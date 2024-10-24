Imports Telerik.Web.UI

Partial Class Products_Gastro_Notes
    Inherits SiteDetailsBase

    Private Shared siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim procName As String = ""
        siteId = CInt(Request.QueryString("SiteId"))

        Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
            Case 1
                procName = " gastroscopy"
            Case 2
                procName = " ERCP"
            Case 3
                procName = " colon"
            Case 4
                procName = " sigmoidoscopy"
            Case 5
                procName = " proctoscopy"
        End Select

        hintLabel.Text = "These notes will appear on the" & procName & " report along with the descriptions and specimens for this site. However, this will not be classed as a diagnoses"

        If Not Page.IsPostBack Then
            Dim dtMa As DataTable = NotesDataAdapter.GetAdditionalNotesData(siteId)
            If dtMa.Rows.Count > 0 Then
                PopulateData(dtMa.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drPs As DataRow)
        NotesTextBox.Text = HttpUtility.HtmlDecode(CStr(drPs("AdditionalNotes")))
    End Sub

    'Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
    '    SaveRecord(True)
    'End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Dim notes As String = ""

        Try
            notes = NotesTextBox.Text.Trim

            NotesDataAdapter.SaveAdditionalNotesData(
                siteId,
                notes)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving notes.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    'Protected Sub EraseButton_Click(sender As Object, e As EventArgs) Handles EraseButton.Click
    '    SaveRecord(True)
    'End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub SaveRecordByClick(saveAndClose As Boolean, Notes As String)
        Dim note As Notes = New Notes
        note.SaveAdditionalNotesData(
                siteId,
                Notes)
    End Sub

End Class
