Imports Microsoft.VisualBasic
Imports System.Data.SqlClient
Imports ERS.Data

Public Class DataAccessi2
    Inherits System.Web.Services.WebService
#Region "Connection Strings Properties"
    Private Shared _ConnectionDatabaseName As String

    Public ReadOnly Property LoggedInUserId As Integer
        Get
            Return CInt(HttpContext.Current.Session("PKUserID"))
        End Get
    End Property


    Public Shared Property ConnectionStr() As String
        Get
            Return DataAccess.ConnectionStr
        End Get
        Set(value As String)
            _ConnectionDatabaseName = value
        End Set
    End Property


    Friend Function getPreviousProcedurePDF(previousProcedureId As Integer) As Byte()
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT PDFBinary FROM ERS_PreviousProcedures WHERE PreviousProcedureId = @PreviousProcedureId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@PreviousProcedureId", previousProcedureId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using

    End Function

    Friend Function getStentInsertionDetails(iTherapeuticId As String) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_ERCPTherapeuticStentInsertions WHERE TherapeuticId = @TherapeuticId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@TherapeuticId", iTherapeuticId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function addNewScopeGeneration(ScopeManufacturerId As String, ScopeGenerationName As String) As Integer
        Try

            If Trim(ScopeGenerationName) = "" Then Return 0


            Using connection As New SqlConnection(ConnectionStr)
                Dim value As Object
                Dim cmd As New SqlCommand("scope_generation_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ScopeManufacturerId", ScopeManufacturerId))
                cmd.Parameters.Add(New SqlParameter("@ScopeGenerationName", ScopeGenerationName))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                value = cmd.ExecuteScalar()
                If Not IsDBNull(value) Then Return CInt(value)
                Return 0
            End Using

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function saveScope(scopeId As Integer, ScopeName As String, OperatingHospitalId As Integer, ScopeGenerationId As Integer, AllProcedures As Boolean) As Integer
        Try
            Dim newId = 0

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("scope_save", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@scopeId", scopeId))
                cmd.Parameters.Add(New SqlParameter("@ScopeName", ScopeName))
                cmd.Parameters.Add(New SqlParameter("@AllProcedures", AllProcedures))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@ScopeGenerationId", ScopeGenerationId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                newId = cmd.ExecuteScalar()
            End Using

            Return newId
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Public Function AddNonGIProcedureType(procedureTypeName As String, operatingHospitalId As Integer) As Integer
        Try
            Dim newId = 0

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("add_non_gi_procedure_type", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@procedureTypeName", procedureTypeName))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

                connection.Open()
                newId = cmd.ExecuteScalar()
            End Using

            Return newId
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Friend Function NonGIGMCCodeExists(GMCCode As String, userId As Integer) As Boolean
        Try
            Dim sql As String = "SELECT 1 FROM ERS_NonGIConsultants WHERE ISNULL(GMCCode,'') = @GMCCode AND (UserId <> @UserId)"
            Dim idObj As Object

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@GMCCode", GMCCode))
                cmd.Parameters.Add(New SqlParameter("@UserId", userId))

                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CBool(idObj)
                End If
            End Using
            Return False
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function NonGIUserExists(forename As String, surname As String, GMCCode As String) As Boolean
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("SELECT CASE WHEN COUNT(*) >1 THEN 1 ELSE 0 END FROM ERS_NonGIConsultants WHERE forename = @forename AND Surname = @surname AND GMCCode = @surname", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@forename", forename))
                cmd.Parameters.Add(New SqlParameter("@surname", surname))
                cmd.Parameters.Add(New SqlParameter("@gmccode", GMCCode))
                connection.Open()
                Return CBool(cmd.ExecuteScalar())
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetProcedureSpecimenCount(procedureId As Integer) As Integer
        Try
            Dim sql As String = "SELECT count(*) FROM dbo.ERS_UpperGISpecimens eug INNER JOIN dbo.ERS_Sites es ON eug.SiteId = es.SiteId WHERE es.ProcedureId = @ProcedureId"
            Dim idObj As Object

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CInt(idObj)
                End If
            End Using
            Return 0
        Catch ex As Exception
            Return 0
        End Try
    End Function

    Friend Function GetHasProcedureFNA(procedureId As Integer) As Boolean
        Try
            Dim idObj As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("PathResultsDisplayFNA", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CBool(idObj)
                Else
                    Return False
                End If

            End Using
        Catch ex As Exception
            Return False
        End Try
    End Function


    Friend Function GetUserOperatingHospitals(editUserId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT OperatingHospitalId FROM ERS_UserOperatingHospitals WHERE UserId = @UserId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", editUserId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Sub UpdateIsActive(imagePortId As Integer, status As Boolean)
        Dim sql = "UPDATE ERS_ImagePort SET IsActive = @Active, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE ImagePortId = @ImagePortId"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@Active", status))
            cmd.Parameters.Add(New SqlParameter("@ImagePortId", imagePortId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Sub cancelWorklistPatient(worklistId As Integer)
        Dim sql = "UPDATE ERS_Appointments SET AppointmentStatusId = (SELECT [UniqueId] FROM ERS_AppointmentStatus WHERE HDCKey = 'C') WHERE AppointmentId = @AppointmentId"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", worklistId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Function UserNameExists(userName As String, operatingHospitalIds As String, userId As Integer) As Boolean
        Dim sql As String = "SELECT TOP 1 CASE WHEN eu.UserID IS NULL THEN 0 ELSE 1 END AS 'Exists' 
                            FROM dbo.ERS_Users eu 
                                INNER JOIN dbo.ERS_UserOperatingHospitals euoh ON eu.UserID = euoh.UserId 
                            WHERE eu.Username=@Username AND euoh.OperatingHospitalId IN (" & operatingHospitalIds & ") AND eu.UserId <> @UserId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@UserName", userName))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalIds))
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Friend Sub AddNewReferringHospital(hospitalName As String)
        Dim sql = "INSERT INTO ERS_ReferralHospitals (HospitalName) VALUES (@HospitalName)"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@HospitalName", hospitalName))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Sub UpdateReferringHospital(hospitalId As Integer, hospitalName As String)
        Dim sql = "UPDATE ERS_ReferralHospitals SET HospitalName = @HospitalName WHERE HospitalId = @HospitalId"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@HospitalName", hospitalName))
            cmd.Parameters.Add(New SqlParameter("@HospitalId", hospitalId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Sub UpdateUsersOperatingHospitals(userId As Integer, operatingHospitalIds As String)
        Dim sql As String = "DELETE FROM ERS_UserOperatingHospitals WHERE UserId = @UserId; 
                                INSERT INTO ERS_UserOperatingHospitals (UserId, OperatingHospitalId) VALUES "

        For Each oh In operatingHospitalIds.Split(",")
            sql += " (@userId, " & oh & "), "
        Next

        sql = TransactionSQL(sql.Remove(sql.ToString().Length - 2))

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalIds))

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Function SpecialtyExists(newGroupName As String, newGroupCode As String) As Boolean
        Dim sql As String = "SELECT CASE WHEN GroupID IS NULL THEN 0 ELSE 1 END FROM ERS_ConsultantGroup WHERE GroupName = @GroupName OR Code = @GroupCode"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@GroupName", newGroupName))
            cmd.Parameters.Add(New SqlParameter("@GroupCode", newGroupCode))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            Else
                Return False
            End If
        End Using
    End Function

    Friend Sub logProcedureEnd(procedureId As Integer)
        Try
            Using db As New GastroDbEntities
                Dim tblPatientJourney = db.ERS_PatientJourney.Where(Function(x) x.ProcedureId = procedureId).FirstOrDefault
                If tblPatientJourney IsNot Nothing Then
                    tblPatientJourney.ProcedureEndTime = Now
                End If
                db.ERS_PatientJourney.Attach(tblPatientJourney)
                db.Entry(tblPatientJourney).State = Entity.EntityState.Modified
                db.SaveChanges()

                If tblPatientJourney.AppointmentId IsNot Nothing Then
                    Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = tblPatientJourney.AppointmentId).FirstOrDefault
                    Dim appointmentProceduresCount = db.ERS_AppointmentProcedureTypes.Count(Function(x) x.AppointmentID = tblPatientJourney.AppointmentId)

                    'check if a solo procedure or if all are in the patient journey table with end dates. if so update status to PC
                    If appointmentProceduresCount = 1 Or db.ERS_PatientJourney.Count(Function(x) x.AppointmentId = tblPatientJourney.AppointmentId And x.ProcedureEndTime.HasValue) = appointmentProceduresCount Then
                        appointment.AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "RC").FirstOrDefault.UniqueId
                        db.ERS_Appointments.Attach(appointment)
                        db.Entry(appointment).State = Entity.EntityState.Modified
                    End If
                End If

                db.SaveChanges()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error logging procedure end", ex)
        End Try
    End Sub

    Friend Function GMCCodeExists(GMCCode As String, userId As Integer) As Boolean
        Dim sql As String = "SELECT 1 FROM ERS_Users WHERE ISNULL(GMCCode,'') = @GMCCode AND UserId <> @UserId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@GMCCode", GMCCode))
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Friend Function ConsultantGMCCodeExists(GMCCode As String, ConsultantId As Integer) As Boolean
        Dim sql As String = "SELECT 1 FROM ERS_Consultant WHERE ISNULL(GMCCode,'') = @GMCCode AND ConsultantId <> @ConsultantId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@GMCCode", GMCCode))
            cmd.Parameters.Add(New SqlParameter("@ConsultantId", ConsultantId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Friend Function getPatientPathwayTimes(appointmentId As Integer) As DataTable
        Dim sb As StringBuilder = New StringBuilder()
        sb.Append("SELECT top (1) * from (Select ")
        sb.Append("PatientAdmissionTime, PatientDischargeTime FROM ERS_PatientJourney WHERE AppointmentId = @AppointmentId ")
        sb.Append("union select null, null) a ")
        sb.Append("order by PatientAdmissionTime desc, PatientDischargeTime desc ")
        'Dim sql As String = "SELECT PatientAdmissionTime, PatientDischargeTime FROM ERS_PatientJourney WHERE AppointmentId = @AppointmentId"
        Dim dsData As New DataSet


        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sb.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", appointmentId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function IsPEGProcedure(procedureId As Integer) As Boolean
        Try
            Dim idObj As Boolean

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("SELECT dbo.IsPEGProcedure(@ProcedureId)", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                connection.Open()
                Return CBool(cmd.ExecuteScalar())
            End Using

            Return idObj
        Catch ex As Exception
            Throw ex
        End Try
        Return False
    End Function

    Friend Function IsEUSSuccessful(procedureId As Integer) As Boolean
        Try
            Dim idObj As Boolean

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("get_eus_success", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                connection.Open()
                Return CBool(cmd.ExecuteScalar())
            End Using

            Return idObj
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("", ex)
        End Try
        Return False
    End Function

    Friend Sub AddPatientToWorklist(patientId As Integer, procedureDate As Date, endoscopist As Integer, procedureTypeId As Integer, operatingHospitalId As Integer, timeOfDay As String)
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("add_to_worklist", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
            cmd.Parameters.Add(New SqlParameter("@StartDateTime", procedureDate))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@TimeOfDay", timeOfDay))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            If endoscopist > 0 Then
                cmd.Parameters.Add(New SqlParameter("@Endoscopist", endoscopist))
            Else
                cmd.Parameters.Add(New SqlParameter("@Endoscopist", DBNull.Value))
            End If
            If procedureTypeId > 0 Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", procedureTypeId))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", DBNull.Value))
            End If

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Function AddNewOperatingHospital(ByVal reportHeading As String,
                                            ByVal reportSubHeading As String,
                                            ByVal reportFooter As String,
                                            ByVal reportTrustType As String,
                                            ByVal departmentName As String,
                                            ByVal hospitalName As String,
                                            ByVal contactNumber As String,
                                            ByVal internalHospitalId As String,
                                            ByVal nhsHospitalId As String,
                                            ByVal pdfExportPath As String,
                                            ByVal NEDODSCode As String,
                                            ByVal NEDExportPath As String,
                                            ByVal copyPrintSettings As Boolean,
                                            ByVal copyPhraseLibrary As Boolean) As Integer

        Dim newId = 0

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("add_new_operating_hospital", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@InternalHospitalID", internalHospitalId))
            cmd.Parameters.Add(New SqlParameter("@NHSHospitalID", nhsHospitalId))
            cmd.Parameters.Add(New SqlParameter("@HospitalName", hospitalName))
            cmd.Parameters.Add(New SqlParameter("@ContactNumber", contactNumber))
            cmd.Parameters.Add(New SqlParameter("@ReportExportPath", pdfExportPath))
            cmd.Parameters.Add(New SqlParameter("@ReportHeading", reportHeading))
            cmd.Parameters.Add(New SqlParameter("@ReportTrustType", reportTrustType))
            cmd.Parameters.Add(New SqlParameter("@ReportSubHeading", reportSubHeading))
            cmd.Parameters.Add(New SqlParameter("@ReportFooter", reportFooter))
            cmd.Parameters.Add(New SqlParameter("@DepartmentName", departmentName))
            cmd.Parameters.Add(New SqlParameter("@NEDExportPath", NEDExportPath))
            cmd.Parameters.Add(New SqlParameter("@NEDODSCode", NEDODSCode))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@CopyPrintSettings", copyPrintSettings))
            cmd.Parameters.Add(New SqlParameter("@CopyPhraseLibrary", copyPhraseLibrary))

            connection.Open()
            newId = cmd.ExecuteScalar()
        End Using

        Return newId
    End Function

    Public Sub setEUSSuccess(EUSSuccessful As Boolean)
        Try
            Dim sql As String = "set_eus_success"
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sql.ToString(), connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))))
                cmd.Parameters.Add(New SqlParameter("@EUSSuccessful", EUSSuccessful))
                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Shared Function ProcedureDNA(procedureId As Integer) As String
        Dim sql As String = "SELECT PP_DNA FROM dbo.ERS_Procedures ep INNER JOIN dbo.ERS_ProceduresReporting epr ON ep.ProcedureId = epr.ProcedureId WHERE ep.ProcedureId=@ProcedureId AND ep.DNA IS NOT NULL"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            Dim dbRes = cmd.ExecuteScalar()
            Return dbRes
        End Using
        Return False
    End Function

    Public Function GetWorklistRecord(AppointementId As Integer, operatingHospitalId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_worklist_patient", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", AppointementId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetWorklistPatient(Optional PatientId As Integer = 0, Optional OperatingHospitalId As Integer = 0) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_worklist_patient", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", DBNull.Value))
            cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Shared ReadOnly Property ConnectionStrLogging() As String
        Get
            Using Securitee As New ERS.Security.Simple3Des("")
                Return Securitee.ConnectionStringBuilder(ConfigurationManager.ConnectionStrings("Logging_DB").ConnectionString)
            End Using
        End Get
    End Property

    Public Shared ReadOnly Property ConnectionStrPASData() As String
        Get
            Using Securitee As New ERS.Security.Simple3Des("")
                Return Securitee.ConnectionStringBuilder(ConfigurationManager.ConnectionStrings("PASData").ConnectionString)
            End Using
        End Get
    End Property

    Friend Function GetPatientByCNN(cnn As String) As DataTable
        Dim dsData As New DataSet
        Dim sql As String = "SELECT * FROM ERS_VW_Patients WHERE HospitalNumber = @CNN"
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.Parameters.Add(New SqlParameter("@CNN", cnn))

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
#End Region

#Region "Base Methods"
    <Obsolete("This method is deprecated, use [DataAccess.ExecuteScalerSQL(ScalerExecuteSQL)] instead.")>
    Private Function GetData(ByVal sqlQuery As String) As DataTable
        Dim dsData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sqlQuery, connection)
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

    <Obsolete("This method is deprecated, use [DataAccess.ExecuteSP(StoredProcName, paramList)] instead.")>
    Private Function GetData(ByVal sqlQuery As String, sqlType As CommandType) As DataTable
        Dim dsData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sqlQuery, connection)
            cmd.CommandType = sqlType
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetAbnormalities(siteId As Integer, tableName As String) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM " + tableName + " WHERE SiteId = @SiteId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function ProcedureAmended(procedureId As Integer) As Boolean
        Dim sql As String = "SELECT ISNULL(ReportUpdated,0) FROM ERS_Procedures WHERE ProcedureId = @ProcedureId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Public Function ResetProcedureAmended(procedureId As Integer) As Boolean
        Dim sql As String = "UPDATE ERS_Procedures SET ReportUpdated = 0 WHERE ProcedureId = @ProcedureId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function
#End Region

