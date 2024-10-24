Imports Telerik.Web.UI
Public Class PatientDetails
    Inherits System.Web.UI.UserControl

    Private DataAdapter As New DataAccess
    Dim dtStaffEndoDetails As DataTable

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        NHSNoAvailableLabel.Text = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " no: "

        If Not IsPostBack AndAlso Not CBool(Session("isERSViewer")) Then
            LoadPatientInfo()
            'LoadStaffDefaults()
            LoadStaffLabels()
            LoadStaffEditForm()
        End If
        Dim myAjaxMgr3 As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        'myAjaxMgr3.AjaxSettings.AddAjaxSetting(SaveStaffButton, Me)
        myAjaxMgr3.AjaxSettings.AddAjaxSetting(SaveStaffButton, StaffTable)
        myAjaxMgr3.AjaxSettings.AddAjaxSetting(SaveStaffButton, EditStaffWindow)
        myAjaxMgr3.AjaxSettings.AddAjaxSetting(SaveStaffButton, SaveStaffButton)

    End Sub

    Protected Sub LoadPatientInfo()
        PatientName.Text = Session("PatSurname") & ", " & Session("PatForename") & " (" & Session("PatGender") & ")"
        CNN.Text = Session(Constants.SESSION_CASE_NOTE_NO)
        NHSNo.Text = Utilities.FormatHealthServiceNumber(Session("PatNHS"))
        If Not IsNothing(Session("PatDOB")) AndAlso Session("PatDOB").ToString().Trim() <> "" Then
            DOB.Text = Session("PatDOB") & " (" & Utilities.GetAgeAtDate(CDate(Session("PatDOB")), CDate(Session(Constants.SESSION_PROCEDURE_DATE))) & ")"
        Else
            DOB.Text = ""
        End If

        RecCreated.Text = Session("PatCreated")
    End Sub

    Public Sub LoadStaffLabels()
        Dim listconsultant As String = ""
        Dim endoscopists As String = ""
        Dim nurses As String = ""
        Dim da As New DataAccess
        dtStaffEndoDetails = da.GetProcedureDetails(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

        If dtStaffEndoDetails IsNot Nothing AndAlso dtStaffEndoDetails.Rows.Count > 0 Then
            Dim rw As DataRow = dtStaffEndoDetails.Rows(0)
            If rw IsNot Nothing Then
                If Not IsDBNull(rw("ListConsultantName")) AndAlso rw("ListConsultantName") IsNot Nothing Then
                    listconsultant = rw("ListConsultantName")
                    Session(Constants.SESSION_LISTCON) = rw("ListConsultant")
                    Session(Constants.SESSION_LISTCON_TEXT) = rw("ListConsultantName")
                End If

                If Not IsDBNull(rw("Endoscopist1Name")) AndAlso rw("Endoscopist1Name") IsNot Nothing Then
                    endoscopists = rw("Endoscopist1Name")
                    Session(Constants.SESSION_ENDO1) = rw("Endoscopist1")
                    Session(Constants.SESSION_ENDO1_TEXT) = rw("Endoscopist1Name")
                    Session("EndoRole") = rw("Endo1Role")
                End If
                If Not IsDBNull(rw("Endoscopist2Name")) AndAlso rw("Endoscopist2Name") IsNot Nothing Then
                    If endoscopists <> "" AndAlso rw("Endoscopist1") <> rw("Endoscopist2") Then
                        endoscopists = endoscopists & ", " & rw("Endoscopist2Name")
                    Else
                        endoscopists = rw("Endoscopist2Name")
                    End If
                    Session(Constants.SESSION_ENDO2) = rw("Endoscopist2")
                    Session(Constants.SESSION_ENDO2_TEXT) = rw("Endoscopist2Name")
                End If
                If Not IsDBNull(rw("Nurse1Name")) AndAlso rw("Nurse1Name") IsNot Nothing Then
                    nurses = rw("Nurse1Name")
                    Session(Constants.SESSION_NURSE1) = rw("Nurse1")
                    Session(Constants.SESSION_NURSE1_TEXT) = rw("Nurse1Name")
                End If
                If Not IsDBNull(rw("Nurse2Name")) AndAlso rw("Nurse2Name") IsNot Nothing Then
                    If Not String.IsNullOrEmpty(rw("Nurse1Name").ToString()) Then
                        If nurses <> "" AndAlso rw("Nurse1") <> rw("Nurse2") Then
                            nurses = nurses & ", " & rw("Nurse2Name")
                        Else
                            nurses = rw("Nurse2Name")
                        End If
                    Else
                        nurses = rw("Nurse2Name")
                    End If
                    Session(Constants.SESSION_NURSE2) = rw("Nurse2")
                    Session(Constants.SESSION_NURSE2_TEXT) = rw("Nurse2Name")
                End If
                If Not IsDBNull(rw("Nurse3Name")) AndAlso rw("Nurse3Name") IsNot Nothing Then
                    If Not String.IsNullOrEmpty(rw("Nurse2Name").ToString()) Then
                        If nurses <> "" Then
                            If (rw("Nurse1") <> rw("Nurse3") AndAlso rw("Nurse2") <> rw("Nurse3")) Then nurses = nurses & ", " & rw("Nurse3Name")
                        Else
                            nurses = rw("Nurse3Name")
                        End If
                        Session(Constants.SESSION_NURSE3) = rw("Nurse3")
                        Session(Constants.SESSION_NURSE3_TEXT) = rw("Nurse3Name")
                    Else
                        If Not String.IsNullOrEmpty(rw("Nurse1Name").ToString()) Then
                            If nurses <> "" Then
                                If rw("Nurse1") <> rw("Nurse3") Then nurses = nurses & ", " & rw("Nurse3Name")
                            Else
                                nurses = rw("Nurse3Name")
                            End If
                        Else
                            nurses = rw("Nurse3Name")
                        End If
                        Session(Constants.SESSION_NURSE3) = rw("Nurse3")
                        Session(Constants.SESSION_NURSE3_TEXT) = rw("Nurse3Name")

                    End If
                End If
                If Not IsDBNull(rw("Nurse4Name")) AndAlso rw("Nurse4Name") IsNot Nothing Then
                    If Not String.IsNullOrEmpty(rw("Nurse3Name").ToString()) Then
                        If nurses <> "" Then
                            If (rw("Nurse1") <> rw("Nurse4") AndAlso rw("Nurse2") <> rw("Nurse4") AndAlso rw("Nurse3") <> rw("Nurse4")) Then nurses = nurses & ", " & rw("Nurse4Name")
                        Else
                            nurses = rw("Nurse4Name")
                        End If
                        Session(Constants.SESSION_NURSE4) = rw("Nurse4")
                        Session(Constants.SESSION_NURSE4_TEXT) = rw("Nurse4Name")
                    Else
                        If Not String.IsNullOrEmpty(rw("Nurse1Name").ToString()) Then
                            If nurses <> "" Then
                                If rw("Nurse1") <> rw("Nurse4") Then nurses = nurses & ", " & rw("Nurse4Name")
                            Else
                                nurses = rw("Nurse4Name")
                            End If
                        Else
                            nurses = rw("Nurse4Name")
                        End If
                        Session(Constants.SESSION_NURSE4) = rw("Nurse4")
                        Session(Constants.SESSION_NURSE4_TEXT) = rw("Nurse4Name")

                    End If
                End If
            End If
        End If

        If Not String.IsNullOrEmpty(listconsultant) Then
            ListConsultantLabel.Text = listconsultant
        Else
            ListConsultantLabel.Text = "Not Specified"
        End If
        If Not String.IsNullOrEmpty(endoscopists) Then
            EndoscopistsLabel.Text = endoscopists
        Else
            EndoscopistsLabel.Text = "Not Specified"
        End If
        If Not String.IsNullOrEmpty(nurses) Then
            NursesLabel.Text = nurses
        Else
            NursesLabel.Text = "Not Specified"
        End If
    End Sub
    Protected Sub SaveStaffButton_Click(sender As Object, e As EventArgs)
        Try
            Dim da As DataAccess = New DataAccess()
            Dim ImagePortId As Integer = ImagePortComboBox.SelectedValue
            If (ImagePortId <> Session("PortId")) Then
                Session("PortId") = ImagePortComboBox.SelectedValue
                Session("PortName") = da.ImagePortName(Session("PortId"))
            End If

            Dim recordUpdated As Integer = da.UpdateProcedureStaff(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                    IIf(ListTypeComboBox.SelectedValue = "", 0, ListTypeComboBox.SelectedValue),
                                    IIf(ListConsultantComboBox.SelectedValue = "", 0, ListConsultantComboBox.SelectedValue),
                                    IIf(Endo1ComboBox.SelectedValue = "", 0, Endo1ComboBox.SelectedValue),
                                    IIf(Endo1RoleComboBox.SelectedValue = "", 0, Endo1RoleComboBox.SelectedValue),
                                    IIf(Endo2ComboBox.SelectedValue = "", 0, Endo2ComboBox.SelectedValue),
                                    IIf(Endo2RoleComboBox.SelectedValue = "", 0, Endo2RoleComboBox.SelectedValue),
                                    IIf(Nurse1ComboBox.SelectedValue = "", 0, Nurse1ComboBox.SelectedValue),
                                    IIf(Nurse2ComboBox.SelectedValue = "", 0, Nurse2ComboBox.SelectedValue),
                                    IIf(Nurse3ComboBox.SelectedValue = "", 0, Nurse3ComboBox.SelectedValue),
                                    IIf(Nurse4ComboBox.SelectedValue = "", 0, Nurse4ComboBox.SelectedValue),
                                    ImagePortId,
                                    ServiceProviderRadComboBox.SelectedValue,
                                    OtherProviderRadTextBox.Text,
                                    ReferralTypeRadComboBox.SelectedValue,
                                    OtherReferrerTypeTextBox.Text,
                                    If(Utilities.GetInt(HospitalComboBox.SelectedValue), 0),
                                    If(Utilities.GetInt(ConsultantComboBox.Value), 0),
                                    If(Utilities.GetInt(SpecialityRadComboBox.SelectedValue), 0),
                                    If(Utilities.GetInt(PatStatusRadioButtonList.SelectedValue), 0),
                                    If(Utilities.GetInt(WardComboBox.SelectedValue), 0),
                                    If(Utilities.GetInt(PatientTypeRadioButtonList.SelectedValue), 0),
                                    Convert.ToInt32(CategoryRadComboBox.SelectedValue))

            Session(Constants.SESSION_LISTCON) = ""
            Session(Constants.SESSION_LISTCON_TEXT) = ""
            Session(Constants.SESSION_ENDO1) = ""
            Session(Constants.SESSION_ENDO1_TEXT) = ""
            Session(Constants.SESSION_ENDO2) = ""
            Session(Constants.SESSION_ENDO2_TEXT) = ""
            Session(Constants.SESSION_NURSE1) = ""
            Session(Constants.SESSION_NURSE1_TEXT) = ""
            Session(Constants.SESSION_NURSE2) = ""
            Session(Constants.SESSION_NURSE2_TEXT) = ""
            Session(Constants.SESSION_NURSE3) = ""
            Session(Constants.SESSION_NURSE3_TEXT) = ""
            Session(Constants.SESSION_NURSE4) = ""
            Session(Constants.SESSION_NURSE4_TEXT) = ""
            Session("EndoRole") = ""

            If ListConsultantComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_LISTCON) = ListConsultantComboBox.SelectedValue
                Session(Constants.SESSION_LISTCON_TEXT) = ListConsultantComboBox.SelectedItem.Text
            End If
            If Endo1ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_ENDO1) = Endo1ComboBox.SelectedValue
                Session(Constants.SESSION_ENDO1_TEXT) = Endo1ComboBox.SelectedItem.Text
                Session("EndoRole") = Endo1RoleComboBox.SelectedValue
            End If
            If Endo2ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_ENDO2) = Endo2ComboBox.SelectedValue
                Session(Constants.SESSION_ENDO2_TEXT) = Endo2ComboBox.SelectedItem.Text
            End If
            If Nurse1ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_NURSE1) = Nurse1ComboBox.SelectedValue
                Session(Constants.SESSION_NURSE1_TEXT) = Nurse1ComboBox.SelectedItem.Text
            End If
            If Nurse2ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_NURSE2) = Nurse2ComboBox.SelectedValue
                Session(Constants.SESSION_NURSE2_TEXT) = Nurse2ComboBox.SelectedItem.Text
            End If
            If Nurse3ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_NURSE3) = Nurse3ComboBox.SelectedValue
                Session(Constants.SESSION_NURSE3_TEXT) = Nurse3ComboBox.SelectedItem.Text
            End If
            If Nurse4ComboBox.SelectedIndex <> 0 Then
                Session(Constants.SESSION_NURSE4) = Nurse4ComboBox.SelectedValue
                Session(Constants.SESSION_NURSE4_TEXT) = Nurse4ComboBox.SelectedItem.Text
            End If

            LoadStaffLabels()
            LoadStaffEditForm()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while updating procedure staff.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Public Sub LoadStaffEditForm()

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ImagePortComboBox, ""}}, DataAdapter.GetAvailableImagePortsForRoom(Session("RoomId")), "FriendlyName", "ImagePortId")

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ServiceProviderRadComboBox, ""}}, DataAdapter.GetProviderOrganisations, "Description", "UniqueId")

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ReferralTypeRadComboBox, ""}}, DataAdapter.GetReferralOptions(0), "Description", "UniqueId")

        With ConsultantComboBox
            .Items.Clear()
            .DataSource = DataAdapter.GetConsultantsLst("", "", 0)
            .DataBind()
        End With

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalComboBox, ""}}, DataAdapter.GetHospitalsLst(String.Empty, 0), "HospitalName", "HospitalID")

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{SpecialityRadComboBox, ""}}, DataAdapter.GetSpeciality, "GroupName", "GroupID")

        Utilities.LoadRadioButtonList(PatStatusRadioButtonList, DataAdapter.GetPatientStatuses(), "ListItemText", "ListItemNo")

        Utilities.LoadRadioButtonList(PatientTypeRadioButtonList, DataAdapter.LoadProviders(), "Description", "UniqueId")

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{WardComboBox, ""}}, DataAdapter.GetPatientWards, "WardDescription", "WardId")
        WardComboBox.Items.Insert(0, New RadComboBoxItem(""))

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{CategoryRadComboBox, ""}}, DataAdapter.LoadProcedureCategories, "Description", "UniqueId")

        LoadConsultantByType(ListConsultantComboBox, Staff.ListConsultant)
        LoadConsultantByType(Endo1ComboBox, Staff.EndoScopist1)
        LoadConsultantByType(Endo2ComboBox, Staff.EndoScopist2)
        LoadConsultantByType(Nurse1ComboBox, Staff.Nurse1)
        LoadConsultantByType(Nurse2ComboBox, Staff.Nurse2)
        LoadConsultantByType(Nurse3ComboBox, Staff.Nurse3)
        LoadConsultantByType(Nurse4ComboBox, Staff.Nurse4)

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                {ListTypeComboBox, "List Type"},
                {Endo1RoleComboBox, "Endoscopist1 Role"},
                {Endo2RoleComboBox, "Endoscopist2 Role"}
          })

        If dtStaffEndoDetails IsNot Nothing AndAlso dtStaffEndoDetails.Rows.Count > 0 Then
            Dim rw As DataRow = dtStaffEndoDetails.Rows(0)

            If Not IsDBNull(rw("ListType")) Then
                DropBoxSetSelectedOrDefaultValue(ListTypeComboBox, CInt(rw("ListType")))
            End If

            If Not IsDBNull(rw("ListConsultant")) AndAlso rw("ListConsultant") IsNot Nothing Then
                DropBoxSetSelectedOrDefaultValue(ListConsultantComboBox, CInt(rw("ListConsultant")))
            End If
            If Not IsDBNull(rw("ListConsultant")) AndAlso Not String.IsNullOrWhiteSpace(rw("ListConsultantGMCCode")) Then
                ListConsultantGMCHiddenField.Value = rw("ListConsultantGMCCode")
            End If
            If Not IsDBNull(rw("Endoscopist1")) AndAlso rw("Endoscopist1") IsNot Nothing Then
                DropBoxSetSelectedOrDefaultValue(Endo1ComboBox, CInt(rw("Endoscopist1")))

                If Not String.IsNullOrWhiteSpace(rw("Endoscopist1GMCCode")) Then
                    Endo1GMCHiddenField.Value = rw("Endoscopist1GMCCode")
                End If
            End If
            If Not IsDBNull(rw("Endo1Role")) AndAlso rw("Endo1Role") IsNot Nothing Then
                DropBoxSetSelectedOrDefaultValue(Endo1RoleComboBox, CInt(rw("Endo1Role")))
            End If
            If Not IsDBNull(rw("Endoscopist2")) AndAlso rw("Endoscopist2") IsNot Nothing Then
                DropBoxSetSelectedOrDefaultValue(Endo2ComboBox, CInt(rw("Endoscopist2")))

                If Not IsDBNull(rw("Endoscopist2GMCCode")) Then
                    Endo2GMCHiddenField.Value = rw("Endoscopist2GMCCode")
                End If
            End If
            If Not IsDBNull(rw("Endo2Role")) AndAlso rw("Endo2Role") IsNot Nothing Then
                DropBoxSetSelectedOrDefaultValue(Endo2RoleComboBox, CInt(rw("Endo2Role")))
            End If

            If Not IsDBNull(rw("Nurse1")) AndAlso rw("Nurse1") IsNot Nothing Then
                DropBoxSetSelectedOrDefaultValue(Nurse1ComboBox, CInt(rw("Nurse1")))
            End If
            If Not IsDBNull(rw("Nurse2")) AndAlso rw("Nurse2") IsNot Nothing Then
                DropBoxSetSelectedOrDefaultValue(Nurse2ComboBox, CInt(rw("Nurse2")))
            End If
            If Not IsDBNull(rw("Nurse3")) AndAlso rw("Nurse3") IsNot Nothing Then
                DropBoxSetSelectedOrDefaultValue(Nurse3ComboBox, CInt(rw("Nurse3")))
            End If
            If Not IsDBNull(rw("Nurse4")) AndAlso rw("Nurse4") IsNot Nothing Then
                DropBoxSetSelectedOrDefaultValue(Nurse4ComboBox, CInt(rw("Nurse4")))
            End If

            If (Endo1ComboBox.SelectedValue <> "" And Endo2ComboBox.SelectedValue <> "") AndAlso
            (Endo1ComboBox.SelectedValue > 0 And Endo2ComboBox.SelectedValue > 0 And Endo1ComboBox.SelectedValue <> Endo2ComboBox.SelectedValue) Then
                Endoscopist1Label.Text = "TrainER:"
                Endoscopist2Label.Text = "TrainEE:"
            End If

            If Not IsDBNull(rw("ImagePortId")) Then
                DropBoxSetSelectedOrDefaultValue(ImagePortComboBox, CInt(rw("ImagePortId")))
            End If

            If Not IsDBNull(rw("ProviderTypeId")) Then
                DropBoxSetSelectedOrDefaultValue(ServiceProviderRadComboBox, CInt(rw("ProviderTypeId")))
            End If

            If Not IsDBNull(rw("ProviderOther")) AndAlso Not String.IsNullOrEmpty(rw("ProviderOther")) Then
                OtherProviderRadTextBox.Text = rw("ProviderOther")
            End If

            If Not IsDBNull(rw("ReferrerType")) Then
                DropBoxSetSelectedOrDefaultValue(ReferralTypeRadComboBox, CInt(rw("ReferrerType")))
            End If

            If Not IsDBNull(rw("ReferrerTypeOther")) AndAlso Not String.IsNullOrEmpty(rw("ReferrerTypeOther")) Then
                OtherReferrerTypeTextBox.Text = rw("ReferrerTypeOther")
            End If

            If Not IsDBNull(rw("ReferralConsultantNo")) Then
                SelectReferralConsultantComboByConsultantID(CInt(rw("ReferralConsultantNo")))
            End If

            If Not IsDBNull(rw("ReferralConsultantSpeciality")) Then
                DropBoxSetSelectedOrDefaultValue(SpecialityRadComboBox, CInt(rw("ReferralConsultantSpeciality")))
            Else
                SpecialityRadComboBox.Items.Insert(0, New RadComboBoxItem(""))
                SpecialityRadComboBox.SelectedIndex = 0
            End If

            If Not IsDBNull(rw("ReferralHospitalNo")) Then
                DropBoxSetSelectedOrDefaultValue(HospitalComboBox, CInt(rw("ReferralHospitalNo")))
            Else
                HospitalComboBox.Items.Insert(0, New RadComboBoxItem(""))
                HospitalComboBox.SelectedIndex = 0
            End If

            If Not IsDBNull(rw("PatientStatus")) Then
                PatStatusRadioButtonList.SelectedValue = CInt(rw("PatientStatus"))
            End If

            If Not IsDBNull(rw("Ward")) Then
                DropBoxSetSelectedOrDefaultValue(WardComboBox, CInt(rw("Ward")))
            Else
                WardComboBox.SelectedIndex = 0
            End If

            If Not IsDBNull(rw("PatientType")) Then
                PatientTypeRadioButtonList.SelectedValue = CInt(rw("PatientType"))
            End If

            If Not IsDBNull(rw("CategoryListId")) Then
                DropBoxSetSelectedOrDefaultValue(CategoryRadComboBox, CInt(rw("CategoryListId")))
            End If
        End If
    End Sub

    ''' <summary>
    ''' This will set a value in the Dropdown List box- either an Existing value form Table or set Empty!
    ''' </summary>
    ''' <param name="targetDropdown">RadComboBox.Dropdown List Box</param>
    ''' <param name="sourceColumn">Table Field name</param>
    ''' <remarks>Shawkat; 2017-07-07</remarks>
    Private Sub DropBoxSetSelectedOrDefaultValue(targetDropdown As RadComboBox, Optional ByVal sourceColumn As String = Nothing)
        Try
            Dim itemToSelect As RadComboBoxItem
            itemToSelect = targetDropdown.FindItemByValue(CStr(IIf(String.IsNullOrEmpty(sourceColumn), Nothing, sourceColumn)))
            If itemToSelect IsNot Nothing Then
                itemToSelect.Selected = True
            Else 'when String.IsNullOrEmpty
                'targetDropdown.Items.Insert(0, New RadComboBoxItem("")) '//## making it Empty!
                targetDropdown.Items(0).Selected = True
            End If

        Catch ex As Exception

        End Try

    End Sub

    ''' <summary>
    ''' This will load the specific type of Consultant in a Specific DropDown box!
    ''' Using the LAMBDA- benefit is- read once all the Consultant and filter them later as per the Dropdown type
    ''' </summary>
    ''' <param name="dropDownBox">dropDownBox As RadComboBox</param>
    ''' <param name="consultantType">ie: Staff.ListConsultant</param>
    ''' <remarks></remarks>
    Private Sub LoadConsultantByType(ByVal dropDownBox As RadComboBox, ByVal consultantType As Staff)
        dropDownBox.ClearSelection()
        dropDownBox.Items.Clear()
        dropDownBox.DataTextField = "Consultant"
        dropDownBox.DataValueField = "UserId"

        Try
            dropDownBox.DataSource = BusinessLogic.FilterConsultantByType(consultantType)
            dropDownBox.DataBind()
            dropDownBox.Items.Insert(0, New RadComboBoxItem(""))
            dropDownBox.SelectedIndex = 0

            Dim intProcedureId As Integer = 0
            Dim strConsultantType As String = ""
            strConsultantType = [Enum].GetName(GetType(Staff), consultantType)

            If Not IsNothing(Session(Constants.SESSION_PROCEDURE_ID)) Then
                intProcedureId = Session(Constants.SESSION_PROCEDURE_ID)
            End If

            'If existing procedure, ensure selected staff appears in dropdown list
            If intProcedureId > 0 Then
                Dim dtSelectedStaff = BusinessLogic.GetSelectedStaffForProcedureId(strConsultantType, intProcedureId)
                If dtSelectedStaff.Rows.Count > 0 Then
                    Dim intEachUserId As Integer = 0
                    Dim strEachConsultant As String = ""
                    Dim radDropItem As New RadComboBoxItem
                    For Each drD As DataRow In dtSelectedStaff.Rows
                        intEachUserId = 0
                        strEachConsultant = ""

                        If Not IsDBNull(drD("UserId")) Then
                            intEachUserId = Convert.ToInt32(drD("UserId"))
                        End If
                        If Not IsDBNull(drD("Consultant")) Then
                            strEachConsultant = drD("Consultant").ToString()
                        End If

                        radDropItem = New RadComboBoxItem(strEachConsultant, intEachUserId)

                        If IsNothing(dropDownBox.FindItemByValue(intEachUserId)) Then
                            dropDownBox.Items.Add(radDropItem)
                        End If

                    Next
                End If
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occurred on LoadConsultantByType.", ex)
            dropDownBox.Items.Add("Load Failed")
        End Try
    End Sub

    Protected Sub HospitalChanged()
        If HospitalComboBox.SelectedValue = "" Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalComboBox, ""}}, DataAdapter.GetReferralHospitals(""), "HospitalName", "HospitalID")
            HospitalComboBox.Items.Insert(0, New RadComboBoxItem(""))
        End If
    End Sub

    Sub SelectReferralConsultantComboByConsultantID(intConsultantID As Integer)
        Dim intCounter As Integer = 0
        intCounter = ConsultantComboBox.Items.Count

        If intCounter > 0 Then
            For i As Integer = 0 To intCounter - 1
                If ConsultantComboBox.Items(i).Value = intConsultantID Then
                    ConsultantComboBox.Items(i).Selected = True
                    ConsultantComboBox.Text = ConsultantComboBox.Items(i).Text
                    ConsultantComboBox.Value = ConsultantComboBox.Items(i).Value
                    Exit For
                End If
            Next
        End If
    End Sub
End Class