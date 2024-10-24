Imports System.Web.Script.Serialization
Imports Telerik.Web.UI

Public Class FindBookSlot
    Inherits System.Web.UI.Page

#Region "Web methods"
    <System.Web.Services.WebMethod>
    Public Shared Function GetProcedureLengths(procedureTypeId As Integer, checked As Boolean, operatingHospitalId As Integer, nonGI As Boolean, isTraining As Boolean, isDiagnostic As Boolean) As String
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim mappings = (From pm In db.ERS_SCH_PointMappings
                                Where pm.ProceduretypeId = procedureTypeId And
                                      pm.OperatingHospitalId = operatingHospitalId And
                                      pm.Training = isTraining And
                                      pm.NonGI = nonGI
                                Select pm.Minutes, pm.Points, pm.TherapeuticMinutes, pm.TherapeuticPoints).FirstOrDefault()

                Dim obj = New With {
                    .procedureTypeId = procedureTypeId,
                    .length = If(isDiagnostic, mappings.Minutes, mappings.TherapeuticMinutes),
                    .checked = checked,
                    .points = If(isDiagnostic, mappings.Points, mappings.TherapeuticPoints)
                }

                Return New JavaScriptSerializer().Serialize(obj)
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in web method GetProcedureLengths", ex)
            Throw ex
        End Try
    End Function


    <System.Web.Services.WebMethod>
    Public Shared Function GetSlotBreechDays(slotIds As List(Of Integer)) As Integer
        Try
            Dim da As New DataAccess_Sch
            Return da.GetSlotBreechDays(slotIds)

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in web method GetSlotBreechDays", ex)
            Throw ex
        End Try
    End Function

#End Region
#Region "Properties"
    Public ReadOnly Property OperatingHospitalId As Integer
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("operatinghospitalid")) Then
                Return CInt(Request.QueryString("operatinghospitalid"))
            Else
                Return 0
            End If
        End Get
    End Property
    Public ReadOnly Property AppointmentId As Integer
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("appointmentid")) Then
                Return CInt(Request.QueryString("appointmentid"))
            Else
                Return 0
            End If
        End Get
    End Property
    Public ReadOnly Property Mode As String
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("mode")) Then
                Return Request.QueryString("mode")
            Else
                Return "s"
            End If
        End Get
    End Property
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
    Private Property PageSearchFields As Products_Scheduler.SearchFields
        Get
            Return Session("SearchFields")
        End Get
        Set(value As Products_Scheduler.SearchFields)
            Session("SearchFields") = value
        End Set
    End Property
#End Region

#Region "Find available slots private methods"
    Private Sub resetFilters()
        If SearchTrustRadComboBox.SelectedValue = 0 Then
            SearchOperatingHospitalIdRadComboBox.DataSource = DataAdapter_Sch.GetAllSchedulerHospitals()
        Else
            SearchOperatingHospitalIdRadComboBox.DataSource = DataAdapter_Sch.GetSchedulerHospitals(SearchTrustRadComboBox.SelectedValue)
        End If
        SearchOperatingHospitalIdRadComboBox.DataBind()
        SearchOperatingHospitalIdRadComboBox.Items(SearchOperatingHospitalIdRadComboBox.FindItemIndexByValue(OperatingHospitalId)).Checked = True

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
                                    Where sd.OperatingHospitalId = OperatingHospitalId
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

    Private Sub BuildSlotRow(ByVal dr As DataRow, ByRef newRow As DataRow, currDate As DateTime, Optional FilteredGender As String = "")
        Try
            Dim slotDateTime = currDate.ToShortDateString & " " & CDate(dr("DiaryStart")).ToShortTimeString()

            'Dim result = DiarysAvailableSlots(CInt(dr("DiaryId")), currDate.ToShortDateString)
            'If result.Count = 0 Then Exit Sub

            newRow("SlotDate") = currDate.ToString("ddd dd MMM yyyy")
            newRow("SlotTime") = CDate(dr("DiaryStart")).ToShortTimeString() '& "-" & CDate(dr("End")).ToShortTimeString()
            newRow("Endoscopist") = dr("EndoscopistName")
            newRow("RoomName") = dr("RoomName")
            newRow("RoomID") = dr("RoomId")
            newRow("Template") = dr("ListName") & If(CBool(dr("Training")), " (training)", "")
            newRow("SlotType") = dr("Description")
            newRow("Reserved") = dr("ProcedureType")
            newRow("DiaryId") = dr("DiaryId")
            newRow("OperatingHospitalId") = dr("OperatingHospitalId")
            newRow("ListSlotId") = dr("ListSlotId")
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("BuildSlotRow:  " + ex.ToString(), ex)
            Utilities.SetErrorNotificationStyle(SearchWindowRadNotification, errorLogRef, "There is a problem with your request.")
            SearchWindowRadNotification.Show()
        End Try
    End Sub


    Private Function DiarysAvailableSlots(iDiaryId As Integer, slotDate As String) As List(Of DiarySlot)
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
                                       .OperatingHospitalId = ds("OperatingHospitalId"),
                                       .ListSlotId = ds("ListSlotId")})


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
            Return Nothing
        End Try
    End Function

