Imports Microsoft.VisualBasic
Imports System.Data.SqlClient
Imports System.Net
Imports System.Net.Configuration
Imports System.Net.Mail
Imports DevExpress.ExpressApp.Web.SystemModule.CallbackHandlers
Imports ERS.Data
Imports System
Imports System.Data.Common
Imports System.Net.Http
Imports Hl7.Fhir.Serialization
Imports System.Xml
Imports System.IO
Imports Telerik.Web.Spreadsheet
Imports iTextSharp.text
Imports DevExpress.DataProcessing.InMemoryDataProcessor


Public Class DataAccess
    Inherits System.Web.Services.WebService
#Region "Connection Strings Properties"
    Private Shared _ConnectionDatabaseName As String

    Public ReadOnly Property LoggedInUserId As Integer
        Get
            Return CInt(HttpContext.Current.Session("PKUserID"))
        End Get
    End Property
    Public Shared Property ConnectionStr() As String
        Get
            Dim resultConnString As String = ""
            If Not IsNothing(_ConnectionDatabaseName) Then
                Using Securitee As New ERS.Security.Simple3Des("")
                    resultConnString = Securitee.ConnectionStrMainDB(ConfigurationManager.ConnectionStrings(_ConnectionDatabaseName).ConnectionString, ConfigurationManager.AppSettings("EncryptedPassword") = "true")
                End Using
            Else
                HttpContext.Current.Response.Redirect("~/Security/Logout.aspx", False)
                Return Nothing
            End If

            Return resultConnString

        End Get
        Set(value As String)
            _ConnectionDatabaseName = value
        End Set
    End Property

    Public Function GetDBInfo() As DataRow  ' issue 4426
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * from dbo.fnGetDBInfo()", connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables(0).Rows.Count > 0 Then
            Return dsResult.Tables(0).Rows(0)
        End If
        Return Nothing
    End Function
    Public Sub addSiteBiopsy(siteId As Integer, biopsySiteId As String, distance As Double?, bxQty As Double?)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("site_specimens_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.Parameters.Add(New SqlParameter("@BiopsySiteId", biopsySiteId))
                cmd.Parameters.Add(New SqlParameter("@Distance", distance))
                cmd.Parameters.Add(New SqlParameter("@Qty", bxQty))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function checkNEDFailedExportCount() As Integer
        Try

            Using connection As New SqlConnection(ConnectionStr)
                Dim value As Object
                Dim cmd As New SqlCommand("usp_NEDI2_Check_Export_Result", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@UserId", LoggedInUserId))

                connection.Open()
                value = cmd.ExecuteScalar()
                If Not IsDBNull(value) Then Return CInt(value)
                Return 0
            End Using

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub updateSiteBiopsy(siteSpecimenId As Integer, biopsySiteId As String, distance As Double?, bxQty As Double?)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("site_specimens_update", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteSpecimenId", siteSpecimenId))
                cmd.Parameters.Add(New SqlParameter("@BiopsySiteId", biopsySiteId))
                cmd.Parameters.Add(New SqlParameter("@Distance", distance))
                cmd.Parameters.Add(New SqlParameter("@Qty", bxQty))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub deleteSiteBiopsy(siteSpecimenId As Integer, procedureId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("site_specimens_delete", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteSpecimenId", siteSpecimenId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function LoadSitesBiopsies(SiteId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("site_specimens_select", connection)
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@SiteId", .SqlDbType = SqlDbType.Int, .Value = SiteId})

            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function LoadBiopsySites() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("biopsy_sites_select", connection)
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureTypeId", .SqlDbType = SqlDbType.Int, .Value = Session(Constants.SESSION_PROCEDURE_TYPE)})

            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScopeManufacturers() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("scope_manufacturer_select", connection)

            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScopeManufacturerGeneration(manufacturerId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("scope_generation_select", connection)
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ManufacturerId", .SqlDbType = SqlDbType.Int, .Value = manufacturerId})

            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function
    Friend Function getPreviousProcedurePDF(previousProcedureId As Integer) As Byte()
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT PDFBinary FROM ERS_PreviousProcedures WHERE PreviousProcedureId = @PreviousProcedureId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@PreviousProcedureId", previousProcedureId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using

    End Function

    Friend Function getStentInsertionDetails(iTherapeuticId As String) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_ERCPTherapeuticStentInsertions WHERE TherapeuticId = @TherapeuticId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@TherapeuticId", iTherapeuticId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Sub updateDiagnosesSummary(procedureId As Integer)
        Try
            Try
                Using connection As New SqlConnection(ConnectionStr)
                    Dim cmd As New SqlCommand("ogd_diagnoses_summary_update", connection)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                    cmd.Connection.Open()
                    cmd.ExecuteNonQuery()
                End Using
            Catch ex As Exception
                Throw ex
            End Try
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("There was an error updating the diagnoses summary", ex)
        End Try
    End Sub

    Friend Function addNewScopeGeneration(ScopeManufacturerId As String, ScopeGenerationName As String) As Integer
        Try

            If Trim(ScopeGenerationName) = "" Then Return 0


            Using connection As New SqlConnection(ConnectionStr)
                Dim value As Object
                Dim cmd As New SqlCommand("scope_generation_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ScopeManufacturerId", ScopeManufacturerId))
                cmd.Parameters.Add(New SqlParameter("@ScopeGenerationName", ScopeGenerationName))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                value = cmd.ExecuteScalar()
                If Not IsDBNull(value) Then Return CInt(value)
                Return 0
            End Using

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub UpdateDistalAttachment(DistalAttachmentId As String, DistalAttachmentName As String, ProcedureId As Integer)
        Try
            If DistalAttachmentId = -99 Then
                Dim da As New DataAccess
                Dim newId = da.InsertListItem("Distal attachment", DistalAttachmentName)
                If newId > 0 Then
                    DistalAttachmentId = newId
                End If
            End If

            Using db As New ERS.Data.GastroDbEntities
                Dim procedure = db.ERS_Procedures.Where(Function(x) x.ProcedureId = ProcedureId).FirstOrDefault
                procedure.DistalAttachmentId = DistalAttachmentId
                db.ERS_Procedures.Attach(procedure)
                db.Entry(procedure).State = Entity.EntityState.Modified
                db.SaveChanges()
                Update_Procedure(ProcedureId)
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub


    Friend Sub saveProcedureInstruments(procedureId As Integer, instrument1 As Integer, instrument2 As Integer, distalAttachmentId As Integer, scopeGuideUsed As Boolean?, techniqueUsed As String, techniqueUsedIdx As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_instruments_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@Instrument1Id", instrument1))
                cmd.Parameters.Add(New SqlParameter("@Instrument2Id", instrument2))
                If scopeGuideUsed.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@ScopeGuideUsed", scopeGuideUsed))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ScopeGuideUsed", DBNull.Value))
                End If
                If techniqueUsed <> "" Then
                    cmd.Parameters.Add(New SqlParameter("@TecniqueUsed", techniqueUsed))
                Else
                    cmd.Parameters.Add(New SqlParameter("@TecniqueUsed", DBNull.Value))
                End If

                If techniqueUsedIdx <> "" Then
                    cmd.Parameters.Add(New SqlParameter("@TecniqueUsedIdx", techniqueUsedIdx))
                Else
                    cmd.Parameters.Add(New SqlParameter("@TecniqueUsedIdx", DBNull.Value))
                End If
                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub


    Friend Function saveScope(scopeId As Integer, ScopeName As String, OperatingHospitalIdList As String, ScopeGenerationId As Integer, AllProcedures As Boolean) As Integer
        Try
            Dim newId = 0

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("scope_save", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@scopeId", scopeId))
                cmd.Parameters.Add(New SqlParameter("@ScopeName", ScopeName))
                cmd.Parameters.Add(New SqlParameter("@AllProcedures", AllProcedures))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalIdList", OperatingHospitalIdList))
                cmd.Parameters.Add(New SqlParameter("@ScopeGenerationId", ScopeGenerationId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                newId = cmd.ExecuteScalar()
            End Using

            Return newId
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function updateScope(scopeId As Integer, ScopeGenerationId As Integer) As Boolean
        Try
            Dim rowsAffected As Integer = 0

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("UPDATE ERS_Scopes SET  ScopeGenerationId = @ScopeGenerationId, WhenUpdated = @WhenUpdated,WhoUpdatedId = @WhoUpdatedId  WHERE scopeId = @scopeId", connection)
                cmd.Parameters.Add(New SqlParameter("@scopeId", scopeId))
                cmd.Parameters.Add(New SqlParameter("@WhenUpdated", DateTime.Now))
                cmd.Parameters.Add(New SqlParameter("@ScopeGenerationId", ScopeGenerationId))
                cmd.Parameters.Add(New SqlParameter("@WhoUpdatedId", LoggedInUserId))
                connection.Open()
                rowsAffected = cmd.ExecuteNonQuery()
            End Using

            If rowsAffected > 0 Then
                Return True
            Else
                Return False
            End If

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function AddNonGIProcedureType(procedureTypeName As String, operatingHospitalId As Integer) As Integer
        Try
            Dim newId = 0

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("add_non_gi_procedure_type", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@procedureTypeName", procedureTypeName))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

                connection.Open()
                newId = cmd.ExecuteScalar()
            End Using

            Return newId
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Public Function savePathwayPlanQuestions(question As String, isOptional As Boolean, freeText As Boolean, mandatory As Boolean, procedureType As Integer, operatingHospitalId As Integer, Optional questionId As Integer? = Nothing, Optional suppressed As Boolean? = Nothing) As Integer
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("pathway_plan_questions_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@Question", question))
                cmd.Parameters.Add(New SqlParameter("@Optional", isOptional))
                cmd.Parameters.Add(New SqlParameter("@FreeText", freeText))
                cmd.Parameters.Add(New SqlParameter("@Mandatory", mandatory))
                cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
                If questionId.HasValue AndAlso questionId.Value > 0 Then
                    cmd.Parameters.Add(New SqlParameter("@QuestionId", questionId.Value))
                End If

                If suppressed.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Suppressed", suppressed.Value))
                End If

                cmd.Connection.Open()
                Return Convert.ToInt32(cmd.ExecuteNonQuery())
            End Using
        Catch ex As Exception
            Throw ex
            Return Nothing
        End Try
    End Function


    Public Function suppressPathwayPlanQuestions(questionId As Integer, suppressed As Boolean, operatingHospital As Integer) As Integer
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("pathway_plan_questions_suppress", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@QuestionId", questionId))
                cmd.Parameters.Add(New SqlParameter("@Suppress", suppressed))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospital))

                cmd.Connection.Open()
                Return Convert.ToInt32(cmd.ExecuteNonQuery())
            End Using
        Catch ex As Exception
            Throw ex
            Return Nothing
        End Try
    End Function


    Public Sub reorderPathwayPlanQuestions(questionId As Integer, direction As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("pathway_plan_questions_reorder", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@QuestionId", questionId))
                cmd.Parameters.Add(New SqlParameter("@Direction", direction))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetPathwayPlanQuestions(operatingHospital As Integer, procType As Integer, Optional suppressed As Boolean? = Nothing) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("pathway_plan_questions_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospital))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", procType))

            If suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Suppressed", suppressed))
            End If

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function


    Public Function GetPathwayPlanQuestion(questionId As Integer, operatingHospital As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("pathway_plan_question_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@QuestionId", questionId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospital))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function NonGIGMCCodeExists(GMCCode As String, userId As Integer) As Boolean
        Try
            Dim sql As String = "SELECT 1 FROM ERS_NonGIConsultants WHERE ISNULL(GMCCode,'') = @GMCCode AND (UserId <> @UserId)"
            Dim idObj As Object

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@GMCCode", GMCCode))
                cmd.Parameters.Add(New SqlParameter("@UserId", userId))

                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CBool(idObj)
                End If
            End Using
            Return False
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function NonGIUserExists(forename As String, surname As String, GMCCode As String) As Boolean
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("SELECT CASE WHEN COUNT(*) >1 THEN 1 ELSE 0 END FROM ERS_NonGIConsultants WHERE forename = @forename AND Surname = @surname AND GMCCode = @surname", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@forename", forename))
                cmd.Parameters.Add(New SqlParameter("@surname", surname))
                cmd.Parameters.Add(New SqlParameter("@gmccode", GMCCode))
                connection.Open()
                Return CBool(cmd.ExecuteScalar())
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    'AS (08/Sep/21) - updated for Bronchs
    Friend Function GetProcedureSpecimenCount(procedureId As Integer) As Integer
        Try
            Dim sql As String =
                    "SELECT SUM(a) FROM (SELECT COUNT(*) AS a FROM dbo.ERS_UpperGISpecimens eug INNER JOIN dbo.ERS_Sites es ON eug.SiteId = es.SiteId WHERE es.ProcedureId = @ProcedureId UNION SELECT COUNT(*) AS a FROM dbo.ERS_BRTSpecimens ebt INNER JOIN dbo.ERS_Sites es ON ebt.SiteId = es.SiteId WHERE es.ProcedureId = @ProcedureId UNION SELECT COUNT(*) AS a FROM dbo.ERS_CystoscopySpecimens ebt INNER JOIN dbo.ERS_Sites es ON ebt.SiteId = es.SiteId WHERE es.ProcedureId = @ProcedureId ) result"
            Dim idObj As Object

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CInt(idObj)
                End If
            End Using
            Return 0
        Catch ex As Exception
            Return 0
        End Try
    End Function
    'Mahfuz wrote on 21 Apr 2021 to use in ScotHospitalWSXmlWritrer (PAS system)
    Friend Function GetProcedureSiteSpecimens(procedureId As Integer) As DataTable
        Try
            ' Dim sql As String = "Select s.SiteNo,sp.Summary as SpecimenSummary From ERS_UpperGISpecimens sp inner join ERS_Sites s on sp.SiteId=s.SiteId Where ProcedureId= @ProcedureId Order by s.SiteNo asc"
            Dim sql As String = "Select  s.SiteNo, sp.Summary As SpecimenSummary From ERS_UpperGISpecimens sp inner join ERS_Sites s On sp.SiteId=s.SiteId Where ProcedureId= @ProcedureId  union Select s.SiteNo, sp.Summary as SpecimenSummary From ERS_BRTSpecimens sp inner join ERS_Sites s on sp.SiteId=s.SiteId Where ProcedureId= @ProcedureId union Select s.SiteNo, sp.Summary as SpecimenSummary From ERS_CystoscopySpecimens sp inner join ERS_Sites s on sp.SiteId=s.SiteId Where ProcedureId= @ProcedureId Order by SiteNo asc"

            Dim dtData As DataTable = New DataTable

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                Dim da As SqlDataAdapter

                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                da = New SqlDataAdapter(cmd)
                connection.Open()
                da.Fill(dtData)
                Return dtData
            End Using
            Return dtData
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error logging: occurred in GetProcedureSiteSpecimens", ex)
        End Try
    End Function
    'Mahfuz wrote on 21 Apr 2021 to use in ScotHospitalWSXmlWritrer (PAS system)
    Friend Function GetProcedureSiteImagesAndDocumentsStoreData(procedureId As Integer) As DataTable
        Try
            Dim sql As String = "uspGetProcedureSiteImagesAndDocumentsStoreData"

            Dim dtData As DataTable = New DataTable

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                Dim da As SqlDataAdapter

                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                da = New SqlDataAdapter(cmd)
                connection.Open()
                da.Fill(dtData)

                Return dtData
            End Using
            Return dtData
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error logging: occured in GetProcedureSiteSpecimens", ex)
        End Try
    End Function

    Friend Function GetHasProcedureFNA(procedureId As Integer) As Boolean
        Try
            Dim idObj As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("PathResultsDisplayFNA", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CBool(idObj)
                Else
                    Return False
                End If

            End Using
        Catch ex As Exception
            Return False
        End Try
    End Function

    Friend Function GetSiteRegionDetails(procTypeId As Integer, siteId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("usp_get_site_region_details", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procTypeId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function GetUserOperatingHospitals(editUserId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT OperatingHospitalId FROM ERS_UserOperatingHospitals WHERE UserId = @UserId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", editUserId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Sub UpdateIsActive(imagePortId As Integer, status As Boolean)
        Dim sql = "UPDATE ERS_ImagePort SET IsActive = @Active, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE ImagePortId = @ImagePortId"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@Active", status))
            cmd.Parameters.Add(New SqlParameter("@ImagePortId", imagePortId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Sub cancelWorklistPatient(worklistId As Integer)
        Dim sql = "UPDATE ERS_Appointments SET AppointmentStatusId = (SELECT [UniqueId] FROM ERS_AppointmentStatus WHERE HDCKey = 'C') WHERE AppointmentId = @AppointmentId"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", worklistId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Function UserNameExists(userName As String) As Integer
        Dim sql As String = "SELECT TOP 1 UserID FROM dbo.ERS_Users WHERE Username=@Username"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserName", userName))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return idObj
            End If
        End Using
        Return 0
    End Function

    Friend Sub AddNewReferringHospital(hospitalName As String)
        Dim sql = "INSERT INTO ERS_ReferralHospitals (HospitalName, TrustId) VALUES (@HospitalName, @TrustId)"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@HospitalName", hospitalName))
            cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Sub UpdateReferringHospital(hospitalId As Integer, hospitalName As String)
        Dim sql = "UPDATE ERS_ReferralHospitals SET HospitalName = @HospitalName, TrustId = @TrustId WHERE HospitalId = @HospitalId"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@HospitalName", hospitalName))
            cmd.Parameters.Add(New SqlParameter("@HospitalId", hospitalId))
            cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Sub UpdateUsersOperatingHospitals(userId As Integer, operatingHospitalIds As String)
        Dim sql As String = "DELETE FROM ERS_UserOperatingHospitals WHERE UserId = @UserId; 
                                INSERT INTO ERS_UserOperatingHospitals (UserId, OperatingHospitalId) VALUES "

        For Each oh In operatingHospitalIds.Split(",")
            sql += " (@userId, " & oh & "), "
        Next

        sql = TransactionSQL(sql.Remove(sql.ToString().Length - 2))

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalIds))

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Function SpecialtyExists(newGroupName As String, newGroupCode As String) As Boolean
        Dim sql As String = "SELECT CASE WHEN GroupID IS NULL THEN 0 ELSE 1 END FROM ERS_ConsultantGroup WHERE GroupName = @GroupName OR Code = @GroupCode"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@GroupName", newGroupName))
            cmd.Parameters.Add(New SqlParameter("@GroupCode", newGroupCode))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            Else
                Return False
            End If
        End Using
    End Function

    Friend Sub logProcedureEnd(procedureId As Integer)
        Try
            Using db As New GastroDbEntities
                'get patient journey details
                Dim tblPatientJourney = db.ERS_PatientJourney.Where(Function(x) x.ProcedureId = procedureId).FirstOrDefault
                If tblPatientJourney IsNot Nothing Then
                    ' Only update if the procedure has an end date specified
                    If IsNothing(tblPatientJourney.ProcedureEndTime) Then
                        If tblPatientJourney.AppointmentId IsNot Nothing Then
                            Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = tblPatientJourney.AppointmentId).FirstOrDefault
                            Dim appointmentProceduresCount = db.ERS_AppointmentProcedureTypes.Count(Function(x) x.AppointmentID = tblPatientJourney.AppointmentId)


                            ''check for DNA status and only update if procedure is not DNA
                            Dim dtDNA = ProcedureDNA(procedureId)
                            If dtDNA Is Nothing OrElse dtDNA.Rows.Count = 0 Then
                                'check if a solo procedure or if all are in the patient journey table with end dates. if so update status to PC
                                If appointmentProceduresCount = 1 Or db.ERS_PatientJourney.Count(Function(x) x.AppointmentId = tblPatientJourney.AppointmentId And x.ProcedureEndTime.HasValue) = appointmentProceduresCount Then
                                    appointment.AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY = "RC").FirstOrDefault.UniqueId
                                    db.ERS_Appointments.Attach(appointment)
                                    db.Entry(appointment).State = Entity.EntityState.Modified
                                End If
                            End If
                        End If

                        db.SaveChanges()
                    End If
                End If
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error logging procedure end", ex)
        End Try
    End Sub

    Friend Function GMCCodeExists(GMCCode As String, userId As Integer) As Boolean
        Dim sql As String = "SELECT 1 
                             FROM ERS_Users u, ERS_UserOperatingHospitals uoh, ERS_OperatingHospitals h 
                             WHERE u.UserID = uoh.UserId
                             AND uoh.OperatingHospitalId = h.OperatingHospitalId
                             AND ISNULL(GMCCode,'') = @GMCCode 
                             AND h.TrustID = @TrustId
                             AND u.UserId <> @UserId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@GMCCode", GMCCode))
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Friend Function ConsultantGMCCodeExists(GMCCode As String, ConsultantId As Integer) As Boolean
        Dim sql As String = "SELECT 1 FROM ERS_Consultant WHERE ISNULL(GMCCode,'') = @GMCCode AND ConsultantId <> @ConsultantId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@GMCCode", GMCCode))
            cmd.Parameters.Add(New SqlParameter("@ConsultantId", ConsultantId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Friend Function getPatientPathwayTimes(appointmentId As Integer) As DataTable
        Dim sb As StringBuilder = New StringBuilder()
        sb.Append("SELECT top (1) * from (Select ")
        sb.Append("PatientAdmissionTime, PatientDischargeTime FROM ERS_PatientJourney WHERE AppointmentId = @AppointmentId ")
        sb.Append("union select null, null) a ")
        sb.Append("order by PatientAdmissionTime desc, PatientDischargeTime desc ")
        'Dim sql As String = "SELECT PatientAdmissionTime, PatientDischargeTime FROM ERS_PatientJourney WHERE AppointmentId = @AppointmentId"
        Dim dsData As New DataSet


        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sb.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", appointmentId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function IsPEGProcedure(procedureId As Integer) As Boolean
        Try
            Dim idObj As Boolean

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("SELECT dbo.IsPEGProcedure(@ProcedureId)", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                connection.Open()
                Return CBool(cmd.ExecuteScalar())
            End Using

            Return idObj
        Catch ex As Exception
            Throw ex
        End Try
        Return False
    End Function

    Friend Function IsEUSSuccessful(procedureId As Integer) As Boolean
        Try
            Dim idObj As Boolean

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("get_eus_success", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                connection.Open()
                Return CBool(cmd.ExecuteScalar())
            End Using

            Return idObj
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("", ex)
        End Try
        Return False
    End Function

    Friend Sub AddPatientToWorklist(patientId As Integer, procedureDate As DateTime, endoscopist As Integer, procedureTypeId As String, operatingHospitalId As Integer, timeOfDay As String, RoomID As Integer)
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("add_to_worklist", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
            cmd.Parameters.Add(New SqlParameter("@StartDateTime", procedureDate))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@TimeOfDay", timeOfDay))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            If endoscopist > 0 Then
                cmd.Parameters.Add(New SqlParameter("@Endoscopist", endoscopist))
            Else
                cmd.Parameters.Add(New SqlParameter("@Endoscopist", DBNull.Value))
            End If
            If String.IsNullOrEmpty(procedureTypeId) Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", procedureTypeId))
            End If
            cmd.Parameters.Add(New SqlParameter("@RoomID", RoomID))
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Function AddNewOperatingHospital(
                                            ByVal id As Integer,
                                            ByVal reportHeading As String,
                                            ByVal reportSubHeading As String,
                                            ByVal reportFooter As String,
                                            ByVal reportTrustType As String,
                                            ByVal departmentName As String,
                                            ByVal TrustId As Integer,
                                            ByVal hospitalName As String,
                                            ByVal contactNumber As String,
                                            ByVal internalHospitalId As String,
                                            ByVal nhsHospitalId As String,
                                            ByVal pdfExportPath As String,
                                            ByVal NEDODSCode As String,
                                            ByVal NEDExportPath As String,
                                            ByVal copyPrintSettings As Boolean,
                                            ByVal copyPhraseLibrary As Boolean,
                                            ByVal ImportPatientByWebservice As Integer,
                                            ByVal blnAddExportFileForMirth As Boolean,
                                            ByVal blnSuppressMainReportPDF As Boolean,
                                            ByVal ExportDocumentFilePrefix As String,
                                            Optional ByVal TrustName As String = "") As Integer

        Dim newId = 0

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("add_new_operating_hospital", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ExistingHospitalID", id))
            cmd.Parameters.Add(New SqlParameter("@InternalHospitalID", internalHospitalId))
            cmd.Parameters.Add(New SqlParameter("@NHSHospitalID", nhsHospitalId))
            cmd.Parameters.Add(New SqlParameter("@TrustId", TrustId))
            cmd.Parameters.Add(New SqlParameter("@HospitalName", hospitalName))
            cmd.Parameters.Add(New SqlParameter("@ContactNumber", contactNumber))
            cmd.Parameters.Add(New SqlParameter("@ReportExportPath", pdfExportPath))
            cmd.Parameters.Add(New SqlParameter("@ReportHeading", reportHeading))
            cmd.Parameters.Add(New SqlParameter("@ReportTrustType", reportTrustType))
            cmd.Parameters.Add(New SqlParameter("@ReportSubHeading", reportSubHeading))
            cmd.Parameters.Add(New SqlParameter("@ReportFooter", reportFooter))
            cmd.Parameters.Add(New SqlParameter("@DepartmentName", departmentName))
            cmd.Parameters.Add(New SqlParameter("@NEDExportPath", NEDExportPath))
            cmd.Parameters.Add(New SqlParameter("@NEDODSCode", NEDODSCode))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@CopyPrintSettings", copyPrintSettings))
            cmd.Parameters.Add(New SqlParameter("@CopyPhraseLibrary", copyPhraseLibrary))
            cmd.Parameters.Add(New SqlParameter("@ImportPatientByWebservice", ImportPatientByWebservice))
            cmd.Parameters.Add(New SqlParameter("@AddExportFileForMirth", blnAddExportFileForMirth))
            cmd.Parameters.Add(New SqlParameter("@SuppressMainReportPDF", blnSuppressMainReportPDF))
            cmd.Parameters.Add(New SqlParameter("@ExportDocumentFilePrefix", ExportDocumentFilePrefix)) 'MH added on 05 Jan 2022

            If Not String.IsNullOrWhiteSpace(TrustName) Then
                cmd.Parameters.Add(New SqlParameter("@TrustName", TrustName))

            End If

            connection.Open()
            newId = cmd.ExecuteScalar()
        End Using

        Return newId
    End Function

    Public Sub setEUSSuccess(EUSSuccessful As Boolean)
        Try
            Dim sql As String = "set_eus_success"
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sql.ToString(), connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))))
                cmd.Parameters.Add(New SqlParameter("@EUSSuccessful", EUSSuccessful))
                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Shared Function ProcedureDNA(procedureId As Integer) As DataTable
        Dim dsData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_dna_status", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetWorklistRecord(AppointementId As Integer, operatingHospitalId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_worklist_patient", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", AppointementId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetWorklistPatient(Optional PatientId As Integer = 0, Optional OperatingHospitalId As Integer = 0) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_worklist_patient", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", DBNull.Value))
            cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Shared ReadOnly Property ConnectionStrPASData() As String
        Get
            Using Securitee As New ERS.Security.Simple3Des("")
                Return Securitee.ConnectionStringBuilder(ConfigurationManager.ConnectionStrings("PASData").ConnectionString)
            End Using
        End Get
    End Property

    Friend Function GetPatientByCNN(cnn As String) As DataTable
        Dim dsData As New DataSet
        Dim sql As String = "SELECT * FROM ERS_Patients WHERE HospitalNumber = @CNN"
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.Parameters.Add(New SqlParameter("@CNN", cnn))

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
#End Region

#Region "Base Methods"
    <Obsolete("This method is deprecated, use [DataAccess.ExecuteScalerSQL(ScalerExecuteSQL)] instead.")>
    Private Function GetData(ByVal sqlQuery As String) As DataTable
        Dim dsData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
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

    <Obsolete("This method is deprecated, use [DataAccess.ExecuteSP(StoredProcName, paramList)] instead.")>
    Private Function GetData(ByVal sqlQuery As String, sqlType As CommandType) As DataTable
        Dim dsData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sqlQuery, connection)
            cmd.CommandType = sqlType
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetAbnormalities(siteId As Integer, tableName As String) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM " + tableName + " WHERE SiteId = @SiteId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function GetPatientReportInfo(ProcedureId As Integer) As DataSet
        Try
            Dim ds As DataSet = New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("Get_PatientReport_Info", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
                cmd.Parameters.Add(New SqlParameter("OperatingHospitalId", CInt(Session("OperatingHospitalId"))))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)
                Return ds
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in DataAccess-->GetPatientReportInfo", ex)
            Return Nothing
        End Try
    End Function
    Public Function GetAllTemporal() As DataTable
        Return ExecuteSP("get_all_temporal_data", New SqlParameter() {New SqlParameter("@Calltype", "get_temporal_tbl_list")})
    End Function
    Public Function GetHistoryData(historytbl As String, fromDate As String, toDate As String) As DataTable
        Return ExecuteSP("get_all_temporal_data", New SqlParameter() {
                         New SqlParameter("@Calltype", "get_history_data"),
                         New SqlParameter("@Desc1", historytbl),
                         New SqlParameter("@Desc2", fromDate),
                         New SqlParameter("@Desc3", toDate)
                         })
    End Function
    Public Function Get_ERS_ReportingSections() As DataTable
        Return ExecuteSP("custom_reporting", New SqlParameter() {New SqlParameter("@Calltype", "GET_ERS_ReportingSections")})
    End Function
    Public Function Get_ERS_Reporting(id As String) As DataTable
        Return ExecuteSP("custom_reporting", New SqlParameter() {
                         New SqlParameter("@Calltype", "GET_ERS_REPORTING"),
                         New SqlParameter("@Desc1", id)
                         })
    End Function
    Public Function Get_Procedure_Parameters(procedureName As String) As DataTable
        Return ExecuteSP("custom_reporting", New SqlParameter() {
                         New SqlParameter("@Calltype", "GET_PROCEDURE_PARAMETERS"),
                         New SqlParameter("@Desc1", procedureName)
                         })
    End Function

    Public Function Get_Custom_Report(procedureName As String, dct As Dictionary(Of String, String)) As DataTable
        Dim sqlPram As New List(Of SqlParameter)()
        For Each item As KeyValuePair(Of String, String) In dct
            sqlPram.Add(New SqlParameter(item.Key, item.Value))
        Next
        Return ExecuteSP(procedureName, sqlPram.ToArray())
    End Function

    Public Function ProcedureAmended(procedureId As Integer) As Boolean
        Dim sql As String = "SELECT ISNULL(ReportUpdated,0) FROM ERS_Procedures WHERE ProcedureId = @ProcedureId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function
    'MH created new function on 02 Nov 2021 for TFS 1729
    Public Function CanProcedureTypeExportDocument(procedureId As Integer) As Boolean
        Dim sql As String = "Select IsNull(CanExportDocument,0) as CanExportDocument from ERS_Procedures pr inner join ERS_ProcedureTypes pt on pr.ProcedureType = pt.ProcedureTypeId Where pr.ProcedureId = @ProcedureId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Public Function logProcedureChanged(procedureId As Integer) As Boolean
        Dim sql As String = "UPDATE ERS_Procedures SET NEDExported = 0 WHERE ProcedureId = @ProcedureId ; Exec Procedure_Updated @ProcedureId ; "
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Public Function ResetProcedureAmended(procedureId As Integer) As Boolean
        Dim sql As String = "UPDATE ERS_Procedures SET ReportUpdated = 0 WHERE ProcedureId = @ProcedureId ; Exec Procedure_Updated @ProcedureId ; "
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function
#End Region

#Region "Generic Methods"
    Public Function IsSystemDisabled(ByVal operatingHospitalId As Integer) As Boolean
        Dim sql As String = "SELECT SystemDisabled FROM ERS_SystemConfig WHERE OperatingHospitalID = @OperatingHospitalID"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", operatingHospitalId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function


    Friend Function GetProviderOrganisations() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("provider_organisation_select", connection)
            cmd.CommandType = CommandType.StoredProcedure

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function


    Friend Function GetReferralOptions(Suppressed As Boolean?) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("common_referral_types_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            If Suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = Suppressed})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = DBNull.Value})
            End If
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetSurgicalSafetyCheckListCompleted() As Boolean
        Dim sql As String = "SELECT TOP(1) ISNULL(CompleteWHOSurgicalSafetyCheckList,0) AS CompleteWHOSurgicalSafetyCheckList FROM ERS_SystemConfig"
        Dim idObj As Object
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Public Sub InsertDummyText(ByVal patientNo As String, ByVal episodeNo As Integer,
                               ByVal tableName As String, ByVal fieldName As String, ByVal dummyText As String,
                               ByVal procedureId As Integer, ByVal recordIdentifier As String)

        Dim sql As New StringBuilder
        sql.Append(String.Format("UPDATE [{0}] ", tableName))
        sql.Append(String.Format("SET [{0}] = @DummyText ", fieldName))
        sql.Append("WHERE PatientNo = @PatientNo ")
        sql.Append("AND EpisodeNo = @EpisodeNo ")
        sql.Append("INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId],[Identifier],[RecordCount]) ")
        sql.Append("VALUES (@ProcedureId, NULL, @Identifier, 1) ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DummyText", dummyText))
            cmd.Parameters.Add(New SqlParameter("@PatientNo", patientNo))
            cmd.Parameters.Add(New SqlParameter("@EpisodeNo", episodeNo))
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@Identifier", recordIdentifier))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub
    Public Sub SaveAuditLog_X(
                               Category As Nullable(Of Integer),
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
                                PatientNo As String,
                               EpisodeNo As Nullable(Of Integer),
                                CaseNoteNo As String,
                               ProcedureID As Nullable(Of Integer),
                                ProcedureDate As Nullable(Of DateTime),
                                ProcedureName As String,
                            EventDescription As String,
                            DatabaseName As String)
        Dim sql As String = "INSERT INTO [ERS_AuditLog] (Category,EventType,ApplicationID,AppVersion,UserID,FullUsername,StationID,HospitalID,HospitalName,OperatingHospitalID,OperatingHospitalName,PatientNo,EpisodeNo,CaseNoteNo,ProcedureID,ProcedureDate,ProcedureName,EventDescription,DatabaseName) " &
                            "VALUES (@Category,@EventType,@ApplicationID,@AppVersion,@UserID,@FullUsername,@StationID,@HospitalID,@HospitalName,@OperatingHospitalID,@OperatingHospitalName,@PatientNo,@EpisodeNo,@CaseNoteNo,@ProcedureID,@ProcedureDate,@ProcedureName,@EventDescription,@DatabaseName) "
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            If Category.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Category", Category))
            Else
                cmd.Parameters.Add(New SqlParameter("@Category", SqlTypes.SqlInt32.Null))
            End If
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
            If Not String.IsNullOrEmpty(PatientNo) Then
                cmd.Parameters.Add(New SqlParameter("@PatientNo", PatientNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@PatientNo", SqlTypes.SqlString.Null))
            End If

            If EpisodeNo.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@EpisodeNo", EpisodeNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@EpisodeNo", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(CaseNoteNo) Then
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", CaseNoteNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", SqlTypes.SqlString.Null))
            End If

            If ProcedureID.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureID", SqlTypes.SqlInt32.Null))
            End If
            If ProcedureDate.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureDate", ProcedureDate))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureDate", SqlTypes.SqlDateTime.Null))
            End If

            If Not String.IsNullOrEmpty(ProcedureName) Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureName", ProcedureName))
            Else
                cmd.Parameters.Add(New SqlParameter("@ProcedureName", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(EventDescription) Then
                cmd.Parameters.Add(New SqlParameter("@EventDescription", EventDescription))
            Else
                cmd.Parameters.Add(New SqlParameter("@EventDescription", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DatabaseName) Then
                cmd.Parameters.Add(New SqlParameter("@DatabaseName", DatabaseName))
            Else
                cmd.Parameters.Add(New SqlParameter("@DatabaseName", SqlTypes.SqlString.Null))
            End If
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Function GetAvailableImagePorts(OperatingHospitalId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim SQL = "SELECT * FROM ERS_ImagePort WHERE OperatingHospitalId = @OperatingHospitalId AND ISNULL(PCName, '') = '' AND IsActive = 1 ORDER BY PortName"

            Dim cmd As New SqlCommand(SQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetAvailableImagePortsForRoom(RoomId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)

            Dim cmd As New SqlCommand("Get_ImageportsForRoom", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@RoomId", RoomId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetPCImagePortID() As Integer
        Try
            Dim ImgPortID As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("SELECT Top 1 ImagePortId FROM ERS_ImagePort WHERE IsActive=1 AND RoomID=@RoomId AND OperatingHospitalId=@OpHospital", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@RoomId", Session("RoomId").ToString()))
                cmd.Parameters.Add(New SqlParameter("@OpHospital", CInt(Session("OperatingHospitalID"))))
                connection.Open()
                ImgPortID = cmd.ExecuteScalar()
                If ImgPortID IsNot Nothing AndAlso IsDBNull(ImgPortID) = False Then
                    Return CInt(ImgPortID)
                Else
                    Return 0
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function PCLogCheck(OperatingHospitalId As Integer) As Boolean
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim idObj As Object

            'Need to check if static or dynamic as well
            Dim SQL As String = "SELECT CASE " &
                " WHEN (SELECT TOP 1 1 FROM ERS_ImagePort WHERE OperatingHospitalId = @OperatingHospitalId AND RoomId = @RoomId AND IsActive = 1 AND ISNULL(Static,0) = 0) = 1 THEN 0 " &
                " WHEN (SELECT TOP 1 1 FROM ERS_PCLog WHERE ClientPCName = @RoomName) = 1 THEN 1 " &
                " ELSE 0 END"

            Dim cmd As New SqlCommand(SQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomId", Session("RoomId").ToString()))
            cmd.Parameters.Add(New SqlParameter("@RoomName", Session("RoomName").ToString()))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            'adapter.Fill(dsData)
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Friend Function IsTransnasalProcedure(procedureId As Integer) As Boolean
        Dim sql As String = "SELECT ISNULL(Transnasal, 0) AS Transnasal FROM ERS_Procedures WHERE ProcedureId = @ProcedureId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
        End Using
        Return False
    End Function

    Public Function InsertError(ByVal ErrorNo As String,
                                ByVal ErrorMessage As String,
                                ByVal ErrorDescription As String,
                                ByVal ErrorStackTrace As String,
                                ByVal ErrorInnerException As String,
                                ByVal ErrorData As String,
                                ByVal ProductId As Integer,
                                ByVal ProductVersion As String,
                                ByVal UserId As String,
                                ByVal StationId As String,
                                ByVal ProcedureId As Nullable(Of Integer),
                                ByVal PatientId As Nullable(Of Integer),
                                ByVal CaseNoteNo As String,
                                ByVal HospitalId As Integer,
                                ByVal OperatingHospitalId As Integer) As String
        Dim sql As String = "INSERT INTO ERS_ErrorLog ([ErrorReference], [ErrorTimestamp], [ErrorNo], [ErrorMessage], [ErrorDescription], [ErrorStackTrace], [ErrorInnerException], [ErrorData], [ProductId], [ProductVersion], [UserId], [StationId], [ProcedureId], [PatientId], [CaseNoteNo], [HospitalId], [OperatingHospitalId]) " &
                            "VALUES (@errorReference, GETDATE(), @errorNo, @errorMessage, @errorDescription, @errorStackTrace, @errorInnerException, @errorData, @productId, @productVersion, @userId, @stationId, @procedureId, @patientId, @caseNoteNo, @hospitalId, @operatingHospitalId) "

        Dim reference As String = "ERS" & OperatingHospitalId & Date.Now.ToString("yyyyMMddHHmmss")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@errorReference", reference))
            If Not String.IsNullOrEmpty(ErrorNo) Then
                cmd.Parameters.Add(New SqlParameter("@errorNo", ErrorNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorNo", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@errorMessage", ErrorMessage))
            If Not String.IsNullOrEmpty(ErrorDescription) Then
                cmd.Parameters.Add(New SqlParameter("@errorDescription", ErrorDescription))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorDescription", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(ErrorStackTrace) Then
                cmd.Parameters.Add(New SqlParameter("@errorStackTrace", ErrorStackTrace))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorStackTrace", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(ErrorInnerException) Then
                cmd.Parameters.Add(New SqlParameter("@errorInnerException", ErrorInnerException))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorInnerException", SqlTypes.SqlString.Null))
            End If

            If Not String.IsNullOrEmpty(ErrorData) Then
                cmd.Parameters.Add(New SqlParameter("@errorData", ErrorData))
            Else
                cmd.Parameters.Add(New SqlParameter("@errorData", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@productId", ProductId))
            cmd.Parameters.Add(New SqlParameter("@productVersion", HttpContext.Current.Session(Constants.SESSION_APPVERSION)))
            cmd.Parameters.Add(New SqlParameter("@userId", UserId))
            If Not String.IsNullOrEmpty(StationId) Then
                cmd.Parameters.Add(New SqlParameter("@stationId", StationId))
            Else
                cmd.Parameters.Add(New SqlParameter("@stationId", SqlTypes.SqlString.Null))
            End If
            If ProcedureId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@procedureId", ProcedureId))
            Else
                cmd.Parameters.Add(New SqlParameter("@procedureId", SqlTypes.SqlInt32.Null))
            End If
            If PatientId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@patientId", PatientId))
            Else
                cmd.Parameters.Add(New SqlParameter("@patientId", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(CaseNoteNo) Then
                cmd.Parameters.Add(New SqlParameter("@caseNoteNo", CaseNoteNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@caseNoteNo", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@HospitalId", HospitalId))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
        Return reference
    End Function

    Friend Sub SavePDFToDatabase(procedureId As String, bBLOBStorage() As Byte)
        Dim sql As String = "Insert into ERS_DocumentStore (ProcedureId, PDF) values (@ProcedureId, @PDF)"
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim blobParam = New SqlParameter("@PDF", SqlDbType.VarBinary, bBLOBStorage.Length)
            blobParam.Value = bBLOBStorage
            cmd.Parameters.Add(blobParam)
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Friend Function SavePDFToDatabase(patientId As Integer, procedureType As String, procedureDate As Date, bBLOBStorage() As Byte) As Boolean
        Try
            Dim sql As String = "Insert into ERS_PreviousProcedures (PatientId, ProcedureType, ProcedureDate, PDFBinary) " &
                "values (@patientId, @procedureType, @procedureDate, @PDFBinary)"
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
                cmd.Parameters.Add(New SqlParameter("@ProcedureDate", procedureDate))
                'cmd.Parameters.Add(New SqlParameter("@ProcedureDate", Now))
                Dim blobParam = New SqlParameter("@PDFBinary", SqlDbType.VarBinary, bBLOBStorage.Length)
                blobParam.Value = bBLOBStorage
                cmd.Parameters.Add(blobParam)
                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using

            Return True

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in SavePDFToDatabase", ex)
            Return False
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function InsertBlobDataToDocumentStore(ByVal ProcedureId As Integer,
        ByVal bBlobStorageContent As Byte(),
        ByVal FileType As String,
        ByVal FileLocation As String,
        ByVal FileLocationDirectory As String,
        ByVal DocumentFilename As String,
        ByVal OriginalPDFDocumentStoreId As Nullable(Of Integer),
        ByVal DocumentStoreIdList As String,
        ByVal blnPDFfileWrittentoDisk As Boolean,
        ByRef Output_DocumentStoreId As Integer) As Boolean

        Dim blnSaveFileBlobContentToDatabase As Boolean = True 'This is True by default - if nothing set App will save blob data in database
        Dim blnSaveBase64FileContentToDatabase As Boolean = False 'Is False by default - if nothing set app will not generate Base64FileContent data

        Dim Base64FileContent As String = ""

        If ConfigurationManager.AppSettings.AllKeys.Contains("SaveFileBlobContentToDatabase") Then
            If ConfigurationManager.AppSettings("SaveFileBlobContentToDatabase").ToLower() = "true" Then
                blnSaveFileBlobContentToDatabase = True
            Else
                blnSaveFileBlobContentToDatabase = False
            End If
        End If

        'In case the PDF file couldn't be written on Disk (Azure or local) - Override the settings
        If Not blnPDFfileWrittentoDisk Then
            blnSaveFileBlobContentToDatabase = True
        End If

        If ConfigurationManager.AppSettings.AllKeys.Contains("SaveBase64FileContentToDatabase") Then
            If ConfigurationManager.AppSettings("SaveBase64FileContentToDatabase").ToLower() = "true" Then
                blnSaveBase64FileContentToDatabase = True
            Else
                blnSaveBase64FileContentToDatabase = False
            End If
        End If

        If GetSuppressMainReportPDFFlag(CInt(HttpContext.Current.Session("OperatingHospitalID"))) Then
            FileLocation = Nothing
        End If

        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("sp_InsertBlobDataToDocumentStore", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))

                If blnSaveFileBlobContentToDatabase Then
                    cmd.Parameters.Add(New SqlParameter("@bBlobStorageContent", bBlobStorageContent))
                Else
                    'cmd.Parameters.Add(New SqlParameter("@bBlobStorageContent", DBNull.Value)) --MH changed as below on 21 Oct 2024 No TFS
                    cmd.Parameters.Add(New SqlParameter("@bBlobStorageContent", SqlDbType.VarBinary)).SqlValue = DBNull.Value
                End If


                If String.IsNullOrEmpty(FileType) Then
                    cmd.Parameters.Add(New SqlParameter("@FileType", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@FileType", FileType))
                End If

                If String.IsNullOrEmpty(FileLocation) Then
                    cmd.Parameters.Add(New SqlParameter("@FileLocation", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@FileLocation", FileLocation))
                End If

                If String.IsNullOrEmpty(FileLocationDirectory) Then
                    cmd.Parameters.Add(New SqlParameter("@FileLocationDirectory", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@FileLocationDirectory", FileLocationDirectory))
                End If

                If String.IsNullOrEmpty(DocumentFilename) Then
                    cmd.Parameters.Add(New SqlParameter("@DocumentFileName", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@DocumentFileName", DocumentFilename))
                End If

                If Not OriginalPDFDocumentStoreId.HasValue() Then
                    cmd.Parameters.Add(New SqlParameter("@OriginalPDFDocumentStoreId", DBNull.Value))
                ElseIf OriginalPDFDocumentStoreId > 0 Then
                    cmd.Parameters.Add(New SqlParameter("@OriginalPDFDocumentStoreId", OriginalPDFDocumentStoreId))
                Else
                    cmd.Parameters.Add(New SqlParameter("@OriginalPDFDocumentStoreId", DBNull.Value))
                End If

                If Not IsNothing(bBlobStorageContent) Then
                    If blnSaveBase64FileContentToDatabase Then
                        Base64FileContent = Convert.ToBase64String(bBlobStorageContent)
                    End If
                End If

                If String.IsNullOrEmpty(Base64FileContent) Then
                    cmd.Parameters.Add(New SqlParameter("@Base64FileContent", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Base64FileContent", Base64FileContent))
                End If

                If String.IsNullOrEmpty(DocumentStoreIdList) Then
                    cmd.Parameters.Add(New SqlParameter("@LinkDocumentStoreIds", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@LinkDocumentStoreIds", DocumentStoreIdList))
                End If

                cmd.Parameters.Add(New SqlParameter("@Output_DocumentStoreId", SqlDbType.Int))
                cmd.Parameters("@Output_DocumentStoreId").Direction = ParameterDirection.Output

                connection.Open()
                cmd.ExecuteNonQuery()

                Output_DocumentStoreId = cmd.Parameters("@Output_DocumentStoreId").Value
            End Using
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function Updatesp_InsertBlobDataToDocumentStore...", ex)
            Return False
        End Try
    End Function

    Public Function GetDataFromStoredProcedure()
        Try
            Dim dsData As New DataSet
            Dim da As SqlDataAdapter
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("get_ProcedureTypes", connection)
                connection.Open()
                da = New SqlDataAdapter(cmd)
                da.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
        Catch ex As Exception
            Throw ex
        End Try
        Return Nothing
    End Function

    Public Sub insertImageCount(ImageCount As String, ProcedureId As Integer)
        DataAccess.ExecuteScalerSQL("addImageCount", CommandType.StoredProcedure, New SqlParameter() {
                                New SqlParameter("@ImageCount", ImageCount),
                                New SqlParameter("@ProcedureId", ProcedureId)})
    End Sub

    Public Function InsertPhrase(userName As String, Category As String, Phrase As String, OperatingHospitalId As Integer, ProcedureTypeId As String) As String
        Try
            Dim RecColID As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("common_phraselibrary_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@UserName", userName))
                cmd.Parameters.Add(New SqlParameter("@PhraseCategory", Category))
                cmd.Parameters.Add(New SqlParameter("@Phrase", Phrase))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", ProcedureTypeId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                connection.Open()
                RecColID = cmd.ExecuteScalar()
                If RecColID IsNot Nothing AndAlso IsDBNull(RecColID) = False Then
                    Return CStr(RecColID)
                Else
                    Return Nothing
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function DeletePhrase(PhraseID As String) As Integer
        Try
            Dim RecColID As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("DELETE FROM [ERS_PhraseLibrary] WHERE PhraseID = @PhraseID", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@PhraseID", PhraseID))
                connection.Open()
                RecColID = cmd.ExecuteScalar()
                If RecColID IsNot Nothing AndAlso IsDBNull(RecColID) = False Then
                    Return CInt(RecColID)
                Else
                    Return Nothing
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function EditPhrase(PhraseID As String, Phrase As String) As Integer
        Try
            Dim RecColID As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("UPDATE [ERS_PhraseLibrary] SET Phrase = @Phrase, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE PhraseID = @PhraseID", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@PhraseID", PhraseID))
                cmd.Parameters.Add(New SqlParameter("@Phrase", Phrase))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                connection.Open()
                RecColID = cmd.ExecuteScalar()
                If RecColID IsNot Nothing AndAlso IsDBNull(RecColID) = False Then
                    Return CInt(RecColID)
                Else
                    Return Nothing
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetConsultants(ConsultantID As Integer) As DataTable
        Dim sqlStr As String = "Select ISNULL([Title],'') as Title, ISNULL([Initial],'') as Initial, ISNULL([ForeName],'') as ForeName, ISNULL([Surname],'') as Surname, " &
                                "ISNULL([EmailAddress], '') AS EmailAddress,  ISNULL([GMCCode],'') as GMCCode , ISNULL([GroupID],0) as GroupID, ISNULL([AllHospitals],1) as AllHospitals  " &
                                " FROM [ERS_Consultant]  WHERE [ConsultantID] = " & CStr(ConsultantID)
        Return GetData(sqlStr)
    End Function

    Public Function UpdatePCSImagePort(RoomId As String, imageportId As Integer, isStatic As Boolean) As Boolean
        Dim idObj As Object

        Dim sql As String = "IF NOT EXISTS (SELECT 1 FROM ERS_ImagePort WHERE RoomId = @RoomId) BEGIN UPDATE ERS_ImagePort SET RoomId = @RoomId, Static = @isStatic WHERE ImagePortId = @ImagePortId; SELECT 1 END "
        sql += " ELSE SELECT 0;"
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomId", RoomId))
            cmd.Parameters.Add(New SqlParameter("@ImagePortId", imageportId))
            cmd.Parameters.Add(New SqlParameter("@isStatic", isStatic))
            cmd.Connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CBool(idObj)
            End If
            Return CBool(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetConsultants(GroupID As String) As DataTable
        Dim sqlStr As String
        If GroupID = Nothing Or GroupID = "" Then
            sqlStr = "SELECT ConsultantId, ISNULL(LTRIM(RTRIM([Title])) + ' ', '') + ISNULL(LTRIM(RTRIM([Forename])) + ' ', '') + ISNULL(LTRIM(RTRIM([Surname])), '') as Name FROM [ERS_Consultant] WHERE [Suppressed] = 0 ORDER BY [Surname]"
        Else
            sqlStr = "SELECT ConsultantId, ISNULL(LTRIM(RTRIM([Title])) + ' ', '') + ISNULL(LTRIM(RTRIM([Forename])) + ' ', '') + ISNULL(LTRIM(RTRIM([Surname])), '') as Name FROM [ERS_Consultant] WHERE [Suppressed] = 0 AND  GroupID = " & GroupID & " ORDER BY [Surname]"
        End If
        Return GetData(sqlStr)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetConsultantsLst(Field As String, FieldValue As String, Suppressed As Nullable(Of Integer)) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("common_consultant_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalId", .SqlDbType = SqlDbType.Int, .Value = CInt(HttpContext.Current.Session("OperatingHospitalId"))})
            If Field = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Field", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Field", .SqlDbType = SqlDbType.Text, .Value = Field})
            End If
            If FieldValue = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@FieldValue", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@FieldValue", .SqlDbType = SqlDbType.Text, .Value = FieldValue})
            End If
            If Suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = Suppressed})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = DBNull.Value})
            End If
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = Session("TrustId")})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetPhotoURL(operatingHospitalId As Integer) As String
        Dim sqlStr = "SELECT ISNULL(PhotosURL,'') as PhotosURL FROM ERS_SystemConfig WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using
    End Function

    Friend Function IsNormalProcedure(procId As Integer) As Boolean
        Dim sqlStr = "SELECT CASE WHEN (SELECT TOP 1 1 FROM ers_sites WHERE ProcedureId = @ProcedureId AND isnull(HasAbnormalities,0) = 1) = 1 THEN 0 ELSE 1 END"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procId))
            connection.Open()
            Return CBool(cmd.ExecuteScalar())
        End Using
    End Function

    Public Function GetPhotoUNC(operatingHospitalId As Integer) As String
        Dim sqlStr = "SELECT ISNULL(PhotosUNC,'') as PhotosUNC FROM ERS_SystemConfig WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using

    End Function
    Public Function GetAddExportFileForMirthFlag(operatingHospitalId As Integer) As Boolean
        Dim sqlStr = "SELECT ISNULL(AddExportFileForMirth,0) as AddExportFileForMirth FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return Convert.ToBoolean(cmd.ExecuteScalar())
        End Using

    End Function
    Public Function GetSuppressMainReportPDFFlag(operatingHospitalId As Integer) As Boolean
        Dim sqlStr = "SELECT ISNULL(SuppressMainReportPDF,0) as SuppressMainReportPDF FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return Convert.ToBoolean(cmd.ExecuteScalar())
        End Using

    End Function
    Public Function GetExportDocumentToApiConfigVariables(operatingHospitalId As Integer) As DataTable
        Dim sqlStr = "SELECT ISNULL(ReportDocumentExportApiUrl,'') as ReportDocumentExportApiUrl, ISNULL(DocumentExportSharedLocation,'') as DocumentExportSharedLocation,ISNULL(ReportSharedDriveAccessUser,'') as ReportSharedDriveAccessUser,ISNULL(SharedDriveAccessUserPassword,'') as SharedDriveAccessUserPassword,ISNULL(DirectoryNameForXmlTransferInAzure,'') as DirectoryNameForXmlTransferInAzure FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Dim dsData As New DataSet
        Dim da As SqlDataAdapter


        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            da = New SqlDataAdapter(cmd)
            da.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If

    End Function
    Public Function GetImportPatientByWebservice(operatingHospitalId As Integer) As Integer
        Dim sqlStr = "SELECT ISNULL(ImportPatientByWebService,0) as ImportPatientByWebService FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using

    End Function
    'Mahfuz created on 24 June 2021
    Public Function GetTrustCodeByTrustID(intTrustID As Integer) As String
        Dim sqlStr = "SELECT ISNULL(TrustCode,'') as TrustCode FROM ERS_Trusts WHERE TrustID = @TrustID"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@TrustID", intTrustID))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetConsultantsHospitalList(ConsultantID As Integer) As DataTable
        Dim sqlStr As String = "SELECT [HospitalID] FROM [ERS_ConsultantsHospital] WHERE [ConsultantID] = " & CStr(ConsultantID)
        Return GetData(sqlStr)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSpeciality() As DataTable
        Dim sqlStr As String = "SELECT [GroupID], [GroupName], [Code] FROM [ERS_ConsultantGroup] ORDER BY GroupName"
        Return GetData(sqlStr)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSpeciality(ConsultantID As String) As String
        Dim value As String
        Dim querystr As String = "SELECT g.[GroupID], g.[Code] FROM [ERS_ConsultantGroup] g LEFT JOIN [ERS_Consultant] c ON g.Code = c.GroupID  WHERE c.ConsultantID = @ConsultantID"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@ConsultantID", ConsultantID))
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If Not IsDBNull(v) Then
                If IsNothing(v) Then
                    value = Nothing
                Else
                    value = v.ToString
                End If
            Else
                value = Nothing
            End If
        End Using
        Return value
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHospitalsLst(HospitalName As String, Suppressed As Nullable(Of Integer)) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_referral_hospitals", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))
            If Suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Suppressed", Suppressed.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@Suppressed", DBNull.Value))

            End If
            cmd.Parameters.Add(New SqlParameter("@HospitalName", HospitalName))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SaveHospital(HospitalName As String) As Integer
        Dim sql As String = "common_hospital_save"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))
            cmd.Parameters.Add(New SqlParameter("@HospitalName", HospitalName))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function
    Public Function SaveSpeciality(GroupName As String, GroupCode As String) As Integer
        Dim sql As String = "common_speciality_save"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@GroupName", GroupName))
            cmd.Parameters.Add(New SqlParameter("@GroupCode", GroupCode))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function
    Public Function SuppressHospital(HospitalID As String, Suppressed As Boolean) As Integer
        Dim sql As String = "UPDATE [ERS_ReferralHospitals] SET [Suppressed] = @Suppressed WHERE [HospitalID]= @HospitalID"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@Suppressed", Suppressed))
            cmd.Parameters.Add(New SqlParameter("@HospitalID", HospitalID))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    Public Function SuppressConsultant(ConsultantID As String, Suppressed As Boolean) As Integer
        Dim sql As String = "UPDATE [ERS_Consultant] SET [Suppressed] = @Suppressed, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE [ConsultantID]= @ConsultantID"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@Suppressed", Suppressed))
            cmd.Parameters.Add(New SqlParameter("@ConsultantID", ConsultantID))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetReferralHospitals(ConsultantID As String) As DataTable
        Dim sqlStr As String = Nothing
        If ConsultantID = Nothing Or ConsultantID = "" Then
            sqlStr = "SELECT * FROM [ERS_ReferralHospitals] WHERE [Suppressed] = 0 ORDER BY [HospitalName]"
        Else
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim querystr As String = "SELECT [AllHospitals] FROM [ERS_Consultant] WHERE [ConsultantID] = " & ConsultantID & " AND [TrustId] = " & Session("TrustId")
                Dim mycmd As New SqlCommand(querystr, connection)
                mycmd.CommandType = CommandType.Text
                connection.Open()
                Dim value As Object = mycmd.ExecuteScalar()
                If Not IsDBNull(value) Then
                    If CBool(value) = True Then
                        sqlStr = "SELECT * FROM [ERS_ReferralHospitals] WHERE [Suppressed] = 0 AND [TrustId] = " & Session("TrustId") & " ORDER BY [HospitalName]"
                    Else
                        sqlStr = "SELECT rh.[HospitalName],rh.[HospitalID] FROM [ERS_ReferralHospitals] rh LEFT JOIN [ERS_ConsultantsHospital] ch ON rh.[HospitalID]  = ch.[HospitalID] WHERE rh.[Suppressed] =0 AND ch.ConsultantID= " & ConsultantID & " [TrustId] = " & Session("TrustId") & " ORDER BY [HospitalName]"
                    End If
                End If
            End Using
        End If
        Return GetData(sqlStr)
    End Function

    Public Function SaveConsultant(ConsultantID As Integer, Title As String, Initial As String, Forename As String, Surname As String, EmailAddress As String, GroupID As String, AllHospitals As Nullable(Of Boolean), GMCCode As String, HospitalList As String) As Integer
        Dim sql As String = "common_consultant_save"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ConsultantID", ConsultantID))
            If Title = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Title", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Title", .SqlDbType = SqlDbType.Text, .Value = Title})
            End If
            If Initial = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Initial", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Initial", .SqlDbType = SqlDbType.Text, .Value = Initial})
            End If
            If Forename = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Forename", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Forename", .SqlDbType = SqlDbType.Text, .Value = Forename})
            End If
            If Surname = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Surname", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Surname", .SqlDbType = SqlDbType.Text, .Value = Surname})
            End If
            If EmailAddress = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@EmailAddress", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@EmailAddress", .SqlDbType = SqlDbType.Text, .Value = EmailAddress})
            End If
            If GroupID = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GroupID", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GroupID", .SqlDbType = SqlDbType.Text, .Value = GroupID})
            End If
            'cmd.Parameters.Add(New SqlParameter("@GroupID", GroupID))
            cmd.Parameters.Add(New SqlParameter("@AllHospitals", AllHospitals))
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LoggedInUserId", .SqlDbType = SqlDbType.Int, .Value = LoggedInUserId})

            If GMCCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GMCCode", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GMCCode", .SqlDbType = SqlDbType.Text, .Value = GMCCode})
            End If
            If HospitalList = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HospitalList", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@HospitalList", .SqlDbType = SqlDbType.Text, .Value = HospitalList})
            End If
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = Session("TrustId")})
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    Public Function GetProceduresImagePort(procedureId As Integer) As DataTable
        Dim rSet As New DataSet
        'FormerProcedureId below is required for double procedure, to display images captured in the former procedure from cache
        Dim sql As String = "SELECT ISNULL(ep.ImagePortId,0) AS ImagePortId, eip.PortName, ISNULL(ep.FormerProcedureId,0) AS FormerProcedureId
                                FROM dbo.ERS_Procedures ep
	                                INNER JOIN dbo.ERS_ImagePort eip 
		                                ON ep.ImagePortId = eip.ImagePortId
                                WHERE ep.ProcedureId = @ProcedureId"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(rSet)
        End Using
        If rSet.Tables.Count > 0 Then
            Return rSet.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetImagePortRooms(operatingHospitalId As Integer) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            'Dim sqlCmd As New SqlCommand("SELECT ip.ImagePortId, ip.MacAddress, ip.FriendlyName, ip.[Default], rooms.RoomId, rooms.RoomName, ip.Static, ip.Comments, ip.PortName " &
            '                "FROM ERS_SCH_Rooms AS rooms " &
            '                "LEFT JOIN ERS_ImagePort AS ip ON rooms.HospitalId = ip.OperatingHospitalId ", connection)
            Dim sqlCmd As New SqlCommand("SELECT rooms.RoomId, rooms.RoomName " &
                            "FROM ERS_SCH_Rooms AS rooms " &
                            "WHERE HospitalId = @OperatingHospitalId and Suppressed = 0 " &
                            "ORDER BY rooms.RoomSortOrder", connection)


            sqlCmd.CommandType = CommandType.Text
            sqlCmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            Dim adapter = New SqlDataAdapter(sqlCmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If

        Return Nothing

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetImagePortRoomsSpecific(imagePortId As Integer, roomId As Integer) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("image_port_room_specific_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ImagePortId", imagePortId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If

        Return Nothing

    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOperatingHospitalID(RoomId As Integer) As Integer

        Dim value As Integer = -1
        Dim querystr As String = "SELECT TOP 1 o.OperatingHospitalId
                            From ERS_OperatingHospitals o
                            LEFT JOIN ERS_SCH_Rooms r ON o.OperatingHospitalId = r.HospitalId WHERE r.RoomId = '" & RoomId & "'"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim mycmd As New SqlCommand(querystr, connection)
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If Not IsDBNull(v) AndAlso Not IsNothing(v) Then
                value = CInt(v)
            Else
                value = -1
            End If
        End Using
        Return value
    End Function
    Public Function GetProcedureDataForFileDataExport(intProcedureID As Integer) As DataSet
        Try
            Dim ds As DataSet
            ds = New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("uspGetProcedureDataForExport", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", intProcedureID))
                cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))
                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(ds)

                Return ds
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in DataAccess-->GetProcedureDataForFileDataExport", ex)
            Return Nothing
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOperatingHospitalsRooms(trustId As Integer) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Get_Login_Rooms", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@TrustId", trustId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If

        Return Nothing


    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTrusts() As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Get_Trusts", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If

        Return Nothing


    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTrustHospitals(trustId As Integer) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Get_Trust_Hospitals", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@TrustId", trustId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If

        Return Nothing


    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOperatingHospitals(sFirstItemText As String) As DataTable
        Return GetData("SELECT *, '" & sFirstItemText & "' AS FirstItemText  FROM [ERS_OperatingHospitals] ORDER BY HospitalName ASC")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOperatingHospitals() As DataTable
        'Return GetData("SELECT * FROM [ERS_OperatingHospitals] ORDER BY OperatingHospitalId ASC")
        Dim dsData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_OperatingHospitals where TrustId = @TrustId ORDER BY HospitalName ASC", connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))
            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllOperatingHospitals(selectedTrust As Integer) As DataTable
        'Return GetData("SELECT * FROM [ERS_OperatingHospitals] ORDER BY OperatingHospitalId ASC")
        Dim dsData As New DataSet
        Dim searchByTrust As String = ""
        If Not (selectedTrust = 0) Then
            searchByTrust = " Where TrustId=" + selectedTrust.ToString()
        End If

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_OperatingHospitals " + searchByTrust + "  ORDER BY HospitalName ASC", connection)
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

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllOperatingHospitals() As DataTable
        'Return GetData("SELECT * FROM [ERS_OperatingHospitals] ORDER BY OperatingHospitalId ASC")
        Dim dsData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_OperatingHospitals ORDER BY HospitalName ASC", connection)
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

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTemplateOperatingHospitals() As DataTable
        '    Return GetData("SELECT OperatingHospitalId, HospitalName FROM dbo.ERS_OperatingHospitals eoh ORDER BY OperatingHospitalId")
        Dim dsData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT OperatingHospitalId, HospitalName FROM dbo.ERS_OperatingHospitals eoh where TrustId = @TrustId ORDER BY HospitalName ASC", connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))
            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function GetInternalOperatingHospitalID(OperatingHospitalID As String) As String
        Dim value As String
        Dim querystr As String = "SELECT InternalHospitalID FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalID))
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If Not IsDBNull(v) AndAlso Not IsNothing(v) Then
                value = v.ToString
            Else
                value = Nothing
            End If
        End Using
        Return value
    End Function
    Public Function GetOperatingHospitalCount() As Integer
        Dim value As Integer = -1
        Dim querystr As String = "SELECT Count([OperatingHospitalId]) FROM ERS_OperatingHospitals"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim mycmd As New SqlCommand(querystr, connection)
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If Not IsDBNull(v) AndAlso Not IsNothing(v) Then
                value = CInt(v)
            Else
                value = -1
            End If
        End Using
        Return value
    End Function
    Public Function GetLoginPCDetails(RoomName As String, UserName As String) As DataTable
        Return GetData("SELECT * FROM [ERS_PCLog] WHERE [ClientPCName] = '" & RoomName & "' AND UserName = '" & UserName & "'")
    End Function
    Public Function SaveLoginPcDetail(RoomName As String, OperatingHospitalID As Integer, UserName As String) As Integer
        Dim sql As String = "IF NOT EXISTS(SELECT 1 FROM [ERS_PCLog] WHERE [ClientPCName]= @RoomName AND UserName=@UserName) INSERT INTO [ERS_PCLog](ClientPCName,OperatingHospitalID,UserName) VALUES (@RoomName,@OperatingHospitalID,@UserName)"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalID))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
    'Public Function LockPatientProcedures(ClientPCName As String, UserName As String, LockedPatientID As Integer) As Integer
    '    Dim sql As String = "IF EXISTS(SELECT 1 FROM ERS_PCLog WHERE [LockedPatientID] = @LockedPatientID) BEGIN UPDATE ERS_PCLog SET [LockedPatientID]= NULL, [LockedOn]=NULL WHERE [LockedPatientID] = @LockedPatientID END; UPDATE [ERS_PCLog] SET [LockedPatientID] = @LockedPatientID, [LockedOn] = @LockedOn WHERE ClientPCName = @ClientPCName AND UserName =@UserName"
    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand(sql.ToString(), connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@ClientPCName", ClientPCName))
    '        cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
    '        cmd.Parameters.Add(New SqlParameter("@LockedPatientID", LockedPatientID))
    '        cmd.Parameters.Add(New SqlParameter("@LockedOn", Date.Now))
    '        connection.Open()
    '        Return cmd.ExecuteNonQuery()
    '    End Using
    'End Function

    Public Function GetFirstERCP(ByVal procedureId As Integer) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT dbo.fnFirstERCP(@ProcedureId)", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            Return CStr(cmd.ExecuteScalar())
        End Using
        Return ""
    End Function

    Public Function isPatientProceduresLocked(UserName As String, LockedPatientID As Integer) As DataTable
        Dim rSet As New DataSet
        Dim sql As String = "IF EXISTS(SELECT 1 FROM ERS_PCLog WHERE [LockedPatientID] = @LockedPatientID AND UserName <> @UserName AND LockedOn >= GETDATE()-1) BEGIN SELECT '1' AS isLocked, 'This patient has been locked by '+ u.Username +' from '+ p.ClientPCName + ' on ' + cast(p.LockedOn as varchar(50)) AS LockedMessage FROM ERS_PCLog p INNER JOIN tvfUsersByOperatingHospital(@OperatingHospitalId) u ON p.UserName = u.UserName WHERE p.[LockedPatientID] = @LockedPatientID END ELSE SELECT 0 AS isLocked, '' AS LockedMessage"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@LockedPatientID", LockedPatientID))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(rSet)
        End Using
        If rSet.Tables.Count > 0 Then
            Return rSet.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    'Public Function UnlockPatientProcedures(ClientPCName As String, UserName As String) As Integer
    '    Dim sql As String = "UPDATE ERS_PCLog SET [LockedPatientID]= NULL, [LockedOn]=NULL WHERE ClientPCName = @ClientPCName AND UserName =@UserName"
    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand(sql.ToString(), connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@ClientPCName", ClientPCName))
    '        cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
    '        connection.Open()
    '        Return cmd.ExecuteNonQuery()
    '    End Using
    'End Function
    'end of PatientProcedures
    Public Function isUserLockedOut(RoomName As String, UserName As String) As DataTable
        Dim rSet As New DataSet
        Dim sql As String = "SELECT 'You have been locked out of this system from '  + [LogOutBy] as pcMessage, CASE ISNULL(LogOutBy,'') WHEN '' THEN 0 WHEN ClientPCName THEN 0 ELSE 1 END AS pcState FROM ERS_PCLog WHERE ClientPCName = @RoomName AND UserName= @UserName"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(rSet)
        End Using
        If rSet.Tables.Count > 0 Then
            Return rSet.Tables(0)
        Else
            Return Nothing
        End If
    End Function

    Public Function isUserExist(RoomName As String, UserName As String) As Integer
        Dim sql As String = "IF EXISTS(SELECT 1 FROM ERS_PCLog WHERE UserName = @UserName AND ClientPCName <> @RoomName AND ([LogOutBy] <> @RoomName  OR [LogOutBy] IS NULL) ) SELECT 1 ELSE SELECT 0"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            connection.Open()
            Dim r As Object = cmd.ExecuteScalar
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CInt(r)
            Else
                Return 0
            End If
        End Using
    End Function
    Public Function isUserExistLogOutMessages(RoomName As String, UserName As String) As String
        Dim sql As String = "SELECT 'User account '+ ISNULL((SELECT u.Username  FROM tvfUsersByOperatingHospital(@OperatingHospitalId) u WHERE  u.UserName = p.UserName ),'""' + @UserName + '""') + ' is currently in use on ' + p.ClientPCName + '. Do you wish to logout the current user?'  FROM ERS_PCLog p WHERE p.UserName = @UserName AND p.ClientPCName <> @RoomName AND ([LogOutBy] <> @RoomName  OR [LogOutBy] IS NULL)"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId"))))
            connection.Open()
            Dim r As Object = cmd.ExecuteScalar
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CStr(r)
            Else
                Return Nothing
            End If
        End Using
    End Function

    Public Sub setTransnasal(transnasal As Boolean)
        Dim sql As String = "UPDATE ERS_Procedures SET Transnasal = @Transnasal WHERE ProcedureId = @ProcedureId ; Exec Procedure_Updated @ProcedureId ; "
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))))
            cmd.Parameters.Add(New SqlParameter("@Transnasal", transnasal))
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
        Using db As New ERS.Data.GastroDbEntities
            Dim pr = db.ERS_ProceduresReporting.Find(CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID)))
            Dim proc = db.ERS_Procedures.Find(CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID)))
            If pr.PP_Instrument IsNot Nothing Then
                If Not pr.PP_Instrument.Contains("(Transnasal)") And transnasal Then
                    pr.PP_Instrument = pr.PP_Instrument + " (Transnasal)"
                ElseIf pr.PP_Instrument.Contains("(Transnasal)") And Not transnasal Then
                    pr.PP_Instrument = pr.PP_Instrument.Replace(" (Transnasal)", "")
                End If
                'pr.PP_Instrument = InstrumentTxt
                db.SaveChanges()
                Update_ProceduresReporting(CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID)))
            End If
        End Using
    End Sub

    Friend Function GetPDFExportLocation(operatingHospitalId As Integer) As String
        Dim sql As String = "SELECT ISNULL(ReportExportPath,'') AS ReportExportPath FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using
    End Function
    Friend Function GetIsExportPdfInAzureStorage(operatingHospitalId As Integer) As Boolean
        Dim sql As String = "SELECT ISNULL(ExportPDFReportInAzureStorage,0) AS ExportPDFReportInAzureStorage FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Dim dsData As New DataSet
        Dim blnExportToAzureStorage As Boolean = False

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            Dim da As New SqlDataAdapter(cmd)

            connection.Open()
            da.Fill(dsData)
            If dsData.Tables(0).Rows.Count > 0 Then
                blnExportToAzureStorage = Convert.ToBoolean(dsData.Tables(0).Rows(0)("ExportPDFReportInAzureStorage"))
            End If
        End Using
        Return blnExportToAzureStorage
    End Function
    Friend Function GetIsDisplayPatientWithoutCHI(operatingHospitalId As Integer) As Boolean
        Dim sql As String = "SELECT ISNULL(DisplayPatientWithoutCHI,0) AS DisplayPatientWithoutCHI FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Dim dsData As New DataSet
        Dim blnExportToAzureStorage As Boolean = False

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            Dim da As New SqlDataAdapter(cmd)

            connection.Open()
            da.Fill(dsData)
            If dsData.Tables(0).Rows.Count > 0 Then
                blnExportToAzureStorage = Convert.ToBoolean(dsData.Tables(0).Rows(0)("DisplayPatientWithoutCHI"))
            End If
        End Using
        Return blnExportToAzureStorage
    End Function
    Friend Function GetPDFReportDirectoryInAzureStorage(operatingHospitalId As Integer) As String
        Dim sql As String = "SELECT ISNULL(PDFReportDirectoryInAzureStorage,'') AS PDFReportDirectoryInAzureStorage FROM ERS_OperatingHospitals WHERE OperatingHospitalId = @OperatingHospitalId"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using
    End Function


    Public Function clearExistingUser(RoomName As String, UserName As String) As Integer
        Dim sql As String = "UPDATE ERS_PCLog SET LogOutBy = @RoomName, LoggedOutOn = GetDate()  WHERE UserName= @UserName"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoomName", RoomName))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPhrasesData(UserID As String, PhraseCategory As String, OperatingHospitalId As Integer, ProcedureTypeIds As String, PhraseText As String) As DataTable
        Return ExecuteSP("GetFilteredPhrases", New SqlParameter() {
                         New SqlParameter("@UserName", UserID),
                         New SqlParameter("@PhraseCategory", PhraseCategory),
                         New SqlParameter("@OperatingHospitalId", OperatingHospitalId),
                         New SqlParameter("@ProcedureTypeIds", ProcedureTypeIds),
                         New SqlParameter("@PhraseText", PhraseText)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetStaff(role As Staff) As DataTable
        Dim sql As New StringBuilder

        sql.Append("SELECT UserId, ISNULL(Title, '') + ISNULL(' ' + Forename, '') + ' ' + Surname AS UserFullName FROM tvfUsersByOperatingHospital(@OperatingHospitalId) ")

        If role = Staff.ListConsultant Then
            sql.Append("WHERE [IsListConsultant] = 1 ")
        ElseIf role = Staff.EndoScopist1 Then
            sql.Append("WHERE [IsEndoscopist1] = 1 ")
        ElseIf role = Staff.EndoScopist2 Then
            sql.Append("WHERE [IsEndoscopist2] = 1 ")
        ElseIf role = Staff.Nurse1 Then
            sql.Append("WHERE [IsAssistantOrTrainee] = 1 ")
        ElseIf role = Staff.Nurse2 Then
            sql.Append("WHERE [IsNurse1] = 1 ")
        ElseIf role = Staff.Nurse3 Then
            sql.Append("WHERE [IsNurse2] = 1 ")
        ElseIf role = Staff.Nurse4 Then
            sql.Append("WHERE [IsNurse2] = 1 ")
        End If

        sql.Append("ORDER BY [Surname] ")

        'Return GetData(sql.ToString())
        Return ExecuteSQL(sql.ToString(), New SqlParameter() {New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId")))})

    End Function

    Public Function GetProcedureDetails(ProcedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("GetProcedureDetails", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If

        Return Nothing
    End Function

    Public Function GetRecordCountOfOtherData(ByVal procedureId As Integer) As DataTable
        Dim dsRecordCountOfOtherData As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND SiteID IS NULL ", connection)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsRecordCountOfOtherData)
        End Using

        If dsRecordCountOfOtherData.Tables.Count > 0 Then
            Return dsRecordCountOfOtherData.Tables(0)
        End If
        Return Nothing
        'Using da As New DataAccess
        '    Return DataAccess.ExecuteSQL("SELECT * FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND SiteID IS NULL", New SqlParameter() {New SqlParameter("@ProcedureId", procedureId)})
        'End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRegionPathsEbusLymphNodes(height As Integer, width As Integer) As DataTable
        Dim dsRegions As New DataSet
        Dim query As New StringBuilder
        Dim constr = ConnectionStr

        query.Append("SELECT EBUSLymphNodeId, [Name] AS Region, RegionId, [Name] AS ActualRegionName, ")
        query.Append("convert(decimal(5,2), (XCoordinate * (convert(decimal(5,2),@Width)/500))) AS XCoordinate, ")
        query.Append("convert(decimal(5,2), (YCoordinate * (convert(decimal(5,2),@Height)/500))) AS YCoordinate, ")
        query.Append("FROM ERS_EBUSLymphNodes ")

        Using connection As New SqlConnection(constr)
            Dim cmd As New SqlCommand("get_ebus_lymph_nodes", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@height", height))
            cmd.Parameters.Add(New SqlParameter("@width", width))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsRegions)
        End Using

        If dsRegions.Tables.Count > 0 Then
            Return dsRegions.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRegionPathsProtocolSites(procedureId As Integer) As DataTable
        Dim dsRegions As New DataSet
        Dim query As New StringBuilder
        Dim constr = ConnectionStr

        Using connection As New SqlConnection(constr)
            Dim cmd As New SqlCommand("procedure_sydney_protocol_sites_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsRegions)
        End Using

        If dsRegions.Tables.Count > 0 Then
            Return dsRegions.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetResectedColonRegions() As DataTable
        'Dim procedureTypeID As Integer = CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE))

        'If procedureTypeID <> ProcedureType.Colonoscopy And procedureTypeID <> ProcedureType.Sigmoidscopy Then Return Nothing

        Dim dsResectedColonRegions As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT rc.ResectedColonID, rc.ResectedColonText, rcr.RegionId, r.Region ")
        query.Append("FROM ERS_ResectedColonRegions rcr ")
        query.Append("JOIN ERS_ResectedColon rc ON rcr.ResectedColonID = rc.ResectedColonID ")
        query.Append("JOIN ERS_Regions r ON rcr.RegionId = r.RegionId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString(), connection)
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResectedColonRegions)
        End Using

        If dsResectedColonRegions.Tables.Count > 0 Then
            Return dsResectedColonRegions.Tables(0)
        End If
        Return Nothing
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetAppointments() As DataTable
    '    Return GetData("SELECT * FROM ERS_Appointments")
    'End Function

    Public Function GetCustomer(ByVal hospitalId As Integer) As DataTable
        Dim dsCustomer As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM [CRM_Customers] WHERE HospitalID = @HospitalID", connection)
            cmd.Parameters.Add(New SqlParameter("@HospitalID", hospitalId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsCustomer)
        End Using

        If dsCustomer.Tables.Count > 0 Then
            Return dsCustomer.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetEthnicOrigins(ByVal usedIn As EthnicOriginsUsedIn) As DataTable
        Dim dsEthnicOrigins As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_Ethnic_Groups ORDER BY CASE WHEN details = 'Not Stated' THEN ' Not Stated' ELSE details END", connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsEthnicOrigins)
        End Using

        If dsEthnicOrigins.Tables.Count > 0 Then
            Return dsEthnicOrigins.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function GetResectedColonDetails(ByVal ProcedureID As Integer, ByVal EpisodeNo As Integer, ByVal bIsRetrograde As Boolean) As String
        Dim RecColID As Object
        Dim sql As String = ""
        If ProcedureID = 0 Then
            Dim sTableName As String = IIf(bIsRetrograde, "[ENTER retro procedure]", "[Colon Procedure]")
            sql = "SELECT [Resected Colon No] AS  ResectedColonNo FROM " & sTableName & " WHERE [Episode No] = @EpisodeNo AND [Patient No] = @PatientNo"
        Else
            sql = "SELECT ResectedColonNo FROM ERS_Procedures WHERE ProcedureID = @ProcedureID"
        End If

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            cmd.Parameters.Add(New SqlParameter("@EpisodeNo", EpisodeNo))
            If HttpContext.Current.Session("PatientComboId") IsNot Nothing Then
                cmd.Parameters.Add(New SqlParameter("@PatientNo", HttpContext.Current.Session("PatientComboId")))
            Else
                cmd.Parameters.Add(New SqlParameter("@PatientNo", SqlTypes.SqlString.Null))
            End If
            connection.Open()
            RecColID = cmd.ExecuteScalar()
            If RecColID IsNot Nothing AndAlso IsDBNull(RecColID) = False Then
                Return CStr(RecColID)
            Else
                Return "0"
            End If
        End Using
        Return Nothing
    End Function

    Public Function GetResectedColonText(ResectedColonID As Integer) As String
        Dim ResectedColonTextValue As Object
        Dim sql As String = "SELECT ResectedColonText  FROM ERS_ResectedColon WHERE ResectedColonID = @ResectedColonID"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ResectedColonID", ResectedColonID))
            connection.Open()
            ResectedColonTextValue = cmd.ExecuteScalar()
            If ResectedColonTextValue IsNot Nothing AndAlso IsDBNull(ResectedColonTextValue) = False Then
                Return CStr(ResectedColonTextValue)
            Else
                Return ""
            End If
        End Using
        Return Nothing
    End Function

    Public Function UpdateResectedColon(ByVal ProcedureId As Integer, ByVal ResectedColonId As String) As Integer
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_Procedures ")
        sql.Append("SET ResectedColonNo = @ResectedColonId ")
        sql.Append("WHERE ProcedureID = @ProcedureID ")

        ' updates the report summary (esp the region in the site name)
        sql.Append("EXEC procedure_summary_update @ProcedureID ; Exec Procedure_Updated @ProcedureID ; ")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@ResectedColonId", ResectedColonId))
            cmd.Connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using

        '### Now Update the PP field- which is in [ERS_ProceduresReporting]=> Use EntityFrame Work!
        Using db As New ERS.Data.GastroDbEntities
            Dim pr As New ERS.Data.ERS_ProceduresReporting
            pr = db.ERS_ProceduresReporting.Find(ProcedureId)
            pr.PP_ResectedColon = ResectedColonId
            db.SaveChanges()
            Update_ProceduresReporting(ProcedureId)
        End Using

    End Function

    Public Function GetEthnicOriginIdByName(ByVal ethnicOrigin As String) As Nullable(Of Integer)
        Dim sql As String = "SELECT EthnicOriginId FROM ERS_EthnicOrigins WHERE EthnicOrigin = @EthnicOrigin"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", ethnicOrigin.ToString()))

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If idObj IsNot Nothing Then
                Return CInt(idObj)
            End If
        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetGPs() As DataTable
        Return GetData("SELECT CASE WHEN NationalCode = 'G9999998' THEN 'Not Stated' ELSE CompleteName END AS FullName, * FROM ERS_GPS")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetGP(ByVal GPId As String) As DataTable
        Return GetData("SELECT * FROM ERS_VW_GPS WHERE GPId = " & GPId)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function SearchGP(searchTerm As String, searchField As String)
        Dim sSQL = "SELECT * FROM ERS_VW_GPS WHERE "
        Select Case searchField.ToLower()
            Case "all"
                sSQL += "GPCode LIKE '%" & searchTerm & "%' OR "
                sSQL += "CompleteName LIKE '%" & searchTerm & "%' OR "
                sSQL += "Practice LIKE '%" & searchTerm & "%'"
            Case "gp name"
                sSQL += "CompleteName LIKE '%" & searchTerm & "%'"
            Case "national code"
                sSQL += "GPCode LIKE '%" & searchTerm & "%'"
            Case "practice name"
                sSQL += "Practice LIKE '%" & searchTerm & "%'"
        End Select

        Dim dt = ExecuteSQL(sSQL)
        Return If(dt, New DataTable)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRoles(includeNotEditable As Boolean) As DataTable
        Return ExecuteSP("get_roles", New SqlParameter() {
                         New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = CInt(HttpContext.Current.Session("TrustId"))},
                         New SqlParameter With {.ParameterName = "@IncludeNotEditable", .SqlDbType = SqlDbType.Bit, .Value = BoolToBit(includeNotEditable)}
                         })
    End Function

    Private Function BoolToBit(boolToConvert As Boolean) As Integer
        If boolToConvert Then
            Return 1
        Else
            Return 0
        End If
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function CanViewAllUsers() As Boolean
        Try
            Dim userId = Integer.Parse(HttpContext.Current.Session("PKUserId"))

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("SELECT CASE WHEN COUNT(UserId) = 0 THEN 0 ELSE 1 END FROM ERS_Users WHERE (RoleId IN (SELECT convert(varchar(10), RoleId) FROM ERS_Roles WHERE RoleName='System Administrators') OR CanViewAllUserAudits = 1)  AND UserID = @UserID", connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@UserID", userId))
                connection.Open()
                Dim returnValue = Integer.Parse(cmd.ExecuteScalar())
                Return returnValue = 1
            End Using
        Catch ex As Exception
            Return False
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPagesByRole(ByVal RoleId As Integer, GroupID As Integer) As DataTable

        Dim dsPagesByRole As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("common_pagebyrole_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            'cmd.Parameters.Add("@RoleId", SqlDbType.Int).Value = RoleId
            cmd.Parameters.Add(New SqlParameter("@RoleId", RoleId))
            cmd.Parameters.Add(New SqlParameter("@GroupID", GroupID))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPagesByRole)
        End Using

        If dsPagesByRole.Tables.Count > 0 Then
            Return dsPagesByRole.Tables(0)
        End If
        Return Nothing

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetMenuByCategory(ByVal MenuCategory As String) As DataTable

        Dim dsPagesByRole As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT [MapID],[ParentID],[NodeName],[MenuCategory],[MenuUrl],[isViewer],[isDemoVersion],ISNULL([PageID],-1) AS PageID,[MenuIcon],[MenuTooltip] FROM ERS_MenuMap WHERE MenuCategory=@MenuCategory", connection)
            'cmd.Parameters.Add("@RoleId", SqlDbType.Int).Value = RoleId
            cmd.Parameters.Add(New SqlParameter("@MenuCategory", MenuCategory))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsPagesByRole)
        End Using

        If dsPagesByRole.Tables.Count > 0 Then
            Return dsPagesByRole.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function GetAccessLevels(ByVal userId As Integer, ByVal pageNames As String()) As Dictionary(Of String, Integer)
        Try

            Using connection As New SqlConnection(ConnectionStr)

                Dim ds As New DataSet
                Dim sql As New StringBuilder
                If userId = -9999 Then 'UserId -9999 for Unisoft
                    sql.Append("SELECT MAX(ISNULL(AccessLevel,0)) as AccessLevel FROM ERS_PagesByRole pr ")
                    sql.Append("INNER JOIN ERS_Pages p ON p.PageId = pr.PageId AND AppPageName IN @PageName  ")
                    sql.Append("WHERE RoleID = (SELECT TOP 1 RoleId FROM ERS_Roles WHERE RoleName = 'Unisoft') ")
                Else
                    sql.Append("DECLARE @RoleID VARCHAR(70), @GroupId INT ")
                    sql.Append("DECLARE @GlobalAdmin BIT = 0 ")
                    sql.Append("SELECT @RoleID=RoleID FROM ERS_Users where UserID = @UserID ")
                    sql.Append("SELECT [item] INTO #tmpRole FROM dbo.fnSplitString(@RoleID,',') ")
                    sql.Append("SELECT @GlobalAdmin=ISNULL((select 1 from ers_roles r where r.RoleId in (SELECT [item] FROM #tmpRole) and r.RoleName = 'GlobalAdmin'), 0) ")
                    sql.Append("SELECT MAX(ISNULL(AccessLevel,0)) as AccessLevel, AppPageName FROM ERS_PagesByRole pr ")
                    sql.Append("INNER JOIN  ERS_Users u ON pr.RoleId IN (SELECT [item] FROM #tmpRole) AND u.UserId = @UserId OR @GlobalAdmin = 1 ")
                    sql.Append("INNER JOIN ERS_Pages p ON p.PageId = pr.PageId AND AppPageName = @PageName ")
                    sql.Append("Group By AppPageName ")
                End If

                Dim cmd As New SqlCommand(sql.ToString(), connection)
                cmd.Parameters.Add(New SqlParameter("@UserId", userId))
                cmd.Parameters.Add(New SqlParameter("@PageName", String.Join(",", pageNames)))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(ds)

                If ds.Tables.Count > 0 Then
                    Dim dt = ds.Tables(0)

                    Dim dbRes = (From r As DataRow In dt.Rows
                                 Select New Dictionary(Of String, Integer) From {
                                     {r("AppPageName").ToString(), CInt(r("AccessLevel"))}})

                    Return dbRes
                End If
                'If Not IsDBNull(idObj) AndAlso Not IsNothing(idObj) Then
                '    Return CInt(idObj)
                'Else
                '    Return 0
                'End If

            End Using

        Catch ex As Exception

        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPageAccessLevel(ByVal userId As Integer, ByVal pageName As String) As Nullable(Of Integer)
        Try
            Dim allPageAccess As New Dictionary(Of String, Integer)
            If HttpContext.Current.Session("allPageAccess") Is Nothing Then
                Dim ds As New DataSet
                Using connection As SqlConnection = New SqlConnection(ConnectionStr)
                    Dim cmd As SqlCommand = New SqlCommand("GetAllPageAccessLevel", connection)
                    cmd.CommandType = CommandType.StoredProcedure

                    cmd.Parameters.Add(New SqlParameter("@UserId", userId))
                    cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))
                    cmd.Parameters.Add(New SqlParameter("@IsReadOnlyOverride", ConfigurationManager.AppSettings("ActiveDirectoryReadOnlyDefault")))

                    connection.Open()
                    Dim adapter = New SqlDataAdapter(cmd)
                    adapter.Fill(ds)
                End Using
                If ds.Tables.Count > 0 Then
                    Dim dt = ds.Tables(0)
                    Dim accessLevel As Integer
                    For Each row As DataRow In dt.Rows
                        If String.IsNullOrEmpty(row("AccessLevel").ToString()) Then
                            accessLevel = 0
                        Else
                            accessLevel = CInt(row("AccessLevel").ToString())
                        End If
                        allPageAccess.Add(row("AppPageName").ToString(), accessLevel)
                    Next
                    HttpContext.Current.Session("AllPageAccess") = allPageAccess
                End If
            Else

                allPageAccess = CType(HttpContext.Current.Session("AllPageAccess"), Dictionary(Of String, Integer))
            End If
            If allPageAccess.ContainsKey(pageName) Then
                Return allPageAccess(pageName)
            Else
                Return 0
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetPageAccessLevel: " + ex.ToString(), ex)
            Return 0
        End Try
    End Function
    Public Function InsertPage(ByVal PageName As String, ByVal AppPageName As String) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("DECLARE @max int = (select max(pageID) FROM ERS_Pages);IF NOT EXISTS(SELECT 1 FROM ERS_Pages WHERE AppPageName = @AppPageName) INSERT INTO ERS_Pages (PageID,PageName,AppPageName) VALUES (@max+1,@PageName,@AppPageName)", connection)
            cmd.Parameters.Add(New SqlParameter("@AppPageName", AppPageName))
            cmd.Parameters.Add(New SqlParameter("@PageName", PageName))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using
    End Function

    Public Function InsertFeedback(ByVal Fullname As String, ByVal EmailAddress As String, FeedbackText As String) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("INSERT INTO ERS_Feedback (Fullname,EmailAddress,FeedbackText) VALUES (@Fullname,@EmailAddress,@FeedbackText)", connection)
            cmd.Parameters.Add(New SqlParameter("@Fullname", Fullname))
            cmd.Parameters.Add(New SqlParameter("@EmailAddress", EmailAddress))
            cmd.Parameters.Add(New SqlParameter("@FeedbackText", FeedbackText))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            Return cmd.ExecuteNonQuery
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveGP(ByVal GPId As Nullable(Of Integer),
                           ByVal Title As String,
                           ByVal Initials As String,
                           ByVal ForeName As String,
                           ByVal Surname As String,
                           ByVal PracticeName As String,
                           ByVal Address As String,
                           ByVal Telephone As String,
                           ByVal Suppressed As Boolean) As Integer

        Dim affectedGPId As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("gp_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            If GPId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GPId", GPId))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPId", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Title", Title))
            cmd.Parameters.Add(New SqlParameter("@Initials", Initials))
            cmd.Parameters.Add(New SqlParameter("@ForeName", ForeName))
            cmd.Parameters.Add(New SqlParameter("@Surname", Surname))
            cmd.Parameters.Add(New SqlParameter("@PracticeName", PracticeName))
            cmd.Parameters.Add(New SqlParameter("@Address", Address))
            cmd.Parameters.Add(New SqlParameter("@Telephone", Telephone))
            cmd.Parameters.Add(New SqlParameter("@Suppressed", Suppressed))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            affectedGPId = CInt(cmd.ExecuteScalar())
        End Using

        Return affectedGPId
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTherapeuticBandingPiles(ByVal siteId As Integer) As DataTable
        Return GetData("SELECT BandingPiles, BandingNum FROM ERS_UpperGITherapeutics WHERE SiteId=" & siteId)
    End Function
    Friend Sub Update_ogd_kpi_stricture_perforation(siteId As Integer)
        DataAccess.ExecuteScalerSQL("ogd_kpi_stricture_perforation", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@SiteId", siteId)})
    End Sub
    Friend Sub Update_therapeutics_ercp_summary(siteId As Integer, therapeuticId As Integer)
        DataAccess.ExecuteScalerSQL("therapeutics_ercp_summary_update", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@TherapeuticId", therapeuticId),
                                        New SqlParameter("@SiteId", siteId)})
    End Sub
    Friend Sub Update_sites_summary(siteId As Integer)
        DataAccess.ExecuteScalerSQL("sites_summary_update", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@SiteId", siteId)})
    End Sub
    Friend Sub Update_Upper_GI_Therapeutic(siteId As Integer)
        DataAccess.ExecuteScalerSQL("Upper_GI_Therapeutic_Update", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@site_id", siteId)})
    End Sub
    Friend Sub Update_abnormalities_colon_lesions_summary(siteId As Integer)
        DataAccess.ExecuteScalerSQL("abnormalities_colon_lesions_summary_update", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@SiteId", siteId)})
    End Sub
    Friend Sub Update_ERS_Extent_Limiting_Factors(procedureID As Integer)
        DataAccess.ExecuteScalerSQL("ERS_Extent_Limiting_Factors", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@procedureID", procedureID)})
    End Sub
    Friend Sub Update_ProceduresReporting(procedureID As Integer)
        DataAccess.ExecuteScalerSQL("ProceduresReporting_Updated", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@ProcedureId", procedureID)})
    End Sub
    Friend Sub Update_Procedure(procedureID As Integer)
        DataAccess.ExecuteScalerSQL("Procedure_Updated", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@ProcedureId", procedureID)})
    End Sub
    Friend Sub Update_ogd_followup_summary(procedureID As Integer)
        DataAccess.ExecuteScalerSQL("ogd_followup_summary_update", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@ProcedureId", procedureID)})
    End Sub
    Friend Sub Update_ogd_premedication_summary(procedureID As Integer)
        DataAccess.ExecuteScalerSQL("ogd_premedication_summary_update", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@ProcedureId", procedureID)})
    End Sub
    Friend Sub Update_UpperGIQA(procedureID As Integer)
        DataAccess.ExecuteScalerSQL("UpperGIQA", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@procedure_id", procedureID)})
    End Sub
    Friend Sub Visualisation_DuplicateCheck(procedureID As Integer)
        DataAccess.ExecuteScalerSQL("Visualisation_DuplicateCheck", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@procedure_id", procedureID)})
    End Sub
    Public Sub saveStentInsertionDetails(therapeuticId As Integer, stentInsertion As Boolean, SiteId As Integer, StentInsertionQty As Integer, InsertionDetails As List(Of StentInsertion))
        Try
            Dim sql As New StringBuilder
            sql.Append("DELETE FROM ERS_ERCPTherapeuticStentInsertions WHERE TherapeuticId IN (SELECT ee.id FROM dbo.ERS_ERCPTherapeutics ee WHERE ee.SiteId = @SiteId AND ee.StentInsertion=0)") 'clean up for related site only
            sql.Append("DELETE FROM ERS_ERCPTherapeuticStentInsertions WHERE TherapeuticId = @TherapeuticId; ") 'delete for this particular therapeutic id. If theres insertion details that need to be attached, will do it down below. This handles the SI checkbox previously being ticked and then being unticked

            If stentInsertion AndAlso (InsertionDetails IsNot Nothing AndAlso (InsertionDetails.Count > 0 And StentInsertionQty > 0)) Then
                sql.Append("INSERT INTO ERS_ERCPTherapeuticStentInsertions (TherapeuticId, StentInsertionType, StentInsertionLength, StentInsertionDiameter, StentInsertionDiameterUnits) VALUES ")

                For i = 0 To InsertionDetails.Count - 1 'only up to the qty of insertions stated.. incase user filled out a certain amount by the lowered the QTY without updating and saving
                    With InsertionDetails(i)
                        sql.Append("(@TherapeuticId, " & .StentInsertionType & ", " & .StentInsertionLength & ", " & .StentInsertionDiameter & ", " & .StentInsertionDiameterUnits & "), ")
                    End With
                Next
            End If
            sql.Append("EXEC therapeutics_ercp_summary_update @TherapeuticId, @SiteId; ")
            sql.Append("EXEC sites_summary_update @SiteId; ")
            Dim sqlCommand = TransactionSQL(sql.ToString().Remove(sql.ToString().Length - 2))


            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sqlCommand, connection)

                cmd.Parameters.Add(New SqlParameter("@TherapeuticId", therapeuticId))
                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception

        End Try

    End Sub
#End Region

#Region "Lists"

    Public Function GetList(ByVal listDescription As String, Optional bOrderByDesc As Boolean = False) As DataTable
        Dim dsResult As New DataSet()
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_list_procedure", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ListDescription", listDescription))
            cmd.Parameters.Add(New SqlParameter("@OrderByDesc", bOrderByDesc))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using
        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetList_Arr(ByVal listDescription As String) As DataTable
        Return GetList(listDescription)
    End Function

    Public Function GetDistinctList() As DataTable
        'Dim sql As String = "SELECT * from ERS_Roles WHERE RoleName <> 'Unisoft'"
        Return ExecuteSP("get_roles", New SqlParameter() {
                         New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = CInt(HttpContext.Current.Session("TrustId"))},
                         New SqlParameter With {.ParameterName = "@IncludeNotEditable", .SqlDbType = SqlDbType.Bit, .Value = BoolToBit(True)}
                         })
        'Return GetData(sql)
    End Function

    Public Function GetDistinctListPage() As DataTable
        Dim sql As String = "SELECT 0 AS PageId, '*Default*' AS PageName UNION SELECT -1 AS PageId, '' AS PageName UNION SELECT PageId, PageName FROM ERS_Pages"
        Return GetData(sql)
    End Function
    Public Function GetDistinctCategory() As DataTable
        Dim sql As String = "SELECT DISTINCT (MenuCategory) FROM ERS_MenuMap"
        Return GetData(sql)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUniqueListDescription() As DataTable
        Return GetData("SELECT DISTINCT(ListDescription) AS ListDescription FROM ERS_Lists WHERE ReadOnly = 0")
        'Return GetData("SELECT DISTINCT(ListDescription) AS ListDescription FROM ERS_Lists WHERE ISNULL(Suppressed,0) = 0")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetFieldUniqueFormName() As DataTable
        Return GetData("SELECT DISTINCT p.PageAlias AS FormName, p.PageId FROM ERS_FieldLabels f INNER JOIN ERS_Pages p ON f.PageID = p.PageId ORDER BY FormName")
    End Function

    Public Function GetCountryLabel(ByVal label As String) As String
        'Using connection As New SqlConnection(ConnectionStr)
        '    Dim cmd As New SqlCommand("country_label_select", connection)
        '    cmd.CommandType = CommandType.StoredProcedure
        '    cmd.Parameters.Add(New SqlParameter("@label", label))
        '    connection.Open()
        '    Return CStr(cmd.ExecuteScalar())
        'End Using
        'Return ""

        Dim returnStr As String = ""
        Select Case label
            Case "CNN"
                returnStr = "Hospital no"
            Case "CNN1"
                returnStr = "hospital number"
            Case "DHA"
                returnStr = "DHA Code"
            Case "District"
                returnStr = "District"
            Case "Endo"
                returnStr = "Endoscopist"
            Case "Endoprn"
                returnStr = "End"
            Case "Forename"
                returnStr = "Forenames"
            Case "GP"
                returnStr = "GP"
            Case "GP1"
                returnStr = "GP"
            Case "List"
                returnStr = "List consultant"
            Case "Listprn"
                returnStr = "Lst cons"
            Case "NHSNo"
                returnStr = Session(Constants.SESSION_HEALTH_SERVICE_NAME) + " No"
            Case "RefHosp"
                returnStr = "Referring Hospital"
        End Select
        Return returnStr
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertListItem(ByVal listDescription As String, ByVal itemName As String) As Integer

        If Trim(itemName) = "" Then Return 0


        Using connection As New SqlConnection(ConnectionStr)
            Dim value As Object
            Dim cmd As New SqlCommand("add_new_list_item", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@listDescription", listDescription))
            cmd.Parameters.Add(New SqlParameter("@itemName", itemName))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            value = cmd.ExecuteScalar()
            If Not IsDBNull(value) Then Return CInt(value)
            Return 0
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateItemList(ByVal ListId As Integer, ByVal ListItemText As String) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                db.ERS_List_UpdateValue(ListId, Nothing, ListItemText, False, LoggedInUserId)
            End Using
            Return 1
        Catch ex As Exception
            Return 0
        End Try

        'Dim sql As New StringBuilder

        'sql.Append("UPDATE ERS_Lists ")
        'sql.Append("SET ListItemText=@ListItemText ")
        'sql.Append("WHERE ListId=@ListId")

        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand(sql.ToString(), connection)
        '    cmd.CommandType = CommandType.Text
        '    cmd.Parameters.Add(New SqlParameter("@ListId", ListId))
        '    cmd.Parameters.Add(New SqlParameter("@ListItemText", ListItemText))

        '    connection.Open()
        '    Return cmd.ExecuteNonQuery()
        'End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SuppressItemList(ByVal ListId As Integer, ByVal SuppressItem As Boolean) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = db.ERS_List_UpdateValue(ListId, vbNullString, vbNullString, SuppressItem, LoggedInUserId)
            End Using
            Return 1
        Catch ex As Exception
            Return 0
        End Try

        'Dim sql As New StringBuilder

        'sql.Append("UPDATE ERS_Lists ")
        'sql.Append("SET Suppressed=@SuppressItem ")
        'sql.Append("WHERE ListId=@ListId")

        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand(sql.ToString(), connection)
        '    cmd.CommandType = CommandType.Text
        '    cmd.Parameters.Add(New SqlParameter("@ListId", ListId))
        '    cmd.Parameters.Add(New SqlParameter("@SuppressItem", SuppressItem))
        '    connection.Open()
        '    Return cmd.ExecuteNonQuery()
        'End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetJobTitles() As DataTable
        Dim dsJobTitles As New DataSet
        Dim sql As String = "SELECT * FROM ERS_JobTitles ORDER BY Description "

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsJobTitles)
        End Using

        If dsJobTitles.Tables.Count > 0 Then
            Return dsJobTitles.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertJobTitle(ByVal title As String) As Integer
        Dim sql As New StringBuilder
        sql.Append("INSERT INTO ERS_JobTitles ([Description], [WhoCreatedId], [WhenCreated]) ")
        sql.Append("VALUES (@Title, @LoggedInUserId, GETDATE()) ")
        sql.Append("SELECT @@IDENTITY ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@Title", title))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertRole(ByVal RoleName As String) As Integer
        Dim sql As New StringBuilder
        sql.Append("INSERT INTO ERS_Roles ([RoleName], TrustId, IsEditable, WhoCreatedId, WhenCreated) ")
        sql.Append("VALUES (@RoleName, @TrustId, 1, @LoggedInUserId, GETDATE()) ")
        sql.Append("SELECT @@IDENTITY ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoleName", RoleName))
            cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateRoles(ByVal roleId As Integer,
                                         ByVal roleName As String) As Integer
        Dim sql As String = "UPDATE ERS_Roles SET RoleName=@Rolename, TrustId=@TrustId, WhoUpdatedId=@LoggedInUserId, WhenUpdated=GETDATE() WHERE RoleId=@RoleId"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoleId", roleId))
            cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))
            cmd.Parameters.Add(New SqlParameter("@Rolename", roleName))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Delete, False)>
    Public Function DeleteRole(ByVal roleId As Integer) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("DELETE FROM ERS_Roles WHERE roleId = @RoleId AND TrustId = @TrustId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RoleId", roleId))
            cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertPagesByRole(ByVal sCommand As String) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sCommand, connection)
            cmd.CommandType = CommandType.Text
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Sub InsertPagesByRole(roleId As Integer, roleAccessLevels As Dictionary(Of Integer, String), Optional updateAll As Boolean = False)

        Using db As New ERS.Data.GastroDbEntities
            Dim pageIDs = roleAccessLevels.Select(Function(x) x.Key).ToList
            Dim roleList = db.ERS_PagesByRole.Where(Function(x) pageIDs.Contains(x.PageId) And x.RoleId = roleId)
            If Not updateAll And roleList.Count > 0 Then
                For Each role In roleList
                    If Not role.AccessLevel = roleAccessLevels(role.PageId) Then
                        role.AccessLevel = roleAccessLevels(role.PageId)
                        role.WhoUpdatedId = LoggedInUserId
                        role.WhenUpdated = Now
                        db.ERS_PagesByRole.Attach(role)
                        db.Entry(role).State = Entity.EntityState.Modified
                    End If
                Next
            Else
                For Each pageId In roleAccessLevels.Keys
                    Dim role = db.ERS_PagesByRole.Where(Function(x) x.PageId = pageId And x.RoleId = roleId).FirstOrDefault
                    If role Is Nothing Then role = New ERS_PagesByRole

                    role.PageId = pageId
                    role.RoleId = roleId
                    role.AccessLevel = roleAccessLevels(pageId)

                    If role.PagesByRoleId = 0 Then
                        role.WhoCreatedId = LoggedInUserId
                        role.WhenCreated = Now
                        db.ERS_PagesByRole.Add(role)
                    Else
                        role.WhoUpdatedId = LoggedInUserId
                        role.WhenUpdated = Now
                        db.ERS_PagesByRole.Attach(role)
                        db.Entry(role).State = Entity.EntityState.Modified
                    End If
                Next
            End If

            db.SaveChanges()
        End Using
    End Sub
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedureTypes(ByVal productType As Integer) As DataTable
        Dim dsProcedureTpes As New DataSet
        Dim sql As String = "SELECT *, CASE WHEN Suppressed = 1 THEN 0 ELSE 1 END AS Enabled FROM ERS_ProcedureTypes WHERE ProductTypeId = @ProductTypeId AND Suppressed = 0"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProductTypeId", productType))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsProcedureTpes)
        End Using

        If dsProcedureTpes.Tables.Count > 0 Then
            Return dsProcedureTpes.Tables(0)
        End If
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllProcedureTypes() As DataTable
        Dim dsProcedureTpes As New DataSet
        Dim sql As String = "SELECT * FROM ERS_ProcedureTypes WHERE Suppressed = 0"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsProcedureTpes)
        End Using

        If dsProcedureTpes.Tables.Count > 0 Then
            Return dsProcedureTpes.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetNonGIProcedures() As DataTable
        Dim dsProcedureTpes As New DataSet
        Dim sql As String = "SELECT *, CASE WHEN Suppressed = 1 THEN 0 ELSE 1 END AS Enabled FROM ERS_ProcedureTypes WHERE IsGI = 0 AND Suppressed = 0"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsProcedureTpes)
        End Using

        If dsProcedureTpes.Tables.Count > 0 Then
            Return dsProcedureTpes.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRegionsForProcedureType(procedureTypeId As String) As DataTable
        Return ExecuteSP("regions_select", New SqlParameter() {New SqlParameter("@procedureTypeId", procedureTypeId)})
    End Function

    Public Function GetAbnormalitiesForProcedure(siteId As Integer) As DataTable
        Return ExecuteSP("SelectAbnormalitiesForSite", New SqlParameter() {New SqlParameter("@SiteId", siteId)})
    End Function

    Friend Sub SaveOtherAbnormalitySettings(otherAbnormalityId As String, abnormality As String, summary As String, diagnosis As String, procedureTypeId As Integer, regions As String, active As Boolean)
        DataAccess.ExecuteScalerSQL("OtherAbnormalities_insert", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@OtherId", otherAbnormalityId),
                                        New SqlParameter("@Abnormality", abnormality),
                                        New SqlParameter("@Summary", summary),
                                        New SqlParameter("@Diagnoses", diagnosis),
                                        New SqlParameter("@ProcedureTypeId", procedureTypeId),
                                        New SqlParameter("@RegionsString", regions),
                                        New SqlParameter("@Active", active)})
    End Sub

    Friend Sub SaveOtherAbnormality(siteId As Integer, abnormalityList As String)
        DataAccess.ExecuteScalerSQL("abnormalities_other_save", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@SiteId", siteId),
                                        New SqlParameter("@AbnormalityList", abnormalityList)})
    End Sub

    Friend Function GetRegionsForOtherAbnormalities(OtherAbnormalityid As Integer) As DataTable
        Return ExecuteSP("OtherAbnormalityRegions_select", New SqlParameter() {New SqlParameter("@otherAbnormalityId", OtherAbnormalityid)})
    End Function


    Public Function GetOtherAbnormalities(OtherAbnormalityid As String) As DataTable
        Return ExecuteSP("OtherAbnormality_select", New SqlParameter() {New SqlParameter("@otherAbnormalityId", OtherAbnormalityid)})
    End Function

    Public Function GetTrust(trustId As Integer) As DataTable
        Return ExecuteSP("trust_select", New SqlParameter() {New SqlParameter("@TrustId", trustId)})
    End Function

    Friend Sub SaveTrust(trustId As String, trustName As String)
        DataAccess.ExecuteScalerSQL("trust_insert", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@trustId", trustId),
                                        New SqlParameter("@TrustName", trustName)})
    End Sub

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientWards(operatingHospitalId As Integer) As DataTable
        Return ExecuteSP("GetWards", New SqlParameter() {New SqlParameter("@OperatingHospital", operatingHospitalId)})

        'Return GetList("Ward")
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientWards() As DataTable
        Return ExecuteSP("GetWards", New SqlParameter() {New SqlParameter("@OperatingHospital", Session("OperatingHospitalID"))})

        'Return GetList("Ward")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientStatuses() As DataTable
        Return GetList("Patient Status")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetBowelPreparationQuality() As DataTable
        Return GetList("Bowel_Preparation_Quality")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientTypes() As DataTable
        Return GetList("Patient Type")
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetProcedureCategories() As DataTable
    '    Return GetList("Procedure Category", False)
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetListType() As DataTable
    '    Return GetList("List Type", False)
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetEndoscopist1Role() As DataTable
    '    Return GetList("Endoscopist1 Role", False)
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetEndoscopist2Role() As DataTable
    '    Return GetList("Endoscopist2 Role", False)
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetForcepSerialNos() As DataTable
    '    Return GetList("Forcep Serial Numbers")
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSurgicalProcedures() As DataTable
        Return GetList("Surgical Procedures")
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetSurgeryFollowUpProc() As DataTable
    '    Return GetList("Surgery follow up proc Upper GI")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetDamagingDrugs() As DataTable
    '    Return GetList("Indications_Potential_Damaging_Drugs")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetRectal() As DataTable
    '    Return GetList("Indications Colon Rectal Bleeding")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function ERCPFollowPrev() As DataTable
    '    Return GetList("Follow up disease/proc ERCP")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetAlteredBowel() As DataTable
    '    Return GetList("Indications Colon Altered Bowel Habit")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetBowelFormation() As DataTable
    '    Return GetList("Bowel_Preparation")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInsertionComfirmedBy() As DataTable
    '    Return GetList("Colon_Extent_Insertion_Comfirmed_By")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInsertionLimitedBy() As DataTable
    '    Return GetList("Colon_Extent_Insertion_Limited_By")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetDifficultyEncountered() As DataTable
    '    Return GetList("Colon_Extent_Difficulty_Encountered")
    'End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDropDownList(FieldName As String) As DataTable
        Return GetList(FieldName)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiseaseFollowUpProc(ByVal procedureTypeId As Integer) As String
        If procedureTypeId = ProcedureType.Gastroscopy Then
            Return "Follow up disease/proc Upper GI"
        ElseIf procedureTypeId = ProcedureType.ERCP Then
            Return "Follow up disease/proc ERCP"
        ElseIf procedureTypeId = ProcedureType.Colonoscopy Then
            Return "Follow up disease/proc Colon"
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetFutherProcedures(ByVal procedureTypeId As Integer) As String
        If procedureTypeId = ProcedureType.Gastroscopy Then
            Return "Further procedure"
        ElseIf procedureTypeId = ProcedureType.ERCP Then
            Return "Further ERCP procedure"
        ElseIf procedureTypeId = ProcedureType.Bronchoscopy Or procedureTypeId = ProcedureType.EBUS Or procedureTypeId = ProcedureType.Thoracoscopy Then
            Return "Further Broncho procedure"
        ElseIf procedureTypeId = ProcedureType.Flexi Then
            Return "Further Cysto procedure"
        Else
            Return "Further procedure"
        End If
        Return Nothing
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetFutherProcedurePeriods() As DataTable
    '    Return GetList("Further procedure period")
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetFollowupReferredTo(procedureTypeId As Integer) As String
        If procedureTypeId = ProcedureType.Bronchoscopy Or procedureTypeId = ProcedureType.EBUS Or procedureTypeId = ProcedureType.Thoracoscopy Then
            Return "Broncho Return or referred to"
        End If
        Return "Return or referred to"
    End Function
    Public Function GetConsultantList() As DataTable
        Dim ds As New DataAccess
        Return ds.GetConsultantsLst(Nothing, Nothing, 0)
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetReviewLocations(procedureTypeId As Integer) As String
        If procedureTypeId = ProcedureType.Bronchoscopy Or procedureTypeId = ProcedureType.EBUS Or procedureTypeId = ProcedureType.Thoracoscopy Then
            Return "Review Broncho"
        End If
        Return "Review"
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetReviewPeriods() As DataTable
    '    Return GetList("Review period")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetPatientNotCopiedReason() As DataTable
    '    Return GetList("PatientNotCopiedReason")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInjectionTypes() As DataTable
    '    Return GetList("Agent Upper GI")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStentInsertionTypes() As DataTable
    '    Return GetList("Therapeutic Stent Insertion Types")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStentInsertionStomachTypes() As DataTable
    '    Return GetList("Therapeutic Stomach Stent Insertion Types")
    'End Function


    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInsertionUnits() As DataTable
    '    Return GetList("Gastrostomy PEG units")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetInsertionTypes() As DataTable
    '    Return GetList("Gastrostomy PEG type")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStentInsertionDiaUnits() As DataTable
    '    Return GetList("Oesophageal dilatation units")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStentRemovalTechnique() As DataTable
    '    Return GetList("Therapeutic Stent Removal Technique")
    'End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetEMRFluid() As DataTable
    '    Return GetList("Therapeutic EMR Fluid")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetMarkingType() As DataTable
    '    Return GetList("Abno marking")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetOesophagealDilator() As DataTable
    '    Return GetList("Oesophageal dilator")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetStoneRemovalUsing() As DataTable
    '    Return GetList("ERCP stone removal method")
    'End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetCystPunctureDevice() As DataTable
    '    Return GetList("Cyst Puncture device")
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDeliveryMethods() As DataTable
        Return GetList("Premedication Delivery Method")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetMarkingTypes() As DataTable
        Return GetList("Abno marking")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetMedicationFrequency() As DataTable
        Return GetList("Medication_Frequency")
    End Function

    Public Function rGetUsername(ByVal ProcedureID As String) As String
        Dim value As Object
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT isnull(pt.Surname,'') + ', '+ isnull(pt.Forename1,'') as Name FROM ERS_Patients pt INNER JOIN ERS_Procedures p ON pt.[PatientId]=p.PatientId WHERE p.ProcedureId=@ProcedureId"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            value = mycmd.ExecuteScalar()
            If Not IsDBNull(value) Then Return CStr(value)
        End Using
        Return Nothing
    End Function
    Public Function rGetReferralConsultantNo(ByVal ProcedureID As String) As String
        Dim value As Object
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT ReferralConsultantNo FROM ERS_Procedures  WHERE ProcedureId=@ProcedureId"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            value = mycmd.ExecuteScalar()
            If Not IsDBNull(value) Then Return CStr(value)
        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetInstruments(ByVal procedureTypeId As Integer) As String
        Select Case procedureTypeId
            Case ProcedureType.Gastroscopy
                Return "Instrument Upper GI"
            Case ProcedureType.EUS_OGD, ProcedureType.EUS_HPB
                Return "Instrument EUS"
            Case ProcedureType.ERCP
                Return "Instrument ERCP"
            Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy, ProcedureType.Proctoscopy
                Return "Instrument ColonSig"
            Case ProcedureType.Antegrade
                Return "Instrument Antegrade"
            Case ProcedureType.Retrograde
                Return "Instrument Retrograde"
            Case ProcedureType.Bronchoscopy, ProcedureType.EBUS, ProcedureType.Thoracoscopy
                Return "Instrument Thoracic"
            Case Else
                Return Nothing
        End Select
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedureInstruments(ByVal procedureId As Integer) As DataTable
        Dim sql As String = "SELECT ISNULL(Instrument1,0) AS Instrument1, ISNULL(Instrument2,0) AS Instrument2, ISNULL(ScopeGuide,0) AS ScopeGuide, " &
                            "ISNULL(PancreasDivisum,0) AS PancreasDivisum, ISNULL(BiliaryManometry,0) AS BiliaryManometry, ISNULL(PancreaticManometry,0) AS PancreaticManometry " &
                            "FROM ERS_Procedures " &
                            "WHERE ProcedureId = '" & procedureId & "' "
        Return GetData(sql)
        '### TO DO: Return Procedure object-> using StoredProc!
    End Function
#End Region

#Region "Users"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUser(ByVal userId As Integer) As DataTable
        Dim dsUser As New DataSet
        'Dim sql As New StringBuilder
        'sql.Append("SELECT u.*, jt.Description AS JobTitle, ")
        'sql.Append(" CASE AccessRights WHEN 1 THEN 'Read Only' WHEN 2 THEN 'Regular' WHEN 3 THEN 'Administrator' ELSE '' END AS Permissions ")
        'sql.Append("FROM ERS_Users u ")
        'sql.Append("LEFT JOIN ERS_JobTitles jt ON u.JobTitleID = jt.JobTitleID ")
        'sql.Append("WHERE UserId = @UserId")

        'Using connection As New SqlConnection(ConnectionStr)
        '    Dim cmd As New SqlCommand(sql.ToString(), connection)
        '    cmd.CommandType = CommandType.Text
        '    cmd.Parameters.Add(New SqlParameter("@UserId", userId))

        '    Dim adapter = New SqlDataAdapter(cmd)

        '    connection.Open()
        '    adapter.Fill(dsUser)
        'End Using

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_user", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsUser)
        End Using

        If dsUser.Tables.Count > 0 Then
            Return dsUser.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUserByUserName(ByVal userName As String) As DataTable
        Try
            Dim dsUser As New DataSet
            'Dim sql As String = "SELECT * FROM ERS_Users eu INNER JOIN dbo.ERS_UserOperatingHospitals euoh ON eu.UserID = euoh.UserId WHERE eu.UserName = @UserName AND euoh.OperatingHospitalId = @OperatingHospitalId"
            'Dim sql As New StringBuilder
            'sql.AppendLine("DECLARE @RoleID VARCHAR(70)")
            'sql.AppendLine("SELECT @RoleID=RoleId FROM ERS_Users eu ")
            'sql.AppendLine("LEFT JOIN dbo.ERS_UserOperatingHospitals euoh ON eu.UserID = euoh.UserId AND euoh.OperatingHospitalId = @OperatingHospitalId")
            'sql.AppendLine("WHERE eu.UserName = @UserName")
            'sql.AppendLine("DECLARE @GlobalAdmin BIT = 0")
            'sql.AppendLine("Select [item] INTO #tmpRole FROM dbo.fnSplitString(@RoleID,',') ")
            'sql.AppendLine("Select @GlobalAdmin=ISNULL((select 1 from ers_roles r where r.RoleId in (SELECT [item] FROM #tmpRole) and r.RoleName = 'GlobalAdmin'), 0)")
            'sql.AppendLine("DECLARE @isAdmin BIT = 0")
            'sql.AppendLine("IF EXISTS (select 1 from ers_roles r where r.RoleId in (SELECT [item] FROM #tmpRole) and LOWER(r.RoleName) LIKE '%admin%') SET @isAdmin = 1")
            'sql.AppendLine("Select TOP 1 *, @isAdmin AS IsAdmin FROM ERS_Users eu")
            'sql.AppendLine("Left JOIN dbo.ERS_UserOperatingHospitals euoh ON eu.UserID = euoh.UserId WHERE eu.UserName = @UserName AND (euoh.OperatingHospitalId = @OperatingHospitalId OR @GlobalAdmin = 1)")


            Using connection As New SqlConnection(ConnectionStr)
                'Dim cmd As New SqlCommand(sql.ToString(), connection)
                Dim cmd As New SqlCommand("GetUserByUserName", connection)
                cmd.CommandType = CommandType.StoredProcedure
                'cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@UserName", userName))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", Session("OperatingHospitalID")))

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsUser)
            End Using

            If dsUser.Tables.Count > 0 Then
                Return dsUser.Tables(0)
            End If

            Return Nothing

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetUserByUserName: " + ex.ToString(), ex)
            Return Nothing
        End Try

    End Function

    Public Sub LoginFailure(sUser As String, sReason As String)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("LogLoginFail", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@UserId", sUser))
                cmd.Parameters.Add(New SqlParameter("@Reason", sReason))
                connection.Open()
                cmd.ExecuteScalar()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error logging fail login", ex)
        End Try
    End Sub

    Public Sub LoginSuccess(sUser As String)
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("LogLoginSuccess", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@UserId", sUser))
                connection.Open()
                cmd.ExecuteScalar()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error logging fail login", ex)
        End Try
    End Sub

    Public Function GetNonGIConsultants(operatingHospitalIds As String) As DataTable
        Try
            Dim dsResult As New DataSet
            Dim sSQL = "SELECT eu.UserID, eu.Title, eu.Forename, eu.Surname, ISNULL(eu.Title, '') + ' ' + eu.Forename + ' ' + eu.Surname as Consultant, eu.Suppressed, eu.GMCCode, ejt.Description as JobTitle, ISNULL(eu.JobTitleId,0) AS JobTitleId
                        FROM dbo.ERS_Users eu
	                        LEFT JOIN dbo.ERS_JobTitles ejt ON eu.JobTitleID = ejt.JobTitleID
                             INNER JOIN dbo.ERS_UserOperatingHospitals euoh ON eu.UserID = euoh.UserId 
                        WHERE ISNULL(eu.IsGIConsultant, 1) = 0 and euoh.OperatingHospitalId IN (" & operatingHospitalIds & ")"

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sSQL, connection)
                cmd.CommandType = CommandType.Text

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetNonGIConsultant(userId As Integer) As DataTable
        Try
            Dim dsResult As New DataSet

            Dim sSQL = "SELECT eu.UserID, eu.Title, eu.Forename, eu.Surname, ISNULL(eu.Title, '') + ' ' + eu.Forename + ' ' + eu.Surname as Consultant, eu.Suppressed, eu.GMCCode, ejt.Description as JobTitle, eu.JobTitleId
                        FROM dbo.ERS_Users eu
	                        LEFT JOIN dbo.ERS_JobTitles ejt ON eu.JobTitleID = ejt.JobTitleID
                        WHERE UserId=@UserId"

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sSQL, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@UserId", userId))
                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsResult)
            End Using

            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertUser(ByVal username As String,
                               ByVal expiresOn As Date,
                               ByVal title As String,
                               ByVal forename As String,
                               ByVal surname As String,
                               ByVal initials As String,
                               ByVal qualifications As String,
                               ByVal isGIConsultant As Boolean,
                               ByVal jobTitleId As Integer,
                               ByVal RoleID As String,
                               ByVal canRunAK As Boolean,
                               ByVal isListConsultant As Boolean,
                               ByVal isEndoscopist1 As Boolean,
                               ByVal isEndoscopist2 As Boolean,
                               ByVal isAssistantOrTrainee As Boolean,
                               ByVal isNurse1 As Boolean,
                               ByVal isNurse2 As Boolean,
                               ByVal suppressed As Boolean,
                               ByVal showTooltips As Boolean,
                               ByVal gmcCode As String,
                               ByVal canEditDropdowns As Boolean,
                               ByVal canOverbookLists As Boolean,
                               ByVal CanViewAllUserAudits As Boolean,
                               ByRef userId As Integer,
                               ByVal GeneralLibrary As Boolean,
                               ByVal CanOverrideSchedule As Boolean,
                               ByVal IsTrainee As Boolean
                               ) As Integer
        Try

            Dim sCloneUsername As String = username 'Use different variable for GetPasswordASC as the function is uppercasing username (byref) 
            Dim dsUser As New DataSet

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("insert_user", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@Username", username))
                If Year(expiresOn) < 5 Then
                    cmd.Parameters.Add(New SqlParameter("@ExpiresOn", "01/01/3999"))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ExpiresOn", expiresOn))
                End If
                cmd.Parameters.Add(New SqlParameter("@Password", Utilities.GetPasswordASC(sCloneUsername)))
                cmd.Parameters.Add(New SqlParameter("@Title", title))
                cmd.Parameters.Add(New SqlParameter("@Forename", forename))
                cmd.Parameters.Add(New SqlParameter("@Surname", surname))
                If initials IsNot Nothing Then
                    cmd.Parameters.Add(New SqlParameter("@Initials", initials))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Initials", SqlTypes.SqlString.Null))
                End If
                If qualifications IsNot Nothing Then
                    cmd.Parameters.Add(New SqlParameter("@Qualifications", qualifications))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Qualifications", SqlTypes.SqlString.Null))
                End If

                cmd.Parameters.Add(New SqlParameter("@IsGI", isGIConsultant))
                cmd.Parameters.Add(New SqlParameter("@JobTitleId", jobTitleId))
                cmd.Parameters.Add(New SqlParameter("@RoleID", RoleID))
                cmd.Parameters.Add(New SqlParameter("@CanRunAK", canRunAK))
                cmd.Parameters.Add(New SqlParameter("@IsListConsultant", isListConsultant))
                cmd.Parameters.Add(New SqlParameter("@IsEndoscopist1", isEndoscopist1))
                cmd.Parameters.Add(New SqlParameter("@IsEndoscopist2", isEndoscopist2))
                cmd.Parameters.Add(New SqlParameter("@IsAssistantOrTrainee", isAssistantOrTrainee))
                cmd.Parameters.Add(New SqlParameter("@IsNurse1", isNurse1))
                cmd.Parameters.Add(New SqlParameter("@IsNurse2", isNurse2))
                cmd.Parameters.Add(New SqlParameter("@Suppressed", suppressed))
                cmd.Parameters.Add(New SqlParameter("@ShowTooltips", showTooltips))
                cmd.Parameters.Add(New SqlParameter("@GMCCode", gmcCode))
                cmd.Parameters.Add(New SqlParameter("@CanEditDropdowns", canEditDropdowns))
                cmd.Parameters.Add(New SqlParameter("@CanViewAllUserAudits", CanViewAllUserAudits))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@GeneralLibrary", GeneralLibrary))
                cmd.Parameters.Add(New SqlParameter("@CanOverbookLists", canOverbookLists))
                cmd.Parameters.Add(New SqlParameter("@CanOverrideSchedule", CanOverrideSchedule))
                cmd.Parameters.Add(New SqlParameter("@IsTrainee", IsTrainee))
                HttpContext.Current.Session("ShowToolTips") = showTooltips
                connection.Open()
                Return CInt(cmd.ExecuteScalar())
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error adding user", ex)
        End Try


        Return 0

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateUser(ByVal userId As Integer,
                               ByVal expiresOn As Date,
                               ByVal username As String,
                               ByVal title As String,
                               ByVal forename As String,
                               ByVal surname As String,
                               ByVal initials As String,
                               ByVal qualifications As String,
                               ByVal isGIConsultant As Boolean,
                               ByVal jobTitleId As Integer,
                               ByVal RoleID As String,
                               ByVal canRunAK As Boolean,
                               ByVal isListConsultant As Boolean,
                               ByVal isEndoscopist1 As Boolean,
                               ByVal isEndoscopist2 As Boolean,
                               ByVal isAssistantOrTrainee As Boolean,
                               ByVal isNurse1 As Boolean,
                               ByVal isNurse2 As Boolean,
                               ByVal suppressed As Boolean,
                               ByVal showTooltips As Boolean,
                               ByVal gmcCode As String,
                               ByVal canEditDropdowns As Boolean,
                               ByVal canOverbookLists As Boolean,
                               ByVal CanViewAllUserAudits As Boolean,
                               ByVal GeneralLibrary As Boolean,
                               ByVal canOverrideSchedule As Boolean,
                               ByVal IsTrainee As Boolean) As Integer

        Try
            Dim idObj As Object

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("update_user", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))
                cmd.Parameters.Add(New SqlParameter("@UserId", userId))
                cmd.Parameters.Add(New SqlParameter("@Username", username))
                cmd.Parameters.Add(New SqlParameter("@Title", title))
                cmd.Parameters.Add(New SqlParameter("@Forename", forename))
                cmd.Parameters.Add(New SqlParameter("@Surname", surname))
                If qualifications IsNot Nothing Then
                    cmd.Parameters.Add(New SqlParameter("@Qualifications", qualifications))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Qualifications", SqlTypes.SqlString.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@IsGI", isGIConsultant))
                cmd.Parameters.Add(New SqlParameter("@JobTitleId", jobTitleId))
                cmd.Parameters.Add(New SqlParameter("@RoleID", RoleID))
                cmd.Parameters.Add(New SqlParameter("@CanRunAK", canRunAK))
                cmd.Parameters.Add(New SqlParameter("@CanViewAllUserAudits", CanViewAllUserAudits))
                cmd.Parameters.Add(New SqlParameter("@IsListConsultant", isListConsultant))
                cmd.Parameters.Add(New SqlParameter("@IsEndoscopist1", isEndoscopist1))
                cmd.Parameters.Add(New SqlParameter("@IsEndoscopist2", isEndoscopist2))
                cmd.Parameters.Add(New SqlParameter("@IsAssistantOrTrainee", isAssistantOrTrainee))
                cmd.Parameters.Add(New SqlParameter("@IsNurse1", isNurse1))
                cmd.Parameters.Add(New SqlParameter("@IsNurse2", isNurse2))
                cmd.Parameters.Add(New SqlParameter("@Suppressed", suppressed))
                If expiresOn.ToString = "01/01/0001 00:00:00" Then
                    expiresOn = DateTime.Now
                End If
                cmd.Parameters.Add(New SqlParameter("@ExpiresOn", expiresOn))
                cmd.Parameters.Add(New SqlParameter("@ShowTooltips", showTooltips))
                cmd.Parameters.Add(New SqlParameter("@GMCCode", gmcCode))
                cmd.Parameters.Add(New SqlParameter("@CanEditDropdowns", canEditDropdowns))
                cmd.Parameters.Add(New SqlParameter("@GeneralLibrary", GeneralLibrary))
                cmd.Parameters.Add(New SqlParameter("@CanOverbookLists", canOverbookLists))
                cmd.Parameters.Add(New SqlParameter("@UpdateUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@CanOverrideSchedule", canOverrideSchedule))
                cmd.Parameters.Add(New SqlParameter("@IsTrainee", IsTrainee))
                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CBool(idObj)
                Else
                    Return False
                End If
            End Using
            HttpContext.Current.Session("ShowToolTips") = showTooltips

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(String.Format("Error at: DataAccess.vb=>UpdateUser(UserId={0}, TrustId={1})", userId, Session("TrustId")), ex)
            Return False
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateUserLogin(ByVal userId As Integer,
                                    ByVal loggedOn As Boolean,
                                    ByVal hostName As String,
                                    ByVal hostFullName As String) As Integer

        Dim sql As New StringBuilder
        Dim operatingHospitalId As Integer = CInt(HttpContext.Current.Session("OperatingHospitalID"))
        sql.Append("UPDATE ERS_Users ")
        sql.Append("SET LoggedOn = @LoggedOn, LastOperatingHospital = @OperatingHospitalId, LastLoggedIn = GETDATE() ")
        sql.Append("WHERE UserId = @UserId ")

        sql.Append("DELETE FROM ERS_UserLogins WHERE UserId = @UserId ")
        sql.Append("INSERT INTO ERS_UserLogins (UserID, HostName, HostFullName, LoggedInAt, LastActiveAt) ")
        sql.Append("VALUES (@UserId, @HostName, @HostFullName, GETDATE(), GETDATE()) ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@LoggedOn", loggedOn))
            cmd.Parameters.Add(New SqlParameter("@HostName", IIf(hostName Is Nothing, hostFullName, hostName))) 'use hostFullName when hostname is returned as nothing
            cmd.Parameters.Add(New SqlParameter("@HostFullName", hostFullName))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateUser(ByVal userId As Integer,
                               ByVal suppressed As Boolean) As Integer

        Dim dsUser As New DataSet
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_Users ")
        sql.Append("SET suppressed = @Suppressed ")
        sql.Append(",WhoUpdatedId = @LoggedInUserId ")
        sql.Append(",WhenUpdated = GETDATE() ")
        sql.Append("WHERE UserId = @UserId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@Suppressed", suppressed))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateUserResetPassword(ByVal userId As Integer,
                                            ByVal password As String,
                                            ByVal passwordExpiresOn As Date,
                                            ByVal resetPassword As Boolean) As Integer

        Dim dsUser As New DataSet
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_Users ")
        sql.Append("SET password = @Password, ")
        sql.Append("LastUpdated = GETDATE(), ")
        sql.Append("PasswordExpiresOn = @PasswordExpiresOn, ")
        sql.Append("ResetPassword = @ResetPassword, ")
        sql.Append("WhoUpdatedId = @LoggedInUserId, ")
        sql.Append("WhenUpdated = GetDate() ")
        sql.Append("WHERE UserId = @UserId ")

        sql.Append("INSERT INTO ERS_UserPasswords (UserID, Password, CreatedOn, WhoCreatedId, WhenCreated) ")
        sql.Append("VALUES (@UserId, @Password, GETDATE(), @LoggedInUserId, GETDATE()) ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@Password", Utilities.GetPasswordASC(password)))
            cmd.Parameters.Add(New SqlParameter("@PasswordExpiresOn", passwordExpiresOn))
            cmd.Parameters.Add(New SqlParameter("@ResetPassword", resetPassword))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function ResetUserPassword(ByVal userId As Integer,
                                            ByVal password As String,
                                            ByVal resetPassword As Boolean) As Integer

        Dim dsUser As New DataSet
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_Users ")
        sql.Append("SET password = @Password, ")
        sql.Append("LastUpdated = GETDATE(), ")
        sql.Append("ResetPassword = @ResetPassword, ")
        sql.Append("WhoUpdatedId = @LoggedInUserId, ")
        sql.Append("WhenUpdated = GetDate() ")
        sql.Append("WHERE UserId = @UserId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@Password", Utilities.GetPasswordASC(password)))
            cmd.Parameters.Add(New SqlParameter("@ResetPassword", resetPassword))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateTheme(ByVal userId As Integer,
                                            ByVal sTheme As String,
                                            ByVal ThemeName As String) As Integer

        Dim dsUser As New DataSet
        Dim sql As New StringBuilder
        sql.Append("UPDATE ERS_Users SET ")
        If sTheme = "Diagram" Then
            sql.Append("DiagramTheme = @ThemeName, ")
        ElseIf sTheme = "Controls" Then
            sql.Append("SkinName = @ThemeName, ")
        End If
        sql.Append("LastUpdated = GETDATE() ")
        sql.Append("WHERE UserId = @UserId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            cmd.Parameters.Add(New SqlParameter("@ThemeName", ThemeName))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function GetHostNameOfLastLogin(ByVal userId As Integer) As String
        Dim sql As String = "SELECT TOP 1 HostName FROM ERS_UserLogins WHERE UserID = @UserId"

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@UserID", userId))

            connection.Open()
            Return CStr(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllTrusts() As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Trusts_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function

    'Public Function IsUserAdmin(ByVal userId As Integer) As Boolean
    '    Dim sql As String = "SELECT CASE WHEN AccessRights = 3 THEN 1 ELSE 0 END AS UserIsAdmin FROM ERS_Users WHERE UserID = @UserID"

    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand(sql, connection)
    '        cmd.CommandType = CommandType.Text

    '        cmd.Parameters.Add(New SqlParameter("@UserID", userId))

    '        connection.Open()
    '        Dim ret = cmd.ExecuteScalar()
    '        If ret IsNot Nothing Then
    '            Return CBool(ret)
    '        End If
    '    End Using
    '    Return False
    'End Function
#End Region

#Region "Patient"
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetPatients1(ByVal searchString1 As String, ByVal searchString2 As String, _
    '                            ByVal searchString3 As String, ByVal searchString4 As String, _
    '                            ByVal opt_condition As String) As DataTable
    '    Dim sql As New StringBuilder
    '    Dim criteria As String = ""
    '    Dim dsPatients As New DataSet


    '    If HttpContext.Current.Session(Constants.SESSION_SEARCH_TAB) = "0" Then
    '        If searchString1 Is Nothing Or searchString1 = "" Then
    '            criteria = ""
    '        Else
    '            Select Case opt_condition
    '                Case "ALL"
    '                    criteria = " WHERE [Case note no] LIKE '%' + ISNULL(@SearchString1,'') + '%' OR [NHS No] LIKE '%' + ISNULL(@SearchString1,'') + '%' OR Surname LIKE '%' + ISNULL(@SearchString1,'') + '%' OR Forename LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '                Case "Case note no"
    '                    criteria = " WHERE [Case note no] LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '                Case "NHS No"
    '                    criteria = " WHERE [NHS No] LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '                Case "Surname"
    '                    criteria = " WHERE Surname LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '                Case "Forename"
    '                    criteria = " WHERE Forename LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '            End Select
    '        End If
    '    Else 'Advanced Search
    '        If Not searchString1 Is Nothing AndAlso searchString1 <> "" Then
    '            criteria += IIf(criteria = "", "WHERE", opt_condition) & " [Case note no] LIKE '%' + ISNULL(@SearchString1,'') + '%' "
    '        End If
    '        If Not searchString2 Is Nothing AndAlso searchString2 <> "" Then
    '            criteria += IIf(criteria = "", "WHERE", opt_condition) & " [NHS No] LIKE '%' + ISNULL(@SearchString2,'') + '%' "
    '        End If
    '        If Not searchString3 Is Nothing AndAlso searchString3 <> "" Then
    '            criteria += IIf(criteria = "", "WHERE", opt_condition) & " Surname LIKE '%' + ISNULL(@SearchString3,'') + '%' "
    '        End If
    '        If Not searchString4 Is Nothing AndAlso searchString4 <> "" Then
    '            criteria += IIf(criteria = "", "WHERE", opt_condition) & " Forename LIKE '%' + ISNULL(@SearchString4,'') + '%' "
    '        End If

    '    End If

    '    sql.Append("SELECT [Patient No] AS PatientId, Forename + ' ' + Surname AS PatientName, [Case note no] AS CaseNoteNo,  ")
    '    sql.Append("[NHS No] AS NHSNo, [Record created] AS CreatedOn, * ")
    '    sql.Append(" FROM Patient ")
    '    sql.Append(criteria)
    '    sql.Append(" ORDER BY [Record created] DESC, [Patient No]  DESC ")


    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand(sql.ToString(), connection)
    '        cmd.CommandType = CommandType.Text

    '        If Not String.IsNullOrEmpty(searchString1) Then
    '            cmd.Parameters.Add(New SqlParameter("@SearchString1", searchString1))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@SearchString1", SqlTypes.SqlString.Null))
    '        End If

    '        If Not String.IsNullOrEmpty(searchString2) Then
    '            cmd.Parameters.Add(New SqlParameter("@SearchString2", searchString2))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@SearchString2", SqlTypes.SqlString.Null))
    '        End If
    '        If Not String.IsNullOrEmpty(searchString3) Then
    '            cmd.Parameters.Add(New SqlParameter("@SearchString3", searchString3))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@SearchString3", SqlTypes.SqlString.Null))
    '        End If
    '        If Not String.IsNullOrEmpty(searchString4) Then
    '            cmd.Parameters.Add(New SqlParameter("@SearchString4", searchString4))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@SearchString4", SqlTypes.SqlString.Null))
    '        End If


    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsPatients)
    '    End Using

    '    If dsPatients.Tables.Count > 0 Then
    '        Return dsPatients.Tables(0)
    '    End If
    '    Return New DataTable
    'End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatients(ByVal searchString1 As String, ByVal searchString2 As String,
                                ByVal searchString3 As String, ByVal searchString4 As String,
                                ByVal searchString5 As String, ByVal searchString6 As String,
                                ByVal searchString7 As String, ByVal searchString8 As String, ByVal opt_condition As String,
                                ByVal opt_Type As String, ByVal includeDeceased As Boolean) As DataTable

        Try
            Dim dsPatients As New DataSet
            Session("SearchedNHSNo") = ""
            Session("PatientSearchSource") = ""
            'Using connection As New SqlConnection(ConnectionStr)
            '    Dim cmd As New SqlCommand("startup_select", connection)
            '    cmd.CommandType = CommandType.StoredProcedure

            'Mahfuz added on 24 June 2021
            'New Design Plan for Scottish D&G Import Patients by WebService. Get Search Patients by Web Service and return the temporary patients datasource
            'Commit later on while creating the procedures!! (Brilliant idea from Duncan!)

            If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
                'Only for D&G Scottish Hopspital - Return the patients data received from Web Service
                Dim ScotHosWSBL As ScotHospitalWebServiceBL = New ScotHospitalWebServiceBL

                ScotHosWSBL.ConnectWebservice()
                'Call GetPatients method
                dsPatients = ScotHosWSBL.SearchAndGetPatientsViaWebService()
                'Logout
                ScotHosWSBL.DisconnectService()
            ElseIf ((Session(Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI) = ImportPatientByWebserviceOptions.NSSAPI) And Not String.IsNullOrEmpty(searchString2)) Then

                Dim nipapiPIBL As NIPAPIBL = New NIPAPIBL()
                Dim chiNumber As String = searchString2
                Session("SearchedNHSNo") = searchString2
                Session("PatientSearchSource") = Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI
                dsPatients = nipapiPIBL.GetPatientFromNIPAndGetGeneratedDataset(chiNumber)
            ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI) = ImportPatientByWebserviceOptions.NHSSPINEAPI Then

                Dim nhsSpineAPI As NHSSPINEAPIBL = New NHSSPINEAPIBL()
                Dim nhsNumber As String = searchString2
                Session("SearchedNHSNo") = searchString2
                dsPatients = nhsSpineAPI.GetPatientFromNHSSPINEAndGetGeneratedDataset(nhsNumber, searchString3, searchString4, searchString5, searchString8, searchString7)


            Else 'For all other clients like as usual like before
                Using connection As New SqlConnection(ConnectionStr)
                    Dim cmd As New SqlCommand("startup_select", connection)
                    cmd.CommandType = CommandType.StoredProcedure


                    If Not String.IsNullOrEmpty(searchString1) Then
                        cmd.Parameters.Add(New SqlParameter("@SearchString1", searchString1))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@SearchString1", SqlTypes.SqlString.Null))
                    End If

                    If Not String.IsNullOrEmpty(searchString2) Then
                        cmd.Parameters.Add(New SqlParameter("@SearchString2", searchString2))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@SearchString2", SqlTypes.SqlString.Null))
                    End If
                    If Not String.IsNullOrEmpty(searchString3) Then
                        cmd.Parameters.Add(New SqlParameter("@SearchString3", searchString3))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@SearchString3", SqlTypes.SqlString.Null))
                    End If
                    If Not String.IsNullOrEmpty(searchString4) Then
                        cmd.Parameters.Add(New SqlParameter("@SearchString4", searchString4))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@SearchString4", SqlTypes.SqlString.Null))
                    End If
                    If Not String.IsNullOrEmpty(searchString5) Then
                        cmd.Parameters.Add(New SqlParameter("@searchString5", searchString5))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@searchString5", SqlTypes.SqlString.Null))
                    End If
                    If Not String.IsNullOrEmpty(searchString6) Then
                        cmd.Parameters.Add(New SqlParameter("@searchString6", searchString6))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@searchString6", SqlTypes.SqlString.Null))
                    End If
                    If Not String.IsNullOrEmpty(searchString7) Then
                        cmd.Parameters.Add(New SqlParameter("@searchString7", searchString7))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@searchString7", SqlTypes.SqlString.Null))
                    End If
                    If Not String.IsNullOrEmpty(searchString8) Then
                        cmd.Parameters.Add(New SqlParameter("@searchGender", searchString8))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@searchGender", SqlTypes.SqlString.Null))
                    End If

                    cmd.Parameters.Add(New SqlParameter("@SearchTab", CInt(HttpContext.Current.Session(Constants.SESSION_SEARCH_TAB))))
                    cmd.Parameters.Add(New SqlParameter("@Condition", opt_condition))
                    cmd.Parameters.Add(New SqlParameter("@SearchType", opt_Type))
                    cmd.Parameters.Add(New SqlParameter("@ExcludeDeceased", includeDeceased))
                    cmd.Parameters.Add(New SqlParameter("@UserId", LoggedInUserId))
                    cmd.Parameters.Add(New SqlParameter("@UserName", Session("UserId")))
                    cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))

                    Dim adapter = New SqlDataAdapter(cmd)

                    connection.Open()
                    adapter.Fill(dsPatients)
                End Using
            End If

            If dsPatients.Tables.Count > 0 Then
                Return dsPatients.Tables(0)
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("GetPatients:   " + ex.ToString(), ex)
            Return Nothing
        End Try
        Return New DataTable
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatient(ByVal PatientId As Integer, Optional ByVal UserId? As Integer = Nothing, Optional ByVal UserName As String = "") As DataTable
        Dim dsPatient As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("patient_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
            cmd.Parameters.Add(New SqlParameter("@UserName", UserName))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPatient)
        End Using

        If dsPatient.Tables.Count > 0 Then
            Return dsPatient.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SavePatient(ByVal PatientId As Nullable(Of Integer),
                                ByVal CaseNoteNo As String,
                                ByVal Title As String,
                                ByVal Forename As String,
                                ByVal Surname As String,
                                ByVal DateOfBirth As Date,
                                ByVal NHSNo As String,
                                ByVal Address1 As String,
                                ByVal Address2 As String,
                                ByVal Town As String,
                                ByVal County As String,
                                ByVal PostCode As String,
                                ByVal PhoneNo As String,
                                ByVal Gender As String,
                                ByVal EthnicOrigin As Nullable(Of Integer),
                                ByVal JustDownloaded As Nullable(Of Boolean),
                                ByVal Notes As String,
                                ByVal District As String,
                                ByVal DHACode As String,
                                ByVal GPId As Nullable(Of Integer),
                                ByVal PracticeId As Nullable(Of Integer),
                                ByVal DateOfDeath As Nullable(Of Date),
                                ByVal AdvocateRequired As Nullable(Of Boolean),
                                ByVal DateLastSeenAlive As Nullable(Of Date),
                                ByVal CauseOfDeath As String,
                                ByVal CodeForCauseOfDeath As String,
                                ByVal CARelatedDeath As Nullable(Of Boolean),
                                ByVal DeathWithinHospital As Nullable(Of Boolean),
                                ByVal Hospitals As Nullable(Of Integer),
                                ByVal ExtraReferral As String,
                                ByVal ConsultantNo As Nullable(Of Integer),
                                ByVal HIVRisk As Nullable(Of Integer),
                                ByVal OutcomeNotes As String,
                                ByVal UniqueHospitalId As Nullable(Of Integer),
                                ByVal GPReferralFlag As Nullable(Of Boolean),
                                ByVal OwnedBy As String,
                                ByVal HasImages As Nullable(Of Boolean),
                                ByVal VerificationStatus As String,
                                ByVal Email As String, 'Added by rony tfs-4206
                                ByVal MobileNo As String,
                                ByVal KentOfKin As String,
                                ByVal Modalities As String
        ) As Integer

        Dim affectedPatientId As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("patients_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            If PatientId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            Else
                cmd.Parameters.Add(New SqlParameter("@PatientId", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", CaseNoteNo))
            cmd.Parameters.Add(New SqlParameter("@Title", Title))
            cmd.Parameters.Add(New SqlParameter("@Forename", Forename))
            cmd.Parameters.Add(New SqlParameter("@Surname", Surname))
            cmd.Parameters.Add(New SqlParameter("@DateOfBirth", DateOfBirth))
            If Not String.IsNullOrEmpty(NHSNo) Then
                cmd.Parameters.Add(New SqlParameter("@NHSNo", NHSNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@NHSNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address1) Then
                cmd.Parameters.Add(New SqlParameter("@Address1", Address1))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address1", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address2) Then
                cmd.Parameters.Add(New SqlParameter("@Address2", Address2))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address2", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Town) Then
                cmd.Parameters.Add(New SqlParameter("@Town", Town))
            Else
                cmd.Parameters.Add(New SqlParameter("@Town", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(County) Then
                cmd.Parameters.Add(New SqlParameter("@County", County))
            Else
                cmd.Parameters.Add(New SqlParameter("@County", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PostCode) Then
                cmd.Parameters.Add(New SqlParameter("@PostCode", PostCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@PostCode", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PhoneNo) Then
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", PhoneNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Gender) Then
                cmd.Parameters.Add(New SqlParameter("@Gender", Gender))
            Else
                cmd.Parameters.Add(New SqlParameter("@Gender", SqlTypes.SqlString.Null))
            End If
            If EthnicOrigin.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", EthnicOrigin))
            Else
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", SqlTypes.SqlInt32.Null))
            End If
            If JustDownloaded.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@JustDownloaded", JustDownloaded))
            Else
                cmd.Parameters.Add(New SqlParameter("@JustDownloaded", SqlTypes.SqlBoolean.Null))
            End If
            If Not String.IsNullOrEmpty(Notes) Then
                cmd.Parameters.Add(New SqlParameter("@Notes", Notes))
            Else
                cmd.Parameters.Add(New SqlParameter("@Notes", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(District) Then
                cmd.Parameters.Add(New SqlParameter("@District", District))
            Else
                cmd.Parameters.Add(New SqlParameter("@District", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DHACode) Then
                cmd.Parameters.Add(New SqlParameter("@DHACode", DHACode))
            Else
                cmd.Parameters.Add(New SqlParameter("@DHACode", SqlTypes.SqlString.Null))
            End If
            If GPId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GPId", GPId))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPId", SqlTypes.SqlInt32.Null))
            End If
            If PracticeId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PracticeId", PracticeId))
            Else
                cmd.Parameters.Add(New SqlParameter("@PracticeId", SqlTypes.SqlInt32.Null))
            End If
            If DateOfDeath.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DateOfDeath", DateOfDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@DateOfDeath", SqlTypes.SqlDateTime.Null))
            End If
            If AdvocateRequired.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AdvocateRequired", AdvocateRequired))
            Else
                cmd.Parameters.Add(New SqlParameter("@AdvocateRequired", SqlTypes.SqlBoolean.Null))
            End If
            If DateLastSeenAlive.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DateLastSeenAlive", DateLastSeenAlive))
            Else
                cmd.Parameters.Add(New SqlParameter("@DateLastSeenAlive", SqlTypes.SqlDateTime.Null))
            End If
            If Not String.IsNullOrEmpty(CauseOfDeath) Then
                cmd.Parameters.Add(New SqlParameter("@CauseOfDeath", CauseOfDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@CauseOfDeath", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(CodeForCauseOfDeath) Then
                cmd.Parameters.Add(New SqlParameter("@CodeForCauseOfDeath", CodeForCauseOfDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@CodeForCauseOfDeath", SqlTypes.SqlString.Null))
            End If
            If CARelatedDeath.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CARelatedDeath", CARelatedDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@CARelatedDeath", SqlTypes.SqlBoolean.Null))
            End If
            If DeathWithinHospital.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DeathWithinHospital", DeathWithinHospital))
            Else
                cmd.Parameters.Add(New SqlParameter("@DeathWithinHospital", SqlTypes.SqlBoolean.Null))
            End If
            If Hospitals.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Hospitals", Hospitals))
            Else
                cmd.Parameters.Add(New SqlParameter("@Hospitals", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(ExtraReferral) Then
                cmd.Parameters.Add(New SqlParameter("@ExtraReferral", ExtraReferral))
            Else
                cmd.Parameters.Add(New SqlParameter("@ExtraReferral", SqlTypes.SqlString.Null))
            End If
            If ConsultantNo.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ConsultantNo", ConsultantNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@ConsultantNo", SqlTypes.SqlInt32.Null))
            End If
            If HIVRisk.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@HIVRisk", HIVRisk))
            Else
                cmd.Parameters.Add(New SqlParameter("@HIVRisk", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(OutcomeNotes) Then
                cmd.Parameters.Add(New SqlParameter("@OutcomeNotes", OutcomeNotes))
            Else
                cmd.Parameters.Add(New SqlParameter("@OutcomeNotes", SqlTypes.SqlString.Null))
            End If
            If UniqueHospitalId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", UniqueHospitalId))
            Else
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", SqlTypes.SqlInt32.Null))
            End If
            If GPReferralFlag.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GPReferralFlag", GPReferralFlag))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPReferralFlag", SqlTypes.SqlBoolean.Null))
            End If
            If Not String.IsNullOrEmpty(OwnedBy) Then
                cmd.Parameters.Add(New SqlParameter("@OwnedBy", OwnedBy))
            Else
                cmd.Parameters.Add(New SqlParameter("@OwnedBy", SqlTypes.SqlString.Null))
            End If
            If HasImages.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@HasImages", HasImages))
            Else
                cmd.Parameters.Add(New SqlParameter("@HasImages", SqlTypes.SqlBoolean.Null))
            End If
            If Not String.IsNullOrEmpty(VerificationStatus) Then
                cmd.Parameters.Add(New SqlParameter("@VerificationStatus", VerificationStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@VerificationStatus", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))
            'Added by rony tfs-4206
            cmd.Parameters.Add(New SqlParameter("@Email", Email))
            cmd.Parameters.Add(New SqlParameter("@MobileNo", MobileNo))
            cmd.Parameters.Add(New SqlParameter("@KentOfKin", KentOfKin))
            cmd.Parameters.Add(New SqlParameter("@Modalities", Modalities))

            connection.Open()
            affectedPatientId = CInt(cmd.ExecuteScalar())
        End Using

        Return affectedPatientId
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function InsertOrUpdateERS_GPS_FromSCIStore(ByRef GPId As Integer,
        ByVal Title As String,
        ByVal Initial As String,
        ByVal ForeName As String,
        ByVal GPName As String,
        ByVal Email As String,
        ByVal Telephone As String,
        ByVal LoggedInUserId As Integer,
        ByVal SCIStoreGPId As String) As Boolean
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("InsertOrUpdateERS_GPS_FromSCIStore", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@GPId", SqlDbType.Int))
                cmd.Parameters("@GPId").Direction = ParameterDirection.Output

                cmd.Parameters.Add(New SqlParameter("@Title", Title))
                cmd.Parameters.Add(New SqlParameter("@Initial", Initial))
                cmd.Parameters.Add(New SqlParameter("@ForeName", ForeName))
                cmd.Parameters.Add(New SqlParameter("@GPName", GPName))
                cmd.Parameters.Add(New SqlParameter("@Email", Email))
                cmd.Parameters.Add(New SqlParameter("@Telephone", Telephone))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@SCIStoreGPId", SCIStoreGPId))
                connection.Open()
                cmd.ExecuteNonQuery()
                GPId = cmd.Parameters("@GPId").Value
            End Using
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function InsertOrUpdateERS_GPS_FromSCIStore...", ex)
            Return False
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function InsertOrUpdateERS_Practices_FromSCIStore(ByRef PracticeId As Integer,
        ByVal Code As String,
        ByVal NationalCode As String,
        ByVal Name As String,
        ByVal Address1 As String,
        ByVal Address2 As String,
        ByVal Address3 As String,
        ByVal Address4 As String,
        ByVal Postcode As String,
        ByVal TelNo As String,
        ByVal Email As String,
        ByVal LoggedInUserId As Integer,
        ByVal SCIStorePracticeId As String) As Boolean
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("InsertOrUpdateERS_Practices_FromSCIStore", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@PracticeId", SqlDbType.Int))
                cmd.Parameters("@PracticeId").Direction = ParameterDirection.Output

                cmd.Parameters.Add(New SqlParameter("@Code", Code))
                cmd.Parameters.Add(New SqlParameter("@NationalCode", NationalCode))
                cmd.Parameters.Add(New SqlParameter("@Name", Name))
                cmd.Parameters.Add(New SqlParameter("@Address1", Address1))
                cmd.Parameters.Add(New SqlParameter("@Address2", Address2))
                cmd.Parameters.Add(New SqlParameter("@Address3", Address3))
                cmd.Parameters.Add(New SqlParameter("@Address4", Address4))
                cmd.Parameters.Add(New SqlParameter("@Postcode", Postcode))
                cmd.Parameters.Add(New SqlParameter("@TelNo", TelNo))
                cmd.Parameters.Add(New SqlParameter("@Email", Email))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@SCIStorePracticeId", SCIStorePracticeId))
                connection.Open()
                cmd.ExecuteNonQuery()
                PracticeId = cmd.Parameters("@PracticeId").Value

            End Using
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function InsertOrUpdateERS_Practices_FromSCIStore...", ex)
            Return False
        End Try
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function AddUpdatePatientFromWebService(ByVal PatientId As Nullable(Of Integer),
                                ByVal CaseNoteNo As String,
                                ByVal Title As String,
                                ByVal Forename As String,
                                ByVal Surname As String,
                                ByVal DateOfBirth As Date,
                                ByVal NHSNo As String,
                                ByVal Address1 As String,
                                ByVal Address2 As String,
                                ByVal Town As String,
                                ByVal County As String,
                                ByVal PostCode As String,
                                ByVal PhoneNo As String,
                                ByVal Gender As String,
                                ByVal EthnicOrigin As String,
                                ByVal JustDownloaded As Nullable(Of Boolean),
                                ByVal Notes As String,
                                ByVal District As String,
                                ByVal DHACode As String,
                                ByVal GPId As Nullable(Of Integer),
                                ByVal PracticeId As Nullable(Of Integer),
                                ByVal DateOfDeath As Nullable(Of Date),
                                ByVal AdvocateRequired As Nullable(Of Boolean),
                                ByVal DateLastSeenAlive As Nullable(Of Date),
                                ByVal CauseOfDeath As String,
                                ByVal CodeForCauseOfDeath As String,
                                ByVal CARelatedDeath As Nullable(Of Boolean),
                                ByVal DeathWithinHospital As Nullable(Of Boolean),
                                ByVal Hospitals As Nullable(Of Integer),
                                ByVal ExtraReferral As String,
                                ByVal ConsultantNo As Nullable(Of Integer),
                                ByVal HIVRisk As Nullable(Of Integer),
                                ByVal OutcomeNotes As String,
                                ByVal UniqueHospitalId As Nullable(Of Integer),
                                ByVal GPReferralFlag As Nullable(Of Boolean),
                                ByVal OwnedBy As String,
                                ByVal HasImages As Nullable(Of Boolean),
                                ByVal VerificationStatus As String,
                                ByVal MaritalStatus As String,
                                ByVal intTrustId As Nullable(Of Integer)) As Integer

        Dim affectedPatientId As Integer
        'Mahfuz Added TrustID on 25th May 2021

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("stp_InsertUpdatePatientFromWebservice", connection)
            cmd.CommandType = CommandType.StoredProcedure

            If PatientId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            Else
                cmd.Parameters.Add(New SqlParameter("@PatientId", SqlTypes.SqlInt32.Null))
            End If
            If String.IsNullOrEmpty(CaseNoteNo) Then
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", CaseNoteNo))
            End If

            If String.IsNullOrEmpty(Title) Then
                cmd.Parameters.Add(New SqlParameter("@Title", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@Title", Title))
            End If

            If String.IsNullOrEmpty(Forename) Then
                cmd.Parameters.Add(New SqlParameter("@Forename", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@Forename", Forename))
            End If

            If String.IsNullOrEmpty(Surname) Then
                cmd.Parameters.Add(New SqlParameter("@Surname", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@Surname", Surname))
            End If


            cmd.Parameters.Add(New SqlParameter("@DateOfBirth", DateOfBirth))

            If Not String.IsNullOrEmpty(NHSNo) Then
                cmd.Parameters.Add(New SqlParameter("@NHSNo", NHSNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@NHSNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address1) Then
                cmd.Parameters.Add(New SqlParameter("@Address1", Address1))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address1", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address2) Then
                cmd.Parameters.Add(New SqlParameter("@Address2", Address2))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address2", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Town) Then
                cmd.Parameters.Add(New SqlParameter("@Town", Town))
            Else
                cmd.Parameters.Add(New SqlParameter("@Town", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(County) Then
                cmd.Parameters.Add(New SqlParameter("@County", County))
            Else
                cmd.Parameters.Add(New SqlParameter("@County", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PostCode) Then
                cmd.Parameters.Add(New SqlParameter("@PostCode", PostCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@PostCode", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PhoneNo) Then
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", PhoneNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Gender) Then
                cmd.Parameters.Add(New SqlParameter("@Gender", Gender))
            Else
                cmd.Parameters.Add(New SqlParameter("@Gender", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(EthnicOrigin) Then
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", EthnicOrigin))
            Else
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(MaritalStatus) Then
                cmd.Parameters.Add(New SqlParameter("@MaritalStatus", MaritalStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@MaritalStatus", SqlTypes.SqlString.Null))
            End If

            If JustDownloaded.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@JustDownloaded", JustDownloaded))
            Else
                cmd.Parameters.Add(New SqlParameter("@JustDownloaded", SqlTypes.SqlBoolean.Null))
            End If
            If Not String.IsNullOrEmpty(Notes) Then
                cmd.Parameters.Add(New SqlParameter("@Notes", Notes))
            Else
                cmd.Parameters.Add(New SqlParameter("@Notes", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(District) Then
                cmd.Parameters.Add(New SqlParameter("@District", District))
            Else
                cmd.Parameters.Add(New SqlParameter("@District", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(DHACode) Then
                cmd.Parameters.Add(New SqlParameter("@DHACode", DHACode))
            Else
                cmd.Parameters.Add(New SqlParameter("@DHACode", SqlTypes.SqlString.Null))
            End If
            If GPId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GPId", GPId))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPId", SqlTypes.SqlInt32.Null))
            End If
            If PracticeId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PracticeId", PracticeId))
            Else
                cmd.Parameters.Add(New SqlParameter("@PracticeId", SqlTypes.SqlInt32.Null))
            End If
            If DateOfDeath.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DateOfDeath", DateOfDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@DateOfDeath", SqlTypes.SqlDateTime.Null))
            End If
            If AdvocateRequired.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AdvocateRequired", AdvocateRequired))
            Else
                cmd.Parameters.Add(New SqlParameter("@AdvocateRequired", SqlTypes.SqlBoolean.Null))
            End If
            If DateLastSeenAlive.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DateLastSeenAlive", DateLastSeenAlive))
            Else
                cmd.Parameters.Add(New SqlParameter("@DateLastSeenAlive", SqlTypes.SqlDateTime.Null))
            End If
            If Not String.IsNullOrEmpty(CauseOfDeath) Then
                cmd.Parameters.Add(New SqlParameter("@CauseOfDeath", CauseOfDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@CauseOfDeath", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(CodeForCauseOfDeath) Then
                cmd.Parameters.Add(New SqlParameter("@CodeForCauseOfDeath", CodeForCauseOfDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@CodeForCauseOfDeath", SqlTypes.SqlString.Null))
            End If
            If CARelatedDeath.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@CARelatedDeath", CARelatedDeath))
            Else
                cmd.Parameters.Add(New SqlParameter("@CARelatedDeath", SqlTypes.SqlBoolean.Null))
            End If
            If DeathWithinHospital.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DeathWithinHospital", DeathWithinHospital))
            Else
                cmd.Parameters.Add(New SqlParameter("@DeathWithinHospital", SqlTypes.SqlBoolean.Null))
            End If
            If Hospitals.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Hospitals", Hospitals))
            Else
                cmd.Parameters.Add(New SqlParameter("@Hospitals", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(ExtraReferral) Then
                cmd.Parameters.Add(New SqlParameter("@ExtraReferral", ExtraReferral))
            Else
                cmd.Parameters.Add(New SqlParameter("@ExtraReferral", SqlTypes.SqlString.Null))
            End If
            If ConsultantNo.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ConsultantNo", ConsultantNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@ConsultantNo", SqlTypes.SqlInt32.Null))
            End If
            If HIVRisk.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@HIVRisk", HIVRisk))
            Else
                cmd.Parameters.Add(New SqlParameter("@HIVRisk", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(OutcomeNotes) Then
                cmd.Parameters.Add(New SqlParameter("@OutcomeNotes", OutcomeNotes))
            Else
                cmd.Parameters.Add(New SqlParameter("@OutcomeNotes", SqlTypes.SqlString.Null))
            End If
            If UniqueHospitalId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", UniqueHospitalId))
            Else
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", SqlTypes.SqlInt32.Null))
            End If
            If GPReferralFlag.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@GPReferralFlag", GPReferralFlag))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPReferralFlag", SqlTypes.SqlBoolean.Null))
            End If
            If Not String.IsNullOrEmpty(OwnedBy) Then
                cmd.Parameters.Add(New SqlParameter("@OwnedBy", OwnedBy))
            Else
                cmd.Parameters.Add(New SqlParameter("@OwnedBy", SqlTypes.SqlString.Null))
            End If
            If HasImages.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@HasImages", HasImages))
            Else
                cmd.Parameters.Add(New SqlParameter("@HasImages", SqlTypes.SqlBoolean.Null))
            End If
            If Not String.IsNullOrEmpty(VerificationStatus) Then
                cmd.Parameters.Add(New SqlParameter("@VerificationStatus", VerificationStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@VerificationStatus", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            'Mahfuz added TrustId on 25th May 2021
            If intTrustId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TrustId", intTrustId))
            Else
                cmd.Parameters.Add(New SqlParameter("@TrustId", SqlTypes.SqlInt32.Null))
            End If


            connection.Open()
            affectedPatientId = CInt(cmd.ExecuteScalar())
        End Using

        Return affectedPatientId
    End Function
    Public Function GetSELocalDBPatientIDBySCIStorePatientId(ByVal intSCIStorePatientId As Integer) As Integer
        'Dim dsProcedure As New DataSet
        Dim sql As String
        Dim dtPatientTable As New DataTable
        Dim intSELocalDBPatientID As Integer = 0

        sql = "SELECT TOP 1 PatientId FROM ERS_Patients WHERE AccountNumber = @SCIStorePatientId"

        dtPatientTable = ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@SCIStorePatientId", intSCIStorePatientId)})
        If Not IsNothing(dtPatientTable) Then
            If dtPatientTable.Rows.Count > 0 Then
                intSELocalDBPatientID = Convert.ToInt32(dtPatientTable.Rows(0)("PatientId").ToString())
            End If
        End If
        Return intSELocalDBPatientID
    End Function
    'Public Function GetSELocalDBPatientIDBySCIStorePatientId(ByVal intSCIStorePatientId As Integer) As Integer
    '    Dim sql As String
    '    Dim dtPatientTable As New DataTable
    '    Dim intSELocalDBPatientID As Integer = 0

    '    sql = "SELECT TOP 1 PatientId FROM ERSPatients WHERE AccountNumber = " + intSCIStorePatientId.ToString()


    '    dtPatientTable = GetData(sql)

    '    If Not IsNothing(dtPatientTable) Then
    '        If dtPatientTable.Rows.Count > 0 Then
    '            intSELocalDBPatientID = Convert.ToInt32(dtPatientTable.Rows(0)("PatientId").ToString())
    '        End If
    '    End If
    '    Return intSELocalDBPatientID
    '    '### TO DO: Return Procedure object-> using StoredProc!
    'End Function
#End Region

#Region "Procedures"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedures(ByVal userName As String, ByVal patientId As Integer, ByVal includeOldProcs As Boolean) As DataTable
        '### TO DO: Return Procedure object-> using StoredProc!
        Return ExecuteSP("usp_Procedures_SelectByPatient", New SqlParameter() {New SqlParameter("@UserName", userName), New SqlParameter("@PatientId", patientId), New SqlParameter("@IncludeOldProcs", includeOldProcs)})
    End Function

    Public Function GetProcedure(ByVal procedureId As Integer, ByVal bFromUGI As Boolean, ByVal procedureType As Integer, ByVal ColonType As Integer, Optional ByVal fromPrevious As Boolean = False) As DataTable
        Return ExecuteSP("usp_Procedure_Select", New SqlParameter() {New SqlParameter("@ProcedureType", procedureType),
                                                                New SqlParameter("@ProcedureID", procedureId),
                                                                New SqlParameter("@FromUGI", bFromUGI),
                                                                New SqlParameter("@ColonType", ColonType),
                                                                New SqlParameter("@FromPrevious", fromPrevious)
                                                            })
    End Function

    'Public Function GetProcedureLatest(ByVal caseNoteNo As String) As DataTable
    '    '### TO DO: Return Procedure object-> using StoredProc!
    '    Dim dsProcedure As New DataSet
    '    Dim sql As String

    '    sql = "SELECT TOP 1 * FROM ERS_Procedures WHERE PatientId = (SELECT [Patient No] FROM Patient WHERE [Case note no] = @CaseNoteNo) ORDER BY CreatedOn DESC"
    '    Return ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@CaseNoteNo", caseNoteNo)})

    '    'Using connection As New SqlConnection(ConnectionStr)
    '    '    Dim cmd As New SqlCommand(sql, connection)
    '    '    cmd.CommandType = CommandType.Text
    '    '    cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", caseNoteNo))

    '    '    Dim adapter = New SqlDataAdapter(cmd)

    '    '    connection.Open()
    '    '    adapter.Fill(dsProcedure)
    '    'End Using

    '    'If dsProcedure.Tables.Count > 0 Then
    '    '    Return dsProcedure.Tables(0)
    '    'End If
    '    'Return Nothing
    'End Function

    'Public Function GetProcedureByEpisodeNo(ByVal episodeNo As Integer) As DataTable
    '    Dim dsProcedures As New DataSet
    '    Dim sql As String = "SELECT * FROM ERS_Procedures WHERE EpisodeNo = @episodeNo"

    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand(sql, connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@EpisodeNo", episodeNo))

    '        Dim adapter = New SqlDataAdapter(cmd)

    '        connection.Open()
    '        adapter.Fill(dsProcedures)
    '    End Using

    '    If dsProcedures.Tables.Count > 0 Then
    '        Return dsProcedures.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertProcedure(ByVal P As ERS.Data.ERS_Procedures, ByVal ProductType As Integer) As Integer
        Dim newProcId As Integer
        Dim outputParamNewProcedureId As New System.Data.Entity.Core.Objects.ObjectParameter("NewProcedureId", GetType(Integer))
        'outNewProc.ParameterType

        Using db As New ERS.Data.GastroDbEntities
            If db.ERS_Procedures.Any(Function(x) x.IsActive = 1 And (x.ProcedureCompleted Is Nothing Or x.ProcedureCompleted = 0) And x.PatientId = P.PatientId) Then
                Throw New Exception("An incomplete procedure already exists for this patient. Must be completed or deleted before creating a new one.") 'if system finds a way through attempting to create multiple procedures before ones been completed
            Else
                Dim resultExecution = db.Procedures_Insert(P.ProcedureType _
                                                , P.PatientId _
                                                , P.CreatedOn _
                                                , P.ProcedureTime _
                                                , P.PatientStatus _
                                                , P.Ward _
                                                , P.PatientType _
                                                , P.OperatingHospitalID _
                                                , P.ListConsultant _
                                                , P.Endoscopist1 _
                                                , P.Endoscopist2 _
                                                , P.Assistant _
                                                , P.Nurse1 _
                                                , P.Nurse2 _
                                                , P.Nurse3 _
                                                , P.Nurse4 _
                                                , P.ReferralHospitalNo _
                                                , P.ReferralConsultantNo _
                                                , P.ReferralConsultantSpeciality _
                                                , P.PatientConsent _
                                                , P.PatientConsentType _
                                                , P.PatientConsentTypeOther _
                                                , False _
                                                , P.CreatedBy _
                                                , ProductType _
                                                , P.ListType _
                                                , P.Endo1Role _
                                                , P.Endo2Role _
                                                , P.CategoryListId _
                                                , P.OnWaitingList _
                                                , P.OpenAccessProc _
                                                , P.EmergencyProcType _
                                                , outputParamNewProcedureId _
                                                , P.ImagePortId _
                                                , P.Points _
                                                , P.ChecklistComplete _
                                                , P.ReferrerType _
                                                , P.GPReferrer _
                                                , P.ReferrerTypeOther _
                                                , P.ProviderTypeId _
                                                , P.ProviderOther _
                                                , P.PatientNotes _
                                                , P.PatientReferralLetter _
                                                , P.ImageGenderID _
                                                , P.OrderId _
                                                , P.PreAssessmentId)

                newProcId = Convert.ToInt32(outputParamNewProcedureId.Value.ToString())

                Try
                    If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_APPOINTMENT_ID)) AndAlso CInt(Session(Constants.SESSION_APPOINTMENT_ID)) > 0 Then
                        Dim appointmentId = CInt(Session(Constants.SESSION_APPOINTMENT_ID))

                        logJourneyProcedureStart(newProcId, appointmentId)

                        Dim appointment = db.ERS_Appointments.Where(Function(x) x.AppointmentId = appointmentId).FirstOrDefault
                        appointment.AppointmentStatusId = db.ERS_AppointmentStatus.Where(Function(x) x.HDCKEY.Trim = "IP").FirstOrDefault.UniqueId
                        db.ERS_Appointments.Attach(appointment)
                        db.Entry(appointment).State = Entity.EntityState.Modified
                        db.SaveChanges()
                    End If
                Catch ex As Exception
                    LogManager.LogManagerInstance.LogError("Error saving procedure start time to patient journey table", ex)
                End Try
            End If
        End Using

        Return newProcId

    End Function
    Public Sub logJourneyProcedureStart(procId As Integer, appointmentId As Integer)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim offsetMinutes As Integer = CInt(Session("TimezoneOffset"))
                Dim tblPatientJourney =
                            db.ERS_PatientJourney.Where(Function(x) x.ProcedureId Is Nothing AndAlso
                                                                    x.PatientAdmissionTime IsNot Nothing And
                                                                    x.ProcedureStartTime Is Nothing And
                                                                    x.ProcedureEndTime Is Nothing And
                                                                    x.AppointmentId = appointmentId).FirstOrDefault


                If tblPatientJourney Is Nothing Then tblPatientJourney = New ERS_PatientJourney
                With tblPatientJourney
                    .ProcedureId = procId
                    .ProcedureStartTime = DateTime.UtcNow.AddMinutes(-offsetMinutes)
                    .AppointmentId = appointmentId
                End With

                If tblPatientJourney.PatientJourneyId = 0 Then
                    db.ERS_PatientJourney.Add(tblPatientJourney)
                Else
                    db.ERS_PatientJourney.Attach(tblPatientJourney)
                    db.Entry(tblPatientJourney).State = Entity.EntityState.Modified
                End If
                db.SaveChanges()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error logging patient journey procedure start", ex)
        End Try
    End Sub

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)> _
    'Public Function InsertProcedure(ByVal procedureType As Integer, _
    '                                ByVal patientId As Integer, _
    '                                ByVal procedureDate As Nullable(Of Date), _
    '                                ByVal patientStatus As Nullable(Of Integer), _
    '                                ByVal patientWard As Nullable(Of Integer), _
    '                                ByVal patientType As Nullable(Of Integer), _
    '                                ByVal listConsultant As Nullable(Of Integer), _
    '                                ByVal endoscopist1 As Nullable(Of Integer), _
    '                                ByVal endoscopist2 As Nullable(Of Integer), _
    '                                ByVal assistant As Nullable(Of Integer), _
    '                                ByVal nurse1 As Nullable(Of Integer), _
    '                                ByVal nurse2 As Nullable(Of Integer), _
    '                                ByVal nurse3 As Nullable(Of Integer), _
    '                                ByVal referralHospitalNo As Nullable(Of Integer), _
    '                                ByVal referralConsultantNo As Nullable(Of Integer), _
    '                                ByVal ReferralConsultantSpeciality As Nullable(Of Integer), _
    '                                ByVal PatientConsent As Nullable(Of Integer), _
    '                                ByVal DefaultCheckBox As Boolean, _
    '                                ByVal UserId As Integer, _
    '                                ByVal ProductType As Integer, _
    '                                ByVal listType As Nullable(Of Integer), _
    '                                ByVal endo1Role As Nullable(Of Integer), _
    '                                ByVal endo2Role As Nullable(Of Integer)) As Integer

    '    '### TO DO: INSERT Procedure object-> using Entity Framework!

    '    Dim operatingHospitalId As Integer = CInt(HttpContext.Current.Session("OperatingHospitalID"))

    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand("usp_Procedures_Insert", connection)
    '        cmd.CommandType = CommandType.StoredProcedure

    '        cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
    '        cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
    '        cmd.Parameters.Add(New SqlParameter("@ProcedureDate", procedureDate))
    '        ' cmd.Parameters.Add(New SqlParameter("@UserId", CStr(HttpContext.Current.Session("PKUserId"))))
    '        cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))

    '        If patientStatus.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@PatientStatus", patientStatus))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@PatientStatus", SqlTypes.SqlInt32.Null))
    '        End If
    '        If patientWard.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@PatientWard", patientWard))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@PatientWard", SqlTypes.SqlInt32.Null))
    '        End If
    '        If patientType.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@PatientType", patientType))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@PatientType", SqlTypes.SqlInt32.Null))
    '        End If
    '        If listConsultant.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@ListConsultant", listConsultant))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@ListConsultant", SqlTypes.SqlInt32.Null))
    '        End If
    '        If endoscopist1.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Endoscopist1", endoscopist1))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Endoscopist1", SqlTypes.SqlInt32.Null))
    '        End If
    '        If endoscopist2.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Endoscopist2", endoscopist2))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Endoscopist2", SqlTypes.SqlInt32.Null))
    '        End If
    '        If assistant.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Assistant", assistant))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Assistant", SqlTypes.SqlInt32.Null))
    '        End If
    '        If nurse1.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Nurse1", nurse1))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Nurse1", SqlTypes.SqlInt32.Null))
    '        End If
    '        If nurse2.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Nurse2", nurse2))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Nurse2", SqlTypes.SqlInt32.Null))
    '        End If
    '        If nurse3.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@Nurse3", nurse3))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@Nurse3", SqlTypes.SqlInt32.Null))
    '        End If
    '        If referralHospitalNo.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@ReferralHospitalNo", referralHospitalNo))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@ReferralHospitalNo", SqlTypes.SqlInt32.Null))
    '        End If
    '        If referralConsultantNo.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@ReferralConsultantNo", referralConsultantNo))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@ReferralConsultantNo", SqlTypes.SqlInt32.Null))
    '        End If
    '        If ReferralConsultantSpeciality.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@ReferralConsultantSpeciality", ReferralConsultantSpeciality))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@ReferralConsultantSpeciality", SqlTypes.SqlInt32.Null))
    '        End If
    '        If PatientConsent.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@PatientConsent", PatientConsent))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@PatientConsent", SqlTypes.SqlInt32.Null))
    '        End If
    '        cmd.Parameters.Add(New SqlParameter("@DefaultCheckBox", DefaultCheckBox))
    '        cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
    '        cmd.Parameters.Add(New SqlParameter("@ProductType", ProductType))


    '        If listType.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@listType", listType))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@listType", SqlTypes.SqlInt32.Null))
    '        End If
    '        If endo1Role.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@endo1Role", endo1Role))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@endo1Role", SqlTypes.SqlInt32.Null))
    '        End If
    '        If endo2Role.HasValue Then
    '            cmd.Parameters.Add(New SqlParameter("@endo2Role", endo2Role))
    '        Else
    '            cmd.Parameters.Add(New SqlParameter("@endo2Role", SqlTypes.SqlInt32.Null))
    '        End If

    '        connection.Open()
    '        Return CInt(cmd.ExecuteScalar())
    '    End Using
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function ReplicateProcedure(ByVal procedureId As Integer, ByVal procedureType As Integer) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("usp_Procedure_Replicate", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureID", procedureId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
            Dim returnProcIdParam As New SqlParameter("@returnProcedureId", SqlDbType.Int)
            returnProcIdParam.Direction = ParameterDirection.Output
            cmd.Parameters.Add(returnProcIdParam)

            connection.Open()
            cmd.ExecuteNonQuery()

            Return CInt(cmd.Parameters("@returnProcedureId").Value)
        End Using
    End Function

    Public Sub DeleteProcedure(ByVal procedureId As Integer, Optional ByVal deleteText As String = "") 'Added by rony tfs-3059
        ExecuteScalerSQL("usp_Procedures_Delete", CommandType.StoredProcedure, New SqlParameter() {
                                                                                        New SqlParameter("@ProcedureId", procedureId),
                                                                                        New SqlParameter("@DeleteText", deleteText),
                                                                                        New SqlParameter("@UserId", LoggedInUserId)
                         })
    End Sub

    Public Function DeletePreviousProcedure(ByVal previousProcedureId As Integer, Optional ByVal inactiveReason As String = "") As Integer
        Return ExecuteScalerSQL("usp_PreviousProcedures_Delete", CommandType.StoredProcedure,
                                New SqlParameter() {
                                    New SqlParameter("@PreviousProcedureId", previousProcedureId),
                                    New SqlParameter("@InactiveReason", inactiveReason)}
                                )
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertPatientWard(ByVal ward As String) As Integer
        Return ExecuteScalerSQL("usp_Ward_Insert", CommandType.StoredProcedure, New SqlParameter() {
                                                                                        New SqlParameter("@WardName", ward),
                                                                                        New SqlParameter("@OperatingHospital", Session("OperatingHospitalID"))
                                                                                })
    End Function

    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)> _
    'Public Function SetDefaultValues(ByVal pageName As String, _
    '                                     ByVal listConsultant As Integer, _
    '                                     ByVal endoscopist1 As Integer, _
    '                                     ByVal endoscopist2 As Integer, _
    '                                     ByVal nurse1 As Integer, _
    '                                     ByVal nurse2 As Integer, _
    '                                     ByVal nurse3 As Integer, _
    '                                     ByVal patientType As Integer, _
    '                                     ByVal listType As Integer, _
    '                                     ByVal procedureRole As Integer) As Integer
    '    Dim sql As New StringBuilder
    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand("set_default_values", connection)
    '        cmd.CommandType = CommandType.StoredProcedure
    '        cmd.Parameters.Add(New SqlParameter("@UserID", CInt(HttpContext.Current.Session("PKUserID"))))
    '        cmd.Parameters.Add(New SqlParameter("@ListConsultant", listConsultant))
    '        cmd.Parameters.Add(New SqlParameter("@Endoscopist1", endoscopist1))
    '        cmd.Parameters.Add(New SqlParameter("@Endoscopist2", endoscopist2))
    '        cmd.Parameters.Add(New SqlParameter("@Nurse1", nurse1))
    '        cmd.Parameters.Add(New SqlParameter("@Nurse2", nurse2))
    '        cmd.Parameters.Add(New SqlParameter("@Nurse3", nurse3))
    '        cmd.Parameters.Add(New SqlParameter("@PatientType", patientType))
    '        cmd.Parameters.Add(New SqlParameter("@ListType", listType))
    '        cmd.Parameters.Add(New SqlParameter("@ProcedureRole", procedureRole))
    '        connection.Open()
    '        Return cmd.ExecuteNonQuery()
    '    End Using
    'End Function

    Public Function GetDefaultValues() As DataTable
        'Dim dsProcedure As New DataSet
        Dim sql As String

        sql = "SELECT TOP 1 * FROM ERS_Default WHERE UserID = @UserId"
        Return ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@UserId", LoggedInUserId)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateProcedureStaff(ByVal procedureID As Integer,
                                         ByVal listType As Integer,
                                         ByVal consultant As Integer,
                                         ByVal endoscopist1 As Integer,
                                         ByVal endoscopist1Role As Integer,
                                         ByVal endoscopist2 As Integer,
                                         ByVal endoscopist2Role As Integer,
                                         ByVal nurse1 As Integer,
                                         ByVal nurse2 As Integer,
                                         ByVal nurse3 As Integer,
                                         ByVal nurse4 As Integer,
                                         ByVal ImagePortId As Integer,
                                         ByVal ProviderTypeId As Integer,
                                         ByVal OtherProviderText As String,
                                         ByVal ReferrerType As Integer,
                                         ByVal OtherReferrerText As String,
                                         ByVal ReferralHospitalNo As Integer,
                                         ByVal ReferralConsultantNo As Integer,
                                         ByVal ReferralConsultantSpeciality As Integer,
                                         ByVal PatientStatus As Integer,
                                         ByVal Ward As Integer,
                                         ByVal PatientType As Integer,
                                         ByVal CategoryListId As Integer) As Integer

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("usp_UpdateProcedureStaff", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureID", procedureID))
                cmd.Parameters.Add(New SqlParameter("@ListType", listType))
                cmd.Parameters.Add(New SqlParameter("@ListConsultant", consultant))
                cmd.Parameters.Add(New SqlParameter("@Endoscopist1", endoscopist1))
                cmd.Parameters.Add(New SqlParameter("@Endoscopist1Role", endoscopist1Role))
                cmd.Parameters.Add(New SqlParameter("@Endoscopist2", If(endoscopist2 > 0, endoscopist2, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@Endoscopist2Role", If(endoscopist2Role > 0, endoscopist2Role, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@Nurse1", If(nurse1 > 0, nurse1, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@Nurse2", If(nurse2 > 0, nurse2, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@Nurse3", If(nurse3 > 0, nurse3, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@Nurse4", If(nurse4 > 0, nurse4, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId"))))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@ImagePortId", ImagePortId))
                cmd.Parameters.Add(New SqlParameter("@ProviderTypeId", If(ProviderTypeId > 0, ProviderTypeId, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@OtherProviderText", OtherProviderText))
                cmd.Parameters.Add(New SqlParameter("@ReferrerType", If(ReferrerType > 0, ReferrerType, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@OtherReferrerText", OtherReferrerText))
                If (ReferrerType <> 1 AndAlso ReferrerType <> 5) Then
                    cmd.Parameters.Add(New SqlParameter("@ReferralHospitalNo", ReferralHospitalNo))
                    cmd.Parameters.Add(New SqlParameter("@ReferralConsultantNo", ReferralConsultantNo))
                    cmd.Parameters.Add(New SqlParameter("@ReferralConsultantSpeciality", ReferralConsultantSpeciality))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ReferralHospitalNo", DBNull.Value))
                    cmd.Parameters.Add(New SqlParameter("@ReferralConsultantNo", DBNull.Value))
                    cmd.Parameters.Add(New SqlParameter("@ReferralConsultantSpeciality", DBNull.Value))
                End If
                cmd.Parameters.Add(New SqlParameter("@PatientStatus", PatientStatus))
                If (PatientStatus = 2 Or Ward = 0) Then
                    cmd.Parameters.Add(New SqlParameter("@Ward", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Ward", Ward))
                End If
                cmd.Parameters.Add(New SqlParameter("@PatientType", PatientType))
                cmd.Parameters.Add(New SqlParameter("@CategoryListId", CategoryListId))
                connection.Open()
                Return CInt(cmd.ExecuteScalar())
            End Using

        Catch ex As Exception
            Return 0
            Console.WriteLine("Ex message: " + ex.ToString())
        End Try

    End Function

    Public Function ProcedureConsultantRoles(ByVal procedureId As Integer) As DataTable
        Return ExecuteSQL("SELECT * FROM tvfProcedureConsultantRoles(@ProcedureID)", New SqlParameter() {New SqlParameter("@ProcedureID", procedureId)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateProcedureFlipDiagram(ByVal procedureId As Integer) As Integer
        Using da As New DataAccess
            Return DataAccess.ExecuteScalerSQL("broncho_flip_diagram", CommandType.StoredProcedure, New SqlParameter() {New SqlParameter("@procedureId", procedureId)})
        End Using
    End Function

    Public Function GetDiagram(id As Integer) As DataTable
        Return ExecuteSQL("SELECT * FROM ERS_Diagrams WHERE DiagramId = @DiagramId", New SqlParameter() {New SqlParameter("@DiagramId", id)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiagram(procedureType As Integer, diagramNumber As Integer, Optional height As Integer = 0, Optional width As Integer = 0, Optional getRegionPaths As Boolean = 0, Optional ImageGenderID As Integer = 0) As DataTable
        'param diagramNumber seems to be always 0, so not using it any further 

        Return ExecuteSP("usp_GetDiagram", New SqlParameter() {New SqlParameter("@ProcedureTypeId", procedureType),
                                                                New SqlParameter("@DiagramNumber", diagramNumber),
                                                                New SqlParameter("@height", height),
                                                                New SqlParameter("@width", width),
                                                                New SqlParameter("@getRegionPaths", getRegionPaths),
                                                                New SqlParameter("@ImageGenderID", ImageGenderID)
                                                            })
    End Function

#End Region

#Region "Report Summary"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintReport(ByVal procId As Integer, ByVal group As String, ByVal episodeNo As Integer, ByVal patComboId As String, ProcedureType As Integer, ColonType As Integer) As DataTable

        Return GetReport(procId, group, episodeNo, patComboId, ProcedureType, ColonType)

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientIdFromProcedureId(ByVal procId As Integer) As Integer
        Dim i As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_patientId_from_ProcedureId", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            i = cmd.ExecuteScalar()
        End Using

        If Not IsDBNull(i) Then
            Return CInt(i)
        Else
            Return 0
        End If
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function SetPatientIdFromProcedureId(ByVal procId As Integer, ByVal patinentId As Integer) As Integer
        Dim i As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("Set_patientId_from_ProcedureId", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procId))
            cmd.Parameters.Add(New SqlParameter("@PatinentId", patinentId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            i = cmd.ExecuteScalar()
        End Using

        If Not IsDBNull(i) Then
            Return CInt(i)
        Else
            Return 0
        End If
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetReportSummary(ByVal procId As Integer) As DataTable

        Return GetReport(procId, "LS", Nothing, Nothing, Nothing, Nothing)

    End Function

    'edited by mostafiz 3891
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPP_GPName(ByVal procedureId As Integer) As String
        Try
            Dim pp_GPName As String = ""
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                connection.Open()
                Dim query As String = "SELECT COUNT(*) FROM ERS_UpperGIFollowUp WHERE ProcedureId = @ProcedureId AND CopyToGPEmailAddress = '1'"
                Using command As New SqlCommand(query, connection)
                    command.Parameters.AddWithValue("@ProcedureId", procedureId)
                    Dim count As Integer = Convert.ToInt32(command.ExecuteScalar())

                    If count > 0 Then
                        query = "SELECT PP_GPName FROM ERS_ProceduresReporting WHERE ProcedureId = @ProcedureId"
                        command.CommandText = query
                        pp_GPName = Convert.ToString(command.ExecuteScalar())
                    End If
                End Using
            End Using
            Return pp_GPName
        Catch ex As Exception

            Return ""
        End Try

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function IsUserSystemAdministratorOrGlobalAdmin(ByVal username As String) As Boolean
        Dim isAdmin As Boolean = False
        Try

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                connection.Open()
                Dim query As String = "SELECT COUNT(*) FROM ers_roles WHERE RoleID IN (SELECT Item FROM dbo.fnSplitString((SELECT RoleID FROM ers_users WHERE Username = @LoggedUser), ',')) AND (RoleName = 'System Administrators' OR RoleName = 'GlobalAdmin')"
                Using command As New SqlCommand(query, connection)
                    command.Parameters.AddWithValue("@LoggedUser", username)
                    Dim count As Integer = Convert.ToInt32(command.ExecuteScalar())
                    isAdmin = (count > 0)
                End Using
            End Using

        Catch ex As Exception

        End Try
        Return isAdmin
    End Function
    'edited by mostafizur issue 3575

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetReportSummaryByGroup(ByVal procId As Integer, ByVal strGroup As String) As DataTable

        Return GetReport(procId, strGroup, Nothing, Nothing, Nothing, Nothing)

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPremedReportSummary(ByVal procId As Integer) As DataTable

        Return GetReport(procId, "Premed", Nothing, Nothing, Nothing, Nothing)

    End Function

    Public Function GetPatientPriority(ProcedureId As Integer) As String
        'Dim sqlStr = "SELECT ISNULL(PhotosURL,'') as PhotosURL FROM ERS_SystemConfig WHERE OperatingHospitalId = @OperatingHospitalId"
        Dim SQLStr = "select ISNULL(Description, '') AS PatientPriority from ERS_UrgencyTypes where UniqueId=(select CategoryListId from ERS_Procedures where ProcedureId=@ProcedureId)"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(SQLStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using
    End Function

    Public Function GetReport(ProcedureId As Integer, Group As String, ByVal EpisodeNo As String, PatientComboId As String, ProcedureType? As Integer, ColonType? As Integer) As DataTable

        Return ExecuteSP("usp_PrintReport", New SqlParameter() {
                                                             New SqlParameter("@ProcedureID", ProcedureId),
                                                             New SqlParameter("@Group", Group),
                                                             New SqlParameter("@EpisodeNo", IIf(EpisodeNo Is Nothing, SqlTypes.SqlString.Null, EpisodeNo)),
                                                             New SqlParameter("@PatientComboId", IIf(PatientComboId Is Nothing, SqlTypes.SqlString.Null, PatientComboId)),
                                                             New SqlParameter("@ProcedureType", IIf(ProcedureType.HasValue(), ProcedureType, SqlTypes.SqlInt32.Null)),
                                                             New SqlParameter("@ColonType", IIf(ColonType.HasValue(), ColonType, SqlTypes.SqlInt32.Null))
                                                         })

    End Function

    Public Sub reloadSiteSummary(SiteId As Integer)
        Try
            Dim SQLString As String = ""
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("sites_summary_update", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception

        End Try
    End Sub
    Public Function GetReportSummaryWithHyperlinks(ByVal procedureId As Integer, ByVal SiteId As Integer) As String
        Dim s As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("usp_Report_Summary_Select_Hyperlinks", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@SiteId", SiteId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            s = cmd.ExecuteScalar()
        End Using

        If IsDBNull(s) = False Then
            Return CStr(s)
        Else
            Return ""
        End If
    End Function

    Public Function GetInstForCareWithHyperlinks(ByVal procedureId As Integer) As String
        Dim hyperLinkText As String = ""

        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = db.ERS_ProceduresReporting.Find(procedureId)
                hyperLinkText = result.PP_InstForCareWithLinks.ToString()
            End Using

            Return hyperLinkText
        Catch ex As Exception
            Return ""   '### Error .. Return Empty!
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPatientSummary(ByVal procedureId As Integer, ByVal ProcedureType As Integer, Optional ByVal episodeNo As Integer = 0, Optional ByVal patComboId As String = "") As DataTable
        '##### Question: Can't we use 'printreport_patient_info_select' instead of 'usp_PrintReport_Select'?? So- we can re-use the Function [ GetPrintReport() ]
        Return ExecuteSP("printreport_patient_info_select", New SqlParameter() {
                                                     New SqlParameter("@ProcedureID", procedureId),
                                                     New SqlParameter("@ProcedureType", ProcedureType),
                                                     New SqlParameter("@EpisodeNo", episodeNo),
                                                     New SqlParameter("@PatientComboId", patComboId)
                                                 })
    End Function

    'Public Function GetPrintReportHeader(ByVal operatingHospitalId As Integer) As DataTable
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintReportHeader(ByVal operatingHospitalId As Integer, ByVal procedureId As Integer, ByVal episodeNo As Integer, ByVal patientComboId As String, ByVal procedureTypeId As Integer, ByVal bRepEnableNHSStyle As Boolean) As DataTable

        Dim dsSummary As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("printreport_header_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@EpisodeNo", episodeNo))
            cmd.Parameters.Add(New SqlParameter("@PatientComboId", patientComboId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureTypeId))
            cmd.Parameters.Add(New SqlParameter("@EnableNHSType", bRepEnableNHSStyle))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSummary)
        End Using

        If dsSummary.Tables.Count > 0 Then
            Return dsSummary.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintReportPhotos(ByVal operatingHospitalId As Integer, ByVal procedureId As Integer, ByVal episodeNo As Integer, ByVal patientComboId As String, ByVal ColonType As Integer) As DataTable

        If procedureId = 0 Then
            Return Nothing
        End If

        Dim iProcedureType As Integer
        If Not Integer.TryParse(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE), iProcedureType) Then
            iProcedureType = 0
        End If

        If iProcedureType = ProcedureType.Rigid Then
            iProcedureType = 3
        End If

        Return ExecuteSP("printreport_photos_select", New SqlParameter() {
                                                            New SqlParameter("@OperatingHospitalID", operatingHospitalId),
                                                            New SqlParameter("@ProcedureId", procedureId),
                                                            New SqlParameter("@EpisodeNo", episodeNo),
                                                            New SqlParameter("@PatientComboId", patientComboId),
                                                            New SqlParameter("@ProcedureType", iProcedureType),
                                                            New SqlParameter("@ColonType", ColonType)})

    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function IsImagesOnReport(ByVal operatingHospitalId As Integer, ByVal procedureId As Integer, ByVal episodeNo As Integer, ByVal patientComboId As String, ByVal ColonType As Integer) As DataTable

        If procedureId = 0 Then
            Return Nothing
        End If

        Dim iProcedureType As Integer
        If Not Integer.TryParse(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE), iProcedureType) Then
            iProcedureType = 0
        End If

        If iProcedureType = ProcedureType.Rigid Then
            iProcedureType = 3
        End If

        Return ExecuteSP("getImageCount", New SqlParameter() {
                                                            New SqlParameter("@OperatingHospitalID", operatingHospitalId),
                                                            New SqlParameter("@ProcedureId", procedureId),
                                                            New SqlParameter("@EpisodeNo", episodeNo),
                                                            New SqlParameter("@PatientComboId", patientComboId),
                                                            New SqlParameter("@ProcedureType", iProcedureType),
                                                            New SqlParameter("@ColonType", ColonType)})

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintReportSpecimens(ByVal procedureId As Integer) As DataTable
        Return ExecuteSP("printreport_specimens_select", New SqlParameter() {
                                                            New SqlParameter("@ProcedureId", procedureId)})

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPathologyReportSpecimens() As DataTable
        Dim iProcedureID = CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))

        Dim dt = ExecuteSP("pathologyreport_specimens_select", New SqlParameter() {
                                                            New SqlParameter("@ProcedureId", iProcedureID)})

        Return dt
    End Function
#End Region

#Region "Sites"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSites(ByVal procedureId As Integer, ByVal diagHeight As Integer, ByVal diagWidth As Integer, ByVal episodeNo As Integer, ByVal procType As Integer, ColonType As Integer) As DataTable
        Dim dsSites As New DataSet
        Dim isERS As Boolean = IIf(episodeNo > 0, False, True)

        Return ExecuteSP("sites_select", New SqlParameter() {
                                                    New SqlParameter("@isERS", isERS),
                                                    New SqlParameter("@ProcedureId", procedureId),
                                                    New SqlParameter("@Height", diagHeight),
                                                    New SqlParameter("@Width", diagWidth),
                                                    New SqlParameter("@OperatingHospitalID", CInt(HttpContext.Current.Session("OperatingHospitalID"))),
                                                    New SqlParameter("@ProcedureType", procType),
                                                    New SqlParameter("@episodeNo", episodeNo),
                                                    New SqlParameter("@ColonType", ColonType)})
    End Function

    Public Function GetSiteDetailsByDistance() As DataTable
        Dim dsSite As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT SiteId, ")
        query.Append(" ( CONVERT(VARCHAR,XCoordinate) +   ")
        query.Append("    CASE WHEN YCoordinate IS NULL OR YCoordinate=0 THEN ' cm' ")
        query.Append("         ELSE (' to ' + CONVERT(VARCHAR,YCoordinate) + ' cm' ) END) AS Distance ")
        query.Append("FROM ERS_Sites ")
        query.Append("WHERE ProcedureID = @ProcedureId AND SiteNo = @SiteNo ")
        query.Append("ORDER BY XCoordinate ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID))))
            cmd.Parameters.Add(New SqlParameter("@SiteNo", -77))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSite)
        End Using

        If dsSite.Tables.Count > 0 Then
            Return dsSite.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSiteTitles(ByVal procedureId As Integer) As DataTable
        Dim dsSites As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT s.SiteId, CASE WHEN s.SiteNo > 0 THEN dbo.fnGetSiteTitle(s.SiteNo, pr.OperatingHospitalID) END AS SiteTitle ")
        query.Append("From ERS_Sites s ")
        query.Append("left join ERS_Procedures pr on s.ProcedureID = pr.ProcedureID ")
        query.Append("Where s.procedureId = @ProcedureId Order By s.AreaNo, s.SiteNo DESC")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSites)
        End Using

        If dsSites.Tables.Count > 0 Then
            Return dsSites.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSitesWithPhotos(ByVal procedureId As Integer, Optional ByVal includeVideos As Boolean = True) As DataTable
        Dim dsSites As New DataSet
        Dim sql As New StringBuilder

        sql.Append("Select DISTINCT p.SiteId, ISNULL('Site ' + dbo.fnGetSiteTitle(SiteNo, pr.OperatingHospitalID) + ' : ', 'ZZZZ') + ISNULL(Region,'') AS SiteName ")
        sql.Append("FROM ERS_Photos p ")
        sql.Append("LEFT JOIN ERS_Sites s ON p.SiteId=s.SiteId ")
        sql.Append("LEfT JOIN ERS_Regions r ON s.RegionId = r.RegionId ")
        sql.Append("Left Join ERS_Procedures pr on s.ProcedureID = pr.ProcedureID ")
        sql.Append("WHERE p.ProcedureId = @ProcedureId ")
        If Not includeVideos Then
            sql.Append("AND p.PhotoName NOT LIKE '%.mp4' ")
        End If
        sql.Append("ORDER BY SiteName ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSites)
        End Using

        If dsSites.Tables.Count > 0 Then
            Return dsSites.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSitesWithDescription(ByVal procedureId As Integer) As DataTable
        Dim dsSites As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("Get_Sites_With_Description", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSites)
        End Using

        If dsSites.Tables.Count > 0 Then
            Return dsSites.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetSiteDescription(ByVal siteId As Integer) As String
        Dim dsSites As New DataSet
        Dim query As New StringBuilder
        Dim siteDescription As String = ""

        query.Append("SELECT ")
        query.Append("  'Site ' + CONVERT(VARCHAR(5), SiteNo) + ")
        query.Append("  ' (' + ")
        'query.Append(" CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN 'Anterior/Posterior' END + ")
        query.Append(" CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN '' END + ")
        query.Append("  ' in ' + r.Region + ")
        query.Append("  ')' AS SiteDescription ")
        query.Append("FROM ERS_Sites s ")
        query.Append("JOIN ERS_Regions r ON s.RegionId = r.RegionId ")
        query.Append("WHERE SiteId = @SiteId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            connection.Open()
            siteDescription = CStr(cmd.ExecuteScalar())
        End Using

        Return siteDescription
    End Function

    Public Function GetSiteDetails(ByVal siteId As Integer) As DataTable
        Dim dsSite As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT SiteId, ")
        query.Append("  CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN '' END AS AntPosDescription, ")
        query.Append("  r.Region ")
        query.Append("FROM ERS_Sites s ")
        query.Append("JOIN ERS_Regions r ON s.RegionId = r.RegionId ")
        query.Append("WHERE SiteId = @SiteId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSite)
        End Using

        If dsSite.Tables.Count > 0 Then
            Return dsSite.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSitesSummary(ByVal procId As Integer) As DataTable
        Dim dsSummary As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT SiteNo,SiteSummary FROM Sites WHERE ProcedureId = @ProcedureId", connection)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSummary)
        End Using

        If dsSummary.Tables.Count > 0 Then
            Return dsSummary.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetSitesByProcedure(ByVal ProcedureId As Integer) As DataTable
        Return ExecuteSP("Get_Sites_By_Procedure", New SqlParameter() {New SqlParameter("@ProcedureId", ProcedureId)})
    End Function

    Public Function GetSiteNo(ByVal siteId As Integer) As String
        Dim siteNo As String = ""
        Dim query As New StringBuilder

        'query.Append("SELECT CASE WHEN s.SiteNo > 0 THEN dbo.fnGetSiteTitle(s.SiteNo, pr.OperatingHospitalID) END AS SiteTitle ")
        query.Append("SELECT dbo.fnGetSiteTitle(s.SiteNo, pr.OperatingHospitalID) AS SiteTitle ")
        query.Append("From ERS_Sites s ")
        query.Append("left join ERS_Procedures pr on s.ProcedureID = pr.ProcedureID ")
        query.Append("WHERE SiteId = @SiteId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            connection.Open()
            siteNo = cmd.ExecuteScalar()
            If siteNo IsNot Nothing Then
                siteNo = siteNo.ToString()
            End If
        End Using

        Return siteNo
    End Function

    Public Function GetPrimeSiteId(ByVal siteId As Integer) As Integer
        Dim siteNo As Integer

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT dbo.fnGetPrimeSiteId(@SiteId)", connection)
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            connection.Open()
            siteNo = CInt(cmd.ExecuteScalar())
        End Using

        Return siteNo
    End Function

    Public Function GetSiteDetailsMenus(siteId As Integer) As DataTable
        Dim dsMenus As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("site_details_menu_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            'cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
            'cmd.Parameters.Add(New SqlParameter("@Region", region))
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsMenus)
        End Using

        If dsMenus.Tables.Count > 0 Then
            Return dsMenus.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SitesExist(ByVal procedureId As Integer, ByVal episodeNo As Integer, ByVal procType As Integer) As Boolean
        Dim dsSites As New DataSet
        Dim qry As New StringBuilder()
        Dim sitesCount As Integer

        qry.Append("IF @ProcedureId > 0 ")
        qry.Append("SELECT COUNT(*) FROM ERS_Sites WHERE ProcedureId = @ProcedureId ")
        qry.Append("ELSE ")
        If procType = ProcedureType.Gastroscopy Then
            qry.Append("SELECT COUNT(*) FROM [Upper GI Procedure] WHERE [Episode No] = @EpisodeNo ")
        ElseIf procType = ProcedureType.ERCP Then
            qry.Append("SELECT COUNT(*) FROM [ERCP Procedure] WHERE [Episode No] = @EpisodeNo ")
        Else
            qry.Append("SELECT COUNT(*) FROM [Colon Procedure] WHERE [Episode No] = @EpisodeNo ")
        End If

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@EpisodeNo", episodeNo))

            cmd.Connection.Open()
            sitesCount = CInt(cmd.ExecuteScalar())
        End Using

        Return sitesCount > 0
    End Function

    Public Function InsertSite(ByVal procId As Integer,
                               ByVal regionId As Integer,
                               ByVal xCordinate As Integer,
                               ByVal yCordinate As Integer,
                               ByVal antPos As Integer,
                               ByVal positionSpecified As Boolean,
                               ByVal areaNumber As Integer,
                               ByVal height As Integer,
                               ByVal width As Integer) As String
        Dim newSiteInfo As String
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("sites_insert", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procId))
            cmd.Parameters.Add(New SqlParameter("@RegionId", regionId))
            cmd.Parameters.Add(New SqlParameter("@XCoordinate", xCordinate))
            cmd.Parameters.Add(New SqlParameter("@YCoordinate", yCordinate))
            cmd.Parameters.Add(New SqlParameter("@AntPos", antPos))
            cmd.Parameters.Add(New SqlParameter("@PositionSpecified", positionSpecified))
            cmd.Parameters.Add(New SqlParameter("@AreaNo", areaNumber))
            cmd.Parameters.Add(New SqlParameter("@DiagramHeight", height))
            cmd.Parameters.Add(New SqlParameter("@DiagramWidth", width))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            cmd.Connection.Open()
            newSiteInfo = CStr(cmd.ExecuteScalar())
        End Using

        Return newSiteInfo
    End Function

    Public Function UpdateSiteAsLymphNodeSite(ByVal siteId As Integer, ByVal lymphNodeId As Integer) As String
        Dim newSiteInfo As String
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("lymph_node_site_update", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@LymphNodeId", lymphNodeId))

            cmd.Connection.Open()
            newSiteInfo = CStr(cmd.ExecuteScalar())
        End Using

        Return newSiteInfo

    End Function
    Public Function UpdateSite(ByVal siteId As Integer,
                               ByVal regionId As Integer,
                               ByVal xCordinate As Integer,
                               ByVal yCordinate As Integer,
                               ByVal antPos As Integer,
                               ByVal positionSpecified As Boolean) As Integer

        Return ExecuteScalerSQL("sites_update", CommandType.StoredProcedure, New SqlParameter() {
                                                                                    New SqlParameter("@SiteId", siteId),
                                                                                    New SqlParameter("@RegionId", regionId),
                                                                                    New SqlParameter("@XCoordinate", xCordinate),
                                                                                    New SqlParameter("@YCoordinate", yCordinate),
                                                                                    New SqlParameter("@AntPos", antPos),
                                                                                    New SqlParameter("@PositionSpecified", positionSpecified),
                                                                                    New SqlParameter("@LoggedInUserId", LoggedInUserId)})
    End Function

    Public Function DeleteSite(ByVal siteId As Integer) As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("sites_delete", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))

            cmd.Connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

#Region "Photos"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPhotoCache(ByVal userHostName As String) As DataTable
        Dim dsCache As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM [ERS_Cache] WHERE HostName = @HostName", connection)
            cmd.Parameters.Add(New SqlParameter("@HostName", userHostName))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsCache)
        End Using

        If dsCache.Tables.Count > 0 Then
            Return dsCache.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedurePhotos(ByVal procedureId As Integer) As DataTable
        Dim dsPhotos As New DataSet
        Dim query As New StringBuilder
        'query.Append("SELECT *, ISNULL(PhotoName + ' - ' + b.SiteDescription, 'No site associated (Attached to the report)') AS PhotoTitle FROM [ERS_Photos] a ")
        query.Append("SELECT *, ISNULL(b.SiteDescription, 'No site associated (Attached to the report)') AS PhotoTitle FROM [ERS_Photos] a ")
        query.Append("LEFT JOIN ")
        query.Append("(SELECT SiteId, ")
        query.Append("  'Site ' + CONVERT(VARCHAR(5), SiteNo) + ")
        query.Append("  ' (' + ")
        query.Append(" CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN 'Anterior/Posterior' END + ")
        query.Append("  ' in ' + r.Region + ")
        query.Append("  ')' AS SiteDescription ")
        query.Append("FROM ERS_Sites s ")
        query.Append("JOIN ERS_Regions r ON s.RegionId = r.RegionId ")
        query.Append("WHERE ProcedureId = @ProcedureId) b ON a.SiteId=b.SiteId ")
        query.Append("WHERE ProcedureId = @ProcedureId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString(), connection)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPhotos)
        End Using

        If dsPhotos.Tables.Count > 0 Then
            Return dsPhotos.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedurePhotosOldUGI(ByVal patientComboId As String, ByVal episodeNo As String) As DataTable
        Dim dsPhotos As New DataSet

        Dim sql As New StringBuilder
        sql.Append("SELECT * FROM [Photos] ")
        sql.Append(" WHERE [Patient No] = @patientComboId ")
        sql.Append(" AND [Episode No] = @episodeNo ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.Parameters.Add(New SqlParameter("@patientComboId", patientComboId))
            cmd.Parameters.Add(New SqlParameter("@episodeNo", episodeNo))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPhotos)
        End Using

        If dsPhotos.Tables.Count > 0 Then
            Return dsPhotos.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedureMedia(ByVal procedureId As Integer) As DataTable
        Dim dsPhotos As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("usp_get_procedure_media", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPhotos)
        End Using

        If dsPhotos.Tables.Count > 0 Then
            Return dsPhotos.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetSitePhotos(ByVal siteId As Integer, ByVal procedureId As Integer) As DataTable
        Dim dsPhotos As New DataSet
        Dim query As New StringBuilder
        query.Append("SELECT * FROM [ERS_Photos] WHERE " + If(siteId <> 0, "SiteId = @SiteId ", "SiteId IS NULL AND ProcedureId = @ProcedureId ") + "order by DateTimeStamp desc")
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString(), connection)
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPhotos)
        End Using

        If dsPhotos.Tables.Count > 0 Then
            Return dsPhotos.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetPhoto(ByVal photoId As Integer) As DataTable
        Dim dsPhoto As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM [ERS_Photos] WHERE PhotoId = @PhotoId", connection)
            cmd.Parameters.Add(New SqlParameter("@PhotoId", photoId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPhoto)
        End Using

        If dsPhoto.Tables.Count > 0 Then
            Return dsPhoto.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SavePhoto(ByVal cacheId As Integer,
                              ByVal procedureId As Integer,
                              ByVal siteId As Nullable(Of Integer)) As Integer
        Dim sql As New StringBuilder
        sql.Append("INSERT INTO ERS_Photos (PhotoName, PhotoBlob, ProcedureId, SiteId, IncludeInReport)")
        sql.Append("SELECT 'GetADecentName', PhotoBlob, @ProcedureId, @SiteId, 1 ")
        sql.Append("FROM ERS_Cache ")
        sql.Append("WHERE CacheId = @CacheId ")

        sql.Append("UPDATE ERS_Cache ")
        sql.Append("SET Used = 1")
        sql.Append("WHERE CacheId = @CacheId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@CacheId", cacheId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            If siteId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Else
                cmd.Parameters.Add(New SqlParameter("@SiteId", SqlTypes.SqlInt32.Null))
            End If

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Sub SavePhoto(ByVal photoName As String,
                              ByVal procedureId As Integer,
                              ByVal siteId As Nullable(Of Integer),
                              ByVal DateTimeStamp As DateTime)
        Try

            Try
                Using db As New ERS.Data.GastroDbEntities

                    If (CType(Session(Constants.SESSION_PROCEDURE_TYPE), ProcedureType) = ProcedureType.Colonoscopy Or CType(Session(Constants.SESSION_PROCEDURE_TYPE), ProcedureType) = ProcedureType.Sigmoidscopy) And siteId IsNot Nothing Then
                        Dim procedurePhotos = db.ERS_Photos.Where(Function(x) x.SiteId IsNot Nothing And x.ProcedureId = procedureId).ToList()
                        Dim PhotoSiteName = SiteName(siteId)

                        Dim IntubationData = (From ce In db.ERS_ColonExtentOfIntubation Where ce.ProcedureId = procedureId).FirstOrDefault()
                        If Not IntubationData Is Nothing Then

                            If PhotoSiteName.ToLower() = "caecum" Then '1a
                                If Not procedurePhotos.Any(Function(x) x.SiteId = siteId And x.DateTimeStamp < DateTimeStamp) Then 'check if site already has a photo attached and if this ones earlier

                                    If IntubationData.IntubationStartDateTime > CDate("01/01/1901") Then
                                        'calculate ttc
                                        Dim ttc = DateTimeStamp.Subtract(IntubationData.IntubationStartDateTime.Value)
                                        IntubationData.TimeToCaecumMin_Photo = ttc.Minutes
                                        IntubationData.TimeToCaecumSec_Photo = ttc.Seconds

                                        'check wt and recalculate
                                        If IntubationData.TimeForWithdrawalMin_Photo Is Nothing Then
                                            Dim rectumPhoto = (From p In procedurePhotos
                                                               Let ppSiteName = SiteName(p.SiteId)
                                                               Where p.ProcedureId = procedureId And
                                                           ppSiteName.ToLower() = "rectum" Or ppSiteName.ToLower() = "anal margin"
                                                               Order By p.DateTimeStamp Descending).FirstOrDefault()

                                            If rectumPhoto IsNot Nothing Then
                                                Dim wt = rectumPhoto.p.DateTimeStamp.Value.Subtract(DateTimeStamp)
                                                IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                                                IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                                                db.Entry(IntubationData).State = Entity.EntityState.Modified
                                            End If
                                        End If

                                        'update record count for extent
                                        If Not db.ERS_RecordCount.Any(Function(x) x.ProcedureId = procedureId And x.Identifier = "Extent/Limiting factors") Then
                                            db.ERS_RecordCount.Add(New ERS_RecordCount() With {
                                    .ProcedureId = procedureId,
                                    .Identifier = "Extent/Limiting factors",
                                    .RecordCount = 1
                                    })
                                        End If

                                        db.SaveChanges()
                                        Update_ERS_Extent_Limiting_Factors(procedureId)
                                    End If
                                End If
                            ElseIf PhotoSiteName.ToLower() = "rectum" Or PhotoSiteName.ToLower() = "anal margin" Then '1b
                                If Not procedurePhotos.Any(Function(x) x.SiteId = siteId And x.DateTimeStamp > DateTimeStamp And Not x.PhotoName = photoName) Then 'check if this is the latest rectum photo
                                    'Dim IntubationData = (From ce In db.ERS_ColonExtentOfIntubation Where ce.ProcedureId = procedureId).FirstOrDefault()

                                    'check if ttc via photo recorded and recalculate wt
                                    If IntubationData.TimeToCaecumMin_Photo IsNot Nothing Then
                                        Dim caecumPhoto = (From p In procedurePhotos
                                                           Let ppSiteName = SiteName(p.SiteId)
                                                           Where p.ProcedureId = procedureId And
                                                           ppSiteName.ToLower() = "caecum"
                                                           Order By p.DateTimeStamp).FirstOrDefault()

                                        If caecumPhoto IsNot Nothing Then
                                            Dim wt = DateTimeStamp.Subtract(caecumPhoto.p.DateTimeStamp.Value)
                                            IntubationData.TimeForWithdrawalMin_Photo = wt.Minutes
                                            IntubationData.TimeForWithdrawalSec_Photo = wt.Seconds

                                            db.Entry(IntubationData).State = Entity.EntityState.Modified
                                            db.SaveChanges()
                                            Update_ERS_Extent_Limiting_Factors(procedureId)
                                        End If
                                    End If
                                End If
                            End If
                        End If
                    End If
                End Using
            Catch ex As Exception
                Dim errorRef = LogManager.LogManagerInstance.LogError("Error during auto calculations", ex)
                Throw New AutoCalculationException("There was an error auto calculating you photo timings. Caecum/withdrawal times will need to be done manually.", errorRef)
            End Try

            Using db As New ERS.Data.GastroDbEntities
                'insert record
                db.ERS_Photos.Add(New ERS.Data.ERS_Photos() With {
.PhotoName = photoName,
.ProcedureId = procedureId,
                    .SiteId = siteId,
                    .DateTimeStamp = DateTimeStamp
                })
                db.SaveChanges()

                Dim isRecordExist = db.ERS_RecordCount.Any(Function(x) x.ProcedureId = procedureId AndAlso x.SiteId = siteId AndAlso x.Identifier = "Media")
                If Not isRecordExist Then
                    db.ERS_RecordCount.Add(New ERS_RecordCount() With {
                          .ProcedureId = procedureId,
                          .SiteId = siteId,
                          .Identifier = "Media",
                          .RecordCount = 1
                    })
                End If
                db.SaveChanges()

            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error during photo save routine", ex)
            Throw ex
        End Try

    End Sub

    Public Function MovePhoto(ByVal photoId As Integer, ByVal selectedSiteId As Nullable(Of Integer), ByVal siteId As Nullable(Of Integer), procedureId As Integer) As String
        'check if photo needs to do any time calculations
        '1a- if photo attached to caecum check if an initial photo has been set- if yes check if previous image added to caecum- if yes compare time stamp and see if this ones earlier- if yes calculate tts accordingly and update- finially, check for wt, if present recalculate based on attached image to rectum's timestamp
        '1b- if photo attached to rectum check if ttc recorded. If yes check if image already added to rectum- if yes compare timestamps and see if this ones earlier- if yes calculate wt and update
        '1c- check if photo was attached to caecum (if yes check if any _Photo times- BOTH! Needs removing if present)
        '1d- check if photo was attached to rectum (if yes check for withdrawal _Photo times- Needs removing if present)
        Try
            Dim newFileName = ""

            Using db As New ERS.Data.GastroDbEntities
                Dim procedurePhotos = db.ERS_Photos.Where(Function(x) x.ProcedureId = procedureId).ToList()
                Dim photo = procedurePhotos.Where(Function(x) x.PhotoId = photoId).FirstOrDefault()

                selectedSiteId = If(selectedSiteId = 0, Nothing, selectedSiteId)
                siteId = If(siteId = 0, Nothing, siteId)

                With photo
                    .SiteId = selectedSiteId
                    .WhoUpdatedId = LoggedInUserId
                    .WhenUpdated = Now
                End With

                'perform update before making any timing changes (if necessary) incase update fails
                db.Entry(photo).State = Entity.EntityState.Modified
                db.SaveChanges()

                Dim isRecordExist = db.ERS_RecordCount.Any(Function(x) x.ProcedureId = procedureId AndAlso x.SiteId = selectedSiteId AndAlso x.Identifier = "Media")
                If Not isRecordExist Then
                    db.ERS_RecordCount.Add(New ERS_RecordCount() With {
                          .ProcedureId = procedureId,
                          .SiteId = selectedSiteId,
                          .Identifier = "Media",
                          .RecordCount = 1
                    })
                End If
                db.SaveChanges()

                Dim isPhotoExist = db.ERS_Photos.Any(Function(x) x.ProcedureId = procedureId AndAlso x.SiteId = siteId)
                If Not isPhotoExist Then
                    Dim recordCount = db.ERS_RecordCount.FirstOrDefault(Function(x) x.ProcedureId = procedureId AndAlso x.SiteId = siteId AndAlso x.Identifier = "Media")
                    db.ERS_RecordCount.Remove(recordCount)
                End If
                db.SaveChanges()
            End Using

            Return newFileName
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function DeletePhoto(ByVal photoId As Integer, procedureId As Integer, ByVal siteId As Nullable(Of Integer)) As String
        '1- check if photo was attached to caecum and if photo timings have been recorded- if so check if another photos is attached to caecum and recalculate, otherwise remove ttc and wt timings
        '2- check if photo was attached to rectum and if photo times have been recorded- if so check another photos is attached to rectum and recalculate, otherwise remove wt timings
        Try
            Dim photoName = ""
            Using db As New ERS.Data.GastroDbEntities
                siteId = If(siteId = 0, Nothing, siteId)
                Dim dbRes = (From p In db.ERS_Photos Where p.ProcedureId = procedureId AndAlso p.SiteId = siteId)
                Dim photo = dbRes.Where(Function(x) x.PhotoId = photoId).FirstOrDefault()
                photoName = photo.PhotoName

                'perform update before making any timing changes (if necessary) incase update fails
                db.ERS_Photos.Remove(photo)
                db.SaveChanges()

                Dim isPhotoExist = db.ERS_Photos.Any(Function(x) x.ProcedureId = procedureId AndAlso x.SiteId = siteId)
                If Not isPhotoExist Then
                    Dim recordCount = db.ERS_RecordCount.FirstOrDefault(Function(x) x.ProcedureId = procedureId AndAlso x.SiteId = siteId AndAlso x.Identifier = "Media")
                    db.ERS_RecordCount.Remove(recordCount)
                End If
                db.SaveChanges()
            End Using

            Return photoName
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function DeletePhotoFromCache(ByVal cacheId As Integer) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("DELETE FROM ERS_Cache WHERE CacheId = @CacheId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@CacheId", cacheId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

#Region "OtherAbnormalities"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllOtherAbno() As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("OtherAbnormalities_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            End If

        End Using
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Protected Sub UpdateInsertOtherAbno(CancelReasonId As Integer, Code As String, Detail As String, CancelledByHospital As Boolean, Active As Boolean, UserId As Integer)

        InsertUpdateOtherAbno(Code, Detail, CancelledByHospital, Active, UserId, CancelReasonId)

    End Sub
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Protected Sub InsertNewOtherAbno(Code As String, Detail As String, CancelledByHospital As Boolean, Active As Boolean, UserId As Integer)

        InsertUpdateOtherAbno(Code, Detail, CancelledByHospital, Active, UserId)

    End Sub

    Public Sub InsertUpdateOtherAbno(Abnormality As String, Summary As String, Diagnoses As Boolean, Active As Boolean, UserId As Integer, Optional OtherId As Integer = 0)

        DataAccess.ExecuteScalerSQL("OtherAbnormalities_insert_update", CommandType.StoredProcedure, New SqlParameter() {
                                                New SqlParameter("@OtherId", OtherId),
                                                New SqlParameter("@Abnormality", Abnormality),
                                                New SqlParameter("@Summary", Summary),
                                                New SqlParameter("@Diagnoses", Diagnoses),
                                                New SqlParameter("@Active", Active),
                                                New SqlParameter("@UserId", UserId)})

    End Sub

#End Region


    'TODO - REVAMP THIS - CREATE A NEW AUDITLOG TABLE FOR ERS
    'Public Sub WriteAuditLog(ByVal appID As APP_ID_ENUM, _
    '                         ByVal eventType As EVENT_TYPE_ENUM, _
    '                         ByVal eventDesc As String, _
    '                         ByVal appVersion As String, _
    '                         ByVal userId As String, _
    '                         ByVal userFullName As String, _
    '                         ByVal hospitalId As String, _
    '                         ByVal operatingHospitalId As String, _
    '                         ByVal hospitalName As String, _
    '                         ByVal patientId As String, _
    '                         ByVal episodeNo As String, _
    '                         ByVal caseNoteNo As String)

    '    Dim Category As Integer = vbNull

    '    Select Case eventType
    '        Case EVENT_TYPE_ENUM.EventNewRec, EVENT_TYPE_ENUM.EventUpdateRec, EVENT_TYPE_ENUM.EventDeleteRec, EVENT_TYPE_ENUM.EventDownload, EVENT_TYPE_ENUM.EventConfig, EVENT_TYPE_ENUM.EventDatabase
    '            Category = 1 'CategoryApp
    '        Case EVENT_TYPE_ENUM.EventSearch, EVENT_TYPE_ENUM.EventReports, EVENT_TYPE_ENUM.EventView, EVENT_TYPE_ENUM.EventPrint, EVENT_TYPE_ENUM.EventExport
    '            Category = 2 'CategoryInfo
    '        Case EVENT_TYPE_ENUM.EventLogIn, EVENT_TYPE_ENUM.EventLogOut
    '            Category = 3 'CategorySecurity
    '    End Select

    '    Dim EpiNo As Long = vbNull

    '    Dim AuditDate As String = vbNullString
    '    Dim EpiDate As String = vbNullString

    '    AuditDate = Format(Now(), "yyyy-MM-dd HH:mm:ss")
    '    EpiDate = Format(Now(), "yyyy-MM-dd")

    '    Dim sSQL As String = vbNullString
    '    sSQL = "INSERT INTO [AuditLog] (" & _
    '      "[Category], [Event Type], [Date], [ApplicationID], [App Version], [UserID], " & _
    '      "[Full Username], [StationID], [HospitalID], [Hospital Name], " & _
    '      "[OperatingID], [Operating Name], [Patient No], [Proc Episode No], " & _
    '      "[Case note no], [Procedure Date], [Procedure Time], [Procedure Name], " & _
    '      "[Event Description]) VALUES (" & _
    '      Category & "," & eventType & ",'" & AuditDate & "','" & appID & "','" & appVersion & "','" & userId & "','" & _
    '      Utilities.FixString(userFullName) & "','UKN'," & hospitalId & ",'" & Utilities.FixString(hospitalName) & "'," & _
    '      operatingHospitalId & ",'" & Utilities.FixString(hospitalName) & "','" & patientId & "'," & episodeNo & ",'" & _
    '      caseNoteNo & "','" & EpiDate & "','" & Format(Now(), "HH:mm:ss") & "','Upper GI','" & _
    '      Utilities.FixString(eventDesc) & "');"

    '    Using connection As New SqlConnection(ConnectionStr)
    '        Dim cmd As New SqlCommand(sSQL, connection)
    '        cmd.CommandType = CommandType.Text

    '        connection.Open()
    '        cmd.ExecuteNonQuery()
    '    End Using
    'End Sub

    'TODO - REVAMP THIS - CREATE A NEW AUDITLOG TABLE FOR ERS
    Public Function GetAuditLog(ByVal categoryId As Integer) As DataTable
        Dim dsAuditLog As New DataSet
        Dim sSQL As String
        sSQL = "SELECT [Event Type] AS Event_Type, [Date], [Full Username] AS Full_Username, [StationID], [Event Description] AS Event_Description FROM [AuditLog]"
        If categoryId <> 0 Then
            sSQL = sSQL & " WHERE [Category] = " & categoryId
        End If
        sSQL = sSQL & " ORDER BY [Date] DESC"

        Return DataAccess.ExecuteSQL(sSQL, Nothing)

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateInstrument(ByVal Instrument1 As Integer, ByVal Instrument1NewItemText As String, ByVal Instrument2 As Integer, ByVal Instrument2NewItemText As String, ByVal InstrumentTxt As String, ByVal ProcedureId As Integer, ByVal ProcedureTypeId As Integer) As Integer
        Dim sql As New StringBuilder
        'Dim listDescription As String = String.Empty

        'If ProcedureTypeId = ProcedureType.Gastroscopy Then
        '    listDescription = "Instrument Upper GI"
        'ElseIf ProcedureTypeId = ProcedureType.ERCP Then
        '    listDescription = "Instrument ERCP"
        'ElseIf ProcedureTypeId = ProcedureType.Colonoscopy Or ProcedureTypeId = ProcedureType.Sigmoidscopy Or ProcedureTypeId = ProcedureType.Proctoscopy Then
        '    listDescription = "Instrument ColonSig"
        'ElseIf ProcedureTypeId = ProcedureType.EUS_OGD Or ProcedureType.EUS_HPB Then
        '    listDescription = "Instrument EUS"
        'ElseIf ProcedureTypeId = ProcedureType.Antegrade Then
        '    listDescription = "Instrument Antegrade"
        'ElseIf ProcedureTypeId = ProcedureType.Retrograde Then
        '    listDescription = "Instrument Retrograde"
        'ElseIf ProcedureTypeId = ProcedureType.Bronchoscopy Or ProcedureType.EBUS Or ProcedureType.Thoracoscopy Then
        '    listDescription = "Instrument Thoracic"
        'End If

        If Instrument1 = -99 Then
            Dim newId = InsertInstrument(Instrument1NewItemText)
            If newId > 0 Then
                Instrument1 = newId
            End If
        End If

        If Instrument2 = -99 Then
            Dim newId = InsertInstrument(Instrument2NewItemText)
            If newId > 0 Then
                Instrument2 = newId
            End If
            'Dim da As New DataAccess
            'Dim newId = da.InsertListItem(listDescription, Instrument2NewItemText)
            'If newId > 0 Then
            '    Instrument2 = newId
            'End If
        End If

        Try
            '### Update the PP Text Values in Reporting Table!
            Using db As New ERS.Data.GastroDbEntities
                Dim pr = db.ERS_ProceduresReporting.Find(ProcedureId)
                Dim proc = db.ERS_Procedures.Find(ProcedureId)
                If Not InstrumentTxt.Contains("(Transnasal)") And proc.Transnasal Then
                    InstrumentTxt = InstrumentTxt + " (Transnasal)"
                ElseIf InstrumentTxt.Contains("(Transnasal)") And Not proc.Transnasal Then
                    InstrumentTxt = InstrumentTxt.Replace(" (Transnasal)", "")
                End If
                pr.PP_Instrument = InstrumentTxt
                db.SaveChanges()
                Update_ProceduresReporting(ProcedureId)

            End Using
        Catch ex As Exception
            '## On Error Resume next.. Don't make any sound!! Just swalloooooow!!!
        End Try

        sql.Append("UPDATE ERS_Procedures ")
        sql.Append("SET Instrument1=@Instrument1, Instrument2=@Instrument2 ")
        sql.Append("WHERE ProcedureId=@ProcedureId; Exec Procedure_Updated @ProcedureId ;")

        Return DataAccess.ExecuteScalerSQL(sql.ToString(), CommandType.Text, New SqlParameter() _
                                    {New SqlParameter("@Instrument1", Instrument1),
                                     New SqlParameter("@Instrument2", Instrument2),
                                     New SqlParameter("@InstrumentTxt", InstrumentTxt),
                                     New SqlParameter("@ProcedureId", ProcedureId)})

    End Function

    Private Function InsertInstrument(ByVal ScopeName As String) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("INSERT INTO [dbo].[ERS_Scopes] ([ScopeName],[AllProcedureTypes],[HospitalId],[WhoCreatedId],[WhoUpdatedId]) 
                    VALUES (@ScopeName, 0, @HospitalId, @WhoCreatedId, @WhoUpdatedId); 
                    DECLARE @ScopeID INT = SCOPE_IDENTITY();
                    INSERT INTO [dbo].[ERS_ScopeProcedures] ([ScopeId],[ProcedureTypeId],[WhoCreatedId],[WhoUpdatedId]) 
                    VALUES (@ScopeID, @ProcedureType, @WhoCreatedId, @WhoUpdatedId);SELECT @ScopeID;", connection)
            cmd.Parameters.Add(New SqlParameter("@ScopeName", ScopeName))
            cmd.Parameters.Add(New SqlParameter("@HospitalId", CInt(Session("OperatingHospitalId"))))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE))))
            cmd.Parameters.Add(New SqlParameter("@WhoCreatedId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@WhoUpdatedId", LoggedInUserId))

            Try
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                Return CInt(cmd.ExecuteScalar())
            Catch ex As Exception
                Throw ex
            End Try

            Return 0

        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateProcedureField(ByVal FieldName As String, ByVal Value As Boolean, ByVal ProcedureId As Integer) As Integer
        Dim sql As New StringBuilder

        sql.Append("UPDATE ERS_Procedures ")
        sql.Append("SET " & FieldName & " = @Value ")
        sql.Append("WHERE ProcedureId=@ProcedureId ; Exec Procedure_Updated @ProcedureId ; ")

        Return DataAccess.ExecuteScalerSQL(sql.ToString(), CommandType.Text, New SqlParameter() _
                            {New SqlParameter("@ProcedureId", ProcedureId),
                             New SqlParameter("@Value", Value)})

    End Function

#Region "Premedication Drugs Settings"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPremedicationDrugs(ops As Integer) As DataTable
        Dim dsPatients As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("drugs_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@DrugType", ops))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsPatients)
        End Using

        If dsPatients.Tables.Count > 0 Then
            Return dsPatients.Tables(0)
        Else
            Return Nothing
        End If
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDrug(ByVal DrugID As Integer) As DataTable
        Dim dsDrug As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_drug", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugID))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsDrug)
        End Using
        If dsDrug.Tables.Count > 0 Then
            Return dsDrug.Tables(0)
        Else
            Return Nothing
        End If

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertDrug(DrugNo As Int32, DrugName As String, DrugType As Int32, Isreversingagent As Int32, Units As String, DoseNotApplicable As Boolean,
                           Defaultdose As Double, Doseincrement As Double, Deliverymethod As String, UsedinUpperGI As Int32, UsedinEUSOGD As Int32, UsedinERCP As Int32,
                           UsedinEUSHPB As Int32, UsedinColonSig As Int32, UsedinBroncho As Int32, UsedinEbus As Int32, UsedInAntegrade As Int32, UsedInRetrograde As Int32, UsedInFlexiCystoscopy As Int32, MaximumDose As Double) As Integer

        Dim dsDrug As New DataSet
        Dim sql As String = "INSERT INTO [ERS_DrugList] ([ProductID],[LocationID],[DrugType],[DrugName],[DeliveryMethod],[Units],[DefaultDose],[DoseIncrement],[UsedinColonSig],[UsedinERCP],[UsedinUpperGI],[Isreversingagent],[UsedinEUS_OGD],[UsedinEUS_HPB],DoseNotApplicable, [UsedInBroncho], [UsedInEBUS], [UsedInAntegrade], [UsedInRetrograde], [UsedInFlexiCystoscopy], [MaximumDose], WhoCreatedId, WhenCreated) " &
                    "VALUES ('GI','XXXX',@Drugtype,@Drugname,@Deliverymethod,@Units,@Defaultdose,@Doseincrement,@UsedinColonSig,@UsedinERCP,@UsedinUpperGI,@Isreversingagent,@UsedinEUSOGD,@UsedinEUSHPB,@DoseNotApplicable,@UsedInBroncho, @UsedInEBUS, @UsedInAntegrade, @UsedInRetrograde, @UsedInFlexiCystoscopy, @MaximumDose, @LoggedInUserId, GETDATE()) " &
                    "SELECT @@identity "
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
            cmd.Parameters.Add(New SqlParameter("@Drugtype", DrugType))
            cmd.Parameters.Add(New SqlParameter("@Drugname", DrugName))
            cmd.Parameters.Add(New SqlParameter("@Isreversingagent", Isreversingagent))
            If String.IsNullOrWhiteSpace(Units) Then
                cmd.Parameters.Add(New SqlParameter("@Units", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@Units", Units))
            End If
            cmd.Parameters.Add(New SqlParameter("@Defaultdose", Defaultdose))
            cmd.Parameters.Add(New SqlParameter("@Doseincrement", Doseincrement))
            cmd.Parameters.Add(New SqlParameter("@Deliverymethod", Deliverymethod))
            cmd.Parameters.Add(New SqlParameter("@UsedinUpperGI", UsedinUpperGI))
            cmd.Parameters.Add(New SqlParameter("@UsedinEUSOGD", UsedinEUSOGD))
            cmd.Parameters.Add(New SqlParameter("@UsedinERCP", UsedinERCP))
            cmd.Parameters.Add(New SqlParameter("@UsedinEUSHPB", UsedinEUSHPB))
            cmd.Parameters.Add(New SqlParameter("@UsedinBroncho", UsedinBroncho))
            cmd.Parameters.Add(New SqlParameter("@UsedInEBUS", UsedinEbus))
            cmd.Parameters.Add(New SqlParameter("@UsedinColonSig", UsedinColonSig))
            cmd.Parameters.Add(New SqlParameter("@UsedInAntegrade", UsedInAntegrade))
            cmd.Parameters.Add(New SqlParameter("@UsedInRetrograde", UsedInRetrograde))
            cmd.Parameters.Add(New SqlParameter("@UsedInFlexiCystoscopy", UsedInFlexiCystoscopy))
            cmd.Parameters.Add(New SqlParameter("@DoseNotApplicable", DoseNotApplicable))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@MaximumDose", MaximumDose))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateDrug(DrugNo As Int32,
                          Drugname As String, DrugType As Int32, Isreversingagent As Int32, Units As String, DoseNotApplicable As Boolean,
                           Defaultdose As Double, Doseincrement As Double, Deliverymethod As String, UsedinUpperGI As Int32, UsedinEUSOGD As Int32, UsedinERCP As Int32,
                           UsedinEUSHPB As Int32, UsedinColonSig As Int32, UsedinBroncho As Int32, UsedinEbus As Int32, UsedInAntegrade As Int32, UsedInRetrograde As Int32, UsedInFlexiCystoscopy As Int32, MaximumDose As Double) As Integer

        ' Ideally, the db column ERS_DrugList.Deliverymethod must be an integer connecting to the value from ERS_Lists. 
        ' But this is a varchar field. So check for the value in the ERS_Lists table, insert if not found.
        Dim dtDeliveryMethods As DataTable = GetDeliveryMethods()
        Dim matches = From r In dtDeliveryMethods.AsEnumerable()
                      Where r.Field(Of String)("ListItemText") = Deliverymethod
                      Select r
        If matches.Count = 0 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Premedication Delivery Method", Deliverymethod)
        End If

        Dim dsDrug As New DataSet
        Dim sql As String

        sql = "UPDATE [ERS_DrugList] SET [DrugType] = @Drugtype,  [DrugName] = @Drugname,  [DeliveryMethod] = @Deliverymethod, [Units]=@Units, [DefaultDose]=@Defaultdose, DoseNotApplicable = @DoseNotApplicable," &
    " [DoseIncrement] = @Doseincrement,  [UsedinColonSig] = @UsedinColonSig,   [UsedinERCP]=@UsedinERCP,  [UsedinUpperGI] = @UsedinUpperGI, [Isreversingagent]=@Isreversingagent, [UsedinEUS_OGD]=@UsedinEUSOGD," &
    " [UsedinEUS_HPB]=@UsedinEUSHPB, [UsedInBroncho]=@UsedInBroncho, [UsedInEBUS] = @UsedInEBUS, [UsedInAntegrade]=@UsedInAntegrade, [UsedInRetrograde]=@UsedInRetrograde, [UsedInFlexiCystoscopy]=@UsedInFlexiCystoscopy, [MaximumDose]=@MaximumDose, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE [DrugNo]=@DrugNo"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
            cmd.Parameters.Add(New SqlParameter("@Drugtype", DrugType)) ' set to zero
            cmd.Parameters.Add(New SqlParameter("@Drugname", Drugname))
            cmd.Parameters.Add(New SqlParameter("@Isreversingagent", Isreversingagent))

            If Not String.IsNullOrEmpty(Units) Then
                cmd.Parameters.Add(New SqlParameter("@Units", Units))
            Else
                cmd.Parameters.Add(New SqlParameter("@Units", SqlTypes.SqlString.Null))
            End If

            If Not String.IsNullOrEmpty(Deliverymethod) Then
                cmd.Parameters.Add(New SqlParameter("@Deliverymethod", Deliverymethod))
            Else
                cmd.Parameters.Add(New SqlParameter("@Deliverymethod", SqlTypes.SqlString.Null))
            End If
            'cmd.Parameters.Add(New SqlParameter("@Units", Units))
            cmd.Parameters.Add(New SqlParameter("@Defaultdose", Defaultdose))
            cmd.Parameters.Add(New SqlParameter("@Doseincrement", Doseincrement))
            'cmd.Parameters.Add(New SqlParameter("@Deliverymethod", Deliverymethod))
            cmd.Parameters.Add(New SqlParameter("@UsedinUpperGI", UsedinUpperGI))
            cmd.Parameters.Add(New SqlParameter("@UsedinEUSOGD", UsedinEUSOGD))
            cmd.Parameters.Add(New SqlParameter("@UsedinERCP", UsedinERCP))
            cmd.Parameters.Add(New SqlParameter("@UsedinEUSHPB", UsedinEUSHPB))
            cmd.Parameters.Add(New SqlParameter("@UsedinColonSig", UsedinColonSig))
            cmd.Parameters.Add(New SqlParameter("@UsedinBroncho", UsedinBroncho))
            cmd.Parameters.Add(New SqlParameter("@UsedinEbus", UsedinEbus))
            cmd.Parameters.Add(New SqlParameter("@UsedInAntegrade", UsedInAntegrade))
            cmd.Parameters.Add(New SqlParameter("@UsedInRetrograde", UsedInRetrograde))
            cmd.Parameters.Add(New SqlParameter("@UsedInFlexiCystoscopy", UsedInFlexiCystoscopy))
            cmd.Parameters.Add(New SqlParameter("@DoseNotApplicable", DoseNotApplicable))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@MaximumDose", MaximumDose))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

#Region "Regime"
    Public Function GetRegime(ByVal RegimeName As String) As Integer
        Dim value As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT TOP(1) RegimenNo FROM ERS_DrugRegime WHERE Description = @RegimeName"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@RegimeName", RegimeName))
            connection.Open()
            value = mycmd.ExecuteScalar()
        End Using
        Return value
    End Function
    Public Function GetMaxReg() As Integer
        Dim value As Integer = 1
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT ISNULL(MAX(RegimenNo), 1) FROM ERS_DrugRegime"
            Dim mycmd As New SqlCommand(querystr, connection)
            connection.Open()
            value = mycmd.ExecuteScalar()
        End Using
        Return value
    End Function
    Public Function SaveRegime(RegimenNo As Integer, Description As String, ProcedureNo As Integer, DrugNo As Integer, DrugDose As Double, Frequency As String, Duration As String, DrugCount As Integer, RegimeText As String) As Integer
        Dim sql As String = "INSERT INTO ERS_DrugRegime (RegimenNo, Description, ProcedureNo, DrugNo, DrugDose, Frequency, Duration, DrugCount, RegimeText)  VALUES (@RegimenNo, @Description, @ProcedureNo, @DrugNo, @DrugDose, @Frequency, @Duration, @DrugCount, @RegimeText) "
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RegimenNo", RegimenNo))
            'cmd.Parameters.Add(New SqlParameter("@Drugtype", Drugtype))
            cmd.Parameters.Add(New SqlParameter("@Description", Description))
            cmd.Parameters.Add(New SqlParameter("@ProcedureNo", ProcedureNo))
            cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
            cmd.Parameters.Add(New SqlParameter("@DrugDose", DrugDose))
            cmd.Parameters.Add(New SqlParameter("@Frequency", Frequency))
            cmd.Parameters.Add(New SqlParameter("@Duration", Duration))
            cmd.Parameters.Add(New SqlParameter("@DrugCount", DrugCount))
            cmd.Parameters.Add(New SqlParameter("@RegimeText", RegimeText))
            connection.Open()
            Return CInt(cmd.ExecuteScalar())
        End Using
    End Function
    Public Function DeleteRegime(DescriptionText As String) As Integer
        Dim sql As String = "DELETE FROM ERS_DrugRegime WHERE [Description] = @DescriptionText"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DescriptionText", DescriptionText))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function LoadRegimeData(ByVal regimeID As Integer) As DataTable
        Dim dsResult As New DataSet
        Dim sql As String = "SELECT RegimenNo, Description, ProcedureNo, DrugNo, DrugDose, Frequency, Duration, DrugCount, RegimeText FROM ERS_DrugRegime WHERE RegimenNo = @RegimeNo  "
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@RegimeNo", regimeID))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function SavePrescription(ProcedureNo As Integer, DrugCount As Integer, DrugNo As Integer, DrugDose As Double, Frequency As String, Duration As String, HPyloriDrug As Boolean, WhoPrescribed As String, AuthenticationDate As Date, AuthenticatedBy As String, PrescriptionText As String) As Integer

        ' Ideally, the db column ERS_PatientMedication.Frequency must be an integer connecting to the value from ERS_Lists. 
        ' But this is a varchar field. So check for the value in the ERS_Lists table, insert if not found.
        Dim dtFrequency As DataTable = GetMedicationFrequency()
        Dim matches = From r In dtFrequency.AsEnumerable()
                      Where r.Field(Of String)("ListItemText") = Frequency
                      Select r
        If matches.Count = 0 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Medication_Frequency", Frequency)
        End If
        Try
            Dim sql As String = "ogd_rx_prescription_save"
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureNo", ProcedureNo))
                cmd.Parameters.Add(New SqlParameter("@DrugCount", DrugCount))
                cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
                cmd.Parameters.Add(New SqlParameter("@DrugDose", DrugDose))
                cmd.Parameters.Add(New SqlParameter("@Frequency", Frequency))
                cmd.Parameters.Add(New SqlParameter("@Duration", Duration))
                cmd.Parameters.Add(New SqlParameter("@HPyloriDrug", HPyloriDrug))
                cmd.Parameters.Add(New SqlParameter("@WhoPrescribed", WhoPrescribed))
                cmd.Parameters.Add(New SqlParameter("@PrescriptionText", PrescriptionText))
                If AuthenticationDate = Nothing Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AuthenticationDate", .SqlDbType = SqlDbType.Date, .Value = DBNull.Value})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AuthenticationDate", .SqlDbType = SqlDbType.Date, .Value = AuthenticationDate})
                End If
                If AuthenticatedBy = Nothing Then
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AuthenticatedBy", .SqlDbType = SqlDbType.VarChar, .Value = DBNull.Value})
                Else
                    cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AuthenticatedBy", .SqlDbType = SqlDbType.VarChar, .Value = AuthenticatedBy})
                End If
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

                connection.Open()
                Return CInt(cmd.ExecuteNonQuery())

            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function LoadPrescriptionData(ByVal ProcedureNo As Integer, WhoPrescribed As String) As DataTable
        Dim dsResult As New DataSet
        Dim sql As String = "SELECT dbo.fnCapitalise(l.drugname+'#'+cast(m.DrugDose as varchar(50))+'#'+ISNULL(l.units,'')+'#'+ ISNULL(l.deliverymethod,'')+'#'+m.Frequency+'#'+m.Duration+'#'+cast(l.doseincrement as varchar(50))+'#'+cast(m.DrugNo as varchar(50)) + '#' + cast(ISNULL(l.MaximumDose,'') as varchar(50))) as [text] FROM [dbo].[ERS_PatientMedication] m left join [ERS_DrugList] l on m.[DrugNo] =l.[DrugNo] WHERE m.ProcedureNo = @ProcedureNO AND m.WhoPrescribed = @WhoPrescribed"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureNo", ProcedureNo))
            cmd.Parameters.Add(New SqlParameter("@WhoPrescribed", WhoPrescribed))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function DeletePrescription(ByVal ProcedureNo As Integer, WhoPrescribed As String) As Integer
        Dim sql As String = "DELETE FROM ERS_PatientMedication WHERE ProcedureNo = @ProcedureNO AND WhoPrescribed = @WhoPrescribed"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureNo", ProcedureNo))
            cmd.Parameters.Add(New SqlParameter("@WhoPrescribed", WhoPrescribed))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

#Region "Print Options"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintOptions(opertingHospitalId As Integer) As DataSet
        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("SELECT * FROM ERS_PrintOptionsGPReport WHERE OperatingHospitalId = @OperatingHospitalId ")
        qry.Append("SELECT * FROM ERS_PrintOptionsLabRequestReport WHERE OperatingHospitalId = @OperatingHospitalId ")
        qry.Append("SELECT * FROM ERS_PrintOptionsPatientFriendlyReport WHERE OperatingHospitalId = @OperatingHospitalId ")
        qry.Append("SELECT * FROM ERS_PrintOptionsPatientFriendlyReportAdditional WHERE OperatingHospitalId = @OperatingHospitalId ")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", opertingHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsProcedures)
        End Using

        If dsProcedures.Tables.Count > 0 Then
            Return dsProcedures
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPrintOptionsPatientFriendlyReportAdditional(Optional ByVal OperatingHospitalId As Integer = 0, Optional ByVal includedOnly As Boolean = False) As DataTable
        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("SELECT AdditionalText FROM ERS_PrintOptionsPatientFriendlyReportAdditional ")
        If includedOnly Then
            qry.Append(" WHERE IncludeAdditionalText = 1 ")
        End If
        'qry.Append("WHERE OperatingHospitalID = " & CStr(OperatingHospitalId))
        'If includedOnly Then
        '    qry.Append(" AND IncludeAdditionalText = 1 ")
        'End If

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsProcedures)
        End Using

        If dsProcedures.Tables.Count > 0 Then
            Return dsProcedures.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SaveGPReportPrintOptions(ByVal IncludeDiagram As Boolean,
                                             ByVal IncludeDiagramOnlyIfSitesExist As Boolean,
                                             ByVal IncludeListConsultant As Boolean,
                                             ByVal IncludeNurses As Boolean,
                                             ByVal IncludeInstrument As Boolean,
                                             ByVal IncludeMissingCaseNote As Boolean,
                                             ByVal IncludeIndications As Boolean,
                                             ByVal IncludeCoMorbidities As Boolean,
                                             ByVal IncludePlannedProcedures As Boolean,
                                             ByVal IncludePremedication As Boolean,
                                             ByVal IncludeProcedureNotes As Boolean,
                                             ByVal IncludeSiteNotes As Boolean,
                                             ByVal IncludeBowelPreparation As Boolean,
                                             ByVal IncludeExtentOfIntubation As Boolean,
                                             ByVal IncludePreviousGastricUlcer As Boolean,
                                             ByVal IncludeExtentAndLimitingFactors As Boolean,
                                             ByVal IncludeCannulation As Boolean,
                                             ByVal IncludeExtentOfVisualisation As Boolean,
                                             ByVal IncludeContrastMediaUsed As Boolean,
                                             ByVal IncludePapillaryAnatomy As Boolean,
                                             ByVal IncludeDiagnoses As Boolean,
                                             ByVal IncludeFollowUp As Boolean,
                                             ByVal IncludeTherapeuticProcedures As Boolean,
                                             ByVal IncludeSpecimensTaken As Boolean,
                                             ByVal IncludePeriOperativeComplications As Boolean,
                                             ByVal DefaultNumberOfCopies As Integer,
                                             ByVal DefaultNumberOfPhotos As Integer,
                                             ByVal DefaultPhotoSize As Integer,
                                             ByVal DefaultExportImage As Boolean,
                                             ByVal PrintType As Integer,
                                             ByVal PrintDoubleSided As Boolean,
                                             ByVal OperatingHospitalId As Integer) As Integer

        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("UPDATE ERS_PrintOptionsGPReport SET ")
        qry.Append("IncludeDiagram = @IncludeDiagram")
        qry.Append(",IncludeDiagramOnlyIfSitesExist = @IncludeDiagramOnlyIfSitesExist")
        qry.Append(",IncludeListConsultant = @IncludeListConsultant")
        qry.Append(",IncludeNurses = @IncludeNurses")
        qry.Append(",IncludeInstrument = @IncludeInstrument")
        qry.Append(",IncludeMissingCaseNote = @IncludeMissingCaseNote")
        qry.Append(",IncludeIndications = @IncludeIndications")
        qry.Append(",IncludeCoMorbidities = @IncludeCoMorbidities")
        qry.Append(",IncludePlannedProcedures = @IncludePlannedProcedures")
        qry.Append(",IncludePremedication = @IncludePremedication")
        qry.Append(",IncludeProcedureNotes = @IncludeProcedureNotes")
        qry.Append(",IncludeSiteNotes = @IncludeSiteNotes")
        qry.Append(",IncludeBowelPreparation = @IncludeBowelPreparation")
        qry.Append(",IncludeExtentOfIntubation = @IncludeExtentOfIntubation")
        qry.Append(",IncludePreviousGastricUlcer = @IncludePreviousGastricUlcer")
        qry.Append(",IncludeExtentAndLimitingFactors = @IncludeExtentAndLimitingFactors")
        qry.Append(",IncludeCannulation = @IncludeCannulation")
        qry.Append(",IncludeExtentOfVisualisation = @IncludeExtentOfVisualisation")
        qry.Append(",IncludeContrastMediaUsed = @IncludeContrastMediaUsed")
        qry.Append(",IncludePapillaryAnatomy = @IncludePapillaryAnatomy")
        qry.Append(",IncludeDiagnoses = @IncludeDiagnoses")
        qry.Append(",IncludeFollowUp = @IncludeFollowUp")
        qry.Append(",IncludeTherapeuticProcedures = @IncludeTherapeuticProcedures")
        qry.Append(",IncludeSpecimensTaken = @IncludeSpecimensTaken")
        qry.Append(",IncludePeriOperativeComplications = @IncludePeriOperativeComplications")
        qry.Append(",DefaultNumberOfCopies = @DefaultNumberOfCopies")
        qry.Append(",DefaultNumberOfPhotos = @DefaultNumberOfPhotos")
        qry.Append(",DefaultPhotoSize = @DefaultPhotoSize")
        qry.Append(",PrintOnExport = @DefaultExportImage")
        qry.Append(",PrintType = @PrintType")
        qry.Append(",PrintDoubleSided = @PrintDoubleSided")
        qry.Append(",WhoUpdatedId = @LoggedInUserId")
        qry.Append(",WhenUpdated = GETDATE()")
        qry.Append(" WHERE OperatingHospitalId = @OperatingHospitalId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@IncludeDiagram", IncludeDiagram))
            cmd.Parameters.Add(New SqlParameter("@IncludeDiagramOnlyIfSitesExist", IncludeDiagramOnlyIfSitesExist))
            cmd.Parameters.Add(New SqlParameter("@IncludeListConsultant", IncludeListConsultant))
            cmd.Parameters.Add(New SqlParameter("@IncludeNurses", IncludeNurses))
            cmd.Parameters.Add(New SqlParameter("@IncludeInstrument", IncludeInstrument))
            cmd.Parameters.Add(New SqlParameter("@IncludeMissingCaseNote", IncludeMissingCaseNote))
            cmd.Parameters.Add(New SqlParameter("@IncludeIndications", IncludeIndications))
            cmd.Parameters.Add(New SqlParameter("@IncludeCoMorbidities", IncludeCoMorbidities))
            cmd.Parameters.Add(New SqlParameter("@IncludePlannedProcedures", IncludePlannedProcedures))
            cmd.Parameters.Add(New SqlParameter("@IncludePremedication", IncludePremedication))
            cmd.Parameters.Add(New SqlParameter("@IncludeProcedureNotes", IncludeProcedureNotes))
            cmd.Parameters.Add(New SqlParameter("@IncludeSiteNotes", IncludeSiteNotes))
            cmd.Parameters.Add(New SqlParameter("@IncludeBowelPreparation", IncludeBowelPreparation))
            cmd.Parameters.Add(New SqlParameter("@IncludeExtentOfIntubation", IncludeExtentOfIntubation))
            cmd.Parameters.Add(New SqlParameter("@IncludePreviousGastricUlcer", IncludePreviousGastricUlcer))
            cmd.Parameters.Add(New SqlParameter("@IncludeExtentAndLimitingFactors", IncludeExtentAndLimitingFactors))
            cmd.Parameters.Add(New SqlParameter("@IncludeCannulation", IncludeCannulation))
            cmd.Parameters.Add(New SqlParameter("@IncludeExtentOfVisualisation", IncludeExtentOfVisualisation))
            cmd.Parameters.Add(New SqlParameter("@IncludeContrastMediaUsed", IncludeContrastMediaUsed))
            cmd.Parameters.Add(New SqlParameter("@IncludePapillaryAnatomy", IncludePapillaryAnatomy))
            cmd.Parameters.Add(New SqlParameter("@IncludeDiagnoses", IncludeDiagnoses))
            cmd.Parameters.Add(New SqlParameter("@IncludeFollowUp", IncludeFollowUp))
            cmd.Parameters.Add(New SqlParameter("@IncludeTherapeuticProcedures", IncludeTherapeuticProcedures))
            cmd.Parameters.Add(New SqlParameter("@IncludeSpecimensTaken", IncludeSpecimensTaken))
            cmd.Parameters.Add(New SqlParameter("@IncludePeriOperativeComplications", IncludePeriOperativeComplications))
            cmd.Parameters.Add(New SqlParameter("@DefaultNumberOfCopies", DefaultNumberOfCopies))
            cmd.Parameters.Add(New SqlParameter("@DefaultNumberOfPhotos", DefaultNumberOfPhotos))
            cmd.Parameters.Add(New SqlParameter("@DefaultPhotoSize", DefaultPhotoSize))
            cmd.Parameters.Add(New SqlParameter("@DefaultExportImage", DefaultExportImage))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@PrintType", PrintType))
            cmd.Parameters.Add(New SqlParameter("@PrintDoubleSided", PrintDoubleSided))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function SaveLabRequestReportPrintOptions(ByVal OneRequestForEverySpecimen As Boolean,
                                                     ByVal GroupSpecimensByDestination As Boolean,
                                                     ByVal RequestsPerA4Page As Integer,
                                                     ByVal IncludeDiagram As Boolean,
                                                     ByVal IncludeTimeSpecimenCollected As Boolean,
                                                     ByVal IncludeHeading As Boolean,
                                                     ByVal Heading As String,
                                                     ByVal IncludeIndications As Boolean,
                                                     ByVal IncludeProcedureNotes As Boolean,
                                                     ByVal IncludeAbnormalities As Boolean,
                                                     ByVal IncludeSiteNotes As Boolean,
                                                     ByVal IncludeDiagnoses As Boolean,
                                                     ByVal DefaultNumberOfCopies As Integer,
                                                     ByVal OperatingHospitalId As Integer) As Integer

        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("UPDATE ERS_PrintOptionsLabRequestReport SET ")
        qry.Append("OneRequestForEverySpecimen = @OneRequestForEverySpecimen")
        qry.Append(",GroupSpecimensByDestination = @GroupSpecimensByDestination")
        qry.Append(",RequestsPerA4Page = @RequestsPerA4Page")
        qry.Append(",IncludeDiagram = @IncludeDiagram")
        qry.Append(",IncludeTimeSpecimenCollected = @IncludeTimeSpecimenCollected")
        qry.Append(",IncludeHeading = @IncludeHeading")
        qry.Append(",Heading = @Heading")
        qry.Append(",IncludeIndications = @IncludeIndications")
        qry.Append(",IncludeProcedureNotes = @IncludeProcedureNotes")
        qry.Append(",IncludeAbnormalities = @IncludeAbnormalities")
        qry.Append(",IncludeSiteNotes = @IncludeSiteNotes")
        qry.Append(",IncludeDiagnoses = @IncludeDiagnoses")
        qry.Append(",WhoUpdatedId = @LoggedInUserId")
        qry.Append(",DefaultNumberOfCopies = @DefaultNumberOfCopies")
        qry.Append(",WhenUpdated = GETDATE()")
        qry.Append(" WHERE OperatingHospitalId = @OperatingHospitalId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@OneRequestForEverySpecimen", OneRequestForEverySpecimen))
            cmd.Parameters.Add(New SqlParameter("@GroupSpecimensByDestination", GroupSpecimensByDestination))
            cmd.Parameters.Add(New SqlParameter("@RequestsPerA4Page", RequestsPerA4Page))
            cmd.Parameters.Add(New SqlParameter("@IncludeDiagram", IncludeDiagram))
            cmd.Parameters.Add(New SqlParameter("@IncludeTimeSpecimenCollected", IncludeTimeSpecimenCollected))
            cmd.Parameters.Add(New SqlParameter("@IncludeHeading", IncludeHeading))
            cmd.Parameters.Add(New SqlParameter("@Heading", Heading))
            cmd.Parameters.Add(New SqlParameter("@IncludeIndications", IncludeIndications))
            cmd.Parameters.Add(New SqlParameter("@IncludeProcedureNotes", IncludeProcedureNotes))
            cmd.Parameters.Add(New SqlParameter("@IncludeAbnormalities", IncludeAbnormalities))
            cmd.Parameters.Add(New SqlParameter("@IncludeSiteNotes", IncludeSiteNotes))
            cmd.Parameters.Add(New SqlParameter("@IncludeDiagnoses", IncludeDiagnoses))
            cmd.Parameters.Add(New SqlParameter("@DefaultNumberOfCopies", DefaultNumberOfCopies))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function SavePatientFriendlyReportPrintOptions(ByVal IncludeNoFollowup As Boolean,
                                                          ByVal IncludeUreaseText As Boolean,
                                                          ByVal UreaseText As String,
                                                          ByVal IncludePolypectomyText As Boolean,
                                                          ByVal PolypectomyText As String,
                                                          ByVal IncludeOtherBiopsyText As Boolean,
                                                          ByVal OtherBiopsyText As String,
                                                          ByVal IncludeAnyOtherBiopsyText As Boolean,
                                                          ByVal AnyOtherBiopsyText As String,
                                                          ByVal IncludeAdviceComments As Boolean,
                                                          ByVal IncludePreceedAdviceComments As Boolean,
                                                          ByVal PreceedAdviceComments As String,
                                                          ByVal IncludeFinalText As Boolean,
                                                          ByVal FinalText As String,
                                                          ByVal DefaultNumberOfCopies As String,
                                                          ByVal OperatingHospitalId As Integer) As Integer

        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        qry.Append("UPDATE ERS_PrintOptionsPatientFriendlyReport SET ")
        qry.Append("IncludeNoFollowup = @IncludeNoFollowup")
        qry.Append(",IncludeUreaseText = @IncludeUreaseText")
        qry.Append(",UreaseText = @UreaseText")
        qry.Append(",IncludePolypectomyText = @IncludePolypectomyText")
        qry.Append(",PolypectomyText = @PolypectomyText")
        qry.Append(",IncludeOtherBiopsyText = @IncludeOtherBiopsyText")
        qry.Append(",OtherBiopsyText = @OtherBiopsyText")
        qry.Append(",IncludeAnyOtherBiopsyText = @IncludeAnyOtherBiopsyText")
        qry.Append(",AnyOtherBiopsyText = @AnyOtherBiopsyText")
        qry.Append(",IncludeAdviceComments = @IncludeAdviceComments")
        qry.Append(",IncludePreceedAdviceComments = @IncludePreceedAdviceComments")
        qry.Append(",PreceedAdviceComments = @PreceedAdviceComments")
        qry.Append(",IncludeFinalText = @IncludeFinalText")
        qry.Append(",FinalText = @FinalText")
        qry.Append(",DefaultNumberOfCopies = @DefaultNumberOfCopies")
        qry.Append(",WhoUpdatedId = @LoggedInUserId")
        qry.Append(",WhenUpdated = GETDATE()")
        qry.Append(" WHERE OperatingHospitalId = @OperatingHospitalId")

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@IncludeNoFollowup", IncludeNoFollowup))
            cmd.Parameters.Add(New SqlParameter("@IncludeUreaseText", IncludeUreaseText))
            cmd.Parameters.Add(New SqlParameter("@UreaseText", UreaseText))
            cmd.Parameters.Add(New SqlParameter("@IncludePolypectomyText", IncludePolypectomyText))
            cmd.Parameters.Add(New SqlParameter("@PolypectomyText", PolypectomyText))
            cmd.Parameters.Add(New SqlParameter("@IncludeOtherBiopsyText", IncludeOtherBiopsyText))
            cmd.Parameters.Add(New SqlParameter("@OtherBiopsyText", OtherBiopsyText))
            cmd.Parameters.Add(New SqlParameter("@IncludeAnyOtherBiopsyText", IncludeAnyOtherBiopsyText))
            cmd.Parameters.Add(New SqlParameter("@AnyOtherBiopsyText", AnyOtherBiopsyText))
            cmd.Parameters.Add(New SqlParameter("@IncludeAdviceComments", IncludeAdviceComments))
            cmd.Parameters.Add(New SqlParameter("@IncludePreceedAdviceComments", IncludePreceedAdviceComments))
            cmd.Parameters.Add(New SqlParameter("@PreceedAdviceComments", PreceedAdviceComments))
            cmd.Parameters.Add(New SqlParameter("@IncludeFinalText", IncludeFinalText))
            cmd.Parameters.Add(New SqlParameter("@FinalText", FinalText))
            cmd.Parameters.Add(New SqlParameter("@DefaultNumberOfCopies", DefaultNumberOfCopies))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Public Function SavePatientFriendlyReportAdditionalPrintOptions(ByVal Id As Integer,
                                                                    ByVal IncludeAdditionalText As Boolean,
                                                                    ByVal AdditionalText As String,
                                                                    ByVal OperatingHospitalId As Integer) As Integer
        Dim dsProcedures As New DataSet
        Dim qry As New StringBuilder()

        If Id > 0 Then
            qry.Append("UPDATE ERS_PrintOptionsPatientFriendlyReportAdditional SET ")
            qry.Append("IncludeAdditionalText = @IncludeAdditionalText ")
            qry.Append(",AdditionalText = @AdditionalText ")
            qry.Append(",WhoUpdatedId = @LoggedInUserId ")
            qry.Append(",WhenUpdated = GETDATE()")
            qry.Append(" WHERE Id = @Id")
        Else
            qry.Append("INSERT INTO ERS_PrintOptionsPatientFriendlyReportAdditional, WhoCreatedId, WhenCreated ")
            qry.Append("VALUES (@IncludeAdditionalText, @AdditionalText, @LoggedInUserId, GETDATE())")
        End If

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(qry.ToString(), connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@Id", Id))
            cmd.Parameters.Add(New SqlParameter("@IncludeAdditionalText", IncludeAdditionalText))
            cmd.Parameters.Add(New SqlParameter("@AdditionalText", AdditionalText))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function
#End Region

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiagnoses(ProcedureTypeID As Integer, Section As String) As DataTable
        Dim ds As New DataSet
        Dim sql As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand
            If IsNothing(Section) Then
                sql = "SELECT * FROM ERS_DiagnosesMatrix WHERE ProcedureTypeID = @ProcedureTypeID AND Visible = 1 ORDER BY OrderByNumber"
            Else
                sql = "SELECT * FROM ERS_DiagnosesMatrix WHERE ProcedureTypeID = @ProcedureTypeID  AND Section = @Section AND Visible = 1 ORDER BY OrderByNumber"
                cmd.Parameters.Add(New SqlParameter("@Section", Section))
            End If
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", ProcedureTypeID))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)

            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function getProcedureChartByYear(operatingHospitalsIds As String) As DataTable
        Return ExecuteSP("report_procedure_yearly", New SqlParameter() {New SqlParameter("@operatingHospitalsIds", operatingHospitalsIds), New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId")))})
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function getProcedureChartByMonth(ProcedureYear As String, operatingHospitalsIds As String) As DataTable
        Return ExecuteSP("report_procedure_monthly", New SqlParameter() {New SqlParameter("@ProcedureYear", ProcedureYear), New SqlParameter("@operatingHospitalsIds", operatingHospitalsIds), New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId")))})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function getProcedureChartYears() As DataTable

        Return ExecuteSP("chart_get_procedure_years", Nothing)

        'Dim ds As New DataSet
        'Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        'Dim cmd As New SqlCommand
        'Dim sql As String = " IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Colon Procedure'))  " &
        '    " BEGIN " &
        '    " select year([Procedure date]) as ProcedureYear FROM [Colon Procedure] where year([Procedure date]) IS NOT NULL group by year([Procedure date]) union " &
        '    " select year([Procedure date]) as ProcedureYear from [Upper GI Procedure] where year([Procedure date]) IS NOT NULL group by year([Procedure date]) union " &
        '    "  select year([Procedure date]) as ProcedureYear from [ERCP Procedure] where year([Procedure date]) IS NOT NULL group by year([Procedure date]) union " &
        '    " select year([Procedure date]) as ProcedureYear from [EUS procedure] where year([Procedure date]) IS NOT NULL group by year([Procedure date])" &
        '    " END ELSE SELECT 0 AS ProcedureYear"
        'Return ExecuteSQL(sql, Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetListDetails(ListDescription As String, Suppressed As Boolean, OrderBy As String) As DataTable
        Dim sql As String = "SELECT [ListItemNo], [ListItemText] FROM [ERS_Lists] WHERE (([ListDescription] = @ListDescription) AND ([Suppressed] = @Suppressed))"
        If OrderBy <> "" Then sql = sql + "ORDER BY " & OrderBy

        Return ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@ListDescription", ListDescription),
                                                                         New SqlParameter("@Suppressed", Suppressed)})

        'Return ExecuteSP("report_procedure_monthly", New SqlParameter() {New SqlParameter("@ListDescription", ListDescription), _
        '                                                                 New SqlParameter("@Suppressed", Suppressed)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDrugType(Drug_type As Integer) As DataTable
        Dim ds As New DataSet
        Dim sUsedInProcedures As String = ""
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand

            Select Case CInt(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_TYPE))
                Case ProcedureType.Gastroscopy
                    sUsedInProcedures = "UsedInUpperGI"
                Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy
                    sUsedInProcedures = "UsedInColonSig"
                Case ProcedureType.ERCP
                    sUsedInProcedures = "UsedInERCP"
                Case ProcedureType.EUS_OGD
                    sUsedInProcedures = "UsedInEUS_OGD"
                Case ProcedureType.EUS_HPB
                    sUsedInProcedures = "UsedInEUS_HPB"
            End Select

            If sUsedInProcedures <> "" Then sUsedInProcedures = " AND " & sUsedInProcedures & " = 1 "

            Dim sql As String = "SELECT [Drugno] as Drug_no , [Drugname] + " &
                                " COALESCE( '('+ [Deliverymethod] + ' in ' + [Units] + ')', '('+ [Deliverymethod] + ')', '('+ [Units] + ')', '')   AS Drug_Alias " &
                                " FROM [ERS_Druglist] WHERE ([Drugtype] = @Drug_type) " & sUsedInProcedures & " ORDER BY [Drugname], [Deliverymethod], [Units] "
            cmd.CommandText = sql
            cmd.Connection = connection
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@Drug_type", Drug_type))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(ds)
            If ds.Tables.Count > 0 Then
                Return ds.Tables(0)
            Else
                Return Nothing
            End If
        End Using
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDrugRegime() As DataTable
        Return ExecuteSQL("SELECT DISTINCT [RegimenNo] AS Regimen_No, [Description] FROM [ERS_DrugRegime]", Nothing)
        'Dim ds As New DataSet
        'Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        'Dim cmd As New SqlCommand
        'Dim sql As String = "SELECT DISTINCT [RegimenNo] AS Regimen_No, [Description] FROM [ERS_DrugRegime]"
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
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDrugInfo(DrugNo As Integer) As DataTable

        Dim sql As String = "SELECT DrugNo, [DrugName] as Name,[DeliveryMethod] as Method, Units,[DefaultDose] as Dosage, [DoseIncrement] as Increment, ISNULL(DoseNotApplicable,0) AS DoseNotApplicable, [MaximumDose] AS MaximumDose  FROM [ERS_DrugList] WHERE ( [DrugNo] =@DrugNo)"
        Return ExecuteSQL(sql, New SqlParameter() {New SqlParameter("@DrugNo", DrugNo)})
        'Dim ds As New DataSet
        'Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        'Dim cmd As New SqlCommand
        'cmd.CommandText = sql
        'cmd.Connection = connection
        'cmd.CommandType = CommandType.Text
        'cmd.Parameters.Add(New SqlParameter("@DrugNo", DrugNo))
        'Dim adapter = New SqlDataAdapter(cmd)
        'connection.Open()
        'adapter.Fill(ds)
        'If ds.Tables.Count > 0 Then
        '    Return ds.Tables(0)
        'Else
        '    Return Nothing
        'End If
    End Function
    Public Function UpdateWHOSurgicalSafetyCheckList(ProcedureID As Integer, SurgicalSafetyCheckListCompleted As Nullable(Of Boolean)) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("UPDATE [ERS_Procedures] SET SurgicalSafetyCheckListCompleted = @SurgicalSafetyCheckListCompleted WHERE ProcedureID = @ProcedureID ; Exec Procedure_Updated @ProcedureID ; ", connection)
            cmd.CommandType = CommandType.Text
            If IsNothing(SurgicalSafetyCheckListCompleted) Then
                cmd.Parameters.Add(New SqlParameter("@SurgicalSafetyCheckListCompleted", SqlTypes.SqlBoolean.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@SurgicalSafetyCheckListCompleted", SurgicalSafetyCheckListCompleted))
            End If

            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            Return cmd.ExecuteNonQuery
        End Using
    End Function
    Public Function GetWHOSurgicalSafetyCheckList(ProcedureID As Integer) As Nullable(Of Integer)
        Dim sVal As Object
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT SurgicalSafetyCheckListCompleted FROM [ERS_Procedures] WHERE ProcedureID = @ProcedureID", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            sVal = cmd.ExecuteScalar()
            If Not IsDBNull(sVal) AndAlso Not IsNothing(sVal) Then
                If CBool(sVal) Then Return 1 Else Return 0
            Else
                Return Nothing
            End If
        End Using
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetExportDocumentFilePrefix() As String
        Dim strExportDocFilePrfix As String = ""
        Dim dtData As New DataTable

        Dim sqlStr As String = "SELECT ExportDocumentFilePrefix From ERS_OperatingHospitals Where OperatingHospitalID = @OperatingHospitalID"

        dtData = DataAccess.ExecuteSQL(sqlStr.ToString(), New SqlParameter() {New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId")))})
        If dtData.Rows.Count > 0 Then
            If Not IsDBNull(dtData.Rows(0)("ExportDocumentFilePrefix")) Then
                strExportDocFilePrfix = dtData.Rows(0)("ExportDocumentFilePrefix").ToString().Trim()
            End If
        End If
        Return strExportDocFilePrfix
    End Function
    Public Function GetMenuMapItems(UserID As Integer, isViewer As Boolean, isDemoVersion As Boolean, MenuCategory As String) As DataTable
        Return ExecuteSP("common_select_menu", New SqlParameter() {
                                                    New SqlParameter("@isViewer", isViewer),
                                                    New SqlParameter("@MenuCategory", MenuCategory),
                                                    New SqlParameter("@isDemoVersion", isDemoVersion),
                                                    New SqlParameter("@UserID", UserID),
                                                    New SqlParameter("@OperatingHospitalId", CInt(Session("OperatingHospitalId")))})
    End Function
    Public Function InsertControl(Control As String, ControlType As String, Others As String, Page As String)
        If Control Is Nothing Then Return Nothing

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("IF NOT EXISTS (SELECT 1 FROM tempo where [Control]=@Control AND [Page]=@Page) INSERT INTO tempo ([Control],[ControlType],[Others],[Page]) values (@Control,@ControlType,@Others,@Page)", connection)
                cmd.CommandType = CommandType.Text
                If String.IsNullOrEmpty(Control) Then
                    cmd.Parameters.Add(New SqlParameter("@Control", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Control", Control))
                End If
                If String.IsNullOrEmpty(ControlType) Then
                    cmd.Parameters.Add(New SqlParameter("@ControlType", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ControlType", ControlType))
                End If
                If String.IsNullOrEmpty(Others) Then
                    cmd.Parameters.Add(New SqlParameter("@Others", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Others", Left(Others, 400)))
                End If
                If String.IsNullOrEmpty(Page) Then
                    cmd.Parameters.Add(New SqlParameter("@Page", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Page", Page))
                End If
                connection.Open()
                Return cmd.ExecuteNonQuery
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(String.Format("Error at DataAccess.vb->InsertControl(Control: {0}, ControlType:{1}, Others:{2}, Page:{3})", Control, ControlType, Others, Page), ex)
            Return Nothing
        End Try
    End Function

    ''' <summary>
    ''' Execute any DDL/DML Stored Procedure.
    ''' </summary>
    ''' <param name="StoredProcName">Name of the SP</param>
    ''' <param name="paramList">List of Parameters</param>
    ''' <returns>DataTable, if USED for SELECT</returns>
    ''' <remarks>Added by Shawkat Osman; 2017-06-14</remarks>
    Public Function ExecuteSP(ByVal StoredProcName As String, Optional ByVal paramList As SqlParameter() = Nothing) As DataTable
        Dim dsData As New DataSet
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(StoredProcName, connection)
                cmd.CommandType = CommandType.StoredProcedure

                If paramList IsNot Nothing Then cmd.Parameters.AddRange(paramList) '#### If No ParamList is Passed- don't worry! Lets go Alone!

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            Else
                Return Nothing
            End If
            'Return IIf(dsData.Tables.Count > 0, dsData.Tables(0), Nothing)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(String.Format("Error Executing StoredProc: {0}({1}), at: DataAccess.vb=>ExecuteSP()", StoredProcName, IIf(paramList Is Nothing, "", paramList.ToString())), ex)
            Return Nothing
        End Try

    End Function

    ''' <summary>
    ''' Execute any DDL/DML SQL Statement. 
    ''' </summary>
    ''' <param name="sqlStatement">Statement to EXECUTE</param>
    ''' <param name="paramList">List of Parameters</param>
    ''' <returns>DataTable, if USED for SELECT</returns>
    ''' <remarks>Added by Shawkat Osman; 2017-08-22</remarks>
    Public Shared Function ExecuteSQL(ByVal sqlStatement As String, Optional ByVal paramList As SqlParameter() = Nothing) As DataTable
        Dim result As New DataTable
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sqlStatement, connection)
                cmd.CommandType = CommandType.Text

                If paramList IsNot Nothing Then cmd.Parameters.AddRange(paramList) '#### If No ParamList is Passed- don't worry! Lets go Alone!

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(result)
            End Using

            Return IIf(result.Rows.Count > 0, result, Nothing)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error Executing sqlStatement=[" & sqlStatement & "], at: DataAccess.vb=>ExecuteSQL()", ex)
            Return Nothing
        End Try

    End Function

    ''' <summary>
    ''' Sanitized version of GetData. Only StoredProc.. But sometimes InLine SQL can be used.. but very risky!
    ''' </summary>
    ''' <param name="ScalerExecuteSQL">Simple SQL Suery text</param>
    ''' <returns>True if No Error, else False</returns>
    ''' <remarks>Need to sanitize the user SQL; They can be risky!</remarks>
    Public Shared Function ExecuteScalerSQL(ByVal ScalerExecuteSQL As String, Optional ByVal ExecuteAs As CommandType = CommandType.Text, Optional ByVal paramList As SqlParameter() = Nothing) As Boolean
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(ScalerExecuteSQL, connection)
                cmd.CommandType = ExecuteAs

                If paramList IsNot Nothing Then cmd.Parameters.AddRange(paramList) '#### If No ParamList is Passed- don't worry! Lets go Alone!

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error Executing Generic SQL Statement, at: DataAccess.vb=>ScalerExecuteSQL()) " + ScalerExecuteSQL, ex)
            Return False
        Finally

        End Try

    End Function
    Public Shared Function ProcedureNotCarriedOut_Reset(procedureId As Integer) As Boolean
        Using connection As New SqlConnection(ConnectionStr)
            Try
                Dim cmd As New SqlCommand("usp_ProcedureNotCarriedOut_Reset", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                connection.Open()
                cmd.ExecuteNonQuery()
            Catch ex As Exception
                Console.WriteLine("Error: " & ex.Message)
            End Try
        End Using
        Return True
    End Function
    Public Shared Function ProcedureNotCarriedOut_UpdateReason(ByVal procedureId As String, ByVal DNA_ReasonId As String, ByVal PP_DNA_Text As String, ByVal patientInRecovery As Boolean) As Boolean
        Dim Procedure = CInt(procedureId)
        Dim DNA_Reason = CInt(DNA_ReasonId)

        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = db.ProcedureNotCarriedOut_UpdateReason(Procedure, DNA_Reason, PP_DNA_Text)
            End Using

            Dim da As New DataAccess

            'check if was a scheduled appointment if so update status
            Dim dtProceureAppointment = da.getProcedureAppointment(procedureId)

            If dtProceureAppointment IsNot Nothing AndAlso dtProceureAppointment.Rows.Count > 0 Then
                Dim appointmentId As Integer = dtProceureAppointment.Rows(0)("AppointmentId")
                If patientInRecovery Then
                    da.updateAppointmentStatus(appointmentId, "RC")
                    'added by Ferdowsi
                ElseIf PP_DNA_Text = "Patient DNA" Then
                    da.updateAppointmentStatus(appointmentId, "D")
                Else
                    da.updateAppointmentStatus(appointmentId, "C")
                End If
            End If

            Return True

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(String.Format("Error at: DataAccess.vb=>ProcedureNotCarriedOut_UpdateReason(Procedure={0}, DNA_Reason={1}, PP_DNA_Text={2})", Procedure, DNA_Reason, PP_DNA_Text), ex)
            Return False
        End Try
    End Function

    Public Shared Function ProcedureIsValidToExportNED_XML(ByVal procedureId As Integer, ByVal ProcedureType As Integer) As Boolean
        Try
            Dim idObj As Object

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("usp_IsValidToExportNED", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureType", ProcedureType))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalID"))))

                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return CBool(idObj)
                End If
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(String.Format("Error at: DataAccess.vb=>ProcedureIsValidToExportNED_XML(Procedure={0}, ProcedureType={1})", procedureId, ProcedureType), ex)
            Return False
        End Try
    End Function

    Public Function GetPatientComfortLevel(procedureID As Integer) As DataTable
        Dim value As Integer = -1
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT PatSedation, PatDiscomfortPatient, PatDiscomfortNurse, PatSedationAsleepResponseState  FROM ERS_UpperGIQA WHERE ProcedureID=@ProcedureID", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", procedureID))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetPatientsByIDs(patientIds As List(Of String)) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT *, dbo.fnGender(GenderId) AS Gender, dbo.fnFullAddress(Address1, Address2, Address3, Address4, '''') as Address FROM ERS_Patients WHERE PatientID IN (" & String.Join(",", patientIds) & ")", connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetPatientById(patientId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SELECT *, dbo.fnGender(GenderId) AS Gender, dbo.fnFullAddress(Address1, Address2, Address3, Address4, '''') as Address FROM ERS_Patients WHERE PatientId=" & patientId, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetEndoscopist() As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(ConnectionStr)

            Dim cmd As New SqlCommand("get_WorklistEndoscopists", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospital", CInt(Session("OperatingHospitalId"))))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetProcedureTypes() As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(ConnectionStr)

            Dim cmd As New SqlCommand("get_WorklistProcedureTypes", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing

    End Function


    Public Function SiteName(ByVal siteId As Integer) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT dbo.fnGetSiteName(@SiteId)", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            connection.Open()
            Return CStr(cmd.ExecuteScalar())
        End Using
        Return ""
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetWorklistPatients(Optional startDate As Date? = Nothing, Optional endDate As Date? = Nothing, Optional endoscopistId As Integer? = Nothing) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("get_worklist_patients", connection)
            cmd.CommandType = CommandType.StoredProcedure
            'cmd.CommandTimeout = 220
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalID"))))
            If startDate Is Nothing Then
                cmd.Parameters.Add(New SqlParameter("@StartDate", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@StartDate", startDate.Value))
            End If
            If endDate Is Nothing Then
                cmd.Parameters.Add(New SqlParameter("@EndDate", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@EndDate", endDate.Value))
            End If
            If endoscopistId Is Nothing Then
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistId.Value))
            End If

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Sub InsertExportFileProcessToMirth(strMessage As String, FileContent() As Byte, FileLocation As String, FileLocationDirectory As String, DocumentFilename As String, ByRef outputDocumentStoreId As Integer)
        Dim Base64FileContent As String
        Dim blnSaveBase64FileContentToDatabase As Boolean = False
        If ConfigurationManager.AppSettings.AllKeys.Contains("SaveBase64FileContentToDatabase") Then
            If ConfigurationManager.AppSettings("SaveBase64FileContentToDatabase").ToLower() = "true" Then
                Base64FileContent = Convert.ToBase64String(FileContent)
            End If
        End If

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("sp_Insert_FileExport_ForMirth_Record", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(Session(Constants.SESSION_PROCEDURE_ID))))
                cmd.Parameters.Add(New SqlParameter("@ProcessString", strMessage))
                cmd.Parameters.Add(New SqlParameter("@FileLocation", FileLocation))
                cmd.Parameters.Add(New SqlParameter("@FileLocationDirectory", FileLocationDirectory))
                cmd.Parameters.Add(New SqlParameter("@DocumentFileName", DocumentFilename))
                cmd.Parameters.Add(New SqlParameter("@Instance", "SE " + HttpContext.Current.Session(Constants.SESSION_APPVERSION)))

                Dim blobParam = New SqlParameter("@FileContent", SqlDbType.VarBinary, FileContent.Length)
                blobParam.Value = FileContent
                cmd.Parameters.Add(blobParam)

                If String.IsNullOrEmpty(Base64FileContent) Then
                    cmd.Parameters.Add(New SqlParameter("@Base64FileContent", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Base64FileContent", Base64FileContent))
                End If

                cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(HttpContext.Current.Session("TrustId"))))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@OutputDocumentStoreId", SqlDbType.Int))
                cmd.Parameters("@OutputDocumentStoreId").Direction = ParameterDirection.Output

                connection.Open()
                cmd.ExecuteNonQuery()

                outputDocumentStoreId = cmd.Parameters("@OutputDocumentStoreId").Value

            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : InsertExportFileProcessToMirth()", ex)
        End Try
    End Sub
    Public Function GetTotalProcedureCountsForBatchExport(intBatchExportMasterId As Integer) As Integer
        Try
            Dim ds As DataSet
            ds = New DataSet
            Dim intTotalProcedures As Integer = 0

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("uspGetTotalProcedureCountsForBatchExport", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@BatchExportMasterId", intBatchExportMasterId))
                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(ds)

                If ds.Tables(0).Rows.Count > 0 Then
                    If Not IsDBNull(ds.Tables(0).Rows(0)("TotalProceduresToExport")) Then
                        intTotalProcedures = Convert.ToInt32(ds.Tables(0).Rows(0)("TotalProceduresToExport").ToString())
                    End If
                End If

                Return intTotalProcedures
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in DataAccess-->GetProcedureDataForFileDataExport", ex)
            Return Nothing
        End Try
    End Function
    Public Function GetAllLeftProceduresForBatchExportByMasterId(intBatchExportMasterId As Integer) As DataSet
        Try
            Dim ds As DataSet
            ds = New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("uspGetAllLeftProceduresForBatchExportByMasterId", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@BatchExportMasterId", intBatchExportMasterId))
                Dim adapter = New SqlDataAdapter(cmd)

                connection.Open()
                adapter.Fill(ds)

                Return ds
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in DataAccess-->GetProcedureDataForFileDataExport", ex)
            Return Nothing
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateProcedureBatchExportSuccess(ByVal DocBatchExpProcedureId As Integer) As Boolean
        Try
            Return DataAccess.ExecuteScalerSQL("uspUpdateProcedureBatchExportSuccess", CommandType.StoredProcedure, New SqlParameter() {
                                                                         New SqlParameter("@DocBatchExpProcedureId", DocBatchExpProcedureId)
                                                                })
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in DataAccess-->UpdateProcedureBatchExportSuccess", ex)
            Return Nothing
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function LogFailedBatchExportReason(ByVal DocBatchExpProcedureId As Integer, ByVal strErrorMessage As String) As Boolean
        Try
            Return DataAccess.ExecuteScalerSQL("uspLogFailedBatchExportReason", CommandType.StoredProcedure, New SqlParameter() {
                                                                         New SqlParameter("@DocBatchExpProcedureId", DocBatchExpProcedureId),
                                                                         New SqlParameter("@ErrorMessage", strErrorMessage)
                                                                })
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in DataAccess-->LogFailedBatchExportReason", ex)
            Return Nothing
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTop1UnexportedBatchExportMasterId() As Integer

        Dim value As Integer = 1
        Dim querystr As String = "Select top 1 bem.BatchExportMasterId from ERS_DocumentBatchExportMaster bem inner join ERS_DocumentBatchExportProcedures bep on bem.BatchExportMasterId = bep.BatchExportMasterId Where IsNull(ExportCompleted,0) = 0 Group by bem.BatchExportMasterId Order by bem.BatchExportMasterId asc"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim mycmd As New SqlCommand(querystr, connection)
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If Not IsDBNull(v) AndAlso Not IsNothing(v) Then
                value = CInt(v)
            Else
                value = 1
            End If
        End Using
        Return value
    End Function
    Public Sub saveOCSRecord()

    End Sub
    'Public Function GetVisualisationRecords(ByVal procedureId As Integer) As ERS.Data.EndoscopistSearch_Result
    '    Dim result As IQueryable(Of ERS.Data.EndoscopistSearch_Result)
    '    Try
    '        Using db As New ERS.Data.GastroDbEntities
    '            '### First get the Details about the Endoscopist! Both 1 and 2 wherever applicable!
    '            result = db.EndoscopistSelectByProcedureSite(procedureId, 0)
    '            Return result.FirstOrDefault()
    '        End Using
    '    Catch ex As Exception

    '        Return Nothing
    '    End Try

    'End Function


    Public Sub SetPriorityColors()
        Dim i As Integer
        Dim dsResult As New DataSet
        Dim PriorityDataTable As DataTable = Nothing
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("Select PriorityId, Description, Backcolor from ERS_Priority", connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using
        If dsResult.Tables.Count > 0 Then PriorityDataTable = dsResult.Tables(0)

        If PriorityDataTable.Rows.Count > 0 Then
            For i = 0 To PriorityDataTable.Rows.Count - 1
                PriorityColours.Add(New clsPriorityColors(PriorityDataTable.Rows(i).Item("PriorityId"), PriorityDataTable.Rows(i).Item("Description"), PriorityDataTable.Rows(i).Item("Backcolor")))
            Next
        End If

        PriorityDataTable.Dispose()

    End Sub
    Public Sub UpdateIsActive(InboundID As Long, Status As Integer, ProcessId As Integer, Optional OperatingHospitalId As Long = 0)
        Dim SQLString As String = ""
        Using connection As New SqlConnection(ConnectionStr)
            Select Case ProcessId
                Case 1 ' ProcedureType
                    SQLString = "UPDATE [ERS_ProcedureTypesHospitalDefinition] SET IsActive = " & Status & " WHERE ProcedureTypeID = " & InboundID &
                    " And OperatingHospitalId = " & OperatingHospitalId
                Case 2 'IMAGEPORT
                    SQLString = "UPDATE [ERS_ImagePort] SET IsActive = " & Status & " WHERE ImagePortID = " & InboundID
            End Select
            Dim cmd As New SqlCommand(SQLString, connection)
            cmd.CommandType = CommandType.Text
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Sub UnlinkImagePort(InboundID As Long)
        Dim SQLString As String = ""
        Using connection As New SqlConnection(ConnectionStr)
            SQLString = "UPDATE [ERS_ImagePort] SET RoomID = null, [Static] = NULL, [Default] = NULL, WhoUpdatedId=@LoggedInUserId, WhenUpdated = GETDATE() WHERE ImagePortID = " & InboundID
            Dim cmd As New SqlCommand(SQLString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Sub DeleteImagePort(InboundID As Long)
        Dim SQLString As String = ""
        Using connection As New SqlConnection(ConnectionStr)
            SQLString = "Delete from [ERS_ImagePort] WHERE ImagePortID = " & InboundID
            Dim cmd As New SqlCommand(SQLString, connection)
            cmd.CommandType = CommandType.Text
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Function CheckEntryExists(UID As Long, UIDName As String, Tbl As String, FieldName As String) As Boolean
        Dim SQLString As String = "select isnull(" & FieldName & ",'') as Fvalue from " & Tbl & " where  " & UIDName & " = " & UID
        Using connection As New SqlConnection(ConnectionStr)

            Dim exists As Boolean
            Dim myTmpTable As New DataTable '= Nothing
            Dim myTmpDataAdapter As New SqlDataAdapter(SQLString, connection)
            myTmpDataAdapter.Fill(myTmpTable)

            If myTmpTable.Rows.Count > 0 Then
                If Len(myTmpTable.Rows(0).Item("Fvalue")) Then
                    exists = True
                Else
                    exists = False
                End If
            Else
                exists = False
            End If
            myTmpTable.Dispose()
            connection.Dispose()
            Return exists

        End Using
    End Function
    Public Function CheckValueExists(EntryName As String, Tbl As String, FieldName As String, ID As String) As Long
        Dim SQLString As String = "select " & ID & " as Fvalue from " & Tbl & " where  " & FieldName & " = '" & EntryName & "'"
        Using connection As New SqlConnection(ConnectionStr)
            Dim exists As Long
            Dim myTmpTable As New DataTable '= Nothing
            Dim myTmpDataAdapter As New SqlDataAdapter(SQLString, connection)
            myTmpDataAdapter.Fill(myTmpTable)
            If myTmpTable.Rows.Count > 0 Then
                exists = myTmpTable.Rows(0).Item("Fvalue")
            Else
                exists = 0
            End If
            myTmpTable.Dispose()
            connection.Dispose()
            Return exists
        End Using
    End Function
    Public Function GetGPList(PostCode As String, NationalCode As String, LocalCode As String, GPName As String, PracticeName As String, Active As Integer) As DataTable
        Dim dsData As New DataSet
        Dim ActiveValue As Integer = Val(Active)
        GPName = "SMITH"
        '@PostCode as varchar(50), @NationalCode varchar(50), @LocalCode varchar(50), @GPName varchar(50), @PracticeName varchar(50))

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("GetGPList", connection)
            cmd.CommandType = CommandType.StoredProcedure
            If PostCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Postcode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Postcode", .SqlDbType = SqlDbType.Text, .Value = PostCode})
            End If
            If NationalCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NationalCode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NationalCode", .SqlDbType = SqlDbType.Text, .Value = NationalCode})
            End If
            If LocalCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LocalCode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LocalCode", .SqlDbType = SqlDbType.Text, .Value = LocalCode})
            End If
            If GPName = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GPName", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@GPName", .SqlDbType = SqlDbType.Text, .Value = GPName})
            End If
            If PracticeName = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PracticeName", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PracticeName", .SqlDbType = SqlDbType.Text, .Value = PracticeName})
            End If

            ' If Active = Nothing Then
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Active", .SqlDbType = SqlDbType.Int, .Value = 1})
            '   Else
            '     cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Active", .SqlDbType = SqlDbType.Int, .Value = ActiveValue})
            '    End If
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function GetPracticeList(PostCode As String, NationalCode As String, LocalCode As String, PracticeName As String, Active As Integer) As DataTable
        Dim dsData As New DataSet
        Dim ActiveValue As Integer = Val(Active)
        PracticeName = "SMITH"
        '@PostCode as varchar(50), @NationalCode varchar(50), @LocalCode varchar(50), @GPName varchar(50), @PracticeName varchar(50))

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("GetGPList", connection)
            cmd.CommandType = CommandType.StoredProcedure
            If PostCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Postcode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Postcode", .SqlDbType = SqlDbType.Text, .Value = PostCode})
            End If
            If NationalCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NationalCode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@NationalCode", .SqlDbType = SqlDbType.Text, .Value = NationalCode})
            End If
            If LocalCode = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LocalCode", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@LocalCode", .SqlDbType = SqlDbType.Text, .Value = LocalCode})
            End If

            If PracticeName = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PracticeName", .SqlDbType = SqlDbType.Text, .Value = ""})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PracticeName", .SqlDbType = SqlDbType.Text, .Value = PracticeName})
            End If

            ' If Active = Nothing Then
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Active", .SqlDbType = SqlDbType.Int, .Value = 1})
            '   Else
            '     cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Active", .SqlDbType = SqlDbType.Int, .Value = ActiveValue})
            '    End If
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub insertOCSRecord(strMessage As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("usp_Insert_OCS_Record", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcessString", strMessage))
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(Session(Constants.SESSION_PROCEDURE_ID))))
                cmd.Parameters.Add(New SqlParameter("@TrustId", CInt(Session("TrustId"))))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function TransactionSQL(sql As String) As String
        Dim sqlCommand = ""
        sqlCommand += "BEGIN TRY "
        sqlCommand += "BEGIN TRANSACTION "
        sqlCommand += sql
        sqlCommand += " COMMIT TRANSACTION "
        sqlCommand += "END TRY "
        sqlCommand += "BEGIN CATCH
	                    DECLARE @ErrorMessage NVARCHAR(4000);
                        DECLARE @ErrorSeverity INT;
                        DECLARE @ErrorState INT;

                        SELECT @ErrorMessage = ERROR_MESSAGE(),
                               @ErrorSeverity = ERROR_SEVERITY(),
                               @ErrorState = ERROR_STATE();
                        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);"
        sqlCommand += "ROLLBACK "
        sqlCommand += "END CATCH "

        Return sqlCommand.ToString()
    End Function

    Public Function ShowCorrectStentPlacementOptions(siteId As Integer, ProcedureTypeId As Integer) As Boolean
        Dim sqlStmt As String = ""

        If ProcedureTypeId = ProcedureType.Gastroscopy Then
            sqlStmt = "SELECT Stricture AS ShowStentPlacementOption " &
                                    "FROM dbo.ERS_UpperGIAbnoMiscellaneous AS Abn " &
                                    "WHERE Abn.SiteId = @SiteId;"
        ElseIf ProcedureTypeId = ProcedureType.Colonoscopy Or ProcedureType.Sigmoidscopy Then
            sqlStmt = "SELECT Stricture AS ShowStentPlacementOption " &
                                   "FROM dbo.ERS_ColonAbnoCalibre AS Abn " &
                                   "WHERE Abn.SiteId = @SiteId;"
        End If

        Dim result As DataTable
        result = DataAccess.ExecuteSQL(sqlStmt, New SqlParameter() {New SqlParameter("@SiteId", siteId)})
        If result IsNot Nothing Then
            Return CBool(result.Rows(0).Item("ShowStentPlacementOption") = True)
        Else
            Return False
        End If

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetStentInsertionFailureReasons() As DataTable
        Return GetList("Stent Placement Failure Reasons")
    End Function

    Friend Function GetPatientNotes(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("PatientNotesSelect", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Sub SavePatientNotes(procedureId As Integer, patientNotes As String, patientHistory As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("PatientNotesSave", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@PatientNotes", patientNotes))
                cmd.Parameters.Add(New SqlParameter("@PatientHistory", patientHistory))
                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub


    Public Function ImagePortName(portId As String) As String

        Dim sqlQuery As String = ""
        Dim sqlResult As String = ""
        sqlQuery = "SELECT PortName FROM dbo.ERS_ImagePort WHERE ImagePortId = @PortId; "
        Dim result As DataTable
        result = DataAccess.ExecuteSQL(sqlQuery, New SqlParameter() {New SqlParameter("@PortId", portId)})
        If result IsNot Nothing AndAlso portId > 0 Then
            Return Convert.ToString(result.Rows(0).Item("PortName"))
        Else
            Return ""
        End If

    End Function

    Public Function InsertLockedAt(procedureId As Integer, userId As String)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("lockProcedure", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@UserName", userId))
            cmd.Parameters.Add(New SqlParameter("@procedureId", procedureId))
            connection.Open()
            Dim result = cmd.ExecuteScalar()
            Return result
        End Using
    End Function

    Public Sub UnLockProcedure(procedureId As Integer)
        Try
            DataAccess.ExecuteScalerSQL("unLockProcedure", CommandType.StoredProcedure, New SqlParameter() {New SqlParameter("@procedureId", procedureId)})
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred", ex)
        End Try

    End Sub

    Friend Sub SaveImagePortDetails(operatingHospitalId As Integer, imagePortId As Integer, portName As String, macAddress As String, roomId As Integer, comments As String, friendlyName As String, isDefault As Boolean)
        DataAccess.ExecuteScalerSQL("image_port_save", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@OperatingHospitalId", operatingHospitalId),
                                        New SqlParameter("@ImagePortId", imagePortId),
                                        New SqlParameter("@PortName", portName),
                                        New SqlParameter("@MacAddress", macAddress),
                                        New SqlParameter("@RoomId", roomId),
                                        New SqlParameter("@Comments", comments),
                                        New SqlParameter("@FriendlyName", friendlyName),
                                        New SqlParameter("@Default", isDefault)})
    End Sub

    Public Function CheckImagePortRoomDefault(operatingHospitalId As Integer, roomId As Integer, isDefault As Boolean) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("image_port_room_default_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", operatingHospitalId))
            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
            cmd.Parameters.Add(New SqlParameter("@Default", isDefault))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing

    End Function

    'Public Function ClearImagePortRoomDefault(operatingHospitalId As Integer, roomId As Integer, isDefault As Boolean) As DataTable
    Friend Sub ClearImagePortRoomDefault(imagePortId As Integer)

        DataAccess.ExecuteScalerSQL("image_port_room_default_clear", CommandType.StoredProcedure, New SqlParameter() {
                                        New SqlParameter("@ImagePortId", imagePortId)
                                        })

    End Sub
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetJagReportDrillDown(procedureType As String, ConsultantId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("report_JAG" + procedureType + "_DrillDown", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@UserId", .SqlDbType = SqlDbType.Int, .Value = LoggedInUserId})
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@AnonomizedId", .SqlDbType = SqlDbType.Int, .Value = ConsultantId})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

#Region "Wards"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetWardsLst(FieldValue As String, Suppressed As Nullable(Of Integer)) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Wards_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            If FieldValue = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@FieldValue", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@FieldValue", .SqlDbType = SqlDbType.Text, .Value = FieldValue})
            End If
            If Suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = Suppressed})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = DBNull.Value})
            End If
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = Session("TrustId")})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SuppressWard(WardId As String, Suppressed As Boolean) As Boolean
        Dim sql As String = "UPDATE ERS_Wards SET Suppressed = " & IIf(Suppressed, 1, 0) & ", WhoUpdatedId = " & LoggedInUserId & ", WhenUpdated = GETDATE() WHERE WardId = " & WardId
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetWard(ByVal WardId As Integer) As DataTable
        Dim sqlStr As String = "SELECT WardId, WardDescription, ISNULL(OperatingHospitalId,0) AS HospitalId, Suppressed FROM ERS_Wards WHERE WardId = " & WardId
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function SaveWard(ByVal operatingHospital As Integer, ByVal WardId As Integer?, ByVal wardDescription As String) As String
        Try
            ExecuteSP("Ward_save", New SqlParameter() {New SqlParameter("@OperatingHospitalId", operatingHospital),
                                                               New SqlParameter("@wardId", WardId),
                                                               New SqlParameter("@WardDescription", wardDescription)})
            Return Nothing
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error: SaveWard function", ex)
            Return ex.Message
        End Try
    End Function

#End Region

#Region "Scopes"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScopesLst(FieldValue As String, Suppressed As Nullable(Of Integer)) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("scopes_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            If FieldValue = Nothing Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@FieldValue", .SqlDbType = SqlDbType.Text, .Value = DBNull.Value})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@FieldValue", .SqlDbType = SqlDbType.Text, .Value = FieldValue})
            End If
            If Suppressed.HasValue Then
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = Suppressed})
            Else
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@Suppressed", .SqlDbType = SqlDbType.TinyInt, .Value = DBNull.Value})
            End If
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = Session("TrustId")})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SuppressScope(ScopeId As String, Suppressed As Boolean) As Boolean
        Dim sql As String = "UPDATE [ERS_Scopes] SET [Suppressed] = " & IIf(Suppressed, 1, 0) & ", WhoUpdatedId = " & LoggedInUserId & ", WhenUpdated = GETDATE() WHERE [ScopeId]= " & ScopeId
        Return DataAccess.ExecuteScalerSQL(sql.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScope(ByVal ScopeId As Integer) As DataTable
        Dim sqlStr As String = "SELECT ScopeId, ScopeName, AllProcedureTypes, s.Suppressed, ISNULL(ManufacturerId, 0) ManufacturerId, s.ScopeGenerationId  
                                FROM ERS_Scopes s
                                LEFT JOIN ERS_ScopeGenerations g on s.ScopeGenerationId = g.UniqueId WHERE S.ScopeId = " & ScopeId
        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function
    'Added by rony TFS-2816 start
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOperatingHospitalsForScopes(ByVal ScopeId As Integer, ByVal TrustId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("scopes_GetOperatingHospitalForScopes", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ScopeId", .SqlDbType = SqlDbType.Int, .Value = ScopeId})
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = TrustId})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    'End
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScopeOperatingHospitals(ByVal ScopeId As Integer) As DataTable
        Dim sqlStr As String = "Select OperatingHospitalId,ScopeId,ScopeOperatingHospitalId From ERS_ScopeOperatingHospitals Where ScopeId = " & ScopeId

        sqlStr = sqlStr & " ORDER BY OperatingHospitalId "

        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScopeProcedureTypes(ByVal ScopeId As Integer) As DataTable
        Dim sqlStr As String = "Select p.ProcedureTypeId, p.ProcedureType, ISNULL(r.ScopeProcId,0) As ScopeProcId FROM [dbo].[ERS_ProcedureTypes] p " &
            " LEFT JOIN ERS_ScopeProcedures r On p.ProcedureTypeId = r.ProcedureTypeId And r.ScopeId = " & ScopeId

        sqlStr = sqlStr & " ORDER BY p.ProcedureTypeId "

        Return DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)
    End Function
    'MH changed as below 31 Aug 2022
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    'Public Function GetScopeLst(ByVal ProcedureType As Integer) As DataTable
    '    Dim sqlStr As String = "SELECT DISTINCT s.ScopeId, s.ScopeName FROM [ERS_Scopes] s " &
    '                        " INNER JOIN ERS_ScopeProcedures p On p.ScopeId = s.ScopeId And p.ProcedureTypeId = " & ProcedureType &
    '                        " INNER JOIN ERS_OperatingHospitals h On s.HospitalId = h.OperatingHospitalId " &
    '                        " WHERE h.TrustId = " + HttpContext.Current.Session("TrustId") &
    '                        " AND s.Suppressed = 0 " &
    '                        " ORDER BY ScopeName"
    '    Return GetData(sqlStr)
    'End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetScopeLst(ByVal ProcedureType As Integer) As DataTable
        '18 Mar 2022    MH made changes for Scopes associated with multiple hospitals
        Try
            'Dim sqlStr As String = "SELECT DISTINCT s.ScopeId, s.ScopeName FROM [ERS_Scopes] s " &
            '                " INNER JOIN ERS_ScopeProcedures p On p.ScopeId = s.ScopeId And p.ProcedureTypeId = " & ProcedureType &
            '                " INNER JOIN ERS_OperatingHospitals h On s.HospitalId = h.OperatingHospitalId " &
            '                " WHERE h.TrustId = " + HttpContext.Current.Session("TrustId") &
            '                " AND s.Suppressed = 0 " &
            '                " ORDER BY ScopeName"
            'Return GetData(sqlStr)
            Dim blnFilterScopeByHospital As Boolean = False
            Dim intOperatingHospitalId As Integer = 0
            Dim intProcedureId As Integer = 0

            '****************** MH added on 22 Mar 2022 - Scopes outside of logged-in Hospital needed to be added if it is used in previously created procedure ***********
            If Not IsNothing(Session(Constants.SESSION_PROCEDURE_ID)) Then
                intProcedureId = Session(Constants.SESSION_PROCEDURE_ID)
            End If

            If ConfigurationManager.AppSettings.AllKeys.Contains("FilterScopeByOperatingHospital") Then
                If ConfigurationManager.AppSettings("FilterScopeByOperatingHospital").ToLower() = "true" Then
                    blnFilterScopeByHospital = True
                Else
                    blnFilterScopeByHospital = False
                End If
            End If
            If blnFilterScopeByHospital Then
                intOperatingHospitalId = HttpContext.Current.Session("OperatingHospitalId")
            Else
                intOperatingHospitalId = 0
            End If
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("spGetScopeListByOperatingHospitalandTrust", connection)
                cmd.CommandTimeout = 120
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureTypeId", .SqlDbType = SqlDbType.Int, .Value = ProcedureType})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@TrustId", .SqlDbType = SqlDbType.Int, .Value = HttpContext.Current.Session("TrustId")})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalId", .SqlDbType = SqlDbType.Int, .Value = intOperatingHospitalId})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureId", .SqlDbType = SqlDbType.Int, .Value = intProcedureId})
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            Return dsData.Tables(0)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error: GetScopeLst", ex)
        End Try

    End Function
#End Region
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOtherAuditReports(ReportModule As String) As DataTable
        Return ExecuteSP("GetOtherAuditReports", New SqlParameter() {New SqlParameter("@ReportModule", ReportModule)})
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOtherAuditReport(reportId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("auditRunReport", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@UserId", .SqlDbType = SqlDbType.Int, .Value = LoggedInUserId})
            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ReportId", .SqlDbType = SqlDbType.Int, .Value = reportId})
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Sub InsertUpdateOperatingHospitalsForScopeId(ScopeId As Integer, OperatingHospitalIdList As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("spInsertOrDeleteScopesOperatingHospitalLink", connection)

                '07 Jan 2022 MH changed (changed default timeout 30 sec to 120 (2 minutes)) TFS # 1722 Sunderland issue
                cmd.CommandTimeout = 120

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ScopeId", .SqlDbType = SqlDbType.Int, .Value = ScopeId})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OperatingHospitalIdList", .SqlDbType = SqlDbType.VarChar, .Value = OperatingHospitalIdList})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@UserId", .SqlDbType = SqlDbType.Int, .Value = LoggedInUserId})
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error: InsertUpdateOperatingHospitalsForScopeId function", ex)
        End Try
    End Sub

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetRoomNameByRoomId(roomId As Integer) As String

        Dim sql As String = "SELECT RoomName 
                                FROM ERS_SCH_Rooms 
                                WHERE RoomId = @RoomId"
        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand(sql, connection)
            cmd.CommandType = CommandType.Text

            cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))

            connection.Open()
            idObj = cmd.ExecuteScalar()

            Return idObj

        End Using

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHospitalNameByRoomId(roomId As Integer) As String
        Try
            Dim sql As String = "SELECT HospitalName
                                FROM dbo.ERS_SCH_Rooms esr
                                INNER JOIN dbo.ERS_OperatingHospitals eoh
	                                ON esr.HospitalId = eoh.OperatingHospitalId
                                WHERE esr.RoomId = @RoomId"
            Dim idObj As Object
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))
                connection.Open()
                idObj = cmd.ExecuteScalar()
                Return idObj
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error: GetHospitalNameByRoomId function", ex)
            Return False
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTrustIdByRoomId(roomId As Integer) As String
        Try
            Dim sql As String = "SELECT eoh.TrustId
                                FROM dbo.ERS_SCH_Rooms esr
                                INNER JOIN dbo.ERS_OperatingHospitals eoh
	                                ON esr.HospitalId = eoh.OperatingHospitalId
                                WHERE esr.RoomId = @RoomId"
            Dim idObj As Object

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))

                connection.Open()
                idObj = cmd.ExecuteScalar()

                Return idObj

            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error: GetTrustIdByRoomId function", ex)
            Return False
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function CheckRoomId(roomId As Integer) As Boolean
        Try

            Dim sql As String = "SELECT RoomId FROM ERS_SCH_Rooms WHERE RoomId = @RoomId"
            Dim idObj As Object

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text

                cmd.Parameters.Add(New SqlParameter("@RoomId", roomId))

                connection.Open()
                idObj = cmd.ExecuteScalar()
                If idObj IsNot Nothing Then
                    Return True
                End If
            End Using

            Return False
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error: CheckRoomId function", ex)
            Return False
        End Try

    End Function

    Public Function LoadPolypTypes(procedureTypeId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("polyp_types_select", connection)
            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function LoadPolyRemovalTypes() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("polyp_removal_types_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function LoadPolyRemovalMethods() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("polyp_removal_methods_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function LoadMarkingTypes() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("marking_types_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function LoadTattooOptions() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("tattoo_options_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function LoadTumourTypes() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("tumour_types_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function LoadPolypConditions() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("polyp_conditions_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function LoadParisLSTTypes() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("polyp_lst_morphology_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function LoadInflammatoryDisorders() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("inflammatory_disorders_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function LoadUCEIScores() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("ucei_scores_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function LoadRutgeertsScores() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("rutgeers_scores_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub DeletePolypData(siteId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                connection.Open()

                Dim cmd As SqlCommand = New SqlCommand("abnormalities_common_polyp_details_delete", connection)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub SavePolypsData(polypDetails As List(Of SitePolyps), siteId As Integer)
        Dim transaction As SqlTransaction

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            connection.Open()

            transaction = connection.BeginTransaction("PolypEntryTransation") 'transaction started to undo any delete options should the process fail

            Try
                If Not connection.State = ConnectionState.Open Then connection.Open()

                Dim cmd As SqlCommand = New SqlCommand("abnormalities_common_polyp_details_delete", connection)
                cmd.Transaction = transaction

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.ExecuteNonQuery()

                Dim polypDetailsId As New List(Of Integer)
                For Each polyp In polypDetails
                    cmd.CommandText = "abnormalities_common_polyp_details_save"
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Clear()
                    cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                    cmd.Parameters.Add(New SqlParameter("@Size", polyp.Size))
                    cmd.Parameters.Add(New SqlParameter("@Excised", polyp.Excised))
                    cmd.Parameters.Add(New SqlParameter("@Retreived", polyp.Retrieved))
                    cmd.Parameters.Add(New SqlParameter("@Discarded", polyp.Discarded))
                    cmd.Parameters.Add(New SqlParameter("@Successful", polyp.Successful))
                    cmd.Parameters.Add(New SqlParameter("@Labs", polyp.SentToLabs))
                    cmd.Parameters.Add(New SqlParameter("@Removal", polyp.Removal))
                    cmd.Parameters.Add(New SqlParameter("@RemovalMethod", polyp.RemovalMethod))
                    cmd.Parameters.Add(New SqlParameter("@Probably", polyp.Probably))
                    cmd.Parameters.Add(New SqlParameter("@TumorTypeId", polyp.TumourType))
                    cmd.Parameters.Add(New SqlParameter("@ParisClass", polyp.ParisClassification))
                    cmd.Parameters.Add(New SqlParameter("@PitPattern", polyp.PitPattern))
                    cmd.Parameters.Add(New SqlParameter("@TattooedId", polyp.TattooedId))
                    cmd.Parameters.Add(New SqlParameter("@TattooMarkingTypeId", polyp.TattooMarkingTypeId))
                    cmd.Parameters.Add(New SqlParameter("@Infammatory", polyp.Inflammatory))
                    cmd.Parameters.Add(New SqlParameter("@PostInflammatory", polyp.PostInflammatory))
                    cmd.Parameters.Add(New SqlParameter("@PolypConditionIds", String.Join(",", polyp.Conditions)))
                    cmd.Parameters.Add(New SqlParameter("@PolypTypeId", polyp.PolypTypeId))
                    cmd.Parameters.Add(New SqlParameter("@TattooLocationDistal", polyp.TattooLocationDistal))
                    cmd.Parameters.Add(New SqlParameter("@TattooLocationProximal", polyp.TattooLocationProximal))
                    cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

                    cmd.ExecuteNonQuery()
                Next

                cmd.CommandText = "abnormalities_common_lesions_update"
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Clear()
                cmd.Parameters.Add(New SqlParameter("@PolypTypeId", polypDetails.Select(Function(x) x.PolypTypeId).FirstOrDefault)) 'Polyp type id is the same for all
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                cmd.ExecuteNonQuery()

                If polypDetails IsNot Nothing AndAlso polypDetails.Any(Function(x) x.Successful) Then
                    'specimen details   
                    cmd.CommandText = "abnormalities_common_polyp_specimen_details_save"
                    cmd.Parameters.Clear()
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                    cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                    cmd.ExecuteNonQuery()
                End If


                cmd.CommandText = "abnormalities_common_lesions_summary_update"
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Clear()
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.ExecuteNonQuery()

                transaction.Commit()



            Catch ex As Exception
                transaction.Rollback()
                Throw ex
            End Try
        End Using
    End Sub


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPreviousGastricUlcer(ByVal ProcedureId As Integer, DisplayAlertOnly As Boolean) As String

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ogd_previous_gastric_ulcer", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@DisplayAlertOnly", DisplayAlertOnly))
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", CInt(HttpContext.Current.Session("OperatingHospitalId"))))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            Return cmd.ExecuteScalar()
        End Using

    End Function

#Region "Discomfort score"
    Public Function LoadDiscomfortScores() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("discomfort_score_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getProcedureDiscomfortScore(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_discomfort_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getPostProcedureDiscomfortScore(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("postprocedure_discomfort_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub saveDiscomfortScore(procedureId As Integer, discomfortScore As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_discomfort_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@DiscomfortScoreId", discomfortScore))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub savePostProcedureDiscomfortScore(procedureId As Integer, discomfortScore As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("postprocedure_discomfort_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@DiscomfortScoreId", discomfortScore))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

#Region "Potential damaging drugs"
    Friend Sub deleteProcedureAntiCoagDrug(procedureId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_anti_coag_drugs_delete", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Sub deleteProcedureDamagingDrug(procedureId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_damaging_drugs_delete", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Sub saveAntiCoagDrugStatus(procedureId As Integer, drugStatus As String, potentialSignificantStatus As String) 'Added by rony tfs-4171
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_anti_coag_drugs_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                If drugStatus = "null" Then
                    cmd.Parameters.Add(New SqlParameter("@AntiCoagDrugs", SqlTypes.SqlBoolean.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@AntiCoagDrugs", drugStatus))
                End If
                If potentialSignificantStatus = "null" Then
                    cmd.Parameters.Add(New SqlParameter("@PotentialSignificantDrugs", SqlTypes.SqlBoolean.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PotentialSignificantDrugs", potentialSignificantStatus))
                End If

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Function saveDamagingDrug(procedureId As Integer, drugId As String, antiCoag As Integer, sectionName As String, newText As String, potentialSignificantStatus As String, antiCoagOtherText As String) 'Added by rony tfs-4171
        Dim returnValue As Integer?
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_damaging_drugs_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@DrugId", drugId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@AntiCoag", antiCoag))
                cmd.Parameters.Add(New SqlParameter("@SectionName", sectionName))
                cmd.Parameters.Add(New SqlParameter("@NewItem", newText))
                If potentialSignificantStatus = "null" Then
                    cmd.Parameters.Add(New SqlParameter("@PotentialSignificantDrugs", SqlTypes.SqlBoolean.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PotentialSignificantDrugs", potentialSignificantStatus))
                End If
                cmd.Parameters.Add(New SqlParameter("@antiCoagOtherText", antiCoagOtherText))
                Dim returnParam As SqlParameter = New SqlParameter()
                returnParam.Direction = ParameterDirection.ReturnValue
                cmd.Parameters.Add(returnParam)

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()

                If returnParam.Value IsNot DBNull.Value Then
                    returnValue = CInt(returnParam.Value)
                Else
                    returnValue = Nothing
                End If
                Return returnValue
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function


#End Region
#Region "Patient Allergies"
    Friend Sub saveAllergy(procedureId As Integer, allergyResult As Integer, allergyDescription As String, patientId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_allergy_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@AllergyResult", allergyResult))
                cmd.Parameters.Add(New SqlParameter("@AllergyDescription", allergyDescription))
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetPatientAllergies(patientId As Integer, procedureId As Integer, Optional isCreation As Boolean = False) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_allergy_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@IsProcedureCreation", isCreation))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
#End Region


#Region "Extent"
    Public Function LoadExtent(procedureTypeId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("extent_select", connection)
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function LoadProcedureDistalAttachment(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_distal_attachment_select", connection)
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function LoadProcedureInstruments(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_instruments_select", connection)
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function LoadExtentInsertionMethod(procedureTypeId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("extent_insertion_route_select", connection)
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function LoadExtentDifficultiesEncountered() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("extent_difficulties_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function LoadExtentLimitations(procedureTypeId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("limitations_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function LoadExtentConfirmedList(isLimitationReason As Boolean) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("lower_extent_confirmed_by_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@LimitationReason", isLimitationReason))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getProcedureCaecumComfirmedBy(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_caecum_identifiedby_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getProcedureUpperExtent(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_upper_extent_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getProcedurePlannedExtent(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_planned_extent_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getProcedureLowerExtent(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_lower_extent_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function getProcedureEndoscopists(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_endoscopists_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub saveProcedurePlannedExtent(procedureId As Integer, extentId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_planned_extent_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ExtentId", extentId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub saveProcedureUpperExtent(procedureId As Integer, extentId As Integer, additionalInfo As String, endoscopistId As Integer, limitedById As Integer, jmanoeuvreId As Integer, mucosalJunctionDistance As Integer, limitationOther As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_upper_extent_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ExtentId", extentId))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistId))
                cmd.Parameters.Add(New SqlParameter("@LimitedById", limitedById))
                cmd.Parameters.Add(New SqlParameter("@LimitationOther", limitationOther))
                cmd.Parameters.Add(New SqlParameter("@JManoeuvreId", jmanoeuvreId))
                cmd.Parameters.Add(New SqlParameter("@MucosalJunctionDistance", mucosalJunctionDistance))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub saveUpperWithdrawalTime(procedureId As Integer, minutes As Integer, endoscopistID As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_upper_withdrawal_time_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@Minutes", minutes))
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistID))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub saveProcedureLowerExtent(procedureId As Integer, extentId As Integer, additionalInfo As String, endoscopistId As Integer, insertionConfirmedById As Integer, confirmedByOther As String, caecumIdentifiedById As Integer, limitationId As Integer, difficultyEncounteredId As Integer,
                                        difficultyOther As String, rectalExam As Integer, retroflexion As Integer, noRetroflexionReason As String,
                                        insertionVia As Integer, limitationOther As String, abandoned As Boolean, intubationFailed As Boolean)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_lower_extent_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ExtentId", extentId))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistId))
                cmd.Parameters.Add(New SqlParameter("@ConfirmedById", insertionConfirmedById))
                cmd.Parameters.Add(New SqlParameter("@ConfirmedByOther", confirmedByOther))
                cmd.Parameters.Add(New SqlParameter("@CaecumIdentifiedById", caecumIdentifiedById))
                cmd.Parameters.Add(New SqlParameter("@LimitationId", limitationId))
                cmd.Parameters.Add(New SqlParameter("@LimitationOther", limitationOther))
                cmd.Parameters.Add(New SqlParameter("@DifficultyEncounteredId", difficultyEncounteredId))
                cmd.Parameters.Add(New SqlParameter("@DifficultyOther", difficultyOther))
                cmd.Parameters.Add(New SqlParameter("@PR", rectalExam))
                cmd.Parameters.Add(New SqlParameter("@Retroflexion", retroflexion))
                cmd.Parameters.Add(New SqlParameter("@NoRetroflexionReason", noRetroflexionReason))
                cmd.Parameters.Add(New SqlParameter("@InsertionVia", insertionVia))
                cmd.Parameters.Add(New SqlParameter("@ProcedureAbandoned", abandoned))
                cmd.Parameters.Add(New SqlParameter("@IntubationFailed", intubationFailed))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function calculateWithdrawalTime(procedureId As Integer, procedureTypeId As Integer) As Integer
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim value As Object
                Dim cmd As New SqlCommand("procedure_withdrawal_time_calculate", connection)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))

                connection.Open()
                value = cmd.ExecuteScalar()
                If Not IsDBNull(value) Then Return CInt(value)
                Return 0
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub saveWithdrawalTime(procedureId As Integer, minutes As Integer, endoscopistID As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_withdrawal_time_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@Minutes", minutes))
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistID))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub saveTimeToCaecum(procedureId As Integer, startDateTime As DateTime, selected As Boolean)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_time_to_caecum_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@CaecumIntubationStart", startDateTime))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub saveProcedureCaecumIdentifiedBy(identifiedById As Integer, childId As Integer, procedureId As Integer, endoscopistId As Integer, selected As Boolean)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_caecum_identifiedby_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@EndoscopistId", endoscopistId))
                cmd.Parameters.Add(New SqlParameter("@ChildId", childId))
                cmd.Parameters.Add(New SqlParameter("@IdentifiedById", identifiedById))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

#Region "Vocal cord paralysis"
    Public Function LoadParalysisOptions() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("vocal_cord_paralysis_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getProcedureVocalCordParalysis(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_vocal_cord_paralysis_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub saveProcedureVocalCordParalysis(procedureId As Integer, vocalCordParalysisId As Integer, additionalInformation As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_vocal_cord_paralysis_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@VocalCordParalysisId", vocalCordParalysisId))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInformation", additionalInformation))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

#End Region

#Region "Sedation score"
    Public Function LoadSedationScores() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("sedation_score_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function getProcedureSedationScore(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_sedation_score_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub saveSedationScore(procedureId As Integer, sedationScoreId As Integer, childId As Integer, generalAneathetic As Decimal) 'Added by rony tfs-4075
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_sedation_score_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@SedationScoreId", sedationScoreId))
                cmd.Parameters.Add(New SqlParameter("@ChildId", childId))
                cmd.Parameters.Add(New SqlParameter("@GeneralAneathetic", generalAneathetic))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

#Region "Family history"
    Friend Function LoadFamilyDiseaseHistory(procedureTypeId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("family_disease_history_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetPatientFamilyHistory(patientId As Integer, procedureId As Integer, Optional isCreation As Boolean = False) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_family_disease_history_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@IsProcedureCreation", isCreation))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub saveFamilyDiseaseHistory(procedureId As Integer, patientId As Integer, familyDiseaseId As Integer, selected As Boolean, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_family_disease_history_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@FamilyDiseaseHistoryId", familyDiseaseId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Friend Function LoadDistalAttachments() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("distal_attachments_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

#End Region

#Region "Previous Diseases"
    Friend Function LoadPreviousDiseases(procType As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("previous_diseases_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procType))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetPatientPreviousDiseases(patientId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_previous_diseases_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Friend Sub savePreviousDisease(procedureId As Integer, patientId As Integer, previousDiseaseId As Integer, selected As Boolean, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_previous_disease_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@PreviousDiseaseId", previousDiseaseId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

#End Region

#Region "Previous Surgery"
    Friend Function LoadPreviousSurgeries(procedureTypeId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("previous_surgery_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procedureTypeId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function getPatientPreviousSurgery(patientId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_previous_surgery_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub savePreviousSurgery(procedureId As Integer, patientId As Integer, previousSurgeryId As String, previousSurgeryPeriod As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_previous_surgery_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@PreviousSurgeryId", previousSurgeryId))
                cmd.Parameters.Add(New SqlParameter("@PreviousSurgeryPeriod", previousSurgeryPeriod))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

#Region "Procedure Types"
    Friend Function LoadAllProcedureTypes() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("get_ProcedureTypes", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
#End Region

#Region "Damaging Drugs"
    Friend Function LoadAntiCoagDrugs() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("anti_coag_drugs_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function LoadDamagingDrugs() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("damaging_drugs_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    'edited by mostafiz 4090
    Public Function GetAntiCoagStatus(procedureId As Integer) As Integer
        Using connection As New SqlConnection(ConnectionStr)
            Using cmd As New SqlCommand("SELECT dbo.GetAntiCoagDrugs(@ProcedureId)", connection)
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                connection.Open()
                Return cmd.ExecuteScalar()
            End Using
        End Using
    End Function

    'edited by mostafiz 4090

    Public Function GetProcedureAntiCoagDrugs(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_anti_coag_drugs_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetProcedureDamagingDrugs(procedureId As Integer) As DataTable
        Try
            Try
                Dim dsData As New DataSet
                Using connection As New SqlConnection(ConnectionStr)
                    Dim cmd As New SqlCommand("procedure_damaging_drugs_select", connection)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                    Dim adapter = New SqlDataAdapter(cmd)
                    connection.Open()
                    adapter.Fill(dsData)
                End Using
                If dsData.Tables.Count > 0 Then
                    Return dsData.Tables(0)
                End If
                Return Nothing
            Catch ex As Exception
                Throw ex
            End Try
        Catch ex As Exception
            Throw ex
        End Try
    End Function
#End Region

#Region "ASA Status"
    Friend Function LoadASAStatuses() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("asa_status_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetPatientASAStatuses(patientId As Integer, procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_asa_status_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub savePatientASAStatus(patientId As Integer, procedureId As Integer, ASAStatusId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("patient_asa_status_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@ASAStatusId", ASAStatusId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

#Region "Comorbidity"
    Friend Function LoadComorbidities(procType As String) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("comorbidity_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procType))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetProcedureComorbidity(procedureId As Integer?, preAssessmentId As Integer?) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_comorbidity_select", connection)
                cmd.CommandType = CommandType.StoredProcedure

                If procedureId Is Nothing Or procedureId = 0 Then

                    cmd.Parameters.Add(New SqlParameter("@ProcedureId", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                End If

                If preAssessmentId Is Nothing Or preAssessmentId = 0 Then
                    cmd.Parameters.Add(New SqlParameter("@PreAssessmentId", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PreAssessmentId", preAssessmentId))
                End If


                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub saveComorbidity(procedureId As Integer?, preAssessmentId As Integer?, comorbidityId As Integer, childId As Integer, selected As Boolean, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_comorbidity_save", connection)
                cmd.CommandType = CommandType.StoredProcedure

                If procedureId Is Nothing Then
                    cmd.Parameters.Add(New SqlParameter("@ProcedureId", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                End If

                If preAssessmentId Is Nothing Then
                    cmd.Parameters.Add(New SqlParameter("@PreAssessmentId", DBNull.Value))
                Else
                    cmd.Parameters.Add(New SqlParameter("@PreAssessmentId", preAssessmentId))
                End If

                cmd.Parameters.Add(New SqlParameter("@ComorbidityId", comorbidityId))
                cmd.Parameters.Add(New SqlParameter("@ChildComorbidityId", childId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

#End Region

#Region "Planned procedures"

    Friend Function LoadPlannedProcedures(procType As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("planned_procedures_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procType))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
#End Region
#Region "Indications"

    Friend Function LoadIndications(procType As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("indications_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procType))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Friend Function LoadSubIndications(procType As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("subindications_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procType))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Public Function GetProcedureIndications(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_indications_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Public Function GetProcedureSubIndications(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_subindications_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub saveIndication(procedureId As Integer, indicationId As Integer, childId As Integer, selected As Boolean, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_indications_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@IndicationId", indicationId))
                cmd.Parameters.Add(New SqlParameter("@ChildIndicationId", childId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Friend Sub saveSubIndication(procedureId As Integer, subIndicationId As Integer, selected As Boolean, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_subindications_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@SubIndicationId", subIndicationId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Friend Function LoadProviders() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("provider_sectors_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function LoadProcedureCategories() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("urgency_types_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub deleteSubIndications(procedureId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_subindications_delete", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

#End Region

#Region "Imaging"

    Friend Function LoadImagingMethods() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("imaging_method_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetProcedureImagingMethod(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_imaging_method_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub saveImagingMethod(procedureId As Integer, imagingMethodId As Integer, selected As Boolean, AdditionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_imaging_method_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ImagingMethodId", imagingMethodId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", AdditionalInfo))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Friend Function LoadImagingOutcomes() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("imaging_outcomes_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetProcedureImagingOutcomes(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_imaging_outcomes_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub saveImagingOutcome(procedureId As Integer, imagingOutcomeId As Integer, childOutcomeId As Integer, selected As Boolean, AdditionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_imaging_outcome_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ImagingOutcomeId", imagingOutcomeId))
                cmd.Parameters.Add(New SqlParameter("@ChildOutcomeId", childOutcomeId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", AdditionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

#End Region

#Region "Procedure Timings"
    Public Function GetProcedureTimings(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_timings_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub saveProcedureTimings(procedureId As Integer, startDateTime As DateTime?, endDateTime As DateTime?)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_timings_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@StartDateTime", If(startDateTime.HasValue, startDateTime, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@EndDateTime", If(endDateTime.HasValue, endDateTime, DBNull.Value)))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub saveGastricInspectionTimings(siteId As Integer, startDateTime As DateTime, endDateTime As DateTime)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("gastric_inspection_timings_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.Parameters.Add(New SqlParameter("@StartDateTime", startDateTime))
                cmd.Parameters.Add(New SqlParameter("@EndDateTime", endDateTime))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetGastricInspectionTimings(siteId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("gastric_inspection_timings_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
#End Region

#Region "AI Software"

    Public Function LoadAISoftware() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("ai_software_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function GetProcedureAISoftware(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_ai_software_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub saveProcedureAISoftware(procedureId As Integer, AISoftwareId As Integer, AISoftwareOther As String, AISoftwareName1 As String, AISoftwareName2 As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_ai_software_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@AISoftwareId", AISoftwareId))
                cmd.Parameters.Add(New SqlParameter("@AISoftwareOther", AISoftwareOther))
                cmd.Parameters.Add(New SqlParameter("@AISoftwareName", AISoftwareName1))
                cmd.Parameters.Add(New SqlParameter("@AIOtherSoftwareName", AISoftwareName2))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub saveProcedureDistalAttachment(procedureId As Integer, distalAttachmentId As Integer, distalAttachmentOther As String, selected As Boolean)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_distal_attachment_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@DistalAttachmentId", distalAttachmentId))
                cmd.Parameters.Add(New SqlParameter("@DistalAttachmentOther", distalAttachmentOther))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

#Region "DICA Scoring"
    Public Sub saveProcedureDICAScores(siteId As Integer, ExtensionId As Integer, GradeId As Integer, InflammatorySignsId As Integer, ComplicationsId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_DICA_score_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.Parameters.Add(New SqlParameter("@ExtensionId", ExtensionId))
                cmd.Parameters.Add(New SqlParameter("@GradeId", GradeId))
                cmd.Parameters.Add(New SqlParameter("@InflammatorySignsId", InflammatorySignsId))
                cmd.Parameters.Add(New SqlParameter("@ComplicationsId", ComplicationsId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetProcedureDICAScores(siteId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_DICA_score_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function LoadDICAScores() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("DICA_scores_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
#End Region

#Region "Procedure Drugs"
    Public Sub saveProcedureDrugs(procedureId As Integer, drugNo As Integer, dose As String, units As String, selected As Boolean)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_drugs_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@DrugNo", drugNo))
                cmd.Parameters.Add(New SqlParameter("@Dose", dose))
                cmd.Parameters.Add(New SqlParameter("@Units", units))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

#Region "Bowel prep"
    Public Function LoadBowelPrep() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("bowel_prep_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function LoadEnemaBowelPrep() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("enema_bowel_prep_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveBowelPrep(procedureId As Integer, bowelPrepId As Integer, leftScore As Integer, rightScore As Integer, transverseScore As Integer, totalScore As Integer, additionalInfo As String, quantity As Decimal, enemaId As Integer, enemaOther As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_bowel_prep_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@BowelPrepId", bowelPrepId))
                cmd.Parameters.Add(New SqlParameter("@Quantity", quantity))
                cmd.Parameters.Add(New SqlParameter("@EnemaId", enemaId))
                cmd.Parameters.Add(New SqlParameter("@EnemaOther", enemaOther))
                cmd.Parameters.Add(New SqlParameter("@LeftScore", leftScore))
                cmd.Parameters.Add(New SqlParameter("@RightScore", rightScore))
                cmd.Parameters.Add(New SqlParameter("@TransverseScore", transverseScore))
                cmd.Parameters.Add(New SqlParameter("@TotalScore", totalScore))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getProcedureBowelPrep(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_bowel_prep_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

#End Region

#Region "Level of complexity"
    Public Function LoadLevelOfComplexity() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("level_of_complexity_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveProcedureLevelOfComplexity(procedureId As Integer, complexityId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_level_of_complexity_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ComplexityId", complexityId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getProcedureLevelOfComplexity(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_level_of_complexity_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
#End Region

#Region "Insertion technique"
    Public Function LoadInsertionTechniques() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("insertion_techniques_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveInsertionTechnique(procedureId As Integer, insertionTechniqueId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_insertion_technique_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@InsertionTechniqueId", insertionTechniqueId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getProcedureInsertionTechnique(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_insertion_technique_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function



#End Region

#Region "Adverse Events"
    Public Function LoadAdverseEvents(procType As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("adverse_events_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procType))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function getProcedureAdverseEvents(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_adverse_events_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Sub saveAdverseEvents(procedureId As Integer, adverseeventId As Integer, childId As Integer, selected As Boolean, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_adverse_events_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@AdverseEventId", adverseeventId))
                cmd.Parameters.Add(New SqlParameter("@ChildAdverseEventId", childId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

#Region "Management"
    Friend Function LoadManagement() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("management_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetProcedureManagement(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_management_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub saveManagement(procedureId As Integer, managementId As Integer, childId As Integer, selected As Boolean, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_management_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ManagementId", managementId))
                cmd.Parameters.Add(New SqlParameter("@ChildManagementId", childId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

#End Region

#Region "Complications"
    Friend Function LoadComplications() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("complication_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Function GetProcedureComplication(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_complication_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Friend Sub saveComplication(procedureId As Integer, complicationId As Integer, childId As Integer, selected As Boolean, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_management_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ManagementId", complicationId))
                cmd.Parameters.Add(New SqlParameter("@ChildManagementId", childId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

#End Region



#Region "Chromendoscopies"
    Public Function LoadChromendoscopies() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("chromendoscopies_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveProcedureChromendoscopy(procedureId As Integer, chromendoscopyId As Integer, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_chromendoscopy_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@ChromendoscopyId", chromendoscopyId))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getProcedureChromendoscopy(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_chromendoscopy_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
#End Region

#Region "Mucosal Visualisation"
    Public Function LoadMucosalVisualisation() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("musocal_visualisation_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveProcedureMucosalVisualisation(procedureId As Integer, mucosalVisualisationId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_musocal_visualisation_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@MucosalVisualisationId", mucosalVisualisationId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getProcedureMucosalVisualisation(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_musocal_visualisation_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
#End Region

#Region "Mucosal Cleaning"
    Public Function LoadMucosalCleaning() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("musocal_cleaning_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveProcedureMucosalCleaning(procedureId As Integer, mucosalCleaningId As Integer, additionalInfo As String, selected As Boolean)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_musocal_cleaning_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@MucosalCleaningId", mucosalCleaningId))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getProcedureMucosalCleaning(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_musocal_cleaning_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
#End Region

#Region "Procedure Insufflation"
    Public Function LoadInsufflation() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("insufflation_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveProcedureInsufflation(procedureId As Integer, insufflationId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_insufflation_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@InsufflationId", insufflationId))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                'Added by rony tfs-4358
                If insufflationId > 0 Then
                    connection.Open()
                    cmd.ExecuteNonQuery()
                End If
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getProcedureInsufflation(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_insufflation_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
#End Region

#Region "Procedure Enteroscopy Technique"
    Public Function LoadEnteroscopyTechniques() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("enteroscopy_techniques_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveProcedureEnteroscopyTechnique(procedureId As Integer, techniqueId As Integer, additionalInfo As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_enteroscopy_technique_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@TechniqueId", techniqueId))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getProcedureEnteroscopyTechnique(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_enteroscopy_technique_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
#End Region

#Region "Insertion depth"
    Public Function getProcedureInsertionDepth(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_insertion_depth_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveProcedureInsertionLength(procedureId As Integer, insertionLength As Integer, tattooed As Boolean)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_insertion_depth_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@InsertionLength", insertionLength))
                cmd.Parameters.Add(New SqlParameter("@Tattooed", tattooed))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

    Friend Function saveNewTextEntry(sectionName As String, newText As String) As Integer
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("add_new_reference_item", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SectionName", sectionName))
                cmd.Parameters.Add(New SqlParameter("@NewItem", newText))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@NewId", SqlDbType.Int))
                cmd.Parameters("@NewId").Direction = ParameterDirection.Output
                connection.Open()
                cmd.ExecuteNonQuery()
                Return cmd.Parameters("@NewId").Value
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Public Sub MarkSectionComplete(ByVal ProcedureId As Integer,
                                   ByVal SectionName As String)

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("UI_update_procedure_summary", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@Section", SectionName))
            cmd.Parameters.Add(New SqlParameter("@Summary", SectionName))
            cmd.Parameters.Add(New SqlParameter("@ResultId", "1"))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using

    End Sub

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function IsLymphNodeBySiteId(siteId As Integer) As Boolean

        Try
            Dim isLymphNode As Boolean = False

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("IsLymphNodeBySiteId", connection)

                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@siteId", siteId))

                connection.Open()
                isLymphNode = cmd.ExecuteScalar()
            End Using

            Session(Constants.SESSION_IS_LYMPH_NODE_SITE) = isLymphNode

            Return isLymphNode

        Catch ex As Exception
            Throw ex
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllRooms() As DataTable
        Return ExecuteSP("dbo.GetAllRooms")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAllRoomsForSelectedHospitals(hospitalIds As String) As DataTable
        Try
            Dim dsData As New DataSet
            Dim da As SqlDataAdapter

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("GetAllRoomsForSelectedHospitals", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@HospitalIds", hospitalIds))

                connection.Open()
                da = New SqlDataAdapter(cmd)
                da.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If

            Return Nothing

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function: DataAccess.GetAllRoomsForSelectedHospitals.", ex)
            Return Nothing
        End Try
    End Function


    Public Function GetAuditReportsScheduler() As DataTable
        Return ExecuteSP("GetAuditReportsScheduler")
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPreAssessmentQuestionList(preAssessmentId As Integer, Optional trustId As Integer? = Nothing) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("GetPreAssessmentQuestionList", connection)

            cmd.CommandType = CommandType.StoredProcedure
            If preAssessmentId > 0 Then
                cmd.Parameters.Add(New SqlParameter("@PreAssessmentId", preAssessmentId))
            End If
            cmd.Parameters.Add(New SqlParameter("@TrustId", trustId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetNurseModuleList(patientId As Integer) As DataSet
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("GetNurseModuleList", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@patientId", patientId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult
        End If
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetNurseModuleQuestionAndAnswerList(procTypes As String, nurseModuleId As Integer, Optional trustId As Integer? = Nothing) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As New SqlCommand("GetNurseModuleQuestionAndAnswerList", connection)
            cmd.CommandType = CommandType.StoredProcedure

            If nurseModuleId > 0 Then
                cmd.Parameters.Add(New SqlParameter("@NurseModuleId", nurseModuleId))
            Else
                cmd.Parameters.Add(New SqlParameter("@NurseModuleId", DBNull.Value))
            End If
            cmd.Parameters.Add(New SqlParameter("@procedureType", procTypes))
            cmd.Parameters.Add(New SqlParameter("@trustId", trustId))
            Dim adapter As New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetLetterQueueList(Optional startDate As Date? = Nothing, Optional endDate As Date? = Nothing, Optional viewAll As Integer? = Nothing) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sql = "select pt.NHSNo,pt.PatientId,lq.ProcedureId, pt.Forename1,pt.Surname,lq.LetterTypeId,lq.Printed,lq.whencreated " +
                      "from ERS_LetterQueue lq, ERS_Patients pt " +
                        "where lq.PatientId=pt.PatientId " +
                        "And lq.whencreated between @StartDate And @EndDate"
            If viewAll = 0 Then
                sql = sql + " And Printed=@isPrinted"
            Else

            End If

            Dim cmd As New SqlCommand(sql, connection)

            cmd.CommandType = CommandType.Text

            If startDate Is Nothing Then
                cmd.Parameters.Add(New SqlParameter("@StartDate", DBNull.Value))
            Else
                cmd.Parameters.Add(New SqlParameter("@StartDate", startDate.Value))
            End If
            If endDate Is Nothing Then
                cmd.Parameters.Add(New SqlParameter("@EndDate", DBNull.Value))
            Else

                cmd.Parameters.Add(New SqlParameter("@EndDate", endDate.GetValueOrDefault().AddDays(1).AddSeconds(-1)))
            End If
            If viewAll = 0 Then
                sql = sql + " And Printed=@isPrinted"
                cmd.Parameters.Add(New SqlParameter("@isPrinted", 0))
            Else

            End If

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Sub InsertPatientIntoTrust(ByVal PatientId As Integer,
                                ByVal TrustId As Integer,
                                ByVal HospitalNumber As String)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("patients_trust_insert", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            cmd.Parameters.Add(New SqlParameter("@TrustId", TrustId))
            cmd.Parameters.Add(New SqlParameter("@HospitalNumber", HospitalNumber))
            connection.Open()
            cmd.ExecuteScalar()
        End Using
    End Sub

    Public Sub SetReportPrinted(ProcedureId As Integer)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("usp_SetProcedurePrinted", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            connection.Open()
            cmd.ExecuteScalar()
        End Using

    End Sub

    Public Function IsProcedurePrinted(ProcedureId As Integer) As Boolean
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("usp_IsProcedurePrinted", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            connection.Open()
            Dim r As Object = cmd.ExecuteScalar
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return r
            Else
                Return False
            End If
        End Using
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Friend Shared Function GetGPEmailAddress(ByVal patientId As Integer, Optional ByVal userId? As Integer = Nothing, Optional ByVal userName As String = "") As DataTable
        Try
            Dim dsData As New DataSet
            Dim da As SqlDataAdapter

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("get_gp_email_address", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@PatientId", patientId))
                cmd.Parameters.Add(New SqlParameter("@UserId", userId))
                cmd.Parameters.Add(New SqlParameter("@UserName", userName))

                connection.Open()
                da = New SqlDataAdapter(cmd)
                da.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If

            Return Nothing

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function: DataAccess.GetGPEmailAddress.", ex)
            Return Nothing
        End Try
    End Function

    Protected Friend Shared Sub SetEmailSettings(deliveryMethod As String, useDefaultCredentials As Boolean, portNo As String,
                                 enableSsl As Boolean, host As String, fromAddress As String, fromName As String, fromPassword As String)

        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("SetEmailSettings", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("DeliveryMethod", deliveryMethod))
                cmd.Parameters.Add(New SqlParameter("UseDefaultCredentials", useDefaultCredentials))
                cmd.Parameters.Add(New SqlParameter("PortNo", portNo))
                cmd.Parameters.Add(New SqlParameter("EnableSsl", enableSsl))
                cmd.Parameters.Add(New SqlParameter("Host", host))
                cmd.Parameters.Add(New SqlParameter("fromAddress", fromAddress))
                cmd.Parameters.Add(New SqlParameter("fromName", fromName))
                cmd.Parameters.Add(New SqlParameter("fromPassword", fromPassword))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using

        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Shared Function GetEmailSettings() As DataTable

        'Dim cmd As New SqlCommand("GetEmailSettings", connection)
        'Dim cmd As New SqlCommand()
        Dim sqlString As String = "GetEmailSettings"
        Dim dsData As New DataSet
        Dim da As SqlDataAdapter

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sqlString, connection)
                da = New SqlDataAdapter(cmd)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Connection.Open()
                da.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing

        Catch ex As Exception
            Return Nothing
        End Try

    End Function

    Public Function SendEmail(smtpInfo As Products_Options_EmailSettings.SMTPInfo, toEmailAddressCollection As MailAddressCollection,
                              subject As String, body As String, messageAttachment As Attachment,
                              Optional isBodyHtml As Boolean = False) As Boolean

        Dim fromAddress = New MailAddress(smtpInfo.SMTP_FromAddress, smtpInfo.SMTP_FromName)
        Dim client As SmtpClient = New SmtpClient()

        With client
            .DeliveryMethod = SmtpDeliveryMethod.Network
            .Host = smtpInfo.SMTP_Host
            .Port = smtpInfo.SMTP_Port
            .EnableSsl = smtpInfo.SMTP_EnableSSL

            If smtpInfo.SMTP_DefaultCredentials = False Then
                client.Credentials = New NetworkCredential(fromAddress.DisplayName, smtpInfo.SMTP_FromPassword)
            End If
        End With

        Dim mailMessage = New MailMessage()

        For Each emailAddress In toEmailAddressCollection
            mailMessage.To.Add(emailAddress)
        Next

        Using mailMessage
            With mailMessage
                .From = fromAddress
                .Subject = subject
                .IsBodyHtml = True
                .Body = body
                .Attachments.Add(messageAttachment)
                .BodyEncoding = System.Text.Encoding.UTF8
            End With

            Try
                client.Send(mailMessage)
                Return True
            Catch ex As Exception
                Debug.WriteLine(ex.Message)
                Return False
            End Try
        End Using
        Return False
    End Function

    Public Shared Function GetConsultantProcedureEmailAddress(procedureId As Integer) As String

        Dim sqlString As String = "get_consultant_email_address"
        Dim dsData As New DataSet
        Dim da As SqlDataAdapter

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sqlString, connection)
                da = New SqlDataAdapter(cmd)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("procedureId", procedureId))

                cmd.Connection.Open()
                Return cmd.ExecuteScalar()
            End Using
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    Public Shared Function CheckUserAuditReportViewSetting(userId As String) As String

        Dim da As New DataAccess()
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("CheckUserAuditReportViewSetting", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@UserId", userId))
                connection.Open()
                Return CStr(cmd.ExecuteScalar())
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(
                "Error occurred in Function: DataAccess.CheckUserAuditReportViewSetting.", ex)
            Return Nothing
        End Try
    End Function

    Public Function CheckEmailCanBeCreated(patientId As Int32) As Boolean
        Dim checkGPEmailExistsFlag As Boolean = False
        Dim checkConsultantEmailExistsFlag As Boolean = False
        Dim gpEmailAddressString As String = ""
        Dim gpEmailAddressReturnCodeString As String = ""
        Dim consultantEmailAddressString As String = ""
        Dim customExceptionErrorMessage As New Exception()
        Dim customExceptionErrorDescription As String = ""

        Try
            Dim dtCheckMail As DataTable = GetGPEmailAddress(patientId)
            Dim drCheckMail As DataRow = dtCheckMail.Rows(0)

            'Email report - check if GP or Referring Consultant has an email address
            gpEmailAddressString = drCheckMail("EmailAddress").ToString()
            gpEmailAddressReturnCodeString = drCheckMail("ReturnCode").ToString()

            Session("GPEmailAddressReasonCode") = gpEmailAddressReturnCodeString

            consultantEmailAddressString = GetConsultantProcedureEmailAddress(Session(Constants.SESSION_PROCEDURE_ID))

            If gpEmailAddressReturnCodeString.ToLower() = "ok" Then
                If Not String.IsNullOrEmpty(gpEmailAddressString) Then
                    checkGPEmailExistsFlag = True

                    Session("GPEmailAddress") = gpEmailAddressString
                End If
            End If

            If Not String.IsNullOrEmpty(consultantEmailAddressString) Then
                checkConsultantEmailExistsFlag = True
                Session("ConsultEmailAddress") = consultantEmailAddressString
            End If

            If Not checkGPEmailExistsFlag And Not checkConsultantEmailExistsFlag Then
                customExceptionErrorMessage = New Exception(message:="Warning: GP and Consultant Email Addresses do not exist for this patient.")
                customExceptionErrorDescription = "GPEmailAddress returned: " + gpEmailAddressReturnCodeString + " ConsultantEmailAddressString: Consultant email address needs to be added to the ERS_UpperGIFollowUp table."

                LogManager.LogManagerInstance.LogError(customExceptionErrorDescription, customExceptionErrorMessage)
            Else
                Return True
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(
                "Error occurred in Function: DataAccess.CheckEmailCanBeCreated.", ex)
            Return False
        End Try

    End Function

    Public Function CreateEmail() As String

        'Send email as at least one email address exists to send to!
        Dim mmSubject = "Solus Endoscopy Report Email"
        Dim mmBody = "Please find attached the endoscopy report for " + StrConv(Session("PatForename"), vbProperCase) + " " +
                     StrConv(Session("PatSurname"), vbProperCase)

        ''Dim attachmentFileName AS String = "C:\Users\adrian.HDC\Downloads\TestEmailAttachment.txt"
        'Dim attachmentFileName AS String = GetPDFExportLocation(Session("OperatingHospitalID"))
        Dim attachmentFileName As String
        Dim toEmailAddressCollection As New MailAddressCollection

        toEmailAddressCollection.Add(Session("toEmailAddress"))

        'If (Right(attachmentFileName, 1) <> "\") Then
        '    attachmentFileName = attachmentFileName + "\"
        'End If

        'attachmentFileName = attachmentFileName + "84512_16-11-2021_14-52-55_Gastroscopy_5395.pdf" 'Session("PDFPathAndFileName")
        attachmentFileName = Session("PDFPathAndFileName")

        Dim messageAttachment = New Attachment(attachmentFileName)

        Dim smtpInfo = New Products_Options_EmailSettings.SMTPInfo()

        Dim dtMailSettings As DataTable = DataAccess.GetEmailSettings()
        Dim drMailSettings As DataRow = dtMailSettings.Rows(0)

        'If there aren't any email settings saved in the DB for sending email then can't send either!
        If Not IsNothing(dtMailSettings) Then
            If dtMailSettings.Rows.Count > 0 Then

                smtpInfo.SMTP_Host = drMailSettings("Host")
                smtpInfo.SMTP_Port = drMailSettings("PortNo")
                smtpInfo.SMTP_EnableSSL = drMailSettings("EnableSSL")
                smtpInfo.SMTP_FromAddress = drMailSettings("FromAddress")
                smtpInfo.SMTP_FromName = drMailSettings("FromName")
                smtpInfo.SMTP_FromPassword = drMailSettings("FromPassword")
                smtpInfo.SMTP_DefaultCredentials = drMailSettings("UseDefaultCredentials")

                Return SendEmail(smtpInfo, toEmailAddressCollection, mmSubject, mmBody,
                          messageAttachment, False)
            End If
        End If

        Return False

    End Function

    Public Function IsGlobalAdmin(userId As Integer) As Boolean

        Dim idObj As Object

        Using connection As New SqlConnection(ConnectionStr)

            Dim sql As New StringBuilder
            sql.Append("DECLARE @RoleID VARCHAR(70) ")
            sql.Append("SELECT @RoleID=RoleID FROM ERS_Users where UserID = @UserID ")
            sql.Append("SELECT [item] INTO #tmpRole FROM dbo.fnSplitString(@RoleID,',') ")
            sql.Append("SELECT 1 FROM ERS_Roles where RoleId in(SELECT [item] FROM #tmpRole) and RoleName = 'GlobalAdmin' ")

            Dim cmd As New SqlCommand(sql.ToString(), connection)

            cmd.Parameters.Add(New SqlParameter("@UserId", userId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            idObj = cmd.ExecuteScalar()
            If Not IsDBNull(idObj) AndAlso Not IsNothing(idObj) Then
                Return True
            Else
                Return False
            End If
        End Using
    End Function
#Region "Cystosopy"
    Public Function GetProcedurePreviousDiseaseUrology(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_PreviousDiseaseUrology_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function GetProcedureUrineDipstickCytology(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_UrineDipstickCytology_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function GetProcedureLUTSIPSSSymptoms(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_ERS_LUTSIPSSSymptoms_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function GetProcedureCystoscopyHeader(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_CystoscopyHeader_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function GetCystoscopyType() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("Procedure_CystoscopyType_Select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function GetSmokingType() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SmokingType_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function GetAlcoholingType() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("AlcoholingType_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function GetSmokingDetails(ProcedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("SmokingDetail_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function GetAlcoholingDetails(ProcedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("AlcoholingDetail_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Friend Function LoadPreviousDiseasesUrology(procType As Integer, ImageGenderId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("PreviousDiseasesUrology_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procType))
                cmd.Parameters.Add(New SqlParameter("@ImageGenderId", ImageGenderId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
        Catch ex As Exception
            Throw ex
        End Try

    End Function
    Friend Function LoadUrineDipstickCytology(procType As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("UrineDipstickCytology_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procType))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
        Catch ex As Exception
            Throw ex
        End Try

    End Function
    Friend Function LoadLUTSIPSSSymtoms(procType As Integer, AddInTotalScore As Boolean) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("LUTSIPSSSymptoms_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", procType))
                cmd.Parameters.Add(New SqlParameter("@AddInTotalScore", AddInTotalScore))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
                If dsData.Tables.Count > 0 Then
                    Return dsData.Tables(0)
                End If
                Return Nothing
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Friend Function LoadIPSSScoreList() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("get_IPSSScoreList", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
                If dsData.Tables.Count > 0 Then
                    Return dsData.Tables(0)
                End If
                Return Nothing
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Friend Function LoadPreviousDiseaseProstateSurgeryList() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("get_PreviousDiseaseProstateSurgeryList", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
                If dsData.Tables.Count > 0 Then
                    Return dsData.Tables(0)
                End If
                Return Nothing
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Friend Function LoadIPSSScoreListQuality() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("get_IPSSScoreListQuality", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
                If dsData.Tables.Count > 0 Then
                    Return dsData.Tables(0)
                End If
                Return Nothing
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Friend Sub saveLUTSIPSSSymptoms(procedureId As Integer, LUTSIPSSSymptomId As Integer, IsScore As Boolean, SelectedScoreId As Integer, TotalScoreValue As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_LUTSIPSSScore_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@LUTSIPSSSymptomId", LUTSIPSSSymptomId))
                cmd.Parameters.Add(New SqlParameter("@IsScore", IsScore))
                cmd.Parameters.Add(New SqlParameter("@SelectedScoreId", SelectedScoreId))
                cmd.Parameters.Add(New SqlParameter("@TotalScoreValue", TotalScoreValue))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Sub saveUrineDipstickCytology(procedureId As Integer, previousDiseaseId As Integer, selected As Boolean, additionalInfo As String, childId As Int64, Optional ByVal dateSent As String = Nothing)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_UrineDipstickCytology_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@UrineDipstickCytologyId", previousDiseaseId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@childUrineDipstickCytologyId", childId))
                If Not (dateSent = Nothing) Then
                    cmd.Parameters.Add(New SqlParameter("@dateSent", Date.ParseExact(dateSent, "dd/MM/yyyy", Nothing)))
                End If
                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Sub savePreviousDiseaseUrology(procedureId As Integer, previousDiseaseId As Integer, selected As Boolean, additionalInfo As String, childId As Int64)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_previousDiseaseUrology_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@PreviousDiseaseId", previousDiseaseId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@AdditionalInfo", additionalInfo))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@childPreviousDiseaseId", childId))
                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Sub saveSmoking(procedureId As Integer, PatientId As Integer, SmokingTypeId As Integer, SmokingStatus As String, AverageSmoking As Integer, SmokingNoYear As Integer, SmokedQuitYears As Integer, SmokedPerday As Integer, SmokedNoYear As Integer)
        Try

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_Smoking_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
                cmd.Parameters.Add(New SqlParameter("@SmokingTypeId", SmokingTypeId))
                cmd.Parameters.Add(New SqlParameter("@SmokingStatus", SmokingStatus))
                cmd.Parameters.Add(New SqlParameter("@AverageSmoking", AverageSmoking))
                cmd.Parameters.Add(New SqlParameter("@SmokingNoYear", SmokingNoYear))
                cmd.Parameters.Add(New SqlParameter("@SmokedQuitYears", SmokedQuitYears))
                cmd.Parameters.Add(New SqlParameter("@SmokedPerday", SmokedPerday))
                cmd.Parameters.Add(New SqlParameter("@SmokedNoYear", SmokedNoYear))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Sub saveAlcoholing(procedureId As Integer, PatientId As Integer, AlcoholingTypeId As Integer, AlcoholingStatus As String, AverageAlcoholing As Integer, AlcoholingNoYear As Integer, AlcoholedQuitYears As Integer, AlcoholedPerday As Integer, AlcoholedNoYear As Integer)
        Try

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_Alocoholing_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
                cmd.Parameters.Add(New SqlParameter("@AlcoholingTypeId", AlcoholingTypeId))
                cmd.Parameters.Add(New SqlParameter("@AlcoholingStatus", AlcoholingStatus))
                cmd.Parameters.Add(New SqlParameter("@AverageAlcoholing", AverageAlcoholing))
                cmd.Parameters.Add(New SqlParameter("@AlcoholingNoYear", AlcoholingNoYear))
                cmd.Parameters.Add(New SqlParameter("@AlcoholedQuitYears", AlcoholedQuitYears))
                cmd.Parameters.Add(New SqlParameter("@AlcoholedPerday", AlcoholedPerday))
                cmd.Parameters.Add(New SqlParameter("@AlcoholedNoYear", AlcoholedNoYear))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Sub saveCystoscopyHeader(procedureId As Integer, CystoscopyTypeId As String, CystoscopyProcedureType As String)
        Try

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_CystoscopyHeader_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@CystoscopyTypeId", CystoscopyTypeId))
                cmd.Parameters.Add(New SqlParameter("@CystoscopyProcedureType", CystoscopyProcedureType))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Sub DeleteSmoking(ProcedureSmokingId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_smoking_delete", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureSmokingId", ProcedureSmokingId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Friend Sub DeleteAlcoholing(ProcedureAlcoholingId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_alcoholing_delete", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureAlcoholingId", ProcedureAlcoholingId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetGenderSpecific(ProcedureTypeId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("GetGenderSpecific", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", ProcedureTypeId))

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function
    Public Function GetGenderList() As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("usp_get_genders", connection)
            cmd.CommandType = CommandType.StoredProcedure

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing

    End Function

    Public Function LoadSydneyProtocolSites() As DataTable
        Dim dsData As New DataSet
        Dim da As SqlDataAdapter

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("sydney_protocol_sites_select", connection)
                da = New SqlDataAdapter(cmd)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Connection.Open()
                da.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing

        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    Public Function LoadProcedureSydneyProtocolSites(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Dim da As SqlDataAdapter

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_sydney_protocol_select", connection)
                da = New SqlDataAdapter(cmd)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Connection.Open()
                da.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing

        Catch ex As Exception
            Return Nothing
        End Try
    End Function

#End Region

#Region "EBUS"
    Public Function GetEbusLymphNodeNameBySiteId(siteId As Integer) As String
        Try
            Dim ebusLymphNodeName As String = ""

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("GetEbusLymphNodeNameBySiteId", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@siteId", siteId))

                connection.Open()
                ebusLymphNodeName = cmd.ExecuteScalar()
            End Using

            Return ebusLymphNodeName
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Procedure: DataAccess.GetEbusLymphNodeNameBySiteId.", ex)

            Return Nothing
        End Try
    End Function

    Public Function getProcedureReferralData(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(ConnectionStr)
            Dim cmd As New SqlCommand("procedure_broncho_referral_data_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Sub saveBronchoReferralData(procedureId As Integer, dateBronchRequested As DateTime?, dateOfReferral As DateTime?, lcaSuspectedBySpecialist As Boolean, CTScanAvailable As Boolean, dateOfScan As DateTime?)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_broncho_referral_data_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@DateBronchRequested", dateBronchRequested))
                cmd.Parameters.Add(New SqlParameter("@DateOfReferral", dateOfReferral))
                cmd.Parameters.Add(New SqlParameter("@LCaSuspectedBySpecialist", lcaSuspectedBySpecialist))
                cmd.Parameters.Add(New SqlParameter("@CTScanAvailable", CTScanAvailable))
                cmd.Parameters.Add(New SqlParameter("@DateOfScan", dateOfScan))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
#End Region

#Region "GP Module"
    Public Shared Function CheckIfPDFReportExists(procedureId As Integer) As DataTable

        Dim sqlString As String = "CheckIfPDFReportExists"
        Dim dsData As New DataSet
        Dim da As SqlDataAdapter

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sqlString, connection)
                da = New SqlDataAdapter(cmd)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Connection.Open()
                da.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(
                "Error occurred in Function: DataAccess.CheckIfPDFReportExists.", ex)
            Return Nothing
        End Try

    End Function

    Public Shared Sub SavePdfExportFilePathNameToDb(procedureId As Integer, fileName As String, isReportEmailed As Boolean)

        Dim sqlString As String = "SavePdfExportFilePathNameToDb"

        Try
            DataAccess.ExecuteScalerSQL("SavePdfExportFilePathNameToDb",
                                        CommandType.StoredProcedure,
                                        New SqlParameter() {
                                                    New SqlParameter("@procedureId", procedureId),
                                                    New SqlParameter("@fileName", fileName),
                                                    New SqlParameter("@reportEmailed", isReportEmailed)})

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(
                "Error occurred in Function: DataAccess.SavePdfExportFilePathNameToDb.", ex)
        End Try

    End Sub

    Public Shared Function CheckIfGpConsultantEmailsSelected(procedureId As Integer) As DataTable

        Dim sqlString As String = "CheckIfGpConsultantEmailsSelected"
        Dim dsData As New DataSet
        Dim da As SqlDataAdapter

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sqlString, connection)
                da = New SqlDataAdapter(cmd)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Connection.Open()
                da.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError(
                "Error occurred in Function: DataAccess.CheckIfGpConsultantEmailsSelected.", ex)
            Return Nothing
        End Try
    End Function

#End Region

    Public Function GetCustomText(CustomTextId As String) As String
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("get_custom_text", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@CustomTextId", CustomTextId))
                connection.Open()
                Dim r As Object = cmd.ExecuteScalar
                If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                    Return CStr(r)
                Else
                    Return Nothing
                End If
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Procedure: DataAccess.GetCustomText.", ex)

            Return Nothing
        End Try
    End Function

    Public Function UseLabRequestForm(procedureId As Integer) As Boolean

        Dim sqlString As String = "UseLabRequestForm"
        Dim dsData As New DataSet
        Dim da As SqlDataAdapter

        Dim biopsy, brushCytology, needleAspirate, gastricWashing, hotBiopsy, polypectomy, urease As Boolean
        biopsy = False
        brushCytology = False
        needleAspirate = False
        gastricWashing = False
        hotBiopsy = False
        polypectomy = False
        urease = False

        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand(sqlString, connection)
                da = New SqlDataAdapter(cmd)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@procedureId", procedureId))
                cmd.Connection.Open()
                da.Fill(dsData)
            End Using

            If dsData.Tables.Count > 0 Then
                If dsData.Tables(0).Rows.Count > 0 Then

                    For Each row As DataRow In dsData.Tables(0).Rows
                        If row.Item("Biopsy") = True Then
                            biopsy = True
                        End If
                        If row.Item("BrushCytology") = True Then
                            brushCytology = True
                        End If
                        If row.Item("NeedleAspirate") = True Then
                            needleAspirate = True
                        End If
                        If row.Item("GastricWashing") = True Then
                            gastricWashing = True
                        End If
                        If row.Item("HotBiopsy") = True Then
                            hotBiopsy = True
                        End If
                        If row.Item("Polypectomy") = True Then
                            polypectomy = True
                        End If
                        If row.Item("Urease") = True Then
                            urease = True
                        End If
                    Next row

                    If urease = True And (biopsy = True Or brushCytology = True Or needleAspirate = True Or gastricWashing = True Or hotBiopsy = True Or polypectomy = True) Then
                        Return True
                    ElseIf urease = False And (biopsy = True Or brushCytology = True Or needleAspirate = True Or gastricWashing = True Or hotBiopsy = True Or polypectomy = True) Then
                        Return True
                    Else
                        Return False
                    End If

                Else
                    Return False
                End If
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function: DataAccess.UseLabRequestForm.", ex)
            Return False
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHospital() As DataTable
        Dim sqlStr As String = "SELECT [HospitalID],  [HospitalName],[Suppressed]  FROM [dbo].[ERS_ReferralHospitals] WHERE [Suppressed] = 0 AND TrustId = @TrustId ORDER BY HospitalName"
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
        'Return GetData(sqlStr)
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetHospitals() As DataTable
        Dim sqlStr As String = "SELECT [HospitalID],  [HospitalName],(CASE [Suppressed] WHEN 1 THEN 'Yes' ELSE 'No' END) as Suppressed   FROM [dbo].[ERS_ReferralHospitals] WHERE TrustId = @TrustId ORDER BY HospitalName"
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlStr, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@TrustId", Session("TrustId")))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
        'Return GetData(sqlStr)
    End Function

    Public Function InsertSSOUserWithGroup(ByVal username As String,
                              ByVal forename As String,
                              ByVal surname As String,
                              ByVal Fullname As String,
                              ByVal Groups As String,
                              ByVal OperatingHospitalId As Integer) As String

        Try

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("ERS_SSOInsertUser", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@Username", username)) ' AD user
                cmd.Parameters.Add(New SqlParameter("@Forename", forename))
                cmd.Parameters.Add(New SqlParameter("@Surname", surname))
                cmd.Parameters.Add(New SqlParameter("@Fullname", Fullname))
                cmd.Parameters.Add(New SqlParameter("@Groups", Groups))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
                Dim returnParameter = cmd.Parameters.Add("@ReturnVal", SqlDbType.Int)
                returnParameter.Direction = ParameterDirection.ReturnValue
                connection.Open()
                cmd.ExecuteNonQuery()
                Dim retStatus = returnParameter.Value
                Return CStr(retStatus)
            End Using
        Catch ex As Exception

            LogManager.LogManagerInstance.LogError("Error occurred in Procedure: DataAccess.InsertSSOUserWithGroup.", ex)
            Return "Error"
        End Try

    End Function


    ''' <summary>
    ''' Updates appointment status based on HDCKey
    ''' Booked=B
    ''' Attended=A
    ''' Arrived=BA
    ''' Cancelled=C
    ''' Abandoned=X
    ''' DNA=D
    ''' Booked=P
    ''' TCI - Booked=TCI
    ''' In Progress=IP
    ''' Received=R
    ''' Diary Deleted=DD
    ''' Discharged=DC
    ''' Recovery=RC
    ''' Reserved (in booking mode) =H
    ''' Booked (in edit mode) =E
    ''' </summary>
    ''' <param name="appointmentId"></param>
    ''' <param name="HDCKey"></param>
    Public Sub updateAppointmentStatus(appointmentId As Integer, HDCKey As String)
        Try

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("sch_update_appointment_status", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@AppointmentId", appointmentId))
                cmd.Parameters.Add(New SqlParameter("@HDCStatusKey", HDCKey))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getProcedureAppointment(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("sch_get_procedure_appointment", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function AddUpdatePatientFromNIPAPI(ByVal PatientId As Nullable(Of Integer),
                               ByVal CaseNoteNo As String,
                               ByVal Title As String,
                               ByVal Forename As String,
                               ByVal Surname As String,
                               ByVal DateOfBirth As Date,
                               ByVal NHSNo As String,
                               ByVal Address1 As String,
                               ByVal Address2 As String,
                               ByVal Town As String,
                               ByVal County As String,
                               ByVal PostCode As String,
                               ByVal PhoneNo As String,
                               ByVal Gender As String,
                               ByVal EthnicOrigin As String,
                               ByVal District As String,
                               ByVal GPGMCCode As String,
                               ByVal GPPracticeCode As String,
                               ByVal DateOfDeath As Nullable(Of Date),
                               ByVal Hospitals As Nullable(Of Integer),
                               ByVal UniqueHospitalId As Nullable(Of Integer),
                               ByVal MaritalStatus As String,
                               ByVal SearchedNHSNo As String,
                               ByVal intTrustId As Nullable(Of Integer)) As Integer

        Dim affectedPatientId As Integer


        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("stp_InsertUpdatePatientFromNIPAPI", connection)
            cmd.CommandType = CommandType.StoredProcedure

            If PatientId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            Else
                cmd.Parameters.Add(New SqlParameter("@PatientId", SqlTypes.SqlInt32.Null))
            End If
            If String.IsNullOrEmpty(CaseNoteNo) Then
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", CaseNoteNo))
            End If

            If String.IsNullOrEmpty(Title) Then
                cmd.Parameters.Add(New SqlParameter("@Title", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@Title", Title))
            End If

            If String.IsNullOrEmpty(Forename) Then
                cmd.Parameters.Add(New SqlParameter("@Forename", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@Forename", Forename))
            End If

            If String.IsNullOrEmpty(Surname) Then
                cmd.Parameters.Add(New SqlParameter("@Surname", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@Surname", Surname))
            End If


            cmd.Parameters.Add(New SqlParameter("@DateOfBirth", DateOfBirth))

            If Not String.IsNullOrEmpty(NHSNo) Then
                cmd.Parameters.Add(New SqlParameter("@NHSNo", NHSNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@NHSNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address1) Then
                cmd.Parameters.Add(New SqlParameter("@Address1", Address1))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address1", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address2) Then
                cmd.Parameters.Add(New SqlParameter("@Address2", Address2))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address2", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Town) Then
                cmd.Parameters.Add(New SqlParameter("@Town", Town))
            Else
                cmd.Parameters.Add(New SqlParameter("@Town", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(County) Then
                cmd.Parameters.Add(New SqlParameter("@County", County))
            Else
                cmd.Parameters.Add(New SqlParameter("@County", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PostCode) Then
                cmd.Parameters.Add(New SqlParameter("@PostCode", PostCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@PostCode", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PhoneNo) Then
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", PhoneNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Gender) Then
                cmd.Parameters.Add(New SqlParameter("@Gender", Gender))
            Else
                cmd.Parameters.Add(New SqlParameter("@Gender", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(EthnicOrigin) Then
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", EthnicOrigin))
            Else
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(MaritalStatus) Then
                cmd.Parameters.Add(New SqlParameter("@MaritalStatus", MaritalStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@MaritalStatus", SqlTypes.SqlString.Null))
            End If


            If Not String.IsNullOrEmpty(District) Then
                cmd.Parameters.Add(New SqlParameter("@District", District))
            Else
                cmd.Parameters.Add(New SqlParameter("@District", SqlTypes.SqlString.Null))
            End If

            If Not String.IsNullOrEmpty(GPGMCCode) Then
                cmd.Parameters.Add(New SqlParameter("@GPGMCCode", GPGMCCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPGMCCode", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(GPPracticeCode) Then
                cmd.Parameters.Add(New SqlParameter("@GPPracticeCode", GPPracticeCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPPracticeCode", SqlTypes.SqlInt32.Null))
            End If
            If DateOfDeath.HasValue Then
                If Date.MinValue = DateOfDeath Then
                    cmd.Parameters.Add(New SqlParameter("@DateOfDeath", SqlTypes.SqlDateTime.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@DateOfDeath", DateOfDeath))
                End If
            Else
                cmd.Parameters.Add(New SqlParameter("@DateOfDeath", SqlTypes.SqlDateTime.Null))
            End If



            If Hospitals.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Hospitals", Hospitals))
            Else
                cmd.Parameters.Add(New SqlParameter("@Hospitals", SqlTypes.SqlInt32.Null))
            End If


            If UniqueHospitalId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", UniqueHospitalId))
            Else
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", SqlTypes.SqlInt32.Null))
            End If


            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            If Not String.IsNullOrEmpty(SearchedNHSNo) Then
                cmd.Parameters.Add(New SqlParameter("@SearchedNHSNo", SearchedNHSNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@SearchedNHSNo", SqlTypes.SqlString.Null))
            End If

            If intTrustId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TrustId", intTrustId))
            Else
                cmd.Parameters.Add(New SqlParameter("@TrustId", SqlTypes.SqlInt32.Null))
            End If


            connection.Open()
            affectedPatientId = CInt(cmd.ExecuteScalar())
        End Using

        Return affectedPatientId
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTrustsFromSSOADGroupName(groups As String) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ERS_SSOGetTrustFromADGroupName", connection)
            cmd.CommandType = CommandType.StoredProcedure
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@groups", groups))
            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If

        Return Nothing


    End Function

    Public Function InsertSSOUserForTrust(ByVal username As String,
                             ByVal forename As String,
                             ByVal surname As String,
                             ByVal Fullname As String,
                             ByVal Groups As String,
                             ByVal OperatingHospitalId As Integer) As String

        Try

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("ERS_SSOInsertUserForTrust", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@Username", username)) ' AD user
                cmd.Parameters.Add(New SqlParameter("@Forename", forename))
                cmd.Parameters.Add(New SqlParameter("@Surname", surname))
                cmd.Parameters.Add(New SqlParameter("@Fullname", Fullname))
                cmd.Parameters.Add(New SqlParameter("@Groups", Groups))
                cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
                Dim returnParameter = cmd.Parameters.Add("@ReturnVal", SqlDbType.Int)
                returnParameter.Direction = ParameterDirection.ReturnValue
                connection.Open()
                cmd.ExecuteNonQuery()
                Dim retStatus = returnParameter.Value
                Return CStr(retStatus)
            End Using
        Catch ex As Exception

            LogManager.LogManagerInstance.LogError("Error occurred in Procedure: DataAccess.InsertSSOUserForTrust.", ex)
            Return "Error"
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function AddUpdatePatientFromSPINEAPI(ByVal PatientId As Nullable(Of Integer),
                             ByVal CaseNoteNo As String,
                             ByVal Title As String,
                             ByVal Forename As String,
                             ByVal Surname As String,
                             ByVal DateOfBirth As Date,
                             ByVal NHSNo As String,
                             ByVal Address1 As String,
                             ByVal Address2 As String,
                             ByVal Town As String,
                             ByVal County As String,
                             ByVal PostCode As String,
                             ByVal PhoneNo As String,
                             ByVal Gender As String,
                             ByVal EthnicOrigin As String,
                             ByVal District As String,
                             ByVal GPGMCCode As String,
                             ByVal GPPracticeCode As String,
                             ByVal DateOfDeath As Nullable(Of Date),
                             ByVal Hospitals As Nullable(Of Integer),
                             ByVal UniqueHospitalId As Nullable(Of Integer),
                             ByVal MaritalStatus As String,
                             ByVal SearchedNHSNo As String,
                             ByVal intTrustId As Nullable(Of Integer)) As Integer

        Dim affectedPatientId As Integer


        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("stp_InsertUpdatePatientFromSPINEAPI", connection)
            cmd.CommandType = CommandType.StoredProcedure

            If PatientId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))
            Else
                cmd.Parameters.Add(New SqlParameter("@PatientId", SqlTypes.SqlInt32.Null))
            End If
            If String.IsNullOrEmpty(CaseNoteNo) Then
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@CaseNoteNo", CaseNoteNo))
            End If

            If String.IsNullOrEmpty(Title) Then
                cmd.Parameters.Add(New SqlParameter("@Title", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@Title", Title))
            End If

            If String.IsNullOrEmpty(Forename) Then
                cmd.Parameters.Add(New SqlParameter("@Forename", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@Forename", Forename))
            End If

            If String.IsNullOrEmpty(Surname) Then
                cmd.Parameters.Add(New SqlParameter("@Surname", SqlTypes.SqlString.Null))
            Else
                cmd.Parameters.Add(New SqlParameter("@Surname", Surname))
            End If


            cmd.Parameters.Add(New SqlParameter("@DateOfBirth", DateOfBirth))

            If Not String.IsNullOrEmpty(NHSNo) Then
                cmd.Parameters.Add(New SqlParameter("@NHSNo", NHSNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@NHSNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address1) Then
                cmd.Parameters.Add(New SqlParameter("@Address1", Address1))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address1", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Address2) Then
                cmd.Parameters.Add(New SqlParameter("@Address2", Address2))
            Else
                cmd.Parameters.Add(New SqlParameter("@Address2", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Town) Then
                cmd.Parameters.Add(New SqlParameter("@Town", Town))
            Else
                cmd.Parameters.Add(New SqlParameter("@Town", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(County) Then
                cmd.Parameters.Add(New SqlParameter("@County", County))
            Else
                cmd.Parameters.Add(New SqlParameter("@County", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PostCode) Then
                cmd.Parameters.Add(New SqlParameter("@PostCode", PostCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@PostCode", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(PhoneNo) Then
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", PhoneNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@PhoneNo", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(Gender) Then
                cmd.Parameters.Add(New SqlParameter("@Gender", Gender))
            Else
                cmd.Parameters.Add(New SqlParameter("@Gender", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(EthnicOrigin) Then
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", EthnicOrigin))
            Else
                cmd.Parameters.Add(New SqlParameter("@EthnicOrigin", SqlTypes.SqlString.Null))
            End If
            If Not String.IsNullOrEmpty(MaritalStatus) Then
                cmd.Parameters.Add(New SqlParameter("@MaritalStatus", MaritalStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@MaritalStatus", SqlTypes.SqlString.Null))
            End If


            If Not String.IsNullOrEmpty(District) Then
                cmd.Parameters.Add(New SqlParameter("@District", District))
            Else
                cmd.Parameters.Add(New SqlParameter("@District", SqlTypes.SqlString.Null))
            End If

            If Not String.IsNullOrEmpty(GPGMCCode) Then
                cmd.Parameters.Add(New SqlParameter("@GPGMCCode", GPGMCCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPGMCCode", SqlTypes.SqlInt32.Null))
            End If
            If Not String.IsNullOrEmpty(GPPracticeCode) Then
                cmd.Parameters.Add(New SqlParameter("@GPPracticeCode", GPPracticeCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@GPPracticeCode", SqlTypes.SqlInt32.Null))
            End If
            If DateOfDeath.HasValue Then
                If Date.MinValue = DateOfDeath Then
                    cmd.Parameters.Add(New SqlParameter("@DateOfDeath", SqlTypes.SqlDateTime.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@DateOfDeath", DateOfDeath))
                End If
            Else
                cmd.Parameters.Add(New SqlParameter("@DateOfDeath", SqlTypes.SqlDateTime.Null))
            End If



            If Hospitals.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Hospitals", Hospitals))
            Else
                cmd.Parameters.Add(New SqlParameter("@Hospitals", SqlTypes.SqlInt32.Null))
            End If


            If UniqueHospitalId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", UniqueHospitalId))
            Else
                cmd.Parameters.Add(New SqlParameter("@UniqueHospitalId", SqlTypes.SqlInt32.Null))
            End If


            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            If Not String.IsNullOrEmpty(SearchedNHSNo) Then
                cmd.Parameters.Add(New SqlParameter("@SearchedNHSNo", SearchedNHSNo))
            Else
                cmd.Parameters.Add(New SqlParameter("@SearchedNHSNo", SqlTypes.SqlString.Null))
            End If

            If intTrustId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@TrustId", intTrustId))
            Else
                cmd.Parameters.Add(New SqlParameter("@TrustId", SqlTypes.SqlInt32.Null))
            End If


            connection.Open()
            affectedPatientId = CInt(cmd.ExecuteScalar())
        End Using

        Return affectedPatientId
    End Function

    Public Sub updateProcedureSummary(procedureId As Integer)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_summary_update", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

                cmd.Connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function getFITNotKnownValues() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("fit_not_known_reasons_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function


    Public Function getProcedureFitResult(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("procedure_fit_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Sub saveProcedureFIT(FITValue As String, FITNotKnownId As Integer, procedureId As Integer, selected As Boolean)
        Try

            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("procedure_fit_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@FITValue", FITValue))
                cmd.Parameters.Add(New SqlParameter("@FITNotKnownId", FITNotKnownId))
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@Selected", selected))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub saveRepeatProcedure(procedureId As Integer, selectedAnswer As Boolean, repeatUnknownValue As Integer, otherTextValue As String)
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim cmd As New SqlCommand("repeat_procedure_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                cmd.Parameters.Add(New SqlParameter("@SelectedAnswer", selectedAnswer))
                cmd.Parameters.Add(New SqlParameter("@RepeatUnknownId", repeatUnknownValue))
                cmd.Parameters.Add(New SqlParameter("@OtherTextValue", otherTextValue))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                cmd.ExecuteNonQuery()
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Function GetProductId(ByVal ProcedureTypeId As String) As String
        Dim value As Object
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT ProductTypeId  FROM ERS_ProcedureTypes WHERE ProcedureTypeId = @ProcedureTypeId and Suppressed = 0"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", ProcedureTypeId))
            connection.Open()
            value = mycmd.ExecuteScalar()
            If Not IsDBNull(value) Then Return CStr(value)
        End Using
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SuppressSectionList(ByVal SectionId As Integer, ByVal SuppressItem As Boolean) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = UpdateSectionList(SectionId, "", 0, SuppressItem)
            End Using
            Return 1
        Catch ex As Exception
            Return 0
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateSectionList(ByVal SectionId As Integer, ByVal SectionName As String, ByVal Order As Nullable(Of Integer), Suppressed As Nullable(Of Boolean)) As Integer
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim value As Object
                Dim cmd As New SqlCommand("Add_Or_Update_New_Section_Item", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SectionId", SectionId))
                cmd.Parameters.Add(New SqlParameter("@SectionName", SectionName))
                cmd.Parameters.Add(New SqlParameter("@Order", Order))
                cmd.Parameters.Add(New SqlParameter("@IsSuppressed", Suppressed))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

                connection.Open()
                value = cmd.ExecuteNonQuery()
                If Not IsDBNull(value) Then Return CInt(value)
                Return 0
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function

    Public Function UpdateNurseModuleSectionList(ByVal SectionId As Integer, ByVal SectionName As String, ByVal ProcedureType As Nullable(Of Integer), ByVal Order As Nullable(Of Integer), Suppressed As Nullable(Of Boolean)) As Integer
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim value As Object
                Dim cmd As New SqlCommand("Add_Or_Update_Nurse_Section_Item", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SectionId", SectionId))
                cmd.Parameters.Add(New SqlParameter("@SectionName", SectionName))
                If Order Is Nothing Then
                    cmd.Parameters.Add(New SqlParameter("@order", vbNull))
                Else
                    cmd.Parameters.Add(New SqlParameter("@order", Order))
                End If
                cmd.Parameters.Add(New SqlParameter("@IsSuppressed", Suppressed))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                If ProcedureType Is Nothing Then
                    cmd.Parameters.Add(New SqlParameter("@ProcedureType", vbNull))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ProcedureType", ProcedureType))
                End If

                connection.Open()
                value = cmd.ExecuteNonQuery()
                If Not IsDBNull(value) Then Return CInt(value)
                Return 0
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SuppressNurseModuleSectionList(ByVal SectionId As Integer, ByVal SuppressItem As Boolean) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = UpdateNurseModuleSectionList(SectionId, "", Nothing, Nothing, SuppressItem)
            End Using
            Return 1
        Catch ex As Exception
            Return 0
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertNurseModuleSectionsItem(ByVal sectionId As Integer, ByVal ProcedureType As Nullable(Of Integer), ByVal sectionName As String, ByVal order As Nullable(Of Integer)) As Integer

        If Trim(sectionName) = "" Then Return 0

        Using connection As New SqlConnection(ConnectionStr)
            Dim value As Object
            Dim cmd As New SqlCommand("Add_Or_Update_Nurse_Section_Item", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@sectionId", sectionId))
            cmd.Parameters.Add(New SqlParameter("@sectionName", sectionName))
            If order Is Nothing Then
                cmd.Parameters.Add(New SqlParameter("@order", vbNull))
            Else
                cmd.Parameters.Add(New SqlParameter("@order", order))
            End If
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", ProcedureType))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            value = cmd.ExecuteNonQuery()
            If Not IsDBNull(value) Then Return CInt(value)
            Return 0
        End Using
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SuppressNurseModuleQuestionList(ByVal QuestionId As Integer, ByVal SuppressItem As Boolean, ByVal M As Nullable(Of Boolean), ByVal F As Nullable(Of Boolean), ByVal Y As Nullable(Of Boolean), ByVal SortOrder As Nullable(Of Integer)) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = UpdateNurseModuleQuestionList(QuestionId, 0, vbNullString, vbNullString, vbNullString, vbNullString, vbNullString, vbNullString, SuppressItem, SortOrder)
            End Using
            Return 1
        Catch ex As Exception
            Return 0
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateNurseModuleQuestionList(ByVal QuestionId As Integer, ByVal SectionId As Nullable(Of Integer), ByVal Question As String, ByVal Mandatory As Nullable(Of Boolean), ByVal FreeText As Nullable(Of Boolean), ByVal YesNo As Nullable(Of Boolean), ByVal DropdownOption As Nullable(Of Boolean), ByVal DropdownOptionText As String, ByVal Suppressed As Nullable(Of Boolean), ByVal SortOrder As Nullable(Of Integer)) As Integer
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim value As Object
                Dim cmd As New SqlCommand("Add_Or_Update_Nurse_Question_Item", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@QuestionId", QuestionId))
                cmd.Parameters.Add(New SqlParameter("@SectionId", SectionId))
                cmd.Parameters.Add(New SqlParameter("@Question", Question))
                cmd.Parameters.Add(New SqlParameter("@Mandatory", Mandatory))
                cmd.Parameters.Add(New SqlParameter("@FreeText", FreeText))
                cmd.Parameters.Add(New SqlParameter("@YesNo", YesNo))
                cmd.Parameters.Add(New SqlParameter("@DropdownOption", DropdownOption))
                cmd.Parameters.Add(New SqlParameter("@DropdownOptionText", DropdownOptionText))
                cmd.Parameters.Add(New SqlParameter("@IsSuppressed", Suppressed))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@TrustId", 3))
                cmd.Parameters.Add(New SqlParameter("@SortOrder", SortOrder))
                connection.Open()
                value = cmd.ExecuteScalar()
                If Not IsDBNull(value) Then Return CInt(value)
                Return 0
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertNurseModuleQuestionItem(ByVal SectionId As Integer, ByVal Question As String, ByVal Mandatory As Boolean, ByVal FreeText As Boolean, ByVal YesNo As Boolean, ByVal DropdownOption As Boolean, ByVal DropdownOptionText As String, ByVal Suppressed As Boolean, ByVal SortOrder As Nullable(Of Integer)) As Integer


        Using connection As New SqlConnection(ConnectionStr)
            Dim value As Object
            Dim cmd As New SqlCommand("Add_Or_Update_Nurse_Question_Item", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SectionId", SectionId))
            cmd.Parameters.Add(New SqlParameter("@Question", Question))
            cmd.Parameters.Add(New SqlParameter("@QuestionId", 0))
            cmd.Parameters.Add(New SqlParameter("@Mandatory", Mandatory))
            cmd.Parameters.Add(New SqlParameter("@FreeText", FreeText))
            cmd.Parameters.Add(New SqlParameter("@YesNo", YesNo))
            cmd.Parameters.Add(New SqlParameter("@DropdownOption", DropdownOption))
            cmd.Parameters.Add(New SqlParameter("@DropdownOptionText", DropdownOptionText))
            cmd.Parameters.Add(New SqlParameter("@IsSuppressed", Suppressed))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@TrustId", 3))
            cmd.Parameters.Add(New SqlParameter("@SortOrder", SortOrder))
            connection.Open()
            value = cmd.ExecuteScalar()
            If Not IsDBNull(value) Then Return CInt(value)
            Return 0
        End Using
    End Function
    Public Function getEditHistoryList(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_ProcedureEditHistory", connection)
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandTimeout = 180 'MH added on 20 Jan 2022 TFS 1857
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetAbnormalityDetails(siteId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM dbo.fnRestOfColon(@SiteId)", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertSectionsItem(ByVal sectionName As String, ByVal order As String) As Integer

        If Trim(sectionName) = "" Then Return 0

        Using connection As New SqlConnection(ConnectionStr)
            Dim value As Object
            Dim cmd As New SqlCommand("Add_Or_Update_New_Section_Item", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SectionId", 0))
            cmd.Parameters.Add(New SqlParameter("@sectionName", sectionName))
            cmd.Parameters.Add(New SqlParameter("@order", order))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            connection.Open()
            value = cmd.ExecuteNonQuery()
            If Not IsDBNull(value) Then Return CInt(value)
            Return 0
        End Using
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SuppressQuestionList(ByVal QuestionId As Integer, ByVal SuppressItem As Boolean, ByVal M As Nullable(Of Boolean), ByVal F As Nullable(Of Boolean), ByVal Y As Nullable(Of Boolean), ByVal SortOrder As Nullable(Of Integer)) As Integer
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim result = UpdateQuestionList(QuestionId, 0, "", vbNullString, vbNullString, vbNullString, vbNullString, vbNullString, SuppressItem, 0)
            End Using
            Return 1
        Catch ex As Exception
            Return 0
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function UpdateQuestionList(ByVal QuestionId As Integer, ByVal SectionId As Nullable(Of Integer), ByVal Question As String, ByVal Mandatory As Nullable(Of Boolean), ByVal FreeText As Nullable(Of Boolean), ByVal YesNo As Nullable(Of Boolean), ByVal DropdownOption As Nullable(Of Boolean), ByVal DropdownOptionText As String, ByVal Suppressed As Nullable(Of Boolean), ByVal SortOrder As Nullable(Of Integer)) As Integer
        Try
            Using connection As New SqlConnection(ConnectionStr)
                Dim value As Object
                Dim cmd As New SqlCommand("Add_Or_Update_New_Question_Item", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@QuestionId", QuestionId))
                cmd.Parameters.Add(New SqlParameter("@SectionId", SectionId))
                cmd.Parameters.Add(New SqlParameter("@Question", Question))
                cmd.Parameters.Add(New SqlParameter("@Optional", Mandatory))
                cmd.Parameters.Add(New SqlParameter("@FreeText", FreeText))
                cmd.Parameters.Add(New SqlParameter("@YesNo", YesNo))
                cmd.Parameters.Add(New SqlParameter("@DropdownOption", DropdownOption))
                cmd.Parameters.Add(New SqlParameter("@DropdownOptionText", DropdownOptionText))
                cmd.Parameters.Add(New SqlParameter("@IsSuppressed", Suppressed))
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                cmd.Parameters.Add(New SqlParameter("@TrustId", 3))
                cmd.Parameters.Add(New SqlParameter("@SortOrder", SortOrder))
                connection.Open()
                value = cmd.ExecuteScalar()
                If Not IsDBNull(value) Then Return CInt(value)
                Return 0
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function InsertQuestionItem(ByVal SectionId As Integer, ByVal Question As String, ByVal Mandatory As Boolean, ByVal FreeText As Boolean, ByVal YesNo As Boolean, ByVal DropdownOption As Boolean, ByVal DropdownOptionText As String, ByVal Suppressed As Boolean, ByVal SortOrder As Nullable(Of Integer)) As Integer


        Using connection As New SqlConnection(ConnectionStr)
            Dim value As Object
            Dim cmd As New SqlCommand("Add_Or_Update_New_Question_Item", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@SectionId", SectionId))
            cmd.Parameters.Add(New SqlParameter("@QuestionId", 0))
            cmd.Parameters.Add(New SqlParameter("@Question", Question))
            cmd.Parameters.Add(New SqlParameter("@Optional", Mandatory))
            cmd.Parameters.Add(New SqlParameter("@FreeText", FreeText))
            cmd.Parameters.Add(New SqlParameter("@YesNo", YesNo))
            cmd.Parameters.Add(New SqlParameter("@DropdownOption", DropdownOption))
            cmd.Parameters.Add(New SqlParameter("@DropdownOptionText", DropdownOptionText))
            cmd.Parameters.Add(New SqlParameter("@IsSuppressed", Suppressed))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@TrustId", 3))
            cmd.Parameters.Add(New SqlParameter("@SortOrder", SortOrder))
            connection.Open()
            value = cmd.ExecuteScalar()
            If Not IsDBNull(value) Then Return CInt(value)
            Return 0
        End Using
    End Function

    Public Function getAccessForEditCreate() As Integer  ' added by Ferdowsi TFS 4199
        Dim iAccessLevel = 0
        If (patientview.canEdit = 9) Then

            iAccessLevel = GetPageAccessLevel(CInt(Session("PKUserId")), "Edit Procedure")
        End If
        If (patientview.canCreate = 9) Then
            iAccessLevel = GetPageAccessLevel(CInt(Session("PKUserId")), "create_procedure")

        End If
        Return iAccessLevel

    End Function

    Public Function GetRepeatUnknownValues() As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("repeat_unknown_reasons_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetRepeatProcedureResult(procedureId As Integer) As DataTable
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("repeat_procedure_select", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            If dsData.Tables.Count > 0 Then
                Return dsData.Tables(0)
            End If
            Return Nothing
        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Public Function GetTransnasalAccessMethodThoracicList() As DataTable
        Return ExecuteSP("get_Transnasal_AccessMethodThoracic_List", New SqlParameter() {
                         New SqlParameter With {.ParameterName = "@ListDescription", .SqlDbType = SqlDbType.VarChar, .Value = "AccessMethod Thoracic"},
                         New SqlParameter With {.ParameterName = "@LoggedInUserId", .SqlDbType = SqlDbType.Int, .Value = LoggedInUserId},
                         New SqlParameter With {.ParameterName = "@OrderByDesc", .SqlDbType = SqlDbType.Bit, .Value = BoolToBit(False)}
                         })
    End Function
End Class

