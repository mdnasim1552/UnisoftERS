Imports DevExpress.XtraRichEdit.Model
Imports Telerik.Web.UI

Public Class CoMorbidity
    Inherits ProcedureControls

    Private Shared procType As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = Session(Constants.SESSION_PROCEDURE_TYPE)

            If String.IsNullOrEmpty(procType) Then
                procType = Session(Constants.SESSION_PROCEDURE_TYPES)
            End If
            If procType Is Nothing Then
                procType = "0"
            End If

            Try
                bindData()
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading Co-Morbidities for binding", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading comorbidity")
                RadNotification1.Show()
            End Try
        ElseIf Not String.IsNullOrEmpty(Session(Constants.SESSION_PROCEDURE_TYPES)) Then

            procType = Session(Constants.SESSION_PROCEDURE_TYPES)

            If procType Is Nothing Then
                procType = "0"
            End If

            Try
                bindData()
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading Co-Morbidities for binding", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading comorbidity")
                RadNotification1.Show()
            End Try

        End If

    End Sub

    Private Sub bindData()
        Try
            'databing repeater
            Dim dbResult = DataAdapter.LoadComorbidities(procType)

            If dbResult.Rows.Count > 0 Then
                ComorbidityHeader.Visible = True

                ' Colummn wise Checkbox sorting part
                Dim comorbidities = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = 0)
                Dim filteredDataTable = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = 0).CopyToDataTable()

                Dim resultDataTable As DataTable = DataHelper.GetColumnWiseSortedTable(filteredDataTable)

                rptComorbidity.DataSource = resultDataTable
                rptComorbidity.DataBind()
                ' Colummn wise Checkbox sorting part

                'load procedure Comorbidity
                Dim procedureComorbidity = DataAdapter.GetProcedureComorbidity(Session(Constants.SESSION_PROCEDURE_ID), CInt(Session(Constants.SESSION_PRE_ASSESSMENT_Id)))

                For Each itm As RepeaterItem In rptComorbidity.Items
                    Dim chk As New CheckBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is CheckBox Then
                            chk = CType(ctrl, CheckBox)
                        End If
                    Next

                    If chk IsNot Nothing Then
                        If chk.Text.ToLower = "none" Then
                            chk.CssClass = chk.CssClass + " comorbidity-none"
                        End If

                        Dim comorbId = CInt(chk.Attributes.Item("data-comorbid"))

                        chk.Checked = procedureComorbidity.AsEnumerable.Any(Function(x) CInt(x("ComorbidityId")) = comorbId)

                        'get the checkbox- dataitem as nothing so cant get the values in that way :(
                        If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = comorbId) Then
                            Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = comorbId)

                            'check that none of the child items ids are parent ids of anything else


                            'create a dropdown list and bind child items to it
                            Dim ddlChildComorbidity As New RadComboBox
                            With ddlChildComorbidity
                                .AutoPostBack = False
                                .Skin = "Metro"
                                .CssClass = "comorb-child"
                                .Attributes.Add("data-comorbid", comorbId)
                                .OnClientSelectedIndexChanged = "childComorb_changed"
                                If Not chk.Checked Then .Style.Add("display", "none")
                            End With


                            For Each ci In childItems
                                ddlChildComorbidity.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                            Next
                            ddlChildComorbidity.Items.Insert(0, New RadComboBoxItem("", 0))

                            'If True Then
                            '    ddlChildComorbidity.Items.Add(New RadComboBoxItem() With {
                            '    .Text = "Add new",
                            '    .Value = -55,
                            '    .ImageUrl = "~/images/icons/add.png",
                            '    .CssClass = "comboNewItem"
                            '    })
                            '    ddlChildComorbidity.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & ddlChildComorbidity.ClientID & "); } else { window.parent.AddNewItemPopUp(" & ddlChildComorbidity.ClientID & ");" & " }")
                            'End If

                            ddlChildComorbidity.Sort = RadComboBoxSort.Ascending

                            If procedureComorbidity.AsEnumerable.Any(Function(x) CInt(x("ComorbidityId")) = comorbId And CInt(x("ChildComorbidityId")) > 0) Then
                                Dim childComorbidityId = (From pi In procedureComorbidity.AsEnumerable
                                                          Where CInt(pi("ComorbidityId")) = comorbId
                                                          Select CInt(pi("ChildComorbidityId"))).FirstOrDefault
                                ddlChildComorbidity.SelectedIndex = ddlChildComorbidity.Items.FindItemIndexByValue(childComorbidityId)
                            End If
                            'add the control to the relevant td
                            itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildComorbidity)


                        End If
                    End If
                Next

                'additional info/other text boxes
                If comorbidities.AsEnumerable.Any(Function(x) x("AdditionalInfo")) Then
                    rptComorbidityAdditionalInfo.DataSource = comorbidities.AsEnumerable.Where(Function(x) x("AdditionalInfo")).CopyToDataTable
                    rptComorbidityAdditionalInfo.DataBind()
                End If

                For Each itm As RepeaterItem In rptComorbidityAdditionalInfo.Items
                    Dim tb As New RadTextBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is RadTextBox Then
                            tb = CType(ctrl, RadTextBox)
                        End If
                    Next

                    If tb IsNot Nothing Then
                        Dim ComorbidityId = CInt(tb.Attributes.Item("data-comorbid"))

                        tb.Text = (From si In procedureComorbidity Where CInt(si("ComorbidityId")) = ComorbidityId
                                   Select si("AdditionalInformation")).FirstOrDefault

                    End If
                Next
            Else
                ComorbidityHeader.Visible = False
            End If

        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Protected Sub rptComorbidity_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            'Other textbox
            If CType(CType(e.Item.DataItem, DataRowView).Row("AdditionalInfo"), Boolean) = True Then
                Dim chk As New CheckBox

                For Each ctrl As Control In e.Item.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                        chk.CssClass += " comorbidity-other-entry-toggle" 'set new classname as original once casuses an autosave
                        chk.Attributes.Add("onchange", "checkAndNotifyTextEntrys('" & chk.ClientID & "','comorbidity')")
                    End If
                Next
            End If
        End If
    End Sub
End Class