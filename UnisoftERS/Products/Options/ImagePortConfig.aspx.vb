
Imports System.Drawing
Imports Telerik.Web.UI
Public Class ImagePortConfig
    Inherits OptionsBase

    Protected ReadOnly Property OperatingHospitalId() As Integer
        Get
            Return CInt(OperatingHospitalsRadComboBox.SelectedValue)
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ImagePortDataSource.ConnectionString = DataAccess.ConnectionStr
        If Not Page.IsPostBack Then
            OperatingHospitalsRadComboBox.DataSource = DataAdapter.GetOperatingHospitals()
            OperatingHospitalsRadComboBox.DataTextField = "HospitalName"
            OperatingHospitalsRadComboBox.DataValueField = "OperatingHospitalId"
            OperatingHospitalsRadComboBox.DataBind()

            'HospitalFilterDiv.Visible = OperatingHospitalsRadComboBox.Items.Count > 1

        End If
    End Sub

    Protected Sub IsActiveCheckBox_CheckedChanged(sender As Object, e As EventArgs)
        Try
            Dim PiD As Long
            Dim CBStatus As Boolean = DirectCast(sender, CheckBox).Checked
            Dim selectedRow = DirectCast(sender, System.Web.UI.Control).NamingContainer
            PiD = DirectCast(selectedRow, GridDataItem).GetDataKeyValue("ImagePortId")
            DataAdapter.UpdateIsActive(PiD, CBStatus)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving your changes.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving image port data.")
            RadNotification1.Show()
        End Try
    End Sub



    Protected Sub ImagePortRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)

        If e.CommandName.ToLower = "unlink" Then
            Try
                Dim PiD As Long
                Dim RoomId As String = ""

                RoomId = DirectCast(e.Item, GridDataItem).GetDataKeyValue("RoomId").ToString
                If Len(RoomId) <> 0 Then
                    PiD = CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("ImagePortId"))
                    DataAdapter.UnlinkImagePort(PiD)
                    ImagePortRadGrid.Rebind()
                End If
            Catch ex As Exception
                Dim errorLogRef As String
                errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving your changes.", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving image port data.")
                RadNotification1.Show()
            End Try
        End If

    End Sub

    Protected Sub ImagePortRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles ImagePortRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return EditImagePortWindow('{0}');", e.Item.ItemIndex)

            Dim item As GridDataItem = CType(e.Item, GridDataItem)
            Dim LinkUnlinkPCLinkButton As LinkButton = item.FindControl("LinkUnlinkPCLinkButton")
            If String.IsNullOrWhiteSpace(item.GetDataKeyValue("RoomId").ToString) Then
                LinkUnlinkPCLinkButton.Text = "Link Room"
                LinkUnlinkPCLinkButton.CommandName = ""

                LinkUnlinkPCLinkButton.Attributes("href") = "javascript:void(0);"
                LinkUnlinkPCLinkButton.Attributes("onclick") = String.Format("return LinkPc('{0}');", e.Item.ItemIndex)
            Else
                LinkUnlinkPCLinkButton.Text = "Unlink Room"
                LinkUnlinkPCLinkButton.CommandName = "UnLink"

                LinkUnlinkPCLinkButton.Attributes("onclick") = "javascript:if(!confirm('Are you sure you want to unlink this ImagePort?')){return false;}"
            End If
        End If
    End Sub

    Protected Sub LinkPCSaveRadButton_Click(sender As Object, e As EventArgs)
        'Deprecated function - PCNAME not being used anymore!
        Try
            Dim imagePortId = ImagePortIdHiddenField.Value
            Dim pcName = PopupLinkedPCNameTextBox.Text
            Dim isStatic = PopupStaticCheckbox.Checked

            If DataAdapter.UpdatePCSImagePort(pcName, imagePortId, isStatic) Then
                ScriptManager.RegisterStartupScript(Me.Page, Page.GetType, "close_window_script", "LinkPCWindowClientClose();", True)
                ImagePortRadGrid.Rebind()
            Else
                Utilities.SetNotificationStyle(FailedNotification, "Specified PC is already linked to an image port. Only 1 image port per PC", True)
                FailedNotification.Title = "Please correct the following..."
                FailedNotification.Height = "0"
                FailedNotification.Show()
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving your changes.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving image port data.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub ImagePortRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles ImagePortRadGrid.ItemDataBound
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return EditImagePort('{0}');", e.Item.ItemIndex)
            End If
        Catch ex As Exception
            Dim errorMsg = "Error in ImagePortRadGrid_ItemDataBound"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest

        If e.Argument = "Rebind" Then
            ImagePortRadGrid.MasterTableView.SortExpressions.Clear()
            ImagePortRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            ImagePortRadGrid.MasterTableView.SortExpressions.Clear()
            ImagePortRadGrid.MasterTableView.CurrentPageIndex = ImagePortRadGrid.MasterTableView.PageCount - 1
            ImagePortRadGrid.Rebind()
        End If

    End Sub

End Class