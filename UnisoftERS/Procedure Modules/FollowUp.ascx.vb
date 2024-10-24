Imports Hl7.Fhir.Model
Imports Telerik.Web.UI

Public Class FollowUp
    Inherits ProcedureControls

    Public Property procTypeID As Integer

    Public tmp As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procTypeID = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            PopulateComboBoxes()

            Dim da As New OtherData
            Dim dtFu As DataTable = da.GetUpperGIFollowUp(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtFu.Rows.Count > 0 Then
                PopulateData(dtFu.Rows(0))
            End If



        End If
    End Sub

    Private Sub PopulateComboBoxes()

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                    {ReturnToComboBox, DataAdapter.GetFollowupReferredTo(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                    {ReviewLocationComboBox, DataAdapter.GetReviewLocations(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                    {ReviewDueTypeComboBox, "Review period"}
              })

    End Sub

    Private Sub PopulateData(ByVal drFu As DataRow)

        Dim polypDetails As List(Of SitePolyps) = CType(Session("CommonPolypDetails"), List(Of SitePolyps)) '4115
        If Not IsDBNull(drFu("NoFurtherTestsRequired")) Then chkNoFurtherTestsCheckBox.Checked = CBool(drFu("NoFurtherTestsRequired"))
        If Not IsDBNull(drFu("AwaitingPathologyResults")) Then chkAwaitingPathologyResultsCheckBox.Checked = CBool(drFu("AwaitingPathologyResults"))

        'EditType by mostafiz 4115

        If polypDetails IsNot Nothing Then
            Dim firstSuccessfulPolyp = polypDetails.FirstOrDefault(Function(row) row IsNot Nothing AndAlso row.Successful)
            chkAwaitingPathologyResultsCheckBox.Checked = firstSuccessfulPolyp IsNot Nothing
            If chkAwaitingPathologyResultsCheckBox.Checked Then
                SaveRecord(True)
            End If

        End If

        'EditType by mostafiz 4115

        If Not IsDBNull(drFu("ReturnTo")) Then ReturnToComboBox.SelectedValue = CInt(drFu("ReturnTo"))
        If Not IsDBNull(drFu("NoFurtherFollowUp")) Then NoFurtherFollowUpCheckBox.Checked = CBool(drFu("NoFurtherFollowUp"))
        If Not IsDBNull(drFu("ReviewLocation")) Then ReviewLocationComboBox.SelectedValue = CInt(drFu("ReviewLocation"))

        If Not IsDBNull(drFu("ReviewDueCount")) Then
            ReviewDueCountNumericTextBox.Value = CInt(drFu("ReviewDueCount"))
        End If

        If Not IsDBNull(drFu("ReviewDueType")) Then ReviewDueTypeComboBox.SelectedValue = CInt(drFu("ReviewDueType"))
        If Not IsDBNull(drFu("ReviewText")) Then ReviewTextBox.Text = Server.HtmlDecode(CStr(drFu("ReviewText").ToString))
    End Sub

    Private Sub SaveRecord(isSaveAndClose As Boolean)
        Dim da As New OtherData

        'IIf(FurtherProcedureDueCountNumericTextBox.Value Is Nothing, 0, FurtherProcedureDueCountNumericTextBox.Value), _
        'IIf(ReviewDueCountNumericTextBox.Value Is Nothing, 0, CInt(ReviewDueCountNumericTextBox.Value)), _

        '******************************************************************************************************************
        'Cancer Evidence Radio Buttons
        'rblCancerEvidence.SelectedValue
        '1 = Yes, 2 = No, 3 = Unknown
        '******************************************************************************************************************
        Dim cancerEvidence As Integer = 0



        Try
            da.SaveUpperGIFollowUp(CInt(Session(Constants.SESSION_PROCEDURE_ID)), 'procedureid
                                   CInt(Session(Constants.SESSION_PROCEDURE_TYPE)),'protypeid
                                   chkNoFurtherTestsCheckBox.Checked,'nofurthertestsrequired
                                   chkAwaitingPathologyResultsCheckBox.Checked, 'chkAwaitingPathologyResults
                                   Nothing,'rblCancerEvidence
                                   Nothing,'chkPatientInformed
                                   Nothing,'chkFastTrackRemoved
                                   Nothing,'txtReasonWhyNotInformed
                                   Nothing,'chkCnsMdtcInformed
                                   Nothing,'FurtherProcedure
                                   Nothing,'FurtherProcedureNewItemText
                                   0,'FurtherProcedureDueCount
                                   Nothing,'FurtherProcedureDueType
                                   Nothing,'FurtherProcedureText
                                   Utilities.GetComboBoxValue(ReturnToComboBox),'ReturnTo
                                   ReturnToComboBox.SelectedItem.Text,'ReturnToNewItemText
                                   NoFurtherFollowUpCheckBox.Checked,'NoFurtherFollowUp
                                   Utilities.GetComboBoxValue(ReviewLocationComboBox),'ReviewLocation
                                   ReviewLocationComboBox.SelectedItem.Text,'ReviewLocationNewItemText
                                   0,'ReviewDueCount
                                   Utilities.GetComboBoxValue(ReviewDueTypeComboBox),'ReviewDueType
                                   Server.HtmlEncode(ReviewTextBox.Text),'ReviewText
                                   Nothing,'Comments
                                   Nothing,'PP_PFRFollowUp
                                   Nothing, 'ReBleedPlanRepeatGastroscopy
                                   Nothing, 'ReBleedPlanRequestSurgicalReview,
                                   Nothing, 'ReBleedPlanOtherOption,
                                   Nothing, 'ReBleedPlanOtherText
                                   Nothing, 'chkFindingAlert
                                   Nothing, 'chkImagingRequested
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   Nothing,
                                   True'setComplete
                                   )
            'update UI sections to mark complete
            Dim daa As New DataAccess '4115
            daa.MarkSectionComplete((CInt(Session(Constants.SESSION_PROCEDURE_ID))), "Follow up") '4115

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Follow Up.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class