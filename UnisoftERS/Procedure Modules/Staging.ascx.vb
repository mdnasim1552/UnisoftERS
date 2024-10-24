Imports Telerik.Web.UI

Public Class Staging
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim da As New OtherData
            Dim dtPathology As DataTable = da.GetBroncoStaging(Session(Constants.SESSION_PROCEDURE_ID))
            If dtPathology.Rows.Count > 0 Then
                PopulateData(dtPathology.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drPathology As DataRow)
        StagingInvestigationsCheckBox.Checked = CBool(drPathology("StagingInvestigations"))
        ClinicalGroundsCheckBox.Checked = CBool(drPathology("ClinicalGrounds"))
        ImagingOfThoraxCheckBox.Checked = CBool(drPathology("ImagingOfThorax"))
        MediastinalSamplingCheckBox.Checked = CBool(drPathology("MediastinalSampling"))
        MetastasesCheckBox.Checked = CBool(drPathology("Metastases"))
        PleuralHistologyCheckBox.Checked = CBool(drPathology("PleuralHistology"))
        BronchoscopyCheckBox.Checked = CBool(drPathology("Bronchoscopy"))
        StageCheckBox.Checked = CBool(drPathology("Stage"))
        StageTComboBox.SelectedValue = CInt(drPathology("StageT"))
        StageNComboBox.SelectedValue = CInt(drPathology("StageN"))
        StageMComboBox.SelectedValue = CInt(drPathology("StageM"))
        If Not IsDBNull(drPathology("StageLocation")) Then TumourLocationComboBox.SelectedValue = CInt(drPathology("StageLocation"))
        PerformanceStatusCheckBox.Checked = CBool(drPathology("PerformanceStatus"))
        If Not IsDBNull(drPathology("PerformanceStatusType")) Then PerformanceStatusTypeRadioButtonList.SelectedValue = CInt(drPathology("PerformanceStatusType"))
    End Sub
End Class