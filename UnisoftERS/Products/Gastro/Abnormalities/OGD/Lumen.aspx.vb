Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Gastro_Abnormalities_Lumen
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            SetControls()
            Dim dtLumen As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_lumen_select")
            If dtLumen.Rows.Count > 0 Then
                PopulateData(dtLumen.Rows(0))
            End If
        End If
        SetControlProperties()
    End Sub

    'Protected Sub Page_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
    '    Call uniAdaptor.IsAuthenticated()
    '    'TODO - close the window down and then redirect to the login page
    'End Sub

    Private Sub InsertComboBoxItem(ctrl As RadComboBox)
        If ctrl.ID.LastIndexOf("_Amount_ComboBox") > 0 Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Small", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Moderate", "2"))
            ctrl.Items.Add(New RadComboBoxItem("Large", "3"))

            ctrl.Items(1).CssClass = "abnor_cb1"
            ctrl.Items(2).CssClass = "abnor_cb2"
            ctrl.Items(3).CssClass = "abnor_cb3"
            ctrl.Width = "110"
        ElseIf ctrl.ID.LastIndexOf("_Origin_ComboBox") > 0 Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Not Identified", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Transported", "2"))

            ctrl.Items(1).CssClass = "abnor_cb1"
            ctrl.Items(2).CssClass = "abnor_cb2"

            ctrl.Width = "110"
        End If
        ctrl.Style("text-align") = "center"
        ctrl.Enabled = False
        ctrl.CssClass = "abnor_cb1"
        ctrl.OnClientSelectedIndexChanged = "toggleClass"
    End Sub

    Private Sub SetControls()
        For Each ctrl As Control In rgAbnormalities.Controls
            If TypeOf ctrl Is RadComboBox Then
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
        NoneCheckBox.Checked = CBool(drGU("NoBlood"))
        FreshBlood_CheckBox.Checked = CBool(drGU("FreshBlood"))
        FreshBlood_Amount_ComboBox.SelectedValue = CInt(drGU("FreshBloodAmount"))
        FreshBlood_Origin_ComboBox.SelectedValue = CInt(drGU("FreshBloodOrigin"))
        AlteredBlood_CheckBox.Checked = CBool(drGU("AlteredBlood"))
        AlteredBlood_Amount_ComboBox.SelectedValue = CInt(drGU("AlteredBloodAmount"))
        AlteredBlood_Origin_ComboBox.SelectedValue = CInt(drGU("AlteredBloodOrigin"))
        Food_CheckBox.Checked = CBool(drGU("Food"))
        Food_Amount_ComboBox.SelectedValue = CInt(drGU("FoodAmount"))
        Bile_CheckBox.Checked = CBool(drGU("Bile"))
        Bile_Amount_ComboBox.SelectedValue = CInt(drGU("BileAmount"))

        SetControlProperties()
    End Sub

    Private Sub SetControlProperties()
        DisableControls(FreshBlood_CheckBox, FreshBlood_Amount_ComboBox, FreshBlood_Origin_ComboBox)
        DisableControls(AlteredBlood_CheckBox, AlteredBlood_Amount_ComboBox, AlteredBlood_Origin_ComboBox)
        DisableControls(Food_CheckBox, Food_Amount_ComboBox, Nothing)
        DisableControls(Bile_CheckBox, Bile_Amount_ComboBox, Nothing)
    End Sub

    Private Sub DisableControls(abnorCheckBox As RadButton, _
                                amountCombobox As RadComboBox, _
                                originCombobox As RadComboBox)
        If abnorCheckBox.Checked Then
            amountCombobox.Enabled = True
            amountCombobox.CssClass = "abnor_cb" & amountCombobox.SelectedValue.ToString
            If Not originCombobox Is Nothing Then
                originCombobox.Enabled = True
                originCombobox.CssClass = "abnor_cb" & (originCombobox.SelectedValue).ToString
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
            AbnormalitiesDataAdapter.SaveLumenData(
                siteId, NoneCheckBox.Checked,
                FreshBlood_CheckBox.Checked, GetRadioValue(FreshBlood_Amount_ComboBox), GetRadioValue(FreshBlood_Origin_ComboBox),
                AlteredBlood_CheckBox.Checked, GetRadioValue(AlteredBlood_Amount_ComboBox), GetRadioValue(AlteredBlood_Origin_ComboBox),
                Food_CheckBox.Checked, GetRadioValue(Food_Amount_ComboBox),
                Bile_CheckBox.Checked, GetRadioValue(Bile_Amount_ComboBox))

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Lumen.", ex)

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
