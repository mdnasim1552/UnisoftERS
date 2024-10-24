Imports Telerik.Web.UI

Public Class Indications
    Inherits ProcedureControls

    Private Shared procType As Integer
    Private Shared dbResult As DataTable


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            Try
                If procType = CInt(ProcedureType.Bronchoscopy) OrElse procType = CInt(ProcedureType.EBUS) Then
                    RepeatProcedureDiv.Visible = True
                    populateRepeatProcedure()
                End If
                bindSurveillanceIndications()
                bindIndications()
                'Added by rony tfs-4358
                If procType <> CInt(ProcedureType.Proctoscopy) Then
                    bindPlannedIndications()
                End If

                bindSubIndications()
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading indications for binding", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading indications")
                RadNotification1.Show()
            End Try

        End If
    End Sub

    Private Sub populateRepeatProcedure()
        Try
            RepeatNotKnownRadComboBox.DataSource = DataAdapter.GetRepeatUnknownValues()
            RepeatNotKnownRadComboBox.DataBind()

            'get and set result
            Dim repeatDt = DataAdapter.GetRepeatProcedureResult(Session(Constants.SESSION_PROCEDURE_ID))

            If repeatDt IsNot Nothing AndAlso repeatDt.Rows.Count > 0 Then
                Dim dr = repeatDt.Rows(0)

                Dim selectedAnswer = CBool(dr("Answer"))
                Dim repeatUnknownValue = CInt(dr("RepeatUnknownId"))
                Dim otherTextValue = CStr(dr("OtherTextValue"))

                If selectedAnswer = True Then
                    RepeatRadioButtonList.SelectedValue = 1
                    RepeatUnknownDiv.Attributes.Add("style", "display: block;")
                    RepeatNotKnownRadComboBox.SelectedValue = repeatUnknownValue
                    If Not String.IsNullOrWhiteSpace(otherTextValue) Then
                        RepeatTextDiv.Attributes.Add("style", "display: block;")
                        RepeatTextBox.Text = otherTextValue
                    End If
                Else
                    RepeatRadioButtonList.SelectedValue = 0
                End If
            End If
        Catch ex As Exception

        End Try
    End Sub

    Private Sub bindIndications()
        Try
            'databing repeater
            dbResult = DataAdapter.LoadIndications(procType).AsEnumerable().Where(Function(x) CInt(x("SectionId")) <> 5 And CInt(x("SectionId")) <> 6).CopyToDataTable()

            rptSections.DataSource = (From i In dbResult.AsEnumerable
                                      Select SectionId = i("SectionId"), SectionName = i("SectionName") Order By SectionId Distinct)
            rptSections.DataBind()

            'load procedure indications
            Dim procedureIndications = DataAdapter.GetProcedureIndications(Session(Constants.SESSION_PROCEDURE_ID))

            For Each sectionItem As RepeaterItem In rptSections.Items
                Dim rptIndications As Repeater = sectionItem.FindControl("rptIndications")
                Dim sectionName = CType(sectionItem.FindControl("SectionNameLabel"), Label).Text

                ' Colummn wise Checkbox sorting part
                Dim filteredDataTable = dbResult.AsEnumerable().
                                Where(Function(x) x("SectionName").ToString() = sectionName AndAlso CInt(x("ParentId")) = 0).
                                CopyToDataTable()

                Dim resultDataTable As DataTable = DataHelper.GetColumnWiseSortedTable(filteredDataTable)

                rptIndications.DataSource = resultDataTable
                rptIndications.DataBind()
                ' Colummn wise Checkbox sorting part

                For Each itm As RepeaterItem In rptIndications.Items
                    Dim chk As New CheckBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is CheckBox Then
                            chk = CType(ctrl, CheckBox)
                        End If
                    Next

                    If chk IsNot Nothing Then
                        Dim jagAuditable = CBool(chk.Attributes.Item("data-jagauditable"))
                        If jagAuditable Then
                            Dim img As New HtmlImage
                            img.Src = "../Images/NEDJAG/JAGNED.png"
                            chk.CssClass = chk.CssClass + " jag-audit-control"
                            itm.Controls.AddAt(itm.Controls.Count - 1, img)
                        End If

                        Dim indicationsId = CInt(chk.Attributes.Item("data-indicationid"))


                        chk.Checked = procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId)

                        'get the checkbox- dataitem as nothing so cant get the values in that way :(
                        If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = indicationsId) Then
                            Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = indicationsId)

                            If childItems.Any(Function(x) x("AdditionalInfo")) Then
                                Dim txtChildIndication As New TextBox
                                With txtChildIndication
                                    .TextMode = TextBoxMode.Number
                                    '.RenderMode = RenderMode.Lightweight
                                    '.Skin = "Windows10"
                                    .CssClass = "indications-child indications-child-info"
                                    .Attributes.Add("data-indicationid", indicationsId)
                                    .ID = CInt(childItems(0)("UniqueId"))
                                    .ClientIDMode = ClientIDMode.Static
                                    .Width = 55
                                    If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                End With

                                Dim lblChildIndication As New Label
                                With lblChildIndication
                                    .Text = "(ug/mg)"
                                    .CssClass = "indications-child"
                                    If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                End With

                                If procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId AndAlso
                                                                                    x("ChildIndicationId") IsNot DBNull.Value AndAlso CInt(x("ChildIndicationId")) > 0) Then
                                    Dim childIndicationText = (From pi In procedureIndications.AsEnumerable
                                                               Where CInt(pi("IndicationId")) = indicationsId
                                                               Select pi("AdditionalInformation")).FirstOrDefault

                                    txtChildIndication.Text = childIndicationText
                                End If

                                itm.Controls.AddAt(itm.Controls.Count - 1, txtChildIndication)
                                itm.Controls.AddAt(itm.Controls.Count - 1, lblChildIndication)

                            Else
                                'create a dropdown list and bind child items to it
                                Dim ddlChildIndications As New RadComboBox
                                With ddlChildIndications
                                    .AutoPostBack = False
                                    .Skin = "Metro"
                                    .CssClass = "indications-child"
                                    .Attributes.Add("data-indicationid", indicationsId)
                                    .OnClientSelectedIndexChanged = "childIndication_changed"
                                    If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                End With


                                For Each ci In childItems
                                    ddlChildIndications.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                                Next
                                ddlChildIndications.Items.Insert(0, New RadComboBoxItem("", 0))

                                ddlChildIndications.Sort = RadComboBoxSort.Ascending

                                If procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId AndAlso
                                                                                    x("ChildIndicationId") IsNot DBNull.Value AndAlso CInt(x("ChildIndicationId")) > 0) Then
                                    Dim childIndicationId = (From pi In procedureIndications.AsEnumerable
                                                             Where CInt(pi("IndicationId")) = indicationsId
                                                             Select CInt(pi("ChildIndicationId"))).FirstOrDefault

                                    ddlChildIndications.SelectedIndex = ddlChildIndications.Items.FindItemIndexByValue(childIndicationId)
                                End If

                                'add the control to the relevant td
                                itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildIndications)
                            End If

                        End If

                    End If
                Next
            Next
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Protected Sub ParentRepeater_ItemDataBound(ByVal sender As Object, ByVal e As RepeaterItemEventArgs)
        Dim procedureIndications = DataAdapter.GetProcedureIndications(Session(Constants.SESSION_PROCEDURE_ID))
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim childRepeater As Repeater = DirectCast(e.Item.FindControl("rptIndicationsAdditionalInfo"), Repeater)
            ' Set the data source for the child Repeater (e.g., dtChild)

            If dbResult.AsEnumerable.Any(Function(x) CBool(x("AdditionalInfo")) And CInt(x("ParentId")) = 0) Then
                childRepeater.DataSource = dbResult.AsEnumerable.Where(Function(x) CBool(x("AdditionalInfo")) And CInt(x("ParentId")) = 0).CopyToDataTable
                childRepeater.DataBind()

                For Each itm As RepeaterItem In childRepeater.Items
                    Dim tb As New RadTextBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is RadTextBox Then
                            tb = CType(ctrl, RadTextBox)
                        End If
                    Next

                    If tb IsNot Nothing Then
                        Dim indicationsId = CInt(tb.Attributes.Item("data-indicationid"))

                        tb.Text = (From si In procedureIndications Where CInt(si("IndicationId")) = indicationsId
                                   Select si("AdditionalInformation")).FirstOrDefault
                    End If
                Next
            End If
        End If
    End Sub


    Private Sub bindSubIndications()
        Try

            Dim subIndicationsDT As DataTable = DataAdapter.LoadSubIndications(procType)

            rptSubIndications.DataSource = subIndicationsDT
            rptSubIndications.DataBind()

            'load procedure indications
            Dim procedureSubIndications = DataAdapter.GetProcedureSubIndications(Session(Constants.SESSION_PROCEDURE_ID))

            For Each itm As RepeaterItem In rptSubIndications.Items

                Dim chk As New CheckBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                    End If
                Next

                If chk IsNot Nothing Then
                    Dim subIndicationsId = CInt(chk.Attributes.Item("data-subindicationid"))

                    chk.Checked = procedureSubIndications.AsEnumerable.Any(Function(x) CInt(x("SubIndicationId")) = subIndicationsId)
                End If
            Next

            'additional info/other text boxes
            If subIndicationsDT.AsEnumerable.Any(Function(x) x("AdditionalInfo")) Then
                Dim filteredDataTable = subIndicationsDT.AsEnumerable.Where(Function(x) x("AdditionalInfo")).CopyToDataTable
                Dim resultDataTable As DataTable = DataHelper.GetColumnWiseSortedTable(filteredDataTable)

                rptSubIndicationsAdditionalInfo.DataSource = resultDataTable
                rptSubIndicationsAdditionalInfo.DataBind()
            End If

            For Each itm As RepeaterItem In rptSubIndicationsAdditionalInfo.Items

                Dim tb As New RadTextBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is RadTextBox Then
                        tb = CType(ctrl, RadTextBox)
                    End If
                Next

                If tb IsNot Nothing Then
                    Dim subIndicationsId = CInt(tb.Attributes.Item("data-subindicationid"))

                    tb.Text = (From si In procedureSubIndications Where CInt(si("SubIndicationId")) = subIndicationsId
                               Select si("AdditionalInfo")).FirstOrDefault
                End If
            Next

        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Protected Sub rptIndications_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Parent/child items

            If CInt(CType(e.Item.DataItem, DataRowView)("ParentId")) > 0 Then
                Exit Sub
            End If

            'mark jag auditable items
            If CType(CType(e.Item.DataItem, DataRowView).Row("JAGAuditable"), Boolean) Then

            End If

            If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
                Dim someLiteral As Literal = e.Item.FindControl("someliteral")
            End If

            'Other textbox
            'If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
            '    Dim chk As New CheckBox

            '    'For Each ctrl As Control In e.Item.Controls
            '    '    If TypeOf ctrl Is CheckBox Then
            '    '        chk = CType(ctrl, CheckBox)
            '    '        chk.CssClass += " indications-other-entry-toggle" 'set new classname as original once casuses an autosave
            '    '        chk.Attributes.Add("onchange", "checkAndNotifyTextEntry('" & chk.ClientID & "','indications')")
            '    '    End If
            '    'Next
            '    For Each ctrl As Control In e.Item.Controls
            '        If TypeOf ctrl Is WebControl Then
            '            'DirectCast(ctrl, WebControl).Attributes.CssStyle.Add("display", "none")
            '            DirectCast(ctrl, WebControl).CssClass += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + " "
            '        ElseIf TypeOf ctrl Is HtmlControl Then
            '            'DirectCast(ctrl, HtmlControl).Style.Add("display", "none")
            '            DirectCast(ctrl, HtmlControl).Attributes("class") += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + " "
            '        End If
            '    Next
            'End If

            'GI Bleeds
            If CType(e.Item.DataItem, DataRowView).Row("Description").ToString.ToLower = "haematemesis" Or CType(e.Item.DataItem, DataRowView).Row("Description").ToString.ToLower = "melaena" Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " gi-data-toggle" 'Give classname to control for JS
                        chk.Attributes.Add("onchange", "ToggleGIBleedsButton()")
                    End If
                Next

                'create GI Bleeds button
                Dim btnGIBleeds As New RadButton
                With btnGIBleeds
                    .Text = "GI Bleeds"
                    .CssClass = "gi-bleeds-button"
                    .Icon.PrimaryIconUrl = "~/Images/icons/GI_Bleeds.png"
                    .OnClientClicked = "openGIBleedsPopUp"
                    .Skin = "Metro"
                    .AutoPostBack = False
                End With

                'add the button
                e.Item.Controls.AddAt(e.Item.Controls.Count - 1, btnGIBleeds)
            End If

            'sub indications
            If CType(CType(e.Item.DataItem, DataRowView).Row("SubIndicationParent"), Boolean) = True Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " sub-indication-parent"
                        chk.Attributes.Add("data-indicationId", CType(e.Item.DataItem, DataRowView).Row("UniqueId"))
                        chk.Attributes.Add("onchange", "ToggleSubIndications()")
                    End If
                Next
            End If
        End If
    End Sub
    Protected Sub rptIndicationsAdditionalInfo_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is WebControl Then
                        'DirectCast(ctrl, WebControl).Attributes.CssStyle.Add("display", "none")
                        DirectCast(ctrl, WebControl).CssClass += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_indication ", " ")
                    ElseIf TypeOf ctrl Is HtmlControl Then
                        'DirectCast(ctrl, HtmlControl).Style.Add("display", "none")
                        DirectCast(ctrl, HtmlControl).Attributes("class") += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_indication ", " ")
                    End If
                Next

            End If
        End If
    End Sub
    Protected Sub rptSubIndicationsAdditionalInfo_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " subindications-other-entry-toggle " 'set new classname as original once casuses an autosave CType(e.Item.DataItem, DataRowView).Row("Description") + " "
                        chk.Attributes.Add("onchange", "checkAndNotifyTextEntry('" & chk.ClientID & "','subindications')")
                    End If
                Next
                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is WebControl Then
                        'DirectCast(ctrl, WebControl).Attributes.CssStyle.Add("display", "none")
                        DirectCast(ctrl, WebControl).CssClass += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + " "
                    ElseIf TypeOf ctrl Is HtmlControl Then
                        'DirectCast(ctrl, HtmlControl).Style.Add("display", "none")
                        DirectCast(ctrl, HtmlControl).Attributes("class") += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + " "
                    End If
                Next

            End If
        End If
    End Sub

    Protected Sub rptSectionsPlanned_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        Dim procedureIndications = DataAdapter.GetProcedureIndications(Session(Constants.SESSION_PROCEDURE_ID))
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim childRepeater As Repeater = DirectCast(e.Item.FindControl("rptPlannedIndicationsAdditionalInfo"), Repeater)
            ' Set the data source for the child Repeater (e.g., dtChild)

            If dbResult.AsEnumerable.Any(Function(x) CBool(x("AdditionalInfo")) And CInt(x("ParentId")) = 0) Then
                childRepeater.DataSource = dbResult.AsEnumerable.Where(Function(x) CBool(x("AdditionalInfo")) And CInt(x("ParentId")) = 0).CopyToDataTable
                childRepeater.DataBind()

                For Each itm As RepeaterItem In childRepeater.Items
                    Dim tb As New RadTextBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is RadTextBox Then
                            tb = CType(ctrl, RadTextBox)
                        End If
                    Next

                    If tb IsNot Nothing Then
                        Dim indicationsId = CInt(tb.Attributes.Item("data-indicationid"))

                        tb.Text = (From si In procedureIndications Where CInt(si("IndicationId")) = indicationsId
                                   Select si("AdditionalInformation")).FirstOrDefault
                    End If
                Next
            End If
        End If
    End Sub

    Protected Sub rptPlannedIndications_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Parent/child items

            If CInt(CType(e.Item.DataItem, DataRowView)("ParentId")) > 0 Then
                Exit Sub
            End If

            'mark jag auditable items
            If CType(CType(e.Item.DataItem, DataRowView).Row("JAGAuditable"), Boolean) Then

            End If

            If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
                Dim someLiteral As Literal = e.Item.FindControl("someliteral")
            End If

            'Other textbox
            'If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
            '    Dim chk As New CheckBox

            '    For Each ctrl As Control In e.Item.Controls
            '        If TypeOf ctrl Is CheckBox Then
            '            chk = CType(ctrl, CheckBox)
            '            chk.CssClass += " indications-other-entry-toggle" 'set new classname as original once casuses an autosave
            '            chk.Attributes.Add("onchange", "checkAndNotifyTextEntry('" & chk.ClientID & "','indications')")
            '        End If
            '    Next
            'End If

            'GI Bleeds
            If CType(e.Item.DataItem, DataRowView).Row("Description").ToString.ToLower = "haematemesis" Or CType(e.Item.DataItem, DataRowView).Row("Description").ToString.ToLower = "melaena" Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " gi-data-toggle" 'Give classname to control for JS
                        chk.Attributes.Add("onchange", "ToggleGIBleedsButton()")
                    End If
                Next

                'create GI Bleeds button
                Dim btnGIBleeds As New RadButton
                With btnGIBleeds
                    .Text = "GI Bleeds"
                    .CssClass = "gi-bleeds-button"
                    .Icon.PrimaryIconUrl = "~/Images/icons/GI_Bleeds.png"
                    .OnClientClicked = "openGIBleedsPopUp"
                    .Skin = "Metro"
                    .AutoPostBack = False
                End With

                'add the button
                e.Item.Controls.AddAt(e.Item.Controls.Count - 1, btnGIBleeds)
            End If

            'sub indications
            If CType(CType(e.Item.DataItem, DataRowView).Row("SubIndicationParent"), Boolean) = True Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " sub-indication-parent"
                        chk.Attributes.Add("data-indicationId", CType(e.Item.DataItem, DataRowView).Row("UniqueId"))
                        chk.Attributes.Add("onchange", "ToggleSubIndications()")
                    End If
                Next
            End If
        End If
    End Sub

    Private Sub bindPlannedIndications()
        Try
            dbResult = DataAdapter.LoadIndications(procType)
            ' Check if dbResult is not null and has rows
            If dbResult IsNot Nothing AndAlso dbResult.Rows.Count > 0 Then
                Dim filteredResult = dbResult.AsEnumerable().Where(Function(x) CInt(x("SectionId")) = 5)
                If filteredResult IsNot Nothing AndAlso filteredResult.Any() Then
                    dbResult = filteredResult.CopyToDataTable()

                    rptSectionsPlanned.DataSource = (From i In dbResult.AsEnumerable
                                                     Select SectionId = i("SectionId"), SectionName = i("SectionName") Order By SectionId Distinct)
                    rptSectionsPlanned.DataBind()

                    'load procedure indications
                    Dim procedureIndications = DataAdapter.GetProcedureIndications(Session(Constants.SESSION_PROCEDURE_ID))

                    For Each sectionItem As RepeaterItem In rptSectionsPlanned.Items
                        Dim rptIndications As Repeater = sectionItem.FindControl("rptPlannedIndications")
                        Dim sectionName = CType(sectionItem.FindControl("SectionNameLabel"), Label).Text

                        ' Colummn wise Checkbox sorting part

                        Dim filteredDataTable = dbResult.AsEnumerable().
                                        Where(Function(x) x("SectionName").ToString() = sectionName AndAlso CInt(x("ParentId")) = 0).
                                        CopyToDataTable()

                        Dim resultDataTable As DataTable = DataHelper.GetColumnWiseSortedTable(filteredDataTable)
                        rptIndications.DataSource = resultDataTable
                        rptIndications.DataBind()

                        ' Colummn wise Checkbox sorting part

                        For Each itm As RepeaterItem In rptIndications.Items
                            Dim chk As New CheckBox

                            For Each ctrl As Control In itm.Controls
                                If TypeOf ctrl Is CheckBox Then
                                    chk = CType(ctrl, CheckBox)
                                End If
                            Next

                            If chk IsNot Nothing Then
                                Dim jagAuditable = CBool(chk.Attributes.Item("data-jagauditable"))
                                If jagAuditable Then
                                    Dim img As New HtmlImage
                                    img.Src = "../Images/NEDJAG/JAGNED.png"
                                    chk.CssClass = chk.CssClass + " jag-audit-control"
                                    itm.Controls.AddAt(itm.Controls.Count - 1, img)
                                End If

                                Dim indicationsId = CInt(chk.Attributes.Item("data-indicationid"))


                                chk.Checked = procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId)

                                'get the checkbox- dataitem as nothing so cant get the values in that way :(
                                If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = indicationsId) Then
                                    Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = indicationsId)

                                    If childItems.Any(Function(x) x("AdditionalInfo")) Then
                                        Dim txtChildIndication As New TextBox
                                        With txtChildIndication
                                            .TextMode = TextBoxMode.Number
                                            '.RenderMode = RenderMode.Lightweight
                                            '.Skin = "Windows10"
                                            .CssClass = "indications-child indications-child-info"
                                            .Attributes.Add("data-indicationid", indicationsId)
                                            .ID = CInt(childItems(0)("UniqueId"))
                                            .ClientIDMode = ClientIDMode.Static
                                            .Width = 55
                                            If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                        End With

                                        Dim lblChildIndication As New Label
                                        With lblChildIndication
                                            .Text = "(ug/mg)"
                                            .CssClass = "indications-child"
                                            If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                        End With

                                        If procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId AndAlso
                                                                                            x("ChildIndicationId") IsNot DBNull.Value AndAlso CInt(x("ChildIndicationId")) > 0) Then
                                            Dim childIndicationText = (From pi In procedureIndications.AsEnumerable
                                                                       Where CInt(pi("IndicationId")) = indicationsId
                                                                       Select pi("AdditionalInformation")).FirstOrDefault

                                            txtChildIndication.Text = childIndicationText
                                        End If

                                        itm.Controls.AddAt(itm.Controls.Count - 1, txtChildIndication)
                                        itm.Controls.AddAt(itm.Controls.Count - 1, lblChildIndication)

                                    Else
                                        'create a dropdown list and bind child items to it
                                        Dim ddlChildIndications As New RadComboBox
                                        With ddlChildIndications
                                            .AutoPostBack = False
                                            .Skin = "Metro"
                                            .CssClass = "indications-child"
                                            .Attributes.Add("data-indicationid", indicationsId)
                                            .OnClientSelectedIndexChanged = "childIndication_changed"
                                            If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                        End With


                                        For Each ci In childItems
                                            ddlChildIndications.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                                        Next
                                        ddlChildIndications.Items.Insert(0, New RadComboBoxItem("", 0))

                                        ddlChildIndications.Sort = RadComboBoxSort.Ascending

                                        If procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId AndAlso
                                                                                            x("ChildIndicationId") IsNot DBNull.Value AndAlso CInt(x("ChildIndicationId")) > 0) Then
                                            Dim childIndicationId = (From pi In procedureIndications.AsEnumerable
                                                                     Where CInt(pi("IndicationId")) = indicationsId
                                                                     Select CInt(pi("ChildIndicationId"))).FirstOrDefault

                                            ddlChildIndications.SelectedIndex = ddlChildIndications.Items.FindItemIndexByValue(childIndicationId)
                                        End If

                                        'add the control to the relevant td
                                        itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildIndications)
                                    End If

                                End If

                            End If
                        Next
                    Next
                Else
                    Me.rptSectionsPlannedDiv.Visible = False
                End If
            End If


        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Protected Sub rptPlannedIndicationsAdditionalInfo_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is WebControl Then
                        'DirectCast(ctrl, WebControl).Attributes.CssStyle.Add("display", "none")
                        DirectCast(ctrl, WebControl).CssClass += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_planned ", " ")
                    ElseIf TypeOf ctrl Is HtmlControl Then
                        'DirectCast(ctrl, HtmlControl).Style.Add("display", "none")
                        DirectCast(ctrl, HtmlControl).Attributes("class") += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_planned ", " ")
                    End If
                Next

            End If
        End If
    End Sub
    Private Sub bindSurveillanceIndications()
        Try
            dbResult = DataAdapter.LoadIndications(procType)
            ' Check if dbResult is not null and has rows
            If dbResult IsNot Nothing AndAlso dbResult.Rows.Count > 0 Then
                Dim filteredResult = dbResult.AsEnumerable().Where(Function(x) CInt(x("SectionId")) = 6)
                If filteredResult IsNot Nothing AndAlso filteredResult.Any() Then
                    dbResult = filteredResult.CopyToDataTable()

                    rptSurveillance.DataSource = (From i In dbResult.AsEnumerable
                                                  Select SectionId = i("SectionId"), SectionName = i("SectionName") Order By SectionId Distinct)
                    rptSurveillance.DataBind()

                    'load procedure indications
                    Dim procedureIndications = DataAdapter.GetProcedureIndications(Session(Constants.SESSION_PROCEDURE_ID))

                    For Each sectionItem As RepeaterItem In rptSurveillance.Items
                        Dim rptIndications As Repeater = sectionItem.FindControl("rptSurveillanceIndications")
                        Dim sectionName = CType(sectionItem.FindControl("SectionNameLabel"), Label).Text

                        ' Colummn wise Checkbox sorting part

                        Dim filteredDataTable = dbResult.AsEnumerable().
                                        Where(Function(x) x("SectionName").ToString() = sectionName AndAlso CInt(x("ParentId")) = 0).
                                        CopyToDataTable()

                        Dim resultDataTable As DataTable = DataHelper.GetColumnWiseSortedTable(filteredDataTable)
                        rptIndications.DataSource = resultDataTable
                        rptIndications.DataBind()

                        ' Colummn wise Checkbox sorting part

                        For Each itm As RepeaterItem In rptIndications.Items
                            Dim chk As New CheckBox

                            For Each ctrl As Control In itm.Controls
                                If TypeOf ctrl Is CheckBox Then
                                    chk = CType(ctrl, CheckBox)
                                End If
                            Next

                            If chk IsNot Nothing Then
                                Dim jagAuditable = CBool(chk.Attributes.Item("data-jagauditable"))
                                If jagAuditable Then
                                    Dim img As New HtmlImage
                                    img.Src = "../Images/NEDJAG/JAGNED.png"
                                    chk.CssClass = chk.CssClass + " jag-audit-control"
                                    itm.Controls.AddAt(itm.Controls.Count - 1, img)
                                End If

                                Dim indicationsId = CInt(chk.Attributes.Item("data-indicationid"))


                                chk.Checked = procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId)

                                'get the checkbox- dataitem as nothing so cant get the values in that way :(
                                If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = indicationsId) Then
                                    Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = indicationsId)

                                    If childItems.Any(Function(x) x("AdditionalInfo")) Then
                                        Dim txtChildIndication As New TextBox
                                        With txtChildIndication
                                            .TextMode = TextBoxMode.Number
                                            '.RenderMode = RenderMode.Lightweight
                                            '.Skin = "Windows10"
                                            .CssClass = "indications-child indications-child-info"
                                            .Attributes.Add("data-indicationid", indicationsId)
                                            .ID = CInt(childItems(0)("UniqueId"))
                                            .ClientIDMode = ClientIDMode.Static
                                            .Width = 55
                                            If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                        End With

                                        Dim lblChildIndication As New Label
                                        With lblChildIndication
                                            .Text = "(ug/mg)"
                                            .CssClass = "indications-child"
                                            If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                        End With

                                        If procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId AndAlso
                                                                                            x("ChildIndicationId") IsNot DBNull.Value AndAlso CInt(x("ChildIndicationId")) > 0) Then
                                            Dim childIndicationText = (From pi In procedureIndications.AsEnumerable
                                                                       Where CInt(pi("IndicationId")) = indicationsId
                                                                       Select pi("AdditionalInformation")).FirstOrDefault

                                            txtChildIndication.Text = childIndicationText
                                        End If

                                        itm.Controls.AddAt(itm.Controls.Count - 1, txtChildIndication)
                                        itm.Controls.AddAt(itm.Controls.Count - 1, lblChildIndication)

                                    Else
                                        'create a dropdown list and bind child items to it
                                        Dim ddlChildIndications As New RadComboBox
                                        With ddlChildIndications
                                            .AutoPostBack = False
                                            .Skin = "Metro"
                                            .CssClass = "indications-child"
                                            .Attributes.Add("data-indicationid", indicationsId)
                                            .OnClientSelectedIndexChanged = "childIndication_changed"
                                            If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                        End With


                                        For Each ci In childItems
                                            ddlChildIndications.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                                        Next
                                        ddlChildIndications.Items.Insert(0, New RadComboBoxItem("", 0))

                                        ddlChildIndications.Sort = RadComboBoxSort.Ascending

                                        If procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId AndAlso
                                                                                            x("ChildIndicationId") IsNot DBNull.Value AndAlso CInt(x("ChildIndicationId")) > 0) Then
                                            Dim childIndicationId = (From pi In procedureIndications.AsEnumerable
                                                                     Where CInt(pi("IndicationId")) = indicationsId
                                                                     Select CInt(pi("ChildIndicationId"))).FirstOrDefault

                                            ddlChildIndications.SelectedIndex = ddlChildIndications.Items.FindItemIndexByValue(childIndicationId)
                                        End If

                                        'add the control to the relevant td
                                        itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildIndications)
                                    End If

                                End If

                            End If
                        Next
                    Next
                Else
                    Me.rptSurveillanceDiv.Visible = False
                End If
            End If


        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    Protected Sub rptSurveillanceAdditionalInfo_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is WebControl Then
                        'DirectCast(ctrl, WebControl).Attributes.CssStyle.Add("display", "none")
                        DirectCast(ctrl, WebControl).CssClass += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_surveillance ", " ")
                    ElseIf TypeOf ctrl Is HtmlControl Then
                        'DirectCast(ctrl, HtmlControl).Style.Add("display", "none")
                        DirectCast(ctrl, HtmlControl).Attributes("class") += " " + Regex.Replace(CType(e.Item.DataItem, DataRowView).Row("Description"), "[^a-zA-Z0-9]", "_") + If(CType(e.Item.DataItem, DataRowView).Row("Description") = "Other", "_surveillance ", " ")
                    End If
                Next

            End If
        End If
    End Sub

    Protected Sub rptSurveillanceIndications_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Parent/child items

            If CInt(CType(e.Item.DataItem, DataRowView)("ParentId")) > 0 Then
                Exit Sub
            End If

            'mark jag auditable items
            If CType(CType(e.Item.DataItem, DataRowView).Row("JAGAuditable"), Boolean) Then

            End If

            If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
                Dim someLiteral As Literal = e.Item.FindControl("someliteral")
            End If

            'Other textbox
            'If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
            '    Dim chk As New CheckBox

            '    For Each ctrl As Control In e.Item.Controls
            '        If TypeOf ctrl Is CheckBox Then
            '            chk = CType(ctrl, CheckBox)
            '            chk.CssClass += " indications-other-entry-toggle" 'set new classname as original once casuses an autosave
            '            chk.Attributes.Add("onchange", "checkAndNotifyTextEntry('" & chk.ClientID & "','indications')")
            '        End If
            '    Next
            'End If

            'GI Bleeds
            If CType(e.Item.DataItem, DataRowView).Row("Description").ToString.ToLower = "haematemesis" Or CType(e.Item.DataItem, DataRowView).Row("Description").ToString.ToLower = "melaena" Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " gi-data-toggle" 'Give classname to control for JS
                        chk.Attributes.Add("onchange", "ToggleGIBleedsButton()")
                    End If
                Next

                'create GI Bleeds button
                Dim btnGIBleeds As New RadButton
                With btnGIBleeds
                    .Text = "GI Bleeds"
                    .CssClass = "gi-bleeds-button"
                    .Icon.PrimaryIconUrl = "~/Images/icons/GI_Bleeds.png"
                    .OnClientClicked = "openGIBleedsPopUp"
                    .Skin = "Metro"
                    .AutoPostBack = False
                End With

                'add the button
                e.Item.Controls.AddAt(e.Item.Controls.Count - 1, btnGIBleeds)
            End If

            'sub indications
            If CType(CType(e.Item.DataItem, DataRowView).Row("SubIndicationParent"), Boolean) = True Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " sub-indication-parent"
                        chk.Attributes.Add("data-indicationId", CType(e.Item.DataItem, DataRowView).Row("UniqueId"))
                        chk.Attributes.Add("onchange", "ToggleSubIndications()")
                    End If
                Next
            End If
        End If
    End Sub

    Protected Sub rptSurveillance_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        Dim procedureIndications = DataAdapter.GetProcedureIndications(Session(Constants.SESSION_PROCEDURE_ID))
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim childRepeater As Repeater = DirectCast(e.Item.FindControl("rptSurveillanceAdditionalInfo"), Repeater)
            ' Set the data source for the child Repeater (e.g., dtChild)

            If dbResult.AsEnumerable.Any(Function(x) CBool(x("AdditionalInfo")) And CInt(x("ParentId")) = 0) Then
                childRepeater.DataSource = dbResult.AsEnumerable.Where(Function(x) CBool(x("AdditionalInfo")) And CInt(x("ParentId")) = 0).CopyToDataTable
                childRepeater.DataBind()

                For Each itm As RepeaterItem In childRepeater.Items
                    Dim tb As New RadTextBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is RadTextBox Then
                            tb = CType(ctrl, RadTextBox)
                        End If
                    Next

                    If tb IsNot Nothing Then
                        Dim indicationsId = CInt(tb.Attributes.Item("data-indicationid"))

                        tb.Text = (From si In procedureIndications Where CInt(si("IndicationId")) = indicationsId
                                   Select si("AdditionalInformation")).FirstOrDefault
                    End If
                Next
            End If
        End If
    End Sub
End Class