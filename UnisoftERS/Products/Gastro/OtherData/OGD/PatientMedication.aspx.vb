Imports Telerik.Web.UI

Partial Class Products_Gastro_OtherData_OGD_PatientMedication
    Inherits PageBase
    Shared RegimeText As String
    Shared windowID As Integer = 0
    Shared WhoPrescribed As String = ""
    Shared procID As Integer
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Not String.IsNullOrEmpty(Request.QueryString("title")) Then
                HeadingLabel.Text = Request.QueryString("title")
                windowID = CInt(Request.QueryString("id"))
                Select Case windowID
                    Case 1
                        WhoPrescribed = "C"
                    Case 2
                        WhoPrescribed = "H"
                    Case 3
                        WhoPrescribed = "G"
                    Case 4
                        WhoPrescribed = "S"
                End Select
                procID = CInt(Session(Constants.SESSION_PROCEDURE_ID))
                loadPrescription(procID, WhoPrescribed)
            End If
        End If
    End Sub

    Sub ShowDrugBox()
        AddDrugButton.Text = "Add this drug"
        Dim ChkDoseNotApplicable As CheckBox = TryCast(DrugDetailsFormView.FindControl("ChkDoseNotApplicable"), CheckBox)
        Dim DosageNumericBox As RadNumericTextBox = TryCast(DrugDetailsFormView.FindControl("DosageNumericBox"), RadNumericTextBox)
        Dim UnitLabel As Label = TryCast(DrugDetailsFormView.FindControl("UnitLabel"), Label)
        Dim lblDoseNotApplicable As Label = TryCast(DrugDetailsFormView.FindControl("lblDoseNotApplicable"), Label)
        If ChkDoseNotApplicable.Checked Then
            DosageNumericBox.Visible = False
            UnitLabel.Visible = False
            lblDoseNotApplicable.Visible = True
        Else
            DosageNumericBox.Visible = True
            UnitLabel.Visible = True
            lblDoseNotApplicable.Visible = False
        End If
        Dim script As String = "function f(){$find(""" + MedicationPrescribedWindow.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key1", script, True)
    End Sub

    Protected Sub DrugListBox_SelectedIndexChanged(sender As Object, e As EventArgs)
        DrugDetailsFormView.DataSource = Nothing
        PrescriptionSqlDataSource.SelectParameters("DrugNo").DefaultValue = DrugListBox.SelectedValue
        DrugDetailsFormView.DataSourceID = "PrescriptionSqlDataSource"
        'DrugDetailsFormView.DataBind()
        AddRadButton.Enabled = True
    End Sub
    Protected Sub AddtoLeft()

        Dim dosage As String = TryCast(DrugDetailsFormView.FindControl("DosageNumericBox"), RadNumericTextBox).Text
        Dim maximumDosage As String = TryCast(DrugDetailsFormView.FindControl("maximumDoseLabel"), Label).Text
        Dim drugName As String = TryCast(DrugDetailsFormView.FindControl("druglbl"), Label).Text
        Dim dosageVal As Double = 0
        If dosage.Trim <> "" Then
            dosageVal = CDbl(dosage)
        End If
        Dim maximumDosageVal As Double = 0
        If maximumDosage.Trim <> "" Then
            maximumDosageVal = CDbl(maximumDosage)
        Else
            maximumDosageVal = Integer.MaxValue
        End If
        If dosageVal > maximumDosageVal Then
            lblMessage.Text = "The maximum recommended drug dose for " + drugName + " is " + maximumDosage + ".<br> Do you want to continue?"
            MaximumDoseLimitCrossRadWindow.VisibleOnPageLoad = True
        Else
            CommonAddDrug()
        End If


    End Sub

    Protected Sub ChangeDose()
        DrugDetailsFormView.DataSourceID = Nothing
        AddDrugButton.Text = "Accept"
        Dim strVal As List(Of String) = PrescriptionList.Items(PrescriptionList.SelectedIndex).Value.Split("#").ToList
        Dim a As New List(Of Products_Gastro_OtherData_OGD_PatientMedication_Drug)
        a.Add(New Products_Gastro_OtherData_OGD_PatientMedication_Drug(strVal(7), strVal(0), strVal(1), strVal(2), strVal(3), strVal(4), strVal(5), strVal(6), 0, strVal(8)))
        DrugDetailsFormView.DataSource = a
        DrugDetailsFormView.DataBind()
        'TryCast(DrugDetailsFormView.FindControl("FrequencyDropDown"), RadComboBox).SelectedValue = strVal(4)
        TryCast(DrugDetailsFormView.FindControl("FrequencyDropDown"), RadComboBox).FindItemByText(strVal(4)).Selected = True
        TryCast(DrugDetailsFormView.FindControl("DurationDropDownList"), DropDownList).SelectedValue = strVal(5)

        Dim script As String = "function f(){$find(""" + MedicationPrescribedWindow.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key", script, True)
    End Sub

    Protected Sub openRegime()
        Dim script As String = "function f(){$find(""" + RadWindow1.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
        ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key1", script, True)
    End Sub

    Public Sub savePrescription()
        Dim ds As New DataAccess
        Dim txt As String = ""
        If PrescriptionList.Items.Count = 1 Then
            txt = txt + PrescriptionList.Items(0).Text
        ElseIf PrescriptionList.Items.Count = 2 Then
            txt = txt + PrescriptionList.Items(0).Text + " and " + PrescriptionList.Items(1).Text
        ElseIf PrescriptionList.Items.Count > 2 Then
            For i As Integer = 0 To PrescriptionList.Items.Count - 1
                If i = PrescriptionList.Items.Count - 1 Then
                    txt = txt + PrescriptionList.Items(i).Text.Trim
                Else
                    txt = txt + PrescriptionList.Items(i).Text.Trim + ", "
                End If
            Next
            txt = txt + " and " + PrescriptionList.Items(PrescriptionList.Items.Count - 1).Text
        Else
            If windowID <> 1 Then Exit Sub
        End If

        If WhoPrescribed <> Nothing Then ds.DeletePrescription(procID, WhoPrescribed)
        Dim drugCount As Integer = 1
        ' save to patient priscription table before populating the prescription box
        For Each itm As RadListBoxItem In PrescriptionList.Items
            Dim itmStr As List(Of String) = itm.Value.Split("#").ToList

            Dim summaryText = ""
            If windowID = 1 Then
                summaryText = "Continue medication " + txt.Replace(vbNewLine, "").Trim.ToLower
            ElseIf windowID = 3 Then
                summaryText = "Please be kind enough to prescribe " + txt.Replace(vbNewLine, "").Trim.ToLower
            ElseIf windowID = 2 Then
                txt = txt.Replace(vbNewLine, "")
                summaryText = "" + txt.First.ToString.ToUpper + txt.Substring(1) + " was prescribed"
            ElseIf windowID = 4 Then
                summaryText = "Suggest medication " + txt.Replace(vbNewLine, "").Trim.ToLower
            End If

            ds.SavePrescription(procID, drugCount, IIf(itmStr(7) = "", 0, itmStr(7)),
                                                   IIf(itmStr(1) = "", 0, itmStr(1)),
                                                   itmStr(4),
                                                   itmStr(5),
                                                   False, WhoPrescribed, Nothing, Nothing, summaryText)
            drugCount = drugCount + 1
        Next



        If windowID = 1 Then
            Dim PrescriptionData = "1#Continue medication " + txt.Replace(vbNewLine, "").Trim.ToLower
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "PasslistToParent('" + PrescriptionData + "');", True)
        ElseIf windowID = 3 Then
            Dim PrescriptionGPData = "3#Please be kind enough to prescribe " + txt.Replace(vbNewLine, "").Trim.ToLower
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "PasslistToParent('" + PrescriptionGPData + "');", True)
        ElseIf windowID = 2 Then
            txt = txt.Replace(vbNewLine, "")
            Dim PrescribedData = "2#" + txt.First.ToString.ToUpper + txt.Substring(1) + " was prescribed"
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "PasslistToParent('" + PrescribedData + "');", True)
        ElseIf windowID = 4 Then
            Dim SuggestPrescribeData = "4#Suggest medication " + txt.Replace(vbNewLine, "").Trim.ToLower
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "PasslistToParent('" + SuggestPrescribeData + "');", True)
        End If
        Utilities.SetNotificationStyle(RadNotification1)
        RadNotification1.Show()
    End Sub

    Protected Sub loadRegime()
        Dim ds As New DataAccess
        Dim dat As DataTable = ds.LoadRegimeData(CInt(RegimeDropDown.SelectedValue))
        If dat.Rows.Count > 0 Then
            For Each dataValue As DataRow In dat.Rows
                Dim regText As List(Of String) = dataValue("RegimeText").ToString.Split("#").ToList
                Dim txt As New StringBuilder
                txt.Append(regText(0)).AppendLine(" ")
                txt.Append(regText(1))
                txt.Append(regText(2)).AppendLine(" ")
                txt.Append(regText(3)).AppendLine(" ")
                Dim Frequency As String = regText(4)
                txt.Append(IIf(Frequency = "" Or Frequency = "(none)", "", Frequency + " "))
                Dim Duration As String = regText(5)
                txt.Append(IIf(Duration = "" Or Duration = "(unspecified duration)", "", Duration))

                Dim newItem As New RadListBoxItem
                newItem.Text = txt.ToString
                newItem.Value = dataValue("RegimeText")
                PrescriptionList.Items.Add(newItem)
            Next
        End If

    End Sub
    Protected Sub loadPrescription(prodID As Integer, WhoPrescribed As String)
        Dim ds As New DataAccess
        Dim dat As DataTable = ds.LoadPrescriptionData(prodID, WhoPrescribed)
        If dat.Rows.Count > 0 Then
            For Each dataValue As DataRow In dat.Rows
                Dim regText As List(Of String) = dataValue("text").ToString.Split("#").ToList
                Dim txt As New StringBuilder
                txt.Append(regText(0)).AppendLine(" ")
                txt.Append(regText(1))
                txt.Append(regText(2)).AppendLine(" ")
                txt.Append(regText(3)).AppendLine(" ")
                Dim Frequency As String = regText(4)
                txt.Append(IIf(Frequency = "" Or Frequency = "(none)", "", Frequency + " "))
                Dim Duration As String = regText(5)
                txt.Append(IIf(Duration = "" Or Duration = "(unspecified duration)", "", Duration))

                Dim newItem As New RadListBoxItem
                newItem.Text = txt.ToString
                newItem.Value = dataValue("text")
                PrescriptionList.Items.Add(newItem)
            Next
        End If

    End Sub

    Protected Sub mee()
        If txt1.Text <> Nothing Then
            Dim ds As New DataAccess
            If ds.GetRegime(txt1.Text) <> Nothing Then
                RegimeText = txt1.Text
                Dim script As String = "function f(){$find(""" + RadWindow2.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
                ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key1", script, True)

            Else
                Dim count As Integer = 1
                Dim regMax As Integer = ds.GetMaxReg()
                regMax = IIf(regMax = Nothing, 1, regMax + 1)
                'RegimenNo, Description, ProcedureNo, DrugNo, DrugDose, Frequency, Duration, DrugCount, RegimeText
                For Each item As RadListBoxItem In PrescriptionList.Items
                    Dim procID As Integer = CInt(Session(Constants.SESSION_PROCEDURE_ID))
                    Dim itemValue As List(Of String) = item.Value.Split("#").ToList
                    ds.SaveRegime(regMax, txt1.Text, procID, itemValue(7), itemValue(1), itemValue(4), itemValue(5), count, item.Value)
                    count = count + 1
                Next
                RegimeDropDown.DataBind()
            End If

        End If
    End Sub
    Protected Sub meee()
        Dim ds As New DataAccess
        ds.DeleteRegime(RegimeText)
        Dim count As Integer = 1
        Dim regMax As Integer = ds.GetMaxReg()
        regMax = IIf(regMax = Nothing, 1, regMax + 1)
        'RegimenNo, Description, ProcedureNo, DrugNo, DrugDose, Frequency, Duration, DrugCount, RegimeText
        For Each item As RadListBoxItem In PrescriptionList.Items
            Dim procID As Integer = CInt(Session(Constants.SESSION_PROCEDURE_ID))
            Dim itemValue As List(Of String) = item.Value.Split("#").ToList
            ds.SaveRegime(regMax, RegimeText, procID, itemValue(7), itemValue(1), itemValue(4), itemValue(5), count, item.Value)
            count = count + 1
        Next
        RegimeDropDown.DataBind()
        Utilities.SetNotificationStyle(RadNotification1)
        RadNotification1.Show()
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        DrugListBox.DataBind()

        'If e.Argument = "Rebind" Then
        '    DrugsRadGrid.MasterTableView.SortExpressions.Clear()
        '    DrugsRadGrid.Rebind()
        'ElseIf e.Argument = "RebindAndNavigate" Then
        '    DrugsRadGrid.MasterTableView.SortExpressions.Clear()
        '    DrugsRadGrid.MasterTableView.CurrentPageIndex = DrugsRadGrid.MasterTableView.PageCount - 1
        '    DrugsRadGrid.Rebind()
        'End If
    End Sub

    Private Sub DrugDetailsFormView_DataBound(sender As Object, e As EventArgs) Handles DrugDetailsFormView.DataBound
        Dim FrequencyDropDown As RadComboBox = DirectCast(DrugDetailsFormView.FindControl("FrequencyDropDown"), RadComboBox)
        If FrequencyDropDown IsNot Nothing Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{FrequencyDropDown, ""}}, DataAdapter.GetMedicationFrequency(), "ListItemText", "ListItemText")
            'Utilities.LoadDropdown(FrequencyDropDown, DataAdapter.GetMedicationFrequency(), "ListItemText", "ListItemText")
        End If

        'Dim DurationDropDownList As RadComboBox = DirectCast(DrugDetailsFormView.FindControl("DurationDropDownList"), RadComboBox)
        'If DurationDropDownList IsNot Nothing Then
        '    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{DurationDropDownList, ""}}, DataAdapter.GetMedicationFrequency(), "ListItemText", "ListItemText")
        'End If
    End Sub

    Protected Sub ContinueRadButton_Click(sender As Object, e As EventArgs)
        CommonAddDrug()
    End Sub

    Private Sub CommonAddDrug()
        Dim txt As New StringBuilder
        txt.Append(TryCast(DrugDetailsFormView.FindControl("druglbl"), Label).Text).AppendLine(" ")
        txt.Append(TryCast(DrugDetailsFormView.FindControl("DosageNumericBox"), RadNumericTextBox).Text)
        txt.Append(TryCast(DrugDetailsFormView.FindControl("UnitLabel"), Label).Text).AppendLine(" ")
        txt.Append(TryCast(DrugDetailsFormView.FindControl("DeliveryMethodLabel"), Label).Text).AppendLine(" ")
        Dim Frequency As String = TryCast(DrugDetailsFormView.FindControl("FrequencyDropDown"), RadComboBox).SelectedItem.Text
        txt.Append(IIf(Frequency = "" Or Frequency = "(none)", "", Frequency + " "))
        Dim Duration As String = TryCast(DrugDetailsFormView.FindControl("DurationDropDownList"), DropDownList).SelectedValue
        txt.Append(IIf(Duration = "" Or Duration = "(unspecified duration)", "", Duration))

        If AddDrugButton.Text <> "Accept" Then  ' don't forgrt to remove selected index and use real value in frequency
            Dim newItem As New RadListBoxItem
            newItem.Text = txt.ToString
            newItem.Value = TryCast(DrugDetailsFormView.FindControl("druglbl"), Label).Text + "#" + TryCast(DrugDetailsFormView.FindControl("DosageNumericBox"), RadNumericTextBox).Text + "#" + TryCast(DrugDetailsFormView.FindControl("UnitLabel"), Label).Text + "#" + TryCast(DrugDetailsFormView.FindControl("DeliveryMethodLabel"), Label).Text + "#" + TryCast(DrugDetailsFormView.FindControl("FrequencyDropDown"), RadComboBox).SelectedItem.Text + "#" + TryCast(DrugDetailsFormView.FindControl("DurationDropDownList"), DropDownList).SelectedValue + "#" + TryCast(DrugDetailsFormView.FindControl("incrementLabel"), Label).Text + "#" + TryCast(DrugDetailsFormView.FindControl("DrugNoHidden"), Label).Text
            PrescriptionList.Items.Add(newItem)
        Else
            PrescriptionList.Items(PrescriptionList.SelectedIndex).Text = txt.ToString
            PrescriptionList.Items(PrescriptionList.SelectedIndex).Value = TryCast(DrugDetailsFormView.FindControl("druglbl"), Label).Text + "#" + TryCast(DrugDetailsFormView.FindControl("DosageNumericBox"), RadNumericTextBox).Text + "#" + TryCast(DrugDetailsFormView.FindControl("UnitLabel"), Label).Text + "#" + TryCast(DrugDetailsFormView.FindControl("DeliveryMethodLabel"), Label).Text + "#" + TryCast(DrugDetailsFormView.FindControl("FrequencyDropDown"), RadComboBox).SelectedItem.Text + "#" + TryCast(DrugDetailsFormView.FindControl("DurationDropDownList"), DropDownList).SelectedValue + "#" + TryCast(DrugDetailsFormView.FindControl("incrementLabel"), Label).Text + "#" + TryCast(DrugDetailsFormView.FindControl("DrugNoHidden"), Label).Text
            PrescriptionList.Items(PrescriptionList.SelectedIndex).Selected = False
        End If
        MaximumDoseLimitCrossRadWindow.VisibleOnPageLoad = False
    End Sub
End Class

Public Class Products_Gastro_OtherData_OGD_PatientMedication_Drug
    Public Sub New()
    End Sub
    Public Sub New(_drugno As Integer, _name As String, _dosage As String, _units As String, _delivery As String, _frequency As String, _duration As String, _increment As String, _doseNotApplicable As Integer, _maximumDose As String)
        DrugNo = _drugno
        Name = _name
        Dosage = _dosage
        Units = _units
        Method = _delivery
        Frequency = _frequency
        Duration = _duration
        Increment = _increment
        DoseNotApplicable = _doseNotApplicable
        MaximumDose = _maximumDose
    End Sub
    Public Class Products_Gastro_OtherData_OGD_PatientMedication_DrugList
        Inherits List(Of Products_Gastro_OtherData_OGD_PatientMedication_Drug)
    End Class
    Public Property DrugNo As Integer
    Public Property Name As String
    Public Property Dosage As String
    Public Property Units As String
    Public Property Method As String
    Public Property Frequency As String
    Public Property Duration As String
    Public Property Increment As String
    Public Property MaximumDose As String
    Public Property DoseNotApplicable As Integer

End Class