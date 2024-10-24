<%@ Control Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.UserControls_AppScheduler" CodeBehind="AppScheduler.ascx.vb" %>

<style type="text/css">
    .SelectedGridRowStyle {
        color: #fff !important;
        background: #25a0da !important;
    }

    .rsArrowBottom {
        display: none !important;
    }

    .diary-calendar input, .diary-calendar td:first-child {
        display: none;
    }

    .calender-li {
        width: 20px;
        color: white !important;
    }

    .room-tabs ul {
        margin: 0;
        padding: 0;
    }

    .room-tabs input {
        border: none;
        background: none;
    }

    .room-tabs li {
        list-style-type: none;
        background-color: #f9f9f9;
        color: #000;
        border: 1px solid #e0e0e0;
        padding: 10px 15px !important;
    }

        .room-tabs li:hover {
            border-color: #cecece;
            background-color: #e7e7e7;
            cursor: pointer;
        }

        .room-tabs li.selected {
            border-color: #25a0da;
            color: #fff;
            background-color: #25a0da;
        }

    .tod-div {
        float: left;
        width: 49%;
        padding-right: 10px;
    }

        .tod-div h2 {
            text-align: center;
        }

    .day-notes textarea {
        height: 50px;
        width: 98.5%;
        margin-top: 2px;
        resize: none;
    }

    .calenderHeaderDiv {
        width: 100%;
        height: 30px;
        line-height: 25px;
        z-index: 1000;
        border: 1px solid #25a0da;
        color: #fff;
        background-color: #25a0da;
    }

    /*.rooms-tabs div {
        border-bottom: none !important;
    }*/

    .date-toggle ul {
        float: left;
        margin: 0;
        padding: 0;
    }

    .date-toggle li {
        list-style-type: none;
        float: left;
        color: white !important;
        padding: 3px;
        margin: 2px 3px 1px 1px;
        height: 25px;
        padding: 0 3px 0 3px;
        cursor: pointer;
    }

    .date-toggle span {
        font-size: 15px;
    }

    .calender-view-toggle ul {
        float: right;
        padding-right: 10px;
        margin: 0;
        text-decoration: none;
    }

    .calender-view-toggle li {
        list-style-type: none;
        float: left;
        color: white;
        padding: 3px;
        margin: 2px 3px 1px 1px;
        height: 25px;
        padding: 0 10px 0 10px;
        cursor: pointer;
    }

    .calender-view-toggle a, .date-toggle a {
        text-decoration-line: none;
        color: white !important;
    }

    .calender-view-toggle li:hover, .calender-view-toggle li.selected-li {
        border: 1px solid white;
        margin: 1px 2px 0px 0px;
        padding: -1px 9px -1px 9px;
    }

    .context-menu-popup {
        z-index: 999 !important;
    }

    .rsAptResize, .rsAptDelete {
        visibility: hidden !important;
    }

    #RadMenu1 {
        position: fixed;
        z-index: 8001 !important;
    }

    .RadAjaxPanel {
        display: inline !important;
    }

    .rsDayView .rsHorizontalHeaderTable tr:first-child th div,
    .rsWeekView .rsHorizontalHeaderTable tr:first-child th div,
    .rsMonthView .rsHorizontalHeaderTable tr:first-child th div,
    .rsTimelineView .rsVerticalHeaderWrapper .rsVerticalHeaderTable .rsMainHeader,
    .rsAgendaView .rsAgendaRow .rsResourceHeader {
        font-weight: bolder;
        color: #004d66;
        text-align: center;
        font-size: 13px;
    }

    .rsWeekView .rsDateHeader,
    .rsTimelineView .rsHorizontalHeaderTable tr:first-child th div,
    .rsAgendaView .rsHorizontalHeaderTable tr:first-child th div,
    .rsHorizontalHeaderTable tr:nth-child(2) th div {
        color: olive;
    }

    .rsTimelineView .rsAllDayTable .rsAllDayRow {
        background-color: #fbfffb !important;
    }

    #SearchAvailableSlotDiv {
        overflow-x: hidden;
    }

    #FilterDiv {
        margin-left: 15px;
    }

        #FilterDiv div {
            margin-bottom: 5px;
        }

    .search-fieldset div {
        margin-bottom: 5px;
    }

    .patient-details-table td {
        vertical-align: top;
    }

    /*.patient-booking-slot {
        border: 0.5px dotted blue !important;
        width: 100% !important;
        padding-left: 0px !important;
        left: 0px !important;
    }*/

    .free-slot, .patient-booking-slot {
        width: 98.9% !important;
        border: 1px solid black !important;
        padding-left: 0px !important;
        left: 0px !important;
    }

    .overview-slot {
        height: 85px !important;
    }

    .overview-free {
        background-color: #46a958;
    }

    .overview-used {
        background-color: #d89f3b;
    }

    .overview-full {
        background-color: #d33a3a;
    }

    .Overview-Scheduler .rsWrap {
        height: 82px !important;
    }

    .Overview-Scheduler .rsDateWrap {
        height: 20px !important;
    }


    .end-of-list {
        text-align: center;
        width: 100% !important;
        border: 1px dashed black;
        /*padding-left: 30%;*/
    }

        .end-of-list div {
            width: 100%;
            text-align: center;
        }

    .selected-appointment {
        border: 2px solid black !important;
        width: 99.6% !important;
    }

    .no-padding {
        padding: 0px !important;
    }

    .align-left div {
        text-align: left !important;
    }

    /*.lock-list-div {
        position: absolute;
        top: -15px;
        right: 20px;
    }*/

    .lock-list-div {
        position: absolute;
        float: right;
        right: 20px;
    }

    .patient-attendance-icons {
        float: left;
        margin-right: 5px;
    }

    .tooltip-icons {
        position: relative;
        top: -3px;
    }

        .tooltip-icons img {
            width: 15px;
        }

    .patient-status-item img {
        width: 16px !important;
    }

    .tooltip-icons td {
        border: none !important;
    }

    .no-template-div {
        min-height: 400px;
        background-color: white;
        text-align: center;
        color: black;
        padding-top: 55px;
        font-size: 20px;
        border: 1px solid #ccc;
    }

    .header-session {
        border-style: solid;
        border-width: 100px;
        border: 1px solid #25a0da;
        padding-top: 10px;
        padding-bottom: 10px;
        font-size: 18px;
        font-weight: 900;
        text-align: center;
    }

    .header-diary-details {
        border-style: solid;
        border-width: 100px;
        border: 1px solid #25a0da;
        height: 70px;
        margin-top: 2px;
        padding-left: 5px;
        padding-right: 5px;
        padding-top: 5px;
        padding-bottom: 25px;
        font-size: 14px;
    }

    .hide-rooms-dropdown-div {
        display: none;
    }
