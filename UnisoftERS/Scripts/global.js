var previousSelectedNode = null;
function RefreshPage() {
    location.reload();
}

function GetRadWindow() {

    var oWindow = null;
    if (window.parent.radWindow) {
        oWindow = window.parent.radWindow;
    }
    //else if (window.name.indexOf("RadWindow") > -1) {
    //    oWindow = window;
    //}
    else if (window.frameElement) {
        if (window.frameElement.radWindow) {
            oWindow = window.frameElement.radWindow;
        }
    }
    else if (window.parent.frameElement) {
        if (window.parent.frameElement.radWindow) {
            oWindow = window.parent.frameElement.radWindow;
        }
    }
    return oWindow;
}

function CloseWindow() {
    var oWindow = GetRadWindow();
    oWindow.close();
    //window.close();
    return false;
}

function ClearComboBox(comboboxid) {
    var combo = $find(comboboxid);
    var item = combo.findItemByText("");
    if (item) { item.select(); }
}

function Toggle(chkd, detailsControlId) {
    if (chkd) {
        //$('*[id*=' + detailsControlId + ']').attr("style", "display: block"); 
        $('*[id*=' + detailsControlId + ']').show();
        //$('*[id*=' + detailsControlId + ']').attr("style", "visibility: visible");
    }
    else {
        //$('*[id*=' + detailsControlId + ']').attr("style", "display: none");
        $('*[id*=' + detailsControlId + ']').hide();
        //$('*[id*=' + detailsControlId + ']').attr("style", "visibility: hidden");
        $('*[id*=' + detailsControlId + '] input:text').val('');
    }
}

function ToggleDetails(detailsControlId) {
    Toggle(($(event.target).is(':checked')), detailsControlId);
}

function refreshParent() {
    parent.refreshSummary();

    var urlParams = new URLSearchParams(window.location.search);
    var siteIdParam = urlParams.get('SiteId');

    var parentUrl = new URLSearchParams(parent.location.search);
    parentUrl.set('SiteId', siteIdParam);

    var redirectUrl = parent.location.pathname + '?' + parentUrl.toString();

    parent.location.href = redirectUrl;
    parent.getParentNode();

}

function setRehideSummary() {
    parent.setRehideSummary();

    //var urlParams = new URLSearchParams(window.location.search);
    //var siteIdParam = urlParams.get('SiteId') ?? 0;

    //var parentUrl = new URLSearchParams(parent.location.search);
    //parentUrl.set('SiteId', siteIdParam);

    //var redirectUrl = parent.location.pathname + '?' + parentUrl.toString();

    //parent.location.href = redirectUrl;
    //parent.getParentNode();
    
}

function refreshDiagram() {
    parent.refreshParentWithDiagram();
    
}


function refreshParentEBUS(siteid) {

    var test = parent.location.href;
    test = test.replace("SiteId=-1", "SiteId=" + siteid);
    parent.location.href = test + '&DefaultNav=yes'
   
    // console.log(parent.location.href);

    //parent.location.reload();
}


function getResectionTxt(resid) {
    var res;
    var jsondata = { ResectedColumnID: resid };
    $.ajax({
        type: "POST",
        async: false,
        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Default.aspx/getResectedText",
        data: JSON.stringify(jsondata),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (msg) { res = msg.d; },
    });
    return res;
}


// Add New Item Code - Start
var cbo;
var isCboMultiSelect = false;
var isPreviousSurgery = false;
function AddNewItemPopUp(sender, multiSelect = false, addNew = false) {
    isCboMultiSelect = multiSelect;
    cbo = sender;
    if (cbo !== null && cbo !== undefined) isPreviousSurgery = cbo.id.indexOf('AntiCoagDrugsRadComboBox') == -1 ? true : false; 
    var valArr = isCboMultiSelect == true ? $.map($(cbo).val().split(','), $.trim) : [];
    if ((isCboMultiSelect == false && $(cbo).val() === "Add new") || ((cbo !== null && cbo !== undefined) && cbo.id.indexOf('AntiCoagDrugsRadComboBox') !== -1 && addNew) ||
        (jQuery.inArray("Add new", valArr) != -1 || jQuery.inArray("All items checked", valArr) != -1)) {
        var oWnd = $find(AddNewItemRadWindowClientId);
        if (oWnd != null)
            oWnd.show();
        $("#" + AddNewItemRadTextBoxClientId).val('');
        $("#" + AddNewItemRadTextBoxClientId).focus();
        return false;
    }
}

