Imports Telerik.Web.UI

Public Class OGDMucosalOutcomes
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            loadMucosalVisualisation()
        End If
    End Sub

    Private Sub loadMucosalVisualisation()
        Try
            MucosalVisualisationRadComboBox.DataSource = DataAdapter.LoadMucosalVisualisation()
            MucosalVisualisationRadComboBox.DataBind()

            Dim dtVisualisation = DataAdapter.getProcedureMucosalVisualisation(Session(Constants.SESSION_PROCEDURE_ID))
            If dtVisualisation.Rows.Count > 0 Then
                Dim techniqueId = dtVisualisation.Rows(0)("MucosalVisualisationId")
                MucosalVisualisationRadComboBox.SelectedIndex = MucosalVisualisationRadComboBox.Items.FindItemIndexByValue(techniqueId)
            Else
                MucosalVisualisationRadComboBox.Items.Insert(0, New RadComboBoxItem(""))
            End If

            MucosalCleaningRadComboBox.DataSource = DataAdapter.LoadMucosalCleaning()
            MucosalCleaningRadComboBox.DataBind()

            Dim dtCleaning = DataAdapter.getProcedureMucosalCleaning(Session(Constants.SESSION_PROCEDURE_ID))
            If dtCleaning.Rows.Count > 0 Then
                For Each dr As DataRow In dtCleaning.Rows
                    Dim cleaningId = dr("MucosalCleaningId")
                    Dim cleaningText As String = ""
                    If MucosalCleaningRadComboBox.Items.Any(Function(x) x.Value = cleaningId) Then
                        MucosalCleaningRadComboBox.Items.Where(Function(x) x.Value = cleaningId).FirstOrDefault.Checked = True
                        cleaningText = MucosalCleaningRadComboBox.Items.Where(Function(x) x.Value = cleaningId).FirstOrDefault.Text
                        If cleaningText.ToLower = "other" Then
                            ScriptManager.RegisterStartupScript(Page, GetType(Page), "m1", "$('.other-cleaning-text-entry').show();", True)
                        End If
                    End If

                    If Not String.IsNullOrWhiteSpace(dr("AdditionalInfo")) Then
                        OtherTextBox.Text = dr("AdditionalInfo")
                    End If
                Next
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
End Class