</style>
<telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">

    <script type="text/javascript">
        var docURL = document.URL;

        function validateSearchCriteria() {
            var valid = Page_ClientValidate("SlotSearch");
            if (!valid) {
                $find("<%=ValidateSearchRadNotification.ClientID%>").show();
            }
        }
        function EditClosed(sender) {

            sender.remove_close(EditClosed);
            //alert('client closed');
            var btn = $find("<%=SearchButton.ClientID %>");
            btn.click();
        }
        function editOrderComm(OrderId) {
            if (OrderId > 0) {
                var rdwindow = radopen("EditOrderComms.aspx?OrderId=" + OrderId, "Order Comms Details", 1000, 850);
                rdwindow.set_title('<center>Order Comms Detail</center>');
                rdwindow.set_visibleStatusbar(false);
                rdwindow.setActive(true);
                rdwindow.add_close(EditClosed);
                return false;

            }
        }
        function PopUpOrderComms(intOrderId) {
                    var width = 1000;
                    var height = 850;
                    
                   
                    var url = "EditOrderComms.aspx?OrderId=" + intOrderId + "&fromwaitlist=y"
                        
                    //window.open("ViewProcDocPDF.aspx?ProcedureId=" + procedureId + "&ProcedureMaxDate=" + procedureMaxDate + "&ProcedureDocSource=" + procedureDocSource, 'winname', 'directories=0,titlebar=0,toolbar=0,location=0,status=0,menubar=0,top=350,screenY=350,left=550,scrollbars=0,resizable=1,width=600,height=800');
                    popupWindow(url, "View OrderComm Report", width, height);

                    return false;
                }
        function popupWindow(url, windowName, w, h) {
                    var win = window

                    const y = win.top.outerHeight / 2 + win.top.screenY - (h / 2);
                    const x = win.top.outerWidth / 2 + win.top.screenX - (w / 2);


                    return win.open(url, windowName, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width=' + w + ', height=' + h + ', top='+y + ', left=' + x);
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
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Scheduler/Scheduler.aspx/GetSlotBreechDays",
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

        function getDayNotes(calendarDate, roomId, operatingHospitalId) {
            var obj = {};
            obj.noteDate = calendarDate;
            obj.roomId = parseInt(roomId);
            obj.operatingHospitalId = parseInt(operatingHospitalId);
            $.ajax({
                type: "POST",
                url: "Scheduler.aspx/GetDayNotes",
                data: JSON.stringify(obj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d) {
                        var res = JSON.parse(data.d);
                        $(res).each(function (index, value) {
                            var timeOfDay = value.TimeOfDay
                            var notesText = value.NoteText
                            if (timeOfDay == "AM") {
                                $('#<%=AMNotesTextBox.ClientID%>').val(notesText);
                            }
                            else if (timeOfDay == "PM") {
                                $('#<%=PMNotesTextBox.ClientID%>').val(notesText);
                            }
                            else if (timeOfDay == "EVE") {
                                $('#<%=EVENotesTextBox.ClientID%>').val(notesText);
                            }
                        });
                    }
                },
                error: function (jqXHR, textStatus, data) {
                    //alert("An error occured while getting your notes");
                    $('#<%=AMNotesTextBox.ClientID%>').val("");
                    $('#<%=PMNotesTextBox.ClientID%>').val("");
                    $('#<%=EVENotesTextBox.ClientID%>').val("");
                }
            });
        }

        var notesChanged;
        function setTextChanges() {
            notesChanged = true;
        }

        function saveDayNotes(noteDate, noteTime, roomId, operatingHospitalId, txtBox) {
            if (notesChanged) {
                var noteText = $('#' + txtBox).val();

                var obj = {};
                obj.noteDate = noteDate;
                obj.noteTime = noteTime;
                obj.noteText = noteText
                obj.roomId = parseInt(roomId);
                obj.operatingHospitalId = parseInt(operatingHospitalId);
                obj.userId = parseInt(<%= Session("PKUserId")%>);

                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/SaveDayNotes",
                    data: JSON.stringify(obj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function () {
                        notesChanged = false;
                    },
                    error: function (jqXHR, textStatus, data) {
                        notesChanged = false;
                        alert("An error occured while saving your notes");
                    }
                });
            }
        }



        function roomTabClicked(sendr) {
            $('ul#room-tab li').each(function (index, item) {
                $(item).removeClass('selected');
            });

            $(sendr).addClass('selected');
            var roomId = $(sendr).attr("data-id");
            var roomName = $(sendr).attr("data-name");

            $('#<%=SelectedRoomHiddenField.ClientID%>').val(roomId);
            $('#<%=RoomNameLabel.ClientID%>').text(roomName);

            $('#<%=SetSelectedRoomRadButton.ClientID%>').click();
        }

        function setRoomTabSelected(roomId) {
            $('ul#room-tab li').each(function (index, item) {
                if ($(item).attr("data-id") == roomId) {
                    $(item).addClass("selected");

                    var roomName = $(item).attr("data-name");
                    $('#<%=RoomNameLabel.ClientID%>').text(roomName);
                }
            });
        }

        function setOverviewType(ctrl) {
            if ($(ctrl).val() == "endo") {
                $('.overview-endo-div').css("visibility", "visible");
            }
            else {
                $('.overview-endo-div').css("visibility", "hidden");
            }
        }
        function bindEvents() {
            $('#<%=OverviewTypeRadioButtonList.ClientID%> input').on('change', function () {
                setOverviewType($(this))
            });

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
                oWnd.setUrl("../Options/Scheduler/TherapeuticTypes.aspx?ProcedureType=" + procedureType + "&ProcedureTypeID=" + procedureTypeID + "&mode=search")
                oWnd.setSize(500, 550);
                oWnd.show();
                oWnd.add_close(function () {
                    oWnd.set_title("");
                });
                return false;
            });
        }

        $(window).on('load', function () {

        });

        $(document).ready(function () {
            <%--document.getElementById("<%= FormDiv.ClientID%>").style.height = (document.documentElement.clientHeight - 350) + 'px';
            if (document.getElementById("<%= AMRadScheduler.ClientID%>") != undefined) {
                //document.getElementById("<%= AMRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 370) + 'px';
                document.getElementById("<%= AMRadScheduler.ClientID%>").style.overflowY = 'auto';
            }
            if (document.getElementById("<%= PMRadScheduler.ClientID%>") != undefined) {
                //document.getElementById("<%= PMRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 370) + 'px';
                document.getElementById("<%= PMRadScheduler.ClientID%>").style.overflowY = 'auto';
            }
            if (document.getElementById("<%= EVRadScheduler.ClientID%>") != undefined) {
                //document.getElementById("<%= EVRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 370) + 'px';
                document.getElementById("<%= EVRadScheduler.ClientID%>").style.overflowY = 'auto';
            }
            $(window).resize(function() {
                document.getElementById("<%= FormDiv.ClientID%>").style.height = (document.documentElement.clientHeight - 370) + 'px';
                if (document.getElementById("<%= AMRadScheduler.ClientID%>") != undefined) {
                    document.getElementById("<%= AMRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 370) + 'px';
                }
                if (document.getElementById("<%= PMRadScheduler.ClientID%>") != undefined) {
                    document.getElementById("<%= PMRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 370) + 'px';
                }
                if (document.getElementById("<%= EVRadScheduler.ClientID%>") != undefined) {
                    document.getElementById("<%= EVRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 370) + 'px';
                }
            });--%>


            Sys.Application.add_load(function () {
                bindEvents();
            });
        });

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
                obj.operatingHospitalId = $find('<%=HospitalDropDownList.ClientID%>').get_value();
                obj.isDiagnostic = true;
                obj.isTraining = false;

                $.ajax({
                    type: "POST",
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Scheduler/Scheduler.aspx/GetProcedureLengths",
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
            obj.operatingHospitalId = $find('<%=HospitalDropDownList.ClientID%>').get_value();
            obj.isTraining = false;
            obj.isDiagnostic = isDiagnostic;

            $.ajax({
                type: "POST",
                url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Scheduler/Scheduler.aspx/GetProcedureLengths",
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

        function validationFunction(source, arguments) {
            if (arguments.Value == '' || arguments.Value == '-') {
                arguments.IsValid = false;
            } else {
                arguments.IsValid = true;
            }
        }

        function closeSearchBookingWindow() {
            var oWnd = $find("<%= FindExistingBookingRadWindow.ClientID %>");
            if (oWnd != null)
                oWnd.close();
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

            var oWnd2 = $find("<%= SearchAvailableSlotWindow.ClientID %>");
            if (oWnd2 != null)
                oWnd2.close();
        }

        function CloseWindow(sender, args) {
            var oWnd = $find("<%= SearchAvailableSlotWindow.ClientID %>");
            if (oWnd != null)
                oWnd.close();

            args.set_cancel(true);
        }

        function closeRadWindow(sender, args) {
            var oWnd = $find("<%=PatientDeleteBookingConfirmationWindow.ClientID%>");
            var combo = $find("<%= CancellationReasonRadComboBox.ClientID %>");
            combo.clearSelection();
            if (oWnd != null) {
                oWnd.close();
                PrintCancelLetter()
            }

            if (args != null) {
                args.set_cancel(true);
            }

        }

       <%-- function CloseBookingWindow() {
            var oWnd = $find("<%= PatientBookingWindow.ClientID %>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }

        function CloseAndContinuePreviousBookingWindow() {
            var oWnd = $find("<%= PreviousPatientBookingsWindow.ClientID %>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }--%>

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

        function FormatDate(dateStr) {
            var day = dateStr.getDate();
            var month = dateStr.getMonth() + 1;
            var year = dateStr.getFullYear();
            var minutes = dateStr.getMinutes();

            if (minutes < 10)
                minutes = "0" + minutes;

            return day + "/" + month + "/" + year + " " + dateStr.getHours() + ":" + minutes;
        }

        function AppointmentDateString(dateStr) {
            var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
            var months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

            var day = days[dateStr.getDay()];
            var month = months[dateStr.getMonth()];

            return day + " " + dateStr.getDate() + " " + month + " " + dateStr.getFullYear() + " " + dateStr.getHours() + ":" + dateStr.getMinutes();
        }

        function BookSlot(diaryId, slotDate, roomId, procedureTypeId, slotStatusId, bookingMode, hospitalId, slotLength, slotPoints) {
            var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
            oWnd.setUrl("../Scheduler/PatientBooking.aspx?action=" + bookingMode + "&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&slotPoints=" + slotPoints + "&diaryId=" + diaryId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotId=" + slotStatusId + "&slotLength=" + slotLength);
            oWnd.show();
            closeSlotWindow();
        }

        function OverviewContextClicked(sender, args) {
            var itm = args.get_item();
            var appointment = args.get_appointment();

            var roomId = appointment.get_attributes(0)["getAttribute"]("roomId");
            var slotDate = FormatDate(new Date(appointment.get_start()));

            $find('<%=btnReload.ClientID%>').set_commandName(roomId)
            $find('<%=btnReload.ClientID%>').set_commandArgument(slotDate)

            $('#<%= btnReload.ClientID %>').click();
        }

        function ContextClicked(sender, args) {
            var itm = args.get_item();
            var appointment = args.get_appointment();

            var slotStatusId = appointment.get_attributes(0)["getAttribute"]("statusId");
            var procedureTypeId = appointment.get_attributes(0)["getAttribute"]("procedureTypeId");
            var roomId = appointment.get_attributes(0)["getAttribute"]("roomId");
            var slotLength = appointment.get_attributes(0)["getAttribute"]("slotLength");
            var slotPoints = appointment.get_attributes(0)["getAttribute"]("slotPoints");
            var hospitalId = appointment.get_attributes(0)["getAttribute"]("operatingHospitalId");

            var slotDate = FormatDate(new Date(appointment.get_start()));
            var diaryId = parseInt(appointment._id);

            //var roomId = $find('<%=RoomsDropdown.ClientID%>').get_value();
            if (itm.get_text() == "Add a new booking...") {

                //var own = radopen("../Scheduler/PatientBooking.aspx?action=add&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotId=" + slotStatusId, "Add new booking...", '950px', '600px');
                //own.set_visibleStatusbar(false);

                var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
                oWnd.setUrl("../Scheduler/PatientBooking.aspx?action=add&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotId=" + slotStatusId + "&slotLength=" + slotLength + "&slotPoints=" + slotPoints);
                oWnd.set_width("950");
                oWnd.set_height("600");
                oWnd.show();

            }
            else if (itm.get_text() == "Paste Booking") {
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/GetAppointmentId",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (data.d > 0) {
                            BookSlot(diaryId, slotDate, roomId, procedureTypeId, slotStatusId, "move", hospitalId, slotLength, slotPoints);
                        }
                    },
                    error: function (jqXHR, textStatus, data) {
                    }
                });
            }
            else if (itm.get_text() == "Edit Booking") {
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                var diaryId = appointment.get_attributes(0)["getAttribute"]("diaryId");

                var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
                oWnd.setUrl("../Scheduler/PatientBooking.aspx?action=edit&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&appointmentId=" + appointmentId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotLength=" + slotLength + "&slotPoints=" + slotPoints);
                oWnd.set_width("950");
                oWnd.set_height("600");
                oWnd.show();

                //var own = radopen("../Scheduler/PatientBooking.aspx?action=edit&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&appointmentId=" + appointmentId + "&roomId=" + roomId, "Edit booking...", '950px', '600px');
                //own.set_visibleStatusbar(false);
            }
                else if (itm.get_text() == "Cut Booking") {
                var copiedAppointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                SetSessionAppointment(copiedAppointmentId);
            }
            else if (itm.get_value() == "MarkBooked") {
                //ajax call to update patient journey
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/unmarkPatientAttended",
                    data: JSON.stringify({ "appointmentId": appointmentId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        //refresh diary
                        $('#<%= btnReload.ClientID %>').click();
                    },
                    error: function (jqXHR, textStatus, data) {
                        //alert("An error occured while saving your notes");

                    }
                });
            }
            else if (itm.get_value() == "MarkAttended") {
                //ajax call to update patient journey
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/markPatientAttended",
                    data: JSON.stringify({ "appointmentId": appointmentId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        //refresh diary
                        $('#<%= btnReload.ClientID %>').click();
                    },
                    error: function (jqXHR, textStatus, data) {
                        //alert("An error occured while saving your notes");

                    }
                });
            }
            else if (itm.get_value() == "MarkDischarged") {
                //ajax call to update patient journey
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/markPatientDischarged",
                    data: JSON.stringify({ "appointmentId": appointmentId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        //refresh diary
                        $('#<%= btnReload.ClientID %>').click();
                    },
                    error: function (jqXHR, textStatus, data) {
                        //alert("An error occured while saving your notes");

                        $('#AmendedEVEBookingsDiv').hide();
                    }
                });
            }
            else if (itm.get_text() == "Cancel Booking") {
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                $('#<%=PatientAppointmentIDHiddenField.ClientID%>').val(appointmentId);

                var oWnd = $find("<%= PatientDeleteBookingConfirmationWindow.ClientID %>");
                if (oWnd != null) {
                    oWnd.set_title(itm.get_text());
                    oWnd.show();

<%--                    $find('<%= CancellationReasonRadComboBox.ClientID %>').set_value(0);--%>

                    $('.cancellation-confirmation').show();
                    $('.cancellation-confirmation-action').hide();

                    //ajax call to see if appointment was made from the waitlist. show and set checkbox accordingly;
                    var obj = {};
                    obj.appointmentId = parseInt(appointmentId);
                    $.ajax({
                        type: "POST",
                        url: "Scheduler.aspx/BookedFromWaitlist",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (r) {
                            if (r.d == true) {
                                $('.waitlist-cb').show();
                                $('.waitlist-cb').attr("checked", true);
                            }
                            else {
                                $('.waitlist-cb').hide();
                            }
                        },
                        error: function (jqXHR, textStatus, data) {
                        }
                    });

                }
            }
            else if (itm.get_value() == "PatientDNA") {
                //ajax call to mark patient/appointment as DNA
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/markPatientDNA",
                    data: JSON.stringify({ "appointmentId": appointmentId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        //refresh diary
                        $('#<%= btnReload.ClientID %>').click();
                    },
                    error: function (jqXHR, textStatus, data) {
                        //alert("An error occured while saving your notes");

                    }
                });
            }
            else if (itm.get_value() == "PatientStatus") {
                //ajax call to update patient status
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                var statusCode = appointment.get_attributes(0)["getAttribute"]("statusCode");

                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/updatePatientStatus",
                    data: JSON.stringify({ "appointmentId": appointmentId, "statusCode": statusCode == "B" ? "P" : "B" }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        //refresh diary
                        $('#<%= btnReload.ClientID %>').click();
                    },
                    error: function (jqXHR, textStatus, data) {
                        //alert("An error occured while saving your notes");

                    }
                });
            }
            else if (itm.get_value() == "PatientConfirmed") {
                //ajax call to update patient status
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/updatePatientStatus",
                    data: JSON.stringify({ "appointmentId": appointmentId, "statusCode": "B" }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        //refresh diary
                        $('#<%= btnReload.ClientID %>').click();
                    },
                    error: function (jqXHR, textStatus, data) {
                        //alert("An error occured while saving your notes");

                    }
                });
            }
            else if (itm.get_value() == "PartiallyBooked") {
                //ajax call to update patient status
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/updatePatientStatus",
                    data: JSON.stringify({ "appointmentId": appointmentId, "statusCode": "P" }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        //refresh diary
                        $('#<%= btnReload.ClientID %>').click();
                    },
                    error: function (jqXHR, textStatus, data) {
                        //alert("An error occured while saving your notes");

                    }
                });
            }
            else if (itm.get_text() == "With Additional Document") {
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");


                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/GenerateLetterForAppointmentid",
                    data: JSON.stringify({ "AppointmentId": appointmentId, "WithAdditionalDocument": "Yes" }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: false,
                    success: function (data) {
                        window.open('../Letters/DisplayAndPrintPDF.aspx', "_blank");
                    },
                    error: function (jqXHR, textStatus, data) {


                    }
                });
            }
            else if (itm.get_text() == "Without Additional Document") {
                var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");


                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/GenerateLetterForAppointmentid",
                    data: JSON.stringify({ "AppointmentId": appointmentId, "WithAdditionalDocument": "No" }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: false,
                    success: function (data) {
                        window.open('../Letters/DisplayAndPrintPDF.aspx', "_blank");
                    },
                    error: function (jqXHR, textStatus, data) {


                    }
                });
            }
        }

        function SetSessionAppointment(appointmentId) {
            $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/SetAppointmentId",
                    data: JSON.stringify({ "appointmentId": appointmentId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                    },
                    error: function (jqXHR, textStatus, data) {
                    }
                });
        }

        function PrintCancelLetter() {
            var appointmentId = $('#<%=PatientAppointmentIDHiddenField.ClientID%>').val();
            $.ajax({
                type: "POST",
                url: "Scheduler.aspx/GenerateLetterForAppointmentid",
                data: JSON.stringify({ "AppointmentId": appointmentId, "WithAdditionalDocument": "No" }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    window.open('../Letters/DisplayAndPrintPDF.aspx', "_blank");
                },
                error: function (jqXHR, textStatus, data) {


                }
            });
        }

        function bookingFound() {
            $('#<%= btnReload.ClientID %>').click();
        }

        function bookingSaved() {
            $('#<%= btnReload.ClientID %>').click();
        }

        function reloadDiary() {
            $('#<%= btnReload.ClientID %>').click();
        }

        function OnClientAppointmentMoveStart(sender, eventArgs) {
            eventArgs.set_cancel(true);
        }

        function OnClientAppointmentDoubleClick(sender, args) {
            var appointment = args.get_appointment();

            var slotType = appointment.get_attributes(0)["getAttribute"]("slotType");

            if (appointment.get_contextMenuID() == undefined) {
                if (slotType == "FreeSlot")
                    alert('Diary locked. Appointments cannot be added to this list.');
                else if (slotType == "PatientBooking")
                    alert('Diary locked. Appointments cannot be edited.');
                else if (slotType.toLowerCase() == "reservedslot") {
                    var lockedByUser = clickedappointment.get_attributes(0)["getAttribute"]("lockedByUser");
                    alert('This slot is locked by ' + lockedByUser + '. Booking in progress');
                }
            }
            else if (slotType == "FreeSlot") {
                //check if slot is reserved
                clickedappointment = appointment; //must set this for after our result is returned from the ajax call- scope would be lost by then

                //check slot availability and disable add button if not
                var diaryId = parseInt(clickedappointment.get_attributes(0)["getAttribute"]("diaryId"));
                var userId = <%= DataAdapter.LoggedInUserId%>;
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/slotAvailable",
                    data: JSON.stringify({ "selectedDateTime": clickedappointment.get_start(), "diaryId": diaryId, "userId": userId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (data.d != "") {
                            alert('This slot is locked by ' + data.d + '. Booking in progress.');
                        }
                        else {

                            var slotStatusId = clickedappointment.get_attributes(0)["getAttribute"]("statusId");
                            var procedureTypeId = clickedappointment.get_attributes(0)["getAttribute"]("procedureTypeId");
                            var roomId = clickedappointment.get_attributes(0)["getAttribute"]("roomId");
                            var slotLength = clickedappointment.get_attributes(0)["getAttribute"]("slotLength");
                            var slotPoints = clickedappointment.get_attributes(0)["getAttribute"]("slotPoints");
                            var hospitalId = clickedappointment.get_attributes(0)["getAttribute"]("operatingHospitalId");

                            var slotDate = FormatDate(new Date(clickedappointment.get_start()));
                            var diaryId = parseInt(appointment._id);


                            var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
                            oWnd.setUrl("../Scheduler/PatientBooking.aspx?action=add&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotId=" + slotStatusId + "&slotLength=" + slotLength + "&slotPoints=" + slotPoints);
                            oWnd.set_width("950");
                            oWnd.set_height("600");
                            oWnd.show();
                        }
                    },
                    error: function (x, y, z) {
                        console.log(x.responseJSON.Message);
                    }
                });

            }
        }

        function OnClientAppointmentEditing(sender, args) {

            args.set_cancel(true);
        }

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


        function displayCancelledBookings(bookingDate, diaryId) {
            var own = radopen("../Scheduler/CancelledBookings.aspx?diaryId=" + diaryId + "&bookingDate=" + bookingDate, "Cancelled bookings", '950px', '600px');
            own.set_visibleStatusbar(false);
        }

        function showLockWindow(diaryDate, diaryId, locked, tod) {
            var windowTitle;
            if (locked == "True") {
                windowTitle = "Unlock list for...";
            }
            else {
                windowTitle = "Lock list for...";
            }

            var oWnd = $find('<%=ExternalRadWindow.ClientID%>');
            oWnd.setUrl("../Scheduler/Windows/LockList.aspx?diaryId=" + diaryId + "&diaryDate=" + diaryDate + "&locked=" + locked + "&tod=" + tod);
            oWnd.setSize(650, 350);
            oWnd.set_title(windowTitle);
            oWnd.show();
            oWnd.add_close(function () {
                oWnd.set_title("");
            });
            return false;

        }

        function validateDiaryLockReason(sender, args) {
            var valid = Page_ClientValidate("saveLockReason");
           <%-- if (!valid) {
                $find("<%=SaveLockReasonRadNotification.ClientID%>").show();
            }--%>

        }

        function GetRadWindow() {
            var oWindow = null;
            if (window.radWindow) oWindow = window.radWindow;
            else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
            return oWindow;
        }

        function CloseDialog() {
            GetRadWindow().close();
        }

        function OnClientAppointmentContextMenuClicking(sender, args) {
            var slotType = args.get_appointment().get_attributes(0)["getAttribute"]("slotType");


            if (slotType == "EndOfList") {
                args.set_cancel(true);
            }
        }

        function OnClientWewekViewAppointmentContextMenu(sender, args) {

            var slotType = args.get_appointment().get_attributes(0)["getAttribute"]("slotType");
            if (args.get_appointment().get_contextMenuID() == undefined) {
                if (slotType == "FreeSlot")
                    alert('Diary locked. Appointments cannot be added to this list.');
                else if (slotType == "PatientBooking")
                    alert('Diary locked. Appointments cannot be edited.');
                else if (slotType == "ReservedSlot") {
                    var lockedByUser = args.get_appointment().get_attributes(0)["getAttribute"]("lockedByUser");
                    alert('This slot is locked by ' + lockedByUser + '. Booking in progress');
                }
            }
        }

        var clickedContextMenu;
        var clickedappointment;

        function OnClientAppointmentContextMenu(sender, args) {

            clickedContextMenu = sender.get_appointmentContextMenus();//[1].get_items().getItem(3);
            clickedappointment = args.get_appointment();

            var slotType = clickedappointment.get_attributes(0)["getAttribute"]("slotType");
            if (clickedappointment.get_contextMenuID() == undefined) {
                if (slotType == "FreeSlot")
                    alert('Diary locked. Appointments cannot be added to this list.');
                else if (slotType == "ReservedSlot") {
                    var lockedByUser = clickedappointment.get_attributes(0)["getAttribute"]("lockedByUser");
                    alert('This slot is locked by ' + lockedByUser + '. Booking in progress');
                }
            }
            else if (slotType == "PatientBooking") {
                var appointmentId = clickedappointment.get_attributes(0)["getAttribute"]("appointmentId");
                $('#<%=SelectedApppointmentId.ClientID%>').val(appointmentId);

                var pathwayContextMenuItem = clickedContextMenu[2].findItemByValue("PatientPathway");
                var editBookingContextMenuItem = clickedContextMenu[2].findItemByValue("EditBooking");
                var moveBookingContextMenuItem = clickedContextMenu[2].findItemByValue("MoveBooking");
                var cancelBookingContextMenuItem = clickedContextMenu[2].findItemByValue("DeleteBooking");
                var patientDNAContextMenuItem = clickedContextMenu[2].findItemByValue("PatientDNA");
                var patientStatusContextMenuItem = clickedContextMenu[2].findItemByValue("BookingConfirmed");
                var setPartiallyBookedContextMenuItem = clickedContextMenu[2].findItemByValue("PartiallyBooked");
                var setPatientConfirmedContextMenuItem = clickedContextMenu[2].findItemByValue("PatientConfirmed");
                var CutBookingContextMenuItem = clickedContextMenu[2].findItemByValue("CutBooking");


                //json call to check 
                var obj = {};
                obj.appointmentId = parseInt(appointmentId);

                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/GetPatientPathwayDetails",
                    data: JSON.stringify(obj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (data.d) {
                            var res = JSON.parse(data.d);
                            if (res.length > 0) {

                                var patientJourney = res[0];
                                if (patientJourney.arrivalTime != "") {
                                    //cant edit of cancel if patient journeys been logged
                                    cancelBookingContextMenuItem.set_enabled(false);
                                    editBookingContextMenuItem.set_enabled(false);
                                    patientDNAContextMenuItem.set_enabled(false);
                                    moveBookingContextMenuItem.set_enabled(false);
                                    patientStatusContextMenuItem.set_enabled(false);
                                    CutBookingContextMenuItem.set_enabled(false);

                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkAttended").set_text("Mark Arrived - " + patientJourney.arrivalTime);
                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkAttended").set_enabled(false);
                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkBooked").set_enabled(true);
                                }
                                else {
                                    cancelBookingContextMenuItem.set_enabled(true);
                                    editBookingContextMenuItem.set_enabled(true);
                                    patientDNAContextMenuItem.set_enabled(true);
                                    moveBookingContextMenuItem.set_enabled(true);
                                    patientStatusContextMenuItem.set_enabled(true);
                                    CutBookingContextMenuItem.set_enabled(true);

                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkAttended").set_text("Mark Arrived");
                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkAttended").set_enabled(true);
                                    //pathwayContextMenuItem.get_menu().findItemByValue("MarkBooked").set_enabled(false);
                                }
                                if (patientJourney.dischargeTime != "") {
                                    //cant edit of cancel if patient journeys been logged
                                    cancelBookingContextMenuItem.set_enabled(false);
                                    editBookingContextMenuItem.set_enabled(false);
                                    patientDNAContextMenuItem.set_enabled(false);
                                    moveBookingContextMenuItem.set_enabled(false);
                                    patientStatusContextMenuItem.set_enabled(false);
                                    CutBookingContextMenuItem.set_enabled(false);

                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkDischarged").set_text("Mark Discharged - " + patientJourney.dischargeTime);
                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkAttended").set_enabled(false);
                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkDischarged").set_enabled(false);
                                    //pathwayContextMenuItem.get_menu().findItemByValue("MarkBooked").set_enabled(false);
                                }
                                else {
                                    cancelBookingContextMenuItem.set_enabled(true);
                                    editBookingContextMenuItem.set_enabled(true);
                                    patientDNAContextMenuItem.set_enabled(true);
                                    moveBookingContextMenuItem.set_enabled(true);
                                    patientStatusContextMenuItem.set_enabled(true);
                                    CutBookingContextMenuItem.set_enabled(true);

                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkDischarged").set_text("Mark Discharged");
                                    pathwayContextMenuItem.get_menu().findItemByValue("MarkDischarged").set_enabled(true);
                                }
                            }
                        }
                    },
                    error: function (jqXHR, textStatus, data) {
                        //alert("An error occured while getting your notes");
                        console.log(jqXHR.responseJSON);
                    }
                });

                //check DNA status and set context menu text accordingly
                var statusCode = clickedappointment.get_attributes(0)["getAttribute"]("statusCode");
                if (statusCode == "D") {
                    cancelBookingContextMenuItem.set_enabled(false);
                    editBookingContextMenuItem.set_enabled(false);
                    moveBookingContextMenuItem.set_enabled(false);
                    pathwayContextMenuItem.set_enabled(false);
                    patientStatusContextMenuItem.set_enabled(false);
                    CutBookingContextMenuItem.set_enabled(false);

                    patientDNAContextMenuItem.set_text("Unmark DNA");
                }
                else {
                    patientDNAContextMenuItem.set_text("Mark DNA");
                }

                if (statusCode == undefined) {
                    patientStatusContextMenuItem.hide();

                    pathwayContextMenuItem.set_enabled(true);
                    patientStatusContextMenuItem.set_enabled(false);
                    patientDNAContextMenuItem.set_enabled(false);
                    setPartiallyBookedContextMenuItem.show();
                    setPatientConfirmedContextMenuItem.show();
                }
                else {
                    patientStatusContextMenuItem.show();
                    setPartiallyBookedContextMenuItem.hide();
                    setPatientConfirmedContextMenuItem.hide();

                    if (statusCode == "P") {
                        patientStatusContextMenuItem.set_text("Partially booked");
                        patientStatusContextMenuItem.get_menu().findItemByValue("PatientStatus").set_text("Set patient confirmed");

                    }
                    else {
                        patientStatusContextMenuItem.set_text("Patient confirmed");
                        patientStatusContextMenuItem.get_menu().findItemByValue("PatientStatus").set_text("Set partially booked");
                    }
                    if (statusCode.toLowerCase() == "e") {
                        var diaryId = parseInt(clickedappointment.get_attributes(0)["getAttribute"]("diaryId"));
                        var userId = <%= DataAdapter.LoggedInUserId%>;
                        $.ajax({
                            type: "POST",
                            url: "Scheduler.aspx/slotAvailable",
                            data: JSON.stringify({ "selectedDateTime": clickedappointment.get_start(), "diaryId": diaryId, "userId": userId }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (data) {
                                if (data.d != "") {
                                    var pathwayContextMenuItem = clickedContextMenu[2].findItemByValue("PatientPathway");
                                    var editBookingContextMenuItem = clickedContextMenu[2].findItemByValue("EditBooking");
                                    var moveBookingContextMenuItem = clickedContextMenu[2].findItemByValue("MoveBooking");
                                    var cancelBookingContextMenuItem = clickedContextMenu[2].findItemByValue("DeleteBooking");
                                    var patientDNAContextMenuItem = clickedContextMenu[2].findItemByValue("PatientDNA");
                                    var patientStatusContextMenuItem = clickedContextMenu[2].findItemByValue("BookingConfirmed");
                                    var setPartiallyBookedContextMenuItem = clickedContextMenu[2].findItemByValue("PartiallyBooked");
                                    var setPatientConfirmedContextMenuItem = clickedContextMenu[2].findItemByValue("PatientConfirmed");
                                    var CutBookingContextMenuItem = clickedContextMenu[2].findItemByValue("CutBooking");

                                    setPatientConfirmedContextMenuItem.set_enabled(false);
                                    setPartiallyBookedContextMenuItem.set_enabled(false);
                                    cancelBookingContextMenuItem.set_enabled(false);
                                    patientDNAContextMenuItem.set_enabled(false);
                                    editBookingContextMenuItem.set_enabled(false);
                                    moveBookingContextMenuItem.set_enabled(false);
                                    CutBookingContextMenuItem.set_enabled(false);
                                    pathwayContextMenuItem.set_enabled(false);
                                    patientStatusContextMenuItem.set_enabled(false);
                                    alert('This slot is locked by ' + data.d + '. Edit in progress.');

                                }
                                else {

                                }
                            },
                            error: function (x, y, z) {
                                console.log(x.responseJSON.Message);
                            }
                        });
                    }
                }

                //check slot availability and disable add button if not



            }
            else if (slotType == "FreeSlot") {
                //check slot availability and disable add button if not
                var diaryId = parseInt(clickedappointment.get_attributes(0)["getAttribute"]("diaryId"));
                var userId = <%= DataAdapter.LoggedInUserId%>;
                $.ajax({
                    type: "POST",
                    url: "Scheduler.aspx/slotAvailable",
                    data: JSON.stringify({ "selectedDateTime": clickedappointment.get_start(), "diaryId": diaryId, "userId": userId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (data.d != "") {
                            alert('This slot is locked by ' + data.d + '. Booking in progress.');
                            clickedContextMenu[1].findItemByValue("AddBooking").set_visible(false);
                            clickedContextMenu[1].findItemByValue("PasteBooking").set_visible(false);
                        }
                        else {
                            clickedContextMenu[1].findItemByValue("AddBooking").set_visible(true);
                            $.ajax({
                                type: "POST",
                                url: "Scheduler.aspx/GetAppointmentId",
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                success: function (data) {
                                    if (data.d > 0) {
                                        clickedContextMenu[1].findItemByValue("PasteBooking").set_visible(true);
                                    }
                                    else {
                                        clickedContextMenu[1].findItemByValue("PasteBooking").set_visible(false);
                                    }
                                },
                                error: function (jqXHR, textStatus, data) {
                                }
                            });
                        }
                    },
                    error: function (x, y, z) {
                        console.log(x.responseJSON.Message);
                    }
                });
            }
        }

        function setCalendarView(view) {
            $('.calender-view-toggle').find('li').each(function () {
                $(this).removeClass("selected-li");
            });

            var li = 1
            if (view == "day")
                li = 1;
            //else if (view == "week")
            //    li = 2;
            else if (view == "month")
                li = 2;

            $('.calender-view-toggle').find('li:nth-of-type(' + li + ')').addClass('selected-li')
        }

        function GetDiaryAmendedBookings(diaryDate, roomId) {
            $.ajax({
                type: "POST",
                url: "Scheduler.aspx/getAmendedBookings",
                data: JSON.stringify({ "diaryDate": diaryDate, "roomId": roomId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d) {
                        var res = JSON.parse(data.d);

                        if (res.length > 0) {
                            for (var i = 0; i < res.length; i++) {
                                var diaryType = res[i].diaryType;

                                if (diaryType == "AM") {
                                    $('#AmendedAMBookingsDiv').show();
                                }

                                if (diaryType == "PM") {
                                    $('#AmendedPMBookingsDiv').show();
                                }

                                if (diaryType == "EVE") {
                                    $('#AmendedEVEBookingsDiv').show();
                                }
                            }

                            //    if (res.find(x -> x.diaryType == "AM") != undefined) {
                            //        $('#AmendedAMBookingsDiv').show();
                            //    }
                            //    else {
                            //        $('#AmendedAMBookingsDiv').hide();
                            //}

                            //if (res.find(x => x.diaryType == "PM") != undefined) {
                            //    $('#AmendedPMBookingsDiv').show();
                            //}
                            //else {
                            //    $('#AmendedPMBookingsDiv').hide();
                            //}

                            //if (res.find(x => x.diaryType == "EVE") != undefined) {
                            //    $('#AmendedEVEBookingsDiv').show();
                            //}
                            //else {
                            //    $('#AmendedEVEBookingsDiv').hide();
                            //}
                        }
                    }
                },
                error: function (jqXHR, textStatus, data) {
                    //alert("An error occured while saving your notes");
                    console.log(jqXHR.responseJSON);
                    $('#AmendedAMBookingsDiv').hide();
                    $('#AmendedPMBookingsDiv').hide();
                    $('#AmendedEVEBookingsDiv').hide();
                }
            });
        }

        function NoContextMenu(sender, args) {
            alert('opening');
            args.set_cancel(true);
        }

        //function ShowHover(subject) {
        //    var e = window.event;
        //    var posX = e.clientX;
        //    var posY = e.clientY;

        //    $find("#ToolTip").st("visibility")

        //    alert(subject);
        //    alert(description);
        //}

    </script>
