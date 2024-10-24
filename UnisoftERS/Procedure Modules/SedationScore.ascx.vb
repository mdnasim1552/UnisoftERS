Imports Telerik.Web.UI

Public Class SedationScore
    Inherits ProcedureControls

    Public Property IsEnabled As Boolean = True

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            bindSedationScores()
        End If
    End Sub

    Private Sub bindSedationScores()
        Try
            Dim dbResult = DataAdapter.LoadSedationScores()

            rptSedationScore.DataSource = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = 0).CopyToDataTable
            rptSedationScore.DataBind()



            Dim procedureSedationScore = DataAdapter.getProcedureSedationScore(Session(Constants.SESSION_PROCEDURE_ID))
            'Added by rony tfs-4075
            If procedureSedationScore.Rows.Count > 0 Then
                Dim dr = procedureSedationScore.Rows(0)
                PatientSedationGeneralAneatheticTextBox.Text = CDec(If(IsDBNull(dr("GeneralAneathetic")), 0, (dr("GeneralAneathetic"))))
            End If


            For Each itm As RepeaterItem In rptSedationScore.Items
                Dim rb As New RadioButton

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is RadioButton Then
                        rb = CType(ctrl, RadioButton)
                    End If
                Next

                If rb IsNot Nothing Then
                    Dim scoreId = CInt(rb.Attributes.Item("data-uniqueid"))

                    rb.Checked = procedureSedationScore.AsEnumerable.Any(Function(x) CInt(x("SedationScoreId")) = scoreId)
                    rb.Attributes.Add("onchange", "sedationScoreChanged('" & rb.ClientID & "');")

                    If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = scoreId) Then
                        Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = scoreId)

                        'create a dropdown list and bind child items to it
                        Dim ddlChildItems As New RadComboBox
                        With ddlChildItems
                            .AutoPostBack = False
                            .Skin = "Metro"
                            .CssClass = "sedation-score-child"
                            .Attributes.Add("data-uniqueid", scoreId)
                            .OnClientSelectedIndexChanged = "childsedationscore_changed"
                            If Not rb.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                        End With


                        For Each ci In childItems
                            ddlChildItems.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                        Next
                        ddlChildItems.Items.Insert(0, New RadComboBoxItem("", 0))

                        ddlChildItems.Sort = RadComboBoxSort.Ascending

                        If procedureSedationScore.AsEnumerable.Any(Function(x) CInt(x("SedationScoreId")) = scoreId And CInt(x("ChildId")) > 0) Then
                            Dim childIndicationId = (From pi In procedureSedationScore.AsEnumerable
                                                     Where CInt(pi("SedationScoreId")) = scoreId
                                                     Select CInt(pi("ChildId"))).FirstOrDefault

                            ddlChildItems.SelectedIndex = ddlChildItems.Items.FindItemIndexByValue(childIndicationId)
                        End If

                        'add the control to the relevant td
                        itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildItems)
                    End If

                    If Not IsEnabled Then
                        rb.Enabled = False
                    End If
                End If
            Next
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
End Class