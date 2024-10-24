Public Class landingpage
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadLandingPage()
        End If
    End Sub

    Public Sub LoadLandingPage()
        If Not IsPostBack Then
            Dim cn As New System.Data.SqlClient.SqlConnectionStringBuilder(DataAccess.ConnectionStr)
            Dim da As New DataAccess

            lblLoggedOn.Text = CStr(Session("LoggedOn"))
            lblVersion.Text = Session(Constants.SESSION_APPVERSION)
            lblHospitalNumber.Text = Session("HospitalID")
            lblDatabaseName.Text = cn.InitialCatalog()

            Dim userDataTable As DataTable = da.GetUser(CInt(Session("PKUserID")))
            If userDataTable IsNot Nothing AndAlso userDataTable.Rows.Count > 0 Then
                lblPermissions.Text = userDataTable.Rows(0)("Permissions").ToString
            Else
                lblPermissions.Text = "READ ONLY"
            End If
        End If
    End Sub

    Public Sub optionERSViewer()
        tableRight.Visible = False
        radTileScheduler.Visible = False
        radTilePASDownload.Visible = False
        radTileReports.Visible = False
    End Sub
    Public Sub optionValidDate(validUntil As DateTime)
        'RadContentTemplateTile1.Style.Add("background-color", "#c20e24") 'red
        'LicencePeekTemplateDiv.Style.Add("background-color", "#c20e24")

        RadContentTemplateTile1.CssClass = "contentRed"
        LicencePeekTemplateDiv.Attributes("class") = "contentRed"
        'LicencePeekTemplateDiv.Attributes.Add("style", "height:120px")
        LicenceLabel.Text = "Your license has expired on " & validUntil.ToString("dd/MM/yyyy") & ". Please contact your service manager."

        RadContentTemplateTile1.PeekTemplateSettings.ShowInterval = 3600000
        RadContentTemplateTile1.PeekTemplateSettings.ShowPeekTemplateOnMouseOver = False
        RadContentTemplateTile1.PeekTemplateSettings.HidePeekTemplateOnMouseOut = False
        RadContentTemplateTile1.Height = 240
        LicenceExpiryLabel.Text = LicenceLabel.Text
        LicenceExpiryDiv.Visible = True
    End Sub
    Public Sub optionValidDateSoon(validUntil As DateTime)
        'RadContentTemplateTile1.Style.Add("background-color", "#FF7F00") 'orange/amber
        'LicencePeekTemplateDiv.Style.Add("background-color", "#FF7F00")
        Dim iDateDiff As Integer = 0
        RadContentTemplateTile1.CssClass = "contentOrange"
        LicencePeekTemplateDiv.Attributes("class") = "contentOrange"
        LicencePeekTemplateDiv.Attributes.Add("style", "height:120px")
        iDateDiff = DateDiff(DateInterval.Day, Date.Today, validUntil)
        If iDateDiff > 0 Then
            LicenceLabel.Text = "Your license is about to expire in " & DateDiff(DateInterval.Day, Date.Today, validUntil) & IIf(iDateDiff = 1, " day", " days") & ". Please contact your service manager."
        Else
            LicenceLabel.Text = "Your license is expiring today. Please contact your service manager."
        End If
    End Sub
    Public Sub optionInvalidDate()
        'RadContentTemplateTile1.Style.Add("background-color", "#5DA437") 'green
        'LicencePeekTemplateDiv.Style.Add("background-color", "#5DA437")
        RadContentTemplateTile1.CssClass = "contentGreen"  ' "contentGreen"
        LicencePeekTemplateDiv.Attributes("class") = "contentGreen" ' "contentGreen"
        LicencePeekTemplateDiv.Attributes.Add("style", "height:120px")
        LicenceLabel.Text = "Over 20 years of market leading endoscopy software from <br /> HD Clinical Ltd"
    End Sub
End Class