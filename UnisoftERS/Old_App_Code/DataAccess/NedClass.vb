Imports System.IO
Imports System.Xml
Imports System.Data.SqlClient
Imports System.Web.Hosting
Imports System.Threading
Imports System.Xml.Schema

Public Class NedClass

#Region "Public Properties"
    Private _NEDTestService As Boolean = False
    Property NEDTestService As Boolean
        Get
            Return _NEDTestService
        End Get
        Set(value As Boolean)
            _NEDTestService = value
        End Set
    End Property

    Private _SendValidationErrorEmail As String = ""
    Property SendValidationErrorEmail As String
        Get
            Return _SendValidationErrorEmail
        End Get
        Set(value As String)
            _SendValidationErrorEmail = value
        End Set
    End Property

    Private _XSDTargetNamespace As String = ""
    Property XSDTargetNamespace As String
        Get
            Return _XSDTargetNamespace
        End Get
        Set(value As String)
            _XSDTargetNamespace = value
        End Set
    End Property

    Private _NEDXSD As String = ""
    Property NEDXSD As String
        Get
            Return _NEDXSD
        End Get
        Set(value As String)
            _NEDXSD = value
        End Set
    End Property

    Private Shared _OrganisationApiKey As String = ""
    Shared Property OrganisationApiKey As String
        Get
            Return _OrganisationApiKey
        End Get
        Set(value As String)
            _OrganisationApiKey = value
        End Set
    End Property

    Private Shared _OrganizationCode As String = ""
    Shared Property OrganizationCode As String
        Get
            Return _OrganizationCode
        End Get
        Set(value As String)
            _OrganizationCode = value
        End Set
    End Property

    Private _BatchID As String = ""
    Property BatchID As String
        Get
            Return _BatchID
        End Get
        Set(value As String)
            _BatchID = value
        End Set
    End Property

    Private _IsCompressed As Boolean = False
    Property IsCompressed As Boolean
        Get
            Return _IsCompressed
        End Get
        Set(value As Boolean)
            _IsCompressed = value
        End Set
    End Property

    Private _Flag As Boolean
    Property Flag As Boolean
        Get
            Return _Flag
        End Get
        Set(value As Boolean)
            _Flag = value
        End Set
    End Property

    Private _ProcedureId As String
    Public Property ProcedureId As String
        Get
            Return _ProcedureId
        End Get
        Set(value As String)
            _ProcedureId = value
        End Set
    End Property

    Private Shared _UserID As String = ""
    Public Shared ReadOnly Property UserId As String
        Get
            Return _UserID
        End Get
    End Property

    Private Shared _FromDate As String = "01/01/1980"
    Public Shared Property FromDate
        Get
            Return _FromDate
        End Get
        Set(value)
            _FromDate = value
        End Set
    End Property

    Private Shared _ToDate As String = "31/12/2099"
    Public Shared Property ToDate
        Get
            Return _ToDate
        End Get
        Set(value)
            _ToDate = value
        End Set
    End Property

    Private Shared _ProcedureTypeId As String = ""
    Public Shared Property ProcedureTypeId As String
        Get
            Return _ProcedureTypeId
        End Get
        Set(value As String)
            _ProcedureTypeId = value
        End Set
    End Property

    Private Shared _CNN As String = ""
    Public Shared Property CNN As String
        Get
            Return _CNN
        End Get
        Set(value As String)
            _CNN = value
        End Set
    End Property

    Private Shared _NHS As String = ""
    Public Shared Property NHS As String
        Get
            Return _NHS
        End Get
        Set(value As String)
            _NHS = value
        End Set
    End Property

    Private Shared _PatientName As String = ""
    Public Shared Property PatientName As String
        Get
            Return _PatientName
        End Get
        Set(value As String)
            _PatientName = value
        End Set
    End Property

    Private Shared _OperatingHospitalId As Integer
    Public Shared Property OperatingHospitalId As Integer
        Get
            Return _OperatingHospitalId
        End Get
        Set(value As Integer)
            _OperatingHospitalId = value
        End Set
    End Property

    Private Shared _ApplicationVersion As String
    Public Shared Property ApplicationVersion As String
        Get
            Return _ApplicationVersion
        End Get
        Set(value As String)
            _ApplicationVersion = value
        End Set
    End Property

    'Private Shared _IsProcessed As String = "0"
    'Public Shared Property IsProcessed As String
    '    Get
    '        Return _IsProcessed
    '    End Get
    '    Set(value As String)
    '        _IsProcessed = value
    '    End Set
    'End Property

    'Private Shared _IsSchemaValid As String = "0"
    'Public Shared Property IsSchemaValid As String
    '    Get
    '        Return _IsSchemaValid
    '    End Get
    '    Set(value As String)
    '        _IsSchemaValid = value
    '    End Set
    'End Property

    Private Shared _IsSent As String = "0"
    Public Shared Property IsSent As String
        Get
            Return _IsSent
        End Get
        Set(value As String)
            _IsSent = value
        End Set
    End Property

    Private Shared _IsRejected As String = "0"
    Public Shared Property IsRejected As String
        Get
            Return _IsRejected
        End Get
        Set(value As String)
            _IsRejected = value
        End Set
    End Property

