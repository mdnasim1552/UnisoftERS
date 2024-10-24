Imports Telerik.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI
Imports System.Web
Imports System.Drawing
Imports xls = Telerik.Web.UI.ExportInfrastructure
Imports System.IO
Imports System.Data.OleDb
Imports System.Linq
Imports System.Globalization
Imports System.Data.SqlClient
Imports System.Web.Services
Imports System.Net
Imports Telerik.Web.UI.GridExcelBuilder

Public Class JAGGRS
    Inherits OptionsBase

    Public SQLString As String = "SELECT ReportID As UserID, Consultant, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_Consultants Where Consultant<>'(None)'"
    Private Shared ReadOnly IndexRowItemStart As Integer = 1

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(RadButtonFilter, ReportPanel, RadAjaxLoadingPanel1)

        Dim myScriptMgr As ScriptManager = ScriptManager.GetCurrent(Me.Page)
        'myScriptMgr.RegisterPostBackControl(RadButtonExportGrids)

        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/", False)
        Else
            SUID.Value = Session("PKUserId").ToString
        End If
        If RDPFrom.SelectedDate.ToString = "" Then
            Me.LoadDefaultsFromDB()
        End If

        If Not Page.IsPostBack Then
            Session("ReportingOperatingHospitalIds") = Session("OperatingHospitalIdsForTrust")
            Dim da As New DataAccess

            '***************************************************************************************************************************
            'Hiding operating hospital control until reports work with it properly.
            OperatingHospitalsRadComboBox.DataSource = da.GetOperatingHospitals()
            OperatingHospitalsRadComboBox.DataTextField = "HospitalName"
            OperatingHospitalsRadComboBox.DataValueField = "OperatingHospitalId"
            OperatingHospitalsRadComboBox.DataBind()

            If OperatingHospitalsRadComboBox.Items.Count = 1 Then OperatingHospitalsRadComboBox.EnableCheckAllItemsCheckBox = False
            HospitalFilterDiv.Visible = True
            '***************************************************************************************************************************

            'If RadListBox1.Items.Count = 0 Then
            '    NoProceduresPanel.Visible = True
            '    ReportPanel.Visible = False
            'Else
            '    NoProceduresPanel.Visible = False
            '    ReportPanel.Visible = True
            'End If

            If da.CanViewAllUsers() Then
                ConsultantPanel.Disabled = False
            Else
                'consultantDataTable = BusinessLogic.GetConsultants("all", operatingHospitalsIds, HideSuppressed, searchPhrase)
                ConsultantPanel.Disabled = False
                RadListBox1.Enabled = True
                cbHideSuppressed.Enabled = False
                cbRandomize.Enabled = False
                ComboConsultants.Enabled = True
                ISMFilter.Enabled = False

                Dim userId = Session("PKUserId").ToString
                'Dim result = RadListBox1.Items.FirstOrDefault(Function(a) a.Value = userId)

                For Each item As RadListBoxItem In RadListBox1.Items
                    If item.Value = userId Then
                        item.Checked = True
                        Exit For
                    End If
                Next
            End If
            Utilities.LoadCheckBoxList(OtherAudits, da.GetOtherAuditReports("R"), "AuditReportDescription", "AuditReportId", True)
            cbHideSuppressed.Checked = True
        Else
            cbReports_exec(True)
        End If
    End Sub

#Region "Properties"
    Public Shared ReadOnly Property ConnectionStr() As String
        Get
            Return DataAccess.ConnectionStr
        End Get
    End Property


#End Region

