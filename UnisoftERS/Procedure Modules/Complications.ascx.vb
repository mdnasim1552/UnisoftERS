Imports Telerik.Web.UI

Public Class Complications
    Inherits ProcedureControls

    Private Shared procType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            bindData()
        End If
    End Sub

    Private Sub bindData()
        Try
            'databing repeater
            Dim dbResult = DataAdapter.LoadComplications()
            Dim complications = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = 0)

            If complications.Count > 0 Then
                rptComplication.DataSource = complications.CopyToDataTable
                rptComplication.DataBind()

                'load procedure Comorbidity
                Dim procedureComplications = DataAdapter.GetProcedureComplication(Session(Constants.SESSION_PROCEDURE_ID))

                For Each itm As RepeaterItem In rptComplication.Items
                    Dim chk As New CheckBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is CheckBox Then
                            chk = CType(ctrl, CheckBox)
                        End If
                    Next

                    If chk IsNot Nothing Then
                        Dim complicationsId = CInt(chk.Attributes.Item("data-complicationid"))

                        chk.Checked = procedureComplications.AsEnumerable.Any(Function(x) CInt(x("ComplicationId")) = complicationsId)

                        'get the checkbox- dataitem as nothing so cant get the values in that way :(
                        If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = complicationsId) Then
                            Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = complicationsId)

                            'check that none of the child items ids are parent ids of anything else


                            'create a dropdown list and bind child items to it
                            Dim ddlChildComplication As New RadComboBox
                            With ddlChildComplication
                                .AutoPostBack = False
                                .Skin = "Metro"
                                .CssClass = "complication-child"
                                .Attributes.Add("data-complication", complicationsId)
                                .OnClientSelectedIndexChanged = "childComplication_changed"
                                If Not chk.Checked Then .Style.Add("display", "none")
                            End With


                            For Each ci In childItems
                                ddlChildComplication.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                            Next
                            ddlChildComplication.Items.Insert(0, New RadComboBoxItem("", 0))

                            'If True Then
                            '    ddlChildComorbidity.Items.Add(New RadComboBoxItem() With {
                            '    .Text = "Add new",
                            '    .Value = -55,
                            '    .ImageUrl = "~/images/icons/add.png",
                            '    .CssClass = "comboNewItem"
                            '    })
                            '    ddlChildComorbidity.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & ddlChildComorbidity.ClientID & "); } else { window.parent.AddNewItemPopUp(" & ddlChildComorbidity.ClientID & ");" & " }")
                            'End If

                            ddlChildComplication.Sort = RadComboBoxSort.Ascending

                            If procedureComplications.AsEnumerable.Any(Function(x) CInt(x("ComplicationId")) = complicationsId And CInt(x("ChildComplicationId")) > 0) Then
                                Dim childComplicationId = (From pi In procedureComplications.AsEnumerable
                                                           Where CInt(pi("ComplicationsId")) = complicationsId
                                                           Select CInt(pi("ChildComplicationsId"))).FirstOrDefault

                                ddlChildComplication.SelectedIndex = ddlChildComplication.Items.FindItemIndexByValue(childComplicationId)
                            End If

                            'add the control to the relevant td
                            itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildComplication)


                        End If
                    End If
                Next

                'additional info/other text boxes
                If complications.AsEnumerable.Any(Function(x) x("AdditionalInfo")) Then
                    rptComplicationAdditionalInfo.DataSource = complications.AsEnumerable.Where(Function(x) x("AdditionalInfo")).CopyToDataTable
                    rptComplicationAdditionalInfo.DataBind()
                End If

                For Each itm As RepeaterItem In rptComplicationAdditionalInfo.Items
                    Dim tb As New RadTextBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is RadTextBox Then
                            tb = CType(ctrl, RadTextBox)
                        End If
                    Next

                    If tb IsNot Nothing Then
                        Dim ComplicationsId = CInt(tb.Attributes.Item("data-complicationid"))

                        tb.Text = (From si In procedureComplications Where CInt(si("ComplicationId")) = ComplicationsId
                                   Select si("AdditionalInformation")).FirstOrDefault
                    End If
                Next
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Protected Sub rptComplication_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " complication-other-entry-toggle" 'set new classname as original once casuses an autosave
                        chk.Attributes.Add("onchange", "checkAndNotifyTextEntry('" & chk.ClientID & "','complication')")
                    End If
                Next
            End If
        End If
    End Sub
End Class