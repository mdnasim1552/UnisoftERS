Imports System.Web.Mvc
Imports Microsoft.Owin.Security
Imports System.Web
Imports Microsoft.Owin.Security.Cookies
Imports Microsoft.Owin.Security.OpenIdConnect
Imports Microsoft.AspNet.Identity.Owin
Imports Microsoft.AspNet.Identity
Imports System.Net.Http
Imports Microsoft.Owin.Security.WsFederation




'Namespace UnisoftERS.Controllers
Public Class SSOAccountController
    Inherits Controller

    ' GET: SSOAccount
    Function Index() As ActionResult
        Return View()
    End Function
    Public Sub SignIn()
        If Not Request.IsAuthenticated Then
            Dim SSOIDPMode As String = System.Configuration.ConfigurationManager.AppSettings("SSOIDPMode")
            If (SSOIDPMode = "O") Then
                HttpContext.GetOwinContext().Authentication.Challenge(New AuthenticationProperties With {
                   .RedirectUri = "Claim/mainSE"
                   }, OpenIdConnectAuthenticationDefaults.AuthenticationType)
            End If
            If (SSOIDPMode = "S") Then

                HttpContext.GetOwinContext().Authentication.Challenge(New AuthenticationProperties With {
                .RedirectUri = "Claim/mainSE"
                }, WsFederationAuthenticationDefaults.AuthenticationType)
            End If
        Else
            Response.Redirect("~/security/SElogin.aspx", False)
        End If
    End Sub

    Public Sub SignOut()
        Dim SSOIDPMode As String = System.Configuration.ConfigurationManager.AppSettings("SSOIDPMode")
        Dim callbackUrl As String = Url.Action("SignOutCallback", "SSOAccount", routeValues:=Nothing, protocol:=Request.Url.Scheme)

        Call clearSessionVariable()
        If (SSOIDPMode = "O") Then
            HttpContext.GetOwinContext().Authentication.SignOut(New AuthenticationProperties With {.RedirectUri = callbackUrl},
                                                                OpenIdConnectAuthenticationDefaults.AuthenticationType,
                                                                CookieAuthenticationDefaults.AuthenticationType)
            Session.Abandon()
        End If
        If (SSOIDPMode = "S") Then
            HttpContext.GetOwinContext().Authentication.SignOut(New AuthenticationProperties With {.RedirectUri = callbackUrl},
                WsFederationAuthenticationDefaults.AuthenticationType,
                CookieAuthenticationDefaults.AuthenticationType)
            Session.Abandon()
        End If
    End Sub
    Public Sub SignOutFromSE()
        Dim callbackUrl As String = Url.Action("SignOutCallback", "SSOAccount", routeValues:=Nothing, protocol:=Request.Url.Scheme)
        Call clearSessionVariable()
        HttpContext.GetOwinContext().Authentication.SignOut(New AuthenticationProperties With {.RedirectUri = callbackUrl}, OpenIdConnectAuthenticationDefaults.AuthenticationType, CookieAuthenticationDefaults.AuthenticationType)
    End Sub
    Public Function SignOutCallback() As ActionResult
        Return View()
        'If Request.IsAuthenticated Then
        '    Return RedirectToAction("Index", "Claim")
        'End If
        'Return View()
    End Function

    Private Sub clearSessionVariable()
        Session("Authenticated") = False
        Session("FullName") = ""
        Session("LoggedOn") = ""
        Session("IsSSO") = "False"
        Session("TrustId") = ""
        Session("UserID") = ""

        Session("DisplayName") = ""
        Session("GivenName") = ""
        Session("SurName") = ""
        Session("SSOIDPMode") = ""
        Session("AzureADGroups") = ""
    End Sub

End Class
'End Namespace