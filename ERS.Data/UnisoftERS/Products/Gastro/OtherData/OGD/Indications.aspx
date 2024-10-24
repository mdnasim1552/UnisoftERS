<%@ Page Language="VB" MasterPageFile="~/Templates/ProcedureMaster.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_OtherData_OGD_Indications" CodeBehind="Indications.aspx.vb" ValidateRequest="false"%>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../../Scripts/jquery-1.11.0.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/Global.js"></script>
    <style type="text/css">
        .whoRadioList {
        }

        .UrgentCheckBox label {
            color: red;
        }

        .checkboxesTable td {
            padding-right: 10px;
            /*padding-bottom:1px;*/
        }

        .inputSpacing {
            padding-right: 25px;
        }
    </style>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">

            window.onbeforeunload = function (event) {
                document.getElementById("<%= SaveOnly.ClientID %>").click();
            }


            $(window).load(function () {
                ToggleAnaemiaTypeComboBox();
                TogglePyloriDiv();
                ToggleUrgentDiv(false);
                cToggleUrgentDiv(false);
                eToggleUrgentDiv(false);
                ToggleDiabetesTypeComboBox();
                ToggleAllergyDescTextBox();
                IndicationsTab();
                ColIndicationsTab();
                CoMorbidiryTab();
                MedicationsTab();
                FollowUpTab();
                ColonFollowUpTab();
                ToggleGIBleedsButton();
                ERSIndicationsTab();
                ERSPlannedTab();
                ERSImagingTab();
                ERSFollowupTab();
            });

            $(document).ready(function () {

                $("#<%= ERSDilatedDuctsCheckBox.ClientID%>").trigger('onclick'); //## This will show/Hide [DilatedDuctsTD]. Other ways are not working effectively, therefore this is safer and shorter...!

                $("#<%=GastrostomyInsertionCheckBox.ClientID%>").click(function () {
                    if ($("#<%=GastrostomyInsertionCheckBox.ClientID%>").is(':checked')) {
                    $("#<%=JejunostomyInsertionCheckBox.ClientID%>").prop('checked', false);
                    $("#<%=NasojejunalCheckBox.ClientID%>").prop('checked', false);
                    }
                });
                $("#<%=JejunostomyInsertionCheckBox.ClientID%>").click(function () {
                    if ($("#<%=JejunostomyInsertionCheckBox.ClientID%>").is(':checked')) {
                    $("#<%=GastrostomyInsertionCheckBox.ClientID%>").prop('checked', false);
                    $("#<%=NasojejunalCheckBox.ClientID%>").prop('checked', false);
                    }
                });
                $("#<%=NasojejunalCheckBox.ClientID%>").click(function () {
                    if ($("#<%=NasojejunalCheckBox.ClientID%>").is(':checked')) {
                    $("#<%=GastrostomyInsertionCheckBox.ClientID%>").prop('checked', false);
                    $("#<%=JejunostomyInsertionCheckBox.ClientID%>").prop('checked', false);
                    }
                });

                $("#<%=ColonScreeningCheckBox.ClientID%>").click(function () {
                    if ($("#<%=ColonScreeningCheckBox.ClientID%>").is(':checked')) {
                    $("#<%=ColonBowelCancerCheckBox.ClientID%>").prop('checked', false);
                    }
                });
                $("#<%=ColonBowelCancerCheckBox.ClientID%>").click(function () {
                    if ($("#<%=ColonBowelCancerCheckBox.ClientID%>").is(':checked')) {
                    $("#<%=ColonScreeningCheckBox.ClientID%>").prop('checked', false);
                    }
                });

                //clears checkbox selections when non is selected
                $("#<%=CoMorbidityNoneCheckbox.ClientID%>").change(function () {
                    if ($(this).is(':checked')) {
                        $("#checkboxesTables tr td").each(function () {
                            $(this).find("input:checkbox:checked").not($("#<%=CoMorbidityNoneCheckbox.ClientID%>")).removeAttr("checked");
                        });
                    }
                });

                $("#checkboxesTables input:checkbox").not($("#<%=CoMorbidityNoneCheckbox.ClientID%>")).change(function () {
                    if ($(this).is(':checked')) {
                        $("#<%=CoMorbidityNoneCheckbox.ClientID%>").prop('checked', false);
                    }
                });

                $("#<%=ColonAssessmentCheckBox.ClientID%>").click(function () {
                    if ($("#<%=ColonAssessmentCheckBox.ClientID%>").is(':checked') || $("#<%=ColonSurveillanceCheckBox.ClientID%>").is(':checked')) {
                        ToggleIBDDiv(true);
                    } else { ToggleIBDDiv(false); }
                });
                $("#<%=ColonSurveillanceCheckBox.ClientID%>").click(function () {
                    if ($("#<%=ColonSurveillanceCheckBox.ClientID%>").is(':checked') || $("#<%=ColonAssessmentCheckBox.ClientID%>").is(':checked')) {
                        ToggleIBDDiv(true);
                    } else {
                        ToggleIBDDiv(false);

                    }
                });
                $("#<%=ColonFamilyCheckBox.ClientID%>").click(function () {
                    if ($("#<%=ColonFamilyCheckBox.ClientID%>").is(':checked')) {
                    $("#<%= familydiv.ClientID%>").show();
                } else {
                    $("#<%= familydiv.ClientID%>").find('input[type=radio]:checked').removeAttr('checked');
                    $find("<%=ColonAdditionalRadTextBox.ClientID%>").set_value('');
                    $("#<%= familydiv.ClientID%>").hide();
                    }
                });
                $("#<%=ColonAnamemiaCheckBox.ClientID%>").click(function () {
                    if ($("#<%=ColonAnamemiaCheckBox.ClientID%>").is(':checked')) {
                    $("#<%= ColonAnaemiaRadComboBox.ClientID%>").show();
                } else {
                    var aneabx = $find("<%= ColonAnaemiaRadComboBox.ClientID%>")
                    aneabx.clearSelection();
                    $("#<%=ColonAnaemiaRadComboBox.ClientID%>").hide();
                    }
                });
                $("#imgTable input:checkbox").change(function () {
                    if ($(this).is(':checked')) {
                        $("#<%=ERSNormalCheckBox.ClientID%>").prop('checked', false);
                    }
                });
                $("#<%=ERSNormalCheckBox.ClientID%>").click(function () {
                    if ($("#<%=ERSNormalCheckBox.ClientID%>").is(':checked')) {
                    $("#imgTable input:checkbox").prop('checked', false);
                    $find("<%=ERSImgOthersTextBox.ClientID%>").set_value('');
                    }
                });
                $("#<%=ERSImgOthersTextBox.ClientID%>").change(function () {
                    if ($find("<%=ERSImgOthersTextBox.ClientID%>").get_value() != '') {
                    $("#<%=ERSNormalCheckBox.ClientID%>").prop('checked', false);
                    }

                });


                $("#IndicationTable").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    IndicationsTab();
                });
                $("#PlannedTable").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    IndicationsTab();
                });
                $("#ColonIndicationTable").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    ColIndicationsTab();
                });
                $("#ColonPlannedTable").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    ColIndicationsTab();
                });
                $("#checkboxesTables").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    CoMorbidiryTab();
                });
                $("#asadiv input:radio:checked").change(function () {
                    CoMorbidiryTab();
                });
                $("#MedicationsDiv").find("input[type=text],input:checkbox,input:radio, select, textarea").change(function () {
                    MedicationsTab();
                });
                $("#FollowUpDiv").find("input[type=text],input:checkbox,input:radio, select, textarea").change(function () {
                    FollowUpTab();
                });
                $("#ColonFollowUpDiv").find("input[type=text],input:checkbox,input:radio, select, textarea").change(function () {
                    ColonFollowUpTab();
                });
                $("#ERSIndicationTable").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    ERSIndicationsTab();
                });
                $("#ERSPlannedTable").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    ERSPlannedTab();
                });
                $("#ERSPlannedTable").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    ERSPlannedTab();
                });
                $("#ImagingTable").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    ERSImagingTab();
                });
                $("#ERSFolloupTable").find("input[type=text],input:checkbox, select, textarea").change(function () {
                    ERSFollowupTab();
                });

                $("#PyloriTable input:checkbox, #PyloriTable input[type=text]").change(function () { //## input[type=text] actually means Select/DropDown controls.. Telerik has its own way to confuse people!
                    if ($(this).is(':checkbox')) {
                        if (!$(this).is(':checked')) {
                            $(this).closest('td').next('td').find("input:text").val("");
                        }
                    }
                    else {
                        var thisId = this.id;
                        if (thisId.indexOf("_CancerComboBox_Input") < 0) {  //## if the user is clicking any of the ListBoxes in the 'Previous H. pylori test'.. then CheckBox gets Checked!
                            $(this).closest('div .RadComboBox').closest('td').prev('td').find("input:checkbox").prop('checked', ($(this).val() != ""));
                        }
                    }
                });

                $("#<%=WhoPerformanceStatusTextBox.ClientID%>").focus(function () {
                    $("#<%= UrgentTwoWeekCheckBox.ClientID%>").focus();
                    ToggleUrgentDiv(true);
                });

                $("#<%=cWhoPerformanceStatusTextBox.ClientID%>").focus(function () {
                    $("#<%= cUrgentCheckBox.ClientID%>").focus();
                    cToggleUrgentDiv(true);
                });

                $("#<%=ERSWHOPerformanceRadTextBox.ClientID%>").focus(function () {
                    $("#<%= ERSUrgentCheckBox.ClientID%>").focus();
                    eToggleUrgentDiv(true);
                });

            });

            function IndicationsTab() {
                var apply = false;
                $("#IndicationTable").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                if ($("#IndicationTable input:checkbox:checked").length > 0) { apply = true; }

                $("#PlannedTable").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                if ($("#PlannedTable input:checkbox:checked").length > 0) { apply = true; }
                setImage("0", apply);
            }

            function ERSIndicationsTab() {
                var apply = false;
                $("#ERSIndicationTable").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                if ($("#ERSIndicationTable input:checkbox:checked").length > 0) { apply = true; }
                setImage("7", apply);
            }

            function ERSPlannedTab() {
                var apply = false;
                $("#ERSPlannedTable").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                if ($("#ERSPlannedTable input:checkbox:checked").length > 0) { apply = true; }
                setImage("9", apply);
            }

            function ERSImagingTab() {
                var apply = false;
                $("#ImagingTable").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                if ($("#ImagingTable input:checkbox:checked").length > 0) { apply = true; }
                setImage("6", apply);
            }

            function ERSFollowupTab() {
                var apply = false;
                $("#ERSFolloupTable").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                if ($("#ERSFolloupTable input:checkbox:checked").length > 0) { apply = true; }
                setImage("8", apply);
            }

            function ColIndicationsTab() {
                var apply = false;
                $("#ColonIndicationTable").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
                });
                if ($("#ColonIndicationTable input:checkbox:checked").length > 0) { apply = true; }

                $("#ColonPlannedTable").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; console.log($(this)); return false; }
                });
                if ($("#ColonPlannedTable input:checkbox:checked").length > 0) { apply = true; }
                setImage("1", apply);
            }

            function CoMorbidiryTab() {
                var apply = false;
                $("#checkboxesTables").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                if ($("#checkboxesTables input:checkbox:checked").length > 0) { apply = true; }
                if ($("#asadiv input:radio:checked").length > 0) { apply = true; }
                setImage("2", apply);
            }

            function MedicationsTab(sender) {
                //console.log(sender);
                var apply = false;

                $("#MedicationsDiv").find("input[type=text], select, textarea").each(function () {
                    //console.log($(this));
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                //if ($("#MedicationsDiv input:checkbox:checked").length > 0) { apply = true; }
                if ($("#MedicationsDiv input:radio:checked").length > 0) { apply = true; }

                setImage("3", apply);
            }

            function FollowUpTab() {
                var apply = false;
                $("#FollowUpDiv").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                if ($("#FollowUpDiv input:checkbox:checked").length > 0) { apply = true; }
                if ($("#FollowUpDiv input:radio:checked").length > 0) { apply = true; }
                setImage("4", apply);
            }

            function ColonFollowUpTab() {
                var apply = false;
                $("#ColonFollowUpDiv").find("input[type=text], select, textarea").each(function () {
                    if ($(this).val() != null && $(this).val() != '') { apply = true; return false; }
                });
                if ($("#ColonFollowUpDiv input:checkbox:checked").length > 0) { apply = true; }
                if ($("#ColonFollowUpDiv input:radio:checked").length > 0) { apply = true; }
                setImage("5", apply);
            }

            function setImage(ind, state) {
                var tabS = $find("<%= RadTabStrip1.ClientID%>");
                if (tabS != null) {
                    if (ind != undefined) {
                        var tab = tabS.findTabByValue(ind);
                        if (tab != null) {
                            if (state) {
                                //tab.set_imageUrl('../../../../Images/Ok.png');
                                tab.get_textElement().style.fontWeight = 'bold';

                            } else {

                                //tab.set_imageUrl("../../../../Images/none.png");
                                tab.get_textElement().style.fontWeight = 'normal';
                            }
                        }
                    }
                }
            }
            //------------------------------------------------------------------------------------

            function ToggleIBDDiv(state) {
                if (state) {
                    $("#<%= ibddiv.ClientID%>").show();
                } else {
                    $("#<%= ibddiv.ClientID%>").find('input[type=radio]:checked').removeAttr('checked');
                    $("#<%= ibddiv.ClientID%>").hide();
                }
            }

            function ClearControls(div) {
                div.find("input:radio:checked").removeAttr("checked");
                div.find("input:checkbox:checked").removeAttr("checked");
                div.find("input:text").val("");
                //div.find("select").clearSelection();
            }

            /****** Indications / Planned Procedures *******/

            function ToggleAnaemiaTypeComboBox() {
                if ($("#<%= AnaemiaCheckBox.ClientID%>").is(':checked')) {
                    $("#<%= AnaemiaTypeComboBox.ClientID%>").show();
                }
                else {
                    $("#<%= AnaemiaTypeComboBox.ClientID%>").hide();
                    $find('<%= AnaemiaTypeComboBox.ClientID%>').clearSelection();
                }
            }

            function TogglePyloriDiv() {
                if ($("#<%= PrevHPyloriCheckBox.ClientID%>").is(':checked')) {
                    $("#<%= PyloriTestDiv.ClientID%>").show();
                }
                else {
                    $("#<%= PyloriTestDiv.ClientID%>").hide();
                    ClearControls($("#<%= PyloriTestDiv.ClientID%>"));
                }
            }

            //### Urgent two week referral
            function ToggleUrgentDiv(showPopup) {
                //console.log("Called from: ToggleUrgentDiv(showPopup)");
                if ($("#<%= UrgentTwoWeekCheckBox.ClientID%>").is(':checked')) {
                    $find("<%=CancerComboBox.ClientID%>").enable();
                    $("#<%= UrgentDiv.ClientID%>").show();
                    if (showPopup) {
                        var oWnd = $find("<%= WHOStatusPickerWindow.ClientID%>");
                        vstate = 0;
                        oWnd.show();

                    }
                }
                else {
                    var combo = $find("<%=CancerComboBox.ClientID%>");
                    combo.disable();
                    combo.set_text("");
                    $("#<%= UrgentDiv.ClientID%>").hide();
                    ClearControls($("#<%= UrgentDiv.ClientID%>"));
                    $("#<%= WHOStatusRadioButtonList.ClientID%> input:radio:checked").removeAttr("checked");
                }
            }


            function eToggleUrgentDiv(showPopup) {
                //console.log("Called from: eToggleUrgentDiv(showPopup)");
                if ($("#<%= ERSUrgentCheckBox.ClientID%>").is(':checked')) {
                    $find("<%=ERSCancerRadComboBox.ClientID%>").enable();
                    $("#<%= eUrgentDiv.ClientID%>").show();
                    if (showPopup) {
                        var oWnd = $find("<%= WHOStatusPickerWindow.ClientID%>");
                        vstate = 2;
                        oWnd.show();

                    }
                }
                else {
                    var combo = $find("<%=ERSCancerRadComboBox.ClientID%>");
                    combo.disable();
                    combo.set_text("");
                    $("#<%= eUrgentDiv.ClientID%>").hide();
                    ClearControls($("#<%= eUrgentDiv.ClientID%>"));
                    $("#<%= WHOStatusRadioButtonList.ClientID%> input:radio:checked").removeAttr("checked");
                }
            }

            var vstate = 0;
            function cToggleUrgentDiv(showPopup) {
                //console.log("Called from: cToggleUrgentDiv(showPopup)");
                if ($("#<%= cUrgentCheckBox.ClientID%>").is(':checked')) {
                    $find("<%=ColonCancerRadComboBox.ClientID%>").enable();
                    $("#<%= cUrgentDiv.ClientID%>").show();
                    if (showPopup) {
                        var oWnd = $find("<%= WHOStatusPickerWindow.ClientID%>");
                        vstate = 1;
                        oWnd.show();
                    }
                }
                else {
                    var combo = $find("<%=ColonCancerRadComboBox.ClientID%>");
                    combo.disable();
                    combo.set_text("");
                    $("#<%= cUrgentDiv.ClientID%>").hide();
                    ClearControls($("#<%= cUrgentDiv.ClientID%>"));
                    $("#<%= WHOStatusRadioButtonList.ClientID%> input:radio:checked").removeAttr("checked");
                }
            }


            function SetWhoStatus() {
                if (vstate == 1) {
                    $find("<%= cWhoPerformanceStatusTextBox.ClientID%>").set_value($("#<%= WHOStatusRadioButtonList.ClientID%> input:checked").val());
                } else if (vstate == 2) {
                    $find("<%= ERSWHOPerformanceRadTextBox.ClientID%>").set_value($("#<%= WHOStatusRadioButtonList.ClientID%> input:checked").val());
                }
                else {
                    $find("<%= WhoPerformanceStatusTextBox.ClientID%>").set_value($("#<%= WHOStatusRadioButtonList.ClientID%> input:checked").val());
                }

                CloseWhoStatusPickerWindow();
            }

            function CloseWhoStatusPickerWindow() {
                var oWnd = $find("<%= WHOStatusPickerWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function ToggleGIBleedsButton() {
                if (($("#<%= MelaenaCheckBox.ClientID%>").is(':checked'))
                    || ($("#<%= HaematemesisCheckBox.ClientID%>").is(':checked'))) {
                    $("#<%= GIBleedsButton.ClientID%>").show();
                }
                else {
                    $("#<%= GIBleedsButton.ClientID%>").hide();
                }
            }

            function ToggleGIBleedsPopup() {
                if (($("#<%= MelaenaCheckBox.ClientID%>").is(':checked'))
                    || ($("#<%= HaematemesisCheckBox.ClientID%>").is(':checked'))) {
                    if ($("#<%= GIBleedsButton.ClientID%>").css("display") == "none") { //stop the popup if button is already visible. Means this has already once been fired, no need to again
                        openGIBleedsPopUp();

                        $("#<%= GIBleedsButton.ClientID%>").show();
                    }

                }
                else {
                    $("#<%= GIBleedsButton.ClientID%>").hide();
                }
            }

     <%--   function CloseCurrentRXWindow() {
            var oWnds = $find("<%= CurrentRXWindow.ClientID%>");
            if (oWnds != null)
                oWnds.close();
            return false;
        }--%>


            /******* Co-Morbidity / ASA Status *******/

            function ToggleDiabetesTypeComboBox() {
                if ($("#<%= DiabetesMellitusCheckBox.ClientID%>").is(':checked')) {
                    $("#<%= DiabetesMellitusTypeComboBox.ClientID%>").show();
                }
                else {
                    $("#<%= DiabetesMellitusTypeComboBox.ClientID%>").hide();
                    $find('<%= DiabetesMellitusTypeComboBox.ClientID%>').clearSelection();
                }
            }


            /******* Medication / Allergies *******/

            function ToggleAllergyDescTextBox() {
                if ($("#<%= AllergyYesRadioButton.ClientID%>").is(':checked')) {
                    $("#<%= AllergyDescTextBox.ClientID%>").show();
                }
                else {
                    $("#<%= AllergyDescTextBox.ClientID%>").hide();
                    $('#<%= AllergyDescTextBox.ClientID%>').val("");
                }
            }

            /******* Following up *******/

            function BuildSurgeryFollowUpText() {
                var proc, period, newtxt, oldtxt;
                proc = $("#<%= SurgeryFollowUpProcComboBox.ClientID%>").val();
                period = $("#<%= SurgeryFollowUpProcPeriodComboBox.ClientID%>").val()
                oldtxt = $find("<%= SurgeryFollowUpTextBox.ClientID%>").get_value();

                if (period == "undefined" || period == "unknown") { period = ""; }
                if (proc == "undefined") { proc = ""; }
                newtxt = "";

                if (proc != "" && period != "") {
                    newtxt = proc + " " + period;
                }
                else if (proc != "") {
                    newtxt = proc;
                }

                if (newtxt != "") {
                    if (oldtxt != "") {
                        oldtxt = oldtxt.replace(" and ", ", ")
                        newtxt = oldtxt + " and " + newtxt;
                    }
                    $find("<%= SurgeryFollowUpTextBox.ClientID%>").set_value(newtxt);
                }

                ClearComboBox("<%= SurgeryFollowUpProcComboBox.ClientID %>");
                ClearComboBox("<%= SurgeryFollowUpProcPeriodComboBox.ClientID %>");
            }

            function cBuildSurgeryFollowUpText() {
                var proc, period, newtxt, oldtxt;
                proc = $("#<%= ColonFollowUpLeftRadComboBox.ClientID%>").val();
                period = $("#<%= ColonFollowUpRightRadComboBox.ClientID%>").val()
                oldtxt = $find("<%= ColonFollowUpRadTextBox.ClientID%>").get_value();

                if (period == "undefined" || period == "unknown") { period = ""; }
                if (proc == "undefined") { proc = ""; }
                newtxt = "";

                oldtxt = oldtxt.replace("Previous ", "");
                if (proc != "" && period != "") {
                    newtxt = "a " + proc + " " + period;
                }
                else if (proc != "") {
                    newtxt = "a " + proc;
                }

                if (newtxt != "") {
                    if (oldtxt != "") {
                        oldtxt = oldtxt.replace(" and ", ", ");
                        newtxt = oldtxt + " and " + newtxt;
                    }
                    $find("<%= ColonFollowUpRadTextBox.ClientID%>").set_value("Previous " + newtxt);
                }

                $find("<%= ColonFollowUpLeftRadComboBox.ClientID%>").clearSelection();
                ClearComboBox("<%= ColonFollowUpRightRadComboBox.ClientID%>");
            }

            function validateControls(sender, args) {
                document.getElementById("valDiv").innerHTML = '';
                var initialValidationPassed = true;

                if (validateCoMorbidity(sender, args) != true)
                    initialValidationPassed = false;

                if (validateAntiCoag(sender, args) != true)
                    initialValidationPassed = false;

                if (validateASA(sender, args) != true)
                    initialValidationPassed = false;

                if (initialValidationPassed)
                    validatePage(sender, args);
            }

            function validateAntiCoag(sender, args) {
                var validate = false;
                var antiCoagChecked = false;
                antiCoagChecked = $("#<%= AntiCoagRadioButtonList.ClientID%> input:checked").val() == 1 || antiCoagChecked;
                if (antiCoagChecked) {
                    if ($("#<%= DamagingDrugsMultiTextBox.ClientID%>").val() != null && $("#<%= DamagingDrugsMultiTextBox.ClientID%>").val() != '') {
                        validate = true;
                    } else {
                        validate = false;
                    }
                    if (validate == true) {
                        return true;
                    }
                    else {
                        args.set_cancel(true);
                        var msg = document.getElementById("valDiv").innerHTML;
                        if (msg == null || msg == '') {
                            document.getElementById("valDiv").innerHTML = "* You must record medication/allergies for this procedure when the patient is taking anti-coagulant or anti-platelet medication.";
                        } else {
                            document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record medication/allergies for this procedure when the patient is taking anti-coagulant or anti-platelet medication.";
                        }
                        var tabstrip = $find('<%= RadTabStrip1.ClientID %>');
                        tabstrip.get_tabs().getTab("2").click();

                        $find("<%=CreateProcRadNotification.ClientID%>").show();
                        return false;
                    }
                } else {
                    return true;
                }
            }

            function validateCoMorbidity(sender, args) {
                var validate = false;
                $("#checkboxesTables input:checkbox").each(function () {
                    if ($(this).is(':checked')) { validate = true; return false; }
                });
                $('#checkboxesTables').find('inputinput[type=text], select, textarea').each(function () {
                    if ($(this).val() != null && $(this).val() != '') { validate = true; return false; }
                });
                //$("#IndicationTable1 input[type=text], textarea").each(function () {
                //    console.log($(this));
                //    if ($(this).val() != null && $(this).val() != '') { validate = true; return false; }
                //});

                if (validate == true) { return true; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* You must record co-morbidity for this procedure.";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record co-morbidity for this procedure";
                    }
                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                    return false;
                }
            }

            function validateASA(sender, args) {
                var validate = false;
                var asav = $("#asadiv input:radio:checked").val();
                if (asav != null) { validate = true; return true; }


                //$("#IndicationTable1 input[type=text], textarea").each(function () {
                //    console.log($(this));
                //    if ($(this).val() != null && $(this).val() != '') { validate = true; return false; }
                //});

                if (validate == true) { return true; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* You must record ASA physical status classification for this procedure, even if this is 'Not assessed'";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record ASA physical status classification for this procedure, even if this is 'Not assessed'";
                    }
                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                    return false;
                }
            }

            function openGIBleedsPopUp() {
                var own = radopen("GIBleeds.aspx", "GI Bleeds", '865px', '700px');
                own.set_visibleStatusbar(false);
            }

            function DilatedBileClicked(sender) {
                console.log("function DilatedBileClicked(sender): " + (sender).is(":checked"));
                if ((sender).is(":checked")) {
                    $("#DilatedDuctsTD").show();
                    console.log("$(#DilatedDuctsTD).show();");
                } else {
                    $("#DilatedDuctsTD").hide();
                    $("#DilatedDuctsTD").find("input:checkbox:checked").prop("checked", false);
                    console.log("$(#DilatedDuctsTD).hide();");
                }

            }
        </script>

    </telerik:RadScriptBlock>
</asp:Content>
<asp:Content ID="IDBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadNotification ID="CreateProcRadNotification" runat="server" Animation="None" 
                    EnableRoundedCorners="true" EnableShadow="true" Title="Please correct the following"
                    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center"
                    AutoCloseDelay="7000" Skin="Web20">
        <ContentTemplate>
            <div id="valDiv" class="aspxValidationSummary">
            </div>
        </ContentTemplate>
    </telerik:RadNotification>

    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="500px">
            <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                <div id="ContentDiv">
                    <div class="otherDataHeading">
                        <b>Indications</b>
                    </div>
                    <div style="margin: 0px 20px;">
                        <div style="margin-top: 10px;">
                        </div>

                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" ReorderTabsOnSelect="true" Skin="Metro"
                            Orientation="HorizontalTop" RenderMode="Lightweight">
                            <Tabs>
                                <telerik:RadTab Text="Imaging" Font-Bold="true" Value="6" PageViewID="ERCPRadPageView4" Visible="false" />
                                <telerik:RadTab Text="Indications / Planned procedures" Value="0" Font-Bold="true" PageViewID="RadPageView0" Visible="false" imageUrl="../../../../Images/NEDJAG/NED.png" />
                                <telerik:RadTab Text="Indications / Planned procedures" Value="1" Font-Bold="true" PageViewID="RadPageView9" Visible="false" imageUrl="../../../../Images/NEDJAG/NED.png" />
                                <telerik:RadTab Text="Indications" Value="7" Font-Bold="true" PageViewID="ERCPRadPageView5" Visible="false" />
                                <telerik:RadTab Text="Planned procedures" Value="9" Font-Bold="true" PageViewID="ERCPRadPageView9" Visible="false" />
                                <telerik:RadTab Text="Co-morbidity / ASA status" Value="2" Font-Bold="true" PageViewID="RadPageView1" Visible="false" imageUrl="../../../../Images/NEDJAG/Mand.png" />
                                <telerik:RadTab Text="Medication / Allergies" Value="3" Font-Bold="true" PageViewID="RadPageView2" Visible="false" />
                                <telerik:RadTab Text="Previous History" Font-Bold="true" Value="4" PageViewID="RadPageView3" Visible="false" />
                                <telerik:RadTab Text="Previous History" Font-Bold="true" Value="5" PageViewID="ColonFollowingUpRadPageView" Visible="false" />
                                <telerik:RadTab Text="Previous History" Font-Bold="true" Value="8" PageViewID="ERCPRadPageView6" Visible="false" />
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server">
                            <telerik:RadPageView ID="RadPageView0" runat="server">
                                <div class="multiPageDivTab">
                                    <fieldset id="IndicationsFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Clinical indications</legend>

                                        <div id="ogdIndications" runat="server">
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="TumourStagingCheckbox" runat="server" Text="Tumour staging" />
                                                    </td>
                                                    <td>
                                                        <asp:CheckBox ID="MediastinalAbnoCheckbox" runat="server" Text="Mediastinal Abnormality" />
                                                    </td>
                                                    <td>
                                                        <asp:CheckBox ID="LymphNodeCheckBox" runat="server" Text="Lymph node sampling" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="SubmucosalCheckBox" runat="server" Text="Submucosal lesion" />
                                                    </td>
                                                    <td>
                                                        <asp:CheckBox ID="FNAMassCheckbox" runat="server" Text="FNA adrenal mass" />
                                                    </td>
                                                </tr>

                                            </table>
                                        </div>


                                        <table id="IndicationTable" cellpadding="0" cellspacing="0">

                                            <div  runat="server" id="hideIndications">
                                              <tr>
                                                <td colspan="2">
                                                    <div style="float: left; width: 180px;">
                                                        <div style="height: 23px;">
                                                            <asp:CheckBox ID="AnaemiaCheckBox" runat="server" Text="Anaemia" Skin="Windows7" ForeColor="YellowGreen"
                                                                onchange="ToggleAnaemiaTypeComboBox();" />
                                                            <telerik:RadComboBox ID="AnaemiaTypeComboBox" runat="server" Width="100" Skin="Windows7" Style="margin-left: 5px;">
                                                                <Items>
                                                                    <telerik:RadComboBoxItem Text="" Value="0" />
                                                                    <telerik:RadComboBoxItem Text="Unspecified" Value="1" />
                                                                    <telerik:RadComboBoxItem Text="Microcytic" Value="2" />
                                                                    <telerik:RadComboBoxItem Text="Normocytic" Value="3" />
                                                                    <telerik:RadComboBoxItem Text="Macrocytic" Value="4" />
                                                                </Items>
                                                            </telerik:RadComboBox>
                                                        </div>
                                                        <asp:CheckBox ID="AbdominalPainCheckBox" runat="server" Text="Abdominal pain" />
                                                        <br />
                                                        <div id="EnteroscopyIndicationsDiv" runat="server" visible="false">
                                                            <asp:CheckBox ID="AbnormalCapsuleStudyCheckBox" runat="server" Text="Abnormal capsule study" />
                                                            <br />
                                                            <asp:CheckBox ID="AbnormalMRICheckBox" runat="server" Text="Abnormal MRI" />
                                                            <br />
                                                        </div>
                                                        <asp:CheckBox ID="AbnormalityOnBariumCheckBox" runat="server" Text="Abnormality on barium" />
                                                        <br />
                                                        <asp:CheckBox ID="ChestPainCheckBox" runat="server" Text="Chest pain" />
                                                        <br />
                                                        <asp:CheckBox ID="ChronicLiverCheckBox" runat="server" Text="Chronic liver disease ?varices" />
                                                        <br />
                                                    </div>
                                                    <div style="float: left; margin-left: 8px;">
                                                        <asp:CheckBox ID="CoffeeGroundsVomitCheckBox" runat="server" Text="Coffee grounds vomit" />
                                                        <br />
                                                        <asp:CheckBox ID="DiarrhoeaCheckBox" runat="server" Text="Diarrhoea" />
                                                        <br />
                                                        <asp:CheckBox ID="DrugTrialCheckBox" runat="server" Text="Drug trial" />
                                                        <br />
                                                        <asp:CheckBox ID="DyspepsiaCheckBox" runat="server" Text="Dyspepsia" />
                                                        <br />
                                                        <asp:CheckBox ID="DyspepsiaAtypicalCheckBox" runat="server" Text="Dyspepsia - atypical" />
                                                        <br />
                                                    </div>
                                                    <div style="float: left; margin-left: 8px;">
                                                        <asp:CheckBox ID="DyspepsiaUlcerTypeCheckBox" runat="server" Text="Dyspepsia - ulcer type" />
                                                        <br />
                                                        <asp:CheckBox ID="DysphagiaCheckBox" runat="server" Text="Dysphagia" />
                                                        <br />
                                                        <asp:CheckBox ID="HaematemesisCheckBox" runat="server" Text="Haematemesis" onchange="ToggleGIBleedsPopup();" />
                                                        <br />
                                                        <asp:CheckBox ID="MelaenaCheckBox" runat="server" Text="Melaena" onchange="ToggleGIBleedsPopup();" />
                                                        <telerik:RadButton ID="GIBleedsButton" runat="server" Text="GI Bleeds" OnClientClicked="openGIBleedsPopUp" Skin="Windows7" Icon-PrimaryIconUrl="~/Images/icons/GI_Bleeds.png" AutoPostBack="false" />
                                                        <br />
                                                        <asp:CheckBox ID="NauseaAndOrVomitingCheckBox" runat="server" Text="Nausea and/or vomiting" />
                                                        <br />
                                                    </div>
                                                    <div style="float: left; margin-left: 8px;">
                                                        <asp:CheckBox ID="OdynophagiaCheckBox" runat="server" Text="Odynophagia" />
                                                        <br />
                                                        <asp:CheckBox ID="PositiveTTGCheckBox" runat="server" Text="Positive TTG / EMA" />
                                                        <br />
                                                        <asp:CheckBox ID="RefluxSymptomsCheckBox" runat="server" Text="Reflux symptoms" />
                                                        <br />
                                                        <asp:CheckBox ID="UlcerExclusionCheckBox" runat="server" Text="Ulcer exclusion" />
                                                        <br />
                                                        <asp:CheckBox ID="WeightLossCheckBox" runat="server" Text="Weight loss" />
                                                        <br />
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 464px;" valign="top">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td colspan="2">
                                                                <asp:CheckBox ID="PrevHPyloriCheckBox" runat="server" Text="Previous H. pylori test"
                                                                    onchange="TogglePyloriDiv();" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <div id="PyloriTestDiv" runat="server" style="margin-left: 10px;">
                                                                    <table id="PyloriTable">
                                                                        <tr>
                                                                            <td style="width: 70px;">
                                                                                <asp:CheckBox ID="SerologyCheckBox" runat="server" Text="Serology" />
                                                                            </td>
                                                                            <td style="width: 98px;">
                                                                                <telerik:RadComboBox ID="SerologyResultComboBox" runat="server" Width="95" Skin="Windows7">
                                                                                    <Items>
                                                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                                                        <telerik:RadComboBoxItem Text="Positive" Value="1" />
                                                                                        <telerik:RadComboBoxItem Text="Negative" Value="2" />
                                                                                        <telerik:RadComboBoxItem Text="Inconclusive" Value="3" />
                                                                                    </Items>
                                                                                </telerik:RadComboBox>
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="UreaseCheckBox" runat="server" Text="Urease" />
                                                                            </td>
                                                                            <td>
                                                                                <telerik:RadComboBox ID="UreaseResultComboBox" runat="server" Width="95" Skin="Windows7">
                                                                                    <Items>
                                                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                                                        <telerik:RadComboBoxItem Text="Positive" Value="1" />
                                                                                        <telerik:RadComboBoxItem Text="Negative" Value="2" />
                                                                                        <telerik:RadComboBoxItem Text="Inconclusive" Value="3" />
                                                                                    </Items>
                                                                                </telerik:RadComboBox>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <asp:CheckBox ID="BreathCheckBox" runat="server" Text="Breath" />
                                                                            </td>
                                                                            <td>
                                                                                <telerik:RadComboBox ID="BreathResultComboBox" runat="server" Width="95" Skin="Windows7">
                                                                                    <Items>
                                                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                                                        <telerik:RadComboBoxItem Text="Positive" Value="1" />
                                                                                        <telerik:RadComboBoxItem Text="Negative" Value="2" />
                                                                                        <telerik:RadComboBoxItem Text="Inconclusive" Value="3" />
                                                                                    </Items>
                                                                                </telerik:RadComboBox>
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="StoolAntigenCheckBox" runat="server" Text="Stool antigen" />
                                                                            </td>
                                                                            <td>
                                                                                <telerik:RadComboBox ID="StoolAntigenResultComboBox" runat="server" Width="95" Skin="Windows7">
                                                                                    <Items>
                                                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                                                        <telerik:RadComboBoxItem Text="Positive" Value="1" />
                                                                                        <telerik:RadComboBoxItem Text="Negative" Value="2" />
                                                                                        <telerik:RadComboBoxItem Text="Inconclusive" Value="3" />
                                                                                    </Items>
                                                                                </telerik:RadComboBox>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </div>
                                                            </td>
                                                            <%--                                                            <td style="text-align: right; vertical-align: top;" class="rptSummaryText10">
                                                                
                                                            </td>--%>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td style="text-align: right; vertical-align: top; width: 192px;" class="rptSummaryText10">
                                                    <asp:CheckBox ID="UrgentTwoWeekCheckBox" runat="server"
                                                        Text="Urgent two week referral"
                                                        onchange="ToggleUrgentDiv(true);" CssClass="UrgentCheckBox" />


                                                    <div style="margin-left: 10px; margin-bottom: 3px;">
                                                        Cancer&nbsp;&nbsp;
                                                                    <telerik:RadComboBox ID="CancerComboBox" runat="server" Width="100" Skin="Windows7">
                                                                        <Items>
                                                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                                                            <telerik:RadComboBoxItem Text="Definite" Value="1" />
                                                                            <telerik:RadComboBoxItem Text="Suspected" Value="2" />
                                                                            <telerik:RadComboBoxItem Text="Excluded" Value="3" />
                                                                        </Items>
                                                                    </telerik:RadComboBox>
                                                    </div>
                                                    <div id="UrgentDiv" runat="server" style="margin-left: 10px;">
                                                        WHO Performance Status&nbsp;&nbsp;
                                                                    <telerik:RadTextBox ID="WhoPerformanceStatusTextBox" runat="server" Skin="Windows7" Width="30" />
                                                    </div>

                                                </td>
                                            </tr>
                                            </div>
                                            <tr class="rptSummaryText10">
                                                <td colspan="4">
                                                    <table>
                                                        <tr>
                                                            <td>Other indications :&nbsp;&nbsp;</td>
                                                            <td>Clinically important comments :&nbsp;&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                             <td style="padding-right: 20px;">
                                                                <telerik:RadTextBox ID="OtherIndicationTextBox" runat="server" Skin="Windows7" Width="300px" TextMode="MultiLine" Height="55" />
                                                            </td>
                                                           <td>
                                                                <telerik:RadTextBox ID="ClinicallyImportantCommentsTextBox" runat="server" Skin="Windows7" Width="350px"
                                                                    TextMode="MultiLine" Height="55" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>

                                    </fieldset>
                                    <fieldset id="PlannedProceduresFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Planned Procedures</legend>
                                        <table id="PlannedTable" cellspacing="0" cellpadding="0" class="checkboxesTable">
                                           
                                            <tr id="PlannedProceduresRow" runat="server">
                                                <td>
                                                    <asp:CheckBox ID="BariatricPreAssessmentCheckBox" runat="server" Text="Bariatric pre-assessment" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EusCheckBox" runat="server" Text="EUS" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="NasojejunalCheckBox" runat="server" Text="Nasojejunal tube (NJT)" class="mutuallyexclusive" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="PushEnteroscopyCheckBox" runat="server" Text="Push enteroscopy" />

                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="BalloonInsertionCheckBox" runat="server" Text="Balloon insertion" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="GastrostomyInsertionCheckBox" runat="server" Text="Gastrostomy insertion (PEG)" class="mutuallyexclusive" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="OesophagealDilatationCheckBox" runat="server" Text="Oesophageal dilatation" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="SmallBowelBiopsyCheckBox" runat="server" Text="Small bowel biopsy" />
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="BalloonRemovalCheckBox" runat="server" Text="Balloon removal" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="InsertionOfPhProbeCheckBox" runat="server" Text="Insertion of pH probe" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="PegRemovalCheckBox" runat="server" Text="PEG removal" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="StentRemovalCheckBox" runat="server" Text="Stent removal" />
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="PostBariatricSurgeryAssessmentCheckBox" runat="server" Text="Post bariatric surgery assessment" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="JejunostomyInsertionCheckBox" runat="server" Text="Jejunostomy insertion (PEJ)" class="mutuallyexclusive" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="PEGReplacementCheckBox" runat="server" Text="PEG replacement" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="StentInsertionCheckBox" runat="server" Text="Stent Insertion" class="mutuallyexclusive" />
                                                </td>
                                            </tr>

                                            <tr>
                                                <td></td>
                                                <td>
                                                    <asp:CheckBox ID="PolypTumourAssessCheckBox" runat="server" Text="Polyp/Tumour Assessment" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EMRCheckBox" runat="server" Text="EMR" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="StentReplacementCheckBox" runat="server" Text="Stent replacement" />
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="NGTubeInsertionCheckBox" runat="server" Text="NG Tube Insertion" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="NGTubeRemovalCheckBox" runat="server" Text="NG Tube Removal" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="BarrettsCheckBox" runat="server" Text="Barrett's Oesophagus surveillance" />
                                                </td>
                                                <td colspan="1"></td>

                                            </tr>

                                            <tr id="EnteroscopyPlannedProceduresRow" runat="server" visible="false">
                                                <td colspan="4">
                                                    <div style="float: left;">
                                                        <asp:CheckBox ID="SingleBalloonEnteroscopyCheckBox" runat="server" Text="Single balloon enteroscopy" />
                                                        <br />
                                                        <asp:CheckBox ID="DoubleBalloonEnteroscopyCheckBox" runat="server" Text="Double balloon enteroscopy (push-pull enteroscopy)" />
                                                        <br />
                                                        <asp:CheckBox ID="InsertionOfPhProbeEnteroscopyCheckBox" runat="server" Text="Insertion of pH probe" />
                                                        <br />
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr style="height: 8px;">
                                                <td></td>
                                            </tr>
                                            <tr class="rptSummaryText10">
                                                <td colspan="4">Other :&nbsp;&nbsp;
                                                    <telerik:RadTextBox ID="OtherPlannedProcedureTextBox" runat="server" Skin="Windows7" Width="400" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView9" runat="server">
                                <div class="multiPageDivTab">
                                    <fieldset id="ColonIndicationFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Clinical indications</legend>
                                                                                <table id="ColonIndicationTable" cellpadding="0" cellspacing="0">

                                            <tr>
                                                <td colspan="4">
                                                    <table cellpadding="8" cellspacing="0">
                                                        <tr id="ColonScreeningTR" runat="server">
                                                            <td id="ColonScreeningTD" runat="server">
                                                                <asp:CheckBox ID="ColonScreeningCheckBox" runat="server" Text="screening colonoscopy(family history)" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonBowelCancerCheckBox" runat="server" Text="bowel cancer screening programme" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonFOBTCheckBox" runat="server" Text="FOBT" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonFITCheckBox" runat="server" Text="FIT positive" Visible="false" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonIndicationSurveillanceCheckbox" runat="server" Text="Surveillance" Visible="false" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-left: 5px" colspan="4">
                                                                <label>
                                                                Altered bowel habit</label>
                                                                <telerik:RadComboBox ID="ColonAlterBowelRadComboBox" runat="server" Width="270px" Skin="Windows7" Style="margin-left: 5px;" />&nbsp;
                                                                <asp:CheckBox ID="NationalBowelScopeScreeningCheckBox" runat="server" Text="National Bowel Scope Screening" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-left: 5px" colspan="4">
                                                                <label>
                                                                Rectal bleeding</label>
                                                                <telerik:RadComboBox ID="ColonRectalRadComboBox" runat="server" Width="270px" Skin="Windows7" Style="margin-left: 27px;" />
                                                                <asp:CheckBox ID="ColonLeadingToHaematemesisCheckBox" runat="server" Text="Leading to haematemesis?" />

                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td colspan="4">
                                                    <table cellpadding="4" cellspacing="0">
                                                        <tr>
                                                            <%--Row 1--%>
                                                            <td>
                                                                <asp:CheckBox ID="ColonAbdominalMassCheckBox" runat="server" Text="Abdominal mass" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonDefaecationDisorder" runat="server" Text="Defaecation disorder" />
                                                            </td>
                                                            <td>
                                                                
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonRaisedFaecalCalprotectinCheckBox" runat="server" Text="Raised Faecal Calprotectin" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <%--Row 2--%>
                                                            <td>
                                                                <asp:CheckBox ID="ColonAbdominalPainCheckBox" runat="server" Text="Abdominal pain" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonAbnormalCTScanCheckBox" runat="server" Text="Abnormal CT scan" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonColonicObstructionCheckBox" runat="server" Text="Colonic obstruction" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonTumourAssessmentCheckBox" runat="server" Text="Tumour assessment" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <%--Row 3--%>
                                                            <td>
                                                                <asp:CheckBox ID="ColonAbnormalBariumEnemaCheckBox" runat="server" Text="Abnormal barium enema" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonAbnormalSigmoidoscopyCheckBox" runat="server" Text="Abnormal sigmoidoscopy" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonMelaenaCheckBox" runat="server" Text="Melaena" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ColonWeightLossCheckBox" runat="server" Text="Weight loss" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td valign="top" style="width: 325px; padding-left: 3px; padding-top: 2px;">
                                                    <asp:CheckBox ID="ColonAnamemiaCheckBox" runat="server" Text="Anaemia" />
                                                    <telerik:RadComboBox ID="ColonAnaemiaRadComboBox" runat="server" Width="120px" Skin="Windows7" Style="display: none">
                                                        <Items>
                                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                                            <telerik:RadComboBoxItem Text="Unspecified" Value="1" />
                                                            <telerik:RadComboBoxItem Text="Microcytic" Value="2" />
                                                            <telerik:RadComboBoxItem Text="Normocytic" Value="3" />
                                                            <telerik:RadComboBoxItem Text="Macrocytic" Value="4" />
                                                        </Items>
                                                    </telerik:RadComboBox>
                                                </td>
                                                <td></td>
                                                <td valign="top" style="width:130px;">
                                                    <asp:CheckBox ID="PolyposisSyndromeCheckBox" runat="server" Text="Polyposis syndrome" />
                                                </td>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="cUrgentCheckBox" runat="server"
                                                                    Text="Urgent two week referral"
                                                                    onchange="cToggleUrgentDiv(true);" CssClass="UrgentCheckBox" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="text-align: right;" class="rptSummaryText10">
                                                                <label>
                                                                Cancer&nbsp;&nbsp;</label>
                                                                <telerik:RadComboBox ID="ColonCancerRadComboBox" runat="server" Width="100" Skin="Windows7">
                                                                    <Items>
                                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                                        <telerik:RadComboBoxItem Text="Definite" Value="1" />
                                                                        <telerik:RadComboBoxItem Text="Suspected" Value="2" />
                                                                        <telerik:RadComboBoxItem Text="Excluded" Value="3" />
                                                                    </Items>
                                                                </telerik:RadComboBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="text-align: right;">
                                                                <div id="cUrgentDiv" runat="server" style="margin-left: 5px;">
                                                                    <label>
                                                                    Performance Status&nbsp;&nbsp;</label>
                                                                    <telerik:RadTextBox ID="cWhoPerformanceStatusTextBox" runat="server" Skin="Windows7" Width="30" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr class="rptSummaryText10">
                                                <td colspan="4">
                                                    <table>
                                                        <tr>
                                                            <td>Other :&nbsp;&nbsp;</td>
                                                            <td>Clinically important comments :&nbsp;&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 20px;">
                                                                <telerik:RadTextBox ID="ColonOtherRadTextBox" runat="server" Skin="Windows7" Width="300px" TextMode="MultiLine" Height="55" />
                                                            </td>
                                                            <td>
                                                                <telerik:RadTextBox ID="ColonImportantCommentsRadTextBox" runat="server" Skin="Windows7" Width="350px"
                                                                    TextMode="MultiLine" Height="55" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>                                      
                                        </table>
                                    </fieldset>
                                    <fieldset id="ColonProceduresFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Planned Procedures</legend>
                                        <table id="ColonPlannedTable" cellspacing="0" cellpadding="0" class="checkboxesTable">
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="ColonStentRemovalCheckBox" runat="server" Text="Stent removal" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ColonStentInsertionCheckBox" runat="server" Text="Stent insertion" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ColonStentReplacementCheckBox" runat="server" Text="Stent replacement" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ColonPolypTumourAssessCheckBox" runat="server" Text="Polyp/Tumour Assessment" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ColonEMRCheckBox" runat="server" Text="EMR" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ColonPlannedPolypectomy" runat="server" Text="Polypectomy" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="IBDSprayCheckbox" runat="server" Text="IBD dye spray surveillance" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="ERCPRadPageView5" runat="server">
                                <div class="multiPageDivTab">
                                    <fieldset id="Fieldset3" runat="server" class="otherDataFieldset">
                                        <legend>Clinical indications</legend>
                                        <table id="ERSIndicationTable" cellpadding="0" cellspacing="0" style="border-spacing: 20px 5px;">
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="ERSAbdominalPainCheckBox" runat="server" Text="Abdominal pain" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSJaundiceCheckBox" runat="server" Text="Jaundice" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSPapillaryDysfunctionCheckBox" runat="server" Text="Papillary dysfunction" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="ERSAbnormalEnzymesCheckBox" runat="server" Text="Abnormal enzymes" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSObstructedCBDCheckBox" runat="server" Text="Obstructed CBD/CHD" CssClass="jag-audit-control" /> <img src="../../../../Images/NEDJAG/JAGNED.png" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSPrelaparoscopicCheckBox" runat="server" Text="Pre-laparoscopic cholecystectomy" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="ERSAcutePancreatitisAcuteCheckBox" runat="server" Text="Acute pancreatitis" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSCBDStonesCheckBox" runat="server" Text="CBD stones" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSPriSclerosingCholCheckBox" runat="server" Text="Primary sclerosing cholangitis" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="ERSBileDuctInjuryCheckBox" runat="server" Text="Bile duct injury" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSOpenAccessCheckBox" runat="server" Text="Open access" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSSphincterCheckBox" runat="server" Text="Sphincter of Oddi dysfunction" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="ERSBiliaryLeakCheckBox" runat="server" Text="Biliary leak" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSChronicPancreatisisCheckBox" runat="server" Text="Chronic pancreatitis" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSStentOcclusionCheckBox" runat="server" Text="Stent occlusion" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="ERSCholangitisCheckBox" runat="server" Text="Cholangitis" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSRecurrentPancreatitisCheckBox" runat="server" Text="Recurrent pancreatitis" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSSuspectedPapillaryCheckBox" runat="server" Text="Suspected papillary stenosis" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="ERSPurulentCholangitisCheckBox" runat="server" Text="Purulent cholangitis" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSPancreaticPseudocystCheckBox" runat="server" Text="Pancreatic pseudocyst" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ERSPancreatobiliaryPainCheckBox" runat="server" Text="Pancreatobiliary pain" />
                                                </td>
                                            </tr>
                                            <tr>
                                                

                                                <td>
                                                    <table>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="ERSUrgentCheckBox" runat="server" Text="Urgent two week referral" onchange="eToggleUrgentDiv(true);" CssClass="UrgentCheckBox" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="rptSummaryText10">
                                                                <div style="margin-left: 10px; margin-bottom: 3px;">
                                                                    Cancer&nbsp;&nbsp;
                                                                    <telerik:RadComboBox ID="ERSCancerRadComboBox" runat="server" Width="100" Skin="Windows7">
                                                                        <Items>
                                                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                                                            <telerik:RadComboBoxItem Text="Definite" Value="1" />
                                                                            <telerik:RadComboBoxItem Text="Suspected" Value="2" />
                                                                            <telerik:RadComboBoxItem Text="Excluded" Value="3" />
                                                                        </Items>
                                                                    </telerik:RadComboBox>
                                                                </div>
                                                                <div id="eUrgentDiv" runat="server" style="margin-left: 10px;">
                                                                    WHO Performance Status&nbsp;&nbsp;
                                                                    <telerik:RadTextBox ID="ERSWHOPerformanceRadTextBox" runat="server" Skin="Windows7" Width="30" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EUSCysticLesion" runat="server" Text="Cystic Lesion" />
                                                    
                                                </td>
                                            </tr>
                                            <tr class="rptSummaryText10">
                                                <td colspan="3">
                                                    <table>
                                                        <tr>
                                                            <td>Other :&nbsp;&nbsp;</td>
                                                            <td>Clinically important comments :&nbsp;&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 20px;">
                                                                <telerik:RadTextBox ID="ERSOtherRadTextBox" runat="server" Skin="Windows7" Width="300px" TextMode="MultiLine" Height="55" />
                                                            </td>
                                                            <td>
                                                                <telerik:RadTextBox ID="ERSImportantCommentsRadTextBox" runat="server" Skin="Windows7" Width="350px"
                                                                    TextMode="MultiLine" Height="55" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                         </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="ERCPRadPageView9" runat="server">
                                <div class="multiPageDivTab">
                                    <fieldset id="Fieldset4" runat="server" class="otherDataFieldset">
                                        <legend>Planned Procedures</legend>
                                        <table id="ERSPlannedTable" cellspacing="0" cellpadding="0" class="checkboxesTable" style="border-spacing: 20px 5px;">
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="EPlanCanunulateCheckBox" runat="server" Text="Cannulate and opacify the biliary tree" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EplanManometryCheckBox" runat="server" Text="Manometry" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EplanStentremovalCheckBox" runat="server" Text="Stent removal" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="EplanCombinedProcedureCheckBox" runat="server" Text="Combined procedure(Rendezvous)" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EplanNasoPancreaticCheckBox" runat="server" Text="Naso-pancreatic/biliary drains" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EplanStentReplacementCheckBox" runat="server" Text="Stent replacement" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="EPlanEndoscopicCystCheckBox" runat="server" Text="Endoscopic cyst puncture" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EplanPapillotomyCheckBox" runat="server" Text="Papillotomy/sphincterotomy" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EplanStoneRemovalCheckBox" runat="server" Text="Stone removal" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="EplanPolypTumourAssessCheckBox" runat="server" Text="Polyp/Tumour Assessment" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EplanStentInsertionCheckBox" runat="server" Text="Stent insertion" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EplanStrictureDilatationCheckBox" runat="server" Text="Stricture dilatation" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="EplanEMRCheckBox" runat="server" Text="EMR" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="Microlithiasis" runat="server" Text="Exclude Microlithiasis" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="FNACheckbox" runat="server" Text="FNA" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="FNBCheckbox" runat="server" Text="FNB" />
                                                </td>
                                            </tr>
                                            <tr class="rptSummaryText10">
                                                <td colspan="4">Other :&nbsp;&nbsp;
                                                    <telerik:RadTextBox ID="EplanOthersTextBox" runat="server" Skin="Windows7" Width="400" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView1" runat="server">
                                <div class="multiPageDivTab">
                                    <fieldset id="CoMorbidityFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Co-morbidity</legend>
                                        <table id="checkboxesTables" cellspacing="0" cellpadding="0" class="checkboxesTable">
                                            <tr>
                                                <td style="width: 140px;">
                                                    <asp:CheckBox ID="CoMorbidityNoneCheckbox" runat="server" Text="None" />
                                                </td>
                                                <td style="width: 200px;">
                                                    <asp:CheckBox ID="CopdCheckBox" runat="server" Text="COPD" />
                                                </td>
                                                <td style="width: 200px;">
                                                    <asp:CheckBox ID="HemiparesisPostStrokeCheckBox" runat="server" Text="Hemiparesis post stroke" />
                                                </td>
                                                <td style="width: 150px;">
                                                    <asp:CheckBox ID="ObesityCheckBox" runat="server" Text="Obesity" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="AnginaCheckBox" runat="server" Text="Angina" />
                                                </td>
                                                <td style="height: 23px;">
                                                    <asp:CheckBox ID="DiabetesMellitusCheckBox" runat="server" Text="Diabetes Mellitus"
                                                        onchange="ToggleDiabetesTypeComboBox();" />
                                                    <telerik:RadComboBox ID="DiabetesMellitusTypeComboBox" runat="server" Width="80" Skin="Windows7"
                                                        Style="margin-left: 5px;">
                                                        <%--<Items>
                                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                                            <telerik:RadComboBoxItem Text="Unknown" Value="1" />
                                                            <telerik:RadComboBoxItem Text="Type I" Value="2" />
                                                            <telerik:RadComboBoxItem Text="Type II" Value="3" />
                                                        </Items>--%>
                                                    </telerik:RadComboBox>
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="HypertensionCheckBox" runat="server" Text="Hypertension" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="TiaCheckBox" runat="server" Text="TIA" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="AsthmaCheckBox" runat="server" Text="Asthma" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="EpilepsyCheckBox" runat="server" Text="Epilepsy" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="MICheckBox" runat="server" Text="MI" />
                                                </td>
                                            </tr>
                                            <tr style="height: 8px;">
                                                <td></td>
                                            </tr>
                                            <tr class="rptSummaryText10">
                                                <td colspan="5" style="width: 70px; vertical-align: top;">Other :&nbsp;&nbsp;
                                                    <telerik:RadTextBox ID="OtherCoMorbidityTextBox" runat="server" Skin="Windows7" Width="600"
                                                    TextMode="MultiLine" Height="80" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                    <fieldset id="AsaStatusFieldset" runat="server" class="otherDataFieldset">
                                        <legend>ASA Physical Status Classification</legend>
                                        <div id="asadiv">
                                            <asp:RadioButtonList ID="AsaStatusRadioButtonList" runat="server"
                                                CellSpacing="1" CellPadding="1" RepeatDirection="Vertical" RepeatLayout="Table">
                                                <asp:ListItem Value="0" Text="Not assessed"></asp:ListItem>
                                                <asp:ListItem Value="1" Text="<b>ASA I</b> - Patient is normal and healthy"></asp:ListItem>
                                                <asp:ListItem Value="2" Text="<b>ASA II</b> - Patient has mild systemic disease"></asp:ListItem>
                                                <asp:ListItem Value="3" Text="<b>ASA III</b> - Patient has severe systemic disease"></asp:ListItem>
                                                <asp:ListItem Value="4" Text="<b>ASA IV</b> - Patient has severe systemic disease that is a constant threat to life"></asp:ListItem>
                                                <asp:ListItem Value="5" Text="<b>ASA V</b> - Patient is moribund and is not expected to survive without the procedure/operation"></asp:ListItem>
                                            </asp:RadioButtonList>
                                        </div>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView2" runat="server">
                                <div id="MedicationsDiv" class="multiPageDivTab">
                                    <fieldset id="MedicationFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Medication/allergies</legend>
                                        <telerik:RadAjaxPanel runat="server" ClientEvents-OnResponseEnd="MedicationsTab">
                                            <table cellspacing="1" cellpadding="1">

                                                <tr>
                                                    <td width="200px">
                                                        <label>
                                                        Potential significant drugs:&nbsp;&nbsp;</label>
                                                        </td>
                                                    <td>

                                                         <telerik:RadComboBox ID="DamagingDrugsComboBox" runat="server" CheckBoxes="true" EnableCheckAllItemsCheckBox="true" 
                                                                Width="298" Skin="Windows7"/>

                                                        <%--<telerik:RadComboBox  ID="DamagingDrugsComboBox" runat="server" Width="294px" Skin="Windows7"
                                                        Style="margin-left: 5px;" Height="22px" />--%>

                                                        <telerik:RadButton ID="AddButton" runat="server" Text="Add" Skin="WebBlue" OnClick="AddButton_Click" ButtonType="SkinnedButton" Style="margin-left: 5px;"/>
                                                        <%--  <telerik:RadButton ID="CurrentRXButton" runat="server" Text="Current Rx..." Skin="WebBlue"/>--%></td>
                                                </tr>
                                                <tr>
                                                    <td/>
                                                    <td>
                                                        <telerik:RadTextBox ID="DamagingDrugsMultiTextBox" runat="server" Skin="Windows7" Width="353px"
                                                     TextMode="MultiLine" Height="80px" MaxLength="65000" ForeColor="red" />
                                                    </td>
                                                </tr>
                                                <tr class="rptSummaryText10">
                                                    <td colspan="2">
                                                        Is the patient taking anti-coagulant or anti-platelet medication?    
                                                        <asp:RadioButtonList ID="AntiCoagRadioButtonList" runat="server" Style="display: inline; vertical-align:middle" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="2">
                                                            <asp:ListItem Text="No" Value="0" />
                                                            <asp:ListItem Text="Yes" Value="1" />
                                                        </asp:RadioButtonList>

                                                    </td>
                                                </tr>
                                            </table>
                                        </telerik:RadAjaxPanel>
                                    </fieldset>
                                    <fieldset id="AllergiesFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Allergies</legend>
                                        <table cellspacing="1" cellpadding="1">
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="AllergyUnknownRadioButton" runat="server" Text="Unknown" GroupName="AllergyRadioButtonList"
                                                        onchange="ToggleAllergyDescTextBox();" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="AllergyNoneRadioButton" runat="server" Text="None" GroupName="AllergyRadioButtonList"
                                                        onchange="ToggleAllergyDescTextBox();" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="AllergyYesRadioButton" runat="server" Text="Yes" GroupName="AllergyRadioButtonList"
                                                        onchange="ToggleAllergyDescTextBox();" />
                                                </td>
                                                <td>
                                                    <telerik:RadTextBox ID="AllergyDescTextBox" runat="server" Skin="Windows7" Width="400" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView3" runat="server">
                                <div id="FollowUpDiv" class="multiPageDivTab">
                                    <fieldset id="FollowingUpSurgeryFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Previous Surgery</legend>
                                        <table>
                                            <tr>
                                                <td>
                                                    <telerik:RadComboBox ID="SurgeryFollowUpProcComboBox" runat="server" Skin="Windows7" Width="220"
                                                        Style="margin-right: 5px;" />
                                                    <telerik:RadComboBox ID="SurgeryFollowUpProcPeriodComboBox" runat="server" Skin="Windows7" Width="220"
                                                        Style="margin-right: 5px;">
                                                        <Items>
                                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                                            <telerik:RadComboBoxItem Text="within the last month" Value="1" />
                                                            <telerik:RadComboBoxItem Text="one to two months ago" Value="2" />
                                                            <telerik:RadComboBoxItem Text="three to four months ago" Value="3" />
                                                            <telerik:RadComboBoxItem Text="five to six months ago" Value="4" />
                                                            <telerik:RadComboBoxItem Text="seven to twelve months ago" Value="5" />
                                                            <telerik:RadComboBoxItem Text="one to three years ago" Value="6" />
                                                            <telerik:RadComboBoxItem Text="more than three years ago" Value="7" />
                                                            <telerik:RadComboBoxItem Text="unknown" Value="8" />
                                                        </Items>
                                                    </telerik:RadComboBox>
                                                    <telerik:RadButton ID="SurgeryFollowUpAddButton" runat="server" Text="Add" Skin="WebBlue" ButtonType="SkinnedButton"
                                                        AutoPostBack="false" OnClientClicked="BuildSurgeryFollowUpText" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <telerik:RadTextBox ID="SurgeryFollowUpTextBox" runat="server" Skin="Windows7" TextMode="MultiLine"
                                                        Width="502" Height="80" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                    <fieldset id="FollowingUpDiseaseFieldset" runat="server" class="otherDataFieldset">
                                        <legend>Previous Diseases/Procedures</legend>
                                        <table class="rptSummaryText10">
                                            <tr>
                                                <td>Previous:
                                                </td>
                                                <td>
                                                    <telerik:RadComboBox ID="DiseaseFollowUpProcComboBox" runat="server" Skin="Windows7" Width="200px" Style="margin-right: 5px;" />
                                                    (procedure)
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Carried out:
                                                </td>
                                                <td>
                                                    <telerik:RadComboBox ID="DiseaseFollowUpProcPeriodComboBox" runat="server" Skin="Windows7" Width="200" >
                                                       <%-- <Items>
                                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                                            <telerik:RadComboBoxItem Text="within the last month" Value="1" />
                                                            <telerik:RadComboBoxItem Text="one to two months ago" Value="2" />
                                                            <telerik:RadComboBoxItem Text="three to four months ago" Value="3" />
                                                            <telerik:RadComboBoxItem Text="five to six months ago" Value="4" />
                                                            <telerik:RadComboBoxItem Text="seven to twelve months ago" Value="5" />
                                                            <telerik:RadComboBoxItem Text="one to three years ago" Value="6" />
                                                            <telerik:RadComboBoxItem Text="more than three years ago" Value="7" />
                                                            <telerik:RadComboBoxItem Text="unknown" Value="8" />
                                                        </Items>--%>
                                                    </telerik:RadComboBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4">
                                                    <table cellspacing="0" cellpadding="0" class="checkboxesTable">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="BarrettsOesophagusCheckBox" runat="server" Text="Barrett's oesophagus" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="DysplasiaCheckBox" runat="server" Text="Dysplasia" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="MalignancyCheckBox" runat="server" Text="Malignancy" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="OesophagealVaricesCheckBox" runat="server" Text="Oesophageal varices" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="UlcerHealingCheckBox" runat="server" Text="Ulcer healing" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="CoeliacDiseaseCheckBox" runat="server" Text="Coeliac disease" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="GastritisCheckbox" runat="server" Text="Gastritis" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="OesophagealDilatationFollowUpCheckBox" runat="server" Text="Oesophageal dilatation" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="OesophagitisCheckBox" runat="server" Text="Oesophagitis" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="ColonFollowingUpRadPageView" runat="server">
                                <div id="ColonFollowUpDiv" class="multiPageDivTab">
                                    <fieldset id="Fieldset2" runat="server" class="otherDataFieldset">
                                        <legend>Previous diseases</legend>
                                        <table class="rptSummaryText10">
                                            <tr>
                                                <td>
                                                    <telerik:RadComboBox ID="ColonFollowUpLeftRadComboBox" runat="server" Skin="Windows7" Width="200"
                                                        Style="margin-right: 5px;" AppendDataBoundItems="False" />
                                                    <telerik:RadComboBox ID="ColonFollowUpRightRadComboBox" runat="server" Skin="Windows7" Width="200"
                                                        Style="margin-right: 5px;">
                                                        <Items>
                                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                                            <telerik:RadComboBoxItem Text="within the last month" Value="1" />
                                                            <telerik:RadComboBoxItem Text="one to two months ago" Value="2" />
                                                            <telerik:RadComboBoxItem Text="three to four months ago" Value="3" />
                                                            <telerik:RadComboBoxItem Text="five to six months ago" Value="4" />
                                                            <telerik:RadComboBoxItem Text="seven to twelve months ago" Value="5" />
                                                            <telerik:RadComboBoxItem Text="one to three years ago" Value="6" />
                                                            <telerik:RadComboBoxItem Text="more than three years ago" Value="7" />
                                                            <telerik:RadComboBoxItem Text="unknown" Value="8" />
                                                        </Items>
                                                    </telerik:RadComboBox>
                                                    <telerik:RadButton ID="ColonFollowUpAddRadButton" runat="server" Text="Add" Skin="WebBlue" ButtonType="SkinnedButton"
                                                        AutoPostBack="false" OnClientClicked="cBuildSurgeryFollowUpText" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <telerik:RadTextBox ID="ColonFollowUpRadTextBox" runat="server" Skin="Windows7" TextMode="MultiLine"
                                                        Width="500" Height="80" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <td style="padding-right: 150px">
                                                                <label>
                                                                    <b>I.B.D</b></label></td>
                                                            <td style="padding-right: 150px">
                                                                <asp:CheckBox ID="ColonFamilyCheckBox" runat="server" Text="Family history taken/known" />
                                                            </td>
                                                            <td>
                                                                <label>
                                                                    <b>Previous:</b></label></td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">
                                                                <asp:CheckBox ID="ColonAssessmentCheckBox" runat="server" Text="Assessment" />
                                                                <br />
                                                                <asp:CheckBox ID="ColonSurveillanceCheckBox" runat="server" Text="Surveillance" />
                                                                <div id="ibddiv" runat="server" style="display: none">
                                                                    <asp:RadioButton ID="ColonUnspecifiedRadioButton" runat="server" Text="unspecified" GroupName="Assess" />
                                                                    <br />
                                                                    <asp:RadioButton ID="ColonCrohnRadioButton" runat="server" Text="Crohn's Disease" GroupName="Assess" />
                                                                    <br />
                                                                    <asp:RadioButton ID="ColonUlcerativeRadioButton" runat="server" Text="Ulcerative Colitis" GroupName="Assess" />
                                                                </div>
                                                            </td>
                                                            <td valign="top">
                                                                <div id="familydiv" runat="server" style="display: none">
                                                                    <asp:RadioButton ID="ColonRiskRadioButton" runat="server" Text="risk unknown" GroupName="family" />
                                                                    <br />
                                                                    <asp:RadioButton ID="ColonNoRiskRadioButton" runat="server" Text="no risk" GroupName="family" />
                                                                    <br />
                                                                    <asp:RadioButton ID="ColonFamilialRadioButton" runat="server" Text="familial adenomatous polyposis" GroupName="family" />
                                                                    <br />
                                                                    <asp:RadioButton ID="ColonHistoryRadioButton" runat="server" Text="family history of colorectal cancer(unspecified)" GroupName="family" />
                                                                    <br />
                                                                    <asp:RadioButton ID="ColonHereditoryRadioButton" runat="server" Text="hereditary non-polyposis colorectal cancer(HNPCC)" GroupName="family" />
                                                                    <br />
                                                                    <asp:RadioButton ID="ColonHnpccRadioButton" runat="server" Text="HNPCC gene carrier" GroupName="family" />
                                                                    <br />
                                                                    <label>
                                                                    Additional text:(</label>
                                                                    <telerik:RadTextBox ID="ColonAdditionalRadTextBox" runat="server" Skin="Windows7" TextMode="MultiLine" Width="300px" />
                                                                    <label>
                                                                        )</label>
                                                                </div>
                                                            </td>
                                                            <td valign="top">
                                                                <asp:CheckBox ID="ColonCarcinomaCheckBox" runat="server" Text="Carcinoma" />
                                                                <br />
                                                                <asp:CheckBox ID="ColonPolypsCheckBox" runat="server" Text="Polyps" />
                                                                <br />
                                                                <asp:CheckBox ID="ColonDysplasiaCheckBox" runat="server" Text="Dysplasia" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="ERCPRadPageView4" runat="server">
                                <div id="ERSImagingDiv" class="multiPageDivTab">
                                    <fieldset id="Fieldset1" runat="server" class="otherDataFieldset">
                                        <legend>Imaging</legend>
                                        <table id="ImagingTable" class="rptSummaryText10">
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <td class="inputSpacing">
                                                                <asp:CheckBox ID="UltrasoundCheckBox" runat="server" Text="Ultrasound" CssClass="inputSpacing" />
                                                                <asp:CheckBox ID="CTCheckBox" runat="server" Text="CT" CssClass="inputSpacing" />
                                                                <asp:CheckBox ID="MRICheckBox" runat="server" Text="MRI" CssClass="inputSpacing" />
                                                                <asp:CheckBox ID="MRCPCheckBox" runat="server" Text="MRCP" CssClass="inputSpacing" />
                                                                <asp:CheckBox ID="IDACheckBox" runat="server" Text="IDA - isotope scan" CssClass="inputSpacing" />
                                                                <asp:CheckBox ID="EUSCheckBoxe" runat="server" Text="EUS" />
                                                            </td>

                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <fieldset style="width: 680px;">
                                                        <table>
                                                            <tr>
                                                                <td>
                                                                    <asp:CheckBox ID="ERSNormalCheckBox" runat="server" Text="Normal" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table id="imgTable" style="border-spacing: 20px 5px;">

                                                                        <tr>
                                                                            <td>
                                                                                <asp:CheckBox ID="AmpullaryMassCheckBox" runat="server" Text="ampullary mass" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSFluidCollectionCheckBox" runat="server" Text="fluid collection" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSHepaticMassCheckBox" runat="server" Text="hepatic mass" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSChronicPancreatitisCheckBox" runat="server" Text="chronic pancreatitis" />
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <asp:CheckBox ID="BiliaryLeakCheckBox" runat="server" Text="biliary leak" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSGallBladderMassCheckBox" runat="server" Text="gall bladder mass" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSPancreaticMassCheckBox" runat="server" Text="pancreatic mass" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSStonedBiliaryCheckBox" runat="server" Text="stone(s) in biliary tree" />
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSDilatedPancreaticCheckBox" runat="server" Text="dilated pancreatic duct" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSGallBladderPolypCheckBox" runat="server" Text="gall bladder polyp" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSObstructedCheckBox" runat="server" Text="Obstructed CBD/CHD" CssClass="jag-audit-control" /> <img src="../../../../Images/NEDJAG/JAGNED.png" />

                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="CysticLesionCheckBox" runat="server" Text="cystic lesion"/> 
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSDilatedDuctsCheckBox" runat="server" Text="dilated bile ducts" onclick="javascript:DilatedBileClicked($(this))" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSGallBladderCheckBox" runat="server" Text="gall bladder stones" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="ERSAcutePancreatitisCheckBox" runat="server" Text="acute pancreatitis" />
                                                                            </td>
                                                                            <td></td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td id="DilatedDuctsTD" colspan="2" style="display: none">
                                                                                <fieldset>
                                                                                    <asp:CheckBox ID="ERSDilatedDuctType1" runat="server" Text="extrahepatic" CssClass="inputSpacing" />
                                                                                    <asp:CheckBox ID="ERSDilatedDuctType2" runat="server" Text="intrahepatic" />
                                                                                    <%--<asp:CheckBoxList ID="ERSDilatedDuctType" runat="server">
                                                                                        <asp:ListItem Text="extrahepatic" Value="1" />
                                                                                        <asp:ListItem Text="intrahepatic" Value="2" />
                                                                                    </asp:CheckBoxList>--%>
                                                                                </fieldset>
                                                                            </td>
                                                                            <td></td>
                                                                            <td></td>
                                                                            <td></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>

                                                            <tr class="rptSummaryText10">
                                                                <td colspan="4">Other :&nbsp;&nbsp;
                                                                    <telerik:RadTextBox ID="ERSImgOthersTextBox" runat="server" Skin="Windows7" Width="400" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </fieldset>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="ERCPRadPageView6" runat="server">
                                <div id="ERSFollowUpDiv" class="multiPageDivTab">
                                    <fieldset id="Fieldset6" runat="server" class="otherDataFieldset">
                                        <legend>Previous History</legend>
                                        <table id="ERSFolloupTable" class="rptSummaryText10" cellpadding="6">
                                            <tr>
                                                <td>Previous:
                                                </td>
                                                <td>
                                                    <telerik:RadComboBox ID="ERSPreviousRadComboBox" runat="server" Skin="Windows7" Width="200" Style="margin-right: 5px;" />
                                                    (procedure)
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Carried out:
                                                </td>
                                                <td>
                                                    <telerik:RadComboBox ID="ERSCarriedOutRadComboBox" runat="server" Skin="Windows7" Width="200">
                                                        <%--<Items>
                                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                                            <telerik:RadComboBoxItem Text="within the last month" Value="1" />
                                                            <telerik:RadComboBoxItem Text="one to two months ago" Value="2" />
                                                            <telerik:RadComboBoxItem Text="three to four months ago" Value="3" />
                                                            <telerik:RadComboBoxItem Text="five to six months ago" Value="4" />
                                                            <telerik:RadComboBoxItem Text="seven to twelve months ago" Value="5" />
                                                            <telerik:RadComboBoxItem Text="one to three years ago" Value="6" />
                                                            <telerik:RadComboBoxItem Text="more than three years ago" Value="7" />
                                                            <telerik:RadComboBoxItem Text="unknown" Value="8" />
                                                        </Items>--%>
                                                    </telerik:RadComboBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4">
                                                    <table cellspacing="0" cellpadding="0" class="checkboxesTable">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="ERSBileDuctCheckBox" runat="server" Text="Bile duct stone(s)" CssClass="inputSpacing" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ERSMalignancyCheckBox" runat="server" Text="Malignancy" CssClass="inputSpacing" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ERSBiliaryStrictureCheckBox" runat="server" Text="Biliary stricture" CssClass="inputSpacing" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="ERSStentReplacementCheckBox" runat="server" Text="Stent replacement" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>
                </div>
            </telerik:RadAjaxPanel>
        </telerik:RadPane>
        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" OnClientClicking="validateControls" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
            <div style="height:0px; display:none">
                <telerik:RadButton ID="SaveOnly" runat="server" Text="Save" Skin="Web20" OnClick="SaveOnly_Click" style="height:1px; width:1px" />
            </div>        
        </telerik:RadPane>
    </telerik:RadSplitter>
    <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False"
        Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move">
        <Windows>
            <telerik:RadWindow ID="WHOStatusPickerWindow" runat="server" ReloadOnShow="true"
                KeepInScreenBounds="true" Width="700px" Height="230px" Title="WHO Performance Status" VisibleStatusbar="false" Animation="Fade">
                <ContentTemplate>
                    <div class="rptSummaryText10" style="margin-left: 5px; margin-top: 10px; padding-bottom: 10px;">
                        <asp:RadioButtonList ID="WHOStatusRadioButtonList" runat="server"
                            CellSpacing="1" CellPadding="1" RepeatDirection="Vertical" RepeatLayout="Table" CssClass="whoRadioList"
                            onchange="SetWhoStatus();">
                            <asp:ListItem Value="0" Text="<b>0</b> - Fully active, no restrictions on activities"></asp:ListItem>
                            <asp:ListItem Value="1" Text="<b>1</b> - Unable to do strenuous activities, but able to carry out light housework and sedentary activities"></asp:ListItem>
                            <asp:ListItem Value="2" Text="<b>2</b> - Able to walk and manage self-care, but unable to work. Out of bed more than 50% of waking hours"></asp:ListItem>
                            <asp:ListItem Value="3" Text="<b>3</b> - Confined to bed or a chair more than 50% of waking hours. Capable of limited self-cares"></asp:ListItem>
                            <asp:ListItem Value="4" Text="<b>4</b> - Completely disabled. Totally confined to a bed or chair. Unable to do any self-care"></asp:ListItem>
                            <%--<asp:ListItem Value="5" Text="<b>5</b> - Death"></asp:ListItem>--%>
                        </asp:RadioButtonList>
                    </div>
                    <div id="buttonsdiv" style="margin-left: 5px; height: 10px; padding-top: 16px; vertical-align: central;">
                        <telerik:RadButton ID="CloseWhoPickerButton" runat="server" Text="Close" Skin="WebBlue"
                            OnClientClicked="CloseWhoStatusPickerWindow" AutoPostBack="false" />
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>
            <%--<telerik:RadWindow ID="CurrentRXWindow" runat="server" ReloadOnShow="true"
                KeepInScreenBounds="true" Width="700px" Height="300px" Title="Current medication" VisibleStatusbar="false" Animation="Fade">
                <ContentTemplate>
                    <div class="rptSummaryText10" style="margin-left: 5px; margin-top: 10px; padding-bottom: 10px;">
                       <div>
                         <fieldset id="Fieldset1" runat="server">
                                    <legend>Hints:</legend>
                          If the software finds medication that was prescribed in this patient's previous procedure, this will be pulled forward.<br />
                             You can then modify that medication if needed.
                            </fieldset>
</div>
                        <div> 
                            <asp:CheckBox ID="IncluseinReportCheckBox" runat="server" Text ="Include in report" />
                              
                        </div>
                        <div>
                            <telerik:RadButton ID="SetMedicationButton" runat="server" Text="Set medication..." Skin="Web20" OnClick="ShowSetMedicationWindow" />

                        </div><div></div>
                        <div>
                             <telerik:RadTextBox ID="MedicationTextBox" runat="server" Skin="Windows7"  Width="650px" TextMode="MultiLine" Height="90" MaxLength="65000" Enabled ="false" />
                        </div>
                    </div>
                    <div id="buttonsdiv1" style="margin-left: 5px; height: 10px; padding-top: 6px; vertical-align: central;">
                        <telerik:RadButton ID="closeCurrentRXButton" runat="server" Text="Close" Skin="WebBlue" 
                            OnClientClicked="CloseCurrentRXWindow" AutoPostBack="false" />
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>
            <telerik:RadWindow ID="SetMedicationWindow" runat="server" ReloadOnShow="true"
                KeepInScreenBounds="true" Width="700px" Height="300px" Title="Set Current Medication" VisibleStatusbar="false" Animation="Fade">
                <ContentTemplate>
                    <div class="rptSummaryText10" style="margin-left: 5px; margin-top: 10px; padding-bottom: 10px;">
                       <div>
                         <fieldset id="Fieldset2" runat="server">
                          <legend>Hints:</legend>
                             <div style="width: 50%; float:left">
                              To add drug(s) to the list of medication, either choose a regimen and/or double click in the right-hand list of drugs.
                              </div>
                               <div style="width: 50%; float:right">
                                To remove a medication or change the dose details, click in the LEFT hand window then click appropriate button.
                                </div>
                            </fieldset>
                           </div>
                        <div> 
                            <asp:CheckBox ID="CheckBox1" runat="server" Text ="Include in report" />
                              
                        </div>
                        <div>
                            <telerik:RadButton ID="RadButton1" runat="server" Text="Set medication..." Skin="Web20" />

                        </div><div></div>
                        <div>
                             <telerik:RadTextBox ID="RadTextBox1" runat="server" Skin="Windows7"  Width="650px" TextMode="MultiLine" Height="90" MaxLength="65000" Enabled ="false" />
                        </div>
                    </div>
                    <div id="buttonsdiv2" style="margin-left: 5px; height: 10px; padding-top: 6px; vertical-align: central;">
                        <telerik:RadButton ID="RadButton2" runat="server" Text="Close" Skin="WebBlue" 
                            AutoPostBack="false" />
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>--%>
        </Windows>
    </telerik:RadWindowManager>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>
</asp:Content>
