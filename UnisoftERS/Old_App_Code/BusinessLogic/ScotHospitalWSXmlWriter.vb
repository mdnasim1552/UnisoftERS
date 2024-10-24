Imports System.Linq
Imports Microsoft.VisualBasic
Imports ERS.Data
Imports System.Data.SqlClient
Imports System.Reflection
Imports System.IO
Imports System.Drawing
Imports System.Xml
Imports System.Text
Imports System.Web.Hosting
Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.File
Imports DevExpress.ExpressApp.Web.Editors.ASPx
Imports System.Net
Imports System.Net.Http
Imports System.Net.Http.Headers
Imports System.Threading.Tasks
Imports DevExpress.XtraRichEdit.Import.Rtf

Public Class ScotHospitalWSXmlWriter
    Inherits System.Web.UI.Page
    Dim strXmlTempFileName As String
    Dim strXmlSchemaFile As String

    Dim strXmlTempOutputPath As String
    'Dim strTempFileName As String
    Dim strOutputFileName As String
    Dim strOutputFilePath As String
    Private _intProcedureID As Integer
    Private _strProcedureType As String
    Private _strSoftwareVersion As String
    Private _mainXmlDocument As XmlDocument
    Private _xmlDocAuthor As String
    Private _CDataHtmlContents As String

    Private strMainXmlContent As String
    Private lstStartedElement As List(Of String)

    Private repPrefix As String
    Private repPrefixValue As String

    Private sciPrefix As String
    Private sciPrefixValue As String

    Private genPrefix As String
    Private genPrefixValue As String

    Private xsdSchemaLocation As String

    Private strApplicationName As String

    Private dsProcedureData As DataSet
#Region "Patient related Variables"
    Private _intPatientID As Integer 'Mahfuz added on 23 June 2021
    Private strPatientNHSNo As String = "" 'Scottish CHI no is being saved in NHSNo column
    Private strPatientCRNno As String = ""

    Private strPatientTitle As String = ""
    Private strForename1 As String = ""
    Private strSurname As String = ""
    Private strAddress1 As String = ""
    Private strAddress2 As String = ""
    Private strTown As String = ""
    Private strPostCode As String = ""
    Private strTelephone As String = ""
    Private strDateOfBirth As String = ""
    Private strSex As String = ""
    Private strSexTitle As String = ""
    Private strMaritalStatus As String = ""
    Private strGPCompleteName As String = ""
    Private strGPName As String = ""

    Private strHospitalNo As String = ""
    Private strProcedure As String = ""
    Private strUniqueExaminationID As String = ""
    Private strExaminationName As String = ""
    Private strExaminationCode As String = ""
    Private dtExaminationDateTime As DateTime
    Private blnExaminationDateTime As Boolean = False
    Private strReferralConsultantNo As String = ""
    Private strReferralDoctorCode As String = ""
    Private strPracticeCode As String = "" 'MH added on 27 Aug 2021
    Private strReferralDoctorName As String = ""
    Private strReferralDoctorGroupName As String = ""
    Private strEndoscopistName As String = ""
    Private strListConsultantCode As String = ""
    Private strListConsultantName As String = ""
    Private strConsultantSpecialityID As String = ""
    Private strConsultantSpecialty As String = ""
    Private strNurse1Name As String = ""
    Private strNurse2Name As String = ""
    Private strPatientStatus As String = ""
    Private strProcedurePriority As String = "" 'CategoryListId
    Private strHospitalName As String = ""
    Private strHospitalPhoneNumber As String = ""
    Private strPatientCurrentLocationCode As String = ""
    Private strPatientCurrentLocationName As String = ""
    Private strGpCode As String = ""
    Private strPracticeName As String = ""
    Private strPracticeAddress1 As String = ""
    Private strPracticeAddress2 As String = ""
    Private strPracticeAddress3 As String = ""
    Private strPracticeAddress4 As String = ""
    Private strPracticePostCode As String = ""
    Private intDocumentRevisionNo As Integer = 0
    Private dtDocumentCreationDateTime As DateTime
    Private dtDocumentAttestationDateTime As DateTime


#End Region



    Public Sub New()
        strXmlTempOutputPath = Path.Combine(GetEnvironmentRoot, "tmp_result_xml_files\")


        strOutputFilePath = Nothing
        'strOutputFilePath = Global.UnisoftERS.My.MySettings.Default.UnisoftERS_ScotHospitalWebservice_SCIStoreResultXmlOutputPath
        'Mahfuz changed as below on 19 May 2021
        strOutputFilePath = ConfigurationManager.AppSettings("UnisoftERS_ScotHospitalWebservice_SCIStoreResultXmlOutputPath").ToString()
        If ConfigurationManager.AppSettings("IsAzure").ToLower() <> "true" Then
            CreateOutputDirectory(strOutputFilePath)
        End If

        repPrefix = "rep"
        repPrefixValue = "http://www.show.scot.nhs.uk/isd/TestReport"

        sciPrefix = "sci"
        sciPrefixValue = "http://www.show.scot.nhs.uk/isd/SCIStore"

        genPrefix = "gen"
        genPrefixValue = "http://www.show.scot.nhs.uk/isd/General"

        xsdSchemaLocation = "http://www.show.scot.nhs.uk/isd/TestReport InvestigationReport-v4-0.xsd"

        _strSoftwareVersion = "Ver.2.04.3"

        _xmlDocAuthor = "Sean DRozario"

        _CDataHtmlContents = ""

        strApplicationName = "Solus Endoscopy"
    End Sub
    Private Sub CreateTempDirectory(strTempXmlPath As String)
        If Directory.Exists(strTempXmlPath) Then
            Directory.Delete(strTempXmlPath, True)
        End If

        Directory.CreateDirectory(strTempXmlPath)
    End Sub
    Private Sub CreateOutputDirectory(strOutDir As String)
        If Directory.Exists(strOutDir) Then
            'Directory.Delete(strOutDir, True)
        Else
            Directory.CreateDirectory(strOutDir)
        End If


    End Sub
    Private Sub PopulateLocalVariablesFromDataset()
        'Populating local variables from Dataset
        If dsProcedureData.Tables(0).Rows.Count > 0 Then
            _intPatientID = Convert.ToInt32(dsProcedureData.Tables(0).Rows(0)("PatientID").ToString())

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("NHSNo")) Then
                strPatientNHSNo = dsProcedureData.Tables(0).Rows(0)("NHSNo").ToString()
            Else
                strPatientNHSNo = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PatientTitle")) Then
                strPatientTitle = dsProcedureData.Tables(0).Rows(0)("PatientTitle").ToString()
            Else
                strPatientTitle = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("Forename1")) Then
                strForename1 = dsProcedureData.Tables(0).Rows(0)("Forename1").ToString()
            Else
                strForename1 = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("Surname")) Then
                strSurname = dsProcedureData.Tables(0).Rows(0)("Surname").ToString()
            Else
                strSurname = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("address1")) Then
                strAddress1 = dsProcedureData.Tables(0).Rows(0)("address1").ToString()
            Else
                strAddress1 = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("address2")) Then
                strAddress2 = dsProcedureData.Tables(0).Rows(0)("address2").ToString()
            Else
                strAddress2 = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("address3")) Then
                strTown = dsProcedureData.Tables(0).Rows(0)("address3").ToString()
            Else
                strTown = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("Postcode")) Then
                strPostCode = dsProcedureData.Tables(0).Rows(0)("Postcode").ToString()
            Else
                strPostCode = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("Telephone")) Then
                strTelephone = dsProcedureData.Tables(0).Rows(0)("Telephone").ToString()
            Else
                strTelephone = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("DateOfBirth")) Then
                strDateOfBirth = Convert.ToDateTime(dsProcedureData.Tables(0).Rows(0)("DateOfBirth")).ToString("yyyy-MM-dd")
            Else
                strDateOfBirth = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("Sex")) Then
                strSex = dsProcedureData.Tables(0).Rows(0)("Sex").ToString()
            Else
                strSex = ""
            End If
            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("SexTitle")) Then
                strSexTitle = dsProcedureData.Tables(0).Rows(0)("SexTitle").ToString()
            Else
                strSexTitle = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("MaritalStatus")) Then
                strMaritalStatus = dsProcedureData.Tables(0).Rows(0)("MaritalStatus").ToString()
            Else
                strMaritalStatus = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("GPName")) Then
                strGPName = dsProcedureData.Tables(0).Rows(0)("GPName").ToString()
            Else
                strGPName = ""
            End If
            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("GPCompleteName")) Then
                strGPCompleteName = dsProcedureData.Tables(0).Rows(0)("GPCompleteName").ToString()
            Else
                strGPCompleteName = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("HospitalNumber")) Then
                strHospitalNo = dsProcedureData.Tables(0).Rows(0)("HospitalNumber").ToString()
            Else
                strHospitalNo = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("Procedure")) Then
                strProcedure = dsProcedureData.Tables(0).Rows(0)("Procedure").ToString()
            Else
                strProcedure = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("UniqueExaminationID")) Then
                strUniqueExaminationID = dsProcedureData.Tables(0).Rows(0)("UniqueExaminationID").ToString()
            Else
                strUniqueExaminationID = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ExaminationName")) Then
                strExaminationName = dsProcedureData.Tables(0).Rows(0)("ExaminationName").ToString()
            Else
                strExaminationName = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ExaminationCode")) Then
                strExaminationCode = dsProcedureData.Tables(0).Rows(0)("ExaminationCode").ToString()
            Else
                strExaminationCode = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ExaminationDateTime")) Then

                If DateTime.TryParse(dsProcedureData.Tables(0).Rows(0)("ExaminationDateTime").ToString(), dtExaminationDateTime) Then
                    blnExaminationDateTime = True
                Else
                    blnExaminationDateTime = False
                End If
            Else
                blnExaminationDateTime = False
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ReferralConsultantNo")) Then
                strReferralConsultantNo = dsProcedureData.Tables(0).Rows(0)("ReferralConsultantNo").ToString()
            Else
                strReferralConsultantNo = ""
            End If


            'Mahfuz added on 23 June 2021 - for Stoke export
            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("SpecialtyID")) Then
                strConsultantSpecialityID = dsProcedureData.Tables(0).Rows(0)("SpecialtyID").ToString()
            Else
                strConsultantSpecialityID = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ConsultantSpecialty")) Then
                strConsultantSpecialty = dsProcedureData.Tables(0).Rows(0)("ConsultantSpecialty").ToString()
            Else
                strConsultantSpecialty = ""
            End If


            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ReferralDoctorCode")) Then
                strReferralDoctorCode = dsProcedureData.Tables(0).Rows(0)("ReferralDoctorCode").ToString()
            Else
                strReferralDoctorCode = ""
            End If

            'MH added on 27 Aug 2021
            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PracticeCode")) Then
                strPracticeCode = dsProcedureData.Tables(0).Rows(0)("PracticeCode").ToString()
            Else
                strPracticeCode = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ReferralDoctorName")) Then
                strReferralDoctorName = dsProcedureData.Tables(0).Rows(0)("ReferralDoctorName").ToString()
            Else
                strReferralDoctorName = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ReferralDoctorGroupName")) Then
                strReferralDoctorGroupName = dsProcedureData.Tables(0).Rows(0)("ReferralDoctorGroupName").ToString()
            Else
                strReferralDoctorGroupName = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("EndoscopistName")) Then
                strEndoscopistName = dsProcedureData.Tables(0).Rows(0)("EndoscopistName").ToString()
            Else
                strEndoscopistName = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ListConsultantCode")) Then
                strListConsultantCode = dsProcedureData.Tables(0).Rows(0)("ListConsultantCode").ToString()
            Else
                strListConsultantCode = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ListConsultantName")) Then
                strListConsultantName = dsProcedureData.Tables(0).Rows(0)("ListConsultantName").ToString()
            Else
                strListConsultantName = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("Nurse1Name")) Then
                strNurse1Name = dsProcedureData.Tables(0).Rows(0)("Nurse1Name").ToString()
            Else
                strNurse1Name = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("Nurse2Name")) Then
                strNurse2Name = dsProcedureData.Tables(0).Rows(0)("Nurse2Name").ToString()
            Else
                strNurse2Name = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PatientStatus")) Then
                strPatientStatus = dsProcedureData.Tables(0).Rows(0)("PatientStatus").ToString()
            Else
                strPatientStatus = ""
            End If

            'Mahfuz changed on 30 June 2021
            'If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("CategoryListId")) Then
            '    strProcedurePriority = dsProcedureData.Tables(0).Rows(0)("CategoryListId").ToString()
            'Else
            '    strProcedurePriority = ""
            'End If
            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("ProcedurePriority")) Then
                strProcedurePriority = dsProcedureData.Tables(0).Rows(0)("ProcedurePriority").ToString().Replace("[NED]", "")
            Else
                strProcedurePriority = ""
            End If


            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("HospitalName")) Then
                strHospitalName = dsProcedureData.Tables(0).Rows(0)("HospitalName").ToString()
            Else
                strHospitalName = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("HospitalPhoneNumber")) Then
                strHospitalPhoneNumber = dsProcedureData.Tables(0).Rows(0)("HospitalPhoneNumber").ToString()
            Else
                strHospitalPhoneNumber = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PatientCurrentLocationCode")) Then
                strPatientCurrentLocationCode = dsProcedureData.Tables(0).Rows(0)("PatientCurrentLocationCode").ToString()
            Else
                strPatientCurrentLocationCode = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PatientCurrentLocationName")) Then
                strPatientCurrentLocationName = dsProcedureData.Tables(0).Rows(0)("PatientCurrentLocationName").ToString()
            Else
                strPatientCurrentLocationName = ""
            End If
            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("GPCode")) Then
                strGpCode = dsProcedureData.Tables(0).Rows(0)("GPCode").ToString()
            Else
                strGpCode = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PracticeName")) Then
                strPracticeName = dsProcedureData.Tables(0).Rows(0)("PracticeName").ToString()
            Else
                strPracticeName = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PracticeAddress1")) Then
                strPracticeAddress1 = dsProcedureData.Tables(0).Rows(0)("PracticeAddress1").ToString()
            Else
                strPracticeAddress1 = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PracticeAddress2")) Then
                strPracticeAddress2 = dsProcedureData.Tables(0).Rows(0)("PracticeAddress2").ToString()
            Else
                strPracticeAddress2 = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PracticeAddress3")) Then
                strPracticeAddress3 = dsProcedureData.Tables(0).Rows(0)("PracticeAddress3").ToString()
            Else
                strPracticeAddress3 = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PracticeAddress4")) Then
                strPracticeAddress4 = dsProcedureData.Tables(0).Rows(0)("PracticeAddress4").ToString()
            Else
                strPracticeAddress4 = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("PracticePostCode")) Then
                strPracticePostCode = dsProcedureData.Tables(0).Rows(0)("PracticePostCode").ToString()
            Else
                strPracticePostCode = ""
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("DocumentCreationDateTime")) Then
                dtDocumentCreationDateTime = Convert.ToDateTime(dsProcedureData.Tables(0).Rows(0)("DocumentCreationDateTime").ToString())
            Else
                dtDocumentCreationDateTime = DateTime.Now
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("DocumentRevisionNo")) Then
                intDocumentRevisionNo = Convert.ToInt32(dsProcedureData.Tables(0).Rows(0)("DocumentRevisionNo").ToString())
            Else
                intDocumentRevisionNo = 1
            End If

            If Not IsDBNull(dsProcedureData.Tables(0).Rows(0)("DocumentAttestationDateTime")) Then

                If DateTime.TryParse(dsProcedureData.Tables(0).Rows(0)("DocumentAttestationDateTime").ToString(), dtDocumentAttestationDateTime) Then
                Else
                    dtDocumentAttestationDateTime = DateTime.Now
                End If
            Else
                dtDocumentAttestationDateTime = DateTime.Now
            End If


        End If

    End Sub

    Public Function GenerateResultXmlFile(intProcedureId As Integer, strProcedureType As String, strSoftwareVersion As String)
        Try
            Dim strReportDocumentExportApiUrl As String = ""
            Dim DocumentExportSharedLocation As String = ""
            Dim ReportSharedDriveAccessUser As String = ""
            Dim SharedDriveAccessUserPassword As String = ""
            Dim DirectoryNameForXmlTransferInAzure As String = "xml-transfer"
            Dim dtXmlTransferVariables As New DataTable



            _intProcedureID = intProcedureId
            _strSoftwareVersion = strSoftwareVersion

            dsProcedureData = New DataSet

            Dim da As New DataAccess

