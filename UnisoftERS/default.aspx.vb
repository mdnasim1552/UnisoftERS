Public Class _default
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If System.Configuration.ConfigurationManager.AppSettings("SignOnMode") = "SSO" Then
            Response.Redirect("~/SSOAccount/signin", False)
        Else
            Response.Redirect("~/security/SElogin.aspx", False)
        End If
    End Sub

End Class