Public Class StartupConfiguration
    Inherits System.Web.UI.UserControl

    Private _optionsDataAdapter As Options = Nothing
    Protected ReadOnly Property OptionsDataAdapter() As Options
        Get
            If _optionsDataAdapter Is Nothing Then
                _optionsDataAdapter = New Options
            End If
            Return _optionsDataAdapter
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        ProcedureTypesDataSource.ConnectionString = DataAccess.ConnectionStr
        If Not IsPostBack Then
            OptionFromRadDateInput.SelectedDate = Now.Date
            loadForm()
        End If
    End Sub

    Sub loadForm()
        Dim dtSys As DataTable = OptionsDataAdapter.GetStartupSettings()
        If dtSys.Rows.Count > 0 Then
            Dim dr As DataRow = dtSys.Rows(0)
            HideStartupChartsCheckBox.Checked = CBool(dr("HideStartupCharts"))
            If CBool(dr("ShowWorklistOnStartup")) Then
                WorklistCheckbox.Checked = True
            End If

            Select Case CInt(dr("SearchCriteriaOption"))
                Case 1
                    OptionAllRadioButton.Checked = True
                Case 2
                    OptionOnlyLastRadioButton.Checked = True
                    OptionOnlyLastRadNumericTextBox.Text = dr("SearchCriteriaOptionPatientCount")
                    OptionOnlyLastRadNumericTextBox.Enabled = True
                Case 3
                    OptionFromRadioButton.Checked = True
                    OptionFromRadDateInput.SelectedDate = CDate(dr("SearchCriteriaOptionDate"))
                    OptionFromRadDateInput.Enabled = True
                Case 4
                    OptionLastRadioButton.Checked = True
                    OptionLastRadNumericTextBox.Text = dr("SearchCriteriaOptionMonths")
                    OptionLastRadNumericTextBox.Enabled = True
            End Select
            DeadCheckBox.Checked = CBool(dr("ExcludeDeadOption"))
            OldProcCheckBox.Checked = CBool(dr("ExcludeUGI"))
            AllProcCheckBox.Checked = CBool(dr("AllProcedures"))
            GastroCheckBox.Checked = CBool(dr("Gastroscopy"))
            ERCPCheckBox.Checked = CBool(dr("ERCP"))
            ColonCheckBox.Checked = CBool(dr("Colonoscopy"))
            ProctoCheckBox.Checked = CBool(dr("Proctoscopy"))
            CLOCheckBox.Checked = CBool(dr("OutstandingCLO"))

            Select Case CInt(dr("OrderListOptions"))
                Case 1
                    ReverseRadioButton.Checked = True
                Case 2
                    AlphabetRadioButton.Checked = True
            End Select

        End If
    End Sub

    Protected Sub saveData()
        Try
            Dim SearchCriteria As Integer = 1

            Dim ShowWorklistOnStartup As Boolean = False
            If WorklistCheckbox.Checked Then
                ShowWorklistOnStartup = True
            End If

            Dim SearchCriteriaOption As Integer
            Dim SearchCriteriaOptionPatientCount As Integer
            Dim SearchCriteriaOptionDate As Nullable(Of Date) = Nothing
            Dim SearchCriteriaOptionMonths As Integer

            If OptionAllRadioButton.Checked Then
                SearchCriteriaOption = 1
            ElseIf OptionOnlyLastRadioButton.Checked Then
                SearchCriteriaOption = 2
                SearchCriteriaOptionPatientCount = CInt(OptionOnlyLastRadNumericTextBox.Text)
            ElseIf OptionFromRadioButton.Checked Then
                SearchCriteriaOption = 3
                SearchCriteriaOptionDate = OptionFromRadDateInput.SelectedDate
            ElseIf OptionLastRadioButton.Checked Then
                SearchCriteriaOption = 4
                SearchCriteriaOptionMonths = CInt(OptionLastRadNumericTextBox.Text)
            End If
            Dim ExcludeDeadOption As Boolean = DeadCheckBox.Checked
            Dim OldProcOption As Boolean = OldProcCheckBox.Checked
            Dim AllProcedures As Boolean = AllProcCheckBox.Checked
            Dim Gastroscopy As Boolean = GastroCheckBox.Checked
            Dim ERCP As Boolean = ERCPCheckBox.Checked
            Dim Colonoscopy As Boolean = ColonCheckBox.Checked
            Dim Proctoscopy As Boolean = ProctoCheckBox.Checked
            Dim OutstandingCLO As Boolean = CLOCheckBox.Checked
            Dim HideStartupCharts As Boolean = HideStartupChartsCheckBox.Checked
            Dim OrderListOptions As Integer
            If ReverseRadioButton.Checked Then
                OrderListOptions = 1
            ElseIf AlphabetRadioButton.Checked Then
                OrderListOptions = 2
            End If

            OptionsDataAdapter.SaveStartupSettings(SearchCriteria, SearchCriteriaOption, SearchCriteriaOptionPatientCount, SearchCriteriaOptionDate, SearchCriteriaOptionMonths, ExcludeDeadOption, OldProcOption, OrderListOptions, AllProcedures, Gastroscopy, ERCP, Colonoscopy, Proctoscopy, OutstandingCLO, ShowWorklistOnStartup, HideStartupCharts, CInt(Session("PKUserId")), CInt(Session("OperatingHospital")))
            Utilities.SetNotificationStyle(RadNotification1, "Settings saved successfully.")
            RadNotification1.Show()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving System Settings under Options.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class