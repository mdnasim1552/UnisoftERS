Imports Telerik.Web.UI

Partial Class Products_Options_Scheduler_EditRooms
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim RoomId As Integer = 0
        If Not Page.IsPostBack Then
            RoomId = GetRoomId()
            If RoomId > 0 Then
                fillEditForm(RoomId)
            End If
        End If
    End Sub

    Private Sub fillEditForm(RoomId As Integer)
        Dim db As New DataAccess_Sch
        Dim dt As DataRow = db.GetRoom(RoomId).Rows(0)
        RoomNameTextBox.Text = CStr(dt("RoomName"))
        RoomSortOrderTextBox.Text = CStr(dt("RoomSortOrder"))
        HospitalDropDownList.SelectedValue = CStr(dt("HospitalId"))
    End Sub

    Protected Sub SaveRoom()
        Try
            Dim db As New DataAccess_Sch

            Dim checkAllProcedure As Boolean = False
            If ProcedureTypeRadListBox.CheckedItems.Count = ProcedureTypeRadListBox.Items.Count Then
                checkAllProcedure = True
            End If

            Dim bOtherInvestigations As Boolean = False
            Dim ProcedureTypes As String = ""
            For Each item As RadListBoxItem In ProcedureTypeRadListBox.Items
                If item.Checked Then
                    If item.Value = 99 Then
                        bOtherInvestigations = True
                    Else
                        ProcedureTypes = ProcedureTypes & item.Value & ","
                    End If
                End If
            Next

            db.SaveRooms(GetRoomId(), RoomNameTextBox.Text,
                         RoomSortOrderTextBox.Text, checkAllProcedure,
                         bOtherInvestigations, IIf(HospitalDropDownList.SelectedValue = "", 0, HospitalDropDownList.SelectedValue),
                         CInt(Session("PKUserID")), ProcedureTypes)
            'Dim RoomId As Integer = GetRoomId()
            'Dim sqlStr As String = ""
            'Dim sqlProc As String = ""


            'If sqlProc <> "" Then
            '    If Right(sqlProc, 1) = "," Then
            '        sqlProc = Left(sqlProc, sqlProc.Length - 1)
            '    End If

            '    sqlProc = " INSERT INTO [dbo].[ERS_SCH_RoomProcedures] (RoomId, ProcedureTypeId, WhoCreatedId, WhenCreated) VALUES " & sqlProc
            'End If


            'sqlStr = "DECLARE @RoomId INT; "
            'If RoomId > 0 Then
            '    sqlStr = sqlStr & "SET @RoomId = " & CStr(RoomId) & ";"

            '    sqlStr = sqlStr & " DELETE FROM [dbo].[ERS_SCH_RoomProcedures] WHERE RoomId = @RoomId; "

            '    sqlStr = sqlStr & " UPDATE [dbo].[ERS_SCH_Rooms] SET RoomName='" & RoomNameTextBox.Text & "', RoomSortOrder='" & RoomSortOrderTextBox.Text & "', AllProcedureTypes = " & IIf(checkAllProcedure, 1, 0) & ", " &
            '                "HospitalId = " & HospitalDropDownList.SelectedValue & ", OtherInvestigations = " & IIf(bOtherInvestigations, 1, 0) &
            '                ", WhoUpdatedID = " & CInt(Session("PKUserID")) & ", WhenUpdated = GETDATE() WHERE RoomId = @RoomId; "
            'Else
            '    sqlStr = sqlStr & " INSERT INTO [dbo].[ERS_SCH_Rooms] (RoomSortOrder, RoomName, AllProcedureTypes, OtherInvestigations, HospitalId, Suppressed, WhoCreatedId , WhenCreated) " &
            '        " Select '" & RoomSortOrderTextBox.Text & "', " & "'" & RoomNameTextBox.Text & "', " & IIf(checkAllProcedure, 1, 0) & ", " & IIf(bOtherInvestigations, 1, 0) & ", " &
            '        IIf(HospitalDropDownList.SelectedValue = "", 0, HospitalDropDownList.SelectedValue) & ", 0, " & CInt(Session("PKUserID")) & ", GETDATE() ;" &
            '        "SET @RoomId = @@IDENTITY; "
            'End If

            'sqlStr = sqlStr & sqlProc

            'Try
            '    DataAccess.ExecuteSQL(sqlStr, Nothing)
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving rooms.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

    Private Sub ProcedureTypeRadListBox_ItemDataBound(sender As Object, e As RadListBoxItemEventArgs) Handles ProcedureTypeRadListBox.ItemDataBound
        Dim item As RadListBoxItem = CType(e.Item, RadListBoxItem)
        Dim row As DataRowView = CType(item.DataItem, DataRowView)
        If Convert.ToInt32(row("RoomProcId")) > 0 Then
            item.Checked = True
        End If
    End Sub

    Private Function GetRoomId() As Integer
        Dim RoomId As Integer = 0
        If Not IsDBNull(Request.QueryString("RoomId")) AndAlso Request.QueryString("RoomId") <> "" Then
            RoomId = CInt(Request.QueryString("RoomId"))
        End If
        Return RoomId
    End Function

    Private Sub RoomProcedureObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles RoomProcedureObjectDataSource.Selecting
        e.InputParameters("RoomId") = GetRoomId()
    End Sub
End Class
