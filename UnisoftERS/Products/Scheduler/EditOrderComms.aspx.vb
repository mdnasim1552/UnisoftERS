Imports Telerik.Web.UI
Public Class EditOrderComms
    Inherits System.Web.UI.Page
    Private _dataadapter As DataAccess = Nothing
    Private _dataadapter_sch As DataAccess_Sch = Nothing
    Private _ordercommsbl As OrderCommsBL = Nothing
    Public Shared intOrderId As Integer
    Public Shared blnFromWaitList As Boolean = False
    Public Shared strOrderSourceDisplayColumns As String = ""


    Private Enum OrderCommsStatus
        OnWaitingList = 3
        Pending = 1
        Rejected = 2
    End Enum

    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataadapter Is Nothing Then
                _dataadapter = New DataAccess
            End If
            Return _dataadapter
        End Get
    End Property
    Protected ReadOnly Property DataAdapter_Sch() As DataAccess_Sch
        Get
            If _dataadapter_sch Is Nothing Then
                _dataadapter_sch = New DataAccess_Sch
            End If
            Return _dataadapter_sch
        End Get
    End Property
    Protected ReadOnly Property OrderCommsBL() As OrderCommsBL
        Get
            If _ordercommsbl Is Nothing Then
                _ordercommsbl = New OrderCommsBL
            End If
            Return _ordercommsbl
        End Get
    End Property
    Property PageSearchFields As Products_Scheduler.SearchFields
        Get
            Return Session("SearchFields")
        End Get
        Set(value As Products_Scheduler.SearchFields)
            Session("SearchFields") = value
        End Set
    End Property
    Protected Sub CheckBuiltInSkins()
        Dim lstSkins As List(Of String)

    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Not IsDBNull(Request.QueryString("OrderId")) AndAlso Request.QueryString("OrderId") <> "" Then
                intOrderId = CInt(Request.QueryString("OrderId"))

                LoadComboboxes()
                LoadDataInControls()

            Else
                intOrderId = -1
            End If
            If Not IsDBNull(Request.QueryString("fromwaitlist")) AndAlso Request.QueryString("fromwaitlist") <> "" Then
                If Request.QueryString("fromwaitlist") = "y" Then
                    blnFromWaitList = True
                Else
                    blnFromWaitList = False
                End If
            Else
                blnFromWaitList = False
            End If

            If blnFromWaitList Then
                btnOrderClose.Enabled = False
            Else
                btnOrderClose.Enabled = True
            End If

            HealthServiceNameIdEditOrderCommsTd.InnerText = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " number:"

        End If

        If intOrderId > 0 Then
            'OrderId provided. Edit/Reject environment
            SetEditRejectEvironment()
            btnSaveNewOrderComm.Visible = False

            If Not IsNothing(cboOrderStatus.SelectedValue) Then

                If cboOrderStatus.SelectedValue.ToString() <> "" Then
                    If cboOrderStatus.SelectedValue = OrderCommsStatus.Pending Then
                        btnOrderAddToWaitlist.Visible = True
                    Else
                        btnOrderAddToWaitlist.Visible = False
                    End If
                Else

                End If

            End If

            btnOrderReject.Visible = True

        Else
            'No Order Id, its a New OrderComm, Add New Environment
            btnSaveNewOrderComm.Visible = True
            btnOrderAddToWaitlist.Visible = False
            btnOrderReject.Visible = False
        End If
        UpdateStatusLabel.Visible = False
    End Sub

    Private Sub SetEditRejectEvironment()
        MakeSomeControlsReadOnlyforRejectEnvironment()
    End Sub
    Private Sub SetAddNewEnvironment()
        btnSaveNewOrderComm.Visible = True
        btnOrderReject.Visible = False
        btnSelectPatient.Visible = True
    End Sub
    Private Sub MakeSomeControlsReadOnlyforRejectEnvironment()
        txtOrderNumber.Enabled = False
        OrderDate.Enabled = False
        DateRaised.Enabled = False
        DateReceived.Enabled = False
        DueDate.Enabled = False
        'txtOrderSource.Enabled = False
        cboOrderSourceListNo.Enabled = False
        txtLocation.Enabled = False
        txtWard.Enabled = False
        txtBed.Enabled = False
        'txtReferrer.Enabled = False
        'txtOrderHospital.Enabled = False
        'txtOrderDepartment.Enabled = False
        'txtAssignedCareProfessional.Enabled = False
        cboOrderPriority.Enabled = False
        'txtOrderedBy.Enabled = False
        'txtOrderedByContact.Enabled = False
        cboProcedureType.Enabled = False
        lblProcedureType.Visible = True
        cboProcedureType.Visible = False

        cboOrderStatus.Enabled = False
        cboRejectionReasonId.Enabled = True
        txtRejectionComments.Enabled = True
        cboReferringConsultant.Enabled = False
        cboReferringConsultantSpeciality.Enabled = False
        cboReferringHospital.Enabled = False

    End Sub

    Protected Sub CancelSearchButton_Click(sender As Object, e As EventArgs)
        Dim btn = CType(sender, RadButton)

        Select Case btn.CommandName.ToLower
            Case "cancelmovebooking"
                Session("AppointmentId") = Nothing
            Case "cancelsearchslot"
                PageSearchFields = Nothing
            Case "cancelbookfromwaitlist"
                Session("WaitlistId") = Nothing
        End Select

        btn.CommandName = Nothing
    End Sub
    Protected Sub btnOrderAddToWaitlist_Click(sender As Object, e As EventArgs)
        Try
            Dim intSuccess As Int32
            Dim strErrorMessage As String

            Dim intLoggedInUserID As Integer = HttpContext.Current.Session("PKUserID")

            strErrorMessage = ""

            intSuccess = OrderCommsBL.MoveOrderCommsToWaitingList(strErrorMessage, intOrderId, intLoggedInUserID)

            If intSuccess = 1 Then
                UpdateStatusLabel.Visible = True
                UpdateStatusLabel.InnerHtml = "Patient of this Order Comm has been moved to Waiting List<br />"

