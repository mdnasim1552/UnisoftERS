Imports System.Drawing
Imports Telerik.Web.UI

Public Class NonGIConsultants
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            NonGIConsultantsDatasource.SelectParameters("operatingHospitalIds").DefaultValue = Session("OperatingHospitalIdsForTrust")
            Try
                If Me.Master IsNot Nothing Then
                    Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                    Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                    If leftPane IsNot Nothing Then leftPane.Visible = False
                    If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
                End If
            Catch ex As Exception

            End Try
        End If

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(myAjaxMgr, NonGIConsultantsRadGrid, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(NonGIConsultantsRadGrid, NonGIConsultantsRadGrid, RadAjaxLoadingPanel1, UpdatePanelRenderMode.Inline)
    End Sub

    Protected Sub NonGIConsultantsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        If e.CommandName = "SuppressUser" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter_Sch.SuppressUser(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("UserId")), bSuppress)
            NonGIConsultantsRadGrid.Rebind()
        ElseIf e.CommandName = "Rebind" Then
            NonGIConsultantsRadGrid.MasterTableView.SortExpressions.Clear()
            NonGIConsultantsRadGrid.Rebind()
        ElseIf e.CommandName = "RebindAndNavigate" Then
            NonGIConsultantsRadGrid.MasterTableView.SortExpressions.Clear()
            NonGIConsultantsRadGrid.MasterTableView.CurrentPageIndex = NonGIConsultantsRadGrid.MasterTableView.PageCount - 1
            NonGIConsultantsRadGrid.Rebind()
        End If
    End Sub

    Protected Sub NonGIConsultantsRadGrid_ItemCreated(sender As Object, e As GridItemEventArgs)
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return ShowEditForm('{0}','{1}');",
                                                                 e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("UserId"),
                                                                 e.Item.ItemIndex)
        End If
    End Sub

    Protected Sub RoomsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles NonGIConsultantsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If row("Suppressed") = True Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Room"
                SuppressLinkButton.OnClientClick = ""
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub
End Class