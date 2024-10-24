Imports Telerik.Web.UI
Imports System.Data.SqlClient


Partial Class Products_Broncho_Abnormalities_BrtAbnoDescriptions
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        Dim reg As String = Request.QueryString("Reg")

        If Not Page.IsPostBack Then

            SetControls(reg)

            Dim dtDu As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_brt_descriptions_select")
            If dtDu.Rows.Count > 0 Then
                PopulateData(dtDu.Rows(0))
            End If
        End If
    End Sub

    Private Sub SetControls(ByVal region As String)

        Dim Hepatic() As String = {"Left Hepatic Ducts", "Right Hepatic Ducts", "Left intra-hepatic ducts", "Right intra-hepatic ducts", "Right Hepatic Lobe", "Left Hepatic Lobe"}
        Dim GallBladderReg() As String = {"Gall Bladder", "Common Bile Duct", "Common Hepatic Duct", "Cystic Duct", "Bifurcation"}
        'Dim Pancreas() As String = {"Main Pancreatic Duct", "Accessory Pancreatic Duct", "Tail", "Body", "Neck", "Head", "Uncinate Process", "Major Papilla", "Minor Papilla", "Lateral Wall First Part", "Medial Wall First Part", "First Part", "Lateral Wall Second Part", "Medial Wall Second Part", "Second Part", "Lateral Wall Third Part", "Medial Wall Third Part", "Third Part"}

        If Hepatic.Contains(region, StringComparer.CurrentCultureIgnoreCase) Then 'Hepatic Regions
            '    CystsCholedochalDiv.Visible = False
            '    StrictureTypeMalignantRow.Visible = True
            '    CystsSuspectedRow.Visible = True
        ElseIf GallBladderReg.Contains(region, StringComparer.CurrentCultureIgnoreCase) Then 'GallBladder and the regions close to it
            'If region.ToLower = "gall bladder" Then
            '    HeadingLabel.Text = "Gall Bladder"
            'End If
            'CystsCholedochalDiv.Visible = True
            'StrictureTypeMalignantRow.Visible = False
            'CystsSuspectedRow.Visible = False
        Else 'Pancreas Regions
            'CystsCholedochalDiv.Visible = True
            'StrictureTypeMalignantRow.Visible = False
            'CystsSuspectedRow.Visible = False
            'CystsCommunicatingCheckBox.Text = "communicating with pancreatic duct"
            'CystsCholedochalCheckBox.Text = "pseudocyst"
        End If
    End Sub

    Private Sub PopulateData(drDu As DataRow)
        NoneCheckBox.Checked = CBool(drDu("Normal"))

        If CBool(drDu("Normal")) Then Exit Sub

        If Not IsDBNull(drDu("Carinal")) AndAlso CInt(drDu("Carinal")) > 0 Then CarinalRBL.SelectedValue = CInt(drDu("Carinal"))
        If Not IsDBNull(drDu("Vocal")) AndAlso CInt(drDu("Vocal")) > 0 Then VocalRBL.SelectedValue = CInt(drDu("Vocal"))

        'CompressionCheckBox.Checked = CBool(drDu("Compression"))
        CompressionGeneralCheckBox.Checked = CBool(drDu("CompressionGeneral"))
        CompressionFromLeftCheckBox.Checked = CBool(drDu("CompressionFromLeft"))
        CompressionFromRightCheckBox.Checked = CBool(drDu("CompressionFromRight"))
        CompressionFromAnteriorCheckBox.Checked = CBool(drDu("CompressionFromAnterior"))
        CompressionFromPosteriorCheckBox.Checked = CBool(drDu("CompressionFromPosterior"))

        If Not IsDBNull(drDu("Stenosis")) AndAlso CInt(drDu("Stenosis")) > 0 Then StenosisRBL.SelectedValue = CInt(drDu("Stenosis"))
        If Not IsDBNull(drDu("Obstruction")) AndAlso CInt(drDu("Obstruction")) > 0 Then ObstructionRBL.SelectedValue = CInt(drDu("Obstruction"))

        'MucosalCheckBox.Checked = CBool(drDu("Mucosal"))
        MucosalOedemaCheckBox.Checked = CBool(drDu("MucosalOedema"))
        MucosalErythemaCheckBox.Checked = CBool(drDu("MucosalErythema"))
        MucosalPitsCheckBox.Checked = CBool(drDu("MucosalPits"))
        MucosalAnthracosisCheckBox.Checked = CBool(drDu("MucosalAnthracosis"))
        MucosalInfiltrationCheckBox.Checked = CBool(drDu("MucosalInfiltration"))
        'MucosalIrregularityCheckBox.Checked = CBool(drDu("MucosalIrregularity"))

        If Not IsDBNull(drDu("MucosalIrregularity")) AndAlso CInt(drDu("MucosalIrregularity")) > 0 Then MucosalIrregularityRBL.SelectedValue = CInt(drDu("MucosalIrregularity"))
        If Not IsDBNull(drDu("ExcessiveSecretions")) AndAlso CInt(drDu("ExcessiveSecretions")) > 0 Then ExcessiveSecretionsRBL.SelectedValue = CInt(drDu("ExcessiveSecretions"))
        If Not IsDBNull(drDu("Bleeding")) AndAlso CInt(drDu("Bleeding")) > 0 Then BleedingRBL.SelectedValue = CInt(drDu("Bleeding"))

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            AbnormalitiesDataAdapter.SaveBRTAbnosData( _
                siteId, _
                NoneCheckBox.Checked, _
                Utilities.GetRadioValue(CarinalRBL), _
                Utilities.GetRadioValue(VocalRBL), _
                0, _
                CompressionGeneralCheckBox.Checked, _
                CompressionFromLeftCheckBox.Checked, _
                CompressionFromRightCheckBox.Checked, _
                CompressionFromAnteriorCheckBox.Checked, _
                CompressionFromPosteriorCheckBox.Checked, _
                Utilities.GetRadioValue(StenosisRBL), _
                Utilities.GetRadioValue(ObstructionRBL), _
                0, _
                MucosalOedemaCheckBox.Checked, _
                MucosalErythemaCheckBox.Checked, _
                MucosalPitsCheckBox.Checked, _
                MucosalAnthracosisCheckBox.Checked, _
                MucosalInfiltrationCheckBox.Checked, _
                Utilities.GetRadioValue(MucosalIrregularityRBL), _
                Utilities.GetRadioValue(ExcessiveSecretionsRBL), _
                Utilities.GetRadioValue(BleedingRBL))

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving ERCP Abnormalities - Duct.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click

    End Sub
End Class