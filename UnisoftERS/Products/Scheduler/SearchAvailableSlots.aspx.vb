Imports Telerik.Web.UI

Public Class SearchAvailableSlots
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    'Protected Sub SearchButton_Click(sender As Object, e As EventArgs)
    '    Try
    '        'reset divs

    '        Dim searchFields As New Products_Scheduler.SearchFields

    '        searchFields.Endo = ""
    '        searchFields.Gender = "" 'n
    '        searchFields.ReferalDate = ReferalDateDatePicker.SelectedDate 'n/a
    '        searchFields.BreachDate = BreachDateDatePicker.SelectedDate 'y
    '        searchFields.SearchStartDate = SearchDateDatePicker.SelectedDate 'y
    '        searchFields.Slots = New Dictionary(Of Integer, String) 'y
    '        searchFields.SearchDays = New List(Of Products_Scheduler.SearchDays) 'filter on return
    '        searchFields.GIProcedure = True 'y
    '        searchFields.ReservedSlotsOnly = False 'y
    '        searchFields.ProcedureTypes = New List(Of Products_Scheduler.SearchProcedure) 'y
    '        searchFields.SlotLength = LengthOfSlotsNumericTextbox.Value 'y
    '        searchFields.NonGIProcedureType = Nothing 'n
    '        searchFields.NonGIDiagnostic = False 'info needed
    '        searchFields.NonGITherapeutic = False 'info needed

    '        Dim sProcedureTypesString As String = ""
    '        Dim sSlotTypesString As String = ""
    '        Dim sDaysString As String = ""

    '        For Each itm As RadComboBoxItem In SearchEndoscopistDropdown.CheckedItems
    '            searchFields.Endo = searchFields.Endo & IIf(searchFields.Endo = Nothing, itm.Value, "," & itm.Value)
    '        Next

    '        If Not EndoscopistGenderRadioButtonList.SelectedValue = "0" Then
    '            searchFields.Gender = EndoscopistGenderRadioButtonList.SelectedValue
    '        End If

    '        For Each itm As ListItem In IncludedSlotsCheckBoxList.Items
    '            If itm.Selected Or AllSlotsCheckBox.Checked Then
    '                searchFields.Slots.Add(itm.Value.ToString(), itm.Text)
    '            End If
    '        Next

    '        If MondayCheckBox.Checked Then
    '            Dim searchDays As New Products_Scheduler.SearchDays
    '            With searchDays
    '                .Day = DayOfWeek.Monday
    '                .Morning = MondayMorningCheckBox.Checked
    '                .Afternoon = MondayAfternoonCheckBox.Checked
    '                .Evening = MondayEveningCheckBox.Checked
    '            End With
    '            searchFields.SearchDays.Add(searchDays)
    '            sDaysString += "Mon"

    '            If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
    '                Dim tod As New List(Of String)
    '                If searchDays.Morning Then tod.Add("am")
    '                If searchDays.Afternoon Then tod.Add("pm")
    '                If searchDays.Evening Then tod.Add("ev")
    '                sDaysString += " (" & String.Join("/", tod) & ")"
    '            End If
    '            sDaysString += ", "
    '        End If
    '        If TuesdayCheckBox.Checked Then
    '            Dim searchDays As New Products_Scheduler.SearchDays
    '            With searchDays
    '                .Day = DayOfWeek.Tuesday
    '                .Morning = TuesdayMorningCheckBox.Checked
    '                .Afternoon = TuesdayAfternoonCheckBox.Checked
    '                .Evening = TuesdayEveningCheckBox.Checked
    '            End With
    '            searchFields.SearchDays.Add(searchDays)
    '            sDaysString += "Tue"

    '            If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
    '                Dim tod As New List(Of String)
    '                If searchDays.Morning Then tod.Add("am")
    '                If searchDays.Afternoon Then tod.Add("pm")
    '                If searchDays.Evening Then tod.Add("ev")
    '                sDaysString += " (" & String.Join("/", tod) & ")"
    '            End If
    '            sDaysString += ", "
    '        End If
    '        If WednesdayCheckBox.Checked Then
    '            Dim searchDays As New Products_Scheduler.SearchDays
    '            With searchDays
    '                .Day = DayOfWeek.Wednesday
    '                .Morning = WednesdayMorningCheckBox.Checked
    '                .Afternoon = WednesdayAfternoonCheckBox.Checked
    '                .Evening = WednesdayEveningCheckBox.Checked
    '            End With
    '            searchFields.SearchDays.Add(searchDays)
    '            sDaysString += "Wed"

    '            If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
    '                Dim tod As New List(Of String)
    '                If searchDays.Morning Then tod.Add("am")
    '                If searchDays.Afternoon Then tod.Add("pm")
    '                If searchDays.Evening Then tod.Add("ev")
    '                sDaysString += " (" & String.Join("/", tod) & ")"
    '            End If
    '            sDaysString += ", "
    '        End If
    '        If ThursdayCheckBox.Checked Then
    '            Dim searchDays As New Products_Scheduler.SearchDays
    '            With searchDays
    '                .Day = DayOfWeek.Thursday
    '                .Morning = ThursdayMorningCheckBox.Checked
    '                .Afternoon = ThursdayAfternoonCheckBox.Checked
    '                .Evening = ThursdayEveningCheckBox.Checked
    '            End With
    '            searchFields.SearchDays.Add(searchDays)
    '            sDaysString += "Thu"

    '            If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
    '                Dim tod As New List(Of String)
    '                If searchDays.Morning Then tod.Add("am")
    '                If searchDays.Afternoon Then tod.Add("pm")
    '                If searchDays.Evening Then tod.Add("ev")
    '                sDaysString += " (" & String.Join("/", tod) & ")"
    '            End If
    '            sDaysString += ", "
    '        End If
    '        If FridayCheckBox.Checked Then
    '            Dim searchDays As New Products_Scheduler.SearchDays
    '            With searchDays
    '                .Day = DayOfWeek.Friday
    '                .Morning = FridayMorningCheckBox.Checked
    '                .Afternoon = FridayAfternoonCheckBox.Checked
    '                .Evening = FridayEveningCheckBox.Checked
    '            End With
    '            searchFields.SearchDays.Add(searchDays)
    '            sDaysString += "Fri"

    '            If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
    '                Dim tod As New List(Of String)
    '                If searchDays.Morning Then tod.Add("am")
    '                If searchDays.Afternoon Then tod.Add("pm")
    '                If searchDays.Evening Then tod.Add("ev")
    '                sDaysString += " (" & String.Join("/", tod) & ")"
    '            End If
    '            sDaysString += ", "
    '        End If
    '        If SaturdayCheckBox.Checked Then
    '            Dim searchDays As New Products_Scheduler.SearchDays
    '            With searchDays
    '                .Day = DayOfWeek.Saturday
    '                .Morning = SaturdayMorningCheckBox.Checked
    '                .Afternoon = SaturdayAfternoonCheckBox.Checked
    '                .Evening = SaturdayEveningCheckBox.Checked
    '            End With
    '            searchFields.SearchDays.Add(searchDays)
    '            sDaysString += "Sat"

    '            If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
    '                Dim tod As New List(Of String)
    '                If searchDays.Morning Then tod.Add("am")
    '                If searchDays.Afternoon Then tod.Add("pm")
    '                If searchDays.Evening Then tod.Add("ev")
    '                sDaysString += " (" & String.Join("/", tod) & ")"
    '            End If
    '            sDaysString += ", "
    '        End If
    '        If SundayCheckBox.Checked Then
    '            Dim searchDays As New Products_Scheduler.SearchDays
    '            With searchDays
    '                .Day = DayOfWeek.Sunday
    '                .Morning = SundayMorningCheckBox.Checked
    '                .Afternoon = SundayAfternoonCheckBox.Checked
    '                .Evening = SundayEveningCheckBox.Checked
    '            End With
    '            searchFields.SearchDays.Add(searchDays)
    '            sDaysString += "Sun"

    '            If Not searchDays.Morning Or Not searchDays.Afternoon Or Not searchDays.Evening Then
    '                Dim tod As New List(Of String)
    '                If searchDays.Morning Then tod.Add("am")
    '                If searchDays.Afternoon Then tod.Add("pm")
    '                If searchDays.Evening Then tod.Add("ev")
    '                sDaysString += " (" & String.Join("/", tod) & ")"
    '            End If
    '            sDaysString += ", "
    '        End If

    '        searchFields.GIProcedure = CBool(SearchGIProcedureRadioButtons.SelectedValue)
    '        searchFields.ReservedSlotsOnly = ShowOnlyReservedSlotsCheckBox.Checked
    '        searchFields.SlotLength = LengthOfSlotsNumericTextbox.Value 'TODO: ask about this...

    '        Dim lTherapeuticTypes As New List(Of Integer)

    '        If searchFields.GIProcedure Then
    '            For Each item As RepeaterItem In rptProcedureTypes.Items
    '                If item.ItemType = ListItemType.Item Or item.ItemType = ListItemType.AlternatingItem Then
    '                    Dim DiagnosticCheckBox As CheckBox = item.FindControl("DiagnosticProcedureTypesCheckBox")
    '                    Dim TherapeuticCheckBox As CheckBox = item.FindControl("TherapeuticProcedureTypesCheckBox")

    '                    If DiagnosticCheckBox.Checked Or TherapeuticCheckBox.Checked Then
    '                        Dim procedureTypeID = CInt(CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value)
    '                        Dim procedureType = CType(item.FindControl("ProcedureTypeHiddenField"), HiddenField).Value
    '                        Dim searchProcedure As New Products_Scheduler.SearchProcedure
    '                        With searchProcedure
    '                            .ProcedureTypeID = procedureTypeID
    '                            .ProcedureType = procedureType
    '                            .Diagnostic = DiagnosticCheckBox.Checked
    '                            .Therapeutic = TherapeuticCheckBox.Checked
    '                            If Session("TherapeuticTypes_" & procedureTypeID) IsNot Nothing Then
    '                                .TherapeuticTypes = CType(Session("TherapeuticTypes_" & procedureTypeID), List(Of Integer))
    '                                lTherapeuticTypes.AddRange(.TherapeuticTypes) 'TODO: Sort this out.......... things have changed now, need another way around this!
    '                            End If
    '                        End With

    '                        searchFields.ProcedureTypes.Add(searchProcedure)
    '                    End If
    '                End If
    '            Next
    '        Else
    '            If nonGIProceduresDropdown.SelectedIndex > 0 Then
    '                searchFields.NonGIProcedureType = nonGIProceduresDropdown.SelectedValue
    '            End If

    '            searchFields.NonGIDiagnostic = DiagnosticsRadioButton.Checked
    '            searchFields.NonGITherapeutic = TherapeuticRadioButton.Checked
    '        End If

    '        If Not searchFields.ReservedSlotsOnly Then searchFields.ProcedureTypes.Add(New Products_Scheduler.SearchProcedure With {.ProcedureTypeID = 0, .Diagnostic = True, .Therapeutic = True})

    '        Dim da As New DataAccess_Sch
    '        Dim procTypes = String.Join(",", searchFields.ProcedureTypes.Select(Function(x) x.ProcedureTypeID).ToArray())

    '        Dim slots = String.Join(",", searchFields.Slots.Keys.ToArray())
    '        Dim results = da.SearchAvailableSlots(searchFields, OperatingHospitalID, lTherapeuticTypes) 'da.GetAvailableSlots(searchFields.SearchStartDate, searchFields.BreachDate, OperatingHospitalID,
    '        '                                   procTypes, String.Join(",", lTherapeuticTypes), slots, searchFields.Endo, searchFields.SlotLength, searchFields.GIProcedure)
    '        If results.Rows.Count > 0 Then
    '            NoResultsDiv.Visible = False

    '            'Get Endo rules to filter results by
    '            Dim endosForProc As New List(Of Integer)
    '            Dim endosForTherapType As New List(Of Integer)

    '            If searchFields.ProcedureTypes.Any(Function(x) x.Diagnostic) Then
    '                endosForProc = da.GetEndoscopistsByProcedureTypes(searchFields.ProcedureTypes.Select(Function(x) x.ProcedureTypeID).ToList)
    '                If endosForProc.Count > 0 Then
    '                    'only return rows where matched endo is present
    '                    results = results.AsEnumerable.Where(Function(x) endosForProc.Contains(x("EndoId"))).CopyToDataTable()
    '                Else
    '                    'only return rows where no endo is specified
    '                    results = results.AsEnumerable.Where(Function(x) x("EndoId") = 0).CopyToDataTable

    '                End If
    '            End If

    '            If searchFields.ProcedureTypes.Any(Function(x) x.TherapeuticTypes IsNot Nothing) Then
    '                endosForTherapType = da.GetEndoscopistsByProcedureTherapeutics(searchFields.ProcedureTypes.Select(Function(x) x.TherapeuticTypes))
    '                If endosForTherapType.Count > 0 Then
    '                    results = results.AsEnumerable.Where(Function(x) x.IsNull("EndoId") Or endosForTherapType.Contains(x("EndoId"))).CopyToDataTable
    '                End If
    '            End If

    '            'get booked slots in order to remove from available slots
    '            Dim dtAppointments = da.GetBookedSlots(searchFields.SearchStartDate, searchFields.BreachDate)

    '            Dim dt As New DataTable
    '            dt.Columns.Add("SlotDate")
    '            dt.Columns.Add("SlotTime")
    '            dt.Columns.Add("Endoscopist") 'endoscopist
    '            dt.Columns.Add("RoomName") 'room name
    '            dt.Columns.Add("RoomID") 'room name
    '            dt.Columns.Add("Template") 'template
    '            dt.Columns.Add("SlotType") 'slot type
    '            dt.Columns.Add("Reserved") 'reserved
    '            dt.Columns.Add("DiaryId") 'diaryId

    '            For i = 0 To DateDiff(DateInterval.Day, searchFields.SearchStartDate, searchFields.BreachDate)
    '                Dim currDate = searchFields.SearchStartDate.AddDays(i)
    '                If currDate.Date <= Now.Date Then Continue For
    '                If searchFields.SearchDays.Count > 0 And Not searchFields.SearchDays.Select(Function(x) x.Day).Contains(currDate.DayOfWeek) Then Continue For

    '                For Each dr As DataRow In results.Rows 'loops through diaries/slot for the current day
    '                    Dim dtGenderSpecificLists As New List(Of ERS.Data.ERS_SCH_GenderList)
    '                    If Not String.IsNullOrWhiteSpace(searchFields.Gender) Then dtGenderSpecificLists = da.GetGenderLists(CInt(dr("DiaryId")))

    '                    If dtGenderSpecificLists.Any(Function(x) x.DiaryId = CInt(dr("DiaryId")) And x.ListDate.Date = currDate.Date And ((searchFields.Gender.ToLower = "m" And Not x.Male) Or (searchFields.Gender.ToLower = "f" And Not x.Female))) Then Continue For
    '                    If searchFields.SearchDays IsNot Nothing Then
    '                        'check time of day filter...

    '                        Dim skip As Boolean = False

    '                        If searchFields.SearchDays.Any(Function(x) x.Day = currDate.DayOfWeek And x.Morning = False) Then
    '                            If (CDate(dr("DiaryStart")).TimeOfDay < New TimeSpan(12, 0, 0) And CDate(dr("End")).TimeOfDay <= New TimeSpan(12, 0, 0)) Then 'is a morning only slot
    '                                skip = True
    '                            End If
    '                        End If

    '                        If searchFields.SearchDays.Any(Function(x) x.Day = currDate.DayOfWeek And x.Afternoon = False) Then
    '                            If (CDate(dr("DiaryStart")).TimeOfDay >= New TimeSpan(12, 0, 0) And CDate(dr("End")).TimeOfDay <= New TimeSpan(17, 0, 0)) Then 'is an afternoon only slot
    '                                skip = True
    '                            End If
    '                        End If

    '                        If searchFields.SearchDays.Any(Function(x) x.Day = currDate.DayOfWeek And x.Evening = False) Then
    '                            If (CDate(dr("DiaryStart")).TimeOfDay >= New TimeSpan(17, 0, 0) And CDate(dr("End")).TimeOfDay >= New TimeSpan(17, 0, 0)) Then
    '                                skip = True
    '                            End If
    '                        End If

    '                        If skip Then Continue For
    '                    End If

    '                    If dr.IsNull("RecurrenceRule") Then
    '                        If CDate(dr("DiaryStart")).ToShortDateString = currDate.ToShortDateString Then
    '                            Dim dtRow As DataRow = dt.NewRow()
    '                            BuildSlotRow(dr, dtRow, currDate, dtAppointments)
    '                            If Not dr.IsNull(0) Then dt.Rows.Add(dtRow)
    '                        End If
    '                    Else
    '                        Dim recurrentRule = dr("RecurrenceRule").ToString().Substring(dr("RecurrenceRule").ToString().IndexOf("RRULE:") + 6)
    '                        recurrentRule = recurrentRule.Substring(0, recurrentRule.IndexOf(vbCrLf))

    '                        Dim lst = recurrentRule.Split(";")
    '                        Dim rules As New Dictionary(Of String, String)
    '                        For Each l In lst
    '                            If l.Contains("=") Then rules.Add(l.Split("=")(0), l.Split("=")(1))
    '                        Next

    '                        Dim days = rules("BYDAY").Split(",").ToList()
    '                        Dim interval = rules("INTERVAL")

    '                        Select Case rules("FREQ")
    '                            Case "DAILY"
    '                                If days.Contains(currDate.DayOfWeek.ToString().ToUpper().Substring(0, 2)) Then
    '                                    Dim dtRow As DataRow = dt.NewRow()
    '                                    BuildSlotRow(dr, dtRow, currDate, dtAppointments)
    '                                    If Not dtRow.IsNull(0) Then dt.Rows.Add(dtRow)
    '                                End If
    '                            Case "WEEKLY"
    '                                If days.Contains(currDate.DayOfWeek.ToString().ToUpper().Substring(0, 2)) Then
    '                                    If CInt((DateDiff(DateInterval.Day, CDate(dr("DiaryStart")), currDate) / 7)) Mod interval = 0 Then
    '                                        Dim dtRow As DataRow = dt.NewRow()
    '                                        BuildSlotRow(dr, dtRow, currDate, dtAppointments)
    '                                        If Not dtRow.IsNull(0) Then dt.Rows.Add(dtRow)
    '                                    End If
    '                                End If
    '                            Case "MONTHLY"
    '                                Dim intervalPosition = rules("BYSETPOS")

    '                                'X weekend day of every month can only be a sunday if X = 1. otherwise will be a Saturday. So removing sunday to save confusion if day check below
    '                                If intervalPosition <> 1 And rules("BYDAY") = "SA,SU" Then days.Remove("SU")

    '                                If days.Contains(currDate.DayOfWeek.ToString().ToUpper().Substring(0, 2)) Then
    '                                    Select Case intervalPosition
    '                                        Case 1, 2, 3, 4
    '                                            'check if is 1st occurance
    '                                            If DateAdd(DateInterval.Day, -(7 * intervalPosition), currDate).AddDays(5).Day = 1 Then '(calculation for 2nd tuesday of every month)
    '                                                Dim dtRow As DataRow = dt.NewRow()
    '                                                BuildSlotRow(dr, dtRow, currDate, dtAppointments)
    '                                                If Not dtRow.IsNull(0) Then dt.Rows.Add(dtRow)
    '                                            End If
    '                                        Case -1
    '                                            'check if is last day of the month (if tomorrow is a new month)
    '                                            If DateAdd(DateInterval.Day, 1, currDate).Month > currDate.Month Then
    '                                                Dim dtRow As DataRow = dt.NewRow()
    '                                                BuildSlotRow(dr, dtRow, currDate, dtAppointments)
    '                                                If Not dtRow.IsNull(0) Then dt.Rows.Add(dtRow)
    '                                            End If
    '                                    End Select
    '                                End If

    '                            'interval: 1st, 2nd, 3rd, 4th, last (-1)
    '                            'interval2: day, weekday, weekend day, sun-sat
    '                            Case "YEARLY"
    '                                'interval: 1st, 2nd, 3rd, 4th, last
    '                                'interval 2: day, weekday, weekend day, sun-sat
    '                                'interval 3: month 
    '                        End Select
    '                    End If
    '                Next
    '            Next

    '            Dim qry = (From dr In dt.Rows
    '                       Group RoomID = dr("RoomID"), AvailableDate = dr("SlotDate"), SlotTime = dr("SlotTime"), Endoscopist = dr("Endoscopist"), RoomName = dr("RoomName"), Template = dr("Template"), Reserved = dr("Reserved"), SlotType = dr("SlotType"), DiaryId = dr("DiaryId") By SlotDate = dr("SlotDate") Into details = Group
    '                       Select SlotDate, details).ToList()

    '            If qry.Count > 0 Then
    '                AvailableSlotsResultsRepeater.DataSource = qry
    '                AvailableSlotsResultsRepeater.DataBind()

    '                For i As Integer = 0 To AvailableSlotsResultsRepeater.Items.Count - 1
    '                    Dim item As RepeaterItem = AvailableSlotsResultsRepeater.Items(i)
    '                    If Not item.ItemType = ListItemType.Item And Not item.ItemType = ListItemType.AlternatingItem Then Continue For

    '                    'Dim childGrid = CType(item.FindControl("rptSlots"), Repeater)
    '                    Dim childGrid = CType(item.FindControl("SlotsRadGrid"), RadGrid)

    '                    Dim lblSlotDate = CType(item.FindControl("SlotDateLabel"), Label).Text
    '                    Dim qrySlots = qry.Where(Function(x) x.SlotDate = lblSlotDate).FirstOrDefault

    '                    Dim groupedSlots = (From q In qry.Where(Function(x) x.SlotDate = lblSlotDate).FirstOrDefault.details
    '                                        Group q.SlotType, q.Reserved By q.DiaryId, q.AvailableDate, q.SlotTime, q.Endoscopist, q.RoomID, q.RoomName, q.Template Into slotDetails = Group
    '                                        Let Reserved = If(slotDetails.Any(Function(x) x.Reserved = ""), "All", String.Join(", ", slotDetails.Select(Function(x) x.Reserved).Distinct))
    '                                        Select DiaryId, SlotTime, Endoscopist, RoomID, RoomName, AvailableDate, Template, Reserved, SlotType = String.Join(", ", slotDetails.Select(Function(x) x.SlotType).Distinct)).ToList()


    '                    childGrid.DataSource = groupedSlots
    '                    childGrid.DataBind()
    '                Next

    '                PageSearchFields = searchFields
    '            Else
    '                NoResultsDiv.Visible = True
    '            End If
    '        Else
    '            AvailableSlotsResultsRepeater.DataSource = Nothing
    '            AvailableSlotsResultsRepeater.DataBind()
    '            NoResultsDiv.Visible = True
    '        End If
    '        divResults.Visible = True
    '        divFilters.Visible = False
    '        SearchCriteriaProcedureGITypeLabel.Text = SearchGIProcedureRadioButtons.SelectedItem.Text

    '        'build criteria table for results section
    '        SCEndoscopistLabel.Text = If(String.IsNullOrWhiteSpace(searchFields.Endo), "All", If(SearchEndoscopistDropdown.CheckedItems.Count = 1, SearchEndoscopistDropdown.CheckedItems(0).Text, SearchEndoscopistDropdown.CheckedItems(0).Text & " + " & SearchEndoscopistDropdown.CheckedItems.Count - 1 & " more"))
    '        SCProceduresLabel.Text = If(searchFields.ProcedureTypes.Count = 0, "All", String.Join(",", searchFields.ProcedureTypes.Where(Function(x) x.ProcedureTypeID > 0).Select(Function(x) x.ProcedureType)))
    '        SCSlotTypeLabel.Text = If(AllSlotsCheckBox.Checked, "All", String.Join(",", searchFields.Slots.Values.ToArray()))
    '        SCGenderLabel.Text = If(String.IsNullOrWhiteSpace(searchFields.Gender), "All", If(searchFields.Gender.ToLower = "f", "Female", "Male"))
    '        SCReferralDateLabel.Text = searchFields.ReferalDate
    '        SCBreachDateLabel.Text = searchFields.BreachDate
    '        SCSearchFromDateLabel.Text = searchFields.SearchStartDate
    '        SCDaysLabel.Text = If(String.IsNullOrWhiteSpace(sDaysString), "All", sDaysString.Remove(sDaysString.Trim().Length - 1))

    '    Catch ex As Exception
    '        Dim errorLogRef As String
    '        errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while seartching for available slots.", ex)

    '        Utilities.SetErrorNotificationStyle(SearchWindowRadNotification, errorLogRef, "There was a displaying search results.")
    '        SearchWindowRadNotification.Show()
    '    End Try
    'End Sub


    'Private Sub BuildSlotRow(ByVal dr As DataRow, ByRef newRow As DataRow, currDate As DateTime, dtAppointments As DataTable, Optional FilteredGender As String = "")
    '    Dim todaysBookings = (From b In dtAppointments.AsEnumerable
    '                          Let currentDate = currDate.ToShortDateString()
    '                          Let appointmentDate = CDate(b.Field(Of String)("AppointmentDate"))
    '                          Where appointmentDate = currentDate And b.Field(Of Integer)("RoomID") = dr("RoomId") And b.Field(Of Integer)("DiaryId") = dr("DiaryId")
    '                          Select b).ToList()


    '    Dim slotDateTime = currDate.ToShortDateString & " " & CDate(dr("DiaryStart")).ToShortTimeString()

    '    If todaysBookings.Count > 0 Then
    '        'check if bookings take up entire slot
    '        Dim minStartTime = todaysBookings.OrderBy(Function(x) x("AppointmentStart")).FirstOrDefault.Field(Of DateTime)("AppointmentStart")
    '        Dim maxStartTime = todaysBookings.OrderByDescending(Function(x) x("AppointmentEnd")).FirstOrDefault.Field(Of DateTime)("AppointmentEnd")
    '        If CDate(minStartTime).ToShortTimeString() = CDate(dr("DiaryStart")).ToShortTimeString() AndAlso CDate(maxStartTime).ToShortTimeString() >= CDate(dr("End")).ToShortTimeString() Then
    '            Exit Sub
    '        End If
    '    End If

    '    newRow("SlotDate") = currDate.ToString("ddd dd MMM yyyy")
    '    newRow("SlotTime") = CDate(dr("DiaryStart")).ToShortTimeString() & "-" & CDate(dr("End")).ToShortTimeString()
    '    newRow("Endoscopist") = dr("Endoscopist")
    '    newRow("RoomName") = dr("RoomName")
    '    newRow("RoomID") = dr("RoomId")
    '    newRow("Template") = dr("ListName")
    '    newRow("SlotType") = dr("SlotType")
    '    newRow("Reserved") = dr("ProcedureType")
    '    newRow("DiaryId") = dr("DiaryId")
    'End Sub

    'Protected Sub rptProcedureTypes_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
    '    'clear any previously created sessions (this gets created in the therapeutic types window on save and close
    '    If e.Item.DataItem IsNot Nothing Then
    '        Dim dataRow = DirectCast(e.Item.DataItem, DataRowView)
    '        Dim procTypeID = dataRow.Row("ProcedureTypeID")
    '        Session("TherapeuticType_" & procTypeID) = Nothing

    '        'hide checkbox for ERCP diagnostic
    '        If CBool(dataRow("SchedulerDiagnostic")) = False Then
    '            CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Visible = False
    '        End If

    '        If CBool(dataRow("SchedulerTherapeutic")) = False Then
    '            CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Visible = False
    '        End If
    '    End If
    'End Sub

    'Protected Sub ChangeSearchCriteriaButton_Click(sender As Object, e As EventArgs)
    '    divResults.Visible = False
    '    divFilters.Visible = True
    'End Sub

    'Protected Sub SlotsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
    '    Try
    '        If e.CommandName = "GoToDate" Then
    '            Dim RoomID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoomID")
    '            RoomsDropdown.SelectedValue = RoomID
    '            ChangeRoomButton_Click(ChangeRoomButton, New EventArgs)

    '            ListRadScheduler.SelectedView = SchedulerViewType.DayView
    '            ListRadScheduler.SelectedDate = DateTime.Parse(e.CommandArgument)
    '        ElseIf e.CommandName = "SelectSlot" Then
    '            Dim diaryId = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiaryId")
    '            Dim slotDate = CDate(e.CommandArgument).ToShortDateString
    '            BookingSlotDateLabel.Text = "Choose slot for " & CDate(e.CommandArgument).ToLongDateString

    '            Dim da As New DataAccess_Sch
    '            Dim dtSlots = (From ds In da.GetDiarySlots(diaryId, slotDate, OperatingHospitalID).AsEnumerable
    '                           Where ds(10) = ""
    '                           Let StartDate = CDate(slotDate & " " & CDate(ds(3)).ToShortTimeString)
    '                           Select New With {.Description = ds(1) & " " & ds(12),
    '                                            .RoomId = ds(6),
    '                                            StartDate,
    '                                            .DiaryId = ds(0)})


    '            ListSlotsRadGrid.DataSource = dtSlots
    '            ListSlotsRadGrid.DataBind()
    '            ScriptManager.RegisterStartupScript(Me.Page, Me.Page.GetType, "selectSlotWindow", "ShowBookingWindow();", True)
    '        End If
    '    Catch ex As Exception
    '        Dim errorLogRef As String
    '        errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on list schedules page.", ex)
    '        Utilities.SetErrorNotificationStyle(SearchWindowRadNotification, errorLogRef, "There is a problem with your request.")
    '        SearchWindowRadNotification.Show()
    '    End Try
    'End Sub


End Class