Imports System.Data.SqlClient
Imports ERS.Data

Public Class Reporting
#Region "Common"

#Region "Public Property"
    Private Shared _ErrorMsg As String = ""
    Public Shared Property ErrorMsg As String
        Get
            Return _ErrorMsg
        End Get
        Set(value As String)
            _ErrorMsg = value
        End Set
    End Property

    Private Shared _PageTitle As String = ""
    Public Shared Property PageTitle As String
        Get
            Return _PageTitle
        End Get
        Set(value As String)
            _PageTitle = value
        End Set
    End Property

    Private Shared _FromDate As String = "01/01/2018"
    Public Shared Property FromDate
        Get
            Return _FromDate
        End Get
        Set(value)
            _FromDate = value
        End Set
    End Property

    Private Shared _ToDate As String = "31/12/2099"
    Public Shared Property ToDate
        Get
            Return _ToDate
        End Get
        Set(value)
            _ToDate = value
        End Set
    End Property

    Private Shared _TypeOfConsultant As Integer = 0
    Public Shared Property TypeOfConsultant As Integer
        Get
            Return _TypeOfConsultant
        End Get
        Set(value As Integer)
            _TypeOfConsultant = value
        End Set
    End Property

    Private Shared _HideSuppressed As Boolean = False
    Public Shared Property HideSuppressed As Boolean
        Get
            Return _HideSuppressed
        End Get
        Set(value As Boolean)
            _HideSuppressed = value
        End Set
    End Property

    Private Shared _Gastroscopy As Boolean = True
    Public Shared Property Gastroscopy As Boolean
        Get
            Return _Gastroscopy
        End Get
        Set(value As Boolean)
            _Gastroscopy = value
        End Set
    End Property

    Private Shared _PEGPEJ As Boolean = True
    Public Shared Property PEGPEJ As Boolean
        Get
            Return _PEGPEJ
        End Get
        Set(value As Boolean)
            _PEGPEJ = value
        End Set
    End Property
    Private Shared _ERCP As Boolean = True
    Public Shared Property ERCP As Boolean
        Get
            Return _ERCP
        End Get
        Set(value As Boolean)
            _ERCP = value
        End Set
    End Property

    Private Shared _Colonoscopy As Boolean = True
    Public Shared Property Colonoscopy As Boolean
        Get
            Return _Colonoscopy
        End Get
        Set(value As Boolean)
            _Colonoscopy = value
        End Set
    End Property

    Private Shared _Sigmoidoscopy As Boolean = True
    Public Shared Property Sigmoidoscopy As Boolean
        Get
            Return _Sigmoidoscopy
        End Get
        Set(value As Boolean)
            _Sigmoidoscopy = value
        End Set
    End Property

    Private Shared _Bowel As Boolean = True
    Public Shared Property Bowel As Boolean
        Get
            Return _Bowel
        End Get
        Set(value As Boolean)
            _Bowel = value
        End Set
    End Property

    Private Shared _Standard As Boolean = True
    Public Shared Property Standard As Boolean
        Get
            Return _Standard
        End Get
        Set(value As Boolean)
            _Standard = value
        End Set
    End Property

    Private Shared _Boston As Boolean = False
    Public Shared Property Boston As Boolean
        Get
            Return _Boston
        End Get
        Set(value As Boolean)
            _Boston = value
        End Set
    End Property

    Private Shared _Anonymise As Boolean = False
    Public Shared Property Anonymise As Boolean
        Get
            Return _Anonymise
        End Get
        Set(value As Boolean)
            _Anonymise = value
        End Set
    End Property

    Private Shared _pFormulation As String = ""
    Public Shared Property pFormulation
        Get
            Return _pFormulation
        End Get
        Set(value)
            _pFormulation = value
        End Set
    End Property

    Private Shared _SSRSURL As String = ConfigurationManager.AppSettings("Unisoft.Reportserver")
    Public Shared Property SSRSURL
        Get
            Return _SSRSURL
        End Get
        Set(value)
            _SSRSURL = value
        End Set
    End Property

    Private Shared _ReportURL As String = "ReportViewer.aspx?%2fERS_Reports%2f"
    Public Shared Property ReportURL
        Get
            Return _ReportURL
        End Get
        Set(value)
            _ReportURL = value
        End Set
    End Property

    Private Shared _ReportName As String = ""
    Public Shared Property ReportName As String
        Get
            Return _ReportName
        End Get
        Set(value As String)
            _ReportName = value
        End Set
    End Property

    Private Shared _Parameters As String = ""
    Public Shared Property Parameters As String
        Get
            Return _Parameters
        End Get
        Set(value As String)
            _Parameters = value
        End Set
    End Property

    Private Shared _UserID As Integer = 0
    Public Shared Property UserID
        Get
            Return _UserID
        End Get
        Set(value)
            _UserID = value
        End Set
    End Property

    Private Shared _ReportCalled As String = ""
    Public Shared Property ReportCalled As String
        Get
            Return _ReportCalled
        End Get
        Set(value As String)
            _ReportCalled = value
        End Set
    End Property

    Private Shared _URL As String = ""
    Public Shared Property URL As String
        Get
            Return _URL
        End Get
        Set(value As String)
            _URL = value
        End Set
    End Property

    Private Shared _ListBox1SQL As String = "SELECT ReportID, Consultant, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 
                                                FROM v_rep_Consultants 
                                                WHERE (IsEndoscopist1 = 1 OR IsEndoscopist2 = 1) order by Surname"
    Public Shared Property ListBox1SQL As String
        Get
            Return _ListBox1SQL
        End Get
        Set(value As String)
            _ListBox1SQL = value
        End Set
    End Property

    Private Shared _ListBox2SQL As String = "SELECT ReportID, Consultant, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_Consultants WHERE (Consultant <> '(None)')"
    Public Shared Property ListBox2SQL As String
        Get
            Return _ListBox2SQL
        End Get
        Set(value As String)
            _ListBox2SQL = value
        End Set
    End Property

    Private Shared _TypeOfEndoscopist = "3"
    Public Shared Property TypeOfEndoscopist As String
        Get
            Return _TypeOfEndoscopist
        End Get
        Set(value As String)
            _TypeOfEndoscopist = value
        End Set
    End Property
