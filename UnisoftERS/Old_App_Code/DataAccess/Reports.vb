Imports System
Imports System.Data.SqlClient


Public Class Reports
    Public Shared ShowOldProcedures As Boolean = CBool(ConfigurationManager.AppSettings("Unisoft.ShowOldProcedures"))
    'Shared ReadOnly GRS01_Diarrhoea As String = "sp_rep_GRSA01"
    'Shared ReadOnly GRS02_Haemostasis As String = "sp_rep_GRSA02" ' "Exec sp_rep_GRSA02 @UserID=@UserID, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @OGD=@OGD, @COLSIG=@COLSIG"
    'Shared ReadOnly GRS03_StendAndPegPej_Placement As String = "sp_rep_GRSA03" 'Exec sp_rep_GRSA03 @UserID=@UserID, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @FromAge=@FromAge, @ToAge=@ToAge, @CountOfProcedures=@CountOfProcedures, @ListOfPatients=@ListOfPatients, @OesophagealStent=@OesophagealStent, @DuodenalStent=@DuodenalStent, @UnitAsAWhole=@UnitAsAWhole, @ColonicStent=@ColonicStent, @PEG=@PEG, @PEJ=@PEJ

#Region "Cubes"
    'Private Shared _Cube01 = "SELECT Convert(varchar(4),DATEPART(yy, fw_Procedures.CreatedOn)) AS Period, fw_ProceduresTypes.ProcedureType, fw_ConsultantTypes.ConsultantType, fw_Consultants.ConsultantName, fw_Procedures.Age, fw_Patients.CNN+' '+fw_Patients.PatientName As Patient, fw_Patients.Gender, fw_Patients.PostCode, 1 As N FROM fw_ProceduresTypes INNER JOIN fw_Procedures ON fw_ProceduresTypes.ProcedureTypeId = fw_Procedures.ProcedureTypeId INNER JOIN fw_Patients ON fw_Procedures.PatientId = fw_Patients.PatientId INNER JOIN fw_ProceduresConsultants ON fw_Procedures.ProcedureId = fw_ProceduresConsultants.ProcedureId INNER JOIN fw_Consultants ON fw_ProceduresConsultants.ConsultantId = fw_Consultants.ConsultantId INNER JOIN fw_ConsultantTypes ON fw_ProceduresConsultants.ConsultantTypeId = fw_ConsultantTypes.ConsultantTypeId"
    'Private Shared _Cube02 = "SELECT C.ProcedureType, C.CNN, C.PatientName , Year(C.CreatedOn) As [Year] , Month(C.CreatedOn) As [Month] , C.Age , C.Instrument, C.ScopeId, C.ConsultantName, C.ConsultantType, C.N From Cube_Instruments C"
    Public Shared Function GetCube01() As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "" '_Cube01
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Public Shared Function GetCube02() As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "" ' _Cube02
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Public Shared Function SToBoolean(ByVal character As String) As Boolean
        If character = "1" Then
            SToBoolean = True
        Else
            SToBoolean = False
        End If
    End Function

