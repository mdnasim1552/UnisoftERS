<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="FindBookSlot.aspx.vb" Inherits="UnisoftERS.FindBookSlot" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../Scripts/global.js"></script>
    <link href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        body {
            font-size: 12px;
        }

        .notification-window {
            background-color: white;
        }

        .SelectedGridRowStyle {
            color: #fff !important;
            background: #25a0da !important;
        }

        .rsArrowBottom {
            display: none !important;
        }
        .rfdSkinnedButton{
            /*display: none !important; */
        }
        #WaitListGrid_GridData{
            height: calc(75vh - 35px) !important;
            overflow:auto;
        }
    </style>
    <telerik:RadScriptBlock ID="sb1" runat="server">
        <script type="text/javascript">
            /*WAITLIST FUNCTIONS*/
            function searchSlotFromWaitlist() {
                $('#<%= btnSearchSlotFromWorklist.ClientID %>').click();
            }

            function searchSlotFromOrder() {
                $('#<%= btnSearchSlotFromOrder.ClientID %>').click();
            }

            function showWorklistDetail() {
                $('#<%= btnShowWorklistDetail.ClientID %>').click();
            }

            function showOrdersDetail() {
                $('#<%= btnShowOrdersDetail.ClientID %>').click();
            }

            function MoveToWorklist() {
                $('#<%= btnMoveToWorklist.ClientID %>').click();
            }

            function waitlistRowSelected(sender, args) {
                $('#<%=WaitlistPatientHiddenField.ClientID%>').val(args.getDataKeyValue("PatientId"));
            }
            function makeSearchButtonsInvisible() {

<%--                $("<%= btnSearchSlotFromWorklist.ClientID %>").set_visible(false);
                $("<%= btnSearchSlotFromOrder.ClientID %>").set_visible(false);
                $("<%= btnShowOrdersDetail.ClientID %>").set_visible(false);
                $("<%= btnShowWorklistDetail.ClientID %>").set_visible(false);
                $("<%= btnMoveToWorklist.ClientID %>").set_visible(false);--%>

                var radButton1 = $('#<%=btnSearchSlotFromWorklist.ClientID%>');
                radButton1.hide();

                var radButton2 = $('#<%=btnSearchSlotFromOrder.ClientID%>');
                radButton2.hide();

                var radButton3 = $('#<%=btnShowOrdersDetail.ClientID%>');
                radButton3.hide();

            }
            function PopUpOrderComms(intOrderId) {
                var width = 1020;
                var height = 820;


                var url = "../EditOrderComms.aspx?OrderId=" + intOrderId + "&fromwaitlist=y"

                //window.open("ViewProcDocPDF.aspx?ProcedureId=" + procedureId + "&ProcedureMaxDate=" + procedureMaxDate + "&ProcedureDocSource=" + procedureDocSource, 'winname', 'directories=0,titlebar=0,toolbar=0,location=0,status=0,menubar=0,top=350,screenY=350,left=550,scrollbars=0,resizable=1,width=600,height=800');
                popupWindow(url, "View OrderComm Report", width, height);

                return false;
            }
            function popupWindow(url, windowName, w, h) {
                var win = window

                const y = win.top.outerHeight / 2 + win.top.screenY - (h / 2);
                const x = win.top.outerWidth / 2 + win.top.screenX - (w / 2);


                return win.open(url, windowName, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width=' + w + ', height=' + h + ', top=' + y + ', left=' + x);
            }
            function showContextMenuWrk(sender, eventArgs) {
                $find('<%= WaitListGrid.ClientID %>').clearSelectedItems();
                var menu = $telerik.findControl(document, "WaitlistRadMenu");
                var evt = eventArgs.get_domEvent();
                if (evt.target.tagName == "INPUT" || evt.target.tagName == "A") {
                    return;
                }

                var rowIndex = eventArgs.get_itemIndexHierarchical();
                var row = $find('<%= WaitListGrid.ClientID %>').get_masterTableView().get_dataItems()[rowIndex];
                row.set_selected(true);
                $('#<%=WaitlistPatientHiddenField.ClientID%>').val(row.getDataKeyValue("PatientId"));
                menu.show(evt);
                evt.cancelBubble = true;
                evt.returnValue = false;

                if (evt.stopPropagation) {
                    evt.stopPropagation();
                    evt.preventDefault();
                }
            }

            function showContextMenuOrd(sender, eventArgs) {
                $find('<%= WaitListGrid.ClientID %>').clearSelectedItems();
                var menu = $telerik.findControl(document, "OrdersRadMenu");
                var evt = eventArgs.get_domEvent();
                if (evt.target.tagName == "INPUT" || evt.target.tagName == "A") {
                    return;
                }

                var rowIndex = eventArgs.get_itemIndexHierarchical();
                var row = $find('<%= OrdersRadGrid.ClientID %>').get_masterTableView().get_dataItems()[rowIndex];
                row.set_selected(true);
                $('#<%=WaitlistPatientHiddenField.ClientID%>').val(row.getDataKeyValue("PatientId"));
                menu.show(evt);
                evt.cancelBubble = true;
                evt.returnValue = false;

                if (evt.stopPropagation) {
                    evt.stopPropagation();
                    evt.preventDefault();
                }
            }

            function waitlistRowSelected(sender, args) {
                $('#<%=WaitlistPatientHiddenField.ClientID%>').val(args.getDataKeyValue("PatientId"));
            }

            function showContextMenuWrk(sender, eventArgs) {
                $find('<%= WaitListGrid.ClientID %>').clearSelectedItems();
                var menu = $telerik.findControl(document, "WaitlistRadMenu");
                var evt = eventArgs.get_domEvent();
                if (evt.target.tagName == "INPUT" || evt.target.tagName == "A") {
                    return;
                }

                var rowIndex = eventArgs.get_itemIndexHierarchical();
                var row = $find('<%= WaitListGrid.ClientID %>').get_masterTableView().get_dataItems()[rowIndex];
                row.set_selected(true);
                $('#<%=WaitlistPatientHiddenField.ClientID%>').val(row.getDataKeyValue("PatientId"));
                menu.show(evt);
                evt.cancelBubble = true;
                evt.returnValue = false;

                if (evt.stopPropagation) {
                    evt.stopPropagation();
                    evt.preventDefault();
                }
            }

            function showContextMenuOrd(sender, eventArgs) {
                $find('<%= WaitListGrid.ClientID %>').clearSelectedItems();
                var menu = $telerik.findControl(document, "OrdersRadMenu");
                var evt = eventArgs.get_domEvent();
                if (evt.target.tagName == "INPUT" || evt.target.tagName == "A") {
                    return;
                }

                var rowIndex = eventArgs.get_itemIndexHierarchical();
                var row = $find('<%= OrdersRadGrid.ClientID %>').get_masterTableView().get_dataItems()[rowIndex];
                row.set_selected(true);
                $('#<%=WaitlistPatientHiddenField.ClientID%>').val(row.getDataKeyValue("PatientId"));
                menu.show(evt);
                evt.cancelBubble = true;
                evt.returnValue = false;

                if (evt.stopPropagation) {
                    evt.stopPropagation();
                    evt.preventDefault();
                }
            }

            function BookAvailableSlot(btn) {
                var diaryId = $(btn).data('diaryid');
                var slotDate = $(btn).data('slotdate');
                var roomId = $(btn).data('roomid');
                var procedureTypeId = $(btn).data('proceduretypeid');
                var slotStatusId = $(btn).data('statusid');
                var bookingMode;// = '<%=Mode%>';
                var hospitalId = $(btn).data('operatinghospital');
                var slotLength = $(btn).data('duration');
                var slotPoints = $(btn).data('points');
                var listSlotId = $(btn).data('listslotid');

                switch ('<%=Mode%>') {
                    case 's':
                        bookingMode = 'search';
                        break;
                    case 'w':
                        bookingMode = 'waitlist';
                        break;
                    case 'm':
                        bookingMode = 'move';
                        break;
                    default:
                        bookingMode = 'add';

                }

                BookSlot(diaryId, slotDate, roomId, procedureTypeId, slotStatusId, bookingMode, hospitalId, slotLength, slotPoints, listSlotId);
            }
            function BookSlot(diaryId, slotDate, roomId, procedureTypeId, slotStatusId, bookingMode, hospitalId, slotLength, slotPoints, listSlotId) {
                var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
                oWnd.setUrl("../PatientBooking.aspx?action=" + bookingMode + "&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&slotPoints=" + slotPoints + "&diaryId=" + diaryId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotId=" + slotStatusId + "&slotLength=" + slotLength + "&listslotid=" + listSlotId);
                oWnd.show();
                closeSlotWindow();
            }

            function bookingSaved() {
                GetRadWindow().BrowserWindow.reloadDiary();
                GetRadWindow().close();
            }

            function CloseAndRebind() {
                GetRadWindow().BrowserWindow.bookingSaved();
                GetRadWindow().close();
            }
            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }

            function RowContextMenu(sender, eventArgs) {
                var menu = $telerik.findControl(document, "RadMenu1");

                var evt = eventArgs.get_domEvent();
                if (evt.target.tagName == "INPUT" || evt.target.tagName == "A") {
                    return;
                }

                var index = eventArgs.get_itemIndexHierarchical();
                document.getElementById("radGridClickedRowIndex").value = index;

                sender.get_masterTableView().selectItem(sender.get_masterTableView().get_dataItems()[index].get_element(), true);

                menu.show(evt);
                evt.cancelBubble = true;
                evt.returnValue = false;

                if (evt.stopPropagation) {
                    evt.stopPropagation();
                    evt.preventDefault();
                }
            }


            $(document).ready(function () {
                $('.define-button').on('click', function () {

                    
                    var procedureType = $(this).attr("data-proc-type");
                    var procedureTypeID = $(this).attr("data-proc-id");

                    var oWnd = $find('<%=ExternalRadWindow.ClientID%>');
                    oWnd.setUrl("../../Options/Scheduler/TherapeuticTypes.aspx?ProcedureType=" + procedureType + "&ProcedureTypeID=" + procedureTypeID + "&mode=search")
                    oWnd.setSize(450, 520);
                    oWnd.show();
                    oWnd.add_close(function () {
                        oWnd.set_title("");
                    });
                    return false;
                });
                //makeSearchButtonsInvisible();
                Sys.Application.add_load(function () {
                    bindEvents();
                });
                
            });

            function bindEvents() {
                $('.slot-filter input[type=checkbox]').on('change', function () {
                    var idVal = $(this).attr("id");

                    if ((($("label[for='" + idVal + "']").text().toLowerCase()) == 'all slots')) {
                        if (($(this).is(':checked')))
                            $('.slot-filter input[type=checkbox]').not('[id="' + idVal + '"]').each(function (index, item) {
                                $(item).prop("checked", false);
                            });
                    }
                    else {
                        if (($(this).is(':checked')))
                            $('#<%=AllSlotsCheckBox.ClientID%>').prop("checked", false);
                    }

                    setBreachDays();
                });


                $('.search-days input[type=checkbox]').on('click', function () {
                    var idVal = $(this).attr("id");
                    var day = $(this).closest('tr').attr('data-day');

                    if ((($("label[for='" + idVal + "']").text().toLowerCase()) == day)) {
                        var isChecked = ($(this).is(":checked"));
                        $('[data-day=' + day + '] input[type=checkbox]').each(function (index, item) {
                            $(item).prop("checked", isChecked);
                        });
                    }
                    else {
                        //count how many checkboxes on that day are checked
                        var checkedCount = 0;

                        $('[data-day=' + day + '] input[type=checkbox]').each(function (index, item) {
                            var ctrlId = $(item).attr("id");
                            if (($("label[for='" + ctrlId + "']").text().toLowerCase()) != day) {
                                if ($(this).is(':checked')) {
                                    checkedCount++;
                                }
                            }

                        });

                        if (checkedCount > 0)
                            $('tr [data-day=' + day + '] input[type=checkbox]').first().prop("checked", true);
                        else
                            $('tr [data-day=' + day + '] input[type=checkbox]').first().prop("checked", false);
                    }
                });

                toggleGIProceduresView($('#<%=SearchGIProcedureRadioButtons.ClientID%> input:checked').val() == "true");
                $('#<%=SearchGIProcedureRadioButtons.ClientID%> input').on('change', function () {
                    toggleGIProceduresView($(this).val().toLowerCase() == "true");
                });

                $('#non-gi-procedure-types input[type=checkbox]').on('click', function () {
                    var idVal = $(this).attr("id");
                    if ((($("label[for='" + idVal + "']").text().toLowerCase()) == "diagnostic")) {
                        $('#<%=LengthOfSlotsNumericTextbox.ClientID%>').val(15);
                    }
                    else {
                        $('#<%=LengthOfSlotsNumericTextbox.ClientID%>').val(45);
                    }
                });

                //$('.procedure-type-cb input[type=checkbox]').on('click', function () {
                //    var idVal = $(this).attr("id");
                //    var type = $(this).closest('span').attr('data-check-type');
                //    var therapeuticChecked = false;
                //    var procTypeId = $(this).closest('tr').find('[data-val-id]').attr("data-val-id");
                //    var isChecked = $(this).is(":checked");

                //    var recalculate = true;

                //    //toggle checkbox groups
                //    if (type.toLowerCase() == 'therapeutic') {
                //        therapeuticChecked = $(this).is(":checked")
                //        var diagnosticCB = $(this).closest('tr').find('[data-check-type=diagnostic] input');
                //        if (diagnosticCB.is(":checked")) {
                //            diagnosticCB.prop('checked', false);
                //            recalculate = false;
                //        }
                //    }
                //    else if (type.toLowerCase() == 'diagnostic') {
                //        var therapeuticCB = $(this).closest('tr').find('[data-check-type=therapeutic] input');
                //        if (therapeuticCB.is(":checked")) {
                //            therapeuticCB.prop('checked', false);
                //            recalculate = false;
                //        }
                //    }

                //    $(this).closest('tr').find('.define-button').attr("disabled", (therapeuticChecked == false));

                //    if (recalculate)
                //        calculateSlotLength(procTypeId, isChecked);
                //});





                $('.define-button').on('click', function () {
                    var procedureType = $(this).attr("data-proc-type");
                    var procedureTypeID = $(this).attr("data-proc-id");

                    var oWnd = $find('<%=ExternalRadWindow.ClientID%>');
                    oWnd.setUrl("../../Options/Scheduler/TherapeuticTypes.aspx?ProcedureType=" + procedureType + "&ProcedureTypeID=" + procedureTypeID + "&mode=search")
                    oWnd.setSize(450, 520);
                    oWnd.show();
                    oWnd.add_close(function () {
                        oWnd.set_title("");
                    });
                    return false;
                });
            }

            function validateProcedureTypes(source, args) {
                //check for procedure types
                var checkedCount = 0;
                $('.procedure-type-cb input').each(function () {
                    if ($(this).is(":checked")) {
                        checkedCount += 1;
                    }
                });

                if (checkedCount == 0) {
                    args.IsValid = false;
                }
            }

            function validateNonGIProcedureTypes(source, args) {
                //check if procedure type selected
                var procId = $find('<%=nonGIProceduresDropdown.ClientID%>').get_value();

                if (procId == 0) {
                    args.IsValid = false;
                }
            }

            function validateSlotType(source, args) {
                checkedCount = 0;
                if ($('#<%= AllSlotsCheckBox.ClientID%>').is(":checked")) {
                    checkedCount = 1;
                }
                else {
                    $('#<%=IncludedSlotsCheckBoxList.ClientID%> input').each(function () {
                        if ($(this).is(":checked")) {
                            checkedCount += 1;
                        }
                    });
                }

                if (checkedCount == 0) {
                    args.IsValid = false;
                }
            }

            function validateMoveReason(source, args) {
                var moveReason = $find('<%=ReasonForMoveDropdown.ClientID%>').get_value();
                if (moveReason == 0) {
                    args.IsValid = false;
                }
            }

            function validateSearchCriteria() {
                var valid = Page_ClientValidate("SlotSearch");
                if (!valid) {
                    $find("<%=ValidateSearchRadNotification.ClientID%>").show();
                }
            }

            function setBreachDays() {
                //loop through checked boxes and build array of slot ids
                var slotIds = [];

                $('#<%=IncludedSlotsCheckBoxList.ClientID%> input').each(function (index, item) {
                    if ($(item).is(":checked") || $('#<%=AllSlotsCheckBox.ClientID%>').is(':checked')) {
                        slotIds.push(parseInt($(item).val()));
                    }
                });
                if (slotIds.length > 0) {
                    //ajax call to return breech days
                    var obj = {};
                    obj.slotIds = slotIds;
                    $.ajax({
                        type: "POST",
                        url: "FindBookSlot.aspx/GetSlotBreechDays",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (r) {
                            if (r.d != null) {
                                //set breach date textbox accordingly
                                var breechDays = r.d;
                                var referralDatePicker = $find('<%=ReferalDateDatePicker.ClientID%>')
                                if (referralDatePicker != null) {
                                    var referralDate = referralDatePicker.get_selectedDate();
                                    var newDate = new Date(referralDate);
                                    newDate.setDate(newDate.getDate() + breechDays);

                                    var todaysDate = new Date()
                                    if (breechDays == 0) {
                                        $find('<%=BreachDateDatePicker.ClientID%>').set_selectedDate(todaysDate);
                                        $('#<%=SearchWeeksBeforeTextBox.ClientID%>').val(0);
                                    }
                                    else
                                        $find('<%=BreachDateDatePicker.ClientID%>').set_selectedDate(newDate);

                                    updateSearchDate();
                                }
                            }
                        },
                        error: function (jqXHR, textStatus, data) {
                        }
                    });
                }
            }

            function ShowBookingWindow() {
                //GetListSlots
                var oWnd = $find("<%= BookingWindow.ClientID %>");
                if (oWnd != null) {
                    oWnd.set_title("");
                    oWnd.show();
                }
                //$('.slot-options-popup').show();
                //$('.slot-popup-modal').show();

            }


            function closeSlotWindow() {
                var oWnd = $find("<%= BookingWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
            }

            function validateMoveReason(source, args) {
                var moveReason = $find('<%=ReasonForMoveDropdown.ClientID%>').get_value();
                if (moveReason == 0) {
                    args.IsValid = false;
                }
            }

            function procedureChanged(sender) {
                var idVal = $(sender).attr("id");
                var type = $(sender).closest('span').attr('data-check-type');
                var therapeuticChecked = false;
                var procTypeId = $(sender).closest('tr').find('[data-val-id]').attr("data-val-id");
                var isChecked = $(sender).is(":checked");

                var recalculate = true;
                //toggle checkbox groups
                if (type.toLowerCase() == 'therapeutic') {
                    therapeuticChecked = true;
                    var diagnosticCB = $(sender).closest('tr').find('[data-check-type=diagnostic] input');
                    if (diagnosticCB.is(":checked")) {
                        diagnosticCB.prop('checked', false);
                        recalculate = false;
                    }
                }
                else if (type.toLowerCase() == 'diagnostic') {
                    therapeuticChecked = false;
                    var therapeuticCB = $(sender).closest('tr').find('[data-check-type=therapeutic] input');
                    if (therapeuticCB.is(":checked")) {
                        therapeuticCB.prop('checked', false);
                        recalculate = false;
                    }
                }
                
                $(sender).closest('tr').find('.define-button').attr("disabled", (therapeuticChecked == false));

                if (recalculate)
                    calculateSlotLength(procTypeId, isChecked, true);
            }

            function nonGIProcedureChanged(sender) {
                var procTypeId = $find('<%=nonGIProceduresDropdown.ClientID%>').get_value();

                if (procTypeId > 0) {
                    var obj = {};
                    obj.procedureTypeId = parseInt(procTypeId);
                    obj.checked = true;
                    obj.nonGI = true;
                    obj.operatingHospitalId = <%=OperatingHospitalId%>;
                    obj.isDiagnostic = true;
                    obj.isTraining = false;

                    $.ajax({
                        type: "POST",
                        url: "FindBookSlot.aspx/GetProcedureLengths",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (r) {
                            if (r.d != null) {
                                var retVal = JSON.parse(r.d);
                                $('.slot-length').val(parseFloat(retVal.points));
                            }
                        },
                        error: function (jqXHR, textStatus, data) {
                            console.log(jqXHR.responseText);
                        }
                    });
                }
                else {
                    $('.slot-length').val(0);
                }
            }

            function calculateSlotLength(iProcedureTypeId, isChecked, isDiagnostic) {
                var obj = {};
                obj.procedureTypeId = parseInt(iProcedureTypeId);
                obj.nonGI = false;
                obj.checked = isChecked;
                obj.operatingHospitalId = <%=OperatingHospitalId%>;
                obj.isTraining = false;
                obj.isDiagnostic = isDiagnostic;

                $.ajax({
                    type: "POST",
                    url: "FindBookSlot.aspx/GetProcedureLengths",
                    data: JSON.stringify(obj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (r) {
                        if (r.d != null) {
                            var slotLength = $('.slot-length').val();
                            var retVal = JSON.parse(r.d);

                            if (retVal.checked) {
                                $('.slot-length').val(parseFloat(slotLength) + parseFloat(retVal.points));
                            }
                            else {
                                $('.slot-length').val(parseFloat(slotLength) - parseFloat(retVal.points));
                            }
                        }
                    },
                    error: function (jqXHR, textStatus, data) {
                        console.log(jqXHR.responseText);
                       <%-- if (obj.checked == "true") {
                                $('#<%=LengthOfSlotsNumericTextbox.ClientID%>').val(parseInt(slotLength) + 15);
                            }
                            else {
                                $('.slot-length').val(parseInt(slotLength) - 15);
                            }
                        alert("Unable to retreive slot length for the selected procedure. A default value of 15 minutes has been gi. Please adjust manually");--%>
                    }
                });
            }

            function resetSearchDays() {
                $('.search-days input[type=checkbox]').each(function (index, item) {
                    $(item).prop("checked", false);
                });
            }



            function toggleGIProceduresView(isGIProcedure) {
                if (isGIProcedure) {
                    $('#non-gi-procedure-types').hide();
                    $('#gi-procedure-types').show();

                    $('#<%=LengthOfSlotsNumericTextbox.ClientID%>').val(0);
                    //validatorNonGIProcedureTypes
                    if ($('#<%=validatorProcedureTypes.ClientID%>')[0] != undefined)
                        ValidatorEnable($('#<%=validatorProcedureTypes.ClientID%>')[0], true);

                    if ($('#<%=validatorNonGIProcedureTypes.ClientID%>')[0] != undefined)
                        ValidatorEnable($('#<%=validatorNonGIProcedureTypes.ClientID%>')[0], false);
                }
                else {
                    $('#non-gi-procedure-types').show();
                    $('#gi-procedure-types').hide();

                    $('#<%=LengthOfSlotsNumericTextbox.ClientID%>').val(0);
                    if ($('#<%=validatorProcedureTypes.ClientID%>')[0] != undefined)
                        ValidatorEnable($('#<%=validatorProcedureTypes.ClientID%>')[0], false);

                    if ($('#<%=validatorNonGIProcedureTypes.ClientID%>')[0] != undefined)
                        ValidatorEnable($('#<%=validatorNonGIProcedureTypes.ClientID%>')[0], true);
                    //update EndoscopistObjectDataSource select paramenter

                }
            }

            function updateSearchDate() {
                var breachDate = new Date($find('<%=BreachDateDatePicker.ClientID%>').get_selectedDate());
                var weeks = parseInt($('#<%=SearchWeeksBeforeTextBox.ClientID%>').val());

                var newDate = new Date(breachDate);
                newDate.setDate(newDate.getDate() - (7 * weeks));

                var searchStartDate = $find('<%=SearchDateDatePicker.ClientID%>');
                searchStartDate.set_selectedDate(newDate);

            }

            function OnClientCheckAllChecked(sender, eventArgs) {
                __doPostBack(sender.get_id(), '');
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>

        <telerik:RadAjaxManager ID="am1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="SearchButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SearchWindowRadNotification" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ListSlotsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ListSlotsRadGrid" />
                        <telerik:AjaxUpdatedControl ControlID="SearchWindowRadNotification" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SearchAvailableSlotDiv">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SearchAvailableSlotDiv" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="FindAvailableSlotRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="FindAvailableSlotRadButton" />
                        <telerik:AjaxUpdatedControl ControlID="SearchWindowRadNotification" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="AvailableSlotsResultsRepeater">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ListSlotsRadGrid" />
                        <telerik:AjaxUpdatedControl ControlID="AvailableSlotsResultsRepeater" />
                        <telerik:AjaxUpdatedControl ControlID="SearchWindowRadNotification" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="WaitListGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="WaitListGrid" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="BookFromWaitlistRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="divWaitlist" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="SearchAvailableSlotDiv" Skin="Metro" />
        <telerik:RadNotification ID="SearchWindowRadNotification" runat="server" VisibleOnPageLoad="false" Height="170px" CssClass="rad-window-popup" ShowCloseButton="true" Skin="Metro" Title="Booking error" AutoCloseDelay="0" />
        <telerik:RadNotification ID="ValidateSearchRadNotification" runat="server" Animation="None"
            EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
            AutoCloseDelay="70000">
            <ContentTemplate>
                <asp:ValidationSummary ID="ValidateSearchValidationSummary" runat="server" ValidationGroup="SlotSearch" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
            </ContentTemplate>
        </telerik:RadNotification>

        <asp:HiddenField ID="SearchModeHiddenField" runat="server" />
        <asp:HiddenField ID="SelectedApppointmentId" runat="server" />

        <div id="SearchAvailableSlotDiv" runat="server" style="width: 100%; position: absolute; overflow-y:auto;">

            <div id="divFilters" runat="server" visible="true">
                <table style="width: 100%;">
                    <tr id="MoveBookingTR" runat="server" visible="false">
                        <td colspan="3" style="text-align: center;">
                            <label class="move-label">Please enter a reason for the move:</label>
                            <telerik:RadComboBox ID="ReasonForMoveDropdown" runat="server" DataTextField="Detail" DataValueField="CancelReasonId" ZIndex="9999" AutoPostBack="false" />
                            <asp:CustomValidator ID="validatorMoveReason" runat="server" ErrorMessage="Please select a reason" Text="*" CssClass="aspxValidator" ValidationGroup="SlotSearch" ValidateEmptyText="true" ClientValidationFunction="validateMoveReason" EnableClientScript="true" Display="None" />
                        </td>
                    </tr>
                    <tr>
                        <td valign="top" colspan="2">
                            <fieldset class="search-fieldset">
                                <legend>Search Criteria</legend>
                                <table>
                                    <tr>
                                        <td>
                                            <label>Trust</label></td>
                                        <td>
                                            <telerik:RadComboBox ID="SearchTrustRadComboBox" runat="server" AutoPostBack="true" ZIndex="9999" DataTextField="TrustName" DataValueField="TrustId" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Operating Hospital</label></td>
                                        <td>
                                            <telerik:RadComboBox ID="SearchOperatingHospitalIdRadComboBox" runat="server" AutoPostBack="false" ZIndex="9999" DataTextField="HospitalName" DataValueField="OperatingHospitalId" CheckBoxes="true" EnableCheckAllItemsCheckBox="true" Localization-CheckAllString="All hospitals" Localization-AllItemsCheckedString="All hospitals" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="height: 15px;"></td>
                                    </tr>
                                    <tr style="display:none;">
                                        <td>
                                            <label>Search for</label></td>
                                        <td>
                                            <asp:RadioButtonList ID="SearchGIProcedureRadioButtons" runat="server" RepeatDirection="Horizontal" AutoPostBack="true">
                                                <asp:ListItem Text="GI Procedures" Value="true" Selected="True" />
                                                <asp:ListItem Text="Non-GI Procedures" Value="false" />
                                            </asp:RadioButtonList></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Endoscopist:</label></td>
                                        <td>
                                            <telerik:RadComboBox ID="SearchEndoscopistDropdown" runat="server" Style="z-index: 9999;" CheckBoxes="true" EmptyMessage="Any" DataSourceID="EndoscopistObjectDataSource" DataTextField="EndoName" DataValueField="UserID" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>List gender</label></td>
                                        <td>
                                            <asp:RadioButtonList ID="EndoscopistGenderRadioButtonList" runat="server" AutoPostBack="false" RepeatDirection="Horizontal">
                                                <asp:ListItem Text="Any" Selected="true" Value="0" />
                                                <asp:ListItem Value="m" Text="Male" />
                                                <asp:ListItem Value="f" Text="Female" />
                                            </asp:RadioButtonList></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="height: 20px;"></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Referral date:</label></td>
                                        <td>
                                            <telerik:RadDatePicker ID="ReferalDateDatePicker" runat="server" MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/3000" ZIndex="7999" DateInput-OnClientDateChanged="setBreachDays" />
                                            <asp:RequiredFieldValidator ID="ReferalDateDatePickerValidator" runat="server" ControlToValidate="ReferalDateDatePicker" ValidationGroup="SlotSearchValidation" ErrorMessage="*" ForeColor="Red" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Breach date:</label></td>
                                        <td>
                                            <telerik:RadDatePicker ID="BreachDateDatePicker" runat="server" MinDate='<%# DateTime.Now.Date().AddDays(7 * 6) %>' MaxDate="01/01/3000" ZIndex="7999" DateInput-OnClientDateChanged="updateSearchDate" />
                                            <asp:RequiredFieldValidator ID="BreachDateDatePickerValidator" runat="server" ControlToValidate="BreachDateDatePicker" ValidationGroup="SlotSearchValidation" ErrorMessage="*" ForeColor="Red" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Start searching</label>
                                        </td>
                                        <td>
                                            <telerik:RadNumericTextBox ID="SearchWeeksBeforeTextBox" runat="server" Value="2"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0" UpdateValueEvent="PropertyChanged" ClientEvents-OnValueChanged="updateSearchDate">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                            <label>weeks before breach date</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>Or from:</label></td>
                                        <td>
                                            <telerik:RadDatePicker ID="SearchDateDatePicker" runat="server" MaxDate="01/01/3000" ZIndex="7999" />
                                            <asp:RequiredFieldValidator ID="SearchDateDatePickerValidator" runat="server" ControlToValidate="SearchDateDatePicker" ValidationGroup="SlotSearchValidation" ErrorMessage="*" ForeColor="Red" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="height: 15px;"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <asp:CheckBox ID="ExcludeTrainingListsCheckBox" runat="server" Text="Exclude training lists" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                        <td valign="top" rowspan="2">
                            <fieldset>
                                <legend>Include these procedures in search</legend>
                                <asp:CheckBox ID="ShowOnlyReservedSlotsCheckBox" runat="server" Text="Show only reserved slots (guidelines)" />
                                <br />
                                <div style="padding: 7px; display: none;">
                                    <label>Length of slot</label>
                                    <telerik:RadNumericTextBox ID="LengthOfSlotsNumericTextbox" CssClass="slot-length" runat="server" Value="0"
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="0.5"
                                        Width="35px"
                                        MinValue="0">
                                        <NumberFormat DecimalDigits="1" />
                                    </telerik:RadNumericTextBox>&nbsp;points
                                </div>
                                <div id="non-gi-procedure-types" style="padding-bottom: 3px; display: none;">
                                    <div>
                                        <telerik:RadComboBox ID="nonGIProceduresDropdown" runat="server" Style="z-index: 9999;" DataSourceID="NonGIProceduresObjectDataSource" DataTextField="ProcedureType" EmptyMessage="Choose non-GI procedure" DataValueField="ProcedureTypeId" CheckBoxes="false" OnClientSelectedIndexChanged="nonGIProcedureChanged" AppendDataBoundItems="true">
                                            <Items>
                                                <telerik:RadComboBoxItem Text="" Value="0" />
                                            </Items>
                                        </telerik:RadComboBox>
                                        <asp:CustomValidator ID="validatorNonGIProcedureTypes" runat="server" ErrorMessage="Please select at least one procedure type" Text="*" CssClass="aspxValidator" ValidationGroup="SlotSearch" ClientValidationFunction="validateNonGIProcedureTypes" EnableClientScript="true" Display="None" />
                                    </div>
                                    <div style="float: left">
                                        <table cellpadding="4">
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="DiagnosticsRadioButton" runat="server" Text="Diagnostic" TextAlign="Right" GroupName="non-gi-procedure-group" /></td>
                                                <td>
                                                    <asp:RadioButton ID="TherapeuticRadioButton" runat="server" Text="Therapeutic" TextAlign="Right" GroupName="non-gi-procedure-group" /></td>
                                                <td></td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                                <div id="gi-procedure-types">
                                    <div style="float: left;">
                                        <asp:CustomValidator ID="validatorProcedureTypes" runat="server" ErrorMessage="Please select at least one procedure type" Text="*" CssClass="aspxValidator" ValidationGroup="SlotSearch" ClientValidationFunction="validateProcedureTypes" EnableClientScript="true" Display="None" />
                                        <asp:Repeater ID="rptProcedureTypes" runat="server" OnItemDataBound="rptProcedureTypes_ItemDataBound">
                                            <HeaderTemplate>
                                                <table cellpadding="4">
                                                    <tr>
                                                        <td>
                                                            <label>Diagnostic</label></td>
                                                        <td>
                                                            <label>Therapeutic</label></td>
                                                        <td></td>
                                                    </tr>
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <tr>
                                                    <td>
                                                        <asp:HiddenField ID="ProcedureTypeHiddenField" runat="server" Value='<%#Eval("SchedulerProcName") %>' />
                                                        <asp:HiddenField ID="ProcedureTypeIDHiddenField" runat="server" Value='<%#Eval("ProcedureTypeID") %>' />
                                                        <asp:CheckBox ID="DiagnosticProcedureTypesCheckBox" CssClass="procedure-type-cb" runat="server" Text='<%#Eval("SchedulerProcName") %>' data-check-type="diagnostic" GroupName="procedure-group" onclick="procedureChanged(this)" />
                                                    </td>
                                                    <td>
                                                        <asp:CheckBox ID="TherapeuticProcedureTypesCheckBox" CssClass="procedure-type-cb" runat="server" data-val-id='<%#Eval("ProcedureTypeID") %>' Text='<%#Eval("SchedulerProcName") %>' data-check-type="therapeutic" onclick="procedureChanged(this)" GroupName="procedure-group" />
                                                    </td>
                                                    <td>
                                                        <asp:Button ID="DefineTherapeuticProcedureButton" runat="server" data-val-id='<%#Eval("ProcedureTypeID") %>' Text="Define" Enabled="false" CssClass="define-button" data-proc-type='<%#Eval("SchedulerProcName") %>' data-proc-id='<%#Eval("ProcedureTypeID") %>' />
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                            <FooterTemplate>
                                                </table>
                                            </FooterTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </fieldset>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top">
                            <asp:CustomValidator ID="SlotTypeValidator" runat="server" ErrorMessage="Please select a slot type" ValidationGroup="SlotSearch" Text="*" CssClass="aspxValidator" ClientValidationFunction="validateSlotType" EnableClientScript="true" Display="None" />
                            <fieldset class="slot-filter">
                                <legend>Include these slots in search</legend>
                                <asp:CheckBox ID="AllSlotsCheckBox" runat="server" Text="ALL slots" Checked="true" />
                                <asp:CheckBoxList ID="IncludedSlotsCheckBoxList" runat="server" DataSourceID="SlotStatusObjectDataSource" DataValueField="StatusId" DataTextField="Description" />
                            </fieldset>
                        </td>
                        <td valign="top">
                            <fieldset>
                                <legend>Include these days in search</legend>
                                <table class="search-days" cellpadding="4" id="SearchDaysTable" runat="server">
                                    <tr>
                                        <td></td>
                                        <td>
                                            <label>Morning</label></td>
                                        <td>
                                            <label>Afternoon</label></td>
                                        <td>
                                            <label>Evening</label></td>
                                    </tr>
                                    <tr data-day="monday">
                                        <td>
                                            <asp:CheckBox ID="MondayCheckBox" runat="server" Text="Monday" TextAlign="Right" /></td>
                                        <td>
                                            <asp:CheckBox ID="MondayMorningCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="MondayAfternoonCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="MondayEveningCheckBox" runat="server" /></td>
                                    </tr>
                                    <tr data-day="tuesday">
                                        <td>
                                            <asp:CheckBox ID="TuesdayCheckBox" runat="server" Text="Tuesday" TextAlign="Right" /></td>
                                        <td>
                                            <asp:CheckBox ID="TuesdayMorningCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="TuesdayAfternoonCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="TuesdayEveningCheckBox" runat="server" /></td>
                                    </tr>
                                    <tr data-day="wednesday">
                                        <td>
                                            <asp:CheckBox ID="WednesdayCheckBox" runat="server" Text="Wednesday" TextAlign="Right" /></td>
                                        <td>
                                            <asp:CheckBox ID="WednesdayMorningCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="WednesdayAfternoonCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="WednesdayEveningCheckBox" runat="server" /></td>
                                    </tr>
                                    <tr data-day="thursday">
                                        <td>
                                            <asp:CheckBox ID="ThursdayCheckBox" runat="server" Text="Thursday" TextAlign="Right" /></td>
                                        <td>
                                            <asp:CheckBox ID="ThursdayMorningCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="ThursdayAfternoonCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="ThursdayEveningCheckBox" runat="server" /></td>
                                    </tr>
                                    <tr data-day="friday">
                                        <td>
                                            <asp:CheckBox ID="FridayCheckBox" runat="server" Text="Friday" TextAlign="Right" /></td>
                                        <td>
                                            <asp:CheckBox ID="FridayMorningCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="FridayAfternoonCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="FridayEveningCheckBox" runat="server" /></td>
                                    </tr>
                                    <tr data-day="saturday">
                                        <td>
                                            <asp:CheckBox ID="SaturdayCheckBox" runat="server" Text="Saturday" TextAlign="Right" /></td>
                                        <td>
                                            <asp:CheckBox ID="SaturdayMorningCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="SaturdayAfternoonCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="SaturdayEveningCheckBox" runat="server" /></td>
                                    </tr>
                                    <tr data-day="sunday">
                                        <td>
                                            <asp:CheckBox ID="SundayCheckBox" runat="server" Text="Sunday" TextAlign="Right" /></td>
                                        <td>
                                            <asp:CheckBox ID="SundayMorningCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="SundayAfternoonCheckBox" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="SundayEveningCheckBox" runat="server" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                        <td></td>
                    </tr>
                </table>
                <div id="buttons" runat="server" height="78px" style="padding-top: 25px; text-align: center;">
                    <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Skin="Metro" Icon-PrimaryIconCssClass="rbSearch" OnClick="SearchButton_Click" ValidationGroup="SlotSearchValidation" />
                    <telerik:RadButton ID="CancelSearchButton" runat="server" Text="Close" Skin="Metro" OnClientClicking="CloseWindow" OnClick="CancelSearchButton_Click" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" CausesValidation="false" />
                </div>
            </div>
            <div id="divResults" runat="server" visible="false" style="width: 95%;">
                <fieldset>
                    <legend>Search criteria&nbsp(<asp:Label ID="SearchCriteriaProcedureGITypeLabel" runat="server" />)</legend>
                    <asp:Label ID="SearchCriteriaDetailsLabel" runat="server" />
                    <div style="float: left">
                        <table>
                            <tr>
                                <td>Endoscopist:</td>
                                <td>
                                    <asp:Label ID="SCEndoscopistLabel" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>Procedure(s):</td>
                                <td>
                                    <asp:Label ID="SCProceduresLabel" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>Type of slot:</td>
                                <td>
                                    <asp:Label ID="SCSlotTypeLabel" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>Gender:</td>
                                <td>
                                    <asp:Label ID="SCGenderLabel" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>Days:</td>
                                <td>
                                    <asp:Label ID="SCDaysLabel" runat="server" /></td>
                            </tr>
                        </table>
                    </div>
                    <div style="float: right;">
                        <table>
                            <tr>
                                <td>Referral Date:</td>
                                <td>
                                    <asp:Label ID="SCReferralDateLabel" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>Breach Date:</td>
                                <td>
                                    <asp:Label ID="SCBreachDateLabel" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>Search from Date:</td>
                                <td>
                                    <asp:Label ID="SCSearchFromDateLabel" runat="server" /></td>
                            </tr>
                        </table>
                    </div>
                </fieldset>
                <telerik:RadButton ID="ChangeSearchCriteriaButton" runat="server" Text="Change search criteria" OnClick="ChangeSearchCriteriaButton_Click" />
                <br />
                <div id="NoResultsDiv" runat="server" visible="false" style="margin-top: 30px; text-align: center;">
                    <asp:Label ID="NoResultsLabel" runat="server" />
                    <div runat="server" height="78px" style="padding-top: 5px; text-align: center;">
                        <telerik:RadButton ID="CloseNoResultsDivButton" runat="server" Text="Close" Skin="Metro" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" />
                    </div>
                </div>

                <div style="">



                    <asp:Repeater ID="AvailableSlotsResultsRepeater" runat="server" OnItemCreated="AvailableSlotsResultsRepeater_ItemCreated">
                        <HeaderTemplate>
                            <table style="width: 100%;">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <asp:Label ID="SlotDateLabel" runat="server" Text='<%#Eval("SlotDate") %>' CssClass="divWelcomeMessage" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Repeater ID="SlotsRepeater" runat="server">

                                        <ItemTemplate>
                                            <div style="border-bottom: 1px solid #c5c5c5; padding-top: 20px;">
                                                <table class="MasterClass" style="width: 100%; border-spacing: 0px; border-color: #c5c5c5;">
                                                    <thead>
                                                        <tr>
                                                            <th scope="col" class="rgHeader" style="width: 100px; border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label>List Name</label></th>
                                                            <th scope="col" class="rgHeader" style="width: 160px; border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label>Time</label></th>
                                                            <th scope="col" class="rgHeader" style="width: 130px; border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label>Endoscopist</label></th>
                                                            <th scope="col" class="rgHeader" style="width: 150px; border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label>Room</label></th>
                                                            <th scope="col" class="rgHeader" style="width: 100px; border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label>Type</label></th>
                                                            <th scope="col" class="rgHeader" style="width: 100px; border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label>Reserved</label></th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <tr>
                                                            <td style="border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label><%#Eval("Template") %></label></td>
                                                            <td style="border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label><%#Eval("SlotTime") %></label></td>
                                                            <td style="border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label><%#Eval("Endoscopist") %></label></td>
                                                            <td style="border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label><%#Eval("RoomName") %></label></td>
                                                            <td style="border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label><%#Eval("SlotType") %></label></td>
                                                            <td style="border: 1px solid #e5e5e5; text-align: left; padding: 5px;">
                                                                <label><%#Eval("Reserved") %></label><asp:HiddenField ID="DiaryIdHiddenField" runat="server" Value='<%# Eval("DiaryId") %>' />
                                                            </td>

                                                        </tr>
                                                        <tr>
                                                            <td colspan="7" style="padding: 10px 0px 35px 35px;">
                                                                <label>Available times:</label><br />
                                                                <asp:Repeater ID="rptAvailableSlots" runat="server">
                                                                    <HeaderTemplate>
                                                                        <table>
                                                                            <tr>
                                                                    </HeaderTemplate>
                                                                    <ItemTemplate>
                                                                        <td>
                                                                            <asp:Button ID="btnSlotTime" runat="server" data-diaryid='<%#Eval("DiaryId") %>' data-slotdate='<%#Eval("DiaryStart") %>' data-roomid='<%#Eval("RoomId") %>'
                                                                                data-statusid='<%#Eval("StatusId") %>' data-duration='<%#Eval("SlotDuration") %>' data-points='<%#Eval("Points") %>' data-listslotid='<%#Eval("ListSlotId") %>'
                                                                                data-proceduretypeid='<%#Eval("ProcedureTypeId") %>' data-operatinghospital='<%#Eval("OperatingHospitalId") %>' Text='<%# CDate(Eval("DiaryStart")).ToShortTimeString() %>' OnClientClick="BookAvailableSlot(this)" />
                                                                        </td>
                                                                    </ItemTemplate>
                                                                    <FooterTemplate>
                                                                        </tr>
                                                            </table>
                                                                    </FooterTemplate>
                                                                </asp:Repeater>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <%--    <telerik:RadGrid ID="SlotsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                                        Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px;" OnItemCommand="SlotsRadGrid_ItemCommand" EnableHeaderContextMenu="true" EnableHeaderContextFilterMenu="true" OnItemCreated="SlotsRadGrid_ItemCreated">
                                        <MasterTableView TableLayout="Fixed" CssClass="MasterClass" DataKeyNames="RoomID,DiaryId">
                                            <Columns>
                                                <telerik:GridBoundColumn DataField="SlotTime" HeaderText="Time" SortExpression="SlotTime" HeaderStyle-Width="160px" HeaderStyle-Height="0" AllowSorting="false" />
                                                <telerik:GridBoundColumn DataField="Endoscopist" HeaderText="Endoscopist" SortExpression="Endoscopist" HeaderStyle-Width="130px" HeaderStyle-Height="0" AllowSorting="false" ItemStyle-Wrap="true" />
                                                <telerik:GridBoundColumn DataField="RoomName" HeaderText="Room" SortExpression="RoomName" HeaderStyle-Width="150px" HeaderStyle-Height="0" AllowSorting="false" ShowSortIcon="true" />
                                                <telerik:GridBoundColumn DataField="Template" HeaderText="Template" SortExpression="Template" HeaderStyle-Width="100px" HeaderStyle-Height="0" AllowSorting="false" />
                                                <telerik:GridBoundColumn DataField="SlotType" HeaderText="Type" SortExpression="SlotType" HeaderStyle-Width="100px" HeaderStyle-Height="0" AllowSorting="false" ShowSortIcon="true" />
                                                <telerik:GridBoundColumn DataField="Reserved" HeaderText="Reserved" SortExpression="Reserved" HeaderStyle-Width="100px" HeaderStyle-Height="0" AllowSorting="false" ShowSortIcon="true" />
                                                <telerik:GridTemplateColumn HeaderStyle-Width="50px">
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="GoToDateLinkButton" runat="server" Text="View slots" Font-Italic="true" CommandArgument='<%#Eval("AvailableDate") %>' CommandName="SelectSlot" />&nbsp;

                                                    </ItemTemplate>
                                                </telerik:GridTemplateColumn>
                                                <telerik:GridTemplateColumn HeaderStyle-Width="50px">
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="DateRejectedLinkButton" runat="server" Text="Reject Date" Font-Italic="true" CommandArgument='<%#Eval("AvailableDate") %>' CommandName="RejectSlot" />&nbsp;

                                                    </ItemTemplate>
                                                </telerik:GridTemplateColumn>
                                            </Columns>
                                        </MasterTableView>
                                        <ClientSettings>
                                            <ClientEvents OnRowContextMenu="RowContextMenu" />
                                            <Selecting AllowRowSelect="true" />
                                        </ClientSettings>
                                    </telerik:RadGrid>
                                    <input type="hidden" id="radGridClickedRowIndex" name="radGridClickedRowIndex" />

                                    <telerik:RadContextMenu ID="RadMenu1" runat="server"
                                        EnableRoundedCorners="true" EnableShadows="true" CssClass="context-menu-popup">
                                        <Items>
                                            <telerik:RadMenuItem Text="Make Offer">
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Go to slot">
                                            </telerik:RadMenuItem>
                                        </Items>
                                    </telerik:RadContextMenu>--%>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>

            </div>

            <div id="divWaitlist" runat="server" visible="false" style="padding-top: 15px;">

                <telerik:RadTabStrip ID="WaitlistTabStrip" runat="server" Orientation="HorizontalTop" Visible="true" MultiPageID="WaitlistMultipage" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="Metro" RenderMode="Lightweight">
                    <Tabs>
                        <telerik:RadTab Text="Waitlist" runat="server" PageViewID="WaitlistPageView" />
                        <telerik:RadTab Text="Orders" runat="server" PageViewID="OrdersPageView" Visible="false" />
                    </Tabs>
                </telerik:RadTabStrip>
                <telerik:RadMultiPage ID="WaitlistMultipage" runat="server" SelectedIndex="0">
                    <telerik:RadPageView ID="WaitlistPageView" runat="server">
                        <table border="0" width="100%" style="margin-top: 5px; margin-bottom: 5px;">
                            <tr>
                                <td>
                                    <table border="0">
                                        <tr>
                                            <td><span style="font-size: 14px;">Select Hospitals:</span></td>
                                            <td style="width: 300px">
                                                <telerik:RadComboBox ID="cboOperatingHospitals" runat="server" Skin="Windows7" AutoPostBack="true" Font-Bold="false" Width="100%" CssClass="filterDDL" Filter="StartsWith" CheckBoxes="true" OnItemChecked="cboOperatingHospitals_ItemChecked" EnableCheckAllItemsCheckBox="true" OnClientCheckAllChecked="OnClientCheckAllChecked"></telerik:RadComboBox>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <telerik:RadGrid ID="WaitListGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                            AllowAutomaticDeletes="True" AutoSizeColumnsMode="Fill" AllowSorting="true" Height="" Width=""
                            Skin="Metro" GridLines="None" CssClass="WrkGridClass" SelectedItemStyle-CssClass="SelectedGridRowStyle" OnNeedDataSource="WaitListGrid_NeedDataSource" OnItemCommand="WaitListGrid_ItemCommand" OnItemDataBound="WaitListGrid_ItemDataBound">
                            <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
                            <CommandItemStyle BackColor="WhiteSmoke" />
                            <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="WaitingListId,PatientId" 
                                CommandItemDisplay="None" 
                                DataKeyNames="WaitingListId,PatientId,ProcedureTypeId,PriorityId,DiagnosticProcedure,TherapeuticProcedure,DateRaised,OrderId,DefaultSchedulerDiagnostic,DefaultSchedulerTherapeutic" 
                                TableLayout="Fixed" CssClass="MasterClass"
                                GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AllowFilteringByColumn="true" 
                                EnableNoRecordsTemplate="true">
                                <Columns>
                                    <telerik:GridBoundColumn DataField="Alert" HeaderText="Alert" HeaderStyle-Width="45px" AllowFiltering="false"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" ShowSortIcon="true" AllowSorting="true" SortExpression="Surname" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Forename1" HeaderText="Forename" SortExpression="Forename1" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Gender" HeaderText="Gender" SortExpression="Gender" ItemStyle-HorizontalAlign="Center" FilterControlWidth="12px" CurrentFilterFunction="EqualTo" ShowFilterIcon="false" AutoPostBackOnFilter="true" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="75px">
                                        <FilterTemplate>
                                            <telerik:RadComboBox RenderMode="Lightweight" ID="GenderCombo" Width="60" ZIndex="99999" SelectedValue='<%# CType(Container, GridItem).OwnerTableView.GetColumn("Gender").CurrentFilterValue %>'
                                                runat="server" Skin="Metro" OnClientSelectedIndexChanged="GenderComboIndexChanged">
                                                <Items>
                                                    <telerik:RadComboBoxItem Text="All" Value="" />
                                                    <telerik:RadComboBoxItem Text="Male" Value="Male" />
                                                    <telerik:RadComboBoxItem Text="Female" Value="Female" />
                                                </Items>
                                            </telerik:RadComboBox>
                                            <telerik:RadScriptBlock ID="RadScriptBlockGender" runat="server">
                                                <script type="text/javascript">
                                                    function GenderComboIndexChanged(sender, args) {
                                                        var tableView = $find("<%# CType(Container, GridItem).OwnerTableView.ClientID %>");
                                                        tableView.filter("Gender", args.get_item().get_value(), "EqualTo");
                                                    }
                                                </script>
                                            </telerik:RadScriptBlock>
                                        </FilterTemplate>
                                    </telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn HeaderText="DOB" SortExpression="DateOfBirth" HeaderStyle-Width="80px" AllowFiltering="false" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Label ID="lblPatientDOB" runat="server" Text='<%# Eval("DateOfBirth", "{0:dd/MM/yyyy}") %>' />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Case note number" SortExpression="HospitalNumber" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="NHSNo" HeaderText="NHS number" SortExpression="NHSNo" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn DataField="Postcode" HeaderText="Postcode" SortExpression="Postcode" HeaderStyle-Width="80px" FilterControlWidth="70px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <telerik:RadToolTip RenderMode="Lightweight" ID="RadToolTip1" runat="server" TargetControlID="PostcodeLabel" Skin="Metro" RelativeTo="Element" Style="z-index: 99999999;"
                                                Position="MiddleRight" RenderInPageRoot="true">
                                                <%# DataBinder.Eval(Container, "DataItem.Address")%>
                                            </telerik:RadToolTip>
                                            <asp:Label ID="PostcodeLabel" runat="server" Text='<%#Eval("Postcode") %>' />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure" SortExpression="ProcedureType" HeaderStyle-Width="120px" FilterControlWidth="115" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true">
                                        <FilterTemplate>
                                            <telerik:RadComboBox RenderMode="Lightweight" ID="ProcedureCombo" Width="120" SelectedValue='<%# CType(Container, GridItem).OwnerTableView.GetColumn("ProcedureType").CurrentFilterValue %>'
                                                runat="server" Skin="Metro" OnClientSelectedIndexChanged="ProcedureTypeComboIndexChanged" ZIndex="99999" DataSourceID="ProcedureTypesObjectDataSourceForFilter" DataValueField="ProcedureType" DataTextField="ProcedureType" />
                                            <telerik:RadScriptBlock ID="RadScriptBlockProcedureType" runat="server">
                                                <script type="text/javascript">
                                                    function ProcedureTypeComboIndexChanged(sender, args) {

                                                        var tableView = $find("<%# CType(Container, GridItem).OwnerTableView.ClientID %>");
                                                        //alert(args.get_item().get_value());
                                                        if (args.get_item().get_value() == 'All Procedures') {
                                                            tableView.filter("ProcedureType", "", "EqualTo");
                                                        }
                                                        else {
                                                            tableView.filter("ProcedureType", args.get_item().get_value(), "EqualTo");
                                                        }

                                                    }
                                                </script>
                                            </telerik:RadScriptBlock>
                                        </FilterTemplate>
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="PriorityDescription" HeaderText="Priority" SortExpression="PriorityDescription" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true">
                                        <FilterTemplate>
                                            <telerik:RadComboBox RenderMode="Lightweight" ID="PriorityCombo" Width="100" ZIndex="99999" SelectedValue='<%# CType(Container, GridItem).OwnerTableView.GetColumn("PriorityDescription").CurrentFilterValue %>'
                                                runat="server" Skin="Metro" OnClientSelectedIndexChanged="PriorityComboIndexChanged" DataSourceID="SlotStatusObjectDataSourceForFilter" DataValueField="Description" DataTextField="Description" />

                                            <telerik:RadScriptBlock ID="RadScriptBlockPriority" runat="server">
                                                <script type="text/javascript">
                                                    function PriorityComboIndexChanged(sender, args) {
                                                        var tableView = $find("<%# CType(Container, GridItem).OwnerTableView.ClientID %>");
                                                        if (args.get_item().get_value() == '-- All --') {
                                                            tableView.filter("PriorityDescription", "", "EqualTo");
                                                        }
                                                        else {
                                                            tableView.filter("PriorityDescription", args.get_item().get_value(), "EqualTo");
                                                        }
                                                    }
                                                </script>
                                            </telerik:RadScriptBlock>
                                        </FilterTemplate>
                                    </telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn HeaderText="Referral date" SortExpression="DateRaised" HeaderStyle-Width="80px" AllowFiltering="false" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Label ID="lblDateRaised" runat="server" Text='<%# Eval("DateRaised", "{0:dd/MM/yyyy}") %>' />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn DataField="WaitDays" HeaderText="Days<br>wait" SortExpression="WaitDays" CurrentFilterFunction="LessThanOrEqualTo" HeaderStyle-Width="80px" FilterControlWidth="70px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="DaysToBreach" HeaderText="Days until<br>breach" SortExpression="DaysToBreach" HeaderStyle-Width="90px" FilterControlWidth="80px" ItemStyle-HorizontalAlign="Center" CurrentFilterFunction="LessThanOrEqualTo" HeaderStyle-HorizontalAlign="Center" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <%--<telerik:GridTemplateColumn HeaderText="Due date" SortExpression="DueDate" HeaderStyle-Width="80px" AllowFiltering="false" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Label ID="lblDueDate" runat="server" Text='<%# Eval("DueDate", "{0:dd/MM/yyyy}") %>' />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>--%>
                                    <telerik:GridBoundColumn DataField="Referrer" HeaderText="Referred by" SortExpression="Referrer" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn UniqueName="OrderId" DataField="OrderId" Visible="false">
                                    </telerik:GridBoundColumn>
                                    <telerik:GridTemplateColumn HeaderText="OC" HeaderStyle-Width="60px" AllowFiltering="false" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:ImageButton ID="btnViewOrderComm" runat="server" ImageUrl="~/Images/info-24x24.png" CommandName="ViewDetailOrderComm" ToolTip="View Order Comm"
                                                Height="18px" Width="18px" />
                                        </ItemTemplate>
                                    </telerik:GridTemplateColumn>
                                    <telerik:GridBoundColumn DataField="HospitalName" HeaderText="Hospital Name" SortExpression="HospitalName" HeaderStyle-Width="130px" AllowFiltering="false">
                                        <%--<FilterTemplate>
                                            <telerik:RadComboBox RenderMode="Lightweight" ID="HospitalNameCombo" Width="120" SelectedValue='<%# CType(Container, GridItem).OwnerTableView.GetColumn("HospitalName").CurrentFilterValue %>'
                                                runat="server" Skin="Metro" OnClientSelectedIndexChanged="HospitalNameComboIndexChanged"
                                                ZIndex="99999" DataSourceID="HospitalNameObjectDataSourceForFilter" DataValueField="HospitalName" DataTextField="HospitalName"/>
                                            <telerik:RadScriptBlock ID="RadScriptBlockHospitalName" runat="server">
                                                <script type="text/javascript">
                                                    function HospitalNameComboIndexChanged(sender, args) {

                                                        var tableView = $find("<%# CType(Container, GridItem).OwnerTableView.ClientID %>");
                                                        if (args.get_item().get_value() == 'All Hospitals') {
                                                            tableView.filter("HospitalName", "", "EqualTo");
                                                        }
                                                        else {
                                                            tableView.filter("HospitalName", args.get_item().get_value(), "EqualTo");
                                                        }

                                                    }
                                                </script>
                                            </telerik:RadScriptBlock>
                                        </FilterTemplate>--%>
                                    </telerik:GridBoundColumn>
                                </Columns>
                                <NoRecordsTemplate>
                                    <div id="NoRecordsDiv" style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                                        No patients found.
                                    </div>
                                </NoRecordsTemplate>
                            </MasterTableView>
                            <GroupingSettings CaseSensitive="false" CollapseAllTooltip="Collapse all groups"></GroupingSettings>
                            <ClientSettings EnableRowHoverStyle="true">
                                <Resizing AllowColumnResize="true" ResizeGridOnColumnResize="true" AllowResizeToFit="true" />
                                <Selecting AllowRowSelect="true" />
                                <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                                <ClientEvents OnRowContextMenu="showContextMenuWrk" OnRowSelecting="waitlistRowSelected" OnRowClick="waitlistRowSelected" OnRowDblClick="searchSlotFromWaitlist" />
                            </ClientSettings>
                            <AlternatingItemStyle BackColor="#fafafa" />
                            <HeaderStyle BackColor="#f4f7f9" Font-Bold="true" Height="10" />
                            <SortingSettings SortedBackColor="ControlLight" />
                        </telerik:RadGrid>
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="OrdersPageView" runat="server" Height="200px">
                        <telerik:RadGrid ID="OrdersRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                            AllowAutomaticDeletes="True" AutoSizeColumnsMode="Fill" AllowSorting="true" Height="500" Width="1205"
                            Skin="Metro" GridLines="None" CssClass="WrkGridClass">
                            <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
                            <CommandItemStyle BackColor="WhiteSmoke" />
                            <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="OrderId,PatientId" CommandItemDisplay="None" DataKeyNames="OrderId,PatientId,ProcedureTypeId" TableLayout="Fixed" CssClass="MasterClass"
                                GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AllowFilteringByColumn="false">
                                <Columns>
                                    <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure" SortExpression="ProcedureType" HeaderStyle-Width="120px" FilterControlWidth="120" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="false">
                                        <FilterTemplate>
                                            <telerik:RadComboBox AutoPostBack="false" RenderMode="Lightweight" ID="ProcedureCombo2" Width="120" SelectedValue='<%# CType(Container, GridItem).OwnerTableView.GetColumn("ProcedureType").CurrentFilterValue %>'
                                                runat="server" Skin="Metro" OnClientSelectedIndexChanged="ProcedureTypeComboIndexChanged2" ZIndex="99999" DataSourceID="ProcedureTypesObjectDataSource" DataTextField="ProcedureType" />
                                            <telerik:RadScriptBlock ID="RadScriptBlockProcedureType2" runat="server">
                                                <script type="text/javascript">
                                                    function ProcedureTypeComboIndexChanged2(sender, args) {
                                                        var tableView = $find("<%# CType(Container, GridItem).OwnerTableView.ClientID %>");
                                                        tableView.filter("ProcedureType", args.get_item().get_value(), "EqualTo");
                                                    }
                                                </script>
                                            </telerik:RadScriptBlock>
                                        </FilterTemplate>
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="OrderDate" HeaderText="Order Date" SortExpression="OrderDate" DataType="System.DateTime" DataFormatString="{0:dd MMMM yyyy}" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" SortExpression="Surname" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Forename" HeaderText="Forename" SortExpression="Forename1" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="DateOfBirth" HeaderText="DOB" SortExpression="DateOfBirth" DataType="System.DateTime" DataFormatString="{0:dd MMMM yyyy}" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Case Note Number" SortExpression="HospitalNumber" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="NHSNo" HeaderText="NHS Number" SortExpression="NHSNo" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="DueDate" HeaderText="Due Date" SortExpression="DueDate" DataType="System.DateTime" DataFormatString="{0:dd MMMM yyyy}" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="AssignedCareProfessional" HeaderText="Assigned Care Professional" SortExpression="AssignedCareProfessional" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Referrer" HeaderText="Referrer" SortExpression="Referrer" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="OrderNumber" HeaderText="Order Number" SortExpression="OrderNumber" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                </Columns>
                                <NoRecordsTemplate>
                                    <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                                        No patients found.
                                    </div>
                                </NoRecordsTemplate>
                            </MasterTableView>
                            <GroupingSettings CaseSensitive="false" CollapseAllTooltip="Collapse all groups"></GroupingSettings>
                            <ClientSettings EnableRowHoverStyle="true">
                                <Resizing AllowColumnResize="true" ResizeGridOnColumnResize="true" AllowResizeToFit="true" />
                                <Selecting AllowRowSelect="true" />
                                <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                                <ClientEvents OnRowContextMenu="showContextMenuOrd" OnRowSelecting="waitlistRowSelected" OnRowClick="waitlistRowSelected" OnRowDblClick="searchSlotFromWaitlist" />
                            </ClientSettings>
                            <AlternatingItemStyle BackColor="#fafafa" />
                            <HeaderStyle BackColor="#f4f7f9" Font-Bold="true" Height="10" />
                            <SortingSettings SortedBackColor="ControlLight" />
                        </telerik:RadGrid>
                    </telerik:RadPageView>
                </telerik:RadMultiPage>
                <asp:HiddenField ID="WaitlistSelectedIdHiddenField" runat="server" />
                <asp:HiddenField ID="WaitlistPatientHiddenField" runat="server" />
                <asp:HiddenField ID="WiatlistIdHiddenField" runat="server" />
                <span id="spanSearchButtons" runat="server" style="display:none;">
                <asp:Button ID="btnSearchSlotFromWorklist" runat="server" OnClick="btnSearchSlotFromWorklist_Click" Style="display: none;" />
                <asp:Button ID="btnSearchSlotFromOrder" runat="server" OnClick="btnSearchSlotFromOrder_Click" Style="display: none;"/>
                <asp:Button ID="btnShowWorklistDetail" runat="server" OnClick="btnSearchSlotFromWorklist_Click" Style="display: none;"/>
                <asp:Button ID="btnShowOrdersDetail" runat="server" OnClick="btnShowOrdersDetail_Click" Style="display: none;" />
                <asp:Button ID="btnMoveToWorklist" runat="server" OnClick="btnMoveToWorklist_Click" Style="display: none;" />
                </span>
                <telerik:RadContextMenu ID="WaitlistRadMenu" runat="server" EnableRoundedCorners="true" EnableOverlay="true" EnableShadows="true" Style="z-index: 999999999999 !important;">
                    <Items>
                        <telerik:RadMenuItem Text="View details" ImageUrl="../../../Images/icons/notes.png" NavigateUrl="javascript:showWorklistDetail();">
                        </telerik:RadMenuItem>
                        <telerik:RadMenuItem Text="Find available slot" ImageUrl="../../../Images/icons/select.png" NavigateUrl="javascript:searchSlotFromWaitlist();">
                        </telerik:RadMenuItem>
                    </Items>
                </telerik:RadContextMenu>
                <telerik:RadContextMenu ID="OrdersRadMenu" runat="server" EnableRoundedCorners="true" EnableOverlay="true" EnableShadows="true" Style="z-index: 999999999999 !important;">
                    <Items>
                        <telerik:RadMenuItem Text="Add to Waitlist" ImageUrl="../../../Images/icons/worklist_add.png" NavigateUrl="javascript:MoveToWorklist();">
                        </telerik:RadMenuItem>
                        <telerik:RadMenuItem Text="View details" ImageUrl="../../../Images/icons/notes.png" NavigateUrl="javascript:showOrdersDetail();">
                        </telerik:RadMenuItem>

                    </Items>
                </telerik:RadContextMenu>
            </div>
            <div id="divOrderDetails" runat="server" visible="false" style="padding-top: 15px;">
                <telerik:RadTabStrip ID="RadTabOrders" runat="server" Orientation="HorizontalTop" Visible="true" MultiPageID="OrderDetailMultipage" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="Metro" RenderMode="Lightweight">
                    <Tabs>
                        <telerik:RadTab Text="Order" runat="server" PageViewID="OrderDetailPageView" />
                        <telerik:RadTab Text="Questions" runat="server" PageViewID="OrderQuestionsPageView" />
                        <telerik:RadTab Text="History" runat="server" PageViewID="OrderHistoryPageView" />
                    </Tabs>
                </telerik:RadTabStrip>
                <telerik:RadMultiPage ID="OrderDetailMultipage" runat="server" SelectedIndex="0">
                    <telerik:RadPageView ID="OrderDetailPageView" runat="server" Height="510px">
                        <table border="1">
                            <tr>
                                <td>
                                    <fieldset runat="server" id="Fieldset1">
                                        <legend>Patient Information</legend>
                                        <table>
                                            <tr>
                                                <td>Name:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="OrderDetailPatName" /></td>
                                                <td rowspan="5" style="vertical-align: text-top;">Address:</td>
                                                <td rowspan="5" style="vertical-align: text-top;">
                                                    <asp:Label runat="server" ID="OrderDetailPatAddress" /></td>
                                            </tr>
                                            <tr>
                                                <td>Gender:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="OrderDetailPatGender" /></td>
                                            </tr>
                                            <tr>
                                                <td>DOB:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="OrderDetailPatDOB" /></td>
                                            </tr>
                                            <tr>
                                                <td>Case note number:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="OrderDetailPatHospitalNo" /></td>
                                            </tr>
                                            <tr>
                                                <td>NHS number:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="OrderDetailPatNHSNo" /></td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                                <td rowspan="2">
                                    <fieldset runat="server" id="Fieldset3">
                                        <legend>Order Comms attached</legend>
                                        <table>
                                            <tr>
                                                <td>Order Date:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label13" /></td>
                                            </tr>
                                            <tr>
                                                <td>Date Raised:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label14" /></td>
                                            </tr>
                                            <tr>
                                                <td>Date Received:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label15" /></td>
                                            </tr>
                                            <tr>
                                                <td>Due Date:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label16" /></td>
                                            </tr>
                                            <tr>
                                                <td>Order Source:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label17" /></td>
                                            </tr>
                                            <tr>
                                                <td>Location:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label18" /></td>
                                            </tr>
                                            <tr>
                                                <td>Ward:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label19" /></td>
                                            </tr>
                                            <tr>
                                                <td>Referer:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label20" /></td>
                                            </tr>
                                            <tr>
                                                <td>Test Site:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label21" /></td>
                                            </tr>
                                            <tr>
                                                <td>Priority:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label22" /></td>
                                            </tr>
                                            <tr>
                                                <td>Order Status:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label23" /></td>
                                            </tr>
                                            <tr>
                                                <td>Ordered By:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label24" /></td>
                                            </tr>
                                            <tr>
                                                <td>Ordered By Contact:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label25" /></td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <fieldset runat="server" id="Fieldset2">
                                        <legend>Order Information</legend>
                                        <table>
                                            <tr>
                                                <td>Order Date:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="OrderDetailOrderDate" /></td>
                                            </tr>
                                            <tr>
                                                <td>Date Raised:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label1" /></td>
                                            </tr>
                                            <tr>
                                                <td>Date Received:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label2" /></td>
                                            </tr>
                                            <tr>
                                                <td>Due Date:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label3" /></td>
                                            </tr>
                                            <tr>
                                                <td>Order Source:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label4" /></td>
                                            </tr>
                                            <tr>
                                                <td>Location:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label5" /></td>
                                            </tr>
                                            <tr>
                                                <td>Ward:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label6" /></td>
                                            </tr>
                                            <tr>
                                                <td>Referer:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label7" /></td>
                                            </tr>
                                            <tr>
                                                <td>Test Site:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label8" /></td>
                                            </tr>
                                            <tr>
                                                <td>Priority:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label9" /></td>
                                            </tr>
                                            <tr>
                                                <td>Order Status:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label10" /></td>
                                            </tr>
                                            <tr>
                                                <td>Ordered By:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label11" /></td>
                                            </tr>
                                            <tr>
                                                <td>Ordered By Contact:</td>
                                                <td>
                                                    <asp:Label runat="server" ID="Label12" /></td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                        </table>


                    </telerik:RadPageView>
                    <telerik:RadPageView ID="OrderQuestionsPageView" runat="server" Height="510px">
                        <telerik:RadGrid ID="RadGrid1" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                            AllowAutomaticDeletes="True" AutoSizeColumnsMode="Fill" AllowSorting="true" Height="500" Width="1205"
                            Skin="Metro" GridLines="None" CssClass="WrkGridClass">
                            <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
                            <CommandItemStyle BackColor="WhiteSmoke" />
                            <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="OrderId,PatientId" CommandItemDisplay="None" DataKeyNames="OrderId,PatientId,ProcedureTypeId" TableLayout="Fixed" CssClass="MasterClass"
                                GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AllowFilteringByColumn="false">
                                <Columns>
                                    <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure" SortExpression="ProcedureType" HeaderStyle-Width="120px" FilterControlWidth="120" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="false">
                                        <FilterTemplate>
                                            <telerik:RadComboBox AutoPostBack="false" RenderMode="Lightweight" ID="ProcedureCombo2" Width="120" SelectedValue='<%# CType(Container, GridItem).OwnerTableView.GetColumn("ProcedureType").CurrentFilterValue %>'
                                                runat="server" Skin="Metro" OnClientSelectedIndexChanged="ProcedureTypeComboIndexChanged2" ZIndex="99999" DataSourceID="ProcedureTypesObjectDataSource" DataTextField="ProcedureType" />
                                            <telerik:RadScriptBlock ID="RadScriptBlockProcedureType2" runat="server">
                                                <script type="text/javascript">
                                                    function ProcedureTypeComboIndexChanged2(sender, args) {
                                                        var tableView = $find("<%# CType(Container, GridItem).OwnerTableView.ClientID %>");
                                                        tableView.filter("ProcedureType", args.get_item().get_value(), "EqualTo");
                                                    }
                                                </script>
                                            </telerik:RadScriptBlock>
                                        </FilterTemplate>
                                    </telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="OrderDate" HeaderText="Order Date" SortExpression="OrderDate" DataType="System.DateTime" DataFormatString="{0:dd MMMM yyyy}" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" SortExpression="Surname" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Forename" HeaderText="Forename" SortExpression="Forename1" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="DateOfBirth" HeaderText="DOB" SortExpression="DateOfBirth" DataType="System.DateTime" DataFormatString="{0:dd MMMM yyyy}" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Case Note Number" SortExpression="HospitalNumber" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="NHSNo" HeaderText="NHS Number" SortExpression="NHSNo" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="DueDate" HeaderText="Due Date" SortExpression="DueDate" DataType="System.DateTime" DataFormatString="{0:dd MMMM yyyy}" HeaderStyle-Width="130px" FilterControlWidth="120px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="AssignedCareProfessional" HeaderText="Assigned Care Professional" SortExpression="AssignedCareProfessional" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="Referrer" HeaderText="Referrer" SortExpression="Referrer" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                    <telerik:GridBoundColumn DataField="OrderNumber" HeaderText="Order Number" SortExpression="OrderNumber" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
                                </Columns>
                                <NoRecordsTemplate>
                                    <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                                        No patients found.
                                    </div>
                                </NoRecordsTemplate>
                            </MasterTableView>
                            <GroupingSettings CaseSensitive="false" CollapseAllTooltip="Collapse all groups"></GroupingSettings>
                            <ClientSettings EnableRowHoverStyle="true">
                                <Resizing AllowColumnResize="true" ResizeGridOnColumnResize="true" AllowResizeToFit="true" />
                                <Selecting AllowRowSelect="true" />
                                <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                                <ClientEvents OnRowContextMenu="showContextMenuOrd" OnRowSelecting="waitlistRowSelected" OnRowClick="waitlistRowSelected" OnRowDblClick="searchSlotFromWaitlist" />
                            </ClientSettings>
                            <AlternatingItemStyle BackColor="#fafafa" />
                            <HeaderStyle BackColor="#f4f7f9" Font-Bold="true" Height="10" />
                            <SortingSettings SortedBackColor="ControlLight" />
                        </telerik:RadGrid>


                    </telerik:RadPageView>
                    <telerik:RadPageView ID="OrderHistoryPageView" runat="server" Height="510px">
                    </telerik:RadPageView>
                </telerik:RadMultiPage>
                <div id="OrderButtons" runat="server" height="78px" style="padding-top: 25px; text-align: center;">
                    <telerik:RadButton ID="btnOrderReject" runat="server" Text="Reject" Skin="Metro" OnClick="CancelSearchButton_Click" ValidationGroup="SlotSearch" />
                    <telerik:RadButton ID="btnOrderAddToWaitlist" runat="server" Text="Add to Waitlist" Skin="Metro" OnClick="CancelSearchButton_Click" AutoPostBack="False" />
                    <telerik:RadButton ID="btnOrderPrint" runat="server" Text="Print" Skin="Metro" OnClick="CancelSearchButton_Click" AutoPostBack="False" />
                    <telerik:RadButton ID="btnOrderClose" runat="server" Text="Close" Skin="Metro" OnClick="CancelSearchButton_Click" AutoPostBack="False" />
                </div>
            </div>
            <div id="divWaitDetails" runat="server" visible="false" style="padding-top: 15px;">
                <table border="0" style="width: 100%;">
                    <tr>
                        <td style="min-width: 550px !important; vertical-align: top;">
                            <fieldset runat="server" id="WaitlistPatient">
                                <legend>Patient Information</legend>
                                <table style="width: 100%">
                                    <tr>
                                        <td>Name:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistPatientName" /></td>
                                    </tr>
                                    <tr>
                                        <td>Gender:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistPatientGender" /></td>
                                    </tr>
                                    <tr>
                                        <td>Address:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistPatientAddress" /></td>
                                    </tr>
                                    <tr>
                                        <td>DOB:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistPatientDOB" /></td>
                                    </tr>
                                    <tr>
                                        <td>Case note number:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistPatientHospitalNumber" /></td>
                                    </tr>
                                    <tr>
                                        <td>NHS number:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistPatientNHSNumber" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                        <td rowspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        </td>
                        <td rowspan="2" style="vertical-align: top;">
                            <fieldset runat="server" id="Fieldset4">
                                <legend>Order Comms information</legend>
                                <table>
                                    <tr>
                                        <td style="min-width: 200px !important;">Order Number:</td>
                                        <td>
                                            <asp:Label runat="server" ID="OrderCommOrderNumber" /></td>
                                        <td>Order Hospital:</td>
                                        <td>
                                            <asp:Label runat="server" ID="OrderCommOrderHospital" /></td>
                                    </tr>
                                    <tr>
                                        <td>Order Date:</td>
                                        <td>
                                            <asp:Label runat="server" ID="OrderCommOrderDate" /></td>
                                        <td>Ordered By:</td>
                                        <td>
                                            <asp:Label runat="server" ID="OrderCommOrderedBy" /></td>
                                    </tr>
                                    <tr>
                                        <td>Order Source:</td>
                                        <td>
                                            <asp:Label runat="server" ID="OrderCommOrderSource" /></td>
                                        <td>Due Date:</td>
                                        <td>
                                            <asp:Label runat="server" ID="OrderCommDueDate" /></td>
                                    </tr>
                                    <tr>
                                        <td>Referrer:</td>
                                        <td>
                                            <asp:Label runat="server" ID="OrderCommReferrer" /></td>
                                        <td>Ordered By Contact:</td>
                                        <td>
                                            <asp:Label runat="server" ID="OrderCommOrderedByContact" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top;">Clinical History:</td>
                                        <td colspan="3">
                                            <div id="ClinicalHistoryNotes" runat="server" style="height: 170px!important; overflow-y: scroll !important; white-space: normal;"></div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top;">Questions & Answers:</td>
                                        <td colspan="3">
                                            <div style="height: 170px!important; overflow-y: scroll !important; white-space: normal;">
                                                <asp:Repeater ID="rptQuestionsAnswers" runat="server">
                                                    <HeaderTemplate>
                                                        <table>
                                                            <tr>
                                                                <th style="text-align: left; vertical-align: top;">Question</th>
                                                                <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
                                                                <th style="text-align: left; vertical-align: top">Answer</th>
                                                            </tr>
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <tr style="vertical-align: top;">
                                                            <td><%# Eval("Question") %></td>
                                                            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                            <td><%# Eval("Answer") %></td>
                                                        </tr>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        </table>
                                                    </FooterTemplate>
                                                </asp:Repeater>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>

                        </td>
                    </tr>
                    <tr>
                        <td style="vertical-align: top;">
                            <fieldset runat="server" id="WaitlistInformation">
                                <legend>Wait List Information</legend>
                                <table>
                                    <tr>
                                        <td>Procedure:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistInfoProcedure" /></td>
                                    </tr>
                                    <tr>
                                        <td>Priority:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistInfoPriority" /></td>
                                    </tr>
                                    <tr>
                                        <td>Date raised:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistInfoDateRaised" /></td>
                                    </tr>
                                    <tr>
                                        <td>Book by:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistInfoBookBy" /></td>
                                    </tr>
                                    <tr>
                                        <td>Days until breach:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistInfoDaysToBreach" /></td>
                                    </tr>
                                    <tr>
                                        <td>wait days::</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistInfoWaitDays" /></td>
                                    </tr>
                                    <tr>
                                        <td>Referrer:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistInfoReferrer" /></td>
                                    </tr>
                                    <tr>
                                        <td>Notes:</td>
                                        <td>
                                            <asp:Label runat="server" ID="WaitlistInfoNotes" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" style="text-align: center; padding-top: 5px;">
                            <telerik:RadButton ID="radCloseWaitDetails" runat="server" Text="Close" Skin="Office2007">
                            </telerik:RadButton>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <asp:ObjectDataSource ID="EndoscopistObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetEndoscopist">
            <SelectParameters>
                <asp:ControlParameter Name="IsGIConsultant" ControlID="SearchGIProcedureRadioButtons" PropertyName="SelectedValue" DbType="Boolean" DefaultValue="true" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="NonGIProceduresObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetProcedureTypes">
            <SelectParameters>
                <asp:Parameter Name="isGI" Type="Boolean" DefaultValue="false" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="ProcedureTypesObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetProcedureTypes">
            <SelectParameters>
                <asp:Parameter Name="isGI" Type="Boolean" DefaultValue="true" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="ProcedureTypesObjectDataSourceForFilter" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetProcedureTypesForFilter">
            <SelectParameters>
                <asp:Parameter Name="isGI" Type="Boolean" DefaultValue="true" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="HospitalNameObjectDataSourceForFilter" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetHospitalNameForFilter">
            <SelectParameters>
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="SlotStatusObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSlotStatus">
            <SelectParameters>
                <asp:Parameter Name="GI" DbType="Byte" DefaultValue="1" />
                <asp:Parameter Name="nonGI" DbType="Byte" DefaultValue="1" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="SlotStatusObjectDataSourceForFilter" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSlotStatusForFilter">
            <SelectParameters>
                <asp:Parameter Name="GI" DbType="Byte" DefaultValue="1" />
                <asp:Parameter Name="nonGI" DbType="Byte" DefaultValue="1" />
            </SelectParameters>
        </asp:ObjectDataSource>


        <telerik:RadWindowManager ID="AddNewTitleRadWindowManager" runat="server" ShowContentDuringLoad="false"
            Behaviors="Move" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="ExternalRadWindow" runat="server" CssClass="rad-window-popup" VisibleStatusbar="false" Skin="Metro" />
                <telerik:RadWindow ID="BookingWindow" runat="server" Height="600" Width="950" AutoSize="true" CssClass="rad-window-popup" Behaviors="Close">
                    <%--this pops up OVER a radwindow, therefore has a different class in order to have a higher z-index--%>
                    <ContentTemplate>
                        <asp:Label ID="BookingSlotDateLabel" runat="server" CssClass="divWelcomeMessage" />

                        <div class="slot-options-popup" style="background-color: white; width: 350px; min-height: 150px; margin-top: 20px;">

                            <telerik:RadGrid ID="ListSlotsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                                Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 95%;" OnItemCreated="ListSlotsRadGrid_ItemCreated">
                                <MasterTableView HeaderStyle-Font-Bold="true" TableLayout="Fixed" ShowHeader="false" CssClass="MasterClass" DataKeyNames="RoomID,DiaryId,StartDate,ProcedureTypeID,StatusId,OperatingHospitalId">
                                    <Columns>
                                        <telerik:GridBoundColumn HeaderText="Description" DataField="Description" HeaderStyle-Height="0" AllowSorting="false" />
                                        <telerik:GridTemplateColumn HeaderStyle-Width="50px">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="BookSlotRadButton" runat="server" Text="Book" Font-Italic="true" OnClientClick="closeSlotWindow" />&nbsp;
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                    </Columns>
                                    <HeaderStyle Font-Bold="true" />
                                </MasterTableView>
                            </telerik:RadGrid>
                        </div>

                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="PatientBookingRadWindow" runat="server" Height="600" Width="950" AutoSize="false" CssClass="rad-window-popup" VisibleStatusbar="false" />

            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>
</html>
