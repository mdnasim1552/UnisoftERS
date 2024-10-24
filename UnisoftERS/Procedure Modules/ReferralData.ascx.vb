Public Class ReferralData
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            loadReferralData()
            Dim procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If procType = CInt(ProcedureType.EBUS) Or procType = CInt(ProcedureType.Bronchoscopy) Then
                DateOfReferall.Visible = False
                blankRowAfterReferal.Visible = False
                CTScanAvailableCheckBox.Text = "PET scan available prior to EBUS"
            Else
                blankRowAfterReferal.Visible = True
            End If
        End If
    End Sub

    Private Sub loadReferralData()
        Try
            Dim da As New DataAccess
            Dim dt = da.getProcedureReferralData(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)

                If Not dr.IsNull("DateBronchRequested") Then DateBronchRequestedDatePicker.SelectedDate = CDate(dr("DateBronchRequested"))
                If Not dr.IsNull("DateOfReferral") Then DateOfReferralDatePicker.SelectedDate = CDate(dr("DateOfReferral"))
                If Not dr.IsNull("LCaSuspectedBySpecialist") Then LCaSuspectedBySpecialistCheckBox.Checked = CBool(dr("LCaSuspectedBySpecialist"))
                If Not dr.IsNull("CTScanAvailable") Then CTScanAvailableCheckBox.Checked = CBool(dr("CTScanAvailable"))
                If Not dr.IsNull("DateOfScan") Then DateOfScanDatePicker.SelectedDate = CDate(dr("DateOfScan"))
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading referral data", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading referral data")
            RadNotification1.Show()
        End Try
    End Sub
End Class