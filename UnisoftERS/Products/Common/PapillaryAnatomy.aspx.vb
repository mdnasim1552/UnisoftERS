Imports Telerik.Web.UI
Imports System.Data.SqlClient

Partial Class Products_Common_PapillaryAnatomy
    Inherits PageBase

    Protected Sub Products_Common_PapillaryAnatomy_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim da As New OtherData
            Dim dtPa As DataTable = da.GetERCPPapillaryAnatomy(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtPa.Rows.Count > 0 Then
                PopulateData(dtPa.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drPa As DataRow)
        MajorSiteLocationRadioButtonList.Text = CInt(drPa("MajorSiteLocation"))
        If Not IsDBNull(drPa("MajorSiteLocation")) Then MajorSiteLocationRadioButtonList.SelectedValue = CInt(drPa("MajorSiteLocation"))
        If Not IsDBNull(drPa("MajorSize")) Then MajorSizeRadioButtonList.SelectedValue = CInt(drPa("MajorSize"))
        If Not IsDBNull(drPa("MajorNoOfOpenings")) Then MajorNoOfOpeningsRadioButtonList.SelectedValue = CInt(drPa("MajorNoOfOpenings"))
        MajorFloppyCheckBox.Checked = CBool(drPa("MajorFloppy"))
        MajorStenosedCheckBox.Checked = CBool(drPa("MajorStenosed"))
        MajorSurgeryNoneCheckBox.Checked = CBool(drPa("MajorSurgeryNone"))
        MajorEndoscopicCheckBox.Checked = CBool(drPa("MajorEndoscopic"))
        If Not IsDBNull(drPa("MajorEndoscopicSize")) Then MajorEndoscopicSizeTextBox.Value = CDec(drPa("MajorEndoscopicSize"))
        MajorOperativeCheckBox.Checked = CBool(drPa("MajorOperative"))
        If Not IsDBNull(drPa("MajorOperativeSize")) Then MajorOperativeSizeTextBox.Value = CDec(drPa("MajorOperativeSize"))
        MajorSphincteroplastyCheckBox.Checked = CBool(drPa("MajorSphincteroplasty"))
        If Not IsDBNull(drPa("MajorSphincteroplastySize")) Then MajorSphincteroplastySizeTextBox.Value = CDec(drPa("MajorSphincteroplastySize"))
        MajorCholedochoduodenostomyCheckBox.Checked = CBool(drPa("MajorCholedochoduodenostomy"))

        If Not IsDBNull(drPa("MinorSiteLocation")) Then MinorSiteLocationRadioButtonList.SelectedValue = CInt(drPa("MinorSiteLocation"))
        If Not IsDBNull(drPa("MinorSize")) Then MinorSizeRadioButtonList.SelectedValue = CInt(drPa("MinorSize"))
        MinorStenosedCheckBox.Checked = CBool(drPa("MinorStenosed"))
        MinorSurgeryNoneCheckBox.Checked = CBool(drPa("MinorSurgeryNone"))
        MinorEndoscopicCheckBox.Checked = CBool(drPa("MinorEndoscopic"))
        If Not IsDBNull(drPa("MinorEndoscopicSize")) Then MinorEndoscopicSizeTextBox.Value = CDec(drPa("MinorEndoscopicSize"))
        MinorOperativeCheckBox.Checked = CBool(drPa("MinorOperative"))
        If Not IsDBNull(drPa("MinorOperativeSize")) Then MinorOperativeSizeTextBox.Value = CDec(drPa("MinorOperativeSize"))
        If Not IsDBNull(drPa("MajorBilrothRoux")) Then MajorBilrothRouxCheckBox.Checked = CBool(drPa("MajorBilrothRoux"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            Dim da As New OtherData
            da.SavePapillaryAnatomyData(
                CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                Utilities.GetRadioValue(MajorSiteLocationRadioButtonList),
                Utilities.GetRadioValue(MajorSizeRadioButtonList),
                Utilities.GetRadioValue(MajorNoOfOpeningsRadioButtonList),
                MajorFloppyCheckBox.Checked,
                MajorStenosedCheckBox.Checked,
                MajorSurgeryNoneCheckBox.Checked,
                MajorEndoscopicCheckBox.Checked,
                MajorEndoscopicSizeTextBox.Value,
                MajorOperativeCheckBox.Checked,
                MajorOperativeSizeTextBox.Value,
                MajorSphincteroplastyCheckBox.Checked,
                MajorSphincteroplastySizeTextBox.Value,
                MajorCholedochoduodenostomyCheckBox.Checked,
                Utilities.GetRadioValue(MinorSiteLocationRadioButtonList),
                Utilities.GetRadioValue(MinorSizeRadioButtonList),
                MinorStenosedCheckBox.Checked,
                MinorSurgeryNoneCheckBox.Checked,
                MinorEndoscopicCheckBox.Checked,
                MinorEndoscopicSizeTextBox.Value,
                MinorOperativeCheckBox.Checked,
                MinorOperativeSizeTextBox.Value,
                MajorBilrothRouxCheckBox.Checked)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "close", "CloseWindow();", True)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving ERCP Papillary Anatomy.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click

    End Sub
End Class
