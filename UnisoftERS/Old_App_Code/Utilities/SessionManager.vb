Imports Microsoft.VisualBasic

Public Class SessionManager
    Inherits System.Web.UI.Page

    Public Sub SetInitialSessions()
        'Session("AppVersion") = (ConfigurationManager.AppSettings("Unisoft.Version"))
        Session(Constants.SESSION_APPVERSION) = System.Reflection.Assembly.GetExecutingAssembly().GetName.Version.ToString
        Session("HospitalName") = (ConfigurationManager.AppSettings("Unisoft.Hospital"))
        Session("HospitalID") = (ConfigurationManager.AppSettings("Unisoft.HospitalID"))
        Session("Helpdesk") = (ConfigurationManager.AppSettings("Unisoft.Helpdesk"))
        Session("DisableAuditLog") = (ConfigurationManager.AppSettings("Unisoft.DisableAuditLog"))
        Session("AdvancedMode") = (ConfigurationManager.AppSettings("Unisoft.AccessMode") = "Standard")
        Session("LicenseExpired") = "False"
        Session("CountryOfOriginHealthService") = "NHS"
    End Sub

    Public Sub SetProcedureSessions(ByVal procedureId As Integer, ByVal bFromUGI As Boolean, ByVal ProcedureType As Integer, ByVal ColonType As Integer, Optional ByVal bPreviousProcedure As Boolean = False)
        Dim da As New DataAccess
        Dim dtProc = da.GetProcedure(procedureId, bFromUGI, ProcedureType, ColonType, bPreviousProcedure)
        If dtProc.Rows.Count <= 0 Then
            Session(Constants.SESSION_PROCEDURE_ID) = Nothing
            Session(Constants.SESSION_PROCEDURE_TYPE) = Nothing
            Exit Sub
        Else
            If Not bFromUGI Then
                Session(Constants.SESSION_EPISODE_NO) = Nothing
                Session(Constants.SESSION_IS_PREVIOUS_PROCEDURE) = bPreviousProcedure
                If Not bPreviousProcedure Then
                    Session(Constants.SESSION_PROCEDURE_ID) = dtProc.Rows(0)!ProcedureId
                    Session(Constants.SESSION_PROCEDURE_DATE) = dtProc.Rows(0)!CreatedOn
                Else
                    Session(Constants.SESSION_PROCEDURE_ID) = dtProc.Rows(0)!PreviousProcedureId
                End If
            Else
                Session(Constants.SESSION_PROCEDURE_ID) = Nothing
                Session(Constants.SESSION_EPISODE_NO) = dtProc.Rows(0)!ProcedureId
            End If
            Session(Constants.SESSION_PROCEDURE_TYPE) = dtProc.Rows(0)!ProcedureType
            Session(Constants.SESSION_DIAGRAM_NUMBER) = dtProc.Rows(0)!DiagramNumber
            Session(Constants.SESSION_PROCEDURE_COLONTYPE) = dtProc.Rows(0)!ColonType

            Session(Constants.SESSION_IMAGE_GENDERID) = If(dtProc.Rows(0)!ImageGenderId Is Nothing, 0, dtProc.Rows(0)!ImageGenderId)
        End If
    End Sub

    Public Sub OverrideLogin()
        Session("Authenticated") = True
    End Sub

    Public Function SetPatientSessions(ByVal patientId As Integer) As DataTable
        Dim da As New DataAccess
        Dim dtPat = da.GetPatient(patientId, Session("PKUserId"), Session("UserId"))

        If dtPat.Rows.Count > 0 Then
            Session("PatCNN") = dtPat.Rows(0)("CaseNoteNo").ToString
            Session("PatNHS") = dtPat.Rows(0)("NHSNo").ToString
            Session("PatSurname") = UCase(dtPat.Rows(0)("Surname").ToString())
            Session("PatForename") = dtPat.Rows(0)("Forename").ToString()
            If String.IsNullOrEmpty(dtPat.Rows(0)("DateOfBirth").ToString) Then
                Session("PatDOB") = ""
            Else
                Session("PatDOB") = FormatDateTime(dtPat.Rows(0)("DateOfBirth"), DateFormat.ShortDate)
            End If
            Session("PatGender") = dtPat.Rows(0)("Gender").ToString()
            Session("PatEthnicity") = dtPat.Rows(0)("Ethnicity").ToString()
            Session("PatDeceased") = dtPat.Rows(0)("Deceased").ToString()
            If String.IsNullOrEmpty(dtPat.Rows(0)("CreatedOn").ToString) Then
                Session("PatCreated") = ""
            Else
                Session("PatCreated") = FormatDateTime(dtPat.Rows(0)("CreatedOn"), DateFormat.ShortDate)
            End If

            'Session("PatAddress") = dtPat.Rows(0)("Address")
            'Session("PatPostCode") = dtPat.Rows(0)("PostCode").ToString()

            'Session("GPName") = dtPat.Rows(0)("GPName").ToString()
            'Session("GPAddress") = dtPat.Rows(0)("GPAddress").ToString()
            'Added by rony tfs-4206
            Session("Telephone") = dtPat.Rows(0)("Telephone").ToString()
            Session("Email") = dtPat.Rows(0)("Email").ToString()
            Session("MobileNo") = dtPat.Rows(0)("MobileNo").ToString()
            Session("KentOfKin") = dtPat.Rows(0)("KentOfKin").ToString()
            Session("Modalities") = dtPat.Rows(0)("Modalities").ToString()
        End If

        Return dtPat
    End Function

    Public Sub ClearPatientSessions()
        'Session(Constants.SESSION_PATIENT_SEARCH_FIELDS) = Nothing
        'Session(Constants.SESSION_PATIENT_ID) = Nothing
        If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
            Dim Cookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
            Cookie.Expires = DateTime.Now.AddDays(-1)
            HttpContext.Current.Response.Cookies.Add(Cookie)
        End If
        Session(Constants.SESSION_CASE_NOTE_NO) = Nothing
        Session(Constants.SESSION_PATIENT_WORKLIST_ID) = Nothing
        Session(Constants.SESSION_APPOINTMENT_ID) = Nothing
        Session("PatNHS") = Nothing
        Session("PatSurname") = Nothing
        Session("PatForename") = Nothing
        Session("PatDOB") = Nothing
        Session("PatGender") = Nothing
        Session("PatCreated") = Nothing
        'Session("PatAddress") = Nothing
        'Session("PatPostCode") = Nothing
        'Session("GPName") = Nothing
        'Session("GPAddress") = Nothing
        Session("GPEmailAddress") = Nothing
        Session("GPEmailAddressReasonCode") = Nothing
        Session("ConsultEmailAddress") = Nothing
        Session("ProcedureFromOrderComms") = Nothing
        Session("OrderCommsOrderId") = Nothing
    End Sub

    Public Sub ClearStaffSessions()
        Session(Constants.SESSION_LISTCON) = Nothing
        Session(Constants.SESSION_ENDO1) = Nothing
        Session(Constants.SESSION_ENDO2) = Nothing
        Session(Constants.SESSION_NURSE1) = Nothing
        Session(Constants.SESSION_NURSE2) = Nothing
        Session(Constants.SESSION_NURSE3) = Nothing
        Session(Constants.SESSION_NURSE4) = Nothing
    End Sub

    Public Sub SetQAManagementSession()

    End Sub
End Class
