Public Class Site
    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If String.IsNullOrWhiteSpace(Session("UserID")) Then
            Session.Contents.RemoveAll()
            Response.Redirect("~/Security/Logout.aspx", False)
        End If
    End Sub

End Class