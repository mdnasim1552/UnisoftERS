Imports System.Windows
Imports Telerik.Web.UI

Public Class Products_Gastro_Abnormalities_Colon_Tumour
    Inherits SiteDetailsBase

    Private Shared siteId As Integer
    Private Shared ProcTypeId As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        ProcTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        If Not Page.IsPostBack Then

            PolypTattooedRadioButtonList = DirectCast(FindControl("PolypTattooedRadioButtonList"), Global.System.Web.UI.WebControls.RadioButtonList)
            RadNotification1 = DirectCast(FindControl("RadNotification1"), Global.Telerik.Web.UI.RadNotification)
            TumourLargestNumericTextBox = DirectCast(FindControl("TumourLargestNumericTextBox"), Global.Telerik.Web.UI.RadNumericTextBox)
            GranulomaLargestNumericTextBox = DirectCast(FindControl("GranulomaLargestNumericTextBox"), Global.Telerik.Web.UI.RadNumericTextBox)
            DysplasticLargestNumericTextBox = DirectCast(FindControl("DysplasticLargestNumericTextBox"), Global.Telerik.Web.UI.RadNumericTextBox)
            TumourRadioButtonList = DirectCast(FindControl("TumourRadioButtonList"), Global.System.Web.UI.WebControls.RadioButtonList)
            Tumour_CheckBox = DirectCast(FindControl("Tumour_CheckBox"), Global.Telerik.Web.UI.RadButton)
            TumourQtyNumericTextBox = DirectCast(FindControl("TumourQtyNumericTextBox"), Global.Telerik.Web.UI.RadNumericTextBox)
            TumourProbablyCheckBox = DirectCast(FindControl("TumourProbablyCheckBox"), Global.Telerik.Web.UI.RadButton)
            Tumour_Type_ComboBox = DirectCast(FindControl("Tumour_Type_ComboBox"), Global.Telerik.Web.UI.RadComboBox)
            TattooedQtyNumericTextBox = DirectCast(FindControl("TattooedQtyNumericTextBox"), Global.Telerik.Web.UI.RadNumericTextBox)
            Tattoo_Marking_ComboBox = DirectCast(FindControl("Tattoo_Marking_ComboBox"), Global.Telerik.Web.UI.RadComboBox)
            NoneCheckBox = DirectCast(FindControl("NoneCheckBox"), Global.Telerik.Web.UI.RadButton)
            Granuloma_CheckBox = DirectCast(FindControl("Granuloma_CheckBox"), Global.Telerik.Web.UI.RadButton)
            GranulomaQtyNumericTextBox = DirectCast(FindControl("GranulomaQtyNumericTextBox"), Global.Telerik.Web.UI.RadNumericTextBox)
            Dysplastic_CheckBox = DirectCast(FindControl("Dysplastic_CheckBox"), Global.Telerik.Web.UI.RadButton)
            DysplasticQtyNumericTextBox = DirectCast(FindControl("DysplasticQtyNumericTextBox"), Global.Telerik.Web.UI.RadNumericTextBox)

            Tumour_Type_ComboBox.DataSource = DataAdapter.LoadTumourTypes()
            Tumour_Type_ComboBox.DataBind()

            PolypTattooedRadioButtonList.DataSource = DataAdapter.LoadTattooOptions
            PolypTattooedRadioButtonList.DataBind()

            Tattoo_Marking_ComboBox.DataSource = DataAdapter.LoadMarkingTypes()
            Tattoo_Marking_ComboBox.DataBind()

            Dim dtDf As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_colon_tumour_select")
            If dtDf.Rows.Count > 0 Then
                PopulateData(dtDf.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drDf As DataRow)
        NoneCheckBox.Checked = CBool(drDf("None"))

        If CBool(drDf("Submucosal")) Then
            TumourRadioButtonList.SelectedValue = 1
            If Not IsDBNull(drDf("SubmucosalQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drDf("SubmucosalQuantity"))
            If Not IsDBNull(drDf("SubmucosalLargest")) Then TumourLargestNumericTextBox.Text = CInt(drDf("SubmucosalLargest"))
            TumourProbablyCheckBox.Checked = CBool(drDf("SubmucosalProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drDf("SubmucosalType"))
        ElseIf CBool(drDf("Villous")) Then
            TumourRadioButtonList.SelectedValue = 2
            If Not IsDBNull(drDf("VillousQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drDf("VillousQuantity"))
            If Not IsDBNull(drDf("VillousLargest")) Then TumourLargestNumericTextBox.Text = CInt(drDf("VillousLargest"))
            TumourProbablyCheckBox.Checked = CBool(drDf("VillousProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drDf("VillousType"))
        ElseIf CBool(drDf("Ulcerative")) Then
            TumourRadioButtonList.SelectedValue = 3
            If Not IsDBNull(drDf("UlcerativeQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drDf("UlcerativeQuantity"))
            If Not IsDBNull(drDf("UlcerativeLargest")) Then TumourLargestNumericTextBox.Text = CInt(drDf("UlcerativeLargest"))
            TumourProbablyCheckBox.Checked = CBool(drDf("UlcerativeProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drDf("UlcerativeType"))
        ElseIf CBool(drDf("Stricturing")) Then
            TumourRadioButtonList.SelectedValue = 4
            If Not IsDBNull(drDf("StricturingQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drDf("StricturingQuantity"))
            If Not IsDBNull(drDf("StricturingLargest")) Then TumourLargestNumericTextBox.Text = CInt(drDf("StricturingLargest"))
            TumourProbablyCheckBox.Checked = CBool(drDf("StricturingProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drDf("StricturingType"))
        ElseIf CBool(drDf("Polypoidal")) Then
            TumourRadioButtonList.SelectedValue = 5
            If Not IsDBNull(drDf("PolypoidalQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drDf("PolypoidalQuantity"))
            If Not IsDBNull(drDf("PolypoidalLargest")) Then TumourLargestNumericTextBox.Text = CInt(drDf("PolypoidalLargest"))
            TumourProbablyCheckBox.Checked = CBool(drDf("PolypoidalProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drDf("PolypoidalType"))
        End If

        If TumourRadioButtonList.SelectedValue <> "" AndAlso TumourRadioButtonList.SelectedValue > 0 Then
            Tumour_CheckBox.Checked = True
        End If

        Granuloma_CheckBox.Checked = CBool(drDf("Granuloma"))
        If Not IsDBNull(drDf("GranulomaQuantity")) Then
            GranulomaQtyNumericTextBox.Text = CInt(drDf("GranulomaQuantity"))
        End If
        If Not IsDBNull(drDf("GranulomaLargest")) Then
            GranulomaLargestNumericTextBox.Text = CInt(drDf("GranulomaLargest"))
        End If
        Dysplastic_CheckBox.Checked = CBool(drDf("Dysplastic"))
        If Not IsDBNull(drDf("DysplasticQuantity")) Then
            DysplasticQtyNumericTextBox.Text = CInt(drDf("DysplasticQuantity"))
        End If
        If Not IsDBNull(drDf("DysplasticLargest")) Then
            DysplasticLargestNumericTextBox.Text = CInt(drDf("DysplasticLargest"))
        End If

        If Not IsDBNull(drDf("TattooedId")) Then
            PolypTattooedRadioButtonList.SelectedValue = CInt(drDf("TattooedId"))

            If Not IsDBNull(drDf("TattooedQuantity")) Then
                TattooedQtyNumericTextBox.Text = CInt(drDf("TattooedQuantity"))
            End If

            If Not IsDBNull(drDf("TattooMarkingTypeId")) Then
                Tattoo_Marking_ComboBox.SelectedValue = CInt(drDf("TattooMarkingTypeId"))
            End If
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        'check if tattoo details required
        If (If(GranulomaLargestNumericTextBox.Value, 0) >= 20 Or If(DysplasticLargestNumericTextBox.Value, 0) >= 20 Or If(TumourLargestNumericTextBox.Value, 0)) >= 20 And PolypTattooedRadioButtonList.SelectedIndex = -1 And Not NoneCheckBox.Checked Then
            'Utilities.SetNotificationStyle(RadNotification1, "Please specify tumour tattoo details.", True)
            'RadNotification1.Show()
            Exit Sub
        End If

        'check if at least one type of tumour has been selected
        If TumourRadioButtonList.SelectedIndex = -1 And Tumour_CheckBox.Checked Then
            'Utilities.SetNotificationStyle(RadNotification1, "Please select tumour type.", True)
            'RadNotification1.Show()
            Exit Sub
        End If

        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)

        Dim Tumour As Integer = 0
        Dim TumourQty As Integer? = Nothing
        Dim TumourLargest As Integer? = Nothing
        Dim TumourProbably As Boolean = False
        Dim Tumour_Type As Integer = 0

        If Tumour_CheckBox.Checked Then
            Tumour = If(TumourRadioButtonList.SelectedValue = "", 0, TumourRadioButtonList.SelectedValue)
            TumourQty = If(TumourQtyNumericTextBox.Value Is Nothing, Nothing, TumourQtyNumericTextBox.Value)
            TumourLargest = If(TumourLargestNumericTextBox.Value Is Nothing, Nothing, TumourLargestNumericTextBox.Value)
            TumourProbably = TumourProbablyCheckBox.Checked
            Tumour_Type = If(Tumour_Type_ComboBox.SelectedValue = "", 0, Tumour_Type_ComboBox.SelectedValue)
        End If

        Dim TattooedId As Integer? = Nothing
        Dim TattooQty As Integer? = Nothing
        Dim TattooMarkingTypeId As Integer? = Nothing

        If PolypTattooedRadioButtonList.SelectedIndex > -1 AndAlso Tumour_CheckBox.Checked Then
            TattooedId = PolypTattooedRadioButtonList.SelectedValue
            TattooQty = TattooedQtyNumericTextBox.Value
            TattooMarkingTypeId = If(Tattoo_Marking_ComboBox.SelectedValue = "", Nothing, Tattoo_Marking_ComboBox.SelectedValue)
        End If

        Dim polypSelectedIndex = PolypTattooedRadioButtonList.SelectedIndex = -1
        Dim polypTattooedSelectedVal = If(polypSelectedIndex, 0, CInt(PolypTattooedRadioButtonList.SelectedValue))
        Dim tattooQtyVal = TattooedQtyNumericTextBox.Value Is Nothing
        Dim tattooMarkingCombo = String.IsNullOrEmpty(Tattoo_Marking_ComboBox.SelectedValue)

        If Tumour_CheckBox.Checked Then
            If Tumour = 0 Or polypSelectedIndex Then
                Return
            End If

            If Not polypSelectedIndex AndAlso polypTattooedSelectedVal = 2 Then
                If tattooQtyVal Or tattooMarkingCombo Then
                    Return
                End If
            End If
        End If

        Try
            AbnormalitiesDataAdapter.SaveColonTumourData(
                siteId,
                NoneCheckBox.Checked,
                IIf(Tumour = 1, True, False),
                IIf(Tumour = 1, TumourQty, Nothing),
                IIf(Tumour = 1, TumourLargest, Nothing),
                IIf(Tumour = 1, TumourProbably, False),
                IIf(Tumour = 1, Tumour_Type, 0),
                IIf(Tumour = 2, True, False),
                IIf(Tumour = 2, TumourQty, Nothing),
                IIf(Tumour = 2, TumourLargest, Nothing),
                IIf(Tumour = 2, TumourProbably, False),
                IIf(Tumour = 2, Tumour_Type, 0),
                IIf(Tumour = 3, True, False),
                IIf(Tumour = 3, TumourQty, Nothing),
                IIf(Tumour = 3, TumourLargest, Nothing),
                IIf(Tumour = 3, TumourProbably, False),
                IIf(Tumour = 3, Tumour_Type, 0),
                IIf(Tumour = 4, True, False),
                IIf(Tumour = 4, TumourQty, Nothing),
                IIf(Tumour = 4, TumourLargest, Nothing),
                IIf(Tumour = 4, TumourProbably, False),
                IIf(Tumour = 4, Tumour_Type, 0),
                IIf(Tumour = 5, True, False),
                IIf(Tumour = 5, TumourQty, Nothing),
                IIf(Tumour = 5, TumourLargest, Nothing),
                IIf(Tumour = 5, TumourProbably, False),
                IIf(Tumour = 5, Tumour_Type, 0),
                Granuloma_CheckBox.Checked,
                GranulomaQtyNumericTextBox.Value,
                GranulomaLargestNumericTextBox.Value,
                Dysplastic_CheckBox.Checked,
                DysplasticQtyNumericTextBox.Value,
                DysplasticLargestNumericTextBox.Value,
                TattooedId,
                TattooQty,
                TattooMarkingTypeId,
                Tumour_CheckBox.Checked)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Tumour.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            'RadNotification1.Show()
        End Try
    End Sub

End Class