Public Class CystosocpySpecimensTaken
    Inherits SiteDetailsBase
    Public siteId As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        If Not IsPostBack Then
            CystoscopySpecimensFormView.DefaultMode = FormViewMode.Edit
            CystoscopySpecimensFormView.ChangeMode(FormViewMode.Edit)
        End If
    End Sub
    Protected Sub CystoscopySpecimensObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles CystoscopySpecimensObjectDataSource.Selecting
        e.InputParameters("siteId") = siteId
    End Sub
    Protected Sub CystoscopySpecimensObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopySpecimensObjectDataSource.Updating
        SetParams(e)
    End Sub
    Private Sub SetParams(e As ObjectDataSourceMethodEventArgs)
        e.InputParameters("siteId") = siteId
    End Sub

    Protected Sub CystoscopySpecimensObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopySpecimensObjectDataSource.Inserting
        SetParams(e)
    End Sub
    Protected Sub CystoscopySpecimensFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles CystoscopySpecimensFormView.ItemInserted
        CystoscopySpecimensFormView.DefaultMode = FormViewMode.Edit
        CystoscopySpecimensFormView.ChangeMode(FormViewMode.Edit)
        CystoscopySpecimensFormView.DataBind()
        ' ShowMsg()
    End Sub
    Protected Sub CystoscopySpecimensFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles CystoscopySpecimensFormView.ItemUpdated
        'ShowMsg()
    End Sub
    Protected Sub CystoscopySpecimensFormView_DataBound(sender As Object, e As EventArgs) Handles CystoscopySpecimensFormView.DataBound
        Dim row As DataRowView = DirectCast(CystoscopySpecimensFormView.DataItem, DataRowView)
        If row IsNot Nothing Then
        Else
            CystoscopySpecimensFormView.DefaultMode = FormViewMode.Insert
            CystoscopySpecimensFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub

    Protected Sub SaveButton_Click(Sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecords(True)
    End Sub

    Private Sub SaveRecords(saveAndClose As Boolean)
        If CystoscopySpecimensFormView.CurrentMode = FormViewMode.Edit Then
            CystoscopySpecimensFormView.UpdateItem(True)
        End If
        If CystoscopySpecimensFormView.CurrentMode = FormViewMode.Insert Then
            CystoscopySpecimensFormView.InsertItem(True)
        End If

        If saveAndClose Then
            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
        End If
    End Sub

End Class