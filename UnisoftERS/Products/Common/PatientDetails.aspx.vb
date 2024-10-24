Imports Hl7.Fhir.Model
Imports Telerik.Web.UI

Partial Class Products_Common_PatientDetails
    Inherits PageBase

    Private Property FormState As String
        Get
            If ViewState("FormState") IsNot Nothing Then
                Return CStr(ViewState("FormState"))
            End If
            Return "Insert"
        End Get
        Set(ByVal value As String)
            ViewState("FormState") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load

        lblPatientNHSNo.Text = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " no "

        If Not Page.IsPostBack Then
            Session("NewPatientAdded") = Nothing
            Session("GPSelectedValue") = Nothing
            Session("PracticeSelectedValue") = Nothing
            InitForm()
        End If
    End Sub

    Private Sub InitForm()


        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{EthnicOriginComboBox, ""}}, DataAdapter.GetEthnicOrigins(EthnicOriginsUsedIn.AllOthers), "Details", "EthnicId")
        'Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{GPNameComboBox, ""}}, DataAdapter.GetGPs(), "FullName", "GPId")

        'Utilities.LoadDropdown(EthnicOriginComboBox, DataAdapter.GetEthnicOrigins(EthnicOriginsUsedIn.AllOthers), "EthnicOrigin", "EthnicOriginId")
        'Utilities.LoadDropdown(GPNameComboBox, DataAdapter.GetGPs(), "FullName", "GPId")

        'Annoyingly RadDateInput control's default minimum accepted date value is only 1 Jan 1980! Hence need to set it explicitly.
        DobDateInput.MinDate = DateTime.MinValue
        DobDateInput.MaxDate = DateTime.Now
        DodDateInput.MinDate = DateTime.MinValue
        DodDateInput.MaxDate = DateTime.Now

        If Not String.IsNullOrEmpty(Request.QueryString("NewPatient")) Then
            FormState = "Insert"
            Me.Title = "Add New Patient"
            'LastModifiedDiv.Style.Add("visibility", "hidden")
            LastModifiedDiv.Attributes("class") = "subText"
            LastModifiedDiv.InnerText = "New Patient"
            LastModifiedDiv.Style.Add("padding", "0px 0px")

        ElseIf Not String.IsNullOrEmpty(Request.QueryString("PatientID")) Then
            FormState = "Update"

            Dim dtPat As DataTable = DataAdapter.GetPatient(CInt(Request.QueryString("PatientID")), Session("PKUserId"), Session("UserId"))
            If dtPat.Rows.Count > 0 Then
                PopulateData(dtPat.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(ByVal drPat As DataRow)
        If FormState = "Update" Then
            CaseNoteNoTextBox.Enabled = False
        End If

        If Not IsDBNull(drPat("ModifiedOn")) Then
            LastModifiedLabel.Text = IIf(Not IsDBNull(drPat("ModifiedOn")),
                                         Convert.ToDateTime(drPat("ModifiedOn")).ToString("dd/MM/yyyy"),
                                         "")
            LastModifiedLabel.Text = LastModifiedLabel.Text.Replace("00:00", "")
        End If


        If Not IsDBNull(drPat("Title")) Then TitleTextBox.Text = CStr(drPat("Title"))
        If Not IsDBNull(drPat("Forename")) Then ForenameTextBox.Text = CStr(drPat("Forename"))
        If Not IsDBNull(drPat("Surname")) Then SurnameTextBox.Text = CStr(drPat("Surname"))
        If Not IsDBNull(drPat("DateOfBirth")) Then DobDateInput.SelectedDate = drPat("DateOfBirth")
        If Not IsDBNull(drPat("CaseNoteNo")) Then CaseNoteNoTextBox.Text = CStr(drPat("CaseNoteNo"))
        If Not IsDBNull(drPat("NHSNo")) Then NhsNoTextBox.Text = CStr(drPat("NHSNo"))
        ' ???? If Not IsDBNull(drPat("District")) Then DistrictTextBox.Text = CStr(drPat("District"))

        If Not IsDBNull(drPat("GenderCode")) Then
            GenderRadioButtonList.SelectedValue = CStr(drPat("GenderCode"))
            'If CStr(drPat("Gender")) = "M" Then
            '    GenderRadioButtonList_M.Checked = True
            'ElseIf CStr(drPat("Gender")) = "F" Then
            '    GenderRadioButtonList_F.Checked = True
            'End If
        End If

        If Not IsDBNull(drPat("Ethnicity")) Then EthnicOriginComboBox.SelectedValue = CStr(drPat("Ethnicity"))

        If Not IsDBNull(drPat("Address1")) Then PatAddressTextBox.Text = CStr(drPat("Address1"))
        If Not IsDBNull(drPat("Address2")) Then PatAddress2TextBox.Text = CStr(drPat("Address2"))
        If Not IsDBNull(drPat("Town")) Then PatAddressTownTextBox.Text = CStr(drPat("Town"))
        If Not IsDBNull(drPat("County")) Then PatAddressCountyTextBox.Text = CStr(drPat("County"))

        If Not IsDBNull(drPat("PostCode")) Then PostCodeTextBox.Text = CStr(drPat("PostCode"))
        If Not IsDBNull(drPat("DateOfDeath")) Then DodDateInput.SelectedDate = Date.ParseExact(drPat("DateOfDeath"), "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo).ToString("dd/MM/yyyy")
        If Not IsDBNull(drPat("DHACode")) Then DhaCodeTextBox.Text = CStr(drPat("DHACode"))

        ' ??? If Not IsDBNull(drPat("AdvocateRequired")) Then AdvocateRequiredCheckBox.Checked = CBool(drPat("AdvocateRequired"))
        ' ??? If Not IsDBNull(drPat("DHACode")) Then DhaCodeTextBox.Text = CStr(drPat("DHACode"))
        ' ??? If Not IsDBNull(drPat("DateOfDeath")) Then DodDateInput.SelectedDate = CDate(drPat("DateOfDeath"))
        If Not IsDBNull(drPat("GPId")) Then
            Dim gpId As Nullable(Of Integer) = drPat("GPId")
            GPIDHiddenField.Value = gpId
            PopulateGPField(gpId)
        End If
        If Not IsDBNull(drPat("PracticeId")) Then PracticeIDHiddenField.Value = drPat("PracticeId")
        Me.Title = "Edit Patient: " & SurnameTextBox.Text & ", " & ForenameTextBox.Text & " (" & DobDateInput.SelectedDate & ", " & CaseNoteNoTextBox.Text & ")"

        'Fieldset1.Style.Add("display", "none")
        'If Not IsDBNull(drPat("GPAddress")) Then GPAddressTextBox.Text = CStr(drPat("GPAddress"))
        'Added by rony tfs-4206
        If Not IsDBNull(drPat("Email")) Then EmailTextBox.Text = CStr(drPat("Email"))
        If Not IsDBNull(drPat("Telephone")) Then TelephoneNoTextBox.Text = CStr(drPat("Telephone"))
        If Not IsDBNull(drPat("MobileNo")) Then MobileNoTextBox.Text = CStr(drPat("MobileNo"))
        If Not IsDBNull(drPat("KentOfKin")) Then KentOfKinTextBox.Text = CStr(drPat("KentOfKin"))
        If Not IsDBNull(drPat("Modalities")) Then ModalitiesTextBox.Text = CStr(drPat("Modalities"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            Dim patId As Nullable(Of Integer)
            Dim patientId As Int32 = 0

            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
            End If

            If FormState = "Insert" Then
                patId = Nothing
            ElseIf FormState = "Update" Then
                patId = CInt(Request.QueryString("PatientID")) 'Added by rony tfs-4206
            End If

            'check patient exists... notify and stop from adding if so
            Dim dtPatient = DataAdapter.GetPatientByCNN(CaseNoteNoTextBox.Text)
            If (dtPatient IsNot Nothing AndAlso dtPatient.Rows.Count > 0) AndAlso FormState = "Insert" Then
                Utilities.SetNotificationStyle(ErrorRadNotification, "Patient already exists with the same hospital number.", True)
                ErrorRadNotification.Show()
            Else
                Dim GPNumber, PracticeNumber As Integer
                If Not Integer.TryParse(GPIDHiddenField.Value, GPNumber) Then
                    GPNumber = 0
                End If
                If Not Integer.TryParse(PracticeIDHiddenField.Value, PracticeNumber) Then
                    PracticeNumber = 0
                End If
                patientId =
                    DataAdapter.SavePatient(patId,
                                            CaseNoteNoTextBox.Text,
                                            TitleTextBox.Text,
                                            ForenameTextBox.Text,
                                            SurnameTextBox.Text,
                                            DobDateInput.SelectedDate,
                                            NhsNoTextBox.Text,
                                            PatAddressTextBox.Text,
                                            PatAddress2TextBox.Text,
                                            PatAddressTownTextBox.Text,
                                            PatAddressCountyTextBox.Text,
                                            PostCodeTextBox.Text,
                                            TelephoneNoTextBox.Text,'Added by rony tfs-4206
                                            GenderRadioButtonList.SelectedValue,
                                            Utilities.GetComboBoxValue(EthnicOriginComboBox, True),
                                            Nothing,
                                            Nothing,
                                            DistrictTextBox.Text,
                                            DhaCodeTextBox.Text,
                                            GPNumber,
                                            PracticeNumber,
                                            DodDateInput.SelectedDate,
                                            AdvocateRequiredCheckBox.Checked,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            Nothing,
                                            EmailTextBox.Text,
                                            MobileNoTextBox.Text,
                                            KentOfKinTextBox.Text,
                                            ModalitiesTextBox.Text) 'Added by rony tfs-4206

                If FormState = "Insert" Then
                    Session("NewPatientAdded") = True
                End If

                Dim CookieTime As Int32 = ConfigurationManager.AppSettings("CookieTime")
                '--- Update Cookies
                If Request.Cookies("patientId") Is Nothing Then
                    Dim aCookie As New HttpCookie("patientId")
                    aCookie.Value = patientId
                    aCookie.Expires = DateTime.Now.AddMinutes(CookieTime)
                    Response.Cookies.Add(aCookie)
                Else
                    Dim Cookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                    Cookie.Value = patientId
                    Cookie.Expires = DateTime.Now.AddMinutes(CookieTime)
                    Response.Cookies.Add(Cookie)
                End If
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)

                Utilities.SetNotificationStyle(RadNotification1)
                RadNotification1.Show()
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving patient details.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub PatDetailsAjaxManager_AjaxRequest(sender As Object, e As AjaxRequestEventArgs) Handles PatDetailsAjaxManager.AjaxRequest
        If Session("GPSelectedValue") IsNot Nothing Then
            GPIDHiddenField.Value = Session("GPSelectedValue")
            PracticeIDHiddenField.Value = Session("PracticeIDSelectedValue")
            PopulateGPField(CInt(Session("GPSelectedValue")))

            'clear session. if "add new 
            Session("GPSelectedValue") = Nothing
            Session("PracticeSelectedValue") = Nothing
        End If

    End Sub

    Private Sub PopulateGPField(ByVal gpId As Integer)
        Dim dtGP As DataTable = DataAdapter.GetGP(gpId)
        If dtGP.Rows.Count > 0 Then
            GPRadSearchBox.Text = dtGP.Rows(0)("CompleteName")
        End If
    End Sub

    Protected Overrides Sub RedirectToLoginPage()
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "sessionexpired", "window.parent.location='" + ResolveUrl("~/Security/Logout.aspx") + "'; ", True)
    End Sub
End Class
