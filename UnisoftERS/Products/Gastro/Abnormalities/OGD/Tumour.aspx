<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_OGD_Tumour" Codebehind="Tumour.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript">

        var tumourValueChanged = false;

        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
                //ShowBeningnDiv();
                ShowTumorTypeDiv();
                //ShowInletPatchDiv();
                //QtyChanged('Diverticulum');
                //MultipleChecked('Diverticulum');
                //QtyChanged('Ulceration');
                //MultipleChecked('Ulceration');
                //QtyChanged('InletPatch');
                //MultipleChecked('InletPatch');
            });
        });

        $(document).ready(function () {
            $("#OgdTumourFormView_TumourTable tr td:first-child input:checkbox, input[type=radio], input[type=text]").change(function () {
                ToggleTRs($(this));
                tumourValueChanged = true;
            });

            $("#OgdTumourFormView_NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                tumourValueChanged = true;
            });

            $('#OgdTumourFormView_StrictureTypeRadioButtonList').on('change', function () {
                ShowBeningnDiv();
                tumourValueChanged = true;
            });

            $("#OgdTumourFormView_TumourCheckBox").change(function () {
                ShowTumorTypeDiv();
                tumourValueChanged = true;
            });

            $("#OgdTumourFormView_InletPatchCheckBox").change(function () {
                ShowInletPatchDiv();
                tumourValueChanged = true;
            });

            $('#OgdTumourFormView_TumourTypeRadioButtonList').on('change', function () {
                ShowTumorTypeDiv();
                ClearControls($("#OgdTumourFormView_SubTumourTypeDiv"));
                ClearControls($("#OgdTumourFormView_MalignantDiv"));
                ClearControls($("#OgdTumourFormView_BenignDiv"));
                tumourValueChanged = true;
            });

            $("#OgdTumourFormView_TumourProbablyCheckBox").change(function () {
                ShowProbableText();
                tumourValueChanged = true;
            });
            $('#OgdTumourFormView_TumourBenignTypeRadioButtonList').on('change', function () {
                ChkOtherBenign();
                tumourValueChanged = true;
            });
            $('#OgdTumourFormView_TumourMalignantTypeRadioButtonList').on('change', function () {
                ChkOtherMalignant();
                tumourValueChanged = true;
            });

            $(window).on('beforeunload', function () {
                if (tumourValueChanged) {
                    localStorage.setItem('valueChanged',$("#OgdTumourFormView_TumourTable input:checkbox:checked").length > 0 ? 'true' : 'false');
                    $("#SaveButton").click();
                }
            });
            $(window).on('unload', function () {
                localStorage.clear();
            });
        });

        function CloseWindow() {
            window.parent.CloseWindow();
        }
        function OnSaveChange() {
            tumourValueChanged = true;
        }

        function ToggleTRs(chkbox) {
            if (chkbox[0].id != "OgdTumourFormView_NoneCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#OgdTumourFormView_NoneCheckBox").prop('checked', false);
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
                $("#OgdTumourFormView_TumourTable tr td:first-child").each(function () {
                    $(this).find("input:checkbox:checked").prop('checked', false);
                    $(this).find("input:checkbox").trigger("change");
                });
                //ShowBeningnDiv();
                ShowTumorTypeDiv();
            }
        }

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").prop('checked', false);
            tableCell.find("input:checkbox:checked").prop('checked', false);
            tableCell.find("input:text").val("");
        }

        //function ShowBeningnDiv() {
        //    if ($('#OgdTumourFormView_StrictureTypeRadioButtonList_0').is(':checked')) {
        //        $("#OgdTumourFormView_StrictureTypeDiv").show();
        //    } else {
        //        $("#OgdTumourFormView_StrictureTypeDiv").hide();
        //        $("#OgdTumourFormView_StrictureTypeDiv").find('input[type=radio]').removeAttr('checked');
        //    }
        //}

        function ShowTumorTypeDiv() {
            var isType = false;
            
            if ($('#OgdTumourFormView_TumourTypeRadioButtonList_0').is(':checked')) {
                $("#OgdTumourFormView_BenignDiv").show();
                $("#OgdTumourFormView_SubTumourTypeDiv").show();
                isType = true;
            } else {
                $("#OgdTumourFormView_BenignDiv").hide();
            }
            if ($('#OgdTumourFormView_TumourTypeRadioButtonList_1').is(':checked')) {
                $("#OgdTumourFormView_MalignantDiv").show();
                $("#OgdTumourFormView_SubTumourTypeDiv").show();
                isType = true;
            } else {
                $("#OgdTumourFormView_MalignantDiv").hide();
            }
            if (!isType) {
                $("#OgdTumourFormView_SubTumourTypeDiv").hide();
            }
            ShowProbableText();
        }

        //function ShowInletPatchDiv() {
        //    if ($('#OgdTumourFormView_InletPatchCheckBox').is(':checked')) {
        //        $('#InletPatchDiv').show();
        //    }
        //    else {
        //        $('#InletPatchDiv').hide();
        //    }
        //}

        function ShowProbableText() {
            if ($('#OgdTumourFormView_TumourProbablyCheckBox').is(':checked')) {
                $('#OgdTumourFormView_TumourBenignTypeRadioButtonList_1').next().html('Probable leiomyoma');
                $('#OgdTumourFormView_TumourBenignTypeRadioButtonList_2').next().html('Probable lipoma');
                $('#OgdTumourFormView_TumourBenignTypeRadioButtonList_3').next().html('Probable granular cell tumour');
                $('#OgdTumourFormView_TumourMalignantTypeRadioButtonList_1').next().html('Probable squamous carcinoma');
                $('#OgdTumourFormView_TumourMalignantTypeRadioButtonList_2').next().html('Probable adenocarcinoma');
            } else {
                $('#OgdTumourFormView_TumourBenignTypeRadioButtonList_1').next().html('Leiomyoma');
                $('#OgdTumourFormView_TumourBenignTypeRadioButtonList_2').next().html('Lipoma');
                $('#OgdTumourFormView_TumourBenignTypeRadioButtonList_3').next().html('Granular cell tumour');
                $('#OgdTumourFormView_TumourMalignantTypeRadioButtonList_1').next().html('Squamous carcinoma');
                $('#OgdTumourFormView_TumourMalignantTypeRadioButtonList_2').next().html('Adenocarcinoma');
            }


        }

        function ChkOtherBenign() {
            if (!$('#OgdTumourFormView_TumourBenignTypeRadioButtonList_4').is(':checked')) {
                $("#OgdTumourFormView_TumourBenignTypeOtherTextBox").val("");
            }
        }

        function ChkOtherMalignant() {
            if (!$('#OgdTumourFormView_TumourMalignantTypeRadioButtonList_3').is(':checked')) {
                $("#OgdTumourFormView_TumourMalignantTypeOtherTextBox").val("");
            }
        }


        //function QtyChanged(diag) {
            //if (diag=='Diverticulum') {
            //    if ($find("OgdTumourFormView_DivertQtyNumericTextBox").get_value() != "") {
            //        $("#OgdTumourFormView_DivertMultipleCheckBox").removeAttr("checked");
            //    }
            //}
            //else if (diag == 'Ulceration') {
            //    if ($find("OgdTumourFormView_UlcerationQtyNumericTextBox").get_value() != "") {
            //        $("#OgdTumourFormView_UlcerationMultipleCheckBox").removeAttr("checked");
            //    }
            //}
            //else if (diag == 'InletPatch') {
            //    if ($find("OgdTumourFormView_InletPatchQtyNumericTextBox").get_value() != "") {
            //        $("#OgdTumourFormView_InletPatchMultipleCheckBox").removeAttr("checked");
            //    }
            //}
        //}

        //function MultipleChecked(diag) {
            //if (diag == 'Diverticulum') {
            //    if ($("#OgdTumourFormView_DivertMultipleCheckBox").is(':checked')) {
            //        $find("OgdTumourFormView_DivertQtyNumericTextBox").set_value("");
            //    }
            //}
            //else if (diag == 'Ulceration') {
            //    if ($("#OgdTumourFormView_UlcerationMultipleCheckBox").is(':checked')) {
            //        $find("OgdTumourFormView_UlcerationQtyNumericTextBox").set_value("");
            //    }
            //}
            //else if (diag == 'InletPatch') {
            //    if ($("#OgdTumourFormView_InletPatchMultipleCheckBox").is(':checked')) {
            //        $find("OgdTumourFormView_InletPatchQtyNumericTextBox").set_value("");
            //    }
            //}
        //}

        //function SaveMisc(button, args) {
        //    if ($("#OgdTumourFormView_StrictureCheckBox").is(':checked')) {
        //        var vPerforation = $("#OgdTumourFormView_StricturePerforationRadioButtonList").find(":checked").val();
        //        if (vPerforation != 0 && vPerforation != 1) {
        //            alert('Please select a value to state if there was perforation.');
        //            args.set_cancel(true);
        //        }
        //    }
        //}

    </script>

    <style type="text/css">
        .SiteDetailsForm {
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

            .SiteDetailsForm td {
                padding-bottom:10px;
            }
        .rblType label
        {
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
        <telerik:RadScriptManager ID="OGDTumourRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Tumour</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">

                <asp:ObjectDataSource ID="OgdTumourObjectDataSource" runat="server"
                    TypeName="UnisoftERS.Abnormalities" SelectMethod="GetOgdTumourData" UpdateMethod="SaveOgdTumourData" InsertMethod="SaveOgdTumourData">
                    <SelectParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="None" DbType="Boolean" DefaultValue="false" />							
                        <%--<asp:Parameter Name="Web" DbType="Boolean" DefaultValue="false" />							
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
                        <asp:Parameter Name="Ulceration" DbType="Boolean" DefaultValue="false" />					
                        <asp:Parameter Name="UlcerationType" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="UlcerationMultiple" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="UlcerationQty" DbType="Int32" DefaultValue="0" />					
                        <asp:Parameter Name="UlcerationLength" DbType="Int32" DefaultValue="0" />				
                        <asp:Parameter Name="UlcerationClotInBase" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="UlcerationReflux" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="UlcerationPostSclero" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="UlcerationPostBanding" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="Stricture" DbType="Boolean" DefaultValue="false" />						
                        <asp:Parameter Name="StrictureCompression" DbType="Int32" DefaultValue="0" />			
                        <asp:Parameter Name="StrictureScopeNotPass" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="StrictureSeverity" DbType="Int32" DefaultValue="0" />			
                        <asp:Parameter Name="StrictureType" DbType="Int32" DefaultValue="0" />					
                        <asp:Parameter Name="StrictureProbably" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="StrictureBenignType" DbType="Int32" DefaultValue="0" />			
                        <asp:Parameter Name="StrictureBeginning" DbType="Int32" DefaultValue="0" />			
                        <asp:Parameter Name="StrictureLength" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StricturePerforation" DbType="Int32" ConvertEmptyStringToNull="true" />--%>				
                        <asp:Parameter Name="Tumour" DbType="Boolean" DefaultValue="false" />						
                        <asp:Parameter Name="TumourType" DbType="Int32" DefaultValue="0" />					
                        <asp:Parameter Name="TumourProbably" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="TumourExophytic" DbType="Int32" DefaultValue="0" />				
                        <asp:Parameter Name="TumourBenignType" DbType="Int32" DefaultValue="0" />				
                        <asp:Parameter Name="TumourBenignTypeOther" DbType="String" />			
                        <asp:Parameter Name="TumourBeginning" DbType="Int32" DefaultValue="0" />				
                        <asp:Parameter Name="TumourLength" DbType="Int32" DefaultValue="0" />		
                        <asp:Parameter Name="TumourLocation" DbType="String" />	  <%-- 'edited by mostafiz 3487--%>
                        <asp:Parameter Name="StageT" DbType="String" />	
                        <asp:Parameter Name="StageN" DbType="String" />	
                        <asp:Parameter Name="StageM" DbType="String" />	
                        <asp:Parameter Name="TumourScopeNotPass" DbType="Boolean" DefaultValue="false" />					
                        <%--<asp:Parameter Name="MiscOther" DbType="String"  />		
                        <asp:Parameter Name="InletPatch" DbType="Boolean" DefaultValue="false" />					
                        <asp:Parameter Name="InletPatchMultiple" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="InletPatchQty" DbType="Int32" DefaultValue="0" />	--%>					
                    </UpdateParameters>
                    <InsertParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="None" DbType="Boolean" DefaultValue="false" />							
                        <%--<asp:Parameter Name="Web" DbType="Boolean" DefaultValue="false" />							
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
                        <asp:Parameter Name="Ulceration" DbType="Boolean" DefaultValue="false" />					
                        <asp:Parameter Name="UlcerationType" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="UlcerationMultiple" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="UlcerationQty" DbType="Int32" DefaultValue="0" />					
                        <asp:Parameter Name="UlcerationLength" DbType="Int32" DefaultValue="0" />				
                        <asp:Parameter Name="UlcerationClotInBase" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="UlcerationReflux" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="UlcerationPostSclero" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="UlcerationPostBanding" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="Stricture" DbType="Boolean" DefaultValue="false" />						
                        <asp:Parameter Name="StrictureCompression" DbType="Int32" DefaultValue="0" />			
                        <asp:Parameter Name="StrictureScopeNotPass" DbType="Boolean" DefaultValue="false" />			
                        <asp:Parameter Name="StrictureSeverity" DbType="Int32" DefaultValue="0" />			
                        <asp:Parameter Name="StrictureType" DbType="Int32" DefaultValue="0" />					
                        <asp:Parameter Name="StrictureProbably" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="StrictureBenignType" DbType="Int32" DefaultValue="0" />			
                        <asp:Parameter Name="StrictureBeginning" DbType="Int32" DefaultValue="0" />			
                        <asp:Parameter Name="StrictureLength" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="StricturePerforation" DbType="Int32" ConvertEmptyStringToNull="true"  />--%>					
                        <asp:Parameter Name="Tumour" DbType="Boolean" DefaultValue="false" />						
                        <asp:Parameter Name="TumourType" DbType="Int32" DefaultValue="0" />					
                        <asp:Parameter Name="TumourProbably" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="TumourExophytic" DbType="Int32" DefaultValue="0" />				
                        <asp:Parameter Name="TumourBenignType" DbType="Int32" DefaultValue="0" />				
                        <asp:Parameter Name="TumourBenignTypeOther" DbType="String" />			
                        <asp:Parameter Name="TumourBeginning" DbType="Int32" DefaultValue="0" />				
                        <asp:Parameter Name="TumourLength" DbType="Int32" DefaultValue="0" />
                        <asp:Parameter Name="TumourLocation" DbType="String" />	 <%-- 'edited by mostafiz 3487--%>
                        <asp:Parameter Name="StageT" DbType="String" />	
                        <asp:Parameter Name="StageN" DbType="String" />	
                        <asp:Parameter Name="StageM" DbType="String" />
                        <asp:Parameter Name="TumourScopeNotPass" DbType="Boolean" DefaultValue="false" />					
                        <%--<asp:Parameter Name="MiscOther" DbType="String"  />	   
                        <asp:Parameter Name="InletPatch" DbType="Boolean" DefaultValue="false" />					
                        <asp:Parameter Name="InletPatchMultiple" DbType="Boolean" DefaultValue="false" />				
                        <asp:Parameter Name="InletPatchQty" DbType="Int32" DefaultValue="0" />	--%>
                    </InsertParameters> 
                </asp:ObjectDataSource>


                <asp:FormView ID="OgdTumourFormView" runat="server" DefaultMode="Edit"
                    DataSourceID="OgdTumourObjectDataSource" DataKeyNames="SiteId">
                    <EditItemTemplate>

                        <div id="ContentDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="TumourTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width:780px;">
                                   <%-- <table id="therapeuticTable" class="rgview" cellpadding="0" cellspacing="0">--%>
                                        <colgroup>
                                            <col>
                                            <col>
                                            <col>
                                        </colgroup>
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="2" >
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" Checked='<%# Bind("None")%>' />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%--<tr>
                                                <td style="padding:0px 0px 0px 6px;">
                                                    <table style="width:100%; ">
                                                        <tr>
                                                            <td style="border:none;" >
                                                                <asp:CheckBox ID="CheckBox1" runat="server" Checked='<%# Bind("Web")%>' Text="Web" style="margin-right:10px;"/>
                                                                <asp:CheckBox ID="CheckBox2" runat="server" Checked='<%# Bind("Mallory")%>' Text="Mallory - Weiss tear" style="margin-right:10px;"/>
                                                                <asp:CheckBox ID="CheckBox3" runat="server" Checked='<%# Bind("SchatzkiRing")%>' Text="Schatzki ring" style="margin-right:10px;"/>
                                                                <asp:CheckBox ID="CheckBox4" runat="server" Checked='<%# Bind("FoodResidue")%>' Text="Food residue" style="margin-right:10px;"/>
                                                                <asp:CheckBox ID="CheckBox29" runat="server" Checked='<%# Bind("Foreignbody")%>' Text="Foreign body" style="margin-right:10px;"/><br />
                                                                <div style="float:left"><asp:CheckBox ID="InletPatchCheckBox" runat="server" Checked='<%# Bind("InletPatch")%>' Text="Inlet patch" style="margin-right:10px;"/></div>
                                                                <div id="InletPatchDiv" style="float:left"><asp:CheckBox ID="InletPatchMultipleCheckBox" runat="server" Checked='<%# Bind("InletPatchMultiple")%>' Text="Multiple &nbsp; <i>OR</i> &nbsp; qty" style="margin-right:10px;" onchange="MultipleChecked('InletPatch');"/>
                                                                <telerik:RadNumericTextBox ID="InletPatchQtyNumericTextBox" runat="server" DbValue='<%# Bind("InletPatchQty")%>'
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="50px"
                                                                    MinValue="0"
                                                                    onchange="QtyChanged('InletPatch');">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                    </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>--%>
                                            <%--<tr>
                                                <td style="padding:0px 0px 0px 6px;">
                                                    <table>
                                                        <tr>
                                                            <td style="border:none;vertical-align:top;" >
                                                                <asp:CheckBox ID="DiverticulumCheckBox" runat="server" Checked='<%# Bind("Diverticulum")%>' Text="Diverticulum" />
                                                            </td>
                                                            <td style="border:none;vertical-align:top;" >
                                                                <asp:CheckBox ID="DivertMultipleCheckBox" runat="server" Checked='<%# Bind("DivertMultiple")%>' Text="Multiple &nbsp; <i>OR</i> &nbsp; qty" style="margin-right:10px;" onchange="MultipleChecked('Diverticulum');"/>
                                                                <telerik:RadNumericTextBox ID="DivertQtyNumericTextBox" runat="server" DbValue='<%# Bind("DivertQty")%>'
                                                                    ShowSpinButtons="true"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="50px"
                                                                    MinValue="0"
                                                                    onchange="QtyChanged('Diverticulum');">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox><br />
                                                                <asp:CheckBox ID="CheckBox13" runat="server" Checked='<%# Bind("PulsionType")%>' Text="Pulsion type" style="margin-right:10px;"/>
                                                                <asp:CheckBox ID="CheckBox14" runat="server" Checked='<%# Bind("TractionType")%>' Text="Traction type" style="margin-right:10px;"/>
                                                                <asp:CheckBox ID="CheckBox15" runat="server" Checked='<%# Bind("DiffuseIntramural")%>' Text="Diffuse intramural" style="margin-right:10px;"/>
                                                                <asp:CheckBox ID="CheckBox16" runat="server" Checked='<%# Bind("Pharyngeal")%>' Text="Pharyngeal (Zenker's)" style="margin-right:10px;"/>
                                                            </td>
                                                            <td style="border:none;vertical-align:top;padding-left:30px; " >

                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>--%>
                                            <%--<tr>
                                                <td style="padding:0px 0px 0px 6px;">
                                                    <table style="width:100%;">
                                                        <tr headRow="1" hasChildRows="1">
                                                            <td style="border:none;vertical-align:top;" >
                                                                <asp:CheckBox ID="CheckBox7" runat="server" Checked='<%# Bind("MotilityDisorder")%>' Text="Motility disorder" />
                                                            </td>
                                                        </tr>
                                                        <tr  childRow="1">
                                                            <td style="border:none;vertical-align:top;width:100%;padding:0px 0px 10px 50px;">
                                                                <div style="float: left;">
                                                                    <asp:CheckBox ID="CheckBox9" runat="server" Checked='<%# Bind("ProbableAchalasia")%>' Text="Probable achalasia" style="margin-right:10px;"/><br />
                                                                    <asp:CheckBox ID="CheckBox10" runat="server" Checked='<%# Bind("ConfirmedAchalasia")%>' Text="Confirmed achalasia" style="margin-right:10px;"/><br />
                                                                    <asp:CheckBox ID="CheckBox11" runat="server" Checked='<%# Bind("Presbyoesophagus")%>' Text="Presbyoesophagus" style="margin-right:10px;"/>
                                                                </div>
                                                                <div style="float: left;padding-left:15px; ">
                                                                    <asp:CheckBox ID="CheckBox8" runat="server" Checked='<%# Bind("MarkedTertiaryContractions")%>' Text="Marked tertiary contractions" style="margin-right:10px;"/><br />
                                                                    <asp:CheckBox ID="CheckBox17" runat="server" Checked='<%# Bind("LaxLowerOesoSphincter")%>' Text="Lax lower oesophageal sphincter" style="margin-right:10px;"/><br />
                                                                    <asp:CheckBox ID="CheckBox18" runat="server" Checked='<%# Bind("TortuousOesophagus")%>' Text="Tortuous oesophagus" style="margin-right:10px;"/>
                                                                </div>
                                                                <div style="float: left;padding-left:15px;">
                                                                    <asp:CheckBox ID="CheckBox20" runat="server" Checked='<%# Bind("DilatedOesophagus")%>' Text="Dilated oesophagus" style="margin-right:10px;"/><br />
                                                                    <asp:CheckBox ID="CheckBox21" runat="server" Checked='<%# Bind("MotilityPoor")%>' Text="Poor motility" style="margin-right:10px;"/>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>--%>
                                            <%--<tr>
                                                <td style="padding:0px 0px 0px 6px;">
                                                    <table style="border:none;">
                                                        <tr headRow="1" hasChildRows="1">
                                                            <td style="border:none;vertical-align:top;">
                                                                <asp:CheckBox ID="CheckBox12" runat="server" Checked='<%# Bind("Ulceration")%>' Text="Ulceration"/>
                                                            </td>
                                                            <td style="border:none;">
                                                                <div style="float: left;padding-left:15px;">
                                                                    <asp:CheckBox ID="UlcerationMultipleCheckBox" runat="server" Checked='<%# Bind("UlcerationMultiple")%>' Text="Multiple &nbsp; <i>OR</i> &nbsp; qty" style="margin-right:10px;" onchange="MultipleChecked('Ulceration');" />
                                                                    <telerik:RadNumericTextBox ID="UlcerationQtyNumericTextBox" runat="server" DbValue='<%# Bind("UlcerationQty")%>'
                                                                        ShowSpinButtons="true"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="50px"
                                                                        MinValue="0"
                                                                        onchange="QtyChanged('Ulceration');">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                        Length
                                                                    <telerik:RadNumericTextBox ID="UlcerationLengthNumericTextBox" runat="server" DbValue='<%# Bind("UlcerationLength")%>'
                                                                        ShowSpinButtons="true"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="50px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    mm
                                                                    <span style="margin-left:20px;"></span>
                                                                    <asp:CheckBox ID="CheckBox19" runat="server" Checked='<%# Bind("UlcerationClotInBase")%>' Text="Clot in base"/>
                                                                    
                                                                    <div>
                                                                        <asp:CheckBox ID="CheckBox23" runat="server" Checked='<%# Bind("UlcerationReflux")%>' Text="Reflux (grade 4)" />
                                                                        <span style="margin-left:20px;"></span>
                                                                        <asp:CheckBox ID="CheckBox25" runat="server" Checked='<%# Bind("UlcerationPostSclero")%>' Text="Post sclerotherapy" />
                                                                        <span style="margin-left:73px;"></span>
                                                                        <asp:CheckBox ID="CheckBox22" runat="server" Checked='<%# Bind("UlcerationPostBanding")%>' Text="Post banding" />
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>--%>
                                            <%--<tr>
                                                <td style="padding:0px 0px 0px 6px;">
                                                    <table style="width:100%; ">
                                                        <tr headRow="1" hasChildRows="1">
                                                            <td style="border:none;vertical-align:top;width:15%;" >
                                                                <asp:CheckBox ID="StrictureCheckBox" runat="server" Checked='<%# Bind("Stricture")%>' Text="Stricture" />
                                                            </td>
                                                            <td style="border:none;" >
                                                                <asp:RadioButtonList ID="StrictureCompressionRadioButtonList" runat="server" 
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rblType">
                                                                    <asp:ListItem Value="1" Text="luminal narrowing"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="extrinsic compression"></asp:ListItem>
                                                                    <asp:ListItem Value="3" Text="unknown"></asp:ListItem>
                                                                </asp:RadioButtonList>  
                                                               
                                                                <asp:CheckBox ID="CheckBox28" runat="server" Checked='<%# Bind("StrictureScopeNotPass")%>' Text="'scope could not pass" />                                                          
                                                            
                                                            
                                                                <div style="float: left;margin-left:-90px;">
                                                                    <fieldset id="Fieldset1" runat="server" style="margin-left: 10px;height:105px;">
                                                                        <legend>Severity</legend>
                                                                        <asp:RadioButtonList ID="StrictureSeverityRadioButtonList" runat="server" 
                                                                            CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Slight"></asp:ListItem>
                                                                            <asp:ListItem Value="2" Text="Moderate"></asp:ListItem>
                                                                            <asp:ListItem Value="3" Text="Tight"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                    </fieldset>
                                                                </div>
                                                                <div style="float: left;padding-left:5px;">
                                                                    <fieldset id="Fieldset2" runat="server" style="height:105px;">
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
                                                                        <div id="StrictureTypeDiv"  runat="server" style="float: left;padding-left:5px;">
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
                                                                <div style="float: left;padding-left:5px;">
                                                                    <fieldset id="Fieldset3" runat="server" style="margin-left: 5px;height:105px;width:190px;">
                                                                        <legend>Extent</legend>
                                                                        <div style="float: left;">
                                                                            Beginning
                                                                            <telerik:RadNumericTextBox ID="StrictureBeginningNumericTextBox" runat="server" DbValue='<%# Bind("StrictureBeginning")%>'
                                                                                ShowSpinButtons="true"
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="50px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox> 
                                                                        </div>
                                                                        <div style="float: left;vertical-align:top;">
                                                                            cm, <br/> from incisors. 
                                                                        </div>
                                                                        <div style="margin-top:45px;">
                                                                            Length
                                                                           
                                                                            <telerik:RadNumericTextBox ID="StrictureLengthNumericTextBox" runat="server" DbValue='<%# Bind("StrictureLength")%>'
                                                                                ShowSpinButtons="true" style="margin-left:17px;"
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="50px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox> cm 
                                                                        </div>
                                                                    </fieldset>
                                                                </div>

                                                                <div style="float: left;padding-left:5px;">
                                                                    <fieldset id="Fieldset4" runat="server" style="text-align:center;height:105px; ">
                                                                        <legend>Perforation &nbsp; <img src="../../../../Images/NEDJAG/Mand.png" /></legend>
                                                                    Dilatation leading <br /> to perforation? <br />
                                                                    <div style="padding-top:10px; ">
                                                                        <asp:RadioButtonList ID="StricturePerforationRadioButtonList" runat="server" RepeatDirection="Vertical" CellSpacing="0" RepeatLayout="Flow" CellPadding="0" CssClass="rblType">
                                                                            <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                                            <asp:ListItem Value="0" Text="No" Selected="True"></asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                    </div>
                                                                </fieldset>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <%--<tr childRow="1" >
                                                            <td colspan="4" style="border:none;padding-left:278px;">
                                                                
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>--%>
                                            
                                            <tr id="TumourArea" runat="server">
                                                <td style="padding:0px 0px 0px 6px;">
                                                    <table style="width:100%;">
                                                        <tr headrow="1" haschildrows="1">
                                                            <td style="border:none;" colspan="2" >
                                                                <asp:CheckBox ID="TumourCheckBox" runat="server" Checked='<%# Bind("Tumour")%>' Text="Tumour" />
                                                            </td>
                                                        </tr>
                                                        <tr childrow="1" style="height:23px;">
                                                            <td style="border:none;">
                                                                <div style="margin-top:-34px; margin-right:10px; text-align:right;">
                                                                    <asp:CheckBox ID="TumourScopeCouldNotPassCheckBox" runat="server" Checked='<%# Bind("TumourScopeNotPass")%>' Text="'scope could not pass" />                                                          
                                                                </div>
                                                                <div style="float: left;padding-left:5px;">
                                                                    <fieldset id="Fieldset5" runat="server" style="width:720px;">
                                                                        <legend>Type</legend>
                                                                        <div id="TumourCategoryDiv" style="float: left;">  
                                                                            <asp:RadioButtonList ID="TumourTypeRadioButtonList" runat="server"  
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                                <asp:ListItem Value="1" Text="Benign"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Malignant"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                            <br />
                                                                            &nbsp;&nbsp;<asp:CheckBox ID="TumourProbablyCheckBox" runat="server" Checked='<%# Bind("TumourProbably")%>' Text="(probably)" />
                                                                        </div>
                                                                        <div id="SubTumourTypeDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                            <asp:RadioButtonList ID="TumourExophyticRadioButtonList" runat="server" 
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                                <asp:ListItem Value="1" Text="Indeterminate"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Submucosal"></asp:ListItem>
                                                                                <asp:ListItem Value="3" Text="Exophytic"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                        </div>
                                                                        <div id="MalignantDiv"  runat="server" style="float: left;padding-left:25px;">
                                                                            <asp:RadioButtonList ID="TumourMalignantTypeRadioButtonList" name="TumourMalignantTypeRadioButtonList" runat="server" 
                                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rblType">
                                                                                <asp:ListItem Value="1" Text="Uncertain"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="Squamous carcinoma"></asp:ListItem>
                                                                                <asp:ListItem Value="3" Text="Adenocarcinoma"></asp:ListItem>
                                                                                <asp:ListItem Value="4" Text="Other"></asp:ListItem>
                                                                            </asp:RadioButtonList>
                                                                            <telerik:RadTextBox ID="TumourMalignantTypeOtherTextBox" name="TumourMalignantTypeOtherTextBox" runat="server" Width="200px" Text='<%# Bind("TumourBenignTypeOther")%>' />
                                                                        </div>
                                                                        <div id="BenignDiv"  runat="server" style="float: left;padding-left:25px;">
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
                                                                <div style="float: left;padding-left:5px;">
                                                                    <fieldset id="Fieldset6" runat="server" style="width:720px;">
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
                                                                            
                                                                        <div style="float: left;margin-left:45px;">
                                                                            Length
                                                                            <telerik:RadNumericTextBox ID="TumourLengthNumericTextBox" runat="server" DbValue='<%# Bind("TumourLength")%>'
                                                                                style="margin-left:17px;"
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox> cm 
                                                                        </div>
                                                                    </fieldset>
                                                                </div>
                                                               <%-- 'edited by mostafiz 3487--%>
                                                                  <div style="float: left;padding-left:5px;">
                                                                  <fieldset id="Fieldset7" runat="server" style="width:720px;">
                                                                      <legend>TNM Staging</legend>

                                                                      <div style="float: left;">
                                                                          Location of primary tumour: 
                                                                          <telerik:RadDropDownList ID="TumourLocationDropDownList" runat="server" OnClientSelectedIndexChanged="OnSaveChange"
                                                                            Width="120px" SelectedValue='<%# Bind("TumourLocation") %>'>
                                                                            <Items>
                                                                                <telerik:DropDownListItem Value="" Text="" />
                                                                                <telerik:DropDownListItem Value="Oesophagus" Text="Oesophagus" />
                                                                                <telerik:DropDownListItem Value="Oesophagogastric junction" Text="Oesophagogastric junction" />
                                                                                <telerik:DropDownListItem Value="Stomach" Text="Stomach" />                                                                      
                                                                            </Items>
                                                                        </telerik:RadDropDownList> 
                                                                          &nbsp;
                                                                      </div>
              
                                                                      <div style="float: left;">
                                                                        Stage  T:  
                                                                        <telerik:RadDropDownList ID="StageTDropDownList" runat="server"  OnClientSelectedIndexChanged="OnSaveChange"
                                                                          Width="50px" SelectedValue='<%# Bind("StageT") %>'>
                                                                          <Items>
                                                                              <telerik:DropDownListItem Value="" Text="" />
                                                                              <telerik:DropDownListItem Value="TX" Text="TX" />
                                                                              <telerik:DropDownListItem Value="T0" Text="T0" />
                                                                              <telerik:DropDownListItem Value="Tis" Text="Tis" /> 
                                                                              <telerik:DropDownListItem Value="T1" Text="T1" />
                                                                              <telerik:DropDownListItem Value="T1a" Text="T1a" />
                                                                              <telerik:DropDownListItem Value="T1b" Text="T1b" /> 
                                                                              <telerik:DropDownListItem Value="T2" Text="T2" />
                                                                              <telerik:DropDownListItem Value="T3" Text="T3" />
                                                                              <telerik:DropDownListItem Value="T4" Text="T4" />
                                                                              <telerik:DropDownListItem Value="T4a" Text="T4a" />
                                                                              <telerik:DropDownListItem Value="T4b" Text="T4b" />
                                                                              
                                                                          </Items>
                                                                      </telerik:RadDropDownList>   
                                                                          &nbsp;
                                                                    </div>

                                                                        <div style="float: left;">
                                                                            N:  
                                                                            <telerik:RadDropDownList ID="StageNDropDownList" runat="server"  OnClientSelectedIndexChanged="OnSaveChange"
                                                                              Width="50px" SelectedValue='<%# Bind("StageN") %>'>
                                                                              <Items>
                                                                                  <telerik:DropDownListItem Value="" Text="" />
                                                                                  <telerik:DropDownListItem Value="NX" Text="NX" />
                                                                                  <telerik:DropDownListItem Value="N0" Text="N0" />
                                                                                  <telerik:DropDownListItem Value="N1" Text="N1" /> 
                                                                                  <telerik:DropDownListItem Value="N2" Text="N2" />
                                                                                  <telerik:DropDownListItem Value="N3" Text="N3" />
                                                                                 
                                                                              </Items>
                                                                          </telerik:RadDropDownList>     
                                                                            &nbsp;
                                                                        </div>
                                                                       <div style="float: left;">
                                                                         M:  
                                                                         <telerik:RadDropDownList ID="StageMDropDownList" runat="server"  OnClientSelectedIndexChanged="OnSaveChange"
                                                                           Width="50px" SelectedValue='<%# Bind("StageM") %>'>
                                                                           <Items>
                                                                                <telerik:DropDownListItem Value="" Text="" />
                                                                               <telerik:DropDownListItem Value="MX" Text="MX" />
                                                                               <telerik:DropDownListItem Value="M0" Text="M0" />
                                                                               <telerik:DropDownListItem Value="M1" Text="M1" /> 
                                                                              
                                                                           </Items>
                                                                       </telerik:RadDropDownList>
                                                                           &nbsp;
                                                                     </div>

                                                                  </fieldset>
                                                              </div>
                                                                 <%-- 'edited by mostafiz 3487--%>
                                                            </td>
                                                         
                                                          
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>                                            

                                            <%--<tr>
                                                <td style="padding:0px 0px 0px 6px;">
                                                    <table style="width:100%; ">
                                                        <tr>
                                                            <td style="border:none;" >
                                                                <asp:CheckBox ID="MiscOtherCheckBox" runat="server" Text="Other"/>
                                                            </td>
                                                            <td style="border:none;" >
                                                                <telerik:RadTextBox ID="MiscOtherTextBox" runat="server" Width="500px" Text='<%# Bind("MiscOther")%>' />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>--%>
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
                    <%--<telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"  OnClientClicking="SaveMisc"   />--%>
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>