</telerik:RadScriptBlock>
<telerik:RadScriptBlock ID="ScriptBlock2" runat="server">
    <script type="text/javascript">
        function yesCancelBooking(sender, args) {
            $('.cancellation-confirmation').hide();
            $('.cancellation-confirmation-action').show();

            args.set_cancel(true);
        }

        function showWaitlist() {
            var oWnd = $find("<%=  SearchAvailableSlotWindow.ClientID%>");
            if (oWnd != null) {

                oWnd.setSize(1400, 1200);
                oWnd.set_title("Book from waitlist");
                oWnd.show();

                //$find('<%=CancelSearchButton.ClientID%>').set_commandName("CancelBookFromWaitlist");
            }
        }

        function findSlot() {
            var oWnd = $find("<%=SearchAvailableSlotWindow.ClientID  %>");
            if (oWnd != null) {
                oWnd.set_title("Search available slots");
                oWnd.show();

                //$find('<%=CancelSearchButton.ClientID%>').set_commandName("CancelSearchSlot");
            }
        }

        function moveBooking() {
            var oWnd = $find("<%= SearchAvailableSlotWindow.ClientID %>");
            if (oWnd != null) {
                oWnd.set_title("Search and move booking");
                oWnd.show();

                //$find('<%=CancelSearchButton.ClientID%>').set_commandName("CancelMoveBooking");
            }
        }

        function findBooking(sender, args) {
            var own = radopen("../Scheduler/BookingSearch.aspx", "Find existing booking...");
            own.set_visibleStatusbar(false);
            own.set_behaviors(Telerik.Web.UI.WindowBehaviors.Close);
            own.moveTo(100, 100);
            own.set_title("Search existing booking");
            args.set_cancel(true);
        }

        function RoomsDropDownShow() {
            $('#RoomsDropDownDiv').removeClass('hide-rooms-dropdown-div');
            $('#RoomsChangeButtonDiv').removeClass('hide-rooms-dropdown-div');
        }

        function RoomsDropDownHide() {
            $('#RoomsDropDownDiv').addClass('hide-rooms-dropdown-div');
            $('#RoomsChangeButtonDiv').addClass('hide-rooms-dropdown-div');
        }

    </script>
