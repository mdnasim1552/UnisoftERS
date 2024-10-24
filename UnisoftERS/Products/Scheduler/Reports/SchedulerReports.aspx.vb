Imports Telerik.Web.UI
Imports Telerik.Web.UI.GridBoundColumn
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
Imports Telerik.Web.UI.GridExcelBuilder
Imports Telerik.Web.UI.HtmlChart
Imports DevExpress.Web.ASPxHtmlEditor.Internal

Public Class SchedulerReports
    Inherits System.Web.UI.Page


#Region "Properties"
    Public Shared ReadOnly Property ConnectionStr() As String
        Get
            Return DataAccess.ConnectionStr
        End Get
    End Property

    Public Shared ReadOnly Property ConnectionStrLogging() As String
        Get
            Return ConfigurationManager.ConnectionStrings("Logging_DB").ConnectionString
        End Get
    End Property

    Public Shared ReadOnly Property ConnectionStrPASData() As String
        Get
            Return ConfigurationManager.ConnectionStrings("PASData").ConnectionString
        End Get
    End Property

    Dim dateFromFilterParam As Date,
        dateToFilterParam As Date

    Private _dateFromText As String
    Public ReadOnly Property DateFromText() As String
        Get
            Return dateFromFilterParam.ToString("dd/MM/yyyy")
        End Get
    End Property

    Private _dateToText As String
    Public ReadOnly Property DateToText() As String
        Get
            Return dateToFilterParam.ToString("dd/MM/yyyy")
        End Get
    End Property

    Public Property HospitalDataValues As Object
        Get
            Return ViewState("HospitalValues")
        End Get

        Set(value As Object)
            ViewState("HospitalValues") = value
        End Set
    End Property

    Public Property RoomDataValues As Object
        Get
            Return ViewState("RoomValues")
        End Get

        Set(value As Object)
            ViewState("RoomValues") = value
        End Set
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

    Structure SearchFields
        Property OperatingHospitalIds As List(Of Integer)
        Property RoomIds As List(Of Integer)
        Property SearchStartDate As DateTime
        Property SearchEndDate As DateTime
    End Structure
