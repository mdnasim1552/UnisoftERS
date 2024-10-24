Imports System.IO
Imports Telerik.Web.UI

Partial Class Products_Common_PhotoMove
    Inherits PageBase

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            Me.Title = "Move Attached media"
            headerLabel.Text = "Move attached media to "

            LoadSites()
        End If
    End Sub

    Private Sub LoadSites()
        Dim dtSites As DataTable = DataAdapter.GetSitesWithDescription(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        Dim dtPhoto As DataTable = DataAdapter.GetPhoto(CInt(Request.QueryString("PhotoId")))



        If Not dtPhoto.Rows(0).IsNull("SiteId") Then
            Dim siteId As Integer = dtPhoto.Rows(0)("SiteId")
            For Each dr As DataRow In dtSites.Rows
                If CInt(dr("SiteId")) = siteId Then
                    dtSites.Rows.Remove(dr)
                    Exit For
                End If
            Next
        Else
            'if media is already attached to the procedure then disable or hide the radio button-- site ID will be null if it is
            ProcedureRadioButton.Visible = False
        End If

        With SiteComboBox
            .Items.Clear()
            .DataSource = dtSites
            .DataTextField = "SiteDescription"
            .DataValueField = "SiteId"
            .DataBind()

        End With

        If dtSites Is Nothing OrElse dtSites.Rows.Count = 0 Then
            With SiteComboBox
                .Items.Clear()
                .Items.Add(New RadComboBoxItem("No sites to attach to", 0))
            End With
        End If

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            'validation.....
            If CInt(SiteComboBox.SelectedValue) > 0 Or ProcedureRadioButton.Checked = True Then
                Dim siteId As Integer = If(Integer.TryParse(Request.QueryString("SiteId"), siteId), siteId, 0)
                DataAdapter.MovePhoto(CInt(Request.QueryString("PhotoId")), CInt(SiteComboBox.SelectedValue), siteId, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

                Dim dtPhotos As DataTable = DataAdapter.GetSitePhotos(siteId, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                If dtPhotos.Rows.Count > 0 Then
                    Utilities.SetNotificationStyle(RadNotification1, "Media moved successfully.")
                    RadNotification1.Show()
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "CloseMe", "CloseWindow();", True)
                Else
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "CloseMe", "CloseWindow();", True)
                    ScriptManager.RegisterStartupScript(Me, Me.GetType(), "runFunction", "triggerAttachMediaPage();", True)
                End If
            Else
                Utilities.SetNotificationStyle(RadNotification1, "Please choose where to attach media to")
                RadNotification1.Show()

            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while moving attached media.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
