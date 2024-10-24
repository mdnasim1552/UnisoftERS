Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Gastro_Abnormalities_Colon_Diverticulum
    Inherits SiteDetailsBase

    Private Shared siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_Colon_Diverticulum_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        If Not Page.IsPostBack Then
            LoadPage()
        End If
    End Sub

    Private Sub LoadPage()
        SetControls()
        Dim dtDi As DataTable = AbnormalitiesColonDataAdapter.GetDiverticulumData(siteId)
        If dtDi.Rows.Count > 0 Then
            PopulateData(dtDi.Rows(0))
        End If
    End Sub

    Private Sub SetControls()
        For Each ctrl As Control In rgAbnormalities.Controls
            If TypeOf ctrl Is RadComboBox Then
                'DirectCast(ctrl, RadComboBox).ForeColor() = Color.Red
                InsertComboBoxItem(ctrl)
            ElseIf TypeOf ctrl Is RadButton Then
                Dim abnormalitiesRB As RadButton = DirectCast(ctrl, RadButton)

                abnormalitiesRB.ToggleType = ButtonToggleType.CheckBox
                abnormalitiesRB.ButtonType = RadButtonType.ToggleButton
                abnormalitiesRB.AutoPostBack = False
                If abnormalitiesRB.ID = "NoneCheckBox" Then
                    abnormalitiesRB.ForeColor() = ColorTranslator.FromHtml("#384e76")
                Else
                    abnormalitiesRB.ForeColor() = Color.Gray
                End If
            End If
        Next
    End Sub

    Private Sub InsertComboBoxItem(ctrl As RadComboBox)
        If ctrl.ID.Contains("Distribution") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Scattered", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Localised", "2"))

        ElseIf ctrl.ID.Contains("Severity") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Mild", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Moderate", "2"))
            ctrl.Items.Add(New RadComboBoxItem("Severe", "3"))

        ElseIf ctrl.ID.Contains("Quantity") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Single", "4"))
            ctrl.Items.Add(New RadComboBoxItem("A few", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Several", "2"))
            ctrl.Items.Add(New RadComboBoxItem("Multiple", "3"))
        End If

        ctrl.Width = "110"
        ctrl.Style("text-align") = "center"
        If ctrl.ID <> "QuantityComboBox" Then
            ctrl.Enabled = False
        End If
        ctrl.CssClass = "abnor_cb1"
    End Sub

    Private Sub PopulateData(drDi As DataRow)
        NoneCheckBox.Checked = CBool(drDi("None"))
        MucosalInflammation_CheckBox.Checked = CBool(drDi("MucosalInflammation"))
        QuantityComboBox.SelectedValue = CInt(drDi("Quantity"))
        DistributionComboBox.SelectedValue = CInt(drDi("Distribution"))
        NarrowingTortuosity_CheckBox.Checked = CBool(drDi("NarrowingTortuosity"))
        NarrowingTortuosity_Severity_ComboBox.SelectedValue = CInt(drDi("Severity"))
        CircMuscleHypertrophy_CheckBox.Checked = CBool(drDi("CircMuscleHypertrophy"))

        SetControlProperties()
    End Sub

    Private Sub SetControlProperties()
        DisableControls(NarrowingTortuosity_CheckBox.Checked, NarrowingTortuosity_Severity_ComboBox)
        DisableControls(QuantityComboBox.SelectedValue <> "0", DistributionComboBox)
    End Sub

    Private Sub DisableControls(enable As Boolean,
                                combo1 As RadComboBox,
                                Optional combo2 As RadComboBox = Nothing)
        If enable Then
            combo1.Enabled = True
            combo1.CssClass = "abnor_cb" & combo1.SelectedValue.ToString
            If combo2 IsNot Nothing Then
                combo2.Enabled = True
                combo2.CssClass = "abnor_cb" & (combo2.SelectedValue + 1).ToString
            End If
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            If Not ucDICAScores.saveScoring() And
                (NarrowingTortuosity_CheckBox.Checked Or CircMuscleHypertrophy_CheckBox.Checked Or QuantityComboBox.SelectedIndex > 0) Then
                'DICA score notification
                Utilities.SetNotificationStyle(RadNotification1, "Please complete DICA scores for diverticulosis extension and qty before continuing", True, "Please correct")
                'RadNotification1.Show()
            Else
                ucDICAScores.saveScoring()
                AbnormalitiesColonDataAdapter.SaveDiverticulumData(
                                siteId,
                                NoneCheckBox.Checked,
                                MucosalInflammation_CheckBox.Checked,
                                QuantityComboBox.SelectedValue,
                                DistributionComboBox.SelectedValue,
                                NarrowingTortuosity_CheckBox.Checked,
                                NarrowingTortuosity_Severity_ComboBox.SelectedValue,
                                CircMuscleHypertrophy_CheckBox.Checked)


                If saveAndClose Then
                    SetControlProperties()

                    'Utilities.SetNotificationStyle(RadNotification1)
                    'RadNotification1.Show()
                    'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
                End If
            End If


        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Colon Abnormalities - Diverticulum.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
