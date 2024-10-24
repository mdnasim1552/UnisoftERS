Imports Telerik.Web.UI
Imports System.Drawing
Imports System.Data.SqlClient
Imports System.IO
Imports System.Windows
Imports Microsoft.Ajax.Utilities
Imports Hl7.Fhir.Model
Imports Telerik.Web.UI.Calendar
Public Class patientview
    Inherits System.Web.UI.UserControl

    'Public Property setPKUser As Boolean = False
    Public Property Enabled As Boolean = True
    Public Shared canEdit As Integer  ' added by Ferdowsi TFS 4199
    Public Shared canCreate As Integer  ' added by Ferdowsi TFS 4199
    Private patientId As Int32 = 0
    Dim showPreAssessment As String = ConfigurationManager.AppSettings("ShowPreAssessment")
    Dim showNurseModule As String = ConfigurationManager.AppSettings("ShowNurseModule")
    Public Property lockedUserName As String = ""
    Dim hasConsultantChanged As Boolean = False

    Public ReadOnly Property LogFolderPath() As String
        Get
            Return CType(Me.Page, Products_Default).LogFolderPath
        End Get
    End Property

    Public ReadOnly Property PhotosFolderUri() As String
        Get
            Return CType(Me.Page, Products_Default).PhotosFolderUri
        End Get
    End Property

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init

        If Not IsPostBack Then
            Dim _license As New License(ConfigurationManager.AppSettings("Unisoft.LicenseKey"))
            ProcedureDate.SelectedDate = DateTime.Today
            ProductChanged(1)
            ChkPatientConsent()
            ChkPatientNotesAvailableMandatory()
            Session(Constants.SESSION_PRE_ASSESSMENT_Id) = Nothing
            If Not DataAdapter.GetSurgicalSafetyCheckListCompleted Then
                If PrevProcsTreeViewContextMenu.FindItemByValue("who") IsNot Nothing Then PrevProcsTreeViewContextMenu.FindItemByValue("who").Visible = False
                If PrevProcsTreeViewContextMenu.FindItemByValue("swho") IsNot Nothing Then PrevProcsTreeViewContextMenu.FindItemByValue("swho").Visible = False
            End If
            'LoadComboBoxes()
        End If
        If Session(Constants.SESSION_TREE_GROUP_TYPE) Is Nothing Then
            Session(Constants.SESSION_TREE_GROUP_TYPE) = 2
        End If

    End Sub

    Protected Sub patientview_Init()

    End Sub

    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then
            Dim oWnd As RadWindow = TryCast(FindControl("UnlockProcedureWindow"), RadWindow)
            oWnd.VisibleOnPageLoad = False
        End If

        ProcedureDateRadDatePicker.MaxDate = DateTime.Now
        RemoveProcedureTypeLabel.BorderColor = Color.LightGray
        RemoveProcedureDateRadDatePicker.BorderColor = Color.LightGray

        lblNHSNo.Text = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " no: "
        Dim myAjaxMgr3 As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr3.AjaxSettings.AddAjaxSetting(CreateProcedureButton, RadSplitter2, RadAjaxLoadingPanel1)
        myAjaxMgr3.AjaxSettings.AddAjaxSetting(CreateProcedureButton, RadNotification1)
        myAjaxMgr3.AjaxSettings.AddAjaxSetting(PrevProcsTreeViewContextMenu, RadSplitter2, RadAjaxLoadingPanel1)
        If IsNothing(Session("ProcedureFromOrderComms")) Then
            lblOCProcedure.Text = ""
        ElseIf Session("ProcedureFromOrderComms") = False Then
            lblOCProcedure.Text = ""
        End If

        AddHandler myAjaxMgr3.AjaxRequest, AddressOf RadAjaxManager1_AjaxRequest
        CheckTime()

    End Sub

    Protected Sub CheckTime()
        Dim offsetMinutes As Integer = CInt(Session("TimezoneOffset"))
        Dim curTime As Date = DateTime.UtcNow.AddMinutes(-offsetMinutes)
        If curTime.Hour > 12 Then
            TimeComboBox.SelectedValue = "PM"
        Else
            TimeComboBox.SelectedValue = "AM"
        End If
    End Sub

    Protected Sub ChkPatientConsent()
        Dim OBda As New Options
        Dim bIsPatientConsent As Boolean = OBda.IsPatientConsent()
        If bIsPatientConsent Then
            trPatientConsent.Visible = True
            'tdSeperatorPatientConsent.Attributes("class") = "border_bottom"
        Else
            trPatientConsent.Visible = False
            'tdSeperatorPatientConsent.Attributes("class") = ""
        End If
    End Sub
    Protected Sub ChkPatientNotesAvailableMandatory() 'MH created on 16 Jan 2024
        Dim OBda As New Options
        Dim bIsPatientNotesAvailable As Boolean = OBda.IsPatientNotesAvailable()
        If bIsPatientNotesAvailable Then
            tdPatientsNotesAvailable.Visible = True
            'tdSeperatorPatientNotesAvailable.Attributes("class") = "border_bottom"
        Else
            tdPatientsNotesAvailable.Visible = False
            'tdSeperatorPatientNotesAvailable.Attributes("class") = ""
        End If
    End Sub

    'Protected Sub myAjaxMgr_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
    '    If Session(Constants.SESSION_PATIENT_ID) IsNot Nothing Then
    '        'LoadPatientPage()
    '        If Session("NewPatientAdded") IsNot Nothing Then
    '            Response.Redirect("Default.aspx?patient=true", False)
    '        Else
    '            LoadPatientInfo()
    '        End If
    '    End If
    'End Sub

    Public Sub optionERSViewer()
        NewProcedurePageView.Visible = False
        PrintInitiateUserControl.optionERSViewer()
    End Sub

    Public Sub LoadPatientInfo()
        Dim dtPat As DataTable = New SessionManager().SetPatientSessions(patientId)

        lblCaseNoteNo.Text = DataAdapter.GetCountryLabel("CNN")
        lblNHSNo.Text = DataAdapter.GetCountryLabel("NHSNo")
        PatientName.Text = Session("PatSurname") & ", " & Session("PatForename") & " (" & Session("PatGender") & ")"
        CNN.Text = Session("PatCNN")
        NHSNo.Text = Utilities.FormatHealthServiceNumber(Session("PatNHS"))
        If Not IsNothing(Session("PatDOB")) And Session("PatDOB").ToString().Trim() <> "" Then
            DOB.Text = Session("PatDOB") & " (" & Utilities.GetAgeAtDate(CDate(Session("PatDOB")), Today) & ")"
        Else
            DOB.Text = ""
        End If


        RecCreated.Text = Session("PatCreated")
        Ethnicity.Text = Session("PatEthnicity")
        PatientIdHiddenField.Value = patientId

        If dtPat.Rows.Count > 0 Then
            If Not IsDBNull(dtPat.Rows(0)("Address")) Then
                Address.Text = dtPat.Rows(0)("Address").ToString().Replace(Char.ConvertFromUtf32(10), "<br />")
            End If
            'PatientPostCode.Text = dtPat.Rows(0)("PostCode").ToString()

            GPName.Text = dtPat.Rows(0)("GPName").ToString()
            If Not IsDBNull(dtPat.Rows(0)("PracticeName")) Then
                PracticeName.Text = dtPat.Rows(0)("PracticeName").ToString().Replace(Char.ConvertFromUtf32(10), "<br />")
            End If
            If Not IsDBNull(dtPat.Rows(0)("GPAddress")) Then
                GPAddress.Text = dtPat.Rows(0)("GPAddress").ToString().Replace(Char.ConvertFromUtf32(10), "<br />")
            End If

            'Session("GPEmailAddress") = DataAccess.GetGPEmailAddress(Session("PatientId"), Session("PKUserId"), Session("UserId"))
            'Added by rony tfs-4206
            TelephoneNo.Text = dtPat.Rows(0)("Telephone").ToString()
            Email.Text = dtPat.Rows(0)("Email").ToString()
            MobileNo.Text = dtPat.Rows(0)("MobileNo").ToString()
            KentOfKin.Text = dtPat.Rows(0)("KentOfKin").ToString()
            Modalities.Text = dtPat.Rows(0)("Modalities").ToString()
        End If
    End Sub

    Public Sub LoadTreeView()

        Dim groupType = CInt(TreeRadioGroupList.SelectedValue)


        If patientId = Nothing Then
            patientId = PatientIdHiddenField.Value
        End If

        Dim ds As New DataAccess
        Dim dtProcedures = ds.GetProcedures(Session("UserID"), patientId, CBool(ConfigurationManager.AppSettings("Unisoft.ShowOldProcedures")))
        PrevProcsTreeView.Nodes.Clear()
        PrevProcsTreeView.Enabled = True
        Dim nodeNewProc As New RadTreeNode()

        ''New Procedures not required for ERS Viewer
        If (Not CBool(Session("isERSViewer")) And CBool(Session(Constants.SESSION_IS_PRE_ASSESSMENT)) And CBool(Session(Constants.SESSION_IS_ERS_PATIENT))) And Not CBool(Session("PatDeceased")) Then
            nodeNewProc.Text = "New Procedure"
            nodeNewProc.Font.Bold = True
            nodeNewProc.Selected = False
            nodeNewProc.Enabled = True
            PrevProcsTreeView.Nodes.Add(nodeNewProc)
        ElseIf (Not CBool(Session("isERSViewer")) And CBool(Session(Constants.SESSION_IS_ERS_PATIENT))) And Not CBool(Session("PatDeceased")) Then
            nodeNewProc.Text = "New Procedure"
            nodeNewProc.Font.Bold = True
            nodeNewProc.Selected = True
            nodeNewProc.Enabled = True
            PrevProcsTreeView.Nodes.Add(nodeNewProc)
        End If
        Dim newNurseModuleProc As New RadTreeNode()
        ''For Nursing Module added
        If (Not String.IsNullOrEmpty(showNurseModule) AndAlso showNurseModule.ToLower() = "y") And (Not CBool(Session("isERSViewer")) And CBool(Session(Constants.SESSION_IS_ERS_PATIENT))) And Not CBool(Session("PatDeceased")) Then
            newNurseModuleProc.Text = "New Nursing Module"
            newNurseModuleProc.Font.Bold = True
            newNurseModuleProc.Selected = False
            newNurseModuleProc.Enabled = True
            IsNewNurses.Value = "false"
            PrevProcsTreeView.Nodes.Add(newNurseModuleProc)
        End If

        Dim preAssessNodeNewProc As New RadTreeNode()
        ''For pre assessment node added
        If (Not String.IsNullOrEmpty(showPreAssessment) AndAlso showPreAssessment.ToLower() = "y") And (Not CBool(Session("isERSViewer")) And CBool(Session(Constants.SESSION_IS_PRE_ASSESSMENT)) And CBool(Session(Constants.SESSION_IS_ERS_PATIENT))) And Not CBool(Session("PatDeceased")) Then
            preAssessNodeNewProc.Text = "New Pre Assessment"
            preAssessNodeNewProc.Font.Bold = True
            preAssessNodeNewProc.Selected = True
            SpecialityCheckBox.Visible = False
            TreeRadioGroupList.SelectedValue = 2
            ProcedureStartDateRadTimeInput.SelectedDate = DateTime.Now
            ProcedureStartRadTimePicker.SelectedTime = TimeSpan.Parse(DateTime.Now.TimeOfDay.Hours)
            preAssessNodeNewProc.Enabled = True
            IsNewPreAssess.Value = "true"
            PrevProcsTreeView.Nodes.Add(preAssessNodeNewProc)
        ElseIf (Not String.IsNullOrEmpty(showPreAssessment) AndAlso showPreAssessment.ToLower() = "y") And (Not CBool(Session("isERSViewer")) And CBool(Session(Constants.SESSION_IS_ERS_PATIENT))) And Not CBool(Session("PatDeceased")) Then
            preAssessNodeNewProc.Text = "New Pre Assessment"
            preAssessNodeNewProc.Font.Bold = True
            preAssessNodeNewProc.Selected = False
            preAssessNodeNewProc.Enabled = True
            IsNewPreAssess.Value = "false"
            PrevProcsTreeView.Nodes.Add(preAssessNodeNewProc)
        End If


        If Session(Constants.SESSION_TREE_GROUP_TYPE) = 2 Then


            Dim rootNode As New RadTreeNode("Procedure")
            Dim prevRootNode As New RadTreeNode("Previous Procedures")
            prevRootNode.Font.Bold = True
            prevRootNode.Expanded = False
            'Dim bLocked As Boolean = False
            Dim bDisplayMessage As Boolean = False
            'Dim dT As DataTable = ds.isPatientProceduresLocked(Session("UserID"), CInt(Session(Constants.SESSION_PATIENT_ID)))
            'If Not IsNothing(dT) AndAlso dT.Rows.Count > 0 Then
            '    If CInt(dT.Rows(0).Item("isLocked")) = 1 Then bLocked = True
            '    rootNode.ToolTip = dT.Rows(0).Item("LockedMessage")
            'End If

            Dim childNode As RadTreeNode
            rootNode.Font.Bold = True
            rootNode.Expanded = True

            addOrderRootNode(True)

            Dim preassessmentRootNode As New RadTreeNode("Pre Assessment")

            Dim groupedProcedures = From row In dtProcedures.AsEnumerable()
                                    Where Not row.IsNull("PreAssessmentId")
                                    Group row By PreAssessmentId = row.Field(Of Integer)("PreAssessmentId") Into Group
                                    Let PreAssessmentDate = Group.Max(Function(r) r.Field(Of DateTime)("PreAssessmentDate"))
                                    Order By PreAssessmentDate Descending
                                    Select PreAssessmentId, Procedures = Group, PreAssessmentDate

            For Each group In groupedProcedures.Take(5)
                Dim preAssessmentDate As DateTime = group.Procedures(0).Field(Of DateTime)("PreAssessmentDate")
                Dim rootGroupNode As New RadTreeNode(preAssessmentDate.ToString("dd/MM/yyyy") + " - Pre Assessment")
                rootGroupNode.Font.Bold = True
                rootGroupNode.Expanded = True
                Dim value = CInt(group.Procedures(0).Field(Of Integer)("PreAssessmentId"))
                Dim isProcedureCompleted As Boolean = True
                rootGroupNode.Attributes.Add("PreAssessmentId", CInt(group.Procedures(0).Field(Of Integer)("PreAssessmentId")))
                rootGroupNode.Attributes.Add("ProcedureTypes", group.Procedures(0).Field(Of String)("PreAssessProcTypes"))
                rootGroupNode.Attributes.Add("PreAssessmentDate", preAssessmentDate)
                Dim hasNoChild = True
                For Each dr In group.Procedures.Take(5)
                    If CInt(dr!ProcedureId) > 0 Then

                        Dim displayName As String = dr.Field(Of String)("DisplayName")
                        childNode = New RadTreeNode(displayName)
                        Dim updatedChild = PrepareChildNodeForTree(childNode, dr, isProcedureCompleted)
                        rootGroupNode.Nodes.Add(updatedChild)
                        hasNoChild = False
                    End If
                Next
                If hasNoChild Then
                    rootGroupNode.Attributes.Add("IsParent", "true")
                Else
                    rootGroupNode.Attributes.Add("IsParent", "false")
                End If
                If Not isProcedureCompleted Then
                    rootGroupNode.CssClass = "ProcedureIncomplete"
                    rootGroupNode.ToolTip = "PreAssessment incomplete"
                End If
                preassessmentRootNode.Font.Bold = True
                preassessmentRootNode.Nodes.Add(rootGroupNode)
                preassessmentRootNode.Expanded = True
                PrevProcsTreeView.Nodes.Add(preassessmentRootNode)
            Next

            Dim filteredRows = From row In dtProcedures.AsEnumerable()
                               Where row.IsNull("PreAssessmentId") OrElse row.Field(Of Integer)("PreAssessmentId") <= 0
                               Select row
            Dim count = 0
            If dtProcedures.Rows.Count > 0 Then

                For Each dr As DataRow In filteredRows

                    childNode = New RadTreeNode(CStr(dr!DisplayName))
                    Dim displayName As String = dr.Field(Of String)("DisplayName")
                    Dim isProcedureCompleted As Boolean = True
                    childNode = New RadTreeNode(displayName)
                    Dim updatedChild = PrepareChildNodeForTree(childNode, dr, isProcedureCompleted)

                    If Not isProcedureCompleted Then
                        updatedChild.CssClass = "ProcedureIncomplete"
                        updatedChild.ToolTip = "Report incomplete"
                    End If

                    If count < 5 Then

                        rootNode.Nodes.Add(updatedChild)
                        count = count + 1
                    Else
                        prevRootNode.Nodes.Add(updatedChild)
                        count = count + 1
                    End If
                    'bDisplayMessage = True
                    'If Not nodeNewProc Is Nothing Then
                    '    'Dim sHREF As String = "#"
                    '    'If CBool(dr!ERS) = True Then
                    '    '    sHREF = "PatientProcedure.aspx?rep=incomplete&pID=" & childNode.Attributes("ProcedureId") & "&pType=" & childNode.Attributes("ProcedureType") & "&cType=" & childNode.Attributes("ColonType")
                    '    'End If
                    '    'nodeNewProc.LongDesc = "<a href='" & sHREF & "' style='color:red;'>This patient has previous incomplete report (" & childNode.Text & "). <br />Please complete this report or contact your system administrator to create a new procedure. </a>"
                    '    nodeNewProc.LongDesc = "This patient has previous incomplete report (" & childNode.Text & "). <br />Please complete this report or contact your system administrator to create a new procedure."
                    '    nodeNewProc.Attributes.Add("ProcedureId", CInt(dr!ProcedureId))
                    '    nodeNewProc.Attributes.Add("ProcedureType", CInt(dr!ProcedureType))
                    '    nodeNewProc.Attributes.Add("ColonType", CStr(dr!ColonType))
                    '    DisplayMessage(nodeNewProc)
                    'End If
                    'ElseIf CBool(dr!Locked) And CStr(dr!LockedBy) <> "0" And CStr(dr!LockedBy) <> CStr(Session("PKUserID")) And Not bLocked Then
                    ' bLocked = True 'Lock record for other users
                    'ElseIf CBool(dr!Locked) And CStr(dr!LockedBy) = CStr(Session("PKUserID")) Then
                    '    setPKUser = True

                    'childNode.Attributes.Add("Locked", bLocked)
                    'If bLocked Then
                    '    childNode.Text = " <img src='../Images/Lock-Lock-48x48.png' alt='Locked' style='width:12px;height:12px'>" + childNode.Text
                    '    childNode.ToolTip = rootNode.ToolTip
                    'End If
                Next

                If rootNode.Nodes.Count > 0 Then
                    PrevProcsTreeView.Nodes.Add(rootNode)
                End If
                If (Not String.IsNullOrEmpty(showNurseModule) AndAlso showNurseModule.ToLower() = "y") Then

                    Dim dtNurseModule = ds.GetNurseModuleList(patientId)
                    Dim nurseGroupNode As New RadTreeNode("Nursing Module")
                    If dtNurseModule.Tables(0).Rows.Count > 0 Then
                        rootNode.Nodes.Add(nurseGroupNode)
                        For Each dr As DataRow In dtNurseModule.Tables(0).Rows
                            Dim nurseModuleDate As DateTime = dr!NurseModuleDate
                            Dim childNodes = New RadTreeNode(nurseModuleDate.ToString("dd/MM/yyyy") + " - Nursing Module")
                            childNodes.Font.Bold = True
                            childNodes.Attributes.Add("NurseModuleId", CInt(dr!NurseModuleId))
                            childNodes.Attributes.Add("ProcedureTypes", dr!ProcedureType)
                            childNodes.Attributes.Add("NurseModuleDate", dr!NurseModuleDate)
                            nurseGroupNode.Nodes.Add(childNodes)
                        Next
                        nurseGroupNode.Font.Bold = True
                        nurseGroupNode.Enabled = True
                        nurseGroupNode.Expanded = True
                        PrevProcsTreeView.Nodes.Add(nurseGroupNode)
                    End If
                End If
                If count > 5 Then
                    PrevProcsTreeView.Nodes.Add(prevRootNode)
                End If

                Session("HelpTooltipElementId") = PrevProcsTreeView.ClientID
                If CBool(Session("isERSViewer")) Then
                    Session("HelpMessage") = "Click on a date to view and print the appropriate reports. Procedures in <span style='color:red;'>red</span> cannot be edited."
                Else
                    Session("HelpMessage") = "Click on <b>New Procedure</b> to create a new report. Click on a date to view, edit and print the appropriate reports. Procedures in <span style='color:red;'>red</span> cannot be edited."
                End If
            Else
                rootNode.Text = "No records found"
                rootNode.Nodes.Add(New RadTreeNode("No records found"))
                'PrevProcsTreeView.Nodes.Add(rootNode) ' As discussed with SPR, only label "New Procedure" to be displayed if there's no previous procedures
                'If blnOrdersFound = False Then
                '    PrevProcsTreeView.Enabled = False
                'End If
            End If

            'If bLocked Then
            '    rootNode.Text += " <img src='../Images/Lock-Lock-48x48.png' alt='Locked' style='width:12px;height:12px'>"
            '    nodeNewProc.Enabled = False
            'End If

            PageVisibleDecider(bDisplayMessage, rootNode)

            'OpenPDFUploadWindowRadButton.Attributes("onclick") = String.Format("return openPDFUpload('{0}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ListRulesId"))
        Else
            Dim procedures = From row In dtProcedures.AsEnumerable()
                             Where row.Field(Of Integer)("ProcedureId") > 0
            SpecialityCheckBox.Visible = True
            If PrevProcsTreeView.SelectedNode.Text <> "New Pre Assessment" Or PrevProcsTreeView.SelectedNode.Text <> "New Nursing Module" Then
                nodeNewProc.Selected = True
                TreeRadioGroupList.SelectedValue = 1
            End If
            loadProcedureView()
            If SpecialityCheckBox.Checked = True Then
                groupWiseChildLoaded(procedures, "")
            Else
                groupWiseChildLoaded(procedures, "Procedure")
            End If
            addOrderRootNode(False)
        End If
    End Sub
    Sub addOrderRootNode(isExpand As Boolean)
        'MH adde on 22 Feb 2022 - New Left menu header - Order Comms list
        Dim OCBal As New OrderCommsBL
        Dim dsOrderComs As New DataSet
        dsOrderComs = OCBal.GetAvailableOrderCommsByPatientId(patientId)
        Dim rootNodeOc As New RadTreeNode("Orders")
        Dim childNodeOc As RadTreeNode

        rootNodeOc.Font.Bold = True
        rootNodeOc.Expanded = isExpand
        Dim blnOrdersFound As Boolean
        blnOrdersFound = False
        If dsOrderComs.Tables(0).Rows.Count > 0 Then
            blnOrdersFound = True
        End If

        If blnOrdersFound Then
            rootNodeOc.Visible = True
            For Each drD As DataRow In dsOrderComs.Tables(0).Rows
                childNodeOc = New RadTreeNode(drD!OrderComDetailColmn)
                childNodeOc.Attributes.Add("OrderCommsOrderId", CInt(drD!OrderId))
                childNodeOc.Attributes.Add("OrderCommsChild", True)
                rootNodeOc.Nodes.Add(childNodeOc)
            Next
            If Not PrevProcsTreeView.Enabled Then
                PrevProcsTreeView.Enabled = True
            End If
            PrevProcsTreeView.Nodes.Add(rootNodeOc)
        End If
    End Sub

    Sub AddGroupNode(ByVal rootGroupNode As RadTreeNode, isExpanded As Boolean)
        rootGroupNode.Attributes.Add("IsParent", "true")
        rootGroupNode.Font.Bold = True
        rootGroupNode.Expanded = isExpanded
        PrevProcsTreeView.Nodes.Add(rootGroupNode)
    End Sub
    Sub groupWiseChildLoaded(ByVal ProcedureList As IEnumerable(Of DataRow), rootName As String)

        Dim isProcedureCompleted As Boolean = True
        Dim count = 0

        Dim prevRootGroupNode As New RadTreeNode("Previous Procedures")
        Dim rootProcs = PrevProcsTreeView.FindNodeByText(rootName)
        Dim procRootNode As RadTreeNode = Nothing

        If rootProcs Is Nothing And rootName <> "" Then
            procRootNode = New RadTreeNode(rootName)
            AddGroupNode(procRootNode, True)
        End If

        For Each dr In ProcedureList
                Dim root = PrevProcsTreeView.FindNodeByText(dr!GroupType)
                If root Is Nothing AndAlso rootName = "" AndAlso count < 5 Then
                    Dim rootGroupNode As New RadTreeNode(dr!GroupType)
                    root = rootGroupNode
                    AddGroupNode(rootGroupNode, True)
                End If
                Dim displayName As String = dr.Field(Of String)("DisplayName")
                Dim prochildNode = New RadTreeNode(displayName)
                Dim updatedChild = PrepareChildNodeForTree(prochildNode, dr, isProcedureCompleted)
                If count < 5 And rootName = "" Then
                    root.Nodes.Add(updatedChild)
                    count = count + 1
                Else

                    If count < 5 Then
                        procRootNode.Nodes.Add(updatedChild)
                        count = count + 1
                    Else
                        prevRootGroupNode.Nodes.Add(updatedChild)
                    End If

                End If
            Next
            If prevRootGroupNode.Nodes.Count > 0 Then
                AddGroupNode(prevRootGroupNode, False)
            End If
    End Sub
    Sub loadProcedureView()
        LoadComboBoxes()
        ClearPreassessmentSession(False)
        CreateProcedureButton.Enabled = Enabled ' Not bLocked And Enabled
        NewProcedurePageView.Selected = Enabled
    End Sub

    Sub PageVisibleDecider(ByVal bDisplayMessage As Boolean, ByVal rootNode As RadTreeNode)
        If (Not bDisplayMessage AndAlso Not CBool(Session("isERSViewer")) AndAlso Not CBool(Session(Constants.SESSION_IS_PRE_ASSESSMENT))) Then 'Or not CBool(Session("PatDeceased")) Then
            loadProcedureView()
        End If

        If (Not bDisplayMessage AndAlso Not CBool(Session("isERSViewer")) AndAlso CBool(Session(Constants.SESSION_IS_PRE_ASSESSMENT))) Then 'Or not CBool(Session("PatDeceased")) Then

            Session(Constants.SESSION_PROCEDURE_TYPES) = 1

            CreateOrUpdatePreAssessment(False)
            GetPreassessmentProcedure()
            BindQuestions()
            Session(Constants.SESSION_PROCEDURE_TYPE) = Nothing
            Session(Constants.SESSION_PROCEDURE_ID) = Nothing
            CreatePreAssessmentProcedureButton.Enabled = Enabled ' Not bLocked And Enabled
            NewPreassessmentProcedurePageView.Selected = Enabled

        End If

        If (CBool(Session("isERSViewer")) Or Not CBool(Session(Constants.SESSION_IS_ERS_PATIENT))) Or CBool(Session("PatDeceased")) Then
            DisplayMessage(rootNode)
        End If
    End Sub
    Sub DisplayMessage(node As RadTreeNode)
        lblMessage.CommandArgument = ""

        If Left(node.Text, 18) = "New Nursing Module" Then
            If node.LongDesc <> "" Then
                lblMessage.Text = node.LongDesc
                lblMessage.ForeColor = Color.Red
                lblMessage.Style.Add("text-decoration", "underline")
                lblMessage.CommandArgument = node.Attributes("ProcedureId") & "|" & node.Attributes("ProcedureType") & "|" & node.Attributes("ColonType")
                DisplayMessagePageView.Selected = True
            Else
                NurseCreatedDiv.Style.Add("display", "block")
                ClearPageWiseSession("New Nursing Module")
                IsNewNurses.Value = "true"
                CreateOrUpdateNurseModule(False)
                GetNurseModuleProcedure()
                BindNurseModuleQuestions()
                NewNurseModulePageView.Selected = True
            End If
        ElseIf Left(node.Text, 18) = "New Pre Assessment" Then
            If node.LongDesc <> "" Then
                lblMessage.Text = node.LongDesc
                lblMessage.ForeColor = Color.Red
                lblMessage.Style.Add("text-decoration", "underline")
                IsNewPreAssess.Value = "true"
                lblMessage.CommandArgument = node.Attributes("ProcedureId") & "|" & node.Attributes("ProcedureType") & "|" & node.Attributes("ColonType")
                DisplayMessagePageView.Selected = True
            Else
                ClearPageWiseSession("New Pre Assessment")
                preAssessBtnDiv.Style.Add("display", "block")
                IsNewPreAssess.Value = "true"
                CreateOrUpdatePreAssessment(False)
                GetPreassessmentProcedure()
                BindQuestions()
                Session(Constants.SESSION_PROCEDURE_ID) = Nothing
                NewPreassessmentProcedurePageView.Selected = True
            End If
        ElseIf Left(node.Text, 13) = "New Procedure" Then
            If node.LongDesc <> "" Then
                lblMessage.Text = node.LongDesc
                lblMessage.ForeColor = Color.Red
                lblMessage.Style.Add("text-decoration", "underline")
                lblMessage.CommandArgument = node.Attributes("ProcedureId") & "|" & node.Attributes("ProcedureType") & "|" & node.Attributes("ColonType")
                DisplayMessagePageView.Selected = True
            Else
                LoadComboBoxes()
                ClearPageWiseSession("New Procedure")
                NewProcedurePageView.Selected = True
                IsNewPreAssess.Value = "false"
            End If
        ElseIf Left(node.Text, 14) = "Pre Assessment" Then
            lblMessage.Text = "Select a report in the list of pre assessment to be displayed."
            lblMessage.ForeColor = ColorTranslator.FromHtml("#008080")
            lblMessage.Style.Add("text-decoration", "none")
            DisplayMessagePageView.Selected = True
        ElseIf Left(node.Text, 14) = "Nursing Module" Then
            lblMessage.Text = "Select a report in the list of Nursing Module to be displayed."
            lblMessage.ForeColor = ColorTranslator.FromHtml("#008080")
            lblMessage.Style.Add("text-decoration", "none")
            DisplayMessagePageView.Selected = True
        ElseIf Left(node.Text, 9) = "Procedure" Then
            lblMessage.Text = "Select a report in the list of procedures to be displayed."
            lblMessage.ForeColor = ColorTranslator.FromHtml("#008080")
            lblMessage.Style.Add("text-decoration", "none")
            DisplayMessagePageView.Selected = True
        ElseIf Left(node.Text, 19) = "Previous Procedures" Then
            lblMessage.Text = "Select a report in the list of procedures to be displayed."
            lblMessage.ForeColor = ColorTranslator.FromHtml("#008080")
            lblMessage.Style.Add("text-decoration", "none")
            DisplayMessagePageView.Selected = True
        ElseIf Left(node.Text, 16) = "No records found" Then
            lblMessage.Text = "No procedures found for the selected patient."
            lblMessage.ForeColor = ColorTranslator.FromHtml("#008080")
            lblMessage.Style.Add("text-decoration", "none")
            DisplayMessagePageView.Selected = True
        Else
            lblMessage.Text = "Select a report in the list of procedures to be displayed."
            lblMessage.ForeColor = ColorTranslator.FromHtml("#008080")
            lblMessage.Style.Add("text-decoration", "none")
            DisplayMessagePageView.Selected = True
        End If
    End Sub
    Private Sub ClearPageWiseSession(ByVal page As String)

        Session(Constants.SESSION_PRE_ASSESSMENT_Id) = Nothing
        Session(Constants.SESSION_Nurse_Module_Id) = Nothing
        Session(Constants.SESSION_PROCEDURE_ID) = Nothing

        If (page.ToLower() = "New Procedure".ToLower()) Then
        ElseIf (page.ToLower() = "New Pre Assessment".ToLower()) Then
            Session(Constants.SESSION_PROCEDURE_TYPES) = "1"
        ElseIf (page.ToLower() = "New Nursing Module".ToLower()) Then
            Session(Constants.SESSION_PROCEDURE_TYPES) = "1"
        End If
    End Sub
    Private Function PrepareChildNodeForTree(childNode As RadTreeNode, Datarow As DataRow, ByRef isProcedureCompleted As Boolean) As RadTreeNode

        Dim dr = Datarow
        Dim DNA_Reason_PP_Text As String
        canEdit = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "Edit Procedure") ' added by Ferdowsi TFS 4199
        canCreate = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "create_procedure")
        Dim canDelete = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "delete_procedure")
        Dim canPrint = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "products_common_printreport_aspx")

        childNode.Attributes.Add("ERS", CInt(dr!ERS))
        childNode.Attributes.Add("ProcedureId", CInt(dr!ProcedureId))
        childNode.Attributes.Add("EpisodeNo", CInt(dr!EpisodeNo))
        childNode.Attributes.Add("PreviousProcedureId", CInt(dr!PreviousProcedureId))
        childNode.Attributes.Add("ProcedureType", CInt(dr!ProcedureType))
        childNode.Attributes.Add("ProcedureDate", CDate(dr!CreatedOn))
        childNode.Attributes.Add("PatientComboId", CStr(dr!PatientComboId))
        childNode.Attributes.Add("ColonType", CStr(dr!ColonType))
        childNode.Attributes.Add("SurgicalSafetyCheckListCompleted", CStr(dr!SurgicalSafetyCheckListCompleted))
        childNode.Attributes.Add("BreathTestResult", If(dr.IsNull("BreathTest"), -1, CInt(dr!BreathTest)))
        childNode.Attributes.Add("HasPhotos", CBool(dr!HasPhotos))
        childNode.Attributes.Add("procedureLocked", CStr(dr!procedureLocked))
        childNode.Attributes.Add("lockedUser", CStr(dr!LockedUser))
        childNode.Attributes.Add("lockedAt", CStr(dr!LockedAt))
        childNode.CssClass = "procedureLocked_" & CInt(dr!ProcedureId)
        childNode.Attributes.Add("Administrator", CStr(dr!Administrator))
        DNA_Reason_PP_Text = (dr!DNA_Reason_PP_Text)

        childNode.Attributes.Add("DNA_Reason_PP_Text", DNA_Reason_PP_Text)

        If canCreate = 0 Then
            childNode.Attributes.Add("isProcedureLocked", 1)
        Else
            childNode.Attributes.Add("isProcedureLocked", CInt(dr!isProcedureLocked))
        End If
        childNode.Attributes.Add("DiagramNumber", CInt(dr!DiagramNumber))
        childNode.Attributes.Add("ProcedureComplete", CBool(dr!ProcedureCompleted))

        If canDelete = 0 Then
            childNode.Attributes.Add("CanDelete", 0)
        End If

        If canEdit = 0 Then
            childNode.Attributes.Add("canEdit", 0) ' added by Ferdowsi TFS 4199
        End If

        If canPrint = 0 Then
            childNode.Attributes.Add("canPrint", 0)
        End If

        If ConfigurationManager.AppSettings("PrintPreview") = "false" Then
            childNode.Attributes.Add("canPrintPreview", 0)
        End If

        If CBool(dr!ERS) = False Then
            'childNode.ForeColor = Color.Red
            childNode.CssClass = "UGI_Procedure"
        ElseIf CBool(dr!ERS) = True AndAlso CInt(dr!isProcedureLocked) = 1 Then
            'childNode.ForeColor = Color.Purple
            childNode.CssClass = "LockedProcedure"
        ElseIf CStr(dr!procedureLocked) = "true" Then
            childNode.CssClass &= " procedureLocked"

        ElseIf CBool(dr!ERS) = True AndAlso CInt(dr!ProcedureCompleted) = 0 Then
            childNode.CssClass = "ProcedureIncomplete"
            childNode.ToolTip = "Report incomplete"
            isProcedureCompleted = False
        End If
        Return childNode
    End Function
    Sub AppendNodeChild(ByVal rootNodeName As String, ByVal attributeName As String, ByVal newNodeId As Integer, ByVal nodeSurname As String, ByVal dateAttribute As String)

        Dim rootNode As RadTreeNode = PrevProcsTreeView.FindNodeByText(rootNodeName)
        If rootNode IsNot Nothing Then
            Dim isExists As Boolean = False

            For Each childNode In rootNode.Nodes
                If childNode.Attributes(attributeName) IsNot Nothing Then
                    Dim existingPreAssessmentId As Integer = CInt(childNode.Attributes(attributeName))
                    If existingPreAssessmentId = newNodeId Then
                        isExists = True
                        Exit For
                    End If
                End If
            Next
            If Not isExists Then
                addChildNode(False, rootNode, attributeName, newNodeId, nodeSurname, dateAttribute)
            End If
        Else
            Dim nurseGroupNode As New RadTreeNode("Nurse Module")
            nurseGroupNode.Font.Bold = True
            nurseGroupNode.Enabled = True
            nurseGroupNode.Expanded = True
            Dim count = PrevProcsTreeView.Nodes.Count
            If count > 2 Then
                PrevProcsTreeView.Nodes.Insert(3, nurseGroupNode)
            Else
                PrevProcsTreeView.Nodes.Add(nurseGroupNode)
            End If
            addChildNode(True, nurseGroupNode, attributeName, newNodeId, nodeSurname, dateAttribute)
        End If
    End Sub
    Sub addChildNode(ByVal isNew As Boolean, ByVal rootNode As RadTreeNode, ByVal attributeName As String, ByVal newNodeId As Integer, ByVal nodeSurname As String, ByVal dateAttribute As String)
        Dim todayDate = DateTime.UtcNow
        Dim rootGroupNode As New RadTreeNode(todayDate.ToString("dd/MM/yyyy") + " - " + nodeSurname)
        rootGroupNode.Font.Bold = True
        rootGroupNode.Attributes.Add(attributeName, newNodeId)
        rootGroupNode.Attributes.Add("ProcedureTypes", Session(Constants.SESSION_PROCEDURE_TYPES))
        rootGroupNode.Attributes.Add(dateAttribute, todayDate)
        rootGroupNode.Attributes.Add("IsParent", "true")
        rootNode.Expanded = True

        If rootNode.Text = "Nursing Module" Then
            If isNew Then
                PrevProcsTreeView.Nodes.Add(rootNode)
            End If
            rootGroupNode.Selected = True
            rootNode.Nodes.Insert(0, rootGroupNode)
            EditNurseModule(rootGroupNode)
        Else
            Dim orderNode As RadTreeNode = PrevProcsTreeView.FindNodeByText("Orders")
            If isNew Then
                If orderNode IsNot Nothing Then
                    PrevProcsTreeView.Nodes.Insert(1, rootNode)
                Else
                    PrevProcsTreeView.Nodes.Insert(0, rootNode)
                End If
            End If
            rootNode.Nodes.Insert(0, rootGroupNode)
            rootGroupNode.Selected = False
        End If
    End Sub
    Public Sub MessageClicked()
        Dim sMessage As String = lblMessage.CommandArgument
        If sMessage = "" Then Exit Sub
        SessionHelper.SetProcedureSessions(CInt(sMessage.Split("|")(0)), False, CInt(sMessage.Split("|")(1)), CInt(sMessage.Split("|")(2)))
        EditProcedure()
    End Sub

    Private DataAdapter As New DataAccess
    Private SessionHelper As New SessionManager

    Protected Sub PrevProcsTreeView_ContextMenuItemClick(sender As Object, e As RadTreeViewContextMenuEventArgs) Handles PrevProcsTreeView.ContextMenuItemClick

        IsNewPreAssess.Value = "false"
        IsNewNurses.Value = "false"
        preAssessBtnDiv.Style.Add("display", "none")
        NurseCreatedDiv.Style.Add("display", "none")
        If Not IsNothing(Session("ProcedureFromOrderComms")) Then
            Session("ProcedureFromOrderComms") = Nothing
        End If
        If Not IsNothing(Session("OrderCommsOrderId")) Then
            Session("OrderCommsOrderId") = Nothing
        End If
        If Not IsNothing(lblOCProcedure) Then
            lblOCProcedure.Text = ""
        End If
        If Not IsNothing(e.Node.Attributes("PreAssessmentId")) Then


            If e.MenuItem.Text = "Add Procedure" Then
                NewPreassessmentProcedurePageView.Selected = False
                For Each node In PrevProcsTreeView.Nodes
                    node.Selected = False

                    If node.Text = "New Procedure" Then
                        node.Selected = True
                        NewProcedurePageView.Selected = True
                    End If
                Next

                Session(Constants.SESSION_IS_PRE_ASSESSMENT) = True
                Session(Constants.SESSION_PRE_ASSESSMENT_Id) = e.Node.Attributes("PreAssessmentId")

                LoadComboBoxes()
            ElseIf e.MenuItem.Text = "Edit" Then
                e.Node.Selected = True
                EditPreassessment(e.Node)
            Else e.MenuItem.Text = "Delete"
                deletePreassessment(e.Node)
            End If
        ElseIf Not IsNothing(e.Node.Attributes("NurseModuleId")) Then

            If e.MenuItem.Text = "Edit" Then
                e.Node.Selected = True
                EditNurseModule(e.Node)
            Else e.MenuItem.Text = "Delete"
                deleteNurseModule(e.Node)
            End If

        ElseIf Not IsNothing(e.Node.Attributes("OrderCommsChild")) Then
            'NewProcedurePageView.Selected = True

            'ProcTypeRadioButtonList.SelectedValue = 3

            'ConsultantComboBox.Text = ConsultantComboBox.Items(3).Text
            'ConsultantComboBox.Value = ConsultantComboBox.Items(3).Value
            'ConsultantComboBox.Items(3).Selected = True
            'SpecialityRadComboBox.Items(3).Selected = True
            If e.MenuItem.Text = "Order to Procedure" Then
                NewProcedurePageView.Selected = True

                'Set Session variable to use later
                Session("ProcedureFromOrderComms") = True
                Session("OrderCommsOrderId") = e.Node.Attributes("OrderCommsOrderId").ToString()
                If Not IsNothing(lblOCProcedure) Then
                    lblOCProcedure.Text = "From Order : " + e.Node.FullPath().Split("-")(1)
                    e.Node.Selected = True
                End If

                SetNewProcedureFromOrderComms(Convert.ToInt32(e.Node.Attributes("OrderCommsOrderId").ToString()))

            ElseIf e.MenuItem.Text = "View OrderComms" Then
                ViewOrderCommsPageView.Selected = True
                e.Node.Selected = True
                DisplayOrderCommsDetailsView(e.Node.Attributes("OrderCommsOrderId"))

                If Not IsNothing(Session("ProcedureFromOrderComms")) Then
                    Session("ProcedureFromOrderComms") = Nothing
                End If
                If Not IsNothing(Session("OrderCommsOrderId")) Then
                    Session("OrderCommsOrderId") = Nothing
                End If

                If Not IsNothing(lblOCProcedure) Then
                    lblOCProcedure.Text = ""
                End If

            End If

        Else
            ClearPreassessmentSession(False)
            selectedProcedureId.Value = CInt(e.Node.Attributes("ProcedureId"))
            selectedProcedureType.Value = CInt(e.Node.Attributes("ProcedureType"))

            If Not IsNothing(Session("ProcedureFromOrderComms")) Then
                Session("ProcedureFromOrderComms") = Nothing
            End If
            If Not IsNothing(Session("OrderCommsOrderId")) Then
                Session("OrderCommsOrderId") = Nothing
            End If
            If Not IsNothing(lblOCProcedure) Then
                lblOCProcedure.Text = ""
            End If
            'Added by rony tfs-2964 start
            Dim inputTxt As String = e.Node.Text
            Dim imgRegex As New Regex("<img[^>]*>", RegexOptions.IgnoreCase)
            Dim outputTxt As String = imgRegex.Replace(inputTxt, "")
            'End

            Select Case e.MenuItem.Text
                Case "Delete"
                    'Make sure Delete is not available for ERS Viewer
                    If Not CBool(Session("isERSViewer")) Then
                        If CInt(e.Node.Attributes("PreviousProcedureId")) = 0 Then
                            DataAdapter.DeleteProcedure(CInt(e.Node.Attributes("ProcedureId")))
                        End If
                    End If

                    'Response.Redirect("Default.aspx?CNN=" & Session(Constants.SESSION_CASE_NOTE_NO))
                    LoadPatientPage()
                Case "Edit"
                    'user can only edit the new procedures
                    If CBool(e.Node.Attributes("ERS")) Then
                        lockedUserName = CStr(e.Node.Attributes("lockedUser"))
                        SessionHelper.SetProcedureSessions(CInt(e.Node.Attributes("ProcedureId")), False, CInt(e.Node.Attributes("ProcedureType")), CInt(e.Node.Attributes("ColonType")))
                        EditProcedure()
                    End If

                Case "UnLock"
                    YesRadButton.Visible = True
                    PopUpCloseRadButton.Text = "No"
                    Dim oWnd As RadWindow = TryCast(FindControl("UnlockProcedureWindow"), RadWindow)
                    Dim user = CStr(e.Node.Attributes("lockedUser"))
                    lblDeleteMessage.Text = "This Procedure is locked by " & user & " at " & CStr(e.Node.Attributes("lockedAt")) & "." & vbCrLf & "Do you want to Unlock this Procedure?"
                    oWnd.VisibleOnPageLoad = True

                Case "Media"
                    e.Node.Selected = True 'set selected node for purpose of other tabs
                    NodeClick(e.Node)

                    PrevProcSummaryTabStrip.Tabs(1).Visible = True
                    PrevProcSummaryTabStrip.Tabs.Item(1).Selected = True
                    RMPPrevProcs.SelectedIndex = 1
                    PrevProcSummaryTabStrip.FindTabByText("Images").Selected = True
                    PrevProcSummaryTabStrip.FindTabByText("Images").PageView.Selected = True

                    PhotosObjectDataSource.SelectParameters("operatingHospitalId").DefaultValue = CInt(Session("OperatingHospitalID"))
                    PhotosObjectDataSource.SelectParameters("procedureId").DefaultValue = CInt(Session(Constants.SESSION_PROCEDURE_ID))
                    PhotosObjectDataSource.SelectParameters("episodeNo").DefaultValue = CInt(Session(Constants.SESSION_EPISODE_NO))
                    PhotosObjectDataSource.SelectParameters("patientComboId").DefaultValue = CStr(Session(Constants.SESSION_PATIENT_COMBO_ID))
                    PhotosObjectDataSource.SelectParameters("ColonType").DefaultValue = CStr(Session(Constants.SESSION_PROCEDURE_COLONTYPE))


                    RMPPrevProcs.SelectedIndex = 1

                'Dim tab1 As RadTab = PrevProcSummaryTabStrip.Tabs.FindTabByText("Images")
                'tab1.Selected = True
                'radPaneReportLeft.Width = 976

                Case "Print"
                    e.Node.Selected = True 'set selected node for purpose of other tabs
                    NodeClick(e.Node)
                    PrintInitiateUserControl.LoadPrintInitiatePage()
                    PrintInitiateUserControl.PopulateCopyTo()
                    PrevProcSummaryTabStrip.Tabs.Item(2).Selected = True
                    RMPPrevProcs.SelectedIndex = 2
                    PrevProcSummaryTabStrip.FindTabByText("Print").Selected = True
                    PrevProcSummaryTabStrip.FindTabByText("Print").PageView.Selected = True

                    RMPPrevProcs.SelectedIndex = 2

                    Dim tab1 As RadTab = PrevProcSummaryTabStrip.Tabs.FindTabByText("Print")
                    tab1.Selected = True
                    radPaneReportLeft.Width = 976

                'Page.ClientScript.RegisterStartupScript(Me.GetType(), "tabsel", "SelectPrintTab();", True)
                'ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "printtabsel", "SelectPrintTab();", True)

                'ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "printtabsel", "FixPageViewHeight();", True)
                Case "Print Preview"

                    Dim procId As String = String.Empty
                    Dim epiNo As String = String.Empty
                    Dim procTypeId As String = String.Empty
                    Dim colonType As String = String.Empty
                    Dim cnn As String = String.Empty
                    Dim diagramNum As String = String.Empty

                    procId = CStr(e.Node.Attributes("ProcedureId"))
                    epiNo = CStr(e.Node.Attributes("EpisodeNo"))
                    procTypeId = CStr(e.Node.Attributes("ProcedureType"))
                    colonType = CStr(e.Node.Attributes("ColonType"))
                    diagramNum = CStr(e.Node.Attributes("DiagramNumber"))

                    Session(Constants.SESSION_PATIENT_COMBO_ID) = ""
                    SessionHelper.SetProcedureSessions(procId, False, procTypeId, colonType)


                    Dim script As New StringBuilder

                    script.Append("var procId;")
                    script.Append("var epiNo;")
                    script.Append("var procTypeId;")
                    script.Append("var cType;")
                    script.Append("var cnn;")
                    script.Append("var diagramNum;")
                    script.Append("var previewOnly;")
                    script.Append("var deleteMedia;")

                    script.Append("procId = '" & procId & "';")
                    script.Append("epiNo = '" & epiNo & "';")
                    script.Append("procTypeId = '" & procTypeId & "';")
                    script.Append("cType = '" & colonType & "';")
                    script.Append("cnn = '" & cnn & "';")
                    script.Append("diagramNum = '" & diagramNum & "';")
                    script.Append("previewOnly = 'True';")
                    script.Append("deleteMedia = 'False';")

                    script.Append("GetDiagramScript();")

                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", script.ToString(), True)

                Case "Record use of REVERSAL AGENTS"
                    If CBool(e.Node.Attributes("ERS")) Then
                        SessionHelper.SetProcedureSessions(CInt(e.Node.Attributes("ProcedureId")), False, CInt(e.Node.Attributes("ProcedureType")), CInt(e.Node.Attributes("ColonType")))
                        Dim script As String = "var own = radopen('../Products/Gastro/OtherData/OGD/ReversalAgents.aspx?title=Reversal Agents - [ " + outputTxt + " ]', '', '500px');own.set_visibleStatusbar(false);"
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "showReversalAgentsWindow", script, True)
                    End If
                Case "Record patient COMFORT LEVELS"
                    SessionHelper.SetProcedureSessions(CInt(e.Node.Attributes("ProcedureId")), False, CInt(e.Node.Attributes("ProcedureType")), CInt(e.Node.Attributes("ColonType")))
                    Dim script As String = "var own = radopen('../Products/Gastro/OtherData/OGD/PostProcedualData.aspx?type=comfort-levels&title=Patient comfort levels - [ " + outputTxt + " ]', '', '590px','440px');own.set_visibleStatusbar(false);"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "showPostProceduralDataWindow", script, True)
                Case "Record PATHOLOGY RESULTS"
                    SessionHelper.SetProcedureSessions(CInt(e.Node.Attributes("ProcedureId")), False, CInt(e.Node.Attributes("ProcedureType")), CInt(e.Node.Attributes("ColonType")))
                    Session("PathDiagram") = CStr(e.Node.Attributes("DiagramNumber"))
                    PrevProcSummaryTabStrip.Tabs(3).Visible = True
                    PathologyResultsLinkButton.Visible = True
                    PrevProcSummaryTabStrip.Tabs.Item(3).Selected = True

                    PrevProcSummaryTabStrip.FindTabByText("Pathology Results").Selected = True
                    PrevProcSummaryTabStrip.FindTabByText("Pathology Results").PageView.Selected = True

                    e.Node.Selected = True 'set selected node for purpose of other tabs
                    NodeClick(e.Node)
                    PathologyResultsUserControl.fillPathologyResultsForm(CDate(e.Node.Attributes("ProcedureDate")))
                    radPaneReportLeft.Width = 976
                Case "Record belated UREASE results"
                    SessionHelper.SetProcedureSessions(CInt(e.Node.Attributes("ProcedureId")), False, CInt(e.Node.Attributes("ProcedureType")), CInt(e.Node.Attributes("ColonType")))
                    Dim script As String = "var own = radopen('../Products/Gastro/OtherData/OGD/PostProcedualData.aspx?type=urease-results&title=Urease Results - [ " + outputTxt + " ]', '', '500px', '140px');own.set_visibleStatusbar(false);"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "showPostProceduralDataWindow", script, True)
                Case "Record POST-PROCEDURE"
                    SessionHelper.SetProcedureSessions(CInt(e.Node.Attributes("ProcedureId")), False, CInt(e.Node.Attributes("ProcedureType")), CInt(e.Node.Attributes("ColonType")))
                    Dim script As String = "var own = radopen('../Products/Gastro/OtherData/OGD/PostProcedualData.aspx?type=post-op-complications&title=Post Procedure Complications - [ " + outputTxt + " ]', '', '750px', '675px');own.set_visibleStatusbar(false);"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "showPostOpComplicationsScript", script, True)
                Case "Breath Test"
                    SessionHelper.SetProcedureSessions(CInt(e.Node.Attributes("ProcedureId")), False, CInt(e.Node.Attributes("ProcedureType")), CInt(e.Node.Attributes("ColonType")))
                    Dim script As String = "var own = radopen('../Products/Gastro/OtherData/OGD/PostProcedualData.aspx?type=breath-test&title=Breath Test - [ " + outputTxt + " ]', '', '440px', '125px');own.set_visibleStatusbar(false);"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "showPostOpComplicationsScript", script, True)
            End Select
        End If
    End Sub

    Sub ClosePathTab() Handles PathologyResultsUserControl.SaveAndClose
        PrevProcSummaryTabStrip.Tabs(3).Visible = False
        PrevProcSummaryTabStrip.Tabs(3).Selected = False
        RMPPrevProcs.PageViews(3).Selected = False

        PrevProcSummaryTabStrip.Tabs(0).Visible = True
        RMPPrevProcs.PageViews(0).Selected = True

        'MH Changed on 02 Jan 2024
        'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "closePathologyResultsTab", "pathologyResultsTabClose();", True)

        PrevProcsTreeView_NodeClick(Me, New RadTreeNodeEventArgs(PrevProcsTreeView.SelectedNode))
    End Sub

    Sub EditProcedure()
        Dim procedure As ERS.Data.ERS_Procedures = BusinessLogic.Procedures_Select(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        Session("PortId") = procedure.ImagePortId
        Session("PortName") = New DataAccess().ImagePortName(procedure.ImagePortId)
        Dim lockStatus = New DataAccess().InsertLockedAt(CInt(Session(Constants.SESSION_PROCEDURE_ID)), CStr(Session("UserID")))
        If lockStatus = "false" Then
            Dim procedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))
            Dim dtDNA = DataAccess.ProcedureDNA(procedureId)
            If dtDNA IsNot Nothing AndAlso dtDNA.Rows.Count > 0 Then
                Response.Redirect("~/Products/PostProcedure.aspx", False)
            Else
                'Response.Redirect("~/Products/Procedure.aspx", False)
                Dim opt As New Options()
                Dim message = opt.CheckRequired(procedureId, 1)
                Session("message") = message
                If message <> String.Empty Then
                    Response.Redirect("~/Products/PreProcedure.aspx?message=1", False)
                Else
                    message = opt.CheckRequired(procedureId, 2)
                    Session("message") = message
                    If message <> String.Empty Then
                        Response.Redirect("~/Products/Procedure.aspx?message=2", False)
                    Else
                        message = opt.CheckRequired(procedureId, 3)
                        Session("message") = message
                        If message <> String.Empty Then
                            Response.Redirect("~/Products/PostProcedure.aspx?message=3", False)
                        Else
                            Response.Redirect("~/Products/Procedure.aspx?message=0", False)
                        End If
                    End If
                End If
            End If

        Else
            Dim oWnd As RadWindow = TryCast(FindControl("UnlockProcedureWindow"), RadWindow)
            lblDeleteMessage.Text = "This procedure is Locked by " & lockStatus
            oWnd.VisibleOnPageLoad = True
            YesRadButton.Visible = False
            PopUpCloseRadButton.Text = "Ok"
            LoadTreeView()
        End If
    End Sub
    Private Sub EditReportTabStrip_TabClick(sender As Object, e As RadTabStripEventArgs) Handles EditReportTabStrip.TabClick
        EditProcedure()
    End Sub

    Public Sub PrintNodeClick(node As RadTreeNode)
        NodeClick(node)
        'PrevProcSummaryTabStrip.SelectedIndex = 2
        'PrevProcSummaryTabStrip.FindTabByText("Print").Selected = True
        'PrevProcSummaryTabStrip.FindTabByText("Print").PageView.Selected = True
        'PrevProcSummaryTabStrip.Tabs.Item(2).Selected = True
        'RMPPrevProcs.SelectedIndex = 2
        'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "da", "SelectPrintTab();", True)
    End Sub
    Sub SetNewProcedureFromOrderComms(intOrderCommOrderId As Integer)
        Try
            Dim intPatientId As Integer
            Dim OrderCommsBL As New OrderCommsBL

            Dim dsData As New DataSet
            dsData = OrderCommsBL.GetOrderCommsDetails(intOrderCommOrderId)

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ProductTypeId")) Then
                If Convert.ToInt32(dsData.Tables(0).Rows(0)("ProductTypeId")) > 0 And Convert.ToInt32(dsData.Tables(0).Rows(0)("ProductTypeId")) < 4 Then
                    ProductRadioButtonList.SelectedValue = Convert.ToInt32(dsData.Tables(0).Rows(0)("ProductTypeId"))

                    ProductRadioButtonList_SelectedIndexChanged(Me, New EventArgs)

                End If
            End If

            'Need to treat - Broncoscopy procedure type here.

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ProcedureTypeId")) Then
                ProcTypeRadComboBox.SelectedValue = Convert.ToInt32(dsData.Tables(0).Rows(0)("ProcedureTypeId"))
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantID")) Then
                SelectReferralConsultantComboByConsultantID(Convert.ToInt32(dsData.Tables(0).Rows(0)("ReferralConsultantID")))
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantSpecialty")) Then
                SpecialityRadComboBox.SelectedValue = Convert.ToInt32(dsData.Tables(0).Rows(0)("ReferralConsultantSpecialty"))
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralHospitalID")) Then
                HospitalComboBox.SelectedValue = Convert.ToInt32(dsData.Tables(0).Rows(0)("ReferralHospitalID"))
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("OrdersPriorityId")) Then

            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderSourceListNo")) Then

            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in DisplayOrderCommsDetailsView()", ex)
        End Try
    End Sub
    Sub SelectReferralConsultantComboByConsultantID(intConsultantID As Integer)
        Dim intCounter As Integer = 0
        intCounter = ConsultantComboBox.Items.Count

        If intCounter > 0 Then
            For i As Integer = 0 To intCounter - 1
                If ConsultantComboBox.Items(i).Value = intConsultantID Then
                    ConsultantComboBox.Items(i).Selected = True
                    ConsultantComboBox.Text = ConsultantComboBox.Items(i).Text
                    ConsultantComboBox.Value = ConsultantComboBox.Items(i).Value
                    Exit For
                End If
            Next
        End If

    End Sub
    Sub DisplayOrderCommsDetailsView(intOrderCommOrderId As Integer)
        Try
            Dim intPatientId As Integer
            Dim OrderCommsBL As New OrderCommsBL

            If Not IsDBNull(Request.QueryString("OrderId")) AndAlso Request.QueryString("OrderId") <> "" Then
                intOrderCommOrderId = CInt(Request.QueryString("OrderId"))
            End If

            Dim dsData As New DataSet
            dsData = OrderCommsBL.GetOrderCommsDetails(intOrderCommOrderId)

            lblOrderNo.Text = intOrderCommOrderId.ToString()

            Dim strForeName As String = ""
            Dim strSurname As String = ""
            Dim strPatientName As String = ""
            Dim strPatAddress As String = ""

            intPatientId = CInt(dsData.Tables(0).Rows(0)("PatientId").ToString())

            If Not IsDBNull(dsData.Tables(0).Rows(0)("Forename")) Then
                strForeName = dsData.Tables(0).Rows(0)("Forename").ToString()
            Else
                strForeName = ""
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("Surname")) Then
                strSurname = dsData.Tables(0).Rows(0)("Surname").ToString()
            Else
                strSurname = ""
            End If

            strPatientName = strForeName + " " + strSurname


            If Not IsDBNull(dsData.Tables(0).Rows(0)("PatientAddressWithBreak")) Then
                strPatAddress = dsData.Tables(0).Rows(0)("PatientAddressWithBreak").ToString()
            Else
                strPatAddress = ""
            End If
            strPatAddress = strPatAddress.Replace("  ", " ").Trim()


