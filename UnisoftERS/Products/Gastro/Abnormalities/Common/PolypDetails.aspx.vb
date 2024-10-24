Imports DevExpress.CodeParser
Imports DevExpress.XtraPrinting.Native
Imports Telerik.Web.UI
Imports Telerik.Web.UI.Skins
Imports RadButton = Telerik.Web.UI.RadButton

Public Class CommonPolypDetails
    Inherits PageBase

    Public polypType As String
    Private _abnormalitiesDataAdapter As Abnormalities = Nothing
    Public Shared procType As Integer
    Protected ReadOnly Property AbnormalitiesDataAdapter() As Abnormalities
        Get
            If _abnormalitiesDataAdapter Is Nothing Then
                _abnormalitiesDataAdapter = New Abnormalities
            End If
            Return _abnormalitiesDataAdapter
        End Get
    End Property
    Public ReadOnly Property siteId As Integer
        Get
            Return Request.QueryString("siteid")
        End Get
    End Property

    Public ReadOnly Property Mode As String
        Get
            Return Request.QueryString("mode")
        End Get
    End Property

    Public ReadOnly Property selectedQty As Integer
        Get
            Return If(String.IsNullOrWhiteSpace(Request.QueryString("qty")), 0, Request.QueryString("qty"))
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        polypType = PolypTypeRadComboBox.SelectedItem.Text
        SetButtonEvents()
        If Not Page.IsPostBack Then

            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If procType = CInt(ProcedureType.Colonoscopy) OrElse procType = CInt(ProcedureType.Sigmoidscopy) Then
                PolypTypeRadComboBox.FindItemByValue("6").Visible = False
            End If

            Session("CommonPolypDetails") = AbnormalitiesDataAdapter.GetLesionsPolypData(siteId)
            'polypType = Request.QueryString("type")
            LoadDropdowns()

            If Session("CommonPolypDetails") IsNot Nothing AndAlso CType(Session("CommonPolypDetails"), List(Of SitePolyps)).Count > 0 Then

                'Session("CommonPolypDetails") = Nothing 'can i do this.? What if they close without saving and reopen it... Need to do a DB call to retrieve them on page load maybe?
            Else
                'ScriptManager.RegisterClientScriptBlock(Me.Page, GetType(Page), "showentrywindow", "showAddNewWindow();", True)
            End If

            If selectedQty > 0 Then
                PolypQtyRadNumericTextBox.Value = selectedQty
            End If



            If Mode = "edit" Then
                Dim _sitePolyp As SitePolyps = DirectCast(Session("PolypDetailsEdit"), SitePolyps)



                PolypTypeRadComboBox.SelectedValue = _sitePolyp.PolypTypeId
                polypType = PolypTypeRadComboBox.SelectedItem.Text



                SetButtonEvents()
                'polypType = _sitePolyp.
                'PolypTypeRadComboBox.SelectedValue = _sitePolyp.PolypType

                removeTypeandQtyTR.Visible = False


                PolypSizeNumericTextBox.Text = _sitePolyp.Size
                ExcisedCheckBox.Checked = _sitePolyp.Excised

                RetrievedCheckBox.Checked = _sitePolyp.Retrieved  ' problamatic 
                DiscardedCheckBox.Checked = _sitePolyp.Discarded    ' problamatic 
                Removal_ComboBox.SelectedValue = _sitePolyp.Removal  ' problamatic 
                Removal_Method_ComboBox.SelectedValue = _sitePolyp.RemovalMethod   ' problamatic 
                SuccessfulCheckBox.Checked = _sitePolyp.Successful   ' problamatic 
                Type_ComboBox.SelectedValue = _sitePolyp.TumourType 'might problamatic 


                Probably_CheckBox.Checked = _sitePolyp.Probably

                'SubmucosalQtyNumericTextBox.Text = _sitePolyp.SubmucosalQuantity
                'SubmucosalLargestNumericTextBox.Text = _sitePolyp.SubmucosalLargest
                'FocalLargestNumericTextBox.Text = _sitePolyp.FocalLargest
                'FocalQtyNumericTextBox.Text = _sitePolyp.FocalQuantity
                'FundicGlandPolypLargestNumericTextBox.Text = _sitePolyp.FundicGlandPolypLargest
                'FundicGlandPolypQtyNumericTextBox.Text = _sitePolyp.FundicGlandPolypQuantity

                ' _sitePolyp.ParisClassification
                '_sitePolyp.PitPattern


                Select Case polypType.ToLower
                    Case "pedunculated"
                        GetPedunculatedPitPatternValue(_sitePolyp.PitPattern)
                        If vPedunculatedPitPattern Is Nothing Then vPedunculatedPitPattern = New Dictionary(Of String, Integer)
                        If vPedunculatedPitPattern.ContainsKey(_sitePolyp.PolypId) Then vPedunculatedPitPattern.Remove(_sitePolyp.PolypId)
                        vPedunculatedPitPattern.Add(_sitePolyp.PolypId, GetPedunculatedPitPatternValue())
                        polypPitLabel.Text = GetPedunculatedPitPatternDescription(_sitePolyp.PitPattern)

                        GetPedunculatedParisClassificationValue(_sitePolyp.ParisClassification)
                        If GetPedunculatedParisClassificationValue() > 0 Then
                            If vPedunculatedParisClassification Is Nothing Then vPedunculatedParisClassification = New Dictionary(Of String, Integer)
                            If vPedunculatedParisClassification.ContainsKey(_sitePolyp.PolypId) Then vPedunculatedParisClassification.Remove(_sitePolyp.PolypId)
                            vPedunculatedParisClassification.Add(_sitePolyp.PolypId, GetPedunculatedParisClassificationValue())
                            polypParisLabel.Text = GetPedunculatedParisClassificationDescription(_sitePolyp.ParisClassification)
                        End If

                    Case Else
                        GetSessilePitPatternValue(_sitePolyp.PitPattern)
                        If vSessilePitPattern Is Nothing Then vSessilePitPattern = New Dictionary(Of String, Integer)
                        polypPitLabel.Text = GetSessilePitPatternDescription(_sitePolyp.PitPattern)

                        If vSessilePitPattern.ContainsKey(_sitePolyp.PolypId) Then vSessilePitPattern.Remove(_sitePolyp.PolypId)
                        vSessilePitPattern.Add(_sitePolyp.PolypId, GetSessilePitPatternValue())
                        GetSessileParisClassificationValue(_sitePolyp.ParisClassification)
                        If GetSessileParisClassificationValue() > 0 Then
                            If vSessileParisClassification Is Nothing Then vSessileParisClassification = New Dictionary(Of String, Integer)
                            If vSessileParisClassification.ContainsKey(_sitePolyp.PolypId) Then vSessileParisClassification.Remove(_sitePolyp.PolypId)
                            vSessileParisClassification.Add(_sitePolyp.PolypId, GetSessileParisClassificationValue())
                            polypParisLabel.Text = GetSessileParisClassificationDescription(_sitePolyp.ParisClassification)
                        End If


                End Select

                Dim jsPitFunction = ""
                Dim jsParisFunction = ""
                Select Case polypType.ToLower
                    Case "pedunculated"
                        pseudoPolypTR.Visible = False
                        jsParisFunction = "showPedunculatedParisPopup('-1', " & _sitePolyp.ParisClassification & ");"
                        jsPitFunction = "showPedunculatedPitPatternsPopup('-1'," & _sitePolyp.PitPattern & ");"

                    Case "pseudo"
                        pseudoPolypTR.Visible = True
                        jsPitFunction = "showSessilePitPatternsPopup('-1'," & _sitePolyp.PitPattern & ");"
                        jsParisFunction = "showSessileParisPopup('-1', " & _sitePolyp.ParisClassification & ");"

                    Case Else
                        pseudoPolypTR.Visible = False
                        jsPitFunction = "showSessilePitPatternsPopup('-1'," & _sitePolyp.PitPattern & " );"
                        jsParisFunction = "showSessileParisPopup('-1', " & _sitePolyp.ParisClassification & ");"
                End Select




                PitShowButton.Attributes("onclick") = "return " & jsPitFunction
                ParisShowButton.Attributes("onclick") = "return " & jsParisFunction



                InflamCheckBox.Checked = _sitePolyp.Inflammatory
                PostInflamCheckBox.Checked = _sitePolyp.PostInflammatory

                For Each item As ListItem In PolypConditionsCheckBoxList.Items
                    If _sitePolyp.Conditions.Contains(Integer.Parse(item.Value)) Then
                        item.Selected = True
                    End If
                Next

                TattooLocationDistalCheckBox.Checked = _sitePolyp.TattooLocationDistal
                TattooLocationProximalCheckBox.Checked = _sitePolyp.TattooLocationProximal
                PolypTattooedRadioButtonList.SelectedIndex = _sitePolyp.TattooedId
                Tattoo_Marking_ComboBox.SelectedIndex = _sitePolyp.TattooMarkingTypeId

                'If (_sitePolyp.PolypType.ToLower = "fundic gland polyp") Then
                '    FundicGlandPolypTR.Visible = True
                '    FocalPolypTR.Visible = False
                '    SubmucosalPolypTR.Visible = False
                'ElseIf (_sitePolyp.PolypType.ToLower = "focal lesions") Then
                '    FocalPolypTR.Visible = True
                '    FundicGlandPolypTR.Visible = False
                '    SubmucosalPolypTR.Visible = False
                'ElseIf (_sitePolyp.PolypType.ToLower = "submucosal") Then
                '    SubmucosalPolypTR.Visible = True
                '    FocalPolypTR.Visible = False
                '    FundicGlandPolypTR.Visible = False
                'End If

                'Select Case polypType.ToLower
                '    Case "sessile", "pedunculated", "pseudo"
                '        PolypParisRequiredFieldValidator.Enabled = True
                '        PolypPitRequiredFieldValidator.Enabled = True
                '        parisTR.Visible = True
                '        pitTR.Visible = True
                '    Case Else
                '        PolypParisRequiredFieldValidator.Enabled = False
                '        PolypPitRequiredFieldValidator.Enabled = False
                '        parisTR.Visible = False
                '        pitTR.Visible = False
                'End Select

                AddPolypDetailsRadButton.Text = "Save Polyps"


            ElseIf Mode = "Insert" Then
                clearForm()
            End If

        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try

            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "CloseMe", "SaveAndClose();", True)
            End If
            'Else
            '    Utilities.SetNotificationStyle(RadNotification1, "You have not enter/saved your polyp details. Please correct and try again", True, "Please check your details")
            '    RadNotification1.Show()
            'End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving polyp details.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
    Private Sub SetButtonEvents()
        Dim jsPitFunction = ""
        Dim jsParisFunction = ""

        Select Case polypType.ToLower
            Case "pedunculated"
                pseudoPolypTR.Visible = False
                jsParisFunction = "showPedunculatedParisPopup('-1', 0);"
                jsPitFunction = "showPedunculatedPitPatternsPopup('-1', 0);"
            Case "pseudo"
                pseudoPolypTR.Visible = True
                jsPitFunction = "showSessilePitPatternsPopup('-1', 0);"
                jsParisFunction = "showSessileParisPopup('-1', 0);"
            Case Else
                pseudoPolypTR.Visible = False
                jsPitFunction = "showSessilePitPatternsPopup('-1', 0);"
                jsParisFunction = "showSessileParisPopup('-1', 0);"
        End Select

        PitShowButton.Attributes("onclick") = "return " & jsPitFunction
        ParisShowButton.Attributes("onclick") = "return " & jsParisFunction

    End Sub

    Private Sub LoadDropdowns()
        Try
            Removal_ComboBox.DataSource = DataAdapter.LoadPolyRemovalMethods()
            Removal_ComboBox.DataBind()

            Removal_Method_ComboBox.DataSource = DataAdapter.LoadPolyRemovalTypes()
            Removal_Method_ComboBox.DataBind()

            Type_ComboBox.DataSource = DataAdapter.LoadTumourTypes()
            Type_ComboBox.DataBind()

            PolypTattooedRadioButtonList.DataSource = DataAdapter.LoadTattooOptions
            PolypTattooedRadioButtonList.DataBind()

            Tattoo_Marking_ComboBox.DataSource = DataAdapter.LoadMarkingTypes()
            Tattoo_Marking_ComboBox.DataBind()

            If Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Gastroscopy Or Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Transnasal Then
                PolypConditionTR.Visible = True
                PolypConditionsCheckBoxList.DataSource = DataAdapter.LoadPolypConditions()
                PolypConditionsCheckBoxList.DataBind()
            End If

            LSTTypesDropdown.DataSource = DataAdapter.LoadParisLSTTypes()
            LSTTypesDropdown.DataBind()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading polyp details dropdowns", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading reference data")
        End Try
    End Sub



    Private Sub clearForm()
        'SubmucosalQtyNumericTextBox.Text = ""
        'SubmucosalLargestNumericTextBox.Text = ""
        'FocalLargestNumericTextBox.Text = ""
        'FocalQtyNumericTextBox.Text = ""
        'FundicGlandPolypLargestNumericTextBox.Text = ""
        'FundicGlandPolypQtyNumericTextBox.Text = ""

        PolypQtyRadNumericTextBox.Text = ""
        PolypSizeNumericTextBox.Text = ""
        ExcisedCheckBox.Checked = False
        'RetrievedCheckBox.Checked = False
        SuccessfulCheckBox.Checked = False
        'ToLabsCheckBox.Checked = False
        Removal_ComboBox.SelectedIndex = 0
        Removal_Method_ComboBox.SelectedIndex = 0
        Probably_CheckBox.Checked = False
        InflamCheckBox.Checked = False
        PostInflamCheckBox.Checked = False
        TattooLocationDistalCheckBox.Checked = False
        TattooLocationProximalCheckBox.Checked = False

        For Each itm As ListItem In PolypConditionsCheckBoxList.Items
            itm.Selected = False
        Next

        PolypTattooedRadioButtonList.SelectedIndex = -1
        Tattoo_Marking_ComboBox.SelectedIndex = 0


        If vSessilePitPattern IsNot Nothing AndAlso vSessilePitPattern.ContainsKey(-1) Then
            vSessilePitPattern.Remove(-1)
        End If
        If vSessileParisClassification IsNot Nothing AndAlso vSessileParisClassification.ContainsKey(-1) Then
            vSessileParisClassification.Remove(-1)
        End If
        If vPedunculatedPitPattern IsNot Nothing AndAlso vPedunculatedPitPattern.ContainsKey(-1) Then
            vPedunculatedPitPattern.Remove(-1)
        End If
        If vPedunculatedParisClassification IsNot Nothing AndAlso vPedunculatedParisClassification.ContainsKey(-1) Then
            vPedunculatedParisClassification.Remove(-1)
        End If
    End Sub
    'Protected Sub PolypDetailsRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
    '    Try
    '        If e.Item.DataItem Is Nothing Then Exit Sub

    '        Dim polypTypeRPT As HiddenField = e.Item.FindControl("polypTypeRPT")
    '        Dim RemovalHiddenField As HiddenField = e.Item.FindControl("PolypRemovalHiddenField")
    '        Dim RemovalMethodHiddenField As HiddenField = e.Item.FindControl("PolypRemovalMethodHiddenField")
    '        Dim TumourTypeHiddenField As HiddenField = e.Item.FindControl("PolypTypeHiddenField")
    '        Dim PolypTattooedHiddenField As HiddenField = e.Item.FindControl("PolypTattooedHiddenField")
    '        Dim TattooMarkingHiddenField As HiddenField = e.Item.FindControl("PolypMarkingHiddenField")
    '        Dim ProbablyHiddenField As HiddenField = e.Item.FindControl("PolypProbablyHiddenField")
    '        Dim PolypSize As Label = e.Item.FindControl("lblSize")
    '        Dim Excised As CheckBox = e.Item.FindControl("ExcisedCheckbox")
    '        Dim Retrieved As CheckBox = e.Item.FindControl("RetrievedCheckbox")
    '        Dim Successful As CheckBox = e.Item.FindControl("SuccessfulCheckbox")
    '        Dim InflamCheckBox As CheckBox = e.Item.FindControl("InflamCheckBox")
    '        Dim PostInflamCheckBox As CheckBox = e.Item.FindControl("PostInflamCheckBox")
    '        Dim Labs As CheckBox = e.Item.FindControl("ToLabsCheckbox")
    '        Dim Conditions As HiddenField = e.Item.FindControl("PolypConditionHiddenField")
    '        Dim pseudoPolypTR As HtmlTableRow = e.Item.FindControl("pseudoPolypTR")
    '        Dim polypTypeDetailsTR As HtmlTableRow = e.Item.FindControl("polypTypeDetailsTR")
    '        Dim polypMorphologyLabel As Label = e.Item.FindControl("polypMorphologyLabel")

    '        Dim parisDescription = ""
    '        Dim pitDescription = ""

    '        Dim dr = DirectCast(e.Item.DataItem, SitePolyps)
    '        RemovalHiddenField.Value = dr.Removal
    '        RemovalMethodHiddenField.Value = dr.RemovalMethod
    '        TumourTypeHiddenField.Value = dr.TumourType
    '        ProbablyHiddenField.Value = dr.Probably
    '        InflamCheckBox.Checked = dr.Inflammatory
    '        PostInflamCheckBox.Checked = dr.PostInflammatory

    '        PolypTattooedHiddenField.Value = dr.TattooedId
    '        TattooMarkingHiddenField.Value = dr.TattooMarkingTypeId

    '        'Dim Removal_ComboBox As RadComboBox = e.Item.FindControl("Removal_ComboBox")
    '        'Dim Removal_Method_ComboBox As RadComboBox = e.Item.FindControl("Removal_Method_ComboBox")
    '        'Dim Type_ComboBox As RadComboBox = e.Item.FindControl("Type_ComboBox")
    '        'Dim PolypTattooedRadioButtonList As RadioButtonList = e.Item.FindControl("PolypTattooedRadioButtonList")
    '        'Dim Tattoo_Marking_ComboBox As RadComboBox = e.Item.FindControl("Tattoo_Marking_ComboBox")
    '        'Dim Probably_Checkbox As CheckBox = e.Item.FindControl("Probably_CheckBox")

    '        'Removal_ComboBox.DataSource = DataAdapter.LoadPolyRemovalTypes()
    '        'Removal_ComboBox.DataBind()

    '        'Removal_Method_ComboBox.DataSource = DataAdapter.LoadPolyRemovalMethods()
    '        'Removal_Method_ComboBox.DataBind()

    '        'Type_ComboBox.DataSource = DataAdapter.LoadTumourTypes()
    '        'Type_ComboBox.DataBind()

    '        'Tattoo_Marking_ComboBox.DataSource = DataAdapter.LoadMarkingTypes()
    '        'Tattoo_Marking_ComboBox.DataBind()

    '        'PolypTattooedRadioButtonList.DataSource = DataAdapter.LoadTattooOptions()
    '        'PolypTattooedRadioButtonList.DataBind()

    '        'If Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Gastroscopy Then
    '        '    PolypConditionPanel.Visible = True
    '        '    PolypConditionsCheckBoxList.DataSource = DataAdapter.LoadPolypConditions()
    '        '    PolypConditionsCheckBoxList.DataBind()
    '        'End If

    '        If dr.Size > 0 Then PolypSize.Text = dr.Size
    '        Excised.Checked = dr.Excised
    '        Retrieved.Checked = dr.Retrieved
    '        Successful.Checked = dr.Successful
    '        Labs.Checked = dr.SentToLabs

    '        Dim polypId = e.Item.ItemIndex & "_" & siteId.ToString

    '        Select Case polypTypeRPT.Value.ToLower
    '            Case "sessile", "pseudo"
    '                Dim sessileParisValue = 0
    '                Dim sessilePitPattern = 0

    '                If dr.ParisClassification > 0 Then
    '                    If vSessileParisClassification Is Nothing Then vSessileParisClassification = New Dictionary(Of String, Integer)

    '                    If Not vSessileParisClassification.ContainsKey(polypId) Then
    '                        vSessileParisClassification.Add(polypId, dr.ParisClassification)
    '                    End If
    '                    parisDescription = "Paris classification: " & GetSessileParisClassificationDescription(dr.ParisClassification)
    '                End If

    '                If dr.PitPattern > 0 Then
    '                    If vSessilePitPattern Is Nothing Then vSessilePitPattern = New Dictionary(Of String, Integer)

    '                    If Not vSessilePitPattern.ContainsKey(polypId) Then
    '                        vSessilePitPattern.Add(polypId, dr.PitPattern)
    '                    End If
    '                    pitDescription = "Pit pattern: " & GetSessilePitPatternDescription(dr.PitPattern)
    '                End If

    '                ParisShowButton.Attributes("onclick") = "return showSessileParisPopup('" & polypId & "'," & sessileParisValue & ");"
    '                PitShowButton.Attributes("onclick") = "return showSessilePitPatternsPopup('" & polypId & "'," & sessilePitPattern & ");"
    '            Case "pedunculated"
    '                Dim pedunculatedParisValue = 0
    '                Dim pedunculatedPitPattern = 0

    '                If dr.ParisClassification > 0 Then
    '                    If vPedunculatedParisClassification Is Nothing Then vPedunculatedParisClassification = New Dictionary(Of String, Integer)

    '                    If Not vPedunculatedParisClassification.ContainsKey(polypId) Then
    '                        vPedunculatedParisClassification.Add(polypId, dr.ParisClassification)
    '                    End If
    '                    parisDescription = GetPedunculatedParisClassificationDescription(dr.ParisClassification)
    '                End If

    '                If dr.PitPattern > 0 Then
    '                    If vPedunculatedPitPattern Is Nothing Then vPedunculatedPitPattern = New Dictionary(Of String, Integer)
    '                    If Not vPedunculatedPitPattern.ContainsKey(polypId) Then
    '                        vPedunculatedPitPattern.Add(polypId, dr.PitPattern)
    '                    End If
    '                    pitDescription = GetPedunculatedPitPatternDescription(dr.PitPattern)
    '                End If

    '                ParisShowButton.Attributes("onclick") = "return showPedunculatedParisPopup('" & polypId & "'," & pedunculatedParisValue & ");"
    '                PitShowButton.Attributes("onclick") = "return showPedunculatedPitPatternsPopup('" & polypId & "'," & pedunculatedParisValue & ");"
    '            Case "pseudo"
    '                If polypTypeDetailsTR IsNot Nothing Then polypTypeDetailsTR.Visible = False
    '                If pseudoPolypTR IsNot Nothing Then pseudoPolypTR.Visible = True
    '            Case "submucosal"
    '                If polypTypeDetailsTR IsNot Nothing Then polypTypeDetailsTR.Visible = False
    '                'If PolypRemovalTR IsNot Nothing Then PolypRemovalTR.Visible = False
    '        End Select

    '        polypMorphologyLabel.Text = parisDescription & " " & pitDescription

    '        If Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Gastroscopy Then
    '            Dim dtCondition = DataAdapter.LoadPolypConditions()
    '            Dim contiditonsUL As HtmlGenericControl = e.Item.FindControl("PolypConditionUL")
    '            If contiditonsUL IsNot Nothing Then
    '                If CType(e.Item.DataItem, SitePolyps).Conditions.Count > 0 Then
    '                    Conditions.Value = String.Join(",", CType(e.Item.DataItem, SitePolyps).Conditions)

    '                    For Each conditionId In CType(e.Item.DataItem, SitePolyps).Conditions
    '                        Dim drCondition = dtCondition.Select("UniqueId='" & conditionId & "'")
    '                        Dim cbText = drCondition(0)("Description") 'PolypConditionsCheckBoxList.Items.FindByValue(conditionId)
    '                        'cbText.Selected = True
    '                        Dim Lconditions = cbText.Split(" ")
    '                        Dim conditionsAbbr As String = ""
    '                        For Each c In Lconditions
    '                            conditionsAbbr += c.Substring(0, 1)
    '                        Next
    '                        contiditonsUL.Controls.Add(New LiteralControl("<li class='" & cbText.Replace(" ", "") & "'><strong>" & conditionsAbbr.ToUpper() & "</strong></li>"))
    '                        'contiditonsUL.Controls.Add(New LiteralControl("<li class='" & cbText.Text.Replace(" ", "") & "'><img src='images\icons\polyp_conditions\" & cbText.Text.Replace(" ", "").ToLower() & ".png' alt='" & cbText.Text.Replace(" ", "").ToLower() & "' /></li>"))
    '                    Next
    '                End If
    '            End If
    '        End If
    '    Catch ex As Exception
    '        Dim ref = LogManager.LogManagerInstance.LogError("Error populating data", ex)
    '        Throw ex
    '    End Try
    'End Sub

    Private Sub LoadData(rowQty As Integer)
        Try

            Dim sitePolyps As New List(Of SitePolyps)
            Dim pitPattern As Integer = 0
            Dim parisClassification As Integer = 0




            'only do this on load otherwise will be carried out when adding a new polyp too, therefore duplicating
            If Session("CommonPolypDetails") IsNot Nothing Then
                sitePolyps.AddRange(CType(Session("CommonPolypDetails"), List(Of SitePolyps)))

            End If

            'get polyp conditions data for checkbox list
            Dim PolypTypeId = PolypTypeRadComboBox.SelectedValue
            Dim size = PolypSizeNumericTextBox.Value

            'Dim submucosalQuantity = SubmucosalQtyNumericTextBox.Value
            'Dim submucosalLargest = SubmucosalLargestNumericTextBox.Value
            'Dim focalLargest = FocalLargestNumericTextBox.Value
            'Dim focalQuantity = FocalQtyNumericTextBox.Value
            'Dim fundicGlandPolypLargest = FundicGlandPolypLargestNumericTextBox.Value
            'Dim fundicGlandPolypQuantity = FundicGlandPolypQtyNumericTextBox.Value


            Dim excised = ExcisedCheckBox.Checked
            Dim retrieved = RetrievedCheckBox.Checked
            Dim discarded = DiscardedCheckBox.Checked

            Dim successful = SuccessfulCheckBox.Checked

            Dim removal = Removal_ComboBox.SelectedValue
            Dim removalMethod = Removal_Method_ComboBox.SelectedValue
            Dim probably = Probably_CheckBox.Checked
            Dim type = Type_ComboBox.SelectedValue
            Dim inflammatory = InflamCheckBox.Checked
            Dim postInflammatory = PostInflamCheckBox.Checked

            Dim tattooLocationDistal = TattooLocationDistalCheckBox.Checked
            Dim tattooLocationProximal = TattooLocationProximalCheckBox.Checked

            Dim tattooedId As Integer = 0 'PolypTattooedRadioButtonList.SelectedValue
            Dim tattooMarkingId As Integer = 0 'Tattoo_Marking_ComboBox.SelectedValue
            Dim polypConditions As New List(Of Integer)


            If Not String.IsNullOrWhiteSpace(PolypTattooedRadioButtonList.SelectedValue) Then
                tattooedId = PolypTattooedRadioButtonList.SelectedValue
            End If

            If Not String.IsNullOrWhiteSpace(Tattoo_Marking_ComboBox.SelectedValue) Then
                tattooMarkingId = Tattoo_Marking_ComboBox.SelectedValue
            End If

            For Each chk As ListItem In PolypConditionsCheckBoxList.Items
                If chk.Selected Then polypConditions.Add(chk.Value)
            Next


            Dim pitPatterns = New Dictionary(Of String, Integer)
            Dim parisClass = New Dictionary(Of String, Integer)

            '18 Aug 2021 : Mahfuz added fix for New PolypID generation. Same polypid is being created for second new Polyp

            'For i as Integer = 0 to rowQty -1  Mahfuz changed this line as below

            For i As Integer = 0 To rowQty - 1
                Dim polypId = i & "_" & siteId

                Dim sp As New SitePolyps
                sp.PolypTypeId = PolypTypeId
                sp.PolypType = polypType

                'sp.SubmucosalQuantity = If(submucosalQuantity IsNot Nothing, submucosalQuantity, 0)
                'sp.SubmucosalLargest = If(submucosalLargest IsNot Nothing, submucosalLargest, 0)
                'sp.FocalLargest = If(focalLargest IsNot Nothing, focalLargest, 0)
                'sp.FocalQuantity = If(focalQuantity IsNot Nothing, focalQuantity, 0)
                'sp.FundicGlandPolypLargest = If(fundicGlandPolypLargest IsNot Nothing, fundicGlandPolypLargest, 0)
                'sp.FundicGlandPolypQuantity = If(fundicGlandPolypQuantity IsNot Nothing, fundicGlandPolypQuantity, 0)

                sp.PolypId = polypId
                sp.Size = size
                sp.Excised = excised
                sp.Retrieved = retrieved
                sp.Discarded = discarded
                sp.Successful = successful
                'sp.SentToLabs = labs
                sp.Removal = removal
                sp.RemovalMethod = removalMethod
                sp.TumourType = type
                sp.Probably = probably
                sp.Inflammatory = inflammatory
                sp.PostInflammatory = postInflammatory
                If sp.Size >= 20 Then
                    sp.TattooedId = tattooedId
                    sp.TattooMarkingTypeId = tattooMarkingId
                    sp.TattooLocationDistal = tattooLocationDistal
                    sp.TattooLocationProximal = tattooLocationProximal
                End If

                If polypConditions.Count > 0 Then
                    sp.Conditions.AddRange(polypConditions)
                End If

                Select Case polypType.ToLower 'key of -1 indicates a new set of morphology. polyp id was not known at the time, but it is now so updating and removing
                    Case "pedunculated"
                        If vPedunculatedPitPattern IsNot Nothing AndAlso vPedunculatedPitPattern.ContainsKey(-1) AndAlso Not vPedunculatedPitPattern.ContainsKey(polypId) Then
                            vPedunculatedPitPattern.Add(polypId, vPedunculatedPitPattern(-1))
                            sp.PitPattern = vPedunculatedPitPattern(-1)
                            'vPedunculatedPitPattern = Nothing
                        End If
                        If vPedunculatedParisClassification IsNot Nothing AndAlso vPedunculatedParisClassification.ContainsKey(-1) AndAlso Not vPedunculatedParisClassification.ContainsKey(polypId) Then
                            vPedunculatedParisClassification.Add(polypId, vPedunculatedParisClassification(-1))
                            sp.ParisClassification = vPedunculatedParisClassification(-1)
                            'vPedunculatedParisClassification = Nothing
                        End If
                    Case "sessile", "pseudo"
                        If vSessilePitPattern IsNot Nothing AndAlso vSessilePitPattern.ContainsKey(-1) AndAlso Not vSessilePitPattern.ContainsKey(polypId) Then
                            vSessilePitPattern.Add(polypId, vSessilePitPattern(-1))
                            sp.PitPattern = vSessilePitPattern(-1)
                            'vSessilePitPattern = Nothing
                        End If
                        If vSessileParisClassification IsNot Nothing AndAlso vSessileParisClassification.ContainsKey(-1) AndAlso Not vSessileParisClassification.ContainsKey(polypId) Then
                            vSessileParisClassification.Add(polypId, vSessileParisClassification(-1))
                            sp.ParisClassification = vSessileParisClassification(-1)
                            'vSessileParisClassification = Nothing
                        End If
                End Select

                sitePolyps.Add(sp)

            Next

            'vSessilePitPattern = Nothing
            'vSessileParisClassification = Nothing
            'vPedunculatedPitPattern = Nothing
            'vPedunculatedParisClassification = Nothing

            'PolypDetailsRepeater.DataSource = sitePolyps
            'PolypDetailsRepeater.DataBind()
            Session("CommonPolypDetails") = sitePolyps
            clearForm()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error populating data", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error populating data")
            RadNotification1.Show()
        End Try
    End Sub


#Region "Paris/Pit window details"
    Private Property vSessileParisClassification As Dictionary(Of String, Integer)
        Get
            Return ViewState("vSessileParisClassification")
        End Get
        Set(value As Dictionary(Of String, Integer))
            ViewState("vSessileParisClassification") = value
        End Set
    End Property
    Private Property vPedunculatedParisClassification As Dictionary(Of String, Integer)
        Get
            Return ViewState("vPedunculatedParisClassification")
        End Get
        Set(value As Dictionary(Of String, Integer))
            ViewState("vPedunculatedParisClassification") = value
        End Set
    End Property
    Private Property vSessilePitPattern As Dictionary(Of String, Integer)
        Get
            Return ViewState("vSessilePitPattern")
        End Get
        Set(value As Dictionary(Of String, Integer))
            ViewState("vSessilePitPattern") = value
        End Set
    End Property
    Private Property vPedunculatedPitPattern As Dictionary(Of String, Integer)
        Get
            Return ViewState("vPedunculatedPitPattern")
        End Get
        Set(value As Dictionary(Of String, Integer))
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
        ElseIf LSTGRadioButton.Checked Then
            Return LSTTypesDropdown.SelectedValue
        End If
        Return 0
    End Function

    Private Function GetSessileParisClassificationValue(ByVal sessilparisselection)
        If sessilparisselection = 1 Then
            SessileLSRadioButton.Checked = True
        ElseIf sessilparisselection = 2 Then
            SessileLLARadioButton.Checked = True
        ElseIf sessilparisselection = 3 Then
            SessileLLALLCRadioButton.Checked = True
        ElseIf sessilparisselection = 4 Then
            SessileLLBRadioButton.Checked = True
        ElseIf sessilparisselection = 5 Then
            SessileLLCRadioButton.Checked = True
        ElseIf sessilparisselection = 6 Then
            SessileLLCLLARadioButton.Checked = True
        ElseIf sessilparisselection > 6 Then
            LSTGRadioButton.Checked = True
            LSTTypesDropdown.SelectedValue = sessilparisselection
        End If
    End Function

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

    Private Function GetPedunculatedParisClassificationValue() As Integer
        If ProtrudedRadioButton.Checked Then
            Return 7
        ElseIf PedunculatedRadioButton.Checked Then
            Return 8
        Else
            Return 0
        End If
    End Function
    Private Function GetPedunculatedParisClassificationValue(ByVal penduparisselection)
        If penduparisselection = 7 Then
            ProtrudedRadioButton.Checked = True
        ElseIf penduparisselection = 8 Then
            PedunculatedRadioButton.Checked = True
        End If
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
    Private Function GetSessilePitPatternValue(ByVal sessilpitselection)
        If sessilpitselection = 1 Then
            SessileNormalRoundPitsRadioButton.Checked = True
        ElseIf sessilpitselection = 2 Then
            SessileStellarRadioButton.Checked = True
        ElseIf sessilpitselection = 3 Then
            SessileTubularRoundPitsRadioButton.Checked = True
        ElseIf sessilpitselection = 4 Then
            SessileTubularRadioButton.Checked = True
        ElseIf sessilpitselection = 5 Then
            SessileSulcusRadioButton.Checked = True
        ElseIf sessilpitselection = 6 Then
            SessileLossRadioButton.Checked = True
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

    Private Function GetPedunculatedPitPatternValue(ByVal pendupitselection)
        If pendupitselection = 1 Then
            PedunculatedNormalRoundPitsRadioButton.Checked = True
        ElseIf pendupitselection = 2 Then
            PedunculatedStellarRadioButton.Checked = True
        ElseIf pendupitselection = 3 Then
            PedunculatedTubularRoundPitsRadioButton.Checked = True
        ElseIf pendupitselection = 4 Then
            PedunculatedTubularRadioButton.Checked = True
        ElseIf pendupitselection = 5 Then
            PedunculatedSulcusRadioButton.Checked = True
        ElseIf pendupitselection = 6 Then
            PedunculatedLossRadioButton.Checked = True
        End If

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

    Protected Sub GetValues(sender As Object, e As EventArgs)
        Dim btn = DirectCast(sender, RadButton)
        Dim cmdName As String = btn.ID
        Dim polypId As String = -1 'btn.CommandArgument
        Dim itemIndex As Integer = polypId.Split("_")(0)

        Select Case cmdName
            Case "PedunculatedPitPatternsRadButton"
                If vPedunculatedPitPattern Is Nothing Then vPedunculatedPitPattern = New Dictionary(Of String, Integer)
                If vPedunculatedPitPattern.ContainsKey(polypId) Then vPedunculatedPitPattern.Remove(polypId)
                vPedunculatedPitPattern.Add(polypId, GetPedunculatedPitPatternValue())
            Case "SessilePitPatternsRadButton"
                If vSessilePitPattern Is Nothing Then vSessilePitPattern = New Dictionary(Of String, Integer)

                If vSessilePitPattern.ContainsKey(polypId) Then vSessilePitPattern.Remove(polypId)
                vSessilePitPattern.Add(polypId, GetSessilePitPatternValue())
            Case "PedunculatedParisClassificationRadButton"
                If GetPedunculatedParisClassificationValue() > 0 Then
                    If vPedunculatedParisClassification Is Nothing Then vPedunculatedParisClassification = New Dictionary(Of String, Integer)
                    If vPedunculatedParisClassification.ContainsKey(polypId) Then vPedunculatedParisClassification.Remove(polypId)
                    vPedunculatedParisClassification.Add(polypId, GetPedunculatedParisClassificationValue())
                End If

            Case "SessileParisClassificationRadButton"
                If GetSessileParisClassificationValue() > 0 Then
                    If vSessileParisClassification Is Nothing Then vSessileParisClassification = New Dictionary(Of String, Integer)
                    If vSessileParisClassification.ContainsKey(polypId) Then vSessileParisClassification.Remove(polypId)
                    vSessileParisClassification.Add(polypId, GetSessileParisClassificationValue())
                End If
        End Select
    End Sub

    Protected Sub AddPolypDetailsRadButton_Click(sender As Object, e As EventArgs)

        Try

            Dim qty = PolypQtyRadNumericTextBox.Value
            Dim x As Boolean = False
            'validate that a morphology value is present if polyps have been removed by any of the specified methods (keys of -1 indicates a new entry)
            ' If Removal_Method_ComboBox.SelectedValue > 0 AndAlso ((polypType.ToLower = "pedunculated" Or polypType.ToLower = "sessile" Or polypType.ToLower = "pseudo") AndAlso (polypDetails.ParisClassification = 0) And (polypDetails.PitPattern = 0)) Then
            If AddPolypDetailsRadButton.Text = "Save Polyps" Then
                Dim polypDetails As SitePolyps = DirectCast(Session("PolypDetailsEdit"), SitePolyps)


                AddPolypDetailsRadButton.Text = "Add Polyps"

                'polypDetails.SubmucosalQuantity = SubmucosalQtyNumericTextBox.Text
                'polypDetails.SubmucosalLargest = SubmucosalLargestNumericTextBox.Text
                'polypDetails.FocalLargest = FocalLargestNumericTextBox.Text
                'polypDetails.FocalQuantity = FocalQtyNumericTextBox.Text
                'polypDetails.FundicGlandPolypLargest = FundicGlandPolypLargestNumericTextBox.Text
                'polypDetails.FundicGlandPolypQuantity = FundicGlandPolypQtyNumericTextBox.Text



                PolypQtyRadNumericTextBox.Visible = False

                polypDetails.Size = PolypSizeNumericTextBox.Text
                polypDetails.Excised = ExcisedCheckBox.Checked
                polypDetails.Retrieved = RetrievedCheckBox.Checked
                polypDetails.Discarded = DiscardedCheckBox.Checked
                'RetrievedCheckBox.Checked = False
                polypDetails.Successful = SuccessfulCheckBox.Checked
                'ToLabsCheckBox.Checked = False
                polypDetails.Removal = Removal_ComboBox.SelectedIndex
                polypDetails.RemovalMethod = Removal_Method_ComboBox.SelectedIndex

                polypDetails.TumourType = Type_ComboBox.SelectedIndex
                polypDetails.Probably = Probably_CheckBox.Checked



                'Select Case polypType.ToLower 'key of -1 indicates a new set of morphology. polyp id was not known at the time, but it is now so updating and removing
                '    Case "sessile", "pseudo"

                '        If vSessilePitPattern IsNot Nothing AndAlso vSessilePitPattern.ContainsKey(-1) AndAlso Not vSessilePitPattern.ContainsKey(polypDetails.PolypId) Then
                '            vSessilePitPattern.Add(polypDetails.PolypId, vSessilePitPattern(-1))
                '            polypDetails.PitPattern = vSessilePitPattern(-1)
                '            'vSessilePitPattern = Nothing
                '        End If
                '        ' If vSessileParisClassification IsNot Nothing AndAlso Not vSessileParisClassification.ContainsKey(-1) AndAlso vSessileParisClassification.ContainsKey(polypDetails.PolypId) Then
                '        '''''''''''' just handle below condition , need to handle all for update properly 

                '        If polypDetails.ParisClassification > 0 Then

                '            'vSessileParisClassification.Add(polypDetails.PolypId, vSessileParisClassification(-1))
                '            'polypDetails.ParisClassification = vSessileParisClassification(-1)
                '            If vSessileParisClassification.ContainsKey(polypDetails.PolypId) Then
                '                vSessileParisClassification(polypDetails.PolypId) = vSessileParisClassification(-1)
                '            Else
                '                vSessileParisClassification.Add(polypDetails.PolypId, vSessileParisClassification(-1))
                '            End If

                '            polypDetails.ParisClassification = vSessileParisClassification(polypDetails.PolypId)
                '        End If
                '        '''' just handle below condition , need to handle all for update properly 
                '    Case "pedunculated"
                '            If vPedunculatedPitPattern IsNot Nothing AndAlso vPedunculatedPitPattern.ContainsKey(-1) AndAlso Not vPedunculatedPitPattern.ContainsKey(polypDetails.PolypId) Then
                '                vPedunculatedPitPattern.Add(polypDetails.PolypId, vPedunculatedPitPattern(-1))
                '                polypDetails.PitPattern = vPedunculatedPitPattern(-1)
                '                'vPedunculatedPitPattern = Nothing
                '            End If
                '            If vPedunculatedParisClassification IsNot Nothing AndAlso vPedunculatedParisClassification.ContainsKey(-1) AndAlso Not vPedunculatedParisClassification.ContainsKey(polypDetails.PolypId) Then
                '                vPedunculatedParisClassification.Add(polypDetails.PolypId, vPedunculatedParisClassification(-1))
                '                polypDetails.ParisClassification = vPedunculatedParisClassification(-1)
                '                'vPedunculatedParisClassification = Nothing
                '            End If
                '    End Select

                'Select Case polypType.ToLower
                '    Case "pedunculated"
                '        GetPedunculatedPitPatternValue(_sitePolyp.PitPattern)
                '        If vPedunculatedPitPattern Is Nothing Then vPedunculatedPitPattern = New Dictionary(Of String, Integer)
                '        If vPedunculatedPitPattern.ContainsKey(_sitePolyp.PolypId) Then vPedunculatedPitPattern.Remove(_sitePolyp.PolypId)
                '        vPedunculatedPitPattern.Add(_sitePolyp.PolypId, GetPedunculatedPitPatternValue())

                '        GetPedunculatedParisClassificationValue(_sitePolyp.ParisClassification)
                '        If GetPedunculatedParisClassificationValue() > 0 Then
                '            If vPedunculatedParisClassification Is Nothing Then vPedunculatedParisClassification = New Dictionary(Of String, Integer)
                '            If vPedunculatedParisClassification.ContainsKey(_sitePolyp.PolypId) Then vPedunculatedParisClassification.Remove(_sitePolyp.PolypId)
                '            vPedunculatedParisClassification.Add(_sitePolyp.PolypId, GetPedunculatedParisClassificationValue())
                '        End If

                '    Case "sessile", "pseudo"
                '        GetSessilePitPatternValue(_sitePolyp.PitPattern)
                '        If vSessilePitPattern Is Nothing Then vSessilePitPattern = New Dictionary(Of String, Integer)

                '        If vSessilePitPattern.ContainsKey(_sitePolyp.PolypId) Then vSessilePitPattern.Remove(_sitePolyp.PolypId)
                '        vSessilePitPattern.Add(_sitePolyp.PolypId, GetSessilePitPatternValue())
                '        GetSessileParisClassificationValue(_sitePolyp.ParisClassification)
                '        If GetSessileParisClassificationValue() > 0 Then
                '            If vSessileParisClassification Is Nothing Then vSessileParisClassification = New Dictionary(Of String, Integer)
                '            If vSessileParisClassification.ContainsKey(_sitePolyp.PolypId) Then vSessileParisClassification.Remove(_sitePolyp.PolypId)
                '            vSessileParisClassification.Add(_sitePolyp.PolypId, GetSessileParisClassificationValue())
                '        End If


                'End Select
                Dim custompolypId = "0" & "_" & siteId
                Select Case polypType.ToLower 'key of -1 indicates a new set of morphology. polyp id was not known at the time, but it is now so updating and removing
                    Case "pedunculated"
                        If vPedunculatedPitPattern IsNot Nothing AndAlso vPedunculatedPitPattern.ContainsKey(-1) AndAlso Not vPedunculatedPitPattern.ContainsKey(custompolypId) Then
                            vPedunculatedPitPattern.Add(custompolypId, vPedunculatedPitPattern(-1))
                            polypDetails.PitPattern = vPedunculatedPitPattern(-1)
                            'vPedunculatedPitPattern = Nothing
                        End If
                        If vPedunculatedParisClassification IsNot Nothing AndAlso vPedunculatedParisClassification.ContainsKey(-1) AndAlso Not vPedunculatedParisClassification.ContainsKey(custompolypId) Then
                            vPedunculatedParisClassification.Add(custompolypId, vPedunculatedParisClassification(-1))
                            polypDetails.ParisClassification = vPedunculatedParisClassification(-1)
                            'vPedunculatedParisClassification = Nothing
                        End If
                    Case Else
                        If vSessilePitPattern IsNot Nothing AndAlso vSessilePitPattern.ContainsKey(-1) AndAlso Not vSessilePitPattern.ContainsKey(custompolypId) Then
                            vSessilePitPattern.Add(custompolypId, vSessilePitPattern(-1))
                            polypDetails.PitPattern = vSessilePitPattern(-1)
                            'vSessilePitPattern = Nothing
                        End If
                        If vSessileParisClassification IsNot Nothing AndAlso vSessileParisClassification.ContainsKey(-1) AndAlso Not vSessileParisClassification.ContainsKey(custompolypId) Then
                            vSessileParisClassification.Add(custompolypId, vSessileParisClassification(-1))
                            polypDetails.ParisClassification = vSessileParisClassification(-1)
                            'vSessileParisClassification = Nothing
                        End If
                End Select

                polypDetails.Inflammatory = InflamCheckBox.Checked
                    polypDetails.PostInflammatory = PostInflamCheckBox.Checked

                    Dim polypConditions As New List(Of Integer)
                    polypDetails.Conditions.Clear()
                    For Each chk As ListItem In PolypConditionsCheckBoxList.Items
                        If chk.Selected Then polypConditions.Add(chk.Value)
                    Next
                    If polypConditions.Count > 0 Then
                        polypDetails.Conditions.AddRange(polypConditions)
                    End If


                    polypDetails.TattooLocationDistal = TattooLocationDistalCheckBox.Checked
                    polypDetails.TattooLocationProximal = TattooLocationProximalCheckBox.Checked
                    polypDetails.TattooedId = PolypTattooedRadioButtonList.SelectedIndex
                    polypDetails.TattooMarkingTypeId = Tattoo_Marking_ComboBox.SelectedIndex

                    x = AbnormalitiesDataAdapter.updatepolypDetails(polypDetails, siteId)
                Else
                If Removal_Method_ComboBox.SelectedValue > 0 AndAlso (vSessileParisClassification Is Nothing OrElse Not vSessileParisClassification.ContainsKey(-1)) And (vPedunculatedParisClassification Is Nothing OrElse Not vPedunculatedParisClassification.ContainsKey(-1)) Then
                    Utilities.SetNotificationStyle(RadNotification1, "You must specify morphology/paris classifaction for removed polyps", True, "Please check your entry")
                    RadNotification1.Show()
                End If
                LoadData(qty)
                x = AbnormalitiesDataAdapter.savepolypDetails(DirectCast(Session("CommonPolypDetails"), List(Of SitePolyps)), siteId)
            End If


            'Dim x As Boolean = AbnormalitiesDataAdapter.updatepolypDetails(polypDetails, siteId)
            'If x Then
            '    ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "CloseMe", "SaveAndClose();", True)
            'End If





            AddPolypDetailsRadButton.Text = "Add Polyps"

            If x Then
                ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "CloseMe", "SaveAndClose();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving polyp details.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try




    End Sub

    'Protected Sub PolypDetailsRepeater_ItemCommand(source As Object, e As RepeaterCommandEventArgs)
    '    If e.CommandName.ToLower = "remove" AndAlso Not String.IsNullOrWhiteSpace(e.CommandArgument) Then

    '        Dim sitePolyps = DirectCast(Session("CommonPolypDetails"), List(Of SitePolyps))
    '        sitePolyps = sitePolyps.Where(Function(t) t.PolypId <> CInt(e.CommandArgument)).ToList()

    'Dim sitePolyps As New List(Of SitePolyps)
    'For Each item As RepeaterItem In PolypDetailsRepeater.Items
    '    Dim sp As New SitePolyps

    '    If item Is e.Item Then Continue For

    '    Dim polypId = CType(item.FindControl("PolypIdHiddenValue"), HiddenField).Value

    '    sp.PolypType = polypType
    '    sp.PolypId = CType(item.FindControl("PolypIdHiddenValue"), HiddenField).Value
    '    sp.Size = CType(item.FindControl("lblSize"), Label).Text
    '    sp.Excised = CType(item.FindControl("ExcisedCheckbox"), CheckBox).Checked
    '    sp.Retrieved = CType(item.FindControl("RetrievedCheckbox"), CheckBox).Checked
    '    sp.Successful = CType(item.FindControl("SuccessfulCheckbox"), CheckBox).Checked
    '    sp.SentToLabs = CType(item.FindControl("ToLabsCheckbox"), CheckBox).Checked
    '    sp.Removal = CType(item.FindControl("PolypRemovalHiddenField"), HiddenField).Value
    '    sp.RemovalMethod = CType(item.FindControl("PolypRemovalMethodHiddenField"), HiddenField).Value
    '    sp.TumourType = CType(item.FindControl("PolypTypeHiddenField"), HiddenField).Value
    '    sp.Probably = CType(item.FindControl("PolypProbablyHiddenField"), HiddenField).Value


    '    sp.Inflammatory = CType(item.FindControl("InflamCheckBox"), CheckBox).Checked
    '    sp.PostInflammatory = CType(item.FindControl("PostInflamCheckBox"), CheckBox).Checked


    '    sp.SubmucosalLargest = CType(item.FindControl("SubmucosalLargestNumericTextBoxRPT"), HiddenField).Value
    '    sp.SubmucosalQuantity = CType(item.FindControl("SubmucosalQtyNumericTextBoxRPT"), HiddenField).Value
    '    sp.FocalLargest = CType(item.FindControl("FocalLargestNumericTextBoxRPT"), HiddenField).Value
    '    sp.FocalQuantity = CType(item.FindControl("FocalQtyNumericTextBoxRPT"), HiddenField).Value
    '    sp.FundicGlandPolypLargest = CType(item.FindControl("FundicGlandPolypLargestNumericTextBoxRPT"), HiddenField).Value
    '    sp.FundicGlandPolypQuantity = CType(item.FindControl("FundicGlandPolypQtyNumericTextBoxRPT"), HiddenField).Value
    '    sp.PolypTypeId = CType(item.FindControl("PolypTypeIdRPT"), HiddenField).Value

    '    If CType(item.FindControl("pseudoPolypTR"), HtmlTableRow).Visible Then
    '        sp.Inflammatory = CType(item.FindControl("InflamCheckBox"), CheckBox).Checked
    '        sp.PostInflammatory = CType(item.FindControl("PostInflamCheckBox"), CheckBox).Checked
    '    End If
    '    If sp.Size >= 20 Then
    '        If Not String.IsNullOrWhiteSpace(CType(item.FindControl("PolypTattooedHiddenField"), HiddenField).Value) Then
    '            sp.TattooedId = CType(item.FindControl("PolypTattooedHiddenField"), HiddenField).Value
    '        End If
    '        sp.TattooMarkingTypeId = CType(item.FindControl("PolypMarkingHiddenField"), HiddenField).Value
    '    End If

    '    If Not String.IsNullOrWhiteSpace(CType(item.FindControl("PolypConditionHiddenField"), HiddenField).Value) Then
    '        For Each condition In CType(item.FindControl("PolypConditionHiddenField"), HiddenField).Value.Split(",")
    '            sp.Conditions.Add(CInt(condition))
    '        Next
    '    End If

    '    If polypType.ToLower = "sessile" Or polypType.ToLower = "pseudo" Then

    '        '18 Aug 2021 Mahfuz added IsNothing check to avoid throwing error
    '        If Not IsNothing(vSessilePitPattern) Then
    '            If vSessilePitPattern.ContainsKey(polypId) Then
    '                sp.PitPattern = vSessilePitPattern(polypId)
    '            End If
    '        End If


    '        '18 Aug 2021 Mahfuz added IsNothing check to avoid throwing error
    '        If Not IsNothing(vSessileParisClassification) Then
    '            If vSessileParisClassification.ContainsKey(polypId) Then
    '                sp.ParisClassification = vSessileParisClassification(polypId)
    '            End If
    '        End If


    '    ElseIf polypType.ToLower = "pedunculated" Then
    '        If vPedunculatedPitPattern.ContainsKey(polypId) Then
    '            sp.PitPattern = vPedunculatedPitPattern(polypId)
    '        End If

    '        If vPedunculatedParisClassification.ContainsKey(polypId) Then
    '            sp.ParisClassification = vPedunculatedParisClassification(polypId)
    '        End If
    '    End If

    '    sitePolyps.Add(sp)
    'Next




    '        Session("CommonPolypDetails") = sitePolyps
    '        Dim x = AbnormalitiesDataAdapter.savepolypDetails(sitePolyps, siteId)
    '    End If
    'End Sub


    Protected Sub PolypTypeRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        SetButtonEvents()
    End Sub

#End Region

End Class