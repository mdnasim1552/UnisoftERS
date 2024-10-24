Imports Telerik.Web.UI

Public Class BiopsySites
    Inherits SiteDetailsBase

    Public ReadOnly Property siteId As Integer
        Get
            Return CInt(Request.QueryString("siteid"))
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadData()
        End If
    End Sub

    Protected Sub AddBiopsySiteRadButton_Click(sender As Object, e As EventArgs)
        Try
            Dim biopsySiteId = BiopsySiteRadComboBox.SelectedValue
            Dim distance = DistanceNumericTextBox.Value
            Dim bxQty = QtyRadNumericTextBox.Value

            'save to db
            DataAdapter.addSiteBiopsy(siteId, biopsySiteId, distance, bxQty)

            'reload repeater
            LoadData()

            'clear controls for new entry
            BiopsySiteRadComboBox.SelectedIndex = 0
            DistanceNumericTextBox.Text = ""
            QtyRadNumericTextBox.Text = ""
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error saving site biopsy", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "Error saving site biopsy")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub LoadData()
        Try
            BiospySiteDetailsRepeater.DataSource = DataAdapter.LoadSitesBiopsies(siteId)
            BiospySiteDetailsRepeater.DataBind()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading sites biopsies", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "Error loading sites biopsies")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub BiospySiteDetailsRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim combobox As RadComboBox = e.Item.FindControl("BiopsySiteRadComboBox")
            If combobox IsNot Nothing Then
                combobox.SelectedIndex = combobox.FindItemIndexByValue(CType(e.Item.DataItem, DataRowView).Row("BiopsySiteId"))
            End If

            Dim DistanceNumericTextBox As RadNumericTextBox = e.Item.FindControl("DistanceNumericTextBox")
            If DistanceNumericTextBox IsNot Nothing Then
                DistanceNumericTextBox.Value = CInt(CType(e.Item.DataItem, DataRowView).Row("Distance"))
            End If

            Dim QtyNumericTextBox As RadNumericTextBox = e.Item.FindControl("QtyRadNumericTextBox")
            If QtyNumericTextBox IsNot Nothing Then
                QtyNumericTextBox.Value = CInt(CType(e.Item.DataItem, DataRowView).Row("Qty"))
            End If
        End If
    End Sub

    Protected Sub BiospySiteDetailsRepeater_ItemCommand(source As Object, e As RepeaterCommandEventArgs)
        If Not String.IsNullOrWhiteSpace(e.CommandArgument) Then
            Dim siteSpecimenId = e.CommandArgument
            If e.CommandName.ToLower = "updatebiopsy" Then
                Dim biopsySiteId = CType(e.Item.FindControl("BiopsySiteRadComboBox"), RadComboBox).SelectedValue
                Dim distance = CType(e.Item.FindControl("DistanceNumericTextBox"), RadNumericTextBox).Value
                Dim qty = CType(e.Item.FindControl("QtyRadNumericTextBox"), RadNumericTextBox).Value

                DataAdapter.updateSiteBiopsy(siteSpecimenId, biopsySiteId, distance, qty)
            ElseIf e.CommandName.ToLower = "deletebiopsy" Then
                Dim procedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))
                DataAdapter.deleteSiteBiopsy(siteSpecimenId, procedureId)
                LoadData()
            End If
        End If

    End Sub
End Class