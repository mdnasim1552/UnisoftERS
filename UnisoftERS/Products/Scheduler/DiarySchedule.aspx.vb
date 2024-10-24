Imports System.Data.Entity.Core.Objects
Imports System.Web.Script.Serialization
Imports DevExpress.Pdf.Native.BouncyCastle.Asn1.Ocsp
Imports DevExpress.Xpo.DB
Imports Telerik.Web.Design
Imports Telerik.Web.UI


Public Class DiarySchedule
    Inherits System.Web.UI.Page

#Region "Page Properties"
    Private _dataAdapter As DataAccess = Nothing
    Public day = ""
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

    ReadOnly Property OperatingHospitalID As Integer
        Get
            If String.IsNullOrWhiteSpace(HospitalDropDownList.SelectedValue) Then
                Return CInt(Session("OperatingHospitalId"))
            Else
                Return CInt(HospitalDropDownList.SelectedValue)
            End If
        End Get
    End Property


    Public Property CalendarView As SchedulerViewType
        Get
            If Not String.IsNullOrWhiteSpace(Session("CalendarView")) Then
                Return Session("CalendarView")
            Else
                Return SchedulerViewType.DayView
            End If
        End Get
        Set(value As SchedulerViewType)
            Session("CalendarView") = value
        End Set
    End Property
#End Region



#Region "Web methods"
    <System.Web.Services.WebMethod>
    Public Shared Function CheckListForAppointments(diaryId As Integer) As Boolean
        Dim da As New DataAccess_Sch
        Dim dt = da.GetListAppointments(diaryId)
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Return True
        Else
            Return False
        End If
    End Function
    <System.Web.Services.WebMethod>
    Public Shared Function AppointmentLetterCheck(operatingHospitalId As Integer) As Boolean
        Dim da As New DataAccess_Sch
        Dim letterTemplate = da.GetLetterTemplate(1, operatingHospitalId)
        If letterTemplate Is Nothing OrElse letterTemplate.Rows.Count = 0 Then
            Return False
        Else
            Return True
        End If
    End Function
    <System.Web.Services.WebMethod>
    Public Shared Sub SetAppointmentId(appointmentId As Integer)
        Dim ctx As HttpContext = System.Web.HttpContext.Current
        ctx.Session("AppointmentId") = appointmentId
    End Sub

    <System.Web.Services.WebMethod>
    Public Shared Function GetAppointmentId() As Integer
        Dim ctx As HttpContext = System.Web.HttpContext.Current
        If Not String.IsNullOrWhiteSpace(ctx.Session("AppointmentId")) Then
            Return ctx.Session("AppointmentId")
        Else
            Return 0
        End If
    End Function

    <System.Web.Services.WebMethod>
    Shared Function getProcedurePoints(procedureTypeId As Integer, operatingHospitalId As Integer, isTraining As Boolean, isNonGI As Boolean, isDiagnostic As Boolean) As String
        Try
            Dim da As New DataAccess_Sch
            Dim dt = da.GetProcedurePointMappings(procedureTypeId, operatingHospitalId, isTraining, isNonGI)
            Dim obj As New Object

            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)
                obj = New With {
               .length = If(isDiagnostic, CInt(dr("DiagnosticMinutes")), CInt(dr("TherapeuticMinutes"))),
               .points = If(isDiagnostic, CDec(dr("DiagnosticPoints")), CDec(dr("TherapeuticPoints")))
               }
            Else
                obj = New With {
                .length = 15,
                .points = 1
                }
            End If


            Return New JavaScriptSerializer().Serialize(obj)
        Catch ex As Exception
            Throw ex
        End Try
    End Function



    <System.Web.Services.WebMethod()>
    Public Shared Sub markPatientAttended(appointmentId As Integer)
        Try
            Dim da As New DataAccess_Sch
            da.markPatientAttended(appointmentId)
        Catch ex As Exception
            Throw ex
        End Try

    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub markPatientDischarged(appointmentId As Integer)
        Try
            Dim da As New DataAccess_Sch
            da.markPatientDischarged(appointmentId)
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function GetPatientPathwayDetails(appointmentId As Integer) As String
        Dim da As New DataAccess
        Dim dbResult = da.getPatientPathwayTimes(appointmentId)
        Dim patientPathway As New List(Of Object)

        For Each r In dbResult.AsEnumerable
            Dim arrivalTime = If(Not r.IsNull("PatientAdmissionTime"), CDate(r("PatientAdmissionTime")).ToShortTimeString, "")
            Dim DischargeTime = If(Not r.IsNull("PatientDischargeTime"), CDate(r("PatientDischargeTime")).ToShortTimeString, "")

            Dim obj = New With {
                .appointmentId = appointmentId,
                .arrivalTime = arrivalTime,
                .dischargeTime = DischargeTime
            }
            patientPathway.Add(obj)
        Next

        Return New JavaScriptSerializer().Serialize(patientPathway)
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function BookedFromWaitlist(appointmentId As Integer) As Boolean
        Try
            Dim da As New DataAccess_Sch
            Return da.BookedFromWaitlist(appointmentId)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in BookedFromWaitlist", ex)
            Return False
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Sub markPatientDNA(appointmentId As Integer)
        Try
            Dim da As New DataAccess_Sch
            da.markPatientDNA(appointmentId)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in markPatientDNA", ex)
            Throw ex
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub updatePatientStatus(appointmentId As Integer, statusCode As String)
        Try
            Dim da As New DataAccess_Sch
            da.updatePatientStatus(appointmentId, statusCode)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in updatePatientStatus", ex)
            Throw ex
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub unmarkPatientAttended(appointmentId As Integer)
        Try
            Dim da As New DataAccess_Sch
            da.unmarkPatientAttended(appointmentId)
        Catch ex As Exception
            Throw ex
        End Try

    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub SaveDiaryNotes(diaryId As Integer, listNotes As String)
        Try
            Dim da As New DataAccess_Sch
            da.saveDiaryNotes(diaryId, listNotes)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>MoveTemplate", ex)
            Throw ex
        End Try
    End Sub


    <System.Web.Services.WebMethod()>
    Public Shared Function GetDiaryDetails(diaryId As Integer, loggedInUserId As Integer) As String
        Try
            Dim da As New DataAccess
            Dim dtUserPermissions = da.GetUser(loggedInUserId)
            Dim canOverbook As Boolean
            Dim canOverrideSchedule As Boolean
            If dtUserPermissions IsNot Nothing AndAlso dtUserPermissions.Rows.Count > 0 Then
                Dim dr = dtUserPermissions.Rows(0)
                canOverbook = CBool(dr("CanOverbookLists"))
                canOverrideSchedule = CBool(dr("CanOverrideSchedule"))

            End If

            Dim daSch As New DataAccess_Sch
            Dim dt = daSch.GetListDiaryDetails(diaryId)


            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)

                Dim obj = New With {
                .listName = dr("Subject"),
                .listStart = CDate(dr("DiaryStart")).ToString("dd/MM/yyyy HH:mm"),
                .listEnd = CDate(dr("DiaryEnd")).ToString("dd/MM/yyyy HH:mm"),
                .listConsultant = dr("ListConsultant"),
                .listEndoscopist = dr("EndoscopistName"),
                .listGender = dr("ListGender"),
                .suppressed = dr("Suppressed"),
                .points = dr("TotalPoints"),
                .overBookedPoints = dr("OverBookedPoints"),
                .blockedPoints = dr("BlockedPoints"),
                .notes = dr("Notes"),
                .listRulesId = CInt(dr("ListRulesId")),
                .roomId = CInt(dr("RoomId")),
                .operatingHospitalId = CInt(dr("OperatingHospitalId")),
                .endoscopistId = CInt(dr("EndoscopistId")),
                .locked = CBool(dr("Locked")),
                .appointments = CBool(dr("Appointments")),
                .appointmentPoints = CDec(dr("AppointmentPoints")), 'Added by rony tfs-3861
                .totalUsedMinutes = CInt(dr("TotalUsedMinutes")),
                .cancelledAppointments = CBool(dr("CancelledAppointments")),
                .recurring = CBool(dr("Recurring")),
                .recurrancePattern = If(dr.IsNull("RecurrancePattern"), "", "occurs " & dr("RecurrancePattern")),
                .listMinutes = CInt(dr("ListMinutes")),
                .canOverbook = canOverbook,
                .canOverrideSchedule = canOverrideSchedule
            }


                Return New Script.Serialization.JavaScriptSerializer().Serialize(obj)
            Else
                Return New Script.Serialization.JavaScriptSerializer().Serialize("")
            End If


        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>MoveTemplate", ex)
            Throw ex
        End Try
    End Function


    '<System.Web.Services.WebMethod()>
    'Public Shared Function GetRecurringLists(diaryId As Integer) As String
    '    Try
    '        Dim da As New DataAccess_Sch
    '        Dim dt = da.GetRecurringLists(diaryId)

    '        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
    '            Dim dr = dt.Rows(0)

    '            Dim obj = New With {
    '            .listName = dr("Subject"),
    '            .listStart = CDate(dr("DiaryStart")).ToString("dd/MM/yyyy HH:mm"),
    '            .listEnd = CDate(dr("DiaryEnd")).ToString("dd/MM/yyyy HH:mm")
    '        }


    '            Return New Script.Serialization.JavaScriptSerializer().Serialize(obj)
    '        Else
    '            Return New Script.Serialization.JavaScriptSerializer().Serialize("")
    '        End If


    '    Catch ex As Exception
    '        LogManager.LogManagerInstance.LogError("Error in DiaryPages>MoveTemplate", ex)
    '        Throw ex
    '    End Try
    'End Function



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

            Using db As New ERS.Data.GastroDbEntities
                Dim listProcedures = (From l In db.ERS_SCH_ListSlots Where l.ListRulesId = listRulesId And Not l.ProcedureTypeId = 0 Select l.ProcedureTypeId.Value Distinct).ToList
                Dim roomProcedures = (From p In db.ERS_SCH_Rooms Join rp In db.ERS_SCH_RoomProcedures On p.RoomId Equals rp.RoomId Where rp.RoomId = roomId Select rp.ProcedureTypeId).ToList

                For Each p In listProcedures
                    If Not roomProcedures.Contains(p) Then Return False
                Next

                Return True
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>IsProcedureRoom", ex)
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function ContainsEndoscopistProcedures(endoID As Integer, listRulesId As Integer) As Boolean
        Try
            Dim da As New DataAccess_Sch

            Using db As New ERS.Data.GastroDbEntities
                Dim listProcedures = (From l In db.ERS_SCH_ListSlots Where l.ListRulesId = listRulesId And Not l.ProcedureTypeId = 0 Select l.ProcedureTypeId.Value Distinct).ToList

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

    <System.Web.Services.WebMethod()>
    Public Shared Function ValidNewSlot(roomId As Integer, endoscopistId As Integer, procedureTypeId As Integer) As String
        Dim procedureRoomValid = False
        Dim procedureEndoscopistValid = False
        Dim retVal = ""

        Dim da As New DataAccess_Sch
        If da.GetRoomProcedureTypes(roomId).AsEnumerable.Any(Function(x) x("ProcedureTypeId") = procedureTypeId) Or procedureTypeId = 0 Then
            procedureRoomValid = True
        End If

        If da.GetEndoscopistProcedures(endoscopistId).AsEnumerable.Any(Function(x) x("ProcedureTypeId") = procedureTypeId) Or procedureTypeId = 0 Then
            procedureEndoscopistValid = True
        End If

        If procedureRoomValid = False And procedureEndoscopistValid = False Then
            retVal = "This procedure cannot be carried out in this room or by this endoscopist"
        ElseIf procedureEndoscopistValid = False Then
            retVal = "This procedure cannot be carried out by this endoscopist"
        ElseIf procedureRoomValid = False Then
            retVal = "This procedure cannot be carried out in this room"
        End If

        Return retVal
    End Function
