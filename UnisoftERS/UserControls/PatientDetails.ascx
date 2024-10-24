<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PatientDetails.ascx.vb" Inherits="UnisoftERS.PatientDetails" %>
<telerik:RadScriptBlock ID="rad1" runat="server">
    <style type="text/css">
        #ctl00_ctl00_BodyContentPlaceHolder_PatientDetails_EditStaffWindow_C{
            width: 850px !important;
            height: 365px !important;
        }
    </style>
    <script type="text/javascript">
        var docURL = document.URL;
        var webMethodLocation = docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Default.aspx/";

        function openStaffWindow() {
            var oWnd = $find("<%= EditStaffWindow.ClientID%>");
            oWnd.show();
            setEndoscopistRole();
            ReferralTypeRadComboBoxChanged();
            ProviderTypeComboBoxChanged()
            PatStatusClicked();
            return false;
        }

        function closeStaffWindow() {
            var oWnd = $find("<%= EditStaffWindow.ClientID %>");
            //setTimeout(function () { oWnd.close(); }, 0);

            if (oWnd != null)
                oWnd.close();

            return false;
        }

        function EditStaffClicked() {
            $("#<%= ListConsultantComboBox.ClientID%>").show();
            $("#<%= Endo1ComboBox.ClientID%>").show();
            $("#<%= Endo2ComboBox.ClientID%>").show();
            $("#<%= Nurse1ComboBox.ClientID%>").show();
            $("#<%= Nurse2ComboBox.ClientID%>").show();
            $("#<%= Nurse3ComboBox.ClientID%>").show();
            $("#<%= Nurse4ComboBox.ClientID%>").show();

            $("#<%= ListConsultantLabel.ClientID%>").hide();
            $("#<%= EndoscopistsLabel.ClientID%>").hide();
            $("#<%= NursesLabel.ClientID%>").hide();
        }

        // 1, 'Independent (no trainer)'
        // 2, 'Was observed'
        // 3, 'Was assisted physically'

        function getGMCCode(hiddenControl, userId) {
            $.ajax({
                type: "POST",
                url: webMethodLocation + "GetGMCCode",
                data: JSON.stringify({ userId: parseInt(userId) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d) {
                        //if (data.d.trim() != "")
                        $(hiddenControl).val(data.d);
                    }
                    else {
                        $(hiddenControl).val("");
                    }
                }
            });
        }

        function ListConsultantChanged() {
            //get GMC Code and set hidden variable
            var hiddenField = $('#<%=ListConsultantGMCHiddenField.ClientID%>');
            var userId = $find('<%=ListConsultantComboBox.ClientID%>').get_value();
            getGMCCode(hiddenField, userId);
            setEndoscopist1();
        }

        function Endo1Changed() {
            //get GMC Code and set hidden variable            
            var hiddenField = $('#<%=Endo1GMCHiddenField.ClientID%>');
            var userId = $find('<%=Endo1ComboBox.ClientID%>').get_value();
            // added by rony tfs-4173, Endoscopist 1 value null then show console error fixed
            if ($find('<%=Endo1ComboBox.ClientID%>').get_selectedIndex() == null || $find('<%=Endo1ComboBox.ClientID%>').get_selectedIndex() == "") {
                return false
            } else {
                getGMCCode(hiddenField, userId);
                ddlComparisonValidation("endo");
                setEndoscopistRole();
            }
        }

        function Endo2Changed() {
            //get GMC Code and set hidden variable
            var hiddenField = $('#<%=Endo2GMCHiddenField.ClientID%>');
            var userId = $find('<%=Endo2ComboBox.ClientID%>').get_value();
            // added by rony tfs-4173, Endoscopist 2 value null then show console error fixed
            if ($find('<%=Endo2ComboBox.ClientID%>').get_selectedIndex() == null || $find('<%=Endo2ComboBox.ClientID%>').get_selectedIndex() == "") {
                return false
            } else {
                getGMCCode(hiddenField, userId);
                ddlComparisonValidation("endo");
                setEndoscopistRole();
            }            
        }

        function setEndoscopistRole() {
            var comboEndo1 = $find('<%=Endo1ComboBox.ClientID%>');
            if (comboEndo1 == undefined || comboEndo1 == null || comboEndo1.get_selectedItem() == null) return;
            var comboEndo1Val = comboEndo1.get_selectedItem().get_value();

            var comboEndo2 = $find('<%=Endo2ComboBox.ClientID%>');
            var comboEndo2Val = comboEndo2.get_selectedItem().get_value();
            var comboEndo1Role = $find('<%=Endo1RoleComboBox.ClientID%>');
            var comboEndo1RoleVal = comboEndo1Role.get_selectedItem().get_value();
            var comboEndo2Role = $find('<%=Endo2RoleComboBox.ClientID%>');
            var comboEndo2RoleVal = comboEndo2Role.get_selectedItem().get_value();

            var comboListType = $find('<%=ListTypeComboBox.ClientID%>');
            var comboListTypeVal = comboListType.get_selectedItem().get_value();

            enableComboItems(comboEndo1Role);
            enableComboItems(comboEndo2Role);
            $('#<%=Endoscopist1Label.ClientID%>').html("Endoscopist 1:");
            $('#<%=Endoscopist2Label.ClientID%>').html("Endoscopist 2:");
            if (comboEndo1Val != '' && comboEndo2Val != '') {
                if (comboEndo1Val == comboEndo2Val) {
                    setComboVal(comboEndo1Role, 1); //'Independent (no trainer)'
                    setComboVal(comboEndo2Role, 1); //'Independent (no trainer)'
                    disableComboItems(comboEndo1Role, 4);
                    disableComboItems(comboEndo2Role, 4);
                } else {
                    if (comboListTypeVal == 1) { //ListType is Service List
                        setComboVal(comboEndo1Role, 1); //'Independent (no trainer)'
                        setComboVal(comboEndo2Role, 1); //'Independent (no trainer)'
                        disableComboItems(comboEndo1Role, 4);
                        disableComboItems(comboEndo2Role, 4);
                    } else {
                        setComboVal(comboEndo1Role, 2); //'I observed'
                        setComboVal(comboEndo2Role, 2); //'Was observed'
                        disableComboItems(comboEndo1Role, 2);
                        disableComboItems(comboEndo2Role, 2);
                    }

                    if (comboListTypeVal != 1) { //Do not change Endoscopist labels if ListType is Service List
                        $('#<%=Endoscopist1Label.ClientID%>').html("TrainER:");
                        $('#<%=Endoscopist2Label.ClientID%>').html("TrainEE:");
                    }
                }
            } else {
                if (comboEndo1Val == '') {
                    setComboVal(comboEndo1Role, 0);
                } else {
                    setComboVal(comboEndo1Role, 1); //'Independent (no trainer)'
                }

                if (comboEndo2Val == '') {
                    setComboVal(comboEndo2Role, 0);
                } else {
                    setComboVal(comboEndo2Role, 1); //'Independent (no trainer)'
                }
                disableComboItems(comboEndo1Role, 4);
                disableComboItems(comboEndo2Role, 4);
            }
        }

        var vCounterToExit = 0;

        function changeEndoRole(sender, args) {
            if (vCounterToExit == 1) {
                vCounterToExit = 0;
                return;
            }
            if (sender._uniqueId.indexOf('Endo1') !== -1) {
                vCounterToExit = 1;
                setEndoscopist1RoleChanged();
            } else {
                vCounterToExit = 1;
                setEndoscopist2RoleChanged();
            }
        }

        function setEndoscopist1RoleChanged() {
            var comboEndo1Role = $find('<%=Endo1RoleComboBox.ClientID%>');
            if (comboEndo1Role == undefined || comboEndo1Role == null) return;
            var comboEndo1RoleVal = comboEndo1Role.get_selectedItem().get_value();
            if (comboEndo1RoleVal == null) return;
            var comboEndo2Role = $find('<%=Endo2RoleComboBox.ClientID%>');
            if (comboEndo1RoleVal == 2) {
                setComboVal(comboEndo2Role, 2);
            } else if (comboEndo1RoleVal == 3) {
                setComboVal(comboEndo2Role, 3);
            }
        }

        function setEndoscopist2RoleChanged() {
            var comboEndo1Role = $find('<%=Endo1RoleComboBox.ClientID%>');
            var comboEndo2Role = $find('<%=Endo2RoleComboBox.ClientID%>');
            if (comboEndo2Role == undefined || comboEndo2Role == null) return;
            var comboEndo2RoleVal = comboEndo2Role.get_selectedItem().get_value();
            if (comboEndo2RoleVal == null) return;
            if (comboEndo2RoleVal == 2) {
                setComboVal(comboEndo1Role, 2);
            } else if (comboEndo2RoleVal == 3) {
                setComboVal(comboEndo1Role, 3);
            }
        }

        function setEndoscopist1() {
            var comboListConsultant = $find('<%=ListConsultantComboBox.ClientID%>');
            var comboListConsultantVal = comboListConsultant.get_selectedItem().get_value();
            var comboEndo1 = $find('<%=Endo1ComboBox.ClientID%>');
            var comboEndo1Val = comboEndo1.get_selectedItem().get_value();
            if (comboListConsultantVal != '' && comboEndo1Val == '') {
                setComboVal(comboEndo1, comboListConsultantVal);
            }
        }

        function setComboVal(combo, val) {
            var item = combo.findItemByValue(val);
            item.select();
        }

        function disableComboItems(comboEndoRole, disabledItems) {
            for (var i = 0; i < disabledItems; i++) {
                if (comboEndoRole.get_items().getItem(i).get_checked() == false) {
                    var vItem = comboEndoRole.get_items().getItem(i);
                    vItem.set_enabled(false);
                    vItem.get_element().style.color = "#c2d2e2";
                }
            }
        }

        function enableComboItems(comboEndoRole) {
            for (var i = 0; i < comboEndoRole.get_items().get_count(); i++) {
                if (comboEndoRole.get_items().getItem(i).get_checked() == false) {
                    var vItem = comboEndoRole.get_items().getItem(i);
                    vItem.set_enabled(true);
                    vItem.get_element().style.color = "#1e395b";
                }
            }
        }

        function validateGMCCodes(sender, args) {
            if (validatePage(sender, args)) {
                var listConsultant = $find('<%=ListConsultantComboBox.ClientID%>').get_value();
                var endo1 = $find('<%=Endo1ComboBox.ClientID%>').get_value();
                var endo2 = $find('<%=Endo2ComboBox.ClientID%>').get_value();

                var listConsultantGMC = $('#<%=ListConsultantGMCHiddenField.ClientID%>').val();
                var endo1GMC = $('#<%=Endo1GMCHiddenField.ClientID%>').val();
                var endo2GMC = $('#<%=Endo2GMCHiddenField.ClientID%>').val();

                if (listConsultantGMC == "" || endo1GMC == "" || (endo2 != "" && endo2GMC == "")) {
                    var obj = {};
                    var endoIDs = [];
                    endoIDs.push(parseInt(listConsultant));
                    endoIDs.push(parseInt(endo1));
                    if (endo2 != "") {
                        endoIDs.push(parseInt(endo2));
                    }

                    obj.endoIds = endoIDs;

                    $.ajax({
                        type: "POST",
                        url: webMethodLocation + "CheckGMCCodes",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            if (data.d != "") {
                                var url = docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Common/UpdateGMCCodes.aspx?IDs=" + data.d.join();

                                var oWnd = $find("<%= GMCCodeRadWindow.ClientID %>");
                                oWnd._navigateUrl = url;
                                oWnd.show();
                            }
                        }
                    });
                    args.set_cancel(true);
                }
                else if (listConsultantGMC != "" || endo1GMC != "" || (endo2 != "" && endo2GMC != "")) {
                    var obj = {};
                    var endoIDs = [];
                    var gmcIDs = [];
                    endoIDs.push(parseInt(listConsultant));
                    gmcIDs.push(parseInt(listConsultantGMC));
                    endoIDs.push(parseInt(endo1));
                    gmcIDs.push(parseInt(endo1GMC));
                    if (endo2 != "" && endo2GMC != "") {
                        endoIDs.push(parseInt(endo2));
                        gmcIDs.push(parseInt(endo2GMC));
                    }

                    obj.endoIds = endoIDs;
                    obj.gmcIDs = gmcIDs;
                    $.ajax({
                        type: "POST",
                        url: webMethodLocation + "ValidateGMCCodes",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        async: false,
                        success: function (data) {
                            if (data.d != "") {
                                var url = docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Common/UpdateGMCCodes.aspx?IDs=" + data.d.join();

                                var oWnd = $find("<%= GMCCodeRadWindow.ClientID %>");
                                oWnd._navigateUrl = url;
                                oWnd.show();
                                args.set_cancel(true);
                            } else {
                                args.set_cancel(false);
                            }
                        }
                    });
                }
            }
        }

        function updateGMC(arg) {
            //set with any values as this function wouldn't have been reached if GMC codes weren't updated
            var listConsultantGMC = $('#<%=ListConsultantGMCHiddenField.ClientID%>').val("updated");
             var endo1GMC = $('#<%=Endo1GMCHiddenField.ClientID%>').val("updated");
             var endo2GMC = $('#<%=Endo2GMCHiddenField.ClientID%>').val("updated");
        }

        function ddlComparisonValidation(sender) {
            if (sender == "endo") {
                var endo1 = $find('<%=Endo1ComboBox.ClientID%>').get_value();
                var endo2 = $find('<%=Endo2ComboBox.ClientID%>').get_value();
                if (endo1 == endo2) {
                    alert("Endoscopist 1 and Endoscopist 2 must not match.");
                    $find('<%=Endo1ComboBox.ClientID%>').clearSelection();

                }
            }
        }
        function nurse1DropDown(sender, eventArgs) {
            var b = $find('<%=Nurse2ComboBox.ClientID %>');
            var c = $find('<%=Nurse3ComboBox.ClientID %>');
            var d = $find('<%=Nurse4ComboBox.ClientID %>');
            var nurse2 = b.get_text();
            var nurse3 = c.get_text();
            var nurse4 = d.get_text();

            var nurse1 = $find('<%=Nurse1ComboBox.ClientID %>');

            var items = nurse1.get_items();
            for (var i = 0; i < items.get_count(); i++) {
                var item = items.getItem(i);
                if (item.get_text() !== '' && (item.get_text() === nurse2 || item.get_text() === nurse3 || item.get_text() === nurse4)) {
                    item.set_visible(false);
                } else {
                    item.set_visible(true);
                }
            }
        }

        function nurse2DropDown(sender, eventArgs) {
            var b = $find('<%=Nurse1ComboBox.ClientID %>');
            var c = $find('<%=Nurse3ComboBox.ClientID %>');
            var d = $find('<%=Nurse4ComboBox.ClientID %>');
            var nurse1 = b.get_text();
            var nurse3 = c.get_text();
            var nurse4 = d.get_text();

            var nurse2 = $find('<%=Nurse2ComboBox.ClientID %>');

            var items = nurse2.get_items();
            for (var i = 0; i < items.get_count(); i++) {
                var item = items.getItem(i);
                if (item.get_text() !== '' && (item.get_text() === nurse1 || item.get_text() === nurse3 || item.get_text() === nurse4)) {
                    item.set_visible(false);
                }
                else {
                    item.set_visible(true);
                }
            }
        }

        function nurse3DropDown(sender, eventArgs) {
            var b = $find('<%=Nurse1ComboBox.ClientID %>');
            var c = $find('<%=Nurse2ComboBox.ClientID %>');
            var d = $find('<%=Nurse4ComboBox.ClientID %>');
            var nurse1 = b.get_text();
            var nurse2 = c.get_text();
            var nurse4 = d.get_text();

            var nurse3 = $find('<%=Nurse3ComboBox.ClientID %>');

            var items = nurse3.get_items();
            for (var i = 0; i < items.get_count(); i++) {
                var item = items.getItem(i);
                if (item.get_text() !== '' && (item.get_text() === nurse1 || item.get_text() === nurse2 || item.get_text() === nurse4)) {
                    item.set_visible(false);
                } else {
                    item.set_visible(true);
                }
            }
        }

        function nurse4DropDown(sender, eventArgs) {
            var b = $find('<%=Nurse1ComboBox.ClientID %>');
            var c = $find('<%=Nurse2ComboBox.ClientID %>');
            var d = $find('<%=Nurse3ComboBox.ClientID %>');
            var nurse1 = b.get_text();
            var nurse2 = c.get_text();
            var nurse3 = d.get_text();

            var nurse4 = $find('<%=Nurse4ComboBox.ClientID %>');

            var items = nurse4.get_items();
            for (var i = 0; i < items.get_count(); i++) {
                var item = items.getItem(i);
                if (item.get_text() !== '' && (item.get_text() === nurse1 || item.get_text() === nurse2 || item.get_text() === nurse3)) {
                    item.set_visible(false);
                } else {
                    item.set_visible(true);
                }
            }
        }

        function nurse1Validation(sender, eventArgs) {
            var select = sender.get_text();
            if (select != '') {
                var b = $find('<%=Nurse2ComboBox.ClientID %>');
                var c = $find('<%=Nurse3ComboBox.ClientID %>');
                var d = $find('<%=Nurse4ComboBox.ClientID %>');
                var nurse2 = b.get_text();
                var nurse3 = c.get_text();
                var nurse4 = d.get_text();
                if (nurse2 == select) {
                    b.set_text("");
                }
                if (nurse3 == select) {
                    c.set_text("");
                }
                if (nurse4 == select) {
                    d.set_text("");
                }
            }
        }

        function nurse2Validation(sender, eventArgs) {
            var select = sender.get_text();
            if (select != '') {
                var b = $find('<%=Nurse1ComboBox.ClientID %>');
                var c = $find('<%=Nurse3ComboBox.ClientID %>');
                var d = $find('<%=Nurse4ComboBox.ClientID %>');
                var nurse1 = b.get_text();
                var nurse3 = c.get_text();
                var nurse4 = d.get_text();
                if (nurse1 == select) {
                    b.set_text("");
                }
                if (nurse3 == select) {
                    c.set_text("");
                }
                if (nurse4 == select) {
                    d.set_text("");
                }
            }
        }

        function nurse3Validation(sender, eventArgs) {
            var select = sender.get_text();
            if (select != '') {
                var b = $find('<%=Nurse1ComboBox.ClientID %>');
                var c = $find('<%=Nurse2ComboBox.ClientID %>');
                var d = $find('<%=Nurse4ComboBox.ClientID %>');
                var nurse1 = b.get_text();
                var nurse2 = c.get_text();
                var nurse4 = d.get_text();
                if (nurse1 == select) {
                    b.set_text("");
                }
                if (nurse2 == select) {
                    c.set_text("");
                }
                if (nurse4 == select) {
                    d.set_text("");
                }
            }
        }

        function nurse4Validation(sender, eventArgs) {
            var select = sender.get_text();
            if (select != '') {
                var b = $find('<%=Nurse1ComboBox.ClientID %>');
                var c = $find('<%=Nurse2ComboBox.ClientID %>');
                var d = $find('<%=Nurse3ComboBox.ClientID %>');
                var nurse1 = b.get_text();
                var nurse2 = c.get_text();
                var nurse3 = d.get_text();
                if (nurse1 == select) {
                    b.set_text("");
                }
                if (nurse2 == select) {
                    c.set_text("");
                }
                if (nurse3 == select) {
                    d.set_text("");
                }
            }
        }

        function ProviderTypeComboBoxChanged() {
            var providerType = $find("<%= ServiceProviderRadComboBox.ClientID %>").get_text()
            if (providerType.toLowerCase().indexOf("other") > -1) {
                $('.other-provider-input').show();
                setRequiredField('<%= OtherProviderRadTextBox.ClientID %>', 'other provider type');
            }
            else { //other trust, bscp
                $('.other-provider-input').hide();
                removeRequiredField('<% =OtherProviderRadTextBox.ClientID %>', 'other provider type');
                $find('<%=OtherProviderRadTextBox.ClientID %>').clear()
            }
        }

        function ReferralTypeRadComboBoxChanged() {
            var referralType = $find("<%= ReferralTypeRadComboBox.ClientID %>").get_text()
            if (referralType.toLowerCase() == "gp" || referralType.toLowerCase() == "") {
                $('.other-type-input').hide();

                if (reqFields != undefined) {

                    //remove other referreral type as a required field
                    removeRequiredField('<%=OtherReferrerTypeTextBox.ClientID%>', 'other referrer type');

                    //remove referring consulant controls as required fields
                    removeRequiredField('<%=ConsultantComboBox.ClientID%>', 'consultant');
                    removeRequiredField('<%=SpecialityRadComboBox.ClientID%>', 'speciality');
                    removeRequiredField('<%=HospitalComboBox.ClientID%>', 'hospital');

                    //make referreral type a required field
                    setRequiredField('<%=ReferralTypeRadComboBox.ClientID%>', 'referrer type');
                }


                $find('<%=OtherReferrerTypeTextBox.ClientID %>').clear()
                $('.referral-consultant-row').hide();

            }
            else {
                if (referralType.toLowerCase() == 'other') {
                    $('.other-type-input').show();
                    setRequiredField('<%=OtherReferrerTypeTextBox.ClientID%>', 'other referrer type');

                    //remove referring consulant controls as required fields
                    removeRequiredField('<%=ConsultantComboBox.ClientID%>', 'consultant');
                    removeRequiredField('<%=SpecialityRadComboBox.ClientID%>', 'speciality');
                    removeRequiredField('<%=HospitalComboBox.ClientID%>', 'hospital');
                    $('.referral-consultant-row').hide();
                }
                else { //own trust, bscp
                    $('.referral-consultant-row').show();
                    setRequiredField('<%=ConsultantComboBox.ClientID%>', 'consultant');
                    setRequiredField('<%=SpecialityRadComboBox.ClientID%>', 'speciality');
                    setRequiredField('<%=HospitalComboBox.ClientID%>', 'hospital');

                    $('.other-type-input').hide();
                    removeRequiredField('<%=OtherReferrerTypeTextBox.ClientID%>', 'other referrer type');
                    $find('<%=OtherReferrerTypeTextBox.ClientID %>').clear()
                }
            }
        }

        function ConsultantChanged(sender, args) {
            var slyCombo = $find("<%= SpecialityRadComboBox.ClientID %>");
            var sly = args.get_dataItem().GroupName;
            if (sly == null || sly == 'null' || sly == '') {
                slyCombo.findItemByText('').select();
            } else {
                var chkSlyVal = slyCombo.findItemByText(sly);
                if (chkSlyVal == null || chkSlyVal == 'null') {
                    slyCombo.findItemByText('').select();
                } else {
                    chkSlyVal.select();
                }
            }

            var hplCombo = $find("<%= HospitalComboBox.ClientID %>");
            var hplcnt = hplCombo.get_items().get_count();
            var hpl = args.get_dataItem().Hospital;
            if (hpl == '(All hospitals)' && hplcnt == 2) {
                hplCombo.trackChanges();
                hplCombo.get_items().getItem(1).select();
                hplCombo.commitChanges();
            } else if (hpl == null || hpl == 'null' || hpl == '' || hpl == '(All hospitals)' || hpl == '(Unspecified)' || hpl == '(Multiple hospitals)') {
                hplCombo.findItemByText('').select();
            } else {
                var chkHospVal = hplCombo.findItemByText(hpl);
                if (chkHospVal == null || chkHospVal == 'null') {
                    hplCombo.findItemByText('').select();
                } else {
                    chkHospVal.select();
                }
            }
        }

        function PatStatusClicked() {
            var checked_radio = $("#<%= PatStatusRadioButtonList.ClientID%> input:checked");
            var text = checked_radio.closest("td").find("label").html();
            if (text != undefined && text != null) {
                ToggleWard(text);
            }
        }

        var validateWard;
        function ToggleWard(selectedText) {
            var wardDiv = $("#<%= PatientWardCell.ClientID%>");
            <%If Not CBool(Session("isERSViewer")) Then%>

            if ((selectedText != null) && (selectedText.indexOf("Inpatient") > -1)) {
                wardDiv.show();
                validateWard = true;
            }
            else {
                wardDiv.hide();
                validateWard = false;
                $find('<%=WardComboBox.ClientID%>').clearSelection();
            }
            <%End If%>
        }

        function setCategoryOptions(sender, args) {
            var divName = sender.get_text().substring(0, 4);
            $("[id*='divCategory_']").hide();  //## Hide all three option sets.. Unhide them later as per request!
            if ($.inArray(divName.toLowerCase(), ['emer', 'open', 'elec']) >= 0) {
                $("[id*='divCategory_" + divName + "']").show();
            }
        }

    </script>
