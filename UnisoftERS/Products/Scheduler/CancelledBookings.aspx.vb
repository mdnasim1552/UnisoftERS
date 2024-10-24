Imports Telerik.Web.UI

Public Class CancelledBookings
    Inherits PageBase

    ReadOnly Property DiaryId As Integer
        Get
            Return CInt(Request.QueryString("diaryId"))
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            populateGrid()
        End If
    End Sub

    Private Sub populateGrid()
        Try
            CancelledBookingsRadGrid.DataSource = DataAdapter_Sch.getCancelledBookings(DiaryId)
            CancelledBookingsRadGrid.DataBind()

        Catch ex As Exception
            Dim errorRef = LogManager.LogManagerInstance.LogError("An error occured loading booking cancellations", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, "An error occured loading booking cancellations")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelledBookingsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        If String.IsNullOrWhiteSpace(e.CommandArgument) Then
            Dim errorRef = LogManager.LogManagerInstance.LogError("An error occured trying to view cancelled booking details", New Exception("AppointmentId command argument not set"))
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef)
            RadNotification1.Show()
            Exit Sub
        End If

        Try
            Dim bookingDetailsDT = DataAdapter_Sch.getCancelledBookingDetails(e.CommandArgument)
            If bookingDetailsDT.Rows.Count > 0 Then
                Dim dr = bookingDetailsDT.Rows(0)

                lblPatientName.Text = dr("PatientName")
                lblPatientDOB.Text = CDate(dr("DateOfBirth")).ToShortDateString
                lblPatientCNN.Text = dr("HospitalNumber")
                lblPatientGender.Text = dr("Gender")
                lblEndoscopist.Text = dr("Endoscopist")
                lblBookingAuditDetails.Text = "Booked on " & dr("DateEntered") & " by " & dr("BookedBy")
                lblBookingScheduledDetails.Text = CDate(dr("BookingDate")).ToLongDateString & " in " & dr("RoomName")
                lblCallInTime.Text = CDate(dr("DueArrivalTime")).ToShortTimeString
                lblStartTime.Text = CDate(dr("BookingDate")).ToShortTimeString
                lblSlotLength.Text = dr("AppointmentDuration")
                lblPatientStatus.Text = dr("PatientSlotStatus")
                lblPatientNotes.Text = dr("Notes")
                lblBookingCancellationDetails.Text = "Cancelled on " & dr("DateCancelled") & " by " & dr("CancelledBy")
                lblCancellationReason.Text = dr("Reason")
                lblProcedure.Text = dr("ProcedureType")
            End If

            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "show-cancelled-details", "showCancelledBookingDetails();", True)
        Catch ex As Exception
            Dim errorRef = LogManager.LogManagerInstance.LogError("An error occured trying to view cancelled booking details", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, "An error occured trying to view cancelled booking details")
            RadNotification1.Show()
        End Try
    End Sub
End Class