Imports Telerik.Web.UI

Partial Class UserControls_AppScheduler
    Inherits System.Web.UI.UserControl

    Public Event SearchBookingFromWaitlist()

#Region "Properties"
    Private _dataAdapter As DataAccess = Nothing
    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataAdapter Is Nothing Then
                _dataAdapter = New DataAccess
            End If
            Return _dataAdapter
        End Get
    End Property

    Private _dataAdapter_Sch As DataAccess_Sch = Nothing
    Protected ReadOnly Property DataAdapter_Sch() As DataAccess_Sch
        Get
            If _dataAdapter_Sch Is Nothing Then
                _dataAdapter_Sch = New DataAccess_Sch
            End If
            Return _dataAdapter_Sch
        End Get
    End Property

    ReadOnly Property CalendarView As SchedulerViewType
        Get
            Select Case Session("CalendarView")
                Case "day"
                    Return SchedulerViewType.DayView
                Case "week"
                    Return SchedulerViewType.WeekView
                Case "month"
                    Return SchedulerViewType.MonthView
                Case Else
                    Return SchedulerViewType.DayView
            End Select
        End Get
    End Property

    ReadOnly Property SelectedRoomId As Integer
        Get
            If CalendarView = SchedulerViewType.DayView Then
                Return SelectedRoomHiddenField.Value
            Else
                Return 1
            End If
        End Get
    End Property

    Public ReadOnly Property SelectedRoomName As String
        Get
            If CalendarView = SchedulerViewType.DayView Then
                If String.IsNullOrWhiteSpace(SelectedRoomHiddenField.Value) And RoomsDropdown.CheckedItems.Count >= 1 Then
                    Return RoomsDropdown.CheckedItems(0).Text
                ElseIf Not String.IsNullOrWhiteSpace(SelectedRoomHiddenField.Value) Then
                    Return RoomsDropdown.FindItemByValue(CInt(SelectedRoomHiddenField.Value)).Text
                Else
                    Return 0
                End If
            Else
                Return 0
            End If
        End Get
    End Property

    Public Function DiarysAvailableSlots(iDiaryId As Integer, slotDate As String) As List(Of DiarySlot)
        Try
            Dim retVal = (From ds In DataAdapter_Sch.GetFreeDiarySlots(iDiaryId, slotDate).AsEnumerable
                          Where (PageSearchFields.ProcedureTypes.Select(Function(x) x.ProcedureTypeID).ToList.Contains(ds("ProcedureTypeId")) Or (PageSearchFields.ReservedSlotsOnly = 0 And ds("ProcedureTypeId") = 0)) And 'only show slots thats been chosen 
                               ds("SlotType").ToString.ToLower = "freeslot"  'free slot or appointment was booked but is now cancelled
                          Let StartDate = CDate(slotDate & " " & CDate(ds("DiaryStart")).ToShortTimeString)
                          Select New DiarySlot With {
                                       .Description = ds("Subject") & " " & "(" & If(ds("Points") Mod 1 = 0, CInt(ds("Points")) & If(CInt(ds("Points")) = 1, " point", " points"), ds("Points") & " points") & ")",
                                       .RoomId = ds("RoomID"),
                                       .StartDate = StartDate,
                                       .DiaryId = ds("DiaryId"),
                                       .StatusId = ds("StatusId"),
                                       .ProcedureTypeId = ds("ProcedureTypeID"),
                                       .SlotDuration = ds("SlotDuration"),
                                       .SlotPoints = ds("Points"),
                                       .OperatingHospitalId = ds("OperatingHospitalId")})


            If retVal IsNot Nothing Then
                Return retVal.ToList
            Else
                Return Nothing
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("DiarysAvailableSlots: " + ex.ToString(), ex)
            Utilities.SetErrorNotificationStyle(SearchWindowRadNotification, errorLogRef, "There is a problem with your request.")
            SearchWindowRadNotification.Show()
        End Try
    End Function
#End Region