#Region "OrderDetails"
            If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderDate")) Then
                lblOrderDate.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("OrderDate").ToString()).ToString("dd MMM yyyy")
            Else
                lblOrderDate.Text = ""
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("DateReceived")) Then
                lblDateReceived.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateReceived").ToString()).ToString("dd MMM yyyy")
            Else
                lblDateReceived.Text = ""
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("DueDate")) Then
                lblDueDate.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DueDate").ToString()).ToString("dd MMM yyyy")
            Else
                lblDueDate.Text = ""
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("DateAdded")) Then
                lblDateRaised.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateAdded").ToString()).ToString("dd MMM yyyy")
            ElseIf Not IsDBNull(dsData.Tables(0).Rows(0)("DateReceived")) Then
                lblDateRaised.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateReceived").ToString()).ToString("dd MMM yyyy")
            Else
                lblDateRaised.Text = ""
            End If


            'MH added on 09 Mar 2022
            If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantName")) Then
                lblReferralConsultantName.Text = dsData.Tables(0).Rows(0)("ReferralConsultantName").ToString()
            Else
                lblReferralConsultantName.Text = ""
            End If
            If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantSpecialtyName")) Then
                lblReferralConsultantSpeciality.Text = dsData.Tables(0).Rows(0)("ReferralConsultantSpecialtyName").ToString()
            Else
                lblReferralConsultantSpeciality.Text = ""
            End If
            If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralHospitalName")) Then
                lblReferralHospitalName.Text = dsData.Tables(0).Rows(0)("ReferralHospitalName").ToString()
            Else
                lblReferralHospitalName.Text = ""
            End If


            If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderNumber")) Then
                lblOrderNo.Text = dsData.Tables(0).Rows(0)("OrderNumber").ToString()
            Else
                lblOrderNo.Text = ""
            End If

            'MH changed from OrderSource to OrderSourceListNo on 24 Feb 2022
            If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderSourceListNo")) Then
                lblOrderSource.Text = dsData.Tables(0).Rows(0)("OrderSourceListNo").ToString()
            Else
                lblOrderSource.Text = ""
            End If


            If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderLocation")) Then
                lblLocation.Text = dsData.Tables(0).Rows(0)("OrderLocation").ToString()
            Else
                lblLocation.Text = ""
            End If


            If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderWard")) Then
                lblWard.Text = dsData.Tables(0).Rows(0)("OrderWard").ToString()
            Else
                lblWard.Text = ""
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("BedLocation")) Then
                lblBed.Text = dsData.Tables(0).Rows(0)("BedLocation").ToString()
            Else
                lblBed.Text = ""
            End If


            If Not IsDBNull(dsData.Tables(0).Rows(0)("ClinicalHistoryNotes")) Then
                lblClinicalHistory.Text = dsData.Tables(0).Rows(0)("ClinicalHistoryNotes").ToString().Replace(vbCrLf.ToString(), "<br />")
            Else
                lblClinicalHistory.Text = ""
            End If


            If Not IsDBNull(dsData.Tables(0).Rows(0)("ProcedureType")) Then
                lblProcedureType.Text = dsData.Tables(0).Rows(0)("ProcedureType").ToString()
            Else
                lblProcedureType.Text = ""
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("Priority")) Then
                lblPriority.Text = dsData.Tables(0).Rows(0)("Priority").ToString()
            Else
                lblPriority.Text = ""
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("Status")) Then
                lblOrderStatus.Text = dsData.Tables(0).Rows(0)("Status").ToString()
            Else
                lblOrderStatus.Text = ""
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("RejectionReason")) Then
                lblRejectionReason.Text = dsData.Tables(0).Rows(0)("RejectionReason").ToString().Replace(vbCrLf.ToString(), "<br />")
            Else
                lblRejectionReason.Text = ""
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("RejectionComments")) Then
                lblRejectionComments.Text = dsData.Tables(0).Rows(0)("RejectionComments").ToString().Replace(vbCrLf.ToString(), "<br />")
            Else
                lblRejectionComments.Text = ""
            End If
