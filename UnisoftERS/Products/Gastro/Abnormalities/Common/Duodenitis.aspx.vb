Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Gastro_Abnormalities_Common_Duodenitis
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        Dim reg As String = Request.QueryString("Reg")

        If reg = "Jejunum" Then
            HeaderDiv.InnerText = "Jejunitis"
            Duodenitis_CheckBox.Text = "Jejunitis"
        ElseIf reg = "Ileum" Then
            HeaderDiv.InnerText = "Ileitis"
            Duodenitis_CheckBox.Text = "Ileitis"
        Else
            HeaderDiv.InnerText = "Duodenitis"
            Duodenitis_CheckBox.Text = "Duodenitis"
        End If

        If Not Page.IsPostBack Then
            SetControls(rgAbnormalities)
            SetControls(AssociatedWithFieldset)
            Dim dtGU As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_duodenitis_select")
            If dtGU.Rows.Count > 0 Then
                PopulateData(dtGU.Rows(0))
            End If
        End If
        SetControlProperties()
    End Sub

    Private Sub InsertComboBoxItem(ctrl As RadComboBox)
        If ctrl.ID.LastIndexOf("_Severity") > 0 Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Mild", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Moderate", "2"))
            ctrl.Items.Add(New RadComboBoxItem("Severe", "3"))

            ctrl.Items(1).CssClass = "abnor_cb1"
            ctrl.Items(2).CssClass = "abnor_cb2"
            ctrl.Items(3).CssClass = "abnor_cb3"
            ctrl.Width = "110"
        ElseIf ctrl.ID.LastIndexOf("_Bleeding") > 0 Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("None", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Active", "2"))
            ctrl.Items.Add(New RadComboBoxItem("Recent", "3"))

            ctrl.Items(0).CssClass = "abnor_cb1"
            ctrl.Items(1).CssClass = "abnor_cb2"
            ctrl.Items(2).CssClass = "abnor_cb3"
            'ctrl.Items(2).ForeColor = Color.Red
            ctrl.Width = "110"
            ctrl.CssClass = "abnor_cb1"
        End If
        ctrl.Style("text-align") = "center"
        ctrl.Enabled = False
        ctrl.CssClass = "abnor_cb1"
        ctrl.OnClientSelectedIndexChanged = "toggleClass"
    End Sub

    'Protected Sub Page_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
    '    Call uniAdaptor.IsAuthenticated()
    '    'TODO - close the window down and then redirect to the login page
    'End Sub

    Private Sub SetControls(pCtrl As Object)
        For Each ctrl As Control In (pCtrl.Controls)
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

    Private Sub PopulateData(drGU As DataRow)

        NoneCheckBox.Checked = CBool(drGU("None"))

        Duodenitis_CheckBox.Checked = CBool(drGU("Duodenitis"))
        Duodenitis_Severity_ComboBox.SelectedValue = CInt(drGU("Severity"))
        Duodenitis_Bleeding_ComboBox.SelectedValue = CInt(drGU("Bleeding"))
        Patchy_Erythema_ChkBox.Checked = CBool(drGU("PatchyErythema"))
        Diffuse_Erythema_ChkBox.Checked = CBool(drGU("DiffuseErythema"))
        Erosions_ChkBox.Checked = CBool(drGU("Erosions"))
        Nodularity_ChkBox.Checked = CBool(drGU("Nodularity"))
        Oedematous_ChkBox.Checked = CBool(drGU("Oedematous"))

        'FlatErosive_CheckBox.Checked = CBool(drGU("FlatErosive"))
        'FlatErosive_Severity_ComboBox.SelectedValue = CInt(drGU("FlatErosiveSeverity"))
        'FlatErosive_Bleeding_ComboBox.SelectedValue = CInt(drGU("FlatErosiveBleeding"))

        SetControlProperties()
    End Sub

    Private Sub SetControlProperties()
        DisableControls(Duodenitis_CheckBox, Duodenitis_Severity_ComboBox, Duodenitis_Bleeding_ComboBox)
        'DisableControls(FlatErosive_CheckBox, FlatErosive_Severity_ComboBox, FlatErosive_Bleeding_ComboBox)
    End Sub

    Private Sub DisableControls(abnorCheckBox As RadButton, _
                                severityCombobox As RadComboBox, _
                                bleedingCombobox As RadComboBox)
        If abnorCheckBox.Checked Then
            severityCombobox.Enabled = True
            severityCombobox.CssClass = "abnor_cb" & severityCombobox.SelectedValue.ToString
            If Not bleedingCombobox Is Nothing Then
                bleedingCombobox.Enabled = True
                bleedingCombobox.CssClass = "abnor_cb" & (bleedingCombobox.SelectedValue + 1).ToString
            End If
            'severityCombobox.ForeColor = severityCombobox.Items(severityCombobox.SelectedValue).ForeColor
            'bleedingCombobox.ForeColor = bleedingCombobox.Items(bleedingCombobox.SelectedValue).ForeColor
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
            AbnormalitiesDataAdapter.SaveDuodenitisData(
                siteId, NoneCheckBox.Checked,
                Duodenitis_CheckBox.Checked,
                GetRadioValue(Duodenitis_Severity_ComboBox), GetRadioValue(Duodenitis_Bleeding_ComboBox),
                Patchy_Erythema_ChkBox.Checked, Diffuse_Erythema_ChkBox.Checked,
                Erosions_ChkBox.Checked, Nodularity_ChkBox.Checked,
                Oedematous_ChkBox.Checked)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then  ' //for this page issue 4166  by Mostafiz
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If


        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Duodenitis.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Function GetRadioValue(rdo As RadComboBox) As Integer
        If rdo.SelectedIndex = -1 Then
            Return 0
        Else
            Return CInt(rdo.SelectedValue)
        End If
    End Function
End Class
