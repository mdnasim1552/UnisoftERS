Imports Telerik.Web.UI

Public Class PlannedProcedures
    Inherits System.Web.UI.UserControl

    Private Shared procType As Integer
    Private _dataAdapter As DataAccess = Nothing

    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataAdapter Is Nothing Then
                _dataAdapter = New DataAccess
            End If
            Return _dataAdapter
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            Try
                bindPlannedProcedures()
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading planned procedures for binding", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading planned procedures")
                RadNotification1.Show()
            End Try
        End If
    End Sub

    Protected Sub rptPlannedProcedures_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        Try
            If e.Item.DataItem Is Nothing Then Exit Sub
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " planned-procedure-other-entry-toggle" 'set new classname as original once casuses an autosave
                        chk.Attributes.Add("onchange", "checkAndNotifyTextEntry('" & chk.ClientID & "','planned-procedure')")
                    End If
                Next
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in rptPlannedProcedures_ItemDataBound", ex)
        End Try
    End Sub

    Private Sub bindPlannedProcedures()
        Try
            'databing repeater
            Dim dbResult = DataAdapter.LoadPlannedProcedures(procType)
            Dim plannedProcedures = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = 0)

            rptPlannedProcedures.DataSource = plannedProcedures.CopyToDataTable '.AsEnumerable.Where(Function(x) Not x("AdditionalInfo")).CopyToDataTable
            rptPlannedProcedures.DataBind()

            'load procedure indications
            Dim procedureIndications = DataAdapter.GetProcedureIndications(Session(Constants.SESSION_PROCEDURE_ID))

            For Each itm As RepeaterItem In rptPlannedProcedures.Items
                Dim chk As New CheckBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                    End If
                Next

                If chk IsNot Nothing Then
                    Dim indicationsId = CInt(chk.Attributes.Item("data-plannedid"))

                    chk.Checked = procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId)

                    'get the checkbox- dataitem as nothing so cant get the values in that way :(
                    If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = indicationsId) Then
                        Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = indicationsId)

                        'check that none of the child items ids are parent ids of anything else


                        'create a dropdown list and bind child items to it
                        Dim ddlChildIndications As New RadComboBox
                        With ddlChildIndications
                            .AutoPostBack = False
                            .Skin = "Metro"
                            .CssClass = "planned-procedure-child"
                            .Attributes.Add("data-plannedid", indicationsId)
                            .OnClientSelectedIndexChanged = "childPlannedProcedure_changed"
                            If Not chk.Checked Then .Style.Add("display", "none")
                        End With


                        For Each ci In childItems
                            ddlChildIndications.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                        Next
                        ddlChildIndications.Items.Insert(0, New RadComboBoxItem("", 0))

                        If True Then
                            ddlChildIndications.Items.Add(New RadComboBoxItem() With {
                            .Text = "Add new",
                            .Value = -55,
                            .ImageUrl = "~/images/icons/add.png",
                            .CssClass = "comboNewItem"
                            })
                            ddlChildIndications.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & ddlChildIndications.ClientID & "); } else { window.parent.AddNewItemPopUp(" & ddlChildIndications.ClientID & ");" & " }")
                        End If

                        ddlChildIndications.Sort = RadComboBoxSort.Ascending

                        If procedureIndications.AsEnumerable.Any(Function(x) CInt(x("IndicationId")) = indicationsId And CInt(x("ChildIndicationId")) > 0) Then
                            Dim childIndicationId = (From pi In procedureIndications.AsEnumerable
                                                     Where CInt(pi("IndicationId")) = indicationsId
                                                     Select CInt(pi("ChildIndicationId"))).FirstOrDefault

                            ddlChildIndications.SelectedIndex = ddlChildIndications.Items.FindItemIndexByValue(childIndicationId)
                        End If

                        'add the control to the relevant td
                        itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildIndications)


                    End If
                End If
            Next

            'additional info/other text boxes
            If plannedProcedures.AsEnumerable.Any(Function(x) x("AdditionalInfo")) Then
                rptAdditionalInfo.DataSource = plannedProcedures.AsEnumerable.Where(Function(x) x("AdditionalInfo")).CopyToDataTable
                rptAdditionalInfo.DataBind()
            End If

            For Each itm As RepeaterItem In rptAdditionalInfo.Items
                Dim tb As New RadTextBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is RadTextBox Then
                        tb = CType(ctrl, RadTextBox)
                    End If
                Next

                If tb IsNot Nothing Then
                    Dim indicationsId = CInt(tb.Attributes.Item("data-plannedid"))

                    tb.Text = (From si In procedureIndications Where CInt(si("IndicationId")) = indicationsId
                               Select si("AdditionalInformation")).FirstOrDefault
                End If
            Next
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

End Class