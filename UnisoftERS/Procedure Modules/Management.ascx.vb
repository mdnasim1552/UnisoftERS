Imports Telerik.Web.UI
Imports ERS.Data
Imports Telerik.Web.UI.PivotGrid.DataProviders

Public Class Management
    Inherits ProcedureControls
    Private Shared procType As Integer
    Public helpDesk = ConfigurationManager.AppSettings("Unisoft.Helpdesk")  'added by Ferdowsi
    Protected Property thisIsA_NewRecord() As Boolean
        Get
            Return CBool(ViewState("thisIsA_NewRecord"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("thisIsA_NewRecord") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender

        If Not Page.IsPostBack Then
            Dim da As New OtherData
            Dim UpperGIQA_Record As ERS.Data.ERS_UpperGIQA = da.UpperGIQA_Find(Convert.ToInt32(Session(Constants.SESSION_PROCEDURE_ID)))

            If UpperGIQA_Record IsNot Nothing Then
                PopulateData(UpperGIQA_Record)
                thisIsA_NewRecord = False
            Else
                PopulateDefaultManagement()
                thisIsA_NewRecord = True
            End If
        End If

    End Sub

    Private Sub PopulateData(qa As ERS_UpperGIQA)
        ' Management Section
        ManagementNoneCheckBox.Checked = qa.ManagementNone
        PulseOximetryCheckBox.Checked = qa.PulseOximetry
        IVAccessCheckBox.Checked = qa.IVAccess
        IVAntibioticsCheckBox.Checked = qa.IVAntibiotics
        OxygenationCheckBox.Checked = qa.Oxygenation
        OxygenationMethodRadioButtonList.SelectedValue = qa.OxygenationMethod
        'If Not IsDBNull(drQa("OxygenationFlowRate")) Then OxygenationFlowRateTextBox.Text = CStr(drQa("OxygenationFlowRate"))
        If qa.OxygenationFlowRate.HasValue Then OxygenationFlowRateTextBox.Text = qa.OxygenationFlowRate

        ContinuousECGCheckBox.Checked = qa.ContinuousECG
        BPCheckBox.Checked = qa.BP
        If qa.BPSystolic.HasValue Then BPSysTextBox.Text = qa.BPSystolic
        If qa.BPDiastolic.HasValue Then BPDiaTextBox.Text = qa.BPDiastolic

        ManagementOtherCheckBox.Checked = (Not String.IsNullOrWhiteSpace(qa.ManagementOtherText))
        ManagementOtherTextBox.Text = qa.ManagementOtherText


    End Sub

    Private Sub UpperGIQA_Record_Fill(UpperGIQA_Record As ERS.Data.ERS_UpperGIQA)
        Dim oxygenationFlowRate As Nullable(Of Decimal) = Nothing
        Dim systolicBP As Nullable(Of Decimal) = Nothing
        Dim diastolicBP As Nullable(Of Decimal) = Nothing

        If OxygenationFlowRateTextBox.Text <> "" Then oxygenationFlowRate = CDec(OxygenationFlowRateTextBox.Text)

        With UpperGIQA_Record
            .ManagementNone = ManagementNoneCheckBox.Checked
            .PulseOximetry = PulseOximetryCheckBox.Checked
            .IVAccess = IVAccessCheckBox.Checked
            .IVAntibiotics = IVAntibioticsCheckBox.Checked
            .Oxygenation = OxygenationCheckBox.Checked
            .OxygenationMethod = Utilities.GetRadioValue(OxygenationMethodRadioButtonList)
            .OxygenationFlowRate = oxygenationFlowRate
            .ContinuousECG = ContinuousECGCheckBox.Checked
            .BP = BPCheckBox.Checked
            .BPSystolic = systolicBP
            .BPDiastolic = diastolicBP
            .ManagementOther = ManagementOtherCheckBox.Checked
            .ManagementOtherText = ManagementOtherTextBox.Text
        End With
    End Sub

    Private Sub SaveRecord(isSaveAndClose As Boolean)
        Dim da As New OtherData
        Dim UpperGIQA_Record As ERS.Data.ERS_UpperGIQA

        '## If this is a new Record!  
        If thisIsA_NewRecord Then
            UpperGIQA_Record = New ERS_UpperGIQA()
        Else
            UpperGIQA_Record = da.UpperGIQA_Find(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        End If

        Try
            '## Need to Fill the Class object and then Pass to EntityFramework to Save it..!!
            UpperGIQA_Record_Fill(UpperGIQA_Record)

            '### Insert/Update the Record
            da.UpperGI_Save(UpperGIQA_Record, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

        Catch ex As Exception
            Throw ex
        End Try
    End Sub



    'Private Sub bindData()
    '    Try
    '        'databing repeater
    '        Dim dbResult = DataAdapter.LoadManagement()
    '        Dim management = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = 0)

    '        rptManagement.DataSource = management.CopyToDataTable
    '        rptManagement.DataBind()

    '        'load procedure Comorbidity
    '        Dim procedureManagement = DataAdapter.GetProcedureManagement(Session(Constants.SESSION_PROCEDURE_ID))

    '        For Each itm As RepeaterItem In rptManagement.Items
    '            Dim chk As New CheckBox

    '            For Each ctrl As Control In itm.Controls
    '                If TypeOf ctrl Is CheckBox Then
    '                    chk = CType(ctrl, CheckBox)
    '                End If
    '            Next

    '            If chk IsNot Nothing Then
    '                Dim managementId = CInt(chk.Attributes.Item("data-managementid"))

    '                chk.Checked = procedureManagement.AsEnumerable.Any(Function(x) CInt(x("ManagementId")) = managementId)

    '                'get the checkbox- dataitem as nothing so cant get the values in that way :(
    '                If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = managementId) Then
    '                    Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = managementId)

    '                    'check that none of the child items ids are parent ids of anything else


    '                    'create a dropdown list and bind child items to it
    '                    Dim ddlChildManagement As New RadComboBox
    '                    With ddlChildManagement
    '                        .AutoPostBack = False
    '                        .Skin = "Metro"
    '                        .CssClass = "management-child"
    '                        .Attributes.Add("data-management", managementId)
    '                        .OnClientSelectedIndexChanged = "childManagement_changed"
    '                        If Not chk.Checked Then .Style.Add("display", "none")
    '                    End With


    '                    For Each ci In childItems
    '                        ddlChildManagement.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
    '                    Next
    '                    ddlChildManagement.Items.Insert(0, New RadComboBoxItem("", 0))

    '                    'If True Then
    '                    '    ddlChildComorbidity.Items.Add(New RadComboBoxItem() With {
    '                    '    .Text = "Add new",
    '                    '    .Value = -55,
    '                    '    .ImageUrl = "~/images/icons/add.png",
    '                    '    .CssClass = "comboNewItem"
    '                    '    })
    '                    '    ddlChildComorbidity.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & ddlChildComorbidity.ClientID & "); } else { window.parent.AddNewItemPopUp(" & ddlChildComorbidity.ClientID & ");" & " }")
    '                    'End If

    '                    ddlChildManagement.Sort = RadComboBoxSort.Ascending

    '                    If procedureManagement.AsEnumerable.Any(Function(x) CInt(x("ManagementId")) = managementId And CInt(x("ChildManagementId")) > 0) Then
    '                        Dim childManagementId = (From pi In procedureManagement.AsEnumerable
    '                                                 Where CInt(pi("ManagementId")) = managementId
    '                                                 Select CInt(pi("ChildManagementId"))).FirstOrDefault

    '                        ddlChildManagement.SelectedIndex = ddlChildManagement.Items.FindItemIndexByValue(childManagementId)
    '                    End If

    '                    'add the control to the relevant td
    '                    itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildManagement)


    '                End If
    '            End If
    '        Next

    '        'additional info/other text boxes
    '        If management.AsEnumerable.Any(Function(x) x("AdditionalInfo")) Then
    '            rptManagementAdditionalInfo.DataSource = management.AsEnumerable.Where(Function(x) x("AdditionalInfo")).CopyToDataTable
    '            rptManagementAdditionalInfo.DataBind()
    '        End If

    '        For Each itm As RepeaterItem In rptManagementAdditionalInfo.Items
    '            Dim tb As New RadTextBox

    '            For Each ctrl As Control In itm.Controls
    '                If TypeOf ctrl Is RadTextBox Then
    '                    tb = CType(ctrl, RadTextBox)
    '                End If
    '            Next

    '            If tb IsNot Nothing Then
    '                Dim ManagementId = CInt(tb.Attributes.Item("data-managementid"))

    '                tb.Text = (From si In procedureManagement Where CInt(si("ManagementId")) = ManagementId
    '                           Select si("AdditionalInformation")).FirstOrDefault
    '            End If
    '        Next
    '    Catch ex As Exception
    '        Throw ex
    '    End Try
    'End Sub

    'Protected Sub rptManagement_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
    '    If e.Item.DataItem IsNot Nothing Then
    '        'Other textbox
    '        If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
    '            Dim chk As New CheckBox

    '            For Each ctrl As Control In e.Item.Controls
    '                If TypeOf ctrl Is CheckBox Then
    '                    chk = CType(ctrl, CheckBox)
    '                    chk.CssClass += " management-other-entry-toggle" 'set new classname as original once casuses an autosave
    '                    chk.Attributes.Add("onchange", "checkAndNotifyTextEntry('" & chk.ClientID & "','management')")
    '                End If
    '            Next
    '        End If
    '    End If
    'End Sub

    Protected Sub PopulateDefaultManagement()   'edited by Ferdowsi
        If CBool(HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT)) Then
            ManagementNoneCheckBox.Checked = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_NONE)
            PulseOximetryCheckBox.Checked = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_PULSE_OXIMETRY)
            IVAccessCheckBox.Checked = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_IV_ACCESS)
            IVAntibioticsCheckBox.Checked = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_IV_ANTIBIOTICS)
            OxygenationCheckBox.Checked = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION)
            OxygenationMethodRadioButtonList.SelectedValue = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_METHOD)
            If Not String.IsNullOrWhiteSpace(HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_FLOW_RATE)) Then OxygenationFlowRateTextBox.Text = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_FLOW_RATE)
            ContinuousECGCheckBox.Checked = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_CONTINOUS_ECG)
            BPCheckBox.Checked = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_BP)
            If Not String.IsNullOrWhiteSpace(HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_SYSTOLIC_BP)) Then BPSysTextBox.Text = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_SYSTOLIC_BP)
            If Not String.IsNullOrWhiteSpace(HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_DIASTOLIC_BP)) Then BPDiaTextBox.Text = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_DIASTOLIC_BP)
            If Not String.IsNullOrWhiteSpace(HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_SYSTOLIC_BP)) Then BPSysTextBox.Text = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_SYSTOLIC_BP)
            If Not String.IsNullOrWhiteSpace(HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_DIASTOLIC_BP)) Then BPDiaTextBox.Text = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_DIASTOLIC_BP)
            ManagementOtherCheckBox.Checked = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OTHER)
            ManagementOtherTextBox.Text = HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OTHER_TEXT)
        End If
    End Sub


    'removed savedefault by Ferdowsi


End Class