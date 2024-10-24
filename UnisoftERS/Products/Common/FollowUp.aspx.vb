Imports Telerik.Web.UI


Partial Class Products_Common_FollowUp
    Inherits PageBase

    Public Sub New()

    End Sub

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If (Not IsPostBack) Then
            Call initForm()
        End If
    End Sub

    Protected Sub Page_PreLoad(sender As Object, e As System.EventArgs) Handles Me.PreLoad
        'Call uniAdaptor.IsAuthenticated()
    End Sub

    Protected Sub initForm()
        cmdAccept.Text = IIf(Session("AdvancedMode") = True, "Save Record", "Save & Close")

        Call loadReviewPeriod()
        Call loadFurtherProc()
    End Sub

    Protected Sub loadReviewPeriod()
        'Dim sSQL As String = "SELECT * FROM [Lists] WHERE [List description] = 'Review period' AND [Suppressed] = 0 AND [List item no] <> 0 ORDER BY [List item no] ASC;"
        'With cboReviewPeriod
        '    .Items.Clear()

        '    .DataSource = uniAdaptor.GetDataTable(sSQL)
        '    .DataTextField = "List item text"
        '    .DataValueField = "List item no"
        '    .DataBind()

        '    '.Items.Insert(0, New RadComboBoxItem(" - Select ward"))
        'End With

        'With cboReviewIn
        '    .Items.Clear()

        '    .DataSource = uniAdaptor.GetDataTable(sSQL)
        '    .DataTextField = "List item text"
        '    .DataValueField = "List item no"
        '    .DataBind()

        '    '.Items.Insert(0, New RadComboBoxItem(" - Select ward"))
        'End With
    End Sub

    Protected Sub loadFurtherProc()
        'Dim sSQL As String = "SELECT * FROM [Lists] WHERE [List description] = 'Further procedure' AND [Suppressed] = 0 AND [List item no] <> 0 ORDER BY [List item no] ASC;"
        'With cboFurtherProcs
        '    .Items.Clear()

        '    .DataSource = uniAdaptor.GetDataTable(sSQL)
        '    .DataTextField = "List item text"
        '    .DataValueField = "List item no"
        '    .DataBind()

        '    .Items.Insert(0, New RadComboBoxItem("(None)"))
        'End With
    End Sub

    'Protected Sub saveRecord()
    '    'Call uniAdaptor.saveOtherData(validateCheckboxes)
    '    Call uniAdaptor.saveOtherDataDEMO("PP_Followup", "No further follow up. Further procedure(s): upper endoscopy in 1 day.")
    '    Call uniAdaptor.setButtonState(Session("PageID"), True)

    '    Select Case Session("AdvancedMode")
    '        Case True
    '            Call InitMsg()
    '        Case False
    '            Response.Redirect("~/Products/PatientProcedure.aspx")
    '    End Select
    'End Sub

    Protected Sub cancelRecord()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

    Protected Sub InitMsg()
        If Session("UpdateDBFailed") = True Then Exit Sub
        Utilities.SetNotificationStyle(RadNotification1)
        RadNotification1.Show()
    End Sub

    Protected Function validateCheckboxes() As String
        Dim selectedValues As String = ""

        selectedValues = IIf(chkNoFurtherTests.Checked = True, chkNoFurtherTests.Text & ", ", "")
        selectedValues = selectedValues & IIf(CheckBox1.Checked = True, CheckBox1.Text & ", ", "")
        selectedValues = selectedValues & IIf(RadTextBox1.Text <> "", RadTextBox1.Text, "")

        selectedValues = Trim(selectedValues)
        If Right(selectedValues, 1) = "," Then
            selectedValues = Mid(selectedValues, 1, Len(selectedValues) - 1)
        End If

        validateCheckboxes = selectedValues
    End Function

    Protected Sub cmdAccept_Click(sender As Object, e As EventArgs) Handles cmdAccept.Click
        Dim da As New DataAccess
        Dim dummyText As String

        dummyText = "Morbi natoque felis elit. Est eros consectetuer taciti sem venenatis diam mollis id Malesuada convallis etiam lobortis lectus. Pellentesque orci."
        da.InsertDummyText(CStr(Session(Constants.SESSION_PATIENT_COMBO_ID)), CInt(Session(Constants.SESSION_EPISODE_NO)), "ERS_Procedures", "PP_Followup", dummyText,
                           CInt(Session(Constants.SESSION_PROCEDURE_ID)), "Follow up")

        'uniAdaptor.setButtonState(Session("PageID"), True)

        Select Case Session("AdvancedMode")
            Case True
                InitMsg()
            Case False
                Response.Redirect("~/Products/PatientProcedure.aspx", False)
        End Select

        ' Refresh the left side Summary panel that's on the master page
        Dim c As Control = FindAControl(Me.Master.Controls, "SummaryListView")
        If c IsNot Nothing Then
            Dim lvSummary As ListView = DirectCast(c, ListView)
            lvSummary.DataBind()
        End If
        

        DirectCast(Session("BoldButtons"), List(Of String)).Add("Follow up")
        Me.Master.SetButtonStyle()
    End Sub
End Class
