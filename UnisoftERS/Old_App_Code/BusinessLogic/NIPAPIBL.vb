Imports System.Linq
Imports Microsoft.VisualBasic
Imports ERS.Data
Imports System.Data.SqlClient
Imports System.Reflection
'Imports UnisoftERS.ScotHospitalWebservice
Imports Microsoft.Ajax.Utilities

Imports Hl7.Fhir.Serialization
Imports System.IO
Imports System.Net.Http
Imports System.Xml
Imports System.Xml.Linq
Imports Hl7.Fhir.Model
Imports DevExpress.DataProcessing.InMemoryDataProcessor.GraphGenerator
Imports System.Xml.XPath
Imports DevExpress.Web.Internal

Public Class NIPAPIBL
    Inherits System.Web.UI.Page




    Function GetPatientFromNIPAPIByCHINumber(chiNumber As String) As String
        Dim patientData As String

        Try

            Dim httpClient = New HttpClient
            httpClient.BaseAddress = New Uri(ConfigurationManager.AppSettings("NIPAPIURL").ToString())
            httpClient.DefaultRequestHeaders.Add("System-Source", "hd-clinical")
            Dim consumeApi = httpClient.GetAsync("Patient/" + chiNumber)
            consumeApi.Wait()

            Dim readData = consumeApi.Result
            If (readData.IsSuccessStatusCode) Then
                Dim displayData = readData.Content.ReadAsStringAsync()
                displayData.Wait()
                patientData = displayData.Result
                Return patientData
            Else
                Throw New Exception(readData.StatusCode & "==" & readData.ReasonPhrase)
            End If



        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetPatientFromNIPAPIByCHINumber()", ex)

        End Try


    End Function

    Function ExtractPatientInfoFromAPIXML(patientInfo As String) As Hl7.Fhir.Model.Patient
        Dim patient As Hl7.Fhir.Model.Patient
        Try

            Dim stReader As StringReader = New StringReader(patientInfo)
            Dim xr = XmlReader.Create(stReader)
            Dim parser As FhirXmlParser = New FhirXmlParser()
            patient = parser.Parse(Of Hl7.Fhir.Model.Patient)(xr)
            Return patient

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ExtractPatientInfoFromXML()", ex)

        End Try


    End Function



    Function GetPatientFromNIPByCHINumber(chiNumber As String, includeGP As Boolean) As PatientNIP
        Dim patient As Hl7.Fhir.Model.Patient
        Try


            Dim patientInfo = GetPatientFromNIPAPIByCHINumber(chiNumber)
            If (patientInfo = "APIConnctionError") Then
                Throw New Exception(" Error during Connecting to NIP Service==")
            End If
            patient = ExtractPatientInfoFromAPIXML(patientInfo)
            If Not (patient Is Nothing) Then
                Dim PatientNIPobj = GeneratePatientNip(patient)

                If (includeGP = True) Then
                    PopulateGPAndPractice(patientInfo, PatientNIPobj)
                End If


                Return PatientNIPobj
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetPatientFromNIPByCHINumber()", ex)
            Return Nothing
        End Try


    End Function



    Function PopulateGPAndPractice(patientInfo As String, PatientNIPobj As PatientNIP)
        Try

            Dim xmlDoc1 = New XmlDocument()
            xmlDoc1.LoadXml(patientInfo)

            Dim xmlContained = xmlDoc1.GetElementsByTagName("contained")
            Dim practiceCode = GetGPValue(xmlContained, "https://digitalhealthplatform.scot/fhir/GpPracticeCode")
            Dim gmcNumber = GetGPValue(xmlContained, "http://fhir.nhs.scot.uk/national/gmc-number")
            PatientNIPobj.GPGMCCode = gmcNumber
            PatientNIPobj.GPPracticeCode = practiceCode
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetGeneratedDatasetFromFindPatientItemCollection()", ex)

        End Try

    End Function
    Function PatientNipFromXML(patientInfo As String)
        Try

            Dim xmlDoc1 = New XmlDocument()
            xmlDoc1.LoadXml(patientInfo)

            Dim xmlContained = xmlDoc1.GetElementsByTagName("contained")
            Dim practiceCode = GetGPValue(xmlContained, "https://digitalhealthplatform.scot/fhir/GpPracticeCode")
            Dim gmcNumber = GetGPValue(xmlContained, "http://fhir.nhs.scot.uk/national/gmc-number")
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in PatientNipFromXML()", ex)

        End Try

    End Function

    Private Function GetGPValue(ByVal items As XmlNodeList, ByVal codeName As String) As String
        Dim value As String = Nothing

        For Each item As XmlNode In items

            For Each item1 As XmlNode In item.FirstChild

                If item1.Name = "identifier" Then
                    Dim firstChild = item1.FirstChild
                    Dim codeNameVale = firstChild.Attributes("value").Value

                    If codeNameVale = codeName Then
                        firstChild = item1.ChildNodes(1)
                        value = firstChild.Attributes("value").Value
                        Exit For
                    End If
                End If
            Next
        Next

        Return value
    End Function
    Function GeneratePatientNip(patient1 As Hl7.Fhir.Model.Patient) As PatientNIP


        Dim patientNIP = New PatientNIP
        Try


            patientNIP.NHSNo = patient1.Identifier(0).Value
            patientNIP.CaseNoteNo = patient1.Identifier(0).Value
            patientNIP.HospitalNumber = patient1.Identifier(0).Value



            patientNIP.Forename = patient1.Name(0).GivenElement(0).Value
            patientNIP.Surname = patient1.Name(0).Family
            patientNIP.PatientName = patient1.Name(0).ToString()
            patientNIP.FullAddress = patient1.Address(0).LineElement(0).ToString()
            patientNIP.PostCode = patient1.Address(0).PostalCode

            Dim address = patient1.Address
            If address.Count > 0 Then
                If address(0).LineElement.Count >= 1 Then
                    patientNIP.Address1 = address(0).LineElement(0).ToString()

                End If
                If address(0).LineElement.Count >= 2 Then
                    patientNIP.Address2 = address(0).LineElement(1).ToString()

                End If
                If address(0).LineElement.Count >= 3 Then
                    patientNIP.Address3 = address(0).LineElement(2).ToString()

                End If

                patientNIP.PostCode = address(0).PostalCode



            End If


            patientNIP.Gender = patient1.GenderElement.ToString()
            patientNIP.DateOfBirth = patient1.BirthDate
            If patient1.Deceased Is Nothing Then
                patientNIP.isDeceased = False
            Else
                patientNIP.isDeceased = True
                patientNIP.DateOfDeath = patient1.Deceased(0).Value
            End If
            Return patientNIP
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GeneratePatientNip()", ex)
            Return Nothing
        End Try
    End Function





    Public Function GetPatientFromNIPAndGetGeneratedDataset(chiNumber As String) As DataSet

        Dim patient = GetPatientFromNIPByCHINumber(chiNumber, False)

        Return GetGeneratedDatasetFromFindPatientItemCollection(patient)


    End Function



    Public Function GetGeneratedDatasetFromFindPatientItemCollection(patient1 As PatientNIP) As DataSet
        Dim dsPatients As New DataSet

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

            intPatientRowID = 1


            If Not (patient1 Is Nothing) Then

                objNewRow = patientTable.NewRow()





                objNewRow("PatientId") = intPatientRowID
                objNewRow("NHSNo") = patient1.NHSNo
                objNewRow("CaseNoteNo") = patient1.CaseNoteNo
                objNewRow("HospitalNumber") = patient1.HospitalNumber

                objNewRow("PatientRowID") = intPatientRowID

                objNewRow("Forename1") = patient1.Forename
                objNewRow("Surname") = patient1.Surname
                objNewRow("PatientName") = patient1.PatientName
                objNewRow("Address") = patient1.FullAddress
                objNewRow("PostCode") = patient1.PostCode
                objNewRow("Gender") = patient1.Gender
                objNewRow("DOB") = patient1.DateOfBirth
                objNewRow("DateOfBirth") = patient1.DateOfBirth
                objNewRow("Deceased") = patient1.isDeceased
                objNewRow("ERSPatient") = 1


                patientTable.Rows.Add(objNewRow)

                intPatientRowID = intPatientRowID + 1
                'Next
            End If
            dsPatients.Tables.Add(patientTable)
            Return dsPatients
