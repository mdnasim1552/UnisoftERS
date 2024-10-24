Imports Telerik.Web.UI

Public Class PointMappings
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        myAjaxMgr.UpdatePanelsRenderMode = UpdatePanelRenderMode.Inline
        myAjaxMgr.AjaxSettings.AddAjaxSetting(myAjaxMgr, PointMappingsRadGrid, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(PointMappingsRadGrid, PointMappingsRadGrid, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(NonGIPointMappingsRadGrid, NonGIPointMappingsRadGrid, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(TrainingPointMappingsRadGrid, TrainingPointMappingsRadGrid, RadAjaxLoadingPanel1)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(HospitalsComboBox, PointMappingsRadGrid)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(HospitalsComboBox, NonGIPointMappingsRadGrid)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(HospitalsComboBox, TrainingPointMappingsRadGrid)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(HospitalsComboBox, DefaultSlotLengthRadNumericTextBox)

        'myAjaxMgr.AjaxSettings.AddAjaxSetting(AddNewItemSaveRadButton, PointMappingsRadGrid, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(AddNewItemSaveRadButton, NonGIPointMappingsRadGrid, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(AddNewItemSaveRadButton, TrainingPointMappingsRadGrid, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(AddNewItemCancelRadButton, PointMappingsRadGrid)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(AddNewItemSaveRadButtonNonGI, NonGIPointMappingsRadGrid, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(AddNewItemCancelRadButtonNonGI, PointMappingsRadGrid)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveDefaultSlotLengthRadButton, DefaultSlotLengthRadNumericTextBox, Nothing, UpdatePanelRenderMode.Inline)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveDefaultTrainingSlotLengthRadButton, DefaultTrainingSlotLengthRadNumericTextBox, Nothing, UpdatePanelRenderMode.Inline)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveDefaultNonGISlotLengthRadButton, DefaultNonGISlotLengthRadNumericTextBox, Nothing, UpdatePanelRenderMode.Inline)

        If Not Page.IsPostBack Then
            Try

                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalsComboBox, ""}}, DataAdapter.GetOperatingHospitals(), "HospitalName", "OperatingHospitalId")
                getDefaultSlotLengths()

                If Me.Master IsNot Nothing Then
                    Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                    Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                    If leftPane IsNot Nothing Then leftPane.Visible = False
                    If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
                End If
            Catch ex As Exception

            End Try
        End If

    End Sub

    Protected Sub PointMappingsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles PointMappingsRadGrid.ItemCreated
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return editMapping('{0}','{1}','{2}','{3}','{4}','{5}');",
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("PointsMappingId"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ProcedureType"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiagnosticMinutes"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiagnosticPoints"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("TherapeuticMinutes"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("TherapeuticPoints"))
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading PointMappingsRadGrid_ItemCreated", ex)
        End Try
    End Sub

    Protected Sub TrainingPointMappingsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles TrainingPointMappingsRadGrid.ItemCreated
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return editMappingTraining('{0}','{1}','{2}','{3}','{4}','{5}');",
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("PointsMappingId"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ProcedureType"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiagnosticMinutes"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiagnosticPoints"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("TherapeuticMinutes"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("TherapeuticPoints"))
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading TrainingPointMappingsRadGrid_ItemCreated", ex)
        End Try
    End Sub

    Protected Sub NonGIPointMappingsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles NonGIPointMappingsRadGrid.ItemCreated
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return editMappingNonGI('{0}','{1}','{2}','{3}');",
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("PointsMappingId"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ProcedureType"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiagnosticMinutes"),
                        e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiagnosticPoints"))
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading NonGIPointMappingsRadGrid_ItemCreated", ex)
        End Try
    End Sub

    Protected Sub AddNewItemSaveRadButton_Click(sender As Object, e As EventArgs)
        Try
            If CType(sender, RadButton).CommandName.ToLower = "savenongimappings" Then
                Using db As New ERS.Data.GastroDbEntities

                    If String.IsNullOrWhiteSpace(PointsMappingIDHiddenFieldNonGI.Value) Then

                        If Not db.ERS_ProcedureTypes.Any(Function(x) (x.ProcedureType = NonGIProcedureTypeRadTextBox.Text And x.OperatingHospitalId = HospitalsComboBox.SelectedValue)) Then

                            Dim newProcType As Integer = DataAdapter.AddNonGIProcedureType(NonGIProcedureTypeRadTextBox.Text, HospitalsComboBox.SelectedValue)

                            Dim dbRecord = New ERS.Data.ERS_SCH_PointMappings
                            With dbRecord
                                .ProceduretypeId = newProcType
                                If (DiagnosticPointsRadTextBoxNonGI.Text = "") Then
                                    .Points = Convert.ToDecimal("0.0")
                                Else
                                    .Points = Convert.ToDecimal(DiagnosticPointsRadTextBoxNonGI.Text)
                                End If

                                If (DiagnosticMinutesRadTextBoxNonGI.Text = "") Then
                                    .Minutes = 0
                                Else
                                    .Minutes = Convert.ToInt32(DiagnosticMinutesRadTextBoxNonGI.Text)
                                End If


                                .OperatingHospitalId = HospitalsComboBox.SelectedValue
                                .NonGI = 1
                                .Training = 0
                                .WhoCreatedId = Session("PKUserID")
                                .WhenCreated = Now()
                            End With

                            db.ERS_SCH_PointMappings.Add(dbRecord)
                        Else
                            Utilities.SetNotificationStyle(RadNotification1, "Procedure type " & NonGIProcedureTypeRadTextBox.Text & " already exists.", True)
                            RadNotification1.Show()
                        End If
                    Else

                        Dim dbRecord = db.ERS_SCH_PointMappings.Where(Function(x) x.PointsMappingId = PointsMappingIDHiddenFieldNonGI.Value).FirstOrDefault

                        With dbRecord
                            If (DiagnosticPointsRadTextBoxNonGI.Text = "") Then
                                .Points = Convert.ToDecimal("0.0")
                            Else
                                .Points = Convert.ToDecimal(DiagnosticPointsRadTextBoxNonGI.Text)
                            End If

                            .Minutes = IIf(DiagnosticMinutesRadTextBoxNonGI.Text = "", 0, DiagnosticMinutesRadTextBoxNonGI.Text)

                            .OperatingHospitalId = HospitalsComboBox.SelectedValue
                        End With

                        db.ERS_SCH_PointMappings.Attach(dbRecord)
                        db.Entry(dbRecord).State = Entity.EntityState.Modified

                    End If

                    db.SaveChanges()
                End Using
            ElseIf CType(sender, RadButton).CommandName.ToLower = "savegimappings" Then
                Using db As New ERS.Data.GastroDbEntities
                    Dim dbRecord = db.ERS_SCH_PointMappings.Where(Function(x) x.PointsMappingId = PointsMappingIDHiddenField.Value).FirstOrDefault
                    If DiagnosticPointsRadTextBox.Text = "" Then
                        DiagnosticPointsRadTextBox.Text = "0.0"
                    End If
                    If dbRecord IsNot Nothing Then
                        With dbRecord
                            '08 Jun 2022 - MH commented and changed like below
                            '.Points = IIf(DiagnosticPointsRadTextBox.Text <> "0.0", Convert.ToDecimal(DiagnosticPointsRadTextBox.Text), DiagnosticPointsRadTextBox.Text)
                            .Points = IIf(DiagnosticPointsRadTextBox.Text = "", 0.0, Convert.ToDecimal(DiagnosticPointsRadTextBox.Text))
                            .Minutes = IIf(DiagnosticMinutesRadTextBox.Text = "", 0, DiagnosticMinutesRadTextBox.Text)
                            .OperatingHospitalId = HospitalsComboBox.SelectedValue
                            .NonGI = 0
                            .Training = 0

                            If DiagnosticPointsRadTextBox.Text = "" Then
                                .Points = Convert.ToDecimal("0.0")
                            Else
                                .Points = Convert.ToDecimal(DiagnosticPointsRadTextBox.Text)
                            End If

                            .TherapeuticMinutes = IIf(TherapeuticMinutesRadTextBox.Text = "", 0, TherapeuticMinutesRadTextBox.Text)
                            .TherapeuticPoints = IIf(TherapeuticPointsRadTextBox.Text = "", Convert.ToDecimal("0.0"), Convert.ToDecimal(TherapeuticPointsRadTextBox.Text))
                        End With

                        db.ERS_SCH_PointMappings.Attach(dbRecord)
                        db.Entry(dbRecord).State = Entity.EntityState.Modified
                    End If

                    db.SaveChanges()
                End Using
            ElseIf CType(sender, RadButton).CommandName.ToLower = "savegimappingstraining" Then
                Using db As New ERS.Data.GastroDbEntities
                    Dim dbRecord = db.ERS_SCH_PointMappings.Where(Function(x) x.PointsMappingId = PointsMappingIDHiddenField.Value).FirstOrDefault
                    If DiagnosticPointsRadTextBox.Text = "" Then
                        DiagnosticPointsRadTextBox.Text = "0.0"
                    End If
                    If dbRecord IsNot Nothing Then
                        With dbRecord
                            '08 Jun 2022 - MH commented out and changed like below
                            '.Points = IIf(DiagnosticPointsRadTextBox.Text <> "0.0", Convert.ToDecimal(DiagnosticPointsRadTextBox.Text), DiagnosticPointsRadTextBox.Text)
                            .Points = IIf(DiagnosticPointsRadTextBox.Text = "", 0.0, Convert.ToDecimal(DiagnosticPointsRadTextBox.Text))
                            .Minutes = IIf(DiagnosticMinutesRadTextBox.Text = "", 0, DiagnosticMinutesRadTextBox.Text)
                            .OperatingHospitalId = HospitalsComboBox.SelectedValue
                            .NonGI = 0
                            .Training = 1
                            If (TherapeuticPointsRadTextBox.Text = "") Then
                                .TherapeuticPoints = Convert.ToDecimal("0.0")
                            Else
                                .TherapeuticPoints = Convert.ToDecimal(TherapeuticPointsRadTextBox.Text)
                            End If

                            .TherapeuticMinutes = IIf(TherapeuticMinutesRadTextBox.Text = "", 0, TherapeuticMinutesRadTextBox.Text)
                            .TherapeuticPoints = IIf(TherapeuticPointsRadTextBox.Text = "", 0, Convert.ToDecimal(TherapeuticPointsRadTextBox.Text))
                        End With

                        db.ERS_SCH_PointMappings.Attach(dbRecord)
                        db.Entry(dbRecord).State = Entity.EntityState.Modified
                    End If

                    db.SaveChanges()
                End Using
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred on points mappings page.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try

        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_Close", "closeAddItemWindow();", True)
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_Close2", "closeAddItemWindowNonGI();", True)

        PointMappingsRadGrid.MasterTableView.SortExpressions.Clear()
        TrainingPointMappingsRadGrid.MasterTableView.SortExpressions.Clear()
        NonGIPointMappingsRadGrid.MasterTableView.SortExpressions.Clear()

        PointMappingsRadGrid.Rebind()
        TrainingPointMappingsRadGrid.Rebind()
        NonGIPointMappingsRadGrid.Rebind()

    End Sub

    Protected Sub PointMappingsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try

            If e.Item.DataItem IsNot Nothing Then
                Dim diagnosticPoints = Convert.ToDecimal(DirectCast(e.Item.DataItem, DataRowView).Row("DiagnosticPoints"))
                Dim therapeuticPoints = Convert.ToDecimal(DirectCast(e.Item.DataItem, DataRowView).Row("TherapeuticPoints"))
                Dim lblDiagnosticPoints = CType(e.Item.FindControl("GridDiagnosticPointsLabel"), Label)
                Dim lblDiagnosticMinutes = CType(e.Item.FindControl("GridDiagnosticMinutesLabel"), Label)
                Dim lblTherapeuticPoints = CType(e.Item.FindControl("GridTherapeuticPointsLabel"), Label)
                If lblDiagnosticPoints IsNot Nothing Then
                    If e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ProcedureType") <> "ERCP" Then
                        lblDiagnosticPoints.Text = If(diagnosticPoints Mod 1 = 0, CInt(diagnosticPoints), diagnosticPoints)
                    Else
                        lblDiagnosticPoints.Text = "n/a"
                    End If
                End If

                If lblDiagnosticMinutes IsNot Nothing Then
                    If e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ProcedureType") = "ERCP" Then
                        lblDiagnosticMinutes.Text = "n/a"
                    End If
                End If

                If lblTherapeuticPoints IsNot Nothing Then lblTherapeuticPoints.Text = If(therapeuticPoints Mod 1 = 0, CInt(therapeuticPoints), therapeuticPoints)
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in PointMappingsRadGrid_ItemDataBound.", ex)
        End Try
    End Sub

    Protected Sub TrainingPointMappingsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try

            If e.Item.DataItem IsNot Nothing Then
                Dim trainingDiagnosticPoints = Convert.ToDecimal(DirectCast(e.Item.DataItem, DataRowView).Row("DiagnosticPoints"))
                Dim trainingTherapeuticPoints = Convert.ToDecimal(DirectCast(e.Item.DataItem, DataRowView).Row("TherapeuticPoints"))
                Dim lblTrainingDiagnosticPoints = CType(e.Item.FindControl("GridDiagnosticPointsLabel"), Label)
                Dim lblTrainingDiagnosticMinutes = CType(e.Item.FindControl("GridDiagnosticMinutesLabel"), Label)
                Dim lblTrainingTherapeuticPoints = CType(e.Item.FindControl("GridTherapeuticPointsLabel"), Label)
                If lblTrainingDiagnosticPoints IsNot Nothing Then
                    If e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ProcedureType") <> "ERCP" Then
                        lblTrainingDiagnosticPoints.Text = If(trainingDiagnosticPoints Mod 1 = 0, CInt(trainingDiagnosticPoints), trainingDiagnosticPoints)
                    Else
                        lblTrainingDiagnosticPoints.Text = "n/a"
                    End If
                End If

                If lblTrainingDiagnosticMinutes IsNot Nothing Then
                    If e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ProcedureType") = "ERCP" Then
                        lblTrainingDiagnosticMinutes.Text = "n/a"
                    End If
                End If

                If lblTrainingTherapeuticPoints IsNot Nothing Then lblTrainingTherapeuticPoints.Text = If(trainingTherapeuticPoints Mod 1 = 0, CInt(trainingTherapeuticPoints), trainingTherapeuticPoints)
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in TrainingPointMappingsRadGrid_ItemDataBound.", ex)
        End Try
    End Sub

    Protected Sub NonGIPointMappingsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try

            If e.Item.DataItem IsNot Nothing Then
                Dim diagnosticPoints = Convert.ToDecimal(DirectCast(e.Item.DataItem, DataRowView).Row("DiagnosticPoints"))
                'Dim therapeuticPoints = Convert.ToDecimal(DirectCast(e.Item.DataItem, DataRowView).Row("TherapeuticPoints"))
                Dim lblDiagnosticPoints = CType(e.Item.FindControl("GridDiagnosticPointsLabel"), Label)
                'Dim lblTherapeuticPoints = CType(e.Item.FindControl("GridTherapeuticPointsLabel"), Label)
                If lblDiagnosticPoints IsNot Nothing Then lblDiagnosticPoints.Text = If(diagnosticPoints Mod 1 = 0, CInt(diagnosticPoints), diagnosticPoints)
                'If lblTherapeuticPoints IsNot Nothing Then lblTherapeuticPoints.Text = If(therapeuticPoints Mod 1 = 0, CInt(therapeuticPoints), therapeuticPoints)
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in NonGIPointMappingsRadGrid_ItemDataBound.", ex)
        End Try
    End Sub

    Protected Sub SaveDefaultSlotLengthRadButton_Click(sender As Object, e As EventArgs) Handles SaveDefaultSlotLengthRadButton.Click, SaveDefaultTrainingSlotLengthRadButton.Click, SaveDefaultNonGISlotLengthRadButton.Click
        Try
            Dim defaultSlotMinutes = 0
            Select Case RadTabStrip1.SelectedIndex
                Case 0
                    defaultSlotMinutes = DefaultSlotLengthRadNumericTextBox.Value
                Case 1
                    defaultSlotMinutes = DefaultTrainingSlotLengthRadNumericTextBox.Value
                Case 2
                    defaultSlotMinutes = DefaultNonGISlotLengthRadNumericTextBox.Value
            End Select

            DataAdapter_Sch.UpdateDefaultSlotLength(HospitalsComboBox.SelectedValue, defaultSlotMinutes, (RadTabStrip1.SelectedIndex = 1), (RadTabStrip1.SelectedIndex = 2))
            Utilities.SetNotificationStyle(RadNotification1, "Default slot length saved.")
            RadNotification1.Show()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred on points mappings page.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving your default slot length.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub HospitalsComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            getDefaultSlotLengths()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred on points mappings page.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There was a problem populating your data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveDefaultTrainingSlotLengthRadButton_Click(sender As Object, e As EventArgs)

    End Sub

    Protected Sub SaveDefaultNonGISlotLengthRadButton_Click(sender As Object, e As EventArgs)

    End Sub

    Private Sub getDefaultSlotLengths()
        DefaultSlotLengthRadNumericTextBox.Value = DataAdapter_Sch.getDefaultSlotLength(CInt(HospitalsComboBox.SelectedValue), 0, 0)
        DefaultTrainingSlotLengthRadNumericTextBox.Value = DataAdapter_Sch.getDefaultSlotLength(CInt(HospitalsComboBox.SelectedValue), 1, 0)
        DefaultNonGISlotLengthRadNumericTextBox.Value = DataAdapter_Sch.getDefaultSlotLength(CInt(HospitalsComboBox.SelectedValue), 0, 1)
    End Sub

End Class