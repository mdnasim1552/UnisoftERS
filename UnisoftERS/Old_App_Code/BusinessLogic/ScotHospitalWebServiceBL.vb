Imports System.Linq
Imports Microsoft.VisualBasic
Imports ERS.Data
Imports System.Data.SqlClient
Imports System.Reflection
Imports UnisoftERS.ScotHospitalWebservice
Imports Microsoft.Ajax.Utilities
Imports DevExpress.CodeParser
Imports System.Data.Common

Public Class ScotHospitalWebServiceBL
    Inherits System.Web.UI.Page

    Private _service As SCIStoreServicesPort
    Private _creds As CredentialsUserInfo
    Private _token As String
    Dim _login As New Login




    Public Function ConnectWebservice() As Boolean
        Dim result As Boolean = False
        Try


            _service = New SCIStoreServicesPort
            '_service.Url = Global.UnisoftERS.My.MySettings.Default.UnisoftERS_ScotHospitalWebservice_SCIStoreServicesPort
            _service.Url = ConfigurationManager.AppSettings("UnisoftERS_ScotHospitalWebservice_SCIStoreServicesPort").ToString() 'Mahfuz changed on 19 May 2021
            _service.Timeout = 100000
            _service.UserCredentials = New Credentials
            _creds = New CredentialsUserInfo
            _creds.FriendlyName = "WS Test App"
            _creds.SystemCode = "Test App"
            _creds.SystemLocation = "SG033827"
            _creds.UserName = "webservice"
            '_service.UserCredentials = _creds
            _service.UseDefaultCredentials = True


            '_login.Username = Global.UnisoftERS.My.MySettings.Default.UnisoftERS_ScotHospitalWebservice_SCIStoreUserName
            '_login.Password = Global.UnisoftERS.My.MySettings.Default.UnisoftERS_ScotHospitalWebservice_SCIStoreUserPassword
            'Mahfuz changed as below on 19 May 2021
            _login.Username = ConfigurationManager.AppSettings("UnisoftERS_ScotHospitalWebservice_SCIStoreUserName").ToString()
            _login.Password = ConfigurationManager.AppSettings("UnisoftERS_ScotHospitalWebservice_SCIStoreUserPassword").ToString()

            Dim LoginResponse As LoginTokenResponse = _service.Login(_login)

            _token = LoginResponse.Token
            result = True

            Return result

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ConnectWebservice()", ex)
            Return False
        End Try

    End Function
    Public Function FindAndImportPatients() As Boolean
        Try
            Dim fpsc As FindPatientCriteria = New FindPatientCriteria
            fpsc = GetPatientSearchCriteriaFromSessionSearchFields()


            _service.UserCredentials.UserInfo = _creds

            _service.UserCredentials.Token = _token


            Dim fpr As FindPatientResponse = New FindPatientResponse
            Dim prosc As ProviderSearchCriteria = New ProviderSearchCriteria

            'fpsc.Ids.ID = "0002625"
            'fpsc.Ids.IDcomparator = SearchComparator.equals
            'fpsc.Ids.IDcomparatorSpecified = True


            prosc.IncludeAll = True
            fpsc.ProviderSearch = prosc

            fpr = _service.FindPatient(fpsc)

            Dim fpitems As FindPatientItem() = fpr.Patients

            If Not IsNothing(fpitems) Then
                If fpitems.Count > 0 Then
                    ImportPatientsIntoDatabase(fpitems)
                End If
            End If

            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in FindAndImportPatients()", ex)
            Return False
        End Try
    End Function
    Public Function SearchAndGetPatientsViaWebService() As DataSet
        Try
            Dim fpsc As FindPatientCriteria = New FindPatientCriteria
            Dim dsPatients As New DataSet

            fpsc = GetPatientSearchCriteriaFromSessionSearchFields()


            _service.UserCredentials.UserInfo = _creds

            _service.UserCredentials.Token = _token


            Dim fpr As FindPatientResponse = New FindPatientResponse
            Dim prosc As ProviderSearchCriteria = New ProviderSearchCriteria

            'fpsc.Ids.ID = "0002625"
            'fpsc.Ids.IDcomparator = SearchComparator.equals
            'fpsc.Ids.IDcomparatorSpecified = True


            prosc.IncludeAll = True
            fpsc.ProviderSearch = prosc

            fpr = _service.FindPatient(fpsc)

            Dim fpitems As FindPatientItem() = fpr.Patients

            If fpitems.Length = 0 Then ' Search returned 0 patients with Soundex , try search by like comparator
                If Not String.IsNullOrEmpty(fpsc.Name.Forename) Then
                    fpsc.Name.ForenameComparator = SearchComparator.contains
                    fpsc.Name.ForenameComparatorSpecified = True
                End If

                If Not String.IsNullOrEmpty(fpsc.Name.Surname) Then
                    fpsc.Name.SurnameComparator = SearchComparator.contains
                    fpsc.Name.SurnameComparatorSpecified = True
                End If

                fpr = _service.FindPatient(fpsc)
                fpitems = fpr.Patients

            End If

            dsPatients = GetGeneratedDatasetFromFindPatientItemCollection(fpitems)

            Return dsPatients
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in SearchAndGetPatientsViaWebService()", ex)
            Return Nothing
        End Try
    End Function
    Private Function GetGeneratedDatasetFromFindPatientItemCollection(objFPItemCol As FindPatientItem()) As DataSet
        Dim dsPatients As New DataSet
        Dim dap As New DataAccess

        Try
