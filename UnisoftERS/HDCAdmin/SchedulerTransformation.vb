Imports System.Data.SqlClient
Imports Telerik.Web.UI

Public Class CustomEx
    Inherits Exception

    Property ErrorObjectId As Integer
End Class
Public Class SchedulerTransformation
    'transform diaries where recurrence rule is not null
    'update appointments with the correct diaryid and list slot id



    Public Structure ListDiary
        Property NewDiaryId As Integer
        Property DiaryId As Integer
        Property Subject As String
        Property DiaryStart As DateTime
        Property DiaryEnd As DateTime
        Property UserId As Integer
        Property RoomId As Integer
        Property ListRulesId As Integer
        Property RecurrenceRule As String
        Property RecurrenceParentId As Integer
        Property OperatingHospitalId As Integer
        Property Training As Integer
        Property ListConsultantId As Integer
        Property ListGenderId As Integer
        Property ListNotes As String
        Property IsGi As Boolean
        Property Locked As Boolean
        Property RecurrenceFrequency As String
        Property RecurrenceCount As Integer
    End Structure

    Public Structure ListSlot
        Property ListSlotId As Integer
        Property StartTime As TimeSpan
        Property EndTime As TimeSpan
        Property Minutes As Integer
    End Structure

    Public Sub transformDiary(diaryId)
        Dim dtDiaries As DataTable = getDiary(diaryId)
        transform(dtDiaries)
    End Sub

    Public Sub transformAllDiaries()
        Dim dtDiaries As DataTable = getAllDiaries()
        transform(dtDiaries)
    End Sub
    Public Sub transform(dtDiaries As DataTable)
        Dim dtDiaryAppointments = getDiaryAppointments()
        'Dim dtListSlots = getListSlots()

        Dim ListDiaries As New List(Of ListDiary)

        For Each dr As DataRow In dtDiaries.Rows


            'do not continue if suppressed from date has passed
            If Not dr.IsNull("SuppressedFromDate") AndAlso CDate(dr("DiaryStart")) > CDate(dr("SuppressedFromDate")).Date.AddDays(1) Then
                Continue For
            End If

            'Single entry diaries
            If dr.IsNull("RecurrenceRule") Then
                'add diary
                Dim ld As New ListDiary
                With ld
                    .DiaryId = dr("DiaryId")
                    .Subject = dr("Subject")
                    .DiaryStart = dr("DiaryStart")
                    .DiaryEnd = dr("DiaryEnd")
                    .UserId = dr("UserId")
                    .RoomId = dr("RoomId")
                    .ListRulesId = dr("ListRulesId")
                    .OperatingHospitalId = dr("OperatingHospitalId")
                    .Training = dr("Training")
                    .ListConsultantId = If(Not dr.IsNull("ListConsultantId"), dr("ListConsultantId"), 0)
                    .ListGenderId = If(Not dr.IsNull("ListGenderId"), dr("ListGenderId"), getDiaryGender(.DiaryId, .DiaryStart))
                    .ListNotes = If(Not dr.IsNull("Notes"), dr("Notes"), getListNotes(.OperatingHospitalId, .RoomId, .DiaryStart))
                    .IsGi = True
                    .Locked = isLocked(CInt(dr("DiaryId")), CDate(dr("DiaryStart")))
                    .RecurrenceFrequency = ""
                    .RecurrenceCount = 0
                End With

                'add to the database
                '--update diary with newly introduced data columns 
                Dim transDT = addTransformedDiary(ld, False)
                ld.ListRulesId = transDT.Rows(0)("ListRulesId")
                ListDiaries.Add(ld)

                Dim dtListSlots = getListSlots(ld.ListRulesId)

                'build list slots
                Dim diarySlots As New List(Of ListSlot)
                Dim slotStart = CDate(dr("DiaryStart"))
                Dim slotEnd As DateTime

                For Each s In dtListSlots.Rows
                    slotEnd = slotStart.AddMinutes(CInt(s("SlotMinutes")))

                    Dim ls As New ListSlot
                    With ls
                        .ListSlotId = s("ListSlotId")
                        .StartTime = CDate(slotStart.ToString("HH:mm")).TimeOfDay
                        .EndTime = CDate(slotEnd.ToString("HH:mm")).TimeOfDay
                        .Minutes = s("SlotMinutes")
                    End With
                    slotStart = slotEnd

                    diarySlots.Add(ls)
                Next

                'check for appointments for current diary day
                Dim diaryAppointments = dtDiaryAppointments.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And CDate(x("StartDateTime")).Date = CDate(dr("DiaryStart")).Date).OrderBy(Function(x) CDate(x("StartDateTime")))
                If diaryAppointments.Count > 0 Then
                    For Each da In diaryAppointments
                        'work out which slot id it belongs to
                        Dim associatedSlotId = 0
                        Dim associatedSlot = (From ds In diarySlots
                                              Let appointmentStart = CDate(CDate(da("StartDateTime")).ToString("HH:mm")).TimeOfDay,
                                              appointmentEnd = CDate(CDate(da("StartDateTime")).AddMinutes(CInt(da("AppointmentDuration"))).ToString("HH:mm")).TimeOfDay
                                              Where appointmentStart >= ds.StartTime And appointmentStart < ds.EndTime
                                              Select ds).FirstOrDefault

                        If associatedSlot.ListSlotId > 0 Then
                            updateAppointmentSlotId(da("AppointmentId"), associatedSlot.ListSlotId, ld.DiaryId)
                        Else
                            'check for overbooked list
                            If CDate(da("StartDateTime")).TimeOfDay >= diarySlots.Max(Function(x) x.EndTime) Then
                                addOverBookedAppointment(CInt(da("AppointmentId")), CInt(dr("DiaryId")), CDec(da("TotalPoints")))
                            End If
                        End If
                    Next
                End If

            Else 'reoccuring diaries
                Dim diaryRecurrence As RecurrenceRule = Nothing
                RecurrenceRule.TryParse(dr("RecurrenceRule").ToString, diaryRecurrence)

                If diaryRecurrence IsNot Nothing Then
                    Dim maxOcc As Integer = 1
                    Select Case diaryRecurrence.Pattern.Frequency
                        Case RecurrenceFrequency.Daily
                            maxOcc = 365
                        Case RecurrenceFrequency.Weekly
                            maxOcc = 52
                        Case RecurrenceFrequency.Monthly
                            maxOcc = 12
                        Case RecurrenceFrequency.Yearly
                            maxOcc = 5
                    End Select

                    Dim iCount = 0
                    For Each o In diaryRecurrence.Occurrences
                        'do not continue if suppressed from date has passed
                        If Not dr.IsNull("SuppressedFromDate") AndAlso o.Date > CDate(dr("SuppressedFromDate")).Date.AddDays(1) Then
                            Continue For
                        End If

                        Dim ld = New ListDiary
                        Try
                            With ld
                                .DiaryId = dr("DiaryId")
                                .Subject = dr("Subject")
                                .DiaryStart = o.Date.Add(CDate(dr("DiaryStart")).TimeOfDay)
                                .DiaryEnd = o.Date.Add(CDate(dr("DiaryEnd")).TimeOfDay)
                                .UserId = dr("UserId")
                                .RoomId = dr("RoomId")
                                .ListRulesId = dr("ListRulesId")
                                .OperatingHospitalId = dr("OperatingHospitalId")
                                .Training = dr("Training")
                                .ListConsultantId = If(Not dr.IsNull("ListConsultantId"), dr("ListConsultantId"), 0)
                                .ListGenderId = If(Not dr.IsNull("ListGenderId"), dr("ListGenderId"), getDiaryGender(.DiaryId, .DiaryStart))
                                .ListNotes = If(Not dr.IsNull("Notes"), dr("Notes"), getListNotes(.OperatingHospitalId, .RoomId, .DiaryStart))
                                .IsGi = True
                                .Locked = isLocked(.DiaryId, .DiaryStart)
                                Select Case diaryRecurrence.Pattern.Frequency
                                    Case RecurrenceFrequency.Daily
                                        .RecurrenceFrequency = "d"
                                    Case RecurrenceFrequency.Weekly
                                        .RecurrenceFrequency = "w"
                                    Case RecurrenceFrequency.Monthly
                                        .RecurrenceFrequency = "m"
                                    Case RecurrenceFrequency.Yearly
                                        .RecurrenceFrequency = "y"
                                End Select

                                .RecurrenceCount = diaryRecurrence.Occurrences.Count
                                .RecurrenceParentId = dr("DiaryId")
                            End With


                            'add to the database
                            '--update NewDiaryId with returned id
                            Dim reccTransDT = addTransformedDiary(ld, True)
                            ld.DiaryId = reccTransDT.Rows(0)("DiaryId")
                            ld.ListRulesId = reccTransDT.Rows(0)("ListRulesId")
                            ListDiaries.Add(ld)

                            Dim dtListSlots = getListSlots(ld.ListRulesId)

                            'build list slots
                            Dim diarySlots = New List(Of ListSlot)
                            Dim slotStart = ld.DiaryStart
                            Dim slotEnd = New DateTime

                            For Each s In dtListSlots.Rows
                                slotEnd = slotStart.AddMinutes(CInt(s("SlotMinutes")))

                                Dim ls As New ListSlot
                                With ls
                                    .ListSlotId = s("ListSlotId")
                                    .StartTime = CDate(slotStart.ToString("HH:mm")).TimeOfDay
                                    .EndTime = CDate(slotEnd.ToString("HH:mm")).TimeOfDay
                                    .Minutes = s("SlotMinutes")
                                End With
                                slotStart = slotEnd

                                diarySlots.Add(ls)
                            Next

                            'check for appointments for current diary day
                            Dim diaryAppointments = dtDiaryAppointments.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And CDate(x("StartDateTime")).Date = o.Date).OrderBy(Function(x) CDate(x("StartDateTime")))
                            If diaryAppointments.Count > 0 Then
                                For Each da In diaryAppointments
                                    'work out which slot id it belongs to
                                    Dim associatedSlotId = 0
                                    Dim associatedSlot = (From ds In diarySlots
                                                          Let appointmentStart = CDate(CDate(da("StartDateTime")).ToString("HH:mm")).TimeOfDay,
                                                              appointmentEnd = CDate(CDate(da("StartDateTime")).AddMinutes(CInt(da("AppointmentDuration"))).ToString("HH:mm")).TimeOfDay
                                                          Where appointmentStart >= ds.StartTime And appointmentStart < ds.EndTime
                                                          Select ds).FirstOrDefault

                                    If associatedSlot.ListSlotId > 0 Then
                                        updateAppointmentSlotId(da("AppointmentId"), associatedSlot.ListSlotId, ld.DiaryId)
                                    Else
                                        'check for overbooked list
                                        If CDate(da("StartDateTime")).TimeOfDay >= diarySlots.Max(Function(x) x.EndTime) Then
                                            addOverBookedAppointment(da("AppointmentId"), ld.DiaryId, CDec(da("TotalPoints")))
                                        End If
                                    End If
                                Next
                            End If

                            ''check for appointments for current diary day
                            'diaryAppointments = dtDiaryAppointments.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And CDate(x("StartDateTime")).Date = CDate(dr("DiaryStart")).Date)
                            'If diaryAppointments.Count > 0 Then
                            '    'work out which slot id it belongs to

                            '    diarySlots = New List(Of ListSlot)
                            '    slotStart = CDate(dr("DiaryStart"))
                            '    slotEnd = slotStart


                            '    'build list slots
                            '    For Each s In dtListSlots.AsEnumerable.Where(Function(x) x("ListRulesId") = dr("ListRulesId"))
                            '        slotEnd = slotStart.AddMinutes(CInt(s("SlotMinutes")))

                            '        Dim ls As New ListSlot
                            '        With ls
                            '            .ListSlotId = s("ListSlotId")
                            '            .StartTime = CDate(slotStart.ToString("HH:mm")).TimeOfDay
                            '            .EndTime = CDate(slotEnd.ToString("HH:mm")).TimeOfDay
                            '            .Minutes = s("SlotMinutes")
                            '        End With
                            '        diarySlots.Add(ls)

                            '        Dim slotAppointment = diaryAppointments.Where(Function(x) CDate(x("StartDateTime")).TimeOfDay >= slotStart.TimeOfDay).FirstOrDefault
                            '        If slotAppointment IsNot Nothing Then
                            '            '--update appointment with list slot id and new diary id
                            '            updateAppointmentSlotId(slotAppointment("AppointmentId"), ls.ListSlotId, ld.NewDiaryId)

                            '            slotStart = CDate(slotAppointment("StartDateTime")).AddMinutes(CInt(slotAppointment("AppointmentDuration")))
                            '        Else
                            '            slotStart = slotEnd
                            '        End If
                            '    Next
                            'End If

                            iCount += 1

                            If o.Date >= CDate(dr("DiaryStart")).AddYears(3).Date Then
                                Exit For
                            End If
                        Catch ex As CustomEx
                            ex.ErrorObjectId = ld.DiaryId
                            Throw ex
                        End Try
                    Next
                End If
            End If

        Next
    End Sub

    Private Sub addOverBookedAppointment(appointmentId As Integer, diaryId As Integer, points As Integer)
        Dim da As New DataAccess_Sch
        da.addOverBookedSlot(appointmentId, diaryId, points)
    End Sub

    Private Function getListNotes(operatingHospitalId As Integer, roomId As Integer, diaryDate As DateTime) As String
        Dim da As New DataAccess_Sch
        Dim noteTime As String = ""

        If diaryDate.TimeOfDay < New TimeSpan(12, 0, 0) Then
            noteTime = "AM"
        ElseIf diaryDate.TimeOfDay > New TimeSpan(12, 0, 0) And diaryDate.TimeOfDay <= New TimeSpan(17, 0, 0) Then
            noteTime = "PM"
        ElseIf diaryDate.TimeOfDay > New TimeSpan(17, 0, 0) Then
            noteTime = "EVE"
        End If

        Dim dbResult = da.getDayNotes(CDate(diaryDate), roomId, operatingHospitalId, noteTime)
        If dbResult IsNot Nothing AndAlso dbResult.Rows.Count > 0 Then
            Return dbResult.Rows(0)("NoteText")
        Else
            Return ""
        End If
    End Function

    Private Function getDiaryGender(diaryId As Integer, diaryDate As DateTime) As Integer
        Dim da As New DataAccess_Sch
        Dim diaryGender = da.GetGenderLists(diaryId, diaryDate)
        If diaryGender.Count > 0 Then
            If diaryGender(0).Female And diaryGender(0).Male Then
                Return 0
            ElseIf diaryGender(0).Female Then
                Return 3
            ElseIf diaryGender(0).Male Then
                Return 2
            Else
                Return 0
            End If
        Else
            Return 0
        End If
    End Function

    Private Function isLocked(diaryId As Integer, diaryDate As DateTime) As Boolean
        Return False
    End Function

    Public Function getAllDiaries() As DataTable
        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sys_get_all_diaries", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting diaries", ex)
            Return Nothing
        End Try

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function getDiary(diaryId As Integer) As DataTable
        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sys_get_diary", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("diaryId", diaryId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting diaries", ex)
            Return Nothing
        End Try

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function getDiaryAppointments() As DataTable
        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sys_get_all_appointments", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting diaries", ex)
            Return Nothing
        End Try

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function getListSlots(listRulesId As Integer) As DataTable
        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sys_get_list_slots", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ListRulesId", listRulesId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting diaries", ex)
            Return Nothing
        End Try

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Friend Function addTransformedDiary(ld As ListDiary, addNew As Boolean) As DataTable
        Try
            Dim dsData As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sys_transformed_diary_add", connection)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", ld.DiaryId))
                cmd.Parameters.Add(New SqlParameter("@Subject", ld.Subject))
                cmd.Parameters.Add(New SqlParameter("@DiaryStart", ld.DiaryStart))
                cmd.Parameters.Add(New SqlParameter("@DiaryEnd", ld.DiaryEnd))
                cmd.Parameters.Add(New SqlParameter("@RoomID", ld.RoomId))
                cmd.Parameters.Add(New SqlParameter("@UserID", ld.UserId))
                cmd.Parameters.Add(New SqlParameter("@RecurrenceFrequency", ld.RecurrenceFrequency))
                cmd.Parameters.Add(New SqlParameter("@RecurrenceCount", ld.RecurrenceCount))
                cmd.Parameters.Add(New SqlParameter("@RecurrenceParentID", ld.RecurrenceParentId))
                cmd.Parameters.Add(New SqlParameter("@ListRulesId", ld.ListRulesId))
                cmd.Parameters.Add(New SqlParameter("@Description", ld.Subject))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", ld.OperatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@Training", ld.Training))
                cmd.Parameters.Add(New SqlParameter("@ListConsultant", ld.ListConsultantId))
                cmd.Parameters.Add(New SqlParameter("@ListGenderId", ld.ListGenderId))
                cmd.Parameters.Add(New SqlParameter("@ListNotes", ld.ListNotes))
                cmd.Parameters.Add(New SqlParameter("@IsGI", ld.IsGi))
                cmd.Parameters.Add(New SqlParameter("@Add", addNew))


                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)

                If dsData.Tables.Count > 0 Then
                    Return dsData.Tables(0)
                End If
                Return Nothing

            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function updateAppointmentSlotId(appointmentId As Integer, listSlotId As Integer, diaryId As Integer) As Integer
        Try
            Dim idObj As Object
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sys_update_list_appointment", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@AppointmentId", appointmentId))
                cmd.Parameters.Add(New SqlParameter("@ListSlotId", listSlotId))
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))

                cmd.Connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CInt(idObj)
                Else
                    Return 0
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

End Class
