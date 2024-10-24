
Public Class EditByHistory
    Inherits System.Web.UI.Page

    ReadOnly Property procedureId As Integer
        Get
            Return CInt(Request.QueryString("procedureId"))
        End Get
    End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            EditHistoryDataBind()
        End If
    End Sub

    Protected Sub EditHistoryDataBind()
        Try
            Dim ds As New DataAccess
            EditHistoryListRadGrid.DataSource = ds.getEditHistoryList(procedureId)
            EditHistoryListRadGrid.DataBind()
        Catch ex As Exception
            Dim errorRef = LogManager.LogManagerInstance.LogError("An error occured loading booking cancellations", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorRef, "An error occured loading booking cancellations")
            RadNotification1.Show()
        End Try
    End Sub

End Class