#Region "Send Order Message"
                Dim strOrderMessage As String = ""
                Dim blnOrderEventIdSendEnabled As Boolean = False
                Dim strLoggedInUserName As String = HttpContext.Current.Session("UserID")
                Dim WaitingListId As Integer

                'Code 4 is for Sent to Waiting List

                blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(4)
                WaitingListId = OrderCommsBL.GetWaitingListIdByOrderId(intOrderId)

                If blnOrderEventIdSendEnabled Then
                    strOrderMessage = "Order Sent to Waiting List by " + strLoggedInUserName
                    OrderCommsBL.SendOrderMessageByOrderAndEventId(intOrderId, 4, Nothing, WaitingListId, Nothing, strOrderMessage, Nothing, intLoggedInUserID)
                End If
#End Region

                LoadDataInControls()
            Else
                UpdateStatusLabel.Visible = True
                UpdateStatusLabel.InnerHtml = "Couldn't be moved to Waiting List <br />" & strErrorMessage
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : btnOrderAddToWaitlist_Click", ex)
        End Try
    End Sub
    Protected Sub btnUpdateHistory_Click(sender As Object, e As EventArgs)
        Try
            UpdateOrderComms()
            UpdateStatusLabel.Visible = True
            UpdateStatusLabel.InnerHtml = "Patient Clinical History Updated successfully.<br />"

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : btnUpdateHistory_Click", ex)
        End Try
    End Sub
    Protected Sub btnOrderReject_Click(sender As Object, e As EventArgs)
        Try
            Dim blnRejectionComboProvided As Boolean = False
            Dim blnRejectionCommentsProvided As Boolean = False

            If btnOrderReject.Text = "Reject" Then

                If IsNothing(cboRejectionReasonId.SelectedItem) Then
                    blnRejectionComboProvided = False
                Else
                    If cboRejectionReasonId.SelectedValue > 0 Then
                        blnRejectionComboProvided = True
                    Else
                        blnRejectionComboProvided = False
                    End If
                End If

                If txtRejectionComments.Text.Trim() <> "" Then
                    blnRejectionCommentsProvided = True
                Else
                    blnRejectionCommentsProvided = False
                End If

                If Not blnRejectionComboProvided Then
                    RejectionReasonComboError.Visible = True
                Else
                    RejectionReasonComboError.Visible = False
                End If

                If Not blnRejectionCommentsProvided Then
                    RejectionCommentsError.Visible = True
                Else
                    RejectionCommentsError.Visible = False
                End If
            Else
                RejectionCommentsError.Visible = False
                RejectionReasonComboError.Visible = False
            End If

            If (blnRejectionComboProvided And blnRejectionCommentsProvided) Or btnOrderReject.Text = "Un-Reject" Then
                'Do Rejection of Order Comms
                RejectOrderComms()
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : btnOrderReject_Click", ex)
        End Try
    End Sub
    Protected Sub UpdateOrderComms()
        Try
            Dim intLoggedInUserID As Integer = HttpContext.Current.Session("PKUserID")
            Dim strLoggedInUserName As String = HttpContext.Current.Session("UserID")

#Region "OrderCommsVariable"
            Dim lOrderId As Nullable(Of Integer)
            Dim lSavedReturnedOrderId As Integer

            Dim lOperatingHospitalId As Int32
            Dim lDateReceived As Nullable(Of Date)
            Dim lProcedureType As Int32
            Dim lOrderDate As Nullable(Of Date)
            Dim lPatientId As Integer
            Dim lPriorityId As Int32
            Dim lDueDate As Nullable(Of Date)
            Dim lStatusId As Int32
            'Dim lAssignedCareProfessional As String
            ' Dim lReferrer As String
            Dim lOrderNumber As String
            Dim lOrderSource As Integer
            'Dim lOrderDepartment As String
            Dim lOrderLocation As String
            Dim lReferralConsultantID? As Integer
            Dim lReferralHospitalID? As Integer
            Dim lReferralConsultantSpeciality? As Integer
            Dim lOrderWard As String
            Dim lBedLocation As String
            Dim lClinicalHistoryNotes As String
            Dim lTestSite As String
            'Dim lOrderedBy As String
            'Dim lOrderedByContact As String
            Dim lRejectionReasonId As Nullable(Of Integer)
            Dim lWhoRejected As String
            Dim lRejectionComments As String
            Dim lUserId As Integer


            lReferralConsultantID = Nothing
            lReferralHospitalID = Nothing
            lReferralConsultantSpeciality = Nothing

            If intOrderId > 0 Then
                lOrderId = intOrderId
            Else
                lOrderId = Nothing
            End If

            lOperatingHospitalId = intOperatingHospitalId.Value

            If Not IsNothing(DateReceived.SelectedDate) Then
                lDateReceived = DateReceived.SelectedDate
            Else
                lDateReceived = Nothing
            End If

            If Not IsNothing(cboProcedureType.SelectedValue) Then
                lProcedureType = Convert.ToInt32(cboProcedureType.SelectedValue.ToString())
            End If

            If Not IsNothing(OrderDate.SelectedDate) Then
                lOrderDate = OrderDate.SelectedDate
            Else
                lOrderDate = Nothing
            End If

            lPatientId = Convert.ToInt32(intPatientId.Value)

            If Not IsNothing(cboOrderPriority.SelectedValue) Then
                lPriorityId = Convert.ToInt32(cboOrderPriority.SelectedValue.ToString())
            Else
                lPriorityId = Nothing
            End If

            If Not IsNothing(DueDate.SelectedDate) Then
                lDueDate = DueDate.SelectedDate
            Else
                lDueDate = Nothing
            End If

            If Not IsNothing(cboReferringConsultant.SelectedValue) Then
                If Convert.ToInt32(cboReferringConsultant.SelectedValue.ToString()) > 0 Then
                    lReferralConsultantID = Convert.ToInt32(cboReferringConsultant.SelectedValue.ToString())
                End If
            End If

            If Not IsNothing(cboReferringConsultantSpeciality.SelectedValue) Then
                If Convert.ToInt32(cboReferringConsultantSpeciality.SelectedValue.ToString()) > 0 Then
                    lReferralConsultantSpeciality = Convert.ToInt32(cboReferringConsultantSpeciality.SelectedValue.ToString())
                End If
            End If
            If Not IsNothing(cboReferringHospital.SelectedValue) Then
                If Convert.ToInt32(cboReferringHospital.SelectedValue.ToString()) > 0 Then
                    lReferralHospitalID = Convert.ToInt32(cboReferringHospital.SelectedValue.ToString())
                End If
            End If


            If Not IsNothing(cboOrderStatus.SelectedValue) Then
                lStatusId = Convert.ToInt32(cboOrderStatus.SelectedValue.ToString())
            Else
                lStatusId = Nothing
            End If



            'lAssignedCareProfessional = txtAssignedCareProfessional.Text
            'lReferrer = txtReferrer.Text
            lOrderNumber = txtOrderNumber.Text
            If Not IsNothing(cboOrderSourceListNo.SelectedValue) Then
                lOrderSource = CInt(cboOrderSourceListNo.SelectedValue)
            End If

            'lOrderDepartment = txtOrderDepartment.Text
            lOrderLocation = txtLocation.Text
            'lOrderHospital = txtOrderHospital.Text
            lOrderWard = txtWard.Text
            lBedLocation = txtBed.Text
            lClinicalHistoryNotes = HttpUtility.HtmlEncode(txtClinicalHistory.Content)
            lTestSite = ""
            'lOrderedBy = txtOrderedBy.Text
            'lOrderedByContact = txtOrderedByContact.Text

            lWhoRejected = strLoggedInUserName

            If Not IsNothing(cboRejectionReasonId.SelectedValue) Then
                If cboRejectionReasonId.SelectedValue.ToString().Trim() <> "" Then
                    lRejectionReasonId = Convert.ToInt32(cboRejectionReasonId.SelectedValue.ToString())
                Else
                    lRejectionReasonId = Nothing
                End If

            Else
                lRejectionReasonId = Nothing
            End If
            lRejectionComments = txtRejectionComments.Text


            lUserId = intLoggedInUserID

