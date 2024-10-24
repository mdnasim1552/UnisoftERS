Imports Telerik.Web.UI

Public Class GPList
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Page.IsPostBack Then Exit Sub

        If Not String.IsNullOrWhiteSpace(Request.QueryString("searchstr")) Then
            'populateResults(Request.QueryString("searchstr"), Request.QueryString("searchval"))
        End If
    End Sub

    Private Sub populateResults(searchTerm As String, searchType As String)
        Try

            Dim da As New DataAccess
            'Dim searchTerm = Request.QueryString("searchstr")
            'Dim searchType = Request.QueryString("searchval")
            GPResultsGrid.DataSource = da.SearchGP(searchTerm, searchType)
            GPResultsGrid.DataBind()
        Catch ex As Exception

        End Try
    End Sub

    Protected Sub GPResultsGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        If e.CommandName = "Select" Then
            Session("GPSelectedValue") = CInt(CType(e.Item, GridDataItem).GetDataKeyValue("GPId"))
            Session("PracticeIDSelectedValue") = CInt(CType(e.Item, GridDataItem).GetDataKeyValue("PracticeId"))
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType, "SaveAndCloseGPSeearch", "window.close();", True)
        End If
    End Sub

    Protected Sub GPRadSearchBox_Search(sender As Object, e As SearchBoxEventArgs)
        Dim searchTerm = GPRadSearchBox.Text
        Dim searchType = "ALL"
        If GPRadSearchBox.SearchContext.SelectedItem IsNot Nothing Then
            searchType = GPRadSearchBox.SearchContext.SelectedItem.Text
        End If
        populateResults(searchTerm, searchType)
    End Sub

    Protected Sub GPResultsGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim da As New DataAccess
        Dim searchTerm = Request.QueryString("searchstr")
        Dim searchType = Request.QueryString("searchval")
        GPResultsGrid.DataSource = da.SearchGP(searchTerm, searchType)

    End Sub
End Class