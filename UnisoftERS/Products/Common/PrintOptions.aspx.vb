Imports Telerik.Web.UI

Partial Class Products_Common_PrintOptions
    Inherits OptionsBase

    Protected ReadOnly Property OperatingHospitalId() As Integer
        Get
            Return CInt(OperatingHospitalsRadComboBox.SelectedValue)
        End Get
    End Property

    Private Sub Products_Common_PrintOptions_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            OperatingHospitalsRadComboBox.DataSource = DataAdapter.GetOperatingHospitals()
            OperatingHospitalsRadComboBox.DataTextField = "HospitalName"
            OperatingHospitalsRadComboBox.DataValueField = "OperatingHospitalId"
            OperatingHospitalsRadComboBox.DataBind()

            OperatingHospitalsRadComboBox.SelectedValue = CInt(Session("OperatingHospitalID"))
            HospitalFilterDiv.Visible = OperatingHospitalsRadComboBox.Items.Count > 1

            If Request.QueryString.Count > 0 Then
                If Request.QueryString("MainMenu") = "1" Then
                    CloseButton.Visible = False
                    CancelButton.Visible = True
                End If
            End If

            HideControls()

            Dim po As PrintOptions = LogicAdapter.GetPrintOptions(OperatingHospitalId)
            PopulateControls(po)
        End If
    End Sub

    Protected Overrides Sub RedirectToLoginPage()
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "sessionexpired", "window.parent.location='" + ResolveUrl("~/Security/Logout.aspx") + "'; ", True)
    End Sub

    Private Sub PopulateControls(ByVal po As PrintOptions)
        With po.GPReportPrintOptions
            GPReportDiagramCheckBox.Checked = .IncludeDiagram
            If .IncludeDiagramOnlyIfSitesExist Then GPReportDiagramDropDownList.SelectedValue = 2

            PreProcedureTreeView.FindNodeByValue("GPReportListConsultantCheckBox").Checked = .IncludeListConsultant
            PreProcedureTreeView.FindNodeByValue("GPReportNursesCheckBox").Checked = .IncludeNurses
            PreProcedureTreeView.FindNodeByValue("GPReportInstrumentCheckBox").Checked = .IncludeInstrument
            PreProcedureTreeView.FindNodeByValue("GPReportMissingCaseNoteCheckBox").Checked = .IncludeMissingCaseNote
            PreProcedureTreeView.FindNodeByValue("GPReportIndicationsCheckBox").Checked = .IncludeIndications
            PreProcedureTreeView.FindNodeByValue("GPReportCoMorbiditiesCheckBox").Checked = .IncludeCoMorbidities
            PreProcedureTreeView.FindNodeByValue("GPReportPlannedProceduresCheckBox").Checked = .IncludePlannedProcedures
            PreProcedureTreeView.FindNodeByValue("GPReportPremedicationCheckBox").Checked = .IncludePremedication
            PreProcedureTreeView.FindNodeByValue("GPReportPreviousGastricUlcerCheckBox").Checked = .IncludePreviousGastricUlcer

            ProcedureTreeView.FindNodeByValue("GPReportDiagnosesCheckBox").Checked = .IncludeDiagnoses
            ProcedureTreeView.FindNodeByValue("GPReportTherapeuticProceduresCheckBox").Checked = .IncludeTherapeuticProcedures
            ProcedureTreeView.FindNodeByValue("GPReportSpecimensTakenCheckBox").Checked = .IncludeSpecimensTaken
            ProcedureTreeView.FindNodeByValue("GPReportProcedureNotesCheckBox").Checked = .IncludeProcedureNotes
            ProcedureTreeView.FindNodeByValue("GPReportSiteNotesCheckBox").Checked = .IncludeSiteNotes
            ProcedureTreeView.FindNodeByValue("GPReportBowelPreparationCheckBox").Checked = .IncludeBowelPreparation
            ProcedureTreeView.FindNodeByValue("GPReportExtentOfIntubationCheckBox").Checked = .IncludeExtentOfIntubation
            ProcedureTreeView.FindNodeByValue("GPReportExtentAndLimitingFactorsCheckBox").Checked = .IncludeExtentAndLimitingFactors
            ProcedureTreeView.FindNodeByValue("GPReportCannulationCheckBox").Checked = .IncludeCannulation
            ProcedureTreeView.FindNodeByValue("GPReportExtentOfVisualisationCheckBox").Checked = .IncludeExtentOfVisualisation
            ProcedureTreeView.FindNodeByValue("GPReportContrastMediaUsedCheckBox").Checked = .IncludeContrastMediaUsed
            ProcedureTreeView.FindNodeByValue("GPReportPapillaryAnatomyCheckBox").Checked = .IncludePapillaryAnatomy

            PostProcedureTreeView.FindNodeByValue("GPReportFollowUpCheckBox").Checked = .IncludeFollowUp
            PostProcedureTreeView.FindNodeByValue("GPReportPeriOperativeComplicationsCheckBox").Checked = .IncludePeriOperativeComplications

            GPReportDefaultNumberOfCopiesRadNumericTextBox.Value = .DefaultNumberOfCopies
            PhotosDefaultNumberOfCopiesNumericTextBox.Value = .DefaultNumberOfPhotos
            PhotosDefaultImageSize.SelectedValue = .DefaultPhotoSize
            PhotosDefaultExportImage.Checked = .DefaultExportImage
            PrintTypeButtonList.SelectedValue = .PrintType
            PrintDoubleSidedCheckBox.Checked = .PrintDoubleSided
        End With

        With po.LabRequestFormPrintOptions
            If .OneRequestForEverySpecimen Then LabRequestGroupSpecimensRadioButtonList.SelectedValue = 1
            If .GroupSpecimensByDestination Then LabRequestGroupSpecimensRadioButtonList.SelectedValue = 2
            LabRequestsPerPageDropDownList.SelectedValue = .RequestsPerA4Page
            LabRequestDiagramCheckBox.Checked = .IncludeDiagram
            LabRequestTimeCheckBox.Checked = .IncludeTimeSpecimenCollected
            LabRequestHeadingCheckBox.Checked = .IncludeHeading
            LabRequestIndicationsCheckBox.Checked = .IncludeIndications
            LabRequestProcedureNotesCheckBox.Checked = .IncludeProcedureNotes
            LabRequestAbnormalitiesCheckBox.Checked = .IncludeAbnormalities
            LabRequestSiteNotesCheckBox.Checked = .IncludeSiteNotes
            LabRequestDiagnosesCheckBox.Checked = .IncludeDiagnoses
            LabRequestDefaultCopiesRadNumericTextBox.Value = .DefaultNumberOfCopies
            If LabRequestHeadingComboBox.FindItemByText(.Heading) IsNot Nothing Then
                LabRequestHeadingComboBox.FindItemByText(.Heading).Selected = True
            Else
                LabRequestOtherTextBox.Text = .Heading
            End If
        End With

        With po.PatientFriendlyReportPrintOptions
            NoFollowupCheckBox.Checked = .IncludeNoFollowup
            UreaseCheckBox.Checked = .IncludeUreaseText
            UreaseTextBox.Text = Server.HtmlDecode(.UreaseText)
            PolypectomyCheckBox.Checked = .IncludePolypectomyText
            PolypectomyTextBox.Text = Server.HtmlDecode(.PolypectomyText)
            OtherBiopsyCheckBox.Checked = .IncludeOtherBiopsyText
            OtherBiopsyTextBox.Text = Server.HtmlDecode(.OtherBiopsyText)
            AnyOtherBiopsyCheckBox.Checked = .IncludeAnyOtherBiopsyText
            AnyOtherBiopsyTextBox.Text = Server.HtmlDecode(.AnyOtherBiopsyText)
            AdviceCommentsCheckBox.Checked = .IncludeAdviceComments
            PreceedAdviceCommentsCheckBox.Checked = .IncludePreceedAdviceComments
            PreceedAdviceCommentsTextBox.Text = Server.HtmlDecode(.PreceedAdviceComments)
            FinalTextCheckBox.Checked = .IncludeFinalText
            FinalTextBox.Text = Server.HtmlDecode(.FinalText)
            PatientFriendlyDefaultCopiesRadNumericTextBox.Value = .DefaultNumberOfCopies
            AdditionalListView.DataSource = .AdditionalEntries
            AdditionalListView.DataBind()
        End With
    End Sub

    Private Sub HideControls()
        Dim procTypeId As Integer
        If Session(Constants.SESSION_PROCEDURE_TYPE) IsNot Nothing AndAlso CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) > 0 Then
            procTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            Select Case procTypeId
                Case 1, 5, 7 '1:OGD - 5:EUS-OGD
                    ProcedureTreeView.FindNodeByValue("GPReportBowelPreparationCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportExtentAndLimitingFactorsCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportCannulationCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportExtentOfVisualisationCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportContrastMediaUsedCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportPapillaryAnatomyCheckBox").Visible = False

                Case 2, 6 '2:ERCP ; 6:EUS-HPB
                    ProcedureTreeView.FindNodeByValue("GPReportBowelPreparationCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportExtentOfIntubationCheckBox").Visible = False
                    PreProcedureTreeView.FindNodeByValue("GPReportPreviousGastricUlcerCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportExtentAndLimitingFactorsCheckBox").Visible = False

                Case 3, 4, 12 'Colon/Proct/Sig
                    ProcedureTreeView.FindNodeByValue("GPReportExtentOfIntubationCheckBox").Visible = False
                    PreProcedureTreeView.FindNodeByValue("GPReportPreviousGastricUlcerCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportCannulationCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportExtentOfVisualisationCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportContrastMediaUsedCheckBox").Visible = False
                    ProcedureTreeView.FindNodeByValue("GPReportPapillaryAnatomyCheckBox").Visible = False
            End Select

            'Dim da As New DataAccess
            'Dim dt As DataTable = da.GetPrintReportPhotos(CInt(Session("OperatingHospitalID")), CInt(Session(Constants.SESSION_PROCEDURE_ID)), CInt(Session(Constants.SESSION_EPISODE_NO)), CStr(Session(Constants.SESSION_PATIENT_COMBO_ID)))
            'If dt Is Nothing OrElse dt.Rows.Count = 0 Then
            '    NoPhotosMessageLabel.Visible = True
            'End If
        End If
    End Sub

    Protected Sub AddEntryButton_Click(sender As Object, e As EventArgs) Handles AddEntryButton.Click
        Dim entriesSoFar As List(Of PatientFriendlyReportPrintOptionsAdditional) = SetPatientFriendlyReportOptionsAdditional()

        If entriesSoFar.Where(Function(i) i.Id = 0 And i.AdditionalText = "").Count = 0 Then
            entriesSoFar.Add(New PatientFriendlyReportPrintOptionsAdditional With {
                         .Id = 0,
                         .IncludeAdditionalText = False,
                         .AdditionalText = ""})
            entriesSoFar = entriesSoFar.OrderBy(Function(i) i.Id).ThenBy(Function(i) Server.HtmlDecode(i.AdditionalText)).ToList()
        End If

        AdditionalListView.DataSource = entriesSoFar
        AdditionalListView.DataBind()
    End Sub

    Private Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            Dim po As New PrintOptions()

            po.IncludeGPReport = True
            po.IncludePhotosReport = True
            po.IncludePatientCopyReport = True
            po.IncludeLabRequestReport = True

            po.GPReportPrintOptions = SetGPReportOptions()
            po.LabRequestFormPrintOptions = SetLabRequestOptions()
            po.PatientFriendlyReportPrintOptions = SetPatientFriendlyReportOptions()

            'Session("PrintOptions") = po
            LogicAdapter.SavePrintOptions(po, OperatingHospitalId)

            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
            'ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "callprint", "PrintReports();", True)
            'Page.ClientScript.RegisterStartupScript(Me.GetType(), "callprint", "PrintReports();", True)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Print Options.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        Response.Redirect(Request.Url.AbsoluteUri, False)
    End Sub

    Private Function SetGPReportOptions() As GPReportPrintOptions
        Dim grpo As New GPReportPrintOptions

        grpo.IncludeDiagram = GPReportDiagramCheckBox.Checked
        grpo.IncludeDiagramOnlyIfSitesExist = CInt(GPReportDiagramDropDownList.SelectedValue) = 2

        grpo.IncludeListConsultant = PreProcedureTreeView.FindNodeByValue("GPReportListConsultantCheckBox").Checked
        grpo.IncludeNurses = PreProcedureTreeView.FindNodeByValue("GPReportNursesCheckBox").Checked
        grpo.IncludeInstrument = PreProcedureTreeView.FindNodeByValue("GPReportInstrumentCheckBox").Checked
        grpo.IncludeMissingCaseNote = PreProcedureTreeView.FindNodeByValue("GPReportMissingCaseNoteCheckBox").Checked
        grpo.IncludeIndications = PreProcedureTreeView.FindNodeByValue("GPReportIndicationsCheckBox").Checked
        grpo.IncludeCoMorbidities = PreProcedureTreeView.FindNodeByValue("GPReportCoMorbiditiesCheckBox").Checked
        grpo.IncludePlannedProcedures = PreProcedureTreeView.FindNodeByValue("GPReportPlannedProceduresCheckBox").Checked
        grpo.IncludePremedication = PreProcedureTreeView.FindNodeByValue("GPReportPremedicationCheckBox").Checked
        grpo.IncludePreviousGastricUlcer = PreProcedureTreeView.FindNodeByValue("GPReportPreviousGastricUlcerCheckBox").Checked

        grpo.IncludeDiagnoses = ProcedureTreeView.FindNodeByValue("GPReportDiagnosesCheckBox").Checked
        grpo.IncludeTherapeuticProcedures = ProcedureTreeView.FindNodeByValue("GPReportTherapeuticProceduresCheckBox").Checked
        grpo.IncludeSpecimensTaken = ProcedureTreeView.FindNodeByValue("GPReportSpecimensTakenCheckBox").Checked
        grpo.IncludeProcedureNotes = ProcedureTreeView.FindNodeByValue("GPReportProcedureNotesCheckBox").Checked
        grpo.IncludeSiteNotes = ProcedureTreeView.FindNodeByValue("GPReportSiteNotesCheckBox").Checked
        grpo.IncludeBowelPreparation = ProcedureTreeView.FindNodeByValue("GPReportBowelPreparationCheckBox").Checked
        grpo.IncludeExtentOfIntubation = ProcedureTreeView.FindNodeByValue("GPReportExtentOfIntubationCheckBox").Checked
        grpo.IncludeExtentAndLimitingFactors = ProcedureTreeView.FindNodeByValue("GPReportExtentAndLimitingFactorsCheckBox").Checked
        grpo.IncludeCannulation = ProcedureTreeView.FindNodeByValue("GPReportCannulationCheckBox").Checked
        grpo.IncludeExtentOfVisualisation = ProcedureTreeView.FindNodeByValue("GPReportExtentOfVisualisationCheckBox").Checked
        grpo.IncludeContrastMediaUsed = ProcedureTreeView.FindNodeByValue("GPReportContrastMediaUsedCheckBox").Checked
        grpo.IncludePapillaryAnatomy = ProcedureTreeView.FindNodeByValue("GPReportPapillaryAnatomyCheckBox").Checked


        grpo.IncludeFollowUp = PostProcedureTreeView.FindNodeByValue("GPReportFollowUpCheckBox").Checked
        grpo.IncludePeriOperativeComplications = PostProcedureTreeView.FindNodeByValue("GPReportPeriOperativeComplicationsCheckBox").Checked

        grpo.DefaultNumberOfCopies = GPReportDefaultNumberOfCopiesRadNumericTextBox.Value
        grpo.DefaultNumberOfPhotos = PhotosDefaultNumberOfCopiesNumericTextBox.Value
        grpo.DefaultPhotoSize = PhotosDefaultImageSize.SelectedValue
        grpo.DefaultExportImage = PhotosDefaultExportImage.Checked
        grpo.PrintType = PrintTypeButtonList.SelectedValue
        grpo.PrintDoubleSided = PrintDoubleSidedCheckBox.Checked
        Return grpo
    End Function

    Private Function SetLabRequestOptions() As LabRequestFormPrintOptions
        Dim lrpo As New LabRequestFormPrintOptions()

        lrpo.DefaultNumberOfCopies = LabRequestDefaultCopiesRadNumericTextBox.Value
        lrpo.OneRequestForEverySpecimen = CInt(LabRequestGroupSpecimensRadioButtonList.SelectedValue) = 1
        lrpo.GroupSpecimensByDestination = CInt(LabRequestGroupSpecimensRadioButtonList.SelectedValue) = 2
        lrpo.RequestsPerA4Page = CInt(LabRequestsPerPageDropDownList.SelectedValue)
        lrpo.IncludeDiagram = LabRequestDiagramCheckBox.Checked
        lrpo.IncludeTimeSpecimenCollected = LabRequestTimeCheckBox.Checked
        lrpo.IncludeHeading = LabRequestHeadingCheckBox.Checked

        If CInt(LabRequestHeadingComboBox.SelectedValue) = 5 Then
            lrpo.Heading = LabRequestOtherTextBox.Text
        Else
            lrpo.Heading = LabRequestHeadingComboBox.SelectedItem.Text
        End If

        lrpo.IncludeIndications = LabRequestIndicationsCheckBox.Checked
        lrpo.IncludeProcedureNotes = LabRequestProcedureNotesCheckBox.Checked
        lrpo.IncludeAbnormalities = LabRequestAbnormalitiesCheckBox.Checked
        lrpo.IncludeSiteNotes = LabRequestSiteNotesCheckBox.Checked
        lrpo.IncludeDiagnoses = LabRequestDiagnosesCheckBox.Checked

        Return lrpo
    End Function

    Private Function SetPatientFriendlyReportOptions() As PatientFriendlyReportPrintOptions
        Dim pfpo As New PatientFriendlyReportPrintOptions()

        pfpo.IncludeNoFollowup = NoFollowupCheckBox.Checked
        pfpo.IncludeUreaseText = UreaseCheckBox.Checked
        pfpo.UreaseText = Server.HtmlEncode(UreaseTextBox.Text)
        pfpo.IncludePolypectomyText = PolypectomyCheckBox.Checked
        pfpo.PolypectomyText = Server.HtmlEncode(PolypectomyTextBox.Text)
        pfpo.IncludeOtherBiopsyText = OtherBiopsyCheckBox.Checked
        pfpo.OtherBiopsyText = Server.HtmlEncode(OtherBiopsyTextBox.Text)
        pfpo.IncludeAnyOtherBiopsyText = AnyOtherBiopsyCheckBox.Checked
        pfpo.AnyOtherBiopsyText = Server.HtmlEncode(AnyOtherBiopsyTextBox.Text)
        pfpo.IncludeAdviceComments = AdviceCommentsCheckBox.Checked
        pfpo.IncludePreceedAdviceComments = PreceedAdviceCommentsCheckBox.Checked
        pfpo.PreceedAdviceComments = Server.HtmlEncode(PreceedAdviceCommentsTextBox.Text)
        pfpo.IncludeFinalText = FinalTextCheckBox.Checked
        pfpo.FinalText = Server.HtmlEncode(FinalTextBox.Text)
        pfpo.DefaultNumberOfCopies = PatientFriendlyDefaultCopiesRadNumericTextBox.Value

        pfpo.AdditionalEntries = SetPatientFriendlyReportOptionsAdditional()

        Return pfpo
    End Function

    Private Function SetPatientFriendlyReportOptionsAdditional() As List(Of PatientFriendlyReportPrintOptionsAdditional)
        Dim pfpoaList As New List(Of PatientFriendlyReportPrintOptionsAdditional)
        Dim pfpoa As PatientFriendlyReportPrintOptionsAdditional

        For Each i As ListViewDataItem In AdditionalListView.Items
            pfpoa = New PatientFriendlyReportPrintOptionsAdditional
            With pfpoa
                .Id = AdditionalListView.DataKeys(i.DataItemIndex).Values("Id")
                .IncludeAdditionalText = DirectCast(i.FindControl("AdditionalCheckBox"), CheckBox).Checked
                .AdditionalText = Server.HtmlEncode(DirectCast(i.FindControl("AdditionalTextBox"), RadTextBox).Text)
            End With
            pfpoaList.Add(pfpoa)
        Next
        Return pfpoaList
    End Function

    Protected Sub OperatingHospitalsRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Dim po As PrintOptions = LogicAdapter.GetPrintOptions(OperatingHospitalId)
        PopulateControls(po)
    End Sub
End Class
