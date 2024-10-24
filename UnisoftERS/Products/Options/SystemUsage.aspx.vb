Imports Constants
Imports Utilities
Imports Telerik.Web.UI

Partial Class Products_Options_SystemUsage
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then

        End If
    End Sub

    Protected Sub LoggedInUsersGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles LoggedInUsersGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim LogOutImageButton As ImageButton = DirectCast(e.Item.FindControl("LogOutImageButton"), ImageButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If CInt(row("UserId") = CInt(Session("PKUserId"))) Then
                'LogOutImageButton.Enabled = False
                LogOutImageButton.OnClientClick = "javascript:alert('You cannot force log off yourself.');return false;"
            End If
        End If
    End Sub

    Protected Sub LoggedInUsersGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles LoggedInUsersGrid.ItemCommand
        If e.CommandName = "Delete" Then
            If CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("UserId")) = CInt(Session("PKUserId")) Then
                'This is to be on safe side just in case if the Javascript fails
                e.Canceled = True
            End If
        End If
    End Sub

    Protected Sub LoggedInUsersGrid_ItemDeleted(sender As Object, e As GridDeletedEventArgs) Handles LoggedInUsersGrid.ItemDeleted
        If e.Exception Is Nothing Then
            Utilities.SetNotificationStyle(RadNotification1, "User has been force logged off successfully!")
            RadNotification1.Show()
        End If
    End Sub

    'Protected Sub LockedPatientsGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles LockedPatientsGrid.ItemCommand
    '    If e.CommandName = "Unlock" Then
    '        LockedPatientsObjectDataSource.UpdateParameters("patientId").DefaultValue = CStr(DirectCast(e.Item, GridDataItem).GetDataKeyValue("PatientId"))
    '        LockedPatientsObjectDataSource.Update()
    '    End If
    'End Sub

    'Protected Sub LockedPatientsGrid_ItemDeleted(sender As Object, e As GridDeletedEventArgs) Handles LockedPatientsGrid.ItemDeleted
    '    If e.Exception Is Nothing Then
    '        Utilities.SetNotificationStyle(RadNotification1, "Patient record unlocked successfully!")
    '        RadNotification1.Show()
    '    End If
    'End Sub
End Class
