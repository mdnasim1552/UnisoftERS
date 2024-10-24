Imports System.Data.SqlClient
Imports Telerik.Web.UI

Public Class ReversalAgents
    Inherits OptionsBase

    Private conn As SqlConnection = Nothing
    Private myReader As SqlDataReader = Nothing
    Private ProcType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = Request.QueryString("title")
        Dim da As New OtherData
        Dim dtPm As DataTable = da.GetUpperGIPremedication(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

        selectedProcedureId.Value = CInt(Session(Constants.SESSION_PROCEDURE_ID))

        ProcType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        Dim ConnString As [String] = DataAccess.ConnectionStr
        Dim sProcFieldName As String = ""
        conn = New SqlConnection(ConnString)
        conn.Open()

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
            Case ProcedureType.EBUS
                sProcFieldName = "UsedInEBUS" 'MH added on 25 Apr 2022
            Case ProcedureType.Bronchoscopy
                sProcFieldName = "UsedInBroncho"
            Case ProcedureType.Flexi
                sProcFieldName = "UsedInFlexiCystoscopy"
            Case Else
                sProcFieldName = "UsedInUpperGI"
        End Select

        'Dim cmdString As String = "SELECT row_number() OVER (ORDER BY Drugname) AS tdOrderBy, * " &
        '                   " INTO #DrugList FROM [ERS_DrugList] WHERE [" & sProcFieldName & "] = 1 AND [Drugtype] = 0 AND [IsReversingAgent] = 1 ORDER BY [Drugname] ASC; " &
        '                   " UPDATE #DrugList SET tdOrderBy = 1 WHERE tdOrderBy <= ((select count(*) from #DrugList) / 2) ; " &
        '                   " SELECT * FROM #DrugList ORDER BY tdOrderBy, DrugName ; " &
        '                   " IF OBJECT_ID('tempdb..#DrugList') IS NOT NULL DROP TABLE #DrugList"

        Dim sHTML As String = ""
        Dim iCtrlCount As Integer = 1
        'Dim newPanelID As Integer = 1
        Dim sSkinName As String = Session("SkinName").ToString

        'Dim cmd As New SqlCommand(cmdString, conn)
        Dim cmd As New SqlCommand("get_reversal_agents_drug", conn)
        cmd.CommandType = CommandType.StoredProcedure
        cmd.Parameters.Add(New SqlParameter("@ProcedureFieldName", sProcFieldName))
        myReader = cmd.ExecuteReader()

        If myReader.HasRows Then

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

                Dim txtDrugNo As New TextBox
                txtDrugNo.Text = myReader("Drugno").ToString
                txtDrugNo.Visible = False

                Dim lblResult As New Label
                lblResult.Text = myReader("Units").ToString
                If Not IsDBNull(myReader("DoseNotApplicable")) AndAlso CBool(myReader("DoseNotApplicable")) = True Then
                    txtDosage.Visible = False
                    lblResult.Visible = False
                End If

                'When drugs don't have units *and* delivery method do not display txtDosage for the volume
                If Trim(myReader("Deliverymethod").ToString) = "" AndAlso Trim(myReader("Units").ToString) = "" Then
                    txtDosage.Visible = False
                    lblResult.Visible = False
                End If

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
                chkBox.AutoPostBack = False
                chkBox.ID = "PreMedChkBox" & iCtrlCount.ToString
                chkBox.ClientIDMode = System.Web.UI.ClientIDMode.Static
                chkBox.Attributes.Add("OnClick", "javascript:setDefaultValue(this)")

                Dim hfDefDosage As New HiddenField
                hfDefDosage.Value = myReader("Defaultdose").ToString
                hfDefDosage.ID = "hfDefDosage" & iCtrlCount.ToString
                hfDefDosage.ClientIDMode = System.Web.UI.ClientIDMode.Static

                If dtPm IsNot Nothing Then
                    Dim dr() As System.Data.DataRow

                    dr = dtPm.Select("DrugNo='" & myReader("Drugno").ToString & "'")
                    If dr.Length > 0 Then
                        chkBox.Checked = True
                        txtDosage.Text = dr(0)("Dose").ToString()
                    Else
                        txtDosage.Text = ""
                    End If
                End If

                Dim tRow As New HtmlTableRow()
                Dim tCell1 As New HtmlTableCell()
                Dim tCell2 As New HtmlTableCell()

                tCell1.Controls.Add(chkBox)
                tRow.Cells.Add(tCell1)

                tCell2.Controls.Add(txtDosage)
                tCell2.Controls.Add(lblResult)
                tCell2.Controls.Add(txtDrugNo)
                tCell2.Controls.Add(hfDefDosage)
                tCell2.Controls.Add(maxDoseLimit)
                tCell2.Controls.Add(drugName)

                tRow.Cells.Add(tCell2)

                tablePostMed.Rows.Add(tRow)


                iCtrlCount = iCtrlCount + 1
            Loop
        End If

        myReader.Close()

    End Sub

    Protected Sub SaveReversalAgentsRadButton_Click(sender As Object, e As EventArgs)
        Dim sSQL As New StringBuilder
        Dim sGeneratedSQL = ""
        Dim sDrugIDs = ""
        Dim iProcedureID = selectedProcedureId.Value
        Dim alertMessage = ""
        For Each row As HtmlTableRow In tablePostMed.Rows
            Dim chkBox As CheckBox = DirectCast(row.Cells(0).Controls(0), CheckBox)
            Dim txDose As RadNumericTextBox = DirectCast(row.Cells(1).Controls(0), RadNumericTextBox)
            Dim txtDrugNo As TextBox = DirectCast(row.Cells(1).Controls(2), TextBox)
            Dim drugName As String = TryCast(row.Cells(1).Controls(5), Label).Text
            Dim maximumDose As String = TryCast(row.Cells(1).Controls(4), Label).Text

            Dim dosageVal As Double = 0
            If txDose.Text.Trim <> "" Then
                dosageVal = CDbl(txDose.Text)
            End If
            Dim maximumDosageVal As Double = 0
            If maximumDose.Trim <> "" Then
                maximumDosageVal = CDbl(maximumDose)
            Else
                maximumDosageVal = Integer.MaxValue
            End If

            If dosageVal > maximumDosageVal Then
                alertMessage += "The maximum recommended drug dose for " + drugName + " is " + maximumDose + ".<br>"
            End If
            'sDrugIDs += CInt(txtDrugNo.Text) & ","

            'If chkBox.Checked Then
            '    sGeneratedSQL += "SELECT " & iProcedureID & ",[Drugno], [Drugname], '" & IIf(txDose.Text.ToString = "", "0", txDose.Text.ToString) & "',[Units], [Deliverymethod], " & CInt(Session("PKUserID")) & ", GETDATE() FROM [ERS_Druglist] WHERE [Drugno] = " & txtDrugNo.Text.ToString & "  UNION "
            'End If
        Next

        If alertMessage <> "" Then
            alertMessage += "Do you want to continue?"
            lblMessage.Text = alertMessage
            MaximumDoseLimitCrossRadWindow.VisibleOnPageLoad = True
        End If

        'If sGeneratedSQL.Length > 0 Then
        '    sGeneratedSQL = Left(sGeneratedSQL, sGeneratedSQL.Length - 6)
        '    sGeneratedSQL = "DELETE FROM ERS_UpperGIPremedication WHERE ProcedureId = " + iProcedureID + " AND DrugNo IN (" & sDrugIDs.Remove(sDrugIDs.Length - 1, 1) & ") " &
        '                    "INSERT INTO ERS_UpperGIPremedication (ProcedureId, DrugNo, DrugName, Dose, Units, DeliveryMethod, WhoCreatedId, WhenCreated) " + sGeneratedSQL.ToString()

        '    Dim cmd As New SqlCommand(sGeneratedSQL, conn)
        '    cmd.ExecuteReader()
        'End If

        'ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "CloseMe", "CloseWindow();", True)
    End Sub

    Protected Sub ContinueRadButton_Click(sender As Object, e As EventArgs)
        Dim sSQL As New StringBuilder
        Dim sGeneratedSQL = ""
        Dim sDrugIDs = ""
        Dim iProcedureID = selectedProcedureId.Value
        For Each row As HtmlTableRow In tablePostMed.Rows
            Dim chkBox As CheckBox = DirectCast(row.Cells(0).Controls(0), CheckBox)
            Dim txDose As RadNumericTextBox = DirectCast(row.Cells(1).Controls(0), RadNumericTextBox)
            Dim txtDrugNo As TextBox = DirectCast(row.Cells(1).Controls(2), TextBox)
            sDrugIDs += CInt(txtDrugNo.Text) & ","

            If chkBox.Checked Then
                sGeneratedSQL += "SELECT " & iProcedureID & ",[Drugno], [Drugname], '" & IIf(txDose.Text.ToString = "", "0", txDose.Text.ToString) & "',[Units], [Deliverymethod], " & CInt(Session("PKUserID")) & ", GETDATE() FROM [ERS_Druglist] WHERE [Drugno] = " & txtDrugNo.Text.ToString & "  UNION "
            End If
        Next

        If sGeneratedSQL.Length > 0 Then
            sGeneratedSQL = Left(sGeneratedSQL, sGeneratedSQL.Length - 6)
            sGeneratedSQL = "DELETE FROM ERS_UpperGIPremedication WHERE ProcedureId = " + iProcedureID + " AND DrugNo IN (" & sDrugIDs.Remove(sDrugIDs.Length - 1, 1) & ") " &
                            "INSERT INTO ERS_UpperGIPremedication (ProcedureId, DrugNo, DrugName, Dose, Units, DeliveryMethod, WhoCreatedId, WhenCreated) " + sGeneratedSQL.ToString()

            Dim cmd As New SqlCommand(sGeneratedSQL, conn)
            cmd.ExecuteReader()
            Dim da As DataAccess = New DataAccess()
            da.Update_ogd_premedication_summary(iProcedureID)
        End If
        ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "CloseMe", "CloseWindow();", True)
    End Sub
End Class