Imports Telerik.Web.UI
Imports System.Data.SqlClient

Partial Class Products_Gastro_Abnormalities_ERCP_Parenchyma
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_ERCP_Parenchyma_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        Dim reg As String = Request.QueryString("Reg")

        If Not Page.IsPostBack Then

            SetControls(reg)

            Dim dtPa As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_parenchyma_select")
            If dtPa.Rows.Count > 0 Then
                PopulateData(dtPa.Rows(0))
            End If
        End If
    End Sub

    Private Sub SetControls(ByVal region As String)

        'Mahfuz added on 14 May 2021
        Dim Hepatic() As String = {"Left Hepatic Ducts", "Right Hepatic Ducts", "Left intra-hepatic ducts", "Right intra-hepatic ducts", "Right Hepatic Lobe", "Left Hepatic Lobe"}
        Dim GallBladderReg() As String = {"Gall Bladder", "Common Bile Duct", "Common Hepatic Duct", "Cystic Duct", "Bifurcation"}

        If Hepatic.Contains(region, StringComparer.CurrentCultureIgnoreCase) Then 'Hepatic Regions
            CystsCholedochalDiv.Visible = False
            CystsSuspectedRow.Visible = True
        ElseIf GallBladderReg.Contains(region, StringComparer.CurrentCultureIgnoreCase) Then 'GallBladder and the regions close to it
            CystsCholedochalDiv.Visible = True
            CystsSuspectedRow.Visible = False
        Else 'Pancreas Regions
            CystsCholedochalDiv.Visible = True
            CystsSuspectedRow.Visible = False
            CystsCommunicatingCheckBox.Text = "Communicating with pancreatic duct"
            CystsCholedochalCheckBox.Text = "Pseudocyst"

        End If
        'Finished of Mahfuz added on 14 May 2021 

        If region.ToLower.Contains("hepatic lobe") OrElse region.ToLower.Contains("hepatic ducts") Then
            MassDistortingAnatomyChildRow.Visible = True
            SpideryStretchedDuctulesRow.Visible = True
            MultipleStricturesRow.Visible = True
        Else
            MassDistortingAnatomyChildRow.Visible = False
            SpideryStretchedDuctulesRow.Visible = False
            MultipleStricturesRow.Visible = False
        End If

        If Request.QueryString("Area") IsNot Nothing AndAlso Request.QueryString("Area") = "Pancreas" Then
            PancreatitisRow.Visible = True
        End If

    End Sub

    Private Sub PopulateData(drPa As DataRow)
        NoneCheckBox.Checked = CBool(drPa("Normal"))


        IrregularDuctulesCheckBox.Checked = CBool(drPa("Irregular"))
        DilatedDuctulesCheckBox.Checked = CBool(drPa("Dilated"))
        SmallLakesCheckBox.Checked = CBool(drPa("SmallLakes"))
        StricturesCheckBox.Checked = CBool(drPa("Strictures"))
        MassDistortingAnatomyCheckBox.Checked = CBool(drPa("Mass"))
        If Not IsDBNull(drPa("MassType")) Then MassTypeRadioButtonList.SelectedValue = CInt(drPa("MassType"))
        ProbablyCheckBox.Checked = CBool(drPa("MassProbably"))
        SpideryStretchedDuctulesCheckBox.Checked = CBool(drPa("SpideryDuctules"))
        If Not IsDBNull(drPa("SpiderySuspection")) Then SpideryDuctulesRadioButtonList.SelectedValue = CInt(drPa("SpiderySuspection"))
        MultipleStricturesCheckBox.Checked = CBool(drPa("MultiStrictures"))
        AnnulareCheckBox.Checked = CBool(drPa("Annulare"))
        OcclusionCheckBox.Checked = CBool(drPa("Occlusion"))
        BiliaryLeakCheckBox.Checked = CBool(drPa("BiliaryLeak"))
        PreviousSurgeryCheckBox.Checked = CBool(drPa("PreviousSurgery"))
        PancreatitisCheckBox.Checked = CBool(drPa("Pancreatitis"))

        'Mahfuz added Cystic Lesion related 11 params on 14 May 2021
        CystsCheckBox.Checked = CBool(drPa("Cysts"))
        If CBool(drPa("Cysts")) Then
            CystsMultipleCheckBox.Checked = CBool(drPa("CystsMultiple"))
            If Not IsDBNull(drPa("CystsQty")) Then CystsQtyNumericTextBox.Value = CInt(drPa("CystsQty"))
            If Not IsDBNull(drPa("CystsDiameter")) Then CystsDiameterNumericTextBox.Value = CDec(drPa("CystsDiameter"))
            CystsSimpleCheckBox.Checked = CBool(drPa("CystsSimple"))
            CystsRegularCheckBox.Checked = CBool(drPa("CystsRegular"))
            CystsIrregularCheckBox.Checked = CBool(drPa("CystsIrregular"))
            CystsLoculatedCheckBox.Checked = CBool(drPa("CystsLoculated"))
            CystsCommunicatingCheckBox.Checked = CBool(drPa("CystsCommunicating"))
            CystsCholedochalCheckBox.Checked = CBool(drPa("CystsCholedochal"))
            If Not IsDBNull(drPa("CystsSuspectedType")) Then CystsSuspectedTypeRadioButtonList.Text = CInt(drPa("CystsSuspectedType"))
        End If
        'Finished

        If Not drPa.IsNull("PancreatitisType") Then PancreatitisTypeRadioButtonList.SelectedValue = CInt(drPa("PancreatitisType"))

        If Not IsDBNull(drPa("MultiStricturesSuspection")) Then MultipleStricturesRadioButtonList.SelectedValue = CInt(drPa("MultiStricturesSuspection"))

        If Not IsDBNull(drPa("Other")) AndAlso Not String.IsNullOrWhiteSpace(drPa("Other")) Then
            OtherCheckBox.Checked = True
            OtherTextBox.Text = drPa("Other")
        End If

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        'Mahfuz added Cystic Lesion related 11 parameters on 14 May 2021
        Try
            AbnormalitiesDataAdapter.SaveParenchymaData(
                siteId,
                NoneCheckBox.Checked,
                IrregularDuctulesCheckBox.Checked,
                DilatedDuctulesCheckBox.Checked,
                SmallLakesCheckBox.Checked,
                StricturesCheckBox.Checked,
                MassDistortingAnatomyCheckBox.Checked,
                Utilities.GetRadioValue(MassTypeRadioButtonList),
                ProbablyCheckBox.Checked,
                SpideryStretchedDuctulesCheckBox.Checked,
                Utilities.GetRadioValue(SpideryDuctulesRadioButtonList),
                MultipleStricturesCheckBox.Checked,
                Utilities.GetRadioValue(MultipleStricturesRadioButtonList),
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
                AnnulareCheckBox.Checked,
                PancreatitisCheckBox.Checked,
                Utilities.GetRadioValue(PancreatitisTypeRadioButtonList),
                OcclusionCheckBox.Checked,
                BiliaryLeakCheckBox.Checked,
                PreviousSurgeryCheckBox.Checked,
                OtherTextBox.Text)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            'If saveAndClose Then
            '    ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            'End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving ERCP Abnormalities - Parenchyma.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click

    End Sub
End Class