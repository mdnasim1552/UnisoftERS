'DataAccess for SCHEDULER

Imports System.Data.Entity.Core.Objects
Imports System.Data.Entity.SqlServer
Imports System.Data.SqlClient
Imports DevExpress.Spreadsheet
Imports Telerik.Web.UI

Public Class DataAccess_Sch

    Private ReadOnly Property LoggedInUserId As Integer
        Get
            Return CInt(HttpContext.Current.Session("PKUserID"))
        End Get
    End Property

    Private ReadOnly Property OffsetMinutes As Integer
        Get
            Return CInt(HttpContext.Current.Session("TimezoneOffset"))
        End Get
    End Property

#Region "List Templates"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTemplatesLst(Field As String, FieldValue As String, Suppressed As Nullable(Of Integer), IsGI As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_templates_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            '22 Oct 2021 : MH changed @TrustId parameter type from SqlDbType.TinyInt to SqlDbType.Int, 
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = CInt(HttpContext.Current.Session("TrustId"))})
            If Suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = Suppressed})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = DBNull.Value})
            End If
            If IsGI > -1 Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@IsGI", .SqlDbType = SqlDbType.TinyInt, .Value = IsGI})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@IsGI", .SqlDbType = SqlDbType.TinyInt, .Value = DBNull.Value})
            End If
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function


    Friend Function GetGenericTemplates(operatingHospitalId As Integer, Optional showCustom As Boolean = False) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_templates", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@ShowCustom", showCustom))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing

        Catch ex As Exception
            Throw ex
        End Try
    End Function



    Public Function GetEndoscopists(isGI As Boolean) As DataTable
        Try

            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("get_endoscopists", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetTemplateEndoscopist(templateId As String) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return (From l In db.ERS_SCH_ListRules Where l.ListRulesId = templateId Select l.Endoscopist).FirstOrDefault
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting templates endoscopist", ex)
            Throw ex
        End Try
    End Function

    Friend Function getTemplateDiaries(listRulesId As Integer) As DataTable
        Throw New NotImplementedException()
    End Function

    Friend Function reserveSlot(bookingDate As Date, bookingDuration As Integer, statusId As Integer, diaryId As Integer, roomId As Integer, operatingHospitalID As Integer, patientId As Integer, Optional appointmentId As Integer = 0) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim reservedStatusId As Integer = (From s In db.ERS_AppointmentStatus Where s.HDCKEY = "H" Select s.UniqueId).FirstOrDefault
                If reservedStatusId > 0 Then
                    If appointmentId = 0 Then
                        Dim tbl As New ERS.Data.ERS_Appointments
                        With tbl
                            .AppointmentStatusId = reservedStatusId
                            .PatientId = patientId
                            .OperationalHospitaId = operatingHospitalID
                            .DiaryId = diaryId
                            .SlotStatusID = statusId
                            .StartDateTime = bookingDate
                            .AppointmentDuration = bookingDuration
                            .DateAccessed = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                            .StaffAccessedId = LoggedInUserId
                        End With
                        db.ERS_Appointments.Add(tbl)
                        db.SaveChanges()

                        Return tbl.AppointmentId
                    Else
                        Dim editingStatusId As Integer = (From s In db.ERS_AppointmentStatus Where s.HDCKEY = "E" Select s.UniqueId).FirstOrDefault

                        Dim editingAppointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault
                        editingAppointment.PreviousStatusId = editingAppointment.AppointmentStatusId 'record existing diary id 
                        editingAppointment.AppointmentStatusId = editingStatusId
                        editingAppointment.StaffAccessedId = LoggedInUserId
                        editingAppointment.DateAccessed = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                        db.Entry(editingAppointment).State = Entity.EntityState.Modified
                        db.SaveChanges()

                        Return appointmentId
                    End If
                Else
                    Throw New Exception("Unable to reserve slot. Reserve slot id not available")
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetTemplateByEndoscopist(endoscopistId As Integer, isGI As Boolean, operatingHospitalId As Integer) As DataTable
        Try
            Dim sSQL = "SELECT * FROM ERS_SCH_ListRules WHERE GIProcedure = @IsGI AND Endoscopist = ISNULL(@EndoscopistId, Endoscopist) AND Endoscopist <> 0 AND OperatingHospitalId = @OperatingHospitalId AND Suppressed = 0"

            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sSQL, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@IsGI", isGI))
                If endoscopistId = 0 Then
                    cmd.Parameters.Add(New SqlParameter("@EndoscopistId", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistId))
                End If
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function checkTemplateBookings(listRulesId As Integer) As Integer
        Try
            Dim sSQL = "SELECT COUNT(ea.AppointmentId) FROM dbo.ERS_Appointments ea WHERE ea.DiaryId IN (SELECT DiaryId FROM dbo.ERS_SCH_DiaryPages esdp WHERE esdp.ListRulesId=@ListRulesId)"
            Dim idObj As Object

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sSQL, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@ListRulesId", listRulesId))

                connection.Open()
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

    Public Function getDefaultSlotLength(operatingHospitalId As Integer, training As Boolean, nonGI As Boolean) As Double
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return (From x In db.ERS_SCH_PointMappings
                        Where x.OperatingHospitalId = operatingHospitalId And
                              x.ProceduretypeId = 0 And
                              x.Training = training And
                              x.NonGI = nonGI
                        Select x.Minutes).FirstOrDefault
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function IncludeDiaryEvenings(operatingHospitalID As Integer) As Boolean
        Dim sql As String = "SELECT EveningProcedures FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Dim idObj As Object

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalID))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Friend Sub UpdateDefaultSlotLength(operatingHospitalId As Integer, defaultMinutes As Double, training As Boolean, nonGI As Boolean)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim dbRecord = db.ERS_SCH_PointMappings.Where(Function(x) x.OperatingHospitalId = operatingHospitalId And
                                                                  x.ProceduretypeId = 0 And
                                                                  x.Training = training And
                                                                  x.NonGI = nonGI).FirstOrDefault
                With dbRecord
                    .Minutes = defaultMinutes
                End With

                db.ERS_SCH_PointMappings.Attach(dbRecord)
                db.Entry(dbRecord).State = Entity.EntityState.Modified

                db.SaveChanges()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetSlotBreechDays(slotIds As List(Of Integer)) As Integer
        Using db As New ERS.Data.GastroDbEntities
            Return (From ss In db.ERS_SCH_SlotStatus
                    Where slotIds.Contains(ss.StatusId)
                    Order By ss.BreachDays
                    Select ss.BreachDays).FirstOrDefault 'return lowest day
        End Using
    End Function

    Public Function CalculateBookingCallInTime(procedureTypeIds As List(Of Integer), operatingHospitalId As Integer) As Integer
        Using db As New ERS.Data.GastroDbEntities
            Return (From ct In db.ERS_SCH_ProcedureCallInTimes
                    Where procedureTypeIds.Contains(ct.ProcedureTypeId) And ct.OperatingHospitalId = operatingHospitalId And ct.CallInMinutes > 0
                    Order By ct.CallInMinutes Descending
                    Select ct.CallInMinutes).FirstOrDefault 'return highest number
        End Using
    End Function

    Friend Function GetDiaryDetails(diaryId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_get_list_diary_details", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@DiaryId", .SqlDbType = SqlDbType.Int, .Value = diaryId})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTemplate(ByVal ListRulesId As Integer) As DataTable
        Dim sqlStr As String = "SELECT * FROM ERS_SCH_ListRules WHERE ListRulesId = " & ListRulesId
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    Friend Function EndosopistsDiaryDatesOverlap(endoId As String, diaryStart As DateTime, diaryEnd As DateTime, recurrenceRule As RecurrenceRule) As Boolean
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim endoDiaries = db.ERS_SCH_DiaryPages.Where(Function(x) x.UserID = endoId)
                Dim tmp = endoDiaries.ToList
                '1- check if current date = diary date
                If endoDiaries.Any(Function(x) (diaryStart >= x.DiaryStart And diaryStart < x.DiaryEnd) Or (diaryEnd >= x.DiaryStart And diaryEnd < x.DiaryEnd)) Then
                    Return True
                End If

                For Each a In endoDiaries
                    Dim recurrenceState As New RecurrenceState

                    'Dim diaryAppointment As New Appointment(a.DiaryId, a.DiaryStart, a.DiaryEnd, a.Subject, a.RecurrenceRule, a.RecurrenceParentID)
                Next

                '2- check diary date against returned diaries occurences to see if this diary date falls within it
                '3- check diaries occurences against returned diaries occurences to see if any of them clash
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetProcedureCallInTime(procedureTypeId As Integer, operatingHospitalId As Integer) As TimeSpan
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_procedurecallintime_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Dim retVal As New TimeSpan
                If dsData.Tables(0).Rows.Count > 0 Then
                    retVal = New TimeSpan("00", dsData.Tables(0).Rows(0)("CallInMinutes"), "00")
                    Return retVal
                Else
                    Return New TimeSpan(0, 0, 0)
                End If
            End If
            Return New TimeSpan(0, 0, 0)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting procedure call in time. default of 15 mins returned", ex)
            Return New TimeSpan(0, 0, 0)
        End Try
    End Function

    Friend Function getTemplateEndTime(templateId As Integer, startDateTime As Date) As Date
        Dim sqlStr As String = "SELECT dbo.fnSCH_DiaryEnd(@ListRulesId, @StartDateTime)"

        Dim idObj As Object

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ListRulesId", templateId))
            cmd.Parameters.Add(New SqlParameter("@StartDateTime", startDateTime))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing And idObj IsNot DBNull.Value Then
                'Return CDate(idObj)
                Return CDate(idObj.ToString).ToString("yyyy/MM/dd hh:mm:ss")
            Else
                Return startDateTime
            End If
        End Using
    End Function

    Public Function ProcedureMinutes(ProcedureTypeId As Integer, operatingHospitalID As Integer) As Integer
        Dim sqlStr As String = "SELECT [Minutes] FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = @ProcedureTypeId AND OperatingHospitalId = @OperatingHospitalId"

        Dim idObj As Object

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", ProcedureTypeId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalID))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CInt(idObj)
            Else
                Return 15
            End If
        End Using
    End Function
    Public Function SuppressTemplate(ListID As String, suppress As Boolean, Optional suppressFrom As DateTime? = Nothing) As Boolean
        Try

            Dim sql As String = "UPDATE [ERS_SCH_ListRules] SET [Suppressed] = CASE WHEN [Suppressed] = 0 then 1 else 0 end, WhoUpdatedId = " & LoggedInUserId & ", WhenUpdated = GETDATE() WHERE [ListRulesId]= " & ListID
            Dim successful = DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)

            If suppress And suppressFrom.HasValue Then
                Using db As New ERS.Data.GastroDbEntities
                    Dim templatesDiary = db.ERS_SCH_DiaryPages.Where(Function(x) x.ListRulesId = ListID)
                    For Each d In templatesDiary

                        d.Suppressed = True
                        d.SuppressedFromDate = suppressFrom

                        db.ERS_SCH_DiaryPages.Attach(d)
                        db.Entry(d).State = Entity.EntityState.Modified
                    Next

                    db.SaveChanges()
                End Using
            ElseIf Not suppress Then
                Using db As New ERS.Data.GastroDbEntities
                    Dim templatesDiary = db.ERS_SCH_DiaryPages.Where(Function(x) x.ListRulesId = ListID)
                    For Each d In templatesDiary

                        d.Suppressed = False
                        d.SuppressedFromDate = Nothing

                        db.ERS_SCH_DiaryPages.Attach(d)
                        db.Entry(d).State = Entity.EntityState.Modified
                    Next

                    db.SaveChanges()
                End Using
            End If

            Return successful

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("There was an error suppressing the template. ID" & ListID, ex)
            Return False
        End Try
    End Function

    Public Function ProcedureMinutesDiagAndThera(procedureTypeId As Integer, operatingHospitalID As Integer, training As Boolean, nonGI As Boolean) As DataTable
        Dim sqlStr As String = "SELECT [Minutes] AS DiagnosticMinutes, TherapeuticMinutes, [Points] as DiagnosticPoints, TherapeuticPoints FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = @ProcedureTypeId AND OperatingHospitalId = @OperatingHospitalId AND Training = @Training AND NonGI = @NonGI"

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalID))
            cmd.Parameters.Add(New SqlParameter("@Training", training))
            cmd.Parameters.Add(New SqlParameter("@NonGI", nonGI))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing

    End Function

    Friend Function checkSlotAvailability(selectedDateTime As DateTime, diaryId As Integer) As DataTable
        Try
            ReleaseRedundantLockedSlots()

            Dim sSQL = "sch_appointment_availability"
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sSQL, connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))
                cmd.Parameters.Add(New SqlParameter("@StartDateTime", selectedDateTime))

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function SuppressTemplate(ListID As String) As Boolean
        Dim sql As String = "UPDATE [ERS_SCH_ListRules] SET [Suppressed] = CASE WHEN [Suppressed] = 0 then 1 else 0 end, WhoUpdatedId = " & LoggedInUserId & ", WhenUpdated = GETDATE() WHERE [ListRulesId]= " & ListID
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetEndoscopist(isGIConsultant As Boolean) As DataTable
        'Dim sqlStr As String = ""

        'If isGIConsultant Then
        '    sqlStr = "SELECT UserID, LTRIM(RTRIM(ISNULL([Title], '') + ' ' + ISNULL([Forename], '') + ' ' + ISNULL([Surname], ''))) AS EndoName, Description AS FullName " &
        '   " FROM ERS_USERS WHERE (IsEndoscopist1 = 1 OR IsEndoscopist2 = 1) AND ISNULL(IsGIConsultant,1) = " & If(isGIConsultant, 1, 0)
        'Else
        '    sqlStr = "SELECT UserID, LTRIM(RTRIM(ISNULL([Title], '') + ' ' + ISNULL([Forename], '') + ' ' + ISNULL([Surname], ''))) AS EndoName, Description AS FullName " &
        '   " FROM ERS_USERS WHERE ISNULL(IsGIConsultant,1) = " & If(isGIConsultant, 1, 0)
        'End If

        'Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
        Return GetEndoscopists(isGIConsultant)
    End Function

    Public Sub setEvenings(operatingHospitalId As Integer, includeEvenings As Boolean)
        Try
            Dim sqlStr As String = "UPDATE ERS_OperatingHospitals SET EveningProcedures = @IncludeEvenings WHERE OperatingHospitalId = @OperatingHospitalId"
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sqlStr.ToString(), connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@IncludeEvenings", includeEvenings))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Public Sub setImportPatientByWebservice(operatingHospitalId As Integer, intImportPatientByWebservice As Integer)
        Try
            Dim sqlStr As String = "Update ERS_OperatingHospitals Set ImportPatientByWebservice = @ImportPatientByWebService Where OperatingHospitalId = @OperatingHospitalId3"
            Using conn As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sqlStr.ToString(), conn)
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@ImportPatientByWebservice", intImportPatientByWebservice))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Friend Sub moveTemplate(diaryId As Integer, newDate As Date, newTime As String, newRoom As String)
        Try
            Dim sqlStr As String = "sch_move_diary_template"
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sqlStr.ToString(), connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))
                cmd.Parameters.Add(New SqlParameter("@NewStart", newDate))
                cmd.Parameters.Add(New SqlParameter("@NewRoom", newRoom))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetEndoscopist() As DataTable
        Dim sqlStr As String = "Select distinct u.UserID, LTRIM(RTRIM(ISNULL(u.Title, '') + ' ' + ISNULL(u.Forename, '') + ' ' + ISNULL(u.Surname, ''))) AS EndoName, u.Description AS FullName, u.Surname " &
                                "From ERS_USERS u " &
                                "join ERS_UserOperatingHospitals uoh on u.UserID = uoh.UserId " &
                                "Join ERS_OperatingHospitals oh on uoh.OperatingHospitalId = oh.OperatingHospitalId " &
                                "where (IsEndoscopist1 = 1 OR IsEndoscopist2 = 1) and oh.TrustId = " & HttpContext.Current.Session("TrustId") &
                                " order by u.Surname "
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetListSlots(ByVal ListRulesId As Integer) As DataTable
        Dim sqlStr As String = "SELECT row_number() OVER (ORDER BY [ListSlotId]) LstSlotId, * FROM [dbo].[ERS_SCH_ListSlots] " &
            " WHERE ListRulesId = " & CStr(ListRulesId) &
            " ORDER BY ListSlotId"
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    Friend Function BookedFromWaitlist(appointmentId As Integer) As Boolean
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return db.ERS_Appointments.Any(Function(x) x.AppointmentId = appointmentId And x.WaitingListId IsNot Nothing And x.WaitingListId > 0)
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub updatePatientStatus(appointmentId As Integer, statusCode As String)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim statuses = db.ERS_AppointmentStatus
                Dim newStatusId = 0
                Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault

                newStatusId = statuses.Where(Function(x) x.HDCKEY = statusCode).FirstOrDefault.UniqueId

                With appointment
                    .AppointmentStatusId = newStatusId
                    .DateChanged = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                    .StaffChangedId = LoggedInUserId
                End With

                db.ERS_Appointments.Attach(appointment)
                db.Entry(appointment).State = Entity.EntityState.Modified
                db.SaveChanges()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub markPatientAbandoned(appointmentId As Integer)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim statuses = db.ERS_AppointmentStatus
                Dim newStatusId = 0
                Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault

                newStatusId = statuses.Where(Function(x) x.HDCKEY = "X").FirstOrDefault.UniqueId

                If Not newStatusId = 0 Then
                    With appointment
                        .AppointmentStatusId = newStatusId
                        .DateChanged = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                        .StaffChangedId = LoggedInUserId
                    End With

                    db.ERS_Appointments.Attach(appointment)
                    db.Entry(appointment).State = Entity.EntityState.Modified
                    db.SaveChanges()
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub markPatientCancelled(appointmentId As Integer)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim statuses = db.ERS_AppointmentStatus
                Dim newStatusId = 0
                Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault

                newStatusId = statuses.Where(Function(x) x.HDCKEY = "C").FirstOrDefault.UniqueId

                If Not newStatusId = 0 Then
                    With appointment
                        .AppointmentStatusId = newStatusId
                        .DateChanged = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                        .StaffChangedId = LoggedInUserId
                    End With

                    db.ERS_Appointments.Attach(appointment)
                    db.Entry(appointment).State = Entity.EntityState.Modified
                    db.SaveChanges()
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub markPatientBooked(appointmentId As Integer)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim statuses = db.ERS_AppointmentStatus
                Dim newStatusId = 0
                Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault

                newStatusId = statuses.Where(Function(x) x.HDCKEY = "B").FirstOrDefault.UniqueId

                If Not newStatusId = 0 Then
                    With appointment
                        .AppointmentStatusId = newStatusId
                        .DateChanged = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                        .StaffChangedId = LoggedInUserId
                    End With

                    db.ERS_Appointments.Attach(appointment)
                    db.Entry(appointment).State = Entity.EntityState.Modified
                    db.SaveChanges()
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub markPatientDNA(appointmentId As Integer)
        Dim blnSaved As Boolean = False

        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim statuses = db.ERS_AppointmentStatus
                Dim newStatusId = 0
                Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault


                If appointment.AppointmentStatusId = statuses.Where(Function(x) x.HDCKEY = "D").FirstOrDefault.UniqueId Then
                    newStatusId = statuses.Where(Function(x) x.HDCKEY = "B").FirstOrDefault.UniqueId
                Else
                    newStatusId = statuses.Where(Function(x) x.HDCKEY = "D").FirstOrDefault.UniqueId
                End If

                If Not newStatusId = 0 Then
                    With appointment
                        .AppointmentStatusId = newStatusId
                        .DateChanged = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                        .StaffChangedId = LoggedInUserId
                    End With

                    db.ERS_Appointments.Attach(appointment)
                    db.Entry(appointment).State = Entity.EntityState.Modified
                    db.SaveChanges()
                    blnSaved = True
                End If
            End Using

            If blnSaved Then
                Dim strOrderMessage As String = ""
                Dim blnOrderEventIdSendEnabled As Boolean = False
                Dim strLoggedInUserName As String = HttpContext.Current.Session("UserID")
                Dim OrderCommsBL As New OrderCommsBL
                Dim intOrderId As Integer = 0
                Dim intCurrentAppointmentWaitListId As Integer = 0

                Dim intLoggedInUserId As Integer = CInt(HttpContext.Current.Session("PKUserId"))
                intOrderId = OrderCommsBL.GetOrderIdByAppointmentId(appointmentId)
                intCurrentAppointmentWaitListId = OrderCommsBL.GetWaitingListIdByOrderId(intOrderId)

                If intOrderId > 0 Then
                    blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(15)
                    If blnOrderEventIdSendEnabled Then
                        strOrderMessage = "Patient Marked as DNA by " + strLoggedInUserName + ". "
                        strOrderMessage = strOrderMessage + OrderCommsBL.GetOrderAppointmentMessageByAppointmentId(appointmentId)
                        OrderCommsBL.SendOrderMessageByOrderAndEventId(intOrderId, 15, Nothing, intCurrentAppointmentWaitListId, appointmentId, strOrderMessage, Nothing, intLoggedInUserId)
                    End If
                End If

            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getAppointmentDetails(appointmentId As Integer) As DataTable
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault
            End Using

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub unMarkPatientDNA(appointmentId As Integer)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault
                With appointment
                    .AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "B").FirstOrDefault.UniqueId
                    .DateChanged = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                    .StaffChangedId = LoggedInUserId
                End With

                db.ERS_Appointments.Attach(appointment)
                db.Entry(appointment).State = Entity.EntityState.Modified
                db.SaveChanges()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub insertLetterQueueData(AppointmentId As Integer)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("insert_data_LetterQueue", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@AppointmentId", AppointmentId))
                cmd.Connection.Open()
                Dim value = cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function CancellationReasons() As DataTable
        Dim sqlStr As String = "SELECT CancelReasonId, Detail as CancellationReason FROM ERS_CancelReasons WHERE Active = 1 AND Suppressed = 0"
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    Public Function ListCancellationReasons() As DataTable
        Dim sqlStr As String = "SELECT ListCancelReasonId, Detail as CancellationReason FROM ERS_ListCancelReasons WHERE Active = 1 AND Suppressed = 0"
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSlotStatus(ByVal GI As Byte, ByVal nonGI As Byte) As DataTable
        Dim sqlStr As String = "SELECT * FROM [dbo].[ERS_SCH_SlotStatus] " &
            " WHERE GI = " & CStr(GI) & " OR nonGI = " & CStr(nonGI) &
            " ORDER BY StatusId"

        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSlotStatusForFilter(ByVal GI As Byte, ByVal nonGI As Byte) As DataTable

        Dim sqlStr As String = "Select * from (Select 0 as StatusId,'-- All --' as Description Union SELECT StatusId, Description FROM [dbo].[ERS_SCH_SlotStatus] " &
            " WHERE GI = " & CStr(GI) & " OR nonGI = " & CStr(nonGI) &
            ") a ORDER BY a.StatusId"
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOrderCommsStatus() As DataTable
        Dim sqlStr As String = "Select l.ListItemText,l.ListItemNo,l.ListId from ERS_Lists l inner join ERS_ListsMain lm on l.ListMainId=lm.ListMainId Where lm.ListDescription = 'OrderComms Status' and l.ListDescription = 'OrderComms Status' Order by l.ListItemNo"

        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOrderCommsRejectionReasons() As DataTable
        Dim sqlStr As String = "Select l.ListItemText,l.ListItemNo,l.ListId from ERS_Lists l inner join ERS_ListsMain lm on l.ListMainId=lm.ListMainId Where lm.ListDescription = 'OrderComms Rejection Reason' and l.ListDescription = 'OrderComms Rejection Reason' Order by l.ListItemNo"

        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetGuidelines(isGI As Byte, operatingHospital As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_guidelines", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", 1))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Friend Sub unmarkPatientAttended(appointmentId As Integer)
        Try
            Using db As New ERS.Data.GastroDbEntities
                'update/insert patient journey record
                Dim appointment = (From a In db.ERS_Appointments
                                   Where a.AppointmentId = appointmentId
                                   Select a).FirstOrDefault

                If appointment Is Nothing Then
                    Throw New Exception("Appointment not found")
                    Exit Sub
                End If

                Dim appointmentStatuses = db.ERS_AppointmentStatus

                Dim tblPatientJourney = db.ERS_PatientJourney.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault
                If tblPatientJourney IsNot Nothing Then
                    db.ERS_PatientJourney.Remove(tblPatientJourney)
                End If

                'update appointment status id
                appointment.AppointmentStatusId = (From s In appointmentStatuses Where s.HDCKEY.ToUpper = "B" Select s.UniqueId).FirstOrDefault 'DB status for booked

                db.ERS_Appointments.Attach(appointment)
                db.Entry(appointment).State = Entity.EntityState.Modified

                db.SaveChanges()
            End Using

        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Friend Sub markPatientAttended(appointmentId As Integer)
        Dim blnSaved As Boolean = False
        Try
            Using db As New ERS.Data.GastroDbEntities
                'update/insert patient journey record
                Dim appointment = (From a In db.ERS_Appointments
                                   Where a.AppointmentId = appointmentId
                                   Select a).FirstOrDefault

                If appointment Is Nothing Then
                    Throw New Exception("Appointment not found")
                    Exit Sub
                End If

                Dim appointmentStatuses = db.ERS_AppointmentStatus

                Dim tblPatientJourney = db.ERS_PatientJourney.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault
                If tblPatientJourney Is Nothing Then tblPatientJourney = New ERS.Data.ERS_PatientJourney
                With tblPatientJourney
                    .PatientId = appointment.PatientId
                    .AppointmentId = appointmentId
                    .PatientAdmissionTime = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                End With

                If tblPatientJourney.PatientJourneyId = 0 Then
                    db.ERS_PatientJourney.Add(tblPatientJourney)
                Else
                    db.ERS_PatientJourney.Attach(tblPatientJourney)
                    db.Entry(tblPatientJourney).State = Entity.EntityState.Modified
                End If

                'update appointment status id
                appointment.AppointmentStatusId = (From s In appointmentStatuses Where s.HDCKEY.ToUpper = "BA" Select s.UniqueId).FirstOrDefault 'DB status for arrived

                db.ERS_Appointments.Attach(appointment)
                db.Entry(appointment).State = Entity.EntityState.Modified

                db.SaveChanges()
                blnSaved = True

            End Using

            If blnSaved Then
                Dim strOrderMessage As String = ""
                Dim blnOrderEventIdSendEnabled As Boolean = False
                Dim strLoggedInUserName As String = HttpContext.Current.Session("UserID")
                Dim OrderCommsBL As New OrderCommsBL
                Dim intOrderId As Integer = 0
                Dim intCurrentAppointmentWaitListId As Integer = 0

                Dim intLoggedInUserId As Integer = CInt(HttpContext.Current.Session("PKUserId"))
                intOrderId = OrderCommsBL.GetOrderIdByAppointmentId(appointmentId)
                intCurrentAppointmentWaitListId = OrderCommsBL.GetWaitingListIdByOrderId(intOrderId)

                If intOrderId > 0 Then
                    blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(11)
                    If blnOrderEventIdSendEnabled Then
                        strOrderMessage = "Patient Marked as Arrived by " + strLoggedInUserName + ". "
                        strOrderMessage = strOrderMessage + OrderCommsBL.GetOrderAppointmentMessageByAppointmentId(appointmentId)
                        OrderCommsBL.SendOrderMessageByOrderAndEventId(intOrderId, 11, Nothing, intCurrentAppointmentWaitListId, appointmentId, strOrderMessage, Nothing, intLoggedInUserId)
                    End If
                End If

            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    'Public Function getDiaryAppointments(diaryId As Integer, startDateTime As DateTime)
    '    Try
    '        Using db As New ERS.Data.GastroDbEntities
    '            startDateTime = startDateTime.Date.Add(New TimeSpan(0, 0, 0))
    '            Dim dbResults As IEnumerable(Of DataRow) = (From a In db.ERS_Appointments.AsEnumerable
    '                                                        Where a.DiaryId = diaryId And
    '                                   a.StartDateTime >= startDateTime
    '                                                        Select a)
    '        End Using
    '    Catch ex As Exception
    '        Throw ex
    '    End Try
    'End Function

    Public Function getdiaryAppointments(diaryId As Integer, startDate As DateTime) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_diary_appointments", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))
                cmd.Parameters.Add(New SqlParameter("@StartDate", startDate))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub markPatientDischarged(appointmentId As Integer)
        Dim blnSaved As Boolean = False

        Try
            Using db As New ERS.Data.GastroDbEntities
                'update/insert patient journey record
                Dim appointment = (From a In db.ERS_Appointments
                                   Where a.AppointmentId = appointmentId
                                   Select a).FirstOrDefault

                If appointment Is Nothing Then
                    Throw New Exception("Appointment not found")
                    Exit Sub
                End If

                Dim appointmentStatuses = db.ERS_AppointmentStatus

                Dim tblPatientJourney = db.ERS_PatientJourney.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault
                If tblPatientJourney Is Nothing Then tblPatientJourney = New ERS.Data.ERS_PatientJourney
                With tblPatientJourney
                    .PatientId = appointment.PatientId
                    .AppointmentId = appointmentId
                    .PatientDischargeTime = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                End With

                If tblPatientJourney.PatientJourneyId = 0 Then
                    db.ERS_PatientJourney.Add(tblPatientJourney)
                Else
                    db.ERS_PatientJourney.Attach(tblPatientJourney)
                    db.Entry(tblPatientJourney).State = Entity.EntityState.Modified
                End If

                'update appointment status id
                appointment.AppointmentStatusId = (From s In appointmentStatuses Where s.HDCKEY.ToUpper = "DC" Select s.UniqueId).FirstOrDefault 'DB status for discharged

                db.ERS_Appointments.Attach(appointment)
                db.Entry(appointment).State = Entity.EntityState.Modified

                db.SaveChanges()
                blnSaved = True

            End Using

            If blnSaved Then
                Dim strOrderMessage As String = ""
                Dim blnOrderEventIdSendEnabled As Boolean = False
                Dim strLoggedInUserName As String = HttpContext.Current.Session("UserID")
                Dim OrderCommsBL As New OrderCommsBL
                Dim intOrderId As Integer = 0
                Dim intCurrentAppointmentWaitListId As Integer = 0

                Dim intLoggedInUserId As Integer = CInt(HttpContext.Current.Session("PKUserId"))
                intOrderId = OrderCommsBL.GetOrderIdByAppointmentId(appointmentId)
                intCurrentAppointmentWaitListId = OrderCommsBL.GetWaitingListIdByOrderId(intOrderId)

                If intOrderId > 0 Then
                    blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(13)
                    If blnOrderEventIdSendEnabled Then
                        strOrderMessage = "Patient Marked as Discharged by " + strLoggedInUserName + ". "
                        strOrderMessage = strOrderMessage + OrderCommsBL.GetOrderAppointmentMessageByAppointmentId(appointmentId)
                        OrderCommsBL.SendOrderMessageByOrderAndEventId(intOrderId, 13, Nothing, intCurrentAppointmentWaitListId, appointmentId, strOrderMessage, Nothing, intLoggedInUserId)
                    End If
                End If

            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

