Imports System.Collections.Generic
Imports System.Data
Imports System.Drawing
Imports System.Linq
Imports System.Web
Imports Telerik.Web.UI

''' <summary>
''' A Class that provides functionality for grouping RadHtmlChart's data source
''' </summary>
Public NotInheritable Class RadHtmlChartGroupDataSource
    Private Sub New()
    End Sub
    ''' <summary>
    ''' Groups the RadHtmlChart's data source.
    ''' </summary>
    ''' <param name="HtmlChart">The RadHtmlChart instance.</param>
    ''' <param name="DataSource">The raw DataTable data source.</param>
    ''' <param name="DataGroupColumn">The name of the column in the raw data source which will be the criteria for grouping the chart series items into series. There will be as many series as the number of distinct values in this column.</param>
    ''' <param name="SeriesType">The type of the series. Currently the example supports Area, Bar, Column, Line, Scatter and ScatterLine series. You can, however, expand that list in the AddChartSeriesType() method.</param>
    ''' <param name="DataFieldY">The name of the column in the raw data source that stores the y-values.</param>
    ''' <param name="DataFieldX">The name of the column in the raw data source that stores the x-values. </param>
    Public Shared Sub GroupDataSource(HtmlChart As RadHtmlChart, DataSource As DataTable, DataGroupColumn As String, SeriesType As String, DataFieldY As String, DataFieldX As String)
        'Get number of distinct rows by DataGroupColumn (e.g., Year column)
        Dim distinctValuesDT As DataTable = DataSource.DefaultView.ToTable(True, DataGroupColumn)
        Dim numDistinctValues As Integer = distinctValuesDT.Rows.Count

        'Add RadHtmlChart series
        ConfigureChartSeries(HtmlChart, numDistinctValues, distinctValuesDT, SeriesType, DataFieldY, DataFieldX)

        'Group data source and bind it to the chart
        HtmlChart.DataSource = GetGroupedData(DataSource, DataGroupColumn, DataFieldY, numDistinctValues, distinctValuesDT)
        HtmlChart.DataBind()
    End Sub
    ''' <summary>
    ''' Configures chart series. For example sets series names, define tooltips/labels template, etc.
    ''' </summary>
    Private Shared Sub ConfigureChartSeries(HtmlChart As RadHtmlChart, NumDistinctValues As Integer, DistinctValuesDT As DataTable, SeriesType As String, DataFieldY As String, DataFieldX As String)
        HtmlChart.PlotArea.Series.Clear()
        'Detect whether series are of category type
        Dim categorySeriesArray As String() = {"AreaSeries", "BarSeries", "ColumnSeries", "LineSeries"}
        Dim isCategorySeries As Boolean = If(Array.IndexOf(categorySeriesArray, SeriesType) > -1, True, False)

        'Configure x-axis DataLabelsField if series are of category type
        If isCategorySeries Then
            HtmlChart.PlotArea.XAxis.DataLabelsField = DataFieldX & "0"
        End If

        For i As Integer = 0 To NumDistinctValues - 1

            'Construct the series name, tooltips template and labels format string
            Dim seriesName As String = DistinctValuesDT.Rows(i)(0).ToString()
            'Dim tooltipsTemplate As String = "#=dataItem." & DataFieldX & i & "# : #=dataItem." & DataFieldY & i & "#"
            Dim tooltipsTemplate As String = "#= series.name # for #=dataItem." & DataFieldX & i & "# : #=dataItem." & DataFieldY & i & "#"
            Dim labelsFormatString As String = "{0}"

            'Add the corresponding series type to the chart
            AddChartSeriesType(HtmlChart, SeriesType, DataFieldY, DataFieldX, i, seriesName, tooltipsTemplate, labelsFormatString)
        Next
    End Sub
    ''' <summary>
    ''' Adds chart series. Currently the method supports Area, Bar, Column, Line, Scatter and ScatterLine series. You can, however, expand that list here.
    ''' </summary>
    Private Shared Sub AddChartSeriesType(HtmlChart As RadHtmlChart, SeriesType As String, DataFieldY As String, DataFieldX As String, Index As Integer, SeriesName As String, TooltipsTemplate As String, LabelsFormatString As String)
        Select Case SeriesType
            Case "AreaSeries"
                Dim areaSeries1 As New AreaSeries()
                areaSeries1.Name = SeriesName
                areaSeries1.DataFieldY = DataFieldY & Index
                areaSeries1.TooltipsAppearance.ClientTemplate = TooltipsTemplate
                areaSeries1.TooltipsAppearance.Color = Color.White
                areaSeries1.LabelsAppearance.DataFormatString = LabelsFormatString
                HtmlChart.PlotArea.Series.Add(areaSeries1)
                Exit Select

            Case "BarSeries"
                Dim barSeries1 As New BarSeries()
                barSeries1.Name = SeriesName
                barSeries1.DataFieldY = DataFieldY & Index
                barSeries1.TooltipsAppearance.ClientTemplate = TooltipsTemplate
                barSeries1.TooltipsAppearance.Color = Color.White
                barSeries1.LabelsAppearance.DataFormatString = LabelsFormatString
                HtmlChart.PlotArea.Series.Add(barSeries1)
                Exit Select

            Case "ColumnSeries"
                Dim columnSeries1 As New ColumnSeries()
                columnSeries1.Name = SeriesName
                columnSeries1.DataFieldY = DataFieldY & Index
                columnSeries1.TooltipsAppearance.ClientTemplate = TooltipsTemplate
                columnSeries1.TooltipsAppearance.Color = Color.White
                'columnSeries1.LabelsAppearance.DataFormatString = LabelsFormatString
                columnSeries1.LabelsAppearance.Visible = False
                columnSeries1.Appearance.FillStyle.BackgroundColor = setColor(SeriesName)
                HtmlChart.PlotArea.Series.Add(columnSeries1)
                Exit Select

            Case "LineSeries"
                Dim lineSeries1 As New LineSeries()
                lineSeries1.Name = SeriesName
                lineSeries1.DataFieldY = DataFieldY & Index
                lineSeries1.TooltipsAppearance.ClientTemplate = TooltipsTemplate
                lineSeries1.TooltipsAppearance.Color = Color.White
                'lineSeries1.LabelsAppearance.DataFormatString = LabelsFormatString
                lineSeries1.LabelsAppearance.Visible = False
                HtmlChart.PlotArea.Series.Add(lineSeries1)
                Exit Select

            Case "ScatterSeries"
                Dim scatterSeries1 As New ScatterSeries()
                scatterSeries1.Name = SeriesName
                scatterSeries1.DataFieldY = DataFieldY & Index
                scatterSeries1.DataFieldX = DataFieldX & Index
                scatterSeries1.TooltipsAppearance.ClientTemplate = TooltipsTemplate
                scatterSeries1.TooltipsAppearance.Color = Color.White
                scatterSeries1.LabelsAppearance.DataFormatString = LabelsFormatString
                HtmlChart.PlotArea.Series.Add(scatterSeries1)
                Exit Select

            Case "ScatterLineSeries"
                Dim scatterLineSeries1 As New ScatterLineSeries()
                scatterLineSeries1.Name = SeriesName
                scatterLineSeries1.DataFieldY = DataFieldY & Index
                scatterLineSeries1.DataFieldX = DataFieldX & Index
                scatterLineSeries1.TooltipsAppearance.ClientTemplate = TooltipsTemplate
                scatterLineSeries1.TooltipsAppearance.Color = Color.White
                scatterLineSeries1.LabelsAppearance.DataFormatString = LabelsFormatString
                HtmlChart.PlotArea.Series.Add(scatterLineSeries1)
                Exit Select
            Case Else

                Exit Select
        End Select
    End Sub

    Private Shared Function setColor(seriesName As String) As Color
        Select Case seriesName
            Case "Others"
                Return Color.DarkTurquoise
            Case "UpperGI"
                Return Color.DarkSlateBlue
            Case "Colon"
                Return Color.DarkOliveGreen
            Case "ERCP"
                Return Color.Black
            Case "EUS"
                Return Color.Chocolate
        End Select
    End Function
    ''' <summary>
    ''' The actual data source grouping manipulations.
    ''' </summary>
    Private Shared Function GetGroupedData(RawDataTable As DataTable, DataGroupColumn As String, DataFieldY As String, NumDistinctValues As Integer, DistinctValuesDT As DataTable) As DataTable
        If NumDistinctValues > 1 Then
            Dim commonDT As New DataTable()

            'Split the raw DataTable by numDistinctValues to an array of temporary DataTables
            Dim tempDTarray As DataTable() = New DataTable(NumDistinctValues - 1) {}
            tempDTarray = SplitDataTable(RawDataTable, DataGroupColumn, NumDistinctValues, DistinctValuesDT)

            'Add rows to the common DataTable
            For i As Integer = 0 To tempDTarray(0).Rows.Count - 1
                commonDT.Rows.Add()
            Next

            'Add columns to the common DataTable and fill values from each temp DataTable
            For i As Integer = 0 To NumDistinctValues - 1
                'Loop through the columns of each temp DataTable
                For g As Integer = 0 To tempDTarray(i).Columns.Count - 1
                    Dim columnName As String = tempDTarray(i).Columns(g).ColumnName
                    'Add columns from the temp DataTables to the common DataTable
                    commonDT.Columns.Add(columnName, tempDTarray(i).Columns(g).DataType)

                    'Loop through the rows of the each temp DataTable
                    For f As Integer = 0 To tempDTarray(i).Rows.Count - 1
                        'Fill values from each temp DataTable to the common DataTable   
                        Try
                            commonDT.Rows(f)(columnName) = tempDTarray(i).Rows(f)(columnName)
                        Catch ex As Exception
                        End Try
                    Next
                Next
            Next
            Return commonDT
        Else
            Return Nothing
        End If
    End Function
    ''' <summary>
    ''' A helper method for the data source grouping manipulations.
    ''' </summary>
    Private Shared Function SplitDataTable(RawDataTable As DataTable, DataGroupColumn As String, NumDistinctValues As Integer, DistinctValuesDT As DataTable) As DataTable()
        If NumDistinctValues > 1 Then
            Dim tempDTarray As DataTable() = New DataTable(NumDistinctValues - 1) {}
            For i As Integer = 0 To NumDistinctValues - 1
                'Split the raw DataTable to multiple temporary DataTables by distinct DataGroupColumn values
                tempDTarray(i) = RawDataTable.[Select](DataGroupColumn & "='" & DistinctValuesDT.Rows(i)(0).ToString() & "'").CopyToDataTable()

                For g As Integer = 0 To tempDTarray(i).Columns.Count - 1
                    'Add g-th index to column names for each i-th DataTable from the temporary DataTable array
                    Dim columnName As String = tempDTarray(i).Columns(g).ColumnName + i.ToString()
                    tempDTarray(i).Columns(g).ColumnName = columnName
                Next
            Next
            Return tempDTarray
        Else
            Return Nothing
        End If
    End Function
End Class

