Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_OGD_Varices
    Inherits SiteDetailsBase

    Private Shared siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            DisplayControls()
            Dim dtVa As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_varices_select")
            If dtVa.Rows.Count > 0 Then
                PopulateData(dtVa.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drVa As DataRow)
        NoneCheckBox.Checked = CBool(drVa("None"))
        GradingRadioButtonList.Text = CInt(drVa("Grading"))
        MultipleCheckBox.Checked = CBool(drVa("Multiple"))
        If Not IsDBNull(drVa("Quantity")) Then QuantityNumericTextBox.Value = CInt(drVa("Quantity"))
        BleedingRadioButtonList.Text = CInt(drVa("Bleeding"))
        RedSignRadioButtonList.Text = CInt(drVa("RedSign"))
        WhiteFibrinClotCheckBox.Checked = CBool(drVa("WhiteFibrinClot"))
    End Sub

    Private Sub DisplayControls()
        Dim sArea As String = Request.QueryString("Area")
        If Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Colonoscopy Or Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Sigmoidscopy Or Session(Constants.SESSION_PROCEDURE_TYPE) = ProcedureType.Retrograde Then
            sArea = "Colon"
        End If

        Select Case sArea
            Case "Oesophagus"
                RedSignFieldset.Visible = True
                'GradingRadioButtonList.Items.Add(New ListItem("Probable", 1))
                'GradingRadioButtonList.Items.Add(New ListItem("Barely noticeable", 2))
                'GradingRadioButtonList.Items.Add(New ListItem("Protrusion to 1/4 of lumen", 3))
                'GradingRadioButtonList.Items.Add(New ListItem("Protrusion to 1/2 of lumen", 4))
                'GradingRadioButtonList.Items.Add(New ListItem("Protrusion greater than 1/2 of lumen", 5))

                'New grading for varices
                GradingRadioButtonList.Items.Add(New ListItem("<b>Grade I</b> - These collapse on inflation of the oesophagus with air", 1))
                GradingRadioButtonList.Items.Add(New ListItem("<b>Grade II</b> - These are varices between I and III", 2))
                GradingRadioButtonList.Items.Add(New ListItem("<b>Grade III</b> - These are large enough to occlude the lumen", 3))
                GradingRadioButtonList.RepeatDirection = RepeatDirection.Vertical

                BleedingRadioButtonList.Items.Add(New ListItem("None", 1))
                BleedingRadioButtonList.Items.Add(New ListItem("Fresh clot", 2))
                BleedingRadioButtonList.Items.Add(New ListItem("Altered blood", 3))
                BleedingRadioButtonList.Items.Add(New ListItem("Active bleeding", 4))
                BleedingRadioButtonList.Items.Add(New ListItem("Signs of recent bleeding", 5))
            Case "Stomach", "Duodenum", "Colon"
                RedSignFieldset.Visible = False
                WhiteFibrinClotCheckBox.Visible = False
                GradingRadioButtonList.Items.Add(New ListItem("Small", 1))
                GradingRadioButtonList.Items.Add(New ListItem("Medium", 2))
                GradingRadioButtonList.Items.Add(New ListItem("Large", 3))
                GradingRadioButtonList.RepeatDirection = RepeatDirection.Horizontal

                BleedingRadioButtonList.Items.Add(New ListItem("None", 1))
                BleedingRadioButtonList.Items.Add(New ListItem("Fibrin plug", 2))
                BleedingRadioButtonList.Items.Add(New ListItem("Fresh clot", 3))
                BleedingRadioButtonList.Items.Add(New ListItem("Red sign", 4))
                BleedingRadioButtonList.Items.Add(New ListItem("Active bleeding", 5))
        End Select

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesDataAdapter.SaveVaricesData(
                siteId,
                NoneCheckBox.Checked,
                Utilities.GetRadioValue(GradingRadioButtonList),
                MultipleCheckBox.Checked,
                QuantityNumericTextBox.Value,
                Utilities.GetRadioValue(BleedingRadioButtonList),
                Utilities.GetRadioValue(RedSignRadioButtonList),
                WhiteFibrinClotCheckBox.Checked)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Varices.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
