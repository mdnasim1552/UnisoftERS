Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Options_Scheduler_BookingStatusLinkHL7Code
    Inherits OptionsBase
    Public intDefaultSlothLengthMinutes As Integer = 0

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(myAjaxMgr, GridBookingBreachHL7Code, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(GridBookingBreachHL7Code, GridBookingBreachHL7Code, RadAjaxLoadingPanel1)

        If Not Page.IsPostBack Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{OperatingHospitalDropdown, ""}}, DataAdapter.GetTemplateOperatingHospitals, "HospitalName", "OperatingHospitalId")
            OperatingHospitalDropdown_SelectedIndexChanged(sender, e)
            GridBookingBreachHL7Code.Rebind()
        End If

    End Sub
    Private Sub SaveBookingData(blnCloseWindow As Boolean)
        Try
            Dim da_sch As DataAccess_Sch = New DataAccess_Sch


            Dim intOperatingHospitalID As Integer
            Dim eachHL7Code As String
            Dim eachHDCKey As String
            Dim intEachStatusId As Integer

            intOperatingHospitalID = OperatingHospitalDropdown.SelectedValue


            Dim txtHL7Code As TextBox
            Dim txtHDCKey As TextBox

            For Each dataitem As GridDataItem In GridBookingBreachHL7Code.Items
                eachHL7Code = ""
                eachHDCKey = ""

                txtHL7Code = DirectCast(dataitem.FindControl("txtHL7Code"), TextBox)
                txtHDCKey = DirectCast(dataitem.FindControl("txtHDCKey"), TextBox)

                If Not IsNothing(txtHL7Code) Then
                    eachHL7Code = txtHL7Code.Text
                End If

                If Not IsNothing(txtHDCKey) Then
                    eachHDCKey = txtHDCKey.Text
                End If

                intEachStatusId = dataitem.GetDataKeyValue("StatusId")

                da_sch.InsertOrUpdateBreachStatusLinkHL7Code(intOperatingHospitalID, intEachStatusId, eachHDCKey, eachHL7Code, CInt(HttpContext.Current.Session("PKUserID")))
            Next

            If blnCloseWindow Then
                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "applyandclose", "CloseWindow();", True)
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured while saving HL7Code Link in SaveBookingData.", ex)
        End Try
    End Sub
    Protected Sub SaveBookingBreachHL7Code()
        SaveBookingData(True)
    End Sub
    Protected Sub SaveOnlyBookingBreachHL7Code()
        SaveBookingData(False)
    End Sub
    Protected Sub btnSaveAndApply_Click(sender As Object, e As EventArgs)
        'SelectList(SlotQtyRadNumericTextBox.Value, ProcedureTypesComboBox.SelectedValue, PointsRadNumericTextBox.Value, SlotLengthRadNumericTextBox.Value, SlotComboBox.SelectedValue)



        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "applyandclose", "closeAddNewWindow();", True)
    End Sub

    Private Sub GridBookingBreachHL7Code_ItemCommand(sender As Object, e As GridCommandEventArgs)
        If e.CommandName = "Rebind" Then
            GridBookingBreachHL7Code.MasterTableView.SortExpressions.Clear()
            GridBookingBreachHL7Code.Rebind()
        ElseIf e.CommandName = "RebindAndNavigate" Then
            GridBookingBreachHL7Code.MasterTableView.SortExpressions.Clear()
            GridBookingBreachHL7Code.MasterTableView.CurrentPageIndex = GridBookingBreachHL7Code.MasterTableView.PageCount - 1
            GridBookingBreachHL7Code.Rebind()
        End If
    End Sub

    Private Sub GridBookingBreachHL7Code_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles GridBookingBreachHL7Code.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim TextColour As Label = DirectCast(e.Item.FindControl("ColourLabel"), Label)
            TextColour.BackColor = ColorTranslator.FromHtml((DataBinder.Eval(e.Item.DataItem, "ForeColor").ToString()))
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest1(sender As Object, e As AjaxRequestEventArgs)
        If e.Argument = "Rebind" Then
            GridBookingBreachHL7Code.MasterTableView.SortExpressions.Clear()
            GridBookingBreachHL7Code.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            GridBookingBreachHL7Code.MasterTableView.SortExpressions.Clear()
            GridBookingBreachHL7Code.MasterTableView.CurrentPageIndex = GridBookingBreachHL7Code.MasterTableView.PageCount - 1
            GridBookingBreachHL7Code.Rebind()
        End If
    End Sub



    Protected Sub OperatingHospitalDropdown_SelectedIndexChanged(sender As Object, e As EventArgs)
        Dim tblBreachStatusLinkHL7Code As DataTable = New DataTable
        Dim da As New DataAccess_Sch
        Dim intSelectedOperatingHospitalId As Integer

        If Not IsNothing(OperatingHospitalDropdown.SelectedValue) Then
            If IsNumeric(OperatingHospitalDropdown.SelectedValue.ToString()) Then
                intSelectedOperatingHospitalId = Convert.ToInt32(OperatingHospitalDropdown.SelectedValue)
            Else
                intSelectedOperatingHospitalId = 1
            End If
        Else
            intSelectedOperatingHospitalId = 1
        End If

        tblBreachStatusLinkHL7Code = da.GetBookingBreachStatusLinkHL7Code(intSelectedOperatingHospitalId)

        GridBookingBreachHL7Code.DataSource = Nothing
        GridBookingBreachHL7Code.DataSource = tblBreachStatusLinkHL7Code

        GridBookingBreachHL7Code.DataBind()
        GridBookingBreachHL7Code.Rebind()
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)

    End Sub
End Class