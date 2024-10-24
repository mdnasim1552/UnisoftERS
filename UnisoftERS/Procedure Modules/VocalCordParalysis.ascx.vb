Public Class VocalCordParalysis1
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            bindParalysisOptions()
        End If
    End Sub

    Private Sub bindParalysisOptions()
        Try
            Dim dbResult = DataAdapter.LoadParalysisOptions()

            rptVocalCordParalysis.DataSource = dbResult
            rptVocalCordParalysis.DataBind()

            Dim procedureVocalCordParalysis = DataAdapter.getProcedureVocalCordParalysis(Session(Constants.SESSION_PROCEDURE_ID))
            'Added by rony tfs-4326
            If (procedureVocalCordParalysis.Rows.Count > 0) Then
                AdditionalInformationTextBox.Text = procedureVocalCordParalysis.Rows(0)("AdditionalInformation")
            End If

            For Each itm As RepeaterItem In rptVocalCordParalysis.Items
                Dim rb As New RadioButton

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is RadioButton Then
                        rb = CType(ctrl, RadioButton)
                    End If
                Next

                If rb IsNot Nothing Then
                    Dim vocalCordParalysisId = CInt(rb.Attributes.Item("data-uniqueid"))

                    rb.Checked = procedureVocalCordParalysis.AsEnumerable.Any(Function(x) CInt(x("VocalCordParalysisId")) = VocalCordParalysisId)
                    rb.Attributes.Add("onchange", "paralysisChanged('" & rb.ClientID & "');")
                End If
            Next

        Catch ex As Exception

        End Try
    End Sub
End Class