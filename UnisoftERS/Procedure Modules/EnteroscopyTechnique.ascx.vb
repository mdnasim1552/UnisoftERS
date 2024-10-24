Public Class EnteroscopyTechnique
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            loadEnteroscopyTechniques()
        End If
    End Sub

    Private Sub loadEnteroscopyTechniques()
        Try
            EnteroscopyTechniqueRadComboBox.DataSource = DataAdapter.LoadEnteroscopyTechniques()
            EnteroscopyTechniqueRadComboBox.DataBind()

            Dim dt = DataAdapter.getProcedureEnteroscopyTechnique(Session(Constants.SESSION_PROCEDURE_ID))
            If dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)
                EnteroscopyTechniqueRadComboBox.SelectedIndex = EnteroscopyTechniqueRadComboBox.Items.FindItemIndexByValue(dr("TechniqueId"))
                If Not String.IsNullOrWhiteSpace(dr("AdditionalInfo")) Then
                    OtherTextBox.Text = dr("AdditionalInfo")
                End If
            End If

            Dim dtInsertion = DataAdapter.getProcedureInsertionDepth(Session(Constants.SESSION_PROCEDURE_ID))
            If dtInsertion.Rows.Count > 0 Then
                Dim dr = dtInsertion.Rows(0)
                InsertionDepthRadNumericTextBox.Value = CInt(dr("InsertionLength"))
                TattooedCheckBox.Checked = CBool(dr("Tattooed"))
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
End Class