</telerik:RadScriptBlock>

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
<table id="PatientDetailsTable" runat="server" cellspacing="0" cellpadding="0" style="margin-left: 10px; height: 120px;">
    <tr style="vertical-align: top; color: black;">
        <td style="width: 440px; border-right: 1px solid #c2d2e2;">
            <table cellpadding="1" cellspacing="1">
                <tr>
                    <td style="font-weight: bold;">Name:</td>
                    <td>
                        <asp:Label ID="PatientName" runat="server" Text="Not available" Font-Bold="true" /></td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Hospital no:</td>
                    <td>
                        <asp:Label ID="CNN" runat="server" Text="Not available" /></td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="NHSNoAvailableLabel" runat="server" Text="NHS no:" Font-Bold="True"/></td>
                    <td>
                        <asp:Label ID="NHSNo" runat="server" Text="Not available" /></td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Date of birth:</td>
                    <td>
                        <asp:Label ID="DOB" runat="server" Text="Not available" /></td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Record created:</td>
                    <td>
                        <asp:Label ID="RecCreated" runat="server" Text="Not available" /></td>
                </tr>
            </table>
        </td>
        <td style="padding-left: 10px; vertical-align: central;">
            <table id="StaffTable" runat="server" cellpadding="2" cellspacing="2">
                <tr>
                    <td style="font-weight: bold;">List consultant:</td>
                    <td>
                        <asp:Label ID="ListConsultantLabel" runat="server" Text="Not available" />
                    </td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Endoscopists:</td>
                    <td>
                        <asp:Label ID="EndoscopistsLabel" runat="server" Text="Not available" />
                    </td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Nurses:</td>
                    <td>
                        <asp:Label ID="NursesLabel" runat="server" Text="Not available" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <telerik:RadButton ID="EditStaffButton" runat="server" Text="Edit Staff" Skin="Office2007"
                            AutoPostBack="false" OnClientClicked="openStaffWindow" Icon-PrimaryIconUrl="~/Images/icons/edit_staff.png" />
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<telerik:RadWindowManager ID="EditStaffWindowManager" runat="server" ShowContentDuringLoad="false"
    Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true" VisibleStatusbar="false" ZIndex="12345" Width="720">
    <%--need to have enough width, as sometimes the Role combo box gets pushed to the next line--%>
    <Windows>
        <telerik:RadWindow ID="GMCCodeRadWindow" runat="server" Title="GMC Code required"
            Width="550px" MinHeight="250px" ReloadOnShow="true" ShowContentDuringLoad="false"
            Modal="true" VisibleStatusbar="false" Skin="Metro" Behaviors="Close">
        </telerik:RadWindow>
        <telerik:RadWindow ID="EditStaffWindow" runat="server" VisibleOnPageLoad="false" ShowContentDuringLoad="false" KeepInScreenBounds="true" Width="700px" Height="400px" Title="Edit Staff" VisibleStatusbar="false">
            <ContentTemplate>
                <div class="rptSummaryText10" style="margin-left: 5px; margin-top: 10px; padding-bottom: 10px;">
                    <%--Added by rony tfs-4108--%>
                    <div style="float:right; font-size: small; text-align: right;">
                        <img src="~/Images/NEDJAG/Mand.png" runat="server" />Mandatory&nbsp;&nbsp;<img src="~/Images/NEDJAG/NED.png" runat="server" />National Data Set Requirement&nbsp;&nbsp;<img src="~/Images/NEDJAG/JAG.png" runat="server" />JAG Requirement
                    </div>
                    <table>
                        <tr>
                            <td style="width: 120px; white-space: nowrap;">
                                &nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="ImagePortLabel" runat="server" Text="Image Port:" />
                            </td>
                            <td colspan="3">
                                <telerik:RadComboBox ID="ImagePortComboBox" runat="server" Skin="Metro" ZIndex="12345" Width="120px" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="5" style="border-bottom:1pt dashed #B8CBDE"></td>
                        </tr>
                        <tr>
                            <td style="width: 120px; white-space: nowrap;">
                                <img src="~/Images/NEDJAG/NED.png" alt="NED Field" runat="server"/>&nbsp;<asp:Label ID="ServiceProviderLabel" runat="server" Text="Service Provider:" />
                            </td>
                            <td colspan="3">
                                <telerik:RadComboBox ID="ServiceProviderRadComboBox" runat="server" Skin="Windows7" ZIndex="12345" OnClientSelectedIndexChanged="ProviderTypeComboBoxChanged"/>
                                <span class="other-provider-input" style="display: none;">
                                    <img src="~/Images/NEDJAG/Ned.png" alt="Mandatory Field" runat="server" />&nbsp;Other:&nbsp;
                                    <telerik:RadTextBox ID="OtherProviderRadTextBox" runat="server" Skin="Metro" RenderMode="Lightweight" />
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 120px; white-space: nowrap;">
                                <img src="~/Images/NEDJAG/NED.png" alt="NED Field" runat="server"/>&nbsp;<asp:Label ID="ReferralTypeLabel" runat="server" Text="Referral Type:" />
                            </td>
                            <td colspan="3">
                                <telerik:RadComboBox ID="ReferralTypeRadComboBox" runat="server" Skin="Windows7" ZIndex="12345" OnClientSelectedIndexChanged="ReferralTypeRadComboBoxChanged"/>
                                <span class="other-type-input" style="display: none;">
                                    <img src="~/Images/NEDJAG/Ned.png" alt="Mandatory Field" runat="server" />&nbsp;Other:&nbsp;
                                    <telerik:RadTextBox ID="OtherReferrerTypeTextBox" runat="server" Skin="Metro" />
                                </span>
                            </td>
                        </tr>
                        <tr class="referral-consultant-row" style="display: none;">
                            <td>
                                <img src="~/Images/NEDJAG/Mand.png" alt="Mandatory Field" runat="server"/>&nbsp;Referring Consultant:
                            </td>
                            <td style="padding-left: 2px;">
                                <img src="~/Images/NEDJAG/Mand.png" alt="Mandatory Field" runat="server" />&nbsp;Speciality:
                            </td>
                            <td style="padding-left: 2px;">
                                <img src="~/Images/NEDJAG/Mand.png" alt="Mandatory Field" runat="server" />&nbsp;Referring Hospital:
                            </td>
                        </tr>
                        <tr class="referral-consultant-row" style="display: none;">
                            <td>
                                <div class="left" style="float: right;">
                                    <telerik:RadMultiColumnComboBox runat="server" ID="ConsultantComboBox" Skin="Metro" SelectionBoxesVisibility="Hidden" AutoPostBack="false"
                                        Height="300px" DropDownWidth="600px" Width="100%"
                                        Filter="contains" FilterFields="FullName, GroupName, Hospital"
                                        DataTextField="FullName" DataValueField="ConsultantID">
                                        <ColumnsCollection>
                                            <telerik:MultiColumnComboBoxColumn Field="FullName" Title="Referring Consultant" />
                                            <telerik:MultiColumnComboBoxColumn Field="GroupName" Title="Speciality" />
                                            <telerik:MultiColumnComboBoxColumn Field="Hospital" Title="Referring Hospital" />
                                        </ColumnsCollection>
                                        <ClientEvents OnSelect="ConsultantChanged" />
                                    </telerik:RadMultiColumnComboBox>
                                </div>
                            </td>
                            <td style="padding-left: 2px;">
                                <div class="left">
                                    <telerik:RadComboBox ID="SpecialityRadComboBox" runat="server" Skin="Windows7" Width="250px" AutoPostBack="false" Enabled="True" ShowToggleImage="True" ZIndex="12345" />
                                </div>
                            </td>
                            <td style="padding-left: 2px;">
                                <div class="left">
                                    <telerik:RadComboBox ID="HospitalComboBox" runat="server" Skin="Windows7" Width="200px" OnSelectedIndexChanged="HospitalChanged" AutoPostBack="false" ZIndex="12345" />
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <img src="~/Images/NEDJAG/NED.png" alt="NED Field" runat="server"/>&nbsp;Patient Status:
                            </td>
                            <td>
                                <asp:RadioButtonList ID="PatStatusRadioButtonList" runat="server" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="4" onclick="javascript:PatStatusClicked();" />
                            </td>
                            <td id="PatientWardCell" class="ward-input" runat="server" style="display: none">
                                <div class="left">
                                    &nbsp;Ward:&nbsp;
                                    <telerik:RadComboBox ID="WardComboBox" runat="server" Skin="Windows7" Width="120" Filter="StartsWith" ZIndex="12345"></telerik:RadComboBox>                                  &nbsp;
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 120px; white-space: nowrap;">
                                <img src="~/Images/NEDJAG/NED.png" alt="NED Field" runat="server"/>&nbsp;<asp:Label ID="PatientTypeLabel" runat="server" Text="Patient Type:" />
                            </td>
                            <td colspan="3">
                                <div class="left">
                                    <asp:RadioButtonList ID="PatientTypeRadioButtonList" runat="server" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="4" />
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 120px; white-space: nowrap;">
                                <img src="~/Images/NEDJAG/NED.png" alt="NED Field" runat="server"/>&nbsp;<asp:Label ID="CategoryLabel" runat="server" Text="Category:" />
                            </td>
                            <td colspan="3">
                                <div class="left">
                                    <telerik:RadComboBox ID="CategoryRadComboBox" runat="server" Skin="Windows7" AutoPostBack="false" OnClientSelectedIndexChanged="setCategoryOptions" ZIndex="12345" />
                                </div>
                                <div id="divCategory_Emergency" style="padding-left: 20px; float: left; height: 22px; display: none;">
                                    <asp:RadioButtonList ID="rblEmergencyNedCatOption" runat="server" Skin="Windows7" RepeatColumns="2" RepeatDirection="Horizontal">
                                        <asp:ListItem Value="1" Selected="True">in</asp:ListItem>
                                        <asp:ListItem Value="2">out of hours</asp:ListItem>
                                    </asp:RadioButtonList>
                                </div>
                                <div id="divCategory_OpenAccess" style="padding-left: 20px; float: left; height: 22px; display: none;">
                                    <asp:RadioButtonList ID="rblOpenAccessCatOption" runat="server" Skin="Windows7" RepeatColumns="2" RepeatDirection="Horizontal">
                                        <asp:ListItem Value="1" Selected="True">OGD</asp:ListItem>
                                        <asp:ListItem Value="2">col/sig</asp:ListItem>
                                    </asp:RadioButtonList>
                                </div>
                                <div id="divCategory_Elective" style="padding-left: 20px; float: left; display: none;">
                                    <asp:CheckBox ID="chkElectiveNED" runat="server" Text="On waiting list" TextAlign="Right" Checked="true" />
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4">
                                &nbsp;
                            </td>
                        </tr>
                    </table>
                    <table>
                        <tr>
                            <td colspan="5" style="border-bottom:1pt dashed #B8CBDE"></td>
                        </tr>
                        <tr>
                            <td style="width: 120px; white-space: nowrap;">
                                <img src="~/Images/NEDJAG/NED.png" alt="NED Field" runat="server"/>&nbsp;<asp:Label ID="ListTypeLabel" runat="server" Text="List type:" /></td>
                            <td>
                                <telerik:RadComboBox ID="ListTypeComboBox" runat="server" Skin="Windows7" ZIndex="12345" OnClientSelectedIndexChanged="setEndoscopistRole" />
                            </td>
                            <td style="width: 50px; white-space: nowrap;">
                                <img src="~/Images/NEDJAG/NED.png" alt="NED Field" runat="server"/>&nbsp;<asp:Label ID="Nurse1Label" runat="server" Text="Nurse 1:" />
                            </td>
                            <td>
                                <telerik:RadComboBox ID="Nurse1ComboBox" runat="server" OnClientSelectedIndexChanged="nurse1Validation" Width="130" Skin="Windows7" ZIndex="12345"  OnClientDropDownOpening="nurse1DropDown"/>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 120px; white-space: nowrap;">
                                &nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="Label1" runat="server" Text="List consultant:" /></td>
                            <td>
                                <telerik:RadComboBox ID="ListConsultantComboBox" runat="server" Skin="Windows7" ZIndex="12345" OnClientSelectedIndexChanged="ListConsultantChanged" />
                                <asp:HiddenField ID="ListConsultantGMCHiddenField" runat="server" />
                            </td>
                            <td>
                                <img src="~/Images/NEDJAG/NED.png" alt="NED Field" runat="server"/>&nbsp;<asp:Label ID="Nurse2Label" runat="server" Text="Nurse 2:" /></td>
                            <td>
                                <telerik:RadComboBox ID="Nurse2ComboBox" runat="server" OnClientSelectedIndexChanged="nurse2Validation" Width="130" Skin="Windows7" ZIndex="12345" OnClientDropDownOpening="nurse2DropDown" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <img src="~/Images/NEDJAG/JAGNED.png" alt="NED Field" runat="server"/>&nbsp;<asp:Label ID="Endoscopist1Label" runat="server" Text="Endoscopist 1:" />
                            </td>
                            <td>
                                <telerik:RadComboBox ID="Endo1ComboBox" runat="server" Skin="Windows7" ZIndex="12345" OnClientSelectedIndexChanged="Endo1Changed" />
                                <telerik:RadComboBox ID="Endo1RoleComboBox" runat="server" Skin="Windows7" ForeColor="#669900" ZIndex="12345" OnClientSelectedIndexChanged="changeEndoRole" />
                                <asp:HiddenField ID="Endo1GMCHiddenField" runat="server" />
                            </td>
                            <td>
                                <asp:Label ID="Nurse3Label" runat="server" Text="Assistant/Nurse&nbsp;3:" /></td>
                            <td>
                                <telerik:RadComboBox ID="Nurse3ComboBox" OnClientSelectedIndexChanged="nurse3Validation" runat="server" Width="130" Skin="Windows7" ZIndex="12345" OnClientDropDownOpening="nurse3DropDown"/>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                &nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="Endoscopist2Label" runat="server" Text="Endoscopist 2:" /></td>
                            <td>
                                <telerik:RadComboBox ID="Endo2ComboBox" runat="server" Skin="Windows7" ZIndex="12345" OnClientSelectedIndexChanged="Endo2Changed" />
                                <telerik:RadComboBox ID="Endo2RoleComboBox" runat="server" Skin="Windows7" ForeColor="#669900" ZIndex="12345" OnClientSelectedIndexChanged="changeEndoRole" />
                                <asp:HiddenField ID="Endo2GMCHiddenField" runat="server" />
                            </td>
                            <td>
                                <asp:Label ID="Nurse4Label" runat="server" Text="Trainee:" /></td>
                            <td>
                                <telerik:RadComboBox ID="Nurse4ComboBox" OnClientSelectedIndexChanged="nurse4Validation" runat="server" Width="130" Skin="Windows7" ZIndex="12345" OnClientDropDownOpening="nurse4DropDown"/>
                            </td>
                        </tr>
                        <tr>
                            <td style="height: 5px;"></td>
                        </tr>
                        <tr>
                            <td colspan="4">
                                <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                    <span style="float: left">
                                        <telerik:RadButton ID="SaveStaffButton" runat="server" Text="Save & Close" Skin="WebBlue" ValidationGroup="EditStaff" OnClick="SaveStaffButton_Click" OnClientClicking="validateGMCCodes" Icon-PrimaryIconCssClass="telerikSaveButton" ButtonType="SkinnedButton" />
                                    </span>
                                    <span style="float: left; padding-left: 5px">
                                        <telerik:RadButton ID="CancelStaffButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="closeStaffWindow" ButtonType="SkinnedButton"
                                            Icon-PrimaryIconCssClass="telerikCloseButton" />
                                    </span>
                                    <span style="float: left; padding-left: 25px">
                                        <asp:RequiredFieldValidator ID="Endo1RequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                            ControlToValidate="Endo1ComboBox" EnableClientScript="true" Display="Static"
                                            ErrorMessage="Endoscopist 1 is required" Text="- Endoscopist 1 is required." ToolTip="This is a required field"
                                            ValidationGroup="EditStaff">
                                        </asp:RequiredFieldValidator>
                                        <%--Added by rony tfs-4173 additional add nurse 1 validation--%>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" CssClass="aspxValidator"
                                            ControlToValidate="Nurse1ComboBox" EnableClientScript="true" Display="Static"
                                            ErrorMessage="Nurse 1 is required" Text="- Nurse 1 is required." ToolTip="This is a required field"
                                            ValidationGroup="EditStaff">
                                        </asp:RequiredFieldValidator>
                                    </span>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>
        </telerik:RadWindow>
        <telerik:RadWindow ID="AddNewConsultantRadWindow" runat="server" Title="Add consultant"
            Width="525px" Height="700px" ReloadOnShow="true" ShowContentDuringLoad="true"
            Modal="true" VisibleStatusbar="false" Skin="Office2010Blue" Behaviors="Close">
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>