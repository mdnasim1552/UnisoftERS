Imports Telerik.Web.UI
Imports System.Data.SqlClient

Partial Class DATAMasterPage_old
    Inherits System.Web.UI.MasterPage

    Private conn As SqlConnection = Nothing
    Private myReader As SqlDataReader = Nothing
    'Private myArray() As String

    '#Public Sub DisplayDataFromPage(ByVal message As String)
    '#DataFromPage.Text = message
    '#End Sub

    '#Public ReadOnly Property DataFromPageLabelControl() As Label
    '#Get
    '#Return Me.DataFromPage
    '#End Get
    '#End Property

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        'ScriptManager.RegisterStartupScript(Me, Me.GetType(), "load", "alert('load');", True)
        If Not IsPostBack Then
            SessionTimeoutNotification.ShowInterval = (Session.Timeout - 1) * 60000
            SessionTimeoutNotification.Value = Page.ResolveClientUrl("~/Security/Logout.aspx")

            InitForm()
            'lblUserID.Text = "UserID: <b>" & Session("UserID") & " (" & Session("FullName") & ")" & "</b>"
            'lblPageID.Text = "PageID: <b>" & Session("PageID") & "</b>&nbsp;"
            'lblCompany.Text = "&#169 1994-" & Format(Now(), "yyyy") & " <b>Unisoft Medical Systems</b>"
            'LoggedOnAtLabel.Text = "Logged on at: <b>" & Session("LoggedOn") & "</b>"
        End If
    End Sub

    Protected Sub InitForm()
        Select Case Session("PageID")
            Case "1"
                '##cmdIndications.Skin = "Web20"
                '##cmdIndications.Enabled = False

            Case "4"
                '##cmdDiagnoses.Skin = "Web20"
                '##cmdDiagnoses.Enabled = False

            Case "7"
                '##cmdFollowUp.Skin = "Web20"
                '##cmdFollowUp.Enabled = False
        End Select

        Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
            Case 2 'ERCP
                cmdExtLim.Visible = False
                cmdVisualisation.Visible = True

            Case 3, 4 'Col/Sig
                cmdExtLim.Text = "Extent/Limiting factors"

            Case 5 'Proct
                cmdExtLim.Visible = False

            Case 8, 9 'Broncho / EBUS
                cmdIndications.Visible = False
                cmdPremed.Visible = False
                cmdVisualisation.Visible = False
                cmdExtLim.Visible = False
                cmdDiagnoses.Visible = False
                cmdQA.Visible = False
                cmdRx.Visible = False
                cmdFollowUp.Visible = False
                cmd18w.Visible = False
                PathologyButton.Visible = True
                DrugsButton.Visible = True
        End Select

        Dim procName As String = ""
        Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
            Case 1
                procName = "Upper GI"
            Case 2
                procName = "ERCP"
            Case 3, 5
                procName = "Colon"
            Case 4
                procName = "Sigmoidoscopy"
        End Select
        lblProcDate.Text = "<span style='font-size:smaller;color:#ffff99;'>Summary</span><br />" & procName & " Procedure - " & Format(Now(), "dd/MM/yyyy")
        'lblProcDate.Text = Session("ProcTable") & " Procedure - " & Format(Now(), "dd/MM/yyyy")

        If Session("AdvancedMode") = False Or Session("PageID") = "99" Then
            'Hide the entire left pane if it is not PatientProcedure page, as the left pane is needed on PatientProcedure page to display the diagram
            If Request.Url.Segments(Request.Url.Segments.Count - 1) = "PatientProcedure.aspx" Then
                SummaryPreviewDiv.Visible = False
            Else
                paneReportSummary.Visible = False
                paneButtons.Visible = False
                SBReport.Visible = False
            End If
        End If

        'radWindow.OpenerElementID = "cmdShowDiagram"
        'radWindow.NavigateUrl = "~/Diagrams/Stomach.aspx"

        'Call loadReportFields()
        Call loadPatientInfo()
        LoadStaffDefaults()
        LoadStaffLabels()
        SetButtonStyle()
        LoadStaffEditForm()
    End Sub

    'Protected Sub loadReportFields()
    '    ReDim myArray(8)
    '    myArray(0) = "Indications;;PP_Indic"
    '    myArray(1) = "Report;;PP_MainReportBody"
    '    myArray(2) = "Diagnoses;;PP_Diagnoses"
    '    myArray(3) = "Therapies;;PP_Therapies"
    '    myArray(4) = "Premedication;;PP_Premed"
    '    myArray(5) = "Follow up;;PP_Followup"
    '    myArray(6) = "Advice/Comments;;PP_AdviceAndComments"
    '    myArray(7) = "Specimen Taken;;PP_SpecimenTaken"
    '    myArray(8) = "Rx;;PP_Rx"
    'End Sub

    Protected Sub loadPage(ByRef pageName As String)
        Dim sPageURL As String = ""
        Dim pageIDX As String = ""

        Session("PageID") = ""

        Select Case pageName
            Case "MainScreen"
                sPageURL = "~/Products/PatientProcedure.aspx"
                pageIDX = ""

            Case "Indications"
                sPageURL = "~/Products/Gastro/OtherData/OGD/Indications.aspx"
                pageIDX = "1"

            Case "Premed"
                sPageURL = "~/Products/Common/PreMed.aspx"
                'sPageURL = "~/Products/UnderConstruction.aspx"
                'sPageURL = "~/Products/Gastro/OtherData/OGD/Premed.aspx"
                pageIDX = "2"

            Case "Extent/Lim"
                If Session(Constants.SESSION_PROCEDURE_TYPE) = 1 Then
                    sPageURL = "~/Products/Gastro/OtherData/OGD/ExtentOfIntubation.aspx"
                Else
                    sPageURL = "~/Products/Common/ExtentLim.aspx"
                End If

                pageIDX = "3"

            Case "Visualisation"
                sPageURL = "~/Products/Common/Visualisation.aspx"
                pageIDX = "4"

            Case "Diagnoses"
                'sPageURL = "~/Products/Common/Diagnoses.aspx"
                sPageURL = "~/Products/Gastro/OtherData/OGD/Diagnoses.aspx"
                pageIDX = "5"

            Case "QA"
                'sPageURL = "~/Products/Common/QA.aspx"
                sPageURL = "~/Products/Gastro/OtherData/OGD/QA.aspx"
                pageIDX = "6"

            Case "Rx"
                sPageURL = "~/Products/Gastro/OtherData/OGD/Rx.aspx"
                'sPageURL = "~/Products/UnderConstruction.aspx"
                pageIDX = "7"

            Case "FollowUp"
                'sPageURL = "~/Products/Common/FollowUp.aspx"
                sPageURL = "~/Products/Gastro/OtherData/OGD/FollowUp.aspx"
                pageIDX = "8"

            Case "18w"
                'sPageURL = "~/Products/Common/18w.aspx"
                pageIDX = "9"

            Case "Print"
                'sPageURL = "PatientReport.aspx"
                sPageURL = "~/Products/Default.aspx?Print=yes"
                'sPageURL = "~/Products/Default.aspx?CNN=" & Session(Constants.SESSION_CASE_NOTE_NO) & "&Print=yes"
                pageIDX = "10"

            Case "Abno"
                'sPageURL = "~/Products/Common/AbnoThera3.aspx?xy=" & lblCoords.Value
                'pageIDX = "9"

            Case "Pathology"
                sPageURL = "~/Products/Broncho/OtherData/Pathology.aspx"
                pageIDX = "11"

            Case "Drugs"
                sPageURL = "~/Products/Broncho/OtherData/Drugs.aspx"
                pageIDX = "12"
        End Select

        Session("PageID") = pageIDX

        Response.Redirect(sPageURL)
    End Sub

    Protected Sub cmdMainScreen_Click(sender As Object, e As System.EventArgs) Handles cmdMainScreen.Click
        Call loadPage("MainScreen")
    End Sub

    Public Sub setButtonStatus()

    End Sub

    Public Sub disableButtons()
        Dim bSetState As New Boolean
        bSetState = Session("ButtonState")

        cmdMainScreen.Enabled = IIf(bSetState = True, False, True)
        cmdIndications.Enabled = IIf(bSetState = True, False, True)
        cmdPremed.Enabled = IIf(bSetState = True, False, True)
        cmdFollowUp.Enabled = IIf(bSetState = True, False, True)
        cmdExtLim.Enabled = IIf(bSetState = True, False, True)
        cmdQA.Enabled = IIf(bSetState = True, False, True)
        cmdRx.Enabled = IIf(bSetState = True, False, True)
        cmdVisualisation.Enabled = IIf(bSetState = True, False, True)
        'cmdDiagnoses.Enabled = IIf(bSetState = True, False, True)
        cmdDiagnoses.Visible = False
        cmd18w.Enabled = IIf(bSetState = True, False, True)

        'Select Case Session("PageID")
        '    Case "1"
        '        cmdIndications.Font.Bold = True
        'End Select
    End Sub

    Protected Sub cmdDiagnoses_Click(sender As Object, e As System.EventArgs) Handles cmdDiagnoses.Click
        If Session("StaffChanged") IsNot Nothing Then
            If CBool(Session("StaffChanged")) Then
                'SaveStaff()
            End If
        End If
        Call loadPage("Diagnoses")
    End Sub

    Protected Sub cmdIndications_Click(sender As Object, e As System.EventArgs) Handles cmdIndications.Click
        Call loadPage("Indications")
    End Sub

    Protected Sub cmdExtLim_Click(sender As Object, e As System.EventArgs) Handles cmdExtLim.Click
        Call loadPage("Extent/Lim")
    End Sub

    Protected Sub cmdPremed_Click(sender As Object, e As System.EventArgs) Handles cmdPremed.Click
        Call loadPage("Premed")
    End Sub

    Protected Sub cmdFollowUp_Click(sender As Object, e As System.EventArgs) Handles cmdFollowUp.Click
        Call loadPage("FollowUp")
    End Sub

    Protected Sub cmdQA_Click(sender As Object, e As System.EventArgs) Handles cmdQA.Click
        Call loadPage("QA")
    End Sub

    Protected Sub cmdVisualisation_Click(sender As Object, e As System.EventArgs) Handles cmdVisualisation.Click
        Call loadPage("Visualisation")
    End Sub

    Protected Sub cmdRx_Click(sender As Object, e As System.EventArgs) Handles cmdRx.Click
        Call loadPage("Rx")
    End Sub

    Protected Sub cmdPrint_Click(sender As Object, e As System.EventArgs) Handles cmdPrint.Click
        Call loadPage("Print")
    End Sub

    Protected Sub PathologyButton_Click(sender As Object, e As System.EventArgs) Handles PathologyButton.Click
        loadPage("Pathology")
    End Sub

    Protected Sub DrugsButton_Click(sender As Object, e As System.EventArgs) Handles DrugsButton.Click
        loadPage("Drugs")
    End Sub

    Protected Sub loadPatientInfo()
        PatientName.Text = Session("PatSurname") & ", " & Session("PatForename") & " (" & Session("PatGender") & ")"
        CNN.Text = Session(Constants.SESSION_CASE_NOTE_NO)
        NHSNo.Text = Session("PatNHS")
        DOB.Text = Session("PatDOB")
        RecCreated.Text = Session("PatCreated")
    End Sub

    'Protected Sub MasterPageAjaxManager_AjaxRequest(sender As Object, e As AjaxRequestEventArgs) Handles MasterPageAjaxManager.AjaxRequest
    '    EndoscopistsLabel.Text = "rama"
    'End Sub

    Public Sub LoadStaffEditForm()
        Dim da As New DataAccess
        Dim staffTextField As String = "UserFullName"
        Dim staffValueField As String = "UserId"
        Dim itemToSelect As RadComboBoxItem

        Utilities.LoadDropdown(ListConsultantComboBox, da.GetStaff(Staff.ListConsultant), staffTextField, staffValueField, "")
        Utilities.LoadDropdown(Endo1ComboBox, da.GetStaff(Staff.EndoScopist1), staffTextField, staffValueField, "")
        Utilities.LoadDropdown(Endo2ComboBox, da.GetStaff(Staff.EndoScopist2), staffTextField, staffValueField, "")
        Utilities.LoadDropdown(Nurse1ComboBox, da.GetStaff(Staff.Nurse1), staffTextField, staffValueField, "")
        Utilities.LoadDropdown(Nurse2ComboBox, da.GetStaff(Staff.Nurse2), staffTextField, staffValueField, "")
        Utilities.LoadDropdown(Nurse3ComboBox, da.GetStaff(Staff.Nurse3), staffTextField, staffValueField, "")

        If Not String.IsNullOrEmpty(Session(Constants.SESSION_LISTCON)) AndAlso Session(Constants.SESSION_LISTCON) <> "" Then
            itemToSelect = ListConsultantComboBox.FindItemByValue(CInt(Session(Constants.SESSION_LISTCON)))
            If itemToSelect IsNot Nothing Then itemToSelect.Selected = True
        End If
        If Not String.IsNullOrEmpty(Session(Constants.SESSION_ENDO1)) AndAlso Session(Constants.SESSION_ENDO1) <> "" Then
            itemToSelect = Endo1ComboBox.FindItemByValue(CInt(Session(Constants.SESSION_ENDO1)))
            If itemToSelect IsNot Nothing Then itemToSelect.Selected = True
        End If
        If Not String.IsNullOrEmpty(Session(Constants.SESSION_ENDO2)) AndAlso Session(Constants.SESSION_ENDO2) <> "" Then
            itemToSelect = Endo2ComboBox.FindItemByValue(CInt(Session(Constants.SESSION_ENDO2)))
            If itemToSelect IsNot Nothing Then itemToSelect.Selected = True
        End If
        If Not String.IsNullOrEmpty(Session(Constants.SESSION_NURSE1)) AndAlso Session(Constants.SESSION_NURSE1) <> "" Then
            itemToSelect = Nurse1ComboBox.FindItemByValue(CInt(Session(Constants.SESSION_NURSE1)))
            If itemToSelect IsNot Nothing Then itemToSelect.Selected = True
        End If
        If Not String.IsNullOrEmpty(Session(Constants.SESSION_NURSE2)) AndAlso Session(Constants.SESSION_NURSE2) <> "" Then
            itemToSelect = Nurse2ComboBox.FindItemByValue(CInt(Session(Constants.SESSION_NURSE2)))
            If itemToSelect IsNot Nothing Then itemToSelect.Selected = True
        End If
        If Not String.IsNullOrEmpty(Session(Constants.SESSION_NURSE3)) AndAlso Session(Constants.SESSION_NURSE3) <> "" Then
            itemToSelect = Nurse3ComboBox.FindItemByValue(CInt(Session(Constants.SESSION_NURSE3)))
            If itemToSelect IsNot Nothing Then itemToSelect.Selected = True
        End If
    End Sub

    Public Sub LoadStaffDefaults()
        Dim listconsultant As String = ""
        Dim endoscopists As String = ""
        Dim nurses As String = ""

        listconsultant = CStr(Session(Constants.SESSION_LISTCON_TEXT_DEFAULT))

        endoscopists = CStr(Session(Constants.SESSION_ENDO1_TEXT_DEFAULT)) _
            & IIf(Session(Constants.SESSION_ENDO2_TEXT_DEFAULT) <> "", _
                  ", " & CStr(Session(Constants.SESSION_ENDO2_TEXT_DEFAULT)), _
                  "")

        nurses = CStr(Session(Constants.SESSION_NURSE1_TEXT_DEFAULT))
        If CStr(Session(Constants.SESSION_NURSE2_TEXT_DEFAULT)) <> "" Then
            If nurses <> "" Then
                nurses = nurses & ", " & CStr(Session(Constants.SESSION_NURSE2_TEXT_DEFAULT))
            Else
                nurses = CStr(Session(Constants.SESSION_NURSE2_TEXT_DEFAULT))
            End If
        End If
        If CStr(Session(Constants.SESSION_NURSE3_TEXT_DEFAULT)) <> "" Then
            If nurses <> "" Then
                nurses = nurses & ", " & CStr(Session(Constants.SESSION_NURSE3_TEXT_DEFAULT))
            Else
                nurses = CStr(Session(Constants.SESSION_NURSE3_TEXT_DEFAULT))
            End If
        End If

        If String.IsNullOrEmpty(listconsultant) Then listconsultant = "Not specified"
        If String.IsNullOrEmpty(endoscopists) Then endoscopists = "Not specified"
        If String.IsNullOrEmpty(nurses) Then nurses = "Not specified"

        ListConsultantLabel.Text = listconsultant
        EndoscopistsLabel.Text = endoscopists
        NursesLabel.Text = nurses
    End Sub

    Public Sub LoadStaffLabels()
        Dim listconsultant As String = ""
        Dim endoscopists As String = ""
        Dim nurses As String = ""

        If Session(Constants.SESSION_LISTCON_TEXT) IsNot Nothing AndAlso CStr(Session(Constants.SESSION_LISTCON_TEXT)) <> "" Then
            listconsultant = CStr(Session(Constants.SESSION_LISTCON_TEXT))
        End If

        'endoscopists = CStr(Session(Constants.SESSION_ENDO1_TEXT)) _
        '    & IIf(Session(Constants.SESSION_ENDO2_TEXT) <> "", _
        '          ", " & CStr(Session(Constants.SESSION_ENDO2_TEXT)), _
        '          "")
        If Session(Constants.SESSION_ENDO1_TEXT) IsNot Nothing AndAlso CStr(Session(Constants.SESSION_ENDO1_TEXT)) <> "" Then
            endoscopists = CStr(Session(Constants.SESSION_ENDO1_TEXT))
        End If
        If Session(Constants.SESSION_ENDO2_TEXT) IsNot Nothing AndAlso CStr(Session(Constants.SESSION_ENDO2_TEXT)) <> "" Then
            If endoscopists <> "" Then
                endoscopists = endoscopists & ", " & CStr(Session(Constants.SESSION_ENDO2_TEXT))
            Else
                endoscopists = CStr(Session(Constants.SESSION_ENDO2_TEXT))
            End If
        End If

        If Session(Constants.SESSION_NURSE1_TEXT) IsNot Nothing AndAlso CStr(Session(Constants.SESSION_NURSE1_TEXT)) <> "" Then
            nurses = CStr(Session(Constants.SESSION_NURSE1_TEXT))
        End If
        If CStr(Session(Constants.SESSION_NURSE2_TEXT)) <> "" Then
            If nurses <> "" Then
                nurses = nurses & ", " & CStr(Session(Constants.SESSION_NURSE2_TEXT))
            Else
                nurses = CStr(Session(Constants.SESSION_NURSE2_TEXT))
            End If
        End If
        If CStr(Session(Constants.SESSION_NURSE3_TEXT)) <> "" Then
            If nurses <> "" Then
                nurses = nurses & ", " & CStr(Session(Constants.SESSION_NURSE3_TEXT))
            Else
                nurses = CStr(Session(Constants.SESSION_NURSE3_TEXT))
            End If
        End If

        If Not String.IsNullOrEmpty(listconsultant) Then
            ListConsultantLabel.Text = listconsultant
        Else
            ListConsultantLabel.Text = "Not Specified"
        End If
        If Not String.IsNullOrEmpty(endoscopists) Then
            EndoscopistsLabel.Text = endoscopists
        Else
            EndoscopistsLabel.Text = "Not Specified"
        End If
        If Not String.IsNullOrEmpty(nurses) Then
            NursesLabel.Text = nurses
        Else
            NursesLabel.Text = "Not Specified"
        End If
    End Sub

    'Protected Sub cboListConsultant_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles cboListConsultant.SelectedIndexChanged
    '    Session("StaffChanged") = True
    '    If cboListConsultant.SelectedIndex <> 0 Then
    '        Session(Constants.SESSION_LISTCON) = cboListConsultant.SelectedValue
    '        Session(Constants.SESSION_LISTCON_TEXT) = cboListConsultant.SelectedItem.Text
    '    Else
    '        Session(Constants.SESSION_LISTCON) = ""
    '        Session(Constants.SESSION_LISTCON_TEXT) = ""
    '    End If
    'End Sub

    'Protected Sub cboEndo1_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles cboEndo1.SelectedIndexChanged
    '    Session("StaffChanged") = True
    '    If cboEndo1.SelectedIndex <> 0 Then
    '        Session(Constants.SESSION_ENDO1) = cboEndo1.SelectedValue
    '        Session(Constants.SESSION_ENDO1_TEXT) = cboEndo1.SelectedItem.Text
    '    Else
    '        Session(Constants.SESSION_ENDO1) = ""
    '        Session(Constants.SESSION_ENDO1_TEXT) = ""
    '    End If
    'End Sub

    'Protected Sub cboEndo2_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles cboEndo2.SelectedIndexChanged
    '    Session("StaffChanged") = True
    '    If cboEndo2.SelectedIndex <> 0 Then
    '        Session(Constants.SESSION_ENDO2) = cboEndo2.SelectedValue
    '        Session(Constants.SESSION_ENDO2_TEXT) = cboEndo2.SelectedItem.Text
    '    Else
    '        Session(Constants.SESSION_ENDO2) = ""
    '        Session(Constants.SESSION_ENDO2_TEXT) = ""
    '    End If
    'End Sub

    'Protected Sub cboNurse1_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles cboNurse1.SelectedIndexChanged
    '    Session("StaffChanged") = True
    '    If cboNurse1.SelectedIndex <> 0 Then
    '        Session(Constants.SESSION_NURSE1) = cboNurse1.SelectedValue
    '        Session(Constants.SESSION_NURSE1_TEXT) = cboNurse1.SelectedItem.Text
    '    Else
    '        Session(Constants.SESSION_NURSE1) = ""
    '        Session(Constants.SESSION_NURSE1_TEXT) = ""
    '    End If
    'End Sub

    'Protected Sub cboNurse2_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles cboNurse2.SelectedIndexChanged
    '    Session("StaffChanged") = True
    '    If cboNurse2.SelectedIndex <> 0 Then
    '        Session(Constants.SESSION_NURSE2) = cboNurse2.SelectedValue
    '        Session(Constants.SESSION_NURSE2_TEXT) = cboNurse2.SelectedItem.Text
    '    Else
    '        Session(Constants.SESSION_NURSE2) = ""
    '        Session(Constants.SESSION_NURSE2_TEXT) = ""
    '    End If
    'End Sub

    'Protected Sub cboNurse3_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles cboNurse3.SelectedIndexChanged
    '    Session("StaffChanged") = True
    '    If cboNurse3.SelectedIndex <> 0 Then
    '        Session(Constants.SESSION_NURSE3) = cboNurse3.SelectedValue
    '        Session(Constants.SESSION_NURSE3_TEXT) = cboNurse3.SelectedItem.Text
    '    Else
    '        Session(Constants.SESSION_NURSE3) = ""
    '        Session(Constants.SESSION_NURSE3_TEXT) = ""
    '    End If
    'End Sub

    Protected Sub SummaryObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryObjectDataSource.Selecting
        e.InputParameters("procId") = CStr(Session("ProcId"))
    End Sub

    Protected Sub SummaryListView_ItemCreated(sender As Object, e As ListViewItemEventArgs) Handles SummaryListView.ItemCreated
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!NodeSummary) Then
                e.Item.Visible = False
            ElseIf CStr(drItem!NodeSummary) = "" Then
                e.Item.Visible = False
            End If
        End If
    End Sub

    Public Sub SetButtonStyle()
        Dim da As New DataAccess
        Dim dtRec As DataTable
        Dim recs As New List(Of String)

        dtRec = da.GetRecordCountOfOtherData(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        recs = (From dr In dtRec.AsEnumerable()
                   Select LCase(CStr(dr("Identifier")))).ToList()

        For Each btn As RadButton In paneButtons.Controls.OfType(Of RadButton)()
            If recs.Contains(btn.Text.ToLower) Then
                btn.Font.Bold = True
            Else
                btn.Font.Bold = False
            End If
        Next

        'If Session("BoldButtons") Is Nothing Then
        '    Session("BoldButtons") = New List(Of String)
        'Else
        '    Dim dtRec As DataTable = da.GetRecordCountOfOtherData(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        '    Dim secs = (From dr In dtRec.AsEnumerable()
        '               Select CStr(dr("Identifier"))).ToList()
        '    Session("BoldButtons") = secs
        'End If

        'If Session("BoldButtons") IsNot Nothing Then
        '    Dim boldbtns As List(Of String) = DirectCast(Session("BoldButtons"), List(Of String))

        '    For Each btn As RadButton In paneButtons.Controls.OfType(Of RadButton)()
        '        If boldbtns.Contains(btn.Text) Then
        '            btn.Font.Bold = True
        '        End If
        '    Next
        'End If
    End Sub

    Protected Sub SaveStaffButton_Click(sender As Object, e As EventArgs) Handles SaveStaffButton.Click

        Try

            Dim da As New DataAccess
            da.UpdateProcedureStaff(CInt(Session(Constants.SESSION_PROCEDURE_ID)), _
                                    IIf(ListConsultantComboBox.SelectedValue = "", 0, ListConsultantComboBox.SelectedValue), _
                                    IIf(Endo1ComboBox.SelectedValue = "", 0, Endo1ComboBox.SelectedValue), _
                                    IIf(Endo2ComboBox.SelectedValue = "", 0, Endo2ComboBox.SelectedValue), _
                                    IIf(Nurse1ComboBox.SelectedValue = "", 0, Nurse1ComboBox.SelectedValue), _
                                    IIf(Nurse2ComboBox.SelectedValue = "", 0, Nurse2ComboBox.SelectedValue), _
                                    IIf(Nurse3ComboBox.SelectedValue = "", 0, Nurse3ComboBox.SelectedValue))

            If ListConsultantComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_LISTCON) = ListConsultantComboBox.SelectedValue
                Session(Constants.SESSION_LISTCON_TEXT) = ListConsultantComboBox.SelectedItem.Text
            Else
                Session(Constants.SESSION_LISTCON) = ""
                Session(Constants.SESSION_LISTCON_TEXT) = ""
            End If

            If Endo1ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_ENDO1) = Endo1ComboBox.SelectedValue
                Session(Constants.SESSION_ENDO1_TEXT) = Endo1ComboBox.SelectedItem.Text
            Else
                Session(Constants.SESSION_ENDO1) = ""
                Session(Constants.SESSION_ENDO1_TEXT) = ""
            End If

            If Endo2ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_ENDO2) = Endo2ComboBox.SelectedValue
                Session(Constants.SESSION_ENDO2_TEXT) = Endo2ComboBox.SelectedItem.Text
            Else
                Session(Constants.SESSION_ENDO2) = ""
                Session(Constants.SESSION_ENDO2_TEXT) = ""
            End If

            If Nurse1ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_NURSE1) = Nurse1ComboBox.SelectedValue
                Session(Constants.SESSION_NURSE1_TEXT) = Nurse1ComboBox.SelectedItem.Text
            Else
                Session(Constants.SESSION_NURSE1) = ""
                Session(Constants.SESSION_NURSE1_TEXT) = ""
            End If

            If Nurse2ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_NURSE2) = Nurse2ComboBox.SelectedValue
                Session(Constants.SESSION_NURSE2_TEXT) = Nurse2ComboBox.SelectedItem.Text
            Else
                Session(Constants.SESSION_NURSE2) = ""
                Session(Constants.SESSION_NURSE2_TEXT) = ""
            End If

            If Nurse3ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_NURSE3) = Nurse3ComboBox.SelectedValue
                Session(Constants.SESSION_NURSE3_TEXT) = Nurse3ComboBox.SelectedItem.Text
            Else
                Session(Constants.SESSION_NURSE3) = ""
                Session(Constants.SESSION_NURSE3_TEXT) = ""
            End If

            LoadStaffLabels()

            'Page.ClientScript.RegisterStartupScript(Me.GetType(), "1", "closeStaffWindow();", True)
            'ScriptManager.RegisterStartupScript(EditStaffWindow, EditStaffWindow.GetType(), "2", "closeStaffWindow();", True)
            'ScriptManager.RegisterStartupScript(Me, Me.GetType(), "3", "alert(2);", True)
            'ScriptManager.RegisterStartupScript(RadScriptManager1, RadScriptManager1.GetType(), "4", "closeStaffWindow();", True)

            'If (Not Page.ClientScript.IsStartupScriptRegistered("aa")) Then
            'Page.ClientScript.RegisterStartupScript(Me.GetType(), "aa", "alert(2);", True)
            'End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while updating procedure staff.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class

