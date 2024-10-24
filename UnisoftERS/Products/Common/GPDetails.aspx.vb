Imports Telerik.Web.UI

Partial Class Products_Common_GPDetails
    Inherits PageBase

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Not String.IsNullOrWhiteSpace(Request.QueryString("searchstr")) Then
                ControlsRadPane.Visible = False
                GPListRadPane.Visible = True
                populateResults(Request.QueryString("searchstr"), Request.QueryString("searchval"))
            Else
                ControlsRadPane.Visible = True
                GPListRadPane.Visible = False
                If Session("GPSelectedValue") IsNot Nothing Then
                    PopulateData(CInt(Session("GPSelectedValue")))
                Else
                    PopulateData()
                End If
            End If
        End If
    End Sub

    Private Sub populateResults(searchTerm As String, searchType As String)
        GPResultsGrid.DataSource = DataAdapter.SearchGP(searchTerm, searchType)
        GPResultsGrid.DataBind()
    End Sub

    Private Sub PopulateData(Optional ByVal gpId As Integer = 0)
        If gpId > 0 Then
            Dim dtGP As DataTable = DataAdapter.GetGP(gpId)
            If dtGP.Rows.Count > 0 Then
                EditGPTitleTextBox.Text = dtGP.Rows(0)("Title")
                EditGPInitialsTextBox.Text = dtGP.Rows(0)("Initials")
                EditGPForeNameTextBox.Text = dtGP.Rows(0)("Forename")
                EditGPSurnameTextBox.Text = dtGP.Rows(0)("Surname")
                EditGPPracticeNameTextBox.Text = dtGP.Rows(0)("PracticeName")
                EditGPAddressTextBox.Text = dtGP.Rows(0)("Address")
                EditGPTelephoneTextBox.Text = dtGP.Rows(0)("Telephone")
                EditGPSuppressedCheckBox.Checked = CBool(dtGP.Rows(0)("Suppressed"))
            End If
        Else
            EditGPTitleTextBox.Text = ""
            EditGPInitialsTextBox.Text = ""
            EditGPForeNameTextBox.Text = ""
            EditGPSurnameTextBox.Text = ""
            EditGPPracticeNameTextBox.Text = ""
            EditGPAddressTextBox.Text = ""
            EditGPTelephoneTextBox.Text = ""
            EditGPSuppressedCheckBox.Checked = False
        End If
    End Sub

    Protected Sub SaveGPButton_Click(sender As Object, e As EventArgs) Handles SaveGPButton.Click
        'Utilities.SetNotificationStyle(GPSaveCallBackNotification)
        'GPSaveCallBackNotification.Show()

        'Utilities.SetNotificationStyle(Parent.FindControl("RadNotification1"))
        'DirectCast(Parent.FindControl("RadNotification1"), RadNotification).Show()
        Try
            Session("GPSelectedValue") =
                DataAdapter.SaveGP(Nothing,
                                    EditGPTitleTextBox.Text,
                                    EditGPInitialsTextBox.Text,
                                    EditGPForeNameTextBox.Text,
                                    EditGPSurnameTextBox.Text,
                                    EditGPPracticeNameTextBox.Text,
                                    EditGPAddressTextBox.Text,
                                    EditGPTelephoneTextBox.Text,
                                    EditGPSuppressedCheckBox.Checked)

            Utilities.SetNotificationStyle(GPSaveCallBackNotification)
            GPSaveCallBackNotification.Show()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving GP details.", ex)

            Utilities.SetErrorNotificationStyle(GPSaveCallBackNotification, errorLogRef, "There is a problem saving data.")
            GPSaveCallBackNotification.Show()
        End Try
    End Sub

    Protected Sub GPResultsGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Session("GPSelectedValue") = CInt(CType(e.Item, GridDataItem).GetDataKeyValue("GPId"))
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType, "SaveAndCloseGPSeearch", "CloseWindow();", True)
    End Sub
End Class
