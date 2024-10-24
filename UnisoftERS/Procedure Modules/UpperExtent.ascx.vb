'Imports Azure.Storage.Blobs.Models
'Imports DevExpress.Spreadsheet
Imports Telerik.Web.UI

Public Class UpperExtent
    Inherits ProcedureControls

    Public Event Extent_ToggleLimited(isLimited As Boolean)

    Public Shared procType As Integer
    Public Shared endoscopipstId As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            'bindExtentRepeater()
            bindExtentRepeater()
            If Not procType = ProcedureType.Gastroscopy AndAlso Not procType = ProcedureType.EUS_OGD AndAlso Not procType = ProcedureType.Transnasal Then
                MucosalJunctionDistanceTR.Visible = False
            End If
            If procType = ProcedureType.ERCP Then
                levelOfComplexity.Visible = True
                loadLevelOfComplexity()
            End If
        End If
        'bindExtentRepeater()
    End Sub

    Public Structure ProcedureExtent
        Property EndoscopistName As String
        Property EndoscopistId As Integer
        Property MucosalJunctionDistance As Integer
        Property JManoeuverId As Integer
        Property ExtentId As Integer
        Property ExtentFailedReason As String
        Property LimitedById As Integer
        Property WithdrawalMinutes As Integer
        Property TraineeTrainer As String 'Added by rony tfs-3761
    End Structure


    'Public HideExtendLimited As Boolean

    'Public Sub ShowOrHideExtentLimitedBy()

    '    bindExtentRepeater()

    'End Sub
    'Public Sub PlannedShowOrHideExtentLimitedBy()

    '    bindExtentRepeater(0)

    'End Sub
    Private Sub bindExtentRepeater()
        Try
            Dim endoExtents As New List(Of ProcedureExtent)
            Dim procedureEndoscopists = DataAdapter.getProcedureEndoscopists(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            Dim extentOptions = DataAdapter.LoadExtent(procType)
            Dim procedureExtent = DataAdapter.getProcedureUpperExtent(Session(Constants.SESSION_PROCEDURE_ID))


            For Each endo In procedureEndoscopists.Rows
                Dim endoExtent As New ProcedureExtent
                With endoExtent
                    .EndoscopistId = CInt(endo("EndoscopistId"))
                    .EndoscopistName = endo("EndoscopistName")
                    .TraineeTrainer = endo("TraineeTrainer").ToString() 'Added by rony tfs-3761
                    If procedureExtent.AsEnumerable.Any(Function(x) x("EndoscopistId") = CInt(endo("EndoscopistId"))) Then
                        Dim dr = procedureExtent.AsEnumerable.Where(Function(x) x("EndoscopistId") = CInt(endo("EndoscopistId"))).FirstOrDefault
                        If Not dr.IsNull("ExtentId") Then .ExtentId = CInt(dr("ExtentId"))
                        If Not dr.IsNull("MucosalJunctionDistance") Then .MucosalJunctionDistance = CInt(dr("MucosalJunctionDistance"))
                        If Not dr.IsNull("JManoeuvreId") Then .JManoeuverId = dr("JManoeuvreId")
                        If Not dr.IsNull("AdditionalInfo") Then .ExtentFailedReason = dr("AdditionalInfo")
                        If Not dr.IsNull("LimitationId") Then .LimitedById = CInt(dr("LimitationId"))
                    Else
                        .ExtentId = 0
                        .LimitedById = 0
                        .WithdrawalMinutes = 0
                        .MucosalJunctionDistance = 0
                        'insert entry to DB
                        DataAdapter.saveProcedureUpperExtent(Session(Constants.SESSION_PROCEDURE_ID), 0, "", endo("EndoscopistId"), 0, -1, 0, "")

                    End If
                End With
                'procedureExtent = DataAdapter.getProcedureUpperExtent(Session(Constants.SESSION_PROCEDURE_ID)) ' this line needed to fix under condition , do same in lower extent also 
                endoExtents.Add(endoExtent)

            Next

            rptUpperExtent.DataSource = endoExtents
            rptUpperExtent.DataBind()

            For Each itm As RepeaterItem In rptUpperExtent.Items

                Dim endoId As Integer = CType(itm.FindControl("EndoscopistIdHiddenValue"), HiddenField).Value


                Dim UpperExtentComboBox As RadComboBox = itm.FindControl("UpperExtentComboBox")
                UpperExtentComboBox.DataSource = extentOptions.AsEnumerable.Where(Function(x) Not CBool(x("AdditionalInfo"))).CopyToDataTable '-1 is for failed results
                UpperExtentComboBox.DataBind()
                UpperExtentComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
                UpperExtentComboBox.Attributes.Add("data-endoscopistid", endoId)
                'UpperExtentComboBox.Attributes.Add("data-failedoutcome", endoId)
                endoscopipstId = endoId 'By ferdowsi
                Dim InsertionLimitedRadComboBox As RadComboBox = itm.FindControl("InsertionLimitedRadComboBox")
                InsertionLimitedRadComboBox.DataSource = DataAdapter.LoadExtentLimitations(procType)
                InsertionLimitedRadComboBox.DataBind()
                InsertionLimitedRadComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
                InsertionLimitedRadComboBox.Attributes.Add("data-endoscopistid", endoId)



                'Dim dataSource As DataTable = DirectCast(InsertionLimitedRadComboBox.DataSource, DataTable)
                Dim JManoeuvreRadComboBox As RadComboBox = itm.FindControl("JManoeuvreRadComboBox")
                JManoeuvreRadComboBox.Attributes.Add("data-endoscopistid", endoId)

                If procType = ProcedureType.ERCP Or procType = ProcedureType.EUS_OGD Or procType = ProcedureType.EUS_HPB Then  ' Added by Ferdowsi, TFS 4076

                    Dim JManoeuvreTR As HtmlTableRow = itm.FindControl("JManoeuvreTR")
                    If JManoeuvreTR IsNot Nothing Then JManoeuvreTR.Visible = False
                End If

                Dim FailedOtherTextBox As TextBox = itm.FindControl("FailedOtherTextBox")
                FailedOtherTextBox.Attributes.Add("data-endoscopistid", endoId)

                Dim OtherLimitationTextBox As TextBox = itm.FindControl("OtherLimitationTextBox")
                OtherLimitationTextBox.Attributes.Add("data-endoscopistid", endoId)

                If procedureExtent.Rows.Count > 0 Then
                    If Not procedureExtent.AsEnumerable.Any(Function(x) x("EndoscopistId") = endoId) Then Continue For
                    Dim dr = procedureExtent.AsEnumerable.Where(Function(x) x("EndoscopistId") = endoId).CopyToDataTable.Rows(0)
                    If Not dr.IsNull("ExtentId") Then UpperExtentComboBox.SelectedIndex = UpperExtentComboBox.FindItemIndexByValue(dr("ExtentId"))
                    'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "sethideextent", "$('.lower-extent-options').show();", True)

                    'Dim OtherLimitationTR As HtmlTableRow = TryCast(itm.FindControl("OtherLimitationTR"), HtmlTableRow)
                    'added 
                    If Not dr.IsNull("LimitationId") Then InsertionLimitedRadComboBox.SelectedIndex = InsertionLimitedRadComboBox.FindItemIndexByValue(dr("LimitationId"))
                    If Not dr.IsNull("MucosalJunctionDistance") Then MucosalJunctionDistanceRadNumericTextBox.Value = CInt(dr("MucosalJunctionDistance"))
                    If Not dr.IsNull("AdditionalInfo") Then FailedOtherTextBox.Text = dr("AdditionalInfo").ToString()
                    If Not dr.IsNull("LimitationOther") Then OtherLimitationTextBox.Text = dr("LimitationOther").ToString()
                    'added  done
                    If Not dr.IsNull("JManoeuvreId") Then JManoeuvreRadComboBox.SelectedIndex = JManoeuvreRadComboBox.FindItemIndexByValue(dr("JManoeuvreId"))
                    '         If Not dr.IsNull("LimitationId") Then
                    '    InsertionLimitedRadComboBox.SelectedIndex = InsertionLimitedRadComboBox.FindItemIndexByValue(dr("LimitationId"))
                    'End If '

                    'Dim LimitationTR As HtmlTableRow = TryCast(itm.FindControl("LimitationTR"), HtmlTableRow)

                    '    If CInt(dr("ListOrderBy") >= PlannedExtent.PlannedExtentIdValue) Then
                    '        LimitationTR.Visible = False
                    '        OtherLimitationTR.Visible = False
                    '    Else
                    '        LimitationTR.Visible = True
                    '        OtherLimitationTR.Visible = False
                    '    End If

                    '    If Not dr.IsNull("WithdrawalMins") Then
                    '        TimeForWithdrawalMinRadNumericTextBox.Value = CInt(dr("WithdrawalMins"))
                    '    Else
                    '        TimeForWithdrawalMinRadNumericTextBox.Value = Nothing
                    '    End If
                    '    If Not dr.IsNull("MucosalJunctionDistance") Then
                    '        MucosalJunctionDistanceRadNumericTextBox.Value = CInt(dr("MucosalJunctionDistance"))
                    '    Else
                    '        MucosalJunctionDistanceRadNumericTextBox.Value = Nothing
                    '    End If

                    '    If Not dr.IsNull("AdditionalInfo") Then FailedOtherTextBox.Text = dr("AdditionalInfo").ToString()
                    '    If Not dr.IsNull("LimitationOther") Then
                    '        OtherLimitationTextBox.Text = dr("LimitationOther").ToString()
                    '    End If

                    '    Dim selectedItem As RadComboBoxItem = InsertionLimitedRadComboBox.SelectedItem
                    '    If selectedItem IsNot Nothing AndAlso selectedItem.Text = "Other" Then
                    '        OtherLimitationTR.Visible = True
                    '    Else
                    '        OtherLimitationTR.Visible = False
                    '    End If

                    '    Dim FailedTR As HtmlTableRow = TryCast(itm.FindControl("FailedExtentTR"), HtmlTableRow)

                    '    Dim selectedvalue As RadComboBoxItem = UpperExtentComboBox.SelectedItem
                    '    If selectedvalue IsNot Nothing AndAlso (selectedvalue.Text = "Abandoned" Or selectedvalue.Text = "Intubation failed") Then
                    '        FailedTR.Visible = True
                    '    End If



                End If
            Next

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error binding upper extent data", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading your data")
            RadNotification1.Show()
        End Try
    End Sub





    'Private Sub bindExtent()
    '    Try
    '        Dim procedureEndoscopists = DataAdapter.getProcedureEndoscopists(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
    '        'EndoscopistRadioButtonList.DataSource = procedureEndoscopists
    '        'EndoscopistRadioButtonList.DataBind()
    '        'EndoscopistRadioButtonList.SelectedIndex = 0

    '        'If procedureEndoscopists.Rows.Count = 1 Then EndoscopistTR.Style.Add("display", "none")
    '        Dim extentOptions = DataAdapter.LoadExtent(procType)
    '        Dim procedureExtent = DataAdapter.getProcedureUpperExtent(Session(Constants.SESSION_PROCEDURE_ID))

    '        UpperExtentComboBox.DataSource = extentOptions.AsEnumerable.Where(Function(x) Not CBool(x("AdditionalInfo"))).CopyToDataTable '-1 is for failed results
    '        UpperExtentComboBox.DataBind()


    '        'FailedIntubationRadioButtonList.DataSource = extentOptions.AsEnumerable.Where(Function(x) x("ListOrderBy") = -1 Or CBool(x("AdditionalInfo"))).CopyToDataTable '-1 is for failed results
    '        'FailedIntubationRadioButtonList.DataBind()

    '        InsertionLimitedRadComboBox.DataSource = DataAdapter.LoadExtentLimitations(procType)
    '        InsertionLimitedRadComboBox.DataBind()
    '        InsertionLimitedRadComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
    '        InsertionLimitedRadComboBox.Attributes.Add("data-endoscopistid", 0)

    '        If procedureExtent.Rows.Count > 0 Then
    '            Dim dr = procedureExtent.Rows(0)
    '            UpperExtentComboBox.SelectedIndex = UpperExtentComboBox.FindItemIndexByValue(dr("ExtentId"))
    '            If Not String.IsNullOrWhiteSpace(dr("AdditionalInfo")) Then FailedOtherTextBox.Text = dr("AdditionalInfo")

    '            'If UpperExtentComboBox.FindItemIndexByValue(dr("ExtentId")) > -1 Then
    '            '    UpperExtentComboBox.SelectedIndex = UpperExtentComboBox.FindItemIndexByValue(dr("ExtentId"))
    '            'Else
    '            '    If FailedIntubationRadioButtonList.Items.FindByValue(dr("ExtentId")).Value > 0 Then
    '            '        FailedRadioButton.Checked = True
    '            '        FailedIntubationRadioButtonList.SelectedValue = dr("ExtentId")
    '            '        If Not String.IsNullOrWhiteSpace(dr("AdditionalInfo")) Then FailedOtherTextBox.Text = dr("AdditionalInfo")
    '            '    End If
    '            'End If
    '        End If
    '    Catch ex As Exception
    '        Dim ref = LogManager.LogManagerInstance.LogError("There was an error binding upper extent data", ex)
    '        Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading your data")
    '        RadNotification1.Show()
    '    End Try
    'End Sub
    'Added by ronytfs-2830 start
    Protected Sub UpperExtentRadComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim dr = CType(e.Item.DataItem, DataRowView)
            e.Item.Attributes.Add("data-upper-extent", dr("ListOrderBy").ToString)
        End If
    End Sub
    'End
    Private Sub loadLevelOfComplexity()
        Try

            Dim LevelOfComplexityDatasource = DataAdapter.LoadLevelOfComplexity()

            ComplexityRadioButtonList.DataSource = LevelOfComplexityDatasource
            ComplexityRadioButtonList.DataTextField = "Description"
            ComplexityRadioButtonList.DataValueField = "UniqueId"
            ComplexityRadioButtonList.DataBind()

            Dim ProcedureComplexity = DataAdapter.getProcedureLevelOfComplexity(Session(Constants.SESSION_PROCEDURE_ID))
            If ProcedureComplexity.Rows.Count > 0 Then
                ComplexityRadioButtonList.SelectedValue = ProcedureComplexity.Rows(0)("ComplexityId").ToString()
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
End Class