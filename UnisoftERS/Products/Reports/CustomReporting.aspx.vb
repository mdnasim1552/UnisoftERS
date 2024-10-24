Imports Telerik.Web.UI

Public Class AuditReporting
    Inherits System.Web.UI.Page
    Dim dataaccess As New DataAccess
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim dt As DataTable = dataaccess.Get_ERS_ReportingSections()
            ERS_ReportingSectionsRadComboBox.DataTextField = "ReportSectionName"
            ERS_ReportingSectionsRadComboBox.DataValueField = "ReportSectionId"
            ERS_ReportingSectionsRadComboBox.DataSource = dt
            ERS_ReportingSectionsRadComboBox.DataBind()
        End If
        Dim dts As DataTable = dataaccess.Get_Procedure_Parameters(ERS_ReportingRadComboBox.SelectedValue)
        If dts IsNot Nothing Then
            CreateDynamicControls(dts)
        End If
    End Sub

    Protected Sub ERS_ReportingSectionsRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Dim dt As DataTable = dataaccess.Get_ERS_Reporting(e.Value)
        ERS_ReportingRadComboBox.DataTextField = "FriendlyName"
        ERS_ReportingRadComboBox.DataValueField = "StoreProcedureName"
        ERS_ReportingRadComboBox.DataSource = dt
        ERS_ReportingRadComboBox.DataBind()

        Dim newItem As New RadComboBoxItem()
        newItem.Text = "Select"
        newItem.Value = "AAAAAAA" ' Set the value as needed
        newItem.Selected = True ' Optionally set whether it's selected
        ERS_ReportingRadComboBox.Items.Add(newItem)

        'searchDiv.Visible = False
        reportDiv.Visible = False
        Rdcontent.Visible = False
        ExportToExcelButton.Visible = False
    End Sub

    'Protected Sub OkButton_Click(sender As Object, e As EventArgs)
    '    Dim dt As DataTable = dataaccess.Get_Procedure_Parameters(ERS_ReportingRadComboBox.SelectedValue)
    '    CreateDynamicControls(dt)
    'End Sub

    Private Sub CreateDynamicControls(dt As DataTable)
        ' Clear existing dynamic controls
        dynamicLabel.Controls.Clear()
        dynamicInputbox.Controls.Clear()
        For Each row As DataRow In dt.Rows
            Dim labelText As String = row("parameter_name").ToString()
            Dim defaultValue As String = row("DefaultValue").ToString()
            ' Create a label
            Dim lbl As New RadLabel()
            lbl.Text = labelText.Replace("@", "") & ":"
            lbl.Style("margin-bottom") = "8px"
            dynamicLabel.Controls.Add(lbl)
            dynamicLabel.Controls.Add(New LiteralControl("<br />"))
            ' Create a RadTextBox
            Dim txtBox As New RadTextBox()
            txtBox.ID = ERS_ReportingRadComboBox.Text & labelText.Replace(" ", "")
            txtBox.Style("margin-bottom") = "5px"
            dynamicInputbox.Controls.Add(txtBox)
            txtBox.Text = defaultValue
            lbl.AssociatedControlID = txtBox.ID
            ' Add a line break for better formatting
            dynamicInputbox.Controls.Add(New LiteralControl("<br />"))
        Next
    End Sub

    Protected Sub ERS_ReportingRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        'searchDiv.Visible = True
        reportDiv.Visible = True
        reportNameId.InnerText = ERS_ReportingRadComboBox.Text
        Rdcontent.Visible = False
        ExportToExcelButton.Visible = False
        'Dim dt As DataTable = dataaccess.Get_Procedure_Parameters(ERS_ReportingRadComboBox.SelectedValue)
        'ViewState("ProcedureParameters") = dt
        'CreateDynamicControls(dt)
    End Sub

    Protected Sub searchButton_Click(sender As Object, e As EventArgs)
        'Dim x = DirectCast(dynamicInputbox.FindControl("txt_@OperatingHospital"), RadTextBox).Text
        Dim dct As Dictionary(Of String, String) = New Dictionary(Of String, String)()
        For Each control As Control In dynamicInputbox.Controls
            If TypeOf control Is RadTextBox Then
                Dim textBox As RadTextBox = DirectCast(control, RadTextBox)
                Dim fieldName As String = textBox.ID.Replace(ERS_ReportingRadComboBox.Text, "") ' Extract field name from RadTextBox ID
                Dim fieldValue As String = textBox.Text ' Get the value entered in the RadTextBox
                dct.Add(fieldName, fieldValue)
                'textBox.Text = ""
            End If
        Next
        Dim dt As DataTable = dataaccess.Get_Custom_Report(ERS_ReportingRadComboBox.SelectedValue, dct)
        If (StartDate.SelectedDate IsNot Nothing And EndDate.SelectedDate IsNot Nothing) Then
            'Dim columnExists As Boolean = dt.Columns.Contains("CreationDate")
            If dt.Columns.Contains("CreationDate") Then
                dt = FilterDateColumn(dt, "CreationDate")
            ElseIf dt.Columns.Contains("CreatedOn") Then
                dt = FilterDateColumn(dt, "CreatedOn")
            ElseIf dt.Columns.Contains("ProcedureDate") Then
                dt = FilterDateColumn(dt, "ProcedureDate")
            ElseIf dt.Columns.Contains("Procedure Date") Then
                dt = FilterDateColumn(dt, "Procedure Date")
            End If
            'Dim fromDate As String = Convert.ToDateTime(StartDate.SelectedDate).ToString("yyyy-MM-dd")
            'Dim toDate As String = Convert.ToDateTime(EndDate.SelectedDate).ToString("yyyy-MM-dd")
            'Dim columnExists As Boolean = dt.Columns.Contains("CreationDate")
            'If columnExists Then
            '    For Each row As DataRow In dt.Rows
            '        Dim creationDate As DateTime = Convert.ToDateTime(row("CreationDate"))
            '        Dim formattedDate As String = creationDate.ToString("yyyy-MM-dd")
            '        row("CreationDate") = formattedDate
            '    Next
            '    Dim dv As DataView = dt.DefaultView
            '    Dim query As String = "creationdate >='" + fromDate + "' AND CreationDate <= '" + toDate + "'"
            '    dv.RowFilter = query
            '    dt = dv.ToTable()
            'End If
        End If
        Session("GetCustomReport") = dt
        ' Clear sorting expressions to reset the sorting
        RadGrid1.MasterTableView.SortExpressions.Clear()
        Me.Data_Bind()
    End Sub
    Public Function FilterDateColumn(dt As DataTable, columnName As String)
        Dim fromDate As String = Convert.ToDateTime(StartDate.SelectedDate).ToString("yyyy-MM-dd")
        Dim toDate As String = Convert.ToDateTime(EndDate.SelectedDate).ToString("yyyy-MM-dd")
        Dim columnExists As Boolean = dt.Columns.Contains(columnName)
        If columnExists Then
            For Each row As DataRow In dt.Rows
                Dim creationDate As DateTime = Convert.ToDateTime(row(columnName))
                Dim formattedDate As String = creationDate.ToString("yyyy-MM-dd")
                row(columnName) = formattedDate
            Next
            Dim dv As DataView = dt.DefaultView
            Dim query As String = "[" + columnName + "] >='" + fromDate + "' AND [" + columnName + "] <= '" + toDate + "'"
            dv.RowFilter = query
            dt = dv.ToTable()
            'For Each row As DataRow In dt.Rows
            '    Dim creationDate As DateTime = Convert.ToDateTime(row("CreationDate"))
            '    Dim formattedDate As String = creationDate.ToString("dd MMMM yyyy")
            '    row("CreationDate") = formattedDate
            'Next
        End If
        Return dt
    End Function
    Protected Sub ExportToExcelButton_Click(sender As Object, e As EventArgs)
        Data_Bind()
        RadGrid1.MasterTableView.HeaderStyle.Height = Unit.Pixel(28)
        RadGrid1.Visible = True
        RadGrid1.ExportSettings.Excel.Format = GridExcelExportFormat.Html
        RadGrid1.ExportSettings.IgnorePaging = False
        RadGrid1.ExportSettings.ExportOnlyData = True
        RadGrid1.ExportSettings.HideStructureColumns = True
        RadGrid1.ExportSettings.UseItemStyles = True
        RadGrid1.ExportSettings.FileName = ViewState("Historytblname") + DateTime.Now.ToString("yyyy-MM-dd HH-mm-ss")
        RadGrid1.ExportSettings.OpenInNewWindow = True
        RadGrid1.MasterTableView.ExportToExcel()
    End Sub
    Protected Sub RadGrid1_SortCommand(ByVal sender As Object, ByVal e As GridSortCommandEventArgs) Handles RadGrid1.SortCommand
        ' Perform custom sorting logic here based on the column clicked
        Dim columnName As String = e.SortExpression
        Dim sortDirection As GridSortOrder = e.NewSortOrder
        Me.Data_Bind()
    End Sub
    Private Sub Data_Bind()
        'DisableAjaxSetting()
        RadGrid1.Columns.Clear()
        RadGrid1.AutoGenerateColumns = False
        Dim dt As DataTable = DirectCast(Session("GetCustomReport"), DataTable)
        If dt IsNot Nothing Then
            For Each column As DataColumn In dt.Columns
                Dim boundColumn As New GridBoundColumn()
                boundColumn.DataField = column.ColumnName
                boundColumn.UniqueName = column.ColumnName.Replace(" ", "_")
                boundColumn.HeaderText = column.ColumnName
                boundColumn.HeaderStyle.Width = IIf(column.ColumnName.Length > 25, Unit.Pixel(200), Unit.Pixel(100))
                boundColumn.AllowSorting = True
                RadGrid1.MasterTableView.Columns.Add(boundColumn)
            Next
            RadGrid1.DataSource = dt
            RadGrid1.DataBind()
            If dt.Rows.Count > 0 Then
                Me.ExportToExcelButton.Visible = True
            Else
                Me.ExportToExcelButton.Visible = False
            End If
            Rdcontent.Visible = True
        Else
            Me.ExportToExcelButton.Visible = False
            Me.Rdcontent.Visible = False
        End If

    End Sub
    Protected Sub RadGrid1_PageIndexChanged(sender As Object, e As GridPageChangedEventArgs)
        RadGrid1.CurrentPageIndex = e.NewPageIndex
        Me.Data_Bind()
    End Sub

    Protected Sub RadGrid1_PageSizeChanged(sender As Object, e As GridPageSizeChangedEventArgs)
        'RadGrid1.PageSize = e.NewPageSize
        'ViewState("PageSize") = e.NewPageSize
        Me.Data_Bind()
    End Sub
    Protected Sub RadGrid1_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles RadGrid1.ItemCommand
        If e.CommandName = RadGrid.ExportToExcelCommandName Then
            Data_Bind()
        End If
    End Sub
End Class