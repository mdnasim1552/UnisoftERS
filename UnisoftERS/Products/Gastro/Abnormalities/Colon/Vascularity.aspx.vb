Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Colon_Vascularity
    Inherits SiteDetailsBase

    Private Shared siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_Colon_Vascularity_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtDi As DataTable = AbnormalitiesColonDataAdapter.GetVascularityData(siteId)
            If dtDi.Rows.Count > 0 Then
                PopulateData(dtDi.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drDi As DataRow)
        NoneCheckBox.Checked = CBool(drDi("None"))
        Indistinct_RadioButton.Checked = CBool(drDi("Indistinct"))
        Exaggerated_RadioButton.Checked = CBool(drDi("Exaggerated"))
        Attenuated_RadioButton.Checked = CBool(drDi("Attenuated"))
        Telangiectasia_RadioButton.Checked = CBool(drDi("Telangeiectasia"))
        Angiodysplasia_RadioButton.Checked = CBool(drDi("Angiodysplasia"))
        RadiationProtitis_RadioButton.Checked = CBool(drDi("RadiationProtitis"))
        If Telangiectasia_RadioButton.Checked Then
            cell.Attributes.Add("Style", "display:normal") 'cell.Visible = True 
            sizediv.Attributes.Add("Style", "display:none")
            MultipleCheckbox.Checked = CBool(drDi("TelangeiectasiaMultiple"))
            If Not IsDBNull(drDi("TelangeiectasiaQuantity")) Then
                QuantityTextBox.Value = CInt(drDi("TelangeiectasiaQuantity"))
            End If
        ElseIf Angiodysplasia_RadioButton.Checked Then
            cell.Attributes.Add("Style", "display:normal")
            sizediv.Attributes.Add("Style", "display:normal")
            MultipleCheckbox.Checked = CBool(drDi("AngiodysplasiaMultiple"))
            If Not IsDBNull(drDi("AngiodysplasiaQuantity")) Then
                QuantityTextBox.Value = CInt(drDi("AngiodysplasiaQuantity"))
            End If
            If Not IsDBNull(drDi("AngiodysplasiaSize")) Then
                ASizeTextBox.Value = CInt(drDi("AngiodysplasiaSize"))
            End If

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

            Dim bTelangiectasiaMultiple As Boolean
            Dim intTelangeiectasiaQuantity As Nullable(Of Integer)
            Dim bAngiodysplasiaMultiple As Boolean
            Dim bintAngiodysplasiaQuantity As Nullable(Of Integer)
            Dim bintAngiodysplasiaSize As Nullable(Of Integer)

            If Telangiectasia_RadioButton.Checked Then
                bTelangiectasiaMultiple = MultipleCheckbox.Checked
                intTelangeiectasiaQuantity = QuantityTextBox.Value
            ElseIf Angiodysplasia_RadioButton.Checked Then
                bAngiodysplasiaMultiple = MultipleCheckbox.Checked
                bintAngiodysplasiaQuantity = QuantityTextBox.Value
                bintAngiodysplasiaSize = ASizeTextBox.Value
            End If

            AbnormalitiesColonDataAdapter.SaveVascularityData(
                siteId,
                NoneCheckBox.Checked,
                Indistinct_RadioButton.Checked,
                Exaggerated_RadioButton.Checked,
                Attenuated_RadioButton.Checked,
                Telangiectasia_RadioButton.Checked,
                bTelangiectasiaMultiple,
                intTelangeiectasiaQuantity,
                Angiodysplasia_RadioButton.Checked,
                bAngiodysplasiaMultiple,
                bintAngiodysplasiaQuantity,
                bintAngiodysplasiaSize,
                RadiationProtitis_RadioButton.Checked)

            'SetControlProperties()

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Colon Abnormalities - Vascularity.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