#Region "Generic Methods"
    Public Function IsSystemDisabled(ByVal operatingHospitalId As Integer) As Boolean
        Dim sql As String = "SELECT SystemDisabled FROM ERS_SystemConfig WHERE OperatingHospitalID = @OperatingHospitalID"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", operatingHospitalId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Public Function GetSurgicalSafetyCheckListCompleted() As Boolean
        Dim sql As String = "SELECT TOP(1) ISNULL(CompleteWHOSurgicalSafetyCheckList,0) AS CompleteWHOSurgicalSafetyCheckList FROM ERS_SystemConfig"
        Dim idObj As Object
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Public Sub InsertDummyText(ByVal patientNo As String, ByVal episodeNo As Integer,
                               ByVal tableName As String, ByVal fieldName As String, ByVal dummyText As String,
                               ByVal procedureId As Integer, ByVal recordIdentifier As String)

        Dim sql As New StringBuilder
        sql.Append(String.Format("UPDATE [{0}] ", tableName))
        sql.Append(String.Format("SET [{0}] = @DummyText ", fieldName))
        sql.Append("WHERE PatientNo = @PatientNo ")
        sql.Append("AND EpisodeNo = @EpisodeNo ")
        sql.Append("INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId],[Identifier],[RecordCount]) ")
        sql.Append("VALUES (@ProcedureId, NULL, @Identifier, 1) ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DummyText", dummyText))
            cmd.Parameters.Add(New SqlParameter("@PatientNo", patientNo))
            cmd.Parameters.Add(New SqlParameter("@EpisodeNo", episodeNo))
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@Identifier", recordIdentifier))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Function GetReferralOptions(Suppressed As Boolean?) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("common_referral_types_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            If Suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = Suppressed})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = DBNull.Value})
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

    Public Sub SaveAuditLog_X(
                               Category As Nullable(Of Integer),
                                EventType As Nullable(Of Integer),
                                ApplicationID As Nullable(Of Integer),
                                AppVersion As String,
                               UserID As String,
                                FullUsername As String,
                                StationID As String,
                               HospitalID As Nullable(Of Integer),
                               HospitalName As String,
                                OperatingHospitalID As Nullable(Of Integer),
                                OperatingHospitalName As String,
                                PatientNo As String,
                               EpisodeNo As Nullable(Of Integer),
                                CaseNoteNo As String,
                               ProcedureID As Nullable(Of Integer),
                                ProcedureDate As Nullable(Of DateTime),
                                ProcedureName As String,
                            EventDescription As String,
                            DatabaseName As String)
        Dim sql As String = "INSERT INTO [ERS_AuditLog] (Category,EventType,ApplicationID,AppVersion,UserID,FullUsername,StationID,HospitalID,HospitalName,OperatingHospitalID,OperatingHospitalName,PatientNo,EpisodeNo,CaseNoteNo,ProcedureID,ProcedureDate,ProcedureName,EventDescription,DatabaseName) " &
                            "VALUES (@Category,@EventType,@ApplicationID,@AppVersion,@UserID,@FullUsername,@StationID,@HospitalID,@HospitalName,@OperatingHospitalID,@OperatingHospitalName,@PatientNo,@EpisodeNo,@CaseNoteNo,@ProcedureID,@ProcedureDate,@ProcedureName,@EventDescription,@DatabaseName) "
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            If Category.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Category", Category))
            Else
                cmd.Parameters.Add(New SqlParameter("@Category", SqlTypes.SqlInt32.Null))
            End If
            If EventType.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@EventType", EventType))
            Else
                cmd.Parameters.Add(New SqlParameter("@EventType", SqlTypes.SqlInt32.Null))
            End If
            If ApplicationID.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ApplicationID", ApplicationID))
            Else
                cmd.Parameters.Add(New SqlParameter("@ApplicationID", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(AppVersion) Then
                cmd.Parameters.Add(New SqlParameter("@AppVersion", AppVersion))
            Else
                cmd.Parameters.Add(New SqlParameter("@AppVersion", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(UserID) Then
                cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
            Else
                cmd.Parameters.Add(New SqlParameter("@UserID", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(FullUsername) Then
                cmd.Parameters.Add(New SqlParameter("@FullUsername", FullUsername))
            Else
                cmd.Parameters.Add(New SqlParameter("@FullUsername", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(StationID) Then
                cmd.Parameters.Add(New SqlParameter("@StationID", StationID))
            Else
                cmd.Parameters.Add(New SqlParameter("@StationID", SqlTypes.SqlString.Null))
            End If
            If HospitalID.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@HospitalID", HospitalID))
            Else
                cmd.Parameters.Add(New SqlParameter("@HospitalID", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(HospitalName) Then
                cmd.Parameters.Add(New SqlParameter("@HospitalName", HospitalName))
            Else
                cmd.Parameters.Add(New SqlParameter("@HospitalName", SqlTypes.SqlString.Null))
            End If
            If OperatingHospitalID.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalID))
            Else
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(OperatingHospitalName) Then
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalName", OperatingHospitalName))
            Else
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalName", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PatientNo) Then
                cmd.Parameters.Add(New SqlParameter("@PatientNo", PatientNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@PatientNo", SqlTypes.SqlString.Null))
            End If

            If EpisodeNo.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@EpisodeNo", EpisodeNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@EpisodeNo", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(CaseNoteNo) Then
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", CaseNoteNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", SqlTypes.SqlString.Null))
            End If

            If ProcedureID.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureID", SqlTypes.SqlInt32.Null))
            End If
            If ProcedureDate.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureDate", ProcedureDate))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureDate", SqlTypes.SqlDateTime.Null))
            End If

            If Not String.IsNullOrEmpty(ProcedureName) Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureName", ProcedureName))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureName", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(EventDescription) Then
                cmd.Parameters.Add(New SqlParameter("@EventDescription", EventDescription))
            Else
                cmd.Parameters.Add(New SqlParameter("@EventDescription", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DatabaseName) Then
                cmd.Parameters.Add(New SqlParameter("@DatabaseName", DatabaseName))
            Else
                cmd.Parameters.Add(New SqlParameter("@DatabaseName", SqlTypes.SqlString.Null))
            End If
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Sub UpdateDistalAttachment(DistalAttachmentId As String, DistalAttachmentName As String, ProcedureId As Integer)
        Try
            If DistalAttachmentId = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("Distal attachment", DistalAttachmentName)
                If newId > 0 Then
                    DistalAttachmentId = newId
                End If
            End If

            Using db As New ERS.Data.GastroDbEntities
                Dim procedure = db.ERS_Procedures.Where(Function(x) x.ProcedureId = ProcedureId).FirstOrDefault
                procedure.DistalAttachmentId = DistalAttachmentId
                db.ERS_Procedures.Attach(procedure)
                db.Entry(procedure).State = Entity.EntityState.Modified
                db.SaveChanges()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetAvailableImagePorts(OperatingHospitalId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim SQL = "SELECT * FROM ERS_ImagePort WHERE OperatingHospitalId = @OperatingHospitalId AND ISNULL(PCName, '') = '' AND IsActive = 1 ORDER BY PortName"

            Dim cmd As New SqlCommand(SQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetAvailableImagePortsForRoom(RoomId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            'Dim SQL = "SELECT * FROM ERS_ImagePort WHERE RoomId = @RoomId AND IsActive = 1 ORDER BY PortName"
            Dim SQL = "SELECT * FROM ERS_ImagePort WHERE RoomId = @RoomId AND IsActive = 1 ORDER BY [Default] DESC"

            Dim cmd As New SqlCommand(SQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomId", RoomId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetPCImagePortID() As Integer
        Try
            Dim ImgPortID As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("SELECT Top 1 ImagePortId FROM ERS_ImagePort WHERE IsActive=1 AND RoomID=@RoomId AND OperatingHospitalId=@OpHospital", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@RoomId", Session("RoomId").ToString()))
                cmd.Parameters.Add(New SqlParameter("@OpHospital", CInt(Session("OperatingHospitalID"))))
                connection.Open()
                ImgPortID = cmd.ExecuteScalar()
                If ImgPortID IsNot Nothing AndAlso IsDBNull(ImgPortID) = False Then
                    Return CInt(ImgPortID)
                Else
                    Return 0
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function PCLogCheck(OperatingHospitalId As Integer) As Boolean
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim idObj As Object

            'Need to check if static or dynamic as well
            Dim SQL As String = "SELECT CASE " &
                " WHEN (SELECT TOP 1 1 FROM ERS_ImagePort WHERE OperatingHospitalId = @OperatingHospitalId AND RoomId = @RoomId AND IsActive = 1 AND ISNULL(Static,0) = 0) = 1 THEN 0 " &
                " WHEN (SELECT TOP 1 1 FROM ERS_PCLog WHERE ClientPCName = @RoomName) = 1 THEN 1 " &
                " ELSE 0 END"

            Dim cmd As New SqlCommand(SQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomId", Session("RoomId").ToString()))
            cmd.Parameters.Add(New SqlParameter("@RoomName", Session("RoomName").ToString()))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            'adapter.Fill(dsData)
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Friend Function IsTransnasalProcedure(procedureId As Integer) As Boolean
        Dim sql As String = "SELECT ISNULL(Transnasal, 0) AS Transnasal FROM ERS_Procedures WHERE ProcedureId = @ProcedureId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Public Function InsertError(ByVal ErrorNo As String,
                                ByVal ErrorMessage As String,
                                ByVal ErrorDescription As String,
                                ByVal ErrorStackTrace As String,
                                ByVal ErrorInnerException As String,
                                ByVal ErrorData As String,
                                ByVal ProductId As Integer,
                                ByVal ProductVersion As String,
                                ByVal UserId As String,
                                ByVal StationId As String,
                                ByVal ProcedureId As Nullable(Of Integer),
                                ByVal PatientId As Nullable(Of Integer),
                                ByVal CaseNoteNo As String,
                                ByVal HospitalId As Integer,
                                ByVal OperatingHospitalId As Integer) As String
        Dim sql As String = "INSERT INTO ERS_ErrorLog ([ErrorReference], [ErrorTimestamp], [ErrorNo], [ErrorMessage], [ErrorDescription], [ErrorStackTrace], [ErrorInnerException], [ErrorData], [ProductId], [ProductVersion], [UserId], [StationId], [ProcedureId], [PatientId], [CaseNoteNo], [HospitalId], [OperatingHospitalId]) " &
                            "VALUES (@errorReference, GETDATE(), @errorNo, @errorMessage, @errorDescription, @errorStackTrace, @errorInnerException, @errorData, @productId, @productVersion, @userId, @stationId, @procedureId, @patientId, @caseNoteNo, @hospitalId, @operatingHospitalId) "

        Dim reference As String = "ERS" & OperatingHospitalId & Date.Now.ToString("yyyyMMddHHmmss")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@errorReference", reference))
            If Not String.IsNullOrEmpty(ErrorNo) Then
                cmd.Parameters.Add(New SqlParameter("@errorNo", ErrorNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorNo", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@errorMessage", ErrorMessage))
            If Not String.IsNullOrEmpty(ErrorDescription) Then
                cmd.Parameters.Add(New SqlParameter("@errorDescription", ErrorDescription))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorDescription", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(ErrorStackTrace) Then
                cmd.Parameters.Add(New SqlParameter("@errorStackTrace", ErrorStackTrace))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorStackTrace", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(ErrorInnerException) Then
                cmd.Parameters.Add(New SqlParameter("@errorInnerException", ErrorInnerException))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorInnerException", SqlTypes.SqlString.Null))
            End If

            If Not String.IsNullOrEmpty(ErrorData) Then
                cmd.Parameters.Add(New SqlParameter("@errorData", ErrorData))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorData", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@productId", ProductId))
            cmd.Parameters.Add(New SqlParameter("@productVersion", HttpContext.Current.Session(Constants.SESSION_APPVERSION)))
            cmd.Parameters.Add(New SqlParameter("@userId", UserId))
            If Not String.IsNullOrEmpty(StationId) Then
                cmd.Parameters.Add(New SqlParameter("@stationId", StationId))
            Else
                cmd.Parameters.Add(New SqlParameter("@stationId", SqlTypes.SqlString.Null))
            End If
            If ProcedureId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@procedureId", ProcedureId))
            Else
                cmd.Parameters.Add(New SqlParameter("@procedureId", SqlTypes.SqlInt32.Null))
            End If
            If PatientId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@patientId", PatientId))
            Else
                cmd.Parameters.Add(New SqlParameter("@patientId", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(CaseNoteNo) Then
                cmd.Parameters.Add(New SqlParameter("@caseNoteNo", CaseNoteNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@caseNoteNo", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@HospitalId", HospitalId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
        Return reference
    End Function

    Friend Sub SavePDFToDatabase(procedureId As String, bBLOBStorage() As Byte)
        Dim sql As String = "Insert into ERS_DocumentStore (ProcedureId, PDF) values (@ProcedureId, @PDF)"
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim blobParam = New SqlParameter("@PDF", SqlDbType.VarBinary, bBLOBStorage.Length)
            blobParam.Value = bBLOBStorage
            cmd.Parameters.Add(blobParam)
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Function SavePDFToDatabase(patientId As Integer, procedureType As String, procedureDate As Date, bBLOBStorage() As Byte) As Boolean
        Try
            Dim sql As String = "Insert into ERS_PreviousProcedures (PatientId, ProcedureType, ProcedureDate, PDFBinary) " &
                "values (@patientId, @procedureType, @procedureDate, @PDFBinary)"
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
                cmd.Parameters.Add(New SqlParameter("@ProcedureDate", procedureDate))
                'cmd.Parameters.Add(New SqlParameter("@ProcedureDate", Now))
                Dim blobParam = New SqlParameter("@PDFBinary", SqlDbType.VarBinary, bBLOBStorage.Length)
                blobParam.Value = bBLOBStorage
                cmd.Parameters.Add(blobParam)
                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using

            Return True

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in SavePDFToDatabase", ex)
            Return False
        End Try
    End Function

    Public Function InsertPhrase(userName As String, Category As String, Phrase As String, OperatingHospitalId As Integer) As String
        Try
            Dim RecColID As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("common_phraselibrary_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@UserName", userName))
                cmd.Parameters.Add(New SqlParameter("@PhraseCategory", Category))
                cmd.Parameters.Add(New SqlParameter("@Phrase", Phrase))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                connection.Open()
                RecColID = cmd.ExecuteScalar()
                If RecColID IsNot Nothing AndAlso IsDBNull(RecColID) = False Then
                    Return CStr(RecColID)
                Else
                    Return Nothing
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function DeletePhrase(PhraseID As String) As Integer
        Try
            Dim RecColID As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("DELETE FROM [ERS_PhraseLibrary] WHERE PhraseID = @PhraseID", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@PhraseID", PhraseID))
                connection.Open()
                RecColID = cmd.ExecuteScalar()
                If RecColID IsNot Nothing AndAlso IsDBNull(RecColID) = False Then
                    Return CInt(RecColID)
                Else
                    Return Nothing
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function EditPhrase(PhraseID As String, Phrase As String) As Integer
        Try
            Dim RecColID As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("UPDATE [ERS_PhraseLibrary] SET Phrase = @Phrase, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE PhraseID = @PhraseID", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@PhraseID", PhraseID))
                cmd.Parameters.Add(New SqlParameter("@Phrase", Phrase))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                connection.Open()
                RecColID = cmd.ExecuteScalar()
                If RecColID IsNot Nothing AndAlso IsDBNull(RecColID) = False Then
                    Return CInt(RecColID)
                Else
                    Return Nothing
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetConsultants(ConsultantID As Integer) As DataTable
        Dim sqlStr As String = "Select ISNULL([Title],'') as Title, ISNULL([Initial],'') as Initial, ISNULL([ForeName],'') as ForeName, ISNULL([Surname],'') as Surname, " &
                                " ISNULL([GMCCode],'') as GMCCode , ISNULL([GroupID],0) as GroupID, ISNULL([AllHospitals],1) as AllHospitals  " &
                                " FROM [ERS_Consultant]  WHERE [ConsultantID] = " & CStr(ConsultantID)
        Return GetData(sqlStr)
    End Function

    Public Function UpdatePCSImagePort(RoomId As String, imageportId As Integer, isStatic As Boolean) As Boolean
        Dim idObj As Object

        Dim sql As String = "IF NOT EXISTS (SELECT 1 FROM ERS_ImagePort WHERE RoomId = @RoomId) BEGIN UPDATE ERS_ImagePort SET RoomId = @RoomId, Static = @isStatic WHERE ImagePortId = @ImagePortId; SELECT 1 END "
        sql += " ELSE SELECT 0;"
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomId", RoomId))
            cmd.Parameters.Add(New SqlParameter("@ImagePortId", imageportId))
            cmd.Parameters.Add(New SqlParameter("@isStatic", isStatic))
            cmd.Connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
            Return CBool(cmd.ExecuteScalar())
        End Using
    End Function








    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetConsultants(GroupID As String) As DataTable
        Dim sqlStr As String
        If GroupID = Nothing Or GroupID = "" Then
            sqlStr = "SELECT ConsultantId, ISNULL(LTRIM(RTRIM([Title])) + ' ', '') + ISNULL(LTRIM(RTRIM([Forename])) + ' ', '') + ISNULL(LTRIM(RTRIM([Surname])), '') as Name FROM [ERS_Consultant] WHERE [Suppressed] = 0"
        Else
            sqlStr = "SELECT ConsultantId, ISNULL(LTRIM(RTRIM([Title])) + ' ', '') + ISNULL(LTRIM(RTRIM([Forename])) + ' ', '') + ISNULL(LTRIM(RTRIM([Surname])), '') as Name FROM [ERS_Consultant] WHERE [Suppressed] = 0 AND  GroupID = " & GroupID
        End If
        Return GetData(sqlStr)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetConsultantsLst(Field As String, FieldValue As String, Suppressed As Nullable(Of Integer)) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("common_consultant_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalId", .SqlDbType = SqlDbType.Int, .Value = CInt(HttpContext.Current.Session("OperatingHospitalId"))})
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
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetPhotoURL(operatingHospitalId As Integer) As String
        Dim sqlStr = "SELECT ISNULL(PhotosURL,'') as PhotosURL FROM ERS_SystemConfig WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using
    End Function

    Friend Function IsNormalProcedure(procId As Integer) As Boolean
        Dim sqlStr = "SELECT CASE WHEN (SELECT TOP 1 1 FROM ers_sites WHERE ProcedureId = @ProcedureId AND isnull(HasAbnormalities,0) = 1) = 1 THEN 0 ELSE 1 END"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procId))
            connection.Open()
            Return CBool(cmd.ExecuteScalar())
        End Using
    End Function

    Public Function GetPhotoUNC(operatingHospitalId As Integer) As String
        Dim sqlStr = "SELECT ISNULL(PhotosUNC,'') as PhotosUNC FROM ERS_SystemConfig WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetConsultantsHospitalList(ConsultantID As Integer) As DataTable
        Dim sqlStr As String = "SELECT [HospitalID] FROM [ERS_ConsultantsHospital] WHERE [ConsultantID] = " & CStr(ConsultantID)
        Return GetData(sqlStr)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSpeciality() As DataTable
        Dim sqlStr As String = "SELECT [GroupID], [GroupName], [Code] FROM [ERS_ConsultantGroup] ORDER BY GroupName"
        Return GetData(sqlStr)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSpeciality(ConsultantID As String) As String
        Dim value As String
        Dim querystr As String = "SELECT g.[GroupID], g.[Code] FROM [ERS_ConsultantGroup] g LEFT JOIN [ERS_Consultant] c ON g.Code = c.GroupID  WHERE c.ConsultantID = @ConsultantID"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@ConsultantID", ConsultantID))
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If Not IsDBNull(v) Then
                If IsNothing(v) Then
                    value = Nothing
                Else
                    value = v.ToString
                End If
            Else
                value = Nothing
            End If
        End Using
        Return value
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHospital() As DataTable
        Dim sqlStr As String = "SELECT [HospitalID],  [HospitalName],[Suppressed]  FROM [dbo].[ERS_ReferralHospitals] WHERE [Suppressed] = 0 ORDER BY HospitalName"
        Return GetData(sqlStr)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHospitals() As DataTable
        Dim sqlStr As String = "SELECT [HospitalID],  [HospitalName],(CASE [Suppressed] WHEN 1 THEN 'Yes' ELSE 'No' END) as Suppressed   FROM [dbo].[ERS_ReferralHospitals] ORDER BY HospitalName"
        Return GetData(sqlStr)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHospitalsLst(HospitalName As String, Suppressed As Nullable(Of Integer)) As DataTable
        Dim sqlStr As String = "SELECT [HospitalID],  [HospitalName],(CASE [Suppressed] WHEN 1 THEN 'Yes' ELSE 'No' END) as Suppressed   
                                FROM [dbo].[ERS_ReferralHospitals] 
                                WHERE HospitalName LIKE '%' +ISNULL(@HospitalName,HospitalName) +'%'
                                    AND Suppressed = ISNULL(@Suppressed, Suppressed)
                                ORDER BY HospitalName"

        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@HospitalName", HospitalName))

            If Suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Suppressed", Suppressed.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@Suppressed", DBNull.Value))

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
    Public Function SaveHospital(HospitalName As String) As Integer
        Dim sql As String = "common_hospital_save"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@HospitalName", HospitalName))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function
    Public Function SaveSpeciality(GroupName As String, GroupCode As String) As Integer
        Dim sql As String = "common_speciality_save"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@GroupName", GroupName))
            cmd.Parameters.Add(New SqlParameter("@GroupCode", GroupCode))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function
    Public Function SuppressHospital(HospitalID As String, Suppressed As Boolean) As Integer
        Dim sql As String = "UPDATE [ERS_ReferralHospitals] SET [Suppressed] = @Suppressed WHERE [HospitalID]= @HospitalID"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@Suppressed", Suppressed))
            cmd.Parameters.Add(New SqlParameter("@HospitalID", HospitalID))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    Public Function SuppressConsultant(ConsultantID As String, Suppressed As Boolean) As Integer
        Dim sql As String = "UPDATE [ERS_Consultant] SET [Suppressed] = @Suppressed, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE [ConsultantID]= @ConsultantID"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@Suppressed", Suppressed))
            cmd.Parameters.Add(New SqlParameter("@ConsultantID", ConsultantID))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetReferralHospitals(ConsultantID As String) As DataTable
        Dim sqlStr As String = Nothing
        If ConsultantID = Nothing Or ConsultantID = "" Then
            sqlStr = "SELECT * FROM [ERS_ReferralHospitals] WHERE [Suppressed] = 0"
        Else
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim querystr As String = "SELECT [AllHospitals] FROM [ERS_Consultant] WHERE [ConsultantID] = " & ConsultantID
                Dim mycmd As New SqlCommand(querystr, connection)
                mycmd.CommandType = CommandType.Text
                connection.Open()
                Dim value As Object = mycmd.ExecuteScalar()
                If Not IsDBNull(value) Then
                    If CBool(value) = True Then
                        sqlStr = "SELECT * FROM [ERS_ReferralHospitals] WHERE [Suppressed] = 0"
                    Else
                        sqlStr = "SELECT rh.[HospitalName],rh.[HospitalID] FROM [ERS_ReferralHospitals] rh LEFT JOIN [ERS_ConsultantsHospital] ch ON rh.[HospitalID]  = ch.[HospitalID] WHERE rh.[Suppressed] =0 AND ch.ConsultantID= " & ConsultantID
                    End If
                End If
            End Using
        End If
        Return GetData(sqlStr)
    End Function
    Public Function SaveConsultant(ConsultantID As Integer, Title As String, Initial As String, Forename As String, Surname As String, GroupID As String, AllHospitals As Nullable(Of Boolean), GMCCode As String, HospitalList As String) As Integer
        Dim sql As String = "common_consultant_save"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ConsultantID", ConsultantID))
            If Title = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Title", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Title", .SqlDbType = SqlDbType.Text, .Value = Title})
            End If
            If Initial = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Initial", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Initial", .SqlDbType = SqlDbType.Text, .Value = Initial})
            End If
            If Forename = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Forename", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Forename", .SqlDbType = SqlDbType.Text, .Value = Forename})
            End If
            If Surname = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Surname", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Surname", .SqlDbType = SqlDbType.Text, .Value = Surname})
            End If
            If GroupID = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GroupID", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GroupID", .SqlDbType = SqlDbType.Text, .Value = GroupID})
            End If
            'cmd.Parameters.Add(New SqlParameter("@GroupID", GroupID))
            cmd.Parameters.Add(New SqlParameter("@AllHospitals", AllHospitals))
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LoggedInUserId", .SqlDbType = SqlDbType.Int, .Value = LoggedInUserId})

            If GMCCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GMCCode", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GMCCode", .SqlDbType = SqlDbType.Text, .Value = GMCCode})
            End If
            If HospitalList = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HospitalList", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HospitalList", .SqlDbType = SqlDbType.Text, .Value = HospitalList})
            End If
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    Public Function GetProceduresImagePort(procedureId As Integer) As DataTable
        Dim rSet As New DataSet
        'FormerProcedureId below is required for double procedure, to display images captured in the former procedure from cache
        Dim sql As String = "SELECT ISNULL(ep.ImagePortId,0) AS ImagePortId, eip.PortName, ISNULL(ep.FormerProcedureId,0) AS FormerProcedureId
                                FROM dbo.ERS_Procedures ep
	                                INNER JOIN dbo.ERS_ImagePort eip 
		                                ON ep.ImagePortId = eip.ImagePortId
                                WHERE ep.ProcedureId = @ProcedureId"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(rSet)
        End Using
        If rSet.Tables.Count > 0 Then
            Return rSet.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetImagePortRooms(operatingHospitalId As Integer) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            'Dim sqlCmd As New SqlCommand("SELECT ip.ImagePortId, ip.MacAddress, ip.FriendlyName, ip.[Default], rooms.RoomId, rooms.RoomName, ip.Static, ip.Comments, ip.PortName " &
            '                "FROM ERS_SCH_Rooms AS rooms " &
            '                "LEFT JOIN ERS_ImagePort AS ip ON rooms.HospitalId = ip.OperatingHospitalId ", connection)
            Dim sqlCmd As New SqlCommand("SELECT rooms.RoomId, rooms.RoomName " &
                            "FROM ERS_SCH_Rooms AS rooms " &
                            "WHERE HospitalId = @OperatingHospitalId ", connection)


            sqlCmd.CommandType = CommandType.Text
            sqlCmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            Dim adapter = New SqlDataAdapter(sqlCmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If

        Return Nothing

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetImagePortRoomsSpecific(imagePortId As Integer, roomId As Integer) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("image_port_room_specific_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ImagePortId", imagePortId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
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
    Public Function GetOperatingHospitalID(RoomId As Integer) As Integer

        Dim value As Integer = -1
        Dim querystr As String = "SELECT TOP 1 o.OperatingHospitalId
                            FROM ERS_OperatingHospitals o
                            LEFT JOIN ERS_SCH_Rooms r ON o.OperatingHospitalId = r.HospitalId WHERE r.RoomId = '" & RoomId & "'"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim mycmd As New SqlCommand(querystr, connection)
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If Not IsDBNull(v) AndAlso Not IsNothing(v) Then
                value = CInt(v)
            Else
                value = -1
            End If
        End Using
        Return value
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOperatingHospitalsRooms() As DataTable

        'Dim sql As String = "SELECT o.OperatingHospitalId, o.HospitalName, i.ImagePortId, i.PortName, i.RoomId, r.RoomName
        '                    FROM ERS_OperatingHospitals o
        '                    LEFT JOIN ERS_ImagePort i ON o.OperatingHospitalId = i.OperatingHospitalId
        '                    LEFT JOIN ERS_SCH_Rooms r ON o.OperatingHospitalId = r.HospitalId AND i.RoomId = r.RoomId ORDER BY HospitalName, RoomName ASC"
        Dim sql As String = "SELECT o.OperatingHospitalId, o.HospitalName, r.RoomId, r.RoomName
                            FROM ERS_OperatingHospitals o                            
                            LEFT JOIN ERS_SCH_Rooms r ON o.OperatingHospitalId = r.HospitalId"
        Return GetData(sql)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOperatingHospitals(sFirstItemText As String) As DataTable
        Return GetData("SELECT *, '" & sFirstItemText & "' AS FirstItemText  FROM [ERS_OperatingHospitals] ORDER BY HospitalName ASC")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOperatingHospitals() As DataTable
        Return GetData("SELECT * FROM [ERS_OperatingHospitals] ORDER BY OperatingHospitalId ASC")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTemplateOperatingHospitals() As DataTable
        Return GetData("SELECT OperatingHospitalId, HospitalName FROM dbo.ERS_OperatingHospitals eoh ORDER BY OperatingHospitalId")
    End Function

    Public Function GetInternalOperatingHospitalID(OperatingHospitalID As String) As String
        Dim value As String
        Dim querystr As String = "SELECT InternalHospitalID FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalID))
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If Not IsDBNull(v) AndAlso Not IsNothing(v) Then
                value = v.ToString
            Else
                value = Nothing
            End If
        End Using
        Return value
    End Function
    Public Function GetOperatingHospitalCount() As Integer
        Dim value As Integer = -1
        Dim querystr As String = "SELECT Count([OperatingHospitalId]) FROM ERS_OperatingHospitals"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim mycmd As New SqlCommand(querystr, connection)
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If Not IsDBNull(v) AndAlso Not IsNothing(v) Then
                value = CInt(v)
            Else
                value = -1
            End If
        End Using
        Return value
    End Function
    Public Function GetLoginPCDetails(RoomName As String, UserName As String) As DataTable
        Return GetData("SELECT * FROM [ERS_PCLog] WHERE [ClientPCName] = '" & RoomName & "' AND UserName = '" & UserName & "'")
    End Function
    Public Function SaveLoginPcDetail(RoomName As String, OperatingHospitalID As Integer, UserName As String) As Integer
        Dim sql As String = "IF NOT EXISTS(SELECT 1 FROM [ERS_PCLog] WHERE [ClientPCName]= @RoomName AND UserName=@UserName) INSERT INTO [ERS_PCLog](ClientPCName,OperatingHospitalID,UserName) VALUES (@RoomName,@OperatingHospitalID,@UserName)"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalID))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
    'Public Function LockPatientProcedures(ClientPCName As String, UserName As String, LockedPatientID As Integer) As Integer
    '    Dim sql As String = "IF EXISTS(SELECT 1 FROM ERS_PCLog WHERE [LockedPatientID] = @LockedPatientID) BEGIN UPDATE ERS_PCLog SET [LockedPatientID]= NULL, [LockedOn]=NULL WHERE [LockedPatientID] = @LockedPatientID END; UPDATE [ERS_PCLog] SET [LockedPatientID] = @LockedPatientID, [LockedOn] = @LockedOn WHERE ClientPCName = @ClientPCName AND UserName =@UserName"
    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand(sql.ToString(), connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@ClientPCName", ClientPCName))
    '        cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
    '        cmd.Parameters.Add(New SqlParameter("@LockedPatientID", LockedPatientID))
    '        cmd.Parameters.Add(New SqlParameter("@LockedOn", Date.Now))
    '        connection.Open()
    '        Return cmd.ExecuteNonQuery()
    '    End Using
    'End Function

    Public Function GetFirstERCP(ByVal procedureId As Integer) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("first_ercp", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            Return CStr(cmd.ExecuteScalar())
        End Using
        Return ""
    End Function

    Public Function isPatientProceduresLocked(UserName As String, LockedPatientID As Integer) As DataTable
        Dim rSet As New DataSet
        Dim sql As String = "IF EXISTS(SELECT 1 FROM ERS_PCLog WHERE [LockedPatientID] = @LockedPatientID AND UserName <> @UserName AND LockedOn >= GETDATE()-1) BEGIN SELECT '1' AS isLocked, 'This patient has been locked by '+ u.Username +' from '+ p.ClientPCName + ' on ' + cast(p.LockedOn as varchar(50)) AS LockedMessage FROM ERS_PCLog p INNER JOIN tvfUsersByOperatingHospital(@OperatingHospitalId) u ON p.UserName = u.UserName WHERE p.[LockedPatientID] = @LockedPatientID END ELSE SELECT 0 AS isLocked, '' AS LockedMessage"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@LockedPatientID", LockedPatientID))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(rSet)
        End Using
        If rSet.Tables.Count > 0 Then
            Return rSet.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    'Public Function UnlockPatientProcedures(ClientPCName As String, UserName As String) As Integer
    '    Dim sql As String = "UPDATE ERS_PCLog SET [LockedPatientID]= NULL, [LockedOn]=NULL WHERE ClientPCName = @ClientPCName AND UserName =@UserName"
    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand(sql.ToString(), connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@ClientPCName", ClientPCName))
    '        cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
    '        connection.Open()
    '        Return cmd.ExecuteNonQuery()
    '    End Using
    'End Function
    'end of PatientProcedures
    Public Function isUserLockedOut(RoomName As String, UserName As String) As DataTable
        Dim rSet As New DataSet
        Dim sql As String = "SELECT 'You have been locked out of this system from '  + [LogOutBy] as pcMessage, CASE ISNULL(LogOutBy,'') WHEN '' THEN 0 WHEN ClientPCName THEN 0 ELSE 1 END AS pcState FROM ERS_PCLog WHERE ClientPCName = @RoomName AND UserName= @UserName"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(rSet)
        End Using
        If rSet.Tables.Count > 0 Then
            Return rSet.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    Public Function isUserExist(RoomName As String, UserName As String) As Integer
        Dim sql As String = "IF EXISTS(SELECT 1 FROM ERS_PCLog WHERE UserName = @UserName AND ClientPCName <> @RoomName AND ([LogOutBy] <> @RoomName  OR [LogOutBy] IS NULL) ) SELECT 1 ELSE SELECT 0"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            connection.Open()
            Dim r As Object = cmd.ExecuteScalar
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CInt(r)
            Else
                Return 0
            End If
        End Using
    End Function
    Public Function isUserExistLogOutMessages(RoomName As String, UserName As String) As String
        Dim sql As String = "SELECT 'User account '+ ISNULL((SELECT u.Username  FROM tvfUsersByOperatingHospital(@OperatingHospitalId) u WHERE  u.UserName = p.UserName ),'""' + @UserName + '""') + ' is currently in use on ' + p.ClientPCName + '. Do you wish to logout the current user?'  FROM ERS_PCLog p WHERE p.UserName = @UserName AND p.ClientPCName <> @RoomName AND ([LogOutBy] <> @RoomName  OR [LogOutBy] IS NULL)"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId"))))
            connection.Open()
            Dim r As Object = cmd.ExecuteScalar
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CStr(r)
            Else
                Return Nothing
            End If
        End Using
    End Function

    Public Function setTransnasal(transnasal As Boolean)
        Dim sql As String = "UPDATE ERS_Procedures SET Transnasal = @Transnasal WHERE ProcedureId = @ProcedureId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))))
            cmd.Parameters.Add(New SqlParameter("@Transnasal", transnasal))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Friend Function GetPDFExportLocation(operatingHospitalId As Integer) As String
        Dim sql As String = "SELECT ISNULL(ReportExportPath,'') AS ReportExportPath FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using
    End Function

    Public Function clearExistingUser(RoomName As String, UserName As String) As Integer
        Dim sql As String = "UPDATE ERS_PCLog SET LogOutBy = @RoomName, LoggedOutOn = GetDate()  WHERE UserName= @UserName"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetGeneralLibrary(PhraseCategory As String, OperatingHospitalId As Integer) As DataTable
        Dim querystr As String = "SELECT Phrase, PhraseID FROM [ERS_PhraseLibrary]  WHERE UserID = 0 AND PhraseCategory = '" & PhraseCategory & "' AND OperatingHospitalId = " & OperatingHospitalId
        Return GetData(querystr)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPersonalLibrary(UserID As String, PhraseCategory As String, OperatingHospitalId As Integer) As DataTable
        Dim querystr As String = "SELECT p.Phrase, p.PhraseID FROM [ERS_PhraseLibrary] p LEFT JOIN [ERS_Users] u ON p.UserID = u.UserID WHERE u.Username = '" & UserID & "' AND p.PhraseCategory = '" & PhraseCategory & "' AND OperatingHospitalId = " & OperatingHospitalId
        Return GetData(querystr)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetStaff(role As Staff) As DataTable
        Dim sql As New StringBuilder

        sql.Append("SELECT UserId, ISNULL(Title, '') + ISNULL(' ' + Forename, '') + ' ' + Surname AS UserFullName FROM tvfUsersByOperatingHospital(@OperatingHospitalId) ")

        If role = Staff.ListConsultant Then
            sql.Append("WHERE [IsListConsultant] = 1 ")
        ElseIf role = Staff.EndoScopist1 Then
            sql.Append("WHERE [IsEndoscopist1] = 1 ")
        ElseIf role = Staff.EndoScopist2 Then
            sql.Append("WHERE [IsEndoscopist2] = 1 ")
        ElseIf role = Staff.Nurse1 Then
            sql.Append("WHERE [IsAssistantOrTrainee] = 1 ")
        ElseIf role = Staff.Nurse2 Then
            sql.Append("WHERE [IsNurse1] = 1 ")
        ElseIf role = Staff.Nurse3 Then
            sql.Append("WHERE [IsNurse2] = 1 ")
        ElseIf role = Staff.Nurse4 Then
            sql.Append("WHERE [IsNurse2] = 1 ")
        End If

        sql.Append("ORDER BY [Surname] ")

        'Return GetData(sql.ToString())
        Return ExecuteSQL(sql.ToString(), New SqlParameter() {New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId")))})

    End Function

    Public Function GetStaffEndo(ProcedureId As Integer) As DataTable
        Dim sqlStr As String ' = "SELECT p.[ListConsultant],(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[ListConsultant]) AS ListConsultantName,p.[Endoscopist1],(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Endoscopist1]) AS Endoscopist1Name , p.[Endoscopist2],(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Endoscopist2]) AS Endoscopist2Name, p.[Nurse1],(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse1]) AS Nurse1Name, p.[Nurse2],(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse2]) AS Nurse2Name, p.[Nurse3] ,(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse3]) AS Nurse3Name FROM ERS_Procedures p WHERE p.ProcedureId=@ProcedureID"
        sqlStr = "SELECT " &
                    "P.ListType, p.[ListConsultant]" &
                    ", (SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[ListConsultant]) AS ListConsultantName" &
                    ", (SELECT ISNULL(u.GMCCode, '') FROM ERS_Users u WHERE u.UserID = p.[ListConsultant]) AS ListConsultantGMCCode" &
                    ", p.[Endoscopist1], p.Endo1Role" &
                    ", (SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Endoscopist1]) AS Endoscopist1Name" &
                    ", (SELECT ISNULL(u.GMCCode, '') FROM ERS_Users u WHERE u.UserID = p.[Endoscopist1]) AS Endoscopist1GMCCode" &
                    ", p.[Endoscopist2], p.Endo2Role" &
                    ", (SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Endoscopist2]) AS Endoscopist2Name" &
                    ", (SELECT ISNULL(u.GMCCode, '') FROM ERS_Users u WHERE u.UserID = p.[Endoscopist2]) AS Endoscopist2GMCCode" &
                    ", ISNULL(p.[Nurse1],0) AS Nurse1,(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse1]) AS Nurse1Name" &
                    ", ISNULL(p.[Nurse2],0) AS Nurse2 ,(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse2]) AS Nurse2Name" &
                    ", ISNULL(p.[Nurse3],0) AS Nurse3 ,(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse3]) AS Nurse3Name " &
                    ", ISNULL(p.[Nurse4],0) AS Nurse4 ,(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse4]) AS Nurse4Name " &
                    "FROM ERS_Procedures p WHERE p.ProcedureId=@ProcedureId"
        Using da As New DataAccess
            Return DataAccess.ExecuteSQL(sqlStr, New SqlParameter() {New SqlParameter("@ProcedureId", ProcedureId)})
        End Using
    End Function

    Public Function GetRecordCountOfOtherData(ByVal procedureId As Integer) As DataTable
        Dim dsRecordCountOfOtherData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND SiteID IS NULL ", connection)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsRecordCountOfOtherData)
        End Using

        If dsRecordCountOfOtherData.Tables.Count > 0 Then
            Return dsRecordCountOfOtherData.Tables(0)
        End If
        Return Nothing
        'Using da As New DataAccess
        '    Return DataAccess.ExecuteSQL("SELECT * FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND SiteID IS NULL", New SqlParameter() {New SqlParameter("@ProcedureId", procedureId)})
        'End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRegionPathsEbusLymphNodes(height As Integer, width As Integer) As DataTable
        Dim dsRegions As New DataSet
        Dim query As New StringBuilder
        Dim constr = ConnectionStr

        query.Append("SELECT EBUSLymphNodeId, ")
        query.Append("convert(decimal(5,2), (XCoordinate * (convert(decimal(5,2),@Width)/500))) AS XCoordinate, ")
        query.Append("convert(decimal(5,2), (YCoordinate * (convert(decimal(5,2),@Height)/500))) AS YCoordinate ")
        query.Append("FROM ERS_EBUSLymphNodes ")

        Using connection As New SqlConnection(constr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.Parameters.Add(New SqlParameter("@height", height))
            cmd.Parameters.Add(New SqlParameter("@width", width))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsRegions)
        End Using

        If dsRegions.Tables.Count > 0 Then
            Return dsRegions.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetResectedColonRegions() As DataTable
        'Dim procedureTypeID As Integer = CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE))

        'If procedureTypeID <> ProcedureType.Colonoscopy And procedureTypeID <> ProcedureType.Sigmoidscopy Then Return Nothing

        Dim dsResectedColonRegions As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT rc.ResectedColonID, rc.ResectedColonText, rcr.RegionId, r.Region ")
        query.Append("FROM ERS_ResectedColonRegions rcr ")
        query.Append("JOIN ERS_ResectedColon rc ON rcr.ResectedColonID = rc.ResectedColonID ")
        query.Append("JOIN ERS_Regions r ON rcr.RegionId = r.RegionId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString(), connection)
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResectedColonRegions)
        End Using

        If dsResectedColonRegions.Tables.Count > 0 Then
            Return dsResectedColonRegions.Tables(0)
        End If
        Return Nothing
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetAppointments() As DataTable
    '    Return GetData("SELECT * FROM ERS_Appointments")
    'End Function

    Public Function GetCustomer(ByVal hospitalId As Integer) As DataTable
        Dim dsCustomer As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM [CRM_Customers] WHERE HospitalID = @HospitalID", connection)
            cmd.Parameters.Add(New SqlParameter("@HospitalID", hospitalId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsCustomer)
        End Using

        If dsCustomer.Tables.Count > 0 Then
            Return dsCustomer.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetEthnicOrigins(ByVal usedIn As EthnicOriginsUsedIn) As DataTable
        Dim dsEthnicOrigins As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_Ethnic_Groups", connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsEthnicOrigins)
        End Using

        If dsEthnicOrigins.Tables.Count > 0 Then
            Return dsEthnicOrigins.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function GetResectedColonDetails(ByVal ProcedureID As Integer, ByVal EpisodeNo As Integer, ByVal bIsRetrograde As Boolean) As String
        Dim RecColID As Object
        Dim sql As String = ""
        If ProcedureID = 0 Then
            Dim sTableName As String = IIf(bIsRetrograde, "[ENTER retro procedure]", "[Colon Procedure]")
            sql = "SELECT [Resected Colon No] AS  ResectedColonNo FROM " & sTableName & " WHERE [Episode No] = @EpisodeNo AND [Patient No] = @PatientNo"
        Else
            sql = "SELECT ResectedColonNo FROM ERS_Procedures WHERE ProcedureID = @ProcedureID"
        End If

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            cmd.Parameters.Add(New SqlParameter("@EpisodeNo", EpisodeNo))
            If HttpContext.Current.Session("PatientComboId") IsNot Nothing Then
                cmd.Parameters.Add(New SqlParameter("@PatientNo", HttpContext.Current.Session("PatientComboId")))
            Else
                cmd.Parameters.Add(New SqlParameter("@PatientNo", SqlTypes.SqlString.Null))
            End If
            connection.Open()
            RecColID = cmd.ExecuteScalar()
            If RecColID IsNot Nothing AndAlso IsDBNull(RecColID) = False Then
                Return CStr(RecColID)
            Else
                Return "0"
            End If
        End Using
        Return Nothing
    End Function

    Public Function GetResectedColonText(ResectedColonID As Integer) As String
        Dim ResectedColonTextValue As Object
        Dim sql As String = "SELECT ResectedColonText  FROM ERS_ResectedColon WHERE ResectedColonID = @ResectedColonID"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ResectedColonID", ResectedColonID))
            connection.Open()
            ResectedColonTextValue = cmd.ExecuteScalar()
            If ResectedColonTextValue IsNot Nothing AndAlso IsDBNull(ResectedColonTextValue) = False Then
                Return CStr(ResectedColonTextValue)
            Else
                Return ""
            End If
        End Using
        Return Nothing
    End Function

    Public Function UpdateResectedColon(ByVal ProcedureId As Integer, ByVal ResectedColonId As Integer) As Integer
        Dim sql As New StringBuilder
        sql.Append("UPDATE p ")
        sql.Append("SET ResectedColonNo = @ResectedColonId ")
        sql.Append("FROM ERS_Procedures p ")
        sql.Append("INNER JOIN ERS_ResectedColon rc ON rc.ResectedColonID = @ResectedColonId ")
        sql.Append("WHERE ProcedureID = @ProcedureID ")

        ' updates the report summary (esp the region in the site name)
        sql.Append("EXEC procedure_summary_update @ProcedureID ")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@ResectedColonId", ResectedColonId))
            cmd.Connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using

        '### Now Update the PP field- which is in [ERS_ProceduresReporting]=> Use EntityFrame Work!
        Using db As New ERS.Data.GastroDbEntities
            Dim pr As New ERS.Data.ERS_ProceduresReporting
            pr = db.ERS_ProceduresReporting.Find(ProcedureId)
            pr.PP_ResectedColon = ResectedColonId
            db.SaveChanges()
        End Using

    End Function

    Public Function GetEthnicOriginIdByName(ByVal ethnicOrigin As String) As Nullable(Of Integer)
        Dim sql As String = "SELECT EthnicOriginId FROM ERS_EthnicOrigins WHERE EthnicOrigin = @EthnicOrigin"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", ethnicOrigin.ToString()))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CInt(idObj)
            End If
        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetGPs() As DataTable
        Return GetData("SELECT CASE WHEN NationalCode = 'G9999998' THEN 'Not Stated' ELSE CompleteName END AS FullName, * FROM ERS_GPS")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetGP(ByVal GPId As String) As DataTable
        Return GetData("SELECT * FROM ERS_VW_GPS WHERE GPId = " & GPId)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function SearchGP(searchTerm As String, searchField As String)
        Dim sSQL = "SELECT * FROM ERS_VW_GPS WHERE "
        Select Case searchField.ToLower()
            Case "all"
                sSQL += "GPCode LIKE '%" & searchTerm & "%' OR "
                sSQL += "CompleteName LIKE '%" & searchTerm & "%' OR "
                sSQL += "Practice LIKE '%" & searchTerm & "%'"
            Case "gp name"
                sSQL += "CompleteName LIKE '%" & searchTerm & "%'"
            Case "national code"
                sSQL += "GPCode LIKE '%" & searchTerm & "%'"
            Case "practice name"
                sSQL += "Practice LIKE '%" & searchTerm & "%'"
        End Select

        Dim dt = ExecuteSQL(sSQL)
        Return If(dt, New DataTable)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRoles() As DataTable
        'If current user logged in is Unisoft, return all roles including "Unisoft"
        If String.Compare(HttpContext.Current.Session("UserID"), "Unisoft", True) = 0 Then
            Return GetData("SELECT RoleName, RoleId FROM ERS_Roles ORDER BY RoleId")
        Else
            'Do not return role "Unisoft"
            Return GetData("SELECT RoleName, RoleId FROM ERS_Roles WHERE RoleName <> 'Unisoft' ORDER BY RoleId")
        End If
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function CanViewAllUsers() As Boolean
        Try
            Dim userId = Integer.Parse(HttpContext.Current.Session("PKUserId"))

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("SELECT CASE WHEN COUNT(UserId) = 0 THEN 0 ELSE 1 END FROM ERS_Users WHERE (RoleId IN (SELECT convert(varchar(10), RoleId) FROM ERS_Roles WHERE RoleName='System Administrators') OR CanViewAllUserAudits = 1)  AND UserID = @UserID", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@UserID", userId))
                connection.Open()
                Dim returnValue = Integer.Parse(cmd.ExecuteScalar())
                Return returnValue = 1
            End Using
        Catch ex As Exception
            Return False
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPagesByRole(ByVal RoleId As Integer, GroupID As Integer) As DataTable

        Dim dsPagesByRole As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("common_pagebyrole_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            'cmd.Parameters.Add("@RoleId", SqlDbType.Int).Value = RoleId
            cmd.Parameters.Add(New SqlParameter("@RoleId", RoleId))
            cmd.Parameters.Add(New SqlParameter("@GroupID", GroupID))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPagesByRole)
        End Using

        If dsPagesByRole.Tables.Count > 0 Then
            Return dsPagesByRole.Tables(0)
        End If
        Return Nothing

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetMenuByCategory(ByVal MenuCategory As String) As DataTable

        Dim dsPagesByRole As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT [MapID],[ParentID],[NodeName],[MenuCategory],[MenuUrl],[isViewer],[isDemoVersion],ISNULL([PageID],-1) AS PageID,[MenuIcon],[MenuTooltip] FROM ERS_MenuMap WHERE MenuCategory=@MenuCategory", connection)
            'cmd.Parameters.Add("@RoleId", SqlDbType.Int).Value = RoleId
            cmd.Parameters.Add(New SqlParameter("@MenuCategory", MenuCategory))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsPagesByRole)
        End Using

        If dsPagesByRole.Tables.Count > 0 Then
            Return dsPagesByRole.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function GetAccessLevels(ByVal userId As Integer, ByVal pageNames As String()) As Dictionary(Of String, Integer)
        Try

            Using connection As New SqlConnection(ConnectionStr)

                Dim ds As New DataSet
                Dim sql As New StringBuilder
                If userId = -9999 Then 'UserId -9999 for Unisoft
                    sql.Append("SELECT MAX(ISNULL(AccessLevel,0)) as AccessLevel FROM ERS_PagesByRole pr ")
                    sql.Append("INNER JOIN ERS_Pages p ON p.PageId = pr.PageId AND AppPageName IN @PageName  ")
                    sql.Append("WHERE RoleID = (SELECT TOP 1 RoleId FROM ERS_Roles WHERE RoleName = 'Unisoft') ")
                Else
                    sql.Append("DECLARE @RoleID VARCHAR(70), @GroupId INT ")
                    sql.Append("SELECT @RoleID=RoleID FROM ERS_Users where UserID = @UserID ")
                    sql.Append("SELECT [item] INTO #tmpRole FROM dbo.fnSplitString(@RoleID,',') ")
                    sql.Append("SELECT MAX(ISNULL(AccessLevel,0)) as AccessLevel, AppPageName FROM ERS_PagesByRole pr ")
                    sql.Append("INNER JOIN  ERS_Users u ON pr.RoleId IN (SELECT [item] FROM #tmpRole) AND u.UserId = @UserId ")
                    sql.Append("INNER JOIN ERS_Pages p ON p.PageId = pr.PageId AND AppPageName IN (@PageName)  ")
                    sql.Append("Group By AppPageName ")
                End If

                Dim cmd As New SqlCommand(sql.ToString(), connection)
                cmd.Parameters.Add(New SqlParameter("@UserId", userId))
                cmd.Parameters.Add(New SqlParameter("@PageName", String.Join(",", pageNames)))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)

                If ds.Tables.Count > 0 Then
                    Dim dt = ds.Tables(0)

                    Dim dbRes = (From r As DataRow In dt.Rows
                                 Select New Dictionary(Of String, Integer) From {
                                     {r("AppPageName").ToString(), CInt(r("AccessLevel"))}})

                    Return dbRes
                End If
                'If Not IsDBNull(idObj) AndAlso Not IsNothing(idObj) Then
                '    Return CInt(idObj)
                'Else
                '    Return 0
                'End If

            End Using

        Catch ex As Exception

        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPageAccessLevel(ByVal userId As Integer, ByVal pageName As String) As Nullable(Of Integer)

        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)


            Dim sql As New StringBuilder
            If userId = -9999 Then 'UserId -9999 for Unisoft
                sql.Append("SELECT MAX(ISNULL(AccessLevel,0)) as AccessLevel FROM ERS_PagesByRole pr ")
                sql.Append("INNER JOIN ERS_Pages p ON p.PageId = pr.PageId AND AppPageName = @PageName  ")
                sql.Append("WHERE RoleID = (SELECT TOP 1 RoleId FROM ERS_Roles WHERE RoleName = 'Unisoft') ")
            Else
                sql.Append("DECLARE @RoleID VARCHAR(70), @GroupId INT ")
                sql.Append("SELECT @RoleID=RoleID FROM ERS_Users where UserID = @UserID ")
                sql.Append("SELECT [item] INTO #tmpRole FROM dbo.fnSplitString(@RoleID,',') ")
                sql.Append("SELECT @GroupId = GroupId FROM ERS_Pages WHERE AppPageName = @PageName ")
                sql.Append("IF @GroupId IN (5,6) SET @PageName = 'create_procedure' ")
                sql.Append("SELECT MAX(ISNULL(AccessLevel,0)) as AccessLevel FROM ERS_PagesByRole pr ")
                sql.Append("INNER JOIN  ERS_Users u ON pr.RoleId IN (SELECT [item] FROM #tmpRole) AND u.UserId = @UserId ")
                sql.Append("INNER JOIN ERS_Pages p ON p.PageId = pr.PageId AND AppPageName = @PageName  ")
                'sql.Append("DROP TABLE #tmpRole ")
            End If

            Dim cmd As New SqlCommand(sql.ToString(), connection)

            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@PageName", pageName))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If Not IsDBNull(idObj) AndAlso Not IsNothing(idObj) Then
                Return CInt(idObj)
            Else
                Return 0
            End If
        End Using
    End Function
    Public Function InsertPage(ByVal PageName As String, ByVal AppPageName As String) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("DECLARE @max int = (select max(pageID) FROM ERS_Pages);IF NOT EXISTS(SELECT 1 FROM ERS_Pages WHERE AppPageName = @AppPageName) INSERT INTO ERS_Pages (PageID,PageName,AppPageName) VALUES (@max+1,@PageName,@AppPageName)", connection)
            cmd.Parameters.Add(New SqlParameter("@AppPageName", AppPageName))
            cmd.Parameters.Add(New SqlParameter("@PageName", PageName))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using
    End Function

    Public Function InsertFeedback(ByVal Fullname As String, ByVal EmailAddress As String, FeedbackText As String) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("INSERT INTO ERS_Feedback (Fullname,EmailAddress,FeedbackText) VALUES (@Fullname,@EmailAddress,@FeedbackText)", connection)
            cmd.Parameters.Add(New SqlParameter("@Fullname", Fullname))
            cmd.Parameters.Add(New SqlParameter("@EmailAddress", EmailAddress))
            cmd.Parameters.Add(New SqlParameter("@FeedbackText", FeedbackText))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            Return cmd.ExecuteNonQuery
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveGP(ByVal GPId As Nullable(Of Integer),
                           ByVal Title As String,
                           ByVal Initials As String,
                           ByVal ForeName As String,
                           ByVal Surname As String,
                           ByVal PracticeName As String,
                           ByVal Address As String,
                           ByVal Telephone As String,
                           ByVal Suppressed As Boolean) As Integer

        Dim affectedGPId As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("gp_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            If GPId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GPId", GPId))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPId", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Title", Title))
            cmd.Parameters.Add(New SqlParameter("@Initials", Initials))
            cmd.Parameters.Add(New SqlParameter("@ForeName", ForeName))
            cmd.Parameters.Add(New SqlParameter("@Surname", Surname))
            cmd.Parameters.Add(New SqlParameter("@PracticeName", PracticeName))
            cmd.Parameters.Add(New SqlParameter("@Address", Address))
            cmd.Parameters.Add(New SqlParameter("@Telephone", Telephone))
            cmd.Parameters.Add(New SqlParameter("@Suppressed", Suppressed))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            affectedGPId = CInt(cmd.ExecuteScalar())
        End Using

        Return affectedGPId
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTherapeuticBandingPiles(ByVal siteId As Integer) As DataTable
        Return GetData("SELECT BandingPiles, BandingNum FROM ERS_UpperGITherapeutics WHERE SiteId=" & siteId)
    End Function

    Public Sub saveStentInsertionDetails(therapeuticId As Integer, stentInsertion As Boolean, SiteId As Integer, StentInsertionQty As Integer, InsertionDetails As List(Of StentInsertion))
        Dim sql As New StringBuilder
        sql.Append("DELETE FROM ERS_ERCPTherapeuticStentInsertions WHERE TherapeuticId IN (SELECT ee.id FROM dbo.ERS_ERCPTherapeutics ee WHERE ee.SiteId = @SiteId AND ee.StentInsertion=0)") 'clean up for related site only
        sql.Append("DELETE FROM ERS_ERCPTherapeuticStentInsertions WHERE TherapeuticId = @TherapeuticId; ") 'delete for this particular therapeutic id. If theres insertion details that need to be attached, will do it down below. This handles the SI checkbox previously being ticked and then being unticked

        If stentInsertion AndAlso (InsertionDetails IsNot Nothing AndAlso (InsertionDetails.Count > 0 And StentInsertionQty > 0)) Then
            sql.Append("INSERT INTO ERS_ERCPTherapeuticStentInsertions (TherapeuticId, StentInsertionType, StentInsertionLength, StentInsertionDiameter, StentInsertionDiameterUnits) VALUES ")

            For i = 0 To InsertionDetails.Count - 1 'only up to the qty of insertions stated.. incase user filled out a certain amount by the lowered the QTY without updating and saving
                With InsertionDetails(i)
                    sql.Append("(@TherapeuticId, " & .StentInsertionType & ", " & .StentInsertionLength & ", " & .StentInsertionDiameter & ", " & .StentInsertionDiameterUnits & "), ")
                End With
            Next
        End If

        Dim sqlCommand = TransactionSQL(sql.ToString().Remove(sql.ToString().Length - 2))


        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlCommand, connection)

            cmd.Parameters.Add(New SqlParameter("@TherapeuticId", therapeuticId))
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub
#End Region

