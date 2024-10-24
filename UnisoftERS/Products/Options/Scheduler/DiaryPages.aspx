<%@ Page Language="VB" MasterPageFile="~/Templates/Scheduler.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_Scheduler_DiaryPages" CodeBehind="DiaryPages.aspx.vb" %>

<%@ Register Src="~/UserControls/CustomDiaryAddEdit.ascx" TagPrefix="scheduler" TagName="AdvancedForm" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title>Add/Edit scheduler templates</title>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
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

        /*.rfbGroup rsResourceControls .rfbRow {
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

        #DiaryRadScheduler_Form_ResourceControls{display:inline !important;}*/

        .optionsSubHeading {
            font-size: 14px !important;
            margin-left: 10px;
            font-weight: bold;
        }

            .optionsSubHeading a {
                font-weight: normal;
            }
    </style>


    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            var demo = window.demo = window.demo || {};
            var schedulerTemplates = {};

            $(window).on('load', function () {

            });

            $(document).ready(function () {
                document.getElementById("<%= DiaryRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 215) + 'px';
                $(window).resize(function () {
                    document.getElementById("<%= DiaryRadScheduler.ClientID%>").style.height = (document.documentElement.clientHeight - 215) + 'px';
                });
            });



            function appointmentSaved() {

            }

            function clientFormCreated(scheduler, eventArgs) {
                // Create a client-side object only for the advanced templates

                var mode = eventArgs.get_mode();
                if (mode == Telerik.Web.UI.SchedulerFormMode.AdvancedInsert ||
                    mode == Telerik.Web.UI.SchedulerFormMode.AdvancedEdit) {
                    // Initialize the client-side object for the advanced form
                    var formElement = eventArgs.get_formElement();
                    var templateKey = scheduler.get_id() + "_" + mode;
                    var advancedTemplate = schedulerTemplates[templateKey];
                    if (!advancedTemplate) {
                        // Initialize the template for this RadScheduler instance
                        // and cache it in the schedulerTemplates dictionary
                        var schedulerElement = scheduler.get_element();
                        var isModal = scheduler.get_advancedFormSettings().modal;
                        advancedTemplate = new SchedulerAdvancedTemplate(schedulerElement, formElement, isModal);
                        advancedTemplate.initialize();

                        schedulerTemplates[templateKey] = advancedTemplate;

                        // Remove the template object from the dictionary on dispose.
                        scheduler.add_disposing(function () {
                            schedulerTemplates[templateKey] = null;
                        });
                    }

                    // Are we using Web Service data binding?
                    if (!scheduler.get_webServiceSettings().get_isEmpty()) {
                        // Populate the form with the appointment data
                        var apt = eventArgs.get_appointment();
                        var apt = eventArgs.get_appointment();
                        var isInsert = mode == Telerik.Web.UI.SchedulerFormMode.AdvancedInsert;
                        advancedTemplate.populate(apt, isInsert);
                    }
                }
            }


            function validationFunction(source, arguments) {
                if (arguments.Value == '' || arguments.Value == '-') {
                    arguments.IsValid = false;
                } else {
                    arguments.IsValid = true;
                }
            }

            function OnClientAppointmentMoveStart(sender, eventArgs) {
                eventArgs.set_cancel(true);
            }

            function OnClientAppointmentDoubleClick(sender, args) {
                alert("");
            }

            var appointment;
            var scheduler;
            var editMode;
            var selectedTimeSlot = {};

            var updatingRecurring;

            function OnClientAppointmentEditing(sender, args) {
                scheduler = sender;
                editMode = 'edit';
                appointment = args.get_appointment();
                updatingRecurring = args.get_editingRecurringSeries();

                OnAppointmentCommand();

                args.set_cancel(true);
            }

            function OnAppointmentCommand() {

                var diaryId = appointment.get_recurrenceState() == 1 || appointment.get_recurrenceState() == 0 ? appointment.get_id() : appointment.get_recurrenceParentID(); //check if we're editing the master record (1) or one of its children to determine where to get the diary id from
                var checkStartDate;
                var urlPath;

                if (updatingRecurring) {
                    checkStartDate = new Date();
                    urlPath = "GetTemplateAppointments";
                }
                else {
                    checkStartDate = appointment.get_start();
                    urlPath = "GetTemplateAppointmentsByDay";
                }

                //set to start of day (midnight)
                checkStartDate.setHours(0);
                checkStartDate.setMinutes(0);

                //check if appointments are attached
                checkForAppointments(diaryId, checkStartDate, urlPath);
            }

            function OnClientAppointmentDeleting(sender, args) {
                scheduler = sender;
                editMode = 'delete';
                appointment = args.get_appointment();
                updatingRecurring = args.get_editingRecurringSeries();

                OnAppointmentCommand();

                args.set_cancel(true);
            }

            function checkForAppointments(diaryId, checkStartDate, urlPath) {
                $.ajax({
                    type: "POST",
                    url: "DiaryPages.aspx/" + urlPath, //GetTemplateAppointments",
                    data: JSON.stringify({ "diaryId": diaryId, "startDate": checkStartDate }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (JSON.parse(data.d).length == 0) {
                            confirmYes();
                        }
                        else {
                            if (editMode == 'delete') {
                                $('.edit-template-message').hide();
                                $('.delete-template-message').show();
                            }
                            else if (editMode == "edit") {
                                $('.edit-template-message').show();
                                $('.delete-template-message').hide();
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
                        var objError = x.responseJSON;
                        var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                        $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                        $find('<%=RadNotification1.ClientID%>').show();
                    }
                });
            }

            function OnClientAppointmentContextMenuItemClicked(sender, args) {
                var itm = args.get_item();
                appointment = args.get_appointment();

                //check if the appointment clicked is possibly an exclusion of an recurring diary 

                scheduler = sender;
                if (itm.get_value() == "MoveTemplate") {
                    confirmTemplateEdit();
                    editMode = "move";
                }
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
                        var objError = x.responseJSON;
                        var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                        $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                        $find('<%=RadNotification1.ClientID%>').show();

                    }
                });
            }

            function OnClientTimeSlotClick(sender, args) {
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
                        var objError = x.responseJSON;
                        var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                        $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                        $find('<%=RadNotification1.ClientID%>').show();
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
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />


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
                                    <div>
                                        Hospital:&nbsp;<telerik:RadDropDownList ID="HospitalDropDownList" CssClass="filterDDL" runat="server" Width="200" DataTextField="HospitalName" AutoPostBack="true" DataValueField="OperatingHospitalID" DataSourceID="HospitalObjectDataSource" OnSelectedIndexChanged="HospitalDropDownList_SelectedIndexChanged" />
                                    </div>
                                </td>
                                <td>
                                    <div>
                                        Room(s):&nbsp;<telerik:RadComboBox ID="RoomsDropdown" CssClass="filterDDL" runat="server" Width="200" CheckBoxes="true" EnableCheckAllItemsCheckBox="true" AllowCustomText="true" DataValueField="RoomId" DataTextField="RoomName" AutoPostBack="false" OnSelectedIndexChanged="RoomsDropdown_SelectedIndexChanged">
                                            <Localization AllItemsCheckedString="All rooms selected" ItemsCheckedString="room(s) selected" />
                                        </telerik:RadComboBox>
                                        <telerik:RadComboBox ID="WeekViewRoomsDropdown" CssClass="filterDDL" runat="server" Width="200" DataValueField="RoomId" DataTextField="RoomName" AutoPostBack="true" Visible="false" OnSelectedIndexChanged="WeekViewRoomsDropdown_SelectedIndexChanged">
                                        </telerik:RadComboBox>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </telerik:RadAjaxPanel>
                </td>
                <td valign="top">
                    <telerik:RadButton ID="SelectRoomButton" runat="server" Text="Change Rooms" CssClass="filterBtn" OnClick="SelectRoomButton_Click" />
                </td>
            </tr>
        </table>
    </div>

    <div class="zoom" style="">
        <div style="padding-left: 85px; font-size: 10px;">Zoom</div>
        <telerik:RadSlider ID="RadSlider1" runat="server" ItemType="Item" Skin="Metro" ThumbsInteractionMode="Free" Value="1" TrackPosition="TopLeft" Height="40px" AutoPostBack="true"
            OnValueChanged="Unnamed_ValueChanged">
            <Items>
                <telerik:RadSliderItem Value="60" Text="100%" />
                <telerik:RadSliderItem Value="30" Text="150%" />
                <telerik:RadSliderItem Value="15" Text="200%" />
                <telerik:RadSliderItem Value="5" Text="250%" />
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

    <div id="FormDiv" runat="server" style="margin: 10px; height: 100%;">
        <telerik:RadScheduler runat="server" ID="DiaryRadScheduler" DataEndField="DiaryEnd" RowHeight="30" Height="95%"
            DataKeyField="DiaryID" DataRecurrenceField="RecurrenceRule" AgendaView-UserSelectable="true"
            StartEditingInAdvancedForm="true" StartInsertingInAdvancedForm="true"
            DataRecurrenceParentKeyField="RecurrenceParentID" DataSourceID="AppointmentsDataSource" EnableDescriptionField="false"
            DataDescriptionField="Description" GroupBy="Room" GroupingDirection="Horizontal" OverflowBehavior="Scroll"
            Localization-AdvancedSubjectRequired="False" OnClientFormCreated="clientFormCreated"
            EnableResourceEditing="true" ShowFooter="false" DayStartTime="06:00" DayEndTime="23:59"
            DataStartField="DiaryStart" DataSubjectField="Subject" Skin="Metro" RenderMode="Classic" DayView-DayStartTime="06:00" DayView-DayEndTime="23:59"
            OnClientAppointmentContextMenuItemClicked="OnClientAppointmentContextMenuItemClicked"
            OnClientAppointmentMoveStart="OnClientAppointmentMoveStart"
            OnClientTimeSlotClick="OnClientTimeSlotClick"
            OnOccurrenceDelete="DiaryRadScheduler_OccurrenceDelete"
            OnClientAppointmentDeleting="OnClientAppointmentDeleting"
            OnClientAppointmentEditing="OnClientAppointmentEditing"
            OnNavigationComplete="DiaryRadScheduler_NavigationComplete"
            AllowEdit="true" EditFormDateFormat="dd/MM/yyyy">
            <AdvancedForm Modal="true" />
            <DayView HeaderDateFormat="dddd, dd MMMM yyyy"></DayView>
            <TimelineView UserSelectable="false" GroupBy="Room" GroupingDirection="Vertical" HeaderDateFormat="dd MMM yyyy" ColumnHeaderDateFormat="dd/MM/yyyy"></TimelineView>
            <WeekView HeaderDateFormat="dd MMM yyyy" EnableExactTimeRendering="true" DayStartTime="06:00" DayEndTime="23:59" />
            <AgendaView UserSelectable="false" HeaderDateFormat="dd MMM yyyy" />
            <MonthView UserSelectable="false" />
            <TimeSlotContextMenus>
                <telerik:RadSchedulerContextMenu runat="server" ID="SlotContextMenu">
                    <Items>
                        <telerik:RadMenuItem Text="Add template" Value="CommandAddAppointment" />
                    </Items>
                </telerik:RadSchedulerContextMenu>
            </TimeSlotContextMenus>
            <AppointmentContextMenus>
                <telerik:RadSchedulerContextMenu runat="server" ID="DiaryPageContextMenu">
                    <Items>
                        <telerik:RadMenuItem Text="Edit template" Value="CommandEdit" Enabled="true" />
                        <telerik:RadMenuItem Text="Delete template" Value="CommandDelete" />
                        <telerik:RadMenuItem Text="Move template" Value="MoveTemplate" Visible="false" />
                    </Items>
                </telerik:RadSchedulerContextMenu>
            </AppointmentContextMenus>
            <ResourceTypes>
                <telerik:ResourceType DataSourceID="AppointmentsDataSource" ForeignKeyField="DiaryId"
                    KeyField="DiaryId" Name="DiaryTemplate" TextField="Subject" />
                <telerik:ResourceType DataSourceID="RoomsDataSource" ForeignKeyField="RoomID"
                    KeyField="RoomId" Name="Room" TextField="RoomName" />
                <telerik:ResourceType DataSourceID="TemplatesObjectDataSource" ForeignKeyField="ListRulesId"
                    KeyField="ListRulesId" Name="Template" TextField="ListName" />
                <telerik:ResourceType DataSourceID="ConsultantDataSource" ForeignKeyField="UserID"
                    KeyField="UserID" Name="Endoscopist" TextField="EndoName" />
            </ResourceTypes>
            <AdvancedInsertTemplate>
                <scheduler:AdvancedForm ID="AdvancedInsertForm1" runat="server" Mode="Insert" OnTemplate_Added="AdvancedInsertForm1_Template_Added"
                    OperatingHospitalId='<%# OperatingHospitalID %>' />
            </AdvancedInsertTemplate>
            <AdvancedEditTemplate>
                <scheduler:AdvancedForm ID="AdvancedEditForm1" runat="server" Mode="Edit" OnTemplate_Updated="AdvancedEditForm1_Template_Updated"
                    UserID='<%# Bind("UserId") %>'
                    ListRulesId='<%# Bind("ListRulesId") %>'
                    DiaryId='<%# Bind("DiaryId") %>'
                    Start='<%# Bind("Start") %>'
                    End='<%# Bind("End") %>'
                    OperatingHospitalId='<%# OperatingHospitalID %>' />

            </AdvancedEditTemplate>
            <AppointmentTemplate>
                <div style="font-weight: bold;">
                    <%# Eval("subject") %>&nbsp;
                </div>

                <div style="font-style: normal;">
                    <%# Eval("Description") %>
                </div>
                <p style="font-style: italic;">
                    <%# DataAdapter_Sch.RecurrenceDescription(Eval("RecurrenceRule")) %>
                </p>
            </AppointmentTemplate>
            <Localization AdvancedEditAppointment="Set worklists (using templates)" AdvancedNewAppointment="Set worklists (using templates)"
                ConfirmDeleteText="Are you sure you want to delete this worklist?" ConfirmRecurrenceDeleteTitle="Deleting a recurring worklist"
                ConfirmRecurrenceEditTitle="Editing a recurring worklist" AllDay="" AdvancedEndDateRequired="false" AdvancedEndTimeRequired="false"
                HeaderAgendaAppointment="Worklist" HeaderAgendaResource="Room name" AdvancedSubject="" />
        </telerik:RadScheduler>

        <asp:SqlDataSource ID="AppointmentsDataSource" runat="server"
            SelectCommand="sch_diary_page_select"
            SelectCommandType="StoredProcedure"
            InsertCommand="sch_diary_page_add"
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
            </InsertParameters>
        </asp:SqlDataSource>
    </div>

    <div class="edit-mode-notification" style="text-align: center; visibility: hidden;">
        <div class="optionsSubHeading">
            <span>Select the time, room and date you wish to move your diary template to...
            </span>
            <asp:LinkButton ID="CancelMoveLinkButton" runat="server" Text="cancel move" OnClientClick="javascript: return cancelMoveMode()" />
        </div>
    </div>

    <asp:ObjectDataSource ID="TemplatesObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetTemplatesLst">
        <SelectParameters>
            <asp:Parameter Name="Field" DbType="String" DefaultValue="" />
            <asp:Parameter Name="FieldValue" DbType="String" DefaultValue="" />
            <asp:Parameter Name="Suppressed" DbType="Int32" />
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

    <asp:ObjectDataSource ID="HospitalObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSchedulerHospitals" />
    <asp:ObjectDataSource ID="HospitalRoomsDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetHospitalRooms">
        <SelectParameters>
            <asp:ControlParameter ControlID="HospitalDropDownList" DbType="Int32" Name="HospitalID" PropertyName="SelectedValue" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <telerik:RadWindowManager ID="DiaryPagesRadWindowManager" runat="server" ShowContentDuringLoad="false"
        Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
        <Windows>
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
        </Windows>
    </telerik:RadWindowManager>
</asp:Content>
