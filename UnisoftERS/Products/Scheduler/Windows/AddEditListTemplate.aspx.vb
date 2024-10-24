Imports System.ComponentModel
Imports System.Globalization
Imports Telerik.Web.UI
Imports Telerik.Web.UI.Calendar

Partial Class AddEditListTemplate
    Inherits System.Web.UI.Page


    Public Enum RadSchedulerAdvancedFormAdvancedFormMode
        Insert
        Edit
    End Enum

    Public intDefaultSlothLengthMinutes As Integer = 15

    ReadOnly Property GIProcedure As Boolean
        Get
            Return True
        End Get
    End Property

    ReadOnly Property IsTraining As Boolean
        Get
            Return chkIsTraining.Checked
        End Get
    End Property

    Public Event Template_Added(sender As Object, a As Appointment)
    Public Event Template_Updated(sender As Object, oldAppointment As Appointment, a As Appointment)

#Region "Properties"
    Private _dataAdapter_Sch As DataAccess_Sch = Nothing
    Protected ReadOnly Property DataAdapter_Sch() As DataAccess_Sch
        Get
            If _dataAdapter_Sch Is Nothing Then
                _dataAdapter_Sch = New DataAccess_Sch
            End If
            Return _dataAdapter_Sch
        End Get
    End Property

    Private Property FormInitialized() As Boolean
        Get
            Dim storedValue As Object = ViewState("FormInitialized")
            If storedValue IsNot Nothing Then
                Return CBool(storedValue)
            End If

            Return False
        End Get

        Set(ByVal value As Boolean)
            ViewState("FormInitialized") = value
        End Set
    End Property

    Private _mode As RadSchedulerAdvancedFormAdvancedFormMode

    Public Property Mode() As RadSchedulerAdvancedFormAdvancedFormMode
        Get
            Return _mode
        End Get
        Set(ByVal value As RadSchedulerAdvancedFormAdvancedFormMode)
            _mode = value
        End Set
    End Property

    'Protected ReadOnly Property Owner() As RadScheduler
    '    Get
    '        Return Nothing ' Appointment.Owner
    '    End Get
    'End Property

    'Public ReadOnly Property Appointment() As Appointment
    '    Get
    '        Dim container As SchedulerFormContainer = DirectCast(BindingContainer, SchedulerFormContainer)
    '        Return Nothing ' container.Appointment
    '    End Get
    'End Property

    Private _hasAppointments As Boolean
    Public Property HasAppointmentsAttached() As Boolean
        Get
            Return _hasAppointments
        End Get
        Set(ByVal value As Boolean)
            _hasAppointments = value
        End Set
    End Property

    Public ReadOnly Property TotalPoints As Decimal
        Get
            Dim points As Integer

            For Each item As GridDataItem In SlotsRadGrid.Items
                Dim PointsRadNumericTextBox As RadNumericTextBox = item.FindControl("PointsRadNumericTextBox")
                points += CDec(PointsRadNumericTextBox.Text)
            Next

            Return points
        End Get
    End Property

    Public ReadOnly Property TotalMinutes As Integer
        Get
            Dim mins As Integer

            For Each item As GridDataItem In SlotsRadGrid.Items
                Dim SlotLengthRadNumericTextBox As RadNumericTextBox = item.FindControl("SlotLengthRadNumericTextBox")
                mins += CInt(SlotLengthRadNumericTextBox.Text)
            Next

            Return mins
        End Get
    End Property

#End Region

#Region "Attributes and resources"

    Private _operatingHospitalId As Integer
    Public Property OperatingHospitalId() As Integer
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("operatinghospitalid")) Then
                _operatingHospitalId = Request.QueryString("operatinghospitalid")
            Else
                _operatingHospitalId = 0
            End If

            Return _operatingHospitalId
        End Get

        Set(ByVal value As Integer)
            _operatingHospitalId = value
        End Set
    End Property

    <Bindable(BindableSupport.Yes, BindingDirection.TwoWay)>
    Private _userId As Integer
    Public Property UserID() As Integer
        Get
            Return _userId
        End Get

        Set(ByVal value As Integer)
            _userId = value
        End Set
    End Property

    <Bindable(BindableSupport.Yes, BindingDirection.TwoWay)>
    Private _diaryId As Integer
    Public Property DiaryId() As Integer
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("diaryid")) Then
                _diaryId = Request.QueryString("diaryid")
            Else
                _diaryId = 0
            End If
            Return _diaryId
        End Get

        Set(ByVal value As Integer)
            _diaryId = value
        End Set
    End Property

    <Bindable(BindableSupport.Yes, BindingDirection.TwoWay)>
    Private _listRulesId As Integer

    Public Property ListRulesId() As Integer
        Get
            If _listRulesId = 0 Then
                If Not String.IsNullOrWhiteSpace(Request.QueryString("listrulesid")) Then
                    _listRulesId = Request.QueryString("listrulesid")
                Else
                    _listRulesId = 0
                End If
            End If

            Return _listRulesId
        End Get

        Set(ByVal value As Integer)
            _listRulesId = value
        End Set
    End Property

    Private _roomId As Integer
    Public Property RoomId() As Integer
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("roomid")) Then
                _roomId = Request.QueryString("roomid")
            Else
                _roomId = 0
            End If

            Return _roomId
        End Get

        Set(ByVal value As Integer)
            _roomId = value
        End Set
    End Property

    Private _start As DateTime
    Public Property ListStart() As DateTime
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("startdate")) Then
                _start = Request.QueryString("startdate")
            Else
                _start = Now
            End If
            Return _start
        End Get

        Set(ByVal value As DateTime)
            _start = value
        End Set
    End Property


    Private _end As DateTime
    Public Property ListEnd() As DateTime
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("listend")) Then
                _end = Request.QueryString("listend")
            Else
                _end = Now
            End If

            Return _end
        End Get

        Set(ByVal value As DateTime)
            _end = value
        End Set
    End Property


