Public Class NEDReports
    Inherits System.Web.UI.Page
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        If IsNothing(Session("PKUserID")) Then
            Response.Redirect("/")
        End If
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
    End Sub

    Protected Sub Go_Click(sender As Object, e As EventArgs) Handles Go.Click
        PASDownload.FromDate = RDPFrom.SelectedDate.ToString
        PASDownload.ToDate = RDPTo.SelectedDate.ToString
        PASDownload.IsProcessed = Me.IsProcessed.SelectedValue.ToString
        PASDownload.IsRejected = IsRejected.SelectedValue.ToString
        PASDownload.IsSchemaValid = Me.IsSchemaValid.SelectedValue.ToString
        PASDownload.IsSent = Me.IsSent.SelectedValue.ToString
        PASDownload.ProcedureTypeId = Me.ProcedureTypeId.SelectedValue.ToString
        PASDownload.PatientName = PatientName.Value
        PASDownload.CNN = CNN.Value
        PASDownload.NHS = NHS.Value
        RadGridNED.DataBind()
    End Sub
End Class