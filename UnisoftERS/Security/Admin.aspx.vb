
Partial Class Security_Admin
    Inherits System.Web.UI.Page

    Protected Sub Security_Admin_Load(sender As Object, e As EventArgs) Handles Me.Load
        'Call initForm()
    End Sub

    'Protected Sub Security_Admin_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
    '    Dim sPassword As String = Trim(Request.QueryString("sd"))
    '    If sPassword <> "un1s0ft12" Then
    '        Response.Redirect("login.aspx")
    '    End If
    'End Sub

    'Private Sub initForm()
    '    Call uniAdaptor.checkSystemConfig()
    '    lblStatus.Text = IIf(Session("SystemDisabled") = True, "Offline", "Online")
    '    cmdSetStatus.Text = "Set " & IIf(Session("SystemDisabled") = True, "Online", "Offline")
    'End Sub

    'Protected Sub cmdSetStatus_Click(sender As Object, e As EventArgs) Handles cmdSetStatus.Click
    '    Dim sSQL As String = ""
    '    If Session("SystemDisabled") = True Then
    '        Session("SystemDisabled") = False
    '    Else
    '        Session("SystemDisabled") = True
    '    End If

    '    sSQL = "UPDATE [SystemConfig] SET [SystemDisabled] = " & IIf(Session("SystemDisabled") = True, 1, 0)
    '    Call uniAdaptor.updateRecords(sSQL)
    '    Response.Redirect("/Security/Admin.aspx?sd=un1s0ft12")
    'End Sub


End Class
