Public Class EditWards
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim WardId As Integer = 0
        If Not Page.IsPostBack Then
            WardId = GetWardId()
            If WardId > 0 Then
                fillEditForm(WardId)
                HospitalDropDownList.Enabled = False
            End If
        End If
    End Sub

    Protected Sub SaveWard()
        Dim WardId As Integer = GetWardId()
        Dim db As New DataAccess
        Dim returnError As String = db.SaveWard(HospitalDropDownList.SelectedValue, WardId, WardNameTextBox.Text)
        If String.IsNullOrEmpty(returnError) Then
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind('saved');", True)
        Else
            Utilities.SetErrorNotificationStyle(RadNotification1, returnError, "There is a problem saving data.")
            RadNotification1.Show()
        End If
    End Sub

    Private Function GetWardId() As Integer
        Dim WardId As Integer = 0
        If Not IsDBNull(Request.QueryString("WardId")) AndAlso Request.QueryString("WardId") <> "" Then
            WardId = CInt(Request.QueryString("WardId"))
        End If
        Return WardId
    End Function

    Private Sub fillEditForm(WardId As Integer)
        Dim db As New DataAccess
        Dim dt As DataRow = db.GetWard(WardId).Rows(0)
        WardNameTextBox.Text = CStr(dt("WardDescription"))
        HospitalDropDownList.SelectedValue = CStr(dt("HospitalId"))
    End Sub
End Class