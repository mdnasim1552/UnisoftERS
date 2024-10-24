Imports Telerik.Web.UI

Public Class TrustDetails
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Protected Sub TrustsRadGrid_ItemDataBound(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles TrustsRadGrid.ItemDataBound
        ' Hide Add New Trust Button if not GlobalAdmin
        Dim AddNewTrustButton = e.Item.FindControl("AddNewTrustButton")
        If Not IsNothing(AddNewTrustButton) Then
            Dim da = New DataAccess()
            AddNewTrustButton.Visible = da.IsGlobalAdmin(Session("PKUserId"))
        End If

        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return addTrust('{0}');", e.Item.ItemIndex)
            End If
        Catch ex As Exception
            Dim errorMsg = "Error in TrustRadGrid_ItemDataBound"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        TrustsRadGrid.Rebind()
    End Sub

End Class