#End Region

            lSavedReturnedOrderId = OrderCommsBL.AddOrUpdateOrderComms(lOrderId, lOperatingHospitalId, lDateReceived, lProcedureType, lOrderDate, lPatientId, lPriorityId, lDueDate, lStatusId,
                                 lOrderNumber, lOrderSource, lOrderLocation, lReferralConsultantID, lReferralHospitalID, lReferralConsultantSpeciality,
                                   lOrderWard, lBedLocation, lClinicalHistoryNotes, lTestSite, lRejectionReasonId, lWhoRejected, System.DateTime.Now(), lRejectionComments, lUserId)

            intOrderId = lSavedReturnedOrderId

            LoadDataInControls()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : UpdateOrderComms()", ex)
        End Try
    End Sub
    Protected Sub RejectOrderComms()
        Try
            Dim intLoggedInUserID As Integer = HttpContext.Current.Session("PKUserID")
            Dim strLoggedInUserName As String = HttpContext.Current.Session("UserID")

#Region "OrderCommsVariable"
            Dim lOrderId As Nullable(Of Integer)
            Dim lOperatingHospitalId As Int32
            Dim lDateReceived As Nullable(Of Date)
            Dim lProcedureType As Int32
            Dim lOrderDate As Nullable(Of Date)
            Dim lPatientId As Integer
            Dim lPriorityId As Int32
            Dim lDueDate As Nullable(Of Date)
            Dim lStatusId As Int32
            Dim lOrderNumber As String
            Dim lOrderSource As String
            Dim lOrderLocation As String
            Dim lReferralConsultantID? As Integer
            Dim lReferralHospitalID? As Integer
            Dim lReferralConsultantSpeciality? As Integer
            Dim lOrderWard As String
            Dim lBedLocation As String
            Dim lClinicalHistoryNotes As String
            Dim lTestSite As String
            Dim lRejectionReasonId As Nullable(Of Integer)
            Dim lWhoRejected As String
            Dim lRejectionComments As String
            Dim lUserId As Integer


            lReferralConsultantID = Nothing
            lReferralHospitalID = Nothing
            lReferralConsultantSpeciality = Nothing

            If intOrderId > 0 Then
                lOrderId = intOrderId
            Else
                lOrderId = Nothing
            End If

            lOperatingHospitalId = intOperatingHospitalId.Value

            If Not IsNothing(DateReceived.SelectedDate) Then
                lDateReceived = DateReceived.SelectedDate
            Else
                lDateReceived = Nothing
            End If

            If Not IsNothing(cboProcedureType.SelectedValue) Then
                lProcedureType = Convert.ToInt32(cboProcedureType.SelectedValue.ToString())
            End If

            If Not IsNothing(cboReferringConsultant.SelectedValue) Then
                If Convert.ToInt32(cboReferringConsultant.SelectedValue.ToString()) > 0 Then
                    lReferralConsultantID = Convert.ToInt32(cboReferringConsultant.SelectedValue.ToString())
                End If
            End If

            If Not IsNothing(cboReferringConsultantSpeciality.SelectedValue) Then
                If Convert.ToInt32(cboReferringConsultantSpeciality.SelectedValue.ToString()) > 0 Then
                    lReferralConsultantSpeciality = Convert.ToInt32(cboReferringConsultantSpeciality.SelectedValue.ToString())
                End If
            End If
            If Not IsNothing(cboReferringHospital.SelectedValue) Then
                If Convert.ToInt32(cboReferringHospital.SelectedValue.ToString()) > 0 Then
                    lReferralHospitalID = Convert.ToInt32(cboReferringHospital.SelectedValue.ToString())
                End If
            End If



            If Not IsNothing(OrderDate.SelectedDate) Then
                lOrderDate = OrderDate.SelectedDate
            Else
                lOrderDate = Nothing
            End If

            lPatientId = Convert.ToInt32(intPatientId.Value)

            If Not IsNothing(cboOrderPriority.SelectedValue) Then
                lPriorityId = Convert.ToInt32(cboOrderPriority.SelectedValue.ToString())
            Else
                lPriorityId = Nothing
            End If

            If Not IsNothing(DueDate.SelectedDate) Then
                lDueDate = DueDate.SelectedDate
            Else
                lDueDate = Nothing
            End If


            'If Not IsNothing(cboOrderStatus.SelectedValue) Then
            '    lStatusId = Convert.ToInt32(cboOrderStatus.SelectedValue.ToString())
            'Else
            '    lStatusId = Nothing
            'End If

            'For Reject Set lStatusId to Reject Status
            If btnOrderReject.Text = "Reject" Then
                lStatusId = OrderCommsStatus.Rejected
            ElseIf btnOrderReject.Text = "Un-Reject" Then
                lStatusId = OrderCommsStatus.Pending
            End If


            lOrderNumber = txtOrderNumber.Text

            If Not IsNothing(cboOrderSourceListNo.SelectedValue) Then
                If cboOrderSourceListNo.SelectedValue.ToString().Trim() <> "" Then
                    lOrderSource = CInt(cboOrderSourceListNo.SelectedValue)
                Else
                    lOrderSource = ""
                End If
            Else
                lOrderSource = ""
            End If

            lOrderLocation = txtLocation.Text
            lOrderWard = txtWard.Text
            lBedLocation = txtBed.Text
            lClinicalHistoryNotes = HttpUtility.HtmlEncode(txtClinicalHistory.Content)
            lTestSite = ""

            lWhoRejected = strLoggedInUserName


            If btnOrderReject.Text = "Reject" Then
                lRejectionComments = txtRejectionComments.Text
                lRejectionReasonId = Convert.ToInt32(cboRejectionReasonId.SelectedValue.ToString())
            ElseIf btnOrderReject.Text = "Un-Reject" Then
                lRejectionComments = Nothing
                lRejectionReasonId = Nothing
            End If

            lUserId = intLoggedInUserID

