Public Class FITResult
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            populatePage()
        End If
    End Sub

    Private Sub populatePage()
        FITNotKnownRadComboBox.DataSource = DataAdapter.getFITNotKnownValues
        FITNotKnownRadComboBox.DataBind()

        'get and set result
        Dim fitDT = DataAdapter.getProcedureFitResult(Session(Constants.SESSION_PROCEDURE_ID))

        If fitDT IsNot Nothing AndAlso fitDT.Rows.Count > 0 Then
            Dim dr = fitDT.Rows(0)
            Dim FITValue = dr("FITValue").ToString
            Dim FITNotKnownValue = CInt(dr("FITNotKnownId"))

            If Not String.IsNullOrWhiteSpace(FITValue) Then
                FitResultKnownRadioButtonList.SelectedValue = 1
                FITValueRadTextBox.Text = FITValue
                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-fit", "toggleFITResultSection();", True)
            ElseIf FITNotKnownValue > 0 Then
                FitResultKnownRadioButtonList.SelectedValue = 0
                FITNotKnownRadComboBox.SelectedIndex = FITNotKnownRadComboBox.Items.FindItemIndexByValue(FITNotKnownValue)
                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-fit", "toggleFITResultSection();", True)
            End If


        End If
    End Sub

End Class