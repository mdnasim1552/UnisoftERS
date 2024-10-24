Imports Telerik.Web.UI

Partial Class Products_Common_ExtentLim
    Inherits PageBase

    Dim bRetrogradeProcedure As Boolean = False
    Dim bTrainer As Boolean = False

    Protected Property ValidatorString() As String
        Get
            If ViewState("ValidatorString") IsNot Nothing Then
                Return CStr(ViewState("ValidatorString"))
            End If
            Return ""
        End Get
        Set(ByVal value As String)
            ViewState("ValidatorString") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        bRetrogradeProcedure = IIf(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Retrograde, True, False)

        If Not IsPostBack Then
            If bRetrogradeProcedure Then
                LoadFormControlsRetro()
            Else
                Dim da As New DataAccess
                Dim iResectedColonNo As Integer = da.GetResectedColonDetails(CInt(Session(Constants.SESSION_PROCEDURE_ID)), 0, bRetrogradeProcedure)
                If iResectedColonNo > 0 Then
                    trResection.Visible = True
                    trResectionDetails.Visible = True
                End If

                RadTabStrip1.Tabs(1).Visible = False
                Dim od As New OtherData
                Dim dtTr As DataTable = od.GetTrainerTraineeEndo(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                If dtTr.Rows.Count > 0 Then
                    Dim drTr As DataRow = dtTr.Rows(0)

                    If Not IsDBNull(drTr("TraineeEndoscopist")) AndAlso drTr("TraineeEndoscopist") <> "" Then
                        RadTabStrip1.Tabs(1).Visible = True
                        RadTabStrip1.Tabs(0).Text = CStr(drTr("TraineeEndoscopist")) '"TrainEE: " &
                        bTrainer = True
                    End If

                    If Not IsDBNull(drTr("TrainerEndoscopist")) AndAlso drTr("TrainerEndoscopist") <> "" Then
                        RadTabStrip1.Tabs(1).Text = CStr(drTr("TrainerEndoscopist")) '"TrainER: " &
                    End If

                    If Not RadTabStrip1.Tabs(1).Visible Then RadTabStrip1.Style.Add("display", "none")
                    If iResectedColonNo > 0 Then
                        trResection_NED.Visible = True
                        trResectionDetails_NED.Visible = True
                    End If
                    'Utilities.LoadDropdown(InsertionComfirmedRadComboBox_NED, DataAdapter.GetInsertionComfirmedBy, "ListItemText", "ListItemNo", Nothing)
                    'Utilities.LoadDropdown(InsertionLimitedRadComboBox_NED, DataAdapter.GetInsertionLimitedBy, "ListItemText", "ListItemNo", Nothing)
                    'Utilities.LoadDropdown(DifficultiesEncounteredRadComboBox_NED, DataAdapter.GetDifficultyEncountered, "ListItemText", "ListItemNo", Nothing)

                    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                        {InsertionComfirmedRadComboBox_NED, "Colon_Extent_Insertion_Comfirmed_By"},
                        {InsertionLimitedRadComboBox_NED, "Colon_Extent_Insertion_Limited_By"},
                        {DifficultiesEncounteredRadComboBox_NED, "Colon_Extent_Difficulty_Encountered"}
                    })
                End If

                'Utilities.LoadDropdown(InsertionComfirmedRadComboBox, DataAdapter.GetInsertionComfirmedBy, "ListItemText", "ListItemNo", Nothing)
                'Utilities.LoadDropdown(InsertionLimitedRadComboBox, DataAdapter.GetInsertionLimitedBy, "ListItemText", "ListItemNo", Nothing)
                'Utilities.LoadDropdown(DifficultiesEncounteredRadComboBox, DataAdapter.GetDifficultyEncountered, "ListItemText", "ListItemNo", Nothing)

                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                    {InsertionComfirmedRadComboBox, "Colon_Extent_Insertion_Comfirmed_By"},
                    {InsertionLimitedRadComboBox, "Colon_Extent_Insertion_Limited_By"},
                    {DifficultiesEncounteredRadComboBox, "Colon_Extent_Difficulty_Encountered"}
                })

                LoadFormControls()
            End If
        End If

        If bRetrogradeProcedure Then
            ColonDiv.Visible = False
            RetrogradeDiv.Visible = True
        Else
            ColonDiv.Visible = True
            RetrogradeDiv.Visible = False

            ValidatorString = validator()
            cmdAccept.OnClientClicking = "Validate"
        End If

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdAccept, tableVia, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdAccept, RadNotification1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdCancel, tableVia, RadAjaxLoadingPanel1)
    End Sub

    Function validator() As String
        Dim op As New Options

        'Dim dtSys As DataTable = op.GetSystemSettings()
        'If dtSys.Rows.Count > 0 AndAlso dtSys.Rows(0)("NEDEnabled") Then
        '    InsertionSpecificCheckBox.Enabled = True
        '    NotRecordedCheckBox.Enabled = True
        'Else
        '    InsertionSpecificCheckBox.Enabled = False
        '    NotRecordedCheckBox.Enabled = False
        'End If

        Dim s As New Dictionary(Of String, Boolean)
        s.Add("validateRectal", op.CheckRequiredField("ExtentLim", "Rectal exam (PR)"))
        s.Add("validateRetroflexion", op.CheckRequiredField("ExtentLim", "Retroflexion in rectum"))
        s.Add("validateVia", op.CheckRequiredField("ExtentLim", "Insertion via"))
        s.Add("validateInsertto", op.CheckRequiredField("ExtentLim", "Insertion to"))
        s.Add("validateLimitedby", op.CheckRequiredField("ExtentLim", "Insertion limited by"))
        Dim serialize As New System.Web.Script.Serialization.JavaScriptSerializer()
        Return serialize.Serialize(s)
    End Function
    Protected Sub Page_PreLoad(sender As Object, e As System.EventArgs) Handles Me.PreLoad
        'Call uniAdaptor.IsAuthenticated()
    End Sub

    Protected Sub LoadFormControlsRetro()
        Dim ds As New OtherData
        Dim dtDi As DataTable = ds.GetColonExtentLimitingFactor(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        If dtDi.Rows.Count > 0 Then
            Dim rRow As DataRow = dtDi.Rows(0)
            Select Case CInt(rRow("InsertionVia"))
                Case 1
                    InsertionViaDuoRadioButton.Checked = True
                Case 2
                    InsertionViaColRadioButton.Checked = True
            End Select

            DistanceFromICVNumericTextBox.Text = rRow("ICVDistance")
            NoOfLoopsNumericTextBox.Text = rRow("NumberLoops")
        End If
    End Sub
    Protected Sub LoadFormControls()
        Dim ds As New OtherData
        Dim dtDi As DataTable = ds.GetColonExtentLimitingFactor(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        If dtDi.Rows.Count > 0 Then
            Dim rRow As DataRow = dtDi.Rows(0)
            InsertionLimitedRadComboBox.Enabled = True
            InsertionSpecificDiv.Attributes.Add("style", "display:none")
            If CBool(rRow("RectalExam")) Then
                RectalExamDoneRadioButton.Checked = True
            Else
                RectalExamNotDoneRadioButton.Checked = True
            End If
            If CBool(rRow("Retroflexion")) Then
                RetroflexionDoneRadioButton.Checked = True
            Else
                RetroflexionNotDoneRadioButton.Checked = True
            End If
            If Not String.IsNullOrWhiteSpace(rRow("InsertionVia").ToString()) Then
                Select Case CInt(rRow("InsertionVia"))
                    Case 1
                        InsertionAnusRadioButton.Checked = True
                    Case 2
                        InsertionColostomyRadioButton.Checked = True
                    Case 3
                        InsertionLoopColostomyRadioButton.Checked = True
                    Case 4
                        InsertionCaecostomyRadioButton.Checked = True
                    Case 5
                        InsertionIleostomyRadioButton.Checked = True
                End Select
            End If
            If Not String.IsNullOrWhiteSpace(rRow("InsertionTo").ToString()) Then
                Select Case CInt(rRow("InsertionTo"))
                    Case 1
                        InsertionSpecificCheckBox.Checked = True
                        InsertionSpecificCheckRadNumericTextBox.Text = rRow("SpecificDistanceCm")
                        InsertionSpecificDiv.Attributes.Add("style", "display:inline-block")
                    Case 2
                        NotRecordedCheckBox.Checked = True
                    'InsertionConfirmedTrID.Attributes.Add("style", "display:none")
                    'InsertionLimitedTrID.Attributes.Add("style", "display:none")
                    Case 3
                        ProximalSigmoidCheckBox.Checked = True
                    Case 4
                        MidTransverseCheckBox.Checked = True
                    Case 5
                        CaecumCheckBox.Checked = True
                        'InsertionLimitedRadComboBox.Enabled = False
                        initbox()
                    Case 6
                        CompleteCheckBox.Checked = True
                    Case 7
                        DistalDescendingCheckBox.Checked = True
                    Case 8
                        ProximalTransverseCheckBox.Checked = True
                    Case 9
                        TerminalIleumCheckBox.Checked = True
                        'InsertionLimitedRadComboBox.Enabled = False
                        initbox()
                    Case 10
                        RectumCheckBox.Checked = True
                    Case 11
                        ProximalDescendingCheckBox.Checked = True
                    Case 12
                        HepaticFlexureCheckBox.Checked = True
                    Case 13
                        NeoTerminalCheckBox.Checked = True
                        'InsertionLimitedRadComboBox.Enabled = False
                        initbox()
                    Case 14
                        RectoSigmoidCheckBox.Checked = True
                    Case 15
                        SplenicFlexureCheckBox.Checked = True
                    Case 16
                        DistalAscendingCheckBox.Checked = True
                    Case 17
                        DistalSigmoidCheckBox.Checked = True
                    Case 18
                        DistalTransverseCheckBox.Checked = True
                    Case 19
                        ProximalAscendingCheckBox.Checked = True
                    Case 30
                        AnastomosisCheckBox.Checked = True
                    Case 31
                        IleoColonCheckBox.Checked = True
                    Case 32
                        PouchCheckBox.Checked = True
                End Select
            End If

            InsertionComfirmedRadComboBox.SelectedValue = rRow("InsertionConfirmedBy").ToString()
            InsertionLimitedRadComboBox.SelectedValue = rRow("InsertionLimitedBy").ToString()
            DifficultiesEncounteredRadComboBox.SelectedValue = rRow("DifficultiesEncountered").ToString()

            IleocecalValveCheckBox.Checked = CBool(rRow("IleocecalValve"))
            TransIlluminationCheckBox.Checked = CBool(rRow("TransIllumination"))
            IlealIntubationCheckBox.Checked = CBool(rRow("IlealIntubation"))
            AppendicularOrificeCheckBox.Checked = CBool(rRow("AppendicularOrifice"))
            TriRadiateCheckBox.Checked = CBool(rRow("TriRadiateCaecalFold"))
            DigitalPressureCheckBox.Checked = CBool(rRow("DigitalPressure"))

            ConfidenceDegreeCheckBox.Checked = CBool(rRow("DegreeOfConfidence"))
            PositivelyRadioButton.Checked = CBool(rRow("Positively"))
            WithReasonableConfidenceRadioButton.Checked = CBool(rRow("WithReasonableConfidence"))
            AbandonedCheckBox.Checked = CBool(rRow("Abandoned"))
            If CInt(rRow("ProcedureType")) <> ProcedureType.Sigmoidscopy Then
                CompleteCheckBox.Attributes.Add("style", "display:none")
                If rRow.IsNull("TimeToCaecumMin") Then
                    If Not bTrainer AndAlso Not rRow.IsNull("TimeToCaecumMin_Photo") Then
                        TimeToCaecumMinRadNumericTextBox.Text = rRow("TimeToCaecumMin_Photo")
                    Else
                        TimeToCaecumMinRadNumericTextBox.Text = 0
                    End If
                Else
                    TimeToCaecumMinRadNumericTextBox.Text = rRow("TimeToCaecumMin")
                End If
                If rRow.IsNull("TimeToCaecumSec") Then
                    If Not bTrainer AndAlso Not rRow.IsNull("TimeToCaecumSec_Photo") Then
                        TimeToCaecumSecRadNumericTextBox.Text = rRow("TimeToCaecumSec_Photo")
                    Else
                        TimeToCaecumSecRadNumericTextBox.Text = 0
                    End If
                Else
                    TimeToCaecumSecRadNumericTextBox.Text = rRow("TimeToCaecumSec")
                End If

                If (rRow.IsNull("TimeForWithdrawalMin")) Then
                    If Not bTrainer AndAlso Not rRow.IsNull("TimeForWithdrawalMin_Photo") Then
                        TimeForWithdrawalMinRadNumericTextBox.Text = rRow("TimeForWithdrawalMin_Photo")
                    Else
                        TimeForWithdrawalMinRadNumericTextBox.Text = 0
                    End If
                Else
                    TimeForWithdrawalMinRadNumericTextBox.Text = rRow("TimeForWithdrawalMin")
                End If
                If (rRow.IsNull("TimeForWithdrawalSec")) Then
                    If Not bTrainer AndAlso Not rRow.IsNull("TimeForWithdrawalSec_Photo") Then
                        TimeForWithdrawalSecRadNumericTextBox.Text = rRow("TimeForWithdrawalSec_Photo")
                    Else
                        TimeForWithdrawalSecRadNumericTextBox.Text = 0
                    End If
                Else
                    TimeForWithdrawalSecRadNumericTextBox.Text = rRow("TimeForWithdrawalSec")
                End If
            End If

            If bTrainer Then
                LoadFormControlsTrainer(rRow)
            End If
        End If

        If CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Sigmoidscopy Then
            TimeToCaecumMinRadNumericTextBox.Text = 0
            TimeToCaecumSecRadNumericTextBox.Text = 0
            TimeForWithdrawalMinRadNumericTextBox.Text = 0
            TimeForWithdrawalSecRadNumericTextBox.Text = 0
            CaecumTimeTrID.Attributes.Add("style", "display:none")
            CompleteCheckBox.Attributes.Add("style", "display:none")
            CompleteCheckBox_NED.Attributes.Add("style", "display:none")
        Else
            CaecumTimeTrID.Attributes.Add("style", "display:normal")
            CompleteCheckBox.Checked = False
            CompleteCheckBox.Attributes.Add("style", "display:none")
            CompleteCheckBox_NED.Attributes.Add("style", "display:none")
        End If
    End Sub

    Private Sub LoadFormControlsTrainer(rRow As DataRow)
        InsertionLimitedRadComboBox_NED.Enabled = True
        InsertionSpecificDiv_NED.Attributes.Add("style", "display:none")
        If CBool(rRow("NED_RectalExam")) Then
            RectalExamDoneRadioButton_NED.Checked = True
        Else
            RectalExamNotDoneRadioButton_NED.Checked = True
        End If
        If CBool(rRow("NED_Retroflexion")) Then
            RetroflexionDoneRadioButton_NED.Checked = True
        Else
            RetroflexionNotDoneRadioButton_NED.Checked = True
        End If
        If Not rRow.IsNull("NED_InsertionTo") Then
            Select Case CInt(rRow("NED_InsertionTo"))
                Case 1
                    InsertionSpecificCheckBox_NED.Checked = True
                    InsertionSpecificCheckRadNumericTextBox_NED.Text = rRow("NED_SpecificDistanceCm")
                    InsertionSpecificDiv_NED.Attributes.Add("style", "display:inline-block")
                Case 2
                    NotRecordedCheckBox_NED.Checked = True
                'InsertionConfirmedTrID.Attributes.Add("style", "display:none")
                'InsertionLimitedTrID.Attributes.Add("style", "display:none")
                Case 3
                    ProximalSigmoidCheckBox_NED.Checked = True
                Case 4
                    MidTransverseCheckBox_NED.Checked = True
                Case 5
                    CaecumCheckBox_NED.Checked = True
                    'InsertionLimitedRadComboBox.Enabled = False
                    initboxTrainer()
                Case 6
                    CompleteCheckBox_NED.Checked = True
                Case 7
                    DistalDescendingCheckBox_NED.Checked = True
                Case 8
                    ProximalTransverseCheckBox_NED.Checked = True
                Case 9
                    TerminalIleumCheckBox_NED.Checked = True
                    'InsertionLimitedRadComboBox.Enabled = False
                    initboxTrainer()
                Case 10
                    RectumCheckBox_NED.Checked = True
                Case 11
                    ProximalDescendingCheckBox_NED.Checked = True
                Case 12
                    HepaticFlexureCheckBox_NED.Checked = True
                Case 13
                    NeoTerminalCheckBox_NED.Checked = True
                    'InsertionLimitedRadComboBox.Enabled = False
                    initboxTrainer()
                Case 14
                    RectoSigmoidCheckBox_NED.Checked = True
                Case 15
                    SplenicFlexureCheckBox_NED.Checked = True
                Case 16
                    DistalAscendingCheckBox_NED.Checked = True
                Case 17
                    DistalSigmoidCheckBox_NED.Checked = True
                Case 18
                    DistalTransverseCheckBox_NED.Checked = True
                Case 19
                    ProximalAscendingCheckBox_NED.Checked = True
                Case 30
                    AnastomosisCheckBox_NED.Checked = True
                Case 31
                    IleoColonCheckBox_NED.Checked = True
                Case 32
                    PouchCheckBox_NED.Checked = True
            End Select
        End If

        InsertionComfirmedRadComboBox_NED.SelectedValue = rRow("NED_InsertionConfirmedBy").ToString()
        InsertionLimitedRadComboBox_NED.SelectedValue = rRow("NED_InsertionLimitedBy").ToString()
        DifficultiesEncounteredRadComboBox_NED.SelectedValue = rRow("NED_DifficultiesEncountered").ToString()

        IleocecalValveCheckBox_NED.Checked = CBool(rRow("NED_IleocecalValve"))
        TransIlluminationCheckBox_NED.Checked = CBool(rRow("NED_TransIllumination"))
        IlealIntubationCheckBox_NED.Checked = CBool(rRow("NED_IlealIntubation"))
        AppendicularOrificeCheckBox_NED.Checked = CBool(rRow("NED_AppendicularOrifice"))
        TriRadiateCheckBox_NED.Checked = CBool(rRow("NED_TriRadiateCaecalFold"))
        DigitalPressureCheckBox_NED.Checked = CBool(rRow("NED_DigitalPressure"))

        ConfidenceDegreeCheckBox_NED.Checked = CBool(rRow("NED_DegreeOfConfidence"))
        PositivelyRadioButton_NED.Checked = CBool(rRow("NED_Positively"))
        WithReasonableConfidenceRadioButton_NED.Checked = CBool(rRow("NED_WithReasonableConfidence"))
        AbandonedCheckBox_NED.Checked = CBool(rRow("NED_Abandoned"))
        If CInt(rRow("ProcedureType")) <> ProcedureType.Sigmoidscopy Then
            CompleteCheckBox_NED.Attributes.Add("style", "display:none")

            If (rRow.IsNull("NED_TimeToCaecumMin")) Then
                If Not bTrainer AndAlso Not rRow.IsNull("TimeToCaecumMin_Photo") Then
                    TimeForWithdrawalMinRadNumericTextBox_NED.Text = CInt(rRow("TimeToCaecumMin_Photo"))
                Else
                    TimeForWithdrawalMinRadNumericTextBox_NED.Text = 0
                End If
            Else
                TimeForWithdrawalMinRadNumericTextBox_NED.Text = rRow("NED_TimeToCaecumMin").ToString()
            End If
            If (rRow.IsNull("NED_TimeToCaecumSec")) Then
                If Not bTrainer AndAlso Not rRow.IsNull("TimeToCaecumSec_Photo") Then
                    TimeToCaecumSecRadNumericTextBox_NED.Text = CInt(rRow("TimeToCaecumSec_Photo"))
                Else
                    TimeToCaecumSecRadNumericTextBox_NED.Text = 0
                End If
            Else
                TimeToCaecumSecRadNumericTextBox_NED.Text = rRow("NED_TimeToCaecumSec").ToString()
            End If

            If (rRow.IsNull("NED_TimeForWithdrawalMin")) Then
                If Not bTrainer AndAlso Not rRow.IsNull("TimeForWithdrawalMin_Photo") Then
                    TimeForWithdrawalMinRadNumericTextBox_NED.Text = CInt(rRow("TimeForWithdrawalMin_Photo"))
                Else
                    TimeForWithdrawalMinRadNumericTextBox_NED.Text = 0
                End If
            Else
                TimeForWithdrawalMinRadNumericTextBox_NED.Text = rRow("NED_TimeForWithdrawalMin").ToString()
            End If

            If (rRow.IsNull("NED_TimeForWithdrawalSec")) Then
                If Not bTrainer AndAlso Not rRow.IsNull("TimeForWithdrawalSec_Photo") Then
                    TimeForWithdrawalSecRadNumericTextBox_NED.Text = CInt(rRow("TimeForWithdrawalSec_Photo"))
                Else
                    TimeForWithdrawalSecRadNumericTextBox_NED.Text = 0
                End If
            Else
                TimeForWithdrawalSecRadNumericTextBox_NED.Text = rRow("NED_TimeForWithdrawalSec").ToString()
            End If

            'TimeForWithdrawalMinRadNumericTextBox_NED.Text = rRow("NED_TimeForWithdrawalMin").ToString()
            'TimeForWithdrawalSecRadNumericTextBox_NED.Text = rRow("NED_TimeForWithdrawalSec").ToString()

            'If Not rRow.IsNull("TimeForWithdrawalMin_Photo") Then
            '    AutoEntryRadioButton_ER.Checked = True
            '    TimeForWithdrawalMinRadNumericTextBox_AutoEntry_ER.Value = CInt(rRow("TimeForWithdrawalMin_Photo"))
            'End If
            'If Not rRow.IsNull("TimeForWithdrawalSec_Photo") Then
            '    AutoEntryRadioButton_ER.Checked = True
            '    TimeForWithdrawalSecRadNumericTextBox_AutoEntry_ER.Value = CInt(rRow("TimeForWithdrawalSec_Photo"))
            'End If
        End If
    End Sub

    Protected Sub initbox(Optional state As Boolean = False)
        InsertionConfirmedTrID.Attributes.Remove("style")
        InsertionLimitedTrID.Attributes.Remove("style")
    End Sub

    Protected Sub initboxTrainer(Optional state As Boolean = False)
        InsertionConfirmedTrID_NED.Attributes.Remove("style")
        InsertionLimitedTrID_NED.Attributes.Remove("style")
    End Sub
    Protected Sub SaveExtentData(isSaveAndClose As Boolean)
        Try

            Dim insertionVia As Integer = 0
            If InsertionAnusRadioButton.Checked Then
                insertionVia = 1
            ElseIf InsertionColostomyRadioButton.Checked Then
                insertionVia = 2
            ElseIf InsertionLoopColostomyRadioButton.Checked Then
                insertionVia = 3
            ElseIf InsertionCaecostomyRadioButton.Checked Then
                insertionVia = 4
            ElseIf InsertionIleostomyRadioButton.Checked Then
                insertionVia = 5
            End If

            Dim insertionTo As Integer = 0
            Dim InsertionSpecific As Integer = 0
            Dim insertionTo_Trainer As Integer = 0
            Dim InsertionSpecific_Trainer As Integer = 0

            Dim InsertionComfirmedRadComboBox_NED_txt As String = ""
            Dim InsertionLimitedRadComboBox_NED_txt As String = ""
            Dim DifficultiesEncounteredRadComboBox_NED_txt As String = ""

            If Not InsertionComfirmedRadComboBox_NED.SelectedItem Is Nothing Then
                InsertionComfirmedRadComboBox_NED_txt = InsertionComfirmedRadComboBox_NED.SelectedItem.Text
            End If
            If Not InsertionLimitedRadComboBox_NED.SelectedItem Is Nothing Then
                InsertionLimitedRadComboBox_NED_txt = InsertionLimitedRadComboBox_NED.SelectedItem.Text
            End If
            If Not DifficultiesEncounteredRadComboBox_NED.SelectedItem Is Nothing Then
                DifficultiesEncounteredRadComboBox_NED_txt = DifficultiesEncounteredRadComboBox_NED.SelectedItem.Text
            End If

            If InsertionSpecificCheckBox.Checked Then
                InsertionSpecific = InsertionSpecificCheckRadNumericTextBox.Text
                insertionTo = 1
            Else
                InsertionSpecific = 0
            End If

            If InsertionSpecificCheckBox_NED.Checked Then
                InsertionSpecific_Trainer = InsertionSpecificCheckRadNumericTextBox_NED.Text
                insertionTo_Trainer = 1
            Else
                InsertionSpecific_Trainer = 0
            End If

            If NotRecordedCheckBox.Checked Then
                insertionTo = 2
            ElseIf ProximalSigmoidCheckBox.Checked Then
                insertionTo = 3
            ElseIf MidTransverseCheckBox.Checked Then
                insertionTo = 4
            ElseIf CaecumCheckBox.Checked Then
                insertionTo = 5
            ElseIf CompleteCheckBox.Checked Then
                insertionTo = 6
            ElseIf DistalDescendingCheckBox.Checked Then
                insertionTo = 7
            ElseIf ProximalTransverseCheckBox.Checked Then
                insertionTo = 8
            ElseIf TerminalIleumCheckBox.Checked Then
                insertionTo = 9
            ElseIf RectumCheckBox.Checked Then
                insertionTo = 10
            ElseIf ProximalDescendingCheckBox.Checked Then
                insertionTo = 11
            ElseIf HepaticFlexureCheckBox.Checked Then
                insertionTo = 12
            ElseIf NeoTerminalCheckBox.Checked Then
                insertionTo = 13
            ElseIf RectoSigmoidCheckBox.Checked Then
                insertionTo = 14
            ElseIf SplenicFlexureCheckBox.Checked Then
                insertionTo = 15
            ElseIf DistalAscendingCheckBox.Checked Then
                insertionTo = 16
            ElseIf DistalSigmoidCheckBox.Checked Then
                insertionTo = 17
            ElseIf DistalTransverseCheckBox.Checked Then
                insertionTo = 18
            ElseIf ProximalAscendingCheckBox.Checked Then
                insertionTo = 19
            ElseIf AnastomosisCheckBox.Checked Then
                insertionTo = 30
            ElseIf IleoColonCheckBox.Checked Then
                insertionTo = 31
            ElseIf PouchCheckBox.Checked Then
                insertionTo = 32
            End If

            If NotRecordedCheckBox_NED.Checked Then
                insertionTo_Trainer = 2
            ElseIf ProximalSigmoidCheckBox_NED.Checked Then
                insertionTo_Trainer = 3
            ElseIf MidTransverseCheckBox_NED.Checked Then
                insertionTo_Trainer = 4
            ElseIf CaecumCheckBox_NED.Checked Then
                insertionTo_Trainer = 5
            ElseIf CompleteCheckBox_NED.Checked Then
                insertionTo_Trainer = 6
            ElseIf DistalDescendingCheckBox_NED.Checked Then
                insertionTo_Trainer = 7
            ElseIf ProximalTransverseCheckBox_NED.Checked Then
                insertionTo_Trainer = 8
            ElseIf TerminalIleumCheckBox_NED.Checked Then
                insertionTo_Trainer = 9
            ElseIf RectumCheckBox_NED.Checked Then
                insertionTo_Trainer = 10
            ElseIf ProximalDescendingCheckBox_NED.Checked Then
                insertionTo_Trainer = 11
            ElseIf HepaticFlexureCheckBox_NED.Checked Then
                insertionTo_Trainer = 12
            ElseIf NeoTerminalCheckBox_NED.Checked Then
                insertionTo_Trainer = 13
            ElseIf RectoSigmoidCheckBox_NED.Checked Then
                insertionTo_Trainer = 14
            ElseIf SplenicFlexureCheckBox_NED.Checked Then
                insertionTo_Trainer = 15
            ElseIf DistalAscendingCheckBox_NED.Checked Then
                insertionTo_Trainer = 16
            ElseIf DistalSigmoidCheckBox_NED.Checked Then
                insertionTo_Trainer = 17
            ElseIf DistalTransverseCheckBox_NED.Checked Then
                insertionTo_Trainer = 18
            ElseIf ProximalAscendingCheckBox_NED.Checked Then
                insertionTo_Trainer = 19
            ElseIf AnastomosisCheckBox_NED.Checked Then
                insertionTo_Trainer = 30
            ElseIf IleoColonCheckBox_NED.Checked Then
                insertionTo_Trainer = 31
            ElseIf PouchCheckBox_NED.Checked Then
                insertionTo_Trainer = 32
            End If

            Dim ds As New OtherData
            ds.SaveColonExtentLimitingFactor(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
            IIf(RectalExamDoneRadioButton.Checked, True, False),
           IIf(RetroflexionDoneRadioButton.Checked, True, False),
           insertionVia,
           insertionTo,
           InsertionSpecific,
           IInt(InsertionComfirmedRadComboBox.SelectedValue),
           Utilities.GetComboBoxText(InsertionComfirmedRadComboBox),
           IInt(InsertionLimitedRadComboBox.SelectedValue),
           Utilities.GetComboBoxText(InsertionLimitedRadComboBox),
           IInt(DifficultiesEncounteredRadComboBox.SelectedValue),
           Utilities.GetComboBoxText(DifficultiesEncounteredRadComboBox),
           IleocecalValveCheckBox.Checked,
           TransIlluminationCheckBox.Checked,
           IlealIntubationCheckBox.Checked,
           AppendicularOrificeCheckBox.Checked,
           TriRadiateCheckBox.Checked,
           DigitalPressureCheckBox.Checked,
           ConfidenceDegreeCheckBox.Checked,
           PositivelyRadioButton.Checked,
           WithReasonableConfidenceRadioButton.Checked,
           IIf(Trim(TimeToCaecumMinRadNumericTextBox.Text) = "", 0, TimeToCaecumMinRadNumericTextBox.Text),
           IIf(Trim(TimeToCaecumSecRadNumericTextBox.Text) = "", 0, TimeToCaecumSecRadNumericTextBox.Text),
           IIf(Trim(TimeForWithdrawalMinRadNumericTextBox.Text) = "", 0, TimeForWithdrawalMinRadNumericTextBox.Text),
           IIf(Trim(TimeForWithdrawalSecRadNumericTextBox.Text) = "", 0, TimeForWithdrawalSecRadNumericTextBox.Text),
           AbandonedCheckBox.Checked,
           IIf(RectalExamDoneRadioButton_NED.Checked, True, False),
           IIf(RetroflexionDoneRadioButton_NED.Checked, True, False),
           insertionTo_Trainer,
           InsertionSpecific_Trainer,
           IIf(Trim(InsertionComfirmedRadComboBox_NED.SelectedValue) = "", 0, InsertionComfirmedRadComboBox_NED.SelectedValue),
           InsertionComfirmedRadComboBox_NED_txt,
           IIf(Trim(InsertionLimitedRadComboBox_NED.SelectedValue) = "", 0, InsertionLimitedRadComboBox_NED.SelectedValue),
           InsertionLimitedRadComboBox_NED_txt,
           IIf(Trim(DifficultiesEncounteredRadComboBox_NED.SelectedValue) = "", 0, DifficultiesEncounteredRadComboBox_NED.SelectedValue),
           DifficultiesEncounteredRadComboBox_NED_txt,
           IleocecalValveCheckBox_NED.Checked,
           TransIlluminationCheckBox_NED.Checked,
           IlealIntubationCheckBox_NED.Checked,
           AppendicularOrificeCheckBox_NED.Checked,
           TriRadiateCheckBox_NED.Checked,
           DigitalPressureCheckBox_NED.Checked,
           ConfidenceDegreeCheckBox_NED.Checked,
           PositivelyRadioButton_NED.Checked,
           WithReasonableConfidenceRadioButton_NED.Checked,
           IIf(Trim(TimeToCaecumMinRadNumericTextBox_NED.Text) = "", 0, TimeToCaecumMinRadNumericTextBox_NED.Text),
           IIf(Trim(TimeToCaecumSecRadNumericTextBox_NED.Text) = "", 0, TimeToCaecumSecRadNumericTextBox_NED.Text),
           IIf(Trim(TimeForWithdrawalMinRadNumericTextBox_NED.Text) = "", 0, TimeForWithdrawalMinRadNumericTextBox_NED.Text),
           IIf(Trim(TimeForWithdrawalSecRadNumericTextBox_NED.Text) = "", 0, TimeForWithdrawalSecRadNumericTextBox_NED.Text),
           AbandonedCheckBox_NED.Checked,
           isSaveAndClose)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If isSaveAndClose Then
                ExitForm()
            End If

            ' Refresh the left side Summary panel that's on the master page
            'Dim c As Control = FindAControl(Me.Master.Controls, "SummaryListView")
            'If c IsNot Nothing Then
            '    Dim lvSummary As ListView = DirectCast(c, ListView)
            '    lvSummary.DataBind()
            'End If


            'Me.Master.SetButtonStyle()

        Catch ex As Exception

            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Extent/Limiting Factors - Colon.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
        'LoadFormControls()
    End Sub

    Protected Sub cancelRecord()
        ExitForm()
    End Sub

    Protected Sub SaveOnly_Click(sender As Object, e As EventArgs) Handles SaveOnly.Click
        SaveRecord(False)
    End Sub

    Protected Sub cmdAccept_Click(sender As Object, e As EventArgs) Handles cmdAccept.Click
        SaveRecord(True)
    End Sub

    Protected Sub SaveRecord(isSaveAndClose As Boolean)

        SaveExtentData(isSaveAndClose)

        ' Refresh the left side Summary panel that's on the master page
        Dim c As Control = FindAControl(Me.Master.Controls, "SummaryListView")
        If c IsNot Nothing Then
            Dim lvSummary As ListView = DirectCast(c, ListView)
            lvSummary.DataBind()
        End If

        Select Case Session("AdvancedMode")
            Case True
                InitMsg(isSaveAndClose)
            Case False
                If isSaveAndClose Then
                    ExitForm()
                End If
        End Select

        'DirectCast(Session("BoldButtons"), List(Of String)).Add("Extent/limiting factors")
        Me.Master.SetButtonStyle()
    End Sub

    Protected Sub InitMsg(isSaveAndClose As Boolean)
        If Session("UpdateDBFailed") = True Then Exit Sub

        If isSaveAndClose Then
            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        End If
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub
End Class
