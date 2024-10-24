Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Common_DuodenalUlcer
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        Dim reg As String = Request.QueryString("Reg")

        If reg = "Jejunum" Then
            HeaderDiv.InnerText = "Jejunal Ulcer"
        ElseIf reg = "Ileum" Then
            HeaderDiv.InnerText = "Ileal Ulcer"
        ElseIf reg.Contains("Pylorus") Then
            HeaderDiv.InnerText = "Pyloric Ulcer"
        Else
            HeaderDiv.InnerText = "Duodenal Ulcer"
        End If

        If Not IsPostBack Then
            DuodenalUlcerFormView.DefaultMode = FormViewMode.Edit
            DuodenalUlcerFormView.ChangeMode(FormViewMode.Edit)
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        If DuodenalUlcerFormView.CurrentMode = FormViewMode.Edit Then
            DuodenalUlcerObjectDataSource.UpdateParameters("RegionalIdentifier").DefaultValue = HeaderDiv.InnerText
            DuodenalUlcerFormView.UpdateItem(True)
        ElseIf DuodenalUlcerFormView.CurrentMode = FormViewMode.Insert Then
            DuodenalUlcerObjectDataSource.InsertParameters("RegionalIdentifier").DefaultValue = HeaderDiv.InnerText
            DuodenalUlcerFormView.InsertItem(True)
        End If
    End Sub

    Protected Sub DuodenalUlcerObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DuodenalUlcerObjectDataSource.Selecting
        e.InputParameters("siteId") = siteId
    End Sub

    Protected Sub DuodenalUlcerObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles DuodenalUlcerObjectDataSource.Updating
        SetParams(e)
    End Sub

    Protected Sub DuodenalUlcerObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles DuodenalUlcerObjectDataSource.Inserting
        SetParams(e)
    End Sub

    Private Sub SetParams(e As ObjectDataSourceMethodEventArgs)
        e.InputParameters("siteId") = siteId

        Dim UlcerTypeRadioButtonList = DirectCast(DuodenalUlcerFormView.FindControl("UlcerTypeRadioButtonList"), RadioButtonList)
        If UlcerTypeRadioButtonList IsNot Nothing Then
            If UlcerTypeRadioButtonList.SelectedValue = "" Then
                e.InputParameters("UlcerType") = Nothing
            Else
                e.InputParameters("UlcerType") = UlcerTypeRadioButtonList.SelectedValue
            End If
        End If

        Dim VisibleVesselRadioButtonList = DirectCast(DuodenalUlcerFormView.FindControl("VisibleVesselRadioButtonList"), RadioButtonList)
        If VisibleVesselRadioButtonList IsNot Nothing Then
            If VisibleVesselRadioButtonList.SelectedValue = "" Then
                e.InputParameters("VisibleVesselType") = Nothing
            Else
                e.InputParameters("VisibleVesselType") = VisibleVesselRadioButtonList.SelectedValue
            End If
        End If

        Dim ActiveBleedingRadioButtonList = DirectCast(DuodenalUlcerFormView.FindControl("ActiveBleedingRadioButtonList"), RadioButtonList)
        If ActiveBleedingRadioButtonList IsNot Nothing Then
            If ActiveBleedingRadioButtonList.SelectedValue = "" Then
                e.InputParameters("ActiveBleedingType") = Nothing
            Else
                e.InputParameters("ActiveBleedingType") = ActiveBleedingRadioButtonList.SelectedValue
            End If
        End If
    End Sub

    Protected Sub DuodenalUlcerFormView_DataBound(sender As Object, e As EventArgs) Handles DuodenalUlcerFormView.DataBound
        Dim row As DataRowView = DirectCast(DuodenalUlcerFormView.DataItem, DataRowView)
        If row IsNot Nothing Then
            Dim UlcerTypeRadioButtonList = DirectCast(DuodenalUlcerFormView.FindControl("UlcerTypeRadioButtonList"), RadioButtonList)
            Dim VisibleVesselRadioButtonList = DirectCast(DuodenalUlcerFormView.FindControl("VisibleVesselRadioButtonList"), RadioButtonList)
            Dim ActiveBleedingRadioButtonList = DirectCast(DuodenalUlcerFormView.FindControl("ActiveBleedingRadioButtonList"), RadioButtonList)
            If Not IsDBNull(row("UlcerType")) AndAlso UlcerTypeRadioButtonList IsNot Nothing Then
                UlcerTypeRadioButtonList.SelectedValue = CStr(row("UlcerType"))
            End If
            If Not IsDBNull(row("VisibleVesselType")) AndAlso VisibleVesselRadioButtonList IsNot Nothing Then
                VisibleVesselRadioButtonList.SelectedValue = CStr(row("VisibleVesselType"))
            End If
            If Not IsDBNull(row("ActiveBleedingType")) AndAlso ActiveBleedingRadioButtonList IsNot Nothing Then
                ActiveBleedingRadioButtonList.SelectedValue = CStr(row("ActiveBleedingType"))
            End If
        Else
            DuodenalUlcerFormView.DefaultMode = FormViewMode.Insert
            DuodenalUlcerFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub

    Protected Sub DuodenalUlcerFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles DuodenalUlcerFormView.ItemInserted
        DuodenalUlcerFormView.DefaultMode = FormViewMode.Edit
        DuodenalUlcerFormView.ChangeMode(FormViewMode.Edit)
        DuodenalUlcerFormView.DataBind()
        ShowMsg()
    End Sub

    Protected Sub DuodenalUlcerFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles DuodenalUlcerFormView.ItemUpdated
        ShowMsg()
    End Sub

    Private Sub ShowMsg()
        'Utilities.SetNotificationStyle(RadNotification1)
        'RadNotification1.Show()
        ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
    End Sub


End Class
