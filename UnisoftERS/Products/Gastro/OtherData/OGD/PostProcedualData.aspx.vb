Imports System.Data.SqlClient
Imports ERS.Data
Imports Telerik.Web.UI

Public Class PostProcedualData
    Inherits OptionsBase

#Region "Properties"
    Protected ReadOnly Property ProcedureID As Integer
        Get
            Return CInt(Session(Constants.SESSION_PROCEDURE_ID))
        End Get
    End Property

    Protected ReadOnly Property ProcType As Integer
        Get
            Return CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        End Get
    End Property
#End Region

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        If Not IsPostBack Then
            PostOpSeveritySQLDataSource.ConnectionString = DataAccess.ConnectionStr
            PostOpResolutionSQLDataSource.ConnectionString = DataAccess.ConnectionStr
            EndoscopistSQLDataSource.ConnectionString = DataAccess.ConnectionStr
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Request.QueryString.Count > 0 Then
                Page.Title = Request.QueryString("title")
                Select Case Request.QueryString("type").ToLower()
                    Case "urease-results"
                        loadUreaseResults()
                        UreaseResultsPanel.Visible = True
                    Case "post-op-complications"
                        loadPostOperativeForm()
                        PostOpComplicationsPanel.Visible = True
                    Case "comfort-levels"
                        Dim da As New DataAccess
                        Dim dt = da.GetPatientComfortLevel(ProcedureID)
                        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                            loadComfortLevels(dt.Rows(0))
                        End If
                        PatientComfortLevelPanel.Visible = True
                    Case "breath-test"
                        loadBreathTestResults()
                        BreathTestPanel.Visible = True
                End Select
            End If
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

    Private Sub closeWindow()
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "closePostProceduralDataWindow", "CloseWindow();", True)
    End Sub

    Private Sub showLogError(logMessage As String, ex As Exception)
        Dim errorLogRef = LogManager.LogManagerInstance.LogError(logMessage, ex)
        Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
        RadNotification1.Show()
    End Sub

