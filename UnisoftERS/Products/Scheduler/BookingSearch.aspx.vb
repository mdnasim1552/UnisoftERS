Imports Telerik.Web.UI

Public Class BookingSearch
    Inherits PageBase

#Region "Properties"
    Private _dataAdapter As DataAccess = Nothing
    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataAdapter Is Nothing Then
                _dataAdapter = New DataAccess
            End If
            Return _dataAdapter
        End Get
    End Property

    Private _dataAdapter_Sch As DataAccess_Sch = Nothing
    Protected ReadOnly Property DataAdapter_Sch() As DataAccess_Sch
        Get
            If _dataAdapter_Sch Is Nothing Then
                _dataAdapter_Sch = New DataAccess_Sch
            End If
            Return _dataAdapter_Sch
        End Get
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            FindExistingBookingDiv.Visible = True
            FoundBookingResultsDiv.Visible = False

            BookingSearchCNNTextBox.Text = ""
            BookingSearchNHSNoTextBox.Text = ""
            BookingSearchSurnameTextBox.Text = ""
            BookingSearchForenameTextBox.Text = ""

            HealthServiceNameIdTd.InnerText = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " Number:"

        End If
    End Sub

    Protected Sub SearchExistingBookingButton_Click(sender As Object, e As EventArgs)
        If String.IsNullOrWhiteSpace(BookingSearchCNNTextBox.Text) And
           String.IsNullOrWhiteSpace(BookingSearchNHSNoTextBox.Text) And
           String.IsNullOrWhiteSpace(BookingSearchSurnameTextBox.Text) And
           String.IsNullOrWhiteSpace(BookingSearchForenameTextBox.Text) Then
            Utilities.SetNotificationStyle(RadNotification1, "Please enter at least 1 search term and try again", True)
            RadNotification1.Show()
            Exit Sub
        End If

        If (Not String.IsNullOrEmpty(BookingSearchSurnameTextBox.Text) And BookingSearchSurnameTextBox.Text.Length < 3) Or
           (Not String.IsNullOrEmpty(BookingSearchForenameTextBox.Text) And BookingSearchForenameTextBox.Text.Length < 3) Then
            Utilities.SetNotificationStyle(RadNotification1, "Please enter at least a 3 character search term and try again", True)
            RadNotification1.Show()
            Exit Sub
        End If

        Dim bookingsDT = DataAdapter_Sch.SearchPatientForBookings(BookingSearchCNNTextBox.Text, BookingSearchNHSNoTextBox.Text, BookingSearchSurnameTextBox.Text, BookingSearchForenameTextBox.Text)
        Try
            If bookingsDT IsNot Nothing AndAlso bookingsDT.Rows.Count > 0 Then
                'If bookingsDT.Rows.Count = 1 Then
                '    Dim bookingRow = bookingsDT.Rows(0)
                '    Dim operatingHospitalId = CInt(bookingRow("HospitalId"))
                '    Dim roomId = CInt(bookingRow("RoomId"))
                '    Dim bookingDate = CDate(bookingRow("StartDateTime"))

                '    goToPatientBooking(operatingHospitalId, roomId, bookingDate)
                'Else
                'show a list of patients and bookings in a grid
                FoundBookingsRadGrid.DataSource = bookingsDT
                FoundBookingsRadGrid.DataBind()

                FoundBookingResultsDiv.Visible = True
                FindExistingBookingDiv.Visible = False
                'End If
            Else
                'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-window", "closeSearchBookingWindow();", True)

                'notification
                Utilities.SetNotificationStyle(RadNotification1, "No bookings found", False)
                RadNotification1.Show()
            End If

        Catch ex As Exception
            'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-window", "closeSearchBookingWindow();", True)

            Dim errRef = LogManager.LogManagerInstance.LogError("An error occured while searching for existing bookings", ex)
            'notification
            Utilities.SetErrorNotificationStyle(RadNotification1, errRef, "There was an error searching for bookings")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub FoundBookingsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        If e.CommandName.ToLower = "selectbooking" Then
            Dim RoomID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoomId")
            Dim HospitalID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("HospitalId")
            Dim bookingDate = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("StartDateTime")
            Dim appointmentId = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("AppointmentId")

            goToPatientBooking(HospitalID, RoomID, bookingDate, appointmentId)
        End If
    End Sub

    Private Sub goToPatientBooking(operatingHospitalId As Integer, roomId As Integer, bookingdate As DateTime, AppointmentId As Integer)

        Session("BookedDate") = bookingdate
        Session("BookedHospitalId") = operatingHospitalId
        Session("BookedRoom") = roomId
        Session("BookedAppointmentId") = AppointmentId

        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "booking-found", "CloseAndRebind();", True)
    End Sub

End Class