Imports Microsoft.VisualBasic

Public Class OptionsBase
    Inherits PageBase

    Private _optionsDataAdapter As Options = Nothing

    Protected ReadOnly Property OptionsDataAdapter() As Options
        Get
            If _optionsDataAdapter Is Nothing Then
                _optionsDataAdapter = New Options
            End If
            Return _optionsDataAdapter
        End Get
    End Property

    Protected Sub Page_PreInit() Handles Me.PreInit
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "PreInit_CloseLoadingPanel", "if (window.parent.HideLoadingPanel) { window.parent.HideLoadingPanel();}", True)
    End Sub

    'Protected Sub Page_Load() Handles Me.Load
    '    ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "CloseLoadingPanel", " window.parent.HideLoadingPanel();", True)
    'End Sub

    Private Sub Page_Error(sender As Object, e As EventArgs) Handles Me.Error
        Dim errorLogRef As String
        Dim exc As Exception = Server.GetLastError

        If exc.GetBaseException() IsNot Nothing Then
            'exc = exc.InnerException
            exc = exc.GetBaseException()
        End If

        errorLogRef = LogManager.LogManagerInstance.LogError("Unhandled error occured in one of the Options pages, and caught in the Page.Error event in the base page, OptionsBase.vb.", _
                                                             exc)
        'Utilities.SetErrorNotificationStyle(DirectCast(Me.FindControl("RadNotification1"), RadNotification), exc, errorLogRef, "There is a problem saving data.")

        Server.ClearError()

        Response.Redirect("OptionsError.aspx?ErrorRef=" & errorLogRef, False)

        'ClientScript.RegisterStartupScript(Me.GetType(), "Error_CloseLoadingPanel", " alert(1);window.parent.HideLoadingPanel();", True)
        'Page.RegisterStartupScript("Error_CloseLoadingPanel", " alert(1);window.parent.HideLoadingPanel();")

        'Utilities.SetErrorNotificationStyle(DirectCast(Me.FindControl("RadNotification1"), RadNotification), 
    End Sub

    Protected Overrides Sub RedirectToLoginPage()
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "sessionexpired", "window.parent.location='" + ResolveUrl("~/Security/Logout.aspx") + "'; ", True)
    End Sub
End Class
