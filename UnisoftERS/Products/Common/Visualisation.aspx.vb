Imports Telerik.Web.UI

Partial Class Products_Common_Visualisation
    Inherits PageBase
    Private VisRecord As ERS.Data.ERS_Visualisation
    Private PROCEDURE_ID As Integer

    Protected Property trainEE_Exist() As Boolean
        Get
            Return CBool(ViewState("trainEE_Exist"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("trainEE_Exist") = value
        End Set
    End Property

    Protected Property currentVisRecordId() As Integer
        Get
            Return CInt(ViewState("currentVisRecordId"))
        End Get
        Set(ByVal value As Integer)
            ViewState("currentVisRecordId") = value
        End Set
    End Property

    Protected Property NEW_RECORD() As Boolean
        Get
            Return CBool(ViewState("NEW_RECORD"))
        End Get
        Set(ByVal value As Boolean)
            ViewState("NEW_RECORD") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        PROCEDURE_ID = CInt(Session(Constants.SESSION_PROCEDURE_ID))

        If Not IsPostBack Then
            LoadLookupComboBoxes()
            Load_Data()
        End If
    End Sub

    Protected Sub cancelRecord()
        ExitForm()
    End Sub

    Protected Sub SaveOnly_Click(sender As Object, e As EventArgs) Handles SaveOnly.Click
        SaveRecord(False)
    End Sub

    Protected Sub cmdAccept_Click(sender As Object, e As EventArgs) Handles cmdAccept.Click
        SaveRecord(True)
    End Sub

    Protected Sub SaveRecord(isSaveAndClose As Boolean)
        Try
            Fill_Record_Object()

            Dim DB As New OtherData
            DB.SaveVisualisation(VisRecord, NEW_RECORD, isSaveAndClose)

            WriteAuditLog() '## Log the INSERT/UPDATE operation
            NEW_RECORD = False

            Me.Master.SetButtonStyle()
            If isSaveAndClose Then
                ExitForm()
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Products\Common\Visualisation.asPx.vb, at: cmdAccept_Click()", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub

    Sub WriteAuditLog()
        '### Write to Audit Log
        Dim evenTypeId As Integer = IIf(NEW_RECORD, EVENT_TYPE.Insert, EVENT_TYPE.Update)

        Using lm As New AuditLogManager
            lm.WriteActivityLog(evenTypeId, "Save Visualisation Record, Procedure ID: " & PROCEDURE_ID.ToString())
        End Using
    End Sub

    ''' <summary>
    ''' This will load the Therapeutic Records for Both TrainEE and TrainER
    ''' And will feed the values to the UserControl respectively!
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub Load_Data()
        Dim od As New OtherData
        'Dim bFirstERCP As Boolean = False
        'Dim therap As New Therapeutics
        'Dim endoscopistRecords As ERS.Data.EndoscopistSearch_Result

        'endoscopistRecords = od.GetVisualisationRecordInfo(PROCEDURE_ID)

        Dim dtTr As DataTable = od.GetTrainerTraineeEndo(PROCEDURE_ID)
        Dim drEndoscopist As DataRow = dtTr.Rows(0)
        'Dim trainee_Exist As Boolean

        trainEE_Exist = IIf(IsDBNull(dtTr.Rows(0).Item("TraineeEndoscopist")), False, True)
        'bFirstERCP = IIf((dtTr.Rows(0).Item("FirstERCP") = 0), False, True)

        '### Write to Audit Log
        'Using lm As New AuditLogManager
        '    lm.WriteActivityLog(EVENT_TYPE.SelectRecord, "Load Visualisation Record Procedure ID: " & PROCEDURE_ID.ToString())
        'End Using

        '### If there is a signature of End2 Role in the ERS_Procedure Table- means TrainEE exist.. Go and Find him and bring him here.. ALIVE!
        'If endoscopistRecords.Endoscopist2.HasValue AndAlso (Not endoscopistRecords.Endoscopist1.Equals(endoscopistRecords.Endoscopist2)) Then
        '    trainEE_Exist = True
        'Else
        '    trainEE_Exist = False
        'End If

        If trainEE_Exist Then
            radTabStripVisualisation.Tabs(0).Text = CStr(drEndoscopist("TraineeEndoscopist")) '"TrainEE: " & 
            radTabStripVisualisation.Tabs(1).Text = CStr(drEndoscopist("TrainerEndoscopist")) '"TrainER: " &
            radTabStripVisualisation.FindTabByValue("0").Visible = True
            radTabStripVisualisation.FindTabByValue("1").Visible = True
            radTabStripVisualisation.FindTabByValue("2").Visible = True

            radTabStripVisualisation.SelectedIndex = 0
            radMultiVisPageViews.SelectedIndex = 0
        Else
            radTabStripVisualisation.SelectedIndex = 1           '### Zero gets Hidden.. 1 becomes visible; 0=TrainEE; 1=TrainEE
            radMultiVisPageViews.SelectedIndex = 1
            radTabStripVisualisation.Tabs(1).Text = "Cannulation" '"Endoscopist: " & CStr(drEndoscopist("TrainerEndoscopist"))
            radTabStripVisualisation.FindTabByValue("1").Visible = True
            radTabStripVisualisation.FindTabByValue("2").Visible = True

        End If


        'Dim oDT As DataTable = od.SelectVisualisation(currentRecordId)
        VisRecord = od.SelectVisualisation(PROCEDURE_ID)

        If VisRecord IsNot Nothing Then
            NEW_RECORD = False
            currentVisRecordId = VisRecord.ID '### will be helpful while updating.. 
            'Dim rRow As DataRow = oDT.Rows(0)
            Select Case GetNumber(VisRecord.AccessVia)
                Case 1
                    optAV1.Checked = True
                Case 2
                    optVA2.Checked = True
                    cboAccessViaOther.SelectedValue = GetString(VisRecord.AccessViaOtherText)
                    'optDiv.Style("display") = "normal"
            End Select
            Select Case GetNumber(VisRecord.MajorPapillaBile)
                Case 1
                    optBile1.Checked = True
                    BileReasonsDiv1.Style("display") = "normal"
                    cboBileReasons1.SelectedValue = GetNumber(VisRecord.MajorPapillaBileReason)
                Case 2
                    optBile2.Checked = True
                    BileReasonsDiv2.Style("display") = "normal"
                    cboBileReasons2.SelectedValue = GetNumber(VisRecord.MajorPapillaBileReason)
                Case 3
                    optBile3.Checked = True
                Case 4
                    optBile4.Checked = True
                    BileReasonsDiv4.Style("display") = "normal"
                    cboBileReasons4.SelectedValue = GetNumber(VisRecord.MajorPapillaBileReason)
            End Select

            Select Case GetNumber(VisRecord.MajorPapillaPancreatic)
                Case 1
                    optPan1.Checked = True
                    PancreaticReasonsDiv1.Style("display") = "normal"
                    cboPancreaticReasons1.SelectedValue = GetNumber(VisRecord.MajorPapillaPancreaticReason)
                Case 2
                    optPan2.Checked = True
                    PancreaticReasonsDiv2.Style("display") = "normal"
                    cboPancreaticReasons2.SelectedValue = GetNumber(VisRecord.MajorPapillaPancreaticReason)
                Case 3
                    optPan3.Checked = True
                Case 4
                    optPan4.Checked = True
                    PancreaticReasonsDiv4.Style("display") = "normal"
                    cboPancreaticReasons4.SelectedValue = GetNumber(VisRecord.MajorPapillaPancreaticReason)
            End Select

            Select Case GetNumber(VisRecord.MinorPapilla)
                Case 1
                    optMinorPap1.Checked = True

                    MinorPapReasonsDiv1.Style("display") = "normal"
                    cboMinorPapReasons1.SelectedValue = GetNumber(VisRecord.MinorPapillaReason)
                Case 2
                    optMinorPap2.Checked = True
                    MinorPapReasonsDiv2.Style("display") = "normal"
                    cboMinorPapReasons2.SelectedValue = GetNumber(VisRecord.MinorPapillaReason)
                Case 3
                    optMinorPap3.Checked = True
                Case 4
                    optMinorPap4.Checked = True
                    MinorPapReasonsDiv4.Style("display") = "normal"
                    cboMinorPapReasons4.SelectedValue = GetNumber(VisRecord.MinorPapillaReason)
            End Select
            AbandonedCheckBox.Checked = GetBoolean(VisRecord.Abandoned)
            IntendedBileDuctCheckBox.Checked = GetBoolean(VisRecord.IntendedBileDuct)
            IntendedPancreaticDuctCheckBox.Checked = GetBoolean(VisRecord.IntendedPancreaticDuct)

            '### now for TrainER fields.. and Controls..
            Select Case GetNumber(VisRecord.MajorPapillaBile_ER)
                Case 1
                    optBile1_ER.Checked = True
                    ER_BileReasonsDiv1.Style("display") = "normal"
                    cboBileReasons1_ER.SelectedValue = GetNumber(VisRecord.MajorPapillaBileReason_ER)
                Case 2
                    optBile2_ER.Checked = True
                    ER_BileReasonsDiv2.Style("display") = "normal"
                    cboBileReasons2_ER.SelectedValue = GetNumber(VisRecord.MajorPapillaBileReason_ER)
                Case 3
                    optBile3_ER.Checked = True
                Case 4
                    optBile4_ER.Checked = True
                    ER_BileReasonsDiv4.Style("display") = "normal"
                    cboBileReasons4_ER.SelectedValue = GetNumber(VisRecord.MajorPapillaBileReason_ER)
            End Select

            Select Case GetNumber(VisRecord.MajorPapillaPancreatic_ER)
                Case 1
                    optPan1_ER.Checked = True
                    ER_PancreaticReasonsDiv1.Style("display") = "normal"
                    cboPancreaticReasons1_ER.SelectedValue = GetNumber(VisRecord.MajorPapillaPancreaticReason_ER)
                Case 2
                    optPan2_ER.Checked = True
                    ER_PancreaticReasonsDiv2.Style("display") = "normal"
                    cboPancreaticReasons2_ER.SelectedValue = GetNumber(VisRecord.MajorPapillaPancreaticReason_ER)
                Case 3
                    optPan3_ER.Checked = True
                Case 4
                    optPan4_ER.Checked = True
                    ER_PancreaticReasonsDiv4.Style("display") = "normal"
                    cboPancreaticReasons4_ER.SelectedValue = GetNumber(VisRecord.MajorPapillaPancreaticReason_ER)
            End Select

            Select Case GetNumber(VisRecord.MinorPapilla_ER)
                Case 1
                    optMinorPap1_ER.Checked = True

                    ER_MinorPapReasonsDiv1.Style("display") = "normal" '#### to do
                    cboMinorPapReasons1_ER.SelectedValue = GetNumber(VisRecord.MinorPapillaReason_ER)
                Case 2
                    optMinorPap2_ER.Checked = True
                    ER_MinorPapReasonsDiv2.Style("display") = "normal"
                    cboMinorPapReasons2_ER.SelectedValue = GetNumber(VisRecord.MinorPapillaReason_ER)
                Case 3
                    optMinorPap3_ER.Checked = True
                Case 4
                    optMinorPap4_ER.Checked = True
                    ER_MinorPapReasonsDiv4.Style("display") = "normal"
                    cboMinorPapReasons4_ER.SelectedValue = GetNumber(VisRecord.MinorPapillaReason_ER)
            End Select
            Abandoned_ER_CheckBox.Checked = GetBoolean(VisRecord.Abandoned_ER)
            IntendedBileDuct_ER_CheckBox.Checked = GetBoolean(VisRecord.IntendedBileDuct_ER)
            IntendedPancreaticDuct_ER_CheckBox.Checked = GetBoolean(VisRecord.IntendedPancreaticDuct_ER)
            '#### TrainER Cannulation Fields!


            'If bFirstERCP Then
            '    IntendedDuctTD.Style("display") = "normal"
            '    IntendedDuct_ER_TD.Style("display") = "normal"
            'Else
            '    AbandonedTD.ColSpan = 2
            '    Abandoned_ER_TD.ColSpan = 2
            'End If

            chkHVNotVisualised.Checked = GetBoolean(VisRecord.HepatobiliaryNotVisualised)
            If GetBoolean(VisRecord.HepatobiliaryNotVisualised) Then limitedtable.Style("display") = "normal"
            chkHVWholeBiliary.Checked = GetBoolean(VisRecord.HepatobiliaryWholeBiliary)
            If GetBoolean(VisRecord.HepatobiliaryWholeBiliary) Then AcinarTR.Style("display") = "normal"
            chkExcept1.Checked = GetBoolean(VisRecord.ExceptBileDuct)
            chkExcept2.Checked = GetBoolean(VisRecord.ExceptGallBladder)
            chkExcept3.Checked = GetBoolean(VisRecord.ExceptCommonHepaticDuct)
            chkExcept4.Checked = GetBoolean(VisRecord.ExceptRightHepaticDuct)
            chkExcept5.Checked = GetBoolean(VisRecord.ExceptLeftHepaticDuct)
            chkAcinar1.Checked = GetBoolean(VisRecord.HepatobiliaryAcinarFilling)
            If GetBoolean(VisRecord.HepatobiliaryAcinarFilling) Then AcinarTR.Style("display") = "normal"
            Select Case GetNumber(VisRecord.HepatobiliaryLimitedBy)
                Case 1
                    optLB1.Checked = True
                    limitedtable.Style("display") = "normal"
                Case 2
                    optLB2.Checked = True
                    limitedtable.Style("display") = "normal"
                    optLB2Div.Style("display") = "normal"
                    optLB2ComboBox.SelectedValue = GetString(VisRecord.HepatobiliaryLimitedByOtherText) '### something wrong!
            End Select
            pNotVisualisedCheckBox.Checked = GetBoolean(VisRecord.PancreaticNotVisualised)
            If VisRecord.PancreaticNotVisualised Then limitedtable1.Style("display") = "normal"
            PancreasCheckBox.Checked = GetBoolean(VisRecord.PancreaticDivisum)
            WholeCheckBox.Checked = GetBoolean(VisRecord.PancreaticWhole)
            If GetBoolean(VisRecord.PancreaticWhole) Then chkAcinar2TR.Style("display") = "normal"
            ExceptCheckBox1.Checked = GetBoolean(VisRecord.ExceptAccesoryPancreatic)
            ExceptCheckBox2.Checked = GetBoolean(VisRecord.ExceptMainPancreatic)
            ExceptCheckBox3.Checked = GetBoolean(VisRecord.ExceptUncinate)
            ExceptCheckBox4.Checked = GetBoolean(VisRecord.ExceptHead)
            ExceptCheckBox5.Checked = GetBoolean(VisRecord.ExceptNeck)
            ExceptCheckBox6.Checked = GetBoolean(VisRecord.ExceptBody)
            ExceptCheckBox7.Checked = GetBoolean(VisRecord.ExceptTail)
            chkAcinar2.Checked = GetBoolean(VisRecord.PancreaticAcinar)
            If VisRecord.PancreaticAcinar Then chkAcinar2TR.Style("display") = "normal"
            Select Case GetNumber(VisRecord.PancreaticLimitedBy)
                Case 1
                    optLimitedByPVButton.Checked = True
                    limitedtable1.Style("display") = "normal"
                Case 2
                    optOtherButton.Checked = True
                    optOtherDiv.Style("display") = "normal"
                    limitedtable1.Style("display") = "normal"
                    optOtherComboBox.SelectedValue = GetNumber(VisRecord.PancreaticLimitedByOtherText)
            End Select
            HepatobiliaryFirstComboBox.SelectedValue = GetNumber(VisRecord.HepatobiliaryFirst)
            HepatobiliaryFirstMLTextBox.Text = GetNumber(VisRecord.HepatobiliaryFirstML)
            HepatobiliarySecondComboBox.SelectedValue = GetNumber(VisRecord.HepatobiliarySecond)
            HepatobiliarySecondMLRadTextBox.Text = GetNumber(VisRecord.HepatobiliarySecondML)
            HepatobiliaryBalloonCheckBox.Checked = GetBoolean(VisRecord.HepatobiliaryBalloon)
            PancreaticFirstComboBox.SelectedValue = GetNumber(VisRecord.PancreaticFirst)
            PancreaticFirstMLTextBox.Text = GetNumber(VisRecord.PancreaticFirstML)
            PancreaticSecondComboBox.SelectedValue = GetNumber(VisRecord.PancreaticSecond)
            PancreaticSecondMLTextBox.Text = GetNumber(VisRecord.PancreaticSecondML)
            PancreaticBalloonCheckBox.Checked = GetBoolean(VisRecord.PancreaticBalloon)

            DuodenumNormalCheckBox.Checked=GetBoolean(VisRecord.DuodenumNormal)
            DuodenumNotEnteredCheckBox.Checked=GetBoolean(VisRecord.DuodenumNotEntered)
            Duodenum2ndPartNotEnteredCheckBox.Checked = GetBoolean(VisRecord.Duodenum2ndPartNotEntered)
            AmupllaNotEnteredCheckBox.Checked = GetBoolean(VisRecord.AmpullaNotVisualised)
        Else
            NEW_RECORD = True
        End If
    End Sub

    Sub Fill_Record_Object()
        Dim od As New DataAccess

        VisRecord = New ERS.Data.ERS_Visualisation '### Make a new Instance.. and Fill it up with values.. 
        VisRecord.ProcedureID = PROCEDURE_ID '### Preparing for INSERT or UPDATE -> in any case feed the ProcedureId.. remember this is a new Instance Object- empty! Feed it...

        If Not NEW_RECORD Then VisRecord.ID = currentVisRecordId '### I know its an Existing Record.. need to UPDATE only! Use the UniqueRecordId stored when the Form loaded!

        If optAV1.Checked Then
            VisRecord.AccessVia = 1
        ElseIf optVA2.Checked Then
            VisRecord.AccessVia = 2
            If Trim(cboAccessViaOther.Text) <> "" Then VisRecord.AccessViaOtherText = ValInsertListItem(od, cboAccessViaOther, "ERCP other access point") Else VisRecord.AccessViaOtherText = Nothing
        Else
            VisRecord.AccessVia = Nothing
            VisRecord.AccessViaOtherText = Nothing
        End If


        '#### TrainEE Cannulation Values.....
        VisRecord.Abandoned = AbandonedCheckBox.Checked

        '#### TrainEE Intended duct for Cannulation .....
        VisRecord.IntendedBileDuct = IntendedBileDuctCheckBox.Checked
        VisRecord.IntendedPancreaticDuct = IntendedPancreaticDuctCheckBox.Checked

        '--Cannulation via major papilla to bile duct was..
        If optBile1.Checked Then
            VisRecord.MajorPapillaBile = 1
            'cboBileReasons1.SelectedValue = od.InsertListItem("ERCP via major to bile successful using", cboBileReasons1.Text)
            If Trim(cboBileReasons1.Text) <> "" Then VisRecord.MajorPapillaBileReason = ValInsertListItem(od, cboBileReasons1, "ERCP via major to bile successful using") Else VisRecord.MajorPapillaBileReason = Nothing
        ElseIf optBile2.Checked Then
            VisRecord.MajorPapillaBile = 2
            If Trim(cboBileReasons2.Text) <> "" Then VisRecord.MajorPapillaBileReason = ValInsertListItem(od, cboBileReasons2, "ERCP via major to bile partially successful reason") Else VisRecord.MajorPapillaBileReason = Nothing
        ElseIf optBile3.Checked Then
            VisRecord.MajorPapillaBile = 3
            VisRecord.MajorPapillaBileReason = Nothing
        ElseIf optBile4.Checked Then
            VisRecord.MajorPapillaBile = 4
            If Trim(cboBileReasons4.Text) <> "" Then VisRecord.MajorPapillaBileReason = ValInsertListItem(od, cboBileReasons4, "ERCP via major to bile unsuccessful due to") Else VisRecord.MajorPapillaBileReason = Nothing
            'cboBileReasons4.SelectedValue = od.InsertListItem("ERCP via major to bile unsuccessful due to", cboBileReasons4.Text)
        Else
            VisRecord.MajorPapillaBile = Nothing
            VisRecord.MajorPapillaBileReason = Nothing
        End If

        '-- Cannulation via major papilla to pancreatic duct was..
        If optPan1.Checked Then
            VisRecord.MajorPapillaPancreatic = 1
            If Trim(cboPancreaticReasons1.Text) <> "" Then VisRecord.MajorPapillaPancreaticReason = ValInsertListItem(od, cboPancreaticReasons1, "ERCP via major to pancreatic successful using") Else VisRecord.MajorPapillaPancreaticReason = Nothing
            'cboPancreaticReasons1.SelectedValue = od.InsertListItem("ERCP via major to pancreatic successful using", cboPancreaticReasons1.Text)
        ElseIf optPan2.Checked Then
            VisRecord.MajorPapillaPancreatic = 2
            If Trim(cboPancreaticReasons2.Text) <> "" Then VisRecord.MajorPapillaPancreaticReason = ValInsertListItem(od, cboPancreaticReasons2, "ERCP via major to pancreatic partially successful reason") Else VisRecord.MajorPapillaPancreaticReason = Nothing
            'cboPancreaticReasons2.SelectedValue = od.InsertListItem("ERCP via major to pancreatic partially successful reason", cboPancreaticReasons2.Text)
        ElseIf optPan3.Checked Then
            VisRecord.MajorPapillaPancreatic = 3
            VisRecord.MajorPapillaPancreaticReason = Nothing
        ElseIf optPan4.Checked Then
            VisRecord.MajorPapillaPancreatic = 4
            If Trim(cboPancreaticReasons4.Text) <> "" Then VisRecord.MajorPapillaPancreaticReason = ValInsertListItem(od, cboPancreaticReasons4, "ERCP via major to pancreatic unsuccessful due to") Else VisRecord.MajorPapillaPancreaticReason = Nothing
            'cboPancreaticReasons4.SelectedValue = od.InsertListItem("ERCP via major to pancreatic unsuccessful due to", cboPancreaticReasons4.Text)
        Else
            VisRecord.MajorPapillaPancreatic = Nothing
            VisRecord.MajorPapillaPancreaticReason = Nothing
        End If

        '-- Cannulation via minor papilla
        If optMinorPap1.Checked Then
            VisRecord.MinorPapilla = 1
            If Trim(cboMinorPapReasons1.Text) <> "" Then VisRecord.MinorPapillaReason = ValInsertListItem(od, cboMinorPapReasons1, "ERCP via minor successful using to") Else VisRecord.MinorPapillaReason = Nothing
            'cboMinorPapReasons1.SelectedValue = od.InsertListItem("ERCP via minor successful using to", cboMinorPapReasons1.Text)
        ElseIf optMinorPap2.Checked Then
            VisRecord.MinorPapilla = 2
            If Trim(cboMinorPapReasons2.Text) <> "" Then VisRecord.MinorPapillaReason = ValInsertListItem(od, cboMinorPapReasons2, "ERCP via minor partially successful reason") Else VisRecord.MinorPapillaReason = Nothing
            'cboMinorPapReasons2.SelectedValue = od.InsertListItem("ERCP via minor partially successful reason", cboMinorPapReasons2.Text)
        ElseIf optMinorPap3.Checked Then
            VisRecord.MinorPapilla = 3
            VisRecord.MinorPapillaReason = Nothing
        ElseIf optMinorPap4.Checked Then
            VisRecord.MinorPapilla = 4
            If Trim(cboMinorPapReasons4.Text) <> "" Then VisRecord.MinorPapillaReason = ValInsertListItem(od, cboMinorPapReasons4, "ERCP via minor unsuccessful due to") Else VisRecord.MinorPapillaReason = Nothing
            'cboMinorPapReasons4.SelectedValue = od.InsertListItem("ERCP via minor unsuccessful due to", cboMinorPapReasons4.Text)
        Else
            VisRecord.MinorPapilla = Nothing
            VisRecord.MinorPapillaReason = Nothing
        End If

        '#### TrainER Cannulation Values.....
        VisRecord.Abandoned_ER = Abandoned_ER_CheckBox.Checked

        '#### TrainER Intended duct for Cannulation .....
        VisRecord.IntendedBileDuct_ER = IntendedBileDuct_ER_CheckBox.Checked
        VisRecord.IntendedPancreaticDuct_ER = IntendedPancreaticDuct_ER_CheckBox.Checked

        '--Trainer - Cannulation via major papilla to bile duct was..
        If optBile1_ER.Checked Then
            VisRecord.MajorPapillaBile_ER = 1
            If Trim(cboBileReasons1_ER.Text) <> "" Then VisRecord.MajorPapillaBileReason_ER = ValInsertListItem(od, cboBileReasons1_ER, "ERCP via major to bile successful using") Else VisRecord.MajorPapillaBileReason_ER = Nothing
            'cboBileReasons1_ER.SelectedValue = od.InsertListItem("ERCP via major to bile successful using", cboBileReasons1_ER.Text)
        ElseIf optBile2_ER.Checked Then
            VisRecord.MajorPapillaBile_ER = 2
            If Trim(cboBileReasons2_ER.Text) <> "" Then VisRecord.MajorPapillaBileReason_ER = ValInsertListItem(od, cboBileReasons2_ER, "ERCP via major to bile partially successful reason") Else VisRecord.MajorPapillaBileReason_ER = Nothing
            'cboBileReasons2_ER.SelectedValue = od.InsertListItem("ERCP via major to bile partially successful reason", cboBileReasons2_ER.Text)
        ElseIf optBile3_ER.Checked Then
            VisRecord.MajorPapillaBile_ER = 3
            VisRecord.MajorPapillaBileReason_ER = Nothing
        ElseIf optBile4_ER.Checked Then
            VisRecord.MajorPapillaBile_ER = 4
            If Trim(cboBileReasons4_ER.Text) <> "" Then VisRecord.MajorPapillaBileReason_ER = ValInsertListItem(od, cboBileReasons4_ER, "ERCP via major to bile unsuccessful due to") Else VisRecord.MajorPapillaBileReason_ER = Nothing
            'cboBileReasons4_ER.SelectedValue = od.InsertListItem("ERCP via major to bile unsuccessful due to", cboBileReasons4_ER.Text)
        Else
            VisRecord.MajorPapillaBile_ER = Nothing
            VisRecord.MajorPapillaBileReason_ER = Nothing
        End If


        '--Trainer - Cannulation via major papilla to pancreatic duct was..
        If optPan1_ER.Checked Then
            VisRecord.MajorPapillaPancreatic_ER = 1
            If Trim(cboPancreaticReasons1_ER.Text) <> "" Then VisRecord.MajorPapillaPancreaticReason_ER = ValInsertListItem(od, cboPancreaticReasons1_ER, "ERCP via major to pancreatic successful using") Else VisRecord.MajorPapillaPancreaticReason_ER = Nothing
            'cboPancreaticReasons1_ER.SelectedValue = od.InsertListItem("ERCP via major to pancreatic successful using", cboPancreaticReasons1_ER.Text)
        ElseIf optPan2_ER.Checked Then
            VisRecord.MajorPapillaPancreatic_ER = 2
            If Trim(cboPancreaticReasons2_ER.Text) <> "" Then VisRecord.MajorPapillaPancreaticReason_ER = ValInsertListItem(od, cboPancreaticReasons2_ER, "ERCP via major to pancreatic partially successful reason") Else VisRecord.MajorPapillaPancreaticReason_ER = Nothing

            'cboPancreaticReasons2_ER.SelectedValue = od.InsertListItem("ERCP via major to pancreatic partially successful reason", cboPancreaticReasons2_ER.Text)
        ElseIf optPan3_ER.Checked Then
            VisRecord.MajorPapillaPancreatic_ER = 3
            VisRecord.MajorPapillaPancreaticReason_ER = Nothing
        ElseIf optPan4_ER.Checked Then
            VisRecord.MajorPapillaPancreatic_ER = 4
            If Trim(cboPancreaticReasons4_ER.Text) <> "" Then VisRecord.MajorPapillaPancreaticReason_ER = ValInsertListItem(od, cboPancreaticReasons4_ER, "ERCP via major to pancreatic unsuccessful due to") Else VisRecord.MajorPapillaPancreaticReason_ER = Nothing
            'cboPancreaticReasons4_ER.SelectedValue = od.InsertListItem("ERCP via major to pancreatic unsuccessful due to", cboPancreaticReasons4_ER.Text)
        Else
            VisRecord.MajorPapillaPancreatic_ER = Nothing
            VisRecord.MajorPapillaPancreaticReason_ER = Nothing
        End If


        '--Trainer - Cannulation via major papilla to bile duct was..
        If optMinorPap1_ER.Checked Then
            VisRecord.MinorPapilla_ER = 1
            If Trim(cboMinorPapReasons1_ER.Text) <> "" Then VisRecord.MinorPapillaReason_ER = ValInsertListItem(od, cboMinorPapReasons1_ER, "ERCP via minor successful using to") Else VisRecord.MinorPapillaReason_ER = Nothing
            'cboMinorPapReasons1_ER.SelectedValue = od.InsertListItem("ERCP via minor successful using to", cboMinorPapReasons1_ER.Text)
        ElseIf optMinorPap2_ER.Checked Then
            VisRecord.MinorPapilla_ER = 2
            If Trim(cboMinorPapReasons2_ER.Text) <> "" Then VisRecord.MinorPapillaReason_ER = ValInsertListItem(od, cboMinorPapReasons2_ER, "ERCP via minor partially successful reason") Else VisRecord.MinorPapillaReason_ER = Nothing
            'cboMinorPapReasons2_ER.SelectedValue = od.InsertListItem("ERCP via minor partially successful reason", cboMinorPapReasons2_ER.Text)
        ElseIf optMinorPap3_ER.Checked Then
            VisRecord.MinorPapilla_ER = 3
            VisRecord.MinorPapillaReason_ER = Nothing
        ElseIf optMinorPap4_ER.Checked Then
            VisRecord.MinorPapilla_ER = 4
            If Trim(cboMinorPapReasons4_ER.Text) <> "" Then VisRecord.MinorPapillaReason_ER = ValInsertListItem(od, cboMinorPapReasons4_ER, "ERCP via minor unsuccessful due to") Else VisRecord.MinorPapillaReason_ER = Nothing
            'cboMinorPapReasons4_ER.SelectedValue = od.InsertListItem("ERCP via minor unsuccessful due to", cboMinorPapReasons4_ER.Text)
        Else
            VisRecord.MinorPapilla_ER = Nothing
            VisRecord.MinorPapillaReason_ER = Nothing
        End If


        '### Visualisation Common Data!
        If optLB1.Checked Then
            VisRecord.HepatobiliaryLimitedBy = 1
        ElseIf optLB2.Checked Then
            VisRecord.HepatobiliaryLimitedBy = 2
            If Trim(optLB2ComboBox.Text) <> "" Then VisRecord.HepatobiliaryLimitedByOtherText = ValInsertListItem(od, optLB2ComboBox, "ERCP extent of visualisation limited by other") Else VisRecord.HepatobiliaryLimitedByOtherText = Nothing
        Else
            VisRecord.HepatobiliaryLimitedBy = Nothing
            VisRecord.HepatobiliaryLimitedByOtherText = Nothing
        End If
        'VisRecord.HepatobiliaryLimitedByOtherText = optLB2ComboBox.SelectedValue

        If optLimitedByPVButton.Checked Then
            VisRecord.PancreaticLimitedBy = 1
        ElseIf optOtherButton.Checked Then
            VisRecord.PancreaticLimitedBy = 2
            If Trim(optOtherComboBox.Text) <> "" Then VisRecord.PancreaticLimitedByOtherText = ValInsertListItem(od, optOtherComboBox, "ERCP extent of visualisation limited by other") Else VisRecord.PancreaticLimitedByOtherText = Nothing
        Else
            VisRecord.PancreaticLimitedBy = Nothing
            VisRecord.PancreaticLimitedByOtherText = Nothing
        End If

        'cboAccessViaOther.SelectedValue = od.InsertListItem("ERCP other access point", cboAccessViaOther.Text)
        'optLB2ComboBox.SelectedValue = od.InsertListItem("ERCP extent of visualisation limited by other", optLB2ComboBox.Text)
        'optOtherComboBox.SelectedValue = od.InsertListItem("ERCP extent of visualisation limited by other", optOtherComboBox.Text)

        VisRecord.HepatobiliaryNotVisualised = chkHVNotVisualised.Checked
        VisRecord.HepatobiliaryWholeBiliary = chkHVWholeBiliary.Checked
        VisRecord.ExceptBileDuct = chkExcept1.Checked
        VisRecord.ExceptGallBladder = chkExcept2.Checked
        VisRecord.ExceptCommonHepaticDuct = chkExcept3.Checked
        VisRecord.ExceptRightHepaticDuct = chkExcept4.Checked
        VisRecord.ExceptLeftHepaticDuct = chkExcept5.Checked
        VisRecord.HepatobiliaryAcinarFilling = chkAcinar1.Checked

        'If optLB1.Checked Then
        '    VisRecord.HepatobiliaryLimitedBy = 1
        'Else
        '    VisRecord.HepatobiliaryLimitedBy = 0
        'End If
        'VisRecord.HepatobiliaryLimitedByOtherText = optLB2ComboBox.SelectedValue

        VisRecord.PancreaticNotVisualised = pNotVisualisedCheckBox.Checked

        VisRecord.PancreaticDivisum = PancreasCheckBox.Checked
        VisRecord.PancreaticWhole = WholeCheckBox.Checked
        VisRecord.ExceptAccesoryPancreatic = ExceptCheckBox1.Checked
        VisRecord.ExceptMainPancreatic = ExceptCheckBox2.Checked
        VisRecord.ExceptUncinate = ExceptCheckBox3.Checked
        VisRecord.ExceptHead = ExceptCheckBox4.Checked
        VisRecord.ExceptNeck = ExceptCheckBox5.Checked
        VisRecord.ExceptBody = ExceptCheckBox6.Checked
        VisRecord.ExceptTail = ExceptCheckBox7.Checked
        VisRecord.PancreaticAcinar = chkAcinar2.Checked
        'chkAcinar2.Checked = GetBoolean(VisRecord.PancreaticAcinar)

        'If optLimitedByPVButton.Checked Then
        '    VisRecord.PancreaticLimitedBy = 1
        'Else
        '    VisRecord.PancreaticLimitedBy = 0
        'End If

        'VisRecord.PancreaticLimitedByOtherText = optOtherComboBox.SelectedValue

        'HepatobiliaryFirstComboBox.SelectedValue = IIf(HepatobiliaryFirstComboBox.Text = "", 0, od.InsertListItem("ERCP contrast media used", HepatobiliaryFirstComboBox.Text))
        'HepatobiliarySecondComboBox.SelectedValue = IIf(HepatobiliarySecondComboBox.Text = "", 0, od.InsertListItem("ERCP contrast media used", HepatobiliarySecondComboBox.Text))
        'PancreaticFirstComboBox.SelectedValue = IIf(PancreaticFirstComboBox.Text = "", 0, od.InsertListItem("ERCP contrast media used", PancreaticFirstComboBox.Text))
        'PancreaticSecondComboBox.SelectedValue = IIf(PancreaticSecondComboBox.Text = "", 0, od.InsertListItem("ERCP contrast media used", PancreaticSecondComboBox.Text))
        If Trim(HepatobiliaryFirstComboBox.Text) <> "" Then VisRecord.HepatobiliaryFirst = ValInsertListItem(od, HepatobiliaryFirstComboBox, "ERCP contrast media used") Else VisRecord.HepatobiliaryFirst = Nothing
        VisRecord.HepatobiliaryFirstML = HepatobiliaryFirstMLTextBox.Text

        If Trim(HepatobiliarySecondComboBox.Text) <> "" Then VisRecord.HepatobiliarySecond = ValInsertListItem(od, HepatobiliarySecondComboBox, "ERCP contrast media used") Else VisRecord.HepatobiliarySecond = Nothing

        VisRecord.HepatobiliarySecondML = HepatobiliarySecondMLRadTextBox.Text
        VisRecord.HepatobiliaryBalloon = HepatobiliaryBalloonCheckBox.Checked

        If Trim(PancreaticFirstComboBox.Text) <> "" Then VisRecord.PancreaticFirst = ValInsertListItem(od, PancreaticFirstComboBox, "ERCP contrast media used") Else VisRecord.PancreaticFirst = Nothing

        VisRecord.PancreaticFirstML = PancreaticFirstMLTextBox.Text

        If Trim(PancreaticSecondComboBox.Text) <> "" Then VisRecord.PancreaticSecond = ValInsertListItem(od, PancreaticSecondComboBox, "ERCP contrast media used") Else VisRecord.PancreaticSecond = Nothing

        VisRecord.PancreaticSecondML = PancreaticSecondMLTextBox.Text
        VisRecord.PancreaticBalloon = PancreaticBalloonCheckBox.Checked

        VisRecord.DuodenumNormal=DuodenumNormalCheckBox.Checked
        VisRecord.DuodenumNotEntered = DuodenumNotEnteredCheckBox.Checked
        VisRecord.Duodenum2ndPartNotEntered = Duodenum2ndPartNotEnteredCheckBox.Checked
        VisRecord.AmpullaNotVisualised = AmupllaNotEnteredCheckBox.Checked

        'HepatobiliaryFirstComboBox.SelectedValue = IIf(HepatobiliaryFirstComboBox.Text = "", 0, od.InsertToERSList("ERCP contrast media used", HepatobiliaryFirstComboBox.Text))
        'HepatobiliarySecondComboBox.SelectedValue = IIf(HepatobiliarySecondComboBox.Text = "", 0, od.InsertToERSList("ERCP contrast media used", HepatobiliarySecondComboBox.Text))
        'PancreaticFirstComboBox.SelectedValue = IIf(PancreaticFirstComboBox.Text = "", 0, od.InsertToERSList("ERCP contrast media used", PancreaticFirstComboBox.Text))
        'PancreaticSecondComboBox.SelectedValue = IIf(PancreaticSecondComboBox.Text = "", 0, od.InsertToERSList("ERCP contrast media used", PancreaticSecondComboBox.Text))

    End Sub

    ''' <summary>
    ''' This will validate the selected value of combobox before inserting.
    ''' </summary>
    Private Function ValInsertListItem(da As DataAccess, ByVal combobox As RadComboBox, ByVal listDescription As String) As Integer

        Dim itemName As String = combobox.Text
        'If Trim(itemName) = "" Then Return Nothing

        If combobox.SelectedValue = "-99" Then  'new item
            'Insert only if new item
            Dim iSelValue As Integer = da.InsertListItem(listDescription, itemName)
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{combobox, listDescription}})
            combobox.SelectedItem.Text = itemName
            combobox.SelectedValue = iSelValue ' da.InsertListItem(listDescription, itemName)
        End If

        Return combobox.SelectedValue

    End Function

    Private Function GetBoolean(ByVal fieldValue As Object) As Boolean
        Return IIf(fieldValue Is Nothing, False, CBool(fieldValue))
    End Function

    ''' <summary>
    ''' This will handle the Numeric value in the Entity Object of the Visualisation Record.
    ''' Most of the fields are NULLable- so handle them before assigning to the control or read them in IF() logic!
    ''' </summary>
    ''' <param name="fieldValue">Record data value</param>
    ''' <returns>0 for NOTHING, else valid numeric data</returns>
    ''' <remarks></remarks>
    Private Function GetNumber(ByVal fieldValue As Object) As Integer
        If fieldValue Is Nothing Then
            Return 0
        ElseIf String.IsNullOrEmpty(fieldValue) Then
            Return 0
        Else
            Return CInt(fieldValue)
        End If
    End Function

    Private Function GetString(ByVal fieldValue As Object) As String
        If fieldValue Is Nothing Then
            Return ""
        Else
            Return fieldValue.ToString()
        End If
    End Function

    Sub LoadLookupComboBoxes()



        'Dim values As New List(Of Dictionary(Of RadComboBox, String))()

        'Dim rows As New List(Of Dictionary(Of String, Object))
        'Dim row As Dictionary(Of String, Object)

        'For Each dr As DataRow In dt.Rows
        '    row = New Dictionary(Of String, Object)
        '    For Each col As DataColumn In dt.Columns
        '        row.Add(col.ColumnName, dr(col))
        '    Next
        '    rows.Add(row)
        'Next

        'values.Add(New Dictionary(Of RadComboBox, String)() From {{cboAccessViaOther, "ERCP other access point"}})
        'BindLookupSource_Arr(New Dictionary(Of RadComboBox, String)() From {{HepatobiliaryFirstComboBox, "ERCP contrast media used"}, {optOtherComboBox, "ERCP extent of visualisation limited by other"}})
        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                            {cboAccessViaOther, "ERCP other access point"},
                            {optLB2ComboBox, "ERCP extent of visualisation limited by other"},
                            {optOtherComboBox, "ERCP extent of visualisation limited by other"},
                            {HepatobiliaryFirstComboBox, "ERCP contrast media used"},
                            {HepatobiliarySecondComboBox, "ERCP contrast media used"},
                            {PancreaticFirstComboBox, "ERCP contrast media used"},
                            {PancreaticSecondComboBox, "ERCP contrast media used"},
                            {cboBileReasons1, "ERCP via major to bile successful using"},
                            {cboBileReasons2, "ERCP via major to bile partially successful reason"},
                            {cboBileReasons4, "ERCP via major to bile unsuccessful due to"},
                            {cboPancreaticReasons1, "ERCP via major to pancreatic successful using"},
                            {cboPancreaticReasons2, "ERCP via major to pancreatic partially successful reason"},
                            {cboPancreaticReasons4, "ERCP via major to pancreatic unsuccessful due to"},
                            {cboMinorPapReasons1, "ERCP via minor successful using to"},
                            {cboMinorPapReasons2, "ERCP via minor partially successful reason"},
                            {cboMinorPapReasons4, "ERCP via minor unsuccessful due to"},
                            {cboBileReasons1_ER, "ERCP via major to bile successful using"},
                            {cboBileReasons2_ER, "ERCP via major to bile partially successful reason"},
                            {cboBileReasons4_ER, "ERCP via major to bile unsuccessful due to"},
                            {cboPancreaticReasons1_ER, "ERCP via major to pancreatic successful using"},
                            {cboPancreaticReasons2_ER, "ERCP via major to pancreatic partially successful reason"},
                            {cboPancreaticReasons4_ER, "ERCP via major to pancreatic unsuccessful due to"},
                            {cboMinorPapReasons1_ER, "ERCP via minor successful using to"},
                            {cboMinorPapReasons2_ER, "ERCP via minor partially successful reason"},
                            {cboMinorPapReasons4_ER, "ERCP via minor unsuccessful due to"}
                    })




        ''### Access via
        'BindLookupSource(cboAccessViaOther, "ERCP other access point", firstLoad:=True)
        ''### Extent of hepatobiliary visualisation
        'BindLookupSource(optLB2ComboBox, "ERCP extent of visualisation limited by other")
        ''### Extent of pancreatic visualisation
        ''BindLookupSource(optOtherComboBox, "ERCP extent of visualisation limited by other")
        ''### Contrast media used
        '' BindLookupSource(HepatobiliaryFirstComboBox, "ERCP contrast media used")
        'BindLookupSource(HepatobiliarySecondComboBox, "ERCP contrast media used")
        'BindLookupSource(PancreaticFirstComboBox, "ERCP contrast media used")
        'BindLookupSource(PancreaticSecondComboBox, "ERCP contrast media used")

        ''### TrainEE
        ''BindLookupSource(cboBileReasons1, "ERCP via major to bile successful using")
        'BindLookupSource(cboBileReasons2, "ERCP via major to bile partially successful reason")
        'BindLookupSource(cboBileReasons4, "ERCP via major to bile unsuccessful due to")
        'BindLookupSource(cboPancreaticReasons1, "ERCP via major to pancreatic successful using")
        'BindLookupSource(cboPancreaticReasons2, "ERCP via major to pancreatic partially successful reason")
        'BindLookupSource(cboPancreaticReasons4, "ERCP via major to pancreatic unsuccessful due to")
        'BindLookupSource(cboMinorPapReasons1, "ERCP via minor successful using to")
        'BindLookupSource(cboMinorPapReasons2, "ERCP via minor partially successful reason")
        'BindLookupSource(cboMinorPapReasons4, "ERCP via minor unsuccessful due to")

        ''### TrainEE
        'BindLookupSource(cboBileReasons1_ER, "ERCP via major to bile successful using")
        'BindLookupSource(cboBileReasons2_ER, "ERCP via major to bile partially successful reason")
        'BindLookupSource(cboBileReasons4_ER, "ERCP via major to bile unsuccessful due to")
        'BindLookupSource(cboPancreaticReasons1_ER, "ERCP via major to pancreatic successful using")
        'BindLookupSource(cboPancreaticReasons2_ER, "ERCP via major to pancreatic partially successful reason")
        'BindLookupSource(cboPancreaticReasons4_ER, "ERCP via major to pancreatic unsuccessful due to")
        'BindLookupSource(cboMinorPapReasons1_ER, "ERCP via minor successful using to")
        'BindLookupSource(cboMinorPapReasons2_ER, "ERCP via minor partially successful reason")
        'BindLookupSource(cboMinorPapReasons4_ER, "ERCP via minor unsuccessful due to", firstLoad:=False, disposeCollection:=True)

    End Sub

    'Sub BindLookupSource(ByVal dropDownName As Global.Telerik.Web.UI.RadComboBox, ByVal listSource As String, Optional ByVal firstLoad As Boolean = False, Optional ByVal disposeCollection As Boolean = False)
    '    Utilities.LoadDropdown_Visualisation(dropDownName, listSource, firstLoad, disposeCollection)
    'End Sub

    'Sub BindLookupSource_Old(ByVal dropDownName As Global.Telerik.Web.UI.RadComboBox, ByVal listSource As String)
    '    Dim da As New DataAccess
    '    Utilities.LoadDropdown(dropDownName, da.GetDropDownList(listSource), "ListItemText", "ListItemNo", Nothing)
    'End Sub
End Class