#Region "Patient Comfort Levels"
    Private Sub loadComfortLevels(dr As DataRow)
        UCSedationScore.Visible = True
        UCDiscomfortScore.Visible = True
        'If dr.IsNull("PatSedation") Then
        '    PatSedationRadioButtonList.Enabled = True
        'Else
        '    PatSedationRadioButtonList.SelectedValue = CInt(dr("PatSedation"))
        'End If

        'If dr.IsNull("PatDiscomfortNurse") Then
        '    PatDiscomfortNurseRadioButtonList.Enabled = True
        'Else
        '    PatDiscomfortNurseRadioButtonList.SelectedValue = CInt(dr("PatDiscomfortNurse"))
        'End If

        'PatSedationAsleepResponseStateComboBox.SelectedValue = CInt(dr("PatSedationAsleepResponseState"))

        If Not dr.IsNull("PatDiscomfortPatient") Then PatDiscomfortPatientRadioButtonList.SelectedValue = CInt(dr("PatDiscomfortPatient"))
        'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "TogglePatSedation", "TogglePatSedationComboBox();", True)
    End Sub

    Protected Sub SavePatientComfortLevelsRadButton_Click(sender As Object, e As EventArgs)
        Try
            If String.IsNullOrWhiteSpace(PatDiscomfortPatientRadioButtonList.SelectedValue) Then
                Utilities.SetNotificationStyle(RadNotification1, "Please specify a discomfort score.", True)
                Exit Sub
            End If
            Dim patientDiscomfortScore = CInt(PatDiscomfortPatientRadioButtonList.SelectedValue)
            DataAccess.ExecuteSQL("UPDATE ERS_UpperGIQA SET PatDiscomfortPatient = @PatientScore, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE ProcedureID = @ProcedureID ; Exec UpperGIQA @ProcedureID ; ",
                                  New SqlParameter() {New SqlParameter("@PatientScore", patientDiscomfortScore), New SqlParameter("@ProcedureId", ProcedureID), New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID")))})

            closeWindow()
        Catch ex As Exception
            showLogError("Error occured on default page saving patient comfort levels", ex)
        End Try
    End Sub
#End Region

#Region "Urease Results"
    Private Sub loadUreaseResults()
        Dim da As New SpecimensTaken
        Dim dtUreaseResults As DataTable = da.GetUreaseResult(ProcedureID)
        If dtUreaseResults IsNot Nothing AndAlso dtUreaseResults.Rows.Count > 0 Then
            Dim dr = dtUreaseResults.Rows(0)
            If CBool(dr("Urease")) = True Then
                NoResultsDiv.Visible = False
                UreaseResultsDiv.Visible = True
                If CInt(dr("UreaseResult")) > 0 Then UreaseResultRadioButtonList.SelectedValue = CInt(dr("UreaseResult"))
                AddToOutstandingCheckBox.Checked = False
            Else
                NoResultsDiv.Visible = True
                SaveUreaseResultsButton.Visible = False
                UreaseResultsDiv.Visible = False
            End If
        End If
    End Sub
    Protected Sub SaveUreaseResultsButton_Click(sender As Object, e As EventArgs)
        Try
            Dim ureaseResult = UreaseResultRadioButtonList.SelectedValue
            Dim da As New SpecimensTaken
            If String.IsNullOrEmpty(ureaseResult) Then
                ureaseResult = "0"
            End If
            da.UpdateUreaseResult(ProcedureID, ureaseResult)
            closeWindow()
        Catch ex As Exception
            showLogError("Error occured saving post procedure urease results", ex)
        End Try
    End Sub

#End Region

#Region "Post-op Complications"
    Private Sub loadPostOperativeForm()
        Try
            'set data source
            EndoscopistSQLDataSource.SelectParameters("ProcedureID").DefaultValue = ProcedureID
            PostOpComplicationRecordedByComboBox.DataSourceID = "EndoscopistSQLDataSource"
            PostOpComplicationRecordedByComboBox.DataTextField = "EndoName"
            PostOpComplicationRecordedByComboBox.DataValueField = "ConsultantID"
            PostOpComplicationRecordedByComboBox.DataBind()

            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "loadPostOpComplicationsControls", "showPostOpComplications();", True)

            Using db As New ERS.Data.GastroDbEntities
                Dim complications = db.ERS_PostOperativeComplications.Where(Function(fn) fn.ProcedureId = ProcedureID).FirstOrDefault
                If complications IsNot Nothing Then
                    With complications
                        AspirationCheckBox.Checked = .Aspiration
                        ArrythmiaCheckBox.Checked = .Arrythmia
                        OesophagealPerforationCheckBox.Checked = .OesophagealPerforation
                        If .OesophagealPerforation Then OesophagealServerityComboBox.SelectedValue = .OesophagealPerforationSeverity
                        GastricPerforationCheckbox.Checked = .GastricPerforation
                        If .GastricPerforation Then GastricSeverityComboBox.SelectedValue = .GastricPerforationSeverity
                        BleedingFollowingPolypectomyCheckBox.Checked = .BleedingFollowingPolypectomy
                        If .BleedingFollowingPolypectomy Then BleedingFollowingPolypectomySeverityComboBox.SelectedValue = .BleedingFollowingPolypectomySeverity
                        MajorBleedingFollowingInjectionCheckBox.Checked = .MajorBleedingFollowingInjection
                        If .MajorBleedingFollowingInjection Then MajorBleedingFollowingInjectionSeverityComboBox.SelectedValue = .MajorBleedingFollowingInjectionSeverity
                        MajorUlcerationFollowingInjectionCheckBox.Checked = .MajorUlcerationFollowingInjection
                        If .Haemostasis Then HaemostasisComboBox.SelectedValue = .HaemostasisSeverity
                        HaemostasisCheckBox.Checked = .Haemostasis
                        If .MajorUlcerationFollowingInjection Then MajorUlcerationFollowingInjectionSeverityComboBox.SelectedValue = .MajorUlcerationFollowingInjectionSeverity
                        PancreatitsCheckBox.Checked = .Pancreatits
                        If .Pancreatits Then PancreatitsSeverityComboBox.SelectedValue = .PancreatitsSeverity
                        AscendingCholangitisCheckBox.Checked = .AscendingCholangitis
                        If .AscendingCholangitis Then AscendingCholangitisSeverityComboBox.SelectedValue = .AscendingCholangitisSeverity
                        PerforationCheckBox.Checked = .Perforation
                        If .Perforation Then PerforationSeverityComboBox.SelectedValue = .PerforationSeverity
                        HaemorrhageCheckBox.Checked = .Haemorrhage
                        If .Haemorrhage Then HaemorrhageSeverityComboBox.SelectedValue = .HaemorrhageSeverity
                        OGDOtherFocalTextBox.Text = .OtherFocal
                        PostOpComplicationResolutionRadioButtonList.SelectedValue = .Resolution
                        If .DateOfDeath.HasValue Then PostOpComplicationDodDateInput.SelectedDate = .DateOfDeath
                        PostOpComplicationReadmissionRadioButtonList.SelectedValue = .Readmission
                        If .Readmission Then
                            ReadmissionDateDateInput.SelectedDate = .ReadmissionDate
                            ReadmissionReasonRadTextBox.Text = .ReadmissionReason
                        End If
                        PostOpComplicationRecordedByComboBox.SelectedValue = .RecordedBy
                        PostOpComplicationDateRecordedDateInput.SelectedDate = .RecordedDate
                        If Not String.IsNullOrWhiteSpace(.OtherComments) Then PostOpComplicationOtherCommentsTextBox.Text = .OtherComments

                        PostPEGInfectionCheckBox.Checked = .InfectionFollowingPEG
                        PostPEGInfectionAntibioticsCheckBox.Checked = .AntibioticsForInfectionFollowingPEG
                        PostPEGPeritonitisCheckBox.Checked = .PeritonitisFollowingPEG

                        'Added by rony tfs-1861
                        ScopeDamagedCheckBox.Checked = .ScopeDamaged
                        ScopeDiscoveredComboBox.SelectedValue = .ScopeDiscovered
                        ScopeDiscoveredOtherTextBox.Text = .ScopeDiscoveredOther

                    End With
                Else
                    clearControls(PostOpComplicationsDiv)
                    PostOpComplicationDateRecordedDateInput.SelectedDate = Now
                End If
            End Using
        Catch ex As Exception
            showLogError("Error occured loading post operative complications", ex)
        End Try
    End Sub

    Protected Sub SavePostOpComplicationsRadButton_Click(sender As Object, e As EventArgs)
        Dim type = ""
        Try
            Using db As New ERS.Data.GastroDbEntities

                Dim complications = db.ERS_PostOperativeComplications.Where(Function(fn) fn.ProcedureId = ProcedureID).FirstOrDefault
                If complications Is Nothing Then
                    type = "insert"
                    complications = New ERS_PostOperativeComplications
                    complications.ProcedureId = ProcedureID
                Else
                    type = "update"
                End If

                With complications
                    .Aspiration = AspirationCheckBox.Checked
                    .Arrythmia = ArrythmiaCheckBox.Checked
                    .OesophagealPerforation = OesophagealPerforationCheckBox.Checked
                    If OesophagealPerforationCheckBox.Checked Then .OesophagealPerforationSeverity = OesophagealServerityComboBox.SelectedValue
                    .GastricPerforation = GastricPerforationCheckbox.Checked
                    If GastricPerforationCheckbox.Checked Then .GastricPerforationSeverity = GastricSeverityComboBox.SelectedValue
                    .BleedingFollowingPolypectomy = BleedingFollowingPolypectomyCheckBox.Checked
                    If BleedingFollowingPolypectomyCheckBox.Checked Then .BleedingFollowingPolypectomySeverity = BleedingFollowingPolypectomySeverityComboBox.SelectedValue
                    .MajorBleedingFollowingInjection = MajorBleedingFollowingInjectionCheckBox.Checked
                    If MajorBleedingFollowingInjectionCheckBox.Checked Then .MajorBleedingFollowingInjectionSeverity = MajorBleedingFollowingInjectionSeverityComboBox.SelectedValue
                    .MajorUlcerationFollowingInjection = MajorUlcerationFollowingInjectionCheckBox.Checked
                    If MajorUlcerationFollowingInjectionCheckBox.Checked Then .MajorUlcerationFollowingInjectionSeverity = MajorUlcerationFollowingInjectionSeverityComboBox.SelectedValue
                    .Haemostasis = HaemostasisCheckBox.Checked
                    If HaemostasisCheckBox.Checked Then .HaemostasisSeverity = HaemostasisComboBox.SelectedValue
                    .Pancreatits = PancreatitsCheckBox.Checked
                    If PancreatitsCheckBox.Checked Then .PancreatitsSeverity = PancreatitsSeverityComboBox.SelectedValue
                    .AscendingCholangitis = AscendingCholangitisCheckBox.Checked
                    If AscendingCholangitisCheckBox.Checked Then .AscendingCholangitisSeverity = AscendingCholangitisSeverityComboBox.SelectedValue
                    .Perforation = PerforationCheckBox.Checked
                    If PerforationCheckBox.Checked Then .PerforationSeverity = PerforationSeverityComboBox.SelectedValue
                    .Haemorrhage = HaemorrhageCheckBox.Checked
                    If HaemorrhageCheckBox.Checked Then .HaemorrhageSeverity = HaemorrhageSeverityComboBox.SelectedValue
                    .OtherFocal = OGDOtherFocalTextBox.Text
                    .Resolution = PostOpComplicationResolutionRadioButtonList.SelectedValue
                    If PostOpComplicationDodDateInput.SelectedDate.HasValue Then .DateOfDeath = PostOpComplicationDodDateInput.SelectedDate
                    .Readmission = CBool(PostOpComplicationReadmissionRadioButtonList.SelectedValue)

                    If CBool(PostOpComplicationReadmissionRadioButtonList.SelectedValue) Then
                        .ReadmissionDate = ReadmissionDateDateInput.SelectedDate.Value
                        .ReadmissionReason = ReadmissionReasonRadTextBox.Text
                    End If

                    .InfectionFollowingPEG = PostPEGInfectionCheckBox.Checked
                    .AntibioticsForInfectionFollowingPEG = PostPEGInfectionAntibioticsCheckBox.Checked
                    .PeritonitisFollowingPEG = PostPEGPeritonitisCheckBox.Checked
                    .RecordedBy = PostOpComplicationRecordedByComboBox.SelectedValue
                    .RecordedDate = PostOpComplicationDateRecordedDateInput.SelectedDate.Value
                    If Not String.IsNullOrWhiteSpace(PostOpComplicationOtherCommentsTextBox.Text) Then .OtherComments = PostOpComplicationOtherCommentsTextBox.Text

                    'Added by rony tfs-1861
                    .ScopeDamaged = ScopeDamagedCheckBox.Checked
                    If ScopeDamagedCheckBox.Checked Then
                        .ScopeCreatedDate = DateTime.Now
                        .ScopeDiscovered = ScopeDiscoveredComboBox.SelectedValue
                        .ScopeDiscoveredOther = ScopeDiscoveredOtherTextBox.Text
                        'If ScopeDamagedCheckBox.Checked And ScopeDiscoveredComboBox.SelectedValue = 3 Then
                        '    .ScopeDiscoveredOther = ScopeDiscoveredOtherTextBox.Text
                        'Else
                        '    .ScopeDiscoveredOther = ""
                    End If
                    '1861 -Raihan
                    If Not ScopeDamagedCheckBox.Checked Then 'if unchecked nothing should get saved
                        .ScopeDamaged = 0
                        .ScopeDiscovered = 100 'not to map any dropdown value
                        .ScopeDiscoveredOther = ""
                    End If

                End With

                If type = "insert" Then
                    db.ERS_PostOperativeComplications.Add(complications)
                Else
                    complications.WhoUpdatedId = CInt(HttpContext.Current.Session("PKUserID"))
                    complications.WhenUpdated = DateTime.Now
                    db.ERS_PostOperativeComplications.Attach(complications)
                    db.Entry(complications).State = Entity.EntityState.Modified
                End If

                db.SaveChanges()
            End Using

            closeWindow()
        Catch ex As Exception
            showLogError("Error occured saving post operative complications", ex)
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "loadPostOpComplicationsControls", "showPostOpComplications();", True) 'recall function as postback will reload page with all controls shown regardless

        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function IsPEG(procedureId As Integer) As Boolean
        Try
            Dim da As New DataAccess
            Return da.IsPEGProcedure(procedureId)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in PostProcedualData.IsPEG", ex)
            Throw ex
        End Try
    End Function
