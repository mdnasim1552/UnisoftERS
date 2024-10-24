<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Common_Diagnoses" CodeBehind="Diagnoses.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .inferredDiag {
            color: black;
            border-bottom: 1px dashed #ccccff;
            padding: 5px 10px 6px 5px;
            background-color: #ffffb3;
            border-top: 1px solid #e6e600;
            border-right: 1px solid #e6e600;
            border-left: 1px solid #e6e600;
        }
        td {
            border:none !important;
        }
    </style>

    
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
    <script type="text/javascript">
         $(window).on('load', function () {
            <%'------------------- GASTROSCOPY--------------------- %>
            <% If procTypeID = 1 Then%>
                if (!OesophagusTab() && !$("#<%= OverallNormalCheckBox.ClientID%>").is(":checked")) { $("[name*='OesophagusNormalCheckBox']").prop('checked', true); }
                if (!StomachTab() && !$("#<%= OverallNormalCheckBox.ClientID%>").is(":checked")) { $("[name*='StomachNormalCheckBox']").prop('checked', true); }
                if (!DuodenumTab() && !$("#<%= OverallNormalCheckBox.ClientID%>").is(":checked")) { $("[name*='DuodenumNormalCheckBox']").prop('checked', true); }

                //Hide "not entered", "normal" if there are any inferred diagnoses
                if ($("#<%= divAbnoDiagnosesOeso.ClientID%>:not(:empty)").length) {
                    $('#OesophagusTable').hide(); $('#divWholeUpper').hide(); setImage("0", true);
                }
                if ($("#<%= divAbnoDiagnosesStomach.ClientID%>:not(:empty)").length) {
                    $('#StomachTable').hide(); $('#divWholeUpper').hide(); setImage("1", true);
                }
                if ($("#<%= divAbnoDiagnosesDuodenum.ClientID%>:not(:empty)").length) {
                    $('#DuodenumTable').hide(); $('#divWholeUpper').hide(); setImage("2", true);
                }
            <%'--------------------- ERCP --------------------- %>
            <% ElseIf procTypeID = 2 Then%>
//$("#PapillaeTumourDiv").show();
                $('#divWholeUpper').hide();
                //if (!PapillaeTab() && !BiliaryTab()) { $("#<%'= WholePancreaticCheckBox.ClientID%>").prop('checked', true); }

            <%'--------------------- COLONOSCOPY, SIGMOIDOSCOPY, PROCTOSCOPY ---------------------  %>
            <% ElseIf procTypeID = 3 Or procTypeID = 4 Or procTypeID = 5 Then%>
                $('#<%=ColitisCheckBox.ClientID %>').on('click', function () {
                    toggleInflammatory('colitis');
                });

                $('#<%=IleitisCheckBox.ClientID %>').on('click', function () {
                    toggleInflammatory('ileitis');
                });

                $('#divWholeUpper').hide();
                if (!ColonTab()) { $("[name*='ColonNormalCheckBox']").prop('checked', true); }
            <% End If%>
           
        });


        <% '---------------------------------------------------- DOCUMENT READY ------------------------------------------------------------- %>
        $(document).ready(function () {
            <%'------------------- GASTROSCOPY--------------------- %>
            <% If procTypeID = 1 Then%>
                $("#multiPageDivTab").find("input[type=text],input:checkbox , input:radio, select, textarea").change(function () {
                    OesophagusTab();
                });
                $("#multiPageDivTab1").find("input[type=text],input:checkbox , input:radio, select, textarea").change(function () {
                    StomachTab();
                });
                $("#multiPageDivTab2").find("input[type=text],input:checkbox , input:radio, select, textarea").change(function () {
                    DuodenumTab();
                });

                $(".duodenumclass:checkbox[value='D60P1']").change(function () {
                    if ($(".duodenumclass:checkbox[value='D60P1']").is(':checked')) {
                        $(".duodenumclass:checkbox[value='D56P1']").prop('checked', false)
                    }
                });
                $(".duodenumclass:checkbox[value='D56P1']").change(function () {
                    if ($(".duodenumclass:checkbox[value='D56P1']").is(':checked')) {
                        $(".duodenumclass:checkbox[value='D60P1']").prop('checked', false)
                    }
                });

                $(".oesoclass").not("[name*='OesophagusNormalCheckBox']").not("[name*='OesophagusNotEnteredCheckBox']").change(function () {
                    $("[name*='OesophagusNormalCheckBox']").prop('checked', false);
                    $("[name*='OesophagusNotEnteredCheckBox']").prop('checked', false);
                });
                $("[name*='OesophagusNormalCheckBox']").change(function () {
                    $(".oesoclass").not("[name*='OesophagusNormalCheckBox']").removeAttr("checked");
                    $("[name*='OesophagusOtherDiagnosisTextBox']").val("");
                });
                $("[name*='OesophagusNotEnteredCheckBox']").change(function () {
                    $(".oesoclass").not("[name*='OesophagusNotEnteredCheckBox']").removeAttr("checked");
                    $("[name*='OesophagusOtherDiagnosisTextBox']").val("");
                });

                $(".stomachclass").not("[name*='StomachNormalCheckBox']").not("[name*='StomachNotEnteredCheckBox']").change(function () {
                    $("[name*='StomachNormalCheckBox']").prop('checked', false);
                    $("[name*='StomachNotEnteredCheckBox']").prop('checked', false);
                });
                $("[name*='StomachNormalCheckBox']").change(function () {
                    $(".stomachclass").not("[name*='StomachNormalCheckBox']").removeAttr("checked");
                    $("[name*='StomachOtherDiagnosisTextBox']").val("");
                });
                $("[name*='StomachNotEnteredCheckBox']").change(function () {
                    $(".stomachclass").not("[name*='StomachNotEnteredCheckBox']").removeAttr("checked");
                    $("[name*='StomachOtherDiagnosisTextBox']").val("");
                });


                $('#DuodenumTable input[type=checkbox]').change(function () {
                    if (this.id.indexOf("Duodenum2ndPartNotEnteredCheckBox") >= 0 || this.id.indexOf("DuodenumNormalCheckBox") >= 0 || this.id.indexOf("DuodenumNotEnteredCheckBox") >= 0) {
                        $('#DuodenumTable input[type=checkbox]').not("[id*='" + this.id + "']").prop('checked', false);
                        $("[name*='DuodenumOtherDiagnosisTextBox']").val("");
                    }
                });

                $("input:checkbox").not("[name*='OverallNormalCheckBox']").change(function () {
                    $("#<%= OverallNormalCheckBox.ClientID%>").prop('checked', false);
                });

                $("#<%= OverallNormalCheckBox.ClientID%>").change(function () {
                    $("input:checkbox:checked").not("[name*='OverallNormalCheckBox']").removeAttr("checked");
                    $("[name*='OesophagusOtherDiagnosisTextBox']").val("");
                    $("[name*='StomachOtherDiagnosisTextBox']").val("");
                    $("[name*='DuodenumOtherDiagnosisTextBox']").val("");
                    setImage("0", false);
                    setImage("1", false);
                    setImage("2", false);
                    setImage("3", false);
                    setImage("4", false);
                    setImage1("E0", false);
                    setImage1("E1", false);
                });

            <% End If%>

            <%'--------------------- ERCP --------------------- %>
            <% If procTypeID = 2 Then%>
                $('#ERCP_DuodenumTable input[type=checkbox]').change(function () {
                    $('#ERCP_DuodenumTable input[type=checkbox]').not("[id*='" + this.id + "']").prop('checked', false);
                });

                <%'---D32P2_CheckBox is WholePancreaticCheckBox -- %>
                $("#<%= D32P2_CheckBox.ClientID%>").click(function () {
                    if ($("#<%= D32P2_CheckBox.ClientID%>").is(':checked')) {
                        $("#BiliaryTable input:checkbox, input:radio").prop('checked', false);
                        $("#PancreasTable input:checkbox, input:radio").prop('checked', false);
                        $("#PapillaeTable input:checkbox, input:radio").prop('checked', false);
                        $("#NoObviousTR").hide();
                        <%--$("#<%= MinimalTR.ClientID%>").hide();--%>
                        $("#PapillaeTumourDiv").hide();

                        <%--$("#<%= PapillaeTumourDiv.ClientID%>").hide();--%>
                        <%--$("#<%= TumourOtherDiv.ClientID%>").hide();--%>

                        $(".BiliaryClass input:checkbox, .BiliaryClass input:radio").prop('checked', false);
                        $(".BiliaryClass input:text").val('');
                        $("#<%= BiliaryLeakDiv.ClientID%>").hide(); $("#<%= BiliaryLeakDiv.ClientID%> input:text").val('');
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").hide(); $("#<%= ExtrahepaticLeakDiv.ClientID%> input:text").val('');
                        <%--$("#<%= IntrahepaticTumourDiv.ClientID%>").hide(); $("#<%= IntrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false);
                        $("#<%= IntrahepaticTumourTypeTR.ClientID%>").hide(); $("#<%= IntrahepaticTumourTypeTR.ClientID%> input:checkbox").prop('checked', false);--%>
                        $("#<%= ExtrahepaticTumourDiv.ClientID%>").hide(); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= MalignantTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%>").hide(); $("#<%= MalignantTR.ClientID%>").hide();
                    }
                });

                $("#BiliaryTable input:checkbox , #BiliaryTable input:radio").add("#PancreasTable input:checkbox ,#PancreasTable input:radio").add("#PapillaeTable input:checkbox , #PapillaeTable input:radio").click(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= D32P2_CheckBox.ClientID%>").prop('checked', false);
                    }
                });

                $("#<%= PapillaeTumourDiv.ClientID%> input:checkbox").click(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= PapillaeTumourDiv.ClientID%> input:checkbox").not("[id*='" + this.id + "']").prop('checked', false);
                    }
                });

                $("#<%= IntrahepaticTumourDiv.ClientID%> input:checkbox").click(function () {
                if ($(this).is(':checked')) {
                    $("#<%= IntrahepaticTumourDiv.ClientID%> input:checkbox").not("[id*='" + this.id + "']").prop('checked', false);
                    }
                });


                <%'---D33P2_CheckBox is PapillaeNormalCheckBox -- %>
                $("#<%= D33P2_CheckBox.ClientID%>").click(function () {
                        if ($("#<%= D33P2_CheckBox.ClientID%>").is(':checked')) {
                            $(".PapillaeClass input:checkbox, .PapillaeClass input:radio").prop('checked', false);
                        $("#<%= PapillaeTumourDiv.ClientID%>").hide();
                        }
                });

                $(".PapillaeClass input:checkbox , .PapillaeClass input:radio").click(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= D33P2_CheckBox.ClientID%>").prop('checked', false);
                    }
                });

                <%'---D67P2_CheckBox is PancreasNormalCheckBox -- %>
                $("#<%= D67P2_CheckBox.ClientID%>").click(function () {
                    if ($("#<%= D67P2_CheckBox.ClientID%>").is(':checked')) {
                        $(".PancreasClass input:checkbox, input:radio").prop('checked', false);
                       <%-- $("#<%= NoObviousTR.ClientID%>").hide(); $("#<%= MinimalTR.ClientID%>").hide();
                        $("#<%= TumourOtherDiv.ClientID%>").hide();--%>
                        $(".PancreasClass input:text").val('');
                    }
                });

                $(".PancreasClass input:checkbox , .PancreasClass input:radio, .PancreasClass input:text").change(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= D67P2_CheckBox.ClientID%>").prop('checked', false);
                    }
                    if ($(this).val() != null && $(this).val() != "") { $("#<%= D67P2_CheckBox.ClientID%>").prop('checked', false); }
                });

                <%'---D138P2_CheckBox is BiliaryNormalCheckBox -- %>
                $("#<%= D138P2_CheckBox.ClientID%>").click(function () {
                    if ($("#<%= D138P2_CheckBox.ClientID%>").is(':checked')) {
                        $(".BiliaryClass input:checkbox, .BiliaryClass input:radio").prop('checked', false);
                        //$("#NoObviousTR").hide(); $("#MinimalTR").hide(); $("#TumourOtherDiv").hide();
                        $(".BiliaryClass input:text").val('');
                        $("#<%= BiliaryLeakDiv.ClientID%>").hide(); $("#<%= BiliaryLeakDiv.ClientID%> input:text").val('');
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").hide(); $("#<%= ExtrahepaticLeakDiv.ClientID%> input:text").val('');
                        <%--$("#<%= IntrahepaticTumourDiv.ClientID%>").hide(); $("#<%= IntrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false);
                        $("#<%= IntrahepaticTumourTypeTR.ClientID%>").hide(); $("#<%= IntrahepaticTumourTypeTR.ClientID%> input:checkbox").prop('checked', false);--%>
                        $("#<%= ExtrahepaticTumourDiv.ClientID%>").hide(); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= MalignantTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%>").hide(); $("#<%= MalignantTR.ClientID%>").hide();
                    }
                });

                $(".BiliaryClass input:checkbox , .BiliaryClass input:radio, .BiliaryClass input:text").change(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= D138P2_CheckBox.ClientID%>").prop('checked', false);
                    }
                    if ($(this).val() != null && $(this).val() != "") { $("#<%= D138P2_CheckBox.ClientID%>").prop('checked', false); }
                });

                <%'---D265P2_CheckBox is ExtrahepaticNormalCheckBox -- %>
                $("#<%= D265P2_CheckBox.ClientID%>").click(function () {
                    if ($("#<%= D265P2_CheckBox.ClientID%>").is(':checked')) {
                        $("#ExtrahepaticTable input:checkbox, #ExtrahepaticTable input:radio").prop('checked', false);
                        $("#ExtrahepaticTable input:text").val('');
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").hide(); $("#<%= ExtrahepaticLeakDiv.ClientID%> input:text").val('');
                        $("#<%= ExtrahepaticTumourDiv.ClientID%>").hide(); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= MalignantTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%>").hide(); $("#<%= MalignantTR.ClientID%>").hide();
                    }
                });

                $("#ExtrahepaticTable input:checkbox , #ExtrahepaticTable input:radio, #ExtrahepaticTable input:text").change(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= D265P2_CheckBox.ClientID%>").prop('checked', false);
                    }
                    if ($(this).val() != null && $(this).val() != "") { $("#<%= D265P2_CheckBox.ClientID%>").prop('checked', false); }
                });

                <%'---D198P2_CheckBox is NormalDuctsCheckBox -- %>
                $("#<%= D198P2_CheckBox.ClientID%>").click(function () {
                    if ($("#<%= D198P2_CheckBox.ClientID%>").is(':checked')) {
                        $("#IntrahepaticTable input:checkbox, #IntrahepaticTable input:radio").prop('checked', false);
                        $("#IntrahepaticTable input:text").val('');
                        $("#<%= BiliaryLeakDiv.ClientID%>").hide(); $("#<%= BiliaryLeakDiv.ClientID%> input:text").val('');
                        <%--$("#<%= IntrahepaticTumourDiv.ClientID%>").hide(); $("#<%= IntrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false);
                        $("#<%= IntrahepaticTumourTypeTR.ClientID%>").hide(); $("#<%= IntrahepaticTumourTypeTR.ClientID%> input:checkbox").prop('checked', false);--%>
                    }
                });

                $("#IntrahepaticTable input:checkbox , #IntrahepaticTable input:radio, #IntrahepaticTable input:text").change(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= D198P2_CheckBox.ClientID%>").prop('checked', false);
                    }
                    if ($(this).val() != null && $(this).val() != "") { $("#<%= D198P2_CheckBox.ClientID%>").prop('checked', false); }
                });

                <%'---D220P2_CheckBox is BiliaryLeakSiteCheckBox -- %>
                $("#<%= D220P2_CheckBox.ClientID%>").click(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= BiliaryLeakDiv.ClientID%>").show();
                        $(this).siblings('label').html('Biliary leak -site');
                    } else {
                        $("#<%= BiliaryLeakDiv.ClientID%>").hide(); $("#<%= BiliaryLeakDiv.ClientID%> input:text").val('');
                        $(this).siblings('label').html('Biliary leak');
                    }
                });

                <%'---D280P2_CheckBox is ExtrahepaticLeakSiteCheckBox -- %>
                $("#<%= D280P2_CheckBox.ClientID%>").click(function () {
                    if ($(this).is(':checked')) {
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").show();
                        $(this).siblings('label').html('Biliary leak -site');
                    } else {
                        $("#<%= ExtrahepaticLeakDiv.ClientID%>").hide(); $("#<%= ExtrahepaticLeakDiv.ClientID%> input:text").val('');
                        $(this).siblings('label').html('Biliary leak');
                    }
                });

                <%'---D290P2_CheckBox is ExtrahepaticTumourCheckBox -- %>
                $("#<%= D290P2_CheckBox.ClientID%>").click(function () {
                    if ($("#<%= D290P2_CheckBox.ClientID%>").is(':checked')) {
                        $("#<%= ExtrahepaticTumourDiv.ClientID%>").show();
                    } else {
                        $("#<%= ExtrahepaticTumourDiv.ClientID%>").hide(); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:radio").prop('checked', false); $("#<%= ExtrahepaticTumourDiv.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= MalignantTR.ClientID%> input:checkbox").prop('checked', false);
                        $("#<%= BeningTR.ClientID%>").hide(); $("#<%= MalignantTR.ClientID%>").hide();
                    }
                });

                $("#<%= ExtrahepaticTumourRadioButtonList.ClientID%>").click(function () {
                    var v = $(this).find('input:checked').val();
                    if (v == 1) {
                        $("#<%= BeningTR.ClientID%>").show(); $("#<%= MalignantTR.ClientID%>").hide();
                        $("#<%= MalignantTR.ClientID%> input:checkbox").prop('checked', false);
                    } else if (v == 2) {
                        $("#<%= MalignantTR.ClientID%>").show(); $("#<%= BeningTR.ClientID%>").hide();
                        $("#<%= BeningTR.ClientID%> input:checkbox").prop('checked', false);
                    }
                });
            <% End If%>

            <%'--------------------- COLONOSCOPY, SIGMOIDOSCOPY, PROCTOSCOPY ---------------------  %>
            <% If procTypeID = 3 Or procTypeID = 4 Or procTypeID = 5 Then%>
                $("#multiPageDivTab3").find("input[type=text],input:checkbox , input:radio, select, textarea").change(function () {
                    ColonTab();
                    //alert(2);
                    //ColitisTab();
                });

                $(".coloclass").not("[name*='ColonNormalCheckBox']").not("[name*='ColonRestNormalCheckBox']").change(function () {
                    $("[name*='ColonNormalCheckBox']").prop('checked', false);
                    //$(".rest").show();
                    //$(".norm").hide();
                });

                $('.colitisdiv').find('input[type=radio]').click(function (e) {
                    var idVal = $(this).attr("id");
                    if ((($("label[for='" + idVal + "']").text().toLowerCase()) == 'none specified') && ($(this).is(':checked'))) {
                        HideShowColDropDown(false);
                    } else {
                        HideShowColDropDown(true);
                    }
                    //uncheck all the other radio buttons. As the controls (radio buttons) are inside ItemTemplate, "groupname" for selecting only one doesn't work - each radio button is assigned a different group name!
                    $("#multiPageDivTab3").find('input[type=radio]').not("[id='" + $(this).attr('id') + "']").prop("checked", false);

                    //toggle may score div
                    if ((($("label[for='" + idVal + "']").text().toLowerCase()) == 'ulcerative colitis')) {
                        $('.mayoscorediv').show();
                    } else {
                        $('.mayoscorediv').hide();
                    }

                    //toggle SE score div
                    if ((($("label[for='" + idVal + "']").text().toLowerCase()) == "crohn's disease")) {
                        $('.chronsdiseasescorediv').show();
                    } else {
                        $('.chronsdiseasescorediv').hide();
                    }
                });

                $("[name*='ColonNormalCheckBox']").change(function () {
                    $(".coloclass").find('input[type=checkbox]').not("[name*='ColonNormalCheckBox']").prop("checked", false);
                    $(".coloclass:checkbox").not("[name*='ColonNormalCheckBox']").prop("checked", false);
                    // $(".colclass").find('input[type=checkbox]').prop("checked", false);
                    $("[name*='ColonOtherDiagnosisTextBox']").val("");
                    $('.colitisdiv').find('input[type=radio]:checked').prop("checked", false);
                    Colitis();
                });
             <% End If%>


            <%'------------------Used for both OGD and ERCP----------%>

            <%'------------------------------------------------------%>

        });

        <% '----------------------------------------- END OF DOCUMENT READY ----------------------------------------- %>


        <% '----------------------------------------- UPPER GI ----------------------------------------- %>
        <% If procTypeID = 1 Then%>
        function OesophagusTab() {
            var apply = false;
            $("#multiPageDivTab").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#multiPageDivTab input:checkbox:checked").length > 0) { apply = true; }
            if ($("#multiPageDivTab input:radio:checked").length > 0) { apply = true; }
            if ($("#<%= divAbnoDiagnosesOeso.ClientID%>:not(:empty)").length) { apply = true; }
            setImage("0", apply);
            return apply;
        }

        function StomachTab() {
            var apply = false;
            $("#multiPageDivTab1").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#multiPageDivTab1 input:checkbox:checked").length > 0) { apply = true; }
            if ($("#multiPageDivTab1 input:radio:checked").length > 0) { apply = true; }
            if ($("#<%= divAbnoDiagnosesStomach.ClientID%>:not(:empty)").length) { apply = true; }
            setImage("1", apply);
            return apply;
        }

        function DuodenumTab() {
            var apply = false;
            $("#multiPageDivTab2").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#multiPageDivTab2 input:checkbox:checked").length > 0) { apply = true; }
            if ($("#multiPageDivTab2 input:radio:checked").length > 0) { apply = true; }
            if ($("#<%= divAbnoDiagnosesDuodenum.ClientID%>:not(:empty)").length) { apply = true; }
            setImage("2", apply);
            return apply;
        }

        function GastroOtherKeyPress(e) {
            //alert(e.id);
            if ((e.id.indexOf('Oesophagus') !== -1) && $(e).val() != "") { $("[name*='OesophagusNormalCheckBox']").prop('checked', false); $("[name*='OesophagusNotEnteredCheckBox']").prop('checked', false); OesophagusTab(); }
            else if ((e.id.indexOf('Stomach') !== -1) && $(e).val() != "") { $("[name*='StomachNormalCheckBox']").prop('checked', false); $("[name*='StomachNotEnteredCheckBox']").prop('checked', false); StomachTab(); }
            else if ((e.id.indexOf('Duodenum') !== -1) && $(e).val() != "") { $("[name*='DuodenumNormalCheckBox']").prop('checked', false); $("[name*='DuodenumNotEnteredCheckBox']").prop('checked', false); $("[name*='Duodenum2ndPartNotEnteredCheckBox']").prop('checked', false); DuodenumTab(); }
        }
        <% End If%>

        <% '----------------------------------------- Colonoscopy, Sigmoidscopy, Proctoscopy ----------------------------------------- %>

        <% If procTypeID = 3 Or procTypeID = 4 Or procTypeID = 5 Then%>
        function ColonTab() {
            var apply = false;
            $(".rest").hide();
            $(".norm").show();
            $("#multiPageDivTab3").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#<%= divAbnoDiagnosesCol.ClientID%>:not(:empty)").length) { apply = true; }
            if ($("#multiPageDivTab3 input:checkbox:checked").not("[name*='ColonNormalCheckBox']").length > 0) { apply = true; }
            if ($("#multiPageDivTab3 input:radio:checked").length > 0) { apply = true; }
            //setImage("3", apply);
            if (apply) {
                $(".rest").show();
                $(".norm").hide();
            }
            return apply;
        }

        function ColOtherKeyPress(e) {
            if ($(e).val() != "") { $("[name*='ColonNormalCheckBox']").prop('checked', false); }
            ColonTab();
        }

            function toggleInflammatory(cb) {
                if (cb == 'colitis') {
                    $("[name*='IleitisCheckBox']").removeAttr('checked');
                }
                else if (cb == 'ileitis') {
                    $("[name*='ColitisCheckBox']").removeAttr('checked');

                }
            }

            function Colotis() {
                if ($("[name*='ColitisCheckBox']").is(':checked') || $("[name*='IleitisCheckBox']").is(':checked')) {
                    $('.colitisdiv').show();
                } else {
                    $('.colitisdiv').find('input[type=radio]:checked').removeAttr('checked');
                    HideShowColDropDown(false);
                    $('.colitisdiv').hide();
                }
                
            }

        function HideShowColDropDown(bShow) {
            if (!bShow) {
                $('.extentgradingdiv').hide();
                var rd = $find("<%= ExtentDropdownlist.ClientID%>");
                //var da = $find("<%'= GradingDropDownList.ClientID%>");
                rd.trackChanges();
                rd.get_items().getItem(0).select();
                rd.commitChanges();
                //da.trackChanges();
                //da.get_items().getItem(0).select();
                //da.commitChanges();
            } else {
                $('.extentgradingdiv').show();
            }
        }
        <% End If%>
 

        <% '----------------------------------------- General functions ----------------------------------------- %>

        function setImage(ind, state) {
            var tabS = $find("<%= RadTabStrip1.ClientID%>");
            var tab = tabS.findTabByValue(ind);
            if (tab != null) {
                if (state) {
                    tab.set_imageUrl('../../../../Images/Ok.png');

                } else {

                    tab.set_imageUrl("../../../../Images/none.png");
                }
            }
        }

        function setImage1(ind, state) {
            var tabS = $find("<%= RadTabStrip2.ClientID%>");
            var tab = tabS.findTabByValue(ind);
            if (tab != null) {
                if (state) {
                    tab.set_imageUrl('../../../../Images/Ok.png');

                } else {

                    tab.set_imageUrl("../../../../Images/none.png");
                }
            }
        }

        function validateControls(sender, args) {
            // document.getElementById("createValDiv").innerHTML = "";
            var validate = false;
            var tabStrip = $find("<%= RadTabStrip1.ClientID%>");
            var oestab = tabStrip.findTabByText("Oesophagus");
            if (oestab != null && oestab.get_visible()) {

                if ($("#<%= OverallNormalCheckBox.ClientID%>").is(':visible') && $("#<%= OverallNormalCheckBox.ClientID%>").is(':checked') == false) {
                    validate = true;
                } else { validate = false; }

                if (validate == true && oestab != null && oestab.get_visible() && $('input:checkbox:checked.oesoclass').length == 0 && $("[name*='OesophagusOtherDiagnosisTextBox']").val() == '') {
                    validate = true;
                } else { validate = false; }
                var stotab = tabStrip.findTabByText("Stomach");
                if (validate == true && stotab != null && stotab.get_visible() && $('input:checkbox:checked.stomachclass').length == 0 && $("[name*='StomachOtherDiagnosisTextBox']").val() == '') {
                    validate = true;
                } else { validate = false; }
                var duotab = tabStrip.findTabByText("Duodenum");
                if (validate == true && duotab != null && duotab.get_visible() && $('input:checkbox:checked.duodenumclass').length == 0 && $("[name*='DuodenumOtherDiagnosisTextBox']").val() == '') {
                    validate = true;
                } else { validate = false; }

            }
            var coltab = tabStrip.findTabByText("Colon");
            if (coltab != null && coltab.get_visible()) {
                if ($('input:checkbox:checked.coloclass').length == 0 && $("[name*='ColonOtherDiagnosisTextBox']").val() == '') {
                    validate = true;
                } else { validate = false; }
                var colitab = tabStrip.findTabByText("Colitis / Ileitis / IBD");
                if (validate == true && colitab != null && colitab.get_visible() && $(".coloclass").find('input[type=checkbox]:checked').length == 0) {
                    validate = true;
                } else { validate = false; }
            }
            if (validate != true) { return; }
            else {
                if (!$("#<%= divAbnoDiagnosesCol.ClientID%>:not(:empty)").length) {
                        $find("<%=DiagnosesRadNotifier.ClientID%>").show();
                        args.set_cancel(true);
               }
           }

       }

        function CloseWindow() {
            var oWnd = GetRadWindow();
            oWnd.setUrl("about:blank");
            oWnd.close();
        }
    </script>
           </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="DeformityRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="DeformityRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadNotification ID="DiagnosesRadNotifier" runat="server" Animation="Fade"
            EnableRoundedCorners="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            TitleIcon="delete" Position="Center" LoadContentOn="PageLoad"
            AutoCloseDelay="7000">
            <ContentTemplate>
                <div class="aspxValidationSummary">
                    You must record the diagnoses for this procedure.
                        <br />
                    The report cannot be saved without this information.
                </div>
            </ContentTemplate>
        </telerik:RadNotification>
        <asp:ObjectDataSource ID="DiagnosesObjectDataSource" runat="server" SelectMethod="GetDiagnoses" TypeName="UnisoftERS.DataAccess">
            <SelectParameters>
                <asp:Parameter DefaultValue="" DbType="Int32" Name="ProcedureTypeID" />
                <asp:Parameter Name="Section" DefaultValue="" DbType="String" ConvertEmptyStringToNull="true" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Diagnoses</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="560px">



                <div id="ContentDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <div>
                                <div id="divWholeUpper" style="margin-top: 10px; margin-bottom: 20px;">
                                    <asp:CheckBox ID="OverallNormalCheckBox" Visible="false" runat="server" Text="<b>Whole upper gastro-intestinal tract normal</b>" />
                                </div>

                                <div>

                                    <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" ReorderTabsOnSelect="true" Skin="Default" ForeColor="red"
                                        Orientation="HorizontalTop">
                                        <Tabs>
                                            <telerik:RadTab PageViewID="RadPageView0" Text="Oesophagus" Font-Bold="true" Visible="false" Value="0" />
                                            <telerik:RadTab PageViewID="RadPageView1" Text="Stomach" Font-Bold="true" Visible="false" Value="1" />
                                            <telerik:RadTab PageViewID="RadPageView2" Text="Duodenum" Font-Bold="true" Visible="false" Value="2" />
                                            <telerik:RadTab PageViewID="RadPageView3" Text="Colon" Font-Bold="true" Visible="false" Value="3" />
                                            <%--<telerik:RadTab PageViewID="RadPageView4" Text="Colitis / Ileitis / IBD" Font-Bold="true" Visible="false" Value="4" />--%>
                                            <telerik:RadTab PageViewID="RadPageView5" Font-Bold="true" Visible="false" Value="5" />
                                            <%--for ERCP--%>
                                        </Tabs>
                                    </telerik:RadTabStrip>

                                    <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
                                        <telerik:RadPageView ID="RadPageView0" runat="server">
                                            <div id="multiPageDivTab" class="multiPageDivTab">
                                                <fieldset>
                                                    <div>
                                                        <div id="divAbnoDiagnosesOeso" runat="server" visible="false" class="inferredDiag" style="margin-bottom: 6px;"></div>
                                                    </div>
                                                    <asp:DataList ID="oesodatalist" runat="server" RepeatColumns="3" CellPadding="0">
                                                        <HeaderTemplate>
                                                            <table id="OesophagusTable" cellpadding="0" cellspacing="0" style="padding-top: 8px; padding-bottom: 8px;">
                                                                <tr>
                                                                    <td>
                                                                        <input id="OesophagusNotEnteredCheckBox" type="checkbox" runat="server" class="oesoclass" /><asp:Label runat="server" ID="OesophagusNotEnteredlbl" AssociatedControlID="OesophagusNotEnteredCheckBox" Text="Not Entered" />
                                                                    </td>
                                                                    <td style="padding-left: 15px;">
                                                                        <input id="OesophagusNormalCheckBox" type="checkbox" runat="server" class="oesoclass" /><asp:Label runat="server" ID="OesophagusNormallbl" AssociatedControlID="OesophagusNormalCheckBox" Text="Normal" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <input type="checkbox" id="oesoID" runat="server" value='<%# Eval("Code")%>' class="oesoclass" disabled='<%# Eval("Disabled")%>' /><asp:Label runat="server" ID="oesoIDlbl" AssociatedControlID="oesoID" Text='<%# Eval("DisplayName") %>' />
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            <tr>
                                                                <td colspan="4"><span style="padding-right: 5px">Other:</span>
                                                                    <telerik:RadTextBox ID="OesophagusOtherDiagnosisTextBox" runat="server" Skin="Windows7" Width="500" onkeyup="GastroOtherKeyPress(this);"
                                                                        TextMode="MultiLine" Height="80" />
                                                                </td>
                                                            </tr>
                                                        </FooterTemplate>
                                                    </asp:DataList>
                                                </fieldset>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageView1" runat="server">
                                            <div id="multiPageDivTab1" class="multiPageDivTab">
                                                <fieldset>
                                                    <div>
                                                        <div id="divAbnoDiagnosesStomach" runat="server" visible="false" class="inferredDiag" style="margin-bottom: 6px;"></div>
                                                    </div>
                                                    <asp:DataList ID="StomachDataList" runat="server" RepeatColumns="3" CellPadding="0">
                                                        <HeaderTemplate>
                                                            <table id="StomachTable" cellpadding="0" cellspacing="0" style="padding-top: 8px; padding-bottom: 8px;">
                                                                <tr>
                                                                    <td>
                                                                        <input id="StomachNotEnteredCheckBox" type="checkbox" runat="server" class="stomachclass" /><asp:Label runat="server" ID="StomachNotEnteredlbl" AssociatedControlID="StomachNotEnteredCheckBox" Text="Not Entered" />
                                                                    </td>
                                                                    <td style="padding-left: 15px;">
                                                                        <input id="StomachNormalCheckBox" type="checkbox" runat="server" class="stomachclass" /><asp:Label runat="server" ID="StomachNormalCheckBoxLabel" AssociatedControlID="StomachNormalCheckBox" Text="Normal" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <input type="checkbox" runat="server" id="stoID" value='<%# Eval("Code")%>' class="stomachclass" disabled='<%# Eval("Disabled")%>' /><asp:Label runat="server" ID="stoIDlbl" AssociatedControlID="stoID" Text='<%# Eval("DisplayName") %>' />
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            <tr>
                                                                <td colspan="4"><span style="padding-right: 5px">Other:</span>
                                                                    <telerik:RadTextBox ID="StomachOtherDiagnosisTextBox" runat="server" Skin="Windows7" Width="500" onkeyup="GastroOtherKeyPress(this);"
                                                                        TextMode="MultiLine" Height="80" />
                                                                </td>
                                                            </tr>
                                                        </FooterTemplate>
                                                    </asp:DataList>
                                                </fieldset>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageView2" runat="server">
                                            <div id="multiPageDivTab2" class="multiPageDivTab">
                                                <fieldset>
                                                    <div>
                                                        <div id="divAbnoDiagnosesDuodenum" runat="server" visible="false" class="inferredDiag" style="margin-bottom: 6px;"></div>
                                                    </div>
                                                    <asp:DataList ID="DuodenumDataList" runat="server" RepeatColumns="3" CellPadding="0">
                                                        <HeaderTemplate>
                                                            <table id="DuodenumTable" cellpadding="0" cellspacing="0" style="padding-top: 8px; padding-bottom: 8px;">
                                                                <tr>
                                                                    <td>
                                                                        <input id="DuodenumNotEnteredCheckBox" type="checkbox" runat="server" class="duodenumclass" /><asp:Label runat="server" ID="DuodenumNotEnteredlbl" AssociatedControlID="DuodenumNotEnteredCheckBox" Text="Not Entered" />
                                                                    </td>
                                                                    <td style="padding-left: 15px;">
                                                                        <input id="DuodenumNormalCheckBox" type="checkbox" runat="server" class="duodenumclass" /><asp:Label runat="server" ID="DuodenumNormalLabel" AssociatedControlID="DuodenumNormalCheckBox" Text="Normal" />
                                                                    </td>
                                                                    <td style="padding-left: 15px;">
                                                                        <input id="Duodenum2ndPartNotEnteredCheckBox" type="checkbox" runat="server" class="duodenumclass" /><asp:Label runat="server" ID="Duodenum2ndPartNotEnteredLabel" AssociatedControlID="Duodenum2ndPartNotEnteredCheckBox" Text="2nd Part Not Entered" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <input type="checkbox" runat="server" id="duoID" value='<%# Eval("Code")%>' class="duodenumclass" disabled='<%# Eval("Disabled")%>' /><asp:Label runat="server" ID="duoIDlbl" AssociatedControlID="duoID" Text='<%# Eval("DisplayName") %>' />
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            <tr>
                                                                <td colspan="4"><span style="padding-right: 5px">Other:</span>
                                                                    <telerik:RadTextBox ID="DuodenumOtherDiagnosisTextBox" runat="server" Skin="Windows7" Width="500" onkeyup="GastroOtherKeyPress(this);"
                                                                        TextMode="MultiLine" Height="80" />
                                                                </td>
                                                            </tr>
                                                        </FooterTemplate>
                                                    </asp:DataList>
                                                </fieldset>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageView3" runat="server">
                                            <div id="multiPageDivTab3" class="multiPageDivTab">
                                                <fieldset>
                                                    <div>
                                                        <div id="divAbnoDiagnosesCol" runat="server" visible="false" class="inferredDiag" style="margin-bottom: 6px;"></div>
                                                    </div>
                                                    <asp:DataList ID="ColonDataList" runat="server" RepeatColumns="3" CellPadding="0" SkinID="Web20">
                                                        <HeaderTemplate>
                                                            <table id="ColonTable" cellpadding="0" cellspacing="0" style="padding-top: 8px; padding-bottom: 8px;">
                                                                <tr class="norm">
                                                                    <td colspan="4">
                                                                        <input id="ColonNormalCheckBox" type="checkbox" runat="server" class="coloclass" /><asp:Label runat="server" ID="ColonNormalCheckBoxlbl" AssociatedControlID="ColonNormalCheckBox" Text="The examination to the point of insertion was normal " />
                                                                    </td>
                                                                </tr>
                                                                <tr class="rest" style="display: none" colspan="2" id="normid" runat="server">
                                                                    <td colspan="4">
                                                                        <input id="ColonRestNormalCheckBox" type="checkbox" runat="server" class="coloclass" /><asp:Label runat="server" ID="ColonRestNormalCheckBoxlbl" AssociatedControlID="ColonRestNormalCheckBox" Text="The rest of the examination to the point of insertion was normal" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <input type="checkbox" runat="server" id="coloID" value='<%# Eval("Code")%>' class="coloclass" disabled='<%# Eval("Disabled")%>' /><asp:Label runat="server" ID="coloIDLabel" AssociatedControlID="coloID" Text='<%# Eval("DisplayName") %>' />
                                                        </ItemTemplate>
                                                        <FooterTemplate />
                                                    </asp:DataList>

                                                    <fieldset>
                                                        <legend>Inflammatory disorders</legend>
                                                        <asp:CheckBox runat="server" ID="ColitisCheckBox" Text="Colitis" onclick="Colotis();" class="coloclass" />
                                                        <asp:CheckBox runat="server" ID="IleitisCheckBox" Text="Ileitis" onclick="Colotis();" class="coloclass" />
                                                        <asp:CheckBox runat="server" ID="ProctitisCheckBox" Text="Proctitis" class="coloclass" />
                                                        <div style="overflow: auto; display: none; border-top: 1pt dashed #B8CBDE;" class="colitisdiv" id="colitisdiv" runat="server">
                                                            <asp:DataList ID="ColitisDataList" runat="server" RepeatColumns="3" CellPadding="0">
                                                                <HeaderTemplate />
                                                                <ItemTemplate>
                                                                    <input type="radio" runat="server" id="colitisID" value='<%# Eval("Code")%>' class="colitisclass" disabled='<%# Eval("Disabled")%>' /><asp:Label runat="server" ID="colitisIDLabel" AssociatedControlID="colitisID" Text='<%# Eval("DisplayName") %>' />
                                                                </ItemTemplate>
                                                                <FooterTemplate />
                                                            </asp:DataList>
                                                        </div>
                                                        <div class="extentgradingdiv" style="display: none; padding-top: 10px; float: left;" runat="server" id="raddiv">
                                                            <div style="float: left;">
                                                                <asp:Label ID="ExtentGradingLabel" runat="server" Text="Extent:" />
                                                                <telerik:RadComboBox ID="ExtentDropdownlist" runat="server" class="coloclass" Skin="Metro" />
                                                            </div>

                                                            <div class="mayoscorediv" style="display: none; margin-left: 20px; float: left;" runat="server" id="mayoscorediv">
                                                                <asp:Label runat="server">Mayo Score:</asp:Label>&nbsp;
                                                    <telerik:RadComboBox ID="MayoScoreDropDownList" runat="server" CssClass="coloclass" Skin="Metro" Width="455" />
                                                            </div>
                                                            <div class="chronsdiseasescorediv" style="display: none; margin-left: 20px; float: left;" runat="server" id="chronsdiseasescorediv">
                                                                <asp:Label ID="ChronsDiseaseScoreLabel" runat="server" Text="Simple Endoscopic Score – Crohn's Disease (SES-CD):" />
                                                                <telerik:RadComboBox ID="SESDropDownList" runat="server" CssClass="coloclass" Skin="Metro" Width="240" />
                                                            </div>
                                                        </div>
                                                    </fieldset>
                                                    <div style="padding-right: 5px; padding-top: 7px;" />
                                                    <span style="padding-right: 5px;">Other:</span>
                                                    <telerik:RadTextBox ID="ColonOtherDiagnosisTextBox" runat="server" Skin="Windows7" Width="500" onkeyup="ColOtherKeyPress(this);"
                                                        TextMode="MultiLine" Height="40" />


                                                    <%-- <div id="multiPageDivTab4" class="multiPageDivTab">
                                            
                                        </div>--%>
                                                </fieldset>
                                            </div>
                                        </telerik:RadPageView>

                                        <telerik:RadPageView ID="RadPageView5" runat="server">

                                            <div style="margin-bottom: 10px;">
                                                <div id="divERCPAbnoDiagnosesDuodenum" runat="server" visible="false" class="inferredDiag"></div>
                                            </div>
                                            <fieldset id="ERCP_DuodenumFieldset" runat="server">
                                                <legend>Duodenum</legend>
                                                <table id="ERCP_DuodenumTable" runat="server" cellpadding="0" cellspacing="0" style="padding-top: 8px; padding-bottom: 8px;">
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBox ID="D50P2_CheckBox" runat="server" Text="Not Entered" />
                                                            <%-- ERCP_DuodenumNotEnteredCheckBox--%>
                                                        </td>
                                                        <td style="padding-left: 15px;">
                                                            <asp:CheckBox ID="D51P2_CheckBox" runat="server" Text="Normal" />
                                                            <%-- ERCP_DuodenumNormalCheckBox--%>
                                                        </td>
                                                        <td style="padding-left: 15px;">
                                                            <asp:CheckBox ID="D52P2_CheckBox" runat="server" Text="2nd Part Not Entered" />
                                                            <%-- ERCP_Duodenum2ndPartNotEnteredCheckBox--%>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>

                                            <fieldset>
                                                <div style="margin-bottom: 10px; margin-top: 5px;">
                                                    <asp:CheckBox ID="D32P2_CheckBox" runat="server" Text="Whole pancreatic and biliary system normal" Font-Bold="true" />
                                                    <%-- WholePancreaticCheckBox--%>
                                                </div>
                                                <telerik:RadTabStrip ID="RadTabStrip2" runat="server" MultiPageID="RadMultipageE" ReorderTabsOnSelect="true" Skin="Default" Orientation="HorizontalTop">
                                                    <Tabs>
                                                        <telerik:RadTab PageViewID="RadPageViewE0" Text="Papillae & Pancreas" Selected="true" Font-Bold="true" Value="E0" />
                                                        <telerik:RadTab PageViewID="RadPageViewE1" Text="Biliary" Font-Bold="true" Value="E1" />
                                                    </Tabs>
                                                </telerik:RadTabStrip>
                                                <telerik:RadMultiPage ID="RadMultipageE" SelectedIndex="0" runat="server">
                                                    <telerik:RadPageView ID="RadPageViewE0" Selected="true" runat="server">
                                                        <div id="RadPageViewE0Div" class="multiPageDivTab">
                                                            <fieldset>
                                                                <legend>Papillae</legend>
                                                                <div>
                                                                    <div id="divERCPAbnoDiagnosesPapillae" runat="server" visible="false" class="inferredDiag"></div>
                                                                </div>
                                                                <table id="PapillaeTable">
                                                                    <tr>
                                                                        <td>
                                                                            <asp:CheckBox ID="D33P2_CheckBox" runat="server" Text="<b>Normal</b>" /></td>
                                                                        <%-- PapillaeNormalCheckBox--%>
                                                                        <td style="padding-left: 10px; vertical-align: top;" >
                                                                            <asp:CheckBox ID="D41P2_CheckBox" runat="server" Text="Stenosed" />
                                                                            <%-- StenosedCheckBox--%>
                                                                        </td>
                                                                        <td class="PapillaeClass" style="padding-left: 10px;">

                                                                            <div id="PapillaeTumourDiv" runat="server" style="float: left; display: none; border: 1px dotted #B8CBDE; padding: 5px 10px;">
                                                                                <div style="border-bottom: 1px dotted #B8CBDE; margin-bottom: 5px;">
                                                                                    <b>Tumour</b>
                                                                                </div>
                                                                                <asp:CheckBox ID="D45P2_CheckBox" runat="server" Text="probably benign" />
                                                                                &nbsp;&nbsp;&nbsp; <%-- ERCP_TumourBenignCheckBox--%>
                                                                                <asp:CheckBox ID="D65P2_CheckBox" runat="server" Text="probably malignant" />
                                                                                <%-- ERCP_TumourMalignantCheckBox--%>
                                                                                <%--<fieldset>
                                                                            <legend>Tumour</legend>
                                                                            <asp:RadioButtonList runat="server" ID="PapillaeTumourRadioButtonList" RepeatDirection="Horizontal">
                                                                                <asp:ListItem Text="probably benign" Value="1" />
                                                                                <asp:ListItem Text="probably malignant" Value="2" />
                                                                            </asp:RadioButtonList>
                                                                        </fieldset>--%>
                                                                            </div>
                                                                        </td>
                                                                    </tr>
                                                                    <tr class="PapillaeClass">
                                                                        <td></td>
                                                                    </tr>

                                                                </table>

                                                            </fieldset>
                                                            <fieldset>
                                                                <legend>Pancreas</legend>
                                                                <div>
                                                                    <div id="divERCPAbnoDiagnosesPancreas" runat="server" visible="false" class="inferredDiag"></div>
                                                                </div>
                                                                <table id="PancreasTable">
                                                                    <tr>
                                                                        <td>
                                                                            <asp:CheckBox ID="D67P2_CheckBox" runat="server" Text="<b>Normal</b>" Font-Bold="true" />
                                                                            <%-- PancreasNormalCheckBox--%>
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="D68P2_CheckBox" runat="server" Text="Annulare" />
                                                                            <%-- AnnulareCheckBox--%>
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="D69P2_CheckBox" runat="server" Text="Duct injury" />
                                                                            <%-- DuctInjuryCheckBox--%>
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="D74P2_CheckBox" runat="server" Text="Stent occlusion" />
                                                                            <%-- PanStentOcclusionCheckBox--%>
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="D75P2_CheckBox" runat="server" Text="IPMT" />
                                                                            <%-- IPMTCheckBox--%>
                                                                        </td>

                                                                    </tr>

                                                                    <tr class="PancreasClass">
                                                                        <td colspan="7" style="padding-top: 10px;">
                                                                            <label style="padding-right: 10px; vertical-align: top;">Other</label>
                                                                            <asp:TextBox ID="PancreaticOtherTextBox" runat="server" Width="500px" Height="50px" TextMode="MultiLine" />
                                                                        </td>
                                                                    </tr>
                                                                </table>

                                                            </fieldset>
                                                        </div>
                                                    </telerik:RadPageView>
                                                    <telerik:RadPageView ID="RadPageViewE1" runat="server">
                                                        <div id="RadPageViewE1Div" class="multiPageDivTab">
                                                            <fieldset>
                                                                <legend>Biliary system</legend>
                                                                <div>
                                                                    <div id="divERCPBiliary" runat="server" visible="false" class="inferredDiag"></div>
                                                                </div>
                                                                <asp:CheckBox ID="D138P2_CheckBox" runat="server" Text="Normal" Font-Bold="true" />
                                                                <%-- BiliaryNormalCheckBox--%>
                                                                <table id="BiliaryTable">
                                                                    <tr class="BiliaryClass">
                                                                        <td>
                                                                            <asp:CheckBox ID="D140P2_CheckBox" runat="server" Text="Anastomic stricture" />
                                                                            <%-- AnastomicStrictureCheckBox--%>
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="D180P2_CheckBox" runat="server" Text="Gall bladder tumour" />
                                                                            <%-- GallBladderTumourCheckBox--%>
                                                                            <%--<asp:CheckBox ID="D155P2_CheckBox" runat="server" Text="Cystic duct stones" />--%> <%-- CysticDuctCheckBox--%>
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="D150P2_CheckBox" runat="server" Text="Occlusion" />
                                                                            <%-- OcclusionCheckBox--%>
                                                                        </td>
                                                                        <td style="visibility: hidden;">
                                                                            <asp:CheckBox ID="D145P2_CheckBox" runat="server" Text="Fistula" />
                                                                            <%-- FistulaLeakCheckBox--%>
                                                                        </td>
                                                                    </tr>
                                                                    <tr class="BiliaryClass">
                                                                        <td><%-- inferred from abno, so no need to display --%>
                                                                            <asp:CheckBox ID="D175P2_CheckBox" runat="server" Text="Calculous obstruction of cystic duct" />
                                                                            <%-- CalculousObstructionCheckBox--%>
                                                                    
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="D170P2_CheckBox" runat="server" Text="Haemobilia" />
                                                                            <%-- HaemobiliaCheckBox--%>
                                                                    
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="D195P2_CheckBox" runat="server" Text="Stent occlusion" />
                                                                            <%-- StentOcclusionCheckBox--%>
                                                                        </td>
                                                                        <td>
                                                                            <%--<asp:CheckBox ID="D190P2_CheckBox" runat="server" Text="Gall bladder stones" />--%> <%-- GallBladderCheckBox--%>
                                                                        </td>
                                                                    </tr>
                                                                    <tr class="BiliaryClass">
                                                                        <td>
                                                                            <asp:CheckBox ID="D185P2_CheckBox" runat="server" Text="Cholelithiasis" />
                                                                            <%-- CholelithiasisCheckBox--%>
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="D160P2_CheckBox" runat="server" Text="Mirizzi syndrome" />
                                                                            <%-- MirizziCheckBox--%>
                                                                            <%--<asp:CheckBox ID="D165P2_CheckBox" runat="server" Text="Common duct stone(s)" />--%> <%-- CommonDuctCheckBox--%>
                                                                        </td>
                                                                        <td></td>
                                                                        <td></td>
                                                                    </tr>
                                                                    <tr class="BiliaryClass">
                                                                        <td colspan="2" valign="top" style="max-width: 500px;">
                                                                            <fieldset>
                                                                                <legend>Intrahepatic</legend>
                                                                                <div>
                                                                                    <div id="divERCPIntrahepatic" runat="server" visible="false" class="inferredDiag"></div>
                                                                                </div>
                                                                                <asp:CheckBox ID="D198P2_CheckBox" runat="server" Text="<b>Normal ducts</b>" Font-Bold="true" />
                                                                                <%-- NormalDuctsCheckBox--%>
                                                                                <table id="IntrahepaticTable">
                                                                                    <tr>
                                                                                        <td>
                                                                                            <asp:CheckBox ID="D210P2_CheckBox" runat="server" Text="Suppurative cholangitis" />
                                                                                            <%-- SuppurativeCheckBox--%>
                                                                                        </td>

                                                                                        <tr>
                                                                                            <td colspan="4">
                                                                                                <span style="float: left">
                                                                                                    <asp:CheckBox ID="D220P2_CheckBox" runat="server" Text="Biliary leak" />
                                                                                                    <%-- BiliaryLeakSiteCheckBox--%>
                                                                                                </span>
                                                                                                <div id="BiliaryLeakDiv" runat="server" style="display: none; float: left">
                                                                                                    <telerik:RadComboBox ID="BiliaryLeakSiteRadComboBox" runat="server" Skin="Windows7" AllowCustomText="true" Width="150px" />
                                                                                                </div>
                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td colspan="4">
                                                                                                <div id="IntrahepaticTumourDiv" runat="server" style="float: left; display: none; border: 1px dotted #B8CBDE; padding: 5px 10px;">
                                                                                                    <div style="border-bottom: 1px dotted #B8CBDE; margin-bottom: 5px;">
                                                                                                        <b>Tumour</b>
                                                                                                    </div>
                                                                                                    <asp:CheckBox ID="D242P2_CheckBox" runat="server" Text="probable" />
                                                                                                    <%-- IntrahepaticTumourProbableCheckBox--%>
                                                                                        &nbsp;&nbsp;&nbsp;
                                                                                        <asp:CheckBox ID="D243P2_CheckBox" runat="server" Text="possible" />
                                                                                                    <%-- IntrahepaticTumourPossibleCheckBox--%>
                                                                                                </div>
                                                                                            </td>
                                                                                        </tr>
                                                                                </table>
                                                                            </fieldset>
                                                                        </td>
                                                                        <td colspan="2" valign="top" style="max-width: 500px;">
                                                                            <fieldset>
                                                                                <legend>Extrahepatic</legend>
                                                                                <div>
                                                                                    <div id="divERCPExtrahepatic" runat="server" visible="false" class="inferredDiag"></div>
                                                                                </div>
                                                                                <asp:CheckBox ID="D265P2_CheckBox" runat="server" Text="<b>Normal ducts</b>" Font-Bold="true" />
                                                                                <%-- ExtrahepaticNormalCheckBox--%>
                                                                                <table id="ExtrahepaticTable">
                                                                                    <tr>
                                                                                        <td colspan="4">
                                                                                            <span style="float: left">
                                                                                                <asp:CheckBox ID="D280P2_CheckBox" runat="server" Text="Biliary leak" />
                                                                                                <%-- ExtrahepaticLeakSiteCheckBox--%>
                                                                                            </span>
                                                                                            <div id="ExtrahepaticLeakDiv" runat="server" style="display: none; float: left">
                                                                                                <telerik:RadComboBox ID="ExtrahepaticLeakSiteRadComboBox" runat="server" Skin="Windows7" AllowCustomText="true" Width="150px" />
                                                                                            </div>
                                                                                        </td>
                                                                                    </tr>

                                                                                    <tr>
                                                                                        <td colspan="4">
                                                                                            <span style="float: left; padding-right: 10px">
                                                                                                <asp:CheckBox ID="D290P2_CheckBox" runat="server" Text="Stricture" Enabled="false" />
                                                                                                <%-- ExtrahepaticTumourCheckBox--%>
                                                                                            </span>
                                                                                            <div id="ExtrahepaticTumourDiv" runat="server" style="float: left; display: none">
                                                                                                <span style="float: left">
                                                                                                    <asp:RadioButtonList runat="server" ID="ExtrahepaticTumourRadioButtonList" RepeatDirection="Horizontal" Enabled="false">
                                                                                                        <asp:ListItem Text="benign" Value="1" />
                                                                                                        <asp:ListItem Text="malignant" Value="2" />
                                                                                                    </asp:RadioButtonList></span>
                                                                                                <span style="float: left">
                                                                                                    <asp:CheckBox ID="D325P2_CheckBox" runat="server" Text="(probable)" Enabled="false" />
                                                                                                    <%-- ExtrahepaticProbableCheckBox--%>
                                                                                                </span>
                                                                                            </div>

                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr id="BeningTR" runat="server" style="display: none">
                                                                                        <td colspan="4">
                                                                                            <fieldset>
                                                                                                <table style="padding-left: 10px">
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D305P2_CheckBox" runat="server" Text="pancreatitis" />
                                                                                                            <%-- BeningPancreatitisCheckBox--%>
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D310P2_CheckBox" runat="server" Text="a pseudocyst" />
                                                                                                            <%-- BeningPseudocystCheckBox--%>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D315P2_CheckBox" runat="server" Text="previous surgery" />
                                                                                                            <%-- BeningPreviousCheckBox--%>
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D320P2_CheckBox" runat="server" Text="sclerosing cholangitis" />
                                                                                                            <%-- BeningSclerosingCheckBox--%>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D337P2_CheckBox" runat="server" Text="(probable)" />
                                                                                                            <%-- BeningProbableCheckBox--%>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </fieldset>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr id="MalignantTR" runat="server" style="display: none">
                                                                                        <td colspan="4">
                                                                                            <fieldset>
                                                                                                <table style="padding-left: 10px">
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D340P2_CheckBox" runat="server" Text="gallbladder carcinoma" />
                                                                                                            <%-- MalignantGallbladderCheckBox--%>
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D345P2_CheckBox" runat="server" Text="metastatic carcinoma" />
                                                                                                            <%-- MalignantMetastaticCheckBox--%>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D350P2_CheckBox" runat="server" Text="cholangiocarcinoma" />
                                                                                                            <%-- MalignantCholangiocarcinomaCheckBox--%>
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D355P2_CheckBox" runat="server" Text="pancreatic carcinoma" />
                                                                                                            <%-- MalignantPancreaticCheckBox--%>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="D338P2_CheckBox" runat="server" Text="(probable)" />
                                                                                                            <%-- MalignantProbableCheckBox--%>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </fieldset>
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </fieldset>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                                <label style="padding-right: 10px; vertical-align: top;">Other</label>
                                                                <asp:TextBox ID="BiliaryOtherTextBox" runat="server" Width="500px" Height="50px" TextMode="MultiLine" />
                                                            </fieldset>

                                                        </div>

                                                    </telerik:RadPageView>
                                                </telerik:RadMultiPage>
                                                <div style="padding-top: 10px">
                                                    <label style="padding-right: 10px;">Other</label>
                                                    <telerik:RadComboBox ID="WholeOtherRadComboBox" runat="server" Skin="Windows7" AllowCustomText="true" Width="500px" />
                                                </div>
                                            </fieldset>
                                        </telerik:RadPageView>


                                    </telerik:RadMultiPage>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>


            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
