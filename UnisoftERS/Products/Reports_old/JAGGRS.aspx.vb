Imports Telerik.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI
Imports System.Web
Imports System.Drawing
Imports xls = Telerik.Web.UI.ExportInfrastructure
Imports System.IO
Imports System.Data.OleDb
Imports System
Imports System.Globalization
Imports System.Data.SqlClient
Imports System.Web.Services

Public Class JAGGRS
    Inherits System.Web.UI.Page
    Public SQLString As String = "SELECT ReportID As UserID, Consultant, Active, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_Consultants Where Consultant<>'(None)'"
    Private Shared ReadOnly IndexRowItemStart As Integer = 1

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/")
        Else
            SUID.Text = Session("PKUserId").ToString
        End If
        If RDPFrom.SelectedDate.ToString = "" Then
            Me.LoadDefaultsFromDB()
        End If
    End Sub

#Region "Connection Strings Properties"
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
#End Region
#Region "Library"""
    Private pFromDate As String = ""
    Private pToDate As String = ""
    Private pTypeOfConsultant As Integer = 0
    Private pHideSuppressed As Boolean = False
    Private pGastroscopy As Boolean = True
    Private pPEGPEJ As Boolean = True
    Private pERCP As Boolean = True
    Private pColonoscopy As Boolean = True
    Private pSigmoidoscopy As Boolean = True
    Private pBowel As Boolean = True
    Private pStandard As Boolean = True
    Private pBoston As Boolean = False
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
    Public Property Standard() As Boolean
        Get
            Return pStandard
        End Get
        Set(ByVal Value As Boolean)
            pStandard = Value
        End Set
    End Property
    Public Property Boston() As Boolean
        Get
            Return pBoston
        End Get
        Set(ByVal Value As Boolean)
            pBoston = Value
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
        If Session("PKUserId") IsNot Nothing Then
            sqlQuery1 = "Select * From [dbo].[ERS_ReportFilter] Where UserID='" + Session("PKUserId").ToString + "'"
            DT1 = GetData(sqlQuery1)
            If DT1.Rows.Count = 0 Then
                CreateUserIDFilter(Session("PKUserId").ToString)
                DT1 = GetData(sqlQuery1)
            End If
            For Each Row In DT1.Rows
                Try
                    iTypeOfConsultant = Row("TypesOfEndoscopists").ToString
                    pFromDate = Row("FromDate").ToString
                    pToDate = Row("ToDate").ToString
                    pHideSuppressed = CBool(Row("HideSuppressed").ToString)
                    pGastroscopy = CBool(Row("OGD").ToString)
                    pSigmoidoscopy = CBool(Row("Sigmoidoscopy").ToString)
                    pERCP = CBool(Row("ERCP").ToString)
                    pColonoscopy = CBool(Row("Colonoscopy").ToString)
                    pBowel = CBool(Row("Bowel").ToString)
                    pPEGPEJ = CBool(Row("PEGPEJ").ToString)
                    pStandard = CBool(Row("BowelStandard").ToString)
                    pBoston = CBool(Row("BowelBoston").ToString)
                    pAnonymise = CBool(Row("Anonymise").ToString)
                Catch ex As Exception
                    pFromDate = "01/01/1980"
                    pToDate = "31/12/2099"
                End Try
            Next Row
            sqlQuery2 = "Select * From [dbo].[ERS_ReportConsultants] Where UserID='" + Session("PKUserId").ToString + "'"
            DT2 = GetData(sqlQuery2)
            If DT2.Rows.Count = 0 Then
                CreateUserIDFilter(Session("PKUserId").ToString)
                DT2 = GetData(sqlQuery2)
            End If
            For Each Row In DT1.Rows

            Next Row
        End If
        DT1.Dispose()
        DT2.Dispose()
        Try
            Me.RDPFrom.SelectedDate = pFromDate.ToString
            Me.RDPTo.SelectedDate = pToDate.ToString
        Catch ex As Exception
            RDPFrom.Culture = New CultureInfo("en-GB")
            RDPTo.Culture = New CultureInfo("en-GB")
            Me.RDPFrom.SelectedDate = "01/01/1980"
            Me.RDPTo.SelectedDate = "31/12/2099"
        End Try
        cbHideSuppressed.Checked = pHideSuppressed
        cbRandomize.Checked = pAnonymise
        ComboConsultants.SelectedIndex = iTypeOfConsultant
        cbReports.Items(0).Selected = pGastroscopy
        cbReports.Items(1).Selected = pPEGPEJ
        cbReports.Items(2).Selected = pERCP
        cbReports.Items(3).Selected = pSigmoidoscopy
        cbReports.Items(4).Selected = pColonoscopy
        cbReports.Items(5).Selected = pBowel
        If pStandard Then
            RadioBowel.Items(0).Selected = True
            RadioBowel.Items(1).Selected = False
        Else
            RadioBowel.Items(0).Selected = False
            RadioBowel.Items(1).Selected = True
        End If
        ComboConsultants.Items(0).Selected = True
        cbReports_exec()
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
    Protected Sub CreateUserIDFilter(ByVal UserID As String)
        Dim sql1 As String = "Delete [dbo].[ERS_ReportFilter] Where UserID In (0, " + Session("PKUserID").ToString + ")"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd1 As New SqlCommand(sql1, connection)
            cmd1.CommandType = CommandType.Text
            cmd1.Connection.Open()
            cmd1.ExecuteNonQuery()
        End Using
        Dim sql2 As String = "Insert Into [dbo].[ERS_ReportFilter] (UserID) Select UserID=" + Session("PKUserId").ToString
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd2 As New SqlCommand(sql2, connection)
            cmd2.CommandType = CommandType.Text
            'cmd.Parameters.Add(New SqlParameter("@userId", UserID))
            cmd2.Connection.Open()
            cmd2.ExecuteNonQuery()
        End Using
    End Sub
    Protected Sub SetUserIDFilter(ByVal UserID As String)
        ', ByVal FromDate As String, ByVal ToDate As String
        Try
            pFromDate = RDPFrom.SelectedDate
        Catch ex As Exception
            pFromDate = "01/01/1980"
        End Try
        Try
            pToDate = RDPTo.SelectedDate
        Catch ex As Exception
            pToDate = "31/12/2099"
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
        If Me.cbReports.Items(5).Selected Then
            pBowel = True
        Else
            pBowel = False
        End If
        If Me.RadioBowel.Items(0).Selected Then
            pStandard = True
            pBoston = False
        Else
            pStandard = False
            pBoston = True
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
        sql = "Update [dbo].[ERS_ReportFilter] Set ReportDate=GetDate(), FromDate=Convert(Date,SubString('" + FromDate + "',7,4)+'-'+SubString('" + FromDate + "',4,2)+'-'+SubString('" + FromDate + "',1,2)) , ToDate=Convert(Date,SubString('" + ToDate + "',7,4)+'-'+SubString('" + ToDate + "',4,2)+'-'+SubString('" + ToDate + "',1,2)) "
        sql = sql + ", HideSuppressed='" + pHideSuppressed.ToString + "'"
        sql = sql + ", OGD='" + pGastroscopy.ToString + "'"
        sql = sql + ", PEGPEJ='" + pPEGPEJ.ToString + "'"
        sql = sql + ", ERCP='" + pERCP.ToString + "'"
        sql = sql + ", Colonoscopy='" + pColonoscopy.ToString + "'"
        sql = sql + ", Sigmoidoscopy='" + pSigmoidoscopy.ToString + "'"
        sql = sql + ", Bowel='" + pBowel.ToString + "'"
        sql = sql + ", BowelStandard='" + pStandard.ToString + "'"
        sql = sql + ", BowelBoston='" + pBoston.ToString + "'"
        sql = sql + ", Anonymise='" + pAnonymise.ToString + "'"
        sql = sql + ", TypesOfEndoscopists='" + iTypeOfConsultant.ToString + "'"
        sql = sql + " WHERE UserID = " + UserID
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
        sql = "Delete [dbo].[ERS_ReportConsultants] Where UserID In (0, " + Session("PKUserID").ToString + ")"
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
        sql = "Insert Into [dbo].[ERS_ReportConsultants] (UserID, ConsultantID, AnonimizedID) "
        sql = sql + "Select UserID=" + UserID + ", ConsultantID=ReportID, AnonimizedID=ReportID From [dbo].[v_rep_JAG_Consultants] Where ReportID>0 And ReportID Not In (0"
        For Each Item As RadListBoxItem In RadListBox1.Items
            sql = sql + "," + Item.Value.ToString
        Next
        sql = sql + ") " '+ sqlcaramba
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
        If cbRandomize.Checked = True Then
            sql = "Exec report_Anonimize " + Session("PKUserId").ToString + " ,1"
        Else
            sql = "Exec report_Anonimize " + Session("PKUserId").ToString + " ,0"
        End If
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd2 As New SqlCommand(sql, connection)
            cmd2.CommandType = CommandType.Text
            cmd2.Connection.Open()
            cmd2.ExecuteNonQuery()
        End Using
        Me.LoadDefaultsFromDB()
    End Sub
    Protected Sub TypeOfConsultant_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ComboConsultants.SelectedIndexChanged, cbHideSuppressed.CheckedChanged
        Dim StrSql1 As String = "SELECT ReportID, Consultant, Active, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_JAG_Consultants WHERE ReportID Not In (Select ConsultantID From ERS_ReportConsultants Where UserID=@UserID) And (Consultant <> '(None)')"
        Dim StrSql2 As String = "SELECT ReportID, Consultant, Active, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_JAG_Consultants WHERE ReportID In (Select ConsultantID From ERS_ReportConsultants Where UserID=@UserID) And (Consultant <> '(None)')"
        If Me.cbHideSuppressed.Checked = True Then
            StrSql1 = StrSql1 + " And Active='1'"
            StrSql2 = StrSql2 + " And Active='1'"
        End If
        Select Case Me.ComboConsultants.SelectedValue.ToString
            Case "AllConsultants"
                StrSql1 = StrSql1 + " And ((IsEndoscopist1='1') Or (IsEndoscopist2='1') Or (IsListConsultant='1') Or (IsAssistantOrTrainee='1') Or (IsNurse1='1') Or (IsNurse2='1'))"
                StrSql2 = StrSql2 + " And ((IsEndoscopist1='1') Or (IsEndoscopist2='1') Or (IsListConsultant='1') Or (IsAssistantOrTrainee='1') Or (IsNurse1='1') Or (IsNurse2='1'))"
            Case "Endoscopist1"
                StrSql1 = StrSql1 + " And IsEndoscopist1='1'"
                StrSql2 = StrSql2 + " And IsEndoscopist1='1'"
            Case "Endoscopist2"
                StrSql1 = StrSql1 + " And IsEndoscopist2='1'"
                StrSql2 = StrSql2 + " And IsEndoscopist2='1'"
            Case "ListConsultant"
                StrSql1 = StrSql1 + " And IsListConsultant='1'"
                StrSql2 = StrSql2 + " And IsListConsultant='1'"
            Case "Assistant"
                StrSql1 = StrSql1 + " And IsAssistantOrTrainee='1'"
                StrSql2 = StrSql2 + " And IsAssistantOrTrainee='1'"
            Case "Nurse1"
                StrSql1 = StrSql1 + " And IsNurse1='1'"
                StrSql2 = StrSql2 + " And IsNurse1='1'"
            Case "Nurse2"
                StrSql1 = StrSql1 + " And IsNurse2='1'"
                StrSql2 = StrSql2 + " And IsNurse2='1'"
            Case Else
        End Select
        'SQLString = StrSql1
        Me.RadListBox2.Items.Clear()
        'Me.SqlDSAllConsultants.ConnectionString = DataAccess.ConnectionStr
        Reports.ConsultantsQry1 = StrSql1
        Reports.ConsultantsQry2 = StrSql2
        Me.SqlDSAllConsultants.DataBind()
        'Me.SqlDSSelectedConsultants.ConnectionString = DataAccess.ConnectionStr
        'Me.SqlDSSelectedConsultants.SelectCommand = StrSql2
        Me.SqlDSSelectedConsultants.DataBind()
        'SetUserIDFilter(Session("PKUserID"))
    End Sub


