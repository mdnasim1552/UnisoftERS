Imports Telerik.Web.UI

Public Class NedExportConfig
    Inherits OptionsBase

    Dim nedConfig As NedConfig

    Protected Sub Page_PreInit() Handles Me.PreInit
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "PreInit_CloseLoadingPanel", "if (window.parent.HideLoadingPanel) { window.parent.HideLoadingPanel();}", True)
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadNED_ConfigValues()
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        nedConfig = New NedConfig()
        Try
            With nedConfig
                .APIKey = APIKeyTextBox.Text
                .BatchId = BatchIdTextBox.Text
                '.ExportPath = ExportPathTextBox.Text
                '.HospitalSiteCode = ODS_CodeTextBox.Text
                .OrganisationCode = OrganisationCodeTextBox.Text

                .SaveSettings(nedConfig)
            End With

            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error at ~/Products/Options/NedExportConfig.aspx.vb=>Protected Sub SaveButton_Click() - Admin Utilities.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        Response.Redirect(Request.Url.AbsoluteUri, False)
    End Sub

    Private Sub LoadNED_ConfigValues()        
        nedConfig = NedClass.GetConfigSettings()

        With nedConfig
            APIKeyTextBox.Text = .APIKey
            BatchIdTextBox.Text = .BatchId
            'ExportPathTextBox.Text = .ExportPath
            'ODS_CodeTextBox.Text = .HospitalSiteCode
            OrganisationCodeTextBox.Text = .OrganisationCode
        End With

    End Sub
End Class