#Region "Xml doc transfer related config variables"
            dtXmlTransferVariables = da.GetExportDocumentToApiConfigVariables(CInt(Session("OperatingHospitalID")))
            If dtXmlTransferVariables.Rows.Count > 0 Then
                If Not IsNothing(dtXmlTransferVariables.Rows(0)("ReportDocumentExportApiUrl")) And dtXmlTransferVariables.Rows(0)("ReportDocumentExportApiUrl").ToString().Trim() <> "" Then
                    strReportDocumentExportApiUrl = dtXmlTransferVariables.Rows(0)("ReportDocumentExportApiUrl").ToString()
                End If

                If Not IsNothing(dtXmlTransferVariables.Rows(0)("DocumentExportSharedLocation")) And dtXmlTransferVariables.Rows(0)("DocumentExportSharedLocation").ToString().Trim() <> "" Then
                    DocumentExportSharedLocation = dtXmlTransferVariables.Rows(0)("DocumentExportSharedLocation").ToString()
                End If

                If Not IsNothing(dtXmlTransferVariables.Rows(0)("ReportSharedDriveAccessUser")) And dtXmlTransferVariables.Rows(0)("ReportSharedDriveAccessUser").ToString().Trim() <> "" Then
                    ReportSharedDriveAccessUser = dtXmlTransferVariables.Rows(0)("ReportSharedDriveAccessUser").ToString()
                End If

                If Not IsNothing(dtXmlTransferVariables.Rows(0)("SharedDriveAccessUserPassword")) And dtXmlTransferVariables.Rows(0)("SharedDriveAccessUserPassword").ToString().Trim() <> "" Then
                    SharedDriveAccessUserPassword = dtXmlTransferVariables.Rows(0)("SharedDriveAccessUserPassword").ToString()
                End If

                If Not IsNothing(dtXmlTransferVariables.Rows(0)("DirectoryNameForXmlTransferInAzure")) And dtXmlTransferVariables.Rows(0)("DirectoryNameForXmlTransferInAzure").ToString().Trim() <> "" Then
                    DirectoryNameForXmlTransferInAzure = dtXmlTransferVariables.Rows(0)("DirectoryNameForXmlTransferInAzure").ToString()
                End If
            End If
