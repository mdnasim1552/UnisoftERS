Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Options_Scheduler_Rooms
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        'If Not IsPostBack Then
        '    If Me.Master IsNot Nothing Then
        '        Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
        '        Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

        '        If leftPane IsNot Nothing Then leftPane.Visible = False
        '        If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
        '    End If
        'End If

        'Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)

        'myAjaxMgr.AjaxSettings.AddAjaxSetting(myAjaxMgr, RoomsRadGrid, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(RoomsRadGrid, RoomsRadGrid, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(SearchButton, RoomsRadGrid, RadAjaxLoadingPanel1)


        If Not Page.IsPostBack Then

            OperatingHospitalsRadComboBox.DataSource = DataAdapter.GetAllOperatingHospitals(CInt(Session("TrustId")))
            OperatingHospitalsRadComboBox.DataTextField = "HospitalName"
            OperatingHospitalsRadComboBox.DataValueField = "OperatingHospitalId"
            OperatingHospitalsRadComboBox.DataBind()
            OperatingHospitalsRadComboBox.SelectedValue = CInt(Session("OperatingHospitalId"))
        End If
    End Sub
    Protected Sub HideSuppressButton_Click(sender As Object, e As EventArgs)
        Dim iSuppress As Integer = SuppressedComboBox.SelectedIndex
        Select Case iSuppress
            Case 0
                RoomsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = Nothing
            Case 1
                RoomsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 1
            Case 2
                RoomsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 0
        End Select
        RoomsRadGrid.DataBind()
    End Sub

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        RoomsRadGrid.Rebind()
    End Sub
    Protected Sub SearchRoom()
        RoomsRadGrid.MasterTableView.SortExpressions.Clear()
        RoomsRadGrid.MasterTableView.CurrentPageIndex = 0
        RoomsRadGrid.DataBind()
    End Sub
    Protected Sub clearCosultant()
        SearchComboBox.SelectedIndex = 0
        SearchTextBox.Text = ""
        RoomsRadGrid.DataBind()
    End Sub

    Private Sub RoomsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles RoomsRadGrid.ItemCommand
        If e.CommandName = "SuppressRoom" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter_Sch.SuppressRoom(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("RoomId")), bSuppress)
            RoomsRadGrid.Rebind()
        ElseIf e.CommandName = "Rebind" Then
            RoomsRadGrid.MasterTableView.SortExpressions.Clear()
            RoomsRadGrid.Rebind()
        ElseIf e.CommandName = "RebindAndNavigate" Then
            RoomsRadGrid.MasterTableView.SortExpressions.Clear()
            RoomsRadGrid.MasterTableView.CurrentPageIndex = RoomsRadGrid.MasterTableView.PageCount - 1
            RoomsRadGrid.Rebind()
        End If
    End Sub

    Protected Sub RoomsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles RoomsRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return editRoom('{0}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoomId"))
        End If
    End Sub

    Protected Sub RoomsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles RoomsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If row("Suppressed") = "Yes" Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Room"
                SuppressLinkButton.OnClientClick = ""
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If

            Dim item As GridDataItem = CType(e.Item, GridDataItem)
            Dim Procedures As String = item("Procedures").Text

            If row("AllProcedureTypes") Then
                item("Procedures").Text = "All Procedures"
            ElseIf Procedures = "0" Then
                item("Procedures").Text = "(Unspecified)"
            ElseIf row("Procedures") = "1" Then
                item("Procedures").Text = "1 Procedure"
            Else
                item("Procedures").Text = Procedures & " Procedures"
            End If
        End If
    End Sub


    Protected Sub OperatingHospitalsRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)

    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            RoomsRadGrid.MasterTableView.SortExpressions.Clear()
            RoomsRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            RoomsRadGrid.MasterTableView.SortExpressions.Clear()
            RoomsRadGrid.MasterTableView.CurrentPageIndex = RoomsRadGrid.MasterTableView.PageCount - 1
            RoomsRadGrid.Rebind()
        End If
    End Sub
End Class
