Public Class ProcedureSummary_aspx
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            ProcBowelPrep.Visible = False 'MH added on 08 Feb 2024 - Bowel Prep should only be visible for Col, Sig, ENT Retro and Flexi

            Select Case procType
                Case CInt(ProcedureType.Gastroscopy), CInt(ProcedureType.Transnasal)
                    ProcInsertionTechnique.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    ProcCannulation.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    ProcBowelPrep.Visible = False

                Case CInt(ProcedureType.ERCP)
                    VisualisationLabel.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    ProcMucosalVisualisation.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    ProcBowelPrep.Visible = False
                    ProcLevelOfComplexity.Visible = False
                Case CInt(ProcedureType.Colonoscopy)
                    VisualisationLabel.Visible = False
                    ProcMucosalVisualisation.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    ProcCannulation.Visible = False
                    ProcBowelPrep.Visible = True

                Case CInt(ProcedureType.Sigmoidscopy)
                    VisualisationLabel.Visible = False
                    ProcMucosalVisualisation.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    ProcCannulation.Visible = False
                    AISoftware.Visible = False
                    ProcBowelPrep.Visible = True
                Case CInt(ProcedureType.Proctoscopy)
                    VisualisationLabel.Visible = False
                    ProcMucosalVisualisation.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    ProcCannulation.Visible = False
                    ProcBowelPrep.Visible = False
                    ExtentofIntubationSection.Visible = False
                    ProcPlannedExtent.Visible = False

                Case CInt(ProcedureType.EUS_OGD)
                    VisualisationLabel.Visible = False
                    ProcMucosalVisualisation.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    ProcCannulation.Visible = False
                    ProcBowelPrep.Visible = False

                Case CInt(ProcedureType.EUS_HPB)
                    VisualisationLabel.Visible = False
                    ProcMucosalVisualisation.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    ProcCannulation.Visible = False
                    ProcBowelPrep.Visible = False

                Case CInt(ProcedureType.Antegrade)
                    VisualisationLabel.Visible = False
                    ProcMucosalVisualisation.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    ProcCannulation.Visible = False
                    ProcBowelPrep.Visible = False

                Case CInt(ProcedureType.Retrograde)
                    VisualisationLabel.Visible = False
                    ProcMucosalVisualisation.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    ProcCannulation.Visible = False
                    ProcBowelPrep.Visible = True

                Case CInt(ProcedureType.Flexi) 'This is Cysto ID 13!!!
                    VisualisationLabel.Visible = False
                    ProcMucosalVisualisation.Visible = False

                    ProcChromendoscopies.Visible = False
                    ProcInsufflation.Visible = False
                    ProcPlannedExtent.Visible = False
                    ProcProcedureExtent.Visible = False
                    ProcInsertionTechnique.Visible = False
                    ExtentofIntubationSection.Visible = False

                    ProcInsertionTechnique.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    ProcCannulation.Visible = False
                    ProcBowelPrep.Visible = False

                Case CInt(ProcedureType.Bronchoscopy), CInt(ProcedureType.EBUS)
                    VisualisationLabel.Visible = False
                    ProcPlannedExtent.Visible = False
                    ProcInsufflation.Visible = False
                    'ProcPlannedExtent.Visible = False
                    ProcProcedureExtent.Visible = False
                    AISoftware.Visible = False
                    ProcCannulation.Visible = False
                    ProcLevelOfComplexity.Visible = False
                    'ProcedureSuccessDiv.Visible = False
                    extentdiv.Visible = False
                    ProcEnteroscopyTechnique.Visible = False
                    VisualisationLabel.Visible = False
                    ProcMucosalVisualisation.Visible = False
                    ProcChromendoscopies.Visible = False
                    ProcInsertionTechnique.Visible = False

                    BronchoCodingDiv.Visible = True
                    AdditionalReportNotesDiv.Visible = True
                    ProcedureVocalCordParalysis.Visible = True
                    ProcBroncDrugsAdministered.Visible = True
                    ProcBowelPrep.Visible = False
            End Select

        End If

    End Sub

    Protected Sub ProcScopes_Changed()
        LoadPhotos()
    End Sub
End Class