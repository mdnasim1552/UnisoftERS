Imports Telerik.Web.UI
Imports Microsoft.VisualBasic

Partial Class Products_Gastro_TherapeuticProcedures_OGDTherapeuticProcedures
    Inherits SiteDetailsBase

    Private Enum ControlType
        Check
        Text
        RadioButton
        Numeric
        Combo
    End Enum

    Public siteId As Integer
    Private sArea As String
    Private insertionType As String
    Private UGI_Record As ERS.Data.ERS_UpperGITherapeutics
    Private _fieldValueFound As Boolean

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = Request.QueryString("SiteID")
        sArea = Request.QueryString("Area")
        insertionType = Request.QueryString("InsertionType")


        If Not IsPostBack Then

            Initiate_User_Control_TherapeuticRecord()
            If insertionType = "STENT" Then
                showInstruction()
            ElseIf insertionType = "YAG" Then
                showYagInstruction()
            ElseIf insertionType = "PEG" Then
                showPEGInstruction()
            End If

            DisplayControls()



            hiddenSiteId.Value = siteId

            TherapeuticRecord_LoadData()
            BicapElectroTypeComboBox.Items.Insert(0, New RadComboBoxItem("", Nothing))
        End If

    End Sub

    Protected Sub showInstruction()
        Dim script As String = "function f(){$find(""" + RadWindow1.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key1", script, True)
    End Sub

    Protected Sub showYagInstruction()
        Dim script As String = "function f(){$find(""" + RadWindow2.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key2", script, True)
    End Sub

    Protected Sub showPEGInstruction()
        Dim script As String = "function f(){$find(""" + RadWindow3.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key3", script, True)
    End Sub

    Private Sub DisplayControls()
        'Dim sArea As String = Request.QueryString("Area")
        Dim procType As Integer = Session(Constants.SESSION_PROCEDURE_TYPE)
        SetTherapeuticTR({"VaricealClipTR"})

        Select Case procType
            Case ProcedureType.Gastroscopy, ProcedureType.EUS_OGD, ProcedureType.Antegrade, ProcedureType.Transnasal
                Dim isProcedureTypeAntegrade As Boolean = False
                If (String.Compare(procType, ProcedureType.Antegrade) = 0) Then
                    isProcedureTypeAntegrade = True
                End If

                Dim sArea As String = Request.QueryString("Area")

                Select Case sArea
                    Case "Oesophagus"
                        'SetShowTherapeuticTR({"bandLigationHide", "BotoxInjectionTR", "BougieDilationTR", "RadioFrequencyTR", "StentInsertionTR", "StentRemovalTR", "VaricealSclerotherapyTR", "YAGLaserTR",
                        '                     "BicapElectroTR", "OesophagealDilatationTR"})
                        SetShowTherapeuticTR({"bandLigationHide", "BotoxInjectionTR", "RadioFrequencyTR", "StentInsertionTR", "StentRemovalTR", "VaricealSclerotherapyTR", "YAGLaserTR",
                                             "BicapElectroTR", "OesophagealDilatationTR"})

                        'SetTherapeuticTR({"PolypectomyTR", "GastrostomyInsertionTR", "GastrostomyRemovalTR", "NGNJTubeInsertionTR", "PyloricDilatationTR"})
                        'SetTherapeuticTR({"BougieDilationTR"}, "HtmlTableRow", procType = ProcedureType.Antegrade)
                        DisplayInstructionForCareButtons()
                        DisplayCorrectStentPlacementOptions()
                    Case "Stomach"
                        SetShowTherapeuticTR({"bandLigationHide", "EndoloopPlacementTR", "HeatProbeTR", "GastrostomyInsertionTR", "PolypectomyTR", "NGNJTubeInsertionTR", "PyloricDilatationTR", "GastricBalloonInsertionTR", "BalloonDilationTR", "BicapElectroTR"})

                        'SetTherapeuticTR({"OesophagealDilatationTR", "PyloricDilatationTR", "RadioFrequencyTR", "ProbeInsertionTR"})
                        SetGastrostomyInsertionText()
                    Case "Duodenum"
                        'SetShowTherapeuticTR({"bandLigationHide", "EndoloopPlacementTR", "HeatProbeTR", "PolypectomyTR", "StentInsertionTR", "StentRemovalTR", "NGNJTubeInsertionTR", "GastrostomyInsertionTR", "PyloricDilatationTR", "DiverticulotomyTR", "BicapElectroTR"})
                        SetShowTherapeuticTR({"bandLigationHide", "EndoloopPlacementTR", "HeatProbeTR", "PolypectomyTR", "StentInsertionTR", "StentRemovalTR", "NGNJTubeInsertionTR", "GastrostomyInsertionTR", "PyloricDilatationTR", "BicapElectroTR"})

                        'SetTherapeuticTR({"OesophagealDilatationTR", "GastrostomyRemovalTR", "GastrostomyInsertionTR", "PolypectomyTR", "VaricealSclerotherapyTR", "VaricealBandingTR", "RadioFrequencyTR", "ProbeInsertionTR"})
                        SetGastrostomyInsertionText()
                        'SetTherapeuticTR({"PolypectomyTR"}, "HtmlTableRow", (procType = ProcedureType.Antegrade))
                    Case Else
                        SetTherapeuticTR({"GastrostomyInsertionTR", "NGNJTubeInsertionTR", "GastrostomyRemovalTR", "PyloricDilatationTR", "OesophagealDilatationTR", "VaricealSclerotherapyTR", "VaricealBandingTR", "RadioFrequencyTR", "ProbeInsertionTR"})
                End Select

                'SetTherapeuticTR({"FineNeedleAspirationTR", "FineNeedleAspirationTR"}, "HtmlTableRow", procType = ProcedureType.EUS_OGD)

                'to be shown regardless of the region
                SetShowTherapeuticTR({"argonBeamRowHide", "clipRowHide", "emrRowHide", "ForeignBodyTR", "HotBiopsyTR", "injectionRowHide", "markingRowHide", "DiathermyTR", "homeostasisRowHide"})
                If isProcedureTypeAntegrade Then
                    ForeignBodyTR.Visible = False
                    FlatusTubeInsertionTR.Visible = False
                    ForeignBodyCheckBox.Visible = False
                    FlatusTubeInsertionCheckBox.Visible = False
                    HotBiopsyTR.Visible = False
                    HotBiopsyCheckBox.Visible = False
                    emrRowHide.Visible = False
                    'Added by rony tfs-4073
                    If sArea = "Oesophagus" Then
                        PyloricDilatationTR.Visible = False
                    Else
                        PyloricDilatationTR.Visible = True
                    End If
                End If

                If (String.Compare(procType, ProcedureType.EUS_OGD) = 0) Then
                    BougieDilationTR.Visible = False
                    BougieDilationCheckBox.Visible = False
                End If


            Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy, ProcedureType.Proctoscopy, ProcedureType.Retrograde
                Select Case sArea
                    Case "Anal Margin"
                        'SetTherapeuticTR({"GastrostomyInsertionTR", "NGNJTubeInsertionTR", "GastrostomyRemovalTR", "PyloricDilatationTR", "OesophagealDilatationTR", "VaricealSclerotherapyTR", "VaricealBandingTR", "RadioFrequencyTR", "ProbeInsertionTR"})
                        SetShowTherapeuticTR({"BandingPilesTR"})
                    Case "Rectum"
                        SetShowTherapeuticTR({"BandingPilesTR"})
                    Case Else

                        'SetTherapeuticTR({"GastrostomyInsertionTR", "NGNJTubeInsertionTR", "GastrostomyRemovalTR", "PyloricDilatationTR", "OesophagealDilatationTR", "VaricealSclerotherapyTR", "VaricealBandingTR", "RadioFrequencyTR", "ProbeInsertionTR"})

                        'SetTherapeuticTR({"SigmoidopexyTR", "ColonicDecompressionTR", "FlatusTubeInsertionTR"}, "HtmlTableRow", bShow:=True) '## Show SigmoidopexyTR
                        'SetTherapeuticTR({"PancolonicDyeSprayTR"}, "HtmlTableRow", (procType = ProcedureType.Colonoscopy)) '## Show only for COLON
                End Select

                SetShowTherapeuticTR({"argonBeamRowHide",
                                     "BalloonDilationTR",
                                     "clipRowHide",
                                     "EndoloopPlacementTR",
                                     "emrRowHide",
                                     "ForeignBodyTR",
                                     "HeatProbeTR",
                                     "HotBiopsyTR",
                                     "injectionRowHide",
                                     "markingRowHide",
                                     "PolypectomyTR",
                                     "StentInsertionTR",
                                     "StentRemovalTR",
                                     "BandingPilesTR",
                                     "DiathermyTR",
                                     "bandLigationHide",
                                     "BicapElectroTR",
                                     "homeostasisRowHide"})
                DisplayCorrectStentPlacementOptions()
            Case ProcedureType.ERCP, ProcedureType.EUS_HPB ' removed procedure by Ferdowsi, TFS - 4324
                SetTherapeuticTR({"GastrostomyInsertionTR", "GastrostomyRemovalTR", "PyloricDilatationTR", "OesophagealDilatationTR", "VaricealSclerotherapyTR", "VaricealBandingTR", "RadioFrequencyTR", "ProbeInsertionTR", "bandLigationHide"})
                'Dim region As String = Request.QueryString("Reg")
                'Select Case region
                '    Case "Second Part", "First Part", "Medial Wall First Part", "Lateral Wall First Part",
                '        "Lateral Wall Second Part", "Medial Wall Second Part", "Third Part", "Lateral Wall Third Part", "Medial Wall Third Part"
                'End Select
            Case ProcedureType.Bronchoscopy, ProcedureType.EBUS  ' added by Ferdowsi, TFS - 4324
                SetTherapeuticTR({"GastrostomyInsertionTR", "GastrostomyRemovalTR", "FlatusTubeInsertionTR", "PyloricDilatationTR", "OesophagealDilatationTR", "VaricealSclerotherapyTR", "VaricealBandingTR", "RadioFrequencyTR", "ProbeInsertionTR", "bandLigationHide"})
            Case Else

        End Select

        If procType = ProcedureType.EUS_OGD OrElse procType = ProcedureType.EBUS Then
            FineNeedleAspirationTR.Visible = True
            FineNeedleBiopsyTR.Visible = True
        End If

        HideNonEbusBroncTheraps()

        'SetTherapeuticTR({"BandLigationCheckBox", "BotoxInjectionCheckBox", "EndoloopPlacementCheckBox", "ForeignBodyCheckBox"}, "CheckBox")

        'The code below works for JS
        'Page.ClientScript.RegisterStartupScript(Me.GetType(), "ShowTR", "hideTR('" & sArea & "');", True)

    End Sub

    Private Sub HideNonEbusBroncTheraps()
        If Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Bronchoscopy Or Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.EBUS Then
            'Attributes.Add("style", "display:hidden")
            argonBeamRowHide.Visible = True
            CryotherapyTR.Visible = True
            bandLigationHide.Visible = False
            injectionRowHide.Visible = True
            OesophagealDilatationTR.Visible = False
            PolypectomyTR.Visible = False
            BandingPilesTR.Visible = False
            GastrostomyInsertionTR.Visible = False
            GastrostomyRemovalTR.Visible = False
            NGNJTubeInsertionTR.Visible = False
            PyloricDilatationTR.Visible = False
            VaricealSclerotherapyTR.Visible = False
            VaricealBandingTR.Visible = False
            VaricealClipTR.Visible = False
            emrRowHide.Visible = False
            SigmoidopexyTR.Visible = False
            RadioFrequencyTR.Visible = False
            endoRowHide.Visible = False
            clipRowHide.Visible = False
            markingRowHide.Visible = False
            GastricBalloonInsertionTR.Visible = False
            DiverticulotomyTR.Visible = False

        Else 'Hide all these additional 5 options for other Procedure Types

            'Mahfuz added below on 05 Aug 2021
            DiathermyTR.Visible = False
            CoilTR.Visible = False
            ValveTR.Visible = False
            PhotodynamicTR.Visible = False

        End If
    End Sub

    Private Sub SetShowTherapeuticTR(arrTR As String(), Optional sCtrl As String = "HtmlTableRow")
        For Each value As String In arrTR
            Dim thisObj As Control = DirectCast(panTherapeuticsFormView.FindControl(value), HtmlTableRow)
            If thisObj IsNot Nothing Then thisObj.Visible = True
        Next
    End Sub

    Private Sub SetTherapeuticTR(arrTR As String(), Optional sCtrl As String = "HtmlTableRow", Optional bShow As Boolean = False)
        For Each value As String In arrTR
            Dim thisObj As Control
            If sCtrl = "CheckBox" Then
                thisObj = DirectCast(panTherapeuticsFormView.FindControl(value), CheckBox)
            Else
                thisObj = DirectCast(panTherapeuticsFormView.FindControl(value), HtmlTableRow)
            End If
            If thisObj IsNot Nothing Then thisObj.Visible = bShow
        Next
    End Sub

    Protected Sub DisplayInstructionForCareButtons()
        Dim w1 = DirectCast(panTherapeuticsFormView.FindControl("StentInstructionForCareButton"), RadButton)
        If w1 IsNot Nothing Then w1.Attributes.Add("style", "display:normal")
        Dim w2 = DirectCast(panTherapeuticsFormView.FindControl("OesoInstructionforCareButton"), RadButton)
        If w2 IsNot Nothing Then w2.Attributes.Add("style", "display:normal")
        Dim w3 = DirectCast(panTherapeuticsFormView.FindControl("YagInstructionForCareRadButton"), RadButton)
        If w3 IsNot Nothing Then w3.Attributes.Add("style", "display:normal")
    End Sub

    Protected Sub DisplayCorrectStentPlacementOptions()
        Dim da As New DataAccess
        divStentCorrectPlacement.Visible = da.ShowCorrectStentPlacementOptions(siteId, Session(Constants.SESSION_PROCEDURE_TYPE))

        If divStentCorrectPlacement.Visible Then
            Utilities.LoadRadioButtonList(FailedPlacementReasonsRadioButtonList, da.GetStentInsertionFailureReasons(), "ListItemText", "ListItemNo")
        End If

    End Sub

    Private Sub SetGastrostomyInsertionText()
        Dim ds As New Therapeutics
        Dim GastrostomyInsertionCheckBox = DirectCast(panTherapeuticsFormView.FindControl("GastrostomyInsertionCheckBox"), CheckBox)
        If GastrostomyInsertionCheckBox IsNot Nothing Then
            GastrostomyInsertionCheckBox.Text = ds.GetInstrumentUsed(siteId)

            'For "Gastrostomy insertion (PEG)", removal is "Gastrostomy removal (PEG)"
            'For "Jejunostomy insertion (PEJ)", removal is "Jejunostomy removal (PEJ)"     
            'For "Nasojejunal tube (NJT)", removal is "Nasojejunal removal (NJT)"
            Dim GastrostomyRemovalCheckBox = DirectCast(panTherapeuticsFormView.FindControl("GastrostomyRemovalCheckBox"), CheckBox)
            GastrostomyRemovalCheckBox.Text = Replace(Replace(GastrostomyInsertionCheckBox.Text, "insertion", "removal"), "tube", "removal")

            'Placement not required for Nasojejunal
            If InStr(GastrostomyInsertionCheckBox.Text.ToLower, "nasojejunal") Then
                Dim CorrectPlacementSpan = DirectCast(panTherapeuticsFormView.FindControl("CorrectPlacementSpan"), HtmlGenericControl)
                CorrectPlacementSpan.Visible = False
            End If
        End If
    End Sub

    Sub TherapeuticRecord_LoadData()
        Dim siteId As Integer = Convert.ToInt32(Request.QueryString("SiteId"))
        '######################################################################################
        '############ First Load all the Lookup Value for All Combo/Dropdown Boxes ############ 
        '######################################################################################  

        If sArea = "Oesophagus" Then DisplayInstructionForCareButtons()

        'Mahfuz added Coil, Valve type combo on 30 Jul 2021
        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                    {InjectionTypeComboBox, "Agent Upper GI"},
                    {GastrostomyInsertionUnitsComboBox, "Gastrostomy PEG units"},
                    {GastrostomyInsertionTypeComboBox, "Gastrostomy PEG type"},
                    {VaricealScleroInjTypeComboBox, "Agent Upper GI"},
                    {StentInsertionDiaUnitsComboBox, "Oesophageal dilatation units"},
                    {StentRemovalTechniqueComboBox, "Therapeutic Stent Removal Technique"},
                    {EmrFluidComboBox, "Therapeutic EMR Fluid"},
                    {MarkingTypeComboBox, "Abno marking"},
                    {DilatationUnitsComboBox, "Oesophageal dilatation units"},
                    {DilatorTypeComboBox, "Oesophageal dilator"},
                    {SigmoidopexyMakeComboBox, "Sigmoidopexy make"},
                    {PEGOutcomeComboBox, "PEG Outcome"},
                    {cboCoilType, "BRT Coil Type"},
                    {cboValveType, "BRT Valve Type"},
                    {HomeostasisComboBox, "Homeostasis"},
                    {BalloonDilationDiaUnitsComboBox, "Balloon dilatation units"},
                    {BicapElectroTypeComboBox, "Bicap Electrocautery"}
            })

        ' added by  mostafizur


        Dim StentInsertionTypeComboBox = DirectCast(panTherapeuticsFormView.FindControl("StentInsertionTypeComboBox"), RadComboBox)
        If StentInsertionTypeComboBox IsNot Nothing Then
            If sArea = "Oesophagus" Then
                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{StentInsertionTypeComboBox, "Therapeutic Stent Insertion Types"}})
            Else
                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{StentInsertionTypeComboBox, "Therapeutic Stomach Stent Insertion Types"}})
            End If
        End If

        Dim BalloonDilationTypeComboBox = DirectCast(panTherapeuticsFormView.FindControl("BalloonDilationTypeComboBox"), RadComboBox)
        If BalloonDilationTypeComboBox IsNot Nothing Then

            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{BalloonDilationTypeComboBox, "Therapeutic Balloon Dilation Types"}})

        End If
        '#############################################################################################################
        '############ Now Load Data- once all the controls are in the Variable and done with DirectCast() ############
        '#############################################################################################################
        Dim therap As New Therapeutics
        UGI_Record = therap.TherapeuticRecord_UGI_FindBySite(siteId)
        '### Now log the Insert/Update Activity! LogAsYouRead
        ''InsertAuditLog(EVENT_TYPE.SelectRecord, String.Format("Loading OGD Therapeutic {0} record, for Site: {1} and Procedure ID: ", hiddenTherapRoleId.Value, siteId))

        'set to nothing 1st load incase of previously created sessions
        Session("CommonPolypDetails") = Nothing

        If UGI_Record IsNot Nothing Then
            With UGI_Record
                SetValue("chkNoneCheckBox", ControlType.Check, .None)
                If .EndoRole > 0 Then
                    If .EndoRole = 1 Then
                        optIndependent.Selected = True
                    ElseIf .EndoRole = 2 Then
                        optObserved.Selected = True
                    ElseIf .EndoRole = 3 Then
                        optAssisted.Selected = True
                    ElseIf .EndoRole = 4 Then
                        optIndependentEndo2.Selected = True
                    End If
                End If

                SetValue("YagLaserCheckBox", ControlType.Check, .YAGLaser)
                If UGI_Record.YAGLaser Then
                    SetValue("YagLaserWattsNumericTextBox", ControlType.Numeric, .YAGLaserWatts)
                    SetValue("YagLaserPulsesNumericTextBox", ControlType.Numeric, .YAGLaserPulses)
                    SetValue("YagLaserSecsNumericTextBox", ControlType.Numeric, .YAGLaserSecs)
                    SetValue("YagLaserKJNumericTextBox", ControlType.Numeric, .YAGLaserKJ)

                    YAGDilNilByMouthCheckBox.Checked = IIf(.OesoYAGNilByMouth IsNot Nothing, CBool(.OesoYAGNilByMouth), False)
                    YAGDilNilByMouthHrsRadNumericTextBox.Text = .OesoYAGNilByMouthHrs
                    YagDilSoftDietCheckBox.Checked = IIf(.OesoYAGSoftDiet IsNot Nothing, CBool(.OesoYAGSoftDiet), False)
                    YagDilSoftDietDaysRadNumericTextBox.Text = .OesoYAGSoftDietDays
                    YagDilWarmFluidsCheckBox.Checked = IIf(.OesoYAGWarmFluids IsNot Nothing, CBool(.OesoYAGWarmFluids), False)
                    YagDilWarmFluidsHrsRadNumericTextBox.Text = .OesoYAGWarmFluidsHrs
                    YagDilMedicalReviewCheckBox.Checked = IIf(.OesoYAGMedicalReview IsNot Nothing, CBool(.OesoYAGMedicalReview), False)

                End If

                SetValue("ArgonBeamDiathermyCheckBox", ControlType.Check, .ArgonBeamDiathermy)
                If .ArgonBeamDiathermy Then
                    SetValue("ArgonBeamDiathermyWattsNumericTextBox", ControlType.Numeric, .ArgonBeamDiathermyWatts)
                    SetValue("ArgonBeamDiathermyPulsesNumericTextBox", ControlType.Numeric, .ArgonBeamDiathermyPulses)
                    SetValue("ArgonBeamDiathermySecsNumericTextBox", ControlType.Numeric, .ArgonBeamDiathermySecs)
                    SetValue("ArgonBeamDiathermyKJNumericTextBox", ControlType.Numeric, .ArgonBeamDiathermyKJ)
                End If

                SetValue("RFACheckBox", ControlType.Check, .RFA)
                If .RFA Then
                    SetValue("RfaTypeRadioButtonList", ControlType.RadioButton, .RFAType)
                    SetValue("RFATreatmentFromNumericTextBox", ControlType.Numeric, .RFATreatmentFrom)
                    SetValue("RFATreatmentToNumericTextBox", ControlType.Numeric, .RFATreatmentTo)
                    SetValue("RFAEnergyDeliveredNumericTextBox", ControlType.Numeric, .RFAEnergyDel)
                    SetValue("RFASegmentsTreatedNumericTextBox", ControlType.Numeric, .RFANumSegTreated)
                    SetValue("NoTimesSegmentTreatedNumericTextBox", ControlType.Numeric, .RFANumTimesSegTreated)
                End If

                SetValue("InjectionTherapyCheckBox", ControlType.Check, .Injection)
                If .Injection Then
                    SetValue("InjectionTypeComboBox", ControlType.Combo, .InjectionType)
                    SetValue("InjectionNumberNumericTextBox", ControlType.Numeric, .InjectionNumber)
                    SetValue("InjectionVolumeNumericTextBox", ControlType.Numeric, .InjectionVolume)
                End If

                SetValue("HomeostasisCheckBox", ControlType.Check, .Homeostasis)
                If .Homeostasis Then
                    SetValue("HomeostasisComboBox", ControlType.Combo, .HomeostasisType)
                End If

                SetValue("OesophagealDilatationCheckBox", ControlType.Check, .OesophagealDilatation)
                If .OesophagealDilatation Then
                    SetValue("DilatedToTextBox", ControlType.Numeric, .DilatedTo)
                    SetValue("DilatationUnitsComboBox", ControlType.Combo, .DilatationUnits)
                    SetValue("DilatorTypeComboBox", ControlType.Combo, .DilatorType)
                    SetValue("ScopePassCheckBox", ControlType.Check, .DilatorScopePass)
                    'added by rony tfs-3833
                    SetValue("PerforationRadioButtonList", ControlType.RadioButton, .DilatationPerforation)
                End If

                '#### Polypectomy Removal
                SetValue("PolypectomyCheckBox", ControlType.Check, .Polypectomy)
                'set details button click event 
                If .Polypectomy Then
                    SetValue("PolypectomyQtyRadNumericTextBox", ControlType.Numeric, .PolypectomyQty)
                    Dim polypDetails = AbnormalitiesDataAdapter.GetLesionsPolypData(siteId)
                    Session("CommonPolypDetails") = polypDetails
                End If

                '### Band Ligation
                SetValue("BandingPilesCheckBox", ControlType.Check, .BandingPiles)
                If .BandingPiles Then
                    SetValue("BandingNumRadNumericTextBox", ControlType.Numeric, .BandingNum)
                End If

                SetValue("BalloonDilationCheckBox", ControlType.Check, .BalloonDilation)
                ' added by mostafiz 
                If .BalloonDilation Then
                    SetValue("BalloonDilationTypeComboBox", ControlType.Combo, .BalloonDilationType)
                    SetValue("BalloonDilationDiaNumericTextBox", ControlType.Numeric, .BalloonDilationDiameter)
                    SetValue("BalloonDilationDiaUnitsComboBox", ControlType.Combo, .BalloonDilationDiameterUnits)

                End If
                ' added by mostafiz 


                SetValue("BandLigationCheckBox", ControlType.Check, .BandLigation)
                If .BandLigation Then
                    SetValue("BandLigationPerformedRadNumericTextBox", ControlType.Numeric, .BandLigationPerformed)
                    SetValue("BandLigationSuccessfulRadNumericTextBox", ControlType.Numeric, .BandLigationSuccessful)
                    '    SetValue("BandLigationRetreivedRadNumericTextBox", ControlType.Numeric, .BandLigationRetreived)
                End If

                SetValue("BotoxInjectionCheckBox", ControlType.Check, .BotoxInjection)
                SetValue("EndoloopPlacementCheckBox", ControlType.Check, .EndoloopPlacement)
                SetValue("HeatProbeCheckBox", ControlType.Check, .HeatProbe)
                SetValue("BicapElectroCheckBox", ControlType.Check, .BicapElectro)
                SetValue("ForeignBodyCheckBox", ControlType.Check, .ForeignBody)
                SetValue("HotBiopsyCheckBox", ControlType.Check, .HotBiopsy)
                'If .HotBiopsy Then
                '    SetValue("HotBiopsyPerformedRadNumericTextBox", ControlType.Numeric, .HotBiopsyPerformed)
                '    SetValue("HotBiopsySuccessfulRadNumericTextBox", ControlType.Numeric, .HotBiopsySuccessful)
                '    SetValue("HotBiopsyRetreivedRadNumericTextBox", ControlType.Numeric, .HotBiopsyRetreived)
                'End If


                SetValue("StentRemovalCheckBox", ControlType.Check, .StentRemoval)
                SetValue("StentRemovalTechniqueComboBox", ControlType.Combo, .StentRemovalTechnique)

                SetValue("GastrostomyInsertionCheckBox", ControlType.Check, .GastrostomyInsertion)
                If .GastrostomyInsertion Then
                    SetValue("GastrostomyInsertionUnitsComboBox", ControlType.Combo, .GastrostomyInsertionUnits)
                    SetValue("GastrostomyInsertionTypeComboBox", ControlType.Combo, .GastrostomyInsertionType)
                    SetValue("GastrostomyInsertionSizeNumericTextBox", ControlType.Numeric, .GastrostomyInsertionSize)
                    SetValue("GastrostomyInsertionBatchNoTextBox", ControlType.Text, .GastrostomyInsertionBatchNo)
                    SetValue("CorrectPEGPlacementRadioButtonList", ControlType.RadioButton, .CorrectPEGPlacement)

                    SetValue("PEGPlacementFailureReasonTextBox", ControlType.Text, .PEGPlacementFailureReason)
                    SetValue("PEGOutcomeComboBox", ControlType.Combo, .GastrostomyPEGOutcome)

                    NilByMouthCheckBox.Checked = .NilByMouth
                    NilByMouthHrsNumericTextBox.Text = IIf(.NilByMouthHrs IsNot Nothing, .NilByMouthHrs, "")
                    NilByProcCheckBox.Checked = .NilByProc
                    NilByProcHrsNumericTextBox.Text = .NilByProcHrs
                    FlangePositionNumericTextBox.Text = IIf(.FlangePosition IsNot Nothing, .FlangePosition, "")
                    AttachmentToWardCheckBox.Checked = .AttachmentToWard
                End If

                SetValue("NGNJTubeCheckBox", ControlType.Check, .NGNJTubeInsertion)
                If .NGNJTubeInsertion Then
                    If .NGNJTubeNostril IsNot Nothing Then
                        SetValue("NGNJTubeInsertionRadioButtonList", ControlType.RadioButton, .NGNJTubeNostril)
                    End If
                    SetValue("NGNJTubeInsertionLengthNumericTextBox", ControlType.Numeric, .NGNJTubeLength)
                    NGNJTubeInsertionBridle.Checked = .NGNJTubeBridle
                    SetValue("NGNJTubeInsertionBatchNoTextBox", ControlType.Text, .NGNJTubeBatch)
                End If

                SetValue("GastrostomyRemovalCheckBox", ControlType.Check, .GastrostomyRemoval)
                SetValue("PyloricDilatationChekBox", ControlType.Check, .PyloricDilatation)
                If .PyloricDilatation Then
                    SetValue("PyloricLeadingToPerforationRadioButton", ControlType.RadioButton, .PyloricLeadingToPerforation)
                End If

                SetValue("VaricealSclerotherapyCheckBox", ControlType.Check, .VaricealSclerotherapy)
                If .VaricealSclerotherapy Then
                    SetValue("VaricealScleroInjTypeComboBox", ControlType.Combo, .VaricealSclerotherapyInjectionType)
                    SetValue("VaricealScleroInjVolNumericTextBox", ControlType.Numeric, .VaricealSclerotherapyInjectionVol)
                    SetValue("VaricealScleroInjNumNumericTextBox", ControlType.Numeric, .VaricealSclerotherapyInjectionNum)
                End If

                SetValue("VaricealBandingCheckBox", ControlType.Check, .VaricealBanding)
                If .VaricealBanding Then SetValue("VaricealBandingNumNumericTextBox", ControlType.Numeric, .VaricealBandingNum)

                SetValue("VaricealClipCheckBox", ControlType.Check, .VaricealClip)

                '### Stent Insertion
                SetValue("StentInsertionCheckBox", ControlType.Check, .StentInsertion)
                If .StentInsertion Then
                    SetValue("StentInsertionQtyNumericTextBox", ControlType.Numeric, .StentInsertionQty)
                    SetValue("StentInsertionTypeComboBox", ControlType.Combo, .StentInsertionType)
                    SetValue("StentInsertionLengthNumericTextBox", ControlType.Numeric, .StentInsertionLength)
                    SetValue("StentInsertionDiaNumericTextBox", ControlType.Numeric, .StentInsertionDiameter)
                    SetValue("StentInsertionDiaUnitsComboBox", ControlType.Combo, .StentInsertionDiameterUnits)
                    SetValue("StentInsertionBatchNoTextBox", ControlType.Text, .StentInsertionBatchNo)
                    SetValue("MetalicStentCheckBox", ControlType.Check, .MetalicStent)
                    SetValue("StentCorrectPlacementRadioButton", ControlType.RadioButton, .CorrectStentPlacement)
                    If .CorrectStentPlacement IsNot Nothing AndAlso Not CBool(.CorrectStentPlacement) Then
                        SetValue("FailedPlacementReasonsRadioButtonList", ControlType.RadioButton, .StentPlacementFailureReason)
                    End If
                End If

                '### Stent Removal
                SetValue("StentRemovalCheckBox", ControlType.Check, .StentRemoval)
                If .StentRemoval Then SetValue("StentRemovalTechniqueComboBox", ControlType.Combo, .StentRemovalTechnique)

                '### 30 July 2021 - Mahfuz added Diathermy,Coil,Valve,Cryotherapy,PhotoDynamic
                SetValue("chkDiathermy", ControlType.Check, .Diathermy)
                If .Diathermy Then
                    SetValue("DiathermyWatt", ControlType.Numeric, .DiathermyWatt)
                End If

                SetValue("chkCoil", ControlType.Check, .Coil)
                If .Coil Then
                    SetValue("CoilQty", ControlType.Numeric, .CoilQty)
                    SetValue("cboCoilType", ControlType.Combo, .CoilType)
                End If

                SetValue("chkValve", ControlType.Check, .Valve)
                If .Valve Then
                    SetValue("ValveQty", ControlType.Numeric, .ValveQty)
                    SetValue("cboValveType", ControlType.Combo, .ValveType)
                End If

                SetValue("chkCryotherapy", ControlType.Check, .Cryotherapy)

                SetValue("chkPhotoDynamicTherapy", ControlType.Check, .PhotoDynamicTherapy)


                '### 30 July 2021 - Mahfuz added Finished here

                '### EMR
                SetValue("EmrCheckBox", ControlType.Check, .EMR)
                If .EMR Then
                    SetValue("EmrTypeRadioButtonList", ControlType.RadioButton, .EMRType)
                    SetValue("EmrFluidComboBox", ControlType.Combo, .EMRFluid)
                    SetValue("EmrFluidVolNumericTextBox", ControlType.Numeric, .EMRFluidVolume)
                End If

                '### Sigmoidopexy
                SetValue("SigmoidopexyCheckBox", ControlType.Check, .Sigmoidopexy)
                If .Sigmoidopexy Then
                    SetValue("SigmoidopexyQtyNumericBox", ControlType.Numeric, .SigmoidopexyQty)
                    SetValue("SigmoidopexyMakeComboBox", ControlType.Combo, .SigmoidopexyMake)
                    SetValue("SigmoidopexyFluidDaysRadNumeric", ControlType.Numeric, .SigmoidopexyFluidsDays)
                    SetValue("SigmoidopexyAtibioticDaysRadNumeric", ControlType.Numeric, .SigmoidopexyAntibioticsDays)
                End If

                '### RFA
                SetValue("RFACheckBox", ControlType.Check, .RFA)
                If .RFA Then
                    SetValue("RFATypeRadioButtonList", ControlType.RadioButton, .RFAType)
                    SetValue("RFATreatmentFromNumericTextBox", ControlType.Numeric, .RFATreatmentFrom)
                    SetValue("RFATreatmentToNumericTextBox", ControlType.Numeric, .RFATreatmentTo)
                    SetValue("RFAEnergyDeliveredNumericTextBox", ControlType.Numeric, .RFAEnergyDel)
                    SetValue("RFASegmentsTreatedNumericTextBox", ControlType.Numeric, .RFANumSegTreated)
                    SetValue("NoTimesSegmentTreatedNumericTextBox", ControlType.Numeric, .RFANumTimesSegTreated)
                End If

                '### pH probe insertion
                SetValue("PH_ProbeInsertionCheckBox", ControlType.Check, .pHProbeInsert)
                If .pHProbeInsert Then
                    SetValue("ProbeInsertedAtNumericTextBox", ControlType.Numeric, .pHProbeInsertAt)
                    SetValue("EndoscopicCheck", ControlType.Check, .pHProbeInsertChk)
                    SetValue("TopOfProbeNumericTextBox", ControlType.Numeric, .pHProbeInsertChkTopTo)
                End If

                '### Haemospray 
                SetValue("HaemosprayCheckBox", ControlType.Check, .Haemospray)

                '### Marking
                SetValue("MarkingCheckBox", ControlType.Check, .Marking)
                If .Marking Then
                    SetValue("MarkingTypeComboBox", ControlType.Combo, .MarkingType)
                    SetValue("MarkedQtyNumericTextBox", ControlType.Numeric, .MarkedQuantity)

                    '### MH added on 19 Oct 2021
                    SetValue("chkTattooLocationDistal", ControlType.Check, .TattooLocationDistal)
                    SetValue("chkTattooLocationProximal", ControlType.Check, .TattooLocationProximal)

                End If

                '### Clip
                SetValue("ClipCheckBox", ControlType.Check, .Clip)
                If .Clip Then
                    SetValue("ClipRadNumericTextBox", ControlType.Numeric, .ClipNum)
                    SetValue("ClipSuccessfulRadNumericTextBox", ControlType.Numeric, .ClipNumSuccess)
                End If


                '### Endo Clot
                SetValue("EndoClotCheckBox", ControlType.Check, .EndoClot)

                SetValue("ColonicDecompressionCheckBox", ControlType.Check, .ColonicDecompression)
                SetValue("FlatusTubeInsertionCheckBox", ControlType.Check, .FlatusTubeInsertion)
                SetValue("PancolonicDyeSprayCheckBox", ControlType.Check, .PancolonicDyeSpray)
                SetValue("BougieDilationCheckBox", ControlType.Check, .BougieDilation)
                SetValue("DiverticulotomyCheckBox", ControlType.Check, .Diverticulotomy)
                SetValue("GastricBalloonInsertionCheckBox", ControlType.Check, .GastricBalloonInsertion)
                'SetValue("EndoscopicResectionCheckBox", ControlType.Check, .EndoscopicResection)

                If .FineNeedleAspiration Then
                    SetValue("FineNeedleAspirationCheckBox", ControlType.Check, .FineNeedleAspiration)
                    SetValue("FineNeedleTypeRadioButtonList", ControlType.RadioButton, .FineNeedleAspirationType)

                    SetValue("FineNeedleAspirationPerformedRadNumericTextBox", ControlType.Numeric, .FNAPerformed)
                    SetValue("FineNeedleAspirationSuccessfulRadNumericTextBox", ControlType.Numeric, .FNASuccessful)
                    SetValue("FineNeedleAspirationRetreivedRadNumericTextBox", ControlType.Numeric, .FNARetreived)

                End If

                SetValue("FineNeedleBiopsyCheckBox", ControlType.Check, .FineNeedleBiopsy)
                If .FineNeedleBiopsy Then
                    SetValue("FineNeedleBiopsyPerformedRadNumericTextBox", ControlType.Numeric, .FNBPerformed)
                    SetValue("FineNeedleBiopsySuccessfulRadNumericTextBox", ControlType.Numeric, .FNBSuccessful)
                    SetValue("FineNeedleBiopsyRetreivedRadNumericTextBox", ControlType.Numeric, .FNBRetreived)
                End If
                If .BicapElectro Then
                    SetValue("BicapElectroTypeComboBox", ControlType.Combo, .BicapElectroType)

                End If
                '### Other
                SetValue("OtherTextBox", ControlType.Text, .Other)


                'Dim StentCheckBox = DirectCast(panTherapeuticsFormView.FindControl("StentInsertionCheckBox"), CheckBox)
                'Dim OesophagealCheckBox = DirectCast(panTherapeuticsFormView.FindControl("OesophagealDilatationCheckBox"), CheckBox)
                'If StentCheckBox IsNot Nothing AndAlso OesophagealCheckBox IsNot Nothing AndAlso (OesophagealCheckBox.Checked Or StentCheckBox.Checked) Then
                If .OesophagealDilatation Or .StentInsertion Then
                    OesoDilNilByMouthCheckBox.Checked = .OesoDilNilByMouth
                    OesoDilNilByMouthHrsRadNumericTextBox.Text = .OesoDilNilByMouthHrs
                    OesoDilWarmFluidsCheckBox.Checked = .OesoDilWarmFluids
                    OesoDilWarmFluidsHrsRadNumericTextBox.Text = .OesoDilWarmFluidsHrs
                    OesoDilXRayCheckBox.Checked = .OesoDilXRay
                    OesoDilXRayHrsRadNumericTextBox.Text = .OesoDilXRayHrs
                    OesoDilSoftDietCheckBox.Checked = .OesoDilSoftDiet
                    OesoDilSoftDietDaysRadNumericTextBox.Text = .OesoDilSoftDietDays
                    OesoDilMedicalReviewCheckBox.Checked = .OesoDilMedicalReview
                End If
            End With
        End If

    End Sub

    Private Sub SetValue(ByVal controlName As String, ByVal controlObjectType As ControlType, Optional ByVal value As Object = Nothing)
        If value Is Nothing Then Exit Sub
        Select Case controlObjectType
            Case ControlType.Check
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), CheckBox)
                controlObject.Checked = IIf(value IsNot Nothing, CBool(value), False)
            Case ControlType.Text
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), RadTextBox)
                controlObject.Text = IIf(value IsNot Nothing, value.ToString(), "")
            Case ControlType.Combo
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), RadComboBox)
                controlObject.SelectedValue = IIf(value IsNot Nothing, CInt(value), False)
            Case ControlType.Numeric
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), RadNumericTextBox)
                controlObject.Text = IIf(value IsNot Nothing, value, "")
            Case ControlType.RadioButton
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), RadioButtonList)
                If TypeOf value Is Boolean Then
                    controlObject.SelectedValue = IIf(value = True, 1, 0)
                Else
                    controlObject.SelectedValue = CInt(value)
                End If
        End Select
    End Sub

    Protected Sub SaveAndCloseWindow()

    End Sub

    Protected Sub SaveAndCloseYagWindow()
        ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "ExecuteMyFunction", "closeWindow1", True)
    End Sub

    Protected Sub SaveAndCloseGEJWindow()

    End Sub

    Public Sub InsertUpdateTherapeuticRecord(Optional saveAndClose As Boolean = True)
        Dim therap As New Therapeutics
        Try
            If siteId <= 0 Then
                siteId = AbnormalitiesDataAdapter.CommitEBUSite(Request.QueryString("Reg"))
            End If

            Session(Constants.SESSION_SITE_ID) = siteId
            TherapeuticRecord_FillData()

            '### 1: INSERT Scenario
            If hiddenTherapeuticId.Value <= 0 Then
                If _fieldValueFound Then
                    '### For both EE/ER- just INSERT it- when values found in the Record
                    therap.TherapeuticRecord_UGI_Save(UGI_Record, Therapeutics.SaveAs.InsertNew, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                    hiddenTherapeuticId.Value = UGI_Record.Id
                End If
            Else  '### 2: Update Scenario
                'If _fieldValueFound Then
                '    '### For both EE/ER- just UPDATE it- when values found in the Record
                '    therap.TherapeuticRecord_UGI_Save(UGI_Record, Therapeutics.SaveAs.Update, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                'Else
                '    '### DELETE. 
                '    therap.TherapeuticRecord_Delete("OGD", UGI_Record.Id, UGI_Record.SiteId)
                'End If
                therap.TherapeuticRecord_UGI_Save(UGI_Record, Therapeutics.SaveAs.Update, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                If Not _fieldValueFound Then
                    therap.TherapeuticRecord_Delete("OGD", UGI_Record.Id, UGI_Record.SiteId)
                End If
            End If

            'save polyp details
            If UGI_Record.Polypectomy Then
                If Session("CommonPolypDetails") IsNot Nothing Then
                    Using connection As New SqlClient.SqlConnection(DataAccess.ConnectionStr)
                        DataAdapter.SavePolypsData(CType(Session("CommonPolypDetails"), List(Of SitePolyps)), siteId)
                    End Using
                End If
            Else
                'delete polyps for this site
                DataAdapter.DeletePolypData(siteId)
            End If

            'save individual performed/sucessful/retreived

            If saveAndClose Then
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()

            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setTheraputicsProcedureAfterSave();", True)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("OGDTherapeuticProcedures.InsertUpdateTherapeuticRecord: Error occurred while saving Broncho Therapeutics.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Sub TherapeuticRecord_FillData()
        _fieldValueFound = False '### Initiate with 'False'. When any CheckBox is found 'Checked' in GetValue()- then it will be 'True' from there!


        If hiddenTherapeuticId.Value > 0 Then
            Dim therap As New Therapeutics
            UGI_Record = therap.TherapeuticRecord_UGI_FindBySite(hiddenSiteId.Value())
        Else
            UGI_Record = New ERS.Data.ERS_UpperGITherapeutics
            UGI_Record.SiteId = hiddenSiteId.Value

        End If
        If optIndependent.Selected Then
            UGI_Record.EndoRole = 1
            UGI_Record.CarriedOutRole = 1
        ElseIf optAssisted.Selected Then
            UGI_Record.EndoRole = 3
            UGI_Record.CarriedOutRole = 2
        ElseIf optObserved.Selected Then
            UGI_Record.EndoRole = 2
            UGI_Record.CarriedOutRole = 2
        ElseIf optTrainerCompleted.Selected Then
            UGI_Record.EndoRole = 5
            UGI_Record.CarriedOutRole = 1
        ElseIf optIndependentEndo2.Selected Then
            UGI_Record.EndoRole = 4
            UGI_Record.CarriedOutRole = 2
        End If


        With UGI_Record
            .None = chkNoneCheckBox.Checked
            .Other = IIf(String.IsNullOrWhiteSpace(OtherTextBox.Text), Nothing, OtherTextBox.Text)
            If Not String.IsNullOrWhiteSpace(OtherTextBox.Text) Then _fieldValueFound = True
            '.PolypectomyRemoval = CByte(GetValue("PolypectomyRemovalRadioButtonList", ControlType.RadioButton))
            '.PolypectomyRemovalType = CByte(GetValue("PolypectomyRemovalTypeRadioButtonList", ControlType.RadioButton))
            .CorrectPEGPlacement = CByte(GetValue("CorrectPEGPlacementRadioButtonList", ControlType.RadioButton))

            .YAGLaser = GetValue("YagLaserCheckBox", ControlType.Check)
            If .YAGLaser Then
                .OesoYAGNilByMouth = CBool(YAGDilNilByMouthCheckBox.Checked)
                .OesoYAGNilByMouthHrs = Utilities.GetNumericTextBoxValue(YAGDilNilByMouthHrsRadNumericTextBox)
                .OesoYAGSoftDiet = CBool(YagDilSoftDietCheckBox.Checked)
                .OesoYAGSoftDietDays = Utilities.GetNumericTextBoxValue(YagDilSoftDietDaysRadNumericTextBox)
                .OesoYAGWarmFluids = CBool(YagDilWarmFluidsCheckBox.Checked)
                .OesoYAGWarmFluidsHrs = Utilities.GetNumericTextBoxValue(YagDilWarmFluidsHrsRadNumericTextBox)
                .OesoYAGMedicalReview = CBool(YagDilMedicalReviewCheckBox.Checked)

                .YAGLaserWatts = GetValue("YagLaserWattsNumericTextBox", ControlType.Numeric)
                .YAGLaserPulses = GetValue("YagLaserPulsesNumericTextBox", ControlType.Numeric)
                .YAGLaserSecs = Convert.ToDecimal(GetValue("YagLaserSecsNumericTextBox", ControlType.Numeric))
                .YAGLaserKJ = Convert.ToDecimal(GetValue("YagLaserKJNumericTextBox", ControlType.Numeric))

            Else
                .OesoYAGNilByMouth = False
                .OesoYAGNilByMouthHrs = 0
                .OesoYAGSoftDiet = False
                .OesoYAGSoftDietDays = 0
                .OesoYAGWarmFluids = False
                .OesoYAGWarmFluidsHrs = 0
                .OesoYAGMedicalReview = False

                .YAGLaserWatts = Nothing
                .YAGLaserPulses = Nothing
                .YAGLaserSecs = Nothing
                .YAGLaserKJ = Nothing
            End If

            .ArgonBeamDiathermy = CBool(GetValue("ArgonBeamDiathermyCheckBox", ControlType.Check))
            If .ArgonBeamDiathermy Then
                .ArgonBeamDiathermyWatts = GetValue("ArgonBeamDiathermyWattsNumericTextBox", ControlType.Numeric)
                .ArgonBeamDiathermyPulses = GetValue("ArgonBeamDiathermyPulsesNumericTextBox", ControlType.Numeric)
                .ArgonBeamDiathermySecs = Convert.ToDecimal(GetValue("ArgonBeamDiathermySecsNumericTextBox", ControlType.Numeric))
                .ArgonBeamDiathermyKJ = Convert.ToDecimal(GetValue("ArgonBeamDiathermyKJNumericTextBox", ControlType.Numeric))
            Else
                .ArgonBeamDiathermyWatts = Nothing
                .ArgonBeamDiathermyPulses = Nothing
                .ArgonBeamDiathermySecs = Nothing
                .ArgonBeamDiathermyKJ = Nothing
            End If

            '#### Polypectomy Removal
            .Polypectomy = CBool(GetValue("PolypectomyCheckBox", ControlType.Check))
            If .Polypectomy Then
                .PolypectomyRemoval = CByte(GetValue("PolypectomyRemovalRadioButtonList", ControlType.RadioButton))
                .PolypectomyRemovalType = CByte(GetValue("PolypectomyRemovalTypeRadioButtonList", ControlType.RadioButton))
                .PolypectomyQty = CInt(GetValue("PolypectomyQtyRadNumericTextBox", ControlType.Numeric))

                'save polyp details
                Dim sitePolypDetails As List(Of SitePolyps) = If(Session("CommonPolypDetails"), New List(Of SitePolyps))

                If sitePolypDetails.Count > 0 Then
                    'set polyp type id and resave sessiono data ready for the DB save
                    sitePolypDetails.ForEach(Sub(x) x.PolypTypeId = CInt(GetValue("PolypTypeRadComboBox", ControlType.Combo)))
                    Session("CommonPolypDetails") = sitePolypDetails
                End If
            End If

            '### Band Ligation
            .BandingPiles = CBool(GetValue("BandingPilesCheckBox", ControlType.Check))
            If .BandingPiles Then
                .BandingNum = GetValue("BandingNumRadNumericTextBox", ControlType.Numeric)
            End If

            .BalloonDilation = CBool(GetValue("BalloonDilationCheckBox", ControlType.Check))
            'add by mostafiz 
            If .BalloonDilation Then
                .BalloonDilationType = CShort(GetValue("BalloonDilationTypeComboBox", ControlType.Combo))
                .BalloonDilationDiameter = GetValue("BalloonDilationDiaNumericTextBox", ControlType.Numeric)
                .BalloonDilationDiameterUnits = CByte(GetValue("BalloonDilationDiaUnitsComboBox", ControlType.Combo))

                Dim BalloonDilationTypeComboBox = DirectCast(panTherapeuticsFormView.FindControl("BalloonDilationTypeComboBox"), RadComboBox)
                If BalloonDilationTypeComboBox IsNot Nothing Then
                    If BalloonDilationTypeComboBox.SelectedValue <> "" Then

                        .BalloonDilationTypeNewItemText = BalloonDilationTypeComboBox.SelectedItem.Text
                        .BalloonDilationDiameterUnits = CByte(GetValue("BalloonDilationDiaUnitsComboBox", ControlType.Combo))
                    End If
                End If

            Else

                .BalloonDilationType = Nothing
                .BalloonDilationDiameter = Nothing
                .BalloonDilationDiameterUnits = Nothing

            End If

            'add by mostafiz 

            'End If

            .BandLigation = CBool(GetValue("BandLigationCheckBox", ControlType.Check))
            .BandLigationPerformed = GetValue("BandLigationPerformedRadNumericTextBox", ControlType.Numeric)
            .BandLigationSuccessful = GetValue("BandLigationSuccessfulRadNumericTextBox", ControlType.Numeric)

            .BotoxInjection = CBool(GetValue("BotoxInjectionCheckBox", ControlType.Check))
            .EndoloopPlacement = CBool(GetValue("EndoloopPlacementCheckBox", ControlType.Check))
            .HeatProbe = CBool(GetValue("HeatProbeCheckBox", ControlType.Check))
            .BicapElectro = CBool(GetValue("BicapElectroCheckBox", ControlType.Check))
            .ForeignBody = CBool(GetValue("ForeignBodyCheckBox", ControlType.Check))
            .HotBiopsy = CBool(GetValue("HotBiopsyCheckBox", ControlType.Check))
            'If .HotBiopsy Then
            '    .HotBiopsyPerformed = GetValue("HotBiopsyRadNumericTextBox", ControlType.Numeric)
            '    .HotBiopsySuccessful = GetValue("HotBiopsyRadNumericTextBox", ControlType.Numeric)
            '    .HotBiopsyRetreived = GetValue("HotBiopsyRadNumericTextBox", ControlType.Numeric)
            'End If

            .EMR = CBool(GetValue("EmrCheckBox", ControlType.Check))
            If .EMR Then
                .EMRType = CByte(GetValue("EmrTypeRadioButtonList", ControlType.RadioButton))
                .EMRFluid = GetValue("EmrFluidComboBox", ControlType.Combo)
                .EMRFluidVolume = GetValue("EmrFluidVolNumericTextBox", ControlType.Numeric)
                .EMRFluidNewItemText = GetValue("EmrFluidComboBox", ControlType.Combo, getDropDownText:=True)
            Else
                .EMRType = Nothing
                .EMRFluid = Nothing
                .EMRFluidVolume = Nothing
            End If

            '### Sigmoidopexy
            .Sigmoidopexy = CBool(GetValue("SigmoidopexyCheckBox", ControlType.Check))
            If .Sigmoidopexy Then
                .SigmoidopexyQty = CShort(GetValue("SigmoidopexyQtyNumericBox", ControlType.Numeric))

                If SigmoidopexyMakeComboBox.Text <> "" AndAlso SigmoidopexyMakeComboBox.SelectedValue = -99 Then
                    Dim da As New DataAccess
                    Dim newId = da.InsertListItem("Sigmoidopexy make", SigmoidopexyMakeComboBox.Text)
                    If newId > 0 Then .SigmoidopexyMake = newId
                Else
                    .SigmoidopexyMake = CInt(GetValue("SigmoidopexyMakeComboBox", ControlType.Combo))
                End If

                '.SigmoidopexyMake = CShort(GetValue("SigmoidopexyMakeComboBox", ControlType.Combo))
                .SigmoidopexyFluidsDays = CShort(GetValue("SigmoidopexyFluidDaysRadNumeric", ControlType.Numeric))
                .SigmoidopexyAntibioticsDays = CShort(GetValue("SigmoidopexyAtibioticDaysRadNumeric", ControlType.Numeric))
            End If

            .RFA = CBool(GetValue("RFACheckBox", ControlType.Check))
            If .RFA Then
                .RFAType = CByte(GetValue("RfaTypeRadioButtonList", ControlType.RadioButton))
                .RFATreatmentFrom = GetValue("RFATreatmentFromNumericTextBox", ControlType.Numeric)
                .RFATreatmentTo = GetValue("RFATreatmentToNumericTextBox", ControlType.Numeric)
                .RFAEnergyDel = GetValue("RFAEnergyDeliveredNumericTextBox", ControlType.Numeric)
                .RFANumSegTreated = GetValue("RFASegmentsTreatedNumericTextBox", ControlType.Numeric)
                .RFANumTimesSegTreated = GetValue("NoTimesSegmentTreatedNumericTextBox", ControlType.Numeric)
            Else
                .RFAType = Nothing
                .RFATreatmentFrom = Nothing
                .RFATreatmentTo = Nothing
                .RFAEnergyDel = Nothing
                .RFANumSegTreated = Nothing
                .RFANumTimesSegTreated = Nothing
            End If

            '### pH probe insertion
            .pHProbeInsert = CBool(GetValue("PH_ProbeInsertionCheckBox", ControlType.Check))
            If .pHProbeInsert Then
                .pHProbeInsertAt = GetValue("ProbeInsertedAtNumericTextBox", ControlType.Numeric)
                .pHProbeInsertChk = CBool(GetValue("EndoscopicCheck", ControlType.Check))
                .pHProbeInsertChkTopTo = GetValue("TopOfProbeNumericTextBox", ControlType.Numeric)
            Else
                .pHProbeInsertAt = Nothing
                .pHProbeInsertChk = Nothing
                .pHProbeInsertChkTopTo = Nothing
            End If

            .Injection = CBool(GetValue("InjectionTherapyCheckBox", ControlType.Check))
            If .Injection Then
                .InjectionType = GetValue("InjectionTypeComboBox", ControlType.Combo)
                .InjectionTypeNewItemText = GetValue("InjectionTypeComboBox", ControlType.Combo, getDropDownText:=True)
                .InjectionNumber = GetValue("InjectionNumberNumericTextBox", ControlType.Numeric)
                .InjectionVolume = GetValue("InjectionVolumeNumericTextBox", ControlType.Numeric)
            Else
                .InjectionType = Nothing
                .InjectionNumber = Nothing
                .InjectionVolume = Nothing
            End If

            .Homeostasis = CBool(GetValue("HomeostasisCheckBox", ControlType.Check))
            If .Homeostasis Then
                .HomeostasisType = GetValue("HomeostasisComboBox", ControlType.Combo)
                .HomeostasisTypeNewItemText = GetValue("HomeostasisComboBox", ControlType.Combo, getDropDownText:=True)
            Else
                .HomeostasisType = Nothing
            End If

            .StentRemoval = CBool(GetValue("StentRemovalCheckBox", ControlType.Check))
            If .StentRemoval Then
                .StentRemovalTechnique = GetValue("StentRemovalTechniqueComboBox", ControlType.Combo)
                .StentRemovalTechniqueNewItemText = GetValue("StentRemovalTechniqueComboBox", ControlType.Combo, getDropDownText:=True)
            Else
                .StentRemovalTechnique = Nothing
            End If

            .GastrostomyInsertion = GetValue("GastrostomyInsertionCheckBox", ControlType.Check)
            If .GastrostomyInsertion Then
                '
                .GastrostomyInsertionSize = CDec(GetValue("GastrostomyInsertionSizeNumericTextBox", ControlType.Numeric))
                .GastrostomyInsertionUnits = CByte(GetValue("GastrostomyInsertionUnitsComboBox", ControlType.Combo))

                If GastrostomyInsertionTypeComboBox.Text <> "" AndAlso GastrostomyInsertionTypeComboBox.SelectedValue = -99 Then
                    Dim da As New DataAccess
                    Dim newId = da.InsertListItem("Gastrostomy PEG type", GastrostomyInsertionTypeComboBox.Text)
                    If newId > 0 Then .GastrostomyInsertionType = newId
                Else
                    .GastrostomyInsertionType = CInt(GetValue("GastrostomyInsertionTypeComboBox", ControlType.Combo))
                End If

                If PEGOutcomeComboBox.Text <> "" AndAlso PEGOutcomeComboBox.SelectedValue = -99 Then
                    Dim da As New DataAccess
                    Dim newId = da.InsertListItem("Gastrostomy PEG type", PEGOutcomeComboBox.Text)
                    If newId > 0 Then .GastrostomyPEGOutcome = newId
                Else
                    .GastrostomyPEGOutcome = CInt(GetValue("PEGOutcomeComboBox", ControlType.Combo))
                End If

                .GastrostomyInsertionTypeNewItemText = GetValue("GastrostomyInsertionTypeComboBox", ControlType.Combo, getDropDownText:=True)
                .GastrostomyInsertionBatchNo = (GetValue("GastrostomyInsertionBatchNoTextBox", ControlType.Text))
                .CorrectPEGPlacement = CByte(GetValue("CorrectPEGPlacementRadioButtonList", ControlType.RadioButton))
                .PEGPlacementFailureReason = GetValue("PEGPlacementFailureReasonTextBox", ControlType.Text)

                .NilByMouth = CBool(NilByMouthCheckBox.Checked)
                .NilByMouthHrs = Utilities.GetNumericTextBoxValue(NilByMouthHrsNumericTextBox)
                .NilByProc = CBool(NilByProcCheckBox.Checked)
                .NilByProcHrs = Utilities.GetNumericTextBoxValue(NilByProcHrsNumericTextBox)
                .AttachmentToWard = CBool(AttachmentToWardCheckBox.Checked)
                .FlangePosition = Utilities.GetNumericTextBoxValue(FlangePositionNumericTextBox)
            Else
                .GastrostomyInsertionSize = Nothing
                .GastrostomyInsertionUnits = Nothing
                .GastrostomyInsertionType = Nothing
                .GastrostomyInsertionBatchNo = Nothing
                .CorrectPEGPlacement = Nothing
                .PEGPlacementFailureReason = Nothing

                .NilByMouth = False
                .NilByMouthHrs = 0
                .NilByProc = False
                .NilByProcHrs = 0
                .AttachmentToWard = False
                .FlangePosition = 0
            End If

            .NGNJTubeInsertion = GetValue("NGNJTubeCheckBox", ControlType.Check)
            If .NGNJTubeInsertion Then
                .NGNJTubeNostril = CByte(GetValue("NGNJTubeInsertionRadioButtonList", ControlType.RadioButton))
                .NGNJTubeLength = Utilities.GetNumericTextBoxValue(NGNJTubeInsertionLengthNumericTextBox)
                .NGNJTubeBridle = CBool(NGNJTubeInsertionBridle.Checked)
                .NGNJTubeBatch = GetValue("NGNJTubeInsertionBatchNoTextBox", ControlType.Text)
            Else
                .NGNJTubeNostril = Nothing
                .NGNJTubeLength = Nothing
                .NGNJTubeBridle = False
                .NGNJTubeBatch = Nothing
            End If

            .GastrostomyRemoval = GetValue("GastrostomyRemovalCheckBox", ControlType.Check)
            .PyloricDilatation = GetValue("PyloricDilatationChekBox", ControlType.Check)
            If .PyloricDilatation Then
                .PyloricLeadingToPerforation = CByte(GetValue("PyloricLeadingToPerforationRadioButton", ControlType.RadioButton))
            End If

            .VaricealSclerotherapy = GetValue("VaricealSclerotherapyCheckBox", ControlType.Check)
            If .VaricealSclerotherapy Then

                If VaricealScleroInjTypeComboBox.Text <> "" AndAlso VaricealScleroInjTypeComboBox.SelectedValue = -99 Then
                    Dim da As New DataAccess
                    Dim newId = da.InsertListItem("Agent Upper GI", VaricealScleroInjTypeComboBox.Text)
                    If newId > 0 Then .VaricealSclerotherapyInjectionType = newId
                Else
                    .VaricealSclerotherapyInjectionType = CInt(GetValue("VaricealScleroInjTypeComboBox", ControlType.Combo))
                End If

                .VaricealSclerotherapyInjectionVol = GetValue("VaricealScleroInjVolNumericTextBox", ControlType.Numeric)
                .VaricealSclerotherapyInjectionNum = GetValue("VaricealScleroInjNumNumericTextBox", ControlType.Numeric)
            Else
                .VaricealSclerotherapyInjectionType = Nothing
                .VaricealSclerotherapyInjectionVol = Nothing
                .VaricealSclerotherapyInjectionNum = Nothing
            End If

            .VaricealBanding = CBool(GetValue("VaricealBandingCheckBox", ControlType.Check))
            .VaricealBandingNum = IIf(.VaricealBanding, GetValue("VaricealBandingNumNumericTextBox", ControlType.Numeric), Nothing)

            .VaricealClip = GetValue("VaricealClipCheckBox", ControlType.Check)

            .EMR = CBool(GetValue("EmrCheckBox", ControlType.Check))
            If .EMR Then
                .EMRType = CByte(GetValue("EmrTypeRadioButtonList", ControlType.RadioButton))
                .EMRFluid = GetValue("EmrFluidComboBox", ControlType.Combo)
                .EMRFluidVolume = GetValue("EmrFluidVolNumericTextBox", ControlType.Numeric)
                .EMRFluidNewItemText = GetValue("EmrFluidComboBox", ControlType.Combo, getDropDownText:=True)
            Else
                .EMRType = Nothing
                .EMRFluid = Nothing
                .EMRFluidVolume = Nothing
            End If

            .OesophagealDilatation = GetValue("OesophagealDilatationCheckBox", ControlType.Check)
            If .OesophagealDilatation Then
                '.DilatedTo = GetValue("RadNumericTextBox1", ControlType.Numeric)
                'Added by rony tfs-4085
                .DilatedTo = Convert.ToDecimal(GetValue("DilatedToTextBox", ControlType.Numeric))
                .DilatationUnits = CByte(GetValue("DilatationUnitsComboBox", ControlType.Combo))

                If DilatorTypeComboBox.Text <> "" AndAlso DilatorTypeComboBox.SelectedValue = -99 Then
                    Dim da As New DataAccess
                    Dim newId = da.InsertListItem("Oesophageal dilator", DilatorTypeComboBox.Text)
                    If newId > 0 Then .DilatorType = newId
                Else
                    .DilatorType = CInt(GetValue("DilatorTypeComboBox", ControlType.Combo))
                End If

                .DilatorTypeNewItemText = GetValue("DilatorTypeComboBox", ControlType.Combo, getDropDownText:=True)
                .DilatorScopePass = CBool(GetValue("ScopePassCheckBox", ControlType.Check))
                'added by rony tfs-3833 
                .DilatationPerforation = CBool(GetValue("PerforationRadioButtonList", ControlType.RadioButton))
            Else
                .DilatedTo = Nothing
                .DilatationUnits = Nothing
                .DilatorType = Nothing
                .DilatorScopePass = Nothing
                'added by rony tfs-3833 
                .DilatationPerforation = Nothing
            End If

            .StentInsertion = CBool(GetValue("StentInsertionCheckBox", ControlType.Check))
            If .StentInsertion Then
                .StentInsertionQty = GetValue("StentInsertionQtyNumericTextBox", ControlType.Numeric)
                .StentInsertionType = CShort(GetValue("StentInsertionTypeComboBox", ControlType.Combo))
                .StentInsertionLength = GetValue("StentInsertionLengthNumericTextBox", ControlType.Numeric)
                .StentInsertionDiameter = GetValue("StentInsertionDiaNumericTextBox", ControlType.Numeric)
                .StentInsertionDiameterUnits = CByte(GetValue("StentInsertionDiaUnitsComboBox", ControlType.Combo))
                .StentInsertionBatchNo = GetValue("StentInsertionBatchNoTextBox", ControlType.Text)
                .MetalicStent = CBool(GetValue("MetalicStentCheckBox", ControlType.Check))
                Dim StentInsertionTypeComboBox = DirectCast(panTherapeuticsFormView.FindControl("StentInsertionTypeComboBox"), RadComboBox)
                If StentInsertionTypeComboBox IsNot Nothing Then
                    If StentInsertionTypeComboBox.SelectedValue <> "" Then

                        .StentInsertionTypeNewItemText = IIf(sArea = "Oesophagus",
                                                                       StentInsertionTypeComboBox.SelectedItem.Text & "|Oesophagus|",
                                                                       StentInsertionTypeComboBox.SelectedItem.Text)
                        .StentInsertionDiameterUnits = CByte(GetValue("StentInsertionDiaUnitsComboBox", ControlType.Combo))
                    End If
                End If

                If Not String.IsNullOrWhiteSpace(StentCorrectPlacementRadioButton.SelectedValue) Then
                    .CorrectStentPlacement = StentCorrectPlacementRadioButton.SelectedValue
                    If Not CBool(StentCorrectPlacementRadioButton.SelectedValue) And Not String.IsNullOrWhiteSpace(FailedPlacementReasonsRadioButtonList.SelectedValue) Then
                        .StentPlacementFailureReason = FailedPlacementReasonsRadioButtonList.SelectedValue
                    Else
                        .StentPlacementFailureReason = Nothing
                    End If
                End If
            Else
                .StentInsertionQty = Nothing
                .StentInsertionType = Nothing
                .StentInsertionLength = Nothing
                .StentInsertionDiameter = Nothing
                .StentInsertionDiameterUnits = Nothing
                .StentInsertionBatchNo = Nothing
            End If

            .Haemospray = CBool(GetValue("HaemosprayCheckBox", ControlType.Check))

            .Marking = CBool(GetValue("MarkingCheckBox", ControlType.Check))

            'MH added on 19 Oct 2021
            'MH added on 19 Oct 2021
            .TattooLocationDistal = GetValue("chkTattooLocationDistal", ControlType.Check)
            .TattooLocationProximal = GetValue("chkTattooLocationProximal", ControlType.Check)

            If .Marking Then
                .MarkingType = GetValue("MarkingTypeComboBox", ControlType.Combo)
                .MarkingTypeNewItemText = GetValue("MarkingTypeComboBox", ControlType.Combo, getDropDownText:=True)
                .MarkedQuantity = GetValue("MarkedQtyNumericTextBox", ControlType.Numeric)
            Else
                .MarkingType = Nothing
                .MarkedQuantity = Nothing
            End If

            .Clip = GetValue("ClipCheckBox", ControlType.Check)
            .ClipNum = IIf(.Clip, GetValue("ClipRadNumericTextBox", ControlType.Numeric), Nothing)
            .ClipNumSuccess = IIf(.Clip, GetValue("ClipSuccessfulRadNumericTextBox", ControlType.Numeric), Nothing)

            .EndoClot = GetValue("EndoClotCheckBox", ControlType.Check)
            .ColonicDecompression = GetValue("ColonicDecompressionCheckBox", ControlType.Check)
            .FlatusTubeInsertion = GetValue("FlatusTubeInsertionCheckBox", ControlType.Check)
            .PancolonicDyeSpray = GetValue("PancolonicDyeSprayCheckBox", ControlType.Check)
            .BougieDilation = GetValue("BougieDilationCheckBox", ControlType.Check)
            .GastricBalloonInsertion = GetValue("GastricBalloonInsertionCheckBox", ControlType.Check)
            .Diverticulotomy = GetValue("DiverticulotomyCheckBox", ControlType.Check)
            '.EndoscopicResection = GetValue("EndoscopicResectionCheckBox", ControlType.Check)

            .FineNeedleAspiration = GetValue("FineNeedleAspirationCheckBox", ControlType.Check)
            If .FineNeedleAspiration Then
                .FineNeedleAspirationType = GetValue("FineNeedleTypeRadioButtonList", ControlType.RadioButton)
                .FNAPerformed = GetValue("FineNeedleAspirationPerformedRadNumericTextBox", ControlType.Numeric)
                .FNASuccessful = GetValue("FineNeedleAspirationSuccessfulRadNumericTextBox", ControlType.Numeric)
                .FNARetreived = GetValue("FineNeedleAspirationRetreivedRadNumericTextBox", ControlType.Numeric)
            End If

            .FineNeedleBiopsy = GetValue("FineNeedleBiopsyCheckBox", ControlType.Check)
            If .FineNeedleBiopsy Then
                .FNBPerformed = GetValue("FineNeedleBiopsyPerformedRadNumericTextBox", ControlType.Numeric)
                .FNBSuccessful = GetValue("FineNeedleBiopsySuccessfulRadNumericTextBox", ControlType.Numeric)
                .FNBRetreived = GetValue("FineNeedleBiopsyRetreivedRadNumericTextBox", ControlType.Numeric)
            End If

            Dim StentCheckBox = DirectCast(panTherapeuticsFormView.FindControl("StentInsertionCheckBox"), CheckBox)
            Dim OesophagealCheckBox = DirectCast(panTherapeuticsFormView.FindControl("OesophagealDilatationCheckBox"), CheckBox)

            If StentCheckBox IsNot Nothing AndAlso OesophagealCheckBox IsNot Nothing AndAlso (OesophagealCheckBox.Checked Or StentCheckBox.Checked) Then
                .OesoDilNilByMouth = CBool(OesoDilNilByMouthCheckBox.Checked)
                .OesoDilNilByMouthHrs = CInt(OesoDilNilByMouthHrsRadNumericTextBox.Value)
                .OesoDilXRay = CBool(OesoDilXRayCheckBox.Checked)
                .OesoDilXRayHrs = CInt(OesoDilXRayHrsRadNumericTextBox.Value)
                .OesoDilSoftDiet = CBool(OesoDilSoftDietCheckBox.Checked)
                .OesoDilSoftDietDays = CInt(OesoDilSoftDietDaysRadNumericTextBox.Value)
                .OesoDilWarmFluids = CBool(OesoDilWarmFluidsCheckBox.Checked)
                .OesoDilWarmFluidsHrs = CInt(OesoDilWarmFluidsHrsRadNumericTextBox.Value)
                .OesoDilMedicalReview = CBool(OesoDilMedicalReviewCheckBox.Checked)
            Else
                .OesoDilNilByMouth = False
                .OesoDilNilByMouthHrs = 0
                .OesoDilXRay = False
                .OesoDilXRayHrs = 0
                .OesoDilSoftDiet = False
                .OesoDilSoftDietDays = 0
                .OesoDilWarmFluids = False
                .OesoDilWarmFluidsHrs = 0
                .OesoDilMedicalReview = False
            End If

            '### Mahfuz added Diathermy, Coil, Valve, Cryotherapy, Photodynamic Therapy on 30 Jul 2021
            .Diathermy = GetValue("chkDiathermy", ControlType.Check)
            If .Diathermy Then
                .DiathermyWatt = IIf(.Diathermy, GetValue("DiathermyWatt", ControlType.Numeric), Nothing)
            Else
                .DiathermyWatt = Nothing
            End If

            '### Coil
            .Coil = GetValue("chkCoil", ControlType.Check)
            If .Coil Then
                .CoilQty = IIf(.Coil, GetValue("CoilQty", ControlType.Numeric), Nothing)

                .CoilType = CInt(GetValue("cboCoilType", ControlType.Combo))
            Else
                .CoilQty = Nothing
                .CoilType = Nothing
            End If

            '### Valve
            .Valve = GetValue("chkValve", ControlType.Check)
            If .Valve Then
                .ValveQty = IIf(.Valve, GetValue("ValveQty", ControlType.Numeric), Nothing)
                .ValveType = CInt(GetValue("cboValveType", ControlType.Combo))
            Else
                .ValveQty = Nothing
                .ValveType = Nothing
            End If

            '### Cryotherapy
            .Cryotherapy = GetValue("chkCryotherapy", ControlType.Check)

            '### PhotoDynamicTherapy
            .PhotoDynamicTherapy = GetValue("chkPhotoDynamicTherapy", ControlType.Check)
            If .BicapElectro Then
                Dim BicapElectroTypeComboBox = DirectCast(panTherapeuticsFormView.FindControl("BicapElectroTypeComboBox"), RadComboBox)
                If BicapElectroTypeComboBox.Text <> "" AndAlso BicapElectroTypeComboBox.SelectedValue = -99 Then
                    Dim da As New DataAccess
                    Dim newId = da.InsertListItem("Bicap electrocautery", BicapElectroTypeComboBox.Text)
                    If newId > 0 Then .BicapElectroType = newId

                ElseIf String.IsNullOrEmpty(BicapElectroTypeComboBox.Text) Then
                    .BicapElectroType = Nothing
                Else
                    .BicapElectroType = CInt(GetValue("BicapElectroTypeComboBox", ControlType.Combo))
                End If
            End If
        End With

    End Sub


    Private Function GetValue(ByVal controlName As String, ByVal controlObjectType As ControlType, Optional ByVal getDropDownText As Boolean = False) As Object
        Select Case controlObjectType
            Case ControlType.Check
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), CheckBox)
                If controlObject IsNot Nothing Then
                    _fieldValueFound = controlObject.Checked Or _fieldValueFound
                    Return controlObject.Checked
                Else
                    Return False
                End If
            Case ControlType.Text
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), RadTextBox)
                If controlObject IsNot Nothing Then
                    'If controlObject.Text.Length > 0 Then _fieldValueFound = True
                    Return controlObject.Text
                Else
                    Return ""
                End If
            Case ControlType.Combo
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), RadComboBox)
                If controlObject IsNot Nothing AndAlso controlObject.SelectedIndex > 1 And getDropDownText Then
                    Return controlObject.SelectedItem.Text
                ElseIf controlObject IsNot Nothing AndAlso controlObject.SelectedIndex > 0 Then
                    Return Convert.ToInt32(controlObject.SelectedValue)
                Else
                    Return 0
                End If
            Case ControlType.Numeric
                Dim decimalValue As Decimal
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), RadNumericTextBox)
                If controlObject IsNot Nothing AndAlso controlObject.Value IsNot Nothing AndAlso controlObject.Text <> "" Then
                    '### Sometimes we do get Decimal Values.. Need to treat those shit with respect!
                    If Integer.TryParse(controlObject.Value.ToString(), decimalValue) Then
                        Return Convert.ToInt32(controlObject.Value)
                    ElseIf Decimal.TryParse(controlObject.Value.ToString(), decimalValue) Then
                        Return Convert.ToDecimal(controlObject.Value)
                    Else
                        Return 0
                    End If
                Else
                    Return 0 'should never happen
                End If
            Case ControlType.RadioButton
                Dim controlObject = DirectCast(panTherapeuticsFormView.FindControl(controlName), RadioButtonList)
                If controlObject IsNot Nothing AndAlso controlObject.SelectedItem IsNot Nothing AndAlso controlObject.SelectedItem.Text <> "" Then
                    Return Convert.ToInt32(controlObject.SelectedValue)
                Else
                    Return 0
                End If
            Case Else
                Return Nothing ' should never happen
        End Select
    End Function

    Private Sub SetTabOptions(tabOption As String, Optional independentOnly As Boolean = False)
        Select Case tabOption
            Case "Independent"
                If independentOnly Then
                    optAssisted.Enabled = False
                    optObserved.Enabled = False
                    optTrainerCompleted.Enabled = False
                End If
                optIndependent.Enabled = True
                optIndependent.Selected = True
            Case "Assisted"
                optAssisted.Enabled = True
                optObserved.Enabled = True
                optIndependent.Selected = False
                optAssisted.Selected = True
                optTrainerCompleted.Selected = False
            Case "Observed"
                optAssisted.Enabled = True
                optObserved.Enabled = True
                optIndependent.Selected = False
                optObserved.Selected = True
                optTrainerCompleted.Selected = False
            Case "Completed"
                optAssisted.Enabled = True
                optObserved.Enabled = True
                optIndependent.Selected = False
                optObserved.Selected = True
                optTrainerCompleted.Selected = True
        End Select
    End Sub



    ''' <summary>
    ''' This will load the Therapeutic Records for Both TrainEE and TrainER
    ''' And will feed the values to the UserControl respectively!
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub Initiate_User_Control_TherapeuticRecord()
        'Dim therap As New Therapeutics
        'Dim endoscopistRecords As ERS.Data.EndoscopistSearch_Result

        'endoscopistRecords = therap.GetTherapeuticRecords(siteId)


        Dim da As New OtherData
        Dim dtTr As DataTable = da.GetTrainerTraineeEndo(CInt(Session(Constants.SESSION_PROCEDURE_ID)), siteId)
        Dim drEndoscopist As DataRow = dtTr.Rows(0)

        ''trainEE_Exist = IIf(IsDBNull(dtTr.Rows(0).Item("TraineeEndoscopist")), False, True)

        hiddenTherapeuticId.Value = CInt(drEndoscopist("TherapRecordId"))
        If (IIf(IsDBNull(dtTr.Rows(0).Item("TraineeEndoscopist")), False, True)) AndAlso Session("EndoRole") = 1 Then
            ' 2nd endoscopist in independent role
            optIndependentEndo2.Attributes.CssStyle.Add("visibility", "visible")
            optObserved.Attributes.CssStyle.Add("visibility", "hidden")
            optAssisted.Attributes.CssStyle.Add("visibility", "hidden")
            optTrainerCompleted.Attributes.CssStyle.Add("visibility", "hidden")
            optTrainerCompleted.Attributes.CssStyle.Add("visibility", "hidden")
            optIndependent.Text = drEndoscopist("TrainerEndoscopist")
            optIndependent.Selected = True
            optIndependentEndo2.Text = drEndoscopist("TraineeEndoscopist")
        Else
            If (IIf(IsDBNull(dtTr.Rows(0).Item("TraineeEndoscopist")), False, True)) Then
                ' trainer/trainee
                Select Case CInt(drEndoscopist("EndoRole"))
                    Case 1
                        SetTabOptions("Independent")
                    Case 2
                        SetTabOptions("Observed")
                    Case 3
                        SetTabOptions("Assisted")
                    Case 5
                        SetTabOptions("Completed")
                    Case 0
                        If String.IsNullOrEmpty(drEndoscopist("TraineeEndoscopist")) Then
                            SetTabOptions("Independent", True)
                        Else
                            If Session("EndoRole") = 2 Then
                                SetTabOptions("Observed")
                            Else
                                SetTabOptions("Assisted")
                            End If
                        End If
                End Select
            Else
                ' Only 1 endoscopist, so must be independent only
                optObserved.Attributes.CssStyle.Add("visibility", "hidden")
                optAssisted.Attributes.CssStyle.Add("visibility", "hidden")
                optTrainerCompleted.Attributes.CssStyle.Add("visibility", "hidden")
                optIndependent.Text = drEndoscopist("TrainerEndoscopist")
                optIndependent.Selected = True
            End If
        End If

        'Dim therapeuticCommonData As TherapeuticCommonData
        'TherapeuticCommonData = BusinessLogic.Get_CommonTherapeuticData(siteId, BusinessLogic.ProcedureType.OGD)
        'OtherTextBox.Text = Server.HtmlDecode(therapeuticCommonData.OtherText)
        'chkNoneCheckBox.Checked = therapeuticCommonData.NoneChecked

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        If e.Argument.ToLower = "update-polyps" Then
            'If Session("CommonPolypDetails") IsNot Nothing Then
            '    PolypectomyQtyRadNumericTextBox.Value = CType(Session("CommonPolypDetails"), List(Of SitePolyps)).Count
            'End If
        Else
            SaveRecord(False)
        End If
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        InsertUpdateTherapeuticRecord(saveAndClose)
    End Sub

    Protected Sub YAGLaser_Load(sender As Object, e As EventArgs)

    End Sub
End Class
