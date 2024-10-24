Imports Microsoft.VisualBasic
Imports System.Data.SqlClient
Imports System.Collections.Generic
Imports Hl7.Fhir.Model

Public Class Options


    Private ReadOnly Property LoggedInUserId As Integer
        Get
            Return CInt(HttpContext.Current.Session("PKUserID"))
        End Get
    End Property

#Region "User Maintenance"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUsers(ByVal searchPhrase As String, ByVal filterBy As String) As DataTable
        Dim dsUsers As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_users", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))
            cmd.Parameters.Add(New SqlParameter("@SearchPhrase", If(searchPhrase, DBNull.Value)))
            cmd.Parameters.Add(New SqlParameter("@FilterSuppressed", If(filterBy, DBNull.Value)))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsUsers)
        End Using

        If dsUsers.Tables.Count > 0 Then
            Return dsUsers.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRoles() As DataTable
        ' Should no longer be called, redirected to DataAccess GetRoles method just in case there are any databound references
        Dim da As New DataAccess()

        Return da.GetRoles(True)

        'Dim dsRoles As New DataSet
        'Dim sql As New StringBuilder
        'sql.Append("SELECT RoleId, RoleName, IsEditable ")
        'sql.Append("FROM ERS_Roles ")
        'sql.Append("WHERE RoleName <> 'Unisoft' ")
        'sql.Append("AND TrustID = " + HttpContext.Current.Session("TrustId") + " ")
        'sql.Append("ORDER BY RoleId ASC")

        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand(sql.ToString(), connection)
        '    cmd.CommandType = CommandType.Text

        '    Dim adapter = New SqlDataAdapter(cmd)

        '    connection.Open()
        '    adapter.Fill(dsRoles)
        'End Using

        'If dsRoles.Tables.Count > 0 Then
        '    Return dsRoles.Tables(0)
        'End If
        'Return Nothing
    End Function

#End Region

#Region "Required Fields Setup"
    Public Function GetSuppressedValidators(className As String) As DataTable
        Return GetRequiredFields(Nothing, Nothing, className, False, False)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRequiredFields(ByVal procedureType As Nullable(Of Integer),
                                      ByVal pageName As String,
                                      ByVal className As String,
                                      ByVal required As Nullable(Of Boolean),
                                      ByVal commonFields As Nullable(Of Boolean)) As DataTable
        Dim dsValidators As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("required_fields_select", connection)
            cmd.CommandType = CommandType.StoredProcedure

            If procedureType.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureType", SqlTypes.SqlInt32.Null))
            End If
            If pageName IsNot Nothing Then
                cmd.Parameters.Add(New SqlParameter("@PageName", pageName))
            Else
                cmd.Parameters.Add(New SqlParameter("@PageName", SqlTypes.SqlString.Null))
            End If
            If className IsNot Nothing Then
                cmd.Parameters.Add(New SqlParameter("@ClassName", Replace(className, "UnisoftERS.", "")))
            Else
                cmd.Parameters.Add(New SqlParameter("@ClassName", SqlTypes.SqlString.Null))
            End If
            If required.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Required", required))
            Else
                cmd.Parameters.Add(New SqlParameter("@Required", SqlTypes.SqlBoolean.Null))
            End If
            If commonFields.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CommonFields", commonFields))
            Else
                cmd.Parameters.Add(New SqlParameter("@CommonFields", SqlTypes.SqlBoolean.Null))
            End If

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsValidators)
        End Using

        If dsValidators.Tables.Count > 0 Then
            Return dsValidators.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateRequiredFields(ByVal requiredFieldId As Integer,
                                         ByVal required As Boolean) As Integer
        Dim sql As String = "UPDATE ERS_RequiredFields SET Required=@Required, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE RequiredFieldId=@RequiredFieldId"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RequiredFieldId", requiredFieldId))
            cmd.Parameters.Add(New SqlParameter("@Required", required))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function CheckRequiredField(PageName As String, fieldName As String) As Boolean
        Dim sql As String = "select [Required] from ERS_RequiredFields WHERE [PageName] = @PageName AND [FieldName] = @fieldName"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@PageName", PageName))
            cmd.Parameters.Add(New SqlParameter("@fieldName", fieldName))

            connection.Open()
            Dim r As Object = cmd.ExecuteScalar
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CBool(r)
            Else
                Return False
            End If
        End Using
    End Function
    Public Function CheckRequired(ProcedureId As Integer, Optional ByVal PageId As Integer = 0) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("check_requiredfields", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@PageId", PageId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalId"))))
            connection.Open()
            Dim r As Object = cmd.ExecuteScalar
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CStr(r)
            Else
                Return ""
            End If
        End Using
    End Function
    'issue - 1671
    Public Function CheckProcedureComplete(ByVal ProcedureId As Integer) As Integer
        Dim value As Object
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            ' Call the SQL function instead of using a direct query
            Dim cmd As New SqlCommand("SELECT dbo.CheckProcedureComplete(@ProcedureId)", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))

            connection.Open()
            value = cmd.ExecuteScalar()

            If Not IsDBNull(value) AndAlso value IsNot Nothing Then
                Return Convert.ToInt32(value)
            Else
                Return 0
            End If
        End Using
    End Function

    'issue - 1671

#End Region

