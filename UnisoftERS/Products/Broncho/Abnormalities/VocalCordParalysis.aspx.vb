Imports Telerik.Web.UI
Public Class VocalCordParalysis
    Inherits SiteDetailsBase

    Private siteId As Integer
    Private region As String

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        region = Request.QueryString("Reg")

        If Not Page.IsPostBack Then
            Dim dtDf As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_brt_descriptions_select")
            If dtDf.Rows.Count > 0 Then
                PopulateData(dtDf.Rows(0))
            End If
        End If
    End Sub


    Private Sub PopulateData(drSc As DataRow)
        If Not IsDBNull(drSc("Vocal")) AndAlso CInt(drSc("Vocal")) > 0 Then VocalRBL.SelectedValue = CInt(drSc("Vocal"))
    End Sub


    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            'If siteId = -1 Then
            '    siteId = AbnormalitiesDataAdapter.CommitEBUSite(region)
            'End If

            AbnormalitiesDataAdapter.SaveBRTAbnosData(
                siteId,
                NoneCheckBox.Checked,
                Nothing,
                Utilities.GetRadioValue(VocalRBL),
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing,
                Nothing)

            Using db As New ERS.Data.GastroDbEntities

                Dim ersRecord As ERS.Data.ERS_RecordCount
                ersRecord = db.ERS_RecordCount.Where(Function(ers) ers.SiteId = siteId And ers.Identifier = "Vocal Cord Paralysis").FirstOrDefault()

                If ersRecord Is Nothing Then
                    ersRecord = New ERS.Data.ERS_RecordCount

                    ersRecord.ProcedureId = Session(Constants.SESSION_PROCEDURE_ID)
                    ersRecord.SiteId = siteId
                    ersRecord.Identifier = "Vocal Cord Paralysis"
                    ersRecord.RecordCount = 1

                    db.ERS_RecordCount.Add(ersRecord) '### Second INSERT in the TRANSACTION
                End If

                db.SaveChanges()
            End Using

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "refreshParentEBUS(" & siteId & ");", True)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Bronchoscopy/EBUS Abnormalities - Vocal Cord Baralysis.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub
End Class