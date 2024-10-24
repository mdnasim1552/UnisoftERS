Imports Telerik.Web.UI

Public Class Worklist
    Inherits System.Web.UI.UserControl

    Dim showPreAssessment As String = ConfigurationManager.AppSettings("ShowPreAssessment")
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ProcedureTypesDataSource.ConnectionString = DataAccess.ConnectionStr
        If Not Page.IsPostBack Then
            StartDate.SelectedDate = DateTime.Now
            EndDate.SelectedDate = DateTime.Now
            WorkListObjectDataSource.SelectParameters("StartDate").DefaultValue = DateTime.Now
            WorkListObjectDataSource.SelectParameters("EndDate").DefaultValue = DateTime.Now

            Dim da As New DataAccess
            Dim user = da.GetUser(Session("PKUserId"))
            If user.Rows.Count > 0 Then
                If Not user.Rows(0).Item("IsListConsultant") And Not user.Rows(0).Item("IsEndoscopist1") And Not user.Rows(0).Item("IsEndoscopist2") Then
                    ViewAllCheckbox.Checked = True
                End If
            End If
        End If
    End Sub

    Protected Sub WorklistGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Dim appointmentDate = CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("StartDateTime").ToString()
        If e.CommandName = "startprocedure" Or e.CommandName = "goToPatient" Or e.CommandName = "startpreassessment" Then
            Dim patientId = CInt(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("PatientId"))
            Dim cnn = CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("HospitalNumber").ToString()
            Dim ersPatient = CBool(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("ERSPatient").ToString())
            Dim worklistId = CInt(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("UniqueId").ToString())
            Dim appointmentId = CInt(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("UniqueId").ToString())
            Dim appointmentStatus = CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("AppointmentStatusHDCKEY").ToString()

            If appointmentStatus.ToLower = "c" And e.CommandName = "startpreassessment" Then
                Utilities.SetNotificationStyle(RadNotification1, "You cannot start a pre assessment from a cancelled appointment", True, "Procedure cancelled")
                RadNotification1.Show()
                Exit Sub
            ElseIf appointmentStatus.ToLower = "c" Then
                Utilities.SetNotificationStyle(RadNotification1, "You cannot start a procedure from a cancelled appointment", True, "Procedure cancelled")
                RadNotification1.Show()
                Exit Sub
            End If
            Dim procedureTypeId As Integer = 0
            If Not String.IsNullOrEmpty(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("ProcedureTypeId").ToString()) Then
                procedureTypeId = CInt(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("ProcedureTypeId").ToString())
            End If
            If procedureTypeId > 9 Then procedureTypeId = 0
            WorklistGridSelect(patientId, cnn, ersPatient, worklistId, appointmentId, procedureTypeId, e.CommandName)
        ElseIf e.CommandName = "remove" Then
            Dim worklistId = CInt(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("UniqueId"))
            Dim da As New DataAccess
            da.cancelWorklistPatient(worklistId)
            WorkListGrid.Rebind()
        ElseIf e.CommandName = "goToScheduler" Then
            Session("WorklistDate") = CDate(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("StartDateTime").ToString())
            If Not IsDBNull(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("RoomId")) Then
                Session("WorklistRoomId") = CInt(CType(WorkListGrid.SelectedItems(0), GridDataItem).GetDataKeyValue("RoomId").ToString())
            Else
                Session("WorklistRoomId") = Nothing
            End If
            ' type added by Ferdowsi
            Response.Redirect("~/Products/Scheduler/DiarySchedule.aspx?type=" + appointmentDate, False)
        End If
    End Sub

    Private Sub WorklistGridSelect(patientId As Integer, caseNoteNo As String, ersPatient As Boolean, worklistId As Integer, appointmentId As Integer, procedureTypeId As Integer, commandName As String)
        Dim sm As New SessionManager
        sm.ClearPatientSessions()
        ' Set or alter value when select patient from grid
        Dim CookieTime As Int32 = ConfigurationManager.AppSettings("CookieTime")
        If Request.Cookies("patientId") Is Nothing Then
            Dim aCookie As New HttpCookie("patientId") With {
                .Value = patientId,
                .Expires = DateTime.Now.AddMinutes(CookieTime)
            }
            Response.Cookies.Add(aCookie)
        Else
            Dim Cookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
            Cookie.Value = patientId
            Cookie.Expires = DateTime.Now.AddMinutes(CookieTime)
            Response.Cookies.Add(Cookie)
        End If
        Session(Constants.SESSION_CASE_NOTE_NO) = caseNoteNo
        Session(Constants.SESSION_IS_ERS_PATIENT) = ersPatient
        Session(Constants.SESSION_PATIENT_WORKLIST_ID) = worklistId
        Session(Constants.SESSION_APPOINTMENT_ID) = appointmentId
        Session(Constants.SESSION_WORKLIST_PROCEDURE_TYPE_ID) = procedureTypeId

        Me.Page.GetType.InvokeMember("LoadPatientPage", System.Reflection.BindingFlags.InvokeMethod, Nothing, Me.Page, Nothing)
    End Sub

    Public Sub patientAdded()
        WorkListGrid.MasterTableView.SortExpressions.Clear()
        WorkListGrid.Rebind()
    End Sub

    Protected Sub WorkListGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        If TypeOf e.Item Is GridDataItem Then
            Dim dataItem As GridDataItem = e.Item

            'Format NHS Number
            Dim cell As TableCell = dataItem("NHSNo")
            cell.Text = Utilities.FormatHealthServiceNumber(cell.Text.Replace("&nbsp;", String.Empty))


            Dim appointmentStatusHDCKEY = CType(e.Item, GridDataItem).GetDataKeyValue("AppointmentStatusHDCKEY")
            If Not IsDBNull(appointmentStatusHDCKEY) Then
                Select Case appointmentStatusHDCKEY
                    Case "P", "B"
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#7FCC7F")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                        dataItem.CssClass = "row-colour-opacity"
                    Case "A"
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#7FDBF5")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                        dataItem.CssClass = "row-colour-opacity"
                    Case "BA"
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#B5D2E6")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                        dataItem.CssClass = "row-colour-opacity"
                    Case "C"
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#CD5C5C")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                        dataItem.CssClass = "row-colour-opacity"

                    Case "D"
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#E38AC2")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                        dataItem.CssClass = "row-colour-opacity"
                    Case "X"
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#8D8D8D")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                        dataItem.CssClass = "row-colour-opacity"
                    Case "IP"
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#FFD966")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                        dataItem.CssClass = "row-colour-opacity"
                    Case "DC"
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#5F5FE3")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#FFFFFF")
                        dataItem.CssClass = "row-colour-opacity"
                    Case "RC"
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#FFA500")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                        dataItem.CssClass = "row-colour-opacity"
                    Case Else
                        dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#F0F8FF")
                        dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                        dataItem.CssClass = "row-colour-opacity"
                End Select
            Else
                dataItem.BackColor = Drawing.ColorTranslator.FromHtml("#7FCC7F")
                dataItem.ForeColor = Drawing.ColorTranslator.FromHtml("#000000")
                dataItem.CssClass = "row-colour-opacity"
            End If

            Dim imgAlerts = CType(dataItem.FindControl("imgAlerts"), Image)
            If imgAlerts.ToolTip = Nothing Then
                imgAlerts.Visible = False
            Else
                imgAlerts.Visible = True
            End If

            Dim imgNotes = CType(dataItem.FindControl("imgNotes"), Image)
            If imgNotes.ToolTip = Nothing Then
                imgNotes.Visible = False
            Else
                imgNotes.Visible = True
            End If
        ElseIf TypeOf e.Item Is GridCommandItem Then

            Dim commandItem As GridCommandItem = CType(e.Item, GridCommandItem)

            Dim lnkButton As RadLinkButton = CType(commandItem.FindControl("StartPreAssessment"), RadLinkButton)

            If Not String.IsNullOrEmpty(showPreAssessment) AndAlso showPreAssessment.ToLower() = "y" Then
                lnkButton.Visible = True
            Else
                lnkButton.Visible = False
            End If
        End If
    End Sub
    Protected Sub RadMenu2_PreRender(sender As Object, e As EventArgs) Handles RadMenu2.PreRender

        If Not String.IsNullOrEmpty(showPreAssessment) AndAlso showPreAssessment.ToLower() = "y" Then
            RadMenu2.Items(0).Visible = True
        Else
            RadMenu2.Items(0).Visible = False
        End If
    End Sub
    Protected Sub WorkListGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim endoscopistId = Session("PKUserId")

        If ViewAllCheckbox.Checked Then
            endoscopistId = Nothing
        End If

        Dim da As New DataAccess
        'Dim user = da.GetUser(endoscopistId)
        'If Not user.Rows(0).Item("IsListConsultant") And Not user.Rows(0).Item("IsEndoscopist1") And Not user.Rows(0).Item("IsEndoscopist2") Then
        '    endoscopistId = Nothing
        'End If
        WorkListGrid.DataSource = da.GetWorklistPatients(StartDate.SelectedDate, EndDate.SelectedDate, endoscopistId)

    End Sub

    Protected Sub RadMenu2_ItemClick(ByVal sender As Object, ByVal e As RadMenuEventArgs)
        Dim appointmentId As Integer
        appointmentId = Convert.ToInt32(Request.Form("WorklistSelectedIdHiddenField"))
        If (Not appointmentId = 0) Then
            Dim appointmentStatusHDCKEY As String = e.Item.Value
            If Not appointmentStatusHDCKEY = "" Then
                Dim da As New DataAccess_Sch
                Dim patientId As Integer
                patientId = Convert.ToInt32(Request.Form("WorklistPatientHiddenField"))

                Select Case appointmentStatusHDCKEY
                    Case "BA"
                        da.markPatientAttended(appointmentId)
                        Exit Select
                    Case "DC"
                        da.markPatientDischarged(appointmentId)
                        Exit Select
                    Case "D"
                        da.markPatientDNA(appointmentId)
                        Exit Select
                    Case "X"
                        da.markPatientAbandoned(appointmentId)
                        Exit Select
                    Case "C"
                        da.markPatientCancelled(appointmentId)
                        Exit Select
                    Case "B"
                        da.markPatientBooked(appointmentId)
                        Exit Select
                End Select

                WorkListGrid.Rebind()
            End If
        End If
    End Sub

