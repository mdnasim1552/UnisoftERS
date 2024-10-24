<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Oesophagitis_OGDOesophagitis" CodeBehind="Oesophagitis.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">

            var oesophagitisValueChanged = false;

            $(window).on('load', function () {
                $('input[type="checkbox"]').each(function () {
                    ToggleTRs($(this));
                });
                ToggleGrade4CheckBox($("#Grade4CheckBox"));
            });

            $(document).ready(function () {
                $("#LosAngelesOesophagitisTable tr td:first-child input:checkbox,input[type=text]  ").change(function () {
                    ToggleTRs($(this));
                    oesophagitisValueChanged = true;
                });

                $("#ModifiedSavaryMillerTable tr td:first-child input:checkbox, input[type=text]").change(function () {
                    ToggleTRs($(this));
                    chkboxMutuallyExclusive($(this));
                    oesophagitisValueChanged = true;
                });

                $("#OtherOesophagitisTable tr td:first-child input:checkbox, input[type=text]").change(function () {
                    ToggleTRs($(this));
                    oesophagitisValueChanged = true;
                });

                $("#NoneCheckBox").change(function () {
                    ToggleNoneCheckBox($(this).is(':checked'));
                    oesophagitisValueChanged = true;
                });

                $("#Grade4CheckBox").change(function () {
                    ToggleGrade4CheckBox($(this));
                    oesophagitisValueChanged = true;
                });
                hideSecondRow(false);

                //for this page issue 4166  by Mostafiz
                $(window).on('beforeunload', function () {                 
                    if (oesophagitisValueChanged) {
                        ValueChanged();
                        $("#SaveButton").click();
                    }
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                });
            });
            var countCheckOesophagitis = 0;
            function ValueChanged() {

                $("#LosAngelesOesophagitisTable tr td:first-child").each(function () {
                    if ($(this).find("input:checkbox:checked").is(':checked')) countCheckOesophagitis++ ;
                   
                });
                $("#ModifiedSavaryMillerTable tr td:first-child").each(function () {
                    if ($(this).find("input:checkbox:checked").is(':checked')) countCheckOesophagitis++;

                });
                $("#OtherOesophagitisTable tr td:first-child").each(function () {
                    if ($(this).find("input:checkbox:checked").is(':checked')) countCheckOesophagitis++;

                });
                $("#MucosalOesophagitisTable tr td:first-child").each(function () {
                    if ($(this).find("input:checkbox:checked").is(':checked')) countCheckOesophagitis++;

                });
                if ($('#NoneCheckBox').is(':checked')){
                    countCheckOesophagitis++;                  
                } 
                

                if (countCheckOesophagitis > 0) {
                    localStorage.setItem('valueChanged', 'true');
                } else {
                    localStorage.setItem('valueChanged', 'false');
                }               
            }

            function CloseWindow() {
                window.parent.CloseWindow();
            }

            function ToggleTRs(chkbox) {
                if (chkbox[0].id != "NoneCheckBox") {
                    var checked = chkbox.is(':checked');
                    if (checked) {
                        $("#NoneCheckBox").prop('checked', false);
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
                            $(this).show();

                        });
                    }

                }

                if ($("#LosAngelesOesophagitisTable tr td:first-child input:checkbox").is(':checked')) {
                    setRequiredField('<%=hfLAClassification.ClientID%>', 'LA classification grade');
                }
                else {
                    removeRequiredField('<%=hfLAClassification.ClientID%>', 'LA classification grade');
                }

                ToggleGrade4CheckBox($("#Grade4CheckBox"));
            }
            //changed by mostafiz issue 3647
            function chkboxMutuallyExclusive(chkbox) {
                var checked = chkbox.is(':checked');
                var cbID = chkbox[0].id;
                if (checked && (cbID.substr(cbID.length - 3) == '_ME')) {
                    if (cbID.indexOf("1") < 0) { $("#Grade1CheckBox_ME").prop('checked', false); }
                    if (cbID.indexOf("2a") < 0) { $("#Grade2aCheckBox_ME").prop('checked', false); }
                    if (cbID.indexOf("2b") < 0) { $("#Grade2bCheckBox_ME").prop('checked', false); }
                    if (cbID.indexOf("3") < 0) { $("#Grade3CheckBox_ME").prop('checked', false); }
                }

            }

            function ToggleGrade4CheckBox(chkbox) {
                var checked = chkbox.is(':checked');
                if (checked) { $("#trGrade4ChkBoxes").show(); }
                else { $("#trGrade4ChkBoxes").hide(); }
            }
            //changed by mostafiz issue 3647
            function ToggleNoneCheckBox(checked) {
                if (checked) {
                    $("#LosAngelesOesophagitisTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").prop('checked', false);
                        $(this).find("input:checkbox").trigger("change");
                    });
                    $("#ModifiedSavaryMillerTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").prop('checked', false);
                        $(this).find("input:checkbox").trigger("change");
                    });
                    $("#OtherOesophagitisTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").prop('checked', false);
                        $(this).find("input:checkbox").trigger("change");
                    });
                    $("#MucosalOesophagitisTable tr td:first-child").each(function () {
                        $(this).find("input:radio:checked").prop('checked', false);
                        $(this).find("input:checkbox").trigger("change");
                    });
                    $("#LA_GradeARadButton,#LA_GradeBRadButton, #LA_GradeCRadButton,#LA_GradeDRadButton").removeClass("imageSetBorder");
                    hideSecondRow(true);
                }
            }
            function hideSecondRow(isNoneCheckBox) {
                $("#secondTr").hide();

                if (isNoneCheckBox) {
                    $("#Suspected_Candida_CheckBox").prop('checked', false);
                    $("#Suspected_Candida_CheckBox").trigger("change");
                    document.getElementById('hfLAClassification').value = "";
                }
                else {
                    var value = document.getElementById('hfLAClassification').value;
                    if (value != null && value != "") {
                        $("#secondTr").show();
                        
                    }
                }

            }

           

            //changed by mostafiz issue 3647
            function ClearControls(tableCell) {
                tableCell.find("input:radio:checked").prop('checked', false);
                tableCell.find("input:checkbox:checked").prop('checked', false);
                tableCell.find("input:text").val("");

            }

            function OnClientClicked(sender, args) {
                oesophagitisValueChanged = true;
                $("#secondTr").show();
                /*Added by rony tfs-4236*/
                //$("#Suspected_Candida_CheckBox").prop('checked', true);
                //$("#Suspected_Candida_CheckBox").trigger("change");
                $("#LosAngelesOesophagitisTable tr td:first-child input:checkbox").prop('checked', true);
                $("#LosAngelesOesophagitisTable tr td:first-child input:checkbox").trigger("change");
                $("#LA_ActiveBleedingCheckBox").prop('checked', false);
                $("#LA_ShortOesophagusCheckBox").prop('checked', false);
                $("#LA_GradeARadButton,#LA_GradeBRadButton, #LA_GradeCRadButton,#LA_GradeDRadButton").removeAttr("class");
                sender.addCssClass("imageSetBorder");
                var id = $(event.target)[0].id;
                var LAClass = 0;

                if (id.indexOf("radeA") > 0) { LAClass = 1; }
                else if (id.indexOf("radeB") > 0) { LAClass = 2; }
                else if (id.indexOf("radeC") > 0) { LAClass = 3; }
                else if (id.indexOf("radeD") > 0) { LAClass = 4; }

                document.getElementById('hfLAClassification').value = LAClass;
            }

            // added by ferdowsi , TFS - 4235
            function MultipleChecked(diag) {

                if ($("#UlcerationMultipleCheckBox") != null && diag == 'Ulceration') {
                    if ($("#UlcerationMultipleCheckBox").is(':checked')) {
                        $find("UlcerationQtyNumericTextBox").set_value("");
                        $find("UlcerationLengthNumericTextBox").set_value("");
                    }
                }
            } 

            function QtyChanged(diag) {
                 $("#UlcerationMultipleCheckBox").removeAttr("checked");
                
            }
        </script>
    </telerik:RadScriptBlock>
    <style type="text/css">
        .SiteDetailsForm {
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

            .SiteDetailsForm td {
                padding-bottom: 10px;
            }

        .rblType label {
            margin-right: 22px;
        }

        .imageSetBorder {
            border: 3px solid blue !important;
        }

        .imageRemoveBorder {
            border: none;
        }

        .controlsRadPane {
            height: 650px !important;
        }
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            height: calc(90vh - 20px) !important;
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
        <telerik:RadScriptManager ID="OGDOesophagitisRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

                <div class="abnorHeader">Oesophagitis</div>
                <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
                    <telerik:RadPane ID="ControlsRadPane" runat="server" CssClass="controlsRadPane" Scrolling="Y" Width="95%">
                        <div id="FormDiv" runat="server">

                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgOesophagitis" runat="server">
                                    <table id="OesophagitisTable" class="rgview" cellpadding="0" cellspacing="0" style="width: 780px">
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" width="600px" style="text-align: left;">
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="No oesophagitis" ForeColor="Black" />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <div style="margin: 10px 10px;">
                                <fieldset id="LAClassificationFieldset" runat="server" style="display: block; width: 750px;">
                                    <legend class="siteDetailsLegend">Los Angeles classification</legend>
                                    <table id="LosAngelesOesophagitisTable">
                                        <tr headrow="1" haschildrows="1">
                                            <td style="border: none; vertical-align: top;">
                                                <asp:CheckBox ID="LA_RefluxCheckBox" runat="server" Text="Reflux" />
                                            </td>
                                            <td style="border: none;">
                                                <table>
                                                    <tr>
                                                        <td style="border: none; vertical-align: top; width: 70%">
                                                            <asp:CheckBox ID="LA_ActiveBleedingCheckBox" runat="server" Text="with active bleeding" />
                                                            <%--<asp:CheckBox ID="LA_UlcerCheckBox" runat="server" Text="Ulcer" />
                                                    <div style="width:45px;display:inline-block; "></div>
                                                    <asp:CheckBox ID="LA_StrictureCheckBox" runat="server" Text="Stricture" />
                                                    <div style="width:45px;display:inline-block; "></div>--%>
                                                            <span style="padding-left: 80px;" />
                                                            <asp:CheckBox ID="LA_ShortOesophagusCheckBox" runat="server" Text="Short oesophagus" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left;" colspan="2">
                                                <asp:HiddenField runat="server" ID="hfLAClassification" Value="" />
                                                <table>
                                                    <tr headrow="1" haschildrows="1">
                                                        <td style="border: none;">
                                                            <fieldset id="Fieldset2" runat="server" style="display: block; width: 250px;">
                                                                <legend class="siteDetailsLegend">Grade A</legend>
                                                                <div style="float: left; height: 70px;">
                                                                    <telerik:RadButton ID="LA_GradeARadButton" runat="server" Width="63px" Height="70px" AutoPostBack="false" Checked="true" OnClientClicked="OnClientClicked">
                                                                        <Image ImageUrl="../../../../Images/RefluxGradeA.png" />
                                                                    </telerik:RadButton>
                                                                </div>
                                                                <div style="float: right; width: 170px;">Mucosal breaks confined to the mucosal fold each no longer than 5mm.</div>
                                                            </fieldset>
                                                        </td>
                                                        <td style="border: none;">
                                                            <fieldset id="Fieldset3" runat="server" style="display: block; width: 250px;">
                                                                <legend class="siteDetailsLegend">Grade B</legend>
                                                                <div style="float: left; height: 70px;">
                                                                    <telerik:RadButton ID="LA_GradeBRadButton" runat="server" Width="63px" Height="70px" AutoPostBack="false" OnClientClicked="OnClientClicked">
                                                                        <Image ImageUrl="../../../../Images/RefluxGradeB.png" />
                                                                    </telerik:RadButton>
                                                                </div>
                                                                <div style="float: right; width: 170px;">At least one mucosal break longer than 5mm confined to the mucosal fold but not continuous between two folds.</div>
                                                            </fieldset>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="border: none;">
                                                            <fieldset id="Fieldset4" runat="server" style="display: block; width: 250px;">
                                                                <legend class="siteDetailsLegend">Grade C</legend>
                                                                <div style="float: left; height: 70px;">
                                                                    <telerik:RadButton ID="LA_GradeCRadButton" runat="server" Width="63px" Height="70px" AutoPostBack="false" OnClientClicked="OnClientClicked">
                                                                        <Image ImageUrl="../../../../Images/RefluxGradeC.png" />
                                                                    </telerik:RadButton>
                                                                </div>
                                                                <div style="float: right; width: 170px;">Mucosal breaks that are continuous between the tops of mucosal folds but not circumferential.</div>
                                                            </fieldset>
                                                        </td>
                                                        <td style="border: none;">
                                                            <fieldset id="Fieldset5" runat="server" style="display: block; width: 250px;">
                                                                <legend class="siteDetailsLegend">Grade D</legend>
                                                                <div style="float: left; height: 70px;">
                                                                    <telerik:RadButton ID="LA_GradeDRadButton" runat="server" Width="63px" Height="70px" AutoPostBack="false" OnClientClicked="OnClientClicked">
                                                                        <Image ImageUrl="../../../../Images/RefluxGradeD.png" />
                                                                    </telerik:RadButton>
                                                                </div>
                                                                <div style="float: right; width: 170px;">Extensive mucosal breaks engaging at least 75% of the oesophageal circumference.</div>
                                                            </fieldset>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>


                                <fieldset id="MSMFieldset" runat="server" visible="false">
                                    <legend class="MSMLegend">Modified Savary Miller</legend>
                                    <table id="ModifiedSavaryMillerTable">
                                        <tr headrow="1" haschildrows="1">
                                            <td style="border: none; vertical-align: top;">
                                                <asp:CheckBox ID="MSM_RefluxCheckBox" runat="server" Text="Reflux" />
                                            </td>
                                            <td cellpadding="0" cellspacing="0" style="border: none;">
                                                <table cellpadding="0" cellspacing="0" style="border: none;">
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBox ID="MSM_ActiveBleedingCheckBox" runat="server" Text="Active bleeding" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left;" colspan="2">
                                                <div style="float: left; vertical-align: top; width: 90px;">
                                                    <asp:CheckBox ID="Grade1CheckBox_ME" runat="server" /><label style="font-weight: bold;">Grade 1</label>
                                                </div>
                                                <div style="float: left; vertical-align: top; width: 450px; padding-top: 3px;">
                                                    <asp:Label ID="Grade1Label" runat="server" Text="Single or isolated erosion(s), oval or linear, but affecting only one longitudinal fold" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left; padding-left: 35px;" colspan="2"><i>or</i></td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left;" colspan="2">
                                                <div style="float: left; vertical-align: top; width: 90px;">
                                                    <asp:CheckBox ID="Grade2aCheckBox_ME" runat="server" /><label style="font-weight: bold;">Grade 2a</label>
                                                </div>
                                                <div style="float: left; vertical-align: top; width: 450px; padding-top: 3px;">
                                                    <asp:Label ID="Grade2aLabel" runat="server" Text="Multiple erosions, non-circumferential, affecting greater than one longitudinal fold, without confluence" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left; padding-left: 35px;" colspan="2"><i>or</i></td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left;" colspan="2">
                                                <div style="float: left; vertical-align: top; width: 90px;">
                                                    <asp:CheckBox ID="Grade2bCheckBox_ME" runat="server" /><label style="font-weight: bold;">Grade 2b</label>
                                                </div>
                                                <div style="float: left; vertical-align: top; width: 450px; padding-top: 3px;">
                                                    <asp:Label ID="Grade2bLabel" runat="server" Text="As 2a, with confluence, but not circumferential" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left; padding-left: 35px;" colspan="2"><i>or</i></td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left;" colspan="2">
                                                <div style="float: left; vertical-align: top; width: 90px;">
                                                    <asp:CheckBox ID="Grade3CheckBox_ME" runat="server" /><label style="font-weight: bold;">Grade 3</label>
                                                </div>
                                                <div style="float: left; vertical-align: top; width: 450px; padding-top: 3px;">
                                                    <asp:Label ID="Grade3Label" runat="server" Text="Circumferential erosion" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left; padding-left: 30px;" colspan="2"><i>with</i></td>
                                        </tr>

                                        <tr childrow="1">
                                            <td style="border: none; text-align: left;" colspan="2">
                                                <div style="float: left; vertical-align: top; width: 90px;">
                                                    <asp:CheckBox ID="Grade4CheckBox" runat="server" /><label style="font-weight: bold;">Grade 4</label>
                                                </div>
                                                <div style="float: left; vertical-align: top; width: 450px; padding-top: 3px;">
                                                    <asp:Label ID="Grade4Label" runat="server">Chronic lesions: ulcer(s), stricture(s), and/or short oesophagus. <br /> Alone or in association with lesions of grades 1-3</asp:Label>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr childrow="1" id="trGrade4ChkBoxes">
                                            <td style="border: none; vertical-align: top;"></td>
                                            <td style="border: none;">
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <%--<asp:CheckBox ID="MSM_UlcerCheckBox" runat="server" Text="Ulcer" />
                                                    <div style="width:45px;display:inline-block; "></div>
                                                    <asp:CheckBox ID="MSM_StrictureCheckBox" runat="server" Text="Stricture" />
                                                    <div style="width:45px;display:inline-block; "></div>--%>
                                                            <asp:CheckBox ID="MSM_ShortOesophagusCheckBox" runat="server" Text="Short oesophagus" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>

                                        <tr childrow="1">
                                            <td style="border: none; text-align: left; padding-left: 28px;" colspan="2"><i>and/or</i></td>
                                        </tr>
                                        <tr childrow="1">
                                            <td style="border: none; text-align: left;" colspan="2">
                                                <div style="float: left; vertical-align: top; width: 90px; font-weight: bold;">
                                                    <asp:CheckBox ID="Grade5CheckBox" runat="server" /><label style="font-weight: bold;">Grade 5</label>
                                                </div>
                                                <div style="float: left; vertical-align: top; width: 450px; padding-top: 3px;">
                                                    <asp:Label ID="Grade5Label" runat="server">Barrett's epithelium in continuity with the Z-line, non-circular, star-shaped or circumferential.<br />Alone or associated with lesions of grades 1-4</asp:Label>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>

                                <div style="height: 10px;"></div>

                                <fieldset id="Fieldset1" runat="server" style="display: block; width: 750px;">
                                    <legend class="siteDetailsLegend">Other</legend>
                                    <table id="OtherOesophagitisTable">
                                        <tr>
                                            <td style="">
                                                <table border="0">
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBox ID="Caustic_Ingestion_CheckBox" runat="server" Text="Caustic ingestion" OnClientCheckedChanged="ToggleTRs" />
                                                        </td>
                                                        <td style="padding-left: 20px;">
                                                            <telerik:RadComboBox ID="Caustic_Ingestion_Other_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr id="secondTr">
                                                        <td>
                                                            <asp:CheckBox ID="Suspected_Candida_CheckBox" runat="server" Text="Suspected candida" OnClientCheckedChanged="ToggleTRs" />
                                                        </td>
                                                        <td style="padding-left: 20px;">
                                                            <telerik:RadComboBox ID="Suspected_Candida_Other_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBox ID="Suspected_Herpes_CheckBox" runat="server" Text="Suspected herpes" OnClientCheckedChanged="ToggleTRs" />
                                                        </td>
                                                        <td style="padding-left: 20px;">
                                                            <telerik:RadComboBox ID="Suspected_Herpes_Other_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBox ID="Corrosive_Burns_CheckBox" runat="server" Text="Corrosive ingestion burns" OnClientCheckedChanged="ToggleTRs" />
                                                        </td>
                                                        <td style="padding-left: 20px;">
                                                            <telerik:RadComboBox ID="Corrosive_Burns_Other_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBox ID="Eosinophilic_CheckBox" runat="server" Text="Eosinophilic" OnClientCheckedChanged="ToggleTRs" />
                                                        </td>
                                                        <td style="padding-left: 20px;">
                                                            <telerik:RadComboBox ID="Eosinophilic_Other_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                        </td>
                                                    </tr>
                                                <%--    Aded by Ferdowsi , TFS - 4235--%>
                                                    <tr id="UlcerationTR" runat="server">
                                                        <td style="border: none; vertical-align: top;">
                                                            <asp:CheckBox ID="Ulceration" runat="server" Text="Ulceration" />
                                                        </td>

                                                        <td style="border: none;">
                                                            <div style="float: left; padding-left: 15px;">
                                                                <asp:CheckBox ID="UlcerationMultipleCheckBox" runat="server" Text="Multiple &nbsp; <i>OR</i> &nbsp; qty" Style="margin-right: 10px;" onchange="MultipleChecked('Ulceration');" />
                                                                <telerik:RadNumericTextBox ID="UlcerationQtyNumericTextBox" runat="server"
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="true"
                                                                    IncrementSettings-Step="1"
                                                                    Width="50px"
                                                                    MinValue="0"
                                                                    onchange="QtyChanged('Ulceration');">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                Length
                                                                <telerik:RadNumericTextBox ID="UlcerationLengthNumericTextBox" runat="server"
                                                                ShowSpinButtons="true"
                                                                IncrementSettings-InterceptMouseWheel="true"
                                                                IncrementSettings-Step="1"
                                                                onchange="QtyChanged('Ulceration');"
                                                                Width   ="50px"
                                                                MinValue="0">
                                                               <NumberFormat DecimalDigits="0" />
                                                               </telerik:RadNumericTextBox>
                                                                mm
                                                                <span style="margin-left: 20px;"></span>
                                                                <asp:CheckBox ID="UlcerationClotInBase" runat="server" Text="Clot in base" />

                                                                <div>
                                                                    <asp:CheckBox ID="UlcerationReflux" runat="server" Text="Reflux (grade 4)" />
                                                                    <span style="margin-left: 20px;"></span>
                                                                    <asp:CheckBox ID="UlcerationPostSclero" runat="server" Text="Post sclerotherapy" />
                                                                    <span style="margin-left: 73px;"></span>
                                                                    <asp:CheckBox ID="UlcerationPostBanding" runat="server" Text="Post banding" />
                                                                </div>
                                                            </div>
                                                        </td>
                                                    </tr>

                                                    <tr>
                                                        <td>
                                                            <asp:CheckBox ID="Other_Other_CheckBox" runat="server" Text="Other" />
                                                        </td>
                                                        <td style="padding-left: 20px;">
                                                            <telerik:RadTextBox ID="OtherTextBox" runat="server" Skin="Windows7" Width="400px" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>

                            </div>

                </div>
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="validatePage" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
  <%--          <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="validatePage" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>--%>
                </telerik:RadSplitter>

            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