#End Region
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetGeneratedDatasetFromFindPatientItemCollection()", ex)
            Return Nothing
        End Try
    End Function



    Public Function ExtractAndImportPatientsIntoDatabase(chiNumber As String) As Integer
        Dim patient = GetPatientFromNIPByCHINumber(chiNumber, True)
        Dim SEPatientId As Integer
        SEPatientId = ImportPatientsIntoDatabase(patient)
        Return SEPatientId
    End Function




    Public Function ImportPatientsIntoDatabase(patient As PatientNIP) As Integer
        Try

            Dim objDA As DataAccess

            Dim intPatientId As Nullable(Of Integer)
            objDA = New DataAccess

            Dim patientId As Integer = objDA.AddUpdatePatientFromNIPAPI(intPatientId, patient.CaseNoteNo, patient.Title, patient.Forename, patient.Surname, patient.DateOfBirth, patient.NHSNo,
  patient.Address1, patient.Address2, patient.Address3, Nothing, patient.PostCode, Nothing, patient.Gender, patient.EthnicOrigin, Nothing, patient.GPGMCCode, patient.GPPracticeCode, patient.DateOfDeath, Nothing,
   Nothing, patient.MaritalStatus, Session("SearchedNHSNo"), CInt(Session("TrustId")))

            Return patientId

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ImportPatientsIntoDatabase()", ex)
            Return Nothing
        End Try
    End Function



End Class







Public Class PatientNIP
    Public Property CaseNoteNo As String
    Public Property NHSNo As String
    Public Property HospitalNumber As String
    Public Property Title As String
    Public Property Forename As String
    Public Property Surname As String
    Public Property PatientName As String
    Public Property DateOfBirth As Date
    Public Property FullAddress As String
    Public Property Address1 As String
    Public Property Address2 As String
    Public Property Address3 As String
    Public Property PostCode As String
    Public Property Gender As String
    Public Property EthnicOrigin As String
    Public Property MaritalStatus As String
    Public Property GPGMCCode As String
    Public Property GPPracticeCode As String
    Public Property isDeceased As Boolean
    Public Property DateOfDeath As Date

End Class
