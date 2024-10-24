Imports System.IO
Imports Microsoft.VisualBasic
'Imports Microsoft.Practices.EnterpriseLibrary.Common.Configuration
'Imports Microsoft.Practices.EnterpriseLibrary.Logging
'Imports Microsoft.Practices.EnterpriseLibrary.Logging.Filters
'Imports Microsoft.Practices.EnterpriseLibrary.Logging.ExtraInformation
'Imports Microsoft.Practices.EnterpriseLibrary.Data
'Imports Microsoft.Practices.EnterpriseLibrary.Logging.Database
'Imports Microsoft.Practices.EnterpriseLibrary.Logging.Formatters
'Imports Microsoft.Practices.EnterpriseLibrary.Logging.TraceListeners

Public Class LogManager
    Inherits System.Web.UI.Page

    'Private Shared defaultWriter As LogWriter

    Private Shared ReadOnly _instance As New Lazy(Of LogManager)(Function() New LogManager(), System.Threading.LazyThreadSafetyMode.ExecutionAndPublication)
    Private Shared singleInstance As LogManager
    Private errorWhileReportingToBase As Boolean = False

    'Public ReadOnly Property LogManagerInstance As LogManager
    '    Get
    '        Return _instance.Value
    '    End Get
    'End Property

    Public Shared ReadOnly Property LogManagerInstance() As LogManager
        Get
            If singleInstance Is Nothing Then
                singleInstance = New LogManager
            End If
            Return singleInstance
        End Get
    End Property

    Public Function LogError(ByVal errorDescription As String, ByVal ex As Exception) As String
        Dim ref As String

        Try

            Dim strMessage As String = ex.Message.ToString
            'Line below is mainly for OtherData pages when exiting form after saving. An exception occurs when redirecting - no need to log this.
            If strMessage.Contains("Thread was being aborted.") AndAlso errorDescription.Contains("Error occurred while saving") Then Return ""

            Dim da As New DataAccess
            'da.InsertError("1234", "monkeys jumping on my back", "", 1, "1.1", "rama", "", "", 1, "")

            'Dim proxtest As New UnisoftWebService.ServiceClient
            'Return proxtest.ReportVB6RemoteError("1.0.3", "rama", 99, "Add Patient", "1033", "monkeys jumping", "GY00001", 1043, True)

            Dim userId As String = ""
            Dim procedureId As Nullable(Of Integer) = Nothing
            Dim patientId As Nullable(Of Integer) = Nothing
            Dim caseNoteNo As String = ""

            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
            End If

            If HttpContext.Current.Session IsNot Nothing AndAlso HttpContext.Current.Session.Keys.Count > 0 Then
                userId = CStr(HttpContext.Current.Session("UserID"))
                If HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID) IsNot Nothing Then
                    procedureId = CStr(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))
                Else
                    procedureId = CStr(HttpContext.Current.Session(Constants.SESSION_EPISODE_NO))
                End If
                If HttpContext.Current.Session(Constants.SESSION_CASE_NOTE_NO) IsNot Nothing Then caseNoteNo = CStr(HttpContext.Current.Session(Constants.SESSION_CASE_NOTE_NO))
            End If

            Dim innerException = ""
            If ex.InnerException IsNot Nothing Then
                innerException = If(ex.InnerException.Message, "")
            End If
            'Iff(ex.InnerException IsNot Nothing, ex.InnerException.InnerException.Message, Nothing)
            ref = da.InsertError(CStr(ex.HResult),
                           ex.Message,
                           errorDescription,
                           ex.StackTrace,
                           innerException,
                           "",
                           1,
                           HttpContext.Current.Session("SESSION_APPVERSION"),
                           userId,
                           "",
                           procedureId,
                           patientId,
                           caseNoteNo,
                           ConfigurationManager.AppSettings("Unisoft.HospitalID"),
                           HttpContext.Current.Session("OperatingHospitalID"))

            If ConfigurationManager.AppSettings("Unisoft.ReportToBase") = True Then
                If Not errorWhileReportingToBase Then
                    ReportErrorToBase(ref, errorDescription, ex, userId, procedureId, patientId, caseNoteNo)
                End If
            End If

        Catch exc As Exception
            'cant do anything as not able to save error message if we've reached here.. Maybe log an event log message or to a text file?
        End Try
        Return ref
    End Function

    Private Sub ReportErrorToBase(ByVal ref As String,
                                  ByVal errorDescription As String,
                                  ByVal ex As Exception,
                                  ByVal userId As String,
                                  ByVal procedureId As Nullable(Of Integer),
                                  ByVal patientId As Nullable(Of Integer),
                                  ByVal caseNoteNo As String)
        Try
            Dim prox As New UnisoftWebService.ServiceClient
            prox.ReportError(ref,
                             CStr(ex.HResult),
                             ex.Message,
                             errorDescription,
                             ex.StackTrace,
                             "",
                             1,
                             Session(Constants.SESSION_APPVERSION),
                             userId,
                             "",
                             procedureId,
                             patientId,
                             caseNoteNo,
                             ConfigurationManager.AppSettings("Unisoft.HospitalID"),
                             Session("OperatingHospitalID"))

        Catch ex2 As Exception
            errorWhileReportingToBase = True
            LogError("Error while reporting a system error to HD Clinical.", ex2)
        End Try
    End Sub

    'Public Shared Sub LogToDatabase(ByVal message As String, ByVal extendedProperties As Dictionary(Of String, Object))

    '    'Using connection As New SqlConnection(ConfigurationManager.ConnectionStrings("SampleDB").ConnectionString)
    '    '    'Dim cmd As New SqlCommand("insert into category values ('test2')", connection)
    '    '    Dim cmd As New SqlCommand("insert into [table] values (1, 'test')", connection)
    '    '    cmd.Connection.Open()
    '    '    cmd.ExecuteNonQuery()
    '    'End Using

    '    'Dim loggingConfiguration As LoggingConfiguration =
    '    'defaultWriter = New LogWriter(loggingConfiguration)

    '    ' Check if logging is enabled before creating log entries.
    '    'If defaultWriter.IsLoggingEnabled() Then
    '    ' Create a Dictionary of extended properties
    '    'Dim exProperties As New Dictionary(Of String, Object)()
    '    'exProperties.Add("Extra Information", "Some Special Value")
    '    ' Create a LogEntry using the constructor parameters. 
    '    'defaultWriter.Write("Log entry with category, priority, event ID, severity, title, and extended properties.", "Database", 5, 9008, TraceEventType.Warning, "Logging Block Examples", _
    '    '    exProperties)
    '    'Console.WriteLine("Created a log entry with a category, priority, event ID, severity, title, and   extended properties.")
    '    'Console.WriteLine()

    '    'Dim configurationSource As IConfigurationSource = ConfigurationSourceFactory.Create()
    '    'Dim logWriterFactory As New LogWriterFactory(configurationSource)
    '    'Logger.SetLogWriter(logWriterFactory.Create())

    '    DatabaseFactory.SetDatabaseProviderFactory(New DatabaseProviderFactory())
    '    Dim logWriterFactory As New LogWriterFactory()
    '    Logger.SetLogWriter(logWriterFactory.Create())

    '    Dim cats As New List(Of String)
    '    cats.Add("Database")

    '    Dim entry As New LogEntry()
    '    With entry
    '        .Categories = cats
    '        .Priority = 8
    '        .EventId = 9000
    '        .Severity = TraceEventType.Error
    '        .Title = "Unisoft App"
    '        .ExtendedProperties = extendedProperties
    '        .Message = message
    '    End With

    '    ' Create a LogEntry using the constructor parameters. 
    '    'Dim entry As New LogEntry("LogEntry with category, priority, event ID, severity, title, and extended properties.", "Database",
    '    '                          8, 9009, TraceEventType.Error, "Logging Block Examples", _
    '    '                          extendedProperties)
    '    'defaultWriter.Write(entry)
    '    Logger.Write(entry)
    '    'Console.WriteLine("Created and written LogEntry with a category, priority, event ID, severity,     title, and extended properties.")
    '    'Console.WriteLine()
    '    'Console.WriteLine("Open the 'Logging.mdf' database in the Bin\Debug folder to see the results.")
    '    'Else
    '    '    Console.WriteLine("Logging is disabled in the configuration.")
    '    'End If
    'End Sub
    Public Sub LogMessage(messageDescription As String)
        Dim messageDate As String = String.Format("Time: {0}", DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss tt"))
        Dim message As String

        Dim Debugpath = Server.MapPath("~/App_Data") & "\Debuglog\"
        message = String.Format(" {0} : Message: {1}", messageDate, messageDescription)
        Dim path As String = Debugpath & "Debuglog.txt"
        If Not Directory.Exists(Debugpath) Then
            Directory.CreateDirectory(Debugpath)
        End If

        Using writer As New StreamWriter(path, True)
            writer.WriteLine(message)
            writer.Close()
        End Using
    End Sub
End Class
