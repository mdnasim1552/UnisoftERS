Imports System
Imports System.ComponentModel
Imports System.Net
Imports System.Web
Imports System.Web.Mvc
Imports System.Web.Optimization
Imports System.Web.Routing
Imports System.Web.SessionState

Public Class Global_asax
    Inherits HttpApplication

    Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs on application startup
        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12
        RouteConfig.RegisterRoutes(RouteTable.Routes)
        FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters)
        BundleConfig.RegisterBundles(BundleTable.Bundles)
    End Sub

    Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs on application shutdown
    End Sub

    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)

        '### If we Dvelopers are running it from Localhost IIS then- show the full error details... no need to shy!! We like the Yellow Death Screen!! Yellow page!
        If Not HttpContext.Current.Request.IsLocal Then
            Dim cxt As System.Web.HttpContext = HttpContext.Current
            Dim ex As System.Exception = Context.Server.GetLastError()
            Dim errorCode As Integer = Response.StatusCode()


            If ex.GetBaseException() IsNot Nothing Then
                'ex = ex.GetBaseException()
                If TypeOf ex Is HttpUnhandledException Then
                    Server.Transfer("~/Error_handler/DefaultRedirectErrorPage.aspx?ReturnUrl=" + Request.Path)
                    LogManager.LogManagerInstance.LogError("HttpUnhandledException- has been caught in the Application_Error event. ", ex)
                ElseIf errorCode = 404 Or (ex.Message.Contains("does not exist")) Then
                    Response.Redirect("~/Error_handler/Oops404.aspx?ReturnUrl=" + Request.Path, False)
                    'LogManager.LogManagerInstance.LogError("404-PageNotFound- error occured and has been caught in the Application_Error event. ", ex)
                Else
                    '### For every other ERRORs!
                    LogManager.LogManagerInstance.LogError("Unexpected error occured and has been caught in the Application Error event. ", ex)
                End If
            End If
            'ex = ex.InnerException
            cxt.Server.ClearError()
        End If

    End Sub

    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs when a new session is started
        'Dim da As New Options
        'Session.Timeout = da.GetApplicationTimeOut(CInt(Session("OperatingHospitalID")))
    End Sub

    Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs when a session ends. 
        ' Note: The Session_End event is raised only when the sessionstate mode
        ' is set to InProc in the Web.config file. If session mode is set to StateServer 
        ' or SQLServer, the event is not raised.
        Dim da As New Options
        If Session(".PKUserId") IsNot Nothing Then
            da.RemoveLoggedInUser(CInt(Session("PKUserId")))
        End If
        'Response.Redirect("~/Security/Logout.aspx", False)
    End Sub
End Class