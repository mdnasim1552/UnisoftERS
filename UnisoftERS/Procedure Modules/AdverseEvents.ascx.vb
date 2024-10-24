Imports Telerik.Web.UI

Public Class AdverseEvents
    Inherits ProcedureControls

    Private Shared procType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            Try
                bindData()
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading Adverse Events for binding", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading adverse events")
                RadNotification1.Show()
            End Try
        End If
    End Sub

    Private Sub bindData()
        Try
            'databing repeater
            Dim dbResult = DataAdapter.LoadAdverseEvents(procType)

            If dbResult.Rows.Count > 0 Then
                AdverseEventsHeader.Visible = True
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "UniqueIDScript", $"<script>var otherBleedingUniqueId = '{dbResult.AsEnumerable().Where(Function(x) x("Description") = "Other Bleeding Text").Select(Function(x) x("UniqueID")).FirstOrDefault()}';</script>")

                Dim adverseevents = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = 0 And Not x("Description") = "Other Bleeding Text").CopyToDataTable '4321

                Dim resultDataTable As DataTable = DataHelper.GetColumnWiseSortedTable(adverseevents)
                rptAdverseEvents.DataSource = resultDataTable
                rptAdverseEvents.DataBind()

                'load procedure Adverse Events
                Dim procedureAdverseEvents = DataAdapter.getProcedureAdverseEvents(Session(Constants.SESSION_PROCEDURE_ID))

                For Each itm As RepeaterItem In rptAdverseEvents.Items
                    Dim chk As New CheckBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is CheckBox Then
                            chk = CType(ctrl, CheckBox)
                        End If
                    Next

                    If chk IsNot Nothing Then
                        If chk.Text.ToLower = "none" Then
                            chk.CssClass = chk.CssClass + " adverseevent-none"
                        End If

                        Dim adverseeventId = CInt(chk.Attributes.Item("data-adverseeventid"))

                        chk.Checked = procedureAdverseEvents.AsEnumerable.Any(Function(x) CInt(x("AdverseEventId")) = adverseeventId)

                        'get the checkbox- dataitem as nothing so cant get the values in that way :(
                        If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = adverseeventId) Then
                            Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = adverseeventId)

                            'check that none of the child items ids are parent ids of anything else
                            If childItems.Any(Function(x) x("AdditionalInfo")) Then
                                Dim txtChildAdverseEvent As New TextBox
                                With txtChildAdverseEvent
                                    '.RenderMode = RenderMode.Lightweight
                                    '.Skin = "Windows10"
                                    .CssClass = "adverseevent-child adverseevent-child-info"
                                    .Attributes.Add("data-adverseeventid", adverseeventId)
                                    .ID = CInt(childItems(0)("UniqueId"))
                                    .ClientIDMode = ClientIDMode.Static
                                    .Width = 100
                                    .MaxLength = 400
                                    If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                End With

                                Dim lblChildAdverseEvent As New RadLabel
                                With lblChildAdverseEvent
                                    .Text = childItems(0)("Description") & ":"
                                    .CssClass = "adverseevent-child"
                                    .Style.Add("padding-left", "15px")
                                    .Skin = "Metro"
                                    If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                End With

                                If procedureAdverseEvents.AsEnumerable.Any(Function(x) CInt(x("AdverseEventId")) = adverseeventId And CInt(x("ChildAdverseEventId")) > 0) Then
                                    Dim childAdverseEventText = (From pi In procedureAdverseEvents.AsEnumerable
                                                                 Where CInt(pi("AdverseEventId")) = adverseeventId
                                                                 Select pi("AdditionalInformation")).FirstOrDefault

                                    txtChildAdverseEvent.Text = childAdverseEventText
                                End If

                                itm.Controls.AddAt(itm.Controls.Count - 1, txtChildAdverseEvent)
                                itm.Controls.AddAt(itm.Controls.Count - 2, lblChildAdverseEvent)

                            Else

                                'create a dropdown list and bind child items to it
                                Dim ddlChildAdverseEvent As New RadComboBox
                                With ddlChildAdverseEvent
                                    .AutoPostBack = False
                                    .Skin = "Metro"
                                    .CssClass = "adverseevent-child"
                                    .Attributes.Add("data-adverseeventid", adverseeventId)
                                    .Style.Add("padding-left", "10px") '4321
                                    .Style.Add("width", "40%") '4321
                                    .OnClientSelectedIndexChanged = "childAdverseEvent_changed"
                                    If Not chk.Checked Then .Style.Add("display", "none")
                                End With


                                For Each ci In childItems
                                    ddlChildAdverseEvent.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                                Next
                                ddlChildAdverseEvent.Items.Insert(0, New RadComboBoxItem("", 0))

                                'If True Then
                                '    ddlChildComorbidity.Items.Add(New RadComboBoxItem() With {
                                '    .Text = "Add new",
                                '    .Value = -55,
                                '    .ImageUrl = "~/images/icons/add.png",
                                '    .CssClass = "comboNewItem"
                                '    })
                                '    ddlChildComorbidity.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & ddlChildComorbidity.ClientID & "); } else { window.parent.AddNewItemPopUp(" & ddlChildComorbidity.ClientID & ");" & " }")
                                'End If

                                ddlChildAdverseEvent.Sort = RadComboBoxSort.Ascending

                                If procedureAdverseEvents.AsEnumerable.Any(Function(x) CInt(x("AdverseEventId")) = adverseeventId And CInt(x("ChildAdverseEventId")) > 0) Then
                                    Dim childAdverseEventId = (From pi In procedureAdverseEvents.AsEnumerable
                                                               Where CInt(pi("AdverseEventId")) = adverseeventId
                                                               Select CInt(pi("ChildAdverseEventId"))).FirstOrDefault

                                    ddlChildAdverseEvent.SelectedIndex = ddlChildAdverseEvent.Items.FindItemIndexByValue(childAdverseEventId)
                                End If

                                'add the control to the relevant td
                                itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildAdverseEvent)
                            End If

                        End If
                    End If
                Next

                If dbResult.AsEnumerable.Any(Function(x) CBool(x("AdditionalInfo")) And CInt(x("ParentId")) = 0) Then
                    rptAdverseEventsAdditionalInfo.DataSource = dbResult.AsEnumerable.Where(Function(x) CBool(x("AdditionalInfo")) And CInt(x("ParentId")) = 0).CopyToDataTable
                    rptAdverseEventsAdditionalInfo.DataBind()

                    For Each itm As RepeaterItem In rptAdverseEventsAdditionalInfo.Items
                        Dim tb As New RadTextBox

                        For Each ctrl As Control In itm.Controls
                            If TypeOf ctrl Is RadTextBox Then
                                tb = CType(ctrl, RadTextBox)
                            End If
                        Next

                        If tb IsNot Nothing Then
                            Dim adverseEventId = CInt(tb.Attributes.Item("data-adverseeventid"))

                            tb.Text = (From si In procedureAdverseEvents Where CInt(si("AdverseEventId")) = adverseEventId
                                       Select si("AdditionalInformation")).FirstOrDefault
                        End If
                    Next
                End If
            Else
                AdverseEventsHeader.Visible = False
                AdverseEventsContent.Visible = False
            End If

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error binding Adverse Events", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading the data")
        End Try
    End Sub

    Protected Sub rptAdverseEvents_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " adverseevent-other-entry-toggle" 'set new classname as original once casuses an autosave
                        chk.Attributes.Add("onchange", "checkAndNotifyTextEntry('" & chk.ClientID & "','adverseevent')")
                    End If
                Next
            End If
        End If
    End Sub


End Class