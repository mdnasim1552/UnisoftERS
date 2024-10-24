Imports DevExpress.CodeParser
Imports Telerik.Web.UI
Public Class PatientsList
    Inherits System.Web.UI.UserControl
    Dim showGridOnLoad As Boolean
    Dim showPostCode As String = ConfigurationManager.AppSettings("ShowPostCode")
    Public intMinSearchOptionRequired As Integer = 1

    'Flag to switch between NHS, HSE & HSC numbers depending on the country. Current values: UK, IRL or NI
    'NHS: UK (England, Scotland & Wales)
    'HSE: IRL (Republic of Ireland)
    'HSC: NI (NorthernIreland|)
    Private ReadOnly Property CountryOfOriginHealthService As String
        Get
            Return Session(Constants.SESSION_HEALTH_SERVICE_NAME)
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim op As New Options
        intMinSearchOptionRequired = op.MinimumPatientSearchOption()

        'MH added on 03 Nov 2021 - Scottish Hospital does not need this edit patient button
        If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
            AddPatientButton.Visible = False
        End If
        If Not IsPostBack Then
            LoadGenderCombo()
            VisiblePostCode() '//redo 1578
        End If

        Dim countryOfOriginHealthServiceName = Session(Constants.SESSION_HEALTH_SERVICE_NAME)
        CountryOfOriginHealthServiceNoRadTextBox.Label = countryOfOriginHealthServiceName + " no: "
        CountryOfOriginHealthServiceNoRadTextBox.EmptyMessage = "Enter [" + countryOfOriginHealthServiceName + " no]"

    End Sub
    Private Sub VisiblePostCode() '//redo 1578
        If Not String.IsNullOrEmpty(showPostCode) AndAlso
            showPostCode.ToLower() = "y" Then
            PostCodeTextBox.Visible = True
        End If
    End Sub
    Private Sub LoadGenderCombo()
        Dim dtGenders As New DataTable
        Dim da As New DataAccess
        dtGenders = da.GetGenderList()
        Dim strCode As String = ""
        Dim strTitle As String = ""

        GenderCombobox.Items.Clear()
        GenderCombobox.Items.Add(New RadComboBoxItem("", ""))

        If dtGenders.Rows.Count > 0 Then
            For Each drd As DataRow In dtGenders.Rows
                strCode = ""
                strTitle = ""
                If Not IsNothing(drd("Code")) Then
                    strCode = drd("Code").ToString()
                End If
                If Not IsNothing(drd("Title")) Then
                    strTitle = drd("Title").ToString()
                End If

                If strCode <> "" And strTitle <> "" Then
                    GenderCombobox.Items.Add(New RadComboBoxItem(strTitle, strCode))
                End If
            Next
        End If

    End Sub

    Private Sub PatientsList_Init(sender As Object, e As EventArgs) Handles Me.Init
        If Not IsPostBack Then
            AddPatientButton.Attributes.Add("onclick", "OpenPopUpWindow('PatientDetails', true);")
            PASDownloadButton.Attributes.Add("onclick", "OpenPopUpWindow('PASDownload');")

            showGridOnLoad = True
            'Session("HelpTooltipElementId") = RadSearchBox1.ClientID
            'Session("HelpMessage") = "Add criteria in the Search box and click on search button."

            'Session("HelpTooltipElementId") = CaseNoteNoTextBox.ClientID
            'Session("HelpMessage") = "Add criteria in the Search boxes and click on search button."

            If Not String.IsNullOrWhiteSpace(Session("FailedProceduresMessage")) Then
                Session("HelpTooltipElementId") = CaseNoteNoTextBox.ClientID
                Dim script As String = "alert('" + CStr(Session("FailedProceduresMessage")) + "');"
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "key", script, True)

                Session("FailedProceduresMessage") = Nothing
            End If

        End If

        LoadSearchComboBox()

        If CBool(Session("isERSViewer")) Then
            PASDownloadButton.Visible = False
            AddPatientButton.Visible = False
        End If

        'Querystring "CNN" implemented for Beacon hospital (3001)
        If Not IsPostBack AndAlso Request.QueryString("CNN") IsNot Nothing Then
            Dim cnn As String = CStr(Request.QueryString("CNN"))

            'RadSearchBox1.SearchContext.SelectedIndex = 0
            'RadSearchBox1.Text = cnn
            CaseNoteNoTextBox.Text = cnn
            showGridOnLoad = True

            'Me.Page.GetType.InvokeMember("BindPatientGrid", System.Reflection.BindingFlags.InvokeMethod, Nothing, Me.Page, {RadSearchBox1.SearchContext.SelectedItem.Text, cnn})
            Me.Page.GetType.InvokeMember("BindPatientGrid", System.Reflection.BindingFlags.InvokeMethod, Nothing, Me.Page, {"cnn", cnn})
        End If
    End Sub

    Protected Sub LoadSearchComboBox()

        Dim da As New DataAccess
        Dim arrLabel() As String = {"CNN", "NHSNo", "Surname", "Forename"}
        For i = 1 To 4
            Dim itemData As New SearchContextItem()
            itemData.Text = da.GetCountryLabel(arrLabel(i - 1))
            If itemData.Text = "" Then
                itemData.Text = arrLabel(i - 1)
            End If
            itemData.Key = i
            'RadSearchBox1.SearchContext.Items.Add(itemData)
            'Select Case i
            '    Case 1
            '        CaseNoteNoTextBox.Label = itemData.Text & " :"
            '        CaseNoteNoTextBox.EmptyMessage = "Enter [" & itemData.Text & "]"
            '        'PatientsGrid.Columns(1).HeaderText = itemData.Text
            '        RadSearchBox1.SearchContext.Items(0).Text = itemData.Text
            '    Case 2
            '        NHSNoTextBox.Label = itemData.Text & " :"
            '        NHSNoTextBox.EmptyMessage = "Enter [" & itemData.Text & "]"
            '        RadSearchBox1.SearchContext.Items(1).Text = itemData.Text
            '    Case 3
            '        SurnameTextBox.Label = itemData.Text & " :"
            '        SurnameTextBox.EmptyMessage = "Enter [" & itemData.Text & "]"
            '        RadSearchBox1.SearchContext.Items(2).Text = itemData.Text
            '    Case 4
            '        ForenameTextBox.Label = itemData.Text & " :"
            '        ForenameTextBox.EmptyMessage = "Enter [" & itemData.Text & "]"
            '        RadSearchBox1.SearchContext.Items(3).Text = itemData.Text
            'End Select

        Next i

    End Sub

    Private Sub PASDownloadButton_Click(sender As Object, e As EventArgs) Handles PASDownloadButton.Click
        Dim sm As New SessionManager
        sm.ClearPatientSessions()
        EnableEditPatientMenu(False)
        'PatientsGrid.Style("Display") = "None"
    End Sub

    Public Sub EnableEditPatientMenu(ByVal enable As Boolean)
        Dim menu = CType(FindControl("UnisoftMenu"), RadMenu)
        If menu IsNot Nothing Then
            Dim menuitem = CType(menu.FindItemByText("Edit Patient"), RadMenuItem)
            If menuitem IsNot Nothing Then
                menuitem.Enabled = enable
            End If
        End If
    End Sub

    Private Sub PatientsList_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
        If Not String.IsNullOrEmpty(Request.QueryString("patient")) Then
            EnableEditPatientMenu(True)
        End If
    End Sub

    Protected Sub RadSearchBox1_Search(sender As Object, e As SearchBoxEventArgs)
        'hideRightPanel()
        'If Not e.Text Is Nothing Then
        '    Dim sm As New SessionManager
        '    sm.ClearPatientSessions()

        '    Session(Constants.SESSION_SEARCH_TAB) = "1"

        '    Dim searchFields As New Dictionary(Of String, String)
        '    searchFields.Add("SearchBoxText", e.Text)

        '    Dim optionType = radCBSearchType.SelectedItem.Text
        '    searchFields.Add("SearchTerm", optionType)

        '    If RadSearchBox1.SearchContext.SelectedIndex = -1 Or IsNothing(RadSearchBox1.SearchContext.SelectedItem) Then
        '        searchFields.Add("SearchType", "ALL")
        '        Session(Constants.SESSION_PATIENT_SEARCH_FIELDS) = searchFields
        '        Me.Page.GetType.InvokeMember("BindPatientGrid", System.Reflection.BindingFlags.InvokeMethod, Nothing, Me.Page, {"", e.Text})
        '    Else
        '        searchFields.Add("SearchType", RadSearchBox1.SearchContext.SelectedItem.Text)
        '        Session(Constants.SESSION_PATIENT_SEARCH_FIELDS) = searchFields
        '        Me.Page.GetType.InvokeMember("BindPatientGrid", System.Reflection.BindingFlags.InvokeMethod, Nothing, Me.Page, {RadSearchBox1.SearchContext.SelectedItem.Text, e.Text})
        '    End If
        '    'If Session("isERSViewer") Then PatientsGrid.Height = "490" Else PatientsGrid.Height = "425"
        'End If

        ''Session("HelpTooltipElementId") = PatientsGridSection.ClientID
        'Session("HelpMessage") = "Click on a patient record to see the existing procedures or add a new procedure."
    End Sub

    Sub hideRightPanel()
        'LandingPageView.Selected = True
        'PatientsGrid.Style("Display") = "None"
        'PatientListHeaderDiv.Style("Display") = "None"
        Dim sm As New SessionManager
        sm.ClearPatientSessions()
    End Sub

    Private Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        SearchPatients()
    End Sub

    Sub SearchPatients()
        Dim sm As New SessionManager
        sm.ClearPatientSessions()

        Session("HelpTooltipElementId") = Nothing
        Session("HelpMessage") = Nothing
        Session("ShowToolTips") = False
        'Dim script As String = "LoadHelpTip(""" + CStr(Session("HelpTooltipElementId")) + """, """ + CStr(Session("HelpMessage")) + """);"
        'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "key", script, True)

        hideRightPanel()
        Session(Constants.SESSION_SEARCH_TAB) = "2" 'Advanced Search
        'If Session("isERSViewer") Then PatientsGrid.Height = "377" Else PatientsGrid.Height = "312"

        Dim optionCondition As String
        If RblSearch.SelectedIndex = 0 Then
            optionCondition = "AND"
        Else
            optionCondition = "OR"
        End If

        'Dim optionType = radCBSearchType.Selecteditem.Text

        'build search string 
        Dim searchFields As New Dictionary(Of String, String)
        searchFields.Add("SearchBoxText", "")
        searchFields.Add("SearchCondition", optionCondition)
        searchFields.Add("SearchTerm", "contains")
        searchFields.Add("CaseNoteNo", Trim(CaseNoteNoTextBox.Text))
        searchFields.Add("NHSNo", Trim(CountryOfOriginHealthServiceNoRadTextBox.Text))
        searchFields.Add("Surname", Trim(SurnameTextBox.Text))
        searchFields.Add("Forename", Trim(ForenameTextBox.Text))
        searchFields.Add("DOB", If(DOBTextBox.SelectedDate, ""))
        searchFields.Add("Address", "") 'Trim(AddressTextBox.Text))
        searchFields.Add("Postcode", If(Not String.IsNullOrEmpty(showPostCode) AndAlso
            showPostCode.ToLower() = "y", Trim(PostCodeTextBox.Text), "")) '//redo 1578
        searchFields.Add("IncludeDeceased", IncludeDeceasedCheckbox.Checked)
        searchFields.Add("Gender", GenderCombobox.SelectedValue.ToString())
        Session(Constants.SESSION_PATIENT_SEARCH_FIELDS) = searchFields

        Me.Page.GetType.InvokeMember("BindPatientGrid", System.Reflection.BindingFlags.InvokeMethod, Nothing, Me.Page, {Nothing, Nothing})
    End Sub
End Class
