Imports System.ServiceModel.Channels
Imports System.Web.Script.Serialization

Public Class PostProcedure
    Inherits PageBase


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If procType = ProcedureType.Bronchoscopy Or procType = ProcedureType.EBUS Or procType = ProcedureType.Flexi Then
                divRequirementsKey.Visible = False
            End If

            If DataAccess.ProcedureDNA(CInt(Session(Constants.SESSION_PROCEDURE_ID))).Rows.Count > 0 Then
                ProcNotCarriedOutCheckBox.Checked = True
            End If

            ProcedureTypeLabel.Text = DataHelper.GetProcedureName("Post procedure", procType)
        End If
    End Sub

    Protected Sub Page_Prerender(sender As Object, e As EventArgs)

    End Sub

    Sub reloadSummary()
        Dim SummaryListView As ListView = DirectCast(Master.FindControl("SummaryListView"), ListView)
        SummaryListView.DataBind()
    End Sub

#Region "Adverse Events"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveAdverseEvents(procedureId As Integer, adverseEventId As Integer, childId As Integer, checked As Boolean, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveAdverseEvents(procedureId, adverseEventId, childId, checked, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving adverse event", ex)
            Throw New Exception(ref)
        End Try
    End Sub

#End Region


#Region "Complications"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveComplication(procedureId As Integer, complicationId As Integer, childId As Integer, checked As Boolean, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveComplication(procedureId, complicationId, childId, checked, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error saving complications data", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Sub
#End Region

