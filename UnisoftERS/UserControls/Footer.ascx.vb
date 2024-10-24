
Partial Class UserControls_Footer
    Inherits System.Web.UI.UserControl

    Protected Sub UserControls_Footer_Load(sender As Object, e As EventArgs) Handles Me.Load
        'lblUserID.Text = "UserID: <b>" & Session("UserID") & " (" & Session("FullName") & ")" & "</b>"
        'lblPageID.Text = "PageID: <b>" & Session("PageID") & "</b>&nbsp;"
        'lblCompany.Text = "&#169; 1994-" & Format(Now(), "yyyy") & "<b> <font color='#103d8c'>Uni</font><font color='#c10a22'>soft</font> Medical Systems</b>"
        Dim versionObj As New Version(Session(Constants.SESSION_APPVERSION)) ' 4426
        lblCompany.Text = "&#169; 2018-" & Format(Now(), "yyyy") & "<b> HD Clinical Ltd</b> | Version " & versionObj.Major & "." & versionObj.Minor & "." & versionObj.Build
        'LoggedOnAtLabel.Text = "Logged on at: <b>" & Session("LoggedOn") & "</b> from <b>" & Utilities.GetHostName & "</b>."
    End Sub
End Class