#End Region

    Private Sub page_Load(sender As Object, e As EventArgs) Handles Me.Load
        'Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        'Dim i = 0
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(EndTimePicker, EndTimePicker)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(rblListType, cbPersonalTemplate)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(rblListType, cbGenericTemplate)

        'myAjaxMgr.AjaxSettings.AddAjaxSetting(cbListConsultant, cbEndoscopist)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(cbPersonalTemplate, cbEndoscopist)

    End Sub

    Protected Overrides Sub OnPreRender(e As EventArgs)
        MyBase.OnPreRender(e)

        If Not FormInitialized Then

            OperatingHospitalIdHiddenField.Value = OperatingHospitalId


            loadDropdowns()
            'ucListTemplateSlots.initGrid()
            If ListStart.TimeOfDay > New TimeSpan(0, 0, 0) Then
                StartTimePicker.SelectedDate = ListStart
            End If

            Dim myCI As CultureInfo = New CultureInfo("en-GB")
            Dim myCal As Calendar = myCI.Calendar


            MonthFrequencyRadNumericTextBox.Value = myCal.GetWeekOfYear(DateTime.Parse(ListStart, myCI), System.Globalization.CalendarWeekRule.FirstDay, DayOfWeek.Sunday)

            FormInitialized = True
            If Request.QueryString("mode") = "edit" Then
                Mode = RadSchedulerAdvancedFormAdvancedFormMode.Edit
                populateForm()
                ListSlotsDiv.Visible = False
            Else
                Mode = RadSchedulerAdvancedFormAdvancedFormMode.Insert
                RecurringListsDiv.Visible = False
            End If

        End If
    End Sub

    Private Function weeksInMonth()
        Dim currentMonth = If(StartTimePicker.SelectedDate, ListStart)

        'extract the month
        Dim daysInMonth = DateTime.DaysInMonth(currentMonth.Year, currentMonth.Month)
        Dim firstOfMonth = New DateTime(currentMonth.Year, currentMonth.Month, 1)
        '//days of week starts by default as Sunday = 0
        Dim firstDayOfMonth = CInt(ListStart.DayOfWeek) 'might have to be the selected day of the week.....
        Return CInt(Math.Ceiling((firstDayOfMonth + daysInMonth) / 7.0))
    End Function
    Private Sub populateForm()
        Try
            DiaryIdHiddenField.Value = DiaryId
            'get diary details from DB and populate the controls
            Dim dtDiaryDetails = DataAdapter_Sch.GetListDiaryDetails(DiaryId)

            If dtDiaryDetails IsNot Nothing AndAlso dtDiaryDetails.Rows.Count > 0 Then
                Dim drDiaryDetails = dtDiaryDetails.Rows(0)

                ListNameRadTextBox.Text = drDiaryDetails("Subject")

                'hide template dropdown showing templates, not needed in edit mode as its already been chosen
                GenericTemplateTR.Style.Add("visibility", "hidden")

                ListRulesId = drDiaryDetails("ListRulesId")
                'DiaryId = Appointment.ID
                SelectList()
                'loadDropdowns()

                'template (incase the templates been deleted or suppressed)
                If cbGenericTemplate.FindItemIndexByValue(ListRulesId) > 0 Then
                    cbGenericTemplate.SelectedValue = ListRulesId
                End If
                cbGenericTemplate.Enabled = False

                'endoscopist
                cbEndoscopist.SelectedValue = CInt(drDiaryDetails("EndoscopistId"))

                'list consultant
                If Not drDiaryDetails.IsNull("ListConsultantId") Then
                    cbListConsultant.SelectedValue = CInt(drDiaryDetails("ListConsultantId"))
                End If

                'Training
                chkIsTraining.Checked = CBool(drDiaryDetails("Training"))

                'Gender
                If Not drDiaryDetails.IsNull("ListGenderId") Then
                    cbListGender.SelectedValue = drDiaryDetails("ListGenderId")
                End If

                'startdate
                StartTimePicker.SelectedDate = CDate(drDiaryDetails("DiaryStart"))

                If Not drDiaryDetails.IsNull("Appointments") AndAlso CBool(drDiaryDetails("Appointments")) Then
                    StartTimePicker.Enabled = False
                End If
                'enddate
                EndTimePicker.SelectedDate = CDate(drDiaryDetails("DiaryEnd"))


                'check if its a recurring list
                If CBool(drDiaryDetails("Recurring")) Then
                    Dim recurranceParentId = drDiaryDetails("RecurrenceParentID")
                    If recurranceParentId = 0 Then recurranceParentId = DiaryId


                    RecurringListsDiv.Visible = True
                    Dim dtRecurringLists = DataAdapter_Sch.GetRecurringLists(recurranceParentId, CDate(drDiaryDetails("DiaryStart")))
                    RecurringDatesRadGrid.DataSource = dtRecurringLists
                    RecurringDatesRadGrid.DataBind()
                Else

                    RecurringListsDiv.Visible = False
                End If
            End If

            'If Mode = RadSchedulerAdvancedFormAdvancedFormMode.Edit Then

            '    If DataAdapter_Sch.getdiaryAppointments(DiaryId, Appointment.Start).Rows.Count > 0 Then
            '        StartTimePicker.Enabled = False
            '        cbGenericTemplate.Enabled = False
            '        rblListType.Enabled = False
            '        chkIsTraining.Enabled = False
            '    End If
            'End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error populating edit template form", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading the form")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub loadDropdowns()
        'load endoscopists
        cbEndoscopist.DataSource = DataAdapter_Sch.GetEndoscopists(True)
        cbEndoscopist.DataTextField = "EndoName"
        cbEndoscopist.DataValueField = "UserId"
        cbEndoscopist.DataBind()
        cbEndoscopist.Items.Insert(0, New RadComboBoxItem("", 0))

        cbListConsultant.DataSource = DataAdapter_Sch.GetEndoscopists(True)
        cbListConsultant.DataTextField = "EndoName"
        cbListConsultant.DataValueField = "UserId"
        cbListConsultant.DataBind()
        cbListConsultant.Items.Insert(0, New RadComboBoxItem("", 0))

        cbListGender.DataSource = DataAdapter_Sch.GetGenderGenders()
        cbListGender.DataTextField = "Title"
        cbListGender.DataValueField = "GenderId"
        cbListGender.DataBind()
        cbListGender.Items.Insert(0, New RadComboBoxItem("", 0))

        'load generic templates (WHERE ISNULL(EndoscopistID, 0) = 0)
        Dim templates = DataAdapter_Sch.GetGenericTemplates(OperatingHospitalIdHiddenField.Value, chkShowCustom.Checked).AsEnumerable '.Where(Function(x) x("Suppressed") = 0)
        templates = templates.Where(Function(x) x("Suppressed") = 0)

        If templates.Count > 0 Then
            cbGenericTemplate.DataSource = templates.CopyToDataTable
            cbGenericTemplate.DataTextField = "ListName"
            cbGenericTemplate.DataValueField = "ListRulesId"
            cbGenericTemplate.DataBind()

        End If

        cbGenericTemplate.Items.Insert(0, New RadComboBoxItem("", 0))
        cbGenericTemplate.Items.Insert(1, New RadComboBoxItem("New template", -99))

    End Sub

    Protected Sub cbEndoscopist_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            If cbEndoscopist.AutoPostBack And Not chkIsTraining.Checked Then
                cbListConsultant.SelectedIndex = cbListConsultant.FindItemIndexByValue(cbEndoscopist.SelectedValue)
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error chnaging endoscopist", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "An error changing endoscopists")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveTemplateButton_Click(sender As Object, e As EventArgs)
        Try
            If SlotsRadGrid.Items.Count = 0 Then
                Utilities.SetNotificationStyle(RadNotification1, "List contains 0 slots", True, "Please correct")
                RadNotification1.Show()
                Exit Sub
            End If

            Dim selectedStart = ListStart.Date.Add(StartTimePicker.SelectedTime)
            calculateTime()
            Dim selectedEnd = ListStart.Date.Add(EndTimePicker.SelectedTime)


            Dim selectedDiaries As Dictionary(Of Integer, DateTime) = New Dictionary(Of Integer, DateTime)
            Dim recurranceStart As DateTime
            Dim recurranceEnd As DateTime

            selectedDiaries.Add(DiaryId, selectedStart)

            For Each row As GridDataItem In RecurringDatesRadGrid.Items
                Dim EditListCheckBox As CheckBox = DirectCast(row.FindControl("EditListCheckBox"), CheckBox)
                If EditListCheckBox.Checked Then
                    selectedDiaries.Add(CInt(row.GetDataKeyValue("DiaryId")), CDate(row.GetDataKeyValue("DiaryEnd")))
                End If
            Next

            Dim diaryIds As List(Of Integer) = selectedDiaries.Keys.ToList
            recurranceStart = selectedDiaries.Values.Min
            recurranceEnd = selectedDiaries.Values.Max


            Dim currentDiaryId = 0
            'Room procedures check

            'get list procedures 
            Dim listProcedures As New List(Of Integer)

            If Request.QueryString("mode").ToLower = "new" Then
                For Each row As GridDataItem In SlotsRadGrid.Items
                    If row.CssClass = "slot-point" Then Continue For
                    Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                    If GuidelineComboBox.SelectedValue > 0 Then
                        listProcedures.Add(GuidelineComboBox.SelectedValue)
                    End If
                Next
            ElseIf Request.QueryString("mode").ToLower = "edit" Then
                'get list procedures
                Dim dtListProcedures = DataAdapter_Sch.getListSlots(OperatingHospitalId, ListRulesId)
                For Each dr As DataRow In dtListProcedures.Rows
                    If CInt(dr("ProcedureTypeId")) > 0 Then
                        listProcedures.Add(CInt(dr("ProcedureTypeId")))
                    End If
                Next
            End If

            'check against room procedures
            If listProcedures.Count > 0 Then
                Dim dtRooms = DataAdapter_Sch.GetRoomProcedureTypes(RoomId)
                If dtRooms IsNot Nothing AndAlso dtRooms.Rows.Count > 0 Then
                    If Not dtRooms.AsEnumerable.Any(Function(x) listProcedures.Distinct.Contains(CInt(x("ProcedureTypeId"))) And CInt(x("RoomProcId")) > 0) Then
                        Utilities.SetNotificationStyle(RadNotification1, "This template has procedures that cannot be performed in this room.", True, "Please correct")
                        RadNotification1.Show()
                        Exit Sub
                    End If
                Else
                    Utilities.SetNotificationStyle(RadNotification1, "This template has procedures that cannot be performed in this room.", True, "Please correct")
                    RadNotification1.Show()
                    Exit Sub
                End If
            End If


            'Endoscopist rules
            If (cbGenericTemplate.SelectedIndex > 0 Or cbEndoscopist.SelectedIndex > 0) AndAlso
                        Not Products_Options_Scheduler_DiaryPages.ContainsEndoscopistProcedures(cbEndoscopist.SelectedValue, listProcedures.Distinct.ToList) Then
                Utilities.SetNotificationStyle(RadNotification1, "This template has procedures that your selected endoscopist cannot perform.", True, "Please correct")
                RadNotification1.Show()
                Exit Sub
            End If




            If Request.QueryString("mode").ToLower = "new" Then
                Dim dtList = DataAdapter_Sch.GetDiaryDaySlots(OperatingHospitalId, True, selectedStart, {RoomId}.ToList).AsEnumerable.Where(Function(x) Not diaryIds.Contains(CInt(x("DiaryId"))))

                'overlapped diaries
                If dtList IsNot Nothing AndAlso dtList.Count > 0 Then
                    Dim dayDiaries = dtList
                    If dayDiaries.Any(Function(x) selectedStart >= x("DiaryStart") And selectedStart < x("DiaryEnd")) Or 'starts is in betwen a list
                dayDiaries.Any(Function(x) selectedEnd > x("DiaryStart") And selectedEnd < x("DiaryEnd")) Or 'ends in between a list
                dayDiaries.Any(Function(x) x("DiaryStart") >= selectedStart And x("DiaryStart") < selectedEnd) Then 'spans a list
                        Utilities.SetNotificationStyle(RadNotification1, "Lists cannot overlap", True, "Please correct")
                        RadNotification1.Show()
                        Exit Sub
                    End If
                End If

                'overlapped endoscopist diaries
                Dim endoDiaries = DataAdapter_Sch.EndosopistsDiaryDatesOverlap(cbEndoscopist.SelectedValue, selectedStart, selectedEnd)
                'check if and end diaries start or end date is between this start or end date
                If endoDiaries.AsEnumerable.Any(Function(x) Not diaryIds.Contains(CInt(x("DiaryId")))) Then 'is not the current diary being edited
                    Utilities.SetNotificationStyle(RadNotification1, "Endoscopist has lists that overlap with this one", True, "Please correct")
                    RadNotification1.Show()
                    Exit Sub
                End If

                'endoscopist procedure rules
                If (cbGenericTemplate.SelectedIndex > 0 And cbEndoscopist.SelectedIndex > 0) AndAlso
                   Not Products_Options_Scheduler_DiaryPages.getEndoscopistAppointmentRules(cbEndoscopist.SelectedValue, diaryIds, ListStart.Date, True) Then
                    Utilities.SetNotificationStyle(RadNotification1, "This template is attached to an appointment which has procedures that your selected endoscopist cannot perform.", True, "Please correct")
                    RadNotification1.Show()
                    Exit Sub
                End If

                ListRulesId = SaveSlots(ListNameRadTextBox.Text)
            ElseIf Request.QueryString("mode").ToLower = "edit" Then
                Dim diaryDates = (From sd In selectedDiaries.Values
                                  Select sd.ToString("dd/MM/yyyy")).ToList

                Dim dtDiariesByDate = DataAdapter_Sch.GetDiariesByDates(OperatingHospitalId, True, String.Join(",", diaryDates))
                Dim dtLists As New DataTable
                Dim endoDiaries = DataAdapter_Sch.GetEndosopistsDiaries(cbEndoscopist.SelectedValue, recurranceStart, recurranceEnd)


                Dim existingEndoDiaries As New List(Of DateTime)
                Dim existingDayDiaries As New List(Of DateTime)

                'check if the time has changed. If so, check for overlaps on each day
                If Not selectedStart = ListStart Then
                    'get all diaries in that room between the min and max dates
                    If dtDiariesByDate.AsEnumerable.Any(Function(x) x("RoomId") = RoomId And Not diaryIds.Contains(CInt(x("DiaryId")))) Then
                        'set datatable to only contain records for the selected endoscopist and excluding the current diary from the checks
                        dtLists = dtLists.AsEnumerable.Where(Function(x) x("RoomId") = RoomId And Not diaryIds.Contains(CInt(x("DiaryId")))).CopyToDataTable
                    End If
                End If

                'validate each diary selected to be updated
                For Each itm In selectedDiaries
                    Dim diaryStart As DateTime = itm.Value.Date.Add(selectedStart.TimeOfDay)
                    Dim diaryEnd As DateTime = itm.Value.Date.Add(selectedEnd.TimeOfDay)

                    'overlapped day diaries
                    If dtLists IsNot Nothing AndAlso dtLists.AsEnumerable.Any(Function(x) CDate(x("DiaryStart")).Date = itm.Value.Date) Then
                        Dim dayDiaries = dtLists.AsEnumerable.Where(Function(x) CDate(x("DiaryStart")).Date = itm.Value.Date)

                        If dayDiaries.Any(Function(x) diaryStart >= x("DiaryStart") And diaryStart < x("DiaryEnd")) Or 'starts is in betwen a list
                                dayDiaries.Any(Function(x) diaryEnd > x("DiaryStart") And diaryEnd < x("DiaryEnd")) Or 'ends in between a list
                                dayDiaries.Any(Function(x) x("DiaryStart") >= diaryStart And x("DiaryStart") < diaryEnd) Then 'spans a list

                            existingDayDiaries.Add(diaryStart)

                        End If
                    End If

                    'overlapped endoscopist diaries
                    If endoDiaries.AsEnumerable.Any(Function(x) CDate(x("DiaryStart")).Date = itm.Value.Date) Then
                        Dim dayDiaries = endoDiaries.AsEnumerable.Where(Function(x) CDate(x("DiaryStart")).Date = itm.Value.Date And Not selectedDiaries.Keys.Contains(CInt(x("DiaryId"))))

                        If dayDiaries.AsEnumerable.Any(Function(x) diaryStart >= x("DiaryStart") And diaryStart < x("DiaryEnd")) Or 'starts is in betwen a list
                                dayDiaries.AsEnumerable.Any(Function(x) diaryEnd > x("DiaryStart") And diaryEnd < x("DiaryEnd")) Or 'ends in between a list
                                dayDiaries.AsEnumerable.Any(Function(x) x("DiaryStart") >= diaryStart And x("DiaryStart") < diaryEnd) Then 'spans a list

                            existingEndoDiaries.Add(diaryStart)

                        End If
                    End If

                Next

                If existingDayDiaries.Count > 0 Then
                    Utilities.SetNotificationStyle(RadNotification1, "One or more of your selected lists overlap with an exiting list. Please uncheck the following dates and try again:<br />" & String.Join("<br />", existingDayDiaries.Select(Function(x) "&bull;" & x.ToShortDateString())), True, "Please correct")
                    RadNotification1.Width = "550"
                    RadNotification1.Show()
                    Exit Sub
                End If

                If existingEndoDiaries.Count > 0 Then
                    Utilities.SetNotificationStyle(RadNotification1, "Your selected endoscopist has one or more lists that overlap with your selected ones. Please select a different endoscopist or uncheck the following dates and try again: <br />" & String.Join("<br />", existingEndoDiaries.Select(Function(x) "&bull;" & x.ToShortDateString())), True, "Please correct")
                    RadNotification1.Width = "550"
                    RadNotification1.Show()
                    Exit Sub
                End If
                ListRulesId = cbGenericTemplate.SelectedValue
            End If


            'check against all selected to be edited, or new SP to return all endos lists between all selected list dates dates and compare here
            If Request.QueryString("mode").ToLower = "new" Then

            ElseIf Request.QueryString("mode").ToLower = "edit" Then

            End If

            If Request.QueryString("mode").ToLower = "new" Then

            Else
            End If


            If Request.QueryString("mode").ToLower = "new" Then

                Dim apt As New Appointment
                apt.Resources.Add(New Resource("ListRulesId", ListRulesId, "ListRulesId"))
                apt.Resources.Add(New Resource("IsTrainingList", "IsTrainingList", chkIsTraining.Checked))
                apt.Resources.Add(New Resource("IsGI", "IsGI", True))
                apt.Resources.Add(New Resource("ListGenderId", "ListGenderId", cbListGender.SelectedValue))

                Dim newDiaryId = DataAdapter_Sch.saveDiaryList(ListNameRadTextBox.Text, selectedStart, selectedEnd, RoomId, cbEndoscopist.SelectedValue, "", 0, "", 0, 0, ListRulesId, "", OperatingHospitalIdHiddenField.Value, cbListConsultant.SelectedValue, chkIsTraining.Checked, cbListGender.SelectedValue, True)

                If RepeatPatternRadioButtonList.SelectedIndex > 0 Then




                    Dim repeatPattern = RepeatPatternRadioButtonList.SelectedValue
                    Dim repeatCount = RepeatCountTextBox.Text
                    Dim repeatStart = selectedStart
                    Dim repeateEnd = selectedEnd

                    Select Case repeatPattern
                        Case "d"
                            repeateEnd = selectedStart.AddDays(repeatCount)
                        Case "w"
                            repeateEnd = selectedStart.AddDays((7 * repeatCount))
                        Case "m"
                            repeateEnd = selectedStart.AddMonths(repeatCount)
                    End Select



                    Dim diaryStart = selectedStart
                    Dim diaryEnd = selectedEnd

                    Dim overlappedDates As New List(Of String)
                    'get all the lists in that room between the 2 dates (loop through in for each)
                    Dim roomLists = DataAdapter_Sch.getRoomDiaries(RoomId, repeatStart, repeateEnd)

                    For i As Integer = 1 To repeatCount - 1 'start from the next interval

                        Select Case repeatPattern
                            Case "d"
                                diaryStart = selectedStart.AddDays(i)
                                diaryEnd = selectedEnd.AddDays(i)
                            Case "w"
                                diaryStart = selectedStart.AddDays((7 * i))
                                diaryEnd = selectedEnd.AddDays((7 * i))
                            Case "m"
                                'get 1st day of the month
                                Dim newMonthStart = CDate("01/" & diaryStart.AddMonths(1).Month & " /" & diaryStart.AddMonths(1).Year).Date.Add(diaryStart.TimeOfDay) 'diaryStart.AddDays(-diaryStart.Day + 1).AddMonths(1).AddDays((diaryStart.DayOfWeek) - diaryStart.AddDays(-diaryStart.Day).AddMonths(1).DayOfWeek)

                                'get 1st (desired) weekday of the month
                                While Not newMonthStart.DayOfWeek = selectedStart.DayOfWeek
                                    newMonthStart = newMonthStart.AddDays(1)
                                End While

                                'inc to desired week period
                                diaryStart = newMonthStart.AddDays(7 * (MonthFrequencyRadNumericTextBox.Value - 1)) 'get 1st day of the month, add 1 day then get the 1st day of the month and a
                                diaryEnd = newMonthStart.AddDays(7 * (MonthFrequencyRadNumericTextBox.Value - 1)).Date.Add(diaryEnd.TimeOfDay)
                        End Select

                        'check for overlapped diaries on this date
                        If roomLists.AsEnumerable.Any(Function(x) (diaryStart >= CDate(x("DiaryStart")) And diaryStart < CDate(x("DiaryEnd"))) Or diaryEnd > CDate(x("DiaryStart")) And diaryEnd <= CDate(x("DiaryEnd"))) Then
                            overlappedDates.Add(diaryStart.ToShortDateString)
                        Else
                            'create new set of list slots
                            ListRulesId = SaveSlots(ListNameRadTextBox.Text)

                            DataAdapter_Sch.saveDiaryList(ListNameRadTextBox.Text, diaryStart, diaryEnd, RoomId, cbEndoscopist.SelectedValue, repeatPattern, repeatCount, selectedStart.DayOfWeek.ToString(), MonthFrequencyRadNumericTextBox.Value, newDiaryId, ListRulesId, "", OperatingHospitalIdHiddenField.Value, cbListConsultant.SelectedValue, chkIsTraining.Checked, cbListGender.SelectedValue, True)
                        End If
                    Next

                    If overlappedDates.Count > 0 Then
                        Utilities.SetNotificationStyle(RadNotification1, "1 or more of your orrucances overlapped with an existing list on " & String.Join(",", overlappedDates), True, "Lists not added")
                        RadNotification1.Show()
                    End If
                End If

                'RaiseEvent Template_Added(Me.Page, Appointment)
            ElseIf Request.QueryString("mode").ToLower = "edit" Then
                Dim newAppointment As New Appointment
                With newAppointment
                    .ID = DiaryIdHiddenField.Value
                    .Resources.Add(New Resource("Endoscopist", cbEndoscopist.SelectedValue, "Endoscopist"))
                    .Resources.Add(New Resource("ListConsultant", cbListConsultant.SelectedValue, "ListConsultant"))
                    .Resources.Add(New Resource("ListGenderId", "ListGenderId", cbListGender.SelectedValue))
                    .Start = selectedStart
                    .End = selectedEnd

                    .Subject = ListNameRadTextBox.Text
                    .Resources.Add(New Resource("ListRulesId", ListRulesId, "ListRulesId"))
                    .Resources.Add(New Resource("Room", RoomId, "Room"))
                    .Resources.Add(New Resource("IsTrainingList", "IsTrainingList", chkIsTraining.Checked))
                    .Resources.Add(New Resource("IsGI", "IsGI", True))
                    .Resources.Add(New Resource("ListGenderId", "ListGenderId", cbListGender.SelectedValue))
                End With

                DataAdapter_Sch.saveDiaryList(ListNameRadTextBox.Text, selectedStart, selectedEnd, RoomId, cbEndoscopist.SelectedValue, "", 0, "", 0, 0, ListRulesId, "", OperatingHospitalIdHiddenField.Value, cbListConsultant.SelectedValue, chkIsTraining.Checked, cbListGender.SelectedValue, True, diaryIds)
                'RaiseEvent Template_Updated(Me.Page, Appointment, newAppointment)
            End If

            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-wind", "CloseAndRebind();", True)

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error saving template", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error saving the template")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub Template_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        e.Item.Attributes.Add("training", DirectCast(e.Item.DataItem, System.Data.DataRowView).Row("Training"))
    End Sub

    Protected Sub cbGenericTemplate_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            Dim tblSlots As DataTable = New DataTable

            ListRulesId = cbGenericTemplate.SelectedValue
            intDefaultSlothLengthMinutes = 15
            EndTimePicker.SelectedDate = StartTimePicker.SelectedDate

            initSlotDT(tblSlots)
            initGrid()

            If cbGenericTemplate.SelectedValue = 0 Then
                ListSlotsDiv.Visible = False
            Else
                If Not cbGenericTemplate.SelectedValue = -99 Then
                    SelectList()
                    EndTimePicker.SelectedDate = StartTimePicker.SelectedDate.Value.AddMinutes(TotalMinutes)
                End If

                ListSlotsDiv.Visible = True
            End If
        Catch ex As Exception

        End Try
    End Sub

    'Public Function SaveSlots(listName As String) As Integer

    '    Using db As New ERS.Data.GastroDbEntities
    '        Try
    '            Dim sqlStr As String = ""
    '            Dim sqlSlots As String = ""

    '            Dim nonGIProcedureTypeId As Integer = 0
    '            Dim nonGIPointsPerMinute As Integer = 0
    '            Dim diagnosticCallinTime As Integer = 0
    '            Dim diagnosticPoints As Integer = 0
    '            Dim therapeuticCallInTime As Integer = 0
    '            Dim therapeuticPoints As Integer = 0


    '            Dim ERS_ListRules As New ERS.Data.ERS_SCH_ListRules

    '            With ERS_ListRules
    '                .TotalMins = 0
    '                .Points = 0 'TotalPointsLabel.Text
    '                .ListName = listName
    '                .OperatingHospitalId = OperatingHospitalIdHiddenField.Value
    '                .GIProcedure = GIProcedure
    '                .Training = IsTraining
    '                .NonGIProcedureTypeId = nonGIProcedureTypeId
    '                .NonGIProcedureMinutesPerPoint = nonGIPointsPerMinute
    '                .NonGIDiagnosticCallInTime = diagnosticCallinTime
    '                .NonGIDiagnosticProcedurePoints = diagnosticPoints
    '                .NonGITherapeuticCallInTime = therapeuticCallInTime
    '                .NonGITherapeuticProcedurePoints = therapeuticPoints
    '                .GenderId = If(cbListGender.SelectedValue = 0, Nothing, cbListGender.SelectedValue)
    '                .IsTemplate = False 'Always false unless created from the Templates page
    '            End With

    '            ERS_ListRules.WhoCreatedId = CInt(Session("PKUserID"))
    '            ERS_ListRules.WhenCreated = Now
    '            db.ERS_SCH_ListRules.Add(ERS_ListRules)

    '            db.SaveChanges() 'to get the list rules id for the list slots

    '            Dim ERS_ListSlots As New List(Of ERS.Data.ERS_SCH_ListSlots)
    '            'ERS_ListSlots = ucListTemplateSlots.saveListSlots(ERS_ListRules.ListRulesId)

    '            ERS_ListRules.TotalMins = ERS_ListSlots.Sum(Function(x) x.SlotMinutes)
    '            ERS_ListRules.Points = ERS_ListSlots.Sum(Function(x) x.Points)

    '            db.ERS_SCH_ListRules.Attach(ERS_ListRules)
    '            db.Entry(ERS_ListRules).State = Entity.EntityState.Modified

    '            db.ERS_SCH_ListSlots.AddRange(ERS_ListSlots)
    '            db.SaveChanges()


    '            Return ERS_ListRules.ListRulesId
    '        Catch ex As Exception
    '            Throw ex
    '        End Try
    '    End Using
    'End Function

