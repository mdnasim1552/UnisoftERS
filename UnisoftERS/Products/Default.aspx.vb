Imports Telerik.Web.UI
Imports System.IO
Imports System.Data.SqlClient
Imports System.Drawing
Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Web.Script.Serialization
Imports Newtonsoft.Json

Partial Class Products_Default
    Inherits PageBase

    Private reader As SqlDataReader = Nothing
    Private pageIndex As Integer
    Private giLockedByUserID As Integer
    Private gPP_Site_Legend As String = ""
    Dim _license As New License(ConfigurationManager.AppSettings("Unisoft.LicenseKey"))
    Dim showGridOnLoad As Boolean = False
    Dim SessionTimeoutNotification As RadNotification = Nothing

    Private Shared _dataAdapter As DataAccess = Nothing

    Protected Shared ReadOnly Property DataAdapter2() As DataAccess
        Get
            If _dataAdapter Is Nothing Then
                _dataAdapter = New DataAccess
            End If
            Return _dataAdapter
        End Get
    End Property

    Protected Sub Page_Init(sender As Object, e As System.EventArgs) Handles Me.Init
        If Not IsPostBack Then
            If Session("TrustId") Is Nothing Then
                Response.Redirect("~/Security/Logout.aspx", False)
            End If

            lblWelcomeMessage.Text = "Welcome " & Session("FullName") & ""

            If Not String.IsNullOrEmpty(Session("inactiveAccountStatus")) Then
                'Account has been logged in as ReadOnly as it has either expired or is not in the database
                MessageRadWindow.Visible = True
                MessageRadWindow.VisibleOnPageLoad = True
                lblMessageText.Text = Session("inactiveAccountStatus")
                'Clear the message so it only shows once
                Session("inactiveAccountStatus") = String.Empty
            End If

            SetLicenseTile()
            'LoadSearchComboBox()

            'check failed procedure status
            If Session("NEDFailuresNotified") Is Nothing OrElse Session("NEDFailuresNotified") = False Then
                If DataAdapter.checkNEDFailedExportCount() > 0 Then
                    Session("FailedProceduresMessage") = "One or some of your procedures need attention. Please run the National Data Set failure report and address and reprint to re-submit to National Data Set"

                    Dim script As String = "alert('" + CStr(Session("FailedProceduresMessage")) + "');"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "key", script, True)

                    Session("NEDFailuresNotified") = True
                Else
                    Session("FailedProceduresMessage") = Nothing
                End If
            End If

            If Me.Master.FindControl("SessionTimeoutNotification") IsNot Nothing Then
                SessionTimeoutNotification = DirectCast(Master.FindControl("SessionTimeoutNotification"), RadNotification)
            End If



            If Request.Cookies("patientId") Is Nothing Then
                SessionHelper.ClearPatientSessions()

                Dim iSearchOption As Integer
                Dim bShowWorklist As Boolean
                Dim bHideStartupCharts As Boolean
                getSearchOption(iSearchOption, bShowWorklist, bHideStartupCharts)
                Session("HideStartupCharts") = bHideStartupCharts
                If bShowWorklist Then
                    MainRadTabStrip.Tabs(2).Selected = True
                    RadMultiPage1.PageViews(2).Selected = True
                End If
                dashboard.LoadDashboard()
                landingpage.LoadLandingPage()
            ElseIf CStr(Request.QueryString("Pg")) = "1" Then

            Else
                LoadPatientPage()
            End If

            'Constants.SESSION_SEARCH_TAB Then
            If CBool(Session("HideStartUpCharts")) Then dashboard.Visible = False Else dashboard.Visible = True
            'DataAdapter.UnlockPatientProcedures(Session("PCName"), Session("UserID"))

        End If

        'Constants.SESSION_SEARCH_TAB Then
        If CBool(Session("HideStartUpCharts")) Then dashboard.Visible = False Else dashboard.Visible = True
        'DataAdapter.UnlockPatientProcedures(Session("PCName"), Session("UserID"))



        landingpage.optionERSViewer()
        ''For ERS Viewer only
        If Session("isERSViewer") Then
            MainRadTabStrip.FindTabByText("Worklist").Visible = False
            MainRadTabStrip.FindTabByText("My Preferences").Visible = False
            'patientview.optionERSViewer()
        End If

        'Querystring "CNN" implemented for Beacon hospital (3001)
        If Not IsPostBack Then

            If Request.QueryString("Print") IsNot Nothing AndAlso DirectCast(patientview.FindControl("PrevProcsTreeView"), RadTreeView).Nodes.FindNodeByText("Previous Procedures") IsNot Nothing AndAlso Not IsNothing(Session(Constants.SESSION_PROCEDURE_ID)) AndAlso CInt(Session(Constants.SESSION_PROCEDURE_ID)) <> 0 Then
                Dim pview As RadTreeView = DirectCast(patientview.FindControl("PrevProcsTreeView"), RadTreeView)
                Dim n As RadTreeNode = pview.Nodes.FindNodeByText("Previous Procedures").Nodes.FindNodeByAttribute("ProcedureId", CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                If Not IsNothing(n) Then
                    n.Selected = True
                    patientview.PrintNodeClick(n)
                End If
            End If
        End If
    End Sub

    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(patientview.FindControl("PrevProcsTreeView"), divMultiPageSystem, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(FindAControl(patientview.Controls, "WhoCheckSave"), divMultiPageSystem)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(PatientResultsControl.FindControl("PatientsGrid"), divMultiPageSystem, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(WorklistControl.FindControl("WorklistGrid"), divMultiPageSystem, RadAjaxLoadingPanel1)

        If PatientPageView.Selected Then 'If Create Procedure page with treeview (new/old procedures) is selected
            'myAjaxMgr.AjaxSettings.AddAjaxSetting(patientslist.FindControl("RadSearchBox1"), divMultiPageSystem, RadAjaxLoadingPanel1)
            myAjaxMgr.AjaxSettings.AddAjaxSetting(patientslist.FindControl("SearchButton"), divMultiPageSystem, RadAjaxLoadingPanel1)
            myAjaxMgr.AjaxSettings.AddAjaxSetting(patientslist, MainPage, RadAjaxLoadingPanel1)
        End If
        myAjaxMgr.AjaxSettings.AddAjaxSetting(patientslist.FindControl("SearchButton"), RadMultiPage1, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(patientslist.FindControl("RadSearchBox1"), RadMultiPage1, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(patientslist.FindControl("SearchButton"), MainRadTabStrip)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(patientslist.FindControl("RadSearchBox1"), MainRadTabStrip)

        If Not IsPostBack Then

            Dim op As New Options
            Dim timeOutValue = op.GetApplicationTimeOut()
            If timeOutValue = 0 Then
                Throw New ApplicationException("ApplicationTimeOut is not set properly in ERS_SystemConfig table for the operating hospital id " & CStr(Session("OperatingHospitalID")) & ".")
            End If
            If Request.Cookies("patientId") Is Nothing Then
                SessionTimeoutNotification.ShowInterval = (timeOutValue - 1) * 60000
                SessionTimeoutNotification.Value = Page.ResolveClientUrl("~/Security/Logout.aspx")
            Else
                SessionTimeoutNotification.ShowInterval = 10000 * 60000
                SessionTimeoutNotification.Value = Page.ResolveClientUrl(".")
            End If
            Session.Timeout = 10001
        End If
    End Sub

    Sub getSearchOption(ByRef iSearchOption As Integer, ByRef bShowWorklist As Boolean, ByRef bHideStartupCharts As Boolean)
        Dim op As New Options
        Dim dt As DataTable = op.GetStartupSettings()
        iSearchOption = -1
        If dt.Rows.Count > 0 Then
            iSearchOption = CInt(dt.Rows(0).Item("SearchCriteria"))
            bShowWorklist = CBool(dt.Rows(0).Item("ShowWorklistOnStartup"))
            bHideStartupCharts = CBool(dt.Rows(0).Item("HideStartupCharts"))
        End If
    End Sub

    Private Sub SetLicenseTile()
        Dim datestr As String = _license.ExpiryDate()
        'Dim dtCust As DataTable = DataAdapter.GetCustomer(CInt(Session("HospitalID")))
        'If dtCust.Rows.Count > 0 Then
        '    Dim validUntil As Date = CDate(dtCust.Rows(0)!MaintenanceDue)
        If Not IsNothing(datestr) Then
            Dim validUntil As Date = Date.ParseExact(datestr, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo)
            'If validUntil < Date.Today Then
            If validUntil < DateAdd(DateInterval.Day, 30, Date.Today) Then
                If validUntil < Date.Today Then
                    landingpage.optionValidDate(validUntil)
                    Session("LicenseExpired") = "True"
                ElseIf validUntil < DateAdd(DateInterval.Day, 30, Date.Today) Then
                    landingpage.optionValidDateSoon(validUntil)
                Else
                    landingpage.optionInvalidDate()
                End If
            Else
                landingpage.optionInvalidDate()
            End If
        End If
    End Sub

    Sub hideRightPanel()
        LandingPageView.Selected = True
        'PatientsGrid.Style("Display") = "None"
        'PatientListHeaderDiv.Style("Display") = "None"
        'SessionHelper.ClearPatientSessions()
    End Sub

    Protected Sub ResetButton_Click(sender As Object, e As System.EventArgs)
        SessionHelper.ClearPatientSessions()
        Response.Redirect("Default.aspx", False)
    End Sub

    Public Sub LoadPatientPage()
        Try
            Session(Constants.SESSION_PATIENT_SEARCH_FIELDS) = Nothing
            LandingPageView.Selected = False
            patientview.LoadPatientPage()
            'If patientview.setPKUser Then giLockedByUserID = CInt(Session("PKUserID")) 'Set UserID to later unlock record in page unload.
            PatientPageView.Selected = True
            Using lm As New AuditLogManager
                lm.WriteActivityLog(EVENT_TYPE.SelectRecord, "View patient details")
            End Using


        Catch ex As Exception

        End Try
    End Sub

    Public Sub LoadWorklistPage()
        'MainRadTabStrip.Tabs(2).Selected = True
        'RadMultiPage1.PageViews(2).Selected = True
        WorklistControl.patientAdded()
    End Sub

    Protected Sub Page_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
        If Not String.IsNullOrEmpty(Session("ProductComboBoxValue")) Then
            'patientview.optionProduct()
            Session("ProductComboBoxValue") = Nothing
        End If

        'If Not String.IsNullOrEmpty(Request.QueryString("patient")) Then
        '    EnableEditPatientMenu(True)
        'End If


    End Sub

    Protected Sub Products_Default_Unload(sender As Object, e As EventArgs) Handles Me.Unload
        '      If giLockedByUserID = CInt(Session("PKUserID")) And giLockedByUserID > 0 Then
        'DataAdapter.LockPatient(CInt(Session(Constants.SESSION_PATIENT_ID)), Nothing, Nothing)
        '      End If
        '      giLockedByUserID = Nothing
    End Sub


#Region "Web Methods"
    <WebMethod()>
    Public Shared Function SearchGPs(searchTerm As String)
        Dim sSQL As String = "SELECT TOP 20 GPId, CompleteName FROM ERS_GPS WHERE CompleteName LIKE '%" & searchTerm & "%'"

        Dim dt = DataAccess.ExecuteSQL(sSQL)
        If dt.Rows.Count > 0 Then
            Return (From rows In dt.AsEnumerable
                    Select GPName = rows.Field(Of String)("CompleteName")).ToList()
        Else
            Return Nothing
        End If
    End Function

    <WebMethod()>
    Public Shared Function GetPCImagePort(RoomId As String, operatingHospitalId As Integer) As String
        Dim sSQL As String = "SELECT PortName, ImagePortId, Static FROM ERS_ImagePort " &
       "WHERE IsActive=1 AND RoomId='" & RoomId & "' AND OperatingHospitalId = " & operatingHospitalId

        Dim dt = DataAccess.ExecuteSQL(sSQL)
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Dim retVal As New List(Of Object)

            'build object and serialize
            For Each dr In dt.Rows
                Dim vals = New With {
                    .ImagePortId = dr("ImagePortId"),
                    .Static = dr("Static"),
                    .PortName = dr("PortName")
                }

                retVal.Add(vals)
            Next

            Return New JavaScriptSerializer().Serialize(retVal)
            'Return (From rows In dt.AsEnumerable
            '        Select ImagePortId = rows.Field(Of Integer)("ImagePortId"),
            '               PortName = rows.Field(Of String)("PortName")).ToList()
        Else
            Return Nothing
        End If
    End Function

    <WebMethod()>
    Public Shared Function getResectedText(ByVal ResectedColumnID As String) As String
        Dim da As New DataAccess
        Return da.GetResectedColonText(ResectedColumnID)
    End Function

    <WebMethod()>
    Public Shared Function getRequiredFieldText(ByVal procedureID As String) As String
        Dim opcod As New Options()
        If Not IsNothing(procedureID) AndAlso procedureID <> "0" Then
            Return opcod.CheckRequired(CInt(procedureID))
        Else
            Return ""
        End If
    End Function

    <System.Web.Services.WebMethod(Description:="This method This will Update the user selection for the 'Reason' - Procedure NOT Carried out...")>
    Public Shared Function ProcedureNotCarriedOut_UpdateReason(ByVal procedureId As String, ByVal DNA_ReasonId As String, ByVal PP_DNA_Text As String, ByVal patientInRecovery As Boolean) As String

        Dim executeResult As Boolean = DataAccess.ProcedureNotCarriedOut_UpdateReason(procedureId, DNA_ReasonId, PP_DNA_Text, patientInRecovery)
        If executeResult Then
            'Procedure Marked as DNA - Send Order Message
            Dim OrderComBL As New OrderCommsBL
            Dim LoggedInUserId As Int16
            LoggedInUserId = CInt(HttpContext.Current.Session("PKUserID"))
            OrderComBL.SendMarkDNAOrderMessageByProcedureId(procedureId, LoggedInUserId)
            Return String.Format("Success! Public Shared Function ProcedureNotCarriedOut_UpdateReason() You said: string procedureId= {0}, string DNA_ReasonId= {1}, string PP_DNA_Text= {2}", procedureId, DNA_ReasonId, PP_DNA_Text)
        Else
            Return String.Format("Failed!! Updating ProcedureNotCarriedOut_UpdateReason() procedureId= {0}, string DNA_ReasonId= {1}, string PP_DNA_Text= {2}", procedureId, DNA_ReasonId, PP_DNA_Text)
        End If
    End Function


    <System.Web.Services.WebMethod(Description:="This method This will Update the user selection for the 'Reason' - Procedure NOT Carried out...")>
    Public Shared Function ProcedureNotCarriedOut_Reset(ByVal procedureId As String) As Boolean
        Dim executeResult As Boolean = DataAccess.ProcedureNotCarriedOut_Reset(procedureId)
        If executeResult Then
            Return True
        End If
        Return False
    End Function


    <WebMethod()>
    Public Shared Function PatientExists(forename As String, surname As String, dob As String, cnn As String) As String

        Dim exists = False
        Dim sSQL = "SELECT PatientId, Title, Forename1, Surname, DateOfBirth, NHSNo, dbo.fnFullAddress(Address1, Address2, Address3, Address4, '') AS Address FROM ERS_Patients WHERE"

        If Not String.IsNullOrWhiteSpace(forename) Then sSQL += " Forename1 = '" & forename & "' AND" Else Return ""
        If Not String.IsNullOrWhiteSpace(surname) Then sSQL += " Surname = '" & surname & "' AND" Else Return ""
        If Not String.IsNullOrWhiteSpace(dob) Then sSQL += " CONVERT(varchar(10), DateOfBirth, 103) = '" & CDate(dob).ToShortDateString & "' AND" Else Return ""
        If Not String.IsNullOrWhiteSpace(cnn) Then sSQL += " patientId in (Select PatientId from ERS_PatientTrusts where HospitalNumber like '%" & cnn & "%') AND"

        sSQL = sSQL.Remove(sSQL.LastIndexOf("AND"))

        Dim dt = DataAccess.ExecuteSQL(sSQL)
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Dim patientsRetVal As New List(Of Object)

            'build object and serialize
            For Each dr In dt.Rows
                Dim vals = New With {
                    .PatientId = dr("PatientId")
                }

                patientsRetVal.Add(vals)
            Next

            Return New JavaScriptSerializer().Serialize(patientsRetVal)
        Else
            Return Nothing
        End If
    End Function

    <WebMethod()>
    Public Shared Function GetNOGPCode() As Integer
        Dim sSQL = "SELECT GPId FROM ERS_GPS WHERE Name = 'Not Stated'"
        Dim dt = DataAccess.ExecuteSQL(sSQL)

        If dt IsNot Nothing Then
            Return CInt(dt.Rows(0)("GPId"))
        Else
            Return 0
        End If
    End Function

    <WebMethod()>
    Public Shared Function GetGMCCode(userId As Integer) As String
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return (From u In db.ERS_Users Where u.UserID = userId Select u.GMCCode).FirstOrDefault()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in webcall GetGMCCode", ex)
            Throw ex
        End Try
    End Function

    <WebMethod()>
    Public Shared Function ValidateGMCCodes(endoIds As List(Of Integer), gmcIDs As List(Of Integer))
        Try
            Dim inValidGMCID As New List(Of Integer)
            If Not String.IsNullOrEmpty(ConfigurationManager.AppSettings("ValidateGMCCode")) And ConfigurationManager.AppSettings("ValidateGMCCode") = "true" Then
                For i = 0 To gmcIDs.Count - 1
                    If Not NedClass.ValidateGMCCode(gmcIDs.ElementAt(i)) Then
                        inValidGMCID.Add(endoIds.ElementAt(i))
                    End If
                Next
            End If

            Return inValidGMCID
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in webcall CheckGMCCodes", ex)
            Throw ex
        End Try
    End Function

    <WebMethod()>
    Public Shared Function CheckGMCCodes(endoIds As List(Of Integer))
        Try
            Using db As New ERS.Data.GastroDbEntities
                Return (From usrs In db.ERS_Users
                        Where endoIds.Contains(usrs.UserID) And
                             (usrs.GMCCode Is Nothing Or usrs.GMCCode = "")
                        Select usrs.UserID).ToList

                'Return (From r in dbResult where r.GMCCode )
                'Dim retVal As New List(Of Object)

                'If dbResult IsNot Nothing Then
                '    For Each res In dbResult.Where(Function(x) x.GMCCode Is Nothing Or x.GMCCode = "")
                '        Dim vals = New With {
                '        .UserId = res.UserID,
                '        .Name = res.Description
                '        }

                '        retVal.Add(vals)

                '    Next
                'End If

                'If retVal.Count > 0 Then
                '    Return New JavaScriptSerializer().Serialize(retVal)
                'Else
                '    Return ""
                'End If
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in webcall CheckGMCCodes", ex)
            Throw ex
        End Try
    End Function

    <WebMethod()>
    Public Shared Function UpdateTransnasalProcedure(transnasal As Boolean)
        Try
            Dim da As New DataAccess
            da.setTransnasal(transnasal)
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in webcall UpdateTransnasalProcedure", ex)
            Throw ex
        End Try
    End Function

    <WebMethod()>
    Public Shared Function UpdateEUSSuccess(EUSSuccessful As Boolean)
        Try
            Dim da As New DataAccess
            da.setEUSSuccess(EUSSuccessful)
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in webcall UpdateEUSSuccess", ex)
            Throw ex
        End Try
    End Function


    <WebMethod()>
    Public Shared Function KeepAlive() As String
        Return "OK"
    End Function

    <WebMethod()>
    Public Shared Function ClearPatientSession() As String
        Dim sm As New SessionManager
        sm.ClearPatientSessions()
        Return Nothing
    End Function

    <WebMethod()>
    Public Shared Function getProcedurePoints(procedureTypeId As Integer, operatingHospitalId As Integer, listTypeId As String) As Decimal 'Added by rony tfs-4175
        Try
            Using db As New ERS.Data.GastroDbEntities
                If listTypeId = "" Or listTypeId = "Service List" Then
                    listTypeId = 0
                Else listTypeId = 1
                End If

                Dim points = (From x In db.ERS_SCH_PointMappings
                              Where x.OperatingHospitalId = operatingHospitalId And
                              x.ProceduretypeId = procedureTypeId And
                              x.Training = listTypeId And
                              x.NonGI = 0
                              Select If(procedureTypeId = 2, x.TherapeuticPoints, x.Points)).FirstOrDefault

                Return If(If(points, 1) Mod 1 = 0, CInt(If(points, 1)), If(points, 1))
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    '<System.Web.Services.WebMethod()>
    'Public Shared Function SavePDFFile(pdfExportFilePathName As String, procedureDescription As String,
    '                              procedureDate As String, patientId As Integer) As Boolean
    '    Try
    '        Using output As New FileStream(pdfExportFilePathName, FileMode.Open)
    '            Dim iLen As Integer = CInt(output.Length)
    '            Dim bBLOBStorage(iLen) As Byte
    '            output.Read(bBLOBStorage, 0, iLen)
    '            Dim pdInstance = New Products_Default
    '            Dim dataAdapter As DataAccess = Nothing

    '            If dataAdapter Is Nothing Then
    '                dataAdapter = New DataAccess
    '            End If
    '            dataAdapter.SavePDFToDatabase(patientId, procedureDescription, procedureDate, bBLOBStorage)
    '        End Using

    '        Return New JavaScriptSerializer().Serialize(True)

    '    Catch ex As Exception
    '        Dim errorLogRef As String
    '        errorLogRef = LogManager.LogManagerInstance.LogError("Error occured in SavePDFFile", ex)
    '        Return New JavaScriptSerializer().Serialize(False)
    '    End Try
    'End Function

    '<System.Web.Services.WebMethod()>
    'Public Shared Function RemovePDFFile(previousProcId As Integer, removeReason As String) As Boolean
    '    Try
    '        DataAdapter2.DeletePreviousProcedure(CInt(previousProcId), removeReason)

    '        Return New JavaScriptSerializer().Serialize(True)

    '    Catch ex As Exception
    '        Dim errorLogRef As String
    '        errorLogRef = LogManager.LogManagerInstance.LogError("Error occured in SavePDFFile", ex)
    '        Return New JavaScriptSerializer().Serialize(False)
    '    End Try
    'End Function

#End Region

#Region "Patient Search"
    Sub BindPatientGrid(SelectedCriteria As String, SearchBoxText As String)
        'select search result tab
        If PatientPageView.Selected Then
            LandingPageView.Selected = True
        End If

        RadPageView2.Visible = True
        MainRadTabStrip.Tabs(1).Selected = True
        MainRadTabStrip.Tabs(1).Visible = True
        RadMultiPage1.PageViews(1).Selected = True
        PatientResultsControl.DisplaySearchResults(SelectedCriteria, SearchBoxText)
    End Sub

#End Region

    <WebMethod()>
    Public Shared Function GetGenderSpecific(procedureTypeId As Integer) As Boolean
        Try
            Dim dataTable As DataTable = DataAdapter2.GetGenderSpecific(procedureTypeId)

            If Not dataTable Is Nothing Then
                If dataTable.Columns.Contains("GenderSpecific") Then
                    Dim GenderSpecific As Boolean = dataTable.Rows(0)("GenderSpecific")
                    Return GenderSpecific
                End If
            End If
            Return False
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    <WebMethod()>
    Public Shared Function UnLockProcedure(procedureId As Integer) As Boolean
        Try
            Dim da As DataAccess = New DataAccess()

            da.UnLockProcedure(procedureId)
            Return True

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    <WebMethod()>
    Public Shared Sub SavePreAssementQuestion(preAssessmentId As Integer, questionId As Integer?, answerId As Integer?, optionAnswer As Integer, freeTextAnswer As String, dropdownAnswer As String)
        Try
            Dim da As New OtherData
            da.SavePreAssessmentAnswers(preAssessmentId, questionId, answerId, optionAnswer, freeTextAnswer, dropdownAnswer.Trim())

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error saving cancer follow up answer", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Sub
    <System.Web.Services.WebMethod()>
    Public Shared Function CheckRequiredQuestion(preAssessmentId As Integer) As String
        Try
            Dim da As New OtherData
            Dim result = da.CheckRequiredQuestions(preAssessmentId)
            Return result
        Catch ex As Exception
            Return ""
        End Try

    End Function
    <WebMethod()>
    Public Shared Function getManufactuerGeneration(ByVal manufactureId As Integer)
        Try
            Dim da As New DataAccess
            Dim data = da.GetScopeManufacturerGeneration(manufactureId)
            Dim json As String = JsonConvert.SerializeObject(data)
            Return json
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    <WebMethod()>
    Public Shared Sub SaveNurseModuleAnswer(nurseModuleId As Integer, questionId As Integer?, answerId As Integer?, optionAnswer As Integer, freeTextAnswer As String, dropdownAnswer As String)
        Try
            Dim da As New OtherData
            da.SaveNurseModuleAnswers(nurseModuleId, questionId, answerId, optionAnswer, freeTextAnswer, dropdownAnswer.Trim())

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error saving cancer follow up answer", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Sub
    <System.Web.Services.WebMethod()>
    Public Shared Function CheckNurseModuleRequiredQuestions(nurseModuleId As Integer) As String
        Try
            Dim da As New OtherData
            Dim result = da.CheckNurseModuleRequiredQuestions(nurseModuleId)
            Return result
        Catch ex As Exception
            Return ""
        End Try

    End Function
    'Added by rony tfs-3059
    <WebMethod()>
    Public Shared Function DeleteReportData(procedureId As Integer, previousProcedureId As Integer, sERSViewer As Boolean, deleteTxt As String) As Boolean
        Try
            Dim da As DataAccess = New DataAccess()
            If Not sERSViewer Then
                If previousProcedureId = 0 Then
                    da.DeleteProcedure(procedureId, deleteTxt)
                End If
            End If
            Return True
        Catch ex As Exception
            Throw ex
        End Try
    End Function
End Class