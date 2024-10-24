Imports Telerik.Web.UI

Partial Class Products_Options_MenuRoleAssignment
    Inherits OptionsBase
    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            For Each row As GridDataItem In MenuRadGrid.Items
                Dim MapID As String = row.GetDataKeyValue("MapID")
                Dim combo As RadComboBox = DirectCast(row.FindControl("PageComboBox"), RadComboBox)
                Dim PageID As String = combo.SelectedValue
                If PageID <> "-1" Then
                    Dim sql As String = "UPDATE ERS_MenuMap SET PageID = " & PageID & " WHERE MapID= " & MapID
                    DataAdapter.InsertPagesByRole(sql)
                End If
            Next
            Utilities.SetNotificationStyle(PagesByRoleNotification, "Settings saved successfully.")
            PagesByRoleNotification.Show()
            MenuRadGrid.Rebind()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Pages for this Role.", ex)
            Utilities.SetErrorNotificationStyle(PagesByRoleNotification, errorLogRef, "There is a problem saving data.")
            PagesByRoleNotification.Show()
        End Try
    End Sub
    'Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
    '    If Not IsPostBack Then
    '        InitForm()
    '    End If
    'End Sub

    'Private Sub InitForm()
    '    Utilities.LoadDropdown(RolesComboBox, DataAdapter.GetRoles(), "RoleName", "RoleId", Nothing)
    'End Sub

    'Protected Sub RolesComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles RolesComboBox.SelectedIndexChanged
    '    RolesRadGrid.Rebind()
    'End Sub

    'Protected Sub RolesObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles RolesObjectDataSource.Selecting
    '    e.InputParameters("RoleId") = IIf(RolesComboBox.SelectedValue = "", 0, RolesComboBox.SelectedValue)
    'End Sub

    'Protected Sub RolesRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles RolesRadGrid.ItemDataBound

    '    If TypeOf e.Item Is GridDataItem Then
    '        Dim item As GridDataItem = DirectCast(e.Item, GridDataItem)

    '        Dim combo As RadComboBox = DirectCast(item.FindControl("AccessLevelComboBox"), RadComboBox)
    '        Dim AccessLevelComboBox As String = combo.SelectedValue

    '        If AccessLevelComboBox = "1" Then
    '            combo.ForeColor = Drawing.Color.Orange 'Read Only
    '        ElseIf AccessLevelComboBox = "9" Then
    '            combo.ForeColor = Drawing.Color.Green 'Full Access
    '        Else
    '            combo.ForeColor = Drawing.Color.Red 'No Access
    '        End If

    '    End If

    'End Sub
    'Protected Sub applyToAll(AccessLevel As String)
    '    For Each itm As GridDataItem In RolesRadGrid.Items
    '        Dim combo As RadComboBox = DirectCast(itm.FindControl("AccessLevelComboBox"), RadComboBox)
    '        combo.SelectedValue = AccessLevel
    '    Next
    'End Sub

    'Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click

    '    If RolesComboBox.SelectedValue = "" Then Exit Sub

    '    Dim RoleId As Integer = RolesComboBox.SelectedValue
    '    Dim cmd As String = ""

    '    Try
    '        For Each row As GridDataItem In RolesRadGrid.Items
    '            Dim PageId As String = row.GetDataKeyValue("PageId")
    '            Dim combo As RadComboBox = DirectCast(row.FindControl("AccessLevelComboBox"), RadComboBox)
    '            Dim AccessLevel As String = combo.SelectedValue
    '            If AccessLevel <> "0" Then
    '                cmd += " SELECT " & RoleId & ", " & PageId & ", " & AccessLevel & "  UNION"
    '            End If
    '        Next
    '        If cmd <> "" Then
    '            cmd = "INSERT INTO ERS_PagesByRole (RoleId, PageId, AccessLevel) " & Left(cmd, Len(cmd) - 6)
    '        End If

    '        cmd = "DELETE FROM ERS_PagesByRole WHERE RoleId = " & RoleId & "; " & cmd

    '        DataAdapter.InsertPagesByRole(cmd)
    '        RolesRadGrid.Rebind()
    '    Catch ex As Exception
    '        Dim errorLogRef As String
    '        errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Pages for this Role.", ex)

    '        Utilities.SetErrorNotificationStyle(PagesByRoleNotification, errorLogRef, "There is a problem saving data.")
    '        PagesByRoleNotification.Show()
    '    End Try
    'End Sub

    'Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
    '    RolesRadGrid.Rebind()
    'End Sub

    'Protected Sub ApplyRoleToAllButton_Click(sender As Object, e As EventArgs)
    '    applyToAll(AccessLevelCombobx.SelectedValue)
    'End Sub
End Class