#End Region




            dsProcedureData = da.GetProcedureDataForFileDataExport(_intProcedureID)
            PopulateLocalVariablesFromDataset()

            strOutputFileName = ""
            strOutputFileName = intProcedureId.ToString() & "_" & strProcedure.ToString() & "_Test_" & DateTime.Now.ToString("ddMMyyyy HHmmss")

            CreateDocumentHeader()

            'The full xmlDocument has two main part.
            '1. Report Data
            '2. Document Data
            '2.a - Site details and photo - ERS_Sites and ERS_Photos
            '2.b - Document - ERS_DocumentStore

            '1. Generate Report Data section
            GenerateReportDataSection()

            '2. Generate Document Data section
            GenerateDocumentDataSection()

            '1. Element rep:TestReport


            'Save xmlDocument to temp location
            CreateOutputDirectory(strOutputFilePath)
            If ConfigurationManager.AppSettings("IsAzure").ToUpper() <> "TRUE" Then
                CreateOutputDirectory(strOutputFilePath)
                _mainXmlDocument.Save(strOutputFilePath & "\" & strOutputFileName + ".xml")
            Else

                If ConfigurationManager.AppSettings.AllKeys.Contains("ReportDocumentExportApiUrl") Then
                    If ConfigurationManager.AppSettings("ReportDocumentExportApiUrl").ToString().Trim() <> "" Then
                        strReportDocumentExportApiUrl = ConfigurationManager.AppSettings("ReportDocumentExportApiUrl").ToString().Trim()
                    End If
                End If
                If strReportDocumentExportApiUrl = "" Then
                    'Save XML document to Azure BlobStorage
                    Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureFileStorageAccount"))
                    Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
                    Dim share As CloudFileShare = fileClient.GetShareReference(DirectoryNameForXmlTransferInAzure)
                    Dim msXmlDoc As New MemoryStream()

                    share.CreateIfNotExists()

                    Dim cfd As CloudFileDirectory = share.GetRootDirectoryReference()
                    Dim objCloudFile As CloudFile = cfd.GetFileReference(strOutputFileName + ".xml")


                    _mainXmlDocument.Save(msXmlDoc)

                    msXmlDoc.Flush()
                    msXmlDoc.Position = 0

                    objCloudFile.Create(msXmlDoc.Length)
                    objCloudFile.UploadFromStream(msXmlDoc)
                Else
                    'Send the Xml File Content to the API
                    'Dim xmlDocStringWriter As StringWriter = New StringWriter(New StringBuilder())
                    'Dim settings As XmlWriterSettings = New XmlWriterSettings()
                    'settings.CloseOutput = True
                    'settings.Encoding = Encoding.UTF8
                    'settings.OmitXmlDeclaration = True
                    'settings.Indent = True
                    'settings.IndentChars = ControlChars.Tab
                    'settings.NewLineChars = Environment.NewLine
                    'settings.NewLineOnAttributes = True

                    'Dim sw As New IO.StringWriter
                    'Dim xw As XmlWriter
                    'xw = XmlWriter.Create(sw, settings)

                    '_mainXmlDocument.WriteContentTo(xw)
                    'xw.Close()



                    SendXmlDocumentStringDataToApi(strReportDocumentExportApiUrl, DocumentExportSharedLocation, ReportSharedDriveAccessUser, SharedDriveAccessUserPassword, strOutputFileName + ".xml", _mainXmlDocument.OuterXml)

                End If
            End If
            'AddExportFileForMirth here based on Condition
            'MH added on 18 Nov 2021 - TFS 1779 - ICE Interface with Mirth
            If Session(Constants.SESSION_ADD_EXPORT_FILE_FOR_MIRTH) = True Then
                Dim strMessage As String = ""
                Dim intOutputDocumentStoreId As Int32 = 0

                Dim FileContentsBytesArray() As Byte
                FileContentsBytesArray = System.Text.Encoding.Unicode.GetBytes(_mainXmlDocument.OuterXml)



                strMessage = strOutputFilePath & "\" & strOutputFileName & ".xml"

                da.InsertExportFileProcessToMirth(strMessage, FileContentsBytesArray, strMessage, strOutputFilePath, strOutputFileName + ".xml", intOutputDocumentStoreId)

                If intOutputDocumentStoreId > 0 Then
                    If IsNothing(Session("DocumentStoreIdList")) Then
                        Session("DocumentStoreIdList") = intOutputDocumentStoreId.ToString()
                    ElseIf (Session("DocumentStoreIdList") = "") Then
                        Session("DocumentStoreIdList") = intOutputDocumentStoreId.ToString()
                    Else
                        Session("DocumentStoreIdList") = Session("DocumentStoreIdList") + "," + intOutputDocumentStoreId.ToString()
                    End If
                End If
            End If
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ConnectWebservice()", ex)
            Return False
        End Try
    End Function
    Public Function SendXmlDocumentStringDataToApi(ApiEndPointUrl As String, DocumentExportSharedLocation As String, ReportSharedDriveAccessUser As String, SharedDriveAccessUserPassword As String, ReportDocFileName As String, ReportDocumentContents As String) As Task
        Try


            Dim objHttpClient As New HttpClient()
            objHttpClient.BaseAddress = New Uri(ApiEndPointUrl)
            Dim objApiConfigData As New XmlDocApiConfigVariable

            objApiConfigData.ApiSecKey = "alj&*817Lsjeyu"
            objApiConfigData.XmlDocFileName = ReportDocFileName
            objApiConfigData.XmlDocFileContent = ReportDocumentContents
            objApiConfigData.DocumentExportSharedLocation = DocumentExportSharedLocation
            objApiConfigData.ReportSharedDriveAccessUser = ReportSharedDriveAccessUser
            objApiConfigData.SharedDriveAccessUserPassword = SharedDriveAccessUserPassword

            'Dim dictData As Dictionary(Of String, Object)
            'dictData = New Dictionary(Of String, Object)
            'dictData.Add("Key", "alj&*817Lsjeyu")
            'dictData.Add("FileName", ReportDocFileName)
            'dictData.Add("FileContent", ReportDocumentContents)
            'dictData.Add("objConfigData", objApiConfigData)

            Dim buffer = Encoding.UTF8.GetBytes(Newtonsoft.Json.JsonConvert.SerializeObject(objApiConfigData))
            Dim bytes = New ByteArrayContent(buffer)
            bytes.Headers.ContentType = New Headers.MediaTypeHeaderValue("application/json")

            Dim request1 = objHttpClient.PostAsync(ApiEndPointUrl, bytes)
            request1.Wait()

            Dim result = request1.Result

            If result.IsSuccessStatusCode Then

            Else

            End If



        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in SendXmlDocumentStringDataToApi()", ex)
        End Try
    End Function
    Public Function GetHTML_ContentsOfProcedureTestReulsts(intProcedureId As Integer, strSoftwareVersion As String) As String
        Try
            Dim strHtmlContents As String = ""

            _intProcedureID = intProcedureId
            _strSoftwareVersion = strSoftwareVersion

            dsProcedureData = New DataSet
            Dim da As New DataAccess
            dsProcedureData = da.GetProcedureDataForFileDataExport(_intProcedureID)
            PopulateLocalVariablesFromDataset()

            GenerateCDataHTMLContents()

            strHtmlContents = _CDataHtmlContents.Replace("<![CDATA[", "").Replace("]]>", "")

            strHtmlContents = strHtmlContents.Trim()

            Return strHtmlContents
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetHTML_ContentsOfProcedureTestReulsts()", ex)
            Return ""
        End Try
    End Function
    Public Function GetXML_ContentsOfProcedureTestReulsts(intProcedureId As Integer, strSoftwareVersion As String) As String
        Try
            Dim strXMLContents As String = ""

            _intProcedureID = intProcedureId
            _strSoftwareVersion = strSoftwareVersion

            dsProcedureData = New DataSet
            Dim da As New DataAccess
            dsProcedureData = da.GetProcedureDataForFileDataExport(_intProcedureID)
            PopulateLocalVariablesFromDataset()

            strXMLContents = GetXMLDataContents()

            strXMLContents = strXMLContents.Trim()

            Return strXMLContents
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetXML_ContentsOfProcedureTestReulsts()", ex)
            Return ""
        End Try
    End Function
    Private Function GetXMLDataContents()
        Try
            Dim strXMLContents As String = ""

            strXMLContents = "<?xml version=""1.0"" encoding=""iso-8859-1""?>" & vbCrLf

            strXMLContents = strXMLContents & "<DOCUMENT>" & vbCrLf

            strXMLContents = strXMLContents & "<DOC>" & vbCrLf

            strXMLContents = strXMLContents & "<system>" & "HD Clinical" & "</system>" & vbCrLf

            '*************** gEpisodeNo ?? Assuming ProcedureID
            strXMLContents = strXMLContents & "<localid>" & dtDocumentCreationDateTime.ToString("") & "</localid>" & vbCrLf

            '*******??? Hard coded dictated in old UGI
            strXMLContents = strXMLContents & "<dictated />" & vbCrLf 'MH corrected mistyped on 27 Aug 2021
            '*******??? Hard coded dictatedby in old UGI
            strXMLContents = strXMLContents & "<dictatedby />" & vbCrLf

            strXMLContents = strXMLContents & "<created>" & dtExaminationDateTime.ToString("yyyyMMdd HH:mm:ss") & "</created>" & vbCrLf

            strXMLContents = strXMLContents & "<typedby />" & vbCrLf

            strXMLContents = strXMLContents & "<signed>" & dtDocumentCreationDateTime.ToString("yyyyMMdd HH:mm:ss") & "</signed>" & vbCrLf

            strXMLContents = strXMLContents & "<signedby>" & SanitizeStringForXml(strEndoscopistName) & "</signedby>" & vbCrLf

            strXMLContents = strXMLContents & "<hospital>" & SanitizeStringForXml(strHospitalName) & "</hospital>" & vbCrLf

            strXMLContents = strXMLContents & "<departmentcode>GASTRO</departmentcode>" & vbCrLf 'Hard coded GASTRO used on 27 Aug 2021

            strXMLContents = strXMLContents & "<department>" & SanitizeStringForXml(strPatientCurrentLocationName) & "</department>" & vbCrLf 'Patient Ward

            'strXMLContents = strXMLContents & "<specialtycode>" & SanitizeStringForXml(strConsultantSpecialityID) & "</specialtycode>" & vbCrLf 'Changed to specialtycode on 15 Sept 2021
            strXMLContents = strXMLContents & "<specialtycode></specialtycode>" & vbCrLf 'Changed to specialtycode on 15 Sept 2021 : We don't have specialtycode for Endoscopist/list consultant

            strXMLContents = strXMLContents & "<specialty>" & SanitizeStringForXml(strConsultantSpecialty) & "</specialty>" & vbCrLf

            strXMLContents = strXMLContents & "<consultantcode>" & SanitizeStringForXml(strListConsultantCode) & "</consultantcode>" & vbCrLf

            strXMLContents = strXMLContents & "<consultant>" & SanitizeStringForXml(strListConsultantName) & "</consultant>" & vbCrLf

            'doctype is set to 1 hard coded in old UGI
            strXMLContents = strXMLContents & "<doctype>" & "1" & "</doctype>" & vbCrLf

            'sendtogp is set to Y hard coded in old UGI
            strXMLContents = strXMLContents & "<sendtogp>" & "Y" & "</sendtogp>" & vbCrLf

            strXMLContents = strXMLContents & "<visitkey />" & vbCrLf

            'Ben asked to remove this <doccompiledon> tag : changes on 27 Aug 2021
            'strXMLContents = strXMLContents & "<doccompiledon>" & DateTime.Now.ToString("yyyyMMdd hh:mm:ss") & "</doccompiledon>" & vbCrLf

            strXMLContents = strXMLContents & "</DOC>" & vbCrLf

            strXMLContents = strXMLContents & "<MPI>" & vbCrLf


            strXMLContents = strXMLContents & "<patno>" & SanitizeStringForXml(strHospitalNo) & "</patno>" & vbCrLf
            strXMLContents = strXMLContents & "<title>" & SanitizeStringForXml(strPatientTitle) & "</title>" & vbCrLf
            strXMLContents = strXMLContents & "<forename>" & SanitizeStringForXml(strForename1) & "</forename>" & vbCrLf
            strXMLContents = strXMLContents & "<surname>" & SanitizeStringForXml(strSurname) & "</surname>" & vbCrLf

            If strDateOfBirth.Trim() <> "" Then
                strXMLContents = strXMLContents & "<dob>" & DateTime.ParseExact(strDateOfBirth, "yyyy-MM-dd", Nothing).ToString("yyyyMMdd") & "</dob>" & vbCrLf
            Else
                strXMLContents = strXMLContents & "<dob />" & vbCrLf
            End If

            'strXMLContents = strXMLContents & "<gender>" & SanitizeStringForXml(strSex) & "</gender>" & vbCrLf Mahfuz changed as below:

            strXMLContents = strXMLContents & "<sex>" & SanitizeStringForXml(strSex) & "</sex>" & vbCrLf

            strXMLContents = strXMLContents & "<nhsno>" & SanitizeStringForXml(strPatientNHSNo) & "</nhsno>" & vbCrLf

            Dim strNHSStatus As String = ""
            If strPatientNHSNo.Trim() <> "" Then
                If Utilities.ValidateNHSNo(strPatientNHSNo) Then
                    strNHSStatus = "1"
                Else
                    strNHSStatus = "0"
                End If
            Else
                strNHSStatus = "0"
            End If

            strXMLContents = strXMLContents & "<nhsnostatus>" & strNHSStatus & "</nhsnostatus>" & vbCrLf

            strXMLContents = strXMLContents & "<gpcode>" & SanitizeStringForXml(strGpCode) & "</gpcode>" & vbCrLf
            'strXMLContents = strXMLContents & "<gpname>" & SanitizeStringForXml(strGPName) & "</gpname>" & vbCrLf

            'MH changed on 27 Aug 2021
            'strXMLContents = strXMLContents & "<practicecode>" & SanitizeStringForXml(strReferralDoctorCode) & "</practicecode>" & vbCrLf
            strXMLContents = strXMLContents & "<practicecode>" & SanitizeStringForXml(strPracticeCode) & "</practicecode>" & vbCrLf
            'Patient Address info
            strXMLContents = strXMLContents & "<addr1>" & SanitizeStringForXml(strAddress1) & "</addr1>" & vbCrLf
            strXMLContents = strXMLContents & "<addr2>" & SanitizeStringForXml(strAddress2) & "</addr2>" & vbCrLf
            strXMLContents = strXMLContents & "<addr3 />" & vbCrLf
            strXMLContents = strXMLContents & "<addr4 />" & vbCrLf

            strXMLContents = strXMLContents & "<postcode>" & SanitizeStringForXml(strPostCode) & "</postcode>" & vbCrLf
            'strXMLContents = strXMLContents & "<gpcode>" & SanitizeStringForXml(strGpCode) & "</gpcode>" & vbCrLf 'MH fixed on 16 Sept 2021 added above

            strXMLContents = strXMLContents & "<telhome>" & SanitizeStringForXml(strTelephone) & "</telhome>" & vbCrLf
            strXMLContents = strXMLContents & "<telwork />" & vbCrLf
            strXMLContents = strXMLContents & "</MPI>" & vbCrLf

            Dim strTrustCode As String = ""
            Dim objDa As New DataAccess

            strTrustCode = objDa.GetTrustCodeByTrustID(CInt(HttpContext.Current.Session("TrustId")))

            strXMLContents = strXMLContents & "<applicationdata>" & vbCrLf
            strXMLContents = strXMLContents & "<trust>" & SanitizeStringForXml(strTrustCode) & "</trust>" & vbCrLf
            strXMLContents = strXMLContents & "<content>" & "FILEPAIR" & "</content>" & vbCrLf

            If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.XML_and_HTML Then
                strXMLContents = strXMLContents & "<contenttype>" & "HTML" & "</contenttype>" & vbCrLf
            Else
                strXMLContents = strXMLContents & "<contenttype>" & "PDF" & "</contenttype>" & vbCrLf
            End If


            strXMLContents = strXMLContents & "<docname>tempexportedfilenameextension</docname>" & vbCrLf 'The temp file name will be replaced with original file name from within the caller method

            strXMLContents = strXMLContents & "</applicationdata>" & vbCrLf
            strXMLContents = strXMLContents & "</DOCUMENT>" & vbCrLf

            Return strXMLContents
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetXMLDataContents()", ex)
            Return ""
        End Try
    End Function
    Private Sub GenerateCDataHTMLContents()
        Try
            Dim strCompletePatientName As String = ""
            strCompletePatientName = SanitizeStringForXml(strPatientTitle) & " " & SanitizeStringForXml(strForename1) & " " & SanitizeStringForXml(strSurname)
            strCompletePatientName = strCompletePatientName.Trim()

            _CDataHtmlContents = vbCrLf & "<![CDATA["
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<html>" & vbCrLf & "<head>" & vbCrLf & "<title>"
            _CDataHtmlContents = _CDataHtmlContents & strApplicationName & " " & strExaminationName & "</title>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</head>" & vbCrLf & "<body>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<table border=""0"" cellspacing=""0"" cellpadding=""0"" width=""100%"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>" & vbCrLf & "<td>" & vbCrLf & "<table border=""0"" width=""100%"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td align=""center""><font face=""Arial"" size=""4""><b>" & strExaminationName & "</b></font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>" & vbCrLf & "<hr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<table border=""0"" width=""100%"" id=""PatientDetails"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""50%"" valign=""top"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<table border=""0"" width=""100%"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">Name</font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>"
            _CDataHtmlContents = _CDataHtmlContents & strCompletePatientName & ", " & strDateOfBirth & " (" & strSex & ")"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</b></font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"

            If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then 'Dumfries & Galloway - uses CHI No instead of NHS No
                _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">CHI No:</font></td>"
            Else
                _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">NHS No:</font></td>" 'For all other case use NHS No
            End If


            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>" & strPatientNHSNo & "</b></font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">Hospital No:</font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>" & strHospitalNo & "</b></font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</td>"

            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""50%"" valign=""top"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<table border=""0"" width=""100%"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr valign=""top"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">Address:</font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>" & SanitizeStringForXml(strAddress1) & "<br>" & SanitizeStringForXml(strAddress2) & "<br>" & SanitizeStringForXml(strTown) & "<br>" & strPostCode & "</b></font></td>"

            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<hr>" 'Line 97 in source xml file

            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<table border=""0"" width=""100%"" id=""GPDetails"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""50%"" valign=""top"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<table border=""0"" width=""100%"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr valign=""top"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">GP:</font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>" & SanitizeStringForXml(strGPCompleteName) & "<br>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & SanitizeStringForXml(strPracticeAddress1) & "<br>" & SanitizeStringForXml(strPracticeAddress2) & "<br>" & SanitizeStringForXml(strPracticePostCode) & "<br></b></font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</td>"

            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""50%"" valign=""Top"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<table border=""0"" width=""100%"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">Status:</font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>" & SanitizeStringForXml(strPatientStatus) & "</b></font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">Priority:</font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>" & SanitizeStringForXml(strProcedurePriority) & "</b></font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">Hospital:</font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>" & SanitizeStringForXml(strHospitalName) & "</b></font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>" 'Line no 119 in source xml file

            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">Ward:</font></td>"

            If String.IsNullOrEmpty(strPatientCurrentLocationCode) Then
                _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>Ward - Not specified</b></font></td>"
            Else
                _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>Ward - " & strPatientCurrentLocationCode & "</b></font></td>"
            End If

            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""100""><font face=""Tahoma"" size=""2"">Referring Cons:</font></td>"

            If String.IsNullOrEmpty(strReferralDoctorName) Then
                _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>Data not found</b></font></td>"
            Else
                _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Tahoma"" size=""2""><b>" & SanitizeStringForXml(strReferralDoctorName) & " (consultant " & SanitizeStringForXml(strReferralDoctorGroupName) & ")</b></font></td>"
            End If

            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<br>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<hr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<table border=""0"" width=""100%"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td><font face=""Arial"" size=""3""><b>Procedure date:</b> " & dtExaminationDateTime.ToString("dd MMM yyyy") & "</font></td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<br>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<table border=""0"" width=""100%"" id=""ReportBody"">"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<tr valign=""top"">" 'Line no 139 in source xml file

            '1. First <td> - width 40% - [1. Indications, 2. Report, 3. Diagnoses, 4. Follow up, 5. Advice/Comments]
            GenerateReportFirstTDBlock()


            '2. Second <td> - [6. Consultant/Endoscopist, 7. Instrument, 8. Premedication, 9. Specimens Taken]
            GenerateReportSecondTDBlock()


            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</td>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</tr>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</table>"
            'File ending tag
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</body>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</html>"
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "]]>" & vbCrLf
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GenerateCDataHTMLContents()", ex)
        End Try
    End Sub
    Private Sub GenerateReportFirstTDBlock()
        Try
            '1. First <td> - width 40% - [1. Indications, 2. Report, 3. Diagnoses, 4. Follow up, 5. Advice/Comments]
            Dim da As DataAccess = New DataAccess
            Dim dtData = New DataTable
            dtData = da.GetReportSummary(_intProcedureID)
            Dim strEachNodeName As String = ""
            Dim strEachNodeSummary As String = ""


            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td width=""40%""><font face=""Tahoma"" size=""2"">"

            For Each drD As DataRow In dtData.Rows
                If Not IsDBNull(drD("NodeName")) Then
                    strEachNodeName = drD("NodeName").ToString()
                Else
                    strEachNodeName = ""
                End If

                If Not IsDBNull(drD("NodeSummary")) Then
                    strEachNodeSummary = drD("NodeSummary").ToString()
                Else
                    strEachNodeSummary = ""
                End If

                If Not String.IsNullOrEmpty(strEachNodeName) And Not String.IsNullOrEmpty(strEachNodeSummary) Then

                    '<table> html tag breaking font style, fix it with style
                    If strEachNodeSummary.Contains("<table>") Then
                        strEachNodeSummary = strEachNodeSummary.Replace("<table>", "<table style=font-face:tahoma;font-size:13px;>")
                    End If
                    _CDataHtmlContents = _CDataHtmlContents & "<b>" & strEachNodeName & "</b><br>"
                    _CDataHtmlContents = _CDataHtmlContents & vbCrLf & strEachNodeSummary & "<br><br>"
                End If
            Next
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</font><br><br><font face=""Tahoma"" size=""2""><b>*** END OF REPORT ***</b></td>"

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GenerateReportFirstTDBlock()", ex)
        End Try
    End Sub
    Private Sub GenerateReportSecondTDBlock()
        Try
            '2. Second <td> - [6. Consultant/Endoscopist, 7. Instrument, 8. Premedication, 9. Specimens Taken]
            Dim da As DataAccess = New DataAccess
            Dim dtData = New DataTable
            dtData = da.GetReportSummaryByGroup(_intProcedureID, "RS")
            Dim strEachNodeName As String = ""
            Dim strEachNodeSummary As String = ""


            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "<td align=""Right""><font face=""Tahoma"" size=""2"">"

            For Each drD As DataRow In dtData.Rows
                If Not IsDBNull(drD("NodeName")) Then
                    strEachNodeName = drD("NodeName").ToString()
                Else
                    strEachNodeName = ""
                End If

                If Not IsDBNull(drD("NodeSummary")) Then
                    strEachNodeSummary = drD("NodeSummary").ToString()
                Else
                    strEachNodeSummary = ""
                End If

                If Not String.IsNullOrEmpty(strEachNodeName) And Not String.IsNullOrEmpty(strEachNodeSummary) Then
                    _CDataHtmlContents = _CDataHtmlContents & "<b>" & strEachNodeName & "</b><br>"
                    _CDataHtmlContents = _CDataHtmlContents & vbCrLf & strEachNodeSummary & "<br><br>"
                End If
            Next

            'Premedication - This data has already been there with Drugs name.
            'dtData = New DataTable
            'dtData = da.GetPremedReportSummary(_intProcedureID)
            'For Each drD As DataRow In dtData.Rows
            '    If Not IsDBNull(drD("NodeName")) Then
            '        strEachNodeName = drD("NodeName").ToString()
            '    Else
            '        strEachNodeName = ""
            '    End If

            '    If Not IsDBNull(drD("NodeSummary")) Then
            '        strEachNodeSummary = drD("NodeSummary").ToString()
            '    Else
            '        strEachNodeSummary = ""
            '    End If

            '    If Not String.IsNullOrEmpty(strEachNodeName) And Not String.IsNullOrEmpty(strEachNodeSummary) Then
            '        _CDataHtmlContents = _CDataHtmlContents & "<b>" & strEachNodeName & "</b><br>"
            '        _CDataHtmlContents = _CDataHtmlContents & vbCrLf & strEachNodeSummary & "<br><br>"
            '    End If
            'Next

            'Specimens Taken
            dtData = New DataTable
            dtData = da.GetProcedureSiteSpecimens(_intProcedureID)
            Dim strSiteNo As String = ""
            Dim strSpecimens As String = ""

            _CDataHtmlContents = _CDataHtmlContents & "<b>Specimens Taken</b><br>"
            If Not IsNothing(dtData) Then
                If dtData.Rows.Count > 0 Then
                    For Each drD In dtData.Rows
                        If Not IsDBNull(drD("SiteNo")) Then
                            strSiteNo = drD("SiteNo").ToString()
                        Else
                            strSiteNo = ""
                        End If

                        If Not IsDBNull(drD("SpecimenSummary")) Then
                            strSpecimens = drD("SpecimenSummary").ToString()
                        Else
                            strSpecimens = ""
                        End If

                        If Not String.IsNullOrEmpty(strSpecimens) Then
                            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "Site " & strSiteNo & ":" & strSpecimens & "<br>"
                        End If
                    Next
                End If
            End If
            _CDataHtmlContents = _CDataHtmlContents & vbCrLf & "</font><br><br></td>"
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GenerateReportSecondTDBlock()", ex)
        End Try
    End Sub
    Private Function GetProcessedImageAndDocumentDataTable() As DataTable
        Try
            Dim dtImageAndDocumentDataTable As New DataTable
            Dim da As DataAccess = New DataAccess
            dtImageAndDocumentDataTable = da.GetProcedureSiteImagesAndDocumentsStoreData(_intProcedureID)

            Dim strEachFileName As String = ""
            Dim strEachFileType As String = ""
            Dim intEachFileSizeInBytes As Integer = 0
            Dim strEachFileContentsInBase64text As String = ""

            If Not IsNothing(dtImageAndDocumentDataTable) Then
                If dtImageAndDocumentDataTable.Rows.Count > 0 Then
                    For Each drD As DataRow In dtImageAndDocumentDataTable.Rows
                        If Not IsDBNull(drD("PhotoName")) Then
                            strEachFileName = drD("PhotoName").ToString()
                        Else
                            strEachFileName = ""
                        End If
                        If Not IsDBNull(drD("FileType")) Then
                            strEachFileType = drD("FileType").ToString()
                        Else
                            strEachFileType = ""
                        End If

                        If Not String.IsNullOrEmpty(strEachFileName) And Not String.IsNullOrEmpty(strEachFileType) Then
                            strEachFileContentsInBase64text = ""
                            intEachFileSizeInBytes = 0

                            ProcessImageOrDocFile(strEachFileName, strEachFileType, strEachFileContentsInBase64text, intEachFileSizeInBytes)
                            If strEachFileType.Trim() = "Image" Then
                                drD("Base64TextContent") = strEachFileContentsInBase64text
                                drD("FileSizeInBytes") = intEachFileSizeInBytes
                            End If

                            'PDF file type will already have Base64 converted content and FileSizeInBytes from within Stored Procedure

                            drD.AcceptChanges()
                        End If
                    Next
                End If
            End If
            Return dtImageAndDocumentDataTable
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetProcessedImageAndDocumentDataTable()", ex)
        End Try
    End Function
    Private Function GetBase64FilesContentOfImage(strImageFileNamewithPathOrOnlyName As String) As String
        Dim strEachFileContentsInBase64text As String = ""
        Try

            Return strEachFileContentsInBase64text
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetBase64FilesContentOfImage()", ex)
            Return ""
        End Try
    End Function
    Private Function ProcessImageOrDocFile(ByVal strFileName As String, ByVal strFileType As String, ByRef strFileContentsInBase64 As String, ByRef intFileSizeInBytes As Integer)
        Try
            Dim strImageFileSourceDirectory As String = ""

            If Right(Session(Constants.SESSION_PHOTO_UNC), 1) = "\" Then
                strImageFileSourceDirectory = Session(Constants.SESSION_PHOTO_UNC) & "ERS\Photos\" & _intProcedureID.ToString()
            Else
                strImageFileSourceDirectory = Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & _intProcedureID.ToString()
            End If


            If strFileType.Trim() = "Image" Then
                If ConfigurationManager.AppSettings("IsAzure").ToUpper() <> "TRUE" Then 'Not in Azure - strFileName will be only name if the image file, no location
                    If File.Exists(strImageFileSourceDirectory & "\" & strFileName) Then
                        Using image As Image = Image.FromFile(strImageFileSourceDirectory & "\" & strFileName)
                            Using m As MemoryStream = New MemoryStream
                                image.Save(m, image.RawFormat)
                                Dim imgBytes As Byte() = m.ToArray()
                                intFileSizeInBytes = m.Length
                                strFileContentsInBase64 = Convert.ToBase64String(imgBytes)
                            End Using
                        End Using

                    End If
                Else
                    'App is in Azure. strFileName will be a web url path of the image file in Azure Storage which should be accessible from App user's network.
                    Dim ImgBytesArray As Byte()
                    Dim imgReq As System.Net.HttpWebRequest = System.Net.WebRequest.Create(strFileName)
                    Dim imgResponse As System.Net.WebResponse = imgReq.GetResponse()
                    Dim imgStream As Stream

                    imgStream = imgResponse.GetResponseStream()

                    Using imgms As MemoryStream = New MemoryStream()
                        imgStream.CopyTo(imgms)
                        ImgBytesArray = imgms.ToArray()
                        intFileSizeInBytes = imgms.Length
                        strFileContentsInBase64 = Convert.ToBase64String(ImgBytesArray)
                    End Using

                    imgStream.Close()
                    imgResponse.Close()
                End If

            ElseIf strFileType.Trim() = "PDF" Then
                'No need to do anything at the moment. PDF document's Base64 Converted file data and File Size byte array will be populated from within Stored Procedure.
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ProcessImageOrDocFile()", ex)
        End Try
    End Function
    Private Sub CreateDocumentHeader()
        Try
            'MH changes on 18 Jan 2023 - TFS 2583 Dumfries & Galloway - export report xml structure need changes

            _mainXmlDocument = New XmlDocument()
            _mainXmlDocument.PreserveWhitespace = True


            Dim xmlDeclaration As XmlDeclaration = _mainXmlDocument.CreateXmlDeclaration("1.0", "utf-8", Nothing)

            'Create root element and Namespace prefix
            Dim root As XmlElement = _mainXmlDocument.DocumentElement
            root = _mainXmlDocument.CreateElement(repPrefix, "TestReport", repPrefixValue)

            'Generate Namespace and prefix attributes / Bind namespace with prefixes

            Dim attr1 As XmlAttribute = _mainXmlDocument.CreateAttribute("xsi", "schemaLocation", xsdSchemaLocation)
            attr1.Value = xsdSchemaLocation
            root.Attributes.Append(attr1)

            'root.SetAttribute("xsi:" & "schemaLocation", xsdSchemaLocation)
            root.SetAttribute("xmlns:" & genPrefix, genPrefixValue)
            root.SetAttribute("xmlns:" & sciPrefix, sciPrefixValue)
            root.SetAttribute("xmlns:" & "xsi", "http://www.w3.org/2001/XMLSchema-instance")


            'root.Attributes.Append(_mainXmlDocument.CreateAttribute(genPrefix, "xmlns", genPrefixValue))

            'root.Attributes.Append(_mainXmlDocument.CreateAttribute(sciPrefix, "xmlns", sciPrefixValue))

            'root.Attributes.Append(_mainXmlDocument.CreateAttribute("xsi", "xmlns", "http://www.w3.org/2001/XMLSchema-instance"))

            _mainXmlDocument.AppendChild(root)

            _mainXmlDocument.InsertBefore(xmlDeclaration, root)

            'Comment section
            If Not _strSoftwareVersion.StartsWith("Ver") Then
                _strSoftwareVersion = "Ver " & _strSoftwareVersion
            End If
            Dim xmlcomment As XmlComment = _mainXmlDocument.CreateComment("2021 Solus Endoscopy - SD_XML." & _strSoftwareVersion)
            _mainXmlDocument.InsertBefore(xmlcomment, root)

            xmlcomment = _mainXmlDocument.CreateComment("Author: " & _xmlDocAuthor)
            _mainXmlDocument.InsertBefore(xmlcomment, root)


            xmlcomment = _mainXmlDocument.CreateComment("SCI Store version 4.0")
            _mainXmlDocument.InsertBefore(xmlcomment, root)

            'Sub root element "Report"
            root.AppendChild(_mainXmlDocument.CreateElement(repPrefix, "Report", repPrefixValue))

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in CreateDocumentHeader()", ex)
        End Try
    End Sub
    Private Sub GenerateReportDataSection()
        Try
            Dim reportDataElement As XmlElement = _mainXmlDocument.CreateElement(sciPrefix, "ReportData", sciPrefixValue)
            Dim elem As XmlElement

            elem = _mainXmlDocument.GetElementsByTagName("Report", repPrefixValue).Item(0)
            elem.AppendChild(reportDataElement)
#Region "RequestingBody"
            elem = _mainXmlDocument.CreateElement(sciPrefix, "Discipline", sciPrefixValue)
            elem.InnerXml = strProcedure.ToUpper()
            reportDataElement.AppendChild(elem)
            reportDataElement.AppendChild(_mainXmlDocument.CreateElement(sciPrefix, "ServiceProvider", sciPrefixValue))

            Dim elemReqParty As XmlElement
            elemReqParty = _mainXmlDocument.CreateElement(sciPrefix, "RequestingParty", sciPrefixValue)



            'IdValue = ReferralConsultantNo
            Dim intIdValue As Integer = 0
            Dim blnIdValue As Boolean = False
            If IsDBNull(dsProcedureData.Tables(0).Rows(0)("ReferralConsultantNo")) Then
                blnIdValue = False
            Else
                intIdValue = Convert.ToInt32(dsProcedureData.Tables(0).Rows(0)("ReferralConsultantNo").ToString())
                blnIdValue = True
            End If

            'IdType = Consultant Designation?? Hard coded 'Consultant surgeon' here.

            'HcpName-> UnstructuredName =  ReferralDoctorName
            Dim strUnstructuredName As String = ""
            If IsDBNull(dsProcedureData.Tables(0).Columns("ReferralDoctorName")) Then
                strUnstructuredName = ""
            Else
                strUnstructuredName = dsProcedureData.Tables(0).Rows(0)("ReferralDoctorName").ToString().Trim()
            End If

            reportDataElement.AppendChild(elemReqParty)
            elem = _mainXmlDocument.CreateElement(genPrefix, "HcpId", genPrefixValue)
            elemReqParty.AppendChild(elem)
            If blnIdValue Then
                elem.AppendChild(_mainXmlDocument.CreateElement(genPrefix, "IdValue", genPrefixValue))
                _mainXmlDocument.GetElementsByTagName("IdValue", genPrefixValue).Item(0).InnerXml = intIdValue
            End If


            elem.AppendChild(_mainXmlDocument.CreateElement(genPrefix, "IdType", genPrefixValue))
            _mainXmlDocument.GetElementsByTagName("IdType", genPrefixValue).Item(0).InnerXml = "Consultant surgeon"

            If Not String.IsNullOrEmpty(strUnstructuredName) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "HcpName", genPrefixValue)
                elemReqParty.AppendChild(elem)
                elem.AppendChild(_mainXmlDocument.CreateElement(genPrefix, "UnstructuredName", genPrefixValue))
                _mainXmlDocument.GetElementsByTagName("UnstructuredName", genPrefixValue).Item(0).InnerXml = strUnstructuredName
            End If

            reportDataElement.AppendChild(_mainXmlDocument.CreateElement(sciPrefix, "ServiceRequest", sciPrefixValue))
            _mainXmlDocument.GetElementsByTagName("ServiceRequest", sciPrefixValue).Item(0).AppendChild(_mainXmlDocument.CreateElement(genPrefix, "ClinicalDataRequired", genPrefixValue))

#End Region
#Region "ServiceResult"
            Dim elemServiceResult As XmlElement
            elemServiceResult = _mainXmlDocument.CreateElement(sciPrefix, "ServiceResult", sciPrefixValue)
            reportDataElement.AppendChild(elemServiceResult)

            'ServiceResult has two child element
            '1. SampleDetails
            '2. TestResultSets

            '1. SampleDetails
            elem = _mainXmlDocument.CreateElement(sciPrefix, "SampleDetails", sciPrefixValue)
            elemServiceResult.AppendChild(elem)

            '2. TestResultSets
            elem = _mainXmlDocument.CreateElement(sciPrefix, "TestResultSets", sciPrefixValue)
            elemServiceResult.AppendChild(elem)

            GenerateTestResultSetSection()

            '1. SampleDetails Child Nodes
            'TissueType = Procedure
            'DateTimeSampled = ExaminationDatetime
            'DateTimeReceived = ExaminationDatetime
            'BiohazardAlert
#Region "SampleDetails"
            Dim strTissueType As String = ""
            Dim dtDateTimeSampled As DateTime
            Dim blnDateTimeSampled As Boolean = False
            Dim strBiohazardAlert As String = "false" 'true or false . Keeping hard coded as false
            Dim dtDateTimeReceived As DateTime
            Dim blnDateTimeReceived As Boolean = False

            If IsDBNull(dsProcedureData.Tables(0).Rows(0)("ExaminationDatetime")) Then
                blnDateTimeSampled = False
                blnDateTimeReceived = False
            Else
                dtDateTimeSampled = Convert.ToDateTime(dsProcedureData.Tables(0).Rows(0)("ExaminationDatetime").ToString())
                dtDateTimeReceived = Convert.ToDateTime(dsProcedureData.Tables(0).Rows(0)("ExaminationDatetime").ToString())
                blnDateTimeSampled = True
                blnDateTimeReceived = True
            End If

            If IsDBNull(dsProcedureData.Tables(0).Rows(0)("Procedure")) Then
                strTissueType = ""
            Else
                strTissueType = dsProcedureData.Tables(0).Rows(0)("Procedure").ToString().Trim()
            End If

            If Not String.IsNullOrEmpty(strTissueType) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "TissueType", genPrefixValue)
                elem.InnerXml = strTissueType
                _mainXmlDocument.GetElementsByTagName("SampleDetails", sciPrefixValue).Item(0).AppendChild(elem)
            End If
            If blnDateTimeSampled Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "DateTimeSampled", genPrefixValue)
                elem.InnerXml = dtDateTimeSampled.ToString("yyyy-MM-ddThh:mm:ss")
                _mainXmlDocument.GetElementsByTagName("SampleDetails", sciPrefixValue).Item(0).AppendChild(elem)
            End If
            If blnDateTimeReceived Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "DateTimeReceived", genPrefixValue)
                elem.InnerXml = dtDateTimeReceived.ToString("yyyy-MM-ddThh:mm:ss")
                _mainXmlDocument.GetElementsByTagName("SampleDetails", sciPrefixValue).Item(0).AppendChild(elem)
            End If
            If Not String.IsNullOrEmpty(strBiohazardAlert) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "BiohazardAlert", genPrefixValue)
                elem.InnerXml = strBiohazardAlert
                _mainXmlDocument.GetElementsByTagName("SampleDetails", sciPrefixValue).Item(0).AppendChild(elem)
            End If