#End Region

#Region "Book from waitlist private methods"
    Protected Sub LoadWaitlistGrids()

        cboOperatingHospitals.DataSource = DataAdapter_Sch.GetSchedulerHospitals(CInt(Session("TrustId")))
        cboOperatingHospitals.DataValueField = "OperatingHospitalId"
        cboOperatingHospitals.DataTextField = "HospitalName"
        cboOperatingHospitals.DataBind()

        For Each item As RadComboBoxItem In cboOperatingHospitals.Items
            If item.Value = OperatingHospitalId.ToString() Then
                item.Checked = True
                Exit For
            End If
        Next

        Dim ids = ""
        For Each item As RadComboBoxItem In cboOperatingHospitals.Items
            If item.Checked Then
                ids += item.Value.ToString() + ","
            End If
        Next
        If ids.EndsWith(",") Then
            ids = ids.TrimEnd(","c)
        End If

        Dim da As New DataAccess_Sch
        Dim waitList = da.GetWaitlistPatientsForWBookFromWaitList(ids)
        Dim waitlistPatients = waitList.AsEnumerable.Where(Function(x) Not x.IsNull("AdmissionTypeId") AndAlso x("AdmissionTypeId") = 1)
        If waitlistPatients.Count > 0 Then
            WaitListGrid.DataSource = waitlistPatients.CopyToDataTable
            WaitListGrid.DataBind()
        Else
            WaitListGrid.DataSource = Nothing
            WaitListGrid.DataBind()
        End If
    End Sub
    Protected Sub cboOperatingHospitals_ItemChecked(sender As Object, e As RadComboBoxItemEventArgs)
        Dim da As New DataAccess_Sch
        Dim ids = ""
        For Each item As RadComboBoxItem In cboOperatingHospitals.Items
            If item.Checked Then
                ids += item.Value.ToString() + ","
            End If
        Next
        If ids.EndsWith(",") Then
            ids = ids.TrimEnd(","c)
        End If
        ids = ids.TrimEnd()
        Dim waitList = da.GetWaitlistPatientsForWBookFromWaitList(ids)
        Dim waitlistPatients = waitList.AsEnumerable.Where(Function(x) Not x.IsNull("AdmissionTypeId") AndAlso x("AdmissionTypeId") = 1)
        If waitlistPatients.Count > 0 Then
            WaitListGrid.DataSource = waitlistPatients.CopyToDataTable
        Else
            WaitListGrid.DataSource = Nothing
        End If
        WaitListGrid.DataBind()
    End Sub

    Protected Sub searchSlotFromList(waitlistId As Integer, dataKeyValues As Object)
        Try
            Session("SlotSearchMode") = "w"

            divResults.Visible = False
            divWaitlist.Visible = False
            divWaitDetails.Visible = False
            divOrderDetails.Visible = False
            divFilters.Visible = True

            rptProcedureTypes.DataSource = DataAdapter_Sch.GetProcedureTypes(True)
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

                            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "procedure-length", "calculateSlotLength(" & procedureId & ", true,true);", True)

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
            Dim errorMsg = "Error searching from list"
            Dim errorRef = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(SearchWindowRadNotification, errorRef, errorMsg)
            SearchWindowRadNotification.Show()
        End Try

    End Sub

    Protected Sub ShowOrderDetail(orderId As Integer)
        If orderId > 0 Then
            Dim orderDetails = DataAdapter_Sch.GetOrderDetails(orderId)
            If orderDetails.Rows.Count > 0 Then
                OrderDetailPatName.Text = orderDetails.Rows(0)("Forename1").ToString() + " " + orderDetails.Rows(0)("Surname").ToString()
            End If
        End If
    End Sub