</telerik:RadScriptBlock>
<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />
<telerik:RadButton ID="btnReload" runat="server" OnClick="btnReload_Click" Style="display: none;" />
<telerik:RadNotification ID="DeleteBookingRadNotification" runat="server" VisibleOnPageLoad="false" Skin="Metro" AutoCloseDelay="7000" Position="Center" />

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Position="Center" Skin="Metro" Width="300" Height="200" />
<telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="SearchAvailableSlotDiv" Skin="Metro" />
<telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="PatientSearchDiv" Skin="Metro" />

<div id="FilterDiv">

    <table style="width: 100%;">
        <tr>
            <td style="width: 600px;">
                <div style="position: relative; float: left;">
                    <div style="float: left;" runat="server" id="TrustDiv">
                        Trust:&nbsp;<telerik:RadComboBox ID="TrustDropDownList" runat="server" Width="200" DataTextField="TrustName" AutoPostBack="true" DataValueField="TrustId" />
                    </div>

                    <div style="float: left;" runat="server" id="HospitalDiv">
                        Hospital:&nbsp;<telerik:RadComboBox ID="HospitalDropDownList" runat="server" Width="200" DataTextField="HospitalName" AutoPostBack="true" DataValueField="OperatingHospitalID" />
                    </div>

                    <div id="RoomsDropDownDiv" class="hide-rooms-dropdown-div" style="float: right;">
                        &nbsp;&nbsp; Room(s):&nbsp;<telerik:RadComboBox ID="RoomsDropdown" runat="server" Width="200" CheckBoxes="true" EnableCheckAllItemsCheckBox="true" DataValueField="RoomId" DataTextField="RoomName" AutoPostBack="false" AllowCustomText="true">
                            <Localization AllItemsCheckedString="All rooms selected" ItemsCheckedString="room(s) selected" />
                        </telerik:RadComboBox>
                    </div>

                </div>
            </td>
            <td valign="top">
                <div id="RoomsChangeButtonDiv" class="hide-rooms-dropdown-div" style="float: left;">
                    <telerik:RadButton ID="SetSelectedRoomRadButton" runat="server" Text="" Style="display: none;" OnClick="SetSelectedRoomRadButton_Click" />
                    <telerik:RadButton ID="ChangeRoomButton" runat="server" Text="Change Rooms" OnClick="ChangeRoomButton_Click" />
                </div>
            </td>
            <td valign="top" style="text-align: right; padding-right: 55px;">
                <telerik:RadButton ID="BookFromWaitlistRadButton" runat="server" Text="Book from waitlist" OnClientClicked="showWaitlist" OnClick="BookFromWaitlistRadButton_Click" Visible="false" />
                <telerik:RadButton ID="FindAvailableSlotRadButton" runat="server" Text="Find available slot" OnClientClicked="findSlot" OnClick="FindAvailableSlotRadButton_Click" />
                <telerik:RadButton ID="FindExistingBookingRadButton" runat="server" Text="Find existing booking" OnClientClicking="findBooking" />
            </td>
        </tr>
    </table>
