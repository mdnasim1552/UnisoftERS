Imports System.Drawing
Imports Telerik.Web.UI

Partial Class products_options_scheduler_BookingBreachStatus
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(myAjaxMgr, BookingBreachRadGrid, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(BookingBreachRadGrid, BookingBreachRadGrid, RadAjaxLoadingPanel1)


        If Not Page.IsPostBack Then
            RadNotification1.Title = "HD Clinical Support Helpdesk: " & ConfigurationManager.AppSettings("Unisoft.Helpdesk")
            Try
                If Me.Master IsNot Nothing Then
                    Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                    Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                    If leftPane IsNot Nothing Then leftPane.Visible = False
                    If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
                End If
            Catch ex As Exception
                LogManager.LogManagerInstance.LogError("Error in pageload", ex)
            End Try
        End If
    End Sub

    Private Sub BookingBreachRadGrid_ItemCreated(sender As Object, e As GridItemEventArgs) Handles BookingBreachRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim sItemName As String = ""
            Dim sItemID As String = ""
            Dim sBreachDays As String = ""
            Dim sForeColor As String = ""
            Dim sBackColor As String = ""
            Dim sHL7Code As String = ""

            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            If (DataBinder.Eval(e.Item.DataItem, "StatusId") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "StatusId").ToString())) Then
                sItemID = e.Item.DataItem("StatusId").ToString()
            Else
                sItemID = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "Description") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "Description").ToString())) Then
                sItemName = e.Item.DataItem("Description").ToString()
            Else
                sItemName = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "BreachDays") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "BreachDays").ToString())) Then
                sBreachDays = e.Item.DataItem("BreachDays").ToString()
            Else
                sBreachDays = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "ForeColor") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "ForeColor").ToString())) Then
                sForeColor = e.Item.DataItem("ForeColor").ToString()
            Else
                sForeColor = ""
            End If

            If (DataBinder.Eval(e.Item.DataItem, "HL7Code") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "HL7Code").ToString())) Then
                sHL7Code = e.Item.DataItem("HL7Code").ToString()
            Else
                sHL7Code = ""
            End If


            Dim editString As String = String.Format("openAddItemWindow('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("StatusId"), sItemName, sItemID, True, False, sBreachDays, sForeColor, sHL7Code)
            EditLinkButton.Attributes("onclick") = editString
        End If
    End Sub

    Private Sub BookingBreachRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        If e.CommandName = "Rebind" Then
            BookingBreachRadGrid.MasterTableView.SortExpressions.Clear()
            BookingBreachRadGrid.Rebind()
        ElseIf e.CommandName = "RebindAndNavigate" Then
            BookingBreachRadGrid.MasterTableView.SortExpressions.Clear()
            BookingBreachRadGrid.MasterTableView.CurrentPageIndex = BookingBreachRadGrid.MasterTableView.PageCount - 1
            BookingBreachRadGrid.Rebind()
        End If
    End Sub

    Private Sub BookingBreachRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles BookingBreachRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim TextColour As Label = DirectCast(e.Item.FindControl("ColourLabel"), Label)
            TextColour.BackColor = ColorTranslator.FromHtml((DataBinder.Eval(e.Item.DataItem, "ForeColor").ToString()))
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest1(sender As Object, e As AjaxRequestEventArgs)
        If e.Argument = "Rebind" Then
            BookingBreachRadGrid.MasterTableView.SortExpressions.Clear()
            BookingBreachRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            BookingBreachRadGrid.MasterTableView.SortExpressions.Clear()
            BookingBreachRadGrid.MasterTableView.CurrentPageIndex = BookingBreachRadGrid.MasterTableView.PageCount - 1
            BookingBreachRadGrid.Rebind()
        End If
    End Sub

    Private Sub AddNewItemSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewItemSaveRadButton.Click
        Dim da As New DataAccess_Sch
        Dim Color As String
        Try
            Color = "#" + BreachRadColourPicker.SelectedColor.Name.Substring(2, 6)
            If AddNewItemSaveRadButton.Text = "Update" Then
                da.InsertUpdateBreachStatus(DescriptionRadTextBox.Text, True, False, BreachDaysRadNumericTextBox.Value, Color, txtHL7Code.Text, Session("PKUserID").ToString, hiddenItemId.Value)
            ElseIf AddNewItemSaveRadButton.Text <> "" Then
                da.InsertUpdateBreachStatus(DescriptionRadTextBox.Text, True, False, BreachDaysRadNumericTextBox.Value, Color, txtHL7Code.Text, Session("PKUserID").ToString)
            End If
            BookingBreachRadGrid.Rebind()
            Page.ClientScript.RegisterStartupScript(Me.GetType(), "close", "closeAddItemWindow();", True)
        Catch ex As Exception
            Dim errorLogRef As String = LogManager.LogManagerInstance.LogError("", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "Error in inserting data on breach days")
            RadNotification1.Show()
        End Try
    End Sub
End Class