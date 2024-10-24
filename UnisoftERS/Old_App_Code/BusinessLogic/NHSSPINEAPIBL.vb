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
Imports Microsoft.IdentityModel.Tokens
Imports System.IdentityModel.Tokens.Jwt
Imports System.Security.Claims
Imports DevExpress.XtraPrinting.Native
Imports System.Net.Http.Headers
Imports Newtonsoft.Json
Imports System.Threading.Tasks
Imports DevExpress.CodeParser

Public Class NHSSPINEAPIBL
    Inherits System.Web.UI.Page

    Function GetPatientFromNHSSPINEAPIBynhsNumber(nhsNumber As String) As NHSSpinePatientInfo
        Dim patientData As String

        Try
            Dim patientNHSSpine = New NHSSpinePatientInfo()
            Dim httpClient = New HttpClient
            SetHttpClient(httpClient)
            'httpClient.BaseAddress = New Uri(getSpineAPIURL())
            'Dim token = populatehttpheader()
            'httpClient.DefaultRequestHeaders.Authorization = New AuthenticationHeaderValue("Bearer", token)

            Dim consumeApi = httpClient.GetAsync("api/PDSPatientSearch/PatientSearchByNHSNo/" + nhsNumber)
            consumeApi.Wait()

            Dim readData = consumeApi.Result
            If (readData.IsSuccessStatusCode) Then
                Dim displayData = readData.Content.ReadAsStringAsync()
                displayData.Wait()
                patientData = displayData.Result

                patientNHSSpine = JsonConvert.DeserializeObject(Of NHSSpinePatientInfo)(patientData)
                Return patientNHSSpine
            Else
                Throw New Exception(readData.StatusCode & "==" & readData.ReasonPhrase)
            End If
            Return Nothing


        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetPatientFromNHSSPINEAPIBynhsNumber()", ex)
            Return Nothing
        End Try


    End Function

    Private Function SetHttpClient(httpClient As HttpClient)


        httpClient.BaseAddress = New Uri(getSpineAPIURL())
        Dim token = populatehttpheader()
        httpClient.DefaultRequestHeaders.Authorization = New AuthenticationHeaderValue("Bearer", token)
    End Function

    Private Function getSpineAPIURL()
        Dim url = ConfigurationManager.AppSettings("SPINEAPIURL").ToString()
        If url Is Nothing Then
            Return Nothing
        Else
            If url.EndsWith("/") Then
                Return url
            Else

                Return url & "/"
            End If
        End If

    End Function

    Function GetPatientFromNHSSPINEAPIByAll(familyname As String, givenName As String, birthdate As String, gender As String, postcode As String) As List(Of NHSSpinePatientInfo)
        Dim patientData As String
        Dim ListOfpatientNHSSpine = New List(Of NHSSpinePatientInfo)
        Try
            Dim httpClient = New HttpClient
            SetHttpClient(httpClient)
            'httpClient.BaseAddress = New Uri(getSpineAPIURL())
            'Dim token = populatehttpheader()
            'httpClient.DefaultRequestHeaders.Authorization = New AuthenticationHeaderValue("Bearer", token)
            Dim searchstring As String = "?"
            searchstring += "familyName=" & (If(String.IsNullOrEmpty(familyname), "null", familyname))
            searchstring += "&givenName=" & (If(String.IsNullOrEmpty(givenName), "null", givenName))
            searchstring += "&birthDate=" & (If(String.IsNullOrEmpty(birthdate), "null", birthdate.Replace("/", "-")))
            searchstring += "&postCode=" & (If(String.IsNullOrEmpty(postcode), "null", postcode))


            Dim consumeApi = httpClient.GetAsync("api/PDSPatientSearch/PatientSearchAll/" + searchstring)
            consumeApi.Wait()

            Dim readData = consumeApi.Result
            If (readData.IsSuccessStatusCode) Then
                Dim displayData = readData.Content.ReadAsStringAsync()
                displayData.Wait()
                patientData = displayData.Result

                ListOfpatientNHSSpine = JsonConvert.DeserializeObject(Of List(Of NHSSpinePatientInfo))(patientData)
                Return ListOfpatientNHSSpine
            Else
                Throw New Exception(readData.StatusCode & "==" & readData.ReasonPhrase)
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetPatientFromNHSSPINEByAll()", ex)
            Return Nothing
        End Try


    End Function




    Function GetPatientFromNHSSPINEBynhsNumber(nhsNumber As String) As SEPatientInfo

        Try
            Dim patientInfo = GetPatientFromNHSSPINEAPIBynhsNumber(nhsNumber)

            If Not (patientInfo Is Nothing) Then
                Return GeneratePatientForSE(patientInfo)

            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetPatientFromNHSSPINEBynhsNumber()", ex)
            Return Nothing
        End Try


    End Function

    Function GetPatientFromNHSSPINEByAll(familyname As String, givenName As String, birthdate As String, gender As String, postcode As String) As List(Of SEPatientInfo)
        Dim ListOfPatient As New List(Of SEPatientInfo)
        Try


            Dim ListOfpatientInfo = GetPatientFromNHSSPINEAPIByAll(familyname, givenName, birthdate, gender, postcode)

            If Not (ListOfpatientInfo Is Nothing) Then
                For Each patientInfo As NHSSpinePatientInfo In ListOfpatientInfo
                    ListOfPatient.Add(GeneratePatientForSE(patientInfo))
                Next
                Return ListOfPatient
            Else
                Return Nothing
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetPatientFromNHSSPINEByAll()", ex)
            Return Nothing
        End Try


    End Function


    Function GeneratePatientForSE(patient1 As NHSSpinePatientInfo) As SEPatientInfo


        Dim patientSE = New SEPatientInfo
        Try


            patientSE.NHSNo = patient1.NhsNumber
            patientSE.CaseNoteNo = patient1.NhsNumber
            patientSE.HospitalNumber = patient1.HospitalNumber
            patientSE.Forename = patient1.Forename
            patientSE.Surname = patient1.Surname
            patientSE.PatientName = patient1.Forename + " " + patient1.Surname
            patientSE.FullAddress = patient1.Address
            patientSE.PostCode = patient1.PostCode
            patientSE.Address1 = patient1.Line1
            patientSE.Address2 = patient1.Line2
            patientSE.Address3 = patient1.Line3
            patientSE.Gender = patient1.Gender
            patientSE.DateOfBirth = patient1.Dob
            patientSE.DateOfDeath = patient1.Dod
            If patient1.Dod Is Nothing Then
                patientSE.isDeceased = False
            Else
                patientSE.isDeceased = True

            End If
            patientSE.GPGMCCode = patient1.GPID
            Return patientSE
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GeneratePatientForSE()", ex)
            Return Nothing
        End Try
    End Function





    Public Function GetPatientFromNHSSPINEAndGetGeneratedDataset(nhsNumber As String, familyname As String, givenName As String, birthdate As String, gender As String, postcode As String) As DataSet
        Try


            Dim ListOfPatient = New List(Of SEPatientInfo)
            If (String.IsNullOrEmpty(nhsNumber) And String.IsNullOrEmpty(familyname) And String.IsNullOrEmpty(givenName) And String.IsNullOrEmpty(birthdate) And String.IsNullOrEmpty(gender) And String.IsNullOrEmpty(postcode)) Then
                Return GetGeneratedDatasetFromFindPatientItemCollection(ListOfPatient)
            Else

                If (String.IsNullOrEmpty(nhsNumber)) Then
                    ListOfPatient = GetPatientFromNHSSPINEByAll(familyname, givenName, birthdate, gender, postcode)

                Else
                    Dim SEPatientInfo1 = GetPatientFromNHSSPINEBynhsNumber(nhsNumber)
                    If Not (SEPatientInfo1 Is Nothing) Then
                        ListOfPatient.Add(SEPatientInfo1)
                    End If

                End If
                Return GetGeneratedDatasetFromFindPatientItemCollection(ListOfPatient)

            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetPatientFromNHSSPINEAndGetGeneratedDataset()", ex)
            Return Nothing
        End Try
    End Function



    Public Function GetGeneratedDatasetFromFindPatientItemCollection(patients As List(Of SEPatientInfo)) As DataSet
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


            Dim intPatId As Integer
            Dim intPatientRowID As Integer
            Dim blnCHIProvided As Boolean = True

            intPatientRowID = 1

            If Not (patients Is Nothing) Then

                For Each patient1 As SEPatientInfo In patients
                    Dim objNewRow As DataRow
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


                Next
            End If
            dsPatients.Tables.Add(patientTable)
            Return dsPatients
