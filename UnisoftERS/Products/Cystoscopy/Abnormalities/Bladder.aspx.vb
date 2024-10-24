Public Class Bladder
    Inherits SiteDetailsBase
    Public Shared siteId As Integer
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))


        If Not IsPostBack Then
            CystoscopyBladderFormView.DefaultMode = FormViewMode.Edit
            CystoscopyBladderFormView.ChangeMode(FormViewMode.Edit)
            RegionHidden.Value = Request.QueryString("Reg")

        End If
    End Sub

    Protected Sub CystoscopyBladderObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles CystoscopyBladderObjectDataSource.Selecting
        e.InputParameters("siteId") = siteId
    End Sub
    Protected Sub CystoscopyBladderObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopyBladderObjectDataSource.Updating
        SetParams(e)
    End Sub
    Private Sub SetParams(e As ObjectDataSourceMethodEventArgs)
        e.InputParameters("siteId") = siteId
    End Sub

    Protected Sub CystoscopyBladderObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopyBladderObjectDataSource.Inserting
        SetParams(e)
    End Sub
    Protected Sub CystoscopyBladderFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles CystoscopyBladderFormView.ItemInserted
        CystoscopyBladderFormView.DefaultMode = FormViewMode.Edit
        CystoscopyBladderFormView.ChangeMode(FormViewMode.Edit)
        CystoscopyBladderFormView.DataBind()
        ' ShowMsg()
    End Sub
    Protected Sub CystoscopyBladderFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles CystoscopyBladderFormView.ItemUpdated
        'ShowMsg()
    End Sub
    Protected Sub CystoscopyBladderFormView_DataBound(sender As Object, e As EventArgs) Handles CystoscopyBladderFormView.DataBound
        Dim row As DataRowView = DirectCast(CystoscopyBladderFormView.DataItem, DataRowView)
        If row IsNot Nothing Then
        Else
            CystoscopyBladderFormView.DefaultMode = FormViewMode.Insert
            CystoscopyBladderFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub

    Protected Sub SaveButton_Click(Sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecords(True)
    End Sub

    Private Sub SaveRecords(saveAndClose As Boolean)
        If CystoscopyBladderFormView.CurrentMode = FormViewMode.Edit Then
            CystoscopyBladderFormView.UpdateItem(True)
        End If
        If CystoscopyBladderFormView.CurrentMode = FormViewMode.Insert Then
            CystoscopyBladderFormView.InsertItem(True)
        End If

        If saveAndClose Then
            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
        End If

    End Sub

End Class