#Region "Template stuff"


    Public Function initSlotDT(ByRef tblSlots As DataTable) As DataTable
        'tblSlots.Columns.Add("SlotRowId", GetType(Decimal))
        tblSlots.Columns.Add("LstSlotId", GetType(Decimal))
        tblSlots.Columns.Add("SlotId", GetType(Integer))
        tblSlots.Columns.Add("ProcedureTypeId", GetType(Integer))
        tblSlots.Columns.Add("Points", GetType(Decimal))
        tblSlots.Columns.Add("Suppressed", GetType(Boolean))
        tblSlots.Columns.Add("ParentId", GetType(Integer))
        tblSlots.Columns.Add("Minutes", GetType(Integer))
        tblSlots.Columns.Add("AppointmentId", GetType(Integer))

        Return tblSlots
    End Function

    Public Sub initGrid()
        Dim tblSlots As DataTable = New DataTable
        SlotsRadGrid.DataSource = tblSlots
        SlotsRadGrid.DataBind()
        TotalPointsLabel.Text = 0
        GenerateSlotButton.Enabled = True


    End Sub

    Private Sub calculateTime()
        Dim totalMinutes As Integer

        If StartTimePicker.SelectedDate.HasValue Then
            For Each item As GridDataItem In SlotsRadGrid.Items
                Dim SlotLengthRadNumericTextBox As RadNumericTextBox = item.FindControl("SlotLengthRadNumericTextBox")
                totalMinutes += CInt(SlotLengthRadNumericTextBox.Text)
            Next

            EndTimePicker.SelectedDate = StartTimePicker.SelectedDate.Value.AddMinutes(totalMinutes)
            'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-end-time", "setEndTime('" & endTime.ToShortTimeString & "');", True)
        End If
    End Sub

    Private Sub calculatePoints()
        Dim totalPoints As Decimal = 0
        For Each item As GridDataItem In SlotsRadGrid.Items
            Dim PointsNumericTextBox As RadNumericTextBox = item.FindControl("PointsRadNumericTextBox")
            Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
            totalPoints += SlotPoints
        Next

        TotalPointsLabel.Text = totalPoints
    End Sub

    Private Sub fillEditForm(ListRulesId As Integer)
        Dim da As New DataAccess_Sch
        Dim dt As DataRow = da.GetTemplate(ListRulesId).Rows(0)
        'If dt("GIProcedure") Then
        '    GIProcedureRBL.SelectedValue = "1"
        'Else
        '    'SlotsRadGrid.Style.Item("height") = 280
        '    GIProcedureRBL.SelectedValue = "0"
        'End If
        TotalPointsLabel.Text = dt("Points")

    End Sub

    Public Sub SelectList(Optional slotQty As Integer = 1, Optional procedureTypeId As Integer = 0, Optional points As Decimal = 1, Optional length As Integer = 15, Optional slotType As Integer = 0)
        Try
            Dim totalPoints = 0

            '#### First time page is loaded (ListRulesId > 0), get data from db - else generate slots from codebehind 
            If ListRulesId > 0 Then
                SlotsRadGrid.DataSource = DataAdapter_Sch.getListSlots(OperatingHospitalId, ListRulesId)

                If SlotsRadGrid.DataSource Is Nothing Then
                    Dim tblSlots As DataTable = New DataTable
                    initSlotDT(tblSlots)
                    SlotsRadGrid.DataSource = tblSlots
                    SlotsRadGrid.DataBind()
                Else
                    SlotsRadGrid.DataBind()
                    calculatePoints()
                    calculateTime()
                End If
            Else
                Dim cnt As Integer = 1
                Dim rowId As Decimal = 1

                Dim tblSlots As DataTable = New DataTable
                initSlotDT(tblSlots)

                Dim da As New DataAccess_Sch

                '## Looping through grid just to repopulate the same values already displayed or from user amendments
                For Each row As GridDataItem In SlotsRadGrid.Items
                    Dim LstSlotId As String = (row("LstSlotId").Text)
                    Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
                    Dim SlotId As String = SlotComboBox.SelectedValue
                    Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                    Dim Guideline As String = GuidelineComboBox.SelectedValue
                    Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
                    Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
                    Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
                    Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
                    Dim Suppressed As Boolean = False
                    Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
                    If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = True


                    tblSlots.Rows.Add(cnt, SlotId, Guideline, SlotPoints, Suppressed, 0, SlotMinutes)
                    cnt = cnt + 1
                Next

                If slotQty > 0 Then
                    For i = 0 To slotQty - 1
                        tblSlots.Rows.Add(i, slotType, procedureTypeId, points, False, 0, length)
                        cnt = cnt + 1
                    Next
                Else
                    tblSlots.Rows.Add(cnt, 1, 0, 1, False, 0, 15)
                    cnt = cnt + 1
                End If


                SlotsRadGrid.DataSource = tblSlots
                SlotsRadGrid.DataBind()
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Protected Sub SlotsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Try
            Dim selectedIndex = e.Item.ItemIndex
            Dim cnt As Integer = 1
            Dim rowId As Decimal = 1

            Dim tblSlots As DataTable = New DataTable
            initSlotDT(tblSlots)

            For Each row As GridDataItem In SlotsRadGrid.Items
                Dim LstSlotId As String = (row("LstSlotId").Text)
                Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
                Dim SlotId As String = SlotComboBox.SelectedValue
                Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                Dim Guideline As String = GuidelineComboBox.SelectedValue
                Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
                Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
                Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
                Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
                Dim Suppressed As Boolean = False
                Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
                If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = True


                tblSlots.Rows.Add(cnt, SlotId, Guideline, SlotPoints, Suppressed, 0, SlotMinutes)

                cnt = cnt + 1
            Next

            tblSlots.Rows.RemoveAt(selectedIndex)

            SlotsRadGrid.DataSource = tblSlots
            SlotsRadGrid.DataBind()
            calculatePoints()
            calculateTime()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error in SlotsRadGrid_ItemCommand", ex)
            Throw ex
        End Try
    End Sub

    Protected Sub SlotComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        Dim dataItemForeColor = CType(e.Item.DataItem, DataRowView).Row("ForeColor").ToString()
        e.Item.BackColor = System.Drawing.ColorTranslator.FromHtml(dataItemForeColor)
    End Sub

    Protected Sub GuidelineComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            Dim ProcedureTypeDDL = CType(sender, RadComboBox)
            Dim gridItem = CType(ProcedureTypeDDL.NamingContainer, GridItem)

            Dim Points As Decimal = 1
            Dim Minutes As Integer = 15
            Dim iOperatingHospitalId = OperatingHospitalId
            Dim iProcedureTypeId = ProcedureTypeDDL.SelectedValue

            If ProcedureTypeDDL.SelectedValue > 0 Then
                Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & IsTraining & " AND NonGI = 0"
                Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    Points = Convert.ToDecimal(dt.Rows(0)("Points"))
                    Minutes = CInt(dt.Rows(0)("Minutes"))
                End If
            End If

            CType(gridItem.FindControl("PointsRadNumericTextBox"), RadNumericTextBox).Text = Points
            CType(gridItem.FindControl("SlotLengthRadNumericTextBox"), RadNumericTextBox).Text = Minutes

            calculatePoints()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on edit templates page.", ex)
            Throw ex
        End Try
    End Sub

    Protected Sub SlotsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try

        Catch ex As Exception

        End Try
    End Sub

    Protected Sub ProcedureTypesComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            Dim ProcedureTypeDDL = CType(sender, RadComboBox)

            Dim Points As Decimal = 1
            Dim Minutes As Integer = 15
            Dim iOperatingHospitalId = OperatingHospitalIdHiddenField.Value 'OperatingHospitalDropdown.SelectedValue
            Dim iProcedureTypeId = ProcedureTypeDDL.SelectedValue

            'If ProcedureTypeDDL.SelectedValue > 0 Then
            Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & Convert.ToByte(IsTraining) & " AND NonGI = " & Convert.ToByte(Not GIProcedure)
            Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                Points = Convert.ToDecimal(dt.Rows(0)("Points"))
                Minutes = CInt(dt.Rows(0)("Minutes"))
            Else
                PointsRadNumericTextBox.Text = 1
                SlotLengthRadNumericTextBox.Text = 15
            End If
            'End If

            PointsRadNumericTextBox.Text = Points
            SlotLengthRadNumericTextBox.Text = Minutes
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error during procedure dropdown postback", ex)
            'Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error retrieving procedure points")
            'RadNotification1.Show()

            PointsRadNumericTextBox.Text = 1
            SlotLengthRadNumericTextBox.Text = 15
        End Try
    End Sub

    Protected Sub btnSaveAndApply_Click(sender As Object, e As EventArgs)
        SelectList(SlotQtyRadNumericTextBox.Value, ProcedureTypesComboBox.SelectedValue, PointsRadNumericTextBox.Value, SlotLengthRadNumericTextBox.Value, SlotComboBox.SelectedValue)

        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "applyandclose", "closeAddNewWindow();", True)
        calculatePoints()
        calculateTime()
    End Sub

    Public Function saveListSlots(listRulesId As Integer) As List(Of ERS.Data.ERS_SCH_ListSlots)
        Dim ERS_ListSlots As New List(Of ERS.Data.ERS_SCH_ListSlots)
        Dim totalMinutes As Integer

        For Each row As GridDataItem In SlotsRadGrid.Items
            If row.CssClass = "slot-point" Then Continue For
            Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
            Dim SlotId As String = SlotComboBox.SelectedValue
            Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
            Dim Guideline As String = If(SlotsRadGrid.Columns(2).Display, GuidelineComboBox.SelectedValue, "0")
            Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
            Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)

            Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
            Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
            totalMinutes += SlotMinutes

            Dim Suppressed As Byte = 0
            Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
            If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = 1

            ERS_ListSlots.Add(New ERS.Data.ERS_SCH_ListSlots With {
                    .ListRulesId = listRulesId,
                    .ProcedureTypeId = Guideline,
                    .Suppressed = Suppressed,
                    .SlotId = SlotId,
                    .OperatingHospitalId = OperatingHospitalIdHiddenField.Value,
                    .WhoCreatedId = CInt(Session("PKUserID")),
                    .WhenCreated = Now,
                    .SlotMinutes = SlotMinutes,
                    .Points = SlotPoints,
                    .Active = True
                    })
        Next

        Return ERS_ListSlots
    End Function

    Public Function SaveSlots(listName As String) As Integer

        Using db As New ERS.Data.GastroDbEntities
            Try
                'If CInt(TotalPointsLabel.Text) = 0 And SlotsRadGrid.Items.Count = 0 Then
                '    'Utilities.SetNotificationStyle(RadNotification1, "This template contains 0 slots", True, "Please correct")
                '    'RadNotification1.Show()
                '    'Exit Sub
                'End If

                If Not GIProcedure Then 'non gi template
                    'check a procedure types been set
                    Dim canContinue = True
                    For Each row As GridDataItem In SlotsRadGrid.Items
                        If row.CssClass = "slot-point" Then Continue For
                        Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                        Dim Guideline As String = If(SlotsRadGrid.Columns(2).Display, GuidelineComboBox.SelectedValue, "0")
                        If Guideline = "0" Then
                            canContinue = False
                            Exit For
                        End If
                    Next

                    If Not canContinue Then
                        'Utilities.SetNotificationStyle(RadNotification1, "Non-GI templates cannot contain non-reserved slots.", True, "Please correct")
                        'RadNotification1.Show()
                        'Exit Sub
                    End If
                End If

                Dim sqlStr As String = ""
                Dim sqlSlots As String = ""

                Dim nonGIProcedureTypeId As Integer = 0
                Dim nonGIPointsPerMinute As Integer = 0
                Dim diagnosticCallinTime As Integer = 0
                Dim diagnosticPoints As Integer = 0
                Dim therapeuticCallInTime As Integer = 0
                Dim therapeuticPoints As Integer = 0


                Dim ERS_ListRules As New ERS.Data.ERS_SCH_ListRules

                With ERS_ListRules
                    .Points = TotalPointsLabel.Text
                    .ListName = listName
                    .OperatingHospitalId = OperatingHospitalIdHiddenField.Value
                    .GIProcedure = GIProcedure
                    .Training = IsTraining
                    .NonGIProcedureTypeId = nonGIProcedureTypeId
                    .NonGIProcedureMinutesPerPoint = nonGIPointsPerMinute
                    .NonGIDiagnosticCallInTime = diagnosticCallinTime
                    .NonGIDiagnosticProcedurePoints = diagnosticPoints
                    .NonGITherapeuticCallInTime = therapeuticCallInTime
                    .NonGITherapeuticProcedurePoints = therapeuticPoints
                    .GenderId = If(cbListGender.SelectedValue = 0, Nothing, cbListGender.SelectedValue)
                    .IsTemplate = False 'Always false unless created from the Templates page
                End With

                ERS_ListRules.WhoCreatedId = CInt(Session("PKUserID"))
                ERS_ListRules.WhenCreated = Now
                db.ERS_SCH_ListRules.Add(ERS_ListRules)

                db.SaveChanges() 'to get the list rules id for the list slots

                Dim ERS_ListSlots As New List(Of ERS.Data.ERS_SCH_ListSlots)
                Dim totalMinutes As Integer

                For Each row As GridDataItem In SlotsRadGrid.Items
                    If row.CssClass = "slot-point" Then Continue For
                    Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
                    Dim SlotId As String = SlotComboBox.SelectedValue
                    Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                    Dim Guideline As String = If(SlotsRadGrid.Columns(2).Display, GuidelineComboBox.SelectedValue, "0")
                    Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
                    Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)

                    Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
                    Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
                    totalMinutes += SlotMinutes

                    Dim Suppressed As Byte = 0
                    Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
                    If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = 1

                    ERS_ListSlots.Add(New ERS.Data.ERS_SCH_ListSlots With {
                    .ListRulesId = ERS_ListRules.ListRulesId,
                    .ProcedureTypeId = Guideline,
                    .Suppressed = Suppressed,
                    .SlotId = SlotId,
                    .OperatingHospitalId = OperatingHospitalIdHiddenField.Value,
                    .WhoCreatedId = CInt(Session("PKUserID")),
                    .WhenCreated = Now,
                    .SlotMinutes = SlotMinutes,
                    .Points = SlotPoints,
                    .Active = True
                    })
                Next

                ERS_ListRules.TotalMins = totalMinutes
                db.ERS_SCH_ListRules.Attach(ERS_ListRules)
                db.Entry(ERS_ListRules).State = Entity.EntityState.Modified

                db.ERS_SCH_ListSlots.AddRange(ERS_ListSlots)
                db.SaveChanges()


                Return ERS_ListRules.ListRulesId
            Catch ex As Exception
                Throw ex
            End Try
        End Using
    End Function

    Protected Sub chkShowCustom_CheckedChanged(sender As Object, e As EventArgs)
        Try
            Dim templates = DataAdapter_Sch.GetGenericTemplates(OperatingHospitalIdHiddenField.Value, chkShowCustom.Checked).AsEnumerable '.Where(Function(x) x("Suppressed") = 0)
            templates = templates.Where(Function(x) x("Suppressed") = 0)
            If templates.Count > 0 Then
                cbGenericTemplate.DataSource = templates.CopyToDataTable
                cbGenericTemplate.DataTextField = "ListName"
                cbGenericTemplate.DataValueField = "ListRulesId"
                cbGenericTemplate.DataBind()

            End If

            cbGenericTemplate.Items.Insert(0, New RadComboBoxItem("", 0))
            cbGenericTemplate.Items.Insert(1, New RadComboBoxItem("New template", -99))
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading templates", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading templates")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SlotLengthRadNumericTextBox_TextChanged(sender As Object, e As EventArgs)
        calculateTime()
    End Sub

    Protected Sub PointsRadNumericTextBox_TextChanged(sender As Object, e As EventArgs)
        calculatePoints()
    End Sub

    Protected Sub DateInput3_TextChanged()
        calculateTime()
        calculatePoints()
    End Sub

    Protected Sub StartTimePicker_SelectedDateChanged(sender As Object, e As SelectedDateChangedEventArgs)
        calculateTime()
        calculatePoints()
    End Sub

#End Region
End Class
