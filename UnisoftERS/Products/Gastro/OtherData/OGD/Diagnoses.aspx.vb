Imports Telerik.Web.UI

Partial Class Products_Gastro_OtherData_OGD_Diagnoses
    Inherits PageBase
    Protected Shared procTypeID As Integer

    Private Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        If Not Page.IsPostBack Then
            ' SaveButton.Text = IIf(Session("AdvancedMode") = True, "Save Record", "Save & Close")
            procTypeID = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            'Utilities.LoadDropdown(ExtentDropdownlist, DataAdapter.GetDropDownList("Diagnoses Colon Extent"), "ListItemText", "ListItemNo", Nothing)
            'Utilities.LoadDropdown(GradingDropDownList, DataAdapter.GetDropDownList("Diagnoses Colon Grading"), "ListItemText", "ListItemNo", Nothing)

            'Utilities.LoadDropdown(BiliaryLeakSiteRadComboBox, DataAdapter.GetDropDownList("Intrahepatic biliary leak site"), "ListItemText", "ListItemNo", Nothing)
            'Utilities.LoadDropdown(ExtrahepaticLeakSiteRadComboBox, DataAdapter.GetDropDownList("Extrahepatic biliary leak site"), "ListItemText", "ListItemNo", Nothing)
            'Utilities.LoadDropdown(WholeOtherRadComboBox, DataAdapter.GetDropDownList("ERCP other diagnoses"), "ListItemText", "ListItemNo", Nothing)

            'Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
            '            {ExtentDropdownlist, "Diagnoses Colon Extent"},
            '            {BiliaryLeakSiteRadComboBox, "Intrahepatic biliary leak site"},
            '            {ExtrahepaticLeakSiteRadComboBox, "Extrahepatic biliary leak site"},
            '            {WholeOtherRadComboBox, "ERCP other diagnoses"},
            '            {SESDropDownList, "Simple Endoscopic Score – Crohn''s Disease"},
            '            {MayoScoreDropDownList, "Mayo Score"}
            '    })

            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                        {BiliaryLeakSiteRadComboBox, "Intrahepatic biliary leak site"},
                        {ExtrahepaticLeakSiteRadComboBox, "Extrahepatic biliary leak site"},
                        {WholeOtherRadComboBox, "ERCP other diagnoses"}
                })

            PopulateData()
        End If
    End Sub

    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, RadTabStrip1, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, RadNotification1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(CancelButton, RadTabStrip1, RadAjaxLoadingPanel1)
    End Sub

    Private Sub PopulateData()
        Dim iProcID As Integer = CInt(Session(Constants.SESSION_PROCEDURE_ID))
        Dim sPP_Diagnoses As String = ""
        Dim da As New OtherData
        'Dim dt As DataRow = da.GetAbnoDiagnoses(iProcID).Rows(0)
        Try
            'If procTypeID = ProcedureType.Gastroscopy AndAlso not DataAdapter.IsNormalProcedure(iProcID)  Then 'toggle page title based on normal procedure result
            If DataAdapter.IsNormalProcedure(iProcID) Then
                OverallNormalCheckBox.Checked = True
            End If
            sPP_Diagnoses = da.GetAbnoDiagnoses(iProcID) 'CStr(dt("PP_Diagnoses")).Trim

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading Upper GI Diagnoses.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading data.")
            RadNotification1.Show()
        End Try

        If procTypeID = ProcedureType.Colonoscopy Or procTypeID = ProcedureType.Sigmoidscopy Or procTypeID = ProcedureType.Proctoscopy Then
            PopulateColonData(sPP_Diagnoses, da, iProcID)
        ElseIf procTypeID = ProcedureType.Gastroscopy Or procTypeID = ProcedureType.EUS_OGD Or procTypeID = ProcedureType.Transnasal Then
            PopulateGastroData(sPP_Diagnoses, da, iProcID)
        ElseIf procTypeID = ProcedureType.ERCP Or procTypeID = ProcedureType.EUS_HPB Then
            RadTabStrip1.Attributes.Add("style", "display:none;")
            PopulateERCPData(sPP_Diagnoses, da, iProcID)
        End If
    End Sub

    Private Sub PopulateColonData(sPP_Diagnoses As String, da As OtherData, iProcID As Integer)

        If sPP_Diagnoses <> "" Then
            Dim sText As String = ""
            Dim delim As String() = New String(0) {"<br/>"}
            Dim sDiag As String() = sPP_Diagnoses.Split(delim, StringSplitOptions.None)
            For Each Diag In sDiag
                If Diag.Contains("examination to the point of insertion was normal") Then
                    sText = sText & Diag.Replace(Diag, "")
                Else
                    sText = sText & Diag
                End If
            Next
            If sText <> "" Then
                divAbnoDiagnosesCol.Visible = True
                divAbnoDiagnosesCol.InnerHtml = sText
                'hide ColonNormalCheckBox and show ColonRestNormalCheckBox ??
            End If
        End If

        RadTabStrip1.FindTabByValue("3").Selected = True
        If procTypeID = ProcedureType.Sigmoidscopy Then RadTabStrip1.FindTabByValue("3").Text = "Sigmoidoscopy"
        'RadTabStrip1.FindTabByValue("3").Visible = True
        RadPageView3.Selected = True
        'RadTabStrip1.FindTabByValue("4").Visible = True

        Dim oDataSource As New ObjectDataSource
        oDataSource = DiagnosesObjectDataSource()
        oDataSource.SelectParameters("Section").DefaultValue = "Colon"
        oDataSource.SelectParameters("ProcedureTypeID").DefaultValue = procTypeID
        ColonDataList.DataSource = oDataSource
        ColonDataList.DataBind()

        'Dim sDataSource As New ObjectDataSource
        'sDataSource = DiagnosesObjectDataSource()
        'sDataSource.SelectParameters("Section").DefaultValue = "Colitis"
        'sDataSource.SelectParameters("ProcedureTypeID").DefaultValue = procTypeID
        'ColitisDataList.DataSource = sDataSource
        'ColitisDataList.DataBind()

        'DiagnosesObjectDataSource.SelectParameters("ProcedureTypeID").DefaultValue = procTypeID
        'DiagnosesObjectDataSource.SelectParameters("Section").DefaultValue = ""
        'ColonDataList.DataSourceID = "DiagnosesObjectDataSource"
        'ColonDataList.DataBind()

        'Dim drDg As DataTable = da.GetDiagnosesData(iProcID)
        'If drDg.Rows.Count > 0 Then
        'For Each olist As DataListItem In ColonDataList.Items
        '    Dim ock As HtmlInputCheckBox = DirectCast(olist.FindControl("coloID"), HtmlInputCheckBox)
        '    If Not IsNothing(ock) Then
        '        Dim b As Object = (drDg.Select("MatrixCode='" & ock.Value & "'").FirstOrDefault)
        '        If Not IsDBNull(b) AndAlso Not IsNothing(b) Then ock.Checked = CBool(b.Item("Value"))
        '    End If
        'Next
        'For Each sList As DataListItem In ColitisDataList.Items
        '    Dim sck As HtmlInputRadioButton = DirectCast(sList.FindControl("colitisID"), HtmlInputRadioButton)
        '    If Not IsNothing(sck) Then
        '        Dim b As Object = (drDg.Select("Value='" & sck.Value & "'").FirstOrDefault)
        '        If Not IsDBNull(b) AndAlso Not IsNothing(b) Then
        '            sck.Checked = True 'CBool(b.Item("Value"))
        '            If CType(sList.FindControl("colitisIDLabel"), Label).Text.ToLower() = "ulcerative colitis" Then
        '                mayoscorediv.Style("display") = "normal"
        '            ElseIf CType(sList.FindControl("colitisIDLabel"), Label).Text.ToLower() = "crohn's disease" Then
        '                chronsdiseasescorediv.Style("display") = "normal"
        '            End If
        '        End If
        '        'sck.Attributes.Add("onclick", "resetName('" + sck.ClientID + "','grpColitis')")
        '    End If

        'Next

        'Dim toShowRestNormal As Boolean = False
        'For Each listCtrl As Control In ColonDataList.Controls
        '    Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
        '    If item.ItemType = ListItemType.Header Then
        '        Dim a1Value As DataRow = drDg.Select("MatrixCode='ColonNormal'").FirstOrDefault
        '        Dim a3Value As DataRow = drDg.Select("MatrixCode='ColonRestNormal'").FirstOrDefault
        '        If Not IsNothing(a1Value) Then
        '            DirectCast(item.FindControl("ColonNormalCheckBox"), HtmlInputCheckBox).Checked = CBool(a1Value.Item("Value"))
        '            toShowRestNormal = CBool(a1Value.Item("Value"))
        '        End If
        '        If Not IsNothing(a3Value) Then
        '            DirectCast(item.FindControl("ColonRestNormalCheckBox"), HtmlInputCheckBox).Checked = CBool(a3Value.Item("Value"))
        '            If toShowRestNormal Then
        '                DirectCast(item.FindControl("normid"), HtmlTableRow).Attributes.Add("Style", "display:none")
        '            Else
        '                DirectCast(item.FindControl("normid"), HtmlTableRow).Attributes.Add("Style", "display:normal")
        '            End If
        '        End If
        '    End If
        '    If item.ItemType = ListItemType.Footer Then
        '        Dim a2Value As DataRow = drDg.Select("MatrixCode='ColonOtherDiagnosis'").FirstOrDefault
        '        If Not IsNothing(a2Value) Then ColonOtherDiagnosisTextBox.Text = CStr(a2Value.Item("Value"))
        '    End If
        'Next
        'Dim a9Value As DataRow = drDg.Select("MatrixCode='ColitisType'").FirstOrDefault
        'If Not IsNothing(a9Value) Then
        '    Dim ColitisType As String = CStr(a9Value.Item("Value"))
        '    Dim cNoneSpecified() As String = {"D85P3", "S85P3", "P85P3"} 'None specified

        '    If Right(ColitisType, 2) = "P3" And Not cNoneSpecified.Contains(ColitisType) Then
        '        raddiv.Attributes.Add("Style", "display:normal")
        '    Else
        '        raddiv.Attributes.Add("Style", "display:none")
        '    End If
        'End If

        'Dim a5Value As DataRow = drDg.Select("MatrixCode='Ileitis'").FirstOrDefault
        'Dim a6Value As DataRow = drDg.Select("MatrixCode='Colitis'").FirstOrDefault
        'Dim a11Value As DataRow = drDg.Select("MatrixCode='Proctitis'").FirstOrDefault
        'Dim a7Value As DataRow = drDg.Select("MatrixCode='ColitisExtent'").FirstOrDefault
        'Dim a8Value As DataRow = drDg.Select("MatrixCode='MayoScore'").FirstOrDefault
        'Dim a10Value As DataRow = drDg.Select("MatrixCode='SEScore'").FirstOrDefault

        'If Not IsNothing(a6Value) Then
        '    If CBool(a6Value.Item("Value")) Then colitisdiv.Attributes.Add("Style", "display:normal") '  cooldiv.Attributes.Add("Style", "display:normal;overflow:auto")
        '    ColitisCheckBox.Checked = CBool(a6Value.Item("Value"))
        'End If
        'If Not IsNothing(a5Value) Then
        '    If CBool(a5Value.Item("Value")) Then colitisdiv.Attributes.Add("Style", "display:normal") '  cooldiv.Attributes.Add("Style", "display:normal;overflow:auto")
        '    IleitisCheckBox.Checked = CBool(a5Value.Item("Value"))
        'End If
        'If Not IsNothing(a11Value) Then
        '    ProctitisCheckBox.Checked = CBool(a11Value.Item("Value"))
        'End If
        'If Not IsNothing(a7Value) Then ExtentDropdownlist.SelectedValue = CStr(a7Value.Item("Value"))
        'If Not IsNothing(a8Value) Then
        '    MayoScoreDropDownList.SelectedValue = CStr(a8Value.Item("Value"))
        'End If
        'If Not IsNothing(a10Value) Then
        '    SESDropDownList.SelectedValue = CStr(a10Value.Item("Value"))
        'End If
        'End If
    End Sub

    Private Sub PopulateGastroData(sPP_Diagnoses As String, da As OtherData, iProcID As Integer)
        If sPP_Diagnoses <> "" Then
            Dim delim As String() = New String(0) {"<b>"}
            Dim sDiag As String() = sPP_Diagnoses.Split(delim, StringSplitOptions.None)
            For Each Diag In sDiag
                If Diag.Contains("Duodenum: </b>") And (Not Diag.ToLower.Contains("</b>normal") And Not Diag.ToLower.Contains("not entered")) Then
                    Diag = Diag.Replace("Duodenum: </b>", "")
                    If Not chkAbnoDiagnoses(Diag) Then
                        divAbnoDiagnosesDuodenum.Visible = True
                        divAbnoDiagnosesDuodenum.InnerHtml = Left(Diag, 1).ToUpper & Diag.Substring(1)
                    End If
                End If
                If Diag.Contains("Stomach: </b>") And (Not Diag.ToLower.Contains("</b>normal") And Not Diag.ToLower.Contains("not entered")) Then
                    Diag = Diag.Replace("Stomach: </b>", "")
                    If Not chkAbnoDiagnoses(Diag) Then
                        divAbnoDiagnosesStomach.Visible = True
                        divAbnoDiagnosesStomach.InnerHtml = Left(Diag, 1).ToUpper & Diag.Substring(1)
                    End If
                End If
                If Diag.Contains("Oesophagus: </b>") And (Not Diag.ToLower.Contains("</b>normal") And Not Diag.ToLower.Contains("not entered")) Then
                    Diag = Diag.Replace("Oesophagus: </b>", "")
                    If Not chkAbnoDiagnoses(Diag) Then
                        divAbnoDiagnosesOeso.Visible = True
                        divAbnoDiagnosesOeso.InnerHtml = Left(Diag, 1).ToUpper & Diag.Substring(1)
                    End If
                End If
            Next
        End If

        'RadTabStrip1.FindTabByText("Oesophagus").Selected = True
        'RadTabStrip1.FindTabByText("Oesophagus").Visible = True
        'RadPageView0.Selected = True
        'RadTabStrip1.FindTabByText("Stomach").Visible = True
        'RadTabStrip1.FindTabByText("Duodenum").Visible = True

        Dim oDataSource As New ObjectDataSource
        oDataSource = DiagnosesObjectDataSource()
        oDataSource.SelectParameters("Section").DefaultValue = "Oesophagus"
        oDataSource.SelectParameters("ProcedureTypeID").DefaultValue = procTypeID
        oesodatalist.DataSource = oDataSource
        oesodatalist.DataBind()

        Dim sDataSource As New ObjectDataSource
        sDataSource = DiagnosesObjectDataSource()
        sDataSource.SelectParameters("Section").DefaultValue = "Stomach"
        sDataSource.SelectParameters("ProcedureTypeID").DefaultValue = procTypeID
        StomachDataList.DataSource = sDataSource
        StomachDataList.DataBind()

        Dim dDataSource As New ObjectDataSource
        dDataSource = DiagnosesObjectDataSource()
        dDataSource.SelectParameters("Section").DefaultValue = "Duodenum"
        dDataSource.SelectParameters("ProcedureTypeID").DefaultValue = procTypeID
        DuodenumDataList.DataSource = dDataSource
        DuodenumDataList.DataBind()

        OverallNormalCheckBox.Visible = True
        Dim drDg As DataTable = da.GetDiagnosesData(iProcID)
        Dim a0Value As DataRow = drDg.Select("MatrixCode='OverallNormal'").FirstOrDefault
        If Not IsNothing(a0Value) Then OverallNormalCheckBox.Checked = CBool(a0Value.Item("Value"))

        If drDg.Rows.Count > 0 Then
            For Each olist As DataListItem In oesodatalist.Items
                Dim ock As HtmlInputCheckBox = DirectCast(olist.FindControl("oesoID"), HtmlInputCheckBox)
                Dim lbl As Label = DirectCast(olist.FindControl("oesoIDlbl"), Label)
                If Not IsNothing(ock) Then
                    Dim b As Object = (drDg.Select("MatrixCode='" & ock.Value & "'").FirstOrDefault)
                    If Not IsDBNull(b) AndAlso Not IsNothing(b) Then
                        ock.Checked = CBool(b.Item("Value"))
                        ock.Style.Add("display", "none")
                        lbl.Style.Add("display", "none")
                    End If

                End If
            Next
            For Each sList As DataListItem In StomachDataList.Items
                Dim sck As HtmlInputCheckBox = DirectCast(sList.FindControl("stoID"), HtmlInputCheckBox)
                If Not IsNothing(sck) Then
                    Dim b As Object = (drDg.Select("MatrixCode='" & sck.Value & "'").FirstOrDefault)
                    If Not IsDBNull(b) AndAlso Not IsNothing(b) Then sck.Checked = CBool(b.Item("Value"))
                End If
            Next

            For Each dList As DataListItem In DuodenumDataList.Items
                Dim dck As HtmlInputCheckBox = DirectCast(dList.FindControl("duoID"), HtmlInputCheckBox)
                If Not IsNothing(dck) Then
                    Dim b As Object = (drDg.Select("MatrixCode='" & dck.Value & "'").FirstOrDefault)
                    If Not IsDBNull(b) AndAlso Not IsNothing(b) Then dck.Checked = CBool(b.Item("Value"))
                End If
            Next

            For Each listCtrl As Control In oesodatalist.Controls
                Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
                If item.ItemType = ListItemType.Header Then
                    Dim o1Value As DataRow = drDg.Select("MatrixCode='OesophagusNormal'").FirstOrDefault
                    If Not IsNothing(o1Value) Then DirectCast(item.FindControl("OesophagusNormalCheckBox"), HtmlInputCheckBox).Checked = CBool(o1Value.Item("Value"))
                    Dim o2Value As DataRow = drDg.Select("MatrixCode='OesophagusNotEntered'").FirstOrDefault
                    If Not IsNothing(o2Value) Then DirectCast(item.FindControl("OesophagusNotEnteredCheckBox"), HtmlInputCheckBox).Checked = CBool(o2Value.Item("Value"))
                End If
                'If item.ItemType = ListItemType.Footer Then
                'Dim o3Value As DataRow = drDg.Select("MatrixCode='OesophagusOtherDiagnosis'").FirstOrDefault
                'If Not IsNothing(o3Value) Then DirectCast(item.FindControl("OesophagusOtherDiagnosisTextBox"), RadTextBox).Text = CStr(o3Value.Item("Value"))
                'End If
            Next
            For Each listCtrl As Control In StomachDataList.Controls
                Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
                If item.ItemType = ListItemType.Header Then
                    Dim o3Value As DataRow = drDg.Select("MatrixCode='StomachNotEntered'").FirstOrDefault
                    Dim o4Value As DataRow = drDg.Select("MatrixCode='StomachNormal'").FirstOrDefault
                    If Not IsNothing(o3Value) Then DirectCast(item.FindControl("StomachNotEnteredCheckBox"), HtmlInputCheckBox).Checked = CBool(o3Value.Item("Value"))
                    If Not IsNothing(o4Value) Then DirectCast(item.FindControl("StomachNormalCheckBox"), HtmlInputCheckBox).Checked = CBool(o4Value.Item("Value"))
                End If
                'If item.ItemType = ListItemType.Footer Then
                'Dim o5Value As DataRow = drDg.Select("MatrixCode='StomachOtherDiagnosis'").FirstOrDefault
                'If Not IsNothing(o5Value) Then DirectCast(item.FindControl("StomachOtherDiagnosisTextBox"), RadTextBox).Text = CStr(o5Value.Item("Value"))
                'End If
            Next
            For Each listCtrl As Control In DuodenumDataList.Controls
                Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
                If item.ItemType = ListItemType.Header Then
                    Dim o6Value As DataRow = drDg.Select("MatrixCode='DuodenumNotEntered'").FirstOrDefault
                    Dim o7Value As DataRow = drDg.Select("MatrixCode='Duodenum2ndPartNotEntered'").FirstOrDefault
                    Dim o8Value As DataRow = drDg.Select("MatrixCode='DuodenumNormal'").FirstOrDefault
                    If Not IsNothing(o6Value) Then DirectCast(item.FindControl("DuodenumNotEnteredCheckBox"), HtmlInputCheckBox).Checked = CBool(o6Value.Item("Value"))
                    If Not IsNothing(o7Value) Then DirectCast(item.FindControl("Duodenum2ndPartNotEnteredCheckBox"), HtmlInputCheckBox).Checked = CBool(o7Value.Item("Value"))
                    If Not IsNothing(o8Value) Then DirectCast(item.FindControl("DuodenumNormalCheckBox"), HtmlInputCheckBox).Checked = CBool(o8Value.Item("Value"))
                End If
                'If item.ItemType = ListItemType.Footer Then
                'Dim o9Value As DataRow = drDg.Select("MatrixCode='DuodenumOtherDiagnosis'").FirstOrDefault
                'If Not IsNothing(o9Value) Then DirectCast(item.FindControl("DuodenumOtherDiagnosisTextBox"), RadTextBox).Text = CStr(o9Value.Item("Value"))
                'End If
            Next
        End If
    End Sub

    Private Sub PopulateERCPData(sPP_Diagnoses As String, da As OtherData, iProcID As Integer)

        If sPP_Diagnoses <> "" Then
            Dim bWholePanBilNormal As Boolean = True
            Dim delim As String() = New String(0) {"<b>"}
            Dim sDiag As String() = sPP_Diagnoses.Split(delim, StringSplitOptions.None)
            For Each Diag In sDiag
                If Diag.Contains("Duodenum: </b>") And (Not Diag.ToLower.Contains("</b>normal") And Not Diag.ToLower.Contains("not entered")) Then
                    Diag = Diag.Replace("Duodenum: </b>", "")
                    If Not chkAbnoDiagnoses(Diag) Then '### Not ('not entered'/'normal')
                        divERCPAbnoDiagnosesDuodenum.Visible = True
                        divERCPAbnoDiagnosesDuodenum.InnerHtml = Left(Diag, 1).ToUpper & Diag.Substring(1)
                        D51P2_CheckBox.Visible = False
                    Else
                        If Diag.Contains("normal") Then
                            D51P2_CheckBox.Checked = True
                        ElseIf Diag.Contains("not Entered") Then
                            D50P2_CheckBox.Checked = True
                        ElseIf Diag.Contains("second part") Then
                            D52P2_CheckBox.Checked = True
                        End If
                    End If
                End If

                If Diag.Contains("Ampulla: </b>") And (Not Diag.ToLower.Contains("</b>normal") And Not Diag.ToLower.Contains("not entered")) Then
                    Diag = Diag.Replace("Ampulla: </b>", "")
                    If Not chkAbnoDiagnoses(Diag) Then
                        divERCPAbnoDiagnosesPapillae.Visible = True
                        D33P2_CheckBox.Visible = False 'PapillaeNormalCheckBox
                        divERCPAbnoDiagnosesPapillae.InnerHtml = Left(Diag, 1).ToUpper & Diag.Substring(1)
                        If Diag.Contains("tumour") Then
                            ScriptManager.RegisterStartupScript(Me, Page.GetType, "ShowPapillaeTumourDiv", "$('#PapillaeTumourDiv').show();", True)
                            'PapillaeTumourDiv.Style("display") = "normal"
                        End If
                        bWholePanBilNormal = False
                    End If
                End If

                If Diag.Contains("Pancreas: </b>") And (Not Diag.ToLower.Contains("</b>normal") And Not Diag.ToLower.Contains("not entered")) Then
                    Diag = Diag.Replace("Pancreas: </b>", "")
                    If Not chkAbnoDiagnoses(Diag) Then
                        divERCPAbnoDiagnosesPancreas.Visible = True
                        D67P2_CheckBox.Visible = False 'PancreasNormalCheckBox
                        D66P2_CheckBox.Visible = False 'PancreasNormalCheckBox
                        divERCPAbnoDiagnosesPancreas.InnerHtml = Left(Diag, 1).ToUpper & Diag.Substring(1)
                        bWholePanBilNormal = False
                    End If
                End If

                If Diag.Contains("Biliary: </b>") And (Not Diag.ToLower.Contains("</b>normal") And Not Diag.ToLower.Contains("not entered")) Then
                    Diag = Diag.Replace("Biliary: </b>", "")
                    If Not chkAbnoDiagnoses(Diag) Then
                        D138P2_CheckBox.Visible = False 'BiliaryNormalCheckBox


                        Dim iIntrahepaticPos As Integer = Diag.ToLower.IndexOf("intrahepatic:")
                        Dim iExtrahepaticPos As Integer = Diag.ToLower.IndexOf("extrahepatic:")
                        Dim sBiliary As String = ""
                        Dim sExtrahepatic As String = ""
                        Dim sIntrahepatic As String = ""
                        If iExtrahepaticPos >= 0 Then
                            sExtrahepatic = Diag.Substring(iExtrahepaticPos).Replace("Extrahepatic: ", "").Replace("extrahepatic: ", "").Replace("<br/>", "")
                            D265P2_CheckBox.Visible = False 'ExtrahepaticNormalCheckBox
                            Diag = Left(Diag, iExtrahepaticPos)
                        End If
                        If iIntrahepaticPos >= 0 Then
                            sIntrahepatic = Diag.Substring(iIntrahepaticPos).Replace("Intrahepatic: ", "").Replace("intrahepatic: ", "").Replace("<br/>", "")
                            D198P2_CheckBox.Visible = False 'NormalDuctsCheckBox
                            Diag = Left(Diag, iIntrahepaticPos)
                        End If

                        If Trim(Diag) <> "" Then
                            sBiliary = Left(Diag, 1).ToUpper & Diag.Substring(1)
                            If Trim(sBiliary) <> "" Then
                                divERCPBiliary.Visible = True
                                divERCPBiliary.InnerHtml = Left(Diag, 1).ToUpper & Diag.Substring(1)
                            End If
                        End If

                        'sExtrahepatic = Diag.Substring(Diag.ToLower.IndexOf("extrahepatic:"))
                        If sIntrahepatic <> "" Then
                            divERCPIntrahepatic.Visible = True
                            divERCPIntrahepatic.InnerHtml = Left(sIntrahepatic, 1).ToUpper & sIntrahepatic.Substring(1)

                            If sIntrahepatic.ToLower.Contains("tumour") Then
                                IntrahepaticTumourDiv.Style("display") = "normal"
                                D242P2_CheckBox.Checked = True 'IntrahepaticTumourProbableCheckBox
                            End If
                        End If
                        If sExtrahepatic <> "" Then
                            divERCPExtrahepatic.Visible = True
                            divERCPExtrahepatic.InnerHtml = Left(sExtrahepatic, 1).ToUpper & sExtrahepatic.Substring(1)

                            If sExtrahepatic.ToLower.Contains("stricture") Then
                                IntrahepaticTumourDiv.Style("display") = "normal"
                                D290P2_CheckBox.Checked = True 'ExtrahepaticTumourCheckBox
                                ExtrahepaticTumourDiv.Style("display") = "normal"
                                If sExtrahepatic.ToLower.Contains("benign") Then
                                    ExtrahepaticTumourRadioButtonList.SelectedValue = 1
                                    BeningTR.Style("display") = "normal"
                                ElseIf sExtrahepatic.ToLower.Contains("malignant") Then
                                    ExtrahepaticTumourRadioButtonList.SelectedValue = 2
                                    MalignantTR.Style("display") = "normal"
                                End If

                                If sExtrahepatic.ToLower.Contains("probably malignant") Or sExtrahepatic.ToLower.Contains("probably benign") Then
                                    D325P2_CheckBox.Checked = True 'ExtrahepaticProbableCheckBox
                                End If
                            End If
                        End If
                        If D290P2_CheckBox.Checked = False Then D290P2_CheckBox.Visible = False
                        bWholePanBilNormal = False
                    End If
                End If
            Next

            If divERCPAbnoDiagnosesDuodenum.Visible = True Then ERCP_DuodenumFieldset.Visible = False
            If Not bWholePanBilNormal Then D32P2_CheckBox.Visible = False 'WholePancreaticCheckBox
        End If




        Dim drDg As DataTable = da.GetDiagnosesData(iProcID)

        RadTabStrip1.FindTabByValue("5").Visible = True
        RadTabStrip1.FindTabByValue("5").Selected = True
        RadPageView5.Selected = True

        Dim arrRadPageView() As RadPageView = {RadPageView5, RadPageViewE0, RadPageViewE1}

        For Each radPageView As RadPageView In arrRadPageView
            For Each ctrl As Control In radPageView.Controls
                setERCPValue(ctrl, drDg)
            Next
        Next
    End Sub

    Private Sub setERCPValue(ctrl As Control, drDg As DataTable)
        Dim sFldName As String = ""
        If TypeOf ctrl Is CheckBox Then
            sFldName = CStr(ctrl.ID).Replace("_CheckBox", "") '.Replace("ERCP_", "")
            Dim a0Value As DataRow = drDg.Select("MatrixCode='" & sFldName & "'").FirstOrDefault
            If a0Value IsNot Nothing AndAlso Not IsDBNull(a0Value.Item("Value")) AndAlso CStr(a0Value.Item("Value")).ToLower.Trim = "1" Then
                DirectCast(ctrl, CheckBox).Checked = True
            End If
        ElseIf TypeOf ctrl Is TextBox Then
            sFldName = CStr(ctrl.ID).Replace("TextBox", "")
            Dim a0Value As DataRow = drDg.Select("MatrixCode='" & sFldName & "'").FirstOrDefault
            If a0Value IsNot Nothing AndAlso Not IsDBNull(a0Value.Item("Value")) AndAlso CStr(a0Value.Item("Value")).Trim <> "" Then
                DirectCast(ctrl, TextBox).Text = Server.HtmlDecode(a0Value.Item("Value"))
            End If
        ElseIf TypeOf ctrl Is RadComboBox Then
            sFldName = CStr(ctrl.ID).Replace("RadComboBox", "")
            Dim a0Value As DataRow = drDg.Select("MatrixCode='" & sFldName & "'").FirstOrDefault
            If a0Value IsNot Nothing AndAlso Not IsDBNull(a0Value.Item("Value")) AndAlso CStr(a0Value.Item("Value")).Trim <> "" Then
                DirectCast(ctrl, RadComboBox).Text = a0Value.Item("Value")
            End If
        End If
    End Sub

    'If diag is "Not Entered", "Normal" or "2nd Part Not Entered" then return true
    Function chkAbnoDiagnoses(sDiag As String) As Boolean
        Return False 'This is done as "Normal" has been removed on the page

        sDiag = sDiag.ToLower

        If sDiag.Contains("not entered") OrElse sDiag.Contains("normal") Then
            Return True
        End If
        Return False
    End Function

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Dim da As New OtherData
        Try

            If procTypeID = ProcedureType.Colonoscopy Or procTypeID = ProcedureType.Sigmoidscopy Or procTypeID = ProcedureType.Proctoscopy Then
                SaveColonData()
            ElseIf procTypeID = ProcedureType.Gastroscopy Or procTypeID = ProcedureType.EUS_OGD Or procTypeID = ProcedureType.Transnasal Then
                SaveGastroData()
            ElseIf procTypeID = ProcedureType.ERCP Or procTypeID = ProcedureType.EUS_HPB Then
                SaveERCPData()
            End If

            ExitForm()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Diagnoses.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub


    Private Sub SaveColonData()
        Dim da As New OtherData
        Dim ColonNormalCheckBox As New HtmlInputCheckBox
        Dim ColonRestNormalCheckBox As New HtmlInputCheckBox
        Dim ColitisType As String = ""
        Dim ColoList As String = ""
        Dim MayoScore As String = ""
        Dim SEScore As String = ""

        'Dim ColoList As New Dictionary(Of String, Boolean)
        'For Each olist As DataListItem In ColonDataList.Items
        '    Dim ock As HtmlInputCheckBox = DirectCast(olist.FindControl("coloID"), HtmlInputCheckBox)
        '    ' If ock.Checked Then ColoList.Add(ock.Value, ock.Checked)
        '    If ock.Checked Then ColoList = ColoList + ock.Value + ","
        'Next

        'Remove the last comma
        'If Right(ColoList, 1) = "," Then
        '    ColoList = Left(ColoList, Len(ColoList) - 1)
        'End If

        'Dim root As New XElement("Root", From keyValue In ColoList Select New XElement(keyValue.Key, keyValue.Value))

        For Each listCtrl As Control In ColonDataList.Controls
            Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
            If item.ItemType = ListItemType.Header Then
                ColonNormalCheckBox = DirectCast(item.FindControl("ColonNormalCheckBox"), HtmlInputCheckBox)
                ColonRestNormalCheckBox = DirectCast(item.FindControl("ColonRestNormalCheckBox"), HtmlInputCheckBox)
            End If
        Next

        'For Each olist As DataListItem In ColitisDataList.Items
        '    Dim rbColitis As HtmlInputRadioButton = DirectCast(olist.FindControl("colitisID"), HtmlInputRadioButton)
        '    If rbColitis.Checked Then
        '        ColitisType = rbColitis.Value
        '        Dim rbText = DirectCast(olist.FindControl("colitisIDLabel"), Label).Text
        '        If rbText.ToLower() = "ulcerative colitis" Then
        '            MayoScore = MayoScoreDropDownList.SelectedValue
        '        ElseIf rbText.ToLower() = "crohn's disease" Then
        '            SEScore = SESDropDownList.SelectedValue
        '        End If
        '    End If



        'Next

        'da.SaveColonDiagnoses(CInt(Session(Constants.SESSION_PROCEDURE_ID)), ColonNormalCheckBox.Checked, ColonRestNormalCheckBox.Checked,
        '                      ColitisCheckBox.Checked, IleitisCheckBox.Checked, ProctitisCheckBox.Checked,
        '                      ColitisType, ExtentDropdownlist.SelectedValue, ExtentDropdownlist.SelectedItem.Text,
        '                      ColoList, ColonOtherDiagnosisTextBox.Text, MayoScore, SEScore) ', IleitisCheckBox.Checked, InflammatoryCheckBox.Checked)

        da.SaveColonDiagnoses(CInt(Session(Constants.SESSION_PROCEDURE_ID)), ColonNormalCheckBox.Checked, ColonRestNormalCheckBox.Checked,
                              ColitisType,
                              ColoList)

    End Sub

    Private Sub SaveGastroData()
        Dim da As New OtherData
        Dim OesoList As String = "" ' As New Dictionary(Of String, Boolean)
        Dim StomachList As String = ""
        Dim DuoList As String = ""

        Dim OesophagusNotEnteredCheckBox As New HtmlInputCheckBox
        Dim StomachNotEnteredCheckBox As New HtmlInputCheckBox
        Dim DuodenumNotEnteredCheckBox As New HtmlInputCheckBox
        Dim Duodenum2ndPartNotEnteredCheckBox As New HtmlInputCheckBox
        For Each olist As DataListItem In oesodatalist.Items
            Dim ock As HtmlInputCheckBox = DirectCast(olist.FindControl("oesoID"), HtmlInputCheckBox)
            If ock.Checked Then OesoList = OesoList + ock.Value + "," '.Add(ock.Value, ock.Checked)
        Next

        For Each sList As DataListItem In StomachDataList.Items
            Dim sck As HtmlInputCheckBox = DirectCast(sList.FindControl("stoID"), HtmlInputCheckBox)
            If sck.Checked Then StomachList = StomachList + sck.Value + ","
        Next

        For Each dList As DataListItem In DuodenumDataList.Items
            Dim dck As HtmlInputCheckBox = DirectCast(dList.FindControl("duoID"), HtmlInputCheckBox)
            If dck.Checked Then DuoList = DuoList + dck.Value + ","
        Next

        ' BodyContent_oesodatalist_OesophagusNotEnteredCheckBox()
        Dim OesophagusNormalCheckBox As New HtmlInputCheckBox
        'Dim OesophagusNotEnteredCheckBox As New HtmlInputCheckBox
        'Dim OesophagusOtherDiagnosisTextBox As New RadTextBox

        For Each listCtrl As Control In oesodatalist.Controls
            Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
            If item.ItemType = ListItemType.Header Then
                If divAbnoDiagnosesOeso.Visible Then
                    OesophagusNormalCheckBox.Checked = False
                    OesophagusNotEnteredCheckBox.Checked = False
                Else
                    OesophagusNormalCheckBox = DirectCast(item.FindControl("OesophagusNormalCheckBox"), HtmlInputCheckBox)
                    OesophagusNotEnteredCheckBox = DirectCast(item.FindControl("OesophagusNotEnteredCheckBox"), HtmlInputCheckBox)
                End If
            End If
            'If item.ItemType = ListItemType.Footer Then
            '    OesophagusOtherDiagnosisTextBox = DirectCast(item.FindControl("OesophagusOtherDiagnosisTextBox"), RadTextBox)
            'End If
        Next

        'Dim StomachNotEnteredCheckBox As New HtmlInputCheckBox
        Dim StomachNormalCheckBox As New HtmlInputCheckBox
        'Dim StomachOtherDiagnosisTextBox As New RadTextBox
        For Each listCtrl As Control In StomachDataList.Controls
            Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
            If item.ItemType = ListItemType.Header Then
                If divAbnoDiagnosesStomach.Visible Then
                    StomachNotEnteredCheckBox.Checked = False
                    StomachNormalCheckBox.Checked = False
                Else
                    StomachNotEnteredCheckBox = DirectCast(item.FindControl("StomachNotEnteredCheckBox"), HtmlInputCheckBox)
                    StomachNormalCheckBox = DirectCast(item.FindControl("StomachNormalCheckBox"), HtmlInputCheckBox)
                End If
            End If
            'If item.ItemType = ListItemType.Footer Then
            '    StomachOtherDiagnosisTextBox = DirectCast(item.FindControl("StomachOtherDiagnosisTextBox"), RadTextBox)
            'End If
        Next

        'Dim DuodenumNotEnteredCheckBox As New HtmlInputCheckBox
        'Dim Duodenum2ndPartNotEnteredCheckBox As New HtmlInputCheckBox
        Dim DuodenumNormalCheckBox As New HtmlInputCheckBox
        'Dim DuodenumOtherDiagnosisTextBox As New RadTextBox
        For Each listCtrl As Control In DuodenumDataList.Controls
            Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
            If item.ItemType = ListItemType.Header Then
                If divAbnoDiagnosesDuodenum.Visible Then
                    DuodenumNotEnteredCheckBox.Checked = False
                    Duodenum2ndPartNotEnteredCheckBox.Checked = False
                    DuodenumNormalCheckBox.Checked = False
                Else
                    DuodenumNotEnteredCheckBox = DirectCast(item.FindControl("DuodenumNotEnteredCheckBox"), HtmlInputCheckBox)
                    Duodenum2ndPartNotEnteredCheckBox = DirectCast(item.FindControl("Duodenum2ndPartNotEnteredCheckBox"), HtmlInputCheckBox)
                    DuodenumNormalCheckBox = DirectCast(item.FindControl("DuodenumNormalCheckBox"), HtmlInputCheckBox)
                End If
            End If
            'If item.ItemType = ListItemType.Footer Then
            '    DuodenumOtherDiagnosisTextBox = DirectCast(item.FindControl("DuodenumOtherDiagnosisTextBox"), RadTextBox)
            'End If
        Next


        If Right(OesoList, 1) = "," Then OesoList = Left(OesoList, Len(OesoList) - 1)


        If Right(StomachList, 1) = "," Then StomachList = Left(StomachList, Len(StomachList) - 1)


        If Right(DuoList, 1) = "," Then DuoList = Left(DuoList, Len(DuoList) - 1)

        'da.SaveUpperGIDiagnoses(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
        '                                OverallNormalCheckBox.Checked,
        '                                OesophagusNormalCheckBox.Checked,
        '                                OesophagusNotEnteredCheckBox.Checked,
        '                                OesoList,
        '                                StomachNotEnteredCheckBox.Checked,
        '                                StomachNormalCheckBox.Checked,
        '                                StomachList,
        '                                DuodenumNotEnteredCheckBox.Checked,
        '                                Duodenum2ndPartNotEnteredCheckBox.Checked,
        '                                DuodenumNormalCheckBox.Checked,
        '                                DuoList,
        '                                OesophagusOtherDiagnosisTextBox.Text,
        '                                StomachOtherDiagnosisTextBox.Text,
        '                                DuodenumOtherDiagnosisTextBox.Text)

        da.SaveUpperGIDiagnoses(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                        OverallNormalCheckBox.Checked,
                                        OesophagusNormalCheckBox.Checked,
                                        OesophagusNotEnteredCheckBox.Checked,
                                        OesoList,
                                        StomachNormalCheckBox.Checked,
                                        StomachNotEnteredCheckBox.Checked,
                                        StomachList,
                                        DuodenumNormalCheckBox.Checked,
                                        DuodenumNotEnteredCheckBox.Checked,
                                        Duodenum2ndPartNotEnteredCheckBox.Checked,
                                        DuoList)
    End Sub

    Private Sub SaveERCPData()
        Dim da As New OtherData
        Dim DuodenumNotEnteredCheckBox As Boolean = D50P2_CheckBox.Checked
        Dim Duodenum2ndPartNotEnteredCheckBox As Boolean = D52P2_CheckBox.Checked
        Dim DuodenumNormalCheckBox As Boolean = D51P2_CheckBox.Checked
        'Dim DuodenumOtherDiagnosisTextBox As New RadTextBox



        Dim WholePancreaticCheckBox As Boolean = D32P2_CheckBox.Checked
        Dim PapillaeNormalCheckBox As Boolean = D33P2_CheckBox.Checked
        Dim StenosedCheckBox As Boolean = D41P2_CheckBox.Checked
        Dim ERCP_TumourBenignCheckBox As Boolean = D45P2_CheckBox.Checked
        Dim ERCP_TumourMalignantCheckBox As Boolean = D65P2_CheckBox.Checked
        Dim PancreasNormalCheckBox As Boolean = D67P2_CheckBox.Checked
        Dim PancreasNotEnteredCheckBox As Boolean = D66P2_CheckBox.Checked
        Dim AnnulareCheckBox As Boolean = D68P2_CheckBox.Checked
        Dim DuctInjuryCheckBox As Boolean = D69P2_CheckBox.Checked
        Dim PanStentOcclusionCheckBox As Boolean = D74P2_CheckBox.Checked
        Dim IPMTCheckBox As Boolean = D75P2_CheckBox.Checked
        'Dim PancreaticAndBiliaryOtherTextBox As string 
        Dim BiliaryNormalCheckBox As Boolean = D138P2_CheckBox.Checked
        Dim AnastomicStrictureCheckBox As Boolean = D140P2_CheckBox.Checked
        'Dim CysticDuctCheckBox As Boolean = D155P2_CheckBox.Checked
        Dim HaemobiliaCheckBox As Boolean = D170P2_CheckBox.Checked
        Dim CholelithiasisCheckBox As Boolean = D185P2_CheckBox.Checked
        Dim FistulaLeakCheckBox As Boolean = D145P2_CheckBox.Checked
        Dim MirizziCheckBox As Boolean = D160P2_CheckBox.Checked
        Dim CalculousObstructionCheckBox As Boolean = D175P2_CheckBox.Checked
        'Dim GallBladderCheckBox As Boolean = D190P2_CheckBox.Checked
        Dim OcclusionCheckBox As Boolean = D150P2_CheckBox.Checked
        'Dim CommonDuctCheckBox As Boolean = D165P2_CheckBox.Checked
        Dim GallBladderTumourCheckBox As Boolean = D180P2_CheckBox.Checked
        Dim StentOcclusionCheckBox As Boolean = D195P2_CheckBox.Checked
        Dim NormalDuctsCheckBox As Boolean = D198P2_CheckBox.Checked
        Dim SuppurativeCheckBox As Boolean = D210P2_CheckBox.Checked
        Dim BiliaryLeakSiteCheckBox As Boolean = D220P2_CheckBox.Checked
        ' Dim BiliaryLeakSiteRadComboBox As Boolean = .SelectedValue
        Dim IntrahepaticTumourProbableCheckBox As Boolean = D242P2_CheckBox.Checked
        Dim IntrahepaticTumourPossibleCheckBox As Boolean = D243P2_CheckBox.Checked
        Dim ExtrahepaticNormalCheckBox As Boolean = D265P2_CheckBox.Checked
        Dim ExtrahepaticLeakSiteCheckBox As Boolean = D280P2_CheckBox.Checked
        'Dim ExtrahepaticLeakSiteRadComboBox As Boolean = .SelectedValue
        Dim BeningPancreatitisCheckBox As Boolean = D305P2_CheckBox.Checked
        Dim BeningPseudocystCheckBox As Boolean = D310P2_CheckBox.Checked
        Dim BeningPreviousCheckBox As Boolean = D315P2_CheckBox.Checked
        Dim BeningSclerosingCheckBox As Boolean = D320P2_CheckBox.Checked
        Dim BeningProbableCheckBox As Boolean = D337P2_CheckBox.Checked
        Dim MalignantGallbladderCheckBox As Boolean = D340P2_CheckBox.Checked
        Dim MalignantMetastaticCheckBox As Boolean = D345P2_CheckBox.Checked
        Dim MalignantCholangiocarcinomaCheckBox As Boolean = D350P2_CheckBox.Checked
        Dim MalignantPancreaticCheckBox As Boolean = D355P2_CheckBox.Checked
        Dim MalignantProbableCheckBox As Boolean = D338P2_CheckBox.Checked
        'Dim BiliaryOtherTextBox As Boolean = .Text
        'Dim WholeOtherRadComboBox As Boolean = .SelectedValue)

        da.SaveERCPDiagnoses(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                        DuodenumNotEnteredCheckBox,
                                        DuodenumNormalCheckBox,
                                        Duodenum2ndPartNotEnteredCheckBox,
                                        WholePancreaticCheckBox,
                                        PapillaeNormalCheckBox,
                                        StenosedCheckBox,
                                        ERCP_TumourBenignCheckBox,
                                        ERCP_TumourMalignantCheckBox,
                                        PancreasNormalCheckBox,
                                        PancreasNotEnteredCheckBox,
                                        AnnulareCheckBox,
                                        DuctInjuryCheckBox,
                                        PanStentOcclusionCheckBox,
                                        IPMTCheckBox,
                                        Server.HtmlEncode(PancreaticOtherTextBox.Text),
                                        BiliaryNormalCheckBox,
                                        AnastomicStrictureCheckBox,
                                        HaemobiliaCheckBox,
                                        CholelithiasisCheckBox,
                                        FistulaLeakCheckBox,
                                        MirizziCheckBox,
                                        CalculousObstructionCheckBox,
                                        OcclusionCheckBox,
                                        GallBladderTumourCheckBox,
                                        StentOcclusionCheckBox,
                                        NormalDuctsCheckBox,
                                        SuppurativeCheckBox,
                                        BiliaryLeakSiteCheckBox,
                                        BiliaryLeakSiteRadComboBox.SelectedValue,
                                        IntrahepaticTumourProbableCheckBox,
                                        IntrahepaticTumourPossibleCheckBox,
                                        ExtrahepaticNormalCheckBox,
                                        ExtrahepaticLeakSiteCheckBox,
                                        ExtrahepaticLeakSiteRadComboBox.SelectedValue,
                                        BeningPancreatitisCheckBox,
                                        BeningPseudocystCheckBox,
                                        BeningPreviousCheckBox,
                                        BeningSclerosingCheckBox,
                                        BeningProbableCheckBox,
                                        MalignantGallbladderCheckBox,
                                        MalignantMetastaticCheckBox,
                                        MalignantCholangiocarcinomaCheckBox,
                                        MalignantPancreaticCheckBox,
                                        MalignantProbableCheckBox,
                                        Server.HtmlEncode(BiliaryOtherTextBox.Text),
                                        WholeOtherRadComboBox.SelectedValue)

        'CysticDuctCheckBox, _
        'GallBladderCheckBox,
        'CommonDuctCheckBox,

    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        ExitForm()
    End Sub
    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub
End Class