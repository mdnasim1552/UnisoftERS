Imports System.Data.SqlClient
Imports System.Net.Configuration
Imports System.Net.Mail
Imports System.Web.Mail
Imports Telerik.Web.UI

Public Class Products_Options_EmailSettings
    Inherits OptionsBase
    
    Public class SMTPInfo

        Dim _smtpHost as String
        Dim _smtpPort As Integer
        Dim _smtpEnableSSL As Boolean
        Dim _smtpFromAddress As String
        Dim _smtpFromName As String
        Dim _smtpFromPassword As String
        Dim _smtpDefaultCredentials As Boolean
        Dim _emailSentToGpAndConsultantFlagMessage as String

        Public Property SMTP_Host As String
            Get
                Return _smtpHost
            End Get
            Set(ByVal Value As String)
                _smtpHost = Value
            End Set
        End Property

        Public Property SMTP_Port As String
            Get
                Return _smtpPort
            End Get
            Set(ByVal Value As String)
                _smtpPort = Value
            End Set
        End Property

        Public Property SMTP_EnableSSL As String
            Get
                Return _smtpEnableSSL
            End Get
            Set(ByVal Value As String)
                _smtpEnableSSL = Value
            End Set
        End Property

        Public Property SMTP_FromAddress As String
            Get
                Return _smtpFromAddress
            End Get
            Set(ByVal Value As String)
                _smtpFromAddress = Value
            End Set
        End Property
        
        Public Property SMTP_FromName As String
            Get
                Return _smtpFromName
            End Get
            Set(ByVal Value As String)
                _smtpFromName = Value
            End Set
        End Property

        Public Property SMTP_FromPassword As String
            Get
                Return _smtpFromPassword
            End Get
            Set(ByVal Value As String)
                _smtpFromPassword = Value
            End Set
        End Property

        Public Property SMTP_DefaultCredentials As String
            Get
                Return _smtpDefaultCredentials
            End Get
            Set(ByVal Value As String)
                _smtpDefaultCredentials = Value
            End Set
        End Property

    End Class
              
    Private Sub Products_Options_EmailSettings_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            If Request.QueryString.Count > 0 Then
                If Request.QueryString("MainMenu") = "1" Then
                    'CloseButton.Visible = False
                    'CancelButton.Visible = True
                End If
            End If
            
            PopulateControls()
        End If
    End Sub

    Protected Overrides Sub RedirectToLoginPage()
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "sessionexpired",
                                            "window.parent.location='" + ResolveUrl("~/Security/Logout.aspx") + "'; ",
                                            True)
    End Sub
    
    Private Sub PopulateControls()
        Dim dtSettings As DataTable = DataAccess.GetEmailSettings()
        Dim drSettings As DataRow = dtSettings.Rows(0)

        If Not IsNothing(dtSettings) Then
            If dtSettings.Rows.Count > 0 Then
                If Not IsDBNull(drSettings("DeliveryMethod")) Then
                    EmailSettingsDeliveryMethodTextBox.Text = drSettings("DeliveryMethod").ToString()
                End If

                If Not IsDBNull(drSettings("UseDefaultCredentials")) Then
                    EmailSettingsUseDefaultCredentialsCheckBox.Checked =
                        CBool(drSettings("UseDefaultCredentials").ToString())
                End If

                If Not IsDBNull(drSettings("PortNo")) Then
                    EmailSettingsPortNoTextBox.Text = drSettings("PortNo").ToString()
                End If

                If Not IsDBNull(drSettings("EnableSsl")) Then
                    EmailSettingsEnableSslCheckBox.Checked = CBool(drSettings("EnableSsl").ToString())
                End If
                
                If Not IsDBNull(drSettings("Host")) Then
                    EmailSettingsHostTextBox.Text = drSettings("Host").ToString()
                End If

                If Not IsDBNull(drSettings("FromAddress")) Then
                    EmailSettingsFromAddress.Text = drSettings("FromAddress").ToString()
                End If

                If Not IsDBNull(drSettings("FromName")) Then
                    EmailSettingsFromName.Text = drSettings("FromName").ToString()
                End If

                If Not IsDBNull(drSettings("FromPassword")) Then
                    EmailSettingsFromPassword.Text = drSettings("FromPassword").ToString()
                End If
            End If
        End If
    End Sub
    
    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        Response.Redirect(Request.Url.AbsoluteUri, False)
    End Sub
    
    Public Sub SaveEmailSettings_Click(sender As Object, e As System.EventArgs) Handles EmailSettingsSaveButton.Click

        Dim deliveryMethod As String = EmailSettingsDeliveryMethodTextBox.Text.ToString()
        Dim useDefaultCredentials As Boolean = EmailSettingsUseDefaultCredentialsCheckBox.Checked
        Dim portNo As String = EmailSettingsPortNoTextBox.Text.ToString()
        Dim enableSsl As Boolean = EmailSettingsEnableSslCheckBox.Checked
        Dim host As String = EmailSettingsHostTextBox.Text.ToString()
        Dim fromAddress As String = EmailSettingsFromAddress.Text.ToString()
        Dim fromName As String = EmailSettingsFromName.Text.ToString()
        Dim fromPassword As String = EmailSettingsFromPassword.Text.ToString()

        DataAccess.SetEmailSettings(deliveryMethod, useDefaultCredentials, portNo, enableSsl, host, fromAddress, fromName, fromPassword)

    End Sub
    
    ''Test Email Method
    'Public Sub SendEmailTest(sender As Object, e As System.EventArgs)

    '    Dim smtpSection As SmtpSection = new SmtpSection()
    '    'Dim networkCred As NetworkCredential = New NetworkCredential(smtpSection.Network.UserName,
    '    '                                                             smtpSection.Network.Password)

    '    Dim client As SmtpClient = New SmtpClient()

    '    Using client
    '        With client
    '            .DeliveryMethod = smtpSection.DeliveryMethod
    '            .UseDefaultCredentials = smtpSection.Network.DefaultCredentials
    '            .Port = smtpSection.Network.Port
    '            .EnableSsl = smtpSection.Network.EnableSsl
    '        End With

    '        Dim message As new Net.Mail.MailMessage()
    '        With message
    '            .From = New MailAddress(SendFromTextBox.Text.ToString())
    '            .Subject = SendSubjectTextBox.Text.ToString()
    '            .IsBodyHtml = True
    '            .Body = SendMessageTextBox.Text.ToString()
    '            .BodyEncoding = System.Text.Encoding.UTF8
    '        End With

    '        Dim toAddresses = SendToTextBox.Text.Split(", ")
    '        For Each toAddress As String In toAddresses
    '            message.To.Add(toAddress.Trim())
    '        Next

    '        Try
    '            client.Send(message)
    '        Catch ex As Exception
    '            Debug.WriteLine(ex.Message)
    '        End Try
    '    End Using
    'End Sub

End Class