#Region "Lists"

    Private Function GetList(ByVal listDescription As String, Optional bOrderByDesc As Boolean = False) As DataTable

        Try

            If Left(Trim(listDescription), 1) = "'" Then
                listDescription = listDescription.Replace("'", "")
            End If

            Return ExecuteSP("common_get_list_data", New SqlParameter() {New SqlParameter("@ListDescription", listDescription), New SqlParameter("@LoggedInUserId", LoggedInUserId)})
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while Getting list " + listDescription + ".", ex)
            Return Nothing
        End Try
    End Function

    Public Function GetList_Arr(ByVal listDescription As String) As DataTable
        Return GetList(listDescription)
    End Function

    Public Function GetDistinctList() As DataTable
        Dim sql As String = "SELECT * from ERS_Roles WHERE RoleName <> 'Unisoft'"
        Return GetData(sql)
    End Function

    Public Function GetDistinctListPage() As DataTable
        Dim sql As String = "SELECT 0 AS PageId, '*Default*' AS PageName UNION SELECT -1 AS PageId, '' AS PageName UNION SELECT PageId, PageName FROM ERS_Pages"
        Return GetData(sql)
    End Function
    Public Function GetDistinctCategory() As DataTable
        Dim sql As String = "SELECT DISTINCT (MenuCategory) FROM ERS_MenuMap"
        Return GetData(sql)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUniqueListDescription() As DataTable
        Return GetData("SELECT DISTINCT(ListDescription) AS ListDescription FROM ERS_Lists WHERE ReadOnly = 0")
        'Return GetData("SELECT DISTINCT(ListDescription) AS ListDescription FROM ERS_Lists WHERE ISNULL(Suppressed,0) = 0")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetFieldUniqueFormName() As DataTable
        Return GetData("SELECT DISTINCT p.PageAlias AS FormName, p.PageId FROM ERS_FieldLabels f INNER JOIN ERS_Pages p ON f.PageID = p.PageId ORDER BY FormName")
    End Function

    Public Function GetCountryLabel(ByVal label As String) As String
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("country_label_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@label", label))
            connection.Open()
            Return CStr(cmd.ExecuteScalar())
        End Using
        Return ""
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertListItem(ByVal listDescription As String, ByVal itemName As String) As Integer

        If Trim(itemName) = "" Then Return 0


        Using connection As New SqlConnection(ConnectionStr)
            Dim value As Object
            Dim cmd As New SqlCommand("add_new_list_item", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@listDescription", listDescription))
            cmd.Parameters.Add(New SqlParameter("@itemName", itemName))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            value = cmd.ExecuteScalar()
            If Not IsDBNull(value) Then Return CInt(value)
            Return 0
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateItemList(ByVal ListId As Integer, ByVal ListItemText As String) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                db.ERS_List_UpdateValue(ListId, Nothing, ListItemText, False, LoggedInUserId)
            End Using
            Return 1
        Catch ex As Exception
            Return 0
        End Try

        'Dim sql As New StringBuilder

        'sql.Append("UPDATE ERS_Lists ")
        'sql.Append("SET ListItemText=@ListItemText ")
        'sql.Append("WHERE ListId=@ListId")

        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand(sql.ToString(), connection)
        '    cmd.CommandType = CommandType.Text
        '    cmd.Parameters.Add(New SqlParameter("@ListId", ListId))
        '    cmd.Parameters.Add(New SqlParameter("@ListItemText", ListItemText))

        '    connection.Open()
        '    Return cmd.ExecuteNonQuery()
        'End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SuppressItemList(ByVal ListId As Integer, ByVal SuppressItem As Boolean) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = db.ERS_List_UpdateValue(ListId, vbNullString, vbNullString, SuppressItem, LoggedInUserId)
            End Using
            Return 1
        Catch ex As Exception
            Return 0
        End Try

        'Dim sql As New StringBuilder

        'sql.Append("UPDATE ERS_Lists ")
        'sql.Append("SET Suppressed=@SuppressItem ")
        'sql.Append("WHERE ListId=@ListId")

        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand(sql.ToString(), connection)
        '    cmd.CommandType = CommandType.Text
        '    cmd.Parameters.Add(New SqlParameter("@ListId", ListId))
        '    cmd.Parameters.Add(New SqlParameter("@SuppressItem", SuppressItem))
        '    connection.Open()
        '    Return cmd.ExecuteNonQuery()
        'End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetJobTitles() As DataTable
        Dim dsJobTitles As New DataSet
        Dim sql As String = "SELECT * FROM ERS_JobTitles ORDER BY Description "

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsJobTitles)
        End Using

        If dsJobTitles.Tables.Count > 0 Then
            Return dsJobTitles.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertJobTitle(ByVal title As String) As Integer
        Dim sql As New StringBuilder
        sql.Append("INSERT INTO ERS_JobTitles ([Description], [WhoCreatedId], [WhenCreated]) ")
        sql.Append("VALUES (@Title, @LoggedInUserId, GETDATE()) ")
        sql.Append("SELECT @@IDENTITY ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@Title", title))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertRole(ByVal RoleName As String) As Integer
        Dim sql As New StringBuilder
        sql.Append("INSERT INTO ERS_Roles ([RoleName], WhoCreatedId, WhenCreated) ")
        sql.Append("VALUES (@RoleName, @LoggedInUserId, GETDATE()) ")
        sql.Append("SELECT @@IDENTITY ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoleName", RoleName))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateRoles(ByVal roleId As Integer,
                                         ByVal roleName As String) As Integer
        Dim sql As String = "UPDATE ERS_Roles SET RoleName=@Rolename, WhoUpdatedId=@LoggedInUserId, WhenUpdated=GETDATE() WHERE RoleId=@RoleId"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoleId", roleId))
            cmd.Parameters.Add(New SqlParameter("@Rolename", roleName))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Delete, False)>
    Public Function DeleteRole(ByVal roleId As Integer) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("DELETE FROM ERS_Roles WHERE roleId = @RoleId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoleId", roleId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertPagesByRole(ByVal sCommand As String) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sCommand, connection)
            cmd.CommandType = CommandType.Text
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Sub InsertPagesByRole(roleId As String, roleAccessLevels As Dictionary(Of Integer, String), Optional updateAll As Boolean = False)

        Using db As New ERS.Data.GastroDbEntities
            Dim pageIDs = roleAccessLevels.Select(Function(x) x.Key).ToList
            Dim roleList = db.ERS_PagesByRole.Where(Function(x) pageIDs.Contains(x.PageId) And x.RoleId = roleId)
            If Not updateAll And roleList.Count > 0 Then
                For Each role In roleList
                    If Not role.AccessLevel = roleAccessLevels(role.PageId) Then
                        role.AccessLevel = roleAccessLevels(role.PageId)
                        role.WhoUpdatedId = LoggedInUserId
                        role.WhenUpdated = Now
                        db.ERS_PagesByRole.Attach(role)
                        db.Entry(role).State = Entity.EntityState.Modified
                    End If
                Next
            Else
                For Each pageId In roleAccessLevels.Keys
                    Dim role = db.ERS_PagesByRole.Where(Function(x) x.PageId = pageId And x.RoleId = roleId).FirstOrDefault
                    If role Is Nothing Then role = New ERS_PagesByRole

                    role.PageId = pageId
                    role.RoleId = roleId
                    role.AccessLevel = roleAccessLevels(pageId)

                    If role.PagesByRoleId = 0 Then
                        role.WhoCreatedId = LoggedInUserId
                        role.WhenCreated = Now
                        db.ERS_PagesByRole.Add(role)
                    Else
                        role.WhoUpdatedId = LoggedInUserId
                        role.WhenUpdated = Now
                        db.ERS_PagesByRole.Attach(role)
                        db.Entry(role).State = Entity.EntityState.Modified
                    End If
                Next
            End If

            db.SaveChanges()
        End Using
    End Sub
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedureTypes(ByVal productType As Integer) As DataTable
        Dim dsProcedureTpes As New DataSet
        Dim sql As String = "SELECT *, CASE WHEN Suppressed = 1 THEN 0 ELSE 1 END AS Enabled FROM ERS_ProcedureTypes WHERE ProductTypeId = @ProductTypeId AND Suppressed = 0"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProductTypeId", productType))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsProcedureTpes)
        End Using

        If dsProcedureTpes.Tables.Count > 0 Then
            Return dsProcedureTpes.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetNonGIProcedures() As DataTable
        Dim dsProcedureTpes As New DataSet
        Dim sql As String = "SELECT *, CASE WHEN Suppressed = 1 THEN 0 ELSE 1 END AS Enabled FROM ERS_ProcedureTypes WHERE IsGI = 0 AND Suppressed = 0"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsProcedureTpes)
        End Using

        If dsProcedureTpes.Tables.Count > 0 Then
            Return dsProcedureTpes.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRegionsForProcedureType(procedureTypeId As String) As DataTable
        Return ExecuteSP("regions_select", New SqlParameter() {New SqlParameter("@procedureTypeId", procedureTypeId)})
    End Function

    Public Function GetAbnormalitiesForProcedure(siteId As Integer) As DataTable
        Return ExecuteSP("SelectAbnormalitiesForSite", New SqlParameter() {New SqlParameter("@SiteId", siteId)})
    End Function

    Friend Sub SaveOtherAbnormalitySettings(otherAbnormalityId As String, abnormality As String, summary As String, diagnosis As String, procedureTypeId As Integer, regions As String, active As Boolean)
        DataAccess.ExecuteScalerSQL("OtherAbnormalities_insert", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@OtherId", otherAbnormalityId),
                                        New SqlParameter("@Abnormality", abnormality),
                                        New SqlParameter("@Summary", summary),
                                        New SqlParameter("@Diagnoses", diagnosis),
                                        New SqlParameter("@ProcedureTypeId", procedureTypeId),
                                        New SqlParameter("@RegionsString", regions),
                                        New SqlParameter("@Active", active)})
    End Sub

    Friend Sub SaveOtherAbnormality(siteId As Integer, abnormalityList As String)
        DataAccess.ExecuteScalerSQL("abnormalities_other_save", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@SiteId", siteId),
                                        New SqlParameter("@AbnormalityList", abnormalityList)})
    End Sub

    Friend Function GetRegionsForOtherAbnormalities(OtherAbnormalityid As Integer) As DataTable
        Return ExecuteSP("OtherAbnormalityRegions_select", New SqlParameter() {New SqlParameter("@otherAbnormalityId", OtherAbnormalityid)})
    End Function


    Public Function GetOtherAbnormalities(OtherAbnormalityid As String) As DataTable
        Return ExecuteSP("OtherAbnormality_select", New SqlParameter() {New SqlParameter("@otherAbnormalityId", OtherAbnormalityid)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientWards() As DataTable
        Return GetList("Ward")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientStatuses() As DataTable
        Return GetList("Patient Status")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetBowelPreparationQuality() As DataTable
        Return GetList("Bowel_Preparation_Quality")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientTypes() As DataTable
        Return GetList("Patient Type")
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetProcedureCategories() As DataTable
    '    Return GetList("Procedure Category", False)
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetListType() As DataTable
    '    Return GetList("List Type", False)
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetEndoscopist1Role() As DataTable
    '    Return GetList("Endoscopist1 Role", False)
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetEndoscopist2Role() As DataTable
    '    Return GetList("Endoscopist2 Role", False)
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetForcepSerialNos() As DataTable
    '    Return GetList("Forcep Serial Numbers")
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSurgicalProcedures() As DataTable
        Return GetList("Surgical Procedures")
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetSurgeryFollowUpProc() As DataTable
    '    Return GetList("Surgery follow up proc Upper GI")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetDamagingDrugs() As DataTable
    '    Return GetList("Indications_Potential_Damaging_Drugs")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetRectal() As DataTable
    '    Return GetList("Indications Colon Rectal Bleeding")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function ERCPFollowPrev() As DataTable
    '    Return GetList("Follow up disease/proc ERCP")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetAlteredBowel() As DataTable
    '    Return GetList("Indications Colon Altered Bowel Habit")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetBowelFormation() As DataTable
    '    Return GetList("Bowel_Preparation")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInsertionComfirmedBy() As DataTable
    '    Return GetList("Colon_Extent_Insertion_Comfirmed_By")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInsertionLimitedBy() As DataTable
    '    Return GetList("Colon_Extent_Insertion_Limited_By")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetDifficultyEncountered() As DataTable
    '    Return GetList("Colon_Extent_Difficulty_Encountered")
    'End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDropDownList(FieldName As String) As DataTable
        Return GetList(FieldName)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiseaseFollowUpProc(ByVal procedureTypeId As Integer) As String
        If procedureTypeId = ProcedureType.Gastroscopy Then
            Return "Follow up disease/proc Upper GI"
        ElseIf procedureTypeId = ProcedureType.ERCP Then
            Return "Follow up disease/proc ERCP"
        ElseIf procedureTypeId = ProcedureType.Colonoscopy Then
            Return "Follow up disease/proc Colon"
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetFutherProcedures(ByVal procedureTypeId As Integer) As String
        If procedureTypeId = ProcedureType.Gastroscopy Then
            Return "Further procedure"
        ElseIf procedureTypeId = ProcedureType.ERCP Then
            Return "Further ERCP procedure"
        ElseIf procedureTypeId = ProcedureType.Bronchoscopy Or procedureTypeId = ProcedureType.EBUS Or procedureTypeId = ProcedureType.Thoracoscopy Then
            Return "Further Broncho procedure"
        Else
            Return "Further procedure"
        End If
        Return Nothing
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetFutherProcedurePeriods() As DataTable
    '    Return GetList("Further procedure period")
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetFollowupReferredTo(procedureTypeId As Integer) As String
        If procedureTypeId = ProcedureType.Bronchoscopy Or procedureTypeId = ProcedureType.EBUS Or procedureTypeId = ProcedureType.Thoracoscopy Then
            Return "Broncho Return or referred to"
        End If
        Return "Return or referred to"
    End Function
    Public Function GetConsultantList() As DataTable
        Dim ds As New DataAccess
        Return ds.GetConsultantsLst(Nothing, Nothing, 0)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetReviewLocations(procedureTypeId As Integer) As String
        If procedureTypeId = ProcedureType.Bronchoscopy Or procedureTypeId = ProcedureType.EBUS Or procedureTypeId = ProcedureType.Thoracoscopy Then
            Return "Review Broncho"
        End If
        Return "Review"
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetReviewPeriods() As DataTable
    '    Return GetList("Review period")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetPatientNotCopiedReason() As DataTable
    '    Return GetList("PatientNotCopiedReason")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInjectionTypes() As DataTable
    '    Return GetList("Agent Upper GI")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStentInsertionTypes() As DataTable
    '    Return GetList("Therapeutic Stent Insertion Types")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStentInsertionStomachTypes() As DataTable
    '    Return GetList("Therapeutic Stomach Stent Insertion Types")
    'End Function


    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInsertionUnits() As DataTable
    '    Return GetList("Gastrostomy PEG units")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInsertionTypes() As DataTable
    '    Return GetList("Gastrostomy PEG type")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStentInsertionDiaUnits() As DataTable
    '    Return GetList("Oesophageal dilatation units")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStentRemovalTechnique() As DataTable
    '    Return GetList("Therapeutic Stent Removal Technique")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetEMRFluid() As DataTable
    '    Return GetList("Therapeutic EMR Fluid")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetMarkingType() As DataTable
    '    Return GetList("Abno marking")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetOesophagealDilator() As DataTable
    '    Return GetList("Oesophageal dilator")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStoneRemovalUsing() As DataTable
    '    Return GetList("ERCP stone removal method")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetCystPunctureDevice() As DataTable
    '    Return GetList("Cyst Puncture device")
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDeliveryMethods() As DataTable
        Return GetList("Premedication Delivery Method")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetMarkingTypes() As DataTable
        Return GetList("Abno marking")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetMedicationFrequency() As DataTable
        Return GetList("Medication_Frequency")
    End Function

    Public Function rGetUsername(ByVal ProcedureID As String) As String
        Dim value As Object
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT isnull(pt.Surname,'') + ', '+ isnull(pt.Forename1,'') as Name FROM ERS_VW_Patients pt INNER JOIN ERS_Procedures p ON pt.[PatientId]=p.PatientId WHERE p.ProcedureId=@ProcedureId"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            value = mycmd.ExecuteScalar()
            If Not IsDBNull(value) Then Return CStr(value)
        End Using
        Return Nothing
    End Function
    Public Function rGetReferralConsultantNo(ByVal ProcedureID As String) As String
        Dim value As Object
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT ReferralConsultantNo FROM ERS_Procedures  WHERE ProcedureId=@ProcedureId"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            value = mycmd.ExecuteScalar()
            If Not IsDBNull(value) Then Return CStr(value)
        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetInstruments(ByVal procedureTypeId As Integer) As String
        Select Case procedureTypeId
            Case ProcedureType.Gastroscopy
                Return "Instrument Upper GI"
            Case ProcedureType.EUS_OGD, ProcedureType.EUS_HPB
                Return "Instrument EUS"
            Case ProcedureType.ERCP
                Return "Instrument ERCP"
            Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy, ProcedureType.Proctoscopy
                Return "Instrument ColonSig"
            Case ProcedureType.Antegrade
                Return "Instrument Antegrade"
            Case ProcedureType.Retrograde
                Return "Instrument Retrograde"
            Case ProcedureType.Bronchoscopy, ProcedureType.EBUS, ProcedureType.Thoracoscopy
                Return "Instrument Thoracic"
            Case Else
                Return Nothing
        End Select
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedureInstruments(ByVal procedureId As Integer) As DataTable
        Dim sql As String = "SELECT ISNULL(Instrument1,0) AS Instrument1, ISNULL(Instrument2,0) AS Instrument2, ISNULL(ScopeGuide,0) AS ScopeGuide, " &
                            "ISNULL(PancreasDivisum,0) AS PancreasDivisum, ISNULL(BiliaryManometry,0) AS BiliaryManometry, ISNULL(PancreaticManometry,0) AS PancreaticManometry " &
                            "FROM ERS_Procedures " &
                            "WHERE ProcedureId = '" & procedureId & "' "
        Return GetData(sql)
        '### TO DO: Return Procedure object-> using StoredProc!
    End Function
#End Region

#Region "Users"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUser(ByVal userId As Integer) As DataTable
        Dim dsUser As New DataSet
        Dim sql As New StringBuilder
        sql.Append("SELECT u.*, jt.Description AS JobTitle, ")
        sql.Append(" CASE AccessRights WHEN 1 THEN 'Read Only' WHEN 2 THEN 'Regular' WHEN 3 THEN 'Administrator' ELSE '' END AS Permissions ")
        sql.Append("FROM ERS_Users u ")
        sql.Append("LEFT JOIN ERS_JobTitles jt ON u.JobTitleID = jt.JobTitleID ")
        sql.Append("WHERE UserId = @UserId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsUser)
        End Using

        If dsUser.Tables.Count > 0 Then
            Return dsUser.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUserByUserName(ByVal userName As String) As DataTable
        Try
            Dim dsUser As New DataSet
            Dim sql As String = "SELECT * FROM ERS_Users eu INNER JOIN dbo.ERS_UserOperatingHospitals euoh ON eu.UserID = euoh.UserId WHERE eu.UserName = @UserName AND euoh.OperatingHospitalId = @OperatingHospitalId"

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@UserName", userName))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", Session("OperatingHospitalID")))

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsUser)
            End Using

            If dsUser.Tables.Count > 0 Then
                Return dsUser.Tables(0)
            End If

            Return Nothing

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetUserByUserName: " + ex.ToString(), ex)
            Return Nothing
        End Try

    End Function

    Public Function GetNonGIConsultants() As DataTable
        Try
            Dim dsResult As New DataSet

            Dim sSQL = "SELECT eu.UserID, eu.Title, eu.Forename, eu.Surname, ISNULL(eu.Title, '') + ' ' + eu.Forename + ' ' + eu.Surname as Consultant, eu.Suppressed, eu.GMCCode, ejt.Description as JobTitle, ISNULL(eu.JobTitleId,0) AS JobTitleId
                        FROM dbo.ERS_Users eu
	                        LEFT JOIN dbo.ERS_JobTitles ejt ON eu.JobTitleID = ejt.JobTitleID
                        WHERE ISNULL(eu.IsGIConsultant, 1) = 0"

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
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetNonGIConsultant(userId As Integer) As DataTable
        Try
            Dim dsResult As New DataSet

            Dim sSQL = "SELECT eu.UserID, eu.Title, eu.Forename, eu.Surname, ISNULL(eu.Title, '') + ' ' + eu.Forename + ' ' + eu.Surname as Consultant, eu.Suppressed, eu.GMCCode, ejt.Description as JobTitle, eu.JobTitleId
                        FROM dbo.ERS_Users eu
	                        LEFT JOIN dbo.ERS_JobTitles ejt ON eu.JobTitleID = ejt.JobTitleID
                        WHERE UserId=@UserId"

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sSQL, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@UserId", userId))
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

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertUser(ByVal username As String,
                               ByVal expiresOn As Date,
                               ByVal title As String,
                               ByVal forename As String,
                               ByVal surname As String,
                               ByVal initials As String,
                               ByVal qualifications As String,
                               ByVal isGIConsultant As Boolean,
                               ByVal jobTitleId As Integer,
                               ByVal RoleID As String,
                               ByVal canRunAK As Boolean,
                               ByVal isListConsultant As Boolean,
                               ByVal isEndoscopist1 As Boolean,
                               ByVal isEndoscopist2 As Boolean,
                               ByVal isAssistantOrTrainee As Boolean,
                               ByVal isNurse1 As Boolean,
                               ByVal isNurse2 As Boolean,
                               ByVal suppressed As Boolean,
                               ByVal showTooltips As Boolean,
                               ByVal gmcCode As String,
                               ByVal canEditDropdowns As Boolean,
                               ByVal CanViewAllUserAudits As Boolean,
                               ByRef userId As Integer) As Integer
        Try

            Dim sCloneUsername As String = username 'Use different variable for GetPasswordASC as the function is uppercasing username (byref) 
            Dim dsUser As New DataSet
            Dim sql As String = "INSERT INTO ERS_Users (RecordCreated, LastUpdated, ExpiresOn, Username, [Password], PasswordExpiresOn, Title, Forename, Surname, Initials, Qualifications, IsGIConsultant, JobTitleId, RoleID, CanRunAK, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2, ResetPassword, Suppressed, ShowTooltips, GMCCode, CanEditDropdowns, CanViewAllUserAudits, WhoCreatedId, WhenCreated) " &
                            "VALUES (GETDATE(), GETDATE(), @ExpiresOn, @Username, " & Utilities.GetPasswordASC(sCloneUsername) & ", GETDATE(), @Title, @Forename, @Surname, @Initials, @Qualifications, @IsGI, @JobTitleId, @RoleID, @CanRunAK, @IsListConsultant, @IsEndoscopist1, @IsEndoscopist2, @IsAssistantOrTrainee, @IsNurse1, @IsNurse2, 1, @Suppressed, @ShowTooltips, @GMCCode, @CanEditDropdowns, @CanViewAllUserAudits, @LoggedInUserId, GETDATE()) " &
                            "SELECT SCOPE_IDENTITY() "

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@Username", username))
                If Year(expiresOn) < 5 Then
                    cmd.Parameters.Add(New SqlParameter("@ExpiresOn", "01/01/3999"))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ExpiresOn", expiresOn))
                End If
                cmd.Parameters.Add(New SqlParameter("@Title", title))
                cmd.Parameters.Add(New SqlParameter("@Forename", forename))
                cmd.Parameters.Add(New SqlParameter("@Surname", surname))
                If initials IsNot Nothing Then
                    cmd.Parameters.Add(New SqlParameter("@Initials", initials))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Initials", SqlTypes.SqlString.Null))
                End If
                If qualifications IsNot Nothing Then
                    cmd.Parameters.Add(New SqlParameter("@Qualifications", qualifications))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Qualifications", SqlTypes.SqlString.Null))
                End If

                cmd.Parameters.Add(New SqlParameter("@IsGI", isGIConsultant))
                cmd.Parameters.Add(New SqlParameter("@JobTitleId", jobTitleId))
                cmd.Parameters.Add(New SqlParameter("@RoleID", RoleID))
                cmd.Parameters.Add(New SqlParameter("@CanRunAK", canRunAK))
                cmd.Parameters.Add(New SqlParameter("@IsListConsultant", isListConsultant))
                cmd.Parameters.Add(New SqlParameter("@IsEndoscopist1", isEndoscopist1))
                cmd.Parameters.Add(New SqlParameter("@IsEndoscopist2", isEndoscopist2))
                cmd.Parameters.Add(New SqlParameter("@IsAssistantOrTrainee", isAssistantOrTrainee))
                cmd.Parameters.Add(New SqlParameter("@IsNurse1", isNurse1))
                cmd.Parameters.Add(New SqlParameter("@IsNurse2", isNurse2))
                cmd.Parameters.Add(New SqlParameter("@Suppressed", suppressed))
                cmd.Parameters.Add(New SqlParameter("@ShowTooltips", showTooltips))
                cmd.Parameters.Add(New SqlParameter("@GMCCode", gmcCode))
                cmd.Parameters.Add(New SqlParameter("@CanEditDropdowns", canEditDropdowns))
                cmd.Parameters.Add(New SqlParameter("@CanViewAllUserAudits", CanViewAllUserAudits))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                HttpContext.Current.Session("ShowToolTips") = showTooltips
                connection.Open()
                Return CInt(cmd.ExecuteScalar())
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error adding user", ex)
        End Try


        Return 0

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateUser(ByVal userId As Integer,
                               ByVal expiresOn As Date,
                               ByVal username As String,
                               ByVal title As String,
                               ByVal forename As String,
                               ByVal surname As String,
                               ByVal initials As String,
                               ByVal qualifications As String,
                               ByVal isGIConsultant As Boolean,
                               ByVal jobTitleId As Integer,
                               ByVal RoleID As String,
                               ByVal canRunAK As Boolean,
                               ByVal isListConsultant As Boolean,
                               ByVal isEndoscopist1 As Boolean,
                               ByVal isEndoscopist2 As Boolean,
                               ByVal isAssistantOrTrainee As Boolean,
                               ByVal isNurse1 As Boolean,
                               ByVal isNurse2 As Boolean,
                               ByVal suppressed As Boolean,
                               ByVal showTooltips As Boolean,
                               ByVal gmcCode As String,
                               ByVal canEditDropdowns As Boolean,
                               ByVal CanViewAllUserAudits As Boolean) As Integer

        Dim dsUser As New DataSet
        Dim sql As New StringBuilder

        sql.Append("UPDATE ERS_Users ")
        sql.Append("SET Username=@Username, ")
        sql.Append("    LastUpdated=getdate(), ")
        sql.Append("    Title=@Title, Forename=@Forename, Surname=@Surname, ")
        sql.Append("    Qualifications = @Qualifications, ")
        sql.Append("    IsGIConsultant = @IsGI, ")
        sql.Append("    JobTitleID = @JobTitleId, ")
        sql.Append("    RoleID=@RoleID, ")
        sql.Append("    CanRunAK=@CanRunAK,")
        sql.Append("    CanViewAllUserAudits=@CanViewAllUserAudits,")
        sql.Append("    IsListConsultant=@IsListConsultant, IsEndoscopist1=@IsEndoscopist1, IsEndoscopist2=@IsEndoscopist2, ")
        sql.Append("    IsAssistantOrTrainee=@IsAssistantOrTrainee, IsNurse1=@IsNurse1, IsNurse2=@IsNurse2, ")
        sql.Append("     Suppressed=@Suppressed, ExpiresOn=@ExpiresOn, ShowTooltips=@ShowTooltips, GMCCode=@GMCCode, CanEditDropdowns = @CanEditDropdowns, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() ")
        sql.Append("WHERE UserId=@UserId")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            If expiresOn.ToString = "01/01/0001 00:00:00" Then
                expiresOn = DateTime.Now
            End If
            cmd.Parameters.Add(New SqlParameter("@ExpiresOn", expiresOn))
            cmd.Parameters.Add(New SqlParameter("@Username", username))
            cmd.Parameters.Add(New SqlParameter("@Title", title))
            cmd.Parameters.Add(New SqlParameter("@Forename", forename))
            cmd.Parameters.Add(New SqlParameter("@Surname", surname))
            If initials IsNot Nothing Then
                cmd.Parameters.Add(New SqlParameter("@Initials", initials))
            Else
                cmd.Parameters.Add(New SqlParameter("@Initials", SqlTypes.SqlString.Null))
            End If
            If qualifications IsNot Nothing Then
                cmd.Parameters.Add(New SqlParameter("@Qualifications", qualifications))
            Else
                cmd.Parameters.Add(New SqlParameter("@Qualifications", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@IsGI", isGIConsultant))
            cmd.Parameters.Add(New SqlParameter("@JobTitleId", jobTitleId))
            cmd.Parameters.Add(New SqlParameter("@RoleID", RoleID))
            cmd.Parameters.Add(New SqlParameter("@CanRunAK", canRunAK))
            cmd.Parameters.Add(New SqlParameter("@IsListConsultant", isListConsultant))
            cmd.Parameters.Add(New SqlParameter("@IsEndoscopist1", isEndoscopist1))
            cmd.Parameters.Add(New SqlParameter("@IsEndoscopist2", isEndoscopist2))
            cmd.Parameters.Add(New SqlParameter("@IsAssistantOrTrainee", isAssistantOrTrainee))
            cmd.Parameters.Add(New SqlParameter("@IsNurse1", isNurse1))
            cmd.Parameters.Add(New SqlParameter("@IsNurse2", isNurse2))
            cmd.Parameters.Add(New SqlParameter("@Suppressed", suppressed))
            cmd.Parameters.Add(New SqlParameter("@ShowTooltips", showTooltips))
            cmd.Parameters.Add(New SqlParameter("@GMCCode", gmcCode))
            cmd.Parameters.Add(New SqlParameter("@CanEditDropdowns", canEditDropdowns))
            cmd.Parameters.Add(New SqlParameter("@CanViewAllUserAudits", CanViewAllUserAudits))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            connection.Open()
            HttpContext.Current.Session("ShowToolTips") = showTooltips

            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateUserLogin(ByVal userId As Integer,
                                    ByVal loggedOn As Boolean,
                                    ByVal hostName As String,
                                    ByVal hostFullName As String) As Integer

        Dim sql As New StringBuilder
        Dim operatingHospitalId As Integer = CInt(HttpContext.Current.Session("OperatingHospitalID"))
        sql.Append("UPDATE ERS_Users ")
        sql.Append("SET LoggedOn = @LoggedOn, LastOperatingHospital = @OperatingHospitalId, LastLoggedIn = GETDATE() ")
        sql.Append("WHERE UserId = @UserId ")

        sql.Append("DELETE FROM ERS_UserLogins WHERE UserId = @UserId ")
        sql.Append("INSERT INTO ERS_UserLogins (UserID, HostName, HostFullName, LoggedInAt, LastActiveAt) ")
        sql.Append("VALUES (@UserId, @HostName, @HostFullName, GETDATE(), GETDATE()) ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@LoggedOn", loggedOn))
            cmd.Parameters.Add(New SqlParameter("@HostName", IIf(hostName Is Nothing, hostFullName, hostName))) 'use hostFullName when hostname is returned as nothing
            cmd.Parameters.Add(New SqlParameter("@HostFullName", hostFullName))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateUser(ByVal userId As Integer,
                               ByVal suppressed As Boolean) As Integer

        Dim dsUser As New DataSet
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_Users ")
        sql.Append("SET suppressed = @Suppressed ")
        sql.Append(",WhoUpdatedId = @LoggedInUserId ")
        sql.Append(",WhenUpdated = GETDATE() ")
        sql.Append("WHERE UserId = @UserId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@Suppressed", suppressed))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateUserResetPassword(ByVal userId As Integer,
                                            ByVal password As String,
                                            ByVal passwordExpiresOn As Date,
                                            ByVal resetPassword As Boolean) As Integer

        Dim dsUser As New DataSet
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_Users ")
        sql.Append("SET password = @Password, ")
        sql.Append("LastUpdated = GETDATE(), ")
        sql.Append("PasswordExpiresOn = @PasswordExpiresOn, ")
        sql.Append("ResetPassword = @ResetPassword, ")
        sql.Append("WhoUpdatedId = @LoggedInUserId, ")
        sql.Append("WhenUpdated = GetDate() ")
        sql.Append("WHERE UserId = @UserId ")

        sql.Append("INSERT INTO ERS_UserPasswords (UserID, Password, CreatedOn, WhoCreatedId, WhenCreated) ")
        sql.Append("VALUES (@UserId, @Password, GETDATE(), @LoggedInUserId, GETDATE()) ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@Password", Utilities.GetPasswordASC(password)))
            cmd.Parameters.Add(New SqlParameter("@PasswordExpiresOn", passwordExpiresOn))
            cmd.Parameters.Add(New SqlParameter("@ResetPassword", resetPassword))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function ResetUserPassword(ByVal userId As Integer,
                                            ByVal password As String,
                                            ByVal resetPassword As Boolean) As Integer

        Dim dsUser As New DataSet
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_Users ")
        sql.Append("SET password = @Password, ")
        sql.Append("LastUpdated = GETDATE(), ")
        sql.Append("ResetPassword = @ResetPassword, ")
        sql.Append("WhoUpdatedId = @LoggedInUserId, ")
        sql.Append("WhenUpdated = GetDate() ")
        sql.Append("WHERE UserId = @UserId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@Password", Utilities.GetPasswordASC(password)))
            cmd.Parameters.Add(New SqlParameter("@ResetPassword", resetPassword))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateTheme(ByVal userId As Integer,
                                            ByVal sTheme As String,
                                            ByVal ThemeName As String) As Integer

        Dim dsUser As New DataSet
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_Users SET ")
        If sTheme = "Diagram" Then
            sql.Append("DiagramTheme = @ThemeName, ")
        ElseIf sTheme = "Controls" Then
            sql.Append("SkinName = @ThemeName, ")
        End If
        sql.Append("LastUpdated = GETDATE() ")
        sql.Append("WHERE UserId = @UserId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@ThemeName", ThemeName))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function GetHostNameOfLastLogin(ByVal userId As Integer) As String
        Dim sql As String = "SELECT TOP 1 HostName FROM ERS_UserLogins WHERE UserID = @UserId"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@UserID", userId))

            connection.Open()
            Return CStr(cmd.ExecuteScalar())
        End Using
    End Function

    'Public Function IsUserAdmin(ByVal userId As Integer) As Boolean
    '    Dim sql As String = "SELECT CASE WHEN AccessRights = 3 THEN 1 ELSE 0 END AS UserIsAdmin FROM ERS_Users WHERE UserID = @UserID"

    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand(sql, connection)
    '        cmd.CommandType = CommandType.Text

    '        cmd.Parameters.Add(New SqlParameter("@UserID", userId))

    '        connection.Open()
    '        Dim ret = cmd.ExecuteScalar()
    '        If ret IsNot Nothing Then
    '            Return CBool(ret)
    '        End If
    '    End Using
    '    Return False
    'End Function
