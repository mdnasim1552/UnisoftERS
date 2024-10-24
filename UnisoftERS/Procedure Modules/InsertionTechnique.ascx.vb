Public Class InsertionTechnique1
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            loadInsertionTechniques()
        End If
    End Sub

    Private Sub loadInsertionTechniques()
        Try
            InsertionTechniqueRadComboBox.DataSource = DataAdapter.LoadInsertionTechniques()
            InsertionTechniqueRadComboBox.DataBind()

            Dim ProcedureInsertionTechnique = DataAdapter.getProcedureInsertionTechnique(Session(Constants.SESSION_PROCEDURE_ID))
            If ProcedureInsertionTechnique.Rows.Count > 0 Then
                Dim techniqueId = ProcedureInsertionTechnique.Rows(0)("InsertionTechniqueId")
                InsertionTechniqueRadComboBox.SelectedIndex = InsertionTechniqueRadComboBox.Items.FindItemIndexByValue(techniqueId)
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

End Class