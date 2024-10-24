Imports Telerik.Web.UI
Imports System.Web.UI.WebControls

Public Class OtherAbnormalitiesSettings
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Protected Sub OtherAbnoRadGrid_ItemDataBound(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles OtherAbnoRadGrid.ItemDataBound
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return addOtherAbno('{0}');", e.Item.ItemIndex)
            End If
        Catch ex As Exception
            Dim errorMsg = "Error in OtherAbnoRadGrid_ItemDataBound"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        OtherAbnoRadGrid.Rebind()
    End Sub
End Class