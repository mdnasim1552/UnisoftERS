Imports Telerik.Web.UI


Partial Class Products_Gastro_Abnormalities_EUS_Mediastinal
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
            Case ProcedureType.EUS_HPB 
                StationSpan.Visible = False 
                AbnoHeaderDiv.InnerText ="Site"
        End Select
 
        If Not Page.IsPostBack Then
            Dim dtDf As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_mediastinal_select")
            If dtDf.Rows.Count > 0 Then
                PopulateData(dtDf.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drDf As DataRow)
        NoneCheckBox.Checked = CBool(drDf("None"))

        Select Case CInt(drDf("MediastinalType"))
            Case 1
                MassRadioButton.Checked = True
            Case 2
                LymphNodeRadioButton.Checked = True
        End Select

        StationTextBox.Text = CStr(drDf("NodeStation"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Dim MediastinalType As Integer

        If MassRadioButton.Checked Then
            MediastinalType = 1
        ElseIf LymphNodeRadioButton.Checked Then
            MediastinalType = 2
        End If

        Try
            AbnormalitiesDataAdapter.SaveMediastinalData(siteId, NoneCheckBox.Checked, MediastinalType, StationTextBox.Text)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving EUS Abnormalities - Mediastinal.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
