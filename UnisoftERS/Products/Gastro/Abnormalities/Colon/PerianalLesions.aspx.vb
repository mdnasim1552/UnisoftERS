Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Colon_PerianalLesions
    Inherits SiteDetailsBase

    Private Shared siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_Colon_PerianalLesions_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtDi As DataTable = AbnormalitiesColonDataAdapter.GetPerianalLesionsData(siteId)
            If dtDi.Rows.Count > 0 Then
                PopulateData(dtDi.Rows(0))
            End If
        End If

    End Sub

    Private Sub PopulateData(drDi As DataRow)
        NoneCheckBox.Checked = CBool(drDi("None"))
        Haemorrhoids_Checkbox.Checked = CBool(drDi("Haemorrhoids"))

        If Haemorrhoids_Checkbox.Checked Then
            Dim dtIns As DataTable = DataAdapter.GetTherapeuticBandingPiles(siteId)
            If dtIns.Rows.Count > 0 Then
                BandingPilesCheckBox.Checked = CBool(dtIns.Rows(0)("BandingPiles"))
                BandingNumRadNumericTextBox.Value = CInt(dtIns.Rows(0)("BandingNum"))
            End If
        End If
        'If Haemorrhoids_Checkbox.Checked Then
        'haemorTD1.Attributes.Add("Style", "Display:normal")
        'haemorTD2.Attributes.Add("Style", "Display:normal")
        First_RadioButton.Checked = CBool(drDi("FirstDegree"))
        Second_RadioButton.Checked = CBool(drDi("SecondDegree"))
        Third_RadioButton.Checked = CBool(drDi("ThirdDegree"))
        QuantityRadNumericTextBox.Value = CInt(drDi("Quantity"))
        ' End If


        Skin_CheckBox.Checked = CBool(drDi("PerianalSkin"))
        If Skin_CheckBox.Checked Then
            SkinTagQuantity.Value = CInt(drDi("SkinTagQuantity"))
        End If
        Cancer_Checkbox.Checked = CBool(drDi("PerianalCancer"))
        Wart_Checkbox.Checked = CBool(drDi("PerianalWarts"))
        Herpes_CheckBox.Checked = CBool(drDi("HerpesSimplex"))
        Anal_Checkbox.Checked = CBool(drDi("AnalFissure"))
        Acute_Checkbox.Checked = CBool(drDi("Acute"))
        Chronic_Checkbox.Checked = CBool(drDi("Chronic"))
        Fistula_Checkbox.Checked = CBool(drDi("PerianalFistula"))
    End Sub
    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            Dim SkinTagQty As Integer
            If SkinTagQuantity.Value Is Nothing OrElse String.IsNullOrEmpty(SkinTagQuantity.Value) Then
                SkinTagQty = 0
            Else
                SkinTagQty = SkinTagQuantity.Value
            End If
            AbnormalitiesColonDataAdapter.SavePerianalLesionsData(
                siteId,
                NoneCheckBox.Checked,
                Haemorrhoids_Checkbox.Checked,
                First_RadioButton.Checked,
                Second_RadioButton.Checked,
                Third_RadioButton.Checked,
                QuantityRadNumericTextBox.Value,
                Skin_CheckBox.Checked,
                SkinTagQty,
                Cancer_Checkbox.Checked,
                 Wart_Checkbox.Checked,
                Herpes_CheckBox.Checked,
                Anal_Checkbox.Checked,
                Acute_Checkbox.Checked,
                Chronic_Checkbox.Checked,
                Fistula_Checkbox.Checked,
                BandingPilesCheckBox.Checked,
                BandingNumRadNumericTextBox.Value)
            '
            If saveAndClose Then
                'Utilities.SetNotificationStyle(RadNotification1)
                'RadNotification1.Show()
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Colon Abnormalities - PerianalLesions.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
