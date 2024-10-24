Imports Telerik.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI
Imports System.Web
Imports System.Drawing
Imports xls = Telerik.Web.UI.ExportInfrastructure
Imports System.IO
Imports System.Data.OleDb
Imports System.Linq
Imports System.Globalization
Imports System.Data.SqlClient
Imports System.Web.Services
Imports Telerik.Web.UI.GridExcelBuilder

Public Class ListAnalysisMain
    Inherits System.Web.UI.Page


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
                LoadDefaultsFromDB()
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

#Region "Library"""

    Private Sub LoadDefaultsFromDB()
        Dim DT1 As New DataTable

        DT1 = Reporting.GetReportFilterDefaults(Session("PKUserId").ToString)

        If DT1.Rows.Count > 0 Then
            Dim Row = DT1.Rows(0)
            Try
                'pTypeOfConsultant = Row("TypesOfEndoscopists").ToString
                RDPFrom.SelectedDate = Row("FromDate").ToString
                RDPTo.SelectedDate = Row("ToDate").ToString
                'pHideSuppressed = CBool(Row("HideSuppressed").ToString)
                chkPatientTherapeutics.Checked = CBool(Row("IncludeTherapeutics").ToString)
                chkPatientIndications.Checked = CBool(Row("IncludeIndications").ToString)
                DateOrderRadioButton.SelectedValue = Row("DateOrder").ToString
                PatientStatusRadioButton.SelectedValue = Row("PatientStatus").ToString
                NhsVsPrivateRadioButton.SelectedValue = Row("NHSStatus").ToString
                chkSummaryDiagThera.Checked = CBool(Row("TherapeuticDiagnostic").ToString)
                chkPatientAnon.Checked = CBool(Row("Anonymise").ToString)
                'chkListPatients.Checked = CBool(Row("ListOfPatients").ToString)
                'pAnonymise = CBool(Row("Anonymise").ToString)
                'pIncludeTherapeutics = CBool(Row("IncludeTherapeutics").ToString)
                'pIncludeIndications = CBool(Row("IncludeIndications").ToString)
                'pSummaryForPeriod = CBool(Row("SummaryForPeriod").ToString)
                'pShowDiagnosisVsTherapeutics = CBool(Row("ShowDiagnosisVsTherapeutics").ToString)

            Catch ex As Exception
                RDPFrom.SelectedDate = "01/01/2018"
                RDPTo.SelectedDate = "30/12/2099"
            End Try
        Else
            RDPFrom.SelectedDate = "01/01/2018"
            RDPTo.SelectedDate = "30/12/2099"
        End If
        Dim da As New DataAccess
        DT1.Dispose()


    End Sub

#End Region