#End Region

#Region "Booking Breach Status"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetBookingBreachStatus() As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_booking_breach_status_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOrderCommsOrderSource() As DataTable
        Dim sqlStr As String = "Select l.ListItemText,l.ListItemNo,l.ListId from ERS_Lists l inner join ERS_ListsMain lm on l.ListMainId=lm.ListMainId Where lm.ListDescription = 'OrderComms Order Source' and l.ListDescription = 'OrderComms Order Source' Order by l.ListItemNo"

        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetBookingBreachStatusLinkHL7Code(OperatingHospitalId As Integer) As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sp_getBreachStatusByOperatingHospital", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function InsertOrUpdateBreachStatusLinkHL7Code(OperatingHospitalId As Integer, StatusId As Integer, HDCKey As String, HL7Code As String, UserId As Integer) As Boolean
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sp_updateHL7CodeByOperatingHospitalIDBreachStatus", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@StatusId", StatusId))
                cmd.Parameters.Add(New SqlParameter("@HDCKey", HDCKey))
                cmd.Parameters.Add(New SqlParameter("@HL7Code", HL7Code))
                cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                cmd.ExecuteNonQuery()

                Return True

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataAccess_Sch.vb->InsertOrUpdateBreachStatusLinkHL7Code", ex)
            Return False
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Protected Sub UpdateInsertBreachStatus(StatusId As Integer, Description As String, Gi As Boolean, nonGi As Boolean, BreachDays As Integer, Colour As String, HL7Code As String, UserId As Integer)

        InsertUpdateBreachStatus(Description, Gi, nonGi, BreachDays, Colour, HL7Code, UserId, StatusId)

    End Sub
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Protected Sub InsertNewBreachStatus(Description As String, Gi As Boolean, nonGi As Boolean, BreachDays As Integer, Colour As String, HL7Code As String, UserId As Integer)

        InsertUpdateBreachStatus(Description, Gi, nonGi, BreachDays, Colour, HL7Code, UserId)

    End Sub

    Friend Function getRoomDiaries(roomId As Integer) As DataTable
        Try
            Dim ds As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_room_diaries", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)

                If ds.Tables.Count > 0 Then
                    Return ds.Tables(0)
                End If

            End Using
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting room diaries", ex)
        End Try

    End Function

    Friend Function getRoomDiaries(roomId As Integer, startDate As DateTime, endDate As DateTime) As DataTable
        Try
            Dim ds As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_room_diaries", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
                cmd.Parameters.Add(New SqlParameter("@StartDate", startDate))
                cmd.Parameters.Add(New SqlParameter("@EndDate", endDate))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)

                If ds.Tables.Count > 0 Then
                    Return ds.Tables(0)
                End If

            End Using
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting room diaries", ex)
        End Try

    End Function

    Public Sub InsertUpdateBreachStatus(Description As String, Gi As Boolean, nonGi As Boolean, BreachDays As Integer, Colour As String, HL7Code As String, UserId As Integer, Optional StatusId As Integer = 0)

        DataAccess.ExecuteScalerSQL("sch_booking_breach_status_insert_update", CommandType.StoredProcedure, New SqlParameter() {
                                                New SqlParameter("@StatusId", StatusId),
                                                New SqlParameter("@Desc", Description),
                                                New SqlParameter("@GI", Gi),
                                                New SqlParameter("@nonGI", nonGi),
                                                New SqlParameter("@BreachDays", BreachDays),
                                                New SqlParameter("@Colour", Colour),
                                                New SqlParameter("@HL7Code", HL7Code),
                                                New SqlParameter("@UserId", UserId)})

    End Sub

#End Region

#Region "Cancellation Reasons"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetCancellationReasons() As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_cancellationReasons_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function






    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    'Protected Sub UpdateInsertCancellationReasons(CancelReasonId As Integer, Code As String, Detail As String, CancelledByHospital As Boolean, UserId As Integer)

    '    InsertUpdateCancellationReasons(Code, Detail, CancelledByHospital, UserId, CancelReasonId)

    'End Sub
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    'Protected Sub InsertNewCancellationReasons(Code As String, Detail As String, CancelledByHospital As Boolean, UserId As Integer)

    '    InsertUpdateCancellationReasons(Code, Detail, CancelledByHospital, UserId)

    'End Sub

    Public Sub InsertUpdateCancellationReasons(ProcedureName As String, Code As String, Detail As String, CancelledByHospital As Boolean, UserId As Integer, Optional CancelReasonId As Integer = 0)

        DataAccess.ExecuteScalerSQL(ProcedureName, CommandType.StoredProcedure, New SqlParameter() {
                                                New SqlParameter("@CancelReasonId", CancelReasonId),
                                                New SqlParameter("@Code", Code),
                                                New SqlParameter("@Detail", Detail),
                                                New SqlParameter("@CancelledByHospital", CancelledByHospital),
                                                New SqlParameter("@UserId", UserId)})

    End Sub

#End Region

#Region "List lock Reasons"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Sub AddListLockReason(LockReasonId As Integer, Reason As String, IsLockReason As Boolean, IsUnlockReason As Boolean)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_list_lock_reason_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ReasonId", LockReasonId))
                cmd.Parameters.Add(New SqlParameter("@Reason", Reason))
                cmd.Parameters.Add(New SqlParameter("@IsLockReason", IsLockReason))
                cmd.Parameters.Add(New SqlParameter("@IsUnLockReason", IsUnlockReason))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub


#End Region

#Region " Schedule List Cancellation Reasons"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScheduleListCancellationReasons() As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_ScheduleList_Cancel_Data", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function
#End Region

#Region "Diary lock Reasons"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiaryLockReasons(Optional ignoreSuppressed As Boolean = False) As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sSQL = "SELECT DiaryLockReasonId, Reason, IsLockReason, IsUnlockReason, Suppressed FROM ERS_SCH_DiaryLockReasons"
            If ignoreSuppressed Then sSQL += " WHERE Suppressed = 0"

            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Sub AddDiaryLockReason(LockReasonId As Integer, Reason As String, IsLockReason As Boolean, IsUnlockReason As Boolean)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim tbl = db.ERS_SCH_DiaryLockReasons.Where(Function(x) x.DiaryLockReasonId = LockReasonId).FirstOrDefault
                If tbl Is Nothing Then tbl = New ERS.Data.ERS_SCH_DiaryLockReasons

                With tbl
                    .Reason = Reason
                    .IsLockReason = IsLockReason
                    .IsUnlockReason = IsUnlockReason
                End With

                If LockReasonId = 0 Then
                    tbl.WhoCreatedId = LoggedInUserId
                    tbl.WhenCreated = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                    db.ERS_SCH_DiaryLockReasons.Add(tbl)
                Else
                    tbl.WhoUpdatedId = LoggedInUserId
                    tbl.WhenUpdated = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                    db.ERS_SCH_DiaryLockReasons.Attach(tbl)
                    db.Entry(tbl).State = Entity.EntityState.Modified
                End If

                db.SaveChanges()

            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

#End Region


#Region "Endoscopist Rules"
    Public Function GetEndoscopistsByProcedureTypes(endoscopistId As Integer) As List(Of Integer)
        Using db As New ERS.Data.GastroDbEntities
            'TODO: Leaving this here incase minds get changed again. commented out sections return endoscopists that dont have a rule set against them therefore allowing them to do any procedure
            'Dim unallocatedEndos = (From u In db.ERS_Users Where u.IsEndoscopist1 = True Or u.IsEndoscopist2 = True And Not db.ERS_ConsultantProcedureTypes.Select(Function(x) x.EndoscopistID).Contains(u.UserID) Select u.UserID)

            Return (From cp In db.ERS_ConsultantProcedureTypes
                    Where (cp.Diagnostic Or cp.Therapeutic) And
                                      cp.EndoscopistID = endoscopistId
                    Select cp.ProcedureTypeID).ToList
            'Return qry.Union(unallocatedEndos).ToList


        End Using
    End Function

    Public Function GetEndoscopistsByProcedureTypes(procedureTypeIds As List(Of Integer)) As List(Of Integer)
        Using db As New ERS.Data.GastroDbEntities
            'TODO: Leaving this here incase minds get changed again. commented out sections return endoscopists that dont have a rule set against them therefore allowing them to do any procedure
            'Dim unallocatedEndos = (From u In db.ERS_Users Where u.IsEndoscopist1 = True Or u.IsEndoscopist2 = True And Not db.ERS_ConsultantProcedureTypes.Select(Function(x) x.EndoscopistID).Contains(u.UserID) Select u.UserID)

            Return (From cp In db.ERS_ConsultantProcedureTypes
                    Where cp.Diagnostic = True And
                                      procedureTypeIds.Contains(cp.ProcedureTypeID)
                    Select cp.EndoscopistID).ToList
            'Return qry.Union(unallocatedEndos).ToList


        End Using
    End Function

    Public Function GetEndoscopistsByProcedureTherapeutics(therapeuticTypeIds As List(Of Integer), procedureTypeIds As List(Of Integer)) As DataTable ' added by ferdowsi

        'sch_get_thereaputic_consultants

        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_get_thereaputic_consultants", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@TherapeuticTypeIds", String.Join(",", therapeuticTypeIds)))
            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", String.Join(",", procedureTypeIds))) ' added by ferdowsi
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function

    Public Function GetEndoscopistsByProcedureTherapeutics(endoscopistId As Integer) As List(Of Integer)
        Using db As New ERS.Data.GastroDbEntities
            'TODO: Leaving this here incase minds get changed again. commented out sections return endoscopists that dont have a rule set against them therefore allowing them to do any procedure
            'Dim unallocatedEndos = (From u In db.ERS_Users Where u.IsEndoscopist1 = True Or u.IsEndoscopist2 = True And Not db.ERS_ConsultantProcedureTypes.Select(Function(x) x.EndoscopistID).Contains(u.UserID))

            Return (From cp In db.ERS_ConsultantProcedureTypes
                    Join cpt In db.ERS_ConsultantProcedureTherapeutics
                        On cp.ConsultantProcedureId Equals cpt.ConsultantProcedureID
                    Where cp.Therapeutic = True And
                        cp.EndoscopistID = endoscopistId
                    Select cpt.TherapeuticTypeID Distinct).ToList

            'Return qry.Union(unallocatedEndos).ToList

        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetConsultantEndoscopists() As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_consultant_endoscopist_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalId"))))
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetEndoscopistProcedures(UserId As Integer) As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_endoscopist_proceduretypes_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@EndoscopistId", .SqlDbType = SqlDbType.Int, .Value = UserId})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Shared Function GetEndoscopistProceduresForBookings(UserId As Integer) As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_endoscopist_proceduretypes_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@EndoscopistId", .SqlDbType = SqlDbType.Int, .Value = UserId})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTherapeuticProcedures(ProcedureId As Integer, UserId As Integer) As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_endoscopist_therapeutic_procedures_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@UserId", .SqlDbType = SqlDbType.Int, .Value = UserId})
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureId", .SqlDbType = SqlDbType.Int, .Value = ProcedureId})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If
        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Sub InsertUpdateConsultantProcedureTypes(ProcedureId As Integer, Diagnostic As Boolean, Therapeutic As Boolean, EndoscopistId As Integer)
        Try

            DataAccess.ExecuteScalerSQL("sch_endoscopist_proceduretypes_insert_update", CommandType.StoredProcedure, New SqlParameter() {
                                                    New SqlParameter("@EndoscopistId", EndoscopistId),
                                                    New SqlParameter("@ProcedureId", ProcedureId),
                                                    New SqlParameter("@Diagnostic", Diagnostic),
                                                    New SqlParameter("@Therapeutic", Therapeutic)})

        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Friend Function getDaysAppointments(currentDate As DateTime, diaryId As Integer) As DataTable
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim cancelledStatus = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "C").FirstOrDefault
                Dim reservedsStatus = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "H").FirstOrDefault

                Dim dayAfter = currentDate.AddDays(1)
                Dim app = (From a In db.ERS_Appointments
                           Join ap In db.ERS_AppointmentProcedureTypes On a.AppointmentId Equals ap.AppointmentID
                           Where a.DiaryId = diaryId And Not a.AppointmentStatusId = cancelledStatus.UniqueId And Not a.AppointmentStatusId = reservedsStatus.UniqueId And
                               a.BookingTypeId = 2 And
                                (a.StartDateTime >= currentDate And
                                 a.StartDateTime < dayAfter)
                           Group ap.Points By a.AppointmentId, a.StartDateTime Into g = Group
                           Select AppointmentId, StartDateTime, g)

                If app.Count > 0 Then
                    Dim dt As New DataTable()
                    dt.Columns.AddRange({
                                        New DataColumn("AppointmentId", GetType(Integer)),
                                        New DataColumn("DiaryId", GetType(Integer)),
                                        New DataColumn("StartDate", GetType(DateTime)),
                                        New DataColumn("Points", GetType(Decimal))
                                        })
                    For Each a In app
                        dt.Rows.Add({a.AppointmentId, diaryId, a.StartDateTime, a.g.Sum()})
                    Next

                    Return dt
                Else
                    Return New DataTable
                End If

            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function UpdateConsultantTherapeuticProceduresTypes(listItems As List(Of Integer), EndoscopistId As Integer, ProcedureTypeId As Integer)

        Dim listParam As String = ""
        Dim list As String = ""
        For Each item In listItems
            list += item & ","
        Next

        listParam = list.TrimEnd(",")
        Try
            DataAccess.ExecuteScalerSQL("sch_endoscopist_therapeutic_procedures_insert", CommandType.StoredProcedure, New SqlParameter() {
                                            New SqlParameter("@EndoscopistId", EndoscopistId),
                                            New SqlParameter("@ProcedureTypeId", ProcedureTypeId),
                                            New SqlParameter("@listItems", listParam)})

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error updating Endoscopist Therapeutic types.", ex)
            Throw ex
        End Try
        Return True

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function RemoveExistingTherapeuticTypes(EndoscopistId As Integer, ProcedureTypeId As Integer)
        Try
            DataAccess.ExecuteScalerSQL("sch_endoscopist_therapeutic_procedures_delete", CommandType.StoredProcedure, New SqlParameter() {
                                            New SqlParameter("@EndoscopistId", EndoscopistId),
                                            New SqlParameter("@ProcedureTypeId", ProcedureTypeId)})
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error during removal of Endoscopist Therapeutic types.", ex)
            Return False
        End Try
        Return True
    End Function

