Imports Telerik.Web.UI

Public Class CancelledScheduleList


    Inherits PageBase
    ReadOnly Property DiaryDate As DateTime
        Get
            Return CDate(Request.QueryString("DiaryDate"))
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Page.IsPostBack Then
            CancelledDataBind()
        End If

    End Sub
    Protected Sub CancelledDataBind()
        Try
            CancelledScheduleListRadGrid.DataSource = DataAdapter_Sch.getCancelledScheduleList(DiaryDate)
            CancelledScheduleListRadGrid.DataBind()
        Catch ex As Exception
            Dim errorRef = LogManager.LogManagerInstance.LogError("An error occured loading booking cancellations", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, "An error occured loading booking cancellations")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelledScheduleListRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Try

            Dim bookingDetailsDT = DataAdapter_Sch.getCancelledScheculeListDetails(e.CommandArgument)
            If bookingDetailsDT.Rows.Count > 0 Then
                Dim dr = bookingDetailsDT.Rows(0)
                lblScheduleListCancellationDetails.Text = "Cancelled on " & dr("SuppressedFromDate") & " by " & dr("CancelledBy")
                lblCancellationReason.Text = dr("CancelReason")
                SlotAddedDate.Text = "Booked on " & dr("WhenCreated") & " by " & dr("CreatedBy")
                ScheduleListDate.Text = "Booked for " & dr("DiaryDate")
                'lblStartTime.Text = CDate(dr("DiaryStart"))
                'lblEndTime.Text = CDate(dr("DiaryEnd"))
                lblStartTime.Text = CDate(dr("DiaryStart")).ToString("HH:mm")
                lblEndTime.Text = CDate(dr("DiaryEnd")).ToString("HH:mm")
                lblRoomName.Text = dr("RoomName")
                lblListConsultant.Text = dr("ListConsultant")
                lblEndoscopistName.Text = dr("EndoscopistName")
                lblListName.Text = dr("ListName")
            End If
            ListSlot.DataSource = bookingDetailsDT
            ListSlot.DataBind()
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "show-cancelled-details", "ScheduleListDetails();", True)
        Catch ex As Exception
            Dim errorRef = LogManager.LogManagerInstance.LogError("An error occured trying to view cancelled booking details", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, "An error occured trying to view cancelled booking details")
            RadNotification1.Show()
        End Try
    End Sub


End Class