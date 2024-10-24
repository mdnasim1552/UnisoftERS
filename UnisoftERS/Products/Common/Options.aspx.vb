Imports Telerik.Web.UI
Imports System.Data.SqlClient

Partial Class Products_Common_Options
    Inherits PageBase

    Private conn As SqlConnection = Nothing
    Private reader As SqlDataReader = Nothing
    Private newUserId As Integer

    Private ReadOnly Property SelectedNodeValue As String
        Get
            Return CStr(Request.QueryString("nodevalue"))
        End Get
    End Property


    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            InitForm() ' TODO - FIX THIS LATER
            LoadTreeView()
            UserDetailsFormView.DefaultMode = FormViewMode.Insert
            UserDetailsFormView.ChangeMode(FormViewMode.Insert)
        End If

        If SelectedNodeValue = "1" Then
            RadMultiPage.FindPageViewByID("rvPage1").Selected = True
        ElseIf SelectedNodeValue = "2" Then
            RadMultiPage.FindPageViewByID("rvPage2").Selected = True
        ElseIf SelectedNodeValue = "3" Then
            RadMultiPage.FindPageViewByID("rvPage3").Selected = True
        ElseIf SelectedNodeValue = "4" Then
            RadMultiPage.FindPageViewByID("rvPage4").Selected = True
        ElseIf SelectedNodeValue = "5" Then
            RadMultiPage.FindPageViewByID("rvPage5").Selected = True
        ElseIf SelectedNodeValue = "54" Then
            RadMultiPage.FindPageViewByID("rvPage54").Selected = True
        ElseIf SelectedNodeValue = "55" Then
            RadMultiPage.FindPageViewByID("SystemUsagePageView").Selected = True
        ElseIf SelectedNodeValue = "6" Then
            'RadMultiPage.FindPageViewByID("rvPage6").Selected = True
            'ButtonsRadPane.Visible = False
            radPaneRight.ContentUrl = Page.ResolveUrl("~/Products/Options/UserMaintenance.aspx")
        Else
            RadMultiPage.FindPageViewByID("rvPage1").Selected = True
        End If

        'If selectedNodeName = "User Settings" Then
        '    RadMultiPage.FindPageViewByID("rvPage1").Selected = True
        'ElseIf selectedNodeName = "System Settings" Then
        '    RadMultiPage.FindPageViewByID("rvPage2").Selected = True
        'ElseIf selectedNodeName = "Export Settings" Then
        '    RadMultiPage.FindPageViewByID("rvPage3").Selected = True
        'ElseIf selectedNodeName = "Database Settings" Then
        '    RadMultiPage.FindPageViewByID("rvPage4").Selected = True
        'ElseIf selectedNodeName = "Admin Utilties" Then
        '    RadMultiPage.FindPageViewByID("rvPage5").Selected = True
        'ElseIf selectedNodeName = "User Maintenance" Then
        '    RadMultiPage.FindPageViewByID("rvPage6").Selected = True
        '    'ButtonsRadPane.Visible = False
        'Else
        '    RadMultiPage.FindPageViewByID("rvPage1").Selected = True
        'End If

        If Me.Master.FindControl("UnisoftMenu") IsNot Nothing Then
            Dim UnisoftMenu As RadMenu = DirectCast(Master.FindControl("UnisoftMenu"), RadMenu)
            UnisoftMenu.LoadContentFile("~/App_Data/Menus/01bMenu.xml")
        End If
        'RadMultiPage.FindPageViewByID()
        'Page.ClientScript.RegisterStartupScript(Me.GetType(), "CallMyFunction", "alert(window.innerWidth);alert(window.innerHeight);", True)
        If Me.Master.FindControl("SummaryPreviewDiv") IsNot Nothing Then
            Dim SummaryPreviewDiv As HtmlGenericControl = DirectCast(Master.FindControl("SummaryPreviewDiv"), HtmlGenericControl)
            SummaryPreviewDiv.Visible = False
        End If
        If Me.Master.FindControl("Div2") IsNot Nothing Then
            Dim Div2 As HtmlGenericControl = DirectCast(Master.FindControl("Div2"), HtmlGenericControl)
            Div2.Visible = False
        End If

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(RequiredFieldsGrid, RequiredFieldsGrid)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(LoggedInUsersGrid, LoggedInUsersGrid)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(LockedPatientsGrid, LockedPatientsGrid)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(UsersRadGrid, UserDetailsFormView)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(UserDetailsFormView, RadNotification1)
    End Sub

    Protected Sub InitForm()
        ''If SelectedNodeValue = "54" Then
        ''    Dim da As New DataAccess
        ''    Utilities.LoadDropdown(ProcedureComboBox, da.GetProcedureTypes(), "List item text", "List item no", "")
        ''    Utilities.LoadDropdown(PageNameComboBox, da.GetRequiredFieldsPages(), "PageName", "PageName", "")
        ''End If

        ''TSOptions.Tabs(0).Visible = False
        'Dim ConnString As [String] = uniAdaptor.ConnectionString
        'conn = New SqlConnection(ConnString)
        'conn.Open()

        'Dim cmdString As String = "SELECT * FROM [SystemConfig] WHERE [OperatingHospitalID] = 1;"
        'Dim cmd As New SqlCommand(cmdString, conn)
        'Dim myReader As SqlDataReader

        'Try
        '    myReader = cmd.ExecuteReader()
        '    If myReader.HasRows Then
        '        Do While myReader.Read
        '            'Loading ImGrab settings
        '            If myReader("ImGrab Enabled") = True Then
        '                optImGrabOn.Checked = True
        '            Else
        '                optImGrabOff.Checked = True
        '            End If
        '        Loop
        '    End If
        '    myReader.Close()
        'Catch ex As Exception

        'Finally
        '    conn.Close()
        'End Try
    End Sub

    'Protected Sub cmdCancel_Click(sender As Object, e As System.EventArgs) Handles cmdCancel.Click

    'End Sub

    Protected Sub rtsAdminUtils_TabClick(sender As Object, e As RadTabStripEventArgs) Handles rtsAdminUtils.TabClick

    End Sub

    'Protected Sub cmdOK_Click(sender As Object, e As System.EventArgs) Handles cmdOK.Click
    '    Call uniAdaptor.updateRecords("UPDATE [SystemConfig] SET [ImGrab Enabled] = " & IIf(optImGrabOn.Checked = True, 1, 0))
    'End Sub

    Protected Sub LoadTreeView()
        If Me.Master.FindControl("LeftMenuRadTreeView") IsNot Nothing Then
            Dim LeftMenuRadTreeView As RadTreeView = DirectCast(Master.FindControl("LeftMenuRadTreeView"), RadTreeView)

            Dim rootNode As New RadTreeNode("Options")
            rootNode.Expanded = True

            rootNode.Nodes.Add(New RadTreeNode("User Settings", "~/Products/Common/Options.aspx?nodevalue=1"))
            rootNode.Nodes.Add(New RadTreeNode("System Settings", "~/Products/Common/Options.aspx?nodevalue=2"))
            rootNode.Nodes.Add(New RadTreeNode("Export Settings", "~/Products/Common/Options.aspx?nodevalue=3"))
            rootNode.Nodes.Add(New RadTreeNode("Database Settings", "~/Products/Common/Options.aspx?nodevalue=4"))

            Dim nodeWithSubNodes As New RadTreeNode("Admin Utilities", "~/Products/Common/Options.aspx?nodevalue=5")
            nodeWithSubNodes.Nodes.Add(New RadTreeNode("Registration Details", "~/Products/Common/Options.aspx?nodevalue=51"))
            nodeWithSubNodes.Nodes.Add(New RadTreeNode("Password Rules", "~/Products/Common/Options.aspx?nodevalue=52"))
            nodeWithSubNodes.Nodes.Add(New RadTreeNode("NHS No Validation", "~/Products/Common/Options.aspx?nodevalue=53"))
            nodeWithSubNodes.Nodes.Add(New RadTreeNode("Required Fields Setup", "~/Products/Common/Options.aspx?nodevalue=54"))
            nodeWithSubNodes.Nodes.Add(New RadTreeNode("System Usage", "~/Products/Common/Options.aspx?nodevalue=55"))
            rootNode.Nodes.Add(nodeWithSubNodes)

            rootNode.Nodes.Add(New RadTreeNode("User Maintenance", "~/Products/Common/Options.aspx?nodevalue=6"))

            LeftMenuRadTreeView.Nodes.Add(rootNode)
        End If
    End Sub

    Protected Sub UsersRadGrid_SelectedIndexChanged(sender As Object, e As EventArgs) Handles UsersRadGrid.SelectedIndexChanged
        UserDetailsObjectDataSource.SelectParameters("UserId").DefaultValue = UsersRadGrid.SelectedValue.ToString()
        UserDetailsFormView.ChangeMode(FormViewMode.Edit)
        UserDetailsFormView.DataBind()
    End Sub

    Protected Sub UserDetailsFormView_Init(sender As Object, e As EventArgs) Handles UserDetailsFormView.Init
        If Not IsPostBack Then
            UserDetailsFormView.InsertItemTemplate = UserDetailsFormView.EditItemTemplate
        End If
    End Sub

    Protected Sub UserDetailsFormView_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles UserDetailsFormView.ItemCommand
        If e.CommandName = "Cancel" Then
            UsersRadGrid.SelectedIndexes.Clear()
            UserDetailsFormView.DefaultMode = FormViewMode.Insert
            UserDetailsFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub

    Protected Sub UserDetailsFormView_ItemCreated(sender As Object, e As EventArgs) Handles UserDetailsFormView.ItemCreated
        RefreshTitles()
    End Sub

    Protected Sub RefreshTitles()
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        Dim da As New DataAccess
        Dim dtTitles As DataTable = da.GetJobTitles()
        TitleRadDropDownList.DataTextField = "Description"
        TitleRadDropDownList.DataValueField = "JobTitleId"
        TitleRadDropDownList.DataSource = dtTitles
        TitleRadDropDownList.DataBind()
    End Sub

    'Protected Sub UserDetailsFormView_ItemCreated(sender As Object, e As EventArgs) Handles UserDetailsFormView.ItemCreated
    '    Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
    '    Dim rowView As DataRowView = CType(UserDetailsFormView.DataItem, DataRowView)
    '    ActiveCheckBox.Checked = Not CBool(rowView("Active"))
    'End Sub

    Protected Sub UserDetailsFormView_ItemInserting(sender As Object, e As FormViewInsertEventArgs) Handles UserDetailsFormView.ItemInserting
        Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        e.Values("active") = Not ActiveCheckBox.Checked
        e.Values("jobTitle") = TitleRadDropDownList.SelectedValue
    End Sub

    Protected Sub UserDetailsFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles UserDetailsFormView.ItemInserted
        UserDetailsFormView.DefaultMode = FormViewMode.Edit
        UserDetailsFormView.ChangeMode(FormViewMode.Edit)
        UsersRadGrid.DataBind()

        If newUserId > 0 Then
            For Each item As GridDataItem In UsersRadGrid.MasterTableView.Items
                If item.GetDataKeyValue("UserId") = newUserId Then
                    item.Selected = True
                End If
            Next

            UserDetailsObjectDataSource.SelectParameters("UserId").DefaultValue = newUserId
            UserDetailsFormView.DataBind()
        End If

        'ShowMsg()
    End Sub

    Protected Sub UserDetailsFormView_ItemUpdating(sender As Object, e As FormViewUpdateEventArgs) Handles UserDetailsFormView.ItemUpdating
        Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        e.NewValues("active") = Not ActiveCheckBox.Checked
        e.NewValues("jobTitle") = TitleRadDropDownList.SelectedValue
    End Sub

    Protected Sub UserDetailsFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles UserDetailsFormView.ItemUpdated
        If e.Exception Is Nothing Then
            UserDetailsFormView.DefaultMode = FormViewMode.Edit
            UserDetailsFormView.ChangeMode(FormViewMode.Edit)
            UsersRadGrid.DataBind()

            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        Else
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving user in the User Maintenance page.", e.Exception)

            e.ExceptionHandled = True
            e.KeepInEditMode = True

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End If
    End Sub

    Protected Sub UserDetailsFormView_PreRender(sender As Object, e As EventArgs) Handles UserDetailsFormView.PreRender
        Dim UpdateButton As RadButton

        If UserDetailsFormView.CurrentMode = FormViewMode.Edit Then
            UpdateButton = DirectCast(UserDetailsFormView.FindControl("UpdateButton"), RadButton)
            If UpdateButton IsNot Nothing Then UpdateButton.CommandName = "Update"

            Dim rowView As DataRowView = CType(UserDetailsFormView.DataItem, DataRowView)

            Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
            If ActiveCheckBox IsNot Nothing AndAlso rowView IsNot Nothing Then
                ActiveCheckBox.Checked = Not CBool(rowView("Active"))
            End If

            Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
            If TitleRadDropDownList IsNot Nothing AndAlso rowView IsNot Nothing Then
                If Not IsDBNull(rowView("JobTitle")) Then
                    TitleRadDropDownList.SelectedValue = CStr(rowView("JobTitle"))
                End If
            End If

        ElseIf UserDetailsFormView.CurrentMode = FormViewMode.Insert Then
            UpdateButton = DirectCast(UserDetailsFormView.FindControl("UpdateButton"), RadButton)
            If UpdateButton IsNot Nothing Then UpdateButton.CommandName = "Insert"
        End If
    End Sub

    Protected Sub UserDetailsObjectDataSource_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles UserDetailsObjectDataSource.Inserted
        newUserId = CInt(e.ReturnValue)
    End Sub

    Protected Sub AddNewTitleSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewTitleSaveRadButton.Click
        Dim da As New DataAccess
        If AddNewTitleRadTextBox.Text <> "" Then
            da.InsertJobTitle(AddNewTitleRadTextBox.Text)
            AddNewTitleRadTextBox.Text = ""
        End If

        RefreshTitles()

        Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddTitleWindow();", True)
    End Sub

    'Protected Sub ShowMsg()
    '    If CBool(Session("UpdateDBFailed")) Then
    '        Dim errorLogRef As String
    '        errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Deformity.", ex)

    '        Utilities.SetErrorNotificationStyle(RadNotification1, ex, errorLogRef, "There is a problem saving data.")
    '        RadNotification1.Show()

    '        Exit Sub
    '    End If

    '    Utilities.SetNotificationStyle(RadNotification1)
    '    RadNotification1.Show()
    'End Sub

    Protected Sub RequiredCheckBox_CheckedChanged(sender As Object, e As EventArgs)
        Dim chkbox As CheckBox = DirectCast(sender, CheckBox)
        Dim row As GridDataItem = DirectCast(chkbox.NamingContainer, GridDataItem)
        Dim reqFldId As Integer = CInt(row.GetDataKeyValue("RequiredFieldId"))

        Dim da As New Options
        da.UpdateRequiredFields(reqFldId, chkbox.Checked)
    End Sub

    Protected Sub ReqFieldsObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles ReqFieldsObjectDataSource.Selected
        'Utilities.LoadDropdown(ProcedureComboBox, DirectCast(e.ReturnValue, DataTable), "ProcedureTypeText", "ProcedureType", "")
        ViewState("DataTable") = e.ReturnValue
    End Sub

    Protected Sub RequiredFieldsGrid_ItemCreated(sender As Object, e As GridItemEventArgs) Handles RequiredFieldsGrid.ItemCreated
        If e.Item.ItemType = GridItemType.FilteringItem Then
            If ViewState("DataTable") IsNot Nothing Then
                Dim row As GridFilteringItem = DirectCast(e.Item, GridFilteringItem)
                Dim ProcedureTypeComboBox As RadComboBox = DirectCast(row.FindControl("ProcedureTypeComboBox"), RadComboBox)
                If ProcedureTypeComboBox IsNot Nothing Then
                    'Dim da As New DataAccess
                    'Utilities.LoadDropdown(ProcedureTypeComboBox, da.GetProcedureTypes(), "List item text", "List item no", "All")
                    Dim dt As DataTable = DirectCast(ViewState("DataTable"), DataTable)
                    Dim distinctDT As DataTable = dt.DefaultView.ToTable(True, "ProcedureType")

                    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ProcedureTypeComboBox, ""}}, distinctDT, "ProcedureType", "ProcedureType", False)
                    ProcedureTypeComboBox.Items.Insert(0, "All")
                    'Utilities.LoadDropdown(ProcedureTypeComboBox, distinctDT, "ProcedureType", "ProcedureType", "All", False)
                End If

                Dim PageNameComboBox As RadComboBox = DirectCast(row.FindControl("PageNameComboBox"), RadComboBox)
                If PageNameComboBox IsNot Nothing Then
                    Dim dt As DataTable = DirectCast(ViewState("DataTable"), DataTable)
                    Dim distinctDT As DataTable = dt.DefaultView.ToTable(True, "PageName")
                    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{PageNameComboBox, ""}}, distinctDT, "PageName", "PageName", False)
                    PageNameComboBox.Items.Insert(0, "All")
                    'Utilities.LoadDropdown(PageNameComboBox, distinctDT, "PageName", "PageName", "All", False)
                End If
            End If
            ViewState("DataTable") = Nothing

            'ElseIf e.Item.ItemType = GridItemType.AlternatingItem Or e.Item.ItemType = GridItemType.Item Then
            '    Dim item As GridDataItem
            '    item = e.Item
            '    Dim RequiredCheckBox As CheckBox
            '    RequiredCheckBox = item("RequiredColumn").FindControl("RequiredCheckBox")
            '    'RequiredCheckBox.Enabled = False
        End If
    End Sub

    Protected Sub ProcedureTypeComboBox_SelectedIndexChanged(o As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Dim ProcedureTypeComboBox As RadComboBox = TryCast(o, RadComboBox)

        'save the combo selected value  
        ViewState("ProcedureTypeComboBoxValue") = ProcedureTypeComboBox.SelectedValue

        ''filter the grid  
        'RadGrid1.MasterTableView.FilterExpression = "ProcedureType LIKE '%" + ProcedureTypeComboBox.SelectedValue & "%'"
        'RadGrid1.Rebind()
    End Sub

    Protected Sub ProcedureTypeComboBox_PreRender(sender As Object, e As EventArgs)
        'persist the combo selected value  
        If ViewState("ProcedureTypeComboBoxValue") IsNot Nothing Then
            Dim ProcedureTypeComboBox As RadComboBox = TryCast(sender, RadComboBox)
            ProcedureTypeComboBox.SelectedValue = ViewState("ProcedureTypeComboBoxValue").ToString()
        End If
    End Sub

    Protected Sub PageNameComboBox_SelectedIndexChanged(o As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Dim PageNameComboBox As RadComboBox = TryCast(o, RadComboBox)

        'save the combo selected value  
        ViewState("PageNameComboBoxValue") = PageNameComboBox.SelectedValue

        ''filter the grid  
        'RadGrid1.MasterTableView.FilterExpression = "ProcedureType LIKE '%" + PageNameComboBox.SelectedValue & "%'"
        'RadGrid1.Rebind()
    End Sub

    Protected Sub PageNameComboBox_PreRender(sender As Object, e As EventArgs)
        'Persist the combo selected value  
        If ViewState("PageNameComboBoxValue") IsNot Nothing Then
            Dim PageNameComboBox As RadComboBox = TryCast(sender, RadComboBox)
            PageNameComboBox.SelectedValue = ViewState("PageNameComboBoxValue").ToString()
        End If
    End Sub

    'Protected Sub LockedPatientsGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles LockedPatientsGrid.ItemCommand
    '    If e.CommandName = "Unlock" Then
    '        LockedPatientsObjectDataSource.UpdateParameters("patientId").DefaultValue = CStr(DirectCast(e.Item, GridDataItem).GetDataKeyValue("PatientId"))
    '        LockedPatientsObjectDataSource.Update()
    '    End If
    'End Sub

    'Protected Sub LockedPatientsGrid_ItemDeleted(sender As Object, e As GridDeletedEventArgs) Handles LockedPatientsGrid.ItemDeleted
    '    If e.Exception Is Nothing Then
    '        Utilities.SetNotificationStyle(RadNotification1, "Patient record unlocked successfully!")
    '        RadNotification1.Show()
    '    End If
    'End Sub

    'Protected Sub LoggedInUsersGrid_ItemDeleted(sender As Object, e As GridDeletedEventArgs) Handles LoggedInUsersGrid.ItemDeleted
    '    If e.Exception Is Nothing Then
    '        Utilities.SetNotificationStyle(RadNotification1, "This login has been removed successfully!")
    '        RadNotification1.Show()
    '    End If
    'End Sub
End Class
