Imports DevExpress.XtraPrinting
Imports Telerik.Web.UI

Partial Class Products_Gastro_Specimens_OGDSpecimensTaken
    Inherits SiteDetailsBase

    Public Shared siteId As Integer
    Private isClosing As Boolean = False


    Public ReadOnly Property regionName() As String
        Get
            Return Request.QueryString("Area")
        End Get
    End Property

    Public ReadOnly Property areaNo() As String
        Get
            If Request.QueryString("AreaNo") = "undefined" Then
                Return 0
            Else
                Return Request.QueryString("AreaNo")
            End If
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not IsPostBack Then
            OGDSpecimensFormView.DefaultMode = FormViewMode.Edit
            OGDSpecimensFormView.ChangeMode(FormViewMode.Edit)
            'BiopsyTR_Visibility(False) 
            'OGDSpecimensFormView.FindControl("BiopsyDistanceDiv").Visible = False         '### If gProcSubSet = OESOPHAGUS Then 

        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(False)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        If e.Argument = "biopsy_save" Then

            Dim HistologyQtyNumericTextBox = DirectCast(OGDSpecimensFormView.FindControl("HistologyQtyNumericTextBox"), RadNumericTextBox)
            Dim dt = DataAdapter.LoadSitesBiopsies(siteId)
            Dim totalQty As Integer = 0
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                totalQty = dt.AsEnumerable.Sum(Function(x) x("Qty"))
            End If
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "populate-qty", "populateBXQty(" & totalQty & ");", True)
        Else
            SaveRecord(False)
        End If
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        'SaveData(siteId)
        isClosing = saveAndClose
        If OGDSpecimensFormView.CurrentMode = FormViewMode.Edit Then
            OGDSpecimensFormView.UpdateItem(True)
        ElseIf OGDSpecimensFormView.CurrentMode = FormViewMode.Insert Then
            OGDSpecimensFormView.InsertItem(True)
        End If
    End Sub

    Private Sub DisplayControls()
        If CInt(areaNo) > 0 Then
            Dim BiopsiesTakenAtRandomCheckBox = DirectCast(OGDSpecimensFormView.FindControl("BiopsiesTakenAtRandomCheckBox"), CheckBox)
            If BiopsiesTakenAtRandomCheckBox IsNot Nothing Then BiopsiesTakenAtRandomCheckBox.Visible = True

            Dim BiopsiesTakenAtSitesCheckBox = DirectCast(OGDSpecimensFormView.FindControl("BiopsiesTakenAtSitesCheckBox"), CheckBox)
            If BiopsiesTakenAtSitesCheckBox IsNot Nothing Then BiopsiesTakenAtSitesCheckBox.Visible = True

            'Dim BiopsyOesophagusTR = DirectCast(OGDSpecimensFormView.FindControl("BiopsyOesophagusTR"), HtmlTableRow)
            'If BiopsyOesophagusTR IsNot Nothing Then BiopsyOesophagusTR.Visible = True
        End If

        SpecimensTR_Visibility({"BiopsyOesophagusTR", "BiopsyTR"}, True)     '### I Keep them Visible in the Design time.. if its invisible in Design time- it will be confusing for the Developers.. need to see all controls in design at least! NOTEs: Don't put it in PagePostBack- it will get called after DataSource_DataBind() and will HIDE!

        Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
            Case ProcedureType.Gastroscopy, ProcedureType.Antegrade, ProcedureType.Bronchoscopy, ProcedureType.EBUS, ProcedureType.EUS_OGD, ProcedureType.Transnasal
                Select Case regionName
                    Case "Oesophagus"
                        SpecimensTR_Visibility({"BiopsyTR", "BrushCytologyTR", "FnaTR", "FnbTR", "HotBiopsyTR", "PolypsTR", "GastricWashingTR"}, True)
                    Case "Stomach"
                        SpecimensTR_Visibility({"BiopsyTR", "BrushCytologyTR", "FnaTR", "FnbTR", "GastricWashingTR", "HotBiopsyTR", "PolypsTR", "UreaseTestTR"}, True)
                    Case "Duodenum", "Small intestine"
                        SpecimensTR_Visibility({"BiopsyTR", "BrushCytologyTR", "FnaTR", "FnbTR", "PolypsTR"}, True)
                    Case "Mediastinal" 'For EUS-OGD only - sites planted outside of the main anatomical diagram
                        SpecimensTR_Visibility({"AmylaseLipaseTR", "BrushBiopsyTR", "CytologyHistologyTR", "FnaTR", "FnbTR", "TumourMarkersTR"}, True)
                    Case Else
                        SpecimensTR_Visibility({"BiopsyTR", "BrushCytologyTR", "FnaTR", "FnbTR", "HotBiopsyTR", "PolypsTR"}, True)
                End Select
            Case ProcedureType.Retrograde, ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy, ProcedureType.Proctoscopy
                SpecimensTR_Visibility({"BiopsyTR", "BrushCytologyTR", "FnaTR", "FnbTR", "HotBiopsyTR", "PolypsTR"}, True)
            Case ProcedureType.ERCP, ProcedureType.EUS_HPB
                'TableRow_Visibility("BiopsyTR", True)

                Select Case regionName
                    Case "Second Part", "First Part", "Medial Wall First Part", "Lateral Wall First Part",
                        "Lateral Wall Second Part", "Medial Wall Second Part", "Third Part", "Lateral Wall Third Part", "Medial Wall Third Part"

                        SpecimensTR_Visibility({"BiopsyTR", "BrushCytologyTR", "FnaTR", "FnbTR"}, True)
                        TableRow_Visibility("BiopsyOesophagusTR", True)  '### If gProcSubSet = OESOPHAGUS Then 

                    Case "Uncinate Process", "Head", "Neck", "Body", "Tail", "Accessory Pancreatic Duct", "Main Pancreatic Duct"
                        SpecimensTR_Visibility({"BileTR", "BiopsyTR", "BrushCytologyTR", "FnaTR", "FnbTR"}, True)

                        Dim Bile_PanJuiceCheckBox = DirectCast(OGDSpecimensFormView.FindControl("Bile_PanJuiceCheckBox"), CheckBox)
                        If Bile_PanJuiceCheckBox IsNot Nothing Then Bile_PanJuiceCheckBox.Text = "Pancreatic juice"

                    Case "Site" 'For EUS-HPB only - sites planted outside of the main anatomical diagram
                        SpecimensTR_Visibility({"AmylaseLipaseTR", "CytologyHistologyTR", "FnaTR", "FnbTR", "TumourMarkersTR"}, True)
                        Dim divFnaLogy = DirectCast(OGDSpecimensFormView.FindControl("divFnaLogy"), HtmlGenericControl)
                        If divFnaLogy IsNot Nothing Then divFnaLogy.Visible = False

                    Case Else
                        '"Right Hepatic Lobe", "Left Hepatic Lobe", "Gall Bladder", "Cystic Duct"
                        ' "Right intra-hepatic ducts", "Left intra-hepatic ducts", "Left Hepatic Ducts", "Right Hepatic Ducts",
                        '   "Bifurcation", "Common Hepatic Duct", "Common Bile Duct", "Major Papilla", "Minor Papilla"
                        SpecimensTR_Visibility({"BileTR", "BiopsyTR", "BrushCytologyTR", "FnaTR", "FnbTR"}, True)

                        Dim Bile_PanJuiceAnalysisCheckBox = DirectCast(OGDSpecimensFormView.FindControl("Bile_PanJuiceAnalysisCheckBox"), CheckBox)
                        If Bile_PanJuiceAnalysisCheckBox IsNot Nothing Then Bile_PanJuiceAnalysisCheckBox.Visible = False

                End Select
            Case Else

        End Select

        'The code below works for JS
        'Page.ClientScript.RegisterStartupScript(Me.GetType(), "ShowTR", "hideTR('" & sArea & "');", True)

    End Sub

    ''' <summary>
    ''' This will be used several times- to show/hide the 'BiopsyTR'
    ''' </summary>
    ''' <param name="showBiopsy">True to Show</param>
    ''' <remarks></remarks>
    Sub TableRow_Visibility(ByVal TR_Name As String, ByVal showBiopsy As Boolean)
        Dim BiopsyTR = DirectCast(OGDSpecimensFormView.FindControl(TR_Name), HtmlTableRow)
        If BiopsyTR IsNot Nothing Then BiopsyTR.Visible = showBiopsy
    End Sub
    Private Sub SpecimensTR_Visibility(arrTR As Array, bVisible As Boolean)
        For Each value As String In arrTR
            Dim thisTR = DirectCast(OGDSpecimensFormView.FindControl(value), HtmlTableRow)
            If thisTR IsNot Nothing Then thisTR.Visible = bVisible
        Next
    End Sub

    Protected Sub OGDSpecimensObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles OGDSpecimensObjectDataSource.Selecting
        e.InputParameters("siteId") = siteId
    End Sub

    Protected Sub OGDSpecimensObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles OGDSpecimensObjectDataSource.Updating
        SetParams(e)
    End Sub

    Protected Sub OGDSpecimensObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles OGDSpecimensObjectDataSource.Inserting
        SetParams(e)
    End Sub

    Private Sub SetParams(e As ObjectDataSourceMethodEventArgs)
        e.InputParameters("siteId") = siteId

        Dim ForcepTypeCheckBox = DirectCast(OGDSpecimensFormView.FindControl("ForcepTypeCheckBox"), CheckBox)
        If ForcepTypeCheckBox IsNot Nothing Then
            If ForcepTypeCheckBox.Checked Then
                e.InputParameters("forcepType") = 1
            Else
                e.InputParameters("forcepType") = 0
            End If
        End If

        Dim UreaseTestRadioButtonList = DirectCast(OGDSpecimensFormView.FindControl("UreaseTestRadioButtonList"), RadioButtonList)
        If UreaseTestRadioButtonList IsNot Nothing Then
            If UreaseTestRadioButtonList.SelectedValue = "" Then
                e.InputParameters("ureaseResult") = Nothing
            Else
                e.InputParameters("ureaseResult") = UreaseTestRadioButtonList.SelectedValue
            End If
        End If

        'Dim SerialNoComboBox = DirectCast(OGDSpecimensFormView.FindControl("SerialNoComboBox"), RadComboBox)
        'If SerialNoComboBox IsNot Nothing Then
        '    If SerialNoComboBox.SelectedValue = "" Then
        '        e.InputParameters("forcepSerialNo") = Nothing
        '    Else
        '        e.InputParameters("forcepSerialNo") = SerialNoComboBox.SelectedValue
        '    End If
        'End If
    End Sub

    Protected Sub OGDSpecimensFormView_DataBound(sender As Object, e As EventArgs) Handles OGDSpecimensFormView.DataBound
        Dim row As DataRowView = DirectCast(OGDSpecimensFormView.DataItem, DataRowView)

        'Dim SerialNoComboBox = DirectCast(OGDSpecimensFormView.FindControl("SerialNoComboBox"), RadComboBox)
        'If Not IsPostBack Then
        '    If SerialNoComboBox IsNot Nothing Then
        '        Utilities.LoadDropdown(SerialNoComboBox, DataAdapter.GetForcepSerialNos(), "ListItemText", "ListItemNo", "")
        '    End If
        'End If
        DisplayControls()
        If row IsNot Nothing Then
            'Dim ForcepsRadioButtonList = DirectCast(OGDSpecimensFormView.FindControl("ForcepsRadioButtonList"), RadioButtonList)
            Dim UreaseTestRadioButtonList = DirectCast(OGDSpecimensFormView.FindControl("UreaseTestRadioButtonList"), RadioButtonList)

            'If Not IsDBNull(row("ForcepType")) AndAlso ForcepsRadioButtonList IsNot Nothing Then
            '    ForcepsRadioButtonList.SelectedValue = CStr(row("ForcepType"))
            'End If
            If Not IsDBNull(row("UreaseResult")) AndAlso UreaseTestRadioButtonList IsNot Nothing Then
                UreaseTestRadioButtonList.SelectedValue = CStr(row("UreaseResult"))
            End If
            'If Not IsDBNull(row("ForcepSerialNo")) Then
            '    If SerialNoComboBox IsNot Nothing Then
            '        SerialNoComboBox.SelectedValue = CStr(row("ForcepSerialNo"))
            '    End If
            'End If
        Else
            OGDSpecimensFormView.DefaultMode = FormViewMode.Insert
            OGDSpecimensFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub

    'Protected Sub OGDSpecimensFormView_ItemCreated(sender As Object, e As EventArgs) Handles OGDSpecimensFormView.ItemCreated
    '    Dim SerialNoComboBox = DirectCast(OGDSpecimensFormView.FindControl("SerialNoComboBox"), RadComboBox)
    '    If SerialNoComboBox IsNot Nothing Then
    '        Utilities.LoadDropdown(SerialNoComboBox, DataAdapter.GetForcepSerialNos(), "List item text", "List item no", Nothing)
    '        'If Not IsDBNull(row("ForcepSerialNo")) Then
    '        '    SerialNoComboBox.SelectedValue = CStr(row("ForcepSerialNo"))
    '        'End If
    '    End If
    'End Sub

    Protected Sub OGDSpecimensFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles OGDSpecimensFormView.ItemInserted
        OGDSpecimensFormView.DefaultMode = FormViewMode.Edit
        OGDSpecimensFormView.ChangeMode(FormViewMode.Edit)
        OGDSpecimensFormView.DataBind()
        ShowMsg()
    End Sub

    Protected Sub OGDSpecimensFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles OGDSpecimensFormView.ItemUpdated
        ShowMsg()
    End Sub

    Private Sub ShowMsg()
        'Utilities.SetNotificationStyle(RadNotification1)
        'RadNotification1.Show()
        If isClosing Then
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
        End If
    End Sub

    'Protected Sub Products_Gastro_Specimens_OGDSpecimensTaken_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
    '    Dim SerialNoComboBox = DirectCast(OGDSpecimensFormView.FindControl("SerialNoComboBox"), RadComboBox)
    '    If SerialNoComboBox IsNot Nothing Then
    '        Utilities.LoadDropdown(SerialNoComboBox, DataAdapter.GetForcepSerialNos(), "List item text", "List item no", Nothing)
    '    End If
    'End Sub

    'Protected Sub OGDSpecimensFormView_Load(sender As Object, e As EventArgs) Handles OGDSpecimensFormView.Load
    '    Dim SerialNoComboBox = DirectCast(OGDSpecimensFormView.FindControl("SerialNoComboBox"), RadComboBox)
    '    If SerialNoComboBox IsNot Nothing Then
    '        Utilities.LoadDropdown(SerialNoComboBox, DataAdapter.GetForcepSerialNos(), "List item text", "List item no", Nothing)
    '        'If Not IsDBNull(row("ForcepSerialNo")) Then
    '        '    SerialNoComboBox.SelectedValue = CStr(row("ForcepSerialNo"))
    '        'End If
    '    End If
    'End Sub

End Class
