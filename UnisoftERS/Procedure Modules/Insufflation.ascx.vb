Imports Telerik.Web.UI

Public Class Insufflation
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            loadInsufflation()
        End If
    End Sub

    Private Sub loadInsufflation()
        Try
            InsufflationRadComboBox.DataSource = DataAdapter.LoadInsufflation()
            InsufflationRadComboBox.DataBind()
            'Added by rony tfs-4358
            Dim procType As Integer = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            Dim da As New DataAccess
            Dim dt = DataAdapter.getProcedureInsufflation(Session(Constants.SESSION_PROCEDURE_ID))
            If dt.Rows.Count > 0 Then
                Dim insufflationId = dt.Rows(0)("InsufflationId")
                InsufflationRadComboBox.SelectedValue = insufflationId
            Else
                InsufflationRadComboBox.SelectedIndex = InsufflationRadComboBox.FindItemIndexByText("Carbon dioxide")
                da.saveProcedureInsufflation(CInt(Session(Constants.SESSION_PROCEDURE_ID)), InsufflationRadComboBox.SelectedValue)
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
End Class