#End Region

#Region "Breath Test"
    Protected Sub loadBreathTestResults()
        Dim da As New SpecimensTaken
        Dim sSQL = "SELECT ISNULL(BreathTestResult,'') as Result FROM ERS_Procedures WHERE ProcedureID = @ProcedureID"

        Dim dtBreathTestResults As DataTable = DataAccess.ExecuteSQL(sSQL, New SqlParameter() {New SqlParameter("@ProcedureID", ProcedureID)})
        If dtBreathTestResults IsNot Nothing AndAlso dtBreathTestResults.Rows.Count > 0 Then
            BreathTestResultRadioButtonList.SelectedValue = dtBreathTestResults.Rows(0)("Result")
        End If
    End Sub

    Protected Sub SaveBreathTestResultsRadButton_Click(sender As Object, e As EventArgs)
        If Not String.IsNullOrWhiteSpace(BreathTestResultRadioButtonList.SelectedValue) Then
            Dim breathTestResult = CInt(BreathTestResultRadioButtonList.SelectedValue)

            DataAccess.ExecuteSQL("UPDATE ERS_Procedures SET BreathTestResult = @BreathTestResult WHERE ProcedureID = @ProcedureID ; Exec Procedure_Updated @ProcedureID ; ",
                                      New SqlParameter() {New SqlParameter("@BreathTestResult", breathTestResult), New SqlParameter("@ProcedureId", ProcedureID)})
            closeWindow()
        End If
    End Sub
#End Region

End Class