Imports System.Windows

Public Class Allergies
    Inherits ProcedureControls
    Private patientId As Int32 = 0
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
                loadPatientAllergies()
            Else
                MessageBox.Show("Your session expired, please start procedure again..")
                Response.Redirect("~/Products/Default.aspx", False)
            End If
        End If
    End Sub

    Private Sub loadPatientAllergies()
        Try
            Dim patientAllergy = DataAdapter.GetPatientAllergies(patientId, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If patientAllergy.Rows.Count > 0 Then
                Dim dr As DataRow = patientAllergy.Rows(0)

                AllergyRadioButtonList.SelectedValue = dr("AllergyResult")
                If Not String.IsNullOrWhiteSpace(dr("AllergyDescription")) Then
                    AllergyDescTextBox.Text = dr("AllergyDescription")
                    ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "toggle-description-view", "ToggleAllergyDescTextBox();", True)
                End If
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading patients allergies", ex)
        End Try
    End Sub
End Class