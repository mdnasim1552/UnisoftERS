Imports Telerik.Web.UI

Public Class EditOtherAbnormality
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            'PopulateProcedureTypeDropdown
            Dim da As DataAccess = New DataAccess
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ProcedureTypeRadComboBox, ""}}, da.GetProcedureTypes(1), "ProcedureType", "ProcedureTypeId", True)

            Dim otherAbnoId As Integer = CInt(Request.QueryString("otherAbnoId"))
            If otherAbnoId = 0 Then
                'we have a new record being created
                Utilities.LoadCheckBoxList(RegionsCheckboxes, da.GetRegionsForProcedureType(ProcedureTypeRadComboBox.SelectedValue), "Region", "RegionId", True)
            Else
                AbnormalityId.Value = otherAbnoId
                'lets populate the abnormality from the database
                Dim dt As DataTable = da.GetOtherAbnormalities(otherAbnoId)
                If dt.Rows.Count > 0 Then
                    AbnormalityTextBox.Text = dt.Rows(0).Item("Abnormality")
                    SummaryTextBox.Text = dt.Rows(0).Item("Summary")
                    DiagnosisTextBox.Text = dt.Rows(0).Item("Diagnoses")
                    ProcedureTypeRadComboBox.SelectedIndex = ProcedureTypeRadComboBox.FindItemIndexByValue(dt.Rows(0).Item("ProcedureTypeId"))
                    Utilities.LoadCheckBoxList(RegionsCheckboxes, da.GetRegionsForProcedureType(dt.Rows(0).Item("ProcedureTypeId")), "Region", "RegionId", True)
                    PopulateCheckboxes(otherAbnoId)
                    ActiveCheckBox.Checked = dt.Rows(0).Item("Active")
                End If

            End If

        End If
    End Sub

    Protected Sub PopulateCheckboxes(otherAbnoId As Integer)
        Dim da As DataAccess = New DataAccess
        Dim dt As DataTable = da.GetRegionsForOtherAbnormalities(otherAbnoId)
        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows
                Dim i As Integer
                For i = 0 To RegionsCheckboxes.Items.Count - 1
                    If RegionsCheckboxes.Items(i).Value = dr("RegionId") Then
                        RegionsCheckboxes.Items(i).Selected = True
                    End If
                Next
            Next
        End If
    End Sub

    Protected Sub ProcedureTypeRadComboBox_SelectedIndexChanged(sender As Object, e As EventArgs)
        Dim procedureTypeId = ProcedureTypeRadComboBox.SelectedValue
        Dim da As DataAccess = New DataAccess
        Utilities.LoadCheckBoxList(RegionsCheckboxes, da.GetRegionsForProcedureType(procedureTypeId), "Region", "RegionId", True)
    End Sub

    Protected Sub saveButton_Click()
        Dim regions As String = ""
        For i = 0 To RegionsCheckboxes.Items.Count - 1
            If RegionsCheckboxes.Items(i).Selected Then
                regions += RegionsCheckboxes.Items(i).Value + ","

            End If
        Next
        Dim da As DataAccess = New DataAccess
        da.SaveOtherAbnormalitySettings(AbnormalityId.Value,
                                        AbnormalityTextBox.Text,
                                        SummaryTextBox.Text,
                                        DiagnosisTextBox.Text,
                                        ProcedureTypeRadComboBox.SelectedValue,
                                        regions,
                                        ActiveCheckBox.Checked)
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType, "SaveAndClose", "CloseAndRebind();", True)
    End Sub

End Class
