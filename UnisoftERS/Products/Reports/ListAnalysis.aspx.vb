
Imports Telerik.Web.UI

Imports System.Web.UI.WebControls

Imports xi = Telerik.Web.UI.ExportInfrastructure

Imports System.Web.UI

Imports System.Web

Imports Telerik.Web.UI.GridExcelBuilder

Imports System.Drawing



Public Class ListAnalysis

        Inherits System.Web.UI.Page



        Protected Sub ImageButton_Click(sender As Object, e As ImageClickEventArgs)

            Dim alternateText As String = TryCast(sender, ImageButton).AlternateText

            If alternateText = "Xlsx" AndAlso CheckBox2.Checked Then

                RadGrid1.MasterTableView.GetColumn("EmployeeID").HeaderStyle.BackColor = Color.LightGray

                RadGrid1.MasterTableView.GetColumn("EmployeeID").ItemStyle.BackColor = Color.LightGray

            End If

            RadGrid1.ExportSettings.Excel.Format = DirectCast([Enum].Parse(GetType(GridExcelExportFormat), alternateText), GridExcelExportFormat)

            RadGrid1.ExportSettings.IgnorePaging = CheckBox1.Checked

            RadGrid1.ExportSettings.ExportOnlyData = True

            RadGrid1.ExportSettings.OpenInNewWindow = True

            RadGrid1.MasterTableView.ExportToExcel()

        End Sub



#Region "[ HTML FORMAT ]"

        Protected Sub RadGrid1_ItemCreated(sender As Object, e As GridItemEventArgs)

            If CheckBox2.Checked Then

                If TypeOf e.Item Is GridDataItem OrElse TypeOf e.Item Is GridHeaderItem Then

                    e.Item.Cells(2).CssClass = "employeeColumn"

                End If

            End If

        End Sub



        Protected Sub RadGrid1_HtmlExporting(sender As Object, e As GridHTMLExportingEventArgs)

            If CheckBox2.Checked Then

                e.Styles.Append("@page table .employeeColumn { background-color: #d3d3d3; }")

            End If

        End Sub

#End Region



#Region "[ EXCELML FORMAT ]"

        Protected Sub RadGrid1_ExcelMLWorkBookCreated(sender As Object, e As GridExcelMLWorkBookCreatedEventArgs)

            If CheckBox2.Checked Then

                For Each row As RowElement In e.WorkBook.Worksheets(0).Table.Rows

                    row.Cells(0).StyleValue = "Style1"

                Next



                Dim style As New StyleElement("Style1")

                style.InteriorStyle.Pattern = InteriorPatternType.Solid

                style.InteriorStyle.Color = System.Drawing.Color.LightGray

                e.WorkBook.Styles.Add(style)

            End If

        End Sub



#End Region



#Region "[ BIFF FORMAT ]"

        Protected Sub RadGrid1_BiffExporting(sender As Object, e As GridBiffExportingEventArgs)

            If CheckBox2.Checked Then

                e.ExportStructure.Tables(0).Columns(1).Style.BackColor = System.Drawing.Color.LightGray

            End If

        End Sub



#End Region



#Region "[ Built-in Export button configuration ]"

        Protected Sub RadGrid1_ItemCommand(sender As Object, e As GridCommandEventArgs)

            If e.CommandName = RadGrid.ExportToExcelCommandName Then

                RadGrid1.ExportSettings.Excel.Format = GridExcelExportFormat.Biff

                RadGrid1.ExportSettings.IgnorePaging = CheckBox1.Checked

                RadGrid1.ExportSettings.ExportOnlyData = True

                RadGrid1.ExportSettings.OpenInNewWindow = True

            End If

        End Sub

#End Region

End Class