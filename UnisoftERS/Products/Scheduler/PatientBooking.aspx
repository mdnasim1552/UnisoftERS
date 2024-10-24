<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PatientBooking.aspx.vb" Inherits="UnisoftERS.PatientBooking" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../Scripts/global.js"></script>

    <link href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .booking-confirmation {
            height: 170px !important;
        }

        a.rwCloseButton {
            visibility: hidden !important;
            display: none !important;
        }

        .notification-modal {
            display: none;
            position: absolute;
            left: 0px;
            top: 0px;
            z-index: 7778;
            background-color: rgb(170, 170, 170);
            opacity: 0.5;
            width: 100%;
            height: 100%;
        }
        #ConfirmContinueBookingRadNotification_popup
        {
            height: 188px !important;
        }
        .rnTitleBarTitle
        {
            font-weight: bold;
        }
        #ConfirmContinueBookingRadNotification_popup .rnContentWrapper
        {
            background-color: red !important;
            padding: 15px !important;
            color: white;
            height: 140px !important;
        }
        #ConfirmContinueBookingRadNotification_popup .rad-popup-action-buttons {
            display: flex !important;
            justify-content: flex-end !important;
            padding: 10px !important; 
            margin-top: 50px !important;
            position: relative !important;
        }
    </style>

    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            var docURL = document.URL;

            var d1 = new Date();
            var d2 = new Date(d1);
            d2.setMinutes(d1.getMinutes() + 15);

            // Update the count down every 1 second
            var x = setInterval(function () {

                // Get today's date and time
                var now = new Date().getTime();

                // Find the distance between now and the count down date
                var distance = d2 - now;

                // Time calculations for days, hours, minutes and seconds
                var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((distance % (1000 * 60)) / 1000);

                // Display the result in the element with id="demo"
                document.getElementById('<%=lblRemainingReservedTime.ClientID%>').innerHTML = minutes + "m " + seconds + "s ";

                // If the count down is finished, write some text
                if (distance < 0) {
                    clearInterval(x);
                    document.getElementById('<%=lblRemainingReservedTime.ClientID%>').innerHTML = "00:00";
                }
            }, 1000);

            function setVal(sender, args) {

            }
            function showModal() {
                $('.notification-modal').show();
            }

            function RemoveZero(sender, args) {
                var tbValue = sender._textBoxElement.value;
                if (tbValue == "0")
                    sender._textBoxElement.value = "";

                if (tbValue.endsWith('.00')) {
                    sender._textBoxElement.value = sender._textBoxElement.value.replace(".00", "");
                }
            }

            function RoundDecimal(sender, args) {
                var tbValue = sender._textBoxElement.value;

                if (tbValue.endsWith('.00')) {
                    sender._textBoxElement.value = sender._textBoxElement.value.replace(".00", "");
                }

                calculateBookingSlotPoints()
            }

            function BookingValueChanging(sender, args) {
                if (sender.get_value() == "") { //means procedure type hasnt been selected yet
                    args.set_cancel(true);//...so do not let the user enter a value
                }
            }
            function calculateBookingSlotLength() {
                var bookingLength = 0;

                //loop through slot length textboxes and calculate the booking length
                $('input[type="text"].booking-length').each(function (idx, itm) {
                    if ($(itm).val() != "")
                        bookingLength += parseInt($(itm).val());
                });

                $('.slot-length').val(bookingLength);
            }

            function calculateBookingSlotPoints() {
                var bookingLength = 0;

                //loop through slot length textboxes and calculate the booking length
                $('input[type="text"].booking-points').each(function (idx, itm) {
                    if ($(itm).val() != "")
                        bookingLength += parseFloat($(itm).val());
                });

                $('.slot-points').val(bookingLength);
            }

            function getCallInTimes() {
                //get list of selected procedure types
                var selectedProcTypes = [];

                $('[data-check-type] input[type="checkbox"]').each(function (index, item) {
                    if ($(item).is(':checked')) {
                        var procTypeId = $(item).closest('[data-val-id]').attr('data-val-id')
                        selectedProcTypes.push(parseInt(procTypeId));
                    }
                });

                if (selectedProcTypes.length > 0) {
                    //ajax call to return breech days
                    var obj = {};
                    obj.procedureTypeIds = selectedProcTypes;
                    obj.operatingHospitalId = parseInt(<%=OperatingHospitalID%>);

                    $.ajax({
                        type: "POST",
                        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Scheduler/Scheduler.aspx/CalculateBookingCallInTime",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (r) {
                            if (r.d != null) {
                                //set call in time textbox accordingly
                                var procedureDate = new Date($find('<%= StartTimeRadTimePicker.ClientID%>').get_selectedDate());
                                procedureDate.setMinutes(procedureDate.getMinutes() - parseInt(r.d));
                                $find('<%=CallInTimeRadTimePicker.ClientID%>').get_dateInput().set_value(procedureDate);
                            }
                        },
                        error: function (jqXHR, textStatus, data) {
                            console.log(jqXHR.responseJSON.Message);
                        }
                    });
                }
                else {
                    var procedureDate = new Date($find('<%= StartTimeRadTimePicker.ClientID%>').get_selectedDate());
                    $find('<%=CallInTimeRadTimePicker.ClientID%>').get_dateInput().set_value(procedureDate);
                }
            }

            function bindPageEvents() {
                $('[data-check-type] input[type=checkbox]').on('click', function () {

                    var procTypeId = parseInt($(this).closest('tr').find('[data-val-id]').attr("data-val-id"));

                    if ($(this).is(":checked")) {
                        var idVal = $(this).attr("id");
                        var type = $(this).closest('span').attr('data-check-type');
                        var therapeuticChecked = (type.toLowerCase() == 'therapeutic');
                        $(this).closest('tr').find('.define-button').attr("disabled", (therapeuticChecked == false));

                        if (type.toLowerCase() == 'therapeutic') {
                            $(this).closest('tr').find('[data-check-type=diagnostic] input').prop('checked', false);
                        }
                        else if (type.toLowerCase() == 'diagnostic') {
                            $(this).closest('tr').find('[data-check-type=therapeutic] input').prop('checked', false);
                        }


                        var obj = {};
                        obj.procedureTypeId = procTypeId;
                        obj.checked = $(this).is(":checked");
                        obj.operatingHospitalId = parseInt(<%=OperatingHospitalID%>);
                        obj.nonGI = false;
                        obj.isTraining = false;
                        obj.isDiagnostic = !therapeuticChecked;
                        $.ajax({
                            type: "POST",
                            url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Scheduler/Scheduler.aspx/GetProcedureLengths",
                            data: JSON.stringify(obj),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (data) {
                                if (data.d != null) {
                                    var retVal = JSON.parse(data.d);

                                    var procTypeId = retVal.procedureTypeId;
                                    var procedureLength = retVal.length;
                                    var procedurePoints = retVal.points;

                                    $find($('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-length').attr("id")).set_enabled(true);
                                    $find($('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-points').attr("id")).set_enabled(true);


                                    $('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-length').val(procedureLength);
                                    $('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-points').val(procedurePoints);
                                    calculateBookingSlotLength();
                                    calculateBookingSlotPoints();
                                }
                            },
                            error: function (jqXHR, textStatus, data) {
                                console.log(jqXHR.responseText);

                                //$('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-length').attr("disabled", false);
                                //$('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-points').attr("disabled", false);

                                $('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-length').val(15);
                                $('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-points').val(1);

                                calculateBookingSlotLength();
                                calculateBookingSlotPoints();
                            }
                        });
                    }
                    else {
                        var type = $(this).closest('span').attr('data-check-type');
                        var therapeuticChecked = (type.toLowerCase() == 'therapeutic');
                        if (therapeuticChecked) {
                            $(this).closest('tr').find('.define-button').attr("disabled", true);
                        }

                        $find($('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-length').attr("id")).set_enabled(false);
                        $find($('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-points').attr("id")).set_enabled(false);

                        $('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-length').val("");
                        $('[data-val-id="' + procTypeId + '"]').closest('tr').find('.booking-points').val("");
                        calculateBookingSlotLength();
                        calculateBookingSlotPoints();
                    }

                    getCallInTimes();
                });

                $('.define-button').on('click', function () {
                    var procedureType = $(this).attr("data-proc-type");
                    var procedureTypeID = $(this).attr("data-proc-id");
                    var endoscopistID = $(this).attr("data-endoscopist-id");
                    var own = radopen("../Options/Scheduler/TherapeuticTypes.aspx?ProcedureType=" + procedureType + "&ProcedureTypeID=" + procedureTypeID + "&mode=search&EndoscopistId=" + endoscopistID, "Define " + procedureType + " therapeutic procedures", '500px', '550px');
                    own.set_visibleStatusbar(false);
                    return false;
                });
            }

            $(window).on('load', function () {
                bindPageEvents();

                $('.booking-therapeutic-checkbox input').each(function (itm, idx) {
                    if ($(this).is(':checked')) {
                        //get define button and set enabled
                        var btnDefine = $(itm).closest('tr').find('.define-button').attr("disabled", false);
                    }
                });
            });

            $(document).ready(function () {
                Sys.Application.add_load(function loadHandler() {
                    bindPageEvents();

                    Sys.Application.remove_load(loadHandler);
                });
            });

            function CheckSetNumericFieldTime(sender, args) {
                var nextValue = args._newValue.toString();
                if (nextValue.substring(nextValue.indexOf(".") + 1, 2) == "60") {
                    var newValue = args._newValue + 40;
                }
            }

            function checkPatientsFutureBookings(sender, args) {
                var patientId = $(sender).attr('data-patID');
                var patNHSNo = $(sender).attr('data-patNHSNo');
                var RetrivedFrom = $(sender).attr('data-RetrivedFrom');
                var patientName = "";

                var obj = {};
                obj.patientId = parseInt(patientId);
                obj.patNHSNo = patNHSNo;
                obj.RetrivedFrom = RetrivedFrom;

                $.ajax({
                    type: "POST",
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Scheduler/Scheduler.aspx/ImportPatientAndGetPatientBookings",
                    data: JSON.stringify(obj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (r) {
                        if (r.d != null) {
                            var result = JSON.parse(r.d);

                            if (result.length > 0) {
                                var message = "This patient is already scheduled on <br />";

                                $(result).each(function (index, item) {
                                    message = message + item.BookingDate + " for " + item.ProcedureType + "<br />";
                                });

                                message = message + "<p>Do you still wish to continue?</p>"
                                $('#<%=PreviousBookingMessageLabel.ClientID%>').html(message);
                                var oWnd = $find("<%= PreviousPatientBookingsWindow.ClientID %>");
                                if (oWnd != null) {
                                    oWnd.set_title("Schedule Booking");
                                    oWnd.show();
                                }
                            }
                        }
                    }
                });
            }

            function validateBookingForm(sender, args) {
                var validationMessage = "";
                var isValid = true;
                var giDiv = $('#<%=GIProceduresDiv.ClientID%>');
                var nonGIDiv = $('#<%=NonGIProceduresDiv.ClientID%>');
                var procedureTypes = [];
                var slotType = <%=SelectedSlotId%>;
                var bookingMode = '<%=Action%>';
                var slotLength = 0;
                if (<%=SlotDuration%> != undefined) {
                    slotLength = <%=SlotDuration%>;
                }
                else {
                    slotLength = 0;
                }

                //validate procedures
                var hasCheckedProcedure = false;
                if (giDiv.length > 0) {
                    $('[data-check-type] input[type="checkbox"]').each(function (index, item) {
                        if ($(item).is(':checked')) {
                            hasCheckedProcedure = true;
                            procedureTypes.push($(item).val());
                        }
                    });
                } else {
                    hasCheckedProcedure = true;
                    if (nonGIDiv.length > 0) {
                        if ($('#<%=NonGIProcedureTypeRadioButtonList.ClientID%> input').val() == "") {
                            isValid = false;
                            validationMessage += "&bull;Select the procedure type (diagnostic/therapeutic)<br />";
                        }
                    }
                }

                if (hasCheckedProcedure == false) {
                    isValid = false;
                    $('#<%=ProcedureTypesValidationLabel.ClientID %>').text("*");
                    validationMessage += "&bull;Select at least one procedure type<br />";
                }

                //validate slot status
                if ($('#<%=PatientBookingSlotStatusRadioButtons.ClientID %> input:checked').val() == undefined) {
                    isValid = false;
                    $('#<%=PatientBookingStatusValidationLabel.ClientID %>').text("*");
                    validationMessage += "&bull;Select a slot status<br />";
                }

                //validate offer date
                if ($('#<%=BookingFirstOfferDate.ClientID%>').val() == "") {
                    isValid = false;
                    $('#<%=BookingFirstOfferDate.ClientID%>').addClass('validation-error-field');
                    validationMessage += "&bull;Select an offer date";
                }

        //validate call in time
                <%--if ($('#<%=CallInTimeRadNumericTextBox.ClientID%>').val() == "") {
                    isValid = false;
                    $('#<%=CallInTimeRadNumericTextBox.ClientID%>').addClass('validation-error-field');
                    validationMessage += "&bull;Set a call-in time";
                }

                //validate start time
                if ($('#<%=StartTimeRadNumericTextBox.ClientID%>').val() == "") {
                    isValid = false;
                    $('#<%=StartTimeRadNumericTextBox.ClientID%>').addClass('validation-error-field');
                    validationMessage += "&bull;Set a start time";
                }--%>

                //validate slot length
                if ($('#<%=BookingSlotLengthRadNumericTextBox.ClientID%>').val() == "" || $('#<%=BookingSlotLengthRadNumericTextBox.ClientID%>').val() == 0) {
                    isValid = false;
                    $('#<%=BookingSlotLengthRadNumericTextBox.ClientID%>').addClass('validation-error-field');
                    validationMessage += "&bull;Set a slot length of greater than 0";
                }

                if (isValid == false) {
                    if ($find('#masterValDiv')) {
                        $('#masterValDiv').html(validationMessage);
                        $('#ValidationNotification').show();
                        $('.validation-modal').show();
                    }
                    else {
                        //create modal for window
                        $('#masterValDiv', parent.document).html(validationMessage);
                        $('#ValidationNotification', parent.document).show();
                        $('.validation-modal', parent.document).show();
                    }
                    args.set_cancel(true);
                }
                else {
                    //check if slots proc type is whats been selected and confirm change if not
                    //check if slot type/priority is whats been selected and confirm change if not
                    if (bookingMode.toLowerCase() != 'edit' && slotType != $('#<%=PatientBookingSlotStatusRadioButtons.ClientID %> input:checked').val()) {
                        var originalSlotName = $('#<%=PatientBookingSlotStatusRadioButtons.ClientID %> input[value=' + slotType + ']').closest('td').find('label').text(); //[value=" + value + "]
                        var selectedSlotName = $('#PatientBookingSlotStatusRadioButtons input:checked').closest('td').find('label').text();

                        if (!confirm('You are about to book a ' + selectedSlotName.toUpperCase() + ' slot into a ' + originalSlotName.toUpperCase() + ' slot. Continue?')) {
                            args.set_cancel(true);
                        }
                    }

            //check if selected length is greater than original slot length and confirm overrun
                   <%-- var selectedSlotLength = $find('<%=BookingSlotLengthRadNumericTextBox.ClientID%>').get_textBoxValue();
                    if (selectedSlotLength > slotLength) {
                        var slotDifference = (selectedSlotLength - slotLength);
                        if (!confirm('Your list will overrun by ' + slotDifference + ' minutes. Continue?')) {
                            args.set_cancel(true);
                        }
                    }--%>

                    //check if gender being booked is opposite to the gender of the list e.g. male booked in female list                    
                    var diaryListGenderType = '<%= Session("DiaryGenderType") %>';
                    var patientGenderLabelValue = $('#PatientGenderLabel').text();

                    if (diaryListGenderType != '') {
                        if (diaryListGenderType != patientGenderLabelValue) {
                            if (!confirm('You are booking a ' + patientGenderLabelValue + ' patient in to a ' +
                                diaryListGenderType + ' list. Do you wish to schedule this patient?')) {
                                args.set_cancel(true);
                            }
                        }
                    }
                }
            }

            function CloseBookingWindow() {
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/UnlockReservedSlot",
                    data: JSON.stringify({ "endoscopistId": parseInt(<%=DataAdapter.LoggedInUserId%>) }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    error: function (jqXHR, textStatus, data) {
                        //alert("An error occured");
                    }
                });

                CloseWindow();

            }

            function CloseWindow() {
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null; if (window.radWindow)
                    oWindow = window.radWindow; else if (window.frameElement.radWindow)
                    oWindow = window.frameElement.radWindow; return oWindow;
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

            function CloseAndContinueBookingWindow() {
                var oWnd = $find("<%= PreviousPatientBookingsWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function GetParameterValues(param) {
                var url = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
                for (var i = 0; i < url.length; i++) {
                    var urlparam = url[i].split('=');
                    if (urlparam[0] == param) {
                        return urlparam[1];
                    }
                }
            }


            function getNonGISlotLength(procedureTypeId, ctrl, isDiagnostic) {
                var slotLength = $('.slot-length').val();//$('[data-check-type] input:checked').length;

                var obj = {};
                obj.procedureTypeId = parseInt(procedureTypeId);
                obj.checked = $(ctrl).is(":checked");
                obj.nonGI = true;
                obj.isTraining = false;
                obj.isDiagnostic = isDiagnostic;

                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/GetProcedureLengths",
                    data: JSON.stringify(obj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (r) {
                        if (r.d != null) {
                            var retVal = JSON.parse(r.d);

                            if (retVal.checked) {
                                $('.slot-length').val(parseInt(slotLength) + parseInt(retVal.length));
                            }
                            else {
                                $('.slot-length').val(parseInt(slotLength) - parseInt(retVal.length));

                            }
                        }
                    }
                });
            }

            function CancelBookingRadButtonClicked(sender, args) {
                if ($find('<%=CancelBookingRadButton.ClientID%>').get_commandName() == "uncheckProcedure") {
                    $('[data-check-type] input[type="checkbox"]').each(function (index, item) {
                        var type = $(this).closest('span').attr('data-check-type');

                        //toggle checkbox groups
                        if (type.toLowerCase() == 'therapeutic') {
                            $(this).closest('tr').find('[data-check-type=diagnostic] input').prop('checked', false);
                        }
                        else if (type.toLowerCase() == 'diagnostic') {
                            $(this).closest('tr').find('[data-check-type=therapeutic] input').prop('checked', false);
                        }

                        $(this).closest('tr').find('.define-button').attr("disabled", true);

                    });
                }

                $find('<%=ConfirmContinueBookingRadNotification.ClientID%>').hide();

                CloseAndRebind();
            }

            function YesContinueBookingRadButtonClientClicking(sender, args) {
                if ($find('<%=YesContinueBookingRadButton.ClientID%>').get_commandName() == "") {
                    $find('<%=ConfirmContinueBookingRadNotification.ClientID%>').hide();
                    args.set_cancel(true);
                }
            }

            function OpenPDF() {
                window.open('../Letters/DisplayAndPrintPDF.aspx', "_blank");
            }

            function OpenLetterForEdit1(appointmentId) {
                window.open('../Letters/EditLetterWindow.aspx?AppointmentId=' + appointmentId, "_blank");
            }


            function OpenLetterForEdit(appointmentId) {
                window.open('../Letters/EditLetterWindow.aspx?AppointmentId=' + appointmentId);

                //ajax call to check if a letter is present, opening the edit window only after success
                 <%--$.ajax({
                    type: "POST",
                    url: "../WebMethods.aspx/checkForBookingLetter",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        if (data.d == true) {
                            window.open('../Letters/EditLetterWindow.aspx?AppointmentId=' + appointmentId);
                        }
                        else {
                            alert('No letter template found');
                        }
                    },
                    error: function (x, y, z) {
                       autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                    }
                 });--%>


            }

        </script>

    </telerik:RadScriptBlock>
