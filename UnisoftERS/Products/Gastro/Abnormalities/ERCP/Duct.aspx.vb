Imports Telerik.Web.UI
Imports System.Data.SqlClient

''' <summary>
''' This page is used as both Duct and Gall Bladder
''' </summary>
''' <remarks></remarks>
Partial Class Products_Gastro_Abnormalities_ERCP_Duct
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_ERCP_Duct_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        Dim reg As String = Request.QueryString("Reg")

        If Not Page.IsPostBack Then

            SetControls(reg)

            Dim dtDu As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_duct_select")
            If dtDu.Rows.Count > 0 Then
                PopulateData(dtDu.Rows(0))
            End If
        End If
    End Sub

    Private Sub SetControls(ByVal region As String)

        Dim Hepatic() As String = {"Left Hepatic Ducts", "Right Hepatic Ducts", "Left intra-hepatic ducts", "Right intra-hepatic ducts", "Right Hepatic Lobe", "Left Hepatic Lobe"}
        Dim GallBladderReg() As String = {"Gall Bladder", "Common Bile Duct", "Common Hepatic Duct", "Cystic Duct", "Bifurcation"}
        'Dim Pancreas() As String = {"Main Pancreatic Duct", "Accessory Pancreatic Duct", "Tail", "Body", "Neck", "Head", "Uncinate Process", "Major Papilla", "Minor Papilla", "Lateral Wall First Part", "Medial Wall First Part", "First Part", "Lateral Wall Second Part", "Medial Wall Second Part", "Second Part", "Lateral Wall Third Part", "Medial Wall Third Part", "Third Part"}

        HeadingLabel.Text = "Duct"
        If Hepatic.Contains(region, StringComparer.CurrentCultureIgnoreCase) Then 'Hepatic Regions
            CystsCholedochalDiv.Visible = False
            StrictureTypeMalignantRow.Visible = True
            CystsSuspectedRow.Visible = True
            CalculousObstructionRow.Visible = False
            If region.ToLower.Contains("lobe") Or region.ToLower.Contains("intra-hepatic") Then
                MirizziSyndromeRow.Visible = False
                SclerosingCholangitisRow.Visible = False
                AnastomicStrictureRow.Visible = False
                BiliaryLeakRow.Visible = False
            End If
        ElseIf GallBladderReg.Contains(region, StringComparer.CurrentCultureIgnoreCase) Then 'GallBladder and the regions close to it
            If region.ToLower = "gall bladder" Then
                HeadingLabel.Text = "Gall Bladder"
                trCysts.Visible = True 'False Mahfuz changed False to True on 16 May 2021
                GallBladderTumorRow.Visible = True
                DiverticulumRow.Visible = True
                AnastomicStrictureRow.Visible = False
                MirizziSyndromeRow.Visible = False
                SclerosingCholangitisRow.Visible = False
                CalculousObstructionRow.Visible = False
                OcclusionRow.Visible = False
                BiliaryLeakRow.Visible = False
                PreviousSurgeryRow.Visible = False
                HemobiliaRow.Visible = False
            End If

            If region.ToLower.Contains("cystic duct") Then
                MirizziSyndromeRow.Visible = False
                SclerosingCholangitisRow.Visible = False
                AnastomicStrictureRow.Visible = False
                BiliaryLeakRow.Visible = False
                CalculousObstructionRow.Visible = True
            End If
            CystsCholedochalDiv.Visible = True
            StrictureTypeMalignantRow.Visible = False
            CystsSuspectedRow.Visible = False

            'Mahfuz added on 14 May 2021
            If region.ToLower.Contains("hepatic lobe") OrElse region.ToLower.Contains("hepatic ducts") Then
                MassDistortingAnatomyChildRow.Visible = True
            Else
                MassDistortingAnatomyChildRow.Visible = False
            End If

        Else 'Pancreas Regions
            HemobiliaCheckBox.Checked = False
            AnastomicStrictureRow.Visible = False
            SclerosingCholangitisRow.Visible = False
            MirizziSyndromeRow.Visible = False
            CalculousObstructionRow.Visible = False
            CystsCholedochalDiv.Visible = True
            StrictureTypeMalignantRow.Visible = False
            CystsSuspectedRow.Visible = False
            CystsCommunicatingCheckBox.Text = "communicating with pancreatic duct"
            CystsCholedochalCheckBox.Text = "pseudocyst"
            IPMNRow.Visible = True

            'MH changed on 31 Aug 2021
            If region.ToLower = "main pancreatic duct" Or
                region.ToLower = "tail" Or
                region.ToLower = "body" Or
                region.ToLower = "neck" Or
                region.ToLower = "head" Or
                region.ToLower = "uncinate process" Or
                region.ToLower = "accessory pancreatic duct" Then
                PancreaticTumourRow.Visible = True
            End If
        End If
    End Sub

    Private Sub PopulateData(drDu As DataRow)
        NormalCheckBox.Checked = CBool(drDu("Normal"))

        If Not CBool(drDu("Normal")) Then
            DilatedCheckBox.Checked = CBool(drDu("Dilated"))
            If CBool(drDu("Dilated")) Then
                If Not IsDBNull(drDu("DilatedLength")) Then DilatedLengthNumericTextBox.Text = CInt(drDu("DilatedLength"))
                If Not IsDBNull(drDu("DilatedType")) Then DilatedTypeRadioButtonList.SelectedValue = CInt(drDu("DilatedType"))
            End If

            StrictureCheckBox.Checked = CBool(drDu("Stricture"))
            If CBool(drDu("Stricture")) Then
                If Not IsDBNull(drDu("StrictureLen")) Then StrictureLengthNumericTextBox.Value = CDec(drDu("StrictureLen"))
                UpstreamDilatationCheckBox.Checked = CBool(drDu("UpstreamDilatation"))
                CompleteBlockCheckBox.Checked = CBool(drDu("CompleteBlock"))
                SmoothCheckBox.Checked = CBool(drDu("Smooth"))
                IrregularCheckBox.Checked = CBool(drDu("Irregular"))
                ShoulderedCheckBox.Checked = CBool(drDu("Shouldered"))
                TortuousCheckBox.Checked = CBool(drDu("Tortuous"))
                If Not IsDBNull(drDu("StrictureType")) Then StrictureTypeRadioButtonList.SelectedValue = CInt(drDu("StrictureType"))
                ProbablyCheckBox.Checked = CBool(drDu("StrictureProbably"))
                CholangiocarcinomaCheckBox.Checked = CBool(drDu("Cholangiocarcinoma"))
                ExternalCompressionCheckBox.Checked = CBool(drDu("ExternalCompression"))
            End If

            FistulaCheckBox.Checked = CBool(drDu("Fistula"))
            If CBool(drDu("Fistula")) Then
                If Not IsDBNull(drDu("FistulaQty")) Then FistulaQtyNumericTextBox.Value = CInt(drDu("FistulaQty"))
                VisceralCheckBox.Checked = CBool(drDu("Visceral"))
                CutaneousCheckBox.Checked = CBool(drDu("Cutaneous"))
                CommentsTextBox.Text = CStr(drDu("FistulaComments"))
            End If

            StonesCheckBox.Checked = CBool(drDu("Stones"))
            If CBool(drDu("Stones")) Then
                StonesMultipleCheckBox.Checked = CBool(drDu("StonesMultiple"))
                If Not IsDBNull(drDu("StonesQty")) Then StonesQtyNumericTextBox.Value = CInt(drDu("StonesQty"))
                If Not IsDBNull(drDu("StonesSize")) Then StonesSizeNumericTextBox.Value = CDec(drDu("StonesSize"))
            End If

            CystsCheckBox.Checked = CBool(drDu("Cysts"))
            If CBool(drDu("Cysts")) Then
                CystsMultipleCheckBox.Checked = CBool(drDu("CystsMultiple"))
                If Not IsDBNull(drDu("CystsQty")) Then CystsQtyNumericTextBox.Value = CInt(drDu("CystsQty"))
                If Not IsDBNull(drDu("CystsDiameter")) Then CystsDiameterNumericTextBox.Value = CDec(drDu("CystsDiameter"))
                CystsSimpleCheckBox.Checked = CBool(drDu("CystsSimple"))
                CystsRegularCheckBox.Checked = CBool(drDu("CystsRegular"))
                CystsIrregularCheckBox.Checked = CBool(drDu("CystsIrregular"))
                CystsLoculatedCheckBox.Checked = CBool(drDu("CystsLoculated"))
                CystsCommunicatingCheckBox.Checked = CBool(drDu("CystsCommunicating"))
                CystsCholedochalCheckBox.Checked = CBool(drDu("CystsCholedochal"))
                If Not IsDBNull(drDu("CystsSuspectedType")) Then CystsSuspectedTypeRadioButtonList.Text = CInt(drDu("CystsSuspectedType"))
            End If


            DuctInjuryCheckBox.Checked = CBool(drDu("DuctInjury"))
            StentOcclusionCheckBox.Checked = CBool(drDu("StentOcclusion"))
            GallBladderTumorCheckBox.Checked = CBool(drDu("GallBladderTumor"))
            DiverticulumCheckBox.Checked = CBool(drDu("Diverticulum"))
            AnastomicStrictureCheckbox.Checked = CBool(drDu("AnastomicStricture"))
            MirizziSyndromeCheckbox.Checked = CBool(drDu("MirizziSyndrome"))
            SclerosingCholangitisCheckBox.Checked = CBool(drDu("SclerosingCholangitis"))
            CalculousObstructionCheckBox.Checked = CBool(drDu("CalculousObstruction"))
            OcclusionCheckBox.Checked = CBool(drDu("Occlusion"))
            BiliaryLeakCheckBox.Checked = CBool(drDu("BiliaryLeak"))
            PreviousSurgeryCheckBox.Checked = CBool(drDu("PreviousSurgery"))
            PancreaticTumourCheckBox.Checked = CBool(drDu("PancreaticTumour"))
            MigratedStentCheckBox.Checked = CBool(drDu("ProximallyMigratedStent"))
            IPMNCheckBox.Checked = CBool(drDu("IPMN"))
            HemobiliaCheckBox.Checked = CBool(drDu("Hemobilia"))
            CholangiopathyCheckBox.Checked = CBool(drDu("Cholangiopathy"))

            If Not IsDBNull(drDu("Other")) AndAlso Not String.IsNullOrWhiteSpace(drDu("Other")) Then
                OtherCheckBox.Checked = True
                OtherTextBox.Text = drDu("Other")
            End If

            'Mahfuz added on 14 May 2021
            MassDistortingAnatomyCheckBox.Checked = CBool(drDu("Mass"))
            If Not IsDBNull(drDu("MassType")) Then MassTypeRadioButtonList.SelectedValue = CInt(drDu("MassType"))
            ProbablyCheckBox.Checked = CBool(drDu("MassProbably"))
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesDataAdapter.SaveDuctData(
                siteId,
                NormalCheckBox.Checked,
                DilatedCheckBox.Checked,
                DilatedLengthNumericTextBox.Value,
                Utilities.GetRadioValue(DilatedTypeRadioButtonList),
                StrictureCheckBox.Checked,
                StrictureLengthNumericTextBox.Value,
                UpstreamDilatationCheckBox.Checked,
                CompleteBlockCheckBox.Checked,
                SmoothCheckBox.Checked,
                IrregularCheckBox.Checked,
                ShoulderedCheckBox.Checked,
                TortuousCheckBox.Checked,
                Utilities.GetRadioValue(StrictureTypeRadioButtonList),
                ProbablyCheckBox.Checked,
                CholangiocarcinomaCheckBox.Checked,
                ExternalCompressionCheckBox.Checked,
                FistulaCheckBox.Checked,
                FistulaQtyNumericTextBox.Value,
                VisceralCheckBox.Checked,
                CutaneousCheckBox.Checked,
                CommentsTextBox.Text,
                StonesCheckBox.Checked,
                StonesMultipleCheckBox.Checked,
                StonesQtyNumericTextBox.Value,
                StonesSizeNumericTextBox.Value,
                CystsCheckBox.Checked,
                CystsMultipleCheckBox.Checked,
                CystsQtyNumericTextBox.Value,
                CystsDiameterNumericTextBox.Value,
                CystsSimpleCheckBox.Checked,
                CystsRegularCheckBox.Checked,
                CystsIrregularCheckBox.Checked,
                CystsLoculatedCheckBox.Checked,
                CystsCommunicatingCheckBox.Checked,
                CystsCholedochalCheckBox.Checked,
                Utilities.GetRadioValue(CystsSuspectedTypeRadioButtonList),
                DuctInjuryCheckBox.Checked,
                StentOcclusionCheckBox.Checked,
                GallBladderTumorCheckBox.Checked,
                DiverticulumCheckBox.Checked,
                AnastomicStrictureCheckbox.Checked,
                MirizziSyndromeCheckbox.Checked,
                SclerosingCholangitisCheckBox.Checked,
                CalculousObstructionCheckBox.Checked,
                OcclusionCheckBox.Checked,
                BiliaryLeakCheckBox.Checked,
                PreviousSurgeryCheckBox.Checked,
                PancreaticTumourCheckBox.Checked,
                MigratedStentCheckBox.Checked,
                IPMNCheckBox.Checked,
                HemobiliaCheckBox.Checked,
                CholangiopathyCheckBox.Checked,
                MassDistortingAnatomyCheckBox.Checked,
                Utilities.GetRadioValue(MassTypeRadioButtonList),
                ProbablyCheckBox.Checked,
                OtherTextBox.Text)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
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

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click

    End Sub
End Class
