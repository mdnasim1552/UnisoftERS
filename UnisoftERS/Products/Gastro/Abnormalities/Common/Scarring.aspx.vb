Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Common_Scarring
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        Dim sArea As String = Request.QueryString("Area")


        If Not Page.IsPostBack Then
            Dim dtSc As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_scaring_select")
            If dtSc.Rows.Count > 0 Then
                PopulateData(dtSc.Rows(0))
            End If
            If Request.QueryString("Reg").IndexOf("Pylorus") > -1 Then
                UlcerScarCheckBox.Text = "scar"
                StenosisCheckBox.Text = "stenosed"
                DeformityCheckBox.Text = "deformity"
                PseudodiverticulumCheckBox.Text = "not entered"
                thHeader.InnerText = "Pylorus"
            End If
        End If
    End Sub

    Private Sub PopulateData(drSc As DataRow)
        If Request.QueryString("Reg").IndexOf("Pylorus") > -1 Then
            UlcerScarCheckBox.Checked = CBool(drSc("PylorusScar"))
            StenosisCheckBox.Checked = CBool(drSc("PyloricStenosis"))
            DeformityCheckBox.Checked = CBool(drSc("PylorusDeformity"))
            PseudodiverticulumCheckBox.Checked = CBool(drSc("PylorusNotEntered"))
        Else
            UlcerScarCheckBox.Checked = CBool(drSc("DuodUlcerScar"))
            StenosisCheckBox.Checked = CBool(drSc("DuodStenosis"))
            DeformityCheckBox.Checked = CBool(drSc("DuodDeformity"))
            PseudodiverticulumCheckBox.Checked = CBool(drSc("DuodPsudodivert"))
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
            Dim isPylorus As Boolean = False
            If Request.QueryString("Reg").IndexOf("Pylorus") > -1 Then
                isPylorus = True
            End If

            AbnormalitiesDataAdapter.SaveScarringData(
                siteId,
                UlcerScarCheckBox.Checked,
                StenosisCheckBox.Checked,
                DeformityCheckBox.Checked,
                PseudodiverticulumCheckBox.Checked,
                isPylorus)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then  ' //for this page issue 4166  by Mostafiz
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Scarring/Stenosis.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
