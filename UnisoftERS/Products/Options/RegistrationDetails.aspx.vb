Imports Telerik.Web.UI

Partial Class Products_Options_RegistrationDetails
    Inherits OptionsBase

    Protected ReadOnly Property OperatingHospitalId() As Integer
        Get
            Return CInt(OperatingHospitalsRadComboBox.SelectedValue)
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim trusts = DataAdapter.GetTrusts()
            TrustRadComboBox.DataSource = trusts
            TrustRadComboBox.DataBind()
            Dim da = New DataAccess()
            Dim countryNationalHealthServiceName As String = Session(Constants.SESSION_HEALTH_SERVICE_NAME)
            TrustFilterTR.Visible = da.IsGlobalAdmin(Session("PKUserId"))
            TrustRadComboBox.SelectedValue = Session("TrustId")
            btnToggle.Text = "Enable " + countryNationalHealthServiceName + " style header for reports"
            NationalHealthName.InnerText = countryNationalHealthServiceName + " Hospital ID :"

            If TrustRadComboBox.Items.Count > 0 Then
                loadOperatingHospitals(CInt(Session("TrustId")))
                OperatingHospitalsRadComboBox.SelectedValue = CInt(Session("OperatingHospitalId"))

                PopulateImportPatientByWebserviceCombo()
                loadRegistrationDetails()
            End If
        End If
    End Sub

    Private Sub loadOperatingHospitals(trustId As Integer)
        Try
            OperatingHospitalsRadComboBox.DataSource = DataAdapter.GetTrustHospitals(trustId)
            OperatingHospitalsRadComboBox.DataTextField = "HospitalName"
            OperatingHospitalsRadComboBox.DataValueField = "OperatingHospitalId"
            OperatingHospitalsRadComboBox.DataBind()
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Private Sub loadRegistrationDetails()
        If Not IsNothing(OperatingHospitalsRadComboBox.SelectedValue) Then

            If OperatingHospitalsRadComboBox.SelectedValue.ToString().Trim() <> "" Then
                Dim operatingHospitalId As Integer = OperatingHospitalsRadComboBox.SelectedValue

                Dim dtPr As DataTable = OptionsDataAdapter.GetRegistrationDetails(operatingHospitalId)
                If dtPr.Rows.Count > 0 Then
                    ClearOperatingHospitalFormControls()
                    PopulateData(dtPr.Rows(0))
                End If
            Else
                ClearOperatingHospitalFormControls()
            End If

        Else
            ClearOperatingHospitalFormControls()
        End If
    End Sub

    '08 Mar 2021 : Mahfuz added ImportPatientByWebService
    Private Sub PopulateData(drPr As DataRow)
        If Not IsDBNull(drPr("ReportHeading")) Then
            ReportHeadingRadTextBox.Text = CStr(drPr("ReportHeading"))
        Else
            ReportHeadingRadTextBox.Text = "Default"
        End If

        If Not IsDBNull(drPr("ReportTrustType")) Then
            TrustTypeRadTextBox.Text = CStr(drPr("ReportTrustType"))
        End If

        If Not IsDBNull(drPr("ReportSubHeading")) Then
            ReportSubheadingRadTextBox.Text = CStr(drPr("ReportSubHeading"))
        End If

        If Not IsDBNull(drPr("ReportFooter")) Then
            ReportFooterRadTextBox.Text = CStr(drPr("ReportFooter"))
        End If

        If Not IsDBNull(drPr("DepartmentName")) Then
            DepartmentNameRadTextBox.Text = CStr(drPr("DepartmentName"))
        End If

        If Not IsDBNull(drPr("TrustId")) Then
            TrustNameRadTextBox.Text = TrustRadComboBox.SelectedItem.Text
        Else
            TrustNameRadTextBox.Text = ""
        End If


        If Not IsDBNull(drPr("HospitalName")) Then
            HospitalNameRadTextBox.Text = CStr(drPr("HospitalName"))
        End If

        If Not IsDBNull(drPr("ContactNumber")) Then
            ContactNumberRadTextBox.Text = CStr(drPr("ContactNumber"))
        End If

        If Not IsDBNull(drPr("InternalHospitalID")) Then
            InternalHospitalIdRadTextBox.Text = CStr(drPr("InternalHospitalID"))
        End If

        If Not IsDBNull(drPr("NHSHospitalID")) Then
            NHSHospitalIdRadTextBox.Text = CStr(drPr("NHSHospitalID"))
        End If

        If Not IsDBNull(drPr("ReportExportPath")) Then
            ReportExportPathRadTextBox.Text = CStr(drPr("ReportExportPath"))
        End If

        'If Not IsDBNull(drPr("NED_ExportPath")) Then
        '    NEDExportPathTextBox.Text = CStr(drPr("NED_ExportPath"))
        'End If

        'If Not IsDBNull(drPr("NED_HospitalSiteCode")) Then
        '    NEDODS_CodeTextBox.Text = CStr(drPr("NED_HospitalSiteCode"))
        'End If
        If Not IsDBNull(drPr("ImportPatientByWebService")) Then
            cboImportPatientByWebservice.SelectedValue = CInt(drPr("ImportPatientByWebService"))
            cboWSValue.Value = CInt(drPr("ImportPatientByWebService"))
        End If
        If Not IsDBNull(drPr("AddExportFileForMirth")) Then
            chkAddFileExportForMirth.Checked = Convert.ToBoolean(drPr("AddExportFileForMirth"))
        Else
            chkAddFileExportForMirth.Checked = False
        End If

        If Not IsDBNull(drPr("SuppressMainReportPDF")) Then
            chkSuppressMainReportPDF.Checked = Convert.ToBoolean(drPr("SuppressMainReportPDF"))
        Else
            chkSuppressMainReportPDF.Checked = False
        End If

        '05 Jan 2022 - MH added ExportDocumentFilePrefix

        If Not IsDBNull(drPr("ExportDocumentFilePrefix")) Then
            txtExportDocumentFilePrefix.Text = drPr("ExportDocumentFilePrefix").ToString()
        Else
            txtExportDocumentFilePrefix.Text = ""
        End If
    End Sub
    Private Sub ClearOperatingHospitalFormControls()

        ReportHeadingRadTextBox.Text = ""

        TrustTypeRadTextBox.Text = ""

        ReportSubheadingRadTextBox.Text = ""

        ReportFooterRadTextBox.Text = ""

        DepartmentNameRadTextBox.Text = ""

        TrustNameRadTextBox.Text = ""

        HospitalNameRadTextBox.Text = ""

        ContactNumberRadTextBox.Text = ""

        InternalHospitalIdRadTextBox.Text = ""

        NHSHospitalIdRadTextBox.Text = ""

        ReportExportPathRadTextBox.Text = ""

        chkAddFileExportForMirth.Checked = False

        chkSuppressMainReportPDF.Checked = False

        txtExportDocumentFilePrefix.Text = ""

        If cboImportPatientByWebservice.Items.Count > 0 Then
            cboImportPatientByWebservice.SelectedIndex = 0
        End If
    End Sub

    Private Sub PopulateImportPatientByWebserviceCombo()
        Dim newItem As RadComboBoxItem
        newItem = New RadComboBoxItem
        cboImportPatientByWebservice.Items.Add(newItem) 'Adds a blank (not set item)

        For Each intValue In Utilities.GetEnumValues(Of ImportPatientByWebserviceOptions)
            newItem = New RadComboBoxItem
            newItem.Value = intValue
            newItem.Text = System.Enum.GetName(GetType(ImportPatientByWebserviceOptions), intValue)
            cboImportPatientByWebservice.Items.Add(newItem)
        Next
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Dim intImportPatientByWebserviceSelectedValue As Nullable(Of Integer)
        Dim blnAddNew As Boolean = False
        Dim id = OperatingHospitalId()
        Try
            If OperatingHospitalsRadComboBox.Items.Count = 0 Then
                blnAddNew = True
            ElseIf IsNothing(OperatingHospitalsRadComboBox.SelectedItem) Then
                blnAddNew = True
            ElseIf OperatingHospitalsRadComboBox.SelectedItem.Text = "" Then
                blnAddNew = True
            Else
                blnAddNew = False
            End If
            'MH Changed as below on 18 Nov 2021
            'If OperatingHospitalsRadComboBox.SelectedItem.Text = "" Then
            If HospitalNameRadTextBox.Text = "" Then
                Utilities.SetNotificationStyle(RadNotification1, "Hospital name is required.", True, "Please correct")
                RadNotification1.Show()
            Else
                If blnAddNew Then

                    'add new
                    'do licence check again- just incase...
                    Dim _license As New License(ConfigurationManager.AppSettings("Unisoft.LicenseKey"))
                    If (DataAdapter.GetOperatingHospitalCount + 1) > CInt(_license.RegisteredHospital) Then
                        'show popup to inform them to purchase a new licence
                        Utilities.SetNotificationStyle(RadNotification1, "Licence only valid for " & DataAdapter.GetOperatingHospitalCount & ". Please upgrade your licence and try again.", True)
                        RadNotification1.Show()
                    Else
                        Dim newOHID = DataAdapter.AddNewOperatingHospital(
                                              id,
                                              ReportHeadingRadTextBox.Text,
                                              ReportSubheadingRadTextBox.Text,
                                              ReportFooterRadTextBox.Text,
                                              TrustTypeRadTextBox.Text,
                                              DepartmentNameRadTextBox.Text,
                                              TrustRadComboBox.SelectedValue,
                                              HospitalNameRadTextBox.Text,
                                              ContactNumberRadTextBox.Text,
                                              InternalHospitalIdRadTextBox.Text,
                                              NHSHospitalIdRadTextBox.Text,
                                              ReportExportPathRadTextBox.Text,
                                              "",
                                              "",
                                              CopyPrintSettingsCheckBox.Checked,
                                              CopyPhraseLibraryCheckBox.Checked,
                                              cboImportPatientByWebservice.SelectedValue,
                                              chkAddFileExportForMirth.Checked,
                                                  chkSuppressMainReportPDF.Checked,
                                                  txtExportDocumentFilePrefix.Text,
                                                    If(TrustRadComboBox.SelectedItem.Text = "", TrustNameRadTextBox.Text, Nothing))

                        If newOHID > 0 Then
                            OperatingHospitalsRadComboBox.Enabled = True
                            TrustRadComboBox.Enabled = True
                            AddNewHospitalRadButton.Enabled = True
                            AddNewTrustRadButton.Enabled = True

                            If TrustRadComboBox.SelectedItem.Text = "" Then
                                TrustRadComboBox.DataSource = DataAdapter.GetTrusts()
                                TrustRadComboBox.DataBind()
                                TrustRadComboBox.SelectedValue = newOHID

                                loadOperatingHospitals(newOHID)
                                OperatingHospitalsRadComboBox.SelectedIndex = 0

                                loadRegistrationDetails()
                            Else
                                loadOperatingHospitals(TrustRadComboBox.SelectedValue)
                                'OperatingHospitalsRadComboBox.SelectedValue = newOHID
                                'loadRegistrationDetails()
                            End If

                            ScriptManager.RegisterStartupScript(Me.Page, Page.GetType, "HideControls", "hideCopySettingsOptions();", True)
                            Utilities.SetNotificationStyle(RadNotification1, "A new hospital has been created.", True)
                            RadNotification1.Show()
                            ReportHeadingRadTextBox.Text = ""
                            ReportSubheadingRadTextBox.Text = ""
                            ReportFooterRadTextBox.Text = ""
                            DepartmentNameRadTextBox.Text = ""
                            HospitalNameRadTextBox.Text = ""
                            ContactNumberRadTextBox.Text = ""
                            InternalHospitalIdRadTextBox.Text = ""
                            NHSHospitalIdRadTextBox.Text = ""
                            cboImportPatientByWebservice.SelectedIndex = 1
                        End If
                    End If
                Else
                    If cboImportPatientByWebservice.SelectedValue Is Nothing Or cboImportPatientByWebservice.SelectedValue.Trim() = "" Then
                        intImportPatientByWebserviceSelectedValue = Nothing
                    Else
                        intImportPatientByWebserviceSelectedValue = Convert.ToInt32(cboImportPatientByWebservice.SelectedValue)
                    End If

                    OptionsDataAdapter.UpdateRegistrationDetails(OperatingHospitalId,
                                                       ReportHeadingRadTextBox.Text,
                                                       ReportSubheadingRadTextBox.Text,
                                                       ReportFooterRadTextBox.Text,
                                                       TrustTypeRadTextBox.Text,
                                                       DepartmentNameRadTextBox.Text,
                                                       TrustRadComboBox.SelectedValue,
                                                       HospitalNameRadTextBox.Text,
                                                       ContactNumberRadTextBox.Text,
                                                       InternalHospitalIdRadTextBox.Text,
                                                       NHSHospitalIdRadTextBox.Text,
                                                       ReportExportPathRadTextBox.Text,
                                                       "",
                                                       "",
                                                       intImportPatientByWebserviceSelectedValue,
                                                       chkAddFileExportForMirth.Checked,
                                                        chkSuppressMainReportPDF.Checked,
                                                       txtExportDocumentFilePrefix.Text)
                    Utilities.SetNotificationStyle(RadNotification1, "Registration details information update successfully.", True)
                    RadNotification1.Show()
                End If
                If Session("OperatingHospitalId") = OperatingHospitalId Then
                    Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = intImportPatientByWebserviceSelectedValue
                    'MH added on 17 Nov 2021
                    Session(Constants.SESSION_ADD_EXPORT_FILE_FOR_MIRTH) = chkAddFileExportForMirth.Checked
                    'MH added on 22 Mar 2022
                    Session(Constants.SESSION_SUPPRESS_MAIN_REPORT_PDF) = chkSuppressMainReportPDF.Checked
                End If



                Dim intSelValue As String = ""
                Dim strScript As String = ""

                If Not IsNothing(cboImportPatientByWebservice.SelectedValue) Then
                    If cboImportPatientByWebservice.SelectedValue.ToString().Trim() <> "" Then
                        intSelValue = CInt(cboImportPatientByWebservice.SelectedValue)
                    End If
                End If
                cboWSValue.Value = intSelValue
                strScript = "showHideReportPathEntry(" + intSelValue.ToString() + ");"
                'ClientScript.RegisterStartupScript(Me.GetType(), "LoadStartShowHide", strScript)
                ScriptManager.RegisterStartupScript(Me, Me.GetType, "LoadStartShowHide", strScript, True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Registration Details under Options - Admin Utilities.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        Response.Redirect(Request.Url.AbsoluteUri, False)
    End Sub

    Protected Sub OperatingHospitalsRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        loadRegistrationDetails()
        Dim intSelValue As String = ""
        Dim strScript As String = ""

        If Not IsNothing(cboImportPatientByWebservice.SelectedValue) Then
            If cboImportPatientByWebservice.SelectedValue.ToString().Trim() <> "" Then
                intSelValue = cboImportPatientByWebservice.SelectedValue
            End If
        End If
        cboWSValue.Value = intSelValue
        strScript = "showHideReportPathEntry(" + intSelValue + ");"
        'ClientScript.RegisterStartupScript(Me.GetType(), "LoadStartShowHide", strScript)
        ScriptManager.RegisterStartupScript(Me, Me.GetType, "LoadStartShowHide", strScript, True)
    End Sub

    Protected Sub AddNewHospitalRadButton_Click(sender As Object, e As EventArgs)
        Try

            Dim _license As New License(ConfigurationManager.AppSettings("Unisoft.LicenseKey"))

            If (DataAdapter.GetOperatingHospitalCount + 1) > CInt(_license.RegisteredHospital) Then
                'show popup to inform them to purchase a new licence
                Utilities.SetNotificationStyle(RadNotification1, "Licence only valid for " & DataAdapter.GetOperatingHospitalCount & ". Please upgrade licence and try again.", True)
                RadNotification1.Show()
            Else
                clearForm(False)

                If OperatingHospitalsRadComboBox.Items.Count > 0 Then
                    If Not IsNothing(OperatingHospitalsRadComboBox.SelectedItem) Then
                        OperatingHospitalsRadComboBox.SelectedItem.Text = ""
                    End If
                End If

                OperatingHospitalsRadComboBox.Enabled = False
                AddNewHospitalRadButton.Enabled = False
                SaveButton.CommandName = "hospital"
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading your data.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub clearForm(newTrust As Boolean)
        ReportHeadingRadTextBox.Text = ""
        TrustTypeRadTextBox.Text = ""
        If newTrust Then TrustNameRadTextBox.Text = ""
        ReportSubheadingRadTextBox.Text = ""
        ReportFooterRadTextBox.Text = ""
        DepartmentNameRadTextBox.Text = ""
        HospitalNameRadTextBox.Text = ""
        ContactNumberRadTextBox.Text = ""
        InternalHospitalIdRadTextBox.Text = ""
        NHSHospitalIdRadTextBox.Text = ""
        cboImportPatientByWebservice.SelectedIndex = 1
        'ReportExportPathRadTextBox.Text = ""
        'NEDODS_CodeTextBox.Text = ""
        'NEDExportPathTextBox.Text = ""
    End Sub

    Protected Sub TrustRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            Dim strScript As String = ""
            Dim intSelValue As String = ""

            Dim trustId As Integer = TrustRadComboBox.SelectedValue
            loadOperatingHospitals(trustId)

            loadRegistrationDetails()

            If Not IsNothing(cboImportPatientByWebservice.SelectedValue) Then
                If cboImportPatientByWebservice.SelectedValue.ToString().Trim() <> "" Then
                    intSelValue = cboImportPatientByWebservice.SelectedValue
                End If
            End If

            cboWSValue.Value = intSelValue


            strScript = "showHideReportPathEntry(" + intSelValue + ");"
            'ClientScript.RegisterStartupScript(Me.GetType(), "LoadStartShowHide", strScript)
            ScriptManager.RegisterStartupScript(Me, Me.GetType, "ShowHideStartup", strScript, True)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading trust hospitals.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading your data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub AddNewTrustRadButton_Click(sender As Object, e As EventArgs)
        Dim _license As New License(ConfigurationManager.AppSettings("Unisoft.LicenseKey"))

        If (DataAdapter.GetOperatingHospitalCount + 1) > CInt(_license.RegisteredHospital) Then
            'show popup to inform them to purchase a new licence
            Utilities.SetNotificationStyle(RadNotification1, "Licence only valid for " & DataAdapter.GetOperatingHospitalCount & ". Please upgrade licence and try again.", True)
            RadNotification1.Show()
        Else
            clearForm(True)

            TrustRadComboBox.SelectedItem.Text = ""
            TrustRadComboBox.Enabled = False
            AddNewTrustRadButton.Enabled = False


            OperatingHospitalsRadComboBox.SelectedItem.Text = ""
            OperatingHospitalsRadComboBox.Enabled = False
            AddNewHospitalRadButton.Enabled = False

            TrustNameRadTextBox.Enabled = True
            SaveButton.CommandName = "trust"
        End If
    End Sub
End Class
