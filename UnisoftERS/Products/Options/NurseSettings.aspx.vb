Imports Telerik.Web.UI
Imports Microsoft.VisualBasic
Imports System.Drawing
Imports System.Data.SqlClient

Partial Class Products_Options_NurseSettings
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            BindSectionDropdown()
            GetNurseModuleProcedure()
            DropdownOptionTextBox.Text = "Enter options separated by commas"
        End If
    End Sub
    Private Sub BindSectionDropdown()
        Dim dtSections As DataTable = GetSections()

        SectionDropdown.DataSource = dtSections
        SectionDropdown.DataTextField = "SectionName"
        SectionDropdown.DataValueField = "SectionId"
        SectionDropdown.DataBind()
        SectionDropdown.Items.Insert(0, New RadComboBoxItem("", ""))
    End Sub
    Private Function GetSections() As DataTable
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT SectionId, SectionName FROM ERS_NurseModuleSection where Suppressed = @suppressed", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@suppressed", 0))
            Dim adapter As New SqlDataAdapter(cmd)
            Dim dt As New DataTable()
            adapter.Fill(dt)
            Return dt
        End Using
    End Function
    Protected Sub AddNewItemSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewItemSaveRadButton.Click
        Dim da As New DataAccess
        Dim newItemId As Integer
        Dim sortOrder As Nullable(Of Integer) = Nothing
        Dim selectedProcedureType As Integer = NurseModuleProcedureTypeRadComboBox.SelectedValue
        If Not String.IsNullOrEmpty(SectionOrderTextBox.Text) Then
            sortOrder = CInt(SectionOrderTextBox.Text.Trim())
        End If
        If AddNewItemSaveRadButton.Text = "Update" Then
            da.UpdateNurseModuleSectionList(CInt(hiddenItemId.Value), AddNewItemRadTextBox.Text, selectedProcedureType, sortOrder, Nothing)
            SectionRadGrid.Rebind()
        ElseIf AddNewItemRadTextBox.Text <> "" Then
            newItemId = da.InsertNurseModuleSectionsItem(0, selectedProcedureType, AddNewItemRadTextBox.Text, sortOrder)
            AddNewItemRadTextBox.Text = ""
            SectionRadGrid.Rebind()
        End If
        BindSectionDropdown()
        QuestionRadGrid.Rebind()
        Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddItemWindow();", True)
    End Sub
    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            SectionRadGrid.MasterTableView.SortExpressions.Clear()
            SectionRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            SectionRadGrid.MasterTableView.SortExpressions.Clear()
            SectionRadGrid.MasterTableView.CurrentPageIndex = SectionRadGrid.MasterTableView.PageCount - 1
            SectionRadGrid.Rebind()
        ElseIf e.Argument = "RebindQuestion" Then
            QuestionRadGrid.MasterTableView.SortExpressions.Clear()
            QuestionRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigateQuestion" Then
            QuestionRadGrid.MasterTableView.SortExpressions.Clear()
            QuestionRadGrid.MasterTableView.CurrentPageIndex = QuestionRadGrid.MasterTableView.PageCount - 1
            QuestionRadGrid.Rebind()
        End If
    End Sub
    Protected Sub ListsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles SectionRadGrid.ItemCommand
        If e.CommandName = "SuppressItem" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter.SuppressNurseModuleSectionList(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("SectionId")), bSuppress)
            SectionRadGrid.Rebind()
        End If
    End Sub
    Protected Sub SectionRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles SectionRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
        e.Item.ItemType = GridItemType.AlternatingItem Then
            'Dim SuppressLinkButton As ImageButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), ImageButton)
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If CBool(row("Suppressed")) Then
                'SuppressLinkButton.Enabled = True
                SuppressLinkButton.ForeColor = Color.Gray
                'SuppressLinkButton.ImageUrl = "~/Images/suppress_grey.png"
                SuppressLinkButton.ToolTip = "Unsuppress this item"
                SuppressLinkButton.OnClientClick = ""
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0 ")
            End If
        End If
    End Sub
    Protected Sub SectionRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles SectionRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim sItemName As String = ""
            Dim sSortOrder As String = ""
            Dim procedureType As String = ""
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            If (DataBinder.Eval(e.Item.DataItem, "SectionName") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "SectionName").ToString())) Then
                sItemName = e.Item.DataItem("SectionName").ToString()
            Else
                sItemName = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "SortOrder") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "SortOrder").ToString())) Then
                sSortOrder = e.Item.DataItem("SortOrder").ToString()
            Else
                sSortOrder = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "ProcedureType") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "ProcedureType").ToString())) Then
                ProcedureType = e.Item.DataItem("ProcedureType").ToString()
            Else
                ProcedureType = ""
            End If
            EditLinkButton.Attributes("onclick") = String.Format("return openAddItemWindow('{0}','{1}','{2}','{3}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("SectionId"), sItemName, sSortOrder, procedureType)
        End If

        If TypeOf e.Item Is GridFooterItem Then

        End If
    End Sub
    Protected Sub QuestionRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles QuestionRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
        e.Item.ItemType = GridItemType.AlternatingItem Then
            'Dim SuppressLinkButton As ImageButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), ImageButton)
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If CBool(row("Suppressed")) Then
                'SuppressLinkButton.Enabled = True
                SuppressLinkButton.ForeColor = Color.Gray
                'SuppressLinkButton.ImageUrl = "~/Images/suppress_grey.png"
                SuppressLinkButton.ToolTip = "Unsuppress this item"
                SuppressLinkButton.OnClientClick = ""
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0 ")
            End If
        End If
    End Sub
    Protected Sub QuestionsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles QuestionRadGrid.ItemCommand
        If e.CommandName = "QuestionSuppressItem" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter.SuppressNurseModuleQuestionList(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("QuestionId")), bSuppress, Nothing, Nothing, Nothing, Nothing)
            QuestionRadGrid.Rebind()
        End If
    End Sub
    Protected Sub AddNewQuestionSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewQuestionSaveRadButton.Click
        Dim da As New DataAccess
        Dim newItemId As Integer
        Dim selectedSectionId As Integer = SectionDropdown.SelectedValue
        Dim sortOrder As Nullable(Of Integer) = Nothing

        If Not String.IsNullOrEmpty(questionSortOrder.Text) Then
            sortOrder = CInt(questionSortOrder.Text.Trim())
        End If
        If AddNewQuestionSaveRadButton.Text = "Update" Then
            da.UpdateNurseModuleQuestionList(CInt(HiddenItemId1.Value), selectedSectionId, AddNewQuestionRadTextBox.Text, chkOptionalRadComboBox.Checked, chkFreeTextRadComboBox.Checked, chkYesNoRadComboBox.Checked, DropdownOption.Checked, DropdownOptionTextBox.Text, Nothing, sortOrder)
            QuestionRadGrid.Rebind()
        ElseIf AddNewQuestionSaveRadButton.Text <> "" Then
            newItemId = da.InsertNurseModuleQuestionItem(selectedSectionId, AddNewQuestionRadTextBox.Text, chkOptionalRadComboBox.Checked, chkFreeTextRadComboBox.Checked, chkYesNoRadComboBox.Checked, DropdownOption.Checked, DropdownOptionTextBox.Text, False, sortOrder)
            AddNewItemRadTextBox.Text = ""
            QuestionRadGrid.Rebind()
        End If
        Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddQuestionWindow();", True)
    End Sub
    Protected Sub QuestionRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles QuestionRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim sQuestion As String = ""
            Dim sSectionId As String = ""
            Dim sOptional As Boolean = False
            Dim sFreeText As Boolean = False
            Dim sYesNo As Boolean = False
            Dim dropDownOption As Boolean = False
            Dim dropDownOptionText As String = ""
            Dim sortOrder As String = ""

            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditQLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            If (DataBinder.Eval(e.Item.DataItem, "Question") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "Question").ToString())) Then
                sQuestion = e.Item.DataItem("Question").ToString()
            Else
                sQuestion = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "SectionId") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "SectionId").ToString())) Then
                sSectionId = e.Item.DataItem("SectionId").ToString()
            Else
                sSectionId = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "Mandatory") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "Mandatory").ToString())) Then
                sOptional = e.Item.DataItem("Mandatory")
            Else
                sOptional = False
            End If
            If (DataBinder.Eval(e.Item.DataItem, "FreeText") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "FreeText").ToString())) Then
                sFreeText = e.Item.DataItem("FreeText")
            Else
                sFreeText = False
            End If
            If (DataBinder.Eval(e.Item.DataItem, "YesNo") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "YesNo").ToString())) Then
                sYesNo = e.Item.DataItem("YesNo")
            Else
                sYesNo = False
            End If
            If (DataBinder.Eval(e.Item.DataItem, "DropdownOption") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "DropdownOption").ToString())) Then
                dropDownOption = e.Item.DataItem("DropdownOption")
            Else
                dropDownOption = False
            End If
            If (DataBinder.Eval(e.Item.DataItem, "DropdownOptionText") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "DropdownOptionText").ToString())) Then
                dropDownOptionText = e.Item.DataItem("DropdownOptionText")
            Else
                dropDownOptionText = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "SortOrder") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "SortOrder").ToString())) Then
                sortOrder = e.Item.DataItem("SortOrder").ToString()
            Else
                sortOrder = ""
            End If
            EditLinkButton.Attributes("onclick") = String.Format("return openQuestionAddItemWindow('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("QuestionId"), sQuestion, sSectionId, sOptional, sFreeText, sYesNo, dropDownOption, dropDownOptionText, sortOrder)
        End If

        If TypeOf e.Item Is GridFooterItem Then

        End If
    End Sub
    Sub GetNurseModuleProcedure()
        Try
            NurseModuleProcedureTypeRadComboBox.Items.Clear()
            Dim procedureTypeDataTable As DataTable = DataAdapter.GetAllProcedureTypes()

            Dim filteredRows As DataRow() = procedureTypeDataTable.Select("ProductTypeId > 0")

            Dim filteredDataTable As DataTable = filteredRows.CopyToDataTable()
            If procedureTypeDataTable.Rows.Count > 0 Then
                Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{NurseModuleProcedureTypeRadComboBox, ""}}, filteredDataTable, "ProcedureType", "ProcedureTypeId")
                NurseModuleProcedureTypeRadComboBox.SelectedValue = "1"
            Else
                NurseModuleProcedureTypeRadComboBox.Items.Clear()
            End If
        Catch ex As Exception

        End Try
    End Sub
End Class