#End Region
    '    '------- ▼ Those functions could be unnecessary ▼ -------
    '    '-------   Check before delete                    -------

    Private Function GetDT(ByVal SqlQuery As String) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConfigurationManager.ConnectionStrings("Gastro_DB").ConnectionString)
            Dim cmd As New SqlCommand(SqlQuery, connection)
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

    Protected Sub cbReports_exec()
        If Me.cbReports.Items(0).Selected = False Then
            Me.RadTabStrip2.Tabs(0).Visible = False
        Else
            Me.RadTabStrip2.Tabs(0).Visible = True
        End If
        If Me.cbReports.Items(1).Selected = False Then
            Me.RadTabStrip2.Tabs(1).Visible = False
        Else
            Me.RadTabStrip2.Tabs(1).Visible = True
        End If
        If Me.cbReports.Items(2).Selected = False Then
            Me.RadTabStrip2.Tabs(2).Visible = False
        Else
            Me.RadTabStrip2.Tabs(2).Visible = True
        End If
        If Me.cbReports.Items(3).Selected = False Then
            Me.RadTabStrip2.Tabs(3).Visible = False
        Else
            Me.RadTabStrip2.Tabs(3).Visible = True
        End If
        If Me.cbReports.Items(4).Selected = False Then
            Me.RadTabStrip2.Tabs(4).Visible = False
        Else
            Me.RadTabStrip2.Tabs(4).Visible = True
        End If
        If Me.cbReports.Items(5).Selected = False Then
            'Me.RadioBowel.Visible = False
            Me.RadTabStrip2.Tabs(5).Visible = False
            Me.RadTabStrip2.Tabs(6).Visible = False
        Else
            'Me.RadioBowel.Visible = True
            If Me.RadioBowel.Items(0).Selected Then
                Me.RadTabStrip2.Tabs(5).Visible = True
                Me.RadTabStrip2.Tabs(6).Visible = False
            Else
                Me.RadTabStrip2.Tabs(5).Visible = False
                Me.RadTabStrip2.Tabs(6).Visible = True
            End If
        End If
    End Sub

