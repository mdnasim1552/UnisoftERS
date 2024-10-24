Imports Telerik.Web.UI

Public Class Intrahepatic
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        Dim reg As String = Request.QueryString("Reg")

        If Not Page.IsPostBack Then

            Dim dtDu As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_intrahepatic_select")
            If dtDu.Rows.Count > 0 Then
                PopulateData(dtDu.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drDu As DataRow)
        Try
            D198P2_CheckBox.Checked = CBool(drDu("NormalIntraheptic"))
            D210P2_CheckBox.Checked = CBool(drDu("SuppurativeCholangitis"))
            D220P2_CheckBox.Checked = CBool(drDu("IntrahepticBiliaryLeak"))
            TumourCheckBox.Checked = CBool(drDu("Tumour")) 
            D242P2_CheckBox.Checked = CBool(drDu("IntrahepticTumourProbable"))
            D243P2_CheckBox.Checked = CBool(drDu("IntrahepticTumourPossible"))
            IntrahepaticStonesCheckBox.Checked = CBool(drDu("Stones"))

            If Not IsDBNull(drDu("Other")) Andalso Not String.IsNullOrWhiteSpace(drDu("Other")) Then
                OtherCheckBox.Checked = True
                OtherTextBox.Text = drDu("Other")
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while getting data ERCP Abnormalities - Intrahepatic.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem retrieving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesDataAdapter.SaveIntrahepaticData(
               siteId,
               D198P2_CheckBox.Checked,
               D210P2_CheckBox.Checked,
               D220P2_CheckBox.Checked,
               TumourCheckBox.Checked,
               D242P2_CheckBox.Checked,
               D243P2_CheckBox.Checked,
               IntrahepaticStonesCheckBox.Checked,
               OtherTextBox.Text)

            'If saveAndClose Then
            '    ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            'End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving ERCP Abnormalities - Duct.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class