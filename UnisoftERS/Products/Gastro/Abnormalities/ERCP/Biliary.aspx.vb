Imports Telerik.Web.UI

Public Class Biliary
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        Dim reg As String = Request.QueryString("Reg")

        If Not Page.IsPostBack Then

            SetControls(reg)

            Dim dtDu As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_biliary_select")
            If dtDu.Rows.Count > 0 Then
                PopulateData(dtDu.Rows(0))
            End If
        End If
    End Sub

    Private Sub SetControls(ByVal region As String)
        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                             {BiliaryLeakSiteRadComboBox, "Intrahepatic biliary leak site"},
                             {ExtrahepaticLeakSiteRadComboBox, "Extrahepatic biliary leak site"}
                     })
    End Sub

    Private Sub PopulateData(drDu As DataRow)
        NormalCheckBox.Checked = CBool(drDu("Normal"))
        AnastomicStrictureCheckBox.Checked = CBool(drDu("AnastomicStricture"))
        CalculousObstructionCheckBox.Checked = CBool(drDu("CalculousObstruction"))
        CholelithiasisCheckBox.Checked = CBool(drDu("Cholelithiasis"))
        GallBladderTumourCheckBox.Checked = CBool(drDu("GallBladderTumour"))
        HaemobiliaCheckBox.Checked = CBool(drDu("Haemobilia"))
        MirizziSyndromeCheckBox.Checked = CBool(drDu("MirizziSyndrome"))
        OcclusionCheckBox.Checked = CBool(drDu("Occlusion"))
        StentOcclusionCheckBox.Checked = CBool(drDu("StentOcclusion"))

        D198P2_CheckBox.Checked = CBool(drDu("NormalIntraheptic"))
        D210P2_CheckBox.Checked = CBool(drDu("SuppurativeCholangitis"))
        D220P2_CheckBox.Checked = CBool(drDu("IntrahepticBiliaryLeak"))
        BiliaryLeakSiteRadComboBox.SelectedValue = CInt(drDu("IntrahepticBiliaryLeakSite"))
        D242P2_CheckBox.Checked = CBool(drDu("IntrahepticTumourProbable"))
        D243P2_CheckBox.Checked = CBool(drDu("IntrahepticTumourPossible"))
        D265P2_CheckBox.Checked = CBool(drDu("ExtrahepticNormal"))
        D280P2_CheckBox.Checked = CBool(drDu("ExtrahepticBiliaryLeak"))
        ExtrahepaticLeakSiteRadComboBox.SelectedValue = CInt(drDu("ExtrahepticBiliaryLeakSite"))
        D290P2_CheckBox.Checked = CBool(drDu("Stricture"))
        'ExtrahepaticTumourRadioButtonList.SelectedValue = CInt(drDu(""))
        'D325P2_CheckBox.Checked = CBool(drDu(""))
        'D305P2_CheckBox.Checked = CBool(drDu(""))
        'D310P2_CheckBox.Checked = CBool(drDu(""))
        'D315P2_CheckBox.Checked = CBool(drDu(""))
        'D320P2_CheckBox.Checked = CBool(drDu(""))
        'D337P2_CheckBox.Checked = CBool(drDu(""))
        'D340P2_CheckBox.Checked = CBool(drDu(""))
        'D345P2_CheckBox.Checked = CBool(drDu(""))
        'D350P2_CheckBox.Checked = CBool(drDu(""))
        'D355P2_CheckBox.Checked = CBool(drDu(""))
        'D338P2_CheckBox.Checked = CBool(drDu(""))

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            Dim BiliaryLeakSite As Integer
            Dim ExtrahepaticLeakSite As Integer

            If BiliaryLeakSiteRadComboBox.Text <> "" AndAlso BiliaryLeakSiteRadComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("Intrahepatic biliary leak site", BiliaryLeakSiteRadComboBox.Text)
                If newId > 0 Then BiliaryLeakSite = newId
            Else
                BiliaryLeakSite = Utilities.GetComboBoxValue(BiliaryLeakSiteRadComboBox)
            End If

            If ExtrahepaticLeakSiteRadComboBox.Text <> "" AndAlso ExtrahepaticLeakSiteRadComboBox.SelectedValue = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("Extrahepatic biliary leak site", ExtrahepaticLeakSiteRadComboBox.Text)
                If newId > 0 Then ExtrahepaticLeakSite = newId
            Else
                ExtrahepaticLeakSite = Utilities.GetComboBoxValue(ExtrahepaticLeakSiteRadComboBox)
            End If


            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving ERCP Abnormalities - Duct.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class