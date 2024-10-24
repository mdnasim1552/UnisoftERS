Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Common_Tumour
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtDf As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_tumour_select")
            If dtDf.Rows.Count > 0 Then
                PopulateData(dtDf.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drDf As DataRow)
        NoneCheckBox.Checked = CBool(drDf("None"))

        Select Case CInt(drDf("Type"))
            Case 1
                BenignPolypRadio.Checked = True
            Case 2
                LymphomaRadioButton.Checked = True
            Case 3
                ProbableCarcinomaRadioButton.Checked = True
            Case 4
                ConfirmedCarcinomaRadioButton.Checked = True
            Case 5
                BenignTumourRadio.Checked = True
        End Select

        If CInt(drDf("Type")) > 0 Then
            PrimaryCheckBox.Checked = CBool(drDf("Primary"))
            ExternalInvasionCheckBox.Checked = CBool(drDf("ExternalInvasion"))
        End If

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Dim Type As Integer

        If BenignPolypRadio.Checked Then
            Type = 1
        ElseIf LymphomaRadioButton.Checked Then
            Type = 2
        ElseIf ProbableCarcinomaRadioButton.Checked Then
            Type = 3
        ElseIf ConfirmedCarcinomaRadioButton.Checked Then
            Type = 4
        ElseIf BenignTumourRadio.Checked Then
            Type = 5
        End If

        Try
            AbnormalitiesDataAdapter.SaveTumourData(siteId, NoneCheckBox.Checked, Type, PrimaryCheckBox.Checked, ExternalInvasionCheckBox.Checked)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Tumour.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
