Imports System.Windows
Imports Hl7.Fhir.Model

Public Class ASAStatus
    Inherits ProcedureControls
    Private patientId As Int32 = 0

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then

            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim procType As Integer = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
                'Added by rony tfs-4358
                If procType <> CInt(ProcedureType.Proctoscopy) Then
                    bindData()
                Else
                    ASAStatusHeader.Visible = False
                End If
            Else
                MessageBox.Show("Your session expired, please start procedure again..")
                Response.Redirect("~/Products/Default.aspx", False)
            End If

        End If
    End Sub

    Sub bindData()
        Try
            AsaStatusRadioButtonList.DataSource = DataAdapter.LoadASAStatuses()
            AsaStatusRadioButtonList.DataBind()

            Dim patientASAStatus = DataAdapter.GetPatientASAStatuses(patientId, Session(Constants.SESSION_PROCEDURE_ID))
            If patientASAStatus IsNot Nothing AndAlso patientASAStatus.Rows.Count > 0 Then
                AsaStatusRadioButtonList.SelectedValue = CInt(patientASAStatus.Rows(0)("ASAStatusId"))
            End If

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading ASA Statuses", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading ASA Statuses")
        End Try
    End Sub
End Class