#Region "Library"""
    Private pFromDate As String = ""
    Private pToDate As String = ""
    Private pTypeOfConsultant As Integer = 0
    Private pHideSuppressed As Boolean = False
    Private pGastroscopy As Boolean = False
    Private pPEGPEJ As Boolean = False
    Private pERCP As Boolean = False
    Private pColonoscopy As Boolean = False
    Private pSigmoidoscopy As Boolean = False
    Private pEUS As Boolean = False
    Private pBowel As Boolean = False
    Private pAnonymise As Boolean = False
    Private pFormulation As String = ""
    Public Property FromDate() As String
        Get
            Return pFromDate
        End Get
        Set(ByVal Value As String)
            pFromDate = Value
        End Set
    End Property
    Public Property ToDate() As String
        Get
            Return pToDate
        End Get
        Set(ByVal Value As String)
            pToDate = Value
        End Set
    End Property
    Public Property HideSuppressed() As Boolean
        Get
            Return pHideSuppressed
        End Get
        Set(ByVal Value As Boolean)
            pHideSuppressed = Value
        End Set
    End Property
    Public Property Gastroscopy() As Boolean
        Get
            Return pGastroscopy
        End Get
        Set(ByVal Value As Boolean)
            pGastroscopy = Value
        End Set
    End Property
    Public Property PEGPEJ() As Boolean
        Get
            Return pPEGPEJ
        End Get
        Set(ByVal Value As Boolean)
            pPEGPEJ = Value
        End Set
    End Property
    Public Property ERCP() As Boolean
        Get
            Return pERCP
        End Get
        Set(ByVal Value As Boolean)
            pERCP = Value
        End Set
    End Property
    Public Property Colonoscopy() As Boolean
        Get
            Return pColonoscopy
        End Get
        Set(ByVal Value As Boolean)
            pColonoscopy = Value
        End Set
    End Property
    Public Property Sigmoidoscopy() As Boolean
        Get
            Return pSigmoidoscopy
        End Get
        Set(ByVal Value As Boolean)
            pSigmoidoscopy = Value
        End Set
    End Property
    Public Property Bowel() As Boolean
        Get
            Return pBowel
        End Get
        Set(ByVal Value As Boolean)
            pBowel = Value
        End Set
    End Property
    Public Property Formulation() As String
        Get
            Return pFormulation
        End Get
        Set(ByVal Value As String)
            pFormulation = Value
        End Set
    End Property
    Public Property iTypeOfConsultant() As Integer
        Get
            Return pTypeOfConsultant
        End Get
        Set(ByVal Value As Integer)
            pTypeOfConsultant = Value
        End Set
    End Property
    Public Property Anonymise() As Boolean
        Get
            Return pAnonymise
        End Get
        Set(ByVal Value As Boolean)
            pAnonymise = Value
        End Set
    End Property

    Private Sub LoadDefaultsFromDB()
        Dim DT1 As New DataTable
        Dim DT2 As New DataTable
        Dim Row As DataRow
        Dim sqlQuery1 As String = ""
        Dim sqlQuery2 As String = ""
        Dim Sql As String = ""
        If Session("PKUserId") IsNot Nothing Then
            sqlQuery1 = "Select * From [dbo].[ERS_ReportFilter] Where UserID='" + Session("PKUserId").ToString + "'"
            DT1 = GetData(sqlQuery1)
            If DT1.Rows.Count = 0 Then
                Sql = "Insert Into ERS_ReportFilter (UserId, OGD, PEGPEJ, ERCP, Colonoscopy, Sigmoidoscopy, EUS, Bowel) Values (" + Session("PKUserId").ToString + ",0,0,0,0,0,0,0)"
                Reporting.Transaction(Sql)

            Else
                Sql = "Update [dbo].[ERS_ReportFilter] Set ReportDate=GetDate(), FromDate=Convert(Date,SubString('" + Reporting.FromDate + "',7,4)+'-'+SubString('" + Reporting.FromDate + "',4,2)+'-'+SubString('" + Reporting.FromDate + "',1,2)) , ToDate=Convert(Date,SubString('" + Reporting.ToDate + "',7,4)+'-'+SubString('" + Reporting.ToDate + "',4,2)+'-'+SubString('" + Reporting.ToDate + "',1,2)) "
                Sql = Sql + ", HideSuppressed='" + Reporting.HideSuppressed.ToString + "'"
                Sql = Sql + ", TrustId ='" + Session("TrustId") + "'"
                'sql = sql + ", TypesOfEndoscopists='" + Reporting.TypeOfConsultant.ToString + "'"
                Sql = Sql + " WHERE UserID = " + Session("PKUserID").ToString
                Reporting.Transaction(Sql)
                DT1 = GetData(sqlQuery1)

                Sql = "DELETE FROM ERS_ReportConsultants WHERE UserId = " & Session("PKUserID").ToString
                Reporting.Transaction(Sql)
            End If

            Reporting.CleanListBoxes(Session("PKUserId").ToString)
            Sql = "Insert Into [dbo].[ERS_ReportConsultants] (UserID, ConsultantID, AnonimizedID) "
            Sql = Sql + "Select UserID=" + Session("PKUserID").ToString + ", ConsultantID=ReportID, AnonimizedID=ReportID From [dbo].[v_rep_Consultants] Where ReportID In (0"
            For Each Item As RadListBoxItem In RadListBox1.CheckedItems
                Sql = Sql + "," + Item.Value.ToString
            Next
            Sql = Sql + ") " '+ sql2
            Reporting.Transaction(Sql)
            If Reporting.ErrorMsg <> "" Then
                MsgBox(Reporting.ErrorMsg)
            End If
            Dim operatingHospitalList As String = ""
            For Each Item As RadComboBoxItem In OperatingHospitalsRadComboBox.CheckedItems
                operatingHospitalList = operatingHospitalList + "," + Item.Value.ToString
            Next

            For Each Row In DT1.Rows
                Try
                    iTypeOfConsultant = 0 'Row("TypesOfEndoscopists").ToString
                    pFromDate = Row("FromDate").ToString
                    pToDate = Row("ToDate").ToString
                    pHideSuppressed = CBool(Row("HideSuppressed").ToString)
                    pGastroscopy = CBool(Row("OGD").ToString)
                    pSigmoidoscopy = CBool(Row("Sigmoidoscopy").ToString)
                    pERCP = CBool(Row("ERCP").ToString)
                    pEUS = CBool(Row("EUS").ToString)
                    pColonoscopy = CBool(Row("Colonoscopy").ToString)
                    pBowel = CBool(Row("Bowel").ToString)
                    pPEGPEJ = CBool(Row("PEGPEJ").ToString)
                    pAnonymise = CBool(Row("Anonymise").ToString)
                    operatingHospitalList = operatingHospitalList
                Catch ex As Exception
                    pFromDate = "01/01/2018"
                    pToDate = "30/12/2099"
                End Try
            Next Row
            'sqlQuery2 = "Select * From [dbo].[ERS_ReportConsultants] Where UserID='" + Session("PKUserId").ToString + "'"
            'DT2 = GetData(sqlQuery2)
            'If DT2.Rows.Count = 0 Then
            '    'CreateUserIDFilter(Session("PKUserId").ToString)
            '    DT2 = GetData(sqlQuery2)
            'End If
            'For Each Row In DT1.Rows

            'Next Row
        End If
        DT1.Dispose()
        DT2.Dispose()
        Try
            pFromDate = DateTime.Now.AddMonths(-6).ToString("dd/MM/yyyy")
            pToDate = DateTime.Now.ToString("dd/MM/yyyy")
            Me.RDPFrom.SelectedDate = pFromDate.ToString
            Me.RDPTo.SelectedDate = pToDate.ToString
        Catch ex As Exception
            RDPFrom.Culture = New CultureInfo("en-GB")
            RDPTo.Culture = New CultureInfo("en-GB")
            Me.RDPFrom.SelectedDate = "01/01/2018"
            Me.RDPTo.SelectedDate = "30/12/2099"
            pFromDate = DateTime.Now.AddMonths(-6).ToString("dd/MM/yyyy")
            pToDate = DateTime.Now.ToString("dd/MM/yyyy")
        End Try
        cbHideSuppressed.Checked = pHideSuppressed
        cbRandomize.Checked = pAnonymise
        ComboConsultants.SelectedIndex = iTypeOfConsultant

        'Fire event to populate listbox on initial load (AJ 26.6)
        ' TypeOfConsultant_SelectedIndexChanged(ComboConsultants, New EventArgs)

        cbReports.Items(0).Selected = pGastroscopy
        cbReports.Items(1).Selected = pPEGPEJ
        cbReports.Items(2).Selected = pERCP
        cbReports.Items(3).Selected = pSigmoidoscopy
        cbReports.Items(4).Selected = pColonoscopy
        'cbReports.Items(5).Selected = pBowel
        cbReports.Items(5).Selected = pEUS
        ComboConsultants.Items(0).Selected = True
        'cbReports_exec()
    End Sub
    Private Function GetData(ByVal sqlQuery As String) As DataTable
        Dim dsData As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlQuery, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Function GetSelectedHospitalIds() As String
        Dim operatingHospitalList As String = ""
        For Each Item As RadComboBoxItem In OperatingHospitalsRadComboBox.CheckedItems
            operatingHospitalList = operatingHospitalList + "," + Item.Value.ToString
        Next
        Return operatingHospitalList
    End Function
    Function GetValue(ByVal Qry As String) As String
        Dim str As String = ""
        Dim DT As DataTable = GetData(Qry)
        Dim Row As DataRow
        For Each Row In DT.Rows
            str = Row(0).ToString
            Exit For
        Next
        Return str
    End Function
    'Protected Sub CreateUserIDFilter(ByVal UserID As String)
    '    'Dim sql1 As String = "Delete [dbo].[ERS_ReportFilter] Where UserID In (0, " + Session("PKUserID").ToString + ")"
    '    'Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '    '    Dim cmd1 As New SqlCommand(sql1, connection)
    '    '    cmd1.CommandType = CommandType.Text
    '    '    cmd1.Connection.Open()
    '    '    cmd1.ExecuteNonQuery()
    '    'End Using
    '    Dim sql2 As String = "Insert Into [dbo].[ERS_ReportFilter] (UserID) Select UserID=" + Session("PKUserId").ToString
    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd2 As New SqlCommand(sql2, connection)
    '        cmd2.CommandType = CommandType.Text
    '        'cmd.Parameters.Add(New SqlParameter("@userId", UserID))
    '        cmd2.Connection.Open()
    '        cmd2.ExecuteNonQuery()
    '    End Using
    'End Sub
    Protected Sub SetUserIDFilter(ByVal UserID As String)
        ', ByVal FromDate As String, ByVal ToDate As String
        Try
            pFromDate = RDPFrom.SelectedDate
        Catch ex As Exception
            pFromDate = "01/01/2018"
        End Try
        Try
            pToDate = RDPTo.SelectedDate
        Catch ex As Exception
            pToDate = "30/12/2099"
        End Try
        If ComboConsultants.Items(0).Selected Then
            iTypeOfConsultant = 0
        ElseIf ComboConsultants.Items(1).Selected Then
            iTypeOfConsultant = 1
        ElseIf ComboConsultants.Items(2).Selected Then
            iTypeOfConsultant = 2
        ElseIf ComboConsultants.Items(3).Selected Then
            iTypeOfConsultant = 3
        ElseIf ComboConsultants.Items(4).Selected Then
            iTypeOfConsultant = 4
        ElseIf ComboConsultants.Items(5).Selected Then
            iTypeOfConsultant = 5
        ElseIf ComboConsultants.Items(6).Selected Then
            iTypeOfConsultant = 6
        Else
            iTypeOfConsultant = 0
        End If
        If cbRandomize.Checked Then
            pAnonymise = True
        Else
            pAnonymise = False
        End If
        If Me.cbHideSuppressed.Checked Then
            pHideSuppressed = True
        Else
            pHideSuppressed = False
        End If
        If Me.cbReports.Items(0).Selected Then
            pGastroscopy = True
        Else
            pGastroscopy = False
        End If
        If Me.cbReports.Items(1).Selected Then
            pPEGPEJ = True
        Else
            pPEGPEJ = False
        End If
        If Me.cbReports.Items(2).Selected Then
            pERCP = True
        Else
            pERCP = False
        End If
        If Me.cbReports.Items(3).Selected Then
            pColonoscopy = True
        Else
            pColonoscopy = False
        End If
        If Me.cbReports.Items(4).Selected Then
            pSigmoidoscopy = True
        Else
            pSigmoidoscopy = False
        End If
        'If Me.cbReports.Items(5).Selected Then
        'pBowel = True
        'Else
        'pBowel = False
        'End If
        If Me.cbReports.Items(5).Selected Then
            pEUS = True
        Else
            pEUS = False
        End If
        Dim sql As String = ""
        Dim sqlcaramba As String = ""
        Try
            Select Case Me.ComboConsultants.SelectedValue.ToString
                Case "AllConsultants"
                    sqlcaramba = " And ((IsEndoscopist1=1) Or (IsEndoscopist2=1) Or (IsListConsultant=1) Or (IsAssistantOrTrainee=1) Or (IsNurse1=1) Or (IsNurse2=1))"
                Case "Endoscopist1"
                    sqlcaramba = " And IsEndoscopist1=1"
                Case "Endoscopist2"
                    sqlcaramba = " And IsEndoscopist2=1"
                Case "ListConsultant"
                    sqlcaramba = " And IsListConsultant=1"
                Case "Assistant"
                    sqlcaramba = " And IsAssistantOrTrainee=1"
                Case "Nurse1"
                    sqlcaramba = " And IsNurse1=1"
                Case "Nurse2"
                    sqlcaramba = " And IsNurse2=1"
                Case Else
                    sqlcaramba = ""
            End Select
        Catch ex As Exception
            MsgBox(sqlcaramba & ex.Message.ToArray)
        End Try
        Dim operatingHospitalList As String = GetSelectedHospitalIds()

        sql = "Update [dbo].[ERS_ReportFilter] Set ReportDate=GetDate(), FromDate=Convert(Date,SubString('" + FromDate + "',7,4)+'-'+SubString('" + FromDate + "',4,2)+'-'+SubString('" + FromDate + "',1,2)) , ToDate=Convert(Date,SubString('" + ToDate + "',7,4)+'-'+SubString('" + ToDate + "',4,2)+'-'+SubString('" + ToDate + "',1,2)) "
        sql = sql + ", HideSuppressed='" + pHideSuppressed.ToString + "'"
        sql = sql + ", OGD='" + pGastroscopy.ToString + "'"
        sql = sql + ", PEGPEJ='" + pPEGPEJ.ToString + "'"
        sql = sql + ", ERCP='" + pERCP.ToString + "'"
        sql = sql + ", Colonoscopy='" + pColonoscopy.ToString + "'"
        sql = sql + ", Sigmoidoscopy='" + pSigmoidoscopy.ToString + "'"
        sql = sql + ", EUS='" + pEUS.ToString + "'"
        sql = sql + ", Bowel='" + pBowel.ToString + "'"
        sql = sql + ", Anonymise='" + pAnonymise.ToString + "'"
        sql = sql + ", TypesOfEndoscopists='" + iTypeOfConsultant.ToString + "'"
        sql = sql + ", TrustId ='" + Session("TrustId") + "'"
        sql = sql + ", operatingHospitalList ='" + operatingHospitalList + "'"
        sql = sql + " WHERE UserID = " + UserID
        Reporting.Transaction(sql)

        sql = "DELETE FROM ERS_ReportConsultants WHERE UserID = " & Session("PKUserID")
        Reporting.Transaction(sql)

        sql = "Insert Into [dbo].[ERS_ReportConsultants] (UserID, ConsultantID, AnonimizedID) "
        sql = sql + "Select UserID=" + Session("PKUserID").ToString + ", ConsultantID=ReportID, AnonimizedID=ReportID From [dbo].[v_rep_Consultants] Where ReportID In (0"
        For Each Item As RadListBoxItem In RadListBox1.CheckedItems
            sql = sql + "," + Item.Value.ToString
        Next
        sql = sql + ") " '+ sql2
        Reporting.Transaction(sql)
        If cbRandomize.Checked = True Then
            sql = "Exec report_Anonimize " + Session("PKUserId").ToString + " ,1"
        Else
            sql = "Exec report_Anonimize " + Session("PKUserId").ToString + " ,0"
        End If
        Reporting.Transaction(sql)
        'Me.LoadDefaultsFromDB()
    End Sub
    Protected Sub PageReset(sender As Object, e As EventArgs) Handles ButtonReset.Click
        Dim sql As String = ""
        sql = "DELETE FROM ERS_ReportConsultants WHERE UserId = " & Session("PKUserID").ToString
        Reporting.Transaction(sql)
        sql = "DELETE FROM ERS_ReportFilter WHERE UserId = " & Session("PKUserID").ToString
        Reporting.Transaction(sql)

    End Sub

    'Protected Sub TypeOfConsultant_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ComboConsultants.SelectedIndexChanged, cbHideSuppressed.CheckedChanged
    '    'Reporting.CleanListBoxes(Session("PKUserId").ToString)
    '    ' Reporting.SetConsultantType(Me.ComboConsultants.SelectedValue.ToString, Me.cbHideSuppressed.Checked)
    '    'Me.RadListBox2.Items.Clear()
    '    Me.RadListBox1.Items.Clear()
    '    Me.RadListBox1.DataBind()
    '    'Me.RadListBox2.DataBind()
    '    Me.SqlDSAllConsultants.DataBind()
    '    Me.SqlDSSelectedConsultants.DataBind()
    'End Sub


