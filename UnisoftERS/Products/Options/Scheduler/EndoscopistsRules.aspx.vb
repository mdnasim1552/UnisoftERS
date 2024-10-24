Imports System.Drawing
Imports ERS.Data
Imports Telerik.Web.UI
Partial Class products_options_scheduler_EndoscopistsRules
    Inherits OptionsBase

#Region "Web methods"
    <System.Web.Services.WebMethod>
    Public Shared Sub SetPageUpdated()
        Dim ctx As HttpContext = System.Web.HttpContext.Current
        ctx.Session("Page_Updated") = True
    End Sub
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(rptProcedureTypes, rptProcedureTypes, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(ConsultantComboBox, rptProcedureTypes, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(CancelRadButton, rptProcedureTypes)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(CancelRadButton, CancelRadButton)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveRadButton, SaveRadButton)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveRadButton, RadNotification1)

        If Not IsPostBack Then
            Session("Page_Updated") = False
            If Me.Master IsNot Nothing Then
                Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                If leftPane IsNot Nothing Then leftPane.Visible = False
                If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
            End If

            InitForm()
        End If
    End Sub

    Private Sub InitForm()
        ConsultantComboBox.DataSource = DataAdapter_Sch.GetEndoscopists(True)
        ConsultantComboBox.DataBind()

        Session("SelectedEndoscopistId") = ConsultantComboBox.SelectedValue
        Session("ProcedureTypeCount") = Nothing
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest1(sender As Object, e As AjaxRequestEventArgs)

    End Sub

    Protected Sub rptProcedureTypes_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        'clear any previously created sessions (this gets created in the therapeutic types window on save and close
        If e.Item.DataItem IsNot Nothing Then
            Dim dataRow = DirectCast(e.Item.DataItem, DataRowView)
            Dim procTypeID = dataRow.Row("ProcedureTypeID")
            Session("TherapeuticTypes_" & procTypeID) = Nothing
            'Maintain count of number of ProcedureTypes
            Dim rowCount As Integer = 0
            If Session("ProcedureTypeCount") IsNot Nothing Then
                rowCount = CInt(Session("ProcedureTypeCount"))
                rowCount += 1
            Else
                rowCount = 1
            End If
            Session("ProcedureTypeCount") = rowCount

            If dataRow("SchedulerDiagnostic") Then
                CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Visible = True
                CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Checked = False
            Else
                CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Visible = False
                CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Checked = False
            End If

            If dataRow("SchedulerTherapeutic") Then
                CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Visible = True
                CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = False
                CType(e.Item.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = False
            Else
                CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Visible = False
                CType(e.Item.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = False
            End If

            'set client events
            If CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Visible Then
                CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Attributes.Add("onclick", "procedure_changed()")
            End If

            If CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Visible Then
                CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Attributes.Add("onclick", "procedure_changed()")
            End If


            'Get Selected Endocopists selected items as defined in table ERS_ConsultantProcedureTypes
            Dim da As New DataAccess_Sch
            Dim dt As New DataTable()
            Dim EndoscopistId As Integer
            If Not String.IsNullOrWhiteSpace(Session("SelectedEndoscopistId")) Then
                EndoscopistId = CInt(Session("SelectedEndoscopistId"))
                dt = da.GetEndoscopistProcedures(EndoscopistId)
                For Each row As DataRow In dt.Rows
                    If row("ProcedureTypeID") = dataRow.Row("ProcedureTypeID") Then
                        If row("SchedulerDiagnostic") Then
                            CType(e.Item.FindControl("DiagnosticProcedureTypesCheckbox"), CheckBox).Checked = True
                        End If
                        If row("SchedulerTherapeutic") Then
                            CType(e.Item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = True
                            CType(e.Item.FindControl("DefineTherapeuticProcedureButton"), Button).Enabled = True
                        End If
                        Exit For
                    End If
                Next
            End If
        End If

    End Sub

    Protected Sub ConsultantComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles ConsultantComboBox.SelectedIndexChanged
        If e.Value IsNot Nothing Then
            If Not String.IsNullOrWhiteSpace(Session("Page_Updated")) AndAlso CBool(Session("Page_Updated")) = True Then
                Try
                    SaveData()
                    Session("Page_Updated") = False
                Catch ex As Exception
                    Dim errorLogRef As String
                    errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Endoscopist Rules.", ex)
                    Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
                    RadNotification1.Show()
                End Try
            End If
            Session("SelectedEndoscopistId") = e.Value
            rptProcedureTypes.DataBind()
            clearTherapeuticsSession()

        End If
    End Sub

    Protected Sub SaveRadButton_Click(sender As Object, e As EventArgs) Handles SaveRadButton.Click
        Try
            SaveData()
            rptProcedureTypes.DataBind()
            Utilities.SetNotificationStyle(RadNotification1, "Settings saved successfully.")
            RadNotification1.Show()
            clearTherapeuticsSession()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Endoscopist Rules.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

    End Sub

    Private Sub clearTherapeuticsSession()
        For Each item As RepeaterItem In rptProcedureTypes.Items
            Dim procedureTypeId As Integer = CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value
            Session("TherapeuticTypes_" & procedureTypeId.ToString()) = Nothing
        Next
    End Sub

    Private Sub SaveData()
        Try
            'Save changes to ProcedureTypes for selected endoscopist
            Dim EndoscopistId As Integer

            EndoscopistId = Session("SelectedEndoscopistId")
            Using db As New ERS.Data.GastroDbEntities
                For Each item As RepeaterItem In rptProcedureTypes.Items
                    Dim procedureTypeId As Integer = CType(item.FindControl("ProcedureTypeIDHiddenField"), HiddenField).Value
                    Dim type As String = CType(item.FindControl("ProcedureTypeHiddenField"), HiddenField).Value
                    Dim Diagnostic As Boolean
                    Dim Therapeutic As Boolean

                    If CType(item.FindControl("TherapeuticProcedureTypesCheckBox"), CheckBox).Checked = True Then
                        Therapeutic = True
                        Dim lst As List(Of Integer) = Session("TherapeuticTypes_" & procedureTypeId.ToString())
                        If lst Is Nothing Then
                            lst = New List(Of Integer)
                            'get from the DB- window was not opened and/or saved so nothing is in session
                            Dim dt As New DataTable()
                            dt = DataAdapter_Sch.GetTherapeuticProcedures(procedureTypeId, EndoscopistId)
                            For Each row In dt.Rows
                                lst.Add(row("TherapeuticTypeId"))
                            Next
                            Session("TherapeuticTypes_" & procedureTypeId.ToString()) = lst
                        End If
                    Else
                        Therapeutic = False
                        Session("TherapeuticTypes_" & procedureTypeId.ToString()) = Nothing
                    End If

                    If CType(item.FindControl("DiagnosticProcedureTypesCheckBox"), CheckBox).Checked = True Then
                        Diagnostic = True
                    Else
                        Diagnostic = False
                    End If

                    Dim consultantProcedures = db.ERS_ConsultantProcedureTypes.Where(Function(x) x.ProcedureTypeID = procedureTypeId And x.EndoscopistID = EndoscopistId).FirstOrDefault
                    If consultantProcedures IsNot Nothing Then
                        Dim theraps = db.ERS_ConsultantProcedureTherapeutics.Where(Function(x) x.ConsultantProcedureID = consultantProcedures.ConsultantProcedureId)
                        If theraps.Count > 0 Then
                            db.ERS_ConsultantProcedureTherapeutics.RemoveRange(theraps)
                        End If

                        db.ERS_ConsultantProcedureTypes.Remove(consultantProcedures)
                        db.SaveChanges()
                    End If

                    If Diagnostic Or Therapeutic Then
                        Dim tblConsultantProcedures As New ERS_ConsultantProcedureTypes
                        With tblConsultantProcedures
                            .EndoscopistID = EndoscopistId
                            .ProcedureTypeID = procedureTypeId
                            .Diagnostic = Diagnostic
                            .Therapeutic = Therapeutic
                            .WhoCreatedId = CInt(Session("PKUserId"))
                            .WhenCreated = Now
                        End With
                        db.ERS_ConsultantProcedureTypes.Add(tblConsultantProcedures)
                        db.SaveChanges()

                        If Therapeutic Then
                            Dim lst As List(Of Integer) = Session("TherapeuticTypes_" & procedureTypeId.ToString())
                            If lst IsNot Nothing Then
                                For Each l In lst
                                    Dim tblConsultantTherap As New ERS_ConsultantProcedureTherapeutics
                                    With tblConsultantTherap
                                        .ConsultantProcedureID = tblConsultantProcedures.ConsultantProcedureId
                                        .TherapeuticTypeID = l
                                        .WhoCreatedId = CInt(Session("PKUserId"))
                                        .WhenCreated = Now
                                    End With
                                    db.ERS_ConsultantProcedureTherapeutics.Add(tblConsultantTherap)
                                Next
                                db.SaveChanges()
                            End If
                        End If
                    End If
                Next
            End Using
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Private Sub SaveConsultantProcedureTypes(procedureTypeId As Integer, Diagnostic As Boolean, Therapeutic As Boolean, EndoscopistId As Integer)
        Dim da As New DataAccess_Sch
        da.InsertUpdateConsultantProcedureTypes(ID, Diagnostic, Therapeutic, EndoscopistId)
    End Sub

    Private Sub SaveConsultantTherapeuticProcedures(ProcedureId As Integer, EndoscopistId As Integer)
        Dim da As New DataAccess_Sch
        Dim ListItems As New List(Of Integer)

        If Session("TherapeuticTypes_" & ProcedureId.ToString()) IsNot Nothing Then
            ListItems = Session("TherapeuticTypes_" & ProcedureId.ToString())

            If da.UpdateConsultantTherapeuticProceduresTypes(ListItems, EndoscopistId, ProcedureId) Then
                Session("TherapeuticTypes_" & ProcedureId.ToString()) = Nothing
                'Session("SelectedEndoscopistId") = Nothing
            End If
        End If
    End Sub

    Private Sub RemoveTherapeuticProcedures(ProcedureId As Integer, EndoscopistId As Integer)
        Dim da As New DataAccess_Sch

        If da.RemoveExistingTherapeuticTypes(EndoscopistId, ProcedureId) Then
            Session("TherapeuticTypes_" & ProcedureId.ToString()) = Nothing
        End If

    End Sub

    Protected Sub CancelRadButton_Click(sender As Object, e As EventArgs) Handles CancelRadButton.Click

        'Clear all Session values for Therapeutic Types
        If Session("ProcedureTypeCount") IsNot Nothing Then
            For index = 1 To CInt(Session("ProcedureTypeCount"))
                Session("TherapeuticTypes_" & index.ToString()) = Nothing
                'Session("SelectedEndoscopistId") = Nothing
            Next
        End If
        Session("ProcedureTypeCount") = Nothing
        rptProcedureTypes.DataBind()

    End Sub
End Class