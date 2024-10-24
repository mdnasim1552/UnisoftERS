Imports System.Linq
Imports System.IO
Imports Microsoft.VisualBasic
Imports ERS.Data
Imports System.Data.SqlClient
Imports System.Reflection
Imports System.Text.RegularExpressions

Public Class DataExportLogic
    Inherits System.Web.UI.Page
    Private _LineDelimiter As String
    Private _FieldDelimiter As String
    Private _FileContent As String
    Private _ExportFileName As String
    Private _ExportFileExtension As String
    Private _DataFileExportPath As String
    Private _ExportGlobalFileNamePath As String
    Private _intProcedureId As Integer
    Private _intMaxCharacterLengthForEachLine As Integer
    Private _strExaminationRecordLine As String
    Private _strProcedureAndGPRecordLines As String
    Private _strCommonCommentLineStartID As String

    Public Sub New()
        '_LineDelimiter = " " + vbCrLf 'Default Line Delimiter
        _LineDelimiter = vbCrLf 'Default Line Delimiter Mahfuz changed on 29 June 2021
        _FieldDelimiter = "|" 'Default field Delimiter
        '_ExportFileExtension = "RPT" 'Mahfuz changed from ICE to RPT on 10 June 2021
        _ExportFileExtension = "dat" 'Mahfuz changed again after getting mail from Cathy
        _ExportGlobalFileNamePath = "" 'Mahfuz added on 27 Jan 2022
        'Mahfuz changed Export filename on 8 June 2021
        '_ExportFileName = "ANGLIA_ICE_GASTRO_DATA" 'DateTime will be added later before exporting file.
        _ExportFileName = "GIQCAP" 'Patient ID and Procedure ID will be added later.
        _intMaxCharacterLengthForEachLine = 70
        _strExaminationRecordLine = ""
        _strCommonCommentLineStartID = "C"

        Dim op As New Options
        Dim opHosp = System.Web.HttpContext.Current.Session("OperatingHospitalID")
        Dim dtSys As DataTable = op.GetRegistrationDetails(opHosp)

        _DataFileExportPath = ""

        If Not dtSys Is Nothing Then
            If dtSys.Rows.Count > 0 Then
                If Not IsDBNull(dtSys.Rows(0)("ReportExportPath")) Then
                    _DataFileExportPath = dtSys.Rows(0)("ReportExportPath")
                End If
            End If
        End If
        If _DataFileExportPath.Trim() = "" Then
            _DataFileExportPath = "C:\ERS\DataExport"
        End If

        dtSys.Dispose()

    End Sub

    Public Property FieldDelimiter() As String
        Get
            Return _FieldDelimiter
        End Get
        Set(ByVal value As String)
            _FieldDelimiter = value
        End Set
    End Property
    Public Property LineDelimiter() As String
        Get
            Return _LineDelimiter
        End Get
        Set(ByVal value As String)
            _LineDelimiter = value
        End Set
    End Property

    Public Function ExportProcedureFlatFileByProcedureId(ByVal intProcedureId As Integer) As Boolean
        Try
            Dim blnResult = True
            _FileContent = ""
            _intProcedureId = intProcedureId


            'Generate Export File Content
            GenerateExportFileContent()
            'Save (Export to) ExportDataFile to particular directory
            SaveFileContent()
            Return blnResult
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->ExportProcedureFlatFileByProcedureId()", ex)
            Return False
        End Try
    End Function
    'Mahfuz created on 27 Jan 2022 for Warwickshire PDF supporting XML export file content
    Public Function ExportMainPDFSupportingXMLDocument(ByVal intProcedureId As Integer) As Boolean
        Try
            Dim blnResult = True
            _FileContent = ""
            _intProcedureId = intProcedureId
            _ExportFileExtension = "xml"
            _ExportGlobalFileNamePath = System.IO.Path.GetFileNameWithoutExtension(Session("PDFPathAndFileName"))

            'Generate XML Export File Content
            GeneratePDFSupportingXMLExportFileContent()

            'Save (Export to) ExportDataFile to particular directory
            SaveFileContent()
            Return blnResult
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->ExportProcedureFlatFileByProcedureId()", ex)
            Return False
        End Try
    End Function

    'Mahfuz Added on 27 Oct 2021 for Southampton Practice Plus Group Export Document
    Public Function ExportProcedureFlatFile_For_Southampton_PPG_ByProcedureId(ByVal intProcedureId As Integer) As Boolean
        Try
            Dim blnResult = True
            Dim da As New DataAccess
            Dim strExportDocumentFilePrefix As String = ""

            _FileContent = ""
            _intProcedureId = intProcedureId

            _ExportFileExtension = "txt"

            '05 Jan 2022 :  MH changed below line. Southampton PPG has export file name prefix saved in DB against each Operating Hospital
            '_ExportFileName = "NTP11Uni"
            strExportDocumentFilePrefix = da.GetExportDocumentFilePrefix()
            If strExportDocumentFilePrefix.Trim() <> "" Then
                _ExportFileName = strExportDocumentFilePrefix
            Else
                _ExportFileName = "NTP11Uni"
            End If

            'Generate Export File Content
            GenerateExportFileContent_For_Southampton_PracticePlusGroup()
            'Save (Export to) ExportDataFile to particular directory
            SaveFileContent()



            Return blnResult
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->ExportProcedureFlatFile_For_Southampton_PPG_ByProcedureId()", ex)
            Return False
        End Try
    End Function

    'Mahfuz added on 18 June 2021 for North Midland (Stoke)
    Public Function ExportProcedureXmlAndHTMLByProcedureId(ByVal intProcedureId As Integer) As Boolean
        Try
            Dim blnResult = True
            Dim strHtmlContent As String
            Dim strXmlContent As String = ""

            Dim strFileName As String

            Dim dtData As DataTable
            Dim intProcedureTypeID As Integer = 1
            Dim intPatientId As Integer = 0

            _FileContent = ""
            _intProcedureId = intProcedureId

            Dim strSQL As String = "Select PatientID,ProcedureType From ERS_Procedures Where ProcedureId=" + intProcedureId.ToString()
            dtData = DataAccess.ExecuteSQL(strSQL)
            If Not IsNothing(dtData) Then
                If dtData.Rows.Count > 0 Then
                    intProcedureTypeID = Convert.ToInt32(dtData.Rows(0)("ProcedureType").ToString())
                    intPatientId = Convert.ToInt32(dtData.Rows(0)("PatientId").ToString())
                End If
            End If

            Dim objDExportLogic As New ScotHospitalWSXmlWriter()

            strHtmlContent = objDExportLogic.GetHTML_ContentsOfProcedureTestReulsts(intProcedureId, HttpContext.Current.Session(Constants.SESSION_APPVERSION))

            If Not Directory.Exists(_DataFileExportPath) Then Directory.CreateDirectory(_DataFileExportPath)

            'MH commented out on 27 Aug 2021
            'strFileName = "GIOLJG" + intPatientId.ToString().PadLeft(6, "0") + "_" + intProcedureTypeID.ToString() + "_" + _intProcedureId.ToString().PadLeft(6, "0") + "." + "html"

            'Ben from MediSec didn't want the .html file extension in file name section.
            strFileName = "GIOLJG" + intPatientId.ToString().PadLeft(6, "0") + "_" + intProcedureTypeID.ToString() + "_" + _intProcedureId.ToString().PadLeft(6, "0")

            'MH changed on 18 May 2023 - Do not save HTML file if XML and PDF option is set
            If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.XML_and_HTML Then
                'Saving (Exporting) HTML file
                SaveStringFileContentWithFileNameAndPath(strHtmlContent, strFileName + ".html", _DataFileExportPath)
            End If


            strXmlContent = objDExportLogic.GetXML_ContentsOfProcedureTestReulsts(intProcedureId, HttpContext.Current.Session(Constants.SESSION_APPVERSION))
            strXmlContent = strXmlContent.Replace("tempexportedfilenameextension", strFileName)

            strFileName = "GIOLJG" + intPatientId.ToString().PadLeft(6, "0") + "_" + intProcedureTypeID.ToString() + "_" + _intProcedureId.ToString().PadLeft(6, "0") + "." + "xml"

            'Saving (Exporting) xml file


            SaveStringFileContentWithFileNameAndPath(strXmlContent, strFileName, _DataFileExportPath)

            ''Save (Export to) ExportDataFile to particular directory
            'SaveFileContent()
            Return blnResult
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->ExportProcedureFlatFileByProcedureId()", ex)
            Return False
        End Try
    End Function
    Private Sub GenerateExportFileContent()
        Try
            Dim dsData As New DataSet
            Dim da As New DataAccess
            Dim strOganizationName As String = "" 'Mahfuz added on 15 June 2021

            dsData = da.GetProcedureDataForFileDataExport(_intProcedureId)

            'Mahfuz added on 15 June 2021 for Whittington ICE Export
            If ConfigurationManager.AppSettings.AllKeys.Contains("Ice_FileDataExport_OrganizationName") Then
                strOganizationName = ConfigurationManager.AppSettings("Ice_FileDataExport_OrganizationName").ToString()
            Else
                strOganizationName = "SOLUS ENDOSCOPY"
            End If


            'Add header record line
            _FileContent = "H" + _FieldDelimiter + strOganizationName + _FieldDelimiter +
            DateTime.Now.ToString("yyyyMMddHHmmss") + "-" + _intProcedureId.ToString() + _FieldDelimiter + _intProcedureId.ToString() + _FieldDelimiter + "F"

            'Add patient record line
            _FileContent = _FileContent + _LineDelimiter _
                + GetPatientRecordLine(dsData.Tables(0))

            'Add Staff record line
            _FileContent = _FileContent + _LineDelimiter _
                + GetStaffRecordLine(dsData.Tables(0))

            'Examination Line E record
            _FileContent = _FileContent & _LineDelimiter _
                & _strExaminationRecordLine

            'C record for GP, Procedure creation date etc.
            _FileContent = _FileContent & _LineDelimiter & _strCommonCommentLineStartID & _FieldDelimiter & _strProcedureAndGPRecordLines

            _FileContent = _FileContent & _LineDelimiter & GetExaminationAndCommentRecordLine()


            'Add final 2 lines, line count of Examination and line count of full file.
            Dim intHeaderLineCount As Integer = 0
            Dim intFileLineCount As Integer = 0

            'Mahfuz changed on 29 June 2021
            intFileLineCount = Utilities.InstanceCount(_FileContent, _LineDelimiter) + 1

            'intHeaderLineCount = intFileLineCount - 3

            '_FileContent = _FileContent + LineDelimiter + "L" + _FieldDelimiter + intHeaderLineCount.ToString()
            '_FileContent = _FileContent + LineDelimiter + "F" + _FieldDelimiter + intFileLineCount.ToString()

            _FileContent = _FileContent + LineDelimiter + "L" + _FieldDelimiter + intFileLineCount.ToString()
            _FileContent = _FileContent + LineDelimiter + "F" + _FieldDelimiter + "1" + _FieldDelimiter + (intFileLineCount + 1).ToString()

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GenerateExportFileContent()", ex)
        End Try
    End Sub
    'Mahfuz created on 27 Jan 2022 for Warwickshire XML export file content
    Private Sub GenerateXMLFile_DocinfoPart(dsData As DataSet)
        Try
            Dim ExternalReferenceNumber As String = ""
            Dim strDocumentFileName As String = ""
            strDocumentFileName = System.IO.Path.GetFileName(Session("PDFPathAndFileName"))

            ExternalReferenceNumber = dsData.Tables(0).Rows(0)("PatientId").ToString() & "-" & DateTime.Now.ToString("yyyyMMddHHmmss") & "-" & dsData.Tables(0).Rows(0)("Procedure").ToString() & "-" & dsData.Tables(0).Rows(0)("UniqueExaminationID").ToString()

            'ExternalFileReferenceNumber
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<ExternalReferenceNumber>" & ExternalReferenceNumber & "</ExternalReferenceNumber>"

            'DocumentFileName
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<Documentfilename>" & strDocumentFileName & "</Documentfilename>"

            'DocumentTypeCode
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<DocumentTypeCode>" + dsData.Tables(0).Rows(0)("Procedure").ToString() + " Report</DocumentTypeCode>"

            'Document Created DateTime
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<DocumentCreatedDateTime>" & DateTime.Now.ToString("yyyyMMdd HH:mm:ss") & "</DocumentCreatedDateTime>"

            'DocumentAuthor
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<DocumentAuthor>" & Session("UserID") & "</DocumentAuthor>"


        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GenerateXMLFile_DocinfoPart()", ex)
        End Try
    End Sub
    'Mahfuz created on 27 Jan 2022 for Warwickshire XML export file content
    Private Sub GenerateXMLFile_PatientInfoPart(dsData As DataSet)
        Try
            Dim PatientEpisodeId As String = ""
            Dim PatientForeName As String = ""
            Dim PatientSurname As String = ""
            Dim PatientDOB As String = ""
            Dim PatientNHSNumber As String = ""
            Dim PatientURNNumber As String = ""
            Dim PatientGender As String = ""
            Dim PatientAdmissionDateTime As String = ""
            Dim PatientDischargeDateTime As String = ""
            Dim SpecialtyCode As String = ""
            Dim SpecialtyName As String = ""


            If Not IsDBNull(dsData.Tables(0).Rows(0)("PatientEpisodeId")) Then
                PatientEpisodeId = dsData.Tables(0).Rows(0)("PatientEpisodeId").ToString()
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("Forename1")) Then
                PatientForeName = dsData.Tables(0).Rows(0)("Forename1").ToString()
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("Surname")) Then
                PatientSurname = dsData.Tables(0).Rows(0)("Surname").ToString()
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("DateOfBirth")) Then
                PatientDOB = Convert.ToDateTime(dsData.Tables(0).Rows(0)("DateOfBirth")).ToString("yyyyMMdd")
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("NHSNo")) Then
                PatientNHSNumber = dsData.Tables(0).Rows(0)("NHSNo").ToString()
            End If

            'MH changed on 1 Mar 2022
            'If Not IsDBNull(dsData.Tables(0).Rows(0)("PatientId")) Then
            '    PatientURNNumber = dsData.Tables(0).Rows(0)("PatientId").ToString()
            'End If
            If Not IsDBNull(dsData.Tables(0).Rows(0)("HospitalNumber")) Then
                PatientURNNumber = dsData.Tables(0).Rows(0)("HospitalNumber").ToString()
            Else
                If Not IsDBNull(dsData.Tables(0).Rows(0)("NHSNo")) Then
                    PatientURNNumber = dsData.Tables(0).Rows(0)("NHSNo").ToString()
                Else
                    PatientURNNumber = ""
                End If
            End If

            If PatientURNNumber = "" Then
                PatientURNNumber = PatientNHSNumber
            End If


            If Not IsDBNull(dsData.Tables(0).Rows(0)("SexTitle")) Then
                PatientGender = dsData.Tables(0).Rows(0)("SexTitle").ToString()
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("PatientAdmissionDateTime")) Then
                PatientAdmissionDateTime = Convert.ToDateTime(dsData.Tables(0).Rows(0)("PatientAdmissionDateTime")).ToString("yyyyMMdd HH:mm:ss")
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("PatientDischargeDateTime")) Then
                PatientDischargeDateTime = Convert.ToDateTime(dsData.Tables(0).Rows(0)("PatientDischargeDateTime")).ToString("yyyyMMdd HH:mm:ss")
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("SpecialtyID")) Then
                SpecialtyCode = dsData.Tables(0).Rows(0)("SpecialtyID").ToString()
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ConsultantSpecialty")) Then
                SpecialtyName = dsData.Tables(0).Rows(0)("ConsultantSpecialty").ToString()
            End If

            'PatientEpisodeId
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientEpisodeId>" & PatientURNNumber & "_" & PatientEpisodeId & "</PatientEpisodeId>"

            'PatientForeName
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientForeName>" & PatientForeName & "</PatientForeName>"

            'PatientSurname
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientSurname>" & PatientSurname & "</PatientSurname>"

            'PatientDOB
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientDOB>" & PatientDOB & "</PatientDOB>"

            'PatientNHSNumber
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientNHSNumber>" & PatientNHSNumber & "</PatientNHSNumber>"

            'PatientURNNumber
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientURNNumber>" & PatientURNNumber & "</PatientURNNumber>"

            'PatientGender
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientGender>" & PatientGender & "</PatientGender>"

            'PatientAdmissionDateTime
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientAdmissionDateTime>" & PatientAdmissionDateTime & "</PatientAdmissionDateTime>"

            'PatientDischargeDateTime
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientDischargeDateTime>" & PatientDischargeDateTime & "</PatientDischargeDateTime>"

            'SpecialtyCode
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<SpecialtyCode>" & SpecialtyCode & "</SpecialtyCode>"

            'SpecialtyName
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<SpecialtyName>" & SpecialtyName & "</SpecialtyName>"

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GenerateXMLFile_PatientInfoPart()", ex)
        End Try
    End Sub
    'Mahfuz created on 27 Jan 2022 for Warwickshire XML export file content
    Private Sub GenerateXMLFile_GPPracticePart(dsData As DataSet)
        Try
            Dim PracticeName As String = ""
            Dim GpName As String = ""
            Dim PracticeNacsCode As String = ""


            If Not IsDBNull(dsData.Tables(0).Rows(0)("PracticeName")) Then
                PracticeName = dsData.Tables(0).Rows(0)("PracticeName").ToString()
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("GPCompleteName")) Then
                GpName = dsData.Tables(0).Rows(0)("GPCompleteName").ToString()
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("PracticeNationalCode")) Then
                PracticeNacsCode = dsData.Tables(0).Rows(0)("PracticeNationalCode").ToString()
            End If


            'PatientDischargeDateTime
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PracticeName>" & PracticeName & "</PracticeName>"

            'SpecialtyCode
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<GpName>" & GpName & "</GpName>"

            'SpecialtyName
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PracticeNacsCode>" & PracticeNacsCode & "</PracticeNacsCode>"

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GenerateXMLFile_GPPracticePart()", ex)
        End Try
    End Sub
    'Mahfuz created on 27 Jan 2022 for Warwickshire XML export file content
    Private Sub GeneratePDFSupportingXMLExportFileContent()
        Try
            Dim dsData As New DataSet
            Dim da As New DataAccess
            Dim strOganizationName As String = ""

            dsData = da.GetProcedureDataForFileDataExport(_intProcedureId)

            If ConfigurationManager.AppSettings.AllKeys.Contains("Ice_FileDataExport_OrganizationName") Then
                strOganizationName = ConfigurationManager.AppSettings("Ice_FileDataExport_OrganizationName").ToString()
            Else
                strOganizationName = "SOLUS ENDOSCOPY"
            End If



            _FileContent = "<xml version=""1.0"" encoding=""UTF-8"">"
