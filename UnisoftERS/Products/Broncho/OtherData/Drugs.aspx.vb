Imports Telerik.Web.UI
Imports System.Data.SqlClient
Public Class Products_Broncho_OtherData_Drugs
    Inherits PageBase

    Private procType As Integer
    Private conn As SqlConnection = Nothing
    Private myReader As SqlDataReader = Nothing

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim da As New OtherData
        procType = IInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        If Not Page.IsPostBack Then

            Dim dtDrugs As DataTable = da.GetBronchoDrugs(IInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtDrugs.Rows.Count > 0 Then
                PopulateData(dtDrugs.Rows(0))
            End If



            ' DrugTypeRadComboBox.SelectedValue = Request.QueryString("option")

            'Dim dtPm As DataTable = da.GetUpperGIPremedication(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            'If Not dtPm Is Nothing AndAlso dtPm.Rows.Count > 0 Then
            '    loadPreMed(dtPm)
            'Else
            '    'Load default values for current user
            '    dtPm = da.GetUpperGIPremedicationDefault(CInt(Session("PKUserId")))
            '    If Not dtPm Is Nothing AndAlso dtPm.Rows.Count > 0 Then
            '        loadPreMed(dtPm)
            '    Else
            '        loadPreMed(Nothing)
            '    End If
            'End If

        End If

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

        Select Case procType
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
            Case ProcedureType.Bronchoscopy
                sProcFieldName = "UsedInBroncho"
            Case Else
                sProcFieldName = "UsedInUpperGI"
        End Select

        Dim cmdString As String = "SELECT row_number() OVER (ORDER BY Drugname) AS tdOrderBy, * " &
                            " INTO #DrugList FROM [ERS_DrugList] WHERE [" & sProcFieldName & "] = 1 AND [Drugtype] = 0 ORDER BY [Drugname] ASC; " &
                            " UPDATE #DrugList SET tdOrderBy = 1 WHERE tdOrderBy <= ((select count(*) from #DrugList) / 2) ; " &
                            " SELECT * FROM #DrugList ORDER BY tdOrderBy, DrugName ; " &
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

                txtDosage.Width = "65"

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
                txtDosage.IncrementSettings.InterceptMouseWheel = False
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
                chkBox.Attributes.Add("OnClick", "javascript:setDefaultValue(this)")
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



    'Protected Sub DrugsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles DrugsRadGrid.ItemCreated
    '    If TypeOf e.Item Is GridDataItem Then
    '        Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
    '        EditLinkButton.Attributes("href") = "javascript:void(0);"
    '        EditLinkButton.Attributes("onclick") = String.Format("return ShowEditForm('{0}','{1}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DrugNo"), e.Item.ItemIndex)
    '    End If
    'End Sub

    'Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
    '    If e.Argument = "Rebind" Then
    '        DrugsRadGrid.MasterTableView.SortExpressions.Clear()
    '        DrugsRadGrid.Rebind()
    '    ElseIf e.Argument = "RebindAndNavigate" Then
    '        DrugsRadGrid.MasterTableView.SortExpressions.Clear()
    '        DrugsRadGrid.MasterTableView.CurrentPageIndex = DrugsRadGrid.MasterTableView.PageCount - 1
    '        DrugsRadGrid.Rebind()
    '    End If
    'End Sub




    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        ExitForm()
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

    Private Sub PopulateData(drDrugs As DataRow)
        'EffectOfSedationRadioButtonList.SelectedValue = CInt(drDrugs("EffectOfSedation"))
        LignocaineSprayCheckBox.Checked = CBool(drDrugs("LignocaineSpray"))
        LignocaineGelCheckBox.Checked = CBool(drDrugs("LignocaineGel"))
        If Not IsDBNull(drDrugs("LignocaineViaScope1pc")) Then LignocaineViaScope1pcTextBox.Value = CDec(drDrugs("LignocaineViaScope1pc"))
        If Not IsDBNull(drDrugs("LignocaineViaScope2pc")) Then LignocaineViaScope2pcTextBox.Value = CDec(drDrugs("LignocaineViaScope2pc"))
        If Not IsDBNull(drDrugs("LignocaineViaScope4pc")) Then LignocaineViaScope4pcTextBox.Value = CDec(drDrugs("LignocaineViaScope4pc"))
        If Not IsDBNull(drDrugs("LignocaineNebuliser2pc")) Then LignocaineNebuliser2pcTextBox.Value = CDec(drDrugs("LignocaineNebuliser2pc"))
        If Not IsDBNull(drDrugs("LignocaineNebuliser4pc")) Then LignocaineNebuliser4pcTextBox.Value = CDec(drDrugs("LignocaineNebuliser4pc"))
        If Not IsDBNull(drDrugs("LignocaineTranscricoid2pc")) Then LignocaineTranscricoid2pcTextBox.Value = CDec(drDrugs("LignocaineTranscricoid2pc"))
        If Not IsDBNull(drDrugs("LignocaineTranscricoid4pc")) Then LignocaineTranscricoid4pcTextBox.Value = CDec(drDrugs("LignocaineTranscricoid4pc"))
        If Not IsDBNull(drDrugs("LignocaineBronchial1pc")) Then LignocaineBronchial1pcTextBox.Value = CDec(drDrugs("LignocaineBronchial1pc"))
        If Not IsDBNull(drDrugs("LignocaineBronchial2pc")) Then LignocaineBronchial2pcTextBox.Value = CDec(drDrugs("LignocaineBronchial2pc"))
        SupplyOxygenCheckBox.Checked = CBool(drDrugs("SupplyOxygen"))
        If Not IsDBNull(drDrugs("SupplyOxygenPercentage")) Then SupplyOxygenPercentageTextBox.Value = CDec(drDrugs("SupplyOxygenPercentage"))
        If Not IsDBNull(drDrugs("Nasal")) Then NasalTextBox.Value = CDec(drDrugs("Nasal"))
        If Not IsDBNull(drDrugs("SpO2Base")) Then SpO2BaseTextBox.Value = CDec(drDrugs("SpO2Base"))
        If Not IsDBNull(drDrugs("SpO2Min")) Then SpO2MinTextBox.Value = CDec(drDrugs("SpO2Min"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Dim da As New OtherData

        Try
            'For Each item As RepeaterItem In DrugsRepeater.Items
            '    Dim DoseNumericTextBox As RadNumericTextBox = item.FindControl("DoseNumericTextBox")
            '    Dim DrugNoHiddenField As HiddenField = item.FindControl("DrugNoHiddenField")

            '    Dim dose As Nullable(Of Decimal) = Utilities.GetNumericTextBoxValue(DoseNumericTextBox, True)
            '    Dim drugNo As Integer = CInt(DrugNoHiddenField.Value)

            '    da.SaveBronchoPremedication(IInt(Session(Constants.SESSION_PROCEDURE_ID)), drugNo, dose)
            'Next
            SavePremed(True)

            da.SaveBronchoDrugs(IInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                Nothing, 'Utilities.GetRadioValue(EffectOfSedationRadioButtonList),
                                LignocaineSprayCheckBox.Checked,
                                LignocaineGelCheckBox.Checked,
                                Utilities.GetNumericTextBoxValue(LignocaineSprayTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineViaScope1pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineViaScope2pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineViaScope4pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineNebuliser2pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineNebuliser4pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineTranscricoid2pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineTranscricoid4pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineBronchial1pcTextBox),
                                Utilities.GetNumericTextBoxValue(LignocaineBronchial2pcTextBox),
                                SupplyOxygenCheckBox.Checked,
                                Utilities.GetNumericTextBoxValue(SupplyOxygenPercentageTextBox),
                                Utilities.GetNumericTextBoxValue(NasalTextBox),
                                Utilities.GetNumericTextBoxValue(SpO2BaseTextBox),
                                Utilities.GetNumericTextBoxValue(SpO2MinTextBox), 0)

            Dim dtIn As DataTable = da.GetUpperGIIndications(IInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtIn.Rows.Count > 0 Then
                PopulateData(dtIn.Rows(0))
            End If

            ExitForm()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Bronchoscopy Drugs.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Sub SavePremed(isSaveAndClose As Boolean)
        Dim da As New OtherData
        Dim sSQL As String = ""
        Dim iRowCount1 = tablePreMed1.Rows.Count
        Dim iRowCount2 = tablePreMed2.Rows.Count

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
            Dim daa As DataAccess = New DataAccess()
            daa.Update_ogd_premedication_summary(iProcedureID)
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



            'Me.Master.SetButtonStyle()
            'Response.Redirect(Request.RawUrl, False)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving Upper GI Premedication.", ex)

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

End Class