function CancelAddNewItem() {
    if (cbo != null) {
        var cboControl = $find(cbo.id);
        ClearSelection();
    }
    CloseAddNewItemWindow();
}

function AddNewItem() {
    if (cbo != null) {
        var cboControl = $find(cbo.id);
        var newItemText = $find(AddNewItemRadTextBoxClientId).get_value();

        if (newItemText.trim() != "") {
            var items = cboControl.get_items();
            var comboItemOld = cboControl.findItemByValue(-99);
            var found = false;
            for (var i = 0; i < items.get_count(); i++) {
                var item = items.getItem(i);
                if (item.get_text().toLowerCase() === newItemText.toLowerCase()) {
                    found = true;
                    break;
                }
            }

            if (found) {
                alert('Item already exists!');
                return;
            }

            if (comboItemOld) {
                cboControl.trackChanges();
                items.remove(comboItemOld);
                cboControl.commitChanges();
            }

            var comboItem = new Telerik.Web.UI.RadComboBoxItem();
            comboItem.set_text(newItemText);
            comboItem.set_value(-99);
            cboControl.trackChanges();

            if (isCboMultiSelect == false) {
                items.insert(items.get_count() - 1, comboItem);
                comboItem.select();
            } else {
                var comboItemOld = cboControl.findItemByValue(-55);

                if (comboItemOld) {
                    cboControl.trackChanges();
                    items.remove(comboItemOld);
                    cboControl.commitChanges();
                }
                items.add(comboItem);
                cboControl.get_items().getItem(items.get_count() - 1).set_checked(true);
                isPreviousSurgery == true ? onPSComboClose(cboControl) : saveDamagingDrug(cboControl);
            }
            cboControl.commitChanges();
        }
        else {
            ClearSelection();
        }
    }
    CloseAddNewItemWindow();
}

function CloseAddNewItemWindow() {
    var oWnd = $find(AddNewItemRadWindowClientId);
    if (oWnd != null)
        oWnd.close();
    return false;
}

function AddNewItemWindowClientClose(sender, args) {
    if (cbo != null) {
        var cboControl = $find(cbo.id);
        if (cboControl.get_value() == "-55") {
            ClearSelection();
        }
    }
}

function ClearSelection() {
    var cboControl = $find(cbo.id);
    //cboControl.clearSelection();
    cboControl.trackChanges();

    if (isCboMultiSelect = false) {
        cboControl.get_items().getItem(0).select();
    } else {
        var itemCount = cboControl.get_items().get_count();
        cboControl.get_items().getItem(itemCount-1).set_checked(false);
    }
    cboControl.updateClientState();
    cboControl.commitChanges();
}
// Add New Item Code - End



// Mark tab with a tick mark when any of it's controls' data is altered
function triggerChange(tabId, element, tabstripId) {
    $("#" + element).find("input[type=text], input:checkbox, input:radio, select, textarea").change(function () {
        markTab(tabId, element, tabstripId);
    });
    $("#" + element).find(".riUp, .riDown").click(function () {
        markTab(tabId, element, tabstripId);
    });
}

function markTab(tabId, element, tabstripId) {
    var changed = false;

    $("#" + element).find("input[type=text], select, textarea").each(function () {
        if ($(this).val() != null && $(this).val() != '' && $(this).val() != '0') { changed = true; return false; }
    });
    if ($("#" + element + " input:checkbox:checked, #" + element + " input:radio:checked").length > 0) { changed = true; }

    var tab = $find(tabstripId).findTabByValue(tabId);
    if (tab != null) {
        if (changed) {
            tab.set_imageUrl('../../../../Images/Ok.png');
        } else {
            tab.set_imageUrl("../../../../Images/none.png");
        }
    }
}

function setRequiredField(controlName, controlTitle) {
    var reqField = { control: controlName, fieldName: controlTitle };
    if (reqFields != undefined) {
        if (!reqFields.items.some(e => e.control === controlName)) {
            //make Other referreral type a required field
            reqFields.items.push(reqField);
        }
    }
}

