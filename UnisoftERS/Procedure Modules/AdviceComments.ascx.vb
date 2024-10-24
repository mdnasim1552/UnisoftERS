Imports Telerik.Web.UI

Public Class AdviceComments
    Inherits ProcedureControls

    Public Shared procType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender

    End Sub


    Protected Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Init
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))


            Dim da As New OtherData
            Dim dtFu As DataTable = da.GetUpperGIFollowUp(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtFu.Rows.Count > 0 Then
                PopulateData(dtFu.Rows(0))
            End If

            If da.HasGIBleedsRecord(CInt(Session(Constants.SESSION_PROCEDURE_ID))) And procType = CInt(ProcedureType.Gastroscopy) Then
                ReBleedPlanDiv.Visible = True
            Else
                ReBleedPlanDiv.Visible = False
            End If

        End If
    End Sub

    Private Sub PopulateData(ByVal drFu As DataRow)
        If Not IsDBNull(drFu("EvidenceOfCancerIdentified")) Then
            rblCancerEvidence.SelectedValue = CInt(drFu("EvidenceOfCancerIdentified"))
        Else
            rblCancerEvidence.SelectedValue = 3
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

        If Not IsDBNull(drFu("ClinicalFindingsAlert")) Then
            chkFindingAlert.Checked = CBool(drFu("ClinicalFindingsAlert"))
        Else
            chkFindingAlert.Checked = False
        End If

        If Not IsDBNull(drFu("UrgentTwoWeekReferral")) Then
            UrgentTwoWeekCheckBox.Checked = CBool(drFu("UrgentTwoWeekReferral"))
        Else
            UrgentTwoWeekCheckBox.Checked = False
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "toggle", "ToggleUrgentDiv(false);", True)
        End If

        If Not IsDBNull(drFu("CancerResultId")) Then
            CancerComboBox.SelectedValue = drFu("CancerResultId")
        Else
            UrgentTwoWeekCheckBox.Checked = False
        End If

        If Not IsDBNull(drFu("CancerNotDetected")) Then
            chkNotDetected.Checked = CBool(drFu("CancerNotDetected"))
        End If

        If Not IsDBNull(drFu("WhoStatusId")) Then
            WhoPerformanceStatusTextBox.Text = drFu("WhoStatusId")
        End If

        CommentsTextBox.Text = Server.HtmlDecode(CStr(drFu("Comments").ToString))
        PfrFollowUpTextBox.Text = Server.HtmlDecode(CStr(drFu("PP_PFRFollowUp").ToString))

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

    Public Sub saveAdviceAndComments()
        Dim da As New OtherData

        'IIf(FurtherProcedureDueCountNumericTextBox.Value Is Nothing, 0, FurtherProcedureDueCountNumericTextBox.Value), _
        'IIf(ReviewDueCountNumericTextBox.Value Is Nothing, 0, CInt(ReviewDueCountNumericTextBox.Value)), _

        '******************************************************************************************************************
        'Cancer Evidence Radio Buttons
        'rblCancerEvidence.SelectedValue
        '1 = Yes, 2 = No, 3 = Unknown
        '******************************************************************************************************************
        Dim cancerEvidence As Integer = 0

        cancerEvidence = IIf(rblCancerEvidence.SelectedValue = "", 3, rblCancerEvidence.SelectedValue)

        Try
            da.SaveUpperGIFollowUp(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                   CInt(Session(Constants.SESSION_PROCEDURE_TYPE)),
                                   Nothing,
                                   Nothing,
                                   cancerEvidence,
                                   chkPatientInformed.Checked,
                                   IIf(cancerEvidence = 1, False, chkFastTrackRemoved.Checked),
                                   Server.HtmlEncode(txtReasonWhyNotInformed.Text),
                                   chkCnsMdtcInformed.Checked,
                                   Nothing,
                                   Nothing,
                                   0,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   0,
                                   Nothing,
                                   Nothing,
                                   Server.HtmlEncode(CommentsTextBox.Text),
                                   Server.HtmlEncode(PfrFollowUpTextBox.Text),
                                   Nothing, 'ReBleedPlanRepeatGastroscopy,
                                   Nothing, 'ReBleedPlanRequestSurgicalReview,
                                   Nothing, 'ReBleedPlanOtherOption,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   UrgentTwoWeekCheckBox.Checked,
                                   If(UrgentTwoWeekCheckBox.Checked, CancerComboBox.SelectedValue, Nothing),
                                   If(UrgentTwoWeekCheckBox.Checked, WhoPerformanceStatusTextBox.Text, Nothing),
                                   chkNotDetected.Checked,
                                   True)
        Catch ex As Exception
            'Dim errorLogRef As String
            'errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Follow Up.", ex)

            'Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            'RadNotification1.Show()
        End Try
    End Sub

    'Private Sub loadCancerFollowUpQuestions()
    '    Try
    '        Dim dtQuestions = DataAdapter.GetCancerFollowUpQuestions()
    '        FollowUpQuestionsRepeater.DataSource = dtQuestions
    '        FollowUpQuestionsRepeater.DataBind()

    '        If dtQuestions IsNot Nothing AndAlso dtQuestions.Rows.Count > 0 Then
    '            Dim da As New OtherData


    '            Dim dtQuestionAnswers = da.GetCancerFollowUpQuestionAnswers(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

    '            If dtQuestionAnswers IsNot Nothing AndAlso dtQuestionAnswers.Rows.Count > 0 Then
    '                For Each itm As RepeaterItem In FollowUpQuestionsRepeater.Items
    '                    Dim questionId = CInt(CType(itm.FindControl("QuestionIdHiddenField"), HiddenField).Value)
    '                    Dim QuestionOptionRadioButton = CType(itm.FindControl("QuestionOptionRadioButton"), RadioButtonList)
    '                    Dim QuestionAnswerTextBox = CType(itm.FindControl("QuestionAnswerTextBox"), RadTextBox)

    '                    Dim drAnswers = dtQuestionAnswers.AsEnumerable.Where(Function(x) x("QuestionId") = questionId).FirstOrDefault

    '                    If drAnswers IsNot Nothing Then
    '                        If QuestionOptionRadioButton.Visible And Not drAnswers.IsNull("OptionAnswer") Then
    '                            QuestionOptionRadioButton.SelectedValue = If(CBool(drAnswers("OptionAnswer")), 1, 0)
    '                        End If

    '                        If QuestionAnswerTextBox.Visible And Not drAnswers.IsNull("FreeTextAnswer") Then
    '                            QuestionAnswerTextBox.Text = drAnswers("FreeTextAnswer")
    '                        End If
    '                    End If
    '                Next
    '            End If

    '        End If


    '    Catch ex As Exception
    '        'Dim errorLogRef As String
    '        'errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading followup questions.", ex)

    '        'Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading data.")
    '        'RadNotification1.Show()
    '    End Try


    'End Sub

    'Protected Sub FollowUpQuestionsRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
    '    Try
    '        If e.Item.DataItem IsNot Nothing Then
    '            Dim dr = CType(e.Item.DataItem, DataRowView)
    '            Dim isOptional = CType(dr("Optional"), Boolean)
    '            Dim freeText = CType(dr("CanFreeText"), Boolean)
    '            Dim mandatory = CType(dr("Mandatory"), Boolean)

    '            If Not isOptional Then
    '                CType(e.Item.FindControl("QuestionOptionRadioButton"), RadioButtonList).Visible = False
    '            End If

    '            If Not freeText Then
    '                CType(e.Item.FindControl("QuestionAnswerTextBox"), RadTextBox).Visible = False
    '            End If

    '            CType(e.Item.FindControl("QuestionMandatoryImage"), Image).Visible = mandatory
    '        End If
    '    Catch ex As Exception

    '    End Try
    'End Sub

End Class