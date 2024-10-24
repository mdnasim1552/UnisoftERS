Imports Telerik.Web.UI

Public Class Achalasia
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtAl As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_achalasia_select")
            If dtAl.Rows.Count > 0 Then
                PopulateData(dtAl.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drAl As DataRow)
        NoneCheckBox.Checked = CBool(drAl("None"))
        AchalasiaProbableRadioButton.Checked = CBool(drAl("Probable"))
        AchalasiaConfirmedRadioButton.Checked = CBool(drAl("Confirmed"))
        AchalasiaLeadingToPerforationRadioButton.SelectedValue = If(CBool(drAl("DilationLeadingToPerforation")), 1, 0)
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesDataAdapter.SaveAlchalasiaData(siteId, NoneCheckBox.Checked, AchalasiaProbableRadioButton.Checked, AchalasiaConfirmedRadioButton.Checked, If(NoneCheckBox.Checked, 0, If(String.IsNullOrEmpty(AchalasiaLeadingToPerforationRadioButton.SelectedValue.ToString()), False, AchalasiaLeadingToPerforationRadioButton.SelectedValue)))

            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Achalasia.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class