#End Region

            rptQuestionsAnswers.DataSource = Nothing
            rptQuestionsAnswers.DataSource = dsData.Tables(1)
            rptQuestionsAnswers.DataBind()

            Dim dsPrevProcHistory As New DataSet
            dsPrevProcHistory = OrderCommsBL.GetPreviousProcedureListByPatientId(Convert.ToInt32(intPatientId))

            rptPrevHistory.DataSource = Nothing
            rptPrevHistory.DataSource = dsPrevProcHistory
            rptPrevHistory.DataBind()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in DisplayOrderCommsDetailsView()", ex)
        End Try
    End Sub

    Sub PreviousProcedureNodeClick(node As RadTreeNode)
        Try
            PreviousProcedurePageView.Selected = True
            EditReportTabStrip.Visible = False
            If Left(node.Text, 9) <> "Procedure" AndAlso Left(node.Text, 19) <> "Previous Procedures" Then
                radPaneReportLeft.Visible = True
                lblProcTitle.Text = node.Text & " Procedure"
                If node.Attributes("ERS") = 1 Then
                    Session(Constants.SESSION_PATIENT_COMBO_ID) = ""
                    SessionHelper.SetProcedureSessions(CInt(node.Attributes("ProcedureId")), False, CInt(node.Attributes("ProcedureType")), CInt(node.Attributes("ColonType")))
                    'PrintPatientCopyCheckBox.Visible = True
                    'PrintHistologyCheckBox.Visible = True
                    '                DirectCast(PrintInitiateUserControl.FindControl("PrintPatientCopyCheckBox"), CheckBox).Enabled = True
                    '                DirectCast(PrintInitiateUserControl.FindControl("PrintLabRequestCheckBox"), CheckBox).Enabled = True
                    If Not CBool(Session("isERSViewer")) And Not CBool(Session("PatDeceased")) Then
                        'If CInt(node.Attributes("isProcedureLocked")) <> 1 AndAlso Not CBool(node.Attributes("Locked")) Then EditReportTabStrip.Visible = True
                        If CInt(node.Attributes("isProcedureLocked")) <> 1 Then EditReportTabStrip.Visible = True
                    End If

                    'VideosListView.Items.Clear()
                    'VideosLightBox.Items.Clear()

                    'VideosListView.Rebind()
                    'LoadVideos()

                    'ImagesListView.Rebind()

                    '                ThumbnailRotator.DataSourceID = "PhotosObjectDataSource"
                    '                ThumbnailRotator.DataBind()
                ElseIf node.Attributes("ERS") = 0 Then
                    'EpisodeNo and PatientComboId are used only for the legacy procedures created by the old UGI system
                    Session(Constants.SESSION_EPISODE_NO) = CInt(node.Attributes("EpisodeNo"))
                    Session(Constants.SESSION_PATIENT_COMBO_ID) = CStr(node.Attributes("PatientComboId"))
                    SessionHelper.SetProcedureSessions(Session(Constants.SESSION_EPISODE_NO), True, CInt(node.Attributes("ProcedureType")), CInt(node.Attributes("ColonType")))
                    'PrintPatientCopyCheckBox.Visible = False
                    'PrintHistologyCheckBox.Visible = False
                    '                DirectCast(PrintInitiateUserControl.FindControl("PrintPatientCopyCheckBox"), CheckBox).Enabled = False
                    '                DirectCast(PrintInitiateUserControl.FindControl("PrintLabRequestCheckBox"), CheckBox).Enabled = False
                ElseIf node.Attributes("ERS") = 2 Then
                    Session("PreviousProcedureId") = CInt(node.Attributes("PreviousProcedureId"))
                    Session(Constants.SESSION_IS_PREVIOUS_PROCEDURE) = True
                    Session(Constants.SESSION_PATIENT_COMBO_ID) = ""
                    SessionHelper.SetProcedureSessions(Session("PreviousProcedureId"), False, CInt(node.Attributes("ProcedureType")), CInt(node.Attributes("ColonType")), True)
                End If
                'Diagram to display on report
                'Dim diagram As UserControl = DirectCast(Page.LoadControl("~/UserControls/diagram.ascx?ProcedureId=0&EpisodeNo=66"), UserControl)
                'diagram.ID = "SchDiagram"
                'DiagramDiv.Controls.Add(diagram)
                If node.Attributes("ERS") <> 2 Then
                    Dim myDiagram As UserControls_diagram = DirectCast(Page.LoadControl("~/UserControls/diagram.ascx"), UserControls_diagram)
                    myDiagram.ProcedureId = CInt(node.Attributes("ProcedureId"))
                    myDiagram.EpisodeNo = CInt(node.Attributes("EpisodeNo"))
                    myDiagram.ProcedureTypeId = CInt(node.Attributes("ProcedureType"))
                    myDiagram.DiagramNumber = CInt(node.Attributes("DiagramNumber"))
                    myDiagram.ColonType = CInt(node.Attributes("ColonType"))
                    DiagramDiv.Controls.Add(myDiagram)

                    InitEpisodeDetails(node.Text, CBool(node.Attributes("ERS")), node.Attributes("ProcedureType"), CInt(node.Attributes("ColonType")))
                Else
                    '********************* TO DO **********************
                    'DisplayPDF(CInt(node.Attributes("ProcedureId")))
                    RPVPDFView.ContentUrl = "~/Products/Common/DisplayPDF.aspx?ProcedureId=" + node.Attributes("PreviousProcedureId")
                    RPVPDFView.Height = 700
                    'PrevProcSummaryTabStrip.Tabs(5).Visible = True
                    'PrevProcSummaryTabStrip.Tabs.Item(5).Selected = True

                    PrevProcSummaryTabStrip.FindTabByText("Other System Procedure").Selected = True
                    PrevProcSummaryTabStrip.FindTabByText("Other System Procedure").PageView.Selected = True
                End If
            Else
                'radPaneReportLeft.Visible = False
                DisplayMessage(node)
            End If

            '        PrintInitiateUserControl.LoadPrintInitiatePage()

            'If Session("PKUserId") IsNot Nothing Then
            '    If Not CBool(Session("isERSViewer")) Then
            '        Dim iAccessLevel As Integer = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "products_common_printoptions_aspx")
            '        If iAccessLevel <> 0 Then
            '            DirectCast(PrintInitiateUserControl.FindControl("ConfigureButton"), RadButton).Enabled = True
            '        Else
            '            DirectCast(PrintInitiateUserControl.FindControl("ConfigureButton"), RadButton).Enabled = False
            '        End If

            '    End If
            'End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("In PatientView.ascx.vb->PreviousProcedureNodeClick()", ex)
        End Try
    End Sub
    Sub OrderCommsChildNodeClick(node As RadTreeNode)
        ViewOrderCommsPageView.Selected = True
        node.Selected = True
        DisplayOrderCommsDetailsView(node.Attributes("OrderCommsOrderId"))
    End Sub
    Sub NodeClick(node As RadTreeNode)
        IsNewPreAssess.Value = "false"
        IsNewNurses.Value = "false"
        If Convert.ToBoolean(node.Attributes("OrderCommsChild")) Then
            OrderCommsChildNodeClick(node)
        ElseIf Convert.ToInt32(node.Attributes("PreAssessmentId")) > 0 Then
            If node.Text <> "New Pre Assessment" Then

                preAssessBtnDiv.Style.Add("display", "none")
            Else
                IsNewPreAssess.Value = "true"
                preAssessBtnDiv.Style.Add("display", "block")
            End If

            EditPreassessment(node)
        ElseIf Convert.ToInt32(node.Attributes("NurseModuleId")) > 0 Then
            If node.Text <> "New Nursing Module" Then

                NurseCreatedDiv.Style.Add("display", "none")
            Else
                IsNewNurses.Value = "true"
                NurseCreatedDiv.Style.Add("display", "block")
            End If

            EditNurseModule(node)
        Else

            PreviousProcedureNodeClick(node)
        End If

    End Sub
    Sub EditPreassessment(node As RadTreeNode)
        PreAssessmentTitle.InnerHtml = "<b id='TitleText'>Update Pre Assessment </b>&nbsp;&nbsp;"
        Session(Constants.SESSION_PRE_ASSESSMENT_Id) = CInt(node.Attributes("PreAssessmentId"))
        Session(Constants.SESSION_PROCEDURE_TYPES) = node.Attributes("ProcedureTypes")
        PreAssessmentHiddenField.Value = CInt(node.Attributes("PreAssessmentId"))
        Dim dateTime As DateTime = node.Attributes("PreAssessmentDate")
        If Not String.IsNullOrEmpty(dateTime) Then
            ProcedureStartDateRadTimeInput.SelectedDate = dateTime.Parse(dateTime)
        End If

        If Not String.IsNullOrEmpty(dateTime) Then
            ProcedureStartRadTimePicker.SelectedTime = dateTime.TimeOfDay
        End If
        GetPreassessmentProcedure()
        BindQuestions()
        NewPreassessmentProcedurePageView.Selected = True
        ClearPreassessmentSession(True)
    End Sub
    Sub deletePreassessment(node As RadTreeNode)
        Dim preId = CInt(node.Attributes("PreAssessmentId"))

        If preId > 0 Then
            Dim da As New OtherData
            Dim isDeleted = da.DeletePreAssessmentAndComorbidity(preId)
            If CInt(isDeleted) > 0 Then
                LoadTreeView()
            End If
        End If

    End Sub
    Sub deleteNurseModule(node As RadTreeNode)
        Dim nurseId = CInt(node.Attributes("NurseModuleId"))

        If nurseId > 0 Then
            Dim da As New OtherData
            Dim isDeleted = da.DeleteNurseModule(nurseId)
            If CInt(isDeleted) > 0 Then
                LoadTreeView()
            End If
        End If

    End Sub
    Sub EditNurseModule(node As RadTreeNode)
        NurseCreatedDiv.Style.Add("display", "none")
        nurseModuleTitle.InnerHtml = "<b id='TitleText'>Update Nursing Module </b>&nbsp;&nbsp;"
        Session(Constants.SESSION_Nurse_Module_Id) = CInt(node.Attributes("NurseModuleId"))
        Session(Constants.SESSION_PROCEDURE_TYPES) = node.Attributes("ProcedureTypes")
        NurseModuleHiddenField.Value = CInt(node.Attributes("NurseModuleId"))
        Dim dateTime As DateTime = node.Attributes("NurseModuleDate")
        If Not String.IsNullOrEmpty(dateTime) Then
            NurseRadDateInput.SelectedDate = dateTime.Parse(dateTime.Date)
        End If

        If Not String.IsNullOrEmpty(dateTime) Then
            NurseRadTimePicker.SelectedTime = New TimeSpan(dateTime.TimeOfDay.Hours, 0, 0)
        End If
        GetNurseModuleProcedure()
        BindNurseModuleQuestions()
        NewNurseModulePageView.Selected = True
        Session(Constants.SESSION_PROCEDURE_ID) = Nothing
        Session(Constants.SESSION_PRE_ASSESSMENT_Id) = Nothing
    End Sub
    Protected Sub LoadConsultantDDL()
        'Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ConsultantComboBox, ""}}, DataAdapter.GetConsultantsLst("", "", 0), "FullName", "ConsultantID")

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ReferrerTypeComboBox, ""}}, DataAdapter.GetReferralOptions(0), "Description", "UniqueId")
        ReferrerTypeComboBox.Items.Insert(0, New RadComboBoxItem("", 0))


        With ConsultantComboBox
            .Items.Clear()
            .DataSource = DataAdapter.GetConsultantsLst("", "", 0)
            .DataBind()
        End With

        'ConsultantComboBox.Items.Insert(0, New RadComboBoxItem(""))
        'ConsultantComboBox.Items.Insert(1, New RadComboBoxItem() With {
        '               .Text = "Add new",
        '               .Value = -55,
        '               .ImageUrl = "~/images/icons/add.png",
        '               .CssClass = "comboNewItem"
        '               })

        'ConsultantComboBox.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewConsultantPopUp(" & ConsultantComboBox.ClientID & "); } else { window.parent.AddNewConsultantPopUp(" & ConsultantComboBox.ClientID & ");" & " }")

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ServiceProviderRadComboBox, ""}}, DataAdapter.GetProviderOrganisations, "Description", "UniqueId")
        ServiceProviderRadComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
        ServiceProviderRadComboBox.SelectedIndex = ServiceProviderRadComboBox.FindItemIndexByText("Own Trust")
        'Added by tony tfs-4175
        ListTypeComboBox.SelectedIndex = ListTypeComboBox.FindItemIndexByText("Service List")

    End Sub
    Protected Sub LoadComboBoxes()
        Dim listTextField As String = "ListItemText"
        Dim listValueField As String = "ListItemNo"
        Dim staffTextField As String = "UserFullName"
        Dim staffValueField As String = "UserId"

        'Added by rony tfs-3489
        CategoryRadComboBox.Items.Clear()
        Dim dt = DataAdapter.LoadProcedureCategories()
        For Each row As DataRow In dt.Rows
            Dim itemCategory As New RadComboBoxItem()
            itemCategory.Text = row("Description").ToString()
            itemCategory.ImageUrl = row("Icon").ToString()
            itemCategory.Value = row("UniqueId").ToString()
            CategoryRadComboBox.Items.Add(itemCategory)
        Next

        PatientTypeRadioButtonList.DataSource = DataAdapter.LoadProviders()
        PatientTypeRadioButtonList.DataTextField = "Description"
        PatientTypeRadioButtonList.DataValueField = "UniqueId"
        PatientTypeRadioButtonList.DataBind()
        '4064
        PatientConsentRadComboBox.DataSource = DataAdapter.GetList("Patient_Consent")
        PatientConsentRadComboBox.DataTextField = listTextField
        PatientConsentRadComboBox.DataValueField = listValueField
        PatientConsentRadComboBox.DataBind()
        '4064
        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                {ListTypeComboBox, "List Type"},
                {Endo1RoleComboBox, "Endoscopist1 Role"},
                {Endo2RoleComboBox, "Endoscopist2 Role"}
          })

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalComboBox, ""}}, DataAdapter.GetHospitalsLst(String.Empty, 0), "HospitalName", "HospitalID")
        HospitalComboBox.Items.Insert(0, New RadComboBoxItem(""))

        LoadConsultantDDL()
        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{SpecialityRadComboBox, ""}}, DataAdapter.GetSpeciality, "GroupName", "GroupID")
        SpecialityRadComboBox.Items.Insert(0, New RadComboBoxItem(""))

        If HospitalComboBox.Items.Count > 14 Then HospitalComboBox.Height = 300
        If ConsultantComboBox.Items.Count > 14 Then ConsultantComboBox.Height = 300
        If SpecialityRadComboBox.Items.Count > 14 Then SpecialityRadComboBox.Height = 300

        Utilities.LoadRadioButtonList(PatStatusRadioButtonList, DataAdapter.GetPatientStatuses(), listTextField, listValueField)
        LoadWardsComboBox()

        LoadConsultantByType(ListConsultantComboBox, Staff.ListConsultant)
        LoadConsultantByType(Endo1ComboBox, Staff.EndoScopist1)
        LoadConsultantByType(Endo2ComboBox, Staff.EndoScopist2)
        LoadConsultantByType(Nurse1ComboBox, Staff.Nurse1)
        LoadConsultantByType(Nurse2ComboBox, Staff.Nurse2)
        LoadConsultantByType(Nurse3ComboBox, Staff.Nurse3)
        LoadConsultantByType(Nurse4ComboBox, Staff.Nurse4)

        LoadDefaultStaffList()

        Dim OBda As New Options
        Dim dtSys As DataTable = OBda.GetSystemSettings()
        If dtSys.Rows.Count > 0 Then
            If CInt(dtSys.Rows(0)("DefaultPatientStatus")) > 0 Then
                Dim patientStatus As Integer = CInt(dtSys.Rows(0)("DefaultPatientStatus"))
                PatStatusRadioButtonList.SelectedValue = patientStatus
                PatientWardCell1.Attributes("style") = IIf(patientStatus = 1, "display: block;", "display: none;")
            End If
            If CInt(dtSys.Rows(0)("DefaultPatientType")) > 0 Then
                PatientTypeRadioButtonList.SelectedValue = CInt(dtSys.Rows(0)("DefaultPatientType"))
            End If
            If CInt(dtSys.Rows(0)("DefaultWard")) > 0 Then
                WardComboBox.SelectedValue = CInt(dtSys.Rows(0)("DefaultWard"))
            End If
        End If

        If NewProcedurePageView.Selected And CInt(Session(Constants.SESSION_PATIENT_WORKLIST_ID)) > 0 Then 'and patient in worklist between now and set max days...
            'prepopulate page controls
            Dim dtWorklistEntry = DataAdapter.GetWorklistRecord(CInt(Session(Constants.SESSION_PATIENT_WORKLIST_ID)), CInt(Session("OperatingHospitalId")))
            If dtWorklistEntry.Rows.Count > 0 Then
                Dim dr As DataRow
                If CInt(Session(Constants.SESSION_WORKLIST_PROCEDURE_TYPE_ID)) > 0 Then
                    dr = dtWorklistEntry.AsEnumerable.Where(Function(x) x("ProcedureTypeId") = CInt(Session(Constants.SESSION_WORKLIST_PROCEDURE_TYPE_ID))).CopyToDataTable.Rows(0)
                Else
                    dr = dtWorklistEntry.Rows(0)
                End If
                If Not dr.IsNull("ProcedureType") Then
                    If CInt(dr("ProcedureTypeId")) <= 9 Then
                        ProcTypeRadComboBox.SelectedValue = CInt(dr("ProcedureTypeId"))
                    End If
                End If
                If Not dr.IsNull("EndoscopistId") Then
                    Endo1ComboBox.SelectedValue = CInt(dr("EndoscopistId"))
                    'load GMC
                    Dim GMC = Products_Default.GetGMCCode(CInt(dr("EndoscopistId")))
                    If String.IsNullOrWhiteSpace(GMC) Then
                        Endo1GMCHiddenField.Value = ""
                    Else
                        Endo1GMCHiddenField.Value = GMC
                    End If
                End If

                If Not dr.IsNull("Points") Then
                    ProcedurePointsRadNumericTextBox.Value = CDec(dr("Points"))
                End If
            End If

        End If

    End Sub
    Protected Sub CheckedProcedureTypesFromSession(ByVal type As Integer)

        Dim idsToCheck As String = Session(Constants.SESSION_PROCEDURE_TYPES)
        Dim idArray As String() = idsToCheck.Split(","c)
        If type = 1 Then

            For Each item As RadComboBoxItem In PreAssessmentProcedureTypeRadComboBox.Items
                If idArray.Contains(item.Value) Then
                    item.Checked = True
                End If
            Next
        Else
            For Each item As RadComboBoxItem In NurseModuleProcedureTypeRadComboBox.Items
                If idArray.Contains(item.Value) Then
                    item.Checked = True
                End If
            Next
        End If
    End Sub
    ''' <summary>
    ''' This will set a value in the Dropdown List box- either an Existing value form Table or set Empty!
    ''' </summary>
    ''' <param name="targetDropdown">RadComboBox.Dropdown List Box</param>
    ''' <param name="sourceColumn">Table Field name</param>
    ''' <remarks>Shawkat; 2017-07-07</remarks>
    Private Sub DropBoxSetSelectedOrDefaultValue(targetDropdown As RadComboBox, Optional ByVal sourceColumn As String = Nothing)
        Try
            Dim itemToSelect As RadComboBoxItem
            itemToSelect = targetDropdown.FindItemByValue(CStr(IIf(String.IsNullOrEmpty(sourceColumn), Nothing, sourceColumn)))
            If itemToSelect IsNot Nothing Then
                itemToSelect.Selected = True
            Else 'when String.IsNullOrEmpty
                targetDropdown.Items.Insert(0, New RadComboBoxItem("")) '//## making it Empty!
                targetDropdown.Items(0).Selected = True
            End If

        Catch ex As Exception

        End Try

    End Sub

    Private Sub DropBoxSetSelectedOrDefaultValueByText(targetDropdown As RadComboBox, Optional ByVal sourceColumn As String = Nothing, Optional setEmpty As Boolean = True)
        Try
            Dim itemToSelect As RadComboBoxItem
            itemToSelect = targetDropdown.FindItemByText(CStr(IIf(String.IsNullOrEmpty(sourceColumn), Nothing, sourceColumn)))
            If itemToSelect IsNot Nothing Then
                itemToSelect.Selected = True
            Else 'when String.IsNullOrEmpty
                If setEmpty Then
                    targetDropdown.Items.Insert(0, New RadComboBoxItem("")) '//## making it Empty!
                    targetDropdown.Items(0).Selected = True
                End If
            End If

        Catch ex As Exception

        End Try

    End Sub

    ''' <summary>
    ''' This will load the specific type of Consultant in a Specific DropDown box!
    ''' Using the LAMBDA- benefit is- read once all the Consultant and filter them later as per the Dropdown type
    ''' </summary>
    ''' <param name="dropDownBox">dropDownBox As RadComboBox</param>
    ''' <param name="consultantType">ie: Staff.ListConsultant</param>
    ''' <remarks></remarks>
    Private Sub LoadConsultantByType(ByVal dropDownBox As RadComboBox, ByVal consultantType As Staff)
        dropDownBox.ClearSelection()
        dropDownBox.Items.Clear()
        dropDownBox.DataTextField = "Consultant"
        dropDownBox.DataValueField = "UserId"

        Try
            dropDownBox.DataSource = BusinessLogic.FilterConsultantByType(consultantType)
            dropDownBox.DataBind()
            dropDownBox.Items.Insert(0, New RadComboBoxItem("")) '//## making it Empty!
            dropDownBox.SelectedIndex = 0
            If dropDownBox.Items.Count > 14 Then dropDownBox.Height = 300
        Catch ex As Exception
            dropDownBox.Items.Add("Load Failed")
        End Try

    End Sub

    Protected Sub LoadWardsComboBox(Optional ByVal newlyAddedItem As String = "")
        Dim dtWards As DataTable = DataAdapter.GetPatientWards()
        WardComboBox.Items.Clear()
        WardComboBox.Items.Add(New RadComboBoxItem(""))
        If dtWards.Rows.Count > 0 Then
            Dim r As DataRow
            For Each r In dtWards.Rows
                Dim item As RadComboBoxItem = New RadComboBoxItem(r("WardDescription"), r("WardId"))
                WardComboBox.Items.Add(item)
            Next
            WardComboBox.SelectedIndex = 0
        End If

        'Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{WardComboBox, ""}}, dtWards)
        If WardComboBox.Items.Count > 14 Then WardComboBox.Height = 300
        'Utilities.LoadDropdown(WardComboBox, dtWards, "ListItemText", "ListItemNo", "")
        If Not String.IsNullOrEmpty(newlyAddedItem) Then
            WardComboBox.FindItemByText(newlyAddedItem).Selected = True
        End If
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "closewindow", "closeAddWardWindow();", True)

    End Sub

    Protected Sub LoadImagePortComboBox()
        'Dim dtImagePorts As DataTable = DataAdapter.GetAvailableImagePorts(CInt(Session("OperatingHospitalID")))
        'Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{WardComboBox, ""}}, dtWards)
        'If WardComboBox.Items.Count > 14 Then WardComboBox.Height = 300
        ''Utilities.LoadDropdown(WardComboBox, dtWards, "ListItemText", "ListItemNo", "")
        'If Not String.IsNullOrEmpty(newlyAddedItem) Then
        '    WardComboBox.FindItemByText(newlyAddedItem).Selected = True
        'End If
        'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "closewindow", "closeAddWardWindow();", True)

    End Sub

    Public Sub LoadPatientPage()
        Try
            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
            Else
                MessageBox.Show("Your session expired, please start procedure again..")
                Response.Redirect("~/Products/Default.aspx", False)
            End If

            LoadPatientInfo()
            LoadTreeView()
            'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "bindControlEvents", "loadImagePorts();", True)
            'Load imageports for the room
            ImagePortComboBox.Items.Clear()
            If ConfigurationManager.AppSettings("SetDefaultImageport").ToLower <> "true" Then
                ImagePortComboBox.Items.Add(New RadComboBoxItem("", -1))
            End If
            Dim da As New DataAccess()
            Dim dt As DataTable = da.GetAvailableImagePortsForRoom(Session("RoomId"))
            If dt.Rows.Count > 0 Then
                Dim r As DataRow
                For Each r In dt.Rows
                    Dim item As RadComboBoxItem = New RadComboBoxItem(r("FriendlyName"), r("ImagePortId"))
                    ImagePortComboBox.Items.Add(item)
                Next
                ImagePortComboBox.SelectedIndex = 0
            End If

            'LoadComboBoxes()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error in PatientView.LoadPatientPage().", ex)
        End Try
    End Sub

    Private Sub LoadDefaultStaffList()
        If CBool(Session(Constants.SESSION_STAFF_LIST_SAVE_DEFAULTS)) Then
            SetDefaultCheckBox.Checked = True
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_LISTTYPE_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(ListTypeComboBox, Session(Constants.SESSION_LISTTYPE_TEXT_DEFAULT), False)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_LISTCON_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(ListConsultantComboBox, Session(Constants.SESSION_LISTCON_TEXT_DEFAULT), False)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_LISTCON_GMC_DEFAULT)) Then ListConsultantGMCHiddenField.Value = Session(Constants.SESSION_LISTCON_GMC_DEFAULT)

            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_ENDO1_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(Endo1ComboBox, Session(Constants.SESSION_ENDO1_TEXT_DEFAULT), False)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_ENDO1_GMC_DEFAULT)) Then Endo1GMCHiddenField.Value = Session(Constants.SESSION_ENDO1_GMC_DEFAULT)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_ENDO1ROLE_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(Endo1RoleComboBox, Session(Constants.SESSION_ENDO1ROLE_TEXT_DEFAULT), False)

            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_ENDO2_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(Endo2ComboBox, Session(Constants.SESSION_ENDO2_TEXT_DEFAULT), False)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_ENDO2_GMC_DEFAULT)) Then Endo2GMCHiddenField.Value = Session(Constants.SESSION_ENDO2_GMC_DEFAULT)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_ENDO2ROLE_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(Endo2RoleComboBox, Session(Constants.SESSION_ENDO2ROLE_TEXT_DEFAULT), False)

            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_NURSE1_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(Nurse1ComboBox, Session(Constants.SESSION_NURSE1_TEXT_DEFAULT), False)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_NURSE2_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(Nurse2ComboBox, Session(Constants.SESSION_NURSE2_TEXT_DEFAULT), False)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_NURSE3_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(Nurse3ComboBox, Session(Constants.SESSION_NURSE3_TEXT_DEFAULT), False)
            If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_NURSE4_TEXT_DEFAULT)) Then DropBoxSetSelectedOrDefaultValueByText(Nurse4ComboBox, Session(Constants.SESSION_NURSE4_TEXT_DEFAULT), False)

            If (Endo1ComboBox.SelectedValue <> "" And Endo2ComboBox.SelectedValue <> "") AndAlso
                           (Endo1ComboBox.SelectedValue > 0 And Endo2ComboBox.SelectedValue > 0 And Endo1ComboBox.SelectedValue <> Endo2ComboBox.SelectedValue) Then
                Endoscopist1Label.Text = "TrainER:"
                Endoscopist2Label.Text = "TrainEE:"
            End If
        End If

    End Sub
    Protected Sub InitEpisodeDetails(ByVal sProcType As String, ByVal ers As Boolean, ProcedureType As Integer, ColonType As Integer)
        Dim sProcTable As String = ""
        sProcType = Trim(Mid(sProcType, InStr(sProcType, "-") + 1))

        Select Case sProcType
            Case "Upper GI"
                sProcTable = "Upper GI"
                'diagImage.Height = 250
                'diagImage.Width = 200

            Case "Colonoscopy", "Sigmoidoscopy", "Proctoscopy"
                sProcTable = "Colon"
                'diagImage.Height = 240
                'diagImage.Width = 220

            Case "ERCP"
                sProcTable = "ERCP"
                'diagImage.Height = 240
                'diagImage.Width = 240
            Case "EUS (HPB)", "EUS (OGD)"
                sProcTable = "EUS"
            Case Else
                'diagImage.ImageUrl = ""
        End Select
        GetEpisodeDetails(sProcTable, ProcedureType, ColonType)
        ' If Session("KeyEpiNo") = 

        'Dim xx As String = Session("KeyEpiNo")

        ' diagImage.ResolveUrl("~/Diagram/Diagram.aspx?P=" & sProcTable & "&PatNo=" & Session(Constants.SESSION_PATIENT_COMBO_ID) & "&EpiNo=" & Session("KeyEpiNo"))
        'diagImage.ImageUrl = ""
        'diagImage.ImageUrl = "~/Diagram/Diagram.aspx?P=" & sProcTable & "&PatNo=" & Session(Constants.SESSION_PATIENT_COMBO_ID) & "&EpiNo=" & Session("KeyEpiNo") & "&ResetCache=" & Rnd()
    End Sub

    Private conn As SqlConnection = Nothing
    Dim dss As New DataAccess

    Protected Sub GetEpisodeDetails(sTable As String, ProcedureType As Integer, ColonType As Integer)
        'Dim sTableName As String = sTable & " Procedure"
        'Dim sFieldNames(13) As String
        'Dim sField() As String
        'Dim i As Integer = 0

        ''Left side of report
        'sFieldNames(0) = "LS;;Indications;;PP_Indic;;"
        ''If sTable = "ERCP" Then
        ''sFieldNames(1) = "LS;;Report;;PP2_MainReportBody;;"
        ''Else
        'sFieldNames(1) = "LS;;Report;;PP_MainReportBody;;"
        ''End If
        'sFieldNames(2) = "LS;;Site Data;;PP2_SiteData;;"
        'sFieldNames(3) = "LS;;Diagnoses;;PP_Diagnoses;;"
        'sFieldNames(4) = "LS;;Therapeutic procedures;;PP_Therapies;;"
        'sFieldNames(5) = "LS;;Medication;;PP_Rx;;"
        'sFieldNames(6) = "LS;;Advice/Comments;;PP_AdviceAndComments;;"
        'sFieldNames(7) = "LS;;Follow Up;;PP_Followup;;"

        ''Right side of report
        'sFieldNames(8) = "RS;;Consultant/Endoscopist;;PP_ENDOS;;"
        'sFieldNames(9) = "RS;;Instrument;;PP_Instrument;;"
        'sFieldNames(10) = "RS;;Premedication;;PP_Premed;;"
        'sFieldNames(13) = "RS;;Referring Consultant;;PP_RefCons;;"

        ''This section appears after the diagram
        'sFieldNames(11) = "AD;;Site Legend;;PP_Site_Legend;;"
        'sFieldNames(12) = "AD;;Specimens Taken;;PP_SpecimenTaken;;"

        Try
            'Dim ConnString As [String] = DataAccess.ConnectionStr
            'conn = New SqlConnection(ConnString)
            'conn.Open()

            'Dim cmdString As String = "printreport_select"
            'If ers Then
            '    cmdString = "SELECT * FROM ERS_Procedures WHERE ProcedureId = '" & Session(Constants.SESSION_PROCEDURE_ID) & "'"
            'Else
            '    cmdString = "SELECT * FROM [" & sTableName & "] WHERE [Patient No] = '" & Session(Constants.SESSION_PATIENT_COMBO_ID) & "' AND [Episode No] = " & Session(Constants.SESSION_EPISODE_NO) & ";"
            'End If

            If sTable = "Colon" Then
                Dim ds As New OtherData
                Dim BowelText As String = ds.GetBostonBowelPrepText(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                If Not IsNothing(BowelText) Then
                    lblBowelPrep.Text = BowelText
                    lblBowelPrep.Visible = True
                    lblBowelPrep.Attributes.Add("Style", "display:normal")
                Else
                    lblBowelPrep.Text = ""
                    lblBowelPrep.Visible = True
                    lblBowelPrep.Attributes.Add("Style", "display:none")
                End If
            End If

            'shows NPSA alert message is not empty
            'If Not CBool(Session("isERSViewer")) Then
            '    Dim thera As New Therapeutics
            '    Dim AlertText As String = thera.GetNPSAalert(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            '    If Not IsNothing(AlertText) AndAlso AlertText.Trim <> "" Then
            '        NpsaAlertLabel.InnerText = AlertText
            '        alertDiv.Attributes.Add("style", "display:normal;border:solid;border-color:red;")
            '    Else
            '        alertDiv.Attributes.Add("style", "display:none")
            '    End If
            'End If

            Dim LDataTable As DataTable = dss.GetReport(IIf(IsNothing(Session(Constants.SESSION_PROCEDURE_ID)), 0, Session(Constants.SESSION_PROCEDURE_ID)), "LS", Session(Constants.SESSION_EPISODE_NO), Session(Constants.SESSION_PATIENT_COMBO_ID), ProcedureType, ColonType)
            Dim L_sRpt As String = "<table id='tableLeftHand' runat='server' border='0' cellpadding='0' cellspacing='0' width='460px' >"
            If Not IsNothing(LDataTable) Then
                For Each LRow As DataRow In LDataTable.Rows
                    If Not IsDBNull(LRow(1)) AndAlso Not IsNothing(LRow(1)) AndAlso LRow(1).ToString <> "" Then
                        Dim TextValue As String = Replace(LRow(1), "<BR />" & vbCrLf, "<br />")
                        TextValue = Replace(TextValue, vbCrLf & vbCrLf, "<br />")
                        TextValue = Trim(Replace(TextValue, vbCrLf, "<br />"))
                        If LRow(0) <> "Site Data" Then
                            L_sRpt = L_sRpt & "<tr>"
                            L_sRpt = L_sRpt & "<td class='reportHeader'><b>" & LRow(0) & "</b></td>"
                            L_sRpt = L_sRpt & "</tr>"
                        End If
                        L_sRpt = L_sRpt & "<tr>"
                        L_sRpt = L_sRpt & "<td>" & TextValue & "</td>"
                        L_sRpt = L_sRpt & "</tr>"
                    End If
                Next
                L_sRpt = L_sRpt & "</table>"
                lblLeftRptText.Text = L_sRpt
            End If

            Dim procedureId = IIf(IsNothing(Session(Constants.SESSION_PROCEDURE_ID)), 0, Session(Constants.SESSION_PROCEDURE_ID))
            Dim RDataTable As DataTable = dss.GetReport(procedureId, "RS", Session(Constants.SESSION_EPISODE_NO), Session(Constants.SESSION_PATIENT_COMBO_ID), ProcedureType, ColonType)
            Dim dtPatExtra As DataTable = DataAdapter.GetPrintReport(procedureId, "GPD", Session(Constants.SESSION_EPISODE_NO), Session(Constants.SESSION_PATIENT_COMBO_ID), ProcedureType, ColonType)
            Dim R_sRpt As String = "<table id='tableLeftHand' runat='server' border='0' cellpadding='0' cellspacing='0' width='260px' style=""text-align: right"" >"
            If Not IsNothing(RDataTable) Then
                For Each RRow As DataRow In RDataTable.Rows
                    If Not IsDBNull(RRow(1)) AndAlso Not IsNothing(RRow(1)) AndAlso RRow(1).ToString <> "" Then
                        Dim TextValue1 As String = Trim(Replace(RRow(1), vbCrLf, "<br/>"))
                        If RRow(0).ToString = "Resected Colon" Then
                            If Not IsNothing(TextValue1) And TextValue1 <> "0" Then
                                R_sRpt = R_sRpt & "<tr>"
                                R_sRpt = R_sRpt & "<td class='reportHeader'><b>" & RRow(0) & "</b></td>"
                                R_sRpt = R_sRpt & "</tr>"
                                R_sRpt = R_sRpt & "<tr>"
                                R_sRpt = R_sRpt & "<td>" & dss.GetResectedColonText(CInt(TextValue1)) & "</td>"
                                R_sRpt = R_sRpt & "</tr>"
                            End If
                        Else
                            R_sRpt = R_sRpt & "<tr>"
                            R_sRpt = R_sRpt & "<td class='reportHeader'><b>" & RRow(0) & "</b></td>"
                            R_sRpt = R_sRpt & "</tr>"
                            R_sRpt = R_sRpt & "<tr>"
                            R_sRpt = R_sRpt & "<td>" & TextValue1 & "</td>"
                            R_sRpt = R_sRpt & "</tr>"
                        End If
                    End If
                Next
                R_sRpt = R_sRpt & "</table>"
                lblRightRptText.Text = R_sRpt
            End If

            Dim ADataTable As DataTable = dss.GetReport(IIf(IsNothing(Session(Constants.SESSION_PROCEDURE_ID)), 0, Session(Constants.SESSION_PROCEDURE_ID)), "AD", Session(Constants.SESSION_EPISODE_NO), Session(Constants.SESSION_PATIENT_COMBO_ID), ProcedureType, ColonType)
            Dim A_sRpt As String = "<table id='tableLeftHand' runat='server' border='0' cellpadding='0' cellspacing='0' width='260px' >"

            If Not IsNothing(ADataTable) Then
                For Each ARow As DataRow In ADataTable.Rows
                    If Not IsDBNull(ARow(1)) AndAlso Not IsNothing(ARow(1)) AndAlso ARow(1).ToString <> "" Then
                        Dim TextValue2 As String = Trim(Replace(ARow(1), vbCrLf, "<br />"))
                        A_sRpt = A_sRpt & "<tr>"
                        A_sRpt = A_sRpt & "<td class='reportHeader'><b>" & ARow(0) & "</b></td>"
                        A_sRpt = A_sRpt & "</tr>"
                        A_sRpt = A_sRpt & "<tr>"
                        A_sRpt = A_sRpt & "<td>" & TextValue2 & "</td>"
                        A_sRpt = A_sRpt & "</tr>"

                    End If
                Next
                A_sRpt = A_sRpt & "</table>"
                lblAfterDiagram.Text = A_sRpt
            End If

            'PhotosImageGallery.DataSourceID = "PhotosObjectDataSource" 'enable 3 later
            '            ThumbnailRotator.DataSourceID = "PhotosObjectDataSource"
            '            ThumbnailRotator.DataBind()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred on default page.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
    Private Function GetFieldValue(dtPatExtra As DataTable, nodeName As String) As String
        Dim val As String = "Not Available"
        Dim matches = From r In dtPatExtra.AsEnumerable()
                      Where r.Field(Of String)("NodeName").ToLower = nodeName.ToLower()
                      Select r
        If matches.Count > 0 Then
            If Not IsDBNull(matches(0)("NodeSummary")) Then
                val = CStr(matches(0)("NodeSummary"))
            End If
        End If
        Return val
    End Function
    Protected Sub PhotosObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles PhotosObjectDataSource.Selected
        'PrevProcSummaryTabStrip.Tabs(1).Visible = PhotosImageGallery.Items.Count > 0
        'PrevProcSummaryTabStrip.Tabs(1).Visible = DirectCast(e.ReturnValue, DataTable).Rows.Count > 0
        Dim dt As DataTable = DirectCast(e.ReturnValue, DataTable)

        PrevProcSummaryTabStrip.Tabs(1).Text = "Images"
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            ImagesLinkButton.Visible = True

            ImagesLinkButton.Text = "<img src=""../Images/icons/print.png"" alt=""Print"" />&nbsp;Images (" & dt.Rows.Count & ")"

            PrevProcSummaryTabStrip.Tabs(1).Visible = True

            If ConfigurationManager.AppSettings("IsAzure").ToLower() <> "true" Then
                For Each dr As DataRow In dt.Rows
                    If Not IsDBNull(dr("PhotoUrl")) Then
                        If Not PhotosFolderUri Is Nothing Then
                            If Left(CStr(dr("PhotoUrl")), 10) <> "data:image" Then
                                dr("PhotoUrl") = Path.Combine(PhotosFolderUri, CStr(dr("PhotoUrl"))).Replace("\", "/")
                            End If
                        End If
                    End If
                Next
            End If

        Else
            ImagesLinkButton.Visible = False
            'PrevProcSummaryTabStrip.Tabs(1).Visible = False
            'PrevProcSummaryTabStrip.SelectedIndex = 0
            'RPVGPReport.Selected = True
        End If
    End Sub

    Protected Sub PhotosObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles PhotosObjectDataSource.Selecting
        e.InputParameters("operatingHospitalId") = CInt(Session("OperatingHospitalID"))
        e.InputParameters("procedureId") = CInt(Session(Constants.SESSION_PROCEDURE_ID))
        e.InputParameters("episodeNo") = CInt(Session(Constants.SESSION_EPISODE_NO))
        e.InputParameters("patientComboId") = CStr(Session(Constants.SESSION_PATIENT_COMBO_ID))
        e.InputParameters("ColonType") = CStr(Session(Constants.SESSION_PROCEDURE_COLONTYPE))
    End Sub

    Protected Sub PhotosObjectDataSource_Update(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        e.InputParameters("operatingHospitalId") = CInt(Session("OperatingHospitalID"))
        e.InputParameters("procedureId") = CInt(Session(Constants.SESSION_PROCEDURE_ID))
        e.InputParameters("episodeNo") = CInt(Session(Constants.SESSION_EPISODE_NO))
        e.InputParameters("patientComboId") = CStr(Session(Constants.SESSION_PATIENT_COMBO_ID))
        e.InputParameters("ColonType") = CStr(Session(Constants.SESSION_PROCEDURE_COLONTYPE))
    End Sub

    Protected Sub PrevProcsTreeView_NodeClick(sender As Object, e As RadTreeNodeEventArgs) Handles PrevProcsTreeView.NodeClick
        'PrevProcSummaryTabStrip.Tabs(3).Visible = False
        PathologyResultsLinkButton.Visible = False

        'Session(Constants.SESSION_PROCEDURE_ID) = CInt(e.Node.Attributes("ProcedureId"))

        'MyControl is the Custom User Control with a code behind file
        'Dim diagram As UserControls_diagram = DirectCast(Page.LoadControl("~/UserControls/diagram.ascx"), UserControls_diagram)
        'DiagramDiv.Controls.Add(diagram)
        ' Dim diagram As Unisoft = DirectCast(Page.LoadControl("~/UserControls/diagram.ascx"), Unisoft)
        ' DiagramDiv.Controls.Add(diagram)

        'Dim myControl As MyControl = DirectCast(Page.LoadControl("~/MyControl.ascx"), MyControl)

        'UserControlHolder is a place holder on the aspx page where I want to load the
        'user control to.
        'UserControlHolder.Controls.Add(myControl)

        'PrintGPReportCheckBox.Checked = False
        'PrintPhotosCheckBox.Checked = False
        'PrintPatientCopyCheckBox.Checked = False
        'PrintHistologyCheckBox.Checked = False

        If Not IsNothing(Session("ProcedureFromOrderComms")) Then
            Session("ProcedureFromOrderComms") = Nothing
        End If
        If Not IsNothing(Session("OrderCommsOrderId")) Then
            Session("OrderCommsOrderId") = Nothing
        End If
        If Not IsNothing(lblOCProcedure) Then
            lblOCProcedure.Text = ""
        End If

        Select Case e.Node.Text
            Case "New Pre Assessment"
                Dim today = DateTime.UtcNow
                ProcedureStartDateRadTimeInput.SelectedDate = today
                ProcedureStartRadTimePicker.SelectedTime = today.TimeOfDay
                PreAssessmentTitle.InnerHtml = "<b id='TitleText'>New Pre Assessment </b>&nbsp;&nbsp;"
                DisplayMessage(e.Node)
            Case "Pre Assessment"
                ProcedureStartDateRadTimeInput.SelectedDate = Today
                ProcedureStartRadTimePicker.SelectedTime = Today.TimeOfDay
                nurseModuleTitle.InnerHtml = "<b id='TitleText'>Pre Assessment </b>&nbsp;&nbsp;"
                DisplayMessage(e.Node)
            Case "New Procedure"
                DisplayMessage(e.Node)

                'Session("HelpTooltipElementId") = CreateProcedureButton.ClientID
                'Session("HelpMessage") = "Fill the procedure details and click on Create Procedure button to start a new procedure."
            Case "Nursing Module"
                NurseRadDateInput.SelectedDate = Today
                NurseRadTimePicker.SelectedTime = Today.TimeOfDay
                nurseModuleTitle.InnerHtml = "<b id='TitleText'>Nursing Module </b>&nbsp;&nbsp;"
                DisplayMessage(e.Node)
            Case "New Nursing Module"
                NurseRadDateInput.SelectedDate = Today
                NurseRadTimePicker.SelectedTime = Today.TimeOfDay
                nurseModuleTitle.InnerHtml = "<b id='TitleText'>New Nursing Module </b>&nbsp;&nbsp;"
                DisplayMessage(e.Node)
            Case "Orders"

            Case Else
                PrevProcSummaryTabStrip.Tabs(0).Visible = True
                PrevProcSummaryTabStrip.Tabs.Item(0).Selected = True
                PrevProcSummaryTabStrip.FindTabByText("Report").Selected = True
                PrevProcSummaryTabStrip.FindTabByText("Report").PageView.Selected = True
                NodeClick(e.Node)

                'Session("HelpTooltipElementId") = PrevProcSummaryTabStrip.ClientID
                'Session("HelpMessage") = "Click on Print tab to choose Print options and print various reports."

                'PreviousProcedurePageView.Selected = True
                'If Left(e.Node.Text, 19) <> "Previous Procedures" Then
                '    radPaneReportLeft.Visible = True
                '    lblProcTitle.Text = e.Node.Text & " Procedure"

                '    If CBool(e.Node.Attributes("ERS")) Then
                '        Session(Constants.SESSION_PATIENT_COMBO_ID) = ""
                '        SessionHelper.SetProcedureSessions(CInt(e.Node.Attributes("ProcedureId")), False)

                '        'PrintPatientCopyCheckBox.Visible = True
                '        'PrintHistologyCheckBox.Visible = True
                '    Else
                '        'EpisodeNo and PatientComboId are used only for the legacy procedures created by the old UGI system
                '        Session("KeyEpiNo") = CInt(e.Node.Attributes("EpisodeNo"))
                '        Session(Constants.SESSION_PATIENT_COMBO_ID) = CStr(e.Node.Attributes("PatientComboId"))
                '        SessionHelper.SetProcedureSessions(Session("KeyEpiNo"), True)

                '        'PrintPatientCopyCheckBox.Visible = False
                '        'PrintHistologyCheckBox.Visible = False
                '    End If
                '    'Diagram to display on report
                '    'Dim diagram As UserControl = DirectCast(Page.LoadControl("~/UserControls/diagram.ascx?ProcedureId=0&EpisodeNo=66"), UserControl)
                '    'diagram.ID = "SchDiagram"
                '    'DiagramDiv.Controls.Add(diagram)
                '    Dim myDiagram As UserControls_diagram = DirectCast(Page.LoadControl("~/UserControls/diagram.ascx"), UserControls_diagram)
                '    myDiagram.ProcedureId = CInt(e.Node.Attributes("ProcedureId"))
                '    myDiagram.EpisodeNo = CInt(e.Node.Attributes("EpisodeNo"))
                '    myDiagram.ProcedureTypeId = CInt(e.Node.Attributes("ProcedureType"))
                '    DiagramDiv.Controls.Add(myDiagram)

                '    InitEpisodeDetails(e.Node.Text, CBool(e.Node.Attributes("ERS")))
                'Else
                '    radPaneReportLeft.Visible = False
                'End If
        End Select



        'Dim img As New System.Web.UI.WebControls.Image()
        'img.ImageUrl = "~/Images/colon-black.svg"
        'img.ID = "DiagramImage"



        'Working Code''''''''''''
        '''''''''''''


        'diagram.Attributes("class") = "diagram"
        'DiagramDiv.Controls.Add(img)



        'Dim diagram As UserControls_diagram = DirectCast(Page.LoadControl("~/UserControls/diagram.ascx"), UserControls_diagram)
        'subDiagramDiv.Controls.Add(diagram)
        'Dim DiagramDiv As HtmlGenericControl = DirectCast(radPaneReportRight.FindControl("DiagramDiv"), HtmlGenericControl)


        'Page.ClientScript.RegisterStartupScript(Me.GetType(), "CallMyFunction", "alert('Hi');", True)
        'Dim scriptstring As String = "LoadBasics();LoadExistingPatient();"
        'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "radalert", scriptstring, True)
    End Sub

    Protected Sub SpecialityChanged()
        If SpecialityRadComboBox.SelectedValue = "" Then

            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{SpecialityRadComboBox, ""}}, DataAdapter.GetSpeciality(), "GroupName", "GroupID")
            LoadConsultantDDL()

            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalComboBox, ""}}, DataAdapter.GetReferralHospitals(""), "HospitalName", "HospitalID")

            SpecialityRadComboBox.Items.Insert(0, New RadComboBoxItem(""))
            ' ConsultantComboBox.Items.Insert(0, New RadComboBoxItem(""))
            HospitalComboBox.Items.Insert(0, New RadComboBoxItem(""))


            'Utilities.LoadDropdown(SpecialityRadComboBox, DataAdapter.GetSpeciality, "GroupName", "GroupID", "")
            'Utilities.LoadDropdown(ConsultantComboBox, DataAdapter.GetConsultantsLst("", "", 0), "Name", "ConsultantID", "")
            'Utilities.LoadDropdown(HospitalComboBox, DataAdapter.GetReferralHospitals(""), "HospitalName", "HospitalID", "")
        Else
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalComboBox, ""}}, DataAdapter.GetReferralHospitals(""), "HospitalName", "HospitalID")
            HospitalComboBox.Items.Insert(0, New RadComboBoxItem(""))
            LoadConsultantDDL()

            'ConsultantComboBox.Items.Insert(0, New RadComboBoxItem(""))
            'If ConsultantComboBox.Items.Count = 2 Then
            '    ConsultantComboBox.SelectedIndex = 1
            'End If
            'Utilities.LoadDropdown(ConsultantComboBox, DataAdapter.GetConsultants(SpecialityRadComboBox.SelectedValue), "Name", "ConsultantID", "")
        End If

    End Sub

    Protected Sub HospitalChanged()
        If HospitalComboBox.SelectedValue = "" Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalComboBox, ""}}, DataAdapter.GetReferralHospitals(""), "HospitalName", "HospitalID")
            HospitalComboBox.Items.Insert(0, New RadComboBoxItem(""))
            ' Utilities.LoadDropdown(HospitalComboBox, DataAdapter.GetReferralHospitals(""), "HospitalName", "HospitalID", "")
        End If
    End Sub

    Protected Sub ConsultantChanged()
        'If ConsultantComboBox.SelectedValue = "" Or ConsultantComboBox.SelectedValue = "-55" Then
        '    LoadConsultantDDL()

        '    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{SpecialityRadComboBox, ""}}, DataAdapter.GetSpeciality, "GroupName", "GroupID")
        '    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalComboBox, ""}}, DataAdapter.GetReferralHospitals(""), "HospitalName", "HospitalID")

        '    SpecialityRadComboBox.Items.Insert(0, New RadComboBoxItem(""))
        '    ConsultantComboBox.Items.Insert(0, New RadComboBoxItem(""))
        '    HospitalComboBox.Items.Insert(0, New RadComboBoxItem(""))
        '    'Utilities.LoadDropdown(ConsultantComboBox, DataAdapter.GetConsultantsLst("", "", 0), "Name", "ConsultantID", "")
        '    'Utilities.LoadDropdown(SpecialityRadComboBox, DataAdapter.GetSpeciality, "GroupName", "GroupID", "")
        '    'Utilities.LoadDropdown(HospitalComboBox, DataAdapter.GetReferralHospitals(""), "HospitalName", "HospitalID", "")
        'Else
        '    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalComboBox, ""}}, DataAdapter.GetReferralHospitals(ConsultantComboBox.SelectedValue), "HospitalName", "HospitalID")
        '    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{SpecialityRadComboBox, ""}}, DataAdapter.GetSpeciality, "GroupName", "GroupID")

        '    SpecialityRadComboBox.Items.Insert(0, New RadComboBoxItem(""))
        '    HospitalComboBox.Items.Insert(0, New RadComboBoxItem(""))
        '    'Utilities.LoadDropdown(HospitalComboBox, DataAdapter.GetReferralHospitals(ConsultantComboBox.SelectedValue), "HospitalName", "HospitalID", Nothing)
        '    'Utilities.LoadDropdown(SpecialityRadComboBox, DataAdapter.GetSpeciality, "GroupName", "GroupID", "")
        '    SpecialityRadComboBox.SelectedValue = DataAdapter.GetSpeciality(ConsultantComboBox.SelectedValue)
        '    If HospitalComboBox.Items.Count = 2 Then
        '        HospitalComboBox.SelectedIndex = 1
        '        HospitalComboBox.Enabled = False
        '        HospitalComboBox.ShowToggleImage = False
        '    Else
        '        HospitalComboBox.Enabled = True
        '        HospitalComboBox.ShowToggleImage = True
        '    End If
        '    hasConsultantChanged = True 
        '    ' HospitalComboBox.SelectedValue = DataAdapter.GetReferralHospitals(ConsultantComboBox.SelectedValue)
        'End If
    End Sub

    Protected Sub CreateProcedureButton_Click(sender As Object, e As System.EventArgs) Handles CreateProcedureButton.Click
        Try
            'Check if the page is valid just in case the client validations haven't worked
            'The client validation returns valid=true even if the page is not valid, in case of partial (ajax) post backs
            'If Page.IsValid Then
            'If CInt(Session("PatientId")) = 0 Then
            '    If CInt(PatientIdHiddenField.Value) > 0 Then
            '        Session("PatientId") = PatientIdHiddenField.Value
            '    End If
            'End If

            Session(Constants.SESSION_PROCEDURE_TYPE) = ProcTypeRadComboBox.SelectedValue
            Session(Constants.SESSION_PAGE_INDEX) = ""

            SetStaffSessions()
            Dim iPatientConsent As Integer = Nothing
            If ConsentRadioButtonList.Visible Then
                If ConsentRadioButtonList.SelectedIndex < 0 Then
                    iPatientConsent = Nothing
                Else
                    iPatientConsent = ConsentRadioButtonList.SelectedValue
                End If
            End If
            Dim ImagePortId As Integer = ImagePortComboBox.SelectedValue
            Session("PortId") = ImagePortComboBox.SelectedValue
            Dim da As DataAccess = New DataAccess()
            Session("PortName") = da.ImagePortName(Session("PortId"))
            'If ImagePortIdHiddenField.Value = "" OrElse ImagePortIdHiddenField.Value = "0" Then
            '    ImagePortId = DataAdapter.GetPCImagePortID()
            'Else
            '    ImagePortId = ImagePortIdHiddenField.Value
            'End If

            'Dim operatingHospitalId As Integer = CInt(HttpContext.Current.Session("OperatingHospitalID"))

            '### New Procedure Object.. Feed the Values.. and Pass it as a Parameter for the DataAdapter.InsertProcedure()

            'Mahfuz changed on 27 Jul 2021 - Sets Ward to null if Patient Status is 2 (Outpatient)

            Dim newProcedure As New ERS.Data.ERS_Procedures
            With newProcedure
                .ProcedureType = ProcTypeRadComboBox.SelectedValue
                .PatientId = PatientIdHiddenField.Value
                .CreatedOn = CDate(ProcedureDate.SelectedDate)
                .ProcedureTime = TimeComboBox.SelectedValue
                .PatientStatus = Utilities.GetInt(PatStatusRadioButtonList.SelectedValue)
                If .PatientStatus = 2 Then
                    .Ward = Nothing
                Else
                    .Ward = Utilities.GetInt(WardComboBox.SelectedValue)
                End If
                .PatientType = Utilities.GetInt(PatientTypeRadioButtonList.SelectedValue)
                .ListConsultant = Utilities.GetInt(ListConsultantComboBox.SelectedValue)
                .Endoscopist1 = Utilities.GetInt(Endo1ComboBox.SelectedValue)
                .Endoscopist2 = Utilities.GetInt(Endo2ComboBox.SelectedValue)
                .Assistant = Nothing
                .Nurse1 = Utilities.GetInt(Nurse1ComboBox.SelectedValue)
                .Nurse2 = Utilities.GetInt(Nurse2ComboBox.SelectedValue)
                .Nurse3 = Utilities.GetInt(Nurse3ComboBox.SelectedValue)
                .Nurse4 = Utilities.GetInt(Nurse4ComboBox.SelectedValue)
                .OperatingHospitalID = CInt(HttpContext.Current.Session("OperatingHospitalID"))
                .ReferralHospitalNo = Utilities.GetInt(HospitalComboBox.SelectedValue)
                .ReferralConsultantNo = Utilities.GetInt(ConsultantComboBox.Value)
                .ReferralConsultantSpeciality = Utilities.GetInt(SpecialityRadComboBox.SelectedValue)
                .PatientConsent = iPatientConsent
                .PatientConsentType = PatientConsentRadComboBox.SelectedValue
                .PatientConsentTypeOther = PatientConsentOtherTextBox.Text
                .CreatedBy = CInt(Session("PKUserId"))
                .ListType = (Utilities.GetInt(ListTypeComboBox.SelectedValue))
                .Endo1Role = Utilities.GetInt(Endo1RoleComboBox.SelectedValue)
                .Endo2Role = Utilities.GetInt(Endo2RoleComboBox.SelectedValue)
                .ImagePortId = ImagePortId 'CInt(IIf(ImagePortIdHiddenField.Value = "", 0, ImagePortIdHiddenField.Value))
                '### Now some conditional values- for Categories IN (Open access, Emergency [NED], Elective)
                .CategoryListId = Convert.ToInt32(CategoryRadComboBox.SelectedValue)
                .Points = ProcedurePointsRadNumericTextBox.Value
                .ChecklistComplete = ChecklistCompleteRadioButtonList.SelectedValue
                .ReferrerType = ReferrerTypeComboBox.SelectedValue
                If (GPReferralTextBox.Text.Trim() <> "") Then
                    .GPReferrer = GPReferralTextBox.Text
                Else
                    .GPReferrer = Nothing
                End If
                .ReferrerTypeOther = OtherReferrerTypeTextBox.Text
                .ProviderTypeId = ServiceProviderRadComboBox.SelectedValue
                .ProviderOther = OtherProviderRadTextBox.Text

                If CategoryRadComboBox.SelectedItem.Text().Equals("Open access") Then
                    .OpenAccessProc = Convert.ToInt32(rblOpenAccessCatOption.SelectedValue)
                ElseIf CategoryRadComboBox.SelectedItem.Text().Equals("Emergency [NED]") Then
                    .EmergencyProcType = Convert.ToInt32(rblEmergencyNedCatOption.SelectedValue)
                ElseIf CategoryRadComboBox.SelectedItem.Text().Equals("Elective") Then
                    .OnWaitingList = chkElectiveNED.Checked
                End If

                If PatientNotesRadioButtonList.SelectedValue.Trim() <> "" Then
                    .PatientNotes = PatientNotesRadioButtonList.SelectedValue
                    .PatientReferralLetter = If(PatientNotesRadioButtonList.SelectedValue = "0", ReferralLetterCheckBox.Checked, False)
                End If

                If (ImageGenderID.SelectedIndex = -1) Then
                    .ImageGenderID = 0
                Else
                    .ImageGenderID = ImageGenderID.SelectedValue
                End If

                If Not IsNothing(Session("ProcedureFromOrderComms")) Then
                    If Session("ProcedureFromOrderComms") Then
                        .OrderId = Convert.ToInt32(Session("OrderCommsOrderId"))
                    End If
                End If
                If Not IsNothing(Session(Constants.SESSION_PRE_ASSESSMENT_Id)) Then
                    .PreAssessmentId = CInt(Session(Constants.SESSION_PRE_ASSESSMENT_Id))
                End If
            End With

            Dim newProcId As Integer = DataAdapter.InsertProcedure(newProcedure, ProductRadioButtonList.SelectedValue)

            If Not IsNothing(Session("ProcedureFromOrderComms")) Then
                Session("ProcedureFromOrderComms") = Nothing
            End If
            If Not IsNothing(Session("OrderCommsOrderId")) Then
                Session("OrderCommsOrderId") = Nothing
            End If
            If Not IsNothing(Session(Constants.SESSION_IS_PRE_ASSESSMENT)) Then
                Session(Constants.SESSION_IS_PRE_ASSESSMENT) = Nothing
            End If
            If Not IsNothing(Session(Constants.SESSION_PRE_ASSESSMENT_Id)) Then
                Session(Constants.SESSION_PRE_ASSESSMENT_Id) = Nothing
            End If
            lblOCProcedure.Text = ""

            Session(Constants.SESSION_PROCEDURE_ID) = newProcId

            If newProcId > 0 Then
                Dim patientAllergy = DataAdapter.GetPatientAllergies(PatientIdHiddenField.Value, newProcId, True)
                If patientAllergy.Rows.Count > 0 Then
                    Dim dr As DataRow = patientAllergy.Rows(0)
                    DataAdapter.saveAllergy(newProcId, dr("AllergyResult"), dr("AllergyDescription"), PatientIdHiddenField.Value)
                End If

                'Save patient family history while creating new procedure
                DataAdapter.GetPatientFamilyHistory(PatientIdHiddenField.Value, newProcId, True)

            End If

            SessionHelper.SetProcedureSessions(CInt(newProcId), False, ProcTypeRadComboBox.SelectedValue, -1)
            Session("NewProcedureOpen") = "1"
            Response.Redirect("~/Products/PreProcedure.aspx", False)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while creating new procedure.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
    Protected Sub CreatePreAssessmentProcedureButton1_Click(sender As Object, e As System.EventArgs)

        If Session(Constants.SESSION_PRE_ASSESSMENT_Id) IsNot Nothing Then

            CreateOrUpdatePreAssessment(True)
            Dim preAssessmentId = CInt(Session(Constants.SESSION_PRE_ASSESSMENT_Id))

            If preAssessmentId <> 0 Then
                NewPreassessmentProcedurePageView.Selected = False
                LoadComboBoxes()
                For Each node In PrevProcsTreeView.Nodes
                    node.Selected = False

                    If node.Text = "New Procedure" Then
                        node.Selected = True
                        NewProcedurePageView.Selected = True
                    End If
                Next
                IsNewPreAssess.Value = "false"
                AppendNodeChild("Pre Assessment", "PreAssessmentId", Session(Constants.SESSION_PRE_ASSESSMENT_Id), "Pre Assessment", "PreAssessmentDate")
            End If
        End If
    End Sub
    Private Sub SetStaffSessions()
        SessionHelper.ClearStaffSessions()

        If SetDefaultCheckBox.Checked Then
            Session(Constants.SESSION_STAFF_LIST_SAVE_DEFAULTS) = True
            Session(Constants.SESSION_LISTTYPE_TEXT_DEFAULT) = ListTypeComboBox.SelectedItem.Text
            Session(Constants.SESSION_LISTCON_TEXT_DEFAULT) = ListConsultantComboBox.SelectedItem.Text
            Session(Constants.SESSION_LISTCON_GMC_DEFAULT) = ListConsultantGMCHiddenField.Value

            Session(Constants.SESSION_ENDO1_TEXT_DEFAULT) = Endo1ComboBox.SelectedItem.Text
            Session(Constants.SESSION_ENDO1_GMC_DEFAULT) = Endo1GMCHiddenField.Value
            Session(Constants.SESSION_ENDO1ROLE_TEXT_DEFAULT) = Endo1RoleComboBox.SelectedItem.Text

            Session(Constants.SESSION_ENDO2_TEXT_DEFAULT) = Endo2ComboBox.SelectedItem.Text
            Session(Constants.SESSION_ENDO2_GMC_DEFAULT) = Endo2GMCHiddenField.Value
            Session(Constants.SESSION_ENDO2ROLE_TEXT_DEFAULT) = Endo2RoleComboBox.SelectedItem.Text

            Session(Constants.SESSION_NURSE1_TEXT_DEFAULT) = Nurse1ComboBox.SelectedItem.Text
            Session(Constants.SESSION_NURSE2_TEXT_DEFAULT) = Nurse2ComboBox.SelectedItem.Text
            Session(Constants.SESSION_NURSE3_TEXT_DEFAULT) = Nurse3ComboBox.SelectedItem.Text
            Session(Constants.SESSION_NURSE4_TEXT_DEFAULT) = Nurse4ComboBox.SelectedItem.Text
        Else
            Session(Constants.SESSION_STAFF_LIST_SAVE_DEFAULTS) = False
            Session(Constants.SESSION_LISTTYPE_TEXT_DEFAULT) = Nothing
            Session(Constants.SESSION_LISTCON_TEXT_DEFAULT) = Nothing
            Session(Constants.SESSION_LISTCON_GMC_DEFAULT) = Nothing
            Session(Constants.SESSION_ENDO1_TEXT_DEFAULT) = Nothing
            Session(Constants.SESSION_ENDO1_GMC_DEFAULT) = Nothing
            Session(Constants.SESSION_ENDO1ROLE_TEXT_DEFAULT) = Nothing
            Session(Constants.SESSION_ENDO2_TEXT_DEFAULT) = Nothing
            Session(Constants.SESSION_ENDO2_GMC_DEFAULT) = Nothing
            Session(Constants.SESSION_ENDO2ROLE_TEXT_DEFAULT) = Nothing
            Session(Constants.SESSION_NURSE1_TEXT_DEFAULT) = Nothing
            Session(Constants.SESSION_NURSE2_TEXT_DEFAULT) = Nothing
            Session(Constants.SESSION_NURSE3_TEXT_DEFAULT) = Nothing
            Session(Constants.SESSION_NURSE4_TEXT_DEFAULT) = Nothing
        End If

        If ListConsultantComboBox.SelectedIndex <> 0 Then
            Session(Constants.SESSION_LISTCON) = ListConsultantComboBox.SelectedValue
            Session(Constants.SESSION_LISTCON_TEXT) = ListConsultantComboBox.SelectedItem.Text
        End If
        If Endo1ComboBox.SelectedIndex <> 0 Then
            Session(Constants.SESSION_ENDO1) = Endo1ComboBox.SelectedValue
            Session(Constants.SESSION_ENDO1_TEXT) = Endo1ComboBox.SelectedItem.Text
            Session("EndoRole") = Endo1RoleComboBox.SelectedValue
        End If
        If Endo2ComboBox.SelectedIndex <> 0 Then
            Session(Constants.SESSION_ENDO2) = Endo2ComboBox.SelectedValue
            Session(Constants.SESSION_ENDO2_TEXT) = Endo2ComboBox.SelectedItem.Text
        End If

        If Nurse1ComboBox.SelectedIndex <> 0 Then
            Session(Constants.SESSION_NURSE1) = Nurse1ComboBox.SelectedValue
            Session(Constants.SESSION_NURSE1_TEXT) = Nurse1ComboBox.SelectedItem.Text
        End If

        If Nurse2ComboBox.SelectedIndex <> 0 Then
            Session(Constants.SESSION_NURSE2) = Nurse2ComboBox.SelectedValue
            Session(Constants.SESSION_NURSE2_TEXT) = Nurse2ComboBox.SelectedItem.Text
        End If

        If Nurse3ComboBox.SelectedIndex <> 0 Then
            Session(Constants.SESSION_NURSE3) = Nurse3ComboBox.SelectedValue
            Session(Constants.SESSION_NURSE3_TEXT) = Nurse3ComboBox.SelectedItem.Text
        End If

        If Nurse4ComboBox.SelectedIndex <> 0 Then
            Session(Constants.SESSION_NURSE4) = Nurse4ComboBox.SelectedValue
            Session(Constants.SESSION_NURSE4_TEXT) = Nurse4ComboBox.SelectedItem.Text
        End If

    End Sub

    Protected Sub AddNewWardSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewWardSaveRadButton.Click
        If AddNewWardRadTextBox.Text <> "" Then
            DataAdapter.InsertPatientWard(AddNewWardRadTextBox.Text)

            LoadWardsComboBox(AddNewWardRadTextBox.Text)
            AddNewWardRadTextBox.Text = ""
        End If

        Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddWardWindow();", True)
    End Sub

    'Protected Sub PhotosImageGallery_ItemDataBound(sender As Object, e As ImageGalleryItemEventArgs) Handles PhotosImageGallery.ItemDataBound
    '    Dim desc As String = DirectCast(e.Item, ImageGalleryItem).Description
    '    Dim title As String = DirectCast(e.Item, ImageGalleryItem).Title
    '    ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "ApplyTooltip" & Trim(title.Replace(vbCr, "").Replace(vbLf, "")), "ApplyTooltip('" & Trim(desc.Replace(vbCr, "").Replace(vbLf, "")) & "');", True)
    'End Sub
    Protected Sub ProductRadioButtonList_SelectedIndexChanged(sender As Object, e As EventArgs)
        'If ProductRadioButtonList.SelectedValue = "" Then
        '    ProcTypeRadioButtonList.Items.Clear()
        'Else
        ProductChanged(CInt(ProductRadioButtonList.SelectedValue))
    End Sub
    Protected Sub TreeviewGroup_SelectedIndexChanged(sender As Object, e As EventArgs)
        Session(Constants.SESSION_IS_PRE_ASSESSMENT) = False
        Session(Constants.SESSION_TREE_GROUP_TYPE) = CInt(TreeRadioGroupList.SelectedValue)
        SpecialityCheckBox.Checked = False
        If Session(Constants.SESSION_TREE_GROUP_TYPE) = "1" Then

            SpecialityCheckBox.Visible = True

        Else
            SpecialityCheckBox.Visible = False
        End If
        LoadTreeView()
    End Sub
    Protected Sub SpecialityCheckBox_CheckedChanged(sender As Object, e As EventArgs)
        LoadTreeView()
    End Sub

    Sub ProductChanged(val As Integer)
        Try
            Dim procedureTypeDataTable As DataTable = DataAdapter.GetProcedureTypes(ProductRadioButtonList.SelectedValue)
            If procedureTypeDataTable.Rows.Count > 0 Then
                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ProcTypeRadComboBox, ""}}, procedureTypeDataTable, "ProcedureType", "ProcedureTypeId")

                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "bindControlEvents", "setProcedurePoints(" & ProcTypeRadComboBox.SelectedValue & ");", True)

                Session("ProductComboBoxValue") = ProductRadioButtonList.SelectedValue
            Else
                ProcTypeRadComboBox.Items.Clear()
            End If

        Catch ex As Exception

        End Try
    End Sub

    Sub GetPreassessmentProcedure()
        Try
            PreAssessmentProcedureTypeRadComboBox.Items.Clear()
            Dim procedureTypeDataTable As DataTable = DataAdapter.GetAllProcedureTypes()

            Dim filteredRows As DataRow() = procedureTypeDataTable.Select("ProductTypeId > 0")

            Dim filteredDataTable As DataTable = filteredRows.CopyToDataTable()
            If procedureTypeDataTable.Rows.Count > 0 Then
                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{PreAssessmentProcedureTypeRadComboBox, ""}}, filteredDataTable, "ProcedureType", "ProcedureTypeId")
                CheckedProcedureTypesFromSession(1)
            Else
                PreAssessmentProcedureTypeRadComboBox.Items.Clear()
            End If
        Catch ex As Exception

        End Try
    End Sub
    Sub CreateOrUpdatePreAssessment(isComplete As Boolean)

        Try
            Dim da As New OtherData
            Dim procedureDate = DateTime.Now

            If Session(Constants.SESSION_PRE_ASSESSMENT_Id) IsNot Nothing Then

                Dim dates = ProcedureStartDateRadTimeInput.SelectedDate.GetValueOrDefault.Date
                Dim time? = ProcedureStartRadTimePicker.SelectedDate.GetValueOrDefault

                If (time.HasValue) Then
                    procedureDate = dates.Add(time.Value.TimeOfDay)
                End If

            End If
            Dim assessmentId = da.SavePreAssessment(Session(Constants.SESSION_PROCEDURE_TYPES), Session(Constants.SESSION_PRE_ASSESSMENT_Id), PatientIdHiddenField.Value, isComplete, procedureDate)
            Session(Constants.SESSION_PRE_ASSESSMENT_Id) = assessmentId.ToString()
            PreAssessmentHiddenField.Value = assessmentId.ToString()
            Dim selectedNode = PrevProcsTreeView.SelectedNode
            If selectedNode.Text.Contains("Pre Assessment") Then
                If selectedNode IsNot Nothing Then
                    selectedNode.Attributes("ProcedureTypes") = Session(Constants.SESSION_PROCEDURE_TYPES)
                    selectedNode.Attributes("PreAssessmentDate") = procedureDate.ToString()
                End If
            End If
        Catch ex As Exception
        End Try
    End Sub
    Private Sub BindQuestions()

        Dim dt As DataTable = DataAdapter.GetPreAssessmentQuestionList(Session(Constants.SESSION_PRE_ASSESSMENT_Id), 3)

        Dim groupedData = From row In dt.AsEnumerable()
                          Group row By SectionName = row.Field(Of String)("SectionName") Into Group
                          Select New With
                          {
                               SectionName,
                              .Questions = Group.CopyToDataTable()
                          }
        PreAssessmentSectionsRepeater.DataSource = groupedData
        PreAssessmentSectionsRepeater.DataBind()

    End Sub
    Protected Sub PreAssessmentQuestionsRepeater_ItemDataBound(ByVal sender As Object, ByVal e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim sectionData = CType(e.Item.DataItem, Object)
            Dim questionsTable = CType(sectionData.GetType().GetProperty("Questions").GetValue(sectionData), DataTable)

            Dim questionsRepeater As Repeater = CType(e.Item.FindControl("PreAssessmentQuestionsRepeater"), Repeater)
            If questionsRepeater IsNot Nothing Then
                questionsRepeater.DataSource = questionsTable
                questionsRepeater.DataBind()
            End If
        End If
    End Sub

    Protected Sub PreAssessmentQuestionRepeater_ItemDataBound(ByVal sender As Object, ByVal e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then

            If e.Item.DataItem IsNot Nothing Then
                Dim dr As DataRowView = CType(e.Item.DataItem, DataRowView)

                Dim questionOptionRadioButton As RadioButtonList = CType(e.Item.FindControl("QuestionOptionRadioButton"), RadioButtonList)
                Dim questionAnswerTextBox As RadTextBox = CType(e.Item.FindControl("QuestionAnswerTextBox"), RadTextBox)
                Dim preQuestionMandatoryImage As WebControls.Image = CType(e.Item.FindControl("PreQuestionMandatoryImage"), WebControls.Image)
                Dim answerComboBox As RadComboBox = CType(e.Item.FindControl("DropdownOptionsRadComboBox"), RadComboBox)
                Dim combo As RadComboBox = CType(e.Item.FindControl("QuestionOptionComboBox"), RadComboBox)
                Dim questionId As HiddenField = CType(e.Item.FindControl("QuestionIdHiddenField"), HiddenField)
                Dim answerId As HiddenField = CType(e.Item.FindControl("AnswerIdHiddenField"), HiddenField)

                Dim isOptional As Boolean = CType(dr("Optional"), Boolean)
                Dim isDropDownOption As Boolean
                Dim isYesNo As Boolean = CType(dr("YesNo"), Boolean)
                Dim freeText As Boolean = CType(dr("FreeText"), Boolean)
                Dim dropdownAnswer As String = ""
                Dim dropdownOptionQuestion As String = ""
                Dim optionAnswer As String = ""
                Dim freeTextAnswer As String = ""

                If Not IsDBNull(dr("DropdownOption")) Then
                    Dim optionValue As Boolean = CType(dr("DropdownOption"), Boolean)
                    isDropDownOption = If(optionValue, "1", "0")
                End If

                If Not IsDBNull(dr("DropdownOptionText")) Then
                    dropdownOptionQuestion = CType(dr("DropdownOptionText"), String)

                End If

                If Not IsDBNull(dr("DropdownAnswer")) Then
                    dropdownAnswer = CType(dr("DropdownAnswer"), String).Trim()

                End If


                If isDropDownOption And Not String.IsNullOrEmpty(dropdownOptionQuestion) Then
                    answerComboBox.Visible = True
                    answerComboBox.Items.Clear()
                    Dim comboBoxItems As New List(Of RadComboBoxItem)()
                    Dim optionsArray As String() = dropdownOptionQuestion.Split(","c)
                    If Not String.IsNullOrEmpty(dropdownAnswer) AndAlso Not optionsArray.Any(Function(x) x.Trim().Equals(dropdownAnswer.Trim(), StringComparison.OrdinalIgnoreCase)) Then
                        Dim item = GetRadItem(dropdownAnswer)
                        comboBoxItems.Add(item)
                    End If

                    For Each optionText As String In optionsArray
                        Dim item = GetRadItem(optionText)
                        comboBoxItems.Add(item)
                    Next
                    If questionId IsNot Nothing Then
                        answerComboBox.Attributes("data-questionid") = questionId.Value
                    End If
                    If answerId IsNot Nothing Then
                        answerComboBox.Attributes("data-answerid") = answerId.Value
                    End If

                    answerComboBox.Items.AddRange(comboBoxItems)
                    answerComboBox.Items.Insert(0, New RadComboBoxItem("", ""))
                    answerComboBox.SelectedValue = dropdownAnswer
                Else
                    answerComboBox.Visible = False
                End If

                If Not IsDBNull(dr("OptionAnswer")) Then
                    Dim optionValue As Boolean = CType(dr("OptionAnswer"), Boolean)
                    optionAnswer = If(optionValue, "1", "0")
                End If

                If Not IsDBNull(dr("FreeTextAnswer")) Then
                    freeTextAnswer = CType(dr("FreeTextAnswer"), String)
                End If


                If questionOptionRadioButton IsNot Nothing AndAlso Not isYesNo Then
                    questionOptionRadioButton.Visible = False
                End If

                If questionAnswerTextBox IsNot Nothing AndAlso Not freeText Then
                    questionAnswerTextBox.Visible = False
                End If

                If preQuestionMandatoryImage IsNot Nothing AndAlso Not isOptional Then
                    preQuestionMandatoryImage.Visible = False
                End If

                If combo IsNot Nothing AndAlso questionId IsNot Nothing Then
                    combo.Attributes("data-questionid") = questionId.Value
                End If

                If Not String.IsNullOrEmpty(optionAnswer) Then
                    questionOptionRadioButton.SelectedValue = optionAnswer
                End If

                questionAnswerTextBox.Text = freeTextAnswer
            End If

        End If
    End Sub
    Function GetRadItem(ByVal optionText As String)

        Dim item As New RadComboBoxItem()
        item.Text = optionText.Trim()
        item.Value = optionText.Trim()
        Return item
    End Function
    Protected Sub PreAssessmentProcedureTypeRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)

        Dim selectedValues As New List(Of String)

        For Each item As RadComboBoxItem In PreAssessmentProcedureTypeRadComboBox.CheckedItems
            selectedValues.Add(item.Value)
        Next

        Session(Constants.SESSION_PROCEDURE_TYPES) = String.Join(",", selectedValues)
        CreateOrUpdatePreAssessment(False)

    End Sub
    Private Sub ClearPreassessmentSession(isPreAssessment)

        If isPreAssessment Then
            Session(Constants.SESSION_PROCEDURE_ID) = Nothing
        Else
            Session(Constants.SESSION_PRE_ASSESSMENT_Id) = Nothing
            Session(Constants.SESSION_PROCEDURE_TYPES) = ""
            Session(Constants.SESSION_IS_PRE_ASSESSMENT) = False
        End If

    End Sub
    Protected Sub WhoCheckSave_Click(sender As Object, e As EventArgs)
        Dim StatusBl As Nullable(Of Boolean) = Nothing
        If rbSurgicalChecklistNo.Checked Then
            StatusBl = False
        ElseIf rbSurgicalChecklistYes.Checked Then
            StatusBl = True
        End If
        Dim ds As New DataAccess
        ds.UpdateWHOSurgicalSafetyCheckList(CInt(WhoCheckHidden.Value), StatusBl)

        PrevProcsTreeView.FindNodeByAttribute("ProcedureId", WhoCheckHidden.Value).Attributes("SurgicalSafetyCheckListCompleted") = ds.GetWHOSurgicalSafetyCheckList(CInt(WhoCheckHidden.Value))
        PrevProcsTreeView.DataBind()
        If PrevProcsTreeView.SelectedNode.Text <> "New Procedure" Then NodeClick(PrevProcsTreeView.SelectedNode)
    End Sub

    Protected Sub ProcNotCarriedOutSave_Click(sender As Object, e As EventArgs)
        Dim StatusBl As Nullable(Of Boolean) = Nothing

    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs)
        If e.Argument.ToLower.Contains("newconsultant") Then
            Dim newId As Integer
            If Integer.TryParse(e.Argument.Split("|")(1), newId) Then
                LoadConsultantDDL()

                'If ConsultantComboBox.Items.Count > 14 Then ConsultantComboBox.Height = 300
                'ConsultantComboBox.FindItemByValue(newId).Selected = True
                ConsultantChanged()
            End If
        End If
    End Sub

    Private Sub patientview_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender

        If Not hasConsultantChanged Then Exit Sub

        'Set focus to PrevProcsTreeView only when Referring Consultant is changed (this is a transitory solution)
        Dim pTreeView As RadTreeView = TryCast(Me.FindControl("PrevProcsTreeView"), RadTreeView)
        If pTreeView IsNot Nothing Then
            ScriptManager.GetCurrent(Me.Page).SetFocus(pTreeView)
        End If
    End Sub

    Protected Sub EditReportLinkButton_Click(sender As Object, e As EventArgs)
        EditProcedure()
    End Sub

    'Protected Sub OpenPDFUpload_Click(sender As Object, e As EventArgs)
    '    Dim patientId = PatientIdHiddenField.Value
    '    'RadWindow_NavigateUrl.NavigateUrl = "~/Products/PDFFileUpload.aspx?patientId=" + patientId
    '    'RadWindow_NavigateUrl.VisibleOnPageLoad = True  ' Set the VisibleOnPageLoad Property To True
    'End Sub

    Public Function SavePDFFile(pdfExportFilePathName As String, procedureDescription As String,
                                 procedureDate As Date, patientId As Integer) As Boolean
        Try
            Using output As New FileStream(pdfExportFilePathName, FileMode.Open)
                Dim iLen As Integer = CInt(output.Length)
                Dim bBLOBStorage(iLen) As Byte
                output.Read(bBLOBStorage, 0, iLen)
                Dim pdInstance = New Products_Default

                DataAdapter.SavePDFToDatabase(patientId, procedureDescription, procedureDate, bBLOBStorage)
            End Using

            Return True

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred in SavePDFFile", ex)
            Return False
        End Try
    End Function

    Public Function SavePDFFile(pdfExportBytes() As Byte, procedureDescription As String,
                                 procedureDate As Date, patientId As Integer) As Boolean
        Try
            DataAdapter.SavePDFToDatabase(patientId, procedureDescription, procedureDate, pdfExportBytes)
            Return True
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred in SavePDFFile", ex)
            Return False
        End Try
    End Function

    Public Function RemovePDFFile(previousProcId As Integer, removeReason As String) As Boolean
        Try
            DataAdapter.DeletePreviousProcedure(CInt(previousProcId), removeReason)

            Return True

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred in RemovePDFFile", ex)
            Return False
        End Try
    End Function

    Protected Sub RemovePDFFile_Click(sender As Object, e As EventArgs)
        Try
            RemovePDFFile(CInt(PreviousProcIdHiddenField.Value), RemoveProcedureReasonRadTextBox.Text)

            RemoveProcedureReasonRadTextBox.Text = ""

            LoadTreeView()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred in RemovePDFFile_Click", ex)
        End Try

    End Sub

    Protected Sub SaveFile_Click(sender As Object, e As EventArgs)
        Try
            'Dim folderPath As String = Server.MapPath("~/Files/")

            'Check whether Directory (Folder) exists.
            'If Not Directory.Exists(folderPath) Then
            '    'If Directory (Folder) does not exists. Create it.
            '    Directory.CreateDirectory(folderPath)
            'End If



            If Me.FileUpload1.HasFile Then
                FileUpload1.PostedFile.InputStream.Position = 0

                Using output As New MemoryStream()
                    FileUpload1.PostedFile.InputStream.CopyTo(output)
                    output.Position = 0
                    Dim iLen As Integer = CInt(output.Length)
                    Dim bBLOBStorage(iLen) As Byte
                    bBLOBStorage = output.ToArray()
                    SavePDFFile(bBLOBStorage, ProcedureDescriptionTextBox.Text, ProcedureDateRadDatePicker.SelectedDate, PatientIdHiddenField.Value)
                End Using

                'Save the File to the Directory (Folder).
                'Dim filePathAndName = folderPath & Path.GetFileName(FileUpload1.FileName)
                'FileUpload1.SaveAs(filePathAndName)

                'SavePDFFile(filePathAndName, ProcedureDescriptionTextBox.Text, ProcedureDateRadDatePicker.SelectedDate, PatientIdHiddenField.Value)

                'Display the success message.
                lblMessage.Text = FileUpload1.FileName + " has been uploaded."
            End If

            ProcedureDateRadDatePicker.Clear()
            ProcedureDescriptionTextBox.Text = ""

            LoadTreeView()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred in SaveFile_Click", ex)
        End Try
    End Sub

    Sub GetNurseModuleProcedure()
        Try
            NurseModuleProcedureTypeRadComboBox.Items.Clear()
            Dim procedureTypeDataTable As DataTable = DataAdapter.GetAllProcedureTypes()

            Dim filteredRows As DataRow() = procedureTypeDataTable.Select("ProductTypeId > 0")

            Dim filteredDataTable As DataTable = filteredRows.CopyToDataTable()
            If procedureTypeDataTable.Rows.Count > 0 Then
                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{NurseModuleProcedureTypeRadComboBox, ""}}, filteredDataTable, "ProcedureType", "ProcedureTypeId")
                CheckedProcedureTypesFromSession(2)
            Else
                NurseModuleProcedureTypeRadComboBox.Items.Clear()
            End If
        Catch ex As Exception

        End Try
    End Sub

    Sub CreateOrUpdateNurseModule(isComplete As Boolean)
        Try
            Dim da As New OtherData

            Dim procedureDate = DateTime.Now

            If Session(Constants.SESSION_Nurse_Module_Id) IsNot Nothing Then

                Dim dates = NurseRadDateInput.SelectedDate.GetValueOrDefault.Date
                Dim time? = NurseRadTimePicker.SelectedDate.GetValueOrDefault

                If (time.HasValue) Then
                    procedureDate = dates.Add(time.Value.TimeOfDay)
                End If

            End If

            Dim moduleId = da.SaveNurseModule(Session(Constants.SESSION_PROCEDURE_TYPES), Session(Constants.SESSION_Nurse_Module_Id), PatientIdHiddenField.Value, procedureDate, isComplete)

            Session(Constants.SESSION_Nurse_Module_Id) = moduleId.ToString()

            NurseModuleHiddenField.Value = moduleId.ToString()
            Dim selectedNode = PrevProcsTreeView.SelectedNode
            If selectedNode.Text.Contains("Nursing Module") Then
                If selectedNode IsNot Nothing Then
                    selectedNode.Attributes("ProcedureTypes") = Session(Constants.SESSION_PROCEDURE_TYPES)
                    selectedNode.Attributes("NurseModuleDate") = procedureDate.ToString()
                End If
            End If
        Catch ex As Exception
        End Try
    End Sub

    Protected Sub CreateNurseModuleProcedureButton1_Click(sender As Object, e As System.EventArgs)
        If Session(Constants.SESSION_Nurse_Module_Id) IsNot Nothing Then
            CreateOrUpdateNurseModule(True)
            Dim nurseModuelId = CInt(Session(Constants.SESSION_Nurse_Module_Id))
            AppendNodeChild("Nursing Module", "NurseModuleId", Session(Constants.SESSION_Nurse_Module_Id), "Nursing Module", "NurseModuleDate")
            IsNewNurses.Value = "false"
        End If
    End Sub

    Sub PreAssessmentRadTimePicker_SelectedDateChanged(sender As Object, e As SelectedDateChangedEventArgs)
        CreateOrUpdatePreAssessment(False)
    End Sub

    Sub NurseRadTimePicker_SelectedDateChanged(sender As Object, e As SelectedDateChangedEventArgs)
        CreateOrUpdateNurseModule(False)
    End Sub

    Protected Sub NurseModuleProcedureTypeRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Dim selectedValues As New List(Of String)

        For Each item As RadComboBoxItem In NurseModuleProcedureTypeRadComboBox.CheckedItems
            selectedValues.Add(item.Value)
        Next
        Session(Constants.SESSION_PROCEDURE_TYPES) = String.Join(",", selectedValues)
        CreateOrUpdateNurseModule(False)
        BindNurseModuleQuestions()
    End Sub

    Private Sub BindNurseModuleQuestions()

        Dim dt As DataTable = DataAdapter.GetNurseModuleQuestionAndAnswerList(Session(Constants.SESSION_PROCEDURE_TYPES), CInt(Session(Constants.SESSION_Nurse_Module_Id)), CInt(Session("TrustId")))
        Dim groupedData = From row In dt.AsEnumerable()
                          Group row By SectionName = row.Field(Of String)("SectionName") Into Group
                          Select New With
                          {
                               SectionName,
                              .Questions = Group.CopyToDataTable()
                          }
        NurseModuleSectionRepeater.DataSource = groupedData
        NurseModuleSectionRepeater.DataBind()
    End Sub

    Protected Sub NurseModuleSectionsRepeater_ItemDataBound(ByVal sender As Object, ByVal e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim sectionData = CType(e.Item.DataItem, Object)
            Dim questionsTable = CType(sectionData.GetType().GetProperty("Questions").GetValue(sectionData), DataTable)

            Dim questionsRepeater As Repeater = CType(e.Item.FindControl("NurseModuleQuestionsRepeater"), Repeater)
            If questionsRepeater IsNot Nothing Then
                questionsRepeater.DataSource = questionsTable
                questionsRepeater.DataBind()
            End If
        End If
    End Sub

    Protected Sub NurseModuleQuestionRepeater_ItemDataBound(ByVal sender As Object, ByVal e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then

            If e.Item.DataItem IsNot Nothing Then
                Dim dr As DataRowView = CType(e.Item.DataItem, DataRowView)

                Dim questionOptionRadioButton As RadioButtonList = CType(e.Item.FindControl("NurseModuleQuestionOptionRadioButton"), RadioButtonList)
                Dim questionAnswerTextBox As RadTextBox = CType(e.Item.FindControl("NurseModuleQuestionAnswerTextBox"), RadTextBox)
                Dim preQuestionMandatoryImage As WebControls.Image = CType(e.Item.FindControl("PreQuestionMandatoryImage"), WebControls.Image)
                Dim answerComboBox As RadComboBox = CType(e.Item.FindControl("NurseModuleDropdownOptionsRadComboBox"), RadComboBox)
                Dim combo As RadComboBox = CType(e.Item.FindControl("NurseModuleQuestionOptionComboBox"), RadComboBox)
                Dim questionId As HiddenField = CType(e.Item.FindControl("NurseModuleQuestionIdHiddenField"), HiddenField)
                Dim answerId As HiddenField = CType(e.Item.FindControl("NurseModuleAnswerIdHiddenField"), HiddenField)

                Dim isMandatory As Boolean = CType(dr("Mandatory"), Boolean)
                Dim isDropDownOption As Boolean
                Dim isYesNo As Boolean = CType(dr("YesNo"), Boolean)
                Dim freeText As Boolean = CType(dr("FreeText"), Boolean)
                Dim dropdownAnswer As String = ""
                Dim dropdownOptionQuestion As String = ""
                Dim optionAnswer As String = ""
                Dim freeTextAnswer As String = ""

                If Not IsDBNull(dr("DropdownOption")) Then
                    Dim optionValue As Boolean = CType(dr("DropdownOption"), Boolean)
                    isDropDownOption = If(optionValue, "1", "0")
                End If

                If Not IsDBNull(dr("DropdownOptionText")) Then
                    dropdownOptionQuestion = CType(dr("DropdownOptionText"), String)

                End If

                If Not IsDBNull(dr("DropdownAnswer")) Then
                    dropdownAnswer = CType(dr("DropdownAnswer"), String).Trim()

                End If


                If isDropDownOption And Not String.IsNullOrEmpty(dropdownOptionQuestion) Then
                    answerComboBox.Visible = True
                    answerComboBox.Items.Clear()
                    Dim comboBoxItems As New List(Of RadComboBoxItem)()
                    Dim optionsArray As String() = dropdownOptionQuestion.Split(","c)
                    If Not String.IsNullOrEmpty(dropdownAnswer) AndAlso Not optionsArray.Any(Function(x) x.Trim().Equals(dropdownAnswer.Trim(), StringComparison.OrdinalIgnoreCase)) Then
                        Dim item = GetRadItem(dropdownAnswer)
                        comboBoxItems.Add(item)
                    End If

                    For Each optionText As String In optionsArray
                        Dim item = GetRadItem(optionText)
                        comboBoxItems.Add(item)
                    Next
                    If questionId IsNot Nothing Then
                        answerComboBox.Attributes("data-questionid") = questionId.Value
                    End If
                    If answerId IsNot Nothing Then
                        answerComboBox.Attributes("data-answerid") = answerId.Value
                    End If

                    answerComboBox.Items.AddRange(comboBoxItems)
                    answerComboBox.Items.Insert(0, New RadComboBoxItem("", ""))
                    answerComboBox.SelectedValue = dropdownAnswer
                Else
                    answerComboBox.Visible = False
                End If

                If Not IsDBNull(dr("OptionAnswer")) Then
                    Dim optionValue As Boolean = CType(dr("OptionAnswer"), Boolean)
                    optionAnswer = If(optionValue, "1", "0")
                End If

                If Not IsDBNull(dr("FreeTextAnswer")) Then
                    freeTextAnswer = CType(dr("FreeTextAnswer"), String)
                End If


                If questionOptionRadioButton IsNot Nothing AndAlso Not isYesNo Then
                    questionOptionRadioButton.Visible = False
                End If

                If questionAnswerTextBox IsNot Nothing AndAlso Not freeText Then
                    questionAnswerTextBox.Visible = False
                End If

                If preQuestionMandatoryImage IsNot Nothing AndAlso isMandatory = False Then
                    preQuestionMandatoryImage.Visible = False
                End If

                If combo IsNot Nothing AndAlso questionId IsNot Nothing Then
                    combo.Attributes("data-questionid") = questionId.Value
                End If

                If Not String.IsNullOrEmpty(optionAnswer) Then
                    questionOptionRadioButton.SelectedValue = optionAnswer
                End If

                questionAnswerTextBox.Text = freeTextAnswer
            End If
        End If
    End Sub
    Protected Sub NurseTimeNow_Click(sender As Object, e As EventArgs)
        NurseRadTimePicker.SelectedDate = DateTime.Now
        NurseRadDateInput.SelectedDate = DateTime.Now
        CreateOrUpdateNurseModule(False)
    End Sub
    Protected Sub PreAssessTimeNow_Click(sender As Object, e As EventArgs)
        ProcedureStartDateRadTimeInput.SelectedDate = DateTime.Now
        ProcedureStartRadTimePicker.SelectedDate = DateTime.Now
        CreateOrUpdatePreAssessment(False)
    End Sub
End Class