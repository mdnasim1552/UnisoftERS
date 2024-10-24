Imports Telerik.Web.UI

Partial Class Products_Options_License
    Inherits OptionsBase
    Dim _license As New License(ConfigurationManager.AppSettings("Unisoft.LicenseKey"))

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            loadLicenseText()
        End If
    End Sub

    
    Private Sub loadLicenseText()
        startLabel.Text = _license.StartDate
        ExpireLabel.Text = _license.ExpiryDate
        ProductLabel.Text = String.Join(", ", _license.RegisteredProduct)
        VersionLabel.Text = _license.ProductVersion
        HospitalsLabel.Text = _license.RegisteredHospital
    End Sub

    Protected Sub applybutton1_Click(sender As Object, e As EventArgs)
        applyLicense(licenseRadTextBox.Text)
    End Sub

    'Protected Sub RadAsyncUpload1_FileUploaded(sender As Object, e As FileUploadedEventArgs)
    '    Dim bytes As Byte() = New Byte(e.File.ContentLength - 1) {}
    '    e.File.InputStream.Read(bytes, 0, e.File.ContentLength)
    '    Dim licenseStr As String = System.Text.Encoding.UTF8.GetString(bytes)
    '    applyLicense(licenseStr)
    'End Sub

    Sub applyLicense(licenseKey)
        Try
            If licenseKey <> "" Then
                Dim testLicense As New License(licenseKey)
                If Not String.IsNullOrEmpty(testLicense.ExpiryDate) Then
                    Dim myConfiguration As System.Configuration.Configuration = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("~")
                    myConfiguration.AppSettings.Settings("Unisoft.LicenseKey").Value = licenseKey
                    myConfiguration.Save()
                    loadLicenseText()
                    Utilities.SetNotificationStyle(RadNotification1)
                    RadNotification1.Show()
                Else
                    Utilities.SetErrorNotificationStyle(RadNotification1, "Invalid license key", "There is a problem saving data.")
                    RadNotification1.Show()
                End If
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while applying your license key.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
