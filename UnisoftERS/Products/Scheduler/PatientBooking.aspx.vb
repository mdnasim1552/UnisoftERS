Imports System.Data.Entity.Core.Objects
Imports System.Net.Http
Imports DevExpress.CodeParser
Imports Hl7.Fhir.Model
Imports Newtonsoft.Json.Linq
Imports Telerik.Web.UI

Public Class PatientBooking
    Inherits PageBase

#Region "Web methods"
    <System.Web.Services.WebMethod()>
    Public Shared Function checkForBookingLetter(appointmentId As Integer) As Boolean

        Return False
    End Function
#End Region
#Region "Properties and Structures"
    Private Property PageSearchFields As Products_Scheduler.SearchFields
        Get
            If Session("SearchFields") IsNot Nothing Then
                Return CType(Session("SearchFields"), Products_Scheduler.SearchFields)
            Else
                Return Nothing
            End If
        End Get
        Set(value As Products_Scheduler.SearchFields)
            Session("SearchFields") = value
        End Set
    End Property
    Private _appointmentIdForLetterPrinting As Long
    Private Property AppointmentIdForLetterPrinting As Long
        Get
            Return _appointmentIdForLetterPrinting
        End Get
        Set(value As Long)
            _appointmentIdForLetterPrinting = value
        End Set
    End Property



    ReadOnly Property OperatingHospitalID As Integer
        Get
            Return CInt(Request.QueryString("HospitalId"))
        End Get
    End Property

    ReadOnly Property BookingDate As DateTime
        Get
            Return CDate(Request.QueryString("slotDate"))
        End Get
    End Property

    Public ReadOnly Property DiaryId As Integer
        Get
            Return CInt(Request.QueryString("diaryId"))
        End Get
    End Property

    ReadOnly Property AppointmentId As Integer
        Get
            Return CInt(Request.QueryString("appointmentId"))
        End Get
    End Property

    ReadOnly Property RoomId As Integer
        Get
            Return CInt(Request.QueryString("roomId"))
        End Get
    End Property

    ReadOnly Property SelectedProcedureTypeId As Integer
        Get
            Return CInt(Request.QueryString("procedureTypeId"))
        End Get
    End Property

    ReadOnly Property SlotPoints As Decimal
        Get
            Return CDec(Request.QueryString("slotPoints"))
        End Get
    End Property

    ReadOnly Property SlotDuration As Decimal
        Get
            If (Request.QueryString("slotLength") = "undefined") Then
                Return 0
            Else
                Return CInt(Request.QueryString("slotLength"))
            End If
        End Get
    End Property

    ReadOnly Property SelectedSlotId As Integer
        Get
            Return CInt(Request.QueryString("slotId"))
        End Get
    End Property

    ReadOnly Property ListSlotId As Integer
        Get
            Return CInt(Request.QueryString("listSlotId"))
        End Get
    End Property

    ReadOnly Property Action As String
        Get
            Return Request.QueryString("action").ToString()
        End Get
    End Property


    ReadOnly Property ReservedAppointmentId As Integer
        Get
            Return Session("ReservedAppointmentId")
        End Get
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.InitComplete
        If Not Page.IsPostBack Then
            DataAccess_Sch.ReleaseRedundantLockedSlots(DataAdapter.LoggedInUserId)
            bindControls()
            Session("ReservedAppointmentId") = 0
            If Action.ToLower = "edit" Then
                Page.Title = "Edit booking"
                SelectedRoomIdHiddenField.Value = RoomId
                fillForm(AppointmentId)
                reserveSlot(AppointmentId)
                PatientSearchDiv.Style.Item("display") = "none"
                BookingDiv.Style.Remove("display")
            ElseIf Action.ToLower = "add" Then
                Page.Title = "Add new booking"
                BookingFirstOfferDate.SelectedDate = BookingDate
                SelectedRoomIdHiddenField.Value = RoomId
                Session("SearchFields") = Nothing
            ElseIf Action.ToLower = "search" Then
                Page.Title = "Add new booking"
                BookingFirstOfferDate.SelectedDate = BookingDate
                SelectedRoomIdHiddenField.Value = RoomId
            ElseIf Action.ToLower = "waitlist" Then
                Page.Title = "Add new booking"
                SelectedRoomIdHiddenField.Value = RoomId
                BookingFirstOfferDate.SelectedDate = BookingDate
                PatientSearchDiv.Style.Item("display") = "none"
                BookingDiv.Style.Remove("display")
                populateControls()
                reserveSlot(0)
                If Session("WaitlistId") IsNot Nothing Then populatePatientFromWaitlist(Session("WaitlistID"))
            ElseIf Action.ToLower = "move" Then
                Page.Title = "Move booking"
                BookingFirstOfferDate.SelectedDate = BookingDate
                PatientSearchDiv.Style.Item("display") = "none"
                BookingDiv.Style.Remove("display")
                If Session("AppointmentId") IsNot Nothing Then
                    populateControls()
                    fillForm(Session("AppointmentId"))

                    reserveSlot(Session("AppointmentId"))
                    reserveSlot(0)
                End If
            ElseIf Action.ToLower = "paste" Then
                Page.Title = "Paste booking"
                SelectedRoomIdHiddenField.Value = RoomId
                BookingFirstOfferDate.SelectedDate = BookingDate
                PatientSearchDiv.Style.Item("display") = "none"
                BookingDiv.Style.Remove("display")
                If Session("AppointmentId") IsNot Nothing Then


                    populateControls()
                    fillForm(Session("AppointmentId"))
                    reserveSlot(0)
                End If
            End If

            HealthServiceNameIdTd.InnerText = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " Number:"

        End If
    End Sub

    Private Sub reserveSlot(reservedAppointmentId)
        Try
            'Mahfuz added/changed on 06 July 2021 - D&G wants only save patient when finalizing
            'If SCIStore D&G Webservice enabled then above patientId will be SCIStorePatientID not SE Local DB PatientID
            Dim intSELocalPatientId = 0
            Dim intSCIStorePatientId = 0

            If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
                Dim ScotHosWSBL As ScotHospitalWebServiceBL = New ScotHospitalWebServiceBL

                ScotHosWSBL.ConnectWebservice()
                'Call GetPatients method
                intSELocalPatientId = ScotHosWSBL.ImportPatientsIntoDatabaseBySCIStorePatientID(PatientIDHiddenField.Value)
                'Logout
                ScotHosWSBL.DisconnectService()
            Else
                intSELocalPatientId = PatientIDHiddenField.Value
            End If

            'Session("ReservedAppointmentId") = DataAdapter_Sch.reserveSlot(BookingDate, SlotDuration, SelectedSlotId, DiaryId, RoomId, OperatingHospitalID, If(AppointmentId = 0, PatientIDHiddenField.Value, 0), reservedAppointmentId)
            'Mahfuz changed as below on 06 July 2021
            Session("ReservedAppointmentId") = DataAdapter_Sch.reserveSlot(BookingDate, SlotDuration, SelectedSlotId, DiaryId, RoomId, OperatingHospitalID, If(AppointmentId = 0, intSELocalPatientId, 0), reservedAppointmentId)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error reserving booking slot", ex)
        End Try
    End Sub

    Private Sub bindControls()
        PatientBookingProceduresRepeater.DataSource = DataAdapter_Sch.GetProcedureTypes(True)
        PatientBookingProceduresRepeater.DataBind()
    End Sub

    Private Sub populatePatientFromWaitlist(waitlistId As Integer)
        Dim waitlist = DataAdapter_Sch.GetWaitlistDetails(waitlistId)

        If waitlist IsNot Nothing AndAlso waitlist.Rows.Count > 0 Then
            Dim dr = waitlist.Rows(0)

            BookingReferralDate.SelectedDate = CDate(dr("DateRaised"))

            'Patient Details
            PatientIDHiddenField.Value = dr("PatientId")
            PatientNameLabel.Text = dr("Forename1") + " " + dr("Surname")
            If Not String.IsNullOrWhiteSpace(dr("DateOfBirth")) Then
                PatientDOBLabel.Text = CDate(dr("DateOfBirth")).ToShortDateString
            End If

            PatientCaseNoteLabel.Text = dr("HospitalNumber")
            PatientNHSNoLabel.Text = dr("NHSNo")
            PatientGenderLabel.Text = dr("Gender").ToString()
        End If
    End Sub

    Private Sub populateControls()
        Try
            Dim diaryDetails = DataAdapter_Sch.GetDiaryDetails(DiaryId)
            Dim recordMatch As Boolean
            Dim procedureTypeId As Integer
            Dim slotRunningTotalHiddenFieldFlag = False
            Dim bookingTotalLength = 0
            Dim bookingTotalPoints = 0.0
            Dim multipleSlotsFlag = False
            Dim trainingFlag = False
            Dim nonGIFlag = False
            Dim diagSlotsList As New List(Of Integer)
            Dim theraSlotsList As New List(Of Integer)
            Dim diagMinutes = 0
            Dim theraMinutes = 0

            If Not diaryDetails.Rows(0).IsNull("ListGender") Then
                Dim listGender = diaryDetails.Rows(0)("ListGender")
                Select Case listGender.ToString.ToLower
                    Case "male"
                        Session("DiaryGenderType") = "Male"
                    Case "female"
                        Session("DiaryGenderType") = "Female"
                    Case Else
                        Session("DiaryGenderType") = ""
                End Select
            Else
                Session("DiaryGenderType") = ""
            End If

            If PageSearchFields.ProcedureTypes Is Nothing Then
                Session("SearchProcedureTypes") = Nothing
            End If

            'Session variable to keep track of procedure types selected
            'from the "Find Available Slot" route
            Dim searchProcedureTypes = IIf(Session("SearchProcedureTypes") Is Nothing, False, True)
            Dim findAvailableSlotRoute As Boolean
            Dim directlyFromCalendarRoute As Boolean

            If searchProcedureTypes Then
                'Coming from "Find Available Slot" or "Waiting List" route
                findAvailableSlotRoute = True
                directlyFromCalendarRoute = False
            Else
                'Coming from "Directly From Calendar" route
                findAvailableSlotRoute = False
                directlyFromCalendarRoute = True
            End If

            If diaryDetails.Rows(0)("GIProcedure") Then
                GIProceduresDiv.Visible = True
                NonGIProceduresDiv.Visible = False
                For Each itm As RepeaterItem In PatientBookingProceduresRepeater.Items
                    procedureTypeId = CType(itm.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value

                    If directlyFromCalendarRoute Then
                        If procedureTypeId = SelectedProcedureTypeId Then
                            'get procedure points and minutes
                            If SlotPoints >= 0 Then CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox).Value = SlotPoints Else CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox).Value = 0
                            If SlotDuration >= 0 Then CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox).Value = SlotDuration Else CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox).Value = 0

                            CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox).Enabled = True
                            CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox).Enabled = True

                            If CType(itm.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Visible Then
                                CType(itm.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Checked = True
                            ElseIf CType(itm.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Visible Then
                                CType(itm.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = True
                                CType(itm.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = True
                            End If

                            If Not String.IsNullOrEmpty(CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox).Value.ToString) Then bookingTotalLength += CInt(CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox).Value)
                            If Not String.IsNullOrEmpty(CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox).Value.ToString) Then bookingTotalPoints += CDec(CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox).Value)

                        End If
                    ElseIf findAvailableSlotRoute Then
                        If Not IsNothing(Session("SearchProcedureTypes_" & procedureTypeId)) Then
                            If PageSearchFields.ProcedureTypes.Any(Function(x) x.ProcedureTypeID = Session("SearchProcedureTypes_" & procedureTypeId)) Then
                                Dim searchProcedure = PageSearchFields.ProcedureTypes.Where(Function(x) x.ProcedureTypeID = Session("SearchProcedureTypes_" & procedureTypeId)).FirstOrDefault

                                'check the relevant checkboxes (diagnostic or thereaputic)
                                CType(itm.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Checked = searchProcedure.Diagnostic
                                CType(itm.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = searchProcedure.Therapeutic
                                CType(itm.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = searchProcedure.Therapeutic

                                CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox).Enabled = True
                                CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox).Enabled = True

                                'set points and minutes text boxes
                                If procedureTypeId = SelectedProcedureTypeId Then
                                    'Set points/minutes from template values
                                    If SlotPoints > 0 Then CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox).Value = SlotPoints
                                    If SlotDuration > 0 Then CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox).Value = SlotDuration
                                Else
                                    'set points/minutes from default configuration
                                    Dim procedureLengths = DataAdapter_Sch.ProcedureMinutesDiagAndThera(procedureTypeId, CInt(diaryDetails.Rows(0)("OperatingHospitalID")), CBool(diaryDetails.Rows(0)("Training")), False) 'TODO: Figure out if this is a training list

                                    If searchProcedure.Diagnostic Then
                                        CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox).Value = If(procedureLengths.Rows.Count > 0, CDec(procedureLengths.Rows(0)("DiagnosticPoints")), 1)
                                        CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox).Value = If(procedureLengths.Rows.Count > 0, CInt(procedureLengths.Rows(0)("DiagnosticMinutes")), 15)
                                    Else
                                        CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox).Value = If(procedureLengths.Rows.Count > 0, CDec(procedureLengths.Rows(0)("TherapeuticPoints")), 1)
                                        CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox).Value = If(procedureLengths.Rows.Count > 0, CInt(procedureLengths.Rows(0)("TherapeuticMinutes")), 15)
                                    End If
                                End If
                            End If
                        End If
                    End If


                    Session("SearchProcedureTypes_" & procedureTypeId) = Nothing

                Next itm

                Session("SearchProcedureTypes") = Nothing

                Dim das = New DataAccess_Sch()
                Dim dtGetRoom As DataTable

                dtGetRoom = das.GetProcedureTypeAvailability(IIf(SelectedRoomIdHiddenField.Value = "", 0, SelectedRoomIdHiddenField.Value),
                                                             diaryDetails.Rows(0)("EndoscopistId"))

                For Each item As RepeaterItem In PatientBookingProceduresRepeater.Items
                    recordMatch = False
                    procedureTypeId = CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value
                    Dim DefineTherapeuticProcedureButton = CType(item.FindControl("DefineTherapeuticProcedureButton"), Button)
                    DefineTherapeuticProcedureButton.Attributes.Add("data-endoscopist-id", diaryDetails.Rows(0)("EndoscopistId"))

                    If dtGetRoom.Rows.Count > 0 Then
                        For Each row As DataRow In dtGetRoom.Rows
                            'Find matching row with the current control you are looping through
                            If row.Item("ProcedureTypeId") = procedureTypeId Then
                                'If the procedure is allowed in this room
                                If row.Item("RoomProcId") > 0 AndAlso (row.Item("SchedulerDiagnostic") Or row.Item("SchedulerTherapeutic")) Then
                                    CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Enabled = row.Item("SchedulerDiagnostic")
                                    CType(item.FindControl("DiagnosticProcedureTypesCheckBoxLabel"), WebControls.Label).ForeColor =
                                        IIf(row.Item("SchedulerDiagnostic"), System.Drawing.Color.Black, System.Drawing.Color.LightGray)
                                    CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Enabled = row.Item("SchedulerTherapeutic")
                                    CType(item.FindControl("TherapeuticProcedureTypesCheckBoxLabel"), WebControls.Label).ForeColor =
                                        IIf(row.Item("SchedulerTherapeutic"), System.Drawing.Color.Black, System.Drawing.Color.LightGray)
                                    recordMatch = True
                                End If
                            End If
                        Next row
                        If Not recordMatch Then
                            CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Enabled = False
                            CType(item.FindControl("DiagnosticProcedureTypesCheckBoxLabel"), WebControls.Label).ForeColor = System.Drawing.Color.LightGray
                            CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Enabled = False
                            CType(item.FindControl("TherapeuticProcedureTypesCheckBoxLabel"), WebControls.Label).ForeColor = System.Drawing.Color.LightGray
                        End If
                    End If
                Next item
            Else
                'non-gi procedures
                Dim nonGIProcedureId As Integer
                If SelectedProcedureTypeId = 0 Then
                    nonGIProcedureId = PageSearchFields.ProcedureTypes.Where(Function(x) Not x.ProcedureTypeID = 0).FirstOrDefault.ProcedureTypeID
                Else
                    nonGIProcedureId = SelectedProcedureTypeId
                End If

                ProcedureTypeHiddenField.Value = nonGIProcedureId

                Dim procedureTypeName = DataAdapter_Sch.GetProcedureTypeName(nonGIProcedureId)
                NonGIProcedureLabel.Text = If(procedureTypeName, "")
                GIProceduresDiv.Visible = False
                NonGIProceduresDiv.Visible = True
                nonGIFlag = True
                BookingLengthRadNumericTextBox.Value = SlotDuration
                BookingPointsRadNumericTextBox.Value = SlotPoints

                bookingTotalLength = SlotDuration
                bookingTotalPoints = SlotPoints

                Dim procedureType = String.Empty
                If PageSearchFields.NonGIDiagnostic Then
                    procedureType = "diagnostic"
                ElseIf PageSearchFields.NonGITherapeutic Then
                    procedureType = "therapeutic"
                End If

                If Not String.IsNullOrEmpty(procedureType) Then
                    NonGIProcedureTypeRadioButtonList.SelectedValue = procedureType
                End If

                getNonGIDiaryDetails(PageSearchFields.NonGIDiagnostic, PageSearchFields.NonGITherapeutic)
            End If

            'Slot status
            PatientBookingSlotStatusRadioButtons.SelectedValue = SelectedSlotId

            'Slot length
            BookingSlotLengthRadNumericTextBox.Text = SlotDuration
            BookingSlotPointsRadNumericTextBox.Text = SlotPoints

            'Schedule Details
            ScheduleDetailsLabel.Text = BookingDate.ToString("dddd dd MMM yyyy") & " at " & BookingDate.ToString("HH:mm")
            BookingFirstOfferDate.SelectedDate = CDate(BookingDate)
            CallInTimeRadTimePicker.SelectedTime = BookingDate.TimeOfDay.Add(-DataAdapter_Sch.GetProcedureCallInTime(SelectedProcedureTypeId, OperatingHospitalID))
            StartTimeRadTimePicker.SelectedTime = BookingDate.TimeOfDay

            'Endoscopist
            If Not String.IsNullOrWhiteSpace(diaryDetails.Rows(0)("EndoscopistName")) Then
                PatientEndoscopistLabel.Text = diaryDetails.Rows(0)("EndoscopistName").ToString()
                PatientEndoscopistHiddenField.Value = diaryDetails.Rows(0)("EndoscopistId").ToString()
            End If

            'List consultant
            If Not String.IsNullOrWhiteSpace(diaryDetails.Rows(0)("ListConsultantName")) Then
                PatientListConsultantLabel.Text = diaryDetails.Rows(0)("ListConsultantName").ToString()
                PatientListConsultantHiddenField.Value = diaryDetails.Rows(0)("ListConsultantId").ToString()
            End If

            'check appointment is still available
            Dim selectedBookingDate = CDate(BookingFirstOfferDate.SelectedDate).ToShortDateString
            Dim selectedBookingTime = BookingDate.ToShortTimeString ' CDate(Convert.ToDecimal(StartTimeRadNumericTextBox.Value.ToString()).ToString("N2").Replace(".", ":")).ToShortTimeString
            Dim bookingDateTime = CDate(selectedBookingDate & " " & selectedBookingTime.ToString)
            Dim bookingEndDateTime = bookingDateTime.AddMinutes(BookingSlotLengthRadNumericTextBox.Value)

            'letter printing
            'enable/diable letter print options depending on result
            Dim letterTemplate = DataAdapter_Sch.GetLetterTemplate(1, OperatingHospitalID)
            If letterTemplate Is Nothing OrElse letterTemplate.Rows.Count = 0 Then
                RadioButtonLetterPrintList.Enabled = False
                NotTemplateFoundLabel.Visible = True
            Else
                RadioButtonLetterPrintList.Enabled = True
                NotTemplateFoundLabel.Visible = False
            End If

            Dim isValid = True
            Dim dtExistingAppointments = DataAdapter_Sch.getExistingAppointments(DiaryId, bookingDateTime, bookingEndDateTime)
            If dtExistingAppointments.Rows.Count > 0 Then
                For Each dr In dtExistingAppointments.Rows
                    If dr("AppointmentId") = ReservedAppointmentId Then Continue For

                    Dim existingStart = DateTime.Parse(dr("StartDateTime"))
                    Dim existingEnd = DateTime.Parse(dr("EndDateTime"))

                    'still might be allowed as this one might start as this one ends or ends as this one starts... (SQL between clause isnt great with these things)
                    If Not bookingDateTime = existingEnd And Not bookingEndDateTime = existingStart Then
                        isValid = False
                    End If
                Next
            End If

            If Not isValid Then
                Utilities.SetNotificationStyle(BookingErrorRadNotification, "This booking slot is no longer available and has been filled with another appointment.", True, "Please correct")
                BookingErrorRadNotification.Show()
                Exit Sub
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading controls", ex)
            Utilities.SetErrorNotificationStyle(BookingErrorRadNotification, ref, "There was an error loading the page")
            BookingErrorRadNotification.Show()
        End Try
    End Sub

    Private Sub getNonGIDiaryDetails(diagnostic, therapeutic)
        Try
            Using db As New ERS.Data.GastroDbEntities

                Dim diaryDetails = (From d In db.ERS_SCH_DiaryPages
                                    Join r In db.ERS_SCH_ListRules On d.ListRulesId Equals r.ListRulesId
                                    From p In db.ERS_SCH_PointMappings.Where(Function(x) x.ProceduretypeId = SelectedProcedureTypeId And x.NonGI = True And x.Training = False And x.OperatingHospitalId = d.OperatingHospitalId).DefaultIfEmpty
                                    Where d.DiaryId = DiaryId And p.NonGI = True And p.Training = False
                                    Select p.Minutes, r.NonGIDiagnosticProcedurePoints, r.NonGITherapeuticProcedurePoints, r.NonGIDiagnosticCallInTime, r.NonGITherapeuticCallInTime).FirstOrDefault

                Dim procedureMinutes = 0
                Dim callInTime = 0

                If diagnostic Then
                    BookingSlotLengthRadNumericTextBox.Value = diaryDetails.Minutes
                    CallInTimeRadTimePicker.SelectedTime = BookingDate.AddHours(-diaryDetails.NonGIDiagnosticCallInTime).TimeOfDay
                ElseIf therapeutic Then
                    BookingSlotLengthRadNumericTextBox.Value = diaryDetails.Minutes
                    callInTime = diaryDetails.NonGIDiagnosticCallInTime
                Else
                    Dim defaultProcedureSettings = (From p In db.ERS_SCH_PointMappings
                                                    Where p.ProceduretypeId = 0 And p.NonGI = True And p.Training = 0 And p.OperatingHospitalId = OperatingHospitalID
                                                    Select p.Points, p.Minutes).FirstOrDefault

                    procedureMinutes = defaultProcedureSettings.Minutes
                    CallInTimeRadTimePicker.SelectedTime = BookingDate.AddHours(-15).TimeOfDay

                End If
            End Using
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading controls", ex)
            Utilities.SetErrorNotificationStyle(BookingErrorRadNotification, ref, "There was an error loading the page")
            BookingErrorRadNotification.Show()
        End Try
    End Sub

    Private Sub fillForm(appoinmentId As Integer)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appoinmentId).FirstOrDefault

                If appointment IsNot Nothing Then
                    Dim appointmentProcedure = db.ERS_AppointmentProcedureTypes.Where(Function(x) x.AppointmentID = appointment.AppointmentId)
                    Dim bookingTherapeutics = (From at In db.ERS_AppointmentTherapeutics
                                               Join tt In db.ERS_TherapeuticTypes On at.TherapeuticTypeID Equals tt.Id
                                               Where at.AppointmentID = appointment.AppointmentId)

                    'get diary id and check if its a GI or Non-GI procedure
                    Dim diaryDetails = DataAdapter_Sch.GetDiaryDetails(DiaryId)

                    Dim das = New DataAccess_Sch()
                    Dim dtGetRoom As DataTable
                    Dim recordMatch As Boolean

                    If Action.ToLower = "paste" Then 'then we want to check availability about the lists endoscopist
                        dtGetRoom = das.GetProcedureTypeAvailability(IIf(SelectedRoomIdHiddenField.Value = "", 0, SelectedRoomIdHiddenField.Value),
                                                                         diaryDetails.Rows(0)("EndoscopistId"))
                    Else
                        dtGetRoom = das.GetProcedureTypeAvailability(IIf(SelectedRoomIdHiddenField.Value = "", 0, SelectedRoomIdHiddenField.Value),
                                                                        appointment.EndoscopistId)
                    End If

                    If diaryDetails.Rows(0)("GIProcedure") Then

                        'procedure types with therapeutics (if any)
                        For Each itm As RepeaterItem In PatientBookingProceduresRepeater.Items
                            Dim procedureTypeId = CType(itm.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value
                            Dim chkDiagnosticProcedure = CType(itm.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox)
                            Dim chkTherapeuticProcedure = CType(itm.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox)
                            Dim btnDefineTherapeutic = CType(itm.FindControl("DefineTherapeuticProcedureButton"), Button)
                            Dim procedurePoints = CType(itm.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox)
                            Dim procedureMinutes = CType(itm.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox)


                            btnDefineTherapeutic.Attributes.Add("data-endoscopist-id", diaryDetails(0)("EndoscopistId"))

                            Dim bookingProcedureType = appointmentProcedure.Where(Function(x) x.ProcedureTypeID = procedureTypeId).FirstOrDefault

                            If bookingProcedureType IsNot Nothing Then
                                chkDiagnosticProcedure.Checked = True
                                procedurePoints.Value = bookingProcedureType.Points
                                procedureMinutes.Value = bookingProcedureType.Minutes

                                If bookingProcedureType.IsTherapeutic Then
                                    chkDiagnosticProcedure.Checked = False
                                    chkTherapeuticProcedure.Checked = True
                                    btnDefineTherapeutic.Enabled = True

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

                                        Case ProcedureType.Antegrade, ProcedureType.Retrograde
                                            Session("SearchTherapeuticTypes_" & bookingProcedureType.ProcedureTypeID) = bookingTherapeutics.Where(Function(x) x.tt.Antegrade = True).Select(Function(x) x.at.TherapeuticTypeID).ToList()
                                    End Select

                                End If


                                'check procedure rules against the room and endoscopist before continuing is this is a pastnig booking function
                                If Action.ToLower = "paste" Then
                                    If Not dtGetRoom.AsEnumerable.Any(Function(x) x("ProcedureTypeId") = bookingProcedureType.ProcedureTypeID And x("RoomProcId") > 0) Then
                                        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-window", "alert('This appointment has procedure(s) that cannot be pasted to this list.'); CloseAndRebind();", True)
                                        Exit Sub
                                    End If
                                End If

                                For Each item As RepeaterItem In PatientBookingProceduresRepeater.Items
                                    recordMatch = False
                                    procedureTypeId = CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value

                                    If dtGetRoom.Rows.Count > 0 Then
                                        For Each row As DataRow In dtGetRoom.Rows
                                            'Find matching row with the current control you are looping through
                                            If row.Item("ProcedureTypeId") = procedureTypeId Then
                                                'If the procedure is allowed in this room
                                                If row.Item("RoomProcId") > 0 And (row.Item("SchedulerDiagnostic") Or row.Item("SchedulerTherapeutic")) Then
                                                    CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Enabled = row.Item("SchedulerDiagnostic")
                                                    CType(item.FindControl("DiagnosticProcedureTypesCheckBoxLabel"), WebControls.Label).ForeColor =
                                            IIf(row.Item("SchedulerDiagnostic"), System.Drawing.Color.Black, System.Drawing.Color.LightGray)
                                                    CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Enabled = row.Item("SchedulerTherapeutic")
                                                    CType(item.FindControl("TherapeuticProcedureTypesCheckBoxLabel"), WebControls.Label).ForeColor =
                                            IIf(row.Item("SchedulerTherapeutic"), System.Drawing.Color.Black, System.Drawing.Color.LightGray)
                                                    recordMatch = True
                                                End If
                                            End If
                                        Next row
                                        If Not recordMatch Then
                                            CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Enabled = False
                                            CType(item.FindControl("DiagnosticProcedureTypesCheckBoxLabel"), WebControls.Label).ForeColor = System.Drawing.Color.LightGray
                                            CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Enabled = False
                                            CType(item.FindControl("TherapeuticProcedureTypesCheckBoxLabel"), WebControls.Label).ForeColor = System.Drawing.Color.LightGray
                                        End If
                                    End If
                                Next item

                            Else
                                chkDiagnosticProcedure.Checked = False
                                procedurePoints.Text = ""
                                procedureMinutes.Text = ""

                                chkTherapeuticProcedure.Checked = False
                                btnDefineTherapeutic.Enabled = False
                            End If

                            If Action.ToLower = "move" Then 'remove the ability to change procedure type. This has been set previously, we just want to choose another date
                                chkDiagnosticProcedure.Enabled = False
                                chkTherapeuticProcedure.Enabled = False
                                btnDefineTherapeutic.Enabled = False
                            End If
                        Next
                    Else
                        'non-gi procedures
                        ProcedureTypeHiddenField.Value = appointmentProcedure.FirstOrDefault.ProcedureTypeID
                        Dim procedureTypeName = DataAdapter_Sch.GetProcedureTypeName(appointmentProcedure.FirstOrDefault.ProcedureTypeID)
                        NonGIProcedureLabel.Text = If(procedureTypeName, "")
                        GIProceduresDiv.Visible = False
                        NonGIProceduresDiv.Visible = True

                        BookingLengthRadNumericTextBox.Value = SlotDuration
                        BookingPointsRadNumericTextBox.Value = SlotPoints
                    End If

                    'booking status
                    If appointment.AppointmentStatusId > 0 Then PatientBookedStatusRadioButtons.SelectedValue = db.ERS_AppointmentStatus.Where(Function(x) x.UniqueId = appointment.AppointmentStatusId).FirstOrDefault.HDCKEY

                    'slot status
                    PatientBookingSlotStatusRadioButtons.SelectedValue = appointment.SlotStatusID

                    'patient details
                    Dim da As New DataAccess
                    Dim patientDT = da.GetPatientById(appointment.PatientId)

                    Dim patientDetails = (From dr In patientDT.Rows
                                          Select Forename = dr("Forename1").ToString(),
                                             Surname = dr("Surname").ToString(),
                                             NHSNo = dr("NHSNo").ToString(),
                                             DOB = dr("DateOfBirth"),
                                             CNN = dr("HospitalNumber"),
                                             Gender = dr("Gender").ToString()).FirstOrDefault()

                    With patientDetails
                        PatientNameLabel.Text = .Forename & " " & .Surname
                        PatientDOBLabel.Text = CDate(.DOB).ToShortDateString()
                        If Not IsDBNull(.CNN) Then
                            PatientCaseNoteLabel.Text = .CNN
                        Else
                            PatientCaseNoteLabel.Text = ""
                        End If
                        If Not IsDBNull(.NHSNo) Then
                            PatientNHSNoLabel.Text = Utilities.FormatHealthServiceNumber(.NHSNo)
                        Else
                            PatientNHSNoLabel.Text = ""
                        End If

                        PatientGenderLabel.Text = .Gender
                    End With
                    PatientIDHiddenField.Value = appointment.PatientId

                    'consultant/endoscopist
                    If appointment.EndoscopistId > 0 Then
                        Dim endoscopistName = db.ERS_Users.Where(Function(x) x.UserID = appointment.EndoscopistId).FirstOrDefault
                        If endoscopistName IsNot Nothing Then
                            PatientEndoscopistLabel.Text = endoscopistName.Title + " " + endoscopistName.Forename + " " + endoscopistName.Surname
                            PatientEndoscopistHiddenField.Value = appointment.EndoscopistId
                        End If
                    End If


                    BookingReferralDate.SelectedDate = appointment.ReferralDate
                    BookingSlotLengthRadNumericTextBox.Value = appointment.AppointmentDuration
                    If Not Action.ToLower = "paste" And Not Action.ToLower = "move" Then 'the following dates and times need to stay the same for pasted booking. 
                        'dates
                        ScheduleDetailsLabel.Text = appointment.StartDateTime.ToString("dddd dd MMM yyyy") & " at " & appointment.StartDateTime.ToString("HH:mm")
                        BookingFirstOfferDate.SelectedDate = appointment.StartDateTime

                        'times
                        CallInTimeRadTimePicker.SelectedTime = appointment.DueArrivalTime.Value.TimeOfDay
                        StartTimeRadTimePicker.SelectedTime = appointment.StartDateTime.TimeOfDay
                    End If

                    'notes/info
                    PatientAlertNotesTextBox.Text = appointment.Notes
                    PatientGeneralInfoNotesTextBox.Text = appointment.GeneralInformation

                    BookingSlotPointsRadNumericTextBox.Value = SlotPoints


                End If
            End Using
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred on list schedules page loading appointment data.", ex)
            Utilities.SetErrorNotificationStyle(BookingErrorRadNotification, errorLogRef, "There is a problem loading your data.")
            BookingErrorRadNotification.Show()
        End Try
    End Sub


    Protected Sub RadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Try
            If e.CommandName = "bookpatient" Then
                'check for bookings if present show notification but still load details but set to display none till yes clicked in notification box.
                'make sure its clientside and button is not postback so details aren't removed

                PatientSearchDiv.Style.Item("display") = "none"
                BookingDiv.Style.Remove("display")

                If PageSearchFields.ReferalDate.HasValue Then
                    BookingReferralDate.SelectedDate = PageSearchFields.ReferalDate

                    'Patient Slot Status
                    'If PageSearchFields.Slots.Count = 1 Then PatientBookingSlotStatusRadioButtons.Items.FindByValue(PageSearchFields.Slots(0)).Selected = True
                Else
                    BookingReferralDate.SelectedDate = Now
                End If

                'Patient Details
                PatientIDHiddenField.Value = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("PatientId")
                Dim RetrivedFrom = Session("PatientBookingSearchSource")
                If (RetrivedFrom = Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI Or
                        RetrivedFrom = Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI) Then
                    PatientIDHiddenField.Value = ImportPatientAndGetPatientId(e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("PatientId"), e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("NHSNo"), RetrivedFrom)
                End If
                PatientNameLabel.Text = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("Forename1") + " " + e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("Surname")
                    If Not String.IsNullOrWhiteSpace(e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DateOfBirth")) Then
                        PatientDOBLabel.Text = CDate(e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DateOfBirth")).ToShortDateString
                    End If
                    PatientCaseNoteLabel.Text = "" + e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("HospitalNumber")

                    'Fix on 10 Jun 2022 - TFS 2168
                    If IsDBNull(e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("NHSNo")) Then
                        PatientNHSNoLabel.Text = ""
                    Else
                        PatientNHSNoLabel.Text = "" + Utilities.FormatHealthServiceNumber(e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("NHSNo"))
                    End If

                    HealthServiceNameIdBookingTd.InnerText = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " No:"

                    PatientGenderLabel.Text = "" + e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("Gender").ToString()

                    bindControls()
                    populateControls()
                    reserveSlot(0)

                    If Action.ToLower = "add" Then
                        resetTherapeutics()
                    End If

                End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred on list schedules page.", ex)
            Utilities.SetErrorNotificationStyle(BookingErrorRadNotification, errorLogRef, "There is a problem searching for your data.")
            BookingErrorRadNotification.Show()
        End Try
    End Sub

    Protected Sub bindBookingRepeater()
        If PageSearchFields.ProcedureTypes IsNot Nothing AndAlso PageSearchFields.ProcedureTypes.Count > 0 Then
            For Each item As RepeaterItem In PatientBookingProceduresRepeater.Items
                Dim procTypeID = CInt(CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value)
                Dim currentProc = PageSearchFields.ProcedureTypes.Where(Function(x) x.ProcedureTypeID = procTypeID).FirstOrDefault
                If currentProc.ProcedureTypeID > 0 Then
                    CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Checked = currentProc.Diagnostic
                    CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = currentProc.Therapeutic
                    CType(item.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = currentProc.Therapeutic
                End If
            Next
        End If
    End Sub

#Region "Search Patient/Add Booking"
    Protected Sub PatientSearchResultsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Try
            If e.CommandName = "bookpatient" Then
                'check for bookings if present show notification but still load details but set to display none till yes clicked in notification box.
                'make sure its clientside and button is not postback so details aren't removed

                PatientSearchDiv.Style.Item("display") = "none"
                BookingDiv.Style.Remove("display")

                If PageSearchFields.ReferalDate.HasValue Then
                    BookingReferralDate.SelectedDate = PageSearchFields.ReferalDate

                    'Patient Slot Status
                    If PageSearchFields.Slots.Count = 1 Then PatientBookingSlotStatusRadioButtons.Items.FindByValue(PageSearchFields.Slots(0)).Selected = True
                Else
                    BookingReferralDate.SelectedDate = Now
                End If

                'Patient Details
                PatientIDHiddenField.Value = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("PatientId")
                Dim RetrivedFrom = Session("PatientBookingSearchSource")
                If (RetrivedFrom = Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI Or
                     RetrivedFrom = Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI) Then
                    PatientIDHiddenField.Value = ImportPatientAndGetPatientId(e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("PatientId"), e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("NHSNo"), RetrivedFrom)
                End If
                PatientNameLabel.Text = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("Forename1") + " " + e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("Surname")
                PatientDOBLabel.Text = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DateOfBirth")
                PatientCaseNoteLabel.Text = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("HospitalNumber")
                PatientNHSNoLabel.Text = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("NHSNo")
                PatientGenderLabel.Text = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("Gender").ToString().ToUpper()

                'Schedule Details
                ScheduleDetailsLabel.Text = CDate(SelectedSlotDateHiddenField.Value).ToString("dddd dd MMM yyyy") & " in " & "" 'RoomsDropdown.SelectedItem.Text
                BookingFirstOfferDate.SelectedDate = CDate(SelectedSlotDateHiddenField.Value)
                CallInTimeRadTimePicker.SelectedTime = CDate(SelectedSlotDateHiddenField.Value).TimeOfDay
                StartTimeRadTimePicker.SelectedTime = CDate(SelectedSlotDateHiddenField.Value).TimeOfDay

                bindBookingRepeater()
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred on list schedules page.", ex)
            Utilities.SetErrorNotificationStyle(BookingErrorRadNotification, errorLogRef, "There is a problem searching for your data.")
            BookingErrorRadNotification.Show()
        End Try
    End Sub

    Protected Sub SaveBookingRadButton_Click(sender As Object, e As EventArgs)
        Try
            'get procedure length
            Dim procTypeID = 0
            Dim procedureLength As Integer
            For Each item As RepeaterItem In PatientBookingProceduresRepeater.Items
                procTypeID = CInt(CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value)

                Dim DiagnosticProcCheckBox As CheckBox = CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox),
                            TherapeuticTypeCheckBox As CheckBox = CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox)

                If DiagnosticProcCheckBox.Checked Or
                    TherapeuticTypeCheckBox.Checked Then
                    procedureLength = DataAdapter_Sch.ProcedureMinutes(procTypeID, OperatingHospitalID)
                End If
            Next

            Dim slotLength = BookingSlotLengthRadNumericTextBox.Value

            'get diarys total points
            Dim totalPoints = DataAdapter_Sch.GetTotalListPoints(DiaryId)
            Dim pointsUsed = 0

            Dim existingAppointments = DataAdapter_Sch.getDaysAppointments(BookingDate.Date, DiaryId) 'GetDiaryUsedPoints(DiaryId, BookingDate.Date)
            If existingAppointments IsNot Nothing Then
                pointsUsed = existingAppointments.AsEnumerable.Where(Function(x) (AppointmentId = 0 Or Not x("AppointmentId") = AppointmentId)).Sum(Function(x) CDec(x("Points")))
            Else
                pointsUsed = 0
            End If
            If String.IsNullOrEmpty(Session("CanOverrideSchedule")) Then
                Session("CanOverrideSchedule") = False
            End If
            If ((BookingSlotPointsRadNumericTextBox.Value > totalPoints And Session("CanOverrideSchedule") = False)) Or (((pointsUsed + BookingSlotPointsRadNumericTextBox.Value) > totalPoints) And Session("CanOverrideSchedule") = False) Then
                'If (BookingSlotPointsRadNumericTextBox.Value > totalPoints And Session("CanOverrideSchedule") = False) Then
                Utilities.SetNotificationStyle(CanNotCreateAppointmentRadNotification, "There are not enough available points on this list to create an appointment.", True, "Please Select")
                CanNotCreateAppointmentRadNotification.Show()
            ElseIf ((pointsUsed + BookingSlotPointsRadNumericTextBox.Value) > totalPoints) And Session("CanOverrideSchedule") = True Then
                ConfirmContinueBookingMessageLabel.Text = String.Format(ConfirmContinueBookingMessageLabel.Text, (pointsUsed + BookingSlotPointsRadNumericTextBox.Value) - totalPoints) '<br /><strong>" & PatientNameLabel.Text & "<br />on " & selectedBookingDate & " at " & BookingDate.ToString("HH:mm") & "</strong><br />"
                Utilities.SetNotificationStyle(ConfirmContinueBookingRadNotification, "Confirm", True, "WARNING - OVERBOOKING ALERT")
                ConfirmContinueBookingRadNotification.AutoCloseDelay = 0
                YesContinueBookingRadButton.CommandName = "ContinueSaveBooking"
                ConfirmContinueBookingRadNotification.Show()
            Else
                saveBooking()

                If RadioButtonLetterPrintList.SelectedIndex > -1 Then
                    If Not (AppointmentIdForLetterPrinting = 0) Then

                        Using letterGenerationLogicObject As New LetterGenerationLogic()
                            If RadioButtonLetterPrintList.SelectedValue = "Print" Then
                                Dim url As String = "../Letters/DisplayAndPrintPDF.aspx?AppointmentId=" & AppointmentIdForLetterPrinting
                                Dim s As String = "window.open('" & url & "', '_blank');"
                                ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", s, True)
                            Else
                                ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", "OpenLetterForEdit(" & AppointmentIdForLetterPrinting & ")", True)
                            End If
                        End Using
                    End If

                End If
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred When booking a scheduled slot.", ex)
            Utilities.SetErrorNotificationStyle(BookingErrorRadNotification, errorLogRef, "There Is a problem saving your booking.")
            BookingErrorRadNotification.Show()
        End Try
    End Sub

    Private Sub saveBooking()

        Try
            Dim selectedBookingDate = CDate(BookingFirstOfferDate.SelectedDate).ToShortDateString
            Dim selectedBookingTime = BookingDate.ToShortTimeString ' CDate(Convert.ToDecimal(StartTimeRadNumericTextBox.Value.ToString()).ToString("N2").Replace(".", ":")).ToShortTimeString
            Dim bookingDateTime = CDate(selectedBookingDate & " " & selectedBookingTime.ToString)
            Dim bookingEndDateTime = bookingDateTime.AddMinutes(BookingSlotLengthRadNumericTextBox.Value)

            Dim blnAppointmentSaved As Boolean = False
            Dim blnIsAppointmentAmended As Boolean = False
            Dim intCurrentWorkingAppointmentId As Integer
            Dim intCurrentAppointmentWaitListId As Integer
            intCurrentAppointmentWaitListId = 0

            'check the end date is not passed the end of the day
            If bookingEndDateTime.Date > BookingFirstOfferDate.SelectedDate Then
                Utilities.SetNotificationStyle(BookingErrorRadNotification, "Length of booking will overlap into the next day. Please correct and try again.", True, "Please correct")
                BookingErrorRadNotification.Show()
                Exit Sub
            End If

            'checking the end date doesn't roll over into another list...

            'get room diaries
            Dim roomDiaries As DataTable = DataAdapter_Sch.getRoomDiaries(RoomId)
            For Each dr As DataRow In roomDiaries.Rows
                If CInt(dr("DiaryId")) = DiaryId Then Continue For

                Dim diaryDates As New List(Of Date)

                'get diaries occurrences 
                If dr.IsNull("RecurrenceRule") Then
                    If CDate(dr("DiaryStart")).Date = bookingDateTime.Date Then diaryDates.Add(CDate(dr("DiaryStart")))
                Else
                    Dim currRule As RecurrenceRule
                    RecurrenceRule.TryParse(dr("RecurrenceRule"), currRule)
                    diaryDates = currRule.Occurrences.Where(Function(x) x.Date = bookingDateTime.Date).ToList
                End If
                'check if any occurrences start before the end date of this appointment
                If diaryDates.Any(Function(x) x > bookingDateTime) Then 'we only care about booking on this date but after the start of this one
                    Dim firstStart = diaryDates.Where(Function(x) bookingEndDateTime > x).FirstOrDefault
                    If (firstStart > DateTime.MinValue) AndAlso (bookingEndDateTime > firstStart) Then
                        Utilities.SetNotificationStyle(BookingErrorRadNotification, "This booking overlaps with another diary.", True, "Please correct")
                        BookingErrorRadNotification.Show()
                        Exit Sub
                    End If
                End If
            Next

            'Get procedureTypes

            Dim bookedProcTypes As New List(Of Products_Scheduler.SearchProcedure)
            If GIProceduresDiv.Visible Then
                For Each item As RepeaterItem In PatientBookingProceduresRepeater.Items
                    Dim procTypeID = CInt(CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value)

                    Dim DiagnosticProcCheckBox As CheckBox = CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox)
                    Dim TherapeuticTypeCheckBox As CheckBox = CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox)
                    Dim PointsTextBox As RadNumericTextBox = CType(item.FindControl("BookingPointsRadNumericTextBox"), RadNumericTextBox)
                    Dim LengthTextBox As RadNumericTextBox = CType(item.FindControl("BookingLengthRadNumericTextBox"), RadNumericTextBox)
                    Dim DefineTherapeuticProcedureButton As Button = CType(item.FindControl("DefineTherapeuticProcedureButton"), Button)

                    If DiagnosticProcCheckBox.Checked Or
                        TherapeuticTypeCheckBox.Checked Then

                        'check for selected therapeutics
                        If TherapeuticTypeCheckBox.Checked And (Session("SearchTherapeuticTypes_" & procTypeID) Is Nothing OrElse DirectCast(Session("SearchTherapeuticTypes_" & procTypeID), List(Of Integer)).Count = 0) Then
                            Utilities.SetNotificationStyle(BookingErrorRadNotification, "Please define therapeutic types.", True, "Please correct")
                            BookingErrorRadNotification.Show()
                            DefineTherapeuticProcedureButton.Enabled = True

                            Exit Sub
                        End If
                        bookedProcTypes.Add(New Products_Scheduler.SearchProcedure With {.ProcedureTypeID = procTypeID, .Points = PointsTextBox.Value, .Minutes = LengthTextBox.Value, .Diagnostic = DiagnosticProcCheckBox.Checked, .Therapeutic = TherapeuticTypeCheckBox.Checked, .TherapeuticTypes = DirectCast(Session("SearchTherapeuticTypes_" & procTypeID), List(Of Integer))})
                    End If
                Next

            Else
                bookedProcTypes.Add(New Products_Scheduler.SearchProcedure() With {.ProcedureTypeID = CInt(ProcedureTypeHiddenField.Value), .Diagnostic = (NonGIProcedureTypeRadioButtonList.SelectedValue.ToLower = "diagnostic"), .Therapeutic = (NonGIProcedureTypeRadioButtonList.SelectedValue.ToLower = "therapeutic"), .Points = BookingPointsRadNumericTextBox.Value, .Minutes = BookingLengthRadNumericTextBox.Value})
            End If

            Using db As New ERS.Data.GastroDbEntities
                If db.ERS_Appointments.Any(Function(x) x.AppointmentId <> ReservedAppointmentId And x.StartDateTime = bookingDateTime And x.DiaryId = DiaryId And Not x.AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(s) s.HDCKEY = "C").FirstOrDefault.UniqueId) Then
                    Utilities.SetNotificationStyle(BookingErrorRadNotification, "A booking already exists on this date and time.", True, "Please correct")
                    BookingErrorRadNotification.Show()
                    Exit Sub
                End If

                If db.ERS_Appointments.Any(Function(x) x.AppointmentId <> ReservedAppointmentId And (x.StartDateTime >= bookingDateTime And bookingDateTime < x.EndDateTime) Or (x.StartDateTime >= bookingEndDateTime And bookingEndDateTime < x.EndDateTime) And x.DiaryId = DiaryId And Not x.AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(s) s.HDCKEY = "C").FirstOrDefault.UniqueId) Then
                    Utilities.SetNotificationStyle(BookingErrorRadNotification, "A booking already exists on this date and time.", True, "Please correct")
                    BookingErrorRadNotification.Show()
                    Exit Sub
                End If

                Dim bookingEnd = bookingDateTime.AddMinutes(BookingSlotLengthRadNumericTextBox.Value)

                Dim overlappedAppointments = (From a In db.ERS_Appointments
                                              Let appointmentEnd = EntityFunctions.AddMinutes(a.StartDateTime, CInt(a.AppointmentDuration))
                                              Where (a.AppointmentId <> ReservedAppointmentId And a.DiaryId = DiaryId And
                                                  Not (a.AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "C").FirstOrDefault.UniqueId Or a.AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "H").FirstOrDefault.UniqueId) And
                                                  Not a.AppointmentId = AppointmentId) And ((a.StartDateTime > BookingDate And a.StartDateTime < bookingEnd) Or (appointmentEnd > BookingDate And appointmentEnd < bookingEnd))
                                              Select a)

                If overlappedAppointments.Any Then
                    Utilities.SetNotificationStyle(BookingErrorRadNotification, "The end of this booking will overlap with another one starting at " & overlappedAppointments.FirstOrDefault.StartDateTime.ToShortTimeString & " and cannot be saved.", True, "Please correct")
                    BookingErrorRadNotification.Show()
                    Exit Sub
                End If

                Dim reservedAppointments = (From a In db.ERS_Appointments
                                            Let appointmentEnd = EntityFunctions.AddMinutes(a.StartDateTime, CInt(a.AppointmentDuration))
                                            Where (a.AppointmentId <> ReservedAppointmentId And a.DiaryId = DiaryId And
                                                  a.AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "H").FirstOrDefault.UniqueId And
                                                  Not a.AppointmentId = AppointmentId) And ((a.StartDateTime > BookingDate And a.StartDateTime < bookingEnd) Or (appointmentEnd > BookingDate And appointmentEnd < bookingEnd))
                                            Select a)

                If reservedAppointments.Any Then
                    Utilities.SetNotificationStyle(BookingErrorRadNotification, "The slot for " & reservedAppointments.FirstOrDefault.StartDateTime.ToShortTimeString & " that you are trying to book into is reserved by another user and cannot be used.", True, "Please correct")
                    BookingErrorRadNotification.Show()
                    Exit Sub
                End If

                'checking appointment is still free...
                Dim isValid = True
                Dim dtExistingAppointments = DataAdapter_Sch.getExistingAppointments(DiaryId, bookingDateTime, bookingEndDateTime)
                If dtExistingAppointments.Rows.Count > 0 Then
                    For Each dr In dtExistingAppointments.Rows
                        If dr("AppointmentId") = ReservedAppointmentId Or (AppointmentId > 0 AndAlso dr("AppointmentId") = AppointmentId) Then Continue For

                        Dim existingStart = DateTime.Parse(dr("StartDateTime"))
                        Dim existingEnd = DateTime.Parse(dr("EndDateTime"))

                        'still might be allowed as this one might start as this one ends or ends as this one starts... (SQL between clause isnt great with these things)
                        If Not bookingDateTime = existingEnd And Not bookingEndDateTime = existingStart Then
                            isValid = False
                        End If
                    Next
                End If

                If Not isValid Then
                    Utilities.SetNotificationStyle(BookingErrorRadNotification, "This booking slot is no longer available and has been filled with another appointment.", True, "Please correct")
                    BookingErrorRadNotification.Show()
                    Exit Sub
                End If

                'procedure type validation
                'do room check
                Dim roomProcs = DataAdapter_Sch.GetRoomProcedureTypes(bookedProcTypes.Select(Function(x) x.ProcedureTypeID).ToList)
                If Not roomProcs.Contains(RoomId) Then
                    Utilities.SetNotificationStyle(BookingErrorRadNotification, "This booking has procedures that cannot be performed in this room.", True, "Please correct")
                    BookingErrorRadNotification.Show()
                    Exit Sub
                End If


                'do endo check
                'PatientEndoscopistHiddenField.Value
                Dim endoProcs = DataAdapter_Sch.GetEndoscopistProcedures(PatientEndoscopistHiddenField.Value)
                If endoProcs IsNot Nothing AndAlso endoProcs.Rows.Count > 0 Then
                    For Each procType In bookedProcTypes
                        If Not endoProcs.AsEnumerable.Any(Function(x) x("ProcedureTypeId") = procType.ProcedureTypeID) Then
                            Utilities.SetNotificationStyle(BookingErrorRadNotification, "This booking has procedures that cannot be performed by this endoscopist.", True, "Please correct")
                            BookingErrorRadNotification.Show()
                            Exit Sub
                        End If
                    Next
                    'For Each proc As DataRow In endoProcs.Rows
                    '    If bookedProcTypes.Any(Function(x) Not x.ProcedureTypeID = proc("ProcedureTypeId")) Then
                    '        Utilities.SetNotificationStyle(BookingErrorRadNotification, "This booking has procedures that cannot be performed by this endoscopist.", True, "Please correct")
                    '        BookingErrorRadNotification.Show()
                    '        Exit Sub
                    '    End If
                    'Next
                End If



                Dim appointmentStatus = db.ERS_AppointmentStatus
                Dim intSELocalPatientId As Integer 'Mahfuz added on 30 June 2021
                Dim dbRecord As ERS.Data.ERS_Appointments

                If Action.ToLower.Trim = "add" Or Action.ToLower.Trim = "waitlist" Or Action.ToLower.Trim = "search" Then
                    If Not String.IsNullOrWhiteSpace(ReservedAppointmentId) Then
                        dbRecord = db.ERS_Appointments.Where(Function(x) x.AppointmentId = ReservedAppointmentId).FirstOrDefault

                        If dbRecord Is Nothing Then
                            'reserved spot must've expired, but slot MUST still be available or check's above wouldn't of let us get this far
                            dbRecord = New ERS.Data.ERS_Appointments

                            'New appointment is being created
                            blnIsAppointmentAmended = False
                        Else
                            'Editing a reserved appointment
                            blnIsAppointmentAmended = True
                        End If
                    End If

                    With dbRecord
                        .OperationalHospitaId = OperatingHospitalID

                        'Mahfuz added/changed on 30 June 2021
                        'If SCIStore D&G Webservice enabled then above patientId will be SCIStorePatientID not SE Local DB PatientID

                        If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
                            Dim ScotHosWSBL As ScotHospitalWebServiceBL = New ScotHospitalWebServiceBL

                            ScotHosWSBL.ConnectWebservice()

                            ''Save SCIStorePatientInformation to SE Local DB and get Local Patient ID
                            intSELocalPatientId = ScotHosWSBL.ImportPatientsIntoDatabaseBySCIStorePatientID(PatientIDHiddenField.Value)
                            'Logout
                            ScotHosWSBL.DisconnectService()
                        Else
                            intSELocalPatientId = PatientIDHiddenField.Value
                        End If

                        '.PatientId = PatientIDHiddenField.Value
                        .PatientId = intSELocalPatientId

                        .DateEntered = Now

                        .StartDateTime = CDate(selectedBookingDate & " " & selectedBookingTime.ToString)
                        .AppointmentDuration = BookingSlotLengthRadNumericTextBox.Value
                        .StaffBookedId = DataAdapter.LoggedInUserId
                        .DiaryId = DiaryId
                        .ReferralDate = BookingReferralDate.SelectedDate
                        .SlotStatusID = PatientBookingSlotStatusRadioButtons.SelectedValue

                        If PatientBookedStatusRadioButtons.SelectedIndex > -1 Then
                            .AppointmentStatusId = appointmentStatus.Where(Function(x) x.HDCKEY = PatientBookedStatusRadioButtons.SelectedValue).FirstOrDefault.UniqueId 'P or B as in ERS_AppointmentStatus
                        Else
                            .AppointmentStatusId = Nothing 'P or B as in ERS_AppointmentStatus
                        End If

                        .Notes = PatientAlertNotesTextBox.Text
                        .GeneralInformation = PatientGeneralInfoNotesTextBox.Text
                        .DueArrivalTime = CDate(selectedBookingDate & " " & CallInTimeRadTimePicker.SelectedTime.Value.ToString)
                        .PriorityiD = PatientBookingSlotStatusRadioButtons.SelectedValue
                        .EndoscopistId = If(String.IsNullOrWhiteSpace(PatientEndoscopistHiddenField.Value.ToString), 0, CInt(PatientEndoscopistHiddenField.Value.ToString))

                        .BookingTypeId = 2 'appointment booking (different from worklist entry)
                        .WaitingListId = If(Session("WaitlistId"), 0)
                        .DateRaised = BookingReferralDate.SelectedDate
                        .ListSlotId = ListSlotId

                    End With

                    If dbRecord.AppointmentId = 0 Then
                        db.ERS_Appointments.Add(dbRecord)
                    Else
                        db.ERS_Appointments.Attach(dbRecord)
                        db.Entry(dbRecord).State = Entity.EntityState.Modified
                    End If
                    AppointmentIdForLetterPrinting = dbRecord.AppointmentId
                    intCurrentWorkingAppointmentId = AppointmentIdForLetterPrinting
                    intCurrentAppointmentWaitListId = dbRecord.WaitingListId
                ElseIf Action.ToLower.Trim = "edit" Then
                    'Appointment is getting amended
                    blnIsAppointmentAmended = True

                    dbRecord = db.ERS_Appointments.Where(Function(x) x.AppointmentId = AppointmentId).FirstOrDefault
                    With dbRecord
                        '.Duration = BookingSlotLengthRadNumericTextBox.Value

                        .StaffChangedId = CInt(Session("PKUserId"))
                        .DateChanged = Now
                        .ReferralDate = BookingReferralDate.SelectedDate
                        .SlotStatusID = PatientBookingSlotStatusRadioButtons.SelectedValue
                        .Notes = PatientAlertNotesTextBox.Text
                        If PatientBookedStatusRadioButtons.SelectedIndex > -1 Then
                            .AppointmentStatusId = appointmentStatus.Where(Function(x) x.HDCKEY = PatientBookedStatusRadioButtons.SelectedValue).FirstOrDefault.UniqueId 'P or B as in ERS_AppointmentStatus
                        Else
                            .AppointmentStatusId = Nothing
                        End If
                        .GeneralInformation = PatientGeneralInfoNotesTextBox.Text
                        .AppointmentDuration = BookingSlotLengthRadNumericTextBox.Value
                        .DueArrivalTime = CDate(selectedBookingDate & " " & CallInTimeRadTimePicker.SelectedTime.Value.ToString)
                        .PriorityiD = PatientBookingSlotStatusRadioButtons.SelectedValue


                    End With

                    db.ERS_Appointments.Attach(dbRecord)
                    db.Entry(dbRecord).State = Entity.EntityState.Modified

                    'delete procedures
                    Dim appointmentProcedures = db.ERS_AppointmentProcedureTypes.Where(Function(x) x.AppointmentID = dbRecord.AppointmentId)
                    Dim appointmentTherapeutics = db.ERS_AppointmentTherapeutics.Where(Function(x) x.AppointmentID = dbRecord.AppointmentId)

                    db.ERS_AppointmentProcedureTypes.RemoveRange(appointmentProcedures)

                    'delete therapeutics
                    db.ERS_AppointmentTherapeutics.RemoveRange(appointmentTherapeutics)
                    AppointmentIdForLetterPrinting = dbRecord.AppointmentId
                    intCurrentWorkingAppointmentId = AppointmentIdForLetterPrinting
                    intCurrentAppointmentWaitListId = dbRecord.WaitingListId
                ElseIf (Action.ToLower.Trim = "move" Or Action.ToLower.Trim = "paste") And Session("AppointmentId") > 0 Then
                    'Appointment is getting amended
                    blnIsAppointmentAmended = True
                    Dim appointmentId = CInt(Session("AppointmentId"))
                    intCurrentWorkingAppointmentId = appointmentId

                    dbRecord = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault
                    With dbRecord
                        .StaffChangedId = DataAdapter.LoggedInUserId
                        .DateChanged = Now

                        'move details
                        .OperationalHospitaId = OperatingHospitalID
                        .PreviousDiaryId = dbRecord.DiaryId
                        .PreviousStartDateTime = dbRecord.StartDateTime
                        .AppointmentDateChangedDate = Now
                        .AppointmentDateChangedBy = DataAdapter.LoggedInUserId
                        .MoveReasonId = 0

                        'booking details
                        .StartDateTime = bookingDateTime
                        .AppointmentDuration = BookingSlotLengthRadNumericTextBox.Value

                        .ReferralDate = BookingReferralDate.SelectedDate
                        .SlotStatusID = PatientBookingSlotStatusRadioButtons.SelectedValue
                        .DiaryId = DiaryId
                        If PatientBookedStatusRadioButtons.SelectedIndex > -1 Then
                            .AppointmentStatusId = appointmentStatus.Where(Function(x) x.HDCKEY = PatientBookedStatusRadioButtons.SelectedValue).FirstOrDefault.UniqueId 'P or B as in ERS_AppointmentStatus
                        Else
                            .AppointmentStatusId = Nothing
                        End If
                        .Notes = PatientAlertNotesTextBox.Text
                        .GeneralInformation = PatientGeneralInfoNotesTextBox.Text
                        .DueArrivalTime = CDate(selectedBookingDate & " " & CallInTimeRadTimePicker.SelectedTime.Value.ToString)
                        .PriorityiD = PatientBookingSlotStatusRadioButtons.SelectedValue
                        .EndoscopistId = If(String.IsNullOrWhiteSpace(PatientEndoscopistHiddenField.Value.ToString), 0, CInt(PatientEndoscopistHiddenField.Value.ToString))
                        .ListSlotId = ListSlotId

                        intCurrentAppointmentWaitListId = dbRecord.WaitingListId
                    End With

                    db.ERS_Appointments.Attach(dbRecord)
                    db.Entry(dbRecord).State = Entity.EntityState.Modified

                    'delete reserved slot
                    If ReservedAppointmentId > 0 Then db.ERS_Appointments.Remove(db.ERS_Appointments.Find(ReservedAppointmentId))
                End If

                db.SaveChanges()
                blnAppointmentSaved = True

                If Not Action.ToLower.Trim = "move" Or Not Action.ToLower.Trim = "paste" Then

                    Dim appointmentID = dbRecord.AppointmentId
                    intCurrentWorkingAppointmentId = appointmentID

                    'delete procedures
                    Dim appointmentProcedures = db.ERS_AppointmentProcedureTypes.Where(Function(x) x.AppointmentID = appointmentID)
                    Dim appointmentTherapeutics = db.ERS_AppointmentTherapeutics.Where(Function(x) x.AppointmentID = appointmentID)

                    db.ERS_AppointmentProcedureTypes.RemoveRange(appointmentProcedures)

                    'delete therapeutics
                    db.ERS_AppointmentTherapeutics.RemoveRange(appointmentTherapeutics)
                    db.SaveChanges()
                    blnAppointmentSaved = True

                    For Each proc In bookedProcTypes
                        Dim appProcType = New ERS.Data.ERS_AppointmentProcedureTypes
                        With appProcType
                            .AppointmentID = appointmentID
                            .ProcedureTypeID = proc.ProcedureTypeID
                            .IsTherapeutic = proc.Therapeutic
                            .Minutes = proc.Minutes 'should be the length of the appointment
                            .Points = proc.Points 'should be the amount of points for the appointment
                        End With
                        db.ERS_AppointmentProcedureTypes.Add(appProcType)
                        db.SaveChanges()

                        If proc.TherapeuticTypes IsNot Nothing Then
                            For Each procTherap In proc.TherapeuticTypes
                                Dim theraps = New ERS.Data.ERS_AppointmentTherapeutics
                                With theraps
                                    .AppointmentID = appointmentID
                                    .TherapeuticTypeID = procTherap
                                    .AppointmentProcedureId = appProcType.AppointmentProcedureTypeID
                                End With
                                db.ERS_AppointmentTherapeutics.Add(theraps)
                            Next
                            db.SaveChanges()
                            Session("SearchTherapeuticTypes_" & proc.ProcedureTypeID) = Nothing
                        End If

                    Next
                    db.SaveChanges()
                    blnAppointmentSaved = True
                End If

                If Action = "waitlist" Then
                    DataAdapter_Sch.updateWaitlist(PatientIDHiddenField.Value, bookedProcTypes(0).ProcedureTypeID)
                End If

                'insert data into letterQueue table
                DataAdapter_Sch.insertLetterQueueData(dbRecord.AppointmentId)
            End Using

            Dim strOrderMessage As String = ""
            Dim blnOrderEventIdSendEnabled As Boolean = False
            Dim strLoggedInUserName As String = HttpContext.Current.Session("UserID")
            Dim OrderCommsBL As New OrderCommsBL
            Dim intOrderId As Integer = 0
            Dim intLoggedInUserId As Integer = CInt(Session("PKUserId"))

            If Not IsNothing(Session("BookFromWaitListOrderId")) Then
                If Session("BookFromWaitListOrderId").ToString.Trim() <> "" Then
                    intOrderId = CInt(Session("BookFromWaitListOrderId").ToString())
                Else
                    intOrderId = OrderCommsBL.GetOrderIdByAppointmentId(intCurrentWorkingAppointmentId)
                End If
            Else
                intOrderId = OrderCommsBL.GetOrderIdByAppointmentId(intCurrentWorkingAppointmentId)
            End If

            If blnAppointmentSaved Then 'Appointment has been saved (either edited or created) - Only send Order Message if appointment created or modified
                If blnIsAppointmentAmended Then
                    'Appointment modified/changed
                    'Code 7 for Edit Appointment
                    If intOrderId > 0 Then
                        'Amended Appointment can be Moved or other edit
                        If Action.ToString().ToUpper() = "MOVE" Then
                            blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(10)
                            If blnOrderEventIdSendEnabled Then
                                strOrderMessage = "Appointment Moved by " + strLoggedInUserName + ". "
                                strOrderMessage = strOrderMessage + OrderCommsBL.GetOrderAppointmentMessageByAppointmentId(intCurrentWorkingAppointmentId)
                                OrderCommsBL.SendOrderMessageByOrderAndEventId(intOrderId, 10, Nothing, intCurrentAppointmentWaitListId, intCurrentWorkingAppointmentId, strOrderMessage, Nothing, intLoggedInUserId)
                                Session("BookFromWaitListOrderId") = Nothing
                            End If
                        Else
                            blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(7)
                            If blnOrderEventIdSendEnabled Then
                                strOrderMessage = "Appointment amended by " + strLoggedInUserName + ". "
                                strOrderMessage = strOrderMessage + OrderCommsBL.GetOrderAppointmentMessageByAppointmentId(intCurrentWorkingAppointmentId)
                                OrderCommsBL.SendOrderMessageByOrderAndEventId(intOrderId, 7, Nothing, intCurrentAppointmentWaitListId, intCurrentWorkingAppointmentId, strOrderMessage, Nothing, intLoggedInUserId)
                                Session("BookFromWaitListOrderId") = Nothing
                            End If
                        End If
                    End If
                Else
                    'New Appointment created
                    'Code 6 for New Appointment
                    blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(6)
                    If blnOrderEventIdSendEnabled Then
                        strOrderMessage = "New Appointment created by " + strLoggedInUserName + ". "
                        strOrderMessage = strOrderMessage + OrderCommsBL.GetOrderAppointmentMessageByAppointmentId(intCurrentWorkingAppointmentId)
                        OrderCommsBL.SendOrderMessageByOrderAndEventId(intOrderId, 6, Nothing, intCurrentAppointmentWaitListId, intCurrentWorkingAppointmentId, strOrderMessage, Nothing, intLoggedInUserId)
                        Session("BookFromWaitListOrderId") = Nothing
                    End If
                End If
            End If
            Utilities.SetNotificationStyle(BookingErrorRadNotification, "<br /><strong>" & PatientNameLabel.Text & "<br />on " & selectedBookingDate & " at " & BookingDate.ToString("HH:mm") & "</strong><br />", True, "Booking Saved")
            BookingErrorRadNotification.Show()
            'BookingDetailsLabel.Text = "<br /><strong>" & PatientNameLabel.Text & "<br />on " & selectedBookingDate & " at " & BookingDate.ToString("HH:mm") & "</strong><br />"
            'Utilities.SetNotificationStyle(BookingWindowRadNotification, "Booking saved successfully.", False, "Booking saved")
            'BookingWindowRadNotification.AutoCloseDelay = 0
            'BookingWindowRadNotification.Show()
            'BookingWindowRadNotification.ShowCloseButton = False
            'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "show-modal-script", "showModal();", True)

            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-window", "CloseAndRebind();", True)

            'Session("BookedDate") = BookingFirstOfferDate.SelectedDate.Value
            'Session("BookedHospitalId") = OperatingHospitalID
            'Session("B") = RoomId



            Session("AppointmentId") = Nothing
            Session("SearchProcedureTypes") = Nothing
            Session("SlotSearchMode") = Nothing
            Session("WaitlistId") = Nothing
            Session("BookFromWaitListOrderId") = Nothing
            PageSearchFields = Nothing
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred when booking a scheduled slot.", ex)
            Utilities.SetErrorNotificationStyle(BookingErrorRadNotification, errorLogRef, "There is a problem saving your booking.")
            BookingErrorRadNotification.Show()
        End Try
    End Sub

    Protected Sub NavigateToTodayRadButton_Click(sender As Object, e As EventArgs)
        Session("BookedDate") = Now
        Session("BookedHospitalId") = Nothing
        Session("BookedRoom") = Nothing
        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-window", "CloseAndRebind();", True)
    End Sub

    Protected Sub PatientBookingProceduresRepeater_ItemCreated(sender As Object, e As RepeaterItemEventArgs)
        Try
            If e.Item.DataItem IsNot Nothing Then
                Dim diagnosticproceduretypecheckbox As CheckBox = DirectCast(e.Item.FindControl("diagnosticproceduretypescheckbox"), CheckBox)
                Dim therapeuticproceduretypecheckbox As CheckBox = DirectCast(e.Item.FindControl("therapeuticproceduretypescheckbox"), CheckBox)

                diagnosticproceduretypecheckbox.Attributes("oncheckchanged") = String.Format("return getNonGISlotLength({0},'{1}', 'true');", DataBinder.Eval(e.Item.DataItem, "ProcedureTypeId"), diagnosticproceduretypecheckbox.ClientID)
                therapeuticproceduretypecheckbox.Attributes("oncheckchanged") = String.Format("return getNonGISlotLength({0},'{1}', 'false');", DataBinder.Eval(e.Item.DataItem, "ProcedureTypeId"), therapeuticproceduretypecheckbox.ClientID)

                Dim dataRow = DirectCast(e.Item.DataItem, DataRowView)

                If Not dataRow("SchedulerDiagnostic") Then
                    CType(e.Item.FindControl("DiagnosticProcedureTypesCheckBoxLabel"), WebControls.Label).Visible = False
                    CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Visible = False
                End If

                If Not dataRow("SchedulerTherapeutic") Then
                    CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBoxLabel"), WebControls.Label).Visible = False
                    CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Visible = False
                    CType(e.Item.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = False
                End If

            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in PatientBookingProceduresRepeater_ItemCreated", ex)
        End Try

    End Sub

    Protected Sub SearchPatientButton_Click(sender As Object, e As EventArgs)
        Try
            If String.IsNullOrEmpty(PatientSearchCNNTextBox.Text) AndAlso
                String.IsNullOrEmpty(PatientSearchHealthServiceNoRadTextBox.Text) AndAlso
                String.IsNullOrEmpty(PatientSearchSurnameTextBox.Text) AndAlso
                String.IsNullOrEmpty(PatientSearchForenameTextBox.Text) Then

                Utilities.SetNotificationStyle(BookingErrorRadNotification, "Search criteria not entered.", True, "Search for patient")
                BookingErrorRadNotification.AutoCloseDelay = 1500
                BookingErrorRadNotification.Show()

                PatientNotFoundLabel.Visible = True
                RadTabStrip1.Visible = False
            ElseIf (Not String.IsNullOrEmpty(PatientSearchSurnameTextBox.Text) And PatientSearchSurnameTextBox.Text.Length < 3) Or
                   (Not String.IsNullOrEmpty(PatientSearchForenameTextBox.Text) And PatientSearchForenameTextBox.Text.Length < 3) Then

                Utilities.SetNotificationStyle(BookingErrorRadNotification, "Please enter 3 or more characters to search.", True, "Search for patient")
                BookingErrorRadNotification.AutoCloseDelay = 1500
                BookingErrorRadNotification.Show()

                PatientNotFoundLabel.Visible = True
                RadTabStrip1.Visible = False
            Else
                'Mahfuz changed for D&G Scottish Hospital Patient Search on 30 June 2021
                Dim dtPatientSearch As New DataTable
                Session("PatientBookingSearchSource") = ""

                'Mahfuz implemented Scottish Hospital SCI Store webservice patient import integration
                If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then

                    'Create the Search Fields
                    Dim optionCondition As String
                    optionCondition = "AND" 'No And/Or checkbox in this page
                    'build search string 
                    Dim searchFields As New Dictionary(Of String, String)
                    searchFields.Add("SearchBoxText", "")
                    searchFields.Add("SearchCondition", optionCondition)
                    searchFields.Add("SearchTerm", "contains")
                    searchFields.Add("CaseNoteNo", Trim(PatientSearchCNNTextBox.Text))
                    searchFields.Add("NHSNo", Trim(PatientSearchHealthServiceNoRadTextBox.Text))
                    searchFields.Add("Surname", Trim(PatientSearchSurnameTextBox.Text))
                    searchFields.Add("Forename", Trim(PatientSearchForenameTextBox.Text))


                    searchFields.Add("DOB", "")
                    searchFields.Add("Address", "")
                    searchFields.Add("Postcode", "")
                    'searchFields.Add("ExcludeDeceased", False)
                    searchFields.Add("IncludeDeceased", False)

                    Session(Constants.SESSION_PATIENT_SEARCH_FIELDS) = searchFields


                    Dim ScotHosWSBL As ScotHospitalWebServiceBL = New ScotHospitalWebServiceBL

                    ScotHosWSBL.ConnectWebservice()
                    'Call GetPatients method
                    'ScotHosWSBL.FindAndImportPatients()
                    dtPatientSearch = ScotHosWSBL.SearchAndGetPatientsViaWebService.Tables(0)

                    'Logout
                    ScotHosWSBL.DisconnectService()
                    'ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.FileDataExport Then
                    'Do Flatfile related job
                ElseIf ((Session(Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI) = ImportPatientByWebserviceOptions.NSSAPI) And Not String.IsNullOrEmpty(Trim(PatientSearchHealthServiceNoRadTextBox.Text))) Then


                    Dim nipapiPIBL As NIPAPIBL = New NIPAPIBL()
                    Dim chiNumber As String = Trim(PatientSearchHealthServiceNoRadTextBox.Text)
                    Session("PatientBookingSearchSource") = Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI
                    ' Dim patient = nipapiPIBL.GetPatientFromNIPByCHINumber(chiNumber)
                    dtPatientSearch = nipapiPIBL.GetPatientFromNIPAndGetGeneratedDataset(chiNumber).Tables(0)
                ElseIf ((Session(Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI) = ImportPatientByWebserviceOptions.NHSSPINEAPI) And Not String.IsNullOrEmpty(Trim(PatientSearchHealthServiceNoRadTextBox.Text))) Then


                    Dim nhsSpineAPI As NHSSPINEAPIBL = New NHSSPINEAPIBL()
                    Dim nhsNumber As String = Trim(PatientSearchHealthServiceNoRadTextBox.Text)
                    Dim surName = Trim(PatientSearchSurnameTextBox.Text)
                    Dim givenNameName = Trim(PatientSearchForenameTextBox.Text)
                    Session("PatientBookingSearchSource") = Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI
                    ' Dim patient = nipapiPIBL.GetPatientFromNIPByCHINumber(chiNumber)
                    dtPatientSearch = nhsSpineAPI.GetPatientFromNHSSPINEAndGetGeneratedDataset(nhsNumber, surName, givenNameName, Nothing, Nothing, Nothing).Tables(0)


                Else
                    dtPatientSearch = DataAdapter_Sch.SearchPatients(PatientSearchCNNTextBox.Text, PatientSearchHealthServiceNoRadTextBox.Text, PatientSearchSurnameTextBox.Text, PatientSearchForenameTextBox.Text)
                    'dtPatientSearch = DataAdapter.GetPatients(PatientSearchCNNTextBox.Text, PatientSearchHealthServiceNoRadTextBox.Text, PatientSearchSurnameTextBox.Text, PatientSearchForenameTextBox.Text, "", "", "", "AND", "contains", False)
                End If


                'PatientSearchResultsRadGrid.DataSource = DataAdapter_Sch.SearchPatients(PatientSearchCNNTextBox.Text, PatientSearchNHSNoTextBox.Text, PatientSearchSurnameTextBox.Text, PatientSearchForenameTextBox.Text)
                PatientSearchResultsRadGrid.DataSource = dtPatientSearch
                PatientSearchResultsRadGrid.DataBind()

                PatientSearchDiv.Style.Remove("display")
                BookingDiv.Style.Item("display") = "none"

                PatientNotFoundLabel.Visible = (PatientSearchResultsRadGrid.Items.Count = 0)
                RadTabStrip1.Visible = True
                RadTabStrip1.SelectedIndex = 0
                RadPatients.SelectedIndex = 0
            End If

            'Dim setJavaScriptCode As String = "$('#HealthServiceNameIdTd').val(" + Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " Number:" + ");"

            'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-health-service-name", setJavaScriptCode, True)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred on list schedules page.", ex)
            Utilities.SetErrorNotificationStyle(BookingErrorRadNotification, errorLogRef, "There is a problem searching for your data.")
            BookingErrorRadNotification.Show()
        End Try
    End Sub
    Private Function ImportPatientAndGetPatientId(patientId As Integer, patNHSNo As String, RetrivedFrom As String) As String
        If RetrivedFrom = Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI Then


            Dim nipapiPIBL As NIPAPIBL = New NIPAPIBL()
            Dim chiNumber As String = patNHSNo

            patientId = nipapiPIBL.ExtractAndImportPatientsIntoDatabase(chiNumber)
        End If
        If RetrivedFrom = Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI Then

            Dim nhsSpineAPI As NHSSPINEAPIBL = New NHSSPINEAPIBL()
            Dim nhsNumber As String = patNHSNo

            patientId = nhsSpineAPI.ExtractAndImportPatientsIntoDatabase(nhsNumber)
        End If
        Return patientId
    End Function
    Protected Sub YesContinueBookingRadButton_Click(sender As Object, e As EventArgs)
        If YesContinueBookingRadButton.CommandName = "ContinueSaveBooking" Then
            saveBooking()
        Else
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "notification-close", "$find('<%=BookingTruncatedRadNotification.ClientID%>').hide();", True)
        End If
    End Sub

    Protected Sub NavigateToBookingRadButton_Click(sender As Object, e As EventArgs)
        'Session("BookedDate") = Now
        'Session("BookedHospitalId") = Nothing
        'Session("BookedRoom") = Nothing
        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-window", "CloseAndRebind();", True)
    End Sub

    Protected Sub CancelSaveBookingRadButton_Click(sender As Object, e As EventArgs)
        'clear sessions
        Session("SearchProcedureTypes") = Nothing
        Session("SlotSearchMode") = Nothing
        Session("WaitlistId") = Nothing
        Session("BookFromWaitListOrderId") = Nothing

        For Each itm As RepeaterItem In PatientBookingProceduresRepeater.Items
            Dim procTypeId = CType(itm.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value
            Session("SearchTherapeuticTypes_" & procTypeId) = Nothing

        Next
        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-window-dialog", "CloseBookingWindow();", True)
        'CloseBookingWindow
    End Sub

    Private Sub PatientSearchResultsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles PatientSearchResultsRadGrid.ItemDataBound
        Try


            If TypeOf e.Item Is GridDataItem Then
                Dim dataItem As GridDataItem = CType(e.Item, GridDataItem)

                'Format NHS Number
                'Dim cell As TableCell = dataItem("NHSNo")
                Dim cell As TableCell = dataItem(columnUniqueName:="HealthServiceNameColumn")
                cell.Text = Utilities.FormatHealthServiceNumber(cell.Text.Replace("&nbsp;", String.Empty))

            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred in PatientSearchResultsRadGrid_ItemDataBound method.", ex)
            Utilities.SetErrorNotificationStyle(BookingErrorRadNotification, errorLogRef, "There is a problem searching for your data.")
            BookingErrorRadNotification.Show()
        End Try

    End Sub

    Private Sub PatientSearchResultsRadGrid_PreRender(sender As Object, e As EventArgs) Handles PatientSearchResultsRadGrid.PreRender

        If PatientSearchResultsRadGrid.MasterTableView.Columns.FindByUniqueName("HealthServiceNameColumn") IsNot Nothing Then
            PatientSearchResultsRadGrid.MasterTableView.Columns.FindByUniqueName("HealthServiceNameColumn").HeaderText =
                Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " No"
        End If
        If PatientSearchResultsRadGrid.Items.Count = 0 Then
            Try
                If Session("PatientBookingSearchSource") = Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI Then
                    Dim norecordItem As GridNoRecordsItem = CType(PatientSearchResultsRadGrid.MasterTableView.GetItems(GridItemType.NoRecordsItem)(0), GridNoRecordsItem)

                    Dim lbl As HtmlGenericControl = CType(norecordItem.FindControl("NoRecordsDiv"), HtmlGenericControl)
                    lbl.InnerText = ConfigurationManager.AppSettings("NIPAPINoRecordFound").ToString()
                End If
                If Session("PatientBookingSearchSource") = Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI Then
                    Dim norecordItem As GridNoRecordsItem = CType(PatientSearchResultsRadGrid.MasterTableView.GetItems(GridItemType.NoRecordsItem)(0), GridNoRecordsItem)

                    Dim lbl As HtmlGenericControl = CType(norecordItem.FindControl("NoRecordsDiv"), HtmlGenericControl)
                    lbl.InnerText = ConfigurationManager.AppSettings("NHSSPINEAPINoRecordFound").ToString()
                End If
            Catch
            End Try
        End If

    End Sub

    Protected Sub TherapeuticProcedureTypesCheckBox_CheckedChanged(sender As Object, e As EventArgs)

    End Sub

    Protected Sub PatientBookingProceduresRepeater_ItemCommand(source As Object, e As RepeaterCommandEventArgs)
        If TypeOf (source) Is CheckBox Then
            Dim chkTherapeutic = CType(source, CheckBox)
            Dim btnDefine = CType(e.Item.FindControl("DefineTherapeuticProcedureButton"), Button)

            If chkTherapeutic.Checked Then
                btnDefine.Enabled = True
            Else
                btnDefine.Enabled = False
            End If
        End If
    End Sub

    Private Sub resetTherapeutics()
        For Each itm As RepeaterItem In PatientBookingProceduresRepeater.Items
            Dim procTypeId = CType(itm.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value
            Session("SearchTherapeuticTypes_" & procTypeId) = Nothing
        Next
    End Sub
#End Region
End Class