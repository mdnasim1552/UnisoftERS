Public Class AdditionalReportNotes
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            loadAdditionalReportNotes()
        End If
    End Sub

    Private Sub loadAdditionalReportNotes()
        Try
            Dim da As New OtherData
            Dim dt = da.getProcedureAddiotionalNotes(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)
                AdditionalNotesTextBox.Text = dr("AdditionalNotes")
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading procedure additional report notes.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class