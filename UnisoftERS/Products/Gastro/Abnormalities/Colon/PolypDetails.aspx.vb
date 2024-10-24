Imports Telerik.Web.UI

Public Class PolypDetails
    Inherits PageBase

    Public ReadOnly Property polypType As String
        Get
            Return Request.QueryString("type")
        End Get
    End Property

    Public ReadOnly Property siteId As Integer
        Get
            Return Request.QueryString("siteid")
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadData()
        End If
    End Sub

    Private Sub LoadData()
        Dim rowQty = CInt(Request.QueryString("qty"))
        Dim dt As New DataTable
        dt.Columns.Add("PolypId")
        dt.Columns.Add("Size")
        dt.Columns.Add("Excised")
        dt.Columns.Add("Retreived")
        dt.Columns.Add("Successful")
        dt.Columns.Add("Labs")
        dt.Columns.Add("Removal")
        dt.Columns.Add("RemovalMethod")
        dt.Columns.Add("Probably")
        dt.Columns.Add("Type")

        For i As Integer = 0 To rowQty - 1
            Dim polypId = i.ToString & "_" & siteId.ToString
            Dim size = 0
            Dim excised = 0
            Dim retreived = 0
            Dim successful = 0
            Dim labs = 0
            Dim removal = 0
            Dim removalMethod = 0
            Dim probably = False
            Dim type = -1
            Dim inflammatory = False
            Dim postInflammatory = False


            'check for session and load from there if available
            If Session("CommonPolypDetails") IsNot Nothing AndAlso CType(Session("CommonPolypDetails"), List(Of SitePolyps)).Count > 0 Then
                If CType(Session("CommonPolypDetails"), List(Of SitePolyps))(0).PolypType = polypType Then
                    Dim polyps = CType(Session("CommonPolypDetails"), List(Of SitePolyps))
                    If polyps.Count > i Then
                        size = polyps(i).Size
                        excised = polyps(i).Excised
                        retreived = polyps(i).Retrieved
                        successful = polyps(i).Successful
                        labs = polyps(i).SentToLabs
                        removal = polyps(i).Removal
                        removalMethod = polyps(i).RemovalMethod
                        probably = polyps(i).Probably
                        type = polyps(i).TumourType
                        inflammatory = polyps(i).Inflammatory
                        postInflammatory = polyps(i).PostInflammatory

                        Select Case polypType.ToLower
                            Case "sessile"
                                If polyps(i).PitPattern > 0 Then
                                    Dim pitPatterns = New Dictionary(Of String, Integer)
                                    pitPatterns.Add(polypId, polyps(i).PitPattern)
                                    vSessilePitPattern = pitPatterns
                                End If

                                If polyps(i).ParisClassification > 0 Then
                                    Dim parisClass = New Dictionary(Of String, Integer)
                                    parisClass.Add(polypId, polyps(i).ParisClassification)
                                    vSessileParisClassification = parisClass
                                End If
                            Case "pedunculated"
                                If polyps(i).PitPattern > 0 Then
                                    Dim pitPatterns = New Dictionary(Of String, Integer)
                                    pitPatterns.Add(polypId, polyps(i).PitPattern)
                                    vPedunculatedPitPattern = pitPatterns
                                End If
                                If polyps(i).ParisClassification > 0 Then
                                    Dim parisClass = New Dictionary(Of String, Integer)
                                    parisClass.Add(polypId, polyps(i).ParisClassification)
                                    vPedunculatedParisClassification = parisClass
                                End If
                        End Select
                    End If
                End If
            End If

            Dim dr = dt.NewRow()
            dr("polypId") = polypId
            dr("size") = size
            dr("excised") = excised
            dr("retreived") = retreived
            dr("successful") = successful
            dr("labs") = labs
            dr("removal") = removal
            dr("removalMethod") = removalMethod
            dr("probably") = probably
            dr("type") = type
            dt.Rows.Add(dr)


        Next

        PolypDetailsRepeater.DataSource = dt
        PolypDetailsRepeater.DataBind()
    End Sub

    Private Sub InsertComboBoxItem(ctrl As RadComboBox)
        If ctrl.ID.EndsWith("Removal_ComboBox") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("entire", "1"))
            ctrl.Items.Add(New RadComboBoxItem("piecemeal", "2"))

        ElseIf ctrl.ID.EndsWith("Removal_Method_ComboBox") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("partial snare", "1"))
            ctrl.Items.Add(New RadComboBoxItem("cold snare", "2"))
            ctrl.Items.Add(New RadComboBoxItem("hot snare", "3"))
            ctrl.Items.Add(New RadComboBoxItem("hot bx", "4"))
            ctrl.Items.Add(New RadComboBoxItem("cold bx", "5"))
            ctrl.Items.Add(New RadComboBoxItem("hot snare by EMR", "6"))
            ctrl.Items.Add(New RadComboBoxItem("cold snare by EMR", "7"))

        ElseIf ctrl.ID.EndsWith("Type_ComboBox") Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("benign", "1"))
            ctrl.Items.Add(New RadComboBoxItem("malignant", "2"))

        End If

        ctrl.Width = "90"
        ctrl.Style("text-align") = "center"
        'ctrl.Enabled = False
        ctrl.CssClass = "abnor_cb1"
    End Sub

    Protected Sub PolypDetailsRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem Is Nothing Then Exit Sub

        Dim Removal_ComboBox As RadComboBox = e.Item.FindControl("Removal_ComboBox")
        Dim Removal_Method_ComboBox As RadComboBox = e.Item.FindControl("Removal_Method_ComboBox")
        Dim Type_ComboBox As RadComboBox = e.Item.FindControl("Type_ComboBox")
        Dim Probably_Checkbox As CheckBox = e.Item.FindControl("Probably_CheckBox")

        InsertComboBoxItem(Removal_ComboBox)
        InsertComboBoxItem(Removal_Method_ComboBox)
        InsertComboBoxItem(Type_ComboBox)

        Dim dr = DirectCast(e.Item.DataItem, System.Data.DataRowView)
        If CInt(dr("Removal")) > -1 Then Removal_ComboBox.SelectedValue = CInt(dr("Removal"))
        If CInt(dr("RemovalMethod")) > -1 Then Removal_Method_ComboBox.SelectedValue = CInt(dr("RemovalMethod"))
        If CInt(dr("Type")) > -1 Then Type_ComboBox.SelectedValue = CInt(dr("Type"))
        Probably_Checkbox.Checked = CBool(dr("probably"))

        Dim PolypSize As RadNumericTextBox = e.Item.FindControl("PolypSizeNumericTextBox")
        Dim Excised As CheckBox = e.Item.FindControl("ExcisedCheckbox")
        Dim Retreived As CheckBox = e.Item.FindControl("RetrievedCheckbox")
        Dim Successful As CheckBox = e.Item.FindControl("SuccessfulCheckbox")
        Dim Labs As CheckBox = e.Item.FindControl("ToLabsCheckbox")

        If CInt(dr("size")) > 0 Then PolypSize.Value = CInt(dr("size"))
        Excised.Checked = CBool(dr("excised"))
        Retreived.Checked = CBool(dr("retreived"))
        Successful.Checked = CBool(dr("successful"))
        Labs.Checked = CBool(dr("labs"))

        Dim ParisShowButton As RadButton = e.Item.FindControl("ParisShowButton")
        Dim PitShowButton As RadButton = e.Item.FindControl("PitShowButton")

        Dim pseudoPolypTR As HtmlTableRow = e.Item.FindControl("pseudoPolypTR")
        Dim polypTypeDetailsTR As HtmlTableRow = e.Item.FindControl("polypTypeDetails")

        Dim polypId = e.Item.ItemIndex & "_" & siteId

        Select Case polypType.ToLower
            Case "sessile"
                Dim sessileParisValue = 0
                Dim sessilePitPattern = 0

                If vSessileParisClassification IsNot Nothing AndAlso vSessileParisClassification.ContainsKey(polypId) Then
                    sessileParisValue = vSessileParisClassification(polypId)
                End If

                If vSessilePitPattern IsNot Nothing AndAlso vSessilePitPattern.ContainsKey(polypId) Then
                    sessilePitPattern = vSessilePitPattern(polypId)
                End If

                ParisShowButton.Attributes("onclick") = "return showSessileParisPopup('" & polypId & "'," & sessileParisValue & ");"
                PitShowButton.Attributes("onclick") = "return showSessilePitPatternsPopup('" & polypId & "'," & sessilePitPattern & ");"
            Case "pedunculated"
                Dim pedunculatedParisValue = 0
                Dim pedunculatedPitPattern = 0

                If vPedunculatedParisClassification IsNot Nothing AndAlso vPedunculatedParisClassification.ContainsKey(polypId) Then
                    pedunculatedParisValue = vPedunculatedParisClassification(polypId)
                End If

                If vPedunculatedPitPattern IsNot Nothing AndAlso vPedunculatedPitPattern.ContainsKey(polypId) Then
                    pedunculatedPitPattern = vPedunculatedPitPattern(polypId)
                End If

                ParisShowButton.Attributes("onclick") = "return showPedunculatedParisPopup('" & polypId & "'," & pedunculatedParisValue & ");"
                PitShowButton.Attributes("onclick") = "return showPedunculatedPitPatternsPopup('" & polypId & "'," & pedunculatedParisValue & ");"
            Case "pseudo"
                polypTypeDetailsTR.Visible = False
                pseudoPolypTR.Visible = True
        End Select
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs)
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            Dim sitePolypDetails As New List(Of SitePolyps)
            Dim i = 0
            For Each item As RepeaterItem In PolypDetailsRepeater.Items

                Dim polypId = i.ToString & "_" & siteId.ToString
                Dim size = 0
                Dim excised = False
                Dim retreived = False
                Dim successful = False
                Dim labs = False
                Dim removal = 0
                Dim removalMethod = 0
                Dim probably = False
                Dim pitPattern = 0
                Dim parisClassification = 0
                Dim inflammatory = False
                Dim postInflammatory = False

                Dim sp As New SitePolyps
                With sp
                    .PolypType = polypType
                    .PolypId = polypId
                    .Size = CType(item.FindControl("PolypSizeNumericTextBox"), RadNumericTextBox).Value
                    .Excised = CType(item.FindControl("ExcisedCheckbox"), CheckBox).Checked
                    .Retrieved = CType(item.FindControl("RetrievedCheckbox"), CheckBox).Checked
                    .Successful = CType(item.FindControl("SuccessfulCheckbox"), CheckBox).Checked
                    .SentToLabs = CType(item.FindControl("ToLabsCheckbox"), CheckBox).Checked
                    If CType(item.FindControl("Removal_ComboBox"), RadComboBox).SelectedIndex > 0 Then .Removal = CType(item.FindControl("Removal_ComboBox"), RadComboBox).SelectedValue
                    If CType(item.FindControl("Removal_Method_ComboBox"), RadComboBox).SelectedIndex > 0 Then .RemovalMethod = CType(item.FindControl("Removal_Method_ComboBox"), RadComboBox).SelectedValue

                    Select Case polypType.ToLower
                        Case "sessile"
                            .Probably = CType(item.FindControl("Probably_CheckBox"), CheckBox).Checked
                            If CType(item.FindControl("Type_ComboBox"), RadComboBox).SelectedIndex > 0 Then .TumourType = CType(item.FindControl("Type_ComboBox"), RadComboBox).SelectedValue
                            If vSessileParisClassification IsNot Nothing AndAlso vSessileParisClassification.ContainsKey(polypId) Then
                                .ParisClassification = vSessileParisClassification(polypId)
                            End If
                            If vSessilePitPattern IsNot Nothing AndAlso vSessilePitPattern.ContainsKey(polypId) Then
                                .PitPattern = vSessilePitPattern(polypId)
                            End If
                        Case "pedunculated"
                            .Probably = CType(item.FindControl("Probably_CheckBox"), CheckBox).Checked
                            If CType(item.FindControl("Type_ComboBox"), RadComboBox).SelectedIndex > 0 Then .TumourType = CType(item.FindControl("Type_ComboBox"), RadComboBox).SelectedValue
                            If vPedunculatedParisClassification IsNot Nothing AndAlso vPedunculatedParisClassification.ContainsKey(polypId) Then
                                .ParisClassification = vPedunculatedParisClassification(polypId)
                            End If
                            If vPedunculatedPitPattern IsNot Nothing AndAlso vPedunculatedPitPattern.ContainsKey(polypId) Then
                                .PitPattern = vPedunculatedPitPattern(polypId)
                            End If
                        Case "pseudo"
                            .Inflammatory = CType(item.FindControl("InflamCheckBox"), CheckBox).Checked
                            .PostInflammatory = CType(item.FindControl("PostInflamCheckBox"), CheckBox).Checked
                    End Select
                End With

                sitePolypDetails.Add(sp)

                i += 1
            Next

            Session("ColonPolypDetails") = sitePolypDetails
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "CloseMe", "CloseWindow();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving polyp details.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

