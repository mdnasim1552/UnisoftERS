Imports System.Data.Common
Imports ERS.Data
Imports Telerik.Web.Spreadsheet
Imports Telerik.Web.UI
Imports Telerik.Windows.Documents.Spreadsheet.Model

Public Class PathologyResults
    Inherits System.Web.UI.UserControl

    Private DataAdapter As New DataAccess

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Public Sub fillPathologyResultsForm(procedureDate As DateTime)
        clearControls(PathologyResultsDiv)
        'select selected tab to 1st tab on initial load- this function is called from parent page on click of path results
        RadTabStrip1.SelectedIndex = 0
        RadTabStrip1.Tabs(0).Selected = True
        RadMultiPage2.PageViews(0).Selected = True


        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                   {FurtherProcedureComboBox, DataAdapter.GetFutherProcedures(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                   {FurtherProcedureDueTypeComboBox, "Further procedure period"},
                   {ReturnToComboBox, DataAdapter.GetFollowupReferredTo(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                   {ReviewLocationComboBox, DataAdapter.GetReviewLocations(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                   {ReviewDueTypeComboBox, "Review period"}
                })

        ClearPathologyResultsControls()

        Dim iProcedureID = CInt(Session(Constants.SESSION_PROCEDURE_ID))
        'Enable/Disable AdequateFNACheckBox depending on FNA biopsy performed
        Dim da As New DataAccess()
        If da.GetHasProcedureFNA(iProcedureID) Then
            AdequateFNACheckBox.Visible = True
        Else
            AdequateFNACheckBox.Visible = False
        End If

        '08 Jan 2024 : MH uses main table ERS_UpperGIFollowUp to store information and display data on page.
        'ERS_UpperGIPathologyResults table will only store data :
        'AdenomaConfirmedHistologically
        'DateOfSpecimen
        'DateOfReport
        'DateReceived
        'PathologyReportText - this is being saved in ERS_ProcedureReporting table (!)
        'LabReportNo


        Using db As New ERS.Data.GastroDbEntities

            Dim pathologyResults = db.ERS_UpperGIPathologyResults.Where(Function(fn) fn.ProcedureId = iProcedureID).FirstOrDefault

            Dim pr As New ERS.Data.ERS_ProceduresReporting
            pr = db.ERS_ProceduresReporting.Find(iProcedureID)

            If pathologyResults IsNot Nothing Then

                With pathologyResults
                    AdenomaConfirmedCheckbox.Checked = .AdenomaConfirmedHistologically
                    AdequateFNACheckBox.Checked = .AdequateFNA
                    If pr IsNot Nothing Then PathologyReportTextRadTextBox.Text = pr.PP_Pathology
                    FurtherProcedureTextBox.Text = .FurtherProcedureText
                    NoFurtherFollowUpCheckBox.Checked = .NoFurtherFollowUp
                    ReviewTextBox.Text = .ReviewText
                    LabReportNumberRadTextBox.Text = .LabReportNo
                    DateOfPathReportRadDatePicker.SelectedDate = .DateOfReport
                    DateReportReceivedRadDatePicker.SelectedDate = .DateReceived
                End With
            End If
        End Using

        'get original text from procedure follow up
        '09 Jan 2024 MH populates information from Original table ERS_UpperGIFollowUp

        DateofSpecimenRadDatePicker.SelectedDate = procedureDate
        Dim od As New OtherData
        Dim dtFu As DataTable = od.GetUpperGIFollowUp(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        If dtFu.Rows.Count > 0 Then
            Dim drFu = dtFu.Rows(0)
            FurtherProcedureOriginalTextRadTextBox.Text = CStr(drFu("FurtherProcedureText").ToString)
            FollowUpOriginalTextRadTextBox.Text = CStr(drFu("ReviewText").ToString)
            AdviceCommentsOriginalTextRadTextBox.Text = CStr(drFu("Comments").ToString)

            'Further Procedure

            If drFu("FurtherProcedure") IsNot Nothing Then
                If Not IsDBNull(drFu("FurtherProcedure")) Then
                    FurtherProcedureComboBox.SelectedValue = CInt(drFu("FurtherProcedure").ToString())
                End If
            End If
            If drFu("FurtherProcedureDueCount") IsNot Nothing Then
                If Not IsDBNull(drFu("FurtherProcedureDueCount")) Then
                    FurtherProcedureDueCountNumericTextBox.Text = drFu("FurtherProcedureDueCount").ToString()
                End If
            End If
            If drFu("FurtherProcedureDueType") IsNot Nothing Then
                If Not IsDBNull(drFu("FurtherProcedureDueType")) Then
                    FurtherProcedureDueTypeComboBox.SelectedValue = CInt(drFu("FurtherProcedureDueType").ToString())
                End If
            End If
            If drFu("FurtherProcedureText") IsNot Nothing Then
                If Not IsDBNull(drFu("FurtherProcedureText")) Then
                    FurtherProcedureTextBox.Text = drFu("FurtherProcedureText").ToString()
                End If
            End If


            'Follow up
            If drFu("ReviewLocation") IsNot Nothing Then
                If Not IsDBNull(drFu("ReviewLocation")) Then
                    ReviewLocationComboBox.SelectedValue = CInt(drFu("ReviewLocation").ToString())
                End If
            End If

            If drFu("NoFurtherFollowUp") IsNot Nothing Then
                If Not IsDBNull(drFu("NoFurtherFollowUp")) Then
                    NoFurtherFollowUpCheckBox.Checked = CBool(drFu("NoFurtherFollowUp").ToString())
                End If
            End If
            If drFu("ReturnTo") IsNot Nothing Then
                If Not IsDBNull(drFu("ReturnTo")) Then
                    ReturnToComboBox.SelectedValue = CInt(drFu("ReturnTo").ToString())
                End If
            End If

            If drFu("ReviewDueCount") IsNot Nothing Then
                If Not IsDBNull(drFu("ReviewDueCount")) Then
                    ReviewDueCountNumericTextBox.Text = drFu("ReviewDueCount").ToString()
                End If
            End If
            If drFu("ReviewDueType") IsNot Nothing Then
                If Not IsDBNull(drFu("ReviewDueType")) Then
                    ReviewDueTypeComboBox.SelectedValue = CInt(drFu("ReviewDueType").ToString())
                End If
            End If
            If drFu("ReviewText") IsNot Nothing Then
                If Not IsDBNull(drFu("ReviewText")) Then
                    ReviewTextBox.Text = drFu("ReviewText").ToString()
                    FollowUpOriginalTextRadTextBox.Text = drFu("ReviewText").ToString()
                End If
            End If


            'Advice and Comments
            If drFu("Comments") IsNot Nothing Then
                If Not IsDBNull(drFu("Comments")) Then
                    CommentsTextBox.Text = CStr(drFu("Comments").ToString())
                    AdviceCommentsOriginalTextRadTextBox.Text = CStr(drFu("Comments").ToString)
                End If
            End If



        End If

    End Sub
    Private Sub ClearPathologyResultsControls()
        CommentsTextBox.Text = ""
        AdviceCommentsOriginalTextRadTextBox.Text = ""
        ReviewTextBox.Text = ""
        FollowUpOriginalTextRadTextBox.Text = ""
        ReviewDueTypeComboBox.ClearSelection()
        ReviewDueTypeComboBox.Text = Nothing
        ReviewDueCountNumericTextBox.Text = ""
        ReturnToComboBox.ClearSelection()
        ReturnToComboBox.Text = Nothing
        NoFurtherFollowUpCheckBox.Checked = False
        ReviewLocationComboBox.ClearSelection()
        ReviewLocationComboBox.Text = Nothing
        FurtherProcedureTextBox.Text = ""
        FurtherProcedureDueTypeComboBox.ClearSelection()
        FurtherProcedureDueTypeComboBox.Text = Nothing
        FurtherProcedureDueCountNumericTextBox.Text = ""
        FurtherProcedureComboBox.ClearSelection()
        FurtherProcedureComboBox.Text = Nothing
    End Sub

    Public Event SaveAndClose()
    Protected Sub SavePathologyResultsRadButton_Click(sender As Object, e As EventArgs)
        If SaveResults() Then
            RaiseEvent SaveAndClose()
        End If
    End Sub




    Private Sub clearControls(parentControls As HtmlGenericControl)
        For Each ctrl As Control In parentControls.Controls
            If TypeOf ctrl Is CheckBox Then
                CType(ctrl, CheckBox).Checked = False
            ElseIf TypeOf ctrl Is RadioButtonList Then
                CType(ctrl, RadioButtonList).SelectedIndex = 0
            ElseIf TypeOf ctrl Is RadComboBox Then
                CType(ctrl, RadComboBox).SelectedIndex = 0
            ElseIf TypeOf ctrl Is RadTextBox Then
                CType(ctrl, RadTextBox).Text = ""
            ElseIf TypeOf ctrl Is RadDatePicker Then
                CType(ctrl, RadDatePicker).Clear()
            End If
        Next
    End Sub

    Protected Sub PathologyPreviewRadButton_Click(sender As Object, e As EventArgs)
        If SaveResults() Then

            Dim script As New StringBuilder

            script.Append("var procId;")
            script.Append("var epiNo;")
            script.Append("var procTypeId;")
            script.Append("var cType;")
            script.Append("var cnn;")
            script.Append("var diagramNum;")
            script.Append("var previewOnly;")
            script.Append("var deleteMedia;")

            script.Append("procId = '" & CStr(Session(Constants.SESSION_PROCEDURE_ID)) & "';")
            script.Append("epiNo = '0';")
            script.Append("procTypeId = '" & CStr(Session(Constants.SESSION_PROCEDURE_TYPE)) & "';")
            script.Append("cType = '" & Session(Constants.SESSION_PROCEDURE_COLONTYPE) & "';")
            script.Append("cnn = '0';")
            script.Append("diagramNum = '" & Session("PathDiagram") & "';")
            script.Append("previewOnly = 'True';")
            script.Append("deleteMedia = 'False';")

            script.Append("GetDiagramScript();")

            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", script.ToString(), True)
        End If
    End Sub

    Private Function SaveResults() As Boolean
        Dim type = ""
        Dim AddOrUpdate = ""
        Using db As New ERS.Data.GastroDbEntities

            Try
                Dim iProcedureID = CInt(Session(Constants.SESSION_PROCEDURE_ID))

                Dim rwERS_UpperGIFollowUp = db.ERS_UpperGIFollowUp.Where(Function(fn) fn.ProcedureId = iProcedureID).FirstOrDefault

                If rwERS_UpperGIFollowUp Is Nothing Then
                    AddOrUpdate = "add"
                Else
                    AddOrUpdate = "update"
                End If



                Dim pathologyResults = db.ERS_UpperGIPathologyResults.Where(Function(fn) fn.ProcedureId = iProcedureID).FirstOrDefault
                If pathologyResults Is Nothing Then
                    type = "insert"
                    pathologyResults = New ERS_UpperGIPathologyResults
                    pathologyResults.ProcedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))
                    pathologyResults.WhoCreatedId = CInt(Session("PKUserID"))
                    pathologyResults.WhenCreated = Now
                Else
                    type = "update"
                    pathologyResults.WhoUpdatedId = CInt(Session("PKUserID"))
                    pathologyResults.WhenUpdated = Now
                End If

                With pathologyResults
                    .AdenomaConfirmedHistologically = AdenomaConfirmedCheckbox.Checked
                    .AdequateFNA = AdequateFNACheckBox.Checked
                    .FurtherProcedureText = FurtherProcedureTextBox.Text
                    .NoFurtherFollowUp = NoFurtherFollowUpCheckBox.Checked
                    .ReviewText = ReviewTextBox.Text
                    .DateOfSpecimen = DateofSpecimenRadDatePicker.SelectedDate
                    .LabReportNo = LabReportNumberRadTextBox.Text
                    If DateOfPathReportRadDatePicker.SelectedDate.HasValue Then .DateOfReport = DateOfPathReportRadDatePicker.SelectedDate
                    If DateReportReceivedRadDatePicker.SelectedDate.HasValue Then .DateReceived = DateReportReceivedRadDatePicker.SelectedDate
                End With

                Dim pr As New ERS.Data.ERS_ProceduresReporting
                pr = db.ERS_ProceduresReporting.Find(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                pr.PP_Pathology = PathologyReportTextRadTextBox.Text


                If type = "insert" Then
                    db.ERS_UpperGIPathologyResults.Add(pathologyResults)
                Else
                    db.ERS_UpperGIPathologyResults.Attach(pathologyResults)
                    db.Entry(pathologyResults).State = Entity.EntityState.Modified
                End If

                'MH added on 14 Jan 2024
                'Save Post Procedure Pathology Results to original FurtherPro-FollowUp-Advice-Comments in main table ERS_UpperGIFollowUp 
                If AddOrUpdate = "add" Then
                    rwERS_UpperGIFollowUp = New ERS_UpperGIFollowUp
                    rwERS_UpperGIFollowUp.ProcedureId = iProcedureID
                End If
                With rwERS_UpperGIFollowUp
                    If FurtherProcedureComboBox.SelectedValue.HasValue Then .FurtherProcedure = FurtherProcedureComboBox.SelectedValue Else .FurtherProcedure = Nothing
                    If FurtherProcedureDueCountNumericTextBox.Text.Trim() <> "" Then .FurtherProcedureDueCount = CInt(FurtherProcedureDueCountNumericTextBox.Text) Else .FurtherProcedureDueCount = Nothing
                    If FurtherProcedureDueTypeComboBox.SelectedValue.HasValue Then .FurtherProcedureDueType = FurtherProcedureDueTypeComboBox.SelectedValue Else .FurtherProcedureDueType = Nothing
                    If FurtherProcedureTextBox.Text.Trim() <> "" Then .FurtherProcedureText = FurtherProcedureTextBox.Text Else .FurtherProcedureText = Nothing

                    'FollowUp
                    If ReviewLocationComboBox.SelectedValue.HasValue Then .ReviewLocation = ReviewLocationComboBox.SelectedValue Else .ReviewLocation = Nothing
                    .NoFurtherFollowUp = CBool(NoFurtherFollowUpCheckBox.Checked)
                    If ReturnToComboBox.SelectedValue.HasValue Then .ReturnTo = ReturnToComboBox.SelectedValue Else .ReturnTo = Nothing
                    If ReviewDueCountNumericTextBox.Text.Trim() <> "" Then .ReviewDueCount = CInt(ReviewDueCountNumericTextBox.Text) Else .ReviewDueCount = Nothing
                    If ReviewDueTypeComboBox.SelectedValue.HasValue Then .ReviewDueType = ReviewDueTypeComboBox.SelectedValue Else .ReviewDueType = Nothing
                    .ReviewText = ReviewTextBox.Text
                    .Comments = CommentsTextBox.Text

                End With

                If AddOrUpdate = "add" Then
                    db.ERS_UpperGIFollowUp.Add(rwERS_UpperGIFollowUp)
                Else
                    db.ERS_UpperGIFollowUp.Attach(rwERS_UpperGIFollowUp)
                    db.Entry(rwERS_UpperGIFollowUp).State = Entity.EntityState.Modified
                End If

                db.SaveChanges()
                Dim da As DataAccess = New DataAccess()
                da.Update_ProceduresReporting(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                da.Update_ogd_followup_summary(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                Return True
            Catch ex As Exception
                Dim errorLogRef As String
                errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on default page saving post operative complications", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
                RadNotification1.Show()
                Return False
            End Try
        End Using
    End Function

End Class