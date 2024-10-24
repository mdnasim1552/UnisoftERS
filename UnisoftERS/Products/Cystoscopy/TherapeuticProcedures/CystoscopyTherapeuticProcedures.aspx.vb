Imports Telerik.Web.UI

Public Class CystoscopyTherapeuticProcedures
    Inherits SiteDetailsBase
    Public siteId As Integer
    Dim da As New DataAccess
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        If Not IsPostBack Then
            CystoscopyTherapeuticFormView.DefaultMode = FormViewMode.Edit
            CystoscopyTherapeuticFormView.ChangeMode(FormViewMode.Edit)
        End If
    End Sub

    Protected Sub CystoscopyTherapeuticObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles CystoscopyTherapeuticObjectDataSource.Selecting
        e.InputParameters("siteId") = siteId
    End Sub
    Protected Sub CystoscopyTherapeuticObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopyTherapeuticObjectDataSource.Updating
        SetParams(e)
    End Sub
    Private Sub SetParams(e As ObjectDataSourceMethodEventArgs)
        Dim injectionTherapyNewTypeId As Integer = 0
        e.InputParameters("siteId") = siteId

        Dim InjectionTherapyComboBox = DirectCast(CystoscopyTherapeuticFormView.FindControl("InjectionTherapyCheckBox"), CheckBox)
        Dim InjectionTypeComboBox = DirectCast(CystoscopyTherapeuticFormView.FindControl("InjectionTypeComboBox"), RadComboBox)

        If InjectionTherapyComboBox.Checked Then
            injectionTherapyNewTypeId = Utilities.GetComboBoxValue(InjectionTypeComboBox)
        End If
        e.InputParameters("injectionTherapyNewTypeId") = injectionTherapyNewTypeId
        e.InputParameters("injectionTherapyTypeNewItemText") = InjectionTypeComboBox.SelectedItem.Text

        If InjectionTypeComboBox IsNot Nothing Then
            If InjectionTypeComboBox.SelectedValue = "" Then
                e.InputParameters("InjectionType") = Nothing
            Else
                e.InputParameters("InjectionType") = InjectionTypeComboBox.SelectedValue
            End If
        End If
    End Sub

    Protected Sub CystoscopyTherapeuticObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles CystoscopyTherapeuticObjectDataSource.Inserting
        SetParams(e)
    End Sub
    Protected Sub CystoscopyTherapeuticFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles CystoscopyTherapeuticFormView.ItemInserted
        CystoscopyTherapeuticFormView.DefaultMode = FormViewMode.Edit
        CystoscopyTherapeuticFormView.ChangeMode(FormViewMode.Edit)
        CystoscopyTherapeuticFormView.DataBind()
        ' ShowMsg()
    End Sub
    Protected Sub CystoscopyTherapeuticFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles CystoscopyTherapeuticFormView.ItemUpdated
        'ShowMsg()
    End Sub
    Protected Sub CystoscopyTherapeuticFormView_DataBound(sender As Object, e As EventArgs) Handles CystoscopyTherapeuticFormView.DataBound
        Dim row As DataRowView = DirectCast(CystoscopyTherapeuticFormView.DataItem, DataRowView)
        Dim InjectionTypeComboBox = DirectCast(CystoscopyTherapeuticFormView.FindControl("InjectionTypeComboBox"), RadComboBox)
        If InjectionTypeComboBox IsNot Nothing Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                            {InjectionTypeComboBox, "Agent Upper GI"}
                    })
        End If
        If row IsNot Nothing Then
            InjectionTypeComboBox.SelectedValue = CStr(row("InjectionType"))
        Else
            CystoscopyTherapeuticFormView.DefaultMode = FormViewMode.Insert
            CystoscopyTherapeuticFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub

    Protected Sub SaveButton_Click(Sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecords(True)
    End Sub

    Private Sub SaveRecords(saveAndClose As Boolean)
        If CystoscopyTherapeuticFormView.CurrentMode = FormViewMode.Edit Then
            CystoscopyTherapeuticFormView.UpdateItem(True)
        End If
        If CystoscopyTherapeuticFormView.CurrentMode = FormViewMode.Insert Then
            CystoscopyTherapeuticFormView.InsertItem(True)
        End If

        If saveAndClose Then
            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
        End If

    End Sub

End Class