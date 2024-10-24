Imports Telerik.Web.UI
Imports System.IO
Imports System.Data.SqlClient
Imports System.Drawing
Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Web.Script.Serialization

Partial Class Products_Scheduler
    Inherits PageBase

#Region "Structures"
    Structure SearchProcedure
        Property ProcedureTypeID As Integer
        Property Points As Decimal
        Property Minutes As Integer
        Property ProcedureType As String
        Property Diagnostic As Boolean
        Property Therapeutic As Boolean
        Property TherapeuticTypes As List(Of Integer)
    End Structure

    Structure SearchDays
        Property Day As DayOfWeek
        Property Morning As Boolean
        Property Afternoon As Boolean
        Property Evening As Boolean
    End Structure

    Structure SearchFields
        Property OperatingHospitalIds As List(Of Integer)
        Property Endo As String
        Property Gender As String
        Property ReferalDate As DateTime?
        Property BreachDate As DateTime
        Property SearchStartDate As DateTime
        Property Slots As Dictionary(Of Integer, String) 'y
        Property SearchDays As List(Of SearchDays) 'filter on return
        Property GIProcedure As Boolean
        Property ExcludeTraining As Boolean
        Property ReservedSlotsOnly As Boolean
        Property ProcedureTypes As List(Of SearchProcedure) 'y
        Property SlotLength As Decimal
        Property NonGIProcedureType As Integer?
        Property NonGIDiagnostic As Boolean
        Property NonGITherapeutic As Boolean
    End Structure
#End Region
    Protected Sub Page_Init(sender As Object, e As System.EventArgs) Handles Me.Init

    End Sub

    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Me.Master IsNot Nothing Then
                Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                If leftPane IsNot Nothing Then leftPane.Visible = False
                If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
            End If
        End If
    End Sub

