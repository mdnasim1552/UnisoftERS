Imports Telerik.Web.UI

Public Class NEDSummary
    Inherits PageBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(RadButtonFilter, ReportPanel, RadAjaxLoadingPanel1)

        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/", False)
        Else
            SUID.Value = Session("PKUserId").ToString
        End If

        If Not Page.IsPostBack Then
            Dim da As New DataAccess
            OperatingHospitalsRadComboBox.DataSource = da.GetOperatingHospitals()
            OperatingHospitalsRadComboBox.DataTextField = "HospitalName"
            OperatingHospitalsRadComboBox.DataValueField = "OperatingHospitalId"
            OperatingHospitalsRadComboBox.DataBind()

            If OperatingHospitalsRadComboBox.Items.Count = 1 Then OperatingHospitalsRadComboBox.EnableCheckAllItemsCheckBox = False

            If RDPFrom.SelectedDate.ToString = "" Then
                RDPFrom.SelectedDate = "01/01/2018"
                RDPTo.SelectedDate = "30/12/2099"
            End If

            If da.CanViewAllUsers() Then
                RadListBox1.Enabled = True
            Else
                RadListBox1.Enabled = False

                Dim userId = Session("PKUserId").ToString

                For Each item As RadListBoxItem In RadListBox1.Items
                    If item.Value = userId Then
                        item.Checked = True
                        Exit For
                    End If
                Next
            End If
        End If
    End Sub

    Protected Sub OperatingHospitalsRadComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        e.Item.Checked = True
    End Sub


    Protected Sub RadGridSummary_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim operatingHospitalList As String = ""
        For Each Item As RadComboBoxItem In OperatingHospitalsRadComboBox.CheckedItems
            operatingHospitalList = operatingHospitalList + Item.Value.ToString() + ","
        Next
        If operatingHospitalList.Length > 0 Then operatingHospitalList = operatingHospitalList.Substring(0, operatingHospitalList.LastIndexOf(","))

        Dim consultantList As String = ""
        For Each Item As RadListBoxItem In RadListBox1.CheckedItems
            consultantList = consultantList + Item.Value.ToString + ","
        Next
        If consultantList.Length > 0 Then consultantList = consultantList.Substring(0, consultantList.LastIndexOf(","))

        Dim status As Boolean?
        If ProcessedStatusRadioButton.SelectedValue = -1 Then
            status = Nothing
        Else
            status = ProcessedStatusRadioButton.SelectedValue
        End If


        SummaryReportRadGrid.ExportSettings.Excel.Format = GridExcelExportFormat.Html
        SummaryReportRadGrid.ExportSettings.FileName = "NED_Summary_Report_" & Now.ToString("ddMMyyyy")

        'Run the report(s) selected
        Dim dt = Reporting.GetNEDSummary(operatingHospitalList, consultantList, status, RDPFrom.SelectedDate, RDPTo.SelectedDate)
        SummaryReportRadGrid.DataSource = dt

    End Sub

    Protected Sub RadButtonFilter_Click(sender As Object, e As EventArgs)
        Try
            If RadListBox1.CheckedItems.Count = 0 Then
                RadNotification1.Show("No consultant(s) selected!")
                Exit Sub
            End If
            If CDate(RDPFrom.SelectedDate.ToString) > CDate(RDPTo.SelectedDate.ToString) Then
                RadNotification1.Show("End date must be after the start date")
                Exit Sub
            End If

            Dim operatingHospitalList As String = ""
            For Each Item As RadComboBoxItem In OperatingHospitalsRadComboBox.CheckedItems
                operatingHospitalList = operatingHospitalList + Item.Value.ToString() + ","
            Next
            operatingHospitalList = operatingHospitalList.Substring(0, operatingHospitalList.LastIndexOf(","))

            Dim consultantList As String = ""
            For Each Item As RadListBoxItem In RadListBox1.CheckedItems
                consultantList = consultantList + Item.Value.ToString + ","
            Next
            consultantList = consultantList.Substring(0, consultantList.LastIndexOf(","))

            Dim status As Boolean?
            If ProcessedStatusRadioButton.SelectedValue = -1 Then
                status = Nothing
            Else
                status = ProcessedStatusRadioButton.SelectedValue
            End If


            'Run the report(s) selected

            SummaryReportRadGrid.ExportSettings.Excel.Format = GridExcelExportFormat.Html
            Dim dt = Reporting.GetNEDSummary(operatingHospitalList, consultantList, status, RDPFrom.SelectedDate, RDPTo.SelectedDate)
            SummaryReportRadGrid.DataSource = dt
            SummaryReportRadGrid.DataBind()


            RadMultiPage1.SelectedIndex = 1
            RadTabStrip1.SelectedIndex = 1
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error generating report", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error generating the report")
            RadNotification1.Show()
        End Try
    End Sub
End Class