#Region "Page Events"
    Private Sub UserControls_AppScheduler_Init(sender As Object, e As EventArgs) Handles Me.Init
        'If Not IsPostBack Then
        AppointmentsDataSource.ConnectionString = DataAccess.ConnectionStr

        'End If
    End Sub

    Protected Sub Page_Prerender(sender As Object, e As EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            CalendarDateLabel.Text = Now.ToString("dddd, dd MMM yyyy")

            TrustDropDownList.DataSource = DataAdapter_Sch.GetSchedulerTrusts
            TrustDropDownList.DataBind()
            TrustDropDownList.SelectedValue = CInt(Session("TrustId"))
            If (TrustDropDownList.Items.Count = 1) Then
                TrustDiv.Visible = False
            End If

            SearchTrustRadComboBox.DataSource = DataAdapter_Sch.GetSchedulerTrusts
                SearchTrustRadComboBox.DataBind()
                SearchTrustRadComboBox.Items.Add(New RadComboBoxItem("All trusts", 0))
                SearchTrustRadComboBox.SelectedValue = 0

                PopulateFromTrust(CInt(Session("TrustId")))

                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-selected-calendar-view", "setCalendarView('" & CalendarView.ToString.ToLower().Replace("view", "") & "');", True)
                If UCase(ConfigurationManager.AppSettings("DisplayWaitlist").ToString()) = "TRUE" Then
                    BookFromWaitlistRadButton.Visible = True
                Else
                    BookFromWaitlistRadButton.Visible = False
                End If
            End If


    End Sub

    Private Sub PopulateFromTrust(TrustId As Integer)
        HospitalDropDownList.DataSource = DataAdapter_Sch.GetSchedulerHospitals(TrustId)
        HospitalDropDownList.DataBind()
        HospitalDropDownList.SelectedIndex = 0

        RoomsDropdown.DataSource = DataAdapter_Sch.GetHospitalRooms(HospitalDropDownList.SelectedValue)
        RoomsDropdown.DataBind()
        If Not Session("WorklistRoomId") = Nothing Then
            RoomsDropdown.Items.FindItemByValue(Session("WorklistRoomId")).Checked = True
        Else
            RoomsDropdown.Items(0).Checked = True
        End If

        Dim selectedRooms As New List(Of Object)

        For Each itm As RadComboBoxItem In RoomsDropdown.Items
            Dim obj = New With {
                .RoomId = itm.Value,
                .RoomName = itm.Text
            }
            selectedRooms.Add(obj)
        Next

        rptRoomTabs.DataSource = selectedRooms
        rptRoomTabs.DataBind()

        SelectedRoomHiddenField.Value = RoomsDropdown.Items(0).Value
        'select 1st room
        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-tab", "setRoomTabSelected(" & RoomsDropdown.Items(0).Value & ");", True)



        RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = HospitalDropDownList.SelectedValue
        RoomsDataSource.SelectParameters("FieldValue").DefaultValue = RoomsDropdown.Items(0).Value
        RoomNameLabel.Text = RoomsDropdown.Items(0).Text

        ListRadScheduler.SelectedView = SchedulerViewType.DayView
        AMRadScheduler.SelectedView = SchedulerViewType.DayView
        PMRadScheduler.SelectedView = SchedulerViewType.DayView
        EVRadScheduler.SelectedView = SchedulerViewType.DayView

        'If DataAdapter_Sch.IncludeDiaryEvenings(HospitalDropDownList.SelectedValue) Then
        EVEDiv.Visible = True
        AMDiv.Style.Item("width") = "32%"
        PMDiv.Style.Item("width") = "32%"
        EVEDiv.Style.Item("width") = "32%"
        'End If
        Dim selectedDate = Now

        If Not Session("WorklistDate") = Nothing Then
            selectedDate = Session("WorklistDate")
        End If

        GetDiarySlots(True, SelectedRoomId)
        setDate(selectedDate)
        DiaryDatePicker.SelectedDate = selectedDate
    End Sub

    Private Sub startReservedSlotCheck(endoId As Integer)
        Try
            While 1 = 1
                Using db As New ERS.Data.GastroDbEntities
                    Dim maxReservedSlotTime = 15 'to be configurable
                    Dim reservedStatusId As Integer = (From s In db.ERS_AppointmentStatus Where s.HDCKEY = "H" Select s.UniqueId).FirstOrDefault

                    Dim redundantReservedSlots = db.ERS_Appointments.Where(Function(x) x.AppointmentStatusId = reservedStatusId And Entity.DbFunctions.AddMinutes(x.DateEntered, maxReservedSlotTime) <= Now)

                    redundantReservedSlots = redundantReservedSlots.Where(Function(y) y.EndoscopistId = endoId)

                    If redundantReservedSlots.Count > 0 Then
                        db.ERS_Appointments.RemoveRange(redundantReservedSlots)
                        db.SaveChanges()
                    End If
                    GetDiarySlots(True)

                End Using

                System.Threading.Thread.Sleep(10000)
            End While
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error unreserving slots", ex)
        End Try
    End Sub

    Private Sub UserControls_AppScheduler_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)

        'myAjaxMgr.AjaxSettings.AddAjaxSetting(PMRadScheduler, PMRadScheduler)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(EVRadScheduler, EVRadScheduler)


        'myAjaxMgr.AjaxSettings.AddAjaxSetting(ReservedSlotCheckTimer, AMRadScheduler)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(ReservedSlotCheckTimer, PMRadScheduler)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(ReservedSlotCheckTimer, EVRadScheduler)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(ReservedSlotCheckTimer, ListRadScheduler)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(ReservedSlotCheckTimer, DiaryOverviewRadScheduler)


        myAjaxMgr.AjaxSettings.AddAjaxSetting(DiaryOverviewRadScheduler, AMRadScheduler)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(DiaryOverviewRadScheduler, PMRadScheduler)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(DiaryOverviewRadScheduler, EVRadScheduler)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(DiaryOverviewRadScheduler, ListRadScheduler)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(DiaryOverviewRadScheduler, DiaryOverviewRadScheduler)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(OverviewEndoscopistRadComboBox, DiaryOverviewRadScheduler, RadAjaxLoadingPanel1, UpdatePanelRenderMode.Inline)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(OverviewEndoscopistRadComboBox, OverviewEndoscopistRadComboBox)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(OverviewTypeRadioButtonList, OverviewTypeRadioButtonList)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(OverviewTypeRadioButtonList, OverviewEndoscopistRadComboBox)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(OverviewTypeRadioButtonList, DiaryOverviewRadScheduler, RadAjaxLoadingPanel1, UpdatePanelRenderMode.Inline)

        'myAjaxMgr.AjaxSettings.AddAjaxSetting(RadNotification1, RadNotification1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(RadNotification1, RadNotification1)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(ListSlotsRadGrid, ListRadScheduler)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(ListSlotsRadGrid, ListSlotsRadGrid)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(SearchAvailableSlotDiv, SearchAvailableSlotDiv, RadAjaxLoadingPanel1)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(FindAvailableSlotRadButton, FindAvailableSlotRadButton)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(FindAvailableSlotRadButton, RadNotification1)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(BookFromWaitlistRadButton, BookFromWaitlistRadButton)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FindExistingBookingRadButton, FindExistingBookingRadButton)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SearchGIProcedureRadioButtons, SearchEndoscopistDropdown)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(AvailableSlotsResultsRepeater, ListSlotsRadGrid)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(AvailableSlotsResultsRepeater, BookingSlotDateLabel)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConfirmDeleteBookingRadButton, ListRadScheduler, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConfirmDeleteBookingRadButton, DeleteBookingRadNotification)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConfirmDeleteBookingRadButton, AMRadScheduler)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConfirmDeleteBookingRadButton, PMRadScheduler)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConfirmDeleteBookingRadButton, EVRadScheduler)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(WaitListGrid, WaitListGrid)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(BookFromWaitlistRadButton, divWaitlist, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(FindAvailableSlotRadButton, divFilters, RadAjaxLoadingPanel1)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(SearchExistingBookingButton, AMNotesTextBox)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SearchExistingBookingButton, PMNotesTextBox)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SearchExistingBookingButton, EVENotesTextBox)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(SearchExistingBookingButton, FindExistingBookingDiv)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingResults, FoundBookingResults)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SearchExistingBookingButton, FoundBookingResults)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, FoundBookingsRadGrid)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, AMRadScheduler)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, PMRadScheduler)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, EVRadScheduler)

        'myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, RoomsDropdown)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, HospitalDropDownList)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, RoomNameLabel)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, CalendarDateLabel)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, AMDiaryDetails)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, PMDiaryDetails)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, EVEDiaryDetails)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, AMNotesTextBox)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, PMNotesTextBox)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FoundBookingsRadGrid, EVENotesTextBox)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConfirmDeleteBookingRadButton, ConfirmDeleteBookingRadButton)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConfirmDeleteBookingRadButton, AMDiaryDetails)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConfirmDeleteBookingRadButton, PMDiaryDetails)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConfirmDeleteBookingRadButton, EVEDiaryDetails)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(imgAMListLock, imgAMListLock)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgAMListLock, LockingDiaryInfo)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgAMListLock, LockReasonDiaryDetailsLabel)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgAMListLock, LockReasonRadComboBox)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgAMListLock, btnReload)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(imgPMListLock, imgPMListLock)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgPMListLock, LockingDiaryInfo)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgPMListLock, LockReasonDiaryDetailsLabel)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgPMListLock, LockReasonRadComboBox)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgPMListLock, btnReload)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(imgEVEListLock, imgEVEListLock)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgEVEListLock, LockingDiaryInfo)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgEVEListLock, LockReasonDiaryDetailsLabel)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgEVEListLock, LockReasonRadComboBox)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(imgEVEListLock, btnReload)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(PreviousDayLinkButton, FormDiv, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(NextDayLinkButton, FormDiv, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(TodaysDateLinkButton, FormDiv, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(DayLinkButton, FormDiv, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(WeekLinkbutton, FormDiv, RadAjaxLoadingPanel1)

        AddHandler myAjaxMgr.AjaxRequest, AddressOf RadAjaxManager1_AjaxRequest

        'myAjaxMgr.AjaxSettings.AddAjaxSetting(ChangeRoomButton, ListRadScheduler, RadAjaxLoadingPanel1)

        myAjaxMgr.EnableViewState = True
        'myAjaxMgr.PostBackControls = {"SlotsRadGrid"}
        'myAjaxMgr.Style.Item("display") = "inline"

        If Not Page.IsPostBack Then

            Session("CalendarView") = "day"
            ReferalDateDatePicker.SelectedDate = Now
            BreachDateDatePicker.SelectedDate = Now.AddDays(14)
            SearchDateDatePicker.SelectedDate = BreachDateDatePicker.SelectedDate.Value.AddDays(-(SearchWeeksBeforeTextBox.Value * 7))
            'ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "SearchSlotTimePickerSetup", "setBreachDays();", True)
        Else
            For Each itm As RepeaterItem In rptProcedureTypes.Items
                CType(itm.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = (CType(itm.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked)
            Next
        End If
    End Sub
#End Region

#Region "Scheduler Events"
    Private Sub GetDiarySlots(hideCancelledBookings As Boolean, Optional roomId As Integer = 0)
        Try
            If CalendarView = SchedulerViewType.MonthView Then
                DiaryOverviewRadScheduler.DataSource = DataAdapter_Sch.getDiaryPages()
                DiaryOverviewRadScheduler.DataBind()

                OverviewEndoscopistRadComboBox.DataSource = DataAdapter.GetEndoscopist()
                OverviewEndoscopistRadComboBox.DataTextField = "EndoName"
                OverviewEndoscopistRadComboBox.DataValueField = "UserId"
                OverviewEndoscopistRadComboBox.DataBind()
                OverviewEndoscopistRadComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
            Else
                If dayViewDiv.Visible Then
                    Dim dt = DataAdapter_Sch.GetDiaryDaySlots(OperatingHospitalID, hideCancelledBookings, AMRadScheduler.SelectedDate, {roomId}.ToList)
                    Dim AMDiaryId As Integer = (From x In dt.AsEnumerable Where CDate(x("DiaryStart")).Hour > 0 And CDate(x("DiaryStart")).Hour < 12 Order By x("DiaryStart") Select x("DiaryId")).FirstOrDefault

                    If AMDiaryId > 0 Then
                        Dim dtAM = dt.AsEnumerable.Where(Function(x) x("DiaryId") = AMDiaryId)

                        NoAMListDiv.Visible = False
                        AMRadScheduler.Style.Item("display") = "inline-block"

                        'AMRadScheduler.DayStartTime = CDate(dtAM.OrderBy(Function(x) x("DiaryStart"))(0)("DiaryStart")).TimeOfDay
                        'AMRadScheduler.DayEndTime = CDate(dtAM.OrderByDescending(Function(x) x("DiaryStart"))(0)("DiaryEnd")).TimeOfDay

                        AMRadScheduler.DataSource = dtAM.CopyToDataTable
                        AMRadScheduler.DataBind()
                    Else
                        NoAMListDiv.Visible = True
                        AMRadScheduler.Style.Item("display") = "none"
                        AMRadScheduler.DataSource = New DataTable()
                        AMRadScheduler.DataBind()
                        AMDiaryDetails.Text = ""
                    End If

                    Dim PMDiaryId As Integer = (From x In dt.AsEnumerable Where Not x("DiaryId") = AMDiaryId And CDate(x("DiaryStart")).Hour >= 12 And CDate(x("DiaryStart")).Hour < 17 Select x("DiaryId")).FirstOrDefault
                    If PMDiaryId > 0 Then
                        Dim dtPM = dt.AsEnumerable.Where(Function(x) x("DiaryId") = PMDiaryId)

                        NoPMListDiv.Visible = False
                        PMRadScheduler.Style.Item("display") = "inline-block"

                        PMRadScheduler.DayStartTime = CDate(dtPM.OrderBy(Function(x) x("DiaryStart"))(0)("DiaryStart")).TimeOfDay
                        PMRadScheduler.DayEndTime = CDate(dtPM.OrderByDescending(Function(x) x("DiaryStart"))(0)("DiaryEnd")).TimeOfDay

                        PMRadScheduler.DataSource = dtPM.CopyToDataTable
                        PMRadScheduler.DataBind()
                    Else
                        NoPMListDiv.Visible = True
                        PMRadScheduler.Style.Item("display") = "none"

                        PMRadScheduler.DataSource = New DataTable()
                        PMRadScheduler.DataBind()
                        PMDiaryDetails.Text = ""
                        imgPMListLock.Visible = False
                    End If

                    Dim EVEDiaryId As Integer = (From x In dt.AsEnumerable Where Not x("DiaryId") = AMDiaryId And Not x("DiaryId") = PMDiaryId And CDate(x("DiaryStart")).Hour >= 17 Select x("DiaryId")).FirstOrDefault
                    If EVEDiaryId > 0 Then
                        Dim dtEV = dt.AsEnumerable.Where(Function(x) x("DiaryId") = EVEDiaryId)

                        NoEVEListDiv.Visible = False
                        EVRadScheduler.Style.Item("display") = "inline-block"

                        EVRadScheduler.DayStartTime = CDate(dtEV.OrderBy(Function(x) x("DiaryStart"))(0)("DiaryStart")).TimeOfDay
                        EVRadScheduler.DayEndTime = CDate(dtEV.OrderByDescending(Function(x) x("DiaryStart"))(0)("DiaryEnd")).TimeOfDay

                        EVRadScheduler.DataSource = dtEV.CopyToDataTable
                        EVRadScheduler.DataBind()
                    Else
                        NoEVEListDiv.Visible = True
                        EVRadScheduler.Style.Item("display") = "none"

                        EVRadScheduler.DataSource = New DataTable()
                        EVRadScheduler.DataBind()
                        EVEDiaryDetails.Text = ""
                        imgEVEListLock.Visible = False
                    End If

                    notesSetup()
                ElseIf OtherViewDiv.Visible Then
                    Dim dt = DataAdapter_Sch.GetDiarySlots(OperatingHospitalID, hideCancelledBookings, roomId)

                    If dt.Rows.Count > 0 Then
                        ListRadScheduler.DataSource = dt
                        ListRadScheduler.DataBind()
                    Else
                        ListRadScheduler.DataSource = New DataTable
                        ListRadScheduler.DataBind()
                    End If
                End If

                If CalendarView = SchedulerViewType.DayView Then
                    ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-amended-bookings-notification", "GetDiaryAmendedBookings('" & AMRadScheduler.SelectedDate & "','" & SelectedRoomId & "');", True)
                End If
            End If

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("An error occured getting diary slots", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "An error occured while getting the diary")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub ListRadScheduler_FormCreated(sender As Object, e As SchedulerFormCreatedEventArgs)
        If e.Container.Mode = SchedulerFormMode.AdvancedInsert Or e.Container.Mode = SchedulerFormMode.AdvancedEdit Then

            'Find the TextBox for the Description and make it invisible  
            Dim DescTextbox As RadTextBox = DirectCast(e.Container.FindControl("Description"), RadTextBox)
            If Not DescTextbox Is Nothing Then
                DescTextbox.Visible = False
            End If

            'Make subject textbox readonly
            Dim subject As RadTextBox = DirectCast(e.Container.FindControl("Subject"), RadTextBox)
            subject.ReadOnly = True

            Dim subjectValidator As RequiredFieldValidator = DirectCast(e.Container.FindControl("SubjectValidator"), RequiredFieldValidator)
            If ((Not (subject) Is Nothing) _
                        AndAlso (Not (subjectValidator) Is Nothing)) Then
                subjectValidator.Enabled = False
            End If

            'Dim ResTemplate As RadComboBox = DirectCast(e.Container.FindControl("ResTemplate"), RadComboBox)

            'Add custom validator for template which is compulsory
            Dim validatorForAttribute As CustomValidator = New CustomValidator()
            Dim scheduler As RadScheduler = CType(sender, RadScheduler)
            validatorForAttribute.ID = "TemplateValidator"
            validatorForAttribute.ValidationGroup = scheduler.ValidationGroup
            validatorForAttribute.ControlToValidate = "ResTemplate"
            validatorForAttribute.ErrorMessage = "Please select a template."
            validatorForAttribute.ClientValidationFunction = "validationFunction"
            If e.Container.FindControl("ResTemplate") IsNot Nothing Then
                DirectCast(e.Container.FindControl("ResTemplate"), RadComboBox).Parent.Controls.Add(validatorForAttribute)
            End If

        End If
    End Sub

    Protected Sub ListRadScheduler_AppointmentInsert(sender As Object, e As AppointmentInsertEventArgs)
        Try

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on default page.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub ListRadScheduler_NavigationComplete(sender As Object, e As SchedulerNavigationCompleteEventArgs)
        Dim stDate As Date = CType(sender, RadScheduler).VisibleRangeStart
        Dim endDate As Date = CType(sender, RadScheduler).VisibleRangeEnd
        '  AppointmentsDataSource.SelectCommand = "SELECT 1 AS [AppId]
        ','BUIT' AS [Subject]
        ','2018-05-22 12:00:00.000' AS [Start]
        ','2018-05-22 13:00:00.000' AS [End]
        ',5 AS [UserID]
        ',1 AS [RoomID]
        ',1 AS [ListRulesId]
        ',NULL AS [RecurrenceRule]
        ',NULL AS [RecurrenceParentID]
        ',NULL AS [Annotations]
        ',NULL AS [Description]"
        'FROM [dbo].[ERS_SCH_Appointments]"

    End Sub


    Protected Sub ListRadScheduler_AppointmentCreated(sender As Object, e As AppointmentCreatedEventArgs)
        Try
            If CalendarView = SchedulerViewType.MonthView Then
                Dim iDiaryId = CInt(e.Appointment.Attributes("diaryId"))
                Dim booked As Decimal = 0.0
                Dim totalPoints = DataAdapter_Sch.GetTotalListPoints(iDiaryId)

                Dim monthAppointments = DataAdapter_Sch.getDaysAppointments(e.Appointment.Start.Date, iDiaryId)

                If CBool(e.Appointment.Attributes("training")) Then
                    e.Appointment.Subject += " (training)"
                End If

                If e.Appointment.Start.TimeOfDay < New TimeSpan(12, 0, 0) Then
                    e.Appointment.Subject = "AM List" & "<br />" & e.Appointment.Subject
                    If monthAppointments IsNot Nothing Then
                        booked = monthAppointments.AsEnumerable.Where(Function(x) CDate(x("StartDate")).TimeOfDay < New TimeSpan(12, 0, 0)).Sum(Function(x) CDec(x("Points")))
                    End If

                ElseIf e.Appointment.Start.TimeOfDay >= New TimeSpan(12, 0, 0) And e.Appointment.Start.TimeOfDay < New TimeSpan(17, 0, 0) Then
                    e.Appointment.Subject = "PM List" & "<br />" & e.Appointment.Subject
                    If monthAppointments IsNot Nothing Then
                        booked = monthAppointments.AsEnumerable.Where(Function(x) CDate(x("StartDate")).TimeOfDay >= New TimeSpan(12, 0, 0) And CDate(x("StartDate")).TimeOfDay < New TimeSpan(17, 0, 0)).Sum(Function(x) CDec(x("Points")))
                    End If

                ElseIf e.Appointment.Start.TimeOfDay >= New TimeSpan(17, 0, 0) Then
                    e.Appointment.Subject = "EVENING List" & "<br />" & e.Appointment.Subject

                    If monthAppointments IsNot Nothing Then
                        booked = monthAppointments.AsEnumerable.Where(Function(x) CDate(x("StartDate")).TimeOfDay >= New TimeSpan(17, 0, 0)).Sum(Function(x) CDec(x("Points")))
                    End If
                End If
                Dim freePoints As Decimal = totalPoints - booked
                Dim overBooked As Decimal
                If freePoints < 0 Then
                    overBooked = Math.Abs(freePoints)
                    freePoints = 0
                End If
                If overBooked > 0 Then
                    e.Appointment.Description += "<br />" & String.Format("Free: {0}/Booked: {1} ({2} Over)", freePoints, booked, overBooked)
                Else
                    e.Appointment.Description += "<br />" & String.Format("Free: {0}/Booked: {1}", (totalPoints - booked), booked)
                End If
                e.Appointment.ToolTip = e.Appointment.Subject.Replace("<br />", vbCrLf) & vbCrLf & e.Appointment.Description.Replace("<br />", vbCrLf)

                If booked <= 0 Then
                    e.Appointment.BackColor = Drawing.Color.FromName("#46a958") 'empty
                ElseIf booked >= totalPoints Then
                    e.Appointment.BackColor = Drawing.Color.FromName("#d33a3a") 'full
                Else
                    e.Appointment.BackColor = Drawing.Color.FromName("#d89f3b") 'used
                End If
            Else
                If DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("AM") Then
                    'Appointment.Start = New Date(2020, 3, 2, 9, 35, 0)


                    If e.Appointment.Attributes("slotType").ToLower = "freeslot" Then
                        AMFreeSlots += 1
                    End If

                    If Not e.Appointment.Attributes("slotType").ToLower = "endoflist" Then
                        AMAppointmentCount += 1
                    Else
                        If AMFreeSlots = 0 Then
                            e.Appointment.ContextMenuID = "SchedulerAppointmentContextMenuAM"
                        Else
                            e.Appointment.ContextMenuID = Nothing
                        End If
                    End If

                ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("PM") Then
                    If e.Appointment.Attributes("slotType").ToLower = "freeslot" Then
                        PMFreeSlots += 1
                    ElseIf e.Appointment.Attributes("slotType").ToLower = "patientbooking" Then
                        Dim listPoints = e.Appointment.Attributes("slotPoints") 'DataAdapter_Sch.GetListSlotPoints(e.Appointment.ID)
                        PMBookedSlots += 1
                        PMUsedPoints += listPoints
                    End If

                    If Not e.Appointment.Attributes("slotType").ToLower = "endoflist" Then
                        PMAppointmentCount += 1
                    Else
                        If PMFreeSlots = 0 Then
                            e.Appointment.ContextMenuID = "SchedulerAppointmentContextMenuPM"
                        Else
                            e.Appointment.ContextMenuID = Nothing
                        End If
                    End If
                ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("EV") Then

                    If Not e.Appointment.Attributes("slotType").ToLower = "endoflist" Then EVEAppointmentCount += 1
                    If e.Appointment.Attributes("slotType").ToLower = "freeslot" Then
                        EVEFreeSlots += 1
                    ElseIf e.Appointment.Attributes("slotType").ToLower = "patientbooking" Then
                        Dim listPoints = e.Appointment.Attributes("slotPoints") 'DataAdapter_Sch.GetListSlotPoints(e.Appointment.ID)
                        EVEBookedSlots += 1
                        EVEUsedPoints += listPoints
                    End If

                    If Not e.Appointment.Attributes("slotType").ToLower = "endoflist" Then
                        EVEAppointmentCount += 1
                    Else
                        If EVEFreeSlots = 0 Then
                            e.Appointment.ContextMenuID = "SchedulerAppointmentContextMenuEVE"
                        Else
                            e.Appointment.ContextMenuID = Nothing
                        End If
                    End If
                End If

                If e.Appointment.Attributes("slotType").ToString.ToLower = "patientbooking" Then
                    Dim patientNotes = e.Appointment.Attributes("bookingNotes")
                    If Not String.IsNullOrWhiteSpace(patientNotes) Then
                        Dim appointmentToolTipId = "AppointmentNotesToolTip"
                        Dim appointmentToolTipImageId = "AppointmentNotesToolTipImage"

                        If DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("AM") Then
                            appointmentToolTipId += "AM"
                            appointmentToolTipImageId += "AM"
                        ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("PM") Then
                            appointmentToolTipId += "PM"
                            appointmentToolTipImageId += "PM"
                        ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("EV") Then
                            appointmentToolTipId += "EVE"
                            appointmentToolTipImageId += "EVE"
                        End If

                        CType(e.Container.FindControl(appointmentToolTipImageId), HtmlImage).Visible = True
                        CType(e.Container.FindControl(appointmentToolTipId), RadToolTip).Text = patientNotes.Replace(vbCrLf, "<br/>")
                    End If

                    Dim generalInfo = e.Appointment.Attributes("bookingInformation")
                    If Not String.IsNullOrWhiteSpace(generalInfo) Then
                        Dim infoToolTipId = "AppointmentGeneralInfoToolTip"
                        Dim infoToolTipImageId = "AppointmentGeneralInfoToolTipImage"

                        If DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("AM") Then
                            infoToolTipId += "AM"
                            infoToolTipImageId += "AM"
                        ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("PM") Then
                            infoToolTipId += "PM"
                            infoToolTipImageId += "PM"
                        ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("EV") Then
                            infoToolTipId += "EVE"
                            infoToolTipImageId += "EVE"
                        End If

                        CType(e.Container.FindControl(infoToolTipImageId), HtmlImage).Visible = True
                        CType(e.Container.FindControl(infoToolTipId), RadToolTip).Text = generalInfo.Replace(vbCrLf, "<br/>")
                    End If
                Else
                    'check if appointment start is before previous appointment end- if so change times, change color, change description and make non selectable
                    Dim i = 0
                    Dim aStart = e.Appointment.Start
                    Dim aEnd = e.Appointment.End
                End If
            End If

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error in ListRadScheduler_AppointmentCreated", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem getting diary slots/appointments")
        End Try
    End Sub

    Protected Sub ListRadScheduler_AppointmentDataBound(sender As Object, e As SchedulerEventArgs)
        Try
            If CalendarView = SchedulerViewType.MonthView Then
                e.Appointment.Attributes.Add("slotCount", CType(e.Appointment.DataItem, DataRowView).Row("SlotCount"))
                e.Appointment.Attributes.Add("roomId", CType(e.Appointment.DataItem, DataRowView).Row("RoomId"))
                e.Appointment.Attributes.Add("training", CType(e.Appointment.DataItem, DataRowView).Row("Training"))
                e.Appointment.Attributes.Add("diaryId", CType(e.Appointment.DataItem, DataRowView).Row("DiaryId"))
                e.Appointment.CssClass = "overview-slot"
                'e.Appointment.ToolTip = CType(e.Appointment.DataItem, DataRowView).Row("Subject") & vbCrLf & CType(e.Appointment.DataItem, DataRowView).Row("Description")

            Else

                Dim slotColor = System.Drawing.ColorTranslator.FromHtml(CType(e.Appointment.DataItem, DataRowView).Row("SlotColor").ToString())

                e.Appointment.BackColor = slotColor

                e.Appointment.Attributes.Add("statusId", CType(e.Appointment.DataItem, DataRowView).Row("StatusId"))
                e.Appointment.Attributes.Add("procedureTypeId", CType(e.Appointment.DataItem, DataRowView).Row("ProcedureTypeID"))
                e.Appointment.Attributes.Add("roomId", CType(e.Appointment.DataItem, DataRowView).Row("RoomId"))
                e.Appointment.Attributes.Add("slotType", CType(e.Appointment.DataItem, DataRowView).Row("SlotType"))
                e.Appointment.Attributes.Add("diaryId", CType(e.Appointment.DataItem, DataRowView).Row("DiaryId"))
                e.Appointment.Attributes.Add("slotLength", CType(e.Appointment.DataItem, DataRowView).Row("SlotDuration"))
                e.Appointment.Attributes.Add("slotPoints", CType(e.Appointment.DataItem, DataRowView).Row("Points"))
                e.Appointment.Attributes.Add("operatingHospitalId", CType(e.Appointment.DataItem, DataRowView).Row("OperatingHospitalId"))


                If e.Appointment.Attributes("slotType").ToLower = "patientbooking" Then
                    Dim dr = CType(e.Appointment.DataItem, DataRowView)

                    'e.Appointment.ToolTip = CDate(dr("DiaryStart")).ToShortTimeString & "-" & CDate(dr("DiaryEnd")).ToShortTimeString & ": " & dr("Subject")

                    e.Appointment.ToolTip = dr("Description")

                    e.Appointment.Attributes.Add("appointmentId", CType(e.Appointment.DataItem, DataRowView).Row("AppointmentId"))
                    e.Appointment.Attributes.Add("statusCode", CType(e.Appointment.DataItem, DataRowView).Row("StatusCode"))
                    e.Appointment.Attributes.Add("operatingHospitalId", CType(e.Appointment.DataItem, DataRowView).Row("OperatingHospitalId"))

                    e.Appointment.CssClass = "patient-booking-slot"



                    Dim contextMenuId = "SchedulerBookingContextMenu"
                    If DirectCast(sender, RadScheduler).ID.ToUpper.Contains("AM") Then
                        contextMenuId += "AM"
                        AMBookedSlots += 1
                        AMUsedPoints += CDec(e.Appointment.Attributes("slotPoints"))
                    ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.Contains("PM") Then
                        contextMenuId += "PM"
                        AMBookedSlots += 1
                        AMUsedPoints += CDec(e.Appointment.Attributes("slotPoints"))
                    ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.Contains("EV") Then
                        contextMenuId += "EVE"
                        AMBookedSlots += 1
                        AMUsedPoints += CDec(e.Appointment.Attributes("slotPoints"))
                    End If

                    e.Appointment.ContextMenuID = contextMenuId

                    'information fields
                    e.Appointment.Attributes.Add("bookingNotes", CType(e.Appointment.DataItem, DataRowView).Row("Notes"))
                    e.Appointment.Attributes.Add("bookingInformation", CType(e.Appointment.DataItem, DataRowView).Row("GeneralInfo"))

                    'status colours
                    If Not dr.Row.IsNull("StatusCode") Then

                        Select Case dr("StatusCode")

                            Case "B", "E", ""
                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#7FCC7F")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"

                                If Not String.IsNullOrWhiteSpace(dr("StatusCode")) Then e.Appointment.ToolTip += vbCrLf & "Booked"
                            Case "P"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#7FCC7F")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"

                                e.Appointment.ToolTip += vbCrLf & "Partially booked"

                            Case "A"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#7FDBF5")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                e.Appointment.ToolTip += vbCrLf & "Arrived"

                            Case "BA"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#B5D2E6")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                e.Appointment.ToolTip += vbCrLf & "Arrived"

                            Case "D"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#E38AC2")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                e.Appointment.ToolTip += vbCrLf & "Patient DNA"

                            Case "X"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#8D8D8D")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                e.Appointment.ToolTip += vbCrLf & "Abandoned"

                            Case "IP"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#FFD966")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                e.Appointment.ToolTip += vbCrLf & "In progress"

                            Case "DC"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#0000FF")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#FFFFFF")

                                e.Appointment.CssClass += " row-colour-opacity"
                                e.Appointment.ToolTip += vbCrLf & "Discharged"

                            Case "RC"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#FFA500")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                e.Appointment.ToolTip += vbCrLf & "In recovery"
                            Case Else

                                e.Appointment.BackColor = slotColor

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"

                        End Select

                    Else

                        e.Appointment.BackColor = slotColor

                        e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                        e.Appointment.CssClass += " row-colour-opacity"

                    End If

                ElseIf e.Appointment.Attributes("slotType").ToLower = "reservedslot" Then 'reserved slot (booking in progress)
                    'e.Appointment.Attributes.Add("lockedByUser", CType(e.Appointment.DataItem, DataRowView).Row("EndoscopistName"))
                    'e.Appointment.BackColor = System.Drawing.Color.Yellow
                    'e.Appointment.CssClass = "free-slot"
                    Dim p = 0
                ElseIf e.Appointment.Attributes("slotType").ToLower = "freeslot" Then 'appointment/patient booking
                    e.Appointment.CssClass = "free-slot"

                    Dim dr = CType(e.Appointment.DataItem, DataRowView)

                    e.Appointment.ToolTip = CDate(dr("DiaryStart")).ToShortTimeString & "-" & CDate(dr("DiaryEnd")).ToShortTimeString

                    Dim contextMenuId = "SchedulerAppointmentContextMenu"
                    If DirectCast(sender, RadScheduler).ID.ToUpper.Contains("AM") Then
                        contextMenuId += "AM"
                    ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.Contains("PM") Then
                        contextMenuId += "PM"
                    ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.Contains("EV") Then
                        contextMenuId += "EVE"
                    End If

                    e.Appointment.ContextMenuID = contextMenuId
                ElseIf e.Appointment.Attributes("slotType").ToLower = "endoflist" Then
                    e.Appointment.CssClass = "end-of-list"
                    If CalendarView = SchedulerViewType.WeekView Then
                        e.Appointment.CssClass = "end-of-list no-padding"
                    Else
                        e.Appointment.CssClass = "end-of-list align-center"
                    End If


                End If
            End If

        Catch ex As Exception

        End Try
    End Sub
#End Region

    Protected Sub SearchTrustRadComboBox_Loaded(sender As Object, e As EventArgs) Handles SearchTrustRadComboBox.SelectedIndexChanged
        If SearchTrustRadComboBox.SelectedValue = 0 Then
            SearchOperatingHospitalIdRadComboBox.DataSource = DataAdapter_Sch.GetAllSchedulerHospitals()
        Else
            SearchOperatingHospitalIdRadComboBox.DataSource = DataAdapter_Sch.GetSchedulerHospitals(SearchTrustRadComboBox.SelectedValue)
        End If
        SearchOperatingHospitalIdRadComboBox.DataBind()
        'SearchOperatingHospitalIdRadComboBox.Items(SearchOperatingHospitalIdRadComboBox.FindItemIndexByValue(OperatingHospitalID)).Checked = True
    End Sub


    Protected Sub TrustDropDownList_Loaded(sender As Object, e As EventArgs) Handles TrustDropDownList.SelectedIndexChanged
        PopulateFromTrust(TrustDropDownList.SelectedValue)
    End Sub

#Region "Hospital Room Filter"
    Protected Sub HospitalDropDownList_Loaded(sender As Object, e As EventArgs) Handles HospitalDropDownList.SelectedIndexChanged
        Try
            RoomsDropdown.DataSource = DataAdapter_Sch.GetHospitalRooms(HospitalDropDownList.SelectedValue)
            RoomsDropdown.DataBind()
            If RoomsDropdown.Items.Count > 0 Then
                RoomsDropdown.Items(0).Checked = True
                RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = HospitalDropDownList.SelectedValue
                RoomsDataSource.SelectParameters("FieldValue").DefaultValue = RoomsDropdown.Items(0).Value
                RoomNameLabel.Text = RoomsDropdown.Items(0).Text
            End If

            Dim selectedRooms As New List(Of Object)
            For Each itm As RadComboBoxItem In RoomsDropdown.Items
                Dim obj = New With {
                    .RoomId = itm.Value,
                    .RoomName = itm.Text
                }
                selectedRooms.Add(obj)
            Next

            rptRoomTabs.DataSource = selectedRooms
            rptRoomTabs.DataBind()

            'select 1st room
            SelectedRoomHiddenField.Value = RoomsDropdown.Items(0).Value
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-tab", "setRoomTabSelected(" & RoomsDropdown.Items(0).Value & ");", True)

            ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)
            setDayDefaults()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in HospitalDropDownList_Loaded", ex)
        End Try
    End Sub

    Protected Sub ChangeRoomButton_Click(sender As Object, e As EventArgs)
        Try

            If CalendarView = SchedulerViewType.MonthView Or CalendarView = SchedulerViewType.WeekView Then
                AMRadScheduler.EnableViewState = False
                PMRadScheduler.EnableViewState = False
                EVRadScheduler.EnableViewState = False
            End If

            If RoomsDropdown.CheckedItems.Count = 0 Then Exit Sub
            resetSlotCount()

            Dim roomIDs As String = ""
            For Each itm As RadComboBoxItem In RoomsDropdown.CheckedItems
                roomIDs = roomIDs & IIf(roomIDs = Nothing, itm.Value, "," & itm.Value)
                Dim obj = New With {
                    .RoomId = itm.Value,
                    .RoomName = itm.Text
                }
            Next


            'If RoomsDropdown.CheckedItems.Count = 1 Or (RoomsDropdown.CheckedItems.Count > 1 And Not CalendarView = SchedulerViewType.DayView) Then
            RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = HospitalDropDownList.SelectedValue
            RoomsDataSource.SelectParameters("FieldValue").DefaultValue = roomIDs
            'End If

            If CalendarView = SchedulerViewType.DayView Then
                GetDiarySlots(True, SelectedRoomId)
            Else
                rptRoomTabs.DataSource = New DataTable
                rptRoomTabs.DataBind()

                GetDiarySlots(True)
                RoomNameLabel.Text = RoomsDropdown.CheckedItems(0).Text
            End If

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error changing rooms", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error ")
        End Try
    End Sub

    Private Sub setDayDefaults()
        Try

            SundayCheckBox.Checked = False
            SundayMorningCheckBox.Checked = False
            SundayAfternoonCheckBox.Checked = False
            SundayEveningCheckBox.Checked = False

            MondayCheckBox.Checked = False
            MondayMorningCheckBox.Checked = False
            MondayAfternoonCheckBox.Checked = False
            MondayEveningCheckBox.Checked = False

            TuesdayCheckBox.Checked = False
            TuesdayMorningCheckBox.Checked = False
            TuesdayAfternoonCheckBox.Checked = False
            TuesdayEveningCheckBox.Checked = False

            WednesdayCheckBox.Checked = False
            WednesdayMorningCheckBox.Checked = False
            WednesdayAfternoonCheckBox.Checked = False
            WednesdayEveningCheckBox.Checked = False

            ThursdayCheckBox.Checked = False
            ThursdayMorningCheckBox.Checked = False
            ThursdayAfternoonCheckBox.Checked = False
            ThursdayEveningCheckBox.Checked = False

            FridayCheckBox.Checked = False
            FridayMorningCheckBox.Checked = False
            FridayAfternoonCheckBox.Checked = False
            FridayEveningCheckBox.Checked = False

            SaturdayCheckBox.Checked = False
            SaturdayMorningCheckBox.Checked = False
            SaturdayAfternoonCheckBox.Checked = False
            SaturdayEveningCheckBox.Checked = False

            Using db As New ERS.Data.GastroDbEntities
                Dim slotDefaults = (From sd In db.ERS_SCH_FreeSlotDefaults
                                    Where sd.OperatingHospitalId = HospitalDropDownList.SelectedValue
                                    Group sd.AM, sd.PM, sd.EVE By sd.DayOfWeek Into g = Group
                                    Select DayOfWeek, DaySession = g.ToList)

                For Each sd In slotDefaults
                    Select Case sd.DayOfWeek
                        Case 0
                            SundayCheckBox.Checked = True
                            SundayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                            SundayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                            SundayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        Case 1
                            MondayCheckBox.Checked = True
                            MondayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                            MondayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                            MondayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        Case 2
                            TuesdayCheckBox.Checked = True
                            TuesdayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                            TuesdayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                            TuesdayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        Case 3
                            WednesdayCheckBox.Checked = True
                            WednesdayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                            WednesdayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                            WednesdayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        Case 4
                            ThursdayCheckBox.Checked = True
                            ThursdayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                            ThursdayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                            ThursdayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        Case 5
                            FridayCheckBox.Checked = True
                            FridayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                            FridayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                            FridayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                        Case 6
                            SaturdayCheckBox.Checked = True
                            SaturdayMorningCheckBox.Checked = sd.DaySession.Select(Function(x) x.AM).First
                            SaturdayAfternoonCheckBox.Checked = sd.DaySession.Select(Function(x) x.PM).First
                            SaturdayEveningCheckBox.Checked = sd.DaySession.Select(Function(x) x.EVE).First
                    End Select
                Next
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error setting day defaults", ex)
        End Try
    End Sub

