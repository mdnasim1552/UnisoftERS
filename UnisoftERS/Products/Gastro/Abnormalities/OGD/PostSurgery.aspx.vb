Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_PostSurgery
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{SurgicalProcedureComboBox, "Surgical Procedures"}})
            ' Utilities.LoadDropdown(SurgicalProcedureComboBox, DataAdapter.GetSurgicalProcedures(), "ListItemText", "ListItemNo", "")
            DisplayControls()
            Dim dtMa As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_postsurgery_select")
            If dtMa.Rows.Count > 0 Then
                PopulateData(dtMa.Rows(0))
            End If

        End If
    End Sub

    Private Sub PopulateData(drPs As DataRow)
        NoneCheckBox.Checked = CBool(drPs("None"))
        SurgicalProcedureCheckBox.Checked = CBool(drPs("PreviousSurgery"))
        If CInt(drPs("SurgicalProcedure")) > 0 Then
            SurgicalProcedureCheckBox.Checked = True
            SurgicalProcedureComboBox.SelectedValue = CInt(drPs("SurgicalProcedure"))
            FindingsTextBox.Text = CStr(drPs("SurgicalProcedureFindings"))
        End If

        DuodenumCheckBox.Checked = CBool(drPs("DuodenumPresent"))
        If CInt(drPs("JejunumState")) > 0 Then
            JejunumCheckBox.Checked = True
            JejunumStateRadioButtonList.SelectedValue = CInt(drPs("JejunumState"))
            AbnormalTextBox.Text = CStr(drPs("JejunumAbnormalText"))
        End If
    End Sub

    Private Sub DisplayControls()
        Dim sArea As String = Request.QueryString("Area")
        Select Case sArea
            Case "Oesophagus"
                trJejunum.Visible = False
                trDuodenum.Visible = False
            Case "Stomach"
                trJejunum.Visible = True
                trDuodenum.Visible = True
            Case "Duodenum"

        End Select

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Dim surgicalProcId As Integer = 0
        Dim findings As String = ""

        Try
            If SurgicalProcedureCheckBox.Checked Then
                surgicalProcId = Utilities.GetComboBoxValue(SurgicalProcedureComboBox)
                findings = FindingsTextBox.Text
            End If

            AbnormalitiesDataAdapter.SavePostSurgeryData(
                siteId,
                NoneCheckBox.Checked,
                SurgicalProcedureCheckBox.Checked,
                surgicalProcId,
                SurgicalProcedureComboBox.SelectedItem.Text,
                findings,
                DuodenumCheckBox.Checked,
                Utilities.GetRadioValue(JejunumStateRadioButtonList),
                AbnormalTextBox.Text)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Post Surgery.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
