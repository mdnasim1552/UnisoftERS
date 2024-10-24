Imports Telerik.Web.UI
Imports System.Drawing
Imports System.Data.Entity.Core.Objects

Partial Class Products_Options_Scheduler_DiaryPages
    Inherits OptionsBase

    ReadOnly Property OperatingHospitalID As Integer
        Get
            Return CInt(HospitalDropDownList.SelectedValue)
        End Get
    End Property

    Private Sub Page_Init1(sender As Object, e As EventArgs) Handles Me.Init
        AppointmentsDataSource.ConnectionString = DataAccess.ConnectionStr
        AppointmentsDataSource.SelectParameters("DiaryDate").DefaultValue = Now


        Dim manager As ScriptManager = RadScriptManager.GetCurrent(Page)
        manager.Scripts.Add(New ScriptReference("~\Scripts\AdvancedForm.js"))
    End Sub

    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        'Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)

        'myAjaxMgr.AjaxSettings.AddAjaxSetting(WeekViewRoomsDropdown, DiaryRadScheduler, RadAjaxLoadingPanel1)
        ''myAjaxMgr.AjaxSettings.AddAjaxSetting(DiaryRadScheduler, RadNotification1)

        'AddHandler myAjaxMgr.AjaxRequest, AddressOf RadAjaxManager1_AjaxRequest

        If Not IsPostBack Then
            If Me.Master IsNot Nothing Then
                Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                If leftPane IsNot Nothing Then leftPane.Visible = False
                If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
            End If

            DiaryAppointmentsRadGrid.DataSource = New DataTable()
            DiaryAppointmentsRadGrid.DataBind()

            AppointmentsDataSource.InsertParameters("LoggedInUserId").DefaultValue = CInt(Session("PKUserID"))

            AppointmentsDataSource.UpdateParameters("LoggedInUserId").DefaultValue = CInt(Session("PKUserID"))

            HospitalDropDownList.SelectedValue = CInt(Session("OperatingHospitalId"))

            RoomsDropdown.DataSource = DataAdapter_Sch.GetHospitalRooms(CInt(Session("OperatingHospitalId")))
            RoomsDropdown.DataBind()

            WeekViewRoomsDropdown.DataSource = DataAdapter_Sch.GetHospitalRooms(CInt(Session("OperatingHospitalId")))
            WeekViewRoomsDropdown.DataBind()

            Dim roomIDs As String = ""
            For Each itm As RadComboBoxItem In RoomsDropdown.Items
                itm.Checked = True
                roomIDs = roomIDs & IIf(roomIDs = Nothing, itm.Value, "," & itm.Value)
            Next

            RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = CInt(Session("OperatingHospitalId"))
            RoomsDataSource.SelectParameters("FieldValue").DefaultValue = roomIDs

            If DataAdapter_Sch.IncludeDiaryEvenings(CInt(Session("OperatingHospitalId"))) Then ' using the sessionID as this will be the selected hospital on initial load as above 
                DiaryRadScheduler.DayEndTime = New TimeSpan(22, 0, 0)
            Else
                DiaryRadScheduler.DayEndTime = New TimeSpan(18, 0, 0)
            End If

            DiaryRadScheduler.HoursPanelTimeFormat = "HH:mm tt"
            DiaryRadScheduler.TimeLabelRowSpan = 1

        End If
    End Sub

    Private Sub DiaryRadScheduler_FormCreated(sender As Object, e As SchedulerFormCreatedEventArgs) Handles DiaryRadScheduler.FormCreated
        Try

            If e.Container.Mode = SchedulerFormMode.AdvancedInsert Or e.Container.Mode = SchedulerFormMode.AdvancedEdit Then

                'Hide controls- values are determined by the selected template
                Dim DescTextbox As RadTextBox = DirectCast(e.Container.FindControl("Description"), RadTextBox)
                If Not DescTextbox Is Nothing Then
                    DescTextbox.Visible = False
                End If

                Dim subject As RadTextBox = DirectCast(e.Container.FindControl("Subject"), RadTextBox)
                If Not subject Is Nothing Then
                    subject.CssClass = "hidden-control"
                End If

                'Dim endDate As RadDatePicker = DirectCast(e.Container.FindControl("EndDate"), RadDatePicker)
                'If Not endDate Is Nothing Then
                '    endDate.Visible = False
                'End If

                'Dim endTime As RadTimePicker = DirectCast(e.Container.FindControl("EndTime"), RadTimePicker)
                'If Not endTime Is Nothing Then
                '    endTime.Visible = False
                'End If

                'Dim allDayCheckBox As CheckBox = DirectCast(e.Container.FindControl("AllDayEvent"), CheckBox)
                'If Not allDayCheckBox Is Nothing Then
                '    allDayCheckBox.Visible = False
                'End If

                'Disable controls
                Dim startDate As RadDatePicker = DirectCast(e.Container.FindControl("StartDate"), RadDatePicker)
                If Not startDate Is Nothing Then
                    startDate.Enabled = False
                End If

                Dim startTime As RadTimePicker = DirectCast(e.Container.FindControl("StartTime"), RadTimePicker)
                If Not startTime Is Nothing Then
                    startTime.Enabled = False
                End If

                Dim ResRoom As RadComboBox = DirectCast(e.Container.FindControl("ResRoom"), RadComboBox)
                If Not ResRoom Is Nothing Then
                    ResRoom.Enabled = False
                End If

                Dim subjectValidator As RequiredFieldValidator = DirectCast(e.Container.FindControl("SubjectValidator"), RequiredFieldValidator)
                If ((Not (subject) Is Nothing) _
                            AndAlso (Not (subjectValidator) Is Nothing)) Then
                    subjectValidator.Enabled = False
                End If


                Dim ResTemplate As RadComboBox = DirectCast(e.Container.FindControl("ResTemplate"), RadComboBox)
                If ResTemplate IsNot Nothing Then AddHandler ResTemplate.SelectedIndexChanged, AddressOf ResTemplate_SelectedIndexChanged


                'Add custom validator for template which Is compulsory
                Dim validatorForAttribute As CustomValidator = New CustomValidator()
                Dim scheduler As RadScheduler = CType(sender, RadScheduler)
                validatorForAttribute.ID = "TemplateValidator"
                validatorForAttribute.ValidationGroup = scheduler.ValidationGroup
                validatorForAttribute.ControlToValidate = "ResTemplate"
                validatorForAttribute.ErrorMessage = "Please select a template."
                validatorForAttribute.ClientValidationFunction = "validationFunction"
                'DirectCast(e.Container.FindControl("ResTemplate"), RadComboBox).Parent.Controls.Add(validatorForAttribute)
            End If

        Catch ex As Exception
            Dim errorRef = LogManager.LogManagerInstance.LogError("An error occured", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef)
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub ResTemplate_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Dim FormContainer = DirectCast(DiaryRadScheduler.FindControl("Form"), SchedulerFormContainer)

        'Dim StartDateField = DirectCast(FormContainer.FindControl("StartDate"), RadDatePicker)
        'Dim EndDateField = DirectCast(FormContainer.FindControl("StartDate"), RadDatePicker)
        'DirectCast(FormContainer.FindControl("EndDate"), RadDatePicker).SelectedDate = Now.AddDays(1)

        ''get template ID and get end date and endoscopit (if any) and prefill controls
        'Dim ddl = DirectCast(sender, RadComboBox)
        'Dim templateId = ddl.SelectedValue
    End Sub

    Private Sub DiaryRadScheduler_AppointmentDataBound(sender As Object, e As SchedulerEventArgs) Handles DiaryRadScheduler.AppointmentDataBound
        Try

            e.Appointment.ToolTip = e.Appointment.Subject & vbCrLf & e.Appointment.Description

            Dim isTraining = CBool(DirectCast(e.Appointment.DataItem, System.Data.DataRowView).Row("Training"))
            Dim listConsultantId
            If Not String.IsNullOrEmpty(DirectCast(e.Appointment.DataItem, System.Data.DataRowView).Row("ListConsultantId").ToString()) Then
                listConsultantId = CInt(DirectCast(e.Appointment.DataItem, System.Data.DataRowView).Row("ListConsultantId"))
            End If

            If isTraining Then e.Appointment.Subject += " (training)"
            e.Appointment.Resources.Add(New Resource("IsTrainingList", "IsTrainingList", isTraining))
            e.Appointment.Resources.Add(New Resource("ListConsultant", "ListConsultant", listConsultantId))

            If DiaryRadScheduler.SelectedView = SchedulerViewType.DayView AndAlso Not e.Appointment.Resources.Any(Function(x) x.Type = "Room") Then
                e.Appointment.Resources.Add(New Resource("Room", DirectCast(e.Appointment.DataItem, System.Data.DataRowView).Row("RoomId"), "Room"))
            End If

            If CBool(DirectCast(e.Appointment.DataItem, System.Data.DataRowView).Row("Suppressed")) Then
                If Not String.IsNullOrWhiteSpace(e.Appointment.RecurrenceRule) Then
                    Dim appointmentRule As RecurrenceRule
                    If RecurrenceRule.TryParse(e.Appointment.RecurrenceRule, appointmentRule) Then
                        appointmentRule.Range.RecursUntil = CDate(DirectCast(e.Appointment.DataItem, System.Data.DataRowView).Row("SuppressedFromDate")).Date.Add(e.Appointment.Start.TimeOfDay).AddDays(1)

                        e.Appointment.RecurrenceRule = appointmentRule.ToString()
                    End If
                Else
                    If e.Appointment.Start.Date > CDate(DirectCast(e.Appointment.DataItem, System.Data.DataRowView).Row("SuppressedFromDate")).Date Then
                        e.Appointment.Visible = False
                    End If
                End If
            End If

        Catch ex As Exception

        End Try
    End Sub



    Protected Sub SelectRoomButton_Click(sender As Object, e As EventArgs)
        Dim roomIDs As String = ""

        If DiaryRadScheduler.SelectedView = SchedulerViewType.DayView Then
            If RoomsDropdown.CheckedItems.Count = 0 Then Exit Sub

            For Each itm As RadComboBoxItem In RoomsDropdown.CheckedItems
                roomIDs = roomIDs & IIf(roomIDs = Nothing, itm.Value, "," & itm.Value)
            Next
        Else
            roomIDs = WeekViewRoomsDropdown.SelectedValue
        End If

        RoomsDataSource.SelectParameters("FieldValue").DefaultValue = roomIDs
        RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = CInt(OperatingHospitalID)

        DiaryRadScheduler.Rebind()
        Dim i = 0
    End Sub

    Protected Sub HospitalDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
        RoomsDropdown.DataSource = DataAdapter_Sch.GetHospitalRooms(HospitalDropDownList.SelectedValue)
        RoomsDropdown.DataBind()

        If RoomsDropdown.Items.Count > 0 Then
            For Each itm As RadComboBoxItem In RoomsDropdown.Items
                itm.Checked = True
            Next
        End If

        WeekViewRoomsDropdown.DataSource = DataAdapter_Sch.GetHospitalRooms(HospitalDropDownList.SelectedValue)
        WeekViewRoomsDropdown.DataBind()

        SelectRoomButton_Click(Nothing, Nothing)
    End Sub

    Protected Sub Unnamed_ValueChanged(sender As Object, e As EventArgs)
        DiaryRadScheduler.HoursPanelTimeFormat = "HH:mm tt"
        DiaryRadScheduler.TimeLabelRowSpan = 1

        DiaryRadScheduler.MinutesPerRow = RadSlider1.SelectedValue
        DiaryRadScheduler.Rebind()
    End Sub

    Protected Sub btnZoomIn_Click(sender As Object, e As ImageClickEventArgs)

    End Sub

    Protected Sub btnZoomOut_Click(sender As Object, e As ImageClickEventArgs)

    End Sub

