Public Class Comfort
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        RadPivotGrid1.Rebind()
    End Sub

End Class