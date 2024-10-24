Public Class Chromendoscopies
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            'Added by rony tfs-4358
            Dim procType As Integer = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If procType <> CInt(ProcedureType.Proctoscopy) Then
                loadChromendoscopies()
            Else
                ChromendoscopyUsedContent.Visible = False
            End If
            'markSectionSelected("Chromendoscopies", Session(Constants.SESSION_PROCEDURE_ID))
        End If
    End Sub

    Private Sub loadChromendoscopies()
        Try
            ChromendoscopyRadComboBox.DataSource = DataAdapter.LoadChromendoscopies()
            ChromendoscopyRadComboBox.DataBind()

            Dim dt = DataAdapter.getProcedureChromendoscopy(Session(Constants.SESSION_PROCEDURE_ID))
            If dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)
                ChromendoscopyRadComboBox.SelectedIndex = ChromendoscopyRadComboBox.Items.FindItemIndexByValue(dr("ChromendoscopyId"))
                If Not String.IsNullOrWhiteSpace(dr("AdditionalInfo")) Then
                    OtherTextBox.Text = dr("AdditionalInfo")
                End If
            Else
                markSectionSelected("Chromendoscopies", Session(Constants.SESSION_PROCEDURE_ID))
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
End Class