#Region "Paris/Pit window details"
    Private Property vSessileParisClassification As Dictionary(Of String, Integer)
        Get
            Return ViewState("vSessileParisClassification")
        End Get
        Set(value As Dictionary(Of String, Integer))
            ViewState("vSessileParisClassification") = value
        End Set
    End Property
    Private Property vPedunculatedParisClassification As Dictionary(Of String, Integer)
        Get
            Return ViewState("vPedunculatedParisClassification")
        End Get
        Set(value As Dictionary(Of String, Integer))
            ViewState("vPedunculatedParisClassification") = value
        End Set
    End Property
    Private Property vSessilePitPattern As Dictionary(Of String, Integer)
        Get
            Return ViewState("vSessilePitPattern")
        End Get
        Set(value As Dictionary(Of String, Integer))
            ViewState("vSessilePitPattern") = value
        End Set
    End Property
    Private Property vPedunculatedPitPattern As Dictionary(Of String, Integer)
        Get
            Return ViewState("vPedunculatedPitPattern")
        End Get
        Set(value As Dictionary(Of String, Integer))
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

    Private Function GetPedunculatedParisClassificationValue() As Integer
        If ProtrudedRadioButton.Checked Then
            Return 1
        ElseIf PedunculatedRadioButton.Checked Then
            Return 2
        Else
            Return 0
        End If
    End Function

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

    Protected Sub GetValues(sender As Object, e As EventArgs)
        Dim btn = DirectCast(sender, RadButton)
        Dim cmdName As String = btn.ID
        Dim polypId As String = btn.CommandArgument
        Dim itemIndex As Integer = polypId.Split("_")(0)

        Select Case cmdName
            Case "PedunculatedPitPatternsRadButton"
                Dim pitPatterns = vPedunculatedPitPattern
                If pitPatterns Is Nothing Then pitPatterns = New Dictionary(Of String, Integer)

                If pitPatterns.ContainsKey(polypId) Then pitPatterns.Remove(polypId)
                pitPatterns.Add(polypId, GetPedunculatedPitPatternValue())
                vPedunculatedPitPattern = pitPatterns

                Dim PitShowButton As RadButton = PolypDetailsRepeater.Items(itemIndex).FindControl("PitShowButton")
                PitShowButton.Attributes("onclick") = "return showPedunculatedPitPatternsPopup('" & polypId & "'," & GetPedunculatedPitPatternValue() & ");"
            Case "SessilePitPatternsRadButton"
                Dim pitPatterns = vSessilePitPattern
                If pitPatterns Is Nothing Then pitPatterns = New Dictionary(Of String, Integer)

                If pitPatterns.ContainsKey(polypId) Then pitPatterns.Remove(polypId)
                pitPatterns.Add(polypId, GetSessilePitPatternValue())
                vSessilePitPattern = pitPatterns

                Dim PitShowButton As RadButton = PolypDetailsRepeater.Items(itemIndex).FindControl("PitShowButton")
                PitShowButton.Attributes("onclick") = "return showSessilePitPatternsPopup('" & polypId & "'," & GetSessilePitPatternValue() & ");"
            Case "PedunculatedParisClassificationRadButton"
                Dim parisClass = vPedunculatedParisClassification
                If parisClass Is Nothing Then parisClass = New Dictionary(Of String, Integer)

                If parisClass.ContainsKey(polypId) Then parisClass.Remove(polypId)
                parisClass.Add(polypId, GetPedunculatedParisClassificationValue())
                vPedunculatedParisClassification = parisClass

                Dim ParisShowButton As RadButton = PolypDetailsRepeater.Items(itemIndex).FindControl("ParisShowButton")
                ParisShowButton.Attributes("onclick") = "return showPedunculatedParisPopup('" & polypId & "'," & GetPedunculatedParisClassificationValue() & ");"
            Case "SessileParisClassificationRadButton"
                Dim parisClass = vSessileParisClassification
                If parisClass Is Nothing Then parisClass = New Dictionary(Of String, Integer)

                If parisClass.ContainsKey(polypId) Then parisClass.Remove(polypId)
                parisClass.Add(polypId, GetSessileParisClassificationValue())
                vSessileParisClassification = parisClass
                Dim ParisShowButton As RadButton = PolypDetailsRepeater.Items(itemIndex).FindControl("ParisShowButton")
                ParisShowButton.Attributes("onclick") = "return showSessileParisPopup('" & polypId & "'," & GetSessileParisClassificationValue() & ");"
        End Select
    End Sub
#End Region

End Class