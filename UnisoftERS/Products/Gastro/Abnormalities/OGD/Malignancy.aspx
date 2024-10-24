<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Malignancy" Codebehind="Malignancy.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .RadSplitterNoBorders {
            border-style: none !important;
        }

        .SiteDetailsButtonsPane {
            /*border-top-style: solid;
            border-top-width: 1px;
            border-top-color: ActiveBorder;*/
        }
    </style>

    <telerik:RadCodeBlock ID="RadCodeBlock2" runat="server">
    <script type="text/javascript">
        var malignancyValueChanged = false;
        $(window).on('load', function () {
            ToggleNoneCheckBox();
            ToggleDiv("LymphomaCheckBox", "LymphomaPageView");
            ToggleDiv("AdvCarcinomaCheckBox", "GastricCarcinomaPageView");
            ToggleDiv("EarlyCarcinomaCheckBox", "EarlyCarcinomaPageView");
            ShowEarlyTypeDiv();
            ShowGastricTypeDiv();
            ShowLymphomaTypeDiv();
            toggleBenignOtherTextBox();
            toggleMalignantOtherTextBox();
        });

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        $(document).ready(function () {
            $("#NoneCheckBox").change(function () {
                malignancyValueChanged = true;
                if (!$(this).is(':checked')) {
                    ClearControls("EarlyCarcinomaPageView");
                    ClearControls("GastricCarcinomaPageView");
                    ClearControls("LymphomaPageView");
                }
                ToggleNoneCheckBox();
            });
            //changed by mostafiz issue 3647 
            $("#EarlyCarcinomaCheckBox").change(function () {
                malignancyValueChanged = true;
                if (!$(this).is(':checked')) {
                    ClearControls("EarlyCarcinomaPageView");
                } else { $("#NoneCheckBox").prop('checked', false); }
                ToggleDiv("EarlyCarcinomaCheckBox", "EarlyCarcinomaPageView");
            });
            //changed by mostafiz issue 3647 
            $("#AdvCarcinomaCheckBox").change(function () {
                malignancyValueChanged = true;
                if (!$(this).is(':checked')) {
                    ClearControls("GastricCarcinomaPageView");
                } else { $("#NoneCheckBox").prop('checked', false); }
                ToggleDiv("AdvCarcinomaCheckBox", "GastricCarcinomaPageView");
            });
            //changed by mostafiz issue 3647 
            $("#LymphomaCheckBox").change(function () {
                malignancyValueChanged = true;
                if (!$(this).is(':checked')) {
                    ClearControls("LymphomaPageView");
                } else { $("#NoneCheckBox").prop('checked', false); }
                ToggleDiv("LymphomaCheckBox", "LymphomaPageView");
            });

            /*Early*/
            $("#EarlyTypeRadioButtonList").on('change', function () {
                malignancyValueChanged = true;
                ShowEarlyTypeDiv();
                ClearTypeControls($("#SubEarlyTypeDiv"));
                ClearTypeControls($("#EarlyMalignantDiv"));
                ClearTypeControls($("#EarlyBenignDiv"));
            });

            $("#SubEarlyTypeRadioButtonList, #EarlyMalignantOtherTextBox, #EarlyBenignOtherTextBox,#EarlyCarcinomaBleedingRadioButtonList,#EarlyCarcinomaLesionRadioButtonList, #EarlyCarcinomaDiaNumericTextBox, #EarlyCarcinomaEndNumericTextBox,#EarlyCarcinomaStartNumericTextBox").on('change', function () {
                malignancyValueChanged = true;
            });
            $("#SubGastricTypeRadioButtonList, #GastricBenignOtherTextBox, #GastricMalignantOtherTextBox, #AdvCarcinomaLesionRadioButtonList, #AdvCarcinomaBleedingRadioButtonList, #AdvCarcinomaStartNumericTextBox, #AdvCarcinomaEndNumericTextBox, #AdvCarcinomaDiaNumericTextBox").on('change', function () {
                malignancyValueChanged = true;
            });
            $("#SubLymphomaTypeRadioButtonList, #LymphomaMalignantOthertextBox, #LymphomaBenignOtherTextBox, #LymphomaLesionRadioButtonList, #LymphomaBleedingRadioButtonList, #LymphomaStartNumericTextBox, #LymphomaEndNumericTextBox, #LymphomaDiaNumericTextBox").change(function () {
                malignancyValueChanged = true;             
            });

            $("#EarlyProbablyCheckBox").change(function () {
                malignancyValueChanged = true;
                ShowEarlyProbableText();
            });

            $("#EarlyBenignRadioButtonList").on('change', function () {
                malignancyValueChanged = true;
                ChkOtherEarlyBenign();
            });

            $("#EarlyMalignantRadioButtonList").on('change', function () {
                malignancyValueChanged = true;
                ChkOtherEarlyMalignant();
            });

            $("#<%= EarlyBenignRadioButtonList.ClientID %> input").change(function () {
                malignancyValueChanged = true;
                toggleBenignOtherTextBox();
            });

            $("#<%= EarlyMalignantRadioButtonList.ClientID %> input").change(function () {
                malignancyValueChanged = true;
                toggleMalignantOtherTextBox();
            });

            /*Gastric*/
            $("#GastricTypeRadioButtonList").on('change', function () {
                malignancyValueChanged = true;
                ShowGastricTypeDiv();
                ClearTypeControls($("#SubGastricTypeDiv"));
                ClearTypeControls($("#GastricMalignantDiv"));
                ClearTypeControls($("#GastricBenignDiv"));
            });

            $("#GastricProbablyCheckBox").change(function () {
                malignancyValueChanged = true;
                ShowGastricProbableText();
            });

            $("#GastricBenignRadioButtonList").on('change', function () {
                malignancyValueChanged = true;
                ChkOtherGastricBenign();
            });

            $("#GastricMalignantRadioButtonList").on('change', function () {
                malignancyValueChanged = true;
                ChkOtherGastricMalignant();
            });

            $("#<%= GastricBenignRadioButtonList.ClientID %> input").change(function () {
                malignancyValueChanged = true;
                toggleBenignOtherTextBox();
            });

            $("#<%= GastricMalignantRadioButtonList.ClientID %> input").change(function () {
                malignancyValueChanged = true;
                toggleMalignantOtherTextBox();
            });

            /*Lymphoma*/
            $("#LymphomaTypeRadioButtonList").on('change', function () {
                malignancyValueChanged = true;
                ShowLymphomaTypeDiv();
                ClearTypeControls($("#SubLymphomaTypeDiv"));
                ClearTypeControls($("#LymphomayMalignantDiv"));
                ClearTypeControls($("#LymphomaBenignDiv"));
            });

            $("#LymphomaProbablyCheckBox").change(function () {
                malignancyValueChanged = true;
                ShowLymphomaProbableText();
            });

            $("#LymphomaBenignRadioButtonList").on('change', function () {
                malignancyValueChanged = true;
                ChkOtherLymphomaBenign();
            });

            $("#LymphomaMalignantRadioButtonList").on('change', function () {
                malignancyValueChanged = true;
                ChkOtherLymphomaMalignant();
            });

            $("#<%= LymphomaBenignRadioButtonList.ClientID %> input").change(function () {
                malignancyValueChanged = true;
                toggleBenignOtherTextBox();
            });

            $("#<%= LymphomaMalignantRadioButtonList.ClientID %> input").change(function () {
                malignancyValueChanged = true;
                toggleMalignantOtherTextBox();
            });
            //for this page issue 4166  by Mostafiz
            $(window).on('beforeunload', function () {
                if (malignancyValueChanged) {
                    ValuedChanged();
                    $("#SaveButton").click();
                }
            });

        });

        function ValuedChanged() {
            var noneChecked = $("#NoneCheckBox").is(':checked')
            var earlyCarcinomaCheckBox = $("#EarlyCarcinomaCheckBox").is(':checked')
            var advCarcinomaCheckBox = $("#AdvCarcinomaCheckBox").is(':checked')
            var lymphomaCheckBox = $("#LymphomaCheckBox").is(':checked')

            if (noneChecked || earlyCarcinomaCheckBox || advCarcinomaCheckBox || lymphomaCheckBox) {
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

            var tabStripText;
            switch (chkboxId) {
                case "EarlyCarcinomaCheckBox":
                    tabStripText = "Early Carcinoma";
                    break;
                case "AdvCarcinomaCheckBox":
                    tabStripText = "Established Gastric Carcinoma";
                    break;
                case "LymphomaCheckBox":
                    tabStripText = "Gastric Lymphoma";
                    break;
            }
            var tabStrip = $find("<%=MalignancyTabStrip.ClientID%>");
            var tab = tabStrip.findTabByText(tabStripText);

            if ($("#" + chkboxId).is(':checked')) {
                if (tab) {
                    tab.set_visible(true);
                    tab.select();
                }
            } else {
                if (tab) {
                    tab.set_visible(false);
                    var tabStrip = $find("<%=MalignancyTabStrip.ClientID%>");
                        var tabs = tabStrip.get_tabs();
                        for (var i = 0; i < tabs.get_count() ; i++) {
                            var tab = tabStrip.findTabByText(tabs.getTab(i).get_text());
                            if (tab.get_visible()) { tab.select(); }
                                
                        }
                }
            }


            }
             //changed by mostafiz issue 3647 
        function ToggleNoneCheckBox() {
            if ($("#NoneCheckBox").is(':checked')) {
                //$("#EarlyCarcinomaCheckBox").attr("disabled", "disabled");
                $("#EarlyCarcinomaCheckBox").prop('checked',false);
                $("#EarlyCarcinomaPageView").hide();

                //$("#AdvCarcinomaCheckBox").attr("disabled", "disabled");
                $("#AdvCarcinomaCheckBox").prop('checked', false);
                $("#GastricCarcinomaPageView").hide();

                //$("#LymphomaCheckBox").attr("disabled", "disabled");
                $("#LymphomaCheckBox").prop('checked', false);
                $("#LymphomaPageView").hide();

                var tabStrip = $find("<%=MalignancyTabStrip.ClientID%>");
                var tabs = tabStrip.get_tabs();
                for (var i = 0; i < tabs.get_count() ; i++) {
                    var tab = tabStrip.findTabByText(tabs.getTab(i).get_text());
                    if (tab) { tab.set_visible(false); }
                }
            } else {
                $("#EarlyCarcinomaCheckBox").prop("disabled", false);
                $("#AdvCarcinomaCheckBox").prop("disabled", false);
                $("#LymphomaCheckBox").prop("disabled", false);

            }
        }
         //changed by mostafiz issue 3647 
        function ClearControls(fieldsetId) {
            $("#" + fieldsetId + " input:radio:checked").prop('checked', false);
            $("#" + fieldsetId + " input:checkbox:checked").prop('checked', false);
            $("#" + fieldsetId + " input:text").val("");
        }

        function ClearTypeControls(tableCell) {
            tableCell.find("input:radio:checked").removeAttr("checked");
            tableCell.find("input:checkbox:checked").removeAttr("checked");
            tableCell.find("input:text").val("");
        }

        function toggleBenignOtherTextBox() {
            if ($("#<%= EarlyBenignRadioButtonList.ClientID %> input:checked").val() === "5") {
                $("#<%= EarlyBenignOtherTextBox.ClientID %>").show();
            } else {
                $("#<%= EarlyBenignOtherTextBox.ClientID %>").hide();
            }

            if ($("#<%= GastricBenignRadioButtonList.ClientID %> input:checked").val() === "5") {
                $("#<%= GastricBenignOtherTextBox.ClientID %>").show();
            } else {
                $("#<%= GastricBenignOtherTextBox.ClientID %>").hide();
            }

            if ($("#<%= LymphomaBenignRadioButtonList.ClientID %> input:checked").val() === "5") {
                $("#<%= LymphomaBenignOtherTextBox.ClientID %>").show();
            } else {
                $("#<%= LymphomaBenignOtherTextBox.ClientID %>").hide();
            }
        }

        function toggleMalignantOtherTextBox() {
            if ($("#<%= EarlyMalignantRadioButtonList.ClientID %> input:checked").val() === "4") {
                $("#<%= EarlyMalignantOtherTextBox.ClientID %>").show();
            } else {
                $("#<%= EarlyMalignantOtherTextBox.ClientID %>").hide();
            }

            if ($("#<%= GastricMalignantRadioButtonList.ClientID %> input:checked").val() === "4") {
                $("#<%= GastricMalignantOtherTextBox.ClientID %>").show();
            } else {
                $("#<%= GastricMalignantOtherTextBox.ClientID %>").hide();
            }

            if ($("#<%= LymphomaMalignantRadioButtonList.ClientID %> input:checked").val() === "4") {
                $("#<%= LymphomaMalignantOtherTextBox.ClientID %>").show();
            } else {
                $("#<%= LymphomaMalignantOtherTextBox.ClientID %>").hide();
            }
        }

        /*Early functions*/
        function ShowEarlyTypeDiv() {
            var isType = false;

            if ($('#EarlyTypeRadioButtonList_0').is(':checked')) {
                $("#EarlyBenignDiv").show();
                $("#SubEarlyTypeDiv").show();
                isType = true;
            } else {
                $("#EarlyBenignDiv").hide();
            }
            if ($('#EarlyTypeRadioButtonList_1').is(':checked')) {
                $("#EarlyMalignantDiv").show();
                $("#SubEarlyTypeDiv").show();
                isType = true;
            } else {
                $("#EarlyMalignantDiv").hide();
            }
            if (!isType) {
                $("#SubEarlyTypeDiv").hide();
            }
            ShowEarlyProbableText();
        }

        function ShowEarlyProbableText() {
            if ($('#EarlyProbablyCheckBox').is(':checked')) {
                $('#EarlyBenignRadioButtonList_1').next().html('Probable leiomyoma');
                $('#EarlyBenignRadioButtonList_2').next().html('Probable lipoma');
                $('#EarlyBenignRadioButtonList_3').next().html('Probable granular cell tumour');
                $('#EarlyMalignantRadioButtonList_1').next().html('Probable squamous carcinoma');
                $('#EarlyMalignantRadioButtonList_2').next().html('Probable adenocarcinoma');
            } else {
                $('#EarlyBenignRadioButtonList_1').next().html('Leiomyoma');
                $('#EarlyBenignRadioButtonList_2').next().html('Lipoma');
                $('#EarlyBenignRadioButtonList_3').next().html('Granular cell tumour');
                $('#EarlyMalignantRadioButtonList_1').next().html('Squamous carcinoma');
                $('#EarlyMalignantRadioButtonList_2').next().html('Adenocarcinoma');
            }
        }

        function ChkOtherEarlyBenign() {
            if (!$('#EarlyBenignRadioButtonList_4').is(':checked')) {
                $("#EarlyBenignOtherTextBox").val("");
            }
        }

        function ChkOtherEarlyMalignant() {
            if (!$('#EarlyMalignantRadioButtonList_3').is(':checked')) {
                $("#EarlyMalignantOtherTextBox").val("");
            }
        }

        /*Gastric functions*/
        function ShowGastricTypeDiv() {
            var isType = false;

            if ($('#GastricTypeRadioButtonList_0').is(':checked')) {
                $("#GastricBenignDiv").show();
                $("#SubGastricTypeDiv").show();
                isType = true;
            } else {
                $("#GastricBenignDiv").hide();
            }
            if ($('#GastricTypeRadioButtonList_1').is(':checked')) {
                $("#GastricMalignantDiv").show();
                $("#SubGastricTypeDiv").show();
                isType = true;
            } else {
                $("#GastricMalignantDiv").hide();
            }
            if (!isType) {
                $("#SubGastricTypeDiv").hide();
            }
            ShowGastricProbableText();
        }

        function ShowGastricProbableText() {
            if ($('#GastricProbablyCheckBox').is(':checked')) {
                $('#GastricBenignRadioButtonList_1').next().html('Probable leiomyoma');
                $('#GastricBenignRadioButtonList_2').next().html('Probable lipoma');
                $('#GastricBenignRadioButtonList_3').next().html('Probable granular cell tumour');
                $('#GastricMalignantRadioButtonList_1').next().html('Probable squamous carcinoma');
                $('#GastricMalignantRadioButtonList_2').next().html('Probable adenocarcinoma');
            } else {
                $('#GastricBenignRadioButtonList_1').next().html('Leiomyoma');
                $('#GastricBenignRadioButtonList_2').next().html('Lipoma');
                $('#GastricBenignRadioButtonList_3').next().html('Granular cell tumour');
                $('#GastricMalignantRadioButtonList_1').next().html('Squamous carcinoma');
                $('#GastricMalignantRadioButtonList_2').next().html('Adenocarcinoma');
            }
        }

        function ChkOtherGastricBenign() {
            if (!$('#GastricBenignRadioButtonList_4').is(':checked')) {
                $("#GastricBenignOtherTextBox").val("");
            }
        }

        function ChkOtherGastricMalignant() {
            if (!$('#GastricMalignantRadioButtonList_3').is(':checked')) {
                $("#GastricMalignantOtherTextBox").val("");
            }
        }

        /*Lymphoma functions*/
        function ShowLymphomaTypeDiv() {
            var isType = false;
            if ($('#LymphomaTypeRadioButtonList_0').is(':checked')) {
                $("#LymphomaBenignDiv").show();
                $("#SubLymphomaTypeDiv").show();
                isType = true;
            } else {
                $("#LymphomaBenignDiv").hide();
            }
            if ($('#LymphomaTypeRadioButtonList_1').is(':checked')) {
                $("#LymphomaMalignantDiv").show();
                $("#SubLymphomaTypeDiv").show();
                isType = true;
            } else {
                $("#LymphomaMalignantDiv").hide();
            }
            if (!isType) {
                $("#SubLymphomaTypeDiv").hide();
            }
            ShowLymphomaProbableText();
        }

        function ShowLymphomaProbableText() {
            if ($('#LymphomaProbablyCheckBox').is(':checked')) {
                $('#LymphomaBenignRadioButtonList_1').next().html('Probable leiomyoma');
                $('#LymphomaBenignRadioButtonList_2').next().html('Probable lipoma');
                $('#LymphomaBenignRadioButtonList_3').next().html('Probable granular cell tumour');
                $('#LymphomaMalignantRadioButtonList_1').next().html('Probable squamous carcinoma');
                $('#LymphomaMalignantRadioButtonList_2').next().html('Probable adenocarcinoma');
            } else {
                $('#LymphomaBenignRadioButtonList_1').next().html('Leiomyoma');
                $('#LymphomaBenignRadioButtonList_2').next().html('Lipoma');
                $('#LymphomaBenignRadioButtonList_3').next().html('Granular cell tumour');
                $('#LymphomaMalignantRadioButtonList_1').next().html('Squamous carcinoma');
                $('#LymphomaMalignantRadioButtonList_2').next().html('Adenocarcinoma');
            }
        }

        function ChkOtherLymphomaBenign() {
            if (!$('#LymphomaBenignRadioButtonList_4').is(':checked')) {
                $("#LymphomaBenignOtherTextBox").val("");
            }
        }

        function ChkOtherLymphomaMalignant() {
            if (!$('#LymphomaMalignantRadioButtonList_3').is(':checked')) {
                $("#LymphomaMalignantOtherTextBox").val("");
            }
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
        <telerik:RadScriptManager ID="MalignancyRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="MalignancyRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Malignancy</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgMalignancy" runat="server" style="padding-bottom:20px;">
                            <table id="MalignancyTable" class="rgview" cellpadding="0" cellspacing="0" style="width:650px;">
                                <thead>
                                    <tr>
                                        <th class="rgHeader" width="540px" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" style="margin-right:10px;"/>
                                            <asp:CheckBox ID="EarlyCarcinomaCheckBox" runat="server" Text="Early Carcinoma" style="margin-right:10px;"/>
                                            <asp:CheckBox ID="AdvCarcinomaCheckBox" runat="server" Text="Established Gastric Carcinoma" style="margin-right:10px;"/>
                                            <asp:CheckBox ID="LymphomaCheckBox" runat="server" Text="Gastric Lymphoma"/>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>

                        <telerik:RadTabStrip runat="server" ID="MalignancyTabStrip" MultiPageID="MalignancyMultiPage" SelectedIndex="1" ShowBaseLine="False">
                            <Tabs>
                                <telerik:RadTab Text="Early Carcinoma" Width="216px" PageViewID="EarlyCarcinomaTab" ></telerik:RadTab>
                                <telerik:RadTab Text="Established Gastric Carcinoma" Width="217px" PageViewID="GastricCarcinomaTab" Selected="True"></telerik:RadTab>
                                <telerik:RadTab Text="Gastric Lymphoma" Width="217px" PageViewID="LymphomaTab" Selected="True"></telerik:RadTab>
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="MalignancyMultiPage" runat="server" SelectedIndex="0" >
                            <telerik:RadPageView ID="EarlyCarcinomaPageView" runat="server" >
                                <div id="divEarlyCarcinoma" style="border:1px solid #828282;width:620px;padding:0px 15px;" runat="server">
                                    <table>
                                        <tr valign="top">
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td colspan="3">
                                                            <div style="float: left;">
                                                                <fieldset id="Fieldset1" runat="server" style="width:575px;">
                                                                    <legend>Type</legend>
                                                                    <div id="EarlyTypeDiv" style="float: left;">  
                                                                        <asp:RadioButtonList ID="EarlyTypeRadioButtonList" runat="server"
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Benign"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Malignant"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                        <br />
                                                                        &nbsp;&nbsp;<asp:CheckBox ID="EarlyProbablyCheckBox" runat="server" Checked='<%# Bind("TumourProbably")%>' Text="(probably)" />
                                                                    </div>
                                                                    <div id="SubEarlyTypeDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                        <asp:RadioButtonList ID="SubEarlyTypeRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Indeterminate"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Submucosal"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Exophytic"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                    </div>
                                                                    <div id="EarlyBenignDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                        <asp:RadioButtonList ID="EarlyBenignRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Uncertain"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Leiomyoma"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Lipoma"></asp:ListItem>
                                                                            <asp:ListItem Value="4" Text="Granular cell tumour"></asp:ListItem>
                                                                            <asp:ListItem Value="5" Text="Other"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                        <telerik:RadTextBox ID="EarlyBenignOtherTextBox" runat="server" Width="200px" Text='<%# Bind("TumourBenignTypeOther")%>' />
                                                                    </div>
                                                                    <div id="EarlyMalignantDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                        <asp:RadioButtonList ID="EarlyMalignantRadioButtonList" name="EarlyMalignantRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Uncertain"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Squamous carcinoma"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Adenocarcinoma"></asp:ListItem>
                                                                            <asp:ListItem Value="4" Text="Other"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                        <telerik:RadTextBox ID="EarlyMalignantOtherTextBox" name="EarlyMalignantOtherTextBox" runat="server" Width="200px" Text='<%# Bind("TumourBenignTypeOther")%>' />
                                                                    </div>
                                                                </fieldset>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="3">
                                                            <div style="float: left;">
                                                                <fieldset id="Fieldset2" runat="server" style="width:575px;">
                                                                    <legend>Early Carcinoma</legend>
                                                                    <table>
                                                                        <tr valign="top">
                                                                            <td class="rfdAspLabel">Lesion:</td>
                                                                            <td>
                                                                                <asp:RadioButtonList ID="EarlyCarcinomaLesionRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                                                    <asp:ListItem Value="1" Text="Small polypoidal mass"></asp:ListItem>
                                                                                    <asp:ListItem Value="2" Text="Focal discolouration +/- depression"></asp:ListItem>
                                                                                    <asp:ListItem Value="3" Text="Gastric ulcer with focal discolouration <div style='width:150px;text-align:right;'>+/- depression</div>"></asp:ListItem>
                                                                                </asp:RadioButtonList>
                                                                            </td>
                                                                            <td style="padding-left:50px;">
                                                                                <asp:RadioButtonList ID="EarlyCarcinomaBleedingRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                                                    <asp:ListItem Value="1" Text="Recent bleeding"></asp:ListItem>
                                                                                    <asp:ListItem Value="2" Text="Active bleeding"></asp:ListItem>
                                                                                </asp:RadioButtonList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr><td colspan="3" style="height:10px;" ></td></tr>
                                                                        <tr>
                                                                            <td class="rfdAspLabel">
                                                                                Start at</td>
                                                                            <td class="rfdAspLabel">
                                                                                <telerik:RadNumericTextBox ID="EarlyCarcinomaStartNumericTextBox" runat="server"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                </telerik:RadNumericTextBox>
                                                                                cm,
                                                                                &nbsp;&nbsp;end at&nbsp;&nbsp;
                                                                                <telerik:RadNumericTextBox ID="EarlyCarcinomaEndNumericTextBox" runat="server"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0" >
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                </telerik:RadNumericTextBox>
                                                                                cm ab oral.
                                                                            </td>
                                                                        </tr>
                                                                        <tr class="rfdAspLabel">
                                                                            <td>Greatest <br />diameter:</td>
                                                                            <td>
                                                                                <telerik:RadNumericTextBox ID="EarlyCarcinomaDiaNumericTextBox" runat="server"
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
                                                                  </fieldset>
                                                              </div>
                                                            </td>
                                                        </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>

                            </telerik:RadPageView>
                            <telerik:RadPageView ID="GastricCarcinomaPageView" runat="server" >
                                <div id="divGastricCarcinoma" style="border:1px solid #828282;width:620px;padding:0px 15px;" runat="server">
                                    <table>
                                        <tr valign="top">
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td colspan="3">
                                                            <div style="float: left;">
                                                                <fieldset id="Fieldset3" runat="server" style="width:575px;">
                                                                    <legend>Type</legend>
                                                                    <div id="GastricTypeDiv" style="float: left;">  
                                                                        <asp:RadioButtonList ID="GastricTypeRadioButtonList" runat="server"
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Benign"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Malignant"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                        <br />
                                                                        &nbsp;&nbsp;<asp:CheckBox ID="GastricProbablyCheckBox" runat="server" Checked='<%# Bind("TumourProbably")%>' Text="(probably)" />
                                                                    </div>
                                                                    <div id="SubGastricTypeDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                        <asp:RadioButtonList ID="SubGastricTypeRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Indeterminate"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Submucosal"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Exophytic"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                    </div>
                                                                    <div id="GastricBenignDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                        <asp:RadioButtonList ID="GastricBenignRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Uncertain"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Leiomyoma"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Lipoma"></asp:ListItem>
                                                                            <asp:ListItem Value="4" Text="Granular cell tumour"></asp:ListItem>
                                                                            <asp:ListItem Value="5" Text="Other"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                        <telerik:RadTextBox ID="GastricBenignOtherTextBox" runat="server" Width="200px" Text='<%# Bind("TumourBenignTypeOther")%>' />
                                                                    </div>
                                                                    <div id="GastricMalignantDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                        <asp:RadioButtonList ID="GastricMalignantRadioButtonList" name="GastricMalignantRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Uncertain"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Squamous carcinoma"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Adenocarcinoma"></asp:ListItem>
                                                                            <asp:ListItem Value="4" Text="Other"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                        <telerik:RadTextBox ID="GastricMalignantOtherTextBox" name="GastricMalignantOtherTextBox" runat="server" Width="200px" Text='<%# Bind("TumourBenignTypeOther")%>' />
                                                                    </div>
                                                                </fieldset>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="3">
                                                            <div style="float: left;">
                                                                <fieldset id="Fieldset4" runat="server" style="width:575px;">
                                                                    <legend>Established Gastric Carcinoma</legend>
                                                                    <table>
                                                                        <tr valign="top">
                                                                            <td class="rfdAspLabel">Lesion:</td>
                                                                            <td>
                                                                                <asp:RadioButtonList ID="AdvCarcinomaLesionRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                                                    <asp:ListItem Value="1" Text="Polypoidal"></asp:ListItem>
                                                                                    <asp:ListItem Value="2" Text="Polypoid with central ulceration"></asp:ListItem>
                                                                                    <asp:ListItem Value="3" Text="Infiltrating"></asp:ListItem>
                                                                                    <asp:ListItem Value="4" Text="Infiltrating with central ulceration"></asp:ListItem>
                                                                                    <asp:ListItem Value="5" Text="Linitis plastica (probable)"></asp:ListItem>
                                                                                </asp:RadioButtonList>
                                                                            </td>
                                                                            <td style="padding-left:50px;">
                                                                                <asp:RadioButtonList ID="AdvCarcinomaBleedingRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                                                    <asp:ListItem Value="1" Text="Recent bleeding"></asp:ListItem>
                                                                                    <asp:ListItem Value="2" Text="Active bleeding"></asp:ListItem>
                                                                                </asp:RadioButtonList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr><td colspan="3" style="height:10px;" ></td></tr>
                                                                        <tr>
                                                                            <td class="rfdAspLabel">
                                                                                Start at</td>
                                                                            <td class="rfdAspLabel">
                                                                                <telerik:RadNumericTextBox ID="AdvCarcinomaStartNumericTextBox" runat="server"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                </telerik:RadNumericTextBox>
                                                                                cm, 
                                                                                &nbsp;&nbsp;end at&nbsp;&nbsp;
                                                                                <telerik:RadNumericTextBox ID="AdvCarcinomaEndNumericTextBox" runat="server"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                </telerik:RadNumericTextBox>
                                                                                cm ab oral.
                                                                            </td>
                                                                        </tr>
                                                                        <tr class="rfdAspLabel">
                                                                            <td>Greatest <br />diameter:</td>
                                                                            <td>
                                                                                <telerik:RadNumericTextBox ID="AdvCarcinomaDiaNumericTextBox" runat="server"
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
                                                                </fieldset>
                                                             </div>
                                                         </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>

                            <telerik:RadPageView ID="LymphomaPageView" runat="server" >
                                <div id="divLymphoma" style="border:1px solid #828282;width:620px;padding:0px 15px;" runat="server">
                                    <table>
                                        <tr valign="top">
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td colspan="3">
                                                            <div style="float: left;">
                                                                <fieldset id="Fieldset5" runat="server" style="width:575px;">
                                                                    <legend>Type</legend>
                                                                    <div id="LymphomaTypeDiv" style="float: left;">  
                                                                        <asp:RadioButtonList ID="LymphomaTypeRadioButtonList" runat="server"
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Benign"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Malignant"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                        <br />
                                                                        &nbsp;&nbsp;<asp:CheckBox ID="LymphomaProbablyCheckBox" runat="server" Checked='<%# Bind("TumourProbably")%>' Text="(probably)" />
                                                                    </div>
                                                                    <div id="SubLymphomaTypeDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                        <asp:RadioButtonList ID="SubLymphomaTypeRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Indeterminate"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Submucosal"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Exophytic"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                    </div>
                                                                    <div id="LymphomaBenignDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                        <asp:RadioButtonList ID="LymphomaBenignRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Uncertain"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Leiomyoma"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Lipoma"></asp:ListItem>
                                                                            <asp:ListItem Value="4" Text="Granular cell tumour"></asp:ListItem>
                                                                            <asp:ListItem Value="5" Text="Other"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                        <telerik:RadTextBox ID="LymphomaBenignOtherTextBox" runat="server" Width="200px" Text='<%# Bind("TumourBenignTypeOther")%>' />
                                                                    </div>
                                                                    <div id="LymphomaMalignantDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                        <asp:RadioButtonList ID="LymphomaMalignantRadioButtonList" name="LymphomaMalignantRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Uncertain"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Squamous carcinoma"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Adenocarcinoma"></asp:ListItem>
                                                                            <asp:ListItem Value="4" Text="Other"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                        <telerik:RadTextBox ID="LymphomaMalignantOthertextBox" name="LymphomaMalignantOthertextBox" runat="server" Width="200px" Text='<%# Bind("TumourBenignTypeOther")%>' />
                                                                    </div>
                                                                </fieldset>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="3">
                                                            <div style="float: left;">
                                                                <fieldset id="Fieldset6" runat="server" style="width:575px;">
                                                                    <legend>Gastric Lymphoma</legend>
                                                                    <table>
                                                                        <tr valign="top">
                                                                            <td class="rfdAspLabel">Lesion:</td>
                                                                            <td>
                                                                                <asp:RadioButtonList ID="LymphomaLesionRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                                                    <asp:ListItem Value="1" Text="Single polypoidal mass"></asp:ListItem>
                                                                                    <asp:ListItem Value="2" Text="Multiple polypoid discrete masses"></asp:ListItem>
                                                                                    <asp:ListItem Value="3" Text="Diffusely infiltrating"></asp:ListItem>
                                                                                    <asp:ListItem Value="4" Text="Diffusely infiltrating with ulceration"></asp:ListItem>
                                                                                </asp:RadioButtonList>
                                                                            </td>
                                                                            <td style="padding-left:50px;">
                                                                                <asp:RadioButtonList ID="LymphomaBleedingRadioButtonList" runat="server" CellSpacing="0" CellPadding="0">
                                                                                    <asp:ListItem Value="1" Text="Recent bleeding"></asp:ListItem>
                                                                                    <asp:ListItem Value="2" Text="Active bleeding"></asp:ListItem>
                                                                                </asp:RadioButtonList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr><td colspan="3" style="height:10px;" ></td></tr>
                                                                        <tr>
                                                                            <td class="rfdAspLabel">
                                                                                Start at</td>
                                                                            <td class="rfdAspLabel">
                                                                                <telerik:RadNumericTextBox ID="LymphomaStartNumericTextBox" runat="server"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                </telerik:RadNumericTextBox>
                                                                                cm, 
                                                                                &nbsp;&nbsp;end at&nbsp;&nbsp;
                                                                                <telerik:RadNumericTextBox ID="LymphomaEndNumericTextBox" runat="server"
                                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                                    IncrementSettings-Step="1"
                                                                                    Width="35px"
                                                                                    MinValue="0">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                </telerik:RadNumericTextBox>
                                                                                cm ab oral.
                                                                            </td>
                                                                        </tr>
                                                                        <tr class="rfdAspLabel">
                                                                            <td>Greatest <br />diameter:</td>
                                                                            <td>
                                                                                <telerik:RadNumericTextBox ID="LymphomaDiaNumericTextBox" runat="server"
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
                                                                </fieldset>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>                                   
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
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