#Region "System Usage"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetLockedPatients() As DataTable
        Dim dsPatients As New DataSet
        Dim sql As New StringBuilder
        sql.Append("SELECT [PatientId] AS PatientId, ")
        sql.Append("    p.Title + ' ' + p.Forename1 + ' ' + p.Surname AS PatientName, ")
        sql.Append("    u.Title + ' ' + u.Forename + ' ' + u.Surname AS LockedBy, ")
        sql.Append("    CONVERT(CHAR(11),LockedOn,101) + CONVERT(CHAR(5),LockedOn,114) AS LockedOn ")
        sql.Append("FROM Patient p ")
        sql.Append("LEFT JOIN ERS_Users u ON p.LockedBy = u.UserID ")
        sql.Append("WHERE Locked = 1")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPatients)
        End Using

        If dsPatients.Tables.Count > 0 Then
            Return dsPatients.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateLockedPatients(ByVal patientId As Integer) As Integer
        Dim sql As String = "UPDATE Patient SET Locked=NULL, LockedBy=NULL, LockedOn=NULL WHERE [Patient No]=@PatientId"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetLoggedInUsers(operatingHospitalIds As String) As DataTable
        Dim dsPatients As New DataSet
        Dim sql As New StringBuilder
        sql.Append("SELECT u.UserID, Username, ")
        sql.Append("    Title + ' ' + Forename + ' ' + Surname AS [User], ")
        sql.Append("    CASE WHEN AccessRights = 1 THEN 'Yes' ELSE 'No' END AS IsReadOnly, ")
        sql.Append("    CONVERT(CHAR(11),LastLoggedIn,101) + CONVERT(CHAR(5),LastLoggedIn,114) AS LastLoggedIn ")
        sql.Append("FROM ERS_Users u ")
        sql.Append("Inner join ERS_UserOperatingHospitals euoh on u.UserID = euoh.UserId ")
        sql.Append("WHERE LoggedOn = 1 ")
        sql.Append("and euoh.operatingHospitalId in(1) and dateadd(D,-2,getdate())<=LastLoggedIn")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPatients)
        End Using

        If dsPatients.Tables.Count > 0 Then
            Return dsPatients.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function RemoveLoggedInUser(ByVal userId As Integer, ByVal userName As String) As Integer
        Try
            DataAccess.ExecuteScalerSQL("RemoveLoggedUser", CommandType.StoredProcedure, New SqlParameter() {New SqlParameter("@userId", userId), New SqlParameter("@userName", userName)})
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred", ex)
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function RemoveLoggedInUser(ByVal hostName As String) As Integer
        Dim sql As New StringBuilder
        sql.Append("DECLARE @UserId AS INT ")
        sql.Append("SET @UserId = (SELECT TOP 1 UserId FROM ERS_UserLogins WHERE HostName = @HostName)")

        sql.Append("UPDATE ERS_Users SET LoggedOn = 0 WHERE UserID = @UserId ")

        sql.Append("DELETE FROM ERS_UserLogins WHERE UserId = @UserId ")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@HostName", hostName))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateLastActiveTime(ByVal userId As Integer) As Integer
        Dim sql As String = "UPDATE ERS_UserLogins SET LastActiveAt = GETDATE() WHERE UserID=@UserID"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserID", userId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function GetLastActiveTime(ByVal userId As Integer) As DateTime
        Dim sql As String = "SELECT LastActiveAt FROM ERS_UserLogins WHERE UserID=@UserID"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserID", userId))

            connection.Open()
            'Return CDate(cmd.ExecuteScalar())
            Return Date.ParseExact(cmd.ExecuteScalar(), "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo)
        End Using
    End Function
#End Region

#Region "System Settings"
    'Public Function GetApplicationTimeOut(ByVal operatingHospitalId As Integer) As Integer
    '    Dim sql As String = "SELECT ApplicationTimeOut FROM ERS_SystemConfig WHERE OperatingHospitalID = @OperatingHospitalID"

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand(sql, connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", operatingHospitalId))

    '        connection.Open()
    '        Return CInt(cmd.ExecuteScalar())
    '    End Using
    'End Function
    Public Sub WriteFileMoveLog(src As String, dest As String, fileSize As Long)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("uspLogFileMove", connection)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@Source", src))
                cmd.Parameters.Add(New SqlParameter("@Destination", dest))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception

        End Try
    End Sub

    Public Function GetApplicationTimeOut() As Integer
        Return CInt(ConfigurationManager.AppSettings("Unisoft.ApplicationTimeout"))
    End Function

    Public Function GetSystemSettings(Optional ByVal operatingHospitalId As Integer? = Nothing) As DataTable
        If Not operatingHospitalId.HasValue Then operatingHospitalId = CInt(HttpContext.Current.Session("OperatingHospitalId"))
        Dim dsSystemSettings As New DataSet
        Dim dtDataTable As New DataTable
        If HttpContext.Current.Session("SystemSettings") Is Nothing Then
            dtDataTable = GetSystemSettingsFromDatabase(operatingHospitalId)
            HttpContext.Current.Session("SystemSettings") = dtDataTable
        Else
            dtDataTable = CType(HttpContext.Current.Session("SystemSettings"), DataTable)
            If dtDataTable.Rows(0)("OperatingHospitalId") <> operatingHospitalId Then
                dtDataTable = GetSystemSettingsFromDatabase(operatingHospitalId)
            End If
        End If
        Return dtDataTable
    End Function

    Private Function GetSystemSettingsFromDatabase(operatingHospitalId As Integer) As DataTable
        Dim dsSystemSettings As New DataSet
        Dim dtDataTable As New DataTable       '01 Sept 2021   :   MH Added EvidenceOfCancerMandatory
        '21 Sept 2021   :   MH Added MinimumPatientSearchOption
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("GetSystemSettings", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", operatingHospitalId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSystemSettings)
        End Using
        If dsSystemSettings.Tables.Count > 0 Then
            dtDataTable = dsSystemSettings.Tables(0)

        End If
        Return dtDataTable
    End Function

    Public Function GetStartupSettings() As DataTable
        Dim dsSystemSettings As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sSql = "IF EXISTS (SELECT 1 FROM dbo.ERS_StartupSettings ess WHERE UserID = " & CInt(HttpContext.Current.Session("PKUserId")) & ") 
	                        SELECT TOP 1 * FROM dbo.ers_startupsettings esc WHERE userid = " & CInt(HttpContext.Current.Session("PKUserId")) & "
                        ELSE SELECT TOP 1 * FROM dbo.ers_startupsettings esc"

            Dim cmd As New SqlCommand(sSql, connection) ' WHERE UserId=" & CInt(HttpContext.Current.Session("PKUserId")), connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsSystemSettings)
        End Using
        If dsSystemSettings.Tables.Count > 0 Then
            Return dsSystemSettings.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function SaveStartupSettings(SearchCriteria As Integer, SearchCriteriaOption As Integer, SearchCriteriaOptionPatientCount As Nullable(Of Integer), SearchCriteriaOptionDate As Nullable(Of Date),
                                        SearchCriteriaOptionMonths As Nullable(Of Integer), ExcludeDeadOption As Boolean, ExcludeUGI As Boolean, OrderListOptions As Integer,
                                        AllProcedures As Boolean, Gastroscopy As Boolean, ERCP As Boolean, Colonoscopy As Boolean, Proctoscopy As Boolean, OutstandingCLO As Boolean, ShowWorklistOnStart As Boolean, HideStartupCharts As Boolean, UserId As Integer, operatingHospitalId As Integer) As Integer
        Dim sql As String = "IF EXISTS(SELECT TOP(1) 1 FROM ERS_StartupSettings WHERE UserId = @UserId AND OperatingHospitalId = @OperatingHospitalId) UPDATE ERS_StartupSettings SET SearchCriteria = @SearchCriteria, SearchCriteriaOption = @SearchCriteriaOption, SearchCriteriaOptionPatientCount = @SearchCriteriaOptionPatientCount, SearchCriteriaOptionDate = @SearchCriteriaOptionDate , SearchCriteriaOptionMonths = @SearchCriteriaOptionMonths,ExcludeDeadOption=@ExcludeDeadOption, ExcludeUGI = @ExcludeUGI, AllProcedures = @AllProcedures, Gastroscopy = @Gastroscopy, ERCP = @ERCP, Colonoscopy = @Colonoscopy, Proctoscopy = @Proctoscopy, OutstandingCLO = @OutstandingCLO, OrderListOptions= @OrderListOptions, ShowWorklistOnStartUp =@ShowWorklistOnStart, HideStartupCharts = @HideStartupCharts, WhoUpdatedId = @UserId, WhenUpdated = GETDATE() WHERE UserID=@UserId and OperatingHospitalId = @OperatingHospitalId " &
                                        "ELSE INSERT INTO ERS_StartupSettings (OperatingHospitalId, SearchCriteria, SearchCriteriaOption , SearchCriteriaOptionPatientCount, SearchCriteriaOptionDate, SearchCriteriaOptionMonths,ExcludeDeadOption, ExcludeUGI, AllProcedures, Gastroscopy, ERCP, Colonoscopy, Proctoscopy, OutstandingCLO,OrderListOptions,ShowWorklistOnStartup, HideStartupCharts, UserId, WhoCreatedId, WhenCreated) VALUES (@OperatingHospitalId, @SearchCriteria,@SearchCriteriaOption,@SearchCriteriaOptionPatientCount,@SearchCriteriaOptionDate ,@SearchCriteriaOptionMonths, @ExcludeDeadOption, @ExcludeUGI, @AllProcedures,@Gastroscopy,@ERCP,@Colonoscopy, @Proctoscopy,@OutstandingCLO,@OrderListOptions, @ShowWorklistOnStart, @HideStartupCharts, @UserId,@UserId,GETDATE() )"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SearchCriteria", SearchCriteria))
            cmd.Parameters.Add(New SqlParameter("@SearchCriteriaOption", SearchCriteriaOption))
            If SearchCriteriaOptionPatientCount.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SearchCriteriaOptionPatientCount", SearchCriteriaOptionPatientCount))
            Else
                cmd.Parameters.Add(New SqlParameter("@SearchCriteriaOptionPatientCount", SqlTypes.SqlInt32.Null))
            End If
            If SearchCriteriaOptionDate.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SearchCriteriaOptionDate", SearchCriteriaOptionDate))
            Else
                cmd.Parameters.Add(New SqlParameter("@SearchCriteriaOptionDate", SqlTypes.SqlDateTime.Null))
            End If
            If SearchCriteriaOptionMonths.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SearchCriteriaOptionMonths", SearchCriteriaOptionMonths))
            Else
                cmd.Parameters.Add(New SqlParameter("@SearchCriteriaOptionMonths", SqlTypes.SqlInt32.Null))
            End If

            cmd.Parameters.Add(New SqlParameter("@ExcludeDeadOption", ExcludeDeadOption))
            cmd.Parameters.Add(New SqlParameter("@ExcludeUGI", ExcludeUGI))
            cmd.Parameters.Add(New SqlParameter("@AllProcedures", AllProcedures))
            cmd.Parameters.Add(New SqlParameter("@Gastroscopy", Gastroscopy))
            cmd.Parameters.Add(New SqlParameter("@ERCP", ERCP))
            cmd.Parameters.Add(New SqlParameter("@Colonoscopy", Colonoscopy))
            cmd.Parameters.Add(New SqlParameter("@Proctoscopy", Proctoscopy))
            cmd.Parameters.Add(New SqlParameter("@OutstandingCLO", OutstandingCLO))
            cmd.Parameters.Add(New SqlParameter("@OrderListOptions", OrderListOptions))
            cmd.Parameters.Add(New SqlParameter("@ShowWorklistOnStart", ShowWorklistOnStart))
            cmd.Parameters.Add(New SqlParameter("@HideStartupCharts", HideStartupCharts))
            cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function IsLAClassification(ByVal operatingHospitalId As Integer) As Boolean
        Dim dtSys As DataTable = GetSystemSettings()
        If dtSys.Rows.Count > 0 Then
            If dtSys.Rows(0)("OesophagitisClassification") Then
                Return True
            Else
                Return False
            End If
        Else
            Return False
        End If
    End Function

    Public Function IsPatientConsent() As Boolean
        Dim dtSys As DataTable = GetSystemSettings()
        If dtSys.Rows.Count > 0 Then
            If dtSys.Rows(0)("PatientConsent") Then
                Return True
            Else
                Return False
            End If
        Else
            Return False
        End If
    End Function
    Public Function IsPatientNotesAvailable() As Boolean
        Dim dtSys As DataTable = GetSystemSettings()
        If dtSys.Rows.Count > 0 Then
            If dtSys.Rows(0)("IsPatientNotesAvailableMandatory") Then
                Return True
            Else
                Return False
            End If
        Else
            Return False
        End If
    End Function
    'MH Added on 01 Sept 2021
    'MH Changed on 05 Oct 2021
    Public Function IsEvidenceOfCancerMandatory() As Boolean
        Try
            Dim dtSys As New DataTable
            Dim blnResult As Boolean = False

            '01 Sept 2021   :   MH Added EvidenceOfCancerMandatory
            '21 Sept 2021   :   MH Added MinimumPatientSearchOption
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("GetEvidenceOfCancerMandatoryFlag", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@operatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalId"))))
                cmd.Parameters.Add(New SqlParameter("@procedureId", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))))

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dtSys)
            End Using
            If dtSys.Rows.Count > 0 Then
                If dtSys.Rows(0)("IsCancerMandatory") Then
                    blnResult = True
                Else
                    blnResult = False
                End If
            Else
                blnResult = False
            End If
            Return blnResult
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in IsEvidenceOfCancerMandatory()", ex)
        End Try
    End Function
    'MH Added on 21 Sept 2021
    Public Function MinimumPatientSearchOption() As Integer
        Dim dtSys As DataTable = GetSystemSettings()
        If dtSys.Rows.Count > 0 Then
            If Not IsDBNull(dtSys.Rows(0)("MinimumPatientSearchOption")) Then
                Return CInt(dtSys.Rows(0)("MinimumPatientSearchOption"))
            Else
                Return 1
            End If
        Else
            Return 1
        End If
    End Function

    Public Function SaveSystemSettings(ByVal SiteIdentification As Short,
                                       ByVal PatientConsent As Short,
                                       ByVal IsEvidenceOfCancerMandatory As Short,
                                       ByVal IsPatientNotesAvailableMandatory As Boolean,
                                       ByVal ogdDiagnosis As Boolean,
                                       ByVal ureaseTestsIncludeTickBoxes As Boolean,
                                       ByVal SortReferringConsultantBy As Boolean,
                                       ByVal CompleteWHOSurgicalSafetyCheckList As Boolean,
                                       ByVal siteRadius As Nullable(Of Decimal),
                                       ByVal ReportLocking As Integer,
                                       ByVal LockingTime As String,
                                       ByVal LockingDays As Integer,
                                       ByVal NEDEnabled As Boolean,
                                       ByVal DefaultPatientStatus As Integer,
                                       ByVal DefaultPatientType As Integer,
                                       ByVal DefaultWard As Integer,
                                       ByVal BrtPulmonaryPhysiology As Integer,
                                       ByVal MinimumPatientSearchOption As Integer,
                                       ByVal OperatingHospitalId As Integer) As Integer
        'ByVal operatingHospitalId As Short, _
        ' ByVal applicationTimeout As Integer, _

        '01 Sept 2021   MH      Mahfuz added EvidenceOfCancerMandatory
        '21 Sept 2021   MH      Mahfuz added MinimumPatientSearchOption
        '14 Jan 2024    MH      added IsPatientNotesAvailableMandatory
        Dim sql As New StringBuilder
        Dim RetVal As Integer
        sql.Append("UPDATE TOP(1) ERS_SystemConfig ")
        'sql.Append("SET ApplicationTimeOut = @ApplicationTimeOut ")
        sql.Append("SET SiteIdentification = @SiteIdentification ")
        sql.Append(", SiteRadius = @SiteRadius ")
        sql.Append(", PatientConsent = @PatientConsent ")
        sql.Append(", IsEvidenceOfCancerMandatory = @IsEvidenceOfCancerMandatory ")
        sql.Append(", IsPatientNotesAvailableMandatory = @IsPatientNotesAvailableMandatory ")
        sql.Append(", OGDDiagnosis = @OGDDiagnosis ")
        sql.Append(", UreaseTestsIncludeTickBoxes = @UreaseTestsIncludeTickBoxes ")
        sql.Append(", SortReferringConsultantBy = @SortReferringConsultantBy ")
        sql.Append(", CompleteWHOSurgicalSafetyCheckList = @CompleteWHOSurgicalSafetyCheckList ")
        sql.Append(", ReportLocking = @ReportLocking ")
        sql.Append(", LockingTime = @LockingTime ")
        sql.Append(", LockingDays = @LockingDays ")
        sql.Append(", NEDEnabled = @NEDEnabled ")
        sql.Append(", DefaultPatientStatus = @DefaultPatientStatus ")
        sql.Append(", DefaultPatientType = @DefaultPatientType ")
        sql.Append(", DefaultWard = @DefaultWard ")
        sql.Append(", MinimumPatientSearchOption = @MinimumPatientSearchOption ")
        sql.Append(", BRTPulmonaryPhysiology = @BrtPulmonaryPhysiology ")
        sql.Append(", WhoUpdatedId = @LoggedInUserId ")
        sql.Append(", WhenUpdated = GetDate() ")
        sql.Append("WHERE OperatingHospitalID = @OperatingHospitalID")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalId))
            'cmd.Parameters.Add(New SqlParameter("@ApplicationTimeOut", applicationTimeout))
            cmd.Parameters.Add(New SqlParameter("@SiteIdentification", SiteIdentification))
            cmd.Parameters.Add(New SqlParameter("@PatientConsent", PatientConsent))
            cmd.Parameters.Add(New SqlParameter("@IsEvidenceOfCancerMandatory", IsEvidenceOfCancerMandatory))
            cmd.Parameters.Add(New SqlParameter("@IsPatientNotesAvailableMandatory", IsPatientNotesAvailableMandatory))
            cmd.Parameters.Add(New SqlParameter("@OGDDiagnosis", ogdDiagnosis))
            cmd.Parameters.Add(New SqlParameter("@UreaseTestsIncludeTickBoxes", ureaseTestsIncludeTickBoxes))
            cmd.Parameters.Add(New SqlParameter("@SortReferringConsultantBy", SortReferringConsultantBy))
            cmd.Parameters.Add(New SqlParameter("@CompleteWHOSurgicalSafetyCheckList", CompleteWHOSurgicalSafetyCheckList))
            cmd.Parameters.Add(New SqlParameter("@ReportLocking", ReportLocking))
            cmd.Parameters.Add(New SqlParameter("@LockingTime", LockingTime))
            cmd.Parameters.Add(New SqlParameter("@LockingDays", LockingDays))
            cmd.Parameters.Add(New SqlParameter("@NEDEnabled", NEDEnabled))
            If siteRadius.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SiteRadius", siteRadius.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@SiteRadius", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@DefaultPatientStatus", DefaultPatientStatus))
            cmd.Parameters.Add(New SqlParameter("@DefaultPatientType", DefaultPatientType))
            cmd.Parameters.Add(New SqlParameter("@DefaultWard", DefaultWard))
            cmd.Parameters.Add(New SqlParameter("@MinimumPatientSearchOption", MinimumPatientSearchOption))
            cmd.Parameters.Add(New SqlParameter("@BrtPulmonaryPhysiology", BrtPulmonaryPhysiology))
            connection.Open()
            RetVal = cmd.ExecuteNonQuery()
        End Using
        If CInt(HttpContext.Current.Session("OperatingHospitalId")) = OperatingHospitalId Then
            HttpContext.Current.Session("SystemSettings") = GetSystemSettingsFromDatabase(HttpContext.Current.Session("OperatingHospitalId"))
        End If
        Return RetVal
    End Function
