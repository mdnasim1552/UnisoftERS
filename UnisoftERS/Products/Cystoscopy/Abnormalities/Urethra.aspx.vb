Public Class Urethra
    Inherits SiteDetailsBase
    Public Shared siteId As Integer
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))


        If Not IsPostBack Then
            CystoscopyUrethraFormView.DefaultMode = FormViewMode.Edit
            CystoscopyUrethraFormView.ChangeMode(FormViewMode.Edit)
            RegionHidden.Value = Request.QueryString("Reg")

        End If
    End Sub

    Protected Sub CystoscopyUrethraObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles CystoscopyUrethraObjectDataSource.Selecting
        e.InputParameters("siteId") = siteId
    End Sub
    Protected Sub CystoscopyUrethraObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopyUrethraObjectDataSource.Updating
        SetParams(e)
    End Sub
    Private Sub SetParams(e As ObjectDataSourceMethodEventArgs)
        e.InputParameters("siteId") = siteId
    End Sub

    Protected Sub CystoscopyUrethraObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopyUrethraObjectDataSource.Inserting
        SetParams(e)
    End Sub
    Protected Sub CystoscopyUrethraFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles CystoscopyUrethraFormView.ItemInserted
        CystoscopyUrethraFormView.DefaultMode = FormViewMode.Edit
        CystoscopyUrethraFormView.ChangeMode(FormViewMode.Edit)
        CystoscopyUrethraFormView.DataBind()
        ' ShowMsg()
    End Sub
    Protected Sub CystoscopyUrethraFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles CystoscopyUrethraFormView.ItemUpdated
        'ShowMsg()
    End Sub
    Protected Sub CystoscopyUrethraFormView_DataBound(sender As Object, e As EventArgs) Handles CystoscopyUrethraFormView.DataBound
        Dim row As DataRowView = DirectCast(CystoscopyUrethraFormView.DataItem, DataRowView)
        If row IsNot Nothing Then
        Else
            CystoscopyUrethraFormView.DefaultMode = FormViewMode.Insert
            CystoscopyUrethraFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub

    Protected Sub SaveButton_Click(Sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecords(True)
    End Sub

    Private Sub SaveRecords(saveAndClose As Boolean)
        If CystoscopyUrethraFormView.CurrentMode = FormViewMode.Edit Then
            CystoscopyUrethraFormView.UpdateItem(True)
        End If
        If CystoscopyUrethraFormView.CurrentMode = FormViewMode.Insert Then
            CystoscopyUrethraFormView.InsertItem(True)
        End If

        If saveAndClose Then
            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
        End If

    End Sub

End Class