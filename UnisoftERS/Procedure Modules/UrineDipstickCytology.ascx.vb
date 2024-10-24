Imports Telerik.Web
Imports Telerik.Web.UI

Public Class UrineDipstickCytology
    Inherits ProcedureControls
    Private Shared procType As Integer
    Public Shared SectionLabelName As String
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack = True Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            Try
                bindUrineDipstickCytology()
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading Urine Dipstick Cytology for binding", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading urine dipstick cytology")
                RadNotification1.Show()
            End Try
        End If
    End Sub
    Private Sub bindUrineDipstickCytology()
        Try
            Dim procedureUrineDipstickCytology = DataAdapter.GetProcedureUrineDipstickCytology(Session(Constants.SESSION_PROCEDURE_ID))
            Dim procedureUrineDipstickCytologyRow
            Dim dbResult = DataAdapter.LoadUrineDipstickCytology(procType)
            Dim UrineDipstickCytologyId
            rptSection.DataSource = From i In dbResult.AsEnumerable
                                    Select SectionId = i("SectionId"), SectionName = i("SectionName") Distinct

            rptSection.DataBind()

            For Each sectionItem As RepeaterItem In rptSection.Items
                Dim rptUrineDipstick As Repeater = sectionItem.FindControl("rptUrineDipstick")
                Dim sectionName = CType(sectionItem.FindControl("SectionNameLabel"), Label).Text
                SectionLabelName = CType(sectionItem.FindControl("SectionNameLabel"), Label).Text
                If dbResult.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0 And x("SectionId") = 1).Count > 0 Then
                    Dim dt = dbResult.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0 And x("SectionId") = 1).CopyToDataTable
                    rptUrineDipstick.DataSource = dt
                    rptUrineDipstick.DataBind()

                    For Each itm As RepeaterItem In rptUrineDipstick.Items
                        Dim chk As New CheckBox
                        For Each ctrl As Control In itm.Controls
                            If TypeOf ctrl Is CheckBox Then
                                chk = CType(ctrl, CheckBox)
                            End If
                        Next


                        UrineDipstickCytologyId = CInt(chk.Attributes("data-UrineDipstickCytologyId"))
                        procedureUrineDipstickCytologyRow = procedureUrineDipstickCytology.AsEnumerable.Where(Function(x As DataRow) x.Field(Of Integer)("UrineDipstickCytologyId") = UrineDipstickCytologyId).FirstOrDefault()
                        chk.Checked = procedureUrineDipstickCytology.AsEnumerable.Any(Function(x) CInt(x("UrineDipstickCytologyId")) = UrineDipstickCytologyId)
                        Dim ChildControlType = (From pi In dbResult.AsEnumerable
                                                Where CInt(pi("uniqueId")) = UrineDipstickCytologyId
                                                Select pi("ChildControlType")).FirstOrDefault()
                        If dbResult.AsEnumerable.Any(Function(x) x("ParentId") = UrineDipstickCytologyId) Then
                            Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = UrineDipstickCytologyId)
                            If ChildControlType = "dropdown" Then

                                Dim ddlChildUrineDipstickCytology As New RadComboBox
                                For Each ctrl As Control In itm.Controls
                                    If TypeOf ctrl Is RadComboBox Then
                                        ddlChildUrineDipstickCytology = CType(ctrl, RadComboBox)
                                    End If
                                Next
                                With ddlChildUrineDipstickCytology
                                    .AutoPostBack = False
                                    .Skin = "Metro"
                                    .CssClass = "UrineDipstickCytology-child"
                                    .Attributes.Add("data-UrineDipstickCytologyId", UrineDipstickCytologyId)
                                    .OnClientSelectedIndexChanged = "childUrineDipstickCytology_dropdown_changed"
                                    If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                                End With


                                For Each ci In childItems
                                    ddlChildUrineDipstickCytology.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                                Next
                                ' ddlChildUrineDipstickCytology.Items.Insert(0, New RadComboBoxItem("", 0))
                                If Not procedureUrineDipstickCytologyRow Is Nothing Then
                                    If procedureUrineDipstickCytology.AsEnumerable.Any(Function(x) CInt(x("UrineDipstickCytologyId")) = UrineDipstickCytologyId And CInt(x("ChildUrineDipstickCytologyId")) > 0) Then
                                        Dim ChildUrineDipstickCytologyId = (From pi In procedureUrineDipstickCytology.AsEnumerable
                                                                            Where CInt(pi("UrineDipstickCytologyId")) = UrineDipstickCytologyId
                                                                            Select CInt(pi("ChildUrineDipstickCytologyId"))).FirstOrDefault()
                                        ddlChildUrineDipstickCytology.SelectedIndex = ddlChildUrineDipstickCytology.Items.FindItemIndexByValue(ChildUrineDipstickCytologyId)
                                    End If
                                End If

                                'ctrl.Controls.AddAt(ctrl.Controls.Count, ddlChildUrineDipstickCytology)

                                '  itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildUrineDipstickCytology)
                            End If


                        End If

                    Next
                End If

                If dbResult.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0 And x("SectionId") = 2).Count() > 0 Then
                    Dim rptAdditionalInfo As Repeater = sectionItem.FindControl("rptUrineCytology")

                    Dim dt = dbResult.AsEnumerable.Where(Function(x) x("SectionName") = sectionName And x("ParentId") = 0 And x("SectionId") = 2).CopyToDataTable
                    rptAdditionalInfo.DataSource = dt
                    rptAdditionalInfo.DataBind()

                    For Each itm As RepeaterItem In rptAdditionalInfo.Items
                        For Each ctrl As Control In itm.Controls
                            If ctrl.Visible = True Then

                                If TypeOf ctrl Is RadDatePicker Then
                                    Dim txtBox As New RadDatePicker
                                    txtBox = CType(ctrl, RadDatePicker)
                                    UrineDipstickCytologyId = CInt(txtBox.Attributes("data-UrineDipstickCytologyId"))
                                    txtBox.SelectedDate = (From si In procedureUrineDipstickCytology Where CInt(si("UrineDipstickCytologyId")) = UrineDipstickCytologyId
                                                           Select si("DateSent")).FirstOrDefault
                                End If
                                If TypeOf ctrl Is RadComboBox Then
                                    Dim ddlChildUrineDipstickCytology As New RadComboBox
                                    ddlChildUrineDipstickCytology = CType(ctrl, RadComboBox)
                                    UrineDipstickCytologyId = CInt(ddlChildUrineDipstickCytology.Attributes("data-UrineDipstickCytologyId"))
                                    Dim childItems = dbResult.AsEnumerable.Where(Function(x) x("ParentId") = UrineDipstickCytologyId)
                                    For Each ci In childItems
                                        ddlChildUrineDipstickCytology.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                                    Next
                                    ddlChildUrineDipstickCytology.OnClientSelectedIndexChanged = "childUrineDipstickCytology_dropdown_changed"
                                    procedureUrineDipstickCytologyRow = procedureUrineDipstickCytology.AsEnumerable.Where(Function(x As DataRow) x.Field(Of Integer)("UrineDipstickCytologyId") = UrineDipstickCytologyId).FirstOrDefault()
                                    If Not procedureUrineDipstickCytologyRow Is Nothing Then
                                        If procedureUrineDipstickCytology.AsEnumerable.Any(Function(x) CInt(x("UrineDipstickCytologyId")) = UrineDipstickCytologyId And CInt(x("ChildUrineDipstickCytologyId")) > 0) Then
                                            Dim ChildUrineDipstickCytologyId = (From pi In procedureUrineDipstickCytology.AsEnumerable
                                                                                Where CInt(pi("UrineDipstickCytologyId")) = UrineDipstickCytologyId
                                                                                Select CInt(pi("ChildUrineDipstickCytologyId"))).FirstOrDefault()
                                            ddlChildUrineDipstickCytology.SelectedIndex = ddlChildUrineDipstickCytology.Items.FindItemIndexByValue(ChildUrineDipstickCytologyId)
                                        End If
                                    End If
                                End If
                            End If
                        Next


                    Next
                End If
            Next

        Catch ex As Exception

        End Try
    End Sub
End Class