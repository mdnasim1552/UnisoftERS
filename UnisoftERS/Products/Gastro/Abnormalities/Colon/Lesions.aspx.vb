Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Colon_Lesions
    Inherits SiteDetailsBase

    Public siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_Colon_Lesions_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))


        If Not Page.IsPostBack Then
            Session("ColonPolypDetails") = Nothing
            LoadPage()
        End If
        SetIconClass()
    End Sub

    Private Sub LoadPage()
        Try
            SetControls()
            Dim dtMu As DataTable = AbnormalitiesColonDataAdapter.GetLesionsData(siteId)
            If dtMu.Rows.Count > 0 Then
                PopulateData(dtMu.Rows(0))
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading lesion data", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading lesion data")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub SetIconClass()
        If vSessileParisClassification Then
            SessileParisShowButton.Icon.PrimaryIconCssClass = "rbOk"
        Else
            SessileParisShowButton.Icon.PrimaryIconCssClass = Nothing
        End If
        If vSessilePitPattern Then
            SessilePitShowButton.Icon.PrimaryIconCssClass = "rbOk"
        Else
            SessilePitShowButton.Icon.PrimaryIconCssClass = Nothing
        End If
        If vPedunculatedParisClassification Then
            PedunculatedParisShowButton.Icon.PrimaryIconCssClass = "rbOk"
        Else
            PedunculatedParisShowButton.Icon.PrimaryIconCssClass = Nothing
        End If
        If vPedunculatedPitPattern Then
            PedunculatedPitShowButton.Icon.PrimaryIconCssClass = "rbOk"
        Else
            PedunculatedPitShowButton.Icon.PrimaryIconCssClass = Nothing
        End If
    End Sub

    Private Sub SetControls()
        For Each c In rgAbnormalities.Controls
            For Each childc In c.Controls
                If TypeOf childc Is RadComboBox Then
                    InsertComboBoxItem(childc)
                End If
            Next
        Next

        InsertComboBoxItem(Sessile_Removal_ComboBox)
        InsertComboBoxItem(Sessile_Removal_Method_ComboBox)
        InsertComboBoxItem(Sessile_Type_ComboBox)
        InsertComboBoxItem(Pedunculated_Removal_ComboBox)
        InsertComboBoxItem(Pedunculated_Removal_Method_ComboBox)
        InsertComboBoxItem(Pedunculated_Type_ComboBox)
        InsertComboBoxItem(Pseudo_Removal_ComboBox)
        InsertComboBoxItem(Pseudo_Removal_Method_ComboBox)
        InsertComboBoxItem(Tumour_Type_ComboBox)
        'InsertComboBoxItem(Submucosal_Type_ComboBox)
        'InsertComboBoxItem(Villous_Type_ComboBox)
        'InsertComboBoxItem(Ulcerative_Type_ComboBox)
        'InsertComboBoxItem(Stricturing_Type_ComboBox)
        'InsertComboBoxItem(Polypoidal_Type_ComboBox)

        'For Each ctrl In Page.Controls
        '    'ctrl = rgAbnormalities.FindControl("PedunculatedPolyps_CheckBox")

        '    If TypeOf ctrl Is RadComboBox Then
        '        'DirectCast(ctrl, RadComboBox).ForeColor() = Color.Red
        '        InsertComboBoxItem(ctrl)
        '        'ElseIf TypeOf ctrl Is RadButton Then
        '        '    Dim abnormalitiesRB As RadButton = DirectCast(ctrl, RadButton)

        '        '    If abnormalitiesRB.ID.Contains("ParisShow") Or abnormalitiesRB.ID.Contains("PitShow") Then
        '        '        Exit Sub
        '        '    End If

        '        'abnormalitiesRB.ToggleType = ButtonToggleType.CheckBox
        '        'abnormalitiesRB.ButtonType = RadButtonType.ToggleButton
        '        'abnormalitiesRB.AutoPostBack = False
        '        'If abnormalitiesRB.ID = "NoneCheckBox" Then
        '        '    abnormalitiesRB.ForeColor() = ColorTranslator.FromHtml("#384e76")
        '        'Else
        '        '    abnormalitiesRB.ForeColor() = Color.Gray
        '        'End If
        '    End If
        'Next

        'Set TR visibility for Tattoo Info
        Dim da As New DataAccess

        Dim dtConsultantRoles = da.ProcedureConsultantRoles(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        If dtConsultantRoles IsNot Nothing AndAlso dtConsultantRoles.Rows.Count > 1 Then
            trTattooedBy.Visible = True
            TattooedByRadioButtonList.DataSource = dtConsultantRoles
            TattooedByRadioButtonList.DataTextField = "Role"
            TattooedByRadioButtonList.DataValueField = "RoleID"
            TattooedByRadioButtonList.DataBind()
        End If
    End Sub

    Private Sub InsertComboBoxItem(ctrl As RadComboBox)
        If ctrl.ID.EndsWith("_Removal_ComboBox") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("entire", "1"))
            ctrl.Items.Add(New RadComboBoxItem("piecemeal", "2"))

        ElseIf ctrl.ID.EndsWith("_Removal_Method_ComboBox") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("partial snare", "1"))
            ctrl.Items.Add(New RadComboBoxItem("cold snare", "2"))
            ctrl.Items.Add(New RadComboBoxItem("hot snare", "3"))
            ctrl.Items.Add(New RadComboBoxItem("hot bx", "4"))
            ctrl.Items.Add(New RadComboBoxItem("cold bx", "5"))
            ctrl.Items.Add(New RadComboBoxItem("hot snare by EMR", "6"))
            ctrl.Items.Add(New RadComboBoxItem("cold snare by EMR", "7"))

        ElseIf ctrl.ID.EndsWith("_Type_ComboBox") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("benign", "1"))
            ctrl.Items.Add(New RadComboBoxItem("malignant", "2"))

        ElseIf ctrl.ID.StartsWith("Tattoo_Marking") Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{Tattoo_Marking_ComboBox, ""}}, DataAdapter.GetMarkingTypes(), "ListItemText", "ListItemNo")
        End If

        ctrl.Width = "90"
        ctrl.Style("text-align") = "center"
        'ctrl.Enabled = False
        ctrl.CssClass = "abnor_cb1"
    End Sub

    Private Sub PopulateData(drLe As DataRow)

        NoneCheckBox.Checked = CBool(drLe("None"))
        Sessile_CheckBox.Checked = CBool(drLe("Sessile"))
        If Not IsDBNull(drLe("SessileQuantity")) Then
            SessileQtyNumericTextBox.Text = CInt(drLe("SessileQuantity"))
        End If
        If Not IsDBNull(drLe("SessileLargest")) Then
            SessileLargestNumericTextBox.Text = CInt(drLe("SessileLargest"))
        End If
        If Not IsDBNull(drLe("SessileExcised")) Then
            SessileExcisedNumericTextBox.Text = CInt(drLe("SessileExcised"))
        End If
        If Not IsDBNull(drLe("SessileSuccessful")) Then
            SessileSuccessfulNumericTextBox.Text = CInt(drLe("SessileSuccessful"))
        End If
        If Not IsDBNull(drLe("SessileRetrieved")) Then
            SessileRetrievedNumericTextBox.Text = CInt(drLe("SessileRetrieved"))
        End If
        If Not IsDBNull(drLe("SessileToLabs")) Then
            SessileToLabsNumericTextBox.Text = CInt(drLe("SessileToLabs"))
        End If
        Sessile_Removal_ComboBox.SelectedValue = CInt(drLe("SessileRemoval"))
        Sessile_Removal_Method_ComboBox.SelectedValue = CInt(drLe("SessileRemovalMethod"))
        SessileProbablyCheckBox.Checked = CBool(drLe("SessileProbably"))
        Sessile_Type_ComboBox.SelectedValue = CInt(drLe("SessileType"))
        vSessileParisClassification = drLe("SessileParisClass")
        vSessilePitPattern = drLe("SessilePitPattern")

        PedunculatedPolyps_CheckBox.Checked = CBool(drLe("Pedunculated"))
        If Not IsDBNull(drLe("PedunculatedQuantity")) Then
            PedunculatedPolypsQtyNumericTextBox.Text = CInt(drLe("PedunculatedQuantity"))
        End If
        If Not IsDBNull(drLe("PedunculatedLargest")) Then
            PedunculatedLargestNumericTextBox.Text = CInt(drLe("PedunculatedLargest"))
        End If
        If Not IsDBNull(drLe("PedunculatedExcised")) Then
            PedunculatedExcisedNumericTextBox.Text = CInt(drLe("PedunculatedExcised"))
        End If
        If Not IsDBNull(drLe("PedunculatedSuccessful")) Then
            PedunculatedSuccessfulNumericTextBox.Text = CInt(drLe("PedunculatedSuccessful"))
        End If
        If Not IsDBNull(drLe("PedunculatedRetrieved")) Then
            PedunculatedRetrievedNumericTextBox.Text = CInt(drLe("PedunculatedRetrieved"))
        End If
        If Not IsDBNull(drLe("PedunculatedToLabs")) Then
            PedunculatedToLabsNumericTextBox.Text = CInt(drLe("PedunculatedToLabs"))
        End If
        Pedunculated_Removal_ComboBox.SelectedValue = CInt(drLe("PedunculatedRemoval"))
        Pedunculated_Removal_Method_ComboBox.SelectedValue = CInt(drLe("PedunculatedRemovalMethod"))
        PedunculatedProbablyCheckBox.Checked = CBool(drLe("PedunculatedProbably"))
        Pedunculated_Type_ComboBox.SelectedValue = CInt(drLe("PedunculatedType"))
        vPedunculatedParisClassification = drLe("PedunculatedParisClass")
        vPedunculatedPitPattern = drLe("PedunculatedPitPattern")

        PseudoPolyps_CheckBox.Checked = CBool(drLe("Pseudopolyps"))
        PseudoMultipleCheckBox.Checked = CBool(drLe("PseudopolypsMultiple"))
        If Not IsDBNull(drLe("PseudopolypsQuantity")) Then
            PseudoPolypsQtyNumericTextBox.Text = CInt(drLe("PseudopolypsQuantity"))
        End If
        If Not IsDBNull(drLe("PseudopolypsLargest")) Then
            PseudoLargestNumericTextBox.Text = CInt(drLe("PseudopolypsLargest"))
        End If
        If Not IsDBNull(drLe("PseudopolypsExcised")) Then
            PseudoExcisedNumericTextBox.Text = CInt(drLe("PseudopolypsExcised"))
        End If
        If Not IsDBNull(drLe("PseudopolypsSuccessful")) Then
            PseudoSuccessfulNumericTextBox.Text = CInt(drLe("PseudopolypsSuccessful"))
        End If
        If Not IsDBNull(drLe("PseudopolypsRetrieved")) Then
            PseudoRetrievedNumericTextBox.Text = CInt(drLe("PseudopolypsRetrieved"))
        End If
        If Not IsDBNull(drLe("PseudopolypsToLabs")) Then
            PseudoToLabsNumericTextBox.Text = CInt(drLe("PseudopolypsToLabs"))
        End If
        PseudoInflamCheckBox.Checked = CBool(drLe("PseudopolypsInflam"))
        PseudoPostInflamCheckBox.Checked = CBool(drLe("PseudopolypsPostInflam"))
        Pseudo_Removal_ComboBox.SelectedValue = CInt(drLe("PseudopolypsRemoval"))
        Pseudo_Removal_Method_ComboBox.SelectedValue = CInt(drLe("PseudopolypsRemovalMethod"))

        If CBool(drLe("Submucosal")) Then
            TumourRadioButtonList.SelectedValue = 1
            If Not IsDBNull(drLe("SubmucosalQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drLe("SubmucosalQuantity"))
            If Not IsDBNull(drLe("SubmucosalLargest")) Then TumourLargestNumericTextBox.Text = CInt(drLe("SubmucosalLargest"))
            TumourProbablyCheckBox.Checked = CBool(drLe("SubmucosalProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drLe("SubmucosalType"))
        ElseIf CBool(drLe("Villous")) Then
            TumourRadioButtonList.SelectedValue = 2
            If Not IsDBNull(drLe("VillousQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drLe("VillousQuantity"))
            If Not IsDBNull(drLe("VillousLargest")) Then TumourLargestNumericTextBox.Text = CInt(drLe("VillousLargest"))
            TumourProbablyCheckBox.Checked = CBool(drLe("VillousProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drLe("VillousType"))
        ElseIf CBool(drLe("Ulcerative")) Then
            TumourRadioButtonList.SelectedValue = 3
            If Not IsDBNull(drLe("UlcerativeQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drLe("UlcerativeQuantity"))
            If Not IsDBNull(drLe("UlcerativeLargest")) Then TumourLargestNumericTextBox.Text = CInt(drLe("UlcerativeLargest"))
            TumourProbablyCheckBox.Checked = CBool(drLe("UlcerativeProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drLe("UlcerativeType"))
        ElseIf CBool(drLe("Stricturing")) Then
            TumourRadioButtonList.SelectedValue = 4
            If Not IsDBNull(drLe("StricturingQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drLe("StricturingQuantity"))
            If Not IsDBNull(drLe("StricturingLargest")) Then TumourLargestNumericTextBox.Text = CInt(drLe("StricturingLargest"))
            TumourProbablyCheckBox.Checked = CBool(drLe("StricturingProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drLe("StricturingType"))
        ElseIf CBool(drLe("Polypoidal")) Then
            TumourRadioButtonList.SelectedValue = 5
            If Not IsDBNull(drLe("PolypoidalQuantity")) Then TumourQtyNumericTextBox.Text = CInt(drLe("PolypoidalQuantity"))
            If Not IsDBNull(drLe("PolypoidalLargest")) Then TumourLargestNumericTextBox.Text = CInt(drLe("PolypoidalLargest"))
            TumourProbablyCheckBox.Checked = CBool(drLe("PolypoidalProbably"))
            Tumour_Type_ComboBox.SelectedValue = CInt(drLe("PolypoidalType"))
        End If


        If TumourRadioButtonList.SelectedValue <> "" AndAlso TumourRadioButtonList.SelectedValue > 0 Then
            Tumour_CheckBox.Checked = True
        End If


        Granuloma_CheckBox.Checked = CBool(drLe("Granuloma"))
        If Not IsDBNull(drLe("GranulomaQuantity")) Then
            GranulomaQtyNumericTextBox.Text = CInt(drLe("GranulomaQuantity"))
        End If
        If Not IsDBNull(drLe("GranulomaLargest")) Then
            GranulomaLargestNumericTextBox.Text = CInt(drLe("GranulomaLargest"))
        End If

        'MH added on 25 Oct 2021 Fundic Gland Polyp
        FundicGlandPolyp_CheckBox.Checked = CBool(drLe("FundicGlandPolyp"))
        If Not IsDBNull(drLe("FundicGlandPolypQuantity")) Then
            FundicGlandPolypQtyNumericTextBox.Text = CInt(drLe("FundicGlandPolypQuantity"))
        End If
        If Not IsDBNull(drLe("FundicGlandPolypLargest")) Then
            FundicGlandPolypLargestNumericTextBox.Text = CDbl(drLe("FundicGlandPolypLargest")).ToString()
        End If

        Dysplastic_CheckBox.Checked = CBool(drLe("Dysplastic"))
        If Not IsDBNull(drLe("DysplasticQuantity")) Then
            DysplasticQtyNumericTextBox.Text = CInt(drLe("DysplasticQuantity"))
        End If
        If Not IsDBNull(drLe("DysplasticLargest")) Then
            DysplasticLargestNumericTextBox.Text = CInt(drLe("DysplasticLargest"))
        End If
        Pneumatosis_CheckBox.Checked = CBool(drLe("PneumatosisColi"))

        'MH added on 19 Oct 2021
        If Not IsDBNull(drLe("TattooLocationTop")) Then
            chkTattooLocationTop.Checked = CBool(drLe("TattooLocationTop"))
        Else
            chkTattooLocationTop.Checked = False
        End If
        If Not IsDBNull(drLe("TattooLocationLeft")) Then
            chkTattooLocationLeft.Checked = CBool(drLe("TattooLocationLeft"))
        Else
            chkTattooLocationLeft.Checked = False
        End If
        If Not IsDBNull(drLe("TattooLocationRight")) Then
            chkTattooLocationRight.Checked = CBool(drLe("TattooLocationRight"))
        Else
            chkTattooLocationRight.Checked = False
        End If
        If Not IsDBNull(drLe("TattooLocationBottom")) Then
            chkTattooLocationBottom.Checked = CBool(drLe("TattooLocationBottom"))
        Else
            chkTattooLocationBottom.Checked = False
        End If


        If Not IsDBNull(drLe("Tattooed")) Then
            If Not IsDBNull(drLe("PreviouslyTattooed")) AndAlso CBool(drLe("PreviouslyTattooed")) Then
                PolypTattooedRadioButtonList.SelectedValue = 2
            ElseIf Not CBool(drLe("Tattooed")) Then
                PolypTattooedRadioButtonList.SelectedValue = 0
            ElseIf CBool(drLe("Tattooed")) Then
                PolypTattooedRadioButtonList.SelectedValue = 1
            End If

            If Not IsDBNull(drLe("TattooedQuantity")) Then
                TattooedQtyNumericTextBox.Text = CInt(drLe("TattooedQuantity"))
            End If

            If Not IsDBNull(drLe("TattooType")) Then
                Tattoo_Marking_ComboBox.SelectedValue = CInt(drLe("TattooType"))
            End If

            If Not IsDBNull(drLe("TattooedBy")) AndAlso trTattooedBy.Visible Then
                TattooedByRadioButtonList.SelectedValue = CInt(drLe("TattooedBy"))
            End If
        End If

        If CBool(drLe("Sessile")) Or CBool(drLe("Pedunculated")) Or CBool(drLe("Pseudopolyps")) Then
            Dim polypDetails = AbnormalitiesColonDataAdapter.GetLesionsPolypData(siteId)
            If polypDetails IsNot Nothing AndAlso polypDetails.Count > 0 Then
                If drLe("Sessile") Then polypDetails.ForEach(Function(x)
                                                                 x.PolypType = "sessile"
                                                                 Return True
                                                             End Function)
                If drLe("Pedunculated") Then polypDetails.ForEach(Function(x)
                                                                      x.PolypType = "pedunculated"
                                                                      Return True
                                                                  End Function)
                If drLe("Pseudopolyps") Then polypDetails.ForEach(Function(x)
                                                                      x.PolypType = "pseudo"
                                                                      Return True
                                                                  End Function)

                Session("ColonPolypDetails") = polypDetails
            Else
                polypDetails = New List(Of SitePolyps)
                'this must be an old record before the change to specify individual details. Make it work with the new way
                If CBool(drLe("sessile")) And Not drLe.IsNull("SessileLargest") Then
                    polypDetails.Add(New SitePolyps With {
                        .PolypType = "sessile",
                        .Size = CInt(drLe("SessileLargest")),
                        .Excised = If(CInt(drLe("SessileExcised")) > 0, True, False),
                        .Retrieved = If(CInt(drLe("SessileRetrieved")) > 0, True, False),
                        .Successful = If(CInt(drLe("SessileSuccessful")) > 0, True, False),
                        .SentToLabs = If(CInt(drLe("SessileToLabs")) > 0, True, False),
                        .Removal = CInt(drLe("SessileRemoval")),
                        .RemovalMethod = CInt(drLe("SessileRemovalMethod")),
                        .Probably = CBool(drLe("SessileProbably")),
                        .TumourType = CInt(drLe("SessileType")),
                        .Inflammatory = False,
                        .PostInflammatory = False,
                        .ParisClassification = CInt(drLe("SessileParisClass")),
                        .PitPattern = CInt(drLe("SessilePitPattern"))
                        })
                ElseIf CBool(drLe("pedunculated")) And Not drLe.IsNull("PedunculatedLargest") Then
                    polypDetails.Add(New SitePolyps With {
                       .PolypType = "pedunculated",
                       .Size = CInt(drLe("PedunculatedLargest")),
                       .Excised = If(CInt(drLe("PedunculatedExcised")) > 0, True, False),
                       .Retrieved = If(CInt(drLe("PedunculatedRetrieved")) > 0, True, False),
                       .Successful = If(CInt(drLe("PedunculatedSuccessful")) > 0, True, False),
                       .SentToLabs = If(CInt(drLe("PedunculatedToLabs")) > 0, True, False),
                       .Removal = CInt(drLe("PedunculatedRemoval")),
                       .RemovalMethod = CInt(drLe("PedunculatedRemovalMethod")),
                       .Probably = CBool(drLe("PedunculatedProbably")),
                       .TumourType = CInt(drLe("PedunculatedType")),
                       .Inflammatory = False,
                       .PostInflammatory = False,
                       .ParisClassification = CInt(drLe("PedunculatedParisClass")),
                       .PitPattern = CInt(drLe("PedunculatedPitPattern"))
                       })
                ElseIf CBool(drLe("pseudopolyps")) And Not drLe.IsNull("PseudopolypsLargest") Then
                    'Pseudopolyps
                    polypDetails.Add(New SitePolyps With {
                      .PolypType = "Pseudopolyps",
                      .Size = CInt(drLe("PseudopolypsLargest")),
                      .Excised = If(CInt(drLe("PseudopolypsExcised")) > 0, True, False),
                      .Retrieved = If(CInt(drLe("PseudopolypsRetrieved")) > 0, True, False),
                      .Successful = If(CInt(drLe("PseudopolypsSuccessful")) > 0, True, False),
                      .SentToLabs = If(CInt(drLe("PseudopolypsToLabs")) > 0, True, False),
                      .Removal = CInt(drLe("PseudopolypsRemoval")),
                      .RemovalMethod = CInt(drLe("PseudopolypsRemovalMethod")),
                      .Probably = CBool(drLe("PseudopolypsProbably")),
                      .TumourType = CInt(drLe("PseudopolypsType")),
                      .Inflammatory = CBool(drLe("PseudopolypsInflam")),
                      .PostInflammatory = CBool(drLe("PseudopolypsPostInflam")),
                      .ParisClassification = CInt(drLe("PseudopolypsParisClass")),
                      .PitPattern = CInt(drLe("PseudopolypsPitPattern"))
                      })
                End If
                Session("ColonPolypDetails") = polypDetails
            End If
        End If
        'SetControlProperties()
    End Sub

    Private Sub SetControlProperties()
        'DisableControls(Atrophic_CheckBox, Atrophic_Distribution_ComboBox, Atrophic_Severity_ComboBox)
        'DisableControls(Congested_CheckBox, Congested_Distribution_ComboBox, Congested_Severity_ComboBox)
        'DisableControls(Erythematous_CheckBox, Erythematous_Distribution_ComboBox, Erythematous_Severity_ComboBox)
        'DisableControls(Granular_CheckBox, Granular_Distribution_ComboBox, Granular_Severity_ComboBox)
        'DisableControls(Mucopurulent_CheckBox, Mucopurulent_Distribution_ComboBox, Mucopurulent_Severity_ComboBox)
        'DisableControls(Pigmented_CheckBox, Pigmented_Distribution_ComboBox, Pigmented_Severity_ComboBox)

        'DisableControls(SmallUlcers_CheckBox, SmallUlcers_Type_ComboBox)
        'DisableControls(LargeUlcers_CheckBox, LargeUlcers_Type_ComboBox)
        'DisableControls(PleomorphicUlcers_CheckBox, PleomorphicUlcers_Type_ComboBox)
        'DisableControls(SerpiginousUlcers_CheckBox, SerpiginousUlcers_Type_ComboBox)
        'DisableControls(AphthousUlcers_CheckBox, AphthousUlcers_Type_ComboBox)
        'DisableControls(Cobblestone_CheckBox, Cobblestone_Distribution_ComboBox)
    End Sub

    Private Sub DisableControls(abnorCheckBox As RadButton,
                                combo1 As RadComboBox,
                                Optional combo2 As RadComboBox = Nothing)
        If abnorCheckBox.Checked Then
            combo1.Enabled = True
            combo1.CssClass = "abnor_cb" & combo1.SelectedValue.ToString
            If combo2 IsNot Nothing Then
                combo2.Enabled = True
                combo2.CssClass = "abnor_cb" & (combo2.SelectedValue + 1).ToString
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
        Dim Tumour As Integer = 0
        Dim TumourQty As Integer = Nothing
        Dim TumourLargest As Integer = Nothing
        Dim TumourProbably As Boolean = False
        Dim Tumour_Type As Integer = 0

        If Tumour_CheckBox.Checked Then
            Tumour = IIf(TumourRadioButtonList.SelectedValue = "", 0, TumourRadioButtonList.SelectedValue)
            TumourQty = IIf(TumourQtyNumericTextBox.Value Is Nothing, Nothing, TumourQtyNumericTextBox.Value)
            TumourLargest = IIf(TumourLargestNumericTextBox.Value Is Nothing, Nothing, TumourLargestNumericTextBox.Value)
            TumourProbably = TumourProbablyCheckBox.Checked
            Tumour_Type = Tumour_Type_ComboBox.SelectedValue
        End If

        Dim Tattooed As Boolean? = Nothing
        Dim TattooLocationTop As Boolean? = Nothing
        Dim TattooLocationLeft As Boolean? = Nothing
        Dim TattooLocationRight As Boolean? = Nothing
        Dim TattooLocationBottom As Boolean? = Nothing

        Dim PreviouslyTattooed As Boolean? = Nothing
        Dim TattooMarkedWith As Nullable(Of Integer)
        Dim TattooedQty As Nullable(Of Integer)
        Dim TattooedBy As Nullable(Of Integer)

        Dim lesionSize = 0

        Dim sitePolypDetails As List(Of SitePolyps) = If(Session("ColonPolypDetails"), New List(Of SitePolyps))

        'check if entered details is for the correct polyp type eg
        'user may have changed polyp type after entering the details therefore details are no longer valid as some factors are type specific
        If (Sessile_CheckBox.Checked And Not sitePolypDetails.Any(Function(x) x.PolypType = "sessile")) Or
           (PedunculatedPolyps_CheckBox.Checked And Not sitePolypDetails.Any(Function(x) x.PolypType = "pedunculated")) Or
           (PseudoPolyps_CheckBox.Checked And Not sitePolypDetails.Any(Function(x) x.PolypType = "pseudo")) Then
            sitePolypDetails = New List(Of SitePolyps)
        End If

        If Not NoneCheckBox.Checked And (Sessile_CheckBox.Checked Or PedunculatedPolyps_CheckBox.Checked Or PseudoPolyps_CheckBox.Checked Or Tumour_CheckBox.Checked Or
                                        Granuloma_CheckBox.Checked Or Dysplastic_CheckBox.Checked Or Pneumatosis_CheckBox.Checked) Then
            If (String.IsNullOrWhiteSpace(PolypTattooedRadioButtonList.SelectedValue) Or String.IsNullOrWhiteSpace(PolypTattooedRadioButtonList.SelectedValue = "") Or (String.IsNullOrWhiteSpace(TattooedQtyNumericTextBox.Text) And PolypTattooedRadioButtonList.SelectedValue = "1")) And
                (sitePolypDetails.Any(Function(x) x.Size >= 20) Or GranulomaLargestNumericTextBox.Value >= 20 Or
                DysplasticLargestNumericTextBox.Value >= 20 Or TumourLargestNumericTextBox.Value >= 20) Then 'lesion size > 2cm
                Utilities.SetNotificationStyle(RadNotification1, "Please specify polyp tattoo details.", True)
                RadNotification1.Show()
                Exit Sub
            Else


                Select Case PolypTattooedRadioButtonList.SelectedValue
                    Case 0
                        Tattooed = False
                    Case 1
                        Tattooed = True
                        TattooLocationTop = chkTattooLocationTop.Checked
                        TattooLocationLeft = chkTattooLocationLeft.Checked
                        TattooLocationRight = chkTattooLocationRight.Checked
                        TattooLocationBottom = chkTattooLocationBottom.Checked

                        If Tattoo_Marking_ComboBox.SelectedIndex > 0 Then
                            'TattooMarkedWith = Tattoo_Marking_ComboBox.SelectedValue
                            If Tattoo_Marking_ComboBox.Text <> "" AndAlso Tattoo_Marking_ComboBox.SelectedValue = -99 Then
                                Dim da As New DataAccess
                                Dim newId = da.InsertListItem("Abno marking", Tattoo_Marking_ComboBox.Text)
                                If newId > 0 Then TattooMarkedWith = newId
                            Else
                                TattooMarkedWith = Tattoo_Marking_ComboBox.SelectedValue
                            End If
                        End If

                        If Not String.IsNullOrWhiteSpace(TattooedQtyNumericTextBox.Text) Then
                            TattooedQty = TattooedQtyNumericTextBox.Text
                        End If

                        If Not String.IsNullOrWhiteSpace(TattooedByRadioButtonList.SelectedValue) Then
                            TattooedBy = TattooedByRadioButtonList.SelectedValue
                        End If

                    Case 2
                        Tattooed = False
                        PreviouslyTattooed = True
                End Select
            End If
        End If

        Try
            AbnormalitiesColonDataAdapter.SaveLesions(
                siteId,
                NoneCheckBox.Checked,
                Sessile_CheckBox.Checked,
                SessileQtyNumericTextBox.Value,
                            PedunculatedPolyps_CheckBox.Checked,
                PedunculatedPolypsQtyNumericTextBox.Value,
                PseudoPolyps_CheckBox.Checked,
                PseudoPolypsQtyNumericTextBox.Value,
                sitePolypDetails,
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
                FundicGlandPolyp_CheckBox.Checked,
                FundicGlandPolypQtyNumericTextBox.Value,
                FundicGlandPolypLargestNumericTextBox.Value,
                Dysplastic_CheckBox.Checked,
                DysplasticQtyNumericTextBox.Value,
                DysplasticLargestNumericTextBox.Value,
                Pneumatosis_CheckBox.Checked,
                Tattooed,
                PreviouslyTattooed,
                TattooMarkedWith,
                TattooedQty,
                TattooLocationTop,
                TattooLocationLeft,
                TattooLocationRight,
                TattooLocationBottom,
                TattooedBy)

            If saveAndClose Then
                SetControlProperties()

                'Utilities.SetNotificationStyle(RadNotification1)
                'RadNotification1.Show()
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Colon Abnormalities - Lesions.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
    'clean viewstates on load
    Private Property vSessileParisClassification As Integer
        Get
            Return ViewState("vSessileParisClassification")
        End Get
        Set(value As Integer)
            ViewState("vSessileParisClassification") = value
        End Set
    End Property
    Private Property vPedunculatedParisClassification As Integer
        Get
            Return ViewState("vPedunculatedParisClassification")
        End Get
        Set(value As Integer)
            ViewState("vPedunculatedParisClassification") = value
        End Set
    End Property
    Private Property vSessilePitPattern As Integer
        Get
            Return ViewState("vSessilePitPattern")
        End Get
        Set(value As Integer)
            ViewState("vSessilePitPattern") = value
        End Set
    End Property
    Private Property vPedunculatedPitPattern As Integer
        Get
            Return ViewState("vPedunculatedPitPattern")
        End Get
        Set(value As Integer)
            ViewState("vPedunculatedPitPattern") = value
        End Set
    End Property
    Private Function GetSessileParisClassificationValue() As Integer
        If SessileLSRadioButton.Checked Then
            Return 1
        ElseIf SessileLLARadioButton.Checked Then
            Return 2
        ElseIf SessileLLALLCRadioButton.Checked Then
            Return 3
        ElseIf SessileLLBRadioButton.Checked Then
            Return 4
        ElseIf SessileLLCRadioButton.Checked Then
            Return 5
        ElseIf SessileLLCLLARadioButton.Checked Then
            Return 6
        End If
        Return 0
    End Function

    Private Sub SetSessileParisClassificationValue(ByVal value As Integer)
        If value = 1 Then
            SessileLSRadioButton.Checked = True
        ElseIf value = 2 Then
            SessileLLARadioButton.Checked = True
        ElseIf value = 3 Then
            SessileLLALLCRadioButton.Checked = True
        ElseIf value = 4 Then
            SessileLLBRadioButton.Checked = True
        ElseIf value = 5 Then
            SessileLLCRadioButton.Checked = True
        ElseIf value = 6 Then
            SessileLLCLLARadioButton.Checked = True
        End If
    End Sub

    Private Function GetPedunculatedParisClassificationValue() As Integer
        If ProtrudedRadioButton.Checked Then
            Return 1
        ElseIf PedunculatedRadioButton.Checked Then
            Return 2
        Else
            Return 0
        End If
    End Function

    Private Sub SetPedunculatedParisClassificationValue(ByVal value As Integer)
        If value = 1 Then
            ProtrudedRadioButton.Checked = True
        ElseIf value = 2 Then
            PedunculatedRadioButton.Checked = True
        End If
    End Sub

    Private Function GetSessilePitPatternValue() As Integer
        If SessileNormalRoundPitsRadioButton.Checked Then
            Return 1
        ElseIf SessileStellarRadioButton.Checked Then
            Return 2
        ElseIf SessileTubularRoundPitsRadioButton.Checked Then
            Return 3
        ElseIf SessileTubularRadioButton.Checked Then
            Return 4
        ElseIf SessileSulcusRadioButton.Checked Then
            Return 5
        ElseIf SessileLossRadioButton.Checked Then
            Return 6
        End If
        Return 0
    End Function

    Private Sub SetSessilePitPatternValue(ByVal value As Integer)
        If value = 1 Then
            SessileNormalRoundPitsRadioButton.Checked = True
        ElseIf value = 2 Then
            SessileStellarRadioButton.Checked = True
        ElseIf value = 3 Then
            SessileTubularRoundPitsRadioButton.Checked = True
        ElseIf value = 4 Then
            SessileTubularRadioButton.Checked = True
        ElseIf value = 5 Then
            SessileSulcusRadioButton.Checked = True
        ElseIf value = 6 Then
            SessileLossRadioButton.Checked = True
        End If
    End Sub

    Private Function GetPedunculatedPitPatternValue() As Integer
        If PedunculatedNormalRoundPitsRadioButton.Checked Then
            Return 1
        ElseIf PedunculatedStellarRadioButton.Checked Then
            Return 2
        ElseIf PedunculatedTubularRoundPitsRadioButton.Checked Then
            Return 3
        ElseIf PedunculatedTubularRadioButton.Checked Then
            Return 4
        ElseIf PedunculatedSulcusRadioButton.Checked Then
            Return 5
        ElseIf PedunculatedLossRadioButton.Checked Then
            Return 6
        End If
        Return 0
    End Function

    Private Sub SetPedunculatedPitPatternValue(ByVal value As Integer)
        If value = 1 Then
            PedunculatedNormalRoundPitsRadioButton.Checked = True
        ElseIf value = 2 Then
            PedunculatedStellarRadioButton.Checked = True
        ElseIf value = 3 Then
            PedunculatedTubularRoundPitsRadioButton.Checked = True
        ElseIf value = 4 Then
            PedunculatedTubularRadioButton.Checked = True
        ElseIf value = 5 Then
            PedunculatedSulcusRadioButton.Checked = True
        ElseIf value = 6 Then
            PedunculatedLossRadioButton.Checked = True
        End If
    End Sub

    Protected Sub GetValues(sender As Object, e As EventArgs)
        Dim cmdName As String = DirectCast(sender, RadButton).ID
        Select Case cmdName
            Case "PedunculatedPitPatternsRadButton"
                vPedunculatedPitPattern = GetPedunculatedPitPatternValue()
            Case "SessilePitPatternsRadButton"
                vSessilePitPattern = GetSessilePitPatternValue()
            Case "PedunculatedParisClassificationRadButton"
                vPedunculatedParisClassification = GetPedunculatedParisClassificationValue()
            Case "SessileParisClassificationRadButton"
                vSessileParisClassification = GetSessileParisClassificationValue()
        End Select
        SetIconClass()
    End Sub
    Protected Sub WinUnload(sender As Object, e As EventArgs)
        Dim cmdName As String = DirectCast(sender, RadWindow).ID
        Select Case cmdName
            Case "PedunculatedPitPatternsPopup"
                SetPedunculatedPitPatternValue(CInt(vPedunculatedPitPattern))
            Case "SessilePitPatternsPopup"
                SetSessilePitPatternValue(CInt(vSessilePitPattern))
            Case "PedunculatedParisClassificationPopUp"
                SetPedunculatedParisClassificationValue(CInt(vPedunculatedParisClassification))
            Case "SessileParisClassificationPopup"
                SetSessileParisClassificationValue(CInt(vSessileParisClassification))
        End Select
    End Sub
    Protected Sub ClearState(sender As Object, e As EventArgs)
        Dim wName As String = DirectCast(sender, RadButton).ID
        Select Case wName
            Case "PedunculatedPolyps_CheckBox"
                vSessileParisClassification = 0
                vSessilePitPattern = 0
            Case "Sessile_CheckBox"
                vPedunculatedParisClassification = 0
                vPedunculatedPitPattern = 0
        End Select
    End Sub
    Protected Sub ShowRadWindow(sender As Object, e As EventArgs)
        Dim wName As String = DirectCast(sender, RadButton).ID
        Dim script As String = ""
        Select Case wName
            Case "SessileParisShowButton"
                SetSessileParisClassificationValue(CInt(vSessileParisClassification))
                script = "function f(){$find(""" + SessileParisClassificationPopup.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
            Case "SessilePitShowButton"
                SetSessilePitPatternValue(CInt(vSessilePitPattern))
                script = "function f(){$find(""" + SessilePitPatternsPopup.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
            Case "PedunculatedParisShowButton"
                SetPedunculatedParisClassificationValue(CInt(vPedunculatedParisClassification))
                script = "function f(){$find(""" + PedunculatedParisClassificationPopUp.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
            Case "PedunculatedPitShowButton"
                SetPedunculatedPitPatternValue(CInt(vPedunculatedPitPattern))
                script = "function f(){$find(""" + PedunculatedPitPatternsPopup.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        End Select

        If script <> "" Then ScriptManager.RegisterStartupScript(Page, Page.GetType(), "key0", script, True)
    End Sub
End Class