#End Region

#Region "Properties and Structures"
    Private Property PageSearchFields As Products_Scheduler.SearchFields
        Get
            Return Session("SearchFields")
        End Get
        Set(value As Products_Scheduler.SearchFields)
            Session("SearchFields") = value
        End Set
    End Property

    ReadOnly Property OperatingHospitalID As Integer
        Get
            Return CInt(HospitalDropDownList.SelectedValue)
        End Get
    End Property

    Structure SlotFields
        Property DiaryId As Object
        Property SlotTime As Object
        Property Endoscopist As Object
        Property RoomId As Object
        Property RoomName As Object
        Property AvailableDate As Object
        Property Template As Object
        Property Reserved As String
        Property SlotType As String
        Property BreachDate As String
    End Structure
#End Region

#Region "Slot Search"

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs)
        Try
            If MoveBookingTR.Visible AndAlso ReasonForMoveDropdown.SelectedValue = 0 Then
                Utilities.SetNotificationStyle(SearchWindowRadNotification, "Please select a move reason", True, "Please correct")
                SearchWindowRadNotification.Show()
                Exit Sub
            End If

            'reset divs
            Dim searchFields As New Products_Scheduler.SearchFields

            Dim operatingHospitals As New List(Of Integer)
            searchFields.OperatingHospitalIds = SearchOperatingHospitalIdRadComboBox.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList
            searchFields.Endo = ""
            searchFields.Gender = "" 'n
            searchFields.ReferalDate = ReferalDateDatePicker.SelectedDate 'n/a
            searchFields.BreachDate = BreachDateDatePicker.SelectedDate 'y
            searchFields.SearchStartDate = SearchDateDatePicker.SelectedDate 'y
            searchFields.Slots = New Dictionary(Of Integer, String) 'y
            searchFields.SearchDays = New List(Of Products_Scheduler.SearchDays) 'filter on return
            searchFields.GIProcedure = True 'y
            searchFields.ReservedSlotsOnly = False 'y
            searchFields.ProcedureTypes = New List(Of Products_Scheduler.SearchProcedure) 'y
            searchFields.SlotLength = LengthOfSlotsNumericTextbox.Value 'y
            searchFields.NonGIProcedureType = Nothing 'n
            searchFields.NonGIDiagnostic = False 'info needed
            searchFields.NonGITherapeutic = False 'info needed
            searchFields.ExcludeTraining = ExcludeTrainingListsCheckBox.Checked

            Dim sProcedureTypesString As String = ""
            Dim sSlotTypesString As String = ""
            Dim sDaysString As String = ""

            For Each itm As RadComboBoxItem In SearchEndoscopistDropdown.CheckedItems
                searchFields.Endo = searchFields.Endo & IIf(searchFields.Endo = Nothing, itm.Value, "," & itm.Value)
            Next

            If Not EndoscopistGenderRadioButtonList.SelectedValue = "0" Then
                searchFields.Gender = EndoscopistGenderRadioButtonList.SelectedValue
            End If

            For Each itm As ListItem In IncludedSlotsCheckBoxList.Items
                If itm.Selected Or AllSlotsCheckBox.Checked Then
                    searchFields.Slots.Add(itm.Value.ToString(), itm.Text)
                End If
            Next

            If MondayCheckBox.Checked Then
                Dim searchDays As New Products_Scheduler.SearchDays
                With searchDays
                    .Day = DayOfWeek.Monday
                    .Morning = MondayMorningCheckBox.Checked
                    .Afternoon = MondayAfternoonCheckBox.Checked
                    .Evening = MondayEveningCheckBox.Checked
                End With
                searchFields.SearchDays.Add(searchDays)
                sDaysString += "Mon"

                If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
                    Dim tod As New List(Of String)
                    If searchDays.Morning Then tod.Add("am")
                    If searchDays.Afternoon Then tod.Add("pm")
                    If searchDays.Evening Then tod.Add("ev")
                    sDaysString += " (" & String.Join("/", tod) & ")"
                End If
                sDaysString += ", "
            End If
            If TuesdayCheckBox.Checked Then
                Dim searchDays As New Products_Scheduler.SearchDays
                With searchDays
                    .Day = DayOfWeek.Tuesday
                    .Morning = TuesdayMorningCheckBox.Checked
                    .Afternoon = TuesdayAfternoonCheckBox.Checked
                    .Evening = TuesdayEveningCheckBox.Checked
                End With
                searchFields.SearchDays.Add(searchDays)
                sDaysString += "Tue"

                If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
                    Dim tod As New List(Of String)
                    If searchDays.Morning Then tod.Add("am")
                    If searchDays.Afternoon Then tod.Add("pm")
                    If searchDays.Evening Then tod.Add("ev")
                    sDaysString += " (" & String.Join("/", tod) & ")"
                End If
                sDaysString += ", "
            End If
            If WednesdayCheckBox.Checked Then
                Dim searchDays As New Products_Scheduler.SearchDays
                With searchDays
                    .Day = DayOfWeek.Wednesday
                    .Morning = WednesdayMorningCheckBox.Checked
                    .Afternoon = WednesdayAfternoonCheckBox.Checked
                    .Evening = WednesdayEveningCheckBox.Checked
                End With
                searchFields.SearchDays.Add(searchDays)
                sDaysString += "Wed"

                If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
                    Dim tod As New List(Of String)
                    If searchDays.Morning Then tod.Add("am")
                    If searchDays.Afternoon Then tod.Add("pm")
                    If searchDays.Evening Then tod.Add("ev")
                    sDaysString += " (" & String.Join("/", tod) & ")"
                End If
                sDaysString += ", "
            End If
            If ThursdayCheckBox.Checked Then
                Dim searchDays As New Products_Scheduler.SearchDays
                With searchDays
                    .Day = DayOfWeek.Thursday
                    .Morning = ThursdayMorningCheckBox.Checked
                    .Afternoon = ThursdayAfternoonCheckBox.Checked
                    .Evening = ThursdayEveningCheckBox.Checked
                End With
                searchFields.SearchDays.Add(searchDays)
                sDaysString += "Thu"

                If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
                    Dim tod As New List(Of String)
                    If searchDays.Morning Then tod.Add("am")
                    If searchDays.Afternoon Then tod.Add("pm")
                    If searchDays.Evening Then tod.Add("ev")
                    sDaysString += " (" & String.Join("/", tod) & ")"
                End If
                sDaysString += ", "
            End If
            If FridayCheckBox.Checked Then
                Dim searchDays As New Products_Scheduler.SearchDays
                With searchDays
                    .Day = DayOfWeek.Friday
                    .Morning = FridayMorningCheckBox.Checked
                    .Afternoon = FridayAfternoonCheckBox.Checked
                    .Evening = FridayEveningCheckBox.Checked
                End With
                searchFields.SearchDays.Add(searchDays)
                sDaysString += "Fri"

                If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
                    Dim tod As New List(Of String)
                    If searchDays.Morning Then tod.Add("am")
                    If searchDays.Afternoon Then tod.Add("pm")
                    If searchDays.Evening Then tod.Add("ev")
                    sDaysString += " (" & String.Join("/", tod) & ")"
                End If
                sDaysString += ", "
            End If
            If SaturdayCheckBox.Checked Then
                Dim searchDays As New Products_Scheduler.SearchDays
                With searchDays
                    .Day = DayOfWeek.Saturday
                    .Morning = SaturdayMorningCheckBox.Checked
                    .Afternoon = SaturdayAfternoonCheckBox.Checked
                    .Evening = SaturdayEveningCheckBox.Checked
                End With
                searchFields.SearchDays.Add(searchDays)
                sDaysString += "Sat"

                If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
                    Dim tod As New List(Of String)
                    If searchDays.Morning Then tod.Add("am")
                    If searchDays.Afternoon Then tod.Add("pm")
                    If searchDays.Evening Then tod.Add("ev")
                    sDaysString += " (" & String.Join("/", tod) & ")"
                End If
                sDaysString += ", "
            End If
            If SundayCheckBox.Checked Then
                Dim searchDays As New Products_Scheduler.SearchDays
                With searchDays
                    .Day = DayOfWeek.Sunday
                    .Morning = SundayMorningCheckBox.Checked
                    .Afternoon = SundayAfternoonCheckBox.Checked
                    .Evening = SundayEveningCheckBox.Checked
                End With
                searchFields.SearchDays.Add(searchDays)
                sDaysString += "Sun"

                If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
                    Dim tod As New List(Of String)
                    If searchDays.Morning Then tod.Add("am")
                    If searchDays.Afternoon Then tod.Add("pm")
                    If searchDays.Evening Then tod.Add("ev")
                    sDaysString += " (" & String.Join("/", tod) & ")"
                End If
                sDaysString += ", "
            End If

            searchFields.GIProcedure = CBool(SearchGIProcedureRadioButtons.SelectedValue)
            searchFields.ReservedSlotsOnly = ShowOnlyReservedSlotsCheckBox.Checked
            searchFields.SlotLength = LengthOfSlotsNumericTextbox.Value 'TODO: ask about this...

            Dim lTherapeuticTypes As New List(Of Integer)

            If searchFields.GIProcedure Then
                For Each item As RepeaterItem In rptProcedureTypes.Items
                    If item.ItemType = ListItemType.Item Or item.ItemType = ListItemType.AlternatingItem Then
                        Dim DiagnosticCheckBox As CheckBox = item.FindControl("DiagnosticProcedureTypesCheckBox")
                        Dim TherapeuticCheckBox As CheckBox = item.FindControl("TherapeuticProcedureTypesCheckBox")

                        If DiagnosticCheckBox.Checked Or TherapeuticCheckBox.Checked Then
                            Dim procedureTypeID = CInt(CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value)
                            Dim procedureType = CType(item.FindControl("ProcedureTypeHiddenField"), HiddenField).Value
                            Dim searchProcedure As New Products_Scheduler.SearchProcedure
                            With searchProcedure
                                .ProcedureTypeID = procedureTypeID
                                .ProcedureType = procedureType
                                .Diagnostic = DiagnosticCheckBox.Checked
                                .Therapeutic = TherapeuticCheckBox.Checked
                                If TherapeuticCheckBox.Checked Then
                                    If Session("SearchTherapeuticTypes_" & procedureTypeID) IsNot Nothing AndAlso Session("SearchTherapeuticTypes_" & procedureTypeID).count > 0 Then
                                        .TherapeuticTypes = CType(Session("SearchTherapeuticTypes_" & procedureTypeID), List(Of Integer))
                                        lTherapeuticTypes.AddRange(.TherapeuticTypes) 'TODO: Sort this out.......... things have changed now, need another way around this!
                                    Else
                                        Utilities.SetNotificationStyle(SearchWindowRadNotification, "Please define therapeutic types", True, "Please correct")
                                        SearchWindowRadNotification.Show()
                                        Exit Sub

                                    End If
                                Else
                                    Session("SearchTherapeuticTypes_" & procedureTypeID) = Nothing
                                End If

                            End With

                            searchFields.ProcedureTypes.Add(searchProcedure)
                        End If
                    End If
                Next
            Else
                If nonGIProceduresDropdown.SelectedIndex > 0 Then
                    Dim searchProcedure As New Products_Scheduler.SearchProcedure
                    With searchProcedure
                        .ProcedureTypeID = nonGIProceduresDropdown.SelectedValue
                        .ProcedureType = nonGIProceduresDropdown.SelectedItem.Text
                        .Diagnostic = DiagnosticsRadioButton.Checked
                        .Therapeutic = TherapeuticRadioButton.Checked
                    End With

                    searchFields.ProcedureTypes.Add(searchProcedure)
                End If

                searchFields.NonGIProcedureType = nonGIProceduresDropdown.SelectedValue
                searchFields.NonGIDiagnostic = DiagnosticsRadioButton.Checked
                searchFields.NonGITherapeutic = TherapeuticRadioButton.Checked
            End If

            If Not searchFields.ReservedSlotsOnly Then searchFields.ProcedureTypes.Add(New Products_Scheduler.SearchProcedure With {.ProcedureTypeID = 0, .Diagnostic = True, .Therapeutic = True})

            Dim da As New DataAccess_Sch
            Dim procTypes = String.Join(",", searchFields.ProcedureTypes.Select(Function(x) x.ProcedureTypeID).ToArray())

            Dim slots = String.Join(",", searchFields.Slots.Keys.ToArray())
            Dim results = da.SearchAvailableSlots(searchFields, ExcludeTrainingListsCheckBox.Checked, lTherapeuticTypes)

            If results.Rows.Count > 0 Then
                NoResultsDiv.Visible = False

                'Get Endo rules to filter results by
                Dim endosForProc As New List(Of Integer)
                Dim endosForTherapType As New List(Of Integer)

                If searchFields.ProcedureTypes.Any(Function(x) x.Diagnostic And x.ProcedureTypeID > 0) Then
                    endosForProc = da.GetEndoscopistsByProcedureTypes(searchFields.ProcedureTypes.Where(Function(x) x.Diagnostic).Select(Function(x) x.ProcedureTypeID).ToList)
                    If endosForProc.Count > 0 AndAlso results.AsEnumerable.Any(Function(x) endosForProc.Contains(x("EndoId")) Or x("EndoId") = 0) Then
                        'only return rows where matched endo is present
                        results = results.AsEnumerable.Where(Function(x) endosForProc.Contains(x("EndoId")) Or x("EndoId") = 0).CopyToDataTable()
                    Else
                        If results.AsEnumerable.Any(Function(x) x("EndoId") = 0) Then
                            results = results.AsEnumerable.Where(Function(x) x("EndoId") = 0).CopyToDataTable()
                        Else
                            results = Nothing
                            'set no rows message to: 
                            NoResultsLabel.Text = "There are no endoscopists available to carry out your chosen procedure(s)"
                        End If
                    End If
                End If

                If results.Rows.Count > 0 Then
                    If searchFields.ProcedureTypes.Any(Function(x) x.TherapeuticTypes IsNot Nothing) Then
                        Dim therapTypeIds As New List(Of Integer)
                        For Each i In searchFields.ProcedureTypes.Where(Function(x) x.TherapeuticTypes IsNot Nothing)
                            therapTypeIds = (From tt In i.TherapeuticTypes Select tt).ToList
                        Next

                        'endosForTherapType = da.GetEndoscopistsByProcedureTherapeutics(therapTypeIds)
                        If endosForTherapType.Count > 0 AndAlso results.AsEnumerable.Any(Function(x) x("EndoId") = 0 Or endosForTherapType.Contains(x("EndoId"))) Then
                            results = results.AsEnumerable.Where(Function(x) x("EndoId") = 0 Or endosForTherapType.Contains(x("EndoId"))).CopyToDataTable
                        Else
                            If results.AsEnumerable.Any(Function(x) x("EndoId") = 0) Then
                                results = results.AsEnumerable.Where(Function(x) x("EndoId") = 0).CopyToDataTable()
                            Else
                                results = New DataTable
                                'set no rows message to: 
                                NoResultsLabel.Text = "There are no endoscopists available to carry out your chosen procedure(s)"
                            End If
                        End If
                    End If
                End If

                If results.Rows.Count > 0 Then
                    Dim roomsForProc As List(Of Integer?)

                    'list of rooms based on procedure type
                    If searchFields.ProcedureTypes.Any(Function(x) x.Diagnostic Or x.Therapeutic) Then
                        roomsForProc = da.GetRoomProcedureTypes(searchFields.ProcedureTypes.Select(Function(x) x.ProcedureTypeID).ToList)
                        If roomsForProc.Count > 0 AndAlso results.AsEnumerable.Any(Function(x) roomsForProc.Contains(x("RoomId"))) Then
                            results = results.AsEnumerable.Where(Function(x) roomsForProc.Contains(x("RoomId"))).CopyToDataTable
                        Else
                            results = New DataTable
                            'set no rows message to: 
                            NoResultsLabel.Text = "There are no rooms available to carry out your chosen procedure(s)"
                        End If
                    End If
                End If

                If results.Rows.Count > 0 Then

                    'get booked slots in order to remove from available slots
                    'Dim dtAppointments = da.GetBookedSlots(searchFields.SearchStartDate, searchFields.BreachDate.AddMonths(6))

                    Dim dt As New DataTable
                    dt.Columns.Add("SlotDate")
                    dt.Columns.Add("SlotTime")
                    dt.Columns.Add("Endoscopist") 'endoscopist
                    dt.Columns.Add("RoomName") 'room name
                    dt.Columns.Add("RoomID") 'room name
                    dt.Columns.Add("Template") 'template
                    dt.Columns.Add("SlotType") 'slot type
                    dt.Columns.Add("Reserved") 'reserved
                    dt.Columns.Add("DiaryId") 'diaryId
                    dt.Columns.Add("OperatingHospitalId") 'operatingHospitalId

                    For i = 0 To DateDiff(DateInterval.Day, searchFields.SearchStartDate, DateAdd(DateInterval.Month, 6, searchFields.SearchStartDate))
                        Dim currDate = searchFields.SearchStartDate.AddDays(i)

                        If currDate.Date <= Now.Date Then Continue For
                        If searchFields.SearchDays.Count > 0 And Not searchFields.SearchDays.Select(Function(x) x.Day).Contains(currDate.DayOfWeek) Then Continue For


                        For Each dr As DataRow In results.Rows 'loops through diaries/slot for the current day
                            'Dim dtGenderSpecificLists As New List(Of ERS.Data.ERS_SCH_GenderList)
                            'If Not String.IsNullOrWhiteSpace(searchFields.Gender) Then dtGenderSpecificLists = da.GetGenderLists(CInt(dr("DiaryId")))

                            'If dtGenderSpecificLists.Any(Function(x) x.DiaryId = CInt(dr("DiaryId")) And x.ListDate.Date = currDate.Date And ((searchFields.Gender.ToLower = "m" And Not x.Male) Or (searchFields.Gender.ToLower = "f" And Not x.Female))) Then Continue For
                            If searchFields.SearchDays IsNot Nothing Then
                                'check time of day filter...

                                Dim skip As Boolean = False

                                If searchFields.SearchDays.Any(Function(x) x.Day = currDate.DayOfWeek And x.Morning = False) Then
                                    If CDate(dr("DiaryStart")).TimeOfDay < New TimeSpan(12, 0, 0) Then 'And CDate(dr("End")).TimeOfDay <= New TimeSpan(12, 0, 0)) Then 'is a morning only slot
                                        skip = True
                                    End If
                                End If

                                If searchFields.SearchDays.Any(Function(x) x.Day = currDate.DayOfWeek And x.Afternoon = False) Then
                                    If (CDate(dr("DiaryStart")).TimeOfDay >= New TimeSpan(12, 0, 0) And CDate(dr("DiaryStart")).TimeOfDay < New TimeSpan(17, 0, 0)) Then 'is an afternoon only slot
                                        skip = True
                                    End If
                                End If

                                If searchFields.SearchDays.Any(Function(x) x.Day = currDate.DayOfWeek And x.Evening = False) Then
                                    If CDate(dr("DiaryStart")).TimeOfDay >= New TimeSpan(17, 0, 0) Then 'And CDate(dr("End")).TimeOfDay >= New TimeSpan(17, 0, 0)) Then
                                        skip = True
                                    End If
                                End If

                                If skip Then Continue For
                            End If

                            PageSearchFields = searchFields

                            If dr.IsNull("RecurrenceRule") OrElse String.IsNullOrWhiteSpace(dr("RecurrenceRule")) Then
                                If CDate(dr("DiaryStart")).ToShortDateString = currDate.ToShortDateString Then
                                    Dim dtRow As DataRow = dt.NewRow()
                                    BuildSlotRow(dr, dtRow, currDate)
                                    If Not dr.IsNull(0) Then dt.Rows.Add(dtRow)
                                End If
                            Else
                                Dim diaryRecurrence As RecurrenceRule
                                If RecurrenceRule.TryParse(dr("RecurrenceRule"), diaryRecurrence) Then
                                    If diaryRecurrence.HasOccurrences Then
                                        If diaryRecurrence.Occurrences.Any(Function(x) x.Date = currDate.Date) Then
                                            Dim dtRow As DataRow = dt.NewRow()
                                            BuildSlotRow(dr, dtRow, currDate)
                                            If Not dtRow.IsNull(0) Then dt.Rows.Add(dtRow)
                                        End If
                                    End If
                                End If
                            End If
                        Next
                    Next

                    'grouping by diary id and date, get a list of restricted days; weather they be patient appointments, locked diaries or for the oposite selected gender (if any). Then can remove the "DiarysAvailableSlots" call within the BuildSlotRow method
                    Dim slotsDT = (From dr In dt.Rows
                                   Group diaryDate = CDate(dr("SlotDate")) By diaryId = CInt(dr("DiaryId")), slotTime = dr("SlotTime") Into dates = Group
                                   Select diaryId, slotTime, slotDates = dates.ToList)

                    For Each slot In slotsDT
                        Dim iDiaryId = slot.diaryId
                        'get restrictions for diaryId....

                        'locked diaries
                        Dim lockedDiaries = DataAdapter_Sch.GetLockedDiaries(iDiaryId)
                        If lockedDiaries IsNot Nothing AndAlso lockedDiaries.AsEnumerable.Count(Function(x) CDate(x("DiaryDate")) >= searchFields.SearchStartDate) > 0 Then
                            lockedDiaries = lockedDiaries.AsEnumerable.Where(Function(x) CDate(x("DiaryDate")) >= searchFields.SearchStartDate).CopyToDataTable
                            For Each diary As DataRow In lockedDiaries.Rows
                                Dim rowToRemove As DataRow = Nothing
                                If CBool(diary("AM")) = True Then
                                    rowToRemove = dt.AsEnumerable.Where(Function(x) x("DiaryId") = iDiaryId And CDate(x("SlotDate")) = diary.Field(Of DateTime)("DiaryDate") And TimeSpan.Parse(x("SlotTime").ToString().Split("-")(0).Trim) < New TimeSpan(12, 0, 0)).FirstOrDefault
                                ElseIf CBool(diary("PM")) = True Then
                                    rowToRemove = dt.AsEnumerable.Where(Function(x) x("DiaryId") = iDiaryId And CDate(x("SlotDate")) = diary.Field(Of DateTime)("DiaryDate") And (TimeSpan.Parse(x("SlotTime").ToString().Split("-")(0).Trim) >= New TimeSpan(12, 0, 0) And TimeSpan.Parse(x("SlotTime").ToString().Split("-")(0).Trim) < New TimeSpan(17, 0, 0))).FirstOrDefault
                                ElseIf CBool(diary("EVE")) = True Then
                                    rowToRemove = dt.AsEnumerable.Where(Function(x) x("DiaryId") = iDiaryId And CDate(x("SlotDate")) = diary.Field(Of DateTime)("DiaryDate") And TimeSpan.Parse(x("SlotTime").ToString().Split("-")(0).Trim) >= New TimeSpan(17, 0, 0)).FirstOrDefault
                                End If

                                If rowToRemove IsNot Nothing Then dt.Rows.Remove(rowToRemove)
                            Next
                        End If

                        'gender lists
                        If Not String.IsNullOrWhiteSpace(searchFields.Gender) Then
                            Dim genderSpecificDiaries = DataAdapter_Sch.GetGenderLists(iDiaryId)
                            If genderSpecificDiaries IsNot Nothing AndAlso genderSpecificDiaries.Any(Function(x) x.ListDate > searchFields.SearchStartDate.Date) Then
                                genderSpecificDiaries = genderSpecificDiaries.Where(Function(x) x.ListDate > searchFields.SearchStartDate.Date).ToList
                                For Each diary In genderSpecificDiaries
                                    If (searchFields.Gender.ToUpper = "M" And diary.Male = False) Or (searchFields.Gender.ToUpper = "F" And diary.Female = False) Then
                                        Dim rowToRemove = dt.AsEnumerable.Where(Function(x) x("DiaryId") = iDiaryId And CDate(x("SlotDate")).Date = diary.ListDate.Date).FirstOrDefault
                                        If rowToRemove IsNot Nothing Then dt.Rows.Remove(rowToRemove)
                                    End If
                                Next
                            End If
                        End If

                        'appointments
                        Dim diaryAppointments = (From a In DataAdapter_Sch.getdiaryAppointments(iDiaryId, searchFields.SearchStartDate.Date)
                                                 Group appointmentTimes = a("StartDateTime") By appointmentDate = CDate(a("StartDateTime")).Date Into d = Group
                                                 Select appointmentDate, times = d.ToList)


                        For Each apt In diaryAppointments
                            Dim result = DiarysAvailableSlots(iDiaryId, apt.appointmentDate.Date)
                            If result.Count = 0 Then
                                Dim rowToRemove = dt.AsEnumerable.Where(Function(x) x("DiaryId") = iDiaryId And CDate(x("SlotDate")).Date = apt.appointmentDate.Date).FirstOrDefault
                                If rowToRemove IsNot Nothing Then dt.Rows.Remove(rowToRemove)
                            End If
                        Next
                    Next


                    Dim qry = (From dr In dt.Rows
                               Group RoomID = dr("RoomID"), AvailableDate = dr("SlotDate"), SlotTime = dr("SlotTime"), Endoscopist = dr("Endoscopist"), RoomName = dr("RoomName"), Template = dr("Template"), Reserved = dr("Reserved"), SlotType = dr("SlotType"), DiaryId = dr("DiaryId") By SlotDate = dr("SlotDate") Into details = Group
                               Select SlotDate, details).ToList()

                    If qry.Count > 0 Then
                        AvailableSlotsResultsRepeater.DataSource = qry
                        AvailableSlotsResultsRepeater.DataBind()

                        For i As Integer = 0 To AvailableSlotsResultsRepeater.Items.Count - 1
                            Dim item As RepeaterItem = AvailableSlotsResultsRepeater.Items(i)
                            If Not item.ItemType = ListItemType.Item And Not item.ItemType = ListItemType.AlternatingItem Then Continue For

                            'Dim childGrid = CType(item.FindControl("rptSlots"), Repeater)
                            Dim childGrid = CType(item.FindControl("SlotsRadGrid"), RadGrid)

                            Dim lblSlotDate = CType(item.FindControl("SlotDateLabel"), Label).Text

                            If searchFields.BreachDate.Date > Now.Date AndAlso CDate(lblSlotDate) > searchFields.BreachDate Then
                                CType(item.FindControl("SlotDateLabel"), Label).ForeColor = Drawing.Color.Red
                                childGrid.CssClass += " breached-grid"

                                Dim GoToDateLinkButton = CType(item.FindControl("SlotsRadGrid").FindControl("GoToDateLinkButton"), LinkButton)
                                If GoToDateLinkButton IsNot Nothing Then
                                    GoToDateLinkButton.Attributes.Add("onclick", "javascript:Return confirm('Booking will take you past the breach date for this slot type. Continue?';)")
                                End If
                            End If


                            If Session("SlotSearchMode") = "w" Then
                                CType(item.FindControl("SlotsRadGrid"), RadGrid).MasterTableView.Columns(7).Visible = True
                            Else
                                CType(item.FindControl("SlotsRadGrid"), RadGrid).MasterTableView.Columns(7).Visible = False
                            End If


                            Dim qrySlots = qry.Where(Function(x) x.SlotDate = lblSlotDate).FirstOrDefault
                            Dim groupedSlots = (From q In qry.Where(Function(x) x.SlotDate = lblSlotDate).FirstOrDefault.details
                                                Group q.SlotType, q.Reserved By q.DiaryId, q.AvailableDate, q.SlotTime, q.Endoscopist, q.RoomID, q.RoomName, q.Template Into slotDetails = Group
                                                Let Reserved = If(slotDetails.Any(Function(x) x.Reserved = ""), "All", String.Join(", ", slotDetails.Select(Function(x) x.Reserved).Distinct))
                                                Select DiaryId, SlotTime, Endoscopist, RoomID, RoomName, AvailableDate, Template, Reserved, SlotType = String.Join(", ", slotDetails.Select(Function(x) x.SlotType).Distinct)).ToList()


                            childGrid.DataSource = groupedSlots
                            childGrid.DataBind()
                        Next

                    Else
                        AvailableSlotsResultsRepeater.DataSource = Nothing
                        AvailableSlotsResultsRepeater.DataBind()
                        NoResultsDiv.Visible = True
                        If String.IsNullOrEmpty(NoResultsLabel.Text) Then NoResultsLabel.Text = "No results found" 'Label text may have been set previously by specific rules failing. If not, set to default
                    End If
                Else
                    AvailableSlotsResultsRepeater.DataSource = Nothing
                    AvailableSlotsResultsRepeater.DataBind()
                    NoResultsDiv.Visible = True
                    If String.IsNullOrEmpty(NoResultsLabel.Text) Then NoResultsLabel.Text = "No results found" 'Label text may have been set previously by specific rules failing. If not, set to default
                End If
            Else
                AvailableSlotsResultsRepeater.DataSource = Nothing
                AvailableSlotsResultsRepeater.DataBind()
                NoResultsDiv.Visible = True
                If String.IsNullOrEmpty(NoResultsLabel.Text) Then NoResultsLabel.Text = "No results found" 'Label text may have been set previously by specific rules failing. If not, set to default
            End If

            divResults.Visible = True
            divFilters.Visible = False
            SearchCriteriaProcedureGITypeLabel.Text = SearchGIProcedureRadioButtons.SelectedItem.Text

            'build criteria table for results section
            SCEndoscopistLabel.Text = If(String.IsNullOrWhiteSpace(searchFields.Endo), "All", If(SearchEndoscopistDropdown.CheckedItems.Count = 1, SearchEndoscopistDropdown.CheckedItems(0).Text, SearchEndoscopistDropdown.CheckedItems(0).Text & " + " & SearchEndoscopistDropdown.CheckedItems.Count - 1 & " more"))
            SCProceduresLabel.Text = If(searchFields.ProcedureTypes.Count = 0, "All", String.Join(",", searchFields.ProcedureTypes.Where(Function(x) x.ProcedureTypeID > 0).Select(Function(x) x.ProcedureType)))

            Dim searchProcedureTypes = searchFields.ProcedureTypes.Where(Function(x) x.ProcedureTypeID > 0).Select(Function(x) x.ProcedureTypeID)

            For Each item In searchProcedureTypes
                Session("SearchProcedureTypes_" & item) = item
            Next

            Session("SearchProcedureTypes") = searchProcedureTypes.Any()

            SCSlotTypeLabel.Text = If(AllSlotsCheckBox.Checked, "All", String.Join(",", searchFields.Slots.Values.ToArray()))
            SCGenderLabel.Text = If(String.IsNullOrWhiteSpace(searchFields.Gender), "All", If(searchFields.Gender.ToLower = "f", "Female", "Male"))
            SCReferralDateLabel.Text = searchFields.ReferalDate
            SCBreachDateLabel.Text = searchFields.BreachDate
            SCSearchFromDateLabel.Text = searchFields.SearchStartDate
            SCDaysLabel.Text = If(String.IsNullOrWhiteSpace(sDaysString), "All", sDaysString.Remove(sDaysString.Trim().Length - 1))

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("SearchButton_Click: Error occured while searching for available slots.", ex)

            Utilities.SetErrorNotificationStyle(SearchWindowRadNotification, errorLogRef, "There was an error displaying search results.")
            SearchWindowRadNotification.Show()
        End Try
    End Sub


    Private Sub BuildSlotRow(ByVal dr As DataRow, ByRef newRow As DataRow, currDate As DateTime, Optional FilteredGender As String = "")
        Try
            Dim slotDateTime = currDate.ToShortDateString & " " & CDate(dr("DiaryStart")).ToShortTimeString()

            'Dim result = DiarysAvailableSlots(CInt(dr("DiaryId")), currDate.ToShortDateString)
            'If result.Count = 0 Then Exit Sub

            newRow("SlotDate") = currDate.ToString("ddd dd MMM yyyy")
            newRow("SlotTime") = CDate(dr("DiaryStart")).ToShortTimeString() & "-" & CDate(dr("End")).ToShortTimeString()
            newRow("Endoscopist") = dr("Endoscopist")
            newRow("RoomName") = dr("RoomName")
            newRow("RoomID") = dr("RoomId")
            newRow("Template") = dr("ListName") & If(CBool(dr("Training")), " (training)", "")
            newRow("SlotType") = dr("SlotType")
            newRow("Reserved") = dr("ProcedureType")
            newRow("DiaryId") = dr("DiaryId")
            newRow("OperatingHospitalId") = dr("OperatingHospitalId")
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("BuildSlotRow:  " + ex.ToString(), ex)
            Utilities.SetErrorNotificationStyle(SearchWindowRadNotification, errorLogRef, "There is a problem with your request.")
            SearchWindowRadNotification.Show()
        End Try
    End Sub

    Protected Sub rptProcedureTypes_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        'clear any previously created sessions (this gets created in the therapeutic types window on save and close
        If e.Item.DataItem IsNot Nothing Then
            Dim dataRow = DirectCast(e.Item.DataItem, DataRowView)
            Dim procTypeID = dataRow.Row("ProcedureTypeID")
            Session("SearchTherapeuticType_" & procTypeID) = Nothing

            'hide checkbox for ERCP diagnostic
            If CBool(dataRow("SchedulerDiagnostic")) = False Then
                CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Visible = False
            End If

            If CBool(dataRow("SchedulerTherapeutic")) = False Then
                CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Visible = False
            End If
        End If
    End Sub

    Protected Sub ChangeSearchCriteriaButton_Click(sender As Object, e As EventArgs)
        divResults.Visible = False
        divFilters.Visible = True

        If PageSearchFields.ProcedureTypes IsNot Nothing AndAlso PageSearchFields.ProcedureTypes.Count > 0 Then
            For Each procType In PageSearchFields.ProcedureTypes
                If procType.ProcedureTypeID = 0 Then Continue For
                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "setproc" & procType.ProcedureTypeID & "points", "calculateSlotLength(" & procType.ProcedureTypeID & ", 'true','true');", True)
            Next
        End If

        For Each itm As RepeaterItem In rptProcedureTypes.Items
            CType(itm.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = (CType(itm.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked)
        Next
        'procedureChanged(checked_ctrl) **need to call this passing in the selected procedure type to set the length of slot value
    End Sub

    Protected Sub SlotsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Try
            If e.CommandName = "GoToDate" Then
                Dim RoomID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoomID")
                RoomsDropdown.SelectedValue = RoomID
                ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)

                ListRadScheduler.SelectedView = SchedulerViewType.DayView
                ListRadScheduler.SelectedDate = DateTime.Parse(e.CommandArgument)
            ElseIf e.CommandName = "SelectSlot" Then
                Dim RoomID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoomID")
                Dim diaryId = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiaryId")
                Dim slotDate = CDate(e.CommandArgument).ToShortDateString

                BookingSlotDateLabel.Text = "Choose slot for " & CDate(e.CommandArgument).ToLongDateString

                ListSlotsRadGrid.DataSource = DiarysAvailableSlots(diaryId, slotDate)
                ListSlotsRadGrid.DataBind()
                ScriptManager.RegisterStartupScript(Me.Page, Me.Page.GetType, "selectSlotWindow", "ShowBookingWindow();", True)
            ElseIf e.CommandName = "RejectSlot" Then
                e.Item.BackColor = Drawing.Color.Red
                ' Have to add something here that allows 3 rejects then can't book any more.
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on list schedules page.", ex)
            Utilities.SetErrorNotificationStyle(SearchWindowRadNotification, errorLogRef, "There is a problem with your request.")
            SearchWindowRadNotification.Show()
        End Try
    End Sub

    Protected Sub RoomsDropdown_TemplateNeeded(sender As Object, e As RadComboBoxItemEventArgs)
        Dim ddl = CType(sender, RadComboBox)
        If ddl.Items.Count > 0 Then
            ddl.Items(0).Checked = True
            ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)
            RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = HospitalDropDownList.SelectedValue
            RoomsDataSource.SelectParameters("FieldValue").DefaultValue = ddl.Items(0).Value

            ListRadScheduler.SelectedView = SchedulerViewType.DayView
            AMRadScheduler.SelectedView = SchedulerViewType.DayView
            PMRadScheduler.SelectedView = SchedulerViewType.DayView
            EVRadScheduler.SelectedView = SchedulerViewType.DayView
        End If
    End Sub
