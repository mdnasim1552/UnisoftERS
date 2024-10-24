Public Class SchedulerClass

    Public Structure ListSlots
        Property DiaryId As String
        Property AppointmentId As String
        Property Subject As String
        Property SlotColor As String
        Property DiaryStart As DateTime
        Property DiaryEnd As DateTime
        Property SlotDuration As Integer
        Property UserID As Integer
        Property RoomID As Integer
        Property ListRulesID As Integer
        Property ListSlotId As Integer
        Property Description As String
        Property ProcedureTypeID As Integer
        Property Points As Decimal
        Property StatusId As String
        Property StatusCode As String
        Property SlotType As String
        Property Notes As String
        Property GeneralInfo As String
        Property ParentId As Integer
        Property EndoscopistId As Integer
        Property EndoscopistName As String
        Property SlotSubject As String
        Property OperatingHospitalId As Integer
        Property Locked As Boolean
    End Structure

    Private _dtListSlots As DataTable
    Public Property dtDiaries() As DataTable
        Get
            If _dtListSlots Is Nothing Then
                _dtListSlots = New DataTable
                _dtListSlots.Columns.Add("DiaryId", GetType(String))
                _dtListSlots.Columns.Add("AppointmentId", GetType(String))
                _dtListSlots.Columns.Add("Subject", GetType(String))
                _dtListSlots.Columns.Add("SlotColor", GetType(String))
                _dtListSlots.Columns.Add("DiaryStart", GetType(DateTime))
                _dtListSlots.Columns.Add("DiaryEnd", GetType(DateTime))
                _dtListSlots.Columns.Add("SlotDuration", GetType(Integer))
                _dtListSlots.Columns.Add("UserID", GetType(Integer))
                _dtListSlots.Columns.Add("RoomID", GetType(Integer))
                _dtListSlots.Columns.Add("ListRulesID", GetType(Integer))
                _dtListSlots.Columns.Add("ListSlotId", GetType(Integer))
                _dtListSlots.Columns.Add("Description", GetType(String))
                _dtListSlots.Columns.Add("ProcedureTypeID", GetType(Integer))
                _dtListSlots.Columns.Add("Points", GetType(Decimal))
                _dtListSlots.Columns.Add("StatusId", GetType(String))
                _dtListSlots.Columns.Add("StatusCode", GetType(String))
                _dtListSlots.Columns.Add("SlotType", GetType(String))
                _dtListSlots.Columns.Add("Notes", GetType(String))
                _dtListSlots.Columns.Add("GeneralInfo", GetType(String))
                _dtListSlots.Columns.Add("ParentId", GetType(Integer))
                _dtListSlots.Columns.Add("EndoscopistId", GetType(Integer))
                _dtListSlots.Columns.Add("EndoscopistName", GetType(String))
                _dtListSlots.Columns.Add("SlotSubject", GetType(String))
                _dtListSlots.Columns.Add("OperatingHospitalId", GetType(Integer))
                _dtListSlots.Columns.Add("Locked", GetType(Boolean))
            End If

            Return _dtListSlots
        End Get
        Set(ByVal value As DataTable)
            _dtListSlots = value
        End Set
    End Property

    Public Function BuildListSlots(dt As DataTable)
        'group into lists
        Dim diaryLists = (From d In dt.AsEnumerable
                          Order By d("DiaryId"), d("ListSlotId")
                          Group By ListRuleID = d("ListRulesId"), RoomID = d("RoomID"), UserID = d("UserID"), DiaryID = d("DiaryId"), ListName = d("ListName"), DiaryStartDate = d("DiaryStart"), DiaryEndDate = d("DiaryEnd")
                                      Into g = Group
                          Select ListRuleID, RoomID, UserID, DiaryID, ListName, DiaryStartDate, DiaryEndDate, ListSlots = g.ToList()).ToList()



        For Each lst In diaryLists
            Dim listStart As DateTime = CDate(lst.DiaryStartDate)
            Dim listEnd As DateTime = CDate(lst.DiaryEndDate)
            Dim listName As String = listStart.ToShortTimeString & " - " & lst.ListName

            Dim slotStart As DateTime = CDate(lst.DiaryStartDate)
            Dim slotEnd As DateTime = Nothing
            Dim slotDuration As Integer = 0
            Dim extraDuration As Integer = 0
            Dim iDiaryId = CInt(lst.DiaryID)


            'get individual slots
            For Each dr In lst.ListSlots
                'add to datatable
                Dim newRow = dtDiaries.NewRow

                Dim procTypeId As Integer = dr("ProcedureTypeId")
                Dim slotSubject = slotStart.ToShortTimeString & " - " & dr("Subject")

                slotDuration = CInt(dr("Minutes"))
                slotEnd = slotStart.AddMinutes(slotDuration)

                If Not dr.IsNull("AppointmentId") AndAlso CInt(dr("AppointmentId")) > 0 Then
                    'check if start time is directly after the last slot. If not create a new slot and add
                    'If CDate(dr("AppointmentStart")) > slotStart Then
                    slotStart = CDate(dr("AppointmentStart"))
                    slotEnd = CDate(dr("AppointmentEnd"))
                    slotDuration = DateDiff(DateInterval.Minute, slotStart, slotEnd)

                    'Dim newSlotPoint = 1

                    ''compare appointment with its slot. 
                    ''if points remain, extend this slot
                    ''if points have been reduced, create new slot
                    'newRow("DiaryId") = lst.DiaryID
                    'newRow("AppointmentId") = dr("AppointmentId")
                    'newRow("Subject") = slotSubject
                    'newRow("SlotColor") = dr("Forecolor")
                    'newRow("DiaryStart") = slotStart
                    'newRow("DiaryEnd") = slotEnd
                    'newRow("SlotDuration") = slotDuration
                    'newRow("Description") = slotSubject
                    'newRow("ProcedureTypeID") = 0
                    'newRow("StatusId") = dr("StatusId")
                    'newRow("StatusCode") = ""
                    'newRow("ListRulesID") = lst.ListRuleID
                    'newRow("ListSlotId") = dr("ListSlotId")
                    'newRow("UserID") = lst.UserID
                    'newRow("RoomID") = lst.RoomID
                    'newRow("Points") = dr("Points")
                    'newRow("SlotType") = If(dr("AppointmentId") = "0", "FreeSlot", "PatientBooking")
                    'newRow("Notes") = ""
                    'newRow("GeneralInfo") = ""
                    'newRow("EndoscopistId") = lst.UserID
                    'newRow("SlotSubject") = slotSubject
                    'newRow("OperatingHospitalId") = OperatingHospitalId
                    'newRow("Locked") = CBool(dr("Locked"))

                    'dtDiaries.Rows.Add(newRow)

                    'End If
                    'slotStart = CDate(dr("AppointmentStart"))
                    'slotEnd = CDate(dr("AppointmentEnd"))
                End If




                newRow("DiaryId") = lst.DiaryID
                newRow("AppointmentId") = dr("AppointmentId")
                newRow("Subject") = slotSubject
                newRow("SlotColor") = dr("Forecolor")
                newRow("DiaryStart") = slotStart
                newRow("DiaryEnd") = slotEnd
                newRow("SlotDuration") = CInt(dr("Minutes"))
                newRow("Description") = slotSubject
                newRow("ProcedureTypeID") = procTypeId
                newRow("StatusId") = dr("StatusId")
                newRow("StatusCode") = ""
                newRow("ListRulesID") = lst.ListRuleID
                newRow("ListSlotId") = dr("ListSlotId")
                newRow("UserID") = lst.UserID
                newRow("RoomID") = lst.RoomID
                newRow("Points") = dr("Points")
                newRow("SlotType") = If(dr("AppointmentId") = "0", "FreeSlot", "PatientBooking")
                newRow("Notes") = ""
                newRow("GeneralInfo") = ""
                newRow("EndoscopistId") = lst.UserID
                newRow("SlotSubject") = slotSubject
                newRow("OperatingHospitalId") = dr("OperatingHospitalId")
                newRow("Locked") = CBool(dr("Locked"))

                dtDiaries.Rows.Add(newRow)
                slotStart = slotEnd


            Next
        Next

        Return dtDiaries

    End Function
End Class
