Imports System.Linq
Imports Microsoft.VisualBasic
Imports ERS.Data
Imports System.Data.SqlClient
Imports System.Reflection

Public Class BusinessLogic
    Inherits System.Web.UI.Page

    Public Shared consultantList As List(Of ERS.Data.GetAllConsultant_Result)   '## Will be used accross the ERS App... Load the Consulant/Staff once then Re-use the List!
    'Public Shared therapProcedureList As List(Of ERS.Data.ERS_Lists)   '## Will be used accross the Therapeutical Procedure List.. more than 20 Combo boxes will need these values!

    Public Function ValidateUser(ByVal userName As String, ByVal pwd As String, ByRef resetPassword As Boolean, ByVal operatingHospitalId As Integer) As String
        Dim da As New DataAccess

        If (Session("isSSO") = "True") Then
            Dim sFullName = Session("DisplayName")
            Dim sSurName = Session("SurName")
            Dim sGivenName = Session("GivenName")
            If String.IsNullOrEmpty(sSurName) = True And String.IsNullOrEmpty(sGivenName) = True Then
                Dim sFullNameParts As String() = sFullName.split(New Char() {" "c})
                If sFullNameParts.Count > 0 Then
                    sGivenName = sFullNameParts(0)
                    sSurName = sFullName.Replace(sGivenName, "")
                End If

            Else
                If String.IsNullOrEmpty(sFullName) = True Then
                    sFullName = sGivenName & " " & sSurName
                End If

            End If
            Dim retVal
            If (Session("isSSO") = "True" And ConfigurationManager.AppSettings("TrustNamePassedInSSOADGroupName") = "Y") Then
                retVal = da.InsertSSOUserForTrust(Session("UserID"), sGivenName, sSurName, sFullName, Session("AzureADGroups"), CInt(Session("OperatingHospitalID")))
            Else
                retVal = da.InsertSSOUserWithGroup(Session("UserID"), sGivenName, sSurName, sFullName, Session("AzureADGroups"), CInt(Session("OperatingHospitalID")))
            End If
        End If
        Dim userDataTable As DataTable = da.GetUserByUserName(userName)

        'Does user exist in DB ?
        Dim userInDatabase As Boolean = userDataTable.Rows.Count > 0

        Dim inactiveAccountStatus As String
        'Is AD Authentication configured ?
        Dim adAuthentication As Boolean = ConfigurationManager.AppSettings("Unisoft.ActiveDirectoryLogin").ToLower() = "true"
        'Is ReadOnly login enabled for AD/Passthrough ?
        Dim readOnlyAccess As Boolean = ConfigurationManager.AppSettings("ActiveDirectoryReadOnlyDefault")
        Session("inactiveAccountStatus") = String.Empty

        'Is Session Authenticated
        If HttpContext.Current.Request.IsAuthenticated Then
            'AD or Passthrough Authentication
            If userInDatabase Then
                inactiveAccountStatus = IsAccountActive(userDataTable)

                If Not String.IsNullOrEmpty(inactiveAccountStatus) Then
                    If readOnlyAccess AndAlso Not Session("Suppressed") Then
                        inactiveAccountStatus = inactiveAccountStatus + "</br>" + da.GetCustomText("LoginReadOnly") + "</br></br>" + da.GetCustomText("GeneralContactSupport")
                        Session("inactiveAccountStatus") = inactiveAccountStatus
                        LetUserIn(userDataTable, False, True)
                    Else
                        Session("Authenticated") = False
                        inactiveAccountStatus = inactiveAccountStatus + da.GetCustomText("LoginAccountExpired") + "</br></br>" + da.GetCustomText("GeneralContactSupport")
                        Session("inactiveAccountStatus") = inactiveAccountStatus
                        Return inactiveAccountStatus
                    End If
                Else
                    LetUserIn(userDataTable, False, False)
                End If
            ElseIf readOnlyAccess Then
                Session("inactiveAccountStatus") = da.GetCustomText("LoginNoDBAccount") + "</br>" + da.GetCustomText("LoginReadOnly") + "</br></br>" + da.GetCustomText("GeneralContactSupport")
                LetUserIn(userDataTable, False, True)
            Else
                Session("Authenticated") = False
                Return da.GetCustomText("LoginNotAuthorised")
            End If
        ElseIf Not adAuthentication Then
            'Classic DB Login
            If Not userInDatabase Then
                Session("Authenticated") = False
                Return da.GetCustomText("LoginUsernameOrPasswordIncorrect")
            End If

            If LCase(userDataTable.Rows(0)("Password").ToString) <> Utilities.GetPasswordASC(pwd).ToString Then
                Session("Authenticated") = False
                Return da.GetCustomText("LoginUsernameOrPasswordIncorrect")
            End If

            Session("ShowToolTips") = CBool(userDataTable.Rows(0)("ShowToolTips"))
            If userDataTable.Rows(0)("GeneralLibrary") IsNot DBNull.Value Then
                Session("GeneralLibrary") = CBool(userDataTable.Rows(0)("GeneralLibrary"))
            End If
            inactiveAccountStatus = IsAccountActive(userDataTable)
            If Not String.IsNullOrEmpty(inactiveAccountStatus) Then
                Return inactiveAccountStatus
            End If

            Dim hostLoggedOnAt As String = ""

            If IsUserLoggedOn(userDataTable, hostLoggedOnAt) Then
                If IsUserIdle(CInt(userDataTable.Rows(0)("UserId"))) Then
                    Dim daOp As New Options
                    daOp.RemoveLoggedInUser(CInt(userDataTable.Rows(0)("UserId")))
                    LetUserIn(userDataTable, resetPassword, False)
                Else
                    Session("UserLoggedOnPreviously") = True
                    Session("UserLoggedOnPreviouslyHostName") = hostLoggedOnAt
                End If
            Else
                LetUserIn(userDataTable, resetPassword, False)
            End If
        Else
            Session("Authenticated") = False
            Return da.GetCustomText("LoginNotAuthorised")
        End If

        Return ""
    End Function

    Private Function IsAccountActive(userDataTable As DataTable) As String
        Dim da As New DataAccess
        If userDataTable.Rows.Count > 0 Then
            If userDataTable.Rows(0)("Suppressed") = "True" Then
                Session("Suppressed") = True
                Return da.GetCustomText("LoginAccountSuppressed")
            End If
            If userDataTable.Rows(0)("ExpiresOn") < DateTime.Now.Date() Then
                Session("AccountExpired") = True
                Session("ShowToolTips") = CBool(userDataTable.Rows(0)("ShowToolTips"))
                Return da.GetCustomText("LoginAccountExpired")
            End If
        End If
        Return String.Empty
    End Function

    Private Sub LetUserIn(ByVal userDataTable As DataTable, ByRef resetPassword As Boolean, ByRef readOnlyAccess As Boolean)
        Dim offsetMinutes As Integer = CInt(Session("TimezoneOffset"))
        Session("Authenticated") = True

        Session("UserLoggedOnPreviously") = Nothing
        Session("UserLoggedOnPreviouslyHostName") = Nothing

        'If ConfigurationManager.AppSettings("Unisoft.ActiveDirectoryLogin") = False Then
        If HttpContext.Current.Request.IsAuthenticated Then
            resetPassword = False
        Else
            resetPassword = CBool(userDataTable.Rows(0)("ResetPassword"))
            If Not resetPassword AndAlso Not IsDBNull(userDataTable.Rows(0)("PasswordExpiresOn")) Then
                resetPassword = (userDataTable.Rows(0)("PasswordExpiresOn") < Date.Today)
            End If
        End If
        'Else
        '    resetPassword = False
        'End If



        If userDataTable.Rows.Count > 0 And Not readOnlyAccess Then
            Session("PKUserId") = CInt(userDataTable.Rows(0)("UserId"))
            'Session("FullName") = CStr(userDataTable.Rows(0)("Title")) & " " & CStr(userDataTable.Rows(0)("Forename")) & " " & CStr(userDataTable.Rows(0)("Surname"))
            Session("FullName") = CStr(userDataTable.Rows(0)("Forename")) & " " & CStr(userDataTable.Rows(0)("Surname"))
            Session("LoggedOn") = DateTime.UtcNow.AddMinutes(-offsetMinutes).ToString("dd/MM/yyyy HH:mm")
            Session("SkinName") = userDataTable.Rows(0)("SkinName")
            Session("CanEditDropdowns") = userDataTable.Rows(0)("CanEditDropdowns")
            Session("CanOverrideSchedule") = userDataTable.Rows(0)("CanOverrideSchedule")
            Session("IsAdmin") = userDataTable.Rows(0)("IsAdmin")
        Else
            Session("PKUserId") = 0
            Session("FullName") = Session("UserId")
            Session("LoggedOn") = DateTime.UtcNow.AddMinutes(-offsetMinutes).ToString("dd/MM/yyyy HH:mm")
            Session("SkinName") = "Metro"
            Session("CanEditDropdowns") = False
            Session("CanOverrideSchedule") = False
            Session("IsAdmin") = False
        End If

        If ConfigurationManager.AppSettings("Unisoft.ActiveDirectoryLogin") = False Then
            If Not HttpContext.Current.Request.IsAuthenticated Then
                Dim da As New DataAccess
                da.UpdateUserLogin(CInt(userDataTable.Rows(0)("UserId")), 1, Utilities.GetHostName, Utilities.GetHostFullName)
            End If
        End If

    End Sub

    Public Function IsPasswordValid(ByVal pwd As String) As Boolean
        Dim da As New DataAccess
        Dim userDataTable As DataTable = da.GetUser(CInt(Session("PKUserID")))
        If userDataTable.Rows.Count > 0 Then
            Return LCase(userDataTable.Rows(0)("Password").ToString) = Utilities.GetPasswordASC(pwd)
        End If
        Return False
    End Function

    Public Function IsPasswordFormatValid(ByVal password As String, ByRef isValid As Boolean) As List(Of String)
        Dim da As New Options
        Dim formatErrors As New List(Of String)
        isValid = True

        Dim dtPr As DataTable = da.GetPasswordRules() ' da.GetPasswordRules(CInt(Session("OperatingHospitalID")))
        If dtPr.Rows.Count > 0 Then
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleMinLength")) Then
                If password.Length < CInt(dtPr.Rows(0)("PwdRuleMinLength")) Then
                    isValid = False
                    formatErrors.Add(String.Format("Password must have at least {0} character(s)", CStr(dtPr.Rows(0)("PwdRuleMinLength"))))
                End If
            End If
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleNoOfSpecialChars")) Then
                If GetNoofSpecialCharacters(password) < CInt(dtPr.Rows(0)("PwdRuleNoOfSpecialChars")) Then
                    isValid = False
                    formatErrors.Add(String.Format("Password must have at least {0} non-alphanumeric character(s)", CStr(dtPr.Rows(0)("PwdRuleNoOfSpecialChars"))))
                End If
            End If
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleNoSpaces")) AndAlso CBool(dtPr.Rows(0)("PwdRuleNoSpaces")) Then
                If ContainWhiteSpaces(password) Then
                    isValid = False
                    formatErrors.Add("Password cannot contain spaces")
                End If
            End If
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleCantBeUserId")) AndAlso CBool(dtPr.Rows(0)("PwdRuleCantBeUserId")) Then
                If String.Compare(password, CStr(Session("UserID")), True) = 0 Then
                    isValid = False
                    formatErrors.Add("Password cannot be the same as your user id")
                End If
            End If
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleNoOfPastPwdsToAvoid")) AndAlso CInt(dtPr.Rows(0)("PwdRuleNoOfPastPwdsToAvoid")) > 0 Then
                Dim dtPrevPwds As DataTable = da.GetPreviousPasswords(CInt(Session("PKUserID")), CInt(dtPr.Rows(0)("PwdRuleNoOfPastPwdsToAvoid")))
                Dim foundRows() As Data.DataRow
                foundRows = dtPrevPwds.Select("Password = '" & Utilities.GetPasswordASC(password) & "'")
                'Dim resultRows As DataView = New DataView(dtPrevPwds, "Password", "CreatedOn", DataViewRowState.CurrentRows)
                'If resultRows.Find(Utilities.GetPasswordASC(password)) > 0 Then
                If foundRows.Length > 0 Then
                    isValid = False
                    formatErrors.Add(String.Format("Password cannot be the last {0} password(s) used", CStr(dtPr.Rows(0)("PwdRuleNoOfPastPwdsToAvoid"))))
                End If
            End If
        End If
        Return formatErrors
    End Function

    Public Function IsFirstTimeLogin(ByVal userName As String) As Boolean
        Dim da As New DataAccess
        Dim userDataTable As DataTable = da.GetUserByUserName(userName)
        Dim firstTime As Boolean = False

        If userDataTable.Rows.Count > 0 Then
            If CBool(userDataTable.Rows(0)("ResetPassword")) Then
                Session("PKUserId") = CInt(userDataTable.Rows(0)("UserId"))
                firstTime = True
            End If
            If Session("OperatingHospitalID") Is Nothing Then
                Session("OperatingHospitalID") = userDataTable.Rows(0)("LastOperatingHospital")
            End If
        End If

        Return firstTime
    End Function

    Public Function IsUserLoggedOn(ByVal userDataTable As DataTable, ByRef hostLoggedOnAt As String) As Boolean
        Dim da As New DataAccess
        Dim loggedOn As Boolean = False

        If Not IsDBNull(userDataTable.Rows(0)("LoggedOn")) Then
            loggedOn = CBool(userDataTable.Rows(0)("LoggedOn"))
            If loggedOn Then
                hostLoggedOnAt = da.GetHostNameOfLastLogin(CInt(userDataTable.Rows(0)("UserId")))
            End If
        End If

        Return False ' loggedOn -- TODO : Set to loggedOn (was set to nothing to relax on rules)
    End Function

    Public Function IsUserIdle(ByVal userId As Integer) As Boolean
        Dim idle As Boolean = False
        Dim da As New Options
        Dim lastActiveAt As DateTime = da.GetLastActiveTime(userId)
        Dim timeOut As Integer = da.GetApplicationTimeOut()

        If lastActiveAt.AddMinutes(timeOut) < DateTime.Now Then
            idle = True
        End If

        Return idle
    End Function

    Private Function GetNoofSpecialCharacters(phrase As String) As Integer
        'Dim count As Integer = 0
        'For x = 126 To 255
        '    If phrase.Contains(Chr(x)) Then
        '        count = count + 1
        '    End If
        'Next
        'Return count
        Dim phraseWithoutSplChars As String = Regex.Replace(phrase, "[^A-Za-z0-9\-/]", "")
        Return phrase.Length - phraseWithoutSplChars.Length
    End Function

    Private Function ContainWhiteSpaces(phrase As String) As Boolean
        Dim phraseNew As String = phrase.Replace(" ", "")
        If phraseNew.Length < phrase.Length Then
            Return True
        End If
        Return False
    End Function

    Public Function GetPasswordExpiryDate() As Date
        Dim da As New Options
        Dim dtPr As DataTable = da.GetPasswordRules() 'da.GetPasswordRules(CInt(Session("OperatingHospitalID")))
        If dtPr.Rows.Count > 0 Then
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleDaysToExpiration")) Then
                Return Date.Today.AddDays(dtPr.Rows(0)("PwdRuleDaysToExpiration"))
            Else
                Return Date.Today.AddDays(1000) 'TODO: Decide on no of days (Probably set this in config file)
            End If
        End If
        Return Nothing
    End Function

    'Public Function IsUserNameUnique(ByVal userName As String) As Boolean
    '    Dim da As New DataAccess
    '    Dim userDataTable As DataTable = da.GetUserByUserName(userName)
    '    If userDataTable.Rows.Count > 0 Then
    '        Return False
    '    End If
    '    Return True
    'End Function

    Public Function IsUserNameUnique(ByVal userName As String, ByVal operatingHospitalID As Integer, Optional ByVal userIdToIgnore As Integer = 0) As Boolean
        Dim da As New DataAccess
        Dim userDataTable As DataTable = da.GetUserByUserName(userName)
        Dim matchFound As Boolean = False

        Dim matches = From r In userDataTable.AsEnumerable()
                      Where r.Field(Of String)("UserName").ToLower = userName.ToLower()
                      Select r
        matchFound = matches.Count > 0

        If userIdToIgnore > 0 Then
            Dim furtherMatches = From r In matches.AsEnumerable()
                                 Where r.Field(Of Integer)("UserId") <> userIdToIgnore
                                 Select r
            matchFound = furtherMatches.Count > 0
        End If

        Return Not matchFound
    End Function

    Public Function GetPrintOptions(Optional ByVal operatingHospitalId As Integer? = Nothing) As PrintOptions
        If Not operatingHospitalId.HasValue Then operatingHospitalId = CInt(HttpContext.Current.Session("OperatingHospitalId"))
        Dim po As New PrintOptions()
        Dim da As New DataAccess()
        Dim dsPrintOptions As DataSet

        dsPrintOptions = da.GetPrintOptions(operatingHospitalId)
        If dsPrintOptions IsNot Nothing AndAlso dsPrintOptions.Tables.Count > 0 Then
            po.GPReportPrintOptions = GetGPReportPrintOptions(dsPrintOptions.Tables(0))
            po.LabRequestFormPrintOptions = GetLabRequestFormPrintOptions(dsPrintOptions.Tables(1))
            po.PatientFriendlyReportPrintOptions = GetPatientFriendlyReportPrintOptions(dsPrintOptions.Tables(2), dsPrintOptions.Tables(3))
        End If

        Return po
    End Function

    Private Function GetGPReportPrintOptions(ByVal dtGPReportPrintOptions As DataTable) As GPReportPrintOptions
        Dim grpo As New GPReportPrintOptions
        With grpo
            .IncludeDiagram = CBool(dtGPReportPrintOptions.Rows(0)("IncludeDiagram"))
            .IncludeDiagramOnlyIfSitesExist = CBool(dtGPReportPrintOptions.Rows(0)("IncludeDiagramOnlyIfSitesExist"))
            .IncludeListConsultant = CBool(dtGPReportPrintOptions.Rows(0)("IncludeListConsultant"))
            .IncludeNurses = CBool(dtGPReportPrintOptions.Rows(0)("IncludeNurses"))
            .IncludeInstrument = CBool(dtGPReportPrintOptions.Rows(0)("IncludeInstrument"))
            .IncludeMissingCaseNote = CBool(dtGPReportPrintOptions.Rows(0)("IncludeMissingCaseNote"))
            .IncludeIndications = CBool(dtGPReportPrintOptions.Rows(0)("IncludeIndications"))
            .IncludeCoMorbidities = CBool(dtGPReportPrintOptions.Rows(0)("IncludeCoMorbidities"))
            .IncludePlannedProcedures = CBool(dtGPReportPrintOptions.Rows(0)("IncludePlannedProcedures"))
            .IncludePremedication = CBool(dtGPReportPrintOptions.Rows(0)("IncludePremedication"))
            .IncludeProcedureNotes = CBool(dtGPReportPrintOptions.Rows(0)("IncludeProcedureNotes"))
            .IncludeSiteNotes = CBool(dtGPReportPrintOptions.Rows(0)("IncludeSiteNotes"))
            .IncludeBowelPreparation = CBool(dtGPReportPrintOptions.Rows(0)("IncludeBowelPreparation"))
            .IncludeExtentOfIntubation = CBool(dtGPReportPrintOptions.Rows(0)("IncludeExtentOfIntubation"))
            .IncludePreviousGastricUlcer = CBool(dtGPReportPrintOptions.Rows(0)("IncludePreviousGastricUlcer"))
            .IncludeExtentAndLimitingFactors = CBool(dtGPReportPrintOptions.Rows(0)("IncludeExtentAndLimitingFactors"))
            .IncludeCannulation = CBool(dtGPReportPrintOptions.Rows(0)("IncludeCannulation"))
            .IncludeExtentOfVisualisation = CBool(dtGPReportPrintOptions.Rows(0)("IncludeExtentOfVisualisation"))
            .IncludeContrastMediaUsed = CBool(dtGPReportPrintOptions.Rows(0)("IncludeContrastMediaUsed"))
            .IncludePapillaryAnatomy = CBool(dtGPReportPrintOptions.Rows(0)("IncludePapillaryAnatomy"))
            .IncludeDiagnoses = CBool(dtGPReportPrintOptions.Rows(0)("IncludeDiagnoses"))
            .IncludeFollowUp = CBool(dtGPReportPrintOptions.Rows(0)("IncludeFollowUp"))
            .IncludeTherapeuticProcedures = CBool(dtGPReportPrintOptions.Rows(0)("IncludeTherapeuticProcedures"))
            .IncludeSpecimensTaken = CBool(dtGPReportPrintOptions.Rows(0)("IncludeSpecimensTaken"))
            .IncludePeriOperativeComplications = CBool(dtGPReportPrintOptions.Rows(0)("IncludePeriOperativeComplications"))
            .DefaultNumberOfCopies = CInt(dtGPReportPrintOptions.Rows(0)("DefaultNumberOfCopies"))
            .DefaultNumberOfPhotos = CInt(dtGPReportPrintOptions.Rows(0)("DefaultNumberOfPhotos"))
            .DefaultPhotoSize = CInt(dtGPReportPrintOptions.Rows(0)("DefaultPhotoSize"))
            .DefaultExportImage = CBool(dtGPReportPrintOptions.Rows(0)("PrintOnExport"))
            .PrintType = If(Not IsDBNull(dtGPReportPrintOptions.Rows(0)("PrintType")) AndAlso dtGPReportPrintOptions.Rows(0)("PrintType") IsNot Nothing, CInt(dtGPReportPrintOptions.Rows(0)("PrintType")), 0)
            .PrintDoubleSided = CBool(dtGPReportPrintOptions.Rows(0)("PrintDoubleSided"))
        End With
        Return grpo
    End Function

    Private Function GetLabRequestFormPrintOptions(ByVal dtLabRequestFormPrintOptions As DataTable) As LabRequestFormPrintOptions
        Dim lrpo As New LabRequestFormPrintOptions
        With lrpo
            .OneRequestForEverySpecimen = CBool(dtLabRequestFormPrintOptions.Rows(0)("OneRequestForEverySpecimen"))
            .GroupSpecimensByDestination = CBool(dtLabRequestFormPrintOptions.Rows(0)("GroupSpecimensByDestination"))
            .RequestsPerA4Page = CInt(dtLabRequestFormPrintOptions.Rows(0)("RequestsPerA4Page"))
            .IncludeDiagram = CBool(dtLabRequestFormPrintOptions.Rows(0)("IncludeDiagram"))
            .IncludeTimeSpecimenCollected = CBool(dtLabRequestFormPrintOptions.Rows(0)("IncludeTimeSpecimenCollected"))
            .IncludeHeading = CBool(dtLabRequestFormPrintOptions.Rows(0)("IncludeHeading"))
            .Heading = CStr(dtLabRequestFormPrintOptions.Rows(0)("Heading"))
            .IncludeIndications = CBool(dtLabRequestFormPrintOptions.Rows(0)("IncludeIndications"))
            .IncludeProcedureNotes = CBool(dtLabRequestFormPrintOptions.Rows(0)("IncludeProcedureNotes"))
            .IncludeAbnormalities = CBool(dtLabRequestFormPrintOptions.Rows(0)("IncludeAbnormalities"))
            .IncludeSiteNotes = CBool(dtLabRequestFormPrintOptions.Rows(0)("IncludeSiteNotes"))
            .IncludeDiagnoses = CBool(dtLabRequestFormPrintOptions.Rows(0)("IncludeDiagnoses"))
            .DefaultNumberOfCopies = CInt(dtLabRequestFormPrintOptions.Rows(0)("DefaultNumberOfCopies"))
        End With
        Return lrpo
    End Function

    Private Function GetPatientFriendlyReportPrintOptions(ByVal dtPatientFriendlyReportPrintOptions As DataTable, ByVal dtPatientFriendlyReportAdditional As DataTable) As PatientFriendlyReportPrintOptions
        Dim pfpo As New PatientFriendlyReportPrintOptions
        Dim pfpoaList As New List(Of PatientFriendlyReportPrintOptionsAdditional)
        Dim pfpoa As PatientFriendlyReportPrintOptionsAdditional

        With pfpo
            .IncludeNoFollowup = CBool(dtPatientFriendlyReportPrintOptions.Rows(0)("IncludeNoFollowup"))
            .IncludeUreaseText = CBool(dtPatientFriendlyReportPrintOptions.Rows(0)("IncludeUreaseText"))
            .UreaseText = CStr(dtPatientFriendlyReportPrintOptions.Rows(0)("UreaseText"))
            .IncludePolypectomyText = CBool(dtPatientFriendlyReportPrintOptions.Rows(0)("IncludePolypectomyText"))
            .PolypectomyText = CStr(dtPatientFriendlyReportPrintOptions.Rows(0)("PolypectomyText"))
            .IncludeOtherBiopsyText = CBool(dtPatientFriendlyReportPrintOptions.Rows(0)("IncludeOtherBiopsyText"))
            .OtherBiopsyText = CStr(dtPatientFriendlyReportPrintOptions.Rows(0)("OtherBiopsyText"))
            .IncludeAnyOtherBiopsyText = CBool(dtPatientFriendlyReportPrintOptions.Rows(0)("IncludeAnyOtherBiopsyText"))
            .AnyOtherBiopsyText = CStr(dtPatientFriendlyReportPrintOptions.Rows(0)("AnyOtherBiopsyText"))
            .IncludeAdviceComments = CBool(dtPatientFriendlyReportPrintOptions.Rows(0)("IncludeAdviceComments"))
            .IncludePreceedAdviceComments = CBool(dtPatientFriendlyReportPrintOptions.Rows(0)("IncludePreceedAdviceComments"))
            .PreceedAdviceComments = CStr(dtPatientFriendlyReportPrintOptions.Rows(0)("PreceedAdviceComments"))
            .IncludeFinalText = CBool(dtPatientFriendlyReportPrintOptions.Rows(0)("IncludeFinalText"))
            .FinalText = CStr(dtPatientFriendlyReportPrintOptions.Rows(0)("FinalText"))
            .DefaultNumberOfCopies = CInt(dtPatientFriendlyReportPrintOptions.Rows(0)("DefaultNumberOfCopies"))

            .AdditionalEntries = GetPatientFriendlyReportPrintOptionsAdditional(dtPatientFriendlyReportAdditional)
        End With
        Return pfpo
    End Function

    Private Function GetPatientFriendlyReportPrintOptionsAdditional(ByVal dtPatientFriendlyReportAdditional As DataTable) As List(Of PatientFriendlyReportPrintOptionsAdditional)
        Dim pfpoaList As New List(Of PatientFriendlyReportPrintOptionsAdditional)
        Dim pfpoa As PatientFriendlyReportPrintOptionsAdditional

        For Each dr As DataRow In dtPatientFriendlyReportAdditional.Rows
            pfpoa = New PatientFriendlyReportPrintOptionsAdditional
            With pfpoa
                .Id = CInt(dr("Id"))
                .IncludeAdditionalText = CBool(dr("IncludeAdditionalText"))
                .AdditionalText = CStr(dr("AdditionalText"))
            End With
            pfpoaList.Add(pfpoa)
        Next
        Return pfpoaList
    End Function

    Public Function GetPatientFriendlyReportPrintOptionsAdditional() As List(Of PatientFriendlyReportPrintOptionsAdditional)
        Dim da As New DataAccess()
        Dim dtPatientFriendlyReportAdditional As DataTable

        dtPatientFriendlyReportAdditional = da.GetPrintOptionsPatientFriendlyReportAdditional()
        Return GetPatientFriendlyReportPrintOptionsAdditional(dtPatientFriendlyReportAdditional)
    End Function

    Public Function SavePrintOptions(ByVal po As PrintOptions, ByVal OperatingHospitalId As Integer) As Integer
        Dim da As New DataAccess
        If po.IncludeGPReport And po.GPReportPrintOptions IsNot Nothing Then
            da.SaveGPReportPrintOptions(
                po.GPReportPrintOptions.IncludeDiagram,
                po.GPReportPrintOptions.IncludeDiagramOnlyIfSitesExist,
                po.GPReportPrintOptions.IncludeListConsultant,
                po.GPReportPrintOptions.IncludeNurses,
                po.GPReportPrintOptions.IncludeInstrument,
                po.GPReportPrintOptions.IncludeMissingCaseNote,
                po.GPReportPrintOptions.IncludeIndications,
                po.GPReportPrintOptions.IncludeCoMorbidities,
                po.GPReportPrintOptions.IncludePlannedProcedures,
                po.GPReportPrintOptions.IncludePremedication,
                po.GPReportPrintOptions.IncludeProcedureNotes,
                po.GPReportPrintOptions.IncludeSiteNotes,
                po.GPReportPrintOptions.IncludeBowelPreparation,
                po.GPReportPrintOptions.IncludeExtentOfIntubation,
                po.GPReportPrintOptions.IncludePreviousGastricUlcer,
                po.GPReportPrintOptions.IncludeExtentAndLimitingFactors,
                po.GPReportPrintOptions.IncludeCannulation,
                po.GPReportPrintOptions.IncludeExtentOfVisualisation,
                po.GPReportPrintOptions.IncludeContrastMediaUsed,
                po.GPReportPrintOptions.IncludePapillaryAnatomy,
                po.GPReportPrintOptions.IncludeDiagnoses,
                po.GPReportPrintOptions.IncludeFollowUp,
                po.GPReportPrintOptions.IncludeTherapeuticProcedures,
                po.GPReportPrintOptions.IncludeSpecimensTaken,
                po.GPReportPrintOptions.IncludePeriOperativeComplications,
                po.GPReportPrintOptions.DefaultNumberOfCopies,
                po.GPReportPrintOptions.DefaultNumberOfPhotos,
                po.GPReportPrintOptions.DefaultPhotoSize,
                po.GPReportPrintOptions.DefaultExportImage,
                po.GPReportPrintOptions.PrintType,
                po.GPReportPrintOptions.PrintDoubleSided,
                OperatingHospitalId)
        End If

        If po.IncludeLabRequestReport And po.LabRequestFormPrintOptions IsNot Nothing Then
            da.SaveLabRequestReportPrintOptions(
                po.LabRequestFormPrintOptions.OneRequestForEverySpecimen,
                po.LabRequestFormPrintOptions.GroupSpecimensByDestination,
                po.LabRequestFormPrintOptions.RequestsPerA4Page,
                po.LabRequestFormPrintOptions.IncludeDiagram,
                po.LabRequestFormPrintOptions.IncludeTimeSpecimenCollected,
                po.LabRequestFormPrintOptions.IncludeHeading,
                po.LabRequestFormPrintOptions.Heading,
                po.LabRequestFormPrintOptions.IncludeIndications,
                po.LabRequestFormPrintOptions.IncludeProcedureNotes,
                po.LabRequestFormPrintOptions.IncludeAbnormalities,
                po.LabRequestFormPrintOptions.IncludeSiteNotes,
                po.LabRequestFormPrintOptions.IncludeDiagnoses,
                po.LabRequestFormPrintOptions.DefaultNumberOfCopies,
                OperatingHospitalId)
        End If

        If po.IncludePatientCopyReport And po.PatientFriendlyReportPrintOptions IsNot Nothing Then
            da.SavePatientFriendlyReportPrintOptions(
                po.PatientFriendlyReportPrintOptions.IncludeNoFollowup,
                po.PatientFriendlyReportPrintOptions.IncludeUreaseText,
                po.PatientFriendlyReportPrintOptions.UreaseText,
                po.PatientFriendlyReportPrintOptions.IncludePolypectomyText,
                po.PatientFriendlyReportPrintOptions.PolypectomyText,
                po.PatientFriendlyReportPrintOptions.IncludeOtherBiopsyText,
                po.PatientFriendlyReportPrintOptions.OtherBiopsyText,
                po.PatientFriendlyReportPrintOptions.IncludeAnyOtherBiopsyText,
                po.PatientFriendlyReportPrintOptions.AnyOtherBiopsyText,
                po.PatientFriendlyReportPrintOptions.IncludeAdviceComments,
                po.PatientFriendlyReportPrintOptions.IncludePreceedAdviceComments,
                po.PatientFriendlyReportPrintOptions.PreceedAdviceComments,
                po.PatientFriendlyReportPrintOptions.IncludeFinalText,
                po.PatientFriendlyReportPrintOptions.FinalText,
                po.PatientFriendlyReportPrintOptions.DefaultNumberOfCopies,
                OperatingHospitalId)

            For Each pfpoa As PatientFriendlyReportPrintOptionsAdditional In po.PatientFriendlyReportPrintOptions.AdditionalEntries
                da.SavePatientFriendlyReportAdditionalPrintOptions(
                    pfpoa.Id,
                    pfpoa.IncludeAdditionalText,
                    pfpoa.AdditionalText,
                    OperatingHospitalId)
            Next
        End If

        Return True
    End Function

    ''' <summary>
    ''' This will Load all the Consultants (Endoscopist, Trainee, Nurses)
    ''' </summary>
    ''' <returns>List(Of ERS.Data.ERS_Users)</returns>
    ''' <remarks></remarks>
    'Public Shared Function GetAllConsultant(ByVal consultantType As String, Optional ByVal HideSuppressed As Boolean = False) As List(Of ERS.Data.GetAllConsultant_Result)
    '    'Dim consultantList As List(Of ERS.Data.GetAllConsultant_Result)

    '    Using db As New ERS.Data.GastroDbEntities
    '        consultantList = db.GetAllConsultant(consultantType, HideSuppressed).ToList()
    '    End Using

    '    Return consultantList
    'End Function


    ''' <summary>
    ''' This will Load all the Consultants (Endoscopist, Trainee, Nurses)
    ''' </summary>
    ''' <remarks></remarks>
    'Public Shared Sub LoadAllConsultant(ByVal consultantType As String, Optional ByVal HideSuppressed As Boolean = False)
    '    Try
    '        Using db As New ERS.Data.GastroDbEntities
    '            consultantList = db.GetAllConsultant(consultantType, HideSuppressed).ToList()
    '        End Using
    '    Catch ex As Exception
    '        Dim errorLogRef As String
    '        errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on default page.", ex)
    '    End Try

    'End Sub



    'Public Shared Function FilterConsultantType(consultantType As Staff, Optional ByVal refreshConsultantList As Boolean = False, Optional ByVal HideSuppressed As Boolean = False) As List(Of ERS.Data.GetAllConsultant_Result)
    '    If refreshConsultantList Then
    '        LoadAllConsultant("all", HideSuppressed) '## This will Load the list of ALL Consultants in the Memory!
    '    End If
    '    ' Dim da As New DataAccess()
    '    ' Dim AllConsultants As DataTable

    '    ' AllConsultants = da.ExecuteSP("usp_rep_ConsultantSelectByType", New SqlParameter() {New SqlParameter("@ConsultantType", "all"),
    '    '                                                         New SqlParameter("@HideInactiveConsultants", HideSuppressed)
    '    '                                                   })

    '    Dim result As New List(Of ERS.Data.GetAllConsultant_Result)


    '    Try
    '        Select Case consultantType
    '            Case Staff.ListConsultant
    '                result = consultantList.Where(Function(c) c.IsListConsultant = True).ToList()
    '            Case Staff.EndoScopist1
    '                result = consultantList.Where(Function(c) c.IsEndoscopist1 = True).ToList()
    '            Case Staff.EndoScopist2
    '                result = consultantList.Where(Function(c) c.IsEndoscopist2 = True).ToList()
    '            Case Staff.Nurse1
    '                result = consultantList.Where(Function(c) c.IsAssistantOrTrainee = True).ToList()
    '            Case Staff.Nurse2
    '                result = consultantList.Where(Function(c) c.IsNurse1 = True).ToList()
    '            Case Staff.Nurse3
    '                result = consultantList.Where(Function(c) c.IsNurse2 = True).ToList()
    '            Case Staff.Nurse4
    '                result = consultantList.Where(Function(c) c.IsNurse2 = True).ToList()
    '        End Select

    '        Return result

    '    Catch ex As Exception
    '        LogManager.LogManagerInstance.LogError("Error occurred on FilterConsultantType.", ex)
    '        Return Nothing
    '    End Try




    'End Function

    Public Shared Function FilterConsultantByType(consultantType As Staff, Optional ByVal HideSuppressed As Boolean = True) As DataTable
        Dim operatingHospitalsIds As String = String.Empty

        If ConfigurationManager.AppSettings.AllKeys.Contains("FilterStaffByOperatingHospital") Then
            If ConfigurationManager.AppSettings("FilterStaffByOperatingHospital").ToLower() = "true" Then
                operatingHospitalsIds = HttpContext.Current.Session("OperatingHospitalId")
            Else
                operatingHospitalsIds = HttpContext.Current.Session("OperatingHospitalIdsForTrust")
            End If
        End If

        Dim consultantTypeName = [Enum].GetName(GetType(Staff), consultantType)
        Return GetConsultants(consultantTypeName, operatingHospitalsIds, HideSuppressed)

    End Function

    Public Shared Function GetConsultants(consultantTypeName As String, operatingHospitalsIds As String, Optional ByVal HideSuppressed As Boolean = False, Optional ByVal searchText As String = Nothing) As DataTable
        Dim da As New DataAccess()
        Try
            Return da.ExecuteSP("usp_rep_ConsultantSelectByType",
                                New SqlParameter() {
                                    New SqlParameter("@ConsultantType", consultantTypeName),
                                    New SqlParameter("@HideInactiveConsultants", HideSuppressed),
                                    New SqlParameter("@operatingHospitalsIds", operatingHospitalsIds),
                                    New SqlParameter("@searchText", searchText)
                                })
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    Public Shared Function GetSelectedStaffForProcedureId(consultantTypeName As String, ProcedureId As Integer) As DataTable
        Dim da As New DataAccess()
        Try
            Return da.ExecuteSP("get_SelectedStaffForProcedureId",
                                New SqlParameter() {
                                    New SqlParameter("@ConsultantType", consultantTypeName),
                                    New SqlParameter("@ProcedureId", ProcedureId)
                                })
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in function: BusinessLogic.GetSelectedStaffForProcedureId.", ex)
            Return New DataTable
        End Try
    End Function

    Public Shared Function GetConsultantOnly(userId As Integer, consultantTypeName As String, operatingHospitalsIds As String, Optional ByVal HideSuppressed As Boolean = False, Optional ByVal searchText As String = Nothing) As DataTable


        Dim da As New DataAccess()
        Try
            Return da.ExecuteSP("usp_rep_ConsultantSelectByUser", New SqlParameter() {
                                                                                         New SqlParameter("@userId", userId),
                                                                                         New SqlParameter("@ConsultantType", consultantTypeName),
                                                                                         New SqlParameter("@HideInactiveConsultants", HideSuppressed),
                                                                                         New SqlParameter("@operatingHospitalsIds", operatingHospitalsIds),
                                                                                         New SqlParameter("@searchText", searchText)
                                                                                     })
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in function: BusinessLogic.GetConsultantOnly.", ex)
            Return Nothing
        End Try

    End Function

    ''' <summary>
    ''' This will return only one Procedure Details, filtered by Procedure Id
    ''' </summary>
    ''' <param name="procedureId">Procedure Id number</param>
    ''' <returns>object: ERS.Data.ERS_Procedures</returns>
    ''' <remarks>Shawkat Osman; 2017-07-18</remarks>
    Public Shared Function Procedures_Select(ByVal procedureId As Integer) As ERS.Data.ERS_Procedures
        Using db As New ERS.Data.GastroDbEntities
            Return db.ERS_Procedures.Find(procedureId)
        End Using

    End Function

    ''' <summary>
    ''' UGI Context: OtherText and NONE are common for both ER and EE Therapeutic Records.
    ''' So- save the same 'Other' value on ER Records!
    ''' </summary>
    ''' <param name="siteId">ie: Site Id: 1,2</param>
    ''' <param name="noneChecked">None selected? Yes/No</param>
    ''' <param name="OtherText">Other Text about the UGI->Site</param>
    ''' <remarks></remarks>
    Public Shared Sub UpdateUGI_TherapeuticCommonData(ByVal siteId As Integer, ByVal noneChecked As Boolean, ByVal OtherText As String)
        Using db As New ERS.Data.GastroDbEntities
            db.Database.ExecuteSqlCommand("UPDATE [dbo].[ERS_UpperGITherapeutics] SET [None]=@NoneChecked, [Other]=@OtherTherapText WHERE [SiteId]=@SiteId AND [CarriedOutRole]=1", New SqlParameter() _
                                            {New SqlParameter("@NoneChecked", noneChecked),
                                             New SqlParameter("@OtherTherapText", OtherText),
                                             New SqlParameter("@SiteId", siteId)})
        End Using

    End Sub

    Public Enum ProcedureType
        OGD
        ERCP
        COLON
    End Enum
    ''' <summary>
    ''' Read 'Other' Text only from the TrainER Record in [ERS_UpperGITherapeutics] UGI Record
    ''' </summary>
    ''' <param name="siteId">Site ID: 1/2/3</param>
    ''' <param name="endoscopyName">ERCP/ OGD / COLON</param>
    ''' <returns>TherapeuticCommonData Class object</returns>
    ''' <remarks></remarks>
    Public Shared Function Get_CommonTherapeuticData(ByVal siteId As Integer, ByVal endoscopyName As ProcedureType) As TherapeuticCommonData
        Dim result As New TherapeuticCommonData(False, ""),
            endoscopyEntity As String = "" '### Table Name!

        Select Case endoscopyName
            Case ProcedureType.OGD
                endoscopyEntity = "dbo.ERS_UpperGITherapeutics"
            Case ProcedureType.ERCP
                endoscopyEntity = "dbo.ERS_ERCPTherapeutics"
        End Select

        Using da As New DataAccess
            Dim dr As DataRow = da.GetAbnormalities(siteId, endoscopyEntity).Select("CarriedOutRole=1").FirstOrDefault()

            If dr IsNot Nothing Then
                result.OtherText = dr.Item("Other").ToString()
                result.NoneChecked = CBool(dr.Item("None").ToString())
            End If
        End Using

        Return result

    End Function

    ''' <summary>
    ''' ERCP Context: OtherText is common for both ER and EE Therapeutic Records.
    ''' So- save the same 'Other' value on ER Records!
    ''' </summary>
    ''' <param name="siteId">ie: Site Id: 1,2</param>
    ''' <param name="OtherText">Other Text about the ERCP->Site</param>
    ''' <remarks></remarks>
    Public Shared Sub UpdateOtherERCP_TherapeuticText(ByVal siteId As Integer, ByVal OtherText As String)
        Using db As New ERS.Data.GastroDbEntities
            db.Database.ExecuteSqlCommand("UPDATE [dbo].[ERS_ERCPTherapeutics] SET [Other]=@OtherTherapText WHERE [SiteId]=@SiteId AND [CarriedOutRole]=1", New SqlParameter() _
                                            {New SqlParameter("@OtherTherapText", OtherText),
                                             New SqlParameter("@SiteId", siteId)})
        End Using

    End Sub

    Public Shared Function GetOperatingHospitalIdsForTrust(TrustId As Int32)
        Using db As New DataAccess
            Dim trustDatatables As DataTable = db.GetTrustHospitals(TrustId)
            Dim operatingHospitalIds As String() = trustDatatables.AsEnumerable().[Select](Function(x) x.Field(Of Int32)("OperatingHospitalId").ToString()).ToArray()
            Return String.Join(",", operatingHospitalIds)
        End Using
    End Function
End Class