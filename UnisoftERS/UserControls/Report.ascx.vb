
Partial Class UserControls_Report
    Inherits System.Web.UI.UserControl

    Protected Sub UserControls_Report_Load(sender As Object, e As EventArgs) Handles Me.Load
    End Sub

    Private Sub SummaryObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryObjectDataSource.Selecting
        e.InputParameters("procId") = CStr(Session(Constants.SESSION_PROCEDURE_ID))
    End Sub
End Class

