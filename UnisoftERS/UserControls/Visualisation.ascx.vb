Public Class Visualisation
    Inherits System.Web.UI.UserControl
#Region "Public Propery"
    Private _visRecrdId As Integer
    Public Property RecordId() As String
        Get
            Return _visRecrdId
        End Get
        Set(ByVal value As String)
            _visRecrdId = value
        End Set
    End Property


    Private _carriedOutRole As String
    Public Property CarriedOutRole() As String
        Get
            Return _carriedOutRole
        End Get
        Set(ByVal value As String)
            _carriedOutRole = value
        End Set
    End Property
#End Region

#Region "Private Variables"
    Dim od As New OtherData

    Dim iAccessVia As Integer = 0
    Dim iMajorPapillaBile As Integer = 0
    Dim iMajorPapillaPancreatic As Integer = 0
    Dim iMinorPapilla As Integer = 0
    Dim cboBileReasonsSelectedValue As String = ""
    Dim cboPancreaticReasonsSelectedValue As String = ""
    Dim cboMinorPapReasonsSelectedValue As String = ""
    Dim iHepatobiliaryLimitedBy As Integer = 0
    Dim iPancreaticLimitedBy As Integer = 0

    Dim _fieldValueFound As Boolean
    Dim thisIsA_NewRecord As Boolean