#End Region

#Region "Rooms"
    ''' <summary>
    ''' Returns rooms belonging to a single hospital
    ''' </summary>
    ''' <param name="HospitalID"></param>
    ''' <returns></returns>
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHospitalRooms(HospitalID As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_trust_rooms", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalId", .SqlDbType = SqlDbType.Int, .Value = HospitalID})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    ''' <summary>
    ''' Returns rooms belonging to all given hospitals
    ''' </summary>
    ''' <param name="HospitalIDs"></param>
    ''' <returns></returns>
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllRoomsForSelectedHospitals(HospitalIDs As String) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_hospital_rooms", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIds", .SqlDbType = SqlDbType.Text, .Value = HospitalIDs})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetSchedulerRooms(operatingHospitalId As Integer)
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_get_scheduler_rooms", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "OperatingHospitalId", .SqlDbType = SqlDbType.Int, .Value = operatingHospitalId})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRoomsLst(OperatingHospitalId As Integer, Field As String, FieldValue As String, Suppressed As Nullable(Of Integer)) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_rooms_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            If Field = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Field", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Field", .SqlDbType = SqlDbType.Text, .Value = Field})
            End If
            If FieldValue = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@FieldValue", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@FieldValue", .SqlDbType = SqlDbType.Text, .Value = FieldValue})
            End If
            If Suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = Suppressed})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = DBNull.Value})
            End If
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalId", .SqlDbType = SqlDbType.Int, .Value = OperatingHospitalId})

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SuppressRoom(RoomId As String, Suppressed As Boolean) As Boolean
        Dim sql As String = "UPDATE [ERS_SCH_Rooms] SET [Suppressed] = " & IIf(Suppressed, 1, 0) & ", WhoUpdatedId = " & LoggedInUserId & ", WhenUpdated = GETDATE() WHERE [RoomId]= " & RoomId
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    Public Sub SaveRooms(RoomId As Integer, RoomName As String, SortOrder As Integer, AllProcedureTypes As Boolean, OtherInvestigations As Boolean, HospitalId As Integer, UserId As Integer, RoomProcedures As String)
        DataAccess.ExecuteScalerSQL("Update_Room", CommandType.StoredProcedure, New SqlParameter() {
                                                New SqlParameter("@RoomId", RoomId),
                                                New SqlParameter("@RoomName", RoomName),
                                                New SqlParameter("@RoomSortOrder", SortOrder),
                                                New SqlParameter("@AllProcedureTypes", AllProcedureTypes),
                                                New SqlParameter("@OtherInvestigations", OtherInvestigations),
                                                New SqlParameter("@HospitalId", HospitalId),
                                                New SqlParameter("@User", UserId),
                                                New SqlParameter("@RoomProceduresString", RoomProcedures)})
    End Sub

    Public Function SuppressUser(UserId As String, Suppressed As Boolean) As Boolean
        Dim sql As String = "UPDATE [ERS_Users] SET [Suppressed] = " & IIf(Suppressed, 1, 0) & ", WhoUpdatedId = " & LoggedInUserId & ", WhenUpdated = GETDATE() WHERE [UserID]= " & UserId
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRoom(ByVal RoomId As Integer) As DataTable
        Dim sqlStr As String = "SELECT RoomId, RoomSortOrder, RoomName, AllProcedureTypes, OtherInvestigations, ISNULL(HospitalId,0) AS HospitalId, Suppressed FROM ERS_SCH_Rooms WHERE RoomId = " & RoomId
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetRoomProcedures() As DataTable
    '    Dim sqlStr As String = "SELECT 0 AS ProcedureTypeId, '' AS SchedulerProcName UNION SELECT ProcedureTypeId, SchedulerProcName FROM [dbo].[ERS_ProcedureTypes] " & _
    '        " WHERE SchedulerProc = 1 " & _
    '        " ORDER BY ProcedureTypeId"

    '    Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    'End Function

    Public Function GetProcedureTypeName(procedureTypeId As Integer) As String
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return (From p In db.ERS_ProcedureTypes Where p.ProcedureTypeId = procedureTypeId
                        Select p.ProcedureType).FirstOrDefault
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting procedure type name", ex)
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedureTypes(isGI As Boolean) As DataTable
        Dim sqlStr As String = "SELECT * FROM [dbo].[ERS_ProcedureTypes] p " &
            " WHERE p.SchedulerProc = 1 AND ISNULL(IsGI,1)=" & If(isGI, 1, 0)

        If isGI Then sqlStr += " And (SchedulerDiagnostic = 1 Or SchedulerTherapeutic = 1)"
        sqlStr += " ORDER BY p.ProcedureTypeId "

        Return DataAccess.ExecuteSQL(sqlStr, Nothing)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedureTypesForFilter(isGI As Boolean) As DataTable
        Dim sqlStr As String = "Select * from (Select Null as ProcedureTypeId, 'All Procedures' as ProcedureType Union SELECT ProcedureTypeId,ProcedureType FROM [dbo].[ERS_ProcedureTypes] p " &
            " WHERE p.SchedulerProc = 1 AND ISNULL(IsGI,1)=" & If(isGI, 1, 0)

        If isGI Then sqlStr += " And (SchedulerDiagnostic = 1 Or SchedulerTherapeutic = 1)) p"
        sqlStr += " ORDER BY p.ProcedureTypeId "

        Return DataAccess.ExecuteSQL(sqlStr, Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHospitalNameForFilter() As DataTable
        Dim sqlStr = "SELECT * FROM (SELECT NULL AS OperatingHospitalId, 'All Hospitals' as HospitalName UNION SELECT OperatingHospitalId, HospitalName FROM [ERS_OperatingHospitals] op
                        WHERE op.TrustId = " & CInt(HttpContext.Current.Session("TrustId"))
        sqlStr += " AND op.OperatingHospitalId IN (SELECT HospitalId FROM ERS_SCH_Rooms)) p ORDER BY p.OperatingHospitalId"

        Return DataAccess.ExecuteSQL(sqlStr, Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetListAppointments(ByVal diaryId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_list_appointments", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@DiaryId", .SqlDbType = SqlDbType.Int, .Value = diaryId})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetRoomProcedureTypes Error:" + ex.ToString(), ex)
            Return Nothing
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRoomProcedureTypes(ByVal RoomId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_room_proceduretypes_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomId", .SqlDbType = SqlDbType.Int, .Value = RoomId})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetRoomProcedureTypes Error:" + ex.ToString(), ex)
            Return Nothing
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRoomProcedureTypes(procTypeId As List(Of Integer)) As List(Of Integer?)
        Using db As New ERS.Data.GastroDbEntities

            Return (From procs In db.ERS_SCH_RoomProcedures
                    Where procTypeId.Contains(procs.ProcedureTypeId)
                    Select procs.RoomId Distinct).ToList

        End Using

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedureTypeAvailability(roomId As Integer, endoscopistId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_procedure_type_availability", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomId", .SqlDbType = SqlDbType.Int, .Value = roomId})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@EndoscopistId", .SqlDbType = SqlDbType.Int, .Value = endoscopistId})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetProcedureTypeAvailability Error:" + ex.ToString(), ex)
            Return Nothing
        End Try
    End Function

    Public Sub updateWaitlist(patientID As Integer, procedureTypeID As Integer)
        Try
            Dim sqlStr As String = "UPDATE ERS_Waiting_List SET WaitingListStatusId = 1 WHERE PatientId = @PatientId AND ProcedureTypeId = @ProcedureTypeId"
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sqlStr.ToString(), connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientID))
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeID))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("updateWaitlist Error: " + ex.ToString(), ex)
        End Try
    End Sub

#End Region

