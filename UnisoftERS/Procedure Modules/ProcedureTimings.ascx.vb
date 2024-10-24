Imports Telerik.Web.UI

Public Class ProcedureTimings
    Inherits System.Web.UI.UserControl
    Public Shared procType As Integer
    Public Shared endoscopistID As Integer
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If procType = CInt(ProcedureType.Gastroscopy) Or procType = CInt(ProcedureType.Antegrade) Or procType = CInt(ProcedureType.Transnasal) Then  'removed ERUS by Ferdowsi , TFS 4077
                WithdrawalUpper.Visible = True
            ElseIf procType = CInt(ProcedureType.Colonoscopy) Or procType = CInt(ProcedureType.Sigmoidscopy) Or procType = CInt(ProcedureType.Retrograde) Then
                WithdrawalLower.Visible = True
            End If
            loadProcedureTimings()
        End If
    End Sub

    Private Sub loadProcedureTimings()
        Try
            ProcedureStartDateRadTimeInput.SelectedDate = DateTime.Parse(Session(Constants.SESSION_PROCEDURE_DATE))
            ProcedureEndDateRadTimeInput.SelectedDate = DateTime.Parse(Session(Constants.SESSION_PROCEDURE_DATE))

            Dim da As New DataAccess
            Dim dt = da.GetProcedureTimings(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dt.Rows.Count > 0 Then
                Dim dr = dt.Rows(0)
                If Not dr.IsNull("StartDateTime") Then
                    ProcedureStartDateRadTimeInput.SelectedDate = DateTime.Parse(dr("StartDateTime"))
                    ProcedureStartRadTimePicker.SelectedTime = DateTime.Parse(dr("StartDateTime")).TimeOfDay
                End If

                If Not dr.IsNull("EndDateTime") Then
                    ProcedureEndDateRadTimeInput.SelectedDate = DateTime.Parse(dr("EndDateTime"))
                    ProcedureEndRadTimePicker.SelectedTime = DateTime.Parse(dr("EndDateTime")).TimeOfDay
                End If

                If Not dr.IsNull("WithdrawalMins") Then TimeForWithdrawalMinRadNumericTextBox.Value = CInt(dr("WithdrawalMins"))
                If Not dr.IsNull("CaecumIntubationStart") Then
                    CaecumStartDateRadTimeInput.SelectedDate = CDate(dr("CaecumIntubationStart"))
                    CaecumTimeRadTimePicker.SelectedTime = CDate(dr("CaecumIntubationStart")).TimeOfDay
                End If
                If Not dr.IsNull("UpperWithdrawalMins") Then
                    'added BY FERDOWSI TFS -4160
                    Dim withdrawalMins As Integer = CInt(dr("UpperWithdrawalMins"))
                    If withdrawalMins > 120 Then
                        withdrawalMins = 120
                    End If

                    TimeForUpperWithdrawalMinRadNumericTextBox.Value = withdrawalMins
                Else
                    TimeForUpperWithdrawalMinRadNumericTextBox.Value = Nothing
                End If
            End If

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading procedure timings", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading procedure timings")



            RadNotification1.Show()
        End Try
    End Sub
End Class