#End Region
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not IsPostBack Then
            ViewState("EndoscopistRoleId") = IIf(CarriedOutRole = "TrainER", 1, 2)
            hiddenCarriedRoleOut.Value = CInt(ViewState("EndoscopistRoleId"))
            LoadLookupComboBoxes()
            initForm()
        End If
        'Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdAccept, tableTop, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(cmdCancel, tableTop, RadAjaxLoadingPanel1)
    End Sub

    Sub LoadLookupComboBoxes()

        BindLookupSource(cboAccessViaOther, "ERCP other access point")
        BindLookupSource(optLB2ComboBox, "ERCP extent of visualisation limited by other")
        BindLookupSource(optOtherComboBox, "ERCP extent of visualisation limited by other")
        BindLookupSource(HepatobiliaryFirstComboBox, "ERCP contrast media used")
        BindLookupSource(HepatobiliarySecondComboBox, "ERCP contrast media used")
        BindLookupSource(PancreaticFirstComboBox, "ERCP contrast media used")
        BindLookupSource(PancreaticSecondComboBox, "ERCP contrast media used")

        BindLookupSource(cboBileReasons1, "ERCP via major to bile successful using")
        BindLookupSource(cboBileReasons2, "ERCP via major to bile partially successful reason")
        BindLookupSource(cboBileReasons4, "ERCP via major to bile unsuccessful due to")
        BindLookupSource(cboPancreaticReasons1, "ERCP via major to pancreatic successful using")
        BindLookupSource(cboPancreaticReasons2, "ERCP via major to pancreatic partially successful reason")
        BindLookupSource(cboPancreaticReasons4, "ERCP via major to pancreatic unsuccessful due to")
        BindLookupSource(cboMinorPapReasons1, "ERCP via minor successful using to")
        BindLookupSource(cboMinorPapReasons2, "ERCP via minor partially successful reason")
        BindLookupSource(cboMinorPapReasons4, "ERCP via minor unsuccessful due to")

    End Sub

    Sub BindLookupSource(ByVal dropDownName As Global.Telerik.Web.UI.RadComboBox, ByVal listSource As String)
        Dim da As New DataAccess
        Utilities.LoadDropdown(dropDownName, da.GetDropDownList(listSource), "ListItemText", "ListItemNo", Nothing)
    End Sub

    Protected Sub initForm()
        Dim od As New OtherData
        'Dim oDT As DataTable = od.SelectVisualisation(currentRecordId)
        Dim VisRecord As ERS.Data.ERS_Visualisation = od.SelectVisualisation(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

        If VisRecord IsNot Nothing Then
            'Dim rRow As DataRow = oDT.Rows(0)
            Select Case CInt(VisRecord.AccessVia)
                Case 1
                    optAV1.Checked = True
                Case 2
                    optVA2.Checked = True
                    cboAccessViaOther.SelectedValue = VisRecord.AccessViaOtherText
                    optDiv.Style("display") = "normal"
            End Select
            Select Case CInt(VisRecord.MajorPapillaBile)
                Case 1
                    optBile1.Checked = True
                    BileReasonsDiv1.Style("display") = "normal"
                    cboBileReasons1.SelectedValue = VisRecord.MajorPapillaBileReason
                Case 2
                    optBile2.Checked = True
                    BileReasonsDiv2.Style("display") = "normal"
                    cboBileReasons2.SelectedValue = VisRecord.MajorPapillaBileReason
                Case 3
                    optBile3.Checked = True
                Case 4
                    optBile4.Checked = True
                    BileReasonsDiv4.Style("display") = "normal"
                    cboBileReasons4.SelectedValue = VisRecord.MajorPapillaBileReason
            End Select

            Select Case VisRecord.MajorPapillaPancreatic
                Case 1
                    optPan1.Checked = True
                    PancreaticReasonsDiv1.Style("display") = "normal"
                    cboPancreaticReasons1.SelectedValue = VisRecord.MajorPapillaPancreaticReason
                Case 2
                    optPan2.Checked = True
                    PancreaticReasonsDiv2.Style("display") = "normal"
                    cboPancreaticReasons2.SelectedValue = VisRecord.MajorPapillaPancreaticReason
                Case 3
                    optPan3.Checked = True
                Case 4
                    optPan4.Checked = True
                    PancreaticReasonsDiv4.Style("display") = "normal"
                    cboPancreaticReasons4.SelectedValue = VisRecord.MajorPapillaPancreaticReason
            End Select

            Select Case VisRecord.MinorPapilla
                Case 1
                    optMinorPap1.Checked = True

                    MinorPapReasonsDiv1.Style("display") = "normal"
                    cboMinorPapReasons1.SelectedValue = VisRecord.MinorPapillaReason
                Case 2
                    optMinorPap2.Checked = True
                    MinorPapReasonsDiv2.Style("display") = "normal"
                    cboMinorPapReasons2.SelectedValue = VisRecord.MinorPapillaReason
                Case 3
                    optMinorPap3.Checked = True
                Case 4
                    optMinorPap4.Checked = True
                    MinorPapReasonsDiv4.Style("display") = "normal"
                    cboMinorPapReasons4.SelectedValue = VisRecord.MinorPapillaReason
            End Select

            chkHVNotVisualised.Checked = VisRecord.HepatobiliaryNotVisualised
            If VisRecord.HepatobiliaryNotVisualised Then limitedtable.Style("display") = "normal"
            chkHVWholeBiliary.Checked = VisRecord.HepatobiliaryWholeBiliary
            If VisRecord.HepatobiliaryWholeBiliary Then AcinarTR.Style("display") = "normal"
            chkExcept1.Checked = VisRecord.ExceptBileDuct
            chkExcept2.Checked = VisRecord.ExceptGallBladder
            chkExcept3.Checked = VisRecord.ExceptCommonHepaticDuct
            chkExcept4.Checked = VisRecord.ExceptRightHepaticDuct
            chkExcept5.Checked = VisRecord.ExceptLeftHepaticDuct
            chkAcinar1.Checked = VisRecord.HepatobiliaryAcinarFilling
            If VisRecord.HepatobiliaryAcinarFilling Then AcinarTR.Style("display") = "normal"
            Select Case VisRecord.HepatobiliaryLimitedBy
                Case 1
                    optLB1.Checked = True
                    limitedtable.Style("display") = "normal"
                Case 2
                    optLB2.Checked = True
                    limitedtable.Style("display") = "normal"
                    optLB2Div.Style("display") = "normal"
                    optLB2ComboBox.SelectedValue = VisRecord.HepatobiliaryLimitedByOtherText
            End Select
            pNotVisualisedCheckBox.Checked = VisRecord.PancreaticNotVisualised
            If VisRecord.PancreaticNotVisualised Then limitedtable1.Style("display") = "normal"
            PancreasCheckBox.Checked = VisRecord.PancreaticDivisum
            WholeCheckBox.Checked = VisRecord.PancreaticWhole
            If VisRecord.PancreaticWhole Then chkAcinar2TR.Style("display") = "normal"
            ExceptCheckBox1.Checked = VisRecord.ExceptAccesoryPancreatic
            ExceptCheckBox2.Checked = VisRecord.ExceptMainPancreatic
            ExceptCheckBox3.Checked = VisRecord.ExceptUncinate
            ExceptCheckBox4.Checked = VisRecord.ExceptHead
            ExceptCheckBox5.Checked = VisRecord.ExceptNeck
            ExceptCheckBox6.Checked = VisRecord.ExceptBody
            ExceptCheckBox7.Checked = VisRecord.ExceptTail
            chkAcinar2.Checked = VisRecord.PancreaticAcinar
            If VisRecord.PancreaticAcinar Then chkAcinar2TR.Style("display") = "normal"
            Select Case VisRecord.PancreaticLimitedBy
                Case 1
                    optLimitedByPVButton.Checked = True
                    limitedtable1.Style("display") = "normal"
                Case 2
                    optOtherButton.Checked = True
                    optOtherDiv.Style("display") = "normal"
                    limitedtable1.Style("display") = "normal"
                    optOtherComboBox.SelectedValue = VisRecord.PancreaticLimitedByOtherText
            End Select
            HepatobiliaryFirstComboBox.SelectedValue = VisRecord.HepatobiliaryFirst
            HepatobiliaryFirstMLTextBox.Text = VisRecord.HepatobiliaryFirstML
            HepatobiliarySecondComboBox.SelectedValue = VisRecord.HepatobiliarySecond
            HepatobiliarySecondMLRadTextBox.Text = VisRecord.HepatobiliarySecondML
            HepatobiliaryBalloonCheckBox.Checked = VisRecord.HepatobiliaryBalloon
            PancreaticFirstComboBox.SelectedValue = VisRecord.PancreaticFirst
            PancreaticFirstMLTextBox.Text = VisRecord.PancreaticFirstML
            PancreaticSecondComboBox.SelectedValue = VisRecord.PancreaticSecond
            PancreaticSecondMLTextBox.Text = VisRecord.PancreaticSecondML
            PancreaticBalloonCheckBox.Checked = VisRecord.PancreaticBalloon
            AbandonedCheckBox.Checked = VisRecord.Abandoned

        End If
    End Sub

    Public Sub VisualisationForm_Save()
        od = New OtherData

        Try
            FillRecord_OtherData()
            SaveRecord()

            '### Following block is commented- as Visualisation will not have any scenario- where one can uncheck/clear all previously selected values.. So- we can't or don't need to DELETE an Empty EE/ER record!

            'thisIsA_NewRecord = IIf((currentRecordId <= 0), True, False)

            'Dim trainEE_Value_Found As Boolean, trainEE_Record_Deleted As Boolean '### useful when Loaded as TrainER UC
            'Dim isLoadedAsTrainEE As Boolean = IIf(EndoscopistRoleId = 2, True, False)

            'If thisIsA_NewRecord Then
            '    If Session("TrainEE_Value_Found") IsNot Nothing Then trainEE_Value_Found = Session("TrainEE_Value_Found")

            '    If _fieldValueFound Then
            '        '### For both EE/ER- just INSERT it- when values found in the Record
            '        SaveRecord()
            '    Else '### when Empty record is passed! NO VALUE!!!
            '        If isLoadedAsTrainEE Then '### When TrainEE is passed with no Value- store the flag to be used while checking the TrainER record!
            '            Session("TrainEE_Value_Found") = False
            '            Session("TrainEE_Row_Deleted") = True '### For a later UPDATE Scenario. When Loaded EE = Empty; ER with Values; and then User Emptied all ER values and trying to UPDATE..! So- we will know there is NO EE record, and therefore safe to Delete the Empty ER Record
            '            '### And NOT inserting anything...
            '        Else '#### A 'New Record' AND 'No Field Value Found' )
            '            '### When TrainER is passed empty- then check whether TrainEE was empty, too! If NO- then - don't INSERT TrainER emtpy
            '            If trainEE_Value_Found Then SaveRecord()
            '        End If
            '    End If
            'Else '## UPDATE existing Record
            '    If Session("TrainEE_Row_Deleted") IsNot Nothing Then trainEE_Record_Deleted = Session("TrainEE_Row_Deleted")

            '    If _fieldValueFound Then '## All fields are EMPTY
            '        '### For both EE/ER- just UPDATE it- when values found in the Record
            '        SaveRecord()
            '    ElseIf isLoadedAsTrainEE Then
            '        'therap.TherapeuticRecord_Save(ERCP_Record, Therapeutics.SaveAs.Delete)
            '        od.Visualisation_Delete(currentRecordId)
            '        Session("TrainEE_Row_Deleted") = True '## Keep in the session- result of this Activity.. will need when coming back to check TrainER record
            '    ElseIf Not isLoadedAsTrainEE Then '### Sounds Idiotic comparing with previous ELSE- but keep it Idiot proof IF..ELSE..
            '        '### Then check whether TrainEE was empty, too.. if YES- DELETE TrainER plus Delete RecordCounter
            '        If trainEE_Record_Deleted = True Then '### When previously TrainEE was updated with EMPTY values and were DELETED- and now TrainER has come also EMPTY- DELETE the Record Counter in the dbo.[ers_RecordCounter] Table!!!!
            '            '### No TrainEE, no TrainER record values... :(                        
            '            od.Visualisation_Delete(currentRecordId)
            '            Dim da As New DataAccess                        
            '            da.UpdateRecordCount(Session(Constants.SESSION_PROCEDURE_ID), 0, "Visualisation", False) '### This call will actually Remove the Counter record from the table!
            '        Else
            '            '### TrainEE record Has values.. so- you can't delete the TrainER Empty record.. must keep it!
            '            SaveRecord()
            '        End If
            '    End If
            'End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("OtherData -> Visualisation.asCx.vb, at: VisualisationForm_Save()", ex) '### The entire LogTable is for Error Log.. so we don't need to save "Error occured while saving"

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Sub FillRecord_OtherData()
        _fieldValueFound = False '### Initiate with 'False'. When any CheckBox is found Checked in GetValue()- then it will be 'True' from there!

        If optAV1.Checked Then
            iAccessVia = 1
        ElseIf optVA2.Checked Then
            iAccessVia = 2
        End If

        If optBile1.Checked Then
            iMajorPapillaBile = 1
            cboBileReasonsSelectedValue = od.InsertToERSList("ERCP via major to bile successful using", cboBileReasons1.Text)
        ElseIf optBile2.Checked Then
            iMajorPapillaBile = 2
            cboBileReasonsSelectedValue = od.InsertToERSList("ERCP via major to bile partially successful reason", cboBileReasons2.Text)
        ElseIf optBile3.Checked Then
            iMajorPapillaBile = 3
        ElseIf optBile4.Checked Then
            iMajorPapillaBile = 4
            cboBileReasonsSelectedValue = od.InsertToERSList("ERCP via major to bile unsuccessful due to", cboBileReasons4.Text)
        End If

        If optPan1.Checked Then
            iMajorPapillaPancreatic = 1
            cboPancreaticReasonsSelectedValue = od.InsertToERSList("ERCP via major to pancreatic successful using", cboPancreaticReasons1.Text)
        ElseIf optPan2.Checked Then
            iMajorPapillaPancreatic = 2
            cboPancreaticReasonsSelectedValue = od.InsertToERSList("ERCP via major to pancreatic partially successful reason", cboPancreaticReasons2.Text)
        ElseIf optPan3.Checked Then
            iMajorPapillaPancreatic = 3
        ElseIf optPan4.Checked Then
            iMajorPapillaPancreatic = 4
            cboPancreaticReasonsSelectedValue = od.InsertToERSList("ERCP via major to pancreatic unsuccessful due to", cboPancreaticReasons4.Text)
        End If

        If optMinorPap1.Checked Then
            iMinorPapilla = 1
            cboMinorPapReasonsSelectedValue = od.InsertToERSList("ERCP via minor successful using to", cboMinorPapReasons1.Text)
        ElseIf optMinorPap2.Checked Then
            iMinorPapilla = 2
            cboMinorPapReasonsSelectedValue = od.InsertToERSList("ERCP via minor partially successful reason", cboMinorPapReasons2.Text)
        ElseIf optMinorPap3.Checked Then
            iMinorPapilla = 3
        ElseIf optMinorPap4.Checked Then
            iMinorPapilla = 4
            cboMinorPapReasonsSelectedValue = od.InsertToERSList("ERCP via minor unsuccessful due to", cboMinorPapReasons4.Text)
        End If

        If optLB1.Checked Then
            iHepatobiliaryLimitedBy = 1
        ElseIf optLB2.Checked Then
            iHepatobiliaryLimitedBy = 2
        End If
        If iHepatobiliaryLimitedBy >= 1 Then _fieldValueFound = True

        If optLimitedByPVButton.Checked Then
            iPancreaticLimitedBy = 1
        ElseIf optOtherButton.Checked Then
            iPancreaticLimitedBy = 2
        End If

        '### If any of the checkboxes was Checked.... then know for sure- Value exist!
        If (iAccessVia >= 1 Or iPancreaticLimitedBy >= 1 Or iMinorPapilla >= 1 Or iMajorPapillaPancreatic >= 1 Or iMajorPapillaBile >= 1 Or
           AbandonedCheckBox.Checked Or chkHVNotVisualised.Checked Or chkHVWholeBiliary.Checked Or pNotVisualisedCheckBox.Checked Or WholeCheckBox.Checked) Then _fieldValueFound = True


        cboAccessViaOther.SelectedValue = od.InsertToERSList("ERCP other access point", cboAccessViaOther.Text)
        optLB2ComboBox.SelectedValue = od.InsertToERSList("ERCP extent of visualisation limited by other", optLB2ComboBox.Text)
        optOtherComboBox.SelectedValue = od.InsertToERSList("ERCP extent of visualisation limited by other", optOtherComboBox.Text)

        HepatobiliaryFirstComboBox.SelectedValue = IIf(HepatobiliaryFirstComboBox.Text = "", 0, od.InsertToERSList("ERCP contrast media used", HepatobiliaryFirstComboBox.Text))
        HepatobiliarySecondComboBox.SelectedValue = IIf(HepatobiliarySecondComboBox.Text = "", 0, od.InsertToERSList("ERCP contrast media used", HepatobiliarySecondComboBox.Text))
        PancreaticFirstComboBox.SelectedValue = IIf(PancreaticFirstComboBox.Text = "", 0, od.InsertToERSList("ERCP contrast media used", PancreaticFirstComboBox.Text))
        PancreaticSecondComboBox.SelectedValue = IIf(PancreaticSecondComboBox.Text = "", 0, od.InsertToERSList("ERCP contrast media used", PancreaticSecondComboBox.Text))

        ViewState("EndoscopistRoleId") = hiddenCarriedRoleOut.Value
    End Sub

    ''' <summary>
    ''' This takes all the vlues in the StoredProc and checks- whether INSERT or UPDATE operation... 
    ''' When an INSERT statement is passed- a new record will be entered in the 'dbo.ERS_RecordCount' for Identifier: 'Visualisation'
    ''' </summary>
    ''' <remarks></remarks>
    Sub SaveRecord()
        od.SaveVisualisation(RecordId,
                                    CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                    CInt(ViewState("EndoscopistRoleId")),
                                    iAccessVia,
                                    cboAccessViaOther.SelectedValue,
                                    iMajorPapillaBile,
                                    cboBileReasonsSelectedValue,
                                    iMajorPapillaPancreatic,
                                    cboPancreaticReasonsSelectedValue,
                                    iMinorPapilla,
                                    cboMinorPapReasonsSelectedValue,
                                    chkHVNotVisualised.Checked,
                                    chkHVWholeBiliary.Checked,
                                    chkExcept1.Checked,
                                    chkExcept2.Checked,
                                    chkExcept3.Checked,
                                    chkExcept4.Checked,
                                    chkExcept5.Checked,
                                    chkAcinar1.Checked,
                                    iHepatobiliaryLimitedBy,
                                    optLB2ComboBox.SelectedValue,
                                    pNotVisualisedCheckBox.Checked,
                                    PancreasCheckBox.Checked,
                                    WholeCheckBox.Checked,
                                    ExceptCheckBox1.Checked,
                                    ExceptCheckBox2.Checked,
                                    ExceptCheckBox3.Checked,
                                    ExceptCheckBox4.Checked,
                                    ExceptCheckBox5.Checked,
                                    ExceptCheckBox6.Checked,
                                    ExceptCheckBox7.Checked,
                                    chkAcinar2.Checked,
                                    iPancreaticLimitedBy,
                                    optOtherComboBox.SelectedValue,
                                    CInt(HepatobiliaryFirstComboBox.SelectedValue),
                                    HepatobiliaryFirstMLTextBox.Text,
                                    CInt(HepatobiliarySecondComboBox.SelectedValue),
                                    HepatobiliarySecondMLRadTextBox.Text,
                                    HepatobiliaryBalloonCheckBox.Checked,
                                    CInt(PancreaticFirstComboBox.SelectedValue),
                                    PancreaticFirstMLTextBox.Text,
                                    CInt(PancreaticSecondComboBox.SelectedValue),
                                    PancreaticSecondMLTextBox.Text,
                                    PancreaticBalloonCheckBox.Checked,
                                    AbandonedCheckBox.Checked)
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

End Class