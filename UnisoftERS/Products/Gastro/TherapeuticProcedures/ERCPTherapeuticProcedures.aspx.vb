Imports ERS.Data
Imports Telerik.Web.UI

Partial Class Products_Gastro_TherapeuticProcedures_ERCPTherapeuticProcedures
    Inherits SiteDetailsBase

    Public siteId As Integer
    Private sArea As String
    Private ERCP_Record As ERS.Data.ERS_ERCPTherapeutics
    Private _fieldValueFound As Boolean

    Private Enum ControlType
        Check
        Text
        RadioButton
        Numeric
        Combo
    End Enum

    Protected Sub Products_Gastro_TherapeuticProcedures_OGDTherapeuticProcedures_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        sArea = Request.QueryString("Area")

        If Not IsPostBack Then
            Initiate_User_Control_TherapeuticRecord()
            If Not IsPostBack Then
                hiddenSiteId.Value = siteId

                DisplayControls()
                TherapeuticRecord_LoadData()
            End If
        End If
    End Sub


    Private Sub DisplayControls()
        Dim region As String = Request.QueryString("Reg")
        Dim procType As Integer = Session(Constants.SESSION_PROCEDURE_TYPE)

        PolypTypeRadComboBox.DataSource = DataAdapter.LoadPolypTypes(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))
        PolypTypeRadComboBox.DataBind()

        DisplayDecompressTheDuctOptions(region)
        DisplayCorrectStentplacementOptions(region)

        'trRegion = "COMMON BILE DUCT" Or strRegion = "COMMON HEPATIC DUCT" Or strRegion = "MAJOR PAPILLA"
        Select Case region
            Case "Right Hepatic Lobe", "Left Hepatic Lobe", "Gall Bladder", "Cystic Duct"

                DisplayTherapeuticsTR({"StoneRemovalTR", "StrictureDilatationTR", "EndoscopicCystPunctureTR",
                                         "CannulationTR", "StentInsertionTR", "StentRemovalTR", "OherTR"})

            Case "Uncinate Process", "Head", "Neck", "Body", "Tail", "Accessory Pancreatic Duct", "Main Pancreatic Duct"

                DisplayTherapeuticsTR({"StoneRemovalTR", "StrictureDilatationTR", "EndoscopicCystPunctureTR",
                                         "CannulationTR", "StentInsertionTR", "StentRemovalTR", "OherTR"})

                Dim NasopancreaticDrainCheckBox = DirectCast(panERCPTherapeuticsFormView.FindControl("NasopancreaticDrainCheckBox"), CheckBox)
                If NasopancreaticDrainCheckBox IsNot Nothing Then NasopancreaticDrainCheckBox.Text = "Nasobiliary drain" '"Nasopancreatic drain"

                Dim RendezvousProcedureCheckBox = DirectCast(panERCPTherapeuticsFormView.FindControl("RendezvousProcedureCheckBox"), CheckBox)
                If RendezvousProcedureCheckBox IsNot Nothing Then RendezvousProcedureCheckBox.Visible = False

            Case "Right intra-hepatic ducts", "Left intra-hepatic ducts", "Left Hepatic Ducts", "Right Hepatic Ducts",
                "Bifurcation", "Common Hepatic Duct", "Common Bile Duct"

                DisplayTherapeuticsTR({"StoneRemovalTR", "StrictureDilatationTR", "EndoscopicCystPunctureTR",
                                         "CannulationTR", "StentInsertionTR", "StentRemovalTR", "BalloonTrawlTR", "OherTR"})

            Case "Major Papilla", "Minor Papilla"

                DisplayTherapeuticsTR({"SphincterotomyTR", "StoneRemovalTR", "StrictureDilatationTR",
                                          "StentInsertionTR", "StentRemovalTR", "SnareExcisionTR", "SphincteroplastyTR", "OherTR", "CannulationTR"})

            Case "Second Part", "First Part", "Medial Wall First Part", "Lateral Wall First Part",
                "Lateral Wall Second Part", "Medial Wall Second Part", "Third Part", "Lateral Wall Third Part", "Medial Wall Third Part"

                DisplayTherapeuticsTR({"PolypectomyTR", "YAGLaserTR", "ArgonBeamDiathermyTR", "BandLigationTR", "InjectionTherapyTR", "NasojejunalTubeTR", "NasojejunalRemovalTR", "PyloricDilatationTR",
                         "StentInsertionTR", "StentRemovalTR", "EndoscopicTR", "MarkingTR", "ClipTR", "OherTR"})

                Dim RadioactiveWirePlacedCheckBox = DirectCast(panERCPTherapeuticsFormView.FindControl("RadioactiveWirePlacedCheckBox"), CheckBox)
                If RadioactiveWirePlacedCheckBox IsNot Nothing Then RadioactiveWirePlacedCheckBox.Visible = False

                DisplayInstructionForCareButtons()
            Case "Stomach"

                Dim ds As New Therapeutics
                'If GastrostomyInsertionCheckBox IsNot Nothing Then GastrostomyInsertionCheckBox.Text = ds.GetInstrumentUsed(siteId)
            Case "Duodenum"

                Dim ds As New Therapeutics
                'If GastrostomyInsertionCheckBox IsNot Nothing Then GastrostomyInsertionCheckBox.Text = ds.GetInstrumentUsed(siteId)
            Case Else

        End Select

        'EUS HPB only TRs
        If Not procType = ProcedureType.EUS_HPB Then
            FineNeedleAspirationTR.Visible = False
            FineNeedleBiopsyTR.Visible = False
        End If


        'The code below works for JS
        'Page.ClientScript.RegisterStartupScript(Me.GetType(), "ShowTR", "hideTR('" & sArea & "');", True)

    End Sub

    Sub DisplayDecompressTheDuctOptions(ByVal regionName As String)
        Dim specificRegions As String() = {"common bile duct", "common hepatic duct", "major papilla"}
        If specificRegions.Contains(regionName.ToLower()) Then
            '## Dance!
            Dim therap As New Therapeutics
            If therap.ShouldDisplayDecompressedOptions(siteId:=siteId) Then
                SphincterDecompressedDiv.Visible = True
                StoneRemovalDecompressedDiv.Visible = True
                StrictureDecompressedDiv.Visible = True
                StentDecompressedDiv.Visible = True
                BalloonDecompressedDiv.Visible = True
            End If
        End If
    End Sub

    Sub DisplayCorrectStentplacementOptions(ByVal regionName As String)
        '' Does this actually do anything???
        If regionName.ToLower().Contains("duct") Or regionName.ToLower.Equals("bifurcation") Then
            Console.WriteLine("regionName: " & regionName)
            Dim therap As New Therapeutics
            If therap.ShouldDisplayStentCorrentPlacementOptions(siteId:=siteId) Then
                divStentCorrectPlacement.Visible = True
            End If
        End If
    End Sub

    Private Sub DisplayTherapeuticsTR(arrTR)
        For Each value As String In arrTR
            Dim thisTR = DirectCast(panERCPTherapeuticsFormView.FindControl(value), HtmlTableRow)
            If thisTR IsNot Nothing Then thisTR.Visible = True
        Next
    End Sub

    Protected Sub DisplayInstructionForCareButtons()
        Dim w1 = DirectCast(panERCPTherapeuticsFormView.FindControl("StentInstructionForCareButton"), RadButton)
        If w1 IsNot Nothing Then w1.Attributes.Add("style", "display:normal")
        Dim w2 = DirectCast(panERCPTherapeuticsFormView.FindControl("OesoInstructionforCareButton"), RadButton)
        If w2 IsNot Nothing Then w2.Attributes.Add("style", "display:normal")
        Dim w3 = DirectCast(panERCPTherapeuticsFormView.FindControl("YagInstructionForCareRadButton"), RadButton)
        If w3 IsNot Nothing Then w3.Attributes.Add("style", "display:normal")
    End Sub

    Sub TherapeuticRecord_LoadData()
        Dim siteId As Integer = Convert.ToInt32(Request.QueryString("SiteId"))

        '######################################################################################
        '############ First Load all the Lookup Value for All Combo/Dropdown Boxes ############ 
        '######################################################################################    

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                    {InjectionTypeComboBox, "Agent Upper GI"},
                    {GastrostomyInsertionUnitsComboBox, "Gastrostomy PEG units"},
                    {GastrostomyInsertionTypeComboBox, "Gastrostomy PEG type"},
                    {StentRemovalTechniqueComboBox, "Therapeutic Stent Removal Technique"},
                    {EmrFluidComboBox, "Therapeutic EMR Fluid"},
                    {MarkingTypeComboBox, "Abno marking"},
                    {BalloonDilatationUnitsComboBox, "Oesophageal dilatation units"},
                    {BalloonDilatorTypeComboBox, "ERCP Balloon dilator"},
                    {StrictureDilatationUnitsComboBox, "Oesophageal dilatation units"},
                    {StrictureDilatorTypeComboBox, "Oesophageal dilator"},
                    {BalloonTrawlDilatorUnitsComboBox, "Oesophageal dilatation units"},
                    {BalloonTrawlDilatorTypeComboBox, "ERCP Balloon dilator"},
                    {RemovalUsingComboBox, "ERCP stone removal method"},
                    {CystPunctureDeviceComboBox, "ERCP cyst punct device"},
                    {SphincterotomeComboBox, "Therapeutic ERCP sphincterotomes"},
                    {ReasonForPapillotomyComboBox, "ERCP papillotomy reason"},
                    {CorrectPlacementAcrossStrictureComboBox, "Correct Placement Across Stricture"},
                    {HomeostasisComboBox, "Homeostasis"}
            })

        'set button click event- set here to cater for trainer vs trainee scenario
        StentInsertionDetailsButtons.Attributes("href") = "javascript:void(0);"
        StentInsertionDetailsButtons.Attributes("onclick") = String.Format("return showStentInsertionsWindow('{0}');", StentInsertionQtyNumericTextBox.ClientID)


        'LoadDropDownLookupValues("InjectionTypeComboBox", BusinessLogic.TherapOption.InjectionType, True)
        'LoadDropDownLookupValues("GastrostomyInsertionUnitsComboBox", BusinessLogic.TherapOption.GastrostomyInsertionUnits)
        'LoadDropDownLookupValues("GastrostomyInsertionTypeComboBox", BusinessLogic.TherapOption.GastrostomyInsertionType)
        'LoadDropDownLookupValues("StentInsertionTypeComboBox", IIf(sArea = "Oesophagus", BusinessLogic.TherapOption.StentInsertionType, BusinessLogic.TherapOption.StentInsertionStomachTypes))
        'LoadDropDownLookupValues("StentInsertionDiaUnitsComboBox", BusinessLogic.TherapOption.StentInsertionDiaUnits)
        'LoadDropDownLookupValues("StentRemovalTechniqueComboBox", BusinessLogic.TherapOption.StentRemovalTechnique)
        'LoadDropDownLookupValues("EmrFluidComboBox", BusinessLogic.TherapOption.EmrFluid)
        'LoadDropDownLookupValues("MarkingTypeComboBox", BusinessLogic.TherapOption.MarkingType)
        'LoadDropDownLookupValues("BalloonDilatationUnitsComboBox", BusinessLogic.TherapOption.DilatationUnits)
        'LoadDropDownLookupValues("BalloonDilatorTypeComboBox", BusinessLogic.TherapOption.DilatorType)
        'LoadDropDownLookupValues("StrictureDilatationUnitsComboBox", BusinessLogic.TherapOption.DilatationUnits)
        'LoadDropDownLookupValues("StrictureDilatorTypeComboBox", BusinessLogic.TherapOption.DilatorType)
        'LoadDropDownLookupValues("BalloonTrawlDilatorUnitsComboBox", BusinessLogic.TherapOption.DilatationUnits)
        'LoadDropDownLookupValues("BalloonTrawlDilatorTypeComboBox", BusinessLogic.TherapOption.DilatorType)
        'LoadDropDownLookupValues("RemovalUsingComboBox", BusinessLogic.TherapOption.StoneRemovalUsing)
        'LoadDropDownLookupValues("CystPunctureDeviceComboBox", BusinessLogic.TherapOption.CystPunctureDevice)
        'LoadDropDownLookupValues("SphincterotomeComboBox", BusinessLogic.TherapOption.Sphincterotome)

        '#############################################################################################################
        '############ Now Load Data- once all the controls are in the Variable and done with DirectCast() ############
        '#############################################################################################################
        'set to nothing 1st load incase of previously created sessions
        Session("CommonPolypDetails") = Nothing

        Dim therap As New Therapeutics
        ERCP_Record = therap.TherapeuticRecord_ERCP_FindBySite(siteId)

        If ERCP_Record IsNot Nothing Then

            '### None Check Box
            If (ERCP_Record.None = True) Then
                SetValue("chkNoneCheckBox", ControlType.Check, ERCP_Record.None)
            End If

            '#### Papillotomy: Conditional-> For PAPILLA Sites    
            If ERCP_Record.Papillotomy = True Then
                SetValue("PapillotomyCheckBox", ControlType.Check, ERCP_Record.Papillotomy) '## Which is actually [Sphincterotome]
                SetValue("SphincterotomeComboBox", ControlType.Combo, ERCP_Record.Sphincterotome)
                'SetValue("SphincterotomeComboBox", ControlType.Combo, ERCP_Record.Sphincterotome)
                SetValue("PapillotomyLengthTextBox", ControlType.Numeric, ERCP_Record.PapillotomyLength)
                SetValue("PapillotomyAcceptBalloonSizeTextBox", ControlType.Numeric, ERCP_Record.PapillotomyAcceptBalloonSize)
                SetValue("ReasonForPapillotomyComboBox", ControlType.Combo, ERCP_Record.ReasonForPapillotomy)
                SetValue("PapillotomyBleedingRadioButtonList", ControlType.RadioButton, ERCP_Record.PapillotomyBleeding)
                SetValue("SphincterDecompressedRadioButton", ControlType.RadioButton, ERCP_Record.SphincterDecompressed)
            End If

            '### PanOrifice Sphincterotomy: Conditional-> For PAPILLA Sites
            SetValue("PanOrificeSphincterotomyCheckBox", ControlType.Check, ERCP_Record.PanOrificeSphincterotomy)

            'MH added on 23 Aug 2021
            SetValue("StentChangeCheckBox", ControlType.Check, ERCP_Record.StentChange)
            SetValue("StentPlacementCheckBox", ControlType.Check, ERCP_Record.StentPlacement)

            '### StoneRemoval. Condtional: Billiary / Pancreas / Papilla. NOT Duodenum
            If (ERCP_Record.StoneRemoval = True) Then
                SetValue("StoneRemovalCheckBox", ControlType.Check, ERCP_Record.StoneRemoval)
                SetValue("RemovalUsingComboBox", ControlType.Combo, ERCP_Record.RemovalUsing)
                SetValue("ExtractionOutcomeRadioButtonList", ControlType.RadioButton, ERCP_Record.ExtractionOutcome)
                SetValue("InadequateSphincterotomyCheckBox", ControlType.Check, ERCP_Record.InadequateSphincterotomy)
                SetValue("StoneSizeCheckBox", ControlType.Check, ERCP_Record.StoneSize)
                SetValue("QuantityOfStonesCheckBox", ControlType.Check, ERCP_Record.QuantityOfStones)
                SetValue("ImpactedStonesCheckBox", ControlType.Check, ERCP_Record.ImpactedStones)
                SetValue("OtherReasonCheckBox", ControlType.Check, ERCP_Record.OtherReason)
                SetValue("OtherReasonTextBox", ControlType.Text, ERCP_Record.OtherReasonText)
                SetValue("StoneRemovalDecompressedRadioButton", ControlType.RadioButton, ERCP_Record.StoneDecompressed)
            End If

            '### Stricture Dilatation. Condtional: Billiary / Pancreas / Papilla. NOT Duodenum
            If (ERCP_Record.StrictureDilatation = True) Then
                SetValue("StrictureDilatationCheckBox", ControlType.Check, ERCP_Record.StrictureDilatation)
                SetValue("StrictureDilatedToNumericBox", ControlType.Numeric, ERCP_Record.DilatedTo)
                SetValue("StrictureDilatationUnitsComboBox", ControlType.Combo, ERCP_Record.DilatationUnits)
                SetValue("StrictureDilatorTypeComboBox", ControlType.Combo, ERCP_Record.DilatorType)
                SetValue("StrictureDecompressedRadioButton", ControlType.RadioButton, ERCP_Record.StrictureDecompressed)
            End If

            '### Endoscopic cyst puncture. Conditional: For BILIARY or PANCREAS Site
            If (ERCP_Record.EndoscopicCystPuncture = True) Then
                SetValue("EndoscopicCystPunctureCheckBox", ControlType.Check, ERCP_Record.EndoscopicCystPuncture)
                SetValue("CystPunctureDeviceComboBox", ControlType.Combo, ERCP_Record.CystPunctureDevice)
                SetValue("CystPunctureViaRadioButtonList", ControlType.RadioButton, ERCP_Record.CystPunctureVia)
            End If

            '### YAG Laser: Conditional-> For DUODENUM Sites
            If (ERCP_Record.YAGLaser = True) Then
                SetValue("YagLaserCheckBox", ControlType.Check, ERCP_Record.YAGLaser)
                SetValue("YagLaserWattsNumericTextBox", ControlType.Numeric, ERCP_Record.YAGLaserWatts)
                SetValue("YagLaserPulsesNumericTextBox", ControlType.Numeric, ERCP_Record.YAGLaserPulses)
                SetValue("YagLaserSecsNumericTextBox", ControlType.Numeric, ERCP_Record.YAGLaserSecs)
                SetValue("YagLaserKJNumericTextBox", ControlType.Numeric, ERCP_Record.YAGLaserKJ)
            End If

            '### ArgonBeamDiathermy : Conditional-> For DUODENUM Sites
            If (ERCP_Record.ArgonBeamDiathermy = True) Then
                SetValue("ArgonBeamDiathermyCheckBox", ControlType.Check, ERCP_Record.ArgonBeamDiathermy)
                SetValue("ArgonBeamDiathermyWattsNumericTextBox", ControlType.Numeric, ERCP_Record.ArgonBeamDiathermyWatts)
                SetValue("ArgonBeamDiathermyPulsesNumericTextBox", ControlType.Numeric, ERCP_Record.ArgonBeamDiathermyPulses)
                SetValue("ArgonBeamDiathermySecsNumericTextBox", ControlType.Numeric, ERCP_Record.ArgonBeamDiathermySecs)
                SetValue("ArgonBeamDiathermyKJNumericTextBox", ControlType.Numeric, ERCP_Record.ArgonBeamDiathermyKJ)
            End If

            If (ERCP_Record.Polypectomy = True) Then
                SetValue("PolypectomyCheckBox", ControlType.Check, ERCP_Record.Polypectomy)
                'set details button click event 
                SetValue("PolypectomyQtyRadNumericTextBox", ControlType.Numeric, ERCP_Record.PolypectomyQty)
                Dim polypDetails = AbnormalitiesDataAdapter.GetLesionsPolypData(siteId)
                Session("CommonPolypDetails") = polypDetails
                If polypDetails IsNot Nothing AndAlso polypDetails.Count > 0 Then
                    PolypTypeRadComboBox.SelectedValue = PolypTypeRadComboBox.FindItemByText(polypDetails(0).PolypType).Value
                End If
            End If


            Console.WriteLine("Site Area: " + sArea)
            '## Some more extra Independant Checkboxes.. Common to ONLY Duodenum
            '### BandLigationTR: Conditional ==> For DUODENUM Site
            If (ERCP_Record.BandLigation Or ERCP_Record.BotoxInjection Or ERCP_Record.EndoloopPlacement Or ERCP_Record.HeatProbe Or ERCP_Record.BicapElectro Or ERCP_Record.Diathermy Or ERCP_Record.ForeignBody Or ERCP_Record.HotBiopsy) Then
                '### If at least one of them is True- then do an effort to read that group, else don't try to Set Value- when you know- none of them were Selected!
                SetValue("BandLigationCheckBox", ControlType.Check, ERCP_Record.BandLigation)
                SetValue("BotoxInjectionCheckBox", ControlType.Check, ERCP_Record.BotoxInjection)
                SetValue("EndoloopPlacementCheckBox", ControlType.Check, ERCP_Record.EndoloopPlacement)
                SetValue("HeatProbeCheckBox", ControlType.Check, ERCP_Record.HeatProbe)
                SetValue("BicapElectroCheckBox", ControlType.Check, ERCP_Record.BicapElectro)
                SetValue("DiathermyCheckbox", ControlType.Check, ERCP_Record.Diathermy)
                SetValue("ForeignBodyCheckBox", ControlType.Check, ERCP_Record.ForeignBody)
                SetValue("HotBiopsyCheckBox", ControlType.Check, ERCP_Record.HotBiopsy)
            End If


            '### Injection: Conditional ==> Duodenum Site
            If (ERCP_Record.Injection = True) Then
                SetValue("InjectionTherapyCheckBox", ControlType.Check, ERCP_Record.Injection)
                SetValue("InjectionTypeComboBox", ControlType.Combo, ERCP_Record.InjectionType)
                SetValue("InjectionVolumeNumericTextBox", ControlType.Numeric, ERCP_Record.InjectionVolume)
                SetValue("InjectionNumberNumericTextBox", ControlType.Numeric, ERCP_Record.InjectionNumber)
            End If


            '### Gastrostomy Insertion: Conditional ==> Duodenum Site; GastrostomyInsertion- Via Nose!
            If (ERCP_Record.GastrostomyInsertion = True) Then
                SetValue("GastrostomyInsertionCheckBox", ControlType.Check, ERCP_Record.GastrostomyInsertion)
                SetValue("GastrostomyInsertionSizeNumericTextBox", ControlType.Numeric, ERCP_Record.GastrostomyInsertionSize)
                SetValue("GastrostomyInsertionUnitsComboBox", ControlType.Combo, ERCP_Record.GastrostomyInsertionUnits)
                SetValue("GastrostomyInsertionTypeComboBox", ControlType.Combo, ERCP_Record.GastrostomyInsertionType)
                SetValue("GastrostomyInsertionBatchNoTextBox", ControlType.Text, ERCP_Record.GastrostomyInsertionBatchNo)

                '### Following values to be read from Local Variables.. so- do manual work!
                NilByMouthCheckBox.Checked = ERCP_Record.NilByMouth
                NilByMouthHrsNumericTextBox.Text = ERCP_Record.NilByMouthHrs
                NilByProcCheckBox.Checked = ERCP_Record.NilByProc
                NilByProcHrsNumericTextBox.Text = ERCP_Record.NilByProcHrs
                AttachmentToWardCheckBox.Checked = ERCP_Record.AttachmentToWard
            End If
            SetValue("NasojejunalRemovalCheckBox", ControlType.Check, ERCP_Record.GastrostomyRemoval) '### Nasojejunal removal (NJT)

            '### Pyloric Dilatation. Conditional ==> For Duodenum Site -->
            SetValue("PyloricDilatationCheckBox", ControlType.Check, ERCP_Record.PyloricDilatation)

            '### CannulationTR. Conditional:  For BILIARY or PANCREAS Site
            If (ERCP_Record.Cannulation Or ERCP_Record.DiagCholangiogram Or ERCP_Record.Haemostasis Or ERCP_Record.NasopancreaticDrain Or ERCP_Record.RendezvousProcedure Or ERCP_Record.DiagCholangiogram Or ERCP_Record.Manometry) Then
                '## If at least one of them has a True value- then do an effort to read that group... else don't bother to come and check values and waste time!
                SetValue("CannulationCheckBox", ControlType.Check, ERCP_Record.Cannulation)
                SetValue("DiagnosticCholangiogramCheckBox", ControlType.Check, ERCP_Record.DiagCholangiogram)
                SetValue("HaemostasisCheckBox", ControlType.Check, ERCP_Record.Haemostasis)
                SetValue("NasopancreaticDrainCheckBox", ControlType.Check, ERCP_Record.NasopancreaticDrain)
                SetValue("RendezvousProcedureCheckBox", ControlType.Check, ERCP_Record.RendezvousProcedure)
                SetValue("DiagnosticPancreatogramCheckBox", ControlType.Check, ERCP_Record.DiagPancreatogram)
                SetValue("ManometryCheckBox", ControlType.Check, ERCP_Record.Manometry)
            End If

            '### Stent Insertion ==> Generic: For ANY Site
            If (ERCP_Record.StentInsertion = True) Then
                SetValue("StentInsertionCheckBox", ControlType.Check, ERCP_Record.StentInsertion)
                SetValue("StentInsertionQtyNumericTextBox", ControlType.Numeric, ERCP_Record.StentInsertionQty)
                SetValue("RadioactiveWirePlacedCheckBox", ControlType.Check, ERCP_Record.RadioactiveWirePlaced)
                SetValue("StentInsertionBatchNoTextBox", ControlType.Text, ERCP_Record.StentInsertionBatchNo)
                SetValue("StentDecompressedRadioButton", ControlType.RadioButton, ERCP_Record.StentDecompressedDuct)
                SetValue("StentCorrectPlacementRadioButton", ControlType.RadioButton, ERCP_Record.CorrectStentPlacement)
                SetValue("CorrectPlacementAcrossStrictureComboBox", ControlType.Combo, ERCP_Record.CorrectStentPlacementNoReason)

                Dim da As New DataAccess
                Dim dbDT = da.getStentInsertionDetails(hiddenTherapeuticId.Value)
                If dbDT.Rows.Count > 0 Then
                    'load to session
                    Dim insertionDetails As New List(Of StentInsertion)

                    For Each dr In dbDT.Rows
                        insertionDetails.Add(New StentInsertion With {
                            .StentInsertionType = dr("StentInsertionType"),
                            .StentInsertionLength = dr("StentInsertionLength"),
                            .StentInsertionDiameter = dr("StentInsertionDiameter"),
                            .StentInsertionDiameterUnits = dr("StentInsertionDiameterUnits")
                            })
                    Next

                    Session("StentInsertionDetails") = insertionDetails
                End If
            End If

            '### Stent Removal ==> Generic: For ANY Site
            If (ERCP_Record.StentRemoval = True) Then
                SetValue("StentRemovalCheckBox", ControlType.Check, ERCP_Record.StentRemoval)
                SetValue("StentRemovalTechniqueComboBox", ControlType.Combo, ERCP_Record.StentRemovalTechnique)
            End If

            '### Endocsopy / EMR: Conditional => Duodenum site
            If (ERCP_Record.EMR = True) Then
                SetValue("EmrCheckBox", ControlType.Check, ERCP_Record.EMR)
                SetValue("EmrTypeRadioButtonList", ControlType.RadioButton, ERCP_Record.EMRType)
                SetValue("EMRFluidComboBox", ControlType.Combo, ERCP_Record.EMRFluid)
                SetValue("EmrFluidVolNumericTextBox", ControlType.Numeric, ERCP_Record.EMRFluidVolume)
            End If

            '### Snare Excision: Conditional => Papilla site
            SetValue("SnareExcisionCheckBox", ControlType.Check, ERCP_Record.SnareExcision)

            '### SphincteroplastyTR: Conditional => Papilla site
            If (ERCP_Record.BalloonDilation = True) Then
                SetValue("BalloonDilationCheckBox", ControlType.Check, ERCP_Record.BalloonDilation)
                SetValue("BalloonDilatedToNumber", ControlType.Numeric, ERCP_Record.BalloonDilatedTo)
                SetValue("BalloonDilatationUnitsComboBox", ControlType.Combo, ERCP_Record.BalloonDilatationUnits)
                SetValue("BalloonDilatorTypeComboBox", ControlType.Combo, ERCP_Record.BalloonDilatorType)
            End If

            '### BalloonTrawlTR => Billiary / Pancreas
            If (ERCP_Record.BalloonTrawl = True) Then
                SetValue("BalloonTrawlCheckBox", ControlType.Check, ERCP_Record.BalloonTrawl)
                SetValue("BalloonTrawlDilatorTypeComboBox", ControlType.Combo, ERCP_Record.BalloonTrawlDilatorType)
                SetValue("BalloonTrawlDilatorSizeTextBox", ControlType.Numeric, ERCP_Record.BalloonTrawlDilatorSize)
                SetValue("BalloonTrawlDilatorUnitsComboBox", ControlType.Combo, ERCP_Record.BalloonTrawlDilatorUnits)
                SetValue("BalloonDecompressedRadioButton", ControlType.RadioButton, ERCP_Record.BalloonDecompressed)
                SetValue("BalloonTrawlSuccessfulCheckBox", ControlType.Check, ERCP_Record.BalloonTrawlSuccessful)
            End If

            '### Marking => Billiary / Pancreas
            If (ERCP_Record.Marking = True) Then
                SetValue("MarkingCheckBox", ControlType.Check, ERCP_Record.Marking)
                SetValue("MarkingTypeComboBox", ControlType.Combo, ERCP_Record.MarkingType)
            End If

            '### Clip => Billiary / Pancreas
            SetValue("ClipCheckBox", ControlType.Check, ERCP_Record.Clip)
            SetValue("ClipRadNumericTextBox", ControlType.Numeric, ERCP_Record.ClipNum)
            SetValue("BalloonDilatationCheckBox", ControlType.Check, ERCP_Record.BalloonDilatation)
            SetValue("BougieDilatationCheckBox", ControlType.Check, ERCP_Record.BougieDilatation)
            SetValue("BougieDilationCheckBox", ControlType.Check, ERCP_Record.BougieDilation)
            SetValue("BrushCytologyCheckBox", ControlType.Check, ERCP_Record.BrushCytology)
            SetValue("RadioFrequencyAblationCheckBox", ControlType.Check, ERCP_Record.RadioFrequencyAblation)
            If (ERCP_Record.Cholangioscopy = True) Then
                SetValue("CholangioscopyCheckBox", ControlType.Check, ERCP_Record.Cholangioscopy)
                SetValue("CholangioscopyRadioButtonList", ControlType.RadioButton, ERCP_Record.CholangioscopyType)
            End If



            If (ERCP_Record.FineNeedleAspiration = True) Then
                SetValue("FineNeedleAspirationCheckBox", ControlType.Check, ERCP_Record.FineNeedleAspiration)
                SetValue("FineNeedleTypeRadioButtonList", ControlType.RadioButton, ERCP_Record.FineNeedleAspirationType)

                'MH added on 23 Aug 2021
                SetValue("FNAPerformed", ControlType.Numeric, ERCP_Record.FNAPerformed)
                SetValue("FNARetrieved", ControlType.Numeric, ERCP_Record.FNARetreived)
                SetValue("FNASuccessful", ControlType.Numeric, ERCP_Record.FNASuccessful)
            End If

            SetValue("FineNeedleBiopsyCheckBox", ControlType.Check, ERCP_Record.FineNeedleBiopsy)
            'MH added on 23 Aug 2021
            If (ERCP_Record.FineNeedleBiopsy = True) Then
                SetValue("FNBPerformed", ControlType.Numeric, ERCP_Record.FNBPerformed)
                SetValue("FNBRetrieved", ControlType.Numeric, ERCP_Record.FNBRetreived)
                SetValue("FNBSuccessful", ControlType.Numeric, ERCP_Record.FNBSuccessful)
            End If

            SetValue("HomeostasisCheckBox", ControlType.Check, ERCP_Record.Homeostasis)
            If ERCP_Record.Homeostasis Then
                SetValue("HomeostasisComboBox", ControlType.Combo, ERCP_Record.HomeostasisType)
            End If

            SetValue("DiverticulotomyCheckBox", ControlType.Check, ERCP_Record.Diverticulotomy)


            OtherTextBox.Text = ERCP_Record.Other
        Else
            hiddenTherapeuticId.Value = 0
        End If

    End Sub

    Private Sub SetValue(ByVal controlName As String, ByVal controlObjectType As ControlType, Optional ByVal value As Object = Nothing)
        If value Is Nothing Then Exit Sub

        Select Case controlObjectType
            Case ControlType.Check
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), CheckBox)
                controlObject.Checked = IIf(value IsNot Nothing, CBool(value), False)
            Case ControlType.Text
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), RadTextBox)
                controlObject.Text = IIf(value IsNot Nothing, value.ToString(), "")
            Case ControlType.Combo
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), RadComboBox)
                controlObject.SelectedValue = IIf(value IsNot Nothing, CInt(value), False)
            Case ControlType.Numeric
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), RadNumericTextBox)
                'controlObject.Text = IIf(value IsNot Nothing, CInt(value), "")
                controlObject.Text = IIf(value IsNot Nothing, value, "")
            Case ControlType.RadioButton
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), RadioButtonList)
                If TypeOf value Is Boolean Then
                    controlObject.SelectedValue = IIf(value = True, 1, 0)
                Else
                    controlObject.SelectedValue = CInt(value)
                End If
        End Select
    End Sub

    Private Function GetValue(ByVal controlName As String, ByVal controlObjectType As ControlType, Optional ByVal getDropDownText As Boolean = False) As Object
        Select Case controlObjectType
            Case ControlType.Check
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), CheckBox)
                If controlObject IsNot Nothing Then
                    If controlObject.Checked Then _fieldValueFound = True
                    Return controlObject.Checked
                Else
                    Return False
                End If
            Case ControlType.Text
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), RadTextBox)
                If controlObject IsNot Nothing Then
                    'If controlObject.Text.Length > 0 Then _fieldValueFound = True
                    Return controlObject.Text
                Else
                    Return ""
                End If
            Case ControlType.Combo
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), RadComboBox)
                If controlObject IsNot Nothing AndAlso controlObject.SelectedIndex = 0 Then
                    Return Nothing
                ElseIf controlObject IsNot Nothing AndAlso controlObject.SelectedIndex > 1 And getDropDownText Then
                    Return controlObject.SelectedItem.Text
                ElseIf controlObject IsNot Nothing AndAlso controlObject.SelectedIndex > 0 Then
                    Return Convert.ToInt32(controlObject.SelectedValue)
                Else
                    Return 0
                End If
            Case ControlType.Numeric
                Dim decimalValue As Decimal
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), RadNumericTextBox)
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
                    Return 0
                End If
            Case ControlType.RadioButton
                Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), RadioButtonList)
                If controlObject IsNot Nothing AndAlso controlObject.SelectedItem Is Nothing Then
                    Return Nothing
                ElseIf controlObject IsNot Nothing AndAlso controlObject.SelectedItem IsNot Nothing AndAlso controlObject.SelectedItem.Text <> "" Then
                    Return Convert.ToInt32(controlObject.SelectedValue)
                Else
                    Return 0
                End If
        End Select
    End Function

    Function GetValueFromComboNewItemText(ByVal controlName As String) As String
        Dim controlObject = DirectCast(panERCPTherapeuticsFormView.FindControl(controlName), RadComboBox)
        If controlObject IsNot Nothing AndAlso controlObject.SelectedIndex > 0 AndAlso controlObject.SelectedItem.Text <> "" Then
            Return controlObject.SelectedItem.Text
        Else
            Return ""
        End If
    End Function

    Sub TherapeuticRecord_FillEntity()
        _fieldValueFound = False '### Initiate with 'False'. When any CheckBox is found Checked in GetValue()- then it will be 'True' from there!

        If hiddenTherapeuticId.Value > 0 Then
            Dim therap As New Therapeutics
            ERCP_Record = therap.TherapeuticRecord_ERCP_FindBySite(hiddenSiteId.Value())
        Else
            ERCP_Record = New ERS_ERCPTherapeutics
            ERCP_Record.SiteId = hiddenSiteId.Value
        End If
        If optIndependent.Selected Then
            ERCP_Record.EndoRole = 1
            ERCP_Record.CarriedOutRole = 1
        ElseIf optAssisted.Selected Then
            ERCP_Record.EndoRole = 3
            ERCP_Record.CarriedOutRole = 2
        ElseIf optObserved.Selected Then
            ERCP_Record.EndoRole = 2
            ERCP_Record.CarriedOutRole = 2
        ElseIf optIndependentEndo2.Selected Then
            ERCP_Record.EndoRole = 4
            ERCP_Record.CarriedOutRole = 2
        ElseIf optTrainerCompleted.Selected Then
            ERCP_Record.EndoRole = 5
            ERCP_Record.CarriedOutRole = 1
        End If

        ERCP_Record.None = chkNoneCheckBox.Checked
        ERCP_Record.Other = OtherTextBox.Text
        If Not String.IsNullOrEmpty(OtherTextBox.Text) Then _fieldValueFound = True

        '#### Papillotomy: Conditional-> For PAPILLA Sites        
        If (GetValue("PapillotomyCheckBox", ControlType.Check) = True) Then
            ERCP_Record.Papillotomy = True

            If SphincterotomeComboBox.Text <> "" AndAlso SphincterotomeComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("Therapeutic ERCP sphincterotomes", SphincterotomeComboBox.Text)
                If newId > 0 Then ERCP_Record.Sphincterotome = newId
            Else
                ERCP_Record.Sphincterotome = CInt(GetValue("SphincterotomeComboBox", ControlType.Combo))
            End If

            ERCP_Record.PapillotomyLength = Convert.ToSingle(GetValue("PapillotomyLengthTextBox", ControlType.Numeric))
            ERCP_Record.PapillotomyAcceptBalloonSize = Convert.ToSingle(GetValue("PapillotomyAcceptBalloonSizeTextBox", ControlType.Numeric))

            If ReasonForPapillotomyComboBox.Text <> "" AndAlso ReasonForPapillotomyComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("ERCP papillotomy reason", ReasonForPapillotomyComboBox.Text)
                If newId > 0 Then ERCP_Record.ReasonForPapillotomy = newId
            Else
                ERCP_Record.ReasonForPapillotomy = CInt(GetValue("ReasonForPapillotomyComboBox", ControlType.Combo))
            End If

            ERCP_Record.PapillotomyBleeding = CByte(GetValue("PapillotomyBleedingRadioButtonList", ControlType.RadioButton))
            ERCP_Record.SphincterDecompressed = CBool(GetValue("SphincterDecompressedRadioButton", ControlType.RadioButton))
        Else
            ERCP_Record.Papillotomy = False '### This is the Group Header- Checkbox. Other doesn't matter!
            ERCP_Record.Sphincterotome = Nothing
            ERCP_Record.PapillotomyLength = Nothing
            ERCP_Record.PapillotomyAcceptBalloonSize = Nothing
            ERCP_Record.ReasonForPapillotomy = Nothing
            ERCP_Record.PapillotomyBleeding = Nothing
            ERCP_Record.SphincterDecompressed = Nothing
        End If

        '### PanOrifice Sphincterotomy: Conditional-> For PAPILLA Sites
        ERCP_Record.PanOrificeSphincterotomy = GetValue("PanOrificeSphincterotomyCheckBox", ControlType.Check)

        ERCP_Record.Polypectomy = GetValue("PolypectomyCheckBox", ControlType.Check)
        If ERCP_Record.Polypectomy Then
            'ERCP_Record.PolypectomyRemoval = GetValue("PolypectomyRemovalRadioButtonList", ControlType.RadioButton)
            'ERCP_Record.PolypectomyRemovalType = GetValue("PolypectomyRemovalTypeRadioButtonList", ControlType.RadioButton)
            ERCP_Record.PolypectomyQty = CInt(GetValue("PolypectomyQtyRadNumericTextBox", ControlType.Numeric))

            'save polyp details
            Dim sitePolypDetails As List(Of SitePolyps) = If(Session("CommonPolypDetails"), New List(Of SitePolyps))

            If sitePolypDetails.Count > 0 Then
                'set polyp type id and resave sessiono data ready for the DB save
                sitePolypDetails.ForEach(Sub(x) x.PolypTypeId = CInt(GetValue("PolypTypeRadComboBox", ControlType.Combo)))
                Session("CommonPolypDetails") = sitePolypDetails
            End If
        End If

        '### StoneRemoval. Condtional: Billiary / Pancreas / Papilla. NOT Duodenum
        If (GetValue("StoneRemovalCheckBox", ControlType.Check) = True) Then
            ERCP_Record.StoneRemoval = True

            If RemovalUsingComboBox.Text <> "" AndAlso RemovalUsingComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("ERCP stone removal method", RemovalUsingComboBox.Text)
                If newId > 0 Then ERCP_Record.RemovalUsing = newId
            Else
                ERCP_Record.RemovalUsing = CInt(GetValue("RemovalUsingComboBox", ControlType.Combo))
            End If

            ERCP_Record.ExtractionOutcome = Convert.ToByte(GetValue("ExtractionOutcomeRadioButtonList", ControlType.RadioButton))
            ERCP_Record.InadequateSphincterotomy = GetValue("InadequateSphincterotomyCheckBox", ControlType.Check)
            ERCP_Record.StoneSize = GetValue("StoneSizeCheckBox", ControlType.Check)
            ERCP_Record.QuantityOfStones = GetValue("QuantityOfStonesCheckBox", ControlType.Check)
            ERCP_Record.ImpactedStones = GetValue("ImpactedStonesCheckBox", ControlType.Check)
            ERCP_Record.OtherReason = GetValue("OtherReasonCheckBox", ControlType.Check)
            ERCP_Record.OtherReasonText = GetValue("OtherReasonTextBox", ControlType.Text)
            ERCP_Record.StoneDecompressed = CBool(GetValue("StoneRemovalDecompressedRadioButton", ControlType.RadioButton))
            'hasFieldValue = True '### Value found.. good to INSERT in the table
        Else
            ERCP_Record.StoneRemoval = False
            ERCP_Record.RemovalUsing = Nothing
            '### Followings are 'NOT NULL' fields.. so MUST pass false!
            ERCP_Record.ExtractionOutcome = 0
            ERCP_Record.InadequateSphincterotomy = Nothing
            ERCP_Record.StoneSize = Nothing
            ERCP_Record.QuantityOfStones = Nothing
            ERCP_Record.ImpactedStones = Nothing
            ERCP_Record.OtherReason = Nothing
            ERCP_Record.OtherReasonText = ""
        End If

        '### Stricture Dilatation. Condtional: Billiary / Pancreas / Papilla. NOT Duodenum
        If (GetValue("StrictureDilatationCheckBox", ControlType.Check) = True) Then
            ERCP_Record.StrictureDilatation = True
            ERCP_Record.DilatedTo = Convert.ToSingle(GetValue("StrictureDilatedToNumericBox", ControlType.Numeric))
            ERCP_Record.DilatationUnits = CByte(GetValue("StrictureDilatationUnitsComboBox", ControlType.Combo))

            If StrictureDilatorTypeComboBox.Text <> "" AndAlso StrictureDilatorTypeComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("Oesophageal dilator", StrictureDilatorTypeComboBox.Text)
                If newId > 0 Then ERCP_Record.DilatorType = newId
            Else
                ERCP_Record.DilatorType = CInt(GetValue("StrictureDilatorTypeComboBox", ControlType.Combo))
            End If

            ERCP_Record.StrictureDecompressed = CBool(GetValue("StrictureDecompressedRadioButton", ControlType.RadioButton))
            'hasFieldValue = True
        Else
            ERCP_Record.StrictureDilatation = False
            ERCP_Record.DilatedTo = Nothing
            ERCP_Record.DilatationUnits = Nothing
            ERCP_Record.DilatorType = Nothing
            ERCP_Record.StrictureDecompressed = Nothing
        End If

        '### Endoscopic cyst puncture. Conditional: For BILIARY or PANCREAS Site
        If (GetValue("EndoscopicCystPunctureCheckBox", ControlType.Check) = True) Then
            ERCP_Record.EndoscopicCystPuncture = True

            If CystPunctureDeviceComboBox.Text <> "" AndAlso CystPunctureDeviceComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("ERCP cyst punct device", CystPunctureDeviceComboBox.Text)
                If newId > 0 Then ERCP_Record.CystPunctureDevice = newId
            Else
                ERCP_Record.CystPunctureDevice = CInt(GetValue("CystPunctureDeviceComboBox", ControlType.Combo))
            End If

            'ERCP_Record.CystPunctureDevice = CByte(GetValue("CystPunctureDeviceComboBox", ControlType.Combo))
            ERCP_Record.CystPunctureVia = Convert.ToByte(GetValue("CystPunctureViaRadioButtonList", ControlType.RadioButton))
            'hasFieldValue = True
        Else
            ERCP_Record.EndoscopicCystPuncture = False
            ERCP_Record.CystPunctureDevice = Nothing
            ERCP_Record.CystPunctureVia = Nothing
        End If

        '### YAG Laser: Conditional-> For DUODENUM Sites
        If (GetValue("YagLaserCheckBox", ControlType.Check) = True) Then
            ERCP_Record.YAGLaser = True
            ERCP_Record.YAGLaserWatts = GetValue("YagLaserWattsNumericTextBox", ControlType.Numeric)
            ERCP_Record.YAGLaserPulses = GetValue("YagLaserPulsesNumericTextBox", ControlType.Numeric)
            ERCP_Record.YAGLaserSecs = Convert.ToDecimal(GetValue("YagLaserSecsNumericTextBox", ControlType.Numeric))
            ERCP_Record.YAGLaserKJ = Convert.ToDecimal(GetValue("YagLaserKJNumericTextBox", ControlType.Numeric))
            'hasFieldValue = True
        Else
            ERCP_Record.YAGLaser = False
            ERCP_Record.YAGLaserWatts = Nothing
            ERCP_Record.YAGLaserPulses = Nothing
            ERCP_Record.YAGLaserSecs = Nothing
            ERCP_Record.YAGLaserKJ = Nothing
        End If

        '### ArgonBeamDiathermy : Conditional-> For DUODENUM Sites
        If (GetValue("ArgonBeamDiathermyCheckBox", ControlType.Check) = True) Then
            ERCP_Record.ArgonBeamDiathermy = True
            ERCP_Record.ArgonBeamDiathermyWatts = GetValue("ArgonBeamDiathermyWattsNumericTextBox", ControlType.Numeric)
            ERCP_Record.ArgonBeamDiathermyPulses = GetValue("ArgonBeamDiathermyPulsesNumericTextBox", ControlType.Numeric)
            ERCP_Record.ArgonBeamDiathermySecs = Convert.ToDecimal(GetValue("ArgonBeamDiathermySecsNumericTextBox", ControlType.Numeric))
            ERCP_Record.ArgonBeamDiathermyKJ = Convert.ToDecimal(GetValue("ArgonBeamDiathermyKJNumericTextBox", ControlType.Numeric))
            'hasFieldValue = True
        Else
            ERCP_Record.ArgonBeamDiathermy = False
            ERCP_Record.ArgonBeamDiathermyWatts = Nothing
            ERCP_Record.ArgonBeamDiathermyPulses = Nothing
            ERCP_Record.ArgonBeamDiathermySecs = Nothing
            ERCP_Record.ArgonBeamDiathermyKJ = Nothing
        End If

        '## Some more extra Independant Checkboxes.. Common to ONLY Duodenum
        '### BandLigationTR: Conditional ==> For DUODENUM Site
        Console.WriteLine("Site Area: " + sArea)
        ERCP_Record.BandLigation = GetValue("BandLigationCheckBox", ControlType.Check)
        ERCP_Record.BotoxInjection = GetValue("BotoxInjectionCheckBox", ControlType.Check)
        ERCP_Record.EndoloopPlacement = GetValue("EndoloopPlacementCheckBox", ControlType.Check)
        ERCP_Record.HeatProbe = (GetValue("HeatProbeCheckBox", ControlType.Check))
        ERCP_Record.BicapElectro = (GetValue("BicapElectroCheckBox", ControlType.Check))
        ERCP_Record.Diathermy = (GetValue("DiathermyCheckbox", ControlType.Check))
        ERCP_Record.ForeignBody = GetValue("ForeignBodyCheckBox", ControlType.Check)
        ERCP_Record.HotBiopsy = (GetValue("HotBiopsyCheckBox", ControlType.Check))

        'hasFieldValue = ERCP_Record.BandLigation Or ERCP_Record.BotoxInjection Or ERCP_Record.EndoloopPlacement Or ERCP_Record.HeatProbe Or ERCP_Record.BicapElectro Or ERCP_Record.Diathermy Or ERCP_Record.ForeignBody Or ERCP_Record.HotBiopsy

        '### Injection: Conditional ==> Duodenum Site
        If (GetValue("InjectionTherapyCheckBox", ControlType.Check) = True) Then
            ERCP_Record.Injection = True
            ERCP_Record.InjectionType = CInt(GetValue("InjectionTypeComboBox", ControlType.Combo))
            ERCP_Record.InjectionTypeNewItemText = GetValueFromComboNewItemText("InjectionTypeComboBox")
            ERCP_Record.InjectionVolume = GetValue("InjectionVolumeNumericTextBox", ControlType.Numeric)
            ERCP_Record.InjectionNumber = GetValue("InjectionNumberNumericTextBox", ControlType.Numeric)
            'hasFieldValue = True
        Else
            ERCP_Record.Injection = False
            ERCP_Record.InjectionType = Nothing
            ERCP_Record.InjectionVolume = Nothing
            ERCP_Record.InjectionNumber = Nothing
        End If

        '### Gastrostomy Insertion: Conditional ==> Duodenum Site; GastrostomyInsertion- Via Nose!
        If (GetValue("GastrostomyInsertionCheckBox", ControlType.Check) = True) Then
            ERCP_Record.GastrostomyInsertion = True
            ERCP_Record.GastrostomyInsertionSize = GetValue("GastrostomyInsertionSizeNumericTextBox", ControlType.Numeric)
            ERCP_Record.GastrostomyInsertionUnits = Convert.ToByte(GetValue("GastrostomyInsertionUnitsComboBox", ControlType.Combo))

            If GastrostomyInsertionTypeComboBox.Text <> "" AndAlso GastrostomyInsertionTypeComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("Gastrostomy PEG type", GastrostomyInsertionTypeComboBox.Text)
                If newId > 0 Then ERCP_Record.GastrostomyInsertionType = newId
            Else
                ERCP_Record.GastrostomyInsertionType = CInt(GetValue("GastrostomyInsertionTypeComboBox", ControlType.Combo))
            End If

            'ERCP_Record.GastrostomyInsertionType = Convert.ToByte(GetValue("GastrostomyInsertionTypeComboBox", ControlType.Combo))
            ERCP_Record.GastrostomyInsertionTypeNewItemText = GetValueFromComboNewItemText("GastrostomyInsertionTypeComboBox")
            ERCP_Record.GastrostomyInsertionBatchNo = GetValue("GastrostomyInsertionBatchNoTextBox", ControlType.Text)

            '### Following values to be read from Local Variables.. so- do manual work!
            ERCP_Record.NilByMouth = NilByMouthCheckBox.Checked
            ERCP_Record.NilByMouthHrs = GetValue("NilByMouthHrsNumericTextBox", ControlType.Numeric)
            ERCP_Record.NilByProc = NilByProcCheckBox.Checked
            ERCP_Record.NilByProcHrs = GetValue("NilByProcHrsNumericTextBox", ControlType.Numeric)
            ERCP_Record.AttachmentToWard = AttachmentToWardCheckBox.Checked
            'hasFieldValue = True
        Else
            ERCP_Record.GastrostomyInsertion = False

            ERCP_Record.GastrostomyInsertionSize = Nothing
            ERCP_Record.GastrostomyInsertionUnits = Nothing
            ERCP_Record.GastrostomyInsertionType = Nothing
            ERCP_Record.GastrostomyInsertionTypeNewItemText = Nothing
            ERCP_Record.GastrostomyInsertionBatchNo = Nothing

            '### Following values to be read from Local Variables.. so- do manual work!
            ERCP_Record.NilByMouth = False
            ERCP_Record.NilByMouthHrs = Nothing
            ERCP_Record.NilByProc = False
            ERCP_Record.NilByProcHrs = Nothing
            ERCP_Record.AttachmentToWard = False
        End If

        ERCP_Record.GastrostomyRemoval = GetValue("NasojejunalRemovalCheckBox", ControlType.Check)

        '### Pyloric Dilatation. Conditional ==> For Duodenum Site -->
        ERCP_Record.PyloricDilatation = GetValue("PyloricDilatationCheckBox", ControlType.Check)

        '### CannulationTR. Conditional:  For BILIARY or PANCREAS Site.
        ERCP_Record.Cannulation = GetValue("CannulationCheckBox", ControlType.Check)
        ERCP_Record.DiagCholangiogram = (GetValue("DiagnosticCholangiogramCheckBox", ControlType.Check))
        ERCP_Record.Haemostasis = (GetValue("HaemostasisCheckBox", ControlType.Check))
        ERCP_Record.NasopancreaticDrain = (GetValue("NasopancreaticDrainCheckBox", ControlType.Check))
        ERCP_Record.RendezvousProcedure = (GetValue("RendezvousProcedureCheckBox", ControlType.Check))
        ERCP_Record.DiagPancreatogram = (GetValue("DiagnosticPancreatogramCheckBox", ControlType.Check))
        ERCP_Record.Manometry = (GetValue("ManometryCheckBox", ControlType.Check))
        'hasFieldValue = ERCP_Record.GastrostomyRemoval Or ERCP_Record.DiagCholangiogram Or ERCP_Record.Haemostasis Or ERCP_Record.NasopancreaticDrain Or ERCP_Record.RendezvousProcedure Or ERCP_Record.DiagPancreatogram Or ERCP_Record.Manometry

        ' '### Stent Insertion ==> Generic: For ANY Site
        If (GetValue("StentInsertionCheckBox", ControlType.Check) = True) Then
            ERCP_Record.StentInsertion = True

            ERCP_Record.StentInsertionQty = GetValue("StentInsertionQtyNumericTextBox", ControlType.Numeric)
            ERCP_Record.RadioactiveWirePlaced = GetValue("RadioactiveWirePlacedCheckBox", ControlType.Check)
            ERCP_Record.StentInsertionBatchNo = GetValue("StentInsertionBatchNoTextBox", ControlType.Text)
            ERCP_Record.StentDecompressedDuct = CBool(GetValue("StentDecompressedRadioButton", ControlType.RadioButton))
            Dim correctPlacementValue = GetValue("StentCorrectPlacementRadioButton", ControlType.RadioButton)
            If correctPlacementValue Is Nothing Then
                ERCP_Record.CorrectStentPlacement = Nothing
            Else
                ERCP_Record.CorrectStentPlacement = CBool(correctPlacementValue)
            End If
            Dim correctPlacementAcrossStrictureComboBox = GetValue("CorrectPlacementAcrossStrictureComboBox", ControlType.Combo)
            If correctPlacementAcrossStrictureComboBox Is Nothing Then
                ERCP_Record.CorrectStentPlacementNoReason = Nothing
            Else
                ERCP_Record.CorrectStentPlacementNoReason = CInt(correctPlacementAcrossStrictureComboBox)
            End If
            'hasFieldValue = True
        Else
            ERCP_Record.StentInsertion = False
            ERCP_Record.StentInsertionQty = Nothing
            ERCP_Record.RadioactiveWirePlaced = Nothing
            ERCP_Record.StentInsertionBatchNo = Nothing
            ERCP_Record.StentDecompressedDuct = Nothing
            ERCP_Record.CorrectStentPlacement = Nothing
        End If

        '### Stent Removal ==> Generic: For ANY Site
        If (GetValue("StentRemovalCheckBox", ControlType.Check) = True) Then
            ERCP_Record.StentRemoval = True
            ERCP_Record.StentRemovalTechnique = GetValue("StentRemovalTechniqueComboBox", ControlType.Combo)
            ERCP_Record.StentRemovalTechniqueNewItemText = GetValueFromComboNewItemText("StentRemovalTechniqueComboBox")
            'hasFieldValue = True
        Else
            ERCP_Record.StentRemoval = False
            ERCP_Record.StentRemovalTechnique = Nothing
        End If

        'MH added on 23 Aug 2021
        If (GetValue("StentPlacementCheckBox", ControlType.Check) = True) Then
            ERCP_Record.StentPlacement = True
        Else
            ERCP_Record.StentPlacement = False
        End If


        If (GetValue("StentChangeCheckBox", ControlType.Check) = True) Then
            ERCP_Record.StentChange = True
        Else
            ERCP_Record.StentChange = False
        End If

        '### Endocsopy / EMR: Conditional => Duodenum site
        If (GetValue("EmrCheckBox", ControlType.Check) = True) Then
            ERCP_Record.EMR = True
            ERCP_Record.EMRType = CByte(GetValue("EmrTypeRadioButtonList", ControlType.RadioButton))
            ERCP_Record.EMRFluid = GetValue("EMRFluidComboBox", ControlType.Combo)
            ERCP_Record.EMRFluidNewItemText = GetValueFromComboNewItemText("EMRFluidComboBox")
            ERCP_Record.EMRFluidVolume = GetValue("EmrFluidVolNumericTextBox", ControlType.Numeric)
            'hasFieldValue = True
        Else
            ERCP_Record.EMR = False
            ERCP_Record.EMRType = Nothing
            ERCP_Record.EMRFluid = Nothing
            ERCP_Record.EMRFluidVolume = Nothing
        End If

        '### Snare Excision: Conditional => Papilla site
        ERCP_Record.SnareExcision = GetValue("SnareExcisionCheckBox", ControlType.Check)
        'hasFieldValue = ERCP_Record.SnareExcision

        '### SphincteroplastyTR: Conditional => Papilla site
        If (GetValue("BalloonDilationCheckBox", ControlType.Check) = True) Then
            ERCP_Record.BalloonDilation = True
            ERCP_Record.BalloonDilatedTo = Convert.ToSingle(GetValue("BalloonDilatedToNumber", ControlType.Numeric))
            ERCP_Record.BalloonDilatationUnits = CShort(GetValue("BalloonDilatationUnitsComboBox", ControlType.Combo))

            If BalloonDilatorTypeComboBox.Text <> "" AndAlso BalloonDilatorTypeComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("ERCP Balloon dilator", BalloonDilatorTypeComboBox.Text)
                If newId > 0 Then ERCP_Record.BalloonDilatorType = newId
            Else
                ERCP_Record.BalloonDilatorType = CInt(GetValue("BalloonDilatorTypeComboBox", ControlType.Combo))
            End If

            ERCP_Record.BalloonDecompressed = CBool(GetValue("DecompressedTheDuctRadioButton", ControlType.RadioButton))
            'hasFieldValue = True
        Else
            ERCP_Record.BalloonDilation = False
            ERCP_Record.BalloonDilatedTo = Nothing
            ERCP_Record.BalloonDilatationUnits = Nothing
            ERCP_Record.BalloonDilatorType = Nothing
            ERCP_Record.BalloonDecompressed = Nothing
        End If

        '### BalloonTrawlTR => Billiary / Pancreas
        If (GetValue("BalloonTrawlCheckBox", ControlType.Check) = True) Then
            ERCP_Record.BalloonTrawl = True
            'MH added on 26 Aug 2021
            If (GetValue("BalloonTrawlSuccessfulCheckBox", ControlType.Check) = True) Then
                ERCP_Record.BalloonTrawlSuccessful = True
            Else
                ERCP_Record.BalloonTrawlSuccessful = False
            End If

            If BalloonTrawlDilatorTypeComboBox.Text <> "" AndAlso BalloonTrawlDilatorTypeComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("ERCP Balloon dilator", BalloonTrawlDilatorTypeComboBox.Text)
                If newId > 0 Then ERCP_Record.BalloonTrawlDilatorType = newId
            Else
                ERCP_Record.BalloonTrawlDilatorType = CInt(GetValue("BalloonTrawlDilatorTypeComboBox", ControlType.Combo))
            End If

            'ERCP_Record.BalloonTrawlDilatorType = CShort(GetValue("BalloonTrawlDilatorTypeComboBox", ControlType.Combo))
            ERCP_Record.BalloonTrawlDilatorSize = CSng(Convert.ToSingle(GetValue("BalloonTrawlDilatorSizeTextBox", ControlType.Numeric)))
            ERCP_Record.BalloonTrawlDilatorUnits = CShort(GetValue("BalloonTrawlDilatorUnitsComboBox", ControlType.Combo))
            ERCP_Record.BalloonDecompressed = CBool(GetValue("BalloonDecompressedRadioButton", ControlType.RadioButton))
            'hasFieldValue = True
        Else
            ERCP_Record.BalloonTrawl = False
            ERCP_Record.BalloonTrawlDilatorType = Nothing
            ERCP_Record.BalloonTrawlDilatorSize = Nothing
            ERCP_Record.BalloonTrawlDilatorUnits = Nothing
            ERCP_Record.BalloonDecompressed = Nothing
            ERCP_Record.BalloonTrawlSuccessful = Nothing 'MH added on 26 Aug 2021
        End If

        '### Marking => Billiary / Pancreas
        If (GetValue("MarkingCheckBox", ControlType.Check) = True) Then
            ERCP_Record.Marking = True
            ERCP_Record.MarkingType = GetValue("MarkingTypeComboBox", ControlType.Combo)
            ERCP_Record.MarkingTypeNewItemText = GetValueFromComboNewItemText("MarkingTypeComboBox")
            'hasFieldValue = True
        Else
            ERCP_Record.Marking = False
            ERCP_Record.MarkingType = Nothing
        End If

        '### Clip => Billiary / Pancreas
        ERCP_Record.Clip = GetValue("ClipCheckBox", ControlType.Check)
        ERCP_Record.ClipNum = GetValue("ClipRadNumericTextBox", ControlType.Numeric)
        ERCP_Record.EUSProcType = False

        ERCP_Record.BalloonDilatation = GetValue("BalloonDilatationCheckBox", ControlType.Check)
        ERCP_Record.BougieDilatation = GetValue("BougieDilatationCheckBox", ControlType.Check)
        ERCP_Record.BougieDilation = GetValue("BougieDilationCheckBox", ControlType.Check)
        ERCP_Record.BrushCytology = GetValue("BrushCytologyCheckBox", ControlType.Check)
        ERCP_Record.RadioFrequencyAblation = GetValue("RadioFrequencyAblationCheckBox", ControlType.Check)
        ERCP_Record.Cholangioscopy = GetValue("CholangioscopyCheckBox", ControlType.Check)
        ERCP_Record.CholangioscopyType = CInt(GetValue("CholangioscopyRadioButtonList", ControlType.RadioButton))


        'If (ERCP_Record.FineNeedleAspiration = True) Then
        If (GetValue("FineNeedleAspirationCheckBox", ControlType.Check) = True) Then
            ERCP_Record.FineNeedleAspiration = GetValue("FineNeedleAspirationCheckBox", ControlType.Check)
            ERCP_Record.FineNeedleAspirationType = GetValue("FineNeedleTypeRadioButtonList", ControlType.RadioButton)

            ERCP_Record.FNAPerformed = GetValue("FNAPerformed", ControlType.Numeric)
            ERCP_Record.FNARetreived = GetValue("FNARetrieved", ControlType.Numeric)
            ERCP_Record.FNASuccessful = GetValue("FNASuccessful", ControlType.Numeric)

        Else
            ERCP_Record.FineNeedleAspiration = False
            ERCP_Record.FineNeedleAspirationType = Nothing
            ERCP_Record.FNAPerformed = Nothing
            ERCP_Record.FNARetreived = Nothing
            ERCP_Record.FNASuccessful = Nothing

        End If

        If (GetValue("FineNeedleBiopsyCheckBox", ControlType.Check) = True) Then
            ERCP_Record.FineNeedleBiopsy = GetValue("FineNeedleBiopsyCheckBox", ControlType.Check)
            ERCP_Record.FNBPerformed = GetValue("FNBPerformed", ControlType.Numeric)
            ERCP_Record.FNBRetreived = GetValue("FNBRetrieved", ControlType.Numeric)
            ERCP_Record.FNBSuccessful = GetValue("FNBSuccessful", ControlType.Numeric)
        Else
            ERCP_Record.FineNeedleBiopsy = Nothing
        End If

        ERCP_Record.Homeostasis = CBool(GetValue("HomeostasisCheckBox", ControlType.Check))
        If ERCP_Record.Homeostasis Then
            ERCP_Record.HomeostasisTypeNewItemText = GetValueFromComboNewItemText("HomeostasisComboBox")
            ERCP_Record.HomeostasisType = GetValue("HomeostasisComboBox", ControlType.Combo)
        Else
            ERCP_Record.HomeostasisType = Nothing
        End If

        ERCP_Record.Diverticulotomy = CBool(GetValue("DiverticulotomyCheckBox", ControlType.Check))


        'hasFieldValue = ERCP_Record.Clip Or ERCP_Record.ClipNum 'Or ERCP_Record.EUSProcType

        'Dim StentCheckBox = DirectCast(panERCPTherapeuticsFormView.FindControl("StentInsertionCheckBox"), CheckBox)
    End Sub


















    ''' <summary>
    ''' This will load the Therapeutic Records for Both TrainEE and TrainER
    ''' And will feed the values to the UserControl respectively!
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub Initiate_User_Control_TherapeuticRecord()
        Dim da As New OtherData
        Dim dtTr As DataTable = da.GetTrainerTraineeEndo(CInt(Session(Constants.SESSION_PROCEDURE_ID)), siteId)
        Dim drEndoscopist As DataRow = Nothing

        If dtTr.Rows.Count > 0 Then
            drEndoscopist = dtTr.Rows(0)
            hiddenTherapeuticId.Value = CInt(drEndoscopist("TherapRecordId"))
            If (IIf(IsDBNull(drEndoscopist("TraineeEndoscopist")), False, True)) AndAlso Session("EndoRole") = 1 Then
                ' 2nd endoscopist in independent role
                optIndependentEndo2.Attributes.CssStyle.Add("visibility", "visible")
                optObserved.Attributes.CssStyle.Add("visibility", "hidden")
                optAssisted.Attributes.CssStyle.Add("visibility", "hidden")
                optTrainerCompleted.Attributes.CssStyle.Add("visibility", "hidden")
                optIndependent.Text = drEndoscopist("TrainerEndoscopist")
                optIndependentEndo2.Text = drEndoscopist("TraineeEndoscopist")
                If CInt(drEndoscopist("EndoRole")) = 1 Then
                    optIndependent.Selected = True
                Else
                    optIndependentEndo2.Selected = True
                End If
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
                    optIndependent.Text = drEndoscopist("TrainerEndoscopist")
                    optTrainerCompleted.Attributes.CssStyle.Add("visibility", "hidden")
                    optIndependent.Selected = True
                End If
            End If
        End If
    End Sub

    Private Sub SetTabOptions(tabOption As String, Optional independentOnly As Boolean = False)
        Select Case tabOption
            Case "Independent"
                If independentOnly Then
                    optAssisted.Enabled = False
                    optObserved.Enabled = False
                    optTrainerCompleted.Selected = False
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
    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        If e.Argument.ToLower = "update-polyps" Then
            If Session("CommonPolypDetails") IsNot Nothing Then
                PolypectomyQtyRadNumericTextBox.Value = CType(Session("CommonPolypDetails"), List(Of SitePolyps)).Count
            End If
        Else
            SaveRecord(False)
        End If
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Dim therap As New Therapeutics

        TherapeuticRecord_FillEntity()

        If IIf((hiddenTherapeuticId.Value <= 0), True, False) Then
            therap.TherapeuticRecord_Save(ERCP_Record, Therapeutics.SaveAs.InsertNew, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

            '##Do regardless of SI being ticked.. Function has a cleanup routine that is compulsory
            Dim da As New DataAccess
            da.saveStentInsertionDetails(ERCP_Record.Id, ERCP_Record.SiteId, ERCP_Record.StentInsertion, If(ERCP_Record.StentInsertionQty, 0), CType(Session("StentInsertionDetails"), List(Of StentInsertion)))
            Session("StentInsertionDetails") = Nothing
        Else '## UPDATE existing Record

            therap.TherapeuticRecord_Save(ERCP_Record, Therapeutics.SaveAs.Update, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

            '##Do regardless of SI being ticked.. Function has a cleanup routine that is compulsory
            Dim da As New DataAccess
            da.saveStentInsertionDetails(ERCP_Record.Id, ERCP_Record.StentInsertion, ERCP_Record.SiteId, If(ERCP_Record.StentInsertionQty, 0), CType(Session("StentInsertionDetails"), List(Of StentInsertion)))
            Session("StentInsertionDetails") = Nothing
        End If

        If ERCP_Record.Polypectomy Then
            If Session("CommonPolypDetails") IsNot Nothing Then
                Using connection As New SqlClient.SqlConnection(DataAccess.ConnectionStr)
                    DataAdapter.SavePolypsData(CType(Session("CommonPolypDetails"), List(Of SitePolyps)), siteId)
                End Using
            End If
        Else
            'delete polyps for this site
            DataAdapter.DeletePolypData(siteId)
        End If

        'If saveAndClose Then
        '    ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
        'End If
    End Sub

    Protected Sub SaveAndCloseGEJWindow()

    End Sub


    Protected Sub showPEGInstruction()
        Dim script As String = "function f(){$find(""" + RadWindow3.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key3", script, True)
    End Sub

End Class
