Imports ERS.Data
Imports Hl7.Fhir.Model

Public Class AuditLogManager
    Implements IDisposable

    Private _Category As Integer
    Private _EventType As EVENT_TYPE
    Private _ApplicationID As APP_ID_ENUM
    Private _AppVersion As String
    Private _UserID As String
    Private _FullUsername As String
    Private _StationID As String
    Private _HospitalID As Integer
    Private _HospitalName As String
    Private _OperatingHospitalID As Integer
    Private _OperatingHospitalName As String
    Private _PatientNo As String
    Private _EpisodeNo As Integer
    Private _CaseNoteNo As String
    Private _ProcedureID As Integer
    Private _ProcedureDate As Nullable(Of DateTime)
    Private _ProcedureName As String
    Private _EventDescription As String
    Private _DatabaseName As String

    Private _Request As HttpRequest
    Protected _disposed As Boolean = False


    Sub New(Request As System.Web.HttpRequest)
        _Request = Request
    End Sub

    Sub New()
        '### To create a Blank instance!
    End Sub

    Public ReadOnly Property DisableAuditLog As Boolean
        Get
            Return CBool(HttpContext.Current.Session("DisableAuditLog"))
        End Get
    End Property
    Public Property Category As Nullable(Of Integer)
        Get
            Return _Category
        End Get
        Set(value As Nullable(Of Integer))
            _Category = value
        End Set
    End Property
    Public Property EventType As Nullable(Of Integer)
        Get
            Return CInt(_EventType)
        End Get
        Set(value As Nullable(Of Integer))
            _EventType = value
        End Set
    End Property

    Public Property ApplicationID As Nullable(Of Integer)
        Get
            Return CInt(_ApplicationID)
        End Get
        Set(value As Nullable(Of Integer))
            _ApplicationID = value
        End Set
    End Property
    Public ReadOnly Property AppVersion As String
        Get
            Return CStr(HttpContext.Current.Session(Constants.SESSION_APPVERSION))
        End Get
    End Property
    Public ReadOnly Property UserID As String
        Get
            Return CStr(HttpContext.Current.Session("UserID"))
        End Get
    End Property
    Public ReadOnly Property FullUsername As String
        Get
            Return CStr(HttpContext.Current.Session("FullName"))
        End Get
    End Property
    Public ReadOnly Property StationID As String
        Get
            Return CStr(HttpContext.Current.Session("RoomName"))  ' System.Net.Dns.GetHostEntry(_Request.ServerVariables("remote_addr")).HostName.Split(".")(0)
        End Get
    End Property
    Public ReadOnly Property HospitalID As Nullable(Of Integer)
        Get
            Return CStr(HttpContext.Current.Session("HospitalID"))
        End Get
    End Property
    Public ReadOnly Property HospitalName As String
        Get
            Return CStr(HttpContext.Current.Session("HospitalName"))
        End Get
    End Property

    Public ReadOnly Property OperatingHospitaID As Nullable(Of Integer)
        Get
            Return CStr(HttpContext.Current.Session("OperatingHospitalID"))
        End Get
    End Property
    Public Property OperatingHospitalName As String
        Get
            Return _OperatingHospitalName
        End Get
        Set(value As String)
            _OperatingHospitalName = value
        End Set
    End Property
    Public ReadOnly Property PatientNo As String
        Get
            Dim patientId As Int32 = 0
            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
            End If
            Return CStr(patientId)
        End Get
    End Property

    Public ReadOnly Property EpisodeNo As Nullable(Of Integer)
        Get
            Return CInt(HttpContext.Current.Session(Constants.SESSION_EPISODE_NO))
        End Get
    End Property

    Public ReadOnly Property CaseNoteNo As String
        Get
            Return CStr(HttpContext.Current.Session(Constants.SESSION_CASE_NOTE_NO))
        End Get
    End Property
    Public ReadOnly Property ProcedureID As Nullable(Of Integer)
        Get
            Return CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))
        End Get
    End Property
    Public Property ProcedureDate As Nullable(Of DateTime)
        Get
            Return _ProcedureDate
        End Get
        Set(value As Nullable(Of DateTime))
            _ProcedureDate = value
        End Set
    End Property
    Public Property ProcedureName As String
        Get
            Return _ProcedureName
        End Get
        Set(value As String)
            _ProcedureName = value
        End Set
    End Property
    Public Property EventDescription As String
        Get
            Return _EventDescription
        End Get
        Set(value As String)
            _EventDescription = value
        End Set
    End Property
    Public ReadOnly Property DatabaseName As String
        Get
            Return CStr(HttpContext.Current.Session("ConnectionDatabaseName"))
        End Get
    End Property

    'Public Sub SaveAuditLog()
    '    If Not DisableAuditLog Then
    '        Dim ds As New DataAccess
    '        ds.SaveAuditLog(
    '            Category,
    '            EventType,
    '            ApplicationID,
    '            AppVersion,
    '            UserID,
    '            FullUsername,
    '            StationID,
    '            HospitalID,
    '            HospitalName,
    '            OperatingHospitaID,
    '            OperatingHospitalName,
    '            PatientNo,
    '            EpisodeNo,
    '            CaseNoteNo,
    '            ProcedureID,
    '            ProcedureDate,
    '            ProcedureName,
    '            EventDescription, DatabaseName)
    '    End If
    'End Sub

    ''' <summary>
    ''' This will write a LogRecord in the master Audit Table. And will return the MasterAuditId.
    ''' This MasterAuditId will be used to insert Activity Log in the [ERS_AuditLog_Details] Table
    ''' </summary>
    ''' <remarks></remarks>
    ''' <returns>Returns MasterLogID</returns>
    Public Function WriteLogInDetailsMasterLog() As Integer
        If DisableAuditLog Then Return 0

        Dim logInfo As New ERS.Data.ERS_AuditLog

        Try
            With logInfo
                .ApplicationID = ApplicationID
                .AppVersion = AppVersion
                .DatabaseName = "Gastro"
                '.Datestamp = Now.ToShortDateString()
                'logInfo.DatabaseName '## Deafult in the Database Already!
                .HospitalID = HospitalID
                .OperatingHospitalID = OperatingHospitaID
                .StationID = StationID
                .UserID = UserID
                .Datestamp = Now
            End With

            Using db As New ERS.Data.GastroDbEntities
                db.ERS_AuditLog.Add(logInfo)
                db.SaveChanges()
                Return logInfo.Id '### Will return the last RecordId.. this will be used for All other Activities of this User
            End Using

        Catch ex As Exception
            Dim lm As New LogManager
            lm.LogError("Audit Log entry Failed at- Class AuditLogManager=>Public Shared Sub WriteLogInDetailsLog()", ex)
            Return 0
        End Try
    End Function

    ''' <summary>
    ''' This will write all sorts of User Activities - any DML/DDL o nthe Database!
    ''' </summary>
    ''' <param name="logInfo">Event Details Class</param>
    ''' <remarks></remarks>
    Public Sub WriteActivityLog(ByVal logInfo As ERS.Data.ERS_AuditLog_Details)
        If DisableAuditLog Then Exit Sub
        Try
            Using db As New ERS.Data.GastroDbEntities
                db.ERS_AuditLog_Details.Add(logInfo)
                db.SaveChanges()
            End Using
        Catch ex As Exception
            Dim lm As New LogManager
            lm.LogError("Audit Log entry Failed at- Class AuditLogManager=>Public Shared Sub WriteLog", ex)
        End Try
    End Sub

    ''' <summary>
    ''' This will write all sorts of User Activities - any DML/DDL o nthe Database!
    ''' </summary>
    ''' <param name="activityType">Activity Type Enum value</param>
    ''' <param name="logMessage">Description of the Activity</param>
    ''' <remarks></remarks>
    Public Sub WriteActivityLog(ByVal activityType As EVENT_TYPE, ByVal logMessage As String)

        If DisableAuditLog Then Exit Sub

        Dim logInfo As New ERS.Data.ERS_AuditLog_Details

        Try
            With logInfo
                .MasterLogID = Convert.ToInt32(System.Web.HttpContext.Current.Session(Constants.SESSION_MASTER_AUDIT_LOGID))
                .ProcedureID = IIf(ProcedureID = 0, Nothing, ProcedureID)
                .PatientNo = PatientNo
                .EventType = activityType
                .Category = 0
                .EventDescription = logMessage
                .DateStamp = Now
            End With

            Using db As New ERS.Data.GastroDbEntities
                db.ERS_AuditLog_Details.Add(logInfo)
                db.SaveChanges()
            End Using

        Catch ex As Exception
            Dim lm As New LogManager
            lm.LogError("Audit Log entry Failed at- Class AuditLogManager=>Public Shared Sub WriteLog", ex)
        End Try
    End Sub


#Region "IDisposable Members"

    Public Sub Dispose() Implements IDisposable.Dispose
        Dispose(True)
        GC.SuppressFinalize(Me)
    End Sub

    Protected Overridable Sub Dispose(disposing As Boolean)
        If Not _disposed Then
            ' Need to dispose managed resources if being called manually
            _disposed = True
        End If
    End Sub

#End Region
End Class