#Region "Diary Pages"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSchAppointments() As DataTable
        Dim sqlStr As String = "SELECT * FROM [dbo].[ERS_SCH_Appointments] "

        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    Public Function GetFreeDiarySlots(iDiaryId As Integer, selectedDate As DateTime) As DataTable
        Try
            Dim dt As New DataTable
            dt.Columns.Add("DiaryId", GetType(String)) '0 
            dt.Columns.Add("Subject", GetType(String)) '1
            dt.Columns.Add("SlotColor", GetType(String)) '2
            dt.Columns.Add("DiaryStart", GetType(DateTime)) '3
            dt.Columns.Add("DiaryEnd", GetType(DateTime)) '4
            dt.Columns.Add("UserID", GetType(Integer)) '5
            dt.Columns.Add("RoomID", GetType(Integer)) '6
            dt.Columns.Add("ListRulesID", GetType(Integer)) '7
            dt.Columns.Add("RecurrenceRule", GetType(String)) '8
            dt.Columns.Add("RecurrenceParentID", GetType(Integer)) '9
            dt.Columns.Add("Description", GetType(String)) '10
            dt.Columns.Add("ProcedureTypeID", GetType(Integer)) '11
            dt.Columns.Add("Points", GetType(Decimal)) '12
            dt.Columns.Add("StatusId", GetType(Integer)) '13
            dt.Columns.Add("SlotType", GetType(String)) '14
            dt.Columns.Add("SlotDuration", GetType(Integer)) '15
            dt.Columns.Add("OperatingHospitalId", GetType(Integer)) '16
            dt.Columns.Add("ListSlotId", GetType(Integer)) '17

            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_slots", connection)
                cmd.Parameters.Add(New SqlParameter("@DiaryId", iDiaryId))

                cmd.CommandType = CommandType.StoredProcedure

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            Using db As New ERS.Data.GastroDbEntities
                'Dim lockedLists = db.ERS_SCH_LockedDiaries.Where(Function(x) x.DiaryId = iDiaryId And x.DiaryDate = selectedDate And x.Locked = True) 'WE DONT NEED THIS. IF WE'RE PASSING IN THE DATE WE ALREADY KNOW THIS DATE IS AVAILABLE.. LOCKED DIARY CHECKS SHOULD BE DONE BEFORE THIS BIT

                If dsData.Tables.Count > 0 Then
                    Dim patientBooking As Boolean = False
                    Dim vals = (From d In dsData.Tables(0).AsEnumerable
                                Where d.IsNull("SuppressedFromDate") OrElse d("SuppressedFromDate") >= selectedDate
                                Order By d("DiaryId"), d("ListSlotId")
                                Group By ListRuleID = d("ListRulesId"), RoomID = d("RoomID"), UserID = d("UserID"), DiaryID = d("DiaryId"), OperatingHospitalId = d("OperatingHospitalId") Into g = Group
                                Select ListRuleID, RoomID, UserID, DiaryID, OperatingHospitalId, DataRows = g.ToList()).ToList()

                    For Each v In vals
                        Dim rowNum = 0
                        Dim diaryStart = CDate(v.DataRows(0)("DiaryStart"))
                        Dim slotStart = CDate(selectedDate.ToShortDateString & " " & diaryStart.ToShortTimeString)
                        Dim slotEnd = DateAdd(DateInterval.Minute, CInt(v.DataRows(0)("Minutes")), slotStart)
                        Dim slotDuration = 0
                        Dim extraDuration = 0

                        Dim exclusionDates As New List(Of String)

                        Dim dsPatientBookings As New DataSet
                        Using connection As New SqlConnection(DataAccess.ConnectionStr)
                            Dim cmd As New SqlCommand("sch_todays_patient_appointments", connection)
                            cmd.CommandType = CommandType.StoredProcedure
                            cmd.Parameters.Add(New SqlParameter("@DiaryId", iDiaryId))
                            cmd.Parameters.Add(New SqlParameter("@BookingDate", selectedDate))

                            Dim adapter = New SqlDataAdapter(cmd)
                            connection.Open()
                            adapter.Fill(dsPatientBookings)
                        End Using

                        If dsPatientBookings.Tables.Count > 0 AndAlso dsPatientBookings.Tables(0).Rows.Count > 0 Then
                            For Each dr As DataRow In dsPatientBookings.Tables(0).Rows
                                If CDate(dr("StartDateTime")).ToShortDateString = slotStart.ToShortDateString Then
                                    Dim bookingRow = dt.NewRow
                                    bookingRow("DiaryId") = dr("AppointmentId")
                                    bookingRow("Subject") = dr("ProcedureType") & " - " & dr("HospitalNumber") & " - " & dr("PatientName")
                                    bookingRow("SlotColor") = dr("Forecolor")
                                    bookingRow("DiaryStart") = dr("StartDateTime")
                                    bookingRow("DiaryEnd") = dr("bookingEnd")
                                    bookingRow("Description") = "(" & dr("SlotDescription") & ")"
                                    bookingRow("ProcedureTypeID") = 0
                                    bookingRow("StatusId") = 0
                                    bookingRow("RecurrenceRule") = DBNull.Value
                                    bookingRow("RecurrenceParentID") = iDiaryId
                                    bookingRow("ListRulesID") = v.ListRuleID
                                    bookingRow("UserID") = v.UserID
                                    bookingRow("RoomID") = v.RoomID
                                    bookingRow("Points") = 0
                                    bookingRow("StatusId") = dr("AppointmentStatusId")
                                    bookingRow("SlotType") = "PatientBooking"
                                    bookingRow("OperatingHospitalId") = dr("OperatingHospitalId")
                                    bookingRow("ListSlotId") = dr("ListSlotId")

                                    dt.Rows.Add(bookingRow)
                                End If
                            Next
                        End If


                        For Each dr In v.DataRows
                            slotDuration = CInt(dr("Minutes"))
                            Dim procTypeId As Integer = dr("ProcedureTypeID")
                            Dim slotSubject = slotStart.ToShortTimeString & " - " & dr("Subject")

                            If rowNum > 0 Then
                                Dim dv = dt.DefaultView
                                dv.Sort = "DiaryId, DiaryStart"
                                Dim sortedDT = dv.ToTable()

                                slotDuration = CInt(dr("Minutes")) - extraDuration
                                slotStart = slotEnd
                                slotEnd = DateAdd(DateInterval.Minute, slotDuration, slotStart)
                                slotSubject = slotStart.ToShortTimeString & " - " & dr("Subject")

                                If extraDuration > 0 Then
                                    procTypeId = 0
                                    slotSubject = slotStart.ToShortTimeString & " - " & dr("Description")
                                End If
                                If slotStart = slotEnd Then
                                    extraDuration = extraDuration - CInt(dr("Minutes"))
                                    Continue For
                                End If
                            End If

                            'If Not dt.AsEnumerable.Any(Function(x) x("DiaryStart") = slotStart Or (x("SlotType") = "PatientBooking" And slotStart >= x("DiaryStart") And slotStart < x("DiaryEnd"))) Then 'dont add if booking exists in this slot
                            If Not dt.AsEnumerable.Any(Function(x) x("DiaryStart") = slotStart Or (slotStart > x("DiaryStart") And slotEnd < x("DiaryEnd")) Or (slotStart > x("DiaryStart") And slotStart < x("DiaryEnd"))) Then 'dont add if booking exists in this slot

                                If dt.AsEnumerable.Any(Function(x) x("DiaryStart") > slotStart And x("DiaryStart") < slotEnd) Then
                                    Dim slotBooking = dt.AsEnumerable.Where(Function(x) x("DiaryStart") > slotStart And x("DiaryStart") < slotEnd).FirstOrDefault
                                    slotEnd = slotBooking("DiaryStart")
                                End If

                                Dim newRow = dt.NewRow
                                newRow("DiaryId") = v.DiaryID
                                newRow("Subject") = slotSubject
                                newRow("SlotColor") = dr("Forecolor")
                                newRow("DiaryStart") = slotStart
                                newRow("DiaryEnd") = slotEnd
                                newRow("Description") = ""
                                newRow("ProcedureTypeID") = procTypeId
                                newRow("StatusId") = dr("StatusId")
                                newRow("RecurrenceRule") = ""
                                newRow("RecurrenceParentID") = dr("RecurrenceParentID")
                                newRow("ListRulesID") = v.ListRuleID
                                newRow("UserID") = v.UserID
                                newRow("RoomID") = v.RoomID
                                newRow("Points") = dr("Points") ' "(" & If(dr("Points") Mod 1 = 0, CInt(dr("Points")) & If(CInt(dr("Points")) = 1, " point", " points"), dr("Points") & " points") & ")"
                                newRow("SlotType") = "FreeSlot"
                                newRow("SlotDuration") = slotDuration
                                newRow("OperatingHospitalId") = v.OperatingHospitalId
                                newRow("ListSlotId") = dr("ListSlotId")
                                dt.Rows.Add(newRow)
                                extraDuration = 0
                            Else
                                Dim slotBooking = dt.AsEnumerable.Where(Function(x) x("DiaryStart") = slotStart Or (slotStart > x("DiaryStart") And slotEnd < x("DiaryEnd")) Or (slotStart > x("DiaryStart") And slotStart < x("DiaryEnd"))).FirstOrDefault

                                If slotEnd < slotBooking("DiaryEnd") Then
                                    extraDuration = DateDiff(DateInterval.Minute, slotEnd, slotBooking("DiaryEnd")) 'how mny minutes appointments overrun by (this will be deducted from the next slots appointment minutes)
                                    slotEnd = slotBooking("DiaryEnd")
                                End If
                            End If
                            rowNum += 1
                        Next
                    Next
                End If
            End Using
            Return dt
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetFreeDiarySlots: " + ex.ToString(), ex)
            Return Nothing
        End Try
    End Function

    Friend Function SearchPatients(CaseNoteNo As String, nhsNo As String, surname As String, forename As String) As Object
        Dim dsData As New DataSet
        'Mahfuz added IsNull(Deceased,0) = 0 on 25 May 2021
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sqlStr As String = "SELECT PatientId, Title, Forename1, Surname, NHSNo, DateOfBirth, "
            sqlStr += "STUFF((SELECT DISTINCT ', '+HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId for xml path('')), 1, 2, '') AS HospitalNumber, "
            sqlStr += "dbo.fnGender(p.GenderId) as Gender FROM dbo.ERS_Patients p WHERE IsNull(Deceased,0) = 0 And"

            'If Not String.IsNullOrWhiteSpace(CaseNoteNo) Then sqlStr += " (p.patientId in (Select patientId from ERS_PatientTrusts where HospitalNumber Like '%" & Trim(CaseNoteNo) & "%')) AND"
            'TFS 2020 search for hospital number needs to be an exact match
            If Not String.IsNullOrWhiteSpace(CaseNoteNo) Then sqlStr += " (p.patientId in (Select patientId from ERS_PatientTrusts where HospitalNumber = '" & Trim(CaseNoteNo) & "')) AND"
            If Not String.IsNullOrWhiteSpace(nhsNo) Then sqlStr += " REPLACE(NHSNo, ' ','') = '" & Trim(nhsNo.Replace(" ", "")) & "' AND"
            If Not String.IsNullOrWhiteSpace(surname) Then sqlStr += " Surname like '%" & Trim(surname) & "%' AND"
            If Not String.IsNullOrWhiteSpace(forename) Then sqlStr += " Forename1 like '%" & Trim(forename) & "%' AND"

            If sqlStr.ToLower.EndsWith("and") Then sqlStr = sqlStr.Remove(sqlStr.ToLower.LastIndexOf("and"))
            '"WHERE [HospitalNumber] = '" & CaseNoteNo & "'"

            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiarySlots(OperatingHospitalId As Integer, hideCancelledBookings As Boolean, Optional selectedRoomId As Integer = 0) As DataTable
        Try
            Dim dt As New DataTable
            dt.Columns.Add("DiaryId", GetType(String))
            dt.Columns.Add("AppointmentId", GetType(String))
            dt.Columns.Add("Subject", GetType(String))
            dt.Columns.Add("SlotColor", GetType(String))
            dt.Columns.Add("DiaryStart", GetType(DateTime))
            dt.Columns.Add("DiaryEnd", GetType(DateTime))
            dt.Columns.Add("SlotDuration", GetType(Integer))
            dt.Columns.Add("UserID", GetType(Integer))
            dt.Columns.Add("RoomID", GetType(Integer))
            dt.Columns.Add("ListRulesID", GetType(Integer))
            dt.Columns.Add("RecurrenceRule", GetType(String))
            dt.Columns.Add("RecurrenceParentID", GetType(Integer))
            dt.Columns.Add("Description", GetType(String))
            dt.Columns.Add("ProcedureTypeID", GetType(Integer))
            dt.Columns.Add("Points", GetType(String))
            dt.Columns.Add("StatusId", GetType(String))
            dt.Columns.Add("StatusCode", GetType(String))
            dt.Columns.Add("SlotType", GetType(String))
            dt.Columns.Add("Notes", GetType(String))
            dt.Columns.Add("GeneralInfo", GetType(String))
            dt.Columns.Add("ParentId", GetType(Integer))
            dt.Columns.Add("EndoscopistId", GetType(Integer))
            dt.Columns.Add("EndoscopistName", GetType(String))
            dt.Columns.Add("OperatingHospitalId", GetType(Integer))

            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_appointment_slots", connection)
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalId))
                cmd.CommandType = CommandType.StoredProcedure

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Dim vals = (From d In dsData.Tables(0).AsEnumerable
                            Order By d("DiaryId"), d("ListSlotId")
                            Group By ListRuleID = d("ListRulesId"), RoomID = d("RoomID"), UserID = d("UserID"), DiaryID = d("DiaryId"), ListName = d("ListName"), ListDescription = d("ListDescription") Into g = Group
                            Select ListRuleID, RoomID, UserID, DiaryID, ListName, ListDescription, DataRows = g.ToList()).ToList()

                For Each v In vals
                    If selectedRoomId > 0 Then
                        If v.RoomID <> selectedRoomId Then Continue For
                    End If

                    Dim rowNum = 0
                    Dim diaryStart = CDate(v.DataRows(0)("DiaryStart"))
                    Dim slotStart = diaryStart
                    Dim slotEnd = DateAdd(DateInterval.Minute, CInt(v.DataRows(0)("Minutes")), slotStart)
                    Dim iDiaryId = CInt(v.DiaryID)

                    Dim exclusionDates As New List(Of String)

                    Dim dsPatientBookings As New DataSet
                    Dim dtPatientBookings As New DataTable

                    Using connection As New SqlConnection(DataAccess.ConnectionStr)
                        Dim cmd As New SqlCommand("sch_patient_appointments", connection)
                        cmd.CommandType = CommandType.StoredProcedure
                        cmd.Parameters.Add(New SqlParameter("@DiaryId", iDiaryId))

                        Dim adapter = New SqlDataAdapter(cmd)
                        connection.Open()
                        adapter.Fill(dsPatientBookings)
                    End Using

                    If dsPatientBookings.Tables.Count > 0 AndAlso dsPatientBookings.Tables(0).Rows.Count > 0 Then
                        dtPatientBookings = dsPatientBookings.Tables(0)

                        For Each dr As DataRow In dsPatientBookings.Tables(0).Rows
                            If (hideCancelledBookings And Not dr("AppointmentStatusCode") = "C" And Not (dr("AppointmentStatusCode") = "H" And dr("StaffAccessedId") = LoggedInUserId)) Then
                                Dim DescriptionPrefix As String = ""
                                Dim bookingRow = dt.NewRow
                                bookingRow("DiaryId") = v.DiaryID
                                bookingRow("AppointmentId") = dr("AppointmentId")
                                If Not dr.IsNull("AppointmentStatusCode") AndAlso Not String.IsNullOrEmpty(dr("AppointmentStatusCode")) Then
                                    If dr("AppointmentStatusCode") = "P" Then
                                        DescriptionPrefix = "(PB) "
                                    Else
                                        DescriptionPrefix = "(PC) "
                                    End If
                                End If

                                'If dr("AppointmentStatusCode") = "H" Then
                                '    bookingRow("Subject") = "BOOKING IN PROGRESS - NOT AVAILABLE"
                                '    bookingRow("SlotType") = "ReservedSlot"
                                'Else
                                bookingRow("Subject") = DescriptionPrefix & dr("ProcedureType") & " - " & dr("HospitalNumber") & " - " & dr("PatientName")
                                bookingRow("SlotType") = "PatientBooking"
                                'End If

                                bookingRow("SlotColor") = dr("Forecolor")
                                bookingRow("DiaryStart") = dr("StartDateTime")
                                bookingRow("DiaryEnd") = dr("bookingEnd")
                                bookingRow("SlotDuration") = dr("AppointmentDuration")
                                bookingRow("Description") = v.ListName & "<br />" & v.ListDescription
                                bookingRow("ProcedureTypeID") = 0
                                bookingRow("RecurrenceRule") = DBNull.Value
                                bookingRow("RecurrenceParentID") = iDiaryId
                                bookingRow("ListRulesID") = v.ListRuleID
                                bookingRow("UserID") = v.UserID
                                bookingRow("RoomID") = v.RoomID
                                bookingRow("Points") = 0
                                bookingRow("StatusId") = dr("AppointmentStatusId")
                                bookingRow("StatusCode") = dr("AppointmentStatusCode")
                                bookingRow("Notes") = dr("Notes")
                                bookingRow("GeneralInfo") = dr("GeneralInformation")
                                bookingRow("EndoscopistId") = dr("EndoscopistId")
                                bookingRow("EndoscopistName") = dr("EndoscopistName")
                                bookingRow("OperatingHospitalId") = dr("OperatingHospitalId")

                                dt.Rows.Add(bookingRow)
                                'amend new rule to include exdate being the booking date
                                exclusionDates.Add(CDate(dr("StartDateTime")).ToString("yyyyMMdd") & "T" & CDate(dr("StartDateTime")).ToString("HHmmss") & "Z")
                            End If
                        Next

                    End If

                    For Each dr In v.DataRows
                        'check for appointments and work out new slotStart date based on appointment start/end date and duration
                        Dim newRule = dr("RecurrenceRule").ToString()

                        If rowNum > 0 Then
                            Dim dv = dt.DefaultView
                            dv.Sort = "DiaryStart"
                            Dim sortedDT = dv.ToTable()

                            slotStart = slotEnd ' CDate(dt.Rows(dt.Rows.Count - 1)("DiaryEnd"))
                            slotEnd = DateAdd(DateInterval.Minute, CInt(dr("Minutes")), slotStart)
                        End If

                        If Not dr.IsNull("RecurrenceRule") Then
                            Dim ruleStartDate = ""
                            Dim ruleEndDate = ""
                            Dim ruleUntilDate = ""

                            Dim rRule As RecurrenceRule

                            RecurrenceRule.TryParse(dr("RecurrenceRule"), rRule)

                            'Start date fix
                            ruleStartDate = dr("RecurrenceRule").ToString().Substring(dr("RecurrenceRule").IndexOf("DTSTART:") + 8)
                            ruleStartDate = ruleStartDate.Substring(0, ruleStartDate.IndexOf("DTEND")).Trim()

                            Dim ruleStartTime = ruleStartDate.Substring(ruleStartDate.IndexOf("T") + 1).Trim()
                            newRule = newRule.Replace("DTSTART:" & ruleStartDate, "DTSTART:" & ruleStartDate.Split("T")(0) & "T" & slotStart.ToString("HHmmss") + "Z")

                            'End date fix
                            ruleEndDate = dr("RecurrenceRule").ToString().Substring(dr("RecurrenceRule").IndexOf("DTEND:") + 6)
                            ruleEndDate = ruleEndDate.Substring(0, ruleEndDate.IndexOf("RRULE")).Trim()

                            Dim ruleEndTime = ruleEndDate.Substring(ruleEndDate.IndexOf("T") + 1).Trim()
                            newRule = newRule.Replace("DTEND:" & ruleEndDate, "DTEND:" & ruleEndDate.Split("T")(0) & "T" & slotEnd.ToString("HHmmss") + "Z")

                            If dr("RecurrenceRule").ToString().Contains("UNTIL") Then
                                ruleUntilDate = dr("RecurrenceRule").ToString().Substring(dr("RecurrenceRule").IndexOf("UNTIL=") + 6)
                                ruleUntilDate = ruleUntilDate.Substring(0, ruleUntilDate.IndexOf(";")).Trim()
                                Dim newUntilDate = ruleUntilDate.Split("T")(0) & "T235959Z"
                                newRule = newRule.Replace("UNTIL=" & ruleUntilDate, "UNTIL=" & newUntilDate)
                            End If

                            'If exclusionDates.Count > 0 Then newRule += "EXDATE:" & String.Join(",", exclusionDates) & vbCrLf
                        Else
                            Dim dayRule As String = ""
                            dayRule += "DTSTART:" & CDate(dr("DiaryStart")).ToString("yyyyMMddT") & slotStart.ToString("HHmmssZ") & vbCrLf
                            dayRule += "DTEND:" & CDate(dr("DiaryEnd")).ToString("yyyyMMddT") & slotEnd.ToString("HHmmssZ") & vbCrLf
                            dayRule += "RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=" & CDate(dr("DiaryStart")).DayOfWeek.ToString.Substring(0, 2).ToUpper() & vbCrLf

                            newRule = dayRule
                        End If

                        If exclusionDates.Count > 0 Then newRule += "EXDATE:" & String.Join(",", exclusionDates) & vbCrLf

                        Dim newRow = dt.NewRow
                        newRow("DiaryId") = v.DiaryID
                        newRow("AppointmentId") = 0
                        newRow("Subject") = slotStart.ToShortTimeString & " - " & dr("Subject")
                        newRow("SlotColor") = dr("Forecolor")
                        newRow("DiaryStart") = slotStart
                        newRow("DiaryEnd") = slotEnd
                        newRow("SlotDuration") = dr("Minutes")
                        newRow("Description") = v.ListName & "<br />" & v.ListDescription
                        newRow("ProcedureTypeID") = dr("ProcedureTypeID")
                        newRow("StatusId") = dr("StatusId")
                        newRow("RecurrenceRule") = newRule
                        newRow("RecurrenceParentID") = dr("RecurrenceParentID")
                        newRow("ListRulesID") = v.ListRuleID
                        newRow("UserID") = v.UserID
                        newRow("RoomID") = v.RoomID
                        newRow("Points") = "(" & If(dr("Points") Mod 1 = 0, CInt(dr("Points")) & If(CInt(dr("Points")) = 1, " point", " points"), dr("Points") & " points") & ")"
                        newRow("SlotType") = "FreeSlot"
                        newRow("Notes") = ""
                        newRow("GeneralInfo") = ""
                        newRow("EndoscopistId") = dr("EndoscopistId")
                        newRow("OperatingHospitalId") = OperatingHospitalId
                        dt.Rows.Add(newRow)


                        'If Not dt.AsEnumerable.Any(Function(x) x("DiaryStart") = slotStart Or (slotStart > x("DiaryStart") And slotEnd < x("DiaryEnd")) Or (slotStart > x("DiaryStart") And slotStart < x("DiaryEnd"))) Then 'dont add if booking exists in this slot


                        '    Dim newRow = dt.NewRow
                        '    newRow("DiaryId") = v.DiaryID
                        '    newRow("AppointmentId") = 0
                        '    newRow("Subject") = slotStart.ToShortTimeString & " - " & dr("Subject")
                        '    newRow("SlotColor") = dr("Forecolor")
                        '    newRow("DiaryStart") = slotStart
                        '    newRow("DiaryEnd") = slotEnd
                        '    newRow("SlotDuration") = dr("Minutes")
                        '    newRow("Description") = v.ListName & "<br />" & v.ListDescription
                        '    newRow("ProcedureTypeID") = dr("ProcedureTypeID")
                        '    newRow("StatusId") = dr("StatusId")
                        '    newRow("RecurrenceRule") = newRule
                        '    newRow("RecurrenceParentID") = dr("RecurrenceParentID")
                        '    newRow("ListRulesID") = v.ListRuleID
                        '    newRow("UserID") = v.UserID
                        '    newRow("RoomID") = v.RoomID
                        '    newRow("Points") = "(" & If(dr("Points") Mod 1 = 0, CInt(dr("Points")) & If(CInt(dr("Points")) = 1, " point", " points"), dr("Points") & " points") & ")"
                        '    newRow("SlotType") = "FreeSlot"
                        '    newRow("Notes") = ""
                        '    newRow("GeneralInfo") = ""
                        '    newRow("EndoscopistId") = dr("EndoscopistId")

                        '    dt.Rows.Add(newRow)
                        'Else
                        '    Dim slotBooking = dt.AsEnumerable.Where(Function(x) x("DiaryStart") = slotStart Or (slotStart > x("DiaryStart") And slotEnd < x("DiaryEnd")) Or (slotStart > x("DiaryStart") And slotStart < x("DiaryEnd"))).FirstOrDefault
                        '    If slotEnd < slotBooking("DiaryEnd") Then
                        '        'start date is now the end date of this
                        '        slotEnd = slotBooking("DiaryEnd")

                        '    End If
                        'End If


                        rowNum += 1
                    Next
                    Dim lastRowRule = ""

                    Dim dataView = dt.DefaultView
                    dataView.Sort = "DiaryStart desc"
                    Dim sortedDV = dataView.ToTable()

                    'slotEnd = (From r In sortedDV.AsEnumerable
                    '           Where r("DiaryId") = v.DiaryID
                    '           Select r("DiaryEnd")).FirstOrDefault() 'sortedDV.Rows(0)..AsEnumerable.Where(Function(x) x("DiaryId") = v.DiaryID).Select(Function(x) x("DiaryEnd")'.FirstOrDefault()

                    Dim diaryRecurrenceRule = vals.Where(Function(x) x.DiaryID = v.DiaryID).FirstOrDefault.DataRows(0)

                    If Not diaryRecurrenceRule.IsNull("RecurrenceRule") Then
                        Dim dr = diaryRecurrenceRule
                        lastRowRule = dr("RecurrenceRule")
                        Dim ruleStartDate = ""
                        Dim ruleEndDate = ""
                        Dim ruleUntilDate = ""

                        'Start date fix
                        ruleStartDate = dr("RecurrenceRule").ToString().Substring(dr("RecurrenceRule").IndexOf("DTSTART:") + 8)
                        ruleStartDate = ruleStartDate.Substring(0, ruleStartDate.IndexOf("DTEND")).Trim()

                        Dim ruleStartTime = ruleStartDate.Substring(ruleStartDate.IndexOf("T") + 1).Trim()
                        lastRowRule = lastRowRule.Replace("DTSTART:" & ruleStartDate, "DTSTART:" & ruleStartDate.Split("T")(0) & "T" & slotEnd.ToString("HHmmss") + "Z")

                        'End date fix
                        ruleEndDate = dr("RecurrenceRule").ToString().Substring(dr("RecurrenceRule").IndexOf("DTEND:") + 6)
                        ruleEndDate = ruleEndDate.Substring(0, ruleEndDate.IndexOf("RRULE")).Trim()

                        Dim ruleEndTime = ruleEndDate.Substring(ruleEndDate.IndexOf("T") + 1).Trim()
                        lastRowRule = lastRowRule.Replace("DTEND:" & ruleEndDate, "DTEND:" & ruleEndDate.Split("T")(0) & "T" & slotEnd.AddMinutes(15).ToString("HHmmss") + "Z")

                        If dr("RecurrenceRule").ToString().Contains("UNTIL") Then
                            ruleUntilDate = dr("RecurrenceRule").ToString().Substring(dr("RecurrenceRule").IndexOf("UNTIL=") + 6)
                            ruleUntilDate = ruleUntilDate.Substring(0, ruleUntilDate.IndexOf(";")).Trim()
                            Dim newUntilDate = ruleUntilDate.Split("T")(0) & "T235959Z"
                            lastRowRule = lastRowRule.Replace("UNTIL=" & ruleUntilDate, "UNTIL=" & newUntilDate)
                        End If
                        If exclusionDates.Count > 0 Then lastRowRule += "EXDATE:" & String.Join(",", exclusionDates) & vbCrLf
                    End If


                    If slotEnd.AddMinutes(15).Day = slotEnd.Day Then
                        Dim lastRow = dt.NewRow
                        lastRow("DiaryId") = v.DiaryID
                        lastRow("Subject") = "----------End of list----------"
                        lastRow("SlotColor") = "#3e9ed6"
                        lastRow("DiaryStart") = slotEnd
                        lastRow("DiaryEnd") = slotEnd.AddMinutes(15)
                        lastRow("SlotDuration") = 15
                        lastRow("Description") = ""
                        lastRow("ProcedureTypeID") = 0
                        lastRow("StatusId") = 1
                        lastRow("RecurrenceRule") = lastRowRule
                        lastRow("RecurrenceParentID") = DBNull.Value
                        lastRow("ListRulesID") = v.ListRuleID
                        lastRow("UserID") = v.UserID
                        lastRow("RoomID") = v.RoomID
                        lastRow("Points") = ""
                        lastRow("SlotType") = "EndOfList"
                        lastRow("Notes") = ""
                        lastRow("GeneralInfo") = ""
                        lastRow("EndoscopistId") = 0
                        lastRow("OperatingHospitalId") = OperatingHospitalId

                        rowNum += 1
                        dt.Rows.Add(lastRow)
                    End If
                Next


            End If

            Return dt
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    'Public Function GetDiaryDetails(diaryId As Integer) As DataTable
    '    Dim dsData As New DataSet
    '    'Mahfuz added IsNull(Deceased,0) = 0 on 25 May 2021
    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("sch_get_diary_details", connection)
    '        cmd.CommandType = CommandType.StoredProcedure

    '        Dim adapter = New SqlDataAdapter(cmd)
    '        connection.Open()
    '        adapter.Fill(dsData)
    '    End Using

    '    If dsData.Tables.Count > 0 Then
    '        Return dsData.Tables(0)
    '    End If
    '    Return Nothing
    'End Function
    Public Function GetDiaryOverView(month As Integer, year As Integer, operatingHospitalId As Integer) As DataTable
        Try
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_overview_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
                cmd.Parameters.Add(New SqlParameter("@Month", month))
                cmd.Parameters.Add(New SqlParameter("@Year", year))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getDiaryList(dt As DataTable, diaryDate As DateTime) As List(Of DiaryDayList)
        Dim diaryLists = (From d In dt.AsEnumerable
                          Order By d("DiaryId"), d("ListSlotId")
                          Group By ListRuleID = d("ListRulesId"), RoomID = d("RoomID"), UserID = d("UserID"), EndoscopistName = d("EndoscopistName"), DiaryID = d("DiaryId"), ListName = d("ListName"), ListDescription = d("ListDescription"), DiaryStartDate = d("DiaryStart"), DiaryEndDate = d("DiaryEnd"), LockedDiary = d("LockedDiary"), RoomName = d("RoomName")
                              Into g = Group
                          Select New DiaryDayList() With {.ListRuleId = ListRuleID, .RoomId = RoomID, .RoomName = RoomName, .UserId = UserID, .EndoscopistName = EndoscopistName, .DiaryId = DiaryID, .ListName = ListName, .DiaryStartDate = DiaryStartDate, .DiaryEndDate = DiaryEndDate,
                              .LockedDiary = LockedDiary, .ListSlots = g.ToList()}).ToList()

        Return diaryLists
    End Function

    Public Structure DiaryDayList
        Property ListRuleId As Integer
        Property RoomId As Integer
        Property RoomName As String
        Property UserId As Integer
        Property EndoscopistName As String
        Property DiaryId As Integer
        Property ListName As String
        Property ListDescription As String
        Property DiaryStartDate As DateTime
        Property DiaryEndDate As DateTime
        Property LockedDiary As Boolean
        Property ListSlots As List(Of DataRow)
    End Structure


    Public Function GetDayDiaries(OperatingHospitalId As Integer, hideCancelledBookings As Boolean, diaryDate As DateTime, Optional selectedRoomIds As List(Of Integer) = Nothing) As DataTable
        Try
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_day_diary", connection)
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@DiaryDate", diaryDate))
                cmd.Parameters.Add(New SqlParameter("@RoomIds", String.Join(",", selectedRoomIds)))
                cmd.CommandType = CommandType.StoredProcedure

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetDiariesByDates(OperatingHospitalId As Integer, hideCancelledBookings As Boolean, diaryDates As String) As DataTable
        Try
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_diaries_by_dates", connection)
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@DiaryDates", diaryDates))
                cmd.CommandType = CommandType.StoredProcedure

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function GetEndoscopistDayDiaries(EndoscopistId As Integer, diaryDate As DateTime) As DataTable
        Try
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_user_day_diary", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
                cmd.Parameters.Add(New SqlParameter("@DiaryDate", diaryDate))
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", EndoscopistId))

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function EndosopistsDiaryDatesOverlap(EndoscopistId As Integer, diaryStart As DateTime, diaryEnd As DateTime) As DataTable
        Try
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_overlapped_diaries", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@UserId", EndoscopistId))
                cmd.Parameters.Add(New SqlParameter("@DiaryStart", diaryStart))
                cmd.Parameters.Add(New SqlParameter("@DiaryEnd", diaryEnd))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetEndosopistsDiaries(EndoscopistId As Integer, startDate As DateTime, endDate As DateTime) As DataTable
        Try
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_endoscopists_diaries", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", EndoscopistId))
                cmd.Parameters.Add(New SqlParameter("@StartDate", startDate))
                cmd.Parameters.Add(New SqlParameter("@EndDate", endDate))

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetDiaryDaySlots(OperatingHospitalId As Integer, hideCancelledBookings As Boolean, diaryDate As DateTime, Optional selectedRoomIds As List(Of Integer) = Nothing) As DataTable
        Try
            Dim dtDiaries As New DataTable
            dtDiaries.Columns.Add("DiaryId", GetType(String))
            dtDiaries.Columns.Add("AppointmentId", GetType(String))
            dtDiaries.Columns.Add("Subject", GetType(String))
            dtDiaries.Columns.Add("SlotColor", GetType(String))
            dtDiaries.Columns.Add("DiaryStart", GetType(DateTime))
            dtDiaries.Columns.Add("DiaryEnd", GetType(DateTime))
            dtDiaries.Columns.Add("SlotDuration", GetType(Integer))
            dtDiaries.Columns.Add("UserID", GetType(Integer))
            dtDiaries.Columns.Add("RoomID", GetType(Integer))
            dtDiaries.Columns.Add("ListRulesID", GetType(Integer))
            dtDiaries.Columns.Add("ListSlotId", GetType(Integer))
            dtDiaries.Columns.Add("Description", GetType(String))
            dtDiaries.Columns.Add("ProcedureTypeID", GetType(Integer))
            dtDiaries.Columns.Add("Points", GetType(Decimal))
            dtDiaries.Columns.Add("StatusId", GetType(String))
            dtDiaries.Columns.Add("StatusCode", GetType(String))
            dtDiaries.Columns.Add("SlotType", GetType(String))
            dtDiaries.Columns.Add("Notes", GetType(String))
            dtDiaries.Columns.Add("GeneralInfo", GetType(String))
            dtDiaries.Columns.Add("ParentId", GetType(Integer))
            dtDiaries.Columns.Add("EndoscopistId", GetType(Integer))
            dtDiaries.Columns.Add("EndoscopistName", GetType(String))
            dtDiaries.Columns.Add("SlotSubject", GetType(String))
            dtDiaries.Columns.Add("OperatingHospitalId", GetType(Integer))
            dtDiaries.Columns.Add("Locked", GetType(Boolean))
            dtDiaries.Columns.Add("LockedDiary", GetType(Boolean))

            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_day_diary", connection)
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@DiaryDate", diaryDate))
                cmd.Parameters.Add(New SqlParameter("@RoomIds", String.Join(",", selectedRoomIds)))
                cmd.CommandType = CommandType.StoredProcedure

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            Dim dt As New DataTable
            If dsData.Tables.Count > 0 Then
                dt = dsData.Tables(0)
            End If

            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                Dim diaryLists = getDiaryList(dt, diaryDate)


                'filter rooms
                If selectedRoomIds IsNot Nothing AndAlso selectedRoomIds.Count > 0 Then
                    diaryLists = diaryLists.Where(Function(x) selectedRoomIds.Contains(CInt(x.RoomId))).ToList
                End If


                For Each lst In diaryLists
                    Dim listStart As DateTime = CDate(lst.DiaryStartDate)
                    Dim listEnd As DateTime = CDate(lst.DiaryEndDate)
                    Dim listName As String = listStart.ToShortTimeString & " - " & lst.ListName

                    Dim slotStart As DateTime = CDate(lst.DiaryStartDate)
                    Dim slotEnd As DateTime = Nothing
                    Dim slotDuration As Integer = 0
                    Dim extraDuration As Integer = 0
                    Dim iDiaryId = CInt(lst.DiaryId)


                    'get individual slots
                    For Each dr In lst.ListSlots
                        'add new row
                        Dim newRow = dtDiaries.NewRow

                        Dim procTypeId As Integer = dr("ProcedureTypeId")
                        Dim slotSubject = slotStart.ToShortTimeString & " - " & dr("Subject")

                        slotDuration = CInt(dr("Minutes")) '- extraDuration
                        slotEnd = slotStart.AddMinutes(slotDuration)

                        'check if the previous slot overran into another. the extra duration would've been calculated and added when the appointment adding process was complete
                        If extraDuration > 0 Then
                            'this would've been from an overflowed appointment's extra duration going until the end of this appointment. Therefore we no longer need it
                            If slotStart = slotEnd Then
                                Continue For
                            End If

                            slotDuration = slotDuration - extraDuration

                            If slotDuration < 0 Then 'has all of the minutes have been used up for this slot. (in this scenario the appointment would've used 1 whole slot and some of the one after(maybe even all of it)
                                'calculate how much more the appointment overran by
                                extraDuration = extraDuration - CInt(dr("Minutes"))
                                Continue For
                            ElseIf slotDuration = 0 Then
                                extraDuration = 0
                                Continue For
                            Else
                                'If Only go past the end of the List if there is an appointment, otherwise stop the slot at the end of the list
                                If dr.IsNull("AppointmentId") OrElse CInt(dr("AppointmentId")) = 0 AndAlso slotEnd > CDate(dr("DiaryEnd")) Then
                                    slotEnd = CDate(dr("DiaryEnd"))
                                Else
                                    slotEnd = slotStart.AddMinutes(slotDuration)
                                End If
                            End If
                        Else
                            If slotEnd > CDate(dr("DiaryEnd")) Then
                                slotEnd = CDate(dr("DiaryEnd"))
                            End If
                        End If

                        'if appointment id is 0, check if theres an appointment in the list that starts at this time. if so skip, eventually we'll get to it and fall out of this loop as the appointment id will no longer be 0
                        If dr.IsNull("AppointmentId") OrElse CInt(dr("AppointmentId")) = 0 Then
                            If lst.ListSlots.Any(Function(x) x("AppointmentId") > 0 AndAlso x("AppointmentStart") = slotStart) Then
                                Continue For
                            End If

                            'check if theres an appointment with an end date in between these times. we need to adjust the durations if so
                            Dim ap = dtDiaries.AsEnumerable.Where(Function(x) x("DiaryId") = iDiaryId And x("AppointmentId") > 0 And (x("DiaryEnd") >= slotStart And x("DiaryEnd") < slotEnd)).FirstOrDefault
                            If ap IsNot Nothing Then
                                slotDuration = DateDiff(DateInterval.Minute, ap("DiaryEnd"), slotEnd)
                            End If
                        End If

                        Dim iAppointmentId = 0
                        If Not dr.IsNull("AppointmentId") AndAlso CInt(dr("AppointmentId")) > 0 Then
                            'Check If appointment starts after slot start time - 
                            If slotStart < CDate(dr("AppointmentStart")) Then
                                slotEnd = CDate(dr("AppointmentStart"))
                                slotDuration = DateDiff(DateInterval.Minute, slotStart, slotEnd)

                                newRow("DiaryId") = lst.DiaryId
                                newRow("AppointmentId") = 0
                                newRow("Subject") = slotSubject
                                newRow("SlotColor") = dr("Forecolor")
                                newRow("DiaryStart") = slotStart
                                newRow("DiaryEnd") = slotEnd
                                newRow("SlotDuration") = slotDuration
                                newRow("Description") = slotSubject
                                newRow("ProcedureTypeID") = procTypeId
                                newRow("StatusId") = dr("StatusId")
                                newRow("StatusCode") = ""
                                newRow("ListRulesID") = lst.ListRuleId
                                newRow("ListSlotId") = dr("ListSlotId")
                                newRow("UserID") = lst.UserId
                                newRow("RoomID") = lst.RoomId
                                newRow("Points") = dr("Points")
                                newRow("SlotType") = "FreeSlot"
                                newRow("Notes") = ""
                                newRow("GeneralInfo") = ""
                                newRow("EndoscopistId") = lst.UserId
                                newRow("SlotSubject") = dr("Subject")
                                newRow("OperatingHospitalId") = OperatingHospitalId
                                newRow("Locked") = CBool(dr("Locked"))
                                newRow("LockedDiary") = CBool(lst.LockedDiary)
                                extraDuration = 0

                                dtDiaries.Rows.Add(newRow)

                                newRow = dtDiaries.NewRow
                            End If
                            'create a New slot - end time Is appointment start time
                            'add to datatable

                            Dim DescriptionPrefix = ""

                            'check if start time is directly after the last slot. If not create a new slot and add
                            'If CDate(dr("AppointmentStart")) > slotStart Then
                            If Not dr.IsNull("AppointmentStatusCode") AndAlso Not String.IsNullOrEmpty(dr("AppointmentStatusCode")) Then
                                If dr("AppointmentId") And dr("AppointmentStatusCode") = "P" Then
                                    DescriptionPrefix = "(PB) "
                                Else
                                    DescriptionPrefix = "(PC) "
                                End If
                            End If

                            slotStart = CDate(dr("AppointmentStart"))
                            slotEnd = CDate(dr("AppointmentEnd"))
                            slotDuration = DateDiff(DateInterval.Minute, slotStart, slotEnd)
                            slotSubject = slotStart.ToShortTimeString & "-" & slotEnd.ToShortTimeString & " - " & DescriptionPrefix & dr("AppointmentSubject") & " " & dr("AppointmentProcedures")

                            Dim usedSlot = dtDiaries.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And CDate(x("DiaryStart")) = slotStart).FirstOrDefault
                            If usedSlot IsNot Nothing Then
                                dtDiaries.Rows.Remove(usedSlot)
                            End If


                        Else
                            'check if an appointment starts before the end of the slot
                            Dim appointmentSlot = lst.ListSlots.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And x("AppointmentId") > 0 And Not x.IsNull("AppointmentStart") AndAlso ((CDate(x("AppointmentStart")) > slotStart) And (CDate(x("AppointmentStart")) < slotEnd))).FirstOrDefault
                            If appointmentSlot IsNot Nothing Then
                                slotEnd = CDate(appointmentSlot("AppointmentStart"))
                                slotDuration = DateDiff(DateInterval.Minute, slotStart, slotEnd)
                            End If
                        End If

                        newRow("DiaryId") = lst.DiaryId
                        newRow("AppointmentId") = dr("AppointmentId")
                        newRow("Subject") = slotSubject
                        newRow("SlotColor") = dr("Forecolor")
                        newRow("DiaryStart") = slotStart
                        newRow("DiaryEnd") = slotEnd
                        newRow("SlotDuration") = slotDuration
                        newRow("Description") = If(dr.IsNull("AppointmentStart"), "", CDate(dr("AppointmentStart")).ToShortTimeString & "-" &
                                        CDate(dr("AppointmentEnd")).ToShortTimeString & " - " &
                                        dr("AppointmentSubject") & " - " &
                                        dr("AppointmentProcedures") & "<br />" &
                                        "Booked by " & dr("StaffBooked") & " on " & dr("DateBooked")) 'slotSubject
                        newRow("ProcedureTypeID") = procTypeId
                        newRow("StatusId") = dr("StatusId")
                        newRow("StatusCode") = If(dr.IsNull("AppointmentId"), "", dr("AppointmentStatusCode"))
                        newRow("ListRulesID") = lst.ListRuleId
                        newRow("ListSlotId") = dr("ListSlotId")
                        newRow("UserID") = lst.UserId
                        newRow("RoomID") = lst.RoomId
                        newRow("Points") = If(dr("AppointmentId") = "0", dr("Points"), dr("AppointmentPoints"))
                        newRow("SlotType") = If(dr("AppointmentId") = "0", "FreeSlot", "PatientBooking")
                        newRow("Notes") = If(dr("AppointmentId") = "0", "", dr("AppointmentNotes"))
                        newRow("GeneralInfo") = If(dr("AppointmentId") = "0", "", dr("GeneralInformation"))
                        newRow("EndoscopistId") = lst.UserId
                        newRow("SlotSubject") = dr("Subject")
                        newRow("OperatingHospitalId") = OperatingHospitalId
                        newRow("Locked") = CBool(dr("Locked"))
                        newRow("LockedDiary") = CBool(lst.LockedDiary)

                        dtDiaries.Rows.Add(newRow)
                        slotStart = slotEnd




                        If CInt(dr("AppointmentId")) > 0 Then
                            'check if the appointment takes up less than the slot time
                            If CInt(dr("AppointmentDuration")) < CInt(dr("Minutes")) Then

                                'how much of the current slot has been used
                                Dim usedMins = (From s In dtDiaries.AsEnumerable
                                                Where s("AppointmentId") > 0 And
                                                                s("ListSlotId") = dr("ListSlotId")
                                                Select CInt(s("SlotDuration"))).Sum

                                'calculate how many minutes the slot has left
                                Dim remainingDuration = CInt(dr("Minutes")) - usedMins

                                'how much of the current slot point has been used
                                Dim usedPoints = (From s In dtDiaries.AsEnumerable
                                                  Where s("AppointmentId") > 0 And
                                                                s("ListSlotId") = dr("ListSlotId")
                                                  Select CInt(s("Points"))).Sum

                                'calculate how many points the slot has left
                                Dim remainingPoints = CInt(dr("Points")) - usedPoints

                                If remainingDuration > 0 Then
                                    'as long as this space isnt already filled...
                                    If Not lst.ListSlots.Any(Function(x) x("AppointmentId") > 0 AndAlso x("AppointmentStart") = slotStart) Then

                                        slotStart = CDate(dr("AppointmentEnd"))
                                        slotEnd = slotStart.AddMinutes(remainingDuration)

                                        'check if an appointment starts before the end of the slot, if so adjust the end time
                                        Dim appointmentSlot = lst.ListSlots.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And x("AppointmentId") > 0 And Not x.IsNull("AppointmentStart") AndAlso ((CDate(x("AppointmentStart")) > slotStart) And (CDate(x("AppointmentStart")) < slotEnd))).FirstOrDefault
                                        If appointmentSlot IsNot Nothing Then
                                            slotEnd = CDate(appointmentSlot("AppointmentStart"))
                                        End If

                                        If slotStart >= CDate(dr("DiaryEnd")) Then
                                            Exit For 'we should not be creating any slots past the end of the list
                                        ElseIf slotEnd > CDate(dr("DiaryEnd")) Then
                                            slotEnd = CDate(dr("DiaryEnd")) 'we're creating a new slot for the time that the appointment has left over. but dont let it go past the end of the list
                                        End If
                                        slotSubject = slotStart.ToShortTimeString & " - " & dr("Subject")


                                        newRow = dtDiaries.NewRow

                                        newRow("DiaryId") = lst.DiaryId
                                        newRow("AppointmentId") = 0
                                        newRow("Subject") = slotSubject
                                        newRow("SlotColor") = dr("Forecolor")
                                        newRow("DiaryStart") = slotStart
                                        newRow("DiaryEnd") = slotEnd
                                        newRow("SlotDuration") = remainingDuration
                                        newRow("Description") = slotSubject
                                        newRow("ProcedureTypeID") = procTypeId
                                        newRow("StatusId") = dr("StatusId")
                                        newRow("StatusCode") = ""
                                        newRow("ListRulesID") = lst.ListRuleId
                                        newRow("ListSlotId") = dr("ListSlotId")
                                        newRow("UserID") = lst.UserId
                                        newRow("RoomID") = lst.RoomId
                                        newRow("Points") = If(remainingPoints >= 0, remainingPoints, 0)
                                        newRow("SlotType") = "FreeSlot"
                                        newRow("Notes") = ""
                                        newRow("GeneralInfo") = ""
                                        newRow("EndoscopistId") = lst.UserId
                                        newRow("SlotSubject") = slotStart.ToShortTimeString & " - " & dr("Subject")
                                        newRow("OperatingHospitalId") = OperatingHospitalId
                                        newRow("Locked") = CBool(dr("Locked"))
                                        newRow("LockedDiary") = CBool(lst.LockedDiary)
                                        extraDuration = 0

                                        dtDiaries.Rows.Add(newRow)
                                        slotStart = slotEnd 'do not let the list overrun... soon to be a value against the diary to determine if it can or not

                                        If slotEnd >= CDate(lst.DiaryEndDate) Then
                                            Exit For
                                        End If
                                    End If
                                ElseIf remainingDuration < 0 Then 'its used up some of the next slot
                                    extraDuration = Math.Abs(remainingDuration) 'turn the negative into its positive equivelent

                                End If
                            End If

                            'what if the appointment duration was longer than the slot........
                            If CInt(dr("AppointmentDuration")) > CInt(dr("Minutes")) Then
                                'what was the extra duration.. we need to take it away from the next slot.. but what if it spans multiple???
                                extraDuration = CInt(dr("AppointmentDuration")) - CInt(dr("Minutes"))
                            End If
                        Else
                            extraDuration = 0
                        End If


                        If slotEnd >= CDate(lst.DiaryEndDate) Then
                            Exit For
                        End If

                    Next
                Next
            End If

            Return dtDiaries
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function diarySlots(dt As DataTable) As DataTable
        Dim dtDiaries As New DataTable
        dtDiaries.Columns.Add("DiaryId", GetType(String))
        dtDiaries.Columns.Add("AppointmentId", GetType(String))
        dtDiaries.Columns.Add("Subject", GetType(String))
        dtDiaries.Columns.Add("SlotColor", GetType(String))
        dtDiaries.Columns.Add("DiaryStart", GetType(DateTime))
        dtDiaries.Columns.Add("DiaryEnd", GetType(DateTime))
        dtDiaries.Columns.Add("SlotDuration", GetType(Integer))
        dtDiaries.Columns.Add("UserID", GetType(Integer))
        dtDiaries.Columns.Add("RoomID", GetType(Integer))
        dtDiaries.Columns.Add("RoomName", GetType(String))
        dtDiaries.Columns.Add("ListRulesID", GetType(Integer))
        dtDiaries.Columns.Add("ListSlotId", GetType(Integer))
        dtDiaries.Columns.Add("Description", GetType(String))
        dtDiaries.Columns.Add("ProcedureTypeID", GetType(Integer))
        dtDiaries.Columns.Add("ProcedureType", GetType(String))
        dtDiaries.Columns.Add("Points", GetType(Decimal))
        dtDiaries.Columns.Add("StatusId", GetType(String))
        dtDiaries.Columns.Add("StatusCode", GetType(String))
        dtDiaries.Columns.Add("SlotType", GetType(String))
        dtDiaries.Columns.Add("Notes", GetType(String))
        dtDiaries.Columns.Add("GeneralInfo", GetType(String))
        dtDiaries.Columns.Add("ParentId", GetType(Integer))
        dtDiaries.Columns.Add("EndoscopistId", GetType(Integer))
        dtDiaries.Columns.Add("EndoscopistName", GetType(String))
        dtDiaries.Columns.Add("SlotSubject", GetType(String))
        dtDiaries.Columns.Add("OperatingHospitalId", GetType(Integer))
        dtDiaries.Columns.Add("Locked", GetType(Boolean))
        dtDiaries.Columns.Add("LockedDiary", GetType(Boolean))

        Dim diaryLists = getDiaryList(dt, Now)

        For Each lst In diaryLists
            Dim listStart As DateTime = CDate(lst.DiaryStartDate)
            Dim listEnd As DateTime = CDate(lst.DiaryEndDate)
            Dim listName As String = listStart.ToShortTimeString & " - " & lst.ListName

            Dim slotStart As DateTime = CDate(lst.DiaryStartDate)
            Dim slotEnd As DateTime = Nothing
            Dim slotDuration As Integer = 0
            Dim extraDuration As Integer = 0
            Dim iDiaryId = CInt(lst.DiaryId)


            'get individual slots
            For Each dr In lst.ListSlots
                'add new row
                Dim newRow = dtDiaries.NewRow

                Dim procTypeId As Integer = dr("ProcedureTypeId")
                Dim slotSubject = slotStart.ToShortTimeString & " - " & dr("Subject")

                slotDuration = CInt(dr("Minutes")) '- extraDuration

                slotEnd = slotStart.AddMinutes(slotDuration)

                'check if the previous slot overran into another. the extra duration would've been calculated and added when the appointment adding process was complete
                If extraDuration > 0 Then
                    'this would've been from an overflowed appointment's extra duration going until the end of this appointment. Therefore we no longer need it
                    If slotStart = slotEnd Then
                        Continue For
                    End If

                    slotDuration = slotDuration - extraDuration

                    If slotDuration < 0 Then
                        extraDuration = extraDuration - CInt(dr("Minutes"))
                        Continue For
                    ElseIf slotDuration = 0 Then
                        extraDuration = 0
                        Continue For
                    Else
                        'If Only go past the end of the List if there is an appointment, otherwise stop the slot at the end of the list
                        If dr.IsNull("AppointmentId") OrElse CInt(dr("AppointmentId")) = 0 AndAlso slotEnd > CDate(dr("DiaryEnd")) Then
                            slotEnd = CDate(dr("DiaryEnd"))
                        Else
                            slotEnd = slotStart.AddMinutes(slotDuration)
                        End If
                    End If
                Else
                    If slotEnd > CDate(dr("DiaryEnd")) Then
                        slotEnd = CDate(dr("DiaryEnd"))
                    End If
                End If

                'if appointment id is 0, check if theres an appointment in the list that starts at this time. if so skip, eventually we'll get to it and fall out of this loop as the appointment id will no longer be 0
                If dr.IsNull("AppointmentId") OrElse CInt(dr("AppointmentId")) = 0 Then
                    If lst.ListSlots.Any(Function(x) x("AppointmentId") > 0 AndAlso x("AppointmentStart") = slotStart) Then
                        Continue For
                    End If

                    'check if theres an appointment with an end date in between these times. we need to adjust the durations if so
                    Dim ap = dtDiaries.AsEnumerable.Where(Function(x) x("DiaryId") = iDiaryId And x("AppointmentId") > 0 And (x("DiaryEnd") >= slotStart And x("DiaryEnd") < slotEnd)).FirstOrDefault
                    If ap IsNot Nothing Then
                        slotDuration = DateDiff(DateInterval.Minute, ap("DiaryEnd"), slotEnd)

                    End If
                End If

                Dim iAppointmentId = 0
                If Not dr.IsNull("AppointmentId") AndAlso CInt(dr("AppointmentId")) > 0 Then
                    'Check If appointment starts after slot start time - 
                    If slotStart < CDate(dr("AppointmentStart")) Then
                        slotEnd = CDate(dr("AppointmentStart"))
                        slotDuration = DateDiff(DateInterval.Minute, slotStart, slotEnd)

                        newRow("DiaryId") = lst.DiaryId
                        newRow("AppointmentId") = 0
                        newRow("Subject") = slotSubject
                        newRow("SlotColor") = dr("Forecolor")
                        newRow("DiaryStart") = slotStart
                        newRow("DiaryEnd") = slotEnd
                        newRow("SlotDuration") = slotDuration
                        newRow("Description") = slotSubject
                        newRow("ProcedureTypeID") = procTypeId
                        newRow("StatusId") = dr("StatusId")
                        newRow("StatusCode") = ""
                        newRow("ListRulesID") = lst.ListRuleId
                        newRow("ListSlotId") = dr("ListSlotId")
                        newRow("UserID") = lst.UserId
                        newRow("RoomID") = lst.RoomId
                        newRow("Points") = dr("Points")
                        newRow("SlotType") = "FreeSlot"
                        newRow("Notes") = ""
                        newRow("GeneralInfo") = ""
                        newRow("EndoscopistId") = lst.UserId
                        newRow("SlotSubject") = dr("Subject")
                        newRow("OperatingHospitalId") = dr("OperatingHospitalId")
                        newRow("Locked") = CBool(dr("Locked"))
                        newRow("LockedDiary") = CBool(lst.LockedDiary)
                        extraDuration = 0

                        dtDiaries.Rows.Add(newRow)

                        newRow = dtDiaries.NewRow
                    End If
                    'create a New slot - end time Is appointment start time
                    'add to datatable

                    Dim DescriptionPrefix = ""

                    'check if start time is directly after the last slot. If not create a new slot and add
                    'If CDate(dr("AppointmentStart")) > slotStart Then
                    If Not dr.IsNull("AppointmentStatusCode") AndAlso Not String.IsNullOrEmpty(dr("AppointmentStatusCode")) Then
                        If dr("AppointmentId") And dr("AppointmentStatusCode") = "P" Then
                            DescriptionPrefix = "(PB) "
                        Else
                            DescriptionPrefix = "(PC) "
                        End If
                    End If

                    slotStart = CDate(dr("AppointmentStart"))
                    slotEnd = CDate(dr("AppointmentEnd"))
                    slotDuration = DateDiff(DateInterval.Minute, slotStart, slotEnd)
                    slotSubject = slotStart.ToShortTimeString & "-" & slotEnd.ToShortTimeString & " - " & DescriptionPrefix & dr("AppointmentSubject")

                    Dim usedSlot = dtDiaries.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And CDate(x("DiaryStart")) = slotStart).FirstOrDefault
                    If usedSlot IsNot Nothing Then
                        dtDiaries.Rows.Remove(usedSlot)
                    End If

                Else
                    'check if an appointment starts before the end of the slot
                    Dim appointmentSlot = lst.ListSlots.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And x("AppointmentId") > 0 And Not x.IsNull("AppointmentStart") AndAlso ((CDate(x("AppointmentStart")) > slotStart) And (CDate(x("AppointmentStart")) < slotEnd))).FirstOrDefault
                    If appointmentSlot IsNot Nothing Then
                        slotEnd = CDate(appointmentSlot("AppointmentStart"))
                        slotDuration = DateDiff(DateInterval.Minute, slotStart, slotEnd)
                    End If
                End If

                newRow("DiaryId") = lst.DiaryId
                newRow("AppointmentId") = dr("AppointmentId")
                newRow("Subject") = slotSubject
                newRow("SlotColor") = dr("Forecolor")
                newRow("DiaryStart") = slotStart
                newRow("DiaryEnd") = slotEnd
                newRow("SlotDuration") = slotDuration
                newRow("Description") = slotSubject
                newRow("ProcedureTypeID") = procTypeId
                newRow("StatusId") = dr("StatusId")
                newRow("StatusCode") = If(dr.IsNull("AppointmentId"), "", dr("AppointmentStatusCode"))
                newRow("ListRulesID") = lst.ListRuleId
                newRow("ListSlotId") = dr("ListSlotId")
                newRow("UserID") = lst.UserId
                newRow("RoomID") = lst.RoomId
                newRow("Points") = If(dr("AppointmentId") = "0", dr("Points"), dr("AppointmentPoints"))
                newRow("SlotType") = If(dr("AppointmentId") = "0", "FreeSlot", "PatientBooking")
                newRow("Notes") = If(dr("AppointmentId") = "0", "", dr("AppointmentNotes"))
                newRow("GeneralInfo") = If(dr("AppointmentId") = "0", "", dr("GeneralInformation"))
                newRow("EndoscopistId") = lst.UserId
                newRow("SlotSubject") = dr("Subject")
                newRow("OperatingHospitalId") = dr("OperatingHospitalId")
                newRow("Locked") = CBool(dr("Locked"))
                newRow("LockedDiary") = CBool(lst.LockedDiary)

                dtDiaries.Rows.Add(newRow)


                slotStart = slotEnd

                If CInt(dr("AppointmentId")) > 0 Then
                    'check if the appointment ends before the slot does
                    If CInt(dr("AppointmentDuration")) < CInt(dr("Minutes")) Then
                        'how much of the current slot has been used
                        Dim usedMins = (From s In dtDiaries.AsEnumerable
                                        Where s("AppointmentId") > 0 And
                                                                s("ListSlotId") = dr("ListSlotId")
                                        Select CInt(s("SlotDuration"))).Sum

                        'calculate how many minutes the slot has left
                        Dim remainingDuration = CInt(dr("Minutes")) - usedMins

                        If remainingDuration > 0 Then
                            'as long as this space isnt already filled...
                            If Not lst.ListSlots.Any(Function(x) x("AppointmentId") > 0 AndAlso x("AppointmentStart") = slotStart) Then

                                slotStart = CDate(dr("AppointmentEnd"))
                                slotEnd = slotStart.AddMinutes(remainingDuration)

                                'check if an appointment starts before the end of the slot, if so adjust the end time
                                Dim appointmentSlot = lst.ListSlots.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And x("AppointmentId") > 0 And Not x.IsNull("AppointmentStart") AndAlso ((CDate(x("AppointmentStart")) > slotStart) And (CDate(x("AppointmentStart")) < slotEnd))).FirstOrDefault
                                If appointmentSlot IsNot Nothing Then
                                    slotEnd = CDate(appointmentSlot("AppointmentStart"))
                                End If

                                If slotStart >= CDate(dr("DiaryEnd")) Then
                                    Exit For 'we should not be creating any slots past the end of the list
                                ElseIf slotEnd > CDate(dr("DiaryEnd")) Then
                                    slotEnd = CDate(dr("DiaryEnd")) 'we're creating a new slot for the time that the appointment has left over. but dont let it go past the end of the list
                                End If
                                slotSubject = slotStart.ToShortTimeString & " - " & dr("Subject")


                                newRow = dtDiaries.NewRow

                                newRow("DiaryId") = lst.DiaryId
                                newRow("AppointmentId") = 0
                                newRow("Subject") = slotSubject
                                newRow("SlotColor") = dr("Forecolor")
                                newRow("DiaryStart") = slotStart
                                newRow("DiaryEnd") = slotEnd
                                newRow("SlotDuration") = remainingDuration
                                newRow("Description") = slotSubject
                                newRow("ProcedureTypeID") = procTypeId
                                newRow("StatusId") = dr("StatusId")
                                newRow("StatusCode") = ""
                                newRow("ListRulesID") = lst.ListRuleId
                                newRow("ListSlotId") = dr("ListSlotId")
                                newRow("UserID") = lst.UserId
                                newRow("RoomID") = lst.RoomId
                                newRow("Points") = dr("Points")
                                newRow("SlotType") = "FreeSlot"
                                newRow("Notes") = ""
                                newRow("GeneralInfo") = ""
                                newRow("EndoscopistId") = lst.UserId
                                newRow("SlotSubject") = slotStart.ToShortTimeString & " - " & dr("Subject")
                                newRow("OperatingHospitalId") = dr("OperatingHospitalId")
                                newRow("Locked") = CBool(dr("Locked"))
                                newRow("LockedDiary") = CBool(lst.LockedDiary)
                                extraDuration = 0

                                dtDiaries.Rows.Add(newRow)
                                slotStart = slotEnd 'do not let the list overrun... soon to be a value against the diary to determine if it can or not

                                If slotEnd >= CDate(lst.DiaryEndDate) Then
                                    Exit For
                                End If
                            End If
                        ElseIf remainingDuration < 0 Then 'its used up some of the next slot
                            extraDuration = Math.Abs(remainingDuration) 'turn the negative into its positive equivelent

                        End If
                    End If
                    'what if the appointment duration was longer than the slot........
                    If CInt(dr("AppointmentDuration")) > CInt(dr("Minutes")) Then
                        'what was the extra duration.. we need to take it away from the next slot.. but what if it spans multiple???
                        extraDuration = CInt(dr("AppointmentDuration")) - CInt(dr("Minutes"))
                    End If
                Else
                    extraDuration = 0
                End If


                If slotEnd >= CDate(lst.DiaryEndDate) Then
                    Exit For
                End If

            Next
        Next

        'For Each lst In diaryLists
        '    Dim listStart As DateTime = CDate(lst.DiaryStartDate)
        '    Dim listEnd As DateTime = CDate(lst.DiaryEndDate)
        '    Dim listName As String = listStart.ToShortTimeString & " - " & lst.ListName

        '    Dim slotStart As DateTime = CDate(lst.DiaryStartDate)
        '    Dim slotEnd As DateTime = Nothing
        '    Dim slotDuration As Integer = 0
        '    Dim extraDuration As Integer = 0
        '    Dim iDiaryId = CInt(lst.DiaryId)


        '    'get individual slots
        '    For Each dr In lst.ListSlots
        '        'add new row
        '        Dim newRow = dtDiaries.NewRow

        '        Dim procTypeId As Integer = dr("ProcedureTypeId")
        '        Dim slotSubject = slotStart.ToShortTimeString & " - " & dr("Subject")

        '        If Not dr.IsNull("AppointmentDuration") Then
        '            slotDuration = CInt(dr("AppointmentDuration")) '- extraDuration
        '        Else
        '            slotDuration = CInt(dr("Minutes")) '- extraDuration
        '        End If

        '        slotEnd = slotStart.AddMinutes(slotDuration)

        '        'check if the previous slot overran into another. the extra duration would've been calculated and added when the appointment adding process was complete
        '        If extraDuration > 0 Then
        '            'this would've been from an overflowed appointment's extra duration going until the end of this appointment. Therefore we no longer need it
        '            If slotStart = slotEnd Then
        '                Continue For
        '            End If

        '            If slotDuration <> extraDuration Then
        '                slotDuration = slotDuration - extraDuration
        '            End If

        '            If slotDuration < 0 Then
        '                extraDuration = extraDuration - CInt(dr("Minutes"))
        '                Continue For
        '            ElseIf slotDuration = 0 Then
        '                extraDuration = 0
        '                Continue For
        '            Else
        '                slotEnd = slotStart.AddMinutes(slotDuration)
        '            End If
        '        End If

        '        'if appointment id is 0, check if theres an appointment in the list that starts at this time. if so skip, eventually we'll get to it and fall out of this loop as the appointment id will no longer be 0
        '        If dr.IsNull("AppointmentId") OrElse CInt(dr("AppointmentId")) = 0 Then
        '            If lst.ListSlots.Any(Function(x) x("AppointmentId") > 0 AndAlso x("AppointmentStart") = slotStart) Then
        '                Continue For
        '            End If

        '            'check if theres an appointment with an end date in between these times. we need to adjust the durations if so
        '            Dim ap = dtDiaries.AsEnumerable.Where(Function(x) x("DiaryId") = iDiaryId And x("AppointmentId") > 0 And (x("DiaryEnd") > slotStart And x("DiaryEnd") < slotEnd)).FirstOrDefault
        '            If ap IsNot Nothing Then
        '                slotDuration = DateDiff(DateInterval.Minute, ap("DiaryEnd"), slotEnd)

        '            End If
        '        End If

        '        Dim iAppointmentId = 0
        '        If Not dr.IsNull("AppointmentId") AndAlso CInt(dr("AppointmentId")) > 0 Then
        '            'Check If appointment starts after slot start time - 
        '            If slotStart < CDate(dr("AppointmentStart")) Then
        '                slotEnd = CDate(dr("AppointmentStart"))
        '                slotDuration = DateDiff(DateInterval.Minute, slotStart, slotEnd)

        '                newRow("DiaryId") = lst.DiaryId
        '                newRow("AppointmentId") = 0
        '                newRow("Subject") = slotSubject
        '                newRow("SlotColor") = dr("Forecolor")
        '                newRow("DiaryStart") = slotStart
        '                newRow("DiaryEnd") = slotEnd
        '                newRow("SlotDuration") = slotDuration
        '                newRow("Description") = slotSubject
        '                newRow("ProcedureTypeID") = procTypeId
        '                newRow("StatusId") = dr("StatusId")
        '                newRow("StatusCode") = ""
        '                newRow("ListRulesID") = lst.ListRuleId
        '                newRow("ListSlotId") = dr("ListSlotId")
        '                newRow("UserID") = lst.UserId
        '                newRow("RoomID") = lst.RoomId
        '                newRow("Points") = dr("Points")
        '                newRow("SlotType") = "FreeSlot"
        '                newRow("Notes") = ""
        '                newRow("GeneralInfo") = ""
        '                newRow("EndoscopistId") = lst.UserId
        '                newRow("SlotSubject") = dr("Subject")
        '                newRow("OperatingHospitalId") = dr("OperatingHospitalId")
        '                newRow("Locked") = CBool(dr("Locked"))
        '                newRow("LockedDiary") = CBool(lst.LockedDiary)
        '                extraDuration = 0

        '                dtDiaries.Rows.Add(newRow)

        '                newRow = dtDiaries.NewRow
        '            End If
        '            'create a New slot - end time Is appointment start time
        '            'add to datatable

        '            Dim DescriptionPrefix = ""

        '            'check if start time is directly after the last slot. If not create a new slot and add
        '            'If CDate(dr("AppointmentStart")) > slotStart Then
        '            If Not dr.IsNull("AppointmentStatusCode") AndAlso Not String.IsNullOrEmpty(dr("AppointmentStatusCode")) Then
        '                If dr("AppointmentId") And dr("AppointmentStatusCode") = "P" Then
        '                    DescriptionPrefix = "(PB) "
        '                Else
        '                    DescriptionPrefix = "(PC) "
        '                End If
        '            End If

        '            slotStart = CDate(dr("AppointmentStart"))
        '            slotEnd = CDate(dr("AppointmentEnd"))
        '            slotDuration = DateDiff(DateInterval.Minute, slotStart, slotEnd)
        '            slotSubject = slotStart.ToShortTimeString & "-" & slotEnd.ToShortTimeString & " - " & DescriptionPrefix & dr("AppointmentSubject")

        '            Dim usedSlot = dtDiaries.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And CDate(x("DiaryStart")) = slotStart).FirstOrDefault
        '            If usedSlot IsNot Nothing Then
        '                dtDiaries.Rows.Remove(usedSlot)
        '            End If

        '        Else
        '            'check if an appointment starts before the end of the slot
        '            Dim appointmentSlot = lst.ListSlots.AsEnumerable.Where(Function(x) x("DiaryId") = dr("DiaryId") And x("AppointmentId") > 0 And Not x.IsNull("AppointmentStart") AndAlso ((CDate(x("AppointmentStart")) > slotStart) And (CDate(x("AppointmentStart")) < slotEnd))).FirstOrDefault
        '            If appointmentSlot IsNot Nothing Then
        '                slotEnd = CDate(appointmentSlot("AppointmentStart"))
        '            End If
        '        End If

        '        newRow("DiaryId") = lst.DiaryId
        '        newRow("AppointmentId") = dr("AppointmentId")
        '        newRow("Subject") = slotSubject
        '        newRow("SlotColor") = dr("Forecolor")
        '        newRow("DiaryStart") = slotStart
        '        newRow("DiaryEnd") = slotEnd
        '        newRow("SlotDuration") = slotDuration
        '        newRow("Description") = slotSubject
        '        newRow("ProcedureTypeID") = procTypeId
        '        newRow("StatusId") = dr("StatusId")
        '        newRow("StatusCode") = If(dr.IsNull("AppointmentId"), "", dr("AppointmentStatusCode"))
        '        newRow("ListRulesID") = lst.ListRuleId
        '        newRow("ListSlotId") = dr("ListSlotId")
        '        newRow("UserID") = lst.UserId
        '        newRow("RoomID") = lst.RoomId
        '        newRow("Points") = If(dr("AppointmentId") = "0", dr("Points"), dr("AppointmentPoints"))
        '        newRow("SlotType") = If(dr("AppointmentId") = "0", "FreeSlot", "PatientBooking")
        '        newRow("Notes") = If(dr("AppointmentId") = "0", "", dr("AppointmentNotes"))
        '        newRow("GeneralInfo") = If(dr("AppointmentId") = "0", "", dr("GeneralInformation"))
        '        newRow("EndoscopistId") = lst.UserId
        '        newRow("SlotSubject") = dr("Subject")
        '        newRow("OperatingHospitalId") = dr("OperatingHospitalId")
        '        newRow("Locked") = CBool(dr("Locked"))
        '        newRow("LockedDiary") = CBool(lst.LockedDiary)
        '        'extraDuration = 0

        '        dtDiaries.Rows.Add(newRow)


        '        slotStart = slotEnd

        '        If CInt(dr("AppointmentId")) > 0 Then
        '            'check if the appointment ends before the slot does
        '            If CInt(dr("AppointmentDuration")) < CInt(dr("Minutes")) Then
        '                Dim remainingDuration = CInt(dr("Minutes")) - CInt(dr("AppointmentDuration"))

        '                'get the amount of minutes set for this list slot (if this is an additional slot, the list slot id will be the same)
        '                Dim listSlotPoints = lst.ListSlots.Where(Function(x) x("ListSlotId") = dr("ListSlotId")).Select(Function(y) y("Minutes")).FirstOrDefault

        '                'get total amount of minutes allocated so far for this list slot
        '                Dim listSlotPointsTotal = dtDiaries.AsEnumerable.Where(Function(x) x("ListSlotId") = dr("ListSlotId")).Sum(Function(x) x("SlotDuration"))
        '                'remainingDuration = (listSlotPoints - listSlotPointsTotal) - extraDuration

        '                If remainingDuration > 0 Then
        '                    'as long as this space isnt already filled...
        '                    If Not lst.ListSlots.Any(Function(x) x("AppointmentId") > 0 AndAlso x("AppointmentStart") = slotStart) Then

        '                        slotStart = CDate(dr("AppointmentEnd"))
        '                        slotEnd = slotStart.AddMinutes(remainingDuration)
        '                        If slotEnd > CDate(dr("DiaryEnd")) Then
        '                            slotEnd = CDate(dr("DiaryEnd"))
        '                        End If
        '                        slotSubject = slotStart.ToShortTimeString & " - " & dr("Subject")


        '                        newRow = dtDiaries.NewRow

        '                        newRow("DiaryId") = lst.DiaryId
        '                        newRow("AppointmentId") = 0
        '                        newRow("Subject") = slotSubject
        '                        newRow("SlotColor") = dr("Forecolor")
        '                        newRow("DiaryStart") = slotStart
        '                        newRow("DiaryEnd") = slotEnd
        '                        newRow("SlotDuration") = remainingDuration
        '                        newRow("Description") = slotSubject
        '                        newRow("ProcedureTypeID") = procTypeId
        '                        newRow("StatusId") = dr("StatusId")
        '                        newRow("StatusCode") = ""
        '                        newRow("ListRulesID") = lst.ListRuleId
        '                        newRow("ListSlotId") = dr("ListSlotId")
        '                        newRow("UserID") = lst.UserId
        '                        newRow("RoomID") = lst.RoomId
        '                        newRow("Points") = dr("Points")
        '                        newRow("SlotType") = "FreeSlot"
        '                        newRow("Notes") = ""
        '                        newRow("GeneralInfo") = ""
        '                        newRow("EndoscopistId") = lst.UserId
        '                        newRow("SlotSubject") = slotStart.ToShortTimeString & " - " & dr("Subject")
        '                        newRow("OperatingHospitalId") = dr("OperatingHospitalId")
        '                        newRow("Locked") = CBool(dr("Locked"))
        '                        newRow("LockedDiary") = CBool(lst.LockedDiary)
        '                        extraDuration = 0

        '                        dtDiaries.Rows.Add(newRow)
        '                        slotStart = slotEnd

        '                        'do not let the list overrun... soon to be a value against the diary to determine if it can or not
        '                        If slotEnd >= CDate(lst.DiaryEndDate) Then
        '                            Exit For
        '                        End If
        '                    End If
        '                End If
        '            End If
        '            'what if the appointment duration was longer than the slot........
        '            If CInt(dr("AppointmentDuration")) > CInt(dr("Minutes")) Then
        '                'what was the extra duration.. we need to take it away from the next slot.. but what if it spans multiple???
        '                extraDuration = CInt(dr("AppointmentDuration")) - CInt(dr("Minutes"))
        '            End If
        '        Else
        '            extraDuration = 0
        '        End If

        '        'do not let the list overrun... soon to be a value against the diary to determine if it can or not
        '        If slotEnd >= CDate(lst.DiaryEndDate) Then
        '            Exit For
        '        End If

        '    Next
        'Next

        Return dtDiaries

    End Function

    Friend Function GetLockedDiaries(Optional ByVal diaryId As Integer = 0) As DataTable
        Try
            Dim dsData As New DataSet
            Try
                Using connection As New SqlConnection(DataAccess.ConnectionStr)
                    Dim sSQL = "SELECT AM, PM, EVE, DiaryId, DiaryDate FROM ERS_SCH_LockedDiaries 
                                WHERE DiaryId = ISNULL(@DiaryId, DiaryId) AND DiaryDate >= CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 120) + ' 00:00:00') and Locked = 1"
                    Dim cmd As New SqlCommand(sSQL, connection)
                    cmd.CommandType = CommandType.Text

                    If diaryId > 0 Then
                        cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@DiaryId", DBNull.Value))
                    End If

                    Dim adapter = New SqlDataAdapter(cmd)
                    connection.Open()
                    adapter.Fill(dsData)
                End Using

            Catch ex As Exception
                Return Nothing
            End Try
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetPatientAppointments(iDiaryId As Integer)
        Using db As New ERS.Data.GastroDbEntities
            Return (From b In db.ERS_Appointments
                    Join d In db.ERS_SCH_DiaryPages On b.DiaryId Equals d.DiaryId
                    Join s In db.ERS_SCH_SlotStatus On s.StatusId Equals b.SlotStatusID
                    Join bp In db.ERS_AppointmentProcedureTypes On bp.AppointmentID Equals b.AppointmentId
                    Join pt In db.ERS_ProcedureTypes On pt.ProcedureTypeId Equals bp.ProcedureTypeID
                    Let bookingEnd = SqlFunctions.DateAdd("mi", CInt(b.AppointmentDuration), b.StartDateTime)
                    Where (d.DiaryId = iDiaryId)
                    Group pt.SchedulerProcName By b.StartDateTime, bookingEnd, b.AppointmentDuration, d.RoomID, d.ListRulesId, d.UserID, SlotDescription = s.Description, b.AppointmentId Into g = Group
                    Select AppointmentId, StartDateTime, bookingEnd, AppointmentDuration, RoomID, ListRulesId, UserID, SlotDescription, Procedures = g.ToList())
        End Using
    End Function

    Public Function InsertSchAppointments(Subject As String, Start As DateTime, EndApp As DateTime,
                                          RecurrenceRule As String, RecurrenceParentID As Integer,
                                          Description As String, RoomID As Integer) As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("INSERT INTO [ERS_SCH_Appointments] ([Subject], [StartDateTime], [End], [RecurrenceRule], [RecurrenceParentID], [Description], [RoomID]) " &
                                    " VALUES (@Subject, @Start, @End, @RecurrenceRule, @RecurrenceParentID, @Description, @RoomID) ", connection)
            cmd.Parameters.Add(New SqlParameter("@Subject", Subject))
            cmd.Parameters.Add(New SqlParameter("@Start", Start))
            cmd.Parameters.Add(New SqlParameter("@EndApp", EndApp))
            cmd.Parameters.Add(New SqlParameter("@RecurrenceRule", RecurrenceRule))
            cmd.Parameters.Add(New SqlParameter("@RecurrenceParentID", RecurrenceParentID))
            cmd.Parameters.Add(New SqlParameter("@Description", Description))
            cmd.Parameters.Add(New SqlParameter("@RoomID", RoomID))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using
    End Function


    'Public Function LoadConsultantByType(ByVal consultantType As Staff) As List(Of ERS.Data.GetAllConsultant_Result)
    '    Return BusinessLogic.FilterConsultantType(consultantType, True)
    'End Function