#End Region

    Public Sub New()
        Dim op As New Options
        Dim opHosp = HttpContext.Current.Session("OperatingHospitalID")
        Dim dtSys As DataTable = op.GetSystemSettings(opHosp)
        If dtSys.Rows.Count > 0 AndAlso dtSys.Rows(0)("NEDEnabled") Then
            OrganisationApiKey = dtSys.Rows(0)("NED_APIKey").ToString()
            OrganizationCode = dtSys.Rows(0)("NED_OrganisationCode").ToString()
        End If

        'OrganisationApiKey = ConfigurationManager.AppSettings("Unisoft.OrganisationApiKey")
        'OrganizationCode = ConfigurationManager.AppSettings("Unisoft.OrganizationCode")
        NEDXSD = ConfigurationManager.AppSettings("Unisoft.NEDXSDFileName")
        XSDTargetNamespace = ConfigurationManager.AppSettings("Unisoft.NEDXSDTargetNamespace")
        SendValidationErrorEmail = ConfigurationManager.AppSettings("Unisoft.NEDValidationEmailEnabled")
        BatchID = "0"
    End Sub

    Public Sub sendXMLThread(ByVal ProcedureId As String, ByVal UserId As String, procedureType As Integer, operatingHospitalId As Integer)
        _ProcedureId = ProcedureId
        _UserID = UserId
        _ProcedureTypeId = procedureType
        _OperatingHospitalId = operatingHospitalId
        _ApplicationVersion = HttpContext.Current.Session(Constants.SESSION_APPVERSION).ToString()
        Dim t As Thread
        t = New Thread(AddressOf Me.GenerateNED_XML_ForExport)
        t.Start()
    End Sub

    Public Class NedValidationException
        Inherits Exception

        Sub New(userMessage As String, systemMessage As String)
            MyBase.New(userMessage, New Exception(systemMessage))
        End Sub
    End Class

    Function GetEnvironmentRoot() As String
        Dim RetValue As String = HostingEnvironment.MapPath("~")
        If RetValue.Last() <> "\" Then
            RetValue += "\"
        End If
        Return RetValue
    End Function

    Function ValidateBeforeSend(procedureID As Integer, userID As Integer, procedureType As Integer, softwareVersion As String) As String
        Dim isValid = False

        Try

            _ProcedureId = procedureID
            _UserID = userID
            _ProcedureTypeId = procedureType


            Dim NEDValidation As New NedClass

            'create XML
            Dim strXML = CreateXML()

            'save to tmp location
            Dim tmpFilePath = Path.Combine(GetEnvironmentRoot, "tmp_xml_files\")
            Dim tmpFileName = procedureID.ToString() & "_" & userID.ToString() & "_" & ProcedureTypeId.ToString & "_tmp.xml"
            Dim doc As New XmlDocument()

            Try
                doc.LoadXml(strXML)
                If Not Directory.Exists(tmpFilePath) Then Directory.CreateDirectory(tmpFilePath)
                doc.Save(tmpFilePath & tmpFileName) '### File Path Name example: '~\NED_xml_output\74_22-09-2017_09-32-53_00831101o.xml' 
            Catch ex As Exception
                LogManager.LogManagerInstance.LogError("NedClass.vb => Public Shared Function ValidateBeforeSend()=> Error Saving tmp output File for validation", ex)
            End Try

            'validate
            Dim xsdPath = Path.Combine(GetEnvironmentRoot, "XSD\", NEDXSD)

            Dim valResponse = NEDValidation.LoadValidatedXDocument(tmpFilePath & tmpFileName, xsdPath, SendValidationErrorEmail, XSDTargetNamespace, softwareVersion)

            If valResponse IsNot Nothing Then
                'extract errors to dictionary of string (incorrect property), string (incorrect value)
                Dim errorList = valResponse.GetErrorList()

                Dim errMsg = "The following errors were found while generating the National Data Set file:<br /><br />"
                For Each e In errorList
                    If e.Value.ToString() = "value" Then
                        errMsg += "&bull; Missing value: " & e.Key.ToString() & "<br />"
                    ElseIf e.Value.ToString() = "node" Then
                        errMsg += "&bull; Missing section: " & e.Key.ToString() & "<br />"
                    Else
                        errMsg += "&bull; Incorrect/Invalid " & e.Key.ToString() & " value: " & e.Value.ToString() & "<br />"
                    End If
                Next

                Throw New NedValidationException(errMsg, valResponse.GetErrors(""))
            End If

        Catch ex As Exception
            Throw ex
        End Try
        Return True
    End Function

    Public Function CreateXML(Optional dt As DataTable = Nothing) As String
        Dim sXML = ""
        Dim dtXML_Result As DataTable
        Dim xmlFileContents As String

        If dt Is Nothing Then
            Using da As New DataAccess
                dtXML_Result = da.ExecuteSP("usp_NED_Generate_Report", New SqlParameter() {New SqlParameter("@ProcedureId", ProcedureId)})
            End Using
        Else
            dtXML_Result = dt
        End If

        '### The StoredProc returns some extra fields with some XMLNS attributes which are necessary to be included int he XML file. Wasn't very easy to feed them in the StoredProc- so- inserting them now... "Late better than Never!"
        xmlFileContents = dtXML_Result.Rows(0).Item("returnXML").ToString().Replace("<hospital.SendBatchMessage", dtXML_Result.Rows(0).Item("NS_Info").ToString())

        '### When dealing with 'Limitations'- it only applies for COLON/FLEXI. WHen no 'Limitation' record found at all- then we need to Insert a blank element: eg: '<limitation/>'. This needs to be done from .Net
        '### We know from the XML - XSD- a '<biopsies>' element is MUST. So- we can trace that element to insert a blank '<limitations/>' element
        If (ProcedureTypeId = "1" Or ProcedureTypeId = "2") And Not xmlFileContents.Contains("<limitations") Then
            xmlFileContents = xmlFileContents.Replace("<biopsies>", "<limitations/><biopsies>") '### A blank '<limitations/>' is INSERTED before '<biopsies>'
        End If
        ' What if they haven't put any indications in the procedure?
        If Not xmlFileContents.Contains("<indications") Then
            xmlFileContents = xmlFileContents.Replace("<limitations", "<indications><indication indication=""Other"" comment=""Not Specified"" /></indications><limitations")
        End If
        Return xmlFileContents
    End Function
    ''' <summary>
    ''' This Sub Routine will Execute the Database Procedure and Generate the Required XML data to be Exported to the NED
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub GenerateNED_XML_ForExport()

        '## 4) Now Transmit the file accross the Wire....        
        Try
            Dim op As New Options

            Dim dtSys As DataTable = op.GetSystemSettings(OperatingHospitalId)
            If dtSys.Rows.Count > 0 AndAlso dtSys.Rows(0)("NEDEnabled") Then
                Dim response As New NEDWeblogic.Webservice()

                Dim sNED_ExportStatus As String = ""

                Dim dtXML_Result As DataTable
                Dim xmlFileContents As String, xmlExportFilePathName As String, xmlPreviousFileName As String

                '### 1) Generate the XML contents... from the StoredProc!
                Using da As New DataAccess
                    dtXML_Result = da.ExecuteSP("usp_NED_Generate_Report", New SqlParameter() {New SqlParameter("@ProcedureId", ProcedureId)})
                End Using

                '### The StoredProc returns some extra fields with some XMLNS attributes which are necessary to be included int he XML file. Wasn't very easy to feed them in the StoredProc- so- inserting them now... "Late better than Never!"
                xmlFileContents = CreateXML(dtXML_Result) 'dtXML_Result.Rows(0).Item("returnXML").ToString().Replace("<hospital.SendBatchMessage", dtXML_Result.Rows(0).Item("NS_Info").ToString())

                xmlExportFilePathName = dtXML_Result.Rows(0).Item("xmlFileName").ToString() '### File Path and Name are calculated in the StoredProc.
                xmlPreviousFileName = dtXML_Result.Rows(0).Item("PreviousFileName").ToString()

                '### 2) Put into doc
                '### 2.1 => Before saving the file- Delete the Previous file if any exist!
                If xmlPreviousFileName <> "x" Then '#### Previous Exported XML file name found.. Delete it from the drive!
                    xmlPreviousFileName = Path.Combine(GetEnvironmentRoot, xmlPreviousFileName) '### Create the complete FilePathName
                    If System.IO.File.Exists(xmlPreviousFileName) Then Kill(xmlPreviousFileName)
                End If

                '### 2.2 => Now SAVE!
                Dim doc As New XmlDocument()
                Try
                    'Dim newComment As XmlComment
                    'newComment = doc.CreateComment("NED export build " & _ApplicationVersion)
                    ' load the validated document from the tmp file, then delete the temp file
                    Dim tmpFilePath = Path.Combine(GetEnvironmentRoot, "tmp_xml_files\")
                    Dim tmpFileName = ProcedureId.ToString() & "_" & UserId.ToString() & "_" & ProcedureTypeId.ToString & "_tmp.xml"

                    Try
                        doc.Load(tmpFilePath & tmpFileName)
                        'remove tmp file
                        File.Delete(tmpFilePath & tmpFileName)
                    Catch
                        ' failed to find the temp file, load from SQL
                        doc.LoadXml(xmlFileContents)
                    End Try

                    Dim root = doc.DocumentElement
                    'doc.InsertBefore(newComment, root)

                    If Not Directory.Exists(Path.Combine(GetEnvironmentRoot, dtSys.Rows(0)("NEDExportPath"))) Then Directory.CreateDirectory(Path.Combine(GetEnvironmentRoot, dtSys.Rows(0)("NEDExportPath")))

                    doc.Save(Path.Combine(GetEnvironmentRoot, xmlExportFilePathName)) '### File Path Name example: '~\NED_xml_output\74_22-09-2017_09-32-53_00831101o.xml' 
                Catch ex As Exception
                    LogManager.LogManagerInstance.LogError("NedClass.vb => Public Shared Function GenerateNED_XML_ForExport()>= Error Saving NED_XML output File", ex)
                End Try

                '### 3) Return fileBytes
                Dim fileBytes As Byte() = Encoding.[Default].GetBytes(doc.OuterXml)

                Dim resp As New NEDWebService.SendResponse
                Try
                    Using nedService As New NEDWebService.WebServiceClient
                        If Not String.IsNullOrEmpty(ConfigurationManager.AppSettings("NEDEndpointAddress")) Then
                            Dim endPoint As ServiceModel.EndpointAddress
                            endPoint = New ServiceModel.EndpointAddress(ConfigurationManager.AppSettings("NEDEndpointAddress"))
                            nedService.Endpoint.Address = endPoint
                        End If
                        'Test the service first, if we get a response, send the file over
                        Dim pingTest As String = nedService.Ping()
                        If pingTest.Contains("Pong at ") Then
                            resp = nedService.Send(OrganisationApiKey, OrganizationCode, BatchID, fileBytes, IsCompressed)
                            NED_ExportLog_Insert(ProcedureId, resp.ExceptionMessage, xmlFileContents, xmlExportFilePathName, String.IsNullOrWhiteSpace(resp.ExceptionMessage))
                        Else
                            NED_ExportLog_Insert(ProcedureId, pingTest, xmlFileContents, xmlExportFilePathName, False)
                        End If
                    End Using
                Catch ex As Exception
                    NED_ExportLog_Insert(ProcedureId, "Error handler Exception: " & ex.Message, xmlFileContents, xmlExportFilePathName, False)
                End Try


            End If
        Catch ex As Exception


        End Try

    End Sub

    Public Shared Function ValidateGMCCode(checkProCode As String) As Boolean
        Dim NEDValidation As New NedClass
        Dim resp As Boolean = False
        Try
            Using nedService As New NEDWebService.WebServiceClient
                If Not String.IsNullOrEmpty(ConfigurationManager.AppSettings("NEDEndpointAddress")) Then
                    Dim endPoint As New ServiceModel.EndpointAddress(ConfigurationManager.AppSettings("NEDEndpointAddress"))
                    nedService.Endpoint.Address = endPoint
                End If
                'Test the service first, if we get a response, send the file over
                Dim pingTest As String = nedService.Ping()
                If pingTest.Contains("Pong at ") Then
                    Dim data As NEDWebService.CheckResponse = nedService.CheckValidIdentifier(OrganisationApiKey, OrganizationCode, checkProCode)
                    resp = data.Registered
                End If
                Return resp
            End Using
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("NedClass.vb => Failed to validate GMC Code", ex)
            Return False
        End Try
    End Function

    Public Function GetNEDLog()
        Dim ds As New DataSet
        Dim connection As New SqlConnection(DataAccess.ConnectionStr)
        Dim cmd As New SqlCommand
        Dim sql As String = "Select * From [dbo].[v_rep_NEDLog]"
        Dim Where As Boolean = False

        sql += " Where logDate>=Convert(datetime,'" + Mid(FromDate.ToString, 7, 4) + "-" + Mid(FromDate.ToString, 4, 2) + "-" + Mid(FromDate.ToString, 1, 2) + "') And logDate<=Convert(datetime,'" + Mid(ToDate.ToString, 7, 4) + "-" + Mid(ToDate.ToString, 4, 2) + "-" + Mid(ToDate.ToString, 1, 2) + "')"
        If Not String.IsNullOrWhiteSpace(ProcedureTypeId) Then
            sql += " And ProcedureTypeId IN (" + ProcedureTypeId.ToString + ")"
        End If

        If PatientName <> "" Then
            sql += " And PatientName Like '%" + PatientName + "%'"
        End If

        If Not String.IsNullOrWhiteSpace(CNN) Then
            sql += " And CNN Like '%" + CNN + "%'"
        End If

        If Not String.IsNullOrWhiteSpace(NHS) Then
            sql += " And NHS Like '%" + NHS + "%'"
        End If

        Select Case IsSent
            Case "1"
                sql += " And IsSent=1"
            Case "2"
                sql += " And IsSent=0"
        End Select

        Select Case IsRejected
            Case "1"
                sql += " And IsSuccess=0"
            Case "2"
                sql += " And IsSuccess=1"
        End Select

        sql += " ORDER BY [LogId] DESC;"

        cmd.CommandText = sql
        cmd.Connection = connection
        cmd.CommandType = CommandType.Text
        Dim adapter = New SqlDataAdapter(cmd)
        connection.Open()
        adapter.Fill(ds)
        If ds.Tables.Count > 0 Then
            Return ds
        Else
            Return Nothing
        End If

    End Function

    ''' <summary>
    ''' This will load the XML Data which was exported previously from the Table
    ''' Every time an Export/Upload attempt is made- the XML generated Contents are stored in the Table... So, now Show the Operators what was the Data in it- for Audit!
    ''' </summary>
    ''' <param name="auditLogId">Record Id</param>
    ''' <returns>String</returns>
    ''' <remarks>2017-11-09; Shawkat</remarks>
    Public Shared Function GetXML_ExportedDataById(ByVal auditLogId As Integer) As String
        Try
            Using con As SqlConnection = New SqlConnection(DataAccess.ConnectionStr)
                Using _sqlCmd As SqlCommand = New SqlCommand("Select [xmlFile] From dbo.ERS_NedFilesLog Where [LogId]=@LogId;", con)
                    _sqlCmd.Parameters.Add("@LogId", SqlDbType.Int).Value = auditLogId
                    con.Open()
                    Using xmlReader = _sqlCmd.ExecuteXmlReader()
                        Dim xDocument = System.Xml.Linq.XDocument.Load(xmlReader)
                        Return xDocument.ToString()
                    End Using
                End Using
            End Using

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("NedClass.vb => Public Shared Function GetXML_ExportedDataById()", ex)
            Return "Error reading XML File!"
        End Try
    End Function



    Sub NED_ExportLog_Insert(ByVal procedureId As Integer, ByVal sNED_ExportStatusMessage As String, xmlFileStream As String, ByVal exportedFileName As String, isSent As Boolean)
        'Dim updateExportStatusSQL As String = "Update ERS_NedFilesLog Set IsSent={0}, IsRejected={1}, NEDMessage='{2}' Where LogId In (Select Top 1 LogId From ERS_NedFilesLog Where ProcedureId=@ProcedureId Order By LogId Desc)"
        Try
            '### When no Message is returned- SUCCESSFUL! Then it is Wonderful, too! You can say Awesome!
            DataAccess.ExecuteScalerSQL("usp_NED_Update_Export_Result", CommandType.StoredProcedure, New SqlParameter() _
                                                                                                        {New SqlParameter("@ProcedureId", procedureId),
                                                                                                         New SqlParameter("@NED_ExportMessage", sNED_ExportStatusMessage),
                                                                                                         New SqlParameter("@xml_FileStream", xmlFileStream),
                                                                                                         New SqlParameter("@xmlFileName", exportedFileName),
                                                                                                         New SqlParameter("@UserId", UserId),
                                                                                                         New SqlParameter("@IsSent", isSent)})
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("NedClass.vb => Public Shared Function NED_ExportLog_Insert()", ex)
        End Try


    End Sub

    ''' <summary>
    ''' This will read System Config from the Database for the NED Export Options
    ''' </summary>
    ''' <returns>NedConfig Class object</returns>
    ''' <remarks></remarks>
    Public Shared Function GetConfigSettings() As NedConfig
        Dim oNed As New NedConfig
        Dim dtConfig As New DataTable
        dtConfig = DataAccess.ExecuteSQL("SELECT [NED_HospitalSiteCode], [NED_OrganisationCode], [NED_APIKey], [NED_BatchId], [NED_ExportPath] FROM [dbo].[ERS_SystemConfig]")
        With dtConfig.Rows(0)
            oNed.APIKey = .Item("NED_APIKey") & ""
            oNed.BatchId = .Item("NED_BatchId") & ""
            oNed.ExportPath = .Item("NED_ExportPath") & ""
            oNed.HospitalSiteCode = .Item("NED_HospitalSiteCode") & ""
            oNed.OrganisationCode = .Item("NED_OrganisationCode") & ""
        End With

        Return oNed
    End Function

#Region "Validator"
    Public Function LoadValidatedXDocument(xmlFilePath As String, xsdFilePath As String, SendErrorEmail As String, Optional xsdTargetNameSpace As String = "", Optional softwareVersion As String = "") As XmlValidationErrorBuilder
        Dim doc As XDocument = XDocument.Load(xmlFilePath)
        Dim schemas As New XmlSchemaSet()

        If String.IsNullOrWhiteSpace(xsdTargetNameSpace) Then
            schemas.Add(xsdFilePath, xsdFilePath)
        Else
            schemas.Add(xsdTargetNameSpace, xsdFilePath)

        End If
        Dim bValidationErrors As Boolean = False

        Dim errorBuilder As New XmlValidationErrorBuilder()
        doc.Validate(schemas, New ValidationEventHandler(AddressOf errorBuilder.ValidationEventHandler))

        Dim sMessageBody As String = ""

        Dim errorsText As String = errorBuilder.GetErrors(sMessageBody)
        If errorsText IsNot Nothing Then

            '#### Text for Email Subject
            If CBool(SendErrorEmail) Then
                Dim sEmailSubject As String = ""
                Dim sSoftwareVersion As String = ""
                Dim elements As IEnumerable(Of XElement) = From e In doc.Descendants()
                                                           Select e

                For Each element As XElement In elements
                    If Right(element.Name.ToString.ToLower, 25) = "hospital.sendbatchmessage" Then
                        If element.Attribute("softwareVersion") IsNot Nothing Then sSoftwareVersion = " [" & element.Attribute("softwareVersion").Value & "]" Else sSoftwareVersion = softwareVersion
                    ElseIf Right(element.Name.ToString.ToLower, 7) = "session" Then
                        sEmailSubject = "[" & element.Attribute("site").Value & "] " &
                                        "[" & element.Attribute("date").Value & "-" &
                                         element.Attribute("time").Value & "]"
                        Exit For
                    End If
                Next
                If Trim(sEmailSubject) = "" Then
                    sEmailSubject = "National Data Set XML validation error"
                End If
                sEmailSubject = "NEDU " & sEmailSubject & sSoftwareVersion &
                            IIf(errorsText = "", "", " [" & Mid(errorsText, 4, 25) & "..]")

                SendEmail(sMessageBody, xmlFilePath, sEmailSubject)
            End If

            Return errorBuilder
        Else
            Return Nothing
        End If
    End Function

    Sub SendEmail(sMessageBody As String, xmlFilePath As String, sEmailSubject As String)
        Dim eSender As New Email
        Dim attach As System.Net.Mail.Attachment = New System.Net.Mail.Attachment(xmlFilePath)
        eSender.sendNEDErrorEmail(sMessageBody, attach, sEmailSubject)
    End Sub
#End Region
End Class

Public Class NedConfig
#Region "Public Properties"
    Private _hospitalSiteCode As String
    Public Property HospitalSiteCode() As String
        Get
            Return _hospitalSiteCode
        End Get
        Set(ByVal value As String)
            _hospitalSiteCode = value
        End Set
    End Property

    Private _exportPath As String
    Public Property ExportPath() As String
        Get
            Return _exportPath
        End Get
        Set(ByVal value As String)
            _exportPath = value
        End Set
    End Property

    Private _organisationCode As String
    Public Property OrganisationCode() As String
        Get
            Return _organisationCode
        End Get
        Set(ByVal value As String)
            _organisationCode = value
        End Set
    End Property

    Private _APIKey As String
    Public Property APIKey() As String
        Get
            Return _APIKey
        End Get
        Set(ByVal value As String)
            _APIKey = value
        End Set
    End Property


    Private _batchId As String
    Public Property BatchId() As String
        Get
            Return _batchId
        End Get
        Set(ByVal value As String)
            _batchId = value
        End Set
    End Property




#End Region
    Public Sub SaveSettings(ByVal config As NedConfig)
        DataAccess.ExecuteScalerSQL("usp_NED_Update_Export_Settings", CommandType.StoredProcedure, New SqlParameter() _
                                                                                {New SqlParameter("@OrganisationCode", config.OrganisationCode),
                                                                                New SqlParameter("@APIKey", config.APIKey),
                                                                                New SqlParameter("@BatchId", config.BatchId),
                                                                                New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID")))})
    End Sub
End Class