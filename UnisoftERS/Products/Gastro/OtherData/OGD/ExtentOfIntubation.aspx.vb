Imports Telerik.Web.UI

Partial Class Products_Gastro_OtherData_OGD_ExtentOfIntubation
    Inherits PageBase

    Protected Property trainEE_Exist() As Boolean
        Get
            Return CBool(ViewState("trainEE_Exist"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("trainEE_Exist") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            'SaveButton.Text = IIf(Session("AdvancedMode") = True, "Save Record", "Save & Close")
            ProcedureTypeIdHiddenField.Value = Session(Constants.SESSION_PROCEDURE_TYPE)
            Dim da As New OtherData
            Dim dtTr As DataTable = da.GetTrainerTraineeEndo(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            Dim drEndoscopist As DataRow = dtTr.Rows(0)
            'Dim trainee_Exist As Boolean

            trainEE_Exist = IIf(IsDBNull(dtTr.Rows(0).Item("TraineeEndoscopist")), False, True)

            LoadExtentComboBox()

            Dim dtIn As DataTable = da.GetUpperGIExtentOfIntubation(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtIn.Rows.Count > 0 Then
                PopulateData(dtIn.Rows(0))
            Else
                If trainEE_Exist Then 
                    'SuccessfulRadioButton.Checked = True
                Else
                    TrainerSuccessfulRadioButton.Checked = True
                End If
            End If

            If trainEE_Exist Then
                radProcedureExtent.Tabs(0).Text = CStr(drEndoscopist("TraineeEndoscopist")) '"TrainEE: " & 
                radProcedureExtent.Tabs(1).Text = CStr(drEndoscopist("TrainerEndoscopist")) '"TrainER: " & 
                radProcedureExtent.SelectedIndex = 0
            Else
                radProcedureExtent.Tabs(0).Visible = False
                radProcedureExtent.SelectedIndex = 1           '### Zero gets Hidden.. 1 becomes visible; 0=TrainEE; 1=TrainEE   
                radMultiExtentPageViews.SelectedIndex = 1
                JmanoeuvreRequiredFieldValidator.Enabled = False
                TrainerJmanoeuvreRequiredFieldValidator.ErrorMessage = "Was J manoeuvre carried out?"
                ExtentRequiredFieldValidator.Enabled = False
                FailedOtherRequiredFieldValidator.Enabled = False

            End If
        End If

        'MH added on 22 Oct 2021  : TFS 1536 ENT J Manouver
        If ProcedureTypeIdHiddenField.Value = 6 Or ProcedureTypeIdHiddenField.Value = 8 Then
            Dim adeTest = 0

            JMan.Visible = False
        JMan2.Visible = False
        Else
        JMan.Visible = True
        JMan2.Visible = True
        End If

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, radProcedureExtent, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, RadNotification1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(CancelButton, radProcedureExtent, RadAjaxLoadingPanel1)
    End Sub

    'Protected Sub Page_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
    '    uniAdaptor.IsAuthenticated()
    'End Sub

    Private Sub PopulateData(drIn As DataRow)
        '### All NULLs checked (IsNull())  in the StoredProc!
        If trainEE_Exist Then
            If CInt(drIn("CompletionStatus")) = 1 Then
                SuccessfulRadioButton.Checked = True
            ElseIf CInt(drIn("CompletionStatus")) = 2 Then
                FailedRadioButton.Checked = True
            End If
            ExtentComboBox.SelectedValue = CInt(drIn("Extent"))

            If CInt(drIn("FailureReason")) = 1 Then
                FailedIntubationRadioButton.Checked = True
            ElseIf CInt(drIn("FailureReason")) = 2 Then
                OesoStrictureRadioButton.Checked = True
            ElseIf CInt(drIn("FailureReason")) = 3 Then
                FailedOtherRadioButton.Checked = True
            ElseIf CInt(drIn("FailureReason")) = 4 Then
                AbandonedRadioButton.Checked = True
            End If

            If drIn("Jmanoeuvre") <> 0 Then JmanoeuvreRadioButtonList.SelectedValue = CInt(drIn("Jmanoeuvre"))

            FailedOtherTextBox.Text = CStr(drIn("FailureReasonOther"))
        Else
            JmanoeuvreRadioButtonList.SelectedValue = 0 '### Just to escape the jQuery Validation.. select to empty string with value '0'
        End If

        'Trainer
        If CInt(drIn("TrainerCompletionStatus")) > 0 Then
            If CInt(drIn("TrainerCompletionStatus")) = 1 Then
                TrainerSuccessfulRadioButton.Checked = True
            ElseIf CInt(drIn("TrainerCompletionStatus")) = 2 Then
                TrainerFailedRadioButton.Checked = True
            End If
        End If

        TrainerExtentComboBox.SelectedValue = CInt(drIn("TrainerExtent"))

        If CInt(drIn("TrainerFailureReason") > 0) Then
            Select Case CInt(drIn("TrainerFailureReason"))
                Case 1
                    TrainerFailedIntubationRadioButton.Checked = True
                Case 2
                    TrainerOesoStrictureRadioButton.Checked = True
                Case 3
                    TrainerFailedOtherRadioButton.Checked = True
                Case 4
                    TrainerAbandonedRadioButton.Checked = True
            End Select
        End If



        If drIn("TrainerJmanoeuvre") <> 0 Then TrainerJmanoeuvreRadioButtonList.SelectedValue = CInt(drIn("TrainerJmanoeuvre"))

        TrainerFailedOtherTextBox.Text = CStr(drIn("TrainerFailureReasonOther"))

        Using lm As New AuditLogManager
            lm.WriteActivityLog(EVENT_TYPE.SelectRecord, "View UpperGI ExtentOfIntubation")
        End Using

    End Sub

    Private Enum FailedReason
        Intubation = 1
        Stricture = 2
        Other = 3
        Abandoned = 4
    End Enum

    Private Sub SaveRecord(isSaveAndClose As Boolean)
        Dim completionStatus_EE As Integer = 0,
            failureReason_EE As Integer = 0,
            Jmanoeuvre_EE As Integer = 0,
            Extent_EE As Integer = 0

        Dim CompletionStatus_ER As Integer,
            FailureReason_ER As Integer,
            Jmanoeuvre_ER As Integer,
            Extent_ER As Integer

        If trainEE_Exist Then
            If SuccessfulRadioButton.Checked Then
                completionStatus_EE = 1
                Extent_EE = ExtentComboBox.SelectedValue
            ElseIf FailedRadioButton.Checked Then
                completionStatus_EE = 2

                If FailedIntubationRadioButton.Checked Then
                    failureReason_EE = FailedReason.Intubation
                ElseIf OesoStrictureRadioButton.Checked Then
                    failureReason_EE = FailedReason.Stricture
                ElseIf FailedOtherRadioButton.Checked Then
                    failureReason_EE = FailedReason.Other
                ElseIf AbandonedRadioButton.Checked Then
                    failureReason_EE = FailedReason.Abandoned
                End If
            End If

            If JmanoeuvreRadioButtonList.SelectedValue = "" Then
                Jmanoeuvre_EE = Nothing
            Else
                Jmanoeuvre_EE = JmanoeuvreRadioButtonList.SelectedValue
            End If

        End If

        'Trainer
        If TrainerSuccessfulRadioButton.Checked Then
            CompletionStatus_ER = 1
            Extent_ER = IIf(String.IsNullOrEmpty(TrainerExtentComboBox.SelectedValue), 0, TrainerExtentComboBox.SelectedValue)
            'Extent_ER = IIf(FailureReason_ER > 0, 0, TrainerExtentComboBox.SelectedValue) '### If Failure Reason Exist- then NO ExtentOfIntibation!
        ElseIf TrainerFailedRadioButton.Checked Then
            CompletionStatus_ER = 2

            If TrainerFailedIntubationRadioButton.Checked Then
                FailureReason_ER = FailedReason.Intubation
            ElseIf TrainerOesoStrictureRadioButton.Checked Then
                FailureReason_ER = FailedReason.Stricture
            ElseIf TrainerFailedOtherRadioButton.Checked Then
                FailureReason_ER = FailedReason.Other
            ElseIf TrainerAbandonedRadioButton.Checked Then
                FailureReason_ER = FailedReason.Abandoned
            End If
        End If

        Jmanoeuvre_ER = Utilities.GetRadioValue(TrainerJmanoeuvreRadioButtonList)

        Try
            Dim da As New OtherData
            da.SaveUpperGIExtentOfIntubation(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                             completionStatus_EE,
                                             Extent_EE,
                                             failureReason_EE,
                                             FailedOtherTextBox.Text,
                                             Jmanoeuvre_EE,
                                             CompletionStatus_ER,
                                             Extent_ER,
                                             FailureReason_ER,
                                             TrainerFailedOtherTextBox.Text,
                                             Jmanoeuvre_ER,
                                             isSaveAndClose)


            Using lm As New AuditLogManager
                lm.WriteActivityLog(EVENT_TYPE.Update, "UPDATE UpperGI ExtentOfIntubation")
            End Using

            If isSaveAndClose Then
                ExitForm()
                Me.Master.SetButtonStyle()
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Extent of Intubation.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub SaveOnly_Click(sender As Object, e As EventArgs) Handles SaveOnly.Click
        SaveRecord(False)
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        ExitForm()
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

    Private Sub LoadExtentComboBox()
        Dim procedureTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        Dim lookupSource As String = IIf(procedureTypeId = ProcedureType.Gastroscopy, "Extent of Intubation OGD", "Extent of Intubation")

        'Dim dtExtentLookupList As DataTable = DataAdapter.GetDropDownList(lookupSource) '### Re-use as both Dropdowns' Source!
        'Utilities.LoadDropdown(ExtentComboBox, dtExtentLookupList, "ListItemText", "ListItemNo", Nothing)
        'Utilities.LoadDropdown(TrainerExtentComboBox, dtExtentLookupList, "ListItemText", "ListItemNo", Nothing)

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                    {ExtentComboBox, lookupSource},
                    {TrainerExtentComboBox, lookupSource}
            })

        Select Case procedureTypeId
            Case ProcedureType.Gastroscopy, ProcedureType.Transnasal
                If trainEE_Exist Then 
                    'ExtentComboBox.FindItemByText("D2").Selected = True
                Else 
                    TrainerExtentComboBox.FindItemByText("D2").Selected = True
                End If
            Case ProcedureType.Antegrade
                If trainEE_Exist Then 
                    'ExtentComboBox.FindItemByText("Proximal Ileum").Selected = True
                Else 
                    TrainerExtentComboBox.FindItemByText("Proximal Ileum").Selected = True
                End If
        End Select
    End Sub
End Class
