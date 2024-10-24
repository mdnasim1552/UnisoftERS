Imports System.Security.Claims
Imports System.Web.Mvc


Namespace Controllers
    <Authorize>
    Public Class ClaimController
        Inherits Controller
        ' GET: Claim
        Public Function Index() As ActionResult
            Dim userClaims = TryCast(User.Identity, System.Security.Claims.ClaimsIdentity)
            SetSessionVariable(userClaims)
            ViewBag.Name = Session("FullName")
            ViewBag.Username = Session("UserID")
            ViewBag.Subject = userClaims?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
            ViewBag.TenantId = userClaims?.FindFirst("http://schemas.microsoft.com/identity/claims/tenantid")?.Value
            ViewBag.SSOIDPMode = Session("SSOIDPMode")
            Return View()
        End Function

        Public Function MainSE() As ActionResult
            Dim userClaims = TryCast(User.Identity, System.Security.Claims.ClaimsIdentity)
            SetSessionVariable(userClaims)
            ViewBag.Name = Session("FullName")
            ViewBag.Username = Session("UserID")
            ViewBag.Subject = userClaims?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
            ViewBag.TenantId = userClaims?.FindFirst("http://schemas.microsoft.com/identity/claims/tenantid")?.Value
            ViewBag.SSOIDPMode = Session("SSOIDPMode")
            Return Redirect("~/security/SElogin.aspx")
            'Return View()
        End Function


        Private Sub SetSessionVariable(userClaims As ClaimsIdentity)
            HttpContext.Session("Authenticated") = True
            HttpContext.Session("LoggedOn") = DateTime.Now.ToString("dd/MM/yyyy HH:mm")
            HttpContext.Session("isSSO") = "True"

            Dim SSOIDPMode As String = System.Configuration.ConfigurationManager.AppSettings("SSOIDPMode")
            Dim sGroupName As String
            Dim sFullName As String
            Dim sUserIdFieldName As String
            Dim sGivenNameFieldName As String
            Dim sSurNameFieldName As String
            If SSOIDPMode = "O" Then
                sGroupName = "groups"
                sFullName = "name"
                sUserIdFieldName = "preferred_username"
                sGivenNameFieldName = ""
                sSurNameFieldName = ""
            Else
                sGroupName = "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"
                sFullName = "http://schemas.microsoft.com/identity/claims/displayname"
                sUserIdFieldName = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
                'sUserIdFieldName = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
                sGivenNameFieldName = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
                sSurNameFieldName = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
            End If
            SetGroups(userClaims.Claims, sGroupName)
            Session("FullName") = userClaims.FindFirst(sFullName)?.Value
            Session("DisplayName") = userClaims.FindFirst(sFullName)?.Value
            Session("UserID") = userClaims.FindFirst(sUserIdFieldName)?.Value
            If SSOIDPMode = "S" Then
                If Session("UserID") = "" Then
                    sUserIdFieldName = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
                    Session("UserID") = userClaims.FindFirst(sUserIdFieldName)?.Value
                End If
            End If
            Session("GivenName") = userClaims.FindFirst(sGivenNameFieldName)?.Value
            Session("SurName") = userClaims.FindFirst(sSurNameFieldName)?.Value
            Session("SSOIDPMode") = SSOIDPMode

        End Sub





        Private Sub SetGroups(claims As IEnumerable(Of Claim), sGroupName As String)

            Dim groups = claims.Where(Function(c) c.Type = sGroupName).ToList()
            Dim strGroups As String = ""

            For Each group As Claim In groups
                If strGroups = "" Then
                    strGroups = group.Value
                Else
                    strGroups = strGroups & "," & group.Value
                End If
            Next
            Session("AzureADGroups") = strGroups


            ' LogManager.LogManagerInstance.LogMessage(strGroups)
        End Sub
    End Class
End Namespace