#End Region

            OrderCommsBL.AddOrUpdateOrderComms(lOrderId, lOperatingHospitalId, lDateReceived, lProcedureType, lOrderDate, lPatientId, lPriorityId, lDueDate, lStatusId,
                                               lOrderNumber, lOrderSource, lOrderLocation, lReferralConsultantID, lReferralHospitalID,
                                   lReferralConsultantSpeciality, lOrderWard, lBedLocation, lClinicalHistoryNotes, lTestSite, lRejectionReasonId, lWhoRejected, System.DateTime.Now(), lRejectionComments, lUserId)

            UpdateStatusLabel.Visible = True
#Region "Order Message Send"
            Dim strOrderMessage As String = ""
            Dim blnOrderEventIdSendEnabled As Boolean = False


#End Region
            If btnOrderReject.Text = "Reject" Then
                UpdateStatusLabel.InnerHtml = "OrderComm Record Rejected.<br />"
                btnOrderReject.Text = "Un-Reject"

                blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(2)
                If blnOrderEventIdSendEnabled Then
                    strOrderMessage = "Order Rejected by " + lWhoRejected + " - reason : " + cboRejectionReasonId.SelectedItem.Text.ToString()
                    OrderCommsBL.SendOrderMessageByOrderAndEventId(lOrderId, 2, Nothing, Nothing, Nothing, strOrderMessage, Nothing, lUserId)
                End If

            ElseIf btnOrderReject.Text = "Un-Reject" Then
                UpdateStatusLabel.InnerHtml = "OrderComm Record Un Rejected and set status to Pending<br />"
                btnOrderReject.Text = "Reject"

                blnOrderEventIdSendEnabled = OrderCommsBL.CheckIfOrderEventIdMessageSendEnabled(3)
                If blnOrderEventIdSendEnabled Then
                    strOrderMessage = "Order Un-Rejected by " + lWhoRejected
                    OrderCommsBL.SendOrderMessageByOrderAndEventId(lOrderId, 3, Nothing, Nothing, Nothing, strOrderMessage, Nothing, lUserId)
                End If
            End If
            LoadDataInControls()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : RejectOrderComms()", ex)
        End Try
    End Sub
    Protected Sub LoadComboboxes()
        LoadProcedureTypeCombo()

        LoadPriorityCombo()

        LoadStatusCombo()

        LoadRejectionReasonCombo()

        LoadOrderCommsOrderSourceListNoCombo()

        LoadReferringConsultantsCombo()

        LoadRefConsSpecialitysCombo()

        LoadReferringHospitalsCombo()

    End Sub
    Protected Sub LoadDataInControls()
        Try
            Dim dsData As New DataSet
            dsData = OrderCommsBL.GetOrderCommsDetails(intOrderId)
            Dim strPatientName As String = ""
            Dim strSurname As String = ""
            Dim strForeName As String = ""
            Dim strPatAddress As String = ""
            Dim dsOrderSourceDisplayColumns As New DataSet

            'dsData holds 2 table. Table 0:OrderComms record, Table 1: QuestionsAnswers table
            ClearForm()

            If dsData.Tables(0).Rows.Count > 0 Then