#End Region


    Public Function SearchAvailableSlots(searchFields As Products_Scheduler.SearchFields, excludeTraining As Boolean, Optional lTherapeuticTypes As List(Of Integer) = Nothing) As DataTable

        Dim procTypes = String.Join(",", searchFields.ProcedureTypes.Select(Function(x) x.ProcedureTypeID).ToArray())

        Dim slots = String.Join(",", searchFields.Slots.Keys.ToArray())

        Dim SearchStart As DateTime = searchFields.SearchStartDate
        Dim SearchEnd As DateTime = searchFields.BreachDate
        Dim OperatingHospitalIDs As String = String.Join(",", searchFields.OperatingHospitalIds)
        Dim ProcedureTypes As String = procTypes
        Dim Therapeutics As String = If(lTherapeuticTypes IsNot Nothing, String.Join(",", lTherapeuticTypes), "")
        Dim Endoscopist As String = searchFields.Endo


        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_search_available_slots", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = SearchStart})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIDs", .SqlDbType = SqlDbType.Text, .Value = OperatingHospitalIDs})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ExcludeTraining", .SqlDbType = SqlDbType.Bit, .Value = excludeTraining})

                If ProcedureTypes = Nothing Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureTypes", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureTypes", .SqlDbType = SqlDbType.Text, .Value = ProcedureTypes})
                End If
                If ProcedureTypes = Nothing Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TherapeuticTypes", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TherapeuticTypes", .SqlDbType = SqlDbType.Text, .Value = Therapeutics})
                End If
                If slots = Nothing Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Slots", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Slots", .SqlDbType = SqlDbType.Text, .Value = slots})
                End If
                If Not String.IsNullOrWhiteSpace(Endoscopist) Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Endoscopist", .SqlDbType = SqlDbType.Text, .Value = Endoscopist})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Endoscopist", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
                End If


                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            Return Nothing
        End Try
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If



        Return Nothing


    End Function

    Public Function GetAvailableSlots(SearchStart As DateTime, SearchEnd As DateTime, OperatingHospitalIDs As String, Optional ProcedureTypes As String = "", Optional lTherapeuticTypes As String = "", Optional Slots As String = "", Optional Endoscopist As String = "",
                                      Optional SlotLength As Integer = 0, Optional GIProcedures As Boolean? = Nothing, Optional excludeTraining As Boolean = False) As DataTable

        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_slot_availability_search", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = SearchStart})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchEndDate", .SqlDbType = SqlDbType.DateTime, .Value = SearchEnd})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIDs", .SqlDbType = SqlDbType.Text, .Value = OperatingHospitalIDs})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ExcludeTraining", .SqlDbType = SqlDbType.Bit, .Value = excludeTraining})

                If ProcedureTypes = Nothing Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureTypes", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureTypes", .SqlDbType = SqlDbType.Text, .Value = ProcedureTypes})
                End If
                If ProcedureTypes = Nothing Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TherapeuticTypes", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TherapeuticTypes", .SqlDbType = SqlDbType.Text, .Value = lTherapeuticTypes})
                End If
                If Slots = Nothing Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Slots", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Slots", .SqlDbType = SqlDbType.Text, .Value = Slots})
                End If
                If Not String.IsNullOrWhiteSpace(Endoscopist) Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Endoscopist", .SqlDbType = SqlDbType.Text, .Value = Endoscopist})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Endoscopist", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
                End If
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SlotLength", .SqlDbType = SqlDbType.Int, .Value = SlotLength})
                If GIProcedures.HasValue Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GIProcedure", .SqlDbType = SqlDbType.Bit, .Value = GIProcedures})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GIProcedure", .SqlDbType = SqlDbType.Bit, .Value = DBNull.Value})
                End If

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            Return Nothing
        End Try
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function GetBookedSlots(SearchStartDate As Date, SearchEndDate As Date) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_appointment_bookings", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@StartDateTime", .SqlDbType = SqlDbType.DateTime, .Value = SearchStartDate})
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@EndDateTime", .SqlDbType = SqlDbType.DateTime, .Value = SearchEndDate})

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTherapeuticTypes(ByVal procType As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("GetTherapeuticTypes", connection)
                cmd.CommandType = CommandType.StoredProcedure

                Dim procedureType As Integer = Convert.ToInt32(procedureType)
                cmd.Parameters.Add(New SqlParameter("ProcedureId", procType))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If

            Return Nothing

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetTherapeuticTypes: Error getting therapeutic types", ex)
            Return Nothing
        End Try

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllTherapeuticTypes() As DataTable
        Dim sqlStr As String = "SELECT * FROM ERS_TherapeuticTypes WHERE Id NOT IN (1,2) AND SchedulerTherapeutic = 1  "


        sqlStr += "ORDER BY Description"

        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPointMappings(ByVal OperatingHospitalId As Integer, isTraining As Boolean, isNonGI As Boolean) As DataTable
        'Dim sqlStr As String = "SELECT pm.*, ProcedureType FROM dbo.ERS_SCH_PointMappings pm" &
        '" INNER JOIN ERS_ProcedureTypes pt ON pt.ProcedureTypeID = pm.ProcedureTypeID" &
        '" WHERE pm.OperatingHospitalId = " & OperatingHospitalId & " AND Training = " & If(isTraining, 1, 0) & " AND NonGI=" & If(isNonGI, 1, 0)

        'Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)

        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_point_mappings", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalID", .SqlDbType = SqlDbType.Int, .Value = OperatingHospitalId})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Training", .SqlDbType = SqlDbType.Bit, .Value = isTraining})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NonGI", .SqlDbType = SqlDbType.Bit, .Value = isNonGI})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting procedure type name", ex)
            Return Nothing
        End Try

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function SearchPatientForBookings(CaseNoteNo As String, nhsNo As String, surname As String, forename As String) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sqlStr As String = "SELECT DISTINCT ea.AppointmentID, p.Forename1 + ' ' + p.Surname as PatientName, CASE WHEN eapt.AppointmentID IS NOT NULL THEN ProcTypes.procs ELSE '' END AS ProcedureType, "
            'sqlStr += "ea.StartDateTime, ISNULL(ea.DiaryId, 0) As DiaryId, CASE WHEN ea.DiaryId Is Not NULL THEN esdp.RoomID ELSE ISNULL(ea.RoomId, 0) END as RoomId, esr.HospitalId, aps.Description as Status "
            sqlStr += "ea.StartDateTime, ISNULL(ea.DiaryId, 0) As DiaryId, esr.RoomId as RoomId, esr.RoomName as RoomName, esr.HospitalId, "
            sqlStr += "CASE WHEN aps.Description IS NULL THEN 'Booked' ELSE aps.Description END AS Status "
            sqlStr += "FROM dbo.ERS_Patients p "
            sqlStr += "INNER JOIN dbo.ERS_Appointments ea ON p.[PatientId] = ea.PatientId "
            sqlStr += "LEFT JOIN ERS_AppointmentStatus aps on ea.AppointmentStatusId = aps.UniqueId "
            sqlStr += "LEFT JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID "
            sqlStr += "INNER JOIN dbo.ERS_ProcedureTypes ept ON ept.ProcedureTypeId = eapt.ProcedureTypeID "
            sqlStr += "INNER JOIN dbo.ERS_SCH_DiaryPages esdp on ea.DiaryId = esdp.DiaryId "
            sqlStr += "LEFT JOIN dbo.ERS_SCH_Rooms esr ON esr.RoomId = ISNULL(esdp.RoomID, ea.RoomId) "
            sqlStr += "LEFT JOIN (SELECT ea.AppointmentId, SUM(eapt.Points) AS PointCount, (SELECT AppointmentProcedures + char(10) AS [text()] "
            sqlStr += "FROM dbo.SCH_AppointmentProcedures(ea.AppointmentId) WHERE AppointmentId = ea.AppointmentId FOR XML PATH('')) AS procs "
            sqlStr += "FROM dbo.ERS_Appointments ea INNER JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID "
            sqlStr += "GROUP BY ea.AppointmentId) AS ProcTypes ON proctypes.AppointmentID = ea.AppointmentId "
            sqlStr += "WHERE (ea.AppointmentStatusId <> (SELECT UniqueId FROM ERS_AppointmentStatus WHERE HDCKey = 'C') "
            sqlStr += "OR ea.AppointmentStatusId IS NULL) "
            sqlStr += "AND ea.StartDateTime > DATEADD(month, -1, GetDate())"
            sqlStr += " AND"
            If Not String.IsNullOrWhiteSpace(CaseNoteNo) Then sqlStr += " p.patientId in (Select PatientId from ERS_PatientTrusts where HospitalNumber like '%" & Trim(CaseNoteNo) & "%') AND"
            If Not String.IsNullOrWhiteSpace(nhsNo) Then sqlStr += " NHSNo='" & Trim(nhsNo) & "' AND"
            If Not String.IsNullOrWhiteSpace(surname) Then sqlStr += " Surname like '%" & Trim(surname) & "%' AND"
            If Not String.IsNullOrWhiteSpace(forename) Then sqlStr += " Forename1 like '%" & Trim(forename) & "%' AND"

            If sqlStr.ToLower.EndsWith("and") Then sqlStr = sqlStr.Remove(sqlStr.ToLower.LastIndexOf("and"))
            '"WHERE [HospitalNumber] = '" & CaseNoteNo & "'"

            sqlStr += "  Order By ea.StartDateTime desc"

            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    'Public Function GetWaitlistPatients() As DataTable
    '    Dim dsData As New DataSet
    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim sqlStr As String = "SELECT p.[PatientId], p.[DateOfBirth], p.[NHSNo], p.[HospitalNumber], p.Title, p.Gender, p.Forename1, p.Surname, ewl.ReferralDate, ewl.ReferrerID " &
    '       "FROM dbo.ERS_WaitList ewl " &
    '       "INNER JOIN dbo.ERS_VW_Patients p ON ewl.PatientID = p.[PatientId] " &
    '       "WHERE [Status] = 0"

    '        Dim cmd As New SqlCommand(sqlStr, connection)
    '        cmd.CommandType = CommandType.Text

    '        Dim adapter = New SqlDataAdapter(cmd)
    '        connection.Open()
    '        adapter.Fill(dsData)
    '    End Using

    '    If dsData.Tables.Count > 0 Then
    '        Return dsData.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    Public Function GetGenderLists(diaryId As Integer, Optional diaryDate As Date? = Nothing) As List(Of ERS.Data.ERS_SCH_GenderList)
        Using db As New ERS.Data.GastroDbEntities
            Dim dbResult = db.ERS_SCH_GenderList.Where(Function(x) x.DiaryId = diaryId)
            If diaryDate.HasValue Then
                dbResult = dbResult.Where(Function(x) x.ListDate = diaryDate.Value)
            End If

            Return dbResult.ToList()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetWaitlistPatients(operatingHospitalId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_waitlist_patients", connection)
            cmd.CommandType = CommandType.StoredProcedure
            'cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalID"))))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetWaitlistPatientsForWBookFromWaitList(operatingHospitalId As String) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_waitlist_patients_book_from_wailtlist", connection)
            cmd.CommandType = CommandType.StoredProcedure
            'cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalID"))))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOrderList(operatingHospitalId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_OrderList", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    'Mahfuz created on 16 Jul 2021 - Get Order Comms record with filter criteria
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOrderCommsList(operatingHospitalId As String, intOrderStatusID As Integer, intProcedureTypeId As Integer, intPriorityId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_OrderCommsList", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

            If intOrderStatusID > 0 Then
                cmd.Parameters.Add(New SqlParameter("@intOrderStatusId", intOrderStatusID))
            Else
                cmd.Parameters.Add(New SqlParameter("@intOrderStatusId", DBNull.Value))
            End If

            If intProcedureTypeId > 0 Then
                cmd.Parameters.Add(New SqlParameter("@intProcedureTypeId", intProcedureTypeId))
            Else
                cmd.Parameters.Add(New SqlParameter("@intProcedureTypeId", DBNull.Value))
            End If

            If intPriorityId > 0 Then
                cmd.Parameters.Add(New SqlParameter("@intPriorityId", intPriorityId))
            Else
                cmd.Parameters.Add(New SqlParameter("@intPriorityId", DBNull.Value))
            End If


            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetWaitlistDetails(waitListId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_waitlist_details", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
            cmd.Parameters.Add(New SqlParameter("@WaitlistId", waitListId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOrderDetails(orderId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_order_details", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
            cmd.Parameters.Add(New SqlParameter("@orderId", orderId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Sub MoveOrderToWaitlist(orderId As Integer)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ERS_SCH_MoveOrderToWaitlist", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OrderId", orderId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub



    Public Sub saveDayNote(noteDate As DateTime, noteTime As String, noteText As String, roomId As Integer, operatingHospitalId As Integer, userId As Integer)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("ERS_SCH_SaveDayNotes", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@NoteDate", noteDate))
                cmd.Parameters.Add(New SqlParameter("@NoteText", noteText))
                cmd.Parameters.Add(New SqlParameter("@NoteTime", noteTime))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", userId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getDayNotes(noteDate As DateTime, roomId As Integer, operatingHospitalId As Integer, Optional noteTime As String = Nothing) As DataTable
        Try
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("ERS_SCH_GetDayNotes", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@NoteDate", noteDate))
                cmd.Parameters.Add(New SqlParameter("@NoteTime", noteTime))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function checkAmendedBookings(diaryDate As DateTime, roomId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sqlStr As String = "SELECT ea.AppointmentId, ea.StartDateTime, esdp.DiaryStart 
                                    FROM dbo.ERS_Appointments ea 
                                    INNER JOIN dbo.ERS_SCH_DiaryPages esdp ON ea.DiaryId = esdp.DiaryId
                                    INNER JOIN ERS_AppointmentStatus eas ON eas.UniqueId = ea.AppointmentStatusId
                                    WHERE esdp.RoomID = @RoomId 
                                        AND convert(varchar(10),ea.StartDateTime, 103) = @DiaryDate AND eas.HDCKey = 'C'"


            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            cmd.Parameters.Add(New SqlParameter("@DiaryDate", diaryDate.ToShortDateString))

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function getCancelledBookings(diaryId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_get_cancelled_bookings", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
            cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function getCancelledScheduleList(diaryDate As DateTime) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_get_cancelled_diary", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
            cmd.Parameters.Add(New SqlParameter("@DiaryDate", diaryDate))

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function getCancelledBookingDetails(appointmentID As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_cancelled_booking_details", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
                cmd.Parameters.Add(New SqlParameter("@AppointmentId", appointmentID))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function getCancelledScheculeListDetails(diaryId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_cancelled_diary_details", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Public Function LockedListDetails(listSlotId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_locked_list_details", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ListSlotId", listSlotId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function LockedDiaryDetails(diaryId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_locked_diary_details", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Friend Function IsDiaryLocked(diaryId As Integer, diaryDate As Date, tod As String) As Boolean
        Try
            Dim diaryDateString = diaryDate.Date.ToString '& " 00:00:00"
            Using db As New ERS.Data.GastroDbEntities
                Dim lockedDiaries = db.ERS_SCH_LockedDiaries.Where(Function(x) x.DiaryId = diaryId And x.DiaryDate = diaryDateString And x.Locked)

                If lockedDiaries Is Nothing Then Return False

                Select Case tod
                    Case "AM"
                        Return lockedDiaries.Any(Function(x) x.AM = True)
                    Case "PM"
                        Return lockedDiaries.Any(Function(x) x.PM = True)
                    Case "EVE"
                        Return lockedDiaries.Any(Function(x) x.EVE = True)
                End Select
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function saveLockedReason(iDiaryId As String, reasonId As Integer, lockReason As String, diaryDate As DateTime, tod As String) As Boolean
        Try
            Dim diaryDateString = diaryDate.ToShortDateString
            Dim locked = False

            Using db As New ERS.Data.GastroDbEntities
                Dim tbl As New ERS.Data.ERS_SCH_LockedDiaries

                Dim res = db.ERS_SCH_LockedDiaries.Where(Function(x) x.DiaryId = iDiaryId And x.DiaryDate = diaryDateString)
                Select Case tod
                    Case "AM"
                        tbl = res.Where(Function(x) x.AM = True).FirstOrDefault
                    Case "PM"
                        tbl = res.Where(Function(x) x.PM = True).FirstOrDefault
                    Case "EVE"
                        tbl = res.Where(Function(x) x.EVE = True).FirstOrDefault
                End Select

                If tbl IsNot Nothing AndAlso tbl.Locked Then locked = True

                If tbl Is Nothing Then
                    tbl = New ERS.Data.ERS_SCH_LockedDiaries
                    tbl.DiaryId = iDiaryId
                    tbl.DiaryDate = diaryDateString
                    tbl.AM = (tod = "AM")
                    tbl.PM = (tod = "PM")
                    tbl.EVE = (tod = "EVE")
                    tbl.Locked = True '1st entry so if we're here the diary is being LOCKED for the 1st time
                    tbl.LockedDateTime = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                    tbl.LockedReasonId = reasonId
                    tbl.LockAuthorizatonText = lockReason
                    tbl.WhoCreatedId = LoggedInUserId
                    tbl.WhenCreated = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                Else
                    If locked Then
                        tbl.Locked = False 'undo current locked state
                        tbl.UnlockedReasonId = reasonId
                        tbl.UnlockAuthorizatonText = lockReason
                        tbl.UnlockedDateTime = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                    Else
                        tbl.Locked = True 'undo current locked state
                        tbl.LockedReasonId = reasonId 'undo current locked state
                        tbl.UnlockedReasonId = Nothing
                        tbl.LockAuthorizatonText = lockReason
                        tbl.LockedDateTime = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                    End If

                    tbl.WhoUpdatedId = LoggedInUserId
                    tbl.WhenUpdated = DateTime.UtcNow.AddMinutes(-OffsetMinutes)
                End If

                If tbl.LockedDiaryId > 0 Then
                    db.ERS_SCH_LockedDiaries.Attach(tbl)
                    db.Entry(tbl).State = Entity.EntityState.Modified
                Else
                    db.ERS_SCH_LockedDiaries.Add(tbl)
                End If

                db.SaveChanges()

            End Using

            Return (Not locked) 'oposite state to when function was 1st entered
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetPlannedWaitlistPatients() As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_planned_waitlist_patients", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalID"))))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSchedulerHospitals() As DataTable
        Dim sSQL = "SELECT * FROM [ERS_OperatingHospitals] WHERE OperatingHospitalId IN (SELECT HospitalId FROM ERS_SCH_Rooms) and TrustId = @TrustId ORDER BY HospitalName ASC"

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            'MH fixed TrustID tinyint issue on 26 Nov 2021
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = CInt(HttpContext.Current.Session("TrustId"))})
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllSchedulerHospitals() As DataTable
        Dim sSQL = "SELECT * FROM [ERS_OperatingHospitals] WHERE OperatingHospitalId IN (SELECT HospitalId FROM ERS_SCH_Rooms) ORDER BY HospitalName ASC"

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSchedulerTrusts() As DataTable
        Dim sSQL = "SELECT TrustId, TrustName FROM ERS_Trusts ORDER BY TrustName"

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSchedulerHospitals(TrustId As Integer) As DataTable
        Dim sSQL = "SELECT * FROM [ERS_OperatingHospitals] WHERE OperatingHospitalId IN (SELECT HospitalId FROM ERS_SCH_Rooms r INNER JOIN dbo.ERS_SCH_RoomProcedures rp ON rp.RoomId = r.RoomId) and TrustId = @TrustId ORDER BY HospitalName ASC"

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = TrustId})
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function getDiaryPages(Optional endoscopistId As Integer? = Nothing) As DataTable
        Try
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_page_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
                If endoscopistId.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistId))

                End If
                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetProcedureCallInTimes(operatingHospitaId As Integer) As DataTable
        Try
            Dim dsResult As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_callintimes", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitaId))
                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function




    Public Sub EditNonGIConsultant(title As String, forename As String, surname As String, GMCCode As String, jobTitleId As Integer, userId As Integer)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sp_update_nongi_consultant", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@Title", title))
                cmd.Parameters.Add(New SqlParameter("@Forename", forename))
                cmd.Parameters.Add(New SqlParameter("@Surname", surname))
                cmd.Parameters.Add(New SqlParameter("@GMCCode", GMCCode))
                cmd.Parameters.Add(New SqlParameter("@JobTitleId", jobTitleId))
                cmd.Parameters.Add(New SqlParameter("@UserId", userId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub



    Public Function AddNonGIConsultant(title As String, forename As String, surname As String, GMCCode As String, jobTitleId As Integer) As Integer
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sp_add_nongi_consultant", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@Title", title))
                cmd.Parameters.Add(New SqlParameter("@Forename", forename))
                cmd.Parameters.Add(New SqlParameter("@Surname", surname))
                cmd.Parameters.Add(New SqlParameter("@GMCCode", GMCCode))
                cmd.Parameters.Add(New SqlParameter("@JobTitleId", jobTitleId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))


                cmd.Connection.Open()
                Return cmd.ExecuteScalar()

            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getDiaryConsultant(DiaryId As Integer, diaryDate As DateTime) As String
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_consultant", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", DiaryId))
                cmd.Parameters.Add(New SqlParameter("@DiaryDate", diaryDate))

                cmd.Connection.Open()
                Return cmd.ExecuteScalar()

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting diaries list consultant", ex)
            Return ""
        End Try
    End Function

    Public Function getDiaryEndoscopist(DiaryId As Integer, diaryDate As DateTime) As String
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_endoscopist", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", DiaryId))
                cmd.Parameters.Add(New SqlParameter("@DiaryDate", diaryDate))

                cmd.Connection.Open()
                Return cmd.ExecuteScalar()

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting diaries list endoscopist", ex)
            Return ""
        End Try
    End Function

    Public Function getDiaryProcedureList(DiaryId As Integer, diaryDate As DateTime) As String
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_procedure_list", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", DiaryId))
                cmd.Parameters.Add(New SqlParameter("@DiaryDate", diaryDate))

                cmd.Connection.Open()
                Return cmd.ExecuteScalar()

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("getDiaryProcedureList: " + ex.ToString(), ex)
            Return ""
        End Try
    End Function

    Friend Function isTrainingDiary(AMDiaryId As Integer) As Boolean
        Try
            Dim sSQL = "SELECT TOP 1 esdp.Training
                        FROM dbo.ERS_SCH_DiaryPages esdp
	                        INNER JOIN dbo.ERS_SCH_ListRules eslr on esdp.ListRulesId = eslr.ListRulesId
                        WHERE DiaryId = @DiaryId"

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sSQL, connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@DiaryId", AMDiaryId))

                cmd.Connection.Open()
                Return CBool(cmd.ExecuteScalar())

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting diaries training status", ex)
            Return False
        End Try
    End Function

    Friend Function isGIDiary(AMDiaryId As Integer) As Boolean
        Try
            Dim sSQL = "SELECT TOP 1 eslr.GIProcedure
                        FROM dbo.ERS_SCH_DiaryPages esdp
	                        INNER JOIN dbo.ERS_SCH_ListRules eslr on esdp.ListRulesId = eslr.ListRulesId
                        WHERE DiaryId = @DiaryId"

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sSQL, connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@DiaryId", AMDiaryId))

                cmd.Connection.Open()
                Return CBool(cmd.ExecuteScalar())

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting diaries training status", ex)
            Return False
        End Try
    End Function

    Public Function ProceduresValidForEndoscopist(endoscopistId As Integer, procedureTypeIds As List(Of Integer)) As Boolean
        Dim returnVal As Boolean = True
        Dim dt As DataTable = GetEndoscopistProcedures(endoscopistId)
        Dim keyColumns(1) As DataColumn
        keyColumns(0) = New DataColumn()
        keyColumns(0) = dt.Columns("ProcedureTypeId")
        dt.PrimaryKey = keyColumns
        If dt.Rows.Count > 0 Then
            For Each p In procedureTypeIds
                Dim foundRow As DataRow = dt.Rows.Find(p)
                If IsNothing(foundRow) Then
                    Return False
                End If
            Next
        End If
        Return returnVal
    End Function

    Public Function RecurrenceDescription(rule As String) As String
        If String.IsNullOrWhiteSpace(rule) Then Return ""
        Dim rRule As RecurrenceRule
        Dim ruleText = ""

        If RecurrenceRule.TryParse(rule, rRule) Then
            ruleText = "Occurs " & rRule.Pattern.Frequency.ToString
            If rRule.Pattern.Frequency = RecurrenceFrequency.Daily Then
                If rRule.Pattern.DaysOfWeekMask = RecurrenceDay.EveryDay Then
                    ruleText += If(rRule.Pattern.Interval = 1, "", " every " & rRule.Pattern.Interval & " days")
                ElseIf rRule.Pattern.DaysOfWeekMask = RecurrenceDay.WeekDays Then
                    ruleText += " every weekday"
                End If
            End If
        ElseIf rRule.Pattern.Frequency = RecurrenceFrequency.Weekly Then
            ruleText += ": " & rRule.Pattern.DaysOfWeekMask.ToString()
        End If

        If Not rRule.Range.RecursUntil = DateTime.MaxValue Then
            ruleText += " until " & rRule.Range.RecursUntil.ToShortDateString
        ElseIf rRule.Range.MaxOccurrences < 2147483647 Then
            ruleText += " until "
            Dim ones = rRule.Range.MaxOccurrences Mod 10
            Dim tens = (rRule.Range.MaxOccurrences / 10) Mod 10

            If tens = 1 Then
                ruleText += rRule.Range.MaxOccurrences & "th occurence"
            Else
                Select Case ones
                    Case 1
                        ruleText += rRule.Range.MaxOccurrences & "st occurence"
                    Case 2
                        ruleText += rRule.Range.MaxOccurrences & "nd occurence"
                    Case 3
                        ruleText += rRule.Range.MaxOccurrences & "rd occurence"
                    Case Else
                        ruleText += rRule.Range.MaxOccurrences & "th occurence"
                End Select
            End If
        End If

        Return ruleText
    End Function

    Public Shared Sub ReleaseRedundantLockedSlots(Optional endoscopistId As Integer = 0)
        Try
            Try
                Using connection As New SqlConnection(DataAccess.ConnectionStr)
                    Dim cmd As New SqlCommand("sch_release_redundant_reserved_slots", connection)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Add(New SqlParameter("@MaxReservedMins", 15))
                    cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistId))

                    cmd.Connection.Open()
                    cmd.ExecuteNonQuery()
                End Using
            Catch ex As Exception
                Throw ex
            End Try
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error releasing redundant slots", ex)
            Throw ex
        End Try
    End Sub

    Public Function GetListName(diaryId As Integer) As String
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return (From dp In db.ERS_SCH_DiaryPages Where dp.DiaryId = diaryId Select dp.Subject).FirstOrDefault
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetListName", ex)
            Throw New Exception("GetListName: " & ex.ToString())
        End Try
    End Function

    Public Function GetListSlotPoints(diaryId As Integer) As Decimal
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return (
                    From dp In db.ERS_SCH_DiaryPages
                    Join ls In db.ERS_SCH_ListSlots On dp.ListRulesId Equals ls.ListRulesId
                    Where dp.DiaryId = diaryId Select ls.Points).FirstOrDefault
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetListSlotPoints", ex)
            Throw New Exception("GetListSlotPoints: " & ex.ToString())
        End Try
    End Function

    Public Function GetTotalListPoints(diaryId As Integer) As Decimal
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return (
                    From dp In db.ERS_SCH_DiaryPages
                    Join lr In db.ERS_SCH_ListRules On dp.ListRulesId Equals lr.ListRulesId
                    Where dp.DiaryId = diaryId Select lr.Points).FirstOrDefault
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetTotalListPoints", ex)
            Throw New Exception("GetTotalListPoints: " & ex.ToString())
        End Try
    End Function

    Public Function GetDiaryUsedPoints(diaryId As Integer, diaryDate As DateTime) As Decimal
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return If((
                    From ap In db.ERS_Appointments
                    Join apt In db.ERS_AppointmentProcedureTypes On ap.AppointmentId Equals apt.AppointmentID
                    Let AppointmentDate = EntityFunctions.TruncateTime(ap.StartDateTime)
                    Where ap.DiaryId = diaryId And AppointmentDate = diaryDate
                    Select apt.Points).Sum, 0)
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting diary used points", ex)
            Throw New Exception("Error getting diary used points")
        End Try
    End Function

    Public Function SuppressCancellationReason(CancelReasonID As Integer, Suppressed As Boolean) As Boolean
        Dim sql As String = "UPDATE [ERS_CancelReasons] SET [Suppressed] = " & IIf(Suppressed, 1, 0) & " WHERE CancelReasonID = " & CancelReasonID
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    Public Function SuppressScheduleListCancelReason(CancelReasonID As Integer, Suppressed As Boolean) As Boolean
        Dim sql As String = "UPDATE ERS_ListCancelReasons SET [Suppressed] = " & IIf(Suppressed, 1, 0) & " WHERE ListCancelReasonId = " & CancelReasonID
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    Public Function SuppressLockReason(DiaryLockReasonId As Integer, Suppressed As Boolean) As Boolean
        Dim sql As String = "UPDATE [ERS_SCH_DiaryLockReasons] SET [Suppressed] = " & IIf(Suppressed, 1, 0) & " WHERE DiaryLockReasonId = " & DiaryLockReasonId
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    Public Function SuppressListLockReason(ListLockReasonId As Integer, Suppressed As Boolean) As Boolean
        Dim sql As String = "UPDATE [ERS_SCH_ListLockReasons] SET [Suppressed] = " & IIf(Suppressed, 1, 0) & " WHERE ListLockReasonId = " & ListLockReasonId
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    Friend Function getExistingAppointments(diaryId As Integer, bookingDateTime As Date, bookingEndDateTime As Date) As DataTable
        Try
            Dim ds As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_overlapping_bookings", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))
                cmd.Parameters.Add(New SqlParameter("@AppointmentStart", bookingDateTime))
                cmd.Parameters.Add(New SqlParameter("@AppointmentEnd", bookingEndDateTime))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)

                If ds.Tables.Count > 0 Then
                    Return ds.Tables(0)
                End If

            End Using
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting room diaries", ex)
            Return Nothing
        End Try
    End Function

