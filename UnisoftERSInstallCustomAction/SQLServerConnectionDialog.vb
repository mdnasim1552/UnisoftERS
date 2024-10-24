Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.Configuration
Imports System.Windows.Forms

Public Class SQLServerConnectionDialog

    Dim conn As New SqlConnectionStringBuilder()
    Public RootPath As String = ""
    Dim ConName As String = ""
    Dim _photourl As String = ""
    Private Sub frmSQLConnectionDialog_Load(sender As System.Object, e As System.EventArgs) Handles MyBase.Load

        cbServer.Text = conn.DataSource
        cbDataBase.Text = conn.InitialCatalog

        If conn.IntegratedSecurity = False Then
            txtUser.Enabled = True
            txtPassword.Enabled = True
            rbAuthenticationWin.Checked = False
            rbAuthenticationSql.Checked = True
            txtUser.Text = conn.UserID
            txtPassword.Text = conn.Password
        End If

    End Sub

    Private Sub btnRefresh_Click(sender As System.Object, e As System.EventArgs) Handles btnRefresh.Click
        SqlInstances()
    End Sub

    Sub ContructConnection()
        conn.DataSource = cbServer.Text
        conn.IntegratedSecurity = True
        conn.UserID = ""
        conn.Password = ""
        conn.InitialCatalog = ""

        If rbAuthenticationSql.Checked Then
            conn.IntegratedSecurity = False
            conn.UserID = txtUser.Text
            conn.Password = txtPassword.Text
        End If
        If cbDataBase.Text <> "" Then
            conn.InitialCatalog = cbDataBase.Text
        End If
        ConName = ConnectionNameTextBox.Text
        _photourl = photourlTextBox.Text
    End Sub

    Sub SqlInstances()
        Cursor.Current = Cursors.WaitCursor
        Try
            cbServer.Items.Clear()
            Dim sqlSources As DataTable = SqlDataSourceEnumerator.Instance.GetDataSources
            For Each datarow As DataRow In sqlSources.Rows
                Dim datasource As String = datarow("ServerName").ToString
                If Not datarow("InstanceName") Is DBNull.Value Then
                    datasource &= String.Format("\{0}", datarow("InstanceName"))
                End If
                cbServer.Items.Add(datasource)
            Next
        Catch ex As Exception
            MsgBox(ex.Message, MsgBoxStyle.Information, "Database Setup")
        End Try
        Cursor.Current = Cursors.Default
    End Sub

    Sub SqlDatabaseNames()

        ContructConnection()
        Cursor.Current = Cursors.WaitCursor
        Dim connString As String
        Dim databaseNames As New List(Of String)
        connString = conn.ConnectionString
        cbDataBase.Items.Clear()
        Try
            Using cn As SqlConnection = New SqlConnection(connString)
                cn.Open()
                Using cmd As SqlCommand = New SqlCommand()
                    cmd.Connection = cn
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.CommandText = "sp_databases"

                    Using myReader As SqlDataReader = cmd.ExecuteReader()
                        While (myReader.Read())
                            cbDataBase.Items.Add(myReader.GetString(0))
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            MsgBox(ex.Message, MsgBoxStyle.Information, "Database Setup")
        End Try
        Cursor.Current = Cursors.Default
    End Sub


    Sub TestDB()
        ContructConnection()
        Try
            Dim objConn As SqlConnection = New SqlConnection(conn.ConnectionString)
            objConn.Open()
            objConn.Close()
            MsgBox("Database connection successful.", MsgBoxStyle.Information, "Database Setup")
        Catch ex As Exception
            MsgBox(ex.Message, MsgBoxStyle.Information, "Database Setup")
        End Try

    End Sub
    Function TestConnection() As Boolean
        ContructConnection()
        Try
            Dim objConn As SqlConnection = New SqlConnection(conn.ConnectionString)
            objConn.Open()
            objConn.Close()
            Return True
        Catch ex As Exception
            Return False
        End Try
    End Function
    Private Sub cbServer_DropDown(sender As System.Object, e As System.EventArgs) Handles cbServer.DropDown
        If cbServer.Items.Count = 0 Then
            SqlInstances()
        End If
    End Sub

    Private Sub cbDataBase_DropDown(sender As System.Object, e As System.EventArgs) Handles cbDataBase.DropDown
        SqlDatabaseNames()
    End Sub

    Private Sub rbAuthenticationWin_CheckedChanged(sender As System.Object, e As System.EventArgs) Handles rbAuthenticationWin.CheckedChanged
        txtUser.Enabled = False
        txtPassword.Enabled = False
    End Sub

    Private Sub rbAuthenticationSql_CheckedChanged(sender As System.Object, e As System.EventArgs) Handles rbAuthenticationSql.CheckedChanged
        txtUser.Enabled = True
        txtPassword.Enabled = True
    End Sub


    Private Sub btnTest_Click(sender As System.Object, e As System.EventArgs) Handles btnTest.Click
        TestDB()
    End Sub

    Private Sub btnOK_Click(sender As System.Object, e As System.EventArgs) Handles btnOK.Click
        If ConnectionNameTextBox.Text = "" Or ConnectionNameTextBox.Text.Contains("~") Or ConnectionNameTextBox.Text.Contains("|") Then
            MsgBox("Please enter a valid Connection Name", MsgBoxStyle.Information, "Database Setup")
            ConnectionNameTextBox.Focus()
            ConnectionNameTextBox.BackColor = Drawing.Color.Yellow
            Exit Sub
        End If
        If photourlTextBox.Text = "" Then
            MsgBox("Enter a valid photo url", MsgBoxStyle.Information, "Photo URL Setup")
            photourlTextBox.Focus()
            photourlTextBox.BackColor = Drawing.Color.Yellow
            Exit Sub
        End If
        If TestConnection() = False Then
            MsgBox("Connection to database failed. Please check connection parameters and try again", MsgBoxStyle.Information, "Database Setup")
            cbServer.Focus()
            Exit Sub
        End If
        ContructConnection()
        Me.Close()
        If MsgBox("Do you want to add another database?", MsgBoxStyle.YesNo, "Additional Database") = MsgBoxResult.Yes Then
            Me.DialogResult = Windows.Forms.DialogResult.Retry
        Else
            Me.DialogResult = Windows.Forms.DialogResult.OK
        End If
    End Sub

    Private Sub btnCancel_Click(sender As System.Object, e As System.EventArgs) Handles btnCancel.Click
        If MsgBox("This installation is not yet complete. Are you sure you want to exit?", MsgBoxStyle.YesNo, "Exit Installation") = vbYes Then
            Me.Close()
            Me.DialogResult = Windows.Forms.DialogResult.Cancel
        End If
    End Sub

    Public Property ConnectionString() As String
        Get
            Return conn.ConnectionString
        End Get
        Set(ByVal value As String)
            conn.ConnectionString = value
        End Set
    End Property
    Public Property ConnectionName() As String
        Get
            Return ConName
        End Get
        Set(ByVal value As String)
            ConName = value
        End Set
    End Property
    Public Property Photourl() As String
        Get
            Return _photourl
        End Get
        Set(ByVal value As String)
            _photourl = value
        End Set
    End Property
    Private Sub SaveandAddButton_click(sender As Object, e As EventArgs) Handles SaveandAddButton.Click
        If ConnectionNameTextBox.Text = "" Or ConnectionNameTextBox.Text.Contains("~") Or ConnectionNameTextBox.Text.Contains("|") Then
            MsgBox("Please enter a valid Connection Name", MsgBoxStyle.Information, "Database Setup")
            ConnectionNameTextBox.Focus()
            ConnectionNameTextBox.BackColor = Drawing.Color.Yellow
            Exit Sub
        End If
        If photourlTextBox.Text = "" Then
            MsgBox("Enter a valid photo url", MsgBoxStyle.Information, "Photo URL Setup")
            photourlTextBox.Focus()
            photourlTextBox.BackColor = Drawing.Color.Yellow
            Exit Sub
        End If
        If TestConnection() = False Then
            MsgBox("Connection to database failed. Please check connection parameters and try again", MsgBoxStyle.Information, "Database Setup")
            cbServer.Focus()
            Exit Sub
        End If
        ContructConnection()
        Me.Close()
        Me.DialogResult = Windows.Forms.DialogResult.Retry
    End Sub
End Class