#End Region

    Private Sub Page_Init1(sender As Object, e As EventArgs) Handles Me.Init
        AppointmentsDataSource.ConnectionString = DataAccess.ConnectionStr
        AppointmentsDataSource.SelectParameters("DiaryDate").DefaultValue = Now


        Dim manager As ScriptManager = RadScriptManager.GetCurrent(Page)
        manager.Scripts.Add(New ScriptReference("~\Scripts\AdvancedForm.js"))
    End Sub

    Private Sub Page_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            'SelectRoomButton_Click(Nothing, Nothing)
        End If
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

            TrustDropDownList.DataSource = DataAdapter_Sch.GetSchedulerTrusts
            TrustDropDownList.DataBind()
            TrustDropDownList.SelectedValue = CInt(Session("TrustId"))
            If (TrustDropDownList.Items.Count = 1) Then
                TrustDiv.Visible = False
            End If

            PopulateFromTrust(CInt(Session("TrustId")))

            HospitalDropDownList.SelectedValue = CInt(Session("OperatingHospitalId"))

            RoomsDropdown.DataSource = DataAdapter_Sch.GetSchedulerRooms(CInt(Session("OperatingHospitalId")))
            RoomsDropdown.DataBind()

            Dim roomIDs As String = ""
            For Each itm As RadComboBoxItem In RoomsDropdown.Items.Take(3)
                itm.Checked = True
                roomIDs = roomIDs & IIf(roomIDs = Nothing, itm.Value, "," & itm.Value)
            Next


            RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = CInt(Session("OperatingHospitalId"))
            RoomsDataSource.SelectParameters("FieldValue").DefaultValue = roomIDs
            day = If(Request.QueryString("type") IsNot Nothing, Request.QueryString("type").ToString(), "")
            If day = "" Then
                CalendarView = SchedulerViewType.MonthView
                DiaryRadScheduler.EnableViewState = False
                DiaryRadScheduler.Visible = False
                DiaryOverviewRadScheduler.EnableViewState = True
                DiaryOverviewRadScheduler.Visible = True
                SelectRoomButton_Click(Nothing, Nothing)
                loadDiary(Now.Date)
                loadOverView(Now.Month, Now.Year)
                DiaryRadScheduler.HoursPanelTimeFormat = "HH:mm tt"
                DiaryRadScheduler.TimeLabelRowSpan = 1
                setDate(Now)
            Else
                ' by Ferdowsi -------  active day view 
                CalendarView = SchedulerViewType.DayView
                ZoomLevelLabel.Text = "100% zoom"
                DiaryRadScheduler.Visible = True
                DiaryRadScheduler.EnableViewState = True
                DiaryRadScheduler.ViewStateMode = ViewStateMode.Enabled
                DiaryOverviewRadScheduler.Visible = False
                DiaryOverviewRadScheduler.EnableViewState = False

                setDate(day)
                loadDiary(day)
            End If
        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-selected-calendar-view", "setCalendarView('" & CalendarView.ToString.ToLower().Replace("view", "") & "');", True)

            If UCase(ConfigurationManager.AppSettings("DisplayWaitlist").ToString()) = "TRUE" Then
                BookFromWaitlistRadButton.Visible = True
            Else
                BookFromWaitlistRadButton.Visible = False
            End If
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
            If DiaryRadScheduler.SelectedView = SchedulerViewType.MonthView Then
                e.Appointment.Attributes.Add("slotCount", CType(e.Appointment.DataItem, DataRowView).Row("SlotCount"))
                e.Appointment.Attributes.Add("roomId", CType(e.Appointment.DataItem, DataRowView).Row("RoomId"))
                e.Appointment.Attributes.Add("training", CType(e.Appointment.DataItem, DataRowView).Row("Training"))
                e.Appointment.Attributes.Add("diaryId", CType(e.Appointment.DataItem, DataRowView).Row("DiaryId"))
                e.Appointment.Attributes.Add("lockedDiary", CType(e.Appointment.DataItem, DataRowView).Row("LockedDiary"))

                'e.Appointment.ToolTip = CType(e.Appointment.DataItem, DataRowView).Row("Subject") & vbCrLf & CType(e.Appointment.DataItem, DataRowView).Row("Description")

            Else
                e.Appointment.ToolTip = "" 'off tooltip for whole div in DayView
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
                e.Appointment.Attributes.Add("listSlotId", CType(e.Appointment.DataItem, DataRowView).Row("ListSlotId"))
                e.Appointment.Attributes.Add("locked", CType(e.Appointment.DataItem, DataRowView).Row("Locked"))
                e.Appointment.Attributes.Add("lockedDiary", CType(e.Appointment.DataItem, DataRowView).Row("LockedDiary"))
                e.Appointment.Attributes.Add("endoscopistId", CType(e.Appointment.DataItem, DataRowView).Row("EndoscopistId"))


                If e.Appointment.Attributes("slotType").ToLower = "patientbooking" And Not CType(e.Appointment.Attributes("locked"), Boolean) Then
                    Dim dr = CType(e.Appointment.DataItem, DataRowView)
                    'e.Appointment.ToolTip = dr("Description").ToString.Replace("<br />", vbCrLf)
                    Dim tooltipText As String = dr("Description")

                    e.Appointment.Attributes.Add("appointmentId", CType(e.Appointment.DataItem, DataRowView).Row("AppointmentId"))
                    e.Appointment.Attributes.Add("statusCode", CType(e.Appointment.DataItem, DataRowView).Row("StatusCode"))
                    e.Appointment.Attributes.Add("operatingHospitalId", CType(e.Appointment.DataItem, DataRowView).Row("OperatingHospitalId"))

                    e.Appointment.CssClass = "patient-booking-slot"


                    e.Appointment.ContextMenuID = "SchedulerBookingContextMenu"

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

                                'If Not String.IsNullOrWhiteSpace(dr("StatusCode")) Then e.Appointment.ToolTip += vbCrLf & "Booked"
                                If Not String.IsNullOrWhiteSpace(dr("StatusCode")) Then tooltipText += "<br />" & "Booked"
                            Case "P"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#7FCC7F")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"

                                'e.Appointment.ToolTip += vbCrLf & "Partially booked"
                                tooltipText += "<br />" & "Partially booked"

                            Case "A"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#7FDBF5")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                'e.Appointment.ToolTip += vbCrLf & "Arrived"
                                tooltipText += "<br />" & "Arrived"

                            Case "BA"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#B5D2E6")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                'e.Appointment.ToolTip += vbCrLf & "Arrived"
                                tooltipText += "<br />" & "Arrived"
                            Case "D"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#E38AC2")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                'e.Appointment.ToolTip += vbCrLf & "Patient DNA"
                                tooltipText += "<br />" & "Patient DNA"
                            Case "X"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#8D8D8D")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                ' e.Appointment.ToolTip += vbCrLf & "Abandoned"
                                tooltipText += "<br />" & "Abandoned"
                            Case "IP"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#FFD966")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                'e.Appointment.ToolTip += vbCrLf & "In progress"
                                tooltipText += "<br />" & "In progress"
                            Case "DC"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#5F5FE3")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#FFFFFF")

                                e.Appointment.CssClass += " row-colour-opacity"
                                'e.Appointment.ToolTip += vbCrLf & "Discharged"
                                tooltipText += "<br />" & "Discharged"
                            Case "RC"

                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#FFA500")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"
                                'e.Appointment.ToolTip += vbCrLf & "In recovery"
                                tooltipText += "<br />" & "In recovery"
                                tooltipText += "<br />" & "Discharged"

                            Case "C"   ' Added by Ferdowsi
                                e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#f30505")

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#FFFFFF")

                                e.Appointment.CssClass += " row-colour-opacity"
                                tooltipText += "<br />" & "Cancelled"
                            Case Else

                                e.Appointment.BackColor = slotColor

                                e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                                e.Appointment.CssClass += " row-colour-opacity"

                        End Select
                        e.Appointment.Attributes.Add("subject-tooltip", tooltipText)
                    Else

                        e.Appointment.BackColor = slotColor

                        e.Appointment.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")

                        e.Appointment.CssClass += " row-colour-opacity"

                    End If

                ElseIf e.Appointment.Attributes("slotType").ToLower = "reservedslot" Then 'reserved slot (booking in progress)
                    'e.Appointment.Attributes.Add("lockedByUser", CType(e.Appointment.DataItem, DataRowView).Row("EndoscopistName"))
                    'e.Appointment.BackColor = System.Drawing.Color.Yellow
                    'e.Appointment.CssClass = "free-slot"
                ElseIf e.Appointment.Attributes("slotType").ToLower = "freeslot" Then 'appointment/patient booking
                    Dim contextMenuId = "SchedulerAppointmentContextMenu"
                    e.Appointment.ContextMenuID = contextMenuId

                    Dim dr = CType(e.Appointment.DataItem, DataRowView)
                    'e.Appointment.ToolTip = CDate(dr("DiaryStart")).ToShortTimeString & "-" & CDate(dr("DiaryEnd")).ToShortTimeString
                    Dim tooltipText As String = CDate(dr("DiaryStart")).ToShortTimeString & "-" & CDate(dr("DiaryEnd")).ToShortTimeString
                    e.Appointment.Attributes.Add("subject-tooltip", tooltipText)

                    e.Appointment.CssClass = "free-slot"

                    'for locked slots prior to functionality change on 12.02.24
                    If CBool(e.Appointment.Attributes("locked")) Then
                        e.Appointment.CssClass += " blocked-slot"
                        e.Appointment.Subject = "BLOCKED SLOT"
                        e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#8D8D8D")
                        e.Appointment.ContextMenuID = "BlockedSlotContextMenu"
                    End If
                ElseIf CBool(e.Appointment.Attributes("locked")) Then
                    e.Appointment.CssClass += " blocked-slot"
                    e.Appointment.Subject = "BLOCKED SLOT"
                    e.Appointment.BackColor = Drawing.ColorTranslator.FromHtml("#8D8D8D")
                    e.Appointment.ContextMenuID = "BlockedSlotContextMenu"


                ElseIf e.Appointment.Attributes("slotType").ToLower = "endoflist" Then
                    e.Appointment.CssClass = "end-of-list align-center"


                End If

                If CBool(CType(e.Appointment.DataItem, DataRowView).Row("LockedDiary")) Then
                    e.Appointment.Attributes.Add("oncontextmenu", "alert('list locked');")
                    e.Appointment.ContextMenuID = "LockedDiaryContextMenu"
                End If
            End If

        Catch ex As Exception

        End Try
    End Sub



    Protected Sub SelectRoomButton_Click(sender As Object, e As EventArgs)
        Try

            Dim roomIDs As String = ""

            If Not String.IsNullOrWhiteSpace(Session("BookedRoom")) Then

                'switch to day view
                CalendarView = SchedulerViewType.DayView
                DiaryRadScheduler.Visible = True
                DiaryRadScheduler.EnableViewState = True
                loadDiary(If(Not String.IsNullOrWhiteSpace(Session("BookedDate")), CDate(Session("BookedDate")), DiaryDatePicker.SelectedDate))

                DiaryOverviewRadScheduler.Visible = False
                DiaryOverviewRadScheduler.EnableViewState = False

                HospitalDropDownList.SelectedValue = If(Session("BookedHospitalId"), OperatingHospitalID)

                RoomsDropdown.Items.Clear()
                'RoomsDropdown.DataSource = DataAdapter_Sch.GetAllRoomsForSelectedHospitals(If(Session("BookedHospitalId"), OperatingHospitalID)) --MH changed as below on 22 Feb 2024
                RoomsDropdown.DataSource = DataAdapter_Sch.GetSchedulerRooms(If(Session("BookedHospitalId"), OperatingHospitalID))
                RoomsDropdown.DataBind()
                RoomsDropdown.FindItemByValue(Session("BookedRoom")).Checked = True
            End If


            If Not String.IsNullOrWhiteSpace(Session("BookedDate")) Then setDate(CDate(Session("BookedDate")))


            Session("BookedDate") = Nothing
            Session("BookedHospitalId") = Nothing
            Session("BookedRoom") = Nothing



            If RoomsDropdown.CheckedItems.Count = 0 Then Exit Sub

            For Each itm As RadComboBoxItem In RoomsDropdown.CheckedItems
                roomIDs = roomIDs & IIf(roomIDs = Nothing, itm.Value, "," & itm.Value)
            Next

            RoomsDataSource.SelectParameters("FieldValue").DefaultValue = roomIDs
            RoomsDataSource.SelectParameters("OperatingHospitalId").DefaultValue = OperatingHospitalID

            If CalendarView = SchedulerViewType.DayView Then
                loadDiary(DiaryDatePicker.SelectedDate)
            Else
                If Not IsNothing(Session("SchedulerSelectedDate")) Then
                    DiaryOverviewRadScheduler.SelectedDate = Session("SchedulerSelectedDate")
                End If
                'loadOverView(DiaryDatePicker.SelectedDate, DiaryRadScheduler.SelectedDate.Year)
                loadOverView(DiaryOverviewRadScheduler.SelectedDate.Month, DiaryOverviewRadScheduler.SelectedDate.Year)
            End If

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading diary", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading your diary")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub loadDiary(selectedDate As DateTime)
        Try
            Dim selectedRoomIds As New List(Of Integer)
            Dim datevalue = DiaryRadScheduler.DayView.DayStartTime
            selectedRoomIds = RoomsDropdown.CheckedItems.Select(Function(x) CInt(x.Value)).ToList
            DiaryRadScheduler.Visible = True
            DiaryOverviewRadScheduler.Visible = False
            TodaysDateLinkButton.Visible = True
            lnkZoomIn.Visible = True
            ZoomLevelLabel.Visible = True
            lnkZoomOut.Visible = True
            DiaryRadScheduler.SelectedDate = selectedDate
            DiaryRadScheduler.DataSource = DataAdapter_Sch.GetDiaryDaySlots(OperatingHospitalID, True, selectedDate, selectedRoomIds)
            DiaryRadScheduler.DataBind()

            'If DiaryRadScheduler.Appointments IsNot Nothing AndAlso DiaryRadScheduler.Appointments.Count > 0 Then
            '    'check if the 1st list of the day is before the controls start time
            '    If day <> "" Or (DiaryRadScheduler.DayView.DayStartTime > DiaryRadScheduler.Appointments(0).Start.TimeOfDay) Then
            '        'set start time to the hour of the start of the list. ie 6.30 = 6.00
            '        DiaryRadScheduler.DayView.DayStartTime = New TimeSpan(DiaryRadScheduler.Appointments(0).Start.TimeOfDay.Hours, 0, 0)
            '    End If
            'End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading diary", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading your diary")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub showDayView()
        DiaryRadScheduler.Visible = True
        DiaryOverviewRadScheduler.Visible = False

        TodaysDateLinkButton.Visible = True
        lnkZoomIn.Visible = True
        ZoomLevelLabel.Visible = True
        lnkZoomOut.Visible = True

        'if 1st list is before 7.30 set start time to be on the hour
        Dim listStart = 0

    End Sub

    Private Sub loadOverView(month As Integer, year As Integer)
        Try
            Dim roomIds As New List(Of Integer)
            roomIds = RoomsDropdown.CheckedItems.Select(Function(x) CInt(x.Value)).ToList

            Dim dt = DataAdapter_Sch.GetDiaryOverView(month, year, OperatingHospitalID)
            If dt.AsEnumerable.Any(Function(x) roomIds.Contains(x("RoomId"))) Then
                DiaryOverviewRadScheduler.DataSource = dt.AsEnumerable.Where(Function(x) roomIds.Contains(x("RoomId"))).CopyToDataTable
                DiaryOverviewRadScheduler.DataBind()
            End If
            TodaysDateLinkButton.Visible = False
            lnkZoomIn.Visible = False
            ZoomLevelLabel.Visible = False
            lnkZoomOut.Visible = False
            DiaryOverviewRadScheduler.Visible = True
            DiaryRadScheduler.Visible = False
            DiaryRadScheduler.EnableViewState = False
            DiaryOverviewRadScheduler.SelectedView = SchedulerViewType.MonthView
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading diary", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading your diary")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub HospitalDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
        'RoomsDropdown.DataSource = DataAdapter_Sch.GetAllRoomsForSelectedHospitals(HospitalDropDownList.SelectedValue) -- MH changed as below on 22 Feb 2024
        RoomsDropdown.DataSource = DataAdapter_Sch.GetSchedulerRooms(HospitalDropDownList.SelectedValue)
        RoomsDropdown.DataBind()

        If RoomsDropdown.Items.Count > 0 Then
            For Each itm As RadComboBoxItem In RoomsDropdown.Items.Take(3)
                itm.Checked = True
            Next
        End If


        SelectRoomButton_Click(Nothing, Nothing)
    End Sub



    Public Shared Function getEndoscopistAppointmentRules(endoId As Integer, diaryId As Integer, diaryDateTime As DateTime, singleInstance As Boolean) As Boolean
        Try
            Dim appointmentProcedureTypes As New List(Of Integer)
            Using db As New ERS.Data.GastroDbEntities

                Dim appointments = (From a In db.ERS_Appointments Join p In db.ERS_AppointmentProcedureTypes On a.AppointmentId Equals p.AppointmentID Join d In db.ERS_SCH_DiaryPages On d.DiaryId Equals a.DiaryId Where a.DiaryId = diaryId)
                If appointments IsNot Nothing Then
                    If Not singleInstance Then
                        appointmentProcedureTypes.AddRange((From a In db.ERS_Appointments
                                                            Join p In db.ERS_AppointmentProcedureTypes On a.AppointmentId Equals p.AppointmentID
                                                            Join d In db.ERS_SCH_DiaryPages On d.DiaryId Equals a.DiaryId
                                                            Let AppointmentDate = EntityFunctions.TruncateTime(a.StartDateTime)
                                                            Where a.DiaryId = diaryId And AppointmentDate >= diaryDateTime
                                                            Select p.ProcedureTypeID Distinct).ToList)
                    Else
                        appointmentProcedureTypes.AddRange((From a In db.ERS_Appointments
                                                            Join p In db.ERS_AppointmentProcedureTypes On a.AppointmentId Equals p.AppointmentID
                                                            Join d In db.ERS_SCH_DiaryPages On d.DiaryId Equals a.DiaryId
                                                            Let AppointmentDate = EntityFunctions.TruncateTime(a.StartDateTime)
                                                            Where a.DiaryId = diaryId And AppointmentDate = diaryDateTime
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
            'With a
            '    AppointmentsDataSource.InsertParameters("Subject").DefaultValue = .Subject
            '    AppointmentsDataSource.InsertParameters("DiaryStart").DefaultValue = .Start
            '    AppointmentsDataSource.InsertParameters("DiaryEnd").DefaultValue = .Start
            '    AppointmentsDataSource.InsertParameters("RoomID").DefaultValue = .Resources.Where(Function(x) x.Type = "Room").FirstOrDefault.Key
            '    AppointmentsDataSource.InsertParameters("UserID").DefaultValue = .Resources.Where(Function(x) x.Type = "Endoscopist").FirstOrDefault.Key
            '    AppointmentsDataSource.InsertParameters("ListConsultant").DefaultValue = .Resources.Where(Function(x) x.Type = "ListConsultant").FirstOrDefault.Key
            '    AppointmentsDataSource.InsertParameters("RecurrenceRule").DefaultValue = .RecurrenceRule
            '    AppointmentsDataSource.InsertParameters("RecurrenceParentID").DefaultValue = .RecurrenceParentID
            '    AppointmentsDataSource.InsertParameters("Description").DefaultValue = .Description
            '    AppointmentsDataSource.InsertParameters("OperatingHospitalId").DefaultValue = OperatingHospitalID
            '    AppointmentsDataSource.InsertParameters("LoggedInUserId").DefaultValue = DataAdapter.LoggedInUserId
            '    AppointmentsDataSource.InsertParameters("ListRulesId").DefaultValue = .Resources.Where(Function(x) x.Type = "ListRulesId").FirstOrDefault.Key
            '    AppointmentsDataSource.InsertParameters("Training").DefaultValue = CBool(.Resources.Where(Function(x) x.Type = "IsTrainingList").FirstOrDefault.Text)
            '    AppointmentsDataSource.InsertParameters("ListGenderId").DefaultValue = CInt(.Resources.Where(Function(x) x.Type = "ListGenderId").FirstOrDefault.Text)
            '    AppointmentsDataSource.InsertParameters("IsGI").DefaultValue = CBool(.Resources.Where(Function(x) x.Type = "IsGI").FirstOrDefault.Text)
            'End With
            'AppointmentsDataSource.Insert()
            'DiaryRadScheduler.HideEditForm()


            SelectRoomButton_Click(Nothing, Nothing)


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
                AppointmentsDataSource.InsertParameters("IsGI").DefaultValue = CBool(.Resources.Where(Function(x) x.Type = "IsGI").FirstOrDefault.Text)
            End With
            AppointmentsDataSource.Update()
            DiaryRadScheduler.HideEditForm()
            SelectRoomButton_Click(Nothing, Nothing)
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
        'If SchedulerNavigationCommand.SwitchToWeekView Then
        '    WeekViewRoomsDropdown.Visible = True
        '    RoomsDropdown.Visible = False
        '    SelectRoomButton.Visible = False
        'Else
        '    WeekViewRoomsDropdown.Visible = False
        '    RoomsDropdown.Visible = True
        '    SelectRoomButton.Visible = True
        'End If

        'loadDiary()


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

    Protected Sub btnSaveAndApply_Click(sender As Object, e As EventArgs)
        Try
            If ModeHiddenField.Value.ToLower = "editslot" Then
                'check procedure type against the room if the procedure type is not blank
                If Not String.IsNullOrWhiteSpace(CType(sender, RadButton).CommandArgument) Then
                    Dim listSlotId As Integer = CType(sender, RadButton).CommandArgument
                    Dim slotStatusId As Integer = SlotComboBox.SelectedValue
                    Dim procedureTypeId As Integer = ProcedureTypesComboBox.SelectedValue
                    Dim isGI As Boolean = True
                    Dim points As Decimal = PointsRadNumericTextBox.Text
                    Dim length As Integer = SlotLengthRadNumericTextBox.Text

                    'check for overlapping of diaries by calculating the total length of diary using all slots.... 
                    Dim selectedStart As DateTime, selectedEnd As DateTime, diaryId As Integer = DiaryIdHiddenField.Value

                    'get all diaries belonging to this room on this date
                    Dim dtList = DataAdapter_Sch.GetDiaryDaySlots(OperatingHospitalID, True, CDate(SlotStartHiddenField.Value).ToShortDateString, {CInt(RoomIdHiddenField.Value)}.ToList)

                    'extract this diary of the slot that we're editing
                    Dim slotDiary = dtList.AsEnumerable.Where(Function(x) x("DiaryId") = diaryId)

                    'calculate the total amount of minutes, excluding the list slot that we're editing (incase we've changed the length) and add to the value in the length textbox
                    Dim totalMinutes = slotDiary.Where(Function(x) Not x("ListSlotId") = listSlotId).Sum(Function(x) x("SlotDuration")) + SlotLengthRadNumericTextBox.Value

                    'set the diary start and end 
                    selectedStart = slotDiary.Select(Function(x) x("DiaryStart")).FirstOrDefault
                    selectedEnd = selectedStart.AddMinutes(totalMinutes)

                    'check for overlaps
                    If dtList.AsEnumerable.Where(Function(x) Not x("DiaryId") = diaryId).Count > 0 Then
                        Dim dayDiaries As DataTable = dtList.AsEnumerable.Where(Function(x) Not x("DiaryId") = diaryId).CopyToDataTable
                        If dayDiaries.AsEnumerable.Any(Function(x) selectedStart >= x("DiaryStart") And selectedStart < x("DiaryEnd")) Or 'starts is in betwen a list
                    dayDiaries.AsEnumerable.Any(Function(x) selectedEnd > x("DiaryStart") And selectedEnd < x("DiaryEnd")) Or 'ends in between a list
                    dayDiaries.AsEnumerable.Any(Function(x) x("DiaryStart") >= selectedStart And x("DiaryStart") < selectedEnd) Then 'spans a list
                            Utilities.SetNotificationStyle(RadNotification1, "Changing this slot causes this lists to overlap with another one. Your changes have not saved", True, "Please correct")
                            RadNotification1.Show()
                            Exit Sub
                        End If
                    End If

                    'check if this now overlaps with any other lists that the endoscopist is part of
                    Dim endoDiaries = DataAdapter_Sch.GetEndoscopistDayDiaries(EndoscopistIdHiddenField.Value, selectedStart).AsEnumerable.Where(Function(x) Not x("DiaryId") = diaryId)
                    'check if and end diaries start or end date is between this start or end date
                    If endoDiaries.AsEnumerable.Any(Function(x) selectedStart >= x("DiaryStart") And selectedStart < x("DiaryEnd")) Or 'starts is in betwen a list
                    endoDiaries.AsEnumerable.Any(Function(x) selectedEnd > x("DiaryStart") And selectedEnd < x("DiaryEnd")) Or 'ends in between a list
                    endoDiaries.AsEnumerable.Any(Function(x) x("DiaryStart") >= selectedStart And x("DiaryStart") < selectedEnd) Then 'spans a list
                        Utilities.SetNotificationStyle(RadNotification1, "Changing this slot causes the endoscopist to have lists that overlap with this one. Your changes have not saved", True, "Please correct")
                        RadNotification1.Show()
                        Exit Sub
                    End If

                    'update list slot
                    DataAdapter_Sch.editListSlot(listSlotId, slotStatusId, procedureTypeId, points, length)
                    'rebind
                    SelectRoomButton_Click(Nothing, Nothing)
                End If
            ElseIf ModeHiddenField.Value = "addslot" Then
                'add overbooked slot
                Dim slotStatusId As Integer = SlotComboBox.SelectedValue
                Dim procedureTypeId As Integer = ProcedureTypesComboBox.SelectedValue
                Dim isGI As Boolean = True
                Dim points As Decimal = PointsRadNumericTextBox.Text
                Dim length As Integer = SlotLengthRadNumericTextBox.Text


                DataAdapter_Sch.addListSlot(ListRulesIdHiddenField.Value, slotStatusId, procedureTypeId, OperatingHospitalID, length, points)
                'rebind
                SelectRoomButton_Click(Nothing, Nothing)
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured editing list slot.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem editing this list slot.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub DiaryRadScheduler_AppointmentInserted(sender As Object, e As AppointmentInsertEventArgs)
        SelectRoomButton_Click(Nothing, Nothing)
        DiaryRadScheduler.ShowAdvancedEditForm(New Appointment)


    End Sub


    Protected Sub ConfirmDeleteScheduleListRadButton_Click(sender As Object, e As EventArgs) Handles ConfirmScheduleCancelRadButton.Click

        Dim otherText As String
        Dim cancelId = ListCancellConfirmationComboBox.SelectedValue
        Dim cancelText = ListCancellConfirmationComboBox.SelectedItem.Text
        If (cancelText = "other") Then
            otherText = ListTextArea.Text
        Else
            otherText = ""
        End If


        Dim DiaryID = DiaryIdHiddenField.Value
        Dim deleteOccurrences = False
        Dim cancelledBy = CInt(Session("PKUserId"))
        Dim Suppressed = True
        Try
            Dim da As New DataAccess_Sch
            da.Diary_Delete_Undo(DiaryID, Suppressed, cancelId, otherText, cancelledBy, deleteOccurrences)

            loadDiary(If(Not String.IsNullOrWhiteSpace(Session("BookedDate")), CDate(Session("BookedDate")), DiaryDatePicker.SelectedDate))
            loadOverView(DiaryRadScheduler.SelectedDate.Month, DiaryRadScheduler.SelectedDate.Year)
            SelectRoomButton_Click(Nothing, New EventArgs) ' added by ferdowsi, TFS 4432
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured deleting patient appointment.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem deleting patient booking.")
            RadNotification1.Show()
        End Try

    End Sub




    Protected Sub ConfirmDeleteBookingRadButton_Click(sender As Object, e As EventArgs)
        'ConfirmDeleteBookingRadButton_Click
        Dim intCurrentWorkingAppointmentId As Integer
        Dim blnAppointmentSaved As Boolean = False


        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim appointment = db.ERS_Appointments.Find(CInt(PatientAppointmentIDHiddenField.Value))
                appointment.AppointmentStatusId = 4
                appointment.CancelReasonId = CancellationReasonRadComboBox.SelectedValue
                appointment.StaffCancelledId = CInt(Session("PKUserId"))
                appointment.DateCancelled = Now
                'intCurrentWorkingAppointmentId = appointment.AppointmentId
                appointment.ListSlotId = Nothing

                If chkReturnToWaitlist.Checked Then
                    Dim waitlistRecord = db.ERS_Waiting_List.Find(appointment.WaitingListId)
                    If waitlistRecord IsNot Nothing Then waitlistRecord.WaitingListStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "R").FirstOrDefault.UniqueId
                End If

                db.SaveChanges()
                blnAppointmentSaved = True
            End Using

#Region "Order Message Send"
            'Send Order Message for Appointment cancellation - There are 2 sub types here
            Dim strOrderMessage As String = ""
            Dim blnOrderEventIdSendEnabled As Boolean = False
            Dim strLoggedInUserName As String = HttpContext.Current.Session("UserID")
            Dim OrderCommsBL As New OrderCommsBL
            Dim intOrderId As Integer = 0
            Dim intLoggedInUserId As Integer = CInt(Session("PKUserId"))
            Dim intCurrentAppointmentWaitListId As Integer


            If blnAppointmentSaved Then

                intOrderId = OrderCommsBL.GetOrderIdByAppointmentId(intCurrentWorkingAppointmentId)
                If intOrderId > 0 Then
                    intCurrentAppointmentWaitListId = OrderCommsBL.GetWaitingListIdByOrderId(intOrderId)

                    If chkReturnToWaitlist.Checked Then 'Cancel Appointment with sending back to Waitlist - Order Event Code 8
                        blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(8)
                        If blnOrderEventIdSendEnabled Then
                            strOrderMessage = "Appointment cancelled with sending to Waitlist by " + strLoggedInUserName + ". "
                            strOrderMessage = strOrderMessage + OrderCommsBL.GetOrderAppointmentMessageByAppointmentId(intCurrentWorkingAppointmentId)
                            OrderCommsBL.SendOrderMessageByOrderAndEventId(intOrderId, 8, Nothing, intCurrentAppointmentWaitListId, intCurrentWorkingAppointmentId, strOrderMessage, Nothing, intLoggedInUserId)

                        End If
                    Else 'Cancel appointment without Wait list - Order Event Code 9
                        blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(9)
                        If blnOrderEventIdSendEnabled Then
                            strOrderMessage = "Appointment cancelled without Waitlist by " + strLoggedInUserName + ". "
                            strOrderMessage = strOrderMessage + OrderCommsBL.GetOrderAppointmentMessageByAppointmentId(intCurrentWorkingAppointmentId)
                            OrderCommsBL.SendOrderMessageByOrderAndEventId(intOrderId, 9, Nothing, intCurrentAppointmentWaitListId, intCurrentWorkingAppointmentId, strOrderMessage, Nothing, intLoggedInUserId)
                        End If
                    End If
                End If

            End If

#End Region

            Utilities.SetNotificationStyle(RadNotification1, "Booking cancelled.", False)
            RadNotification1.Show()

            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "booking-cancelled", "closeRadWindow();", True)
            SelectRoomButton_Click(Nothing, New EventArgs)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured deleting patient appointment.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem deleting patient booking.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub ConfirmBlockSlotRadButton_Click(sender As Object, e As EventArgs)

    End Sub

    Protected Sub AppointmentsDataSource_Inserted(sender As Object, e As SqlDataSourceStatusEventArgs)
        SelectRoomButton_Click(Nothing, New EventArgs())
    End Sub

    Protected Sub PreviousDayLinkButton_Click(sender As Object, e As EventArgs)
        RadAjaxLoadingPanel1.Visible = True
        Try

            'SelectRoomButton_Click(Nothing, Nothing)
            Dim nextDate As DateTime
            If CalendarView = SchedulerViewType.DayView Then
                nextDate = CDate(DiaryRadScheduler.SelectedDate).AddDays(-1)
            ElseIf CalendarView = SchedulerViewType.WeekView Then
                nextDate = CDate(DiaryRadScheduler.SelectedDate).AddDays(-7)


            ElseIf CalendarView = SchedulerViewType.MonthView Then
                nextDate = CDate(DiaryOverviewRadScheduler.SelectedDate).AddMonths(-1)
            End If

            setDate(nextDate)
            SelectRoomButton_Click(Nothing, Nothing)
            'setRoom()
        Catch ex As Exception
            RadAjaxLoadingPanel1.Visible = False
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
        RadAjaxLoadingPanel1.Visible = False
    End Sub

    Protected Sub NextDayLinkButton_Click(sender As Object, e As EventArgs)
        RadAjaxLoadingPanel1.Visible = True
        Try
            'SelectRoomButton_Click(Nothing, Nothing)
            Dim nextDate As DateTime

            If CalendarView = SchedulerViewType.DayView Then
                nextDate = CDate(DiaryRadScheduler.SelectedDate).AddDays(1)
            ElseIf CalendarView = SchedulerViewType.WeekView Then
                nextDate = CDate(DiaryRadScheduler.SelectedDate).AddDays(7)
            ElseIf CalendarView = SchedulerViewType.MonthView Then
                nextDate = CDate(DiaryOverviewRadScheduler.SelectedDate).AddMonths(1)
            End If

            setDate(nextDate)
            SelectRoomButton_Click(Nothing, Nothing)
        Catch ex As Exception
            RadAjaxLoadingPanel1.Visible = False
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
        RadAjaxLoadingPanel1.Visible = False
    End Sub

    Protected Sub TodaysDateLinkButton_Click(sender As Object, e As EventArgs)
        RadAjaxLoadingPanel1.Visible = True
        Try
            'SelectRoomButton_Click(Nothing, Nothing)
            setDate(Now)
            SelectRoomButton_Click(Nothing, Nothing)
        Catch ex As Exception
            RadAjaxLoadingPanel1.Visible = False
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
        RadAjaxLoadingPanel1.Visible = False
    End Sub

    Private Sub setDate(selectedDate As DateTime)
        Select Case CalendarView
            Case SchedulerViewType.DayView
                DiaryRadScheduler.SelectedDate = selectedDate
                CalendarDateLabel.Text = selectedDate.ToString("dddd, dd MMM yyyy")
            Case SchedulerViewType.WeekView
                DiaryRadScheduler.SelectedDate = selectedDate
                Dim dow As Integer = selectedDate.DayOfWeek
                Dim startOfWeek = DateAdd(DateInterval.Day, -dow, selectedDate)
                Dim endOfWeek = DateAdd(DateInterval.Day, 6, startOfWeek)

                CalendarDateLabel.Text = startOfWeek.ToString("dd MMM yyyy") & " - " & endOfWeek.ToString("dd MMM yyyy")
            Case SchedulerViewType.MonthView
                Session("SchedulerSelectedDate") = selectedDate
                DiaryOverviewRadScheduler.SelectedDate = selectedDate
                CalendarDateLabel.Text = selectedDate.ToString("MMM yyyy")
        End Select
        DiaryDatePicker.SelectedDate = selectedDate
        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-selected-calendar-view", "setCalendarView('" & CalendarView.ToString.ToLower().Replace("view", "") & "');", True)
    End Sub

    Protected Sub DiaryDatePicker_SelectedDateChanged(sender As Object, e As Calendar.SelectedDateChangedEventArgs)
        Try
            CalendarView = SchedulerViewType.DayView
            'Session("CalendarView") = "day"
            setDate(e.NewDate)
            DiaryRadScheduler.Visible = True
            DiaryRadScheduler.EnableViewState = True
            DiaryRadScheduler.ViewStateMode = ViewStateMode.Enabled

            DiaryOverviewRadScheduler.Visible = False
            DiaryOverviewRadScheduler.EnableViewState = False

            loadDiary(e.NewDate)
            ZoomLevelLabel.Text = "100% zoom"

            SelectRoomButton_Click(Nothing, Nothing)
        Catch ex As Exception
            Dim errorMsg = "An error occured"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function slotAvailable(selectedDateTime As DateTime, diaryId As Integer, userId As Integer) As String
        Try
            Dim lockedByUser = ""

            Dim da As New DataAccess_Sch
            Dim dbRes = da.checkSlotAvailability(selectedDateTime, diaryId)
            If dbRes.Rows.Count > 0 Then
                Dim dr As DataRow = dbRes.Rows(0)
                Dim lockedByUserId = dr("StaffAccessedId")

                If Not lockedByUserId = userId Then
                    lockedByUser = dr("UserName")
                End If
            End If

            Return lockedByUser
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in ReleaseReservedSlots", ex)
            Throw ex
        End Try
    End Function

    Protected Sub DiaryRadScheduler_FormCreating(sender As Object, e As SchedulerFormCreatingEventArgs)
        'Dim slotStart = e.Appointment.Start
        'Dim roomId = e.Appointment.Resources.GetResourceByType("Room").[Key]
        'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "add-mode", "showAddEditListTemplate('" & slotStart.ToString("dd/MM/yyyy HH:mm") & "'," & roomId & ");", True)
        e.Cancel = True
    End Sub

    Protected Sub MonthViewLinkButton_Click(sender As Object, e As EventArgs)
        RadAjaxLoadingPanel1.Visible = True
        'Session("CalendarView") = "month"
        CalendarView = SchedulerViewType.MonthView

        DiaryRadScheduler.Visible = False
        DiaryRadScheduler.EnableViewState = False

        DiaryOverviewRadScheduler.Visible = True
        DiaryOverviewRadScheduler.EnableViewState = True

        setDate(DiaryRadScheduler.SelectedDate)

        loadOverView(DiaryRadScheduler.SelectedDate.Month, DiaryRadScheduler.SelectedDate.Month)
        SelectRoomButton_Click(Nothing, Nothing)
        RadAjaxLoadingPanel1.Visible = False

    End Sub

    Protected Sub DayViewLinkButton_Click(sender As Object, e As EventArgs)
        RadAjaxLoadingPanel1.Visible = True
        'Session("CalendarView") = "day"
        CalendarView = SchedulerViewType.DayView
        ZoomLevelLabel.Text = "100% zoom"

        DiaryRadScheduler.Visible = True
        DiaryRadScheduler.EnableViewState = True
        DiaryRadScheduler.ViewStateMode = ViewStateMode.Enabled

        DiaryOverviewRadScheduler.Visible = False
        DiaryOverviewRadScheduler.EnableViewState = False

        setDate(Now.Date)

        loadDiary(Now.Date)
        SelectRoomButton_Click(Nothing, Nothing)
        RadAjaxLoadingPanel1.Visible = False
    End Sub

    Protected Sub DiaryOverviewRadScheduler_AppointmentCreated(sender As Object, e As AppointmentCreatedEventArgs)
        Dim iDiaryId = CInt(e.Appointment.Attributes("diaryId"))
        Dim booked As Decimal = 0.0
        Dim totalPoints = e.Appointment.Attributes("slotPoints")

        If CBool(e.Appointment.Attributes("training")) Then
            e.Appointment.Subject += " (training)"
        End If

        booked = e.Appointment.Attributes("usedPoints")

        Dim deletedTemplate = e.Appointment.Attributes("Suppressed")

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

        e.Appointment.ToolTip = e.Appointment.Start.ToShortTimeString & "-" & e.Appointment.End.ToShortTimeString & vbCrLf & e.Appointment.Description.Replace("<br />", vbCrLf)
        If deletedTemplate = True Then
            e.Appointment.BackColor = Drawing.Color.FromName("#a1a0a0") 'empty

        Else
            If booked <= 0 Then
                e.Appointment.BackColor = Drawing.Color.FromName("#46a958") 'empty
            ElseIf booked >= totalPoints Then
                e.Appointment.BackColor = Drawing.Color.FromName("#d33a3a") 'full
            Else
                e.Appointment.BackColor = Drawing.Color.FromName("#d89f3b") 'used
            End If
        End If


        e.Appointment.Description = e.Appointment.Attributes("description")
    End Sub

    Protected Sub DiaryOverviewRadScheduler_AppointmentDataBound(sender As Object, e As SchedulerEventArgs)

        e.Appointment.Attributes.Add("Suppressed", CType(e.Appointment.DataItem, DataRowView).Row("Suppressed"))
        e.Appointment.Attributes.Add("roomId", CType(e.Appointment.DataItem, DataRowView).Row("RoomId"))
        e.Appointment.Attributes.Add("training", CType(e.Appointment.DataItem, DataRowView).Row("Training"))
        e.Appointment.Attributes.Add("diaryId", CType(e.Appointment.DataItem, DataRowView).Row("DiaryId"))
        e.Appointment.Attributes.Add("slotType", "OverviewSlot")
        e.Appointment.Attributes.Add("slotPoints", CType(e.Appointment.DataItem, DataRowView).Row("PointsAvailable"))
        e.Appointment.Attributes.Add("usedPoints", (CType(e.Appointment.DataItem, DataRowView).Row("AppointmentPoints") + CType(e.Appointment.DataItem, DataRowView).Row("BlockedPoints")))
        e.Appointment.Attributes.Add("description", CType(e.Appointment.DataItem, DataRowView).Row("Subject"))
        e.Appointment.CssClass = "overview-slot"

    End Sub


    Protected Sub DiaryOverviewRadScheduler_AppointmentContextMenuItemClicked(sender As Object, e As AppointmentContextMenuItemClickedEventArgs)
        Try
            If e.MenuItem.Value.ToLower = "gotodate" Then
                CalendarView = SchedulerViewType.DayView
                Session("BookedDate") = CDate(SelectedDateHiddenField.Value).Date
                DiaryRadScheduler.EnableViewState = True
                DiaryRadScheduler.Visible = True
                DiaryOverviewRadScheduler.EnableViewState = False
                DiaryOverviewRadScheduler.Visible = False
                setDate(Session("BookedDate"))
                loadDiary(Session("BookedDate"))
                SelectRoomButton_Click(Nothing, Nothing)
            ElseIf e.MenuItem.Value.ToLower = "undocancelledlist" Then
                Dim DiaryID = DiaryIdHiddenField.Value
                Dim Suppressed = False
                Try
                    Dim da As New DataAccess_Sch
                    da.Diary_Delete_Undo(DiaryID, Suppressed, 0, "", 0, False)
                    loadOverView(DiaryRadScheduler.SelectedDate.Month, DiaryRadScheduler.SelectedDate.Year)
                Catch ex As Exception
                    Dim errorLogRef As String
                    errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on undo patient appointment.", ex)
                    Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem on undo patient booking.")
                    RadNotification1.Show()
                End Try
            End If

            'SelectedRoomHiddenField.Value = RoomsDropdown.Items(0).Value
            'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-tab", "setRoomTabSelected(" & SelectedRoomId & ");", True)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error selecting date from month view", ex)
            Utilities.SetNotificationStyle(RadNotification1, "Unable to navigate to date. Please use day view and choose the date from the calendar instead.", True)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub DiaryOverviewRadScheduler_TimeSlotContextMenuItemClicked(sender As Object, e As TimeSlotContextMenuItemClickedEventArgs)
        Try
            If e.MenuItem.Value.ToLower = "gotodate" Then
                CalendarView = SchedulerViewType.DayView

                Session("BookedDate") = CDate(SelectedDateHiddenField.Value).Date
                DiaryRadScheduler.EnableViewState = True
                DiaryRadScheduler.Visible = True

                DiaryOverviewRadScheduler.EnableViewState = False
                DiaryOverviewRadScheduler.Visible = False

                setDate(Session("BookedDate"))

                loadDiary(Session("BookedDate"))
                SelectRoomButton_Click(Nothing, Nothing)
            End If

            'SelectedRoomHiddenField.Value = RoomsDropdown.Items(0).Value
            'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-tab", "setRoomTabSelected(" & SelectedRoomId & ");", True)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error selecting date from month view", ex)
            Utilities.SetNotificationStyle(RadNotification1, "Unable to navigate to date. Please use day view and choose the date from the calendar instead.", True)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub DiaryZoomRadSlider_ValueChanged(sender As Object, e As EventArgs)
        DiaryRadScheduler.Rebind()
    End Sub

    Protected Sub DiaryRadScheduler_AppointmentCreated(sender As Object, e As AppointmentCreatedEventArgs)
        If e.Appointment.Attributes("slotType").ToString.ToLower = "patientbooking" Then
            Dim patientNotes = e.Appointment.Attributes("bookingNotes")
            If Not String.IsNullOrWhiteSpace(patientNotes) Then
                Dim appointmentToolTipId = "AppointmentNotesToolTip"
                Dim appointmentToolTipImageId = "AppointmentNotesToolTipImage"

                CType(e.Container.FindControl(appointmentToolTipImageId), HtmlImage).Visible = True
                CType(e.Container.FindControl(appointmentToolTipId), RadToolTip).Text = patientNotes.Replace(vbCrLf, "<br/>")
                CType(e.Container.FindControl(appointmentToolTipId), RadToolTip).Visible = True
            End If

            Dim generalInfo = e.Appointment.Attributes("bookingInformation")
            If Not String.IsNullOrWhiteSpace(generalInfo) Then
                Dim infoToolTipId = "AppointmentGeneralInfoToolTip"
                Dim infoToolTipImageId = "AppointmentGeneralInfoToolTipImage"

                CType(e.Container.FindControl(infoToolTipImageId), HtmlImage).Visible = True
                CType(e.Container.FindControl(infoToolTipId), RadToolTip).Text = generalInfo.Replace(vbCrLf, "<br/>")
                CType(e.Container.FindControl(infoToolTipId), RadToolTip).Visible = True
            End If
        End If

        If (e.Appointment.Attributes("slotType").ToLower = "patientbooking" And Not CType(e.Appointment.Attributes("locked"), Boolean)) Or (e.Appointment.Attributes("slotType").ToLower = "freeslot") Then
            Dim tooltip As String = JustifyText(e.Appointment.Attributes("subject-tooltip"))
            Dim RadSubjectToolTip As RadToolTip = CType(e.Container.FindControl("RadSubjectToolTip"), RadToolTip) '
            'RadSubjectToolTip.RenderMode = RenderMode.Lightweight
            CType(e.Container.FindControl("RadSubjectToolTip"), RadToolTip).Text = tooltip.Replace(vbCrLf, "<br/>")
            CType(e.Container.FindControl("RadSubjectToolTip"), RadToolTip).Visible = True
        End If

    End Sub
    Public Function JustifyText(ByVal inputText As String, Optional ByVal maxLineLength As Integer = 90) As String
        Dim words As String() = inputText.Split(New Char() {" "c}, StringSplitOptions.RemoveEmptyEntries)
        Dim outputText As String = "", lineBuilder As String = ""
        Dim lineLength As Integer = 0
        For Each word As String In words
            If lineLength + word.Length + 1 > maxLineLength Then
                outputText = outputText & lineBuilder.Trim() & "<br/>"
                lineBuilder = ""
                lineLength = 0
            End If
            lineBuilder = lineBuilder & word & " "
            lineLength += word.Length + 1
        Next
        outputText = outputText & lineBuilder.Trim()
        Return outputText.Trim()
    End Function

    Protected Sub TrustDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
        PopulateFromTrust(TrustDropDownList.SelectedValue)
    End Sub

    Private Sub PopulateFromTrust(TrustId As Integer)
        HospitalDropDownList.DataSource = DataAdapter_Sch.GetSchedulerHospitals(TrustId)
        HospitalDropDownList.DataBind()
        HospitalDropDownList.SelectedIndex = 0

        'RoomsDropdown.DataSource = DataAdapter_Sch.GetAllRoomsForSelectedHospitals(HospitalDropDownList.SelectedValue) -- MH changed as below on 22 Feb 2024
        RoomsDropdown.DataSource = DataAdapter_Sch.GetSchedulerRooms(HospitalDropDownList.SelectedValue)
        RoomsDropdown.DataBind()

        'incase room is no longer part of the list of rooms
        If Not Session("WorklistRoomId") = Nothing AndAlso RoomsDropdown.Items.FindItemByValue(Session("WorklistRoomId")) IsNot Nothing Then
            RoomsDropdown.Items.FindItemByValue(Session("WorklistRoomId")).Checked = True
        Else
            RoomsDropdown.Items(0).Checked = True
        End If

        Dim selectedRooms As New List(Of Object)

        For Each itm As RadComboBoxItem In RoomsDropdown.Items.Take(3)

            Dim obj = New With {
                .RoomId = itm.Value,
                .RoomName = itm.Text
            }
            selectedRooms.Add(obj)
        Next


    End Sub

    Protected Sub lnkZoomIn_Click(sender As Object, e As EventArgs)
        Select Case DiaryRadScheduler.MinutesPerRow
            Case 10
                DiaryRadScheduler.MinutesPerRow = 5
                ZoomLevelLabel.Text = "150% zoom"
            Case 15
                DiaryRadScheduler.MinutesPerRow = 10
                ZoomLevelLabel.Text = "125% zoom"
            Case 30
                DiaryRadScheduler.MinutesPerRow = 15
                ZoomLevelLabel.Text = "100% zoom"
            Case 45
                DiaryRadScheduler.MinutesPerRow = 30
                ZoomLevelLabel.Text = "75% zoom"
            Case 60
                DiaryRadScheduler.MinutesPerRow = 45
                ZoomLevelLabel.Text = "50% zoom"
        End Select
        SelectRoomButton_Click(Nothing, Nothing)
    End Sub

    Protected Sub lnkZoomOut_Click(sender As Object, e As EventArgs)
        Select Case DiaryRadScheduler.MinutesPerRow
            Case 5
                DiaryRadScheduler.MinutesPerRow = 10
                ZoomLevelLabel.Text = "125% zoom"
            Case 10
                DiaryRadScheduler.MinutesPerRow = 15
                ZoomLevelLabel.Text = "100% zoom"
            Case 15
                DiaryRadScheduler.MinutesPerRow = 30
                ZoomLevelLabel.Text = "75% zoom"
            Case 30
                DiaryRadScheduler.MinutesPerRow = 45
                ZoomLevelLabel.Text = "50% zoom"
            Case 45
                DiaryRadScheduler.MinutesPerRow = 60
                ZoomLevelLabel.Text = "25% zoom"
        End Select
        SelectRoomButton_Click(Nothing, Nothing)

    End Sub


    Protected Sub DiaryZoomRadSlider_ValueChanged1(sender As Object, e As EventArgs)
        'DiaryRadScheduler.MinutesPerRow = DiaryZoomRadSlider.SelectedValue
        'SelectRoomButton_Click(Nothing, Nothing)

    End Sub
End Class