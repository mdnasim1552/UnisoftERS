Imports System.Windows
Imports Telerik.Web.UI

Public Class PreviousSurgery
    Inherits ProcedureControls

    Private Shared procType As Integer
    Private patientId As Int32 = 0

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
                loadPreviousSurgeryControls()
            Else
                MessageBox.Show("Your session expired, please start procedure again..")
                Response.Redirect("~/Products/Default.aspx", False)
            End If
        End If
    End Sub

    Private Sub loadPreviousSurgeryControls()
        Try
            PreviousSurgeryComboBox.DataSource = DataAdapter.LoadPreviousSurgeries(procType)
            PreviousSurgeryComboBox.DataBind()

            'PreviousSurgeryComboBox.Items.Insert(0, New RadComboBoxItem("", 0))

            If (Session("CanEditDropdowns")) Then
                PreviousSurgeryComboBox.Items.Add(New RadComboBoxItem() With {
                            .Text = "Add new",
                            .Value = -55,
                            .ImageUrl = "~/images/icons/add.png",
                            .CssClass = "comboNewItem"
                            })
                PreviousSurgeryComboBox.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & PreviousSurgeryComboBox.ClientID & ",true); } else { window.parent.AddNewItemPopUp(" & PreviousSurgeryComboBox.ClientID & ",true);" & " }")
            End If

            PreviousSurgeryComboBox.Sort = RadComboBoxSort.Ascending

            'get saved history data and set selected indexes 

            Dim patientPreviousSurgery = DataAdapter.getPatientPreviousSurgery(patientId)
            If patientPreviousSurgery.Rows.Count > 0 Then
                For i As Integer = 0 To patientPreviousSurgery.Rows.Count - 1
                    Dim drugId = patientPreviousSurgery(i)("PreviousSurgeryId")
                    If Not PreviousSurgeryComboBox.FindItemByValue(drugId) Is Nothing Then
                        PreviousSurgeryComboBox.FindItemByValue(drugId).Checked = True
                    End If
                Next
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading relevant follow-up procedures", ex)
        End Try
    End Sub
End Class