#End Region

    ' Begin oJo Delete the following lines later
    Private Shared ConsultantsListBox1 As String = "SELECT ReportID, LTRIM(Consultant) AS Consultant, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_Consultants WHERE (Consultant <> '(None)')"
    Private Shared ConsultantsListBox2 As String = "SELECT ReportID, LTRIM(Consultant) AS Consultant, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_Consultants WHERE ReportID In (Select ConsultantID From ERS_ReportConsultants Where UserID=@UserID) And (Consultant <> '(None)')"
    ' End oJo

    Private Shared _ListOfPatients As Boolean = False
    Public Shared Property ListOfPatients As Boolean
        Get
            Return _ListOfPatients
        End Get
        Set(value As Boolean)
            _ListOfPatients = value
        End Set
    End Property



    Public Function GetListBox1(ByVal UserId As String, Optional ByVal SrchStr As String = "") As DataTable
        If IsNothing(UserId) Then Return Nothing
        Dim sql As String = ListBox1SQL
        'Add Filtering criteria according to the type of consultant
        'If Not HideSuppressed Then
        '    sql += " And Active=0"
        'End If

        Select Case TypeOfConsultant
            Case "1"
                sql += " And IsEndoscopist1=1"
            Case "2"
                sql += " And IsEndoscopist2=1"
            Case "3"
                sql += " And IsListConsultant=1"
            Case "4"
                sql += " And IsAssistantOrTrainee=1"
            Case "5"
                sql += " And IsNurse1=1"
            Case "6"
                sql += " And IsNurse2=1"
        End Select

        If SrchStr <> String.Empty Then
            sql += " And Consultant LIKE " + "'%" + SrchStr + "%'"
        End If

        sql += " ORDER BY [Consultant]"

        Return DataAccess.ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@UserId", UserId)})

    End Function
    Public Shared Function GetListBox2(ByVal UserId As String, Optional ByVal SrchStr As String = "") As DataTable
        If IsNothing(UserId) Then Return Nothing

        Dim sql As String = ListBox2SQL
        'Add Filtering criteria according to the type of consultant
        If Not HideSuppressed Then
            sql += " And Active=0"
        End If

        Select Case TypeOfConsultant
            Case "1"
                sql += " And IsEndoscopist1=1"
            Case "2"
                sql += " And IsEndoscopist2=1"
            Case "3"
                sql += " And IsListConsultant=1"
            Case "4"
                sql += " And IsAssistantOrTrainee=1"
            Case "5"
                sql += " And IsNurse1=1"
            Case "6"
                sql += " And IsNurse2=1"
        End Select

        If SrchStr <> String.Empty Then
            sql += " And Consultant LIKE " + "'%" + SrchStr + "%'"
        End If

        Return DataAccess.ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@UserId", UserId)})

    End Function

    Public Shared Function InsertIFrame() As String
        URL = Reporting.SSRSURL + Reporting.ReportURL + Reporting.ReportName + "&rs:Command=Render&UserID=" + Reporting.UserID.ToString + Reporting.Parameters
        Dim iFrameStr As String = "<iframe class=""if"" src=""" + URL + """></iframe>"
        ReportCalled = URL
        Return iFrameStr
    End Function

    <Obsolete("This method is deprecated, use [ExecuteScalerSQL(ByVal ScalerExecuteSQL As String)] instead.")>
    Public Shared Sub Transaction(ByVal SqlStr As String)
        ErrorMsg = ""
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd1 As New SqlCommand(SqlStr, connection)
                cmd1.CommandType = CommandType.Text
                cmd1.Connection.Open()
                cmd1.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            ErrorMsg = ex.Message + "[" + SqlStr + "]"
        End Try
    End Sub

    Public Shared Function ReportIFrame(ByVal Report As String) As String
        URL = Reporting.SSRSURL + Reporting.ReportURL + Reporting.ReportName + "&rs:Command=Render&UserID=" + Reporting.UserID.ToString + Reporting.Parameters
        Dim iFrameStr As String = "<iframe class=""if"" src=""" + URL + """></iframe>"
        ReportCalled = URL
        Return iFrameStr
    End Function

    Public Shared Sub CreateUserIDFilter()
        If (UserID.ToString <> "0") Or (UserID.ToString = "") Then
            Dim sql1 As String = "Delete [dbo].[ERS_ReportFilter] Where UserID=" + UserID.ToString
            Transaction(sql1)
            Dim sql2 As String = "Insert Into [dbo].[ERS_ReportFilter] (UserID) Select UserID=" + UserID.ToString
            Transaction(sql2)
        End If
    End Sub

    Public Shared Sub DefaultDates()
        Dim DT As New DataTable
        'Dim R As DataRow
        Dim SqlStr = "Select Min(CreatedOn) As MinDate, Max(CreatedOn) As MaxDate From fw_Procedures PR"
        DT = DataAccess.ExecuteSQL(SqlStr)
        FromDate = DT.Rows(0).Item("MinDate").ToString
        ToDate = DT.Rows(0).Item("MaxDate").ToString
    End Sub

    Public Shared Sub Save(ByVal UserId As String)

        If IsNothing(UserId) Then
            Return
        End If

        DataAccess.ExecuteScalerSQL("UserReportFilter_Insert_Update", CommandType.StoredProcedure, New SqlParameter() {
                                               New SqlParameter("@UserId", UserId),
                                               New SqlParameter("@FromDate", Date.ParseExact(FromDate, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo)), 'CDate(FromDate)),
                                               New SqlParameter("@ToDate", Date.ParseExact(ToDate, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo)), 'CDate(ToDate)),
                                               New SqlParameter("@EndoType", TypeOfConsultant),
                                               New SqlParameter("@HideSuppressed", HideSuppressed)})

    End Sub
    Public Shared Sub GetFilter(ByVal UserId As String)
        Dim DT As New DataTable
        Dim R As DataRow
        If IsNothing(UserId) Then
            Return
        End If

        Dim SqlStr = "Select * From ERS_ReportFilter Where UserId=" + UserId
        DT = DataAccess.ExecuteSQL(SqlStr)
        If DT IsNot Nothing Then
            Dim HS As String = ""
            For Each R In DT.Rows
                HS = R("HideSuppressed").ToString
                If HS = "0" Then HideSuppressed = False Else HideSuppressed = True
                FromDate = R("FromDate").ToString
                ToDate = R("ToDate").ToString
                TypeOfEndoscopist = R("TypesOfEndoscopists").ToString
                TypeOfConsultant = CInt(TypeOfEndoscopist)
            Next
        End If
    End Sub

    Public Shared Function GetReportFilterDefaults(ByVal userid As String)
        Using da As New DataAccess
            Return da.ExecuteSP("usp_rep_GetReportFilterDefaults",
                                            New SqlParameter() {New SqlParameter("@UserId", userid)})
        End Using
    End Function

    Public Shared Sub SaveReportFilterDefaults(ByVal userid As String,
                                               fromDate As Date,
                                               toDate As Date,
                                               dateOrder As String,
                                               patientStatus As String,
                                               nhsStatus As String,
                                               anonimize As Boolean,
                                               therapeutic As Boolean,
                                               indications As Boolean,
                                               theraDiag As Boolean,
                                               endoscopistConsultant As Integer,
                                               operatingHospitalList As String)
        Using da As New DataAccess
            da.ExecuteSP("usp_rep_SaveListReportDefaults",
                                New SqlParameter() {
                                    New SqlParameter("@userId", userid),
                                    New SqlParameter("@fromDate", fromDate),
                                    New SqlParameter("@toDate", toDate),
                                    New SqlParameter("@dateOrder", dateOrder),
                                    New SqlParameter("@patientStatus", patientStatus),
                                    New SqlParameter("@NHSStatus", nhsStatus),
                                    New SqlParameter("@anonimize", anonimize),
                                    New SqlParameter("@therapeutic", therapeutic),
                                    New SqlParameter("@indications", indications),
                                    New SqlParameter("@theraDiag", theraDiag),
                                    New SqlParameter("@endoConsultant", endoscopistConsultant),
                                    New SqlParameter("@operatingHospitalList", operatingHospitalList)}
                                )
        End Using
    End Sub

    Public Shared Sub SaveReportConsultants(ByVal userid As String, ByVal consultantList As String)
        Using da As New DataAccess
            da.ExecuteSP("usp_rep_SaveConsultantDefaults",
                                New SqlParameter() {
                                    New SqlParameter("@userId", userid),
                                    New SqlParameter("@consultantIdList", consultantList)}
                                )
        End Using
    End Sub


    Public Shared Function GetNEDSummary(ByVal operatingHospitalIds As String, ByVal endoscopistIds As String, successStatus As Boolean?, dateFrom As DateTime, dateTo As DateTime) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("usp_rep_GetNEDSummary",
                                            New SqlParameter() {New SqlParameter("@OperatingHospitalIds", operatingHospitalIds),
                                                                New SqlParameter("@EndoscopistIds", endoscopistIds),
                                                                New SqlParameter("@DateFrom", dateFrom),
                                                                New SqlParameter("@DateTo", dateTo),
                                                                New SqlParameter("@Status", If(successStatus, DBNull.Value))})
        End Using
    End Function

    Public Shared Function GetListPatientReport(ByVal userid As String) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("usp_rep_GetListPatientReport",
                                            New SqlParameter() {New SqlParameter("@UserId", userid)})
        End Using
    End Function
    Public Shared Function GetListSummaryReport(ByVal userid As String) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("usp_rep_GetListSummaryReport",
                                            New SqlParameter() {New SqlParameter("@UserId", userid)})
        End Using
    End Function

    Public Shared Sub SetConsultantType(ByVal Type As String, ByVal Suppressed As Boolean)
        Dim StrSql As String = ""
        'Select Case Type
        '    Case "AllConsultants"
        '        StrSql = " And ((IsEndoscopist1='1') Or (IsEndoscopist2='1') Or (IsListConsultant='1') Or (IsAssistantOrTrainee='1') Or (IsNurse1='1') Or (IsNurse2='1'))"
        '    Case "Endoscopist1"
        '        StrSql = " And IsEndoscopist1='1'"
        '    Case "Endoscopist2"
        '        StrSql = " And IsEndoscopist2='1'"
        '    Case "ListConsultant"
        '        StrSql = " And IsListConsultant='1'"
        '    Case "Assistant"
        '        StrSql = " And IsAssistantOrTrainee='1'"
        '    Case "Nurse1"
        '        StrSql = " And IsNurse1='1'"'    Case "Nurse2"
        '        StrSql = " And IsNurse2='1'"
        'End Select
        StrSql = " And (IsEndoscopist1='1' Or IsEndoscopist2='1')"
        If Suppressed Then
            StrSql = StrSql + " And Active='1'"
        End If

        StrSql = StrSql + " AND Consultant LIKE '%' + ISNULL(@searchPhrase, '') + '%'"
        StrSql = StrSql + " Order by Surname "
        Reporting.ListBox1SQL = Reporting.ConsultantsListBox1 + StrSql
        Reporting.ListBox2SQL = Reporting.ConsultantsListBox2
    End Sub

    Public Shared Sub SetEndoType(ByVal ListConsultantSuppressed As Boolean, EndoscopistSuppressed As Boolean)
        Dim StrSql As String = ""
        'Select Case Type
        '    Case "AllConsultants"
        '        StrSql = " And ((IsEndoscopist1='1') Or (IsEndoscopist2='1') Or (IsListConsultant='1') Or (IsAssistantOrTrainee='1') Or (IsNurse1='1') Or (IsNurse2='1'))"
        '    Case "Endoscopist1"
        '        StrSql = " And IsEndoscopist1='1'"
        '    Case "Endoscopist2"
        '        StrSql = " And IsEndoscopist2='1'"
        '    Case "ListConsultant"
        '        StrSql = " And IsListConsultant='1'"
        '    Case "Assistant"
        '        StrSql = " And IsAssistantOrTrainee='1'"
        '    Case "Nurse1"
        '        StrSql = " And IsNurse1='1'"'    Case "Nurse2"
        '        StrSql = " And IsNurse2='1'"
        'End Select
        StrSql = " And (IsEndoscopist1='1' Or IsEndoscopist2='1')"
        If ListConsultantSuppressed Then
            'StrSql = StrSql + " And Active='1'"
        End If

        If EndoscopistSuppressed Then

        End If

        StrSql = StrSql + " AND Consultant LIKE '%' + ISNULL(@searchPhrase, '') + '%'"
        StrSql = StrSql + " Order by Surname "
        Reporting.ListBox1SQL = Reporting.ConsultantsListBox1 + StrSql
        Reporting.ListBox2SQL = Reporting.ConsultantsListBox2
    End Sub

    Public Shared Function CleanListBoxes(ByVal UserId As String)

        Dim SqlStr = "Delete ERS_ReportConsultants Where UserID=" + UserId
        Transaction(SqlStr)
        Return ErrorMsg

    End Function

    Public Shared Function GetConsultantsListBox1(ByVal UserID As String, searchPhrase As String, operatingHospitalsIds As String, HideSuppressed As Boolean, Optional ByVal consultantTypeName As String = "All") As DataTable
        Try
            'check if the current user running this has permissions to see all reports from all users, or if they are an admin else limit their
            'consultants to just them.
            Dim checkUserStatus As String = DataAccess.CheckUserAuditReportViewSetting(UserID)
            Dim consultantDataTable As DataTable

            If checkUserStatus = "All" Then
                If consultantTypeName = "All" Then
                    consultantDataTable = BusinessLogic.GetConsultants("all", operatingHospitalsIds, HideSuppressed, searchPhrase)
                Else
                    consultantDataTable = BusinessLogic.GetConsultants(consultantTypeName, operatingHospitalsIds, HideSuppressed, searchPhrase)
                End If
            ElseIf checkUserStatus = "User only" Then
                If consultantTypeName = "All" Then
                    consultantDataTable = BusinessLogic.GetConsultantOnly(UserID, "all", operatingHospitalsIds, HideSuppressed, searchPhrase)
                Else
                    consultantDataTable = BusinessLogic.GetConsultantOnly(UserID, consultantTypeName, operatingHospitalsIds, HideSuppressed, searchPhrase)
                End If
            Else
                Return Nothing
            End If

            Return consultantDataTable

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error Executing sqlStatement=[" & Reporting.ListBox1SQL & "], at: DataAccess.vb=>ExecuteSQL()", ex)
            Return Nothing
        End Try

    End Function

    Public Shared Function GetConsultantsListBox2(ByVal UserID As String) As DataTable
        Return DataAccess.ExecuteSQL(Reporting.ListBox2SQL, New SqlParameter() {New SqlParameter("@UserId", UserID)})
    End Function

    <Obsolete("This method is deprecated, use [GetConsultantByType()] instead.")>
    Public Shared Function GetConsultantByTypeDT(Optional ByVal consultantType As String = "all", Optional ByVal hideInactiveMembers As Boolean = False) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("usp_rep_ConsultantSelectByType",
                                            New SqlParameter() {
                                                New SqlParameter("@ConsultantType", consultantType),
                                                New SqlParameter("@HideInactiveConsultants", hideInactiveMembers)})  '## Revised  by Shawkat;
        End Using
    End Function

    'Public Shared Function GetConsultantByType(Optional ByVal consultantType As String = "all", Optional ByVal hideInactiveMembers As Boolean = False) As List(Of GetAllConsultant_Result)
    '    'Throw New ArgumentException("Exception Occurred: GetConsultantByType() is totally Obsolete... Use BusinessLogic.GetAllConsultant()")
    '    Return BusinessLogic.GetAllConsultant("all")
    'End Function

    Public Shared Sub LoadDefaultsFromDB(ByVal UID As String)
        Dim DT1 As New DataTable
        Dim DT2 As New DataTable
        Dim Row As DataRow
        Dim sqlQuery1 As String = ""
        Dim sqlQuery2 As String = ""
        Dim Sql As String = ""

        sqlQuery1 = "Select * From [dbo].[ERS_ReportFilter] Where UserID='" + UID + "'"
        DT1 = DataAccess.ExecuteSQL(sqlQuery1)

        If DT1.Rows.Count = 0 Then
            CreateUserIDFilter()
            DT1 = DataAccess.ExecuteSQL(sqlQuery1)
        End If

        For Each Row In DT1.Rows
            Try
                TypeOfConsultant = Row("TypesOfEndoscopists").ToString
                FromDate = Row("FromDate").ToString
                ToDate = Row("ToDate").ToString
                HideSuppressed = CBool(Row("HideSuppressed").ToString)
                Gastroscopy = CBool(Row("OGD").ToString)
                Sigmoidoscopy = CBool(Row("Sigmoidoscopy").ToString)
                ERCP = CBool(Row("ERCP").ToString)
                Colonoscopy = CBool(Row("Colonoscopy").ToString)
                Bowel = CBool(Row("Bowel").ToString)
                PEGPEJ = CBool(Row("PEGPEJ").ToString)
                Standard = CBool(Row("BowelStandard").ToString)
                Boston = CBool(Row("BowelBoston").ToString)
                Anonymise = CBool(Row("Anonymise").ToString)
            Catch ex As Exception
                FromDate = "01/01/1980"
                ToDate = "31/12/2099"
                ErrorMsg = ex.Message
            End Try
        Next Row
        sqlQuery2 = "Select * From [dbo].[ERS_ReportConsultants] Where UserID='" + UID + "'"
        DT2 = DataAccess.ExecuteSQL(sqlQuery2)
        If DT2.Rows.Count = 0 Then
            CreateUserIDFilter()
        End If
        DT1.Dispose()
        DT2.Dispose()
    End Sub

    ''' <summary>
    ''' This will Update the [dbo].[ERS_ReportFilter] Table. For William. He is using this table in various reports!
    ''' Just saving his arse!
    ''' </summary>
    ''' <returns>True/False Based on Success result!</returns>
    ''' <remarks></remarks>
    Public Shared Function UpdateReportFilterParamTable() As Boolean
        Try
            Dim executeResult As Boolean = DataAccess.ExecuteScalerSQL("usp_rep_UpdateReportParamFilterRow", CommandType.StoredProcedure,
                                                                                    New SqlParameter() {
                                                                                                  New SqlParameter("@CurrentUserID", _UserID),
                                                                                                  New SqlParameter("@FromDate", _FromDate),
                                                                                                  New SqlParameter("@ToDate", _ToDate),
                                                                                                  New SqlParameter("@TypesOfEndoscopists", _TypeOfEndoscopist),
                                                                                                  New SqlParameter("@HideSuppressed", _HideSuppressed),
                                                                                                  New SqlParameter("@OGD", _Gastroscopy),
                                                                                                  New SqlParameter("@Sigmoidoscopy", _Sigmoidoscopy),
                                                                                                  New SqlParameter("@PEGPEJ", _PEGPEJ),
                                                                                                  New SqlParameter("@Colonoscopy", _Colonoscopy),
                                                                                                  New SqlParameter("@ERCP", _ERCP),
                                                                                                  New SqlParameter("@Bowel", _Bowel),
                                                                                                  New SqlParameter("@BowelStandard", _Standard),
                                                                                                  New SqlParameter("@BowelBoston", _Boston),
                                                                                                  New SqlParameter("@Anonymise", _Anonymise)
                                                                                    })
            Return True
        Catch ex As Exception

            Return False
        End Try

    End Function

    ''' <summary>
    ''' This will Execute the StoredProc to Get the GRS02 Report Data.. Keep things in this Data Layer.. away from Business Logic Layer!
    ''' </summary>
    ''' <returns>DataTable!</returns>
    ''' <remarks></remarks>
    Public Shared Function GetGRS02_ReportData(ByVal GRS02_StoredProcName As String, ByVal Endoscopist1 As Integer, ByVal Endoscopist2 As Integer, ByVal OGD As Integer, ByVal COLSIG As Integer) As DataTable
        Dim executeResult As New DataTable
        Try
            Using da As New DataAccess
                executeResult = da.ExecuteSP(GRS02_StoredProcName,
                                                                                New SqlParameter() {
                                                                                                New SqlParameter("@Endoscopist1", Endoscopist1),
                                                                                                New SqlParameter("@Endoscopist2", Endoscopist2),
                                                                                                New SqlParameter("@OGD", OGD),
                                                                                                New SqlParameter("@COLSIG", COLSIG)
                                                                                })
                Return executeResult
            End Using
        Catch ex As Exception

            Return executeResult
        End Try

    End Function

    Public Shared Function GetRoomsListBox1(ByVal hospitalId As Integer, ByVal roomId As Integer) As DataTable

        Dim dsData As New DataSet
        Dim spGetRoomsStoredProc As String = "SCH_reports_rooms_all"

        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(spGetRoomsStoredProc, connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@operatingHospitalId", hospitalId))
                cmd.Parameters.Add(New SqlParameter("@roomId", roomId))

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
            LogManager.LogManagerInstance.LogError("Error Executing Stored Procedure=[" & spGetRoomsStoredProc & "], at: Reporting.vb=>ExecuteSQL()", ex)
            Return Nothing
        End Try

    End Function

    Public Function GetRoomsListBox2(searchPhrase As String, operatingHospitalIds As String) As DataTable

        Dim dsData As New DataSet
        Dim spGetRoomsStoredProc As String = "SCH_reports_rooms_search"

        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(spGetRoomsStoredProc, connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@hospitalIds", operatingHospitalIds))
                'cmd.Parameters.Add(New SqlParameter("@roomId", roomId))

                If Not String.IsNullOrEmpty(searchPhrase) Then
                    cmd.Parameters.Add(New SqlParameter("@searchPhrase", searchPhrase))
                Else
                    cmd.Parameters.Add(New SqlParameter("@searchPhrase", SqlTypes.SqlString.Null))
                End If

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
            LogManager.LogManagerInstance.LogError("Error Executing Stored Procedure=[" & spGetRoomsStoredProc & "], at: Reporting.vb=>ExecuteSQL()", ex)
            Return Nothing
        End Try

    End Function

    Public Shared Sub SetRoom(ByVal RoomId As String)
        Dim StrSql As String = ""
        'Select Case Type
        '    Case "AllConsultants"
        '        StrSql = " And ((IsEndoscopist1='1') Or (IsEndoscopist2='1') Or (IsListConsultant='1') Or (IsAssistantOrTrainee='1') Or (IsNurse1='1') Or (IsNurse2='1'))"
        '    Case "Endoscopist1"
        '        StrSql = " And IsEndoscopist1='1'"
        '    Case "Endoscopist2"
        '        StrSql = " And IsEndoscopist2='1'"
        '    Case "ListConsultant"
        '        StrSql = " And IsListConsultant='1'"
        '    Case "Assistant"
        '        StrSql = " And IsAssistantOrTrainee='1'"
        '    Case "Nurse1"
        '        StrSql = " And IsNurse1='1'"'    Case "Nurse2"
        '        StrSql = " And IsNurse2='1'"
        'End Select
        'StrSql = " And (IsEndoscopist1='1' Or IsEndoscopist2='1')"
        'If Suppressed Then
        '    StrSql = StrSql + " And Active='1'"
        'End If

        StrSql = StrSql + " AND RoomName LIKE '%' + ISNULL(@searchPhrase, '') + '%'"
        StrSql = StrSql + " Order by RoomName "
        'Reporting.ListBox1SQL = Reporting.ConsultantsListBox1 + StrSql
        'Reporting.ListBox2SQL = Reporting.ConsultantsListBox2
    End Sub

#End Region
End Class