</div>
<div id="FormDiv" runat="server" style="margin: 10px;" class="demo-container no-bg">

    <div class="calenderHeaderDiv rsHeader">
        <div class="date-toggle" style="float: left; margin-bottom: 10px;">
            <ul>
                <li>
                    <asp:LinkButton ID="PreviousDayLinkButton" runat="server" OnClick="PreviousDayLinkButton_Click">&larr;</asp:LinkButton></li>
                <li>
                    <asp:LinkButton ID="NextDayLinkButton" runat="server" OnClick="NextDayLinkButton_Click">&rarr;</asp:LinkButton></li>
                <li>
                    <asp:LinkButton ID="TodaysDateLinkButton" runat="server" CssClass="jump-to-today-button" OnClick="TodaysDateLinkButton_Click">go to today</asp:LinkButton>
                </li>
                <li class="calender-li">
                    <telerik:RadDatePicker ID="DiaryDatePicker" runat="server" AutoPostBack="true" CssClass="diary-calendar" Visible="true" Skin="Metro" DatePopupButton-ForeColor="White" OnSelectedDateChanged="DiaryDatePicker_SelectedDateChanged">
                    </telerik:RadDatePicker>
                </li>
                <li>
                    <asp:Label ID="CalendarDateLabel" runat="server" />
                </li>

            </ul>
        </div>
        <div class="room-display" style="float: left; margin-left: 37%; font-size: 15px; font-weight: bold;">
            <asp:Label ID="RoomNameLabel" runat="server" />
        </div>
        <div class="calender-view-toggle" style="float: right">
            <ul>
                <li>
                    <asp:LinkButton ID="DayLinkButton" runat="server" OnClick="DayLinkButton_Click" OnClientClick="RoomsDropDownHide();">Day</asp:LinkButton></li>
                <li runat="server" visible="false">
                    <asp:LinkButton ID="WeekLinkbutton" runat="server" OnClick="WeekLinkbutton_Click">Week</asp:LinkButton></li>
                <li>
                    <asp:LinkButton ID="MonthLinkbutton" runat="server" OnClick="MonthLinkbutton_Click" OnClientClick="RoomsDropDownShow();">Month/Overview</asp:LinkButton></li>
            </ul>
        </div>
    </div>

    <div id="dayViewDiv" runat="server">
        <table style="width: 100%;">
            <tr>
                <td valign="top" style="border-right: 2px solid #25a0da; width: 150px;">
                    <telerik:RadAjaxPanel runat="server">
                        <asp:HiddenField ID="SelectedRoomHiddenField" runat="server" />
                        <asp:Repeater ID="rptRoomTabs" runat="server">
                            <HeaderTemplate>
                                <div class="room-tabs">
                                    <ul id="room-tab">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <li onclick="roomTabClicked(this)" data-id='<%#Eval("RoomId") %>' data-name='<%#Eval("RoomName") %>'>
                                    <span><%# Eval("RoomName") %></span>
                                </li>
                            </ItemTemplate>
                            <FooterTemplate>
                                </ul>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>
                    </telerik:RadAjaxPanel>
                </td>
                <td valign="top">
                    <div class="zoom" style="">
                        <div style="padding-left: 85px; font-size: 10px;">Zoom</div>
                        <telerik:RadSlider ID="RadSlider1" runat="server" ItemType="Item" Skin="Metro" ThumbsInteractionMode="Free" Value="1" TrackPosition="TopLeft" Height="40px" AutoPostBack="true"
                            OnValueChanged="Unnamed_ValueChanged">
                            <Items>
                                <telerik:RadSliderItem Value="15" Text="100%" />
                                <telerik:RadSliderItem Value="10" Text="150%" />
                                <telerik:RadSliderItem Value="5" Text="200%" />
                            </Items>
                        </telerik:RadSlider>
                        <table style="font-size: 10px; display: none;">
                            <tr>
                                <td style="width: 3%;">
                                    <asp:ImageButton ID="btnZoomIn" runat="server" AlternateText="Zoom in" ImageUrl="~/Images/icons/ZoomIn.png" Width="35" OnClick="btnZoomIn_Click" />
                                    <br />
                                    zoom in
                                </td>
                                <td style="border-left: 1px dotted #25a0da; padding-left: 2px;">
                                    <asp:ImageButton ID="btnZoomOut" runat="server" AlternateText="Zoom out" ImageUrl="~/Images/icons/ZoomOut.png" Width="35" OnClick="btnZoomOut_Click" />
                                    <br />
                                    zoom out
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div style="overflow-y: hidden; margin-top: -6px;">
                        <div style="width: 100%; text-align: left;">
                        </div>
                        <div id="AMDiv" runat="server" class="tod-div" visible="true">
                            <div style="position: relative;" class="header-session">
                                <div class="lock-list-div">
                                    <asp:ImageButton ID="imgAMListLock" runat="server" ImageUrl="~/Images/Lock-Lock-48x48.png" Width="25" Visible="false" OnClick="imgAMListLock_Click" />
                                </div>
                                <span>Morning</span>
                            </div>
                            <div class="header-diary-details">
                                <asp:Label ID="AMDiaryDetails" runat="server" Visible="false" />
                                <div style="text-align: center; display: none;">
                                </div>
                                <div id="AmendedAMBookingsDiv" style="padding-top: 20px; float: right; display: none;">
                                    <span>Patients cancelled</span>&nbsp;
                                <asp:LinkButton ID="ShowAMAmendedBookingsLinkButton" runat="server" Text="View" />
                                </div>
                            </div>

                            <div class="day-notes">
                                <b>
                                    <asp:TextBox ID="AMNotesTextBox" runat="server" TextMode="MultiLine" placeholder="Notes:" CssClass="notes-textbox" />&nbsp;</b>
                            </div>

                            <asp:HiddenField ID="SelectedApppointmentId" runat="server" />
                            <div id="NoAMListDiv" runat="server" visible="false" class="no-template-div"><span>No template assigned</span></div>
                            <telerik:RadScheduler ID="AMRadScheduler" runat="server" RowHeight="30" Height="95%" Width="100%"
                                DataKeyField="DiaryId" DataRecurrenceField="RecurrenceRule"
                                StartEditingInAdvancedForm="true" StartInsertingInAdvancedForm="true"
                                DataRecurrenceParentKeyField="RecurrenceParentID" EnableDescriptionField="false"
                                DataDescriptionField="Description" GroupingDirection="Horizontal" MinutesPerRow="10"
                                Localization-AdvancedSubjectRequired="False" HoursPanelTimeFormat="HH:mm" ShowAllDayRow="false"
                                MonthView-AdaptiveRowHeight="false" ShowFullTime="False" ShowHeader="false" ShowFooter="false" ShowHoursColumn="true" EnableExactTimeRendering="true"
                                DataStartField="DiaryStart" ShowResourceHeaders="false" DataEndField="DiaryEnd" DataSubjectField="Subject" Skin="Metro"
                                AllowEdit="false"
                                WorkDayStartTime="00:00"
                                WorkDayEndTime="23:59"
                                OnClientAppointmentContextMenuItemClicked="ContextClicked"
                                OnClientAppointmentMoveStart="OnClientAppointmentMoveStart"
                                OnClientAppointmentDoubleClick="OnClientAppointmentDoubleClick"
                                OnClientAppointmentContextMenu="OnClientAppointmentContextMenu"
                                OnClientAppointmentEditing="OnClientAppointmentEditing"
                                OnNavigationComplete="ListRadScheduler_NavigationComplete"
                                OnFormCreated="ListRadScheduler_FormCreated"
                                OnAppointmentInsert="ListRadScheduler_AppointmentInsert"
                                OnAppointmentDataBound="ListRadScheduler_AppointmentDataBound"
                                OnPreRender="ListRadScheduler_PreRender"
                                OnTimeSlotCreated="RadScheduler_TimeSlotCreated"
                                OnAppointmentCreated="ListRadScheduler_AppointmentCreated"
                                OnAppointmentContextMenuItemClicked="ListRadScheduler_AppointmentContextMenuItemClicked"
                                OverflowBehavior="Expand">
                                <AdvancedForm Modal="true" />
                                <AppointmentContextMenus>
                                    <telerik:RadSchedulerContextMenu runat="server" ID="EndOfListContextMenuAM" />
                                    <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerAppointmentContextMenuAM">
                                        <Items>
                                            <telerik:RadMenuItem Text="Add a new booking..." Value="AddBooking" ImageUrl="../images/icons/add.png">
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Paste Booking" Value="PasteBooking"></telerik:RadMenuItem>
                                        </Items>
                                    </telerik:RadSchedulerContextMenu>
                                    <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerBookingContextMenuAM">
                                        <Items>
                                            <telerik:RadMenuItem Text="Set partially booked" Value="PartiallyBooked" />
                                            <telerik:RadMenuItem Text="Set patient confirmed" Value="PatientConfirmed" />
                                            <telerik:RadMenuItem Text="Patient Confirmed" Value="BookingConfirmed">
                                                <Items>
                                                    <telerik:RadMenuItem Text="Set partially booked" Value="PatientStatus" />
                                                </Items>
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Edit Booking" Value="EditBooking"></telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Move Booking" Value="MoveBooking"></telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Cut Booking" Value="CutBooking"></telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Cancel Booking" Value="DeleteBooking" />
                                            <telerik:RadMenuItem Text="Patient Pathway" Value="PatientPathway">
                                                <Items>
                                                    <telerik:RadMenuItem Text="Mark Booked" Value="MarkBooked" />
                                                    <telerik:RadMenuItem Text="Mark Arrived" Value="MarkAttended" />
                                                    <telerik:RadMenuItem Text="Mark Discharged" Value="MarkDischarged" />
                                                </Items>
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Patient DNA" Value="PatientDNA" />
                                            <telerik:RadMenuItem Text="Print Letter" Value="PrintLetter">
                                                <Items>
                                                    <telerik:RadMenuItem Text="With Additional Document" Value="WithDocument" />
                                                    <telerik:RadMenuItem Text="Without Additional Document" Value="WithoutDocument" />
                                                </Items>
                                            </telerik:RadMenuItem>
                                        </Items>
                                    </telerik:RadSchedulerContextMenu>
                                </AppointmentContextMenus>
                                <TimelineView GroupBy="Room" GroupingDirection="Vertical" HeaderDateFormat="dd MMM yyyy" ColumnHeaderDateFormat="dd/MM/yyyy"></TimelineView>
                                <WeekView HeaderDateFormat="dd MMM yyyy" />
                                <AgendaView HeaderDateFormat="dd MMM yyyy" />
                                <ResourceTypes>
                                    <telerik:ResourceType DataSourceID="RoomsDataSource" ForeignKeyField="RoomID"
                                        KeyField="RoomId" Name="Room" TextField="RoomName" />
                                </ResourceTypes>
                                <AppointmentTemplate>
                                    <div class="patient-attendance-icons" style="float: left; margin-right: 5px;">
                                        <img src="../Images/Ok.png" id="PatientAttendedImageAM" runat="server" visible="false" />
                                        <telerik:RadToolTip ID="PatientJourneyIconTooltipAM" runat="server" TargetControlID="PatientAttendedImageAM" />
                                    </div>
                                    <div style="font-weight: bold; float: left;">
                                        <%# Eval("Subject") %>
                                    </div>
                                    <div class="tooltip-icons" style="float: right;">
                                        <table border="0">
                                            <tr>
                                                <td>
                                                    <img id="AppointmentNotesToolTipImageAM" runat="server" src="../Images/icons/alert.png" visible="false" /></td>
                                                <td>
                                                    <telerik:RadToolTip ID="AppointmentNotesToolTipAM" runat="server" TargetControlID="AppointmentNotesTooltipImageAM" Text="tooltip test" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div class="tooltip-icons" style="float: right;">
                                        <table border="0">
                                            <tr>
                                                <td>
                                                    <img id="AppointmentGeneralInfoToolTipImageAM" runat="server" src="../Images/alert_round.png" visible="false" /></td>
                                                <td>
                                                    <telerik:RadToolTip ID="AppointmentGeneralInfoToolTipAM" runat="server" TargetControlID="AppointmentGeneralInfoToolTipImageAM" Text="tooltip test" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </AppointmentTemplate>
                                <Localization AdvancedEditAppointment="Set worklists (using templates)" AdvancedNewAppointment="Set worklists (using templates)"
                                    ConfirmDeleteText="Are you sure you want to delete this worklist?" ConfirmRecurrenceDeleteTitle="Deleting a recurring worklist"
                                    ConfirmRecurrenceEditTitle="Editing a recurring worklist" HeaderAgendaAppointment="Worklist" HeaderAgendaResource="Room name" AdvancedSubject="Title" />
                            </telerik:RadScheduler>
                        </div>
                        <div id="PMDiv" runat="server" class="tod-div">
                            <div style="position: relative;" class="header-session">
                                <div class="lock-list-div">
                                    <asp:ImageButton ID="imgPMListLock" runat="server" ImageUrl="~/Images/Lock-Lock-48x48.png" Width="25" Visible="false" OnClick="imgPMListLock_Click" />
                                </div>
                                <span>Afternoon</span>
                            </div>
                            <div class="header-diary-details">
                                <asp:Label ID="PMDiaryDetails" runat="server" Visible="false" />
                                <div style="text-align: center; display: none;">
                                </div>
                                <div id="AmendedPMBookingsDiv" style="padding-top: 20px; float: right; display: none;">
                                    <span>Patients cancelled</span>&nbsp;
                                <asp:LinkButton ID="ShowPMAmendedBookingsLinkButton" runat="server" Text="View" />
                                </div>
                            </div>
                            <div class="day-notes">
                                <b>
                                    <asp:TextBox ID="PMNotesTextBox" runat="server" TextMode="MultiLine" placeholder="Notes:" CssClass="notes-textbox" />&nbsp;</b>
                            </div>
                            <div id="NoPMListDiv" runat="server" visible="false" class="no-template-div"><span>No template assigned</span></div>
                            <telerik:RadScheduler ID="PMRadScheduler" runat="server" RowHeight="30" Height="95%" Width="100%"
                                DataKeyField="DiaryId" DataRecurrenceField="RecurrenceRule"
                                StartEditingInAdvancedForm="true" StartInsertingInAdvancedForm="true"
                                DataRecurrenceParentKeyField="RecurrenceParentID" EnableDescriptionField="false"
                                DataDescriptionField="Description" GroupingDirection="Horizontal" MinutesPerRow="10"
                                Localization-AdvancedSubjectRequired="False" EnableExactTimeRendering="true" HoursPanelTimeFormat="HH:mm" ShowAllDayRow="false"
                                MonthView-AdaptiveRowHeight="false" ShowFullTime="False" ShowHoursColumn="false" ShowHeader="false" ShowFooter="false"
                                AllowEdit="false" DayStartTime="00:00" DayEndTime="00:00"
                                DataStartField="DiaryStart" ShowResourceHeaders="false" DataEndField="DiaryEnd" DataSubjectField="Subject" Skin="Metro"
                                OnClientAppointmentContextMenuItemClicked="ContextClicked"
                                OnClientAppointmentContextMenu="OnClientAppointmentContextMenu"
                                OnClientAppointmentMoveStart="OnClientAppointmentMoveStart"
                                OnClientAppointmentDoubleClick="OnClientAppointmentDoubleClick"
                                OnClientAppointmentEditing="OnClientAppointmentEditing"
                                OnNavigationComplete="ListRadScheduler_NavigationComplete"
                                OnFormCreated="ListRadScheduler_FormCreated"
                                OnAppointmentInsert="ListRadScheduler_AppointmentInsert"
                                OnAppointmentDataBound="ListRadScheduler_AppointmentDataBound"
                                OnPreRender="ListRadScheduler_PreRender"
                                OnTimeSlotCreated="RadScheduler_TimeSlotCreated"
                                OnAppointmentCreated="ListRadScheduler_AppointmentCreated"
                                OnAppointmentContextMenuItemClicked="ListRadScheduler_AppointmentContextMenuItemClicked"
                                OverflowBehavior="Expand">
                                <AdvancedForm Modal="true" />
                                <AppointmentContextMenus>
                                    <telerik:RadSchedulerContextMenu runat="server" ID="EndOfListContextMenuPM" />
                                    <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerAppointmentContextMenuPM">
                                        <Items>
                                            <telerik:RadMenuItem Text="Add a new booking..." Value="AddBooking" ImageUrl="../images/icons/add.png">
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Paste Booking" Value="PasteBooking"></telerik:RadMenuItem>
                                        </Items>
                                    </telerik:RadSchedulerContextMenu>
                                    <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerBookingContextMenuPM">
                                        <Items>
                                            <telerik:RadMenuItem Text="Set partially booked" Value="PartiallyBooked" />
                                            <telerik:RadMenuItem Text="Set patient confirmed" Value="PatientConfirmed" />
                                            <telerik:RadMenuItem Text="Patient Confirmed" Value="BookingConfirmed">
                                                <Items>
                                                    <telerik:RadMenuItem Text="Set partially booked" Value="PatientStatus" />
                                                </Items>
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Edit Booking" Value="EditBooking"></telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Move Booking" Value="MoveBooking"></telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Cut Booking" Value="CutBooking"></telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Cancel Booking" Value="DeleteBooking" />
                                            <telerik:RadMenuItem Text="Patient Pathway" Value="PatientPathway">
                                                <Items>
                                                    <telerik:RadMenuItem Text="Mark Booked" Value="MarkBooked" />
                                                    <telerik:RadMenuItem Text="Mark Arrived" Value="MarkAttended" />
                                                    <telerik:RadMenuItem Text="Mark Discharged" Value="MarkDischarged" />
                                                </Items>
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Patient DNA" Value="PatientDNA" />
                                            <telerik:RadMenuItem Text="Print Letter" Value="PrintLetter">
                                                <Items>
                                                    <telerik:RadMenuItem Text="With Additional Document" Value="WithDocument" />
                                                    <telerik:RadMenuItem Text="Without Additional Document" Value="WithoutDocument" />
                                                </Items>
                                            </telerik:RadMenuItem>
                                        </Items>
                                    </telerik:RadSchedulerContextMenu>
                                </AppointmentContextMenus>
                                <TimelineView GroupBy="Room" GroupingDirection="Vertical" HeaderDateFormat="dd MMM yyyy" ColumnHeaderDateFormat="dd/MM/yyyy"></TimelineView>
                                <WeekView HeaderDateFormat="dd MMM yyyy" />
                                <AgendaView HeaderDateFormat="dd MMM yyyy" />
                                <ResourceTypes>
                                    <telerik:ResourceType DataSourceID="RoomsDataSource" ForeignKeyField="RoomID"
                                        KeyField="RoomId" Name="Room" TextField="RoomName" />
                                </ResourceTypes>
                                <AppointmentTemplate>
                                    <div class="patient-attendance-icons">
                                        <img src="../Images/Ok.png" id="PatientAttendedImagePM" runat="server" visible="false" />
                                        <telerik:RadToolTip ID="PatientJourneyIconTooltipPM" runat="server" TargetControlID="PatientAttendedImagePM" />
                                    </div>
                                    <div style="font-weight: bold; float: left;">
                                        <%# Eval("Subject") %>
                                    </div>
                                    <div class="tooltip-icons" style="float: right;">
                                        <table border="0">
                                            <tr>
                                                <td>
                                                    <img id="AppointmentNotesToolTipImagePM" runat="server" src="../Images/icons/alert.png" visible="false" /></td>
                                                <td>
                                                    <telerik:RadToolTip ID="AppointmentNotesToolTipPM" runat="server" TargetControlID="AppointmentNotesTooltipImagePM" Text="tooltip test" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div class="tooltip-icons" style="float: right;">
                                        <table border="0">
                                            <tr>
                                                <td>
                                                    <img id="AppointmentGeneralInfoToolTipImagePM" runat="server" src="../Images/alert_round.png" visible="false" /></td>
                                                <td>
                                                    <telerik:RadToolTip ID="AppointmentGeneralInfoToolTipPM" runat="server" TargetControlID="AppointmentGeneralInfoToolTipImagePM" Text="tooltip test" Width="20px" />
                                                </td>
                                            </tr>
                                        </table>
                                </AppointmentTemplate>
                                <Localization AdvancedEditAppointment="Set worklists (using templates)" AdvancedNewAppointment="Set worklists (using templates)"
                                    ConfirmDeleteText="Are you sure you want to delete this worklist?" ConfirmRecurrenceDeleteTitle="Deleting a recurring worklist"
                                    ConfirmRecurrenceEditTitle="Editing a recurring worklist" HeaderAgendaAppointment="Worklist" HeaderAgendaResource="Room name" AdvancedSubject="Title" />
                            </telerik:RadScheduler>
                        </div>
                        <div id="EVEDiv" runat="server" class="tod-div">
                            <div style="position: relative;" class="header-session">
                                <div class="lock-list-div">
                                    <asp:ImageButton ID="imgEVEListLock" runat="server" ImageUrl="~/Images/Lock-Lock-48x48.png" Width="25" Visible="false" OnClick="imgEVEListLock_Click" />
                                </div>
                                <span>Evening</span>
                            </div>
                            <div class="header-diary-details">
                                <asp:Label ID="EVEDiaryDetails" runat="server" Visible="false" />
                                <div style="text-align: center; display: none;">
                                </div>
                                <div id="AmendedEVEBookingsDiv" style="padding-top: 20px; float: right; display: none;">
                                    <span>Patients cancelled</span>&nbsp;
                                    <asp:LinkButton ID="ShowEVEAmendedBookingsLinkButton" runat="server" Text="View" />
                                </div>
                            </div>
                            <div class="day-notes">
                                <asp:TextBox ID="EVENotesTextBox" runat="server" TextMode="MultiLine" placeholder="Notes:" />&nbsp;
                            </div>
                            <div style="text-align: center; display: none;">
                                <strong>
                                    <asp:Label ID="lblEVEListConsultant" runat="server" /></strong>
                            </div>
                            <div id="NoEVEListDiv" runat="server" visible="false" class="no-template-div"><span>No template assigned</span></div>
                            <telerik:RadScheduler ID="EVRadScheduler" runat="server" RowHeight="30" Height="100%" Width="100%"
                                DataKeyField="DiaryId" DataRecurrenceField="RecurrenceRule"
                                StartEditingInAdvancedForm="true" StartInsertingInAdvancedForm="true"
                                DataRecurrenceParentKeyField="RecurrenceParentID" EnableDescriptionField="false"
                                DataDescriptionField="Description" GroupingDirection="Horizontal" MinutesPerRow="10"
                                Localization-AdvancedSubjectRequired="False" EnableExactTimeRendering="true" HoursPanelTimeFormat="HH:mm" ShowAllDayRow="false"
                                MonthView-AdaptiveRowHeight="false" ShowFullTime="False" ShowHoursColumn="false" ShowHeader="false" ShowFooter="false"
                                AllowEdit="false"
                                DataStartField="DiaryStart" ShowResourceHeaders="false" DataEndField="DiaryEnd" DataSubjectField="Subject" Skin="Metro" WorkDayEndTime="23:59"
                                OnClientAppointmentContextMenuItemClicked="ContextClicked"
                                OnClientAppointmentContextMenu="OnClientAppointmentContextMenu"
                                OnClientAppointmentMoveStart="OnClientAppointmentMoveStart"
                                OnClientAppointmentDoubleClick="OnClientAppointmentDoubleClick"
                                OnClientAppointmentEditing="OnClientAppointmentEditing"
                                OnNavigationComplete="ListRadScheduler_NavigationComplete"
                                OnFormCreated="ListRadScheduler_FormCreated"
                                OnAppointmentInsert="ListRadScheduler_AppointmentInsert"
                                OnAppointmentDataBound="ListRadScheduler_AppointmentDataBound"
                                OnPreRender="ListRadScheduler_PreRender"
                                OnTimeSlotCreated="RadScheduler_TimeSlotCreated"
                                OnAppointmentCreated="ListRadScheduler_AppointmentCreated"
                                OnAppointmentContextMenuItemClicked="ListRadScheduler_AppointmentContextMenuItemClicked"
                                OverflowBehavior="Expand">
                                <AdvancedForm Modal="true" />
                                <AppointmentContextMenus>
                                    <telerik:RadSchedulerContextMenu runat="server" ID="EndOfListContextMenuEVE" />
                                    <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerAppointmentContextMenuEVE">
                                        <Items>
                                            <telerik:RadMenuItem Text="Add a new booking..." Value="AddBooking" ImageUrl="../images/icons/add.png">
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Paste Booking" Value="PasteBooking"></telerik:RadMenuItem>
                                        </Items>
                                    </telerik:RadSchedulerContextMenu>
                                    <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerBookingContextMenuEVE">
                                        <Items>
                                            <telerik:RadMenuItem Text="Set partially booked" Value="PartiallyBooked" />
                                            <telerik:RadMenuItem Text="Set patient confirmed" Value="PatientConfirmed" />
                                            <telerik:RadMenuItem Text="Patient Confirmed" Value="BookingConfirmed">
                                                <Items>
                                                    <telerik:RadMenuItem Text="Set partially booked" Value="PatientStatus" />
                                                </Items>
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Edit Booking" Value="EditBooking"></telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Move Booking" Value="MoveBooking"></telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Cut Booking" Value="CutBooking"></telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Cancel Booking" Value="DeleteBooking" />
                                            <telerik:RadMenuItem Text="Patient Pathway" Value="PatientPathway">
                                                <Items>
                                                    <telerik:RadMenuItem Text="Mark Booked" Value="MarkBooked" />
                                                    <telerik:RadMenuItem Text="Mark Arrived" Value="MarkAttended" />
                                                    <telerik:RadMenuItem Text="Mark Discharged" Value="MarkDischarged" />
                                                </Items>
                                            </telerik:RadMenuItem>
                                            <telerik:RadMenuItem Text="Patient DNA" Value="PatientDNA" />
                                            <telerik:RadMenuItem Text="Print Letter" Value="PrintLetter">
                                                <Items>
                                                    <telerik:RadMenuItem Text="With Additional Document" Value="WithDocument" />
                                                    <telerik:RadMenuItem Text="Without Additional Document" Value="WithoutDocument" />
                                                </Items>
                                            </telerik:RadMenuItem>
                                        </Items>
                                    </telerik:RadSchedulerContextMenu>

                                </AppointmentContextMenus>
                                <TimelineView GroupBy="Room" GroupingDirection="Vertical" HeaderDateFormat="dd MMM yyyy" ColumnHeaderDateFormat="dd/MM/yyyy"></TimelineView>
                                <WeekView HeaderDateFormat="dd MMM yyyy" />
                                <AgendaView HeaderDateFormat="dd MMM yyyy" />
                                <ResourceTypes>
                                    <telerik:ResourceType DataSourceID="RoomsDataSource" ForeignKeyField="RoomID"
                                        KeyField="RoomId" Name="Room" TextField="RoomName" />
                                </ResourceTypes>
                                <AppointmentTemplate>
                                    <div class="patient-attendance-icons">
                                        <img src="../Images/Ok.png" id="PatientAttendedImageEVE" runat="server" visible="false" />
                                        <telerik:RadToolTip ID="PatientJourneyIconTooltipEVE" runat="server" TargetControlID="PatientAttendedImageEVE" />
                                    </div>
                                    <div style="font-weight: bold; float: left;">
                                        <%# Eval("Subject") %>
                                    </div>
                                    <div class="tooltip-icons" style="float: right;">
                                        <table border="0">
                                            <tr>
                                                <td>
                                                    <img id="AppointmentNotesToolTipImageEVE" runat="server" src="../Images/icons/alert.png" visible="false" /></td>
                                                <td>
                                                    <telerik:RadToolTip ID="AppointmentNotesToolTipEVE" runat="server" TargetControlID="AppointmentNotesTooltipImageEVE" Text="tooltip test" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div class="tooltip-icons" style="float: right;">
                                        <table border="0">
                                            <tr>
                                                <td>
                                                    <img id="AppointmentGeneralInfoToolTipImageEVE" runat="server" src="../Images/alert_round.png" visible="false" /></td>
                                                <td>
                                                    <telerik:RadToolTip ID="AppointmentGeneralInfoToolTipEVE" runat="server" TargetControlID="AppointmentGeneralInfoToolTipImageEVE" Text="tooltip test" />
                                                </td>
                                            </tr>
                                        </table>
                                </AppointmentTemplate>
                                <Localization AdvancedEditAppointment="Set worklists (using templates)" AdvancedNewAppointment="Set worklists (using templates)"
                                    ConfirmDeleteText="Are you sure you want to delete this worklist?" ConfirmRecurrenceDeleteTitle="Deleting a recurring worklist"
                                    ConfirmRecurrenceEditTitle="Editing a recurring worklist" HeaderAgendaAppointment="Worklist" HeaderAgendaResource="Room name" AdvancedSubject="Title" />
                            </telerik:RadScheduler>
                        </div>
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <div id="DiaryOverviewDiv" runat="server" style="height: 100%;" visible="false">
        <div style="float: right; padding-right: 30px; padding-top: 3px;">
            <div style="float: left;">
                <asp:RadioButtonList ID="OverviewTypeRadioButtonList" runat="server" RepeatDirection="Horizontal" OnSelectedIndexChanged="OverviewTypeRadioButtonList_SelectedIndexChanged" AutoPostBack="true">
                    <asp:ListItem Text="All lists" Value="list" Selected="True" />
                    <asp:ListItem Text="By endoscopist" Value="endo" />
                </asp:RadioButtonList>
            </div>
            <div style="float: left; visibility: hidden;" class="overview-endo-div">
                <telerik:RadComboBox ID="OverviewEndoscopistRadComboBox" runat="server" AutoPostBack="true" OnSelectedIndexChanged="OverviewEndoscopist_SelectedIndexChanged" Filter="StartsWith" />
            </div>
        </div>
        <telerik:RadScheduler ID="DiaryOverviewRadScheduler" runat="server" RowHeight="60" Height="600" Width="95%" AppointmentStyleMode="Default"
            DataKeyField="DiaryId" DataRecurrenceField="RecurrenceRule" AgendaView-UserSelectable="true" CssClass="Overview-Scheduler"
            StartEditingInAdvancedForm="true" StartInsertingInAdvancedForm="true"
            DataRecurrenceParentKeyField="RecurrenceParentID" EnableDescriptionField="false"
            DataDescriptionField="Description" GroupBy="Room" GroupingDirection="Horizontal" OverflowBehavior="Scroll"
            Localization-AdvancedSubjectRequired="False" EnableExactTimeRendering="false" HoursPanelTimeFormat="HH:mm"
            MonthView-AdaptiveRowHeight="false" ShowFullTime="true" DayEndTime="17:00" ShowHeader="false" ShowFooter="false"
            DataStartField="DiaryStart" DataEndField="DiaryEnd" DataSubjectField="Subject" Skin="Metro"
            AllowEdit="false"
            AllowInsert="false"
            EnableViewState="false"
            OnAppointmentContextMenuItemClicked="ListRadScheduler_AppointmentContextMenuItemClicked"
            OnClientAppointmentMoveStart="OnClientAppointmentMoveStart"
            OnClientAppointmentContextMenuItemClicked="OverviewContextClicked"
            OnAppointmentDataBound="ListRadScheduler_AppointmentDataBound"
            OnAppointmentCreated="ListRadScheduler_AppointmentCreated">
            <AdvancedForm Modal="true" />
            <MonthView VisibleAppointmentsPerDay="3" />
            <AppointmentContextMenus>
                <telerik:RadSchedulerContextMenu runat="server" ID="DiaryOverviewRadSchedulerContextMenu">
                    <Items>
                        <telerik:RadMenuItem Text="Go to date" Value="GoToDate" runat="server">
                        </telerik:RadMenuItem>
                    </Items>
                </telerik:RadSchedulerContextMenu>
            </AppointmentContextMenus>

            <TimelineView GroupBy="Room" GroupingDirection="Vertical" HeaderDateFormat="dd MMM yyyy" ColumnHeaderDateFormat="dd/MM/yyyy"></TimelineView>
            <WeekView HeaderDateFormat="dd MMM yyyy" />
            <AgendaView UserSelectable="false" HeaderDateFormat="dd MMM yyyy" />
            <ResourceTypes>
                <telerik:ResourceType DataSourceID="RoomsDataSource" ForeignKeyField="RoomID"
                    KeyField="RoomId" Name="Room" TextField="RoomName" />
            </ResourceTypes>
            <AppointmentTemplate>
                <div style="font-weight: normal;">
                    <b><%# Eval("subject") %></b>

                    <div style="font-style: normal;">
                        <%# Eval("Description") %>
                    </div>

                </div>
            </AppointmentTemplate>
        </telerik:RadScheduler>
    </div>
    <div id="OtherViewDiv" runat="server" visible="false" style="height: 100%;">
        <telerik:RadScheduler ID="ListRadScheduler" runat="server" RowHeight="25" Height="600" Width="95%"
            DataKeyField="DiaryId" DataRecurrenceField="RecurrenceRule"
            StartEditingInAdvancedForm="true" StartInsertingInAdvancedForm="true"
            DataRecurrenceParentKeyField="RecurrenceParentID" EnableDescriptionField="false"
            DataDescriptionField="Description" GroupBy="Room" GroupingDirection="Horizontal" OverflowBehavior="Scroll" MinutesPerRow="10"
            Localization-AdvancedSubjectRequired="False" ShowResourceHeaders="false" WeekView-EnableExactTimeRendering="true" HoursPanelTimeFormat="HH:mm"
            MonthView-AdaptiveRowHeight="false" ShowFullTime="False" DayStartTime="07:00" DayEndTime="17:00" ShowHeader="false" ShowFooter="false"
            DataStartField="DiaryStart" DataEndField="DiaryEnd" DataSubjectField="Subject" Skin="Metro"
            OnClientAppointmentContextMenuItemClicked="ContextClicked"
            OnClientAppointmentContextMenu="OnClientWewekViewAppointmentContextMenu"
            OnClientAppointmentMoveStart="OnClientAppointmentMoveStart"
            OnClientAppointmentDoubleClick="OnClientAppointmentDoubleClick"
            OnClientAppointmentEditing="OnClientAppointmentEditing"
            OnNavigationComplete="ListRadScheduler_NavigationComplete"
            OnFormCreated="ListRadScheduler_FormCreated"
            OnAppointmentInsert="ListRadScheduler_AppointmentInsert"
            OnAppointmentDataBound="ListRadScheduler_AppointmentDataBound"
            OnAppointmentCreated="ListRadScheduler_AppointmentCreated"
            ViewStateMode="Disabled" AllowEdit="false">
            <AdvancedForm Modal="true" />
            <AppointmentContextMenus>
                <telerik:RadSchedulerContextMenu runat="server" ID="RadSchedulerContextMenu2" />

                <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerAppointmentContextMenu">
                    <Items>
                        <telerik:RadMenuItem Text="Add a new booking..." Value="AddBooking" ImageUrl="../images/icons/add.png">
                        </telerik:RadMenuItem>
                        <telerik:RadMenuItem Text="Paste Booking" Value="PasteBooking"></telerik:RadMenuItem>
                    </Items>
                </telerik:RadSchedulerContextMenu>
                <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerBookingContextMenu">
                    <Items>
                        <telerik:RadMenuItem Text="Edit Booking" Value="EditBooking" ImageUrl="../images/icons/Edit.png"></telerik:RadMenuItem>
                        <telerik:RadMenuItem Text="Move Booking" Value="EditBooking" Visible="false"></telerik:RadMenuItem>
                        <telerik:RadMenuItem Text="Cut Booking" Value="CutBooking"></telerik:RadMenuItem>
                        <telerik:RadMenuItem Text="Cancel Booking" Value="DeleteBooking" />
                    </Items>
                </telerik:RadSchedulerContextMenu>

            </AppointmentContextMenus>

            <TimelineView GroupBy="Room" GroupingDirection="Vertical" HeaderDateFormat="dd MMM yyyy" ColumnHeaderDateFormat="dd/MM/yyyy"></TimelineView>
            <WeekView HeaderDateFormat="dd MMM yyyy" />
            <AgendaView UserSelectable="false" HeaderDateFormat="dd MMM yyyy" />
            <ResourceTypes>
                <telerik:ResourceType DataSourceID="RoomsDataSource" ForeignKeyField="RoomID"
                    KeyField="RoomId" Name="Room" TextField="RoomName" />

            </ResourceTypes>
            <AppointmentTemplate>
                <div style="font-weight: bold; float: left;" title="<%# Eval("Subject") %>">
                    <%# Eval("Subject") %>
                </div>
                <div class="tooltip-icons" style="float: right;">
                    <table border="0">
                        <tr>
                            <td>
                                <img id="AppointmentNotesToolTipImage" runat="server" src="../Images/icons/alert.png" visible="false" /></td>
                            <td>
                                <telerik:RadToolTip ID="AppointmentNotesToolTip" runat="server" TargetControlID="AppointmentNotesTooltipImage" Text="tooltip test" />
                            </td>
                        </tr>
                    </table>
                </div>
            </AppointmentTemplate>
            <Localization AdvancedEditAppointment="Set worklists (using templates)" AdvancedNewAppointment="Set worklists (using templates)"
                ConfirmDeleteText="Are you sure you want to delete this worklist?" ConfirmRecurrenceDeleteTitle="Deleting a recurring worklist"
                ConfirmRecurrenceEditTitle="Editing a recurring worklist" HeaderAgendaAppointment="Worklist" HeaderAgendaResource="Room name" AdvancedSubject="Title" />
        </telerik:RadScheduler>

    </div>
