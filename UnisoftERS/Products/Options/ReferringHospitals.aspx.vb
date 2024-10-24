Imports System.Drawing
Imports Telerik.Web.UI

Public Class ReferringHospitals
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub
    Protected Sub HideSuppressButton_Click(sender As Object, e As EventArgs)
        Dim iSuppress As Integer = SuppressedComboBox.SelectedIndex
        Select Case iSuppress
            Case 0
                HospitalObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = Nothing
            Case 1
                HospitalObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 1
            Case 2
                HospitalObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 0
        End Select
        ReferringHospitalsRadGrid.Rebind()
    End Sub

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        Try
            ReferringHospitalsRadGrid.Rebind()
        Catch ex As Exception
        End Try
    End Sub
    Protected Sub SearcHospital()
        ReferringHospitalsRadGrid.MasterTableView.SortExpressions.Clear()
        ReferringHospitalsRadGrid.MasterTableView.CurrentPageIndex = 0
        ReferringHospitalsRadGrid.DataBind()
    End Sub
    Protected Sub clearCosultant()
        SearchTextBox.Text = ""
        ReferringHospitalsRadGrid.DataBind()
    End Sub

    Private Sub ReferringHospitalsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles ReferringHospitalsRadGrid.ItemCommand
        If e.CommandName = "SuppressHospital" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter.SuppressHospital(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("HospitalID")), bSuppress)
            ReferringHospitalsRadGrid.Rebind()
        End If
    End Sub

    Protected Sub ReferringHospitalsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles ReferringHospitalsRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return editHospital('{0}','{1}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("HospitalID"), e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("HospitalName"))
        End If
    End Sub

    Protected Sub ReferringHospitalsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles ReferringHospitalsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            'Dim SuppressLinkButton As ImageButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), ImageButton)
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If row("Suppressed") = "Yes" Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Hospital"
                SuppressLinkButton.OnClientClick = ""
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            ReferringHospitalsRadGrid.MasterTableView.SortExpressions.Clear()
            ReferringHospitalsRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            ReferringHospitalsRadGrid.MasterTableView.SortExpressions.Clear()
            ReferringHospitalsRadGrid.MasterTableView.CurrentPageIndex = ReferringHospitalsRadGrid.MasterTableView.PageCount - 1
            ReferringHospitalsRadGrid.Rebind()
        End If
    End Sub

    Protected Sub NewHospitalRadButton_Click(sender As Object, e As EventArgs)
        Dim hospitalName = NewHospitalTextBox.Text

        Try
            If String.IsNullOrWhiteSpace(HospitalIdHiddenField.Value) Then
                'add new
                DataAdapter.AddNewReferringHospital(hospitalName)

                ReferringHospitalsRadGrid.MasterTableView.SortExpressions.Clear()
                ReferringHospitalsRadGrid.MasterTableView.CurrentPageIndex = ReferringHospitalsRadGrid.MasterTableView.PageCount - 1
                ReferringHospitalsRadGrid.Rebind()
            Else
                'edit
                Dim hospitalId = CInt(HospitalIdHiddenField.Value)

                DataAdapter.UpdateReferringHospital(hospitalId, hospitalName)

                ReferringHospitalsRadGrid.MasterTableView.SortExpressions.Clear()
                ReferringHospitalsRadGrid.Rebind()
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving data.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

    Protected Sub ReferringHospitalsRadGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        ReferringHospitalsRadGrid.DataSource = HospitalObjectDataSource
    End Sub
End Class