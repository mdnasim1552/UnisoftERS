Imports Telerik.Web.UI

Public Class CallInTimes
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        CallInTimesSQLDataSource.ConnectionString = DataAccess.ConnectionStr

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.UpdatePanelsRenderMode = UpdatePanelRenderMode.Inline
        myAjaxMgr.AjaxSettings.AddAjaxSetting(CallInTimesRadGrid, CallInTimesRadGrid, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(AddNewItemSaveRadButton, CallInTimesRadGrid)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(AddNewItemSaveRadButton, RadNotification1)

        If Not Page.IsPostBack Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{HospitalsComboBox, ""}}, DataAdapter.GetOperatingHospitals(), "HospitalName", "OperatingHospitalId")
        End If
    End Sub

    Protected Sub AddNewItemSaveRadButton_Click(sender As Object, e As EventArgs)
        Try

            If Not String.IsNullOrWhiteSpace(CType(sender, RadButton).CommandArgument) Then
                Dim callInTimeId = CInt(CType(sender, RadButton).CommandArgument)
                Dim callInMinutes = CallInMinsRadTextBox.Value

                CallInTimesSQLDataSource.UpdateParameters("CallInTimeId").DefaultValue = callInTimeId
                CallInTimesSQLDataSource.UpdateParameters("CallInMinutes").DefaultValue = callInMinutes
                CallInTimesSQLDataSource.Update()

                Utilities.SetNotificationStyle(RadNotification1, "Call-in time saved.")
                RadNotification1.Show()

                CallInTimesRadGrid.Rebind()
                ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "close-wind", "closeAddItemWindow();", True)
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured saving call-in times.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving call-in times.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CallInTimesRadGrid_ItemCreated(sender As Object, e As GridItemEventArgs)
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return editCallInTime('{0}');", e.Item.ItemIndex)
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error loading CallInTimesRadGrid_ItemCreated", ex)
        End Try
    End Sub
End Class