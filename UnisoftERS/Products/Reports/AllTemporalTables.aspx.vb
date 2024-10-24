Imports System.Data.Common
Imports System.Web.Services
Imports Newtonsoft.Json
Imports Telerik.Web.UI
Imports Telerik.Windows.Documents.Flow.Model.StructuredDocumentTags
Public Class AllTemporalTables
    Inherits PageBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            StartDate.SelectedDate = DateTime.Now.AddMonths(-1)
            EndDate.SelectedDate = DateTime.Now
            Session.Remove("GetHistoryData")
            DisableAjaxSetting()
        End If

    End Sub
    Protected Sub DisableAjaxSetting()
        ' Access RadAjaxManager from the master page
        Dim radAjaxManager As RadAjaxManager = DirectCast(Master.FindControl("RadAjaxManager1"), RadAjaxManager)

        If radAjaxManager IsNot Nothing Then
            ' Iterate over the AjaxSettings collection to find the specific AjaxSetting
            For Each ajaxSetting As AjaxSetting In radAjaxManager.AjaxSettings
                If ajaxSetting IsNot Nothing AndAlso ajaxSetting.AjaxControlID = "UnisoftMenu" Then
                    ' Remove the AjaxSetting
                    radAjaxManager.AjaxSettings.Remove(ajaxSetting)
                    Exit For ' Exit loop after removing the AjaxSetting
                End If
            Next
        End If
    End Sub



    Private Sub Page_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
        If Not Page.IsPostBack Then
            BindToDataTable(LeftMenuTreeView)
        End If

    End Sub
    Private Sub BindToDataTable(ByVal treeView As RadTreeView)
        treeView.DataTextField = "TableName"
        treeView.DataValueField = "TableName"
        'treeView.DataFieldID = "MapID"
        'treeView.DataFieldParentID = "ParentID"
        treeView.DataSource = DataAdapter.GetAllTemporal()
        treeView.DataBind()
        treeView.ExpandAllNodes()
    End Sub
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
        DisableAjaxSetting()
        RadGrid1.Columns.Clear()
        RadGrid1.AutoGenerateColumns = False
        Dim dt As DataTable = DirectCast(Session("GetHistoryData"), DataTable)
        If dt IsNot Nothing Then
            For Each column As DataColumn In dt.Columns
                Dim boundColumn As New GridBoundColumn()
                boundColumn.DataField = column.ColumnName
                boundColumn.UniqueName = column.ColumnName.Replace(" ", "_")
                boundColumn.HeaderText = column.ColumnName
                boundColumn.HeaderStyle.Width = Unit.Pixel(100)
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
    Protected Sub RadTreeView1_NodeClick(ByVal sender As Object, ByVal e As RadTreeNodeEventArgs) Handles LeftMenuTreeView.NodeClick
        ViewState("Historytblname") = e.Node.Text
        Dim fromDate As String = Convert.ToDateTime(StartDate.SelectedDate).ToString("yyyy-MM-dd")
        Dim toDate As String = Convert.ToDateTime(EndDate.SelectedDate).ToString("yyyy-MM-dd")
        Dim dataTable As DataTable = DataAdapter.GetHistoryData(e.Node.Text, fromDate, toDate)
        Session("GetHistoryData") = dataTable
        RadGrid1.MasterTableView.SortExpressions.Clear()
        Me.Data_Bind()

        'Me.RadGrid1_NeedDataSource(Nothing, Nothing)
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

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs)
        Dim fromDate As String = Convert.ToDateTime(StartDate.SelectedDate).ToString("yyyy-MM-dd")
        Dim toDate As String = Convert.ToDateTime(EndDate.SelectedDate).ToString("yyyy-MM-dd")
        Dim dataTable As DataTable = DataAdapter.GetHistoryData(ViewState("Historytblname"), fromDate, toDate)
        Session("GetHistoryData") = dataTable
        Me.Data_Bind()
    End Sub
    'Protected Sub RadGrid1_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
    '    Dim dt As DataTable = DirectCast(Session("GetHistoryData"), DataTable)
    '    If dt IsNot Nothing Then
    '        Me.Data_Bind()
    '    End If
    'End Sub
End Class