Imports Microsoft.Ajax.Utilities
Imports Telerik.Web.UI

Public Class DamagingDrugs
    Inherits ProcedureControls

    Private Shared procType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            AntiCoagDrugsRadComboBox.DataSource = DataAdapter.LoadAntiCoagDrugs()
            AntiCoagDrugsRadComboBox.DataBind()
            If (Session("IsAdmin")) Then
                AntiCoagDrugsRadComboBox.Items.Add(New RadComboBoxItem() With {
                    .Text = "Add new",
                    .Value = -55,
                    .ImageUrl = "~/images/icons/add.png",
                    .CssClass = "comboNewItem"
                })
            End If

            'AntiCoagDrugsRadComboBox.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & AntiCoagDrugsRadComboBox.ClientID & ",true); } else { window.parent.AddNewItemPopUp(" & AntiCoagDrugsRadComboBox.ClientID & ",true);" & " }")
            AntiCoagDrugsRadComboBox.Sort = RadComboBoxSort.Ascending

            DamagingDrugsComboBox.DataSource = DataAdapter.LoadDamagingDrugs()
            DamagingDrugsComboBox.DataBind()
            DamagingDrugsComboBox.DataTextField = "Description"
            DamagingDrugsComboBox.DataValueField = "UniqueId"
            loadProcedureDamagingDrugs()
        End If

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
    End Sub


    Private Sub loadProcedureDamagingDrugs()
        Try
            Dim antiCoagDrugs = DataAdapter.GetProcedureAntiCoagDrugs(Session(Constants.SESSION_PROCEDURE_ID))
            'Dim GetAnticoagStatus = DataAdapter.GetAntiCoagStatus(Session(Constants.SESSION_PROCEDURE_ID)) 'edited by mostafiz 4090
            'AntiCoagRadioButtonList.SelectedValue = GetAnticoagStatus.ToString
            'Added by rony tfs-4171
            If antiCoagDrugs IsNot Nothing AndAlso antiCoagDrugs.Rows.Count > 0 AndAlso Not antiCoagDrugs(0).IsNull("AntiCoagDrugs") Then
                AntiCoagRadioButtonList.SelectedValue = If(antiCoagDrugs(0)("AntiCoagDrugs"), 1, 0)
            End If

            If antiCoagDrugs.Rows.Count > 0 Then
                For i As Integer = 0 To antiCoagDrugs.Rows.Count - 1
                    Dim drugId = antiCoagDrugs(i)("DamagingDrugId")
                    Dim otherText = antiCoagDrugs(i)("AdditionalInfo")
                    If Not IsDBNull(drugId) Then
                        AntiCoagDrugsRadComboBox.FindItemByValue(drugId).Checked = True
                    End If
                    If Not IsDBNull(otherText) Then
                        OtherTextBox.Text = otherText
                    End If
                Next
            End If


            Dim damagingDrugs = DataAdapter.GetProcedureDamagingDrugs(Session(Constants.SESSION_PROCEDURE_ID))
            'Added by rony tfs-4171
            If damagingDrugs IsNot Nothing AndAlso damagingDrugs.Rows.Count > 0 AndAlso Not damagingDrugs(0).IsNull("PotentialSignificantDrugs") Then
                PotentialSignificantDrugRadioButtonList.SelectedValue = If(damagingDrugs(0)("PotentialSignificantDrugs"), 1, 0)
            End If

            If damagingDrugs.Rows.Count > 0 Then
                For i As Integer = 0 To damagingDrugs.Rows.Count - 1
                    Dim drugId = damagingDrugs(i)("DamagingDrugId")
                    If Not IsDBNull(drugId) Then
                        DamagingDrugsComboBox.FindItemByValue(drugId).Checked = True
                    End If
                Next
            End If

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading procedures damaging drugs", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading the data")
            RadNotification1.Show()
        End Try
    End Sub
End Class