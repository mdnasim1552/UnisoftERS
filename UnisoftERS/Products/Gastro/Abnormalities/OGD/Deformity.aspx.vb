Imports Telerik.Web.UI


Partial Class Products_Gastro_Abnormalities_OGD_Deformity
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtDf As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_deformity_select")
            If dtDf.Rows.Count > 0 Then
                PopulateData(dtDf.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drDf As DataRow)
        NoneCheckBox.Checked = CBool(drDf("None"))

        Select Case CInt(drDf("DeformityType"))
            Case 1
                ExtrinsicCompRadioButton.Checked = True
            Case 2
                CupAndSpillRadioButton.Checked = True
            Case 3
                HourglassRadioButton.Checked = True
            Case 4
                PostOperativeRadioButton.Checked = True
            Case 5
                JShapedRadioButton.Checked = True
            Case 6
                SubMucosalRadioButton.Checked = True
            Case 7
                OtherRadioButton.Checked = True
        End Select

        OtherTextBox.Text = CStr(drDf("DeformityOther"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Dim deformityType As Integer

        If ExtrinsicCompRadioButton.Checked Then
            deformityType = 1
        ElseIf CupAndSpillRadioButton.Checked Then
            deformityType = 2
        ElseIf HourglassRadioButton.Checked Then
            deformityType = 3
        ElseIf PostOperativeRadioButton.Checked Then
            deformityType = 4
        ElseIf JShapedRadioButton.Checked Then
            deformityType = 5
        ElseIf SubMucosalRadioButton.Checked Then
            deformityType = 6
        ElseIf OtherRadioButton.Checked Then
            deformityType = 7
        End If

        Try
            AbnormalitiesDataAdapter.SaveDeformityData(siteId, NoneCheckBox.Checked, deformityType, OtherTextBox.Text)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Deformity.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
