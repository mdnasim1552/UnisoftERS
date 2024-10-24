Imports Telerik.Web.UI

Public Class DrugsAdministered
    Inherits System.Web.UI.UserControl

    Private procType As Integer
    Private _dataAdapter As DataAccess = Nothing

    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataAdapter Is Nothing Then
                _dataAdapter = New DataAccess
            End If
            Return _dataAdapter
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            Dim da As New OtherData
            Dim dtDrugs As DataTable = da.GetBronchoDrugs(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtDrugs.Rows.Count > 0 Then
                PopulateData(dtDrugs.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drDrugs As DataRow)
        'If Not IsDBNull(drDrugs("EffectOfSedation")) Then EffectOfSedationRadioButtonList.SelectedValue = CInt(drDrugs("EffectOfSedation"))
        LignocaineSprayCheckBox.Checked = CBool(drDrugs("LignocaineSpray"))
        LignocaineGelCheckBox.Checked = CBool(drDrugs("LignocaineGel"))
        If Not IsDBNull(drDrugs("LignocaineViaScope1pc")) Then LignocaineViaScope1pcTextBox.Value = CDec(drDrugs("LignocaineViaScope1pc"))
        If Not IsDBNull(drDrugs("LignocaineSprayTotal")) Then LignocaineSprayTextBox.Value = CDec(drDrugs("LignocaineSprayTotal"))
        If Not IsDBNull(drDrugs("LignocaineSprayPercentage")) Then LignocaineSprayPercentageRadioButtonList.SelectedValue = CInt(drDrugs("LignocaineSprayPercentage")) 'Added by rony tfs-4328
        If Not IsDBNull(drDrugs("LignocaineViaScope2pc")) Then LignocaineViaScope2pcTextBox.Value = CDec(drDrugs("LignocaineViaScope2pc"))
        If Not IsDBNull(drDrugs("LignocaineViaScope4pc")) Then LignocaineViaScope4pcTextBox.Value = CDec(drDrugs("LignocaineViaScope4pc"))
        If Not IsDBNull(drDrugs("LignocaineNebuliser2pc")) Then LignocaineNebuliser2pcTextBox.Value = CDec(drDrugs("LignocaineNebuliser2pc"))
        If Not IsDBNull(drDrugs("LignocaineNebuliser4pc")) Then LignocaineNebuliser4pcTextBox.Value = CDec(drDrugs("LignocaineNebuliser4pc"))
        If Not IsDBNull(drDrugs("LignocaineTranscricoid2pc")) Then LignocaineTranscricoid2pcTextBox.Value = CDec(drDrugs("LignocaineTranscricoid2pc"))
        If Not IsDBNull(drDrugs("LignocaineTranscricoid4pc")) Then LignocaineTranscricoid4pcTextBox.Value = CDec(drDrugs("LignocaineTranscricoid4pc"))
        If Not IsDBNull(drDrugs("LignocaineBronchial1pc")) Then LignocaineBronchial1pcTextBox.Value = CDec(drDrugs("LignocaineBronchial1pc"))
        If Not IsDBNull(drDrugs("LignocaineBronchial2pc")) Then LignocaineBronchial2pcTextBox.Value = CDec(drDrugs("LignocaineBronchial2pc"))
        If Not IsDBNull(drDrugs("TotalLignocaine")) Then LignocaineTotalTextBox.Value = CDec(drDrugs("TotalLignocaine")) 'Added by rony tfs-4328
        SupplyOxygenCheckBox.Checked = CBool(drDrugs("SupplyOxygen"))
        If Not IsDBNull(drDrugs("SupplyOxygenPercentage")) Then SupplyOxygenPercentageTextBox.Value = CDec(drDrugs("SupplyOxygenPercentage"))
        If Not IsDBNull(drDrugs("Nasal")) Then NasalTextBox.Value = CDec(drDrugs("Nasal"))
        If Not IsDBNull(drDrugs("SpO2Base")) Then SpO2BaseTextBox.Value = CDec(drDrugs("SpO2Base"))
        If Not IsDBNull(drDrugs("SpO2Min")) Then SpO2MinTextBox.Value = CDec(drDrugs("SpO2Min"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) 'Handles SaveButton.Click
        Dim da As New OtherData

        Try
            da.SaveBronchoDrugs(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                Nothing, 'Utilities.GetRadioValue(EffectOfSedationRadioButtonList),
                                LignocaineSprayCheckBox.Checked,
                                LignocaineGelCheckBox.Checked,
                                Utilities.GetNumericTextBoxValue(LignocaineSprayTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineViaScope1pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineViaScope2pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineViaScope4pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineNebuliser2pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineNebuliser4pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineTranscricoid2pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineTranscricoid4pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineBronchial1pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineBronchial2pcTextBox),
                                SupplyOxygenCheckBox.Checked,
                                Utilities.GetNumericTextBoxValue(SupplyOxygenPercentageTextBox),
                                Utilities.GetNumericTextBoxValue(NasalTextBox),
                                Utilities.GetNumericTextBoxValue(SpO2BaseTextBox),
                                Utilities.GetNumericTextBoxValue(SpO2MinTextBox),
                                LignocaineSprayPercentageRadioButtonList.SelectedValue) 'Added by rony tfs-4328

            Dim dtIn As DataTable = da.GetUpperGIIndications(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtIn.Rows.Count > 0 Then
                PopulateData(dtIn.Rows(0))
            End If

            'ExitForm()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Bronchoscopy Drugs.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class