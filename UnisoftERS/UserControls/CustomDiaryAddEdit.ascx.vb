Imports System.ComponentModel
Imports Telerik.Web.UI

Public Class CustomDiaryAddEdit
    Inherits System.Web.UI.UserControl

    Public Enum RadSchedulerAdvancedFormAdvancedFormMode
        Insert
        Edit
    End Enum

    Public intDefaultSlothLengthMinutes As Integer = 15

    ReadOnly Property GIProcedure As Boolean
        Get
            Return rblListType.SelectedValue
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

    Private _mode As RadSchedulerAdvancedFormAdvancedFormMode = RadSchedulerAdvancedFormAdvancedFormMode.Insert

    Public Property Mode() As RadSchedulerAdvancedFormAdvancedFormMode
        Get
            Return _mode
        End Get
        Set(ByVal value As RadSchedulerAdvancedFormAdvancedFormMode)
            _mode = value
        End Set
    End Property

    Protected ReadOnly Property Owner() As RadScheduler
        Get
            Return Appointment.Owner
        End Get
    End Property

    Public ReadOnly Property Appointment() As Appointment
        Get
            Dim container As SchedulerFormContainer = DirectCast(BindingContainer, SchedulerFormContainer)
            Return container.Appointment
        End Get
    End Property

    Private _hasAppointments As Boolean
    Public Property HasAppointmentsAttached() As Boolean
        Get
            Return _hasAppointments
        End Get
        Set(ByVal value As Boolean)
            _hasAppointments = value
        End Set
    End Property
#End Region

