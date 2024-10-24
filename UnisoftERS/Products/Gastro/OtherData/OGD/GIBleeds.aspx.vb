Imports System.Windows
Imports Hl7.Fhir.Model
Imports Telerik.Web.UI

Partial Class Products_Gastro_OtherData_OGD_GIBleeds
    Inherits OptionsBase

    Private Shared procType As Integer
    Private patientId As Int32 = 0
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
            Else
                MessageBox.Show("Your session expired, please start procedure again..")
                Response.Redirect("~/Products/Default.aspx", False)
            End If

            If Session("GIBleedsData") IsNot Nothing Then
                Dim gibleeds As GIBleeds = New GIBleeds With {
                .AgeRange = Session("GIBAgeRange"),
                .Gender = Session("GIBGender"),
                .Melaena = Session("GIBMelaena"),
                .Syncope = Session("GIBSyncope"),
                .LowestSystolicBP = Session("GIBLowestSystolicBP"),
                .HighestPulseGreaterThan100 = Session("GIBHighestPulseGreaterThan100"),
                .Urea = Session("GIBUrea"),
                .Haemoglobin = Session("GIBHaemoglobin"),
                .HeartFailure = Session("GIBHeartFailure"),
                .LiverFailure = Session("GIBLiverFailure"),
                .RenalFailure = Session("GIBRenalFailure"),
                .MetastaticCancer = Session("GIBMetastaticCancer"),
                .Diagnosis = Session("GIBDiagnosis"),
                .Bleeding = Session("GIBBleeding"),
                .OverallRiskAssessment = Session("GIBOverallRiskAssessment"),
                .BlatchfordScore = Session("BlatchfordScore"),
                .RockallScore = Session("RockallScore")
                }

                'DirectCast(Session("GIBleedsData"), GIBleeds)
                PopulateData(gibleeds)
                PopulatePatientDemographics(True)
            Else
                PopulatePatientDemographics(False)
            End If

            Dim da As New OtherData
            Dim dtBl As DataTable = da.GetUpperGIBleeds(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtBl IsNot Nothing AndAlso dtBl.Rows.Count > 0 Then
                Dim drBl = dtBl.Rows(0)
                Dim gibleeds As GIBleeds = New GIBleeds With {
                .AgeRange = drBl("AgeRange"),
                .Gender = drBl("Gender"),
                .Melaena = drBl("Melaena"),
                .Syncope = drBl("Syncope"),
                .LowestSystolicBP = drBl("LowestSystolicBP"),
                .HighestPulseGreaterThan100 = drBl("HighestPulseGreaterThan100"),
                .Urea = drBl("Urea"),
                .Haemoglobin = drBl("Haemoglobin"),
                .HeartFailure = drBl("HeartFailure"),
                .LiverFailure = drBl("LiverFailure"),
                .RenalFailure = drBl("RenalFailure"),
                .MetastaticCancer = drBl("MetastaticCancer"),
                .Diagnosis = drBl("Diagnosis"),
                .Bleeding = drBl("Bleeding"),
                .OverallRiskAssessment = drBl("OverallRiskAssessment"),
                .BlatchfordScore = drBl("BlatchfordScore"),
                .RockallScore = drBl("RockallScore")
                }

                PopulateData(gibleeds)
            End If
        End If
    End Sub

    Protected Overrides Sub RedirectToLoginPage()
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "sessionexpired", "window.parent.parent.location='" + ResolveUrl("~/Security/Logout.aspx") + "'; ", True)
    End Sub


    Private Sub PopulateData(bl As GIBleeds)
        AgeDropDownList.SelectedValue = bl.AgeRange
        GenderRadioButtonList.SelectedValue = bl.Gender
        MelaenaRadioButtonList.SelectedValue = bl.Melaena
        SyncopeRadioButtonList.SelectedValue = bl.Syncope
        LowestSystolicBPDropDownList.SelectedValue = bl.LowestSystolicBP
        HighestPulseRadioButtonList.SelectedValue = bl.HighestPulseGreaterThan100
        UreaDropDownList.SelectedValue = bl.Urea
        HaemoglobinDropDownList.SelectedValue = bl.Haemoglobin
        HeartFailureRadioButtonList.SelectedValue = bl.HeartFailure
        LiverFailureRadioButtonList.SelectedValue = bl.LiverFailure
        RenalFailureRadioButtonList.SelectedValue = bl.RenalFailure
        MetastaticCancerRadioButtonList.SelectedValue = bl.MetastaticCancer
        DiagnosisDropDownList.SelectedValue = bl.Diagnosis
        BleedingDropDownList.SelectedValue = bl.Bleeding
        OverallRiskLabel.Text = bl.OverallRiskAssessment


    End Sub

    Private Sub PopulatePatientDemographics(DefaultOnly As Boolean)
        Dim dataAccess As New DataAccess
        Dim dtPat As DataTable = dataAccess.GetPatient(patientId)
        If dtPat.Rows.Count > 0 Then
            If DefaultOnly Then
                If CStr(dtPat.Rows(0)("Gender")) = "Male" Then
                    GenderField.Value = 1
                ElseIf CStr(dtPat.Rows(0)("Gender")) = "Female" Then
                    GenderField.Value = 2
                End If
                Select Case DateDiff(DateInterval.Year, CDate(dtPat.Rows(0)("DateOfBirth")), DateTime.Today)
                    Case 0 To 60
                        AgeField.Value = 1
                    Case 60 To 79
                        AgeField.Value = 2
                    Case 80 To 200
                        AgeField.Value = 3
                    Case Else
                        AgeField.Value = 1
                End Select
            Else
                If dtPat.Rows(0)("Gender") Is Nothing Or IsDBNull(dtPat.Rows(0)("Gender")) Then
                ElseIf CStr(dtPat.Rows(0)("Gender")) = "Male" Then
                    GenderRadioButtonList.SelectedValue = 1
                ElseIf CStr(dtPat.Rows(0)("Gender")) = "Female" Then
                    GenderRadioButtonList.SelectedValue = 2
                End If
                GenderField.Value = GenderRadioButtonList.SelectedValue
                Select Case DateDiff(DateInterval.Year, CDate(dtPat.Rows(0)("DateOfBirth")), DateTime.Today)
                    Case 0 To 60
                        AgeDropDownList.SelectedValue = 1
                    Case 60 To 79
                        AgeDropDownList.SelectedValue = 2
                    Case 80 To 200
                        AgeDropDownList.SelectedValue = 3
                    Case Else
                        AgeDropDownList.SelectedValue = 1
                End Select
                AgeField.Value = AgeDropDownList.SelectedValue
            End If
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            Dim gibleeds As New GIBleeds
            With gibleeds
                .AgeRange = Utilities.GetDropDownListValue(AgeDropDownList)
                .Gender = Utilities.GetRadioValue(GenderRadioButtonList)
                .Melaena = Utilities.GetRadioValue(MelaenaRadioButtonList)
                .Syncope = Utilities.GetRadioValue(SyncopeRadioButtonList)
                .LowestSystolicBP = Utilities.GetDropDownListValue(LowestSystolicBPDropDownList)
                .HighestPulseGreaterThan100 = Utilities.GetRadioValue(HighestPulseRadioButtonList)
                .Urea = Utilities.GetDropDownListValue(UreaDropDownList)
                .Haemoglobin = Utilities.GetDropDownListValue(HaemoglobinDropDownList)
                .HeartFailure = Utilities.GetRadioValue(HeartFailureRadioButtonList)
                .LiverFailure = Utilities.GetRadioValue(LiverFailureRadioButtonList)
                .RenalFailure = Utilities.GetRadioValue(RenalFailureRadioButtonList)
                .MetastaticCancer = Utilities.GetRadioValue(MetastaticCancerRadioButtonList)
                .Diagnosis = Utilities.GetDropDownListValue(DiagnosisDropDownList)
                .Bleeding = Utilities.GetDropDownListValue(BleedingDropDownList)
                .OverallRiskAssessment = OverallScroreField.Value
                .RockallScore = RockallProgressBar.Value
                .BlatchfordScore = BlatchfordProgressBar.Value
            End With

            Dim od As New OtherData
            od.SaveUpperGIBleeds(IInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                    gibleeds.AgeRange,
                                    gibleeds.Gender,
                                    gibleeds.Melaena,
                                    gibleeds.Syncope,
                                    gibleeds.LowestSystolicBP,
                                    gibleeds.HighestPulseGreaterThan100,
                                    gibleeds.Urea,
                                    gibleeds.Haemoglobin,
                                    gibleeds.HeartFailure,
                                    gibleeds.LiverFailure,
                                    gibleeds.RenalFailure,
                                    gibleeds.MetastaticCancer,
                                    gibleeds.Diagnosis,
                                    gibleeds.Bleeding,
                                    gibleeds.OverallRiskAssessment,
                                    gibleeds.BlatchfordScore,
                                    gibleeds.RockallScore)

            ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "CloseMe", "CloseWindow();", True)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Bleeds.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class