#End Region

#End Region
            GeneratePatientInformationSection()


        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GenerateReportDataSection()", ex)
        End Try
    End Sub
    Private Sub GenerateTestResultSetSection()
        Try
            Dim elemTestResultSets As XmlElement
            Dim elemTestResultSet As XmlElement

            Dim elem1 As XmlElement
            Dim elem2 As XmlElement
            Dim elemClinalCodeScheme As XmlElement

            elemTestResultSets = _mainXmlDocument.GetElementsByTagName("TestResultSets", sciPrefixValue).Item(0)
            elemTestResultSet = _mainXmlDocument.CreateElement(sciPrefix, "TestResultSet", sciPrefixValue)
            elemTestResultSets.AppendChild(elemTestResultSet)
            elem1 = _mainXmlDocument.CreateElement(genPrefix, "TestSetDetails", genPrefixValue)
            elemTestResultSet.AppendChild(elem1)
            elem2 = _mainXmlDocument.CreateElement(genPrefix, "TestName", genPrefixValue)
            elem1.AppendChild(elem2)
            elem1 = _mainXmlDocument.CreateElement(genPrefix, "ClinicalCircumstanceDescription", genPrefixValue)
            elem1.InnerXml = strExaminationName
            elem2.AppendChild(elem1)
            elem1 = _mainXmlDocument.CreateElement(genPrefix, "TestResults", genPrefixValue)
            elemTestResultSet.AppendChild(elem1)
            elem2 = _mainXmlDocument.CreateElement(genPrefix, "TestResult", genPrefixValue)
            elem1.AppendChild(elem2)
            elem1 = _mainXmlDocument.CreateElement(genPrefix, "TestPerformed", genPrefixValue)
            elem2.AppendChild(elem1)
            elem2 = _mainXmlDocument.CreateElement(genPrefix, "TestName", genPrefixValue)
            elem1.AppendChild(elem2)
            elem1 = _mainXmlDocument.CreateElement(genPrefix, "ClinicalInformation", genPrefixValue)
            elem2.AppendChild(elem1)
            elem2 = _mainXmlDocument.CreateElement(genPrefix, "ClinicalCode", genPrefixValue)
            elem1.AppendChild(elem2)
            elem1 = _mainXmlDocument.CreateElement(genPrefix, "ClinicalCodeValue", genPrefixValue)
            elem1.InnerXml = "UGIG1"
            elem2.AppendChild(elem1)

            elemClinalCodeScheme = _mainXmlDocument.CreateElement(genPrefix, "ClinicalCodeScheme", genPrefixValue)
            _mainXmlDocument.GetElementsByTagName("ClinicalCode", genPrefixValue).Item(0).AppendChild(elemClinalCodeScheme)

            elem1 = _mainXmlDocument.CreateElement(genPrefix, "ClinicalCodeSchemeVersion", genPrefixValue)
            elem1.InnerXml = "READ"

            elem2 = _mainXmlDocument.CreateElement(genPrefix, "ClinicalCodeSchemeId", genPrefixValue)
            elem2.InnerXml = "V1"

            elemClinalCodeScheme.AppendChild(elem1)
            elemClinalCodeScheme.AppendChild(elem2)

            elemClinalCodeScheme = _mainXmlDocument.CreateElement(genPrefix, "ClinicalCodeDescription", genPrefixValue)
            elemClinalCodeScheme.InnerXml = "UGI G1"

            _mainXmlDocument.GetElementsByTagName("ClinicalInformation", genPrefixValue).Item(0).AppendChild(elemClinalCodeScheme)

            elem1 = _mainXmlDocument.CreateElement(genPrefix, "TestInterpretation", genPrefixValue)
            _mainXmlDocument.GetElementsByTagName("TestResult", genPrefixValue).Item(0).AppendChild(elem1)

            GenerateCDataHTMLContents()


            elem2 = _mainXmlDocument.CreateElement(genPrefix, "Interpretation", genPrefixValue)
            elem2.InnerXml = _CDataHtmlContents

            elem1.AppendChild(elem2)

            GenerateTextEncodedFileDataSection()

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GenerateTestResultSetSection()", ex)
        End Try
    End Sub
    Private Sub GenerateTextEncodedFileDataSection()
        Try
            Dim dtData As DataTable = New DataTable
            dtData = GetProcessedImageAndDocumentDataTable()
            Dim elemTestResult As XmlElement
            Dim elemResultAttachments As XmlElement
            Dim elemEachAttachment As XmlElement

            Dim elem1 As XmlElement

            Dim strDisplayName As String = ""
            Dim strOriginalFileName As String = ""
            Dim strFileTypeExtension As String = ""
            Dim intFileSizeInBytes As Integer = 0
            Dim strCompressionMethod As String = ""
            Dim strAttachmentData As String = ""
            'Dim strAttachmentDataOpeningBracket As String = "<![CDATA[/9j/" --MH changed as below on 03 July 2023 - Images can't be viewed 
            Dim strAttachmentDataOpeningBracket As String = "<![CDATA["
            Dim strAttachmentDataClosingBracket As String = "]]>"


            elemTestResult = _mainXmlDocument.GetElementsByTagName("TestResult", genPrefixValue).Item(0)
            elem1 = _mainXmlDocument.CreateElement(genPrefix, "DisciplineSpecificValues", genPrefixValue)
            elem1.InnerXml = "TestResultOrder:0"
            elemTestResult.AppendChild(elem1)
            elemResultAttachments = _mainXmlDocument.CreateElement(genPrefix, "ResultAttachments", genPrefixValue)
            elemTestResult.AppendChild(elemResultAttachments)

            If Not IsNothing(dtData) Then
                If dtData.Rows.Count > 0 Then
                    For Each drD As DataRow In dtData.Rows
                        elemEachAttachment = _mainXmlDocument.CreateElement(genPrefix, "ResultAttachment", genPrefixValue)
