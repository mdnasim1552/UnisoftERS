Imports Telerik.Web.UI

Public Class OrderCommsReportForPdf
    Inherits System.Web.UI.Page
    Private _dataadapter As DataAccess = Nothing
    Private _dataadapter_sch As DataAccess_Sch = Nothing
    Private _ordercommsbl As OrderCommsBL = Nothing
    Public Shared intOrderCommId As Integer
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
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim intPatientId As Integer

        If Not IsDBNull(Request.QueryString("OrderId")) AndAlso Request.QueryString("OrderId") <> "" Then
            intOrderCommId = CInt(Request.QueryString("OrderId"))
        End If

        Dim dsData As New DataSet
        dsData = OrderCommsBL.GetOrderCommsDetails(intOrderCommId)

        Dim strForeName As String = ""
        Dim strSurname As String = ""
        Dim strPatientName As String = ""
        Dim strPatAddress As String = ""

        intPatientId = CInt(dsData.Tables(0).Rows(0)("PatientId").ToString())

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


        If Not IsDBNull(dsData.Tables(0).Rows(0)("PatientAddressWithBreak")) Then
            strPatAddress = dsData.Tables(0).Rows(0)("PatientAddressWithBreak").ToString()
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

#Region "OrderDetails"
        If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderDate")) Then
            lblOrderDate.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("OrderDate").ToString()).ToString("dd MMM yyyy")
        Else
            lblOrderDate.Text = ""
        End If

        If Not IsDBNull(dsData.Tables(0).Rows(0)("DateReceived")) Then
            lblDateReceived.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateReceived").ToString()).ToString("dd MMM yyyy")
        Else
            lblDateReceived.Text = ""
        End If

        If Not IsDBNull(dsData.Tables(0).Rows(0)("DueDate")) Then
            lblDueDate.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DueDate").ToString()).ToString("dd MMM yyyy")
        Else
            lblDueDate.Text = ""
        End If

        If Not IsDBNull(dsData.Tables(0).Rows(0)("DateAdded")) Then
            lblDateRaised.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateAdded").ToString()).ToString("dd MMM yyyy")
        ElseIf Not IsDBNull(dsData.Tables(0).Rows(0)("DateReceived")) Then
            lblDateRaised.Text = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateReceived").ToString()).ToString("dd MMM yyyy")
        Else
            lblDateRaised.Text = ""
        End If


        'MH added on 09 Mar 2022
        If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantName")) Then
            lblReferralConsultantName.Text = dsData.Tables(0).Rows(0)("ReferralConsultantName").ToString()
        Else
            lblReferralConsultantName.Text = ""
        End If
        If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralConsultantSpecialtyName")) Then
            lblReferralConsultantSpeciality.Text = dsData.Tables(0).Rows(0)("ReferralConsultantSpecialtyName").ToString()
        Else
            lblReferralConsultantSpeciality.Text = ""
        End If
        If Not IsDBNull(dsData.Tables(0).Rows(0)("ReferralHospitalName")) Then
            lblReferralHospitalName.Text = dsData.Tables(0).Rows(0)("ReferralHospitalName").ToString()
        Else
            lblReferralHospitalName.Text = ""
        End If




        If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderNumber")) Then
            lblOrderNo.Text = dsData.Tables(0).Rows(0)("OrderNumber").ToString()
        Else
            lblOrderNo.Text = ""
        End If

        'MH changed from OrderSource to OrderSourceListNo on 24 Feb 2022
        If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderSourceListNo")) Then
            lblOrderSource.Text = dsData.Tables(0).Rows(0)("OrderSourceListNo").ToString()
        Else
            lblOrderSource.Text = ""
        End If


        If Not IsDBNull(dsData.Tables(0).Rows(0)("OrderWard")) Then
            lblWard.Text = dsData.Tables(0).Rows(0)("OrderWard").ToString()
        Else
            lblWard.Text = ""
        End If

        If Not IsDBNull(dsData.Tables(0).Rows(0)("BedLocation")) Then
            lblBed.Text = dsData.Tables(0).Rows(0)("BedLocation").ToString()
        Else
            lblBed.Text = ""
        End If


        If Not IsDBNull(dsData.Tables(0).Rows(0)("ClinicalHistoryNotes")) Then
            lblClinicalHistory.Text = dsData.Tables(0).Rows(0)("ClinicalHistoryNotes").ToString().Replace(vbCrLf.ToString(), "<br />")
        Else
            lblClinicalHistory.Text = ""
        End If


        If Not IsDBNull(dsData.Tables(0).Rows(0)("ProcedureType")) Then
            lblProcedureType.Text = dsData.Tables(0).Rows(0)("ProcedureType").ToString()
        Else
            lblProcedureType.Text = ""
        End If

        If Not IsDBNull(dsData.Tables(0).Rows(0)("Priority")) Then
            lblPriority.Text = dsData.Tables(0).Rows(0)("Priority").ToString()
        Else
            lblPriority.Text = ""
        End If

        If Not IsDBNull(dsData.Tables(0).Rows(0)("Status")) Then
            lblOrderStatus.Text = dsData.Tables(0).Rows(0)("Status").ToString()
        Else
            lblOrderStatus.Text = ""
        End If

        If Not IsDBNull(dsData.Tables(0).Rows(0)("RejectionReason")) Then
            lblRejectionReason.Text = dsData.Tables(0).Rows(0)("RejectionReason").ToString().Replace(vbCrLf.ToString(), "<br />")
        Else
            lblRejectionReason.Text = ""
        End If

        If Not IsDBNull(dsData.Tables(0).Rows(0)("RejectionComments")) Then
            lblRejectionComments.Text = dsData.Tables(0).Rows(0)("RejectionComments").ToString().Replace(vbCrLf.ToString(), "<br />")
        Else
            lblRejectionComments.Text = ""
        End If
#End Region

        rptQuestionsAnswers.DataSource = Nothing
        rptQuestionsAnswers.DataSource = dsData.Tables(1)
        rptQuestionsAnswers.DataBind()

        Dim dsPrevProcHistory As New DataSet
        dsPrevProcHistory = OrderCommsBL.GetPreviousProcedureListByPatientId(Convert.ToInt32(intPatientId))

        rptPrevHistory.DataSource = Nothing
        rptPrevHistory.DataSource = dsPrevProcHistory
        rptPrevHistory.DataBind()


    End Sub

End Class