Imports Telerik.Web.UI

Public Class DiscomfortScore
    Inherits ProcedureControls

    Public Property IsEnabled As Boolean = True

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            loadComfortScores()
        End If
    End Sub

    Private Sub loadComfortScores()
        Try
            DiscomfortScoreRadComboBox.DataSource = DataAdapter.LoadDiscomfortScores()
            DiscomfortScoreRadComboBox.DataBind()

            Dim procedureDiscomfortScore = DataAdapter.getProcedureDiscomfortScore(Session(Constants.SESSION_PROCEDURE_ID))
            If procedureDiscomfortScore.Rows.Count > 0 Then
                Dim scoreResult = procedureDiscomfortScore.Rows(0)("DiscomfortScoreId")
                DiscomfortScoreRadComboBox.SelectedIndex = DiscomfortScoreRadComboBox.Items.FindItemIndexByValue(scoreResult)
            Else
                DiscomfortScoreRadComboBox.Items.Insert(0, New RadComboBoxItem(""))
            End If

            If Not IsEnabled Then DiscomfortScoreRadComboBox.Enabled = False
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

End Class