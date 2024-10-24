Imports System.Threading
Imports System.Windows.Forms
Imports System.IO

Public Class NetworkIniForm
    Dim _NetworkIniName As String
    Public Property NetworkIniName() As String
        Get
            Return _NetworkIniName
        End Get
        Set(ByVal value As String)
            _NetworkIniName = value
        End Set
    End Property
    Private Sub BrowseButton_Click(sender As Object, e As EventArgs) Handles BrowseButton.Click
        Dim newThread As New Thread(AddressOf showDiag)
        newThread.SetApartmentState(ApartmentState.STA)
        newThread.Start()
        'newThread.Join()
    End Sub
    Sub showDiag()
        Dim dlg As New OpenFileDialog()
        dlg.Title = "Select bnetwork.ini file."
        dlg.Filter = "network ini (*.ini)|*.ini"
        dlg.ShowDialog()
        AppendTextBox(FilenameTextBox, dlg.FileName)
    End Sub

    Private Sub OkButton_Click(sender As Object, e As EventArgs) Handles OkButton.Click
        Dim filename As String = FilenameTextBox.Text
        If filename <> "" AndAlso filename.ToLower.EndsWith("bnetwork.ini") AndAlso File.Exists(filename) Then
            _NetworkIniName = filename
            Me.Close()
            Me.DialogResult = Windows.Forms.DialogResult.OK
        Else
            MsgBox("Cannot locate bnetwork.ini file. Please enter a valid location.", MsgBoxStyle.Exclamation, "File Location")
            FilenameTextBox.Focus()
            Exit Sub
        End If
    End Sub

    Private Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        If MsgBox("This installation is not yet complete. Are you sure you want to exit?", MsgBoxStyle.YesNo, "Exit Installation") = vbYes Then
            Me.Close()
            Me.DialogResult = Windows.Forms.DialogResult.Cancel
        End If
    End Sub

    Private Delegate Sub AppendTextBoxDelegate(ByVal TB As TextBox, ByVal txt As String)

    Private Sub AppendTextBox(ByVal TB As TextBox, ByVal txt As String)
        If TB.InvokeRequired Then
            TB.Invoke(New AppendTextBoxDelegate(AddressOf AppendTextBox), New Object() {TB, txt})
        Else
            TB.Text = ""
            TB.AppendText(txt)
        End If
    End Sub

    Public Sub New(Dir As String)

        ' This call is required by the designer.
        InitializeComponent()
        AppendTextBox(FilenameTextBox, Path.GetDirectoryName(Dir) + "\bnetwork.ini")
        ' Add any initialization after the InitializeComponent() call.

    End Sub
End Class