#Region "Patient Information"


                intPatientId.Value = CInt(dsData.Tables(0).Rows(0)("PatientId").ToString())

                If Not IsDBNull(dsData.Tables(0).Rows(0)("OperatingHospitalId")) Then
                    intOperatingHospitalId.Value = CInt(dsData.Tables(0).Rows(0)("OperatingHospitalId").ToString())
                Else
                    intOperatingHospitalId.Value = Session("OperatingHospitalId")
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("Forename")) Then
                    strForeName = dsData.Tables(0).Rows(0)("Forename").ToString()
                Else
                    strForeName = ""
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("Surname")) Then
                    strSurname = dsData.Tables(0).Rows(0)("Surname").ToString()
                Else
                    strSurname = ""
                End If

                strPatientName = strForeName + " " + strSurname
                OrderDetailPatName.Text = strPatientName.Trim()


                If Not IsDBNull(dsData.Tables(0).Rows(0)("PatientAddress")) Then
                    strPatAddress = dsData.Tables(0).Rows(0)("PatientAddress").ToString()
                Else
                    strPatAddress = ""
                End If
                strPatAddress = strPatAddress.Replace("  ", " ").Trim()
                OrderDetailPatAddress.Text = strPatAddress

                If Not IsDBNull(dsData.Tables(0).Rows(0)("Gender")) Then
                    OrderDetailPatGender.Text = dsData.Tables(0).Rows(0)("Gender").ToString()
                Else
                    OrderDetailPatGender.Text = "N/A"
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("DateOfBirth")) Then
                    OrderDetailPatDOB.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateOfBirth").ToString()).ToString("dd MMM yyyy")
                Else
                    OrderDetailPatDOB.Text = "N/A"
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("HospitalNumber")) Then
                    OrderDetailPatHospitalNo.Text = dsData.Tables(0).Rows(0)("HospitalNumber").ToString()
                Else
                    OrderDetailPatHospitalNo.Text = "N/A"
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("NHSNo")) Then
                    OrderDetailPatNHSNo.Text = Utilities.FormatHealthServiceNumber(dsData.Tables(0).Rows(0)("NHSNo").ToString())
                Else
                    OrderDetailPatNHSNo.Text = "N/A"
                End If

