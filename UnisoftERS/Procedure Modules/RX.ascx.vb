Imports Telerik.Web.UI

Public Class RX
    Inherits ProcedureControls


    Protected Property ContinueData() As String
        Get
            Return CStr(ViewState("ContinueData"))
        End Get
        Set(ByVal value As String)
            ViewState("ContinueData") = value
        End Set
    End Property

    Protected Property HospitalData() As String
        Get
            Return CStr(ViewState("HospitalData"))
        End Get
        Set(ByVal value As String)
            ViewState("HospitalData") = value
        End Set
    End Property

    Protected Property GPData() As String
        Get
            Return CStr(ViewState("GPData"))
        End Get
        Set(ByVal value As String)
            ViewState("GPData") = value
        End Set
    End Property

    Protected Property SuggestedData() As String
        Get
            Return CStr(ViewState("SuggestedData"))
        End Get
        Set(ByVal value As String)
            ViewState("SuggestedData") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            'SaveButton.Text = IIf(Session("AdvancedMode") = True, "Save Record", "Save & Close")
            Dim da As New OtherData
            Dim dtRx As DataTable = da.GetUpperGIRx(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtRx.Rows.Count > 0 Then
                PopulateData(dtRx.Rows(0))
            End If
            Dim procID = CInt(Session(Constants.SESSION_PROCEDURE_ID))
            loadPrescription(procID, "C")
            loadPrescription(procID, "G")
            loadPrescription(procID, "H")
            loadPrescription(procID, "S")
        End If
    End Sub

    Private Sub PopulateData(dtRx As DataRow)
        If CBool(dtRx("ContMedication")) Then
            ModifyMedicationRadButton.Attributes.Add("style", "display:normal")
            ContMedication.Checked = True
        Else
            ModifyMedicationRadButton.Attributes.Add("style", "display:none")
            ContMedication.Checked = False
        End If
        If CBool(dtRx("ContMedicationByGP")) Then
            ModifyGPMedicationRadButton.Attributes.Add("style", "display:normal")
            ContMedicationByGP.Checked = True
        Else
            ModifyGPMedicationRadButton.Attributes.Add("style", "display:none")
            ContMedicationByGP.Checked = False
        End If
        If CBool(dtRx("ContPrescribeMedication")) Then
            ModifyPrescribeMedicationRadButton.Attributes.Add("style", "display:normal")
            ContPrescribeMedication.Checked = True
        Else
            ModifyPrescribeMedicationRadButton.Attributes.Add("style", "display:none")
            ContPrescribeMedication.Checked = False
        End If
        If CBool(dtRx("SuggestPrescribe")) Then
            ModifySuggestMedicationRadButton.Attributes.Add("style", "display:normal")
            SuggestPrescribe.Checked = True
        Else
            ModifySuggestMedicationRadButton.Attributes.Add("style", "display:none")
            SuggestPrescribe.Checked = False
        End If
        MedicationText.Text = Server.HtmlDecode(CStr(dtRx("Summary"))).ToString.Replace("<br />", Environment.NewLine)

    End Sub

    Protected Sub prescriptionSaved(prodID As Integer, WhoPrescribed As String)
        Dim ds As New DataAccess
        Dim dat As DataTable = ds.LoadPrescriptionData(prodID, WhoPrescribed)
        If Not IsNothing(dat) Then
            Dim strResult As New List(Of String)
            For Each dataValue As DataRow In dat.Rows
                Dim regText As List(Of String) = dataValue("text").ToString.Split("#").ToList
                Dim txts As New StringBuilder
                txts.Append(regText(0)).AppendLine(" ")
                txts.Append(regText(1))
                txts.Append(regText(2)).AppendLine(" ")
                txts.Append(regText(3)).AppendLine(" ")
                Dim Frequency As String = regText(4)
                txts.Append(IIf(Frequency = "" Or Frequency = "(none)", "", Frequency + " "))
                Dim Duration As String = regText(5)
                txts.Append(IIf(Duration = "" Or Duration = "(unspecified duration)", "", Duration))
                strResult.Add(txts.ToString.Replace(vbNewLine, ""))
            Next

            Dim txt As String = ""
            If strResult.Count = 1 Then
                txt = txt + strResult(0)
            ElseIf strResult.Count = 2 Then
                txt = txt + strResult(0) + " and " + strResult(1)
            ElseIf strResult.Count > 2 Then
                For i As Integer = 0 To strResult.Count - 1
                    If i = strResult.Count - 1 Then
                        txt = txt + strResult(i).Trim
                    Else
                        txt = txt + strResult(i).Trim + ", "
                    End If
                Next
                txt = txt + " and " + strResult(strResult.Count - 1)
            Else
                If WhoPrescribed <> "C" Then Exit Sub
            End If

            Dim param = ""
            If WhoPrescribed = "C" Then
                param = "1#Continue medication " + txt.Replace(vbNewLine, "").Trim
            ElseIf WhoPrescribed = "H" Then
                param = "2#Please be kind enough to prescribe " + txt.Replace(vbNewLine, "").Trim
            ElseIf WhoPrescribed = "G" Then
                param = "3#" + txt.Replace(vbNewLine, "").Trim + " was prescribed"
            ElseIf WhoPrescribed = "S" Then
                param = "4#Suggest medication " + txt.Replace(vbNewLine, "").Trim
            End If

            ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "CalledFn('" + param + "');", True)

        End If
    End Sub

    Protected Sub loadPrescription(prodID As Integer, WhoPrescribed As String)
        Dim ds As New DataAccess
        Dim dat As DataTable = ds.LoadPrescriptionData(prodID, WhoPrescribed)
        If Not IsNothing(dat) Then
            Dim strResult As New List(Of String)
            For Each dataValue As DataRow In dat.Rows
                Dim regText As List(Of String) = dataValue("text").ToString.Split("#").ToList
                Dim txts As New StringBuilder
                txts.Append(regText(0)).AppendLine(" ")
                txts.Append(regText(1))
                txts.Append(regText(2)).AppendLine(" ")
                txts.Append(regText(3)).AppendLine(" ")
                Dim Frequency As String = regText(4)
                txts.Append(IIf(Frequency = "" Or Frequency = "(none)", "", Frequency + " "))
                Dim Duration As String = regText(5)
                txts.Append(IIf(Duration = "" Or Duration = "(unspecified duration)", "", Duration))
                Dim MaximumDose As String = regText(8)
                txts.Append(IIf(MaximumDose = "0", Integer.MaxValue.ToString, MaximumDose))
                strResult.Add(txts.ToString.Replace(vbNewLine, ""))
            Next

            Dim txt As String = ""
            If strResult.Count = 1 Then
                txt = txt + strResult(0)
            ElseIf strResult.Count = 2 Then
                txt = txt + strResult(0) + " and " + strResult(1)
            ElseIf strResult.Count > 2 Then
                For i As Integer = 0 To strResult.Count - 1
                    If i = strResult.Count - 1 Then
                        txt = txt + strResult(i).Trim
                    Else
                        txt = txt + strResult(i).Trim + ", "
                    End If
                Next
                txt = txt + " and " + strResult(strResult.Count - 1)
            Else
                If WhoPrescribed <> "C" Then Exit Sub
            End If

            If WhoPrescribed = "C" Then
                ContinueData = "1#Continue medication " + txt.Replace(vbNewLine, "").Trim
            ElseIf WhoPrescribed = "H" Then
                HospitalData = "2#Please be kind enough to prescribe " + txt.Replace(vbNewLine, "").Trim
            ElseIf WhoPrescribed = "G" Then
                GPData = "3#" + txt.Replace(vbNewLine, "").Trim + " was prescribed"
            ElseIf WhoPrescribed = "S" Then
                SuggestedData = "4#Suggest medication " + txt.Replace(vbNewLine, "").Trim
            End If
        End If
    End Sub

    Private Sub SaveRecord(isSaveAndClose As Boolean)
        Dim da As New OtherData

        Try
            da.SaveUpperGIRx(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                   ContMedication.Checked,
                                   ContMedicationByGP.Checked,
                                   ContPrescribeMedication.Checked,
                                   SuggestPrescribe.Checked,
                                   Server.HtmlEncode(MedicationText.Text),
                                   isSaveAndClose)

            If isSaveAndClose Then
                ExitForm()
            End If


        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Rx.", ex)

        End Try
    End Sub



    Protected Sub SaveData()
        SaveRecord(True)
    End Sub

    Protected Sub CancelSave()
        ExitForm()
    End Sub

    Sub ExitForm()
        Response.Redirect("~/Products/PatientProcedure.aspx", False)
    End Sub
End Class