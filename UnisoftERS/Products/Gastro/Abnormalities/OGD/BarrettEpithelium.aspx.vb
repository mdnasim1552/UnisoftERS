Imports Telerik.Web.UI


Partial Class Products_Gastro_Abnormalities_OGDBarrettEpithelium
    Inherits SiteDetailsBase

#Region "Morphology"
    Private Property vParisClassification As Integer
        Get
            Return ViewState("vParisClassification")
        End Get
        Set(value As Integer)
            ViewState("vParisClassification") = value
        End Set
    End Property
    Private Property vPitPattern As Integer
        Get
            Return ViewState("vPitPattern")
        End Get
        Set(value As Integer)
            ViewState("vPitPattern") = value
        End Set
    End Property

    Private Function GetParisClassificationValue() As Integer
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

    Private Sub SetParisClassificationValue(ByVal value As Integer)
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

    Private Function GetPitPatternValue() As Integer
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

    Private Sub SetPitPatternValue(ByVal value As Integer)
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

    Protected Sub GetValues(sender As Object, e As EventArgs)
        Dim cmdName As String = DirectCast(sender, RadButton).ID
        Select Case cmdName
            Case "PitPatternsRadButton"
                vPitPattern = GetPitPatternValue()
            Case "ParisClassificationRadButton"
                vParisClassification = GetParisClassificationValue()
        End Select
        SetIconClass()
    End Sub

    Private Sub SetIconClass()
        If vParisClassification Then
            ParisShowButton.Icon.PrimaryIconCssClass = "rbOk"
        Else
            ParisShowButton.Icon.PrimaryIconCssClass = Nothing
        End If
        If vPitPattern Then
            PitShowButton.Icon.PrimaryIconCssClass = "rbOk"
        Else
            PitShowButton.Icon.PrimaryIconCssClass = Nothing
        End If
    End Sub

    Protected Sub WinUnload(sender As Object, e As EventArgs)
        Dim cmdName As String = DirectCast(sender, RadWindow).ID
        Select Case cmdName
            Case "PitPatternsPopup"
                SetPitPatternValue(CInt(vPitPattern))
            Case "ParisClassificationPopup"
                SetParisClassificationValue(CInt(vParisClassification))
        End Select
    End Sub
    Protected Sub ClearState(sender As Object, e As EventArgs)
        Dim wName As String = DirectCast(sender, RadButton).ID
        vParisClassification = 0
        vPitPattern = 0
    End Sub
    Protected Sub ShowRadWindow(sender As Object, e As EventArgs)
        Dim wName As String = DirectCast(sender, RadButton).ID
        Dim script As String = ""
        Select Case wName
            Case "ParisShowButton"
                SetParisClassificationValue(CInt(vParisClassification))
                script = "function f(){$find(""" + ParisClassificationPopup.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
            Case "PitShowButton"
                SetPitPatternValue(CInt(vPitPattern))
                script = "function f(){$find(""" + PitPatternsPopup.ClientID + """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        End Select

        If script <> "" Then ScriptManager.RegisterStartupScript(Page, Page.GetType(), "key0", script, True)
    End Sub
#End Region
    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        If Not IsPostBack Then
            FocalTumourTypesRadioButtonList.DataSource = DataAdapter.LoadTumourTypes()
            FocalTumourTypesRadioButtonList.DataBind()

            ParisShowButton.Attributes("onclick") = "return showParisPopup(" & vParisClassification & ");"
            PitShowButton.Attributes("onclick") = "return showPitPatternsPopup(" & vPitPattern & ");"

            Dim dtBE As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_barrett_select")
            If dtBE.Rows.Count > 0 Then
                PopulateData(dtBE.Rows(0))
                SetIconClass()
            End If
        End If
    End Sub

    Private Sub PopulateData(dtBE As DataRow)
        NoneCheckBox.Checked = CBool(dtBE("None"))
        If Not CBool(dtBE("None")) Then
            If Not IsDBNull(dtBE("BarrettIslands")) Then BarrettIslands_CheckBox.Checked = CDbl(dtBE("BarrettIslands"))
            If Not IsDBNull(dtBE("Proximal")) Then ProximalNumericTextBox.Value = CInt(dtBE("Proximal"))
            If Not IsDBNull(dtBE("Distal")) Then DistalNumericTextBox.Value = CInt(dtBE("Distal"))
            If Not IsDBNull(dtBE("DistanceC1")) Then D1RadNumericTextBox.Value = CInt(dtBE("DistanceC1"))
            If Not IsDBNull(dtBE("DistanceC2")) Then D2RadNumericTextBox.Value = CInt(dtBE("DistanceC2"))
            If Not IsDBNull(dtBE("DistanceC3")) Then D3RadNumericTextBox.Value = CInt(dtBE("DistanceC3"))
            If Not IsDBNull(dtBE("DistanceM1")) Then C1RadNumericTextBox.Value = CDbl(dtBE("DistanceM1"))
            If Not IsDBNull(dtBE("DistanceM2")) Then C2RadNumericTextBox.Value = CDbl(dtBE("DistanceM2"))
            If Not IsDBNull(dtBE("InspectionTimeMins")) Then InspectionTimeMinsRadNumericTextBox.Value = CInt(dtBE("InspectionTimeMins"))
            If Not IsDBNull(dtBE("FocalLesions")) Then
                Focal_CheckBox.Checked = CBool(dtBE("FocalLesions"))
                If Focal_CheckBox.Checked Then
                    If Not IsDBNull(dtBE("FocalLesionQty")) Then FocalQtyNumericTextBox.Value = CInt(dtBE("FocalLesionQty"))
                    If Not IsDBNull(dtBE("FocalLesionLargest")) Then FocalLargestNumericTextBox.Value = CInt(dtBE("FocalLesionLargest"))
                    If Not IsDBNull(dtBE("FocalLesionTumourTypeId")) Then FocalTumourTypesRadioButtonList.SelectedValue = CInt(dtBE("FocalLesionTumourTypeId"))
                    If Not IsDBNull(dtBE("FocalLesionProbably")) Then FocalProbablyCheckBox.Checked = CBool(dtBE("FocalLesionProbably"))
                    If Not IsDBNull(dtBE("FocalLesionParisClassificationId")) Then vParisClassification = CInt(dtBE("FocalLesionParisClassificationId"))
                    If Not IsDBNull(dtBE("FocalLesionPitPatternId")) Then vPitPattern = CInt(dtBE("FocalLesionPitPatternId"))
                End If
            End If
            'added by mostafiz 2360
            If Not IsDBNull(dtBE("SmokerRadioButtonListId")) Then SmokerRadioButtonList.SelectedValue = CInt(dtBE("SmokerRadioButtonListId"))
            'added by mostafiz 2360
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
            'check if focal lesions checked and if so that paris classification is chosen
            If Focal_CheckBox.Checked And (vParisClassification = Nothing OrElse vParisClassification = 0) Then
                'display error message and exit sub (sorry Duncan)
                Utilities.SetNotificationStyle(RadNotification1, "Paris classification required for focal lesions", True, "Please correct")
                RadNotification1.Show()
                Exit Sub
            End If

            AbnormalitiesDataAdapter.SaveBarrettEpitheliumData(
                siteId,
                NoneCheckBox.Checked,
                BarrettIslands_CheckBox.Checked,
                If(ProximalNumericTextBox.Value, 0),
                If(DistalNumericTextBox.Value, 0),
                If(D1RadNumericTextBox.Value, 0),
                If(D2RadNumericTextBox.Value, 0),
                If(D3RadNumericTextBox.Value, 0),
                C1RadNumericTextBox.Text,
                C2RadNumericTextBox.Text,
                Focal_CheckBox.Checked,
                If(FocalQtyNumericTextBox.Value, 0),
                If(FocalLargestNumericTextBox.Value, 0),
                If(String.IsNullOrWhiteSpace(FocalTumourTypesRadioButtonList.SelectedValue), 0, FocalTumourTypesRadioButtonList.SelectedValue),
                FocalProbablyCheckBox.Checked,
                vParisClassification,
                vPitPattern,
                InspectionTimeMinsRadNumericTextBox.Text,
                If(String.IsNullOrWhiteSpace(SmokerRadioButtonList.SelectedValue), 0, SmokerRadioButtonList.SelectedValue) 'added by mostafiz 2360
                )
            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Barrett's Epithelium.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