#Region "Read from Data Column"
                        If Not IsDBNull(drD("Region")) Then
                            If Not String.IsNullOrEmpty(drD("Region").ToString()) Then
                                strDisplayName = drD("Region").ToString()
                            Else
                                strDisplayName = "Attached to procedure"
                            End If

                        Else
                            strDisplayName = "Attached to procedure"
                        End If
                        If Not IsDBNull(drD("PhotoName")) Then
                            strOriginalFileName = drD("PhotoName").ToString()
                        Else
                            strOriginalFileName = ""
                        End If
                        strFileTypeExtension = Path.GetExtension(strOriginalFileName).Replace(".", "")


                        If Not IsDBNull(drD("FileSizeInBytes")) Then
                            intFileSizeInBytes = Convert.ToInt32(drD("FileSizeInBytes").ToString())
                        Else
                            intFileSizeInBytes = 0
                        End If
                        If Not IsDBNull(drD("CompressionMethod")) Then
                            strCompressionMethod = drD("CompressionMethod").ToString()
                        Else
                            strCompressionMethod = 0
                        End If
                        If Not IsDBNull(drD("Base64TextContent")) Then
                            strAttachmentData = drD("Base64TextContent").ToString()
                        Else
                            strAttachmentData = ""
                        End If
#End Region
                        elemResultAttachments.AppendChild(elemEachAttachment)
                        elem1 = _mainXmlDocument.CreateElement(genPrefix, "DisplayName", genPrefixValue)
                        elem1.InnerXml = strDisplayName
                        elemEachAttachment.AppendChild(elem1)

                        elem1 = _mainXmlDocument.CreateElement(genPrefix, "OriginalFileName", genPrefixValue)
                        elem1.InnerXml = strOriginalFileName
                        elemEachAttachment.AppendChild(elem1)

                        elem1 = _mainXmlDocument.CreateElement(genPrefix, "FileType", genPrefixValue)
                        elem1.InnerXml = strFileTypeExtension
                        elemEachAttachment.AppendChild(elem1)

                        elem1 = _mainXmlDocument.CreateElement(genPrefix, "FileSizeInBytes", genPrefixValue)
                        elem1.InnerXml = intFileSizeInBytes
                        elemEachAttachment.AppendChild(elem1)

                        elem1 = _mainXmlDocument.CreateElement(genPrefix, "CompressionMethod", genPrefixValue)
                        elem1.InnerXml = strCompressionMethod
                        elemEachAttachment.AppendChild(elem1)

                        elem1 = _mainXmlDocument.CreateElement(genPrefix, "CompressedSizeInBytes", genPrefixValue)
                        elem1.InnerXml = intFileSizeInBytes
                        elemEachAttachment.AppendChild(elem1)

                        elem1 = _mainXmlDocument.CreateElement(genPrefix, "AttachmentData", genPrefixValue)
                        elem1.InnerXml = strAttachmentDataOpeningBracket & strAttachmentData & strAttachmentDataClosingBracket
                        elemEachAttachment.AppendChild(elem1)


                    Next
                End If
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GenerateTextEncodedFileDataSection()", ex)
        End Try
    End Sub
    Private Sub GeneratePatientInformationSection()
        Try
            Dim elemPatientInfo As XmlElement
            Dim elemPatientId As XmlElement
            Dim elemPatientName As XmlElement
            Dim elemPatientAddress As XmlElement
            Dim elemRegGp As XmlElement
            Dim elemRegGpStructuredName As XmlElement
            Dim elemHcpName As XmlElement

            Dim elem As XmlElement


            elemPatientInfo = _mainXmlDocument.CreateElement(sciPrefix, "PatientInformation", sciPrefixValue)
            elemPatientInfo.SetAttribute("xmlns:" & sciPrefix, sciPrefixValue)
            elemPatientInfo.SetAttribute("xmlns:" & genPrefix, genPrefixValue)

            elem = _mainXmlDocument.GetElementsByTagName("ReportData", sciPrefixValue).Item(0)
            elem.AppendChild(elemPatientInfo)

            elem = _mainXmlDocument.CreateElement(sciPrefix, "BasicDemographics", sciPrefixValue)
            elemPatientInfo.AppendChild(elem)

            elemPatientId = _mainXmlDocument.CreateElement(genPrefix, "PatientId", genPrefixValue)
            elemPatientId.SetAttribute("xmlns:" & genPrefix, "http://www.show.scot.nhs.uk/isd/General")
            elem.AppendChild(elemPatientId)

            elem = _mainXmlDocument.CreateElement(genPrefix, "IdValue", "http://www.show.scot.nhs.uk/isd/General")

            elem.InnerXml = strPatientNHSNo 'NHSNo as CHI no
            elemPatientId.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement(genPrefix, "IdScheme", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = "CHI"
            elemPatientId.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement(genPrefix, "IdType", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = "Personal"
            elemPatientId.AppendChild(elem)

            'MH Commented on 15 June 2023
            'elemPatientId = _mainXmlDocument.CreateElement(genPrefix, "PatientId", genPrefixValue)
            'elemPatientId.SetAttribute("xmlns:" & genPrefix, "http://www.show.scot.nhs.uk/isd/General")
            elem = _mainXmlDocument.GetElementsByTagName("BasicDemographics", sciPrefixValue).Item(0)

            elem.AppendChild(elemPatientId)

            'MH changed - 19 Jan 2023 - CRN no more required for Dumfies & Galloway

            'elem = _mainXmlDocument.CreateElement(genPrefix, "IdValue", "http://www.show.scot.nhs.uk/isd/General")
            'elem.InnerXml = "" '120674A - Keeping blank
            'elemPatientId.AppendChild(elem)

            'elem = _mainXmlDocument.CreateElement(genPrefix, "IdScheme", "http://www.show.scot.nhs.uk/isd/General")
            'elem.InnerXml = "CRN"
            'elemPatientId.AppendChild(elem)

            'MH commented on 15 Jun 2023 - Kerry email - may not required
            'elem = _mainXmlDocument.CreateElement(genPrefix, "IdType", "http://www.show.scot.nhs.uk/isd/General")
            'elem.InnerXml = "Personal"
            'elemPatientId.AppendChild(elem)


            elemPatientName = _mainXmlDocument.CreateElement(genPrefix, "PatientName", genPrefixValue)
            elemPatientName.SetAttribute("xmlns:" & genPrefix, "http://www.show.scot.nhs.uk/isd/General")
            elem = _mainXmlDocument.GetElementsByTagName("BasicDemographics", sciPrefixValue).Item(0)
            elem.AppendChild(elemPatientName)

            elem = _mainXmlDocument.CreateElement(genPrefix, "StructuredName", genPrefixValue)
            elemPatientName.AppendChild(elem)

            'Forename1 / Forename2
            If Not String.IsNullOrEmpty(strForename1) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "GivenName", genPrefixValue)
                _mainXmlDocument.GetElementsByTagName("StructuredName", genPrefixValue).Item(0).AppendChild(elem)
                elem.InnerXml = strForename1
            End If


            'Surname
            If Not String.IsNullOrEmpty(strSurname) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "FamilyName", genPrefixValue)
                _mainXmlDocument.GetElementsByTagName("StructuredName", genPrefixValue).Item(0).AppendChild(elem)
                elem.InnerXml = strSurname
            End If


            elem = _mainXmlDocument.CreateElement(genPrefix, "NameType", genPrefixValue)
            elem.InnerXml = "Current"
            elemPatientName.AppendChild(elem)



            elemPatientAddress = _mainXmlDocument.CreateElement(genPrefix, "PatientAddress", genPrefixValue)
            elemPatientAddress.SetAttribute("xmlns:" & genPrefix, "http://www.show.scot.nhs.uk/isd/General")
            elem = _mainXmlDocument.GetElementsByTagName("BasicDemographics", sciPrefixValue).Item(0)
            elem.AppendChild(elemPatientAddress)

            elem = _mainXmlDocument.CreateElement(genPrefix, "StructuredAddress", genPrefixValue)
            elemPatientAddress.AppendChild(elem)

            'Address1
            If Not String.IsNullOrEmpty(strAddress1) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "AddressLine", genPrefixValue)
                _mainXmlDocument.GetElementsByTagName("StructuredAddress", genPrefixValue).Item(0).AppendChild(elem)
                elem.InnerXml = strAddress1
            End If


            'Address2
            If Not String.IsNullOrEmpty(strAddress2) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "AddressLine", genPrefixValue)
                _mainXmlDocument.GetElementsByTagName("StructuredAddress", genPrefixValue).Item(0).AppendChild(elem)
                elem.InnerXml = strAddress2
            End If


            'Address3 / strTown
            If Not String.IsNullOrEmpty(strTown) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "AddressLine", genPrefixValue)
                _mainXmlDocument.GetElementsByTagName("StructuredAddress", genPrefixValue).Item(0).AppendChild(elem)
                elem.InnerXml = strTown
            End If



            'Postcode
            If Not String.IsNullOrEmpty(strPostCode) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "NonValidatedPostCode", genPrefixValue)
                elem.InnerXml = strPostCode
                elemPatientAddress.AppendChild(elem)
            End If


            'Our address type is always Current
            elem = _mainXmlDocument.CreateElement(genPrefix, "AddressType", genPrefixValue)
            elem.InnerXml = "Current"
            elemPatientAddress.AppendChild(elem)

            'DateofBirth - MH changed on 19 Jan 2023
            If Not String.IsNullOrEmpty(strDateOfBirth) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "DateOfBirth", genPrefixValue)
                elem.InnerXml = strDateOfBirth
                _mainXmlDocument.GetElementsByTagName("BasicDemographics", sciPrefixValue).Item(0).AppendChild(elem)
            End If
            'If Not String.IsNullOrEmpty(strDateOfBirth) Then
            '    elem = _mainXmlDocument.CreateElement("DateOfBirth", "http://www.show.scot.nhs.uk/isd/General")
            '    elem.InnerXml = strDateOfBirth
            '    _mainXmlDocument.GetElementsByTagName("BasicDemographics", sciPrefixValue).Item(0).AppendChild(elem)
            'End If

            'Sex
            If Not String.IsNullOrEmpty(strSex) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "Sex", genPrefixValue)
                elem.InnerXml = strSex
                elem.RemoveAllAttributes()
                _mainXmlDocument.GetElementsByTagName("BasicDemographics", sciPrefixValue).Item(0).AppendChild(elem)
            End If


            'MaritalStatus
            If Not String.IsNullOrEmpty(strMaritalStatus) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "MaritalStatus", genPrefixValue)
                elem.InnerXml = strMaritalStatus
                _mainXmlDocument.GetElementsByTagName("BasicDemographics", sciPrefixValue).Item(0).AppendChild(elem)
            End If



            elemRegGp = _mainXmlDocument.CreateElement(genPrefix, "RegisteredGp", genPrefixValue)
            elemRegGp.SetAttribute("xmlns:" & genPrefix, "http://www.show.scot.nhs.uk/isd/General")
            elem = _mainXmlDocument.GetElementsByTagName("BasicDemographics", sciPrefixValue).Item(0)
            elem.AppendChild(elemRegGp)

            elemHcpName = _mainXmlDocument.CreateElement(genPrefix, "HcpName", genPrefixValue)
            elemRegGp.AppendChild(elemHcpName)
            elemRegGpStructuredName = _mainXmlDocument.CreateElement(genPrefix, "StructuredName", genPrefixValue)

            elemHcpName.AppendChild(elemRegGpStructuredName)

            'Referral GP/Doctors Name GPCompleteName
            If Not String.IsNullOrEmpty(strGPCompleteName) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "GivenName", genPrefixValue)
                elem.InnerXml = strGPCompleteName
                elemRegGpStructuredName.AppendChild(elem)
            End If


            'Referral GP - GPName
            If Not String.IsNullOrEmpty(strGPName) Then
                elem = _mainXmlDocument.CreateElement(genPrefix, "FamilyName", genPrefixValue)
                elem.InnerXml = strGPName
                elemRegGpStructuredName.AppendChild(elem)
            End If


        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GeneratePatientInformationSection()", ex)
        End Try
    End Sub
    Private Sub GenerateDocumentDataSection()
        Try
            Dim documentDataElement As XmlElement = _mainXmlDocument.CreateElement(sciPrefix, "DocumentData", sciPrefixValue)
            Dim elem As XmlElement
            Dim elemDocuIdentifier As XmlElement
            Dim elemIdValueLocal As XmlElement
            Dim elemIdSchemeLocal As XmlElement
            Dim elemPatientId As XmlElement

            elem = _mainXmlDocument.GetElementsByTagName("Report", repPrefixValue).Item(0)
            elem.AppendChild(documentDataElement)

            elem = _mainXmlDocument.CreateElement("DocumentCategory", "http://www.show.scot.nhs.uk/isd/General")
            documentDataElement.AppendChild(elem)

            elem.AppendChild(_mainXmlDocument.CreateElement("DocumentType", "http://www.show.scot.nhs.uk/isd/General"))
            _mainXmlDocument.GetElementsByTagName("DocumentType").Item(0).InnerXml = "Labs"

            elem.AppendChild(_mainXmlDocument.CreateElement("Separator", "http://www.show.scot.nhs.uk/isd/General"))
            _mainXmlDocument.GetElementsByTagName("Separator").Item(0).InnerXml = "|"

            elem.AppendChild(_mainXmlDocument.CreateElement("DocumentSubType", "http://www.show.scot.nhs.uk/isd/General"))
            _mainXmlDocument.GetElementsByTagName("DocumentSubType").Item(0).InnerXml = "Other Lab"

            elemDocuIdentifier = _mainXmlDocument.CreateElement(genPrefix, "DocumentIdentifier", "http://www.show.scot.nhs.uk/isd/General")
            'attr = _mainXmlDocument.CreateAttribute(genPrefix, "xmlns", "http://www.show.scot.nhs.uk/isd/General")
            'elemDocuIdentifier.Attributes.Append(attr)
            elemDocuIdentifier.SetAttribute("xmlns:" & genPrefix, "http://www.show.scot.nhs.uk/isd/General")
            documentDataElement.AppendChild(elemDocuIdentifier)

            elemIdValueLocal = _mainXmlDocument.CreateElement(genPrefix, "IdValue", "http://www.show.scot.nhs.uk/isd/General")
            elemDocuIdentifier.AppendChild(elemIdValueLocal)
            elemIdValueLocal.InnerXml = dsProcedureData.Tables(0).Rows(0)("UniqueExaminationID").ToString()

            elemIdSchemeLocal = _mainXmlDocument.CreateElement(genPrefix, "IdScheme", "http://www.show.scot.nhs.uk/isd/General")
            elemDocuIdentifier.AppendChild(elemIdSchemeLocal)
            elemIdSchemeLocal.InnerXml = "Telepath"

            elem = _mainXmlDocument.CreateElement("DocumentRevision", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = String.Format("{0:F2}", intDocumentRevisionNo)
            documentDataElement.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement(genPrefix, "OriginatingHcp", "http://www.show.scot.nhs.uk/isd/General")
            elem.SetAttribute("xmlns:" & genPrefix, "http://www.show.scot.nhs.uk/isd/General")
            documentDataElement.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement(genPrefix, "Attesting_Hcp", "http://www.show.scot.nhs.uk/isd/General")
            elem.SetAttribute("xmlns:" & genPrefix, "http://www.show.scot.nhs.uk/isd/General")
            documentDataElement.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement("DocumentAttestationDate", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = dtDocumentAttestationDateTime.ToString("yyyy-MM-dd") ' "2021-03-08"
            documentDataElement.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement("DocumentAttestationTime", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = dtDocumentAttestationDateTime.ToString("HH:mm:ss") '"16:44:16"
            documentDataElement.AppendChild(elem)

            elemPatientId = _mainXmlDocument.CreateElement(genPrefix, "PatientId", "http://www.show.scot.nhs.uk/isd/General")
            elemPatientId.SetAttribute("xmlns:" & genPrefix, "http://www.show.scot.nhs.uk/isd/General")
            documentDataElement.AppendChild(elemPatientId)

            elem = _mainXmlDocument.CreateElement(genPrefix, "IdValue", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = strPatientNHSNo
            elemPatientId.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement(genPrefix, "IdScheme", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = "CHI"
            elemPatientId.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement(genPrefix, "IdType", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = "Personal"
            elemPatientId.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement(genPrefix, "Sensitivity", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = "H"
            documentDataElement.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement(genPrefix, "DocumentCreationDate", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = dtDocumentCreationDateTime.ToString("yyyy-MM-dd") ' "2021-02-12"
            documentDataElement.AppendChild(elem)

            elem = _mainXmlDocument.CreateElement(genPrefix, "DocumentCreationTime", "http://www.show.scot.nhs.uk/isd/General")
            elem.InnerXml = dtDocumentCreationDateTime.ToString("HH:mm:ss") '"16:44:16"
            documentDataElement.AppendChild(elem)


        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GenerateReportDataSection()", ex)
        End Try
    End Sub
    Public Function TestOwnCustomXmlStringBuilder()

    End Function
    Private Function SanitizeStringForXml(strValue As String) As String
        Dim strCleanValue As String = ""
        strCleanValue = strValue.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("'", "&apos;").Replace("\""", "&quot;")
        Return strCleanValue
    End Function
    Private Function BuildXmlHeaderPart()

    End Function
    Function GetEnvironmentRoot() As String
        Dim RetValue As String = HostingEnvironment.MapPath("~")
        If RetValue.Last() <> "\" Then
            RetValue += "\"
        End If
        Return RetValue
    End Function


#Region "Own customized XmlStringBuilder"
    Private Sub WriteDocumentStartLine(strEncoding As String)
        Dim strDocStartLine As String = ""
        If strEncoding.Trim() = "" Then
            strEncoding = "utf-8"
        End If
        strDocStartLine = "<?xml version=""1.0/""" & " encoding=""" & strEncoding & """?>"

        If strMainXmlContent.Trim() = "" Then
            strMainXmlContent = strDocStartLine
        Else
            strMainXmlContent = strMainXmlContent & vbCrLf & strDocStartLine
        End If
    End Sub
    Private Sub WriteComment(strComment As String)
        If strMainXmlContent.Trim() = "" Then
            strMainXmlContent = "<!-- " & strComment & " -->"
        Else
            strMainXmlContent = strMainXmlContent & vbCrLf & "<!-- " & strComment & " -->"
        End If
    End Sub
    Private Sub StartElement(strPrefix As String, strElementName As String)
        Dim strTab = vbTab
        Dim strIndent As String = ""

        Dim strFullElement As String = ""
        Dim intTabCount As Integer = 0
        If Not lstStartedElement Is Nothing Then
            intTabCount = lstStartedElement.Count
        End If
        strIndent = StrDup(intTabCount, strTab)

        If strPrefix.Trim() = "" Then
            strFullElement = strElementName
        Else
            strFullElement = strPrefix & ":" & strElementName
        End If

        If strMainXmlContent.Trim() = "" Then
            strMainXmlContent = "<" & strFullElement & ">"
        Else
            strMainXmlContent = strMainXmlContent & vbCrLf & strIndent & "<" & strFullElement & ">"
        End If

        lstStartedElement.Add(strFullElement)

    End Sub
    Private Sub EndElement()
        Dim strTab = vbTab
        Dim strIndent As String = ""

        Dim strFullElement As String = ""
        Dim intTabCount As Integer = 0
        If Not lstStartedElement Is Nothing Then
            intTabCount = lstStartedElement.Count
        End If
        strIndent = StrDup(intTabCount, strTab)
        strFullElement = lstStartedElement.Last()
        If strMainXmlContent.Trim() = "" Then
            strMainXmlContent = "</" & strFullElement & ">"
        Else
            strMainXmlContent = strMainXmlContent & vbCrLf & strIndent & "</" & strFullElement & ">"
        End If

        lstStartedElement.RemoveAt(intTabCount - 1)

    End Sub
#End Region
    Private Class XmlDocApiConfigVariable
        Private _ApiSecKey As String
        Private _XmlDocFileName As String
        Private _XmlDocFileContent As String
        Private _DocumentExportSharedLocation As String
        Private _ReportSharedDriveAccessUser As String
        Private _SharedDriveAccessUserPassword As String
        Public Property ApiSecKey() As String
            Get
                Return _ApiSecKey
            End Get
            Set(ByVal value As String)
                _ApiSecKey = value
            End Set
        End Property
        Public Property XmlDocFileName() As String
            Get
                Return _XmlDocFileName
            End Get
            Set(ByVal value As String)
                _XmlDocFileName = value
            End Set
        End Property
        Public Property XmlDocFileContent() As String
            Get
                Return _XmlDocFileContent
            End Get
            Set(ByVal value As String)
                _XmlDocFileContent = value
            End Set
        End Property

        Public Property DocumentExportSharedLocation() As String
            Get
                Return _DocumentExportSharedLocation
            End Get
            Set(ByVal value As String)
                _DocumentExportSharedLocation = value
            End Set
        End Property
        Public Property ReportSharedDriveAccessUser() As String
            Get
                Return _ReportSharedDriveAccessUser
            End Get
            Set(ByVal value As String)
                _ReportSharedDriveAccessUser = value
            End Set
        End Property
        Public Property SharedDriveAccessUserPassword() As String
            Get
                Return _SharedDriveAccessUserPassword
            End Get
            Set(ByVal value As String)
                _SharedDriveAccessUserPassword = value
            End Set
        End Property
    End Class
End Class
