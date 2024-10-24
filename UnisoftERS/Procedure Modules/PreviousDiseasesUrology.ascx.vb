Imports Telerik.Web.UI

Public Class PreviousDiseasesUrology
    Inherits ProcedureControls
    Private Shared procType As Integer
    Public Shared SectionLabelName As String
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack = True Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            Try
                bindPreviousDisease()
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading Previous diseases for binding", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading previous diseases urology")
                RadNotification1.Show()
            End Try
        End If
    End Sub

    Private Sub bindPreviousDisease()
        Try
            Dim procedurePreviousDiseaseUrology = DataAdapter.GetProcedurePreviousDiseaseUrology(Session(Constants.SESSION_PROCEDURE_ID))
            Dim procedurePreviousDiseaseUrologyRow
            Dim dbResult = DataAdapter.LoadPreviousDiseasesUrology(procType, CInt(Session(Constants.SESSION_IMAGE_GENDERID)))
            Dim previousDiseaseId
            rptSection.DataSource = From i In dbResult.AsEnumerable
                                    Select SectionId = i("SectionId"), SectionName = i("SectionName") Distinct

            rptSection.DataBind()

            For Each sectionItem As RepeaterItem In rptSection.Items

                Dim rptPreviousDiesease As Repeater = sectionItem.FindControl("rptPreviousDiesease")
                Dim sectionName = CType(sectionItem.FindControl("SectionNameLabel"), Label).Text
                SectionLabelName = CType(sectionItem.FindControl("SectionNameLabel"), Label).Text
                'If Session(Constants.SESSION_IMAGE_GENDERID) = "3" Then
                '    If UCase(sectionName) = UCase("Prostate") Or UCase(sectionName) = UCase("Prostate surgery") Or UCase(sectionName) = UCase("Testis") Then
                '        Continue For
                '    End If
                'End If
                If dbResult.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0 And Not x("AdditionalInfo")).Count() > 0 Then
                    Dim dt = dbResult.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0).CopyToDataTable
                    rptPreviousDiesease.DataSource = dt
                    rptPreviousDiesease.DataBind()

                    For Each itm As RepeaterItem In rptPreviousDiesease.Items
                        Dim chk As New CheckBox
                        For Each ctrl As Control In itm.Controls
                            If TypeOf ctrl Is CheckBox Then
                                chk = CType(ctrl, CheckBox)
                            End If
                        Next


                        previousDiseaseId = CInt(chk.Attributes("data-PreviousDiseaseId"))
                        procedurePreviousDiseaseUrologyRow = procedurePreviousDiseaseUrology.AsEnumerable.Where(Function(x As DataRow) x.Field(Of Integer)("PreviousDiseaseId") = previousDiseaseId).FirstOrDefault()
                        chk.Checked = procedurePreviousDiseaseUrology.AsEnumerable.Any(Function(x) CInt(x("PreviousDiseaseId")) = previousDiseaseId)
                        Dim ChildControlType = (From pi In dbResult.AsEnumerable
                                                Where CInt(pi("uniqueId")) = previousDiseaseId
                                                Select pi("ChildControlType")).FirstOrDefault()
                        If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = previousDiseaseId) Then
                            Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = previousDiseaseId)
                            If ChildControlType = "dropdown" Then
                                Dim ddlChildPreviousDisease As New RadComboBox
                                With ddlChildPreviousDisease
                                    .AutoPostBack = False
                                    .Skin = "Metro"
                                    .CssClass = "previousDiseaseUrology-child"
                                    .Attributes.Add("data-PreviousDiseaseId", previousDiseaseId)
                                    .OnClientSelectedIndexChanged = "childPreviousDiseaseUrology_dropdown_changed"
                                    If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                End With


                                For Each ci In childItems
                                    ddlChildPreviousDisease.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                                Next
                                ddlChildPreviousDisease.Items.Insert(0, New RadComboBoxItem("", 0))
                                If Not procedurePreviousDiseaseUrologyRow Is Nothing Then
                                    If procedurePreviousDiseaseUrology.AsEnumerable.Any(Function(x) CInt(x("PreviousDiseaseId")) = previousDiseaseId And CInt(x("ChildPreviousDiseaseId")) > 0) Then
                                        Dim ChildPreviousDiseaseId = (From pi In procedurePreviousDiseaseUrology.AsEnumerable
                                                                      Where CInt(pi("PreviousDiseaseId")) = previousDiseaseId
                                                                      Select CInt(pi("ChildPreviousDiseaseId"))).FirstOrDefault()
                                        ddlChildPreviousDisease.SelectedIndex = ddlChildPreviousDisease.Items.FindItemIndexByValue(ChildPreviousDiseaseId)
                                    End If
                                End If

                                'ctrl.Controls.AddAt(ctrl.Controls.Count, ddlChildPreviousDisease)
                                itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildPreviousDisease)
                            End If

                            If ChildControlType = "checkbox" Then


                                For Each ci In childItems

                                    Dim chkChildPreviousDisease As New CheckBox
                                    With chkChildPreviousDisease
                                        .AutoPostBack = False
                                        ' .Skin = "Metro"
                                        .CssClass = "previousDiseaseUrology-child previousDiseaseUrology-child-chkbox"
                                        .Attributes.Add("data-PreviousDiseaseId", ci("UniqueId"))
                                        .Text = ci("Description")
                                        .ID = ci("UniqueId")
                                        If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                        itm.Controls.AddAt(itm.Controls.Count - 1, chkChildPreviousDisease)
                                    End With
                                    If Not procedurePreviousDiseaseUrologyRow Is Nothing Then
                                        If procedurePreviousDiseaseUrology.AsEnumerable.Any(Function(x) CInt(x("PreviousDiseaseId")) = previousDiseaseId And CInt(x("ChildPreviousDiseaseId")) > 0) Then
                                            Dim ChildPreviousDiseaseId = (From pi In procedurePreviousDiseaseUrology.AsEnumerable
                                                                          Where CInt(pi("PreviousDiseaseId")) = previousDiseaseId
                                                                          Select CInt(pi("ChildPreviousDiseaseId"))).FirstOrDefault()
                                            chkChildPreviousDisease.Checked = If(ci("UniqueId") = ChildPreviousDiseaseId, True, False)
                                        End If
                                    End If
                                Next


                            End If

                        End If

                    Next
                End If

                If dbResult.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0 And x("AdditionalInfo")).Count() > 0 Then
                    Dim rptAdditionalInfo As Repeater = sectionItem.FindControl("rptAdditionalInfo")

                    Dim dt = dbResult.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0).CopyToDataTable
                    rptAdditionalInfo.DataSource = dt
                    rptAdditionalInfo.DataBind()
                    Dim txtBox As New RadTextBox
                    For Each itm As RepeaterItem In rptAdditionalInfo.Items
                        For Each ctrl As Control In itm.Controls
                            If TypeOf ctrl Is RadTextBox Then
                                txtBox = CType(ctrl, RadTextBox)
                            End If
                        Next

                        previousDiseaseId = CInt(txtBox.Attributes("data-PreviousDiseaseId"))
                        txtBox.Text = (From si In procedurePreviousDiseaseUrology Where CInt(si("PreviousDiseaseId")) = previousDiseaseId
                                       Select si("AdditionalInformation")).FirstOrDefault
                    Next
                End If
            Next

        Catch ex As Exception

        End Try
    End Sub

End Class