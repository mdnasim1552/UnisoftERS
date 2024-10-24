Imports Telerik.Web.UI
Imports System.Linq
Imports Microsoft.VisualBasic
Imports ERS.Data
Imports System.Data.SqlClient
Imports System.Reflection
Imports UnisoftERS.ScotHospitalWebservice
Public Class PatientSearchResults
    Inherits System.Web.UI.UserControl

    Dim showPreAssessment As String = ConfigurationManager.AppSettings("ShowPreAssessment")
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        PatientDatasource.Value = ImportPatientByWebserviceOptions.Webservice
    End Sub

    Private Sub PatientsObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles PatientsObjectDataSource.Selecting
        If Session(Constants.SESSION_PATIENT_SEARCH_FIELDS) Is Nothing Then Exit Sub
        Dim searchFields As Dictionary(Of String, String) = Session(Constants.SESSION_PATIENT_SEARCH_FIELDS)

        PatientsGrid.Style("Display") = "Block"
        If Session(Constants.SESSION_SEARCH_TAB) = "1" Then
            Dim sSearchText As String = searchFields("SearchBoxText")

            e.InputParameters("SearchString1") = Trim(sSearchText)
            e.InputParameters("opt_condition") = searchFields("SearchType")
        ElseIf Session(Constants.SESSION_SEARCH_TAB) = "2" Then 'Advanced Search
            e.InputParameters("SearchString1") = searchFields("CaseNoteNo") 'Trim(CaseNoteNoTextBox.Text)
            e.InputParameters("SearchString2") = searchFields("NHSNo") 'Trim(NHSNoTextBox.Text)
            e.InputParameters("SearchString3") = searchFields("Surname") 'Trim(SurnameTextBox.Text)
            e.InputParameters("SearchString4") = searchFields("Forename") 'Trim(ForenameTextBox.Text)
            e.InputParameters("SearchString5") = If(String.IsNullOrWhiteSpace(searchFields("DOB")), "", CDate(searchFields("DOB")).ToString("yyyy/MM/dd")) 'If(String.IsNullOrWhiteSpace(DOBTextBox.Text), "", CDate(Trim(DOBTextBox.Text)).ToString("yyyy/MM/dd"))
            e.InputParameters("SearchString6") = searchFields("Address") 'Trim(AddressTextBox.Text)
            e.InputParameters("SearchString7") = searchFields("Postcode") 'Trim(PostCodeTextBox.Text)
            e.InputParameters("SearchString8") = searchFields("Gender") 'Added on 5 Jun 2023
            e.InputParameters("opt_condition") = searchFields("SearchCondition")
            e.InputParameters("IncludeDeceased") = IIf(searchFields("IncludeDeceased") = "False", "True", "False")
        End If
        e.InputParameters("opt_type") = searchFields("SearchTerm")

    End Sub
    '08 Mar 2021 : Mahfuz implemented ImportPatientByWebService
    Sub DisplaySearchResults(SelectedCriteria As String, SearchBoxText As String)
        PatientsGridSection.Visible = True
        SelectedPatientHiddenField.Value = ""

        Try

            PatientsGrid.MasterTableView.SortExpressions.Clear()
            PatientsGrid.MasterTableView.CurrentPageIndex = 0

            'Dim fpc As FindPatientCriteria = New FindPatientCriteria


            'Mahfuz Changed on 25 Jun 2021 - D&G required changes.
            'Below code has been moved to GridDatabind datasource method : DataAccess class GetPatients line 3799 (Old_App_Code\DataAccess\DataAccess.vb)

            'If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
            '    Dim ScotHosWSBL As ScotHospitalWebServiceBL = New ScotHospitalWebServiceBL

            '    ScotHosWSBL.ConnectWebservice()
            '    'Call GetPatients method
            '    ScotHosWSBL.FindAndImportPatients()
            '    'Logout
            '    ScotHosWSBL.DisconnectService()
            'ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.FileDataExport Then
            '    'Do Flatfile related job
            'End If

            PatientsGrid.DataBind()

            'SCIStore Webservice does not return Ethnicity information in Findpatient(BasicDemographics) array 
            If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
                If Not IsNothing(PatientsGrid.MasterTableView.Columns.FindByUniqueNameSafe("Ethnicity")) Then
                    PatientsGrid.MasterTableView.Columns.FindByUniqueNameSafe("Ethnicity").Visible = False
                End If
            Else
                If Not IsNothing(PatientsGrid.MasterTableView.Columns.FindByUniqueNameSafe("Ethnicity")) Then
                    PatientsGrid.MasterTableView.Columns.FindByUniqueNameSafe("Ethnicity").Visible = True
                End If
            End If

        Catch ex As Exception
            Throw ex
        End Try

        'The following (below) is for logging purposes. The query gets built and data is queried in PatientsObjectDataSource_Selecting
        Dim da As New DataAccess

        Dim sSearchText As String = ""
        If Session(Constants.SESSION_SEARCH_TAB) = "1" Then
            If SelectedCriteria = "" Then 'ALL
                sSearchText = "ALL = " & SearchBoxText
            Else
                Dim sca As String = da.GetCountryLabel(SelectedCriteria)
                sSearchText = IIf(sca = "", SelectedCriteria, sca) & " = " & SearchBoxText
            End If
        Else 'Advanced Search 
            Dim searchFields As Dictionary(Of String, String) = Session(Constants.SESSION_PATIENT_SEARCH_FIELDS)
            Dim sCondition = searchFields("SearchCondition")

            If Trim(searchFields("CaseNoteNo")) <> "" Then
                sSearchText += IIf(sSearchText = "", "", sCondition) & "Hospital No " & " = " & Trim(searchFields("CaseNoteNo"))
            End If
            If Trim(searchFields("NHSNo")) <> "" Then
                sSearchText += IIf(sSearchText = "", "", sCondition) & "NHS No " & " = " & Trim(searchFields("NHSNo"))
            End If
            If Trim(searchFields("Surname")) <> "" Then
                sSearchText += IIf(sSearchText = "", "", sCondition) & "Surname " & " = " & Trim(searchFields("Surname"))
            End If
            If Trim(searchFields("Forename")) <> "" Then
                sSearchText += IIf(sSearchText = "", "", sCondition) & "Forename " & " = " & Trim(searchFields("Forename"))
            End If
            If Trim(searchFields("DOB")) <> "" Then
                sSearchText += IIf(sSearchText = "", "", sCondition) & "Date of birth " & " = " & Trim(searchFields("DOB"))
            End If
            If Trim(searchFields("Gender")) <> "" Then
                sSearchText += IIf(sSearchText = "", "", sCondition) & "Gender " & " = " & Trim(searchFields("Gender"))
            End If
            If Trim(searchFields("Address")) <> "" Then
                sSearchText += IIf(sSearchText = "", "", sCondition) & "Address " & " = " & Trim(searchFields("Address"))
            End If
            If Trim(searchFields("Postcode")) <> "" Then
                sSearchText += IIf(sSearchText = "", "", sCondition) & "Postcode " & " = " & Trim(searchFields("Postcode"))
            End If
        End If

        Using lm As New AuditLogManager
            lm.WriteActivityLog(EVENT_TYPE.Search, "Search for " & sSearchText)
        End Using
    End Sub

    Private Sub PatientsGrid_ItemCreated(sender As Object, e As GridItemEventArgs) Handles PatientsGrid.ItemCreated
        If TypeOf e.Item Is GridPagerItem Then
            Dim pagerItem As GridPagerItem = DirectCast(e.Item, GridPagerItem)
            Dim cssClassStr As String = ""
            If pagerItem.Paging.IsFirstPage Then cssClassStr = "RadFirstPage"
            If pagerItem.Paging.IsLastPage Then cssClassStr = Trim(cssClassStr & " " & "RadLastPage")
            If cssClassStr <> "" Then pagerItem.CssClass = cssClassStr
        End If
    End Sub
    Private Sub VisiblePreAssessment()

        If Not String.IsNullOrEmpty(showPreAssessment) AndAlso showPreAssessment.ToLower() = "y" Then
            RadMenu1.Items(0).Visible = True
        Else
            RadMenu1.Items(0).Visible = False
        End If
    End Sub
    Private Sub PatientsGridSelect(patientId As Integer, caseNoteNo As String, ersPatient As Boolean)
        '30 June 2021 - Mahfuz changed for Scottish Hospital D&G web service patients
        Dim sm As New SessionManager
        sm.ClearPatientSessions()
        Dim intSELocalPatientId As Integer
        Dim strSCIStoreImportPatientErrorMessage As String = ""

        'If SCIStore D&G Webservice enabled then above patientId will be SCIStorePatientID not SE Local DB PatientID
        If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
            Dim ScotHosWSBL As ScotHospitalWebServiceBL = New ScotHospitalWebServiceBL

            ScotHosWSBL.ConnectWebservice()
            'Call GetPatients method
            intSELocalPatientId = ScotHosWSBL.ImportPatientsIntoDatabaseBySCIStorePatientID(patientId)
            'Logout
            ScotHosWSBL.DisconnectService()

        ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI) = ImportPatientByWebserviceOptions.NSSAPI Then
            If Session("PatientSearchSource") = Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI Then
                Dim nipapiPIBL As NIPAPIBL = New NIPAPIBL()
                Dim chiNumber As String = caseNoteNo
                intSELocalPatientId = nipapiPIBL.ExtractAndImportPatientsIntoDatabase(chiNumber)
            Else
                intSELocalPatientId = patientId
            End If
        ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI) = ImportPatientByWebserviceOptions.NHSSPINEAPI Then

            Dim nhsSpineAPI As NHSSPINEAPIBL = New NHSSPINEAPIBL()
            Dim nhsNumber As String = caseNoteNo

            intSELocalPatientId = nhsSpineAPI.ExtractAndImportPatientsIntoDatabase(nhsNumber)

        Else
            intSELocalPatientId = patientId
        End If

        Session(Constants.SESSION_PATIENT_SEARCH_FIELDS) = Nothing
        'Session(Constants.SESSION_PATIENT_ID) = intSELocalPatientId '30 June 2021 Mahfuz changed from patientId

        Session(Constants.SESSION_IS_ERS_PATIENT) = ersPatient
        Session(Constants.SESSION_CASE_NOTE_NO) = caseNoteNo

        ' Set value first-time when select patient from grid
        Dim CookieTime As Int32 = ConfigurationManager.AppSettings("CookieTime")
        If Request.Cookies("patientId") Is Nothing Then
            Dim aCookie As New HttpCookie("patientId")
            aCookie.Value = intSELocalPatientId
            aCookie.Expires = DateTime.Now.AddMinutes(CookieTime)
            Response.Cookies.Add(aCookie)

        Else  ' Update value if cookies exist somehow
            Dim Cookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
            Cookie.Value = intSELocalPatientId
            Cookie.Expires = DateTime.Now.AddMinutes(CookieTime)
            Response.Cookies.Add(Cookie)
        End If


        If intSELocalPatientId = 0 Then
            'PatientId can not be 0. Some error occurred. Creating procedure prohibited. Need to show error message to user here.
            If Not IsNothing(Session("SCIStoreImportPatientError")) Then
                strSCIStoreImportPatientErrorMessage = Session("SCIStoreImportPatientError").ToString().Trim()
            End If
            Dim strSurname As String
            Dim strForename As String
            Dim strNHSNo As String
            strSurname = PatientsGrid.SelectedItems(0).OwnerTableView.DataKeyValues(0)("Surname").ToString()
            strForename = PatientsGrid.SelectedItems(0).OwnerTableView.DataKeyValues(0)("Forename1").ToString()
            strNHSNo = PatientsGrid.SelectedItems(0).OwnerTableView.DataKeyValues(0)("NHSNo").ToString()
            strSCIStoreImportPatientErrorMessage = "<span style='color:red;'>" + strSCIStoreImportPatientErrorMessage + "</span><br><br>Patient: " + strForename + " " + strSurname + ", NHSNo:" + strNHSNo
            Utilities.SetErrorNotificationStyle(RadNotification1, strSCIStoreImportPatientErrorMessage, "There is a problem importing Patient details from SCIStore.")
            RadNotification1.Show()
        Else
            Me.Page.GetType.InvokeMember("LoadPatientPage", System.Reflection.BindingFlags.InvokeMethod, Nothing, Me.Page, Nothing)
        End If


    End Sub

    Protected Sub PatientsGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        If Not IsNothing(Session("ProcedureFromOrderComms")) Then
            Session("ProcedureFromOrderComms") = Nothing
        End If
        If Not IsNothing(Session("OrderCommsOrderId")) Then
            Session("OrderCommsOrderId") = Nothing
        End If
        If Not IsNothing(Session(Constants.SESSION_IS_PRE_ASSESSMENT)) Then
            Session(Constants.SESSION_IS_PRE_ASSESSMENT) = Nothing
        End If

        If PatientsGrid.SelectedItems.Count > 0 Then

            If e.CommandName = "startpreassessment" Then
                Dim patientId = CInt(CType(PatientsGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("PatientId"))
                Dim cnn = CType(PatientsGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("CaseNoteNo").ToString()
                Dim ersPatient = CBool(CType(PatientsGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("ERSPatient").ToString())
                Session(Constants.SESSION_IS_PRE_ASSESSMENT) = True
                Session(Constants.SESSION_TREE_GROUP_TYPE) = 2
                PatientsGridSelect(patientId, cnn, ersPatient)
            ElseIf e.CommandName = "startprocedure" Then
                Dim patientId1 = CInt(CType(PatientsGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("PatientId"))
                Dim cnn1 = CType(PatientsGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("CaseNoteNo").ToString()
                Dim ersPatient1 = CBool(CType(PatientsGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("ERSPatient").ToString())
                PatientsGridSelect(patientId1, cnn1, ersPatient1)
            ElseIf e.CommandName = "addtoworklist" Then
                PatientsGrid.Rebind()
                Me.Page.GetType.InvokeMember("LoadWorklistPage", System.Reflection.BindingFlags.InvokeMethod, Nothing, Me.Page, Nothing)

            End If
        End If
    End Sub

    Private Sub PatientsGrid_PreRender(sender As Object, e As EventArgs) Handles PatientsGrid.PreRender

        Dim headerText = PatientsGrid.MasterTableView.GetColumn("NHSNo").HeaderText

        If headerText = "NHS no." And Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() <> "NHS" Then
            PatientsGrid.MasterTableView.GetColumn("NHSNo").HeaderText = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " no."
            PatientsGrid.MasterTableView.Rebind()
        End If

        If PatientsGrid.Items.Count > 0 Then
            Dim cmdItem = PatientsGrid.MasterTableView.GetItems(GridItemType.CommandItem)(0)

            If CBool(Session("isERSViewer")) Then
                Dim btnAddToWorklist = CType(cmdItem.FindControl("AddToWorkListButton"), RadLinkButton)
                Dim btnViewProc = CType(cmdItem.FindControl("StartProcedureLinkButton"), RadLinkButton)
                Dim btnViewPreAssessProc = CType(cmdItem.FindControl("StartPreAssessment"), RadLinkButton)
                Dim btnEditPatientDetails = CType(cmdItem.FindControl("EditPatientDetails"), RadLinkButton)
                If btnViewPreAssessProc IsNot Nothing Then
                    btnViewPreAssessProc.Visible = False
                End If
                If btnAddToWorklist IsNot Nothing Then
                    btnAddToWorklist.Visible = False
                End If
                If btnViewProc IsNot Nothing Then
                    btnViewProc.Text = "View procedure(s)"
                End If
                btnEditPatientDetails.Visible = False
            End If

            Dim da As New DataAccess
            'get worklist
            Dim worklistPatientIDs = (From p In da.GetWorklistPatients() Select p.Field(Of Integer)("PatientId")).ToList
            Dim intSELocalDBPatientId As Integer = 0

            Dim patientIDs As New List(Of Integer)
            For Each item As GridItem In PatientsGrid.Items
                If item.DataItem Is Nothing Then Continue For

                'If SCIStore D&G Webservice enabled then above patientId will be SCIStorePatientID not SE Local DB PatientID
                If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
                    intSELocalDBPatientId = da.GetSELocalDBPatientIDBySCIStorePatientId(Convert.ToInt32(CType(item.DataItem, System.Data.DataRowView).Row("PatientId").ToString()))
                Else
                    intSELocalDBPatientId = Convert.ToInt32(CType(item.DataItem, System.Data.DataRowView).Row("PatientId").ToString())
                End If


                'If worklistPatientIDs.Contains(CType(item.DataItem, System.Data.DataRowView).Row("PatientId")) Then
                '    'highlight line
                '    item.CssClass = "rgRow rgWorklistPatient"
                'End If

                '07 July Mahfuz changed as below:

                If worklistPatientIDs.Contains(intSELocalDBPatientId) Then
                    'highlight line
                    item.CssClass = "rgRow rgWorklistPatient"
                End If
            Next



            If da.GetPageAccessLevel(CInt(Session("PKUserId")), "products_common_patientdetails_aspx") < 9 Then
                CType(cmdItem.FindControl("EditPatientDetails"), RadLinkButton).Visible = False
            End If

            'MH added on 03 Nov 2021 - Scottish Hospital does not need this edit patient button
            If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
                CType(cmdItem.FindControl("EditPatientDetails"), RadLinkButton).Visible = False
            End If
        Else
            If Session("PatientSearchSource") = Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI Then
                Dim norecordItem As GridNoRecordsItem = CType(PatientsGrid.MasterTableView.GetItems(GridItemType.NoRecordsItem)(0), GridNoRecordsItem)

                Dim lbl As HtmlGenericControl = CType(norecordItem.FindControl("NoRecordsDiv"), HtmlGenericControl)
                lbl.InnerText = ConfigurationManager.AppSettings("NIPAPINoRecordFound").ToString()
            End If
        End If

    End Sub

    Private Sub RadMenu1_Init(sender As Object, e As EventArgs) Handles RadMenu1.Init

        If CBool(Session("isERSViewer")) Then
            RadMenu1.Items(0).Visible = False
            RadMenu1.Items(2).Visible = False
            RadMenu1.Items(1).Text = "View procedure(s)"
        End If
    End Sub

    Private Sub PatientsGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles PatientsGrid.ItemDataBound
        If TypeOf e.Item Is GridDataItem Then
            Dim dataItem As GridDataItem = CType(e.Item, GridDataItem)
            Dim bErsPat As Boolean = CBool(dataItem.GetDataKeyValue("ERSPatient").ToString())

            'Format NHS Number
            Dim cell As TableCell = dataItem("NHSNo")
            cell.Text = Utilities.FormatHealthServiceNumber(cell.Text.Replace("&nbsp;", String.Empty))

            If Not bErsPat Then   'UGI Patients
                e.Item.CssClass = "UGIPatient"
                e.Item.ToolTip = "Patient from GI Reporting Tool"
            End If

            If CBool(CType(e.Item, GridDataItem).GetDataKeyValue("Deceased")) = True Then
                e.Item.FindControl("PatientDeceasedLabel").Visible = True
            End If
        ElseIf TypeOf e.Item Is GridCommandItem Then

            Dim commandItem As GridCommandItem = CType(e.Item, GridCommandItem)

            Dim lnkButton As RadLinkButton = CType(commandItem.FindControl("StartPreAssessment"), RadLinkButton)

            If Not String.IsNullOrEmpty(showPreAssessment) AndAlso showPreAssessment.ToLower() = "y" Then
                lnkButton.Visible = True
            Else
                lnkButton.Visible = False
            End If
        End If

    End Sub
    Protected Sub RadMenu1_PreRender(sender As Object, e As EventArgs) Handles RadMenu1.PreRender
        VisiblePreAssessment()
    End Sub


End Class