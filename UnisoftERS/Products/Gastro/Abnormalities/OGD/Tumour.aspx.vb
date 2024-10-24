Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_OGD_Tumour
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_OGD_Tumour_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not IsPostBack Then

            OgdTumourFormView.DefaultMode = FormViewMode.Edit
            OgdTumourFormView.ChangeMode(FormViewMode.Edit)
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        If OgdTumourFormView.CurrentMode = FormViewMode.Edit Then
            OgdTumourFormView.UpdateItem(True)
        ElseIf OgdTumourFormView.CurrentMode = FormViewMode.Insert Then
            OgdTumourFormView.InsertItem(True)
        End If
    End Sub

    Protected Sub OgdTumourObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles OgdTumourObjectDataSource.Selecting
        e.InputParameters("siteId") = siteId
    End Sub

    Protected Sub OgdMiscellaneousObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles OgdTumourObjectDataSource.Updating
        'If Not String.IsNullOrWhiteSpace(DirectCast(OgdTumourFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList).SelectedValue) Then
        '    e.InputParameters("ExtrinsicCompression") = DirectCast(OgdTumourFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList).SelectedValue = 2
        'End If

        SetParams(e)
    End Sub

    Protected Sub OgdMiscellaneousObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles OgdTumourObjectDataSource.Inserting
        'If Not String.IsNullOrWhiteSpace(DirectCast(OgdTumourFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList).SelectedValue) Then
        '    e.InputParameters("ExtrinsicCompression") = DirectCast(OgdTumourFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList).SelectedValue = 2
        'End If
        SetParams(e)
    End Sub

    Private Sub SetParams(e As ObjectDataSourceMethodEventArgs)
        e.InputParameters("siteId") = siteId

        'Dim StrictureSeverityRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StrictureSeverityRadioButtonList"), RadioButtonList)
        'Dim StrictureCompressionRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList)
        'Dim StrictureTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StrictureTypeRadioButtonList"), RadioButtonList)
        'Dim StrictureBenignTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StrictureBenignTypeRadioButtonList"), RadioButtonList)
        'Dim StricturePerforationRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StricturePerforationRadioButtonList"), RadioButtonList)
        Dim TumourTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("TumourTypeRadioButtonList"), RadioButtonList)
        Dim TumourExophyticRadioButtonList = DirectCast(OgdTumourFormView.FindControl("TumourExophyticRadioButtonList"), RadioButtonList)
        Dim TumourBenignTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("TumourBenignTypeRadioButtonList"), RadioButtonList)
        Dim TumourMalignantTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("TumourMalignantTypeRadioButtonList"), RadioButtonList)
        Dim TumourMalignantTypeOtherTextBox = DirectCast(OgdTumourFormView.FindControl("TumourMalignantTypeOtherTextBox"), RadTextBox)
        Dim TumourBenignTypeOtherTextBox = DirectCast(OgdTumourFormView.FindControl("TumourBenignTypeOtherTextBox"), RadTextBox)

        'If StrictureSeverityRadioButtonList IsNot Nothing Then
        '    If StrictureSeverityRadioButtonList.SelectedValue = "" Then
        '        e.InputParameters("StrictureSeverity") = Nothing
        '    Else
        '        e.InputParameters("StrictureSeverity") = StrictureSeverityRadioButtonList.SelectedValue
        '    End If
        'End If
        'If StrictureCompressionRadioButtonList IsNot Nothing Then
        '    If StrictureCompressionRadioButtonList.SelectedValue = "" Then
        '        e.InputParameters("StrictureCompression") = Nothing
        '    Else
        '        e.InputParameters("StrictureCompression") = StrictureCompressionRadioButtonList.SelectedValue
        '    End If
        'End If
        'If StrictureTypeRadioButtonList IsNot Nothing Then
        '    If StrictureTypeRadioButtonList.SelectedValue = "" Then
        '        e.InputParameters("StrictureType") = Nothing
        '    Else
        '        e.InputParameters("StrictureType") = StrictureTypeRadioButtonList.SelectedValue
        '    End If
        'End If

        'If StrictureBenignTypeRadioButtonList IsNot Nothing Then
        '    If StrictureBenignTypeRadioButtonList.SelectedValue = "" Then
        '        e.InputParameters("StrictureBenignType") = Nothing
        '    Else
        '        e.InputParameters("StrictureBenignType") = StrictureBenignTypeRadioButtonList.SelectedValue
        '    End If
        'End If

        'If StricturePerforationRadioButtonList IsNot Nothing Then
        '    If StricturePerforationRadioButtonList.SelectedValue = "" Then
        '        e.InputParameters("StricturePerforation") = Nothing
        '    Else
        '        e.InputParameters("StricturePerforation") = StricturePerforationRadioButtonList.SelectedValue
        '    End If
        'End If

        If TumourTypeRadioButtonList IsNot Nothing Then
            If TumourTypeRadioButtonList.SelectedValue = "" Then
                e.InputParameters("TumourType") = Nothing
            Else
                e.InputParameters("TumourType") = TumourTypeRadioButtonList.SelectedValue

                If TumourTypeRadioButtonList.SelectedValue = 1 Then
                    If TumourBenignTypeRadioButtonList IsNot Nothing Then
                        If TumourBenignTypeRadioButtonList.SelectedValue = "" Then
                            e.InputParameters("TumourBenignType") = 0
                        Else
                            e.InputParameters("TumourBenignType") = TumourBenignTypeRadioButtonList.SelectedValue
                        End If
                    End If
                ElseIf TumourTypeRadioButtonList.SelectedValue = 2 Then
                    If TumourMalignantTypeRadioButtonList IsNot Nothing Then
                        If TumourMalignantTypeRadioButtonList.SelectedValue = "" Then
                            e.InputParameters("TumourBenignType") = 0
                        Else
                            e.InputParameters("TumourBenignType") = TumourMalignantTypeRadioButtonList.SelectedValue
                        End If
                    End If
                End If
                e.InputParameters("TumourBenignTypeOther") = IIf(TumourBenignTypeOtherTextBox.Text = "", TumourMalignantTypeOtherTextBox.Text, TumourBenignTypeOtherTextBox.Text)

            End If
        End If
        If TumourExophyticRadioButtonList IsNot Nothing Then
            If TumourExophyticRadioButtonList.SelectedValue = "" Then
                e.InputParameters("TumourExophytic") = Nothing
            Else
                e.InputParameters("TumourExophytic") = TumourExophyticRadioButtonList.SelectedValue
            End If
        End If
    End Sub

    Protected Sub OgdTumourFormView_DataBound(sender As Object, e As EventArgs) Handles OgdTumourFormView.DataBound
        Dim row As DataRowView = DirectCast(OgdTumourFormView.DataItem, DataRowView)

        If row IsNot Nothing Then
            'Dim StrictureSeverityRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StrictureSeverityRadioButtonList"), RadioButtonList)
            'Dim StrictureCompressionRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList)
            'Dim StrictureTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StrictureTypeRadioButtonList"), RadioButtonList)
            'Dim StrictureBenignTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StrictureBenignTypeRadioButtonList"), RadioButtonList)
            'Dim StricturePerforationRadioButtonList = DirectCast(OgdTumourFormView.FindControl("StricturePerforationRadioButtonList"), RadioButtonList)
            Dim TumourTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("TumourTypeRadioButtonList"), RadioButtonList)
            Dim TumourExophyticRadioButtonList = DirectCast(OgdTumourFormView.FindControl("TumourExophyticRadioButtonList"), RadioButtonList)
            Dim TumourBenignTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("TumourBenignTypeRadioButtonList"), RadioButtonList)
            Dim TumourMalignantTypeRadioButtonList = DirectCast(OgdTumourFormView.FindControl("TumourMalignantTypeRadioButtonList"), RadioButtonList)
            'Dim MiscOtherCheckBox = DirectCast(OgdTumourFormView.FindControl("MiscOtherCheckBox"), CheckBox)

            'If Not IsDBNull(row("StrictureSeverity")) AndAlso StrictureSeverityRadioButtonList IsNot Nothing Then
            '    StrictureSeverityRadioButtonList.SelectedValue = CStr(row("StrictureSeverity"))
            'End If
            'If Not IsDBNull(row("StrictureCompression")) AndAlso StrictureCompressionRadioButtonList IsNot Nothing Then
            '    StrictureCompressionRadioButtonList.SelectedValue = CStr(row("StrictureCompression"))
            'End If

            'If Not IsDBNull(row("StrictureType")) AndAlso StrictureTypeRadioButtonList IsNot Nothing Then
            '    StrictureTypeRadioButtonList.SelectedValue = CStr(row("StrictureType"))
            'End If

            'If Not IsDBNull(row("StricturePerforation")) AndAlso StricturePerforationRadioButtonList IsNot Nothing Then
            '    StricturePerforationRadioButtonList.SelectedValue = CStr(row("StricturePerforation"))
            'End If

            'If Not IsDBNull(row("StrictureBenignType")) AndAlso StrictureBenignTypeRadioButtonList IsNot Nothing Then
            '    StrictureBenignTypeRadioButtonList.SelectedValue = CStr(row("StrictureBenignType"))
            'End If

            If Not IsDBNull(row("Type")) AndAlso TumourTypeRadioButtonList IsNot Nothing Then
                TumourTypeRadioButtonList.SelectedValue = CStr(row("Type"))
                If IIf(TumourTypeRadioButtonList.SelectedValue = "", 0, TumourTypeRadioButtonList.SelectedValue) = 1 Then
                    If Not IsDBNull(row("TumourBenignType")) AndAlso TumourBenignTypeRadioButtonList IsNot Nothing Then
                        TumourBenignTypeRadioButtonList.SelectedValue = CStr(row("TumourBenignType"))
                    End If
                Else
                    If Not IsDBNull(row("TumourBenignType")) AndAlso TumourMalignantTypeRadioButtonList IsNot Nothing Then
                        TumourMalignantTypeRadioButtonList.SelectedValue = CStr(row("TumourBenignType"))
                    End If
                End If
            End If

            If Not IsDBNull(row("TumourExophytic")) AndAlso TumourExophyticRadioButtonList IsNot Nothing Then
                TumourExophyticRadioButtonList.SelectedValue = CStr(row("TumourExophytic"))
            End If
            'If Not IsDBNull(row("MiscOther")) AndAlso MiscOtherCheckBox IsNot Nothing Then
            '    If Trim(row("MiscOther")) <> "" Then MiscOtherCheckBox.Checked = True
            'End If
        Else
            OgdTumourFormView.DefaultMode = FormViewMode.Insert
            OgdTumourFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub



    Protected Sub OgdTumourFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles OgdTumourFormView.ItemInserted
        OgdTumourFormView.DefaultMode = FormViewMode.Edit
        OgdTumourFormView.ChangeMode(FormViewMode.Edit)
        OgdTumourFormView.DataBind()
        ShowMsg()
    End Sub

    Private Sub ShowMsg()
        'Utilities.SetNotificationStyle(RadNotification1)
        'RadNotification1.Show()
        ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
    End Sub

    Protected Sub OgdTumourFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles OgdTumourFormView.ItemUpdated
        ShowMsg()
    End Sub
End Class
