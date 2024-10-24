<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Colon_Mucosa" CodeBehind="Mucosa.aspx.vb" %>

<%@ Register Src="~/UserControls/DICAScoring.ascx" TagName="DICAScores" TagPrefix="UC" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />

    <style type="text/css">
        .ulcerativeTbl {
            border: none;
            margin-top: 5px;
        }

        .ulcerativeTbl td {
            border: none;
        }

        .rbIconButton .rbText {
            padding: 0px !important;
        }
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            height: calc(90vh - 25px) !important;
        }
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            var mucosaValueChanged = false;
            $(window).on('load', function () {
                checkAllRadControls($find("NoneCheckBox").get_checked());
                checkUlcerativeControls($find("Ulcerative_CheckBox").get_checked());
                checkSolitaryUlcerControls($find("SolitaryUlcer_CheckBox").get_checked());
                checkInflammatoryControls($find("Colitis_CheckBox").get_checked(), $find("Ileitis_CheckBox").get_checked());
                checkInflammatoryScoringControls($find("MayoScore_CheckBox").get_checked(), $find("UCEISScore_CheckBox").get_checked());

                var InflammatoryRBL = $find("<%=InflammatoryRadioButtonList.ClientID%>");
                var InflammatoryIndex = InflammatoryRBL.get_selectedIndex();
                var items = InflammatoryRBL.get_items();
                for (var i = 0; i < items.length; i++) {
                    if (items[i].get_selected()) {
                        toggleInflammatoryCombo(items[i].get_text());
                    }
                }
            });

            $(document).ready(function () {
                $("#DiameterNumericTextBox, #ChronsCDEISScoreRadNumericTextBox").change(function () {
                    mucosaValueChanged = true;
                });
                $(window).on('beforeunload', function () {
                    valueChanged(); 
                    $('#<%=SaveButton.ClientID%>').click();
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            });

            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }

            function CloseWindow() {
                window.parent.CloseWindow();
            }

            function ClearControls(tableCell) {
                tableCell.find("input[id*='_CheckBox']").each(function () {
                    var elemId = $(this)[0].id.replace("_ClientState", "");
                    var chkBx = $find(elemId);
                    if (chkBx != null) {
                        chkBx.set_checked(false);
                    }
                });
            }

            function ToggleTRs(sender, args) {
                var enableCombo = args.get_checked();
                var elemId = sender.get_element().id;
                var newElemId = elemId.replace("_CheckBox", "_Distribution_ComboBox");
                clearCombo(newElemId, enableCombo);
                newElemId = elemId.replace("_CheckBox", "_Severity_ComboBox");
                clearCombo(newElemId, enableCombo);
                newElemId = elemId.replace("_CheckBox", "_Type_ComboBox");
                clearCombo(newElemId, enableCombo);

                if (enableCombo) {
                    $find("NoneCheckBox").set_checked(false);
                    if (elemId.indexOf("Ulcers_CheckBox") > -1) {
                        $find("SolitaryUlcer_CheckBox").set_checked(false);
                    }
                }
                mucosaValueChanged = true;
            }

            function ToggleUlcerative(sender, args) {
                if ($('#<%=Ulcerative_CheckBox.ClientID %>').is(':checked')) {
                    $('#UlcerativeControlsTable').show();
                } else {
                    $('#UlcerativeControlsTable').hide();
                }
                ToggleTRs(sender, args);
                checkUlcerativeControls(args.get_checked());
                mucosaValueChanged = true;
            }

            function ToggleSolitaryUlcer(sender, args) {

                checkSolitaryUlcerControls(args.get_checked());
                mucosaValueChanged = true;
            }

            function clearCombo(elemId, enableCombo) {
                var dropdownlist = $find(elemId);
                if (dropdownlist != null) {
                    var item = dropdownlist.findItemByValue("0");
                    item.select();
                    if (enableCombo) {
                        dropdownlist.enable();
                        //$find("NoneCheckBox").set_checked(false);
                    } else {
                        dropdownlist.disable();
                    }
                }
            }

            function ToggleNoneCheckBox(sender, args) {
                if (args.get_checked()) {
                    checkAllRadControls(args.get_checked());
                }
                mucosaValueChanged = true;
            }

            function checkAllRadControls(noneChecked) {
                if (!noneChecked) { return; }
                var allRadControls = $telerik.radControls;
                for (var i = 0; i < allRadControls.length; i++) {
                    var element = allRadControls[i];
                    var elemId = element.get_element().id;
                    if (Telerik.Web.UI.RadButton && Telerik.Web.UI.RadButton.isInstanceOfType(element)) {
                        if ((elemId != "NoneCheckBox") && elemId.indexOf("_CheckBox") > 0) {
                            element.set_checked(false);
                            //removeRequiredField('<%=ExtentDropdownlist.ClientID%>', 'extent');
                        }
                    }
                    else if (Telerik.Web.UI.RadComboBox && Telerik.Web.UI.RadComboBox.isInstanceOfType(element)) {
                        if (elemId.indexOf("_CheckBox") > 0) {
                            clearCombo(elemId, false);
                            //setRequiredField('<%=ExtentDropdownlist.ClientID%>', 'extent');
                        }
                    }
                }
            }

            function checkUlcerativeControls(ulcerativeChecked) {
                var table = $telerik.$("[id$='UlcerativeControlsTable']");

                if (!ulcerativeChecked) {
                    //ClearControls($("#UlcerativeControlsTable"));
                    //$('#UlcerativeControlsTable :input').prop('disabled', true);                    

                    ClearControls(table);
                    $find("DiameterNumericTextBox").clear();
                    $("#DiameterNumericTextBoxTr").hide();
                    table.hide();
                }
                else {
                    table.show();
                }
            }

            function checkSolitaryUlcerControls(solitaryTicked) {
                var numBox = $find("DiameterNumericTextBox");
                if (solitaryTicked) {
                    var table = $telerik.$("[id$='UlcerativeControlsTable']");
                    table.find("input[id*='Ulcers_CheckBox']").each(function () {
                        var elemId = $(this)[0].id.replace("_ClientState", "");
                        var chkBx = $find(elemId);
                        if (chkBx != null) {
                            chkBx.set_checked(false);
                        }
                    });
                    //numBox.set_visible(true);
                    $("#DiameterNumericTextBoxTr").show();
                }
                else {
                    numBox.clear();
                    //numBox.set_visible(false);
                    $("#DiameterNumericTextBoxTr").hide();
                }
            }

            function checkInflammatoryControls(ColitisChecked, IleitisChecked) {
                if (ColitisChecked || IleitisChecked) {
                    $('.colitisdiv').show();
                } else {
                    $('.colitisdiv').hide();
                }

                if (ColitisChecked)
                    HideShowColDropDown(true);
                else
                    HideShowColDropDown(false);
            }

            function checkInflammatoryScoringControls(MayoScoreChecked, UCEISScoreChecked) {
                //20 Aug 2021 : MH changed to show both Mayo & UCEIS together
                if (MayoScoreChecked) {
                    $('.mayoscorediv').show();
                }

                if (UCEISScoreChecked) {
                    $('.uceisscorediv').show();

                };
            }

            function UlcerativeScoring(sender, args) {
                var elemId = sender.get_element().id;
                if ((elemId == 'MayoScore_CheckBox') && (args.get_checked())) {
                    $('.mayoscorediv').show();
                }
                if ((elemId == 'UCEISScore_CheckBox') && (args.get_checked())) {
                    $('.uceisscorediv').show();
                }
            }

            function Colotis(sender, args) {
                var elemId = sender.get_element().id;
                if ((elemId == 'Proctitis_CheckBox') && (args.get_checked())) {
                    $find("NoneCheckBox").set_checked(false);
                }
                else if ((elemId == 'Colitis_CheckBox') && (args.get_checked())) {
                    $find("NoneCheckBox").set_checked(false);
                    $('.colitisdiv').show();
                }
                else if ((elemId == 'Ileitis_CheckBox') && (args.get_checked())) {
                    $find("NoneCheckBox").set_checked(false);
                    $('.colitisdiv').show();
                }
                else if ((!$find("Colitis_CheckBox").get_checked()) && (!$find("Ileitis_CheckBox").get_checked())) {
                    // $('.colitisdiv').find('input[type=button]:checked').removeAttr('checked');
                    HideShowColDropDown(false);
                    $('.colitisdiv').hide();

                    var radioButtonList = $find("<%=ExtentDropdownlist.ClientID%>");
                    var items = radioButtonList.get_items();
                    for (var i = 0; i < items.length; i++) {
                        items[i].set_selected(false);
                    }
                }

                //if colitis isnt ticked
                if (!$find("Colitis_CheckBox").get_checked()) {
                    HideShowColDropDown(false);
                    localStorage.setItem('validationRequired', 'false');
                    if (validationMessage !== "") localStorage.setItem('validationRequiredMessage', '');
                }
                else {
                    HideShowColDropDown(true);
                }
                mucosaValueChanged = true;
            }

            function ReplaceInflammatoryText(cb) {
                var radioButtonList = $find("<%=MayoScoreDropDownList.ClientID%>");
                var items = radioButtonList.get_items();
                for (var i = 0; i < items.length; i++) {
                    if (cb == 'ileitis') {
                        items[i].set_text(items[i].get_text().replace("colitis", "ileitis"));
                    }
                    else if (cb == 'colitis') {
                        items[i].set_text(items[i].get_text().replace("ileitis", "colitis"));
                    }
                }
            }

            function HideShowColDropDown(bShow) {
                if (!bShow) {
                    $('.extentgradingdiv').hide();

                    var rd = $find("<%= ExtentDropdownlist.ClientID%>");
                    rd.trackChanges();
                    rd.get_items().getItem(0).select();
                    rd.commitChanges();

                    rd = $find("<%= MayoScoreDropDownList.ClientID%>");
                    rd.trackChanges();
                    rd.get_items().getItem(0).select();
                    rd.commitChanges();

                    rd = $find("<%= SESDropDownList.ClientID%>");
                    rd.trackChanges();
                    rd.get_items().getItem(0).select();
                    rd.commitChanges();
                    removeRequiredField('<%=SESDropDownList.ClientID%>', 'SES Score-CD');

                } else {
                    $('.extentgradingdiv').show();
                }
            }

            function InflammatoryChanged(sender, args) {
                toggleInflammatoryCombo(args.get_item().get_text());
                mucosaValueChanged = true;
                if (args.get_item().get_text() === 'Diverticular') {
                    validateDICAScore();
                } else {
                    localStorage.setItem('validationRequired', 'false');
                    if (validationMessage !== "") localStorage.setItem('validationRequiredMessage', '');
                }
            }

            function toggleInflammatoryCombo(txt) {
                if (txt.toLowerCase() == 'none specified') {
                    HideShowColDropDown(false);
                    removeRequiredField('<%=ExtentDropdownlist.ClientID%>', 'extent');
                } else {
                    setRequiredField('<%=ExtentDropdownlist.ClientID%>', 'extent');
                    setUCEISRequired(false);

                    //if colitis isnt ticked
                    if (!$find("Colitis_CheckBox").get_checked())
                        HideShowColDropDown(false);
                    else
                        HideShowColDropDown(true);

                }


                //toggle may score div
                if (['ulcerative'].indexOf(txt.toLowerCase()) >= 0) {

                    $('.ulcerativecolitisdiv').show();

                    //MH 20 Aug 2021 : added here by default both will be checked and display child scoring combos
                    $find("MayoScore_CheckBox").set_checked(true);
                    $find("UCEISScore_CheckBox").set_checked(true);
                } else {
                    $('.ulcerativecolitisdiv').hide();

                    $find("MayoScore_CheckBox").set_checked(false);
                    $find("UCEISScore_CheckBox").set_checked(false);

                    var rd = $find("<%= MayoScoreDropDownList.ClientID%>");
                    rd.trackChanges();
                    rd.get_items().getItem(0).select();
                    rd.commitChanges();

                }

                //toggle SE score div
                if (txt.toLowerCase() == "crohn's disease") {
                    $('.chronsdiseasescorediv').show();
                    //$('.cdeisscorediv').show();
                    $('.rutgeertsscorediv').show();
                } else {
                    $('.chronsdiseasescorediv').hide();
                    //$('.cdeisscorediv').hide();
                    $('.rutgeertsscorediv').hide();

                    var rd = $find("<%= SESDropDownList.ClientID%>");
                    rd.trackChanges();
                    rd.get_items().getItem(0).select();
                    rd.commitChanges();
                }

                //toggle diverticulosis scoring
                if (txt.toLowerCase() == "diverticular") {
                    $('.diverticulosisscorediv').show();
                    //set required fields
                    setDICAScoreRequired(true);
                } else {
                    $('.diverticulosisscorediv').hide();
                    //remove required fields
                    setDICAScoreRequired(false);
                }
            }

            function setDICAScoreRequired(required) {
                $('.dica-score-dropdown').each(function (idx, itm) {

                    if (idx < 1) { //only 1st 2 dropdowns are mandatory
                        var ctrlName = $(this)[0].id;
                        var labelName = $(this).closest('tr').find('td').first().find('span').text();

                        if (required) {
                            setRequiredField(ctrlName, labelName.toLowerCase() + ' score');
                        }
                        else {
                            removeRequiredField(ctrlName, labelName.toLowerCase() + ' score');
                        }
                    }
                });
            }

            function setUCEISRequired(required) {
                $('.uceis-scores').each(function (idx, itm) {

                    var ctrlName = $(this)[0].id;
                    var labelName = $(this).closest('tr').find('td').first().find('span').text();

                    if (required) {
                        setRequiredField(ctrlName, labelName.toLowerCase() + ' score');
                    }
                    else {
                        removeRequiredField(ctrlName, labelName.toLowerCase() + ' score');
                    }
                });
            }

            function UCEISScore_changed(sender, args) {
                //reset required status to be calculated below
                setUCEISRequired(false);
                var totalSelected = 0;

                $('.uceis-scores').each(function (idx, itm) {
                    if (itm.value != '') {
                        totalSelected += 1;
                    }
                });

                if (totalSelected > 0) {
                    setUCEISRequired(true);
                }
            }

            function ComboBoxSelectedIndexChanged(sender, args) {
                mucosaValueChanged = true;
            }

            function valueChanged() {
                var NoneCheckBox = $find('<%= NoneCheckBox.ClientID %>').get_checked();
                var Atrophic_CheckBox = $find('<%= Atrophic_CheckBox.ClientID %>').get_checked();
                var Congested_CheckBox = $find('<%= Congested_CheckBox.ClientID %>').get_checked();
                var Erythematous_CheckBox = $find('<%= Erythematous_CheckBox.ClientID %>').get_checked();
                var Granular_CheckBox = $find('<%= Granular_CheckBox.ClientID %>').get_checked();
                var Mucopurulent_CheckBox = $find('<%= Mucopurulent_CheckBox.ClientID %>').get_checked();
                var Pigmented_CheckBox = $find('<%= Pigmented_CheckBox.ClientID %>').get_checked();
                var Ulcerative_CheckBox = $find('<%= Ulcerative_CheckBox.ClientID %>').get_checked();
                var Colitis_CheckBox = $find('<%= Colitis_CheckBox.ClientID %>').get_checked();
                var Ileitis_CheckBox = $find('<%= Ileitis_CheckBox.ClientID %>').get_checked();
                var Proctitis_CheckBox = $find('<%= Proctitis_CheckBox.ClientID %>').get_checked();
                if (NoneCheckBox || Atrophic_CheckBox || Congested_CheckBox || Erythematous_CheckBox ||
                    Granular_CheckBox || Mucopurulent_CheckBox || Pigmented_CheckBox || Ulcerative_CheckBox ||
                    Colitis_CheckBox || Ileitis_CheckBox || Proctitis_CheckBox) {
                    localStorage.setItem('valueChanged', 'true');
                } else {
                    localStorage.setItem('valueChanged', 'false');
                }
            }

        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="MucosaRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Mucosa & Colitides</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="ContentDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <telerik:RadButton ID="NoneCheckBox" runat="server" Text="None" Skin="Web20" OnClientCheckedChanged="ToggleNoneCheckBox" Font-Bold="true"></telerik:RadButton>
                            <br />
                            <table id="MucosaTable" class="rgview" cellpadding="0" cellspacing="0" style="width: 780px;">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="260px" class="rgHeader" style="text-align: left;"></th>
                                        <th width="140px" class="rgHeader">Distribution</th>
                                        <th width="140px" class="rgHeader">Severity</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="Atrophic_CheckBox" runat="server" Text="Atrophic" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Atrophic_Distribution_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Atrophic_Severity_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td>
                                            <telerik:RadButton ID="Congested_CheckBox" runat="server" Text="Congested" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Congested_Distribution_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Congested_Severity_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="Erythematous_CheckBox" runat="server" Text="Erythematous" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Erythematous_Distribution_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Erythematous_Severity_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td>
                                            <telerik:RadButton ID="Granular_CheckBox" runat="server" Text="Granular" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Granular_Distribution_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Granular_Severity_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td>
                                            <telerik:RadButton ID="Mucopurulent_CheckBox" runat="server" Text="Mucopurulent exudate" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Mucopurulent_Distribution_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Mucopurulent_Severity_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td>
                                            <telerik:RadButton ID="Pigmented_CheckBox" runat="server" Text="Pigmented (melanosis)" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Pigmented_Distribution_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadComboBox ID="Pigmented_Severity_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow" id="RedundantRectalRow" runat="server">
                                        <td>
                                            <telerik:RadButton ID="RedundantRectal_CheckBox" runat="server" Text="Redundant anterior rectal mucosa" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td colspan="3">
                                            <telerik:RadButton ID="Ulcerative_CheckBox" runat="server" Text="Ulcerative" Skin="Web20" OnClientCheckedChanged="ToggleUlcerative"></telerik:RadButton>
                                            <br />
                                            <table width="100%" class="ulcerativeTbl" style="display: none;" id="UlcerativeControlsTable">
                                                <tr>
                                                    <td style="vertical-align: top;">
                                                        <table class="ulcerativeTbl">
                                                            <tr>
                                                                <td>
                                                                    <telerik:RadButton ID="SmallUlcers_CheckBox" runat="server" Text="Small ulcers" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                                </td>
                                                                <td>
                                                                    <telerik:RadComboBox ID="SmallUlcers_Type_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <telerik:RadButton ID="LargeUlcers_CheckBox" runat="server" Text="Large ulcers" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                                </td>
                                                                <td>
                                                                    <telerik:RadComboBox ID="LargeUlcers_Type_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <telerik:RadButton ID="PleomorphicUlcers_CheckBox" runat="server" Text="Pleomorphic ulcers" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                                </td>
                                                                <td>
                                                                    <telerik:RadComboBox ID="PleomorphicUlcers_Type_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <telerik:RadButton ID="SerpiginousUlcers_CheckBox" runat="server" Text="Serpiginous ulcers" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                                </td>
                                                                <td>
                                                                    <telerik:RadComboBox ID="SerpiginousUlcers_Type_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <telerik:RadButton ID="AphthousUlcers_CheckBox" runat="server" Text="Aphthous ulcers" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                                </td>
                                                                <td>
                                                                    <telerik:RadComboBox ID="AphthousUlcers_Type_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <telerik:RadButton ID="Cobblestone_CheckBox" runat="server" Text="Cobblestone mucosa" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                                </td>
                                                                <td>
                                                                    <telerik:RadComboBox ID="Cobblestone_Distribution_ComboBox" runat="server" Skin="Windows7" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"></telerik:RadComboBox>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td style="vertical-align: top;">
                                                        <table class="ulcerativeTbl">
                                                            <tr>
                                                                <td>
                                                                    <telerik:RadButton ID="Confluent_CheckBox" runat="server" Text="Confluent ulceration" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <telerik:RadButton ID="DeepUlceration_CheckBox" runat="server" Text="Deep ulceration with fissuring" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td></td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <telerik:RadButton ID="SolitaryUlcer_CheckBox" runat="server" Text="Solitary ulcer" Skin="Web20" OnClientCheckedChanged="ToggleSolitaryUlcer"></telerik:RadButton>
                                                                </td>
                                                            </tr>
                                                            <tr id="DiameterNumericTextBoxTr">
                                                                <td style="border: none;">Largest diameter:
                                                                <telerik:RadNumericTextBox ID="DiameterNumericTextBox" runat="server"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                    mm
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td colspan="3">
                                            <fieldset>
                                                <legend>Inflammatory disorders</legend>
                                                <telerik:RadButton ID="Colitis_CheckBox" runat="server" Text="Colitis" OnClientCheckedChanged="Colotis" class="coloclass" Style="padding-right: 20px;"></telerik:RadButton>
                                                <telerik:RadButton ID="Ileitis_CheckBox" runat="server" Text="Ileitis" OnClientCheckedChanged="Colotis" class="coloclass" Style="padding-right: 20px;"></telerik:RadButton>
                                                <telerik:RadButton ID="Proctitis_CheckBox" runat="server" Text="Proctitis" OnClientCheckedChanged="Colotis" class="coloclass"></telerik:RadButton>
                                                <div style="overflow: auto; display: none; border-top: 1pt dashed #B8CBDE;" class="colitisdiv" id="colitisdiv" runat="server">

                                                    <telerik:RadRadioButtonList runat="server" ID="InflammatoryRadioButtonList" ClientEvents-OnItemClicked="InflammatoryChanged" Columns="3" Skin="Silk" Layout="Flow" AutoPostBack="false" Style="padding-top: 10px;" DataBindings-DataTextField="Description" DataBindings-DataValueField="UniqueId" />

                                                </div>

                                                <div class="extentgradingdiv" style="display: none; padding-top: 10px;" runat="server" id="raddiv">
                                                    <div>
                                                        <asp:Label ID="ExtentGradingLabel" runat="server" Text="Extent:" /><br />
                                                        <telerik:RadComboBox ID="ExtentDropdownlist" runat="server" class="coloclass" Skin="Metro" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"/>
                                                    </div>
                                                    <div class="ulcerativecolitisdiv" style="display: none; float: left; margin-top: 7px;" runat="server" id="ulcerativecolitisdiv">
                                                        <div id="dvMayoAndUCEISCheckboxes" style="display: none;">
                                                            <%--MH:20 Aug 2021 added fix always display Mayo UCEIS--%>
                                                            <telerik:RadButton ID="MayoScore_CheckBox" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" runat="server" Text="Mayo scoring" OnClientCheckedChanged="UlcerativeScoring" class="coloclass" Style="padding-right: 20px;"></telerik:RadButton>
                                                            <telerik:RadButton ID="UCEISScore_CheckBox" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" runat="server" Text="UCEIS scoring" OnClientCheckedChanged="UlcerativeScoring" class="coloclass" Style="padding-right: 20px;"></telerik:RadButton>
                                                            <br />
                                                        </div>
                                                        <div class="mayoscorediv" style="display: none; float: left; margin-top: 7px;" runat="server" id="mayoscorediv">
                                                            <asp:Label runat="server">Mayo Score:</asp:Label><br />
                                                            <telerik:RadComboBox ID="MayoScoreDropDownList" runat="server" CssClass="coloclass mayo-scores" Skin="Metro" Width="455" OnClientDropDownClosed="ComboBoxSelectedIndexChanged" />
                                                        </div>

                                                        <div class="uceisscorediv" style="display: none; float: left; margin-top: 7px;" runat="server" id="uceiscorediv">
                                                            <asp:Label runat="server">UCEIS Score <small>(score most severe lesions)</small>:</asp:Label><br />
                                                            <asp:Repeater ID="rptUCEISScore" runat="server">
                                                                <HeaderTemplate>
                                                                    <table>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <tr>
                                                                        <td style="border: none;">
                                                                            <asp:Label ID="lblSectionName" runat="server" Text='<%#Eval("Description") %>' />
                                                                            <asp:HiddenField ID="ParentIdHiddenField" runat="server" Value='<%#Eval("UniqueId") %>' />
                                                                        </td>
                                                                        <td style="border: none;">
                                                                            <telerik:RadComboBox ID="UCEISScoreRadComboBox" runat="server" DataTextField="Description" DataValueField="UniqueId" Skin="Metro" CssClass="uceis-scores" OnClientSelectedIndexChanged="UCEISScore_changed" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"/>
                                                                        </td>
                                                                    </tr>
                                                                </ItemTemplate>
                                                                <FooterTemplate>
                                                                    </table>
                                                                </FooterTemplate>
                                                            </asp:Repeater>
                                                        </div>
                                                    </div>
                                                    <div class="diverticulosisscorediv" style="display: none; float: left; margin-top: 7px;" runat="server" id="diverticulosisscorediv">
                                                        <UC:DICAScores ID="ucDICAScores" runat="server" />
                                                    </div>
                                                    <div class="chronsdiseasescorediv" style="display: none; margin-top: 7px;" runat="server" id="chronsdiseasescorediv">
                                                        <asp:Label ID="ChronsDiseaseScoreLabel" runat="server" Text="Simple Endoscopic Score – Crohn's Disease (SES-CD):" /><br />
                                                        <telerik:RadComboBox ID="SESDropDownList" runat="server" CssClass="coloclass" Skin="Metro" Width="240" OnClientDropDownClosed="ComboBoxSelectedIndexChanged"/>
                                                    </div>
                                                    <div class="cdeisscorediv" style="display: none; margin-top: 7px;" runat="server" id="cdeisscorediv">
                                                        <asp:Label ID="ChronsCDEISScoreLabel" runat="server" Text="Crohns's Disease Endoscopic Index of Severity (CDEIS):" /><br />
                                                        <telerik:RadNumericTextBox ID="ChronsCDEISScoreRadNumericTextBox" runat="server" Skin="Metro" Width="40" MinValue="0" MaxValue="44" NumberFormat-DecimalDigits="0" />
                                                    </div>
                                                    <div class="rutgeertsscorediv" style="display: none; margin-top: 7px;" runat="server" id="rutgeertsscorediv">
                                                        <asp:Label ID="RutgeertsScoreLabel" runat="server" Text="Rutgeerts Score:" /><br />
                                                        <telerik:RadComboBox ID="RutgeertsScoreRadComboBox" runat="server" Skin="Metro" Width="240" DataTextField="Description" DataValueField="UniqueId" OnClientDropDownClosed="ComboBoxSelectedIndexChanged" />
                                                    </div>
                                                </div>
                                            </fieldset>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="validatePage" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
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
