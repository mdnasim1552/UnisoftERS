Imports Telerik.Web.UI


Partial Class Products_Common_Rx
    Inherits PageBase

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
    End Sub

    'Protected Sub saveRecord()
    '    'Call uniAdaptor.saveOtherData(validateCheckboxes)
    '    Call uniAdaptor.saveOtherDataDEMO("PP_Rx", "Please be kind enough to prescribe Ciprofloxacin 250 mg oral.")
    '    Call uniAdaptor.setButtonState(Session("PageID"), True)

    '    Select Case Session("AdvancedMode")
    '        Case True
    '            'Call InitMsg()

    '        Case False
    '            Response.Redirect("~/Products/PatientProcedure.aspx")
    '    End Select
    'End Sub

    Protected Sub cancelRecord()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

    Protected Sub cmdAccept_Click(sender As Object, e As EventArgs) Handles cmdAccept.Click
        'Dim da As New DataAccess
        'Dim dummyText As String

        'dummyText = "Cras feugiat nascetur penatibus erat pulvinar donec mattis natoque."
        'da.InsertDummyText(CStr(Session(Constants.SESSION_PATIENT_COMBO_ID)), CInt(Session("KeyEpiNo")), "ERS_Procedures", "PP_Rx", dummyText, _
        '                   CInt(Session(Constants.SESSION_PROCEDURE_ID)), "Rx")

        ''uniAdaptor.setButtonState(Session("PageID"), True)

        'Select Case Session("AdvancedMode")
        '    Case True
        '        InitMsg()
        '    Case False
        '        Response.Redirect("~/Products/PatientProcedure.aspx")
        'End Select

        '' Refresh the left side Summary panel that's on the master page
        'If Me.Master.FindControl("SummaryListView") IsNot Nothing Then
        '    Dim lvSummary As ListView = DirectCast(Master.FindControl("SummaryListView"), ListView)
        '    lvSummary.DataBind()
        'End If

        'DirectCast(Session("BoldButtons"), List(Of String)).Add("Rx")
        'Me.Master.SetButtonStyle()
    End Sub

    Protected Sub InitMsg()
        If Session("UpdateDBFailed") = True Then Exit Sub

        Utilities.SetNotificationStyle(RadNotification1)
        RadNotification1.Show()
    End Sub
End Class