#Region "Export multiple Grid"

    Private Estructura As New xls.ExportStructure
    Private Tabla As New ExportInfrastructure.Table
    Private GridControlsFound As New List(Of RadGrid)
    Private Row As Integer = 1
    Private Col As Integer = 1
    Private IsFirstItem As Boolean = True

    Protected Sub RadButtonExportGrids_Click(sender As Object, e As EventArgs) Handles RadButtonExportGrids.Click
        '    '------- ▼ Adding RadGrids to GridControlsFound ▼ -------
        If cbReports.Items(0).Selected = True Then
            GridControlsFound.Add(RadGridGastroscopy)
        End If
        If cbReports.Items(1).Selected = True Then
            GridControlsFound.Add(RadGridPEGPEJ)
        End If
        If cbReports.Items(2).Selected = True Then
            GridControlsFound.Add(RadGridERCP)
        End If
        If cbReports.Items(3).Selected = True Then
            GridControlsFound.Add(RadGridSigmoidoscopy)
        End If
        If cbReports.Items(4).Selected = True Then
            GridControlsFound.Add(RadGridColonoscopy)
        End If
        If cbReports.Items(5).Selected = True Then
            If RadioBowel.Items(0).Selected Then
                GridControlsFound.Add(RadGridStandard)
            Else
                GridControlsFound.Add(RadGridBoston1)
            End If
        End If
        GridControlsFound.Add(RadGridEndoscopists)
        '    '------- ▼ Create list of tables ▼ ------- In progress
        'Dim SingleTable As xls.Table
        'GridHeaderItem headerItem = grid.MasterTableView.GetItems(GridItemType.Header)[0] as GridHeaderItem;
        For Each G In GridControlsFound
            G.AllowPaging = False
            G.CurrentPageIndex = 0
            G.Rebind()
            GenerateTable(G)
        Next
        '    '------- ▼ Generating Excel Sheet ▼ -------
        Dim Renderer As New xls.XlsBiffRenderer(Estructura)
        Dim RenderedBytes As Byte() = Renderer.Render
        Response.Clear()
        Response.AppendHeader("Content-Disposition:", "attachment; filename=JAG GRS Report.xls")
        Response.ContentType = "application/vnd.ms-excel"
        Response.BinaryWrite(RenderedBytes)
        Response.End()
    End Sub

    Protected Sub GenerateTable(ByVal G As RadGrid)
        Dim SingleTable As New xls.Table(G.ID)
        Dim Title1 As New xls.ExportStyle
        Dim Foot As New xls.ExportStyle
        Title1.Font.Name = "Arial"
        Title1.Font.Size = 14
        Title1.Font.Bold = True
        Title1.BorderBottomColor = Color.Black
        Title1.BorderRightColor = Color.Black
        Title1.BorderLeftColor = Color.Black
        Title1.BorderTopColor = Color.Black
        Title1.BorderBottomStyle = BorderStyle.Solid
        Title1.BorderRightStyle = BorderStyle.Solid
        Title1.BorderLeftStyle = BorderStyle.Solid
        Title1.BorderTopStyle = BorderStyle.Solid
        Title1.BorderTopWidth = 1
        Title1.BorderRightWidth = 1
        Title1.BorderLeftWidth = 1
        Title1.BorderBottomWidth = 1
        Title1.BackColor = Color.White
        Title1.ForeColor = Color.FromArgb(0, 0, 114, 198)
        Title1.HorizontalAlign = HorizontalAlign.Left
        Foot.Font.Name = "Arial"
        Foot.Font.Size = 8
        Foot.BackColor = Color.White
        Foot.ForeColor = Color.FromArgb(0, 0, 114, 198)
        Dim Title2 As New xls.ExportStyle
        Title2.Font.Name = "Arial"
        Title2.Font.Size = 13
        Title2.BorderBottomColor = Color.Black
        Title2.BorderRightColor = Color.Black
        Title2.BorderLeftColor = Color.Black
        Title2.BorderTopColor = Color.Black
        Title2.BorderBottomStyle = BorderStyle.Solid
        Title2.BorderRightStyle = BorderStyle.Solid
        Title2.BorderLeftStyle = BorderStyle.Solid
        Title2.BorderTopStyle = BorderStyle.Solid
        Title2.BorderTopWidth = 1
        Title2.BorderRightWidth = 1
        Title2.BorderLeftWidth = 1
        Title2.BorderBottomWidth = 1
        Title2.BackColor = Color.White
        Title2.ForeColor = Color.FromArgb(0, 0, 114, 198)
        Title2.HorizontalAlign = HorizontalAlign.Left
        Dim Head As New xls.ExportStyle
        Head.BorderBottomColor = Color.Black
        Head.BorderRightColor = Color.Black
        Head.BorderLeftColor = Color.Black
        Head.BorderTopColor = Color.Black
        Head.BorderBottomStyle = BorderStyle.Solid
        Head.BorderRightStyle = BorderStyle.Solid
        Head.BorderLeftStyle = BorderStyle.Solid
        Head.BorderTopStyle = BorderStyle.Solid
        Head.BorderTopWidth = 1
        Head.BorderRightWidth = 1
        Head.BorderLeftWidth = 1
        Head.BorderBottomWidth = 1
        Head.BackColor = Color.FromArgb(0, 0, 114, 198)
        Head.ForeColor = Color.White
        Head.HorizontalAlign = HorizontalAlign.Center
        Head.VerticalAlign = VerticalAlign.Bottom
        Dim Cell As New xls.ExportStyle
        Cell.BorderBottomColor = Color.Black
        Cell.BorderRightColor = Color.Black
        Cell.BorderLeftColor = Color.Black
        Cell.BorderTopColor = Color.Black
        Cell.BorderBottomStyle = BorderStyle.Solid
        Cell.BorderRightStyle = BorderStyle.Solid
        Cell.BorderLeftStyle = BorderStyle.Solid
        Cell.BorderTopStyle = BorderStyle.Solid
        Cell.BorderTopWidth = 1
        Cell.BorderRightWidth = 1
        Cell.BorderLeftWidth = 1
        Cell.BorderBottomWidth = 1
        Cell.BackColor = Color.Beige
        Cell.ForeColor = Color.Brown
        Cell.HorizontalAlign = HorizontalAlign.Center
        Dim Detail As New xls.ExportStyle
        Detail.BorderBottomColor = Color.Black
        Detail.BorderRightColor = Color.Black
        Detail.BorderLeftColor = Color.Black
        Detail.BorderTopColor = Color.Black
        Detail.BorderBottomStyle = BorderStyle.Solid
        Detail.BorderRightStyle = BorderStyle.Solid
        Detail.BorderLeftStyle = BorderStyle.Solid
        Detail.BorderTopStyle = BorderStyle.Solid
        Detail.BorderTopWidth = 1
        Detail.BorderRightWidth = 1
        Detail.BorderLeftWidth = 1
        Detail.BorderBottomWidth = 1
        Detail.BackColor = Color.White
        Detail.ForeColor = Color.Black
        Detail.Font.Bold = True
        Detail.HorizontalAlign = HorizontalAlign.Left
        Dim Cols As Int16 = 0
        SingleTable.Rows.Item(1).Height = 25
        SingleTable.Rows.Item(2).Height = 25
        SingleTable.Rows.Item(3).Height = 65
        Dim Title As String = ""
        Dim SubTitle As String = "From " + Mid(Me.RDPFrom.SelectedDate.ToString, 1, 10) + " to " + Mid(Me.RDPTo.SelectedDate.ToString, 1, 10)
        Dim Signature As String = "Compiled on the " + Now.ToString + " using the ERS Viewer Tool (Copyright © 1997 - 2016 Unisoft Computers Ltd)"
        Cols = G.Columns.Count
        Dim Table0 As DataTable = GetDataTable("SELECT B.AnonimizedID As UserID, Consultant FROM v_rep_JAG_Consultants A, ERS_ReportConsultants B WHERE A.ReportID=B.ConsultantID And B.UserID=" + Session("PKUserId").ToString + " Order By 1")
        Dim row0 As DataRow
        Dim LastRow As Integer = 0
        Dim LastEndoscopistRow As Integer = 0
        Dim MaxCols As Integer = 0
        Dim LastBowelRow As Integer = 0
        Select Case G.ID
            Case "RadGridEndoscopists"
                Title = "Endoscopists"
                'SubTitle = "Cowering the whole database"
                SingleTable.Title = "Endoscopists"
                SingleTable.Cells("A3").Value = "Report position"
                SingleTable.Cells("A3").TextWrap = True
                SingleTable.Cells("B3").Value = "Name"
                SingleTable.Cells("B3").TextWrap = True
                SingleTable.Columns.Item(1).Width = 20
                SingleTable.Columns.Item(2).Width = 30
                Row = 4
                LastEndoscopistRow = Table0.Rows.Count + 1
                For Each row0 In Table0.Rows
                    SingleTable.Cells(1, Row).Value = row0("UserID").ToString
                    SingleTable.Cells(1, Row).Style = Cell
                    SingleTable.Cells(1, Row).TextWrap = True
                    SingleTable.Cells(2, Row).Value = row0("Consultant").ToString
                    SingleTable.Cells(2, Row).Style = Cell
                    SingleTable.Cells(2, Row).TextWrap = True
                    Row = Row + 1
                Next
            Case "RadGridGastroscopy"
                Title = "JAG/GRS Report: Gastroscopy Results"
                'SubTitle = "Cowering the whole database"
                SingleTable.Title = "Gastroscopy"
                SingleTable.Columns.Item(1).Width = 12
                SingleTable.Columns.Item(2).Width = 20
                SingleTable.Columns.Item(3).Width = 12
                SingleTable.Columns.Item(4).Width = 12
                SingleTable.Columns.Item(5).Width = 12
                SingleTable.Columns.Item(6).Width = 12
                SingleTable.Columns.Item(7).Width = 12
                SingleTable.Columns.Item(8).Width = 12
                SingleTable.Columns.Item(9).Width = 20
                SingleTable.Columns.Item(10).Width = 12
                SingleTable.Columns.Item(11).Width = 15
                SingleTable.Columns.Item(12).Width = 15
                SingleTable.Columns.Item(13).Width = 15
                SingleTable.Columns.Item(14).Width = 15
                SingleTable.Columns.Item(15).Width = 20
            Case "RadGridPEGPEJ"
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 20
                SingleTable.Columns.Item(3).Width = 15
                SingleTable.Columns.Item(4).Width = 15
                SingleTable.Columns.Item(5).Width = 15
                SingleTable.Columns.Item(6).Width = 25
                Title = "JAG/GRS Report: PEG/PEJ Results"
                'SubTitle = "Covering the selected criteria"
                SingleTable.Title = "PEG PEJ"
            Case "RadGridERCP"
                Title = "JAG/GRS Report: ERCP Results"
                'SubTitle = "Covering the selected criteria"
                SingleTable.Title = "ERCP"
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 20
                SingleTable.Columns.Item(2).Width = 15
                SingleTable.Columns.Item(3).Width = 25
                SingleTable.Columns.Item(4).Width = 25
                SingleTable.Columns.Item(5).Width = 25
                SingleTable.Columns.Item(6).Width = 25
                SingleTable.Columns.Item(7).Width = 25
                SingleTable.Columns.Item(8).Width = 25
                SingleTable.Columns.Item(9).Width = 30
                SingleTable.Columns.Item(10).Width = 15
                SingleTable.Columns.Item(11).Width = 30
                SingleTable.Columns.Item(12).Width = 30
                SingleTable.Columns.Item(13).Width = 30
                SingleTable.Columns.Item(15).Width = 30
                SingleTable.Columns.Item(14).Width = 25
            Case "RadGridSigmoidoscopy"
                Title = "JAG/GRS Report: Flexible Sigmoidoscopy Results"
                'SubTitle = "Covering the selected criteria"
                SingleTable.Title = "Sigmoidoscopy"
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 15
                SingleTable.Columns.Item(3).Width = 20
                SingleTable.Columns.Item(4).Width = 25
                SingleTable.Columns.Item(5).Width = 25
                SingleTable.Columns.Item(6).Width = 25
                SingleTable.Columns.Item(7).Width = 25
                SingleTable.Columns.Item(8).Width = 25
                SingleTable.Columns.Item(9).Width = 25
                SingleTable.Columns.Item(10).Width = 30
                SingleTable.Columns.Item(11).Width = 15
                SingleTable.Columns.Item(12).Width = 15
                SingleTable.Columns.Item(13).Width = 15
                SingleTable.Columns.Item(14).Width = 15
                SingleTable.Columns.Item(15).Width = 20
            Case "RadGridColonoscopy"
                Title = "JAG/GRS Report: Colonoscopy Results"
                'SubTitle = "Covering the selected criteria"
                SingleTable.Title = "Colonoscopy"
                SingleTable.Columns.Item(1).Width = 15
                SingleTable.Columns.Item(2).Width = 15
                SingleTable.Columns.Item(3).Width = 20
                SingleTable.Columns.Item(4).Width = 25
                SingleTable.Columns.Item(5).Width = 25
                SingleTable.Columns.Item(6).Width = 25
                SingleTable.Columns.Item(7).Width = 25
                SingleTable.Columns.Item(8).Width = 25
                SingleTable.Columns.Item(9).Width = 25
                SingleTable.Columns.Item(10).Width = 30
                SingleTable.Columns.Item(11).Width = 15
                SingleTable.Columns.Item(12).Width = 15
                SingleTable.Columns.Item(13).Width = 15
                SingleTable.Columns.Item(14).Width = 15
                SingleTable.Columns.Item(15).Width = 20
            Case "RadGridStandard"
                Title = "GRS C Report - Analysis of Colonoscopy Standard Bowel Preparation"
                'SubTitle = "Covering the selected criteria"
                SingleTable.Title = "Bowel Prep Standard"
                SingleTable.Columns.Item(1).Width = 40
                SingleTable.Columns.Item(2).Width = 15
                SingleTable.Columns.Item(3).Width = 20
                SingleTable.Columns.Item(4).Width = 15
                SingleTable.Columns.Item(5).Width = 20
                SingleTable.Columns.Item(6).Width = 15
                SingleTable.Columns.Item(7).Width = 20
                SingleTable.Columns.Item(8).Width = 20
            Case "RadGridBoston1"
                Cols = 12
                Title = "GRS C Report - Analysis of Colonoscopy Boston Bowel Preparation"
                'SubTitle = "Covering the whole database"
                SingleTable.Title = "Bowel Prep Boston"
            Case Else
        End Select
        'Punto OJO
        If (G.ID = "RadGridGastroscopy") Or (G.ID = "RadGridPEGPEJ") Then
            SingleTable.Cells("A1").Colspan = Cols - 1
            SingleTable.Cells("A1").Value = Title
            SingleTable.Cells("A1").Style = Title1
            SingleTable.Cells("A2").Colspan = Cols - 1
            SingleTable.Cells("A2").Value = SubTitle
            SingleTable.Cells("A2").Style = Title2
        Else
            SingleTable.Cells("A1").Colspan = Cols
            SingleTable.Cells("A1").Value = Title
            SingleTable.Cells("A1").Style = Title1
            SingleTable.Cells("A2").Colspan = Cols
            SingleTable.Cells("A2").Value = SubTitle
            SingleTable.Cells("A2").Style = Title2
        End If
        If G.ID <> "RadGridBoston1" Then
            'Punto OJO
            If (G.ID = "RadGridGastroscopy") Or (G.ID = "RadGridPEGPEJ") Then
                For i = 2 To Cols
                    SingleTable.Cells(i - 1, 3).Style = Head
                    SingleTable.Cells(i - 1, 3).Value = G.Columns(i - 1).HeaderText.ToString
                    SingleTable.Cells(i - 1, 3).Style.HorizontalAlign = HorizontalAlign.Center
                    SingleTable.Cells(i - 1, 3).TextWrap = True
                    SingleTable.Columns(i - 1).Style.HorizontalAlign = HorizontalAlign.Center 'G.Columns(i - 1).ItemStyle.HorizontalAlign
                Next
            Else
                For i = 1 To Cols
                    SingleTable.Cells(i, 3).Style = Head
                    SingleTable.Cells(i, 3).Value = G.Columns(i - 1).HeaderText.ToString
                    SingleTable.Cells(i, 3).Style.HorizontalAlign = HorizontalAlign.Center
                    SingleTable.Cells(i, 3).TextWrap = True
                    SingleTable.Columns(i).Style.HorizontalAlign = HorizontalAlign.Center 'G.Columns(i - 1).ItemStyle.HorizontalAlign
                Next
            End If
        End If
        Row = 4
        Col = 1
        Dim FirstCol As Boolean = True
        If G.ID <> "RadGridBoston1" Then
            For Each Elemento In G.MasterTableView.Items
                'Punto OJO
                If (G.ID = "RadGridGastroscopy") Or (G.ID = "RadGridPEGPEJ") Then
                    FirstCol = True
                    For Each C In G.Columns
                        If FirstCol Then
                            FirstCol = False
                        Else
                            If C.UniqueName <> "Hide" Then
                                SingleTable.Cells(Col, Row).Value = Elemento(C.UniqueName).text
                                SingleTable.Cells(Col, Row).Style = Cell
                                SingleTable.Cells(Col, Row).TextWrap = True
                                Col = Col + 1
                            End If
                        End If
                    Next C
                    MaxCols = G.Columns.Count
                Else
                    For Each C In G.Columns
                        SingleTable.Cells(Col, Row).Value = Elemento(C.UniqueName).text
                        SingleTable.Cells(Col, Row).Style = Cell
                        SingleTable.Cells(Col, Row).TextWrap = True
                        Col = Col + 1
                    Next C
                    MaxCols = G.Columns.Count
                End If
                Col = 1
                Row = Row + 1
            Next
            LastRow = Row + 1
        Else
            Dim Table1 As DataTable = GetDataTable("Select Formulation, NoOfProcs, MeanScore From ERS_ReportBoston3 Where UserID=" + Session("PKUserId").ToString)
            Dim Table2 As DataTable '= GetDataTable("Select Formulation, [Scale], [Right], [RightP],[Transverse], [TransverseP], [Left], [LeftP] From ERS_reportBoston1 Where UserID=" + Session("PKUserID"))
            Dim Table3 As DataTable '= GetDataTable("Select Formulation, Score, Frecuency From ERS_ReportBoston2 Where UserID=" + Session("PKUserID"))
            Dim row1 As DataRow
            Dim row2 As DataRow
            Dim row3 As DataRow
            Dim i As Integer
            Dim j As Integer
            Dim Formulation As String = ""
            Dim inicialRow As Integer = 6
            SingleTable.Cells(1, inicialRow - 3).Colspan = 12
            SingleTable.Cells(1, inicialRow - 3).Value = "Number of procedures where no bowel preparation was set: 0"
            SingleTable.Cells(1, inicialRow - 3).Style = Detail
            i = 0
            SingleTable.Columns(1).Width = 10
            SingleTable.Columns(2).Width = 10
            SingleTable.Columns(3).Width = 10
            SingleTable.Columns(4).Width = 10
            SingleTable.Columns(5).Width = 10
            SingleTable.Columns(6).Width = 10
            SingleTable.Columns(7).Width = 10
            SingleTable.Columns(8).Width = 1
            SingleTable.Columns(9).Width = 10
            SingleTable.Columns(10).Width = 10
            SingleTable.Columns(11).Width = 10
            SingleTable.Columns(12).Width = 10
            For Each row1 In Table1.Rows
                SingleTable.Rows(inicialRow - 1 + i * 12).Height = "25"
                SingleTable.Cells(1, inicialRow - 1 + i * 12).Value = "Scale"
                SingleTable.Cells(2, inicialRow - 1 + i * 12).Value = "Right"
                SingleTable.Cells(3, inicialRow - 1 + i * 12).Value = "%"
                SingleTable.Cells(4, inicialRow - 1 + i * 12).Value = "Transverse"
                SingleTable.Cells(5, inicialRow - 1 + i * 12).Value = "%"
                SingleTable.Cells(6, inicialRow - 1 + i * 12).Value = "Left"
                SingleTable.Cells(7, inicialRow - 1 + i * 12).Value = "%"
                SingleTable.Cells(9, inicialRow - 1 + i * 12).Value = "Score"
                SingleTable.Cells(10, inicialRow - 1 + i * 12).Value = "Frecuency"
                SingleTable.Cells(11, inicialRow - 1 + i * 12).Value = "No Of Procs"
                SingleTable.Cells(12, inicialRow - 1 + i * 12).Value = "Mean score"
                SingleTable.Cells(1, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(2, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(3, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(4, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(5, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(6, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(7, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(9, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(10, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(11, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(12, inicialRow - 1 + i * 12).Style = Head
                SingleTable.Cells(11, 5 + i * 12 + 1).Value = row1("NoOfProcs")
                SingleTable.Cells(12, 5 + i * 12 + 1).Value = row1("MeanScore")
                SingleTable.Cells(11, 5 + i * 12 + 1).Style = Cell
                SingleTable.Cells(12, 5 + i * 12 + 1).Style = Cell
                Formulation = row1("Formulation")
                SingleTable.Cells(1, inicialRow - 2 + i * 12).Colspan = 7
                SingleTable.Cells(1, inicialRow - 2 + i * 12).Value = Formulation
                SingleTable.Cells(1, inicialRow - 2 + i * 12).Style = Detail
                Table2 = GetDataTable("Select Formulation, [Scale], [Right], [RightP],[Transverse], [TransverseP], [Left], [LeftP] From ERS_reportBoston1 Where UserID=" + Session("PKUserId").ToString + " And Formulation='" + Formulation + "'")
                j = 1
                For Each row2 In Table2.Rows
                    SingleTable.Cells(1, 5 + i * 12 + j).Value = row2("Scale")
                    SingleTable.Cells(2, 5 + i * 12 + j).Value = row2("Right")
                    SingleTable.Cells(3, 5 + i * 12 + j).Value = row2("RightP")
                    SingleTable.Cells(4, 5 + i * 12 + j).Value = row2("Transverse")
                    SingleTable.Cells(5, 5 + i * 12 + j).Value = row2("TransverseP")
                    SingleTable.Cells(6, 5 + i * 12 + j).Value = row2("Left")
                    SingleTable.Cells(7, 5 + i * 12 + j).Value = row2("LeftP")
                    SingleTable.Cells(1, 5 + i * 12 + j).Style = Cell
                    SingleTable.Cells(2, 5 + i * 12 + j).Style = Cell
                    SingleTable.Cells(3, 5 + i * 12 + j).Style = Cell
                    SingleTable.Cells(4, 5 + i * 12 + j).Style = Cell
                    SingleTable.Cells(5, 5 + i * 12 + j).Style = Cell
                    SingleTable.Cells(6, 5 + i * 12 + j).Style = Cell
                    SingleTable.Cells(7, 5 + i * 12 + j).Style = Cell
                    j = j + 1
                Next
                Table3 = GetDataTable("Select Formulation, Score, Frecuency From ERS_ReportBoston2 Where UserID=" + Session("PKUserId").ToString + " And Formulation='" + Formulation + "'")
                j = 1
                For Each row3 In Table3.Rows
                    SingleTable.Cells(9, 5 + i * 12 + j).Value = row3("Score")
                    SingleTable.Cells(10, 5 + i * 12 + j).Value = row3("Frecuency")
                    SingleTable.Cells(9, 5 + i * 12 + j).Style = Cell
                    SingleTable.Cells(10, 5 + i * 12 + j).Style = Cell
                    j = j + 1
                    LastRow = 5 + i * 12 + j + 1
                Next
                LastBowelRow = LastRow
                i = i + 1
            Next
        End If
        Select Case SingleTable.Title
            Case "Endoscopists"
                LastRow = LastEndoscopistRow + 4
                MaxCols = 6
            Case "Bowel Prep Boston"
                LastRow = LastBowelRow
                MaxCols = 12
            Case Else
                SingleTable.Cells(1, LastRow).Colspan = MaxCols
        End Select
        SingleTable.Cells(1, LastRow).Value = Signature
        SingleTable.Cells(1, LastRow).Style = Foot
        SingleTable.Cells(1, LastRow).TextWrap = False
        SingleTable.Cells(1, LastRow).Style.HorizontalAlign = HorizontalAlign.Left
        SingleTable.Cells(1, LastRow).Colspan = MaxCols
        Estructura.Tables.Add(SingleTable)
    End Sub
#End Region
#Region "BowelBoston"
    '"Select Formulation, [Scale], [Right], [RightP],[Transverse], [TransverseP], [Left], [LeftP] From ERS_reportBoston1 Where UserID=" + Session("PKUserID")
    '"Select Score, Frecuency From ERS_ReportBoston2 Where Formulation = '" + Formulation + "' And UserID=" + Session("PKUserID")
    '"Select Frecuency, NoOfProcs, MeanScore From ERS_ReportBoston3 Where Formulation = '" + Formulation + "' And UserID=" + Session("PKUserID")
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
    Protected Sub RadGridBoston1_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs) Handles RadGridBoston1.NeedDataSource
        If Not e.IsFromDetailTable Then
            RadGridBoston1.DataSource = GetDataTable("Select Formulation, NoOfProcs, MeanScore From ERS_ReportBoston3 Where UserID=" + Session("PKUserId").ToString)
        End If
    End Sub

    Protected Sub RadGridBoston1_DetailTableDataBind(sender As Object, e As GridDetailTableDataBindEventArgs) Handles RadGridBoston1.DetailTableDataBind
        Dim dataItem As GridDataItem = DirectCast(e.DetailTableView.ParentItem, GridDataItem)
        Select Case e.DetailTableView.Name
            Case "Boston1"
                If True Then 'If True? Literal transcription from Telerik page
                    Dim Formulation1 As String = dataItem.GetDataKeyValue("Formulation").ToString()
                    e.DetailTableView.DataSource = GetDataTable((Convert.ToString("Select Formulation, [Scale], [Right], [RightP],[Transverse], [TransverseP], [Left], [LeftP] From ERS_reportBoston1 Where UserID=" + Session("PKUserId").ToString + " And Formulation = '") & Formulation1) + "'")
                    Exit Select
                End If
            Case "Boston3"
                If True Then 'If True? Literal transcription from Telerik page
                    Dim Formulation1 As String = dataItem.GetDataKeyValue("Formulation").ToString()
                    e.DetailTableView.DataSource = GetDataTable((Convert.ToString("Select Formulation, Score, Frecuency From ERS_ReportBoston2 Where UserID=" + Session("PKUserId").ToString + " And Formulation = '") & Formulation1) + "'")
                    Exit Select
                End If
        End Select
    End Sub

    Protected Sub RadGridBoston1_PreRender(sender As Object, e As EventArgs) Handles RadGridBoston1.PreRender
        If Not Page.IsPostBack Then
            Try
                RadGridBoston1.MasterTableView.Items(0).Expanded = True
                RadGridBoston1.MasterTableView.Items(0).ChildItem.NestedTableViews(0).Items(0).Expanded = False
            Catch ex As Exception
                'Tables with no data
            End Try
        End If
    End Sub
#End Region

#Region "Buttons"
    Protected Sub RadButton1_Click(sender As Object, e As EventArgs) Handles RadButtonFilter.Click
        If CDate(Me.RDPFrom.SelectedDate.ToString) <= CDate(Me.RDPTo.SelectedDate.ToString) Then
            SetUserIDFilter(Session("PKUserId").ToString)
            LoadDefaultsFromDB()
            Dim sqlStr As String = "Exec [dbo].[report_BowelBoston] @UserID=" + Session("PKUserId").ToString
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sqlStr, connection)
                cmd.CommandType = CommandType.Text
                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
            RadGridEndoscopists.DataSourceID = "DSEndoscopists"
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
            If cbReports.Items(5).Selected = True Then
                If RadioBowel.Items(0).Selected Then
                    RadGridStandard.DataSourceID = "DSStandard"
                    DSStandard.DataBind()
                End If
                If RadioBowel.Items(1).Selected Then
                    DSBoston1.DataBind()
                    DSBoston2.DataBind()
                    DSBoston3.DataBind()
                End If
            End If
            RadTabStrip1.Tabs(1).Enabled = True
            RadButtonExportGrids.Enabled = True
            RadTabStrip1.Tabs(0).Selected = False
            RadTabStrip1.Tabs(1).Selected = True
            RadMultiPage1.SelectedIndex = 1
            RadButtonExportGrids.Visible = True
        Else
            Return
        End If
    End Sub
#End Region

    'Protected Sub RadGridGastroscopy_PageSizeChanged(sender As Object, e As Global.Telerik.Web.UI.GridPageSizeChangedEventArgs) Handles RadGridGastroscopy.PageSizeChanged
    '    If RadGridEndoscopists.PageSize <> e.NewPageSize Then
    '        RadGridEndoscopists.PageSize = e.NewPageSize
    '        RadGridEndoscopists.Rebind()
    '    End If
    'End Sub

End Class