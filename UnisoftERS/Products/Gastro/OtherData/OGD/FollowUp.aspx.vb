Imports Telerik.Web.UI

Partial Class Products_Gastro_OtherData_OGD_FollowUp
    Inherits PageBase

    Protected Shared procTypeID As Integer

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Init
        If Not Page.IsPostBack Then
            'SaveButton.Text = IIf(Session("AdvancedMode") = True, "Save Record", "Save & Close")
            procTypeID = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            PopulateComboBoxes()

            Dim da As New OtherData
            Dim dtFu As DataTable = da.GetUpperGIFollowUp(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtFu.Rows.Count > 0 Then
                PopulateData(dtFu.Rows(0))
            End If

            If da.HasGIBleedsRecord(CInt(Session(Constants.SESSION_PROCEDURE_ID))) And procTypeID = CInt(ProcedureType.Gastroscopy) Or procTypeID = CInt(ProcedureType.Transnasal) Then
                ReBleedPlanDiv.Visible = True
            Else
                ReBleedPlanDiv.Visible = False
            End If

            'CS see below for original. tfs "bug" 1440
            If procTypeID = ProcedureType.Thoracoscopy Then
                RadTabStrip1.FindTabByValue(3).Visible = False
            End If
            'If procTypeID = ProcedureType.Bronchoscopy Or procTypeID = ProcedureType.EBUS Or procTypeID = ProcedureType.Thoracoscopy Then
            '    RadTabStrip1.FindTabByValue(3).Visible = False
            'End If

            Dim objOption As New Options
            If objOption.IsEvidenceOfCancerMandatory() Then
                EvidenceOfCancerFieldValidator.Enabled = True

                rblCancerEvidence.Items.FindByValue("3").Enabled = False
            Else
                rblCancerEvidence.Items.FindByValue("3").Enabled = True
                EvidenceOfCancerFieldValidator.Enabled = False
            End If

            'MH added on 01 Oct 2021 - If Evidence of Cancer is set Mandatory and Page re-loaded from Validation display mandatory fields with Red
            Dim li1 As ListItem = rblCancerEvidence.Items.Item(0)
            Dim li2 As ListItem = rblCancerEvidence.Items.Item(1)
            If Request.QueryString("from") IsNot Nothing Then
                If Request.QueryString("from").ToString().ToUpper() = "VALIDATION" Then
                    li1.Text = "<span style='color:red;'>Yes</span>"
                    li2.Text = "<span style='color:red;'>No</span>"
                Else
                    li1.Text = "Yes"
                    li2.Text = "No"
                End If
            Else
                li1.Text = "Yes"
                li2.Text = "No"
            End If
        End If
    End Sub

    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, RadTabStrip1, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, RadNotification1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(CancelButton, RadTabStrip1, RadAjaxLoadingPanel1)
    End Sub

    Private Sub PopulateComboBoxes()

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                    {FurtherProcedureComboBox, DataAdapter.GetFutherProcedures(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                    {FurtherProcedureDueTypeComboBox, "Further procedure period"},
                    {ReturnToComboBox, DataAdapter.GetFollowupReferredTo(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                    {ReviewLocationComboBox, DataAdapter.GetReviewLocations(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                    {ReviewDueTypeComboBox, "Review period"}
              })

    End Sub

    Private Sub PopulateData(ByVal drFu As DataRow)
        Dim objOption As New Options

        chkNoFurtherTestsCheckBox.Checked = CBool(drFu("NoFurtherTestsRequired"))
        chkAwaitingPathologyResultsCheckBox.Checked = CBool(drFu("AwaitingPathologyResults"))

        If Not IsDBNull(drFu("EvidenceOfCancerIdentified")) Then
            rblCancerEvidence.SelectedValue = CInt(drFu("EvidenceOfCancerIdentified"))
        Else
            If Not objOption.IsEvidenceOfCancerMandatory() Then
                rblCancerEvidence.SelectedValue = 3
            End If
        End If

        If Not IsDBNull(drFu("PatientInformed")) Then
            chkPatientInformed.Checked = CBool(drFu("PatientInformed"))
        Else
            chkPatientInformed.Checked = False
        End If

        If Not IsDBNull(drFu("PatientRemovedFromFastTrack")) Then
            chkFastTrackRemoved.Checked = CBool(drFu("PatientRemovedFromFastTrack"))
        Else
            chkFastTrackRemoved.Checked = False
        End If

        If Not IsDBNull(drFu("NotInformedReason")) Then
            txtReasonWhyNotInformed.Text = Server.HtmlDecode(CStr(drFu("NotInformedReason").ToString))
        Else
            txtReasonWhyNotInformed.Text = ""
        End If

        If Not IsDBNull(drFu("CnsMdtcInformed")) Then
            chkCnsMdtcInformed.Checked = CBool(drFu("CnsMdtcInformed"))
        Else
            chkCnsMdtcInformed.Checked = False
        End If

        If Not IsDBNull(drFu("ImagingRequested")) Then
            chkImagingRequested.Checked = CBool(drFu("ImagingRequested"))
        Else
            chkImagingRequested.Checked = False
        End If

        FurtherProcedureTextBox.Text = Server.HtmlDecode(CStr(drFu("FurtherProcedureText").ToString))
        ReturnToComboBox.SelectedValue = CInt(drFu("ReturnTo"))
        NoFurtherFollowUpCheckBox.Checked = CBool(drFu("NoFurtherFollowUp"))
        ReviewLocationComboBox.SelectedValue = CInt(drFu("ReviewLocation"))
        If Not IsDBNull(drFu("ReviewDueCount")) Then
            ReviewDueCountNumericTextBox.Value = CInt(drFu("ReviewDueCount"))
        End If
        ReviewDueTypeComboBox.SelectedValue = CInt(drFu("ReviewDueType"))
        ReviewTextBox.Text = Server.HtmlDecode(CStr(drFu("ReviewText").ToString))

        CommentsTextBox.Text = Server.HtmlDecode(CStr(drFu("Comments").ToString))
        PfrFollowUpTextBox.Text = Server.HtmlDecode(CStr(drFu("PP_PFRFollowUp").ToString))


        If Not IsDBNull(drFu("ClinicalFindingsAlert")) Then
            chkFindingAlert.Checked = CBool(drFu("ClinicalFindingsAlert"))
        Else
            chkFindingAlert.Checked = False
        End If



#Region "Follow Up Re-Bleed"
        If Not IsDBNull(drFu("ReBleedPlanRepeatGastroscopy")) Then
            ReBleedPlanRepeatGastroCheckBox.Checked = CBool(drFu("ReBleedPlanRepeatGastroscopy"))
        End If

        If Not IsDBNull(drFu("ReBleedPlanRequestSurgicalReview")) Then
            ReBleedPlanReqSurgRevCheckBox.Checked = CBool(drFu("ReBleedPlanRequestSurgicalReview"))
        End If

        If Not IsDBNull(drFu("ReBleedPlanOtherOption")) Then
            ReBleedPlanOtherCheckBox.Checked = CBool(drFu("ReBleedPlanOtherOption"))
        End If

        ReBleedPlanOtherOptionTextBox.Text = Server.HtmlDecode(CStr(drFu("ReBleedPlanOtherText").ToString))
#End Region

    End Sub

    Private Sub SaveRecord(isSaveAndClose As Boolean)
        Dim da As New OtherData
        Dim objOptions As New Options
        Dim validationPassed As Boolean = False

        'IIf(FurtherProcedureDueCountNumericTextBox.Value Is Nothing, 0, FurtherProcedureDueCountNumericTextBox.Value), _
        'IIf(ReviewDueCountNumericTextBox.Value Is Nothing, 0, CInt(ReviewDueCountNumericTextBox.Value)), _

        '******************************************************************************************************************
        'Cancer Evidence Radio Buttons
        'rblCancerEvidence.SelectedValue
        '1 = Yes, 2 = No, 3 = Unknown
        '******************************************************************************************************************
        Dim cancerEvidence? As Integer

        'MH Changed on 05 Oct 2021 : If Evidence of Cancer is not mandatory then default value is Unknown or 3
        If Not objOptions.IsEvidenceOfCancerMandatory() Then
            'cancerEvidence = IIf(rblCancerEvidence.SelectedValue = "", 3, rblCancerEvidence.SelectedValue)
            If Not IsNothing(rblCancerEvidence.SelectedValue) Then
                If rblCancerEvidence.SelectedValue.ToString() <> "" Then
                    cancerEvidence = rblCancerEvidence.SelectedValue
                Else
                    cancerEvidence = 3
                End If
            Else
                cancerEvidence = 3
            End If
        Else
            If Not IsNothing(rblCancerEvidence.SelectedValue) Then
                If rblCancerEvidence.SelectedValue.ToString() <> "" Then
                    cancerEvidence = rblCancerEvidence.SelectedValue
                Else
                    cancerEvidence = Nothing
                End If
            Else
                cancerEvidence = Nothing
            End If
        End If



        'If EvidenceOfCancerMandatory, then user has to provide Yes or No for Evidence of cancer. Can not be blank or Unknown. Must be 1 or 2.
        If objOptions.IsEvidenceOfCancerMandatory() Then
            If cancerEvidence = 1 Or cancerEvidence = 2 Then
                validationPassed = True
            Else
                validationPassed = False
            End If
        Else
            validationPassed = True
        End If
        'No need to validate here: If Evidence Of Cancer is mandatory, user will be prompted to provide value with JS, in client side.

        Try

            da.SaveUpperGIFollowUp(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                   CInt(Session(Constants.SESSION_PROCEDURE_TYPE)),
                                   chkNoFurtherTestsCheckBox.Checked,
                                   chkAwaitingPathologyResultsCheckBox.Checked,
                                   IIf(cancerEvidence.HasValue, cancerEvidence, Nothing),
                                   chkPatientInformed.Checked,
                                   IIf(IIf(cancerEvidence.HasValue, cancerEvidence, 0) = 1, False, chkFastTrackRemoved.Checked),
                                   Server.HtmlEncode(txtReasonWhyNotInformed.Text),
                                   chkCnsMdtcInformed.Checked,
                                   chkImagingRequested.Checked,
                                   Utilities.GetComboBoxValue(FurtherProcedureComboBox),
                                   FurtherProcedureComboBox.Text,
                                   0,
                                   Utilities.GetComboBoxValue(FurtherProcedureDueTypeComboBox),
                                   Server.HtmlEncode(FurtherProcedureTextBox.Text),
                                   Utilities.GetComboBoxValue(ReturnToComboBox),
                                   ReturnToComboBox.SelectedItem.Text,
                                   NoFurtherFollowUpCheckBox.Checked,
                                   Utilities.GetComboBoxValue(ReviewLocationComboBox),
                                   ReviewLocationComboBox.SelectedItem.Text,
                                   0,
                                   Utilities.GetComboBoxValue(ReviewDueTypeComboBox),
                                   Server.HtmlEncode(ReviewTextBox.Text),
                                   Server.HtmlEncode(CommentsTextBox.Text),
                                   Server.HtmlEncode(PfrFollowUpTextBox.Text),
                                   ReBleedPlanRepeatGastroCheckBox.Checked, 'ReBleedPlanRepeatGastroscopy,
                                   ReBleedPlanReqSurgRevCheckBox.Checked, 'ReBleedPlanRequestSurgicalReview,
                                   ReBleedPlanOtherCheckBox.Checked, 'ReBleedPlanOtherOption,
                                   Server.HtmlEncode(ReBleedPlanOtherOptionTextBox.Text),
                                   chkFindingAlert.Checked,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   isSaveAndClose)

            If isSaveAndClose Then
                ExitForm()
            End If

            Me.Master.SetButtonStyle()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Follow Up.", ex)

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

    <System.Web.Services.WebMethod()>
    Public Shared Sub SaveNewFollowUpProcedure(procedureTypeId As Integer, text As String)
        Try
            Dim listDescription As String = String.Empty

            If procedureTypeId = ProcedureType.ERCP Then
                listDescription = "Further ERCP procedure"
            Else
                listDescription = "Further procedure"
            End If

            Dim da As New DataAccess
            Dim newId = da.InsertListItem(listDescription, text)
            If newId = 0 Then
                Throw New Exception
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in SaveNewFollowUpProcedure", ex)
            Throw ex
        End Try
    End Sub

End Class