#Region "Web methods"
    <System.Web.Services.WebMethod()>
    Public Shared Sub MoveTemplate(diaryId As Integer, newDate As DateTime, newTime As String, newRoom As String)
        Try
            Dim da As New DataAccess_Sch
            Dim newStart = CDate(newDate.ToShortDateString & " " & newTime)

            da.moveTemplate(diaryId, newStart, newTime, newRoom)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>MoveTemplate", ex)
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function IsProcedureRoom(roomId As Integer, listRulesId As Integer) As Boolean
        Try
            Dim da As New DataAccess_Sch
            Dim blnReslt As Boolean
            blnReslt = False

            'MH changed to let add Template on a Room with 'All Procedrues' checked. 'All Procedure' marked room will not have records in ERS_SCH_RoomProcedures table
            'TFS 2564
            Using db As New ERS.Data.GastroDbEntities

                Dim listProcedures = (From l In db.ERS_SCH_ListSlots Where l.ListRulesId = listRulesId Select l.ProcedureTypeId.Value Distinct).ToList
                Dim roomProcedures = (From p In db.ERS_SCH_Rooms Join rp In db.ERS_SCH_RoomProcedures On p.RoomId Equals rp.RoomId Where rp.RoomId = roomId Select rp.ProcedureTypeId).ToList

                Dim allProcRoom = (From r In db.ERS_SCH_Rooms Where r.RoomId = roomId And r.AllProcedureTypes = True Select r.RoomName).ToList()

                For Each prr In allProcRoom
                    blnReslt = True
                Next

                If blnReslt = False Then
                    For Each p In listProcedures
                        If Not p = 0 AndAlso Not roomProcedures.Contains(p) Then
                            blnReslt = False
                            Exit For
                        Else
                            blnReslt = True
                        End If
                    Next
                End If

                Return blnReslt
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>IsProcedureRoom", ex)
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function ContainsEndoscopistProcedures(endoID As Integer, listProcedures As List(Of Integer)) As Boolean
        Try
            Dim da As New DataAccess_Sch

            Using db As New ERS.Data.GastroDbEntities

                Dim endosForProc = da.GetEndoscopistsByProcedureTypes(endoID)

                For Each p In listProcedures
                    If Not endosForProc.Contains(p) Then Return False
                Next

                Return True
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>ContainsEndoscopistProcedures", ex)
        End Try
    End Function

    Public Shared Function getEndoscopistAppointmentRules(endoId As Integer, diaryIds As List(Of Integer), diaryDateTime As DateTime, singleInstance As Boolean) As Boolean
        Try
            Dim appointmentProcedureTypes As New List(Of Integer)
            Using db As New ERS.Data.GastroDbEntities

                Dim appointments = (From a In db.ERS_Appointments Join p In db.ERS_AppointmentProcedureTypes On a.AppointmentId Equals p.AppointmentID Join d In db.ERS_SCH_DiaryPages On d.DiaryId Equals a.DiaryId Where diaryIds.Contains(a.DiaryId))
                If appointments IsNot Nothing Then
                    If Not singleInstance Then
                        appointmentProcedureTypes.AddRange((From a In db.ERS_Appointments
                                                            Join p In db.ERS_AppointmentProcedureTypes On a.AppointmentId Equals p.AppointmentID
                                                            Join d In db.ERS_SCH_DiaryPages On d.DiaryId Equals a.DiaryId
                                                            Let AppointmentDate = EntityFunctions.TruncateTime(a.StartDateTime)
                                                            Where diaryIds.Contains(a.DiaryId) And AppointmentDate >= diaryDateTime
                                                            Select p.ProcedureTypeID Distinct).ToList)
                    Else
                        appointmentProcedureTypes.AddRange((From a In db.ERS_Appointments
                                                            Join p In db.ERS_AppointmentProcedureTypes On a.AppointmentId Equals p.AppointmentID
                                                            Join d In db.ERS_SCH_DiaryPages On d.DiaryId Equals a.DiaryId
                                                            Let AppointmentDate = EntityFunctions.TruncateTime(a.StartDateTime)
                                                            Where diaryIds.Contains(a.DiaryId) And AppointmentDate = diaryDateTime
                                                            Select p.ProcedureTypeID Distinct).ToList)
                    End If
                End If

                Dim da As New DataAccess_Sch
                Dim endosForProc = da.GetEndoscopistsByProcedureTypes(endoId)

                For Each p In appointmentProcedureTypes
                    If Not endosForProc.Contains(p) Then Return False
                Next

                Return True

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error checking futuire appointment rules", ex)
            Throw New Exception("System could not calculate endoscopists ability to carry out attached appointments")
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function GetTemplateAppointmentsByDay(diaryId As Integer, startDate As DateTime)
        Try
            Dim da As New DataAccess_Sch
            Dim dbResult = da.getdiaryAppointments(diaryId, CDate(startDate)).AsEnumerable.Where(Function(x) x.Field(Of DateTime)("StartDateTime").Date = startDate.Date)
            Dim diaryAppointments As New List(Of Object)

            For Each r In dbResult
                'If CDate(r("StartDateTime")) = startDate Then
                Dim appointmentDate = CDate(r("StartDateTime")).ToString("ddd dd MMM yyyy HH:mm")
                Dim PatientName = r("PatientName")
                Dim ProcedureDetails = ""
                If Not String.IsNullOrWhiteSpace(r("ProcedureType")) And Not String.IsNullOrWhiteSpace(r("TherapeuticType")) Then
                    ProcedureDetails = r("ProcedureType") & " - " & r("TherapeuticType")
                Else
                    ProcedureDetails = If(Not String.IsNullOrWhiteSpace(r("ProcedureType")), r("ProcedureType"), r("TherapeuticType"))
                End If

                Dim obj = New With {
                    .appointmentDate = appointmentDate,
                    .patientName = PatientName,
                    .appointmentProcedureDetails = ProcedureDetails
                }
                diaryAppointments.Add(obj)
                'End If
            Next

            Return New Script.Serialization.JavaScriptSerializer().Serialize(diaryAppointments)
        Catch ex As Exception
            Throw
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function GetTemplateAppointments(diaryId As Integer, startDate As DateTime) As String
        Try
            Dim da As New DataAccess_Sch
            Dim dbResult = da.getdiaryAppointments(diaryId, CDate(startDate))
            Dim diaryAppointments As New List(Of Object)

            For Each r In dbResult.AsEnumerable
                'If CDate(r("StartDateTime")) = startDate Then
                Dim appointmentDate = CDate(r("StartDateTime")).ToString("ddd dd MMM yyyy HH:mm")
                Dim PatientName = r("PatientName")
                Dim ProcedureDetails = ""
                If Not String.IsNullOrWhiteSpace(r("ProcedureType")) And Not String.IsNullOrWhiteSpace(r("TherapeuticType")) Then
                    ProcedureDetails = r("ProcedureType") & " - " & r("TherapeuticType")
                Else
                    ProcedureDetails = If(Not String.IsNullOrWhiteSpace(r("ProcedureType")), r("ProcedureType"), r("TherapeuticType"))
                End If

                Dim obj = New With {
                    .appointmentDate = appointmentDate,
                    .patientName = PatientName,
                    .appointmentProcedureDetails = ProcedureDetails
                }
                diaryAppointments.Add(obj)
                'End If
            Next

            Return New Script.Serialization.JavaScriptSerializer().Serialize(diaryAppointments)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>GetTemplateAppointments", ex)
            Throw ex
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function GetTemplateEnd(templateId As Integer, startDateTime As DateTime) As String
        Try
            Dim da As New DataAccess_Sch
            Return da.getTemplateEndTime(templateId, startDateTime).TimeOfDay.ToString()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>GetTemplateEnd", ex)
            Throw ex
        End Try
    End Function

    Public Shared Function GetTemplateEndDate(templateId As Integer, startDateTime As DateTime) As String
        Try
            Dim da As New DataAccess_Sch
            Return da.getTemplateEndTime(templateId, startDateTime).TimeOfDay.ToString()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>GetTemplateEnd", ex)
            Throw ex
        End Try
    End Function

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        If e.Argument.ToLower = "reload" Then
            DiaryRadScheduler.Rebind()
        End If
    End Sub

    Protected Sub AdvancedInsertForm1_Template_Added(sender As Object, a As Appointment)
        Try
            With a
                AppointmentsDataSource.InsertParameters("Subject").DefaultValue = .Subject
                AppointmentsDataSource.InsertParameters("DiaryStart").DefaultValue = .Start
                AppointmentsDataSource.InsertParameters("DiaryEnd").DefaultValue = .Start
                AppointmentsDataSource.InsertParameters("RoomID").DefaultValue = .Resources.Where(Function(x) x.Type = "Room").FirstOrDefault.Key
                AppointmentsDataSource.InsertParameters("UserID").DefaultValue = .Resources.Where(Function(x) x.Type = "Endoscopist").FirstOrDefault.Key
                AppointmentsDataSource.InsertParameters("ListConsultant").DefaultValue = .Resources.Where(Function(x) x.Type = "ListConsultant").FirstOrDefault.Key
                AppointmentsDataSource.InsertParameters("RecurrenceRule").DefaultValue = .RecurrenceRule
                AppointmentsDataSource.InsertParameters("RecurrenceParentID").DefaultValue = .RecurrenceParentID
                AppointmentsDataSource.InsertParameters("Description").DefaultValue = .Description
                AppointmentsDataSource.InsertParameters("OperatingHospitalId").DefaultValue = OperatingHospitalID
                AppointmentsDataSource.InsertParameters("LoggedInUserId").DefaultValue = DataAdapter.LoggedInUserId
                AppointmentsDataSource.InsertParameters("ListRulesId").DefaultValue = .Resources.Where(Function(x) x.Type = "ListRulesId").FirstOrDefault.Key
                AppointmentsDataSource.InsertParameters("Training").DefaultValue = CBool(.Resources.Where(Function(x) x.Type = "IsTrainingList").FirstOrDefault.Text)
            End With
            AppointmentsDataSource.Insert()
            DiaryRadScheduler.HideEditForm()
            DiaryRadScheduler.Rebind()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error adding diary template", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error adding the diary template")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub AdvancedEditForm1_Template_Updated(sender As Object, oldAppointment As Appointment, a As Appointment)
        Try
            With a
                AppointmentsDataSource.UpdateParameters("DiaryId").DefaultValue = a.ID
                AppointmentsDataSource.UpdateParameters("Subject").DefaultValue = .Subject
                AppointmentsDataSource.UpdateParameters("DiaryStart").DefaultValue = .Start
                AppointmentsDataSource.UpdateParameters("DiaryEnd").DefaultValue = .End
                AppointmentsDataSource.UpdateParameters("RoomID").DefaultValue = .Resources.Where(Function(x) x.Type = "Room").FirstOrDefault.Key
                AppointmentsDataSource.UpdateParameters("UserID").DefaultValue = a.Resources.Where(Function(x) x.Type = "Endoscopist").FirstOrDefault.Key
                AppointmentsDataSource.UpdateParameters("ListConsultant").DefaultValue = a.Resources.Where(Function(x) x.Type = "ListConsultant").FirstOrDefault.Key
                AppointmentsDataSource.UpdateParameters("RecurrenceRule").DefaultValue = oldAppointment.RecurrenceRule
                AppointmentsDataSource.UpdateParameters("RecurrenceParentID").DefaultValue = .RecurrenceParentID
                AppointmentsDataSource.UpdateParameters("LoggedInUserId").DefaultValue = DataAdapter.LoggedInUserId
                AppointmentsDataSource.UpdateParameters("Description").DefaultValue = .Description
                AppointmentsDataSource.UpdateParameters("ListRulesId").DefaultValue = .Resources.Where(Function(x) x.Type = "ListRulesId").FirstOrDefault.Key
                AppointmentsDataSource.UpdateParameters("Training").DefaultValue = CBool(.Resources.Where(Function(x) x.Type = "IsTrainingList").FirstOrDefault.Text)
            End With
            AppointmentsDataSource.Update()
            DiaryRadScheduler.HideEditForm()
            DiaryRadScheduler.Rebind()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error adding diary template", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error adding the diary template")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub DiaryRadScheduler_OccurrenceDelete(sender As Object, e As OccurrenceDeleteEventArgs)
        Try
            With e.Appointment
                AppointmentsDataSource.UpdateParameters("DiaryId").DefaultValue = .ID
                AppointmentsDataSource.UpdateParameters("Subject").DefaultValue = .Subject
                AppointmentsDataSource.UpdateParameters("DiaryStart").DefaultValue = .Start
                AppointmentsDataSource.UpdateParameters("DiaryEnd").DefaultValue = .End
                AppointmentsDataSource.UpdateParameters("RoomID").DefaultValue = .Resources.Where(Function(x) x.Type = "Room").FirstOrDefault.Key
                AppointmentsDataSource.UpdateParameters("UserID").DefaultValue = .Resources.Where(Function(x) x.Type = "Endoscopist").FirstOrDefault.Key
                AppointmentsDataSource.UpdateParameters("ListConsultant").DefaultValue = .Resources.Where(Function(x) x.Type = "ListConsultant").FirstOrDefault.Text

                'if command action is delete single occurence
                Dim appointmentRecurrence As RecurrenceRule = Nothing
                RecurrenceRule.TryParse(.RecurrenceRule, appointmentRecurrence)
                appointmentRecurrence.Exceptions.Add(e.OccurrenceAppointment.Start)

                AppointmentsDataSource.UpdateParameters("RecurrenceRule").DefaultValue = If(appointmentRecurrence, "").ToString
                AppointmentsDataSource.UpdateParameters("RecurrenceParentID").DefaultValue = 0
                AppointmentsDataSource.UpdateParameters("LoggedInUserId").DefaultValue = DataAdapter.LoggedInUserId
                AppointmentsDataSource.UpdateParameters("Description").DefaultValue = .Description
                AppointmentsDataSource.UpdateParameters("ListRulesId").DefaultValue = .Resources.Where(Function(x) x.Type = "Template").FirstOrDefault.Key
                AppointmentsDataSource.UpdateParameters("Training").DefaultValue = CBool(.Resources.Where(Function(x) x.Type = "IsTrainingList").FirstOrDefault.Text)
            End With

            AppointmentsDataSource.Update()
            DiaryRadScheduler.HideEditForm()
            DiaryRadScheduler.Rebind()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error adding diary template", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error adding the diary template")
            RadNotification1.Show()
        End Try
        e.Cancel = True
    End Sub

    Protected Sub DiaryRadScheduler_NavigationComplete(sender As Object, e As SchedulerNavigationCompleteEventArgs)
        If e.Command = SchedulerNavigationCommand.SwitchToWeekView Then
            WeekViewRoomsDropdown.Visible = True
            RoomsDropdown.Visible = False
            SelectRoomButton.Visible = False
        Else
            WeekViewRoomsDropdown.Visible = False
            RoomsDropdown.Visible = True
            SelectRoomButton.Visible = True
        End If

        SelectRoomButton_Click(SelectRoomButton, Nothing)
    End Sub

    Protected Sub WeekViewRoomsDropdown_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        RoomsDataSource.SelectParameters("FieldValue").DefaultValue = WeekViewRoomsDropdown.SelectedValue
        RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = CInt(OperatingHospitalID)
        DiaryRadScheduler.Rebind()
    End Sub

    Protected Sub RoomsDropdown_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        SelectRoomButton_Click(Nothing, Nothing)
    End Sub

#End Region
End Class

