Imports System.Data.SqlClient

Public Class LetterGeneration

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetLetterQueueList(Optional startDate As Date? = Nothing, Optional endDate As Date? = Nothing, Optional viewAll As Integer = 0, Optional hospitalIds As String = "0", Optional AppointmentStatusId As Integer? = Nothing, Optional HospitalNumber As String = Nothing) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("letGetQueueList", connection)
            cmd.CommandType = CommandType.StoredProcedure
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
            cmd.Parameters.Add(New SqlParameter("@IncludePrinted", viewAll))
            If Not HospitalNumber = "" Then
                cmd.Parameters.Add(New SqlParameter("@HospitalNumber", HospitalNumber))
            Else
                cmd.Parameters.Add(New SqlParameter("@HospitalNumber", DBNull.Value))
            End If

            cmd.Parameters.Add(New SqlParameter("@HospitalIds", hospitalIds))
            cmd.Parameters.Add(New SqlParameter("@AppointmentStatusId", AppointmentStatusId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetLetterQueueIdForAppointmentId(AppointmentId As Integer) As Integer
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("letGetLetterQueueIdForAppointmentId", connection) With {
                .CommandType = CommandType.StoredProcedure
            }
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", AppointmentId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Dim LetterQueueId = CInt(dsResult.Tables(0).Rows(0)("LetterQueueId").ToString())
            Return LetterQueueId
        End If
        Return 0
    End Function

    Public Function GetLetterQueueForLetterQueueId(LetterQueueId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("letGetLetterForLetterQueueId", connection) With {
                .CommandType = CommandType.StoredProcedure
            }
            cmd.Parameters.Add(New SqlParameter("@LetterQueueId", LetterQueueId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetLetterType(Optional OperationalHospitalId As Integer? = 0) As DataTable
        Dim sSQL = "SELECT * FROM [ERS_LetterType] WHERE [IsActive] = 1 "



        If Not (OperationalHospitalId = 0) Then
            sSQL = sSQL + " and OperationalHospitalId=@OperationalHospitalId"
        End If
        sSQL = sSQL + " ORDER BY [LetterName] ASC"

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            If Not (OperationalHospitalId = 0) Then

                cmd.Parameters.Add(New SqlParameter("@OperationalHospitalId", OperationalHospitalId))
            End If
            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function GetAppointmentStatusForPrinting() As DataTable
        Dim sSQL = "SELECT  AppointmentStatusId=UniqueId,LetterName=DescriptionForLetter FROM [ERS_AppointmentStatus] WHERE [RequiredLetter] = 1 "

        sSQL = sSQL + " ORDER BY [LetterName] ASC"

        Dim dsResult As New DataSet

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
    End Function

    Public Function GetLetterTypeWithoutTemplate(OperationalHospitalId As Integer) As DataTable
        Dim sSQL = "SELECT DescriptionForLetter LetterName, UniqueId FROM ERS_AppointmentStatus where RequiredLetter=1 and UniqueId not in( select AppointmentStatusId from  ERS_LetterType where OperationalHospitalId =@OperationalHospitalId) ORDER BY [DescriptionForLetter] ASC"

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            cmd.Parameters.Add(New SqlParameter("@OperationalHospitalId", OperationalHospitalId))
            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOperatingHospitals(TrustId As Integer) As DataTable
        Dim sSQL = "SELECT * FROM [ERS_OperatingHospitals] where  TrustId = " + TrustId.ToString() + "ORDER BY HospitalName ASC"

        Dim dsResult As New DataSet

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
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedures() As DataTable
        Dim sSQL = "SELECT [ProcedureTypeId],[ProcedureType] FROM [ERS_ProcedureTypes] p Where  p.SchedulerProc = 1 AND ISNULL(IsGI,1)=1 And (SchedulerDiagnostic = 1 Or SchedulerTherapeutic = 1)ORDER BY [ProcedureType] ASC"

        Dim dsResult As New DataSet

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
    End Function

    Public Function GetMailmergeData(patientId As Integer) As DataTable
        'Dim sSQL = "SELECT  [PatientId] ,[Surname] ,FirstName=[Forename1],LastName=[Forename2],[Title] ,[Address1],[Address2] ,[Address3],[Address4],[Postcode],[HospitalNumber] ,[NHSNo]"
        'sSQL = sSQL + " From [SE_Demo].[dbo].[ERS_Patients] where PatientId =@patientId"

        'Dim dsResult As New DataSet

        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand(sSQL, connection)
        '    cmd.CommandType = CommandType.Text
        '    cmd.Parameters.Add(New SqlParameter("@patientId", patientId))
        '    Dim adapter = New SqlDataAdapter(cmd)

        '    connection.Open()
        '    adapter.Fill(dsResult)
        'End Using

        'If dsResult.Tables.Count > 0 Then
        '    Return dsResult.Tables(0)
        'End If
        'Return Nothing

        Dim da As New DataAccess()
        Try
            Return da.ExecuteSP("get_MailMergeData", New SqlParameter() {New SqlParameter("@patientId", patientId)})
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred on GetMailmergeData.", ex)
            Return Nothing
        End Try

    End Function

    Public Function GetMailmergeDataByletterQueueId(letterQueueId As Integer) As DataTable
        Dim da As New DataAccess()
        Try
            Return da.ExecuteSP("get_MailmergeDataByletterQueueId", New SqlParameter() {New SqlParameter("@letterQueueId", letterQueueId)})
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred on GetMailmergeDataByletterQueueId.", ex)
            Return Nothing
        End Try
    End Function

    Public Function GetTemapletDataForTemplateId(templateId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("letGetTemplateData", connection) With {
                .CommandType = CommandType.StoredProcedure
            }
            cmd.Parameters.Add(New SqlParameter("@templateId", templateId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetAdditionalDocumentDataForId(AdditionalDocumentId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("letGetAdditionalDocumentData", connection) With {
                .CommandType = CommandType.StoredProcedure
            }
            cmd.Parameters.Add(New SqlParameter("@AdditionalDocumentId", AdditionalDocumentId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function GetTemplateIdForAppontmentStatusId(AppointmentStatusId As Integer, OperationalHospitalId As Integer) As Integer
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("letGetTemplateIdForAppointmentStatusAndHospital", connection) With {
                .CommandType = CommandType.StoredProcedure
            }
            cmd.Parameters.Add(New SqlParameter("@AppointmentStatusId", AppointmentStatusId))
            cmd.Parameters.Add(New SqlParameter("@OperationalHospitalId", OperationalHospitalId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()

            Dim rObj As Object = cmd.ExecuteScalar()
            If IsDBNull(rObj) Then
                Return 0
            Else
                Return Convert.ToDecimal(rObj)
            End If

        End Using

        Return Nothing
    End Function

    Public Function UpdateTemplate(TemplateId As Integer, LetterContent() As Byte)
        Dim sSQL = "Update [ERS_LetterType] set  [LetterContent] =@LetterContent  where  [LetterTypeId] =@TemplateId"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@LetterContent", LetterContent))
            cmd.Parameters.Add(New SqlParameter("@TemplateId", TemplateId))

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using

    End Function

    Public Function InsertTemplate(AppointmentStatusId As Integer, LetterName As String, LetterContent() As Byte, OperationalHospitalId As Integer)
        Dim sSQL = "insert into [ERS_LetterType]([LetterContent],[LetterName],[AppointmentStatusId],OperationalHospitalId ) values(@LetterContent , @LetterName ,@AppointmentStatusId ,@OperationalHospitalId)"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@LetterContent", LetterContent))
            cmd.Parameters.Add(New SqlParameter("@LetterName", LetterName))
            cmd.Parameters.Add(New SqlParameter("@AppointmentStatusId", AppointmentStatusId))
            cmd.Parameters.Add(New SqlParameter("@OperationalHospitalId", OperationalHospitalId))

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using

    End Function

    Public Sub UpdateLetterQueueEdited(LetterQueueId As Integer, Optional EditLetterReasonId As Integer? = 0, Optional EditLetterReasonExtraInfo As String = Nothing, Optional PrintOnly As Boolean = False)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("letLetterEdited", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@LetterQueueId", LetterQueueId))
            cmd.Parameters.Add(New SqlParameter("@UserId", CInt(HttpContext.Current.Session("PKUserID"))))
            cmd.Parameters.Add(New SqlParameter("@PrintOnly", If(PrintOnly, 1, 0)))
            cmd.Parameters.Add(New SqlParameter("@EditLetterReasonId", EditLetterReasonId))
            cmd.Parameters.Add(New SqlParameter("@EditLetterReasonExtraInfo", If(EditLetterReasonExtraInfo, DBNull.Value)))
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Function InsertAdditionalInfoDocument(procedureTypeId As Integer, procedureType As String, documentContent() As Byte, DocumentName As String, OperationalHospitaId As Integer, TherapeuticTypeId As Integer, TherapeuticName As String, CombindProcedureTypeId As Integer, CombindProcedureTypeName As String)
        Dim sSQL = "insert into ERS_LetterAdditionalDocument ([DocumentContent],[ProcedureType],[ProcedureTypeId],OperationalHospitalId,DocumentName,TherapeuticTypeId,TherapeuticName,CombindProcedureTypeId,CombindProcedureTypeName ) values(@documentContent , @procedureType ,@procedureTypeId,@OperationalHospitalId,@DocumentName,@TherapeuticTypeId,@TherapeuticName,@CombindProcedureTypeId,@CombindProcedureTypeName )"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@documentContent", documentContent))
            cmd.Parameters.Add(New SqlParameter("@procedureType", procedureType))
            cmd.Parameters.Add(New SqlParameter("@procedureTypeId", procedureTypeId))
            cmd.Parameters.Add(New SqlParameter("@OperationalHospitalId", OperationalHospitaId))
            cmd.Parameters.Add(New SqlParameter("@DocumentName", DocumentName))
            cmd.Parameters.Add(New SqlParameter("@TherapeuticTypeId", TherapeuticTypeId))
            cmd.Parameters.Add(New SqlParameter("@TherapeuticName", TherapeuticName))
            cmd.Parameters.Add(New SqlParameter("@CombindProcedureTypeId", CombindProcedureTypeId))
            cmd.Parameters.Add(New SqlParameter("@CombindProcedureTypeName", CombindProcedureTypeName))

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Function
    Public Function UpdateAdditionalInfoDocument(AdditionalDocumentId As Integer, procedureTypeId As Integer, procedureType As String, documentContent() As Byte, DocumentName As String, OperationalHospitaId As Integer, TherapeuticTypeId As Integer, TherapeuticName As String, CombindProcedureTypeId As Integer, CombindProcedureTypeName As String)
        Dim sSQL = "update ERS_LetterAdditionalDocument Set [DocumentContent]=@documentContent,[ProcedureType]=@procedureType,[ProcedureTypeId]=@procedureTypeId,OperationalHospitalId=@OperationalHospitalId,DocumentName=@DocumentName,TherapeuticTypeId=@TherapeuticTypeId,TherapeuticName=@TherapeuticName ,CombindProcedureTypeId=@CombindProcedureTypeId,CombindProcedureTypeName=@CombindProcedureTypeName where AdditionalDocumentId=@AdditionalDocumentId"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@AdditionalDocumentId", AdditionalDocumentId))
            cmd.Parameters.Add(New SqlParameter("@documentContent", documentContent))
            cmd.Parameters.Add(New SqlParameter("@procedureType", procedureType))
            cmd.Parameters.Add(New SqlParameter("@procedureTypeId", procedureTypeId))
            cmd.Parameters.Add(New SqlParameter("@OperationalHospitalId", OperationalHospitaId))
            cmd.Parameters.Add(New SqlParameter("@DocumentName", DocumentName))
            cmd.Parameters.Add(New SqlParameter("@TherapeuticTypeId", TherapeuticTypeId))
            cmd.Parameters.Add(New SqlParameter("@TherapeuticName", TherapeuticName))
            cmd.Parameters.Add(New SqlParameter("@CombindProcedureTypeId", CombindProcedureTypeId))
            cmd.Parameters.Add(New SqlParameter("@CombindProcedureTypeName", CombindProcedureTypeName))

            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAdditionalDocumentList(Optional OperationalHospitalId As Integer? = Nothing) As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sSQL = "Select ad.* ,oh.Hospitalname, MimeIcon='~/images/MimeIcon/pdf-16.png' , ProcedureType + case  when isnull(CombindProcedureTypeName,'') = '' then '' else ' + ' +  CombindProcedureTypeName end as ProcedureName from ERS_LetterAdditionalDocument ad, ERS_OperatingHospitals oh where ad.OperationalHospitalId=oh.OperatingHospitalId "

            If Not (OperationalHospitalId = 0) Then
                sSQL = sSQL + " and ad.OperationalHospitalId=@OperationalHospitalId"
            End If
            sSQL = sSQL + " order by oh.hospitalname, ad.ProcedureType"
            Dim cmd As New SqlCommand(sSQL, connection)

            If Not (OperationalHospitalId = 0) Then

                cmd.Parameters.Add(New SqlParameter("@OperationalHospitalId", OperationalHospitalId))
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
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAdditionalDocumentFoId(AdditionalDocumentId As Integer) As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sSQL = "select ad.*  from ERS_LetterAdditionalDocument ad where ad.AdditionalDocumentId=@AdditionalDocumentId "

            Dim cmd As New SqlCommand(sSQL, connection)


            cmd.Parameters.Add(New SqlParameter("@AdditionalDocumentId", AdditionalDocumentId))

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
    Public Function GetLetterTemplateList(Optional OperationalHospitalId As Integer? = 0) As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sSQL = "select lt.* ,oh.Hospitalname, MimeIcon='~/images/MimeIcon/writer-16.png' from [ERS_LetterType]  lt, ERS_OperatingHospitals oh where lt.[IsActive]=1 and lt.OperationalHospitalId=oh.OperatingHospitalId "

            If Not (OperationalHospitalId = 0) Then
                sSQL = sSQL + " and lt.OperationalHospitalId=@OperationalHospitalId"
            End If
            sSQL = sSQL + " order by oh.hospitalname, lt.LetterName"
            Dim cmd As New SqlCommand(sSQL, connection)

            If Not (OperationalHospitalId = 0) Then

                cmd.Parameters.Add(New SqlParameter("@OperationalHospitalId", OperationalHospitalId))
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
    Public Function GetProcedureForAnAppointment(appointmentId As Integer) As DataTable
        Dim sSQL = "select  ProcedureTypeID  FROM ERS_AppointmentProcedureTypes where AppointmentID=@appointmentId"
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sSQL, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@appointmentId", appointmentId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function GetAdditionalDocumentForAppointment(appointmentId As Integer, OperationalHospitalId As Integer) As DataTable

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("GetAdditionalDocumentForLetterPrinting", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@appointmentId", appointmentId))
            cmd.Parameters.Add(New SqlParameter("@OperationalHospitalId", OperationalHospitalId))
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
    Public Function GetLetterEditReasons() As DataTable
        Dim ds As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_letter_edit_reasons_select", connection)
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
    Public Function InsertLetterEditReason(Reason As String, WhoCreatedId As Integer)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_letter_edit_reasons_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", WhoCreatedId))
            cmd.Parameters.Add(New SqlParameter("@Reason", Reason))
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
        Return Nothing
    End Function
    Public Function UpdateLetterEditReason(LetterEditReasonId As Integer, Reason As String, WhoUpdatedId As Integer)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_letter_edit_reasons_update", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@LetterEditReasonId", LetterEditReasonId))
            cmd.Parameters.Add(New SqlParameter("@Reason", Reason))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", WhoUpdatedId))
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
        Return Nothing
    End Function
    Public Function UpdateLetterEditReasonStatus(LetterEditReasonId As Integer, suppressed As Boolean, WhoUpdatedId As Integer)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_letter_edit_reasons_suppress", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@LetterEditReasonId", LetterEditReasonId))
            cmd.Parameters.Add(New SqlParameter("@Suppressed", suppressed))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", WhoUpdatedId))
            connection.Open()
            cmd.ExecuteNonQuery()
        End Using
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetLetterEditReasonsActiveOnly() As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("sch_active_letter_edit_reasons_select", connection)
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
End Class