#Region "Web Methods"
    <System.Web.Services.WebMethod>
    Shared Function GetNonGIDiaryProcedureLengths(diaryId As Integer, procedureTypeId As Integer, diagnostic As Boolean, therapeutic As Boolean, operatingHospitalId As Integer) As String
        Try
            Using db As New ERS.Data.GastroDbEntities

                Dim diaryDetails = (From d In db.ERS_SCH_DiaryPages
                                    Join r In db.ERS_SCH_ListRules On d.ListRulesId Equals r.ListRulesId
                                    From p In db.ERS_SCH_PointMappings.Where(Function(x) x.ProceduretypeId = procedureTypeId And x.NonGI = True And x.Training = False And x.OperatingHospitalId = d.OperatingHospitalId).DefaultIfEmpty
                                    Where d.DiaryId = diaryId And p.NonGI = True And p.Training = False
                                    Select p.Minutes, r.NonGIDiagnosticProcedurePoints, r.NonGITherapeuticProcedurePoints, r.NonGIDiagnosticCallInTime, r.NonGITherapeuticCallInTime).FirstOrDefault

                Dim procedurePoints = 0
                Dim procedureMinutes = 0
                Dim callInTime = 0

                If diagnostic Then
                    procedurePoints = diaryDetails.NonGIDiagnosticProcedurePoints
                    procedureMinutes = diaryDetails.Minutes
                    callInTime = diaryDetails.NonGIDiagnosticCallInTime
                ElseIf therapeutic Then
                    procedurePoints = diaryDetails.NonGIDiagnosticProcedurePoints
                    procedureMinutes = diaryDetails.Minutes
                    callInTime = diaryDetails.NonGIDiagnosticCallInTime
                Else
                    Dim defaultProcedureSettings = (From p In db.ERS_SCH_PointMappings
                                                    Where p.ProceduretypeId = 0 And p.NonGI = True And p.Training = 0 And p.OperatingHospitalId = operatingHospitalId
                                                    Select p.Points, p.Minutes).FirstOrDefault

                    procedurePoints = defaultProcedureSettings.Points
                    procedureMinutes = defaultProcedureSettings.Minutes
                    callInTime = 15
                End If

                Dim obj = New With {
                    .length = procedurePoints,
                    .points = procedureMinutes,
                    .callInTime = callInTime
                }

                Return New JavaScriptSerializer().Serialize(obj)
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in web method GetProcedureLengths", ex)
            Throw ex
        End Try
    End Function

    <System.Web.Services.WebMethod>
    Shared Function GetProcedureLengths(procedureTypeId As Integer, checked As Boolean, operatingHospitalId As Integer, nonGI As Boolean, isTraining As Boolean, isDiagnostic As Boolean) As String
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim mappings = (From pm In db.ERS_SCH_PointMappings
                                Where pm.ProceduretypeId = procedureTypeId And
                                      pm.OperatingHospitalId = operatingHospitalId And
                                      pm.Training = isTraining And
                                      pm.NonGI = nonGI
                                Select pm.Minutes, pm.Points, pm.TherapeuticMinutes, pm.TherapeuticPoints).FirstOrDefault()

                Dim obj As New Object

                If mappings Is Nothing Then
                    obj = New With {
                    .procedureTypeId = procedureTypeId,
                    .length = 15,
                    .checked = checked,
                    .points = 1
                }
                Else
                    obj = New With {
                    .procedureTypeId = procedureTypeId,
                    .length = If(isDiagnostic, mappings.Minutes, mappings.TherapeuticMinutes),
                    .checked = checked,
                    .points = If(isDiagnostic, mappings.Points, mappings.TherapeuticPoints)
                }
                End If


                Return New JavaScriptSerializer().Serialize(obj)
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in web method GetProcedureLengths", ex)
            Throw ex
        End Try
    End Function

    '<System.Web.Services.WebMethod>
    'Shared Function GetProcedureLengths(procedureTypeId As Integer, checked As Boolean, operatingHospitalId As Integer, nonGI As Boolean) As String
    '    Try
    '        Using db As New ERS.Data.GastroDbEntities
    '            Dim mappings = (From pm In db.ERS_SCH_PointMappings
    '                            Where pm.ProceduretypeId = procedureTypeId And
    '                                  pm.OperatingHospitalId = operatingHospitalId And
    '                                  pm.Training = False And
    '                                  pm.NonGI = nonGI
    '                            Select pm.Minutes, pm.Points).FirstOrDefault()

    '            Dim obj = New With {
    '                .length = mappings.Minutes,
    '                .checked = checked,
    '                .points = mappings.Points
    '            }

    '            Return New JavaScriptSerializer().Serialize(obj)
    '        End Using
    '    Catch ex As Exception
    '        LogManager.LogManagerInstance.LogError("Error in web method GetProcedureLengths", ex)
    '        Throw ex
    '    End Try
    'End Function

    <System.Web.Services.WebMethod>
    Shared Function GetProcedureLengthsDiagAndThera(procedureTypeId As Integer, checked As Boolean, operatingHospitalId As Integer, nonGI As Boolean, therapeuticChecked As Boolean) As String
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim mappings = (From pm In db.ERS_SCH_PointMappings
                                Where pm.ProceduretypeId = procedureTypeId And
                                      pm.OperatingHospitalId = operatingHospitalId And
                                      pm.Training = False And
                                      pm.NonGI = nonGI
                                Select pm.Minutes, pm.Points, pm.TherapeuticMinutes, pm.TherapeuticPoints).FirstOrDefault()

                Dim currMappingMinutes = mappings.Minutes
                Dim currMappingPoints = mappings.Points
                Dim prevMappingMinutes = mappings.TherapeuticMinutes
                Dim prevMappingPoints = mappings.TherapeuticPoints

                If therapeuticChecked Then
                    currMappingMinutes = mappings.TherapeuticMinutes
                    currMappingPoints = mappings.TherapeuticPoints
                    prevMappingMinutes = mappings.Minutes
                    prevMappingPoints = mappings.Points
                End If

                Dim callInTime As Integer = (From cit In db.ERS_SCH_ProcedureCallInTimes Where cit.ProcedureTypeId = procedureTypeId And cit.OperatingHospitalId = operatingHospitalId Select cit.CallInMinutes).FirstOrDefault

                Dim obj = New With {
                    .requestedProcedureTypeId = procedureTypeId,
                    .lengthCurr = currMappingMinutes,
                    checked,
                    .points = currMappingPoints,
                    .lengthPrev = prevMappingMinutes,
                    .pointsPrev = prevMappingPoints,
                    .diagMins = mappings.Minutes,
                    .theraMins = mappings.TherapeuticMinutes,
                    callInTime
                }

                Return New JavaScriptSerializer().Serialize(obj)
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in web method GetProcedureLengths", ex)
            Throw ex
        End Try
    End Function

    <System.Web.Services.WebMethod>
    Shared Function GetDefaultPointMapping(isGI As Boolean, isTraining As Boolean, operatingHospitalId As Integer) As String
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim mappings = (From pm In db.ERS_SCH_PointMappings
                                Where pm.Training = isTraining And pm.NonGI = (Not isGI) And pm.OperatingHospitalId = operatingHospitalId
                                Select pm.Minutes, pm.Points).FirstOrDefault()


                Dim obj = New With {
                    .length = mappings.Minutes,
                    .points = mappings.Points
                }

                Return New JavaScriptSerializer().Serialize(obj)
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in web method GetDefaultPointMapping", ex)
            Throw ex
        End Try
    End Function

    <System.Web.Services.WebMethod>
    Shared Function GetSlotBreechDays(slotIds As List(Of Integer)) As Integer
        Try
            Dim da As New DataAccess_Sch
            Return da.GetSlotBreechDays(slotIds)

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in web method GetSlotBreechDays", ex)
            Throw ex
        End Try
    End Function



    <System.Web.Services.WebMethod>
    Shared Function CalculateBookingCallInTime(procedureTypeIds As List(Of Integer), operatingHospitalId As Integer) As Integer
        Try
            Dim da As New DataAccess_Sch
            Return da.CalculateBookingCallInTime(procedureTypeIds, operatingHospitalId)

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in web method GetSlotBreechDays", ex)
            Throw ex
        End Try
    End Function

    <System.Web.Services.WebMethod>
    Shared Function ImportPatientAndGetPatientBookings(patientId As Integer, patNHSNo As String, RetrivedFrom As String) As String
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
        Return GetPatientBookings(patientId)
    End Function

    <System.Web.Services.WebMethod>
    Shared Function GetPatientBookings(patientId As Integer) As String
        Try
            Dim bookings As New List(Of Object)

            Using db As New ERS.Data.GastroDbEntities
                Dim dbResult = (From a In db.ERS_Appointments
                                Join apt In db.ERS_AppointmentProcedureTypes On apt.AppointmentID Equals a.AppointmentId
                                Join pt In db.ERS_ProcedureTypes On apt.ProcedureTypeID Equals pt.ProcedureTypeId
                                Join d In db.ERS_SCH_DiaryPages On a.DiaryId Equals d.DiaryId
                                From s In db.ERS_AppointmentStatus.Where(Function(x) x.UniqueId = a.AppointmentStatusId).DefaultIfEmpty
                                Where a.PatientId = patientId And
                                      a.StartDateTime >= Now And
                                    (Not a.AppointmentStatusId.HasValue Or Not s.HDCKEY = "C") 'appointment status is null or not cancelled
                                Group By a.StartDateTime Into g = Group
                                Select StartDateTime, Procedures = g.ToList()).ToList()

                If dbResult.Count > 0 Then
                    For Each r In dbResult
                        Dim obj = New With {
                            .BookingDate = r.StartDateTime.ToString("dd/MM/yyyy HH:mm"),
                            .ProcedureType = String.Join(" + ", r.Procedures.Select(Function(x) x.pt.ProcedureType).ToList)
                        }
                        bookings.Add(obj)
                    Next
                End If
            End Using

            Return New JavaScriptSerializer().Serialize(bookings)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetPatientBookings: " + ex.ToString(), ex)
            Return ""
        End Try
    End Function

    <System.Web.Services.WebMethod>
    Shared Function UpdateGenderList(diaryID As Integer, male As Boolean, female As Boolean, listDate As String) As Boolean
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim genderList = db.ERS_SCH_GenderList.Where(Function(x) x.DiaryId = diaryID And x.ListDate = CDate(listDate)).FirstOrDefault
                If genderList Is Nothing Then
                    genderList = New ERS.Data.ERS_SCH_GenderList
                    genderList.DiaryId = diaryID
                End If

                With genderList
                    .Female = female
                    .Male = male
                    .ListDate = CDate(listDate)
                End With

                If genderList.GenderListId = 0 Then
                    db.ERS_SCH_GenderList.Add(genderList)
                Else
                    db.ERS_SCH_GenderList.Attach(genderList)
                    db.Entry(genderList).State = Entity.EntityState.Modified
                End If

                db.SaveChanges()
            End Using

            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("UpdateGenderList: " + ex.ToString(), ex)
            Return False
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Sub SaveDayNotes(noteDate As String, noteTime As String, noteText As String, roomId As Integer, operatingHospitalId As Integer, userId As Integer)
        Dim da As New DataAccess_Sch
        da.saveDayNote(CDate(noteDate), noteTime, noteText, roomId, operatingHospitalId, userId)
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function GetDayNotes(noteDate As String, roomId As Integer, operatingHospitalId As Integer) As String
        Dim da As New DataAccess_Sch
        Dim dbResult = da.getDayNotes(CDate(noteDate), roomId, operatingHospitalId)
        Dim notes As New List(Of Object)

        For Each r In dbResult.AsEnumerable
            Dim obj = New With {
                .TimeOfDay = Trim(r("NoteTime")),
                .NoteText = Trim(r("NoteText"))
            }
            notes.Add(obj)
        Next

        Return New JavaScriptSerializer().Serialize(notes)
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function GetCancellationReasons() As String
        Dim da As New DataAccess_Sch
        Dim dbResult = da.CancellationReasons()
        Dim cancellationReasons As New List(Of Object)

        For Each r In dbResult.AsEnumerable
            Dim obj = New With {
                .CancelReasonId = Trim(r("CancelReasonId")),
                .CancellationReason = Trim(r("CancellationReason"))
            }
            cancellationReasons.Add(obj)
        Next

        Return New JavaScriptSerializer().Serialize(cancellationReasons)
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function getAmendedBookings(diaryDate As String, roomId As Integer) As String
        Try

            Dim da As New DataAccess_Sch
            Dim dbResult = da.checkAmendedBookings(diaryDate, roomId)
            Dim amendedBookings As New List(Of Object)

            For Each r In dbResult.AsEnumerable
                Dim diaryStartTime = CDate(r("DiaryStart")).TimeOfDay
                Dim diaryType As String = ""

                If diaryStartTime < New TimeSpan(12, 0, 0) Then
                    diaryType = "AM"
                ElseIf diaryStartTime >= New TimeSpan(12, 0, 0) And diaryStartTime < New TimeSpan(17, 0, 0) Then
                    diaryType = "PM"
                ElseIf diaryStartTime >= New TimeSpan(17, 0, 0) Then
                    diaryType = "EVE"
                End If

                Dim obj = New With {
                    .diaryType = diaryType
                }
                amendedBookings.Add(obj)
            Next

            Return New JavaScriptSerializer().Serialize(amendedBookings)

        Catch ex As Exception
            Throw ex
        End Try
    End Function

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

    <System.Web.Services.WebMethod()>
    Public Shared Sub ReleaseReservedSlots()
        Try
            DataAccess_Sch.ReleaseRedundantLockedSlots()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in ReleaseReservedSlots", ex)
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub UnlockReservedSlot(endoscopistId As Integer)
        Try
            DataAccess_Sch.ReleaseRedundantLockedSlots(endoscopistId)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in UnlockReservedSlot", ex)
        End Try
    End Sub

    Protected Sub ReservedSlotCheckTimer_Tick(sender As Object, e As EventArgs)
        Try
            DataAccess_Sch.ReleaseRedundantLockedSlots()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error unreserving slots", ex)
        End Try
    End Sub

    <System.Web.Services.WebMethod>
    Public Shared Sub SetAppointmentId(appointmentId As Integer)
        Dim ctx As HttpContext = System.Web.HttpContext.Current
        ctx.Session("AppointmentId") = appointmentId
    End Sub

    <System.Web.Services.WebMethod>
    Public Shared Function GetAppointmentId() As Integer
        Dim ctx As HttpContext = System.Web.HttpContext.Current
        Return ctx.Session("AppointmentId")
    End Function
#End Region

End Class