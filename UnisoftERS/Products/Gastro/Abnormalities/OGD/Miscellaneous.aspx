<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_OGD_Miscellaneous" CodeBehind="Miscellaneous.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript">

        var miscellaneousValueChanged = false;

        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {  
                ToggleTRs($(this));
                ShowBeningnDiv();
                ShowTumorTypeDiv();
                ShowInletPatchDiv();
                ShowZLineDiv();
                QtyChanged('Diverticulum');
                MultipleChecked('Diverticulum');
                QtyChanged('InletPouch');
            });
        });

        $(document).ready(function () {          
            $("#OgdMiscellaneousFormView_MiscellaneousTable tr td:first-child input:checkbox, input[type=text]").change(function () {
                ToggleTRs($(this));
                miscellaneousValueChanged = true;
            });

            $("#OgdMiscellaneousFormView_NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                miscellaneousValueChanged = true;
            });

            $('#OgdMiscellaneousFormView_StrictureTypeRadioButtonList').on('change', function () {
                ShowBeningnDiv();
                miscellaneousValueChanged = true;
            });

            $("#OgdMiscellaneousFormView_TumourCheckBox").change(function () {
                ShowTumorTypeDiv();
                miscellaneousValueChanged = true;
            });

            $("#OgdMiscellaneousFormView_ZLineCheckBox").change(function () {
                ShowZLineDiv();
                miscellaneousValueChanged = true;
            });

            $("#OgdMiscellaneousFormView_InletPatchCheckBox").change(function () {
                ShowInletPatchDiv();
                miscellaneousValueChanged = true;
            });

            $('#OgdMiscellaneousFormView_TumourTypeRadioButtonList').on('change', function () {
                ShowTumorTypeDiv();
                ClearControls($("#OgdMiscellaneousFormView_SubTumourTypeDiv"));
                ClearControls($("#OgdMiscellaneousFormView_MalignantDiv"));
                ClearControls($("#OgdMiscellaneousFormView_BenignDiv"));
                miscellaneousValueChanged = true;
            });

            $("#OgdMiscellaneousFormView_TumourProbablyCheckBox").change(function () {
                ShowProbableText();
                miscellaneousValueChanged = true;
            });
            $('#OgdMiscellaneousFormView_TumourBenignTypeRadioButtonList').on('change', function () {
                ChkOtherBenign();
                miscellaneousValueChanged = true;
            });
            $('#OgdMiscellaneousFormView_TumourMalignantTypeRadioButtonList').on('change', function () {
                ChkOtherMalignant();
                miscellaneousValueChanged = true;
            });

             //for this page issue 4166  by Mostafiz
             $(window).on('beforeunload', function () {
                 if (miscellaneousValueChanged) {
                     localStorage.setItem('valueChanged', $("#OgdMiscellaneousFormView_MiscellaneousTable input:checkbox:checked").length > 0 ? 'true' : 'false');
                     $("#SaveButton").click();
                 }
             });

             $(window).on('unload', function () {
                 localStorage.clear();
                 setRehideSummary();
             });
        });
        
        function CloseWindow() {
            window.parent.CloseWindow();
        }
         //changed by mostafiz issue 3647 
        function ToggleTRs(chkbox) {
            if (chkbox[0].id != "OgdMiscellaneousFormView_NoneCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#OgdMiscellaneousFormView_NoneCheckBox").prop('checked', false);
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
                        if (checked) {
                            $(this).show();
                        }
                        else {
                            $(this).hide();
                            ClearControls($(this));
                        }
                    });
                }
            }
        }

        function ToggleNoneCheckBox(checked) {
            if (checked) {
                $("#OgdMiscellaneousFormView_MiscellaneousTable tr td:first-child").each(function () {
                    $(this).find("input:checkbox:checked").prop('checked', false);
                    $(this).find("input:checkbox").trigger('change');
                });
                ShowBeningnDiv();
                ShowTumorTypeDiv();
            }
        }

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").prop('checked', false);
            tableCell.find("input:checkbox:checked").prop('checked', false);
            tableCell.find("input:text").val("");
        }

        function ShowBeningnDiv() {
            if ($('#OgdMiscellaneousFormView_StrictureTypeRadioButtonList_0').is(':checked')) {
                $("#OgdMiscellaneousFormView_StrictureTypeDiv").show();
            } else {
                $("#OgdMiscellaneousFormView_StrictureTypeDiv").hide();
                $("#OgdMiscellaneousFormView_StrictureTypeDiv").find('input[type=radio]').removeAttr('checked');
            }
        }

        function ShowTumorTypeDiv() {
            var isType = false;
            if ($('#OgdMiscellaneousFormView_TumourTypeRadioButtonList_0').is(':checked')) {
                $("#OgdMiscellaneousFormView_BenignDiv").show();
                $("#OgdMiscellaneousFormView_SubTumourTypeDiv").show();
                isType = true;
            } else {
                $("#OgdMiscellaneousFormView_BenignDiv").hide();
            }
            if ($('#OgdMiscellaneousFormView_TumourTypeRadioButtonList_1').is(':checked')) {
                $("#OgdMiscellaneousFormView_MalignantDiv").show();
                $("#OgdMiscellaneousFormView_SubTumourTypeDiv").show();
                isType = true;
            } else {
                $("#OgdMiscellaneousFormView_MalignantDiv").hide();
            }
            if (!isType) {
                $("#OgdMiscellaneousFormView_SubTumourTypeDiv").hide();
            }
            ShowProbableText();
        }

        function ShowInletPatchDiv() {
            if ($('#OgdMiscellaneousFormView_InletPatchCheckBox').is(':checked')) {
                $('#InletPatchDiv').show();
            }
            else {
                $('#InletPatchDiv').hide();
            }
        }

        function ShowZLineDiv() {
            if ($('#OgdMiscellaneousFormView_ZLinePatchCheckBox').is(':checked')) {
                $('#ZLineDiv').show();
            }
            else {
                $('#ZLinePatchDiv').hide();
            }
        }

        function ShowProbableText() {
            if ($('#OgdMiscellaneousFormView_TumourProbablyCheckBox').is(':checked')) {
                $('#OgdMiscellaneousFormView_TumourBenignTypeRadioButtonList_1').next().html('Probable leiomyoma');
                $('#OgdMiscellaneousFormView_TumourBenignTypeRadioButtonList_2').next().html('Probable lipoma');
                $('#OgdMiscellaneousFormView_TumourBenignTypeRadioButtonList_3').next().html('Probable granular cell tumour');
                $('#OgdMiscellaneousFormView_TumourMalignantTypeRadioButtonList_1').next().html('Probable squamous carcinoma');
                $('#OgdMiscellaneousFormView_TumourMalignantTypeRadioButtonList_2').next().html('Probable adenocarcinoma');
            } else {
                $('#OgdMiscellaneousFormView_TumourBenignTypeRadioButtonList_1').next().html('Leiomyoma');
                $('#OgdMiscellaneousFormView_TumourBenignTypeRadioButtonList_2').next().html('Lipoma');
                $('#OgdMiscellaneousFormView_TumourBenignTypeRadioButtonList_3').next().html('Granular cell tumour');
                $('#OgdMiscellaneousFormView_TumourMalignantTypeRadioButtonList_1').next().html('Squamous carcinoma');
                $('#OgdMiscellaneousFormView_TumourMalignantTypeRadioButtonList_2').next().html('Adenocarcinoma');
            }


        }

        function ChkOtherBenign() {
            if (!$('#OgdMiscellaneousFormView_TumourBenignTypeRadioButtonList_4').is(':checked')) {
                $("#OgdMiscellaneousFormView_TumourBenignTypeOtherTextBox").val("");
            }
        }

        function ChkOtherMalignant() {
            if (!$('#OgdMiscellaneousFormView_TumourMalignantTypeRadioButtonList_3').is(':checked')) {
                $("#OgdMiscellaneousFormView_TumourMalignantTypeOtherTextBox").val("");
            }
        }


        function QtyChanged(diag) {
          
            if ($find("OgdMiscellaneousFormView_DivertQtyNumericTextBox") != null && diag == 'Diverticulum') {
                if ($find("OgdMiscellaneousFormView_DivertQtyNumericTextBox").get_value() != "") {
                  // $("#OgdMiscellaneousFormView_DivertMultipleCheckBox").removeAttr("checked");
                    $("#OgdMiscellaneousFormView_DivertMultipleCheckBox").prop("checked", false); // issue 4208
                }
            }
            else if ($find("OgdMiscellaneousFormView_InletPatchQtyNumericTextBox") != null && diag == 'InletPatch') {
                if ($find("OgdMiscellaneousFormView_InletPatchQtyNumericTextBox").get_value() != "") {
                   // $("#OgdMiscellaneousFormView_InletPatchMultipleCheckBox").removeAttr("checked");
                    $("#OgdMiscellaneousFormView_InletPatchMultipleCheckBox").prop("checked", false); // issue 4208
                }
            }
           
        }

        function MultipleChecked(diag) {
           
            if ($("#OgdMiscellaneousFormView_DivertMultipleCheckBox") != null && diag == 'Diverticulum') {
                if ($("#OgdMiscellaneousFormView_DivertMultipleCheckBox").is(':checked')) {
                    $find("OgdMiscellaneousFormView_DivertQtyNumericTextBox").set_value("");
                }
            }

            else if ($("#OgdMiscellaneousFormView_InletPatchMultipleCheckBox") != null && diag == 'InletPatch') {
                if ($("#OgdMiscellaneousFormView_InletPatchMultipleCheckBox").is(':checked')) {
                    $find("OgdMiscellaneousFormView_InletPatchQtyNumericTextBox").set_value("");
                }
            }
        }        

    </script>

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
            margin-right: 20px;
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
        <telerik:RadScriptManager ID="OGDMiscellaneousRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>

        <div class="abnorHeader">Miscellaneous</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">

                <asp:ObjectDataSource ID="OgdMiscellaneousObjectDataSource" runat="server"
                    TypeName="UnisoftERS.Abnormalities" SelectMethod="GetOgdMiscellaneousData" UpdateMethod="SaveOgdMiscellaneousData" InsertMethod="SaveOgdMiscellaneousData">
                    <SelectParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="None" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Web" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Mallory" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="SchatzkiRing" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="FoodResidue" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Foreignbody" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ExtrinsicCompression" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Diverticulum" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="DivertMultiple" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="DivertQty" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Pharyngeal" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="DiffuseIntramural" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="TractionType" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="PulsionType" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="MotilityDisorder" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ProbableAchalasia" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ConfirmedAchalasia" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Presbyoesophagus" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="MarkedTertiaryContractions" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="LaxLowerOesoSphincter" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="TortuousOesophagus" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="DilatedOesophagus" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="MotilityPoor" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Stricture" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StrictureCompression" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureScopeNotPass" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StrictureSeverity" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureProbably" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StrictureBenignType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureBeginning" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureLength" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StricturePerforation" DbType="Int32" ConvertEmptyStringToNull="true" />
                        <asp:Parameter Name="Tumour" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="TumourType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourProbably" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="TumourExophytic" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourBenignType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourBenignTypeOther" DbType="String" />
                        <asp:Parameter Name="TumourBeginning" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourLength" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourScopeNotPass" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="MiscOther" DbType="String" />
                        <asp:Parameter Name="InletPatch" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="InletPatchMultiple" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="InletPatchQty" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Fitsula" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="InletPouch" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="InletPouchQty" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="ZLine" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ZLineSize" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Volvulus" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="AmpullaryAdenoma" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StentOcclusion" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StentInSitu" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="PEGInSitu" DbType="Boolean" DefaultValue="false" />
                    </UpdateParameters>
                    <InsertParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="None" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Web" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Mallory" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="SchatzkiRing" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="FoodResidue" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Foreignbody" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ExtrinsicCompression" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Diverticulum" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="DivertMultiple" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="DivertQty" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Pharyngeal" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="DiffuseIntramural" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="TractionType" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="PulsionType" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="MotilityDisorder" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ProbableAchalasia" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ConfirmedAchalasia" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="Presbyoesophagus" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="MarkedTertiaryContractions" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="LaxLowerOesoSphincter" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="TortuousOesophagus" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="DilatedOesophagus" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="MotilityPoor" DbType="Boolean" DefaultValue="false" /> 
                        <asp:Parameter Name="Stricture" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StrictureCompression" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureScopeNotPass" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StrictureSeverity" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureProbably" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StrictureBenignType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureBeginning" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StrictureLength" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StricturePerforation" DbType="Int32" ConvertEmptyStringToNull="true" />
                        <asp:Parameter Name="Tumour" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="TumourType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourProbably" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="TumourExophytic" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourBenignType" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourBenignTypeOther" DbType="String" />
                        <asp:Parameter Name="TumourBeginning" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourLength" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourScopeNotPass" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="MiscOther" DbType="String" />
                        <asp:Parameter Name="InletPatch" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="InletPatchMultiple" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="InletPatchQty" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Fitsula" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="InletPouch" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="InletPouchQty" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="ZLine" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="ZLineSize" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="Volvulus" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="AmpullaryAdenoma" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StentOcclusion" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="StentInSitu" DbType="Boolean" DefaultValue="false" />
                        <asp:Parameter Name="PEGInSitu" DbType="Boolean" DefaultValue="false" />
                    </InsertParameters>
                </asp:ObjectDataSource>


                <asp:FormView ID="OgdMiscellaneousFormView" runat="server" DefaultMode="Edit"
                    DataSourceID="OgdMiscellaneousObjectDataSource" DataKeyNames="SiteId" OnPreRender="OgdMiscellaneousFormView_PreRender">
                    <EditItemTemplate>

                        <div id="ContentDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="MiscellaneousTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 780px;">
                                        <%-- <table id="therapeuticTable" class="rgview" cellpadding="0" cellspacing="0">--%>
                                        <colgroup>
                                            <col>
                                            <col>
                                            <col>
                                        </colgroup>
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="2">
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" Checked='<%# Bind("None")%>' />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <!-- A's -->
                                            <tr id="AmpullaryAdenomaTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="AmpullaryAdenomaCheckBox" runat="server" Checked='<%# Bind("AmpullaryAdenoma")%>' Text="Ampullary Adenoma" />
                                                            </td>
                                                            <td style="border: none;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- D's -->
                                            <tr id="DiverticulumTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="DiverticulumCheckBox" runat="server" Checked='<%# Bind("Diverticulum")%>' Text="Diverticulum" />
                                                            </td>
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="DivertMultipleCheckBox" runat="server" Checked='<%# Bind("DivertMultiple")%>' Text="Multiple &nbsp; <i>OR</i> &nbsp; qty" Style="margin-right: 10px;" onchange="MultipleChecked('Diverticulum');" />
                                                                <telerik:RadNumericTextBox ID="DivertQtyNumericTextBox" runat="server" DbValue='<%# Bind("DivertQty")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0"
                                                                    onchange="QtyChanged('Diverticulum');">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox><br />
                                                                <asp:CheckBox ID="CheckBox13" runat="server" Checked='<%# Bind("PulsionType")%>' Text="Pulsion type" Style="margin-right: 10px;" />
                                                                <asp:CheckBox ID="CheckBox14" runat="server" Checked='<%# Bind("TractionType")%>' Text="Traction type" Style="margin-right: 10px;" />
                                                                <asp:CheckBox ID="CheckBox15" runat="server" Checked='<%# Bind("DiffuseIntramural")%>' Text="Diffuse intramural" Style="margin-right: 10px;" />
                                                                <asp:CheckBox ID="CheckBox16" runat="server" Checked='<%# Bind("Pharyngeal")%>' Text="Pharyngeal (Zenker's)" Style="margin-right: 10px;" />
                                                            </td>
                                                            <td style="border: none; vertical-align: top; padding-left: 30px;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- F's -->
                                            <tr id="FitsulaTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="FitsulaCheckBox" runat="server" Checked='<%# Bind("Fitsula")%>' Text="Fistula" />
                                                            </td>
                                                            <td style="border: none;"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="FoodResidueTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="CheckBox4" runat="server" Checked='<%# Bind("FoodResidue")%>' Text="Food residue" Style="margin-right: 10px;" />

                                                            </td>
                                                        </tr>
                                                    </table>

                                                </td>
                                            </tr>
                                            <tr id="ForeignbodyTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">

                                                                <asp:CheckBox ID="CheckBox29" runat="server" Checked='<%# Bind("Foreignbody")%>' Text="Foreign body" Style="margin-right: 10px;" /><br />

                                                            </td>
                                                        </tr>
                                                    </table>

                                                </td>
                                            </tr>
                                            <tr id="InletPatchTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="InletPatchCheckBox" runat="server" Checked='<%# Bind("InletPatch")%>' Text="Inlet patch" Style="margin-right: 10px;" />



                                                            </td>
                                                            <td style="border: none; vertical-align: top;">
                                                                <div id="InletPatchDiv" style="float: left">
                                                                    <asp:CheckBox ID="InletPatchMultipleCheckBox" runat="server" Checked='<%# Bind("InletPatchMultiple")%>' Text="Multiple &nbsp; size" Style="margin-right: 10px;" />
                                                                    <telerik:RadNumericTextBox ID="InletPatchQtyNumericTextBox" runat="server" DbValue='<%# Bind("InletPatchQty")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0"
                                                                        onchange="QtyChanged('InletPatch');">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    &nbsp; mm
                                                                </div>
                                                            </td>
                                                            <td style="border: none; vertical-align: top; padding-left: 30px;"></td>

                                                        </tr>
                                                    </table>

                                                </td>
                                            </tr>
                                            <!-- I's -->
                                            <tr id="InletPouchTR">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="CheckBox5" runat="server" Checked='<%# Bind("InletPouch")%>' Text="Pharyngeal pouch" Style="margin-right: 10px;" />
                                                            </td>
                                                            <td style="border: none; vertical-align: top;">
                                                                 &nbsp;size
                                                                <telerik:RadNumericTextBox ID="InletPouchQtyNumericTextBox" runat="server" DbValue='<%# Bind("InletPouchQty")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0"
                                                                    onchange="QtyChanged('InletPouch');">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>mm

                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- M's -->
                                            <tr id="MalloryTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="CheckBox2" runat="server" Checked='<%# Bind("Mallory")%>' Text="Mallory - Weiss tear" Style="margin-right: 10px;" />

                                                            </td>
                                                        </tr>
                                                    </table>

                                                </td>
                                            </tr>
                                            <tr id="MotilityDisorderTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="CheckBox7" runat="server" Checked='<%# Bind("MotilityDisorder")%>' Text="Motility disorder" />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1">
                                                            <td style="border: none; vertical-align: top; width: 100%; padding: 0px 0px 10px 50px;">
                                                                <div style="float: left;">
                                                                    <asp:CheckBox ID="CheckBox9" runat="server" Checked='<%# Bind("ProbableAchalasia")%>' Text="Probable achalasia" Style="margin-right: 10px;" /><br />
                                                                    <asp:CheckBox ID="CheckBox10" runat="server" Checked='<%# Bind("ConfirmedAchalasia")%>' Text="Confirmed achalasia" Style="margin-right: 10px;" /><br />
                                                                    <asp:CheckBox ID="CheckBox11" runat="server" Checked='<%# Bind("Presbyoesophagus")%>' Text="Presbyoesophagus" Style="margin-right: 10px;" />
                                                                </div>
                                                                <div style="float: left; padding-left: 15px;">
                                                                    <asp:CheckBox ID="CheckBox8" runat="server" Checked='<%# Bind("MarkedTertiaryContractions")%>' Text="Marked tertiary contractions" Style="margin-right: 10px;" /><br />
                                                                    <asp:CheckBox ID="CheckBox17" runat="server" Checked='<%# Bind("LaxLowerOesoSphincter")%>' Text="Lax lower oesophageal sphincter" Style="margin-right: 10px;" /><br />
                                                                    <asp:CheckBox ID="CheckBox18" runat="server" Checked='<%# Bind("TortuousOesophagus")%>' Text="Tortuous oesophagus" Style="margin-right: 10px;" />
                                                                </div>
                                                                <div style="float: left; padding-left: 15px;">
                                                                    <asp:CheckBox ID="CheckBox20" runat="server" Checked='<%# Bind("DilatedOesophagus")%>' Text="Dilated oesophagus" Style="margin-right: 10px;" /><br />
                                                                    <asp:CheckBox ID="CheckBox21" runat="server" Checked='<%# Bind("MotilityPoor")%>' Text="Poor motility" Style="margin-right: 10px;" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- P's -->
                                            <tr id="PEGInSituTR" runat="server" >   <%--  Removed by ferdowsi, TFS 4396--%>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                 <asp:CheckBox ID="PEGInSituCheckBox" runat="server" Checked='<%# Bind("PEGInSitu")%>' Text="PEG in situ" Style="margin-right: 10px;" />

                                                            </td>
                                                        </tr>
                                                    </table>

                                                </td>
                                            </tr>
                                            <!-- S's -->
                                            <tr id="SchatzkiRingTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                 <asp:CheckBox ID="CheckBox24" runat="server" Checked='<%# Bind("SchatzkiRing")%>' Text="Schatzki ring" Style="margin-right: 10px;" />

                                                            </td>
                                                        </tr>
                                                    </table>

                                                </td>
                                            </tr>
                                            <tr id="StentInSituTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                 <asp:CheckBox ID="StentInSituCheckBox" runat="server" Checked='<%# Bind("StentInSitu")%>' Text="Stent in situ" Style="margin-right: 10px;" />

                                                            </td>
                                                        </tr>
                                                    </table>

                                                </td>
                                            </tr>
                                            <tr id="StentOcclusionTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                 <asp:CheckBox ID="StentOcclusionCheckBox" runat="server" Checked='<%# Bind("StentOcclusion")%>' Text="Stent occlusion" Style="margin-right: 10px;" />

                                                            </td>
                                                        </tr>
                                                    </table>

                                                </td>
                                            </tr>
                                            <tr id="StrictureTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none; vertical-align: top; width: 15%;">
                                                                <asp:CheckBox ID="StrictureCheckBox" runat="server" Checked='<%# Bind("Stricture")%>' Text="Stricture" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <asp:RadioButtonList ID="StrictureCompressionRadioButtonList" runat="server"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                    <asp:ListItem Value="1" Text="luminal narrowing"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="extrinsic compression"></asp:ListItem>
                                                                    <asp:ListItem Value="3" Text="unknown"></asp:ListItem>
                                                                </asp:RadioButtonList>

                                                                <asp:CheckBox ID="CheckBox28" runat="server" Checked='<%# Bind("StrictureScopeNotPass")%>' Text="'scope could not pass" />


                                                                <div style="float: left; margin-left: -90px;">
                                                                    <fieldset id="Fieldset1" runat="server" style="margin-left: 10px; height: 105px;">
                                                                        <legend>Severity</legend>
                                                                        <asp:RadioButtonList ID="StrictureSeverityRadioButtonList" runat="server"
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Slight"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Moderate"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Tight"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                    </fieldset>
                                                                </div>
                                                                <div style="float: left; padding-left: 5px;">
                                                                    <fieldset id="Fieldset2" runat="server" style="height: 105px;">
                                                                        <legend>Cause</legend>
                                                                        <div style="float: left;">
                                                                            <asp:RadioButtonList ID="StrictureTypeRadioButtonList" runat="server"
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                                <asp:ListItem Value="1" Text="Benign"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Malignant"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                            <br />
                                                                            &nbsp;&nbsp;<asp:CheckBox ID="CheckBox27" runat="server" Checked='<%# Bind("StrictureProbably")%>' Text="(probably)" />
                                                                        </div>
                                                                        <div id="StrictureTypeDiv" runat="server" style="float: left; padding-left: 5px;">
                                                                            <asp:RadioButtonList ID="StrictureBenignTypeRadioButtonList" runat="server"
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                                <asp:ListItem Value="1" Text="Inflammatory"></asp:ListItem>
                                                                                <asp:ListItem Value="4" Text="Post radiotherapy"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Post surgery"></asp:ListItem>
                                                                                <asp:ListItem Value="3" Text="Peptic"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                        </div>
                                                                    </fieldset>
                                                                </div>
                                                                <div style="float: left; padding-left: 5px;">
                                                                    <fieldset id="Fieldset3" runat="server" style="margin-left: 5px; height: 105px; width: 190px;">
                                                                        <legend>Extent</legend>
                                                                        <div style="float: left;">
                                                                            Beginning
                                                                            <telerik:RadNumericTextBox ID="StrictureBeginningNumericTextBox" runat="server" DbValue='<%# Bind("StrictureBeginning")%>'
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                        </div>
                                                                        <div style="float: left; vertical-align: top;">
                                                                            cm,
                                                                            <br />
                                                                            from incisors. 
                                                                        </div>
                                                                        <div style="margin-top: 45px;">
                                                                            Length
                                                                           
                                                                            <telerik:RadNumericTextBox ID="StrictureLengthNumericTextBox" runat="server" DbValue='<%# Bind("StrictureLength")%>'
                                                                                Style="margin-left: 17px;"
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                            cm 
                                                                        </div>
                                                                    </fieldset>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <%--<tr childRow="1" >
                                                            <td colspan="4" style="border:none;padding-left:278px;">
                                                                
                                                            </td>
                                                        </tr>--%>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- T's -->
                                            <%--<tr id="TumourTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none;" colspan="2">
                                                                <asp:CheckBox ID="TumourCheckBox" runat="server" Checked='<%# Bind("Tumour")%>' Text="Tumour" />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1" style="height: 23px;">
                                                            <td style="border: none;">
                                                                <div style="margin-top: -34px; margin-right: 10px; text-align: right;">
                                                                    <asp:CheckBox ID="TumourScopeCouldNotPassCheckBox" runat="server" Checked='<%# Bind("TumourScopeNotPass")%>' Text="'scope could not pass" />
                                                                </div>
                                                                <div style="float: left; padding-left: 5px;">
                                                                    <fieldset id="Fieldset5" runat="server" style="width: 550px;">
                                                                        <legend>Type</legend>
                                                                        <div style="float: left;">
                                                                            <asp:RadioButtonList ID="TumourTypeRadioButtonList" runat="server"
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                                <asp:ListItem Value="1" Text="Benign"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Malignant"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                            <br />
                                                                            &nbsp;&nbsp;<asp:CheckBox ID="TumourProbablyCheckBox" runat="server" Checked='<%# Bind("TumourProbably")%>' Text="(probably)" />
                                                                        </div>
                                                                        <div id="SubTumourTypeDiv" runat="server" style="float: left; padding-left: 25px;">
                                                                            <asp:RadioButtonList ID="TumourExophyticRadioButtonList" runat="server"
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                                <asp:ListItem Value="1" Text="Indeterminate"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Submucosal"></asp:ListItem>
                                                                                <asp:ListItem Value="3" Text="Exophytic"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                        </div>
                                                                        <div id="MalignantDiv" runat="server" style="float: left; padding-left: 25px;">
                                                                            <asp:RadioButtonList ID="TumourMalignantTypeRadioButtonList" name="TumourMalignantTypeRadioButtonList" runat="server"
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                                <asp:ListItem Value="1" Text="Uncertain"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Squamous carcinoma"></asp:ListItem>
                                                                                <asp:ListItem Value="3" Text="Adenocarcinoma"></asp:ListItem>
                                                                                <asp:ListItem Value="4" Text="Other"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                            <telerik:RadTextBox ID="TumourMalignantTypeOtherTextBox" name="TumourMalignantTypeOtherTextBox" runat="server" Width="200px" Text='<%# Bind("TumourBenignTypeOther")%>' />
                                                                        </div>
                                                                        <div id="BenignDiv" runat="server" style="float: left; padding-left: 25px;">
                                                                            <asp:RadioButtonList ID="TumourBenignTypeRadioButtonList" runat="server"
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                                <asp:ListItem Value="1" Text="Uncertain"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Leiomyoma"></asp:ListItem>
                                                                                <asp:ListItem Value="3" Text="Lipoma"></asp:ListItem>
                                                                                <asp:ListItem Value="4" Text="Granular cell tumour"></asp:ListItem>
                                                                                <asp:ListItem Value="5" Text="Other"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                            <telerik:RadTextBox ID="TumourBenignTypeOtherTextBox" runat="server" Width="200px" Text='<%# Bind("TumourBenignTypeOther")%>' />
                                                                        </div>
                                                                    </fieldset>
                                                                </div>
                                                                <div style="float: left; padding-left: 5px;">
                                                                    <fieldset id="Fieldset6" runat="server" style="width: 550px;">
                                                                        <legend>Extent</legend>
                                                                        <div style="float: left;">
                                                                            Beginning
                                                                            <telerik:RadNumericTextBox ID="TumourBeginningNumericTextBox" runat="server" DbValue='<%# Bind("TumourBeginning")%>'
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                            cm, from incisors. 
                                                                        </div>

                                                                        <div style="float: left; margin-left: 45px;">
                                                                            Length
                                                                            <telerik:RadNumericTextBox ID="TumourLengthNumericTextBox" runat="server" DbValue='<%# Bind("TumourLength")%>'
                                                                                Style="margin-left: 17px;"
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                            cm 
                                                                        </div>
                                                                    </fieldset>
                                                                </div>
                                                            </td>


                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>--%>
                                            <!-- U's -->
                                            <%--<tr id="UlcerationTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="border: none;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="CheckBox12" runat="server" Checked='<%# Bind("Ulceration")%>' Text="Ulceration" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <div style="float: left; padding-left: 15px;">
                                                                    <asp:CheckBox ID="UlcerationMultipleCheckBox" runat="server" Checked='<%# Bind("UlcerationMultiple")%>' Text="Multiple &nbsp; <i>OR</i> &nbsp; qty" Style="margin-right: 10px;" onchange="MultipleChecked('Ulceration');" />
                                                                    <telerik:RadNumericTextBox ID="UlcerationQtyNumericTextBox" runat="server" DbValue='<%# Bind("UlcerationQty")%>'
                                                                        ShowSpinButtons="true"
                                                                        IncrementSettings-InterceptMouseWheel="true"
                                                                        IncrementSettings-Step="1"
                                                                        Width="50px"
                                                                        MinValue="0"
                                                                        onchange="QtyChanged('Ulceration');">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    Length
                                                                    <telerik:RadNumericTextBox ID="UlcerationLengthNumericTextBox" runat="server" DbValue='<%# Bind("UlcerationLength")%>'
                                                                        ShowSpinButtons="true"
                                                                        IncrementSettings-InterceptMouseWheel="true"
                                                                        IncrementSettings-Step="1"
                                                                        Width="50px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    mm
                                                                    <span style="margin-left: 20px;"></span>
                                                                    <asp:CheckBox ID="CheckBox19" runat="server" Checked='<%# Bind("UlcerationClotInBase")%>' Text="Clot in base" />

                                                                    <div>
                                                                        <asp:CheckBox ID="CheckBox23" runat="server" Checked='<%# Bind("UlcerationReflux")%>' Text="Reflux (grade 4)" />
                                                                        <span style="margin-left: 20px;"></span>
                                                                        <asp:CheckBox ID="CheckBox25" runat="server" Checked='<%# Bind("UlcerationPostSclero")%>' Text="Post sclerotherapy" />
                                                                        <span style="margin-left: 73px;"></span>
                                                                        <asp:CheckBox ID="CheckBox22" runat="server" Checked='<%# Bind("UlcerationPostBanding")%>' Text="Post banding" />
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>--%>
                                            <!-- V's -->
                                            <tr id="VolvulusTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="VolvulusCheckBox" runat="server" Checked='<%# Bind("Volvulus")%>' Text="Volvulus" Style="margin-right: 10px;" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- W's -->
                                            <tr id="WebTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="CheckBox1" runat="server" Checked='<%# Bind("Web")%>' Text="Web" Style="margin-right: 10px;" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- Z's -->
                                            <tr id="ZLineTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="CheckBox6" runat="server" Checked='<%# Bind("ZLine")%>' Text="Z-Line" Style="margin-right: 10px;" />
                                                            </td>
                                                            <td style="border: none; vertical-align: top;">
                                                                 &nbsp;Distance
                                                                <telerik:RadNumericTextBox ID="RadNumericTextBox1" runat="server" DbValue='<%# Bind("ZLineSize")%>'
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>cm

                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <!-- Other -->
                                            <tr id="MiscOtherTR" runat="server">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="MiscOtherCheckBox" runat="server" Text="Other" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <telerik:RadTextBox ID="MiscOtherTextBox" runat="server" Width="500px" Text='<%# Bind("MiscOther")%>' />
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
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <%--added by rony tfs-3833 remove SaveMisc method --%>
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />                    
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
            
        </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>