#Region "Attributes and resources"
    <Bindable(BindableSupport.Yes, BindingDirection.TwoWay)>
    Private _operatingHospitalId As Integer
    Public Property OperatingHospitalId() As Integer
        Get
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
            If _listRulesId = 0 AndAlso Appointment.Resources.Where(Function(x) x.Type = "Template").FirstOrDefault IsNot Nothing Then
                _listRulesId = Appointment.Resources.Where(Function(x) x.Type = "Template").FirstOrDefault.Key
            End If
            Return _listRulesId
        End Get

        Set(ByVal value As Integer)
            _listRulesId = value
        End Set
    End Property

    <Bindable(BindableSupport.Yes, BindingDirection.TwoWay)>
    Public Property RoomId() As Integer
        Get
            Return Appointment.Resources.Where(Function(x) x.Type = "Room").FirstOrDefault.Key
        End Get

        Set(ByVal value As Integer)
            If Not Appointment.Resources.Any(Function(x) x.Type = "Room") Then
                Appointment.Resources.Add(New Resource("Room", value, "Room"))
            End If
        End Set
    End Property

    <Bindable(BindableSupport.Yes, BindingDirection.TwoWay)>
    Private _start As DateTime
    Public Property Start() As DateTime
        Get
            Return Owner.DisplayToUtc(_start)
        End Get

        Set(ByVal value As DateTime)
            _start = Owner.UtcToDisplay(value)
        End Set
    End Property

    <Bindable(BindableSupport.Yes, BindingDirection.TwoWay)>
    Private _end As DateTime
    Public Property [End]() As DateTime
        Get
            Return Owner.DisplayToUtc(_end)
        End Get

        Set(ByVal value As DateTime)
            _end = Owner.UtcToDisplay(value)
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

            rblListType.SelectedValue = 1
            loadDropdowns()
            ucListTemplateSlots.initGrid()

            FormInitialized = True
            If Mode = RadSchedulerAdvancedFormAdvancedFormMode.Edit Then
                populateForm()
                ListSlotsDiv.Visible = False
            End If

        End If
    End Sub

    Private Sub populateForm()
        Try
            DiaryIdHiddenField.Value = Appointment.ID
            'get diary details from DB and populate the controls
            Dim dtDiaryDetails = DataAdapter_Sch.GetListDiaryDetails(Appointment.ID)

            If dtDiaryDetails IsNot Nothing AndAlso dtDiaryDetails.Rows.Count > 0 Then
                Dim drDiaryDetails = dtDiaryDetails.Rows(0)

                ListNameRadTextBox.Text = drDiaryDetails("Subject")
                ListRulesId = drDiaryDetails("ListRulesId")
                DiaryId = Appointment.ID

                loadDropdowns()

                'template (incase the templates been deleted or suppressed)
                If cbGenericTemplate.FindItemIndexByValue(ListRulesId) > 0 Then
                    cbGenericTemplate.SelectedValue = ListRulesId
                End If
                cbGenericTemplate.Enabled = False

                'endoscopist
                cbEndoscopist.SelectedValue = CInt(drDiaryDetails("EndoscopistId"))

                'list consultant
                cbListConsultant.SelectedValue = CInt(drDiaryDetails("ListConsultantId"))

                'Training
                chkIsTraining.Checked = CBool(drDiaryDetails("Training"))

                'Gender
                If Not drDiaryDetails.IsNull("ListGenderId") Then
                    cbListGender.SelectedValue = drDiaryDetails("ListGenderId")
                End If

                If Not drDiaryDetails.IsNull("IsGI") Then
                    'GI Procedure
                    rblListType.SelectedValue = If(drDiaryDetails("IsGI"), 1, 0)
                End If

                'startdate
                StartTimePicker.SelectedDate = CDate(drDiaryDetails("DiaryStart"))

                If Not drDiaryDetails.IsNull("Appointments") AndAlso CBool(drDiaryDetails("Appointments")) Then
                    StartTimePicker.Enabled = False
                End If
                'enddate
                EndTimePicker.SelectedDate = CDate(drDiaryDetails("DiaryEnd"))

                If Mode = RadSchedulerAdvancedFormAdvancedFormMode.Insert Then
                    'load slots
                    ucListTemplateSlots.SelectList()
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

    Protected Sub rblListType_SelectedIndexChanged(sender As Object, e As EventArgs)
        Try
            loadDropdowns()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error chnaging template type to " & rblListType.SelectedItem.Text, ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "An error occured loading the form")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub loadDropdowns()
        'load endoscopists
        cbEndoscopist.DataSource = DataAdapter_Sch.GetEndoscopists(rblListType.SelectedValue)
        cbEndoscopist.DataTextField = "EndoName"
        cbEndoscopist.DataValueField = "UserId"
        cbEndoscopist.DataBind()
        cbEndoscopist.Items.Insert(0, New RadComboBoxItem("", 0))

        cbListConsultant.DataSource = DataAdapter_Sch.GetEndoscopists(rblListType.SelectedValue)
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
        Dim templates = DataAdapter_Sch.GetGenericTemplates(OperatingHospitalIdHiddenField.Value).AsEnumerable '.Where(Function(x) x("Suppressed") = 0)
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
            Dim ref = LogManager.LogManagerInstance.LogError("Error chnaging template type to " & rblListType.SelectedItem.Text, ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "An error occured loading the form")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveTemplateButton_Click(sender As Object, e As EventArgs)
        Try
            'If cbGenericTemplate.SelectedIndex = 0 Then
            '    Utilities.SetNotificationStyle(RadNotification1, "You must select a template", True, "Please correct")
            '    RadNotification1.Show()
            '    Exit Sub
            'End If

            If Mode = RadSchedulerAdvancedFormAdvancedFormMode.Insert Then
                ListRulesId = SaveSlots(ListNameRadTextBox.Text)
            End If

            Dim selectedStart = Appointment.Start.Date.Add(StartTimePicker.SelectedTime)

            'set end time based on the template. Maybe hide the control and let it be updated in DB
            Dim selectedEnd = Appointment.End.Date.Add(EndTimePicker.SelectedTime)

            If cbEndoscopist.SelectedIndex = 0 Then
                Utilities.SetNotificationStyle(RadNotification1, "You must select an endoscopist", True, "Please correct")
                RadNotification1.Show()
                Exit Sub
            End If

            If rblListType.SelectedValue = 1 Then 'Validate GI Procedures only
                'Room procedures
                If Not Products_Options_Scheduler_DiaryPages.IsProcedureRoom(RoomId, ListRulesId) Then
                    Utilities.SetNotificationStyle(RadNotification1, "This template has procedures that cannot be performed in this room.", True, "Please correct")
                    RadNotification1.Show()
                    Exit Sub
                End If

                'Endoscopist rules
                If rblListType.SelectedValue = 1 And (0 > 0 And cbEndoscopist.SelectedIndex > 0) AndAlso
                        Not Products_Options_Scheduler_DiaryPages.ContainsEndoscopistProcedures(cbEndoscopist.SelectedValue, New List(Of Integer)) Then
                    Utilities.SetNotificationStyle(RadNotification1, "This template has procedures that your selected endoscopist cannot perform.", True, "Please correct")
                    RadNotification1.Show()
                    Exit Sub
                End If

                Dim currentDiaryId = 0
                If Mode = RadSchedulerAdvancedFormAdvancedFormMode.Edit Then
                    currentDiaryId = If(Appointment.ID = 0, If(Appointment.RecurrenceParentID, 0), Appointment.ID)
                End If

                If currentDiaryId > 0 Then
                    If (cbGenericTemplate.SelectedIndex > 0 And cbEndoscopist.SelectedIndex > 0) AndAlso
                       Not Products_Options_Scheduler_DiaryPages.getEndoscopistAppointmentRules(cbEndoscopist.SelectedValue, {currentDiaryId}.ToList, Appointment.Start.Date, True) Then
                        Utilities.SetNotificationStyle(RadNotification1, "This template is attached to an appointment which has procedures that your selected endoscopist cannot perform.", True, "Please correct")
                        RadNotification1.Show()
                        Exit Sub
                    End If
                End If
            End If

            If cbListConsultant.SelectedIndex = 0 Then
                Utilities.SetNotificationStyle(RadNotification1, "You must select a list consultant", True, "Please correct")
                RadNotification1.Show()
                Exit Sub
            End If


            Dim appointmentsInRange = Owner.Appointments.GetAppointmentsInRange(selectedStart, selectedEnd).Where(Function(x) x.Start > selectedStart.Date)
            If Mode = RadSchedulerAdvancedFormAdvancedFormMode.Edit Then appointmentsInRange = appointmentsInRange.Where(Function(x) Not x.ID.ToString.Replace("_0", "") = If(Appointment.ID, Appointment.RecurrenceParentID))

            'check for room clash
            If appointmentsInRange.Any(Function(x) x.Resources.Any(Function(y) y.Type = "Room")) Then

                If appointmentsInRange.Where(Function(x) x.Resources.Where(Function(y) y.Type = "Room").FirstOrDefault.Key = RoomId).Count > 0 Then
                    Utilities.SetNotificationStyle(RadNotification1, "Diaries cannot overlap.", True, "Please correct")
                    RadNotification1.Show()
                    Exit Sub
                End If
            End If

            'check for endo clash
            Dim endosAppointmentsInRange = appointmentsInRange.Where(Function(x) x.Resources.Any(Function(y) y.Type = "Endoscopist") AndAlso x.Resources.Where(Function(y) y.Type = "Endoscopist").FirstOrDefault.Key = cbEndoscopist.SelectedValue)

            If endosAppointmentsInRange.Count > 0 Then
                Utilities.SetNotificationStyle(RadNotification1, "This endoscopist has diaries that overlap with this one.", True, "Please correct")
                RadNotification1.Show()
                Exit Sub
            End If

            'check for list consultant clash
            Dim consultantsAppointmentsInRange = appointmentsInRange.Where(Function(x) x.Resources.Any(Function(y) y.Type = "ListConsultant") AndAlso x.Resources.Where(Function(y) y.Type = "ListConsultant").FirstOrDefault.Key = cbListConsultant.SelectedValue)

            If consultantsAppointmentsInRange.Count > 0 Then
                Utilities.SetNotificationStyle(RadNotification1, "This list consultant has diaries that overlap with this one.", True, "Please correct")
                RadNotification1.Show()
                Exit Sub
            End If



            If Mode = RadSchedulerAdvancedFormAdvancedFormMode.Insert Then


                Appointment.Resources.Add(New Resource("ListRulesId", ListRulesId, "ListRulesId"))
                Appointment.Resources.Add(New Resource("IsTrainingList", "IsTrainingList", chkIsTraining.Checked))
                Appointment.Resources.Add(New Resource("IsGI", "IsGI", rblListType.SelectedValue))
                Appointment.Resources.Add(New Resource("ListGenderId", "ListGenderId", cbListGender.SelectedValue))

                Dim newDiaryId = 0 'DataAdapter_Sch.saveDiaryList(ListNameRadTextBox.Text, selectedStart, selectedEnd, RoomId, cbEndoscopist.SelectedValue, "", 0, 0, ListRulesId, "", OperatingHospitalIdHiddenField.Value, cbListConsultant.SelectedValue, chkIsTraining.Checked, cbListGender.SelectedValue, rblListType.SelectedValue)

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

                    For i As Integer = 1 To repeatCount 'start from the next interval

                        'i += 1
                        Select Case repeatPattern
                            Case "d"
                                diaryStart = selectedStart.AddDays(i)
                                diaryEnd = selectedEnd.AddDays(i)
                            Case "w"
                                diaryStart = selectedStart.AddDays((7 * i))
                                diaryEnd = selectedEnd.AddDays((7 * i))
                            Case "m"
                                diaryStart = selectedStart.AddMonths(i)
                                diaryEnd = selectedEnd.AddMonths(i)
                        End Select

                        'check for overlapped diaries on this date
                        If roomLists.AsEnumerable.Any(Function(x) (diaryStart >= CDate(x("DiaryStart")) And diaryStart < CDate(x("DiaryEnd"))) Or diaryEnd > CDate(x("DiaryStart")) And diaryEnd <= CDate(x("DiaryEnd"))) Then
                            overlappedDates.Add(diaryStart.ToShortDateString)
                        Else
                            'DataAdapter_Sch.saveDiaryList(ListNameRadTextBox.Text, diaryStart, diaryEnd, RoomId, cbEndoscopist.SelectedValue, repeatPattern, repeatCount, newDiaryId, ListRulesId, "", OperatingHospitalIdHiddenField.Value, cbListConsultant.SelectedValue, chkIsTraining.Checked, cbListGender.SelectedValue, rblListType.SelectedValue)
                        End If
                    Next

                    If overlappedDates.Count > 0 Then
                        Utilities.SetNotificationStyle(RadNotification1, "1 or more of your orrucances overlapped with an existing list on " & String.Join(",", overlappedDates), True, "Lists not added")
                        RadNotification1.Show()
                    End If
                End If

                'RaiseEvent Template_Added(Me.Page, Appointment)
            ElseIf Mode = RadSchedulerAdvancedFormAdvancedFormMode.Edit Then
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
                    .Resources.Add(New Resource("IsGI", "IsGI", rblListType.SelectedValue))
                    .Resources.Add(New Resource("ListGenderId", "ListGenderId", cbListGender.SelectedValue))
                End With


                RaiseEvent Template_Updated(Me.Page, Appointment, newAppointment)
            End If
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



            ucListTemplateSlots.ListRulesId = cbGenericTemplate.SelectedValue
            ucListTemplateSlots.OperatingHospitalId = OperatingHospitalIdHiddenField.Value
            ucListTemplateSlots.IsTraining = chkIsTraining.Checked
            ucListTemplateSlots.ListRulesId = cbGenericTemplate.SelectedValue
            ucListTemplateSlots.GIProcedure = rblListType.SelectedValue
            ucListTemplateSlots.IsTraining = chkIsTraining.Checked
            ucListTemplateSlots.StartTime = StartTimePicker.SelectedDate
            ucListTemplateSlots.EndTime = StartTimePicker.SelectedDate
            ucListTemplateSlots.intDefaultSlothLengthMinutes = 15

            ucListTemplateSlots.initSlotDT(tblSlots)
            ucListTemplateSlots.initGrid()

            'EndTimePicker.SelectedDate = StartTimePicker.SelectedDate


            If cbGenericTemplate.SelectedValue = 0 Then
                ListSlotsDiv.Visible = False
            Else
                If Not cbGenericTemplate.SelectedValue = -99 Then
                    ucListTemplateSlots.ListRulesId = cbGenericTemplate.SelectedValue
                    ucListTemplateSlots.GIProcedure = rblListType.SelectedValue
                    ucListTemplateSlots.IsTraining = chkIsTraining.Checked
                    ucListTemplateSlots.StartTime = StartTimePicker.SelectedDate
                    ucListTemplateSlots.intDefaultSlothLengthMinutes = 15

                    ucListTemplateSlots.SelectList()
                    'EndTimePicker.SelectedDate = StartTimePicker.SelectedDate.Value.AddMinutes(ucListTemplateSlots.TotalMinutes)

                End If

                ListSlotsDiv.Visible = True
            End If
        Catch ex As Exception

        End Try
    End Sub

    Public Function SaveSlots(listName As String) As Integer

        Using db As New ERS.Data.GastroDbEntities
            Try
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
                    .TotalMins = 0
                    .Points = 0 'TotalPointsLabel.Text
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
                ERS_ListSlots = ucListTemplateSlots.saveListSlots(ERS_ListRules.ListRulesId)

                ERS_ListRules.TotalMins = ERS_ListSlots.Sum(Function(x) x.SlotMinutes)
                ERS_ListRules.Points = ERS_ListSlots.Sum(Function(x) x.Points)

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

    '#Region "Template stuff"


    '    Public Function initSlotDT(ByRef tblSlots As DataTable) As DataTable
    '        'tblSlots.Columns.Add("SlotRowId", GetType(Decimal))
    '        tblSlots.Columns.Add("LstSlotId", GetType(Decimal))
    '        tblSlots.Columns.Add("SlotId", GetType(Integer))
    '        tblSlots.Columns.Add("ProcedureTypeId", GetType(Integer))
    '        tblSlots.Columns.Add("Points", GetType(Decimal))
    '        tblSlots.Columns.Add("Suppressed", GetType(Boolean))
    '        tblSlots.Columns.Add("ParentId", GetType(Integer))
    '        tblSlots.Columns.Add("Minutes", GetType(Integer))
    '        tblSlots.Columns.Add("AppointmentId", GetType(Integer))

    '        Return tblSlots
    '    End Function

    '    Public Sub initGrid()
    '        Dim tblSlots As DataTable = New DataTable
    '        SlotsRadGrid.DataSource = tblSlots
    '        SlotsRadGrid.DataBind()
    '        TotalPointsLabel.Text = 0
    '        GenerateSlotButton.Enabled = True


    '    End Sub

    '    Private Sub calculateTime()
    '        Dim totalMinutes As Integer

    '        For Each item As GridDataItem In SlotsRadGrid.Items
    '            Dim SlotLengthRadNumericTextBox As RadNumericTextBox = item.FindControl("SlotLengthRadNumericTextBox")
    '            totalMinutes += CInt(SlotLengthRadNumericTextBox.Text)
    '        Next

    '        EndTimePicker.SelectedDate = StartTimePicker.SelectedDate
    '    End Sub

    '    Private Sub calculatePoints()
    '        Dim totalPoints As Decimal = 0
    '        For Each item As GridDataItem In SlotsRadGrid.Items
    '            Dim PointsNumericTextBox As RadNumericTextBox = item.FindControl("PointsRadNumericTextBox")
    '            Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
    '            totalPoints += SlotPoints
    '        Next

    '        TotalPointsLabel.Text = totalPoints
    '    End Sub

    '    Private Sub fillEditForm(ListRulesId As Integer)
    '        Dim da As New DataAccess_Sch
    '        Dim dt As DataRow = da.GetTemplate(ListRulesId).Rows(0)
    '        'If dt("GIProcedure") Then
    '        '    GIProcedureRBL.SelectedValue = "1"
    '        'Else
    '        '    'SlotsRadGrid.Style.Item("height") = 280
    '        '    GIProcedureRBL.SelectedValue = "0"
    '        'End If
    '        TotalPointsLabel.Text = dt("Points")

    '    End Sub

    '    Public Sub SelectList(Optional slotQty As Integer = 1, Optional procedureTypeId As Integer = 0, Optional points As Decimal = 1, Optional length As Integer = 15, Optional slotType As Integer = 0)
    '        Try
    '            Dim totalPoints = 0

    '            '#### First time page is loaded (ListRulesId > 0), get data from db - else generate slots from codebehind 
    '            If ListRulesId > 0 Then
    '                Dim sqlStr As String = "SELECT row_number() OVER 
    '                                                        (ORDER BY esls.[ListSlotId]) LstSlotId, SlotId, esls.ProcedureTypeId, esls.ListRulesId, ISNULL(esls.Points,1) as Points, 
    '                                                        ISNULL(esls.Suppressed, 0) AS Suppressed, ISNULL(esls.SlotMinutes ,15) AS [Minutes], 0 AS ParentId, ISNULL(AppointmentId,0) AppointmentId
    '                            FROM [dbo].[ERS_SCH_ListSlots] esls
    '    	                    INNER JOIN dbo.ERS_SCH_ListRules eslr ON esls.ListRulesId = eslr.ListRulesId
    '                            LEFT JOIN ERS_Appointments a ON a.ListSlotId = esls.ListSlotId
    '                            WHERE esls.OperatingHospitalId = " & OperatingHospitalIdHiddenField.Value & " 
    '                              AND esls.ListRulesId = " & CStr(ListRulesId) & "
    '                              AND esls.Active = 1 
    '                            ORDER BY esls.ListSlotId"


    '                SlotsRadGrid.DataSource = DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)

    '                If SlotsRadGrid.DataSource Is Nothing Then
    '                    Dim tblSlots As DataTable = New DataTable
    '                    initSlotDT(tblSlots)
    '                    SlotsRadGrid.DataSource = tblSlots
    '                    SlotsRadGrid.DataBind()
    '                Else
    '                    SlotsRadGrid.DataBind()
    '                    calculatePoints()
    '                    calculateTime()
    '                End If
    '            Else
    '                Dim cnt As Integer = 1
    '                Dim rowId As Decimal = 1

    '                Dim tblSlots As DataTable = New DataTable
    '                initSlotDT(tblSlots)

    '                Dim da As New DataAccess_Sch

    '                '## Looping through grid just to repopulate the same values already displayed or from user amendments
    '                For Each row As GridDataItem In SlotsRadGrid.Items
    '                    Dim LstSlotId As String = (row("LstSlotId").Text)
    '                    Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
    '                    Dim SlotId As String = SlotComboBox.SelectedValue
    '                    Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
    '                    Dim Guideline As String = GuidelineComboBox.SelectedValue
    '                    Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
    '                    Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
    '                    Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
    '                    Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
    '                    Dim Suppressed As Boolean = False
    '                    Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
    '                    If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = True


    '                    tblSlots.Rows.Add(cnt, SlotId, Guideline, SlotPoints, Suppressed, 0, SlotMinutes)
    '                    cnt = cnt + 1
    '                Next

    '                If slotQty > 0 Then
    '                    For i = 0 To slotQty - 1
    '                        tblSlots.Rows.Add(i, slotType, procedureTypeId, points, False, 0, length)
    '                        cnt = cnt + 1
    '                    Next
    '                Else
    '                    tblSlots.Rows.Add(cnt, 1, 0, 1, False, 0, 15)
    '                    cnt = cnt + 1
    '                End If


    '                SlotsRadGrid.DataSource = tblSlots
    '                SlotsRadGrid.DataBind()
    '            End If
    '        Catch ex As Exception
    '            Throw ex
    '        End Try
    '    End Sub

    '    Protected Sub SlotsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
    '        Try
    '            Dim selectedIndex = e.Item.ItemIndex
    '            Dim cnt As Integer = 1
    '            Dim rowId As Decimal = 1

    '            Dim tblSlots As DataTable = New DataTable
    '            initSlotDT(tblSlots)

    '            For Each row As GridDataItem In SlotsRadGrid.Items
    '                Dim LstSlotId As String = (row("LstSlotId").Text)
    '                Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
    '                Dim SlotId As String = SlotComboBox.SelectedValue
    '                Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
    '                Dim Guideline As String = GuidelineComboBox.SelectedValue
    '                Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
    '                Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
    '                Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
    '                Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
    '                Dim Suppressed As Boolean = False
    '                Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
    '                If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = True


    '                tblSlots.Rows.Add(cnt, SlotId, Guideline, SlotPoints, Suppressed, 0, SlotMinutes)

    '                cnt = cnt + 1
    '            Next

    '            tblSlots.Rows.RemoveAt(selectedIndex)

    '            SlotsRadGrid.DataSource = tblSlots
    '            SlotsRadGrid.DataBind()
    '            calculatePoints()
    '            calculateTime()
    '        Catch ex As Exception
    '            Dim ref = LogManager.LogManagerInstance.LogError("There was an error in SlotsRadGrid_ItemCommand", ex)
    '            Throw ex
    '        End Try
    '    End Sub

    '    Protected Sub SlotComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
    '        Dim dataItemForeColor = CType(e.Item.DataItem, DataRowView).Row("ForeColor").ToString()
    '        e.Item.BackColor = System.Drawing.ColorTranslator.FromHtml(dataItemForeColor)
    '    End Sub

    '    Protected Sub GuidelineComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
    '        Try
    '            Dim ProcedureTypeDDL = CType(sender, RadComboBox)
    '            Dim gridItem = CType(ProcedureTypeDDL.NamingContainer, GridItem)

    '            Dim Points As Decimal = 1
    '            Dim Minutes As Integer = 15
    '            Dim iOperatingHospitalId = OperatingHospitalId
    '            Dim iProcedureTypeId = ProcedureTypeDDL.SelectedValue

    '            If ProcedureTypeDDL.SelectedValue > 0 Then
    '                Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & IsTraining & " AND NonGI = 0"
    '                Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
    '                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
    '                    Points = Convert.ToDecimal(dt.Rows(0)("Points"))
    '                    Minutes = CInt(dt.Rows(0)("Minutes"))
    '                End If
    '            End If

    '            CType(gridItem.FindControl("PointsRadNumericTextBox"), RadNumericTextBox).Text = Points
    '            CType(gridItem.FindControl("SlotLengthRadNumericTextBox"), RadNumericTextBox).Text = Minutes

    '            calculatePoints()
    '        Catch ex As Exception
    '            Dim errorLogRef As String
    '            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on edit templates page.", ex)
    '            Throw ex
    '        End Try
    '    End Sub

    '    Protected Sub SlotsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
    '        Try
    '            Dim i = 0
    '            If e.Item.ItemType = GridItemType.Item Or e.Item.ItemType = GridItemType.AlternatingItem Then
    '                Dim j = 0
    '                If DirectCast(e.Item.DataItem, System.Data.DataRowView).Row("AppointmentId") > 0 Then

    '                End If
    '            End If
    '        Catch ex As Exception

    '        End Try
    '    End Sub

    '    Protected Sub ProcedureTypesComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
    '        Try
    '            Dim ProcedureTypeDDL = CType(sender, RadComboBox)

    '            Dim Points As Decimal = 1
    '            Dim Minutes As Integer = 15
    '            Dim iOperatingHospitalId = OperatingHospitalIdHiddenField.Value 'OperatingHospitalDropdown.SelectedValue
    '            Dim iProcedureTypeId = ProcedureTypeDDL.SelectedValue

    '            'If ProcedureTypeDDL.SelectedValue > 0 Then
    '            Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & Convert.ToByte(IsTraining) & " AND NonGI = " & Convert.ToByte(GIProcedure)
    '            Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
    '            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
    '                Points = Convert.ToDecimal(dt.Rows(0)("Points"))
    '                Minutes = CInt(dt.Rows(0)("Minutes"))
    '            Else
    '                PointsRadNumericTextBox.Text = 1
    '                SlotLengthRadNumericTextBox.Text = 15
    '            End If
    '            'End If

    '            PointsRadNumericTextBox.Text = Points
    '            SlotLengthRadNumericTextBox.Text = Minutes
    '        Catch ex As Exception
    '            Dim ref = LogManager.LogManagerInstance.LogError("Error during procedure dropdown postback", ex)
    '            'Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error retrieving procedure points")
    '            'RadNotification1.Show()

    '            PointsRadNumericTextBox.Text = 1
    '            SlotLengthRadNumericTextBox.Text = 15
    '        End Try
    '    End Sub

    '    Protected Sub btnSaveAndApply_Click(sender As Object, e As EventArgs)
    '        SelectList(SlotQtyRadNumericTextBox.Value, ProcedureTypesComboBox.SelectedValue, PointsRadNumericTextBox.Value, SlotLengthRadNumericTextBox.Value, SlotComboBox.SelectedValue)

    '        SlotQtyRadNumericTextBox.Value = 1
    '        ProcedureTypesComboBox.SelectedIndex = 0
    '        PointsRadNumericTextBox.Value = 1
    '        SlotLengthRadNumericTextBox.Value = 15
    '        SlotComboBox.SelectedIndex = 0

    '        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "applyandclose", "closeAddNewWindow();", True)
    '        calculatePoints()
    '        calculateTime()
    '    End Sub

    '    Public Function saveListSlots(listRulesId As Integer) As List(Of ERS.Data.ERS_SCH_ListSlots)
    '        Dim ERS_ListSlots As New List(Of ERS.Data.ERS_SCH_ListSlots)
    '        Dim totalMinutes As Integer

    '        For Each row As GridDataItem In SlotsRadGrid.Items
    '            If row.CssClass = "slot-point" Then Continue For
    '            Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
    '            Dim SlotId As String = SlotComboBox.SelectedValue
    '            Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
    '            Dim Guideline As String = If(SlotsRadGrid.Columns(2).Display, GuidelineComboBox.SelectedValue, "0")
    '            Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
    '            Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)

    '            Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
    '            Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
    '            totalMinutes += SlotMinutes

    '            Dim Suppressed As Byte = 0
    '            Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
    '            If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = 1

    '            ERS_ListSlots.Add(New ERS.Data.ERS_SCH_ListSlots With {
    '                    .ListRulesId = listRulesId,
    '                    .ProcedureTypeId = Guideline,
    '                    .Suppressed = Suppressed,
    '                    .SlotId = SlotId,
    '                    .OperatingHospitalId = OperatingHospitalIdHiddenField.Value,
    '                    .WhoCreatedId = CInt(Session("PKUserID")),
    '                    .WhenCreated = Now,
    '                    .SlotMinutes = SlotMinutes,
    '                    .Points = SlotPoints,
    '                    .Active = True
    '                    })
    '        Next

    '        Return ERS_ListSlots
    '    End Function

    '    Public Function SaveSlots(listName As String) As Integer

    '        Using db As New ERS.Data.GastroDbEntities
    '            Try
    '                'If CInt(TotalPointsLabel.Text) = 0 And SlotsRadGrid.Items.Count = 0 Then
    '                '    'Utilities.SetNotificationStyle(RadNotification1, "This template contains 0 slots", True, "Please correct")
    '                '    'RadNotification1.Show()
    '                '    'Exit Sub
    '                'End If

    '                If Not GIProcedure Then 'non gi template
    '                    'check a procedure types been set
    '                    Dim canContinue = True
    '                    For Each row As GridDataItem In SlotsRadGrid.Items
    '                        If row.CssClass = "slot-point" Then Continue For
    '                        Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
    '                        Dim Guideline As String = If(SlotsRadGrid.Columns(2).Display, GuidelineComboBox.SelectedValue, "0")
    '                        If Guideline = "0" Then
    '                            canContinue = False
    '                            Exit For
    '                        End If
    '                    Next

    '                    If Not canContinue Then
    '                        'Utilities.SetNotificationStyle(RadNotification1, "Non-GI templates cannot contain non-reserved slots.", True, "Please correct")
    '                        'RadNotification1.Show()
    '                        'Exit Sub
    '                    End If
    '                End If

    '                Dim sqlStr As String = ""
    '                Dim sqlSlots As String = ""

    '                Dim nonGIProcedureTypeId As Integer = 0
    '                Dim nonGIPointsPerMinute As Integer = 0
    '                Dim diagnosticCallinTime As Integer = 0
    '                Dim diagnosticPoints As Integer = 0
    '                Dim therapeuticCallInTime As Integer = 0
    '                Dim therapeuticPoints As Integer = 0


    '                Dim ERS_ListRules As New ERS.Data.ERS_SCH_ListRules

    '                With ERS_ListRules
    '                    .Points = TotalPointsLabel.Text
    '                    .ListName = listName
    '                    .OperatingHospitalId = OperatingHospitalIdHiddenField.Value
    '                    .GIProcedure = GIProcedure
    '                    .Training = IsTraining
    '                    .NonGIProcedureTypeId = nonGIProcedureTypeId
    '                    .NonGIProcedureMinutesPerPoint = nonGIPointsPerMinute
    '                    .NonGIDiagnosticCallInTime = diagnosticCallinTime
    '                    .NonGIDiagnosticProcedurePoints = diagnosticPoints
    '                    .NonGITherapeuticCallInTime = therapeuticCallInTime
    '                    .NonGITherapeuticProcedurePoints = therapeuticPoints
    '                    .GenderId = If(cbListGender.SelectedValue = 0, Nothing, cbListGender.SelectedValue)
    '                    .IsTemplate = False 'Always false unless created from the Templates page
    '                End With

    '                ERS_ListRules.WhoCreatedId = CInt(Session("PKUserID"))
    '                ERS_ListRules.WhenCreated = Now
    '                db.ERS_SCH_ListRules.Add(ERS_ListRules)

    '                db.SaveChanges() 'to get the list rules id for the list slots

    '                Dim ERS_ListSlots As New List(Of ERS.Data.ERS_SCH_ListSlots)
    '                Dim totalMinutes As Integer

    '                For Each row As GridDataItem In SlotsRadGrid.Items
    '                    If row.CssClass = "slot-point" Then Continue For
    '                    Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
    '                    Dim SlotId As String = SlotComboBox.SelectedValue
    '                    Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
    '                    Dim Guideline As String = If(SlotsRadGrid.Columns(2).Display, GuidelineComboBox.SelectedValue, "0")
    '                    Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
    '                    Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)

    '                    Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
    '                    Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
    '                    totalMinutes += SlotMinutes

    '                    Dim Suppressed As Byte = 0
    '                    Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
    '                    If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = 1

    '                    ERS_ListSlots.Add(New ERS.Data.ERS_SCH_ListSlots With {
    '                    .ListRulesId = ERS_ListRules.ListRulesId,
    '                    .ProcedureTypeId = Guideline,
    '                    .Suppressed = Suppressed,
    '                    .SlotId = SlotId,
    '                    .OperatingHospitalId = OperatingHospitalIdHiddenField.Value,
    '                    .WhoCreatedId = CInt(Session("PKUserID")),
    '                    .WhenCreated = Now,
    '                    .SlotMinutes = SlotMinutes,
    '                    .Points = SlotPoints,
    '                    .Active = True
    '                    })
    '                Next

    '                ERS_ListRules.TotalMins = totalMinutes
    '                db.ERS_SCH_ListRules.Attach(ERS_ListRules)
    '                db.Entry(ERS_ListRules).State = Entity.EntityState.Modified

    '                db.ERS_SCH_ListSlots.AddRange(ERS_ListSlots)
    '                db.SaveChanges()


    '                Return ERS_ListRules.ListRulesId
    '            Catch ex As Exception
    '                Throw ex
    '            End Try
    '        End Using
    '    End Function

    '#End Region

End Class