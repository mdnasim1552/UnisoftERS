Imports System
Imports System.ComponentModel
Imports System.Configuration
Imports System.Configuration.Install
Imports System.Diagnostics
Imports System.DirectoryServices
Imports System.IO
Imports System.Web.Configuration
Imports System.Windows.Forms
Imports System.Reflection
Imports System.Data.SqlClient
Imports System.Threading
Imports System.Collections.ObjectModel
Imports System.Text.RegularExpressions


Public Class DatabaseOptionsInstaller
    Inherits Installer
    Private ConDic As New Dictionary(Of String, String)
    Public Property targetSite As String
    Public Property targetVDir As String
    Public Property targetDirectory As String
    Public Property friendlySiteName As String
    'Private Property sqlDirectory As String

    Dim iniFile As String
    Dim DESKey As String = "un116.205g053#"
    Dim Encrypto As New Simple3Des(DESKey)

    Public Overrides Sub Install(stateSaver As System.Collections.IDictionary)
        MyBase.Install(stateSaver)

        ' Retrieve configuration settings
        targetSite = Context.Parameters("targetsite")
        targetVDir = Context.Parameters("targetvdir")
        targetDirectory = Context.Parameters("targetdir")
        'sqlDirectory = Path.GetDirectoryName(Context.Parameters("srcdir")) + "\SQLScripts"

        If targetSite Is Nothing Then
            Throw New InstallException("IIS Site Name Not Specified!")
        End If

        If targetSite.StartsWith("/LM/") Then
            targetSite = targetSite.Substring(4)
        End If


        'show bNetwork.ini file dialog 
        PromptNetworkIni()

        'display web setup form 
        ConfigureSettings()

        saveNetworkIni()

        'set up directory where sql scripts reside.
        'SetSqlScriptFolder()
        DatabaseOptionsInstaller()

        ConfigureReport()
    End Sub
    'Private Sub SetSqlScriptFolder()
    '    Dim newThread As New Thread(AddressOf showSQLFolder)
    '    newThread.SetApartmentState(ApartmentState.STA)
    '    newThread.Start()
    '    newThread.Join()
    'End Sub
    'Sub showSQLFolder()
    '    Dim dfolder As New FolderBrowserDialog
    '    dfolder.ShowDialog()
    '    Dim foldername As String = dfolder.SelectedPath
    '    While foldername = "" Or Not Directory.Exists(foldername)
    '        MsgBox("Invalid path specified. Please select a valid path for the SQL queries.")
    '        dfolder.ShowDialog()
    '        foldername = dfolder.SelectedPath
    '    End While
    '    If foldername = "" Then Throw New Exception("Invalid directory specified.")
    '    sqlPath = foldername
    'End Sub

    'Private Sub ()
    '    Dim newThread As New Thread(AddressOf showDiag)
    '    newThread.SetApartmentState(ApartmentState.STA)
    '    newThread.Start()
    '    newThread.Join()
    'End Sub
    Sub PromptNetworkIni()
        Dim netINI As New NetworkIniForm(Context.Parameters("srcdir"))
        Dim inidlg As DialogResult = netINI.ShowDialog
        If inidlg <> DialogResult.OK Or netINI.NetworkIniName = "" Then
            Throw New Exception("File 'bnetwork.ini' not specified. This installation will now terminate.")
        End If
        iniFile = netINI.NetworkIniName
    End Sub
    Sub saveNetworkIni()
        Dim conf As Configuration = WebConfigurationManager.OpenWebConfiguration(Convert.ToString("/") & targetVDir, friendlySiteName)
        Using reader As New System.IO.StreamReader(iniFile)
            While Not reader.EndOfStream
                Dim txt As String() = reader.ReadLine.Split("=")
                If txt(0) = "Registered Hospital" Then saveConfig(conf, "Unisoft.Hospital", txt(1))
                If txt(0) = "Report Title" Then saveConfig(conf, "unisoft.ReportTitle", txt(1))
                If txt(0) = "Internal 3" Then saveConfig(conf, "Unisoft.HospitalID", txt(1))
            End While
        End Using
        conf.Save()
        ConfigurationManager.RefreshSection("appSettings")
    End Sub
    Private Sub ConfigureReport()
        Dim conf As Configuration = WebConfigurationManager.OpenWebConfiguration(Convert.ToString("/") & targetVDir, friendlySiteName)
        If conf.AppSettings.Settings("Unisoft.IsERSViewer") IsNot Nothing AndAlso CBool(conf.AppSettings.Settings("Unisoft.IsERSViewer").Value) = False Then
            Dim report As String = InputBox("Enter reporting server url:", "ERS Reporting Server Prompt")
            If report <> "" Then
                If conf.AppSettings.Settings("Unisoft.Reportserver") IsNot Nothing Then
                    conf.AppSettings.Settings.Remove(conf.AppSettings.Settings("Unisoft.Reportserver").Key)
                End If

                conf.AppSettings.Settings.Add("Unisoft.Reportserver", report)
                conf.Save()
                ConfigurationManager.RefreshSection("appSettings")
            End If
        End If
    End Sub
    Private Sub saveConfig(conf As Configuration, ckey As String, cvalue As String)
        If conf.AppSettings.Settings(ckey) IsNot Nothing Then
            conf.AppSettings.Settings.Remove(conf.AppSettings.Settings(ckey).Key)
        End If
        conf.AppSettings.Settings.Add(ckey, cvalue)
    End Sub
    Private Sub ConfigureSettings()
        ' Retrieve "Friendly Site Name" from IIS for TargetSite
        Dim entry As New DirectoryEntry(Convert.ToString("IIS://LocalHost/") & targetSite)
        friendlySiteName = entry.Properties("ServerComment").Value.ToString()
    End Sub
    Private Sub DatabaseOptionsInstaller()
        ConnectionDialog()
        If ConDic.Count > 0 Then
            Dim AppString As String = ""
            For Each con In ConDic
                Dim cString As New ConnectionStringSettings
                ExecuteSqlTransaction(con.Value.Split("~")(0))
                cString.Name = con.Key
                cString.ConnectionString = Encrypto.EncryptData(con.Value.Split("~")(0))
                cString.ProviderName = "System.Data.SqlClient"
                SetConnConfiguration(cString)
                AppString += IIf(AppString = "", "", "~") & con.Key & "|" & con.Value.Split("~")(1)
            Next
            SetConnConfiguration(AppString)
        Else
            Throw New Exception("No database specified. This installation will now terminate.")
        End If
    End Sub

    Public Sub ConnectionDialog()
        Dim dialog As New SQLServerConnectionDialog()
        Dim DiaRes As DialogResult = dialog.ShowDialog()
        If DiaRes = DialogResult.OK Then
            'Dim photourl As String = InputBox("Input photo url for this connection", "ERS Photo URL Prompt", "http://localhost/ERSViewer/Photos")
            ConDic.Add(dialog.ConnectionName, dialog.ConnectionString & "~" & dialog.Photourl)
        ElseIf DiaRes = DialogResult.Retry Then
            ' Dim photourl As String = InputBox("Input photo url for this connection", "ERS Photo URL Prompt", "http://localhost/ERSViewer/Photos")
            ConDic.Add(dialog.ConnectionName, dialog.ConnectionString & "~" & dialog.Photourl)
            ConnectionDialog()
        End If
    End Sub


    'Private Sub ExecuteSqlTransaction(ByVal connectionString As String)
    '    Using connection As New SqlConnection(connectionString)
    '        connection.Open()

    '        Dim command As SqlCommand = connection.CreateCommand()
    '        Dim transaction As SqlTransaction

    '        ' Start a local transaction
    '        transaction = connection.BeginTransaction(IsolationLevel.ReadCommitted)
    '        command.CommandType = CommandType.Text
    '        command.Connection = connection
    '        command.Transaction = transaction
    '        Dim f As String = ""
    '        Try
    '            Dim files As List(Of String) = My.Computer.FileSystem.GetFiles(sqlDirectory, FileIO.SearchOption.SearchAllSubDirectories, "*.sql").ToList
    '            If files.Count < 1 Then Throw New Exception("No SQL script available to run.")
    '            files.Sort()
    '            For Each fl In files
    '                f = fl
    '                Dim sqlstr As String = GetSql(fl)
    '                If Not IsNothing(sqlstr) AndAlso sqlstr <> "" Then
    '                    For Each st In SplitSqlStatements(sqlstr)
    '                        command.CommandText = st
    '                        command.ExecuteNonQuery()
    '                    Next
    '                End If
    '            Next
    '            ' Must assign both transaction object and connection to Command object for a pending local transaction
    '            transaction.Commit()
    '        Catch e As Exception
    '            Try
    '                transaction.Rollback()
    '            Catch ex As SqlException
    '                If Not transaction.Connection Is Nothing Then MsgBox("An exception of type " & ex.GetType().ToString() & " was encountered while attempting to roll back the transaction." & f)
    '            End Try
    '            MsgBox("An exception of type " & e.ToString() & "was encountered while executing your script." & f)
    '            'Log(f & ". ex: " + e.Message)
    '            Throw e
    '        End Try
    '    End Using
    'End Sub
    Private Sub ExecuteSqlTransaction(ByVal connectionString As String)
        Using connection As New SqlConnection(connectionString)
            connection.Open()

            Dim command As SqlCommand = connection.CreateCommand()
            Dim transaction As SqlTransaction

            ' Start a local transaction
            transaction = connection.BeginTransaction(IsolationLevel.ReadCommitted)
            command.CommandType = CommandType.Text
            command.Connection = connection
            command.Transaction = transaction
            Dim f As String = ""
            Try
                
                Dim sqlstr As String = GetSql("scripts.sql")
                    If Not IsNothing(sqlstr) AndAlso sqlstr <> "" Then
                        For Each st In SplitSqlStatements(sqlstr)
                            command.CommandText = st
                            command.ExecuteNonQuery()
                        Next
                    End If
                ' Must assign both transaction object and connection to Command object for a pending local transaction
                transaction.Commit()
            Catch e As Exception
                Try
                    transaction.Rollback()
                Catch ex As SqlException
                    If Not transaction.Connection Is Nothing Then MsgBox("An exception of type " & ex.GetType().ToString() & " was encountered while attempting to roll back the transaction." & f, MsgBoxStyle.Critical, "Database Setup")
                End Try
                MsgBox("An exception of type " & e.ToString() & " was encountered while executing your script." & f, MsgBoxStyle.Critical, "Database Setup")
                'Log(f & ". ex: " + e.Message)
                Throw e
            End Try
        End Using
    End Sub
    Private Function SplitSqlStatements(sqlScript As String) As IEnumerable(Of String)
        ' Split by "GO" statements
        Dim statements = Regex.Split(sqlScript, "^\s*GO\s* ($ | \-\- .*$)", RegexOptions.Multiline Or RegexOptions.IgnorePatternWhitespace Or RegexOptions.IgnoreCase)

        ' Remove empties, trim, and return
        Return statements.Where(Function(x) Not String.IsNullOrWhiteSpace(x)).[Select](Function(x) x.Trim(" "c, ControlChars.Cr, ControlChars.Lf))
    End Function
    Private Function GetSql(ByVal Name As String) As String
        Try
            ' Gets the current assembly.
            Dim Asm As [Assembly] = [Assembly].GetExecutingAssembly()

            ' Resources are named using a fully qualified name.
            Dim strm As Stream = Asm.GetManifestResourceStream(Asm.GetName().Name + "." + Name)
            'Dim reader As New StreamReader(Name)
            ' Reads the contents of the embedded file.
            Dim reader As StreamReader = New StreamReader(strm)
            Return reader.ReadToEnd()
        Catch ex As Exception
            MsgBox("Error In GetSQL(): " & ex.Message, MsgBoxStyle.Critical, "Database Setup")
            Throw ex
        End Try
    End Function



    Sub SetConnConfiguration(ConnectionString As ConnectionStringSettings)
        Dim config As Configuration = WebConfigurationManager.OpenWebConfiguration(Convert.ToString("/") & targetVDir, friendlySiteName)

        If config.ConnectionStrings.ConnectionStrings(ConnectionString.Name) IsNot Nothing Then
            config.ConnectionStrings.ConnectionStrings.Remove(config.ConnectionStrings().ConnectionStrings(ConnectionString.Name))
        End If

        config.ConnectionStrings.ConnectionStrings.Add(ConnectionString)
        config.Save()
        ConfigurationManager.RefreshSection("connectionStrings")
    End Sub
    Sub SetConnConfiguration(setting As String)
        Dim config As Configuration = WebConfigurationManager.OpenWebConfiguration(Convert.ToString("/") & targetVDir, friendlySiteName)


        If config.AppSettings.Settings("Unisoft.SetupKeys") IsNot Nothing Then
            config.AppSettings.Settings.Remove(config.AppSettings.Settings("Unisoft.SetupKeys").Key)
        End If

        config.AppSettings.Settings.Add("Unisoft.SetupKeys", setting)
        config.Save()
        ConfigurationManager.RefreshSection("appSettings")
    End Sub
End Class