</head>
<body style="font-size: 12px !important; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif">
    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />

        <telerik:RadAjaxManager runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="PatientSearchDiv">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PatientSearchDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="BookingDiv">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="BookingDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SearchPatientsRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PatientSearchDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SaveBookingRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="BookingWindowRadNotification" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="CancelBookingRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ConfirmContinueBookingRadNotification" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <asp:HiddenField ID="SelectedDiaryIdHiddenField" runat="server" />
        <asp:HiddenField ID="SelectedSlotDateHiddenField" runat="server" />
        <asp:HiddenField ID="SelectedRoomIdHiddenField" runat="server" />

        <div id="FormDiv">
            <div id="PatientSearchDiv" runat="server">
                <telerik:RadNotification ID="PatientSearchBookingWindowRadNotification" runat="server" Skin="Metro" VisibleOnPageLoad="false" CssClass="top-rad-window-popup" />

                <div style="padding: 15px;">
                    <div class="patient-search-div">
                        <fieldset>
                            <legend>Search Patient</legend>

                            <table cellpadding="2" cellspacing="2">
                                <tr>
                                    <td>Hospital number:</td>
                                    <td>
                                        <asp:TextBox ID="PatientSearchCNNTextBox" runat="server" Width="250" /></td>
                                </tr>
                                <tr id="CountryOfOriginHealthServiceNoRadTextBoxSearchRow" runat="server" visible="True">
                                    <td id="HealthServiceNameIdTd" runat="server">NHS Number:</td>
                                    <td><asp:TextBox ID="PatientSearchHealthServiceNoRadTextBox" runat="server" Width="250" /></td>
                                </tr>
                                <tr>
                                    <td>Surname:</td>
                                    <td>
                                        <asp:TextBox ID="PatientSearchSurnameTextBox" runat="server" Width="250" /></td>
                                </tr>
                                <tr>
                                    <td>Forename:</td>
                                    <td>
                                        <asp:TextBox ID="PatientSearchForenameTextBox" runat="server" Width="250" /></td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <telerik:RadButton ID="SearchPatientButton" runat="server" Text="Find" OnClick="SearchPatientButton_Click" Skin="Metro" />
                                        &nbsp;
                                    <telerik:RadButton ID="CancelSearchPatientButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="CloseWindow" AutoPostBack="false" />
                                    </td>
                                </tr>
                            </table>

                        </fieldset>
                    </div>
                    <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadPatients" SelectedIndex="1" ReorderTabsOnSelect="true" Skin="Metro"
                        Orientation="HorizontalTop" Visible="false">
                        <Tabs>
                            <telerik:RadTab Text="Search Results" Font-Bold="true" Value="0" Visible="false" />
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="RadPatients" runat="server" SelectedIndex="1">
                        <telerik:RadPageView ID="searchResultsRadPage" runat="server" Visible="true">
                            <div class="patient-search-results-div" style="margin-top: 10px; height: 415px; overflow-y: auto;">
                                <asp:Label class="divWelcomeMessage" ID="lblWelcomeMessage" runat="server" Text="Search results" Style="margin-left: 15px;" />
                                <asp:Label ID="PatientNotFoundLabel" runat="server" Text="" Visible="false" />
                                <telerik:RadGrid ID="PatientSearchResultsRadGrid" runat="server" GridLines="None" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                                    Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 95%;"
                                    OnItemCommand="RadGrid_ItemCommand">
                                    <MasterTableView TableLayout="Fixed" CssClass="MasterClass" ShowHeadersWhenNoRecords="true" ClientDataKeyNames="PatientId" DataKeyNames="PatientId,Title,Forename1,Surname,NHSNo,DateOfBirth,HospitalNumber,Gender">
                                        <NoRecordsTemplate>
                                             <div style="padding: 15px;" id="NoRecordsDiv" class="rgNoRecords" runat ="server">
                                                <em>No patients found.</em>
                                            </div>
                                        </NoRecordsTemplate>
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="Title" HeaderText="Title" SortExpression="Title" HeaderStyle-Width="60px" HeaderStyle-Height="0" AllowSorting="false" />
                                            <telerik:GridBoundColumn DataField="Forename1" HeaderText="Forename" SortExpression="Forename1" HeaderStyle-Width="130px" HeaderStyle-Height="0" AllowSorting="false" ItemStyle-Wrap="true" />
                                            <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" SortExpression="Surname" HeaderStyle-Width="150px" HeaderStyle-Height="0" AllowSorting="false" ShowSortIcon="true" />
                                            <telerik:GridBoundColumn DataField="NHSNo" UniqueName="HealthServiceNameColumn" HeaderText="NHS No" SortExpression="NHSNo" HeaderStyle-Width="80px" HeaderStyle-Height="0" AllowSorting="false" />
                                            <telerik:GridBoundColumn DataField="DateOfBirth" HeaderText="DOB" SortExpression="Dateofbirth" HeaderStyle-Width="100px" HeaderStyle-Height="0" AllowSorting="false" ShowSortIcon="true" DataFormatString="{0:dd/MM/yyyy}" />
                                            <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Hospital no" SortExpression="HospitalNumber" HeaderStyle-Width="100px" HeaderStyle-Height="0" AllowSorting="false" ShowSortIcon="true" />
                                            <telerik:GridTemplateColumn HeaderStyle-Width="35px">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="SelectPatientLinkButton" runat="server" Text="Select" Font-Italic="true" CommandArgument='<%#Eval("HospitalNumber") %>' data-patID='<%#Eval("PatientId") %>' data-patNHSNo='<%#Eval("NHSNo") %>'  data-RetrivedFrom='<%#Session("PatientBookingSearchSource")%>'   CommandName="bookpatient" OnClientClick='checkPatientsFutureBookings(this)' />&nbsp;
                                                </ItemTemplate>
                                            </telerik:GridTemplateColumn>
                                        </Columns>
                                    </MasterTableView>
                                    <ClientSettings>
                                        <Selecting AllowRowSelect="true" />
                                    </ClientSettings>
                                </telerik:RadGrid>

                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                </div>
            </div>
            <div id="BookingDiv" runat="server" style="display: none; overflow-y:auto;">
                <div>

                    <telerik:RadNotification ID="CanNotCreateAppointmentRadNotification" runat="server" VisibleOnPageLoad="false" />

                    <telerik:RadNotification ID="ConfirmContinueBookingRadNotification" AutoCloseDelay="0" runat="server" VisibleOnPageLoad="false" Height="140px" CssClass="rad-window-popup" ShowCloseButton="true" Skin="Metro" Title="Please confirm" Position="Center">
                        <ContentTemplate>
                            <div>
                                <div style="text-align: center;margin-top: 31px">
                                    <asp:Label ID="ConfirmContinueBookingMessageLabel" runat="server" Text="Your list will overrun by {0} points. Do you still want to continue with your booking?" /><br />
                                </div>
                                <div class="rad-popup-action-buttons" style="text-align: center;">
                                    <telerik:RadButton ID="YesContinueBookingRadButton" runat="server" Text="Yes" OnClientClicking="YesContinueBookingRadButtonClientClicking" OnClick="YesContinueBookingRadButton_Click" />
                                    &nbsp;
                                <telerik:RadButton ID="CancelBookingRadButton" runat="server" Text="No" OnClientClicked="CancelBookingRadButtonClicked" AutoPostBack="false" />
                                </div>
                            </div>
                        </ContentTemplate>
                    </telerik:RadNotification>
                    <telerik:RadNotification ID="BookingErrorRadNotification" runat="server" VisibleOnPageLoad="false" Height="170px" CssClass="rad-window-popup" ShowCloseButton="true" Skin="Metro" Title="Booking error" AutoCloseDelay="0" />
                    <div class="notification-modal"></div>
                    <telerik:RadNotification ID="BookingWindowRadNotification" runat="server" VisibleOnPageLoad="false" Height="170px" CssClass="rad-window-popup booking-confirmation" ShowCloseButton="false" Skin="Metro" Title="Booking saved">
                        <ContentTemplate>
                            <div style="height: 170px;">
                                <div style="text-align: center; padding: 15px; height: 120px;">
                                    Booking saved for
                            <asp:Label ID="BookingDetailsLabel" runat="server" /><br />
                                    Would you like to navigate to the booked date?
                                </div>
                                <div class="rad-popup-action-buttons" style="text-align: center;">
                                    <telerik:RadButton ID="NavigateToBookingRadButton" runat="server" Text="Yes, navigate to booking" OnClick="NavigateToBookingRadButton_Click" />
                                    &nbsp;
                            <telerik:RadButton ID="NavigateToTodayRadButton" runat="server" Text="No, go to today" OnClick="NavigateToTodayRadButton_Click" />
                                </div>
                            </div>
                        </ContentTemplate>
                    </telerik:RadNotification>
                    <div style="width: 100%; padding-top: 5px; text-align: right; color: red;">
                        Your slot will be reserved for the next:
                        <asp:Label ID="lblRemainingReservedTime" runat="server" />
                    </div>

                    <div style="width: 51%; float: left;">
                        <fieldset>
                            <legend>Procedures
                                    <asp:Label ID="ProcedureTypesValidationLabel" runat="server" CssClass="validation-message" Text=" " />
                            </legend>
                            <div id="GIProceduresDiv" runat="server" style="height:200px; overflow-y:auto;">
                                <asp:HiddenField ID="SlotRunningTotalHiddenField" runat="server" Value="0" />
                                <asp:Repeater ID="PatientBookingProceduresRepeater" runat="server" OnItemCreated="PatientBookingProceduresRepeater_ItemCreated" OnItemCommand="PatientBookingProceduresRepeater_ItemCommand">
                                    <HeaderTemplate>
                                        <table cellpadding="4" id="PatientBookingProcedures">
                                            <tr>
                                                <td>Diagnostic</td>
                                                <td>Therapeutic</td>
                                                <td></td>
                                                <td>Length of slot</td>
                                                <td>Points</td>
                                            </tr>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <asp:HiddenField ID="ProcedureTypeHiddenField" runat="server" Value='<%#Eval("SchedulerProcName") %>' />
                                                <asp:HiddenField ID="ProcedureTypeIDHiddenField" runat="server" Value='<%#Eval("ProcedureTypeID") %>' />
                                                <asp:CheckBox ID="DiagnosticProcedureTypesCheckBox" runat="server" data-val-id='<%#Eval("ProcedureTypeID") %>' data-check-type="diagnostic" GroupName="procedure-group" />
                                                <asp:Label ID="DiagnosticProcedureTypesCheckBoxLabel" runat="server" Text='<%#Eval("SchedulerProcName") %>' />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="TherapeuticProcedureTypesCheckBox" runat="server" CssClass="booking-therapeutic-checkbox" data-val-id='<%#Eval("ProcedureTypeID") %>' data-check-type="therapeutic" GroupName="procedure-group" />
                                                <asp:Label ID="TherapeuticProcedureTypesCheckBoxLabel" runat="server" Text='<%#Eval("SchedulerProcName") %>' />
                                            </td>
                                            <td>
                                                <asp:Button ID="DefineTherapeuticProcedureButton" runat="server" Text="Define" Enabled="false" CssClass="define-button" data-proc-type='<%#Eval("SchedulerProcName") %>' data-proc-id='<%#Eval("ProcedureTypeID") %>' />
                                            </td>
                                            <td>
                                                <telerik:RadNumericTextBox ID="BookingLengthRadNumericTextBox" CssClass="booking-length" runat="server" SpinDownCssClass="booking-length" SpinUpCssClass="booking-length"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="1">
                                                    <NumberFormat DecimalDigits="0" />
                                                    <ClientEvents OnValueChanging="BookingValueChanging" OnValueChanged="calculateBookingSlotLength" OnLoad="RemoveZero" />
                                                </telerik:RadNumericTextBox>
                                            </td>
                                            <td>
                                                <telerik:RadNumericTextBox ID="BookingPointsRadNumericTextBox" CssClass="booking-points" runat="server"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="0.5"
                                                    Width="35px"
                                                    MinValue="1"
                                                    MaxValue="24"
                                                    >
                                                    <NumberFormat DecimalDigits="2" />
                                                    <ClientEvents OnValueChanging="BookingValueChanging" OnValueChanged="RoundDecimal" OnLoad="RemoveZero" />
                                                </telerik:RadNumericTextBox>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        </table>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                            <div id="NonGIProceduresDiv" runat="server" visible="false">
                                <asp:Label ID="NonGIProcedureLabel" runat="server" Style="margin-left: 10px; font-size: 15px; font-weight: bold; text-transform: capitalize;" /><br />
                                <asp:HiddenField ID="ProcedureTypeHiddenField" runat="server" />

                                <table>
                                    <tr>
                                        <td>
                                            <asp:RadioButtonList ID="NonGIProcedureTypeRadioButtonList" runat="server" RepeatDirection="Horizontal">
                                                <asp:ListItem Text="Diagnostic" Value="diagnostic" Selected="True" />
                                                <asp:ListItem Text="Therapeutic" Value="therapeutic" />
                                            </asp:RadioButtonList>
                                        </td>
                                        <td>
                                            <telerik:RadNumericTextBox ID="BookingLengthRadNumericTextBox" CssClass="booking-length" runat="server" SpinDownCssClass="booking-length" SpinUpCssClass="booking-length"
                                                
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="5"
                                                Width="35px"
                                                MinValue="1">
                                                <NumberFormat DecimalDigits="0" />
                                                <ClientEvents OnValueChanging="BookingValueChanging" OnValueChanged="calculateBookingSlotLength" OnLoad="RemoveZero" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td>
                                            <telerik:RadNumericTextBox ID="BookingPointsRadNumericTextBox" CssClass="booking-points" runat="server"
                                                
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="0.5"
                                                Width="35px"
                                                MinValue="0.5">
                                                <NumberFormat DecimalDigits="2" />
                                                <ClientEvents OnValueChanging="BookingValueChanging" OnValueChanged="calculateBookingSlotPoints" OnLoad="RemoveZero" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </fieldset>
                        <fieldset>
                            <legend>Patient Status
                                        <asp:Label ID="PatientBookingStatusValidationLabel" runat="server" CssClass="validation-message" Text=" " />
                            </legend>
                            <div style="margin-bottom: 20px; text-align: center;">
                                <asp:RadioButtonList ID="PatientBookedStatusRadioButtons" runat="server" RepeatDirection="Horizontal">
                                    <asp:ListItem Value="P">Partially Booked</asp:ListItem>
                                    <asp:ListItem Value="B">Patient Confirmed</asp:ListItem>
                                </asp:RadioButtonList>
                            </div>
                            <div style="height:165px; overflow-y:auto;">
                                <asp:Label ID="PatientSlotStatusValidationLabel" runat="server" CssClass="validation-message" />
                                <asp:RadioButtonList ID="PatientBookingSlotStatusRadioButtons" Enabled="true" runat="server" Style="width: 100%;" DataSourceID="SlotStatusObjectDataSource" DataValueField="StatusId" DataTextField="Description" RepeatColumns="2" RepeatDirection="Vertical" />
                            </div>
                        </fieldset>
                    </div>
                    <div style="width: 49%; float: left">
                        <fieldset>
                            <legend>Patient Details</legend>
                            <div style="float: left; width: 50%;">
                                <asp:HiddenField ID="PatientIDHiddenField" runat="server" />
                                <table class="patient-details-table">
                                    <tr>
                                        <td>Patient Name:</td>
                                        <td>
                                            <asp:Label ID="PatientNameLabel" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>Date of Birth:</td>
                                        <td>
                                            <asp:Label ID="PatientDOBLabel" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>Hospital No:</td>
                                        <td>
                                            <asp:Label ID="PatientCaseNoteLabel" runat="server" /></td>
                                    </tr>
                                    <tr id="CountryOfOriginHealthServiceNoBookingRow" runat="server">
                                        <td id="HealthServiceNameIdBookingTd" runat="server">NHS No:</td>
                                        <td>
                                            <asp:Label ID="PatientNHSNoLabel" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Gender:</td>
                                        <td>
                                            <asp:Label ID="PatientGenderLabel" runat="server" /></td>
                                    </tr>
                                </table>
                            </div>
                            <div style="float: right; width: 50%;">
                                <table>
                                    <tr>
                                        <td>Referral Date</td>
                                        <td>
                                            <telerik:RadDatePicker ID="BookingReferralDate" runat="server" MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/3000" Width="105" ZIndex="78945" />
                                        </td>
                                    </tr>
                                    <tr style="display: none;">
                                        <td>
                                            <asp:Label ID="FirstOfferDateLabel" runat="server" Text="Offer Date" /></td>
                                        <td>
                                            <telerik:RadDatePicker ID="BookingFirstOfferDate" runat="server" MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/3000" Width="105" ZIndex="78945" />
                                        </td>
                                    </tr>
                                    <tr style="display: none;">
                                        <td>
                                            <asp:Label ID="SecondOfferDateLabel" runat="server" Text="2nd Offer Date" /></td>
                                        <td>
                                            <telerik:RadDatePicker ID="BookingSecondOfferDate" runat="server" MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/3000" Width="105" ZIndex="78945" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <br />
                            <div style="margin-top: 55px;">
                                <table style="width: 40%;">
                                    <%--<tr>
                                        <td colspan="2" style="padding-top: 10px;">List Consultant:&nbsp;
                                            <asp:Label ID="PatientListConsultantLabel" runat="server" /></td>
                                    </tr>--%>
                                    <tr>
                                        <td colspan="1">Endoscopist:&nbsp;</td>
                                        <td>
                                            <asp:HiddenField ID="PatientEndoscopistHiddenField" runat="server" />
                                            <asp:Label ID="PatientEndoscopistLabel" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="1">List consultant:&nbsp;</td>
                                        <td>
                                            <asp:HiddenField ID="PatientListConsultantHiddenField" runat="server" />
                                            <asp:Label ID="PatientListConsultantLabel" runat="server" /></td>
                                    </tr>
                                </table>
                            </div>
                        </fieldset>
                        <fieldset>
                            <legend>Patient Notes</legend>
                            <div style="margin-bottom: 10px; text-align: right;">
                                An Alert
                            <telerik:RadTextBox ID="PatientAlertNotesTextBox" runat="server" TextMode="MultiLine" Width="100%" Height="50" />
                            </div>
                            <div style="text-align: right;">
                                General Information
                            <telerik:RadTextBox ID="PatientGeneralInfoNotesTextBox" runat="server" TextMode="MultiLine" Width="100%" Height="50" />
                            </div>
                        </fieldset>
                        <fieldset>
                            <legend>Scheduled For</legend>
                            <asp:Label ID="ScheduleDetailsLabel" runat="server" Font-Bold="true" ForeColor="Red" />
                            <table>
                                <tr>
                                    <td style="text-align: center;">
                                        <asp:Label ID="CallInTimeLabel" runat="server" Text="Call-in time" /></td>
                                    <td style="width: 60px;">
                                        <telerik:RadTimePicker ID="CallInTimeRadTimePicker" runat="server" Width="70px" TimeView-Interval="5" DateInput-IncrementSettings-InterceptArrowKeys="true" DateInput-Width="500" TimeView-TimeStyle-Height="30" TimeView-StartTime="07:00" TimeView-EndTime="22:00" />

                                        <%-- <telerik:RadNumericTextBox ID="CallInTimeRadNumericTextBox" runat="server" Value="13.00" 
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="00.05"
                                            Width="70px"
                                            MinValue="0" ClientEvents-OnValueChanging="CheckSetNumericFieldTime">
                                            <NumberFormat DecimalDigits="2" />
                                        </telerik:RadNumericTextBox>--%>
                                    </td>
                                    <td style="text-align: center; display: none;">
                                        <asp:Label ID="StartTimeLabel" runat="server" Text="Procedure time" /></td>
                                    <td style="display: none;">
                                        <telerik:RadTimePicker ID="StartTimeRadTimePicker" runat="server" Width="80px" TimeView-Interval="5" TimeView-TimeStyle-Height="30" Enabled="false" />

                                        <%-- <telerik:RadNumericTextBox ID="StartTimeRadNumericTextBox" runat="server" Value="13.00" 
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="00.05"
                                            Width="70px"
                                            MinValue="0">
                                            <NumberFormat DecimalDigits="2" />
                                        </telerik:RadNumericTextBox>--%>
                                    </td>
                                    <td style="text-align: center;">
                                        <asp:Label ID="LengthOfSlotLabel" runat="server" Text="Length of slot" /></td>
                                    <td style="width: 60px;">
                                        <telerik:RadNumericTextBox ID="BookingSlotLengthRadNumericTextBox" CssClass="slot-length" runat="server" Value="15"
                                            
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="35px"
                                            MinValue="0"
                                            Enabled="false">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox>
                                    </td>
                                    <td style="text-align: center;">
                                        <asp:Label ID="TotalSlotPointsLabel" runat="server" Text="Slot points" /></td>
                                    <td style="width: 60px;">
                                        <telerik:RadNumericTextBox ID="BookingSlotPointsRadNumericTextBox" CssClass="slot-points" runat="server" Value="1"
                                            
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="0.5"
                                            Width="35px"
                                            MinValue="0"
                                            Enabled="false">
                                            <NumberFormat DecimalDigits="2" />
                                        </telerik:RadNumericTextBox>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                </div>
                <fieldset>
                    <div id="Letter" style="text-align: left;">

                        <asp:RadioButtonList ID="RadioButtonLetterPrintList" runat="server" RepeatDirection="Horizontal">
                            <asp:ListItem Value="Print">Print Letter</asp:ListItem>
                            <asp:ListItem Value="Edit">Edit Letter</asp:ListItem>
                        </asp:RadioButtonList>
                        <asp:Label ID="NotTemplateFoundLabel" runat="server" Text="No letter template found" Visible="false" ForeColor="Red" />
                    </div>
                </fieldset>
                <div id="SaveBookingButtons" style="text-align: right;">
                    <telerik:RadButton ID="SaveBookingRadButton" runat="server" Text="Save and Print" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="validateBookingForm" OnClick="SaveBookingRadButton_Click" />
                    <telerik:RadButton ID="CancelSaveBookingRadButton" runat="server" Text="Close" AutoPostBack="true" OnClick="CancelSaveBookingRadButton_Click" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
                <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None"
                    EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue; z-index: 9999999;"
                    AutoCloseDelay="7000">
                    <ContentTemplate>
                        <asp:ValidationSummary ID="SaveBookingValidationSummary" runat="server" DisplayMode="BulletList"
                            EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                        <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
                    </ContentTemplate>
                </telerik:RadNotification>

            </div>
        </div>


        <!-- Rad Windows -->
        <telerik:RadWindowManager ID="AddNewTitleRadWindowManager" runat="server" ShowContentDuringLoad="false"
            Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="PreviousPatientBookingsWindow" runat="server" ReloadOnShow="false" KeepInScreenBounds="true" Width="350" Height="250" VisibleStatusbar="false">
                    <ContentTemplate>
                        <div style="text-align: center; padding: 30px;">
                            <asp:Label ID="PreviousBookingMessageLabel" runat="server" />
                        </div>
                        <div style="text-align: center; margin-top: 10px; height: 17px;">
                            <telerik:RadButton ID="ContinueBookingRadButton" runat="server" Text="Yes" Icon-PrimaryIconCssClass="telerikYesButton" AutoPostBack="false" OnClientClicked="CloseAndContinueBookingWindow" />
                            <telerik:RadButton ID="CancelButtonRadButton" runat="server" Text="No" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikNoButton" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>

                <telerik:RadWindow ID="TherapeuticTypesSelectionRadWindow" runat="server" ReloadOnShow="false" KeepInScreenBounds="true" Width="350" Height="250">
                    <ContentTemplate>
                    </ContentTemplate>
                </telerik:RadWindow>

                <telerik:RadWindow ID="LetterPrintEdit" runat="server" ReloadOnShow="false" KeepInScreenBounds="true" Width="350" Height="250">
                    <ContentTemplate>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>

        <!--Datasources -->
        <asp:ObjectDataSource ID="SlotStatusObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSlotStatus">
            <SelectParameters>
                <asp:Parameter Name="GI" DbType="Byte" DefaultValue="1" />
                <asp:Parameter Name="nonGI" DbType="Byte" DefaultValue="1" />
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

    </form>
</body>
</html>
