Imports DevExpress.XtraRichEdit.Model
Imports Telerik.Web.UI
Imports System.Windows
Imports UnisoftERS.BusinessLogic

Partial Class Products_Options_SystemSettings
    Inherits OptionsBase

    Private Shared selectedProcedureType As Integer
    Private Shared selectedOperatingHospital As Integer

    Protected ReadOnly Property ApplicationTimeOut() As Integer
        Get
            Return CInt(ConfigurationManager.AppSettings("Unisoft.ApplicationTimeout"))
        End Get
    End Property

    Protected ReadOnly Property OperatingHospitalId() As Integer
        Get
            Return CInt(OperatingHospitalsRadComboBox.SelectedValue)
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            selectedOperatingHospital = CInt(Session("OperatingHospitalId"))
            OperatingHospitalsRadComboBox.DataSource = DataAdapter.GetAllOperatingHospitals(CInt(Session("TrustId")))
            OperatingHospitalsRadComboBox.DataTextField = "HospitalName"
            OperatingHospitalsRadComboBox.DataValueField = "OperatingHospitalId"
            OperatingHospitalsRadComboBox.DataBind()
            OperatingHospitalsRadComboBox.SelectedValue = selectedOperatingHospital

            HospitalFilterDiv.Visible = OperatingHospitalsRadComboBox.Items.Count > 1
            If CBool(Session("IsERSViewer")) Then
                ControlsTable_ERS.Visible = False
                RadTabStrip1.Tabs(1).Visible = False
                RadTabStrip1.Tabs(2).Visible = False
                RadTabStrip1.Tabs(3).Visible = False
            Else
                ControlsTable_ERS.Visible = True
                RadTabStrip1.Tabs(1).Visible = True
                RadTabStrip1.Tabs(2).Visible = True
                RadTabStrip1.Tabs(3).Visible = True

                Dim listTextField As String = "ListItemText"
                Dim listValueField As String = "ListItemNo"
                Utilities.LoadRadioButtonList(PatStatusRadioButtonList, DataAdapter.GetPatientStatuses(), listTextField, listValueField)

                'Dim dtWards As DataTable = DataAdapter.GetPatientWards()
                'Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{WardComboBox, ""}}, dtWards)
                'Utilities.LoadDropdown(WardComboBox, dtWards, listTextField, listValueField, "")


                Utilities.LoadRadioButtonList(PatientTypeRadioButtonList, DataAdapter.GetPatientTypes(), listTextField, listValueField)
            End If
            LoadProcedureTypes()
            PopulateData()
        End If
    End Sub

    Private Sub PopulateData()
        Dim dtSys As DataTable = OptionsDataAdapter.GetSystemSettings(OperatingHospitalId)
        If dtSys.Rows.Count > 0 Then

            'ApplicationTimeoutNumericTextBox.Value = ApplicationTimeOut 'CInt(ConfigurationManager.AppSettings("Unisoft.ApplicationTimeout")) 'CInt(dtSys.Rows(0)("ApplicationTimeOut"))
            If ControlsTable_ERS.Visible Then

                'system Settings Tab
                If CBool(dtSys.Rows(0)("OGDDiagnosis")) Then
                    IndividualRadioButton.Checked = True
                    WholeRadioButton.Checked = False
                Else
                    WholeRadioButton.Checked = True
                    IndividualRadioButton.Checked = False
                End If
                If CBool(dtSys.Rows(0)("UreaseTestsIncludeTickBoxes")) Then
                    UreaseTestsCheckBox.Checked = True
                Else
                    UreaseTestsCheckBox.Checked = False
                End If
                'If dtSys.Rows(0)("OesophagitisClassification") Then
                '    rbLAClassification.Checked = True
                '    rbModifiedSavaryMiller.Checked = False
                'Else
                '    rbLAClassification.Checked = False
                '    rbModifiedSavaryMiller.Checked = True
                'End If
                If dtSys.Rows(0)("NEDEnabled") Then
                    optNEDOn.Checked = True
                Else
                    optNEDOff.Checked = True
                End If
            End If

            'Procedure Settings Tab
            If dtSys.Rows(0)("SortReferringConsultantBy") Then
                rbConsultant_Alphabetical.Checked = False
                rbConsultant_MostFrequent.Checked = True
            Else
                rbConsultant_MostFrequent.Checked = False
                rbConsultant_Alphabetical.Checked = True
            End If
            If dtSys.Rows(0)("CompleteWHOSurgicalSafetyCheckList") Then
                rbSurgicalChecklistOff.Checked = False
                rbSurgicalChecklistOn.Checked = True
            Else
                rbSurgicalChecklistOn.Checked = False
                rbSurgicalChecklistOff.Checked = True
            End If
            If dtSys.Rows(0)("PatientConsent") Then
                rbPatientConsentOff.Checked = False
                rbPatientConsentOn.Checked = True
            Else
                rbPatientConsentOn.Checked = False
                rbPatientConsentOff.Checked = True
            End If

            '01 Sept 2021   :       MH added EvidenceOfCancerMandatory
            If dtSys.Rows(0)("IsEvidenceOfCancerMandatory") Then
                rbEvidenceOfCancerOff.Checked = False
                rbEvidenceOfCancerOn.Checked = True
                EvidenceOfCancerMandatoryDateDiv.Style("display") = "normal"
                CancerManFlagIgnoreBeforeRadDatePicker.SelectedDate = dtSys.Rows(0)("CancerManFlagIgnoreBeforeRadDatePicker")
            Else
                rbEvidenceOfCancerOff.Checked = True
                rbEvidenceOfCancerOn.Checked = False
                EvidenceOfCancerMandatoryDateDiv.Style("display") = "none"
                CancerManFlagIgnoreBeforeRadDatePicker.SelectedDate = dtSys.Rows(0)("CancerManFlagIgnoreBeforeRadDatePicker")
            End If

            '14 Jan 2024    :       MH added IsPatientNotesAvailableMandatory
            If dtSys.Rows(0)("IsPatientNotesAvailableMandatory") Then
                rdPatientNotesAvailableOff.Checked = False
                rdPatientNotesAvailableOn.Checked = True
            Else
                rdPatientNotesAvailableOn.Checked = False
                rdPatientNotesAvailableOff.Checked = True
            End If

            '21 Sept 2021   :       MH added MinimumPatientSearchOption
            Dim intMinPatientSearchOption As Integer = 1

            If Not IsDBNull(dtSys.Rows(0)("MinimumPatientSearchOption")) Then
                intMinPatientSearchOption = CInt(dtSys.Rows(0)("MinimumPatientSearchOption"))
                If intMinPatientSearchOption > 7 Then
                    intMinPatientSearchOption = 7
                End If
            Else
                intMinPatientSearchOption = 1
            End If
            cboMinPatSearchOptions.SelectedValue = intMinPatientSearchOption


            'If dtSys.Rows(0)("BostonBowelPrepScale") Then
            '    BostonBowelOffButton.Checked = False
            '    BostonBowelOnButton.Checked = True
            'Else
            '    BostonBowelOnButton.Checked = False
            '    BostonBowelOffButton.Checked = True
            'End If
            Select Case CInt(dtSys.Rows(0)("ReportLocking"))
                Case 1
                    CanEditRadioButton.Checked = True
                    EditableDiv.Style("display") = "none"
                Case 2
                    CannotEditRadioButton.Checked = True
                    EditableDiv.Style("display") = "normal"
                    FromTimePicker.SelectedTime = TimeSpan.FromHours(Left(dtSys.Rows(0)("LockingTime"), 2)) ' TimeSpan.Parse(dtSys.Rows(0)("LockingTime"))
                    DaysNumericTextBox.Value = CInt(dtSys.Rows(0)("LockingDays"))
            End Select
            If CBool(dtSys.Rows(0)("BRTPulmonaryPhysiology")) = True Then
                ShowPulmonaryPhysiologyRadioButtonList.SelectedValue = 1
            Else
                ShowPulmonaryPhysiologyRadioButtonList.SelectedValue = 0
            End If

            'Site Settings Tab
            If IsDBNull(dtSys.Rows(0)("SiteIdentification")) Then
                rbLetters.Checked = True
            Else
                If CInt(dtSys.Rows(0)("SiteIdentification")) = 1 Then
                    rbLetters.Checked = False
                    rbNumerics.Checked = True
                Else
                    rbNumerics.Checked = False
                    rbLetters.Checked = True
                End If
            End If
            SiteRadiusRadNumericTextBox.Value = CInt(dtSys.Rows(0)("SiteRadius"))

            'Patient Status Defaults Tab
            If CInt(dtSys.Rows(0)("DefaultPatientStatus")) > 0 Then
                PatStatusRadioButtonList.SelectedValue = CInt(dtSys.Rows(0)("DefaultPatientStatus"))
            Else
                PatStatusRadioButtonList.ClearSelection()
            End If
            If CInt(dtSys.Rows(0)("DefaultPatientType")) > 0 Then
                PatientTypeRadioButtonList.SelectedValue = CInt(dtSys.Rows(0)("DefaultPatientType"))
            Else
                PatientTypeRadioButtonList.ClearSelection()
            End If
            Dim dtWards As DataTable = DataAdapter.GetPatientWards(OperatingHospitalId)
            WardComboBox.Items.Clear()
            WardComboBox.Items.Add(New RadComboBoxItem(""))
            If dtWards.Rows.Count > 0 Then
                Dim r As DataRow
                For Each r In dtWards.Rows
                    Dim item As RadComboBoxItem = New RadComboBoxItem(r("WardDescription"), r("WardId"))
                    WardComboBox.Items.Add(item)
                Next
                WardComboBox.SelectedIndex = 0
            End If
            If CInt(dtSys.Rows(0)("DefaultWard")) > 0 Then
                WardComboBox.SelectedValue = CInt(dtSys.Rows(0)("DefaultWard"))
            End If

            MaxQuestionCountLabel.Text = dtSys(0)("PathwayPlanMaxQuestions")

            Dim dtQuestions As New DataTable
            selectedProcedureType = ProcedureType.Gastroscopy
            Dim questions = DataAdapter.GetPathwayPlanQuestions(selectedOperatingHospital, selectedProcedureType)
            If questions IsNot Nothing AndAlso questions.Rows.Count > 0 Then
                Dim nonSystemQuestions = questions.AsEnumerable.Where(Function(x) Not CBool(x("IsSystem")))
                If nonSystemQuestions IsNot Nothing Then
                    dtQuestions = nonSystemQuestions.CopyToDataTable
                Else
                    dtQuestions = questions
                End If
            Else
                dtQuestions = questions
            End If

            FollowUpQuestionsRadGrid.DataSource = dtQuestions
            FollowUpQuestionsRadGrid.DataBind()

        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            'If ApplicationTimeOut <> ApplicationTimeoutNumericTextBox.Value Then
            '    Dim myConfiguration As System.Configuration.Configuration = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("~")
            '    myConfiguration.AppSettings.Settings("Unisoft.ApplicationTimeout").Value = ApplicationTimeoutNumericTextBox.Value
            '    myConfiguration.Save()

            '    'Session.Timeout = CInt(ApplicationTimeoutNumericTextBox.Value)
            '    ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "sessionexpired", "window.parent.location='" + ResolveUrl("~/Security/Logout.aspx") + "'; ", True)

            '    Utilities.SetNotificationStyle(RadNotification1, "Settings saved successfully. The application needs to be restarted after changes to the application timeout.")
            'Else
            '    Utilities.SetNotificationStyle(RadNotification1, "Settings saved successfully.")
            'End If

            If ControlsTable_ERS.Visible Then
                OptionsDataAdapter.SaveSystemSettings(IIf(rbNumerics.Checked, 1, 0),
                                                        IIf(rbPatientConsentOn.Checked, 1, 0),
                                                        IIf(rbEvidenceOfCancerOn.Checked, 1, 0),
                                                        IIf(rdPatientNotesAvailableOn.Checked, 1, 0),
                                                        IIf(IndividualRadioButton.Checked, 1, 0),
                                                        IIf(UreaseTestsCheckBox.Checked, 1, 0),
                                                        IIf(rbConsultant_MostFrequent.Checked, 1, 0),
                                                       IIf(rbSurgicalChecklistOn.Checked, 1, 0),
                                                        SiteRadiusRadNumericTextBox.Value,
                                                        IIf(CanEditRadioButton.Checked, 1, 2),
                                                       FromTimePicker.SelectedTime.Value.ToString,
                                                        DaysNumericTextBox.Text,
                                                        IIf(optNEDOn.Checked, 1, 0),
                                                        IIf(PatStatusRadioButtonList.SelectedValue = "", 0, PatStatusRadioButtonList.SelectedValue),
                                                        IIf(PatientTypeRadioButtonList.SelectedValue = "", 0, PatientTypeRadioButtonList.SelectedValue),
                                                        IIf(WardComboBox.SelectedValue = "", 0, WardComboBox.SelectedValue),
                                                        CBool(ShowPulmonaryPhysiologyRadioButtonList.SelectedValue),
                                                        IIf(cboMinPatSearchOptions.SelectedValue = "", 1, cboMinPatSearchOptions.SelectedValue),
                                                        OperatingHospitalId)
            End If

            Utilities.SetNotificationStyle(RadNotification1, "Settings saved successfully.")
            RadNotification1.Show()
            PopulateData()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving System Settings under Options.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub NEDTest_Click(sender As Object, e As EventArgs)
        Dim ret As String
        Try
            Dim NEDEnabled As Boolean = False

            Dim dtSys As DataTable = OptionsDataAdapter.GetSystemSettings(OperatingHospitalId)
            If dtSys.Rows.Count > 0 Then
                NEDEnabled = CBool(dtSys.Rows(0)("NEDEnabled"))
            End If

            Dim nedService As NEDWeblogic.Webservice = New NEDWeblogic.Webservice()
            ret = nedService.Ping()
            If ret.Contains("Pong at ") Then ret = "Sucessful Connection to National Data Set"

            If Not NEDEnabled Then ret = ret + ", but no data being submitted"

        Catch ex As Exception
            ret = ex.ToString()
        End Try
        ' now display the ned results in a new RadWindow
        lblNEDResult.Text = ret
    End Sub

    Private Sub loadQuestionsRepeater(operatingHospital As Integer, procedureType As Integer)
        Try
            FollowUpQuestionsRadGrid.DataSource = DataAdapter.GetPathwayPlanQuestions(operatingHospital, procedureType)
            FollowUpQuestionsRadGrid.Rebind()

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading cancer follow up questions", ex)
            Utilities.SetErrorNotificationStyle(PathwayPlanRadNotification, ref, "There was an problem loading your questions")
            PathwayPlanRadNotification.Show()
        End Try
    End Sub

    Protected Sub AddQuestionLinkButton_Click(sender As Object, e As EventArgs)
        Try
            ClearValidationClasses()
            Dim questions = DataAdapter.GetPathwayPlanQuestions(selectedOperatingHospital, selectedProcedureType)
            If questions IsNot Nothing AndAlso questions.Rows.Count > 0 Then
                Dim qt = questions.AsEnumerable.Where(Function(x) x("Question") = FollowUpQuestionRadTextBox.Text).FirstOrDefault
                If qt IsNot Nothing Then
                    Utilities.SetNotificationStyle(PathwayPlanRadNotification, "The question you entered already exists for this procedure type.", True, "Please correct")
                    PathwayPlanRadNotification.Show()
                    Exit Sub
                End If
            End If
            If Not ValidateInputs(FollowUpQuestionRadTextBox.Text, QuestionAnswerOptionCheckBox.Checked, FreeTextAnswerOptionCheckBox.Checked) Then
                Exit Sub
            End If
            Dim rowsCount As Integer
            rowsCount = DataAdapter.savePathwayPlanQuestions(FollowUpQuestionRadTextBox.Text.Trim, QuestionAnswerOptionCheckBox.Checked, FreeTextAnswerOptionCheckBox.Checked, AnswerMandatoryCheckBox.Checked, selectedProcedureType, selectedOperatingHospital, If(Not String.IsNullOrWhiteSpace(FollowUpQuestionIdHiddenField.Value), FollowUpQuestionIdHiddenField.Value, Nothing))
            If rowsCount < 1 Then
                Utilities.SetNotificationStyle(PathwayPlanRadNotification, "You've reached the maximum of 10 questions allowed for this procedure type. Please suppress a question to add a new one.", True, "Questions Limit Exceeded")
                PathwayPlanRadNotification.Show()
            End If
            loadQuestionsRepeater(selectedOperatingHospital, selectedProcedureType)
            resetQuestionsForm()

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error saving cancer follow up questions", ex)
            Utilities.SetErrorNotificationStyle(PathwayPlanRadNotification, ref, "There was a problem saving your question")
            PathwayPlanRadNotification.Show()
        End Try
    End Sub

    Private Sub ClearValidationClasses()
        FollowUpQuestionRadTextBox.CssClass = FollowUpQuestionRadTextBox.CssClass.Replace("validation-error-field", "").Trim()
        QuestionAnswerOptionLabel.CssClass = QuestionAnswerOptionLabel.CssClass.Replace("validate-error-label", "").Trim()
        FreeTextAnswerOptionLabel.CssClass = FreeTextAnswerOptionLabel.CssClass.Replace("validate-error-label", "").Trim()
    End Sub

    Private Function ValidateInputs(questionText As String, isQuestionAnswerOptionChecked As Boolean, isFreeTextAnswerOptionChecked As Boolean) As Boolean
        Dim isValid As Boolean = True
        Dim errorMessage As String = String.Empty

        If String.IsNullOrWhiteSpace(questionText) Then
            FollowUpQuestionRadTextBox.CssClass += " validation-error-field"
            errorMessage &= "- Question<br/>"
            isValid = False
        End If

        If Not isQuestionAnswerOptionChecked And Not isFreeTextAnswerOptionChecked Then
            QuestionAnswerOptionLabel.CssClass += " validate-error-label"
            FreeTextAnswerOptionLabel.CssClass += " validate-error-label"
            errorMessage &= "- Yes/No option or Free text<br/>"
            isValid = False
        End If

        If Not isValid Then
            Utilities.SetNotificationStyle(PathwayPlanRadNotification, "Please select all the required fields:<br/> <span class='validate-error-label'>" & errorMessage & "</span>", True, "Please Select")
            PathwayPlanRadNotification.Show()
        End If

        Return isValid
    End Function

    Protected Sub FollowUpQuestionsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Try
            If e.CommandName IsNot Nothing AndAlso Not String.IsNullOrWhiteSpace(e.CommandArgument) Then
                Dim questionId = e.CommandArgument
                Dim dt = DataAdapter.GetPathwayPlanQuestion(questionId, selectedOperatingHospital)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    Dim dr = dt.Rows(0)
                    If e.CommandName.ToLower = "editquestion" Then
                        FollowUpQuestionRadTextBox.Text = dr("Question")
                        QuestionAnswerOptionCheckBox.Checked = CBool(dr("Optional"))
                        FreeTextAnswerOptionCheckBox.Checked = CBool(dr("CanFreeText"))
                        AnswerMandatoryCheckBox.Checked = CBool(dr("Mandatory"))
                        FollowUpQuestionIdHiddenField.Value = questionId
                        AddQuestionLinkButton.Text = "Update Question"
                        lnkClearQuestions.Visible = True
                        ProcedureTypeComboBox.SelectedValue = CInt(dr("ProcedureType"))

                    ElseIf e.CommandName.ToLower = "suppressquestion" Then
                        Dim rowsCount As Integer
                        rowsCount = DataAdapter.suppressPathwayPlanQuestions(questionId, (CType(e.Item.FindControl("SuppressLinkButton"), LinkButton).Text.ToLower = "suppress"), selectedOperatingHospital)
                        If rowsCount < 1 Then
                            Utilities.SetNotificationStyle(PathwayPlanRadNotification, "Unable to unsuppress question. This procedure type already has the maximum of 10 questions.", True, "Questions Limit Exceeded")
                            PathwayPlanRadNotification.Show()
                        End If
                        loadQuestionsRepeater(selectedOperatingHospital, selectedProcedureType)
                        resetQuestionsForm()
                    ElseIf e.CommandName.ToLower = "reorderup" Then
                        DataAdapter.reorderPathwayPlanQuestions(questionId, "u")
                        loadQuestionsRepeater(selectedOperatingHospital, selectedProcedureType)
                    ElseIf e.CommandName.ToLower = "reorderdown" Then
                        DataAdapter.reorderPathwayPlanQuestions(questionId, "d")
                        loadQuestionsRepeater(selectedOperatingHospital, selectedProcedureType)
                    End If
                End If

                ClearValidationClasses()
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error selecting the the questions to edit", ex)
            Utilities.SetErrorNotificationStyle(PathwayPlanRadNotification, ref, "There was an processing your request")
            PathwayPlanRadNotification.Show()
        End Try
    End Sub

    Protected Sub lnkClearQuestions_Click(sender As Object, e As EventArgs)
        resetQuestionsForm()
    End Sub

    Private Sub resetQuestionsForm()
        FollowUpQuestionRadTextBox.Text = ""
        QuestionAnswerOptionCheckBox.Checked = False
        FreeTextAnswerOptionCheckBox.Checked = False
        AnswerMandatoryCheckBox.Checked = False
        FollowUpQuestionIdHiddenField.Value = ""
        AddQuestionLinkButton.Text = "Add Question"
        lnkClearQuestions.Visible = False
    End Sub

    Protected Sub FollowUpQuestionsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim suppressLinkButton As LinkButton = e.Item.FindControl("SuppressLinkButton")
            If suppressLinkButton IsNot Nothing Then
                If CBool(CType(e.Item.DataItem, DataRowView)("Suppressed")) = False Then
                    suppressLinkButton.Text = "Suppress"
                Else
                    suppressLinkButton.Text = "Unsuppress"
                End If
            End If
        End If
    End Sub

    Protected Sub LoadProcedureTypes()
        Try
            ProcedureTypeComboBox.DataSource = DataAdapter.LoadAllProcedureTypes()
            ProcedureTypeComboBox.DataBind()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading relevant data", ex)
        End Try
    End Sub

    Protected Sub OperatingHospitalsRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        selectedOperatingHospital = OperatingHospitalsRadComboBox.SelectedValue
        loadQuestionsRepeater(selectedOperatingHospital, selectedProcedureType)
        ClearValidationClasses()
        resetQuestionsForm()
    End Sub

    Protected Sub ProcedureTypeComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        selectedProcedureType = ProcedureTypeComboBox.SelectedValue
        loadQuestionsRepeater(selectedOperatingHospital, selectedProcedureType)
        ClearValidationClasses()
        resetQuestionsForm()
    End Sub
End Class

