Imports System.IO
Imports System.Net.Mail
Imports System.Web.Services
Imports System.Windows
Imports Hl7.Fhir.Model
Imports Telerik
Imports Telerik.Web.UI
Imports Telerik.Web.UI.Widgets

Public Class PrintInitiate
    Inherits System.Web.UI.UserControl

    Private procedureId As Int32 = 0

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'Dim PatProcAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Page)
        'PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PrintButton, PrintButton, RadAjaxLoadingPanel1)

        If Request.PhysicalPath.IndexOf("Procedure.aspx") >= 0 Then
            divInitiatePrint.Attributes.Remove("class")
            divInitiatePrint.Attributes.Item("style") = divInitiatePrint.Attributes.Item("style").Replace("1px solid",
                                                                                                          "0px solid")

        End If

        If Not Session(Constants.SESSION_PROCEDURE_ID) Is Nothing Then
            procedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))
        End If

        If ConfigurationManager.AppSettings("PrintPreview") = "false" Then
            PrintPreviewButton.Visible = False
        End If

        Dim da As New DataAccess
        If da.ProcedureAmended(procedureId) Then
            'ResendButton.Visible = True
        Else
            'ResendButton.Visible = False
        End If

        Dim od As New OtherData
        Dim dtTr As DataTable = od.GetTrainerTraineeEndo(procedureId)
        If dtTr.Rows.Count > 0 Then
            Dim drEndoscopist As DataRow = dtTr.Rows(0)
            Dim trainee_Exist As Boolean

            trainee_Exist = IIf(IsDBNull(dtTr.Rows(0).Item("TraineeEndoscopist")), False, True)
            If Not trainee_Exist Then
                chkEndo2Sign.Enabled = False
            End If
        End If
        If Not Page.IsPostBack Then
            Dim operatingHospitalId As Integer = CInt(Session("OperatingHospitalID"))
            Dim db As New ERS.Data.GastroDbEntities
            Dim rPrintDoubleSided = (From p In db.ERS_PrintOptionsGPReport
                                     Where p.OperatingHospitalId = operatingHospitalId
                                     Select p.PrintDoubleSided).FirstOrDefault()
            PrintDoubleSidedCheckBox.Checked = rPrintDoubleSided
        End If
    End Sub

    Public Sub PopulateCopyTo()
        PopulateComboBoxes()
        Dim od As New OtherData
        Dim dtFu As DataTable = od.GetUpperGIFollowUp(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        If dtFu.Rows.Count > 0 Then
            PopulateData(dtFu.Rows(0))
        Else
            CopyToRefConTextBox.SelectedValue = od.GetReferringConsultant(procedureId)
        End If
    End Sub

    Public Sub LoadPrintInitiatePage()

        Dim da As New DataAccess
        If Not Page.IsPostBack Then
            'Dim dt As DataTable = da.GetPrintReportPhotos(CInt(Session("OperatingHospitalID")), CInt(Session(Constants.SESSION_PROCEDURE_ID)), CInt(Session(Constants.SESSION_EPISODE_NO)), CStr(Session(Constants.SESSION_PATIENT_COMBO_ID)), CInt(Session(Constants.SESSION_PROCEDURE_COLONTYPE)))
            Dim dt As DataTable = da.IsImagesOnReport(CInt(Session("OperatingHospitalID")),
                                                      Session(Constants.SESSION_PROCEDURE_ID),
                                                      CInt(Session(Constants.SESSION_EPISODE_NO)),
                                                      CStr(Session(Constants.SESSION_PATIENT_COMBO_ID)),
                                                      CInt(Session(Constants.SESSION_PROCEDURE_COLONTYPE)))
            'If dt Is Nothing OrElse dt.Rows.Count = 0 Then
            If dt Is Nothing OrElse dt.Rows(0)(0) = 0 Then
                PrintPhotosCheckBox.Checked = False
                PrintPhotosCheckBox.Enabled = False
                PhotosCountDiv.Visible = False
                PhotoSizeRadioButtonList.Visible = False
            Else
                PrintPhotosCheckBox.Enabled = True
                PrintPhotosCheckBox.Checked = True
                PhotosCountDiv.Visible = True
                PhotoSizeRadioButtonList.Visible = True

                If Request.PhysicalPath.IndexOf("PrintProcedure.aspx") >= 0 Then
                    'show checkbox
                    DeleteImagesVideosCheckbox.Visible =
                        Directory.Exists(
                            Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" &
                            Session(Constants.SESSION_PROCEDURE_ID)) AndAlso
                        System.IO.Directory.GetFiles(
                            Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" &
                            Session(Constants.SESSION_PROCEDURE_ID)).Count > 0
                    DeleteImagesVideosCheckbox.Checked = False
                End If
            End If
            PopulateCopyTo()
        End If
        PopulateCopies()
        If PhotoSizeRadioButtonList.SelectedValue = "" Then
            SetPhotoSizeDefault()
        End If

        Dim useLabRequestForm As Boolean = da.UseLabRequestForm(Session(Constants.SESSION_PROCEDURE_ID))
        Dim specimenCount = da.GetProcedureSpecimenCount(Session(Constants.SESSION_PROCEDURE_ID))

        PrintLabRequestCheckBox.Checked =
            (specimenCount > 0) And
            (LabRequestCount.Value > 0 AndAlso useLabRequestForm)
        PrintLabRequestCheckBox.Enabled = specimenCount > 0 AndAlso useLabRequestForm
        LabRequestCountDiv.Visible = specimenCount > 0 AndAlso useLabRequestForm

        If Session("LicenseExpired") = "True" Then
            PrintButton.Enabled = False
            PrintPreviewButton.Enabled = False
            PrintGPReportCheckBox.Enabled = False
            PrintPhotosCheckBox.Enabled = False
            PrintPatientCopyCheckBox.Enabled = False
            PrintLabRequestCheckBox.Enabled = False
        End If
        If Session(Constants.SESSION_PATIENT_COMBO_ID) = "" Then
            ReturnToRadioButtonList.Items(2).Enabled = True
        Else
            ReturnToRadioButtonList.Items(2).Enabled = False
            cbxProcedure.Enabled = False

            If ReturnToRadioButtonList.SelectedIndex > 1 Then
                ReturnToRadioButtonList.SelectedIndex = 0
            End If

            If Session(Constants.SESSION_PATIENT_COMBO_ID) <> "" Then
                cbxProcedure.Visible = False
                ReturnToRadioButtonList.Items.RemoveAt(2)
            End If
        End If
        If Not IsNothing(Session("DocumentStoreIdList")) Then
            Session("DocumentStoreIdList") = Nothing
        End If
    End Sub

    Private Sub SetPhotoSizeDefault()
        Dim od As New OtherData
        Dim dtFu As DataTable = od.ImageSizeDefault()
        If dtFu.Rows.Count > 0 Then
            Dim drFu As DataRow = dtFu.Rows(0)
            PhotoSizeRadioButtonList.SelectedValue = drFu("DefaultPhotoSize")
        End If
    End Sub

    Private Sub PopulateCopies()
        Dim od As New OtherData
        Dim dtFu As DataTable = od.PrintCopiesDefault()
        If dtFu.Rows.Count > 0 Then
            Dim drFu As DataRow = dtFu.Rows(0)
            If IsNothing(GPReportCount.Value) Then GPReportCount.Value = drFu("gpCopies").ToString()
            If IsNothing(LabRequestCount.Value) Then LabRequestCount.Value = drFu("LabCopies").ToString()
            If IsNothing(PhotosCount.Value) Then PhotosCount.Value = drFu("PhotosCopies").ToString()
            If IsNothing(PatientCopyCount.Value) Then PatientCopyCount.Value = drFu("PatientCopies").ToString()
            If IsNothing(GPReportCount.Value) Then PrintPhotosOnGPReport.Checked = drFu("ImagesOnGPReport")
        End If
    End Sub

    Private Sub PopulateData(ByVal drFu As DataRow)
        Dim patientId As Int32 = 0
        Select Case CInt(drFu("CopyToPatient"))
            Case 1
                CopyToPatientRadioButton.Checked = True
            Case 2
                PatientNotCopiedRadioButton.Checked = True
        End Select

        If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
            Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
            patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
        Else
            MessageBox.Show("Your session expired, please start procedure again..")
            Response.Redirect("~/Products/Default.aspx", False)
        End If

        If Not IsDBNull(drFu("CopyToPatientText")) AndAlso Not String.IsNullOrEmpty(drFu("CopyToPatientText")) Then
            CopyToPatientTextBox.Text = CStr(drFu("CopyToPatientText"))
        Else

            ' get patient name from DB 
            Dim da As New DataAccess()
            Dim patientInfo = da.GetPatient(patientId)
            If patientInfo.Rows.Count > 0 Then
                CopyToPatientTextBox.Text = patientInfo.Rows(0)("Forename") + " " + patientInfo.Rows(0)("Surname")
            End If
            'CopyToPatientTextBox.Text = ""
        End If

        PatientNotCopiedReasonTextBox.SelectedValue = drFu("PatientNotCopiedReason").ToString
        CopyToRefConCheckBox.Checked = CBool(drFu("CopyToRefCon"))
        'If CBool(drFu("CopyToRefCon")) Then CopyToRefConTD.Style("display") = "normal"
        If Not IsDBNull(drFu("CopyToRefConText")) AndAlso Not String.IsNullOrEmpty(drFu("CopyToRefConText")) Then
            CopyToRefConTextBox.SelectedValue = CStr(drFu("CopyToRefConText"))
        Else
            CopyToRefConTextBox.Text = ""
        End If

        CopyToOtherCheckBox.Checked = CBool(drFu("CopyToOther"))
        If CBool(drFu("CopyToOther")) Then
            CopyToOtherTD.Style("display") = "normal"
            CopyToOtherTextBox.Text = Server.HtmlDecode(CStr(drFu("CopyToOtherText")))
        Else
            CopyToOtherTextBox.Text = ""
        End If
        If Not IsDBNull(drFu("CopyToGPEmailAddress")) Then
            CopyToGPEmailAddressCheckBox.Checked = CBool(drFu("CopyToGPEmailAddress")) 'updated by mostafiz 3891
        End If


        'If Session("GPEmailAddress") IsNot Nothing AndAlso Session("GPEmailAddress").ToString() = "False" Then
        '    CopyToGPEmailAddressAddManuallyTR.Visible = False
        'Else
        '    CopyToGPEmailAddressAddManuallyTR.Visible = True
        '    CopyToGPEmailAddressAddManuallyTD.Visible = True
        '    CopyToGPEmailAddressCheckBox.Checked = CBool(drFu("IsCopyToGPEmailAddressChecked"))

        '    If CopyToGPEmailAddressCheckBox.Checked = True Then

        '        CopyToGPEmailAddressAddManuallyTD.Visible = False
        '    End If

        '    CopyToGPEmailAddressAddManuallyTD.Visible = True
        '    CopyToGPEmailAddressAddManuallyTextBox.Text = If(Session("GPEmailAddress"), "")
        'End If
    End Sub

    Private Sub PopulateComboBoxes()

        Dim dataAdapter As DataAccess = New DataAccess

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                                  {PatientNotCopiedReasonTextBox, "PatientNotCopiedReason"}
                                  })

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{CopyToRefConTextBox, ""}},
                               dataAdapter.GetConsultantList, "FullName", "ConsultantID")
        CopyToPatientTextBox.Text = dataAdapter.rGetUsername(Session(Constants.SESSION_PROCEDURE_ID))
        CopyToRefConTextBox.SelectedValue = dataAdapter.rGetReferralConsultantNo(Session(Constants.SESSION_PROCEDURE_ID))

        Dim productTypeId = dataAdapter.GetProductId(Session(Constants.SESSION_PROCEDURE_TYPE))

        Dim procedureTypeDataTable As DataTable = dataAdapter.GetProcedureTypes(productTypeId)
        cbxProcedure.Items.Clear()
        For Each procedureType In procedureTypeDataTable.Rows
            Dim procedureName As String = procedureType.ItemArray(2).ToString
            If procedureName = "Sigmoidscopy" Then
                procedureName = "Sigmoidoscopy"
            End If
            If procedureType.ItemArray(1).ToString <> Session(Constants.SESSION_PROCEDURE_TYPE) Then
                cbxProcedure.Items.Add(New RadComboBoxItem(procedureName, procedureType.ItemArray(1).ToString))
            End If
        Next
    End Sub

    Public Sub optionERSViewer()
        ConfigureButton.Visible = False
        PrintPatientCopyCheckBox.Visible = False
        PatientCopyCountDiv.Visible = False
        PrintLabRequestCheckBox.Visible = False
        LabRequestCountDiv.Visible = False
        cbxProcedure.Visible = False
        ReturnToRadioButtonList.Items.RemoveAt(2)
        'ReportSelectFieldset.Style.Item("width") = "40%"

        'Dim listItem As ListItem = ReturnToRadioButtonList.Items.FindByValue("2")
        'If Not listItem Is Nothing Then ReturnToRadioButtonList.Items.Remove(listItem)
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Dim da As New OtherData
        Dim copyToPatient As Integer

        If CopyToPatientRadioButton.Checked Then
            copyToPatient = 1
        ElseIf PatientNotCopiedRadioButton.Checked Then
            copyToPatient = 2
        End If
        da.SavePatientCopyTo(Session(Constants.SESSION_PROCEDURE_ID),
                             copyToPatient,
                             IIf(copyToPatient = 2, Nothing, CopyToPatientTextBox.Text),
                             IIf(copyToPatient = 1, Nothing, Utilities.GetComboBoxValue(PatientNotCopiedReasonTextBox)),
                             IIf(copyToPatient = 1, Nothing, PatientNotCopiedReasonTextBox.SelectedItem.Text),
                             CopyToRefConCheckBox.Checked,
                             IIf(CopyToRefConCheckBox.Checked, CopyToRefConTextBox.SelectedValue, Nothing),
                             CopyToOtherCheckBox.Checked,
                             IIf(CopyToOtherCheckBox.Checked, Server.HtmlEncode(CopyToOtherTextBox.Text), Nothing),
                             Server.HtmlEncode(SalutationTextBox.Text),
                             CopyToGPEmailAddressCheckBox.Checked,
                             CopyToGPEmailAddressAddManuallyTextBox.Text)

        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "TogglePatientCopiedDetails", "setupCopyTo();", True)
    End Sub

    'Private Sub ResesndButton_Click(sender As Object, e As EventArgs) Handles ResendButton.Click
    '    PrintSendReport(False)
    'End Sub

    Private Sub PrintButton_Click(sender As Object, e As EventArgs) Handles PrintButton.Click
        PrintSendReport(True)
    End Sub

    Private Sub PrintSendReport(print As Boolean)

        Session("PRINT_SESSION_PROCEDURE_ID") = Session(Constants.SESSION_PROCEDURE_ID)
        Session("PRINT_SESSION_PROCEDURE_TYPE") = Session(Constants.SESSION_PROCEDURE_TYPE)

        If ReturnToRadioButtonList.SelectedIndex = 2 Then
            Session(Constants.SESSION_NEXT_PROCEDURE_TYPE) = cbxProcedure.SelectedValue
        End If

        Session("PDFPathAndFileName") = ""
        Session("PdfReportFilename") = ""
        Session("PdfLocationDirectory") = ""

        Dim da As New DataAccess
        '## Print Preview is displayed.. seems the operator is happy to proceed for Printing... now do the actual NED Export match... NED vs Developer;!
        '## 1-0 Developer !!! 

        'log procedure end
        da.logProcedureEnd(procedureId)

        'If procedure has been changed since last print, set NEDExported to false so it is picked up by the sender rather than sent immediatley 
        If da.ProcedureAmended(procedureId) Then
            da.logProcedureChanged(procedureId)
        End If


        'Mahfuz added on 22/03/2021 - Options for Webservice Procedure data export and Result export to ICE/Flat file
        If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then _
            'For D&G Scottish Hospital SCI Store WS
            'Do Export procedure result data to SCI Store Web Service

            '***** BELOW CODE HAS BEEN MOVED TO PrintReport.aspx.vb , Line 211. As generating result xml here was missing the PDF document stored in ERS_DocumentStore
            'PDF document not yet saved in ERS_DocumentStore here
            'Dim objScotHXmlWriter As ScotHospitalWSXmlWriter
            'objScotHXmlWriter = New ScotHospitalWSXmlWriter()
            'objScotHXmlWriter.GenerateResultXmlFile(CInt(Session(Constants.SESSION_PROCEDURE_ID)), Session(Constants.SESSION_PROCEDURE_TYPE), "2.40.03")

        ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.FileDataExport _
            Then 'For ICE, Data export/Anglia Export to EPR
            'Mahfuz added - Only export files if Procedure is amended/changed on 21 July 2021
            If _
                da.ProcedureAmended(procedureId) And
                da.CanProcedureTypeExportDocument(procedureId) Then
                'Export data it ICE / Flatfile
                Dim objFileExport As New DataExportLogic()
                Dim blnExportSuccess = True
                Dim strExportMessage As String = ""
                blnExportSuccess =
                    objFileExport.ExportProcedureFlatFileByProcedureId(procedureId)

                If blnExportSuccess Then
                    strExportMessage = "File data exported successfully."
                Else
                    strExportMessage = "File data export unsuccessful. Please check error log."
                End If
            End If
        ElseIf _
            Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) =
            ImportPatientByWebserviceOptions.FlatFile_Practice_Plus_Group_SO Then _
            'For Southampton Practice Plus Group Export Document

            If _
                da.ProcedureAmended(procedureId) And
                da.CanProcedureTypeExportDocument(procedureId) Then
                Dim objFileExport As New DataExportLogic()
                Dim blnExportSuccess = True
                Dim strExportMessage As String = ""
                blnExportSuccess =
                    objFileExport.ExportProcedureFlatFile_For_Southampton_PPG_ByProcedureId(
                        procedureId)

                If blnExportSuccess Then
                    strExportMessage = "File data exported successfully."
                Else
                    strExportMessage = "File data export unsuccessful. Please check error log."
                End If
            End If


        ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.XML_and_HTML Or Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.XML_and_Main_PDF _
            Then 'For North Midland (Stoke) - XML and HTML file export
            If _
                da.ProcedureAmended(procedureId) And
                da.CanProcedureTypeExportDocument(procedureId) Then
                'Export both XML and HTML file
                Dim objFileExport As New DataExportLogic()
                Dim blnExportSuccess = True

                blnExportSuccess =
                    objFileExport.ExportProcedureXmlAndHTMLByProcedureId(procedureId)


                Dim strExportMessage As String = ""
                'blnExportSuccess = objFileExport.ExportProcedureFlatFileByProcedureId(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

                If blnExportSuccess Then
                    strExportMessage = "File data exported successfully."
                Else
                    strExportMessage = "File data export unsuccessful. Please check error log."
                End If
            End If
        End If


        If print Then InitiatePrint(False)

    End Sub

    Private Sub PrintPreviewButton_Click(sender As Object, e As EventArgs) Handles PrintPreviewButton.Click

        Session("PRINT_SESSION_PROCEDURE_ID") = Session(Constants.SESSION_PROCEDURE_ID)
        Session("PRINT_SESSION_PROCEDURE_TYPE") = Session(Constants.SESSION_PROCEDURE_TYPE)

        InitiatePrint(True)
        PrintWindow.OnClientClose = "setupCopyTo"
    End Sub

    Private Sub InitiatePrint(ByVal previewOnly As Boolean)
        Dim opt As New Options()
        Dim msg As String = String.Empty
        'Dim procedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))

        If _
            CBool(Session("IsDemoVersion")) Or CBool(Session("isERSViewer")) Or
            Session(Constants.SESSION_PATIENT_COMBO_ID) <> "" Then
            ''
        Else
            msg = opt.CheckRequired(procedureId)
            If msg <> String.Empty Then
                Dim errorMessage As String = "The following sections are incomplete:<br />" & msg & "<br /><small>*make sure that any fields requiring further selections or text are also complete</small></br />"
                'Dim url As String = msg.Split("|")(1)

                'PrintRadNotification.Value = Page.ResolveUrl(url.Replace("..", "~"))
                'valDiv.InnerHtml = errorMessage
                Utilities.SetNotificationStyle(RadNotification1, errorMessage, True, "Please correct the following")
                RadNotification1.Show()
                Exit Sub
            End If
        End If

        Dim procId As String = String.Empty
        Dim epiNo As String = String.Empty
        Dim procTypeId As String = String.Empty
        Dim colonType As String = String.Empty
        Dim cnn As String = String.Empty
        Dim diagramNum As String = String.Empty

        Dim PrevProcsTreeView As RadTreeView = Me.Parent.FindControl("PrevProcsTreeView")

        If PrevProcsTreeView IsNot Nothing Then
            procId = CStr(PrevProcsTreeView.SelectedNode.Attributes("ProcedureId"))
            epiNo = CStr(PrevProcsTreeView.SelectedNode.Attributes("EpisodeNo"))
            procTypeId = CStr(PrevProcsTreeView.SelectedNode.Attributes("ProcedureType"))
            colonType = CStr(PrevProcsTreeView.SelectedNode.Attributes("ColonType"))
            'cnn = CStr(PrevProcsTreeView.SelectedNode.Attributes("cnn"))
            diagramNum = CStr(PrevProcsTreeView.SelectedNode.Attributes("DiagramNumber"))

        Else
            procId = CStr(Session(Constants.SESSION_PROCEDURE_ID))
            epiNo = "0"
            procTypeId = CStr(Session(Constants.SESSION_PROCEDURE_TYPE))
            colonType = CStr(Session(Constants.SESSION_PROCEDURE_COLONTYPE))
            'cnn = CStr(PrevProcsTreeView.SelectedNode.Attributes("cnn"))
            diagramNum = CStr(Session(Constants.SESSION_DIAGRAM_NUMBER))
        End If

        Dim script As New StringBuilder

        script.Append("var procId;")
        script.Append("var epiNo;")
        script.Append("var procTypeId;")
        script.Append("var cType;")
        script.Append("var cnn;")
        script.Append("var diagramNum;")
        script.Append("var previewOnly;")
        script.Append("var deleteMedia;")

        script.Append("procId = '" & procId & "';")
        script.Append("epiNo = '" & epiNo & "';")
        script.Append("procTypeId = '" & procTypeId & "';")
        script.Append("cType = '" & colonType & "';")
        script.Append("cnn = '" & cnn & "';")
        script.Append("diagramNum = '" & diagramNum & "';")
        script.Append("previewOnly = '" & previewOnly & "';")
        script.Append("deleteMedia = '" & DeleteImagesVideosCheckbox.Checked & "';")

        script.Append("GetDiagramScript();")

        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", script.ToString(), True)
    End Sub

    Protected Sub CloseButton_Click(sender As Object, e As EventArgs)
        Dim sm As New SessionManager
        sm.ClearPatientSessions()
        Response.Redirect("~/Products/Default.aspx", False)
    End Sub
    Public Sub DownloadPdfInBrowser()
        Dim tempFilePath As String = CType(Session("outputStreamName"), String)
        Dim file As New FileInfo(If(tempFilePath IsNot Nothing, tempFilePath, Server.MapPath("~/TempFiles")))
        If file.Exists Then
            'Clear the response buffer
            System.Web.HttpContext.Current.Response.Clear()
            System.Web.HttpContext.Current.Response.ClearHeaders() ' Clear any existing headers
            'Set the output type as a PDF
            System.Web.HttpContext.Current.Response.ContentType = "application/pdf"
            'Disable caching'
            System.Web.HttpContext.Current.Response.AddHeader("Expires", "0")
            System.Web.HttpContext.Current.Response.AddHeader("Cache-Control", "")
            'Set the filename'
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", "attachment; filename=""" & tempFilePath & """")
            'Set the length of the file so the browser can display an accurate progress bar
            'Write the contents of the memory stream
            'System.Web.HttpContext.Current.Response.OutputStream.Write(outputStream.GetBuffer(), 0, outputStream.GetBuffer().Length)
            Context.Response.TransmitFile(tempFilePath)
            'Close the response stream
            'System.Web.HttpContext.Current.Response.End()
            HttpContext.Current.Response.Flush() ' Sends all currently buffered output to the client.
            HttpContext.Current.Response.SuppressContent = True ' Gets or sets a value indicating whether to send HTTP content to the client.
            HttpContext.Current.ApplicationInstance.CompleteRequest()
        End If

    End Sub
End Class