Imports DevExpress.Data.Controls.ExpressionEditor
Imports Microsoft.Ajax.Utilities
Imports UnisoftERS.ScotHospitalWebservice

Public Class LevelOfComplexity
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            loadLevelOfComplexity()
        End If
    End Sub

    Private Sub loadLevelOfComplexity()
        Try

            Dim LevelOfComplexityDatasource = DataAdapter.LoadLevelOfComplexity()

            ComplexityRadioButtonList.DataSource = LevelOfComplexityDatasource
            ComplexityRadioButtonList.DataTextField = "Description"
            ComplexityRadioButtonList.DataValueField = "UniqueId"
            ComplexityRadioButtonList.DataBind()

            Dim ProcedureComplexity = DataAdapter.getProcedureLevelOfComplexity(Session(Constants.SESSION_PROCEDURE_ID))
            If ProcedureComplexity.Rows.Count > 0 Then
                ComplexityRadioButtonList.SelectedValue = ProcedureComplexity.Rows(0)("ComplexityId").ToString()
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

End Class