Imports Telerik.Web.UI

Public Class Products_Broncho_OtherData_Pathology
    Inherits PageBase

    Private procType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            'Utilities.LoadDropdown(StageTComboBox, DataAdapter.GetDropDownList("BronchoStageT"), "ListItemText", "ListItemNo", Nothing)
            'Utilities.LoadDropdown(StageNComboBox, DataAdapter.GetDropDownList("BronchoStageN"), "ListItemText", "ListItemNo", Nothing)
            'Utilities.LoadDropdown(StageMComboBox, DataAdapter.GetDropDownList("BronchoStageM"), "ListItemText", "ListItemNo", Nothing)
            'Utilities.LoadDropdown(StageTypeComboBox, DataAdapter.GetDropDownList("BronchoStageType"), "ListItemText", "ListItemNo", Nothing)


            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                    {StageTComboBox, "BronchoStageT"},
                    {StageNComboBox, "BronchoStageN"},
                    {StageMComboBox, "BronchoStageM"},
                    {StageTypeComboBox, "BronchoStageType"}
            })

            Dim da As New OtherData
            Dim dtPathology As DataTable = da.GetBronchoPathology(IInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtPathology.Rows.Count > 0 Then
                PopulateData(dtPathology.Rows(0))
            End If

            Dim optionsDataAccess As New Options
            Dim dtSys As DataTable = optionsDataAccess.GetSystemSettings()
            If dtSys.Rows.Count > 0 Then
                If CBool(dtSys.Rows(0)("BRTPulmonaryPhysiology")) = True Then
                    RadPageView2.Visible = True
                    RadTabStrip1.Tabs(2).Visible = True
                Else
                    RadPageView2.Visible = False
                    RadTabStrip1.Tabs(2).Visible = False
                End If
            End If
        End If
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        ExitForm()
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

    Private Sub PopulateData(drPathology As DataRow)
        AsthmaCheckBox.Checked = CBool(drPathology("AsthmaThermoplasty"))
        EmphysemaCheckBox.Checked = CBool(drPathology("EmphysemaLungVolRed"))
        HaemoptysisCheckBox.Checked = CBool(drPathology("Haemoptysis"))
        HilarCheckBox.Checked = CBool(drPathology("HilarMediaLymphadenopathy"))
        InfectionCheckBox.Checked = CBool(drPathology("Infection"))
        ImmunoSuppressedCheckBox.Checked = CBool(drPathology("InfectionImmunoSuppressed"))
        LungLobarCheckBox.Checked = CBool(drPathology("LungLobarCollapse"))
        RadiologicalCheckBox.Checked = CBool(drPathology("RadiologicalAbno"))
        SuspectedLcaCheckBox.Checked = CBool(drPathology("SuspectedLCa"))
        SuspectedSarcoidosisCheckBox.Checked = CBool(drPathology("SuspectedSarcoidosis"))
        SuspectedTBCheckBox.Checked = CBool(drPathology("SuspectedTB"))
        ClinicalDetailsTextBox.Text = CStr(drPathology("ClinicalDetails"))
        AtrialFibrillationCheckBox.Checked = CBool(drPathology("AtrialFibrillation"))
        ChronicKidneyDiseaseCheckBox.Checked = CBool(drPathology("ChronicKidneyDisease"))
        CopdCheckBox.Checked = CBool(drPathology("COPD"))
        EnlargedLymphNodesCheckBox.Checked = CBool(drPathology("EnlargedLymphNodes"))
        EssentialHyperTensionCheckBox.Checked = CBool(drPathology("EssentialHyperTension"))
        HeartFailureCheckBox.Checked = CBool(drPathology("HeartFailure"))
        InterstitialLungDiseaseCheckBox.Checked = CBool(drPathology("InterstitialLungDisease"))
        IschaemicHeartDiseaseCheckBox.Checked = CBool(drPathology("IschaemicHeartDisease"))
        LungCancerCheckBox.Checked = CBool(drPathology("LungCancer"))
        ObesityCheckBox.Checked = CBool(drPathology("Obesity"))
        PleuralEffusionCheckBox.Checked = CBool(drPathology("PleuralEffusion"))
        PneumoniaCheckBox.Checked = CBool(drPathology("Pneumonia"))
        RheumatoidArthritisCheckBox.Checked = CBool(drPathology("RheumatoidArthritis"))
        SecondaryCancerCheckBox.Checked = CBool(drPathology("SecondaryCancer"))
        StrokeCheckBox.Checked = CBool(drPathology("Stroke"))
        Type2DiabetesCheckBox.Checked = CBool(drPathology("Type2Diabetes"))
        OtherCoMorbTextBox.Text = CStr(drPathology("OtherComorb"))
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
        StageTypeComboBox.SelectedValue = CInt(drPathology("StageType"))
        If Not IsDBNull(drPathology("StageDate")) Then StageDatePicker.SelectedDate = drPathology("StageDate")
        PerformanceStatusCheckBox.Checked = CBool(drPathology("PerformanceStatus"))
        If Not IsDBNull(drPathology("PerformanceStatusType")) Then PerformanceStatusTypeRadioButtonList.SelectedValue = CInt(drPathology("PerformanceStatusType"))
        If Not IsDBNull(drPathology("DateBronchRequested")) Then DateBronchRequestedDatePicker.SelectedDate = drPathology("DateBronchRequested")
        If Not IsDBNull(drPathology("DateOfReferral")) Then DateOfReferralDatePicker.SelectedDate = drPathology("DateOfReferral")
        LCaSuspectedBySpecialistCheckBox.Checked = CBool(drPathology("LCaSuspectedBySpecialist"))
        CTScanAvailableCheckBox.Checked = CBool(drPathology("CTScanAvailable"))
        If Not IsDBNull(drPathology("DateOfScan")) Then DateOfScanDatePicker.SelectedDate = drPathology("DateOfScan")
        If Not IsDBNull(drPathology("FEV1Result")) Then FEV1ResultNumericTextBox.Value = CDec(drPathology("FEV1Result"))
        If Not IsDBNull(drPathology("FEV1Percentage")) Then FEV1PercentageNumericTextBox.Value = CDec(drPathology("FEV1Percentage"))
        If Not IsDBNull(drPathology("FVCResult")) Then FVCResultNumericTextBox.Value = CDec(drPathology("FVCResult"))
        If Not IsDBNull(drPathology("FVCPercentage")) Then FVCPercentageNumericTextBox.Value = CDec(drPathology("FVCPercentage"))
        If Not IsDBNull(drPathology("WHOPerformanceStatus")) Then WHOPerformanceStatusRadioButtonList.SelectedValue = CInt(drPathology("WHOPerformanceStatus"))
    End Sub

    Private Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Dim da As New OtherData

        Try
            da.SaveBronchoPathology(IInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                    AsthmaCheckBox.Checked,
                                    EmphysemaCheckBox.Checked,
                                    HaemoptysisCheckBox.Checked,
                                    HilarCheckBox.Checked,
                                    InfectionCheckBox.Checked,
                                    ImmunoSuppressedCheckBox.Checked,
                                    LungLobarCheckBox.Checked,
                                    RadiologicalCheckBox.Checked,
                                    SuspectedLcaCheckBox.Checked,
                                    SuspectedSarcoidosisCheckBox.Checked,
                                    SuspectedTBCheckBox.Checked,
                                    ClinicalDetailsTextBox.Text,
                                    AtrialFibrillationCheckBox.Checked,
                                    ChronicKidneyDiseaseCheckBox.Checked,
                                    CopdCheckBox.Checked,
                                    EnlargedLymphNodesCheckBox.Checked,
                                    EssentialHyperTensionCheckBox.Checked,
                                    HeartFailureCheckBox.Checked,
                                    InterstitialLungDiseaseCheckBox.Checked,
                                    IschaemicHeartDiseaseCheckBox.Checked,
                                    LungCancerCheckBox.Checked,
                                    ObesityCheckBox.Checked,
                                    PleuralEffusionCheckBox.Checked,
                                    PneumoniaCheckBox.Checked,
                                    RheumatoidArthritisCheckBox.Checked,
                                    SecondaryCancerCheckBox.Checked,
                                    StrokeCheckBox.Checked,
                                    Type2DiabetesCheckBox.Checked,
                                    OtherCoMorbTextBox.Text,
                                    StagingInvestigationsCheckBox.Checked,
                                    ClinicalGroundsCheckBox.Checked,
                                    ImagingOfThoraxCheckBox.Checked,
                                    MediastinalSamplingCheckBox.Checked,
                                    MetastasesCheckBox.Checked,
                                    PleuralHistologyCheckBox.Checked,
                                    BronchoscopyCheckBox.Checked,
                                    StageCheckBox.Checked,
                                    Utilities.GetComboBoxValue(StageTComboBox),
                                    Utilities.GetComboBoxValue(StageNComboBox),
                                    Utilities.GetComboBoxValue(StageMComboBox),
                                    Utilities.GetComboBoxValue(StageTypeComboBox),
                                    StageDatePicker.SelectedDate,
                                    PerformanceStatusCheckBox.Checked,
                                    Utilities.GetRadioValue(PerformanceStatusTypeRadioButtonList),
                                    DateBronchRequestedDatePicker.SelectedDate,
                                    DateOfReferralDatePicker.SelectedDate,
                                    LCaSuspectedBySpecialistCheckBox.Checked,
                                    CTScanAvailableCheckBox.Checked,
                                    DateOfScanDatePicker.SelectedDate,
                                    Utilities.GetNumericTextBoxValue(FEV1ResultNumericTextBox, True),
                                    Utilities.GetNumericTextBoxValue(FEV1PercentageNumericTextBox, True),
                                    Utilities.GetNumericTextBoxValue(FVCResultNumericTextBox, True),
                                    Utilities.GetNumericTextBoxValue(FVCPercentageNumericTextBox, True),
                                    Utilities.GetRadioValue(WHOPerformanceStatusRadioButtonList))

            ExitForm()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Bronchoscopy Pathology.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Function GetDecimalValue(textbox As RadTextBox) As Nullable(Of Decimal)
        Dim result As Nullable(Of Decimal)
        If textbox.Text <> "" Then
            If IsNumeric(textbox.Text) Then
                result = CDec(textbox.Text)
            End If
        End If
        Return result
    End Function
End Class