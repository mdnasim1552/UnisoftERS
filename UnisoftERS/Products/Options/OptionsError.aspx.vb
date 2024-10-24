Imports Telerik.Web.UI
Imports Constants
Imports Utilities

Partial Class Products_Options_OptionsError
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim errorLogRef As String = ""

            If Request.QueryString("ErrorRef") IsNot Nothing Then
                errorLogRef = CStr(Request.QueryString("ErrorRef"))
            End If

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "An unexpected error occured performing this operation.")
            RadNotification1.Show()
        End If
    End Sub
End Class
