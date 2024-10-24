Imports System
Imports System.ComponentModel
Imports System.Web.UI
Imports System.Drawing
Imports Telerik.Web.UI

''' <summary>
''' Specifies the advanced form mode.
''' </summary>
Public Enum AdvancedFormMode
    Insert
    Edit
End Enum

Partial Class UserControls_AppointmentForm
    Inherits System.Web.UI.UserControl

#Region "Private members"

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

    Private _mode As AdvancedFormMode = AdvancedFormMode.Insert

#End Region

#Region "Protected properties"

    Protected ReadOnly Property Owner() As RadScheduler
        Get
            Return Appointment.Owner
        End Get
    End Property

    Protected ReadOnly Property Appointment() As Appointment
        Get
            Dim container As SchedulerFormContainer = DirectCast(BindingContainer, SchedulerFormContainer)
            Return container.Appointment
        End Get
    End Property

#End Region

#Region "Attributes and resources"

    '<Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    'Public Property Description() As String
    '    Get
    '        Return DescriptionText.Text
    '    End Get

    '    Set(ByVal value As String)
    '        DescriptionText.Text = value
    '    End Set
    'End Property

    '<Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    'Public Property AppointmentColor() As String
    '    Get
    '        ' No color selected
    '        If AppointmentColorPicker.SelectedColor.A = 0 Then
    '            Return Nothing
    '        End If

    '        Return AppointmentColorPicker.SelectedColor.ToArgb().ToString()
    '    End Get

    '    Set(ByVal value As String)
    '        If String.IsNullOrEmpty(value) Then
    '            Return
    '        End If

    '        Dim argbValue As Integer
    '        If Integer.TryParse(value, argbValue) Then
    '            AppointmentColorPicker.SelectedColor = Color.FromArgb(argbValue)
    '        End If
    '    End Set
    'End Property


    '<Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    'Public Property RoomID() As Object
    '    Get
    '        Return ResRoom.Value
    '    End Get

    '    Set(ByVal value As Object)
    '        ResRoom.Value = value
    '    End Set
    'End Property

    '<Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    'Public Property UserID() As Object
    '    Get
    '        Return ResUser.Value
    '    End Get

    '    Set(ByVal value As Object)
    '        ResUser.Value = value
    '    End Set
    'End Property

#End Region

#Region "Public properties"

    Public Property Mode() As AdvancedFormMode
        Get
            Return _mode
        End Get
        Set(ByVal value As AdvancedFormMode)
            _mode = value
        End Set
    End Property

    '<Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    'Public Property Subject() As String
    '    Get
    '        Return SubjectText.Text
    '    End Get

    '    Set(ByVal value As String)
    '        SubjectText.Text = value
    '    End Set
    'End Property

    '<Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    'Public Property PatientNo() As String
    '    Get
    '        Return Owner
    '    End Get

    '    Set(ByVal value As String)
    '        SubjectText.Text = value
    '    End Set
    'End Property

    <Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    Public Property Start() As DateTime
        Get
            Dim result As DateTime = StartDatePicker.SelectedDate.Value.Date

            'If AllDayEvent.Checked Then
            '    result = result.Date
            'Else
            '    Dim time As TimeSpan = StartTime.SelectedDate.Value.TimeOfDay
            '    result = result.Add(time)
            'End If
            Dim time As TimeSpan = StartTimePicker.SelectedDate.Value.TimeOfDay
            result = result.Add(time)

            Return Owner.DisplayToUtc(result)
        End Get

        Set(ByVal value As DateTime)
            StartDatePicker.SelectedDate = Owner.UtcToDisplay(value)
            StartTimePicker.SelectedDate = Owner.UtcToDisplay(value)
        End Set
    End Property

    <Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    Public Property [End]() As DateTime
        Get
            Dim result As DateTime = EndDatePicker.SelectedDate.Value.Date

            'If AllDayEvent.Checked Then
            '    result = result.Date.AddDays(1)
            'Else
            '    Dim time As TimeSpan = EndTimePicker.SelectedDate.Value.TimeOfDay
            '    result = result.Add(time)
            'End If
            Dim time As TimeSpan = EndTimePicker.SelectedDate.Value.TimeOfDay
            result = result.Add(time)

            Return Owner.DisplayToUtc(result)
        End Get

        Set(ByVal value As DateTime)
            EndDatePicker.SelectedDate = Owner.UtcToDisplay(value)
            EndTimePicker.SelectedDate = Owner.UtcToDisplay(value)
        End Set
    End Property


    '<Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    'Public Property RecurrenceRuleText() As String
    '    Get
    '        If Owner.RecurrenceSupport Then
    '            Dim dateSpecified As Boolean = StartDate.SelectedDate.HasValue AndAlso EndDate.SelectedDate.HasValue
    '            Dim timeSpecified As Boolean = StartTime.SelectedDate.HasValue AndAlso EndTime.SelectedDate.HasValue

    '            If (AllDayEvent.Checked AndAlso Not dateSpecified) OrElse (Not AllDayEvent.Checked AndAlso Not (dateSpecified AndAlso timeSpecified)) Then
    '                Return String.Empty
    '            End If

    '            AppointmentRecurrenceEditor.StartDate = Start
    '            AppointmentRecurrenceEditor.EndDate = [End]

    '            Dim rrule As RecurrenceRule = AppointmentRecurrenceEditor.RecurrenceRule

    '            If rrule Is Nothing Then
    '                Return String.Empty
    '            End If

    '            Dim originalRule As RecurrenceRule = Nothing
    '            If RecurrenceRule.TryParse(OriginalRecurrenceRule.Value, originalRule) Then
    '                rrule.Exceptions = originalRule.Exceptions
    '            End If

    '            If rrule.Range.RecursUntil <> DateTime.MaxValue Then
    '                rrule.Range.RecursUntil = Owner.DisplayToUtc(rrule.Range.RecursUntil)

    '                If Not AllDayEvent.Checked Then
    '                    rrule.Range.RecursUntil = rrule.Range.RecursUntil.AddDays(1)
    '                End If
    '            End If

    '            Return rrule.ToString()
    '        End If

    '        Return String.Empty
    '    End Get

    '    Set(ByVal value As String)
    '        Dim rrule As RecurrenceRule = Nothing
    '        RecurrenceRule.TryParse(value, rrule)

    '        If rrule IsNot Nothing Then
    '            If rrule.Range.RecursUntil <> DateTime.MaxValue Then
    '                Dim recursUntil As DateTime = Owner.UtcToDisplay(rrule.Range.RecursUntil)

    '                If Not IsAllDayAppointment(Appointment) Then
    '                    recursUntil = recursUntil.AddDays(-1)
    '                End If

    '                rrule.Range.RecursUntil = recursUntil
    '            End If

    '            AppointmentRecurrenceEditor.RecurrenceRule = rrule

    '            OriginalRecurrenceRule.Value = value
    '        End If
    '    End Set
    'End Property

    '<Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    'Public Property Reminder() As String
    '    Get
    '        If Owner.RemindersSupport AndAlso ReminderDropDown.SelectedValue <> String.Empty Then
    '            Return ReminderDropDown.SelectedValue
    '        End If

    '        Return String.Empty
    '    End Get

    '    Set(ByVal value As String)
    '        Dim item As RadComboBoxItem = ReminderDropDown.Items.FindItemByValue(value)
    '        If item IsNot Nothing Then
    '            item.Selected = True
    '        End If
    '    End Set
    'End Property

    '<Bindable(BindableSupport.Yes, BindingDirection.TwoWay)> _
    'Public Property TimeZoneID() As String
    '    Get
    '        Return TimeZonesDropDown.SelectedValue
    '    End Get

    '    Set(value As String)

    '        Dim item As RadComboBoxItem = TimeZonesDropDown.Items.FindItemByValue(value)
    '        If item IsNot Nothing Then
    '            item.Selected = True
    '        End If
    '    End Set
    'End Property

#End Region

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        'UpdateButton.ValidationGroup = Owner.ValidationGroup
        'UpdateButton.CommandName = If(Mode = AdvancedFormMode.Edit, "Update", "Insert")
        'SubjectText.LabelWidth = Unit.Empty
        'DescriptionText.LabelWidth = Unit.Empty

        'If Owner.AdvancedForm.EnableTimeZonesEditing Then
        '    PopulateTimeZonesDropDown()
        'Else
        '    TimeZonesDropDown.Visible = False
        'End If

        'If Not Owner.Reminders.Enabled Then
        '    ReminderDropDown.Visible = False
        'End If

        'InitializeStrings()
        'InitializeRecurrenceEditor()

        'If Not FormInitialized Then
        '    UpdateResetExceptionsVisibility()
        'End If
    End Sub

    Protected Overrides Sub OnPreRender(e As EventArgs)
        MyBase.OnPreRender(e)

        'If Not FormInitialized Then
        '    If IsAllDayAppointment(Appointment) Then
        '        EndDate.SelectedDate = EndDate.SelectedDate.Value.AddDays(-1)
        '    End If

        '    FormInitialized = True
        'End If

        'If [String].IsNullOrEmpty(Appointment.TimeZoneID) Then
        '    TimeZoneID = Owner.TimeZonesProvider.OperationTimeZone.TimeZoneId
        'Else
        '    TimeZoneID = Appointment.TimeZoneID
        'End If
    End Sub

    'Private Sub PopulateTimeZonesDropDown()
    '    TimeZonesDropDown.DataSource = Owner.TimeZonesProvider.GetAllTimeZones()
    '    TimeZonesDropDown.DataTextField = "DisplayName"
    '    TimeZonesDropDown.DataValueField = "Id"
    'End Sub

    'Protected Sub BasicControlsPanel_DataBinding(ByVal sender As Object, ByVal e As EventArgs)
    '    AllDayEvent.Checked = IsAllDayAppointment(Appointment)
    'End Sub

    'Protected Sub DurationValidator_OnServerValidate(ByVal source As Object, ByVal args As ServerValidateEventArgs)
    '    args.IsValid = ([End] - Start) > TimeSpan.Zero
    'End Sub

    'Protected Sub ResetExceptions_OnClick(ByVal sender As Object, ByVal e As EventArgs)
    '    Owner.RemoveRecurrenceExceptions(Appointment)
    '    OriginalRecurrenceRule.Value = Appointment.RecurrenceRule
    '    ResetExceptions.Text = Owner.Localization.AdvancedDone
    'End Sub

#Region "Private methods"

    'Private Sub InitializeStrings()
    '    SubjectValidator.ErrorMessage = Owner.Localization.AdvancedSubjectRequired
    '    SubjectValidator.ValidationGroup = Owner.ValidationGroup

    '    AllDayEvent.Text = Owner.Localization.AdvancedAllDayEvent

    '    StartDateValidator.ErrorMessage = Owner.Localization.AdvancedStartDateRequired
    '    StartDateValidator.ValidationGroup = Owner.ValidationGroup

    '    StartTimeValidator.ErrorMessage = Owner.Localization.AdvancedStartTimeRequired
    '    StartTimeValidator.ValidationGroup = Owner.ValidationGroup

    '    EndDateValidator.ErrorMessage = Owner.Localization.AdvancedEndDateRequired
    '    EndDateValidator.ValidationGroup = Owner.ValidationGroup

    '    EndTimeValidator.ErrorMessage = Owner.Localization.AdvancedEndTimeRequired
    '    EndTimeValidator.ValidationGroup = Owner.ValidationGroup

    '    DurationValidator.ErrorMessage = Owner.Localization.AdvancedStartTimeBeforeEndTime
    '    DurationValidator.ValidationGroup = Owner.ValidationGroup

    '    ResetExceptions.Text = Owner.Localization.AdvancedReset

    '    SharedCalendar.FastNavigationSettings.OkButtonCaption = Owner.Localization.AdvancedCalendarOK
    '    SharedCalendar.FastNavigationSettings.CancelButtonCaption = Owner.Localization.AdvancedCalendarCancel
    '    SharedCalendar.FastNavigationSettings.TodayButtonCaption = Owner.Localization.AdvancedCalendarToday
    'End Sub

    'Private Sub InitializeRecurrenceEditor()
    '    AppointmentRecurrenceEditor.SharedCalendar = SharedCalendar
    '    AppointmentRecurrenceEditor.Culture = Owner.Culture
    '    AppointmentRecurrenceEditor.StartDate = Appointment.Start
    '    AppointmentRecurrenceEditor.EndDate = Appointment.End
    'End Sub

    'Private Sub UpdateResetExceptionsVisibility()
    '    If String.IsNullOrEmpty(Owner.WebServiceSettings.Path) Then
    '        ResetExceptions.Visible = False
    '        Dim rrule As RecurrenceRule = RecurrenceRule.Empty
    '        If RecurrenceRule.TryParse(Appointment.RecurrenceRule, rrule) Then
    '            ResetExceptions.Visible = rrule.Exceptions.Count > 0
    '        End If
    '    End If
    'End Sub

    'Private Function IsAllDayAppointment(ByVal appointment As Appointment) As Boolean
    '    Dim displayStart As DateTime = Owner.UtcToDisplay(appointment.Start)
    '    Dim displayEnd As DateTime = Owner.UtcToDisplay(appointment.[End])
    '    Return displayStart.CompareTo(displayStart.[Date]) = 0 AndAlso displayEnd.CompareTo(displayEnd.[Date]) = 0
    'End Function
#End Region
End Class