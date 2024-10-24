Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_OGD_Miscellaneous
    Inherits SiteDetailsBase

    Private siteId As Integer
    Private Shared ProcTypeId As Integer

    Protected Sub Products_Gastro_Abnormalities_OGD_Miscellaneous_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        ProcTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        If Not IsPostBack Then
            HideShowControls()
        End If
    End Sub

    Protected Sub HideShowControls()

    End Sub
    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        If OgdMiscellaneousFormView.CurrentMode = FormViewMode.Edit Then
            OgdMiscellaneousFormView.UpdateItem(True)
        ElseIf OgdMiscellaneousFormView.CurrentMode = FormViewMode.Insert Then
            OgdMiscellaneousFormView.InsertItem(True)
        End If
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click

    End Sub

    Protected Sub OgdMiscellaneousObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles OgdMiscellaneousObjectDataSource.Selecting
        e.InputParameters("siteId") = siteId
    End Sub

    Protected Sub OgdMiscellaneousObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles OgdMiscellaneousObjectDataSource.Updating
        If OgdMiscellaneousFormView.FindControl("StrictureCompressionRadioButtonList") IsNot Nothing AndAlso Not String.IsNullOrWhiteSpace(DirectCast(OgdMiscellaneousFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList).SelectedValue) Then
            e.InputParameters("ExtrinsicCompression") = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList).SelectedValue = 2
        End If

        SetParams(e)
    End Sub

    Protected Sub OgdMiscellaneousObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles OgdMiscellaneousObjectDataSource.Inserting
        If OgdMiscellaneousFormView.FindControl("StrictureCompressionRadioButtonList") IsNot Nothing AndAlso Not String.IsNullOrWhiteSpace(DirectCast(OgdMiscellaneousFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList).SelectedValue) Then
            e.InputParameters("ExtrinsicCompression") = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList).SelectedValue = 2
        End If
        SetParams(e)
    End Sub

    Private Sub SetParams(e As ObjectDataSourceMethodEventArgs)
        e.InputParameters("siteId") = siteId

        Dim StrictureSeverityRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureSeverityRadioButtonList"), RadioButtonList)
        Dim StrictureCompressionRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList)
        Dim StrictureTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureTypeRadioButtonList"), RadioButtonList)
        Dim StrictureBenignTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureBenignTypeRadioButtonList"), RadioButtonList)
        Dim StricturePerforationRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StricturePerforationRadioButtonList"), RadioButtonList)
        Dim TumourTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("TumourTypeRadioButtonList"), RadioButtonList)
        Dim TumourExophyticRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("TumourExophyticRadioButtonList"), RadioButtonList)
        Dim TumourBenignTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("TumourBenignTypeRadioButtonList"), RadioButtonList)
        Dim TumourMalignantTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("TumourMalignantTypeRadioButtonList"), RadioButtonList)
        Dim TumourMalignantTypeOtherTextBox = DirectCast(OgdMiscellaneousFormView.FindControl("TumourMalignantTypeOtherTextBox"), RadTextBox)
        Dim TumourBenignTypeOtherTextBox = DirectCast(OgdMiscellaneousFormView.FindControl("TumourBenignTypeOtherTextBox"), RadTextBox)

        If StrictureSeverityRadioButtonList IsNot Nothing Then
            If StrictureSeverityRadioButtonList.SelectedValue = "" Then
                e.InputParameters("StrictureSeverity") = Nothing
            Else
                e.InputParameters("StrictureSeverity") = StrictureSeverityRadioButtonList.SelectedValue
            End If
        End If
        If StrictureCompressionRadioButtonList IsNot Nothing Then
            If StrictureCompressionRadioButtonList.SelectedValue = "" Then
                e.InputParameters("StrictureCompression") = Nothing
            Else
                e.InputParameters("StrictureCompression") = StrictureCompressionRadioButtonList.SelectedValue
            End If
        End If
        If StrictureTypeRadioButtonList IsNot Nothing Then
            If StrictureTypeRadioButtonList.SelectedValue = "" Then
                e.InputParameters("StrictureType") = Nothing
            Else
                e.InputParameters("StrictureType") = StrictureTypeRadioButtonList.SelectedValue
            End If
        End If

        If StrictureBenignTypeRadioButtonList IsNot Nothing Then
            If StrictureBenignTypeRadioButtonList.SelectedValue = "" Then
                e.InputParameters("StrictureBenignType") = Nothing
            Else
                e.InputParameters("StrictureBenignType") = StrictureBenignTypeRadioButtonList.SelectedValue
            End If
        End If

        If StricturePerforationRadioButtonList IsNot Nothing Then
            If StricturePerforationRadioButtonList.SelectedValue = "" Then
                e.InputParameters("StricturePerforation") = Nothing
            Else
                e.InputParameters("StricturePerforation") = StricturePerforationRadioButtonList.SelectedValue
            End If
        End If

        If TumourTypeRadioButtonList IsNot Nothing Then
            If TumourTypeRadioButtonList.SelectedValue = "" Then
                e.InputParameters("TumourType") = Nothing
            Else
                e.InputParameters("TumourType") = TumourTypeRadioButtonList.SelectedValue

                If TumourTypeRadioButtonList.SelectedValue = 1 Then
                    If TumourBenignTypeRadioButtonList IsNot Nothing Then
                        If TumourBenignTypeRadioButtonList.SelectedValue = "" Then
                            e.InputParameters("TumourBenignType") = Nothing
                        Else
                            e.InputParameters("TumourBenignType") = TumourBenignTypeRadioButtonList.SelectedValue
                        End If
                    End If
                Else
                    If TumourMalignantTypeRadioButtonList IsNot Nothing Then
                        If TumourMalignantTypeRadioButtonList.SelectedValue = "" Then
                            e.InputParameters("TumourBenignType") = Nothing
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

    Protected Sub OgdMiscellaneousFormView_DataBound(sender As Object, e As EventArgs) Handles OgdMiscellaneousFormView.DataBound
        Dim row As DataRowView = DirectCast(OgdMiscellaneousFormView.DataItem, DataRowView)

        If row IsNot Nothing Then
            Dim StrictureSeverityRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureSeverityRadioButtonList"), RadioButtonList)
            Dim StrictureCompressionRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureCompressionRadioButtonList"), RadioButtonList)
            Dim StrictureTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureTypeRadioButtonList"), RadioButtonList)
            Dim StrictureBenignTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StrictureBenignTypeRadioButtonList"), RadioButtonList)
            Dim StricturePerforationRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("StricturePerforationRadioButtonList"), RadioButtonList)
            Dim TumourTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("TumourTypeRadioButtonList"), RadioButtonList)
            Dim TumourExophyticRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("TumourExophyticRadioButtonList"), RadioButtonList)
            Dim TumourBenignTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("TumourBenignTypeRadioButtonList"), RadioButtonList)
            Dim TumourMalignantTypeRadioButtonList = DirectCast(OgdMiscellaneousFormView.FindControl("TumourMalignantTypeRadioButtonList"), RadioButtonList)
            Dim MiscOtherCheckBox = DirectCast(OgdMiscellaneousFormView.FindControl("MiscOtherCheckBox"), CheckBox)

            If Not IsDBNull(row("StrictureSeverity")) AndAlso StrictureSeverityRadioButtonList IsNot Nothing Then
                StrictureSeverityRadioButtonList.SelectedValue = CStr(row("StrictureSeverity"))
            End If
            If Not IsDBNull(row("StrictureCompression")) AndAlso StrictureCompressionRadioButtonList IsNot Nothing Then
                StrictureCompressionRadioButtonList.SelectedValue = CStr(row("StrictureCompression"))
            End If

            If Not IsDBNull(row("StrictureType")) AndAlso StrictureTypeRadioButtonList IsNot Nothing Then
                StrictureTypeRadioButtonList.SelectedValue = CStr(row("StrictureType"))
            End If

            If Not IsDBNull(row("StricturePerforation")) AndAlso StricturePerforationRadioButtonList IsNot Nothing Then
                StricturePerforationRadioButtonList.SelectedValue = CStr(row("StricturePerforation"))
            End If

            If Not IsDBNull(row("StrictureBenignType")) AndAlso StrictureBenignTypeRadioButtonList IsNot Nothing Then
                StrictureBenignTypeRadioButtonList.SelectedValue = CStr(row("StrictureBenignType"))
            End If

            If Not IsDBNull(row("TumourType")) AndAlso TumourTypeRadioButtonList IsNot Nothing Then
                TumourTypeRadioButtonList.SelectedValue = CStr(row("TumourType"))
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
            If Not IsDBNull(row("MiscOther")) AndAlso MiscOtherCheckBox IsNot Nothing Then
                If Trim(row("MiscOther")) <> "" Then MiscOtherCheckBox.Checked = True
            End If
        Else
            OgdMiscellaneousFormView.DefaultMode = FormViewMode.Insert
            OgdMiscellaneousFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub



    Protected Sub OgdMiscellaneousFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles OgdMiscellaneousFormView.ItemInserted
        OgdMiscellaneousFormView.DefaultMode = FormViewMode.Edit
        OgdMiscellaneousFormView.ChangeMode(FormViewMode.Edit)
        OgdMiscellaneousFormView.DataBind()
        ShowMsg()
    End Sub

    Private Sub ShowMsg()
        'Utilities.SetNotificationStyle(RadNotification1)
        'RadNotification1.Show()
        'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True) ' //for this page issue 4166  by Mostafiz
    End Sub

    Protected Sub OgdMiscellaneousFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles OgdMiscellaneousFormView.ItemUpdated
        ShowMsg()
    End Sub

    Protected Sub OgdMiscellaneousFormView_PreRender(sender As Object, e As EventArgs)

        'OgdMiscellaneousFormView.DefaultMode = FormViewMode.Edit
        'OgdMiscellaneousFormView.ChangeMode(FormViewMode.Edit)

        Dim dt = DataAdapter.GetSiteRegionDetails(ProcTypeId, siteId)
        Dim area = dt.Rows(0)("Area").ToString
        If area.ToLower = "stomach" Then
            CType(OgdMiscellaneousFormView.FindControl("WebTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("MalloryTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("SchatzkiRingTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("FoodResidueTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("InletPatchTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("MotilityDisorderTR"), HtmlTableRow).Visible = False
            ' CType(OgdMiscellaneousFormView.FindControl("UlcerationTR"), HtmlTableRow).Visible = False  'commentted by ferdowsi 
            CType(OgdMiscellaneousFormView.FindControl("StrictureTR"), HtmlTableRow).Visible = False
            'CType(OgdMiscellaneousFormView.FindControl("TumourTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("ZLineTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("AmpullaryAdenomaTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("InletPouchTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("StentOcclusionTR"), HtmlTableRow).Visible = False 'Added by ferdowsi, TFS 4397
            CType(OgdMiscellaneousFormView.FindControl("PEGInSituTR"), HtmlTableRow).Visible = True 'Added by ferdowsi, TFS 4396
        End If

        If area.ToLower = "duodenum" Then
            CType(OgdMiscellaneousFormView.FindControl("WebTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("MalloryTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("SchatzkiRingTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("FoodResidueTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("InletPatchTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("MotilityDisorderTR"), HtmlTableRow).Visible = False
            'CType(OgdMiscellaneousFormView.FindControl("UlcerationTR"), HtmlTableRow).Visible = False    'commentted by ferdowsi 
            CType(OgdMiscellaneousFormView.FindControl("StrictureTR"), HtmlTableRow).Visible = False
            'CType(OgdMiscellaneousFormView.FindControl("TumourTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("ZLineTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("InletPouchTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("DiverticulumTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("PEGInSituTR"), HtmlTableRow).Visible = False 'Added by ferdowsi, TFS 4396
        End If
        ' added by Ferdowsi, TFS 4396
        If area.ToLower = "oesophagus" Then
            CType(OgdMiscellaneousFormView.FindControl("PEGInSituTR"), HtmlTableRow).Visible = False 'Added by ferdowsi, TFS 4396
        End If
        If Not area.ToLower = "duodenum" Then
            CType(OgdMiscellaneousFormView.FindControl("VolvulusTR"), HtmlTableRow).Visible = False
            CType(OgdMiscellaneousFormView.FindControl("AmpullaryAdenomaTR"), HtmlTableRow).Visible = False
        End If

    End Sub
End Class