function removeRequiredField(controlName, controlTitle) {
    if (reqFields != undefined) {
        var reqField = { control: controlName, fieldName: controlTitle };

        var toRemove = false;
        $(reqFields.items).each(function (ind, itm) {
            if (itm.control == reqField.control) {
                delete reqFields.items.splice(ind, 1);
                $('#' + controlName).removeClass("validation-error-field");
                return;
            }
        });
    }
}

function validatePage(sender, args) {     
    if (reqFields != undefined) {
        var invalid = false;
        var errMsg = "";
        var isCysto = true;
        var pageName = meWho.split("_").slice(-2).join('_');
        var cystoControlName = 'BodyContentPlaceHolder_patientview_ImageGenderID';
        for (var i = 0; i <= reqFields.items.length - 1; i++) {            
            var obj = reqFields.items[i];
            var control = obj.control;
            var fieldName = obj.fieldName;
            
            if (control == '') {
                continue;
            }           
           
            if ($find(control) != null) { //telerik controls...
                //MH added on 15 Jan 2024 - TFS 2612
                isCysto = true;
                var ctrl = $find(control);                
                if (fieldName == "consultant") {
                    var consultantId = parseInt($(ctrl.get_element()).val());

                    if (isNaN(consultantId) || Number.isInteger(consultantId) == false) {
                        invalid = true;
                        errMsg += "Required field " + fieldName + " you must select a consultant from the list<br />";
                        ctrl.addCssClass('validation-error-field');
                        $('#BodyContentPlaceHolder_patientview_referringConsultantTd').addClass('validation-error-field');
                    }
                    else {
                        ctrl.removeCssClass('validation-error-field');
                        $('#BodyContentPlaceHolder_patientview_referringConsultantTd').removeClass('validation-error-field');
                    }
                }

                else if ((fieldName == "Procedure") && (ctrl._originalText != 'Cystoscopy')) {
                    isCysto = false;                    
                }   
                
                else {                  
                    if ($(ctrl.get_element()).val() == "") {
                        invalid = true;
                        errMsg += "Required field " + fieldName + " is empty<br />";
                        ctrl.addCssClass('validation-error-field');
                        if (pageName == "barrettepithelium_aspx") { barretValidationMessage = errMsg; } 
                    }
                    else {
                        ctrl.removeCssClass('validation-error-field');
                    }
                    
                }
            }

            else if ($('#' + control + ' input[type=radio]')[0] != undefined || $('#' + control + ' input[type=checkedbox]')[0] != undefined) { //check if control is radiobuttons or a checkbox
                if (($('#' + control + ' input:checked').val() == undefined) && (isCysto)) {
                    invalid = true;
                    errMsg += "Required field " + fieldName + " not specified<br />";
                    $('#' + control).addClass('validation-error-input');
                }
                else {
                    $('#' + control).removeClass('validation-error-input');

                }
            }
            else if ($('#' + control + ' input').val() != undefined) { //... otherwise will be a textbox
                if ($('#' + control + ' input').val() == "") {
                    invalid = true;
                    errMsg += "Required field " + fieldName + " not specified<br />";
                    $('#' + control).addClass('validation-error-field');
                }
                else {
                    $('#' + control).removeClass('validation-error-field');

                }
            }
            else if ($('#' + control).val() != undefined) {
                if ($('#' + control).val() == "") {
                    invalid = true;
                    errMsg += "Required field " + fieldName + " is empty<br />";
                    $('#' + control).addClass('validation-error-field');
                }
                else {
                    $('#' + control).removeClass('validation-error-field');
                }
            }
        }        

        if (pageName == "barrettepithelium_aspx" && invalid) { return false; }
        

        if (invalid && pageName !="barrettepithelium_aspx") {
            if ($find('#masterValDiv')) {
                $('#masterValDiv').html(errMsg);
                $('#ValidationNotification').show();
                $('.validation-modal').show();
            }
            else {
                //create modal for window
                $('#masterValDiv', parent.document).html(errMsg);
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();
            }
            args.set_cancel(true);
        }
        else
            return true;
    }
    else
        return true;
}