</div>


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

        <telerik:RadWindow ID="PatientDeleteBookingConfirmationWindow" runat="server" Width="650" Height="200" CssClass="rad-window" VisibleStatusbar="false">
            <ContentTemplate>
                <div>

                    <asp:HiddenField ID="PatientAppointmentIDHiddenField" runat="server" />

                    <div style="padding: 10px;">
                        <div class="cancellation-confirmation" style="text-align: center; padding: 30px;">
                            Are you sure you want to cancel this booking?
                            <div class="buttons-div" style="margin-top: 20px;">
                                <telerik:RadButton ID="YesCancelBookingRadButton" runat="server" Text="Yes" OnClientClicking="yesCancelBooking" />
                                <telerik:RadButton ID="NoCancelBookingRadButton" runat="server" Text="No" OnClientClicking="closeRadWindow" />
                            </div>
                        </div>
                        <div class="cancellation-confirmation-action" style="display: none;">
                            <%--<fieldset>--%>
                            <%--<legend>When this booking is cancelled...</legend>--%>
                            <div style="text-align: center;">
                                <asp:RadioButtonList ID="CancelledActionRadioButtonList" runat="server" RepeatDirection="Horizontal" Width="100%" Visible="false">
                                    <asp:ListItem Value="leavefree" Text="leave as free slot" Selected="True" />
                                    <%--<asp:ListItem Value="moveup" Text="move everyone up the list" />--%>
                                </asp:RadioButtonList><br />
                                Please enter a reason for cancellation&nbsp;<telerik:RadComboBox ZIndex="79876" ID="CancellationReasonRadComboBox" DataSourceID="CancellationReasonsObjectDataSource" runat="server" DataTextField="CancellationReason" DataValueField="CancelReasonId" AppendDataBoundItems="true" Text="">
                                    <Items>
                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                    </Items>
                                </telerik:RadComboBox>
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="CancellationReasonRadComboBox" ErrorMessage="*" ValidationGroup="cancellationReason" ForeColor="Red" />
                                <%--</fieldset>--%><br />
                                <asp:CheckBox ID="chkReturnToWaitlist" runat="server" Text="Return patient to waitlist?" CssClass="waitlist-cb" />
                                <div style="text-align: center; margin-top: 20px; height: 17px;">
                                    <telerik:RadButton ID="ConfirmDeleteBookingRadButton" runat="server" Text="Accept" Icon-PrimaryIconCssClass="telerikYesButton" ValidationGroup="cancellationReason" OnClick="ConfirmDeleteBookingRadButton_Click" />
                                    <telerik:RadButton ID="CancelConfirmDeleteBookingRadButton" runat="server" Text="Cancel" OnClientClicking="closeRadWindow" Icon-PrimaryIconCssClass="telerikNoButton" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </telerik:RadWindow>
        <telerik:RadWindow ID="DefineTherapeuticProceduresWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="370" CssClass="rad-window-popup">
            <%--this pops up OVER a radwindow, therefore has a different class in order to have a higher z-index--%>
            <ContentTemplate>
                <div>
                    <asp:CheckBox ID="SelectAllCheckBox" runat="server" Text="Select All" />
                    <asp:CheckBoxList ID="TherapeuticTypesCheckBoxList" runat="server" RepeatColumns="2" RepeatDirection="Horizontal"
                        RepeatLayout="Table" CellPadding="5"
                        CellSpacing="5" />
                </div>
                <div id="ButtonsRadPane" runat="server" height="78px">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" />
                </div>
            </ContentTemplate>
        </telerik:RadWindow>
        <telerik:RadWindow ID="SearchAvailableSlotWindow" runat="server" ReloadOnShow="true" AutoSize="true" KeepInScreenBounds="true" CssClass="rad-window" Behaviors="Close">
            <ContentTemplate>
                <asp:ObjectDataSource ID="EndoscopistObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetEndoscopist">
                    <SelectParameters>
                        <asp:ControlParameter Name="IsGIConsultant" ControlID="SearchGIProcedureRadioButtons" PropertyName="SelectedValue" DbType="Boolean" DefaultValue="true" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:HiddenField ID="SearchModeHiddenField" runat="server" />
                <div id="SearchAvailableSlotDiv" runat="server" style="width: 1450px; height: 590px; z-index: 999998; position: absolute;">
                    <telerik:RadNotification ID="SearchWindowRadNotification" runat="server" VisibleOnPageLoad="false" />

                    <telerik:RadNotification ID="ValidateSearchRadNotification" runat="server" Animation="None"
                        EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                        LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                        AutoCloseDelay="70000">
                        <ContentTemplate>
                            <asp:ValidationSummary ID="ValidateSearchValidationSummary" runat="server" ValidationGroup="SlotSearch" DisplayMode="BulletList"
                                EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                        </ContentTemplate>
                    </telerik:RadNotification>

                    <div id="divFilters" runat="server" visible="false">
                        <table style="width: 100%;">
                            <tr id="MoveBookingTR" runat="server" visible="false">
                                <td colspan="3" style="text-align: center;">
                                    <%--<fieldset>--%>
                                    <%--<legend>When this patient is moved...</legend>--%>
                                    <%--<div style="margin-left: 30%;">
                                            <asp:RadioButtonList ID="WhenPatientMovedActionRadioButtonList" runat="server" RepeatDirection="Horizontal">
                                                <asp:ListItem Selected="True">Leave as free slot</asp:ListItem>
                                                <asp:ListItem>Move everyone up in the list</asp:ListItem>
                                            </asp:RadioButtonList>
                                        </div>
                                        <br />--%>
                                        Please enter a reason for the move:
                                        <telerik:RadComboBox ID="ReasonForMoveDropdown" runat="server" DataTextField="Detail" DataValueField="CancelReasonId" ZIndex="9999" AutoPostBack="false" />
                                    <asp:CustomValidator ID="validatorMoveReason" runat="server" ErrorMessage="Please select a reason" Text="*" CssClass="aspxValidator" ValidationGroup="SlotSearch" ValidateEmptyText="true" ClientValidationFunction="validateMoveReason" EnableClientScript="true" Display="None" />

                                    <%--</fieldset>--%>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top" colspan="2">
                                    <fieldset class="search-fieldset">
                                        <legend>Search Criteria</legend>
                                        <div runat="server">
                                            <span>Trust</span>&nbsp;
                                            <telerik:RadComboBox ID="SearchTrustRadComboBox" runat="server" AutoPostBack="true" ZIndex="9999" DataTextField="TrustName" DataValueField="TrustId" />

                                        </div>
                                        <div runat="server">
                                            <span>Operating Hospital</span>&nbsp;
                                            <telerik:RadComboBox ID="SearchOperatingHospitalIdRadComboBox" runat="server" AutoPostBack="false" ZIndex="9999" DataTextField="HospitalName" DataValueField="OperatingHospitalId" CheckBoxes="true" EnableCheckAllItemsCheckBox="true" Localization-CheckAllString="All hospitals" Localization-AllItemsCheckedString="All hospitals" />

                                        </div>


                                        <div style="height: 30px;">
                                            <div style="float: left; padding-top: 5px;">Search for&nbsp;</div>
                                            <div style="float: left;">
                                                <asp:RadioButtonList ID="SearchGIProcedureRadioButtons" runat="server" RepeatDirection="Horizontal" AutoPostBack="true">
                                                    <asp:ListItem Text="GI Procedures" Value="true" Selected="True" />
                                                    <asp:ListItem Text="Non-GI Procedures" Value="false" />
                                                </asp:RadioButtonList>
                                            </div>
                                        </div>
                                        <div>
                                            <asp:Label ID="SearchEndoscopist" runat="server">Endoscopist:</asp:Label>&nbsp;
                                            <telerik:RadComboBox ID="SearchEndoscopistDropdown" runat="server" Style="z-index: 9999;" CheckBoxes="true" EmptyMessage="Any" DataSourceID="EndoscopistObjectDataSource" DataTextField="EndoName" DataValueField="UserID" />

                                            <br />
                                            <asp:RadioButtonList ID="EndoscopistGenderRadioButtonList" runat="server" AutoPostBack="false" RepeatDirection="Horizontal">
                                                <asp:ListItem Text="Any" Selected="true" Value="0" />
                                                <asp:ListItem Value="m" Text="Male" />
                                                <asp:ListItem Value="f" Text="Female" />
                                            </asp:RadioButtonList><br />
                                        </div>
                                        <div>
                                            Referral date:&nbsp;<telerik:RadDatePicker ID="ReferalDateDatePicker" runat="server" MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/3000" ZIndex="7999" DateInput-OnClientDateChanged="setBreachDays" />
                                            &nbsp;
                                            Breach date:&nbsp;<telerik:RadDatePicker ID="BreachDateDatePicker" runat="server" MinDate='<%# DateTime.Now.Date().AddDays(7 * 6) %>' MaxDate="01/01/3000" ZIndex="7999" DateInput-OnClientDateChanged="updateSearchDate" />
                                            <br />
                                            Start searching
                                            <telerik:RadNumericTextBox ID="SearchWeeksBeforeTextBox" runat="server" Value="2"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0" UpdateValueEvent="PropertyChanged" ClientEvents-OnValueChanged="updateSearchDate">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                            weeks before breach date on<telerik:RadDatePicker ID="SearchDateDatePicker" runat="server" MaxDate="01/01/3000" ZIndex="7999" />
                                        </div>
                                        <div>
                                            <div style="float: left; padding-top: 5px;"></div>
                                            <div style="float: left;">
                                                <asp:CheckBox ID="ExcludeTrainingListsCheckBox" runat="server" Text="Exclude training lists" />
                                            </div>
                                        </div>
                                    </fieldset>
                                </td>
                                <td valign="top" rowspan="2">
                                    <fieldset>
                                        <legend>Include these procedures in search</legend>
                                        <asp:CheckBox ID="ShowOnlyReservedSlotsCheckBox" runat="server" Text="Show only reserved slots (guidelines)" />
                                        <br />
                                        <div style="padding: 7px; display: none;">
                                            Length of slot
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
                                                <asp:Repeater ID="rptProcedureTypes" runat="server" DataSourceID="ProcedureTypesObjectDataSource" OnItemDataBound="rptProcedureTypes_ItemDataBound">
                                                    <HeaderTemplate>
                                                        <table cellpadding="4">
                                                            <tr>
                                                                <td>Diagnostic</td>
                                                                <td>Therapeutic</td>
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
                                                <td>Morning</td>
                                                <td>Afternoon</td>
                                                <td>Evening</td>
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
                            <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Skin="Metro" Icon-PrimaryIconCssClass="rbSearch" OnClick="SearchButton_Click" ValidationGroup="SlotSearch" OnClientClicked="validateSearchCriteria" />
                            <telerik:RadButton ID="CancelSearchButton" runat="server" Text="Close" Skin="Metro" OnClientClicking="CloseWindow" OnClick="CancelSearchButton_Click" Icon-PrimaryIconCssClass="telerikCancelButton" AutoPostBack="False" />
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

                        <div style="height: 400px; overflow-y: auto; overflow-x: hidden;">



                            <asp:Repeater ID="AvailableSlotsResultsRepeater" runat="server" OnItemCreated="AvailableSlotsResultsRepeater_ItemCreated">
                                <HeaderTemplate>
                                    <table style="width: 100%;">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            <asp:Label ID="SlotDateLabel" runat="server" Text='<%#Eval("SlotDate") %>' CssClass="divWelcomeMessage" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <telerik:RadGrid ID="SlotsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
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
                                            </telerik:RadContextMenu>
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
                            <telerik:RadPageView ID="WaitlistPageView" runat="server" Height="200px">
                                <telerik:RadGrid ID="WaitListGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                    AllowAutomaticDeletes="True" AutoSizeColumnsMode="Fill" AllowSorting="true" Height="500" Width="1450"
                                    Skin="Metro" GridLines="None" CssClass="WrkGridClass" SelectedItemStyle-CssClass="SelectedGridRowStyle" OnNeedDataSource="WaitListGrid_NeedDataSource" OnItemCommand="WaitListGrid_ItemCommand" OnItemDataBound="WaitListGrid_ItemDataBound">
                                    <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
                                    <CommandItemStyle BackColor="WhiteSmoke" />
                                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="WaitingListId,PatientId" CommandItemDisplay="None" DataKeyNames="WaitingListId,PatientId,ProcedureTypeId,PriorityId,DiagnosticProcedure,TherapeuticProcedure,DateRaised,OrderId,DefaultSchedulerDiagnostic,DefaultSchedulerTherapeutic" TableLayout="Fixed" CssClass="MasterClass"
                                        GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AllowFilteringByColumn="true">
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
                                            <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Hospital number" SortExpression="HospitalNumber" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
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
                                            <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Hospital Number" SortExpression="HospitalNumber" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
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
                        <asp:Button ID="btnSearchSlotFromWorklist" runat="server" OnClick="btnSearchSlotFromWorklist_Click" Style="display: none;"  />
                        <asp:Button ID="btnSearchSlotFromOrder" runat="server" OnClick="btnSearchSlotFromOrder_Click" Style="display: none;"  />
                        <asp:Button ID="btnShowWorklistDetail" runat="server" OnClick="btnShowWorklistDetail_Click" Style="display: none;" />
                        <asp:Button ID="btnShowOrdersDetail" runat="server" OnClick="btnShowOrdersDetail_Click" Style="display: none;" />
                        <asp:Button ID="btnMoveToWorklist" runat="server" OnClick="btnMoveToWorklist_Click" Style="display: none;" />

                        <telerik:RadContextMenu ID="WaitlistRadMenu" runat="server" EnableRoundedCorners="true" EnableOverlay="true" EnableShadows="true" Style="z-index: 999999999999 !important;">
                            <Items>
                                <telerik:RadMenuItem Text="View details" ImageUrl="../Images/icons/notes.png" NavigateUrl="javascript:showWorklistDetail();">
                                </telerik:RadMenuItem>
                                <telerik:RadMenuItem Text="Find available slot" ImageUrl="../Images/icons/select.png" NavigateUrl="javascript:searchSlotFromWaitlist();">
                                </telerik:RadMenuItem>
                            </Items>
                        </telerik:RadContextMenu>
                        <telerik:RadContextMenu ID="OrdersRadMenu" runat="server" EnableRoundedCorners="true" EnableOverlay="true" EnableShadows="true" Style="z-index: 999999999999 !important;">
                            <Items>
                                <telerik:RadMenuItem Text="Add to Waitlist" ImageUrl="../Images/icons/worklist_add.png" NavigateUrl="javascript:MoveToWorklist();">
                                </telerik:RadMenuItem>
                                <telerik:RadMenuItem Text="View details" ImageUrl="../Images/icons/notes.png" NavigateUrl="javascript:showOrdersDetail();">
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
                                                        <td>Hospital number:</td>
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
                                            <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Hospital Number" SortExpression="HospitalNumber" HeaderStyle-Width="110px" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"></telerik:GridBoundColumn>
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
                                                <td>Hospital number:</td>
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
                                    <telerik:RadButton ID="radCloseWaitDetails" runat="server" Text="Close" Skin="Office2007" OnClick="radCloseWaitDetails_Click">
                                    </telerik:RadButton>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </ContentTemplate>
        </telerik:RadWindow>
        <telerik:RadWindow ID="FindExistingBookingRadWindow" runat="server" ReloadOnShow="true" AutoSize="true" KeepInScreenBounds="true" CssClass="rad-window" Width="900">
            <ContentTemplate>
                <telerik:RadNotification ID="RadNotification2" runat="server" VisibleOnPageLoad="false" Style="z-index: 790" Position="TopCenter" />

                <div id="FindExistingBookingDiv" runat="server" style="z-index: 789; width: 750px;">

                    <div class="booking-search-filter" style="padding-top: 5px;">
                        <table cellpadding="2" cellspacing="2">
                            <tr>
                                <td>Hospital number:</td>
                                <td>
                                    <asp:TextBox ID="BookingSearchCNNTextBox" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>NHS Number:</td>
                                <td>
                                    <asp:TextBox ID="BookingSearchNHSNoTextBox" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>Surname:</td>
                                <td>
                                    <asp:TextBox ID="BookingSearchSurnameTextBox" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>Forenames:</td>
                                <td>
                                    <asp:TextBox ID="BookingSearchForenameTextBox" runat="server" /></td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <telerik:RadButton ID="SearchExistingBookingButton" runat="server" Text="Find" OnClick="SearchExistingBookingButton_Click" Skin="Metro" />
                                    &nbsp;
                                    <telerik:RadButton ID="CancelSearchExistingBookingButtonButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicking="closeSearchBookingWindow" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="FoundBookingResults" runat="server" visible="false" style="padding-top: 10px; width: 750px;">
                    <div style="margin-bottom: 10px;">Your search returned more that 1 result. Please choose from the list below</div>
                    <telerik:RadGrid ID="FoundBookingsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                        Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 95%;" OnItemCommand="FoundBookingsRadGrid_ItemCommand">
                        <MasterTableView HeaderStyle-Font-Bold="true" TableLayout="Fixed" ShowHeader="false" CssClass="MasterClass" DataKeyNames="RoomId,StartDateTime,HospitalId">
                            <Columns>
                                <telerik:GridBoundColumn HeaderText="Patient Name" DataField="PatientName" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="175" />
                                <telerik:GridBoundColumn HeaderText="Booking Date" DataField="StartDateTime" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="175" />
                                <telerik:GridBoundColumn HeaderText="Procedure" DataField="ProcedureType" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="120" />
                                <telerik:GridBoundColumn HeaderText="Room" DataField="RoomId" HeaderStyle-Height="0" AllowSorting="false" HeaderStyle-Width="120" />
                                <telerik:GridTemplateColumn>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="SelectPatientLinkButton" runat="server" Text="Select" CommandName="selectBooking" />
                                    </ItemTemplate>
                                </telerik:GridTemplateColumn>
                            </Columns>
                            <HeaderStyle Font-Bold="true" />
                        </MasterTableView>
                    </telerik:RadGrid>
                </div>
            </ContentTemplate>
        </telerik:RadWindow>
        <telerik:RadWindow ID="RadWindow1" runat="server" ReloadOnShow="true" AutoSize="true" KeepInScreenBounds="true" CssClass="rad-window" Width="900">
            <ContentTemplate>
                <telerik:RadNotification ID="RadNotification3" runat="server" VisibleOnPageLoad="false" Style="z-index: 790" Position="TopCenter" />
                <div style="z-index: 789; width: 750px;">
                    <telerik:RadTextBox runat="server" TextMode="MultiLine" />
                    <div class="buttons-div" style="margin-top: 20px;">
                        <telerik:RadButton ID="SaveRadButton" runat="server" Text="Save" />
                        <telerik:RadButton ID="CancelRadButton" runat="server" Text="Cancel" OnClientClicked="CloseDialog" />
                    </div>
                </div>
            </ContentTemplate>
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>

