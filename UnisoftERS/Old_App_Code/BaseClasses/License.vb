Public Class License
    Private _IsSystemDisabled As Boolean = False
    Private _IsERSViewer As Boolean = True
    Private _IsDemoVersion As Boolean = True
    Private _ExpiryDate As String
    Private _StartDate As String
    Private _RegisteredProduct As List(Of String)
    Private _ProductVersion As String
    Private _RegisteredHospital As String
    Private plainText As String
    Private _Duration As String
    Private _Period As String
    Private _RegisteredProductText As String
    Private _HospitalID As String
    Public ReadOnly Property IsSystemDisabled As Boolean
        Get
            Return _IsSystemDisabled
        End Get
    End Property
    Public Property IsERSViewer As Boolean
        Get
            Return _IsERSViewer
        End Get
        Set(value As Boolean)
            _IsERSViewer = value
        End Set
    End Property
    Public Property IsDemoVersion As Boolean
        Get
            Return _IsDemoVersion
        End Get
        Set(value As Boolean)
            _IsDemoVersion = value
        End Set
    End Property
    Public ReadOnly Property ExpiryDate As String
        Get
            Return _ExpiryDate
        End Get
    End Property
    Public ReadOnly Property StartDate As String
        Get
            Return _StartDate
        End Get
    End Property
    Public ReadOnly Property RegisteredProduct As List(Of String)
        Get
            Return _RegisteredProduct
        End Get
    End Property
    Public ReadOnly Property RegisteredProductText As String
        Get
            Return _RegisteredProductText
        End Get
    End Property
    Public ReadOnly Property ProductVersion As String
        Get
            Return _ProductVersion
        End Get
    End Property
    Public ReadOnly Property RegisteredHospital As String
        Get
            Return _RegisteredHospital
        End Get
    End Property
    Public ReadOnly Property KeyText As String
        Get
            Return plainText
        End Get
    End Property
    Public ReadOnly Property Duration As String
        Get
            Return _Duration
        End Get
    End Property
    Public ReadOnly Property Period As String
        Get
            Return _Period
        End Get
    End Property
    Public ReadOnly Property HospitalID As String
        Get
            Return _HospitalID
        End Get
    End Property
    Sub New(ByVal licensekey As String)
        Dim Salt As String = getSalt(licensekey)
        Dim EncryptedCode As String = getEncode(licensekey)
        Dim en As New ERS.Security.Simple3Des(Salt)
        plainText = en.DecryptData(EncryptedCode)

        _ExpiryDate = getExpiryDate()
        _StartDate = getStartDate()
        _RegisteredProduct = getRegisteredProduct()
        _ProductVersion = getProductVersion()
        _RegisteredHospital = getRegisteredHospital()
        _Duration = getDuration()
        _Period = getPeriod()
        _HospitalID = getHospitalID()
        _IsSystemDisabled = getIsSystemDisabled()
    End Sub
    Private Function getHospitalID() As String
        Return plainText.Split("~")(4)
    End Function
    Private Function getIsSystemDisabled() As Boolean
        Dim Res As Boolean = False
        'Dim expDate As DateTime = CDate(plainText.Split("~")(0).Split("|")(1))
        Dim expDate As DateTime = Date.ParseExact(plainText.Split("~")(0).Split("|")(1), "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo)
        If expDate < Date.Today Then
            _IsDemoVersion = True
            Res = True
        Else
            Res = False
        End If
        Return Res
    End Function
    Private Function getExpiryDate() As String
        Return plainText.Split("~")(0).Split("|")(1)
    End Function
    Private Function getStartDate() As String
        Return plainText.Split("~")(0).Split("|")(0)
    End Function
    Private Function getRegisteredProduct() As List(Of String)
        Dim pList As New List(Of String)
        Dim pd As String = Trim(plainText.Split("~")(2))
        _RegisteredProductText = pd
        If pd.Chars(0) = "1" Then pList.Add("Auditor's Kit")
        If pd.Chars(1) = "1" Then pList.Add("Bronchoscopy Reporting Tool")
        If pd.Chars(2) = "1" Then pList.Add("BRT")
        If pd.Chars(3) = "1" Then pList.Add("Cystoscopy Reporting Tool")
        If pd.Chars(4) = "1" Then pList.Add("DICOM")
        If pd.Chars(5) = "1" Then pList.Add("DigIMaK")
        If pd.Chars(6) = "1" Then pList.Add("EBUS")
        If pd.Chars(7) = "1" Then pList.Add("Enteroscopy")

        Dim iERS As Integer = Convert.ToInt32(pd.Chars(8).ToString)
        Dim iERSViewer As Integer = Convert.ToInt32(pd.Chars(9).ToString)

        ''''Max licence for ERS or ERSViewer is 9
        IF iERS > 0 Then
            If iERS = 1 Then
                pList.Add("ERS")
            Else
                pList.Add("ERS" & " (" & iERS & ")")
            End If
            IsERSViewer = False
        End If

        IF iERSViewer > 0 Then
            If iERSViewer = 1 Then
                pList.Add("ERS Viewer")
            Else
                pList.Add("ERS Viewer" & " (" & iERSViewer & ")")
            End If
            IsERSViewer = True
        End If
        'If pd.Chars(8) = "1" Then
        '    pList.Add("ERS")
        '    IsERSViewer = False
        'End If
        'If pd.Chars(9) = "1" Then
        '    pList.Add("ERS Viewer")
        '    IsERSViewer = True
        'End If
        If pd.Chars(10) = "1" Then pList.Add("LCMS")
        If pd.Chars(11) = "1" Then pList.Add("Lucada module")
        If pd.Chars(12) = "1" Then pList.Add("Open Export")
        If pd.Chars(13) = "1" Then pList.Add("PAS Interface (CSV-Text)")
        If pd.Chars(14) = "1" Then pList.Add("PAS Interface (HL7 - Bi-Directional + Scheduler)")
        If pd.Chars(15) = "1" Then pList.Add("PAS Interface (HL7 standard)")
        If pd.Chars(16) = "1" Then pList.Add("PAS Interface (SOAP)")
        If pd.Chars(17) = "1" Then pList.Add("Report Browser")
        If pd.Chars(18) = "1" Then pList.Add("Scheduler")
        If pd.Chars(19) = "1" Then pList.Add("Thoracoscopy")
        Return pList
    End Function
    Private Function getProductVersion() As String
        Dim v As String = plainText.Split("~")(1)
        If v.Chars(0) = "1" Then
            _IsDemoVersion = True
            Return "Demo Version"
        ElseIf v.Chars(1) = "1" Then
            _IsDemoVersion = False
            Return "Full version"
        Else
            Return Nothing
        End If
    End Function
    Private Function getRegisteredHospital() As String
        Return plainText.Split("~")(3)
    End Function
    Private Function getDuration() As String
        Return plainText.Split("~")(5).Split("|")(0)
    End Function
    Private Function getPeriod() As String
        Return plainText.Split("~")(5).Split("|")(1)
    End Function
    Private Function getSalt(lic As String) As String
        Return lic.Substring(23, 4) & lic.Substring(57, 2) & lic.Substring(88, 6)
    End Function
    Private Function getEncode(lic As String) As String
        Return lic.Remove(88, 6).Remove(57, 2).Remove(23, 4)
    End Function
End Class

