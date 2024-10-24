Imports Telerik.Web.UI

Partial Class Products_Gastro_OtherData_OGD_Premed
    Inherits PageBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            'SaveButton.Text = IIf(Session("AdvancedMode") = True, "Save Record", "Save & Close")

            Dim da As New OtherData
            Dim dtIn As DataTable = da.GetUpperGIExtentOfIntubation(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtIn.Rows.Count > 0 Then
                PopulateData(dtIn.Rows(0))
            End If
        End If
    End Sub

    'Protected Sub Page_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
    '    uniAdaptor.IsAuthenticated()
    'End Sub

    Private Sub PopulateData(drIn As DataRow)
        'If CInt(drIn("CompletionStatus")) = 1 Then
        '    SuccessfulRadioButton.Checked = True
        'ElseIf CInt(drIn("CompletionStatus")) = 2 Then
        '    FailedRadioButton.Checked = True
        'End If
        'ExtentComboBox.SelectedValue = CInt(drIn("Extent"))

        'If CInt(drIn("FailureReason")) = 1 Then
        '    FailedIntubationRadioButton.Checked = True
        'ElseIf CInt(drIn("FailureReason")) = 2 Then
        '    OesoStrictureRadioButton.Checked = True
        'ElseIf CInt(drIn("FailureReason")) = 3 Then
        '    FailedOtherRadioButton.Checked = True
        'End If
        'FailedOtherTextBox.Text = CStr(drIn("FailureReasonOther"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Dim da As New OtherData
        Dim completionStatus As Integer
        Dim failureReason As Integer

        'If SuccessfulRadioButton.Checked Then
        '    completionStatus = 1
        'ElseIf FailedRadioButton.Checked Then
        '    completionStatus = 2
        'End If

        'If FailedIntubationRadioButton.Checked Then
        '    failureReason = 1
        'ElseIf OesoStrictureRadioButton.Checked Then
        '    failureReason = 2
        'ElseIf FailedOtherRadioButton.Checked Then
        '    failureReason = 3
        'End If

        Try
            'da.SaveUpperGIExtentOfIntubation(CInt(Session(Constants.SESSION_PROCEDURE_ID)), _
            '                                 completionStatus, _
            '                                 ExtentComboBox.SelectedValue, _
            '                                 failureReason, _
            '                                 FailedOtherTextBox.Text)

            'If CBool(Session("AdvancedMode")) Then
            '    Utilities.SetNotificationStyle(RadNotification1)
            '    RadNotification1.Show()

            '    ' Refresh the left side Summary panel that's on the master page
            '    If Me.Master.FindControl("SummaryListView") IsNot Nothing Then
            '        Dim lvSummary As ListView = DirectCast(Master.FindControl("SummaryListView"), ListView)
            '        lvSummary.DataBind()
            '    End If
            'Else
            ExitForm()
            'End If

            Me.Master.SetButtonStyle()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Extent of Intubation.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        ExitForm()
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub
End Class