#Region "Starting xml definition element"
#Region "Block 1 of 3 : Docinfo starting"
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<Docinfo>"
            'Add Docinfo elments here
            GenerateXMLFile_DocinfoPart(dsData)
            _FileContent = _FileContent & vbLf & "</Docinfo>" 'Ending Block 1 of 3 : Docinfo
#End Region
#Region "Block 2 of 3 : PatientInfo starting"
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<PatientInfo>"
            'Add PatientInfo elments here
            GenerateXMLFile_PatientInfoPart(dsData)
            _FileContent = _FileContent & vbLf & "</PatientInfo>" 'Ending Block 2 of 3 : PatientInfo
#End Region
#Region "Block 3 of 3 : GPPractice starting"
            _FileContent = _FileContent & vbLf
            _FileContent = _FileContent & "<GPPractice>"
            'Add GPPractice elments here
            GenerateXMLFile_GPPracticePart(dsData)
            _FileContent = _FileContent & vbLf & "</GPPractice>" 'Ending Block 3 of 3 : GPPractice
#End Region

#End Region
            _FileContent = _FileContent & vbLf & "</xml>" 'Ending xml definition element
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GenerateExportFileContent()", ex)
        End Try
    End Sub

    'Mahfuz created new funciton on 27 Oct 2021 for Southampton Practice Plus Group export document
    Private Sub GenerateExportFileContent_For_Southampton_PracticePlusGroup()
        Try
            Dim dsData As New DataSet
            Dim da As New DataAccess
            Dim strOganizationName As String = ""
            Dim strReportID As String = ""
            Dim strMessagePriority As String = ""
            Dim strHTMLFullContent As String = ""
            Dim strHTMLEachLine As String = ""
            Dim strHtmlLineArray() As String

            Dim objScotHosW As ScotHospitalWSXmlWriter = New ScotHospitalWSXmlWriter


            dsData = da.GetProcedureDataForFileDataExport(_intProcedureId)

            If ConfigurationManager.AppSettings.AllKeys.Contains("Ice_FileDataExport_OrganizationName") Then
                strOganizationName = ConfigurationManager.AppSettings("Ice_FileDataExport_OrganizationName").ToString()
            Else
                strOganizationName = "SOLUS ENDOSCOPY"
            End If

            strReportID = GetExportMessageUniqueID(dsData.Tables(0))

            strMessagePriority = GetMessagePriority(dsData.Tables(0))


            'Changes are made on 01 Mar 2022 - TFS # 1960 - Changes in Export Document for Southampton PPG

            'Add header record line
            '_FileContent = "HEADER" + _FieldDelimiter + strReportID + _FieldDelimiter + strOganizationName + _FieldDelimiter +
            'DateTime.Now.ToString("yyyyMMddhhmmss") + _FieldDelimiter + strMessagePriority.ToString()

            _FileContent = "HEADER" + _FieldDelimiter + strReportID + _FieldDelimiter +
            DateTime.Now.ToString("yyyyMMddHHmmss") + _FieldDelimiter + "Normal" 'N changed to Normal on 01 Mar 2022


            'Add Requester Line
            _FileContent = _FileContent + _LineDelimiter _
                + GetRequesterLine(dsData.Tables(0))

            'Add Provider Line
            _FileContent = _FileContent + _LineDelimiter _
                + GetProviderLine(dsData.Tables(0))

            'Add patient record line
            _FileContent = _FileContent + _LineDelimiter _
                + GetPatientLine(dsData.Tables(0))

            'Add Patient Admin Line  // No need , we don't have Patient Alternate demographics

            'Add Reported Service Line
            Dim intPatientType As Int32
            Dim strPatientType As String = "PPI"
            Dim strPatientStatusForEvent As String = "IP"

            Dim strDocumentStartTime As String = ""
            Dim strDocumentEndDate As String = ""

            Dim strDocumentStartDate As String = ""
            Dim strDocumentEndDateOnly As String = ""

            'Patient Type 1 = NHS, 2 = Private
            If Not IsDBNull(dsData.Tables(0).Rows(0)("PatientType")) Then
                intPatientType = Convert.ToInt32(dsData.Tables(0).Rows(0)("PatientType").ToString())
            Else
                intPatientType = 1
            End If

            '1 = InPatient, 2 = OutPatient, 3 = Day Patient
            If intPatientType = 1 Then
                strPatientType = "PPI"
                strPatientStatusForEvent = "IP"
            ElseIf intPatientType = 2 Then
                strPatientStatusForEvent = "MV"
                strPatientType = "PPR"
            ElseIf intPatientType = 3 Then
                strPatientStatusForEvent = "DC"
                strPatientType = "PPR"
            Else
                strPatientType = "PPR"
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ExaminationDateTime")) Then
                strDocumentStartTime = Convert.ToDateTime(dsData.Tables(0).Rows(0)("ExaminationDateTime")).ToString("yyyyMMddHHmmss")
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ExminationEndDate")) Then
                strDocumentEndDate = Convert.ToDateTime(dsData.Tables(0).Rows(0)("ExminationEndDate")).ToString("yyyyMMddHHmmss")
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ExaminationDateTime")) Then
                strDocumentStartDate = Convert.ToDateTime(dsData.Tables(0).Rows(0)("ExaminationDateTime")).ToString("yyyyMMdd")
            End If

            If Not IsDBNull(dsData.Tables(0).Rows(0)("ExminationEndDate")) Then
                strDocumentEndDateOnly = Convert.ToDateTime(dsData.Tables(0).Rows(0)("ExminationEndDate")).ToString("yyyyMMdd")
            End If


            _FileContent = _FileContent + _LineDelimiter _
                + "REPORTEDSERVICE" & FieldDelimiter & "" & FieldDelimiter & strPatientType & FieldDelimiter & "CO" & FieldDelimiter & "" & FieldDelimiter & ""

            'MH fixed missing REPORTEVENT LINE - ON 09 NOV 2021
            _FileContent = _FileContent + _LineDelimiter _
                + "REPORTEDEVENT" & FieldDelimiter & strDocumentStartDate & FieldDelimiter & "81" & FieldDelimiter & strDocumentEndDateOnly & FieldDelimiter & "82" & FieldDelimiter & strPatientStatusForEvent & FieldDelimiter & "UN"


            'ReportDocumentLine Section - Adam wants to remove REPORTDOCUMENT line 7 Completely. Email conversation 11 NOV 2021
            '_FileContent = _FileContent + _LineDelimiter _
            '    + "REPORTDOCUMENT" & FieldDelimiter & "" & FieldDelimiter & "Clinical Correspondence" & FieldDelimiter & HttpContext.Current.Session("UserID").ToString() & FieldDelimiter &
            '    strDocumentStartTime & FieldDelimiter & strDocumentEndDate & FieldDelimiter


            strHTMLFullContent = objScotHosW.GetHTML_ContentsOfProcedureTestReulsts(_intProcedureId, HttpContext.Current.Session(Constants.SESSION_APPVERSION))

            strHtmlLineArray = strHTMLFullContent.Split(vbCrLf)
            '_intMaxCharacterLengthForEachLine max character is set to 70. If Southampton PPG requires less than that, it can be set here like below:
            '_intMaxCharacterLengthForEachLine = 65

            For Each strLine As String In strHtmlLineArray
                strLine = strLine.Replace(vbCr, "").Replace(vbCrLf, "").Replace(vbLf, "")

                If Len(strLine) > _intMaxCharacterLengthForEachLine Then
                    _FileContent = _FileContent & _LineDelimiter & "REPORTHTML" & FieldDelimiter & GetBrokenLinesByMaxLineLength(strLine, "REPORTHTML")
                Else
                    _FileContent = _FileContent & _LineDelimiter & "REPORTHTML" & FieldDelimiter & strLine
                End If
            Next

            strHTMLEachLine = strHTMLFullContent

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GenerateExportFileContent()", ex)
        End Try
    End Sub
    Private Function GetExportMessageUniqueID(dtdata As DataTable) As String
        Try
            Dim strMessageUniqueID As String = ""

            'If Not IsDBNull(dtdata.Rows(0)("Forename1")) Then
            '    strMessageUniqueID = dtdata.Rows(0)("Forename1").ToString().Substring(0, 3).ToUpper()
            'End If

            'If Not IsDBNull(dtdata.Rows(0)("Surname")) Then
            '    strMessageUniqueID = strMessageUniqueID + dtdata.Rows(0)("Surname").ToString().Substring(0, 3).ToUpper()
            'End If
            strMessageUniqueID = _ExportFileName

            strMessageUniqueID = strMessageUniqueID + _intProcedureId.ToString()


            If Not IsDBNull(dtdata.Rows(0)("Procedure")) Then
                strMessageUniqueID = strMessageUniqueID + dtdata.Rows(0)("Procedure").ToString().Substring(0, 3).ToUpper()
            End If

            strMessageUniqueID = strMessageUniqueID + DateTime.Now.ToString("yyyyMMddHHmmss")

            Return strMessageUniqueID
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetExportMessageUniqueID()", ex)
        End Try
    End Function
    Private Function GetMessagePriority(dtdata As DataTable) As String
        Try
            Dim strProcedurePriority As String = ""
            Dim strMsgPriorityCode As String = ""

            If Not IsDBNull(dtdata.Rows(0)("ProcedurePriority")) Then
                strProcedurePriority = dtdata.Rows(0)("ProcedurePriority").ToString()
            End If

            If strProcedurePriority.Contains("High") Or strProcedurePriority.Contains("Urgent") Then
                strMsgPriorityCode = "H"
            Else
                strMsgPriorityCode = "N"
            End If

            Return strMsgPriorityCode
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetExportMessageUniqueID()", ex)
        End Try
    End Function
    Private Function GetPatientRecordLine(dtData As DataTable) As String
        Try
            Dim strPatientRecordLine As String = ""
            Dim strCaseNoteNo As String = ""
            Dim strNHSNo As String = ""
            Dim strSurname As String = ""
            Dim strForename As String = ""
            Dim strMiddleName As String = ""
            Dim strDateOfBirth As String = ""
            Dim strSex As String = ""
            Dim strAddress1 As String = ""
            Dim strAddress2 As String = ""
            Dim strAddress3 As String = ""
            Dim strAddress4 As String = ""
            Dim strPostcode As String = ""
            Dim strPatientCurrentLocationCode As String = ""
            Dim strPatientCurrentLocationName As String = ""

            Dim strUniqueExaminationID As String = ""
            Dim strExaminationCode As String = ""
            Dim strExaminationName As String = ""
            Dim strDateRequested As String = ""
            Dim strDateTimeOfExamination As String = ""
            Dim strProcedureDateTimeFormatted As String = ""
            Dim strHospitalName As String = ""
            Dim strReferringDoctorCode As String = ""
            Dim strReferringDoctorName As String = ""
            Dim strEndoscopistName As String = ""
            Dim strEndoscopist2Name As String = "" 'MH added on 06 Apr 2022

            Dim strNurse1Name As String = ""
            Dim strNurse2Name As String = ""

            Dim strGPCompleteName As String = ""
            Dim strPracticeName As String = ""
            Dim strPracticeAddress1 As String = ""
            Dim strPracticeAddress2 As String = ""
            Dim strPracticeAddress3 As String = ""
            Dim strPracticeAddress4 As String = ""
            Dim strPracticePostCode As String = ""

            _strExaminationRecordLine = "" 'filling in this method but to be used later
            _strProcedureAndGPRecordLines = "" 'filling in this method but to be used later

            Dim strCommentLineStartID As String = "C"

            If dtData.Rows.Count > 0 Then
                If Not IsDBNull(dtData.Rows(0)("HospitalNumber")) Then
                    strCaseNoteNo = dtData.Rows(0)("HospitalNumber").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("NHSNo")) Then
                    strNHSNo = Utilities.FormatHealthServiceNumber(dtData.Rows(0)("NHSNo").ToString())
                End If

                If Not IsDBNull(dtData.Rows(0)("Surname")) Then
                    strSurname = dtData.Rows(0)("Surname").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Forename1")) Then
                    strForename = dtData.Rows(0)("Forename1").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Forename2")) Then
                    strMiddleName = dtData.Rows(0)("Forename2").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("DateofBirth")) Then
                    strDateOfBirth = Convert.ToDateTime(dtData.Rows(0)("DateofBirth")).ToString("yyyyMMdd")
                End If
                If Not IsDBNull(dtData.Rows(0)("Sex")) Then
                    strSex = dtData.Rows(0)("Sex").ToString()
                End If


                If Not IsDBNull(dtData.Rows(0)("Address1")) Then
                    strAddress1 = dtData.Rows(0)("Address1").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("Address2")) Then
                    strAddress2 = dtData.Rows(0)("Address2").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("Address3")) Then
                    strAddress3 = dtData.Rows(0)("Address3").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("Address4")) Then
                    strAddress4 = dtData.Rows(0)("Address4").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Postcode")) Then
                    strPostcode = dtData.Rows(0)("Postcode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PatientCurrentLocationCode")) Then
                    strPatientCurrentLocationCode = dtData.Rows(0)("PatientCurrentLocationCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PatientCurrentLocationName")) Then
                    strPatientCurrentLocationName = dtData.Rows(0)("PatientCurrentLocationName").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("HospitalName")) Then
                    strHospitalName = dtData.Rows(0)("HospitalName").ToString()
                End If


                'Examination Record Line
                If Not IsDBNull(dtData.Rows(0)("UniqueExaminationID")) Then
                    strUniqueExaminationID = dtData.Rows(0)("UniqueExaminationID").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("ExaminationCode")) Then
                    strExaminationCode = dtData.Rows(0)("ExaminationCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("ExaminationName")) Then
                    strExaminationName = dtData.Rows(0)("ExaminationName").ToString()
                End If

                strDateRequested = "" 'Keeping blank as per spec

                If Not IsDBNull(dtData.Rows(0)("ExaminationDateTime")) Then
                    strDateTimeOfExamination = Convert.ToDateTime(dtData.Rows(0)("ExaminationDateTime")).ToString("yyyyMMddHHmm")
                End If

                If Not IsDBNull(dtData.Rows(0)("ExaminationDateTime")) Then
                    strProcedureDateTimeFormatted = Convert.ToDateTime(dtData.Rows(0)("ExaminationDateTime")).ToString("dd MMMM yyyy (HH:mm tt)")
                End If

                If Not IsDBNull(dtData.Rows(0)("ReferralDoctorCode")) Then
                    strReferringDoctorCode = dtData.Rows(0)("ReferralDoctorCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("ReferralDoctorName")) Then
                    strReferringDoctorName = dtData.Rows(0)("ReferralDoctorName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("EndoscopistName")) Then
                    strEndoscopistName = dtData.Rows(0)("EndoscopistName").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("Endoscopist2Name")) Then
                    strEndoscopist2Name = dtData.Rows(0)("Endoscopist2Name").ToString()
                End If


                If Not IsDBNull(dtData.Rows(0)("Nurse1Name")) Then
                    strNurse1Name = dtData.Rows(0)("Nurse1Name").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Nurse2Name")) Then
                    strNurse2Name = dtData.Rows(0)("Nurse2Name").ToString()
                End If

                'Register GP / Practice section
                If Not IsDBNull(dtData.Rows(0)("GPCompleteName")) Then
                    strGPCompleteName = dtData.Rows(0)("GPCompleteName").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeName")) Then
                    strPracticeName = dtData.Rows(0)("PracticeName").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeAddress1")) Then
                    strPracticeAddress1 = dtData.Rows(0)("PracticeAddress1").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeAddress2")) Then
                    strPracticeAddress2 = dtData.Rows(0)("PracticeAddress2").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeAddress3")) Then
                    strPracticeAddress3 = dtData.Rows(0)("PracticeAddress3").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeAddress4")) Then
                    strPracticeAddress4 = dtData.Rows(0)("PracticeAddress4").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticePostCode")) Then
                    strPracticePostCode = dtData.Rows(0)("PracticePostCode").ToString()
                End If
            End If

            _strExaminationRecordLine = "E" & FieldDelimiter & strUniqueExaminationID & FieldDelimiter & strExaminationCode & FieldDelimiter _
                & strExaminationName & FieldDelimiter & strDateRequested & FieldDelimiter & strDateTimeOfExamination

            '06 Apr 2022 - MH fixed Performed by block for Whittington.
            'Procedure and GP-GPPractice record lines
            _strProcedureAndGPRecordLines = "Procedure Date: " & strProcedureDateTimeFormatted & _LineDelimiter &
                strCommentLineStartID & _FieldDelimiter & "Performed at:" & Space(3) &
                strHospitalName & _LineDelimiter & strCommentLineStartID & _FieldDelimiter & "Performed by: " & Space(2) & strEndoscopistName & _LineDelimiter &
                strCommentLineStartID & _FieldDelimiter & Space(16) & strEndoscopist2Name & _LineDelimiter &
                strCommentLineStartID & _FieldDelimiter & _LineDelimiter &
                strCommentLineStartID & _FieldDelimiter &
                "Nurses:" & Space(9) & strNurse1Name & _LineDelimiter & strCommentLineStartID & _FieldDelimiter & Space(16) & strNurse2Name &
                _LineDelimiter &
                strCommentLineStartID & FieldDelimiter & _LineDelimiter &
                strCommentLineStartID & FieldDelimiter &
                "Registered GP:" & Space(2) & strGPCompleteName & _LineDelimiter & strCommentLineStartID & _FieldDelimiter & Space(16) &
                strPracticeAddress1 & _LineDelimiter & strCommentLineStartID & _FieldDelimiter & Space(16) & strPracticeAddress2 & _LineDelimiter &
                strCommentLineStartID & _FieldDelimiter & Space(16) &
                strPracticeAddress3 & _LineDelimiter & strCommentLineStartID & _FieldDelimiter & Space(16) & strPracticePostCode


            strPatientRecordLine = "P" & _FieldDelimiter & strCaseNoteNo & _FieldDelimiter & strNHSNo & _FieldDelimiter & strSurname &
                _FieldDelimiter & strForename & _FieldDelimiter & strMiddleName & _FieldDelimiter & strDateOfBirth & _FieldDelimiter &
                strSex & _FieldDelimiter & strAddress1 & _FieldDelimiter & strAddress2 & _FieldDelimiter & strAddress3 & _FieldDelimiter &
                strAddress4 & _FieldDelimiter & strPostcode & _FieldDelimiter & strPatientCurrentLocationCode & _FieldDelimiter & strPatientCurrentLocationName

            Return strPatientRecordLine

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetPatientRecordLine()", ex)
        End Try
    End Function
    Private Function GetRequesterLine(dtData As DataTable) As String
        Try
            Dim strRequesterLine As String = ""
            Dim strHospitalName As String = ""
            Dim strGPCode As String = ""
            Dim strGPNationalCode As String = ""
            Dim strReferringDoctorName As String = ""
            Dim strEndoscopistName As String = ""
            Dim strNurse1Name As String = ""
            Dim strNurse2Name As String = ""

            Dim strGPName As String = ""
            Dim strGPCompleteName As String = ""
            Dim strGPRole As String = ""

            Dim strPracticeCode As String = ""
            Dim strPracticeNationalCode As String = ""
            Dim strPracticeName As String = ""
            Dim strPracticeAddress1 As String = ""
            Dim strPracticeAddress2 As String = ""
            Dim strPracticeAddress3 As String = ""
            Dim strPracticeAddress4 As String = ""
            Dim strPracticePostCode As String = ""
            Dim intPatientType As Integer

            If dtData.Rows.Count > 0 Then

                If Not IsDBNull(dtData.Rows(0)("GPCode")) Then
                    strGPCode = dtData.Rows(0)("GPCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("GPNationalCode")) Then
                    strGPNationalCode = dtData.Rows(0)("GPNationalCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("ReferralDoctorName")) Then
                    strReferringDoctorName = dtData.Rows(0)("ReferralDoctorName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("EndoscopistName")) Then
                    strEndoscopistName = dtData.Rows(0)("EndoscopistName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Nurse1Name")) Then
                    strNurse1Name = dtData.Rows(0)("Nurse1Name").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Nurse2Name")) Then
                    strNurse2Name = dtData.Rows(0)("Nurse2Name").ToString()
                End If

                'Register GP / Practice section
                If Not IsDBNull(dtData.Rows(0)("GPName")) Then
                    strGPName = dtData.Rows(0)("GPName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("GPCompleteName")) Then
                    strGPCompleteName = dtData.Rows(0)("GPCompleteName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PracticeCode")) Then
                    strPracticeCode = dtData.Rows(0)("PracticeCode").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeNationalCode")) Then
                    strPracticeNationalCode = dtData.Rows(0)("PracticeNationalCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PracticeName")) Then
                    strPracticeName = dtData.Rows(0)("PracticeName").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeAddress1")) Then
                    strPracticeAddress1 = dtData.Rows(0)("PracticeAddress1").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeAddress2")) Then
                    strPracticeAddress2 = dtData.Rows(0)("PracticeAddress2").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeAddress3")) Then
                    strPracticeAddress3 = dtData.Rows(0)("PracticeAddress3").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticeAddress4")) Then
                    strPracticeAddress4 = dtData.Rows(0)("PracticeAddress4").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("PracticePostCode")) Then
                    strPracticePostCode = dtData.Rows(0)("PracticePostCode").ToString()
                End If

                'Patient Type 1 = NHS, 2 = Private
                If Not IsDBNull(dtData.Rows(0)("PatientType")) Then
                    intPatientType = Convert.ToInt32(dtData.Rows(0)("PatientType").ToString())
                Else
                    intPatientType = 1
                End If

                If intPatientType = 2 Then 'Private
                    strGPRole = "PT"
                Else
                    strGPRole = "PRG"
                End If
            End If

            '25 Feb 2022 - MH placed extra space after GPcode at third position. - This will require their existing procedure uspGetProcedureDataForExport to be changed to normal
            'strRequesterLine = "REQUESTER" & _FieldDelimiter & strGPCode & _FieldDelimiter & _FieldDelimiter & strGPNationalCode & _FieldDelimiter & strGPRole & _FieldDelimiter & strGPName & _FieldDelimiter & "CU" &
            '    _FieldDelimiter & strPracticeCode & _FieldDelimiter & strPracticeNationalCode & _FieldDelimiter & strPracticeName & _FieldDelimiter & strPracticePostCode & _FieldDelimiter &
            '    strPracticeAddress1 & _FieldDelimiter & strPracticeAddress2 & _FieldDelimiter & strPracticeAddress3 & _FieldDelimiter & strPracticeAddress4 & _FieldDelimiter & ""


            'Made changes on 01 Mar 2022 - TFS 1960
            strRequesterLine = "REQUESTER" & _FieldDelimiter & "GP" & _FieldDelimiter & "" & _FieldDelimiter & "PRG" & _FieldDelimiter & strGPName & _FieldDelimiter & "CU" &
                _FieldDelimiter & "22" & _FieldDelimiter & "GP" & _FieldDelimiter & strPracticeCode & _FieldDelimiter & "" & _FieldDelimiter &
                "" & _FieldDelimiter & ""

            Return strRequesterLine

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetRequesterLine()", ex)
        End Try
    End Function
    Private Function GetProviderLine(dtData As DataTable) As String
        Try
            Dim strProviderLine As String = ""

            Dim strPatientCurrentLocationCode As String = ""
            Dim strPatientCurrentLocationName As String = ""

            Dim TrustCode As String = ""
            Dim TrustName As String = ""
            Dim TrustPostCode As String = ""
            Dim TrustAddress1 As String = ""
            Dim TrustAddress2 As String = ""
            Dim TrustAddress3 As String = ""
            Dim TrustAddress4 As String = ""
            Dim TrustAddress5 As String = ""


            Dim strListConsultantCode As String = ""
            Dim strListConsultantNationalCode As String = ""
            Dim strListConsultantName As String = ""
            Dim strConsultantSpecialty As String = ""


            If dtData.Rows.Count > 0 Then


                If Not IsDBNull(dtData.Rows(0)("PatientCurrentLocationCode")) Then
                    strPatientCurrentLocationCode = dtData.Rows(0)("PatientCurrentLocationCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PatientCurrentLocationName")) Then
                    strPatientCurrentLocationName = dtData.Rows(0)("PatientCurrentLocationName").ToString()
                End If


                If Not IsDBNull(dtData.Rows(0)("TrustCode")) Then
                    TrustCode = dtData.Rows(0)("TrustCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("TrustName")) Then
                    TrustName = dtData.Rows(0)("TrustName").ToString()
                End If



                If Not IsDBNull(dtData.Rows(0)("ListConsultantCode")) Then
                    strListConsultantCode = dtData.Rows(0)("ListConsultantCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("ListConsultantName")) Then
                    strListConsultantName = dtData.Rows(0)("ListConsultantName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("ConsultantSpecialty")) Then
                    strConsultantSpecialty = dtData.Rows(0)("ConsultantSpecialty").ToString()
                End If



                If Not IsDBNull(dtData.Rows(0)("PatientCurrentLocationCode")) Then
                    strPatientCurrentLocationCode = dtData.Rows(0)("PatientCurrentLocationCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PatientCurrentLocationName")) Then
                    strPatientCurrentLocationName = dtData.Rows(0)("PatientCurrentLocationName").ToString()
                End If


            End If

            'strProviderLine = "PROVIDER" & FieldDelimiter & strListConsultantCode & FieldDelimiter & strListConsultantNationalCode & FieldDelimiter _
            '    & strListConsultantName & FieldDelimiter & "CU" & FieldDelimiter & "" & FieldDelimiter & TrustCode & FieldDelimiter & TrustName & FieldDelimiter &
            '    TrustPostCode & FieldDelimiter & TrustAddress1 & FieldDelimiter & TrustAddress2 & FieldDelimiter & TrustAddress3 & FieldDelimiter & TrustAddress4 & FieldDelimiter &
            '    TrustAddress5 & FieldDelimiter & strPatientCurrentLocationCode & FieldDelimiter & strPatientCurrentLocationName & FieldDelimiter & strConsultantSpecialty & FieldDelimiter &
            '    "" & FieldDelimiter & ""

            'MH changed as below on 01 Mar 2022: TFS 1960
            strProviderLine = "PROVIDER" & FieldDelimiter & strListConsultantCode & FieldDelimiter & "" & FieldDelimiter _
                & strListConsultantName & FieldDelimiter & "CU" & FieldDelimiter & "23" & FieldDelimiter & "" & FieldDelimiter & "CareUK" & FieldDelimiter & "" & FieldDelimiter &
                "" & FieldDelimiter & "" & FieldDelimiter & "" & FieldDelimiter & "" & FieldDelimiter & "" & FieldDelimiter & strPatientCurrentLocationName



            Return strProviderLine

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetProviderLine()", ex)
        End Try
    End Function
    Private Function GetPatientLine(dtData As DataTable) As String
        Try
            Dim strPatientLine As String = ""
            Dim strPatientID As String = ""

            Dim strCaseNoteNo As String = ""
            Dim strNHSNo As String = ""
            Dim strSurname As String = ""
            Dim strForename As String = ""
            Dim strMiddleName As String = ""
            Dim strDateOfBirth As String = ""
            Dim strDateOfDeath As String = ""

            Dim strPatientTitle As String = ""

            Dim strSex As String = ""
            Dim strAddress1 As String = ""
            Dim strAddress2 As String = ""
            Dim strAddress3 As String = ""
            Dim strAddress4 As String = ""
            Dim strPostcode As String = ""
            Dim strPatientCurrentLocationCode As String = ""
            Dim strPatientCurrentLocationName As String = ""


            If dtData.Rows.Count > 0 Then
                If Not IsDBNull(dtData.Rows(0)("HospitalNumber")) Then
                    strCaseNoteNo = dtData.Rows(0)("HospitalNumber").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("NHSNo")) Then
                    'strNHSNo = Utilities.FormatNHS(dtData.Rows(0)("NHSNo").ToString()) 'They requrested NHSNo without formatting (without spaces)
                    strNHSNo = dtData.Rows(0)("NHSNo").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Surname")) Then
                    strSurname = dtData.Rows(0)("Surname").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PatientID")) Then
                    strPatientID = dtData.Rows(0)("PatientID").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PatientTitle")) Then
                    strPatientTitle = dtData.Rows(0)("PatientTitle").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Forename1")) Then
                    strForename = dtData.Rows(0)("Forename1").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Forename2")) Then
                    strMiddleName = dtData.Rows(0)("Forename2").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("DateofBirth")) Then
                    strDateOfBirth = Convert.ToDateTime(dtData.Rows(0)("DateofBirth")).ToString("yyyyMMdd")
                End If

                If Not IsDBNull(dtData.Rows(0)("DateOfDeath")) Then
                    strDateOfDeath = Convert.ToDateTime(dtData.Rows(0)("DateOfDeath")).ToString("yyyyMMdd")
                End If

                If Not IsDBNull(dtData.Rows(0)("Sex")) Then
                    strSex = dtData.Rows(0)("Sex").ToString()
                End If


                If Not IsDBNull(dtData.Rows(0)("Address1")) Then
                    strAddress1 = dtData.Rows(0)("Address1").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("Address2")) Then
                    strAddress2 = dtData.Rows(0)("Address2").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("Address3")) Then
                    strAddress3 = dtData.Rows(0)("Address3").ToString()
                End If
                If Not IsDBNull(dtData.Rows(0)("Address4")) Then
                    strAddress4 = dtData.Rows(0)("Address4").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Postcode")) Then
                    strPostcode = dtData.Rows(0)("Postcode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PatientCurrentLocationCode")) Then
                    strPatientCurrentLocationCode = dtData.Rows(0)("PatientCurrentLocationCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("PatientCurrentLocationName")) Then
                    strPatientCurrentLocationName = dtData.Rows(0)("PatientCurrentLocationName").ToString()
                End If


            End If

            strPatientLine = "PATIENT" & _FieldDelimiter & strNHSNo & _FieldDelimiter & "" & _FieldDelimiter & strCaseNoteNo & _FieldDelimiter & "" & FieldDelimiter & strSurname &
                _FieldDelimiter & strForename & _FieldDelimiter & strMiddleName & _FieldDelimiter & strPatientTitle & FieldDelimiter & strDateOfBirth & _FieldDelimiter &
                strSex & _FieldDelimiter & strPostcode & FieldDelimiter & "81" & _FieldDelimiter & strAddress1 & _FieldDelimiter & strAddress2 & _FieldDelimiter & strAddress3 & _FieldDelimiter &
                strAddress4 & _FieldDelimiter & "" & _FieldDelimiter & strDateOfDeath

            Return strPatientLine

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetPatientLine()", ex)
        End Try
    End Function
    Private Function GetExaminationAndCommentRecordLine() As String
        Try
            Dim da As New DataAccess
            Dim dtData As New DataTable

            Dim strExamAndCommentRecordLine = ""

            dtData = da.GetReportSummaryByGroup(_intProcedureId, "RS")


            dtData = New DataTable
            dtData = da.GetReportSummary(_intProcedureId)
            strExamAndCommentRecordLine = GetRecordLinesFromReportDataTableRows(dtData)

            dtData = New DataTable
            dtData = da.GetPremedReportSummary(_intProcedureId)
            strExamAndCommentRecordLine = strExamAndCommentRecordLine & _LineDelimiter & GetRecordLinesFromReportDataTableRows(dtData)


            Return strExamAndCommentRecordLine
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetExaminationAndCommentRecordLine()", ex)
        End Try
    End Function
    Private Function GetRecordLinesFromReportDataTableRows(dtRecData As DataTable) As String
        Dim strOutputResult As String = ""
        Dim strEachNodeSummaryLine As String = ""
        Dim streachNodeSummaryLineArray() As String
        Dim strLineStartID As String = "C"
        Try
            If Not IsNothing(dtRecData) Then
                If dtRecData.Rows.Count > 0 Then
                    For Each drD As DataRow In dtRecData.Rows
                        If Not IsDBNull(drD(0)) AndAlso Not IsDBNull(drD(1)) Then
                            If drD(0).ToString().Trim() <> "" AndAlso drD(1).ToString().Trim() <> "" Then

                                If strOutputResult.Trim() = "" Then
                                    strOutputResult = strLineStartID & _FieldDelimiter & _LineDelimiter & strLineStartID & _FieldDelimiter & drD(0).ToString() & ":"
                                Else
                                    strOutputResult = strOutputResult & _LineDelimiter & strLineStartID & _FieldDelimiter & _LineDelimiter & strLineStartID & _FieldDelimiter & drD(0).ToString()
                                End If

                                strEachNodeSummaryLine = drD(1).ToString().Replace("<br>", "¬").Replace("<br/>", "¬").Replace("<br />", "¬") 'Assuming there will be no ¬ character in actual data

                                'MH added on 17 Mar 2022 - TFS #1997 Whittington Line break fix in Advice/Comments
                                strEachNodeSummaryLine = strEachNodeSummaryLine.Replace(vbCrLf, vbCr).Replace(vbCr, "¬").Replace(vbLf, "¬")


                                'Remove end line break;
                                If strEachNodeSummaryLine.Substring(strEachNodeSummaryLine.Length - 1, 1) = "¬" Then
                                    strEachNodeSummaryLine = strEachNodeSummaryLine.Substring(0, strEachNodeSummaryLine.Length - 1)
                                End If
                                streachNodeSummaryLineArray = strEachNodeSummaryLine.Split("¬")
                                For Each strLine As String In streachNodeSummaryLineArray
                                    strLine = Utilities.StripTags(strLine)
                                    strLine = strLine.Replace("&nbsp;", " ").Replace("  ", " ").Replace(" - ", " ").Replace("&#39;", "'")

                                    strLine = GetBrokenLinesByMaxLineLength(strLine, strLineStartID)
                                    strOutputResult = strOutputResult & _LineDelimiter & strLineStartID & _FieldDelimiter & strLine
                                Next
                            End If
                        End If
                    Next
                End If
            End If

            Return strOutputResult
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetRecordLinesFromReportDataTableRows()", ex)
        End Try
    End Function
    Private Function GetBrokenLinesByMaxLineLength(strInputLine As String, strLineIDTag As String) As String
        Dim strResult As String = ""
        Dim htmlTagsMatchCollection As MatchCollection
        Dim strHtmlTagArray() As String
        Dim strHtmlTagSpaceReplacedArray() As String

        htmlTagsMatchCollection = Regex.Matches(strInputLine, "<.*?>")
        ReDim strHtmlTagArray(htmlTagsMatchCollection.Count)
        ReDim strHtmlTagSpaceReplacedArray(htmlTagsMatchCollection.Count)

        Dim i As Int16 = 0

        For Each m As Match In htmlTagsMatchCollection
            strHtmlTagArray(i) = m.Value.ToString()
            strHtmlTagSpaceReplacedArray(i) = m.Value.ToString().Replace(" ", "¬")

            strInputLine = strInputLine.Replace(strHtmlTagArray(i), strHtmlTagSpaceReplacedArray(i))
            i = i + 1
        Next

        strInputLine = strInputLine.Replace("<br />", "<br/>").Replace("><", "> <")


        Dim strWordArray() = strInputLine.Split(" ")



        Dim strEachLine As String = ""

        For Each strWord As String In strWordArray

            If Not String.IsNullOrEmpty(strEachLine) Then
                If (strEachLine + " " + strWord).Length > _intMaxCharacterLengthForEachLine Then
                    If strResult.Trim() = "" Then
                        strResult = strEachLine
                        strEachLine = strWord
                    Else
                        strResult = strResult + _LineDelimiter & strLineIDTag & _FieldDelimiter & strEachLine
                        strEachLine = strWord
                    End If
                Else
                    strEachLine = strEachLine + " " + strWord
                End If
            Else
                strEachLine = strWord
            End If
        Next
        If strResult.Trim() = "" Then
            strResult = strEachLine
        Else
            strResult = strResult + _LineDelimiter & strLineIDTag & _FieldDelimiter & strEachLine
        End If

        Do While i > 0
            strResult = strResult.Replace(strHtmlTagSpaceReplacedArray(i - 1), strHtmlTagArray(i - 1))
            i = i - 1
        Loop

        strResult = strResult.Replace("<br/>", "<br />").Replace("> <", "><")

        Return strResult
    End Function

    Private Function GetStaffRecordLine(dtData As DataTable) As String
        Try
            Dim strStaffRecordLine As String = ""
            Dim strReferringDoctorCode As String = ""
            Dim strReferringDoctorName As String = ""
            Dim strEndoscopistName As String = ""
            Dim strNurse1Name As String = ""
            Dim strNurse2Name As String = ""
            Dim strListConsultantCode As String = ""
            Dim strListConsultantName As String = ""



            If dtData.Rows.Count > 0 Then
                If Not IsDBNull(dtData.Rows(0)("ReferralDoctorCode")) Then
                    strReferringDoctorCode = dtData.Rows(0)("ReferralDoctorCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("ReferralDoctorName")) Then
                    strReferringDoctorName = dtData.Rows(0)("ReferralDoctorName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("EndoscopistName")) Then
                    strEndoscopistName = dtData.Rows(0)("EndoscopistName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Nurse1Name")) Then
                    strNurse1Name = dtData.Rows(0)("Nurse1Name").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Nurse2Name")) Then
                    strNurse2Name = dtData.Rows(0)("Nurse2Name").ToString()
                End If


                If Not IsDBNull(dtData.Rows(0)("ListConsultantCode")) Then
                    strListConsultantCode = dtData.Rows(0)("ListConsultantCode").ToString()
                End If


                If Not IsDBNull(dtData.Rows(0)("ListConsultantName")) Then
                    strListConsultantName = dtData.Rows(0)("ListConsultantName").ToString()
                End If

            End If

            strStaffRecordLine = "S" & _FieldDelimiter & strReferringDoctorCode & _FieldDelimiter & strReferringDoctorName & _FieldDelimiter & strEndoscopistName &
                _FieldDelimiter & strNurse1Name & _FieldDelimiter & strNurse2Name & _FieldDelimiter &
                strListConsultantCode & _FieldDelimiter & strListConsultantName & _FieldDelimiter

            Return strStaffRecordLine

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetStaffRecordLine()", ex)
        End Try
    End Function
    Private Function GetExaminationRecordLine(dtData As DataTable) As String
        Try
            Dim strStaffRecordLine As String = ""
            Dim strReferringDoctorCode As String = ""
            Dim strReferringDoctorName As String = ""
            Dim strEndoscopistName As String = ""
            Dim strNurse1Name As String = ""
            Dim strNurse2Name As String = ""
            Dim strListConsultantCode As String = ""
            Dim strListConsultantName As String = ""



            If dtData.Rows.Count > 0 Then
                If Not IsDBNull(dtData.Rows(0)("ReferralDoctorCode")) Then
                    strReferringDoctorCode = dtData.Rows(0)("ReferralDoctorCode").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("ReferralDoctorName")) Then
                    strReferringDoctorName = dtData.Rows(0)("ReferralDoctorName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("EndoscopistName")) Then
                    strEndoscopistName = dtData.Rows(0)("EndoscopistName").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Nurse1Name")) Then
                    strNurse1Name = dtData.Rows(0)("Nurse1Name").ToString()
                End If

                If Not IsDBNull(dtData.Rows(0)("Nurse2Name")) Then
                    strNurse2Name = dtData.Rows(0)("Nurse2Name").ToString()
                End If


                If Not IsDBNull(dtData.Rows(0)("ListConsultantCode")) Then
                    strListConsultantCode = dtData.Rows(0)("ListConsultantCode").ToString()
                End If


                If Not IsDBNull(dtData.Rows(0)("ListConsultantName")) Then
                    strListConsultantName = dtData.Rows(0)("ListConsultantName").ToString()
                End If

            End If

            strStaffRecordLine = "S" & _FieldDelimiter & strReferringDoctorCode & _FieldDelimiter & strReferringDoctorName & _FieldDelimiter & strEndoscopistName &
                _FieldDelimiter & strNurse1Name & _FieldDelimiter & strNurse2Name & _FieldDelimiter &
                strListConsultantCode & _FieldDelimiter & strListConsultantName & _FieldDelimiter

            Return strStaffRecordLine

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetStaffRecordLine()", ex)
        End Try
    End Function

    Private Sub SaveFileContent()
        Try
            If Not Directory.Exists(_DataFileExportPath) Then Directory.CreateDirectory(_DataFileExportPath)
            Dim strDateTimeStamp As String = Date.Now.ToString("yyyyMMdd_HHmmss")
            Dim strFileNamePath As String
            Dim dtData As DataTable
            Dim intProcedureTypeID As Integer = 1
            Dim intPatientId As Integer = 0
            Dim intOutputDocumentStoreId As Integer = 0

            'Mahfuz changed export file name rules on 08 June 2021
            'strFileNamePath = _DataFileExportPath + "\" + _ExportFileName + "_" + _intProcedureId.ToString() + "_" + strDateTimeStamp + "." + _ExportFileExtension
            Dim strSQL As String = "Select PatientID,ProcedureType From ERS_Procedures Where ProcedureId=" + _intProcedureId.ToString()
            dtData = DataAccess.ExecuteSQL(strSQL)
            If Not IsNothing(dtData) Then
                If dtData.Rows.Count > 0 Then
                    intProcedureTypeID = Convert.ToInt32(dtData.Rows(0)("ProcedureType").ToString())
                    intPatientId = Convert.ToInt32(dtData.Rows(0)("PatientId").ToString())
                End If
            End If

            If _ExportGlobalFileNamePath.Trim() = "" Then
                strFileNamePath = _DataFileExportPath + "\" + _ExportFileName + intPatientId.ToString().PadLeft(6, "0") + "_" + _intProcedureId.ToString().PadLeft(6, "0") + "_" + intProcedureTypeID.ToString() + "." + _ExportFileExtension
            Else
                strFileNamePath = _DataFileExportPath + "\" + _ExportGlobalFileNamePath + "." + _ExportFileExtension
            End If


            Using objStreamWriter As New StreamWriter(strFileNamePath)
                objStreamWriter.Write(_FileContent)
                objStreamWriter.Flush()
            End Using

            'AddExportFileForMirth here based on Condition 
            'MH added on 19 Nov 2021
            If Session(Constants.SESSION_ADD_EXPORT_FILE_FOR_MIRTH) = True Then
                Dim strMessage As String = ""
                Dim da As DataAccess = New DataAccess
                Dim FileContentsBytesArray() As Byte
                FileContentsBytesArray = System.Text.Encoding.Unicode.GetBytes(_FileContent)
                strMessage = strFileNamePath
                da.InsertExportFileProcessToMirth(strMessage, FileContentsBytesArray, strFileNamePath, _DataFileExportPath, _ExportGlobalFileNamePath + "." + _ExportFileExtension, intOutputDocumentStoreId)
                da.Dispose()

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

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->SaveFileContent()", ex)
        End Try
    End Sub
    Public Function GetPatientProcedureFileNameByProcedureID(intProcedureID As Int32) As String
        Try
            Dim strFileName As String
            Dim dtData As DataTable
            Dim intProcedureTypeID As Integer = 1
            Dim intPatientId As Integer = 0

            Dim strSQL As String = "Select PatientID,ProcedureType From ERS_Procedures Where ProcedureId=" + _intProcedureId.ToString()
            dtData = DataAccess.ExecuteSQL(strSQL)
            If Not IsNothing(dtData) Then
                If dtData.Rows.Count > 0 Then
                    intProcedureTypeID = Convert.ToInt32(dtData.Rows(0)("ProcedureType").ToString())
                    intPatientId = Convert.ToInt32(dtData.Rows(0)("PatientId").ToString())
                End If
            End If


            strFileName = intPatientId.ToString().PadLeft(6, "0") + "_" + intProcedureTypeID.ToString() + "_" + _intProcedureId.ToString().PadLeft(6, "0")
            Return strFileName
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetPatientProcedureFileNameByProcedureID()", ex)
        End Try
    End Function
    Public Sub SaveStringFileContentWithFileNameAndPath(strFileContent As String, strFileNameWithExtension As String, strDirectory As String)
        Try
            Dim strFileNameWithDirectoryPath As String = ""
            Dim intOutputDocumentStoreId As Integer = 0

            If Not Directory.Exists(strDirectory) Then Directory.CreateDirectory(strDirectory)
            strFileNameWithDirectoryPath = strDirectory + "\" + strFileNameWithExtension

            Using objStreamWriter As New StreamWriter(strFileNameWithDirectoryPath)
                objStreamWriter.Write(strFileContent)
                objStreamWriter.Flush()
            End Using


            'AddExportFileForMirth here based on Condition
            'MH added on 19 Nov 2021
            If Session(Constants.SESSION_ADD_EXPORT_FILE_FOR_MIRTH) = True Then
                Dim strMessage As String = ""
                Dim da As DataAccess = New DataAccess
                Dim FileContentBytesArray() As Byte
                FileContentBytesArray = System.Text.Encoding.Unicode.GetBytes(strFileContent)
                strMessage = strFileNameWithDirectoryPath
                da.InsertExportFileProcessToMirth(strMessage, FileContentBytesArray, strFileNameWithDirectoryPath, strDirectory, strFileNameWithExtension, intOutputDocumentStoreId)
                da.Dispose()
            End If

            If intOutputDocumentStoreId > 0 Then
                If IsNothing(Session("DocumentStoreIdList")) Then
                    Session("DocumentStoreIdList") = intOutputDocumentStoreId.ToString()
                ElseIf (Session("DocumentStoreIdList") = "") Then
                    Session("DocumentStoreIdList") = intOutputDocumentStoreId.ToString()
                Else
                    Session("DocumentStoreIdList") = Session("DocumentStoreIdList") + "," + intOutputDocumentStoreId.ToString()
                End If
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->SaveStringFileContentWithFileNameAndPath()", ex)
        End Try
    End Sub
#Region "Batch Document Export related Functions"
    'MH created Batch Document Export related functions on 13 May 2022
    Public Function GetTotalProcedureCountsForBatchExportByMasterId(intBatchExportMasterId As Integer) As Integer
        Try
            Dim intTotalProcsCount As Integer = 0
            Dim da As New DataAccess
            intTotalProcsCount = da.GetTotalProcedureCountsForBatchExport(intBatchExportMasterId)
            da.Dispose()
            Return intTotalProcsCount

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetTotalProcedureCountsForBatchExportByMasterId", ex)
            Return Nothing
        End Try
    End Function
    Public Function GetAllLeftProceduresForBatchExportByMasterId(intBatchExportMasterId As Integer) As DataSet
        Try
            Dim da As New DataAccess
            Dim ds As New DataSet

            ds = da.GetAllLeftProceduresForBatchExportByMasterId(intBatchExportMasterId)
            da.Dispose()

            Return ds

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetAllLeftProceduresForBatchExportByMasterId", ex)
            Return Nothing
        End Try
    End Function
    Public Function GetTop1UnexportedBatchExportMasterId() As Integer
        Try
            Dim da As New DataAccess
            Return da.GetTop1UnexportedBatchExportMasterId()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->GetTop1UnexportedBatchExportMasterId", ex)
            Return Nothing
        End Try
    End Function
    Public Sub UpdateProcedureBatchExportSuccess(intDocBatchExportProcedureId As Integer)
        Try
            Dim strMessage As String = ""
            Dim da As DataAccess = New DataAccess
            da.UpdateProcedureBatchExportSuccess(intDocBatchExportProcedureId)
            da.Dispose()

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->UpdateProcedureBatchExportSuccess()", ex)
        End Try
    End Sub
    Public Sub LogFailedBatchExportReason(intDocBatchExportProcedureId As Integer, strErrorMessage As String)
        Try
            Dim strMessage As String = ""
            Dim da As DataAccess = New DataAccess
            da.LogFailedBatchExportReason(intDocBatchExportProcedureId, strErrorMessage)
            da.Dispose()

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("DataExportLogic.vb->LogFailedBatchExportReason()", ex)
        End Try
    End Sub
#End Region
End Class