function closeNotificationWindow() {
    $('#masterValDiv').html("");
    $('#ValidationNotification').hide();
    $('.validation-modal').hide();
}

function setDNAControls() {
    $('.cancelled-proc-cb input').prop('checked', true);

}

function disableForDNA() {
    $('.footer-button').not('.dna-exempt').each(function () {
        var btnName = $(this).attr('id');
        if (btnName != null) {
            var btn = $find(btnName);
            if (btn != null)
                btn.set_enabled(false);
        }
    });

    $('.diagram-btn').each(function () {
        var btnName = $(this).attr('id');
        if (btnName != null) {
            $find(btnName).set_enabled(false);
        }
    });
}

function buildDateTimeString(_date) {
    //convert both time into timestamp
    var start = new Date(_date);
    var dateString = start.getDate() + '/' + (start.getMonth() + 1) + '/' + start.getFullYear() + ' ' + start.getHours() + ':' + start.getMinutes();

    return dateString;
}

function buildErrorString(errorRef, errorMsg) {
    var err = '';
    err += "<table><tr><td colspan='2' class='aspxValidationSummaryHeader'>" + errorMsg + "</td></tr>";
    err += "<tr><td><br/></td></tr><tr><td colspan='2'>Please contact HD Clinical Helpdesk with the following details.</td></tr>";
    if (errorRef != '') {
        err += "<tr><td style='width:100px'>ErrorReference:</td><td>" + errorRef + "</td></tr>";
    }
    
    err += "</table>"

    return err;
}

//function DisplayProcedureInfo() {
//    var procID = '<%=Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>';
//    var patientID = '<%=Session(UnisoftERS.Constants.SESSION_PATIENT_ID)%>';
//    var appVersion = '<%=Session(UnisoftERS.Constants.SESSION_APPVERSION)%>';
//    var operatingHospital = '<%=Session("OperatingHospitalID")%>';
//    var userID = '<%=Session("UserID")%>';
//    var roomID = '<%=Session("RoomId")%>';
//    var imagePortId = '<%=Session("PortId")%>';
//    var imagePortName = '<%=Session("PortName")%>';
//    alert('App Version: ' + appVersion + '\nPatientID: ' + patientID + '\nProcedureID: ' + procID + '\nOperatingHospital: ' + operatingHospital + '\nUserID: ' + userID + '\nRoomID: ' + roomID + '\nPortId: ' + imagePortId + '\nPortName: ' + imagePortName);
//}

function AddPolypDetailsRadButton_ClientClick(sender, eventArgs) {
    if (sender.id !== undefined && sender.id.indexOf('RemoveEntryLinkButton') !== -1) {
        if ($('.polyp-details-table').length > 1 || ($find('PreviousESDScar_CheckBox').get_checked())) {
            localStorage.setItem('valueChanged', 'true');
        }
        else localStorage.setItem('valueChanged', 'false');
    }
    else if (sender.id === undefined && sender.get_element().id.indexOf('AddPolypDetailsRadButton') !== -1) {
        localStorage.setItem('valueChanged', 'true');
    } else {
        console.log(sender);
    }
}
var dicaScoreRequired = false;
function validateDICAScore() {
    $('.dica-score-dropdown').each(function (idx, itm) {
        var selectedPoints = parseInt($find($(itm)[0].id).get_selectedItem().get_attributes().getAttribute('data-points'));
        var radComboBox = $find($(itm)[0].id);
        var selectedItemElement = radComboBox.get_selectedItem().get_element();
        var hasContent = $(selectedItemElement).text().trim().length > 0;
        if (idx < 2) { //only 1st 2 dropdowns are mandatory
            if (!hasContent) {
                dicaScoreRequired = true;
                localStorage.setItem('validationRequired', 'true');
                validationMessage = 'Please complete DICA scores for diverticulosis extension and qty before continuing';
                localStorage.setItem('validationRequiredMessage', validationMessage);
            }
        }
    });
    if (!dicaScoreRequired) {
        localStorage.setItem('validationRequired', 'false');
        if (validationMessage !== "") localStorage.setItem('validationRequiredMessage', '');
        return true;
    }
    return false;
}
