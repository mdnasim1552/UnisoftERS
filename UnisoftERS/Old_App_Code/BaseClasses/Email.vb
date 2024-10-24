Imports System.Net.Mail
Imports System.Web.Configuration

Public Class Email
    Private _Hostname As String
    Private _Port As Integer
    Private _Username As String
    Private _Password As String
    Private _EnableSSL As Boolean
    Private _DeliveryMethod As SmtpDeliveryMethod
    Private _FromEmail As String

    'Public WriteOnly Property Hostname
    '    Set(value)
    '        _Hostname = value
    '    End Set
    'End Property
    'Public WriteOnly Property Port
    '    Set(value)
    '        _Port = value
    '    End Set
    'End Property
    'Public WriteOnly Property Username
    '    Set(value)
    '        _Username = value
    '    End Set
    'End Property
    'Public WriteOnly Property Password
    '    Set(value)
    '        _Password = value
    '    End Set
    'End Property
    'Public WriteOnly Property FromAddress
    '    Set(value)
    '        _FromAddress = value
    '    End Set
    'End Property

    Public Sub New()
        Dim config As System.Configuration.Configuration = WebConfigurationManager.OpenWebConfiguration(HttpContext.Current.Request.ApplicationPath)
        Dim mSettings As System.Net.Configuration.MailSettingsSectionGroup = config.GetSectionGroup("system.net/mailSettings")

        ' Dim mSettings As System.Net.Configuration.MailSettingsSectionGroup

        _Port = mSettings.Smtp.Network.Port
        _Hostname = mSettings.Smtp.Network.Host
        _Password = mSettings.Smtp.Network.Password
        _Username = mSettings.Smtp.Network.UserName
        _EnableSSL = mSettings.Smtp.Network.EnableSsl
        _DeliveryMethod = mSettings.Smtp.DeliveryMethod
        _FromEmail = mSettings.Smtp.From
    End Sub

    Public Sub sendEmail(MessageText As String, attach As Attachment)
        Dim ToAddress As String = ConfigurationManager.AppSettings("Unisoft.FeedbackEmailTo")
        Dim Subject As String = ConfigurationManager.AppSettings("Unisoft.FeedbackSubject")
        Dim SmtpServer As New SmtpClient()
        Dim mail As New MailMessage()
        If String.IsNullOrEmpty(_Username) AndAlso String.IsNullOrEmpty(_Password) Then
            SmtpServer.UseDefaultCredentials = True
        Else
            SmtpServer.Credentials = New Net.NetworkCredential(_Username, _Password)
        End If

        SmtpServer.Port = _Port
        SmtpServer.Host = _Hostname
        SmtpServer.EnableSsl = _EnableSSL
        mail = New MailMessage()
        mail.From = New MailAddress(_FromEmail)
        mail.IsBodyHtml = True
        mail.To.Add(ToAddress)
        mail.Subject = Subject
        mail.Body = MessageText
        If Not IsNothing(attach) Then
            mail.Attachments.Add(attach)
        End If
        SmtpServer.DeliveryMethod = _DeliveryMethod
        SmtpServer.Send(mail)
        mail.Attachments.Dispose()
    End Sub

     Public Sub sendNEDErrorEmail(MessageText As String, attach As Attachment, sEmailSubject As String)
        Dim ToAddress As String = ConfigurationManager.AppSettings("NEDValidation.MailToAddress")
        Dim CCAddress As String = ConfigurationManager.AppSettings("NEDValidation.MailCcAddress")
         
    

        Dim SmtpServer As New SmtpClient()
        Dim mail As New MailMessage()
        If String.IsNullOrEmpty(_Username) AndAlso String.IsNullOrEmpty(_Password) Then
            SmtpServer.UseDefaultCredentials = True
        Else
            SmtpServer.Credentials = New Net.NetworkCredential(_Username, _Password)
        End If

        SmtpServer.Port = _Port
        SmtpServer.Host = _Hostname
        SmtpServer.EnableSsl = _EnableSSL
        mail = New MailMessage()
        mail.From = New MailAddress(_FromEmail)
        mail.IsBodyHtml = True
        mail.To.Add(ToAddress)
        If Trim(CCAddress) <> "" Then
            mail.CC.Add(CCAddress)
        End If
        mail.Subject = sEmailSubject
        mail.Body = MessageText
        If Not IsNothing(attach) Then
            mail.Attachments.Add(attach)
        End If
        SmtpServer.DeliveryMethod = _DeliveryMethod
        SmtpServer.Send(mail)
        mail.Attachments.Dispose()
    End Sub
End Class