#End Region

#Region "Password Rules"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPasswordRules() As DataTable 'Public Function GetPasswordRules(ByVal operatingHospitalId As Integer) As DataTable
        Dim dsPwdRules As New DataSet
        Dim sql As New StringBuilder
        sql.Append("SELECT top(1) PwdRuleMinLength, PwdRuleNoOfSpecialChars, PwdRuleNoSpaces, PwdRuleCantBeUserId, PwdRuleDaysToExpiration, PwdRuleNoOfPastPwdsToAvoid ")
        sql.Append("FROM ERS_SystemConfig ")
        'sql.Append("WHERE OperatingHospitalID = @OperatingHospitalID")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            'cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", operatingHospitalId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPwdRules)
        End Using

        If dsPwdRules.Tables.Count > 0 Then
            Return dsPwdRules.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdatePasswordRules(ByVal minLength As Nullable(Of Integer),
                                        ByVal noOfSpecialChars As Nullable(Of Integer),
                                        ByVal noSpaces As Boolean,
                                        ByVal cantBeUserId As Boolean,
                                        ByVal daysToExpiration As Nullable(Of Integer),
                                        ByVal noOfPastPwdsToAvoid As Nullable(Of Integer)) As Integer
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_SystemConfig ")
        sql.Append("SET PwdRuleMinLength = @PwdRuleMinLength, PwdRuleNoOfSpecialChars = @PwdRuleNoOfSpecialChars, PwdRuleNoSpaces = @PwdRuleNoSpaces, ")
        sql.Append("    PwdRuleCantBeUserId = @PwdRuleCantBeUserId, PwdRuleDaysToExpiration = @PwdRuleDaysToExpiration, PwdRuleNoOfPastPwdsToAvoid = @PwdRuleNoOfPastPwdsToAvoid, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() ")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text

            If minLength.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PwdRuleMinLength", minLength))
            Else
                cmd.Parameters.Add(New SqlParameter("@PwdRuleMinLength", SqlTypes.SqlInt32.Null))
            End If
            If noOfSpecialChars.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PwdRuleNoOfSpecialChars", noOfSpecialChars))
            Else
                cmd.Parameters.Add(New SqlParameter("@PwdRuleNoOfSpecialChars", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@PwdRuleNoSpaces", noSpaces))
            cmd.Parameters.Add(New SqlParameter("@PwdRuleCantBeUserId", cantBeUserId))
            If daysToExpiration.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PwdRuleDaysToExpiration", daysToExpiration))
            Else
                cmd.Parameters.Add(New SqlParameter("@PwdRuleDaysToExpiration", SqlTypes.SqlInt32.Null))
            End If
            If noOfPastPwdsToAvoid.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PwdRuleNoOfPastPwdsToAvoid", noOfPastPwdsToAvoid))
            Else
                cmd.Parameters.Add(New SqlParameter("@PwdRuleNoOfPastPwdsToAvoid", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))


            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function GetPreviousPasswords(ByVal userId As Integer, Optional noOfLatestRows As Integer = 0) As DataTable
        Dim dsPreviousPasswords As New DataSet
        Dim sql As New StringBuilder
        If noOfLatestRows > 0 Then
            sql.Append(String.Format("SELECT TOP {0} * ", noOfLatestRows))
        Else
            sql.Append("SELECT * ")
        End If
        sql.Append("FROM ERS_UserPasswords ")
        sql.Append("WHERE UserID = @UserID ")
        sql.Append("ORDER BY CreatedOn DESC ")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserID", userId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPreviousPasswords)
        End Using

        If dsPreviousPasswords.Tables.Count > 0 Then
            Return dsPreviousPasswords.Tables(0)
        End If
        Return Nothing
    End Function
#End Region

#Region "Registration Details"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRegistrationDetails(ByVal operatingHospitalId As Integer) As DataTable
        Dim dsRegDetails As New DataSet
        'Dim sql As String = "SELECT s.ReportHeading, s.ReportSubHeading, s.ReportFooter, s.ReportTrustType, s.DepartmentName, o.InternalHospitalID, o.NHSHospitalID, o.HospitalName, o.ContactNumber, o.ReportExportPath, s.NED_ExportPath, s.NED_HospitalSiteCode FROM ERS_SystemConfig s INNER JOIN ERS_OperatingHospitals o ON o.OperatingHospitalId = s.OperatingHospitalId WHERE o.OperatingHospitalID = @OperatingHospitalID"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            'Dim cmd As New SqlCommand(sql, connection)
            Dim cmd As New SqlCommand("get_registration_details", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsRegDetails)
        End Using

        If dsRegDetails.Tables.Count > 0 Then
            Return dsRegDetails.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function AddNewOperatingHospital(ByVal reportHeading As String,
                                            ByVal reportSubHeading As String,
                                            ByVal reportFooter As String,
                                            ByVal reportTrustType As String,
                                            ByVal departmentName As String,
                                            ByVal hospitalName As String,
                                            ByVal contactNumber As String,
                                            ByVal internalHospitalId As String,
                                            ByVal nhsHospitalId As String,
                                            ByVal pdfExportPath As String,
                                            ByVal copyPrintSettings As Boolean,
                                            ByVal copyPhraseLibrary As Boolean) As Integer
        Dim newId = 0



        Using db As New ERS.Data.GastroDbEntities

            Dim mainOperatingHospitals = db.ERS_OperatingHospitals

            Dim newRecord As New ERS.Data.ERS_OperatingHospitals
            With newRecord
                '.OperatingHospitalId = mainOperatingHospitals.OrderByDescending(Function(x) x.OperatingHospitalId).Select(Function(x) x.OperatingHospitalId).First() +1
                .InternalHospitalID = internalHospitalId
                .NHSHospitalID = nhsHospitalId
                .HospitalName = hospitalName
                .ContactNumber = contactNumber
                .ReportExportPath = pdfExportPath
            End With

            db.ERS_OperatingHospitals.Add(newRecord)
            db.SaveChanges()

            newId = newRecord.OperatingHospitalId
            Dim initialOHID = mainOperatingHospitals.First().OperatingHospitalId
            'get and mirror system config settings for new hospital
            Dim configSettings = db.ERS_SystemConfig.Where(Function(x) x.OperatingHospitalID = initialOHID).OrderBy(Function(x) x.SystemConfigID).FirstOrDefault()
            If configSettings IsNot Nothing Then

                With configSettings
                    .ReportHeading = reportHeading
                    .ReportSubHeading = reportSubHeading
                    .ReportFooter = reportFooter
                    .ReportTrustType = reportTrustType
                    .OperatingHospitalID = newId
                End With
                db.ERS_SystemConfig.Add(configSettings)
            End If

            If copyPrintSettings Then
                Dim gpPrintSetting = db.ERS_PrintOptionsGPReport.Where(Function(x) x.OperatingHospitalId = initialOHID).OrderBy(Function(x) x.GPReportID).FirstOrDefault()
                If gpPrintSetting IsNot Nothing Then
                    gpPrintSetting.OperatingHospitalId = newId
                    db.ERS_PrintOptionsGPReport.Add(gpPrintSetting)
                End If


                Dim labPrintSetting = db.ERS_PrintOptionsLabRequestReport.Where(Function(x) x.OperatingHospitalId = initialOHID).OrderBy(Function(x) x.RequestReportID).FirstOrDefault()
                If labPrintSetting IsNot Nothing Then
                    labPrintSetting.OperatingHospitalId = newId
                    db.ERS_PrintOptionsLabRequestReport.Add(labPrintSetting)
                End If


                Dim patientPrintSetting = db.ERS_PrintOptionsPatientFriendlyReport.Where(Function(x) x.OperatingHospitalId = initialOHID).OrderBy(Function(x) x.FriendlyReportID).FirstOrDefault()
                If patientPrintSetting IsNot Nothing Then
                    patientPrintSetting.OperatingHospitalId = newId
                    db.ERS_PrintOptionsPatientFriendlyReport.Add(patientPrintSetting)
                End If


                Dim patientAdditionalPrintSettings = db.ERS_PrintOptionsPatientFriendlyReportAdditional.Where(Function(x) x.OperatingHospitalId = initialOHID).OrderBy(Function(x) x.Id)
                For Each setting In patientAdditionalPrintSettings
                    setting.OperatingHospitalId = newId
                    db.ERS_PrintOptionsPatientFriendlyReportAdditional.Add(setting)
                Next
            End If

            If copyPhraseLibrary Then
                Dim dbPhraseLibrary = db.ERS_PhraseLibrary.Where(Function(x) x.OperatingHospitalId = initialOHID).OrderBy(Function(x) x.PhraseID).FirstOrDefault()
                If dbPhraseLibrary IsNot Nothing Then
                    With dbPhraseLibrary
                        .OperatingHospitalId = newId
                    End With
                    db.ERS_PhraseLibrary.Add(dbPhraseLibrary)
                End If
            End If


            db.SaveChanges()
        End Using

        Return newId
    End Function
    '08 Mar 2021 : Mahfuz added ImportPatientByWebservice
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateRegistrationDetails(ByVal operatingHospitalId As Integer,
                                              ByVal reportHeading As String,
                                              ByVal reportSubHeading As String,
                                              ByVal ReportFooter As String,
                                              ByVal reportTrustType As String,
                                              ByVal departmentName As String,
                                              ByVal trustId As Integer,
                                              ByVal hospitalName As String,
                                              ByVal contactNumber As String,
                                              ByVal internalHospitalId As String,
                                              ByVal nhsHospitalId As String,
                                              ByVal pdfExportPath As String,
                                              ByVal NEDExportPath As String,
                                              ByVal NEDODSCode As String,
                                              ByVal ImportPatientByWebservice? As Integer,
                                              ByVal blnAddExportFileForMirth As Boolean,
                                              ByVal blnSuppressMainReportPDF As Boolean,
                                              ByVal ExportDocumentFilePrefix As String) As Integer

        Dim sql As New StringBuilder
        sql.Append("UPDATE TOP(1) ERS_SystemConfig ")
        'sql.Append("SET ReportHeading = @ReportHeading,  ReportTrustType = @ReportTrustType, ReportSubHeading = @ReportSubHeading, ReportFooter = @ReportFooter, DepartmentName = @DepartmentName, NED_ExportPath = @NEDExportPath, NED_HospitalSiteCode = @NEDODSCode WHERE OperatingHospitalID = @OperatingHospitalId; ")
        sql.Append("SET ReportHeading = @ReportHeading,  ReportTrustType = @ReportTrustType, ReportSubHeading = @ReportSubHeading, ReportFooter = @ReportFooter, DepartmentName = @DepartmentName WHERE OperatingHospitalID = @OperatingHospitalId; ")
        sql.Append("UPDATE ERS_OperatingHospitals SET TrustId = @TrustId, HospitalName = @HospitalName, ContactNumber = @ContactNumber, InternalHospitalID = @InternalHospitalID, NHSHospitalID = @NHSHospitalID, ReportExportPath = @ReportExportPath, ImportPatientByWebservice = @ImportPatientByWebservice,AddExportFileForMirth = @blnAddExportFileForMirth,SuppressMainReportPDF = @blnSuppressMainReportPDF, ExportDocumentFilePrefix = @ExportDocumentFilePrefix WHERE OperatingHospitalID = @OperatingHospitalID")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", operatingHospitalId))
            If String.IsNullOrEmpty(reportHeading) Then
                cmd.Parameters.Add(New SqlParameter("@ReportHeading", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@ReportHeading", reportHeading))
            End If
            cmd.Parameters.Add(New SqlParameter("@ReportSubHeading", reportSubHeading))
            cmd.Parameters.Add(New SqlParameter("@ReportFooter", ReportFooter))
            cmd.Parameters.Add(New SqlParameter("@ReportTrustType", reportTrustType))
            cmd.Parameters.Add(New SqlParameter("@DepartmentName", departmentName))
            cmd.Parameters.Add(New SqlParameter("@TrustId", trustId))
            cmd.Parameters.Add(New SqlParameter("@HospitalName", hospitalName))
            cmd.Parameters.Add(New SqlParameter("@ContactNumber", contactNumber))
            cmd.Parameters.Add(New SqlParameter("@InternalHospitalID", internalHospitalId))
            cmd.Parameters.Add(New SqlParameter("@NHSHospitalID", nhsHospitalId))
            cmd.Parameters.Add(New SqlParameter("@ReportExportPath", pdfExportPath))
            cmd.Parameters.Add(New SqlParameter("@NEDExportPath", NEDExportPath))
            cmd.Parameters.Add(New SqlParameter("@NEDODSCode", NEDODSCode))

            If Not IsNothing(ImportPatientByWebservice) Then
                cmd.Parameters.Add(New SqlParameter("@ImportPatientByWebservice", ImportPatientByWebservice))
            Else
                cmd.Parameters.Add(New SqlParameter("@ImportPatientByWebservice", SqlTypes.SqlInt16.Null))
            End If

            cmd.Parameters.Add(New SqlParameter("@blnAddExportFileForMirth", blnAddExportFileForMirth))
            cmd.Parameters.Add(New SqlParameter("@blnSuppressMainReportPDF", blnSuppressMainReportPDF))
            cmd.Parameters.Add(New SqlParameter("@ExportDocumentFilePrefix", ExportDocumentFilePrefix))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

#Region "Lists"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetListMaintenance(ByVal listDescription As String, ByVal showSuppressed As String) As DataTable

        Dim dsList As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("usp_get_list_maintenance", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ListDescription", listDescription))

            If Not String.IsNullOrWhiteSpace(showSuppressed) Then
                cmd.Parameters.Add(New SqlParameter("@ShowSuppressed", CBool(showSuppressed)))
            Else
                cmd.Parameters.Add(New SqlParameter("@ShowSuppressed", DBNull.Value))
            End If

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsList)
        End Using

        If dsList.Tables.Count > 0 Then
            Return dsList.Tables(0)
        End If
        Return Nothing
    End Function
#End Region

#Region "FieldLabels"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetFieldLabels(ByVal AppPageName As String, ByVal ProcedureType As Integer) As DataTable

        Dim dsList As New DataSet
        'Dim sql As String = "SELECT f.* FROM ERS_FieldLabels f 
        '                        INNER JOIN ERS_Pages p ON f.PageID = p.PageId 
        '                    WHERE (f.ProcedureType IN (SELECT [item] FROM dbo.fnSplitString(CONVERT(VARCHAR(10), @ProcedureType) + ',0',',') WHERE [item] IN (@ProcedureType,'0')) AND p.AppPageName = @AppPageName) 
        '                        OR  (p.AppPageName IN (@AppPageName, 'DefaultPage') AND f.PageID=(SELECT PageId FROM ERS_Pages pp WHERE pp.AppPageName = 'DefaultPage')) 
        '                    ORDER BY LabelName ASC" 'filter on specific proceduretypeid or 0 (0 means all applites)


        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("usp_get_page_required_fields", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@AppPageName", AppPageName))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", ProcedureType))
            connection.Open()
            adapter.Fill(dsList)
        End Using

        If dsList.Tables.Count > 0 Then
            Return dsList.Tables(0)
        End If
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetFieldLabels(ByVal PageID As String) As DataTable

        Dim dsList As New DataSet
        Dim sql As String = "SELECT *, CASE WHEN ControlType in ('Label','Button', 'RadButton') THEN 1 ELSE ISNULL(CannotBeSuppressed,0) END AS RequiredCannotBeSuppressed
                            FROM ERS_FieldLabels
                            WHERE PageID = @PageID ORDER BY LabelName ASC"

        '"SELECT * FROM ERS_FieldLabels WHERE PageID = @PageID  ORDER BY LabelName ASC"
        'sql.Append("SELECT * FROM ERS_FieldLabels ")
        'sql.Append("WHERE FormName = '" & formName & "' ")
        'sql.Append("ORDER BY LabelName ASC ")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@PageID", PageID))
            connection.Open()
            adapter.Fill(dsList)
        End Using

        If dsList.Tables.Count > 0 Then
            Return dsList.Tables(0)
        End If
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedures() As DataTable
        Dim dsList As New DataSet
        Dim sql As String = "SELECT * FROM ERS_ProcedureTypes"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsList)
        End Using
        If dsList.Tables.Count > 0 Then
            Return dsList.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateFieldLabels(ByVal FieldLabelID As Integer, ByVal OverrideText As String, ByVal PluralText As String, ByVal HintText As String, ByVal TextColour As String, ByVal ProcedureType As String, ByVal Required As Boolean, ByVal FieldName As String) As Integer
        Dim sql As New StringBuilder

        sql.Append("UPDATE ERS_FieldLabels ")
        sql.Append("SET Override=@OverrideText ")
        sql.Append(", Plural=@PluralText ")
        sql.Append(", Hint=@HintText ")
        sql.Append(", Colour=@TextColour ")
        sql.Append(", ProcedureType=@ProcedureType ")
        sql.Append(", Required=@Required ")
        sql.Append(", FieldName=@FieldName ")
        sql.Append(", WhoUpdatedId=@LoggedInUserId ")
        sql.Append(", WhenUpdated=GETDATE()")
        sql.Append(" WHERE FieldLabelID=@FieldLabelID ")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@FieldLabelID", FieldLabelID))
            cmd.Parameters.Add(New SqlParameter("@Required", Required))
            cmd.Parameters.Add(New SqlParameter("@OverrideText", OverrideText))
            cmd.Parameters.Add(New SqlParameter("@PluralText", PluralText))
            cmd.Parameters.Add(New SqlParameter("@HintText", HintText))
            cmd.Parameters.Add(New SqlParameter("@TextColour", TextColour))
            cmd.Parameters.Add(New SqlParameter("@FieldName", FieldName))
            'cmd.Parameters.Add(New SqlParameter("@ControlType", ControlType))
            If String.IsNullOrEmpty(ProcedureType) Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureType", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureType", ProcedureType))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)> _
    'Public Function UpdateFieldLabels(ByVal LabelName As String, _
    '                                  ByVal Override As String, _
    '                                  ByVal FieldLabelId As Integer, _
    '                                  ByVal Plural As String, _
    '                                    ByVal Hint As String) As Integer

    '    Dim sql As String = "UPDATE ERS_FieldLabels " & _
    '                        " SET Override=@Override, Plural=@Plural, Hint=@Hint " & _
    '                        " WHERE FieldLabelId=@FieldLabelId"

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand(sql, connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@FieldLabelId", FieldLabelId))
    '        cmd.Parameters.Add(New SqlParameter("@Override", Override))
    '        cmd.Parameters.Add(New SqlParameter("@Plural", Plural))
    '        cmd.Parameters.Add(New SqlParameter("@Hint", Hint))

    '        connection.Open()
    '        Return cmd.ExecuteNonQuery()
    '    End Using
    'End Function


#End Region
#Region "Sections"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSectionList() As DataTable

        Dim dsList As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_section_list", connection)
            cmd.CommandType = CommandType.StoredProcedure


            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsList)
        End Using

        If dsList.Tables.Count > 0 Then
            Return dsList.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function MaintenanceListSelectByType(ByVal listDescription As String, ByVal showSuppressed As String) As List(Of ERS.Data.ERS_Lists)

        Dim result As New List(Of ERS.Data.ERS_Lists)
        Try
            Using db As New ERS.Data.GastroDbEntities
                result = db.ERS_Lists.Where(Function(x) _
                                                x.ListDescription.Equals("listDescription") _
                                                And (showSuppressed = "true" AndAlso x.Suppressed = True)) _
                                                .OrderBy(Function(x) x.ListItemNo).ToList()
            End Using

            Return result
        Catch ex As Exception
            Return New List(Of ERS.Data.ERS_Lists)
        End Try


        'Dim dsList As New DataSet
        'Dim sql As New StringBuilder
        'sql.Append("SELECT * FROM ERS_Lists ")
        'sql.Append("WHERE ListDescription = '" & listDescription & "' ")
        'If showSuppressed.ToLower <> "true" Then
        '    sql.Append("AND Suppressed = 0  ")
        'End If
        'sql.Append("ORDER BY ListItemNo ASC ")

        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand(sql.ToString(), connection)
        '    cmd.CommandType = CommandType.Text
        '    Dim adapter = New SqlDataAdapter(cmd)

        '    connection.Open()
        '    adapter.Fill(dsList)
        'End Using

        'If dsList.Tables.Count > 0 Then
        '    Return dsList.Tables(0)
        'End If
        'Return Nothing
    End Function
#End Region
#Region "Question"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetQuestionList() As DataTable

        Dim dsList As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_PreAssessmentQuestions_list", connection)
            cmd.CommandType = CommandType.StoredProcedure

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsList)
        End Using

        If dsList.Tables.Count > 0 Then
            Return dsList.Tables(0)
        End If
        Return Nothing
    End Function
#End Region
#Region "Nurse Module"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetNurseModuleSectionList() As DataTable

        Dim dsList As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_nurse_module_section_list", connection)
            cmd.CommandType = CommandType.StoredProcedure


            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsList)
        End Using

        If dsList.Tables.Count > 0 Then
            Return dsList.Tables(0)
        End If
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetNurseModuleQuestionList() As DataTable

        Dim dsList As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_nurse_module_question_list", connection)
            cmd.CommandType = CommandType.StoredProcedure

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsList)
        End Using

        If dsList.Tables.Count > 0 Then
            Return dsList.Tables(0)
        End If
        Return Nothing
    End Function
#End Region
End Class
