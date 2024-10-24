Imports Telerik.Web.UI
Imports System.Drawing
Imports Hl7.Fhir.Model

Partial Class Products_Gastro_Abnormalities_Gastritis
    Inherits SiteDetailsBase

    Public siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        InspectionStartDateRadTimeInput.SelectedDate = CDate(Session(Constants.SESSION_PROCEDURE_DATE))
        InspectionEndDateRadTimeInput.SelectedDate = CDate(Session(Constants.SESSION_PROCEDURE_DATE))

        If Not Page.IsPostBack Then
            SetControls()
            populateSydneyProtocol()

            Dim dtGU As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_gastritis_select")
            If dtGU.Rows.Count > 0 Then
                PopulateData(dtGU.Rows(0))

                'load existing sydney protocol data
            End If

        End If
        SetControlProperties()
    End Sub

    Private Sub populateSydneyProtocol()
        Try
            SydneyProtocalSitesRepeater.DataSource = DataAdapter.LoadSydneyProtocolSites()
            SydneyProtocalSitesRepeater.DataBind()

            Dim dtProtocolSites = DataAdapter.LoadSitesBiopsies(siteId)

            If dtProtocolSites IsNot Nothing AndAlso dtProtocolSites.Rows.Count > 0 Then
                For Each itm As RepeaterItem In SydneyProtocalSitesRepeater.Items
                    Dim ProtocolSiteHiddenField As HiddenField = itm.FindControl("SydneyProtocolSiteIdHiddenField")
                    Dim ProtocolSiteSpecimenIdHiddenField As HiddenField = itm.FindControl("SydneyProtocolSiteSpecimenIdHiddenField")
                    If ProtocolSiteHiddenField IsNot Nothing Then
                        Dim BiopsyQtyNumericTextBox As RadNumericTextBox = itm.FindControl("BiopsyQtyNumericTextBox")
                        Dim biopsyQty = (From dr In dtProtocolSites.AsEnumerable
                                         Where dr("ProtocolSiteId") = ProtocolSiteHiddenField.Value
                                         Select dr("Qty")).FirstOrDefault

                        If biopsyQty IsNot Nothing Then
                            BiopsyQtyNumericTextBox.Value = CInt(biopsyQty)
                            ProtocolSiteSpecimenIdHiddenField.Value = (From dr In dtProtocolSites.AsEnumerable
                                                                       Where dr("ProtocolSiteId") = ProtocolSiteHiddenField.Value
                                                                       Select dr("SiteSpecimenId")).FirstOrDefault
                        End If

                    End If
                Next
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading sydney protocol sites.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a loading sydney protocol sites.")
            RadNotification1.Show()
        End Try
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
            ctrl.Items.Add(New RadComboBoxItem("None", "9"))
            ctrl.Items.Add(New RadComboBoxItem("Active", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Recent", "2"))

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
    Private Sub PopulateData(drGU As DataRow)

        NoneCheckBox.Checked = CBool(drGU("None"))

        Erythematous_CheckBox.Checked = CBool(drGU("Erythematous"))
        Erythematous_Severity_ComboBox.SelectedValue = CInt(drGU("ErythematousSeverity"))
        Erythematous_Bleeding_ComboBox.SelectedValue = CInt(drGU("ErythematousBleeding"))

        FlatErosive_CheckBox.Checked = CBool(drGU("FlatErosive"))
        FlatErosive_Severity_ComboBox.SelectedValue = CInt(drGU("FlatErosiveSeverity"))
        FlatErosive_Bleeding_ComboBox.SelectedValue = CInt(drGU("FlatErosiveBleeding"))

        RaisedErosive_CheckBox.Checked = CBool(drGU("RaisedErosive"))
        RaisedErosive_Severity_ComboBox.SelectedValue = CInt(drGU("RaisedErosiveSeverity"))
        RaisedErosive_Bleeding_ComboBox.SelectedValue = CInt(drGU("RaisedErosiveBleeding"))

        Atrophic_CheckBox.Checked = CBool(drGU("Atrophic"))
        Atrophic_Severity_ComboBox.SelectedValue = CInt(drGU("AtrophicSeverity"))
        Atrophic_Bleeding_ComboBox.SelectedValue = CInt(drGU("AtrophicBleeding"))

        Haemorrhagic_CheckBox.Checked = CBool(drGU("Haemorrhagic"))
        Haemorrhagic_Severity_ComboBox.SelectedValue = CInt(drGU("HaemorrhagicSeverity"))
        Haemorrhagic_Bleeding_ComboBox.SelectedValue = CInt(drGU("HaemorrhagicBleeding"))

        Reflux_CheckBox.Checked = CBool(drGU("Reflux"))
        Reflux_Severity_ComboBox.SelectedValue = CInt(drGU("RefluxSeverity"))
        Reflux_Bleeding_ComboBox.SelectedValue = CInt(drGU("RefluxBleeding"))

        RugalHyperplastic_CheckBox.Checked = CBool(drGU("RugalHyperplastic"))
        RugalHyperplastic_Severity_ComboBox.SelectedValue = CInt(drGU("RugalHyperplasticSeverity"))
        RugalHyperplastic_Bleeding_ComboBox.SelectedValue = CInt(drGU("RugalHyperplasticBleeding"))

        Vomiting_CheckBox.Checked = CBool(drGU("Vomiting"))
        Vomiting_Severity_ComboBox.SelectedValue = CInt(drGU("VomitingSeverity"))
        Vomiting_Bleeding_ComboBox.SelectedValue = CInt(drGU("VomitingBleeding"))

        PromAreaeGastricae_CheckBox.Checked = CBool(drGU("PromAreaeGastricae"))
        PromAreaeGastricae_Severity_ComboBox.SelectedValue = CInt(drGU("PromAreaeGastricaeSeverity"))

        Corrosive_Burns_CheckBox.Checked = CBool(drGU("CorrosiveBurns"))
        Corrosive_Burns_Severity_ComboBox.SelectedValue = CInt(drGU("CorrosiveBurnsSeverity"))
        Corrosive_Burns_Bleeding_ComboBox.SelectedValue = CInt(drGU("CorrosiveBurnsBleeding"))

        Intestinal_Metaplasia_CheckBox.Checked = CBool(drGU("IntestinalMetaplasia"))
        Intestinal_Metaplasia_Severity_ComboBox.SelectedValue = CInt(drGU("IntestinalMetaplasiaSeverity"))

        SetControlProperties()



        If CBool(drGU("Atrophic")) Or CBool(drGU("IntestinalMetaplasia")) Then
            Dim dtTimings = DataAdapter.GetGastricInspectionTimings(siteId)
            If dtTimings.Rows.Count > 0 Then
                Dim dr = dtTimings.Rows(0)
                If Not dr.IsNull("GastricInspectionStartDateTime") Then
                    InspectionStartDateRadTimeInput.SelectedDate = DateTime.Parse(dr("GastricInspectionStartDateTime"))
                    InspectionStartRadTimePicker.SelectedTime = DateTime.Parse(dr("GastricInspectionStartDateTime")).TimeOfDay
                End If
                If Not dr.IsNull("GastricInspectionEndDateTime") Then
                    InspectionEndDateRadTimeInput.SelectedDate = DateTime.Parse(dr("GastricInspectionEndDateTime"))
                    InspectionEndRadTimePicker.SelectedTime = DateTime.Parse(dr("GastricInspectionEndDateTime")).TimeOfDay
                End If
            End If
        End If
    End Sub

    Private Sub SetControlProperties()
        DisableControls(Erythematous_CheckBox, Erythematous_Severity_ComboBox, Erythematous_Bleeding_ComboBox)
        DisableControls(FlatErosive_CheckBox, FlatErosive_Severity_ComboBox, FlatErosive_Bleeding_ComboBox)
        DisableControls(RaisedErosive_CheckBox, RaisedErosive_Severity_ComboBox, RaisedErosive_Bleeding_ComboBox)
        DisableControls(Atrophic_CheckBox, Atrophic_Severity_ComboBox, Atrophic_Bleeding_ComboBox)
        DisableControls(Haemorrhagic_CheckBox, Haemorrhagic_Severity_ComboBox, Haemorrhagic_Bleeding_ComboBox)
        DisableControls(Reflux_CheckBox, Reflux_Severity_ComboBox, Reflux_Bleeding_ComboBox)
        DisableControls(RugalHyperplastic_CheckBox, RugalHyperplastic_Severity_ComboBox, RugalHyperplastic_Bleeding_ComboBox)
        DisableControls(Vomiting_CheckBox, Vomiting_Severity_ComboBox, Vomiting_Bleeding_ComboBox)
        DisableControls(Corrosive_Burns_CheckBox, Corrosive_Burns_Severity_ComboBox, Corrosive_Burns_Bleeding_ComboBox)
        DisableControls(Intestinal_Metaplasia_CheckBox, Intestinal_Metaplasia_Severity_ComboBox, Nothing)
        DisableControls(PromAreaeGastricae_CheckBox, PromAreaeGastricae_Severity_ComboBox, Nothing)
    End Sub

    Private Sub DisableControls(abnorCheckBox As RadButton,
                                severityCombobox As RadComboBox,
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

        'Dim xx As String = Me.MasterPageFile()


        Try
            AbnormalitiesDataAdapter.SaveGastritisData(
                siteId, NoneCheckBox.Checked,
                Erythematous_CheckBox.Checked, GetRadioValue(Erythematous_Severity_ComboBox), GetRadioValue(Erythematous_Bleeding_ComboBox),
                FlatErosive_CheckBox.Checked, GetRadioValue(FlatErosive_Severity_ComboBox), GetRadioValue(FlatErosive_Bleeding_ComboBox),
                RaisedErosive_CheckBox.Checked, GetRadioValue(RaisedErosive_Severity_ComboBox), GetRadioValue(RaisedErosive_Bleeding_ComboBox),
                Atrophic_CheckBox.Checked, GetRadioValue(Atrophic_Severity_ComboBox), GetRadioValue(Atrophic_Bleeding_ComboBox),
                Haemorrhagic_CheckBox.Checked, GetRadioValue(Haemorrhagic_Severity_ComboBox), GetRadioValue(Haemorrhagic_Bleeding_ComboBox),
                Reflux_CheckBox.Checked, GetRadioValue(Reflux_Severity_ComboBox), GetRadioValue(Reflux_Bleeding_ComboBox),
                RugalHyperplastic_CheckBox.Checked, GetRadioValue(RugalHyperplastic_Severity_ComboBox), GetRadioValue(RugalHyperplastic_Bleeding_ComboBox),
                Vomiting_CheckBox.Checked, GetRadioValue(Vomiting_Severity_ComboBox), GetRadioValue(Vomiting_Bleeding_ComboBox),
                Corrosive_Burns_CheckBox.Checked, GetRadioValue(Corrosive_Burns_Severity_ComboBox), GetRadioValue(Corrosive_Burns_Bleeding_ComboBox),
                PromAreaeGastricae_CheckBox.Checked, GetRadioValue(PromAreaeGastricae_Severity_ComboBox),
                Intestinal_Metaplasia_CheckBox.Checked, GetRadioValue(Intestinal_Metaplasia_Severity_ComboBox))

            'save sidney protocol stuff
            If Not NoneCheckBox.Checked Then
                For Each itm As RepeaterItem In SydneyProtocalSitesRepeater.Items
                    If itm.ItemType = ListItemType.Item Or itm.ItemType = ListItemType.AlternatingItem Then
                        Dim protocolSiteId As Integer = CType(itm.FindControl("SydneyProtocolSiteIdHiddenField"), HiddenField).Value
                        Dim ProtocolSiteSpecimenIdHiddenField As Integer = CType(itm.FindControl("SydneyProtocolSiteSpecimenIdHiddenField"), HiddenField).Value
                        Dim qty As Integer = If(CType(itm.FindControl("BiopsyQtyNumericTextBox"), RadNumericTextBox).Value Is Nothing, 0, CType(itm.FindControl("BiopsyQtyNumericTextBox"), RadNumericTextBox).Value)
                        If qty > 0 Then
                            AbnormalitiesDataAdapter.saveSydneyProtocolData(siteId, protocolSiteId, qty, Session(Constants.SESSION_PROCEDURE_ID))
                        Else
                            If ProtocolSiteSpecimenIdHiddenField <> 0 Then
                                Dim procedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))
                                DataAdapter.deleteSiteBiopsy(ProtocolSiteSpecimenIdHiddenField, procedureId)
                            End If
                        End If
                    End If
                Next
            End If

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "refreshDiagramGastritis(" & siteId & "); setRehideSummary(); ", True)
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Gastritis.", ex)

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