#Region "Buttons"
    Protected Sub RadButtonFilter_Click(sender As Object, e As EventArgs) Handles RadButtonFilter.Click
        Try
            If chkListPatients.Checked Then
                patientOptions.Style.Item("Display") = "block"
            Else
                patientOptions.Style.Item("Display") = "none"
            End If
            If chkSummaryForPeriod.Checked Then
                summaryOptions.Style.Item("Display") = "block"
            Else
                summaryOptions.Style.Item("Display") = "none"
            End If

            If RadListBox1.CheckedItems.Count = 0 Then
                RadNotification1.Show("No consultant(s) selected!")
                Exit Sub
            End If
            If CDate(RDPFrom.SelectedDate.ToString) > CDate(RDPTo.SelectedDate.ToString) Then
                RadNotification1.Show("End date must be after the start date")
                Exit Sub
            End If

            'Save the defaults selected
            Dim operatingHospitalList As String = ""
            For Each Item As RadComboBoxItem In OperatingHospitalsRadComboBox.CheckedItems
                operatingHospitalList = operatingHospitalList + "," + Item.Value.ToString()
            Next
            Reporting.SaveReportFilterDefaults(Session("PKUserId").ToString, RDPFrom.SelectedDate, RDPTo.SelectedDate, DateOrderRadioButton.SelectedValue, PatientStatusRadioButton.SelectedValue, NhsVsPrivateRadioButton.SelectedValue, chkPatientAnon.Checked, chkPatientTherapeutics.Checked, chkPatientIndications.Checked, chkSummaryDiagThera.Checked, optEndoscopistConsultant.SelectedValue, operatingHospitalList)
            Dim consultantList As String = ""
            For Each Item As RadListBoxItem In RadListBox1.CheckedItems
                consultantList = consultantList + "," + Item.Value.ToString
            Next
            Reporting.SaveReportConsultants(Session("PKUserId").ToString, consultantList)

            'Run the report(s) selected
            Dim radGrid_pre As RadGrid = RadGridListPatients
            radGrid_pre.ExportSettings.Excel.Format = GridExcelExportFormat.Html
            Dim dt_pre = Reporting.GetListPatientReport(Session("PKUserId").ToString)
            radGrid_pre.DataSource = dt_pre
            radGrid_pre.Rebind()
            RadPageListPatient.Controls.Add(radGrid_pre)
            RadTabStrip2.SelectedIndex = 0
            RadMultiPage2.SelectedIndex = 0
            If chkListPatients.Checked Then

                'Dim radGrid As RadGrid = RadGridListPatients
                'radGrid.ExportSettings.Excel.Format = GridExcelExportFormat.Html
                'Dim dt = Reporting.GetListPatientReport(Session("PKUserId").ToString)
                'radGrid.DataSource = dt
                'radGrid.Rebind()
                'RadPageListPatient.Controls.Add(radGrid)
                RadTabStrip2.Tabs(0).Visible = True
                'RadTabStrip2.SelectedIndex = 0
                'RadMultiPage2.SelectedIndex = 0
            Else
                RadTabStrip2.Tabs(0).Visible = False
            End If
            If chkSummaryForPeriod.Checked Then
                Dim radGrid As RadGrid = RadGridSummary
                radGrid.ExportSettings.Excel.Format = GridExcelExportFormat.Html
                Dim dt = Reporting.GetListSummaryReport(Session("PKUserId").ToString)
                radGrid.DataSource = dt
                radGrid.Rebind()
                RadTabStrip2.Tabs(1).Visible = True
                RadTabStrip2.SelectedIndex = 1
                RadMultiPage2.SelectedIndex = 1
            Else
                RadTabStrip2.Tabs(1).Visible = False
            End If
            RadMultiPage1.SelectedIndex = 1
            RadTabStrip1.SelectedIndex = 1
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error generating report", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error generating the report")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub OperatingHospitalsRadComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        e.Item.Checked = True
    End Sub

#End Region

    Protected Sub RadGrid_ExcelMLExportStylesCreated(ByVal sender As Object, ByVal e As GridExcelBuilder.GridExportExcelMLStyleCreatedArgs) Handles RadGridListPatients.ExcelMLExportStylesCreated, RadGridSummary.ExcelMLExportStylesCreated
        Dim numberStyle As New StyleElement("NumberStyle")
        numberStyle.NumberFormat.FormatType = NumberFormatType.General
        e.Styles.Add(numberStyle)

        Dim percentStyle As New StyleElement("PercentStyle")
        percentStyle.NumberFormat.FormatType = NumberFormatType.Percent
        e.Styles.Add(percentStyle)

        Dim currencyStyle As New StyleElement("CurrencyStyle")
        currencyStyle.NumberFormat.FormatType = NumberFormatType.Currency
        e.Styles.Add(currencyStyle)
    End Sub

    Protected Sub RadGridListPatients_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim dt = Reporting.GetListPatientReport(Session("PKUserId").ToString)
        RadGridListPatients.DataSource = dt
    End Sub

    Protected Sub RadGridSummary_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)


        Dim dt = Reporting.GetListSummaryReport(Session("PKUserId").ToString)
        RadGridSummary.DataSource = dt
    End Sub
End Class