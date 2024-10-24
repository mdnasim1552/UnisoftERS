Imports Telerik.Web.UI

Public Class Products_Gastro_Abnormalities_Common_Lesions
    Inherits SiteDetailsBase

    Public siteId As Integer
    Public procTypeId As Integer

    Protected Sub Products_Gastro_Abnormalities_Colon_Lesions_Load(sender As Object, e As EventArgs) Handles Me.Load
        PolypDetailsRadWindow.VisibleOnPageLoad = False
        siteId = CInt(Request.QueryString("SiteId"))
        procTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        If Not Page.IsPostBack Then
            LoadPage()
        End If
        SetIconClass()
        Dim polyDt = AbnormalitiesDataAdapter.GetLesionsPolypData(siteId)
        Session("CommonPolypDetails") = polyDt
        PolypDetailsRepeater.DataSource = polyDt
        PolypDetailsRepeater.DataBind()
        If Session("CommonPolypDetails") IsNot Nothing AndAlso CType(Session("CommonPolypDetails"), List(Of SitePolyps)).Count > 0 Then
            Session("LeisonNodeColorChange") = 1
        Else
            Session("LeisonNodeColorChange") = 0
        End If
    End Sub

    Private Sub LoadPage()
        Try
            SetControls()
            Dim dtMu As DataTable = AbnormalitiesDataAdapter.GetLesionsData(siteId)
            If dtMu.Rows.Count > 0 Then
                PopulateData(dtMu.Rows(0))
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading lesion data", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading lesion data")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub SetIconClass()

    End Sub

    Private Sub SetControls()
        'removal types
        'removal method
        'lesion type

        For Each c In rgAbnormalities.Controls
            For Each childc In c.Controls
                If TypeOf childc Is RadComboBox Then
                    InsertComboBoxItem(childc)
                End If
            Next
        Next



        'Dim dtTumourTypes = DataAdapter.LoadTumourTypes()
        'SubmucosalTumourTypesRadioButtonList.DataSource = dtTumourTypes
        'SubmucosalTumourTypesRadioButtonList.DataBind()

        'FocalTumourTypesRadioButtonList.DataSource = dtTumourTypes
        'FocalTumourTypesRadioButtonList.DataBind()

        'Select Case procTypeId
        '    Case ProcedureType.Gastroscopy, ProcedureType.EUS_OGD, ProcedureType.Antegrade
        '        Dim dt = DataAdapter.GetSiteRegionDetails(procTypeId, siteId)
        '        Dim area = dt.Rows(0)("Area").ToString

        '        SubmucosalTR.Visible = True
        '        FocalTR.Visible = True

        '        If Not area.ToLower = "stomach" Then
        '            FundicTR.Visible = False
        '        End If

        '    Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy, ProcedureType.Retrograde
        '        SubmucosalTR.Visible = False
        '        FocalTR.Visible = False
        '        FundicTR.Visible = False
        '    Case ProcedureType.ERCP, ProcedureType.EUS_HPB
        '        SubmucosalTR.Visible = False
        '        FocalTR.Visible = False
        '        FundicTR.Visible = False
        '        PolypsTR.Visible = False
        'End Select
    End Sub

    Private Sub InsertComboBoxItem(ctrl As RadComboBox)
        If ctrl.ID.EndsWith("_Removal_ComboBox") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("entire", "1"))
            ctrl.Items.Add(New RadComboBoxItem("piecemeal", "2"))

        ElseIf ctrl.ID.EndsWith("_Removal_Method_ComboBox") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("partial snare", "1"))
            ctrl.Items.Add(New RadComboBoxItem("cold snare", "2"))
            ctrl.Items.Add(New RadComboBoxItem("hot snare", "3"))
            ctrl.Items.Add(New RadComboBoxItem("hot bx", "4"))
            ctrl.Items.Add(New RadComboBoxItem("cold bx", "5"))
            ctrl.Items.Add(New RadComboBoxItem("hot snare by EMR", "6"))
            ctrl.Items.Add(New RadComboBoxItem("cold snare by EMR", "7"))

        ElseIf ctrl.ID.EndsWith("_Type_ComboBox") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("benign", "1"))
            ctrl.Items.Add(New RadComboBoxItem("malignant", "2"))
        End If

        ctrl.Width = "90"
        ctrl.Style("text-align") = "center"
        'ctrl.Enabled = False
        ctrl.CssClass = "abnor_cb1"
    End Sub

    Private Sub PopulateData(drLe As DataRow)

        NoneCheckBox.Checked = CBool(drLe("None"))
        'Polyp_CheckBox.Checked = CBool(drLe("Polyp"))


        'Submucosal_CheckBox.Checked = CBool(drLe("Submucosal"))
        'If Not IsDBNull(drLe("SubmucosalQuantity")) Then
        '    SubmucosalQtyNumericTextBox.Text = CInt(drLe("SubmucosalQuantity"))
        'End If
        'If Not IsDBNull(drLe("SubmucosalLargest")) Then
        '    SubmucosalLargestNumericTextBox.Text = CInt(drLe("SubmucosalLargest"))
        'End If
        'If Not IsDBNull(drLe("SubmucosalProbably")) Then
        '    SubmucosalProbablyCheckBox.Checked = CBool(drLe("SubmucosalProbably"))
        'End If
        'If Not IsDBNull(drLe("SubmucosalTumourTypeId")) Then
        '    SubmucosalTumourTypesRadioButtonList.SelectedValue = CInt(drLe("SubmucosalTumourTypeId"))
        'End If

        'Focal_CheckBox.Checked = CBool(drLe("Focal"))
        'If Not IsDBNull(drLe("FocalQuantity")) Then
        '    FocalQtyNumericTextBox.Text = CInt(drLe("FocalQuantity"))
        'End If
        'If Not IsDBNull(drLe("FocalLargest")) Then
        '    FocalLargestNumericTextBox.Text = CInt(drLe("FocalLargest"))
        'End If
        'If Not IsDBNull(drLe("FocalProbably")) Then
        '    FocalProbablyCheckBox.Checked = CBool(drLe("FocalProbably"))
        'End If
        If Not IsDBNull(drLe("PreviousESDScar")) Then
            PreviousESDScar_CheckBox.Checked = CBool(drLe("PreviousESDScar"))
        End If
        'If Not IsDBNull(drLe("FocalTumourTypeId")) Then
        '    FocalTumourTypesRadioButtonList.SelectedValue = CInt(drLe("FocalTumourTypeId"))
        'End If

        'FundicGlandPolyp_CheckBox.Checked = CBool(drLe("FundicGlandPolyp"))
        'If Not IsDBNull(drLe("FundicGlandPolypQuantity")) Then
        '    FundicGlandPolypQtyNumericTextBox.Text = CInt(drLe("FundicGlandPolypQuantity"))
        'End If
        'If Not IsDBNull(drLe("FundicGlandPolypLargest")) Then
        '    FundicGlandPolypLargestNumericTextBox.Text = CDbl(drLe("FundicGlandPolypLargest")).ToString()
        'End If

        If CBool(drLe("Polyp")) Then
            Dim polypDetails = AbnormalitiesDataAdapter.GetLesionsPolypData(siteId)
            Session("CommonPolypDetails") = polypDetails
        End If
    End Sub

    Private Sub DisableControls(abnorCheckBox As RadButton,
                                combo1 As RadComboBox,
                                Optional combo2 As RadComboBox = Nothing)
        If abnorCheckBox.Checked Then
            combo1.Enabled = True
            combo1.CssClass = "abnor_cb" & combo1.SelectedValue.ToString
            If combo2 IsNot Nothing Then
                combo2.Enabled = True
                combo2.CssClass = "abnor_cb" & (combo2.SelectedValue + 1).ToString
            End If
        End If
    End Sub

    'Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
    '    SaveRecord(True)
    'End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        'If e.Argument IsNot Nothing Then SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)

        Dim Tattooed As Boolean? = Nothing
        Dim PreviouslyTattooed As Boolean? = Nothing
        Dim TattooMarkedWith As Nullable(Of Integer)
        Dim TattooedQty As Nullable(Of Integer)
        Dim TattooedBy As Nullable(Of Integer)

        Dim lesionSize = 0

        Dim sitePolypDetails As List(Of SitePolyps) = If(Session("CommonPolypDetails"), New List(Of SitePolyps))
        'added by mostafizur 3900
        'If Polyp_CheckBox.Checked AndAlso (PolypTypeRadComboBox.SelectedValue = 0 OrElse sitePolypDetails.Count = 0) Then
        '    Utilities.SetNotificationStyle(RadNotification1, "Size and retrieval details must be entered for polyps", True)
        '    RadNotification1.Show()
        '    'added by mostafizur 3900
        'Else
        'Polyp_CheckBox.Checked,
        '0,'PolypTypeRadComboBox.SelectedValue,
        'sitePolypDetails,
        Try
            AbnormalitiesDataAdapter.saveLesionData(siteId,
                                                        NoneCheckBox.Checked,
                                                        False,'Submucosal_CheckBox.Checked,
                                                        0,'SubmucosalQtyNumericTextBox.Value,
                                                        0,'SubmucosalLargestNumericTextBox.Value,
                                                        False,'If(Submucosal_CheckBox.Checked, SubmucosalProbablyCheckBox.Checked, Nothing),
                                                       False,' If(Submucosal_CheckBox.Checked AndAlso Not String.IsNullOrWhiteSpace(SubmucosalTumourTypesRadioButtonList.SelectedValue), SubmucosalTumourTypesRadioButtonList.SelectedValue, Nothing),
                                                       False,' Focal_CheckBox.Checked,
                                                       0,' FocalQtyNumericTextBox.Value,
                                                      0,  'FocalLargestNumericTextBox.Value,
                                                    False,'    If(Focal_CheckBox.Checked, FocalProbablyCheckBox.Checked, Nothing),
                                                    0, '   If(Focal_CheckBox.Checked AndAlso Not String.IsNullOrWhiteSpace(FocalTumourTypesRadioButtonList.SelectedValue), FocalTumourTypesRadioButtonList.SelectedValue, Nothing),
                                                        Tattooed,
                                                        PreviouslyTattooed,
                                                        TattooMarkedWith,
                                                        TattooedQty,
                                                        TattooedBy,
                                                       False,' FundicGlandPolyp_CheckBox.Checked,
                                                        0,'FundicGlandPolypQtyNumericTextBox.Value,
                                                        0,'FundicGlandPolypLargestNumericTextBox.Value,
                                                        PreviousESDScar_CheckBox.Checked)

            'build summary report

            If saveAndClose Then
                'Utilities.SetNotificationStyle(RadNotification1)
                'RadNotification1.Show()
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

            Catch ex As Exception
                Dim errorLogRef As String
                errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Colon Abnormalities - Lesions.", ex)

                Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
                RadNotification1.Show()
            End Try
        'End If
    End Sub
    'clean viewstates on load
    Private Property vSessileParisClassification As Integer
        Get
            Return ViewState("vSessileParisClassification")
        End Get
        Set(value As Integer)
            ViewState("vSessileParisClassification") = value
        End Set
    End Property
    Private Property vPedunculatedParisClassification As Integer
        Get
            Return ViewState("vPedunculatedParisClassification")
        End Get
        Set(value As Integer)
            ViewState("vPedunculatedParisClassification") = value
        End Set
    End Property
    Private Property vSessilePitPattern As Integer
        Get
            Return ViewState("vSessilePitPattern")
        End Get
        Set(value As Integer)
            ViewState("vSessilePitPattern") = value
        End Set
    End Property
    Private Property vPedunculatedPitPattern As Integer
        Get
            Return ViewState("vPedunculatedPitPattern")
        End Get
        Set(value As Integer)
            ViewState("vPedunculatedPitPattern") = value
        End Set
    End Property
    Private Function GetSessileParisClassificationValue() As Integer
        If SessileLSRadioButton.Checked Then
            Return 1
        ElseIf SessileLLARadioButton.Checked Then
            Return 2
        ElseIf SessileLLALLCRadioButton.Checked Then
            Return 3
        ElseIf SessileLLBRadioButton.Checked Then
            Return 4
        ElseIf SessileLLCRadioButton.Checked Then
            Return 5
        ElseIf SessileLLCLLARadioButton.Checked Then
            Return 6
        End If
        Return 0
    End Function

    Private Sub SetSessileParisClassificationValue(ByVal value As Integer)
        If value = 1 Then
            SessileLSRadioButton.Checked = True
        ElseIf value = 2 Then
            SessileLLARadioButton.Checked = True
        ElseIf value = 3 Then
            SessileLLALLCRadioButton.Checked = True
        ElseIf value = 4 Then
            SessileLLBRadioButton.Checked = True
        ElseIf value = 5 Then
            SessileLLCRadioButton.Checked = True
        ElseIf value = 6 Then
            SessileLLCLLARadioButton.Checked = True
        End If
    End Sub

    Private Function GetPedunculatedParisClassificationValue() As Integer
        If ProtrudedRadioButton.Checked Then
            Return 1
        ElseIf PedunculatedRadioButton.Checked Then
            Return 2
        Else
            Return 0
        End If
    End Function

    Private Sub SetPedunculatedParisClassificationValue(ByVal value As Integer)
        If value = 1 Then
            ProtrudedRadioButton.Checked = True
        ElseIf value = 2 Then
            PedunculatedRadioButton.Checked = True
        End If
    End Sub

    Private Function GetSessilePitPatternValue() As Integer
        If SessileNormalRoundPitsRadioButton.Checked Then
            Return 1
        ElseIf SessileStellarRadioButton.Checked Then
            Return 2
        ElseIf SessileTubularRoundPitsRadioButton.Checked Then
            Return 3
        ElseIf SessileTubularRadioButton.Checked Then
            Return 4
        ElseIf SessileSulcusRadioButton.Checked Then
            Return 5
        ElseIf SessileLossRadioButton.Checked Then
            Return 6
        End If
        Return 0
    End Function

    Private Sub SetSessilePitPatternValue(ByVal value As Integer)
        If value = 1 Then
            SessileNormalRoundPitsRadioButton.Checked = True
        ElseIf value = 2 Then
            SessileStellarRadioButton.Checked = True
        ElseIf value = 3 Then
            SessileTubularRoundPitsRadioButton.Checked = True
        ElseIf value = 4 Then
            SessileTubularRadioButton.Checked = True
        ElseIf value = 5 Then
            SessileSulcusRadioButton.Checked = True
        ElseIf value = 6 Then
            SessileLossRadioButton.Checked = True
        End If
    End Sub

    Private Function GetPedunculatedPitPatternValue() As Integer
        If PedunculatedNormalRoundPitsRadioButton.Checked Then
            Return 1
        ElseIf PedunculatedStellarRadioButton.Checked Then
            Return 2
        ElseIf PedunculatedTubularRoundPitsRadioButton.Checked Then
            Return 3
        ElseIf PedunculatedTubularRadioButton.Checked Then
            Return 4
        ElseIf PedunculatedSulcusRadioButton.Checked Then
            Return 5
        ElseIf PedunculatedLossRadioButton.Checked Then
            Return 6
        End If
        Return 0
    End Function

    Private Sub SetPedunculatedPitPatternValue(ByVal value As Integer)
        If value = 1 Then
            PedunculatedNormalRoundPitsRadioButton.Checked = True
        ElseIf value = 2 Then
            PedunculatedStellarRadioButton.Checked = True
        ElseIf value = 3 Then
            PedunculatedTubularRoundPitsRadioButton.Checked = True
        ElseIf value = 4 Then
            PedunculatedTubularRadioButton.Checked = True
        ElseIf value = 5 Then
            PedunculatedSulcusRadioButton.Checked = True
        ElseIf value = 6 Then
            PedunculatedLossRadioButton.Checked = True
        End If
    End Sub

    Protected Sub GetValues(sender As Object, e As EventArgs)
        Dim cmdName As String = DirectCast(sender, RadButton).ID
        Select Case cmdName
            Case "PedunculatedPitPatternsRadButton"
                vPedunculatedPitPattern = GetPedunculatedPitPatternValue()
            Case "SessilePitPatternsRadButton"
                vSessilePitPattern = GetSessilePitPatternValue()
            Case "PedunculatedParisClassificationRadButton"
                vPedunculatedParisClassification = GetPedunculatedParisClassificationValue()
            Case "SessileParisClassificationRadButton"
                vSessileParisClassification = GetSessileParisClassificationValue()
        End Select
        SetIconClass()
    End Sub
    Protected Sub WinUnload(sender As Object, e As EventArgs)
        Dim cmdName As String = DirectCast(sender, RadWindow).ID
        Select Case cmdName
            Case "PedunculatedPitPatternsPopup"
                SetPedunculatedPitPatternValue(CInt(vPedunculatedPitPattern))
            Case "SessilePitPatternsPopup"
                SetSessilePitPatternValue(CInt(vSessilePitPattern))
            Case "PedunculatedParisClassificationPopUp"
                SetPedunculatedParisClassificationValue(CInt(vPedunculatedParisClassification))
            Case "SessileParisClassificationPopup"
                SetSessileParisClassificationValue(CInt(vSessileParisClassification))
        End Select
    End Sub

    Protected Sub ShowRadWindow(sender As Object, e As EventArgs)
        Dim wName As String = DirectCast(sender, RadButton).ID
        Dim script As String = ""
        Select Case wName
            Case "SessileParisShowButton"
                SetSessileParisClassificationValue(CInt(vSessileParisClassification))
                script = "function f(){$find(""" + SessileParisClassificationPopup.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
            Case "SessilePitShowButton"
                SetSessilePitPatternValue(CInt(vSessilePitPattern))
                script = "function f(){$find(""" + SessilePitPatternsPopup.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
            Case "PedunculatedParisShowButton"
                SetPedunculatedParisClassificationValue(CInt(vPedunculatedParisClassification))
                script = "function f(){$find(""" + PedunculatedParisClassificationPopUp.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
            Case "PedunculatedPitShowButton"
                SetPedunculatedPitPatternValue(CInt(vPedunculatedPitPattern))
                script = "function f(){$find(""" + PedunculatedPitPatternsPopup.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        End Select

        If script <> "" Then ScriptManager.RegisterStartupScript(Page, Page.GetType(), "key0", script, True)
    End Sub
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    Protected Sub PolypDetailsRepeater_ItemCommand(source As Object, e As RepeaterCommandEventArgs)
        If e.CommandName.ToLower = "remove" AndAlso Not String.IsNullOrWhiteSpace(e.CommandArgument) Then
            Dim sitePolyps = DirectCast(Session("CommonPolypDetails"), List(Of SitePolyps))
            sitePolyps = sitePolyps.Where(Function(t) t.PolypId <> CInt(e.CommandArgument)).ToList()
            PolypDetailsRepeater.DataSource = sitePolyps
            PolypDetailsRepeater.DataBind()
            Session("CommonPolypDetails") = sitePolyps
            Dim x = AbnormalitiesDataAdapter.savepolypDetails(sitePolyps, siteId)
        ElseIf e.CommandName.ToLower = "edit" AndAlso Not String.IsNullOrWhiteSpace(e.CommandArgument) Then
            Dim sitePolyps = DirectCast(Session("CommonPolypDetails"), List(Of SitePolyps))
            Session("PolypDetailsEdit") = sitePolyps.Where(Function(t) t.PolypId = CInt(e.CommandArgument)).SingleOrDefault()
            Dim mode = "edit"
            'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "NavigatePolypDetails", "NavigatePolypDetails();", True)
            PolypDetailsRadWindow.NavigateUrl = "~/Products/Gastro/Abnormalities/Common/PolypDetails.aspx?siteid=" + siteId.ToString() + "&mode=" + mode
            PolypDetailsRadWindow.VisibleOnPageLoad = True

        End If
    End Sub

    Protected Sub PolypDetailsRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        Try
            If e.Item.DataItem Is Nothing Then Exit Sub

            Dim polypTypeRPT As HiddenField = e.Item.FindControl("polypTypeRPT")
            Dim RemovalHiddenField As HiddenField = e.Item.FindControl("PolypRemovalHiddenField")
            Dim RemovalMethodHiddenField As HiddenField = e.Item.FindControl("PolypRemovalMethodHiddenField")
            Dim TumourTypeHiddenField As HiddenField = e.Item.FindControl("PolypTypeHiddenField")
            Dim PolypTattooedHiddenField As HiddenField = e.Item.FindControl("PolypTattooedHiddenField")
            Dim TattooMarkingHiddenField As HiddenField = e.Item.FindControl("PolypMarkingHiddenField")
            Dim ProbablyHiddenField As HiddenField = e.Item.FindControl("PolypProbablyHiddenField")
            Dim PolypSize As Label = e.Item.FindControl("lblSize")
            Dim Excised As CheckBox = e.Item.FindControl("ExcisedCheckbox")
            Dim Retrieved As CheckBox = e.Item.FindControl("RetrievedCheckbox")
            Dim Successful As CheckBox = e.Item.FindControl("SuccessfulCheckbox")
            Dim InflamCheckBox As CheckBox = e.Item.FindControl("InflamCheckBox")
            Dim PostInflamCheckBox As CheckBox = e.Item.FindControl("PostInflamCheckBox")
            Dim Labs As CheckBox = e.Item.FindControl("ToLabsCheckbox")
            Dim Conditions As HiddenField = e.Item.FindControl("PolypConditionHiddenField")
            Dim pseudoPolypTR As HtmlTableRow = e.Item.FindControl("pseudoPolypTR")
            Dim polypTypeDetailsTR As HtmlTableRow = e.Item.FindControl("polypTypeDetailsTR")
            Dim polypMorphologyLabel As Label = e.Item.FindControl("polypMorphologyLabel")

            Dim parisDescription = ""
            Dim pitDescription = ""

            Dim dr = DirectCast(e.Item.DataItem, SitePolyps)
            RemovalHiddenField.Value = dr.Removal
            RemovalMethodHiddenField.Value = dr.RemovalMethod
            TumourTypeHiddenField.Value = dr.TumourType
            ProbablyHiddenField.Value = dr.Probably
            InflamCheckBox.Checked = dr.Inflammatory
            PostInflamCheckBox.Checked = dr.PostInflammatory

            PolypTattooedHiddenField.Value = dr.TattooedId
            TattooMarkingHiddenField.Value = dr.TattooMarkingTypeId

            'Dim Removal_ComboBox As RadComboBox = e.Item.FindControl("Removal_ComboBox")
            'Dim Removal_Method_ComboBox As RadComboBox = e.Item.FindControl("Removal_Method_ComboBox")
            'Dim Type_ComboBox As RadComboBox = e.Item.FindControl("Type_ComboBox")
            'Dim PolypTattooedRadioButtonList As RadioButtonList = e.Item.FindControl("PolypTattooedRadioButtonList")
            'Dim Tattoo_Marking_ComboBox As RadComboBox = e.Item.FindControl("Tattoo_Marking_ComboBox")
            'Dim Probably_Checkbox As CheckBox = e.Item.FindControl("Probably_CheckBox")

            'Removal_ComboBox.DataSource = DataAdapter.LoadPolyRemovalTypes()
            'Removal_ComboBox.DataBind()

            'Removal_Method_ComboBox.DataSource = DataAdapter.LoadPolyRemovalMethods()
            'Removal_Method_ComboBox.DataBind()

            'Type_ComboBox.DataSource = DataAdapter.LoadTumourTypes()
            'Type_ComboBox.DataBind()

            'Tattoo_Marking_ComboBox.DataSource = DataAdapter.LoadMarkingTypes()
            'Tattoo_Marking_ComboBox.DataBind()

            'PolypTattooedRadioButtonList.DataSource = DataAdapter.LoadTattooOptions()
            'PolypTattooedRadioButtonList.DataBind()

            'If Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Gastroscopy Then
            '    PolypConditionPanel.Visible = True
            '    PolypConditionsCheckBoxList.DataSource = DataAdapter.LoadPolypConditions()
            '    PolypConditionsCheckBoxList.DataBind()
            'End If

            If dr.Size > 0 Then PolypSize.Text = dr.Size
            Excised.Checked = dr.Excised
            Retrieved.Checked = dr.Retrieved
            Successful.Checked = dr.Successful
            Labs.Checked = dr.SentToLabs

            Dim polypId = e.Item.ItemIndex & "_" & siteId.ToString

            Select Case polypTypeRPT.Value.ToLower
                Case "sessile", "pseudo"
                    Dim sessileParisValue = 0
                    Dim sessilePitPattern = 0

                    If dr.ParisClassification > 0 Then
                        parisDescription = "Paris classification: " & GetSessileParisClassificationDescription(dr.ParisClassification)
                    End If

                    If dr.PitPattern > 0 Then
                        pitDescription = "Pit pattern: " & GetSessilePitPatternDescription(dr.PitPattern)
                    End If
                Case "pedunculated"
                    Dim pedunculatedParisValue = 0
                    Dim pedunculatedPitPattern = 0

                    If dr.ParisClassification > 0 Then
                        parisDescription = GetPedunculatedParisClassificationDescription(dr.ParisClassification)
                    End If

                    If dr.PitPattern > 0 Then
                        pitDescription = GetPedunculatedPitPatternDescription(dr.PitPattern)
                    End If
                Case "pseudo"
                    If polypTypeDetailsTR IsNot Nothing Then polypTypeDetailsTR.Visible = False
                    If pseudoPolypTR IsNot Nothing Then pseudoPolypTR.Visible = True
                Case "submucosal"
                    If polypTypeDetailsTR IsNot Nothing Then polypTypeDetailsTR.Visible = False
                    'If PolypRemovalTR IsNot Nothing Then PolypRemovalTR.Visible = False
            End Select

            polypMorphologyLabel.Text = parisDescription & " " & pitDescription

            If Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Gastroscopy Or Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Transnasal Then
                Dim dtCondition = DataAdapter.LoadPolypConditions()
                Dim contiditonsUL As HtmlGenericControl = e.Item.FindControl("PolypConditionUL")
                If contiditonsUL IsNot Nothing Then
                    If CType(e.Item.DataItem, SitePolyps).Conditions.Count > 0 Then
                        Conditions.Value = String.Join(",", CType(e.Item.DataItem, SitePolyps).Conditions)

                        For Each conditionId In CType(e.Item.DataItem, SitePolyps).Conditions
                            Dim drCondition = dtCondition.Select("UniqueId='" & conditionId & "'")
                            If drCondition.Count > 0 Then
                                Dim cbText = drCondition(0)("Description") 'PolypConditionsCheckBoxList.Items.FindByValue(conditionId)
                                'cbText.Selected = True
                                Dim Lconditions = cbText.Split(" ")
                                Dim conditionsAbbr As String = ""
                                For Each c In Lconditions
                                    conditionsAbbr += c + " "
                                Next
                                contiditonsUL.Controls.Add(New LiteralControl("<li class='" & cbText.Replace(" ", "") & "'><strong>" & conditionsAbbr.ToUpper() & "</strong></li>"))
                            End If

                            'contiditonsUL.Controls.Add(New LiteralControl("<li class='" & cbText.Text.Replace(" ", "") & "'><img src='images\icons\polyp_conditions\" & cbText.Text.Replace(" ", "").ToLower() & ".png' alt='" & cbText.Text.Replace(" ", "").ToLower() & "' /></li>"))
                        Next
                    End If
                End If
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error populating data", ex)
            Throw ex
        End Try
    End Sub


    Private Function GetSessileParisClassificationDescription(parisId As Integer) As String

        If parisId = 1 Then
            Return "Is - sessile"
        ElseIf parisId = 2 Then
            Return "IIa - flat elevated"
        ElseIf parisId = 3 Then
            Return "IIa + IIc - flat elevated with depression"
        ElseIf parisId = 4 Then
            Return "IIb - flat"
        ElseIf parisId = 5 Then
            Return "IIc - slightly depressed"
        ElseIf parisId = 6 Then
            Return "IIc + IIa - slightly depressed"
        Else
            Return LSTTypesDropdown.Items.FindItemByValue(parisId).Text
        End If
        Return 0
    End Function


    Private Function GetPedunculatedParisClassificationDescription(parisId As Integer) As String
        If parisId = 7 Then
            Return "Ip - Pedunculated"
        ElseIf parisId = 8 Then
            Return "Isp - sub pedunculated"
        Else
            Return "not specified"
        End If
    End Function



    Private Function GetSessilePitPatternDescription(pitId As Integer) As String
        If pitId = 1 Then
            Return "I"
        ElseIf pitId = 2 Then
            Return "II"
        ElseIf pitId = 3 Then
            Return "III s"
        ElseIf pitId = 4 Then
            Return "III L"
        ElseIf pitId = 5 Then
            Return "IV"
        ElseIf pitId = 6 Then
            Return "V"
        End If
        Return ""
    End Function



    Private Function GetPedunculatedPitPatternDescription(pitId As Integer) As String
        If pitId = 1 Then
            Return "I"
        ElseIf pitId = 2 Then
            Return "II"
        ElseIf pitId = 3 Then
            Return "III s"
        ElseIf pitId = 4 Then
            Return "III L"
        ElseIf pitId = 5 Then
            Return "IV"
        ElseIf pitId = 6 Then
            Return "V"
        End If
        Return ""
    End Function

    Protected Sub EnterDetailsRadButton_Click(sender As Object, e As EventArgs)
        Dim mode = "Insert"
        'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "NavigatePolypDetails", "NavigatePolypDetails();", True)
        PolypDetailsRadWindow.NavigateUrl = "~/Products/Gastro/Abnormalities/Common/PolypDetails.aspx?siteid=" + siteId.ToString() + "&mode=" + mode
        PolypDetailsRadWindow.VisibleOnPageLoad = True
    End Sub

    Protected Sub NoneCheckBox_CheckedChanged(sender As Object, e As EventArgs)
        SaveRecord(True)
    End Sub

    Protected Sub PreviousESDScar_CheckBox_CheckedChanged(sender As Object, e As EventArgs)
        SaveRecord(True)
    End Sub
End Class
