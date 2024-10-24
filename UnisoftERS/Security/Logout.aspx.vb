
Imports System.DirectoryServices.ActiveDirectory

Partial Class Security_Logout
    Inherits PageBase

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load


        'DataAdapter.UnlockPatientProcedures(Session("PCName"), Session("UserID"))
        Using lm As New AuditLogManager
            lm.WriteActivityLog(EVENT_TYPE.LogOut, "User Logged out. UserId: " & Session("UserID").ToString())
        End Using

        Dim da As New Options
        If Session("PKUserId") IsNot Nothing Then
            da.RemoveLoggedInUser(CInt(Session("PKUserId")), CStr(Session("UserID")))
            DataAccess_Sch.ReleaseRedundantLockedSlots()
            DataAccess_Sch.ReleaseRedundantLockedSlots(CInt(Session("PKUserId")))
        Else
            da.RemoveLoggedInUser(Utilities.GetHostName())
        End If

        Dim isSSO = Session("IsSSO")
        Session.Contents.RemoveAll()
        ' Remove all active cookies
        ExpireAllCookies()

        If isSSO = "True" Then
            Response.Redirect("~/SSOAccount/SignOut", False)
        Else
            Response.Redirect("SELogin.aspx", False)
        End If
    End Sub

    Public Sub ExpireAllCookies()

        If HttpContext.Current IsNot Nothing Then
            Dim cookieCount As Int16 = HttpContext.Current.Request.Cookies.Count

            For i As Integer = 0 To cookieCount
                ' Get single cookie from list
                Dim Cookie = HttpContext.Current.Request.Cookies(i)

                If Cookie IsNot Nothing Then
                    Dim expiredCookie = New HttpCookie(Cookie.Name)
                    expiredCookie.Expires = DateTime.Now.AddDays(-1)
                    expiredCookie.Domain = Cookie.Domain

                    HttpContext.Current.Response.Cookies.Add(expiredCookie)
                End If
            Next

            '' clear cookies from server side
            HttpContext.Current.Request.Cookies.Clear()
        End If
    End Sub

End Class