#Region "Scheduler v2"

    Friend Sub addNewList(listRulesId As Integer, operatingHospitalId As Integer, startDateTime As DateTime, roomId As Integer)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_page_add", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ListRulesId", listRulesId))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@ListStart", startDateTime))
                cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Friend Sub editListSlot(listSlotId As Integer, slotStatusId As Integer, ProcedureTypeId As Integer, points As Decimal, slotLength As Integer)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_list_slot_update", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ListSlotId", listSlotId))
                cmd.Parameters.Add(New SqlParameter("@SlotStatusId", slotStatusId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", ProcedureTypeId))
                cmd.Parameters.Add(New SqlParameter("@Points", points))
                cmd.Parameters.Add(New SqlParameter("@SlotLength", slotLength))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Friend Function getDiaryLists(diaryDate As DateTime, Optional roomId As Integer = 0) As DataTable
        Try
            Dim ds As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_page_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryDate", diaryDate))
                cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)

                If ds.Tables.Count > 0 Then
                    Return ds.Tables(0)
                End If

            End Using
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting room diary lists", ex)
            Return Nothing
        End Try
    End Function

    Friend Function GetGenderGenders() As DataTable
        Try
            Dim ds As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_genders", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)

                If ds.Tables.Count > 0 Then
                    Return ds.Tables(0)
                End If

            End Using
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting room diary lists", ex)
            Return Nothing
        End Try
    End Function

    Public Function GetRecurringLists(diaryId As Integer, diaryDate As DateTime) As DataTable
        Try
            Dim ds As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_recurring_lists", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("DiaryId", diaryId))
                cmd.Parameters.Add(New SqlParameter("DiaryDate", diaryDate))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)

                If ds.Tables.Count > 0 Then
                    Return ds.Tables(0)
                End If

            End Using
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting room diary lists", ex)
            Return Nothing
        End Try
    End Function

    Public Function GetListDiaryDetails(diaryId As Integer) As DataTable
        Try
            Dim ds As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_diary_details", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("DiaryId", diaryId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)

                If ds.Tables.Count > 0 Then
                    Return ds.Tables(0)
                End If

            End Using
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting room diary lists", ex)
            Return Nothing
        End Try
    End Function

    Public Sub saveDiaryNotes(diaryId As Integer, listNotes As String)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_save_diary_notes", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))
                cmd.Parameters.Add(New SqlParameter("@DiaryNotes", listNotes))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error saving diary notes", ex)
            Throw ex
        End Try
    End Sub

    Public Sub lockListSlot(listSlotId As Integer, lock As Boolean, reasonId As Integer, reasonText As String, slotStart As DateTime, slotEnd As DateTime)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_lock_list_slot", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ListSlotId", listSlotId))
                cmd.Parameters.Add(New SqlParameter("@Lock", lock))
                cmd.Parameters.Add(New SqlParameter("@ReasonId", reasonId))
                cmd.Parameters.Add(New SqlParameter("@ReasonText", reasonText))
                cmd.Parameters.Add(New SqlParameter("@SlotStart", slotStart))
                cmd.Parameters.Add(New SqlParameter("@SlotEnd", slotEnd))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error locking list slot", ex)
            Throw ex
        End Try
    End Sub

    Public Sub lockDiaryList(diaryId As Integer, lock As Boolean, reasonId As Integer, reasonText As String)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_set_diary_locked", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))
                cmd.Parameters.Add(New SqlParameter("@Lock", lock))
                cmd.Parameters.Add(New SqlParameter("@ReasonId", reasonId))
                cmd.Parameters.Add(New SqlParameter("@ReasonText", reasonText))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error locking list", ex)
            Throw ex
        End Try
    End Sub


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetListLockReasons(Optional showSuppressed As Boolean = False) As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_list_lock_reasons_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@Showsuppressed", showSuppressed))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function

    Public Function saveDiaryList(subject As String, diaryStart As DateTime, diaryEnd As DateTime, roomId As Integer, endoscopistId As Integer, recurrenceFrequency As String, recurrenceCount As Integer, recurrenceDay As String, recurrencePeriod As Integer, recurrenceParentId As Integer, listRulesId As Integer, description As String, operatingHospitalId As Integer,
                             listConsultantId As Integer, training As Boolean, listGenderId As Integer, isGi As Boolean, Optional diaryIds As List(Of Integer) = Nothing) As Integer
        Try
            Dim idObj As Object
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_page_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryIds", If(diaryIds IsNot Nothing, String.Join(",", diaryIds), "")))
                cmd.Parameters.Add(New SqlParameter("@Subject", subject))
                cmd.Parameters.Add(New SqlParameter("@DiaryStart", diaryStart))
                cmd.Parameters.Add(New SqlParameter("@DiaryEnd", diaryEnd))
                cmd.Parameters.Add(New SqlParameter("@RoomID", roomId))
                cmd.Parameters.Add(New SqlParameter("@UserID", endoscopistId))
                cmd.Parameters.Add(New SqlParameter("@RecurrenceFrequency", recurrenceFrequency))
                cmd.Parameters.Add(New SqlParameter("@RecurrenceCount", recurrenceCount))
                cmd.Parameters.Add(New SqlParameter("@RecurrenceDay", recurrenceDay))
                cmd.Parameters.Add(New SqlParameter("@RecurrencePeriod", recurrencePeriod))
                cmd.Parameters.Add(New SqlParameter("@RecurrenceParentID", recurrenceParentId))
                cmd.Parameters.Add(New SqlParameter("@ListRulesId", listRulesId))
                cmd.Parameters.Add(New SqlParameter("@Description", description))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@ListConsultant", listConsultantId))
                cmd.Parameters.Add(New SqlParameter("@Training", training))
                cmd.Parameters.Add(New SqlParameter("@ListGenderId", listGenderId))
                cmd.Parameters.Add(New SqlParameter("@IsGI", isGi))

                cmd.Connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CInt(idObj)
                Else
                    Return 0
                End If
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error adding list", ex)
            Throw ex
        End Try
    End Function

    Public Sub Diary_Delete_Undo(DiaryID As Integer, Suppressed As Boolean, cancelId As Integer, otherText As String, cancelledBy As Integer, Optional deleteOccurrences As Boolean = False)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_diary_page_delete", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", DiaryID))
                '  cmd.Parameters.Add(New SqlParameter("@DeleteOccurrences", deleteOccurrences))
                cmd.Parameters.Add(New SqlParameter("@CancelReasonId", cancelId))
                cmd.Parameters.Add(New SqlParameter("@Suppressed", Suppressed))
                cmd.Parameters.Add(New SqlParameter("@CancelledBy", cancelledBy))

                cmd.Parameters.Add(New SqlParameter("@CancelComment", otherText))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error deleting list", ex)
            Throw ex
        End Try
    End Sub




    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedurePointMappings(ByVal ProcedureTypeId As Integer, ByVal OperatingHospitalId As Integer, isTraining As Boolean, isNonGI As Boolean) As DataTable
        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_procedure_point_mappings", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureTypeId", .SqlDbType = SqlDbType.Int, .Value = ProcedureTypeId})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalID", .SqlDbType = SqlDbType.Int, .Value = OperatingHospitalId})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Training", .SqlDbType = SqlDbType.Bit, .Value = isTraining})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NonGI", .SqlDbType = SqlDbType.Bit, .Value = isNonGI})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting procedure type name", ex)
            Return Nothing
        End Try

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Public Sub addListSlot(listRulesID As Integer, slotId As Integer, procedureTypeId As Integer, operatingHospitalId As Integer, slotMinutes As Decimal, points As Decimal)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_add_list_slot", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ListRulesId", listRulesID))
                cmd.Parameters.Add(New SqlParameter("@SlotId", slotId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@SlotMinutes", slotMinutes))
                cmd.Parameters.Add(New SqlParameter("@Points", points))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub addOverBookedSlot(appointmentId As Integer, diaryId As Integer, points As Decimal)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_add_overbook_slot", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@DiaryId", diaryId))
                cmd.Parameters.Add(New SqlParameter("@AppointmentID", appointmentId))
                cmd.Parameters.Add(New SqlParameter("@Points", points))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetLetterTemplate(ByVal appointmentStatusId As Integer, ByVal OperatingHospitalId As Integer) As DataTable
        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_letter_select", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AppointmentStatusId", .SqlDbType = SqlDbType.Int, .Value = appointmentStatusId})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalID", .SqlDbType = SqlDbType.Int, .Value = OperatingHospitalId})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting letter template", ex)
            Return Nothing
        End Try

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function GetAppointmentLetterTemplate(ByVal appointmentStatusId As Integer, ByVal OperatingHospitalId As Integer) As DataTable
        Dim dsData As New DataSet
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_letter_select", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AppointmentStatusId", .SqlDbType = SqlDbType.Int, .Value = appointmentStatusId})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalID", .SqlDbType = SqlDbType.Int, .Value = OperatingHospitalId})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting letter template", ex)
            Return Nothing
        End Try

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function



    Public Function getListSlots(operatingHospitalId As Integer, listRulesId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_list_slots", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@OperatingHostpitalId", operatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@ListRulesId", listRulesId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
#End Region

#Region "Scheduler Transformation"

#End Region
End Class