#End Region
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in GetGeneratedDatasetFromFindPatientItemCollection()", ex)
            Return Nothing
        End Try
    End Function




    Public Function ExtractAndImportPatientsIntoDatabase(nhsNumber As String) As Integer
        Dim patient = GetPatientFromNHSSPINEBynhsNumber(nhsNumber)
        Dim SEPatientId As Integer
        SEPatientId = ImportPatientsIntoDatabase(patient)
        Return SEPatientId
    End Function




    Public Function ImportPatientsIntoDatabase(patient As SEPatientInfo) As Integer
        Try

            Dim objDA As DataAccess

            Dim intPatientId As Nullable(Of Integer)
            objDA = New DataAccess

            Dim patientId As Integer = objDA.AddUpdatePatientFromSPINEAPI(intPatientId, patient.CaseNoteNo, patient.Title, patient.Forename, patient.Surname, patient.DateOfBirth, patient.NHSNo,
            patient.Address1, patient.Address2, patient.Address3, Nothing, patient.PostCode, Nothing, patient.Gender, patient.EthnicOrigin, Nothing, patient.GPGMCCode, patient.GPPracticeCode, patient.DateOfDeath, Nothing,
            Nothing, patient.MaritalStatus, Session("SearchedNHSNo"), CInt(Session("TrustId")))

            Return patientId

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in ImportPatientsIntoDatabase()", ex)
            Return Nothing
        End Try
    End Function

    Private Function populatehttpheader()
        Dim guid As Guid = Guid.NewGuid()

        ' httpClient.BaseAddress = New Uri(ConfigurationManager.AppSettings("NHSSPINEAPIURL").ToString())
        Dim key = ConfigurationManager.AppSettings("SPINEAPIKEY").ToString()
        Dim Audience = ConfigurationManager.AppSettings("Audience").ToString()
        Dim Issuer = ConfigurationManager.AppSettings("Issuer").ToString()
        Dim TimeOutInMinute = ConfigurationManager.AppSettings("TimeOutInMinute").ToString()


        Dim token = Session("NHSSpineServiceToken")
        Dim validatedSecurityToken = Nothing

        If token Is Nothing Then
            token = BuildToken(key, Issuer, Audience, TimeOutInMinute)
            Session("NHSSpineServiceToken") = token
        Else
            Dim tokenValidationParameter = New TokenValidationParameters() With {
            .ValidateLifetime = True,
            .ValidateAudience = True,
            .ValidateIssuer = True,
            .ValidAudience = Audience,
            .ValidIssuer = Issuer,
            .IssuerSigningKey = New SymmetricSecurityKey(Encoding.UTF8.GetBytes(key))
        }

            Try
                Dim jwtSecurityHandler = New JwtSecurityTokenHandler()
                jwtSecurityHandler.ValidateToken(token, tokenValidationParameter, validatedSecurityToken)
            Catch ex As Exception
                token = BuildToken(key, Issuer, Audience, TimeOutInMinute)
                Session("NHSSpineServiceToken") = token
            End Try
        End If

        Return token
    End Function
    Private Function BuildToken(ByVal key As String, ByVal issuer As String, ByVal audience As String, ByVal timeOutInMinute As Integer) As String
        Dim claims = {New System.Security.Claims.Claim(ClaimTypes.NameIdentifier, Guid.NewGuid().ToString())}
        Dim securityKey = New SymmetricSecurityKey(Encoding.UTF8.GetBytes(key))
        Dim credentials = New SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256)
        Dim tokenDescriptor = New JwtSecurityToken(issuer, audience, claims, expires:=DateTime.Now.AddMinutes(timeOutInMinute), signingCredentials:=credentials)
        Return New JwtSecurityTokenHandler().WriteToken(tokenDescriptor)
    End Function


End Class

Public Class SEPatientInfo
    Public Property CaseNoteNo As String
    Public Property NHSNo As String
    Public Property HospitalNumber As String
    Public Property Title As String
    Public Property Forename As String
    Public Property Surname As String
    Public Property PatientName As String
    Public Property DateOfBirth As Date?
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
    Public Property DateOfDeath As Date?

End Class
Public Class NHSSpinePatientInfo
    Public Property UniqueId As Int32
    Public Property Surname As String
    Public Property Forename As String
    Public Property Middlename As String
    Public Property Title As String
    Public Property Gender As String
    Public Property Dob As DateTime?
    Public Property Dod As DateTime?
    Public Property Line1 As String
    Public Property Line2 As String
    Public Property Line3 As String
    Public Property Line4 As String
    Public Property Line5 As String
    Public Property Address As String
    Public Property PostCode As String
    Public Property GPID As String
    Public Property NhsNumber As String
    Public Property HospitalNumber As String
    Public Property PhoneHome As String
    Public Property OldNhsNumber As String
    Public Property patientExistforNewNHSNumber As Boolean
    Public Property patientNotFound As Boolean?
    Public Property Restricted As Boolean
End Class