#End Region

#Region "Patient"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetPatients1(ByVal searchString1 As String, ByVal searchString2 As String, _
    '                            ByVal searchString3 As String, ByVal searchString4 As String, _
    '                            ByVal opt_condition As String) As DataTable
    '    Dim sql As New StringBuilder
    '    Dim criteria As String = ""
    '    Dim dsPatients As New DataSet


    '    If HttpContext.Current.Session(Constants.SESSION_SEARCH_TAB) = "0" Then
    '        If searchString1 Is Nothing Or searchString1 = "" Then
    '            criteria = ""
    '        Else
    '            Select Case opt_condition
    '                Case "ALL"
    '                    criteria = " WHERE [Case note no] LIKE '%' + ISNULL(@SearchString1,'') + '%' OR [NHS No] LIKE '%' + ISNULL(@SearchString1,'') + '%' OR Surname LIKE '%' + ISNULL(@SearchString1,'') + '%' OR Forename LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '                Case "Case note no"
    '                    criteria = " WHERE [Case note no] LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '                Case "NHS No"
    '                    criteria = " WHERE [NHS No] LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '                Case "Surname"
    '                    criteria = " WHERE Surname LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '                Case "Forename"
    '                    criteria = " WHERE Forename LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '            End Select
    '        End If
    '    Else 'Advanced Search
    '        If Not searchString1 Is Nothing AndAlso searchString1 <> "" Then
    '            criteria += IIf(criteria = "", "WHERE", opt_condition) & " [Case note no] LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '        End If
    '        If Not searchString2 Is Nothing AndAlso searchString2 <> "" Then
    '            criteria += IIf(criteria = "", "WHERE", opt_condition) & " [NHS No] LIKE '%' + ISNULL(@SearchString2,'') + '%' "
    '        End If
    '        If Not searchString3 Is Nothing AndAlso searchString3 <> "" Then
    '            criteria += IIf(criteria = "", "WHERE", opt_condition) & " Surname LIKE '%' + ISNULL(@SearchString3,'') + '%' "
    '        End If
    '        If Not searchString4 Is Nothing AndAlso searchString4 <> "" Then
    '            criteria += IIf(criteria = "", "WHERE", opt_condition) & " Forename LIKE '%' + ISNULL(@SearchString4,'') + '%' "
    '        End If

    '    End If

    '    sql.Append("SELECT [Patient No] AS PatientId, Forename + ' ' + Surname AS PatientName, [Case note no] AS CaseNoteNo,  ")
    '    sql.Append("[NHS No] AS NHSNo, [Record created] AS CreatedOn, * ")
    '    sql.Append(" FROM Patient ")
    '    sql.Append(criteria)
    '    sql.Append(" ORDER BY [Record created] DESC, [Patient No]  DESC ")


    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand(sql.ToString(), connection)
    '        cmd.CommandType = CommandType.Text

    '        If Not String.IsNullOrEmpty(searchString1) Then
    '            cmd.Parameters.Add(New SqlParameter("@SearchString1", searchString1))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@SearchString1", SqlTypes.SqlString.Null))
    '        End If

    '        If Not String.IsNullOrEmpty(searchString2) Then
    '            cmd.Parameters.Add(New SqlParameter("@SearchString2", searchString2))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@SearchString2", SqlTypes.SqlString.Null))
    '        End If
    '        If Not String.IsNullOrEmpty(searchString3) Then
    '            cmd.Parameters.Add(New SqlParameter("@SearchString3", searchString3))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@SearchString3", SqlTypes.SqlString.Null))
    '        End If
    '        If Not String.IsNullOrEmpty(searchString4) Then
    '            cmd.Parameters.Add(New SqlParameter("@SearchString4", searchString4))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@SearchString4", SqlTypes.SqlString.Null))
    '        End If


    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsPatients)
    '    End Using

    '    If dsPatients.Tables.Count > 0 Then
    '        Return dsPatients.Tables(0)
    '    End If
    '    Return New DataTable
    'End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatients(ByVal searchString1 As String, ByVal searchString2 As String,
                                ByVal searchString3 As String, ByVal searchString4 As String,
                                ByVal searchString5 As String, ByVal searchString6 As String,
                                ByVal searchString7 As String, ByVal opt_condition As String,
                                ByVal opt_Type As String, ByVal ExcludeDeceased As Boolean) As DataTable

        Try
            Dim dsPatients As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("startup_select", connection)
                cmd.CommandType = CommandType.StoredProcedure


                If Not String.IsNullOrEmpty(searchString1) Then
                    cmd.Parameters.Add(New SqlParameter("@SearchString1", searchString1))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SearchString1", SqlTypes.SqlString.Null))
                End If

                If Not String.IsNullOrEmpty(searchString2) Then
                    cmd.Parameters.Add(New SqlParameter("@SearchString2", searchString2))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SearchString2", SqlTypes.SqlString.Null))
                End If
                If Not String.IsNullOrEmpty(searchString3) Then
                    cmd.Parameters.Add(New SqlParameter("@SearchString3", searchString3))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SearchString3", SqlTypes.SqlString.Null))
                End If
                If Not String.IsNullOrEmpty(searchString4) Then
                    cmd.Parameters.Add(New SqlParameter("@SearchString4", searchString4))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SearchString4", SqlTypes.SqlString.Null))
                End If
                If Not String.IsNullOrEmpty(searchString5) Then
                    cmd.Parameters.Add(New SqlParameter("@searchString5", searchString5))
                Else
                    cmd.Parameters.Add(New SqlParameter("@searchString5", SqlTypes.SqlString.Null))
                End If
                If Not String.IsNullOrEmpty(searchString6) Then
                    cmd.Parameters.Add(New SqlParameter("@searchString6", searchString6))
                Else
                    cmd.Parameters.Add(New SqlParameter("@searchString6", SqlTypes.SqlString.Null))
                End If
                If Not String.IsNullOrEmpty(searchString7) Then
                    cmd.Parameters.Add(New SqlParameter("@searchString7", searchString7))
                Else
                    cmd.Parameters.Add(New SqlParameter("@searchString7", SqlTypes.SqlString.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@SearchTab", CInt(HttpContext.Current.Session(Constants.SESSION_SEARCH_TAB))))
                cmd.Parameters.Add(New SqlParameter("@Condition", opt_condition))
                cmd.Parameters.Add(New SqlParameter("@SearchType", opt_Type))
                cmd.Parameters.Add(New SqlParameter("@ExcludeDeceased", ExcludeDeceased))
                cmd.Parameters.Add(New SqlParameter("@UserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@UserName", Session("UserId")))

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsPatients)
            End Using

            If dsPatients.Tables.Count > 0 Then
                Return dsPatients.Tables(0)
            End If
        Catch ex As Exception

        End Try
        Return New DataTable
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatient(ByVal PatientId As Integer, Optional ByVal UserId? As Integer = Nothing, Optional ByVal UserName As String = "") As DataTable
        Dim dsPatient As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("patient_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPatient)
        End Using

        If dsPatient.Tables.Count > 0 Then
            Return dsPatient.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SavePatient(ByVal PatientId As Nullable(Of Integer),
                                ByVal CaseNoteNo As String,
                                ByVal Title As String,
                                ByVal Forename As String,
                                ByVal Surname As String,
                                ByVal DateOfBirth As Date,
                                ByVal NHSNo As String,
                                ByVal Address1 As String,
                                ByVal Address2 As String,
                                ByVal Town As String,
                                ByVal County As String,
                                ByVal PostCode As String,
                                ByVal PhoneNo As String,
                                ByVal Gender As String,
                                ByVal EthnicOrigin As Nullable(Of Integer),
                                ByVal JustDownloaded As Nullable(Of Boolean),
                                ByVal Notes As String,
                                ByVal District As String,
                                ByVal DHACode As String,
                                ByVal GPId As Nullable(Of Integer),
                                ByVal DateOfDeath As Nullable(Of Date),
                                ByVal AdvocateRequired As Nullable(Of Boolean),
                                ByVal DateLastSeenAlive As Nullable(Of Date),
                                ByVal CauseOfDeath As String,
                                ByVal CodeForCauseOfDeath As String,
                                ByVal CARelatedDeath As Nullable(Of Boolean),
                                ByVal DeathWithinHospital As Nullable(Of Boolean),
                                ByVal Hospitals As Nullable(Of Integer),
                                ByVal ExtraReferral As String,
                                ByVal ConsultantNo As Nullable(Of Integer),
                                ByVal HIVRisk As Nullable(Of Integer),
                                ByVal OutcomeNotes As String,
                                ByVal UniqueHospitalId As Nullable(Of Integer),
                                ByVal GPReferralFlag As Nullable(Of Boolean),
                                ByVal OwnedBy As String,
                                ByVal HasImages As Nullable(Of Boolean),
                                ByVal VerificationStatus As String) As Integer

        Dim affectedPatientId As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("patients_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            If PatientId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            Else
                cmd.Parameters.Add(New SqlParameter("@PatientId", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", CaseNoteNo))
            cmd.Parameters.Add(New SqlParameter("@Title", Title))
            cmd.Parameters.Add(New SqlParameter("@Forename", Forename))
            cmd.Parameters.Add(New SqlParameter("@Surname", Surname))
            cmd.Parameters.Add(New SqlParameter("@DateOfBirth", DateOfBirth))
            If Not String.IsNullOrEmpty(NHSNo) Then
                cmd.Parameters.Add(New SqlParameter("@NHSNo", NHSNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@NHSNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address1) Then
                cmd.Parameters.Add(New SqlParameter("@Address1", Address1))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address1", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address2) Then
                cmd.Parameters.Add(New SqlParameter("@Address2", Address2))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address2", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Town) Then
                cmd.Parameters.Add(New SqlParameter("@Town", Town))
            Else
                cmd.Parameters.Add(New SqlParameter("@Town", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(County) Then
                cmd.Parameters.Add(New SqlParameter("@County", County))
            Else
                cmd.Parameters.Add(New SqlParameter("@County", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PostCode) Then
                cmd.Parameters.Add(New SqlParameter("@PostCode", PostCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@PostCode", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PhoneNo) Then
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", PhoneNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Gender) Then
                cmd.Parameters.Add(New SqlParameter("@Gender", Gender))
            Else
                cmd.Parameters.Add(New SqlParameter("@Gender", SqlTypes.SqlString.Null))
            End If
            If EthnicOrigin.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", EthnicOrigin))
            Else
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", SqlTypes.SqlInt32.Null))
            End If
            If JustDownloaded.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@JustDownloaded", JustDownloaded))
            Else
                cmd.Parameters.Add(New SqlParameter("@JustDownloaded", SqlTypes.SqlBoolean.Null))
            End If
            If Not String.IsNullOrEmpty(Notes) Then
                cmd.Parameters.Add(New SqlParameter("@Notes", Notes))
            Else
                cmd.Parameters.Add(New SqlParameter("@Notes", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(District) Then
                cmd.Parameters.Add(New SqlParameter("@District", District))
            Else
                cmd.Parameters.Add(New SqlParameter("@District", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DHACode) Then
                cmd.Parameters.Add(New SqlParameter("@DHACode", DHACode))
            Else
                cmd.Parameters.Add(New SqlParameter("@DHACode", SqlTypes.SqlString.Null))
            End If
            If GPId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GPId", GPId))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPId", SqlTypes.SqlInt32.Null))
            End If
            If DateOfDeath.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DateOfDeath", DateOfDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@DateOfDeath", SqlTypes.SqlDateTime.Null))
            End If
            If AdvocateRequired.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AdvocateRequired", AdvocateRequired))
            Else
                cmd.Parameters.Add(New SqlParameter("@AdvocateRequired", SqlTypes.SqlBoolean.Null))
            End If
            If DateLastSeenAlive.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DateLastSeenAlive", DateLastSeenAlive))
            Else
                cmd.Parameters.Add(New SqlParameter("@DateLastSeenAlive", SqlTypes.SqlDateTime.Null))
            End If
            If Not String.IsNullOrEmpty(CauseOfDeath) Then
                cmd.Parameters.Add(New SqlParameter("@CauseOfDeath", CauseOfDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@CauseOfDeath", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(CodeForCauseOfDeath) Then
                cmd.Parameters.Add(New SqlParameter("@CodeForCauseOfDeath", CodeForCauseOfDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@CodeForCauseOfDeath", SqlTypes.SqlString.Null))
            End If
            If CARelatedDeath.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CARelatedDeath", CARelatedDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@CARelatedDeath", SqlTypes.SqlBoolean.Null))
            End If
            If DeathWithinHospital.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DeathWithinHospital", DeathWithinHospital))
            Else
                cmd.Parameters.Add(New SqlParameter("@DeathWithinHospital", SqlTypes.SqlBoolean.Null))
            End If
            If Hospitals.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Hospitals", Hospitals))
            Else
                cmd.Parameters.Add(New SqlParameter("@Hospitals", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(ExtraReferral) Then
                cmd.Parameters.Add(New SqlParameter("@ExtraReferral", ExtraReferral))
            Else
                cmd.Parameters.Add(New SqlParameter("@ExtraReferral", SqlTypes.SqlString.Null))
            End If
            If ConsultantNo.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ConsultantNo", ConsultantNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@ConsultantNo", SqlTypes.SqlInt32.Null))
            End If
            If HIVRisk.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@HIVRisk", HIVRisk))
            Else
                cmd.Parameters.Add(New SqlParameter("@HIVRisk", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(OutcomeNotes) Then
                cmd.Parameters.Add(New SqlParameter("@OutcomeNotes", OutcomeNotes))
            Else
                cmd.Parameters.Add(New SqlParameter("@OutcomeNotes", SqlTypes.SqlString.Null))
            End If
            If UniqueHospitalId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", UniqueHospitalId))
            Else
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", SqlTypes.SqlInt32.Null))
            End If
            If GPReferralFlag.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GPReferralFlag", GPReferralFlag))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPReferralFlag", SqlTypes.SqlBoolean.Null))
            End If
            If Not String.IsNullOrEmpty(OwnedBy) Then
                cmd.Parameters.Add(New SqlParameter("@OwnedBy", OwnedBy))
            Else
                cmd.Parameters.Add(New SqlParameter("@OwnedBy", SqlTypes.SqlString.Null))
            End If
            If HasImages.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@HasImages", HasImages))
            Else
                cmd.Parameters.Add(New SqlParameter("@HasImages", SqlTypes.SqlBoolean.Null))
            End If
            If Not String.IsNullOrEmpty(VerificationStatus) Then
                cmd.Parameters.Add(New SqlParameter("@VerificationStatus", VerificationStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@VerificationStatus", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            affectedPatientId = CInt(cmd.ExecuteScalar())
        End Using

        Return affectedPatientId
    End Function
#End Region

#Region "Procedures"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedures(ByVal patientId As Integer, ByVal includeOldProcs As Boolean) As DataTable
        '### TO DO: Return Procedure object-> using StoredProc!
        Return ExecuteSP("usp_Procedures_SelectByPatient", New SqlParameter() {New SqlParameter("@PatientId", patientId), New SqlParameter("@IncludeOldProcs", includeOldProcs)})
    End Function

    Public Function GetProcedure(ByVal procedureId As Integer, ByVal bFromUGI As Boolean, ByVal procedureType As Integer, ByVal ColonType As Integer, Optional ByVal fromPrevious As Boolean = False) As DataTable
        Return ExecuteSP("usp_Procedure_Select", New SqlParameter() {New SqlParameter("@ProcedureType", procedureType),
                                                                New SqlParameter("@ProcedureID", procedureId),
                                                                New SqlParameter("@FromUGI", bFromUGI),
                                                                New SqlParameter("@ColonType", ColonType),
                                                                New SqlParameter("@FromPrevious", fromPrevious)
                                                            })
    End Function

    'Public Function GetProcedureLatest(ByVal caseNoteNo As String) As DataTable
    '    '### TO DO: Return Procedure object-> using StoredProc!
    '    Dim dsProcedure As New DataSet
    '    Dim sql As String

    '    sql = "SELECT TOP 1 * FROM ERS_Procedures WHERE PatientId = (SELECT [Patient No] FROM Patient WHERE [Case note no] = @CaseNoteNo) ORDER BY CreatedOn DESC"
    '    Return ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@CaseNoteNo", caseNoteNo)})

    '    'Using connection As New SqlConnection(ConnectionStr)
    '    '    Dim cmd As New SqlCommand(sql, connection)
    '    '    cmd.CommandType = CommandType.Text
    '    '    cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", caseNoteNo))

    '    '    Dim adapter = New SqlDataAdapter(cmd)

    '    '    connection.Open()
    '    '    adapter.Fill(dsProcedure)
    '    'End Using

    '    'If dsProcedure.Tables.Count > 0 Then
    '    '    Return dsProcedure.Tables(0)
    '    'End If
    '    'Return Nothing
    'End Function

    'Public Function GetProcedureByEpisodeNo(ByVal episodeNo As Integer) As DataTable
    '    Dim dsProcedures As New DataSet
    '    Dim sql As String = "SELECT * FROM ERS_Procedures WHERE EpisodeNo = @episodeNo"

    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand(sql, connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@EpisodeNo", episodeNo))

    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsProcedures)
    '    End Using

    '    If dsProcedures.Tables.Count > 0 Then
    '        Return dsProcedures.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertProcedure(ByVal P As ERS.Data.ERS_Procedures, ByVal ProductType As Integer) As Integer
        Dim newProcId As Integer
        Dim outputParamNewProcedureId As New System.Data.Entity.Core.Objects.ObjectParameter("NewProcedureId", GetType(Integer))
        'outNewProc.ParameterType

        Using db As New ERS.Data.GastroDbEntities
            If db.ERS_Procedures.Any(Function(x) x.IsActive = 1 And (x.ProcedureCompleted Is Nothing Or x.ProcedureCompleted = 0) And x.PatientId = P.PatientId) Then
                Throw New Exception("An incomplete procedure already exists for this patient. Must be completed or deleted before creating a new one.") 'if system finds a way through attempting to create multiple procedures before ones been completed
            Else
                Dim resultExecution = db.Procedures_Insert(P.ProcedureType _
                                                , P.PatientId _
                                                , P.CreatedOn _
                                                , P.PatientStatus _
                                                , P.Ward _
                                                , P.PatientType _
                                                , P.OperatingHospitalID _
                                                , P.ListConsultant _
                                                , P.Endoscopist1 _
                                                , P.Endoscopist2 _
                                                , P.Assistant _
                                                , P.Nurse1 _
                                                , P.Nurse2 _
                                                , P.Nurse3 _
                                                , P.Nurse4 _
                                                , P.ReferralHospitalNo _
                                                , P.ReferralConsultantNo _
                                                , P.ReferralConsultantSpeciality _
                                                , P.PatientConsent _
                                                , False _
                                                , P.CreatedBy _
                                                , ProductType _
                                                , P.ListType _
                                                , P.Endo1Role _
                                                , P.Endo2Role _
                                                , P.CategoryListId _
                                                , P.OnWaitingList _
                                                , P.OpenAccessProc _
                                                , P.EmergencyProcType _
                                                , outputParamNewProcedureId _
                                                , P.ImagePortId _
                                                , P.Points _
                                                , P.ChecklistComplete _
                                                , P.ReferrerType _
                                                , P.ReferrerTypeOther)

                newProcId = Convert.ToInt32(outputParamNewProcedureId.Value.ToString())

                Try
                    If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_APPOINTMENT_ID)) AndAlso CInt(Session(Constants.SESSION_APPOINTMENT_ID)) > 0 Then
                        Dim appointmentId = CInt(Session(Constants.SESSION_APPOINTMENT_ID))

                        logJourneyProcedureStart(newProcId, appointmentId)

                        Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault
                        appointment.AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY.Trim = "IP").FirstOrDefault.UniqueId
                        db.ERS_Appointments.Attach(appointment)
                        db.Entry(appointment).State = Entity.EntityState.Modified
                        db.SaveChanges()
                    End If
                Catch ex As Exception
                    LogManager.LogManagerInstance.LogError("Error saving procedure start time to patient journey table", ex)
                End Try
            End If
        End Using

        Return newProcId

    End Function

    Public Sub logJourneyProcedureStart(procId As Integer, appointmentId As Integer)
        Try
            Using db As New ERS.Data.GastroDbEntities

                Dim tblPatientJourney =
                            db.ERS_PatientJourney.Where(Function(x) x.ProcedureId Is Nothing AndAlso
                                                                    x.PatientAdmissionTime IsNot Nothing And
                                                                    x.ProcedureStartTime Is Nothing And
                                                                    x.ProcedureEndTime Is Nothing And
                                                                    x.AppointmentId = appointmentId).FirstOrDefault


                If tblPatientJourney Is Nothing Then tblPatientJourney = New ERS_PatientJourney
                With tblPatientJourney
                    .ProcedureId = procId
                    .ProcedureStartTime = Now
                    .AppointmentId = appointmentId
                End With

                If tblPatientJourney.PatientJourneyId = 0 Then
                    db.ERS_PatientJourney.Add(tblPatientJourney)
                Else
                    db.ERS_PatientJourney.Attach(tblPatientJourney)
                    db.Entry(tblPatientJourney).State = Entity.EntityState.Modified
                End If
                db.SaveChanges()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error logging patient journey procedure start", ex)
        End Try
    End Sub

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)> _
    'Public Function InsertProcedure(ByVal procedureType As Integer, _
    '                                ByVal patientId As Integer, _
    '                                ByVal procedureDate As Nullable(Of Date), _
    '                                ByVal patientStatus As Nullable(Of Integer), _
    '                                ByVal patientWard As Nullable(Of Integer), _
    '                                ByVal patientType As Nullable(Of Integer), _
    '                                ByVal listConsultant As Nullable(Of Integer), _
    '                                ByVal endoscopist1 As Nullable(Of Integer), _
    '                                ByVal endoscopist2 As Nullable(Of Integer), _
    '                                ByVal assistant As Nullable(Of Integer), _
    '                                ByVal nurse1 As Nullable(Of Integer), _
    '                                ByVal nurse2 As Nullable(Of Integer), _
    '                                ByVal nurse3 As Nullable(Of Integer), _
    '                                ByVal referralHospitalNo As Nullable(Of Integer), _
    '                                ByVal referralConsultantNo As Nullable(Of Integer), _
    '                                ByVal ReferralConsultantSpeciality As Nullable(Of Integer), _
    '                                ByVal PatientConsent As Nullable(Of Integer), _
    '                                ByVal DefaultCheckBox As Boolean, _
    '                                ByVal UserId As Integer, _
    '                                ByVal ProductType As Integer, _
    '                                ByVal listType As Nullable(Of Integer), _
    '                                ByVal endo1Role As Nullable(Of Integer), _
    '                                ByVal endo2Role As Nullable(Of Integer)) As Integer

    '    '### TO DO: INSERT Procedure object-> using Entity Framework!

    '    Dim operatingHospitalId As Integer = CInt(HttpContext.Current.Session("OperatingHospitalID"))

    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand("usp_Procedures_Insert", connection)
    '        cmd.CommandType = CommandType.StoredProcedure

    '        cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
    '        cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
    '        cmd.Parameters.Add(New SqlParameter("@ProcedureDate", procedureDate))
    '        ' cmd.Parameters.Add(New SqlParameter("@UserId", CStr(HttpContext.Current.Session("PKUserId"))))
    '        cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

    '        If patientStatus.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@PatientStatus", patientStatus))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@PatientStatus", SqlTypes.SqlInt32.Null))
    '        End If
    '        If patientWard.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@PatientWard", patientWard))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@PatientWard", SqlTypes.SqlInt32.Null))
    '        End If
    '        If patientType.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@PatientType", patientType))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@PatientType", SqlTypes.SqlInt32.Null))
    '        End If
    '        If listConsultant.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@ListConsultant", listConsultant))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@ListConsultant", SqlTypes.SqlInt32.Null))
    '        End If
    '        If endoscopist1.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Endoscopist1", endoscopist1))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Endoscopist1", SqlTypes.SqlInt32.Null))
    '        End If
    '        If endoscopist2.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Endoscopist2", endoscopist2))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Endoscopist2", SqlTypes.SqlInt32.Null))
    '        End If
    '        If assistant.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Assistant", assistant))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Assistant", SqlTypes.SqlInt32.Null))
    '        End If
    '        If nurse1.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Nurse1", nurse1))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Nurse1", SqlTypes.SqlInt32.Null))
    '        End If
    '        If nurse2.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Nurse2", nurse2))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Nurse2", SqlTypes.SqlInt32.Null))
    '        End If
    '        If nurse3.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Nurse3", nurse3))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Nurse3", SqlTypes.SqlInt32.Null))
    '        End If
    '        If referralHospitalNo.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@ReferralHospitalNo", referralHospitalNo))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@ReferralHospitalNo", SqlTypes.SqlInt32.Null))
    '        End If
    '        If referralConsultantNo.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@ReferralConsultantNo", referralConsultantNo))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@ReferralConsultantNo", SqlTypes.SqlInt32.Null))
    '        End If
    '        If ReferralConsultantSpeciality.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@ReferralConsultantSpeciality", ReferralConsultantSpeciality))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@ReferralConsultantSpeciality", SqlTypes.SqlInt32.Null))
    '        End If
    '        If PatientConsent.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@PatientConsent", PatientConsent))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@PatientConsent", SqlTypes.SqlInt32.Null))
    '        End If
    '        cmd.Parameters.Add(New SqlParameter("@DefaultCheckBox", DefaultCheckBox))
    '        cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
    '        cmd.Parameters.Add(New SqlParameter("@ProductType", ProductType))


    '        If listType.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@listType", listType))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@listType", SqlTypes.SqlInt32.Null))
    '        End If
    '        If endo1Role.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@endo1Role", endo1Role))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@endo1Role", SqlTypes.SqlInt32.Null))
    '        End If
    '        If endo2Role.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@endo2Role", endo2Role))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@endo2Role", SqlTypes.SqlInt32.Null))
    '        End If

    '        connection.Open()
    '        Return CInt(cmd.ExecuteScalar())
    '    End Using
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function ReplicateProcedure(ByVal procedureId As Integer, ByVal procedureType As Integer) As Integer

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("usp_Procedure_Replicate", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", procedureId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    Public Function DeleteProcedure(ByVal procedureId As Integer, Optional ByVal episodeNo As Integer = 0) As Integer
        Return ExecuteScalerSQL("usp_Procedures_Delete", CommandType.StoredProcedure, New SqlParameter() {
                                                                                        New SqlParameter("@ProcedureId", procedureId),
                                                                                        New SqlParameter("@EpisodeNo", procedureId)
                         })
    End Function

    Public Function DeletePreviousProcedure(ByVal previousProcedureId As Integer, Optional ByVal inactiveReason As String = "") As Integer
        Return ExecuteScalerSQL("usp_PreviousProcedures_Delete", CommandType.StoredProcedure,
                                New SqlParameter() {
                                    New SqlParameter("@PreviousProcedureId", previousProcedureId),
                                    New SqlParameter("@InactiveReason", inactiveReason)}
                                )
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertPatientWard(ByVal ward As String) As Integer
        Return ExecuteScalerSQL("usp_Ward_Insert", CommandType.StoredProcedure, New SqlParameter() {New SqlParameter("@WardName", ward)})
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)> _
    'Public Function SetDefaultValues(ByVal pageName As String, _
    '                                     ByVal listConsultant As Integer, _
    '                                     ByVal endoscopist1 As Integer, _
    '                                     ByVal endoscopist2 As Integer, _
    '                                     ByVal nurse1 As Integer, _
    '                                     ByVal nurse2 As Integer, _
    '                                     ByVal nurse3 As Integer, _
    '                                     ByVal patientType As Integer, _
    '                                     ByVal listType As Integer, _
    '                                     ByVal procedureRole As Integer) As Integer
    '    Dim sql As New StringBuilder
    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand("set_default_values", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@UserID", CInt(HttpContext.Current.Session("PKUserID"))))
    '        cmd.Parameters.Add(New SqlParameter("@ListConsultant", listConsultant))
    '        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", endoscopist1))
    '        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", endoscopist2))
    '        cmd.Parameters.Add(New SqlParameter("@Nurse1", nurse1))
    '        cmd.Parameters.Add(New SqlParameter("@Nurse2", nurse2))
    '        cmd.Parameters.Add(New SqlParameter("@Nurse3", nurse3))
    '        cmd.Parameters.Add(New SqlParameter("@PatientType", patientType))
    '        cmd.Parameters.Add(New SqlParameter("@ListType", listType))
    '        cmd.Parameters.Add(New SqlParameter("@ProcedureRole", procedureRole))
    '        connection.Open()
    '        Return cmd.ExecuteNonQuery()
    '    End Using
    'End Function

    Public Function GetDefaultValues() As DataTable
        'Dim dsProcedure As New DataSet
        Dim sql As String

        sql = "SELECT TOP 1 * FROM ERS_Default WHERE UserID = @UserId"
        Return ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@UserId", LoggedInUserId)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateProcedureStaff(ByVal procedureID As Integer,
                                         ByVal listType As Integer,
                                         ByVal consultant As Integer,
                                         ByVal endoscopist1 As Integer,
                                         ByVal endoscopist1Role As Integer,
                                         ByVal endoscopist2 As Integer,
                                         ByVal endoscopist2Role As Integer,
                                         ByVal nurse1 As Integer,
                                         ByVal nurse2 As Integer,
                                         ByVal nurse3 As Integer,
                                         ByVal nurse4 As Integer) As Integer
        Try
            Return DataAccess.ExecuteScalerSQL("usp_UpdateProcedureStaff", CommandType.StoredProcedure, New SqlParameter() {
                                                                         New SqlParameter("@ProcedureID", procedureID),
                                                                         New SqlParameter("@ListType", listType),
                                                                         New SqlParameter("@ListConsultant", consultant),
                                                                         New SqlParameter("@Endoscopist1", endoscopist1),
                                                                         New SqlParameter("@Endoscopist1Role", endoscopist1Role),
                                                                         New SqlParameter("@Endoscopist2", endoscopist2),
                                                                         New SqlParameter("@Endoscopist2Role", endoscopist2Role),
                                                                         New SqlParameter("@Nurse1", nurse1),
                                                                         New SqlParameter("@Nurse2", nurse2),
                                                                         New SqlParameter("@Nurse3", nurse3),
                                                                         New SqlParameter("@Nurse4", nurse4),
                                                                         New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId"))),
                                                                         New SqlParameter("@LoggedInUserId", LoggedInUserId)
                                                                })

        Catch ex As Exception
            Return 0
            Console.WriteLine("Ex message: " + ex.ToString())
        End Try

    End Function

    Public Function ProcedureConsultantRoles(ByVal procedureId As Integer) As DataTable
        Return ExecuteSQL("SELECT * FROM tvfProcedureConsultantRoles(@ProcedureID)", New SqlParameter() {New SqlParameter("@ProcedureID", procedureId)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateProcedureFlipDiagram(ByVal procedureId As Integer) As Integer
        Using da As New DataAccess
            Return DataAccess.ExecuteScalerSQL("broncho_flip_diagram", CommandType.StoredProcedure, New SqlParameter() {New SqlParameter("@procedureId", procedureId)})
        End Using
    End Function

    Public Function GetDiagram(id As Integer) As DataTable
        Return ExecuteSQL("SELECT * FROM ERS_Diagrams WHERE DiagramId = @DiagramId", New SqlParameter() {New SqlParameter("@DiagramId", id)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiagram(procedureType As Integer, diagramNumber As Integer, Optional height As Integer = 0, Optional width As Integer = 0, Optional getRegionPaths As Boolean = 0) As DataTable
        'param diagramNumber seems to be always 0, so not using it any further 

        Return ExecuteSP("usp_GetDiagram", New SqlParameter() {New SqlParameter("@ProcedureTypeId", procedureType),
                                                                New SqlParameter("@DiagramNumber", diagramNumber),
                                                                New SqlParameter("@height", height),
                                                                New SqlParameter("@width", width),
                                                                New SqlParameter("@getRegionPaths", getRegionPaths)
                                                            })
    End Function

#End Region

#Region "Report Summary"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintReport(ByVal procId As Integer, ByVal group As String, ByVal episodeNo As Integer, ByVal patComboId As String, ProcedureType As Integer, ColonType As Integer) As DataTable

        Return GetReport(procId, group, episodeNo, patComboId, ProcedureType, ColonType)

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetReportSummary(ByVal procId As Integer) As DataTable
        Try
            Return GetReport(procId, "LS", Nothing, Nothing, Nothing, Nothing)

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error getting summary report", ex)
        End Try

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPremedReportSummary(ByVal procId As Integer) As DataTable

        Return GetReport(procId, "Premed", Nothing, Nothing, Nothing, Nothing)

    End Function

    Public Function GetReport(ProcedureId As Integer, Group As String, ByVal EpisodeNo As String, PatientComboId As String, ProcedureType? As Integer, ColonType? As Integer) As DataTable

        Return ExecuteSP("usp_PrintReport", New SqlParameter() {
                                                             New SqlParameter("@ProcedureID", ProcedureId),
                                                             New SqlParameter("@Group", Group),
                                                             New SqlParameter("@EpisodeNo", IIf(EpisodeNo Is Nothing, SqlTypes.SqlString.Null, EpisodeNo)),
                                                             New SqlParameter("@PatientComboId", IIf(PatientComboId Is Nothing, SqlTypes.SqlString.Null, PatientComboId)),
                                                             New SqlParameter("@ProcedureType", IIf(ProcedureType.HasValue(), ProcedureType, SqlTypes.SqlInt32.Null)),
                                                             New SqlParameter("@ColonType", IIf(ColonType.HasValue(), ColonType, SqlTypes.SqlInt32.Null))
                                                         })

    End Function

    Public Function GetReportSummaryWithHyperlinks(ByVal procedureId As Integer, ByVal SiteId As Integer) As String
        Dim s As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("usp_Report_Summary_Select_Hyperlinks", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            s = cmd.ExecuteScalar()
        End Using

        If IsDBNull(s) = False Then
            Return CStr(s)
        Else
            Return ""
        End If
    End Function

    Public Function GetInstForCareWithHyperlinks(ByVal procedureId As Integer) As String
        Dim hyperLinkText As String = ""

        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = db.ERS_ProceduresReporting.Find(procedureId)
                hyperLinkText = result.PP_InstForCareWithLinks.ToString()
            End Using

            Return hyperLinkText
        Catch ex As Exception
            Return ""   '### Error .. Return Empty!
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientSummary(ByVal procedureId As Integer, ByVal ProcedureType As Integer, Optional ByVal episodeNo As Integer = 0, Optional ByVal patComboId As String = "") As DataTable
        '##### Question: Can't we use 'printreport_patient_info_select' instead of 'usp_PrintReport_Select'?? So- we can re-use the Function [ GetPrintReport() ]
        Return ExecuteSP("printreport_patient_info_select", New SqlParameter() {
                                                     New SqlParameter("@ProcedureID", procedureId),
                                                     New SqlParameter("@ProcedureType", ProcedureType),
                                                     New SqlParameter("@EpisodeNo", episodeNo),
                                                     New SqlParameter("@PatientComboId", patComboId)
                                                 })
    End Function

    'Public Function GetPrintReportHeader(ByVal operatingHospitalId As Integer) As DataTable
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintReportHeader(ByVal operatingHospitalId As Integer, ByVal procedureId As Integer, ByVal episodeNo As Integer, ByVal patientComboId As String, ByVal bRepEnableNHSStyle As Boolean) As DataTable

        Dim dsSummary As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("printreport_header_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@EpisodeNo", episodeNo))
            cmd.Parameters.Add(New SqlParameter("@PatientComboId", patientComboId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE))))
            cmd.Parameters.Add(New SqlParameter("@EnableNHSType", bRepEnableNHSStyle))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSummary)
        End Using

        If dsSummary.Tables.Count > 0 Then
            Return dsSummary.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintReportPhotos(ByVal operatingHospitalId As Integer, ByVal procedureId As Integer, ByVal episodeNo As Integer, ByVal patientComboId As String, ByVal ColonType As Integer) As DataTable

        If procedureId = 0 Then
            Return Nothing
        End If

        Dim iProcedureType As Integer
        If Not Integer.TryParse(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE), iProcedureType) Then
            iProcedureType = 0
        End If

        If iProcedureType = ProcedureType.Rigid Then
            iProcedureType = 3
        End If

        Return ExecuteSP("printreport_photos_select", New SqlParameter() {
                                                            New SqlParameter("@OperatingHospitalID", operatingHospitalId),
                                                            New SqlParameter("@ProcedureId", procedureId),
                                                            New SqlParameter("@EpisodeNo", episodeNo),
                                                            New SqlParameter("@PatientComboId", patientComboId),
                                                            New SqlParameter("@ProcedureType", iProcedureType),
                                                            New SqlParameter("@ColonType", ColonType)})

    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function IsImagesOnReport(ByVal operatingHospitalId As Integer, ByVal procedureId As Integer, ByVal episodeNo As Integer, ByVal patientComboId As String, ByVal ColonType As Integer) As DataTable

        If procedureId = 0 Then
            Return Nothing
        End If

        Dim iProcedureType As Integer
        If Not Integer.TryParse(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE), iProcedureType) Then
            iProcedureType = 0
        End If

        If iProcedureType = ProcedureType.Rigid Then
            iProcedureType = 3
        End If

        Return ExecuteSP("getImageCount", New SqlParameter() {
                                                            New SqlParameter("@OperatingHospitalID", operatingHospitalId),
                                                            New SqlParameter("@ProcedureId", procedureId),
                                                            New SqlParameter("@EpisodeNo", episodeNo),
                                                            New SqlParameter("@PatientComboId", patientComboId),
                                                            New SqlParameter("@ProcedureType", iProcedureType),
                                                            New SqlParameter("@ColonType", ColonType)})

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintReportSpecimens(ByVal procedureId As Integer) As DataTable
        Return ExecuteSP("printreport_specimens_select", New SqlParameter() {
                                                            New SqlParameter("@ProcedureId", procedureId)})

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPathologyReportSpecimens() As DataTable
        Dim iProcedureID = CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))

        Dim dt = ExecuteSP("pathologyreport_specimens_select", New SqlParameter() {
                                                            New SqlParameter("@ProcedureId", iProcedureID)})

        Return dt
    End Function
#End Region

#Region "Sites"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSites(ByVal procedureId As Integer, ByVal diagHeight As Integer, ByVal diagWidth As Integer, ByVal episodeNo As Integer, ByVal procType As Integer, ColonType As Integer) As DataTable
        Dim dsSites As New DataSet
        Dim isERS As Boolean = IIf(episodeNo > 0, False, True)

        Return ExecuteSP("sites_select", New SqlParameter() {
                                                    New SqlParameter("@isERS", isERS),
                                                    New SqlParameter("@ProcedureId", procedureId),
                                                    New SqlParameter("@Height", diagHeight),
                                                    New SqlParameter("@Width", diagWidth),
                                                    New SqlParameter("@OperatingHospitalID", CInt(HttpContext.Current.Session("OperatingHospitalID"))),
                                                    New SqlParameter("@ProcedureType", procType),
                                                    New SqlParameter("@episodeNo", episodeNo),
                                                    New SqlParameter("@ColonType", ColonType)})
    End Function

    Public Function GetSiteDetailsByDistance() As DataTable
        Dim dsSite As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT SiteId, ")
        query.Append(" ( CONVERT(VARCHAR,XCoordinate) +   ")
        query.Append("    CASE WHEN YCoordinate IS NULL OR YCoordinate=0 THEN ' cm' ")
        query.Append("         ELSE (' to ' + CONVERT(VARCHAR,YCoordinate) + ' cm' ) END) AS Distance ")
        query.Append("FROM ERS_Sites ")
        query.Append("WHERE ProcedureID = @ProcedureId AND SiteNo = @SiteNo ")
        query.Append("ORDER BY XCoordinate ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))))
            cmd.Parameters.Add(New SqlParameter("@SiteNo", -77))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSite)
        End Using

        If dsSite.Tables.Count > 0 Then
            Return dsSite.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSiteTitles(ByVal procedureId As Integer) As DataTable
        Dim dsSites As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT s.SiteId, CASE WHEN s.SiteNo > 0 THEN dbo.fnGetSiteTitle(s.SiteNo, pr.OperatingHospitalID) END AS SiteTitle ")
        query.Append("From ERS_Sites s ")
        query.Append("left join ERS_Procedures pr on s.ProcedureID = pr.ProcedureID ")
        query.Append("Where s.procedureId = @ProcedureId Order By s.AreaNo, s.SiteNo DESC")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSites)
        End Using

        If dsSites.Tables.Count > 0 Then
            Return dsSites.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSitesWithPhotos(ByVal procedureId As Integer, Optional ByVal includeVideos As Boolean = True) As DataTable
        Dim dsSites As New DataSet
        Dim sql As New StringBuilder

        sql.Append("Select DISTINCT p.SiteId, ISNULL('Site ' + dbo.fnGetSiteTitle(SiteNo, pr.OperatingHospitalID) + ':', 'ZZZZ') AS SiteName ")
        sql.Append("FROM ERS_Photos p ")
        sql.Append("LEFT JOIN ERS_Sites s ON p.SiteId=s.SiteId ")
        sql.Append("Left Join ERS_Procedures pr on s.ProcedureID = pr.ProcedureID ")
        sql.Append("WHERE p.ProcedureId = @ProcedureId ")
        If Not includeVideos Then
            sql.Append("AND p.PhotoName NOT LIKE '%.mp4' ")
        End If
        sql.Append("ORDER BY SiteName ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSites)
        End Using

        If dsSites.Tables.Count > 0 Then
            Return dsSites.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSitesWithDescription(ByVal procedureId As Integer) As DataTable
        Dim dsSites As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT SiteId, ")
        query.Append("  'Site ' + dbo.fnGetSiteTitle(SiteNo, pr.OperatingHospitalID) + ")
        query.Append("  ' (' + ")
        'query.Append(" CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN 'Anterior/Posterior' END + ")
        query.Append(" CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN '' END + ")
        query.Append("  ' in ' + r.Region + ")
        query.Append("  ')' AS SiteDescription ")
        query.Append("FROM ERS_Sites s ")
        query.Append("JOIN ERS_Regions r ON s.RegionId = r.RegionId ")
        query.Append("Left Join ERS_Procedures pr on s.ProcedureID = pr.ProcedureID ")
        query.Append("WHERE pr.ProcedureId = @ProcedureId ")
        query.Append("AND s.SiteNo <> 0 ")
        query.Append("ORDER BY s.SiteNo ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSites)
        End Using

        If dsSites.Tables.Count > 0 Then
            Return dsSites.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetSiteDescription(ByVal siteId As Integer) As String
        Dim dsSites As New DataSet
        Dim query As New StringBuilder
        Dim siteDescription As String = ""

        query.Append("SELECT ")
        query.Append("  'Site ' + CONVERT(VARCHAR(5), SiteNo) + ")
        query.Append("  ' (' + ")
        'query.Append(" CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN 'Anterior/Posterior' END + ")
        query.Append(" CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN '' END + ")
        query.Append("  ' in ' + r.Region + ")
        query.Append("  ')' AS SiteDescription ")
        query.Append("FROM ERS_Sites s ")
        query.Append("JOIN ERS_Regions r ON s.RegionId = r.RegionId ")
        query.Append("WHERE SiteId = @SiteId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            connection.Open()
            siteDescription = CStr(cmd.ExecuteScalar())
        End Using

        Return siteDescription
    End Function

    Public Function GetSiteDetails(ByVal siteId As Integer) As DataTable
        Dim dsSite As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT SiteId, ")
        query.Append("  CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN '' END AS AntPosDescription, ")
        query.Append("  r.Region ")
        query.Append("FROM ERS_Sites s ")
        query.Append("JOIN ERS_Regions r ON s.RegionId = r.RegionId ")
        query.Append("WHERE SiteId = @SiteId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSite)
        End Using

        If dsSite.Tables.Count > 0 Then
            Return dsSite.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSitesSummary(ByVal procId As Integer) As DataTable
        Dim dsSummary As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT SiteNo,SiteSummary FROM Sites WHERE ProcedureId = @ProcedureId", connection)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSummary)
        End Using

        If dsSummary.Tables.Count > 0 Then
            Return dsSummary.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetSiteNo(ByVal siteId As Integer) As String
        Dim siteNo As String
        Dim query As New StringBuilder

        query.Append("SELECT CASE WHEN s.SiteNo > 0 THEN dbo.fnGetSiteTitle(s.SiteNo, pr.OperatingHospitalID) END AS SiteTitle ")
        query.Append("From ERS_Sites s ")
        query.Append("left join ERS_Procedures pr on s.ProcedureID = pr.ProcedureID ")
        query.Append("WHERE SiteId = @SiteId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            connection.Open()
            siteNo = cmd.ExecuteScalar().ToString()
        End Using

        Return siteNo
    End Function

    Public Function GetPrimeSiteId(ByVal siteId As Integer) As Integer
        Dim siteNo As Integer

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT dbo.fnGetPrimeSiteId(@SiteId)", connection)
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            connection.Open()
            siteNo = CInt(cmd.ExecuteScalar())
        End Using

        Return siteNo
    End Function

    Public Function GetSiteDetailsMenus(siteId As Integer) As DataTable
        Dim dsMenus As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("site_details_menu_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            'cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
            'cmd.Parameters.Add(New SqlParameter("@Region", region))
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsMenus)
        End Using

        If dsMenus.Tables.Count > 0 Then
            Return dsMenus.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SitesExist(ByVal procedureId As Integer, ByVal episodeNo As Integer, ByVal procType As Integer) As Boolean
        Dim dsSites As New DataSet
        Dim qry As New StringBuilder()
        Dim sitesCount As Integer

        qry.Append("IF @ProcedureId > 0 ")
        qry.Append("SELECT COUNT(*) FROM ERS_Sites WHERE ProcedureId = @ProcedureId ")
        qry.Append("ELSE ")
        If procType = ProcedureType.Gastroscopy Then
            qry.Append("SELECT COUNT(*) FROM [Upper GI Procedure] WHERE [Episode No] = @EpisodeNo ")
        ElseIf procType = ProcedureType.ERCP Then
            qry.Append("SELECT COUNT(*) FROM [ERCP Procedure] WHERE [Episode No] = @EpisodeNo ")
        Else
            qry.Append("SELECT COUNT(*) FROM [Colon Procedure] WHERE [Episode No] = @EpisodeNo ")
        End If

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@EpisodeNo", episodeNo))

            cmd.Connection.Open()
            sitesCount = CInt(cmd.ExecuteScalar())
        End Using

        Return sitesCount > 0
    End Function

    Public Function InsertSite(ByVal procId As Integer,
                               ByVal regionId As Integer,
                               ByVal xCordinate As Integer,
                               ByVal yCordinate As Integer,
                               ByVal antPos As Integer,
                               ByVal positionSpecified As Boolean,
                               ByVal areaNumber As Integer,
                               ByVal height As Integer,
                               ByVal width As Integer) As String
        Dim newSiteInfo As String
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("sites_insert", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procId))
            cmd.Parameters.Add(New SqlParameter("@RegionId", regionId))
            cmd.Parameters.Add(New SqlParameter("@XCoordinate", xCordinate))
            cmd.Parameters.Add(New SqlParameter("@YCoordinate", yCordinate))
            cmd.Parameters.Add(New SqlParameter("@AntPos", antPos))
            cmd.Parameters.Add(New SqlParameter("@PositionSpecified", positionSpecified))
            cmd.Parameters.Add(New SqlParameter("@AreaNo", areaNumber))
            cmd.Parameters.Add(New SqlParameter("@DiagramHeight", height))
            cmd.Parameters.Add(New SqlParameter("@DiagramWidth", width))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            cmd.Connection.Open()
            newSiteInfo = CStr(cmd.ExecuteScalar())
        End Using

        Return newSiteInfo
    End Function

    Public Function UpdateSite(ByVal siteId As Integer,
                               ByVal regionId As Integer,
                               ByVal xCordinate As Integer,
                               ByVal yCordinate As Integer,
                               ByVal antPos As Integer,
                               ByVal positionSpecified As Boolean) As Integer

        Return ExecuteScalerSQL("sites_update", CommandType.StoredProcedure, New SqlParameter() {
                                                                                    New SqlParameter("@SiteId", siteId),
                                                                                    New SqlParameter("@RegionId", regionId),
                                                                                    New SqlParameter("@XCoordinate", xCordinate),
                                                                                    New SqlParameter("@YCoordinate", yCordinate),
                                                                                    New SqlParameter("@AntPos", antPos),
                                                                                    New SqlParameter("@PositionSpecified", positionSpecified),
                                                                                    New SqlParameter("@LoggedInUserId", LoggedInUserId)})
    End Function

    Public Function DeleteSite(ByVal siteId As Integer) As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("sites_delete", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            cmd.Connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

#Region "Photos"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPhotoCache(ByVal userHostName As String) As DataTable
        Dim dsCache As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM [ERS_Cache] WHERE HostName = @HostName", connection)
            cmd.Parameters.Add(New SqlParameter("@HostName", userHostName))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsCache)
        End Using

        If dsCache.Tables.Count > 0 Then
            Return dsCache.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedurePhotos(ByVal procedureId As Integer) As DataTable
        Dim dsPhotos As New DataSet
        Dim query As New StringBuilder
        'query.Append("SELECT *, ISNULL(PhotoName + ' - ' + b.SiteDescription, 'No site associated (Attached to the report)') AS PhotoTitle FROM [ERS_Photos] a ")
        query.Append("SELECT *, ISNULL(b.SiteDescription, 'No site associated (Attached to the report)') AS PhotoTitle FROM [ERS_Photos] a ")
        query.Append("LEFT JOIN ")
        query.Append("(SELECT SiteId, ")
        query.Append("  'Site ' + CONVERT(VARCHAR(5), SiteNo) + ")
        query.Append("  ' (' + ")
        query.Append(" CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN 'Anterior/Posterior' END + ")
        query.Append("  ' in ' + r.Region + ")
        query.Append("  ')' AS SiteDescription ")
        query.Append("FROM ERS_Sites s ")
        query.Append("JOIN ERS_Regions r ON s.RegionId = r.RegionId ")
        query.Append("WHERE ProcedureId = @ProcedureId) b ON a.SiteId=b.SiteId ")
        query.Append("WHERE ProcedureId = @ProcedureId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString(), connection)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPhotos)
        End Using

        If dsPhotos.Tables.Count > 0 Then
            Return dsPhotos.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedurePhotosOldUGI(ByVal patientComboId As String, ByVal episodeNo As String) As DataTable
        Dim dsPhotos As New DataSet

        Dim sql As New StringBuilder
        sql.Append("SELECT * FROM [Photos] ")
        sql.Append(" WHERE [Patient No] = @patientComboId ")
        sql.Append(" AND [Episode No] = @episodeNo ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.Parameters.Add(New SqlParameter("@patientComboId", patientComboId))
            cmd.Parameters.Add(New SqlParameter("@episodeNo", episodeNo))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPhotos)
        End Using

        If dsPhotos.Tables.Count > 0 Then
            Return dsPhotos.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSitePhotos(ByVal siteId As Integer, ByVal procedureId As Integer) As DataTable
        Dim dsPhotos As New DataSet
        Dim query As New StringBuilder
        query.Append("IF @SiteId <> 0 ")
        query.Append("SELECT * FROM [ERS_Photos] WHERE SiteId = @SiteId ")
        query.Append("ELSE ")
        query.Append("SELECT * FROM [ERS_Photos] WHERE SiteId IS NULL AND ProcedureId = @ProcedureId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString(), connection)
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPhotos)
        End Using

        If dsPhotos.Tables.Count > 0 Then
            Return dsPhotos.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetPhoto(ByVal photoId As Integer) As DataTable
        Dim dsPhoto As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM [ERS_Photos] WHERE PhotoId = @PhotoId", connection)
            cmd.Parameters.Add(New SqlParameter("@PhotoId", photoId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPhoto)
        End Using

        If dsPhoto.Tables.Count > 0 Then
            Return dsPhoto.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SavePhoto(ByVal cacheId As Integer,
                              ByVal procedureId As Integer,
                              ByVal siteId As Nullable(Of Integer)) As Integer
        Dim sql As New StringBuilder
        sql.Append("INSERT INTO ERS_Photos (PhotoName, PhotoBlob, ProcedureId, SiteId, IncludeInReport)")
        sql.Append("SELECT 'GetADecentName', PhotoBlob, @ProcedureId, @SiteId, 1 ")
        sql.Append("FROM ERS_Cache ")
        sql.Append("WHERE CacheId = @CacheId ")

        sql.Append("UPDATE ERS_Cache ")
        sql.Append("SET Used = 1")
        sql.Append("WHERE CacheId = @CacheId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@CacheId", cacheId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            If siteId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Else
                cmd.Parameters.Add(New SqlParameter("@SiteId", SqlTypes.SqlInt32.Null))
            End If

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Sub SavePhoto(ByVal photoName As String,
                              ByVal procedureId As Integer,
                              ByVal siteId As Nullable(Of Integer),
                              ByVal DateTimeStamp As DateTime)
        Try
            Using db As New ERS.Data.GastroDbEntities
                'insert record
                db.ERS_Photos.Add(New ERS.Data.ERS_Photos() With {
                    .PhotoName = photoName,
                    .ProcedureId = procedureId,
                    .SiteId = siteId,
                    .DateTimeStamp = DateTimeStamp
                })
                db.SaveChanges()
            End Using

            Try
                Using db As New ERS.Data.GastroDbEntities

                    If (CType(Session(Constants.SESSION_PROCEDURE_TYPE), ProcedureType) = ProcedureType.Colonoscopy Or CType(Session(Constants.SESSION_PROCEDURE_TYPE), ProcedureType) = ProcedureType.Sigmoidscopy) And siteId IsNot Nothing Then
                        Dim procedurePhotos = db.ERS_Photos.Where(Function(x) x.SiteId IsNot Nothing And x.ProcedureId = procedureId).ToList()
                        Dim PhotoSiteName = SiteName(siteId)

                        Dim IntubationData = (From ce In db.ERS_ColonExtentOfIntubation Where ce.ProcedureId = procedureId).FirstOrDefault()
                        If Not IntubationData Is Nothing Then

                            If PhotoSiteName.ToLower() = "caecum" Then '1a
                                If Not procedurePhotos.Any(Function(x) x.SiteId = siteId And x.DateTimeStamp < DateTimeStamp) Then 'check if site already has a photo attached and if this ones earlier

                                    If IntubationData.IntubationStartDateTime > CDate("01/01/1901") Then
                                        'calculate ttc
                                        Dim ttc = DateTimeStamp.Subtract(IntubationData.IntubationStartDateTime.Value)
                                        IntubationData.TimeToCaecumMin_Photo = ttc.Minutes
                                        IntubationData.TimeToCaecumSec_Photo = ttc.Seconds

                                        'check wt and recalculate
                                        If IntubationData.TimeForWithdrawalMin_Photo Is Nothing Then
                                            Dim rectumPhoto = (From p In procedurePhotos
                                                               Let ppSiteName = SiteName(p.SiteId)
                                                               Where p.ProcedureId = procedureId And
                                                           ppSiteName.ToLower() = "rectum" Or ppSiteName.ToLower() = "anal margin"
                                                               Order By p.DateTimeStamp Descending).FirstOrDefault()

                                            If rectumPhoto IsNot Nothing Then
                                                Dim wt = rectumPhoto.p.DateTimeStamp.Value.Subtract(DateTimeStamp)
                                                IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                                                IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                                                db.Entry(IntubationData).State = Entity.EntityState.Modified
                                            End If
                                        End If

                                        'update record count for extent
                                        If Not db.ERS_RecordCount.Any(Function(x) x.ProcedureId = procedureId And x.Identifier = "Extent/Limiting factors") Then
                                            db.ERS_RecordCount.Add(New ERS_RecordCount() With {
                                    .ProcedureId = procedureId,
                                    .Identifier = "Extent/Limiting factors",
                                    .RecordCount = 1
                                    })
                                        End If

                                        db.SaveChanges()
                                    End If
                                End If
                            ElseIf PhotoSiteName.ToLower() = "rectum" Or PhotoSiteName.ToLower() = "anal margin" Then '1b
                                If Not procedurePhotos.Any(Function(x) x.SiteId = siteId And x.DateTimeStamp > DateTimeStamp And Not x.PhotoName = photoName) Then 'check if this is the latest rectum photo
                                    'Dim IntubationData = (From ce In db.ERS_ColonExtentOfIntubation Where ce.ProcedureId = procedureId).FirstOrDefault()

                                    'check if ttc via photo recorded and recalculate wt
                                    If IntubationData.TimeToCaecumMin_Photo IsNot Nothing Then
                                        Dim caecumPhoto = (From p In procedurePhotos
                                                           Let ppSiteName = SiteName(p.SiteId)
                                                           Where p.ProcedureId = procedureId And
                                                           ppSiteName.ToLower() = "caecum"
                                                           Order By p.DateTimeStamp).FirstOrDefault()

                                        If caecumPhoto IsNot Nothing Then
                                            Dim wt = DateTimeStamp.Subtract(caecumPhoto.p.DateTimeStamp.Value)
                                            IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                                            IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                                            db.Entry(IntubationData).State = Entity.EntityState.Modified
                                            db.SaveChanges()
                                        End If
                                    End If
                                End If
                            End If
                        End If
                    End If
                End Using
            Catch ex As Exception
                Dim errorRef = LogManager.LogManagerInstance.LogError("Error during auto calculations", ex)
                Throw New AutoCalculationException("There was an error auto calculating you photo timings. Caecum/withdrawal times will need to be done manually.", errorRef)
            End Try
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error during photo save routine", ex)
            Throw ex
        End Try

    End Sub

    Public Function MovePhoto(ByVal photoId As Integer, newSiteId As Integer, procedureId As Integer) As String
        'check if photo needs to do any time calculations
        '1a- if photo attached to caecum check if an initial photo has been set- if yes check if previous image added to caecum- if yes compare time stamp and see if this ones earlier- if yes calculate tts accordingly and update- finially, check for wt, if present recalculate based on attached image to rectum's timestamp
        '1b- if photo attached to rectum check if ttc recorded. If yes check if image already added to rectum- if yes compare timestamps and see if this ones earlier- if yes calculate wt and update
        '1c- check if photo was attached to caecum (if yes check if any _Photo times- BOTH! Needs removing if present)
        '1d- check if photo was attached to rectum (if yes check for withdrawal _Photo times- Needs removing if present)
        Try
            Dim newFileName = ""

            Using db As New ERS.Data.GastroDbEntities
                Dim procedurePhotos = db.ERS_Photos.Where(Function(x) x.ProcedureId = procedureId).ToList()
                Dim photo = procedurePhotos.Where(Function(x) x.PhotoId = photoId).FirstOrDefault()

                Dim newSiteName = SiteName(newSiteId)

                With photo
                    .SiteId = newSiteId
                    .WhoUpdatedId = LoggedInUserId
                    .WhenUpdated = Now
                End With

                'perform update before making any timing changes (if necessary) incase update fails
                db.Entry(photo).State = Entity.EntityState.Modified
                db.SaveChanges()

                Try

                    If CType(Session(Constants.SESSION_PROCEDURE_TYPE), ProcedureType) = ProcedureType.Colonoscopy Then
                        Dim photoOriginalSiteName = If(photo.SiteId.HasValue, SiteName(photo.SiteId), "")
                        Dim IntubationData = (From ce In db.ERS_ColonExtentOfIntubation Where ce.ProcedureId = photo.ProcedureId).FirstOrDefault()
                        If newSiteName.ToLower() = "caecum" Then '1a
                            If Not procedurePhotos.Any(Function(x) (x.SiteId = newSiteId And x.DateTimeStamp < photo.DateTimeStamp)) Then 'check if site already has a photo attached and if this ones earlier
                                If IntubationData.IntubationStartDateTime > CDate("01/01/1901") Then
                                    'calculate ttc
                                    Dim ttc = photo.DateTimeStamp.Value.Subtract(IntubationData.IntubationStartDateTime.Value)
                                    IntubationData.TimeToCaecumMin_Photo = ttc.Minutes
                                    IntubationData.TimeToCaecumSec_Photo = ttc.Seconds

                                    'check wt and recalculate
                                    Dim rectumPhoto = (From p In procedurePhotos
                                                       Let ppSiteName = SiteName(p.SiteId)
                                                       Where ppSiteName.ToLower() = "rectum"
                                                       Order By p.DateTimeStamp Descending).FirstOrDefault()

                                    If rectumPhoto IsNot Nothing Then
                                        Dim wt = rectumPhoto.p.DateTimeStamp.Value.Subtract(photo.DateTimeStamp.Value)
                                        IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                                        IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                                        db.Entry(IntubationData).State = Entity.EntityState.Modified
                                    End If

                                    'update record count for extent
                                    If Not db.ERS_RecordCount.Any(Function(x) x.ProcedureId = procedureId And x.Identifier = "Extent/Limiting factors") Then
                                        db.ERS_RecordCount.Add(New ERS_RecordCount() With {
                                        .ProcedureId = procedureId,
                                        .Identifier = "Extent/Limiting factors",
                                        .RecordCount = 1
                                        })
                                    End If

                                    db.SaveChanges()
                                End If
                            End If
                        ElseIf newSiteName.ToLower() = "rectum" Or newSiteName.ToLower() = "anal margin" Then '1b
                            If Not procedurePhotos.Any(Function(x) (x.SiteId = newSiteId And x.DateTimeStamp > photo.DateTimeStamp)) Then 'check if this is the latest rectum photo
                                'check if ttc via photo recorded and recalculate wt
                                If IntubationData.TimeToCaecumMin_Photo IsNot Nothing Then
                                    Dim caecumPhoto = (From p In procedurePhotos
                                                       Let ppSiteName = SiteName(p.SiteId)
                                                       Where ppSiteName.ToLower() = "caecum"
                                                       Order By p.DateTimeStamp).FirstOrDefault()

                                    If caecumPhoto IsNot Nothing Then
                                        Dim wt = photo.DateTimeStamp.Value.Subtract(caecumPhoto.p.DateTimeStamp.Value)
                                        IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                                        IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                                        db.Entry(IntubationData).State = Entity.EntityState.Modified
                                    Else
                                        'reset tts timestamps. Photo may have originally been there and now moved to here
                                        With IntubationData
                                            .TimeToCaecumMin_Photo = Nothing
                                            .TimeToCaecumSec_Photo = Nothing
                                        End With
                                        db.Entry(IntubationData).State = Entity.EntityState.Modified
                                    End If

                                    db.SaveChanges()
                                End If
                            End If
                        ElseIf photoOriginalSiteName.ToLower() = "caecum" Then '1c
                            If procedurePhotos.Any(Function(x) x.SiteId = photo.SiteId And Not x.PhotoId = photo.PhotoId) Then 'check if site already has a photo attached and if this ones earlier

                                If IntubationData.IntubationStartDateTime > CDate("01/01/1901") Then
                                    'calculate ttc
                                    Dim caecumPhoto = (From p In procedurePhotos
                                                       Let ppSiteName = SiteName(p.SiteId)
                                                       Where ppSiteName.ToLower() = "caecum" And
                                                          Not p.PhotoId = photo.PhotoId
                                                       Order By p.DateTimeStamp).FirstOrDefault()

                                    Dim ttc = caecumPhoto.p.DateTimeStamp.Value.Subtract(IntubationData.IntubationStartDateTime.Value)
                                    IntubationData.TimeToCaecumMin_Photo = ttc.Minutes
                                    IntubationData.TimeToCaecumSec_Photo = ttc.Seconds

                                    'check wt and recalculate
                                    If IntubationData.TimeForWithdrawalMin_Photo IsNot Nothing Then
                                        Dim rectumPhoto = (From p In procedurePhotos
                                                           Let ppSiteName = SiteName(p.SiteId)
                                                           Where ppSiteName.ToLower() = "rectum" And
                                                               Not p.PhotoId = photo.PhotoId
                                                           Order By p.DateTimeStamp Descending).FirstOrDefault()

                                        If rectumPhoto IsNot Nothing Then
                                            Dim wt = rectumPhoto.p.DateTimeStamp.Value.Subtract(caecumPhoto.p.DateTimeStamp.Value)
                                            IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                                            IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                                            db.Entry(IntubationData).State = Entity.EntityState.Modified
                                        End If
                                    End If

                                    'update record count for extent
                                    If Not db.ERS_RecordCount.Any(Function(x) x.ProcedureId = procedureId And x.Identifier = "Extent/Limiting factors") Then
                                        db.ERS_RecordCount.Add(New ERS_RecordCount() With {
                                        .ProcedureId = procedureId,
                                        .Identifier = "Extent/Limiting factors",
                                        .RecordCount = 1
                                        })
                                    End If

                                    db.SaveChanges()
                                End If
                            Else
                                With IntubationData
                                    If .TimeToCaecumMin_Photo IsNot Nothing Or .TimeForWithdrawalMin_Photo IsNot Nothing Then
                                        .TimeToCaecumMin_Photo = Nothing
                                        .TimeToCaecumSec_Photo = Nothing
                                        .TimeForWithdrawalMin_Photo = Nothing
                                        .TimeForWithdrawalSec_Photo = Nothing
                                    End If

                                    db.Entry(IntubationData).State = Entity.EntityState.Modified
                                    db.SaveChanges()
                                End With
                            End If
                        ElseIf photoOriginalSiteName.ToLower() = "rectum" Or photoOriginalSiteName.ToLower() = "anal margin" Then '1d
                            If procedurePhotos.Any(Function(x) x.SiteId = photo.SiteId And Not x.PhotoId = photo.PhotoId) Then 'check if site already has a photo attached and if this ones earlier
                                'check if ttc via photo recorded and recalculate wt
                                If IntubationData.TimeToCaecumMin_Photo IsNot Nothing Then
                                    Dim caecumPhoto = (From p In procedurePhotos
                                                       Let ppSiteName = SiteName(p.SiteId)
                                                       Where ppSiteName.ToLower() = "caecum" And
                                                           Not p.PhotoId = photo.PhotoId
                                                       Order By p.DateTimeStamp).FirstOrDefault()

                                    Dim rectumPhoto = (From p In procedurePhotos
                                                       Let ppSiteName = SiteName(p.SiteId)
                                                       Where ppSiteName.ToLower() = "rectum" And
                                                           Not p.PhotoId = photo.PhotoId
                                                       Order By p.DateTimeStamp Descending).FirstOrDefault()

                                    If rectumPhoto IsNot Nothing Then
                                        Dim wt = rectumPhoto.p.DateTimeStamp.Value.Subtract(caecumPhoto.p.DateTimeStamp.Value)
                                        IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                                        IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                                        db.Entry(IntubationData).State = Entity.EntityState.Modified
                                        db.SaveChanges()
                                    End If
                                End If
                            Else
                                With IntubationData
                                    If .TimeForWithdrawalMin_Photo IsNot Nothing Then
                                        .TimeForWithdrawalMin_Photo = Nothing
                                        .TimeForWithdrawalSec_Photo = Nothing
                                    End If
                                End With

                                db.Entry(IntubationData).State = Entity.EntityState.Modified
                                db.SaveChanges()
                            End If
                        End If
                    End If

                Catch ex As Exception
                    LogManager.LogManagerInstance.LogError("Error during auto calculations", ex)
                    Throw New Exception("There was an error auto calculating you photo timings. Caecum/withdrawal times will need to be done manually.")
                End Try
            End Using

            Return newFileName
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function DeletePhoto(ByVal photoId As Integer, procedureId As Integer) As String
        '1- check if photo was attached to caecum and if photo timings have been recorded- if so check if another photos is attached to caecum and recalculate, otherwise remove ttc and wt timings
        '2- check if photo was attached to rectum and if photo times have been recorded- if so check another photos is attached to rectum and recalculate, otherwise remove wt timings
        Try
            Dim photoName = ""
            Using db As New ERS.Data.GastroDbEntities
                Dim dbRes = (From p In db.ERS_Photos Where p.ProcedureId = procedureId)
                Dim photo = dbRes.Where(Function(x) x.PhotoId = photoId).FirstOrDefault()
                photoName = photo.PhotoName

                'perform update before making any timing changes (if necessary) incase update fails
                db.ERS_Photos.Remove(photo)
                db.SaveChanges()

                Dim procedurePhotos = dbRes.ToList()

                If CType(Session(Constants.SESSION_PROCEDURE_TYPE), ProcedureType) = ProcedureType.Colonoscopy Then
                    Dim photoSiteName = If(photo.SiteId.HasValue, SiteName(photo.SiteId), "")

                    Dim IntubationData = (From ce In db.ERS_ColonExtentOfIntubation Where ce.ProcedureId = photo.ProcedureId).FirstOrDefault()
                    If photoSiteName.ToLower() = "caecum" Then '1
                        If procedurePhotos.Any(Function(x) x.SiteId = photo.SiteId) AndAlso IntubationData.IntubationStartDateTime IsNot Nothing Then 'any other photos attached to the caecum now this ones been detatched and was timings autocalculated?
                            Dim caecumPhotoTimeStamp = (From p In procedurePhotos Where p.SiteId = photo.SiteId Order By p.DateTimeStamp Select p.DateTimeStamp).FirstOrDefault()

                            If caecumPhotoTimeStamp IsNot Nothing Then 'recalculate ttc of remaining caecum photo

                                Dim ttc = caecumPhotoTimeStamp.Value.Subtract(IntubationData.IntubationStartDateTime.Value)
                                IntubationData.TimeToCaecumMin_Photo = ttc.Minutes
                                IntubationData.TimeToCaecumSec_Photo = ttc.Seconds
                            End If

                            'check wt and recalculate
                            If IntubationData.TimeForWithdrawalMin_Photo IsNot Nothing Then
                                Dim rectumPhoto = (From p In procedurePhotos
                                                   Let ppSiteName = SiteName(p.SiteId)
                                                   Where ppSiteName.ToLower() = "rectum"
                                                   Order By p.DateTimeStamp Descending).FirstOrDefault()

                                If rectumPhoto IsNot Nothing Then
                                    Dim wt = rectumPhoto.p.DateTimeStamp.Value.Subtract(photo.DateTimeStamp.Value)
                                    IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                                    IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                                    db.Entry(IntubationData).State = Entity.EntityState.Modified

                                End If

                                db.SaveChanges()
                            End If
                        Else
                            With IntubationData
                                If .TimeToCaecumMin_Photo IsNot Nothing Or .TimeForWithdrawalMin_Photo IsNot Nothing Then
                                    .TimeToCaecumMin_Photo = Nothing
                                    .TimeToCaecumSec_Photo = Nothing
                                    .TimeForWithdrawalMin_Photo = Nothing
                                    .TimeForWithdrawalSec_Photo = Nothing
                                End If

                                db.Entry(IntubationData).State = Entity.EntityState.Modified
                                db.SaveChanges()
                            End With
                        End If
                    ElseIf photoSiteName.ToLower() = "rectum" Then '2
                        If procedurePhotos.Any(Function(x) x.SiteId = photo.SiteId) AndAlso IntubationData.IntubationStartDateTime IsNot Nothing Then 'any other photos attached to the rectum now this ones been detatched and was timings autocalculated?
                            'get caecum pics timestamp for wt's recalculation
                            Dim caecumPhotoTimeStamp = (From p In procedurePhotos
                                                        Where SiteName(p.SiteId).ToLower() = "caecum"
                                                        Order By p.DateTimeStamp
                                                        Select p.DateTimeStamp).FirstOrDefault()

                            Dim rectumPhotoTimeStamp = (From p In procedurePhotos
                                                        Where SiteName(p.SiteId).ToLower() = "rectum"
                                                        Order By p.DateTimeStamp Descending
                                                        Select p.DateTimeStamp).FirstOrDefault()

                            'calculate wt
                            Dim wt = rectumPhotoTimeStamp.Value.Subtract(caecumPhotoTimeStamp.Value)
                            IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                            IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                            db.Entry(IntubationData).State = Entity.EntityState.Modified
                            db.SaveChanges()
                        Else
                            With IntubationData
                                If .TimeForWithdrawalMin_Photo IsNot Nothing Then
                                    .TimeForWithdrawalMin_Photo = Nothing
                                    .TimeForWithdrawalSec_Photo = Nothing
                                End If
                            End With

                            db.Entry(IntubationData).State = Entity.EntityState.Modified
                            db.SaveChanges()
                        End If
                    End If
                End If
            End Using

            Return photoName
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function DeletePhotoFromCache(ByVal cacheId As Integer) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("DELETE FROM ERS_Cache WHERE CacheId = @CacheId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@CacheId", cacheId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

#Region "OtherAbnormalities"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllOtherAbno() As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("OtherAbnormalities_select", connection)
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

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Protected Sub UpdateInsertOtherAbno(CancelReasonId As Integer, Code As String, Detail As String, CancelledByHospital As Boolean, Active As Boolean, UserId As Integer)

        InsertUpdateOtherAbno(Code, Detail, CancelledByHospital, Active, UserId, CancelReasonId)

    End Sub
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Protected Sub InsertNewOtherAbno(Code As String, Detail As String, CancelledByHospital As Boolean, Active As Boolean, UserId As Integer)

        InsertUpdateOtherAbno(Code, Detail, CancelledByHospital, Active, UserId)

    End Sub

    Public Sub InsertUpdateOtherAbno(Abnormality As String, Summary As String, Diagnoses As Boolean, Active As Boolean, UserId As Integer, Optional OtherId As Integer = 0)

        DataAccess.ExecuteScalerSQL("OtherAbnormalities_insert_update", CommandType.StoredProcedure, New SqlParameter() {
                                                New SqlParameter("@OtherId", OtherId),
                                                New SqlParameter("@Abnormality", Abnormality),
                                                New SqlParameter("@Summary", Summary),
                                                New SqlParameter("@Diagnoses", Diagnoses),
                                                New SqlParameter("@Active", Active),
                                                New SqlParameter("@UserId", UserId)})

    End Sub

#End Region


    'TODO - REVAMP THIS - CREATE A NEW AUDITLOG TABLE FOR ERS
    'Public Sub WriteAuditLog(ByVal appID As APP_ID_ENUM, _
    '                         ByVal eventType As EVENT_TYPE_ENUM, _
    '                         ByVal eventDesc As String, _
    '                         ByVal appVersion As String, _
    '                         ByVal userId As String, _
    '                         ByVal userFullName As String, _
    '                         ByVal hospitalId As String, _
    '                         ByVal operatingHospitalId As String, _
    '                         ByVal hospitalName As String, _
    '                         ByVal patientId As String, _
    '                         ByVal episodeNo As String, _
    '                         ByVal caseNoteNo As String)

    '    Dim Category As Integer = vbNull

    '    Select Case eventType
    '        Case EVENT_TYPE_ENUM.EventNewRec, EVENT_TYPE_ENUM.EventUpdateRec, EVENT_TYPE_ENUM.EventDeleteRec, EVENT_TYPE_ENUM.EventDownload, EVENT_TYPE_ENUM.EventConfig, EVENT_TYPE_ENUM.EventDatabase
    '            Category = 1 'CategoryApp
    '        Case EVENT_TYPE_ENUM.EventSearch, EVENT_TYPE_ENUM.EventReports, EVENT_TYPE_ENUM.EventView, EVENT_TYPE_ENUM.EventPrint, EVENT_TYPE_ENUM.EventExport
    '            Category = 2 'CategoryInfo
    '        Case EVENT_TYPE_ENUM.EventLogIn, EVENT_TYPE_ENUM.EventLogOut
    '            Category = 3 'CategorySecurity
    '    End Select

    '    Dim EpiNo As Long = vbNull

    '    Dim AuditDate As String = vbNullString
    '    Dim EpiDate As String = vbNullString

    '    AuditDate = Format(Now(), "yyyy-MM-dd HH:mm:ss")
    '    EpiDate = Format(Now(), "yyyy-MM-dd")

    '    Dim sSQL As String = vbNullString
    '    sSQL = "INSERT INTO [AuditLog] (" & _
    '      "[Category], [Event Type], [Date], [ApplicationID], [App Version], [UserID], " & _
    '      "[Full Username], [StationID], [HospitalID], [Hospital Name], " & _
    '      "[OperatingID], [Operating Name], [Patient No], [Proc Episode No], " & _
    '      "[Case note no], [Procedure Date], [Procedure Time], [Procedure Name], " & _
    '      "[Event Description]) VALUES (" & _
    '      Category & "," & eventType & ",'" & AuditDate & "','" & appID & "','" & appVersion & "','" & userId & "','" & _
    '      Utilities.FixString(userFullName) & "','UKN'," & hospitalId & ",'" & Utilities.FixString(hospitalName) & "'," & _
    '      operatingHospitalId & ",'" & Utilities.FixString(hospitalName) & "','" & patientId & "'," & episodeNo & ",'" & _
    '      caseNoteNo & "','" & EpiDate & "','" & Format(Now(), "HH:mm:ss") & "','Upper GI','" & _
    '      Utilities.FixString(eventDesc) & "');"

    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand(sSQL, connection)
    '        cmd.CommandType = CommandType.Text

    '        connection.Open()
    '        cmd.ExecuteNonQuery()
    '    End Using
    'End Sub

    'TODO - REVAMP THIS - CREATE A NEW AUDITLOG TABLE FOR ERS
    Public Function GetAuditLog(ByVal categoryId As Integer) As DataTable
        Dim dsAuditLog As New DataSet
        Dim sSQL As String
        sSQL = "SELECT [Event Type] AS Event_Type, [Date], [Full Username] AS Full_Username, [StationID], [Event Description] AS Event_Description FROM [AuditLog]"
        If categoryId <> 0 Then
            sSQL = sSQL & " WHERE [Category] = " & categoryId
        End If
        sSQL = sSQL & " ORDER BY [Date] DESC"

        Return DataAccess.ExecuteSQL(sSQL, Nothing)

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateInstrument(ByVal Instrument1 As Integer, ByVal Instrument1NewItemText As String, ByVal Instrument2 As Integer, ByVal Instrument2NewItemText As String, ByVal InstrumentTxt As String, ByVal ProcedureId As Integer, ByVal ProcedureTypeId As Integer) As Integer
        Dim sql As New StringBuilder
        Dim listDescription As String = String.Empty

        If ProcedureTypeId = ProcedureType.Gastroscopy Then
            listDescription = "Instrument Upper GI"
        ElseIf ProcedureTypeId = ProcedureType.ERCP Then
            listDescription = "Instrument ERCP"
        ElseIf ProcedureTypeId = ProcedureType.Colonoscopy Or ProcedureTypeId = ProcedureType.Sigmoidscopy Or ProcedureTypeId = ProcedureType.Proctoscopy Then
            listDescription = "Instrument ColonSig"
        ElseIf ProcedureTypeId = ProcedureType.EUS_OGD Or ProcedureType.EUS_HPB Then
            listDescription = "Instrument EUS"
        ElseIf ProcedureTypeId = ProcedureType.Antegrade Then
            listDescription = "Instrument Antegrade"
        ElseIf ProcedureTypeId = ProcedureType.Retrograde Then
            listDescription = "Instrument Retrograde"
        ElseIf ProcedureTypeId = ProcedureType.Bronchoscopy Or ProcedureType.EBUS Or ProcedureType.Thoracoscopy Then
            listDescription = "Instrument Thoracic"
        End If

        If Instrument1 = -99 Then
            Dim newId = InsertInstrument(Instrument1NewItemText)
            If newId > 0 Then
                Instrument1 = newId
            End If
        End If

        If Instrument2 = -99 Then
            Dim newId = InsertInstrument(Instrument2NewItemText)
            If newId > 0 Then
                Instrument2 = newId
            End If
            'Dim da As New DataAccess
            'Dim newId = da.InsertListItem(listDescription, Instrument2NewItemText)
            'If newId > 0 Then
            '    Instrument2 = newId
            'End If
        End If

        Try
            '### Update the PP Text Values in Reporting Table!
            Using db As New ERS.Data.GastroDbEntities
                Dim pr = db.ERS_ProceduresReporting.Find(ProcedureId)
                pr.PP_Instrument = InstrumentTxt
                db.SaveChanges()
            End Using
        Catch ex As Exception
            '## On Error Resume next.. Don't make any sound!! Just swalloooooow!!!
        End Try

        sql.Append("UPDATE ERS_Procedures ")
        sql.Append("SET Instrument1=@Instrument1, Instrument2=@Instrument2 ")
        sql.Append("WHERE ProcedureId=@ProcedureId")

        Return DataAccess.ExecuteScalerSQL(sql.ToString(), CommandType.Text, New SqlParameter() _
                                    {New SqlParameter("@Instrument1", Instrument1),
                                     New SqlParameter("@Instrument2", Instrument2),
                                     New SqlParameter("@InstrumentTxt", InstrumentTxt),
                                     New SqlParameter("@ProcedureId", ProcedureId)})

    End Function

    Private Function InsertInstrument(ByVal ScopeName As String) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("INSERT INTO [dbo].[ERS_Scopes] ([ScopeName],[AllProcedureTypes],[HospitalId],[WhoCreatedId],[WhoUpdatedId]) 
                    VALUES (@ScopeName, 0, @HospitalId, @WhoCreatedId, @WhoUpdatedId); 
                    DECLARE @ScopeID INT = SCOPE_IDENTITY();
                    INSERT INTO [dbo].[ERS_ScopeProcedures] ([ScopeId],[ProcedureTypeId],[WhoCreatedId],[WhoUpdatedId]) 
                    VALUES (@ScopeID, @ProcedureType, @WhoCreatedId, @WhoUpdatedId);SELECT @ScopeID;", connection)
            cmd.Parameters.Add(New SqlParameter("@ScopeName", ScopeName))
            cmd.Parameters.Add(New SqlParameter("@HospitalId", CInt(Session("OperatingHospitalId"))))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE))))
            cmd.Parameters.Add(New SqlParameter("@WhoCreatedId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@WhoUpdatedId", LoggedInUserId))

            Try
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                Return CInt(cmd.ExecuteScalar())
            Catch ex As Exception
                Throw ex
            End Try

            Return 0

        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateProcedureField(ByVal FieldName As String, ByVal Value As Boolean, ByVal ProcedureId As Integer) As Integer
        Dim sql As New StringBuilder

        sql.Append("UPDATE ERS_Procedures ")
        sql.Append("SET " & FieldName & " = @Value ")
        sql.Append("WHERE ProcedureId=@ProcedureId")

        Return DataAccess.ExecuteScalerSQL(sql.ToString(), CommandType.Text, New SqlParameter() _
                            {New SqlParameter("@ProcedureId", ProcedureId),
                             New SqlParameter("@Value", Value)})

    End Function

#Region "Premedication Drugs Settings"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPremedicationDrugs(ops As Integer) As DataTable
        Dim dsPatients As New DataSet
        Dim sql As String
        If ops = 1 Then
            sql = "SELECT [DrugNo] as DrugNo,[DrugName] as Name,[Units] as Unit,[DeliveryMethod] as Delivery FROM [ERS_DrugList] WHERE [DrugType] = 1 ORDER BY DrugName"
        Else
            sql = "SELECT [DrugNo] as DrugNo,[DrugName] as Name,[Units] as Unit,[DeliveryMethod] as Delivery FROM [ERS_DrugList] WHERE [DrugType] = 0 ORDER BY DrugName"
        End If

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPatients)
        End Using

        If dsPatients.Tables.Count > 0 Then
            Return dsPatients.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDrug(ByVal DrugID As Integer) As DataTable
        Dim dsDrug As New DataSet
        Dim sql As String = "SELECT [DrugNo] as DrugNo,[DrugName] as DrugName,[DrugType],[IsReversingAgent] as Isreversingagent,[Units] as Units," &
                " [DefaultDose] as Defaultdose,[DoseIncrement] as Doseincrement,[DeliveryMethod] as Deliverymethod ,[UsedinColonSig] as UsedinColonSig," &
                " [UsedinERCP] as UsedinERCP ,[UsedinUpperGI] as UsedinUpperGI,[UsedinEUS_OGD] as UsedinEUSOGD,[UsedinEUS_HPB] as UsedinEUSHPB, " &
                " ISNULL(DoseNotApplicable,0) as DoseNotApplicable, ISNULL([UsedInBroncho], 0) as UsedInBroncho, " &
                " ISNULL([UsedInAntegrade], 0) as UsedInAntegrade,  ISNULL([UsedInRetrograde], 0) as UsedInRetrograde FROM [ERS_DrugList] WHERE [DrugNo] = @DrugNo"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugID))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsDrug)
        End Using
        If dsDrug.Tables.Count > 0 Then
            Return dsDrug.Tables(0)
        Else
            Return Nothing
        End If

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertDrug(DrugNo As Int32, DrugName As String, DrugType As Int32, Isreversingagent As Int32, Units As String, DoseNotApplicable As Boolean,
                               Defaultdose As Double, Doseincrement As Double, Deliverymethod As String, UsedinUpperGI As Int32, UsedinEUSOGD As Int32, UsedinERCP As Int32,
                               UsedinEUSHPB As Int32, UsedinColonSig As Int32, UsedinBroncho As Int32, UsedInAntegrade As Int32, UsedInRetrograde As Int32) As Integer

        Dim dsDrug As New DataSet
        Dim sql As String = "INSERT INTO [ERS_DrugList] ([ProductID],[LocationID],[DrugType],[DrugName],[DeliveryMethod],[Units],[DefaultDose],[DoseIncrement],[UsedinColonSig],[UsedinERCP],[UsedinUpperGI],[Isreversingagent],[UsedinEUS_OGD],[UsedinEUS_HPB],DoseNotApplicable, [UsedInBroncho], [UsedInAntegrade], [UsedInRetrograde], WhoCreatedId, WhenCreated) " &
                        "VALUES ('GI','XXXX',@Drugtype,@Drugname,@Deliverymethod,@Units,@Defaultdose,@Doseincrement,@UsedinColonSig,@UsedinERCP,@UsedinUpperGI,@Isreversingagent,@UsedinEUSOGD,@UsedinEUSHPB,@DoseNotApplicable,@UsedInBroncho, @UsedInAntegrade, @UsedInRetrograde, @LoggedInUserId, GETDATE()) " &
                        "SELECT @@identity "
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
            cmd.Parameters.Add(New SqlParameter("@Drugtype", DrugType))
            cmd.Parameters.Add(New SqlParameter("@Drugname", DrugName))
            cmd.Parameters.Add(New SqlParameter("@Isreversingagent", Isreversingagent))
            If String.IsNullOrWhiteSpace(Units) Then
                cmd.Parameters.Add(New SqlParameter("@Units", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@Units", Units))
            End If
            cmd.Parameters.Add(New SqlParameter("@Defaultdose", Defaultdose))
            cmd.Parameters.Add(New SqlParameter("@Doseincrement", Doseincrement))
            cmd.Parameters.Add(New SqlParameter("@Deliverymethod", Deliverymethod))
            cmd.Parameters.Add(New SqlParameter("@UsedinUpperGI", UsedinUpperGI))
            cmd.Parameters.Add(New SqlParameter("@UsedinEUSOGD", UsedinEUSOGD))
            cmd.Parameters.Add(New SqlParameter("@UsedinERCP", UsedinERCP))
            cmd.Parameters.Add(New SqlParameter("@UsedinEUSHPB", UsedinEUSHPB))
            cmd.Parameters.Add(New SqlParameter("@UsedinBroncho", UsedinBroncho))
            cmd.Parameters.Add(New SqlParameter("@UsedinColonSig", UsedinColonSig))
            cmd.Parameters.Add(New SqlParameter("@UsedInAntegrade", UsedInAntegrade))
            cmd.Parameters.Add(New SqlParameter("@UsedInRetrograde", UsedInRetrograde))
            cmd.Parameters.Add(New SqlParameter("@DoseNotApplicable", DoseNotApplicable))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateDrug(DrugNo As Int32,
                              Drugname As String, DrugType As Int32, Isreversingagent As Int32, Units As String, DoseNotApplicable As Boolean,
                               Defaultdose As Double, Doseincrement As Double, Deliverymethod As String, UsedinUpperGI As Int32, UsedinEUSOGD As Int32, UsedinERCP As Int32,
                               UsedinEUSHPB As Int32, UsedinColonSig As Int32, UsedinBroncho As Int32, UsedInAntegrade As Int32, UsedInRetrograde As Int32) As Integer

        ' Ideally, the db column ERS_DrugList.Deliverymethod must be an integer connecting to the value from ERS_Lists. 
        ' But this is a varchar field. So check for the value in the ERS_Lists table, insert if not found.
        Dim dtDeliveryMethods As DataTable = GetDeliveryMethods()
        Dim matches = From r In dtDeliveryMethods.AsEnumerable()
                      Where r.Field(Of String)("ListItemText") = Deliverymethod
                      Select r
        If matches.Count = 0 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Premedication Delivery Method", Deliverymethod)
        End If

        Dim dsDrug As New DataSet
        Dim sql As String

        sql = "UPDATE [ERS_DrugList] SET [DrugType] = @Drugtype,  [DrugName] = @Drugname,  [DeliveryMethod] = @Deliverymethod, [Units]=@Units, [DefaultDose]=@Defaultdose, DoseNotApplicable = @DoseNotApplicable," &
        " [DoseIncrement] = @Doseincrement,  [UsedinColonSig] = @UsedinColonSig,   [UsedinERCP]=@UsedinERCP,  [UsedinUpperGI] = @UsedinUpperGI, [Isreversingagent]=@Isreversingagent, [UsedinEUS_OGD]=@UsedinEUSOGD," &
        " [UsedinEUS_HPB]=@UsedinEUSHPB, [UsedInBroncho]=@UsedInBroncho, [UsedInAntegrade]=@UsedInAntegrade, [UsedInRetrograde]=@UsedInRetrograde, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE [DrugNo]=@DrugNo"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
            cmd.Parameters.Add(New SqlParameter("@Drugtype", DrugType)) ' set to zero
            cmd.Parameters.Add(New SqlParameter("@Drugname", Drugname))
            cmd.Parameters.Add(New SqlParameter("@Isreversingagent", Isreversingagent))

            If Not String.IsNullOrEmpty(Units) Then
                cmd.Parameters.Add(New SqlParameter("@Units", Units))
            Else
                cmd.Parameters.Add(New SqlParameter("@Units", SqlTypes.SqlString.Null))
            End If

            If Not String.IsNullOrEmpty(Deliverymethod) Then
                cmd.Parameters.Add(New SqlParameter("@Deliverymethod", Deliverymethod))
            Else
                cmd.Parameters.Add(New SqlParameter("@Deliverymethod", SqlTypes.SqlString.Null))
            End If
            'cmd.Parameters.Add(New SqlParameter("@Units", Units))
            cmd.Parameters.Add(New SqlParameter("@Defaultdose", Defaultdose))
            cmd.Parameters.Add(New SqlParameter("@Doseincrement", Doseincrement))
            'cmd.Parameters.Add(New SqlParameter("@Deliverymethod", Deliverymethod))
            cmd.Parameters.Add(New SqlParameter("@UsedinUpperGI", UsedinUpperGI))
            cmd.Parameters.Add(New SqlParameter("@UsedinEUSOGD", UsedinEUSOGD))
            cmd.Parameters.Add(New SqlParameter("@UsedinERCP", UsedinERCP))
            cmd.Parameters.Add(New SqlParameter("@UsedinEUSHPB", UsedinEUSHPB))
            cmd.Parameters.Add(New SqlParameter("@UsedinColonSig", UsedinColonSig))
            cmd.Parameters.Add(New SqlParameter("@UsedinBroncho", UsedinBroncho))
            cmd.Parameters.Add(New SqlParameter("@UsedInAntegrade", UsedInAntegrade))
            cmd.Parameters.Add(New SqlParameter("@UsedInRetrograde", UsedInRetrograde))
            cmd.Parameters.Add(New SqlParameter("@DoseNotApplicable", DoseNotApplicable))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

#Region "Regime"
    Public Function GetRegime(ByVal RegimeName As String) As Integer
        Dim value As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT TOP(1) RegimenNo FROM ERS_DrugRegime WHERE Description = @RegimeName"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@RegimeName", RegimeName))
            connection.Open()
            value = mycmd.ExecuteScalar()
        End Using
        Return value
    End Function
    Public Function GetMaxReg() As Integer
        Dim value As Integer = 1
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT ISNULL(MAX(RegimenNo), 1) FROM ERS_DrugRegime"
            Dim mycmd As New SqlCommand(querystr, connection)
            connection.Open()
            value = mycmd.ExecuteScalar()
        End Using
        Return value
    End Function
    Public Function SaveRegime(RegimenNo As Integer, Description As String, ProcedureNo As Integer, DrugNo As Integer, DrugDose As Double, Frequency As String, Duration As String, DrugCount As Integer, RegimeText As String) As Integer
        Dim sql As String = "INSERT INTO ERS_DrugRegime (RegimenNo, Description, ProcedureNo, DrugNo, DrugDose, Frequency, Duration, DrugCount, RegimeText)  VALUES (@RegimenNo, @Description, @ProcedureNo, @DrugNo, @DrugDose, @Frequency, @Duration, @DrugCount, @RegimeText) "
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RegimenNo", RegimenNo))
            'cmd.Parameters.Add(New SqlParameter("@Drugtype", Drugtype))
            cmd.Parameters.Add(New SqlParameter("@Description", Description))
            cmd.Parameters.Add(New SqlParameter("@ProcedureNo", ProcedureNo))
            cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
            cmd.Parameters.Add(New SqlParameter("@DrugDose", DrugDose))
            cmd.Parameters.Add(New SqlParameter("@Frequency", Frequency))
            cmd.Parameters.Add(New SqlParameter("@Duration", Duration))
            cmd.Parameters.Add(New SqlParameter("@DrugCount", DrugCount))
            cmd.Parameters.Add(New SqlParameter("@RegimeText", RegimeText))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function
    Public Function DeleteRegime(DescriptionText As String) As Integer
        Dim sql As String = "DELETE FROM ERS_DrugRegime WHERE [Description] = @DescriptionText"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DescriptionText", DescriptionText))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function LoadRegimeData(ByVal regimeID As Integer) As DataTable
        Dim dsResult As New DataSet
        Dim sql As String = "SELECT RegimenNo, Description, ProcedureNo, DrugNo, DrugDose, Frequency, Duration, DrugCount, RegimeText FROM ERS_DrugRegime WHERE RegimenNo = @RegimeNo  "
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RegimeNo", regimeID))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function SavePrescription(ProcedureNo As Integer, DrugCount As Integer, DrugNo As Integer, DrugDose As Double, Frequency As String, Duration As String, HPyloriDrug As Boolean, WhoPrescribed As String, AuthenticationDate As Date, AuthenticatedBy As String) As Integer

        ' Ideally, the db column ERS_PatientMedication.Frequency must be an integer connecting to the value from ERS_Lists. 
        ' But this is a varchar field. So check for the value in the ERS_Lists table, insert if not found.
        Dim dtFrequency As DataTable = GetMedicationFrequency()
        Dim matches = From r In dtFrequency.AsEnumerable()
                      Where r.Field(Of String)("ListItemText") = Frequency
                      Select r
        If matches.Count = 0 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Medication_Frequency", Frequency)
        End If

        Dim sql As String = "INSERT INTO [ERS_PatientMedication] ([ProcedureNo],[DrugCount],[DrugNo],[DrugDose],[Frequency],[Duration],[HPyloriDrug],[WhoPrescribed],[AuthenticationDate],[AuthenticatedBy],[WhoCreatedId],[WhenCreated])  VALUES (@ProcedureNo,@DrugCount,@DrugNo,@DrugDose,@Frequency,@Duration,@HPyloriDrug,@WhoPrescribed,@AuthenticationDate,@AuthenticatedBy,@LoggedInUserId,GETDATE()) "
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureNo", ProcedureNo))
            cmd.Parameters.Add(New SqlParameter("@DrugCount", DrugCount))
            cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
            cmd.Parameters.Add(New SqlParameter("@DrugDose", DrugDose))
            cmd.Parameters.Add(New SqlParameter("@Frequency", Frequency))
            cmd.Parameters.Add(New SqlParameter("@Duration", Duration))
            cmd.Parameters.Add(New SqlParameter("@HPyloriDrug", HPyloriDrug))
            cmd.Parameters.Add(New SqlParameter("@WhoPrescribed", WhoPrescribed))
            If AuthenticationDate = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AuthenticationDate", .SqlDbType = SqlDbType.Date, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AuthenticationDate", .SqlDbType = SqlDbType.Date, .Value = AuthenticationDate})
            End If
            If AuthenticatedBy = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AuthenticatedBy", .SqlDbType = SqlDbType.VarChar, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AuthenticatedBy", .SqlDbType = SqlDbType.VarChar, .Value = AuthenticatedBy})
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    Public Function LoadPrescriptionData(ByVal ProcedureNo As Integer, WhoPrescribed As String) As DataTable
        Dim dsResult As New DataSet
        Dim sql As String = "SELECT dbo.fnCapitalise(l.drugname+'#'+cast(m.DrugDose as varchar(50))+'#'+ISNULL(l.units,'')+'#'+ ISNULL(l.deliverymethod,'')+'#'+m.Frequency+'#'+m.Duration+'#'+cast(l.doseincrement as varchar(50))+'#'+cast(m.DrugNo as varchar(50))) as [text] FROM [dbo].[ERS_PatientMedication] m left join [ERS_DrugList] l on m.[DrugNo] =l.[DrugNo] WHERE m.ProcedureNo = @ProcedureNO AND m.WhoPrescribed = @WhoPrescribed"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureNo", ProcedureNo))
            cmd.Parameters.Add(New SqlParameter("@WhoPrescribed", WhoPrescribed))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function DeletePrescription(ByVal ProcedureNo As Integer, WhoPrescribed As String) As Integer
        Dim sql As String = "DELETE FROM ERS_PatientMedication WHERE ProcedureNo = @ProcedureNO AND WhoPrescribed = @WhoPrescribed"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureNo", ProcedureNo))
            cmd.Parameters.Add(New SqlParameter("@WhoPrescribed", WhoPrescribed))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

#Region "Print Options"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintOptions(opertingHospitalId As Integer) As DataSet
        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("SELECT * FROM ERS_PrintOptionsGPReport WHERE OperatingHospitalId = @OperatingHospitalId ")
        qry.Append("SELECT * FROM ERS_PrintOptionsLabRequestReport WHERE OperatingHospitalId = @OperatingHospitalId ")
        qry.Append("SELECT * FROM ERS_PrintOptionsPatientFriendlyReport WHERE OperatingHospitalId = @OperatingHospitalId ")
        qry.Append("SELECT * FROM ERS_PrintOptionsPatientFriendlyReportAdditional WHERE OperatingHospitalId = @OperatingHospitalId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", opertingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsProcedures)
        End Using

        If dsProcedures.Tables.Count > 0 Then
            Return dsProcedures
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintOptionsPatientFriendlyReportAdditional(Optional ByVal OperatingHospitalId As Integer = 0, Optional ByVal includedOnly As Boolean = False) As DataTable
        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("SELECT AdditionalText FROM ERS_PrintOptionsPatientFriendlyReportAdditional ")
        If includedOnly Then
            qry.Append(" WHERE IncludeAdditionalText = 1 ")
        End If
        'qry.Append("WHERE OperatingHospitalID = " & CStr(OperatingHospitalId))
        'If includedOnly Then
        '    qry.Append(" AND IncludeAdditionalText = 1 ")
        'End If

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsProcedures)
        End Using

        If dsProcedures.Tables.Count > 0 Then
            Return dsProcedures.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SaveGPReportPrintOptions(ByVal IncludeDiagram As Boolean,
                                             ByVal IncludeDiagramOnlyIfSitesExist As Boolean,
                                             ByVal IncludeListConsultant As Boolean,
                                             ByVal IncludeNurses As Boolean,
                                             ByVal IncludeInstrument As Boolean,
                                             ByVal IncludeMissingCaseNote As Boolean,
                                             ByVal IncludeIndications As Boolean,
                                             ByVal IncludeCoMorbidities As Boolean,
                                             ByVal IncludePlannedProcedures As Boolean,
                                             ByVal IncludePremedication As Boolean,
                                             ByVal IncludeProcedureNotes As Boolean,
                                             ByVal IncludeSiteNotes As Boolean,
                                             ByVal IncludeBowelPreparation As Boolean,
                                             ByVal IncludeExtentOfIntubation As Boolean,
                                             ByVal IncludePreviousGastricUlcer As Boolean,
                                             ByVal IncludeExtentAndLimitingFactors As Boolean,
                                             ByVal IncludeCannulation As Boolean,
                                             ByVal IncludeExtentOfVisualisation As Boolean,
                                             ByVal IncludeContrastMediaUsed As Boolean,
                                             ByVal IncludePapillaryAnatomy As Boolean,
                                             ByVal IncludeDiagnoses As Boolean,
                                             ByVal IncludeFollowUp As Boolean,
                                             ByVal IncludeTherapeuticProcedures As Boolean,
                                             ByVal IncludeSpecimensTaken As Boolean,
                                             ByVal IncludePeriOperativeComplications As Boolean,
                                             ByVal DefaultNumberOfCopies As Integer,
                                             ByVal DefaultNumberOfPhotos As Integer,
                                             ByVal DefaultPhotoSize As Integer,
                                             ByVal OperatingHospitalId As Integer) As Integer

        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("UPDATE ERS_PrintOptionsGPReport SET ")
        qry.Append("IncludeDiagram = @IncludeDiagram")
        qry.Append(",IncludeDiagramOnlyIfSitesExist = @IncludeDiagramOnlyIfSitesExist")
        qry.Append(",IncludeListConsultant = @IncludeListConsultant")
        qry.Append(",IncludeNurses = @IncludeNurses")
        qry.Append(",IncludeInstrument = @IncludeInstrument")
        qry.Append(",IncludeMissingCaseNote = @IncludeMissingCaseNote")
        qry.Append(",IncludeIndications = @IncludeIndications")
        qry.Append(",IncludeCoMorbidities = @IncludeCoMorbidities")
        qry.Append(",IncludePlannedProcedures = @IncludePlannedProcedures")
        qry.Append(",IncludePremedication = @IncludePremedication")
        qry.Append(",IncludeProcedureNotes = @IncludeProcedureNotes")
        qry.Append(",IncludeSiteNotes = @IncludeSiteNotes")
        qry.Append(",IncludeBowelPreparation = @IncludeBowelPreparation")
        qry.Append(",IncludeExtentOfIntubation = @IncludeExtentOfIntubation")
        qry.Append(",IncludePreviousGastricUlcer = @IncludePreviousGastricUlcer")
        qry.Append(",IncludeExtentAndLimitingFactors = @IncludeExtentAndLimitingFactors")
        qry.Append(",IncludeCannulation = @IncludeCannulation")
        qry.Append(",IncludeExtentOfVisualisation = @IncludeExtentOfVisualisation")
        qry.Append(",IncludeContrastMediaUsed = @IncludeContrastMediaUsed")
        qry.Append(",IncludePapillaryAnatomy = @IncludePapillaryAnatomy")
        qry.Append(",IncludeDiagnoses = @IncludeDiagnoses")
        qry.Append(",IncludeFollowUp = @IncludeFollowUp")
        qry.Append(",IncludeTherapeuticProcedures = @IncludeTherapeuticProcedures")
        qry.Append(",IncludeSpecimensTaken = @IncludeSpecimensTaken")
        qry.Append(",IncludePeriOperativeComplications = @IncludePeriOperativeComplications")
        qry.Append(",DefaultNumberOfCopies = @DefaultNumberOfCopies")
        qry.Append(",DefaultNumberOfPhotos = @DefaultNumberOfPhotos")
        qry.Append(",DefaultPhotoSize = @DefaultPhotoSize")
        qry.Append(",WhoUpdatedId = @LoggedInUserId")
        qry.Append(",WhenUpdated = GETDATE()")
        qry.Append(" WHERE OperatingHospitalId = @OperatingHospitalId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@IncludeDiagram", IncludeDiagram))
            cmd.Parameters.Add(New SqlParameter("@IncludeDiagramOnlyIfSitesExist", IncludeDiagramOnlyIfSitesExist))
            cmd.Parameters.Add(New SqlParameter("@IncludeListConsultant", IncludeListConsultant))
            cmd.Parameters.Add(New SqlParameter("@IncludeNurses", IncludeNurses))
            cmd.Parameters.Add(New SqlParameter("@IncludeInstrument", IncludeInstrument))
            cmd.Parameters.Add(New SqlParameter("@IncludeMissingCaseNote", IncludeMissingCaseNote))
            cmd.Parameters.Add(New SqlParameter("@IncludeIndications", IncludeIndications))
            cmd.Parameters.Add(New SqlParameter("@IncludeCoMorbidities", IncludeCoMorbidities))
            cmd.Parameters.Add(New SqlParameter("@IncludePlannedProcedures", IncludePlannedProcedures))
            cmd.Parameters.Add(New SqlParameter("@IncludePremedication", IncludePremedication))
            cmd.Parameters.Add(New SqlParameter("@IncludeProcedureNotes", IncludeProcedureNotes))
            cmd.Parameters.Add(New SqlParameter("@IncludeSiteNotes", IncludeSiteNotes))
            cmd.Parameters.Add(New SqlParameter("@IncludeBowelPreparation", IncludeBowelPreparation))
            cmd.Parameters.Add(New SqlParameter("@IncludeExtentOfIntubation", IncludeExtentOfIntubation))
            cmd.Parameters.Add(New SqlParameter("@IncludePreviousGastricUlcer", IncludePreviousGastricUlcer))
            cmd.Parameters.Add(New SqlParameter("@IncludeExtentAndLimitingFactors", IncludeExtentAndLimitingFactors))
            cmd.Parameters.Add(New SqlParameter("@IncludeCannulation", IncludeCannulation))
            cmd.Parameters.Add(New SqlParameter("@IncludeExtentOfVisualisation", IncludeExtentOfVisualisation))
            cmd.Parameters.Add(New SqlParameter("@IncludeContrastMediaUsed", IncludeContrastMediaUsed))
            cmd.Parameters.Add(New SqlParameter("@IncludePapillaryAnatomy", IncludePapillaryAnatomy))
            cmd.Parameters.Add(New SqlParameter("@IncludeDiagnoses", IncludeDiagnoses))
            cmd.Parameters.Add(New SqlParameter("@IncludeFollowUp", IncludeFollowUp))
            cmd.Parameters.Add(New SqlParameter("@IncludeTherapeuticProcedures", IncludeTherapeuticProcedures))
            cmd.Parameters.Add(New SqlParameter("@IncludeSpecimensTaken", IncludeSpecimensTaken))
            cmd.Parameters.Add(New SqlParameter("@IncludePeriOperativeComplications", IncludePeriOperativeComplications))
            cmd.Parameters.Add(New SqlParameter("@DefaultNumberOfCopies", DefaultNumberOfCopies))
            cmd.Parameters.Add(New SqlParameter("@DefaultNumberOfPhotos", DefaultNumberOfPhotos))
            cmd.Parameters.Add(New SqlParameter("@DefaultPhotoSize", DefaultPhotoSize))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function SaveLabRequestReportPrintOptions(ByVal OneRequestForEverySpecimen As Boolean,
                                                     ByVal GroupSpecimensByDestination As Boolean,
                                                     ByVal RequestsPerA4Page As Integer,
                                                     ByVal IncludeDiagram As Boolean,
                                                     ByVal IncludeTimeSpecimenCollected As Boolean,
                                                     ByVal IncludeHeading As Boolean,
                                                     ByVal Heading As String,
                                                     ByVal IncludeIndications As Boolean,
                                                     ByVal IncludeProcedureNotes As Boolean,
                                                     ByVal IncludeAbnormalities As Boolean,
                                                     ByVal IncludeSiteNotes As Boolean,
                                                     ByVal IncludeDiagnoses As Boolean,
                                                     ByVal DefaultNumberOfCopies As Integer,
                                                     ByVal OperatingHospitalId As Integer) As Integer

        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("UPDATE ERS_PrintOptionsLabRequestReport SET ")
        qry.Append("OneRequestForEverySpecimen = @OneRequestForEverySpecimen")
        qry.Append(",GroupSpecimensByDestination = @GroupSpecimensByDestination")
        qry.Append(",RequestsPerA4Page = @RequestsPerA4Page")
        qry.Append(",IncludeDiagram = @IncludeDiagram")
        qry.Append(",IncludeTimeSpecimenCollected = @IncludeTimeSpecimenCollected")
        qry.Append(",IncludeHeading = @IncludeHeading")
        qry.Append(",Heading = @Heading")
        qry.Append(",IncludeIndications = @IncludeIndications")
        qry.Append(",IncludeProcedureNotes = @IncludeProcedureNotes")
        qry.Append(",IncludeAbnormalities = @IncludeAbnormalities")
        qry.Append(",IncludeSiteNotes = @IncludeSiteNotes")
        qry.Append(",IncludeDiagnoses = @IncludeDiagnoses")
        qry.Append(",WhoUpdatedId = @LoggedInUserId")
        qry.Append(",DefaultNumberOfCopies = @DefaultNumberOfCopies")
        qry.Append(",WhenUpdated = GETDATE()")
        qry.Append(" WHERE OperatingHospitalId = @OperatingHospitalId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@OneRequestForEverySpecimen", OneRequestForEverySpecimen))
            cmd.Parameters.Add(New SqlParameter("@GroupSpecimensByDestination", GroupSpecimensByDestination))
            cmd.Parameters.Add(New SqlParameter("@RequestsPerA4Page", RequestsPerA4Page))
            cmd.Parameters.Add(New SqlParameter("@IncludeDiagram", IncludeDiagram))
            cmd.Parameters.Add(New SqlParameter("@IncludeTimeSpecimenCollected", IncludeTimeSpecimenCollected))
            cmd.Parameters.Add(New SqlParameter("@IncludeHeading", IncludeHeading))
            cmd.Parameters.Add(New SqlParameter("@Heading", Heading))
            cmd.Parameters.Add(New SqlParameter("@IncludeIndications", IncludeIndications))
            cmd.Parameters.Add(New SqlParameter("@IncludeProcedureNotes", IncludeProcedureNotes))
            cmd.Parameters.Add(New SqlParameter("@IncludeAbnormalities", IncludeAbnormalities))
            cmd.Parameters.Add(New SqlParameter("@IncludeSiteNotes", IncludeSiteNotes))
            cmd.Parameters.Add(New SqlParameter("@IncludeDiagnoses", IncludeDiagnoses))
            cmd.Parameters.Add(New SqlParameter("@DefaultNumberOfCopies", DefaultNumberOfCopies))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function SavePatientFriendlyReportPrintOptions(ByVal IncludeNoFollowup As Boolean,
                                                          ByVal IncludeUreaseText As Boolean,
                                                          ByVal UreaseText As String,
                                                          ByVal IncludePolypectomyText As Boolean,
                                                          ByVal PolypectomyText As String,
                                                          ByVal IncludeOtherBiopsyText As Boolean,
                                                          ByVal OtherBiopsyText As String,
                                                          ByVal IncludeAnyOtherBiopsyText As Boolean,
                                                          ByVal AnyOtherBiopsyText As String,
                                                          ByVal IncludeAdviceComments As Boolean,
                                                          ByVal IncludePreceedAdviceComments As Boolean,
                                                          ByVal PreceedAdviceComments As String,
                                                          ByVal IncludeFinalText As Boolean,
                                                          ByVal FinalText As String,
                                                          ByVal DefaultNumberOfCopies As String,
                                                          ByVal OperatingHospitalId As Integer) As Integer

        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("UPDATE ERS_PrintOptionsPatientFriendlyReport SET ")
        qry.Append("IncludeNoFollowup = @IncludeNoFollowup")
        qry.Append(",IncludeUreaseText = @IncludeUreaseText")
        qry.Append(",UreaseText = @UreaseText")
        qry.Append(",IncludePolypectomyText = @IncludePolypectomyText")
        qry.Append(",PolypectomyText = @PolypectomyText")
        qry.Append(",IncludeOtherBiopsyText = @IncludeOtherBiopsyText")
        qry.Append(",OtherBiopsyText = @OtherBiopsyText")
        qry.Append(",IncludeAnyOtherBiopsyText = @IncludeAnyOtherBiopsyText")
        qry.Append(",AnyOtherBiopsyText = @AnyOtherBiopsyText")
        qry.Append(",IncludeAdviceComments = @IncludeAdviceComments")
        qry.Append(",IncludePreceedAdviceComments = @IncludePreceedAdviceComments")
        qry.Append(",PreceedAdviceComments = @PreceedAdviceComments")
        qry.Append(",IncludeFinalText = @IncludeFinalText")
        qry.Append(",FinalText = @FinalText")
        qry.Append(",DefaultNumberOfCopies = @DefaultNumberOfCopies")
        qry.Append(",WhoUpdatedId = @LoggedInUserId")
        qry.Append(",WhenUpdated = GETDATE()")
        qry.Append(" WHERE OperatingHospitalId = @OperatingHospitalId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@IncludeNoFollowup", IncludeNoFollowup))
            cmd.Parameters.Add(New SqlParameter("@IncludeUreaseText", IncludeUreaseText))
            cmd.Parameters.Add(New SqlParameter("@UreaseText", UreaseText))
            cmd.Parameters.Add(New SqlParameter("@IncludePolypectomyText", IncludePolypectomyText))
            cmd.Parameters.Add(New SqlParameter("@PolypectomyText", PolypectomyText))
            cmd.Parameters.Add(New SqlParameter("@IncludeOtherBiopsyText", IncludeOtherBiopsyText))
            cmd.Parameters.Add(New SqlParameter("@OtherBiopsyText", OtherBiopsyText))
            cmd.Parameters.Add(New SqlParameter("@IncludeAnyOtherBiopsyText", IncludeAnyOtherBiopsyText))
            cmd.Parameters.Add(New SqlParameter("@AnyOtherBiopsyText", AnyOtherBiopsyText))
            cmd.Parameters.Add(New SqlParameter("@IncludeAdviceComments", IncludeAdviceComments))
            cmd.Parameters.Add(New SqlParameter("@IncludePreceedAdviceComments", IncludePreceedAdviceComments))
            cmd.Parameters.Add(New SqlParameter("@PreceedAdviceComments", PreceedAdviceComments))
            cmd.Parameters.Add(New SqlParameter("@IncludeFinalText", IncludeFinalText))
            cmd.Parameters.Add(New SqlParameter("@FinalText", FinalText))
            cmd.Parameters.Add(New SqlParameter("@DefaultNumberOfCopies", DefaultNumberOfCopies))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function SavePatientFriendlyReportAdditionalPrintOptions(ByVal Id As Integer,
                                                                    ByVal IncludeAdditionalText As Boolean,
                                                                    ByVal AdditionalText As String,
                                                                    ByVal OperatingHospitalId As Integer) As Integer
        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        If Id > 0 Then
            qry.Append("UPDATE ERS_PrintOptionsPatientFriendlyReportAdditional SET ")
            qry.Append("IncludeAdditionalText = @IncludeAdditionalText ")
            qry.Append(",AdditionalText = @AdditionalText ")
            qry.Append(",WhoUpdatedId = @LoggedInUserId ")
            qry.Append(",WhenUpdated = GETDATE()")
            qry.Append(" WHERE Id = @Id")
        Else
            qry.Append("INSERT INTO ERS_PrintOptionsPatientFriendlyReportAdditional, WhoCreatedId, WhenCreated ")
            qry.Append("VALUES (@IncludeAdditionalText, @AdditionalText, @LoggedInUserId, GETDATE())")
        End If

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@Id", Id))
            cmd.Parameters.Add(New SqlParameter("@IncludeAdditionalText", IncludeAdditionalText))
            cmd.Parameters.Add(New SqlParameter("@AdditionalText", AdditionalText))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiagnoses(ProcedureTypeID As Integer, Section As String) As DataTable
        Dim ds As New DataSet
        Dim sql As String
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        If IsNothing(Section) Then
            sql = "SELECT * FROM ERS_DiagnosesMatrix WHERE ProcedureTypeID = @ProcedureTypeID AND Visible = 1 ORDER BY OrderByNumber"
        Else
            sql = "SELECT * FROM ERS_DiagnosesMatrix WHERE ProcedureTypeID = @ProcedureTypeID  AND Section = @Section AND Visible = 1 ORDER BY OrderByNumber"
            cmd.Parameters.Add(New SqlParameter("@Section", Section))
        End If
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", ProcedureTypeID))
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)

        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function getProcedureChartByYear() As DataTable
        Return ExecuteSP("report_procedure_yearly", Nothing)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function getProcedureChartByMonth(ProcedureYear As String) As DataTable
        Return ExecuteSP("report_procedure_monthly", New SqlParameter() {New SqlParameter("@ProcedureYear", ProcedureYear)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function getProcedureChartYears() As DataTable

        Return ExecuteSP("chart_get_procedure_years", Nothing)

        'Dim ds As New DataSet
        'Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        'Dim cmd As New SqlCommand
        'Dim sql As String = " IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Colon Procedure'))  " &
        '    " BEGIN " &
        '    " select year([Procedure date]) as ProcedureYear FROM [Colon Procedure] where year([Procedure date]) IS NOT NULL group by year([Procedure date]) union " &
        '    " select year([Procedure date]) as ProcedureYear from [Upper GI Procedure] where year([Procedure date]) IS NOT NULL group by year([Procedure date]) union " &
        '    "  select year([Procedure date]) as ProcedureYear from [ERCP Procedure] where year([Procedure date]) IS NOT NULL group by year([Procedure date]) union " &
        '    " select year([Procedure date]) as ProcedureYear from [EUS procedure] where year([Procedure date]) IS NOT NULL group by year([Procedure date])" &
        '    " END ELSE SELECT 0 AS ProcedureYear"
        'Return ExecuteSQL(sql, Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetListDetails(ListDescription As String, Suppressed As Boolean, OrderBy As String) As DataTable
        Dim sql As String = "SELECT [ListItemNo], [ListItemText] FROM [ERS_Lists] WHERE (([ListDescription] = @ListDescription) AND ([Suppressed] = @Suppressed))"
        If OrderBy <> "" Then sql = sql + "ORDER BY " & OrderBy

        Return ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@ListDescription", ListDescription),
                                                                         New SqlParameter("@Suppressed", Suppressed)})

        'Return ExecuteSP("report_procedure_monthly", New SqlParameter() {New SqlParameter("@ListDescription", ListDescription), _
        '                                                                 New SqlParameter("@Suppressed", Suppressed)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDrugType(Drug_type As Integer) As DataTable
        Dim ds As New DataSet
        Dim sUsedInProcedures As String = ""
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand

        Select Case CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE))
            Case ProcedureType.Gastroscopy
                sUsedInProcedures = "UsedInUpperGI"
            Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy
                sUsedInProcedures = "UsedInColonSig"
            Case ProcedureType.ERCP
                sUsedInProcedures = "UsedInERCP"
            Case ProcedureType.EUS_OGD
                sUsedInProcedures = "UsedInEUS_OGD"
            Case ProcedureType.EUS_HPB
                sUsedInProcedures = "UsedInEUS_HPB"
        End Select

        If sUsedInProcedures <> "" Then sUsedInProcedures = " AND " & sUsedInProcedures & " = 1 "

        Dim sql As String = "SELECT [Drugno] as Drug_no , [Drugname] + " &
                                " COALESCE( '('+ [Deliverymethod] + ' in ' + [Units] + ')', '('+ [Deliverymethod] + ')', '('+ [Units] + ')', '')   AS Drug_Alias " &
                                " FROM [ERS_Druglist] WHERE ([Drugtype] = @Drug_type) " & sUsedInProcedures & " ORDER BY [Drugname], [Deliverymethod], [Units] "
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        cmd.Parameters.Add(New SqlParameter("@Drug_type", Drug_type))
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDrugRegime() As DataTable
        Return ExecuteSQL("SELECT DISTINCT [RegimenNo] AS Regimen_No, [Description] FROM [ERS_DrugRegime]", Nothing)
        'Dim ds As New DataSet
        'Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        'Dim cmd As New SqlCommand
        'Dim sql As String = "SELECT DISTINCT [RegimenNo] AS Regimen_No, [Description] FROM [ERS_DrugRegime]"
        'cmd.CommandText = sql
        'cmd.Connection = connection
        'cmd.CommandType = CommandType.Text
        'Dim adapter = New SqlDataAdapter(cmd)
        'connection.Open()
        'adapter.Fill(ds)
        'If ds.Tables.Count > 0 Then
        '    Return ds.Tables(0)
        'Else
        '    Return Nothing
        'End If
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDrugInfo(DrugNo As Integer) As DataTable

        Dim sql As String = "SELECT DrugNo, [DrugName] as Name,[DeliveryMethod] as Method, Units,[DefaultDose] as Dosage, [DoseIncrement] as Increment, ISNULL(DoseNotApplicable,0) AS DoseNotApplicable FROM [ERS_DrugList] WHERE ( [DrugNo] =@DrugNo)"
        Return ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@DrugNo", DrugNo)})
        'Dim ds As New DataSet
        'Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        'Dim cmd As New SqlCommand
        'cmd.CommandText = sql
        'cmd.Connection = connection
        'cmd.CommandType = CommandType.Text
        'cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
        'Dim adapter = New SqlDataAdapter(cmd)
        'connection.Open()
        'adapter.Fill(ds)
        'If ds.Tables.Count > 0 Then
        '    Return ds.Tables(0)
        'Else
        '    Return Nothing
        'End If
    End Function
    Public Function UpdateWHOSurgicalSafetyCheckList(ProcedureID As Integer, SurgicalSafetyCheckListCompleted As Nullable(Of Boolean)) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("UPDATE [ERS_Procedures] SET SurgicalSafetyCheckListCompleted = @SurgicalSafetyCheckListCompleted WHERE ProcedureID = @ProcedureID", connection)
            cmd.CommandType = CommandType.Text
            If IsNothing(SurgicalSafetyCheckListCompleted) Then
                cmd.Parameters.Add(New SqlParameter("@SurgicalSafetyCheckListCompleted", SqlTypes.SqlBoolean.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@SurgicalSafetyCheckListCompleted", SurgicalSafetyCheckListCompleted))
            End If

            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            Return cmd.ExecuteNonQuery
        End Using
    End Function
    Public Function GetWHOSurgicalSafetyCheckList(ProcedureID As Integer) As Nullable(Of Integer)
        Dim sVal As Object
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT SurgicalSafetyCheckListCompleted FROM [ERS_Procedures] WHERE ProcedureID = @ProcedureID", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            sVal = cmd.ExecuteScalar()
            If Not IsDBNull(sVal) AndAlso Not IsNothing(sVal) Then
                If CBool(sVal) Then Return 1 Else Return 0
            Else
                Return Nothing
            End If
        End Using
    End Function
    Public Function GetMenuMapItems(UserID As Integer, isViewer As Boolean, isDemoVersion As Boolean, MenuCategory As String) As DataTable
        Return ExecuteSP("common_select_menu", New SqlParameter() {
                                                    New SqlParameter("@isViewer", isViewer),
                                                    New SqlParameter("@MenuCategory", MenuCategory),
                                                    New SqlParameter("@isDemoVersion", isDemoVersion),
                                                    New SqlParameter("@UserID", UserID),
                                                    New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId")))})
    End Function
    Public Function InsertControl(Control As String, ControlType As String, Others As String, Page As String)
        If Control Is Nothing Then Return Nothing

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("IF NOT EXISTS (SELECT 1 FROM tempo where [Control]=@Control AND [Page]=@Page) INSERT INTO tempo ([Control],[ControlType],[Others],[Page]) values (@Control,@ControlType,@Others,@Page)", connection)
                cmd.CommandType = CommandType.Text
                If String.IsNullOrEmpty(Control) Then
                    cmd.Parameters.Add(New SqlParameter("@Control", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Control", Control))
                End If
                If String.IsNullOrEmpty(ControlType) Then
                    cmd.Parameters.Add(New SqlParameter("@ControlType", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ControlType", ControlType))
                End If
                If String.IsNullOrEmpty(Others) Then
                    cmd.Parameters.Add(New SqlParameter("@Others", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Others", Left(Others, 400)))
                End If
                If String.IsNullOrEmpty(Page) Then
                    cmd.Parameters.Add(New SqlParameter("@Page", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Page", Page))
                End If
                connection.Open()
                Return cmd.ExecuteNonQuery
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(String.Format("Error at DataAccess.vb->InsertControl(Control: {0}, ControlType:{1}, Others:{2}, Page:{3})", Control, ControlType, Others, Page), ex)
            Return Nothing
        End Try
    End Function

    ''' <summary>
    ''' Execute any DDL/DML Stored Procedure.
    ''' </summary>
    ''' <param name="StoredProcName">Name of the SP</param>
    ''' <param name="paramList">List of Parameters</param>
    ''' <returns>DataTable, if USED for SELECT</returns>
    ''' <remarks>Added by Shawkat Osman; 2017-06-14</remarks>
    Public Function ExecuteSP(ByVal StoredProcName As String, Optional ByVal paramList As SqlParameter() = Nothing) As DataTable
        Dim dsData As New DataSet
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(StoredProcName, connection)
                cmd.CommandType = CommandType.StoredProcedure

                If paramList IsNot Nothing Then cmd.Parameters.AddRange(paramList) '#### If No ParamList is Passed- don't worry! Lets go Alone!

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsData)
            End Using

            Return IIf(dsData.Tables.Count > 0, dsData.Tables(0), Nothing)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(String.Format("Error Executing StoredProc: {0}({1}), at: DataAccess.vb=>ExecuteSP()", StoredProcName, IIf(paramList Is Nothing, "", paramList.ToString())), ex)
            Return Nothing
        End Try

    End Function

    ''' <summary>
    ''' Execute any DDL/DML SQL Statement. 
    ''' </summary>
    ''' <param name="sqlStatement">Statement to EXECUTE</param>
    ''' <param name="paramList">List of Parameters</param>
    ''' <returns>DataTable, if USED for SELECT</returns>
    ''' <remarks>Added by Shawkat Osman; 2017-08-22</remarks>
    Public Shared Function ExecuteSQL(ByVal sqlStatement As String, Optional ByVal paramList As SqlParameter() = Nothing) As DataTable
        Dim result As New DataTable
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sqlStatement, connection)
                cmd.CommandType = CommandType.Text

                If paramList IsNot Nothing Then cmd.Parameters.AddRange(paramList) '#### If No ParamList is Passed- don't worry! Lets go Alone!

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(result)
            End Using

            Return IIf(result.Rows.Count > 0, result, Nothing)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error Executing sqlStatement=[" & sqlStatement & "], at: DataAccess.vb=>ExecuteSQL()", ex)
            Return Nothing
        End Try

    End Function

    ''' <summary>
    ''' Sanitized version of GetData. Only StoredProc.. But sometimes InLine SQL can be used.. but very risky!
    ''' </summary>
    ''' <param name="ScalerExecuteSQL">Simple SQL Suery text</param>
    ''' <returns>True if No Error, else False</returns>
    ''' <remarks>Need to sanitize the user SQL; They can be risky!</remarks>
    Public Shared Function ExecuteScalerSQL(ByVal ScalerExecuteSQL As String, Optional ByVal ExecuteAs As CommandType = CommandType.Text, Optional ByVal paramList As SqlParameter() = Nothing) As Boolean
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(ScalerExecuteSQL, connection)
                cmd.CommandType = ExecuteAs

                If paramList IsNot Nothing Then cmd.Parameters.AddRange(paramList) '#### If No ParamList is Passed- don't worry! Lets go Alone!

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error Executing Generic SQL Statement, at: DataAccess.vb=>ScalerExecuteSQL()) " + ScalerExecuteSQL, ex)
            Return False
        Finally

        End Try

    End Function

    Public Shared Function ProcedureNotCarriedOut_UpdateReason(ByVal procedureId As String, ByVal DNA_ReasonId As String, ByVal PP_DNA_Text As String) As Boolean
        Dim Procedure = CInt(procedureId)
        Dim DNA_Reason = CInt(DNA_ReasonId)


        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = db.ProcedureNotCarriedOut_UpdateReason(Procedure, DNA_Reason, PP_DNA_Text)
            End Using
            Return True

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(String.Format("Error at: DataAccess.vb=>ProcedureNotCarriedOut_UpdateReason(Procedure={0}, DNA_Reason={1}, PP_DNA_Text={2})", Procedure, DNA_Reason, PP_DNA_Text), ex)
            Return False
        End Try
    End Function

    Public Shared Function ProcedureIsValidToExportNED_XML(ByVal procedureId As Integer, ByVal ProcedureType As Integer) As Boolean
        Try
            Dim idObj As Object

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("usp_IsValidToExportNED", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureType", ProcedureType))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalID"))))

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CBool(idObj)
                End If
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(String.Format("Error at: DataAccess.vb=>ProcedureIsValidToExportNED_XML(Procedure={0}, ProcedureType={1})", procedureId, ProcedureType), ex)
            Return False
        End Try
    End Function

    Public Function GetPatientComfortLevel(procedureID As Integer) As DataTable
        Dim value As Integer = -1
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT PatSedation, PatDiscomfortPatient, PatDiscomfortNurse, PatSedationAsleepResponseState  FROM ERS_UpperGIQA WHERE ProcedureID=@ProcedureID", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", procedureID))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetPatientsByIDs(patientIds As List(Of String)) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_VW_Patients WHERE PatientID IN (" & String.Join(",", patientIds) & ")", connection)
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

    Public Function GetPatientById(patientId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_VW_Patients WHERE PatientId=" & patientId, connection)
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
    Public Function GetEndoscopist() As DataTable
        Dim sqlStr As String = "SELECT UserID, LTRIM(RTRIM(ISNULL([Forename], '') + ' ' + ISNULL([Surname], ''))) AS EndoName, Description AS FullName " &
            " FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE (IsEndoscopist1 = 1 OR IsEndoscopist2 = 1) AND Suppressed = 0"
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), New SqlParameter() {New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId")))})
    End Function

    Public Function SiteName(ByVal siteId As Integer) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT dbo.fnGetSiteName(@SiteId)", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            connection.Open()
            Return CStr(cmd.ExecuteScalar())
        End Using
        Return ""
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetWorklistPatients(Optional startDate As Date? = Nothing, Optional endDate As Date? = Nothing, Optional endoscopistId As Integer? = Nothing) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_worklist_patients", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalID"))))
            If startDate Is Nothing Then
                cmd.Parameters.Add(New SqlParameter("@StartDate", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@StartDate", startDate.Value))
            End If
            If endDate Is Nothing Then
                cmd.Parameters.Add(New SqlParameter("@EndDate", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@EndDate", endDate.Value))
            End If
            If endoscopistId Is Nothing Then
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistId.Value))
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

    Public Sub saveOCSRecord()

    End Sub
    'Public Function GetVisualisationRecords(ByVal procedureId As Integer) As ERS.Data.EndoscopistSearch_Result
    '    Dim result As IQueryable(Of ERS.Data.EndoscopistSearch_Result)
    '    Try
    '        Using db As New ERS.Data.GastroDbEntities
    '            '### First get the Details about the Endoscopist! Both 1 and 2 wherever applicable!
    '            result = db.EndoscopistSelectByProcedureSite(procedureId, 0)
    '            Return result.FirstOrDefault()
    '        End Using
    '    Catch ex As Exception

    '        Return Nothing
    '    End Try

    'End Function


    Public Sub SetPriorityColors()
        Dim i As Integer
        Dim dsResult As New DataSet
        Dim PriorityDataTable As DataTable = Nothing
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("Select PriorityId, Description, Backcolor from ERS_Priority", connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using
        If dsResult.Tables.Count > 0 Then PriorityDataTable = dsResult.Tables(0)

        If PriorityDataTable.Rows.Count > 0 Then
            For i = 0 To PriorityDataTable.Rows.Count - 1
                PriorityColours.Add(New clsPriorityColors(PriorityDataTable.Rows(i).Item("PriorityId"), PriorityDataTable.Rows(i).Item("Description"), PriorityDataTable.Rows(i).Item("Backcolor")))
            Next
        End If

        PriorityDataTable.Dispose()

    End Sub
    Public Sub UpdateIsActive(InboundID As Long, Status As Integer, ProcessId As Integer, Optional OperatingHospitalId As Long = 0)
        Dim SQLString As String = ""
        Using connection As New SqlConnection(ConnectionStr)
            Select Case ProcessId
                Case 1 ' ProcedureType
                    SQLString = "UPDATE [ERS_ProcedureTypesHospitalDefinition] SET IsActive = " & Status & " WHERE ProcedureTypeID = " & InboundID &
                    " And OperatingHospitalId = " & OperatingHospitalId
                Case 2 'IMAGEPORT
                    SQLString = "UPDATE [ERS_ImagePort] SET IsActive = " & Status & " WHERE ImagePortID = " & InboundID
            End Select
            Dim cmd As New SqlCommand(SQLString, connection)
            cmd.CommandType = CommandType.Text
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Sub UnlinkImagePort(InboundID As Long)
        Dim SQLString As String = ""
        Using connection As New SqlConnection(ConnectionStr)
            SQLString = "UPDATE [ERS_ImagePort] SET RoomID = null, [Static] = NULL, [Default] = NULL, WhoUpdatedId=@LoggedInUserId, WhenUpdated = GETDATE() WHERE ImagePortID = " & InboundID
            Dim cmd As New SqlCommand(SQLString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Sub DeleteImagePort(InboundID As Long)
        Dim SQLString As String = ""
        Using connection As New SqlConnection(ConnectionStr)
            SQLString = "Delete from [ERS_ImagePort] WHERE ImagePortID = " & InboundID
            Dim cmd As New SqlCommand(SQLString, connection)
            cmd.CommandType = CommandType.Text
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Function CheckEntryExists(UID As Long, UIDName As String, Tbl As String, FieldName As String) As Boolean
        Dim SQLString As String = "select isnull(" & FieldName & ",'') as Fvalue from " & Tbl & " where  " & UIDName & " = " & UID
        Using connection As New SqlConnection(ConnectionStr)

            Dim exists As Boolean
            Dim myTmpTable As New DataTable '= Nothing
            Dim myTmpDataAdapter As New SqlDataAdapter(SQLString, connection)
            myTmpDataAdapter.Fill(myTmpTable)

            If myTmpTable.Rows.Count > 0 Then
                If Len(myTmpTable.Rows(0).Item("Fvalue")) Then
                    exists = True
                Else
                    exists = False
                End If
            Else
                exists = False
            End If
            myTmpTable.Dispose()
            connection.Dispose()
            Return exists

        End Using
    End Function
    Public Function CheckValueExists(EntryName As String, Tbl As String, FieldName As String, ID As String) As Long
        Dim SQLString As String = "select " & ID & " as Fvalue from " & Tbl & " where  " & FieldName & " = '" & EntryName & "'"
        Using connection As New SqlConnection(ConnectionStr)
            Dim exists As Long
            Dim myTmpTable As New DataTable '= Nothing
            Dim myTmpDataAdapter As New SqlDataAdapter(SQLString, connection)
            myTmpDataAdapter.Fill(myTmpTable)
            If myTmpTable.Rows.Count > 0 Then
                exists = myTmpTable.Rows(0).Item("Fvalue")
            Else
                exists = 0
            End If
            myTmpTable.Dispose()
            connection.Dispose()
            Return exists
        End Using
    End Function
    Public Function GetGPList(PostCode As String, NationalCode As String, LocalCode As String, GPName As String, PracticeName As String, Active As Integer) As DataTable
        Dim dsData As New DataSet
        Dim ActiveValue As Integer = Val(Active)
        GPName = "SMITH"
        '@PostCode as varchar(50), @NationalCode varchar(50), @LocalCode varchar(50), @GPName varchar(50), @PracticeName varchar(50))

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("GetGPList", connection)
            cmd.CommandType = CommandType.StoredProcedure
            If PostCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Postcode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Postcode", .SqlDbType = SqlDbType.Text, .Value = PostCode})
            End If
            If NationalCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NationalCode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NationalCode", .SqlDbType = SqlDbType.Text, .Value = NationalCode})
            End If
            If LocalCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LocalCode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LocalCode", .SqlDbType = SqlDbType.Text, .Value = LocalCode})
            End If
            If GPName = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GPName", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GPName", .SqlDbType = SqlDbType.Text, .Value = GPName})
            End If
            If PracticeName = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PracticeName", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PracticeName", .SqlDbType = SqlDbType.Text, .Value = PracticeName})
            End If

            ' If Active = Nothing Then
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Active", .SqlDbType = SqlDbType.Int, .Value = 1})
            '   Else
            '     cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Active", .SqlDbType = SqlDbType.Int, .Value = ActiveValue})
            '    End If
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function GetPracticeList(PostCode As String, NationalCode As String, LocalCode As String, PracticeName As String, Active As Integer) As DataTable
        Dim dsData As New DataSet
        Dim ActiveValue As Integer = Val(Active)
        PracticeName = "SMITH"
        '@PostCode as varchar(50), @NationalCode varchar(50), @LocalCode varchar(50), @GPName varchar(50), @PracticeName varchar(50))

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("GetGPList", connection)
            cmd.CommandType = CommandType.StoredProcedure
            If PostCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Postcode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Postcode", .SqlDbType = SqlDbType.Text, .Value = PostCode})
            End If
            If NationalCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NationalCode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NationalCode", .SqlDbType = SqlDbType.Text, .Value = NationalCode})
            End If
            If LocalCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LocalCode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LocalCode", .SqlDbType = SqlDbType.Text, .Value = LocalCode})
            End If

            If PracticeName = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PracticeName", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PracticeName", .SqlDbType = SqlDbType.Text, .Value = PracticeName})
            End If

            ' If Active = Nothing Then
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Active", .SqlDbType = SqlDbType.Int, .Value = 1})
            '   Else
            '     cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Active", .SqlDbType = SqlDbType.Int, .Value = ActiveValue})
            '    End If
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub insertOCSRecord(strMessage As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("usp_Insert_OCS_Record", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcessString", strMessage))
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(Session(Constants.SESSION_PROCEDURE_ID))))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function TransactionSQL(sql As String) As String
        Dim sqlCommand = ""
        sqlCommand += "BEGIN TRY "
        sqlCommand += "BEGIN TRANSACTION "
        sqlCommand += sql
        sqlCommand += " COMMIT TRANSACTION "
        sqlCommand += "END TRY "
        sqlCommand += "BEGIN CATCH
	                    DECLARE @ErrorMessage NVARCHAR(4000);
                        DECLARE @ErrorSeverity INT;
                        DECLARE @ErrorState INT;

                        SELECT @ErrorMessage = ERROR_MESSAGE(),
                               @ErrorSeverity = ERROR_SEVERITY(),
                               @ErrorState = ERROR_STATE();
                        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);"
        sqlCommand += "ROLLBACK "
        sqlCommand += "END CATCH "

        Return sqlCommand.ToString()
    End Function

    Public Function ShowCorrectStentPlacementOptions(siteId As Integer, ProcedureTypeId As Integer) As Boolean
        Dim sqlStmt As String = ""

        If ProcedureTypeId = ProcedureType.Gastroscopy Then
            sqlStmt = "SELECT Stricture AS ShowStentPlacementOption " &
                                    "FROM dbo.ERS_UpperGIAbnoMiscellaneous AS Abn " &
                                    "WHERE Abn.SiteId = @SiteId;"
        ElseIf ProcedureTypeId = ProcedureType.Colonoscopy Then
            sqlStmt = "SELECT Stricture AS ShowStentPlacementOption " &
                                   "FROM dbo.ERS_ColonAbnoCalibre AS Abn " &
                                   "WHERE Abn.SiteId = @SiteId;"
        End If

        Dim result As DataTable
        result = DataAccess.ExecuteSQL(sqlStmt, New SqlParameter() {New SqlParameter("@SiteId", siteId)})
        If result IsNot Nothing Then
            Return CBool(result.Rows(0).Item("ShowStentPlacementOption") = True)
        Else
            Return False
        End If

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetStentInsertionFailureReasons() As DataTable
        Return GetList("Stent Placement Failure Reasons")
    End Function

    Friend Function GetPatientNotes(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("PatientNotesSelect", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Sub SavePatientNotes(procedureId As Integer, patientNotes As String, patientHistory As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("PatientNotesSave", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@PatientNotes", patientNotes))
                cmd.Parameters.Add(New SqlParameter("@PatientHistory", patientHistory))
                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub


    Public Function ImagePortName(portId As String) As String

        Dim sqlQuery As String = ""
        Dim sqlResult As String = ""

        sqlQuery = "SELECT PortName FROM dbo.ERS_ImagePort WHERE ImagePortId = @PortId;"

        Dim result As DataTable
        result = DataAccess.ExecuteSQL(sqlQuery, New SqlParameter() {New SqlParameter("@PortId", portId)})
        If sqlResult IsNot Nothing AndAlso portId > 0 Then
            Return Convert.ToString(result.Rows(0).Item("PortName"))
        Else
            Return ""
        End If

    End Function

    Friend Sub SaveImagePortDetails(operatingHospitalId As Integer, imagePortId As Integer, portName As String, macAddress As String, roomId As Integer, comments As String, friendlyName As String, isDefault As Boolean)
        DataAccess.ExecuteScalerSQL("image_port_save", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@OperatingHospitalId", operatingHospitalId),
                                        New SqlParameter("@ImagePortId", imagePortId),
                                        New SqlParameter("@PortName", portName),
                                        New SqlParameter("@MacAddress", macAddress),
                                        New SqlParameter("@RoomId", roomId),
                                        New SqlParameter("@Comments", comments),
                                        New SqlParameter("@FriendlyName", friendlyName),
                                        New SqlParameter("@Default", isDefault)})
    End Sub

    Public Function CheckImagePortRoomDefault(operatingHospitalId As Integer, roomId As Integer, isDefault As Boolean) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("image_port_room_default_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            cmd.Parameters.Add(New SqlParameter("@Default", isDefault))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing

    End Function

    'Public Function ClearImagePortRoomDefault(operatingHospitalId As Integer, roomId As Integer, isDefault As Boolean) As DataTable
    Friend Sub ClearImagePortRoomDefault(imagePortId As Integer)

        DataAccess.ExecuteScalerSQL("image_port_room_default_clear", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@ImagePortId", imagePortId)
                                        })

    End Sub
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetJagReportDrillDown(procedureType As String, ConsultantId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("report_JAG" + procedureType + "_DrillDown", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@UserId", .SqlDbType = SqlDbType.Int, .Value = LoggedInUserId})
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AnonomizedId", .SqlDbType = SqlDbType.Int, .Value = ConsultantId})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function



#Region "Scopes"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScopesLst(FieldValue As String, Suppressed As Nullable(Of Integer)) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("scopes_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
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
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SuppressScope(ScopeId As String, Suppressed As Boolean) As Boolean
        Dim sql As String = "UPDATE [ERS_Scopes] SET [Suppressed] = " & IIf(Suppressed, 1, 0) & ", WhoUpdatedId = " & LoggedInUserId & ", WhenUpdated = GETDATE() WHERE [ScopeId]= " & ScopeId
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScope(ByVal ScopeId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("scope_select", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ScopeId", .SqlDbType = SqlDbType.Int, .Value = ScopeId})
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
    Public Function GetScopeProcedureTypes(ByVal ScopeId As Integer) As DataTable
        Dim sqlStr As String = "Select p.ProcedureTypeId, p.ProcedureType, ISNULL(r.ScopeProcId,0) As ScopeProcId FROM [dbo].[ERS_ProcedureTypes] p " &
            " LEFT JOIN ERS_ScopeProcedures r On p.ProcedureTypeId = r.ProcedureTypeId And r.ScopeId = " & ScopeId

        sqlStr = sqlStr & " ORDER BY p.ProcedureTypeId "

        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScopeLst(ByVal ProcedureType As Integer) As DataTable
        Dim sqlStr As String = "SELECT DISTINCT s.ScopeId, s.ScopeName FROM [ERS_Scopes] s " &
                            " INNER JOIN ERS_ScopeProcedures p On p.ScopeId = s.ScopeId And p.ProcedureTypeId = " & ProcedureType &
                    " ORDER BY ScopeName"
        Return GetData(sqlStr)
    End Function
#End Region
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOtherAuditReports() As DataTable
        Return ExecuteSP("GetOtherAuditReports")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOtherAuditReport(reportId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("auditRunReport", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@UserId", .SqlDbType = SqlDbType.Int, .Value = LoggedInUserId})
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ReportId", .SqlDbType = SqlDbType.Int, .Value = reportId})
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
    Public Function GetScopeManufacturers() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("scope_manufacturers_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
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
    Public Function GetScopeManufacturerGeneration(manufacturerId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("scope_manufacturers_generation_select", connection)
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ManufacturerId", .SqlDbType = SqlDbType.Int, .Value = manufacturerId})

            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

End Class