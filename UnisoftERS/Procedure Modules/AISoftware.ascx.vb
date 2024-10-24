Public Class AISoftware
    Inherits ProcedureControls


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            'Added by rony tfs-4358
            Dim procType As Integer = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If procType <> CInt(ProcedureType.Proctoscopy) Then
                loadAISoftware()
            Else
                AISoftwareContent.Visible = False
            End If
            'markSectionSelected("AI software", Session(Constants.SESSION_PROCEDURE_ID))
        End If
    End Sub

    Private Sub loadAISoftware()
        Try
            AISoftwareRadComboBox.DataSource = DataAdapter.LoadAISoftware()
            AISoftwareRadComboBox.DataBind()

            Dim procedureAISoftware = DataAdapter.GetProcedureAISoftware(Session(Constants.SESSION_PROCEDURE_ID))
            If procedureAISoftware.Rows.Count > 0 Then
                Dim softwareId = procedureAISoftware.Rows(0)("AISoftwareId")
                AISoftwareRadComboBox.SelectedIndex = AISoftwareRadComboBox.Items.FindItemIndexByValue(softwareId)
                AISoftwareNameTextBox.Text = procedureAISoftware.Rows(0)("AISoftwareName")
                AISoftwareOtherTextBox.Text = procedureAISoftware.Rows(0)("AISoftwareOther")
                AISoftwareNameTextBox.Text = procedureAISoftware.Rows(0)("AISoftwareName")
                AIOtherSoftwareNameTextBox.Text = procedureAISoftware.Rows(0)("AIOtherSoftwareName")

                If Not String.IsNullOrWhiteSpace(AISoftwareRadComboBox.SelectedItem.Text) Then
                    ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "start_up_script", "toggleAISoftwareRows('" & AISoftwareRadComboBox.SelectedItem.Text.ToLower & "');", True)
                End If
            Else
                markSectionSelected("AI software", Session(Constants.SESSION_PROCEDURE_ID))
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
End Class