#End Region

    Protected Sub ConfirmDeleteBookingRadButton_Click(sender As Object, e As EventArgs)
        'ConfirmDeleteBookingRadButton_Click
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim appointment = db.ERS_Appointments.Find(CInt(PatientAppointmentIDHiddenField.Value))
                appointment.AppointmentStatusId = 4
                appointment.CancelReasonId = CancellationReasonRadComboBox.SelectedValue
                appointment.StaffCancelledId = CInt(Session("PKUserId"))
                appointment.DateCancelled = Now

                If chkReturnToWaitlist.Checked Then
                    Dim waitlistRecord = db.ERS_Waiting_List.Find(appointment.WaitingListId)
                    If waitlistRecord IsNot Nothing Then waitlistRecord.WaitingListStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "R").FirstOrDefault.UniqueId
                End If

                db.SaveChanges()
            End Using

            Utilities.SetNotificationStyle(DeleteBookingRadNotification, "Booking cancelled.", False)
            DeleteBookingRadNotification.Show()

            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "booking-cancelled", "closeRadWindow();", True)
            ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)

            'Session("BookedDate") = Nothing
            'Session("BookedHospitalId") = Nothing
            'Session("BookedRoom") = Nothing

            'setRoom()
            'setDate(If(CalendarView = SchedulerViewType.DayView, AMRadScheduler.SelectedDate, ListRadScheduler.SelectedDate))
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured deleting patient appointment.", ex)
            Utilities.SetErrorNotificationStyle(DeleteBookingRadNotification, errorLogRef, "There is a problem deleting patient booking.")
            DeleteBookingRadNotification.Show()
        End Try
    End Sub

    Sub bookingSaved()
        Dim i = 0
    End Sub

    Protected Sub ListRadScheduler_AppointmentContextMenuItemClicked(sender As Object, e As AppointmentContextMenuItemClickedEventArgs)
        Try
            'Need to know which session (AM/PM/EVE) the appt was selected in
            'in order to determine which gender list we should be looking at.
            Session("DaySessionName") = Left(sender.ID, 2)

            If e.MenuItem.Value.ToLower = "gotodate" Then

                'Dim selectedRooms As New List(Of Object)

                'For Each itm As RadComboBoxItem In RoomsDropdown.Items
                '    Dim obj = New With {
                '        .RoomId = itm.Value,
                '        .RoomName = itm.Text
                '    }
                '    selectedRooms.Add(obj)
                'Next

                'rptRoomTabs.DataSource = selectedRooms
                'rptRoomTabs.DataBind()

                ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)


                'SelectedRoomHiddenField.Value = RoomsDropdown.Items(0).Value
                'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-tab", "setRoomTabSelected(" & SelectedRoomId & ");", True)
            ElseIf e.MenuItem.Value.ToLower = "movebooking" Then
                Session("SlotSearchMode") = "m"

                ''Procedure types
                rptProcedureTypes.DataBind()

                enableDisableControls(False)
                resetFilters()
                setDayDefaults()

                divResults.Visible = False
                divWaitlist.Visible = False
                divWaitDetails.Visible = False
                divOrderDetails.Visible = False
                divFilters.Visible = True
                MoveBookingTR.Visible = True

                ReasonForMoveDropdown.DataSource = DataAdapter_Sch.GetCancellationReasons()
                ReasonForMoveDropdown.DataBind()
                ReasonForMoveDropdown.Items.Insert(0, New RadComboBoxItem("", 0))
                ReasonForMoveDropdown.SelectedValue = 0

                Dim appointmentId = SelectedApppointmentId.Value

                Using db As New ERS.Data.GastroDbEntities
                    Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault

                    ''Priority/Status 
                    IncludedSlotsCheckBoxList.SelectedValue = appointment.PriorityiD
                    ReferalDateDatePicker.SelectedDate = appointment.ReferralDate
                    For Each itm As RepeaterItem In rptProcedureTypes.Items
                        Dim procedureTypeId = CType(itm.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value
                        Dim bookingProcedureType = db.ERS_AppointmentProcedureTypes.Where(Function(x) x.AppointmentID = appointment.AppointmentId And x.ProcedureTypeID = procedureTypeId).FirstOrDefault

                        If bookingProcedureType IsNot Nothing Then

                            If bookingProcedureType.IsTherapeutic Then
                                Dim bookingTherapeutics = (From at In db.ERS_AppointmentTherapeutics
                                                           Join tt In db.ERS_TherapeuticTypes On at.TherapeuticTypeID Equals tt.Id
                                                           Where at.AppointmentID = appointment.AppointmentId)

                                'set therapeutic types
                                Dim procType As ProcedureType = bookingProcedureType.ProcedureTypeID
                                Select Case procType
                                    Case ProcedureType.Gastroscopy, ProcedureType.EUS_OGD
                                        Session("SearchTherapeuticTypes_" & bookingProcedureType.ProcedureTypeID) = bookingTherapeutics.Where(Function(x) x.tt.OGD = True).Select(Function(x) x.at.TherapeuticTypeID).ToList()

                                    Case ProcedureType.ERCP, ProcedureType.EUS_HPB
                                        Session("SearchTherapeuticTypes_" & bookingProcedureType.ProcedureTypeID) = bookingTherapeutics.Where(Function(x) x.tt.ERCP = True).Select(Function(x) x.at.TherapeuticTypeID).ToList()

                                    Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy, ProcedureType.Proctoscopy
                                        Session("SearchTherapeuticTypes_" & bookingProcedureType.ProcedureTypeID) = bookingTherapeutics.Where(Function(x) x.tt.Colon = True).Select(Function(x) x.at.TherapeuticTypeID).ToList()

                                    Case ProcedureType.Flexi
                                        Session("SearchTherapeuticTypes_" & bookingProcedureType.ProcedureTypeID) = bookingTherapeutics.Where(Function(x) x.tt.Flexi = True).Select(Function(x) x.at.TherapeuticTypeID).ToList()

                                End Select
                                CType(itm.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = True
                            Else
                                CType(itm.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Checked = True
                            End If


                            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "setSlotLength", "calculateSlotLength(" & procedureTypeId & ", 'true')", True)
                        End If
                    Next
                End Using
                Session("AppointmentId") = appointmentId

                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "MoveBookingScript", "moveBooking();", True)
            End If

        Catch ex As Exception
            Dim errorMsg = "An unexpected error occured"

            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, errorMsg)
        End Try
    End Sub

    Protected Sub btnReload_Click(sender As Object, e As EventArgs)

        divResults.Visible = False
        divFilters.Visible = False

        Try

            If Not String.IsNullOrWhiteSpace(btnReload.CommandName) And Not String.IsNullOrWhiteSpace(btnReload.CommandArgument) Then
                If Not CalendarView = SchedulerViewType.DayView Then
                    AMRadScheduler.EnableViewState = False
                    PMRadScheduler.EnableViewState = False
                    EVRadScheduler.EnableViewState = False
                End If
                Session("BookedRoom") = CInt(btnReload.CommandName)
                Session("BookedDate") = CDate(btnReload.CommandArgument)
                Session("CalendarView") = "day"

                changeCalendarView()
                btnReload.CommandArgument = ""
                btnReload.CommandName = ""


            End If

            If Not String.IsNullOrWhiteSpace(Session("BookedRoom")) Then
                For Each itm As RadComboBoxItem In RoomsDropdown.Items
                    itm.Checked = False
                Next

                HospitalDropDownList.SelectedValue = If(Session("BookedHospitalId"), OperatingHospitalID)

                RoomsDropdown.Items.Clear()
                RoomsDropdown.DataSource = DataAdapter_Sch.GetHospitalRooms(If(Session("BookedHospitalId"), OperatingHospitalID))
                RoomsDropdown.DataBind()

                If Not CalendarView = SchedulerViewType.DayView Then
                    AMRadScheduler.EnableViewState = False
                    PMRadScheduler.EnableViewState = False
                    EVRadScheduler.EnableViewState = False
                End If

                'set selected room
                RoomsDropdown.FindItemByValue(If(Session("BookedRoom"), SelectedRoomId)).Checked = True
                Session("CalendarView") = "day"
                changeCalendarView()
                SelectedRoomHiddenField.Value = Session("BookedRoom")

                SetSelectedRoomRadButton_Click(Nothing, Nothing)
            End If

            If Not String.IsNullOrWhiteSpace(Session("BookedDate")) Then setDate(CDate(Session("BookedDate")))

            ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-tab", "setRoomTabSelected(" & SelectedRoomId & ");", True)

            If Session("BookedAppointmentId") IsNot Nothing Then
                If AMRadScheduler.Appointments.Any(Function(x) x.Attributes("appointmentId") IsNot Nothing AndAlso x.Attributes("appointmentId") = CInt(Session("BookedAppointmentId"))) Then
                    AMRadScheduler.Appointments.Where(Function(x) x.Attributes("appointmentId") IsNot Nothing AndAlso x.Attributes("appointmentId") = CInt(Session("BookedAppointmentId"))).FirstOrDefault.CssClass += " selected-appointment"
                ElseIf PMRadScheduler.Appointments.Any(Function(x) x.Attributes("appointmentId") IsNot Nothing AndAlso x.Attributes("appointmentId") = CInt(Session("BookedAppointmentId"))) Then
                    PMRadScheduler.Appointments.Where(Function(x) x.Attributes("appointmentId") IsNot Nothing AndAlso x.Attributes("appointmentId") = CInt(Session("BookedAppointmentId"))).FirstOrDefault.CssClass += " selected-appointment"
                ElseIf EVRadScheduler.Appointments.Any(Function(x) x.Attributes("appointmentId") IsNot Nothing AndAlso x.Attributes("appointmentId") = CInt(Session("BookedAppointmentId"))) Then
                    EVRadScheduler.Appointments.Where(Function(x) x.Attributes("appointmentId") IsNot Nothing AndAlso x.Attributes("appointmentId") = CInt(Session("BookedAppointmentId"))).FirstOrDefault.CssClass += " selected-appointment"
                End If
                Session("BookedAppointmentId") = Nothing
            End If

            Session("BookedDate") = Nothing
            Session("BookedHospitalId") = Nothing
            Session("BookedRoom") = Nothing

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error reloading diaries. room:" &
                                                   If(Session("BookedRoom"), "") & " hospital:" &
                                                   If(Session("BookedHospitalId"), OperatingHospitalID) & " date:" &
                                                   If(Session("BookedDate"), ""), ex)
            Utilities.SetNotificationStyle(RadNotification1, "There was a problem reloading the diary(s). Please refresh the page")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub AvailableSlotsResultsRepeater_ItemCreated(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim childGrid = e.Item.FindControl("SlotsRadGrid")
            If childGrid IsNot Nothing Then
                Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
                'myAjaxMgr.AjaxSettings.AddAjaxSetting(childGrid, childGrid)
            End If
        End If
    End Sub

    Protected Sub rptSlots_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem = Nothing Then Exit Sub
    End Sub

    Protected Sub ListSlotsRadGrid_ItemCreated(sender As Object, e As GridItemEventArgs)
        If TypeOf e.Item Is GridDataItem Then
            Dim diaryId As Integer = DataBinder.Eval(e.Item.DataItem, "DiaryId")

            Dim mode = "add"
            Select Case Session("SlotSearchMode")
                Case "w"
                    mode = "waitlist"
                Case "m"
                    mode = "move"
                    'diaryId = Session("AppointmentId")
                Case Else
                    mode = "add"
            End Select

            Dim BookSlotRadButton As LinkButton = DirectCast(e.Item.FindControl("BookSlotRadButton"), LinkButton)
            BookSlotRadButton.Attributes("href") = "javascript:void(0);"
            BookSlotRadButton.Attributes("onclick") = String.Format("return BookSlot({0},'{1}',{2},{3},{4},'{5}',{6},{7},{8});", diaryId, DataBinder.Eval(e.Item.DataItem, "StartDate"), DataBinder.Eval(e.Item.DataItem, "RoomId"), DataBinder.Eval(e.Item.DataItem, "ProcedureTypeId"), DataBinder.Eval(e.Item.DataItem, "StatusId"), mode, DataBinder.Eval(e.Item.DataItem, "OperatingHospitalId"), DataBinder.Eval(e.Item.DataItem, "SlotDuration"), DataBinder.Eval(e.Item.DataItem, "SlotPoints"))
        End If
    End Sub

    Protected Sub FindAvailableSlotRadButton_Click(sender As Object, e As EventArgs)
        Session("SlotSearchMode") = "s"

        setDayDefaults()
        enableDisableControls(True)
        resetFilters()

        MoveBookingTR.Visible = False
        divResults.Visible = False
        divWaitlist.Visible = False
        divWaitDetails.Visible = False
        divOrderDetails.Visible = False
        divFilters.Visible = True
    End Sub

    Protected Sub ListSlotsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        If e.CommandName = "GoToDate" Then
            Dim RoomID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoomID")
            Dim BookedDate = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("StartDate")
            RoomsDropdown.SelectedValue = RoomID
            ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)

            ListRadScheduler.SelectedView = SchedulerViewType.DayView
            ListRadScheduler.SelectedDate = DateTime.Parse(e.CommandArgument)
        ElseIf e.CommandName.ToLower.Contains("jumptobookedslot") Then
            Dim params = e.CommandArgument.Split(",")(1)
            Dim roomId = CInt(params.Split("|")(0))
            Dim bookedDate = CDate(params.Split("|")(1))

            RoomsDropdown.SelectedValue = roomId
            ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)

            ListRadScheduler.SelectedView = SchedulerViewType.DayView
            ListRadScheduler.SelectedDate = bookedDate
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs)
        If e.Argument.ToLower.Contains("gotodate") Then
            Dim params = e.Argument.Split(",")(1)
            Dim roomId = CInt(params.Split("|")(0))
            Dim bookedDate = CDate(params.Split("|")(1))

            RoomsDropdown.SelectedValue = roomId
            ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)

            ListRadScheduler.SelectedView = SchedulerViewType.DayView
            ListRadScheduler.SelectedDate = bookedDate
        End If
    End Sub

    Protected Sub BookFromWaitlistRadButton_Click(sender As Object, e As EventArgs)
        Try
            setDayDefaults()
            enableDisableControls(True)
            resetFilters()

            LoadWaitlistGrids()

            'Dim plannedWaitlistPatients = waitList.AsEnumerable.Where(Function(x) Not x.IsNull("AdmissionTypeId") AndAlso x("AdmissionTypeId") = 2)
            'If plannedWaitlistPatients.Count > 0 Then
            '    PlannedWaitlistRadGrid.DataSource = plannedWaitlistPatients.CopyToDataTable
            '    PlannedWaitlistRadGrid.DataBind()
            'Else
            '    PlannedWaitlistRadGrid.DataSource = Nothing
            '    PlannedWaitlistRadGrid.DataBind()
            'End If




            divResults.Visible = False
            divWaitlist.Visible = True
            divWaitDetails.Visible = False
            divOrderDetails.Visible = False
            divFilters.Visible = False
        Catch ex As Exception
            Dim errorMsg = "Error changing to " & CalendarView.ToString.ToLower & " view"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub LoadWaitlistGrids()
        Dim da As New DataAccess_Sch
        Dim waitList = da.GetWaitlistPatients(OperatingHospitalID)
        Dim waitlistPatients = waitList.AsEnumerable.Where(Function(x) Not x.IsNull("AdmissionTypeId") AndAlso x("AdmissionTypeId") = 1)
        If waitlistPatients.Count > 0 Then
            WaitListGrid.DataSource = waitlistPatients.CopyToDataTable
            WaitListGrid.DataBind()
        Else
            WaitListGrid.DataSource = Nothing
            WaitListGrid.DataBind()
        End If


        'MH commented out on 07 Sept 2021 - No need any more. Order comms taken to new menu page

        btnSearchSlotFromWorklist.Visible = False
        btnSearchSlotFromOrder.Visible = False
        btnShowOrdersDetail.Visible = False
        btnShowWorklistDetail.Visible = False
        btnMoveToWorklist.Visible = False

        'Dim OrdersPatients = da.GetOrderList(OperatingHospitalID)
        'If OrdersPatients.Rows.Count > 0 Then
        '    OrdersRadGrid.DataSource = OrdersPatients
        '    OrdersRadGrid.DataBind()
        'Else
        '    OrdersRadGrid.DataSource = Nothing
        '    OrdersRadGrid.DataBind()
        'End If
    End Sub

    Protected Sub btnSearchSlotFromWorklist_Click(sender As Object, e As EventArgs)
        Dim waitlistId = WaitListGrid.MasterTableView.DataKeyValues(WaitListGrid.SelectedIndexes(0))("WaitingListId")
        Dim dataKeyValues = WaitListGrid.MasterTableView.DataKeyValues(WaitListGrid.SelectedIndexes(0))

        searchSlotFromList(waitlistId, dataKeyValues)
    End Sub

    Protected Sub searchSlotFromList(waitlistId As Integer, dataKeyValues As Object)
        Try
            Session("SlotSearchMode") = "w"

            divResults.Visible = False
            divWaitlist.Visible = False
            divWaitDetails.Visible = False
            divOrderDetails.Visible = False
            divFilters.Visible = True

            rptProcedureTypes.DataBind()
            IncludedSlotsCheckBoxList.DataBind()


            If waitlistId > 0 Then

                Session("WaitlistId") = waitlistId
                Dim procedureId As Integer
                Dim diagnosticProcedure As Boolean
                Dim therapeuticProcedure As Boolean

                Dim DefaultdiagnosticProcedure As Boolean
                Dim DefaulttherapeuticProcedure As Boolean

                Dim priorityId As Integer
                Dim referralDate As DateTime? = Nothing

                If Not String.IsNullOrWhiteSpace(dataKeyValues("ProcedureTypeId")) Then procedureId = dataKeyValues("ProcedureTypeId")
                If Not String.IsNullOrWhiteSpace(dataKeyValues("DiagnosticProcedure")) Then diagnosticProcedure = CBool(dataKeyValues("DiagnosticProcedure"))
                If Not String.IsNullOrWhiteSpace(dataKeyValues("TherapeuticProcedure")) Then therapeuticProcedure = CBool(dataKeyValues("TherapeuticProcedure"))

                If Not String.IsNullOrWhiteSpace(dataKeyValues("DefaultSchedulerDiagnostic")) Then DefaultdiagnosticProcedure = CBool(dataKeyValues("DefaultSchedulerDiagnostic"))
                If Not String.IsNullOrWhiteSpace(dataKeyValues("DefaultSchedulerTherapeutic")) Then DefaulttherapeuticProcedure = CBool(dataKeyValues("DefaultSchedulerTherapeutic"))


                If Not String.IsNullOrWhiteSpace(dataKeyValues("PriorityId")) Then priorityId = CInt(dataKeyValues("PriorityId"))
                If Not String.IsNullOrWhiteSpace(dataKeyValues("DateRaised")) Then referralDate = CDate(dataKeyValues("DateRaised"))

                If procedureId > 0 Then
                    For Each item As RepeaterItem In rptProcedureTypes.Items
                        If CInt(CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value) = procedureId Then
                            If diagnosticProcedure Then
                                CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Checked = True
                            ElseIf therapeuticProcedure Then
                                CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = True
                            End If

                            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "procedure-length", "calculateSlotLength(" & procedureId & ", true);", True)

                            Exit For
                        End If
                    Next

                End If

                If priorityId > 0 Then
                    For Each itm As ListItem In IncludedSlotsCheckBoxList.Items
                        If itm.Value = priorityId Then
                            itm.Selected = True
                        End If
                    Next
                    AllSlotsCheckBox.Checked = False
                End If

                ReferalDateDatePicker.SelectedDate = referralDate
                setDayDefaults()
                enableDisableControls(True)
                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "checkbox-events", "setBreachDays();", True)
            End If
        Catch ex As Exception
            Dim errorMsg = "Error changing to " & CalendarView.ToString.ToLower & " view"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try

    End Sub


    Sub resetFilters()
        If SearchTrustRadComboBox.SelectedValue = 0 Then
            SearchOperatingHospitalIdRadComboBox.DataSource = DataAdapter_Sch.GetAllSchedulerHospitals()
        Else
            SearchOperatingHospitalIdRadComboBox.DataSource = DataAdapter_Sch.GetSchedulerHospitals(SearchTrustRadComboBox.SelectedValue)
        End If
        SearchOperatingHospitalIdRadComboBox.DataBind()
        SearchOperatingHospitalIdRadComboBox.Items(SearchOperatingHospitalIdRadComboBox.FindItemIndexByValue(OperatingHospitalID)).Checked = True

        SearchGIProcedureRadioButtons.SelectedValue = "true"
        nonGIProceduresDropdown.SelectedValue = 0
        DiagnosticsRadioButton.Checked = False
        TherapeuticRadioButton.Checked = False

        For Each item As RepeaterItem In rptProcedureTypes.Items
            CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Checked = False
            CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = False

            Dim procedureTypeId As Integer = CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value
            Session("SearchTherapeuticTypes_" & procedureTypeId.ToString()) = Nothing
        Next

        For Each itm As ListItem In IncludedSlotsCheckBoxList.Items
            itm.Selected = False
        Next
        AllSlotsCheckBox.Checked = False

        setDayDefaults()

        For Each itm As RadComboBoxItem In SearchEndoscopistDropdown.Items
            itm.Checked = False
        Next

        EndoscopistGenderRadioButtonList.SelectedValue = 0
        ShowOnlyReservedSlotsCheckBox.Checked = False
        SearchWeeksBeforeTextBox.Text = 2
        ReferalDateDatePicker.SelectedDate = Now
        BreachDateDatePicker.SelectedDate = Now.AddDays(14)
        SearchDateDatePicker.SelectedDate = BreachDateDatePicker.SelectedDate.Value.AddDays(-(SearchWeeksBeforeTextBox.Value * 7))
    End Sub

    Sub enableDisableControls(enabled As Boolean)
        For Each itm As RepeaterItem In rptProcedureTypes.Items
            CType(itm.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Enabled = enabled
            CType(itm.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Enabled = enabled
        Next

        AllSlotsCheckBox.Enabled = enabled
        IncludedSlotsCheckBoxList.Enabled = enabled
        SearchGIProcedureRadioButtons.Enabled = enabled
        LengthOfSlotsNumericTextbox.Enabled = enabled
    End Sub

    Protected Sub DayLinkButton_Click(sender As Object, e As EventArgs)
        Try
            If Not CalendarView = SchedulerViewType.DayView Then
                AMRadScheduler.EnableViewState = False
                PMRadScheduler.EnableViewState = False
                EVRadScheduler.EnableViewState = False
            End If

            Session("CalendarView") = "day"
            changeCalendarView()

            Dim selectedRooms As New List(Of Object)

            For Each itm As RadComboBoxItem In RoomsDropdown.Items
                Dim obj = New With {
                    .RoomId = itm.Value,
                    .RoomName = itm.Text
                }
                selectedRooms.Add(obj)
            Next

            rptRoomTabs.DataSource = selectedRooms
            rptRoomTabs.DataBind()

            SelectedRoomHiddenField.Value = RoomsDropdown.Items(0).Value
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-tab", "setRoomTabSelected(" & SelectedRoomId & ");", True)


            AMRadScheduler.EnableViewState = True
            PMRadScheduler.EnableViewState = True
            EVRadScheduler.EnableViewState = True
        Catch ex As Exception
            Dim errorMsg = "Error changing to " & CalendarView.ToString.ToLower & " view"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub WeekLinkbutton_Click(sender As Object, e As EventArgs)
        Try
            AMRadScheduler.EnableViewState = False
            PMRadScheduler.EnableViewState = False
            EVRadScheduler.EnableViewState = False
            ListRadScheduler.EnableViewState = True

            Session("CalendarView") = "week"
            changeCalendarView()
        Catch ex As Exception
            Dim errorMsg = "Error changing to " & CalendarView.ToString.ToLower & " view"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub MonthLinkbutton_Click(sender As Object, e As EventArgs)
        Try
            AMRadScheduler.EnableViewState = False
            PMRadScheduler.EnableViewState = False
            EVRadScheduler.EnableViewState = False


            Session("CalendarView") = "month"
            changeCalendarView()
        Catch ex As Exception
            Dim errorMsg = "Error changing to " & CalendarView.ToString.ToLower & " view"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub changeCalendarView()
        Try
            Select Case CalendarView
                Case SchedulerViewType.DayView
                    dayViewDiv.Visible = True
                    OtherViewDiv.Visible = False
                    DiaryOverviewDiv.Visible = False
                    RoomNameLabel.Visible = True
                    GetDiarySlots(True, SelectedRoomId)

                    setDate(Now)
                Case SchedulerViewType.WeekView
                    RoomNameLabel.Visible = False
                    dayViewDiv.Visible = False
                    OtherViewDiv.Visible = True
                    DiaryOverviewDiv.Visible = False
                    ListRadScheduler.SelectedView = SchedulerViewType.WeekView


                    Dim roomIDs As String = ""
                    For Each itm As RadComboBoxItem In RoomsDropdown.CheckedItems
                        roomIDs = roomIDs & IIf(roomIDs = Nothing, itm.Value, "," & itm.Value)
                    Next

                    RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = HospitalDropDownList.SelectedValue
                    RoomsDataSource.SelectParameters("FieldValue").DefaultValue = roomIDs

                    GetDiarySlots(True)

                    setDate(ListRadScheduler.SelectedDate)
                Case SchedulerViewType.MonthView
                    Dim roomIDs As String = ""
                    For Each itm As RadComboBoxItem In RoomsDropdown.CheckedItems
                        roomIDs = roomIDs & IIf(roomIDs = Nothing, itm.Value, "," & itm.Value)
                    Next

                    RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = HospitalDropDownList.SelectedValue
                    RoomsDataSource.SelectParameters("FieldValue").DefaultValue = roomIDs


                    dayViewDiv.Visible = False
                    OtherViewDiv.Visible = False
                    DiaryOverviewDiv.Visible = True
                    RoomNameLabel.Visible = False
                    DiaryOverviewRadScheduler.SelectedView = SchedulerViewType.MonthView

                    GetDiarySlots(True)

                    setDate(DiaryOverviewRadScheduler.SelectedDate)

                    OverviewTypeRadioButtonList.SelectedIndex = 0
                    OverviewEndoscopistRadComboBox.SelectedIndex = 0
            End Select

            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-selected-calendar-view", "setCalendarView('" & CalendarView.ToString.ToLower().Replace("view", "") & "');", True)
        Catch ex As Exception
            Dim errorMsg = "Error changing to " & CalendarView.ToString.ToLower & " view"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub PreviousDayLinkButton_Click(sender As Object, e As EventArgs)
        Try

            Dim nextDate As DateTime
            If CalendarView = SchedulerViewType.DayView Then
                nextDate = CDate(AMRadScheduler.SelectedDate).AddDays(-1)
            ElseIf CalendarView = SchedulerViewType.WeekView Then
                nextDate = CDate(ListRadScheduler.SelectedDate).AddDays(-7)

                AMRadScheduler.EnableViewState = False
                PMRadScheduler.EnableViewState = False
                EVRadScheduler.EnableViewState = False
            ElseIf CalendarView = SchedulerViewType.MonthView Then
                nextDate = CDate(DiaryOverviewRadScheduler.SelectedDate).AddMonths(-1)

                AMRadScheduler.EnableViewState = False
                PMRadScheduler.EnableViewState = False
                EVRadScheduler.EnableViewState = False
            End If

            setDate(nextDate)
            SetSelectedRoomRadButton_Click(Nothing, Nothing)


            'setRoom()
        Catch ex As Exception
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub NextDayLinkButton_Click(sender As Object, e As EventArgs)
        Try
            Dim nextDate As DateTime

            If CalendarView = SchedulerViewType.DayView Then
                nextDate = CDate(AMRadScheduler.SelectedDate).AddDays(1)
            ElseIf CalendarView = SchedulerViewType.WeekView Then
                AMRadScheduler.EnableViewState = False
                PMRadScheduler.EnableViewState = False
                EVRadScheduler.EnableViewState = False

                nextDate = CDate(ListRadScheduler.SelectedDate).AddDays(7)
            ElseIf CalendarView = SchedulerViewType.MonthView Then
                AMRadScheduler.EnableViewState = False
                PMRadScheduler.EnableViewState = False
                EVRadScheduler.EnableViewState = False

                nextDate = CDate(DiaryOverviewRadScheduler.SelectedDate).AddMonths(1)
            End If


            setDate(nextDate)
            SetSelectedRoomRadButton_Click(Nothing, Nothing)



        Catch ex As Exception
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub TodaysDateLinkButton_Click(sender As Object, e As EventArgs)
        Try
            setDate(Now)
            ChangeRoomButton_Click(ChangeRoomButton, Nothing)
        Catch ex As Exception
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub setDate(selectedDate As DateTime)
        Select Case CalendarView
            Case SchedulerViewType.DayView
                AMRadScheduler.SelectedDate = selectedDate
                PMRadScheduler.SelectedDate = selectedDate
                EVRadScheduler.SelectedDate = selectedDate
                CalendarDateLabel.Text = selectedDate.ToString("dddd, dd MMM yyyy")

                'set event handlers and display notes for the set day
                notesSetup()
            Case SchedulerViewType.WeekView
                ListRadScheduler.SelectedDate = selectedDate
                Dim dow As Integer = selectedDate.DayOfWeek
                Dim startOfWeek = DateAdd(DateInterval.Day, -dow, selectedDate)
                Dim endOfWeek = DateAdd(DateInterval.Day, 6, startOfWeek)

                CalendarDateLabel.Text = startOfWeek.ToString("dd MMM yyyy") & " - " & endOfWeek.ToString("dd MMM yyyy")
            Case SchedulerViewType.MonthView
                DiaryOverviewRadScheduler.SelectedDate = selectedDate
                CalendarDateLabel.Text = selectedDate.ToString("MMM yyyy")
        End Select
        DiaryDatePicker.SelectedDate = selectedDate
        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-selected-calendar-view", "setCalendarView('" & CalendarView.ToString.ToLower().Replace("view", "") & "');", True)
        resetSlotCount()
    End Sub

    Private Sub notesSetup()
        'set notes
        AMNotesTextBox.Text = ""
        PMNotesTextBox.Text = ""
        EVENotesTextBox.Text = ""

        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-day-notes", "getDayNotes('" & AMRadScheduler.SelectedDate & "', " & CInt(SelectedRoomId) & ", " & OperatingHospitalID & ");", True)

        'bind notes AM save button
        AMNotesTextBox.Attributes("onfocusout") = "saveDayNotes('" & AMRadScheduler.SelectedDate.ToShortDateString & "','AM'," & CInt(SelectedRoomId) & ",'" & OperatingHospitalID & "','" & AMNotesTextBox.ClientID & "');"
        AMNotesTextBox.Attributes("onkeyup") = "setTextChanges();"

        'bind notes PM save button
        PMNotesTextBox.Attributes("onfocusout") = "saveDayNotes('" & PMRadScheduler.SelectedDate.ToShortDateString & "','PM'," & CInt(SelectedRoomId) & ",'" & OperatingHospitalID & "','" & PMNotesTextBox.ClientID & "');"
        PMNotesTextBox.Attributes("onkeyup") = "setTextChanges();"

        'bind notes EVE save button
        EVENotesTextBox.Attributes("onfocusout") = "saveDayNotes('" & EVRadScheduler.SelectedDate.ToShortDateString & "','EVE'," & CInt(SelectedRoomId) & ",'" & OperatingHospitalID & "','" & EVENotesTextBox.ClientID & "');"
        EVENotesTextBox.Attributes("onkeyup") = "setTextChanges();"
    End Sub

    Protected Sub SetSelectedRoomRadButton_Click(sender As Object, e As EventArgs)
        Try
            setRoom()
            ChangeRoomButton_Click(ChangeRoomButton, Nothing)
        Catch ex As Exception
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()

        End Try
    End Sub

    Private Sub setRoom()
        resetSlotCount()

        If Not CalendarView = SchedulerViewType.DayView Then
            Dim selectedRooms As New List(Of Object)

            Dim roomIDs As String = ""
            For Each itm As RadComboBoxItem In RoomsDropdown.CheckedItems
                roomIDs = roomIDs & IIf(roomIDs = Nothing, itm.Value, "," & itm.Value)
                Dim obj = New With {
                    .RoomId = itm.Value,
                    .RoomName = itm.Text
                }
                selectedRooms.Add(obj)
            Next
            RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = HospitalDropDownList.SelectedValue
            RoomsDataSource.SelectParameters("FieldValue").DefaultValue = roomIDs
        Else
            RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = HospitalDropDownList.SelectedValue
            RoomsDataSource.SelectParameters("FieldValue").DefaultValue = SelectedRoomId
        End If

        GetDiarySlots(True, SelectedRoomId)

        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-tab", "setRoomTabSelected(" & SelectedRoomId & ");", True)
        'If CalendarView = SchedulerViewType.DayView Then
        '    ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-amended-bookings-notification", "GetDiaryAmendedBookings('" & CDate(CalendarDateLabel.Text) & "','" & SelectedRoomId & "');", True)
        'End If
    End Sub

    Protected Sub SearchExistingBookingButton_Click(sender As Object, e As EventArgs)
        Dim bookingsDT = DataAdapter_Sch.SearchPatientForBookings(BookingSearchCNNTextBox.Text, BookingSearchNHSNoTextBox.Text, BookingSearchSurnameTextBox.Text, BookingSearchForenameTextBox.Text)
        Try
            If bookingsDT IsNot Nothing AndAlso bookingsDT.Rows.Count > 0 Then
                If bookingsDT.Rows.Count = 1 Then
                    Dim bookingRow = bookingsDT.Rows(0)
                    Dim operatingHospitalId = CInt(bookingRow("HospitalId"))
                    Dim roomId = CInt(bookingRow("RoomId"))
                    Dim bookingDate = CDate(bookingRow("StartDateTime"))

                    goToPatientBooking(operatingHospitalId, roomId, bookingDate)
                Else
                    'show a list of patients and bookings in a grid
                    FoundBookingsRadGrid.DataSource = bookingsDT
                    FoundBookingsRadGrid.DataBind()

                    FoundBookingResults.Visible = True
                    FindExistingBookingDiv.Visible = False
                End If
            Else
                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-window", "closeSearchBookingWindow();", True)

                'notification
                Utilities.SetNotificationStyle(RadNotification2, "No bookings found", False)
                RadNotification2.Show()
            End If
        Catch ex As Exception
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-window", "closeSearchBookingWindow();", True)

            Dim errRef = LogManager.LogManagerInstance.LogError("An error occured while searching for existing bookings", ex)
            'notification
            Utilities.SetErrorNotificationStyle(RadNotification1, errRef, "There was an error searching for bookings")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub goToPatientBooking(operatingHospitalId As Integer, roomId As Integer, bookingdate As DateTime)
        HospitalDropDownList.SelectedValue = operatingHospitalId

        'get hospital rooms 
        RoomsDropdown.Items.Clear()
        RoomsDropdown.DataSource = DataAdapter_Sch.GetHospitalRooms(operatingHospitalId)
        RoomsDropdown.DataBind()

        'set selected room
        RoomsDropdown.FindItemByValue(roomId).Checked = True

        'set calendar date
        setDate(bookingdate)

        'click event to show room tabs and reload based on selected room
        ChangeRoomButton_Click(Nothing, Nothing)

        notesSetup()
    End Sub

    Protected Sub DiaryDatePicker_SelectedDateChanged(sender As Object, e As Calendar.SelectedDateChangedEventArgs)
        Try
            setDate(e.NewDate)
            setRoom()
        Catch ex As Exception
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Dim AMAppointmentCount = 0
    Dim PMAppointmentCount = 0
    Dim EVEAppointmentCount = 0

    Dim AMFreeSlots = 0
    Dim PMFreeSlots = 0
    Dim EVEFreeSlots = 0

    Dim AMBookedSlots = 0
    Dim PMBookedSlots = 0
    Dim EVEBookedSlots = 0

    Dim AMUsedPoints As Decimal = 0.0
    Dim PMUsedPoints As Decimal = 0.0
    Dim EVEUsedPoints As Decimal = 0.0

    Private Sub resetSlotCount()
        AMAppointmentCount = 0
        PMAppointmentCount = 0
        EVEAppointmentCount = 0

        AMFreeSlots = 0
        PMFreeSlots = 0
        EVEFreeSlots = 0

        AMBookedSlots = 0
        PMBookedSlots = 0
        EVEBookedSlots = 0

        AMDiaryDetails.Text = ""
        PMDiaryDetails.Text = ""
        EVEDiaryDetails.Text = ""

        AMUsedPoints = 0.0
        PMUsedPoints = 0.0
        EVEUsedPoints = 0.0
    End Sub

    Protected Sub RadScheduler_TimeSlotCreated(sender As Object, e As TimeSlotCreatedEventArgs)
        Try
            'If e.TimeSlot.Appointments.Count > 0 Then
            '    If DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("AM") Then
            '        'e.TimeSlot.Appointments(0).Start = New Date(2020, 3, 2, 9, 35, 0)

            '        If Not e.TimeSlot.Appointments(0).Attributes("slotType").ToLower = "endoflist" Then AMAppointmentCount += 1
            '        If e.TimeSlot.Appointments(0).Attributes("slotType").ToLower = "freeslot" Then
            '            AMFreeSlots += 1
            '        ElseIf e.TimeSlot.Appointments(0).Attributes("slotType").ToLower = "patientbooking" Then
            '            AMBookedSlots += 1
            '        End If
            '    ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("PM") Then
            '        If Not e.TimeSlot.Appointments(0).Attributes("slotType").ToLower = "endoflist" Then PMAppointmentCount += 1

            '        If e.TimeSlot.Appointments(0).Attributes("slotType").ToLower = "freeslot" Then
            '            PMFreeSlots += 1
            '        ElseIf e.TimeSlot.Appointments(0).Attributes("slotType").ToLower = "patientbooking" Then
            '            PMBookedSlots += 1
            '        End If
            '    ElseIf DirectCast(sender, RadScheduler).ID.ToUpper.StartsWith("EV") Then
            '        If Not e.TimeSlot.Appointments(0).Attributes("slotType").ToLower = "endoflist" Then EVEAppointmentCount += 1
            '        If e.TimeSlot.Appointments(0).Attributes("slotType").ToLower = "freeslot" Then
            '            EVEFreeSlots += 1
            '        ElseIf e.TimeSlot.Appointments(0).Attributes("slotType").ToLower = "patientbooking" Then
            '            EVEBookedSlots += 1
            '        End If
            '    End If
            'End If
        Catch ex As Exception
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub ListRadScheduler_PreRender(sender As Object, e As EventArgs)
        Try

            Dim scheduler = DirectCast(sender, RadScheduler)
            'Dim listConsultantText = "<strong>List Consultant: {0}"
            Dim listDetailsText = "<b>List Consultant:</b> {0}<br /><b>Endoscopist:</b> {1}"
            Dim listTypeText = "<b>List Type:</b> {0}{1}"
            Dim templateDetailsText = "<div style='float:left; padding-top:20px;'><b>Points Used:</b> {0}/{1}{2}</div>"

            Dim AMDiaryId = 0
            Dim PMDiaryId = 0
            Dim EVEDiaryId = 0

            Dim endSlot = scheduler.Appointments.Where(Function(x) x.Subject.ToLower.Contains("end of list")).FirstOrDefault
            If endSlot IsNot Nothing Then endSlot.ContextMenuID = Nothing '.ToLower.Contains("end of list")).ContextMenuID = Nothing

            If CalendarView = SchedulerViewType.MonthView Then
                'Dim bookedCount = 0
                'Dim freeCount = 0
                'Dim diaryDate = 0
                'For Each a As Appointment In DiaryOverviewRadScheduler.Appointments
                '    If a.Attributes("slotType").ToLower = "patientbooking" Then
                '        bookedCount += 1
                '    ElseIf a.Attributes("slotType").ToLower = "freeslot" Then
                '        freeCount += 1
                '    End If
                'Next
            Else
                If scheduler.ID.StartsWith("AM") Then
                    If scheduler.Appointments.Count > 0 Then
                        Dim totalPoints As Decimal = 0.0
                        Dim unUsedPoints As Decimal = 0.0
                        'Dim appointment = scheduler.Appointments.Where(Function(x) x.Start.Date = scheduler.SelectedDate.Date And (x.Start.TimeOfDay >= New TimeSpan(0, 0, 0) And x.Start.TimeOfDay < New TimeSpan(12, 0, 0))).FirstOrDefault
                        AMDiaryId = CInt(scheduler.Appointments(0).Attributes("diaryId"))

                        'get list consultant
                        Dim listConsultant = DataAdapter_Sch.getDiaryConsultant(AMDiaryId, scheduler.SelectedDate)
                        Dim listEndoscopist = DataAdapter_Sch.getDiaryEndoscopist(AMDiaryId, scheduler.SelectedDate)
                        Dim listName = DataAdapter_Sch.GetListName(AMDiaryId)
                        Dim isTraining = DataAdapter_Sch.isTrainingDiary(AMDiaryId)
                        Dim isGIDiary = DataAdapter_Sch.isGIDiary(AMDiaryId)
                        Dim diaryGender = DataAdapter_Sch.GetGenderLists(AMDiaryId, scheduler.SelectedDate.Date)
                        Dim listProcedure = DataAdapter_Sch.getDiaryProcedureList(AMDiaryId, scheduler.SelectedDate)
                        totalPoints = DataAdapter_Sch.GetTotalListPoints(AMDiaryId)
                        unUsedPoints = totalPoints - AMUsedPoints

                        AMUsedPoints = scheduler.Appointments.Where(Function(x) x.Attributes("slotType").ToLower = "patientbooking").Sum(Function(x) CDec(x.Attributes("slotPoints")))

                        Dim listGenderType = ""

                        If diaryGender.Count > 0 Then
                            If diaryGender(0).Female And diaryGender(0).Male Then
                                listGenderType = ""
                            ElseIf diaryGender(0).Female Then
                                listGenderType = "Female list"
                            ElseIf diaryGender(0).Male Then
                                listGenderType = "Male list"
                            End If
                        End If

                        AMDiaryDetails.Text = String.Format(listDetailsText, listConsultant, listEndoscopist) & "<br />" &
                                String.Format(listTypeText, listName, If(isGIDiary, "", "-Non-GI") &
                                If(listGenderType = "", "", "&nbsp;(" & listGenderType & ")" & "")) &
                                If(isTraining, "&nbsp;(training)", "") & "<br />" &
                                String.Format(templateDetailsText, AMUsedPoints.ToString("0.0").Replace(".0", ""), totalPoints.ToString("0.0").Replace(".0", ""), If(AMUsedPoints > totalPoints, " (" & CDec(AMUsedPoints - totalPoints).ToString("0.0").Replace(".0", "") & " over)", ""))

                        AMDiaryDetails.Visible = True

                        Try
                            imgAMListLock.Visible = True

                            Dim locked = DataAdapter_Sch.IsDiaryLocked(AMDiaryId, AMRadScheduler.SelectedDate, "AM")
                            If locked Then
                                SchedulerBookingContextMenuAM.Visible = False
                                SchedulerAppointmentContextMenuAM.Visible = False

                                imgAMListLock.ToolTip = "Click to unlock"
                                imgAMListLock.ImageUrl = "~/Images/Lock-Lock-48x48.png"
                            Else
                                SchedulerBookingContextMenuAM.Visible = True
                                SchedulerAppointmentContextMenuAM.Visible = True

                                imgAMListLock.ToolTip = "Click to lock"
                                imgAMListLock.ImageUrl = "~/Images/Lock-UnLock-48x48.png"
                            End If

                            'list locking...
                            imgAMListLock.Attributes("data-diary-id") = AMDiaryId
                            imgAMListLock.Attributes("data-diary-locked") = locked
                            imgAMListLock.Attributes("href") = "javascript:void(0);"
                            imgAMListLock.Attributes("onclick") = String.Format("return showLockWindow('{0}',{1},'{2}','{3}');", AMRadScheduler.SelectedDate, AMDiaryId, locked, "AM")
                            imgAMListLock.ToolTip = If(locked, "Click to unlock", "Click to lock")

                            'check if locked
                            If locked Then
                                For Each a As Appointment In DirectCast(sender, RadScheduler).Appointments
                                    a.ContextMenuID = Nothing
                                Next
                            Else
                                If AMFreeSlots = 0 Then
                                    Dim endOfListSlot = DirectCast(sender, RadScheduler).Appointments.Where(Function(x) x.Attributes("slotType").ToLower = "endoflist").FirstOrDefault
                                    endOfListSlot.ContextMenuID = "SchedulerAppointmentContextMenuAM"
                                End If
                            End If
                        Catch ex As Exception
                            LogManager.LogManagerInstance.LogError("Error getting locked diary state for diary id " & AMDiaryId, ex)
                            imgAMListLock.Visible = False
                        End Try

                        ShowAMAmendedBookingsLinkButton.Attributes("href") = "javascript:void(0);"
                        ShowAMAmendedBookingsLinkButton.Attributes("onclick") = String.Format("return displayCancelledBookings('{0}','{1}');", AMRadScheduler.SelectedDate, AMDiaryId)
                    Else
                        imgAMListLock.Visible = False
                    End If


                ElseIf scheduler.ID.StartsWith("PM") Then
                    If scheduler.Appointments.Count > 0 Then
                        PMDiaryDetails.Visible = True
                        Try
                            'Dim AMappointments = AMRadScheduler.Appointments.Where(Function(x) x.Start.Date = AMRadScheduler.SelectedDate.Date And (x.Start.TimeOfDay >= New TimeSpan(0, 0, 0) And x.Start.TimeOfDay < New TimeSpan(12, 0, 0))).FirstOrDefault
                            'If AMappointments IsNot Nothing Then AMDiaryId = CInt(AMappointments.Attributes("diaryId"))

                            'Dim appointment = scheduler.Appointments.Where(Function(x) x.Start.Date = scheduler.SelectedDate.Date And (x.Start.TimeOfDay >= New TimeSpan(12, 0, 0) And x.Start.TimeOfDay < New TimeSpan(17, 0, 0))).FirstOrDefault
                            PMDiaryId = CInt(scheduler.Appointments(0).Attributes("diaryId"))

                            Dim listConsultant = ""
                            Dim listEndoscopist = ""
                            Dim listName = ""
                            Dim isTraining = False
                            Dim isGIDiary = True
                            Dim diaryGender As New List(Of ERS.Data.ERS_SCH_GenderList)
                            Dim totalPoints As Decimal = 0.0
                            Dim unUsedPoints As Decimal = 0.0

                            listEndoscopist = DataAdapter_Sch.getDiaryEndoscopist(PMDiaryId, scheduler.SelectedDate)
                            listConsultant = DataAdapter_Sch.getDiaryConsultant(PMDiaryId, scheduler.SelectedDate)
                            listName = DataAdapter_Sch.GetListName(PMDiaryId)
                            isTraining = DataAdapter_Sch.isTrainingDiary(PMDiaryId)
                            isGIDiary = DataAdapter_Sch.isGIDiary(PMDiaryId)
                            diaryGender = DataAdapter_Sch.GetGenderLists(PMDiaryId, scheduler.SelectedDate.Date)
                            totalPoints = DataAdapter_Sch.GetTotalListPoints(PMDiaryId)
                            unUsedPoints = totalPoints - PMUsedPoints

                            PMUsedPoints = scheduler.Appointments.Where(Function(x) x.Attributes("slotType").ToLower = "patientbooking").Sum(Function(x) CDec(x.Attributes("slotPoints")))

                            Dim listGenderType = ""

                            If diaryGender.Count > 0 Then
                                If diaryGender(0).Female And diaryGender(0).Male Then
                                    listGenderType = ""
                                ElseIf diaryGender(0).Female Then
                                    listGenderType = "Female list"
                                ElseIf diaryGender(0).Male Then
                                    listGenderType = "Male list"
                                End If
                            End If

                            PMDiaryDetails.Text = String.Format(listDetailsText, listConsultant, listEndoscopist) & "<br />" &
                                String.Format(listTypeText, listName, If(isGIDiary, "", "-Non-GI") &
                                If(listGenderType = "", "", "&nbsp;(" & listGenderType & ")" & "")) &
                                If(isTraining, "&nbsp;(training)", "") & "<br />" &
                                String.Format(templateDetailsText, PMUsedPoints.ToString("0.0").Replace(".0", ""), totalPoints.ToString("0.0").Replace(".0", ""), If(PMUsedPoints > totalPoints, " (" & CDec(PMUsedPoints - totalPoints).ToString("0.0").Replace(".0", "") & " over)", ""))

                            imgPMListLock.Visible = True

                            Dim locked = DataAdapter_Sch.IsDiaryLocked(PMDiaryId, PMRadScheduler.SelectedDate, "PM")
                            If locked Then
                                SchedulerBookingContextMenuPM.Visible = False
                                SchedulerAppointmentContextMenuPM.Visible = False

                                imgPMListLock.ToolTip = "Click to unlock"
                                imgPMListLock.ImageUrl = "~/Images/Lock-Lock-48x48.png"
                            Else
                                SchedulerBookingContextMenuPM.Visible = True
                                SchedulerAppointmentContextMenuPM.Visible = True

                                imgPMListLock.ToolTip = "Click to lock"
                                imgPMListLock.ImageUrl = "~/Images/Lock-UnLock-48x48.png"
                            End If

                            imgPMListLock.Attributes("onclick") = String.Format("return showLockWindow('{0}',{1},'{2}','{3}');", PMRadScheduler.SelectedDate, PMDiaryId, locked, "PM")
                            imgPMListLock.Attributes("data-diary-id") = PMDiaryId
                            imgPMListLock.Attributes("data-diary-locked") = locked
                            imgPMListLock.ToolTip = If(locked, "Click to unlock", "Click to lock")

                            If locked Then
                                For Each a As Appointment In DirectCast(sender, RadScheduler).Appointments
                                    a.ContextMenuID = Nothing
                                Next
                            Else
                                If PMFreeSlots = 0 Then
                                    Dim endOfListSlot = DirectCast(sender, RadScheduler).Appointments.Where(Function(x) x.Attributes("slotType").ToLower = "endoflist").FirstOrDefault
                                    endOfListSlot.ContextMenuID = "SchedulerAppointmentContextMenuPM"
                                End If
                            End If
                        Catch ex As Exception
                            LogManager.LogManagerInstance.LogError("Error getting locked diary state for diary id " & PMDiaryId, ex)
                            imgPMListLock.Visible = False
                        End Try

                        ShowPMAmendedBookingsLinkButton.Attributes("href") = "javascript:void(0);"
                        ShowPMAmendedBookingsLinkButton.Attributes("onclick") = String.Format("return displayCancelledBookings('{0}','{1}');", PMRadScheduler.SelectedDate, PMDiaryId)
                    End If


                ElseIf scheduler.ID.StartsWith("EV") Then
                    If scheduler.Appointments.Count > 0 Then
                        EVEDiaryDetails.Visible = True

                        Try
                            'Dim AMappointments = AMRadScheduler.Appointments.Where(Function(x) x.Start.Date = scheduler.SelectedDate.Date And (x.Start.TimeOfDay >= New TimeSpan(0, 0, 0) And x.Start.TimeOfDay < New TimeSpan(12, 0, 0))).FirstOrDefault
                            'If AMappointments IsNot Nothing Then AMDiaryId = CInt(AMappointments.Attributes("diaryId"))

                            'Dim PMappointments = PMRadScheduler.Appointments.Where(Function(x) x.Start.Date = scheduler.SelectedDate.Date And (x.Start.TimeOfDay >= New TimeSpan(12, 0, 0) And x.Start.TimeOfDay < New TimeSpan(17, 0, 0))).FirstOrDefault
                            'If PMappointments IsNot Nothing Then PMDiaryId = CInt(PMappointments.Attributes("diaryId"))

                            'Dim appointment = scheduler.Appointments.Where(Function(x) x.Start.Date = scheduler.SelectedDate.Date And x.Start.TimeOfDay >= New TimeSpan(17, 0, 0)).Select(Function(x) x.ID).FirstOrDefault
                            EVEDiaryId = CInt(scheduler.Appointments(0).Attributes("diaryId"))

                            Dim listConsultant = ""
                            Dim listEndoscopist = ""
                            Dim listName = ""
                            Dim isTraining = False
                            Dim isGIDiary = True
                            Dim diaryGender As New List(Of ERS.Data.ERS_SCH_GenderList)
                            Dim totalPoints As Decimal = 0.0
                            Dim unUsedPoints As Decimal = 0.0


                            listEndoscopist = DataAdapter_Sch.getDiaryEndoscopist(EVEDiaryId, scheduler.SelectedDate)
                            listConsultant = DataAdapter_Sch.getDiaryConsultant(EVEDiaryId, scheduler.SelectedDate)
                            listName = DataAdapter_Sch.GetListName(EVEDiaryId)
                            isTraining = DataAdapter_Sch.isTrainingDiary(EVEDiaryId)
                            isGIDiary = DataAdapter_Sch.isGIDiary(EVEDiaryId)
                            diaryGender = DataAdapter_Sch.GetGenderLists(EVEDiaryId, scheduler.SelectedDate.Date)
                            totalPoints = DataAdapter_Sch.GetTotalListPoints(EVEDiaryId)
                            unUsedPoints = totalPoints - EVEUsedPoints

                            EVEUsedPoints = scheduler.Appointments.Where(Function(x) x.Attributes("slotType").ToLower = "patientbooking").Sum(Function(x) CDec(x.Attributes("slotPoints")))

                            Dim listGenderType = ""

                            If diaryGender.Count > 0 Then
                                If diaryGender(0).Female And diaryGender(0).Male Then
                                    listGenderType = ""
                                ElseIf diaryGender(0).Female Then
                                    listGenderType = "Female list"
                                ElseIf diaryGender(0).Male Then
                                    listGenderType = "Male list"
                                End If
                            End If

                            EVEDiaryDetails.Text = String.Format(listDetailsText, listConsultant, listEndoscopist) & "<br />" &
                                String.Format(listTypeText, listName, If(isGIDiary, "", "-Non-GI") &
                                If(listGenderType = "", "", "&nbsp;(" & listGenderType & ")" & "")) &
                                If(isTraining, "&nbsp;(training)", "") & "<br />" &
                                String.Format(templateDetailsText, EVEUsedPoints.ToString("0.0").Replace(".0", ""), totalPoints.ToString("0.0").Replace(".0", ""), If(EVEUsedPoints > totalPoints, " (" & CDec(EVEUsedPoints - totalPoints).ToString("0.0").Replace(".0", "") & " over)", ""))

                            imgEVEListLock.Visible = True
                            Dim locked = DataAdapter_Sch.IsDiaryLocked(EVEDiaryId, EVRadScheduler.SelectedDate, "EVE")
                            If locked Then
                                SchedulerBookingContextMenuEVE.Visible = False
                                SchedulerAppointmentContextMenuEVE.Visible = False

                                imgEVEListLock.ToolTip = "Click to unlock"
                                imgEVEListLock.ImageUrl = "~/Images/Lock-Lock-48x48.png"
                            Else
                                SchedulerBookingContextMenuEVE.Visible = True
                                SchedulerAppointmentContextMenuEVE.Visible = True

                                imgEVEListLock.ToolTip = "Click to lock"
                                imgEVEListLock.ImageUrl = "~/Images/Lock-UnLock-48x48.png"
                            End If

                            imgEVEListLock.Attributes("onclick") = String.Format("return showLockWindow('{0}',{1},'{2}','{3}');", EVRadScheduler.SelectedDate, EVEDiaryId, locked, "EVE")
                            imgEVEListLock.Attributes("data-diary-id") = EVEDiaryId
                            imgEVEListLock.Attributes("data-diary-locked") = locked
                            imgEVEListLock.ToolTip = If(locked, "Click to unlock", "Click to lock")

                            If locked Then
                                For Each a As Appointment In DirectCast(sender, RadScheduler).Appointments
                                    a.ContextMenuID = Nothing
                                Next
                            Else
                                If EVEFreeSlots = 0 Then
                                    Dim endOfListSlot = DirectCast(sender, RadScheduler).Appointments.Where(Function(x) x.Attributes("slotType").ToLower = "endoflist").FirstOrDefault
                                    endOfListSlot.ContextMenuID = "SchedulerAppointmentContextMenuEVE"
                                End If
                            End If
                        Catch ex As Exception
                            LogManager.LogManagerInstance.LogError("Error getting locked diary state for diary id " & EVEDiaryId, ex)
                            imgEVEListLock.Visible = False
                        End Try

                        ShowEVEAmendedBookingsLinkButton.Attributes("href") = "javascript:void(0);"
                        ShowEVEAmendedBookingsLinkButton.Attributes("onclick") = String.Format("return displayCancelledBookings('{0}','{1}');", EVRadScheduler.SelectedDate, EVEDiaryId)
                    Else
                        imgEVEListLock.Visible = False
                    End If
                End If
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in scheduler pre-render", ex)
        End Try
    End Sub

    Protected Sub AgendaLinkButton_Click(sender As Object, e As EventArgs)

    End Sub

    Protected Sub FoundBookingsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        If e.CommandName.ToLower = "selectbooking" Then
            Dim RoomID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoomId")
            Dim HospitalID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("HospitalId")
            Dim bookingDate = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("StartDateTime")

            goToPatientBooking(HospitalID, RoomID, bookingDate)
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "patient-booking-found", "closeSearchBookingWindow();", True)
        End If
    End Sub

    Protected Sub imgAMListLock_Click(sender As Object, e As ImageClickEventArgs)
        LockDiary("AM")
    End Sub

    Protected Sub imgPMListLock_Click(sender As Object, e As ImageClickEventArgs)
        LockDiary("PM")
    End Sub

    Protected Sub imgEVEListLock_Click(sender As Object, e As ImageClickEventArgs)
        LockDiary("EVE")
    End Sub

    Private Sub LockDiary(diarySession As String)
        Try
            Dim iDiaryId = 0
            Dim diaryDate As DateTime
            Dim locked = False
            Dim infoString = SelectedRoomName & " " & AMRadScheduler.SelectedDate.DayOfWeek.ToString & " {0} " & AMRadScheduler.SelectedDate.ToString("dd MMMM yyyy")
            'Select Case diarySession.ToUpper
            '    Case "AM"
            '        iDiaryId = imgAMListLock.Attributes("data-diary-id")
            '        diaryDate = AMRadScheduler.SelectedDate
            '        LockingDiaryInfo.Text = String.Format(infoString, "morning")
            '    Case "PM"
            '        iDiaryId = imgPMListLock.Attributes("data-diary-id")
            '        diaryDate = AMRadScheduler.SelectedDate
            '        LockingDiaryInfo.Text = String.Format(infoString, "afternoon")
            '    Case "EVE"
            '        iDiaryId = imgEVEListLock.Attributes("data-diary-id")
            '        diaryDate = AMRadScheduler.SelectedDate
            '        LockingDiaryInfo.Text = String.Format(infoString, "evening")
            'End Select

            'Dim lockedDiaryDetails = DataAdapter_Sch.LockedDiaryDetails(iDiaryId, EVRadScheduler.SelectedDate)
            'If lockedDiaryDetails.Rows.Count > 0 Then locked = CBool(lockedDiaryDetails.Rows(0)("Locked"))

            'Dim lockReasons = DataAdapter_Sch.GetDiaryLockReasons(True).AsEnumerable.Where(Function(x) CBool(x("IsLockReason")) = (Not locked))

            'If locked Then
            '    Dim dr = lockedDiaryDetails.Rows(0)
            '    LockReasonDiaryDetailsLabel.Text = "List was locked by " & dr("Username") & " on " & CDate(dr("LockedDateTime")).ToShortDateString & " at " & CDate(dr("LockedDateTime")).ToShortTimeString & "<br />" &
            '    "Reason: " & dr("LockReason") & "<br />" &
            '    "Authorisation: " & dr("LockAuthorizatonText")
            'Else
            '    LockReasonDiaryDetailsLabel.Text = ""
            'End If

            'If lockReasons.Count > 0 Then
            '    Dim dt = lockReasons.CopyToDataTable()
            '    LockReasonRadComboBox.DataSource = dt
            '    LockReasonRadComboBox.DataTextField = "Reason"
            '    LockReasonRadComboBox.DataValueField = "DiaryLockReasonId"
            '    LockReasonRadComboBox.DataBind()
            '    LockReasonRadComboBox.Items.Insert(0, "")
            'End If

        Catch ex As Exception
            Dim errorMsg = "Error populating lock reasons"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub CancelSearchButton_Click(sender As Object, e As EventArgs)
        Dim btn = CType(sender, RadButton)

        Select Case btn.CommandName.ToLower
            Case "cancelmovebooking"
                Session("AppointmentId") = Nothing
            Case "cancelsearchslot"
                PageSearchFields = Nothing
            Case "cancelbookfromwaitlist"
                Session("WaitlistId") = Nothing
        End Select

        btn.CommandName = Nothing
    End Sub

    Protected Sub OverviewEndoscopist_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            viewOverviewByEndo()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading endoscopists overview", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading the overview")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub viewOverviewByEndo()
        If OverviewEndoscopistRadComboBox.SelectedValue > 0 Then
            DiaryOverviewRadScheduler.DataSource = DataAdapter_Sch.getDiaryPages(CInt(OverviewEndoscopistRadComboBox.SelectedValue))
            DiaryOverviewRadScheduler.DataBind()

            AMRadScheduler.EnableViewState = False
            PMRadScheduler.EnableViewState = False
            EVRadScheduler.EnableViewState = False
        Else
            DiaryOverviewRadScheduler.DataSource = DataAdapter_Sch.getDiaryPages()
            DiaryOverviewRadScheduler.DataBind()

            AMRadScheduler.EnableViewState = False
            PMRadScheduler.EnableViewState = False
            EVRadScheduler.EnableViewState = False
        End If
    End Sub

    Protected Sub OverviewTypeRadioButtonList_SelectedIndexChanged(sender As Object, e As EventArgs)
        If OverviewTypeRadioButtonList.SelectedValue.ToLower = "list" Then
            DiaryOverviewRadScheduler.DataSource = DataAdapter_Sch.getDiaryPages()
            DiaryOverviewRadScheduler.DataBind()

            AMRadScheduler.EnableViewState = False
            PMRadScheduler.EnableViewState = False
            EVRadScheduler.EnableViewState = False
        Else
            viewOverviewByEndo()
        End If
    End Sub

    Protected Sub btnZoomIn_Click(sender As Object, e As ImageClickEventArgs)
        If AMRadScheduler.MinutesPerRow - 5 > 0 Then
            resetSlotCount()
            AMRadScheduler.MinutesPerRow -= 5
            AMRadScheduler.Rebind()
            PMRadScheduler.MinutesPerRow -= 5
            PMRadScheduler.Rebind()
            If EVEDiv.Visible Then
                EVRadScheduler.MinutesPerRow -= 5
                EVRadScheduler.Rebind()
            End If
            'ListRadScheduler.MinutesPerRow -= 5
            'ListRadScheduler.Rebind()
        End If
    End Sub

    Protected Sub btnZoomOut_Click(sender As Object, e As ImageClickEventArgs)

        If AMRadScheduler.MinutesPerRow < 15 Then
            resetSlotCount()
            AMRadScheduler.MinutesPerRow += 5
            AMRadScheduler.Rebind()
            PMRadScheduler.MinutesPerRow += 5
            PMRadScheduler.Rebind()
            If EVEDiv.Visible Then
                EVRadScheduler.MinutesPerRow += 5
                EVRadScheduler.Rebind()
            End If
            'ListRadScheduler.MinutesPerRow += 5
            'ListRadScheduler.Rebind()
        End If
    End Sub

    Protected Sub Unnamed_ValueChanged(sender As Object, e As EventArgs)
        resetSlotCount()
        AMRadScheduler.MinutesPerRow = RadSlider1.SelectedValue
        AMRadScheduler.Rebind()
        PMRadScheduler.MinutesPerRow = RadSlider1.SelectedValue
        PMRadScheduler.Rebind()
        If EVEDiv.Visible Then
            EVRadScheduler.MinutesPerRow = RadSlider1.SelectedValue
            EVRadScheduler.Rebind()
        End If
    End Sub



    Protected Sub SlotsRadGrid_ItemCreated(sender As Object, e As GridItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            If Not CType(sender, RadGrid).CssClass.Contains("breached-grid") Then Exit Sub
            Dim GoToDateLinkButton = CType(e.Item.FindControl("GoToDateLinkButton"), LinkButton)
            If GoToDateLinkButton IsNot Nothing Then
                'GoToDateLinkButton.Attributes("href") = "javascript:void(0);"
                GoToDateLinkButton.Attributes.Add("onclick", "javascript:return confirm('Booking will take you past the breach date for this slot type. Continue?');")
            End If
        End If
    End Sub

    Protected Sub btnShowWorklistDetail_Click(sender As Object, e As EventArgs)
        divResults.Visible = False
        divWaitlist.Visible = False
        divWaitDetails.Visible = True
        divOrderDetails.Visible = False
        divFilters.Visible = False

        rptProcedureTypes.DataBind()
        IncludedSlotsCheckBoxList.DataBind()

        Dim waitlistId = WaitListGrid.MasterTableView.DataKeyValues(WaitListGrid.SelectedIndexes(0))("WaitingListId")
        ShowWaitlistDetail(waitlistId)

    End Sub

    Protected Sub ShowOrderDetail(orderId As Integer)
        If orderId > 0 Then
            Dim orderDetails = DataAdapter_Sch.GetOrderDetails(orderId)
            If orderDetails.Rows.Count > 0 Then
                OrderDetailPatName.Text = orderDetails.Rows(0)("Forename1").ToString() + " " + orderDetails.Rows(0)("Surname").ToString()
            End If
        End If
    End Sub

    Protected Sub ShowWaitlistDetail(waitlistId As Integer)
        If waitlistId > 0 Then
            ' Show details of waitlist patient
            Dim dsOrderCommData As New DataSet
            Dim intOrderCommOrderId As Integer = 0
            Dim objOrderComBL As New OrderCommsBL

            Dim waitlistDetails = DataAdapter_Sch.GetWaitlistDetails(waitlistId)
            If waitlistDetails.Rows.Count > 0 Then
                WaitlistPatientName.Text = waitlistDetails.Rows(0)("Forename1").ToString() + " " + waitlistDetails.Rows(0)("Surname").ToString()
                WaitlistPatientGender.Text = waitlistDetails.Rows(0)("Gender").ToString()
                WaitlistPatientAddress.Text = waitlistDetails.Rows(0)("Address").ToString()
                WaitlistPatientDOB.Text = waitlistDetails.Rows(0)("DateOfBirth").ToString()
                WaitlistPatientHospitalNumber.Text = waitlistDetails.Rows(0)("HospitalNumber").ToString()
                WaitlistPatientNHSNumber.Text = waitlistDetails.Rows(0)("NHSNo").ToString()

                WaitlistInfoProcedure.Text = waitlistDetails.Rows(0)("ProcedureType").ToString()
                WaitlistInfoPriority.Text = waitlistDetails.Rows(0)("PriorityDescription").ToString()
                WaitlistInfoDateRaised.Text = waitlistDetails.Rows(0)("DateRaised").ToString()
                WaitlistInfoBookBy.Text = waitlistDetails.Rows(0)("BookBy").ToString()
                WaitlistInfoDaysToBreach.Text = waitlistDetails.Rows(0)("DaysToBreach").ToString()
                WaitlistInfoWaitDays.Text = waitlistDetails.Rows(0)("WaitDays").ToString()
                WaitlistInfoReferrer.Text = waitlistDetails.Rows(0)("Referrer").ToString()
                WaitlistInfoNotes.Text = waitlistDetails.Rows(0)("Notes").ToString()
                If CInt(waitlistDetails.Rows(0)("DaysToBreach")) < 8 Then
                    WaitlistInformation.Style.Item(HtmlTextWriterStyle.BorderColor) = "Red !important"
                    WaitlistInformation.Style.Item(HtmlTextWriterStyle.BorderStyle) = "solid"
                    WaitlistPatient.Style.Item(HtmlTextWriterStyle.BorderColor) = "Red !important"
                    WaitlistPatient.Style.Item(HtmlTextWriterStyle.BorderStyle) = "solid"
                ElseIf CInt(waitlistDetails.Rows(0)("DaysToBreach")) < 22 And CInt(waitlistDetails.Rows(0)("DaysToBreach")) > 7 Then
                    WaitlistInformation.Style.Item(HtmlTextWriterStyle.BorderColor) = "Orange !important"
                    WaitlistInformation.Style.Item(HtmlTextWriterStyle.BorderStyle) = "solid"
                    WaitlistPatient.Style.Item(HtmlTextWriterStyle.BorderColor) = "Orange !important"
                    WaitlistPatient.Style.Item(HtmlTextWriterStyle.BorderStyle) = "solid"
                ElseIf CInt(waitlistDetails.Rows(0)("DaysToBreach")) > 21 Then
                    WaitlistInformation.Style.Item(HtmlTextWriterStyle.BorderColor) = "Green !important"
                    WaitlistInformation.Style.Item(HtmlTextWriterStyle.BorderStyle) = "solid"
                    WaitlistPatient.Style.Item(HtmlTextWriterStyle.BorderColor) = "Green !important"
                    WaitlistPatient.Style.Item(HtmlTextWriterStyle.BorderStyle) = "solid"
                End If

                'Check if OrderComms attached
                Dim OrderCommReferrar As String = ""

                If Not IsDBNull(waitlistDetails.Rows(0)("OrderId")) Then
                    intOrderCommOrderId = CInt(waitlistDetails.Rows(0)("OrderId"))
                    dsOrderCommData = objOrderComBL.GetOrderCommsDetails(intOrderCommOrderId)

                    If dsOrderCommData.Tables(0).Rows.Count > 0 Then
                        If Not IsDBNull(dsOrderCommData.Tables(0).Rows(0)("OrderNumber")) Then
                            OrderCommOrderNumber.Text = dsOrderCommData.Tables(0).Rows(0)("OrderNumber").ToString()
                        Else
                            OrderCommOrderNumber.Text = ""
                        End If

                        If Not IsDBNull(dsOrderCommData.Tables(0).Rows(0)("OrderDate")) Then
                            OrderCommOrderDate.Text = Convert.ToDateTime(dsOrderCommData.Tables(0).Rows(0)("OrderDate").ToString()).ToString("dd MMM yyyy")
                        Else
                            OrderCommOrderDate.Text = ""
                        End If

                        If Not IsDBNull(dsOrderCommData.Tables(0).Rows(0)("OrderCommOrderSource")) Then
                            OrderCommOrderSource.Text = dsOrderCommData.Tables(0).Rows(0)("OrderCommOrderSource").ToString()
                        Else
                            OrderCommOrderSource.Text = ""
                        End If

                        If OrderCommOrderSource.Text.Trim() <> "" Then
                            If OrderCommOrderSource.Text.Trim().ToUpper() = "GP" Then
                                If Not IsDBNull(dsOrderCommData.Tables(0).Rows(0)("GPName")) Then
                                    OrderCommReferrar = "GP : " + dsOrderCommData.Tables(0).Rows(0)("GPName").ToString()
                                End If
                            ElseIf OrderCommOrderSource.Text.Trim().ToUpper().Replace("-", "").Replace(" ", "") = "INPATIENT" Then
                                If Not IsDBNull(dsOrderCommData.Tables(0).Rows(0)("ReferralConsultantName")) Then
                                    OrderCommReferrar = "Referral Consultant : " + dsOrderCommData.Tables(0).Rows(0)("ReferralConsultantName").ToString()
                                End If
                            ElseIf OrderCommOrderSource.Text.Trim().ToUpper().Replace("-", "").Replace(" ", "") = "OUTPATIENT" Then
                                If Not IsDBNull(dsOrderCommData.Tables(0).Rows(0)("ReferralHospitalName")) Then
                                    OrderCommReferrar = "Referral Hospital : " + dsOrderCommData.Tables(0).Rows(0)("ReferralHospitalName").ToString()
                                End If
                            ElseIf OrderCommOrderSource.Text.Trim().ToUpper().Replace("-", "").Replace(" ", "") = "DAYPATIENT" Then
                                OrderCommReferrar = ""
                            End If
                        End If

                        OrderCommReferrer.Text = OrderCommReferrar


                        If Not IsDBNull(dsOrderCommData.Tables(0).Rows(0)("ReferralHospitalName")) Then
                            OrderCommOrderHospital.Text = dsOrderCommData.Tables(0).Rows(0)("ReferralHospitalName").ToString()
                        Else
                            OrderCommOrderHospital.Text = ""
                        End If

                        OrderCommOrderedBy.Text = ""


                        If Not IsDBNull(dsOrderCommData.Tables(0).Rows(0)("DueDate")) Then
                            OrderCommDueDate.Text = Convert.ToDateTime(dsOrderCommData.Tables(0).Rows(0)("DueDate").ToString()).ToString("dd MMM yyyy")
                        Else
                            OrderCommDueDate.Text = ""
                        End If

                        OrderCommOrderedByContact.Text = ""


                        If Not IsDBNull(dsOrderCommData.Tables(0).Rows(0)("ClinicalHistoryNotes")) Then
                            ClinicalHistoryNotes.InnerHtml = dsOrderCommData.Tables(0).Rows(0)("ClinicalHistoryNotes").ToString().Replace(vbCrLf.ToString(), "<br/>")
                        Else
                            ClinicalHistoryNotes.InnerHtml = ""
                        End If


                        rptQuestionsAnswers.DataSource = Nothing
                        rptQuestionsAnswers.DataSource = dsOrderCommData.Tables(1)
                        rptQuestionsAnswers.DataBind()

                    Else
                        rptQuestionsAnswers.DataSource = Nothing
                        rptQuestionsAnswers.DataBind()
                    End If
                Else
                    ClearOrderComms()
                    rptQuestionsAnswers.DataSource = Nothing
                    rptQuestionsAnswers.DataBind()
                End If

            End If

        End If
    End Sub
    Private Sub ClearOrderComms()
        OrderCommOrderNumber.Text = ""
        OrderCommOrderSource.Text = ""
        OrderCommOrderHospital.Text = ""
        OrderCommDueDate.Text = ""
        OrderCommOrderDate.Text = ""
        OrderCommOrderedBy.Text = ""
        OrderCommReferrer.Text = ""
        OrderCommOrderedByContact.Text = ""
        ClinicalHistoryNotes.InnerHtml = ""

    End Sub

    Protected Sub radCloseWaitDetails_Click(sender As Object, e As EventArgs)
        divResults.Visible = False
        divWaitlist.Visible = True
        divWaitDetails.Visible = False
        divOrderDetails.Visible = False
        divFilters.Visible = False
    End Sub

    Protected Sub WaitListGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim da As New DataAccess_Sch
        Dim waitList = da.GetWaitlistPatients(OperatingHospitalID)
        Dim waitlistPatients = waitList.AsEnumerable.Where(Function(x) Not x.IsNull("AdmissionTypeId") AndAlso x("AdmissionTypeId") = 1)
        If waitlistPatients.Count > 0 Then
            WaitListGrid.DataSource = waitlistPatients.CopyToDataTable
        Else
            WaitListGrid.DataSource = Nothing
        End If
    End Sub

    Protected Sub btnMoveToWorklist_Click(sender As Object, e As EventArgs)
        Dim da As New DataAccess_Sch
        Dim orderId = OrdersRadGrid.MasterTableView.DataKeyValues(OrdersRadGrid.SelectedIndexes(0))("WaitingListId")
        If orderId > 0 Then
            da.MoveOrderToWaitlist(orderId)
            loadWaitlistGrids()
        End If
    End Sub

    Protected Sub btnShowOrdersDetail_Click(sender As Object, e As EventArgs)
        divResults.Visible = False
        divWaitlist.Visible = False
        divWaitDetails.Visible = False
        divOrderDetails.Visible = True
        divFilters.Visible = False

        rptProcedureTypes.DataBind()
        IncludedSlotsCheckBoxList.DataBind()

        Dim OrderId = OrdersRadGrid.MasterTableView.DataKeyValues(OrdersRadGrid.SelectedIndexes(0))("WaitingListId")
        ShowOrderDetail(OrderId)
    End Sub

    Protected Sub btnSearchSlotFromOrder_Click(sender As Object, e As EventArgs)
        Dim waitlistId = OrdersRadGrid.MasterTableView.DataKeyValues(OrdersRadGrid.SelectedIndexes(0))("WaitingListId")
        Dim dataKeyValues = OrdersRadGrid.MasterTableView.DataKeyValues(OrdersRadGrid.SelectedIndexes(0))
        searchSlotFromList(waitlistId, dataKeyValues)
    End Sub

    Protected Sub WaitListGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim dataItem = e.Item
                Dim OrderCommOrderId = CType(e.Item, GridDataItem).GetDataKeyValue("OrderId")
                If Not IsDBNull(OrderCommOrderId) Then
                    If OrderCommOrderId.ToString() <> "" Then
                        Dim lblOcOrderCom = CType(dataItem.FindControl("lblOrderCommLink"), Label)
                        lblOcOrderCom.Text = OrderCommOrderId.ToString()
                    End If
                End If
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : WaitListGrid_ItemCommand", ex)
        End Try
    End Sub

    Protected Sub WaitListGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Dim strLink As String = ""
        Dim objImageButton As ImageButton

        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim dataItem = e.Item
                Dim OrderCommOrderId = CType(e.Item, GridDataItem).GetDataKeyValue("OrderId")
                objImageButton = CType(dataItem.FindControl("btnViewOrderComm"), ImageButton)
                objImageButton.Visible = False

                If Not IsDBNull(OrderCommOrderId) Then
                    If OrderCommOrderId.ToString() <> "" Then
                        objImageButton.Attributes.Add("href", "javascript:void(0);")
                        strLink = String.Format("return PopUpOrderComms('{0}');", OrderCommOrderId.ToString())
                        objImageButton.Attributes.Add("onclick", strLink)
                        objImageButton.Visible = True
                    End If
                End If
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : WaitListGrid_ItemCommand", ex)
        End Try
    End Sub
End Class

Public Class DiarySlot
    Property Description As String
    Property RoomId As Integer
    Property StartDate As DateTime
    Property DiaryId As Integer
    Property StatusId As Integer
    Property ProcedureTypeId As Integer
    Property SlotDuration As Integer
    Property SlotPoints As Decimal
    Property OperatingHospitalId As Integer
    Property ListSlotId As Integer
    Property Appointment As Boolean
End Class