#Region "Create DataTable with columns"
            Dim patientTable As New DataTable
            patientTable.Columns.Add("PatientId", GetType(Integer))
            patientTable.Columns.Add("PatientName", GetType(String))
            patientTable.Columns.Add("Address", GetType(String))
            patientTable.Columns.Add("DOB", GetType(Date))
            patientTable.Columns.Add("Gender", GetType(String))
            patientTable.Columns.Add("Gender1", GetType(String))
            patientTable.Columns.Add("Ethnicity", GetType(String))
            patientTable.Columns.Add("CaseNoteNo", GetType(String))
            patientTable.Columns.Add("NHSNo", GetType(String))
            patientTable.Columns.Add("CreatedOn", GetType(DateTime))
            patientTable.Columns.Add("Deceased", GetType(Boolean))
            patientTable.Columns.Add("Deceased1", GetType(Boolean))
            patientTable.Columns.Add("PatientRowID", GetType(Integer))
            patientTable.Columns.Add("UGIPatientId", GetType(Integer))
            patientTable.Columns.Add("ComboId", GetType(Integer))
            patientTable.Columns.Add("ERSPatient", GetType(Boolean))
            patientTable.Columns.Add("Title", GetType(String))
            patientTable.Columns.Add("Forename1", GetType(String))
            patientTable.Columns.Add("Surname", GetType(String))
            patientTable.Columns.Add("PostCode", GetType(String))
            patientTable.Columns.Add("Telephone", GetType(String))
            patientTable.Columns.Add("DateOfBirth", GetType(Date))
            patientTable.Columns.Add("HospitalNumber", GetType(String))
            patientTable.Columns.Add("DateAdded", GetType(DateTime))
            patientTable.Columns.Add("DateUpdated", GetType(DateTime))
            patientTable.Columns.Add("EthnicId", GetType(Integer))
            patientTable.Columns.Add("DateOfDeath", GetType(Date))
            patientTable.Columns.Add("CreateUpdateMethod", GetType(String))

            Dim objNewRow As DataRow
            Dim intPatId As Integer
            Dim intPatientRowID As Integer
            Dim blnCHIProvided As Boolean = True
            Dim blnIsDisplayPatientWithoutCHI As Boolean = True

            intPatientRowID = 1
            blnIsDisplayPatientWithoutCHI = dap.GetIsDisplayPatientWithoutCHI(Session("OperatingHospitalID"))
            For Each objfpitem As FindPatientItem In objFPItemCol
                blnCHIProvided = True

                If objfpitem.CHI.IsNullOrWhiteSpace Then
                    blnCHIProvided = False
                Else
                    If objfpitem.CHI.ToString().Trim() = "" Then
                        blnCHIProvided = False
                    End If
                End If

                If Not blnCHIProvided Then
                    If Not blnIsDisplayPatientWithoutCHI Then
                        Continue For
                    End If
                End If

                objNewRow = patientTable.NewRow()
                If Integer.TryParse(objfpitem.PatientID, intPatId) Then
                    objNewRow("PatientId") = intPatId
                Else
                    objNewRow("PatientId") = (intPatientRowID * 1000) + 1 'It may never ever come here.
                End If

                objNewRow("NHSNo") = objfpitem.CHI
                objNewRow("CaseNoteNo") = objfpitem.CHI
                objNewRow("HospitalNumber") = objfpitem.CHI

                objNewRow("PatientRowID") = intPatientRowID

                objNewRow("Forename1") = objfpitem.GivenName
                objNewRow("Surname") = objfpitem.FamilyName
                objNewRow("PatientName") = objfpitem.Name
                objNewRow("Address") = objfpitem.Address
                objNewRow("PostCode") = objfpitem.PostCode
                objNewRow("Gender") = objfpitem.Sex
                objNewRow("DOB") = objfpitem.DateOfBirth
                objNewRow("DateOfBirth") = objfpitem.DateOfBirth
                objNewRow("ERSPatient") = 1
                objNewRow("Deceased") = False
                objNewRow("Deceased1") = False

                patientTable.Rows.Add(objNewRow)

                intPatientRowID = intPatientRowID + 1
            Next

            dsPatients.Tables.Add(patientTable)
            Return dsPatients
