<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_GastricUlcer" Codebehind="GastricUlcer.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .AutoHeight {
            height: auto !important;
        }

        .RadSplitterNoBorders {
            border-style: none !important;
        }

        .SiteDetailsButtonsPane {
            /*border-top-style: solid;
            border-top-width: 1px;
            border-top-color: ActiveBorder;*/
        }

        .rblType label
        {
            margin-right: 20px;
        }

        div.RadToolBar_Horizontal .rtbSeparator {
           width:20px;
           background: none;
           border: none;
        }

    </style>

    <telerik:RadCodeBlock ID="RadCodeBlock2" runat="server">
        <script type="text/javascript">
            var gastricUlcerValueChanged = false;
            $(window).on('load', function () {
                ToggleDiv("ActiveBleedingCheckBox", "ActiveBleedingRadioButtonListDiv");
                ToggleDiv("VisibleVesselCheckBox", "VisibleVesselRadioButtonListDiv");
                ToggleDiv("NotHealedCheckBox", "NotHealedFieldset");
                ToggleDiv("HealingUlcerCheckBox", "HealingUlcerPageView");
                ToggleDiv("UlcerCheckBox", "UlcerPageView");
            });

            $(document).ready(function () {
                $("#NoneCheckBox").change(function () {
                    gastricUlcerValueChanged = true;
                    if ($(this).is(':checked')) {
                        $("#UlcerCheckBox").prop("checked", false);
                        ClearControls("UlcerPageView");
                        ToggleDiv("UlcerCheckBox", "UlcerPageView");
                        $("#NotHealedCheckBox").prop("checked", false);
                        ClearControls("NotHealedPageView");
                        ToggleDiv("NotHealedCheckBox", "NotHealedFieldset");
                        $("#HealingUlcerCheckBox").prop("checked", false);
                        ClearControls("HealingUlcerPageView");
                        ToggleDiv("HealingUlcerCheckBox", "HealingUlcerPageView");
                        $("#HealedCheckBox").prop("checked", false);
                    }
                });

                $("#UlcerCheckBox").change(function () {
                    gastricUlcerValueChanged = true;
                    if ($(this).is(':checked')) {
                        $("#NoneCheckBox").prop("checked", false);
                        ClearControls("UlcerPageView");
                        ToggleDiv("UlcerCheckBox", "UlcerPageView");
                        $("#NotHealedCheckBox").prop("checked", false);
                        ClearControls("NotHealedPageView");
                        ToggleDiv("NotHealedCheckBox", "NotHealedFieldset");
                        $("#HealingUlcerCheckBox").prop("checked", false);
                        ClearControls("HealingUlcerPageView");
                        ToggleDiv("HealingUlcerCheckBox", "HealingUlcerPageView");
                        $("#HealedCheckBox").prop("checked", false);
                    }
                });

                $("#HealingUlcerCheckBox").change(function () {
                    gastricUlcerValueChanged = true;
                    if ($(this).is(':checked')) {
                        $("#NoneCheckBox").prop("checked", false);
                        $("#UlcerCheckBox").prop("checked", false);
                        ClearControls("UlcerPageView");
                        ToggleDiv("UlcerCheckBox", "UlcerPageView");
                        $("#NotHealedCheckBox").prop("checked", false);
                        ClearControls("NotHealedPageView");
                        ToggleDiv("NotHealedCheckBox", "NotHealedFieldset");
                        ClearControls("HealingUlcerPageView");
                        ToggleDiv("HealingUlcerCheckBox", "HealingUlcerPageView");
                        $("#HealedCheckBox").prop("checked", false);
                    }
                });

                $("#UlcerDiameterRadNumericTextBox, #UlcerNoRadNumericTextBox, #TypeRadioButtonList, #ActiveBleedingRadioButtonList").change(function () {
                    gastricUlcerValueChanged = true;
                });


                $("#ActiveBleedingCheckBox").change(function () {
                    gastricUlcerValueChanged = true;
                    if (!$(this).is(':checked')) {
                        $("#ActiveBleedingRadioButtonList input:radio:checked").removeAttr("checked");
                    }
                    ToggleDiv("ActiveBleedingCheckBox", "ActiveBleedingRadioButtonListDiv");
                });

                $("#VisibleVesselCheckBox").change(function () {
                    gastricUlcerValueChanged = true;
                    if (!$(this).is(':checked')) {
                        $("#VisibleVesselRadioButtonList input:radio:checked").removeAttr("checked");
                    }
                    ToggleDiv("VisibleVesselCheckBox", "VisibleVesselRadioButtonListDiv");
                });

                //-------------
                $("#NotHealedCheckBox").change(function () {
                    gastricUlcerValueChanged = true;
                    if ($(this).is(':checked')) {
                        $("#NoneCheckBox").prop("checked", false);
                        $("#UlcerCheckBox").prop("checked", false);
                        ClearControls("UlcerPageView");
                        ToggleDiv("UlcerCheckBox", "UlcerPageView");
                        $("#HealingUlcerCheckBox").prop("checked", false);
                        ClearControls("HealingUlcerPageView");
                        ToggleDiv("HealingUlcerCheckBox", "HealingUlcerPageView");
                        ClearControls("NotHealedPageView");
                        ToggleDiv("NotHealedCheckBox", "NotHealedFieldset");
                        $("#HealedCheckBox").prop("checked", false);
                    }
                });

                $("#HealedCheckBox").change(function () {
                    gastricUlcerValueChanged = true;
                    if ($(this).is(':checked')) {
                        $("#NoneCheckBox").prop("checked", false);
                        $("#UlcerCheckBox").prop("checked", false);
                        ClearControls("UlcerPageView");
                        ToggleDiv("UlcerCheckBox", "UlcerPageView");
                        $("#HealingUlcerCheckBox").prop("checked", false);
                        ClearControls("HealingUlcerPageView");
                        ToggleDiv("HealingUlcerCheckBox", "HealingUlcerPageView");
                        $("#NotHealedCheckBox").prop("checked", false);
                        ClearControls("NotHealedPageView");
                        ToggleDiv("NotHealedCheckBox", "NotHealedFieldset");
                    }
                });
                //for this page issue 4166  by Mostafiz
                $(window).on('beforeunload', function () {
                    if (gastricUlcerValueChanged) {
                        ValuedChanged();
                        $("#SaveButton").click();
                    }
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                });
            });

            function ValuedChanged() {
                var noneChecked = $("#NoneCheckBox").is(':checked')
                var activeBleedingCheckBox = $("#ActiveBleedingCheckBox").is(':checked')
                var visibleVesselCheckBox = $("#VisibleVesselCheckBox").is(':checked')
                var notHealedCheckBox = $("#NotHealedCheckBox").is(':checked')
                var healingUlcerCheckBox = $("#HealingUlcerCheckBox").is(':checked')
                var ulcerCheckBox = $("#UlcerCheckBox").is(':checked')

                if (noneChecked || activeBleedingCheckBox || visibleVesselCheckBox || notHealedCheckBox || healingUlcerCheckBox || ulcerCheckBox ) {
                    localStorage.setItem('valueChanged', 'true');
                } else {
                    localStorage.setItem('valueChanged', 'false');
                }
            }

            function ToggleDiv(chkboxId, divId) {
                if ($("#" + chkboxId).is(':checked')) {
                    $("#" + divId).show();
                } else {
                    $("#" + divId).hide();
                }
                //alert(chkboxId);
                if (divId.indexOf("RadioButtonListDiv") > 0) { return; }

                var tabStripText;
                var tabStrip = $find("<%=GastricUlcerTabStrip.ClientID%>");
                tabStrip.set_visible(true);
                switch (chkboxId) {
                    case "UlcerCheckBox":
                        tabStripText = "Ulcer";
                        break;
                    case "HealingUlcerCheckBox":
                        tabStripText = "Healing Ulcer";
                        break;
                    case "NotHealedCheckBox":
                        tabStrip.set_visible(false);
                        break;
                    case "HealedCheckBox":
                        tabStrip.set_visible(false);
                        break;
                }
                
                var tab = tabStrip.findTabByText(tabStripText);
                
                if ($("#" + chkboxId).is(':checked')) {
                    if (tab) {
                        tab.set_visible(true);
                        tab.select();
                    }
                } else {
                    if (tab) {
                        tab.set_visible(false);
                       <%-- var tabStrip = $find("<%=GastricUlcerTabStrip.ClientID%>");--%>
                        var tabs = tabStrip.get_tabs();
                        for (var i = 0; i < tabs.get_count() ; i++) {
                            var tab = tabStrip.findTabByText(tabs.getTab(i).get_text());
                            if (tab.get_visible()) { tab.select(); }
                        }
                    }
                }
            }

            function ClearControls(fieldsetId) {
                $("#" + fieldsetId + " input:radio:checked").removeAttr("checked");
                $("#" + fieldsetId + " input:checkbox:checked").removeAttr("checked");
                $("#" + fieldsetId + " input:text").val("");
                ToggleDiv("ActiveBleedingCheckBox", "ActiveBleedingRadioButtonListDiv");
                ToggleDiv("VisibleVesselCheckBox", "VisibleVesselRadioButtonListDiv");
            }

            function CloseWindow() {
                window.parent.CloseWindow();
            }

        </script>
    </telerik:RadCodeBlock> 

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
        <telerik:RadScriptManager ID="GastricUlcerRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Gastric Ulcer</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="divPrevUlcer" runat="server" style="margin-left: 15px;margin-top:7px;padding:5px 10px;background-color:#eef8fb;width:535px;border-bottom:1px solid #d6f2fa;" >
                    <asp:Label ID="PrevUlcerLabel" runat="server" Visible="false" ForeColor="Red" width="540px"></asp:Label>
                </div>
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgGastricUlcer" runat="server" style="padding-bottom:20px;">
                            <table id="GastricUlcerTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <thead>
                                    <tr>
                                        <th class="rgHeader" width="540px" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" Style="margin-right: 10px;" />
                                            <asp:CheckBox ID="UlcerCheckBox" runat="server" Text="Ulcer" Style="margin-right: 10px;" />
                                            <asp:CheckBox ID="NotHealedCheckBox" runat="server" Text="Not Healed" Style="margin-right: 10px;" />
                                            <asp:CheckBox ID="HealingUlcerCheckBox" runat="server" Text="Healing Ulcer" Style="margin-right: 10px;" />
                                            <asp:CheckBox ID="HealedCheckBox" runat="server" Text="Healed" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>

                        <telerik:RadTabStrip runat="server" ID="GastricUlcerTabStrip" MultiPageID="GastricUlcerMultiPage" SelectedIndex="1" ShowBaseLine="False">
                            <Tabs>
                                <telerik:RadTab Text="Ulcer" Width="200px" PageViewID="UlcerTab" Selected="True"></telerik:RadTab>
                                <telerik:RadTab Text="Healing Ulcer" Width="200px" PageViewID="HealingUlcerTab"></telerik:RadTab>
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="GastricUlcerMultiPage" runat="server" SelectedIndex="0" >
                            <telerik:RadPageView ID="UlcerPageView" runat="server" >
                                <div id="divUlcer" style="border:1px solid #828282;width:745px;padding:15px 15px;" runat="server">
                                    <table>
                                        <tr>
                                            <td>
                                                <table>
                                                    <tr valign="top">
                                                        <td class="rfdAspLabel" style="width:40px;">Type :</td>
                                                        <td style="width:150px;">
                                                            <asp:RadioButtonList ID="TypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" CssClass="rblType">
                                                                <asp:ListItem Value="1" Text="Acute"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Chronic"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                            </td>
                                                        <td  class="rfdAspLabel">
                                                            <table>
                                                                <tr valign="top">                                                    
                                                                    <td class="rfdAspLabel" style="width:100px;">Number :</td>
                                                                    <td>
                                                                        <telerik:RadNumericTextBox ID="UlcerNoRadNumericTextBox" runat="server"
                                                                            IncrementSettings-InterceptMouseWheel="false"
                                                                            IncrementSettings-Step="1"
                                                                            Width="35px"
                                                                            MinValue="0">
                                                                            <NumberFormat DecimalDigits="0" />
                                                                        </telerik:RadNumericTextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr valign="top">                                                    
                                                                    <td class="rfdAspLabel">Largest Diameter :</td>
                                                                    <td>
                                                                        <telerik:RadNumericTextBox ID="UlcerDiameterRadNumericTextBox" runat="server"
                                                                            IncrementSettings-InterceptMouseWheel="false"
                                                                            IncrementSettings-Step="0.5"
                                                                            Width="35px"
                                                                            MinValue="0">
                                                                            <NumberFormat DecimalDigits="1" />
                                                                        </telerik:RadNumericTextBox>
                                                                        cm
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div style="margin-left: 0px">
                                                    <fieldset id="Fieldset1" runat="server" class="siteDetailsFieldset" style="width:100%;">
                                                        <legend>Associated with</legend>
                                                        <table>
                                                            <tr valign="top">
                                                                <td>
                                                                    <asp:CheckBox ID="ActiveBleedingCheckBox" runat="server" Text="active bleeding" />
                                                                    <br />
                                                                    <div id="ActiveBleedingRadioButtonListDiv" runat="server" style="margin-left: 10px; display: none;">
                                                                        <asp:RadioButtonList ID="ActiveBleedingRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                                            <asp:ListItem Value="1" Text="spurting"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="oozing"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                    </div>
                                                                </td>
                                                                <td><asp:CheckBox ID="FreshClotCheckBox" runat="server" Text="fresh clot in base" /></td>
                                                                <td>
                                                                    <asp:CheckBox ID="VisibleVesselCheckBox" runat="server" Text="visible vessel" />
                                                                    <br />
                                                                    <div id="VisibleVesselRadioButtonListDiv" runat="server" style="margin-left: 10px; display: none;">
                                                                        <asp:RadioButtonList ID="VisibleVesselRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                                            <asp:ListItem Value="1" Text="adherent clot in base"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="pigmented base"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td><asp:CheckBox ID="OverlyingCheckBox" runat="server" Text="overlying old blood" /></td>
                                                                <td><asp:CheckBox ID="MalignantCheckBox" runat="server" Text="malignant appearance" /></td>
                                                                <td><asp:CheckBox ID="PerforationCheckBox" runat="server" Text="perforation" /></td>
                                                            </tr>
                                                        </table>
                                                    </fieldset>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="HealingUlcerPageView" runat="server" >
                                <div id="divHealingUlcer" style="border:1px solid #828282;width:525px;padding:15px 15px;" runat="server">
                                        <asp:RadioButtonList ID="HealingUlcerRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" >
                                            <asp:ListItem Value="1" Text="Early healing (regenerative mucosa evident)"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Advanced healing (almost complete re-epithelialisation)"></asp:ListItem>
                                            <asp:ListItem Value="3" Text='"Red scar" stage'></asp:ListItem>
                                            <asp:ListItem Value="4" Text="Ulcer scar deformity"></asp:ListItem>
                                            <asp:ListItem Value="5" Text="Atypical? early gastric cancer"></asp:ListItem>
                                        </asp:RadioButtonList>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>


                    <div id="divNotHealed" class="siteDetailsContentDiv">
                        <fieldset id="NotHealedFieldset" runat="server" style="width:510px;padding:15px;">
                            <legend>Not Healed</legend>
                            <telerik:RadTextBox ID="NotHealedRemarksTextBox" runat="server" Width="510px" Height="100px"
                                TextMode="MultiLine" Resize="Vertical">
                            </telerik:RadTextBox>
                        </fieldset>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
