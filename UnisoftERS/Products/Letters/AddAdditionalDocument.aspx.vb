Imports System.IO
Imports Telerik.Web.UI

Public Class AddAdditionalDocument
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim AdditionalDocumentId = Request.QueryString("AdditionalDocumentId")
            If Not (AdditionalDocumentId = Nothing) Then
                Dim da As New LetterGeneration()
                Dim datatable = da.GetAdditionalDocumentFoId(CType(AdditionalDocumentId, Long))
                PopulateProcedureDropDownList(CType(datatable.Rows(0)("ProcedureTypeId").ToString(), Long))
                PopulateHospitalDropDownList(CType(datatable.Rows(0)("OperationalHospitalId").ToString(), Long))
                DocumentName.Text = datatable.Rows(0)("DocumentName").ToString()
                PopulateCombindProcedureDropDownList(CType(datatable.Rows(0)("CombindProcedureTypeId").ToString(), Long))
                hdnAdditionalDocumentId.Value = AdditionalDocumentId
                Dim TherapeuticTypeId As Long = 0
                If Not datatable.Rows(0)("TherapeuticTypeId").ToString() = Nothing Then
                    TherapeuticTypeId = CType(datatable.Rows(0)("TherapeuticTypeId").ToString(), Long)
                End If
                PopulateTherapeuticTypeDropDownList(TherapeuticTypeId)
            Else


                Try
                    PopulateHospitalDropDownList()
                    PopulateProcedureDropDownList()
                    PopulateCombindProcedureDropDownList()
                    PopulateTherapeuticTypeDropDownList()

                    Dim RadUploadTempDirectory = Server.MapPath("~/App_Data") + "\WorkDirectory\RadUploadTemp\"
                    If Not Directory.Exists(RadUploadTempDirectory) Then
                        Directory.CreateDirectory(RadUploadTempDirectory)
                    End If
                Catch ex As Exception
                    Dim errorLogRef As String
                    errorLogRef = LogManager.LogManagerInstance.LogError("Error occured During loading the page.", ex)
                    Utilities.SetErrorNotificationStyle(LetterPrintRadNotification, errorLogRef, "Error During page load.")
                    LetterPrintRadNotification.Show()
                End Try

            End If
        End If
    End Sub

    Private Sub PopulateCombindProcedureDropDownList(Optional CombindProcedureTypeId As Long? = Nothing)
        Dim da As New LetterGeneration()
        CombindProcedureNameDropdown.Items.Clear()
        CombindProcedureNameDropdown.Items.Insert(0, New DropDownListItem(" ", 0))
        CombindProcedureNameDropdown.AppendDataBoundItems = True
        CombindProcedureNameDropdown.DataSource = da.GetProcedures()
        CombindProcedureNameDropdown.DataBind()
        If Not (CombindProcedureTypeId = 0) Then
            CombindProcedureNameDropdown.SelectedValue = CombindProcedureTypeId
        End If
    End Sub
    Private Sub PopulateProcedureDropDownList(Optional ProcedureTypeId As Long? = Nothing)
        Dim da As New LetterGeneration()
        ProcedureNameDropdown.Items.Clear()
        ProcedureNameDropdown.Items.Insert(0, New DropDownListItem(" ", 0))
        ProcedureNameDropdown.AppendDataBoundItems = True
        ProcedureNameDropdown.DataSource = da.GetProcedures()
        ProcedureNameDropdown.DataBind()
        If Not (ProcedureTypeId = 0) Then
            ProcedureNameDropdown.SelectedValue = ProcedureTypeId
        End If
    End Sub
    Private Sub PopulateHospitalDropDownList(Optional OperationalHospitalId As Long? = Nothing)
        Dim da As New LetterGeneration()
        HospitalDropDownList.Items.Clear()
        HospitalDropDownList.Items.Insert(0, New DropDownListItem("ALL", 0))
        HospitalDropDownList.AppendDataBoundItems = True
        HospitalDropDownList.DataSource = da.GetOperatingHospitals(CInt(Session("TrustId")))
        HospitalDropDownList.DataBind()
        If Not (OperationalHospitalId = 0) Then
            HospitalDropDownList.SelectedValue = OperationalHospitalId
        End If
    End Sub
    Private Sub PopulateTherapeuticTypeDropDownList(Optional TherapeuticTypeId As Long? = Nothing)
        Dim da As New LetterGeneration


        Dim DataAccessSch As DataAccess_Sch = New DataAccess_Sch()
        TherapeuticTypeDropdown.Items.Clear()
        TherapeuticTypeDropdown.Items.Insert(0, New DropDownListItem(" ", 0))
        TherapeuticTypeDropdown.AppendDataBoundItems = True
        Dim datatable = DataAccessSch.GetAllTherapeuticTypes()

        TherapeuticTypeDropdown.DataSource = datatable
        TherapeuticTypeDropdown.DataBind()

        If Not (TherapeuticTypeId = 0) Then
            TherapeuticTypeDropdown.SelectedValue = TherapeuticTypeId
        End If
    End Sub

    Protected Sub SaveButton_Click(ByVal sender As Object, ByVal e As EventArgs)
        Try
            If ((ProcedureNameDropdown.SelectedIndex = 0 And TherapeuticTypeDropdown.SelectedIndex = 0) Or RadAsyncUploadAdditionDocument.UploadedFiles.Count = 0) Then
                ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", "ShowMessage()", True)
            Else
                If RadAsyncUploadAdditionDocument.UploadedFiles.Count > 0 Then
                    Dim filestream As FileStream = RadAsyncUploadAdditionDocument.UploadedFiles(0).InputStream
                    Dim bytes(RadAsyncUploadAdditionDocument.UploadedFiles(0).ContentLength) As Byte
                    filestream.Read(bytes, 0, filestream.Length)
                    Dim da As New LetterGeneration()
                    If hdnAdditionalDocumentId.Value = Nothing Then
                        If HospitalDropDownList.SelectedIndex = 0 Then
                            For index = 1 To HospitalDropDownList.Items.Count() - 1
                                da.InsertAdditionalInfoDocument(ProcedureNameDropdown.SelectedValue, ProcedureNameDropdown.SelectedText, bytes, DocumentName.Text, HospitalDropDownList.Items.Item(index).Value, TherapeuticTypeDropdown.SelectedValue, TherapeuticTypeDropdown.SelectedText, CombindProcedureNameDropdown.SelectedValue, CombindProcedureNameDropdown.SelectedText)
                            Next
                        Else
                            da.InsertAdditionalInfoDocument(ProcedureNameDropdown.SelectedValue, ProcedureNameDropdown.SelectedText, bytes, DocumentName.Text, HospitalDropDownList.SelectedValue, TherapeuticTypeDropdown.SelectedValue, TherapeuticTypeDropdown.SelectedText, CombindProcedureNameDropdown.SelectedValue, CombindProcedureNameDropdown.SelectedText)
                        End If
                    Else
                        If HospitalDropDownList.SelectedIndex = 0 Then
                            For index = 1 To HospitalDropDownList.Items.Count() - 1
                                da.UpdateAdditionalInfoDocument(CType(hdnAdditionalDocumentId.Value, Long), ProcedureNameDropdown.SelectedValue, ProcedureNameDropdown.SelectedText, bytes, DocumentName.Text, HospitalDropDownList.Items.Item(index).Value, TherapeuticTypeDropdown.SelectedValue, TherapeuticTypeDropdown.SelectedText, CombindProcedureNameDropdown.SelectedValue, CombindProcedureNameDropdown.SelectedText)
                            Next
                        Else
                            da.UpdateAdditionalInfoDocument(CType(hdnAdditionalDocumentId.Value, Long), ProcedureNameDropdown.SelectedValue, ProcedureNameDropdown.SelectedText, bytes, DocumentName.Text, HospitalDropDownList.SelectedValue, TherapeuticTypeDropdown.SelectedValue, TherapeuticTypeDropdown.SelectedText, CombindProcedureNameDropdown.SelectedValue, CombindProcedureNameDropdown.SelectedText)
                        End If
                    End If

                End If

                Response.Redirect("AdditionalDocument.aspx", False)
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured During Additional document save for Letter.", ex)
            Utilities.SetErrorNotificationStyle(LetterPrintRadNotification, errorLogRef, "Error During Additional document Save.")
            LetterPrintRadNotification.Show()
        End Try
    End Sub

    Protected Sub CancelButton_Click(ByVal sender As Object, ByVal e As EventArgs)

        Response.Redirect("AdditionalDocument.aspx", False)
    End Sub
    Protected Sub ProcedureNameDropdown_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)

        'PopulateTherapeuticTypeDropDownList()


    End Sub
    Protected Sub HospitalDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
        'PopulateGrid()
    End Sub
End Class