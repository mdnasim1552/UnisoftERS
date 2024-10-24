Imports Telerik.Web.UI
Imports Telerik
Imports Telerik.Charting
Imports System.Drawing

Public Class dashboard
    Inherits System.Web.UI.UserControl
    Private Property selectedYear As String
        Get
            Return ViewState("selectedYear")
        End Get
        Set(value As String)
            ViewState("selectedYear") = value
        End Set
    End Property
    Private Property lastSelectedChart As String
        Get
            Return ViewState("lastSelectedChart")
        End Get
        Set(value As String)
            ViewState("lastSelectedChart") = value
        End Set
    End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Public Sub LoadDashboard()
        If Not IsPostBack And Not Session("HideStartUpCharts") Then
            Dim ds As New DataAccess
            Dim dtTrusts As New DataTable

            For Each row As DataRow In ds.getProcedureChartYears.Rows
                OptionsMenu2.Items(0).Items.Add(New RadMenuItem(row.Item("ProcedureYear")))
            Next row
            selectedYear = Now.Year.ToString
            lastSelectedChart = "ColumnSeries"
            ''setColour(chartViewer)
            'chartViewer.DataGroupColumn = "Type"
            'chartViewer.ChartTitle.TextBlock.Text = "Type"
            'chartViewer.PlotArea.XAxis.DataLabelsColumn = "ProcedureYear"
            'chartViewer.Legend.Appearance.GroupNameFormat = "#VALUE"

            'YearRadDropDownList.DataBind()
            'If YearRadDropDownList.Items.Count > 0 AndAlso YearRadDropDownList.FindItemByValue(Now.Year.ToString).Index > -1 Then
            '    YearRadDropDownList.SelectedValue = Now.Year.ToString
            '    ' RadCharty.ChartTitle.TextBlock.Text = Now.Year.ToString & " procedures by month"
            'End If

            '29 Jun 2022 : MH added to fix chart load error 
            trChartErrorLabel.Visible = False

            'Deliberate emptying for testing
            'Session("OperatingHospitalIdsForTrust") = Nothing
            'Session("TrustId") = Nothing

            If IsNothing(Session("OperatingHospitalIdsForTrust")) Then
                If Not IsNothing(HttpContext.Current.Session("TrustId")) Then
                    Session("OperatingHospitalIdsForTrust") = BusinessLogic.GetOperatingHospitalIdsForTrust(CInt(HttpContext.Current.Session("TrustId")))
                Else
                    'If TrustId session variable is Null, then show empty chart with a message
                    Session("OperatingHospitalIdsForTrust") = "-1" 'This will load an empty Chart
                    trChartErrorLabel.Visible = True
                End If

            End If

            RadHtmlChartGroupDataSource.GroupDataSource(RadHtmlChart1, ds.getProcedureChartByYear(Session("OperatingHospitalIdsForTrust")), "Type", "ColumnSeries", "Count", "ProcedureYear")
            RadHtmlChartGroupDataSource.GroupDataSource(RadHtmlChart2, ds.getProcedureChartByMonth(selectedYear, Session("OperatingHospitalIdsForTrust")), "Type", lastSelectedChart, "Count", "Month")
            RadHtmlChart2.ChartTitle.Text = selectedYear & " procedures by month"
            'For Each itm As DropDownListItem In YearRadDropDownList.Items
            '    OptionsMenu.Items(0).Items.Add(New RadMenuItem(itm.Value))
            'Next


            ''setColour(RadCharty)
            'RadCharty.DataGroupColumn = "Type"
            'RadCharty.ChartTitle.TextBlock.Text = "Procedures by month"
            'RadCharty.PlotArea.XAxis.DataLabelsColumn = "Month"
            'RadCharty.Legend.Appearance.GroupNameFormat = "#VALUE"
            'ddlProductGrp.Items.FindByText("Product")
            'YearRadDropDownList.DataBind()
            'If YearRadDropDownList.Items.Count > 0 AndAlso YearRadDropDownList.FindItemByValue(Now.Year.ToString).Index > -1 Then
            '    YearRadDropDownList.SelectedValue = Now.Year.ToString
            '    ' RadCharty.ChartTitle.TextBlock.Text = Now.Year.ToString & " procedures by month"
            'End If
        End If
    End Sub

    'Protected Sub DropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
    '    Dim viewer As RadChart
    '    If DirectCast(sender, RadDropDownList).ID = "YearChartDropDownList" Then
    '        ' viewer = chartViewer
    '    Else
    '        viewer = RadCharty
    '    End If
    '    Select Case e.Value
    '        Case 1
    '            viewer.DefaultType = Charting.ChartSeriesType.Bar
    '        Case 2
    '            viewer.DefaultType = Charting.ChartSeriesType.Line
    '        Case 3
    '            viewer.DefaultType = Charting.ChartSeriesType.Spline
    '        Case 4
    '            viewer.DefaultType = Charting.ChartSeriesType.StackedBar
    '        Case 5
    '            viewer.DefaultType = Charting.ChartSeriesType.Area
    '    End Select
    'End Sub


    'Protected Sub ItemDataBound(sender As Object, e As ChartItemDataBoundEventArgs)
    '    If e.SeriesItem.YValue = 0 Then
    '        e.SeriesItem.Label.Appearance.Visible = False
    '    End If
    'End Sub

    Sub setColour(schart As RadChart)
        Dim seriesColors As ColorBlend() = {
            New ColorBlend(New Color() {Color.Blue, Color.Blue}),
            New ColorBlend(New Color() {Color.Red, Color.Red}),
                New ColorBlend(New Color() {Color.Yellow, Color.Yellow}),
                New ColorBlend(New Color() {Color.Black, Color.Black}),
                New ColorBlend(New Color() {Color.Green, Color.Green}),
                New ColorBlend(New Color() {Color.MediumPurple, Color.MediumPurple}),
                New ColorBlend(New Color() {Color.Brown, Color.Brown}),
                New ColorBlend(New Color() {Color.Orange, Color.Orange}),
                New ColorBlend(New Color() {Color.Gray, Color.Gray}),
                    New ColorBlend(New Color() {Color.White, Color.White})}

        Dim seriesPalette As New Palette("seriesPalette", seriesColors)
        schart.CustomPalettes.Add(seriesPalette)
        schart.SeriesPalette = "seriesPalette"
    End Sub
    Protected Sub OptionMenuClicked(sender As Object, e As RadMenuEventArgs)
        If e.Item.Level = 2 Then
            Dim ds As New DataAccess
            Dim sendr As RadContextMenu = DirectCast(sender, RadContextMenu)

            If sendr.ID = "OptionsMenu1" Then
                Dim ChartType As String = e.Item.Value
                RadHtmlChartGroupDataSource.GroupDataSource(RadHtmlChart1, ds.getProcedureChartByYear(Session("OperatingHospitalIdsForTrust")), "Type", ChartType, "Count", "ProcedureYear")
            End If
            If sendr.ID = "OptionsMenu2" Then
                Dim parentItem As RadMenuItem = DirectCast(e.Item.Owner, RadMenuItem)
                If parentItem.Text = "Year" Then
                    selectedYear = e.Item.Text
                    RadHtmlChartGroupDataSource.GroupDataSource(RadHtmlChart2, ds.getProcedureChartByMonth(selectedYear, Session("OperatingHospitalIdsForTrust")), "Type", lastSelectedChart, "Count", "Month")
                    RadHtmlChart2.ChartTitle.Text = e.Item.Text & " procedures by month"
                End If
                If parentItem.Text = "Chart" Then
                    lastSelectedChart = e.Item.Value
                    RadHtmlChartGroupDataSource.GroupDataSource(RadHtmlChart2, ds.getProcedureChartByMonth(selectedYear, Session("OperatingHospitalIdsForTrust")), "Type", lastSelectedChart, "Count", "Month")
                End If
            End If
        End If

    End Sub
End Class