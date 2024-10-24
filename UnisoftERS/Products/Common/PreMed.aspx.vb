Imports Telerik.Web.UI
Imports System.Data.SqlClient

Partial Class Products_Common_PreMed
    Inherits PageBase

    Private conn As SqlConnection = Nothing
    Private myReader As SqlDataReader = Nothing
    Private ProcType As Integer

    Protected Property BowelPrepValue() As Boolean
        Get
            Return CBool(ViewState("BowelPrepValue"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("BowelPrepValue") = value
        End Set
    End Property

    Protected Property DrugAdminValidation() As Boolean
        Get
            Return CBool(ViewState("DrugAdminValidation"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("DrugAdminValidation") = value
        End Set
    End Property

    Protected Property BowelPrepValidation() As Boolean
        Get
            Return CBool(ViewState("BowelPrepValidation"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("BowelPrepValidation") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Init
        ProcType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        If Not Page.IsPostBack Then
            Call initForm()

            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                            {OnOralFormulationComboBox, "Bowel_Preparation_Oral"},
                            {OffOralFormulationComboBox, "Bowel_Preparation_Oral"},
                            {OnEnemaFormulationComboBox, "Bowel_Preparation_Enema"},
                            {OffEnemaFormulationComboBox, "Bowel_Preparation_Enema"}
             })



            Dim listTextField As String = "ListItemText"
            Dim listValueField As String = "ListItemNo"
            Utilities.LoadRadioButtonList(BowelPreparationQualityRadioButtonList, DataAdapter.GetBowelPreparationQuality(), listTextField, listValueField)
            For Each item As ListItem In BowelPreparationQualityRadioButtonList.Items
                item.Attributes.Add("onmouseover", "javascript:showToolTip('" & item.Value & "');")
            Next

            Dim ds As New OtherData
            BowelPrepValue = ds.BostonBowelPrepScale()

            If ProcType = ProcedureType.Colonoscopy Or ProcType = ProcedureType.Sigmoidscopy Then
                Dim dtBowel As DataTable = ds.GetBowelPreparationData(CInt(Session(Constants.SESSION_PROCEDURE_ID)), BowelPrepValue)
                If dtBowel.Rows.Count > 0 Then
                    LoadBowel(dtBowel.Rows(0), BowelPrepValue)
                End If
                If BowelPrepValue Then
                    BowelPrepLegendFieldsetOn.Visible = True
                    BowelPrepLegendFieldsetOff.Visible = False
                Else
                    BowelPrepLegendFieldsetOn.Visible = False
                    BowelPrepLegendFieldsetOff.Visible = True
                End If
            Else
                RadTabStrip1.Tabs(1).Visible = False
                BowelPrepLegendFieldsetOn.Visible = False
                BowelPrepLegendFieldsetOff.Visible = False
            End If
        End If
        Dim op As New Options
        DrugAdminValidation = op.CheckRequiredField("PreMed", "Drugs administered")
        If ProcType = ProcedureType.Colonoscopy Or ProcType = ProcedureType.Sigmoidscopy Then BowelPrepValidation = op.CheckRequiredField("PreMed", "Bowel preparation")
        cmdAccept.OnClientClicking = "Validate"
        Dim da As New OtherData
        Dim dtPm As DataTable = da.GetUpperGIPremedication(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        If Not dtPm Is Nothing AndAlso dtPm.Rows.Count > 0 Then
            loadPreMed(dtPm)
        Else
            'Load default values for current user
            dtPm = da.GetUpperGIPremedicationDefault(CInt(Session("PKUserId")))
            If Not dtPm Is Nothing AndAlso dtPm.Rows.Count > 0 Then
                loadPreMed(dtPm)
            Else
                loadPreMed(Nothing)
            End If
        End If
    End Sub

    Private Sub LoadBowel(drIn As DataRow, state As Boolean)
        '17 Sept 2021 : MH fixes clearing combo values if NoBowelPrefChecked - changed from setting 0 to Nothing
        If state Then
            NoBowelCheckBox.Checked = CBool(drIn("OnNoBowelPrep"))
            If CBool(drIn("OnNoBowelPrep")) Then
                OnOralFormulationComboBox.Enabled = False
                'OnOralFormulationComboBox.SelectedValue = 0
                OnOralFormulationComboBox.SelectedValue = Nothing
                OnEnemaFormulationComboBox.Enabled = False
                'OnEnemaFormulationComboBox.SelectedValue = 0
                OnEnemaFormulationComboBox.SelectedValue = Nothing
                OnOralQuantityText.Enabled = False
                OnOralQuantityText.Text = ""
                RightRadNumericTextBox.Text = ""
                RightRadNumericTextBox.Enabled = False
                TransverseRadNumericTextBox.Text = ""
                TransverseRadNumericTextBox.Enabled = False
                LeftRadNumericTextBox.Text = ""
                LeftRadNumericTextBox.Enabled = False
            Else
                OnOralFormulationComboBox.SelectedValue = drIn("OnOralFormulation").ToString
                OnOralQuantityText.Text = drIn("OnOralQuantity").ToString
                OnEnemaFormulationComboBox.SelectedValue = drIn("OnEnemaFormulation").ToString
                OnCO2InsufflationCheckBox.Checked = CBool(drIn("CO2Insufflation").ToString)
                RightRadNumericTextBox.Text = IIf(IsDBNull(drIn("OnRight")), "", CInt(drIn("OnRight")))
                TransverseRadNumericTextBox.Text = IIf(IsDBNull(drIn("OnTransverse")), "", CInt(drIn("OnTransverse")))
                LeftRadNumericTextBox.Text = IIf(IsDBNull(drIn("OnLeft")), "", CInt(drIn("OnLeft")))
                TotalScoreLabel.Text = IIf(IsDBNull(drIn("OnTotalScore")), "", CInt(drIn("OnTotalScore")))
            End If
        Else
            If CBool(drIn("OffNoBowelPrep")) Then BowelPreparationQualityRadioButtonList.SelectedValue = 0
            If Not CBool(drIn("OffNoBowelPrep")) Then
                OffOralFormulationComboBox.SelectedValue = drIn("OffOralFormulation").ToString
                OffOralQuantityText.Text = drIn("OffOralQuantity").ToString
                OffEnemaFormulationComboBox.SelectedValue = drIn("OffEnemaFormulation").ToString
                OffCO2InsufflationCheckBox.Checked = CBool(drIn("CO2Insufflation").ToString)
                If Not drIn.IsNull("BowelPrepQuality") Then BowelPreparationQualityRadioButtonList.SelectedValue = CInt(drIn("BowelPrepQuality"))
            End If
        End If
    End Sub


    Protected Sub Page_PreLoad(sender As Object, e As System.EventArgs) Handles Me.PreLoad
        'Call uniAdaptor.IsAuthenticated()
    End Sub

    Protected Sub initForm()
        'cmdAccept.Text = IIf(Session("AdvancedMode") = True, "Save Record", "Save & Close")
    End Sub


    Protected Sub loadPreMed(dtPm As DataTable)
        Dim ConnString As [String] = DataAccess.ConnectionStr
        Dim sProcFieldName As String = ""
        conn = New SqlConnection(ConnString)
        conn.Open()

        'Add No sedation/premedication checkbox
        Dim cbNoSedation As New CheckBox
        cbNoSedation.Text = "No sedation/premedication"
        cbNoSedation.CssClass = "Metro"
        cbNoSedation.AutoPostBack = False
        cbNoSedation.ID = "NoSedationChkBox"
        cbNoSedation.ClientIDMode = System.Web.UI.ClientIDMode.Static
        'cbNoSedation.Attributes.Add("OnClick", "javascript:setDefaultValue(this)")
        Dim tRowNoSedation As New HtmlTableRow()
        Dim tCellNoSedation As New HtmlTableCell()
        tCellNoSedation.Controls.Add(cbNoSedation)
        tRowNoSedation.Cells.Add(tCellNoSedation)
        tableNoSedation.Rows.Add(tRowNoSedation)

        SetCtrlValues(dtPm, cbNoSedation, "-1", Nothing)


        'Add General anaesthetic checkbox
        Dim cbAnaesthetic As New CheckBox
        cbAnaesthetic.Text = "General anaesthetic"
        cbAnaesthetic.CssClass = "Metro"
        cbAnaesthetic.AutoPostBack = False
        cbAnaesthetic.ID = "GeneralAnaestheticChkBox"
        cbAnaesthetic.ClientIDMode = System.Web.UI.ClientIDMode.Static
        'cbNoSedation.Attributes.Add("OnClick", "javascript:setDefaultValue(this)")
        Dim tRowAnaesthetic As New HtmlTableRow()
        Dim tCellAnaesthetic As New HtmlTableCell()
        tCellAnaesthetic.Controls.Add(cbAnaesthetic)
        tRowAnaesthetic.Cells.Add(tCellAnaesthetic)
        tableAnaesthetic.Rows.Add(tRowAnaesthetic)

        SetCtrlValues(dtPm, cbAnaesthetic, "-2", Nothing)

        Select Case ProcType
            Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy
                sProcFieldName = "UsedInColonSig"
            Case ProcedureType.ERCP
                sProcFieldName = "UsedInERCP"
            Case ProcedureType.EUS_OGD
                sProcFieldName = "UsedInEUS_OGD"
            Case ProcedureType.EUS_HPB
                sProcFieldName = "UsedInEUS_HPB"
            Case ProcedureType.Antegrade
                sProcFieldName = "UsedInAntegrade"
            Case ProcedureType.Retrograde
                sProcFieldName = "UsedInRetrograde"
            Case Else
                sProcFieldName = "UsedInUpperGI"
        End Select

        Dim cmdString As String = "SELECT row_number() OVER (ORDER BY Drugname) AS tdOrderBy, * " & _
                            " INTO #DrugList FROM [ERS_DrugList] WHERE [" & sProcFieldName & "] = 1 AND [Drugtype] = 0 ORDER BY [Drugname] ASC; " & _
                            " UPDATE #DrugList SET tdOrderBy = 1 WHERE tdOrderBy <= ((select count(*) from #DrugList) / 2) ; " & _
                            " SELECT * FROM #DrugList ORDER BY tdOrderBy, DrugName ; " & _
                            " IF OBJECT_ID('tempdb..#DrugList') IS NOT NULL DROP TABLE #DrugList"
        'Dim cmdString As String = "SELECT * FROM [ERS_DrugList] WHERE [" & sProcFieldName & "] = 1 AND [Drugtype] = 0 ORDER BY [Drugname] ASC;"
        Dim sHTML As String = ""
        Dim iCtrlCount As Integer = 1
        'Dim newPanelID As Integer = 1
        Dim sSkinName As String = Session("SkinName").ToString

        Dim cmd As New SqlCommand(cmdString, conn)
        myReader = cmd.ExecuteReader()

        If myReader.HasRows Then
            'Dim lblHeader As New Label
            'lblHeader.Text = "Surname"
            'lblHeader.Style("Position") = "Static"
            'lblHeader.Font.Bold = True
            'panelPreMed.Controls.Add(lblHeader)

            Do While myReader.Read()
                'Dim txtDosage As New TextBox
                Dim txtDosage As New RadNumericTextBox

                txtDosage.Width = "80"
                txtDosage.ShowSpinButtons = True

                If sSkinName = "" Or sSkinName = "Unisoft" Then
                    txtDosage.Skin = "Metro"
                Else
                    txtDosage.Skin = Session("SkinName").ToString()
                End If
                If Not myReader("Doseincrement").ToString.Contains(".") Then
                    txtDosage.NumberFormat.DecimalDigits = 0
                End If
                txtDosage.CssClass = "spinAlign"
                'txtDosage.Text = myReader("Default dose").ToString
                txtDosage.IncrementSettings.Step = myReader("Doseincrement").ToString
                txtDosage.MinValue = "0"
                txtDosage.ID = "txtDosage" & iCtrlCount.ToString
                txtDosage.ClientIDMode = System.Web.UI.ClientIDMode.Static
                txtDosage.ClientEvents.OnValueChanged = "dosageChanged"



                Dim txtDrugNo As New TextBox
                txtDrugNo.Text = myReader("Drugno").ToString
                txtDrugNo.Visible = False

                'txtDosage.NumberFormat.DecimalSeparator = "."


                Dim lblResult As New Label
                If myReader("Units").ToString = "(none)" Then
                    lblResult.Text = ""
                Else
                    lblResult.Text = myReader("Units").ToString
                End If

                If Not IsDBNull(myReader("DoseNotApplicable")) AndAlso CBool(myReader("DoseNotApplicable")) = True Then
                    txtDosage.Visible = False
                    lblResult.Visible = False
                End If

                'When drugs don't have units *and* delivery method do not display txtDosage for the volume
                If Trim(myReader("Deliverymethod").ToString) = "" AndAlso Trim(myReader("Units").ToString) = "" Then
                    txtDosage.Visible = False
                    lblResult.Visible = False
                End If
                'lblResult.Style("top") = "3px"
                'lblResult.Style("Position") = "Absolute"
                'Dim chkBox As New CheckBox

                Dim chkBox As New CheckBox
                If Not IsDBNull(myReader("Deliverymethod")) AndAlso Trim(myReader("Deliverymethod")) <> "" Then
                    chkBox.Text = myReader("Drugname").ToString & " (" & myReader("Deliverymethod").ToString & ")"
                Else
                    chkBox.Text = myReader("Drugname").ToString
                End If

                If sSkinName = "" Or sSkinName = "Unisoft" Then
                    chkBox.CssClass = "Metro"
                Else
                    chkBox.CssClass = Session("SkinName").ToString()
                End If
                'chkBox.Width = "230"
                chkBox.AutoPostBack = False
                'chkBox.ButtonType = RadButtonType.ToggleButton
                'chkBox.ToggleType = ButtonToggleType.CheckBox
                chkBox.ID = "PreMedChkBox" & iCtrlCount.ToString
                chkBox.ClientIDMode = System.Web.UI.ClientIDMode.Static
                chkBox.Attributes.Add("OnClick", "javascript:setDefaultValue(this, '" + myReader("Defaultdose").ToString + "')")
                'chkBox.OnClientCheckedChanged = "setDefaultValue"
                'chkBox.CssClass = "drugclass"
                'chkBox.ValidationGroup = "PreVal"

                Dim hfDefDosage As New HiddenField
                hfDefDosage.Value = myReader("Defaultdose").ToString
                hfDefDosage.ID = "hfDefDosage" & iCtrlCount.ToString
                hfDefDosage.ClientIDMode = System.Web.UI.ClientIDMode.Static

                SetCtrlValues(dtPm, chkBox, myReader("Drugno").ToString, txtDosage)
                'If dtPm IsNot Nothing Then
                '    Dim dr() As System.Data.DataRow

                '    dr = dtPm.Select("DrugNo='" & myReader("Drugno").ToString & "'")
                '    If dr.Length > 0 Then
                '        chkBox.Checked = True
                '        txtDosage.Text = dr(0)("Dose").ToString()
                '    Else
                '        txtDosage.Text = ""
                '    End If
                'End If

                Dim tRow As New HtmlTableRow()
                Dim tCell1 As New HtmlTableCell()
                Dim tCell2 As New HtmlTableCell()

                tCell1.Controls.Add(chkBox)
                tRow.Cells.Add(tCell1)

                tCell2.Controls.Add(txtDosage)
                tCell2.Controls.Add(lblResult)
                tCell2.Controls.Add(txtDrugNo)
                tCell2.Controls.Add(hfDefDosage)

                tRow.Cells.Add(tCell2)
                'If iCtrlCount Mod 2 = 0 Then
                '    tablePreMed2.Rows.Add(tRow)
                'Else
                '    tablePreMed1.Rows.Add(tRow)
                'End If

                If myReader("tdOrderBy").ToString = "1" Then
                    tablePreMed1.Rows.Add(tRow)
                Else
                    tablePreMed2.Rows.Add(tRow)
                End If

                iCtrlCount = iCtrlCount + 1
                'If iCtrlCount > 10 Then
                '    newPanelID = 2
                'End If
            Loop
        Else
            'Response.Write("No rows found")
        End If

        myReader.Close()
    End Sub

    Protected Sub SetCtrlValues(dtPm As DataTable, ByVal chkBox As CheckBox, DrugNoVal As String, ByVal txtDosage As RadNumericTextBox)
        If dtPm IsNot Nothing Then
            Dim dr() As System.Data.DataRow

            dr = dtPm.Select("DrugNo='" & DrugNoVal & "'")
            If dr.Length > 0 Then
                chkBox.Checked = True
                If Not (txtDosage Is Nothing) Then txtDosage.Text = dr(0)("Dose").ToString()
            Else
                If Not (txtDosage Is Nothing) Then txtDosage.Text = ""
            End If
        End If
    End Sub

    Private Sub cmdSaveDefaults_Click(sender As Object, e As EventArgs) Handles cmdSaveDefaults.Click
        Dim da As New OtherData
        Dim sSQL As String = ""
        Dim iProcedureID As Integer = CInt(Session(Constants.SESSION_PROCEDURE_ID))
        sSQL = GenerateSQL(iProcedureID, True)

        Try
            da.SavePremedicationDefaults(CInt(Session("PKUserId")), sSQL)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Premedication defaults.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveOnly_Click(sender As Object, e As EventArgs) Handles SaveOnly.Click
        SavePremed(False)
    End Sub

    Protected Sub cmdAccept_Click(sender As Object, e As EventArgs) Handles cmdAccept.Click
        'MH added on 16 Sept 2021
        Dim ds As OtherData = New OtherData

        Dim blnBostonBowelPrepFlag = ds.BostonBowelPrepScale()

        If Not blnBostonBowelPrepFlag Then 'MH fixed on 16 Sept 2021: checking quality not required if Boston Bowel prep is on
            If (ProcType = ProcedureType.Colonoscopy Or ProcType = ProcedureType.Sigmoidscopy) AndAlso BowelPreparationQualityRadioButtonList.SelectedValue = "" Then
                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "show-err", "alert('Bowel prep quality is required');", True)
                Exit Sub
            End If

            If (ProcType = ProcedureType.Colonoscopy Or ProcType = ProcedureType.Sigmoidscopy) AndAlso (OffOralQuantityText.Text = "" AndAlso BowelPreparationQualityRadioButtonList.SelectedValue > 0) Then
                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "show-err", "alert('Bowel prep formula quantity is required');", True)
                Exit Sub
            End If
        End If

        SavePremed(True)
    End Sub

    Sub SavePremed(isSaveAndClose As Boolean)
        Dim da As New OtherData
        Dim sSQL As String = ""
        Dim iRowCount1 = tablePreMed1.Rows.Count
        Dim iRowCount2 = tablePreMed2.Rows.Count

        'Mahfuz added 17 Sept 2021 : BowelPrepValue losing its value from ViewState
        BowelPrepValue = da.BostonBowelPrepScale()

        Dim iProcedureID As Integer = CInt(Session(Constants.SESSION_PROCEDURE_ID))

        sSQL = GenerateSQL(iProcedureID, False)

        If sSQL.Length > 0 Then
            sSQL = Left(sSQL, sSQL.Length - 6)
            sSQL = "INSERT INTO ERS_UpperGIPremedication (ProcedureId, DrugNo, DrugName, Dose, Units, DeliveryMethod) " + sSQL
            If isSaveAndClose Then
                sSQL += "; IF EXISTS (SELECT 1 FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND Identifier = 'Premed') DELETE FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND Identifier = 'Premed'; INSERT INTO ERS_RecordCount (ProcedureId, Identifier, RecordCount) VALUES (" & iProcedureID & ",'Premed',1);"
            End If
        End If

            Try

            da.SaveUpperGIPremedication(iProcedureID, sSQL)
            If ProcType = ProcedureType.Colonoscopy Or ProcType = ProcedureType.Sigmoidscopy Then
                If BowelPrepLegendFieldsetOn.Visible Then ' BowelPrepValue is True
                    If Not NoBowelCheckBox.Checked Then
                        Dim right As Integer = CInt(IIf(RightRadNumericTextBox.Text = "", "0", RightRadNumericTextBox.Text))
                        Dim transverse As Integer = CInt(IIf(TransverseRadNumericTextBox.Text = "", "0", TransverseRadNumericTextBox.Text))
                        Dim left As Integer = CInt(IIf(LeftRadNumericTextBox.Text = "", "0", LeftRadNumericTextBox.Text))
                        Dim od As New DataAccess
                        If Trim(OnOralFormulationComboBox.Text) <> "" Then OnOralFormulationComboBox.SelectedValue = ValInsertListItem(od, OnOralFormulationComboBox, "Bowel_Preparation_Oral")
                        If Trim(OnEnemaFormulationComboBox.Text) <> "" Then OnEnemaFormulationComboBox.SelectedValue = ValInsertListItem(od, OnEnemaFormulationComboBox, "Bowel_Preparation_Enema")

                        da.SaveBowelPrepScale(iProcedureID, BowelPrepValue, False, OnOralFormulationComboBox.SelectedValue, OnOralFormulationComboBox.SelectedItem.Text, CInt(IIf(OnOralQuantityText.Text = "", 0, OnOralQuantityText.Text)), OnEnemaFormulationComboBox.SelectedValue, OnEnemaFormulationComboBox.SelectedItem.Text, OnCO2InsufflationCheckBox.Checked,
                                          right, transverse,
                                       left, CInt(IIf(TotalScoreLabel.Text = "", 0, TotalScoreLabel.Text)), False, "", 0, "", False)
                    Else
                        da.SaveBowelPrepScale(iProcedureID, BowelPrepValue, True, "", "", 0, "", "", False, 0, 0, 0, 0, False, "", 0, "", False)
                    End If

                Else
                    Dim od As New DataAccess
                    If Trim(OffOralFormulationComboBox.Text) <> "" Then OffOralFormulationComboBox.SelectedValue = ValInsertListItem(od, OffOralFormulationComboBox, "Bowel_Preparation_Oral")
                    If Trim(OffEnemaFormulationComboBox.Text) <> "" Then OffEnemaFormulationComboBox.SelectedValue = ValInsertListItem(od, OffEnemaFormulationComboBox, "Bowel_Preparation_Enema")
                    da.SaveBowelPrepScale(iProcedureID, BowelPrepValue, NoBowelCheckBox.Checked, "", "", 0, "", "", OffCO2InsufflationCheckBox.Checked, 0, 0, 0, 0, (BowelPreparationQualityRadioButtonList.SelectedValue = 0), OffOralFormulationComboBox.SelectedValue, If(String.IsNullOrWhiteSpace(OffOralQuantityText.Text), 0, OffOralQuantityText.Text), OffEnemaFormulationComboBox.SelectedValue,
                                          BowelPreparationQualityRadioButtonList.SelectedValue)
                End If
            End If

            'If CBool(Session("AdvancedMode")) Then
            '    Utilities.SetNotificationStyle(RadNotification1)
            '    RadNotification1.Show()

            '    ' Refresh the left side Summary panel that's on the master page
            '    If Me.Master.FindControl("SummaryListView") IsNot Nothing Then
            '        Dim lvSummary As ListView = DirectCast(Master.FindControl("SummaryListView"), ListView)
            '        lvSummary.DataBind()
            '    End If
            'Else
            '    Response.Redirect("~/Products/PatientProcedure.aspx")
            'End If
            If isSaveAndClose Then
                ExitForm()
            End If


            'Me.Master.SetButtonStyle()
            'Response.Redirect(Request.RawUrl, False)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Premedication.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

        Me.Master.SetButtonStyle()
    End Sub

    Function GenerateSQL(iProcedureID As Integer, bSaveDefault As Boolean) As String
        Dim sSQL As String = ""
        Dim iCount As Integer = 0
        Dim chkBoxNoSedation As CheckBox
        Dim chkBoxAnaesthetic As CheckBox

        'For Each row As HtmlTableRow In tableNoSedation.Rows
        chkBoxNoSedation = DirectCast(tableNoSedation.Rows(0).Cells(0).Controls(0), CheckBox)
        If chkBoxNoSedation.Checked Then
            If bSaveDefault Then
                sSQL += "-1~"
            Else
                sSQL += "SELECT " & iProcedureID & ",'-1', 'NoSedation', 0, '', ''   UNION "
            End If
        End If

        'For Each row As HtmlTableRow In tableAnaesthetic.Rows
        chkBoxAnaesthetic = DirectCast(tableAnaesthetic.Rows(0).Cells(0).Controls(0), CheckBox)
        If chkBoxAnaesthetic.Checked Then
            If bSaveDefault Then
                sSQL += "-2~"
            Else
                sSQL += "SELECT " & iProcedureID & ",'-2', 'GeneralAnaesthetic', 0, '', ''   UNION "
            End If
        End If

        If Not chkBoxNoSedation.Checked Then 'And Not chkBoxAnaesthetic.Checked Then
            For Each row As HtmlTableRow In tablePreMed1.Rows
                iCount += 1
                Dim chkBox As CheckBox = DirectCast(row.Cells(0).Controls(0), CheckBox)
                Dim txDose As RadNumericTextBox = DirectCast(row.Cells(1).Controls(0), RadNumericTextBox)
                Dim txtDrugNo As TextBox = DirectCast(row.Cells(1).Controls(2), TextBox)
                If chkBox.Checked Then
                    If bSaveDefault Then
                        sSQL += txtDrugNo.Text.ToString & IIf(txDose.Text.ToString = "", "", "|" & txDose.Text.ToString) & "~"
                    Else
                        sSQL += "SELECT " & iProcedureID & ",[Drugno], [Drugname], " & IIf(txDose.Text.ToString = "", "0", txDose.Text.ToString) & ",[Units], [Deliverymethod] FROM [ERS_Druglist] WHERE [Drugno] = " & txtDrugNo.Text.ToString & "  UNION "
                    End If
                End If
            Next

            For Each row As HtmlTableRow In tablePreMed2.Rows
                iCount += 1
                Dim chkBox As CheckBox = DirectCast(row.Cells(0).Controls(0), CheckBox)
                Dim txDose As RadNumericTextBox = DirectCast(row.Cells(1).Controls(0), RadNumericTextBox)

                Dim txtDrugNo As TextBox = DirectCast(row.Cells(1).Controls(2), TextBox)
                If chkBox.Checked Then
                    If bSaveDefault Then
                        sSQL += txtDrugNo.Text.ToString & IIf(txDose.Text.ToString = "", "", "|" & txDose.Text.ToString) & "~"
                    Else
                        sSQL += "SELECT " & iProcedureID & ",[Drugno], [Drugname], " & IIf(txDose.Text.ToString = "", "0", txDose.Text.ToString) & ",[Units], [Deliverymethod] FROM [ERS_Druglist] WHERE [Drugno] = " & txtDrugNo.Text.ToString & "  UNION "
                    End If
                End If
            Next
        End If
        GenerateSQL = sSQL
    End Function

    Protected Sub cancelRecord()
        ExitForm()
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

    Protected Sub InitMsg()
        If Session("UpdateDBFailed") = True Then Exit Sub

        Utilities.SetNotificationStyle(RadNotification1)
        RadNotification1.Show()
    End Sub

    ''' <summary>
    ''' This will validate the selected value of combobox before inserting.
    ''' </summary>
    Private Function ValInsertListItem(da As DataAccess, ByVal combobox As RadComboBox, ByVal listDescription As String) As Integer

        Dim itemName As String = combobox.Text
        'If Trim(itemName) = "" Then Return Nothing

        If combobox.SelectedValue = "-99" Then  'new item
            'Insert only if new item
            Dim iSelValue As Integer = da.InsertListItem(listDescription, itemName)
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{combobox, listDescription}})
            combobox.SelectedItem.Text = itemName
            combobox.SelectedValue = iSelValue ' da.InsertListItem(listDescription, itemName)
        End If

        Return combobox.SelectedValue

    End Function
End Class