#End Region
#Region "Order Comms detail section"
                If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderDate")) Then
                    OrderDate.SelectedDate = Convert.ToDateTime(dsData.Tables(0).Rows(0)("OrderDate").ToString())
                    lblOrderDate.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("OrderDate").ToString()).ToString("dd MMM yyyy")

                Else
                    OrderDate.SelectedDate = Nothing
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("DateReceived")) Then
                    DateReceived.SelectedDate = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateReceived").ToString())
                    lblDateReceived.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateReceived").ToString()).ToString("dd MMM yyyy")
                Else
                    DateReceived.SelectedDate = Nothing
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("DueDate")) Then
                    DueDate.SelectedDate = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DueDate").ToString())
                    lblDueDate.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DueDate").ToString()).ToString("dd MMM yyyy")
                Else
                    DueDate.SelectedDate = Nothing
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("DateAdded")) Then
                    DateRaised.SelectedDate = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateAdded").ToString())
                    lblDateRaised.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateAdded").ToString()).ToString("dd MMM yyyy")
                ElseIf Not IsDBNull(dsData.Tables(0).Rows(0)("DateReceived")) Then
                    DateRaised.SelectedDate = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateReceived").ToString())
                    lblDateRaised.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateReceived").ToString()).ToString("dd MMM yyyy")
                Else
                    DateRaised.SelectedDate = Nothing
                End If


                If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantID")) Then
                    cboReferringConsultant.SelectedValue = CInt(dsData.Tables(0).Rows(0)("ReferralConsultantID").ToString())
                    lblReferringConsultant.Text = dsData.Tables(0).Rows(0)("ReferralConsultantName").ToString()
                Else
                    cboReferringConsultant.SelectedValue = Nothing
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantSpecialty")) Then
                    cboReferringConsultantSpeciality.SelectedValue = CInt(dsData.Tables(0).Rows(0)("ReferralConsultantSpecialty").ToString())
                Else
                    cboReferringConsultantSpeciality.SelectedValue = Nothing
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantSpecialtyName")) Then
                    lblReferringConsultantSpeciality.Text = dsData.Tables(0).Rows(0)("ReferralConsultantSpecialtyName").ToString()
                Else
                    lblReferringConsultantSpeciality.Text = ""
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralHospitalID")) Then
                    cboReferringHospital.SelectedValue = CInt(dsData.Tables(0).Rows(0)("ReferralHospitalID").ToString())
                    lblReferringHospital.Text = dsData.Tables(0).Rows(0)("ReferralHospitalName")
                Else
                    cboReferringHospital.SelectedValue = Nothing
                End If



                If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderNumber")) Then
                    txtOrderNumber.Text = dsData.Tables(0).Rows(0)("OrderNumber").ToString()
                    lblOrderNumber.Text = dsData.Tables(0).Rows(0)("OrderNumber").ToString()
                Else
                    txtOrderNumber.Text = Nothing
                End If

                strOrderSourceDisplayColumns = ""

                If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderSourceListNo")) Then
                    cboOrderSourceListNo.SelectedValue = CInt(dsData.Tables(0).Rows(0)("OrderSourceListNo").ToString())
                    lblOrderSourceListNo.Text = dsData.Tables(0).Rows(0)("OrderCommOrderSource").ToString()
                    strOrderSourceDisplayColumns = OrderCommsBL.GetERS_OrderSourceDisplayColumn(CInt(dsData.Tables(0).Rows(0)("OrderSourceListNo").ToString()))
                Else
                    cboOrderSourceListNo.SelectedValue = Nothing
                End If


                If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderLocation")) Then
                    txtLocation.Text = dsData.Tables(0).Rows(0)("OrderLocation").ToString()
                    lblLocation.Text = dsData.Tables(0).Rows(0)("OrderLocation").ToString()
                Else
                    txtLocation.Text = Nothing
                End If



                If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderWard")) Then
                    txtWard.Text = dsData.Tables(0).Rows(0)("OrderWard").ToString()
                    lblWard.Text = dsData.Tables(0).Rows(0)("WardDescription").ToString()
                Else
                    txtWard.Text = Nothing
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("BedLocation")) Then
                    txtBed.Text = dsData.Tables(0).Rows(0)("BedLocation").ToString()
                    lblBed.Text = dsData.Tables(0).Rows(0)("BedLocation").ToString()
                Else
                    txtBed.Text = Nothing
                    lblBed.Text = ""
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("GPName")) Then

                Else

                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("ClinicalHistoryNotes")) Then
                    txtClinicalHistory.Content = HttpUtility.HtmlDecode(dsData.Tables(0).Rows(0)("ClinicalHistoryNotes").ToString())
                    lblClinicalHistory.Text = HttpUtility.HtmlDecode(dsData.Tables(0).Rows(0)("ClinicalHistoryNotes").ToString())

                Else
                    txtClinicalHistory.Content = Nothing
                End If


                If Not IsDBNull(dsData.Tables(0).Rows(0)("ProcedureTypeId")) Then
                    cboProcedureType.SelectedValue = CInt(dsData.Tables(0).Rows(0)("ProcedureTypeId").ToString())
                    lblProcedureType.Text = dsData.Tables(0).Rows(0)("ProcedureType").ToString().ToUpper()
                Else
                    cboProcedureType.SelectedValue = Nothing
                    lblProcedureType.Text = ""
                End If



                If Not IsDBNull(dsData.Tables(0).Rows(0)("OrdersPriorityId")) Then
                    cboOrderPriority.SelectedValue = CInt(dsData.Tables(0).Rows(0)("OrdersPriorityId").ToString())
                    lblOrderPriority.Text = dsData.Tables(0).Rows(0)("Priority").ToString()
                Else
                    cboOrderPriority.SelectedValue = Nothing
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("StatusId")) Then
                    cboOrderStatus.SelectedValue = CInt(dsData.Tables(0).Rows(0)("StatusId").ToString())
                    lblOrderStatus.Text = dsData.Tables(0).Rows(0)("Status")
                    SetButtonsFromStatusId()
                Else
                    cboOrderStatus.SelectedValue = Nothing
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("RejectionReasonId")) Then
                    cboRejectionReasonId.SelectedValue = CInt(dsData.Tables(0).Rows(0)("RejectionReasonId").ToString())

                    If cboRejectionReasonId.SelectedValue = OrderCommsStatus.Pending Then
                        btnOrderAddToWaitlist.Visible = True
                    Else
                        btnOrderAddToWaitlist.Visible = False
                    End If

                Else
                    cboRejectionReasonId.SelectedValue = Nothing
                    cboRejectionReasonId.Text = ""
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("RejectionComments")) Then
                    txtRejectionComments.Text = dsData.Tables(0).Rows(0)("RejectionComments").ToString()
                Else
                    txtRejectionComments.Text = Nothing
                End If

                'OrderSourceListNo - In-Patient, Day-Patient/OutPatient, GP
                '1      -       Inpatient
                '2      -       OutPatient
                '3      -       DayPatient
                '4      -       GP

                If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderSourceListNo")) Then
                    Select Case Convert.ToInt32(dsData.Tables(0).Rows(0)("OrderSourceListNo").ToString())
                        Case 1 'Inpatient
                            trWardBed.Visible = True

                        Case 2, 3 'Outpatient / DayPatient
                            trWardBed.Visible = False
                            lblReferrerLabel.Text = "Referral:"
                            lblReferringConsultant.Text = ""
                            If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantName")) Then
                                lblReferringConsultant.Text = dsData.Tables(0).Rows(0)("ReferralConsultantName")
                            End If

                            lblReferrerSpecialityLabel.Text = "Referral Speciality:"
                            If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantSpecialtyName")) Then
                                lblReferringConsultantSpeciality.Text = dsData.Tables(0).Rows(0)("ReferralConsultantSpecialtyName")
                            End If

                        Case 4 'GP
                            trWardBed.Visible = False
                            lblReferrerLabel.Text = "Referral GP:"
                            lblReferringConsultant.Text = ""
                            If Not IsDBNull(dsData.Tables(0).Rows(0)("GPName")) Then
                                lblReferringConsultant.Text = dsData.Tables(0).Rows(0)("GPName")
                            End If

                            lblReferrerSpecialityLabel.Text = "Referral Practice:"
                            If Not IsDBNull(dsData.Tables(0).Rows(0)("PracticeName")) Then
                                lblReferringConsultantSpeciality.Text = dsData.Tables(0).Rows(0)("PracticeName")
                            End If
                        Case Else

                    End Select
                End If

                If Not IsDBNull(dsData.Tables(0).Rows(0)("ProcedureId")) Then
                    lblProcedure.Visible = True
                    lblProcedure.Text = "Procedure created : "
                    If Not IsDBNull(dsData.Tables(0).Rows(0)("CreatedOn")) Then
                        lblProcedure.Text = lblProcedure.Text + Convert.ToDateTime(dsData.Tables(0).Rows(0)("CreatedOn").ToString()).ToString("dd MMM yyyy")
                    End If
                    btnOrderAddToWaitlist.Enabled = False
                    btnOrderReject.Enabled = False
                Else
                    lblProcedure.Visible = False
                    'btnOrderAddToWaitlist.Enabled = True
                    'btnOrderReject.Enabled = True
                End If
