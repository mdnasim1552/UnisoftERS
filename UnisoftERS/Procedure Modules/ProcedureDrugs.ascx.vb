Imports System.Data.SqlClient
Imports Telerik.Web.UI

Public Class ProcedureDrugs
    Inherits ProcedureControls

    Private conn As SqlConnection = Nothing
    Private myReader As SqlDataReader = Nothing
    Private ProcType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        ProcType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        If Not Page.IsPostBack Then
            Dim da As New OtherData
            Dim dtPm As DataTable

            dtPm = da.GetUpperGIPremedication(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

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

        'If Not ProcType = ProcedureType.Bronchoscopy And Not ProcType = ProcedureType.EBUS Then
        'Add No sedation/premedication checkbox
        Dim cbNoSedation As New CheckBox
            cbNoSedation.Text = "No sedation/premedication"
            cbNoSedation.CssClass = "Metro no-sedation"
            cbNoSedation.AutoPostBack = False
            cbNoSedation.ID = "NoSedationChkBox"
            cbNoSedation.ClientIDMode = System.Web.UI.ClientIDMode.Static
            cbNoSedation.Attributes("onclick") = "dosageChanged"


            'cbNoSedation.Attributes.Add("OnClick", "javascript:setDefaultValue(this)")
            Dim tRowNoSedation As New HtmlTableRow()
            Dim tCellNoSedation As New HtmlTableCell()
            tCellNoSedation.Controls.Add(cbNoSedation)
            tRowNoSedation.Cells.Add(tCellNoSedation)
            tableNoSedation.Rows.Add(tRowNoSedation)

            SetCtrlValues(dtPm, cbNoSedation, "-1", Nothing, Nothing)


            'Add General anaesthetic checkbox
            Dim cbAnaesthetic As New CheckBox
            cbAnaesthetic.Text = "General anaesthetic"
            cbAnaesthetic.CssClass = "Metro general-anaesthetic"
            cbAnaesthetic.AutoPostBack = False
            cbAnaesthetic.ID = "GeneralAnaestheticChkBox"
            cbAnaesthetic.ClientIDMode = System.Web.UI.ClientIDMode.Static
            cbNoSedation.Attributes("onclick") = "dosageChanged"

            Dim tRowAnaesthetic As New HtmlTableRow()
            Dim tCellAnaesthetic As New HtmlTableCell()
            tCellAnaesthetic.Controls.Add(cbAnaesthetic)
            tRowAnaesthetic.Cells.Add(tCellAnaesthetic)
            tableAnaesthetic.Rows.Add(tRowAnaesthetic)

            SetCtrlValues(dtPm, cbAnaesthetic, "-2", Nothing, Nothing)
        'End If

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
            Case ProcedureType.Bronchoscopy
                sProcFieldName = "UsedInBroncho"
            Case ProcedureType.EBUS
                sProcFieldName = "UsedInEBUS"
            Case ProcedureType.Flexi
                sProcFieldName = "UsedInFlexiCystoscopy"
            Case Else
                sProcFieldName = "UsedInUpperGI"
        End Select

        Dim iCtrlCount As Integer = 1
        'Dim newPanelID As Integer = 1
        Dim sSkinName As String = Session("SkinName").ToString

        Dim cmd As New SqlCommand("get_pre_med_drug", conn)
        cmd.CommandType = CommandType.StoredProcedure
        cmd.Parameters.Add(New SqlParameter("@ProcedureFieldName", sProcFieldName))
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
                txtDosage.Width = "55"
                txtDosage.Style.Add("margin-right", "3px")

                If sSkinName = "" Or sSkinName = "Unisoft" Then
                    txtDosage.Skin = "Metro"
                Else
                    txtDosage.Skin = Session("SkinName").ToString()
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

                Dim lblResult As New Label
                lblResult.ID = "lblUnits" & iCtrlCount.ToString
                lblResult.ClientIDMode = System.Web.UI.ClientIDMode.Static


                Dim maxDoseLimit As New Label
                maxDoseLimit.ID = "maxDoseLimit" & iCtrlCount.ToString
                If Not IsDBNull(myReader("MaximumDose")) Then
                    maxDoseLimit.Text = myReader("MaximumDose").ToString
                Else
                    maxDoseLimit.Text = Integer.MaxValue.ToString
                End If
                maxDoseLimit.ClientIDMode = System.Web.UI.ClientIDMode.Static
                maxDoseLimit.Style.Add("display", "none")

                Dim drugName As New Label
                drugName.ID = "drugName" & iCtrlCount.ToString
                drugName.Text = myReader("Drugname").ToString
                drugName.ClientIDMode = System.Web.UI.ClientIDMode.Static
                drugName.Style.Add("display", "none")

                Dim ddlUnits As New RadComboBox
                ddlUnits.ID = "ddlUnits" & iCtrlCount.ToString
                ddlUnits.Skin = "Metro"
                ddlUnits.Width = 50
                ddlUnits.ClientIDMode = System.Web.UI.ClientIDMode.Static
                ddlUnits.OnClientSelectedIndexChanged = "unitsChanged"
                ddlUnits.AutoPostBack = False

                If myReader("Units").ToString.Contains(",") Then
                    For Each unit In myReader("Units").ToString.Split(",")
                        ddlUnits.Items.Add(New RadComboBoxItem(unit))
                    Next

                    ddlUnits.SelectedIndex = 0
                Else
                    If myReader("Units").ToString = "(none)" Then
                        lblResult.Text = ""
                    Else
                        lblResult.Text = myReader("Units").ToString
                    End If
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
                chkBox.ID = "PreMedChkBox" & iCtrlCount.ToString
                chkBox.ClientIDMode = System.Web.UI.ClientIDMode.Static
                chkBox.Attributes.Add("OnClick", "javascript:setDefaultValue(this)")
                'chkBox.CssClass = "drugclass"

                Dim hfDefDosage As New HiddenField
                hfDefDosage.Value = myReader("Defaultdose").ToString
                hfDefDosage.ID = "hfDefDosage" & iCtrlCount.ToString
                hfDefDosage.ClientIDMode = System.Web.UI.ClientIDMode.Static

                Dim hfDrugId As New HiddenField
                hfDrugId.Value = myReader("Drugno").ToString
                hfDrugId.ID = "hfDrugId" & iCtrlCount.ToString
                hfDrugId.ClientIDMode = System.Web.UI.ClientIDMode.Static

                SetCtrlValues(dtPm, chkBox, myReader("Drugno").ToString, txtDosage, ddlUnits)
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
                If Not myReader("Units").ToString.Contains(",") Then
                    tCell2.Controls.Add(lblResult)
                Else
                    tCell2.Controls.Add(ddlUnits)
                End If

                tCell2.Controls.Add(txtDrugNo)
                tCell2.Controls.Add(hfDefDosage)
                tCell2.Controls.Add(hfDrugId)
                tCell2.Controls.Add(maxDoseLimit)
                tCell2.Controls.Add(drugName)

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

    Protected Sub SetCtrlValues(dtPm As DataTable, ByVal chkBox As CheckBox, DrugNoVal As String, ByVal txtDosage As RadNumericTextBox, ByVal ddlDropdown As RadComboBox)
        If dtPm IsNot Nothing Then
            Dim dr() As System.Data.DataRow

            dr = dtPm.Select("DrugNo='" & DrugNoVal & "'")
            If dr.Length > 0 Then
                chkBox.Checked = True
                If Not (txtDosage Is Nothing) Then txtDosage.Text = dr(0)("Dose").ToString()
            Else
                If Not (txtDosage Is Nothing) Then txtDosage.Text = ""
            End If

            Dim units = dtPm.Rows(0)("units")
            If (ddlDropdown IsNot Nothing And units IsNot Nothing) Then
                ddlDropdown.SelectedIndex = ddlDropdown.Items.FindItemIndexByText(units)
            End If

        End If
    End Sub


    Sub SavePremed()
        Dim da As New OtherData
        Dim sSQL As String = ""
        Dim iRowCount1 = tablePreMed1.Rows.Count
        Dim iRowCount2 = tablePreMed2.Rows.Count

        Dim iProcedureID As Integer = CInt(Session(Constants.SESSION_PROCEDURE_ID))

        sSQL = GenerateSQL(iProcedureID, False)

        If sSQL.Length > 0 Then
            sSQL = Left(sSQL, sSQL.Length - 6)
            sSQL = "INSERT INTO ERS_UpperGIPremedication (ProcedureId, DrugNo, DrugName, Dose, Units, DeliveryMethod) " + sSQL
            sSQL += "; INSERT INTO ERS_RecordCount (ProcedureId, Identifier, RecordCount) VALUES (" & iProcedureID & ",'Premed',1)"
        End If

        Try
            da.SaveUpperGIPremedication(iProcedureID, sSQL)
            Dim daa As DataAccess = New DataAccess()
            daa.Update_ogd_premedication_summary(iProcedureID)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Premedication.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

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

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        If e.Argument = "reloaddrugs" Then
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
        ElseIf e.Argument = "savedefaults" Then
            Dim da As New OtherData
            Dim sSQL As String = ""
            Dim iProcedureID As Integer = CInt(Session(Constants.SESSION_PROCEDURE_ID))

            If tableNoSedation.Rows.Count > 0 Then
                sSQL = GenerateSQL(iProcedureID, True)

                Try
                    da.SavePremedicationDefaults(CInt(Session("PKUserId")), sSQL)
                Catch ex As Exception
                    Dim errorLogRef As String
                    errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Premedication defaults.", ex)

                    Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
                    RadNotification1.Show()
                End Try
            End If
        End If
    End Sub

    Protected Sub ForceReloadButton_Click(sender As Object, e As EventArgs)
        Dim da As New OtherData
        Dim dtPm As DataTable

        dtPm = da.GetUpperGIPremedication(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

        If Not dtPm Is Nothing AndAlso dtPm.Rows.Count > 0 Then
            loadPreMed(dtPm)
        Else
            If Not dtPm Is Nothing AndAlso dtPm.Rows.Count > 0 Then
                loadPreMed(dtPm)
                For Each dr As DataRow In dtPm.Rows
                    ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "add-drug" & dr("DrugNo").ToString, "saveProcedureDrug(" & CInt(dr("DrugNo")) & ", " & CInt(dr("DOSE")) & ", 0, 'true');", True)
                Next
            Else
                loadPreMed(Nothing)
            End If
        End If

    End Sub
End Class