#End Region
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsPostBack Then
            Dim eventTarget As String = Request("__EVENTTARGET")
            If eventTarget = cboOperatingHospitals.ClientID Then
                cboOperatingHospitals_ItemChecked(sender, Nothing)
            End If
        End If
        If Not Page.IsPostBack Then

            SearchTrustRadComboBox.DataSource = DataAdapter_Sch.GetSchedulerTrusts
            SearchTrustRadComboBox.DataBind()
            SearchTrustRadComboBox.Items.Add(New RadComboBoxItem("All trusts", 0))
            SearchTrustRadComboBox.SelectedValue = 0

            rptProcedureTypes.DataSource = DataAdapter_Sch.GetProcedureTypes(True)
            rptProcedureTypes.DataBind()

            Session("SlotSearchMode") = Mode

            setDayDefaults()
            enableDisableControls(True)
            resetFilters()

            Select Case Mode
                Case "s"
                    divFilters.Visible = True
                    MoveBookingTR.Visible = False
                    divResults.Visible = False
                    divWaitlist.Visible = False
                    divWaitDetails.Visible = False
                    divOrderDetails.Visible = False
                Case "w"
                    LoadWaitlistGrids()
                    divResults.Visible = False
                    divWaitlist.Visible = True
                    divWaitDetails.Visible = False
                    divOrderDetails.Visible = False
                    divFilters.Visible = False
                Case "m"
                    ''Procedure types
                    rptProcedureTypes.DataBind()

                    enableDisableControls(True)
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

                    'Dim appointmentId = SelectedApppointmentId.Value

                    Using db As New ERS.Data.GastroDbEntities
                        Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = AppointmentId).FirstOrDefault

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
                                    CType(itm.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = True
                                Else
                                    CType(itm.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Checked = True
                                End If


                                'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "setSlotLength", "calculateSlotLength(" & procedureTypeId & ", 'true','" & If(bookingProcedureType.IsTherapeutic, "false", "true") & "')", True)
                            End If
                        Next
                    End Using
                    Session("AppointmentId") = AppointmentId
            End Select





        End If
    End Sub

    Protected Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
        'For Each item As RepeaterItem In rptProcedureTypes.Items
        '    CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Checked = False
        '    CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = False

        '    Dim procedureTypeId As Integer = CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value
        '    Session("SearchTherapeuticTypes_" & procedureTypeId.ToString()) = Nothing
        'Next

        'Session("SearchFields") = Nothing
    End Sub


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



            If results IsNot Nothing AndAlso results.Rows.Count > 0 Then
                Dim foundLists = da.diarySlots(results)
                NoResultsDiv.Visible = False

                'Get Endo rules to filter results by
                Dim endosForProc As New List(Of Integer)
                Dim endosForTherapType As New List(Of Integer)

                If searchFields.ProcedureTypes.Any(Function(x) x.Diagnostic And x.ProcedureTypeID > 0) Then
                    endosForProc = da.GetEndoscopistsByProcedureTypes(searchFields.ProcedureTypes.Where(Function(x) x.Diagnostic).Select(Function(x) x.ProcedureTypeID).ToList)
                    If endosForProc.Count > 0 AndAlso results.AsEnumerable.Any(Function(x) endosForProc.Contains(x("EndoscopistId")) Or x("EndoscopistId") = 0) Then
                        'only return rows where matched endo is present
                        results = results.AsEnumerable.Where(Function(x) endosForProc.Contains(x("EndoscopistId")) Or x("EndoscopistId") = 0).CopyToDataTable()
                    Else
                        If results.AsEnumerable.Any(Function(x) x("EndoscopistId") = 0) Then
                            results = results.AsEnumerable.Where(Function(x) x("EndoscopistId") = 0).CopyToDataTable()
                        Else
                            results = Nothing
                            'set no rows message to: 
                            NoResultsLabel.Text = "There are no endoscopists available to carry out your chosen procedure(s)"
                        End If
                    End If
                End If

                If results.Rows.Count > 0 Then
                    If searchFields.ProcedureTypes.Any(Function(x) x.TherapeuticTypes IsNot Nothing) Then
                        ' added by ferdowsi
                        Dim therapTypeIds As New List(Of Integer)
                        Dim procedureTypeIds As New List(Of Integer)
                        For Each i In searchFields.ProcedureTypes.Where(Function(x) x.TherapeuticTypes IsNot Nothing)
                            ' Add the procedure type ID to the list
                            procedureTypeIds.Add(i.ProcedureTypeID)
                            ' Add all therapeutic type IDs to the list
                            therapTypeIds.AddRange(i.TherapeuticTypes)
                        Next
                        ' added by ferdowsi

                        Dim endosForTherapDT = da.GetEndoscopistsByProcedureTherapeutics(therapTypeIds, procedureTypeIds) ' added by ferdowsi

                        If endosForTherapDT IsNot Nothing AndAlso endosForTherapDT.Rows.Count > 0 Then
                            endosForTherapType = endosForTherapDT.AsEnumerable.Select(Function(x) CInt(x("EndoscopistId"))).Distinct.ToList
                        End If

                        If endosForTherapType.Count > 0 AndAlso results.AsEnumerable.Any(Function(x) endosForTherapType.Contains(CInt(x("EndoscopistId")))) Then
                            results = results.AsEnumerable.Where(Function(x) endosForTherapType.Contains(CInt(x("EndoscopistId")))).CopyToDataTable
                        Else
                            If results.AsEnumerable.Any(Function(x) x("EndoscopistId") = 0) Then
                                results = results.AsEnumerable.Where(Function(x) x("EndoscopistId") = 0).CopyToDataTable()
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
                    'gender lists
                    If Not String.IsNullOrWhiteSpace(searchFields.Gender) Then
                        If results.AsEnumerable.Any(Function(x) x("ListGender").ToString.ToLower = searchFields.Gender.ToLower) Then
                            'remove rows where gender isnt whats specified
                            results = results.AsEnumerable.Where(Function(x) x("ListGender").ToString.ToLower = searchFields.Gender.ToLower).CopyToDataTable
                        Else
                            results = New DataTable
                            'set no rows message to: 
                            NoResultsLabel.Text = "There are no lists for your specified gender"
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
                    dt.Columns.Add("ListSlotId") 'listSlotId

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

                            If CDate(dr("DiaryStart")).ToShortDateString = currDate.ToShortDateString Then
                                Dim dtRow As DataRow = dt.NewRow()
                                BuildSlotRow(dr, dtRow, currDate)
                                If Not dr.IsNull(0) Then dt.Rows.Add(dtRow)
                            End If

                        Next
                    Next


                    Dim qry = (From dr In dt.Rows
                               Group RoomID = dr("RoomID"), AvailableDate = dr("SlotDate"), SlotTime = dr("SlotTime"), Endoscopist = dr("Endoscopist"), RoomName = dr("RoomName"), Template = dr("Template"), Reserved = dr("Reserved"), SlotType = dr("SlotType"), DiaryId = dr("DiaryId"), ListSlotId = dr("ListSlotId") By SlotDate = dr("SlotDate") Into details = Group
                               Select SlotDate, details).ToList()

                    If qry.Count > 0 Then
                        AvailableSlotsResultsRepeater.DataSource = qry
                        AvailableSlotsResultsRepeater.DataBind()

                        For i As Integer = 0 To AvailableSlotsResultsRepeater.Items.Count - 1
                            Dim item As RepeaterItem = AvailableSlotsResultsRepeater.Items(i)
                            If Not item.ItemType = ListItemType.Item And Not item.ItemType = ListItemType.AlternatingItem Then Continue For

                            Dim childRepeater = CType(item.FindControl("SlotsRepeater"), Repeater)
                            Dim childGrid = CType(item.FindControl("SlotsRadGrid"), RadGrid)

                            Dim lblSlotDate = CType(item.FindControl("SlotDateLabel"), Label).Text

                            If searchFields.BreachDate.Date > Now.Date AndAlso CDate(lblSlotDate) > searchFields.BreachDate Then
                                CType(item.FindControl("SlotDateLabel"), Label).ForeColor = Drawing.Color.Red
                            End If


                            Dim qrySlots = qry.Where(Function(x) x.SlotDate = lblSlotDate).FirstOrDefault
                            Dim groupedSlots = (From q In qry.Where(Function(x) x.SlotDate = lblSlotDate).FirstOrDefault.details
                                                Group q.SlotType, q.Reserved By q.DiaryId, q.AvailableDate, q.SlotTime, q.Endoscopist, q.RoomID, q.RoomName, q.Template Into slotDetails = Group
                                                Let Reserved = If(slotDetails.Any(Function(x) x.Reserved = ""), "All", String.Join(", ", slotDetails.Select(Function(x) x.Reserved).Distinct))
                                                Select DiaryId, SlotTime, Endoscopist, RoomID, RoomName, AvailableDate, Template, Reserved, SlotType = String.Join(", ", slotDetails.Select(Function(x) x.SlotType).Distinct)).ToList()



                            childRepeater.DataSource = groupedSlots
                            childRepeater.DataBind()

                            For Each itm As RepeaterItem In childRepeater.Items
                                Dim diaryId = CInt(CType(itm.FindControl("DiaryIdHiddenField"), HiddenField).Value)
                                Dim rpt As Repeater = itm.FindControl("rptAvailableSlots")

                                Dim diarySlots = foundLists.AsEnumerable.Where(Function(x) x("DiaryId") = diaryId And x("AppointmentId") = 0 And
                                                                                        x("Locked") = False And
                                                                                       (x("ProcedureTypeId") = 0 Or searchFields.ProcedureTypes.Select(Function(y) y.ProcedureTypeID).Contains(x("ProcedureTypeId"))))

                                If diarySlots.Count = 0 Then
                                    'if not available slots for this date, hide the repeater and skip to the next
                                    rpt.Visible = False
                                Else
                                    rpt.DataSource = diarySlots.CopyToDataTable
                                    rpt.DataBind()
                                End If
                            Next
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

    Protected Sub CancelSearchButton_Click(sender As Object, e As EventArgs)

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

    Protected Sub SearchTrustRadComboBox_Loaded(sender As Object, e As EventArgs) Handles SearchTrustRadComboBox.SelectedIndexChanged
        If SearchTrustRadComboBox.SelectedValue = 0 Then
            SearchOperatingHospitalIdRadComboBox.DataSource = DataAdapter_Sch.GetAllSchedulerHospitals()
        Else
            SearchOperatingHospitalIdRadComboBox.DataSource = DataAdapter_Sch.GetSchedulerHospitals(SearchTrustRadComboBox.SelectedValue)
        End If
        SearchOperatingHospitalIdRadComboBox.DataBind()
        'SearchOperatingHospitalIdRadComboBox.Items(SearchOperatingHospitalIdRadComboBox.FindItemIndexByValue(OperatingHospitalID)).Checked = True
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
            BookSlotRadButton.Attributes("onclick") = String.Format("return BookSlot({0},'{1}',{2},{3},{4},'{5}',{6},{7},{8},{9});", diaryId, DataBinder.Eval(e.Item.DataItem, "StartDate"), DataBinder.Eval(e.Item.DataItem, "RoomId"), DataBinder.Eval(e.Item.DataItem, "ProcedureTypeId"), DataBinder.Eval(e.Item.DataItem, "StatusId"), mode, DataBinder.Eval(e.Item.DataItem, "OperatingHospitalId"), DataBinder.Eval(e.Item.DataItem, "SlotDuration"), DataBinder.Eval(e.Item.DataItem, "SlotPoints"), DataBinder.Eval(e.Item.DataItem, "ListSlotId"))
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
                'Dim RoomID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoomID")
                'RoomsDropdown.SelectedValue = RoomID
                'ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)

                'ListRadScheduler.SelectedView = SchedulerViewType.DayView
                'ListRadScheduler.SelectedDate = DateTime.Parse(e.CommandArgument)
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

    Protected Sub WaitListGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim da As New DataAccess_Sch
        Dim ids = ""
        For Each item As RadComboBoxItem In cboOperatingHospitals.Items
            If item.Checked Then
                ids += item.Value.ToString() + ","
            End If
        Next
        If ids.EndsWith(",") Then
            ids = ids.TrimEnd(","c)
        End If
        ids = ids.TrimEnd()
        Dim waitList = da.GetWaitlistPatientsForWBookFromWaitList(ids)
        Dim waitlistPatients = waitList.AsEnumerable.Where(Function(x) Not x.IsNull("AdmissionTypeId") AndAlso x("AdmissionTypeId") = 1)
        If waitlistPatients.Count > 0 Then
            WaitListGrid.DataSource = waitlistPatients.CopyToDataTable
        Else
            WaitListGrid.DataSource = Nothing
        End If
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

    Protected Sub btnSearchSlotFromWorklist_Click(sender As Object, e As EventArgs)
        Dim waitlistId = WaitListGrid.MasterTableView.DataKeyValues(WaitListGrid.SelectedIndexes(0))("WaitingListId")
        Dim dataKeyValues = WaitListGrid.MasterTableView.DataKeyValues(WaitListGrid.SelectedIndexes(0))

        Dim BookFromWaitListOrderId = WaitListGrid.MasterTableView.DataKeyValues(WaitListGrid.SelectedIndexes(0))("OrderId")
        Session("BookFromWaitListOrderId") = BookFromWaitListOrderId

        searchSlotFromList(waitlistId, dataKeyValues)
    End Sub

    Protected Sub btnSearchSlotFromOrder_Click(sender As Object, e As EventArgs)
        Dim waitlistId = OrdersRadGrid.MasterTableView.DataKeyValues(OrdersRadGrid.SelectedIndexes(0))("WaitingListId")
        Dim dataKeyValues = OrdersRadGrid.MasterTableView.DataKeyValues(OrdersRadGrid.SelectedIndexes(0))
        searchSlotFromList(waitlistId, dataKeyValues)
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

    Protected Sub btnMoveToWorklist_Click(sender As Object, e As EventArgs)
        Dim da As New DataAccess_Sch
        Dim orderId = OrdersRadGrid.MasterTableView.DataKeyValues(OrdersRadGrid.SelectedIndexes(0))("WaitingListId")
        If orderId > 0 Then
            da.MoveOrderToWaitlist(orderId)
            LoadWaitlistGrids()
        End If
    End Sub


End Class