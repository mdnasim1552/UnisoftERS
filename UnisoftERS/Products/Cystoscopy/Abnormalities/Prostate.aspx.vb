Public Class Prostate
    Inherits SiteDetailsBase
    Public Shared siteId As Integer
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))


        If Not IsPostBack Then
            CystoscopyProstateFormView.DefaultMode = FormViewMode.Edit
            CystoscopyProstateFormView.ChangeMode(FormViewMode.Edit)
            RegionHidden.Value = Request.QueryString("Reg")

        End If
    End Sub

    Protected Sub CystoscopyProstateObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles CystoscopyProstateObjectDataSource.Selecting
        e.InputParameters("siteId") = siteId
    End Sub
    Protected Sub CystoscopyProstateObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopyProstateObjectDataSource.Updating
        SetParams(e)
    End Sub
    Private Sub SetParams(e As ObjectDataSourceMethodEventArgs)
        e.InputParameters("siteId") = siteId
    End Sub

    Protected Sub CystoscopyProstateObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopyProstateObjectDataSource.Inserting
        SetParams(e)
    End Sub
    Protected Sub CystoscopyProstateFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles CystoscopyProstateFormView.ItemInserted
        CystoscopyProstateFormView.DefaultMode = FormViewMode.Edit
        CystoscopyProstateFormView.ChangeMode(FormViewMode.Edit)
        CystoscopyProstateFormView.DataBind()
        ' ShowMsg()
    End Sub
    Protected Sub CystoscopyProstateFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles CystoscopyProstateFormView.ItemUpdated
        'ShowMsg()
    End Sub
    Protected Sub CystoscopyProstateFormView_DataBound(sender As Object, e As EventArgs) Handles CystoscopyProstateFormView.DataBound
        Dim row As DataRowView = DirectCast(CystoscopyProstateFormView.DataItem, DataRowView)
        If row IsNot Nothing Then
        Else
            CystoscopyProstateFormView.DefaultMode = FormViewMode.Insert
            CystoscopyProstateFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub

    Protected Sub SaveButton_Click(Sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecords(True)
    End Sub

    Private Sub SaveRecords(saveAndClose As Boolean)
        If CystoscopyProstateFormView.CurrentMode = FormViewMode.Edit Then
            CystoscopyProstateFormView.UpdateItem(True)
        End If
        If CystoscopyProstateFormView.CurrentMode = FormViewMode.Insert Then
            CystoscopyProstateFormView.InsertItem(True)
        End If

        If saveAndClose Then
            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
        End If

    End Sub

End Class