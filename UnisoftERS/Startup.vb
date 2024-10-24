Imports System.Threading.Tasks
Imports Microsoft.IdentityModel.Protocols.OpenIdConnect
Imports Microsoft.Owin
Imports Microsoft.Owin.Security
Imports Microsoft.Owin.Security.Cookies
Imports Microsoft.Owin.Security.Notifications
Imports Microsoft.Owin.Security.OpenIdConnect
Imports Owin
Imports Microsoft.Identity.Web
Imports Microsoft.Identity.Web.UI
<Assembly: OwinStartup(GetType(UnisoftERS.Startup))>
Public Class Startup
    Private SSOIDPMode As String = System.Configuration.ConfigurationManager.AppSettings("SSOIDPMode")
    Private clientId As String = System.Configuration.ConfigurationManager.AppSettings("ClientId")
    Private redirectUri As String = System.Configuration.ConfigurationManager.AppSettings("RedirectUri")
    Shared tenant As String = System.Configuration.ConfigurationManager.AppSettings("Tenant")
    Private authority As String = String.Format(System.Globalization.CultureInfo.InvariantCulture, System.Configuration.ConfigurationManager.AppSettings("Authority"), tenant)
    Private wtrealm As String = String.Format(System.Globalization.CultureInfo.InvariantCulture, System.Configuration.ConfigurationManager.AppSettings("Wtrealm"), clientId)
    Private metadataAddress As String = String.Format(System.Globalization.CultureInfo.InvariantCulture, System.Configuration.ConfigurationManager.AppSettings("MetadataAddress"), tenant)



    Public Sub Configuration(ByVal app As IAppBuilder)
        app.SetDefaultSignInAsAuthenticationType(CookieAuthenticationDefaults.AuthenticationType)
        app.UseCookieAuthentication(New CookieAuthenticationOptions())
        If (SSOIDPMode = "O") Then
            app.UseOpenIdConnectAuthentication(New OpenIdConnectAuthenticationOptions With {
            .ClientId = clientId,
            .Authority = authority,
            .RedirectUri = redirectUri,
            .PostLogoutRedirectUri = redirectUri,
            .Scope = OpenIdConnectScope.OpenIdProfile,
            .ResponseType = OpenIdConnectResponseType.CodeIdToken,
            .Notifications = New OpenIdConnectAuthenticationNotifications With {
                .AuthenticationFailed = AddressOf OnAuthenticationFailed
            }
        })
        End If
        If (SSOIDPMode = "S") Then
            app.UseWsFederationAuthentication(New WsFederation.WsFederationAuthenticationOptions With {
             .Wtrealm = wtrealm,
             .MetadataAddress = metadataAddress
            })
        End If

    End Sub

    Private Function OnAuthenticationFailed(ByVal context As AuthenticationFailedNotification(Of OpenIdConnectMessage, OpenIdConnectAuthenticationOptions)) As Task
        context.HandleResponse()
        context.Response.Redirect("/?errormessage=" & context.Exception.Message)
        Return Task.FromResult(0)
    End Function
End Class

