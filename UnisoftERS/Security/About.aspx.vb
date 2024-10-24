Imports Telerik.Web.UI
Imports System.Net.Mail

Partial Class Security_About
    Inherits PageBase
    Protected Sub SaveButton_Click(sender As Object, e As EventArgs)
        'Try
        '    Dim attach As Attachment = Nothing
        '    Dim sMessage As String = ""
        '    If AttachemnetAsyncUpload.UploadedFiles.Count > 0 Then
        '        Dim file As UploadedFile = AttachemnetAsyncUpload.UploadedFiles(0)
        '        attach = New Attachment(file.InputStream, file.FileName)
        '    End If
        '    DataAdapter.InsertFeedback(NameTextBox.Text, EmailAddressTextBox.Text, HttpUtility.HtmlEncode(FeedbackTextBox.Text))
        '    If CBool(ConfigurationManager.AppSettings("Unisoft.FeedbackSendEmail")) Then
        '        Dim eSender As New Email

        '        sMessage = Trim(NameTextBox.Text)
        '        If Trim(sMessage) <> "" Then
        '            sMessage = "Name : " & sMessage & "<br />" & "Email address : " & Trim(EmailAddressTextBox.Text) & "<br /><hr><br />"
        '        Else
        '            sMessage = "Email address : " & Trim(EmailAddressTextBox.Text) & "<br /><hr><br />"
        '        End If
        '        sMessage = sMessage & HttpUtility.HtmlEncode(Trim(FeedbackTextBox.Text)).Replace(System.Environment.NewLine, "<br />")
        '        sMessage = "<html><head><title></title></head><body><span style = 'font-family:Arial, Helvetica, sans-serif;font-size:10pt'>" & _
        '                            sMessage & "</span></body><html>"
        '        eSender.sendEmail(sMessage, attach)
        '    End If
        '    ClearBoxes()
        '    'Utilities.SetNotificationStyle(RadNotification1)
        '    'RadNotification1.Show()
        'Catch ex As Exception
        '    Dim errorLogRef As String
        '    errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while sending feedback.", ex)
        '    Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
        '    RadNotification1.Show()
        'End Try
    End Sub

    Private Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        Dim sColor As String = "color: #4888a2;width:250px;word-wrap:break-word;"
        Dim s1stTD As String = "width:100px;" '"style='padding-top:10px;'"
        Dim sSiteName As String = System.Web.Hosting.HostingEnvironment.ApplicationHost.GetSiteName()
        Dim da As New DataAccess
        Dim DbInfo As DataRow = da.GetDBInfo()

        If CBool(Session("isERSViewer")) Then
            lblWelcomeMessage.Text = "Solus Endoscopy | Viewer"
        Else
            lblWelcomeMessage.Text = "Solus Endoscopy"
        End If
        Me.Title = "About " & lblWelcomeMessage.Text
        Dim versionObj As New Version(Session(Constants.SESSION_APPVERSION))

        lblWelcomeMessage.Text += "<span style='font-size:small;'><br />Version " & versionObj.Major & "." & versionObj.Minor & "." & versionObj.Build & "</span>"
        lblLicensed.Text = "This product is licenced to: <b>" & ConfigurationManager.AppSettings("Unisoft.Hospital") & "</b>"
        lblSupportHotline.Text = "HD Clinical hotline on " &  ConfigurationManager.AppSettings("Unisoft.Helpdesk")

        Dim cn As New System.Data.SqlClient.SqlConnectionStringBuilder(DataAccess.ConnectionStr)
        lblWeb.Text = "<table cellspacing='0' cellpadding='5' style='table-layout:fixed;width:380px;'>" &
                                "<tr><td style='" & s1stTD & "padding-left:3px;'> Site name: </td><td style='" & sColor & "'>" & sSiteName & "</td></tr>" &
                                "<tr><td style='" & s1stTD & "padding-left:6px;'> Server name: </td><td style='" & sColor & "'>" & Environment.MachineName & "</td></tr>" &
                                "<tr><td style='" & s1stTD & "padding-left:15px;'> Domain name: </td><td style='" & sColor & "'>" & Environment.UserDomainName.ToString() & "</td></tr>" &
                                "<tr><td style='" & s1stTD & "padding-left:30px;'> Physical path: </td><td style='" & sColor & "'>" & System.Web.Hosting.HostingEnvironment.ApplicationHost.GetPhysicalPath() & "</td></tr>" &
                                "<tr><td style='" & s1stTD & "padding-left:35px;'> Virtual path: </td><td style='" & sColor & "'>" & System.Web.Hosting.HostingEnvironment.ApplicationHost.GetVirtualPath() & "</td></tr>" &
                                "<tr><td style='" & s1stTD & "padding-left:40px;'> OS version: </td><td style='" & sColor & "'>" & Environment.OSVersion.ToString() & "</td></tr>" &
                                "<tr><td style='" & s1stTD & "padding-left:45px;'> Revision: </td><td style='" & sColor & "'>" & versionObj.Revision & "</td></tr>" & 'issue 4426
                                "<tr><td style='" & s1stTD & "padding-left:50px;'> IIS ver.: </td><td style='" & sColor & "'>" & Request.ServerVariables("SERVER_SOFTWARE") & "</td></tr>" &
                                "</table>"

        lblDB.Text = "<table cellspacing='0' cellpadding='5' style='table-layout:fixed;width:350px;'>" &
                        "<tr><td style='" & s1stTD & "padding-left:3px;'> Database name: </td><td style='" & sColor & "'>" & cn.InitialCatalog() & "</td></tr>" &
                        "<tr><td style='" & s1stTD & "padding-left:6px;'> Server name: </td><td style='" & sColor & "'>" & cn.DataSource() & "</td></tr>" &
                        "<tr><td style='" & s1stTD & "padding-left:8px;'> DB Version: </td><td style='" & sColor & "'>" & If(DbInfo IsNot Nothing AndAlso DbInfo("VersionNum") IsNot DBNull.Value, DbInfo("VersionNum").ToString(), String.Empty) & "</td></tr>" &
                        "<tr><td style='" & s1stTD & "padding-left:18px;'> Version Date: </td><td style='" & sColor & "'>" & If(DbInfo IsNot Nothing AndAlso DbInfo("InstallDate") IsNot DBNull.Value, Convert.ToDateTime(DbInfo("InstallDate")).ToString("yyyy-MM-dd HH:mm:ss.fff"), String.Empty) & "</td></tr>" &
                        "</table>"

        '"Database name: <span style='font-size:small;font-weight: bold; " & sColor & "'>" & cn.InitialCatalog() & "</span>" & _
        '"<tr><td " & s1stTD & "> Server IP: </td><td style='" & sColor & "'>" & Request.ServerVariables("LOCAL_ADDR") & "</td></tr>" & _


        ' "<br /> Physical Path: <span style='" & sColor & "'>" & System.Web.Hosting.HostingEnvironment.SiteName() & "</span>" & _

        '"<br /> Site name: <span style='" & sColor & "'>" & System.Web.Hosting.HostingEnvironment.ApplicationHost.GetPhysicalPath() & "</span>"
    End Sub
End Class