#End Region

                gridQuestionsAnswers.DataSource = Nothing
                gridQuestionsAnswers.DataSource = dsData.Tables(1)
                gridQuestionsAnswers.DataBind()


                Dim dsPrevProcHistory As New DataSet
                dsPrevProcHistory = OrderCommsBL.GetPreviousProcedureListByPatientId(Convert.ToInt32(intPatientId.Value))
                If dsPrevProcHistory.Tables(0).Rows.Count > 0 Then
                    lblPrevHistoryNoRecords.Visible = False
                    tblPrevHistory.Visible = True
                Else
                    lblPrevHistoryNoRecords.Visible = True
                    tblPrevHistory.Visible = False
                End If
                rptPrevProcHistory.DataSource = Nothing
                rptPrevProcHistory.DataSource = dsPrevProcHistory
                rptPrevProcHistory.DataBind()

                MakeLabelVisibleAndInputInvisible()

            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error Occured in : EditOrderComms.aspx.vb-->LoadDataInControls()", ex)
        End Try
    End Sub
    Protected Sub MakeLabelVisibleAndInputInvisible()
        Try
            txtOrderNumber.Visible = False
            lblOrderNumber.Visible = True

            OrderDate.Visible = False
            lblOrderDate.Visible = True

            DueDate.Visible = False
            lblDueDate.Visible = True

            DateRaised.Visible = False
            lblDateRaised.Visible = True

            DateReceived.Visible = False
            lblDateReceived.Visible = True

            txtLocation.Visible = False
            lblLocation.Visible = True

            txtWard.Visible = False
            lblWard.Visible = True

            txtBed.Visible = False
            lblBed.Visible = True

            cboOrderSourceListNo.Visible = False
            lblOrderSourceListNo.Visible = True

            cboReferringConsultant.Visible = False
            lblReferringConsultant.Visible = True

            cboReferringConsultantSpeciality.Visible = False
            lblReferringConsultantSpeciality.Visible = True

            cboReferringHospital.Visible = False
            lblReferringHospital.Visible = True

            cboOrderPriority.Visible = False
            lblOrderPriority.Visible = True

            txtClinicalHistory.Visible = False
            lblClinicalHistory.Visible = True

            cboOrderStatus.Visible = False
            lblOrderStatus.Visible = True

            'Make few data labels visible/invisible depending on Order Sources from Link Table

            'WardId
            If strOrderSourceDisplayColumns.Contains("WardId") Then
                lblWard.Visible = True
            Else
                lblWard.Visible = False
            End If
            'BedLocation
            If strOrderSourceDisplayColumns.Contains("BedLocation") Then
                lblBed.Visible = True
            Else
                lblBed.Visible = False
            End If
            'GPId
            If strOrderSourceDisplayColumns.Contains("GPId") Then

            Else

            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error Occured in : EditOrderComms.aspx.vb-->MakeLabelVisibleAndInputInvisible()", ex)
        End Try
    End Sub
    Protected Sub SetButtonsFromStatusId()
        If Not IsNothing(cboOrderStatus.SelectedValue) Then
            If cboOrderStatus.SelectedValue = OrderCommsStatus.Pending Then
                btnOrderAddToWaitlist.Visible = True
            Else
                btnOrderAddToWaitlist.Visible = False
            End If

            If cboOrderStatus.SelectedValue = OrderCommsStatus.Rejected Then
                btnOrderReject.Enabled = True
                btnOrderReject.Text = "Un-Reject"
            ElseIf cboOrderStatus.SelectedValue = OrderCommsStatus.Pending Then
                btnOrderReject.Enabled = True
                btnOrderReject.Text = "Reject"
            Else
                btnOrderReject.Enabled = False
            End If


        End If
    End Sub

    Protected Sub LoadProcedureTypeCombo()
        Try
            Dim dtProcedureTypes As New DataTable
            Dim rcbitem As New RadComboBoxItem

            dtProcedureTypes = DataAdapter().GetAllProcedureTypes()
            cboProcedureType.DataSource = Nothing
            cboProcedureType.Items.Clear()

            rcbitem.Value = -1
            rcbitem.Text = "Select Procedure Type"
            cboProcedureType.Items.Add(rcbitem)

            For Each drD As DataRow In dtProcedureTypes.Rows
                rcbitem = New RadComboBoxItem
                rcbitem.Value = Convert.ToInt32(drD("ProcedureTypeId"))
                rcbitem.Text = drD("ProcedureType").ToString()

                cboProcedureType.Items.Add(rcbitem)
            Next

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred in : LoadProcedureTypeCombo", ex)
        End Try
    End Sub

    Protected Sub LoadPriorityCombo()
        Dim dtslots As New DataTable
        dtslots = DataAdapter_Sch.GetSlotStatus(1, 1)
        Dim rcbitem As New RadComboBoxItem

        cboOrderPriority.DataSource = Nothing
        cboOrderPriority.Items.Clear()

        rcbitem.Value = -1
        rcbitem.Text = "Select Priority"
        cboOrderPriority.Items.Add(rcbitem)

        For Each drD As DataRow In dtslots.Rows
            rcbitem = New RadComboBoxItem
            rcbitem.Value = Convert.ToInt32(drD("StatusId"))
            rcbitem.Text = drD("Description").ToString()

            cboOrderPriority.Items.Add(rcbitem)
        Next

    End Sub

    Protected Sub LoadStatusCombo()
        Dim dtOCStatus As New DataTable

        Dim rcbitem As New RadComboBoxItem

        cboOrderStatus.DataSource = Nothing
        cboOrderStatus.Items.Clear()


        rcbitem.Value = -1
        rcbitem.Text = "Select Status"
        cboOrderStatus.Items.Add(rcbitem)

        dtOCStatus = DataAdapter_Sch.GetOrderCommsStatus()

        For Each drD As DataRow In dtOCStatus.Rows
            rcbitem = New RadComboBoxItem
            rcbitem.Value = Convert.ToInt32(drD("ListItemNo"))
            rcbitem.Text = drD("ListItemText").ToString()

            cboOrderStatus.Items.Add(rcbitem)
        Next


    End Sub
    Protected Sub LoadOrderCommsOrderSourceListNoCombo()
        Dim dtOCOrderSource As New DataTable

        Dim rcbitem As New RadComboBoxItem

        cboOrderSourceListNo.DataSource = Nothing
        cboOrderSourceListNo.Items.Clear()


        rcbitem.Value = -1
        rcbitem.Text = "Select Order Source"
        cboOrderSourceListNo.Items.Add(rcbitem)

        dtOCOrderSource = DataAdapter_Sch.GetOrderCommsOrderSource()

        For Each drD As DataRow In dtOCOrderSource.Rows
            rcbitem = New RadComboBoxItem
            rcbitem.Value = Convert.ToInt32(drD("ListItemNo"))
            rcbitem.Text = drD("ListItemText").ToString()

            cboOrderSourceListNo.Items.Add(rcbitem)
        Next


    End Sub
    Protected Sub LoadReferringConsultantsCombo()
        Dim dtOCReferringConsultant As New DataTable
        Dim da As New DataAccess

        Dim rcbitem As New RadComboBoxItem

        cboReferringConsultant.DataSource = Nothing
        cboReferringConsultant.Items.Clear()


        rcbitem.Value = -1
        rcbitem.Text = "Select Consultant"
        cboReferringConsultant.Items.Add(rcbitem)

        dtOCReferringConsultant = da.GetConsultants("")

        For Each drD As DataRow In dtOCReferringConsultant.Rows
            rcbitem = New RadComboBoxItem
            rcbitem.Value = Convert.ToInt32(drD("ConsultantID"))
            rcbitem.Text = drD("Name").ToString()

            cboReferringConsultant.Items.Add(rcbitem)
        Next
    End Sub
    Protected Sub LoadRefConsSpecialitysCombo()
        Dim dtOCRefConsSpeciality As New DataTable
        Dim da As New DataAccess

        Dim rcbitem As New RadComboBoxItem

        cboReferringConsultantSpeciality.DataSource = Nothing
        cboReferringConsultantSpeciality.Items.Clear()


        rcbitem.Value = -1
        rcbitem.Text = "Select Speciality"
        cboReferringConsultantSpeciality.Items.Add(rcbitem)

        dtOCRefConsSpeciality = da.GetSpeciality()

        For Each drD As DataRow In dtOCRefConsSpeciality.Rows
            rcbitem = New RadComboBoxItem
            rcbitem.Value = Convert.ToInt32(drD("GroupID"))
            rcbitem.Text = drD("GroupName").ToString()

            cboReferringConsultantSpeciality.Items.Add(rcbitem)
        Next
    End Sub
    Protected Sub LoadReferringHospitalsCombo()
        Dim dtOCReferringHospital As New DataTable
        Dim da As New DataAccess

        Dim rcbitem As New RadComboBoxItem

        cboReferringHospital.DataSource = Nothing
        cboReferringHospital.Items.Clear()


        rcbitem.Value = -1
        rcbitem.Text = "Select Hospital"
        cboReferringHospital.Items.Add(rcbitem)

        dtOCReferringHospital = da.GetReferralHospitals("")

        For Each drD As DataRow In dtOCReferringHospital.Rows
            rcbitem = New RadComboBoxItem
            rcbitem.Value = Convert.ToInt32(drD("HospitalID"))
            rcbitem.Text = drD("HospitalName").ToString()

            cboReferringHospital.Items.Add(rcbitem)
        Next
    End Sub
    Protected Sub LoadRejectionReasonCombo()
        Dim dtOCStatus As New DataTable

        Dim rcbitem As New RadComboBoxItem

        cboRejectionReasonId.DataSource = Nothing
        cboRejectionReasonId.Items.Clear()

        rcbitem.Value = 0
        rcbitem.Text = "Select Rejection Reason"
        cboRejectionReasonId.Items.Add(rcbitem)

        dtOCStatus = DataAdapter_Sch.GetOrderCommsRejectionReasons()

        For Each drD As DataRow In dtOCStatus.Rows
            rcbitem = New RadComboBoxItem
            rcbitem.Value = Convert.ToInt32(drD("ListItemNo"))
            rcbitem.Text = drD("ListItemText").ToString()

            cboRejectionReasonId.Items.Add(rcbitem)
        Next


    End Sub


    Protected Sub ClearForm()

        OrderDetailPatName.Text = ""
        OrderDetailPatAddress.Text = ""
        OrderDetailPatGender.Text = ""
        OrderDetailPatDOB.Text = ""
        OrderDetailPatHospitalNo.Text = ""
        OrderDetailPatNHSNo.Text = ""
        intPatientId.Value = Nothing

        OrderDate.SelectedDate = Nothing
        DateReceived.SelectedDate = Nothing
        DueDate.SelectedDate = Nothing
        DateRaised.SelectedDate = Nothing


        'txtOrderSource.Text = Nothing
        cboOrderSourceListNo.SelectedValue = Nothing

        txtLocation.Text = Nothing
        txtWard.Text = Nothing
        'cboReason.SelectedValue = Nothing

        cboOrderPriority.SelectedValue = Nothing
        cboOrderStatus.SelectedValue = Nothing

        txtRejectionComments.Text = Nothing
        txtBed.Text = Nothing

        cboReferringConsultant.SelectedValue = Nothing
        cboReferringConsultantSpeciality.SelectedValue = Nothing
        cboReferringHospital.SelectedValue = Nothing


        lblProcedureType.Text = ""
        lblOrderNumber.Text = ""
        lblOrderDate.Text = ""
        lblDueDate.Text = ""
        lblDateRaised.Text = ""
        lblDateReceived.Text = ""
        lblLocation.Text = ""
        lblWard.Text = ""
        lblBed.Text = ""
        lblOrderSourceListNo.Text = ""
        lblReferringConsultant.Text = ""
        lblReferringConsultantSpeciality.Text = ""
        lblReferringHospital.Text = ""
        lblOrderPriority.Text = ""

    End Sub

    Protected Sub rptPrevProcHistory_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)

    End Sub
End Class