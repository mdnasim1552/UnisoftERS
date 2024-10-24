Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Options_ReferingConsultant
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load

    End Sub
    Protected Sub HideSuppressButton_Click(sender As Object, e As EventArgs)
        Dim iSuppress As Integer = SuppressedComboBox.SelectedIndex
        Select Case iSuppress
            Case 0
                ConsultantsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = Nothing
            Case 1
                ConsultantsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 1
            Case 2
                ConsultantsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 0
        End Select
        ConsultantsRadGrid.DataBind()
    End Sub
    'Protected Sub SuppressConsultants()
    '    Dim ConsultantID As String = CStr(ConsultantsRadGrid.SelectedValues("ConsultantID"))
    '    Dim Suppressed As Boolean = CBool(IIf(ConsultantsRadGrid.SelectedValues("Suppressed") = "Yes", True, False))
    '    If ConsultantID <> "" Then
    '        Dim db As New DataAccess
    '        db.SuppressConsultant(ConsultantID, Not Suppressed)
    '    End If
    '    ConsultantsRadGrid.DataBind()
    'End Sub

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        ConsultantsRadGrid.Rebind()
    End Sub
    Protected Sub SearchConsultant()
        ConsultantsRadGrid.MasterTableView.SortExpressions.Clear()
        ConsultantsRadGrid.MasterTableView.CurrentPageIndex = 0
        ConsultantsRadGrid.DataBind()
    End Sub
    Protected Sub clearCosultant()
        SearchComboBox.SelectedIndex = 0
        SearchTextBox.Text = ""
        ConsultantsRadGrid.DataBind()
    End Sub

    Private Sub ConsultantsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles ConsultantsRadGrid.ItemCommand
        If e.CommandName = "SuppressConsultant" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter.SuppressConsultant(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("ConsultantID")), bSuppress)
            ConsultantsRadGrid.Rebind()
        End If
    End Sub

    Protected Sub ConsultantsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles ConsultantsRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return editConsultant('{0}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ConsultantID"))
        End If
    End Sub

    Protected Sub ConsultantsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles ConsultantsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or _
            e.Item.ItemType = GridItemType.AlternatingItem Then
            'Dim SuppressLinkButton As ImageButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), ImageButton)
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If row("Suppressed") = "Yes" Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Consultant"
                SuppressLinkButton.OnClientClick = ""
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            ConsultantsRadGrid.MasterTableView.SortExpressions.Clear()
            ConsultantsRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            ConsultantsRadGrid.MasterTableView.SortExpressions.Clear()
            ConsultantsRadGrid.MasterTableView.CurrentPageIndex = ConsultantsRadGrid.MasterTableView.PageCount - 1
            ConsultantsRadGrid.Rebind()
        End If
    End Sub

End Class
