Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Gastro_Abnormalities_Colon_Mucosa
    Inherits SiteDetailsBase

    Private Shared siteId As Integer
    Private Shared UCEISScore As Dictionary(Of String, Integer)

    Protected Sub Products_Gastro_Abnormalities_Colon_Mucosa_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            UCEISScore = New Dictionary(Of String, Integer)
            LoadPage()
        Else
            If Ulcerative_CheckBox.Checked = False Then
                'UlcerativeControlsTable.Style.Add("display", "none")
            Else
                'UlcerativeControlsTable.Style.Add("display", "block")
            End If
            If Colitis_CheckBox.Checked = True Then
                'colitisdiv.Visible = True
                colitisdiv.Style.Add("display", "block")
                If InflammatoryRadioButtonList.SelectedValue = "4" Then
                    'raddiv.Visible = True
                    raddiv.Style.Add("display", "block")
                    diverticulosisscorediv.Style.Add("display", "block")
                End If
            End If
        End If
    End Sub

    Private Sub LoadPage()
        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                        {ExtentDropdownlist, "Diagnoses Colon Extent"},
                        {SESDropDownList, "Simple Endoscopic Score – Crohn's Disease"},
                        {MayoScoreDropDownList, "Mayo Score"}
                })

        InflammatoryRadioButtonList.DataSource = DataAdapter.LoadInflammatoryDisorders
        InflammatoryRadioButtonList.DataBind()

        RutgeertsScoreRadComboBox.DataSource = DataAdapter.LoadRutgeertsScores
        RutgeertsScoreRadComboBox.DataBind()
        DisplayControls()
        SetControls()
        Dim dtMu As DataTable = AbnormalitiesColonDataAdapter.GetMucosaData(siteId)
        If dtMu.Rows.Count > 0 Then
            PopulateData(dtMu.Rows(0))
        Else
            buildUECISScoringGrid(0, 0, 0)

        End If
    End Sub

    Private Sub SetControls()
        For Each ctrl As Control In rgAbnormalities.Controls
            If TypeOf ctrl Is RadComboBox Then
                'DirectCast(ctrl, RadComboBox).ForeColor() = Color.Red
                InsertComboBoxItem(ctrl)
            ElseIf TypeOf ctrl Is RadButton Then
                Dim abnormalitiesRB As RadButton = DirectCast(ctrl, RadButton)

                abnormalitiesRB.ToggleType = ButtonToggleType.CheckBox
                abnormalitiesRB.ButtonType = RadButtonType.ToggleButton
                abnormalitiesRB.AutoPostBack = False
                If abnormalitiesRB.ID = "NoneCheckBox" Then
                    abnormalitiesRB.ForeColor() = ColorTranslator.FromHtml("#384e76")
                Else
                    abnormalitiesRB.ForeColor() = Color.Gray
                End If
            ElseIf TypeOf ctrl Is HtmlTableRow Then
                If ctrl.ID = "RedundantRectalRow" Then
                    Dim abnormalitiesRB As RadButton = DirectCast(ctrl.Controls(0).Controls(1), RadButton)

                    abnormalitiesRB.ToggleType = ButtonToggleType.CheckBox
                    abnormalitiesRB.ButtonType = RadButtonType.ToggleButton
                    abnormalitiesRB.AutoPostBack = False
                    If abnormalitiesRB.ID = "NoneCheckBox" Then
                        abnormalitiesRB.ForeColor() = ColorTranslator.FromHtml("#384e76")
                    Else
                        abnormalitiesRB.ForeColor() = Color.Gray
                    End If
                End If
            End If
        Next
    End Sub

    Private Sub DisplayControls()
        Dim procType As Integer = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        Dim sReg As String = Request.QueryString("Reg")
        Dim sArea As String = Request.QueryString("Area")

        RedundantRectalRow.Visible = False

        If sArea = "Anus" Then
            Dim sSearch As String = IIf(sReg.IndexOf("to") > 0, " to", " cm")
            Dim delim As String() = New String(0) {sSearch}
            Dim sDistance As String() = sReg.Split(delim, StringSplitOptions.None)
            If IsNumeric(sDistance(0)) Then
                If CInt(sDistance(0)) < 17 Then
                    RedundantRectalRow.Visible = True
                End If
            End If
        ElseIf procType = ProcedureType.Retrograde Or sReg = "Rectum" Then
            RedundantRectalRow.Visible = True
        End If
    End Sub

    Private Sub InsertComboBoxItem(ctrl As RadComboBox)
        If ctrl.ID.LastIndexOf("_Distribution") > 0 Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Patchy", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Extensive", "2"))

        ElseIf ctrl.ID.LastIndexOf("_Severity") > 0 Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Mild", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Moderate", "2"))
            ctrl.Items.Add(New RadComboBoxItem("Severe", "3"))

        ElseIf ctrl.ID.LastIndexOf("_Type") > 0 Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Few", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Multiple", "2"))
        End If

        ctrl.Width = "110"
        ctrl.Style("text-align") = "center"
        ctrl.Enabled = False
        ctrl.CssClass = "abnor_cb1"
    End Sub

    Private Sub PopulateData(drMu As DataRow)
        NoneCheckBox.Checked = CBool(drMu("None"))

        Atrophic_CheckBox.Checked = CBool(drMu("Atrophic"))
        Atrophic_Distribution_ComboBox.SelectedValue = CInt(drMu("AtrophicDistribution"))
        Atrophic_Severity_ComboBox.SelectedValue = CInt(drMu("AtrophicSeverity"))
        Congested_CheckBox.Checked = CBool(drMu("Congested"))
        Congested_Distribution_ComboBox.SelectedValue = CInt(drMu("CongestedDistribution"))
        Congested_Severity_ComboBox.SelectedValue = CInt(drMu("CongestedSeverity"))
        Erythematous_CheckBox.Checked = CBool(drMu("Erythematous"))
        Erythematous_Distribution_ComboBox.SelectedValue = CInt(drMu("ErythematousDistribution"))
        Erythematous_Severity_ComboBox.SelectedValue = CInt(drMu("ErythematousSeverity"))
        Granular_CheckBox.Checked = CBool(drMu("Granular"))
        Granular_Distribution_ComboBox.SelectedValue = CInt(drMu("GranularDistribution"))
        Granular_Severity_ComboBox.SelectedValue = CInt(drMu("GranularSeverity"))
        Mucopurulent_CheckBox.Checked = CBool(drMu("Exudate"))
        Mucopurulent_Distribution_ComboBox.SelectedValue = CInt(drMu("ExudateDistribution"))
        Mucopurulent_Severity_ComboBox.SelectedValue = CInt(drMu("ExudateSeverity"))
        Pigmented_CheckBox.Checked = CBool(drMu("Pigmented"))
        Pigmented_Distribution_ComboBox.SelectedValue = CInt(drMu("PigmentedDistribution"))
        Pigmented_Severity_ComboBox.SelectedValue = CInt(drMu("PigmentedSeverity"))
        RedundantRectal_CheckBox.Checked = CBool(drMu("RedundantRectal"))

        Ulcerative_CheckBox.Checked = CBool(drMu("Ulcerative"))

        SmallUlcers_CheckBox.Checked = CBool(drMu("SmallUlcers"))
        SmallUlcers_Type_ComboBox.SelectedValue = CInt(drMu("SmallUlcersType"))
        LargeUlcers_CheckBox.Checked = CBool(drMu("LargeUlcers"))
        LargeUlcers_Type_ComboBox.SelectedValue = CInt(drMu("LargeUlcersType"))
        PleomorphicUlcers_CheckBox.Checked = CBool(drMu("PleomorphicUlcers"))
        PleomorphicUlcers_Type_ComboBox.SelectedValue = CInt(drMu("PleomorphicUlcersType"))
        SerpiginousUlcers_CheckBox.Checked = CBool(drMu("SerpiginousUlcers"))
        SerpiginousUlcers_Type_ComboBox.SelectedValue = CInt(drMu("SerpiginousUlcersType"))
        AphthousUlcers_CheckBox.Checked = CBool(drMu("AphthousUlcers"))
        AphthousUlcers_Type_ComboBox.SelectedValue = CInt(drMu("AphthousUlcersType"))
        Cobblestone_CheckBox.Checked = CBool(drMu("CobblestoneMucosa"))
        Cobblestone_Distribution_ComboBox.SelectedValue = CInt(drMu("CobblestoneMucosaType"))

        Confluent_CheckBox.Checked = CBool(drMu("ConfluentUlceration"))
        DeepUlceration_CheckBox.Checked = CBool(drMu("DeepUlceration"))
        SolitaryUlcer_CheckBox.Checked = CBool(drMu("SolitaryUlcer"))
        If Not IsDBNull(drMu("SolitaryUlcerDiameter")) Then
            DiameterNumericTextBox.Text = CInt(drMu("SolitaryUlcerDiameter"))
        End If

        Colitis_CheckBox.Checked = CBool(drMu("InflammatoryColitis"))
        Ileitis_CheckBox.Checked = CBool(drMu("InflammatoryIleitis"))
        Proctitis_CheckBox.Checked = CBool(drMu("InflammatoryProctitis"))
        InflammatoryRadioButtonList.SelectedValue = CInt(drMu("InflammatoryDisorder"))
        ExtentDropdownlist.SelectedValue = CInt(drMu("InflammatoryExtent"))

        buildUECISScoringGrid(CInt(drMu("VascularPatternUCEISScore")), CInt(drMu("BleedingUCEISScore")), CInt(drMu("ErosionsUCEISScore")))

        If CInt(drMu("VascularPatternUCEISScore")) > 0 Or
           CInt(drMu("BleedingUCEISScore")) > 0 Or
           CInt(drMu("ErosionsUCEISScore")) > 0 Then
            UCEISScore_CheckBox.Checked = True

        End If

        If CInt(drMu("InflammatoryMayoScore")) > 0 Then
            MayoScore_CheckBox.Checked = True
            MayoScoreDropDownList.SelectedValue = CInt(drMu("InflammatoryMayoScore"))

        End If

        SESDropDownList.SelectedValue = CInt(drMu("InflammatorySESCrohn"))

        If Not IsDBNull(drMu("CDEISScore")) Then
            ChronsCDEISScoreRadNumericTextBox.Value = CInt(drMu("CDEISScore"))
        End If

        If Not IsDBNull(drMu("RutgeertsScore")) Then
            RutgeertsScoreRadComboBox.SelectedValue = CInt(drMu("RutgeertsScore"))
        End If

        SetControlProperties()
    End Sub

    Private Sub SetControlProperties()
        DisableControls(Atrophic_CheckBox, Atrophic_Distribution_ComboBox, Atrophic_Severity_ComboBox)
        DisableControls(Congested_CheckBox, Congested_Distribution_ComboBox, Congested_Severity_ComboBox)
        DisableControls(Erythematous_CheckBox, Erythematous_Distribution_ComboBox, Erythematous_Severity_ComboBox)
        DisableControls(Granular_CheckBox, Granular_Distribution_ComboBox, Granular_Severity_ComboBox)
        DisableControls(Mucopurulent_CheckBox, Mucopurulent_Distribution_ComboBox, Mucopurulent_Severity_ComboBox)
        DisableControls(Pigmented_CheckBox, Pigmented_Distribution_ComboBox, Pigmented_Severity_ComboBox)

        DisableControls(SmallUlcers_CheckBox, SmallUlcers_Type_ComboBox)
        DisableControls(LargeUlcers_CheckBox, LargeUlcers_Type_ComboBox)
        DisableControls(PleomorphicUlcers_CheckBox, PleomorphicUlcers_Type_ComboBox)
        DisableControls(SerpiginousUlcers_CheckBox, SerpiginousUlcers_Type_ComboBox)
        DisableControls(AphthousUlcers_CheckBox, AphthousUlcers_Type_ComboBox)
        DisableControls(Cobblestone_CheckBox, Cobblestone_Distribution_ComboBox)
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

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        If Not String.IsNullOrWhiteSpace(InflammatoryRadioButtonList.SelectedValue) AndAlso InflammatoryRadioButtonList.SelectedValue = 4 AndAlso Not ucDICAScores.saveScoring() Then
            Utilities.SetNotificationStyle(RadNotification1, "Please complete DICA scores for diverticulosis extension and qty before continuing", True, "Please correct")
            'RadNotification1.Show()
        Else
            SaveRecord(True)
        End If

    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(isClose As Boolean)
        Try
            AbnormalitiesColonDataAdapter.SaveMucosaData(
                siteId,
                NoneCheckBox.Checked,
                Atrophic_CheckBox.Checked,
                Atrophic_Distribution_ComboBox.SelectedValue,
                Atrophic_Severity_ComboBox.SelectedValue,
                Congested_CheckBox.Checked,
                Congested_Distribution_ComboBox.SelectedValue,
                Congested_Severity_ComboBox.SelectedValue,
                Erythematous_CheckBox.Checked,
                Erythematous_Distribution_ComboBox.SelectedValue,
                Erythematous_Severity_ComboBox.SelectedValue,
                Granular_CheckBox.Checked,
                Granular_Distribution_ComboBox.SelectedValue,
                Granular_Severity_ComboBox.SelectedValue,
                Mucopurulent_CheckBox.Checked,
                Mucopurulent_Distribution_ComboBox.SelectedValue,
                Mucopurulent_Severity_ComboBox.SelectedValue,
                Pigmented_CheckBox.Checked,
                Pigmented_Distribution_ComboBox.SelectedValue,
                Pigmented_Severity_ComboBox.SelectedValue,
                RedundantRectal_CheckBox.Checked,
                Ulcerative_CheckBox.Checked,
                SmallUlcers_CheckBox.Checked,
                SmallUlcers_Type_ComboBox.SelectedValue,
                LargeUlcers_CheckBox.Checked,
                LargeUlcers_Type_ComboBox.SelectedValue,
                PleomorphicUlcers_CheckBox.Checked,
                PleomorphicUlcers_Type_ComboBox.SelectedValue,
                SerpiginousUlcers_CheckBox.Checked,
                SerpiginousUlcers_Type_ComboBox.SelectedValue,
                AphthousUlcers_CheckBox.Checked,
                AphthousUlcers_Type_ComboBox.SelectedValue,
                Cobblestone_CheckBox.Checked,
                Cobblestone_Distribution_ComboBox.SelectedValue,
                Confluent_CheckBox.Checked,
                DeepUlceration_CheckBox.Checked,
                SolitaryUlcer_CheckBox.Checked,
                DiameterNumericTextBox.Value,
                Colitis_CheckBox.Checked,
                Ileitis_CheckBox.Checked,
                Proctitis_CheckBox.Checked,
                If(InflammatoryRadioButtonList.SelectedValue = "", 0, InflammatoryRadioButtonList.SelectedValue),
                If(ExtentDropdownlist.SelectedValue = "", 0, ExtentDropdownlist.SelectedValue),
                If(MayoScoreDropDownList.SelectedValue = "", 0, MayoScoreDropDownList.SelectedValue),
                If(SESDropDownList.SelectedValue = "", 0, SESDropDownList.SelectedValue),
                If(UCEISScore_CheckBox.Checked, UCEISScoring(), New Dictionary(Of String, Integer)),
                If(String.IsNullOrWhiteSpace(ChronsCDEISScoreRadNumericTextBox.Text), 0, ChronsCDEISScoreRadNumericTextBox.Value),
                If(RutgeertsScoreRadComboBox.SelectedValue = "", 0, RutgeertsScoreRadComboBox.SelectedValue))



            If isClose Then
                SetControlProperties()

                'Utilities.SetNotificationStyle(RadNotification1)
                'RadNotification1.Show()
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Colon Abnormalities - Mucosa.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Function UCEISScoring() As Dictionary(Of String, Integer)
        Dim tmp As New Dictionary(Of String, Integer)

        For Each itm As RepeaterItem In rptUCEISScore.Items
            Dim sectionName = CType(itm.FindControl("lblSectionName"), Label).Text.ToLower
            Dim scoreDDL = CType(itm.FindControl("UCEISScoreRadComboBox"), RadComboBox)

            tmp.Add(sectionName, scoreDDL.SelectedValue)
        Next
        Return tmp
    End Function

    Private Sub buildUECISScoringGrid(VascularPatternScore As Integer, BleedingScore As Integer, ErosionsScore As Integer)
        Dim scoreDT = DataAdapter.LoadUCEIScores()

        Dim scoreSections = (From s In scoreDT.AsEnumerable
                             Where s("ParentId") = 0
                             Select UniqueId = s("UniqueId"), Description = s("Description") Distinct)


        rptUCEISScore.DataSource = scoreSections
        rptUCEISScore.DataBind()

        For Each itm As RepeaterItem In rptUCEISScore.Items
            Dim sectionName = CType(itm.FindControl("lblSectionName"), Label).Text
            Dim parentId = CInt(CType(itm.FindControl("ParentIdHiddenField"), HiddenField).Value)
            Dim ddl As RadComboBox = itm.FindControl("UCEISScoreRadComboBox")
            If ddl IsNot Nothing Then
                ddl.DataSource = scoreDT.AsEnumerable.Where(Function(x) x("ParentId") = parentId).CopyToDataTable()
                ddl.DataBind()

                Select Case sectionName.ToLower
                    Case "vascular pattern"
                        ddl.SelectedIndex = ddl.Items.FindItemIndexByValue(VascularPatternScore)
                        'set required field
                    Case "bleeding"
                        ddl.SelectedIndex = ddl.Items.FindItemIndexByValue(BleedingScore)
                        'set required field
                    Case "erosions and ulcers"
                        ddl.SelectedIndex = ddl.Items.FindItemIndexByValue(ErosionsScore)
                        'set required field
                End Select
            End If
        Next

    End Sub
End Class
