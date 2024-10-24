Imports Telerik.Web.UI


Partial Class Products_Gastro_Abnormalities_Common_Diverticulum
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtDv As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_diverticulum_select")
            If dtDv.Rows.Count > 0 Then
                PopulateData(dtDv.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drDv As DataRow)
        NoneCheckBox.Checked = CBool(drDv("None"))
        PseudodiverticulumCheckBox.Checked = CBool(drDv("Pseudodiverticulum"))
        FirstPartCheckBox.Checked = CBool(drDv("Congenital1stPart"))
        SecondPartCheckBox.Checked = CBool(drDv("Congenital2ndPart"))
        OtherCheckBox.Checked = CBool(drDv("Other"))
        OtherTextBox.Text = CStr(drDv("OtherDesc"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Dim other As String = ""

        Try
            If OtherCheckBox.Checked Then
                other = OtherTextBox.Text
            End If

            AbnormalitiesDataAdapter.SaveDiverticulumData( _
                siteId, _
                NoneCheckBox.Checked, _
                PseudodiverticulumCheckBox.Checked, _
                FirstPartCheckBox.Checked, _
                SecondPartCheckBox.Checked, _
                OtherCheckBox.Checked, _
                other)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then  ' //for this page issue 4166  by Mostafiz
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Diverticulum.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