<asp:ObjectDataSource ID="AppointmentsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetDiarySlots">
    <SelectParameters>
        <asp:ControlParameter ControlID="HospitalDropDownList" Name="OperatingHospitalId" PropertyName="SelectedValue" DbType="Int32" />
        <asp:Parameter Name="selectedRoomId" DefaultValue="0" DbType="Int32" />
    </SelectParameters>
</asp:ObjectDataSource>
<asp:SqlDataSource ID="AppointmentsDataSource" runat="server"
    SelectCommand="sch_appointment_slots"
    SelectCommandType="StoredProcedure"></asp:SqlDataSource>

<asp:ObjectDataSource ID="TemplatesObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetTemplatesLst">
    <SelectParameters>
        <asp:Parameter Name="Field" DbType="String" DefaultValue="" />
        <asp:Parameter Name="FieldValue" DbType="String" DefaultValue="" />
        <asp:Parameter Name="Suppressed" DbType="Int32" DefaultValue="0" />
        <asp:Parameter Name="IsGI" DbType="Int32" DefaultValue="-1" />
    </SelectParameters>
</asp:ObjectDataSource>

<asp:ObjectDataSource ID="RoomsDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetRoomsLst">
    <SelectParameters>
        <asp:Parameter Name="OperatingHospitalId" DbType="Int32" />
        <asp:Parameter Name="Field" DbType="String" />
        <asp:Parameter Name="FieldValue" DbType="String" />
        <asp:Parameter Name="Suppressed" DbType="Int32" DefaultValue="0" />
    </SelectParameters>
</asp:ObjectDataSource>

<asp:ObjectDataSource ID="ConsultantDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="LoadConsultantByType">
    <SelectParameters>
        <asp:Parameter Name="consultantType" DbType="String" DefaultValue="1" />
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
<asp:ObjectDataSource ID="BookingProcedureTypesObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetProcedureTypesWithLengths" />
<asp:ObjectDataSource ID="CancellationReasonsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="CancellationReasons" />
