Imports Telerik.Web.UI

Partial Class Products_Options_EditConsultants
    Inherits OptionsBase
    Private Shared ConsultantID As Integer = 0

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Not IsDBNull(Request.QueryString("ConsultantID")) AndAlso Request.QueryString("ConsultantID") <> "" Then
                ConsultantID = CInt(Request.QueryString("ConsultantID"))
                fillEditForm()
            Else
                ConsultantID = Nothing
            End If
        End If
    End Sub

    Private Sub fillEditForm()
        Dim db As New DataAccess
        Dim dt As DataTable = db.GetConsultants(ConsultantID) '.Rows(0)
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Dim dr As DataRow = dt.Rows(0)
            TitleTextBox.Text = CStr(dr("Title"))
            ForenameTextBox.Text = CStr(dr("ForeName"))
            InitialTextBox.Text = CStr(dr("Initial"))
            SurnameTextBox.Text = CStr(dr("Surname"))
            GMCCodeTextBox.Text = CStr(dr("GMCCode"))
            SpecialityDropDownList.SelectedValue = CStr(dr("GroupID"))
            EmailAddressTextBox.Text = CStr(dr("EmailAddress"))

            Dim allHospitals As Boolean = CBool(dr("AllHospitals"))
            HospitalRadListBox.DataBind()
            If allHospitals Then
                For Each item As RadListBoxItem In HospitalRadListBox.Items
                    item.Checked = True
                Next
            Else
                For Each dh As DataRow In db.GetConsultantsHospitalList(ConsultantID).Rows
                    Dim a As RadListBoxItem = HospitalRadListBox.Items.Where(Function(x) x.Value = CStr(dh("HospitalID"))).SingleOrDefault
                    If Not IsNothing(a) Then
                        a.Checked = True
                    End If
                Next
            End If
        End If
    End Sub
    Protected Sub SaveConsultant()
        Try
            Dim checkAllHospital As Boolean
            Dim checkHospitalList As String = ""
            Dim iSpeciality As String
            If HospitalRadListBox.CheckedItems.Count = HospitalRadListBox.Items.Count Then
                checkAllHospital = True
            Else
                checkAllHospital = False
                For Each item As RadListBoxItem In HospitalRadListBox.Items
                    If item.Checked Then
                        checkHospitalList = checkHospitalList & item.Value & "|"
                    End If
                Next
            End If

            'must choose one!
            If SpecialityDropDownList.SelectedValue <> "" Then
                iSpeciality = SpecialityDropDownList.SelectedValue
            Else
                Utilities.SetNotificationStyle(RadNotification1, "Must choose a specialty.", True)
                RadNotification1.Show()
                Exit Sub
            End If

            'check GMC code is unique
            If Not String.IsNullOrWhiteSpace(GMCCodeTextBox.Text) Then
                If DataAdapter.ConsultantGMCCodeExists(GMCCodeTextBox.Text, ConsultantID) Then
                    Utilities.SetNotificationStyle(RadNotification1, "The specified GMC Code is already in use.", True)
                    RadNotification1.Show()
                    Exit Sub
                End If
            End If

            Dim newId = DataAdapter.SaveConsultant(
                ConsultantID,
                TitleTextBox.Text,
                InitialTextBox.Text,
                ForenameTextBox.Text,
                SurnameTextBox.Text,
                EmailAddressTextBox.Text,
                iSpeciality,
                checkAllHospital,
                GMCCodeTextBox.Text,
                checkHospitalList)

            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
            If String.IsNullOrWhiteSpace(Request.QueryString("newprocedure")) Then
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)
            Else
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseEditWindow", "CloseEditWindow(" & newId & ");", True)
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving data.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveHospital()
        Try
            Dim newHospitalName As String = NewHospitalTextBox.Text
            If newHospitalName <> "" Then
                Dim db As New DataAccess
                db.SaveHospital(newHospitalName)
            End If
            HospitalsRadGrid.DataBind()
            HospitalRadListBox.DataBind()
            NewHospitalTextBox.Text = ""
            fillEditForm()
            HospitalsRadGrid.Items(HospitalsRadGrid.Items.Count - 1).Focus()
            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            'ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving data.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
    Protected Sub SuppressHospital()
        If HospitalsRadGrid.SelectedValues Is Nothing Then
            Return
        End If
        Dim HospitalID As String = CStr(HospitalsRadGrid.SelectedValues("HospitalID"))
        Dim Suppressed As Boolean = CBool(IIf(HospitalsRadGrid.SelectedValues("Suppressed") = "Yes", True, False))
        If HospitalID <> "" Then
            Dim db As New DataAccess
            db.SuppressHospital(HospitalID, Not Suppressed)
        End If
        HospitalsRadGrid.DataBind()
        HospitalRadListBox.DataBind()
        fillEditForm()
        SuppressRadButton.Enabled = False
    End Sub

    Protected Sub NewGroupRadButton_Click(sender As Object, e As EventArgs)
        Try
            Dim newGroupName As String = NewGroupTextBox.Text
            Dim newGroupCode As String = NewSpecialtyCodeRadTextBox.Text
            If newGroupName <> "" Then
                Dim db As New DataAccess
                If Not db.SpecialtyExists(newGroupName, newGroupCode) Then
                    db.SaveSpeciality(newGroupName, newGroupCode)
                Else
                    Utilities.SetNotificationStyle(RadNotification1, "Specialty and/or specialty code already exists.", True)
                    RadNotification1.Show()
                    Exit Sub
                End If
            End If
            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
            SpecialityDropDownList.DataBind()
            SpecialityDropDownList.SelectedValue = SpecialityDropDownList.FindItemByText(newGroupName).Value
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving data.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
