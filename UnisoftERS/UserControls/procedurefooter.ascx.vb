Imports System.IO
Imports DevExpress.CodeParser
Imports Telerik.Web.UI
Public Class procedurefooter
    Inherits System.Web.UI.UserControl

    Private Shared sCheckRequiredFields As String = String.Empty
    Public Event ShowSummary_Clicked()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        loaded()

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdMainScreen, cmdOtherData, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdPreProcedure, PrintRadNotification, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdProcedure, PrintRadNotification, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdPostProcedure, PrintRadNotification, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdPrint, PrintRadNotification, RadAjaxLoadingPanel1)

        If Not Page.IsPostBack Then
            Dim message = If(Request.QueryString("message") Is Nothing, 0, CInt(Request.QueryString("message")))
            If message = 1 Then
                cmdProcedure_Click(Nothing, Nothing)
            ElseIf message = 2 Then
                cmdPostProcedure_Click(Nothing, Nothing)
            ElseIf message = 3 Then
                cmdPrint_Click(Nothing, Nothing)
            End If
        End If
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdShowReport, cmdShowReport, Nothing, UpdatePanelRenderMode.Inline)
    End Sub

    Sub loaded()
        Dim da As New DataAccess
        SetButtonStyle()
        Dim procedureTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        sCheckRequiredFields = CheckRequiredFields()
        'issue - 1671 start
        Dim opts As New Options()
        Dim CheckProcedureCompleted = opts.CheckProcedureComplete(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

        If CheckProcedureCompleted <> 1 And (procedureTypeId = ProcedureType.Bronchoscopy Or procedureTypeId = ProcedureType.EBUS Or procedureTypeId = 13) Then

            If Request.Url.Segments(Request.Url.Segments.Count - 1) = "Procedure.aspx" Or Request.Url.Segments(Request.Url.Segments.Count - 1) = "PreProcedure.aspx" Or Request.Url.Segments(Request.Url.Segments.Count - 1) = "PostProcedure.aspx" Then
                cmdMainScreen.AutoPostBack = False
                cmdMainScreen.OnClientClicked = "DisplayMessage"
            End If

        End If
        'issue - 1671 end
        If sCheckRequiredFields <> String.Empty Then
            If Request.Url.Segments(Request.Url.Segments.Count - 1) = "Procedure.aspx" Or Request.Url.Segments(Request.Url.Segments.Count - 1) = "PreProcedure.aspx" Or Request.Url.Segments(Request.Url.Segments.Count - 1) = "PostProcedure.aspx" Then
                cmdMainScreen.AutoPostBack = False
                cmdMainScreen.OnClientClicked = "DisplayMessage"
            End If
        End If
    End Sub

    Protected Sub cmdMainScreen_Click(sender As Object, e As System.EventArgs) Handles cmdMainScreen.Click
        Call loadPage("MainScreen")
    End Sub

    Protected Sub loadPage(ByRef pageName As String)
        Dim sPageURL As String = ""
        Dim pageIDX As String = ""

        Session("PageID") = ""
        Session("ProcedureEditTabs") = ProcedureEditTabs.Others

        Dim procedureTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        Select Case pageName
            Case "MainScreen"
                sPageURL = "~/Products/Default.aspx?patient=true"
                pageIDX = ""
                Session("ProcedureEditTabs") = ProcedureEditTabs.Main
            Case "PreProcedure"
                sPageURL = "~/Products/PreProcedure.aspx"
                pageIDX = "1"
                Session("ProcedureEditTabs") = ProcedureEditTabs.PreProcedure
            Case "Procedure"
                sPageURL = "~/Products/Procedure.aspx"
                pageIDX = "1"
                Session("ProcedureEditTabs") = ProcedureEditTabs.Procedure
            Case "PostProcedure"
                sPageURL = "~/Products/PostProcedure.aspx"
                pageIDX = "1"
                Session("ProcedureEditTabs") = ProcedureEditTabs.PostProcedure
            Case "Indications"
                sPageURL = "~/Products/Gastro/OtherData/OGD/Indications.aspx"
                pageIDX = "1"
                Session("ProcedureEditTabs") = ProcedureEditTabs.Indications
            Case "Premed"
                sPageURL = "~/Products/Common/PreMed.aspx"
                'sPageURL = "~/Products/UnderConstruction.aspx"
                'sPageURL = "~/Products/Gastro/OtherData/OGD/Premed.aspx"
                pageIDX = "2"

            Case "Extent/Lim"
                If procedureTypeId = ProcedureType.Gastroscopy Or procedureTypeId = ProcedureType.Antegrade Or procedureTypeId = ProcedureType.EUS_OGD Or procedureTypeId = ProcedureType.Transnasal Then
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

            Case "PatientNotes"
                sPageURL = "~/Products/Gastro/OtherData/OGD/PatientNotes.aspx"
                pageIDX = "10"

            Case "18w"
                'sPageURL = "~/Products/Common/18w.aspx"
                pageIDX = "9"

            Case "Print"
                'sPageURL = "PatientReport.aspx"
                sPageURL = "~/Products/Gastro/OtherData/PrintProcedure.aspx"
                'sPageURL = "~/Products/Default.aspx?CNN=" & Session(Constants.SESSION_CASE_NOTE_NO) & "&Print=yes"
                pageIDX = "10"
                Session("ProcedureEditTabs") = ProcedureEditTabs.ReviewAndPrint
            Case "Abno"
                'sPageURL = "~/Products/Common/AbnoThera3.aspx?xy=" & lblCoords.Value
                'pageIDX = "9"

            Case "Pathology"
                sPageURL = "~/Products/Broncho/OtherData/Pathology.aspx"
                pageIDX = "11"

            Case "Drugs"
                sPageURL = "~/Products/Broncho/OtherData/Drugs.aspx"
                pageIDX = "12"

            Case "Coding"
                sPageURL = "~/Products/Broncho/OtherData/Coding.aspx"
                pageIDX = "13"
        End Select

        Session("PageID") = pageIDX

        Response.Redirect(sPageURL, False)
    End Sub
    'Protected Sub cmdNormalProc_Click(sender As Object, e As System.EventArgs) Handles cmdNormalProc.Click
    '    If Session("StaffChanged") IsNot Nothing Then
    '        If CBool(Session("StaffChanged")) Then
    '            'SaveStaff()
    '        End If
    '    End If
    '    Call loadPage("Diagnoses")
    'End Sub

    Protected Sub cmdPreProcedure_Click(sender As Object, e As System.EventArgs) Handles cmdPreProcedure.Click
        Call loadPage("PreProcedure")
    End Sub


    Protected Sub cmdProcedure_Click(sender As Object, e As System.EventArgs) Handles cmdProcedure.Click
        Dim msg As String = String.Empty

        'only perform required field check if current page is pre procedure, allowing them to come back to this page if they're already passed
        Dim currentPage = Path.GetFileName(Page.AppRelativeVirtualPath)
        If currentPage = "PreProcedure.aspx" Then
            msg = CheckRequiredFields()
        End If
        If msg = String.Empty Then
            Call loadPage("Procedure")
        Else
            Dim errorMessage As String = "The following sections are incomplete:<br />" & msg & "<br /><small>*make sure that any fields requiring further selections or text are also complete</small></br />"

            valDiv.InnerHtml = errorMessage
            focusOnDiv(msg)
            PrintRadNotification.Show()
        End If
    End Sub
    Public Sub focusOnDiv(msg As String)
        Select Case Path.GetFileName(Page.AppRelativeVirtualPath)
            Case "PreProcedure.aspx"
                If msg.Contains("Indications") Then
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#indications"")", True)
                ElseIf msg.Contains("FIT results") Then
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#fitValueResults"")", True)
                ElseIf msg.Contains("Subindications") Then
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#rptSubIndicationsDiv"")", True)
                ElseIf msg.Contains("Anti-coag drugs") Then
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#anticoagdrugs"")", True)
                End If
            Case "Procedure.aspx"
                Dim message = If(Request.QueryString("message") Is Nothing, 0, CInt(Request.QueryString("message")))
                If message = 2 Then
                    If msg.Contains("Procedure discomfort") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#procedurediscomfort""); }, 3000);", True)
                    ElseIf msg.Contains("Extent") Or msg.Contains("JManoevre") Or msg.Contains("Retroflexion") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#extentdiv""); }, 3000);", True)
                    ElseIf msg.Contains("Bowel Prep") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#bowelprep""); }, 3000);", True)
                    ElseIf msg.Contains("Enteroscopy techniques") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#enteroscopytechniques""); }, 3000);", True)
                    ElseIf msg.Contains("Insertion techniques") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#insertiontechniques""); }, 3000);", True)
                    ElseIf msg.Contains("Insufflation") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#insufflation""); }, 3000);", True)
                    ElseIf msg.Contains("Mucosal visualisation") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#mucosalvisualisation""); }, 3000);", True)
                    ElseIf msg.Contains("Procedure drugs") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#proceduredrugs""); }, 5000);", True)
                    ElseIf msg.Contains("Procedure timing") Or msg.Contains("Withdrawal start time") Or msg.Contains("Total withdrawal time") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#ProcTimingsDiv""); }, 3000);", True)
                    ElseIf msg.Contains("Scopes") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#scopes""); }, 3000);", True)
                    ElseIf msg.Contains("Patient Management") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#management""); }, 3000);", True)
                    End If
                Else
                    If msg.Contains("Procedure discomfort") Then
                        ''ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "setTimeout(function() { focusOnDiv(""#procedurediscomfort""); }, 3000);", True)
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#procedurediscomfort"")", True)
                    ElseIf msg.Contains("Extent") Or msg.Contains("JManoevre") Or msg.Contains("Retroflexion") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#extentdiv"")", True)
                    ElseIf msg.Contains("Bowel Prep") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#bowelprep"")", True)
                    ElseIf msg.Contains("Enteroscopy techniques") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#enteroscopytechniques"")", True)
                    ElseIf msg.Contains("Insertion techniques") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#insertiontechniques"")", True)
                    ElseIf msg.Contains("Insufflation") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#insufflation"")", True)
                    ElseIf msg.Contains("Mucosal visualisation") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#mucosalvisualisation"")", True)
                    ElseIf msg.Contains("Procedure drugs") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#proceduredrugs"")", True)
                    ElseIf msg.Contains("Procedure timing") Or msg.Contains("Withdrawal start time") Or msg.Contains("Total withdrawal time") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#ProcTimingsDiv"")", True)
                    ElseIf msg.Contains("Scopes") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#scopes"")", True)
                    ElseIf msg.Contains("Patient Management") Then
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#management"")", True)
                    End If
                End If

            Case "PostProcedure.aspx"
                If msg.Contains("Follow up") Then
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#followUpId"")", True)
                ElseIf msg.Contains("Adverse events") Then
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#adverseevents"")", True)
                ElseIf msg.Contains("RX") Then
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", "focusOnDiv(""#rxId"")", True)
                End If
            Case Else

        End Select
    End Sub

    Protected Sub cmdPostProcedure_Click(sender As Object, e As System.EventArgs) Handles cmdPostProcedure.Click
        Dim msg As String = CheckRequiredFields()

        If msg = String.Empty Then
            Call loadPage("PostProcedure")
        Else
            Dim errorMessage As String = "The following sections are incomplete:<br />" & msg & "<br /><small>*make sure that any fields requiring further selections or text are also complete</small></br />"

            valDiv.InnerHtml = errorMessage
            focusOnDiv(msg)
            PrintRadNotification.Show()
        End If
    End Sub

    Protected Sub cmdPrint_Click(sender As Object, e As System.EventArgs) Handles cmdPrint.Click
        Dim procedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))

        Dim da As New DataAccess
        da.updateProcedureSummary(procedureId)

        Dim opt As New Options()
        Dim msg As String = opt.CheckRequired(procedureId, 0)

        If msg = String.Empty Then
            loadPage("Print")
        Else
            Dim errorMessage As String = "The following sections are incomplete:<br />" & msg & "<small>*make sure that any fields requiring further selections or text are also complete</small></br />"
            'Dim url As String = msg.Split("|")(1)

            'PrintRadNotification.Value = Page.ResolveUrl(url.Replace("..", "~"))
            valDiv.InnerHtml = errorMessage
            focusOnDiv(msg)
            PrintRadNotification.Show()
        End If
    End Sub

    Function CheckRequiredFields() As String
        Dim opt As New Options()
        Dim procedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))

        Dim pageId As Integer = 0
        Select Case Path.GetFileName(Page.AppRelativeVirtualPath)
            Case "PreProcedure.aspx"
                pageId = 1
            Case "Procedure.aspx"
                pageId = 2
            Case "PostProcedure.aspx"
                pageId = 3
            Case Else
                pageId = 0
        End Select
        CheckRequiredFields = opt.CheckRequired(procedureId, pageId)
    End Function

    Public Sub disableButtons()
        Dim bSetState As New Boolean
        bSetState = Session("ButtonState")

        cmdMainScreen.Enabled = IIf(bSetState = True, False, True)
        cmdPreProcedure.Enabled = IIf(bSetState = True, False, True)
    End Sub
    Public Sub SetButtonStyle()
        Dim da As New DataAccess
        Dim dtRec As DataTable
        Dim recs As New List(Of String)

        dtRec = da.GetRecordCountOfOtherData(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        recs = (From dr In dtRec.AsEnumerable()
                Select LCase(CStr(dr("Identifier")))).ToList()

        For Each btn As RadButton In cmdOtherData.Controls.OfType(Of RadButton)()
            Dim btnText As String = btn.Text.ToLower
            If btnText = "normal procedure" Or btnText = "closing statement" Then btnText = "diagnoses" 'As Diagnoses button been renamed to 'Normal procedure' for OGD, Col/Sig
            If btnText = "drugs" Then btnText = "premed"
            If recs.Contains(btnText) Then
                btn.Font.Bold = True
                btn.ForeColor = Drawing.Color.Blue
                'btn.Skin = "Telerik"
                'btn.Primary = True
                btn.ForeColor = System.Drawing.ColorTranslator.FromHtml("#0072C6")
            Else
                'btn.ForeColor = System.Drawing.ColorTranslator.FromHtml("#000000")
                'btn.ForeColor = Drawing.Color.Gray
                btn.Font.Bold = False
            End If
        Next

        SetProcedureEditTabSessionBasedOnURL()

        Select Case Session("ProcedureEditTabs")
            Case ProcedureEditTabs.Main
                'cmdMainScreen.Font.Bold = True
                'If coming from Main Screen to Edit procedure then Session will hold Main value checks url then
                If Request.Url.Segments.Last().ToLower() = "procedure.aspx" Then
                    cmdProcedure.Font.Bold = True
                End If
            Case ProcedureEditTabs.Indications
            Case ProcedureEditTabs.PostProcedure
                cmdPostProcedure.Font.Bold = True
            Case ProcedureEditTabs.PreProcedure
                cmdPreProcedure.Font.Bold = True
            Case ProcedureEditTabs.Procedure
                cmdProcedure.Font.Bold = True
            Case ProcedureEditTabs.ReviewAndPrint
                cmdPrint.Font.Bold = True
            Case ProcedureEditTabs.ShowHideReport
                'cmdShowReport.Font.Bold = True
            Case ProcedureEditTabs.Others
            Case Else
                cmdProcedure.Font.Bold = True
        End Select
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
    Private Sub SetProcedureEditTabSessionBasedOnURL()
        Dim strFileName As String
        strFileName = Request.Url.Segments.Last().ToLower()
        Select Case strFileName
            Case "procedure.aspx"
                Session("ProcedureEditTabs") = ProcedureEditTabs.Procedure
            Case "preprocedure.aspx"
                Session("ProcedureEditTabs") = ProcedureEditTabs.PreProcedure
            Case "postprocedure.aspx"
                Session("ProcedureEditTabs") = ProcedureEditTabs.PostProcedure

        End Select
    End Sub

    Private Sub DeleteProcRadButton_Click(sender As Object, e As EventArgs) Handles DeleteProcRadButton.Click
        If Not CBool(Session("isERSViewer")) Then
            Dim da As New DataAccess
            da.DeleteProcedure(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        End If
        Response.Redirect("~/Products/Default.aspx?patient=true", False)
    End Sub

    Private Sub KeepProcRadButton_Click(sender As Object, e As EventArgs) Handles KeepProcRadButton.Click
        Response.Redirect("~/Products/Default.aspx?patient=true", False)
    End Sub

    Protected Sub cmdShowReport_Click(sender As Object, e As EventArgs)
        'call to update procedure summary
        Dim da As New DataAccess
        da.updateDiagnosesSummary(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        da.updateProcedureSummary(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        RaiseEvent ShowSummary_Clicked()
    End Sub

End Class