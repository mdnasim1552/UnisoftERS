<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Scheduler.Master" CodeBehind="DiarySchedule.aspx.vb" Inherits="UnisoftERS.DiarySchedule" %>

<%@ Register Src="~/UserControls/CustomDiaryAddEdit.ascx" TagPrefix="scheduler" TagName="AdvancedForm" %>
<%@ Register Src="~/UserControls/AppScheduler.ascx" TagPrefix="scheduler" TagName="AppScheduler" %>


<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title>Add/Edit scheduler templates</title>

    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .link-disabled {
            pointer-events: none;
        }

        .nav-link {
            font-size: 20px !important;
            font-weight: bold !important;
        }

        .RadScheduler .rsAptSimple .rsAptContent {
            margin-top: 0px !important;
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

        .rsMonthView .RadScheduler_Metro .rsHorizontalHeaderTable th {
            border-color: #d5d5d5 !important;
            border-bottom: 3px solid #d3d3d3 !important;
        }

        .header-diary-details table {
            border-spacing: 5px;
        }

            .header-diary-details table tr:not(:last-child) td:first-child {
                font-weight: bold;
            }


        .free-slot:hover {
            /*background-color: blue !important;*/
        }

        .rsSpacerCell, .rsHorizontalHeaderWrapper {
            border-top: 1px solid #e5e5e5 !important;
        }



        .calenderHeaderDiv {
            /*width: 100%;*/
            height: 30px;
            line-height: 25px;
            z-index: 1000;
            border: 1px solid #25a0da;
            color: #fff;
            background-color: #25a0da;
        }


        .diary-calendar input, .diary-calendar td:first-child {
            display: none;
        }

        .calender-view-toggle a, .date-toggle a {
            text-decoration-line: none;
            color: white !important;
        }

        .calender-li {
            width: 0px;
            color: white !important;
        }

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

        .date-toggle .selected-view {
            border-bottom: 1px solid white;
        }

        .rsMonthView .rsAlt td, .rsMonthView .rsHorizontalHeaderTable th, .rsMonthView .rsContentContainerCell {
            border-right: 3px solid #d5d5d5 !important;
        }

        .rsMonthView .rsAptContent {
            font-weight: normal;
            font-size: 8px;
            line-height: 7px;
            text-align: center;
            margin-top: 0px !important;
        }

            .rsMonthView .rsAptContent::first-letter {
                text-transform: uppercase !important;
            }

        .rsDayView .rsAlt td, .rsDayView .rsHorizontalHeaderTable th, .rsDayView .rsContentContainerCell {
            border-right: 1px solid #d5d5d5 !important;
        }


        .rsHorizontalHeaderTable th {
            border-bottom-width: 3px !important;
        }

            .rsHorizontalHeaderTable th div {
                padding: 10px;
            }

        .window-buttons {
            padding-top: 2px;
            padding: 15px;
            position: absolute;
            bottom: 5px;
        }

        .lock-list-div {
            padding: 3px;
            position: absolute;
            right: 0px;
            top: 0px;
        }

        .header-session {
            border-style: solid;
            border-width: 100px;
            border: 1px solid #25a0da;
            padding-top: 10px;
            padding-bottom: 5px;
            text-align: center;
        }

        .header-session-text {
            font-size: 18px;
            font-weight: 900;
        }

        .header-diary-details {
            border-style: solid;
            border-width: 100px;
            border: 1px solid #25a0da;
            margin-top: 2px;
            padding-left: 5px;
            padding-right: 5px;
            padding-top: 5px;
            font-size: 12px;
            <%-- modified by Ferdowsi, TFS 4353--%>
        }

        .tod-div {
            float: left;
            width: 100%;
            padding-right: 10px;
        }

            .tod-div h2 {
                text-align: center;
            }

        .day-notes textarea {
            height: 50px;
            width: 97%;
            margin-top: 2px;
            resize: none;
        }

        .selected-slot {
            border-left: 4px solid blue !important;
            border-right: 4px solid blue !important;
        }

            .selected-slot:first-child {
                border-top: 4px solid blue !important;
            }

            .selected-slot:last-child {
                border-bottom: 4px solid blue !important;
            }

        .free-slot, .patient-booking-slot {
            width: 98.9% !important;
            border: 1px solid black !important;
            padding-left: 0px !important;
            left: 0px !important;
        }

        .overview-slot {
            /*height: 35px !important;*/
        }

        .deleted-template {
            background-color: red;
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

        .rsHeader h2 {
            text-transform: capitalize !important;
            color: white;
        }

        .rsOvertimeArrow {
            display: none !important;
        }

        .rsRecurrenceOptionList label, .rsAdvPatternPanel label, .rsAdvRecurrenceRangePanel label {
            padding-left: 20px !important;
        }

        .hidden-control {
            display: none;
        }
        /* For Classic RenderMode */
        .rsAptDelete {
            display: none;
        }

        .rsApt {
            width: 100% !important;
        }
        /* For Lightweight RenderMode */
        .RadScheduler .rsApt .rsAptDelete {
            display: none;
        }

        .rsEndTimePick {
            display: none;
        }

        body {
            position: fixed;
            top: 0px;
            bottom: 0px;
            left: 0px;
            right: 0px;
        }

        .rsAptResize {
            visibility: hidden !important;
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

        .optionsBodyText {
            margin-left: 10px;
            margin-top: 20px;
        }

            .optionsBodyText div {
                margin-bottom: 5px;
            }

        .search-fieldset div {
            margin-bottom: 5px;
        }
        /*.rsResourceControls { position: absolute; left: 2in; top: 2in; width: 3in; height: 3in; }*/
        /*#DiaryRadScheduler_Form_Description_wrapper {
            visibility:collapse; 
        }*/
        /*.rfbRow {float:left !important ; width:25% !important;
        }
        .riSingle RadInput RadInput_Windows7 RadInputMultiline RadInputMultiline_Windows7{background-color :turquoise !important;width:260px !important;}

        .rsAdvOptionsPanel{float:left !important ;
        }*/
        /*.rfbGroup .rfbRow  table:first-child{background-color :darkseagreen !important;width:100px !important;}*/


        /*.rsAdvContentWrapper{background-color :orange !important;}
        .rsAdvMoreControls .rsAdvOptionsPanel {float: left !important ;
            width:250px !important;
        }
        .rfbGroup .rfbRow{
            width:250px !important; float: left !important ;color:red !important;
        }
        .rfbRow  {float: left !important ;}*/

        /*
        .rfbGroup rsResourceControls .rfbRow {
            float: left !important ;
        }
        .RadComboBox{background-color :turquoise !important;width:260px !important;}
        .rfbLabel {background-color :orange !important;
        }
        #DiaryRadScheduler_Form_LblResList{float:left !important ;background-color :orange !important;
        }
        #DiaryRadScheduler_Form_ResList{float:left !important ;background-color :green !important;
        }
        #DiaryRadScheduler_Form_Description_wrapper { width:100px !important ; float:left ; 
            background-color:red !important ; 
        }

        #DiaryRadScheduler_Form_ResourceControls{display:inline !important;}

        */

        .optionsSubHeading {
            font-size: 14px !important;
            margin-left: 10px;
            font-weight: bold;
        }

            .optionsSubHeading a {
                font-weight: normal;
            }

        .RadWindow .rwWindowContent iframe {
            /*height: 100vh !important;*/
        }

        .RadBoxhidden {
            display: none;
        }

        .RadCheckBox.RadButton .rbText {
            padding: 0 !important
        }

        .rad-window-popup-external {
            width: 90vw !important;
            height: 85vh !important;
            overflow-y:hidden;
            position: fixed;
        }

        iframe[name="ExternalRadWindow"] {
            height: 80vh !important;
        }
        .ChangeRoomsButton{
            margin-bottom:10px;  /*added by Ferdowsi*/
        }
    </style>


    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            var demo = window.demo = window.demo || {};
            var schedulerTemplates = {};


            $(window).on('load', function () {
                $('#<%=ListTextArea.ClientID%>').hide();
            });

            $(document).ready(function () {
                $('.rsDateHeader').addClass('link-disabled').on('click', function (event) {
                    event.preventDefault();
                });

               <%-- document.getElementById("<%= DiaryRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 215) + 'px';
                $(window).resize(function () {
                    document.getElementById("<%= DiaryRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 215) + 'px';
                });--%>
                if (document.getElementById("<%= DiaryOverviewRadScheduler.ClientID%>")) {
                    document.getElementById("<%= DiaryOverviewRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 215) + 'px';
                }

                $(window).resize(function () {
                    if (document.getElementById("<%= DiaryOverviewRadScheduler.ClientID%>")) {
                        document.getElementById("<%= DiaryOverviewRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 215) + 'px';
                    }

                });

                $('#<%=ListNotesTextBox.ClientID%>').on('focusout', function () {
                    saveListNotes();
                });

            });

            function hideShowDatePicker() {
                $find('<%=DiaryDatePicker.ClientID%>').togglePopup();
            }

            function SetSessionAppointment(appointmentId) {
                $.ajax({
                    type: "POST",
                    url: "DiarySchedule.aspx/SetAppointmentId",
                    data: JSON.stringify({ "appointmentId": appointmentId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                    },
                    error: function (jqXHR, textStatus, data) {
                    }
                });
            }

            function setCalendarView(view) {
                $('.calender-view-toggle').closest('li').each(function () {
                    $(this).removeClass("selected-view");
                });

                $(".calender-view-toggle[data-view='" + view + "']").closest('li').addClass('selected-view');
            }

            function showWaitlist() {
                var oWnd = $find("<%=  ExternalRadWindow.ClientID%>");
                oWnd.setUrl('Windows/FindBookSlot.aspx?mode=w&operatinghospitalid=<%=OperatingHospitalID%>');
                if (oWnd != null) {
                    //oWnd.setSize(1450, 700);
                    oWnd.set_title("Book from waitlist");
                    oWnd.show();
                    oWnd.add_close(function () {
                        oWnd.set_title("");
                    });
                }
            }

            function findSlot() {
                var oWnd = $find('<%=ExternalRadWindow.ClientID%>');
                oWnd.setUrl('Windows/FindBookSlot.aspx?mode=s&operatinghospitalid=<%=OperatingHospitalID%>');
                oWnd.setSize(1280, 790);
                oWnd.set_title('Find available slot');
                oWnd.show();
                oWnd.add_close(function () {
                    oWnd.set_title("");
                });
            }

            function moveBooking(appointmentId) {
                var oWnd = $find('<%=ExternalRadWindow.ClientID%>');
                oWnd.setUrl('Windows/FindBookSlot.aspx?mode=m&operatinghospitalid=<%=OperatingHospitalID%>&appointmentid=' + appointmentId);
                oWnd.setSize(1550, 690);
                oWnd.set_title('Find available slot');
                oWnd.show();
                oWnd.add_close(function () {
                    oWnd.set_title("");
                });
            }

            function findBooking() {
                var own = radopen("BookingSearch.aspx", "Find existing booking...");
                own.set_visibleStatusbar(false);
                own.set_behaviors(Telerik.Web.UI.WindowBehaviors.Close);
                own.moveTo(100, 100);
                own.set_title("Search existing booking");
                args.set_cancel(true);
            }


            function bookingSaved() {
                $('#<%= SelectRoomButton.ClientID %>').click();
            }

            function bookingFound() {
                $('#<%= SelectRoomButton.ClientID %>').click();
            }


            function reloadDiary() {
                $('#<%= SelectRoomButton.ClientID %>').click();
            }

            function showLockWindow(locked) {
                var diaryId = parseInt(appointment._id);

                var windowTitle;
                if (locked == "True") {
                    windowTitle = "Unlock list";
                }
                else {
                    windowTitle = "Lock list";
                }

                var oWnd = $find('<%=TemplateRadWindow.ClientID%>');
                oWnd.setUrl("Windows/LockList.aspx?diaryId=" + diaryId + "&locked=" + locked);
                oWnd.setSize(650, 350);
                oWnd.set_title(windowTitle);
                oWnd.show();
                oWnd.add_close(function () {
                    oWnd.set_title("");
                });
                return false;

            }

            function showListLockWindow(locked, listSlotId, slotStart, slotEnd) {
                var windowTitle;
                if (locked == "True") {
                    windowTitle = "Unlock list";
                }
                else {
                    windowTitle = "Lock list";
                }

                var oWnd = $find('<%=TemplateRadWindow.ClientID%>');
                oWnd.setUrl("Windows/LockList.aspx?listSlotId=" + listSlotId + "&locked=" + locked + "&slotstart=" + slotStart + "&slotend=" + slotEnd);
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

            function onKeyUpFunction(sender, eventArgs) {
                errorMsgShowhide("#listTextAreaAlert", "none")
            }

            function closeRadWindow(sender, args) {
                $('.cancellation-confirmation').show();
                var oWnd = $find("<%=PatientDeleteBookingConfirmationWindow.ClientID%>");
                var combo = $find("<%= CancellationReasonRadComboBox.ClientID %>");
                if (combo != null) {
                    combo.clearSelection();
                    if (oWnd != null) {
                        oWnd.close();
                        PrintCancelLetter();
                    }
                }
                if (args != null) {
                    args.set_cancel(true);
                }
            }

            function listCancellWindowClose(sender, args) {
                var oWnd = $find("<%=ListCancellConfirmationWindow.ClientID%>");
                oWnd.close();
                $('.cancellation-confirmation').show();
                $('.cancellation-confirmation-action').hide();
                if (args != null) {
                    args.set_cancel(true);
                }

            }

            function yesCancelBooking(sender, args) {
                $('.cancellation-confirmation').hide();
                $('.cancellation-confirmation-action').show();
                args.set_cancel(true);
            }


            function listCancellationYes() {
                $('.cancellation-confirmation').hide();
                $('.cancellation-confirmation-action').show();
                errorMsgShowhide("#listCancellationAlert", "none")
                $('#<%=ListTextArea.ClientID%>').hide();
                $('#<%=ListTextArea.ClientID%>').val('')
                errorMsgShowhide("#listTextAreaAlert", "none")
                var combo = $find("<%= ListCancellConfirmationComboBox.ClientID %>");
                combo.set_value(0)
                if (combo != null) {
                    combo.clearSelection();
                }
                args.set_cancel(true);
            }


            function ConfirmDeleteScheduleList(sender, args) {
                let cancelReason = $find("<%= ListCancellConfirmationComboBox.ClientID %>").get_text()
                if (cancelReason == "") {
                    errorMsgShowhide("#listCancellationAlert", "")
                    args.set_cancel(true);
                }
                if (cancelReason == 'other') {
                    let textBox = $('#<%=ListTextArea.ClientID%>')
                    if (textBox) {
                        let text = textBox.val()
                        if (text == "") {
                            errorMsgShowhide("#listTextAreaAlert", "")
                            args.set_cancel(true);
                            return
                        }
                    }
                }

            }

            function errorMsgShowhide(id, value) {
                let errorMsg = document.querySelector(id)
                errorMsg.style.display = value
            }

            function cancellationDropdown(sender, args) {
                let text = sender.get_text()
                if (text) {
                    if (text == 'other') {
                        $('#<%=ListTextArea.ClientID%>').show();
                    }
                    else {
                        $('#<%=ListTextArea.ClientID%>').hide();
                    }
                    let errorMsg = document.querySelector("#listCancellationAlert")
                    errorMsg.style.display = "none"
                }


            }

            function saveListNotes() {
                var listNotes = $('#<%=ListNotesTextBox.ClientID%>').val();
                if (appointment != null) {
                    var diaryId = parseInt(appointment._id);
                    var obj = {};
                    obj.diaryId = diaryId;
                    obj.listNotes = listNotes;

                    $.ajax({
                        type: "POST",
                        url: "DiarySchedule.aspx/SaveDiaryNotes",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                        },
                        error: function (jqXHR, textStatus, data) {
                        }
                    });
                }
            }

            function appointmentSaved() {

            }

            function clientFormCreated(scheduler, args) {

                //// Create a client-side object only for the advanced templates

                //var mode = eventArgs.get_mode();
                //if (mode == Telerik.Web.UI.SchedulerFormMode.AdvancedInsert ||
                //    mode == Telerik.Web.UI.SchedulerFormMode.AdvancedEdit) {
                //    // Initialize the client-side object for the advanced form
                //    var formElement = eventArgs.get_formElement();
                //    var templateKey = scheduler.get_id() + "_" + mode;
                //    var advancedTemplate = schedulerTemplates[templateKey];
                //    if (!advancedTemplate) {
                //        // Initialize the template for this RadScheduler instance
                //        // and cache it in the schedulerTemplates dictionary
                //        var schedulerElement = scheduler.get_element();
                //        var isModal = scheduler.get_advancedFormSettings().modal;
                //        advancedTemplate = new SchedulerAdvancedTemplate(schedulerElement, formElement, isModal);
                //        advancedTemplate.initialize();

                //        schedulerTemplates[templateKey] = advancedTemplate;

                //        // Remove the template object from the dictionary on dispose.
                //        scheduler.add_disposing(function () {
                //            schedulerTemplates[templateKey] = null;
                //        });
                //    }

                //    // Are we using Web Service data binding?
                //    if (!scheduler.get_webServiceSettings().get_isEmpty()) {
                //        // Populate the form with the appointment data
                //        var apt = eventArgs.get_appointment();
                //        var apt = eventArgs.get_appointment();
                //        var isInsert = mode == Telerik.Web.UI.SchedulerFormMode.AdvancedInsert;
                //        advancedTemplate.populate(apt, isInsert);
                //    }
                //}
            }


            function validationFunction(source, arguments) {
                if (arguments.Value == '' || arguments.Value == '-') {
                    arguments.IsValid = false;
                }
                else {
                    arguments.IsValid = true;
                }
            }

            function RoomsDropdown_ClientItemChecking(sender, args) {
                var dropdown = $find('<%= RoomsDropdown.ClientID%>');

                //get checked count
                var checkedCount = dropdown.get_checkedItems().length;

                //if >=3 then undo selecction
                if (args.get_item().get_checked() == false && checkedCount >= 3) {
                    args.set_cancel(true);
                    alert('Only 3 rooms can be selected at a time.');
                }
            }


            function OnClientAppointmentMoveStart(sender, eventArgs) {
                eventArgs.set_cancel(true);
            }

            function OnClientAppointmentMoving(sender, eventArgs) {



            }

            function OnClientAppointmentMoveEnd(sender, eventArgs) {
                var listSlotId = eventArgs.get_appointment().get_attributes(0)["getAttribute"]("listSlotId");
                var newStartTime = eventArgs.get_newStartTime();

                //get the diary id that the slots been dragged into.
                //do the adding... but, is there appointments? Do we need to shift slots to match or push stuff down? Can they force a slot to move to a new start time (if not appointment) Can they force a slot time to shirnk (if theres an appointment)
                //attache new slot to dairy.. change the list slot details? add a new one? 
                eventArgs.set_cancel(true);

            }

            function OnClientAppointmentDoubleClick(sender, eventArgs) {
                var isBlocked = appointment.get_attributes(0)["getAttribute"]("locked");
                var listLocked = appointment.get_attributes(0)["getAttribute"]("lockedDiary");

                if (listLocked == "True") {
                    alert('List locked. Changes cannot be made');
                }
                else if (isBlocked == "False") {
                    $('.template-details').hide();

                    appointment = eventArgs.get_appointment();
                    //check if the appointment clicked is possibly an exclusion of an recurring diary 

                    scheduler = sender;

                    var listSlotId = appointment.get_attributes(0)["getAttribute"]("listSlotId");
                    var slotStatusId = appointment.get_attributes(0)["getAttribute"]("statusId");
                    var procedureTypeId = appointment.get_attributes(0)["getAttribute"]("procedureTypeId");
                    var roomId = appointment.get_attributes(0)["getAttribute"]("roomId");
                    var slotLength = appointment.get_attributes(0)["getAttribute"]("slotLength");
                    var slotPoints = appointment.get_attributes(0)["getAttribute"]("slotPoints");
                    var hospitalId = appointment.get_attributes(0)["getAttribute"]("operatingHospitalId");
                    var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");



                    var slotDate = FormatDate(new Date(appointment.get_start()));
                    var diaryId = parseInt(appointment._id);


                    if (appointmentId != undefined) {
                        //edit booking

                        var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
                        oWnd.setUrl("../Scheduler/PatientBooking.aspx?action=edit&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&appointmentId=" + appointmentId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotLength=" + slotLength + "&slotPoints=" + slotPoints);
                        oWnd.set_width("950");
                        oWnd.set_height("600");
                        oWnd.show();
                    }
                    else {
                        //add a new booking
                        var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
                        oWnd.setUrl("PatientBooking.aspx?action=add&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotId=" + slotStatusId + "&slotLength=" + slotLength + "&slotPoints=" + slotPoints + "&listSlotId=" + listSlotId);
                        oWnd.set_width("1050");
                        oWnd.set_height("600");
                        oWnd.show();
                    }

                    eventArgs.set_cancel(true);
                }



            }

            function BookSlot(diaryId, slotDate, roomId, procedureTypeId, slotStatusId, bookingMode, hospitalId, slotLength, slotPoints) {
                var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
                oWnd.setUrl("PatientBooking.aspx?action=" + bookingMode + "&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&slotPoints=" + slotPoints + "&diaryId=" + diaryId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotId=" + slotStatusId + "&slotLength=" + slotLength + "&listSlotId=" + listSlotId);
                oWnd.show();
                closeSlotWindow();
            }

            var appointment;
            var scheduler;
            var editMode;
            var selectedTimeSlot = {};

            var updatingRecurring;


            function showListDetails(diaryId) {

                //load template details and display
                var listName;
                var listStart;
                var listEnd;
                var listConsultant;
                var listEndoscopist;
                var listGender;
                var points;
                var overBookedPoints;
                var notes;
                var appointments = false;
                var appointmentPoints = 0;
                var cancelledAppointments = false;
                var recurring = false;
                var recurrancePattern;

                var obj = {};
                var userId = <%= DataAdapter.LoggedInUserId%>;

                $.ajax({
                    type: "POST",
                    url: "DiarySchedule.aspx/GetDiaryDetails",
                    data: JSON.stringify({ "diaryId": diaryId, "loggedInUserId": userId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var res = JSON.parse(data.d);
                        if (res != null) {
                            $('.template-details').show();
                            //find a way to highlight all the templates in the list

                            listName = res.listName;
                            listStart = res.listStart;
                            listEnd = res.listEnd;
                            listConsultant = res.listConsultant;
                            listEndoscopist = res.listEndoscopist;
                            listGender = res.listGender;
                            points = res.points;
                            overBookedPoints = res.overBookedPoints;
                            notes = res.notes;
                            locked = res.locked;
                            recurring = res.recurring;
                            recurrancePattern = res.recurrancePattern;
                            appointments = res.appointments;
                            appointmentPoints = res.appointmentPoints;
                            blockedPoints = res.blockedPoints;
                            cancelledAppointments = res.cancelledAppointments;
                            listRulesId = res.listRulesId;
                            roomId = res.roomId;
                            endoscopistId = res.endoscopistId;
                            operatingHospitalId = res.operatingHospitalId;
                            listMinutes = res.listMinutes;
                            totalUsedMinutes = res.totalUsedMinutes;

                            if ((totalUsedMinutes >= listMinutes) && res.canOverbook == true) {
                                $('#<%=AddOverBookedSlotLinkButton.ClientID%>').show();
                            }
                            else {
                                $('#<%=AddOverBookedSlotLinkButton.ClientID%>').hide();
                            }
                            suppressed = res.suppressed

                            $(<%=ListTypeLabel.ClientID%>).text(listName);
                            $(<%=ListStartLabel.ClientID%>).text(listStart);
                            $(<%=ListEndLabel.ClientID%>).text(listEnd);
                            $(<%=ListConsultantLabel.ClientID%>).text(listConsultant);
                            $(<%=ListEndoscopistLabel.ClientID%>).text(listEndoscopist);
                            $(<%=GenderTypeLabel.ClientID%>).text((listGender.length > 0) ? '(' + listGender + ')' : '');
                            $(<%=ListPointsLabel.ClientID%>).text((parseFloat(appointmentPoints) + parseInt(blockedPoints)) + ' of ' + points + ' used' + (parseInt(overBookedPoints) > 0 ? ' (' + overBookedPoints + ' over)' : ''));
                            $(<%=ListNotesTextBox.ClientID%>).val(notes);
                            $('#<%=DiaryIdHiddenField.ClientID%>').val(diaryId);
                            $('#<%=ListRulesIdHiddenField.ClientID%>').val(listRulesId);
                            $('#<%=OperatingHospitalIdHiddenField.ClientID%>').val(operatingHospitalId);
                            $('#<%=RoomIdHiddenField.ClientID%>').val(roomId);
                            $('#<%=EndoscopistIdHiddenField.ClientID%>').val(endoscopistId);
                            $('#<%=imgListLock.ClientID%>').data('locked', locked);
                            $('#<%=IsRecurringHiddenField.ClientID%>').val(recurring);
                            $(<%=RecurrencePatternLabel.ClientID%>).text(recurrancePattern);

                            //set lock icon accordingly
                            if (locked == true) {
                                $('#<%=imgListLock.ClientID%>').attr('src', '../../Images/Lock-Lock-48x48.png');
                                //~/Images/Lock-UnLock-48x48.png
                            }
                            else {
                                $('#<%=imgListLock.ClientID%>').attr('src', '../../Images/Lock-UnLock-48x48.png');
                                //~/Images/Lock-Lock-48x48.png
                            }

                            if (appointments == true) {
                                $('#<%=DeleteListLinkButton.ClientID%>').hide();
                            }
                            else {
                                $('#<%=DeleteListLinkButton.ClientID%>').show();
                            }

                            if (cancelledAppointments == true) {
                                $('#AmendedBookingsDiv').show();
                                $('#<%=ShowAmendedBookingsLinkButton.ClientID%>').attr("href", "javascript:void(0);");
                                $('#<%=ShowAmendedBookingsLinkButton.ClientID%>').attr("onclick", "return displayCancelledBookings(" + diaryId + ");");
                            }
                            else {
                                $('#AmendedBookingsDiv').hide();
                                $('#<%=ShowAmendedBookingsLinkButton.ClientID%>').attr("href", "javascript:void(0);");
                                $('#<%=ShowAmendedBookingsLinkButton.ClientID%>').attr("onclick", "return false;");
                            }

                            if (suppressed == true) {
                                $('#<%=DeleteListLinkButton.ClientID%>').hide();
                                $('#<%=CancelledListDivButton.ClientID%>').attr("href", "javascript:void(0);");
                                $('#scheduleCancelledListDiv').show();
                                $('#<%=CancelledListDivButton.ClientID%>').attr("onclick", "return getScheduleList('" + listStart + "');");

                            }
                            else {
                            <%--    $('#<%=CancelledListDivButton.ClientID%>').attr("href", "javascript:void(0);");
                                $('#<%=CancelledListDivButton.ClientID%>').attr("onclick", "return false;");--%>
                                $('#scheduleCancelledListDiv').hide();
                            }


                            $('#<%=ListNotesTextBox.ClientID%>').on('focusout', function () {
                                saveListNotes();
                            });

                            $('#<%=imgListLock.ClientID%>').click(function () {
                                showLockWindow(locked);
                                return false;
                            });

                        }

                    },
                    error: function (jqXHR, textStatus, data) {

                    }
                });


            }

            function OnClientAppointmentClick(sender, args) {
                appointment = args.get_appointment();
                var suppress = appointment.get_attributes().getAttribute("Suppressed")
                scheduler = sender;
                var diaryId = parseInt(appointment._id);
                showListDetails(diaryId);
            }

            function clearClick() {
                var aps = $find('<%=DiaryRadScheduler.ClientID%>').get_appointments();
            }

            function editList() {
                //show addedit page
                var diaryid = $('#<%=DiaryIdHiddenField.ClientID%>').val();
                var roomId = appointment.get_attributes(0)["getAttribute"]("roomId");
                var oWnd = $find('<%=TemplateRadWindow.ClientID%>');
                oWnd.setUrl('Windows/AddEditListTemplate.aspx?mode=edit&operatinghospitalid=' + <%=OperatingHospitalID%> + '&startdate=' + FormatDate(new Date(appointment.get_start())) + '&diaryid=' + diaryid + '&roomid=' + roomId);
                oWnd.setSize(750, 750);
                oWnd.show()


                return false;
            }

            function addOverbookSlot() {
                var diaryId = appointment.get_attributes().getAttribute("diaryId");
                var roomId = appointment.get_attributes().getAttribute("roomId");
                var endoscopistId = appointment.get_attributes().getAttribute("endoscopistId");

                $.ajax({
                    type: "POST",
                    url: "DiarySchedule.aspx/GetDiaryDetails",
                    data: JSON.stringify({ "diaryId": diaryId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var res = JSON.parse(data.d);
                        if (res != null) {
                            $('.template-details').show();
                            listRulesId = res.listRulesId;
                            roomId = res.roomId;
                            endoscopistId = res.endoscopistId;
                            operatingHospitalId = res.operatingHospitalId;

                            $('#<%=ListRulesIdHiddenField.ClientID%>').val(listRulesId);
                            $('#<%=DiaryIdHiddenField.ClientID%>').val(diaryId);
                            $('#<%=RoomIdHiddenField.ClientID%>').val(roomId);
                            $('#<%=EndoscopistIdHiddenField.ClientID%>').val(endoscopistId);
                            $('#<%=OperatingHospitalIdHiddenField.ClientID%>').val(operatingHospitalId);
                        }
                    }
                });

                var oWnd = $find("<%= EditListSlotRadWindow.ClientID %>");
                $('#<%=ModeHiddenField.ClientID%>').val('addslot');

                oWnd.show()
                return false;
            }

            function newslotproceduretype_changed(sender, args) {
                changed_ctrl = sender;
                var proceduretypeid = parseInt(args.get_item().get_value());

                if (proceduretypeid > 0) {
                    var obj = {};
                    obj.procedureTypeId = proceduretypeid;
                    obj.operatingHospitalId = parseInt($('#<%=OperatingHospitalIdHiddenField.ClientID%>').val());
                    obj.isTraining = false;
                    obj.isNonGI = false;
                    obj.isDiagnostic = true;

                    $.ajax({
                        type: "POST",
                        url: "DiarySchedule.aspx/getProcedurePoints",
                        data: JSON.stringify(obj),
                        dataType: "json",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            if (data.d != null) {
                                var res = JSON.parse(data.d);
                                if (res.points > 0)
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-points').val(res.points);
                                else
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-points').val(1);

                                if (res.length > 0)
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-length').val(res.length);
                                else
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-length').val(15);

                            }
                        },
                        error: function (x, y, z) {
                            console.log(x.responseJSON.Message);
                        }
                    });
                }
            }

            function validateProcedureRules(sender, args) {

                var procType = $find('<%=ProcedureTypesComboBox.ClientID%>').get_value();
                var roomId = $('#<%=RoomIdHiddenField.ClientID%>').val();
                var endoscopistId = $('#<%=EndoscopistIdHiddenField.ClientID%>').val();

                var obj = {};
                obj.roomId = parseInt(roomId);
                obj.procedureTypeId = parseInt(procType);
                obj.endoscopistId = parseInt(endoscopistId);

                $.ajax({
                    type: "POST",
                    url: "DiarySchedule.aspx/ValidNewSlot",
                    data: JSON.stringify(obj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        debugger;
                        var res = data.d;
                        if (res != "") {
                            $find('<%=RadNotification1.ClientID%>').set_text(res);
                            $find('<%=RadNotification1.ClientID%>').show();
                        }
                        else {
                            $find("<%=btnSaveAndApply.ClientID%>").click();
                        }
                    }
                });

                args.set_cancel(true);

            }

            function deleteList() {
                var isRecurring = $('#<%=IsRecurringHiddenField.ClientID%>').val();
                var deleteRecurring = false;

                if (proceduretypeid > 0) {
                    var obj = {};
                    obj.procedureTypeId = proceduretypeid;
                    obj.operatingHospitalId = parseInt($('#<%=OperatingHospitalIdHiddenField.ClientID%>').val());
                    obj.isTraining = false;
                    obj.isNonGI = false;
                    obj.isDiagnostic = true;

                    $.ajax({
                        type: "POST",
                        url: "DiarySchedule.aspx/getProcedurePoints",
                        data: JSON.stringify(obj),
                        dataType: "json",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            if (data.d != null) {
                                var res = JSON.parse(data.d);
                                if (res.points > 0)
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-points').val(res.points);
                                else
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-points').val(1);

                                if (res.length > 0)
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-length').val(res.length);
                                else
                                    $('#' + changed_ctrl.get_id()).closest('tr').find('.slot-length').val(15);

                            }
                        },
                        error: function (x, y, z) {
                        }
                    });
                }
            }



            function cancelList(sender, args) {
                var oWnd = $find('<%=ListCancellConfirmationWindow.ClientID%>');
                oWnd.set_title("Schedule list cancel")
                oWnd.show()
                return false;
            }

            function OnClientAppointmentEditing(sender, args) {
                //scheduler = sender;
                //editMode = 'edit';
                //appointment = args.get_appointment();
                //updatingRecurring = args.get_editingRecurringSeries();

                //OnAppointmentCommand();

                //args.set_cancel(true);
            }


            function OnClientAppointmentDeleting(sender, args) {
                //scheduler = sender;
                //editMode = 'delete';
                //appointment = args.get_appointment();
                //updatingRecurring = args.get_editingRecurringSeries();

                //OnAppointmentCommand();

                //args.set_cancel(true);
            }

            function OnClientTimeSlotContextMenu(sender, args) {
                $('.template-details').hide();
                $('#<%=SelectedDateHiddenField.ClientID%>').val(FormatDate(args.get_targetSlot().get_startTime()));
            }


            function visibleMenu(contextMenu, visible, hide) {
                for (var i = 0; i < contextMenu.get_count(); i++) {
                    var item = contextMenu.getItem(i);
                    if (item.get_value() === hide) {
                        item.set_visible(false)
                    }
                    if (item.get_value() === visible) {
                        item.set_visible(true)
                    }
                }
            }

            function OnClientAppointmentContextMenu(sender, args) {
                appointment = args.get_appointment();
                $('#<%=DiaryIdHiddenField.ClientID%>').val(parseInt(appointment._id));

                $('.template-details').hide();
                clickedContextMenu = sender.get_appointmentContextMenus();//[1].get_items().getItem(3);
                clickedappointment = args.get_appointment();
                var contextMenu = $find("<%= DiaryOverviewRadSchedulerContextMenu.ClientID %>");
                if (contextMenu) {
                    // creating new menu item by ferdowsi

                    let value = clickedappointment.get_attributes().getAttribute("Suppressed")

                    let items = contextMenu.get_items()
                    if (value == "True") {
                        visibleMenu(items, 'UndoCancelledList', 'GoToDate')
                    }
                    else {
                        visibleMenu(items, 'GoToDate', 'UndoCancelledList')
                    }
                }

                var slotType = clickedappointment.get_attributes(0)["getAttribute"]("slotType");
                var hospitalId = clickedappointment.get_attributes(0)["getAttribute"]("operatingHospitalId");
                if (slotType != 'OverviewSlot' && clickedappointment.get_attributes(0)["getAttribute"]("lockedDiary") == 'True') {
                    //alert('This list had been locked. Changes cannot be made.');
                    var diaryId = parseInt(clickedappointment.get_attributes(0)["getAttribute"]("diaryId"));
                    showListDetails(diaryId);
                }
                else {
                    if (clickedappointment.get_contextMenuID() == undefined) {
                        if (slotType == "OverviewSlot") {
                            var appointmentId = clickedappointment.get_attributes(0)["getAttribute"]("appointmentId");
                            $('#<%=SelectedDateHiddenField.ClientID%>').val(FormatDate(clickedappointment.get_start()));
                            $('#<%=SelectedApppointmentId.ClientID%>').val(appointmentId);
                        }
                        else if (slotType == "ReservedSlot") {
                            var lockedByUser = clickedappointment.get_attributes(0)["getAttribute"]("lockedByUser");
                            alert('This slot is locked by ' + lockedByUser + '. Booking in progress');
                        }
                    }
                    else if (slotType == "OverviewSlot") {
                        var appointmentId = clickedappointment.get_attributes(0)["getAttribute"]("appointmentId");
                        $('#<%=SelectedApppointmentId.ClientID%>').val(appointmentId);
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
                        var PrintLetterContextMenuItem = clickedContextMenu[2].findItemByValue("PrintLetter");
                        var PrintLetterWithContextMenuItem = clickedContextMenu[2].findItemByValue("WithDocument");
                        var PrintLetterWithoutContextMenuItem = clickedContextMenu[2].findItemByValue("WithoutDocument");

                        //json call to check if letter template is available
                        //hide/show letter print options accordingly

                        var obj = {};
                        obj.operatingHospitalId = parseInt(hospitalId);

                        $.ajax({
                            type: "POST",
                            url: "DiarySchedule.aspx/AppointmentLetterCheck",
                            data: JSON.stringify(obj),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (data) {
                                if (data.d != null) {
                                    if (data.d == true) {
                                        PrintLetterContextMenuItem.set_visible(true);
                                        PrintLetterWithContextMenuItem.set_visible(true);
                                        PrintLetterWithoutContextMenuItem.set_visible(true);
                                    }
                                    else if (data.d == false) {
                                        PrintLetterContextMenuItem.set_visible(false);
                                        PrintLetterWithContextMenuItem.set_visible(false);
                                        PrintLetterWithoutContextMenuItem.set_visible(false);

                                    }
                                }
                            },
                            error: function (jqXHR, textStatus, data) {
                            }
                        });


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
                            url: "DiarySchedule.aspx/slotAvailable",
                            data: JSON.stringify({ "selectedDateTime": clickedappointment.get_start(), "diaryId": diaryId, "userId": userId }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (data) {
                                if (data.d != "") {
                                    alert('This slot is locked by ' + data.d + '. Booking in progress.');
                                    clickedContextMenu[0].findItemByValue("AddBooking").set_visible(false);
                                    clickedContextMenu[0].findItemByValue("PasteBooking").set_visible(false);
                                    clickedContextMenu[0].findItemByValue("EditSlot").set_visible(false);
                                    clickedContextMenu[0].findItemByValue("BlockSlot").set_visible(false);
                                }
                                else {
                                    clickedContextMenu[0].findItemByValue("AddBooking").set_visible(true);
                                    clickedContextMenu[0].findItemByValue("EditSlot").set_visible(true);
                                    clickedContextMenu[0].findItemByValue("BlockSlot").set_visible(true);

                                    $.ajax({
                                        type: "POST",
                                        url: "DiarySchedule.aspx/GetAppointmentId",
                                        contentType: "application/json; charset=utf-8",
                                        dataType: "json",
                                        success: function (data) {
                                            if (data.d > 0) {
                                                clickedContextMenu[0].findItemByValue("PasteBooking").set_visible(true);
                                            }
                                            else {
                                                clickedContextMenu[0].findItemByValue("PasteBooking").set_visible(false);
                                            }
                                        },
                                        error: function (jqXHR, textStatus, data) {
                                        }
                                    });
                                }
                            },
                            error: function (x, y, z) {
                            }
                        });
                    }
                }
            }

            function OnClientAppointmentContextMenuItemClicked(sender, args) {
                $('.template-details').hide();

                var itm = args.get_item();
                appointment = args.get_appointment();
                //check if the appointment clicked is possibly an exclusion of an recurring diary 

                scheduler = sender;

                var listSlotId = appointment.get_attributes(0)["getAttribute"]("listSlotId");
                var slotStatusId = appointment.get_attributes(0)["getAttribute"]("statusId");
                var procedureTypeId = appointment.get_attributes(0)["getAttribute"]("procedureTypeId");
                var roomId = appointment.get_attributes(0)["getAttribute"]("roomId");
                var slotLength = appointment.get_attributes(0)["getAttribute"]("slotLength");
                var slotPoints = appointment.get_attributes(0)["getAttribute"]("slotPoints");
                var hospitalId = appointment.get_attributes(0)["getAttribute"]("operatingHospitalId");
                var slotDate = FormatDate(new Date(appointment.get_start()));
                var diaryId = parseInt(appointment._id);

                if (itm.get_text() == "Add a new booking...") {

                    //var own = radopen("../Scheduler/PatientBooking.aspx?action=add&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotId=" + slotStatusId, "Add new booking...", '950px', '600px');
                    //own.set_visibleStatusbar(false);

                    var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
                    oWnd.setUrl("PatientBooking.aspx?action=add&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotId=" + slotStatusId + "&slotLength=" + slotLength + "&slotPoints=" + slotPoints + "&listSlotId=" + listSlotId);
                    oWnd.set_width("1050");
                    oWnd.set_height("600");
                    oWnd.show();
                }
                else if (itm.get_text() == "Move Booking") {
                    var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");
                    moveBooking(appointmentId);
                }
                else if (itm.get_text() == "Paste Booking") {
                    $.ajax({
                        type: "POST",
                        url: "DiarySchedule.aspx/GetAppointmentId",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            if (data.d > 0) {
                                var appointmentId = parseInt(data.d);
                                var oWnd = $find('<%=PatientBookingRadWindow.ClientID%>');
                                oWnd.setUrl("PatientBooking.aspx?action=paste&appointmentId=" + appointmentId + "&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&roomId=" + roomId + "&slotId=" + slotStatusId + "&slotLength=" + slotLength + "&slotPoints=" + slotPoints + "&listSlotId=" + listSlotId);
                                oWnd.set_width("1050");
                                oWnd.set_height("600");
                                oWnd.show();
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
                    oWnd.setUrl("PatientBooking.aspx?action=edit&hospitalId=" + hospitalId + "&slotDate=" + slotDate + "&diaryId=" + diaryId + "&appointmentId=" + appointmentId + "&roomId=" + roomId + "&procedureTypeId=" + procedureTypeId + "&slotLength=" + slotLength + "&slotPoints=" + slotPoints);
                    oWnd.set_width("1050");
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
                        url: "DiarySchedule.aspx/unmarkPatientAttended",
                        data: JSON.stringify({ "appointmentId": appointmentId }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            //refresh diary
                            $('#<%= SelectRoomButton.ClientID %>').click();
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
                        url: "DiarySchedule.aspx/markPatientAttended",
                        data: JSON.stringify({ "appointmentId": appointmentId }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            //refresh diary
                            $('#<%= SelectRoomButton.ClientID %>').click();
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
                        url: "DiarySchedule.aspx/markPatientDischarged",
                        data: JSON.stringify({ "appointmentId": appointmentId }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            //refresh diary
                            $('#<%= SelectRoomButton.ClientID %>').click();
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

                        var combo = $find("<%= CancellationReasonRadComboBox.ClientID %>");
                        if (combo != null) {
                            combo.clearSelection();
                        }

                        $('.cancellation-confirmation').show();
                        $('.cancellation-confirmation-action').hide();

                        //ajax call to see if appointment was made from the waitlist. show and set checkbox accordingly;
                        var obj = {};
                        obj.appointmentId = parseInt(appointmentId);
                        $.ajax({
                            type: "POST",
                            url: "DiarySchedule.aspx/BookedFromWaitlist",
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
                        url: "DiarySchedule.aspx/markPatientDNA",
                        data: JSON.stringify({ "appointmentId": appointmentId }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            //refresh diary
                            $('#<%= SelectRoomButton.ClientID %>').click();
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
                        url: "DiarySchedule.aspx/updatePatientStatus",
                        data: JSON.stringify({ "appointmentId": appointmentId, "statusCode": statusCode == "B" ? "P" : "B" }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            //refresh diary
                            $('#<%= SelectRoomButton.ClientID %>').click();
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
                        url: "DiarySchedule.aspx/updatePatientStatus",
                        data: JSON.stringify({ "appointmentId": appointmentId, "statusCode": "B" }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            //refresh diary
                            $('#<%= SelectRoomButton.ClientID %>').click();
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
                        url: "DiarySchedule.aspx/updatePatientStatus",
                        data: JSON.stringify({ "appointmentId": appointmentId, "statusCode": "P" }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            //refresh diary
                            $('#<%= SelectRoomButton.ClientID %>').click();
                        },
                        error: function (jqXHR, textStatus, data) {
                            //alert("An error occured while saving your notes");

                        }
                    });
                }
                else if (itm.get_text() == "With Additional Document") {
                    var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");

                    var url = '../Letters/DisplayAndPrintPDF.aspx?AppointmentId=' + appointmentId + '*TRUE'
                    window.open(url, "_blank");
                }
                else if (itm.get_text() == "Without Additional Document") {
                    var appointmentId = appointment.get_attributes(0)["getAttribute"]("appointmentId");

                    var url = '../Letters/DisplayAndPrintPDF.aspx?AppointmentId=' + appointmentId + '*FALSE'
                    window.open(url, "_blank");
                }

                else if (itm.get_value() == "EditSlot") {
                    editMode = "editslot";

                    //bind controls and show edit window
                    var listSlotId = appointment.get_attributes().getAttribute("listSlotId");
                    var statusId = appointment.get_attributes().getAttribute("statusId");
                    var procType = appointment.get_attributes().getAttribute("procedureTypeId");
                    var slotLength = appointment.get_attributes().getAttribute("slotLength");
                    var slotPoints = appointment.get_attributes().getAttribute("slotPoints");
                    var diaryId = appointment.get_attributes().getAttribute("diaryId");
                    var roomId = appointment.get_attributes().getAttribute("roomId");
                    var endoscopistId = appointment.get_attributes().getAttribute("endoscopistId");

                    var oWnd = $find("<%= EditListSlotRadWindow.ClientID %>");
                    $('#<%=ModeHiddenField.ClientID%>').val('editslot');

                    if (oWnd != null) {
                        $find('<%=SlotComboBox.ClientID%>').findItemByValue(statusId).select();
                        $find('<%=ProcedureTypesComboBox.ClientID%>').findItemByValue(procType).select();
                        $find('<%=PointsRadNumericTextBox.ClientID%>').set_value(slotPoints);
                        $find('<%=SlotLengthRadNumericTextBox.ClientID%>').set_value(slotLength);
                        $find('<%=btnSaveAndApply.ClientID%>').set_commandArgument(listSlotId);

                        $('#<%=DiaryIdHiddenField.ClientID%>').val(diaryId);
                        $('#<%=RoomIdHiddenField.ClientID%>').val(roomId);
                        $('#<%=EndoscopistIdHiddenField.ClientID%>').val(endoscopistId);
                        $('#<%=SlotStartHiddenField.ClientID%>').val(FormatDate(appointment.get_start()));

                        oWnd.show();

                        //check if there's an appointment attached to the diary, if so disable the slot length box, otherwise enable it'
                        var obj = {};

                        obj.diaryId = parseInt(diaryId);

                        $.ajax({
                            type: "POST",
                            url: "DiarySchedule.aspx/CheckListForAppointments",
                            data: JSON.stringify(obj),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            async: false,
                            success: function (data) {
                                if (data.d == true) {
                                    $('.edit-slot-length').hide();
                                }
                                else {
                                    $('.edit-slot-length').show();
                                }
                            },
                            error: function (jqXHR, textStatus, data) {
                                autoSaveSuccess = false;
                                //show a message
                                var objError = x.responseJSON;
                                var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                                $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                                $find('<%=RadNotification1.ClientID%>').show();

                            }
                        });
                    }
                }

                else if (itm.get_value() == "BlockSlot") {
                    //show window

                    var listSlotId = appointment.get_attributes().getAttribute("listSlotId");
                    var slotLocked = appointment.get_attributes().getAttribute("locked");
                    var slotStart = FormatDate(appointment.get_start());
                    var slotEnd = FormatDate(appointment.get_end());

                    showListLockWindow(slotLocked, listSlotId, slotStart, slotEnd);


                } else if (itm.get_value() == "UnblockSlot") {
                    //show window
                    var listSlotId = appointment.get_attributes().getAttribute("listSlotId");
                    var slotLocked = appointment.get_attributes().getAttribute("locked");
                    var slotStart = FormatDate(appointment.get_start());
                    var slotEnd = FormatDate(appointment.get_end());

                    showListLockWindow(slotLocked, listSlotId, slotStart, slotEnd);

                }
                else if (itm.get_value() == "MoveTemplate") {
                    confirmTemplateEdit();
                    editMode = "move";
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
            function confirmYes() {
                CloseDialog();
                if (editMode == "edit") {
                    scheduler.editAppointment(appointment, updatingRecurring);
                }
                else if (editMode == "delete") {
                    deleteAppointments();
                }
                else if (editMode == "move") {
                    $('.edit-mode-notification').css("visibility", "visible");

                }
            }

            function deleteAppointments() {
                scheduler.deleteAppointment(appointment, updatingRecurring);
            }

            function confirmTemplateEdit() {
                //ajax call to return a list of appointments related to this template
                var diaryId = appointment.get_id().toString();
                if (diaryId.indexOf("_0") > -1) {
                    diaryId = parseInt(diaryId.replace("_0", ""));
                }

                var selectedDate = new Date(appointment.get_start());
                var startDate = (selectedDate.getMonth() + 1) + '/' + selectedDate.getDate() + '/' + selectedDate.getFullYear();

                $.ajax({
                    type: "POST",
                    url: "DiaryPages.aspx/GetTemplateAppointments",
                    data: JSON.stringify({ "diaryId": diaryId, "startDate": startDate }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (JSON.parse(data.d).length == 0) {
                            confirmYes();
                        }
                        else {
                            if (editMode == "edit") {
                                $('.edit-template-message').show();
                                $('.delete-template-message').hide();
                            }
                            else if (editMode == "delete") {
                                $('.edit-template-message').hide();
                                $('.delete-template-message').show();
                            }
                            else if (editMode == "move") {
                                $('.edit-template-message').hide();
                                $('.delete-template-message').show();
                            }


                            var oWnd = $find("<%= DiaryAppointmentsWindow.ClientID %>");
                            if (oWnd != null) {
                                oWnd.set_title("Confirm " + editMode + " diary");
                                oWnd.show();
                            }
                            //display appointments and ask question
                            var masterTable = $find("<%= DiaryAppointmentsRadGrid.ClientID %>").get_masterTableView();
                            masterTable.set_dataSource(JSON.parse(data.d));
                            masterTable.dataBind();
                        }

                    },
                    error: function (jqXHR, textStatus, data) {
                        alert("Error");

                    }
                });
            }

            function displayCancelledBookings(diaryId) {
                var own = radopen("CancelledBookings.aspx?diaryId=" + diaryId, "Cancelled bookings", '950px', '600px');
                own.set_visibleStatusbar(false);
            }
            function getScheduleList(listStart) {
                var own = radopen("CancelledScheduleList.aspx?DiaryDate=" + listStart, "Schedule Cancel List", '950px', '600px');
                own.show()
                own.set_title("Schedule Cancel List")
                own.set_visibleStatusbar(false);
            }

            function showAddEditListTemplate(selectedSlotTime, roomId) {
                var oWnd = $find('<%=TemplateRadWindow.ClientID%>');
                oWnd.setUrl('Windows/AddEditListTemplate.aspx?mode=new&operatinghospitalid=' + <%=OperatingHospitalID%> + '&startdate=' + selectedSlotTime + '&roomid=' + roomId);
                oWnd.setSize(750, 750);
                //oWnd.add_close(reloadDiary());
                oWnd.show();
            }

            function OnClientTimeSlotContextMenuItemClicked(sender, args) {
                $('.template-details').hide();
                var itm = args.get_item();
                if (itm.get_text().toLowerCase() == 'add template') {
                    var selectedSlot = FormatDate(args.get_slot().get_startTime())
                    var roomId = args.get_slot().get_resource("Room").get_key();
                    var oWnd = $find('<%=TemplateRadWindow.ClientID%>');
                    oWnd.setUrl('Windows/AddEditListTemplate.aspx?mode=new&operatinghospitalid=' + <%=OperatingHospitalID%> + '&startdate=' + selectedSlot + '&roomid=' + roomId);
                    oWnd.setSize(750, 750);
                    //oWnd.add_close(reloadDiary());
                    oWnd.show();
                }

            }

            function OnClientTimeSlotClick(sender, args) {
                $('.template-details').hide();
                if (editMode == 'move') {
                    var templateName = appointment.get_subject();
                    var selectedSlot = args.get_targetSlot();

                    var selectedDate = selectedSlot.get_startTime();

                    selectedTimeSlot.date = (selectedDate.getMonth() + 1) + '/' + selectedDate.getDate() + '/' + selectedDate.getFullYear();

                    selectedTimeSlot.time = selectedSlot.get_startTime().toLocaleTimeString();
                    selectedTimeSlot.room = selectedSlot.get_resource().get_text();

                    var confirmationMsg = "Move <strong>" + templateName + "</strong> to " + selectedTimeSlot.date + " for " + selectedTimeSlot.time.substring(0, 5) + " in <strong>" + selectedTimeSlot.room + "</strong>?";
                    $('#<%=MoveNotificationTextLabel.ClientID%>').html(confirmationMsg);
                    var oWnd = $find("<%= ConfirmMoveDestinationAndTimeRadWindow.ClientID %>");
                    if (oWnd != null) {
                        oWnd.set_title("Confirm move");
                        oWnd.show();
                    }
                }
            }

            function cancelMoveMode() {
                var oWnd = $find("<%= ConfirmMoveDestinationAndTimeRadWindow.ClientID %>");
                if (oWnd != null) {
                    oWnd.close();
                }

                editMode = "";
                $('.edit-mode-notification').css("visibility", "hidden");
                return false;
            }

            function confirmMove() {
                var diaryId = appointment.get_id().toString();

                if (diaryId.indexOf("_0") > -1) {
                    diaryId = parseInt(diaryId.replace("_0", ""));
                }


                $.ajax({
                    type: "POST",
                    url: "DiaryPages.aspx/MoveTemplate",
                    data: JSON.stringify({ "diaryId": diaryId, "newDate": selectedTimeSlot.date, "newTime": selectedTimeSlot.time, "newRoom": selectedTimeSlot.room }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        cancelMoveMode();

                        $find("<%=SelectRoomButton.ClientID%>").click();
                    },
                    error: function (jqXHR, textStatus, data) {
                        alert('error');
                    }
                });
            }

            function declineMove() {
                CloseDialog();
                cancelMoveMode();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow;
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
                return oWindow;
            }

            function CloseDialog() {
                var oWnd = $find("<%= DiaryAppointmentsWindow.ClientID %>");
                if (oWnd != null) {
                    oWnd.close();
                }
            }


        </script>
    </telerik:RadScriptBlock>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <%-- <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />--%>
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Position="Center" Skin="Metro" BorderStyle="Ridge" EnableRoundedCorners="true" ContentIcon="warning" ShowCloseButton="true" />


    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>
    <div class="optionsHeading">
        <asp:Label ID="HeadingLabel" runat="server" Text="Diary Pages Calendar"></asp:Label>
    </div>
    <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
    <div class="optionsBodyText">
        <table style="width: 100%;">
            <tr>
                <td style="width: 525px;">
                    <telerik:RadAjaxPanel runat="server">
                        <table cellspacing="0" style="width: 100%;">
                            <tr>
                                <td>
                                    <div style="float: left; padding-right: 10px" runat="server" id="TrustDiv">
                                        Trust:&nbsp;<telerik:RadDropDownList ID="TrustDropDownList" CssClass="filterDDL" runat="server" Width="200" DataTextField="TrustName" AutoPostBack="true" DataValueField="TrustID" OnSelectedIndexChanged="TrustDropDownList_SelectedIndexChanged" />
                                    </div>
                                </td>
                                <td>
                                    <div style="padding-right: 10px">
                                        Hospital:&nbsp;<telerik:RadDropDownList ID="HospitalDropDownList" CssClass="filterDDL" runat="server" Width="200" DataTextField="HospitalName" AutoPostBack="true" DataValueField="OperatingHospitalID" OnSelectedIndexChanged="HospitalDropDownList_SelectedIndexChanged" />
                                    </div>
                                </td>
                                <td>
                                    <div style="padding-right: 10px">
                                        Room(s):&nbsp;<telerik:RadComboBox ID="RoomsDropdown" CssClass="filterDDL" runat="server" Width="200" CheckBoxes="true" EnableCheckAllItemsCheckBox="false" AllowCustomText="true" DataValueField="RoomId" DataTextField="RoomName" AutoPostBack="false" OnClientItemChecking="RoomsDropdown_ClientItemChecking" OnSelectedIndexChanged="RoomsDropdown_SelectedIndexChanged">
                                            <Localization AllItemsCheckedString="All rooms selected" ItemsCheckedString="room(s) selected" />
                                        </telerik:RadComboBox>
                                        <telerik:RadComboBox ID="WeekViewRoomsDropdown" CssClass="filterDDL" runat="server" Width="200" DataValueField="RoomId" DataTextField="RoomName" AutoPostBack="true" Visible="false">
                                        </telerik:RadComboBox>
                                    </div>
                                </td>
                                 <%-- class added by Ferdowsi--%>
                                 <td style="padding-right: 10px">
                                    <telerik:RadButton ID="SelectRoomButton"   runat="server" Text="Change Rooms" CssClass="filterBtn ChangeRoomsButton"  OnClick="SelectRoomButton_Click" />
                                </td>
                            </tr>
                        </table>
                    </telerik:RadAjaxPanel>
                </td>

                <td style="text-align: right;">
                    <telerik:RadButton ID="BookFromWaitlistRadButton" Style="padding-right: 10px" runat="server" Text="Book from waitlist" OnClientClicked="showWaitlist" AutoPostBack="false" Visible="false" />
                    <telerik:RadButton ID="FindAvailableSlotRadButton" Style="padding-right: 10px" runat="server" Text="Find available slot" OnClientClicked="findSlot" AutoPostBack="false" />
                    <telerik:RadButton ID="FindExistingBookingRadButton" Style="padding-right: 10px" runat="server" Text="Find existing booking" OnClientClicking="findBooking" />
                </td>
            </tr>
        </table>
    </div>
    <div id="FormDiv" runat="server" style="height: 90%;">
        <div class="calenderHeaderDiv rsHeader">
            <div class="date-toggle" style="float: left; margin-bottom: 10px;">
                <ul>
                    <li style="margin-left: 20px;">
                        <asp:LinkButton ID="MonthViewLinkButton" runat="server" OnClick="MonthViewLinkButton_Click" CssClass="calender-view-toggle" data-view="month" OnClientClick="setCalendarView('month')">Month View</asp:LinkButton></li>
                    <li class="head-spacer">|</li>

                    <li style="margin-left: 0px;">
                        <asp:LinkButton ID="DayViewLinkButton" runat="server" OnClick="DayViewLinkButton_Click" CssClass="calender-view-toggle" data-view="day" OnClientClick="setCalendarView('day')">Day View</asp:LinkButton></li>

                    <li style="width: 100px;">&nbsp;</li>


                    <li style="margin-top: 0px;">
                        <asp:LinkButton ID="PreviousDayLinkButton" runat="server" OnClick="PreviousDayLinkButton_Click" CssClass="nav-link">&larr;</asp:LinkButton></li>

                    <li class="calender-li">
                        <telerik:RadDatePicker ID="DiaryDatePicker" runat="server" AutoPostBack="true" CssClass="diary-calendar" Visible="true" Skin="Metro" DatePopupButton-ForeColor="White" Calendar-ForeColor="White" ForeColor="White" OnSelectedDateChanged="DiaryDatePicker_SelectedDateChanged" Style="visibility: hidden;">
                        </telerik:RadDatePicker>
                    </li>

                    <li>
                        <a href="javascript:hideShowDatePicker();">
                            <asp:Label ID="CalendarDateLabel" runat="server" /></a>
                    </li>

                    <li style="margin-top: 0px;">
                        <asp:LinkButton ID="NextDayLinkButton" runat="server" OnClick="NextDayLinkButton_Click" CssClass="nav-link">&rarr;</asp:LinkButton></li>
                    <li></li>
                    <%--<li class="head-spacer">|</li>--%>
                    <li>
                        <asp:LinkButton ID="TodaysDateLinkButton" runat="server" CssClass="jump-to-today-button" OnClick="TodaysDateLinkButton_Click">|&nbsp;&nbsp;go to today</asp:LinkButton>
                    </li>
                    <li style="width: 100px;">&nbsp;</li>

                    <li style="margin-top: 0px;"></li>
                </ul>

            </div>
            <div class="date-toggle" style="float: right; margin-bottom: 10px; margin-right: 15px;">
                <ul>
                    <li style="margin-top: 0px;">
                        <asp:LinkButton ID="lnkZoomOut" Text="Out" runat="server" OnClick="lnkZoomOut_Click" CssClass="nav-link">
-
                        </asp:LinkButton>&nbsp;<asp:Label ID="ZoomLevelLabel" runat="server" Text="100% zoom" />
                        &nbsp;
                        <asp:LinkButton ID="lnkZoomIn" Text="In" runat="server" OnClick="lnkZoomIn_Click" CssClass="nav-link">
+
                        </asp:LinkButton>
                    </li>
                </ul>
            </div>
        </div>
        <asp:HiddenField ID="SelectedApppointmentId" runat="server" />
        <asp:HiddenField ID="SelectedDateHiddenField" runat="server" />
    </div>
    <table style="width: 100%; border-collapse: collapse">
        <tr>
            <td style="width: 16%; vertical-align: top; border-right: 2px solid #25a0da; padding: 0px;">    <%-- width added by Ferdowsi, TFS 4353--%>
                <div style="position: relative; width: 225px">
                    <div class="template-details" style="display: none; margin: 1px 0px 0px 10px; position: fixed; width: 15% ">    <%-- width added by Ferdowsi, TFS 4353--%>

                        <div style="position: relative;" class="header-session">
                            <div class="lock-list-div">
                                <asp:ImageButton ID="imgListLock" runat="server" ImageUrl="~/Images/Lock-UnLock-48x48.png" Width="20" />
                            </div>
                            <span>
                                <asp:Label ID="ListTypeLabel" runat="server" Text="List Name" CssClass="header-session-text" /></span>&nbsp;<small><asp:Label ID="GenderTypeLabel" Font-Size="12px" runat="server" /></small><br />
                            <%--  added by Ferdowsi, TFS 4353--%>
                            <asp:Label ID="RecurrencePatternLabel" runat="server" Text="" Font-Size="14px" /><br />
                         
                            <asp:LinkButton ID="EditListLinkButton" runat="server" Text="Edit list details" Font-Size="14px" OnClientClick="return editList()" />
                           
                            <asp:LinkButton ID="AddOverBookedSlotLinkButton" runat="server" Text="Add slot (overbook)" Font-Size="14px" OnClientClick="return addOverbookSlot()" />
                          

                            <asp:LinkButton ID="DeleteListLinkButton" runat="server" Text="Cancel list" Font-Size="14px" OnClientClick="return cancelList() " />
                            <%--  modified by Ferdowsi end, TFS 4353--%>
                            <asp:HiddenField ID="DiaryIdHiddenField" runat="server" />
                            <asp:HiddenField ID="OperatingHospitalIdHiddenField" runat="server" />
                            <asp:HiddenField ID="ListRulesIdHiddenField" runat="server" />
                            <asp:HiddenField ID="RoomIdHiddenField" runat="server" />
                            <asp:HiddenField ID="EndoscopistIdHiddenField" runat="server" />
                            <asp:HiddenField ID="IsRecurringHiddenField" runat="server" />
                        </div>
                        <div class="header-diary-details">
                            <table>
                                <tr>
                                    <td>List Consultant:</td>
                                    <td>&nbsp;<asp:Label ID="ListConsultantLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Endoscopist:</td>
                                    <td>&nbsp;<asp:Label ID="ListEndoscopistLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>List Start:</td>
                                    <td>&nbsp;<asp:Label ID="ListStartLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>List End:</td>
                                    <td>&nbsp;<asp:Label ID="ListEndLabel" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Points:</td>
                                    <td>&nbsp;<asp:Label ID="ListPointsLabel" runat="server" /></td>
                                </tr>
                                <tr id="AmendedBookingsDiv">
                                    <td colspan="2" style="padding-top: 15px;">Patients cancelled&nbsp;<asp:LinkButton ID="ShowAmendedBookingsLinkButton" runat="server" Text="View" /></td>
                                </tr>
                                <tr id="scheduleCancelledListDiv">
                                    <td colspan="2" style="padding-top: 5px; font-weight: bold;">List cancelled&nbsp;<asp:LinkButton ID="CancelledListDivButton" runat="server" Text="View" /></td>
                                </tr>
                            </table>
                            <div id="AmendedBookingsDiv1" style="padding-top: 20px; float: right; display: none;">
                                <span></span>&nbsp;
                                
                            </div>
                        </div>
                        <div class="day-notes">
                            <b>
                                <asp:TextBox ID="ListNotesTextBox" runat="server" TextMode="MultiLine" placeholder="Notes:" CssClass="notes-textbox" Height="200" />&nbsp;</b>
                        </div>
                    </div>
                </div>
            </td>
            <td   >
                <%--<div class="zoom">
                        <div style="padding-left: 85px; font-size: 10px;">Zoom</div>
                        <telerik:RadSlider ID="DiaryZoomRadSlider" runat="server" ItemType="Item" Skin="Metro" ThumbsInteractionMode="Free" Value="1" TrackPosition="TopLeft" Height="40px" AutoPostBack="true"
                            OnValueChanged="DiaryZoomRadSlider_ValueChanged" Enabled="false">
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
                    </div>--%>
                <telerik:RadScheduler runat="server" ID="DiaryRadScheduler" DataEndField="DiaryEnd" Height="95%"
                    DataKeyField="DiaryID" AgendaView-UserSelectable="true" CssClass="diary-scheduler"
                    StartEditingInAdvancedForm="false" StartInsertingInAdvancedForm="false" AppointmentStyleMode="Auto"
                    EnableAdvancedForm="false"
                    OnFormCreating="DiaryRadScheduler_FormCreating"
                    EnableDescriptionField="false" ShowAllDayRow="false"
                    DataDescriptionField="Description" GroupBy="Room" GroupingDirection="Horizontal" OverflowBehavior="Expand"
                    Localization-AdvancedSubjectRequired="False" OnClientFormCreated="clientFormCreated"
                    EnableResourceEditing="true" ShowHeader="false" ShowFooter="false" DayStartTime="08:00" DayEndTime="21:59" MinutesPerRow="15" DayView-EnableExactTimeRendering="true"
                    DataStartField="DiaryStart" DataSubjectField="Subject" Skin="Metro" RenderMode="Classic" DayView-DayStartTime="07:30" DayView-DayEndTime="21:59"
                    OnClientAppointmentContextMenu="OnClientAppointmentContextMenu"
                    OnClientAppointmentContextMenuItemClicked="OnClientAppointmentContextMenuItemClicked"
                    OnClientAppointmentMoveStart="OnClientAppointmentMoveStart"
                    OnClientAppointmentMoving="OnClientAppointmentMoving"
                    OnClientAppointmentMoveEnd="OnClientAppointmentMoveEnd"
                    OnClientAppointmentDoubleClick="OnClientAppointmentDoubleClick"
                    OnOccurrenceDelete="DiaryRadScheduler_OccurrenceDelete"
                    OnClientAppointmentDeleting="OnClientAppointmentDeleting"
                    OnClientAppointmentEditing="OnClientAppointmentEditing"
                    OnClientAppointmentClick="OnClientAppointmentClick"
                    OnNavigationComplete="DiaryRadScheduler_NavigationComplete"
                    OnAppointmentInsert="DiaryRadScheduler_AppointmentInserted"
                    OnAppointmentCreated="DiaryRadScheduler_AppointmentCreated"
                    OnClientTimeSlotClick="OnClientTimeSlotClick"
                    OnClientTimeSlotContextMenuItemClicked="OnClientTimeSlotContextMenuItemClicked"
                    AllowEdit="true" EditFormDateFormat="dd/MM/yyyy" EnableViewState="true">
                    <AdvancedForm Modal="true" />
                    <DayView HeaderDateFormat="dddd, dd MMMM yyyy"></DayView>
                    <TimelineView UserSelectable="false" GroupBy="Room" GroupingDirection="Vertical" HeaderDateFormat="dd MMM yyyy" ColumnHeaderDateFormat="dd/MM/yyyy"></TimelineView>
                    <WeekView HeaderDateFormat="dd MMM yyyy" EnableExactTimeRendering="true" DayStartTime="08:00" DayEndTime="21:59" />
                    <AgendaView UserSelectable="false" HeaderDateFormat="dd MMM yyyy" />
                    <MonthView UserSelectable="false" />
                    <TimeSlotContextMenus>
                        <telerik:RadSchedulerContextMenu runat="server" ID="SlotContextMenu">
                            <Items>
                                <telerik:RadMenuItem Text="Add template" Value="addtemplate" />
                                <%--<telerik:RadMenuItem Text="Add template" Value="CommandAddAppointment" />--%>
                            </Items>
                        </telerik:RadSchedulerContextMenu>
                    </TimeSlotContextMenus>
                    <AppointmentContextMenus>

                        <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerAppointmentContextMenu">
                            <Items>
                                <telerik:RadMenuItem Text="Add a new booking..." Value="AddBooking" ImageUrl="/images/icons/add.png">
                                </telerik:RadMenuItem>
                                <telerik:RadMenuItem Text="Edit slot" Value="EditSlot"></telerik:RadMenuItem>
                                <telerik:RadMenuItem Text="Block slot" Value="BlockSlot"></telerik:RadMenuItem>
                                <telerik:RadMenuItem Text="Paste Booking" Value="PasteBooking"></telerik:RadMenuItem>
                            </Items>
                        </telerik:RadSchedulerContextMenu>
                        <telerik:RadSchedulerContextMenu runat="server" ID="BlockedSlotContextMenu">
                            <Items>
                                <telerik:RadMenuItem Text="Unblockslot" Value="UnblockSlot"></telerik:RadMenuItem>
                            </Items>
                        </telerik:RadSchedulerContextMenu>
                        <telerik:RadSchedulerContextMenu runat="server" ID="SchedulerBookingContextMenu">
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
                        <telerik:RadSchedulerContextMenu runat="server" ID="DiaryPageContextMenu">
                            <Items>
                                <telerik:RadMenuItem Text="Edit template" Value="CommandEdit" Enabled="true" />
                                <telerik:RadMenuItem Text="Delete template" Value="CommandDelete" />
                                <telerik:RadMenuItem Text="Move template" Value="MoveTemplate" Visible="false" />
                            </Items>
                        </telerik:RadSchedulerContextMenu>

                        <telerik:RadSchedulerContextMenu runat="server" ID="LockedDiaryContextMenu">
                            <Items>
                                <telerik:RadMenuItem Text="List locked. Changes cannot be made"></telerik:RadMenuItem>
                            </Items>
                        </telerik:RadSchedulerContextMenu>
                    </AppointmentContextMenus>
                    <ResourceTypes>
                        <%-- <telerik:ResourceType DataSourceID="AppointmentsDataSource" ForeignKeyField="DiaryId"
                            KeyField="DiaryId" Name="DiaryTemplate" TextField="Subject" />--%>
                        <telerik:ResourceType DataSourceID="RoomsDataSource" ForeignKeyField="RoomID"
                            KeyField="RoomId" Name="Room" TextField="RoomName" />
                        <telerik:ResourceType DataSourceID="TemplatesObjectDataSource" ForeignKeyField="ListRulesId"
                            KeyField="ListRulesId" Name="Template" TextField="ListName" />
                        <telerik:ResourceType DataSourceID="ConsultantDataSource" ForeignKeyField="UserID"
                            KeyField="UserID" Name="Endoscopist" TextField="EndoName" />
                    </ResourceTypes>
                    <AppointmentTemplate>
                        <div style="font-weight: bold; float: left;">
                            <table border="0">
                                <tr style="border: none !important;">
                                    <td style="border: none !important;">
                                        <span style="font-weight: bold;" runat="server" id="SubjectToolTip"><%# Eval("Subject") %></span>
                                    </td>
                                    <td style="border: none !important;">
                                        <telerik:RadToolTip ID="RadSubjectToolTip" Visible="false" runat="server" TargetControlID="SubjectToolTip" Text="Notes:" />
                                    </td>
                                </tr>
                            </table>

                        </div>
                        <div class="tooltip-icons" style="float: right;">
                            <table border="0">
                                <tr>
                                    <td>
                                        <img id="AppointmentNotesToolTipImage" runat="server" src="../../Images/icons/alert.png" visible="false" /></td>
                                    <td>
                                        <telerik:RadToolTip ID="AppointmentNotesToolTip" Visible="false" runat="server" TargetControlID="AppointmentNotesTooltipImage" Text="Notes:" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="tooltip-icons" style="float: right;">
                            <table border="0">
                                <tr>
                                    <td>
                                        <img id="AppointmentGeneralInfoToolTipImage" runat="server" src="../../Images/alert_round.png" visible="false" /></td>
                                    <td>
                                        <telerik:RadToolTip ID="AppointmentGeneralInfoToolTip" Visible="false" runat="server" TargetControlID="AppointmentGeneralInfoToolTipImage" Text="General information:" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </AppointmentTemplate>
                    <Localization AdvancedEditAppointment="Edit list details" AdvancedNewAppointment="Set lists"
                        ConfirmDeleteText="Are you sure you want to delete this list?"
                        AllDay="" AdvancedEndDateRequired="false" AdvancedEndTimeRequired="false"
                        HeaderAgendaAppointment="Worklist" HeaderAgendaResource="Room name" AdvancedSubject="" />
                </telerik:RadScheduler>

                <telerik:RadScheduler ID="DiaryOverviewRadScheduler" runat="server" Height="95%" AppointmentStyleMode="Simple"
                    DataKeyField="DiaryId" AgendaView-UserSelectable="true" CssClass="Overview-Scheduler"
                    StartEditingInAdvancedForm="true" StartInsertingInAdvancedForm="true" RenderMode="Classic"
                    EnableDescriptionField="false"
                    DataDescriptionField="Description" GroupBy="Room" GroupingDirection="Horizontal" OverflowBehavior="Scroll"
                    Localization-AdvancedSubjectRequired="False" EnableExactTimeRendering="true" HoursPanelTimeFormat="HH:mm" MinutesPerRow="5"
                    MonthView-AdaptiveRowHeight="false" ShowFullTime="true" DayEndTime="21:59" ShowHeader="false" ShowFooter="false"
                    DataStartField="DiaryStart" DataEndField="DiaryEnd" DataSubjectField="Subject" Skin="Metro"
                    AllowEdit="false"
                    AllowInsert="false"
                    EnableViewState="false"
                    OnClientAppointmentContextMenu="OnClientAppointmentContextMenu"
                    OnClientAppointmentClick="OnClientAppointmentClick"
                    OnClientAppointmentMoveStart="OnClientAppointmentMoveStart"
                    OnClientTimeSlotClick="OnClientTimeSlotClick"
                    OnClientTimeSlotContextMenu="OnClientTimeSlotContextMenu"
                    OnClientTimeSlotContextMenuItemClicked="OnClientTimeSlotContextMenuItemClicked"
                    OnTimeSlotContextMenuItemClicked="DiaryOverviewRadScheduler_TimeSlotContextMenuItemClicked"
                    OnAppointmentDataBound="DiaryOverviewRadScheduler_AppointmentDataBound"
                    OnAppointmentCreated="DiaryOverviewRadScheduler_AppointmentCreated"
                    OnAppointmentContextMenuItemClicked="DiaryOverviewRadScheduler_AppointmentContextMenuItemClicked">
                    <MonthView ShowDateHeaders="true" VisibleAppointmentsPerDay="10" />
                    <AdvancedForm Modal="true" />
                    <TimeSlotContextMenus>
                        <telerik:RadSchedulerContextMenu runat="server" ID="OverviewSlotRadSchedulerContextMenu">
                            <Items>
                                <telerik:RadMenuItem Text="Add template" />
                            </Items>
                        </telerik:RadSchedulerContextMenu>
                    </TimeSlotContextMenus>
                    <AppointmentContextMenus>
                        <telerik:RadSchedulerContextMenu runat="server" ID="DiaryOverviewRadSchedulerContextMenu">
                            <Items>
                                <telerik:RadMenuItem Text="Go to date" Value="GoToDate" runat="server"></telerik:RadMenuItem>
                                <telerik:RadMenuItem Text="Undo Cancelled List" Value="UndoCancelledList" runat="server"></telerik:RadMenuItem>
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
                            <div style="font-size: 9px; margin-top: 4px;">
                                <%-- style added by Ferdowsi, TFS 4353--%>
                                <%#Eval("Description") %>
                            </div>
                        </div>
                    </AppointmentTemplate>
                </telerik:RadScheduler>

                <asp:SqlDataSource ID="AppointmentsDataSource" runat="server"
                    SelectCommand="sch_diary_page_select"
                    SelectCommandType="StoredProcedure"
                    InsertCommand="sch_diary_page_add" OnInserted="AppointmentsDataSource_Inserted"
                    InsertCommandType="StoredProcedure"
                    UpdateCommand="sch_diary_page_update"
                    UpdateCommandType="StoredProcedure"
                    DeleteCommand="sch_diary_page_delete"
                    DeleteCommandType="StoredProcedure">
                    <SelectParameters>
                        <asp:Parameter Name="DiaryDate" Type="DateTime" />
                    </SelectParameters>
                    <DeleteParameters>
                        <asp:Parameter Name="DiaryId" Type="Int32"></asp:Parameter>
                    </DeleteParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Subject" Type="String" ConvertEmptyStringToNull="false"></asp:Parameter>
                        <asp:Parameter Name="DiaryStart" Type="DateTime"></asp:Parameter>
                        <asp:Parameter Name="DiaryEnd" Type="DateTime"></asp:Parameter>
                        <asp:Parameter Name="RoomID" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="UserID" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="RecurrenceRule" Type="String"></asp:Parameter>
                        <asp:Parameter Name="RecurrenceParentID" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="ListRulesId" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="DiaryId" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="Description" Type="String"></asp:Parameter>
                        <asp:Parameter Name="LoggedInUserId" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="Training" Type="Boolean"></asp:Parameter>
                        <asp:Parameter Name="ListConsultant" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="ListGenderId" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="Notes" Type="String"></asp:Parameter>
                        <asp:Parameter Name="IsGI" Type="Boolean"></asp:Parameter>
                        <asp:ControlParameter Name="OperatingHospitalId" Type="Int32" ControlID="HospitalDropDownList" PropertyName="SelectedValue" />
                    </UpdateParameters>
                    <InsertParameters>
                        <asp:Parameter Name="Subject" Type="String"></asp:Parameter>
                        <asp:Parameter Name="DiaryStart" Type="DateTime"></asp:Parameter>
                        <asp:Parameter Name="DiaryEnd" Type="DateTime"></asp:Parameter>
                        <asp:Parameter Name="RoomID" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="UserID" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="RecurrenceRule" Type="String"></asp:Parameter>
                        <asp:Parameter Name="RecurrenceParentID" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="ListRulesId" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="Description" Type="String"></asp:Parameter>
                        <asp:ControlParameter Name="OperatingHospitalId" Type="Int32" ControlID="HospitalDropDownList" PropertyName="SelectedValue" />
                        <asp:Parameter Name="LoggedInUserId" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="ListConsultant" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="Training" Type="Boolean"></asp:Parameter>
                        <asp:Parameter Name="ListGenderId" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="IsGI" Type="Boolean"></asp:Parameter>
                    </InsertParameters>
                </asp:SqlDataSource>


                <div class="edit-mode-notification" style="text-align: center; visibility: hidden;">
                    <div class="optionsSubHeading">
                        <span>Select the time, room and date you wish to move your diary template to...
                        </span>
                        <asp:LinkButton ID="CancelMoveLinkButton" runat="server" Text="cancel move" OnClientClick="javascript: return cancelMoveMode()" />
                    </div>
                </div>
            </td>
        </tr>
    </table>
    </div>
    <asp:ObjectDataSource ID="TemplatesObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetTemplatesLst">
        <SelectParameters>
            <asp:Parameter Name="Field" DbType="String" DefaultValue="" />
            <asp:Parameter Name="FieldValue" DbType="String" DefaultValue="" />
            <asp:Parameter Name="Suppressed" DbType="Int32" DefaultValue="1" />
            <asp:Parameter Name="IsGI" DbType="Int32" DefaultValue="-1" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="RoomsDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetRoomsLst">
        <SelectParameters>
            <asp:ControlParameter Name="OperatingHospitalId" ControlID="HospitalDropDownList" PropertyName="SelectedValue" DbType="Int32" />
            <asp:Parameter Name="Field" DbType="String" />
            <asp:Parameter Name="FieldValue" DbType="String" />
            <asp:Parameter Name="Suppressed" DbType="Int32" DefaultValue="0" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="ConsultantDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetEndoscopist" />

    <asp:ObjectDataSource ID="TrustObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSchedulerTrusts" />
    <asp:ObjectDataSource ID="HospitalObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSchedulerHospitals" />
    <asp:ObjectDataSource ID="HospitalRoomsDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetHospitalRooms">
        <SelectParameters>
            <asp:ControlParameter ControlID="HospitalDropDownList" DbType="Int32" Name="HospitalID" PropertyName="SelectedValue" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <telerik:RadWindowManager ID="DiaryPagesRadWindowManager" runat="server" ShowContentDuringLoad="false"
        Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
        <Windows>
            <telerik:RadWindow ID="PatientBookingRadWindow" runat="server" Height="600" Width="1050" AutoSize="false" CssClass="rad-window-popup" VisibleStatusbar="false" />

            <telerik:RadWindow ID="EditListSlotRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="650" Height="130" Title="Edit list slot" VisibleStatusbar="false" Modal="True">
                <ContentTemplate>
                    <asp:HiddenField ID="ModeHiddenField" runat="server" />
                    <div style="padding: 5px;">
                        <asp:HiddenField ID="SlotStartHiddenField" runat="server" />
                        <table width="100%">
                            <tr>
                                <td colspan="5">
                                    <asp:RadioButtonList ID="GIProcedureRBL" runat="server" RepeatDirection="Horizontal" CssClass="FormatRBL" Width="200" AutoPostBack="false" Visible="false">
                                        <asp:ListItem Text="Endoscopic" Value="1" Selected="True" />
                                        <asp:ListItem Text="Other" Value="0" />
                                    </asp:RadioButtonList></td>
                            </tr>
                            <tr>
                                <td>Slot type</td>
                                <td>Procedure</td>
                                <td>Points</td>
                                <td class="edit-slot-length">Slot length</td>
                                <td></td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadComboBox ID="SlotComboBox" runat="server" DataSourceID="SlotStatusObjectDataSource" DataTextField="Description" DataValueField="StatusId" ZIndex="9999" />
                                </td>
                                <td>
                                    <telerik:RadComboBox ID="ProcedureTypesComboBox" AutoPostBack="false" runat="server" DataSourceID="GuidelineObjectDataSource" DataTextField="SchedulerProcName" DataValueField="ProcedureTypeId" ZIndex="99999" OnClientSelectedIndexChanged="newslotproceduretype_changed" />
                                </td>
                                <td>
                                    <telerik:RadNumericTextBox ID="PointsRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false" CssClass="slot-points"
                                        IncrementSettings-Step="0.5" Width="35px"
                                        MinValue="0.5" MaxLength="3" MaxValue="1440" Value="1"
                                        AutoPostBack="false">
                                        <NumberFormat DecimalDigits="1" />
                                    </telerik:RadNumericTextBox></td>
                                <td class="edit-slot-length">
                                    <telerik:RadNumericTextBox ID="SlotLengthRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false" CssClass="slot-length"
                                        IncrementSettings-Step="1" Width="35px"
                                        MinValue="1" MaxLength="3" MaxValue="1440">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox></td>
                                <td>

                                    <telerik:RadNumericTextBox ID="SlotQtyRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1" Width="35px"
                                        MinValue="1" MaxLength="3" MaxValue="1440" Value="1" Visible="false">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox></td>
                                <td>
                                    <telerik:RadButton ID="btnSaveAndApply" runat="server" Text="Update" OnClientClicking="validateProcedureRules" OnClick="btnSaveAndApply_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>

                    <asp:ObjectDataSource ID="SlotStatusObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSlotStatus">
                        <SelectParameters>
                            <asp:Parameter Name="GI" DbType="Byte" DefaultValue="1" />
                            <asp:Parameter Name="nonGI" DbType="Byte" DefaultValue="1" />
                        </SelectParameters>
                    </asp:ObjectDataSource>

                    <asp:ObjectDataSource ID="GuidelineObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetGuidelines">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="GIProcedureRBL" Name="IsGI" Type="Byte" PropertyName="SelectedValue" />
                            <asp:ControlParameter ControlID="HospitalDropDownList" Name="operatingHospital" Type="string" PropertyName="SelectedValue" />
                        </SelectParameters>

                    </asp:ObjectDataSource>
                </ContentTemplate>
            </telerik:RadWindow>

            <telerik:RadWindow ID="DiaryAppointmentsWindow" runat="server" Height="350" Width="600" CssClass="rad-window">
                <ContentTemplate>
                    <div style="height: 270px; overflow: hidden; text-align: center;">
                        <p class="edit-template-message" style="display: none;">This diary has the following appointments scheduled. Only the consultants may be changed.</p>
                        <p class="delete-template-message" style="display: none;">This diary has the following appointments attached. Before making these changes to this diary template please amend the following appointments</p>
                        <p class="move-template-message" style="display: none;">This diary has the following appointments attached. Before making these changes to this diary template please amend the following appointments</p>

                        <telerik:RadGrid ID="DiaryAppointmentsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                            Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px; width: 95%; height: 130px" ClientSettings-Scrolling-AllowScroll="true">
                            <MasterTableView HeaderStyle-Font-Bold="true" TableLayout="Fixed" CssClass="MasterClass">
                                <Columns>
                                    <telerik:GridBoundColumn HeaderText="Appointment Date" DataField="appointmentDate" AllowSorting="false" />
                                    <telerik:GridBoundColumn HeaderText="Patient" DataField="patientName" AllowSorting="false" />
                                    <telerik:GridBoundColumn HeaderText="Procedure" DataField="appointmentProcedureDetails" AllowSorting="false" />
                                </Columns>
                                <HeaderStyle Font-Bold="true" />
                            </MasterTableView>
                        </telerik:RadGrid>
                        <p>Do you still wish to continue?</p>
                        <div class="buttons-div" style="margin-top: 20px;">
                            <div class="edit-template-message">
                                <telerik:RadButton ID="SaveRadButton" runat="server" Text="Yes" AutoPostBack="false" OnClientClicked="confirmYes" />
                                <telerik:RadButton ID="CancelRadButton" runat="server" Text="No" OnClientClicked="declineMove" AutoPostBack="false" />
                            </div>
                            <div class="delete-template-message">
                                <telerik:RadButton ID="OkRadButton" runat="server" Text="OK" OnClientClicked="declineMove" AutoPostBack="false" />
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>
            <telerik:RadWindow ID="ConfirmMoveDestinationAndTimeRadWindow" runat="server" Height="180" Width="400" CssClass="rad-window">
                <ContentTemplate>
                    <div>
                        <p>
                            <asp:Label ID="MoveNotificationTextLabel" runat="server" />
                        </p>
                    </div>
                    <div class="buttons-div" style="margin-top: 20px; text-align: center;">
                        <telerik:RadButton ID="YesMoveRadButton" runat="server" Text="Yes" AutoPostBack="false" OnClientClicked="confirmMove" />
                        <telerik:RadButton ID="NoMoveRadButton" runat="server" Text="No" OnClientClicked="CloseDialog" AutoPostBack="false" />
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>
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
                                    <asp:ObjectDataSource ID="CancellationReasonsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="CancellationReasons" />

                                    <asp:RequiredFieldValidator runat="server" ControlToValidate="CancellationReasonRadComboBox" ErrorMessage="*" ValidationGroup="cancellationReason" ForeColor="Red" />
                                    <%--</fieldset>--%><br />
                                    <asp:CheckBox ID="chkReturnToWaitlist" runat="server" Text="Return patient to waitlist?" CssClass="waitlist-cb" />
                                    <div style="text-align: center; margin-top: 20px; height: 17px;">
                                        <telerik:RadButton ID="ConfirmDeleteBookingRadButton" runat="server" Text="Accept" Icon-PrimaryIconCssClass="telerikYesButton" OnClick="ConfirmDeleteBookingRadButton_Click" />
                                        <telerik:RadButton ID="CancelConfirmDeleteBookingRadButton" runat="server" Text="Cancel" OnClientClicking="closeRadWindow" Icon-PrimaryIconCssClass="telerikNoButton" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>

            <%--  Cancell the list--%>
            <telerik:RadWindow ID="ListCancellConfirmationWindow" runat="server" Width="530" Height="200" CssClass="rad-window" VisibleStatusbar="false" OnClientClose="listCancellWindowClose">
                <ContentTemplate>
                    <div>

                        <div style="padding: 10px; font-size: 13px">
                            <div class="cancellation-confirmation" style="text-align: center; padding: 30px;">
                                Are you sure you want to cancel the list?
                                          <div class="buttons-div" style="margin-top: 20px;">
                                              <telerik:RadButton ID="RadButton1" runat="server" Text="Yes" OnClientClicking="listCancellationYes" />
                                              <telerik:RadButton ID="RadButton2" runat="server" Text="No" OnClientClicking="listCancellWindowClose" />
                                          </div>
                            </div>
                            <div class="cancellation-confirmation-action" style="display: none;">
                                <div style="text-align: center; margin-top: 10px">
                                    Please enter a reason for cancellation&nbsp;
                                             <telerik:RadComboBox ZIndex="79876" ID="ListCancellConfirmationComboBox" DataSourceID="ListCancellationReasonsObjectDataSource" runat="server"
                                                 DataTextField="CancellationReason" DataValueField="ListCancelReasonId" OnClientSelectedIndexChanged="cancellationDropdown" AppendDataBoundItems="true" Text="">
                                                 <Items>
                                                     <telerik:RadComboBoxItem Text="" Value="0" />
                                                 </Items>
                                             </telerik:RadComboBox>
                                    <asp:ObjectDataSource ID="ListCancellationReasonsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="ListCancellationReasons" />
                                    <asp:RequiredFieldValidator runat="server" ControlToValidate="ListCancellConfirmationComboBox" ErrorMessage="*" ValidationGroup="cancellationReason" ForeColor="Red" />

                                    <br />
                                    <div id="listCancellationAlert" style="color: red; margin-top: 10px; display: none"><strong>Please  select a reason</strong> </div>
                                    <br />
                                    <telerik:RadTextBox ID="ListTextArea" runat="server" Width="300px" Height="42px" TextMode="MultiLine" AutoPostBack="false" ClientEvents-OnKeyPress="onKeyUpFunction"></telerik:RadTextBox>
                                    <div id="listTextAreaAlert" style="color: red; display: none"><strong>Please give other Text</strong> </div>
                                    <div style="text-align: center; margin-top: 20px; height: 17px;">
                                        <telerik:RadButton ID="ConfirmScheduleCancelRadButton" runat="server" Text="Accept" Icon-PrimaryIconCssClass="telerikYesButton" AutoPostBack="true" OnClick="ConfirmDeleteScheduleListRadButton_Click" OnClientClicking="ConfirmDeleteScheduleList" />
                                        <telerik:RadButton ID="CancelScheduleCancelRadButton" runat="server" Text="Cancel" OnClientClicking="listCancellWindowClose" Icon-PrimaryIconCssClass="telerikNoButton" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </telerik:RadWindow>
            <telerik:RadWindow ID="ExternalRadWindow" runat="server" CssClass="rad-window-popup-external" VisibleStatusbar="false" Skin="Metro" Style="z-index: 999998;" />
            <telerik:RadWindow ID="TemplateRadWindow" runat="server" VisibleStatusbar="false" Skin="Metro" Style="z-index: 999998;" />
        </Windows>
    </telerik:RadWindowManager>
</asp:Content>