#Region "Filtering"
    Protected Sub FilterCombo_DataBound(sender As Object, e As EventArgs)
        Dim comboBox = CType(sender, RadComboBox)
        Dim comboListItems As New List(Of RadComboBoxItem)
        Dim items = comboBox.Items.Select(Function(x) x.Text).Distinct
        comboListItems.AddRange((From c In items
                                 Select New RadComboBoxItem(c)))
        comboBox.Items.Clear()
        comboBox.Items.AddRange(comboListItems)
    End Sub

    Public Function BuildEndoList()
        Dim da As New DataAccess
        Return (From d In da.GetWorklistPatient.Rows
                Select d("Endoscopist") Distinct)
    End Function

    Protected Sub ProceduresCombo_PreRender(sender As Object, e As EventArgs)
        Dim ddl = CType(sender, RadComboBox)
        Dim gridColumn = WorkListGrid.MasterTableView.GetColumn("ProcedureType")
        Dim procsList As New List(Of RadComboBoxItem)
        procsList.Add(New RadComboBoxItem("All"))

        For Each di As GridDataItem In WorkListGrid.Items
            procsList.Add(New RadComboBoxItem(di(gridColumn).Text))
        Next

        Dim items = procsList.Select(Function(x) x.Text).Distinct
        ddl.Items.Clear()
        ddl.Items.AddRange((From c In items
                            Select New RadComboBoxItem(c)))
    End Sub

    Protected Sub EndoscopistCombo_PreRender(sender As Object, e As EventArgs)
        If Page.IsPostBack Then Exit Sub
        Dim ddl = CType(sender, RadComboBox)
        Dim gridColumn = WorkListGrid.MasterTableView.GetColumn("Endoscopist")
        Dim endoList As New List(Of RadComboBoxItem)
        endoList.Add(New RadComboBoxItem("All"))

        For Each di As GridDataItem In WorkListGrid.Items
            endoList.Add(New RadComboBoxItem(di(gridColumn).Text))
        Next

        Dim items = endoList.Select(Function(x) x.Text).Distinct
        ddl.Items.Clear()
        ddl.Items.AddRange((From c In items
                            Select New RadComboBoxItem(c)))
    End Sub

    Public Sub Timer1_Tick(ByVal sender As Object, ByVal e As EventArgs) Handles Timer1.Tick

        WorkListGrid.Rebind()

    End Sub

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        WorkListGrid.Rebind()
    End Sub

    Protected Sub ExportToExcelButton_Click(sender As Object, e As EventArgs)
        Dim offsetMinutes As Integer = CInt(Session("TimezoneOffset"))
        WorkListGrid.ExportSettings.Excel.Format = GridExcelExportFormat.Html
        WorkListGrid.ExportSettings.IgnorePaging = True
        WorkListGrid.ExportSettings.ExportOnlyData = True
        WorkListGrid.ExportSettings.HideStructureColumns = True
        WorkListGrid.ExportSettings.UseItemStyles = True
        WorkListGrid.ExportSettings.FileName = "Worklist_" + DateTime.UtcNow.AddMinutes(-offsetMinutes).ToString("yyyy-MM-dd HH-mm-ss")
        WorkListGrid.ExportSettings.OpenInNewWindow = True
        WorkListGrid.MasterTableView.Columns.FindByUniqueName("ArrowColumn").Visible = False
        WorkListGrid.MasterTableView.Columns.FindByUniqueName("Alerts").Visible = False
        WorkListGrid.MasterTableView.Columns.FindByUniqueName("AlertText").Visible = True
        WorkListGrid.MasterTableView.Columns.FindByUniqueName("Notes").Visible = False
        WorkListGrid.MasterTableView.Columns.FindByUniqueName("NoteText").Visible = True
        WorkListGrid.MasterTableView.ExportToExcel()
    End Sub

    Protected Sub ViewAllCheckbox_CheckedChanged(sender As Object, e As EventArgs)
        WorkListGrid.Rebind()
    End Sub

    Private Sub Worklist_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender

        Dim headerText = WorkListGrid.MasterTableView.GetColumn("NHSNo").HeaderText

        If headerText = "NHS No" Then
            WorkListGrid.MasterTableView.GetColumn("NHSNo").HeaderText = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " No"
            WorkListGrid.MasterTableView.Rebind()
        End If
    End Sub
#End Region

End Class