#End Region
#Region "GRS"


    Public Shared Function GetGRSA01(ByVal DateFrom As String, ByVal DateTo As String) As DataTable
        'Public Shared Function GetGRSA01(ByVal UserID As String, ByVal DateFrom As Date, ByVal DateTo As Date) As DataSet
        Dim dtReportData As New DataTable
        Try
            Dim dateFromParam As New SqlParameter("@DateFrom", DbType.DateTime),
                dateToParam As New SqlParameter("@DateTo", DbType.DateTime)

            dateFromParam.Value = DateFrom
            dateToParam.Value = DateTo

            Using da As New DataAccess
                dtReportData = da.ExecuteSP(ERS_Report.GRS01_Diarrhoea, New SqlParameter() {dateFromParam, dateToParam})
            End Using

            Return IIf((dtReportData.Rows.Count > 0), dtReportData, Nothing)
        Catch ex As Exception
            Return Nothing
        End Try


    End Function
    'Private Shared _GRSA02 As String = "Exec sp_rep_GRSA02 @UserID=@UserID, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @OGD=@OGD, @COLSIG=@COLSIG"
    'Public Shared Property GRSA02 As String
    '    Get
    '        Return _GRSA02
    '    End Get
    '    Set(value As String)
    '        _GRSA02 = value
    '    End Set
    'End Property
    Public Shared Function GetGRSA02(ByVal UserID As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String, ByVal OGD As String, ByVal COLSIG As String) As DataSet
        'Dim dtReportData As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim end1 As Boolean, end2 As Boolean, ogd2 As Boolean, colsig2 As Boolean
        end1 = IIf(Endoscopist1 = "1", True, False)
        end2 = Not end1
        ogd2 = IIf(OGD = "1", True, False)
        colsig2 = IIf(COLSIG = "1", True, False)

        'Dim sql As String = GRSA02
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", end1))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", end2))
        cmd.Parameters.Add(New SqlParameter("@OGD", ogd2))
        cmd.Parameters.Add(New SqlParameter("@COLSIG", colsig2))

        cmd.CommandText = ERS_Report.GRS02_Haemostasis
        cmd.CommandType = CommandType.StoredProcedure
        cmd.Connection = connection

        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If


        'Try
        '    Dim paramEndoscopist1 As New SqlParameter("@Endoscopist1", DbType.String),
        '        paramEndoscopist2 As New SqlParameter("@Endoscopist2", DbType.String),
        '        paramOGD As New SqlParameter("@OGD", DbType.String),
        '        paramCOLSIG As New SqlParameter("@COLSIG", DbType.String)

        '    paramEndoscopist1.Value = Endoscopist1
        '    paramEndoscopist2.Value = Endoscopist2
        '    paramOGD.Value = OGD
        '    paramCOLSIG.Value = COLSIG

        '    dtReportData = DataAccess.ExecuteSP(ERS_Report.GRS02_Haemostasis, New SqlParameter() {paramEndoscopist1, paramEndoscopist2, paramOGD, paramCOLSIG})

        '    Return IIf((dtReportData.Rows.Count > 0), dtReportData, Nothing)
        'Catch ex As Exception
        '    Return Nothing
        'End Try

    End Function

    Public Shared Function GetGRSA02_ShawkatNewReport(ByVal UserID As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String, ByVal OGD As String, ByVal COLSIG As String) As DataTable
        Dim dtReportData As DataTable

        Dim IsEndoscopist1 As Integer, IsEndoscopist2 As Integer, IncludeOGD As Integer, IncludeColSigma As Integer
        Try
            IsEndoscopist1 = Convert.ToInt32(Endoscopist1)
            IsEndoscopist2 = Convert.ToInt32(Endoscopist2)
            IncludeOGD = Convert.ToInt32(OGD)
            IncludeColSigma = Convert.ToInt32(COLSIG)
        Catch ex As Exception

        End Try


        Try
            'dtReportData = Reporting.GetGRS02_ReportData(ERS_Report.GRS02_Haemostasis, IsEndoscopist1, IsEndoscopist2, IncludeOGD, IncludeColSigma)
            dtReportData = Reporting.GetGRS02_ReportData("[dbo].[sp_rep_GRSA02_v2]", IsEndoscopist1, IsEndoscopist2, IncludeOGD, IncludeColSigma)

            Return IIf((dtReportData.Rows.Count > 0), dtReportData, Nothing)
        Catch ex As Exception
            Return Nothing
        End Try

    End Function
    'Private Shared _GRSA03 As String = "Exec sp_rep_GRSA03 @UserID=@UserID, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @FromAge=@FromAge, @ToAge=@ToAge, @CountOfProcedures=@CountOfProcedures, @ListOfPatients=@ListOfPatients, @OesophagealStent=@OesophagealStent, @DuodenalStent=@DuodenalStent, @UnitAsAWhole=@UnitAsAWhole, @ColonicStent=@ColonicStent, @PEG=@PEG, @PEJ=@PEJ"
    'Public Shared Property GRSA03 As String
    '    Get
    '        Return _GRSA03
    '    End Get
    '    Set(value As String)
    '        _GRSA03 = value
    '    End Set
    'End Property
    Public Shared Function GetGRSA03(ByVal UserID As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String, ByVal FromAge As String, ByVal ToAge As String, ByVal CountOfProcedures As String, ByVal ListOfPatients As String, ByVal OesophagealStent As String, ByVal DuodenalStent As String, ByVal UnitAsAWhole As String, ByVal ColonicStent As String, ByVal PEG As String, ByVal PEJ As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        'Dim sql As String = ERS_Report.GRS03_StendAndPegPej_Placement
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", Endoscopist1))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", Endoscopist2))
        cmd.Parameters.Add(New SqlParameter("@FromAge", FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", ToAge))
        cmd.Parameters.Add(New SqlParameter("@CountOfProcedures", CountOfProcedures))
        cmd.Parameters.Add(New SqlParameter("@ListOfPatients", ListOfPatients))
        cmd.Parameters.Add(New SqlParameter("@OesophagealStent", OesophagealStent))
        cmd.Parameters.Add(New SqlParameter("@DuodenalStent", DuodenalStent))
        cmd.Parameters.Add(New SqlParameter("@UnitAsAWhole", UnitAsAWhole))
        cmd.Parameters.Add(New SqlParameter("@ColonicStent", ColonicStent))
        cmd.Parameters.Add(New SqlParameter("@PEG", PEG))
        cmd.Parameters.Add(New SqlParameter("@PEJ", PEJ))

        cmd.CommandText = ERS_Report.GRS03_StendAndPegPej_Placement

        cmd.Connection = connection
        cmd.CommandType = CommandType.StoredProcedure
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSA04A As String = "Exec sp_rep_GRSA04A @UserID=@UserID, @Summary=@Summary"
    Public Shared Property GRSA04A As String
        Get
            Return _GRSA04A
        End Get
        Set(value As String)
            _GRSA04A = value
        End Set
    End Property
    Public Shared Function GetGRSA04A(ByVal UserID As String, ByVal Summary As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSA04A
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@Summary", Summary))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSA04B As String = "Exec sp_rep_GRSA04B @UserID=@UserID, @Patients=@Patients"
    Public Shared Property GRSA04B As String
        Get
            Return _GRSA04B
        End Get
        Set(value As String)
            _GRSA04B = value
        End Set
    End Property
    Public Shared Function GetGRSA04B(ByVal UserID As String, ByVal Patients As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSA04B
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@Patients", Patients))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSA05A As String = "Exec sp_rep_GRSA05A @UserID=@UserID, @UnitAsAWhole=@UnitAsAWhole"
    Public Shared Property GRSA05A As String
        Get
            Return _GRSA05A
        End Get
        Set(value As String)
            _GRSA05A = value
        End Set
    End Property
    Public Shared Function GetGRSA05A(ByVal UserID As String, ByVal UnitAsAWhole As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSA05A
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@UnitAsAWhole", UnitAsAWhole))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSA05B As String = "Exec sp_rep_GRSA05B @UserID=@UserID"
    Public Shared Property GRSA05B As String
        Get
            Return _GRSA05B
        End Get
        Set(value As String)
            _GRSA05B = value
        End Set
    End Property
    Public Shared Function GetGRSA05B(ByVal UserID As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSA05B
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSA05C As String = "Exec sp_rep_GRSA05C @UserID=@UserID"
    Public Shared Property GRSA05C As String
        Get
            Return _GRSA05C
        End Get
        Set(value As String)
            _GRSA05C = value
        End Set
    End Property
    Public Shared Function GetGRSA05C(ByVal UserID As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSA05C
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSB01 As String = "Exec sp_rep_GRSB01 @UserID=@UserID, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @Sessile=@Sessile, @Pedunculated=@Pedunculated, @Pseudopolyp=@Pseudopolyp, @GTSessile=@GTSessile, @GTPedunculated=@GTPedunculated, @GTPseudopolyp=@GTPseudopolyp, @FromAge=@FromAge, @ToAge=@ToAge"
    Public Shared Property GRSB01 As String
        Get
            Return _GRSB01
        End Get
        Set(value As String)
            _GRSB01 = value
        End Set
    End Property
    Public Shared Function GetGRSB01(ByVal UserID As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String, ByVal Sessile As String, ByVal Pedunculated As String, ByVal Pseudopolyp As String, ByVal GTSessile As String, ByVal GTPedunculated As String, ByVal GTPseudopolyp As String, ByVal FromAge As String, ByVal ToAge As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSB01
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", Endoscopist1))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", Endoscopist2))
        cmd.Parameters.Add(New SqlParameter("@Sessile", Sessile))
        cmd.Parameters.Add(New SqlParameter("@Pedunculated", Pedunculated))
        cmd.Parameters.Add(New SqlParameter("@Pseudopolyp", Pseudopolyp))
        cmd.Parameters.Add(New SqlParameter("@GTSessile", GTSessile))
        cmd.Parameters.Add(New SqlParameter("@GTPedunculated", GTPedunculated))
        cmd.Parameters.Add(New SqlParameter("@GTPseudopolyp", GTPseudopolyp))
        cmd.Parameters.Add(New SqlParameter("@FromAge", FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", ToAge))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSB02 As String = "Exec sp_rep_GRSB02 @UserID=@UserID, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @FromAge=@FromAge, @ToAge=@ToAge, @AppId=@AppId"
    Public Shared Property GRSB02 As String
        Get
            Return _GRSB02
        End Get
        Set(value As String)
            _GRSB02 = value
        End Set
    End Property
    Public Shared Function GetGRSB02(ByVal UserID As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String, ByVal FromAge As String, ByVal ToAge As String, ByVal AppId As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSB02
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", Endoscopist1))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", Endoscopist2))
        cmd.Parameters.Add(New SqlParameter("@FromAge", FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", ToAge))
        cmd.Parameters.Add(New SqlParameter("@AppID", AppId))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSB03 As String = "Exec sp_rep_GRSB03 @UserID=@UserID, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @FromAge=@FromAge, @ToAge=@ToAge, @AppId=@AppId"
    Public Shared Property GRSB03 As String
        Get
            Return _GRSB03
        End Get
        Set(value As String)
            _GRSB03 = value
        End Set
    End Property
    Public Shared Function GetGRSB03(ByVal UserID As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String, ByVal FromAge As String, ByVal ToAge As String, ByVal AppId As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSB03
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", Endoscopist1))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", Endoscopist2))
        cmd.Parameters.Add(New SqlParameter("@FromAge", FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", ToAge))
        cmd.Parameters.Add(New SqlParameter("@AppId", AppId))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSB04 As String = "Exec sp_rep_GRSB04 @UserID=@UserID"
    Public Shared Property GRSB04 As String
        Get
            Return _GRSB04
        End Get
        Set(value As String)
            _GRSB04 = value
        End Set
    End Property
    Public Shared Function GetGRSB04(ByVal UserID As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSB04
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSB05 As String = "Exec sp_rep_GRSB05 @UserID=@UserID, @AppId=@AppId, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @Sessile=@Sessile, @SessileN=@SessileN, @Pedunculated=@Pedunculated, @PedunculatedN=@PedunculatedN, @Submucosal=@Submucosal, @SubmucosalN=@SubmucosalN, @Villous=@Villous, @VillousN=@VillousN, @Ulcerative=@Ulcerative, @UlcerativeN=@UlcerativeN, @Stricturing=@Stricturing, @StricturingN=@StricturingN, @Polypoidal=@Polypoidal, @PolypoidalN=@PolypoidalN, @FromAge=@FromAge, @ToAge=@ToAge"
    Public Shared Property GRSB05 As String
        Get
            Return _GRSB05
        End Get
        Set(value As String)
            _GRSB05 = value
        End Set
    End Property
    Public Shared Function GetGRSB05(ByVal UserId As String, ByVal AppId As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String, ByVal Sessile As String, ByVal SessileN As String, ByVal Pedunculated As String, ByVal PedunculatedN As String, ByVal Submucosal As String, ByVal SubmucosalN As String, ByVal Villous As String, ByVal VillousN As String, ByVal Ulcerative As String, ByVal UlcerativeN As String, ByVal Stricturing As String, ByVal StricturingN As String, ByVal Polypoidal As String, ByVal PolypoidalN As String, ByVal FromAge As String, ByVal ToAge As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSB05
        cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
        cmd.Parameters.Add(New SqlParameter("@AppId", AppId))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", Endoscopist1))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", Endoscopist2))
        cmd.Parameters.Add(New SqlParameter("@Sessile", Sessile))
        cmd.Parameters.Add(New SqlParameter("@SessileN", SessileN))
        cmd.Parameters.Add(New SqlParameter("@Pedunculated", Pedunculated))
        cmd.Parameters.Add(New SqlParameter("@PedunculatedN", PedunculatedN))
        cmd.Parameters.Add(New SqlParameter("@Submucosal", Submucosal))
        cmd.Parameters.Add(New SqlParameter("@SubmucosalN", SubmucosalN))
        cmd.Parameters.Add(New SqlParameter("@Villous", Villous))
        cmd.Parameters.Add(New SqlParameter("@VillousN", VillousN))
        cmd.Parameters.Add(New SqlParameter("@Ulcerative", Ulcerative))
        cmd.Parameters.Add(New SqlParameter("@UlcerativeN", UlcerativeN))
        cmd.Parameters.Add(New SqlParameter("@Stricturing", Stricturing))
        cmd.Parameters.Add(New SqlParameter("@StricturingN", StricturingN))
        cmd.Parameters.Add(New SqlParameter("@Polypoidal", Polypoidal))
        cmd.Parameters.Add(New SqlParameter("@PolypoidalN", PolypoidalN))
        cmd.Parameters.Add(New SqlParameter("@FromAge", FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", ToAge))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSC01 As String = "Exec [dbo].[sp_rep_GRSC01] @UserID=@UserId, @ProcType=@ProcType, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @AppId=@AppId"
    Public Shared Property GRSC01 As String
        Get
            Return _GRSC01
        End Get
        Set(value As String)
            _GRSC01 = value
        End Set
    End Property
    Public Shared Function GetGRSC01(ByVal UserId As String, ByVal ProcType As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSC01
        cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
        cmd.Parameters.Add(New SqlParameter("@ProcType", ProcType))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", Endoscopist1))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", Endoscopist2))
        If ShowOldProcedures Then
            cmd.Parameters.Add(New SqlParameter("@AppID", "A"))
        Else
            cmd.Parameters.Add(New SqlParameter("@AppID", "E"))
        End If
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSC02 As String = "Exec [dbo].[sp_rep_GRSC02] @UserId=@UserId, @Summary=@Summary, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @AppId=@AppId"
    Public Shared Property GRSC02 As String
        Get
            Return _GRSC02
        End Get
        Set(value As String)
            _GRSC02 = value
        End Set
    End Property
    Public Shared Function GetGRSC02(ByVal UserId As String, ByVal Summary As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSC02
        cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
        cmd.Parameters.Add(New SqlParameter("@Summary", Summary))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", Endoscopist1))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", Endoscopist2))
        If ShowOldProcedures Then
            cmd.Parameters.Add(New SqlParameter("@AppID", "A"))
        Else
            cmd.Parameters.Add(New SqlParameter("@AppID", "E"))
        End If
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSC03 As String = "Exec [dbo].[sp_rep_GRSC03] @UserID=@UserId, @ProcType=@ProcType, @Complications=@Complications, @ReversalAgents=@ReversalAgents, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @AppId=@AppId"
    Public Shared Property GRSC03 As String
        Get
            Return _GRSC03
        End Get
        Set(value As String)
            _GRSC03 = value
        End Set
    End Property
    Public Shared Function GetGRSC03(ByVal UserId As String, ByVal ProcType As String, ByVal Complications As String, ByVal ReversalAgents As String, ByVal Endoscopist1 As String, ByVal Endoscopist2 As String, ByVal AppId As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSC03
        cmd.Parameters.Add(New SqlParameter("@UserID", UserId))
        cmd.Parameters.Add(New SqlParameter("@ProcType", ProcType))
        cmd.Parameters.Add(New SqlParameter("@Complications", Complications))
        cmd.Parameters.Add(New SqlParameter("@ReversalAgents", ReversalAgents))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", Endoscopist1))
        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", Endoscopist2))
        cmd.Parameters.Add(New SqlParameter("@AppID", AppId))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSC04 As String = "Exec [dbo].[sp_rep_GRSC04] @UserID=@UserID, @ProcType=@ProcType"
    Public Shared Property GRSC04 As String
        Get
            Return _GRSC04
        End Get
        Set(value As String)
            _GRSC04 = value
        End Set
    End Property
    Public Shared Function GetGRSC04(ByVal UserID As String, ByVal ProcType As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSC04
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@ProcType", ProcType))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSC05A As String = "[dbo].[sp_rep_GRSC05] @UserID=@UserID, @ProcType=@ProcType"
    Public Shared Property GRSC05A As String
        Get
            Return _GRSC05A
        End Get
        Set(value As String)
            _GRSC05A = value
        End Set
    End Property
    Public Shared Function GetGRSC05A(ByVal UserID As String, ByVal ProcType As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSC05A
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@ProcType", ProcType))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSC05B As String = "SELECT ISNULL(SUM(Unspecified), 0) AS Unspecified, ISNULL(SUM(NoBowelPrep), 0) AS NoBowelPrep FROM v_rep_BowelPrepGRSC05"
    Public Shared Property GRSC05B As String
        Get
            Return _GRSC05B
        End Get
        Set(value As String)
            _GRSC05B = value
        End Set
    End Property
    Public Shared Function GetGRSC05B() As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSC05B
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSC07 As String = "Execute [dbo].[sp_rep_GRSC07] @UserID=@UserID, @ProcType=@ProcType, @OutputAs=@OutputAs, @Check=@Check, @FromAge=@FromAge, @ToAge=@ToAge"
    Public Shared Property GRSC07 As String
        Get
            Return _GRSC07
        End Get
        Set(value As String)
            _GRSC07 = value
        End Set
    End Property
    Public Shared Function GetGRSC07(ByVal UserID As String, ByVal ProcType As String, ByVal OutputAs As String, ByVal Check As String, ByVal FromAge As String, ByVal ToAge As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSC07
        'Add parameters in that position
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@ProcType", ProcType))
        cmd.Parameters.Add(New SqlParameter("@OutputAs", OutputAs))
        cmd.Parameters.Add(New SqlParameter("@Check", Check))
        cmd.Parameters.Add(New SqlParameter("@FromAge", FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", ToAge))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Private Shared _GRSC08 As String = "Exec sp_rep_GRSC08 @UserID=@UserID, @UnitAsAWhole=@UnitAsAWhole, @ListPatients=@ListPatients"
    Public Shared Property GRSC08 As String
        Get
            Return _GRSC08
        End Get
        Set(value As String)
            _GRSC08 = value
        End Set
    End Property
    Public Shared Function GetGRSC08(ByVal UserID As String, ByVal UnitAsAWhole As String, ByVal ListPatients As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = GRSC08
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@UnitAsAWhole", UnitAsAWhole))
        cmd.Parameters.Add(New SqlParameter("@ListPatients", ListPatients))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function

#End Region
#Region "Patients Report"
    Private Shared _BlankReports As String = "Select '' As ReportHeading, '' As ReportTrustType, '' As ReportSubHeading, '' As ReportHeader, '' As PatientName, '' As Forename, '' As Surname, '' As Gender, '' As DateOfBirdh, '' As NHSNo, '' As CaseNoteNo, '' As [Address], '' As GPName, '' As GPAddress, '' As ProcedureDate, '' As PatientStatus, HospitalName, '' As HospitalPhoneNumber, '' As Ward From [dbo].[ERS_OperatingHospitals]"
    Private Shared _SearchString1 As String = ""
    Private Shared _SearchString2 As String = ""
    Private Shared _SearchString3 As String = ""
    Private Shared _SearchString4 As String = ""
    Private Shared _opt_condition As String = "ALL"

    Private Shared _ListOfPatients As String = "1"
    Private Shared _Anonimised As String = "0"
    Private Shared _IncludeTherapeutics As String = "0"
    Private Shared _IncludeIndications As String = "0"
    Private Shared _CNNvsNHS As String = "CNN"
    Private Shared _DailyTotals1 As String = "0"
    Private Shared _DailyTotals2 As String = "0"
    Private Shared _DailyTotals3 As String = "0"
    Private Shared _Summary As String = "0"
    Private Shared _DiagVsthera As String = "0"
    Private Shared _DNA As String = "0"
    Private Shared _PatientStatusId As String = "0"
    Private Shared _PatientTypeId As String = "0"
    Private Shared _ReportOrder As String = "ASC"
    Private Shared _FromAge As String = "0"
    Private Shared _ToAge As String = "200"
    Public Shared Property BlankReports As String
        Get
            Return (_BlankReports)
        End Get
        Set(value As String)
            _BlankReports = value
        End Set
    End Property
    Public Shared Property SearchString1 As String
        Get
            Return _SearchString1
        End Get
        Set(value As String)
            _SearchString1 = value
        End Set
    End Property
    Public Shared Property SearchString2 As String
        Get
            Return _SearchString2
        End Get
        Set(value As String)
            _SearchString2 = value
        End Set
    End Property
    Public Shared Property SearchString3 As String
        Get
            Return _SearchString3
        End Get
        Set(value As String)
            _SearchString3 = value
        End Set
    End Property
    Public Shared Property SearchString4 As String
        Get
            Return _SearchString4
        End Get
        Set(value As String)
            _SearchString4 = value
        End Set
    End Property
    Public Shared Property opt_condition As String
        Get
            Return _opt_condition
        End Get
        Set(value As String)
            _opt_condition = value
        End Set
    End Property
    Public Shared Function GetBlankReports() As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = BlankReports
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Shared Function GetPatients() As DataTable
        Dim dsPatients As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("startup_select", connection)
            cmd.CommandType = CommandType.StoredProcedure


            If Not String.IsNullOrEmpty(SearchString1) Then
                cmd.Parameters.Add(New SqlParameter("@SearchString1", SearchString1))
            Else
                cmd.Parameters.Add(New SqlParameter("@SearchString1", SqlTypes.SqlString.Null))
            End If

            If Not String.IsNullOrEmpty(SearchString2) Then
                cmd.Parameters.Add(New SqlParameter("@SearchString2", SearchString2))
            Else
                cmd.Parameters.Add(New SqlParameter("@SearchString2", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(SearchString3) Then
                cmd.Parameters.Add(New SqlParameter("@SearchString3", SearchString3))
            Else
                cmd.Parameters.Add(New SqlParameter("@SearchString3", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(SearchString4) Then
                cmd.Parameters.Add(New SqlParameter("@SearchString4", SearchString4))
            Else
                cmd.Parameters.Add(New SqlParameter("@SearchString4", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@SearchTab", CInt(HttpContext.Current.Session(Constants.SESSION_SEARCH_TAB))))
            cmd.Parameters.Add(New SqlParameter("@Condition", opt_condition))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPatients)
        End Using

        If dsPatients.Tables.Count > 0 Then
            Return dsPatients.Tables(0)
        End If
        Return New DataTable
    End Function
    Public Shared Property ListOfPatients As String
        Get
            Return _ListOfPatients
        End Get
        Set(value As String)
            _ListOfPatients = value
        End Set
    End Property
    Public Shared Property Anonimised As String
        Get
            Return _Anonimised
        End Get
        Set(value As String)
            _Anonimised = value
        End Set
    End Property
    Public Shared Property IncludeTherapeutics As String
        Get
            Return _IncludeTherapeutics
        End Get
        Set(value As String)
            _IncludeTherapeutics = value
        End Set
    End Property
    Public Shared Property IncludeIndications As String
        Get
            Return _IncludeIndications
        End Get
        Set(value As String)
            _IncludeIndications = value
        End Set
    End Property
    Public Shared Property CNNvsNHS As String
        Get
            Return _CNNvsNHS
        End Get
        Set(value As String)
            _CNNvsNHS = value
        End Set
    End Property
    Public Shared Property DailyTotals1 As String
        Get
            Return _DailyTotals1
        End Get
        Set(value As String)
            _DailyTotals1 = value
        End Set
    End Property
    Public Shared Property DailyTotals2 As String
        Get
            Return _DailyTotals2
        End Get
        Set(value As String)
            _DailyTotals2 = value
        End Set
    End Property
    Public Shared Property DailyTotals3 As String
        Get
            Return _DailyTotals3
        End Get
        Set(value As String)
            _DailyTotals3 = value
        End Set
    End Property
    Public Shared Property Summary As String
        Get
            Return _Summary
        End Get
        Set(value As String)
            _Summary = value
        End Set
    End Property
    Public Shared Property DiagVsthera As String
        Get
            Return _DiagVsthera
        End Get
        Set(value As String)
            _DiagVsthera = value
        End Set
    End Property
    Public Shared Property DNA As String
        Get
            Return _DNA
        End Get
        Set(value As String)
            _DNA = value
        End Set
    End Property
    Public Shared Property PatientStatusId As String
        Get
            Return _PatientStatusId
        End Get
        Set(value As String)
            _PatientStatusId = value
        End Set
    End Property
    Public Shared Property PatientTypeId As String
        Get
            Return _PatientTypeId
        End Get
        Set(value As String)
            _PatientTypeId = value
        End Set
    End Property
    Public Shared Property ReportOrder As String
        Get
            Return _ReportOrder
        End Get
        Set(value As String)
            _ReportOrder = value
        End Set
    End Property
    Public Shared Property FromAge As String
        Get
            Return _FromAge
        End Get
        Set(value As String)
            _FromAge = value
        End Set
    End Property
    Public Shared Property ToAge As String
        Get
            Return _ToAge
        End Get
        Set(value As String)
            _ToAge = value
        End Set
    End Property
    Public Shared listAnalisys1 As String = ""
    Public Shared listAnalisys2 As String = ""
    Public Shared listAnalisys3 As String = ""
    Public Shared listAnalisys4 As String = ""
    Public Shared listAnalisys5 As String = ""

    Public Shared Function GetListAnalysis1(ByVal UserId As String, ByVal IncludeIndications As String, ByVal IncludeTherapeutics As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "Exec [dbo].[report_ListAnalysis1] @UserID=@UserID, @IncludeIndications=@IncludeIndications, @IncludeTherapeutics=@IncludeTherapeutics, @FromAge=@FromAge, @ToAge=@ToAge"
        'If Reports.CNNvsNHS <> "" Then
        'sql = sql + ", @RadioButtonNHS='" + Reports.CNNvsNHS + "'"
        'End If
        If Reports.ReportOrder <> "" Then
            sql = sql + ", @OrderBy='" + Reports.ReportOrder + "'"
        End If
        If Reports.PatientStatusId = "0" Or Reports.PatientStatusId = "" Then
            sql = sql + ", @PatientStatusId=NULL"
        Else
            sql = sql + ", @PatientStatusId='" + Reports.PatientStatusId + "'"
        End If
        If Reports.PatientTypeId = "0" Or Reports.PatientTypeId = "" Then
            sql = sql + ", @PatientTypeId=NULL"
        Else
            sql = sql + ", @PatientTypeId='" + Reports.PatientTypeId + "'"
        End If

        'cmd.Parameters.Add(New SqlParameter("@UserID", UserId))
        'cmd.Parameters.Add(New SqlParameter("@IncludeIndications", IncludeIndications))
        'cmd.Parameters.Add(New SqlParameter("@IncludeTherapeutics", IncludeTherapeutics))
        'cmd.Parameters.Add(New SqlParameter("@FromAge", Reports.FromAge))
        'cmd.Parameters.Add(New SqlParameter("@ToAge", Reports.ToAge))
        'cmd.CommandText = sql
        'cmd.Connection = connection
        'cmd.CommandType = CommandType.Text
        'Dim adapter = New SqlDataAdapter(cmd)
        'connection.Open()
        'adapter.Fill(ds)
        'If ds.Tables.Count > 0 Then
        '    Return ds.Tables(0)
        'Else
        '    Return Nothing
        'End If
        Return DataAccess.ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@UserID", UserId),
                                                                                   New SqlParameter("@IncludeIndications", IncludeIndications),
                                                                                   New SqlParameter("@IncludeTherapeutics", IncludeTherapeutics),
                                                                                   New SqlParameter("@FromAge", Reports.FromAge),
                                                                                   New SqlParameter("@ToAge", Reports.ToAge)})

    End Function

    Public Shared Function GetListAnalysis2(ByVal UserId As String, ByVal DiagVsThera As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "Exec [dbo].[report_ListAnalysis2] @UserID=@UserID, @FromAge=@FromAge, @ToAge=@ToAge"
        If Reports.PatientStatusId = "0" Or Reports.PatientStatusId = "" Then
            sql = sql + ", @PatientStatusId=NULL"
        Else
            sql = sql + ", @PatientStatusId='" + Reports.PatientStatusId + "'"
        End If
        If Reports.PatientTypeId = "0" Or Reports.PatientTypeId = "" Then
            sql = sql + ", @PatientTypeId=NULL"
        Else
            sql = sql + ", @PatientTypeId='" + Reports.PatientTypeId + "'"
        End If
        ', @PatientStatusId=NULL, @PatientTypeId=NULL"
        cmd.Parameters.Add(New SqlParameter("@UserID", UserId))
        'cmd.Parameters.Add(New SqlParameter("@DiagVsThera", DiagVsThera))
        cmd.Parameters.Add(New SqlParameter("@FromAge", Reports.FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", Reports.ToAge))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Public Shared Function GetListAnalysis3(ByVal UserId As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "Exec [dbo].[report_ListAnalysis3] @UserID=@UserID, @FromAge=@FromAge, @ToAge=@ToAge"
        If Reports.PatientStatusId = "0" Or Reports.PatientStatusId = "" Then
            sql = sql + ", @PatientStatusId=NULL"
        Else
            sql = sql + ", @PatientStatusId='" + Reports.PatientStatusId + "'"
        End If
        If Reports.PatientTypeId = "0" Or Reports.PatientTypeId = "" Then
            sql = sql + ", @PatientTypeId=NULL"
        Else
            sql = sql + ", @PatientTypeId='" + Reports.PatientTypeId + "'"
        End If
        ', @PatientStatusId=NULL, @PatientTypeId=NULL"
        cmd.Parameters.Add(New SqlParameter("@UserID", UserId))
        cmd.Parameters.Add(New SqlParameter("@FromAge", Reports.FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", Reports.ToAge))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Public Shared Function GetListAnalysis4(ByVal UserId As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "Exec [dbo].[report_ListAnalysis4] @UserID=@UserID, @FromAge=@FromAge, @ToAge=@ToAge"
        If Reports.PatientStatusId = "0" Or Reports.PatientStatusId = "" Then
            sql = sql + ", @PatientStatusId=NULL"
        Else
            sql = sql + ", @PatientStatusId='" + Reports.PatientStatusId + "'"
        End If
        If Reports.PatientTypeId = "0" Or Reports.PatientTypeId = "" Then
            sql = sql + ", @PatientTypeId=NULL"
        Else
            sql = sql + ", @PatientTypeId='" + Reports.PatientTypeId + "'"
        End If
        ', @PatientStatusId=NULL, @PatientTypeId=NULL"
        cmd.Parameters.Add(New SqlParameter("@UserID", UserId))
        cmd.Parameters.Add(New SqlParameter("@FromAge", Reports.FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", Reports.ToAge))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Public Shared Function GetListAnalysis5(ByVal UserId As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "Exec [dbo].[report_ListAnalysis5] @UserID=@UserID, @FromAge=@FromAge, @ToAge=@ToAge"
        If Reports.PatientStatusId = "0" Or Reports.PatientStatusId = "" Then
            sql = sql + ", @PatientStatusId=NULL"
        Else
            sql = sql + ", @PatientStatusId='" + Reports.PatientStatusId + "'"
        End If
        If Reports.PatientTypeId = "0" Or Reports.PatientTypeId = "" Then
            sql = sql + ", @PatientTypeId=NULL"
        Else
            sql = sql + ", @PatientTypeId='" + Reports.PatientTypeId + "'"
        End If


        ', @PatientStatusId=NULL, @PatientTypeId=NULL"
        cmd.Parameters.Add(New SqlParameter("@UserID", UserId))
        cmd.Parameters.Add(New SqlParameter("@FromAge", Reports.FromAge))
        cmd.Parameters.Add(New SqlParameter("@ToAge", Reports.ToAge))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function

#End Region
#Region "JAGGRS"
    Private Shared ConsultantsQueryStr1 As String = "SELECT ReportID, Consultant, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_Consultants WHERE (ReportID Not In (Select ConsultantID From ERS_ReportConsultants Where UserID=@UserID)) And (Consultant <> '(None)') and ConsultantID in (Select UserId from ERS_UserOperatingHospitals uoh join ERS_OperatingHospitals oh on oh.OperatingHospitalId = uoh.OperatingHospitalId where oh.TrustId = @TrustId)"
    Private Shared ConsultantsQueryStr2 As String = "SELECT ReportID, Consultant, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2 FROM v_rep_Consultants WHERE ReportID In (Select ConsultantID From ERS_ReportConsultants Where UserID=@UserID) And (Consultant <> '(None)') and ConsultantID in (Select UserId from ERS_UserOperatingHospitals uoh join ERS_OperatingHospitals oh on oh.OperatingHospitalId = uoh.OperatingHospitalId where oh.TrustId = @TrustId)"
    Private Shared BostonQueryStr1 As String = "Select Formulation, [Scale], [Right], [RightP],[Transverse], [TransverseP], [Left], [LeftP] From ERS_reportBoston1 Where UserID=@PKUserID"
    Private Shared BostonQueryStr2 As String = "Select Formulation, NoOfProcs, MeanScore From ERS_ReportBoston3 Where UserID=@UserID"
    Private Shared BostonQueryStr3 As String = "Select Formulation, Score, Frecuency From ERS_ReportBoston2 Where UserID=@UserID"
    Private Shared TotalProceduresPerformedQueryStr As String = "EXEC [dbo].[report_JAGTotalProceduresPerformed] @UserID"
    Private Shared OGDQueryStr As String = "EXEC [dbo].[report_JAGOGD] @UserID"
    Private Shared EUSQueryStr As String = "EXEC [dbo].[report_JAGEUS] @UserID"
    Private Shared PEGQueryStr As String = "EXEC [dbo].[report_JAGPEG] @UserID"
    Private Shared ERCQueryStr As String = "EXEC [dbo].[report_JAGERC] @UserID"
    Private Shared SIGQueryStr As String = "EXEC [dbo].[report_JAGSIG] @UserID"
    Private Shared COLQueryStr As String = "EXEC [dbo].[report_JAGCOL] @UserID"
    Private Shared BowelQueryStr As String = "EXEC [dbo].[report_JAGBowel] @UserID"
    Private Shared ConsultantsQueryStr As String = "SELECT DISTINCT RC.AnonimizedID As UserID, C.ConsultantName As Consultant From fw_ReportConsultants RC INNER JOIN  fw_Consultants C ON  C.ConsultantId=RC.ConsultantId INNER JOIN dbo.fw_ProceduresConsultants PC ON C.ConsultantId = PC.ConsultantId Where UserId=@UserId AND PC.ConsultantTypeId IN (1,2) Order By RC.AnonimizedID"
    Private Shared PEGProcsStr As String = "Select P.CNN As [Hospital no], P.PatientName As Patient, P.DOB As DateofBirth, PR.ProcedureId, PR.CreatedOn, I.InsertionType, I.Correct_Placement As CorrectPlacement, I.Incorrect_Placement As IncorrectPlacement From fw_Insertions I, fw_Sites S, fw_Procedures PR, fw_Patients P, fw_ProceduresConsultants PC, fw_ReportConsultants RC Where I.SiteId=S.SiteId And PR.ProcedureId=S.ProcedureId And PR.PatientId=P.PatientId And PR.ProcedureId=PC.ProcedureId And PC.ConsultantTypeId=1 And RC.ConsultantId=PC.ConsultantId And RC.AnonimizedID=@RowID And RC.UserId=@UserID"
    Private Shared _PEGPlace As String = "Select P.[Hospital no],P.[Forename]+' '+P.[Surname] As Patient, Convert(Date,P.[Date of birth]) As DateofBirth, ProcedureID, CreatedOn, InsertionType, Case Correct_Placement When 1 Then 'Yes' Else 'No' End As CorrectPlacement, Case Incorrect_Placement When 1 Then 'Yes' Else 'No' End As IncorrectPlacement, Release From [dbo].[v_rep_JAG_ProcsPEGPEJ] Procs, ERS_ReportFilter ERF, v_rep_JAG_ReportConsultants ERC, Patient P Where Release='UGI' And ERF.UserID=@UserID And ERF.UserID=ERC.UserID And ERC.AnonimizedID=@rowID And P.[Case note no]=Procs.[Case note no] And ([CreatedOn]>=ERF.FromDate And [CreatedOn]<=ERF.ToDate) And ((Endoscopist1=ERC.UGIID) Or (Endoscopist2=ERC.UGIID) Or (Assistant1=ERC.UGIID) Or (ListConsultant=ERC.UGIID) Or (Nurse1=ERC.UGIID) Or (Nurse2=ERC.UGIID) Or (Nurse3=ERC.UGIID)) Union All Select P.[Case note no],P.[Forename]+' '+P.[Surname] As Patient, Convert(Date,P.[Date of birth]) As DateofBirth, ProcedureID, CreatedOn, InsertionType, Case Correct_Placement When 1 Then 'Yes' Else 'No' End As CorrectPlacement, Case Incorrect_Placement When 1 Then 'Yes' Else 'No' End As IncorrectPlacement, Release From [dbo].[v_rep_JAG_ProcsPEGPEJ] Procs, ERS_ReportFilter ERF, v_rep_JAG_ReportConsultants ERC, Patient P Where Release='ERS' And ERF.UserID=@UserID And ERF.UserID=ERC.UserID And ERC.AnonimizedID=@rowID And P.[Case note no]=Procs.[Case note no] And ([CreatedOn]>=ERF.FromDate And [CreatedOn]<=ERF.ToDate) And ((Endoscopist1=ERC.ERSID) Or (Endoscopist2=ERC.ERSID) Or (Assistant1=ERC.ERSID) Or (ListConsultant=ERC.ERSID) Or (Nurse1=ERC.ERSID) Or (Nurse2=ERC.ERSID) Or (Nurse3=ERC.ERSID))"
    Private Shared _OGDMean As String = "Select [Hospital no],[Forename]+' '+[Surname] As Patient, AgeLimit, DrugName, Dose, ProcedureID, CreatedOn, ProcedureType, Release From [dbo].[v_rep_JAG_PremedicationUGIOGD] Procs, ERS_ReportFilter ERF, v_rep_JAG_ReportConsultants ERC Where Release='UGI' And ERF.UserID=@UserID And ERF.UserID=ERC.UserID And ERC.AnonimizedID=@RowID And ([CreatedOn]>=ERF.FromDate And [CreatedOn]<=ERF.ToDate) And ((Endoscopist1=ERC.UGIID) Or (Endoscopist2=ERC.UGIID) Or (Assistant1=ERC.UGIID) Or (ListConsultant=ERC.UGIID) Or (Nurse1=ERC.UGIID) Or (Nurse2=ERC.UGIID) Or (Nurse3=ERC.UGIID)) And AgeLimit Like @AgeLimit And DrugName Like @Drug Union All Select [Case note no],[Forename]+' '+[Surname] As Patient, AgeLimit, DrugName, Dose, ProcedureID, CreatedOn, ProcedureType, Release From [dbo].[v_rep_JAG_PremedicationERSOGD] Procs, ERS_ReportFilter ERF, v_rep_JAG_ReportConsultants ERC Where Release='ERS' And ERF.UserID=@UserID And ERF.UserID=ERC.UserID And ERC.AnonimizedID=@RowID And ([CreatedOn]>=ERF.FromDate And [CreatedOn]<=ERF.ToDate) And ((Endoscopist1=ERC.ERSID) Or (Endoscopist2=ERC.ERSID) Or (Assistant1=ERC.ERSID) Or (ListConsultant=ERC.ERSID) Or (Nurse1=ERC.ERSID) Or (Nurse2=ERC.ERSID) Or (Nurse3=ERC.ERSID)) And AgeLimit Like @AgeLimit And DrugName Like @Drug"
    Private Shared _OGDComp As String = "Select P.CNN As [Hospital no], P.PatientName As Patient, PR.ProcedureId, PR.CreatedOn , PL.CorrectPlacement, PL.IncorrectPlacement, PL.Placements From fw_Placements PL, fw_Sites S, fw_Procedures PR, fw_Patients P, fw_ProceduresConsultants PC, fw_Consultants C, fw_ReportConsultants RC Where S.SiteId=PL.SiteId And PR.ProcedureId=S.ProcedureId And P.PatientId=PR.PatientId And PR.ProcedureId=PC.ProcedureId And PC.ConsultantTypeId=1 And PC.ConsultantId=C.ConsultantId And C.ConsultantId=RC.ConsultantId And RC.UserId=@UserId And RC.AnonimizedID=@RowID And PL.Placements<>0"
    Private Shared _OGDComf As String = "Select P.CNN, P.PatientName As Patient, PR.ProcedureId, PR.CreatedOn , QA.NurseAssPatSedationScore, QA.NursesAssPatComfortScore, QA.PatientsSedationScore From fw_QA QA, fw_Procedures PR, fw_Patients P, fw_ProceduresConsultants PC, fw_Consultants C, fw_ReportConsultants RC Where PR.ProcedureId=QA.ProcedureId And P.PatientId=PR.PatientId And PR.ProcedureId=PC.ProcedureId And PC.ConsultantTypeId=1 And PC.ConsultantId=C.ConsultantId And C.ConsultantId=RC.ConsultantId And RC.UserId=@UserID And RC.AnonimizedID=@RowID And QA.NursesAssPatComfortScore>4 And PR.ProcedureTypeId=1"
    Private Shared _OGDRepe As String = "Select P.CNN, P.PatientName, PR.CreatedOn, RO.Result, RO.SeenWithin12weeks, RO.NotSeenWithin12Weeks, RO.StillToBeSeen, RO.SummaryText, RO.HealingText From fw_RepeatOGD RO, fw_Sites S, fw_Procedures PR, fw_Patients P, fw_ProceduresConsultants PC, fw_Consultants C, fw_ReportConsultants RC Where S.SiteId=RO.SiteId And PR.ProcedureId=S.ProcedureId And P.PatientId=PR.PatientId And PR.ProcedureId=PC.ProcedureId And PC.ConsultantTypeId=1 And PC.ConsultantId=C.ConsultantId And C.ConsultantId=RC.ConsultantId And RC.UserId=@UserId And RC.AnonimizedID=@RowID"
    Private Shared _Scoreboard As String = "SELECT PT.ProcedureType, C.ConsultantName, P.CNN AS [Hospital no], P.PatientName AS Patient, PR.CreatedOn, QA.NurseAssPatSedationScore, QA.NursesAssPatComfortScore, QA.PatientsSedationScore FROM fw_ProceduresTypes AS PT INNER JOIN fw_Procedures AS PR ON PT.ProcedureTypeId = PR.ProcedureTypeId INNER JOIN fw_QA AS QA ON PR.ProcedureId = QA.ProcedureId INNER JOIN fw_Patients AS P ON PR.PatientId = P.PatientId INNER JOIN fw_ProceduresConsultants AS PC ON PR.ProcedureId = PC.ProcedureId INNER JOIN fw_Consultants AS C ON PC.ConsultantId = C.ConsultantId INNER JOIN fw_ReportConsultants AS RC ON C.ConsultantId = RC.ConsultantId WHERE (PC.ConsultantTypeId = 1) AND (RC.UserId = @UserID)"
    Private Shared _ComfGauge As String = "Select PT.ProcedureType, C.ConsultantName, P.CNN As [Hospital no], P.PatientName As Patient, PR.ProcedureId, PR.CreatedOn , QA.NurseAssPatSedationScore, QA.NursesAssPatComfortScore, QA.PatientsSedationScore From fw_QA QA, fw_Procedures PR, fw_ProceduresTypes PT, fw_Patients P, fw_ProceduresConsultants PC, fw_Consultants C, fw_ReportConsultants RC Where PR.ProcedureTypeId=PT.ProcedureTypeId And PR.ProcedureId=QA.ProcedureId And P.PatientId=PR.PatientId And PR.ProcedureId=PC.ProcedureId And PC.ConsultantTypeId=1 And PC.ConsultantId=C.ConsultantId And C.ConsultantId=RC.ConsultantId And RC.UserId=@UserID"

    Public Shared Property ComfGauge As String
        Get
            Return (_ComfGauge)
        End Get
        Set(value As String)
            _ComfGauge = value
        End Set
    End Property
    Public Shared Property ScoreBoard As String
        Get
            Return (_Scoreboard)
        End Get
        Set(value As String)
            _Scoreboard = value
        End Set
    End Property
    Public Shared Property OGDRepe As String
        Get
            Return _OGDRepe
        End Get
        Set(ByVal Value As String)
            _OGDRepe = Value
        End Set
    End Property
    Public Shared Property OGDComp As String
        Get
            Return _OGDComp
        End Get
        Set(ByVal Value As String)
            _OGDComp = Value
        End Set
    End Property
    Public Shared Property OGDComf As String
        Get
            Return _OGDComf
        End Get
        Set(ByVal Value As String)
            _OGDComf = Value
        End Set
    End Property
    Public Shared Property OGDMean As String
        Get
            Return _OGDMean
        End Get
        Set(ByVal Value As String)
            _OGDMean = Value
        End Set
    End Property
    Public Shared Property PEGPlace As String
        Get
            Return _PEGPlace
        End Get
        Set(ByVal Value As String)
            _PEGPlace = Value
        End Set
    End Property
    Public Shared Property PEGProcs As String
        Get
            Return PEGProcsStr
        End Get
        Set(ByVal Value As String)
            PEGProcsStr = Value
        End Set
    End Property
    Public Shared Property Boston1Qry As String
        Get
            Return BostonQueryStr1
        End Get
        Set(ByVal Value As String)
            BostonQueryStr1 = Value
        End Set
    End Property
    Public Shared Property Boston2Qry As String
        Get
            Return BostonQueryStr2
        End Get
        Set(ByVal Value As String)
            BostonQueryStr2 = Value
        End Set
    End Property
    Public Shared Property Boston3Qry As String
        Get
            Return BostonQueryStr3
        End Get
        Set(ByVal Value As String)
            BostonQueryStr3 = Value
        End Set
    End Property
    Public Shared Property TotalProceduresPerformedQry As String
        Get
            Return TotalProceduresPerformedQueryStr
        End Get
        Set(ByVal Value As String)
            TotalProceduresPerformedQueryStr = Value
        End Set
    End Property
    Public Shared Property OGDQry As String
        Get
            Return OGDQueryStr
        End Get
        Set(ByVal Value As String)
            OGDQueryStr = Value
        End Set
    End Property
    Public Shared Property EUSQry As String
        Get
            Return EUSQueryStr
        End Get
        Set(ByVal Value As String)
            EUSQueryStr = Value
        End Set
    End Property
    Public Shared Property PEGQry As String
        Get
            Return PEGQueryStr
        End Get
        Set(ByVal Value As String)
            PEGQueryStr = Value
        End Set
    End Property
    Public Shared Property ERCQry As String
        Get
            Return ERCQueryStr
        End Get
        Set(ByVal Value As String)
            ERCQueryStr = Value
        End Set
    End Property
    Public Shared Property SIGQry As String
        Get
            Return SIGQueryStr
        End Get
        Set(ByVal Value As String)
            SIGQueryStr = Value
        End Set
    End Property
    Public Shared Property COLQry As String
        Get
            Return COLQueryStr
        End Get
        Set(ByVal Value As String)
            COLQueryStr = Value
        End Set
    End Property
    Public Shared Property BowelQry As String
        Get
            Return BowelQueryStr
        End Get
        Set(ByVal Value As String)
            BowelQueryStr = Value
        End Set
    End Property
    Public Shared Property ConsultantsQry As String
        Get
            Return ConsultantsQueryStr
        End Get
        Set(ByVal Value As String)
            ConsultantsQueryStr = Value
        End Set
    End Property
    Public Shared Property ConsultantsQry1 As String
        Get
            Return ConsultantsQueryStr1
        End Get
        Set(ByVal Value As String)
            ConsultantsQueryStr1 = Value
        End Set
    End Property
    Public Shared Property ConsultantsQry2 As String
        Get
            Return ConsultantsQueryStr2
        End Get
        Set(ByVal Value As String)
            ConsultantsQueryStr2 = Value
        End Set
    End Property
    Public Shared Property TotalScopesBookedQry As String
        Get
            Return ActivityQueryStringProperty
        End Get
        Set(ByVal Value As String)
            ActivityQueryStringProperty = Value
        End Set
    End Property

    Public Shared Function GetComfGauge(ByVal UserID As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = ComfGauge
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function
    Public Shared Function GetScoreBoard(ByVal UserID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = ScoreBoard
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        'cmd.Parameters.Add(New SqlParameter("@rowID", rowID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Sub SaveReportAudit(
                                EventType As Nullable(Of Integer),
                                   ApplicationID As Nullable(Of Integer),
                                   AppVersion As String,
                                  UserID As String,
                                   FullUsername As String,
                                   StationID As String,
                                  HospitalID As Nullable(Of Integer),
                                  HospitalName As String,
                                   OperatingHospitalID As Nullable(Of Integer),
                                   OperatingHospitalName As String,
                                   GroupName As String,
                                   ColumnName As String,
                                   ConsultantName As String,
                                        QueryText As String,
                                   Filename As String,
                                    ErrorCondition As Boolean)
        Dim sql As String = "INSERT INTO [ERS_ReportAudit] (EventType, ApplicationID, AppVersion, UserID, FullUsername, StationID, HospitalID, HospitalName, OperatingHospitalID, OperatingHospitalName, GroupName, ColumnName, ConsultantName, QueryText, FileName, ErrorCondition) " &
                            "VALUES (@EventType, @ApplicationID, @AppVersion, @UserID, @FullUsername, @StationID, @HospitalID, @HospitalName, @OperatingHospitalID, @OperatingHospitalName, @GroupName, @ColumnName, @ConsultantName, @QueryText, @FileName, @ErrorCondition) "
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            If EventType.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@EventType", EventType))
            Else
                cmd.Parameters.Add(New SqlParameter("@EventType", SqlTypes.SqlInt32.Null))
            End If
            If ApplicationID.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ApplicationID", ApplicationID))
            Else
                cmd.Parameters.Add(New SqlParameter("@ApplicationID", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(AppVersion) Then
                cmd.Parameters.Add(New SqlParameter("@AppVersion", AppVersion))
            Else
                cmd.Parameters.Add(New SqlParameter("@AppVersion", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(UserID) Then
                cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
            Else
                cmd.Parameters.Add(New SqlParameter("@UserID", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(FullUsername) Then
                cmd.Parameters.Add(New SqlParameter("@FullUsername", FullUsername))
            Else
                cmd.Parameters.Add(New SqlParameter("@FullUsername", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(StationID) Then
                cmd.Parameters.Add(New SqlParameter("@StationID", StationID))
            Else
                cmd.Parameters.Add(New SqlParameter("@StationID", SqlTypes.SqlString.Null))
            End If
            If HospitalID.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@HospitalID", HospitalID))
            Else
                cmd.Parameters.Add(New SqlParameter("@HospitalID", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(HospitalName) Then
                cmd.Parameters.Add(New SqlParameter("@HospitalName", HospitalName))
            Else
                cmd.Parameters.Add(New SqlParameter("@HospitalName", SqlTypes.SqlString.Null))
            End If
            If OperatingHospitalID.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalID))
            Else
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(OperatingHospitalName) Then
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalName", OperatingHospitalName))
            Else
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalName", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(GroupName) Then
                cmd.Parameters.Add(New SqlParameter("@GroupName", GroupName))
            Else
                cmd.Parameters.Add(New SqlParameter("@GroupName", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(ColumnName) Then
                cmd.Parameters.Add(New SqlParameter("@ColumnName", ColumnName))
            Else
                cmd.Parameters.Add(New SqlParameter("@ColumnName", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(ConsultantName) Then
                cmd.Parameters.Add(New SqlParameter("@ConsultantName", ConsultantName))
            Else
                cmd.Parameters.Add(New SqlParameter("@ConsultantName", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(QueryText) Then
                cmd.Parameters.Add(New SqlParameter("@QueryText", QueryText))
            Else
                cmd.Parameters.Add(New SqlParameter("@QueryText", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Filename) Then
                cmd.Parameters.Add(New SqlParameter("@FileName", Filename))
            Else
                cmd.Parameters.Add(New SqlParameter("@FileName", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@ErrorCondition", ErrorCondition))
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub
    Public Function GetReportColumns(ReportColumnGroupName As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "SELECT [ReportColumnID],[ReportName] FROM [ERS_ReportColumn] WHERE ReportColumnGroupName =@ReportColumnGroupName"
        cmd.Parameters.Add(New SqlParameter("@ReportColumnGroupName", ReportColumnGroupName))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    Public Function GetReportAuditors() As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "SELECT *  FROM [ERS_ReportAuditors]"
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetSelectedReportAuditors(ReportColumnID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "SELECT *  FROM ERS_ReportColumnAuditorsMap WHERE ReportColumnID = @ReportColumnID"
        cmd.CommandText = sql
        cmd.Parameters.Add(New SqlParameter("@ReportColumnID", ReportColumnID))
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Sub InsertReportColumnAuditorsMap(reportColumn As String, reportColumnGroup As String, cData As Dictionary(Of String, String))
        If cData.Count > 0 Then
            Dim dsDrug As New DataSet
            Dim sql As New StringBuilder
            Dim transaction As SqlTransaction

            sql.Append("DELETE FROM  ERS_ReportColumnAuditorsMap WHERE ReportColumnID =" & reportColumn & " ;")
            sql.Append("INSERT INTO [ERS_ReportColumnAuditorsMap] ([ReportColumnID],[ReportColumnGroupID],[ReportAuditorsID],[ReportAuditorsGroupID]) VALUES ")
            For Each item In cData
                sql.Append("(" & reportColumn & ", '" & reportColumnGroup & "', " & item.Key & ", '" & item.Value & "'),")
            Next
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                connection.Open()
                transaction = connection.BeginTransaction("trans")
                Dim cmd As New SqlCommand(IIf(sql.ToString.EndsWith(","), sql.ToString.Remove(sql.Length - 1), sql.ToString), connection)
                cmd.Transaction = transaction
                Try
                    cmd.CommandType = CommandType.Text

                    cmd.ExecuteNonQuery()
                    transaction.Commit()
                Catch ex As Exception
                    Try
                        transaction.Rollback()
                    Catch ex1 As Exception
                        Throw New Exception(ex1.Message & "-->" & ex.Message)
                    End Try
                End Try
            End Using
        End If
    End Sub
    Public Function GetAuditorsMenu(ReportColumnGroupID As String, ReportName As String) As List(Of String)
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "SELECT cast(r.ReportAuditorsID as varchar(50)) + '~' + r.ReportAuditorsText  FROM ERS_ReportColumnAuditorsMap m inner JOIN ERS_ReportColumn c ON m.ReportColumnID = c.ReportColumnID INNER JOIN [ERS_ReportAuditors] r ON m.ReportAuditorsID = r.ReportAuditorsID  WHERE m.ReportColumnGroupID = @ReportColumnGroupID AND c.ReportName = @ReportName"
        cmd.CommandText = sql
        cmd.Parameters.Add(New SqlParameter("@ReportColumnGroupID", ReportColumnGroupID))
        cmd.Parameters.Add(New SqlParameter("@ReportName", ReportName))
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0).Rows.Cast(Of DataRow).Select(Function(dr) dr(0).ToString).ToList
        Else
            Return Nothing
        End If
    End Function
    Public Function GetReportConsultants1(ByVal UserID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = ConsultantsQry1
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetReportConsultants2(ByVal UserID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = ConsultantsQry2
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetReportConsultantsList1(ByVal UserID As String) As List(Of String)
        Dim sql As String = ConsultantsQry1
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        cmd.CommandText = sql
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0).Rows.Cast(Of DataRow).Select(Function(dr) dr(0).ToString).ToList
        Else
            Return Nothing
        End If
    End Function
    Public Function GetReportConsultantsList2(ByVal UserID As String) As List(Of String)
        Dim sql As String = ConsultantsQry2
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        cmd.CommandText = sql
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0).Rows.Cast(Of DataRow).Select(Function(dr) dr(0).ToString).ToList
        Else
            Return Nothing
        End If
    End Function

    Public Function GetTotalProceduresPerformedQry(ByVal UserID As String) As DataTable
        Try

            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = TotalProceduresPerformedQry
            cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception

        End Try
    End Function

    Public Shared Function GetActivityQuery(searchStart As DateTime, searchEnd As DateTime, operatingHospitalIds As String, roomIds As String, hideSuppressedConsultants As Boolean, hideSuppressedEndoscopists As Boolean) As DataTable
        Try
            Dim dsData As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("report_SCH_Activity", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 180


                'New SqlParameter("@FromDate", Date.ParseExact(FromDate, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo))

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
        End Try
    End Function

    Public Shared Function GetCancellationQuery(operatingHospitalId As Integer, roomId As Integer) As DataTable
        Try
            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = CancellationQueryStringProperty
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - cancellation", ex)
        End Try
    End Function

    Public Shared Function GetDnaQuery(operatingHospitalId As Integer, roomId As Integer) As DataTable
        Try
            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = DNAQueryStringProperty
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - dna", ex)
        End Try
    End Function


    Public Shared Function GetPatientPathwayQuery(operatingHospitalId As Integer, roomId As Integer) As DataTable
        Try
            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = DailyPatientsPerRoomQueryStringProperty
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text

            cmd.CommandTimeout = 360
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - patient pathway", ex)
        End Try
    End Function

    Public Shared Function GetPatientStatusQuery(operatingHospitalId As Integer, roomId As Integer, hideSuppressedConsultants As Boolean, hideSuppressedEndoscopists As Boolean) As DataTable
        Try
            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = PatientStatusQueryStringProperty
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            cmd.Parameters.Add(New SqlParameter("@HideSuppressedConsultants", hideSuppressedConsultants))
            cmd.Parameters.Add(New SqlParameter("@HideSuppressedEndoscopists", hideSuppressedEndoscopists))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - patient status", ex)
        End Try
    End Function

    Public Shared Function GetAuditQuery(operatingHospitalId As Integer, roomId As Integer) As DataTable
        Try
            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = AuditQueryStringProperty
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading scheduler report - audit", ex)
        End Try
    End Function
    Public Function GetOGDQry(ByVal UserID As String) As DataTable
        Try

            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = OGDQry
            cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading JAG OGD report", ex)
        End Try
    End Function
    Public Function GetEUSQry(ByVal UserID As String) As DataTable
        Try

            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = EUSQry
            cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading JAG EUS report", ex)

        End Try
    End Function
    Public Function GetPEGQry(ByVal UserID As String) As DataTable
        Try

            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = PEGQry
            cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading JAG PEG report", ex)
            Return Nothing
        End Try
    End Function
    Public Function GetERCQry(ByVal UserID As String) As DataTable
        Try

            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = ERCQry
            cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading JAG ERCP report", ex)
            Return Nothing
        End Try
    End Function
    Public Function GetSIGQry(ByVal UserID As String) As DataTable
        Try

            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = SIGQry
            cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading JAG SIG report", ex)
            Return Nothing
        End Try
    End Function
    Public Function GetCOLQry(ByVal UserID As String) As DataTable
        Try
            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = COLQry
            cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.CommandTimeout = 360

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading JAG COL report", ex)
            Return Nothing
        End Try
    End Function
    Public Function GetBowelQry(ByVal UserID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = BowelQry
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        cmd.CommandTimeout = 360

        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetConsultantsQry(ByVal UserID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = ConsultantsQry
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    Public Function GetPEGProcsQry(ByVal UserID As String, ByVal rowID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = PEGProcs
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@rowID", rowID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetPEGPlaceQry(ByVal UserID As String, ByVal rowID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = PEGPlace
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@rowID", rowID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetOGDMeanQry(ByVal UserID As String, ByVal rowID As String, ByVal AgeLimit As String, ByVal Drug As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = OGDMean
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@rowID", rowID))
        cmd.Parameters.Add(New SqlParameter("@AgeLimit", AgeLimit))
        cmd.Parameters.Add(New SqlParameter("@Drug", Drug))
        ' And DrugName Like 
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetOGDCompQry(ByVal UserID As String, ByVal rowID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = OGDComp
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@rowID", rowID))
        ' And DrugName Like 
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetOGDComfQry(ByVal UserID As String, ByVal rowID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = OGDComf
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@rowID", rowID))
        ' And DrugName Like 
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    Public Function GetOGDRepeQry(ByVal UserID As String, ByVal rowID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = OGDRepe
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@rowID", rowID))
        ' And DrugName Like 
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetSqlDSAllConsultants(ByVal UserID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = ConsultantsQueryStr1
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))
        ' And DrugName Like 
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    Public Function GetSqlDSSelectedConsultants(ByVal UserID As String) As DataTable
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = ConsultantsQueryStr2
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))
        ' And DrugName Like 
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    'Public Function GetTotalScopesBookedQry(ByVal UserID As String) As DataTable
    '    Try
    '        Dim ds As New DataSet
    '        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand
    '        Dim sql As String = TotalScopesBookedQry
    '        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
    '        cmd.CommandText = sql
    '        cmd.Connection = connection
    '        cmd.CommandType = CommandType.Text
    '        cmd.CommandTimeout = 360
    '        Dim adapter = New SqlDataAdapter(cmd)
    '        connection.Open()
    '        adapter.Fill(ds)
    '        If ds.Tables.Count > 0 Then
    '            Return ds.Tables(0)
    '        Else
    '            Return Nothing
    '        End If

    '    Catch ex As Exception
    '        Return Nothing
    '    End Try
    'End Function

    Public Shared Function GetRoomsQry(ByVal hospitalId As Integer, ByVal roomId As Integer) As DataTable
        Try
            Dim ds As New DataSet
            Dim connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            Dim sql As String = TotalScopesBookedQry
            cmd.Parameters.Add(New SqlParameter("@hospitalId", hospitalId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading Activity report", ex)
            Return Nothing
        End Try

    End Function
#End Region
#Region "Charts"
    Private Shared _OGDDrugsChart As String = "Select D.DrugName, PM.Dose, D.DefaultDose, PM.Units, D.DeliveryMethod From 	fw_Premedication PM, fw_Drugs D, fw_Procedures PR, fw_ProceduresConsultants PC, fw_ReportConsultants RC Where PM.DrugId=D.DrugId And PR.ProcedureId=PM.ProcedureId And PR.ProcedureId=PC.ProcedureId And PC.ConsultantTypeId=1	And PC.ConsultantId=RC.ConsultantId And RC.UserId=1 And RC.AnonimizedID=1"
    Public Shared Property OGDDrugsChart As String
        Get
            Return _OGDDrugsChart
        End Get
        Set(value As String)
            _OGDDrugsChart = value
        End Set
    End Property

    Public Shared Property ActivityQueryStringProperty As String
        Get
            Return ActivityBookedQueryString
        End Get
        Set(value As String)
            ActivityBookedQueryString = value
        End Set
    End Property

    Public Shared Property ActivityBookedQueryString As String = "EXEC [dbo].[report_SCH_Activity] @OperatingHospitalID, @RoomId, @RoomId, @HideSuppressedConsultants, @HideSuppressedEndoscopists"

    Public Shared Property CancellationQueryStringProperty As String
        Get
            Return CancellationQueryString
        End Get
        Set(value As String)
            CancellationQueryString = value
        End Set
    End Property

    Public Shared Property CancellationQueryString As String = "EXEC [dbo].[report_SCH_Cancellation] @OperatingHospitalId, @RoomId"

    Public Shared Property DNAQueryStringProperty As String
        Get
            Return DNAQueryString
        End Get
        Set(value As String)
            DNAQueryString = value
        End Set
    End Property

    Public Shared Property DNAQueryString As String = "EXEC [dbo].[report_SCH_DNA] @OperatingHospitalId, @RoomId"


    Public Shared Property DailyPatientsPerRoomQueryStringProperty As String
        Get
            Return DailyPatientsPerRoomQueryString
        End Get
        Set(value As String)
            DailyPatientsPerRoomQueryString = value
        End Set
    End Property

    Public Shared Property DailyPatientsPerRoomQueryString As String = "EXEC [dbo].[report_SCH_PatientPathway] @OperatingHospitalId, @RoomId"

    Public Shared Property PatientStatusQueryStringProperty As String
        Get
            Return PatientStatusQueryString
        End Get
        Set(value As String)
            PatientStatusQueryString = value
        End Set
    End Property

    Public Shared Property PatientStatusQueryString As String = "EXEC [dbo].[report_SCH_PatientStatus] @OperatingHospitalId, @RoomId, @HideSuppressedConsultants, @HideSuppressedEndoscopists"

    Public Shared Property AuditQueryStringProperty As String
        Get
            Return AuditQueryString
        End Get
        Set(value As String)
            AuditQueryString = value
        End Set
    End Property

    Public Shared Property AuditQueryString As String = "EXEC [dbo].[report_SCH_Audit] @OperatingHospitalId, @RoomId"

    Public Shared Function GetOGDDrugs(ByVal UserID As String, ByVal rowID As String) As DataSet
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = OGDDrugsChart
        cmd.Parameters.Add(New SqlParameter("@UserID", UserID))
        cmd.Parameters.Add(New SqlParameter("@rowID", rowID))
        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If
    End Function

#End Region
#Region "Scheduler"
    Private Shared RoomsQueryStr As String = "SELECT DISTINCT RoomId, RoomName FROM ERS_SCH_Rooms WHERE RoomId=@RoomId ORDER BY RoomName"
#End Region

End Class


''############ All the Reports should have its own Class... Implementing a Common Interface 

''' <summary>
''' This will List the available Reports in ERS System.
''' </summary>
''' <remarks></remarks>
Public Class ERS_Report
    Public Shared ReadOnly GRS01_Diarrhoea As String = "sp_rep_GRSA01"
    Public Shared ReadOnly GRS02_Haemostasis As String = "sp_rep_GRSA02" ' "Exec sp_rep_GRSA02 @UserID=@UserID, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @OGD=@OGD, @COLSIG=@COLSIG"
    Public Shared ReadOnly GRS03_StendAndPegPej_Placement As String = "sp_rep_GRSA03" 'Exec sp_rep_GRSA03 @UserID=@UserID, @Endoscopist1=@Endoscopist1, @Endoscopist2=@Endoscopist2, @FromAge=@FromAge, @ToAge=@ToAge, @CountOfProcedures=@CountOfProcedures, @ListOfPatients=@ListOfPatients, @OesophagealStent=@OesophagealStent, @DuodenalStent=@DuodenalStent, @UnitAsAWhole=@UnitAsAWhole, @ColonicStent=@ColonicStent, @PEG=@PEG, @PEJ=@PEJ
End Class


Public Interface IReportObject
    'ReadOnly Property StoredProcName() As String 
    Function GetData() As DataTable

End Interface

''' <summary>
''' GRS01_Diarrhoea
''' </summary>
''' <remarks></remarks>
Public Class Report_GRS01 : Implements IReportObject

    Public StartDate As Date,
            EndDate As Date
    Dim _startDate As Date, _endDate As Date

    Sub New()
        _startDate = "1901-01-01" '## Just a fake default value!
        _endDate = "2099-01-01"   '## Just a fake default value!
    End Sub

    Sub New(ByVal DateFrom As Date, ByVal DateTo As Date)
        _startDate = DateFrom
        _endDate = DateTo
    End Sub

    Function GetData() As DataTable Implements IReportObject.GetData

        Dim dtReportData As New DataTable
        Dim paramList As SqlParameter() = Nothing

        Try
            Dim dateFromParam As New SqlParameter("@DateFrom", DbType.DateTime),
                dateToParam As New SqlParameter("@DateTo", DbType.DateTime)

            dateFromParam.Value = _startDate
            dateToParam.Value = _endDate

            Using da As New DataAccess
                dtReportData = da.ExecuteSP(ERS_Report.GRS01_Diarrhoea, New SqlParameter() {dateFromParam, dateToParam})
            End Using

            Return IIf((dtReportData.Rows.Count > 0), dtReportData, Nothing)
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

End Class

''' <summary>
''' GRS02_Haemostasis
''' </summary>
''' <remarks></remarks>
Public Class Report_GRS02 : Implements IReportObject

    Public Endoscopist1 As Integer,
            Endoscopist2 As Integer,
            OGD As Integer,
            COLSIG As Integer

    Sub New()
        Endoscopist1 = ""
        Endoscopist2 = ""
        OGD = ""
        COLSIG = ""
    End Sub

    Sub New(ByVal _endoscopist1 As Integer, ByVal _endoscopist2 As Integer, ByVal _oGD As Integer, ByVal _cOLSIG As Integer)
        Endoscopist1 = _endoscopist1
        Endoscopist2 = _endoscopist2
        OGD = _oGD
        COLSIG = _cOLSIG
    End Sub

    ''' <summary>
    ''' This will Load data from the StoredProc and return as a DataTable!
    ''' </summary>
    ''' <returns>System.Data.DataTable</returns>
    ''' <remarks></remarks>
    Function GetData() As DataTable Implements IReportObject.GetData

        Dim dtReportData As New DataTable
        'Dim paramList As SqlParameter() = Nothing

        Try
            'Dim paramEndoscopist1 As New SqlParameter("@Endoscopist1", DbType.String),
            '    paramEndoscopist2 As New SqlParameter("@Endoscopist2", DbType.String),
            '    paramOGD As New SqlParameter("@OGD", DbType.String),
            '    paramCOLSIG As New SqlParameter("@COLSIG", DbType.String)

            'paramEndoscopist1.Value = Endoscopist1
            'paramEndoscopist2.Value = Endoscopist2
            'paramOGD.Value = OGD
            'paramCOLSIG.Value = COLSIG

            'dtReportData = DataAccess.ExecuteSP(ERS_Report.GRS02_Haemostasis, New SqlParameter() {paramEndoscopist1, paramEndoscopist2, paramOGD, paramCOLSIG})
            Using da As New DataAccess
                dtReportData = da.ExecuteSP("sp_rep_GRSA02_v2", New SqlParameter() {New SqlParameter("@Endoscopist1", Endoscopist1),
                                                                                            New SqlParameter("@Endoscopist2", Endoscopist2),
                                                                                            New SqlParameter("@OGD", OGD),
                                                                                            New SqlParameter("@COLSIG", COLSIG),
                                                                                            New SqlParameter("@EndoscopistIdList", "@EndoscopistIdList")})
            End Using

            Return IIf((dtReportData.Rows.Count > 0), dtReportData, Nothing)
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

End Class


Public Class GetReportData
    Public Shared Function Result(ByVal ReportClass As IReportObject) As DataTable
        Return ReportClass.GetData()
    End Function
End Class