#Region "RX"
    <System.Web.Services.WebMethod()>
    Public Shared Function saveRXMedication(procedureId As Integer, continueMedication As Boolean, continueGPPrescription As Boolean, continueHospitalSubscription As Boolean,
                                       suggestedMedication As Boolean, medicationText As String, isModified As Nullable(Of Boolean)) As String
        Try


            Dim da As New OtherData

            da.SaveUpperGIRx(procedureId,
                            continueMedication,
                            continueGPPrescription,
                            continueHospitalSubscription,
                            suggestedMedication,
                            medicationText,
                            isModified, True)

            Return PostProcedure.loadRXPrescription(procedureId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error saving RX data", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Function loadRXPrescription(procID As Integer) As String
        Try
            Dim da As New OtherData
            Dim dtRx As DataTable = da.GetUpperGIRx(procID)
            If dtRx.Rows.Count > 0 Then
                Return dtRx.Rows(0)("Summary").ToString.Replace("<br />", Environment.NewLine)
            Else
                Return ""
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading the RX prescription", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Function
#End Region

#Region "Follow up"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveCancerFollowUpQuestions(procedureId As Integer, questionId As Integer?, optionAnswer As Integer, freeTextAnswer As String, comboBoxItemId As Integer)
        Try
            Dim da As New OtherData
            da.savePathwayPlanAnswers(procedureId, questionId, optionAnswer, freeTextAnswer, comboBoxItemId)

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error saving cancer follow up answer", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function GetEvidenceOfCancer(optionAnswer As Integer) As String
        Dim da As New DataAccess()
        Dim dt As New DataTable
        If optionAnswer = 1 Then
            dt = da.GetList("Evidence of cancer yes")
        ElseIf optionAnswer = 0 Then
            dt = da.GetList("Evidence of cancer no")
        Else
            dt = da.GetList("Evidence of cancer unknown")
        End If

        Dim dictionary As New Dictionary(Of Integer, String)()
        For Each row As DataRow In dt.Rows
            dictionary.Add(CInt(row("listid")), row("ListItemText").ToString())
        Next

        Dim stringKeysDictionary As New Dictionary(Of String, String)()
        For Each kvp As KeyValuePair(Of Integer, String) In dictionary
            stringKeysDictionary.Add(kvp.Key.ToString(), kvp.Value)
        Next

        Dim serializer As New JavaScriptSerializer()
        Dim jsonString As String = serializer.Serialize(stringKeysDictionary)
        Return jsonString
    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Sub saveAdviceAndComments(procedureId As Integer, procedureTypeId As Integer, evidenceOfCancer As Integer, patientInformed As Boolean, patientNotInformedReason As String, removedFromFastTrack As Boolean, CNSInformed As Boolean,
                                       comments As String, followUpText As String, repeatGastroscopy As Boolean, requestSurgicalReview As Boolean, otherRebleedPlanText As String, urgentTwoWeekReferral As Boolean,
                                        cancerResultId As Integer, ByVal whoStatusId As Integer, findingAlert As Boolean, imagingRequested As Boolean, cancerNotDetected As Boolean)
        Try
            Dim da As New OtherData

            'IIf(FurtherProcedureDueCountNumericTextBox.Value Is Nothing, 0, FurtherProcedureDueCountNumericTextBox.Value), _
            'IIf(ReviewDueCountNumericTextBox.Value Is Nothing, 0, CInt(ReviewDueCountNumericTextBox.Value)), _

            '******************************************************************************************************************
            'Cancer Evidence Radio Buttons
            'rblCancerEvidence.SelectedValue
            '1 = Yes, 2 = No, 3 = Unknown
            '******************************************************************************************************************
            'Dim cancerEvidence As Integer = 0

            'cancerEvidence = IIf(rblCancerEvidence.SelectedValue = "", 3, rblCancerEvidence.SelectedValue)

            Try
                da.SaveUpperGIFollowUp(procedureId,
                                       procedureTypeId,
                                       Nothing,
                                       Nothing,
                                       If(evidenceOfCancer = -1, Nothing, evidenceOfCancer),
                                       patientInformed,
                                       IIf(evidenceOfCancer = 1, False, removedFromFastTrack),
                                       HttpContext.Current.Server.HtmlEncode(patientNotInformedReason),
                                       CNSInformed,
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
                                       HttpContext.Current.Server.HtmlEncode(comments),
                                       HttpContext.Current.Server.HtmlEncode(followUpText),
                                       repeatGastroscopy, 'ReBleedPlanRepeatGastroscopy,
                                       requestSurgicalReview, 'ReBleedPlanRequestSurgicalReview,
                                       (Not String.IsNullOrWhiteSpace(otherRebleedPlanText)), 'ReBleedPlanOtherOption,
                                       otherRebleedPlanText,
                                       findingAlert,
                                       imagingRequested,
                                       urgentTwoWeekReferral,
                                       cancerResultId,
                                       If(whoStatusId = -1, Nothing, whoStatusId),
                                       cancerNotDetected,
                                       True)
            Catch ex As Exception
                Dim errorLogRef As String
                errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Follow Up.", ex)
                Throw ex

            End Try
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error saving advise and comments data", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub saveFollowUp(procedureId As Integer, procedureTypeId As Integer, noFurtherTests As Boolean, awaitingPathologyResults As Boolean, returnToId As Integer, returnToText As String, noFurtherFollowUp As Boolean, reviewLocationId As Integer,
                                       reviewLocationText As String, reviewDueTypeId As Integer, reviewText As String)
        If Not String.IsNullOrEmpty(reviewText) Then
            reviewText = Char.ToUpper(reviewText(0)) & reviewText.Substring(1)
        End If
        Dim od As New OtherData

        Try
            od.SaveUpperGIFollowUp(procedureId,
                                   procedureTypeId,
                                   noFurtherTests,
                                   awaitingPathologyResults,
                                   Nothing, 'rblCancerEvidence
                                   Nothing, 'chkPatientInformed
                                   Nothing, 'chkFastTrackRemoved
                                   Nothing, 'txtReasonWhyNotInformed
                                   Nothing, 'chkCnsMdtcInformed
                                   Nothing, 'FurtherProcedure
                                   Nothing, 'FurtherProcedureNewItemText
                                   0, 'FurtherProcedureDueCount
                                   Nothing, 'FurtherProcedureDueType
                                   Nothing, 'FurtherProcedureText
                                   returnToId, 'ReturnTo
                                   returnToText, 'ReturnToNewItemText
                                   noFurtherFollowUp, 'NoFurtherFollowUp
                                   reviewLocationId, 'ReviewLocation
                                   reviewLocationText, 'ReviewLocationNewItemText
                                   0, 'ReviewDueCount
                                   reviewDueTypeId, 'ReviewDueType
                                   HttpContext.Current.Server.HtmlEncode(reviewText), 'ReviewText
                                   Nothing, 'Comments
                                   Nothing, 'PP_PFRFollowUp
                                   Nothing, 'ReBleedPlanRepeatGastroscopy
                                   Nothing, 'ReBleedPlanRequestSurgicalReview,
                                   Nothing, 'ReBleedPlanOtherOption,
                                   Nothing, 'ReBleedPlanOtherText
                                   Nothing, 'chkFindingAlert
                                   Nothing, 'check imaging requested
                                   Nothing, 'UrgentTwoWeekReferral
                                   Nothing, 'CancerResultId
                                   Nothing, 'who status
                                   Nothing,
                                   True)

            'update UI sections to mark complete
            Dim da As New DataAccess
            da.MarkSectionComplete(procedureId, "Follow up")
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error saving Follow up data", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub saveFurtherProcedures(procedureId As Integer, procedureTypeId As Integer, furtherProcedureTypeId As Integer?, furtherProcedureTypeText As String, furtherProcedureText As String, furtherProcedureDueTypeId As Integer?, riskCategoriesTypeId As Integer?)
        Dim da As New OtherData

        Try
            da.SaveUpperGIFollowUp(procedureId,
                                   procedureTypeId,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   furtherProcedureTypeId,
                                   furtherProcedureTypeText,
                                   0,
                                   If(furtherProcedureDueTypeId = 0, Nothing, furtherProcedureDueTypeId),
                                   HttpContext.Current.Server.HtmlEncode(furtherProcedureText),
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   0,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing, 'ReBleedPlanRepeatGastroscopy,
                                   Nothing, 'ReBleedPlanRequestSurgicalReview,
                                   Nothing, 'ReBleedPlanOtherOption,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   True,
                                   riskCategoriesTypeId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error saving further procedures data", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Sub

    <Services.WebMethod()>
    Public Shared Sub UpdateDiagnoses(procedureId As Integer)
        Dim da As New DataAccess
        da.updateDiagnosesSummary(procedureId)
    End Sub

#End Region

End Class