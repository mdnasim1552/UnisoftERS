Imports System.Data.Entity.Core.Objects
Imports System.Data.Entity.SqlServer
Imports System.Data.SqlClient
Imports DevExpress.CodeParser
Imports DevExpress.Data.Filtering.Helpers
Imports DevExpress.PivotGrid.OLAP
Imports Telerik.Web.UI
Public Class OrderCommsBL
    Private ReadOnly Property LoggedInUserId As Integer
        Get
            Return CInt(HttpContext.Current.Session("PKUserID"))
        End Get
    End Property
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetOrderCommsDetails(intOrderId As Integer) As DataSet
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("get_OrderCommsDetails", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@OrderId", .SqlDbType = SqlDbType.Int, .Value = intOrderId})

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using

        Return dsData

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetPreviousProcedureListByPatientId(intPatientId As Integer) As DataSet
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("spGetPreviousProcedureListByPatient", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PatientId", .SqlDbType = SqlDbType.Int, .Value = intPatientId})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            Return dsData
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : GetPreviousProcedureListByPatientId", ex)
        End Try

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function GetERS_OrderSourceDisplayColumn(ByVal OrderSourceListItemno As Integer) As String
        Dim dsData As New DataSet

        Try
            Dim strReturnString As String = ""

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("spGetERS_OrderSourceDisplayColumn", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@OrderSourceListItemno", OrderSourceListItemno))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
                If dsData.Tables(0).Rows.Count > 0 Then
                    For Each drD As DataRow In dsData.Tables(0).Rows
                        If Not IsDBNull(drD("DisplayColumnName")) Then
                            If strReturnString.Trim() = "" Then
                                strReturnString = drD("DisplayColumnName").ToString()
                            Else
                                strReturnString = strReturnString + "," + drD("DisplayColumnName").ToString()
                            End If
                        End If

                    Next
                End If

                dsData.Dispose()
                adapter.Dispose()
            End Using
            Return strReturnString

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function GetERS_OrderSourceDisplayColumn...", ex)
            Return Nothing
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAvailableOrderCommsByPatientId(intPatientId As Integer) As DataSet
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("get_AvailableOrderCommsByPatientId", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@PatientId", .SqlDbType = SqlDbType.Int, .Value = intPatientId})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            Return dsData
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : GetAvailableOrderCommsByPatientId", ex)
        End Try

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetProcedurePDFReportByProcedureId(intProcedureId As Integer, dtProcedureMaxDate As DateTime, strDocumentSource As String) As DataSet
        Try
            Dim dsData As New DataSet
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand("spGetProcedureDocumentPDFData", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureId", .SqlDbType = SqlDbType.Int, .Value = intProcedureId})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@ProcedureDate", .SqlDbType = SqlDbType.DateTime, .Value = dtProcedureMaxDate})
                cmd.Parameters.Add(New SqlParameter With {.ParameterName = "@DocumentSource", .SqlDbType = SqlDbType.VarChar, .Value = strDocumentSource})

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            Return dsData
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : GetProcedurePDFReportByProcedureId", ex)
        End Try

    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function AddOrUpdateOrderComms(ByVal OrderId As Nullable(Of Integer),
                                ByVal OperatingHospitalId As Int32,
                                ByVal DateReceived As Nullable(Of Date),
                                ByVal ProcedureType As Int32,
                                ByVal OrderDate As Nullable(Of Date),
                                ByVal PatientId As Integer,
                                ByVal PriorityId As Int32,
                                ByVal DueDate As Nullable(Of Date),
                                ByVal StatusId As Int32,
                                ByVal OrderNumber As String,
                                ByVal OrderSourceListItemNo As String,
                                ByVal OrderLocation As String,
                                ByVal ReferralConsultantID? As Integer,
                                ByVal ReferralHospitalID? As Integer,
                                ByVal ReferralConsultantSpeciality? As Integer,
                                ByVal OrderWard As String,
                                ByVal BedLocation As String,
                                ByVal ClinicalHistoryNotes As String,
                                ByVal TestSite As String,
                                ByVal RejectionReasonId As Nullable(Of Integer),
                                ByVal WhoRejected As String,
                                ByVal WhenRejected As Nullable(Of DateTime),
                                ByVal RejectionComments As String,
                                ByVal UserId As Integer) As Integer

        Dim affectedOrderId As Integer

        Try


            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("spInsertOrUpdateOrderComms", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add(New SqlParameter("@OrderId", SqlDbType.Int, 12, ParameterDirection.InputOutput))
                If OrderId.HasValue Then
                    cmd.Parameters("@OrderId").Value = OrderId
                Else
                    cmd.Parameters("@OrderId").Value = DBNull.Value
                End If

                cmd.Parameters.Add(New SqlParameter("@PatientId", PatientId))

                If OperatingHospitalId > 0 Then
                    cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
                Else
                    cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", SqlTypes.SqlInt32.Null))
                End If

                If ProcedureType > 0 Then
                    cmd.Parameters.Add(New SqlParameter("@ProcedureType", ProcedureType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ProcedureType", SqlTypes.SqlInt32.Null))
                End If

                If OrderDate.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@OrderDate", OrderDate))
                Else
                    cmd.Parameters.Add(New SqlParameter("@OrderDate", SqlTypes.SqlDateTime.Null))
                End If

                If DueDate.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@DueDate", DueDate))
                Else
                    cmd.Parameters.Add(New SqlParameter("@DueDate", SqlTypes.SqlDateTime.Null))
                End If

                If DateReceived.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@DateReceived", DateReceived))
                Else
                    cmd.Parameters.Add(New SqlParameter("@DateReceived", SqlTypes.SqlDateTime.Null))
                End If

                cmd.Parameters.Add(New SqlParameter("@StatusId", StatusId))


                If PriorityId > 0 Then
                    cmd.Parameters.Add(New SqlParameter("@OrdersPriorityId", PriorityId))
                Else
                    cmd.Parameters.Add(New SqlParameter("@OrdersPriorityId", SqlTypes.SqlInt32.Null))
                End If



                If String.IsNullOrEmpty(OrderNumber) Then
                    cmd.Parameters.Add(New SqlParameter("@OrderNumber", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@OrderNumber", OrderNumber))
                End If

                If String.IsNullOrEmpty(OrderSourceListItemNo) Then
                    cmd.Parameters.Add(New SqlParameter("@OrderSourceListItemNo", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@OrderSourceListItemNo", OrderSourceListItemNo))
                End If
                ''''
                If String.IsNullOrEmpty(OrderLocation) Then
                    cmd.Parameters.Add(New SqlParameter("@OrderLocation", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@OrderLocation", OrderLocation))
                End If


                If ReferralConsultantID.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@ReferralConsultantID", ReferralConsultantID))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ReferralConsultantID", SqlTypes.SqlInt32.Null))
                End If

                If ReferralHospitalID.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@ReferralHospitalID", ReferralHospitalID))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ReferralHospitalID", SqlTypes.SqlInt32.Null))
                End If

                If ReferralConsultantSpeciality.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@ReferralConsultantSpecialty", ReferralConsultantSpeciality))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ReferralConsultantSpecialty", SqlTypes.SqlInt32.Null))
                End If

                If String.IsNullOrEmpty(OrderWard) Then
                    cmd.Parameters.Add(New SqlParameter("@OrderWard", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@OrderWard", OrderWard))
                End If
                If String.IsNullOrEmpty(BedLocation) Then
                    cmd.Parameters.Add(New SqlParameter("@BedLocation", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BedLocation", BedLocation))
                End If
                If String.IsNullOrEmpty(ClinicalHistoryNotes) Then
                    cmd.Parameters.Add(New SqlParameter("@ClinicalHistoryNotes", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@ClinicalHistoryNotes", ClinicalHistoryNotes))
                End If
                If String.IsNullOrEmpty(TestSite) Then
                    cmd.Parameters.Add(New SqlParameter("@TestSite", SqlTypes.SqlString.Null))
                Else
                    cmd.Parameters.Add(New SqlParameter("@TestSite", TestSite))
                End If

                If RejectionReasonId.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@RejectionReasonId", RejectionReasonId))
                Else
                    cmd.Parameters.Add(New SqlParameter("@RejectionReasonId", SqlTypes.SqlInt32.Null))
                End If

                If Not String.IsNullOrEmpty(WhoRejected) Then
                    cmd.Parameters.Add(New SqlParameter("@WhoRejected", WhoRejected))
                Else
                    cmd.Parameters.Add(New SqlParameter("@WhoRejected", SqlTypes.SqlString.Null))
                End If

                If WhenRejected.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@WhenRejected", WhenRejected))
                Else
                    cmd.Parameters.Add(New SqlParameter("@WhenRejected", SqlTypes.SqlDateTime.Null))
                End If

                If Not String.IsNullOrEmpty(RejectionComments) Then
                    cmd.Parameters.Add(New SqlParameter("@RejectionComments", RejectionComments))
                Else
                    cmd.Parameters.Add(New SqlParameter("@RejectionComments", SqlTypes.SqlString.Null))
                End If

                cmd.Parameters.Add(New SqlParameter("@UserId", UserId))


                connection.Open()
                cmd.ExecuteScalar()

                affectedOrderId = cmd.Parameters("@OrderId").Value

                Return affectedOrderId

            End Using

            Return affectedOrderId
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : AddOrUpdateOrderComms()", ex)
            Return 0
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function MoveOrderCommsToWaitingList(ByRef strErrorMessage As String,
                                                ByVal OrderId As Integer,
                                                ByVal UserId As Integer) As Integer

        Dim intSuccess As Int32

        Try

            intSuccess = 0

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("spCreateWaitingListFromOrderComms", connection)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add("@Success", SqlDbType.Int, 12)
                cmd.Parameters("@Success").Direction = ParameterDirection.Output
                cmd.Parameters.Add("@ErrorMessage", SqlDbType.VarChar, 500)
                cmd.Parameters("@ErrorMessage").Direction = ParameterDirection.Output


                cmd.Parameters.Add(New SqlParameter("@OrderId", OrderId))


                cmd.Parameters.Add(New SqlParameter("@User", UserId))


                connection.Open()
                cmd.ExecuteScalar()

                intSuccess = cmd.Parameters("@Success").Value
                strErrorMessage = cmd.Parameters("@ErrorMessage").Value

                Return intSuccess

            End Using

            Return intSuccess
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : MoveOrderCommsToWaitingList()", ex)
            Return 0
        End Try
    End Function
#Region "Order Message related functions"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function GetOrderEventCodeDetailsByOrderEventId(ByVal OrderEventId As Integer) As DataSet
        Dim dsData As New DataSet

        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("usp_getOrderEventCodeDetailsByOrderEventId", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@OrderEventId", OrderEventId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            Return dsData
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function GetOrderEventCodeDetailsByOrderEventId", ex)
            Return Nothing
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function GetOrderMessageByOrderAndEventId(ByVal OrderId As Integer,
            ByVal OrderEventId As Integer) As DataSet
        Dim dsData As New DataSet

        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("usp_getOrderMessageByOrderAndEventId", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@OrderId", OrderId))
                cmd.Parameters.Add(New SqlParameter("@OrderEventId", OrderEventId))

                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using
            Return dsData
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function GetOrderMessageByOrderAndEventId", ex)
            Return Nothing
        End Try
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function GetOrderAppointmentMessageByAppointmentId(ByVal AppointmentId As Integer) As String
        Dim dsData As New DataSet
        Dim strOrderMessage As String = ""
        Dim strAppointmentMessage As String = ""
        Dim strProcMessage As String = ""
        Dim strTherapMessage As String = ""
        Dim strAppointmentStatus As String = ""



        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("usp_getAppointmentInfoForOrderMessage", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@AppointmentId", AppointmentId))
                Dim adapter = New SqlDataAdapter(cmd)
                connection.Open()
                adapter.Fill(dsData)
            End Using

            If Not IsNothing(dsData) Then

                'Table 0 - Appointment Datetime, Due Arrival datetime etc
                If dsData.Tables(0).Rows.Count > 0 Then
                    If Not IsDBNull(dsData.Tables(0).Rows(0)("StartDateTime")) Then
                        strAppointmentMessage = "Appointment Date time : " + CDate(dsData.Tables(0).Rows(0)("StartDateTime").ToString()).ToString("dd-MMM-yy HH:mm")
                    End If

                    If Not IsDBNull(dsData.Tables(0).Rows(0)("AppointmentStatus")) Then
                        strAppointmentStatus = "Appointment Status : " + dsData.Tables(0).Rows(0)("AppointmentStatus").ToString()
                    End If

                End If
                'Table 1 - Appointment procedure types
                If dsData.Tables(1).Rows.Count > 0 Then
                    For Each drD As DataRow In dsData.Tables(1).Rows
                        If Not IsDBNull(drD("SchedulerProcName")) Then
                            If strProcMessage.Trim() = "" Then
                                strProcMessage = drD("SchedulerProcName").ToString()
                            Else
                                strProcMessage = strProcMessage + "," + drD("SchedulerProcName").ToString()
                            End If
                        End If
                    Next
                End If

                'Table 2 - Appointment Therapeutic types
                If dsData.Tables(2).Rows.Count > 0 Then
                    For Each drD As DataRow In dsData.Tables(2).Rows
                        If Not IsDBNull(drD("TherapeuticsName")) Then
                            If strTherapMessage.Trim() = "" Then
                                strTherapMessage = drD("TherapeuticsName").ToString()
                            Else
                                strTherapMessage = strTherapMessage + "," + drD("TherapeuticsName").ToString()
                            End If
                        End If
                    Next
                End If

            End If

            If strProcMessage.Trim() <> "" Then
                strProcMessage = ", " + strProcMessage
            End If
            If strTherapMessage.Trim() <> "" Then
                strTherapMessage = ", " + strTherapMessage
            End If
            If strAppointmentStatus.Trim() <> "" Then
                strAppointmentStatus = ", " + strAppointmentStatus
            End If

            strOrderMessage = strAppointmentMessage + strProcMessage + strTherapMessage + strAppointmentStatus

            Return strOrderMessage
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function GetOrderMessageByOrderAndEventId", ex)
            Return Nothing
        End Try
    End Function
    Public Function CheckIfOrderEventIdMessageSendEnabled(ByVal OrderEventId As Integer) As Boolean
        Try
            Dim blnResult As Boolean = False
            Dim dtData As DataSet = New DataSet
            dtData = GetOrderEventCodeDetailsByOrderEventId(OrderEventId)
            If Not IsNothing(dtData) Then
                If dtData.Tables.Count > 0 Then
                    If dtData.Tables(0).Rows.Count > 0 Then
                        If Not IsDBNull(dtData.Tables(0).Rows(0)("IsActive")) Then
                            blnResult = Convert.ToBoolean(dtData.Tables(0).Rows(0)("IsActive"))
                        End If
                    End If
                End If
            End If
            Return blnResult
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function CheckIfOrderEventIdMessageSendEnabled", ex)
            Return Nothing
        End Try
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SendOrderMessageByOrderAndEventId(ByVal OrderId As Integer,
        ByVal OrderEventId As Integer,
        ByVal ProcedureId? As Integer,
        ByVal WaitingListId? As Integer,
        ByVal AppointmentId? As Integer,
        ByVal OrderMessage As String,
        ByVal OperatingHospitalId? As Integer,
        ByVal UserId As Integer) As Boolean
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("usp_InsertOrderMessageOrderAndEventId", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@OrderId", OrderId))
                cmd.Parameters.Add(New SqlParameter("@OrderEventId", OrderEventId))

                If ProcedureId.HasValue Then
                    If ProcedureId > 0 Then
                        cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@ProcedureId", DBNull.Value))
                    End If

                Else
                    cmd.Parameters.Add(New SqlParameter("@ProcedureId", DBNull.Value))
                End If

                If WaitingListId.HasValue Then
                    If WaitingListId > 0 Then
                        cmd.Parameters.Add(New SqlParameter("@WaitinglistId", WaitingListId))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@WaitinglistId", DBNull.Value))
                    End If

                Else
                    cmd.Parameters.Add(New SqlParameter("@WaitinglistId", DBNull.Value))
                End If

                If AppointmentId.HasValue Then
                    If AppointmentId > 0 Then
                        cmd.Parameters.Add(New SqlParameter("@AppointmentId", AppointmentId))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@AppointmentId", DBNull.Value))
                    End If

                Else
                    cmd.Parameters.Add(New SqlParameter("@AppointmentId", DBNull.Value))
                End If



                cmd.Parameters.Add(New SqlParameter("@OrderMessage", OrderMessage))

                If OperatingHospitalId.HasValue Then
                    If OperatingHospitalId > 0 Then
                        cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", OperatingHospitalId))
                    Else
                        cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", DBNull.Value))
                    End If

                Else
                    cmd.Parameters.Add(New SqlParameter("@OperatingHospitalId", DBNull.Value))
                End If


                cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
                connection.Open()
                cmd.ExecuteNonQuery()

            End Using
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function SendOrderMessageByOrderAndEventId", ex)
            Return False
        End Try
    End Function
    Public Function GetWaitingListIdByOrderId(ByVal OrderId As Integer) As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Select WaitingListId from ERS_Orders Where OrderId = @OrderId;", connection)
            cmd.Parameters.Add(New SqlParameter("@OrderId", OrderId))
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
    Public Function GetOrderIdByAppointmentId(ByVal AppointmentId As Integer) As Integer
        Dim strSQL As String = ""
        strSQL = "Select IsNull(o.OrderId,0) as OrderId from ERS_Appointments eapt " +
"Left Join ERS_Waiting_List wl on eapt.WaitingListId = wl.WaitingListId " +
        "Left Join ERS_Orders o on wl.WaitingListId = o.WaitingListId " +
        "Where eapt.AppointmentId = @AppointmentId"

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(strSQL, connection)
            cmd.Parameters.Add(New SqlParameter("@AppointmentId", AppointmentId))
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
    Public Function SendMarkDNAOrderMessageByProcedureId(ByVal ProcedureId As Integer,
        ByVal UserId As Integer) As Boolean
        Try
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("usp_SendMarkDNAOrderMessageByProcedureId", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
                cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
                connection.Open()
                cmd.ExecuteNonQuery()

            End Using
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in Function Updateusp_SendMarkDNAOrderMessageByProcedureId...", ex)
            Return False
        End Try
    End Function

#End Region

End Class