#End Region
    '    '------- ▼ Those functions could be unnecessary ▼ -------
    '    '-------   Check before delete                    -------

    'Private Function GetDT(ByVal SqlQuery As String) As DataTable
    '    Dim dsData As New DataSet
    '    Using connection As New SqlConnection(ConfigurationManager.ConnectionStrings("Gastro_DB").ConnectionString)
    '        Dim cmd As New SqlCommand(SqlQuery, connection)
    '        cmd.CommandType = CommandType.Text
    '        Dim adapter = New SqlDataAdapter(cmd)
    '        connection.Open()
    '        adapter.Fill(dsData)
    '    End Using
    '    If dsData.Tables.Count > 0 Then
    '        Return dsData.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    Protected Sub cbReports_exec(Optional annonymousNeeded As Boolean = True)
        'OGD
        If Me.cbReports.Items(0).Selected = False Then
            Me.RadTabStrip2.Tabs(1).Visible = False
        Else
            Me.RadTabStrip2.Tabs(1).Visible = True
        End If

        'PEGPEJ
        If Me.cbReports.Items(1).Selected = False Then
            Me.RadTabStrip2.Tabs(2).Visible = False
        Else
            Me.RadTabStrip2.Tabs(2).Visible = True
        End If

        'ERCP
        If Me.cbReports.Items(2).Selected = False Then
            Me.RadTabStrip2.Tabs(3).Visible = False
        Else
            Me.RadTabStrip2.Tabs(3).Visible = True
        End If

        'SIG
        If Me.cbReports.Items(3).Selected = False Then
            Me.RadTabStrip2.Tabs(5).Visible = False
        Else
            Me.RadTabStrip2.Tabs(5).Visible = True
        End If

        'COLON
        If Me.cbReports.Items(4).Selected = False Then
            Me.RadTabStrip2.Tabs(4).Visible = False
        Else
            Me.RadTabStrip2.Tabs(4).Visible = True
        End If

        'BOWEL
        'If Me.cbReports.Items(5).Selected = False Then
        Me.RadTabStrip2.Tabs(6).Visible = False
        'Else
        'Me.RadTabStrip2.Tabs(6).Visible = True
        'End If

        'EUS
        If Me.cbReports.Items(5).Selected = False Then
            Me.RadTabStrip2.Tabs(7).Visible = False
        Else
            Me.RadTabStrip2.Tabs(7).Visible = True
        End If

        Me.RadTabStrip2.Tabs(8).Visible = False

        For Each item As ListItem In OtherAudits.Items
            Dim rt As RadTab
            rt = Me.RadTabStrip2.FindTabByText(item.Text)
            If Not IsNothing(rt) Then
                ' have to remove the pageview too
                Dim pageViewCollection As Collection = New Collection()
                For Each pageView As RadPageView In RadMultiPage2.PageViews
                    If pageView.ID = "p" + item.Value Then
                        pageViewCollection.Add(pageView)
                    End If
                Next
                For Each pageView As RadPageView In pageViewCollection
                    RadMultiPage2.PageViews.Remove(pageView)
                Next
                Me.RadTabStrip2.Tabs.Remove(rt)
            End If
            If item.Selected Then
                Dim radTab As RadTab = New RadTab(item.Text)

                Dim pageView As RadPageView = New RadPageView()

                pageView.ID = "p" + item.Value
                Dim radGrid As RadGrid = New RadGrid()
                Dim da As DataAccess = New DataAccess()
                radGrid.ID = item.Value

                pageView.Controls.Add(radGrid)
                RadMultiPage2.PageViews.Add(pageView)
                Me.RadTabStrip2.Tabs.Add(radTab)

                AddHandler radGrid.NeedDataSource, AddressOf OtherReport_NeedDataSource
                AddHandler radGrid.ExcelMLExportStylesCreated, AddressOf OtherReport_ExcelMLExportStylesCreated

                Dim dt = da.GetOtherAuditReport(item.Value)
                If (annonymousNeeded = True) Then
                    Dim AnonymousField As String = ConfigurationManager.AppSettings("AnonymousField")
                    If Not String.IsNullOrEmpty(AnonymousField) Then
                        Dim ColumnsToBeDeleted As String() = AnonymousField.ToString().Split(",")

                        For Each ColName As String In ColumnsToBeDeleted
                            If dt.Columns.Contains(ColName) Then dt.Columns.Remove(ColName)
                        Next

                    End If
                End If

                radGrid.ClientSettings.Scrolling.AllowScroll = True
                radGrid.ClientSettings.Scrolling.UseStaticHeaders = True
                radGrid.MasterTableView.CommandItemSettings.ShowAddNewRecordButton = False
                radGrid.MasterTableView.CommandItemSettings.ShowRefreshButton = False
                radGrid.MasterTableView.CommandItemSettings.ShowExportToExcelButton = True
                radGrid.MasterTableView.CommandItemSettings.ExportToExcelText = "Export"
                radGrid.MasterTableView.CommandItemDisplay = 1

                radGrid.ExportSettings.Excel.Format = GridExcelExportFormat.Biff
                radGrid.ExportSettings.ExportOnlyData = True
                radGrid.ExportSettings.IgnorePaging = True
                radGrid.MasterTableView.CommandItemStyle.Font.Bold = True

                'radGrid.ClientSettings.Scrolling.ScrollHeight = 400
                radGrid.DataSource = dt
                radGrid.Rebind()

                'AddHandler radGrid.PageIndexChanged, Sub(_sender As Object, _e As GridPageChangedEventArgs) RefreshData(CType(_sender, RadGrid))



            End If
        Next

    End Sub

    Protected Sub RadGridGastroscopy_ExcelMLExportStylesCreated(ByVal sender As Object, ByVal e As GridExcelBuilder.GridExportExcelMLStyleCreatedArgs) Handles RadGridGastroscopy.ExcelMLExportStylesCreated, RadGridPEGPEJ.ExcelMLExportStylesCreated, RadGridERCP.ExcelMLExportStylesCreated, RadGridSigmoidoscopy.ExcelMLExportStylesCreated, RadGridColonoscopy.ExcelMLExportStylesCreated, RadGridEUS.ExcelMLExportStylesCreated
        Dim numberStyle As New StyleElement("NumberStyle")
        numberStyle.NumberFormat.FormatType = NumberFormatType.General
        e.Styles.Add(numberStyle)

        Dim percentStyle As New StyleElement("PercentStyle")
        percentStyle.NumberFormat.FormatType = NumberFormatType.Percent
        e.Styles.Add(percentStyle)

        Dim currencyStyle As New StyleElement("CurrencyStyle")
        currencyStyle.NumberFormat.FormatType = NumberFormatType.Currency
        e.Styles.Add(currencyStyle)
    End Sub

    Protected Sub RadGridGastroscopy_ExcelMLExportRowCreated(ByVal source As Object, ByVal e As GridExcelBuilder.GridExportExcelMLRowCreatedArgs) Handles RadGridGastroscopy.ExcelMLExportRowCreated
        e.Row.Cells.GetCellByName("SuccessOfIntubationP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("CompletenessOfProcedureP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("JManoeuvreRate").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfort").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfortNurse").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("GTRecommededDose").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("NoSedationP").StyleValue = "PercentStyle"
    End Sub

    Protected Sub RadGridPEGPEJ_ExcelMLExportRowCreated(ByVal source As Object, ByVal e As GridExcelBuilder.GridExportExcelMLRowCreatedArgs) Handles RadGridPEGPEJ.ExcelMLExportRowCreated
        e.Row.Cells.GetCellByName("SatisfactoryPlacementOfPEGP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("PostProcedureInfectionRequiringAntibioticsP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("PostProcedurePeritonitisP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("BleedingRequiringTransfusionP").StyleValue = "PercentStyle"
    End Sub

    Protected Sub RadGridERCP_ExcelMLExportRowCreated(ByVal source As Object, ByVal e As GridExcelBuilder.GridExportExcelMLRowCreatedArgs) Handles RadGridERCP.ExcelMLExportRowCreated
        e.Row.Cells.GetCellByName("CannulationOfIntendedDuctAtFirstERCP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("CommonBileDuctStoneCclearanceAtFirstERCP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ExtraHepaticStrictureStentSiting").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("GTRecommededDose").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("NoSedationP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("PropofolP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfort").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfortNurse").StyleValue = "PercentStyle"
    End Sub

    Protected Sub RadGridSigmoidoscopy_ExcelMLExportRowCreated(ByVal source As Object, ByVal e As GridExcelBuilder.GridExportExcelMLRowCreatedArgs) Handles RadGridSigmoidoscopy.ExcelMLExportRowCreated
        e.Row.Cells.GetCellByName("DigiRectalExaminationP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("SplenicFlexureIntubationRate").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("DescendingIntubationRate").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("PolypDetectionRate").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("PolypRetrievalRateP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("RectalRetoversionRateP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfort").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("GTRecommededDose").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("NoSedationP").StyleValue = "PercentStyle"
        'e.Row.Cells.GetCellByName("DiagnosticRectalBiopsiesForUnexplainedDiarrohea").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("TattooingOfAllLesionsP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfortNurse").StyleValue = "PercentStyle"
    End Sub

    Protected Sub RadGridColonoscopy_ExcelMLExportRowCreated(ByVal source As Object, ByVal e As GridExcelBuilder.GridExportExcelMLRowCreatedArgs) Handles RadGridColonoscopy.ExcelMLExportRowCreated
        e.Row.Cells.GetCellByName("DigiRectalExaminationP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("UnadjustedCaecalIntubationRate").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("TerminalIlealIntubationRate").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("PolypDetectionRate").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("PolypRetrievalRateP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("RectalRetoversionRateP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfort").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfortNurse").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("GTRecommededDose").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("NoSedationP").StyleValue = "PercentStyle"
    End Sub

    Protected Sub RadGridEUS_ExcelMLExportRowCreated(ByVal source As Object, ByVal e As GridExcelBuilder.GridExportExcelMLRowCreatedArgs) Handles RadGridEUS.ExcelMLExportRowCreated
        e.Row.Cells.GetCellByName("PropofolP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("GTRecommededDose").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("NoSedationP").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfort").StyleValue = "PercentStyle"
        e.Row.Cells.GetCellByName("ComfortLevelModerateSevereDiscomfortNurse").StyleValue = "PercentStyle"
    End Sub


    Protected Sub OtherReport_ExcelMLExportStylesCreated(ByVal sender As Object, ByVal e As GridExcelBuilder.GridExportExcelMLStyleCreatedArgs)
        Dim numberStyle As New StyleElement("NumberStyle")
        numberStyle.NumberFormat.FormatType = NumberFormatType.General
        e.Styles.Add(numberStyle)

        Dim percentStyle As New StyleElement("PercentStyle")
        percentStyle.NumberFormat.FormatType = NumberFormatType.Percent
        e.Styles.Add(percentStyle)

        Dim currencyStyle As New StyleElement("CurrencyStyle")
        currencyStyle.NumberFormat.FormatType = NumberFormatType.Currency
        e.Styles.Add(currencyStyle)
    End Sub

    Protected Sub OtherReport_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim radGrid As RadGrid
        Dim da As DataAccess = New DataAccess()
        radGrid = TryCast(sender, RadGrid)
        Dim dt = da.GetOtherAuditReport(radGrid.ID)
        radGrid.DataSource = dt
    End Sub
#Region "Export multiple Grid"

    Private Estructura As New xls.ExportStructure
    Private Tabla As New ExportInfrastructure.Table
    Private GridControlsFound As New List(Of RadGrid)
    Private DataTablesFound As New Dictionary(Of String, DataTable)
    Private Row As Integer = 1
    Private Col As Integer = 1
    Private IsFirstItem As Boolean = True

    'Protected Sub ExportGrids(sender As Object, e As EventArgs) Handles RadButtonExportGrids.Click
    '    Try
    '        '    '------- ▼ Adding RadGrids to GridControlsFound ▼ -------
    '        'GridControlsFound.Add(RadGridNumberOfProceduresPerformed)
    '        For Each radTab As RadTab In RadTabStrip2.Tabs
    '            If radTab.Visible Then
    '                Dim pageView As RadPageView = radTab.PageView
    '                If Left(pageView.ID, 1) = "p" Then
    '                    Dim da As DataAccess = New DataAccess()
    '                    DataTablesFound.Add(radTab.Text, da.GetOtherAuditReport(Replace(pageView.ID, "p", "")))
    '                Else
    '                    For Each cont As Control In pageView.Controls
    '                        If TypeOf cont Is RadGrid Then
    '                            GridControlsFound.Add(cont)
    '                        End If
    '                    Next
    '                End If
    '            End If
    '        Next
    '        'If cbReports.Items(0).Selected = True Then
    '        '    GridControlsFound.Add(RadGridGastroscopy)
    '        'End If
    '        'If cbReports.Items(1).Selected = True Then
    '        '    GridControlsFound.Add(RadGridPEGPEJ)
    '        'End If
    '        'If cbReports.Items(2).Selected = True Then
    '        '    GridControlsFound.Add(RadGridERCP)
    '        'End If
    '        'If cbReports.Items(3).Selected = True Then
    '        '    GridControlsFound.Add(RadGridSigmoidoscopy)
    '        'End If
    '        'If cbReports.Items(4).Selected = True Then
    '        '    GridControlsFound.Add(RadGridColonoscopy)
    '        'End If
    '        ''If cbReports.Items(5).Selected = True Then
    '        ''GridControlsFound.Add(RadGridBowel)
    '        ''End If
    '        'If cbReports.Items(5).Selected = True Then
    '        '    GridControlsFound.Add(RadGridEUS)
    '        'End If
    '        'GridControlsFound.Add(RadGridEndoscopists)
    '        '    '------- ▼ Create list of tables ▼ ------- In progress
    '        'Dim SingleTable As xls.Table
    '        'GridHeaderItem headerItem = grid.MasterTableView.GetItems(GridItemType.Header)[0] as GridHeaderItem;
    '        For Each G In GridControlsFound
    '            G.AllowPaging = False
    '            G.CurrentPageIndex = 0
    '            G.Rebind()
    '            GenerateTable(G)
    '        Next
    '        For Each D In DataTablesFound
    '            GenerateTable(D.Key, D.Value)
    '        Next

    '        '------- ▼ Generating Excel Sheet ▼ -------
    '        Dim Renderer As New xls.XlsBiffRenderer(Estructura)
    '        Dim RenderedBytes As Byte() = Renderer.Render

    '        'If Not Directory.Exists("C:\HDClinical") Then
    '        ' Directory.CreateDirectory("C:\HDClinical")
    '        'End If

    '        File.WriteAllBytes(Server.MapPath("~/JAG_GRS_Report.xls"), RenderedBytes)

    '        'HttpContext.Current.Response.Clear()
    '        'HttpContext.Current.Response.Buffer = True
    '        'HttpContext.Current.Response.AddHeader("content-disposition", "attachment; filename=JAG_GRS_Report.xls")
    '        'HttpContext.Current.Response.ContentType = "application/octet-stream"
    '        'HttpContext.Current.Response.BinaryWrite(RenderedBytes)
    '        'HttpContext.Current.Response.TransmitFile("C:\HDClinical\JAG GRS Report.xls")
    '        'HttpContext.Current.Response.End()
    '        'HttpContext.Current.Response.Flush()
    '        'HttpContext.Current.ApplicationInstance.CompleteRequest()
    '        downloadFile.HRef = "~/JAG_GRS_Report.xls"
    '        downloadFile.Visible = True

    '        '
    '        'Dim fileData As Byte() = System.IO.File.ReadAllBytes("C:\HDClinical\JAG GRS Report.xls")
    '        'Response.TransmitFile(Server.MapPath("~/JAG_GRS_Report.xls"))
    '        'HttpContext.Current.ApplicationInstance.CompleteRequest()
    '        'Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    '        'Response.Headers.Remove("Content-Disposition")
    '        'Response.AppendHeader("Content-Disposition", "attachment; filename=JAG GRS Report.xlsx")
    '        'Response.BinaryWrite(RenderedBytes)
    '        'Response.[End]()

    '    Catch ex As Exception
    '    End Try
    'End Sub

    Protected Sub GenerateTable(ByVal ReportName As String, ByVal D As DataTable)
        Dim SingleTable As New xls.Table(D.TableName)
        Dim TitleStyle As New xls.ExportStyle
        Dim FootStyle As New xls.ExportStyle
        TitleStyle.Font.Name = "Calibri"
        TitleStyle.Font.Size = 14
        TitleStyle.Font.Bold = True
        TitleStyle.ForeColor = Color.Black
        TitleStyle.HorizontalAlign = HorizontalAlign.Left
        TitleStyle.VerticalAlign = VerticalAlign.Middle
        FootStyle.Font.Name = "Calibri"
        FootStyle.Font.Size = 8
        FootStyle.ForeColor = Color.FromArgb(0, 0, 114, 198)
        Dim AuditPeriodLabelStyle As New xls.ExportStyle
        AuditPeriodLabelStyle.Font.Name = "Calibri"
        AuditPeriodLabelStyle.Font.Size = 10
        AuditPeriodLabelStyle.Font.Bold = True
        AuditPeriodLabelStyle.BorderBottomColor = Color.Black
        AuditPeriodLabelStyle.BorderRightColor = Color.Black
        AuditPeriodLabelStyle.BorderLeftColor = Color.Black
        AuditPeriodLabelStyle.BorderTopColor = Color.Black
        AuditPeriodLabelStyle.BorderBottomStyle = BorderStyle.Solid
        AuditPeriodLabelStyle.BorderRightStyle = BorderStyle.Solid
        AuditPeriodLabelStyle.BorderLeftStyle = BorderStyle.Solid
        AuditPeriodLabelStyle.BorderTopStyle = BorderStyle.Solid
        AuditPeriodLabelStyle.BorderTopWidth = 1
        AuditPeriodLabelStyle.BorderRightWidth = 1
        AuditPeriodLabelStyle.BorderLeftWidth = 1
        AuditPeriodLabelStyle.BorderBottomWidth = 1
        AuditPeriodLabelStyle.BackColor = Color.FromArgb(0, 51, 51, 153)
        AuditPeriodLabelStyle.ForeColor = Color.White
        AuditPeriodLabelStyle.HorizontalAlign = HorizontalAlign.Left
        AuditPeriodLabelStyle.VerticalAlign = VerticalAlign.Middle
        Dim AuditPeriodValueStyle As New xls.ExportStyle
        AuditPeriodValueStyle.Font.Name = "Calibri"
        AuditPeriodValueStyle.Font.Size = 10
        AuditPeriodValueStyle.Font.Bold = True
        AuditPeriodValueStyle.BorderBottomColor = Color.Black
        AuditPeriodValueStyle.BorderRightColor = Color.Black
        AuditPeriodValueStyle.BorderLeftColor = Color.Black
        AuditPeriodValueStyle.BorderTopColor = Color.Black
        AuditPeriodValueStyle.BorderBottomStyle = BorderStyle.Solid
        AuditPeriodValueStyle.BorderRightStyle = BorderStyle.Solid
        AuditPeriodValueStyle.BorderLeftStyle = BorderStyle.Solid
        AuditPeriodValueStyle.BorderTopStyle = BorderStyle.Solid
        AuditPeriodValueStyle.BorderTopWidth = 1
        AuditPeriodValueStyle.BorderRightWidth = 1
        AuditPeriodValueStyle.BorderLeftWidth = 1
        AuditPeriodValueStyle.BorderBottomWidth = 1
        AuditPeriodValueStyle.ForeColor = Color.Black
        AuditPeriodValueStyle.HorizontalAlign = HorizontalAlign.Left
        AuditPeriodValueStyle.VerticalAlign = VerticalAlign.Middle
        Dim HeadStyle As New xls.ExportStyle
        HeadStyle.BorderBottomColor = Color.Black
        HeadStyle.BorderRightColor = Color.Black
        HeadStyle.BorderLeftColor = Color.Black
        HeadStyle.BorderTopColor = Color.Black
        HeadStyle.BorderBottomStyle = BorderStyle.Solid
        HeadStyle.BorderRightStyle = BorderStyle.Solid
        HeadStyle.BorderLeftStyle = BorderStyle.Solid
        HeadStyle.BorderTopStyle = BorderStyle.Solid
        HeadStyle.BorderTopWidth = 1
        HeadStyle.BorderRightWidth = 1
        HeadStyle.BorderLeftWidth = 1
        HeadStyle.BorderBottomWidth = 1
        HeadStyle.BackColor = Color.FromArgb(0, 51, 51, 153)
        HeadStyle.ForeColor = Color.White
        HeadStyle.Font.Bold = True
        HeadStyle.Font.Name = "Calibri"
        HeadStyle.Font.Size = 10
        HeadStyle.HorizontalAlign = HorizontalAlign.Center
        HeadStyle.VerticalAlign = VerticalAlign.Middle
        Dim CellStyle As New xls.ExportStyle
        CellStyle.BorderBottomColor = Color.Black
        CellStyle.BorderRightColor = Color.Black
        CellStyle.BorderLeftColor = Color.Black
        CellStyle.BorderTopColor = Color.Black
        CellStyle.BorderBottomStyle = BorderStyle.Solid
        CellStyle.BorderRightStyle = BorderStyle.Solid
        CellStyle.BorderLeftStyle = BorderStyle.Solid
        CellStyle.BorderTopStyle = BorderStyle.Solid
        CellStyle.BorderTopWidth = 1
        CellStyle.BorderRightWidth = 1
        CellStyle.BorderLeftWidth = 1
        CellStyle.BorderBottomWidth = 1
        CellStyle.BackColor = Color.Beige
        CellStyle.ForeColor = Color.Black
        CellStyle.HorizontalAlign = HorizontalAlign.Center
        CellStyle.VerticalAlign = VerticalAlign.Middle
        SingleTable.Rows.Item(1).Height = 18
        SingleTable.Rows.Item(2).Height = 18
        SingleTable.Rows.Item(3).Height = 18
        SingleTable.Rows.Item(4).Height = 56
        Dim Title As String = ""
        Dim AuditPeriodLabel As String = "Audit Period"
        Dim auditPeriod As String = RDPFrom.SelectedDate.Value.ToString("dd-MMM-yyyy") + " to " + RDPTo.SelectedDate.Value.ToString("dd-MMM-yyyy") '"From " + Mid(Me.RDPFrom.SelectedDate.ToString, 1, 10) + " to " + Mid(Me.RDPTo.SelectedDate.ToString, 1, 10)
        Dim Signature As String = "Compiled on the " + Now.ToString("dd-MMM-yyyy") + " using the ERS Viewer Tool (Copyright © 2018 - " & Date.Today.Year & " HD Clinical Ltd)"
        Dim Cols As Short = D.Columns.Count
        Dim Table0 As DataTable = GetDataTable("SELECT B.AnonimizedID As UserID, Consultant FROM v_rep_Consultants A, ERS_ReportConsultants B WHERE A.ReportID=B.ConsultantID And B.UserID=" + Session("PKUserId").ToString + " Order By 1")
        Dim row0 As DataRow

        SingleTable.Cells("A1").Value = ReportName
        SingleTable.Cells("A1").Style = TitleStyle
        SingleTable.Title = ReportName

        SingleTable.Cells("A3").Value = AuditPeriodLabel
        SingleTable.Cells("A3").Style = AuditPeriodLabelStyle
        SingleTable.Cells("B3").Value = auditPeriod
        SingleTable.Cells("B3").Style = AuditPeriodValueStyle

        Dim HeaderColumnNumber As Integer = 1
        For i = 1 To Cols
            SingleTable.Columns.Item(i).Width = 34
            SingleTable.Cells(HeaderColumnNumber, 4).Style = HeadStyle
            SingleTable.Cells(HeaderColumnNumber, 4).Value = D.Columns(i - 1).Caption.ToString() ' G.Columns(i - 1).HeaderText.ToString
            SingleTable.Cells(HeaderColumnNumber, 4).Style.HorizontalAlign = HorizontalAlign.Center
            SingleTable.Cells(HeaderColumnNumber, 4).TextWrap = True
            SingleTable.Columns(HeaderColumnNumber).Style.HorizontalAlign = HorizontalAlign.Center 'G.Columns(i - 1).ItemStyle.HorizontalAlign
            HeaderColumnNumber = HeaderColumnNumber + 1
        Next
        Row = 5
        Col = 1
        For Each R As DataRow In D.Rows
            For Each C In R.ItemArray
                SingleTable.Cells(Col, Row).Value = C.ToString()
                Col = Col + 1
            Next
            Col = 1
            Row = Row + 1
        Next
        Dim LastRow As Integer = Row + 1

        SingleTable.Cells(1, LastRow).Value = Signature
        SingleTable.Cells(1, LastRow).Style = FootStyle
        SingleTable.Cells(1, LastRow).TextWrap = False
        SingleTable.Cells(1, LastRow).Style.HorizontalAlign = HorizontalAlign.Left
        Estructura.Tables.Add(SingleTable)

    End Sub

    Protected Sub GenerateTable(ByVal G As RadGrid)
        Dim SingleTable As New xls.Table(G.ID)
        Dim TitleStyle As New xls.ExportStyle
        Dim FootStyle As New xls.ExportStyle
        TitleStyle.Font.Name = "Calibri"
        TitleStyle.Font.Size = 14
        TitleStyle.Font.Bold = True
        TitleStyle.ForeColor = Color.Black
        TitleStyle.HorizontalAlign = HorizontalAlign.Left
        TitleStyle.VerticalAlign = VerticalAlign.Middle
        FootStyle.Font.Name = "Calibri"
        FootStyle.Font.Size = 8
        FootStyle.ForeColor = Color.FromArgb(0, 0, 114, 198)
        Dim AuditPeriodLabelStyle As New xls.ExportStyle
        AuditPeriodLabelStyle.Font.Name = "Calibri"
        AuditPeriodLabelStyle.Font.Size = 10
        AuditPeriodLabelStyle.Font.Bold = True
        AuditPeriodLabelStyle.BorderBottomColor = Color.Black
        AuditPeriodLabelStyle.BorderRightColor = Color.Black
        AuditPeriodLabelStyle.BorderLeftColor = Color.Black
        AuditPeriodLabelStyle.BorderTopColor = Color.Black
        AuditPeriodLabelStyle.BorderBottomStyle = BorderStyle.Solid
        AuditPeriodLabelStyle.BorderRightStyle = BorderStyle.Solid
        AuditPeriodLabelStyle.BorderLeftStyle = BorderStyle.Solid
        AuditPeriodLabelStyle.BorderTopStyle = BorderStyle.Solid
        AuditPeriodLabelStyle.BorderTopWidth = 1
        AuditPeriodLabelStyle.BorderRightWidth = 1
        AuditPeriodLabelStyle.BorderLeftWidth = 1
        AuditPeriodLabelStyle.BorderBottomWidth = 1
        AuditPeriodLabelStyle.BackColor = Color.FromArgb(0, 51, 51, 153)
        AuditPeriodLabelStyle.ForeColor = Color.White
        AuditPeriodLabelStyle.HorizontalAlign = HorizontalAlign.Left
        AuditPeriodLabelStyle.VerticalAlign = VerticalAlign.Middle
        Dim AuditPeriodValueStyle As New xls.ExportStyle
        AuditPeriodValueStyle.Font.Name = "Calibri"
        AuditPeriodValueStyle.Font.Size = 10
        AuditPeriodValueStyle.Font.Bold = True
        AuditPeriodValueStyle.BorderBottomColor = Color.Black
        AuditPeriodValueStyle.BorderRightColor = Color.Black
        AuditPeriodValueStyle.BorderLeftColor = Color.Black
        AuditPeriodValueStyle.BorderTopColor = Color.Black
        AuditPeriodValueStyle.BorderBottomStyle = BorderStyle.Solid
        AuditPeriodValueStyle.BorderRightStyle = BorderStyle.Solid
        AuditPeriodValueStyle.BorderLeftStyle = BorderStyle.Solid
        AuditPeriodValueStyle.BorderTopStyle = BorderStyle.Solid
        AuditPeriodValueStyle.BorderTopWidth = 1
        AuditPeriodValueStyle.BorderRightWidth = 1
        AuditPeriodValueStyle.BorderLeftWidth = 1
        AuditPeriodValueStyle.BorderBottomWidth = 1
        AuditPeriodValueStyle.ForeColor = Color.Black
        AuditPeriodValueStyle.HorizontalAlign = HorizontalAlign.Left
        AuditPeriodValueStyle.VerticalAlign = VerticalAlign.Middle
        Dim HeadStyle As New xls.ExportStyle
        HeadStyle.BorderBottomColor = Color.Black
        HeadStyle.BorderRightColor = Color.Black
        HeadStyle.BorderLeftColor = Color.Black
        HeadStyle.BorderTopColor = Color.Black
        HeadStyle.BorderBottomStyle = BorderStyle.Solid
        HeadStyle.BorderRightStyle = BorderStyle.Solid
        HeadStyle.BorderLeftStyle = BorderStyle.Solid
        HeadStyle.BorderTopStyle = BorderStyle.Solid
        HeadStyle.BorderTopWidth = 1
        HeadStyle.BorderRightWidth = 1
        HeadStyle.BorderLeftWidth = 1
        HeadStyle.BorderBottomWidth = 1
        HeadStyle.BackColor = Color.FromArgb(0, 51, 51, 153)
        HeadStyle.ForeColor = Color.White
        HeadStyle.Font.Bold = True
        HeadStyle.Font.Name = "Calibri"
        HeadStyle.Font.Size = 10
        HeadStyle.HorizontalAlign = HorizontalAlign.Center
        HeadStyle.VerticalAlign = VerticalAlign.Middle
        Dim CellStyle As New xls.ExportStyle
        CellStyle.BorderBottomColor = Color.Black
        CellStyle.BorderRightColor = Color.Black
        CellStyle.BorderLeftColor = Color.Black
        CellStyle.BorderTopColor = Color.Black
        CellStyle.BorderBottomStyle = BorderStyle.Solid
        CellStyle.BorderRightStyle = BorderStyle.Solid
        CellStyle.BorderLeftStyle = BorderStyle.Solid
        CellStyle.BorderTopStyle = BorderStyle.Solid
        CellStyle.BorderTopWidth = 1
        CellStyle.BorderRightWidth = 1
        CellStyle.BorderLeftWidth = 1
        CellStyle.BorderBottomWidth = 1
        CellStyle.BackColor = Color.Beige
        CellStyle.ForeColor = Color.Black
        CellStyle.HorizontalAlign = HorizontalAlign.Center
        CellStyle.VerticalAlign = VerticalAlign.Middle
        SingleTable.Rows.Item(1).Height = 18
        SingleTable.Rows.Item(2).Height = 18
        SingleTable.Rows.Item(3).Height = 18
        SingleTable.Rows.Item(4).Height = 56
        Dim Title As String = ""
        Dim AuditPeriodLabel As String = "Audit Period"
        Dim auditPeriod As String = RDPFrom.SelectedDate.Value.ToString("dd-MMM-yyyy") + " to " + RDPTo.SelectedDate.Value.ToString("dd-MMM-yyyy") '"From " + Mid(Me.RDPFrom.SelectedDate.ToString, 1, 10) + " to " + Mid(Me.RDPTo.SelectedDate.ToString, 1, 10)
        Dim Signature As String = "Compiled on the " + Now.ToString("dd-MMM-yyyy") + " using the ERS Viewer Tool (Copyright © 2018 - " & Date.Today.Year & " HD Clinical Ltd)"
        Dim Cols As Short = G.Columns.Count
        Dim Table0 As DataTable = GetDataTable("SELECT B.AnonimizedID As UserID, Consultant FROM v_rep_Consultants A, ERS_ReportConsultants B WHERE A.ReportID=B.ConsultantID And B.UserID=" + Session("PKUserId").ToString + " Order By 1")
        Dim row0 As DataRow
        Select Case G.ID
            Case "RadGridNumberOfProceduresPerformed"
                Title = "Number of procedures performed by each operator"
                SingleTable.Title = "Summary procedure count"
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 26
                SingleTable.Columns.Item(3).Width = 15
                SingleTable.Columns.Item(4).Width = 15
                SingleTable.Columns.Item(5).Width = 15
                SingleTable.Columns.Item(6).Width = 15
                SingleTable.Columns.Item(7).Width = 15
                SingleTable.Columns.Item(8).Width = 15
                SingleTable.Columns.Item(9).Width = 15
            Case "RadGridEndoscopists"
                Title = "Endoscopists"
                SingleTable.Title = Title
                SingleTable.Cells("A3").Value = "Report position"
                SingleTable.Cells("A3").TextWrap = True
                SingleTable.Cells("B3").Value = "Name"
                SingleTable.Cells("B3").TextWrap = True
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 30
                Row = 5
                For Each row0 In Table0.Rows
                    SingleTable.Cells(1, Row).Value = row0("UserID").ToString
                    SingleTable.Cells(1, Row).Style = CellStyle
                    SingleTable.Cells(1, Row).TextWrap = True
                    SingleTable.Cells(2, Row).Value = row0("Consultant").ToString
                    SingleTable.Cells(2, Row).Style = CellStyle
                    SingleTable.Cells(2, Row).TextWrap = True
                    Row = Row + 1
                Next
            Case "RadGridGastroscopy"
                Title = "Gastroscopy outcomes"
                SingleTable.Title = Title
                SingleTable.Columns.Item(1).Width = 12
                SingleTable.Columns.Item(2).Width = 26
                SingleTable.Columns.Item(3).Width = 15
                SingleTable.Columns.Item(4).Width = 15
                SingleTable.Columns.Item(5).Width = 15
                SingleTable.Columns.Item(6).Width = 15
                SingleTable.Columns.Item(7).Width = 15
                SingleTable.Columns.Item(8).Width = 15
                SingleTable.Columns.Item(9).Width = 15
                SingleTable.Columns.Item(10).Width = 15
                SingleTable.Columns.Item(11).Width = 15
                SingleTable.Columns.Item(12).Width = 20
            Case "RadGridPEGPEJ"
                Title = "PEG outcomes"
                SingleTable.Title = Title
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 26
                SingleTable.Columns.Item(3).Width = 15
                SingleTable.Columns.Item(4).Width = 15
                SingleTable.Columns.Item(5).Width = 15
                SingleTable.Columns.Item(6).Width = 15
                SingleTable.Columns.Item(7).Width = 15
                SingleTable.Columns.Item(8).Width = 20
            Case "RadGridERCP"
                Title = "ERCP outcomes"
                SingleTable.Title = Title
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 26
                SingleTable.Columns.Item(3).Width = 15
                SingleTable.Columns.Item(4).Width = 15
                SingleTable.Columns.Item(5).Width = 15
                SingleTable.Columns.Item(6).Width = 20
                SingleTable.Columns.Item(7).Width = 15
                SingleTable.Columns.Item(8).Width = 20
                SingleTable.Columns.Item(9).Width = 20
            Case "RadGridSigmoidoscopy"
                Title = "Flexible sigmoidoscopy outcomes"
                SingleTable.Title = Title
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 26
                SingleTable.Columns.Item(3).Width = 15
                SingleTable.Columns.Item(4).Width = 15
                SingleTable.Columns.Item(5).Width = 15
                SingleTable.Columns.Item(6).Width = 20
            Case "RadGridColonoscopy"
                Title = "Colonoscopy outcomes"
                SingleTable.Title = Title
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 26
                SingleTable.Columns.Item(3).Width = 15
                SingleTable.Columns.Item(4).Width = 15
                SingleTable.Columns.Item(5).Width = 15
                SingleTable.Columns.Item(6).Width = 15
                SingleTable.Columns.Item(7).Width = 15
                SingleTable.Columns.Item(8).Width = 15
                SingleTable.Columns.Item(9).Width = 20
                SingleTable.Columns.Item(10).Width = 20
                SingleTable.Columns.Item(11).Width = 20
                SingleTable.Columns.Item(12).Width = 20
                SingleTable.Columns.Item(13).Width = 15
                SingleTable.Columns.Item(14).Width = 22
                SingleTable.Columns.Item(15).Width = 15
                SingleTable.Columns.Item(16).Width = 15
                SingleTable.Columns.Item(17).Width = 15
                SingleTable.Columns.Item(18).Width = 15
                SingleTable.Columns.Item(19).Width = 15
                SingleTable.Columns.Item(20).Width = 15
                SingleTable.Columns.Item(21).Width = 15
                SingleTable.Columns.Item(22).Width = 20
            Case "RadGridBowel"
                Title = "Bowel preparation outcomes"
                SingleTable.Title = Title
                SingleTable.Columns.Item(1).Width = 20
                SingleTable.Columns.Item(2).Width = 26
                SingleTable.Columns.Item(3).Width = 20
                SingleTable.Columns.Item(4).Width = 20
            Case "RadGridEUS"
                Title = "EUS outcomes"
                SingleTable.Title = Title
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 26
                SingleTable.Columns.Item(3).Width = 15
                SingleTable.Columns.Item(4).Width = 15
                SingleTable.Columns.Item(5).Width = 15
                SingleTable.Columns.Item(6).Width = 15
                SingleTable.Columns.Item(7).Width = 15
                SingleTable.Columns.Item(8).Width = 20
        End Select
        'Punto OJO
        SingleTable.Cells("A1").Value = Title
        SingleTable.Cells("A1").Style = TitleStyle
        SingleTable.Cells("A3").Value = AuditPeriodLabel
        SingleTable.Cells("A3").Style = AuditPeriodLabelStyle
        SingleTable.Cells("B3").Value = auditPeriod
        SingleTable.Cells("B3").Style = AuditPeriodValueStyle

        'Punto OJO
        Dim HeaderColumnNumber As Integer = 1
        For i = 1 To Cols
            If G.Columns(i - 1).Display Then
                SingleTable.Cells(HeaderColumnNumber, 4).Style = HeadStyle
                SingleTable.Cells(HeaderColumnNumber, 4).Value = G.Columns(i - 1).HeaderText.ToString
                SingleTable.Cells(HeaderColumnNumber, 4).Style.HorizontalAlign = HorizontalAlign.Center
                SingleTable.Cells(HeaderColumnNumber, 4).TextWrap = True
                SingleTable.Columns(HeaderColumnNumber).Style.HorizontalAlign = HorizontalAlign.Center 'G.Columns(i - 1).ItemStyle.HorizontalAlign
                HeaderColumnNumber = HeaderColumnNumber + 1
            End If
        Next
        Row = 5
        Col = 1
        For Each Elemento In G.MasterTableView.Items
            'Punto OJO
            Dim count As Integer = 1
            For Each C In G.Columns
                If C.Display Then
                    Dim value As String = Elemento(C.UniqueName).text.ToString()
                    Dim a As GridTableCell = Elemento(C.UniqueName)


                    If C.UniqueName = "Endoscopist1" Then
                        Dim startIndex As Integer = value.IndexOf(">") + 1
                        Dim endIndex As Integer = value.IndexOf("<", startIndex)
                        'value = value.Substring(startIndex, endIndex - startIndex)
                    End If

                    If value = "&nbsp;" Then
                        Try
                            If C.ColumnType = "GridHyperLinkColumn" Then
                                value = "" + Elemento.DataItem.Row.ItemArray(C.OrderIndex).ToString
                            Else
                                value = ""
                            End If
                        Catch ex As Exception
                            value = ex.InnerException.ToString()
                        End Try
                    End If

                    Dim valueAsInt As Integer
                    Dim valueAsDecimal As Decimal
                    Dim isAPercentage As Boolean = value.Contains("%")
                    If isAPercentage Then
                        'value = value.Replace("%", "")
                        SingleTable.Cells(Col, Row).Value = value
                        'If Decimal.TryParse(value, valueAsDecimal) Then
                        '    valueAsDecimal = valueAsDecimal / 100
                        '    SingleTable.Cells(Col, Row).Format = "0.00%"
                        '    SingleTable.Cells(Col, Row).Value = valueAsDecimal
                        'End If
                    Else
                        If Integer.TryParse(value, valueAsInt) Then
                            SingleTable.Cells(Col, Row).Value = valueAsInt
                            SingleTable.Cells(Col, Row).Format = "0"
                        ElseIf Decimal.TryParse(value, valueAsDecimal) Then
                            SingleTable.Cells(Col, Row).Value = valueAsDecimal
                            SingleTable.Cells(Col, Row).Format = "0.00"
                        Else
                            SingleTable.Cells(Col, Row).Value = value
                        End If
                    End If

                    SingleTable.Cells(Col, Row).Style = CellStyle
                    SingleTable.Cells(Col, Row).TextWrap = True
                    Col = Col + 1
                End If
                count = count + 1
            Next C
            Col = 1
            Row = Row + 1
        Next
        Dim LastRow As Integer = Row + 1

        SingleTable.Cells(1, LastRow).Value = Signature
        SingleTable.Cells(1, LastRow).Style = FootStyle
        SingleTable.Cells(1, LastRow).TextWrap = False
        SingleTable.Cells(1, LastRow).Style.HorizontalAlign = HorizontalAlign.Left
        Estructura.Tables.Add(SingleTable)
    End Sub

    Public Function GetDataTable(query As String) As DataTable
        Dim ConnString As [String] = DataAccess.ConnectionStr
        Dim conn As New SqlConnection(ConnString)
        Dim adapter As New SqlDataAdapter()
        adapter.SelectCommand = New SqlCommand(query, conn)
        Dim myDataTable As New DataTable()
        conn.Open()
        Try
            adapter.Fill(myDataTable)
        Finally
            conn.Close()
        End Try
        Return myDataTable
    End Function
#End Region

#Region "Buttons"

    Protected Sub cbHideSuppressed_Click(sender As Object, e As EventArgs) Handles cbHideSuppressed.CheckedChanged
        Dim operatingHospitalList As String = GetSelectedHospitalIds()
        Dim selectedConsultant As String
        For Each Item As RadListBoxItem In RadListBox1.CheckedItems
            selectedConsultant = selectedConsultant + "," + Item.Value.ToString
        Next
        Me.RadListBox1.Items.Clear()
        Me.RadListBox1.DataBind()

        If Not (selectedConsultant Is Nothing) Then
            Dim selectedConsultantList = selectedConsultant.Split(",")
            For Each item As RadListBoxItem In RadListBox1.Items

                If selectedConsultantList.Contains(item.Value.ToString()) Then
                    item.Checked = True
                End If
            Next
        End If
    End Sub

    Protected Sub OperatingHospitalsRadComboBox_OnItemChecked(sender As Object, e As RadComboBoxItemEventArgs)
        Dim operatingHospitalList As String = GetSelectedHospitalIds()
        Session("ReportingOperatingHospitalIds") = operatingHospitalList
        Me.RadListBox1.Items.Clear()
        Me.RadListBox1.DataBind()
    End Sub
    Protected Sub OperatingHospitalsRadComboBox_OnCheckAllChange(sender As Object, e As RadComboBoxCheckAllCheckEventArgs)
        Dim operatingHospitalList As String = GetSelectedHospitalIds()
        Session("ReportingOperatingHospitalIds") = operatingHospitalList
        Me.RadListBox1.Items.Clear()
        Me.RadListBox1.DataBind()
    End Sub
    Protected Sub SqlDSAllConsultants_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        e.InputParameters("operatingHospitalsIds") = Session("OperatingHospitalIdsForTrust")
    End Sub


    Protected Sub RadButton1_Click(sender As Object, e As EventArgs) Handles RadButtonFilter.Click
        Try

            If CDate(Me.RDPFrom.SelectedDate.ToString) <= CDate(Me.RDPTo.SelectedDate.ToString) Then
                'Reporting.CleanListBoxes(Session("PKUserId").ToString)
                'Reporting.SetConsultantType(Me.ComboConsultants.SelectedValue.ToString, Me.cbHideSuppressed.Checked)
                'Me.LoadDefaultsFromDB()

                SetUserIDFilter(Session("PKUserID").ToString)
                'Me.RadListBox2.Items.Clear()
                'Me.RadListBox1.Items.Clear()
                'Me.RadListBox1.DataBind()
                'Me.RadListBox2.DataBind()
                'Dim sqlStr As String = "Exec [dbo].[report_BowelBoston] @UserID=" + Session("PKUserId").ToString
                'Using connection As New SqlConnection(DataAccess.ConnectionStr)
                '    Dim cmd As New SqlCommand(sqlStr, connection)
                '    cmd.CommandType = CommandType.Text
                '    cmd.Connection.Open()
                '    cmd.ExecuteNonQuery()
                'End Using

                RadGridEndoscopists.DataSourceID = "DSEndoscopists"

                RadGridNumberOfProceduresPerformed.DataSourceID = "DSNumberOfProceduresPerformed"
                DSNumberOfProceduresPerformed.DataBind()

                DSEndoscopists.DataBind()
                If cbReports.Items(0).Selected = True Then
                    RadGridGastroscopy.DataSourceID = "DSGastroscopy"
                    DSGastroscopy.DataBind()
                End If
                If cbReports.Items(1).Selected = True Then
                    RadGridPEGPEJ.DataSourceID = "DSPEGPEJ"
                    DSPEGPEJ.DataBind()
                End If
                If cbReports.Items(2).Selected = True Then
                    RadGridERCP.DataSourceID = "DSERCP"
                    DSERCP.DataBind()
                End If
                If cbReports.Items(3).Selected = True Then
                    RadGridSigmoidoscopy.DataSourceID = "DSSigmoidoscopy"
                    DSSigmoidoscopy.DataBind()
                End If
                If cbReports.Items(4).Selected = True Then
                    RadGridColonoscopy.DataSourceID = "DSColonoscopy"
                    DSColonoscopy.DataBind()
                End If
                'If cbReports.Items(5).Selected = True Then
                'RadGridBowel.DataSourceID = "DSBowel"
                'DSBowel.DataBind()
                'End If
                If cbReports.Items(5).Selected = True Then
                    RadGridEUS.DataSourceID = "DSEUS"
                    DSEUS.DataBind()
                End If
                RadTabStrip1.Tabs(1).Enabled = True
                'RadButtonExportGrids.Enabled = True
                RadTabStrip1.Tabs(0).Selected = False
                RadTabStrip1.Tabs(1).Selected = True
                RadMultiPage1.SelectedIndex = 1
                'RadButtonExportGrids.Visible = True
                cbReports_exec(False)
            Else
                Utilities.SetNotificationStyle(RadNotification1, "End date must be after the start date", True)
                RadNotification1.Show()
            End If
            'downloadFile.Visible = False
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error generating report", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error generating the report")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub OperatingHospitalsRadComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        e.Item.Checked = True
    End Sub


#End Region

    'Protected Sub RadGridGastroscopy_PageSizeChanged(sender As Object, e As Global.Telerik.Web.UI.GridPageSizeChangedEventArgs) Handles RadGridGastroscopy.PageSizeChanged
    '    If RadGridEndoscopists.PageSize <> e.NewPageSize Then
    '        RadGridEndoscopists.PageSize = e.NewPageSize
    '        RadGridEndoscopists.Rebind()
    '    End If
    'End Sub

End Class