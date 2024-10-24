Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Colon_Calibre
    Inherits SiteDetailsBase

    Private Shared siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_Colon_Calibre_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtCa As DataTable = AbnormalitiesColonDataAdapter.GetCalibreData(siteId)
            If dtCa.Rows.Count > 0 Then
                PopulateData(dtCa.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drCa As DataRow)
        NormalCheckBox.Checked = CBool(drCa("None"))
        ContractionCheckBox.Checked = CBool(drCa("Contraction"))
        DilatedCheckBox.Checked = CBool(drCa("Dilated"))
        DilatedTypeRadioButtonList.Text = CInt(drCa("DilatedType"))
        ObstructionCheckBox.Checked = CBool(drCa("Obstruction"))
        SpasmCheckBox.Checked = CBool(drCa("Spasm"))
        StrictureCheckBox.Checked = CBool(drCa("Stricture"))
        StrictureTypeRadioButtonList.Text = CInt(drCa("StrictureType"))
        If Not IsDBNull(drCa("StrictureLength")) Then
            StrictureLengthNumericTextBox.Value = CDec(drCa("StrictureLength"))
        End If
        StrictureImpededRadioButtonList.Text = CInt(drCa("StrictureImpeded"))
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesColonDataAdapter.SaveCalibreData(
                siteId,
                NormalCheckBox.Checked,
                ContractionCheckBox.Checked,
                DilatedCheckBox.Checked,
                Utilities.GetRadioValue(DilatedTypeRadioButtonList),
                ObstructionCheckBox.Checked,
                SpasmCheckBox.Checked,
                StrictureCheckBox.Checked,
                Utilities.GetRadioValue(StrictureTypeRadioButtonList),
                StrictureLengthNumericTextBox.Value,
                Utilities.GetRadioValue(StrictureImpededRadioButtonList))

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Colon Abnormalities - Calibre.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub
    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub
End Class
