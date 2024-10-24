Imports Telerik.Web.UI
Public Class OrderComms
    Inherits System.Web.UI.Page
#Region "Properties"

    Private _dataAdapter As DataAccess = Nothing
    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataAdapter Is Nothing Then
                _dataAdapter = New DataAccess
            End If
            Return _dataAdapter
        End Get
    End Property

    Private _dataAdapter_Sch As DataAccess_Sch = Nothing
    Protected ReadOnly Property DataAdapter_Sch() As DataAccess_Sch
        Get
            If _dataAdapter_Sch Is Nothing Then
                _dataAdapter_Sch = New DataAccess_Sch
            End If
            Return _dataAdapter_Sch
        End Get
    End Property
    ReadOnly Property OperatingHospitalID As Integer
        Get
            'Need to return OperatingHospitalID from session
            'Return CInt(HospitalDropDownList.SelectedValue)
            Return 1
        End Get
    End Property
    Private Property PageSearchFields As Products_Scheduler.SearchFields
        Get
            Return Session("SearchFields")
        End Get
        Set(value As Products_Scheduler.SearchFields)
            Session("SearchFields") = value
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            LoadOrderCommsComboboxes()
            LoadOrderCommGrid()

            If OrderCommsRadGrid.MasterTableView.Columns.FindByUniqueName("OrderCommsHealthServiceNameColumn") IsNot Nothing Then
                OrderCommsRadGrid.MasterTableView.Columns.FindByUniqueName("OrderCommsHealthServiceNameColumn").HeaderText =
                    Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " No"
            End If

            For Each item As RadComboBoxItem In cboOperatingHospitals.Items
                If item.Value = OperatingHospitalID.ToString() Then
                    item.Checked = True
                    Exit For
                End If
            Next
        End If
    End Sub
    Protected Sub LoadOrderCommGrid(Optional ByVal checkedOperatingHospitalId As String = "")
        'Dim da As New DataAccess_Sch
        Dim OrdersPatients = DataAdapter_Sch().GetOrderList(OperatingHospitalID)
        If OrdersPatients.Rows.Count > 0 Then
            'OrdersRadGrid.DataSource = OrdersPatients
            'OrdersRadGrid.DataBind()
        Else
            'OrdersRadGrid.DataSource = Nothing
            'OrdersRadGrid.DataBind()
        End If
    End Sub
    Protected Sub LoadOrderCommsComboboxes()
        Try
            cboTrusts.DataSource = DataAdapter_Sch().GetSchedulerTrusts
            cboTrusts.DataValueField = "TrustId"
            cboTrusts.DataTextField = "TrustName"
            cboTrusts.DataBind()
            cboTrusts.SelectedValue = CInt(Session("TrustId"))

            cboOperatingHospitals.DataSource = DataAdapter_Sch.GetSchedulerHospitals(CInt(Session("TrustId")))
            cboOperatingHospitals.DataValueField = "OperatingHospitalId"
            cboOperatingHospitals.DataTextField = "HospitalName"
            cboOperatingHospitals.DataBind()
            cboOperatingHospitals.SelectedIndex = 0

            LoadProcedureTypeCombo()

            LoadPriorityCombo()

            LoadStatusCombo()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : LoadOrderCommsComboboxes", ex)
        End Try
    End Sub
    Protected Sub LoadStatusCombo()
        Dim dtOCStatus As New DataTable

        Dim rcbitem As New RadComboBoxItem

        cboOrderCommOrderStatus.DataSource = Nothing
        rcbitem.Value = 0
        rcbitem.Text = "-- All types --"
        cboOrderCommOrderStatus.Items.Add(rcbitem)

        dtOCStatus = DataAdapter_Sch.GetOrderCommsStatus()

        For Each drD As DataRow In dtOCStatus.Rows
            rcbitem = New RadComboBoxItem
            rcbitem.Value = Convert.ToInt32(drD("ListItemNo"))
            rcbitem.Text = drD("ListItemText").ToString()

            cboOrderCommOrderStatus.Items.Add(rcbitem)
        Next


    End Sub

    Protected Sub OrderCommsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles OrderCommsRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As ImageButton = DirectCast(e.Item.FindControl("btnViewDetail"), ImageButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return editOrderComm('{0}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("OrderId"))
        End If
    End Sub
    'Protected Sub ExportToExcelButton_Click(sender As Object, e As EventArgs)
    '    OrderCommsRadGrid.ExportSettings.Excel.Format = GridExcelExportFormat.Html
    '    OrderCommsRadGrid.ExportSettings.IgnorePaging = True
    '    OrderCommsRadGrid.ExportSettings.ExportOnlyData = True
    '    OrderCommsRadGrid.ExportSettings.HideStructureColumns = True
    '    OrderCommsRadGrid.ExportSettings.UseItemStyles = True
    '    OrderCommsRadGrid.ExportSettings.FileName = "OrderCommsPatients_" + DateTime.Now.ToString("yyyy-MM-dd HH-mm-ss")
    '    OrderCommsRadGrid.ExportSettings.OpenInNewWindow = True
    '    OrderCommsRadGrid.MasterTableView.Columns.FindByUniqueName("TemplateColumn").Visible = False
    '    OrderCommsRadGrid.MasterTableView.ExportToExcel()
    'End Sub
    Protected Sub LoadPriorityCombo()
        Dim dtslots As New DataTable
        dtslots = DataAdapter_Sch.GetSlotStatus(1, 1)
        Dim rcbitem As New RadComboBoxItem

        cboPriority.DataSource = Nothing
        rcbitem.Value = 0
        rcbitem.Text = "-- All types --"
        cboPriority.Items.Add(rcbitem)

        For Each drD As DataRow In dtslots.Rows
            rcbitem = New RadComboBoxItem
            rcbitem.Value = Convert.ToInt32(drD("StatusId"))
            rcbitem.Text = drD("Description").ToString()

            cboPriority.Items.Add(rcbitem)
        Next

    End Sub
    Protected Sub LoadProcedureTypeCombo()
        Try
            Dim dtProcedureTypes As New DataTable
            Dim rcbitem As New RadComboBoxItem

            dtProcedureTypes = DataAdapter().GetAllProcedureTypes()
            cboProcedureType.DataSource = Nothing
            rcbitem.Value = 0
            rcbitem.Text = "--All Procedure Types--"
            cboProcedureType.Items.Add(rcbitem)

            For Each drD As DataRow In dtProcedureTypes.Rows
                rcbitem = New RadComboBoxItem
                rcbitem.Value = Convert.ToInt32(drD("ProcedureTypeId"))
                rcbitem.Text = drD("ProcedureType").ToString()

                cboProcedureType.Items.Add(rcbitem)
            Next

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : LoadProcedureTypeCombo", ex)
        End Try
    End Sub
    Protected Sub HideSuppressButton_Click(sender As Object, e As EventArgs)
        'Dim iSuppress As Integer = SuppressedComboBox.SelectedIndex
        'Select Case iSuppress
        '    Case 0
        '        OrderCommsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = Nothing
        '    Case 1
        '        OrderCommsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 1
        '    Case 2
        '        OrderCommsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 0
        'End Select
        OrderCommsRadGrid.DataBind()
    End Sub

    Protected Sub cboTrusts_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles cboTrusts.SelectedIndexChanged
        cboOperatingHospitals.DataSource = DataAdapter_Sch.GetSchedulerHospitals(CInt(cboTrusts.SelectedValue))
        cboOperatingHospitals.DataBind()
        cboOperatingHospitals.SelectedIndex = 0
    End Sub

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs)
        LoadOrderCommGrid()
        OrderCommsRadGrid.DataBind()
    End Sub

    Protected Sub OrderCommsObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        e.InputParameters("operatingHospitalId") = GetSelectedHospitals()
    End Sub
    Protected Function GetSelectedHospitals() As String
        Dim selectedValues = cboOperatingHospitals.CheckedItems
        If selectedValues.Count = 0 Then
            Return ""
        End If

        Dim selectedIds = selectedValues.Select(Function(item) item.Value)
        Return String.Join(",", selectedIds)
    End Function
    'Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
    '    If e.Argument = "Rebind" Then
    '        OrderCommsRadGrid.MasterTableView.SortExpressions.Clear()
    '        OrderCommsRadGrid.Rebind()
    '    ElseIf e.Argument = "RebindAndNavigate" Then
    '        OrderCommsRadGrid.MasterTableView.SortExpressions.Clear()
    '        OrderCommsRadGrid.MasterTableView.CurrentPageIndex = OrderCommsRadGrid.MasterTableView.PageCount - 1
    '        OrderCommsRadGrid.Rebind()
    '    End If
    'End Sub

    'Private Sub OrderCommsRadGrid_PreRender(sender As Object, e As EventArgs) Handles OrderCommsRadGrid.PreRender

    '    If OrderCommsRadGrid.MasterTableView.Columns.FindByUniqueName("OrderCommsHealthServiceNameColumn") IsNot Nothing Then
    '        OrderCommsRadGrid.MasterTableView.Columns.FindByUniqueName("OrderCommsHealthServiceNameColumn").HeaderText =
    '            Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " No"
    '    End If

    'End Sub
End Class