<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Colon_Diverticulum" CodeBehind="Diverticulum.aspx.vb" %>

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
            height: 15px;
        }
    </style>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            var diverticulumValueChanged = false;
            var validationMessage = '';
            $(window).on('load', function () {
                //checkAllRadControls($find("NoneCheckBox").get_checked());
                toggleScoringDiv();
            });

            function toggleScoringDiv() {
               <%-- debugger;
                if ($('#<%=NoneCheckBox.ClientID%>').is(':checked') || (!$('#<%=MucosalInflammation_CheckBox.ClientID%>').is(':checked') &&
                    !$('#<%=NarrowingTortuosity_CheckBox.ClientID%>').is(':checked') &&
                    !$('#<%=CircMuscleHypertrophy_CheckBox.ClientID%>').is(':checked'))) {
                    setDICAScoreRequired(false);
                }
                else {
                    setDICAScoreRequired(true);
                }--%>
                
            }
            $(document).ready(function () {
                // Assuming your dropdown has a class named "dropdown" for example
                $(".scoring-div").on("click", ".dica-score-dropdown", function () {
                    // Remove the "nonecheck" box
                    $("#NoneCheckBox").prop('checked', false);
                    diverticulumValueChanged = validateDICAScore();
                });
                $(window).on('beforeunload', function () {
                    valueChange();
                    $('#<%=SaveButton.ClientID%>').click();
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            });

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
                var checked = false;
                var comboId = "";
                var elemId = sender._clientStateFieldID;
                diverticulumValueChanged = true;
                if (elemId.indexOf("NoneCheckBox") == -1) {
                    if (elemId.indexOf("MucosalInflammation_CheckBox") > -1) {
                        checked = args.get_checked();
                        diverticulumValueChanged = true;
                    }
                    else if (elemId.indexOf("QuantityComboBox") > -1) {
                        checked = args._item._text.length > 0;
                        comboId = "DistributionComboBox";
                    }
                    else if (elemId.indexOf("NarrowingTortuosity_CheckBox") > -1) {
                        checked = args.get_checked();
                        comboId = "NarrowingTortuosity_Severity_ComboBox";
                    }
                    else if (elemId.indexOf("CircMuscleHypertrophy_CheckBox") > -1) {
                        checked = args.get_checked();
                    }

                    if (comboId != "") {
                        clearCombo(comboId, checked);
                    }

                    if (checked) {
                        $find("NoneCheckBox").set_checked(false);
                    }
                    if (checked && elemId.indexOf("MucosalInflammation_CheckBox") === -1) {
                        diverticulumValueChanged = validateDICAScore();
                    }
                }

                toggleScoringDiv();
            }

            

            function setDICAScoreRequired(required) {
            var requiredMsg = '';
            $('.dica-score-dropdown').each(function (idx, itm) {
                var selectedPoints = parseInt($find($(itm)[0].id).get_selectedItem().get_attributes().getAttribute('data-points'));
                var radComboBox = $find($(itm)[0].id);
                var selectedItemElement = radComboBox.get_selectedItem().get_element();
                var hasContent = $(selectedItemElement).text().trim().length > 0;
                if (idx < 2) { //only 1st 2 dropdowns are mandatory
                    var ctrlName = $(this)[0].id;
                    var labelName = $(this).closest('tr').find('td').first().find('span').text();
                    if (required) {
                        setRequiredField(ctrlName, labelName.toLowerCase() + ' score');
                    }
                    else {
                        removeRequiredField(ctrlName, labelName.toLowerCase() + ' score');
                        //var rd = $find(ctrlName);
                        //rd.trackChanges();
                        //rd.get_items().getItem(0).select();
                        //rd.commitChanges();
                    }
                    if (required && idx == 0 && selectedPoints < 1) {
                        if (requiredMsg.length > 0) requiredMsg += '\n';
                        requiredMsg += labelName + ' is required.';
                    }
                    if (required && idx == 1 && !hasContent) {
                        if (requiredMsg.length > 0) requiredMsg += '\n';
                        requiredMsg += labelName + ' is required.';
                    }
                }
            });
            if (requiredMsg.length > 0) {
                $find('<%=RadNotification1.ClientID%>').set_text(requiredMsg);
                $find('<%=RadNotification1.ClientID%>').set_position(Telerik.Web.UI.NotificationPosition.Center);
                $find('<%=RadNotification1.ClientID%>').show();
                return true;
            }
                return false;
            }

            function clearCombo(elemId, enableCombo) {
                
                var dropdownlist = $find(elemId);
                if (dropdownlist != null) {
                    var item = dropdownlist.findItemByValue("0");
                    item.select();

                    if (elemId.indexOf("Quantity") == -1 && elemId.indexOf("ucDICAScores") == -1) {
                        if (enableCombo) {
                            dropdownlist.enable();
                        }
                        else {
                            dropdownlist.disable();
                        }
                    }
                }
            }

            function ToggleNoneCheckBox(sender, args) {
                if (args.get_checked()) {
                    checkAllRadControls(args.get_checked());
                }
                diverticulumValueChanged = true;
            }

            function checkAllRadControls(noneChecked) {
                
                var allRadControls = $telerik.radControls;
                for (var i = 0; i < allRadControls.length; i++) {
                    var element = allRadControls[i];
                    var elemId = element.get_element().id;
                    if (Telerik.Web.UI.RadButton && Telerik.Web.UI.RadButton.isInstanceOfType(element)) {
                        if ((elemId != "NoneCheckBox") && elemId.indexOf("_CheckBox") > 0) {
                            element.set_checked(false);
                        }
                    }
                    else if (Telerik.Web.UI.RadComboBox && Telerik.Web.UI.RadComboBox.isInstanceOfType(element)) {
                        clearCombo(elemId, false);
                    }
                }

                toggleScoringDiv();

            }

            function ComboBoxIndexChanged(sender, args) {
                diverticulumValueChanged = true;
            }

            function valueChange() {
                var NoneCheckBox = $find('<%= NoneCheckBox.ClientID %>').get_checked();
                var MucosalInflammation_CheckBox = $find('<%= MucosalInflammation_CheckBox.ClientID %>').get_checked();
                var QuantityComboBoxSelectedValue = '';
                if ($find('<%= QuantityComboBox.ClientID %>').get_selectedItem() !== null) {
                    QuantityComboBoxSelectedIndex = $find('<%= QuantityComboBox.ClientID %>').get_selectedIndex();
                    QuantityComboBoxSelectedValue = $find('<%= QuantityComboBox.ClientID %>').get_selectedItem().get_value();
                }
                var NarrowingTortuosity_CheckBox = $find('<%= NarrowingTortuosity_CheckBox.ClientID %>').get_checked();
                var CircMuscleHypertrophy_CheckBox = $find('<%= CircMuscleHypertrophy_CheckBox.ClientID %>').get_checked();
                if (NoneCheckBox || MucosalInflammation_CheckBox || (((QuantityComboBoxSelectedValue !== '' && QuantityComboBoxSelectedValue !== '0') || NarrowingTortuosity_CheckBox || CircMuscleHypertrophy_CheckBox)) && !setDICAScoreRequired(true)) {
                    localStorage.setItem('valueChanged', 'true');
                } else {
                    localStorage.setItem('valueChanged', 'false');
                }
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
        <telerik:RadScriptManager ID="DiverticulumRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Diverticulum</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server">
                <div id="ContentDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <telerik:RadButton ID="NoneCheckBox" runat="server" Text="None" Skin="Web20" OnClientCheckedChanged="ToggleNoneCheckBox" Font-Bold="true"></telerik:RadButton>
                            <br />
                            <br />

                            <table id="DiverticulumTable" class="rgview" cellpadding="0" cellspacing="0" style="width: 780px;">
                                <tbody>
                                    <tr class="rgRow">
                                        <td colspan="3">
                                            <telerik:RadButton ID="MucosalInflammation_CheckBox" runat="server" Text="Mucosal inflammation" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td>
                                            <div style="margin-left: 20px;">
                                                <asp:Label ID="QuantityLabel" runat="server" Text="Quantity" />
                                                &nbsp;&nbsp;
                                            <telerik:RadComboBox ID="QuantityComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="ToggleTRs"></telerik:RadComboBox>
                                            </div>
                                        </td>
                                        <td style="border-right: none;">
                                            <asp:Label ID="DistributionLabel" runat="server" Text="Distribution" />
                                        </td>
                                        <td style="border-left: none;">
                                            <telerik:RadComboBox ID="DistributionComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="ComboBoxIndexChanged"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td style="width: 200px;">
                                            <telerik:RadButton ID="NarrowingTortuosity_CheckBox" runat="server" Text="Narrowing/tortuosity" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                        <td style="width: 100px; border-right: none;">
                                            <asp:Label ID="SeverityLabel" runat="server" Text="Severity" />
                                        </td>
                                        <td style="border-left: none;">
                                            <telerik:RadComboBox ID="NarrowingTortuosity_Severity_ComboBox" runat="server" Skin="Windows7" OnClientSelectedIndexChanged="ComboBoxIndexChanged"></telerik:RadComboBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td colspan="3">
                                            <telerik:RadButton ID="CircMuscleHypertrophy_CheckBox" runat="server" Text="Circular muscle hypertrophy" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="scoring-div">
                            <UC:DICAScores ID="ucDICAScores" runat="server" />
                        </div>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display: none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
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
