Imports Telerik.Web.UI

Public Class EditImagePortConfig
    Inherits PageBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim da As DataAccess = New DataAccess
            Dim dt As DataTable
            Dim otherRoomId As Integer

            If IsDBNull(Request.QueryString("otherRoomId")) Or Request.QueryString("otherRoomId") Is Nothing Or Request.QueryString("otherRoomId") = "" Then
                otherRoomId = 0
            Else
                otherRoomId = CInt(Request.QueryString("otherRoomId"))
            End If

            Dim otherImagePortId As Integer = CInt(Request.QueryString("otherImagePortId"))

            Dim otherOperatingHospitalId As Integer = CInt(Request.QueryString("otherOperatingHospitalId"))

            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{RoomMultiColumnComboBox, ""}},
                                   da.GetImagePortRooms(otherOperatingHospitalId), "RoomName", "RoomId", True)

            RoomIdHiddenField.Value = otherRoomId
            ImagePortIdHiddenField.Value = otherImagePortId
            OperationHospitalIdHiddenField.Value = otherOperatingHospitalId
            If otherImagePortId <> 0 Then
                dt = da.GetImagePortRoomsSpecific(otherImagePortId, otherRoomId)

                If dt.Rows.Count > 0 Then
                    PortnameText.Text = dt.Rows(0).Item("PortName")
                    If IsDBNull(dt.Rows(0).Item("MacAddress")) Or dt.Rows(0).Item("MacAddress") Is Nothing Then
                        MACAddressTextBox.Text = ""
                    Else
                        MACAddressTextBox.Text = dt.Rows(0).Item("MacAddress")
                    End If

                    FriendlyNameTextBox.Text = dt.Rows(0).Item("FriendlyName")

                    If IsDBNull(dt.Rows(0).Item("Default")) Or dt.Rows(0).Item("Default") Is Nothing Then
                        DefaultCheckBox.Checked = False
                    Else
                        DefaultCheckBox.Checked = dt.Rows(0).Item("Default")
                    End If

                    If Not IsDBNull(dt.Rows(0).Item("RoomId")) Then
                        RoomMultiColumnComboBox.SelectedValue = dt.Rows(0).Item("RoomId")
                    End If
                    'Static.Text = dt.Rows(0).Item("Static")
                    If IsDBNull(dt.Rows(0).Item("Comments")) Or dt.Rows(0).Item("Comments") Is Nothing Then
                        CommentsTextBox.Text = ""
                    Else
                        CommentsTextBox.Text = dt.Rows(0).Item("Comments")
                    End If
                End If
            End If
        End If

    End Sub

    Protected Sub ImagePortSaveButton_Click(sender As Object, e As EventArgs)

        Dim da As DataAccess = New DataAccess
        Dim isValid = True
        Dim errorMsg = ""

        Dim selectedRoomId = IIf(RoomMultiColumnComboBox.SelectedValue = "", 0, RoomMultiColumnComboBox.SelectedValue)
        Dim selectedDefaultValue = DefaultCheckBox.Checked
        Dim selectedOperationHospitalId = OperationHospitalIdHiddenField.Value
        Dim currentDefaultImagePort As Integer = 0

        If Len(Trim(PortnameText.Text)) = 0 Then
            IsValid = False
            errorMsg += "No ImagePort name entered.<br />"
            PortnameText.CssClass += "validation-error-field"
        End If

        If Len(Trim(MACAddressTextBox.Text)) = 0 Then
            IsValid = False
            errorMsg += "No MacAddress entered.<br />"
            MACAddressTextBox.CssClass += "validation-error-field"
        End If

        If Len(Trim(FriendlyNameTextBox.Text)) = 0 Then
            IsValid = False
            errorMsg += "No Friendly Name entered.<br />"
            FriendlyNameTextBox.CssClass += "validation-error-field"
        End If

        If ImagePortIdHiddenField.Value = 0 Then

            If DataAdapter.CheckValueExists(PortnameText.Text, "ERS_ImagePort", "PortName", "ImagePortId") > 0 Then
                isValid = False
                errorMsg += "Duplicate ImagePort Name entered.<br />"
                PortnameText.CssClass += "validation-error-field"
            End If

            If DataAdapter.CheckValueExists(MACAddressTextBox.Text, "ERS_ImagePort", "MacAddress", "ImagePortId") > 0 Then
                isValid = False
                errorMsg += "Duplicate MacAddress entered.<br />"
                MACAddressTextBox.CssClass += "validation-error-field"
            End If

            If RoomMultiColumnComboBox.SelectedIndex = -1 Then
                isValid = False
                errorMsg += "No Room entered.<br />"
                RoomMultiColumnComboBox.CssClass += "validation-error-field"
            End If
        End If

        If Not IsValid Then
            Utilities.SetNotificationStyle(FailedNotification, errorMsg, True)
            FailedNotification.Title = "Please correct the following..."
            FailedNotification.Height = "0"
            FailedNotification.Show()
            Exit Sub
        End If

        'Update default room for all image ports in that room if default is changed.
        'Check for default for this room
        Dim dtCheckImagePort As DataTable = da.CheckImagePortRoomDefault(selectedOperationHospitalId, selectedRoomId, selectedDefaultValue)

        Dim result() As DataRow = dtCheckImagePort.Select("[Default] = 1")

        For Each row As DataRow In result
            'MsgBox($"{row(0)}, {row(1)}, {row(2)}, {row(3)}")
            currentDefaultImagePort = row(3)
        Next

        If dtCheckImagePort.Rows.Count > 0 Then
            'Default record already exists in this room.
            'Remove default flag from all other image ports in this room.
            da.ClearImagePortRoomDefault(currentDefaultImagePort)
        End If

        da.SaveImagePortDetails(selectedOperationHospitalId, ImagePortIdHiddenField.Value, PortnameText.Text, MACAddressTextBox.Text,
                                selectedRoomId, CommentsTextBox.Text, FriendlyNameTextBox.Text, selectedDefaultValue)


        ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "SaveAndClose", "CloseAndRebind();", True)
    End Sub

End Class