#End Region
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetGeneratedDatasetFromFindPatientItemCollection()", ex)
            Return Nothing
        End Try
    End Function
    Private Function GetPatientDetailsByWebservice(objFPItem As FindPatientItem) As PatientInformation
        Try
            _service.UserCredentials.UserInfo = _creds
            _service.UserCredentials.Token = _token
            Dim objGetPR As GetPatientResponse = New GetPatientResponse
            Dim objGetPatient As GetPatient = New GetPatient
            'Dim objBrGlItem As BreakGlassItem()
            'ReDim objBrGlItem(1)
            'objBrGlItem(0) = New BreakGlassItem
            'objBrGlItem(0).PatientID = objFPItem.PatientID
            'objBrGlItem(0).BreakGlassToken = _token
            objGetPatient.PatientID = objFPItem.PatientID
            objGetPatient.IncludeExtendedDemographics = True
            objGetPR = _service.GetPatient(objGetPatient)

            Return objGetPR.PatientInformation

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetPatientDetailsByWebService()", ex)
            Return Nothing
        End Try
    End Function
    Private Function GetPatientDetailsBySCIStorePatientID(intSCIStorePatientID As Integer) As PatientInformation
        Try
            _service.UserCredentials.UserInfo = _creds
            _service.UserCredentials.Token = _token
            Dim objGetPR As GetPatientResponse = New GetPatientResponse
            Dim objGetPatient As GetPatient = New GetPatient
            Dim objFPItem As New FindPatientItem

            If Not IsNothing(Session("SCIStoreImportPatientError")) Then
                Session("SCIStoreImportPatientError") = Nothing
            End If
            'Dim objBrGlItem As BreakGlassItem()
            'ReDim objBrGlItem(1)
            'objBrGlItem(0) = New BreakGlassItem
            'objBrGlItem(0).PatientID = objFPItem.PatientID
            'objBrGlItem(0).BreakGlassToken = _token
            objFPItem.PatientID = intSCIStorePatientID

            objGetPatient.PatientID = objFPItem.PatientID
            objGetPatient.IncludeExtendedDemographics = True
            objGetPR = _service.GetPatient(objGetPatient)

            Return objGetPR.PatientInformation

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetPatientDetailsByWebService()", ex)
            Session("SCIStoreImportPatientError") = ex.Message
            Return Nothing
        End Try
    End Function
    Private Function ImportPatientsIntoDatabase(objPatients As FindPatientItem())
        Try

            Dim objDA As DataAccess
            Dim objEachPatientInformation As PatientInformation

            Dim intPatientId As Nullable(Of Integer)
            Dim strCaseNoteNo As String
            Dim strTitle As String
            Dim strstrForename As String
            Dim strSurname As String
            Dim dtDateOfBirth As Date
            Dim strNHSNo As String
            Dim strAddress1 As String
            Dim strAddress2 As String
            Dim strTown As String
            Dim strCounty As String
            Dim strPostCode As String
            Dim strPhoneNo As String
            Dim strGender As String
            Dim strEthnicOrigin As String
            Dim blnJustDownloaded As Nullable(Of Boolean)
            Dim strNotes As String
            Dim strDistrict As String
            Dim strDHACode As String
            Dim intGPId As Nullable(Of Integer)
            Dim dtDateOfDeath As Nullable(Of Date)
            Dim blnAdvocateRequired As Nullable(Of Boolean)
            Dim dtDateLastSeenAlive As Nullable(Of Date)
            Dim strCauseOfDeath As String
            Dim strCodeForCauseOfDeath As String
            Dim blnCARelatedDeath As Nullable(Of Boolean)
            Dim blnDeathWithinHospital As Nullable(Of Boolean)
            Dim intHospitals As Nullable(Of Integer)
            Dim strExtraReferral As String
            Dim intConsultantNo As Nullable(Of Integer)
            Dim intHIVRisk As Nullable(Of Integer)
            Dim strOutcomeNotes As String
            Dim intUniqueHospitalId As Nullable(Of Integer)
            Dim blnGPReferralFlag As Nullable(Of Boolean)
            Dim strOwnedBy As String
            Dim blnHasImages As Nullable(Of Boolean)
            Dim strVerificationStatus As String
            Dim strMaritalStatus As String
            Dim objAddType() As ADDRESS_TYPE

            'Mahfuz added on 25th May 2021 - Handling Patient Registered GP
            Dim strRegisteredGPName As String = ""
            Dim strRegisteredGPCode As String = ""

            Dim intLocalGPId As Integer
            Dim intLocalPracticeId As Integer

            For Each objPItem As FindPatientItem In objPatients
                objDA = New DataAccess
                objEachPatientInformation = New PatientInformation

                objEachPatientInformation = GetPatientDetailsByWebservice(objPItem)

                If objEachPatientInformation IsNot Nothing Then

                    intPatientId = objPItem.PatientID
                    objAddType = objEachPatientInformation.BasicDemographics.PatientAddress
                    If Not objAddType Is Nothing Then
                        For Each objat As ADDRESS_TYPE In objAddType
                            If Not String.IsNullOrEmpty(objat.PostCode) Then
                                strPostCode = objat.PostCode
                            End If
                        Next
                    End If


                    strstrForename = objPItem.GivenName
                    strSurname = objPItem.FamilyName
                    dtDateOfBirth = objPItem.DateOfBirth

                    dtDateLastSeenAlive = Nothing

                    strGender = objPItem.Sex
                    strEthnicOrigin = objEachPatientInformation.SocialCircumstances.EthnicOrigin
                    blnJustDownloaded = True
                    strNotes = ""

                    If Not IsNothing(objEachPatientInformation.ExtendedDemographics) Then
                        '!!!!!!!!!!!!! ********************* NEED TO MAKE SURE!!! ?????
                        strCaseNoteNo = objEachPatientInformation.ExtendedDemographics.CurrentUID.IdValue

                        'CHI no is being saved as NHSNo in patient NHSNo table
                        If objEachPatientInformation.ExtendedDemographics.CurrentUID.IdScheme = "CHI" Then
                            strNHSNo = objEachPatientInformation.ExtendedDemographics.CurrentUID.IdValue.ToString()
                        End If

                        'Get Registered GP Related Information

                        'GetGPNameCodeFromSCIStorePatientObject(strRegisteredGPName, strRegisteredGPCode, objEachPatientInformation)

                        ProcessGPFromSciStore(intLocalGPId, objEachPatientInformation)


                        ProcessPracticeFromSciStore(intLocalPracticeId, objEachPatientInformation)


                        'Extract Address values
                        Dim objAddressType() As ADDRESS_TYPE
                        Dim objStructuredAddressType As STRUCTURED_ADDRESS_TYPE

                        objAddressType = objEachPatientInformation.BasicDemographics.PatientAddress
                        If Not IsNothing(objAddressType) Then
                            If objAddressType.Count > 0 Then
                                For i = 0 To objAddressType.Count - 1
                                    If objAddressType(i).AddressType.ToUpper() = "CURRENT" Then


                                        objStructuredAddressType = objAddressType(i).Item

                                        If Not IsNothing(objStructuredAddressType) Then


                                            If objStructuredAddressType.AddressLine.Count > 0 Then
                                                'Usually objAddressType.AddressLine will have 3 items/string array. Each for addressline
                                                '0 - Addressline1
                                                '1 - Addressline2
                                                '2 - Addressline3 or strTown
                                                For al = 0 To objStructuredAddressType.AddressLine.Count - 1
                                                    If al = 0 Then
                                                        strAddress1 = objStructuredAddressType.AddressLine(al).ToString()
                                                    ElseIf al = 1 Then
                                                        strAddress2 = objStructuredAddressType.AddressLine(al).ToString()
                                                    ElseIf al = 2 Then
                                                        strTown = objStructuredAddressType.AddressLine(al).ToString()
                                                    End If
                                                Next
                                            End If
                                        End If

                                    End If
                                Next
                            End If
                        End If

                        'MaritalStatus
                        strMaritalStatus = objEachPatientInformation.BasicDemographics.MaritalStatus

                        If Not objEachPatientInformation.ExtendedDemographics.DateOfDeath Is Nothing Then
                            dtDateLastSeenAlive = objEachPatientInformation.ExtendedDemographics.DateOfDeath
                        Else
                            dtDateLastSeenAlive = Nothing
                        End If

                        Try
                            If Not objEachPatientInformation.ExtendedDemographics Is Nothing Then
                                If Not objEachPatientInformation.ExtendedDemographics.GPpractice Is Nothing Then
                                    If Not objEachPatientInformation.ExtendedDemographics.GPpractice.OrganisationId Is Nothing Then
                                        If Not objEachPatientInformation.ExtendedDemographics.GPpractice.OrganisationId.IdValue Is Nothing Then
                                            If IsNumeric(objEachPatientInformation.ExtendedDemographics.GPpractice.OrganisationId.IdValue) Then
                                                intGPId = objEachPatientInformation.ExtendedDemographics.GPpractice.OrganisationId.IdValue
                                            End If
                                        End If
                                    End If
                                End If
                            End If

                        Catch ex As Exception

                        End Try



                        'dtDateLastSeenAlive = objEachPatientInformation.ExtendedDemographics.TimeofDeath
                        strCauseOfDeath = ""
                        strCodeForCauseOfDeath = ""
                        strVerificationStatus = objEachPatientInformation.ExtendedDemographics.CurrentPatientStatus
                    Else
                        Debug.WriteLine("Extended Demographics is nothing for Patient ID {0}", intPatientId)
                    End If


                    'Mahfuz added TrustId below on 25 May 2021
                    objDA.AddUpdatePatientFromWebService(intPatientId, strCaseNoteNo, strTitle, strstrForename, strSurname, dtDateOfBirth, strNHSNo,
strAddress1, strAddress2, strTown, strCounty, strPostCode, strPhoneNo, strGender, strEthnicOrigin, blnJustDownloaded, strNotes, strDistrict, strDHACode, intLocalGPId, intLocalPracticeId, dtDateOfDeath,
blnAdvocateRequired, dtDateLastSeenAlive, strCauseOfDeath, strCodeForCauseOfDeath, blnCARelatedDeath, blnDeathWithinHospital, intHospitals, strExtraReferral,
intConsultantNo, intHIVRisk, strOutcomeNotes, intUniqueHospitalId, blnGPReferralFlag, strOwnedBy, blnHasImages, strVerificationStatus, strMaritalStatus,
CInt(Session("TrustId")))
                End If


            Next
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ImportPatientsIntoDatabase()", ex)
            Return False
        End Try
    End Function
    'Mahfuz created new function for Scottish D&G - Saving patients in SE Local DB only when creating procedure
    Public Function ImportPatientsIntoDatabaseBySCIStorePatientID(intSCIStorePatientID As Integer) As Integer
        Try

            Dim objDA As DataAccess
            Dim objEachPatientInformation As PatientInformation

            Dim strCaseNoteNo As String
            Dim strTitle As String
            Dim strstrForename As String
            Dim strSurname As String
            Dim dtDateOfBirth As Date
            Dim strNHSNo As String
            Dim strAddress1 As String
            Dim strAddress2 As String
            Dim strTown As String
            Dim strCounty As String
            Dim strPostCode As String
            Dim strPhoneNo As String
            Dim strGender As String
            Dim strEthnicOrigin As String
            Dim blnJustDownloaded As Nullable(Of Boolean)
            Dim strNotes As String
            Dim strDistrict As String
            Dim strDHACode As String
            Dim intGPId As Nullable(Of Integer)
            Dim dtDateOfDeath As Nullable(Of Date)
            Dim blnAdvocateRequired As Nullable(Of Boolean)
            Dim dtDateLastSeenAlive As Nullable(Of Date)
            Dim strCauseOfDeath As String
            Dim strCodeForCauseOfDeath As String
            Dim blnCARelatedDeath As Nullable(Of Boolean)
            Dim blnDeathWithinHospital As Nullable(Of Boolean)
            Dim intHospitals As Nullable(Of Integer)
            Dim strExtraReferral As String
            Dim intConsultantNo As Nullable(Of Integer)
            Dim intHIVRisk As Nullable(Of Integer)
            Dim strOutcomeNotes As String
            Dim intUniqueHospitalId As Nullable(Of Integer)
            Dim blnGPReferralFlag As Nullable(Of Boolean)
            Dim strOwnedBy As String
            Dim blnHasImages As Nullable(Of Boolean)
            Dim strVerificationStatus As String
            Dim strMaritalStatus As String
            Dim objAddType() As ADDRESS_TYPE

            'Mahfuz added on 25th May 2021 - Handling Patient Registered GP
            Dim strRegisteredGPName As String = ""
            Dim strRegisteredGPCode As String = ""

            Dim intSELocalDBPatientID As Integer
            Dim intLocalGPId As Integer
            Dim intLocalPracticeId As Integer

            'For Each objPItem As FindPatientItem In objPatients
            objDA = New DataAccess
            objEachPatientInformation = New PatientInformation

            objEachPatientInformation = GetPatientDetailsBySCIStorePatientID(intSCIStorePatientID)

            If objEachPatientInformation IsNot Nothing Then


                objAddType = objEachPatientInformation.BasicDemographics.PatientAddress
                If Not objAddType Is Nothing Then
                    For Each objat As ADDRESS_TYPE In objAddType
                        If Not String.IsNullOrEmpty(objat.PostCode) Then
                            strPostCode = objat.PostCode
                        End If
                    Next
                End If

                Dim objPersonalNameTypes() As PERSONAL_NAME_TYPE
                Dim objStructuredNameType As New STRUCTURED_NAME_TYPE

                objPersonalNameTypes = objEachPatientInformation.BasicDemographics.PatientName

                For Each objPerName As PERSONAL_NAME_TYPE In objPersonalNameTypes
                    If objPerName.NameType = "Current" Then
                        objStructuredNameType = objPerName.Item
                        If Not objStructuredNameType Is Nothing Then
                            strTitle = objStructuredNameType.Title
                            strstrForename = objStructuredNameType.GivenName
                            strSurname = objStructuredNameType.FamilyName
                        End If
                    End If
                Next

                'strstrForename = objEachPatientInformation.BasicDemographics.Sex
                'strSurname = objPItem.FamilyName

                dtDateOfBirth = objEachPatientInformation.BasicDemographics.DateOfBirth

                dtDateLastSeenAlive = Nothing

                strGender = objEachPatientInformation.BasicDemographics.Sex
                strEthnicOrigin = objEachPatientInformation.SocialCircumstances.EthnicOrigin
                blnJustDownloaded = True
                strNotes = ""

                If Not IsNothing(objEachPatientInformation.ExtendedDemographics) Then
                    '!!!!!!!!!!!!! ********************* NEED TO MAKE SURE!!! ?????
                    'strCaseNoteNo = objEachPatientInformation.ExtendedDemographics.CurrentUID.IdValue

                    'CHI no is being saved as NHSNo in patient NHSNo table
                    If Not IsNothing(objEachPatientInformation.ExtendedDemographics.CurrentUID) Then
                        If Not IsNothing(objEachPatientInformation.ExtendedDemographics.CurrentUID.IdScheme) Then
                            If objEachPatientInformation.ExtendedDemographics.CurrentUID.IdScheme = "CHI" Then
                                strNHSNo = objEachPatientInformation.ExtendedDemographics.CurrentUID.IdValue.ToString()
                                strCaseNoteNo = strNHSNo 'For Scottish - D&G - Only CHI no is available. CHI no is being used for both NHSNo and CNN/HospitalNo
                            End If
                        End If
                    End If


                    'Get Registered GP Related Information

                    'GetGPNameCodeFromSCIStorePatientObject(strRegisteredGPName, strRegisteredGPCode, objEachPatientInformation)



                    ProcessGPFromSciStore(intLocalGPId, objEachPatientInformation)


                    ProcessPracticeFromSciStore(intLocalPracticeId, objEachPatientInformation)

                    'Extract Address values
                    Dim objAddressType() As ADDRESS_TYPE
                    Dim objStructuredAddressType As STRUCTURED_ADDRESS_TYPE
                    Dim objEachAddress As ADDRESS_TYPE
                    Dim strEachAddressLine() As String

                    objAddressType = objEachPatientInformation.BasicDemographics.PatientAddress
                    If Not IsNothing(objAddressType) Then
                        If objAddressType.Count > 0 Then
                            For i = 0 To objAddressType.Count - 1
                                If objAddressType(i).AddressType.ToUpper() = "CURRENT" Then


                                    '!! Same property of a class can be of different class/object for different patient!!. Need to check object type

                                    If objAddressType(i).Item.GetType() Is GetType(UnisoftERS.ScotHospitalWebservice.STRUCTURED_ADDRESS_TYPE) Then
                                        objStructuredAddressType = objAddressType(i).Item

                                        If Not IsNothing(objStructuredAddressType) Then


                                            If objStructuredAddressType.AddressLine.Count > 0 Then
                                                'Usually objAddressType.AddressLine will have 3 items/string array. Each for addressline
                                                '0 - Addressline1
                                                '1 - Addressline2
                                                '2 - Addressline3 or strTown
                                                For al = 0 To objStructuredAddressType.AddressLine.Count - 1
                                                    If al = 0 Then
                                                        strAddress1 = objStructuredAddressType.AddressLine(al).ToString()
                                                    ElseIf al = 1 Then
                                                        strAddress2 = objStructuredAddressType.AddressLine(al).ToString()
                                                    ElseIf al = 2 Then
                                                        strTown = objStructuredAddressType.AddressLine(al).ToString()
                                                    End If
                                                Next
                                            End If
                                        End If
                                    Else
                                        If objAddressType(i).Item.GetType() Is GetType(UnisoftERS.ScotHospitalWebservice.ADDRESS_TYPE) Then
                                            objEachAddress = objAddressType(i).Item
                                            strEachAddressLine = objEachAddress.Item.ToString().Split("|")
                                            Dim sCounter As Integer = 0

                                            For Each oStr As String In strEachAddressLine
                                                If sCounter = 0 Then
                                                    strAddress1 = oStr
                                                ElseIf sCounter = 1 Then
                                                    strAddress2 = oStr
                                                ElseIf sCounter = 2 Then
                                                    strTown = oStr
                                                ElseIf sCounter = 3 Then
                                                    strCounty = oStr
                                                End If
                                                sCounter = sCounter + 1
                                            Next
                                        ElseIf objAddressType(i).Item.GetType() Is GetType(System.String) Then
                                            strEachAddressLine = objAddressType(i).Item.ToString().Split("|")
                                            Dim sCounter As Integer = 0

                                            For Each oStr As String In strEachAddressLine
                                                If sCounter = 0 Then
                                                    strAddress1 = oStr
                                                ElseIf sCounter = 1 Then
                                                    strAddress2 = oStr
                                                ElseIf sCounter = 2 Then
                                                    strTown = oStr
                                                ElseIf sCounter = 3 Then
                                                    strCounty = oStr
                                                End If
                                                sCounter = sCounter + 1
                                            Next
                                        End If
                                    End If


                                End If
                            Next
                        End If
                    End If

                    'MaritalStatus
                    strMaritalStatus = objEachPatientInformation.BasicDemographics.MaritalStatus

                    If Not objEachPatientInformation.ExtendedDemographics.DateOfDeath Is Nothing Then
                        dtDateLastSeenAlive = objEachPatientInformation.ExtendedDemographics.DateOfDeath
                    Else
                        dtDateLastSeenAlive = Nothing
                    End If



                    'dtDateLastSeenAlive = objEachPatientInformation.ExtendedDemographics.TimeofDeath
                    strCauseOfDeath = ""
                    strCodeForCauseOfDeath = ""
                    strVerificationStatus = objEachPatientInformation.ExtendedDemographics.CurrentPatientStatus
                Else
                    Debug.WriteLine("Extended Demographics is nothing for Patient ID {0}", intSCIStorePatientID)
                End If



                intSELocalDBPatientID = objDA.AddUpdatePatientFromWebService(intSCIStorePatientID, strCaseNoteNo, strTitle, strstrForename, strSurname, dtDateOfBirth, strNHSNo,
strAddress1, strAddress2, strTown, strCounty, strPostCode, strPhoneNo, strGender, strEthnicOrigin, blnJustDownloaded, strNotes, strDistrict, strDHACode, intLocalGPId, intLocalPracticeId, dtDateOfDeath,
blnAdvocateRequired, dtDateLastSeenAlive, strCauseOfDeath, strCodeForCauseOfDeath, blnCARelatedDeath, blnDeathWithinHospital, intHospitals, strExtraReferral,
intConsultantNo, intHIVRisk, strOutcomeNotes, intUniqueHospitalId, blnGPReferralFlag, strOwnedBy, blnHasImages, strVerificationStatus, strMaritalStatus,
CInt(Session("TrustId")))
            End If

            Return intSELocalDBPatientID
            'Next
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ImportPatientsIntoDatabase()", ex)
            Return False
        End Try
    End Function
    Private Function ProcessGPFromSciStore(ByRef intLocalGPId As Integer, objPatient As PatientInformation)
        Try
            'Extract GP information
            'Required Info for GPs
            'Title 
            'Initial
            'ForeName
            'GPName
            'Email
            'Telephone

            'Mapped to SCIStore PatientInformation Object
            'PatientInformation-->BasicDemographics-->RegisteredGP

            Dim strSciStoreGPId As String = ""
            Dim strGPTitle As String = ""
            Dim strGPInitial As String = ""
            Dim strGPForeName As String = ""
            Dim strGPName As String = ""
            Dim strGPEmail As String = ""
            Dim da As New DataAccess

            Dim objHCPDetType As HCP_DETAIL_TYPE = New HCP_DETAIL_TYPE()
            Dim objPNT As PERSONAL_NAME_TYPE = New PERSONAL_NAME_TYPE()
            Dim objIDT As ID_TYPE()

            objHCPDetType = objPatient.BasicDemographics.RegisteredGp
            If Not IsNothing(objHCPDetType) Then
                objPNT = objHCPDetType.HcpName
                objIDT = objHCPDetType.HcpId

                If Not IsNothing(objPNT) Then
                    strGPName = objPNT.Item.ToString()
                End If
                If strGPName.Contains(",") Then
                    strGPForeName = strGPName.Split(",")(0).ToString()
                End If

                If Not IsNothing(objIDT) Then
                    For Each x As ID_TYPE In objIDT
                        If Not IsNothing(x.IdValue) Then
                            If x.IdValue.ToString().Trim() <> "" Then
                                strSciStoreGPId = x.IdValue
                                Exit For
                            End If
                        End If
                    Next
                End If

                da.InsertOrUpdateERS_GPS_FromSCIStore(intLocalGPId, strGPTitle, strGPInitial, strGPForeName, strGPName, strGPEmail, "", CInt(HttpContext.Current.Session("PKUserID")), strSciStoreGPId)
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ProcessGPFromSciStore()", ex)
        End Try
    End Function
    Private Function ProcessPracticeFromSciStore(ByRef intLocalPracticeId As Integer, objPatient As PatientInformation)
        Try
            '-------------------------------------------------
            'Extract Practice information
            'Required info for Practice
            'Code
            'NationalCode
            'Name [PracticeName]
            'Address1, Address2, Address3, Address4
            'Postcode
            'TelNo
            'Email

            'Mapped to SCIStore PatientInformation Object
            'objEachPatientInformation.ExtendedDemographics.GPpractice

            Dim da As New DataAccess
            Dim strSciStorePracticeId As String = ""
            Dim strPracticeCode As String = ""
            Dim strPracticeNationalCode As String = ""
            Dim strPracticeName As String = ""
            Dim strPracticeAddress1 As String = ""
            Dim strPracticeAddress2 As String = ""
            Dim strPracticeAddress3 As String = ""
            Dim strPracticeAddress4 As String = ""
            Dim strPracticePostcode As String = ""
            Dim strPracticeTelNo As String = ""
            Dim strPracticeEmail As String = ""

            Dim objPEinfo As PatientExtendedInformation = New PatientExtendedInformation()
            Dim objPractice As ORGANISATION_TYPE = New ORGANISATION_TYPE()
            Dim objPracticeAddress As ADDRESS_TYPE()
            Dim objAddressItem As STRUCTURED_ADDRESS_TYPE = New STRUCTURED_ADDRESS_TYPE()
            Dim strEachAddressLine As String()
            Dim adlinecounter As Integer = 1

            objPEinfo = objPatient.ExtendedDemographics
            If Not IsNothing(objPEinfo) Then
                objPractice = objPEinfo.GPpractice

                If Not IsNothing(objPractice) Then
                    If Not IsNothing(objPractice.OrganisationName) Then
                        strPracticeName = objPractice.OrganisationName
                    End If

                    'Unline GP, Practice has only one ID_Type object, not an array
                    If Not IsNothing(objPractice.OrganisationId) Then
                        If Not IsNothing(objPractice.OrganisationId.IdValue) Then
                            strPracticeCode = objPractice.OrganisationId.IdValue
                            strSciStorePracticeId = objPractice.OrganisationId.IdValue.ToString()
                        End If
                    End If

                    objPracticeAddress = objPractice.OrganisationAddress
                    If Not IsNothing(objPracticeAddress) Then
                        For Each x As ADDRESS_TYPE In objPracticeAddress
                            If Not IsNothing(x.PostCode) Then
                                If x.PostCode.Trim() <> "" Then
                                    strPracticePostcode = x.PostCode
                                    objAddressItem = x.Item
                                    strEachAddressLine = objAddressItem.AddressLine

                                    For Each al As String In strEachAddressLine
                                        If adlinecounter = 1 Then
                                            strPracticeAddress1 = al
                                        End If

                                        If adlinecounter = 2 Then
                                            strPracticeAddress2 = al
                                        End If

                                        If adlinecounter = 3 Then
                                            strPracticeAddress3 = al
                                        End If

                                        If adlinecounter = 4 Then
                                            strPracticeAddress4 = al
                                        End If

                                        adlinecounter = adlinecounter + 1
                                    Next

                                    Exit For
                                End If
                            End If
                        Next
                    End If

                End If
            End If

            da.InsertOrUpdateERS_Practices_FromSCIStore(intLocalPracticeId, strPracticeCode, strPracticeNationalCode, strPracticeName, strPracticeAddress1, strPracticeAddress2, strPracticeAddress3, strPracticeAddress4, strPracticePostcode, strPracticeTelNo, strPracticeEmail, CInt(HttpContext.Current.Session("PKUserID")), strSciStorePracticeId)

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ProcessPracticeFromSciStore()", ex)
        End Try
    End Function

    Private Function GetGPNameCodeFromSCIStorePatientObject(ByRef strRegGPName As String, ByRef strRegGPCode As String, objPatient As PatientInformation)
        Dim objHCPDetType As HCP_DETAIL_TYPE = New HCP_DETAIL_TYPE()
        Dim objPNT As PERSONAL_NAME_TYPE = New PERSONAL_NAME_TYPE()
        Dim objIDT As ID_TYPE()

        objHCPDetType = objPatient.BasicDemographics.RegisteredGp

        If Not IsNothing(objHCPDetType) Then
            objPNT = objHCPDetType.HcpName
            objIDT = objHCPDetType.HcpId

            If Not IsNothing(objPNT) Then
                strRegGPName = objPNT.Item.ToString()
            End If

            If Not IsNothing(objIDT) Then
                For Each x As ID_TYPE In objIDT
                    strRegGPCode = x.IdValue.ToString()
                    If strRegGPCode.Trim() <> "" Then
                        Exit For
                    End If
                Next
            End If

        End If
    End Function

    Private Function GetPatientSearchCriteriaFromSessionSearchFields() As FindPatientCriteria
        Dim objFPC As New FindPatientCriteria
        Dim dcPatientSearch As New Dictionary(Of String, String)

        dcPatientSearch = Session(Constants.SESSION_PATIENT_SEARCH_FIELDS)

        'CNN (Case Note No) - WS dont have

        'NHSNo - WS have HospitalID
        Dim objFpnc As FindPatientNameCriteria = New FindPatientNameCriteria
        Dim objFpdc As FindPatientCriteriaDate = New FindPatientCriteriaDate
        Dim objFpAc As FindPatientAddressCriteria = New FindPatientAddressCriteria
        Dim objFpIdC As FindPatientIDCriteria = New FindPatientIDCriteria

        Dim dtDateofBirth As DateTime

        'Mahfuz added on 09 June 2021
        'NHSNo or CHI no in SCI Store
        If dcPatientSearch("NHSNo") IsNot Nothing AndAlso Not (String.IsNullOrEmpty(dcPatientSearch("NHSNo"))) Then
            objFpIdC = New FindPatientIDCriteria
            objFpIdC.ID = dcPatientSearch("NHSNo")
            objFpIdC.IDcomparator = SearchComparator.contains
            objFpIdC.IDcomparatorSpecified = True

            objFPC.Ids = objFpIdC
        ElseIf dcPatientSearch("CaseNoteNo") IsNot Nothing AndAlso Not (String.IsNullOrEmpty(dcPatientSearch("CaseNoteNo"))) Then
            objFpIdC = New FindPatientIDCriteria
            objFpIdC.ID = dcPatientSearch("CaseNoteNo")
            objFpIdC.IDcomparator = SearchComparator.contains
            objFpIdC.IDcomparatorSpecified = True

            objFPC.Ids = objFpIdC
        End If

        'Surname
        If dcPatientSearch("Surname") IsNot Nothing AndAlso Not (String.IsNullOrEmpty(dcPatientSearch("Surname"))) Then
            objFpnc.Surname = dcPatientSearch("Surname")
            objFpnc.SurnameComparator = SearchComparator.soundex
            objFpnc.SurnameComparatorSpecified = True
        End If
        'Forename
        If dcPatientSearch("Forename") IsNot Nothing AndAlso Not (String.IsNullOrEmpty(dcPatientSearch("Forename"))) Then
            objFpnc.Forename = dcPatientSearch("Forename")
            objFpnc.ForenameComparator = SearchComparator.soundex
            objFpnc.ForenameComparatorSpecified = True
        End If
        objFPC.Name = objFpnc

        'DOB
        If dcPatientSearch("DOB") IsNot Nothing AndAlso Not (String.IsNullOrEmpty(dcPatientSearch("DOB"))) Then
            If IsDate(dcPatientSearch("DOB").ToString()) Then
                dtDateofBirth = Convert.ToDateTime(dcPatientSearch("DOB").ToString())
                'dtDateofBirth = Date.ParseExact(dcPatientSearch("DOB"), "yyyy/mm/dd", System.Globalization.DateTimeFormatInfo.InvariantInfo)
                objFpdc.DateOfBirth = dtDateofBirth
                objFpdc.DateOfBirthSpecified = True
            Else
                objFpdc.DateOfBirthSpecified = False
            End If
        Else
            objFpdc.DateOfBirthSpecified = False
        End If
        objFPC.Date = objFpdc

        'Gender
        If dcPatientSearch("Gender") IsNot Nothing AndAlso Not (String.IsNullOrEmpty(dcPatientSearch("Gender"))) Then
            If dcPatientSearch("Gender").ToString().Trim() <> "" Then
                objFPC.Sex = dcPatientSearch("Gender").ToString().Trim()
            Else
                objFPC.Sex = ""
            End If
        Else
            objFPC.Sex = ""
        End If

        'Address



        'Postcode
        If dcPatientSearch("Postcode") IsNot Nothing AndAlso Not (String.IsNullOrEmpty(dcPatientSearch("Postcode"))) Then
            objFpAc.Postcode = dcPatientSearch("Postcode")
            objFPC.Address = objFpAc
            objFPC.Address.PostCodeComparator = SearchComparator.contains
        End If

        'ExcludeDeceased
        If dcPatientSearch("IncludeDeceased") IsNot Nothing AndAlso Not (String.IsNullOrEmpty(dcPatientSearch("IncludeDeceased"))) Then
            If Convert.ToBoolean(dcPatientSearch("IncludeDeceased")) Then
                objFPC.IncludeInactiveDemographics = True
                objFPC.IncludeInactiveDemographicsSpecified = True
            Else
                objFPC.IncludeInactiveDemographics = False
                objFPC.IncludeInactiveDemographicsSpecified = True
            End If
        Else
            objFPC.IncludeInactiveDemographics = False
            objFPC.IncludeInactiveDemographicsSpecified = True
        End If

        Return objFPC
    End Function
    Public Function DisconnectService() As Boolean
        Dim _logout As Logout = New Logout
        _service.UserCredentials.Token = _token
        _service.Logout(_logout)
        _token = ""
        Return True
    End Function
End Class