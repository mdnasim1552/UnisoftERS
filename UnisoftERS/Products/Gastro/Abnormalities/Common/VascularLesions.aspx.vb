Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Common_VascularLesions
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            DisplayControls()
            Dim dtVa As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_vascular_lesions_select")
            If dtVa.Rows.Count > 0 Then
                PopulateData(dtVa.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drVa As DataRow)
        NoneCheckBox.Checked = CBool(drVa("None"))
        TypeRadioButtonList.Text = CInt(drVa("Type"))
        MultipleCheckBox.Checked = CBool(drVa("Multiple"))
        If Not IsDBNull(drVa("Quantity")) Then QuantityNumericTextBox.Value = CInt(drVa("Quantity"))
        BleedingRadioButtonList.Text = CInt(drVa("Bleeding"))

    End Sub
        
    Private Sub DisplayControls()
        Dim procType As Integer = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        If procType = ProcedureType.Gastroscopy Or procType = ProcedureType.EUS_OGD Or procType = ProcedureType.Antegrade Or procType = ProcedureType.Transnasal Then
            Dim sArea As String = Request.QueryString("Area")
            Select Case sArea
                Case "Oesophagus"
                    TypeRadioButtonList.Items.Add(New ListItem("Telangiectasia", 1))
                    BleedingFieldset.Visible = False
                Case "Stomach"
                    TypeRadioButtonList.Items.Add(New ListItem("Telangiectasia", 1))
                    TypeRadioButtonList.Items.Add(New ListItem("Angiodysplasia (<5mm)", 2))
                    TypeRadioButtonList.Items.Add(New ListItem("Angiodysplasia (>5mm)", 3))
                    TypeRadioButtonList.Items.Add(New ListItem("Angiodysplasia (large and small lesions)", 4))
                    TypeRadioButtonList.Items.Add(New ListItem("Portal hypertensive gastropathy", 5))
                    TypeRadioButtonList.Items.Add(New ListItem("Watermelon stomach", 6))
                    TypeRadioButtonList.Items.Add(New ListItem("Dieulafoy lesion", 7))
                    'If Not procType = ProcedureType.Antegrade And Not procType = ProcedureType.Gastroscopy Then
                    '    TypeRadioButtonList.Items.Add(New ListItem("Varices", 7))
                    'End If

                    BleedingRadioButtonList.Items.Add(New ListItem("None", 1))
                    BleedingRadioButtonList.Items.Add(New ListItem("Fresh clot", 2))
                    BleedingRadioButtonList.Items.Add(New ListItem("Altered blood", 3))
                    BleedingRadioButtonList.Items.Add(New ListItem("Active bleeding", 4))
                Case "Duodenum", "Jejunum", "Ileum", "Colon"
                    TypeRadioButtonList.Items.Add(New ListItem("Telangiectasia", 1))
                    TypeRadioButtonList.Items.Add(New ListItem("Angiodysplasia (<5mm)", 2))
                    TypeRadioButtonList.Items.Add(New ListItem("Angiodysplasia (>5mm)", 3))
                    TypeRadioButtonList.Items.Add(New ListItem("Angiodysplasia (large and small lesions)", 4))
                    'TypeRadioButtonList.Items.Add(New ListItem("Varices", 5))

                    BleedingRadioButtonList.Items.Add(New ListItem("None", 1))
                    BleedingRadioButtonList.Items.Add(New ListItem("Fibrin plug", 2))
                    BleedingRadioButtonList.Items.Add(New ListItem("Fresh clot", 3))
                    BleedingRadioButtonList.Items.Add(New ListItem("Red sign", 4))
                    BleedingRadioButtonList.Items.Add(New ListItem("Active bleeding", 5))
                    ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "ChkArea", "isDuodenum = true;", True)
            End Select

        ElseIf procType = ProcedureType.ERCP Or procType = ProcedureType.EUS_HPB Then
            TypeRadioButtonList.Items.Add(New ListItem("Telangiectasia", 1))
            TypeRadioButtonList.Items.Add(New ListItem("Angiodysplasia (<5mm)", 2))
        TypeRadioButtonList.Items.Add(New ListItem("Angiodysplasia (>5mm)", 3))
        TypeRadioButtonList.Items.Add(New ListItem("Angiodysplasia (large and small lesions)", 4))
        TypeRadioButtonList.Items.Add(New ListItem("Varices", 5))
            TypeRadioButtonList.Items.Add(New ListItem("Portal hypertensive gastropathy", 6))

            BleedingRadioButtonList.Items.Add(New ListItem("None", 1))
            BleedingRadioButtonList.Items.Add(New ListItem("Fibrin plug", 2))
        BleedingRadioButtonList.Items.Add(New ListItem("Fresh clot", 3))
        BleedingRadioButtonList.Items.Add(New ListItem("Red sign", 4))
        BleedingRadioButtonList.Items.Add(New ListItem("Active bleeding", 5))
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try

            Dim sArea As String = Request.QueryString("Area")

            AbnormalitiesDataAdapter.SaveVascularLesionsData(
                siteId,
                NoneCheckBox.Checked,
                Utilities.GetRadioValue(TypeRadioButtonList),
                MultipleCheckBox.Checked,
                QuantityNumericTextBox.Value,
                Utilities.GetRadioValue(BleedingRadioButtonList),
                sArea)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Vascular Lesions.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
