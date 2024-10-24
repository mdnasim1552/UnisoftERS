<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class SQLServerConnectionDialog
    Inherits System.Windows.Forms.Form

    'Form reemplaza a Dispose para limpiar la lista de componentes.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Requerido por el Diseñador de Windows Forms
    Private components As System.ComponentModel.IContainer

    'NOTA: el Diseñador de Windows Forms necesita el siguiente procedimiento
    'Se puede modificar usando el Diseñador de Windows Forms.  
    'No lo modifique con el editor de código.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.lbServidor = New System.Windows.Forms.Label()
        Me.cbServer = New System.Windows.Forms.ComboBox()
        Me.btnRefresh = New System.Windows.Forms.Button()
        Me.rbAuthenticationWin = New System.Windows.Forms.RadioButton()
        Me.rbAuthenticationSql = New System.Windows.Forms.RadioButton()
        Me.txtUser = New System.Windows.Forms.TextBox()
        Me.txtPassword = New System.Windows.Forms.TextBox()
        Me.lbUsuario = New System.Windows.Forms.Label()
        Me.lbClave = New System.Windows.Forms.Label()
        Me.btnOK = New System.Windows.Forms.Button()
        Me.btnCancel = New System.Windows.Forms.Button()
        Me.btnTest = New System.Windows.Forms.Button()
        Me.cbDataBase = New System.Windows.Forms.ComboBox()
        Me.GroupBox1 = New System.Windows.Forms.GroupBox()
        Me.lbBase = New System.Windows.Forms.Label()
        Me.GroupBox2 = New System.Windows.Forms.GroupBox()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.ConnectionNameTextBox = New System.Windows.Forms.TextBox()
        Me.SaveandAddButton = New System.Windows.Forms.Button()
        Me.DBGroupBox = New System.Windows.Forms.GroupBox()
        Me.PhotoGroupBox = New System.Windows.Forms.GroupBox()
        Me.photourlTextBox = New System.Windows.Forms.TextBox()
        Me.GroupBox1.SuspendLayout()
        Me.GroupBox2.SuspendLayout()
        Me.DBGroupBox.SuspendLayout()
        Me.PhotoGroupBox.SuspendLayout()
        Me.SuspendLayout()
        '
        'lbServidor
        '
        Me.lbServidor.AutoSize = True
        Me.lbServidor.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbServidor.Location = New System.Drawing.Point(7, 43)
        Me.lbServidor.Name = "lbServidor"
        Me.lbServidor.Size = New System.Drawing.Size(72, 13)
        Me.lbServidor.TabIndex = 0
        Me.lbServidor.Text = "Server Name:"
        '
        'cbServer
        '
        Me.cbServer.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.cbServer.FormattingEnabled = True
        Me.cbServer.Location = New System.Drawing.Point(10, 62)
        Me.cbServer.Name = "cbServer"
        Me.cbServer.Size = New System.Drawing.Size(249, 21)
        Me.cbServer.TabIndex = 2
        '
        'btnRefresh
        '
        Me.btnRefresh.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.btnRefresh.Location = New System.Drawing.Point(265, 60)
        Me.btnRefresh.Name = "btnRefresh"
        Me.btnRefresh.Size = New System.Drawing.Size(76, 24)
        Me.btnRefresh.TabIndex = 3
        Me.btnRefresh.Text = "Refresh"
        '
        'rbAuthenticationWin
        '
        Me.rbAuthenticationWin.AutoSize = True
        Me.rbAuthenticationWin.Checked = True
        Me.rbAuthenticationWin.Location = New System.Drawing.Point(13, 20)
        Me.rbAuthenticationWin.Name = "rbAuthenticationWin"
        Me.rbAuthenticationWin.Size = New System.Drawing.Size(162, 17)
        Me.rbAuthenticationWin.TabIndex = 4
        Me.rbAuthenticationWin.TabStop = True
        Me.rbAuthenticationWin.Text = "Use Windows Authentication"
        Me.rbAuthenticationWin.UseVisualStyleBackColor = True
        '
        'rbAuthenticationSql
        '
        Me.rbAuthenticationSql.AutoSize = True
        Me.rbAuthenticationSql.Location = New System.Drawing.Point(13, 42)
        Me.rbAuthenticationSql.Name = "rbAuthenticationSql"
        Me.rbAuthenticationSql.Size = New System.Drawing.Size(173, 17)
        Me.rbAuthenticationSql.TabIndex = 5
        Me.rbAuthenticationSql.Text = "Use SQL Server Authentication"
        '
        'txtUser
        '
        Me.txtUser.Enabled = False
        Me.txtUser.Location = New System.Drawing.Point(81, 72)
        Me.txtUser.Name = "txtUser"
        Me.txtUser.Size = New System.Drawing.Size(250, 20)
        Me.txtUser.TabIndex = 6
        '
        'txtPassword
        '
        Me.txtPassword.Enabled = False
        Me.txtPassword.Location = New System.Drawing.Point(81, 98)
        Me.txtPassword.Name = "txtPassword"
        Me.txtPassword.PasswordChar = Global.Microsoft.VisualBasic.ChrW(42)
        Me.txtPassword.Size = New System.Drawing.Size(250, 20)
        Me.txtPassword.TabIndex = 7
        '
        'lbUsuario
        '
        Me.lbUsuario.AutoSize = True
        Me.lbUsuario.Location = New System.Drawing.Point(17, 75)
        Me.lbUsuario.Name = "lbUsuario"
        Me.lbUsuario.Size = New System.Drawing.Size(61, 13)
        Me.lbUsuario.TabIndex = 9
        Me.lbUsuario.Text = "User name:"
        '
        'lbClave
        '
        Me.lbClave.AutoSize = True
        Me.lbClave.Location = New System.Drawing.Point(17, 101)
        Me.lbClave.Name = "lbClave"
        Me.lbClave.Size = New System.Drawing.Size(56, 13)
        Me.lbClave.TabIndex = 10
        Me.lbClave.Text = "Password:"
        '
        'btnOK
        '
        Me.btnOK.Location = New System.Drawing.Point(277, 439)
        Me.btnOK.Name = "btnOK"
        Me.btnOK.Size = New System.Drawing.Size(82, 24)
        Me.btnOK.TabIndex = 11
        Me.btnOK.Tag = ""
        Me.btnOK.Text = "OK"
        '
        'btnCancel
        '
        Me.btnCancel.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.btnCancel.DialogResult = System.Windows.Forms.DialogResult.OK
        Me.btnCancel.Location = New System.Drawing.Point(189, 439)
        Me.btnCancel.Name = "btnCancel"
        Me.btnCancel.Size = New System.Drawing.Size(82, 24)
        Me.btnCancel.TabIndex = 24
        Me.btnCancel.Text = "Cancel"
        '
        'btnTest
        '
        Me.btnTest.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.btnTest.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft
        Me.btnTest.Location = New System.Drawing.Point(201, 313)
        Me.btnTest.Name = "btnTest"
        Me.btnTest.Size = New System.Drawing.Size(140, 24)
        Me.btnTest.TabIndex = 9
        Me.btnTest.Text = "Test Connection"
        '
        'cbDataBase
        '
        Me.cbDataBase.FormattingEnabled = True
        Me.cbDataBase.Location = New System.Drawing.Point(9, 46)
        Me.cbDataBase.Name = "cbDataBase"
        Me.cbDataBase.Size = New System.Drawing.Size(322, 21)
        Me.cbDataBase.TabIndex = 8
        '
        'GroupBox1
        '
        Me.GroupBox1.Controls.Add(Me.lbBase)
        Me.GroupBox1.Controls.Add(Me.cbDataBase)
        Me.GroupBox1.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.GroupBox1.Location = New System.Drawing.Point(10, 225)
        Me.GroupBox1.Name = "GroupBox1"
        Me.GroupBox1.Size = New System.Drawing.Size(337, 82)
        Me.GroupBox1.TabIndex = 33
        Me.GroupBox1.TabStop = False
        Me.GroupBox1.Text = "Connect to database"
        '
        'lbBase
        '
        Me.lbBase.AutoSize = True
        Me.lbBase.Location = New System.Drawing.Point(6, 27)
        Me.lbBase.Name = "lbBase"
        Me.lbBase.Size = New System.Drawing.Size(164, 13)
        Me.lbBase.TabIndex = 36
        Me.lbBase.Text = "Select or enter a database name:"
        '
        'GroupBox2
        '
        Me.GroupBox2.Controls.Add(Me.txtPassword)
        Me.GroupBox2.Controls.Add(Me.txtUser)
        Me.GroupBox2.Controls.Add(Me.rbAuthenticationWin)
        Me.GroupBox2.Controls.Add(Me.lbUsuario)
        Me.GroupBox2.Controls.Add(Me.lbClave)
        Me.GroupBox2.Controls.Add(Me.rbAuthenticationSql)
        Me.GroupBox2.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.GroupBox2.Location = New System.Drawing.Point(10, 90)
        Me.GroupBox2.Name = "GroupBox2"
        Me.GroupBox2.Size = New System.Drawing.Size(337, 129)
        Me.GroupBox2.TabIndex = 34
        Me.GroupBox2.TabStop = False
        Me.GroupBox2.Text = "Log on to the server"
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label1.Location = New System.Drawing.Point(7, 22)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(95, 13)
        Me.Label1.TabIndex = 35
        Me.Label1.Text = "Connection Name:"
        '
        'ConnectionNameTextBox
        '
        Me.ConnectionNameTextBox.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.ConnectionNameTextBox.Location = New System.Drawing.Point(105, 19)
        Me.ConnectionNameTextBox.Name = "ConnectionNameTextBox"
        Me.ConnectionNameTextBox.Size = New System.Drawing.Size(236, 20)
        Me.ConnectionNameTextBox.TabIndex = 1
        '
        'SaveandAddButton
        '
        Me.SaveandAddButton.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.SaveandAddButton.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft
        Me.SaveandAddButton.Location = New System.Drawing.Point(14, 313)
        Me.SaveandAddButton.Name = "SaveandAddButton"
        Me.SaveandAddButton.Size = New System.Drawing.Size(171, 24)
        Me.SaveandAddButton.TabIndex = 38
        Me.SaveandAddButton.Text = "Save and add another database"
        Me.SaveandAddButton.Visible = False
        '
        'DBGroupBox
        '
        Me.DBGroupBox.Controls.Add(Me.Label1)
        Me.DBGroupBox.Controls.Add(Me.SaveandAddButton)
        Me.DBGroupBox.Controls.Add(Me.GroupBox2)
        Me.DBGroupBox.Controls.Add(Me.ConnectionNameTextBox)
        Me.DBGroupBox.Controls.Add(Me.lbServidor)
        Me.DBGroupBox.Controls.Add(Me.cbServer)
        Me.DBGroupBox.Controls.Add(Me.GroupBox1)
        Me.DBGroupBox.Controls.Add(Me.btnRefresh)
        Me.DBGroupBox.Controls.Add(Me.btnTest)
        Me.DBGroupBox.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.DBGroupBox.Location = New System.Drawing.Point(12, 12)
        Me.DBGroupBox.Name = "DBGroupBox"
        Me.DBGroupBox.Size = New System.Drawing.Size(356, 349)
        Me.DBGroupBox.TabIndex = 39
        Me.DBGroupBox.TabStop = False
        Me.DBGroupBox.Text = "Database Setup"
        '
        'PhotoGroupBox
        '
        Me.PhotoGroupBox.BackColor = System.Drawing.SystemColors.Control
        Me.PhotoGroupBox.Controls.Add(Me.photourlTextBox)
        Me.PhotoGroupBox.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.PhotoGroupBox.Location = New System.Drawing.Point(12, 378)
        Me.PhotoGroupBox.Name = "PhotoGroupBox"
        Me.PhotoGroupBox.Size = New System.Drawing.Size(356, 55)
        Me.PhotoGroupBox.TabIndex = 40
        Me.PhotoGroupBox.TabStop = False
        Me.PhotoGroupBox.Text = "Enter Photo URL"
        '
        'photourlTextBox
        '
        Me.photourlTextBox.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.photourlTextBox.Location = New System.Drawing.Point(10, 21)
        Me.photourlTextBox.Name = "photourlTextBox"
        Me.photourlTextBox.Size = New System.Drawing.Size(337, 20)
        Me.photourlTextBox.TabIndex = 10
        Me.photourlTextBox.Text = "http://localhost/ERSViewer/Photos"
        '
        'SQLServerConnectionDialog
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(382, 478)
        Me.ControlBox = False
        Me.Controls.Add(Me.PhotoGroupBox)
        Me.Controls.Add(Me.DBGroupBox)
        Me.Controls.Add(Me.btnOK)
        Me.Controls.Add(Me.btnCancel)
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "SQLServerConnectionDialog"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "Setup Options"
        Me.TopMost = True
        Me.GroupBox1.ResumeLayout(False)
        Me.GroupBox1.PerformLayout()
        Me.GroupBox2.ResumeLayout(False)
        Me.GroupBox2.PerformLayout()
        Me.DBGroupBox.ResumeLayout(False)
        Me.DBGroupBox.PerformLayout()
        Me.PhotoGroupBox.ResumeLayout(False)
        Me.PhotoGroupBox.PerformLayout()
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents lbServidor As System.Windows.Forms.Label
    Friend WithEvents cbServer As System.Windows.Forms.ComboBox
    Friend WithEvents btnRefresh As System.Windows.Forms.Button
    Friend WithEvents rbAuthenticationWin As System.Windows.Forms.RadioButton
    Friend WithEvents rbAuthenticationSql As System.Windows.Forms.RadioButton
    Friend WithEvents txtUser As System.Windows.Forms.TextBox
    Friend WithEvents txtPassword As System.Windows.Forms.TextBox
    Friend WithEvents lbUsuario As System.Windows.Forms.Label
    Friend WithEvents lbClave As System.Windows.Forms.Label
    Friend WithEvents btnOK As System.Windows.Forms.Button
    Friend WithEvents btnCancel As System.Windows.Forms.Button
    Friend WithEvents btnTest As System.Windows.Forms.Button
    Friend WithEvents cbDataBase As System.Windows.Forms.ComboBox
    Friend WithEvents GroupBox1 As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox2 As System.Windows.Forms.GroupBox
    Friend WithEvents lbBase As System.Windows.Forms.Label
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents ConnectionNameTextBox As System.Windows.Forms.TextBox
    Friend WithEvents SaveandAddButton As System.Windows.Forms.Button
    Friend WithEvents DBGroupBox As System.Windows.Forms.GroupBox
    Friend WithEvents PhotoGroupBox As System.Windows.Forms.GroupBox
    Friend WithEvents photourlTextBox As System.Windows.Forms.TextBox
End Class