#End Region

    Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(RadButtonFilter, ReportPanel, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(RadButtonFilter, RadNotification1, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(RadButtonFilter, RadTabStrip2)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(RadButtonFilter, RadMultiPage2)

        'myAjaxMgr.AjaxSettings.AddAjaxSetting(RadTabStrip2, RadMultiPage2)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(RadTabStrip2, RadTabStrip2)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(RadMultiPage2, RadTabStrip2)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(RadMultiPage2, RadMultiPage2)

        If IsNothing(Session("OperatingHospitalID") Or IsNothing(Session("RoomID"))) Then
            Response.Redirect("/", False)
        Else
            SUID.Value = Session("OperatingHospitalID").ToString
        End If

        If Not Page.IsPostBack Then
            Dim da As New DataAccess
            'OperatingHospitalsRadComboBox.DataSource = da.GetOperatingHospitals()
            'OperatingHospitalsRadComboBox.DataTextField = "HospitalName"
            'OperatingHospitalsRadComboBox.DataValueField = "OperatingHospitalId"
            'OperatingHospitalsRadComboBox.DataBind()

            'If OperatingHospitalsRadComboBox.Items.Count = 1 Then OperatingHospitalsRadComboBox.EnableCheckAllItemsCheckBox = False

            'RoomsRadComboBox.DataSource = da.GetAllRooms()
            'RoomsRadComboBox.DataTextField = "RoomName"
            'RoomsRadComboBox.DataValueField = "RoomId"
            'RoomsRadComboBox.DataBind()

            ' added By Ferdowsi ,set default date
            Dim firstMonth = New DateTime(Now.Year, 1, 1)
            Dim lastMonth = New DateTime(Now.Year, 12, 1)
            RDPFrom.SelectedDate = firstMonth
            RDPTo.SelectedDate = lastMonth

            RadListBox1.DataSource = da.GetOperatingHospitals()
            RadListBox1.DataKeyField = "HospitalName"
            RadListBox1.DataValueField = "OperatingHospitalId"
            RadListBox1.DataBind()

            Dim hospitalsSelected As String = ""
            For Each hopsitalId As RadListBoxItem In RadListBox1.SelectedItems
                hospitalsSelected += CStr(hopsitalId.Index) + ","
            Next

            If RDPFrom.SelectedDate.ToString = "" Then
                LoadDefaults()
            End If

            ISMFilter.Enabled = True

            'Dim dt = da.GetAllRooms()

            'RadListBox1.Enabled = True
            'RoomPanel.Visible = True
            'For Each item As RadListBoxItem In RadListBox1.Items
            'RadListBox1.DataSource = dt
            'Next
            Utilities.LoadCheckBoxList(OtherAudits, da.GetOtherAuditReports("S"), "AuditReportDescription", "AuditReportId", True)
        Else
            chkReports_exec()
        End If
    End Sub

#Region "Library"""

    Private Sub LoadDefaults()
        'Dim DT1 As New DataTable

        'DT1 = Reporting.GetReportFilterDefaults(Session("PKUserId").ToString)

        'If DT1.Rows.Count > 0 Then
        '    Dim Row = DT1.Rows(0)
        '    Try
        '        'pTypeOfConsultant = Row("TypesOfEndoscopists").ToString
        '        RDPFrom.SelectedDate = Row("FromDate").ToString
        '        RDPTo.SelectedDate = Row("ToDate").ToString
        '        'pHideSuppressed = CBool(Row("HideSuppressed").ToString)
        '        chkActivityReport.Checked = CBool(Row("IncludeTherapeutics").ToString)
        '        chkCancellations.Checked = CBool(Row("IncludeIndications").ToString)
        '        chkDailyPatientsPerRoom.Checked = CBool(Row("IncludeIndications").ToString)
        '        chkPatientPathway.Checked = CBool(Row("IncludeIndications").ToString)
        '        DateOrderRadioButton.SelectedValue = Row("DateOrder").ToString
        '        PatientStatusRadioButton.SelectedValue = Row("PatientStatus").ToString
        '        NhsVsPrivateRadioButton.SelectedValue = Row("NHSStatus").ToString

        '        'chkListPatients.Checked = CBool(Row("ListOfPatients").ToString)
        '        'pAnonymise = CBool(Row("Anonymise").ToString)
        '        'pIncludeTherapeutics = CBool(Row("IncludeTherapeutics").ToString)
        '        'pIncludeIndications = CBool(Row("IncludeIndications").ToString)
        '        'pSummaryForPeriod = CBool(Row("SummaryForPeriod").ToString)
        '        'pShowDiagnosisVsTherapeutics = CBool(Row("ShowDiagnosisVsTherapeutics").ToString)

        '    Catch ex As Exception 



        RDPFrom.SelectedDate = DateTime.Now.AddMonths(-6).ToString("dd/MM/yyyy")
        RDPTo.SelectedDate = DateTime.Now.ToString("dd/MM/yyyy")



        'chkReports.Items(0).Enabled = False
        'chkReports.Items(1).Enabled = False
        'chkReports.Items(2).Enabled = False
        'chkReports.Items(3).Enabled = False
        'chkReports.Items(4).Enabled = False

        chkReports.Items(0).Selected = True
        chkReports.Items(1).Selected = True
        chkReports.Items(2).Selected = True
        chkReports.Items(3).Selected = True
        chkReports.Items(4).Selected = True
        chkReports.Items(5).Selected = True
        '    End Try
        'Else
        '    RDPFrom.SelectedDate = "01/01/2018"
        '    RDPTo.SelectedDate = "30/12/2099"
        'End If
        'Dim da As New DataAccess
        'DT1.Dispose()


    End Sub

#End Region

#Region "Buttons"
    Protected Sub RadButtonFilter_Click(sender As Object, e As EventArgs) Handles RadButtonFilter.Click
        Try

            If CDate(Me.RDPFrom.SelectedDate.ToString) <= CDate(Me.RDPTo.SelectedDate.ToString) Then
                SetUserIDFilter(Session("PKUserID").ToString)
                'Dim searchFields As New SchedulerReports.SearchFields
                'Dim operatingHospitals As New List(Of Integer)
                'Dim rooms As New List(Of Integer)

                'Session("ReportFilterDateFrom") = CDate(Me.RDPFrom.SelectedDate.ToString)
                'Session("ReportFilterDateTo") = CDate(Me.RDPTo.SelectedDate.ToString)

                'searchFields.OperatingHospitalIds = RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList
                'searchFields.RoomIds = RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList

                'RadListBox1.SelectedItems.Cast(Of String)

                'Dim counter As Integer = 0

                If chkReports.Items(0).Selected = True Then
                    RadGridActivity.DataSourceID = "DSActivity"
                    DSActivity.DataBind()
                    'counter = counter + 1
                    'Else
                    '    RadGridActivity.DataSourceID = String.Empty
                Else
                    RadGridActivity.DataSourceID = String.Empty
                End If

                If chkReports.Items(1).Selected = True Then
                    RadGridCancellation.DataSourceID = "DSCancellation"
                    DSCancellation.DataBind()
                    'counter = counter + 1
                Else
                    RadGridCancellation.DataSourceID = String.Empty
                End If

                If chkReports.Items(2).Selected = True Then
                    RadGridDna.DataSourceID = "DSDna"
                    DSDna.DataBind()
                    'counter = counter + 1
                Else
                    RadGridDna.DataSourceID = String.Empty
                End If

                If chkReports.Items(3).Selected = True Then
                    RadGridPatientPathway.DataSourceID = "DSPatientPathway"
                    DSPatientPathway.DataBind()
                    'counter = counter + 1
                Else
                    RadGridPatientPathway.DataSourceID = String.Empty
                End If

                If chkReports.Items(4).Selected = True Then
                    RadGridPatientStatus.DataSourceID = "DSPatientStatus"
                    DSPatientStatus.DataBind()
                    'counter = counter + 1
                Else
                    RadGridPatientStatus.DataSourceID = String.Empty
                End If

                If chkReports.Items(5).Selected = True Then
                    RadGridScheduleListCancellation.DataSourceID = "DSScheduleListCancellation"
                    DSScheduleListCancellation.DataBind()
                    'counter = counter + 1
                Else
                    RadGridScheduleListCancellation.DataSourceID = String.Empty
                End If

                ''If chkReports.Items(5).Selected = True Then
                ''    RadGridAudit.DataSourceID = "DSAudit"
                ''    DSAudit.DataBind()
                ''End If

                'RadTabStrip2.MaxDataBindDepth = counter

                RadTabStrip1.Tabs(1).Enabled = True
                'RadButtonExportGrids.Enabled = True
                RadTabStrip1.Tabs(0).Selected = False
                RadTabStrip1.Tabs(1).Selected = True
                RadMultiPage1.SelectedIndex = 1
                'RadButtonExportGrids.Visible = True
                chkReports_exec()
                'RoomName_SelectedIndexChanged(RadListBox1, New EventArgs)

                If RadListBox1.CheckedItems.Count = 0 Then
                    RadNotification1.Show("No operating hospitals selected!")
                    Exit Sub
                End If

                If RadListBox2.CheckedItems.Count = 0 Then
                    RadNotification1.Show("No rooms selected!")
                    Exit Sub
                End If

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

    Protected Sub RoomsRadComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        e.Item.Checked = True
    End Sub

#End Region

    Private Sub RadGrid_ExcelMLExportStylesCreated(ByVal sender As Object, ByVal e As GridExcelBuilder.GridExportExcelMLStyleCreatedArgs) Handles RadGridActivity.ExcelMLExportStylesCreated,
        RadGridCancellation.ExcelMLExportStylesCreated, RadGridPatientPathway.ExcelMLExportStylesCreated, RadGridPatientStatus.ExcelMLExportStylesCreated
    End Sub
    'Private Sub RadGrid_ExcelMLExportStylesCreated(ByVal sender As Object, ByVal e As GridExcelBuilder.GridExportExcelMLStyleCreatedArgs) Handles RadGridActivity.ExcelMLExportStylesCreated

    '    Dim numberStyle As New StyleElement("NumberStyle")
    '    numberStyle.NumberFormat.FormatType = NumberFormatType.General
    '    e.Styles.Add(numberStyle)

    '    Dim percentStyle As New StyleElement("PercentStyle")
    '    percentStyle.NumberFormat.FormatType = NumberFormatType.Percent
    '    e.Styles.Add(percentStyle)

    '    Dim currencyStyle As New StyleElement("CurrencyStyle")
    '    currencyStyle.NumberFormat.FormatType = NumberFormatType.Currency
    '    e.Styles.Add(currencyStyle)
    'End Sub

    Protected Sub RadGridActivity_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim dt = GetActivityQuery(CDate(Me.RDPFrom.SelectedDate.ToString), CDate(Me.RDPTo.SelectedDate.ToString),
                                  String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList),
                                  String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList),
                                  chkHideSuppressedList.Checked,
                                  chkHideSuppressedEndo.Checked)
        RadGridActivity.DataSource = dt
    End Sub
    Protected Sub SetUserIDFilter(ByVal UserID As String)

        Dim sql As String = ""
        Dim sqlQuery1 As String = ""
        Dim DT1 As New DataTable
        Dim sqlcaramba As String = ""
        sqlQuery1 = "Select * From [dbo].[ERS_ReportFilter] Where UserID='" + Session("PKUserId").ToString + "'"
        DT1 = GetData(sqlQuery1)
        Dim operatingHospitalList As String = GetSelectedHospitalIds()
        Dim FromDate = CDate(Me.RDPFrom.SelectedDate.ToString)
        Dim ToDate = CDate(Me.RDPTo.SelectedDate.ToString)
        Dim fromDate1 = "Convert(Date,SubString('" + FromDate + "',7,4)+'-'+SubString('" + FromDate + "',4,2)+'-'+SubString('" + FromDate + "',1,2))"
        Dim ToDate1 = "Convert(Date, SubString('" + ToDate + "',7,4)+'-'+SubString('" + ToDate + "',4,2)+'-'+SubString('" + ToDate + "',1,2)) "
        If DT1.Rows.Count = 0 Then
            sql = "Insert Into ERS_ReportFilter (UserId,operatingHospitalList,FromDate,ToDate ) Values (" + Session("PKUserId").ToString + ",'" + operatingHospitalList + "'," + fromDate1 + "," + ToDate1 + ")"
            Reporting.Transaction(sql)

        Else


            sql = "Update [dbo].[ERS_ReportFilter] Set ReportDate=GetDate(), FromDate=Convert(Date,SubString('" + FromDate + "',7,4)+'-'+SubString('" + FromDate + "',4,2)+'-'+SubString('" + FromDate + "',1,2)) , ToDate=Convert(Date,SubString('" + ToDate + "',7,4)+'-'+SubString('" + ToDate + "',4,2)+'-'+SubString('" + ToDate + "',1,2)) "
            sql = sql + ", HideSuppressed='" + pHideSuppressed.ToString + "'"
            sql = sql + ", TrustId ='" + Session("TrustId") + "'"
            sql = sql + ", operatingHospitalList ='" + operatingHospitalList + "'"
            sql = sql + " WHERE UserID = " + UserID
            Reporting.Transaction(sql)

        End If
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
        For Each Item As RadListBoxItem In RadListBox1.CheckedItems
            operatingHospitalList = operatingHospitalList + "," + Item.Value.ToString
        Next
        Return operatingHospitalList
    End Function
    'Protected Sub RadGridCancellations_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
    '    Dim dt = Reports.GetCancellationQuery(1, 1)
    '    RadGridCancellations.DataSource = dt
    'End Sub

    'Protected Sub RadGridDNAs_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
    '    Dim dt = Reports.GetDnaQuery(1, 1)
    '    RadGridCancellations.DataSource = dt
    'End Sub

    'Protected Sub RadGridPatientPathway_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
    '    'Dim radGrid As RadGrid
    '    'radGrid = TryCast(sender, RadGrid)
    '    Dim dt = Reports.GetPatientPathwayQuery(1, 1)
    '    RadGridPatientPathway.DataSource = dt
    'End Sub

    'Protected Sub RadGridPatientStatus_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
    '    Dim dt = GetPatientStatusQuery(CDate(Me.RDPFrom.SelectedDate.ToString), CDate(Me.RDPTo.SelectedDate.ToString),
    '                              String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList),
    '                              String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList))
    '    RadGridPatientStatus.DataSource = dt
    'End Sub

    Protected Sub RadGridActivity_ItemDataBound(sender As Object, e As GridItemEventArgs)
        '    'Dim item As GridGroupHeaderItem = TryCast(e.Item, GridGroupHeaderItem)
        '    'If (item IsNot Nothing) Then
        '    '    Dim groupDataRow As DataRowView = CType(e.Item.DataItem, DataRowView)
        '    '    item.DataCell.Text = "No of points on template: " + groupDataRow("NoOfPtsOnTemplate").ToString() + item.DataCell.Text = "Remaining slots: " + groupDataRow("RemainingSlots").ToString()
        '    'End If
        Try

        Catch ex As Exception

        End Try
    End Sub

    Protected Sub RadGridCancellation_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try

        Catch ex As Exception

        End Try
    End Sub

    Protected Sub RadGridDna_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try
            'If TypeOf e.Item Is GridGroupHeaderItem Then
            '    Dim item As GridGroupHeaderItem = CType(e.Item, GridGroupHeaderItem)
            '    Dim groupDataRow As DataRowView = CType(e.Item.DataItem, DataRowView)
            '    'item.DataCell.Text = item.DataCell.Text + "; Total: "
            '    item.DataCell.Text = item.DataCell.Text + CType(groupDataRow("NoOfPts"), Decimal).ToString()
            'End If
        Catch ex As Exception

        End Try
    End Sub
    Protected Sub RadGridPatientPathway_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try

        Catch ex As Exception

        End Try
    End Sub

    Protected Sub RadGridPatientStatus_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try

        Catch ex As Exception

        End Try
    End Sub

    Protected Sub RoomName_SelectedIndexChanged(sender As Object, e As EventArgs) Handles RadListBox1.SelectedIndexChanged, chkHideSuppressedList.CheckedChanged, chkHideSuppressedEndo.CheckedChanged

        'Dim dsData As New DataSet
        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand("SCH_reports_rooms_search", connection)
        '    cmd.CommandType = CommandType.StoredProcedure
        '    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HospitalId", .SqlDbType = SqlDbType.Int, .Value = Session("HospitalId"})
        '    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchPhrase", .SqlDbType = SqlDbType.Int, .Value = Me.chk})
        '    Dim adapter = New SqlDataAdapter(cmd)
        '    connection.Open()
        '    adapter.Fill(dsData)
        'End Using
        'If dsData.Tables.Count > 0 Then
        '    Return dsData.Tables(0)
        'End If
        'Return Nothing

        ''strSql = " And (IsEndoscopist1='1' Or IsEndoscopist2='1')"
        'If Me.chkHideSuppressedList.Checked Then
        '    strSql = strSql + " And Active='1'"
        'End If

        'strSql = strSql + " AND Consultant LIKE '%' + ISNULL(@searchPhrase, '') + '%'"
        'strSql = strSql + " Order by Surname "
        'Reporting.ListBox1SQL = Reporting.ConsultantsListBox1 + strSql
        'Reporting.ListBox2SQL = Reporting.ConsultantsListBox2

        'Me.RadListBox1.Items.Clear()
        'Me.RadListBox1.DataBind()

        'Me.SqlDSAllRooms.DataBind()
        'Me.SqlDSSelectedRooms.DataBind()

        'Reporting.SetConsultantType(Me.ComboConsultants.SelectedValue.ToString, Me.cbHideSuppressed.Checked)

        'Me.RadListBox1.Items.Clear()
        Me.RadListBox1.DataBind()

        'Me.RadListBox2.Items.Clear()
        'Dim hospitalsSelected As String = ""
        'For Each hopsitalId As RadListBoxItem In RadListBox1.SelectedItems
        '    hospitalsSelected += CStr(hopsitalId.Index) + ","
        'Next
        'Dim da As New DataAccess
        'RadListBox2.DataSource = da.GetAllRoomsForSelectedHospitals(hospitalsSelected)
        'RadListBox2.DataTextField = "RoomName"
        'RadListBox2.DataValueField = "RoomId"
        RadListBox2.DataBind()

        Me.SqlDSAllRooms.DataBind()
        Me.SqlDSSelectedRooms.DataBind()
    End Sub

    Protected Sub chkReports_exec()

        ''Activity
        If chkReports.Items(0).Selected = False Then
            RadTabStrip2.Tabs(0).Visible = False
        Else
            RadTabStrip2.Tabs(0).Visible = True
            RadTabStrip2.Tabs(0).Selected = True
        End If

        'Cancellation
        If chkReports.Items(1).Selected = False Then
            RadTabStrip2.Tabs(1).Visible = False
        Else
            RadTabStrip2.Tabs(1).Visible = True
        End If

        'DNA
        If Me.chkReports.Items(2).Selected = False Then
            Me.RadTabStrip2.Tabs(2).Visible = False
        Else
            RadTabStrip2.Tabs(2).Visible = True
        End If

        'Patient Pathway
        If Me.chkReports.Items(3).Selected = False Then
            Me.RadTabStrip2.Tabs(3).Visible = False
        Else
            RadTabStrip2.Tabs(3).Visible = True
        End If

        'Patient Status
        If Me.chkReports.Items(4).Selected = False Then
            Me.RadTabStrip2.Tabs(4).Visible = False
        Else
            RadTabStrip2.Tabs(4).Visible = True
        End If
        ' schedule list canncelled
        If Me.chkReports.Items(5).Selected = False Then
            Me.RadTabStrip2.Tabs(5).Visible = False
        Else
            RadTabStrip2.Tabs(5).Visible = True
        End If

        'Now set focus to first report tab selected
        'RadTabStrip2.Tabs(tabSelectionIndex).Selected = True

        ''Audit
        'If Me.chkReports.Items(5).Selected = False Then
        '    Me.RadTabStrip2.Tabs(6).Visible = False
        'Else
        '    Me.RadTabStrip2.Tabs(6).Visible = True
        'End If

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
                'If (annonymousNeeded = True) Then
                '    Dim AnonymousField As String = ConfigurationManager.AppSettings("AnonymousField")
                '    If Not String.IsNullOrEmpty(AnonymousField) Then
                '        Dim ColumnsToBeDeleted As String() = AnonymousField.ToString().Split(",")

                '        For Each ColName As String In ColumnsToBeDeleted
                '            If dt.Columns.Contains(ColName) Then dt.Columns.Remove(ColName)
                '        Next

                '    End If
                'End If

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

    Protected Sub OtherReport_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim radGrid As RadGrid
        Dim da As DataAccess = New DataAccess()
        radGrid = TryCast(sender, RadGrid)
        Dim dt = da.GetOtherAuditReport(radGrid.ID)
        radGrid.DataSource = dt
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

    'Public Function GetActivityQuery() As DataTable
    '    Try

    '        Dim searchFields As New SchedulerReports.SearchFields
    '        Dim operatingHospitals As New List(Of Integer)
    '        Dim rooms As New List(Of Integer)

    '        Session("ReportFilterDateFrom") = CDate(Me.RDPFrom.SelectedDate.ToString)
    '        Session("ReportFilterDateTo") = CDate(Me.RDPTo.SelectedDate.ToString)

    '        searchFields.OperatingHospitalIds = RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList
    '        searchFields.RoomIds = RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList

    '        GetActivityQueries(CDate(Me.RDPFrom.SelectedDate.ToString), CDate(Me.RDPTo.SelectedDate.ToString),
    '                           String.Join(",", searchFields.OperatingHospitalIds), String.Join(",", searchFields.RoomIds))
    '        'Dim dsData As New DataSet

    '        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        '    Dim cmd As New SqlCommand("report_SCH_Activity", connection)
    '        '    cmd.CommandType = CommandType.StoredProcedure

    '        '    'RDPFrom.MinDate = DateTime.Now
    '        '    'RDPFrom.MaxDate = DateTime.Now.AddDays(1000)

    '        '    Dim dateFrom = Session("ReportFilterDateFrom")
    '        '    Dim dateTo = Session("ReportFilterDateFrom")

    '        '    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = dateFrom})
    '        '    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchEndDate", .SqlDbType = SqlDbType.DateTime, .Value = dateTo})
    '        '    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIds", .SqlDbType = SqlDbType.Text, .Value = })
    '        '    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomIds", .SqlDbType = SqlDbType.Text, .Value = roomIds})

    '        '    Dim adapter = New SqlDataAdapter(cmd)
    '        '    connection.Open()
    '        '    adapter.Fill(dsData)
    '        'End Using

    '        'If dsData.Tables.Count > 0 Then
    '        '    Return dsData.Tables(0)
    '        'Else
    '        '    Return Nothing
    '        'End If

    '    Catch ex As Exception
    '        LogManager.LogManagerInstance.LogError("Error in function - GetActivityQuery", ex)
    '    End Try
    'End Function

    'Public Function GetActivityQueries(searchStartDate As Date, searchEndDate As Date, operatingHospitalIds As String, roomIds As String) As DataTable
    '    Try
    '        Dim dsData As New DataSet

    '        Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '            Dim cmd As New SqlCommand("report_SCH_Activity", connection)
    '            cmd.CommandType = CommandType.StoredProcedure

    '            'RDPFrom.MinDate = DateTime.Now
    '            'RDPFrom.MaxDate = DateTime.Now.AddDays(1000)

    '            Dim dateFrom = Session("ReportFilterDateFrom")
    '            Dim dateTo = Session("ReportFilterDateFrom")

    '            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = dateFrom})
    '            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchEndDate", .SqlDbType = SqlDbType.DateTime, .Value = dateTo})
    '            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIds", .SqlDbType = SqlDbType.Text, .Value = operatingHospitalIds})
    '            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomIds", .SqlDbType = SqlDbType.Text, .Value = roomIds})

    '            Dim adapter = New SqlDataAdapter(cmd)
    '            connection.Open()
    '            adapter.Fill(dsData)
    '        End Using

    '        If dsData.Tables.Count > 0 Then
    '            Return dsData.Tables(0)
    '        Else
    '            Return Nothing
    '        End If

    '    Catch ex As Exception
    '        LogManager.LogManagerInstance.LogError("Error loading scheduler report - activity", ex)
    '    End Try
    'End Function

    Public Function GetActivityQuery(searchStart As Date, searchEnd As Date, operatingHospitalIds As String, roomIds As String, hideSuppressedConsultants As Boolean, hideSuppressedEndoscopists As Boolean) As DataTable
        Try
            Dim dsData As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("report_SCH_Activity", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 360 'MH added on 20 Jan 2022 TFS 1857
                'RDPFrom.MinDate = DateTime.Now
                'RDPFrom.MaxDate = DateTime.Now.AddDays(1000)

                'Dim dateFrom = Session("ReportFilterDateFrom")
                'Dim dateTo = Session("ReportFilterDateFrom")

                'SearchFields.OperatingHospitalIds = RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList
                'SearchFields.RoomIds = RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList

                operatingHospitalIds = Session("SchedulerReportsHospitalIds")
                roomIds = Session("SchedulerReportsRoomIds")

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = searchStart})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchEndDate", .SqlDbType = SqlDbType.DateTime, .Value = searchEnd})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIds", .SqlDbType = SqlDbType.Text, .Value = operatingHospitalIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomIds", .SqlDbType = SqlDbType.Text, .Value = roomIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedConsultants", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedConsultants})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedEndoscopists", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedEndoscopists})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - activity", ex)
            Return Nothing
        End Try
    End Function

    Public Function GetCancellationQuery(searchStart As Date, searchEnd As Date, operatingHospitalIds As String, roomIds As String, hideSuppressedConsultants As Boolean, hideSuppressedEndoscopists As Boolean) As DataTable
        Try
            Dim dsData As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("report_SCH_Cancellation", connection)
                cmd.CommandType = CommandType.StoredProcedure

                operatingHospitalIds = Session("SchedulerReportsHospitalIds")
                roomIds = Session("SchedulerReportsRoomIds")

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = searchStart})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchEndDate", .SqlDbType = SqlDbType.DateTime, .Value = searchEnd})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIds", .SqlDbType = SqlDbType.Text, .Value = operatingHospitalIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomIds", .SqlDbType = SqlDbType.Text, .Value = roomIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedConsultants", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedConsultants})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedEndoscopists", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedEndoscopists})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - cancellation", ex)
            Return Nothing
        End Try
    End Function

    Public Function GetScheduleListCancelledData(searchStart As Date, searchEnd As Date, operatingHospitalIds As String, roomIds As String, hideSuppressedConsultants As Boolean, hideSuppressedEndoscopists As Boolean) As DataTable
        Try
            Dim dsData As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("report_SCH_Schedule_list_Cancellation", connection)
                cmd.CommandType = CommandType.StoredProcedure

                operatingHospitalIds = Session("SchedulerReportsHospitalIds")
                roomIds = Session("SchedulerReportsRoomIds")

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = searchStart})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchEndDate", .SqlDbType = SqlDbType.DateTime, .Value = searchEnd})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIds", .SqlDbType = SqlDbType.Text, .Value = operatingHospitalIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomIds", .SqlDbType = SqlDbType.Text, .Value = roomIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedConsultants", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedConsultants})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedEndoscopists", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedEndoscopists})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - cancellation", ex)
            Return Nothing
        End Try
    End Function

    Public Function GetDnaQuery(searchStart As Date, searchEnd As Date, operatingHospitalIds As String, roomIds As String, hideSuppressedConsultants As Boolean, hideSuppressedEndoscopists As Boolean) As DataTable
        Try
            Dim dsData As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("report_SCH_DNA", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 360 'MH added on 20 Jan 2022
                operatingHospitalIds = Session("SchedulerReportsHospitalIds")
                roomIds = Session("SchedulerReportsRoomIds")

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = searchStart})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchEndDate", .SqlDbType = SqlDbType.DateTime, .Value = searchEnd})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIds", .SqlDbType = SqlDbType.Text, .Value = operatingHospitalIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomIds", .SqlDbType = SqlDbType.Text, .Value = roomIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedConsultants", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedConsultants})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedEndoscopists", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedEndoscopists})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - dna", ex)
            Return Nothing
        End Try
    End Function

    Public Function GetPatientPathwayQuery(searchStart As Date, searchEnd As Date, operatingHospitalIds As String, roomIds As String, hideSuppressedConsultants As Boolean, hideSuppressedEndoscopists As Boolean) As DataTable
        Try
            Dim dsData As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("report_SCH_PatientPathway", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 360 'MH added on 20 Jan 2022 TFS 1857
                operatingHospitalIds = Session("SchedulerReportsHospitalIds")
                roomIds = Session("SchedulerReportsRoomIds")

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = searchStart})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchEndDate", .SqlDbType = SqlDbType.DateTime, .Value = searchEnd})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIds", .SqlDbType = SqlDbType.Text, .Value = operatingHospitalIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomIds", .SqlDbType = SqlDbType.Text, .Value = roomIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedConsultants", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedConsultants})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedEndoscopists", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedEndoscopists})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - patient pathway", ex)
            Return Nothing
        End Try
    End Function

    Public Function GetPatientStatusQuery(searchStart As Date, searchEnd As Date, operatingHospitalIds As String, roomIds As String, hideSuppressedConsultants As Boolean, hideSuppressedEndoscopists As Boolean) As DataTable
        Try
            Dim dsData As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("report_SCH_PatientStatus", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 360 'MH added on 20 Jan 2022 TFS 1857
                operatingHospitalIds = Session("SchedulerReportsHospitalIds")
                roomIds = Session("SchedulerReportsRoomIds")

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchStartDate", .SqlDbType = SqlDbType.DateTime, .Value = searchStart})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SearchEndDate", .SqlDbType = SqlDbType.DateTime, .Value = searchEnd})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIds", .SqlDbType = SqlDbType.Text, .Value = operatingHospitalIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@RoomIds", .SqlDbType = SqlDbType.Text, .Value = roomIds})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedConsultants", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedConsultants})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HideSuppressedEndoscopists", .SqlDbType = SqlDbType.Bit, .Value = hideSuppressedEndoscopists})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - patient status", ex)
            Return Nothing
        End Try
    End Function

    Protected Sub DSActivity_OnSelecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        DSActivity.SelectParameters("operatingHospitalIds").DefaultValue = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        DSActivity.SelectParameters("roomIds").DefaultValue = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)

        'Dim searchFields As New SchedulerReports.SearchFields
        'searchFields.OperatingHospitalIds = RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList
        'searchFields.RoomIds = RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList

        Session("SchedulerReportsHospitalIds") = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        Session("SchedulerReportsRoomIds") = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)

    End Sub

    Protected Sub DSCancellation_OnSelecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        DSCancellation.SelectParameters("operatingHospitalIds").DefaultValue = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        DSCancellation.SelectParameters("roomIds").DefaultValue = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)

        Session("SchedulerReportsHospitalIds") = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        Session("SchedulerReportsRoomIds") = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
    End Sub
    Protected Sub DSScheduleListCancellation_OnSelecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        DSScheduleListCancellation.SelectParameters("operatingHospitalIds").DefaultValue = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        DSScheduleListCancellation.SelectParameters("roomIds").DefaultValue = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)

        Session("SchedulerReportsHospitalIds") = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        Session("SchedulerReportsRoomIds") = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
    End Sub


    Protected Sub DSDna_OnSelecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        DSDna.SelectParameters("operatingHospitalIds").DefaultValue = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        DSDna.SelectParameters("roomIds").DefaultValue = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)

        Session("SchedulerReportsHospitalIds") = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        Session("SchedulerReportsRoomIds") = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
    End Sub

    Protected Sub DSPatientPathway_OnSelecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        DSPatientPathway.SelectParameters("operatingHospitalIds").DefaultValue = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        DSPatientPathway.SelectParameters("roomIds").DefaultValue = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)

        Session("SchedulerReportsHospitalIds") = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        Session("SchedulerReportsRoomIds") = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
    End Sub

    Protected Sub DSPatientStatus_OnSelecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        DSPatientStatus.SelectParameters("operatingHospitalIds").DefaultValue = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        DSPatientStatus.SelectParameters("roomIds").DefaultValue = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)

        Session("SchedulerReportsHospitalIds") = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
        Session("SchedulerReportsRoomIds") = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
    End Sub

    Private Sub RadListBox1_ItemCheck(sender As Object, e As RadListBoxItemEventArgs) Handles RadListBox1.ItemCheck
        'If RadListBox1.CheckedItems.Count > 0 Then
        RoomClear_Click(Nothing, Nothing)
        'End If
    End Sub

    Protected Sub RadListBox1_CheckAllCheck(sender As Object, e As RadListBoxCheckAllCheckEventArgs)
        If e.CheckAllChecked Then
            Dim hospitalsSelected As String = ""
            For Each itm As RadListBoxItem In RadListBox1.CheckedItems
                If itm.Checked Then
                    hospitalsSelected += itm.Value & ","
                End If
            Next

            hospitalsSelected = hospitalsSelected.Remove(hospitalsSelected.Length - 1)
            Dim da As New DataAccess_Sch
            RadListBox2.DataSource = da.GetAllRoomsForSelectedHospitals(hospitalsSelected)
            RadListBox2.DataTextField = "RoomName"
            RadListBox2.DataValueField = "RoomId"
            RadListBox2.DataBind()
        Else
            RadListBox2.Items.Clear()
        End If
    End Sub
    Protected Sub HospitalSearchButton_Click(sender As Object, e As EventArgs)
        Dim da As New DataAccess()
        Dim dt = da.GetOperatingHospitals()
        Dim filterExpression As String = "HospitalName LIKE '%" & ISMFilter.Text & "%'"
        dt.DefaultView.RowFilter = filterExpression
        dt = dt.DefaultView.ToTable()
        RadListBox1.DataSource = dt
        RadListBox1.DataKeyField = "HospitalName"
        RadListBox1.DataValueField = "OperatingHospitalId"
        RadListBox1.DataBind()
        RoomClear_Click(Nothing, Nothing)
    End Sub

    Protected Sub RoomClear_Click(sender As Object, e As EventArgs)
        'RadListBox2.Items.Clear()
        RoomSearchButton_Click(Nothing, Nothing)
        'Dim hospitalsSelected As String = ""
        'For Each itm As RadListBoxItem In RadListBox1.CheckedItems
        '    If itm.Checked Then
        '        hospitalsSelected += itm.Value & ","
        '    End If
        'Next
        'If hospitalsSelected.Length > 0 Then
        '    hospitalsSelected = hospitalsSelected.Remove(hospitalsSelected.Length - 1)
        'End If
        'Dim da As New DataAccess_Sch
        'RadListBox2.DataSource = da.GetAllRoomsForSelectedHospitals(hospitalsSelected)
        'RadListBox2.DataTextField = "RoomName"
        'RadListBox2.DataValueField = "RoomId"
        'RadListBox2.DataBind()
    End Sub

    Protected Sub HospitalClear_Click(sender As Object, e As EventArgs)
        ISMFilter.Text = ""
        RoomClear.Text = ""
        HospitalSearchButton_Click(Nothing, Nothing)
    End Sub

    'Private Sub RadGridDna_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles RadGridDna.ItemDataBound
    '    If TypeOf e.Item Is GridGroupHeaderItem Then
    '        Dim item As GridGroupHeaderItem = CType(e.Item, GridGroupHeaderItem)
    '        Dim groupDataRow As DataRowView = CType(e.Item.DataItem, DataRowView)
    '        item.DataCell.Text = item.DataCell.Text + "; Total: "
    '        item.DataCell.Text = item.DataCell.Text + CType(groupDataRow("total"), Decimal).ToString()
    '    End If
    'End Sub

    'Protected Sub DSAudit_OnSelecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
    '    DSAudit.SelectParameters("operatingHospitalIds").DefaultValue = String.Join(",", RadListBox1.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
    '    DSAudit.SelectParameters("roomIds").DefaultValue = String.Join(",", RadListBox2.Items.Where(Function(x) x.Checked).Select(Function(x) CInt(x.Value)).ToList)
    'End Sub

    Private Sub RoomSearchButton_Click(sender As Object, e As EventArgs) Handles RoomSearchButton.Click
        'If RadListBox1.CheckedItems.Count = 0 Then
        '    Utilities.SetNotificationStyle(RadNotification1, "No hospital selected!", True, "Please correct")
        '    RadNotification1.Show()
        '    Exit Sub
        'End If
        Dim hospitalsSelected As String = ""
        For Each itm As RadListBoxItem In RadListBox1.CheckedItems
            If itm.Checked Then
                hospitalsSelected += itm.Value & ","
            End If
        Next
        If hospitalsSelected.Length > 0 Then
            hospitalsSelected = hospitalsSelected.Remove(hospitalsSelected.Length - 1)
        End If
        If Not String.IsNullOrWhiteSpace(RadTextBox1.Text) Then
            'If RadTextBox1.Text.Length < 3 Then
            '    Utilities.SetNotificationStyle(RadNotification1, "Enter at least 3 characters!", True, "Please correct")
            '    RadNotification1.Show()
            '    Exit Sub
            'End If
            Dim da As New Reporting
            RadListBox2.DataSource = da.GetRoomsListBox2(RadTextBox1.Text, hospitalsSelected)
            'search term
            'selcted hospitals
        Else
            'filter on all
            Dim da As New DataAccess_Sch
            RadListBox2.DataSource = da.GetAllRoomsForSelectedHospitals(hospitalsSelected)
        End If

        RadListBox2.DataTextField = "RoomName"
        RadListBox2.DataValueField = "RoomId"
        RadListBox2.DataBind()
    End Sub

End Class