Imports Telerik.Web.UI
Imports ERS.Data
Partial Class Products_Gastro_OtherData_OGD_QA
    Inherits PageBase

    Private procedureType As Integer


    Protected Property thisIsA_NewRecord() As Boolean
        Get
            Return CBool(ViewState("thisIsA_NewRecord"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("thisIsA_NewRecord") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        procedureType = Convert.ToInt32(Session(Constants.SESSION_PROCEDURE_TYPE))

        If Not Page.IsPostBack Then
            'SaveButton.Text = IIf(Session("AdvancedMode") = True, "Save Record", "Save & Close")

            Dim da As New OtherData
            Dim UpperGIQA_Record As ERS.Data.ERS_UpperGIQA = da.UpperGIQA_Find(Convert.ToInt32(Session(Constants.SESSION_PROCEDURE_ID)))

            If UpperGIQA_Record IsNot Nothing Then
                PopulateData(UpperGIQA_Record)
                PopulateDefaultComplicationsTechnicalFailure()
                thisIsA_NewRecord = False
            Else
                PopulateDefaultManagement()
                thisIsA_NewRecord = True
            End If
            Dim op As New Options
            SedationOptionsRequiredFieldValidator.Enabled = op.CheckRequiredField("QA", "Patient Sedation")
            PatDiscomfortRequiredFieldValidator.Enabled = op.CheckRequiredField("QA", "Patient Discomfort")

            If procedureType = UnisoftERS.ProcedureType.Bronchoscopy Or procedureType = UnisoftERS.ProcedureType.EBUS Or procedureType = UnisoftERS.ProcedureType.Thoracoscopy Then
                RadTabStrip1.FindTabByValue(2).Visible = False
                RadTabStrip1.FindTabByValue(3).Visible = False
                RadTabStrip1.FindTabByValue(4).Visible = True

            Else
                RadTabStrip1.FindTabByValue(2).Visible = True
                RadTabStrip1.FindTabByValue(3).Visible = True
                RadTabStrip1.FindTabByValue(4).Visible = False
            End If

            '#Set focus on the required tab page
            If Not String.IsNullOrEmpty(Request.QueryString("tab")) Then
                Dim tab As String = Request.QueryString("tab")
                If Not RadTabStrip1.FindTabByValue(tab) Is Nothing AndAlso RadTabStrip1.FindTabByValue(tab).Visible Then
                    RadTabStrip1.Tabs(tab).Selected = True
                    RadMultiPage1.SelectedIndex = tab
                End If
            End If

        End If

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, RadTabStrip1, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, RadNotification1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(CancelButton, RadTabStrip1, RadAjaxLoadingPanel1)
    End Sub

    Private Sub PopulateData(qa As ERS_UpperGIQA)
        NoNotesCheckBox.Checked = qa.NoNotes
        ReferralLetterCheckBox.Checked = qa.ReferralLetter

        ' Management Section
        ManagementNoneCheckBox.Checked = qa.ManagementNone
        PulseOximetryCheckBox.Checked = qa.PulseOximetry
        IVAccessCheckBox.Checked = qa.IVAccess
        IVAntibioticsCheckBox.Checked = qa.IVAntibiotics
        OxygenationCheckBox.Checked = qa.Oxygenation
        OxygenationMethodRadioButtonList.SelectedValue = qa.OxygenationMethod
        'If Not IsDBNull(drQa("OxygenationFlowRate")) Then OxygenationFlowRateTextBox.Text = CStr(drQa("OxygenationFlowRate"))
        If qa.OxygenationFlowRate.HasValue Then OxygenationFlowRateTextBox.Text = qa.OxygenationFlowRate

        ContinuousECGCheckBox.Checked = qa.ContinuousECG
        BPCheckBox.Checked = qa.BP
        If qa.BPSystolic.HasValue Then BPSysTextBox.Text = qa.BPSystolic
        If qa.BPDiastolic.HasValue Then BPDiaTextBox.Text = qa.BPDiastolic
        ManagementOtherCheckBox.Checked = qa.ManagementOther
        ManagementOtherTextBox.Text = qa.ManagementOtherText

        ' Patient Sedation/Comfort Section
        PatSedationRadioButton.SelectedValue = qa.PatSedation
        'Select Case CInt(drQa("PatSedation"))
        '    Case 1
        '        PatSedationNotRecordedRadioButton.Checked = True
        '    Case 2
        '        PatSedationAwakeRadioButton.Checked = True
        '    Case 3
        '        PatSedationDrowsyRadioButton.Checked = True
        '    Case 4
        '        PatSedationAsleepRadioButton.Checked = True
        'End Select
        If qa.PatSedation = 4 Then
            PatSedationAsleepResponseStateComboBox.Style("display") = "normal"
            PatSedationAsleepResponseStateComboBox.SelectedValue = qa.PatSedationAsleepResponseState
        Else
            PatSedationAsleepResponseStateComboBox.Style("display") = "none"
        End If

        PatDiscomfortNurseRadioButtonList.SelectedValue = qa.PatDiscomfortNurse
        PatDiscomfortEndoRadioButtonList.SelectedValue = qa.PatDiscomfortEndo

        ' Complications Section
        DeathCheckBox.Checked = qa.Death
        CardiacArrythmiaCheckBox.Checked = qa.CardiacArrythmia
        Dim whoRecorded = DataAdapter.GetWHOSurgicalSafetyCheckList(Convert.ToInt32(Session(Constants.SESSION_PROCEDURE_ID)))

        If whoRecorded IsNot Nothing Then
            WHOChecklistRadioButtonList.SelectedValue = whoRecorded
        End If

        If procedureType = UnisoftERS.ProcedureType.Bronchoscopy Or procedureType = UnisoftERS.ProcedureType.EBUS Or procedureType = UnisoftERS.ProcedureType.Thoracoscopy Then
            BleedingCheckBox.Checked = qa.Bleeding
            BleedingSeverityComboBox.Text = qa.BleedingSeverity
            BleedingAdrenalineUsedCheckbox.Checked = qa.BleedingAdrenalineUsed
            If qa.BleedingAdrenalineAmount.HasValue Then BleedingAdrenalineAmountNumericTextBox.Value = qa.BleedingAdrenalineAmount.Value
            BleedingColdSalineUsedCheckbox.Checked = qa.BleedingColdSalineUsed
            BleedingBlockingDeviceUsedCheckbox.Checked = qa.BleedingBlockingDeviceUsed
            PneumothoraxCheckBox.Checked = qa.Pneumothorax
            PneumothoraxAspirChestDrainCheckBox.Checked = qa.PneumothoraxAspirChestDrain
            HospitalisationCheckBox.Checked = qa.Hospitalisation
            MyocardInfarctionCheckbox.Checked = qa.MyocardInfarction
            OversedationCheckbox.Checked = qa.Oversedation
            AdmissionToIcuCheckBox.Checked = qa.AdmissionToICU
            ComplicationsBronchoscopyOtherCheckBox.Checked = qa.ComplicationsOther
            ComplicationsBronchoscopyOtherTextBox.Text = qa.ComplicationsOtherText
            AbandonedOtherCheckbox.Checked = qa.AbandonedOther
            AbandonedOtherTextBox.Text = qa.AbandonedOtherText
            '#####################
            'add abandoned procedure here
            '#####################
        Else
            ComplicationsNoneCheckBox.Checked = qa.ComplicationsNone
            PoorlyToleratedCheckBox.Checked = qa.PoorlyTolerated
            PatientDiscomfortCheckBox.Checked = qa.PatientDiscomfort
            PatientDistressCheckBox.Checked = qa.PatientDistress
            InjuryToMouthCheckBox.Checked = qa.InjuryToMouth
            FailedIntubationCheckBox.Checked = qa.FailedIntubation
            DifficultIntubationCheckBox.Checked = qa.DifficultIntubation
            DamageToScopeCheckBox.Checked = qa.DamageToScope
            LoadDamageTypeSelection(qa.DamageToScopeType)
            GastricContentsAspirationCheckBox.Checked = qa.GastricContentsAspiration
            ShockHypotensionCheckBox.Checked = qa.ShockHypotension
            HaemorrhageCheckBox.Checked = qa.Haemorrhage
            SignificantHaemorrhageCheckBox.Checked = qa.SignificantHaemorrhage
            HypoxiaCheckBox.Checked = qa.Hypoxia
            RespiratoryDepressionCheckBox.Checked = qa.RespiratoryDepression
            RespiratoryArrestCheckBox.Checked = qa.RespiratoryArrest
            CardiacArrestCheckBox.Checked = qa.CardiacArrest
            TechnicalFailureTextBox.Text = Server.HtmlDecode(qa.TechnicalFailure)
            PerforationCheckBox.Checked = qa.Perforation
            PerforationTextBox.Text = qa.PerforationText
            ComplicationsOtherCheckBox.Checked = qa.ComplicationsOther
            ComplicationsOtherTextBox.Text = qa.ComplicationsOtherText
        End If

        '### Adverse Events NED Fields
        chkNoAdverseEvents.Checked = qa.AdverseEventsNone
        chkConsentSignedInRoom.Checked = qa.ConsentSignedInRoom
        chkUnplannedAdmission.Checked = qa.UnplannedAdmission
        chkO2Desaturation.Checked = qa.O2Desaturation
        chkWithdrawalOfConsent.Checked = qa.WithdrawalOfConsent
        chkUnsupervisedTrainee.Checked = qa.UnsupervisedTrainee
        chkVentilation.Checked = qa.Ventilation

        '### Complications -> Technical Filure -> Some NED Fields! ONLY for ERCP
        If procedureType = UnisoftERS.ProcedureType.ERCP Then
            FailureComplicationsDiv.Visible = True
            chkAllergyToContrast.Checked = qa.AllergyToMedium
            chkContrast.Checked = qa.ContrastExtravasation
            chkArcinarisation.Checked = qa.Arcinarisation
            chkFailedERCP.Checked = qa.FailedERCP
            chkFailedCannulation.Checked = qa.FailedCannulation
            chkFailedStentInsertion.Checked = qa.FailedStentInsertion
            chkPancreatitis.Checked = qa.Pancreatitis
        End If
    End Sub

    Protected Sub PopulateDefaultManagement()
        If CBool(Session(Constants.SESSION_QA_MANAGEMENT)) Then
            ManagementNoneCheckBox.Checked = Session(Constants.SESSION_QA_MANAGEMENT_NONE)
            PulseOximetryCheckBox.Checked = Session(Constants.SESSION_QA_MANAGEMENT_PULSE_OXIMETRY)
            IVAccessCheckBox.Checked = Session(Constants.SESSION_QA_MANAGEMENT_IV_ACCESS)
            IVAntibioticsCheckBox.Checked = Session(Constants.SESSION_QA_MANAGEMENT_IV_ANTIBIOTICS)
            OxygenationCheckBox.Checked = Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION)
            OxygenationMethodRadioButtonList.SelectedValue = Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_METHOD)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_FLOW_RATE)) Then OxygenationFlowRateTextBox.Text = Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_FLOW_RATE)
            ContinuousECGCheckBox.Checked = Session(Constants.SESSION_QA_MANAGEMENT_CONTINOUS_ECG)
            BPCheckBox.Checked = Session(Constants.SESSION_QA_MANAGEMENT_BP)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_QA_MANAGEMENT_SYSTOLIC_BP)) Then BPSysTextBox.Text = Session(Constants.SESSION_QA_MANAGEMENT_SYSTOLIC_BP)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_QA_MANAGEMENT_DIASTOLIC_BP)) Then BPDiaTextBox.Text = Session(Constants.SESSION_QA_MANAGEMENT_DIASTOLIC_BP)
            ManagementOtherCheckBox.Checked = Session(Constants.SESSION_QA_MANAGEMENT_OTHER)
            ManagementOtherTextBox.Text = Session(Constants.SESSION_QA_MANAGEMENT_OTHER_TEXT)
        End If
    End Sub

    Protected Sub PopulateDefaultComplicationsTechnicalFailure()
        '### Complications -> Technical Failure -> Some NED Fields! ONLY for ERCP
        If procedureType = UnisoftERS.ProcedureType.ERCP Then
            FailureComplicationsDiv.Visible = True
            chkAllergyToContrast.Checked = False
            chkContrast.Checked = False
            chkArcinarisation.Checked = False
            chkFailedERCP.Checked = False
            chkFailedCannulation.Checked = False
            chkFailedStentInsertion.Checked = False
            chkPancreatitis.Checked = False
        End If
    End Sub

    Protected Sub SaveDefault()
        Dim da As New OtherData
        Dim patientSedation As Integer
        Dim oxygenationFlowRate As Nullable(Of Decimal) = Nothing
        Dim systolicBP As Nullable(Of Decimal) = Nothing
        Dim diastolicBP As Nullable(Of Decimal) = Nothing
        patientSedation = IIf(PatSedationRadioButton.SelectedValue = "", 0, PatSedationRadioButton.SelectedValue)
        'If PatSedationNotRecordedRadioButton.Checked Then
        '    patientSedation = 1
        'ElseIf PatSedationAwakeRadioButton.Checked Then
        '    patientSedation = 2
        'ElseIf PatSedationDrowsyRadioButton.Checked Then
        '    patientSedation = 3
        'ElseIf PatSedationAsleepRadioButton.Checked Then
        '    patientSedation = 4
        'End If

        If OxygenationFlowRateTextBox.Text <> "" Then oxygenationFlowRate = CDec(OxygenationFlowRateTextBox.Text)
        If BPSysTextBox.Text <> "" Then systolicBP = CDec(BPSysTextBox.Text)
        If BPDiaTextBox.Text <> "" Then diastolicBP = CDec(BPDiaTextBox.Text)

        Try
            Session(Constants.SESSION_QA_MANAGEMENT) = True
            Session(Constants.SESSION_QA_MANAGEMENT_NONE) = ManagementNoneCheckBox.Checked
            Session(Constants.SESSION_QA_MANAGEMENT_PULSE_OXIMETRY) = PulseOximetryCheckBox.Checked
            Session(Constants.SESSION_QA_MANAGEMENT_IV_ACCESS) = IVAccessCheckBox.Checked
            Session(Constants.SESSION_QA_MANAGEMENT_IV_ANTIBIOTICS) = IVAntibioticsCheckBox.Checked
            Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION) = OxygenationCheckBox.Checked
            Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_METHOD) = Utilities.GetRadioValue(OxygenationMethodRadioButtonList)
            Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_FLOW_RATE) = oxygenationFlowRate
            Session(Constants.SESSION_QA_MANAGEMENT_CONTINOUS_ECG) = ContinuousECGCheckBox.Checked
            Session(Constants.SESSION_QA_MANAGEMENT_BP) = BPCheckBox.Checked
            Session(Constants.SESSION_QA_MANAGEMENT_SYSTOLIC_BP) = systolicBP
            Session(Constants.SESSION_QA_MANAGEMENT_DIASTOLIC_BP) = diastolicBP
            Session(Constants.SESSION_QA_MANAGEMENT_OTHER) = ManagementOtherCheckBox.Checked
            Session(Constants.SESSION_QA_MANAGEMENT_OTHER_TEXT) = ManagementOtherTextBox.Text

            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
            Me.Master.SetButtonStyle()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving Upper GI QA.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub SaveRecord(isSaveAndClose As Boolean)
        Dim da As New OtherData
        Dim UpperGIQA_Record As ERS.Data.ERS_UpperGIQA

        '## If this is a new Record!  
        If thisIsA_NewRecord Then
            UpperGIQA_Record = New ERS_UpperGIQA()
        Else
            UpperGIQA_Record = da.UpperGIQA_Find(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        End If

        Try
            '## Need to Fill the Class object and then Pass to EntityFramework to Save it..!!
            UpperGIQA_Record_Fill(UpperGIQA_Record)

            '### Insert/Update the Record
            da.UpperGI_Save(UpperGIQA_Record, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

            If WHOChecklistRadioButtonList.SelectedIndex > -1 Then
                Dim ds As New DataAccess
                ds.UpdateWHOSurgicalSafetyCheckList(CInt(Session(Constants.SESSION_PROCEDURE_ID)), WHOChecklistRadioButtonList.SelectedValue)
            End If
            If isSaveAndClose Then
                ExitForm()
                Me.Master.SetButtonStyle()
            End If

            If CBool(Session("AdvancedMode")) Then
                If isSaveAndClose Then
                    Utilities.SetNotificationStyle(RadNotification1)
                    RadNotification1.Show()
                End If
                ' Refresh the left side Summary panel that's on the master page
                Dim c As Control = FindAControl(Me.Master.Controls, "SummaryListView")
                If c IsNot Nothing Then
                    Dim lvSummary As ListView = DirectCast(c, ListView)
                    lvSummary.DataBind()
                End If
            Else
                If isSaveAndClose Then
                    Response.Redirect("~/Products/PatientProcedure.aspx", False)
                End If
            End If


        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving Upper GI QA.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub


    Protected Sub SaveOnly_Click(sender As Object, e As EventArgs) Handles SaveOnly.Click
        SaveRecord(False)
    End Sub


    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        ExitForm()
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

    Private Sub UpperGIQA_Record_Fill(UpperGIQA_Record As ERS.Data.ERS_UpperGIQA)
        Dim patientSedation As Integer
        Dim oxygenationFlowRate As Nullable(Of Decimal) = Nothing
        Dim systolicBP As Nullable(Of Decimal) = Nothing
        Dim diastolicBP As Nullable(Of Decimal) = Nothing
        If PatSedationRadioButton.SelectedValue <> "" Then patientSedation = PatSedationRadioButton.SelectedValue

        If OxygenationFlowRateTextBox.Text <> "" Then oxygenationFlowRate = CDec(OxygenationFlowRateTextBox.Text)
        If BPSysTextBox.Text <> "" Then systolicBP = CDec(BPSysTextBox.Text)
        If BPDiaTextBox.Text <> "" Then diastolicBP = CDec(BPDiaTextBox.Text)

        With UpperGIQA_Record
            .NoNotes = NoNotesCheckBox.Checked
            .ReferralLetter = ReferralLetterCheckBox.Checked
            .ManagementNone = ManagementNoneCheckBox.Checked
            .PulseOximetry = PulseOximetryCheckBox.Checked
            .IVAccess = IVAccessCheckBox.Checked
            .IVAntibiotics = IVAntibioticsCheckBox.Checked
            .Oxygenation = OxygenationCheckBox.Checked
            .OxygenationMethod = Utilities.GetRadioValue(OxygenationMethodRadioButtonList)
            .OxygenationFlowRate = oxygenationFlowRate
            .ContinuousECG = ContinuousECGCheckBox.Checked
            .BP = BPCheckBox.Checked
            .BPSystolic = systolicBP
            .BPDiastolic = diastolicBP
            .ManagementOther = ManagementOtherCheckBox.Checked
            .ManagementOtherText = ManagementOtherTextBox.Text
            .PatSedation = patientSedation
            .PatSedationAsleepResponseState = PatSedationAsleepResponseStateComboBox.SelectedValue
            .PatDiscomfortNurse = Utilities.GetRadioValue(PatDiscomfortNurseRadioButtonList)
            .PatDiscomfortEndo = Utilities.GetRadioValue(PatDiscomfortEndoRadioButtonList)
            .CardiacArrythmia = CardiacArrythmiaCheckBox.Checked
            .Death = DeathCheckBox.Checked

            If procedureType = UnisoftERS.ProcedureType.Bronchoscopy Or procedureType = UnisoftERS.ProcedureType.EBUS Or procedureType = UnisoftERS.ProcedureType.Thoracoscopy Then
                .ComplicationsNone = ComplicationsBronchoscopyNoneCheckBox.Checked
                .Bleeding = BleedingCheckBox.Checked
                .BleedingSeverity = Utilities.GetComboBoxValue(BleedingSeverityComboBox)
                .BleedingAdrenalineUsed = BleedingAdrenalineUsedCheckbox.Checked
                .BleedingAdrenalineAmount = Utilities.GetNumericTextBoxValue(BleedingAdrenalineAmountNumericTextBox, True)
                .BleedingColdSalineUsed = BleedingColdSalineUsedCheckbox.Checked
                .BleedingBlockingDeviceUsed = BleedingBlockingDeviceUsedCheckbox.Checked
                .Pneumothorax = PneumothoraxCheckBox.Checked
                .PneumothoraxAspirChestDrain = PneumothoraxAspirChestDrainCheckBox.Checked
                .Hospitalisation = HospitalisationCheckBox.Checked
                .MyocardInfarction = MyocardInfarctionCheckbox.Checked
                .Oversedation = OversedationCheckbox.Checked
                .AdmissionToICU = AdmissionToIcuCheckBox.Checked
                .ComplicationsOther = ComplicationsBronchoscopyOtherCheckBox.Checked
                .ComplicationsOtherText = ComplicationsBronchoscopyOtherTextBox.Text
                .AbandonedOther = AbandonedOtherCheckbox.Checked
                .AbandonedOtherText = AbandonedOtherTextBox.Text
            Else
                .ComplicationsNone = ComplicationsNoneCheckBox.Checked
                .PoorlyTolerated = PoorlyToleratedCheckBox.Checked
                .PatientDiscomfort = PatientDiscomfortCheckBox.Checked
                .PatientDistress = PatientDistressCheckBox.Checked
                .InjuryToMouth = InjuryToMouthCheckBox.Checked
                .FailedIntubation = FailedIntubationCheckBox.Checked
                .DifficultIntubation = DifficultIntubationCheckBox.Checked
                .DamageToScope = DamageToScopeCheckBox.Checked
                .DamageToScopeType = GetScopeDamageType() '--###
                .GastricContentsAspiration = GastricContentsAspirationCheckBox.Checked
                .ShockHypotension = ShockHypotensionCheckBox.Checked
                .Haemorrhage = HaemorrhageCheckBox.Checked
                .SignificantHaemorrhage = SignificantHaemorrhageCheckBox.Checked
                .Hypoxia = HypoxiaCheckBox.Checked
                .RespiratoryDepression = RespiratoryDepressionCheckBox.Checked
                .RespiratoryArrest = RespiratoryArrestCheckBox.Checked
                .CardiacArrest = CardiacArrestCheckBox.Checked
                .TechnicalFailure = Server.HtmlEncode(TechnicalFailureTextBox.Text)
                .Perforation = PerforationCheckBox.Checked
                .PerforationText = IIf(PerforationCheckBox.Checked, PerforationTextBox.Text, "")
                .ComplicationsOther = ComplicationsOtherCheckBox.Checked
                .ComplicationsOtherText = IIf(ComplicationsOtherCheckBox.Checked, ComplicationsOtherTextBox.Text, "")
            End If

            '### Adverse Events NED Fields
            .AdverseEventsNone = chkNoAdverseEvents.Checked
            .ConsentSignedInRoom = chkConsentSignedInRoom.Checked
            .UnplannedAdmission = chkUnplannedAdmission.Checked
            .O2Desaturation = chkO2Desaturation.Checked
            .WithdrawalOfConsent = chkWithdrawalOfConsent.Checked
            .UnsupervisedTrainee = chkUnsupervisedTrainee.Checked
            .Ventilation = chkVentilation.Checked

            '### Complications -> Technical Filure -> NED Fields! ERCP ONLY
            If procedureType = UnisoftERS.ProcedureType.ERCP Then
                .AllergyToMedium = chkAllergyToContrast.Checked
                .ContrastExtravasation = chkContrast.Checked
                .Arcinarisation = chkArcinarisation.Checked
                .FailedERCP = chkFailedERCP.Checked
                .FailedCannulation = chkFailedCannulation.Checked
                .FailedStentInsertion = chkFailedStentInsertion.Checked
                .Pancreatitis = chkPancreatitis.Checked
            End If
        End With
    End Sub

    ''' <summary>
    ''' Scope Damage Type- holds a single value for the all possible selection. If the User selects only First or Second, then Value will be 1 or 2 respectively. 
    ''' When all the options are seletected then the value will be 9- means ALL Checked...
    ''' </summary>
    ''' <returns>Numeric Value- 9 means ALL</returns>
    ''' <remarks>Shawkat; 2017-12-07</remarks>
    Function GetScopeDamageType() As Integer


        If MechanicalCheckBox.Checked AndAlso PatientInitiatedCheckBox.Checked Then
            Return 9
        ElseIf MechanicalCheckBox.Checked Then
            Return 1
        ElseIf PatientInitiatedCheckBox.Checked Then
            Return 2
        End If

        'Dim collection = DamageToScopeTypeComboBox.CheckedItems
        'If DamageToScopeTypeComboBox.CheckedItems.Count = DamageToScopeTypeComboBox.Items.Count Then
        '    Return 9
        'Else
        '    Return Convert.ToInt16(DamageToScopeTypeComboBox.SelectedItem.Value)
        'End If

    End Function

    ''' <summary>
    ''' This will make the respective checkbox selected
    ''' when 9- then Select All, otherwise only one value gets selected
    ''' </summary>
    ''' <param name="damageTypeValue">Damage Type Number</param>
    ''' <remarks>Shawkat; 2017-12-07</remarks>
    Private Sub LoadDamageTypeSelection(ByVal damageTypeValue As Integer)

        Select Case damageTypeValue
            Case 1
                MechanicalCheckBox.Checked = True
            Case 2
                PatientInitiatedCheckBox.Checked = True
            Case 9
                MechanicalCheckBox.Checked = True
                PatientInitiatedCheckBox.Checked = True
        End Select

        'If damageTypeValue = 9 Then  '### 9 Means 'All Selected/Checked'
        '    For Each damageType As RadComboBoxItem In DamageToScopeTypeComboBox.Items
        '        damageType.Checked = True
        '    Next
        'Else
        '    DamageToScopeTypeComboBox.Items(damageTypeValue).Checked = True
        'End If
    End Sub

End Class