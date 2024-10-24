Imports System
Imports System.IO
Imports iTextSharp.text
Imports iTextSharp.text.pdf
Imports iTextSharp.tool.xml
Imports iTextSharp.tool.xml.html
Imports iTextSharp.tool.xml.parser
Imports iTextSharp.tool.xml.css
Imports iTextSharp.tool.xml.pipeline.html
Imports iTextSharp.tool.xml.pipeline.css
Imports iTextSharp.tool.xml.pipeline.end
Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.File
Imports System.Web
Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Drawing
Imports System.Drawing.Imaging
Imports System.Net.Mail
Imports Telerik.Web.UI
Imports System.Web.Hosting
Imports System.Windows
Imports iTextSharp.text.pdf.XfaForm
Imports System.Data.Common
Imports Telerik.Web.UI.Widgets
Imports Telerik.Web.Data.Extensions


Partial Class Products_Common_PrintReport
    Inherits PageBase

    Private _photosExist As Boolean
    Private _labRequestPages As New List(Of LabRequestPage)
    Private _ResectedColonText As String
    Private _redirectToLoginPage As Boolean
    Private _dtPatRD As DataTable = Nothing

    Private PatName As String
    Private PatDob As String
    Private PatNhsNo As String
    Private PatCaseNoteNo As String
    Private PatAddress As String
    Private PhotoSize As Integer
    Private procedureId As Int32 = 0
    Private patientId As Int32 = 0

    Public ReadOnly Property PrintParams() As PrintOptions
        Get
            Return DirectCast(Session("PrintOptions"), PrintOptions)
        End Get
    End Property

    Public ReadOnly Property IsERSViewer As String
        Get
            Return Session("isERSViewer")
        End Get
    End Property

    Public ReadOnly Property RepEnableNHSStyle As String
        Get
            Return ConfigurationManager.AppSettings("Unisoft.RepEnableNHSStyle")
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Request.QueryString.Count > 0 Then
                Dim printGPReport As Boolean
                Dim printPhotosReport As Boolean
                Dim printPatientCopyReport As Boolean
                Dim printLabRequestReport As Boolean
                Dim previewOnly As Boolean
                Dim deleteMedia As Boolean
                Dim photosOnGpReport As Boolean
                Dim endo1Sig As Boolean
                Dim endo2Sig As Boolean
                Dim printDoubleSided As Boolean
                lblNHSNo.Text = Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " No"

                If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                    Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                    patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
                Else
                    MessageBox.Show("Your session expired, please start procedure again..")
                    Response.Redirect("~/Products/Default.aspx", False)
                End If

                If Not Session("PRINT_SESSION_PROCEDURE_ID") Is Nothing Then
                    procedureId = CInt(Session("PRINT_SESSION_PROCEDURE_ID"))
                End If

                If Request.QueryString("PrintGPReport") IsNot Nothing Then
                    printGPReport = CBool(Request.QueryString("PrintGPReport"))
                Else
                    printGPReport = True
                End If
                If Request.QueryString("PrintPhotosReport") IsNot Nothing Then
                    printPhotosReport = CBool(Request.QueryString("PrintPhotosReport"))
                Else
                    printPhotosReport = False
                End If
                If Request.QueryString("PrintPatientCopyReport") IsNot Nothing Then
                    printPatientCopyReport = CBool(Request.QueryString("PrintPatientCopyReport"))
                Else
                    printPatientCopyReport = False
                End If
                If Request.QueryString("PrintLabRequestReport") IsNot Nothing Then
                    printLabRequestReport = CBool(Request.QueryString("PrintLabRequestReport"))
                Else
                    printLabRequestReport = False
                End If
                If Request.QueryString("PreviewOnly") IsNot Nothing Then
                    previewOnly = CBool(Request.QueryString("PreviewOnly"))
                Else
                    previewOnly = True
                End If
                If Request.QueryString("DeleteMedia") IsNot Nothing Then
                    deleteMedia = CBool(Request.QueryString("DeleteMedia"))
                Else
                    deleteMedia = False
                End If
                If Request.QueryString("PhotosOnGP") IsNot Nothing Then
                    photosOnGpReport = CBool(Request.QueryString("PhotosOnGP"))
                Else
                    photosOnGpReport = True
                End If
                If Request.QueryString("Endo1Sig") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request.QueryString("Endo1Sig")) Then
                    endo1Sig = CBool(Request.QueryString("Endo1Sig"))
                Else
                    endo1Sig = False
                End If
                If Request.QueryString("Endo2Sig") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request.QueryString("Endo2Sig")) Then
                    endo2Sig = CBool(Request.QueryString("Endo2Sig"))
                Else
                    endo2Sig = False
                End If
                If Request.QueryString("PrintDoubleSided") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request.QueryString("PrintDoubleSided")) Then
                    printDoubleSided = CBool(Request.QueryString("PrintDoubleSided"))
                Else
                    printDoubleSided = False
                End If


                SetPrintOptions(printGPReport, photosOnGpReport, printPhotosReport, printPatientCopyReport, printLabRequestReport, previewOnly, deleteMedia, endo1Sig, endo2Sig, printDoubleSided)

                'If Not IsDBNull(Request.QueryString("Resected")) Then
                '    _ResectedColonText = Request.QueryString("Resected")
                'End If

                Dim ds As New OtherData
                Dim BowelText As String = ds.GetBostonBowelPrepText(PrintParams.ProcedureId)
                If Not IsNothing(BowelText) Then
                    BowelPrepLabel.Text = BowelText
                    BowelPrepTr.Visible = True
                Else
                    BowelPrepTr.Visible = False
                End If

                Using db As New ERS.Data.GastroDbEntities
                    Dim isBiopsy = (From spe In db.ERS_UpperGISpecimens
                                    Join sit In db.ERS_Sites
                                                 On spe.SiteId Equals sit.SiteId
                                    Where sit.ProcedureId = PrintParams.ProcedureId
                                    Select spe.Urease, spe.UreaseResult).ToList()

                    If isBiopsy.Any(Function(x) x.Urease = True And x.UreaseResult = 2) Then '1 = positive and 2 = negative :/
                        UreaseResultsTr.Visible = True
                        PositiveResultLabel.Visible = False
                        NegativeResultLabel.Visible = True
                    ElseIf isBiopsy.Any(Function(x) x.Urease = True And x.UreaseResult = 1) Then
                        UreaseResultsTr.Visible = True
                        PositiveResultLabel.Visible = True
                        NegativeResultLabel.Visible = False
                    ElseIf isBiopsy.Any(Function(x) x.Urease = False) Then
                        UreaseResultsTr.Visible = False
                    End If
                End Using

                If printPhotosReport Then
                    'Set number of columns for the photos
                    Dim da As New DataAccess
                    PhotoSize = CInt(Request.QueryString("PhotoSize"))
                    Select Case PhotoSize
                        Case 1
                            PhotosListView.RepeatColumns = 4
                            PhotoSize = 175
                        Case 2
                            PhotosListView.RepeatColumns = 2
                            PhotoSize = 350
                        Case 3
                            PhotosListView.RepeatColumns = 1
                            PhotoSize = 720
                    End Select
                End If

                PopulateReport()
            End If
        End If

    End Sub

    Private Sub Page_Unload(sender As Object, e As EventArgs) Handles Me.Unload
        Try
            Dim sReturnToPage As String = HttpContext.Current.Request.QueryString("ReturnToPage")
            If Not Session("PrintOptions").PreviewOnly Then
                If sReturnToPage = "0" Then '0:Return to the Home screen
                    SessionHelper.ClearPatientSessions()
                ElseIf sReturnToPage = "2" Then  '"Add another procedure for this patient" is selected.
                    Dim iNextProcedure As Integer = CInt(Session(Constants.SESSION_NEXT_PROCEDURE_TYPE))
                    If iNextProcedure > 0 Then
                        Dim newProcId As Integer = DataAdapter.ReplicateProcedure(procedureId, iNextProcedure)
                        If newProcId > 0 Then
                            Session(Constants.SESSION_PROCEDURE_TYPE) = CInt(Session(Constants.SESSION_NEXT_PROCEDURE_TYPE))
                        End If
                        'check for appointment and update patient journey table
                        If CInt(Session(Constants.SESSION_APPOINTMENT_ID)) > 0 Then
                            DataAdapter.logJourneyProcedureStart(newProcId, Session(Constants.SESSION_APPOINTMENT_ID))
                        End If
                        SessionHelper.SetProcedureSessions(CInt(newProcId), False, iNextProcedure, -1)
                    End If
                Else
                    Session(Constants.SESSION_APPOINTMENT_ID) = Nothing
                End If
            End If

            If Not IsNothing(Session("ResetReportPageCounter")) Then
                Session("ResetReportPageCounter") = Nothing
            End If

            If Not IsNothing(Session("MaxGpReportPageNumber")) Then
                Session("MaxGpReportPageNumber") = Nothing
            End If

            If Not IsNothing(Session("MaxPhotosReportPageNumber")) Then
                Session("MaxPhotosReportPageNumber") = Nothing
            End If

            If Not IsNothing(Session("MaxPatientCopyReportPageNumber")) Then
                Session("MaxPatientCopyReportPageNumber") = Nothing
            End If

            If Not IsNothing(Session("MaxLabRequestReportPageNumber")) Then
                Session("MaxLabRequestReportPageNumber") = Nothing
            End If

            If Not IsNothing(Session("ReportCopyType")) Then
                Session("ReportCopyType") = Nothing
            End If

            If Not IsNothing(Session("LabRequestFormType")) Then
                Session("LabRequestFormType") = Nothing
            End If

        Catch ex As Exception

        End Try
    End Sub


    Private Sub SetPrintOptions(printGPReport As Boolean, photosOnGpReport As Boolean, printPhotosReport As Boolean, printPatientCopyReport As Boolean, printLabRequestReport As Boolean, previewOnly As Boolean, deleteMedia As Boolean, endo1Sig As Boolean, endo2Sig As Boolean, printDoubleSided As Boolean)
        Dim po As PrintOptions = LogicAdapter.GetPrintOptions()

        po.GPReportPrintOptions.PrintDoubleSided = printDoubleSided
        Session("PrintOptions") = po

        po.ProcedureId = procedureId
        po.ProcedureTypeId = Session("PRINT_SESSION_PROCEDURE_TYPE")
        po.EpisodeNo = Session(Constants.SESSION_EPISODE_NO)
        po.ColonType = Session(Constants.SESSION_PROCEDURE_COLONTYPE)
        po.PatientComboId = Session(Constants.SESSION_PATIENT_COMBO_ID)

        po.IncludeGPReport = printGPReport
        po.PhotosOnGpReport = photosOnGpReport
        po.IncludePhotosReport = printPhotosReport
        po.IncludePatientCopyReport = printPatientCopyReport
        po.IncludeLabRequestReport = printLabRequestReport
        po.PreviewOnly = previewOnly
        po.DeleteMedia = deleteMedia

        po.Endo1Sig = endo1Sig
        po.Endo2Sig = endo2Sig

    End Sub

    Protected Overrides Sub Render(output As HtmlTextWriter)
        Dim blnResetProcedureAmended As Boolean = False
        Dim newReportCreatedFlag As Boolean = False

        'Check if the procedure's report filename reference has been saved to the DB.
        Dim dtpdfReportName As DataTable = DataAccess.CheckIfPDFReportExists(procedureId)
        Dim drpdfReportName As DataRow = dtpdfReportName.Rows(0)

        Dim printedReportFileName As String = drpdfReportName("PrintedReportFileName").ToString()
        Session("PDFPathAndFileName") = printedReportFileName

        Dim emailSentFlag As Boolean = drpdfReportName("IsReportEmailed").ToString()

        'Email report - check if GP or Referring Consultant checkbox has been selected otherwise don't send.
        Dim dtCheckIfGpConsultantEmailsSelected As DataTable = DataAccess.CheckIfGpConsultantEmailsSelected(procedureId)
        Dim drCheckIfGpConsultantEmailsSelected As DataRow = dtCheckIfGpConsultantEmailsSelected.Rows(0)
        Dim gpEmailCheckBoxSelectedString As String = drCheckIfGpConsultantEmailsSelected("IsCopyToGPEmailAddressChecked").ToString()
        Dim refConEmailCheckBoxSelectedString As String = drCheckIfGpConsultantEmailsSelected("IsCopyToConsultantEmailAddressChecked").ToString()

        'Email report - check if GP or Referring Consultant has an email address
        Dim dtGpEmailAddress As DataTable = DataAccess.GetGPEmailAddress(patientId)
        Dim drGpEmailAddress As DataRow = dtGpEmailAddress.Rows(0)
        Dim gpEmailAddressString As String = drGpEmailAddress("EmailAddress").ToString()
        Dim consultantEmailAddressString As String = DataAccess.GetConsultantProcedureEmailAddress(procedureId)
        Dim gpEmailAddressReturnCodeString As String = drGpEmailAddress("ReturnCode").ToString()

        Session("CopyToGPEmailChecked") = gpEmailCheckBoxSelectedString
        Session("CopyToRefConChecked") = refConEmailCheckBoxSelectedString
        Session("GPEmailAddress") = gpEmailAddressString
        Session("RefConEmailAddress") = consultantEmailAddressString
        Session("GPEmailAddressReasonCode") = gpEmailAddressReturnCodeString

        Dim checkGpEmailExistsFlag As Boolean = Session("GPEmailAddressReasonCode").ToString() = "OK"
        Dim checkConsultantEmailExistsFlag As Boolean = consultantEmailAddressString <> ""
        Dim toEmailAddressCollection As New MailAddressCollection

        If ConfigurationManager.AppSettings("GPModuleActive").ToLower() = "true" AndAlso Session("GPEmailAddressReasonCode").ToString().ToLower() <> "not stated" Then
            If gpEmailCheckBoxSelectedString = "True" And refConEmailCheckBoxSelectedString = "True" And checkGpEmailExistsFlag And checkConsultantEmailExistsFlag Then
                Session("EmailSentToGpAndConsultantFlagMessage") = "Report sent electronically to: " + vbCrLf +
                                                                   "General Practitioner (GP)" + vbCrLf +
                                                                   "Referring Consultant"
            ElseIf gpEmailCheckBoxSelectedString = "True" And checkGpEmailExistsFlag And refConEmailCheckBoxSelectedString = "False" Then
                Session("EmailSentToGpAndConsultantFlagMessage") = "Report sent electronically to: " + vbCrLf +
                                                                   "General Practitioner (GP)"
            ElseIf ((gpEmailCheckBoxSelectedString = "True" And Not checkGpEmailExistsFlag) Or gpEmailCheckBoxSelectedString = "False") And refConEmailCheckBoxSelectedString = "True" And checkConsultantEmailExistsFlag Then
                Session("EmailSentToGpAndConsultantFlagMessage") = "Report sent electronically to: " + vbCrLf +
                                                                   "Referring Consultant"
            Else
                Session("EmailSentToGpAndConsultantFlagMessage") = "Report not sent electronically"
            End If
        Else
            If refConEmailCheckBoxSelectedString = "True" And checkConsultantEmailExistsFlag Then
                Session("EmailSentToGpAndConsultantFlagMessage") = "Report sent electronically to: " + vbCrLf +
                                                                   "Referring Consultant"
            Else
                'MH commented our below on 24 Mar 2022 - Practice Plus Portsmouth - don't want to see this message when GP Module Active is turned off in web config
                'Session("EmailSentToGpAndConsultantFlagMessage") = "Report not sent electronically"
                Session("EmailSentToGpAndConsultantFlagMessage") = ""
            End If
        End If

        If Not _redirectToLoginPage Then
            GenerateReport(False) 'generate and view

            PopulateReport() 'do this again to ensure the diagram is populated

            'check if procedure has been updated (ERS_Procedures.ReportUpdated = 1)
            If DataAdapter.ProcedureAmended(procedureId) And Not PrintParams.PreviewOnly Then
                GenerateReport(True) 'save
                blnResetProcedureAmended = True
                newReportCreatedFlag = True
                'Exporting Procedure Result for D&G - should be called here. (need to check) ImportPatientByWebService
                'Below code has been moved from PrintInitiate.ascx.vb line 280
                If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then 'For D&G Scottish Hospital SCI Store WS
                    'MH added on 03 Oct 2021 - Use CanExportDocument of ProcedureType flag
                    If DataAdapter.CanProcedureTypeExportDocument(procedureId) Then
                        Dim objScotHXmlWriter As ScotHospitalWSXmlWriter
                        objScotHXmlWriter = New ScotHospitalWSXmlWriter()
                        objScotHXmlWriter.GenerateResultXmlFile(procedureId, Session("PRINT_SESSION_PROCEDURE_TYPE"), HttpContext.Current.Session(Constants.SESSION_APPVERSION))

                    End If
                ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Main_PDF_Supporting_XML Then 'MH added on 26 Jan 2022 for Warwickshire
                    Dim da As DataAccess = New DataAccess
                    If da.ProcedureAmended(procedureId) And da.CanProcedureTypeExportDocument(procedureId) Then
                        'Export XML PDF support file
                        'Need to change below codes from FlatFile to XML document
                        'Session("PDFPathAndFileName") 'Exported PDF file name is saved here.
                        Dim objFileExport As New DataExportLogic()
                        Dim blnExportSuccess = True
                        Dim strExportMessage As String = ""
                        blnExportSuccess =
                        objFileExport.ExportMainPDFSupportingXMLDocument(procedureId)

                        If blnExportSuccess Then
                            strExportMessage = "PDF Support XML Document exported successfully."
                        Else
                            strExportMessage = "PDF Support XML Document export unsuccessful. Please check error log."
                        End If

                    End If
                End If

                Dim blnPrintPreview As Boolean = False

                If Not IsNothing(Session("PrintPreview")) Then
                    blnPrintPreview = Convert.ToBoolean(Session("PrintPreview"))
                Else
                    blnPrintPreview = False
                End If

                If blnResetProcedureAmended And Not blnPrintPreview Then
                    DataAdapter.ResetProcedureAmended(procedureId)
                End If
            End If


        Else
            output.Write("<script language='JavaScript'>")
            output.Write("window.parent.location='" + ResolveUrl("~/Security/Logout.aspx") + "'; ")
            output.Write("</script>")
        End If
    End Sub

#Region "Listview & Datasource events"
    Protected Sub SummaryObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryObjectDataSource.Selecting
        e.InputParameters("procId") = PrintParams.ProcedureId
        e.InputParameters("group") = "LS"
        e.InputParameters("episodeNo") = PrintParams.EpisodeNo
        e.InputParameters("patComboId") = PrintParams.PatientComboId
        e.InputParameters("ProcedureType") = PrintParams.ProcedureTypeId
        e.InputParameters("ColonType") = PrintParams.ColonType
    End Sub

    Protected Sub SummaryObjectDataSourceRightSide_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryObjectDataSourceRightSide.Selecting
        e.InputParameters("procId") = PrintParams.ProcedureId
        e.InputParameters("ProcedureType") = PrintParams.ProcedureTypeId
        e.InputParameters("group") = "RS"
        e.InputParameters("episodeNo") = PrintParams.EpisodeNo
        e.InputParameters("patComboId") = PrintParams.PatientComboId
        e.InputParameters("ColonType") = PrintParams.ColonType
    End Sub

    Protected Sub SummaryObjectDataSourceAfterDiagram_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryObjectDataSourceAfterDiagram.Selecting
        e.InputParameters("procId") = PrintParams.ProcedureId
        e.InputParameters("group") = "AD"
        e.InputParameters("episodeNo") = PrintParams.EpisodeNo
        e.InputParameters("patComboId") = PrintParams.PatientComboId
        e.InputParameters("ProcedureType") = PrintParams.ProcedureTypeId
        e.InputParameters("ColonType") = PrintParams.ColonType
    End Sub

    Protected Sub SummaryObjectDataSourcePhotos_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryObjectDataSourcePhotos.Selecting
        e.InputParameters("operatingHospitalId") = CInt(Session("OperatingHospitalID"))
        e.InputParameters("procedureId") = PrintParams.ProcedureId
        e.InputParameters("episodeNo") = PrintParams.EpisodeNo
        e.InputParameters("patientComboId") = PrintParams.PatientComboId
        e.InputParameters("ColonType") = PrintParams.ColonType
    End Sub

    Protected Sub SummaryObjectDataSourceSpecimens_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryObjectDataSourceSpecimens.Selecting
        If PrintParams.IncludeLabRequestReport Then
            e.InputParameters("procedureId") = PrintParams.ProcedureId
        Else
            e.Cancel = True
        End If
    End Sub

    'Protected Sub PatientFriendlyAdditionalTextObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles PatientFriendlyAdditionalTextObjectDataSource.Selecting
    '    If PrintParams.IncludePatientCopyReport Then
    '        e.InputParameters("operatingHospitalId") = CInt(Session("OperatingHospitalID"))
    '        e.InputParameters("includedOnly") = True
    '    Else
    '        e.Cancel = True
    '    End If
    'End Sub

    Protected Sub SummaryObjectDataSourceRightSide_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles SummaryObjectDataSourceRightSide.Selected
        Dim dt As DataTable = DirectCast(e.ReturnValue, DataTable)
        If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows
                If Not IsDBNull(dr("NodeSummary")) Then
                    dr("NodeSummary") = CStr(dr("NodeSummary")).Replace(Char.ConvertFromUtf32(10), "<br />")
                End If
                If Not IsDBNull(dr("NodeName")) AndAlso Not IsDBNull(dr("NodeSummary")) AndAlso dr("NodeName") = "Resected Colon" Then
                    Dim da As New DataAccess
                    dr("NodeSummary") = da.GetResectedColonText(CInt(dr("NodeSummary")))
                End If
            Next
        End If
    End Sub

    Protected Sub SummaryObjectDataSourceAfterDiagram_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles SummaryObjectDataSourceAfterDiagram.Selected
        Dim dt As DataTable = DirectCast(e.ReturnValue, DataTable)
        If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows
                If Not IsDBNull(dr("NodeSummary")) Then
                    dr("NodeSummary") = CStr(dr("NodeSummary")).Replace(Char.ConvertFromUtf32(10), "<br />")
                End If

                If Not IsDBNull(dr("NodeSummary")) Then
                    If CStr(dr("NodeName")).ToLower() = "site legend" Then
                        SiteLegendLabel.Text = CStr(dr("NodeSummary"))
                    End If
                End If
            Next
        End If
    End Sub

    Protected Sub SummaryObjectDataSourcePhotos_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles SummaryObjectDataSourcePhotos.Selected
        Dim dt As DataTable = DirectCast(e.ReturnValue, DataTable)
        If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
            If ConfigurationManager.AppSettings("IsAzure").ToLower() <> "true" Then
                For Each dr As DataRow In dt.Rows
                    If Not IsDBNull(dr("PhotoUrl")) AndAlso Not PhotosFolderUri Is Nothing Then
                        dr("PhotoUrl") = Path.Combine(PhotosFolderUri, CStr(dr("PhotoUrl"))).Replace("\", "/")
                    End If
                Next
            End If
            _photosExist = dt.Rows.Count > 0
        End If
    End Sub

    Protected Sub SummaryObjectDataSourceSpecimens_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles SummaryObjectDataSourceSpecimens.Selected
        If PrintParams.IncludeLabRequestReport Then
            Dim specimensData As DataTable = DirectCast(e.ReturnValue, DataTable)
            If specimensData IsNot Nothing Then AscertainLabRequestPages(specimensData)
        End If
    End Sub

    Protected Sub SummaryListView_DataBound(sender As Object, e As EventArgs) Handles SummaryListView.DataBound
        If SummaryListView.Items.Count > 0 Then
            If SummaryListView.Items.Where(Function(i As ListViewDataItem) i.Visible).Count = 0 Then
                SummaryListView.Visible = False
            End If
        Else
            SummaryListView.Visible = False
        End If
    End Sub

    Protected Sub SummaryListView_ItemCreated(sender As Object, e As ListViewItemEventArgs) Handles SummaryListView.ItemCreated
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!NodeSummary) OrElse CStr(drItem!NodeSummary) = "" Then
                e.Item.Visible = False
            Else
                If PrintParams.IncludeGPReport Then
                    If CStr(drItem!NodeName) = "Diagnoses" Then
                        e.Item.Visible = PrintParams.GPReportPrintOptions.IncludeDiagnoses
                    ElseIf CStr(drItem!NodeName) = "Follow up" Then
                        e.Item.Visible = PrintParams.GPReportPrintOptions.IncludeFollowUp
                    ElseIf CStr(drItem!NodeName) = "Therapeutic procedures" Then
                        e.Item.Visible = PrintParams.GPReportPrintOptions.IncludeTherapeuticProcedures
                    ElseIf CStr(drItem!NodeName) = "Site Data" Then
                        drItem!NodeName = ""
                    End If
                    If Not PrintParams.PhotosOnGpReport Then
                        GPPhotosListView.Visible = False
                    End If
                End If
                'Image display for NPSA alert
                Dim sImagePath = "/Images/icons/alert.png"
                If CStr(drItem!NodeName) = "Report" AndAlso InStr(CStr(drItem!NodeSummary).ToLower, sImagePath.ToLower) > 0 Then
                    Dim urlalert As String = HttpContext.Current.Request.Url.AbsoluteUri.Replace(HttpContext.Current.Request.Url.PathAndQuery, "") + sImagePath
                    drItem!NodeSummary = Replace(drItem!NodeSummary, sImagePath.ToLower, urlalert.ToLower)
                End If
            End If
        End If
    End Sub

    Protected Sub SummaryListViewRightSide_DataBound(sender As Object, e As EventArgs) Handles SummaryListViewRightSide.DataBound
        If SummaryListViewRightSide.Items.Count > 0 Then
            If SummaryListViewRightSide.Items.Where(Function(i As ListViewDataItem) i.Visible).Count = 0 Then
                SummaryListViewRightSide.Visible = False
            End If
        Else
            SummaryListViewRightSide.Visible = False
        End If
    End Sub

    Protected Sub SummaryListViewRightSide_ItemCreated(sender As Object, e As ListViewItemEventArgs) Handles SummaryListViewRightSide.ItemCreated
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!NodeSummary) OrElse CStr(drItem!NodeSummary) = "" Then
                e.Item.Visible = False
            Else
                If PrintParams.IncludeGPReport Then
                    If CStr(drItem!NodeName) = "Consultant/Endoscopist" Then
                        e.Item.Visible = PrintParams.GPReportPrintOptions.IncludeListConsultant
                    ElseIf CStr(drItem!NodeName) = "Instrument" Then
                        e.Item.Visible = PrintParams.GPReportPrintOptions.IncludeInstrument
                    ElseIf CStr(drItem!NodeName) = "Premedication" Then
                        e.Item.Visible = PrintParams.GPReportPrintOptions.IncludePremedication
                    ElseIf CStr(drItem!NodeName) = "Specimens Taken" Then
                        e.Item.Visible = PrintParams.GPReportPrintOptions.IncludeSpecimensTaken
                    End If
                End If
            End If
        End If
    End Sub

    Protected Sub SummaryListViewAfterDiagram_DataBound(sender As Object, e As EventArgs) Handles SummaryListViewAfterDiagram.DataBound
        If SummaryListViewAfterDiagram.Items.Count > 0 Then
            If SummaryListViewAfterDiagram.Items.Where(Function(i As ListViewDataItem) i.Visible).Count = 0 Then
                SummaryListViewAfterDiagram.Visible = False
            End If
        Else
            SummaryListViewAfterDiagram.Visible = False
        End If
    End Sub

    Protected Sub SummaryListViewAfterDiagram_ItemCreated(sender As Object, e As ListViewItemEventArgs) Handles SummaryListViewAfterDiagram.ItemCreated
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!NodeSummary) Then
                e.Item.Visible = False
            ElseIf CStr(drItem!NodeSummary) = "" Then
                e.Item.Visible = False
            End If
        End If
    End Sub

    'Protected Sub PhotosListView_DataBound(sender As Object, e As EventArgs) Handles PhotosListView.DataBound
    '    If PhotosListView.Items.Count > 0 Then
    '        If PhotosListView.Items.Where(Function(i As ListViewDataItem) i.Visible).Count = 0 Then
    '            PhotosListView.Visible = False
    '        End If
    '    Else
    '        PhotosListView.Visible = False
    '    End If
    'End Sub

    Protected Sub PhotosListView_ItemCreated(sender As Object, e As DataListItemEventArgs) Handles PhotosListView.ItemCreated
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, DataListItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!PhotoUrl) Then
                e.Item.Visible = False
            ElseIf CStr(drItem!PhotoUrl) = "" Then
                e.Item.Visible = False
            End If

        End If
    End Sub

    Private Function GetPhotoWidth() As Integer


    End Function

    Private Sub PhotosListView_ItemDataBound(sender As Object, e As DataListItemEventArgs) Handles PhotosListView.ItemDataBound
        If e.Item.ItemType = ListItemType.Item Then
            'Dim xx As Image  = Nothing
        End If
        e.Item.Width = PhotoSize
    End Sub

    Protected Sub SummaryListView4_DataBound(sender As Object, e As EventArgs) Handles SummaryListView4.DataBound
        If SummaryListView4.Items.Count > 0 Then
            If SummaryListView4.Items.Where(Function(i As ListViewDataItem) i.Visible).Count = 0 Then
                SummaryListView4.Visible = False
            End If
        Else
            SummaryListView4.Visible = False
        End If
    End Sub

    Protected Sub SummaryListView4_ItemCreated(sender As Object, e As ListViewItemEventArgs) Handles SummaryListView4.ItemCreated
        If IsERSViewer Then Exit Sub
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!NodeSummary) OrElse CStr(drItem!NodeSummary) = "" Then
                e.Item.Visible = False
            Else
                If PrintParams.IncludeLabRequestReport Then
                    If CStr(drItem!NodeName) = "Indications" Then
                        e.Item.Visible = PrintParams.LabRequestFormPrintOptions.IncludeIndications
                    ElseIf CStr(drItem!NodeName) = "Report" Then
                        e.Item.Visible = PrintParams.LabRequestFormPrintOptions.IncludeAbnormalities
                    ElseIf CStr(drItem!NodeName) = "Diagnoses" Then
                        e.Item.Visible = PrintParams.LabRequestFormPrintOptions.IncludeDiagnoses
                    End If
                End If
            End If
        End If
    End Sub
#End Region

    Private Sub PopulateReport()
        Dim dtPat As DataTable = DataAdapter.GetPatientSummary(PrintParams.ProcedureId, PrintParams.ProcedureTypeId, PrintParams.EpisodeNo, PrintParams.PatientComboId)
        Dim dsPaInfo = DataAdapter.GetPatientReportInfo(PrintParams.ProcedureId)
        Dim dtPatInfo As DataTable = dsPaInfo.Tables(0)
        Dim dtPatInfoResult As DataTable = dsPaInfo.Tables(1)
        'Set Image url
        'NoFutherFollowupImg.Src = ResolveUrl("~/Images/Rectangle.png")
        'NoFutherFollowupImgChecked.Src = ResolveUrl("~/Images/CheckedRectangle.png")
        'FollowInThePostImg.Src = ResolveUrl("~/Images/Rectangle.png")
        'FollowInThePostImgChecked.Src = ResolveUrl("~/Images/CheckedRectangle.png")
        'DischargeToGpImg.Src = ResolveUrl("~/Images/Rectangle.png")
        'DischargeToGpImgChecked.Src = ResolveUrl("~/Images/CheckedRectangle.png")

        If Not dtPat Is Nothing AndAlso dtPat.Rows.Count > 0 Then
            Dim procedureTypeID = CInt(dtPatInfo.Rows(0)("ProcedureTypeId"))
            FRProcedureLabel.Text = dtPatInfo.Rows(0)("ProcedureType")
            FRMedication.Text = dtPatInfo.Rows(0)("MedicationText")
            FRProcedureCompleted.Text = dtPatInfo.Rows(0)("procedureComplete")
            ResultListView.DataSource = dtPatInfoResult
            ResultListView.DataBind()

            'FRProcedureCompleted.Text = If(dtPatInfo.Rows(0)("NEDEnabled") = False, "No", "")
            FRFollowUp.Text = If(dtPatInfo.Rows(0)("NoFurtherFollowUp") = True, "No follow up required, Discharged back to GP.", dtPatInfo.Rows(0)("ReviewText"))
            If dtPatInfo.Rows(0)("NoFurtherFollowUp") = True Or dtPatInfo.Rows(0)("NoFurtherTestsRequired") = True Then
                NoFutherFollowupImgChecked.Visible = True
                NoFutherFollowupImg.Visible = False
            End If


            PatName = CStr(dtPat.Rows(0)("PatientName")) & " (" & CStr(dtPat.Rows(0)("Gender")) & ")"
            NameLabel.Text = PatName
            If String.IsNullOrEmpty(dtPat.Rows(0)("ProcedureDate").ToString()) Then
                PatDob = CDate(dtPat.Rows(0)("DateOfBirth")).ToString("dd/MM/yyyy") & " (" & Utilities.GetAgeAtDate(CDate(dtPat.Rows(0)("DateOfBirth")), Now()) & ")"
            Else
                PatDob = CDate(dtPat.Rows(0)("DateOfBirth")).ToString("dd/MM/yyyy") & " (" & Utilities.GetAgeAtDate(CDate(dtPat.Rows(0)("DateOfBirth")), CDate(dtPat.Rows(0)("ProcedureDate").Substring(0, dtPat.Rows(0)("ProcedureDate").IndexOf("(") - 1))) & ")"
            End If
            DOBAgeLabel.Text = PatDob
            DobLabel.Text = PatDob
            PatNhsNo = Utilities.FormatHealthServiceNumber(CStr(dtPat.Rows(0)("NHSNo")))
            PatCaseNoteNo = CStr(dtPat.Rows(0)("CaseNoteNo"))
            PatAddress = CStr(dtPat.Rows(0)("Address")).Replace(Char.ConvertFromUtf32(10), vbCrLf).Replace(vbCrLf + vbCrLf, vbCrLf)
            'PatAddress = CStr(PatAddress.Replace(", ", vbLf))

            'NameLabel.Text = CStr(dtPat.Rows(0)("PatientName")) & " (" & CStr(dtPat.Rows(0)("Gender")) & ")"
            'DobLabel.Text = CDate(dtPat.Rows(0)("DateOfBirth")).ToString("dd/MM/yyyy")
            NhsNoLabel.Text = Utilities.FormatHealthServiceNumber(CStr(dtPat.Rows(0)("NHSNo")))
            CaseNoteNoLabel.Text = CStr(dtPat.Rows(0)("CaseNoteNo"))
            AddressLabel.Text = CStr(dtPat.Rows(0)("Address")).Replace(Char.ConvertFromUtf32(10), "<br />")

            'GPLabel.Text = CStr(dtPat.Rows(0)("GPName"))
            GPAddressLabel.Text = CStr(dtPat.Rows(0)("GPAddress")).Replace(Char.ConvertFromUtf32(10), "<br />").Replace("<br/><br/>", "<br/>")

            ProcedureDateLabel.Text = CStr(dtPat.Rows(0)("ProcedureDate"))
            StatusLabel.Text = CStr(dtPat.Rows(0)("PatientStatus"))
            HospitalLabel.Text = CStr(dtPat.Rows(0)("HospitalName"))
            WardLabel.Text = CStr(dtPat.Rows(0)("Ward"))

            Dim sPatientPriority = CStr(dtPat.Rows(0)("PatientPriority"))
            PriorityLabel.Text = sPatientPriority.Replace("[NED]", "")

            If WardLabel.Text = "(none)" Or WardLabel.Text.Trim = "" Then
                trPrintWard.Visible = False
            End If

            Dim sCaseNoteNo As String = DataAdapter.GetCountryLabel("CNN")
            Dim sNHSNo As String = DataAdapter.GetCountryLabel("NHSNo")
            lblCaseNoteNo.Text = sCaseNoteNo
            'lblPhotoCaseNoteNo.Text = sCaseNoteNo
            'lblPatientCopyCaseNoteNo.Text = sCaseNoteNo
            lblLabRequestCaseNoteNo.Text = sCaseNoteNo

            'MH uncommented below on 01 Mar 2023
            'lblNHSNo.Text = sNHSNo
            'lblPhotoNHSNo.Text = sNHSNo
            'lblPatientCopyNHSNo.Text = sNHSNo
            lblLabRequestNHSNo.Text = sNHSNo

            'Fields used in Photos Report
            'NameLabel2.Text = NameLabel.Text
            'DobLabel2.Text = DobLabel.Text
            'NhsNoLabel2.Text = NhsNoLabel.Text
            'CaseNoteNoLabel2.Text = CaseNoteNoLabel.Text
            'AddressLabel2.Text = AddressLabel.Text
            ProcedureDateLabel2.Text = ProcedureDateLabel.Text

            'Fields used in Patient Copy Report
            'NameLabel3.Text = NameLabel.Text
            'DobLabel3.Text = DobLabel.Text
            'NhsNoLabel3.Text = NhsNoLabel.Text
            'CaseNoteNoLabel3.Text = CaseNoteNoLabel.Text
            'AddressLabel3.Text = AddressLabel.Text
            ProcedureDateLabel3.Text = ProcedureDateLabel.Text

            'Fields used in Lab Request Report
            NhsNoLabel4.Text = NhsNoLabel.Text
            CaseNoteNoLabel4.Text = CaseNoteNoLabel.Text
            If HospitalLabel.Text.ToLower <> "not available" And HospitalLabel.Text.ToLower <> "not specified" Then
                HospitalLabel4.Text = HospitalLabel.Text
                TRLabReferringHospital.Visible = True
            Else
                TRLabReferringHospital.Visible = False
            End If

            PopulatePatientExtraInfo()

            ProcedureDateLabel4.Text = ProcedureDateLabel.Text
            GenderLabel.Text = CStr(dtPat.Rows(0)("Gender"))
            SurnameLabel.Text = CStr(dtPat.Rows(0)("Surname"))
            ForenameLabel.Text = CStr(dtPat.Rows(0)("Forename"))
            AddressLabel4.Text = AddressLabel.Text
            ' GPLabel4.Text = GPLabel.Text
            GPAddressLabel4.Text = GPAddressLabel.Text
            'DOBAgeLabel.Text = CDate(dtPat.Rows(0)("DateOfBirth")).ToString("dd MMM yyyy") & " (" & Utilities.GetAgeAtDate(CDate(dtPat.Rows(0)("DateOfBirth")), CDate(dtPat.Rows(0)("ProcedureDate").Substring(0, dtPat.Rows(0)("ProcedureDate").IndexOf("(") - 1))) & ")"
            If StatusLabel.Text <> "" Then
                PatientStatusWardLabel.Text = StatusLabel.Text
                If WardLabel.Text <> "" Then
                    PatientStatusWardLabel.Text = PatientStatusWardLabel.Text & " (" & WardLabel.Text & ")"
                End If
            End If
            If ReferringConsultantLabel.Text.ToLower = "not available" Or ReferringConsultantLabel.Text = "" Then
                TRLabReferringConsultant.Visible = False
            Else
                ReferringConsultantLabel4.Text = ReferringConsultantLabel.Text
                TRLabReferringConsultant.Visible = True
            End If
            'ReferringConsultantLabel2.Text = GetEndoscopistName()' ReferringConsultantLabel4.Text
        End If

        PopulatePatientExtraInfo()
        SummaryListView.DataBind()
        SummaryListViewRightSide.DataBind()
        'populateAlert()
        SummaryListView4.DataBind()

        ApplyPrintOptions()

        diagimg.Src = HttpContext.Current.Session("ImgBase64")
        diagimg4.Src = HttpContext.Current.Session("ImgBase64")
        Using lm As New AuditLogManager
            lm.WriteActivityLog(EVENT_TYPE.Print, "Print report for Procedure ID: " & procedureId)
        End Using
    End Sub

    'Private Sub populateAlert()
    '    Dim thera As New Therapeutics
    '    Dim AlertText As String = thera.GetNPSAalert(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
    '    Dim alertDiv As HtmlTableRow = DirectCast(SummaryListView.FindControl("alertDiv"), HtmlTableRow)
    '    If Not IsNothing(AlertText) AndAlso AlertText.Trim <> "" Then
    '        DirectCast(SummaryListView.FindControl("NpsaAlertLabel"), Literal).Text = AlertText
    '        Dim urlalert As String = HttpContext.Current.Request.Url.AbsoluteUri.Replace(HttpContext.Current.Request.Url.PathAndQuery, "") + "/Images/warning-24x24.png"
    '        DirectCast(SummaryListView.FindControl("AlertImage"), HtmlImage).Src = urlalert
    '        If Not alertDiv Is Nothing Then alertDiv.Visible = True
    '    Else
    '        If Not alertDiv Is Nothing Then alertDiv.Visible = False
    '    End If

    'End Sub

    Private Sub PopulatePatientExtraInfo()
        Dim dtPatExtra As DataTable = DataAdapter.GetPrintReport(PrintParams.ProcedureId, "GPD", PrintParams.EpisodeNo, PrintParams.PatientComboId, PrintParams.ProcedureTypeId, PrintParams.ColonType)
        If Not IsNothing(dtPatExtra) AndAlso dtPatExtra.Rows.Count > 0 Then
            If PriorityLabel.Text = "" Or PriorityLabel.Text = "Not available" Then
                PriorityLabel.Text = GetFieldValue(dtPatExtra, "Priority")
            End If
            If StatusLabel.Text = "" Or StatusLabel.Text = "Not available" Then
                StatusLabel.Text = GetFieldValue(dtPatExtra, "PatientStatus")
            End If
            Dim hname = GetFieldValue(dtPatExtra, "RefHosp")
            If hname <> "" And hname.ToLower <> "not available" And hname.ToLower <> "not specified" Then
                HospitalLabel.Text = hname
                TRReferringHospital.Visible = True
            Else
                TRReferringHospital.Visible = False
            End If
            If WardLabel.Text = "" Or WardLabel.Text = "Not available" Then
                WardLabel.Text = GetFieldValue(dtPatExtra, "Ward")
            End If
            ReferringConsultantLabel.Text = GetFieldValue(dtPatExtra, "RefCons")
            If ReferringConsultantLabel.Text.ToLower = "not available" Or ReferringConsultantLabel.Text = "" Then
                ReferringConsultantLabel.Text = ""
                TRReferringConsultant.Visible = False
            End If
        End If
    End Sub

    Private Sub ApplyPrintOptions()
        If PrintParams.IncludeGPReport Then
            With PrintParams.GPReportPrintOptions
                If Not .IncludeDiagram Then
                    GPReportDiagramSection.Visible = False
                ElseIf .IncludeDiagramOnlyIfSitesExist Then
                    GPReportDiagramSection.Visible = DataAdapter.SitesExist(PrintParams.ProcedureId, PrintParams.EpisodeNo, PrintParams.ProcedureTypeId)
                End If
            End With
        End If

        If PrintParams.IncludeLabRequestReport Then
            With PrintParams.LabRequestFormPrintOptions
                LabRequestIndicationsHeadingSection.Visible = .IncludeHeading
                LabRequestIndicationsHeadingLabel.Text = .Heading

                DateTimeCollectedSection.Visible = .IncludeTimeSpecimenCollected
                LabRequestDiagramSection.Visible = .IncludeDiagram
            End With
        End If

        If PrintParams.IncludePatientCopyReport Then
            With PrintParams.PatientFriendlyReportPrintOptions
                Using db As New ERS.Data.GastroDbEntities
                    Dim dbFollowUp = db.ERS_UpperGIFollowUp.FirstOrDefault(Function(x) x.ProcedureId = PrintParams.ProcedureId)
                    FinalTextSection.Visible = .IncludeFinalText
                    FinalTextLabel.Text = .FinalText

                    'If .IncludeAdviceComments Then
                    '    PRAdviceComments.Visible = True
                    '    Dim AdviceComments As String = ""
                    '    If .IncludePreceedAdviceComments Then
                    '        AdviceComments = .PreceedAdviceComments
                    '    End If
                    '    If Not dbFollowUp Is Nothing AndAlso Not String.IsNullOrWhiteSpace(dbFollowUp.PP_PFRFollowUp) Then
                    '        PRAdviceCommentsLabel.Text = AdviceComments + " " + dbFollowUp.PP_PFRFollowUp
                    '    Else
                    '        PRAdviceComments.Visible = False
                    '    End If
                    'Else
                    '    PRAdviceComments.Visible = False
                    'End If

                    'If .IncludeNoFollowup AndAlso (Not (dbFollowUp Is Nothing) AndAlso dbFollowUp.NoFurtherFollowUp) Then
                    '    PRNoFollowUp.Visible = True
                    'Else
                    '    PRNoFollowUp.Visible = False
                    'End If

                    'Dim isBiopsy = (From spe In db.ERS_UpperGISpecimens
                    '                Join sit In db.ERS_Sites
                    '                         On spe.SiteId Equals sit.SiteId
                    '                Where sit.ProcedureId = PrintParams.ProcedureId
                    '                Select spe.Polypectomy, spe.Biopsy, spe.BrushCytology, spe.NeedleAspirate,
                    '                    spe.GastricWashing, spe.HotBiopsy, spe.Bile_PanJuice,
                    '                    spe.Urease, spe.UreaseResult).ToList()
                    'If .IncludeUreaseText And isBiopsy.Any(Function(x) x.Urease = True And x.UreaseResult = 0) Then
                    '    PRUreaseLabel.Text = .UreaseText
                    'Else
                    '    PRUrease.Visible = False
                    'End If

                    'If .IncludePolypectomyText And isBiopsy.Any(Function(x) x.Polypectomy = True) Then
                    '    PRPolypectomyLabel.Text = .PolypectomyText
                    'Else
                    '    PRPolypectomy.Visible = False
                    'End If

                    'If .IncludeAnyOtherBiopsyText And isBiopsy.Any(Function(x) x.Biopsy = True _
                    '                                                            Or x.BrushCytology = True _
                    '                                                            Or x.NeedleAspirate = True _
                    '                                                            Or x.GastricWashing = True _
                    '                                                            Or x.HotBiopsy = True _
                    '                                                            Or x.Bile_PanJuice = True
                    '                                                       ) Then
                    '    PRBiopsyLabel.Text = .OtherBiopsyText
                    'Else
                    '    PRBiopsy.Visible = False
                    'End If

                    Dim operatingHospitalId As Integer = CInt(Session("OperatingHospitalID"))

                    PatientFriendlyTextListView.DataSource = (From add In db.ERS_PrintOptionsPatientFriendlyReportAdditional
                                                              Where add.IncludeAdditionalText = True
                                                              Where add.OperatingHospitalId = operatingHospitalId
                                                              Select add.AdditionalText).ToList
                    PatientFriendlyTextListView.DataBind()
                End Using
            End With
        End If
    End Sub

    Private Function GetFieldValue(dtPatExtra As DataTable, nodeName As String) As String
        Dim val As String = "Not Available"
        Dim matches = From r In dtPatExtra.AsEnumerable()
                      Where r.Field(Of String)("NodeName").ToLower = nodeName.ToLower()
                      Select r
        If matches.Count > 0 Then
            If Not IsDBNull(matches(0)("NodeSummary")) Then
                val = CStr(matches(0)("NodeSummary"))
            End If
        End If
        Return val
    End Function

    Private Sub AscertainLabRequestPages(specimensData As DataTable)
        If specimensData.Rows.Count > 0 Then
            'Get values into the list of objects
            _labRequestPages = specimensData.AsEnumerable().Select(Function(row) New LabRequestPage With {
                    .ReportType = row.Field(Of String)("LabRequestReportName"),
                    .SpecimenKey = row.Field(Of String)("SpecimenKey")
                }).ToList()

            'Group by report type and get distinct values with comma separated string of specimen key field values
            If PrintParams.LabRequestFormPrintOptions.GroupSpecimensByDestination Then
                Dim query = From r As LabRequestPage In _labRequestPages
                            Group By DistinctReportType = r.ReportType Into Records = Group
                            Select DistinctReportType, SpecimenKeyCSV = String.Join(","c, Records.Select(Function(x) x.SpecimenKey))

                _labRequestPages = query.Select(Function(s) New LabRequestPage With {
                        .ReportType = s.DistinctReportType,
                        .SpecimenKey = s.SpecimenKeyCSV
                    }).ToList()
            End If
        End If
    End Sub

    Private Sub DeactivateSpecimenText(reportType As String, specimenKey As String)
        For Each item As ListViewDataItem In LabRequestSpecimenListView.Items

            Dim containerIdTableCell = DirectCast(item.FindControl("LabRequestSpecimenContainerIdSection"), HtmlTableCell)
            Dim containerIdTableTR = DirectCast(item.FindControl("specimensTR"), HtmlTableRow)
            Dim SpecimenTextLabel = DirectCast(item.FindControl("SpecimenTextLabel"), Label)

            If specimenKey.ToLower().Split(",").Contains(LabRequestSpecimenListView.DataKeys(item.DataItemIndex).Values("SpecimenKey").ToLower()) Then
                containerIdTableCell.Attributes.Add("class", "tickbox")
                SpecimenTextLabel.CssClass = "labRequestSpecimenTextActive"
                'SpecimenTextLabel.Text = SpecimenTextLabel.Text.Replace("for " & reportType.ToLower(), "")
                containerIdTableTR.Visible = True
            Else
                containerIdTableCell.Attributes.Add("class", "tickboxHidden")
                SpecimenTextLabel.CssClass = "labRequestSpecimenTextInactive"
                SpecimenTextLabel.Text = LabRequestSpecimenListView.DataKeys(item.DataItemIndex).Values("Specimen").ToLower()
                containerIdTableTR.Visible = False
            End If
        Next
    End Sub

#Region "Web Methods"
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Sub SaveImgBase64(ByVal base64String As String)
        HttpContext.Current.Session("ImgBase64") = base64String
    End Sub

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GenerateDiagram(ByVal procedureIdFromJS As Integer, ByVal episodeNoFromJS As Integer, ByVal procedureTypeIdFromJS As Integer, ByVal colonType As Integer, ByVal diagramNumberFromJS As Integer) As String
        Dim page As New Page()
        'Disable event validation (this is to avoid the "RegisterForEventValidation can only be called during Render()" exception)
        page.EnableEventValidation = False

        'Create the runat="server" form that must host asp.net controls
        Dim form As New HtmlForm()
        form.Name = "form1"
        page.Controls.Add(form)

        'Load the control and add it to the page's form
        Dim myDiagram As UserControls_diagram = DirectCast(page.LoadControl("~/UserControls/diagram.ascx"), UserControls_diagram)
        myDiagram.ProcedureId = procedureIdFromJS
        myDiagram.EpisodeNo = episodeNoFromJS
        myDiagram.ProcedureTypeId = procedureTypeIdFromJS
        myDiagram.ColonType = colonType
        myDiagram.DiagramNumber = diagramNumberFromJS
        myDiagram.ForPrinting = True

        form.Controls.Add(myDiagram)

        'Call RenderControl method to get the generated HTML
        Dim htmlOutput As String = RenderControlMe(page)

        Return htmlOutput
    End Function

    Private Shared Function RenderControlMe(control As Control) As String
        Dim sb As New StringBuilder()
        Dim sw As New StringWriter(sb)
        Dim writer As New HtmlTextWriter(sw)

        control.RenderControl(writer)
        Return sb.ToString()
    End Function
#End Region

    Function GetEnvironmentRoot() As String
        Dim RetValue As String = HostingEnvironment.MapPath("~")
        If RetValue.Last() <> "\" Then
            RetValue += "\"
        End If
        Return RetValue
    End Function

    Public Sub GenerateReport(save As Boolean)
        Session("ResetReportPageCounter") = False
        Session("MaxGpReportPageNumber") = 1
        Session("MaxPhotosReportPageNumber") = 1
        Session("MaxPatientCopyReportPageNumber") = 1
        Session("MaxLabRequestReportPageNumber") = 1
        'Session("LabRequestFormType") = "HISTOLOGY"

        'ReportCopyType     1   =   GPReport
        '                   2   =   PhotosReport
        '                   3   =   PatientCopyReport
        '                   4   =   LabRequestReport

        Session("ReportCopyType") = "1"

        If PrintParams.IncludePhotosReport Then
            PrintParams.IncludePhotosReport = _photosExist
        End If

        If Not PrintParams.IncludeGPReport And Not PrintParams.IncludePhotosReport And Not PrintParams.IncludePatientCopyReport And Not PrintParams.IncludeLabRequestReport Then
            'NothingToPrint()
            Return
        End If

        Dim bRepEnableNHSStyle As Boolean = CBool(RepEnableNHSStyle)

        Dim dtPat As DataTable = DataAdapter.GetPrintReportHeader(CInt(Session("OperatingHospitalID")), procedureId, CInt(Session(Constants.SESSION_EPISODE_NO)), CStr(Session(Constants.SESSION_PATIENT_COMBO_ID)), Session("PRINT_SESSION_PROCEDURE_TYPE"), bRepEnableNHSStyle)
        'Dim dtPat As DataTable = DataAdapter.GetPrintReportHeader(CInt(Session("OperatingHospitalID")))
        If dtPat.Rows.Count = 0 Then
            'NothingToPrint()
            Return
        End If

        'calculate start position base on the number of header lines
        Dim headerCount As Single = 25.0F
        If Not IsDBNull(dtPat.Rows(0)("ReportHeading")) AndAlso Not IsNothing(dtPat.Rows(0)("ReportHeading")) AndAlso dtPat.Rows(0)("ReportHeading") <> "" Then
            headerCount += 20.0F
        End If
        If Not IsDBNull(dtPat.Rows(0)("ReportTrustType")) AndAlso Not IsNothing(dtPat.Rows(0)("ReportTrustType")) AndAlso dtPat.Rows(0)("ReportTrustType") <> "" Then
            headerCount += 20.0F
        End If
        If Not IsDBNull(dtPat.Rows(0)("ReportSubHeading")) AndAlso Not IsNothing(dtPat.Rows(0)("ReportSubHeading")) AndAlso dtPat.Rows(0)("ReportSubHeading") <> "" Then
            headerCount += 20.0F
        End If
        If Not IsDBNull(dtPat.Rows(0)("ReportHeader")) AndAlso Not IsNothing(dtPat.Rows(0)("ReportHeader")) AndAlso dtPat.Rows(0)("ReportHeader") <> "" Then
            headerCount += 20.0F
        End If

        'Patient Details Header
        headerCount += 60.0F
        'If Not IsNothing(GetReportName()) AndAlso GetReportName() <> "" Then
        '    headerCount += 20.0F
        'End If

        'Dim document As New Document(PageSize.A4, 10.0F, 10.0F, 100.0F, 80.0F)
        'Dim document As New Document(PageSize.A4, Left, Right, Top, Bottom)

        Session("ReportCopyType") = "1"
        If (String.IsNullOrEmpty(dtPat.Rows(0)("LeftLogo").ToString())) Then
        Else
            If File.Exists(Server.MapPath(dtPat.Rows(0)("LeftLogo").ToString())) Then
                HeaderLeftLogoPath.ImageUrl = ResolveUrl(dtPat.Rows(0)("LeftLogo").ToString())
            Else
                HeaderLeftLogoPath.Visible = False
            End If
            'LeftLogoPath.ImageUrl = ResolveUrl(dtPat.Rows(0)("LeftLogo").ToString())
        End If

        HeaderRightLogoPath.ImageUrl = ResolveUrl("~/Images/NHS-RGB.jpg") 'C:\TFS\SE2_Dev-Nasim\UnisoftERS\Images\NHS-RGB.jpg
        HeaderTitle.Text = dtPat.Rows(0)("ReportHeader")
        Dim sb = New StringBuilder()
        divLogoAndTitle.RenderControl(New HtmlTextWriter(New StringWriter(sb)))
        ViewState("PrintReportHeader") = sb.ToString()
        sb = New StringBuilder()
        divGPRepHeader.RenderControl(New HtmlTextWriter(New StringWriter(sb)))
        ViewState("PrintReportHeader") += "<hr />" & sb.ToString() & "<hr />"
        Dim pe = New UnisoftPdfPageEvent() _
              With
              {
                  .ReportHeading = dtPat.Rows(0)("ReportHeading"),
                  .TrustType = dtPat.Rows(0)("ReportTrustType"),
                  .ReportSubHeading = dtPat.Rows(0)("ReportSubHeading"),
                  .ReportFooter = dtPat.Rows(0)("ReportFooter"),
                  .ReportName = dtPat.Rows(0)("ReportHeader"),
                  .LogoPath = HttpContext.Current.Server.MapPath("~/Images/NHS-RGB.jpg"),
                  .LeftLogoPath = IIf(String.IsNullOrEmpty(dtPat.Rows(0)("LeftLogo").ToString()), "", HttpContext.Current.Server.MapPath(dtPat.Rows(0)("LeftLogo").ToString())),
                  .PrintTimeText = GetPrintTimeText(),
                  .EndoscopistName = GetEndoscopistName(),
                  .Endoscopist2Name = GetEndoscopist2Name(),
                  .CCRefConName = GetccRefConName(),
                  .PrintOptionValues = PrintParams,
                  .PatName = PatName,
                  .PatDob = PatDob,
                  .PatNhsNo = PatNhsNo,
                  .PatCaseNoteNo = PatCaseNoteNo,
                  .PatAddress = PatAddress
              }

        If save Then

            Try
                Dim fileSaveLocation As String
                Dim deleteAfterSave As Boolean = False
                Dim blnSuppressMainReportPDF As Boolean = False
                Dim pdfExportFilePathName As String = ""
                Dim pdfFileName As String = ""
                Dim output_DocumentStoreId As Integer = 0
                Dim strDocumentStoreIdList As String = ""
                Dim PDFReportDirectoryInAzureStorage As String = ""

                pdfFileName = GetPdfFileName()
                Session("PdfReportFilename") = pdfFileName


                If ConfigurationManager.AppSettings("IsAzure").ToLower() <> "true" Then

                    fileSaveLocation = GetSaveLocation()
                    If String.IsNullOrWhiteSpace(fileSaveLocation) Then
                        fileSaveLocation = Path.Combine(GetEnvironmentRoot, "ReportTemp\")
                        deleteAfterSave = True
                    End If
                    If Not Directory.Exists(fileSaveLocation) Then Directory.CreateDirectory(fileSaveLocation)


                    pdfExportFilePathName = fileSaveLocation & "\" & pdfFileName

                    Session("PDFPathAndFileName") = pdfExportFilePathName
                    Session("PdfLocationDirectory") = fileSaveLocation

                Else 'Azure environment configured. Get Azure Blob Storage - Create report export directory in Azure Container if not exists

                    ' ***** This has been done later in this method when the PDF is actually being saved on a disk file.
                    ' *** NO Need to do anything here ***

                End If

                Using output As New MemoryStream()
                    Dim pdfDoc As New Document(PageSize.A4, 20.0F, 45.0F, headerCount, 120.0F)
                    Dim doc = PdfWriter.GetInstance(pdfDoc, output)
                    doc.CloseStream = False
                    doc.PageEvent = pe
                    buildPDF(pdfDoc, pe, doc, save)
                    Dim iLen As Integer = CInt(output.Length)
                    Dim bBLOBStorage(iLen) As Byte
                    'output.Read(bBLOBStorage, 0, iLen)
                    output.Position = 0
                    bBLOBStorage = output.ToArray()

                    Dim blnProcedureAmended As Boolean = False
                    Dim blnPrintPreview As Boolean = False
                    Dim blnPDFfileWrittentoDisk As Boolean = True 'Single flag will be used for both Azure and non-Azure environment


                    '**** 29 Mar 2022   Mahfuz added SUPPRESS MAIN REPORT PDF If it is set in configure
                    If Not IsNothing(Session(Constants.SESSION_SUPPRESS_MAIN_REPORT_PDF)) Then
                        blnSuppressMainReportPDF = Convert.ToBoolean(Session(Constants.SESSION_SUPPRESS_MAIN_REPORT_PDF))
                    End If

                    If DataAdapter.ProcedureAmended(procedureId) Then
                        blnProcedureAmended = True
                    Else
                        blnProcedureAmended = False
                    End If

                    '05 Sep 2023 : MH took below code down further where PDF save location (either in Azure or in local disk file) are available
                    'If DataAdapter.ProcedureAmended(CInt(Session("PRINT_SESSION_PROCEDURE_ID"))) Then
                    '    DataAdapter.SavePDFToDatabase(Session("PRINT_SESSION_PROCEDURE_ID"), bBLOBStorage)
                    '    'MH changed on 21 Feb 2023 - TFS 2279
                    '    'DataAdapter.SavePDFToDatabase(Session(Constants.SESSION_PROCEDURE_ID), bBLOBStorage)
                    '    If Not IsNothing(Session("DocumentStoreIdList")) Then
                    '        strDocumentStoreIdList = Session("DocumentStoreIdList")
                    '    End If
                    '    DataAdapter.InsertBlobDataToDocumentStore(Session(Constants.SESSION_PROCEDURE_ID), bBLOBStorage, Nothing, pdfExportFilePathName, fileSaveLocation, pdfFileName, 0, strDocumentStoreIdList, output_DocumentStoreId)
                    '    Session("DocumentStoreIdList") = Nothing
                    '    blnProcedureAmended = True
                    'Else
                    '    blnProcedureAmended = False
                    'End If

                    If Not IsNothing(Session("PrintPreview")) Then
                        blnPrintPreview = Convert.ToBoolean(Session("PrintPreview"))
                    Else
                        blnPrintPreview = False
                    End If

                    '**** 29 Mar 2022   Mahfuz added SUPPRESS MAIN REPORT PDF If it is set in configure
                    If Not IsNothing(Session(Constants.SESSION_SUPPRESS_MAIN_REPORT_PDF)) Then
                        blnSuppressMainReportPDF = Convert.ToBoolean(Session(Constants.SESSION_SUPPRESS_MAIN_REPORT_PDF))
                    End If

                    If Not deleteAfterSave And Not blnSuppressMainReportPDF And blnProcedureAmended And Not blnPrintPreview Then
                        Session("PrintPreview") = False

                        'If not in Azure, then save the pdf file to disk - either on network or local machine 
                        'Save the PDF to a file
                        If ConfigurationManager.AppSettings("IsAzure").ToLower() <> "true" Then
                            'Writing to disk file in non-azure environment in a try block
                            Try
                                output.Position = 0
                                Using fileOutput As New FileStream(pdfExportFilePathName, FileMode.Create)
                                    output.CopyTo(fileOutput)
                                    output.Flush()
                                End Using
                            Catch ex As Exception
                                LogManager.LogManagerInstance.LogError("Error occurred while submitting report - PDF writing to disk", ex)
                                blnPDFfileWrittentoDisk = False
                            End Try

                        Else
                            'If it is in Azure - check if PDF saving in Azure config are provided
                            If DataAdapter.GetIsExportPdfInAzureStorage(Session("OperatingHospitalID")) Then
                                PDFReportDirectoryInAzureStorage = DataAdapter.GetPDFReportDirectoryInAzureStorage(Session("OperatingHospitalID"))
                                If String.IsNullOrEmpty(PDFReportDirectoryInAzureStorage) Then
                                    PDFReportDirectoryInAzureStorage = "reports"
                                Else
                                    PDFReportDirectoryInAzureStorage = PDFReportDirectoryInAzureStorage.ToLower() 'Azure File Share directory does not support Upper case
                                End If

                                'Keeping writing PDF to Azure file share in a Try Catch - so that error here will let GPEmail Module and Outbound Mirth channel to continue
                                Try
                                    Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureFileStorageAccount"))
                                    Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
                                    Dim share As CloudFileShare = fileClient.GetShareReference(PDFReportDirectoryInAzureStorage)
                                    Dim msXmlDoc As New MemoryStream()

                                    share.CreateIfNotExists()

                                    Dim cfd As CloudFileDirectory = share.GetRootDirectoryReference()
                                    Dim objCloudFile As CloudFile = cfd.GetFileReference(pdfFileName + ".pdf")

                                    output.Position = 0

                                    objCloudFile.Create(output.Length)
                                    objCloudFile.UploadFromStream(output)

                                    pdfExportFilePathName = objCloudFile.Uri.AbsoluteUri.ToString()
                                    fileSaveLocation = pdfExportFilePathName.Replace(pdfFileName + ".pdf", "")

                                    Session("PDFPathAndFileName") = pdfExportFilePathName
                                    Session("PdfLocationDirectory") = fileSaveLocation

                                Catch exinner As Exception
                                    LogManager.LogManagerInstance.LogError("Error occurred while saving the report on Azure File Share!!", exinner)
                                    blnPDFfileWrittentoDisk = False
                                End Try
                            End If
                        End If
                    End If

                    If DataAdapter.ProcedureAmended(procedureId) Then
                        'DataAdapter.SavePDFToDatabase(Session("PRINT_SESSION_PROCEDURE_ID"), bBLOBStorage) 'NO MORE REQUIRED - Using below InsertBlobDataToDocumentStore instead.
                        'MH changed on 21 Feb 2023 - TFS 2279
                        'DataAdapter.SavePDFToDatabase(Session(Constants.SESSION_PROCEDURE_ID), bBLOBStorage)
                        If Not IsNothing(Session("DocumentStoreIdList")) Then
                            strDocumentStoreIdList = Session("DocumentStoreIdList")
                        End If
                        DataAdapter.InsertBlobDataToDocumentStore(Session(Constants.SESSION_PROCEDURE_ID), bBLOBStorage, Nothing, pdfExportFilePathName, fileSaveLocation, pdfFileName, 0, strDocumentStoreIdList, blnPDFfileWrittentoDisk, output_DocumentStoreId)
                        Session("DocumentStoreIdList") = Nothing
                    End If

                End Using


                'Keeping Email sent GP Email section in try block  to let following code execute in case of error
                Try
                    Dim emailSent As DataAccess = New DataAccess
                    If ConfigurationManager.AppSettings("GPModuleActive").ToLower() = "true" Then
                        If emailSent.CheckEmailCanBeCreated(patientId) = True Then
                            If emailSent.CreateEmail() = True Then
                                Utilities.SetNotificationStyle(RadNotification1)
                                RadNotification1.Show()
                            End If
                        End If
                    End If
                Catch ex As Exception
                    LogManager.LogManagerInstance.LogError("Error occurred while submitting report - in GP Email sent section", ex)
                End Try


                'Using output As New FileStream(pdfExportFilePathName, FileMode.Create)
                '    Dim pdfDoc As New Document(PageSize.A4, 20.0F, 45.0F, headerCount, 120.0F)
                '    Dim doc = PdfWriter.GetInstance(pdfDoc, output)
                '    doc.PageEvent = pe
                '    buildPDF(pdfDoc, pe, doc, save)
                'End Using

                'Using output As New FileStream(pdfExportFilePathName, FileMode.Open)
                '    Dim iLen As Integer = CInt(output.Length)
                '    Dim bBLOBStorage(iLen) As Byte
                '    output.Read(bBLOBStorage, 0, iLen)
                '    DataAdapter.SavePDFToDatabase(Session(Constants.SESSION_PROCEDURE_ID), bBLOBStorage)
                'End Using

                Try
                    'insert entry into OCS table
                    'build string
                    CheckPatientId()
                    If IsNothing(fileSaveLocation) Then
                        fileSaveLocation = "NO_DISK_FILE"
                    End If
                    Dim oruSTR = "ORU|" & patientId & "||" & procedureId & "|" & IIf(deleteAfterSave, "", Path.Combine(fileSaveLocation, pdfExportFilePathName)) & "|" & "PDF|0"
                    DataAdapter.insertOCSRecord(oruSTR)
                Catch ex As Exception
                    'need to notify someone if this doesn't save!
                    Dim errorLogRef As String
                    errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while submitting the report!!", ex)

                    Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There was a problem submitting your report.")
                    RadNotification1.Show()
                End Try

            Catch ex As Exception
                Dim errorLogRef As String
                errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving the report!!", ex)

                Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There was a problem saving your report.")
                RadNotification1.Show()
            End Try



        Else
            Using outputStream As New MemoryStream()
                Dim document As New Document(PageSize.A4, 20.0F, 45.0F, headerCount, 120.0F)
                Dim w = PdfWriter.GetInstance(document, outputStream)
                w.PageEvent = pe
                buildPDF(document, pe, w, save)
                'Session("outputStream") = outputStream.GetBuffer()
                Dim pdfFileName As String = GetPdfFileName()
                Dim operatingHospitalId As Integer = CInt(Session("OperatingHospitalID"))
                Dim db As New ERS.Data.GastroDbEntities
                Dim rPrintType As Short = If((From p In db.ERS_PrintOptionsGPReport
                                              Where p.OperatingHospitalId = operatingHospitalId
                                              Select p.PrintType).FirstOrDefault(), 0)

                If rPrintType = 1 Then
                    Dim tempFilesDirectory As String = Server.MapPath("~/Reports")

                    Dim reportPdfUrl As String = ResolveUrl("~/Reports/" + pdfFileName)
                    If Directory.Exists(tempFilesDirectory) <> True Then
                        ' Create the directory if it doesn't exist
                        Directory.CreateDirectory(tempFilesDirectory)
                    End If
                    ' Save the PDF file as a temporary file on the server
                    Dim tempFilePath As String = Path.Combine(tempFilesDirectory, pdfFileName)
                    File.WriteAllBytes(tempFilePath, outputStream.GetBuffer())
                    Session("PrintReportData") = CType(Session("PrintReportData"), String).Replace("{{ReportPdfUrl}}", reportPdfUrl)
                    HttpContext.Current.Session("ReportPdfUrl") = reportPdfUrl
                    Session("outputStreamName") = tempFilePath
                    'Clear the response buffer
                    System.Web.HttpContext.Current.Response.Clear()
                    'Set the output type as HTML
                    System.Web.HttpContext.Current.Response.ContentType = "text/html"
                    'Disable caching'
                    System.Web.HttpContext.Current.Response.AddHeader("Expires", "0")
                    System.Web.HttpContext.Current.Response.AddHeader("Cache-Control", "")
                    System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", "inline; filename=""" & pdfFileName & """")
                    'Set the length of the file so the browser can display an accurate progress bar
                    System.Web.HttpContext.Current.Response.AddHeader("Content-length", Session("PrintReportData").Length.ToString())
                    'Write the HTML content
                    System.Web.HttpContext.Current.Response.Write(Session("PrintReportData"))

                    'Close the response stream
                    HttpContext.Current.Response.Flush() ' Sends all currently buffered output to the client.
                HttpContext.Current.Response.SuppressContent = True ' Gets or sets a value indicating whether to send HTTP content to the client.
                HttpContext.Current.ApplicationInstance.CompleteRequest() ' Causes ASP.NET to bypass all events and filtering in the HTTP pipeline chain of execution and directly execute the EndRequest event.
                ElseIf rPrintType = 0 Then
                'Clear the response buffer
                System.Web.HttpContext.Current.Response.Clear()
                'Set the output type as a PDF
                System.Web.HttpContext.Current.Response.ContentType = "application/pdf"
                'Disable caching'
                System.Web.HttpContext.Current.Response.AddHeader("Expires", "0")
                System.Web.HttpContext.Current.Response.AddHeader("Cache-Control", "")
                'Set the filename'
                System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", "inline; filename=""" & pdfFileName & """")
                'Set the length of the file so the browser can display an accurate progress bar
                System.Web.HttpContext.Current.Response.AddHeader("Content-length", outputStream.GetBuffer().Length.ToString())
                'Write the contents of the memory stream
                System.Web.HttpContext.Current.Response.OutputStream.Write(outputStream.GetBuffer(), 0, outputStream.GetBuffer().Length)

                'Close the response stream
                'System.Web.HttpContext.Current.Response.End()
                HttpContext.Current.Response.Flush() ' Sends all currently buffered output to the client.
                HttpContext.Current.Response.SuppressContent = True ' Gets or sets a value indicating whether to send HTTP content to the client.
                HttpContext.Current.ApplicationInstance.CompleteRequest() ' Causes ASP.NET to bypass all events and filtering in the HTTP pipeline chain of execution and directly execute the EndRequest event.
                End If


        'DirectCast(LoadControl("~/UserControls/PrintInitiate.ascx"), PrintInitiate).DownloadPdfInBrowser()
        ''Clear the response buffer
        'System.Web.HttpContext.Current.Response.Clear()
        ''Set the output type as a PDF
        'System.Web.HttpContext.Current.Response.ContentType = "application/pdf"
        ''Disable caching'
        'System.Web.HttpContext.Current.Response.AddHeader("Expires", "0")
        'System.Web.HttpContext.Current.Response.AddHeader("Cache-Control", "")
        ''Set the filename'
        'System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", "inline; filename=""" & GetPdfFileName() & """")
        ''Set the length of the file so the browser can display an accurate progress bar
        'System.Web.HttpContext.Current.Response.AddHeader("Content-length", outputStream.GetBuffer().Length.ToString())
        ''Write the contents of the memory stream
        ''System.Web.HttpContext.Current.Response.OutputStream.Write(outputStream.GetBuffer(), 0, outputStream.GetBuffer().Length)
        'Context.Response.TransmitFile(tempFilePath)
        ''Close the response stream
        ''System.Web.HttpContext.Current.Response.End()
        'HttpContext.Current.Response.Flush() ' Sends all currently buffered output to the client.
        'HttpContext.Current.Response.SuppressContent = True ' Gets or sets a value indicating whether to send HTTP content to the client.
        'HttpContext.Current.ApplicationInstance.CompleteRequest() ' Causes ASP.NET to bypass all events and filtering in the HTTP pipeline chain of execution and directly execute the EndRequest event.
        End Using

        Dim dtImagePorts = DataAdapter.GetProceduresImagePort(procedureId)
        Dim portId = If(dtImagePorts.Rows.Count = 0, 0, CInt(dtImagePorts.Rows(0)("ImagePortId")))

        'if delete media move photos to temp folder (do here inside of the print/display section so is only run once, on final call)
        If PrintParams.DeleteMedia AndAlso ConfigurationManager.AppSettings("IsAzure").ToLower() <> "true" Then
            If Directory.Exists(CacheFolderPath) Then
                'get image port name to determine prefix for files that need moving                  
                If dtImagePorts.Rows.Count > 0 AndAlso CInt(dtImagePorts.Rows(0)("ImagePortId")) > 0 Then
                    Dim searchPatterns() As String = {"*.jpg", "*.bmp", "*.jpeg", "*.gif", "*.png", "*.tiff", "*.mp4", "*.mpg", "*.mov", "*.wmv", "*.flv", "*.avi", "*.mpeg"}
                    For Each searchPattern As String In searchPatterns
                        Dim imgFiles = Directory.GetFiles(CacheFolderPath, searchPattern)
                        For Each img In imgFiles
                            If Not img.Contains("ERS_" & procedureId & "_" & ConfigurationManager.AppSettings("Unisoft.HospitalID") & "_" & Session("OperatingHospitalID") & "_" & Session(Constants.SESSION_PROCEDURE_TYPE) & "_" & portId.ToString()) Then Continue For 'skip image if not got the correct prefix

                            Dim fi As New FileInfo(img)
                            Dim newFilePath = Path.Combine(TempPhotosFolderPath, fi.Name)
                            If File.Exists(newFilePath) Then File.Delete(newFilePath)
                            File.Move(img, newFilePath)
                        Next
                    Next
                End If
            End If
        End If
        If Not DataAdapter.IsProcedurePrinted(procedureId) Then
            If ConfigurationManager.AppSettings("IsAzure").ToLower() <> "true" Then
                Using lm As New AuditLogManager
                    lm.WriteActivityLog(EVENT_TYPE.Print, "Deleting files from ImagePort Share: " & procedureId)
                End Using
                Dim sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & Session("PortName")
                If Not Directory.Exists(sourcePath) Then Exit Sub

                Dim di As New DirectoryInfo(sourcePath)
                Dim fiArr As FileInfo() = di.GetFiles()
                For Each fil As FileInfo In fiArr
                    If fil.Extension = ".bmp" OrElse fil.Extension = ".jpg" OrElse fil.Extension = ".mp4" Then
                        If Not Directory.Exists(TempPhotosFolderPath) Then Directory.CreateDirectory(TempPhotosFolderPath)
                        If File.Exists(TempPhotosFolderPath & "\" & fil.Name) Then
                            File.Delete(TempPhotosFolderPath & "\" & fil.Name)
                        End If
                        File.Move(fil.FullName, TempPhotosFolderPath & "\" & fil.Name)
                    Else
                        File.Delete(fil.FullName)
                    End If
                Next
            End If
        End If
        DataAdapter.SetReportPrinted(procedureId)
        End If
    End Sub
    <WebMethod()>
    Public Shared Function DeleteGeneratedPdfFile()
        Dim url As String = HttpContext.Current.Session("ReportPdfUrl").ToString()
        Dim serverPath As String = System.Web.HttpContext.Current.Server.MapPath(url)
        If File.Exists(serverPath) Then
            File.Delete(serverPath)
        End If
    End Function
    Sub buildPDF(document As Document, pageEvent As UnisoftPdfPageEvent, output As PdfWriter, save As Boolean)
        Dim htmlText As String

        'Open the PDF for writing
        document.Open()
        Dim LastPageNumber As Integer = 0, AddBlankPage As Integer = 0
        Dim jqueryScript As String = "
<script src='https://code.jquery.com/jquery-3.6.0.min.js'></script>
<script>
$(document).ready(function() {
  var fileUrl = '{{ReportPdfUrl}}';
    // Logic to download PDF
  function downloadFile(fileUrl) {
        var a = $('<a />', {
          href: fileUrl,
          download: '', // This attribute will make the browser download the file instead of navigating to it
          style: 'display: none;' // Hide the anchor element
        }).appendTo('body');
        
        // Programmatically click the anchor to trigger the download
        a[0].click();
        
        // Remove the anchor element from the document
        a.remove();

        
   }
    //downloadFile(fileUrl);
});
</script>
"
        Dim reportFooter As String = "<div id=""RpFooter"" style=""margin-bottom:40px;"">
            <hr/>
                <table class=""mainTable printFontBasic"" cellpadding=""0"" cellspacing=""0"" style=""table-layout:fixed;padding-left: 20px ;"">
                    <tr>
                        <td colspan=""1"">" & "Produced by Solus Endoscopy Tool (v" & HttpContext.Current.Session(Constants.SESSION_APPVERSION) & ")" & "<br/>" & GetPrintTimeText() & "</td>
                        <td colspan=""1"" align=""center"">
                            {{PageNumber}}
                        </td>
                        <td colspan=""1"">
                        </td>
                    </tr>                   
                </table>
            <hr/>
        </div>"
        Dim labsignature As String = ""
        If pageEvent.PrintOptionValues.Endo1Sig AndAlso pageEvent.PrintOptionValues.Endo2Sig Then
            labsignature = "Signature _________________________ " & "<br/>" & pageEvent.EndoscopistName.Replace(vbCrLf, "<br/>") & "<br/>" & "<br/>" & "Signature _________________________ " & "<br/>" & pageEvent.Endoscopist2Name
            'footerTableCell3 = New PdfPCell(New Phrase("Signature _________________________ " & vbCrLf & EndoscopistName & vbCrLf & vbCrLf & "Signature _________________________ " & vbCrLf & Endoscopist2Name, fontMed9NormalBlack))
        ElseIf pageEvent.PrintOptionValues.Endo1Sig AndAlso Not pageEvent.PrintOptionValues.Endo2Sig Then
            labsignature = "Signature _________________________ " & "<br/>" & pageEvent.EndoscopistName.Replace(vbCrLf, "<br/>")
            'footerTableCell3 = New PdfPCell(New Phrase("Signature _________________________ " & vbCrLf & EndoscopistName, fontMed9NormalBlack))
        ElseIf Not pageEvent.PrintOptionValues.Endo1Sig AndAlso pageEvent.PrintOptionValues.Endo2Sig Then
            labsignature = "Signature _________________________ " & "<br/>" & pageEvent.Endoscopist2Name.Replace(vbCrLf, "<br/>")
            'footerTableCell3 = New PdfPCell(New Phrase("Signature _________________________ " & vbCrLf & Endoscopist2Name, fontMed9NormalBlack))
        End If
        Dim labreportFooter As String = "<div id=""LbRpFooter"" style=""margin-bottom:40px;"">
            <hr/>
                <table class=""mainTable printFontBasic"" cellpadding=""0"" cellspacing=""0"" style=""table-layout:fixed;padding-left: 20px ;"">
                    <tr>
                        <td colspan=""2"">" & "Produced by Solus Endoscopy Tool. Call 01279 358 400 if modifications to this form/layout are required." & "</td>
                        <td colspan=""1"" align=""center"">
                            {{PageNumber}}
                        </td>
                        <td colspan=""2"" align=""right"">" & labsignature & "
                        </td>
                    </tr>                  
                </table>
            <hr/>
        </div>"


        Dim emailSentToGpAndConsultantFlagMessage = CType(HttpContext.Current.Session("EmailSentToGpAndConsultantFlagMessage"), String)
        Dim RptFooterConsultant As String = ""
        If pageEvent.PrintOptionValues.Endo1Sig AndAlso pageEvent.PrintOptionValues.Endo2Sig Then
            RptFooterConsultant = "_________________________" & "<br/>" & pageEvent.EndoscopistName & "<br/>" & pageEvent.Endoscopist2Name & "<br/>" & "{{CCRefConName}}"
            'footerTableCell1 = New PdfPCell(New Phrase(pageEvent.EndoscopistName, fontMed10NormalBlack))
            'footerTableCell12 = New PdfPCell(New Phrase(pageEvent.Endoscopist2Name, fontMed10NormalBlack))
            'footerTableCell1_1 = New PdfPCell(New Phrase(pageEvent.EndoscopistName, fontMed10NormalBlack))
            'footerTableCell12_2 = New PdfPCell(New Phrase(pageEvent.Endoscopist2Name + vbCrLf + vbCrLf + vbCrLf + emailSentToGpAndConsultantFlagMessage, fontMed10NormalBlack))
        ElseIf pageEvent.PrintOptionValues.Endo1Sig AndAlso Not pageEvent.PrintOptionValues.Endo2Sig Then
            'RptFooterConsultant = pageEvent.EndoscopistName
            RptFooterConsultant = "_________________________" & "<br/>" & pageEvent.EndoscopistName & "<br/>" & "{{CCRefConName}}"
        ElseIf Not pageEvent.PrintOptionValues.Endo1Sig AndAlso pageEvent.PrintOptionValues.Endo2Sig Then
            'RptFooterConsultant = pageEvent.Endoscopist2Name
            RptFooterConsultant = "_________________________" & "<br/>" & pageEvent.Endoscopist2Name & "<br/>" & "{{CCRefConName}}"
        Else
            RptFooterConsultant = "{{CCRefConName}}"
        End If
        If Trim(pageEvent.CCRefConName) <> "" Then
            'footerTable.AddCell(footerTableCell1)
            'footerTable.AddCell(footerTableCell12)
            'footerTable.AddCell(footerTableCell1a)
            RptFooterConsultant = RptFooterConsultant.Replace("{{CCRefConName}}", "c.c. " & pageEvent.CCRefConName & If(emailSentToGpAndConsultantFlagMessage.Length > 0, "_________________________" & "<br/>" & emailSentToGpAndConsultantFlagMessage, ""))
        Else
            RptFooterConsultant = RptFooterConsultant.Replace("{{CCRefConName}}", emailSentToGpAndConsultantFlagMessage)
            'footerTable.AddCell(footerTableCell1_1)
            'footerTable.AddCell(footerTableCell12_2)
        End If
        Dim FooterConsultantSignature As String = "<div id=""LbRpConsultantSignature"" style=""margin-bottom:40px;"">            
                <table class=""mainTable printFontBasic"" cellpadding=""0"" cellspacing=""0"" style=""table-layout:fixed;padding-left: 20px ;"">
                    <tr>
                        <td colspan=""2""></td>
                        <td colspan=""1"" align=""center""></td>
                        <td colspan=""2"" align=""right"">" & RptFooterConsultant.Replace(vbCrLf, "<br/>") & "
                        </td>
                    </tr>                  
                </table>
        </div>"
        Dim tagProcessors = DirectCast(Tags.GetHtmlTagProcessorFactory(), DefaultTagProcessorFactory)
        tagProcessors.RemoveProcessor(HTML.Tag.IMG)

        'Remove the default processor and use our new processor
        tagProcessors.AddProcessor(HTML.Tag.IMG, New CustomImageTagProcessor())

        'iTextSharp.text.FontFactory.Register("c:\windows\fonts\cambria.ttc", "Segoe UI")

        Dim htmlContext = New HtmlPipelineContext(Nothing)

        'For img embed
        htmlContext.SetAcceptUnknown(True).AutoBookmark(True).SetTagFactory(tagProcessors)

        Dim cssResolver As ICSSResolver = XMLWorkerHelper.GetInstance().GetDefaultCssResolver(False)
        cssResolver.AddCssFile(HttpContext.Current.Server.MapPath("~/Styles/PrintReport.css"), True)

        Dim pipeline = New CssResolverPipeline(cssResolver, New HtmlPipeline(htmlContext, New PdfWriterPipeline(document, output)))
        Dim worker = New XMLWorker(pipeline, True)
        Dim p = New XMLParser(worker)
        Dim sb = New StringBuilder()
        Dim headerSection As String = "<html xmlns='http://www.w3.org/1999/xhtml'><head><link type='text/css' href='../../Styles/Site.css' rel='stylesheet' /> <link type='text/css' href='../../Styles/PrintReport.css' rel='stylesheet' /><style type='text/css'>.DischargeToGp{width:20px !important;}#divGPRepHeader{padding-left:20px;}.mainTable:after{border:none;}.PhotoImageWidth{width:385px !important;}#GPReportDiv{padding-left: 20px;}.textalignright{text-align: right;}#PatientCopyReportDiv{padding-left: 20px;}#NodeSummaryTD{padding-left: 5px;}</style>" + jqueryScript + "</head><body style='width:799px;'>"
        Session("PrintReportData") = ""
        'MAIN REPORT
        Dim GPReportCopies = 0
        If PrintParams.IncludeGPReport Or save Then
            'GPReportCopies = If(save, 1, PrintParams.GPReportPrintOptions.DefaultNumberOfCopies)
            If save Then
                GPReportCopies = 1
            ElseIf String.IsNullOrEmpty(Request.QueryString("GPCopies")) Then
                GPReportCopies = PrintParams.GPReportPrintOptions.DefaultNumberOfCopies
            Else
                GPReportCopies = Request.QueryString("GPCopies")
            End If
            If save And Not PrintParams.GPReportPrintOptions.DefaultExportImage Then
                GPPhotosListView.Visible = False
            End If


            sb = New StringBuilder()

            Session("ReportCopyType") = "1"

            GPReportDiv.RenderControl(New HtmlTextWriter(New StringWriter(sb)))
            htmlText = sb.ToString().Replace("</br>", "<br />")
            htmlText = htmlText.Replace("<br>", "<br />")
            htmlText = htmlText.Replace("/*", "&#47;&#42;")
            'htmlText = htmlText.Replace("&", "&amp;")

            'Little explination of what the regex below does
            'pattern & (?!(?:[a-zA-Z]{2,6}|#[0-9]{1,4}|#x[0-9A-Fa-f]{1,4});):
            '   & matches the literal ampersand.
            '   (?!(?:[a-zA-Z]{2,6}|#[0-9]{1,4}|#x[0-9A-Fa-f]{1,4});) Is a negative lookahead that ensures the & Is Not followed by
            '       a-zA - Z{2, 6}: a sequence Of 2 To 6 alphabetic characters (e.g., & lt;, & amp;).
            '       #[0-9]{1,4}: a numeric character reference (e.g., &#1234;).
            '       #x[0-9A-Fa-f]{1,4}: a hexadecimal character reference (e.g., &#x1F4A9;).
            Dim pattern As String = "&(?!(?:[a-zA-Z]{2,6}|#[0-9]{1,4}|#x[0-9A-Fa-f]{1,4});)"
            htmlText = Regex.Replace(htmlText, pattern, "&amp;")

            htmlText = htmlText.Replace("<br /.", "<br />")
            htmlText = htmlText.Replace("<div style=""padding-left:8%;"">", "") 'edited by mostafiz 3565
            htmlText = htmlText.Replace("</div>.", "") 'edited by mostafiz 3565 
            htmlText = htmlText.Replace("&amp;nbsp;", "&nbsp;")
            LastPageNumber = LastPageNumber + 1
            Session("PrintReportData") = Session("PrintReportData") + "<div style='min-height:1124px;'>" + ViewState("PrintReportHeader") + htmlText + FooterConsultantSignature + "</div>" + reportFooter.Replace("{{PageNumber}}", "Page " & LastPageNumber & " of {{LastPageNumber}}")
            For i As Integer = 0 To GPReportCopies - 1
                If save And i = 1 Then Exit For 'because we only want 1 copy of the PDF to save

                Using srHtml = New MemoryStream(Encoding.UTF8.GetBytes(htmlText)) ' 4378
                    p.Parse(srHtml)
                End Using

                'Always add a new page after report is done, irrespective of whether there will be a next report - this is to get the accurate page number
                document.NewPage()

                'MH added on 12 Oct 2021
                Session("ResetReportPageCounter") = True
                AddBlankPage += 1
            Next
        End If
        If Not PrintParams.IncludeGPReport Then document.NewPage()

        'MH added on 12 Oct 2021
        Session("ResetReportPageCounter") = True

        'pageEvent.GPReportPageCount = GPReportCopies 'output.PageNumber - 1
        pageEvent.GPReportPageCount = Session("MaxGpReportPageNumber")

        'PHOTOS REPORT
        Dim PhotosCopies = 0
        If (save And PrintParams.GPReportPrintOptions.DefaultExportImage) Or (Not save And PrintParams.IncludePhotosReport) Then
            Session("ReportCopyType") = "2"
            'PhotosCopies = If(save, 1, PrintParams.GPReportPrintOptions.DefaultNumberOfPhotos)
            If String.IsNullOrEmpty(Request.QueryString("PhotosCopies")) OrElse Request.QueryString("PhotosCopies") = "undefined" Then
                PhotosCopies = PrintParams.GPReportPrintOptions.DefaultNumberOfPhotos
            Else
                PhotosCopies = Request.QueryString("PhotosCopies")
            End If
            LastPageNumber = LastPageNumber + 1
            For i As Integer = 0 To PhotosCopies - 1

                sb = New StringBuilder()
                PhotosReportDiv.RenderControl(New HtmlTextWriter(New StringWriter(sb)))
                htmlText = sb.ToString()
                htmlText = htmlText.Replace("&amp;nbsp;", "&nbsp;")
                Session("PrintReportData") = Session("PrintReportData") + "<div style='min-height:1124px;'>" + ViewState("PrintReportHeader") + htmlText + FooterConsultantSignature + "</div>" + reportFooter.Replace("{{PageNumber}}", "Page " & LastPageNumber & " of {{LastPageNumber}}")
                Using srHtml = New MemoryStream(Encoding.UTF8.GetBytes(htmlText))
                    p.Parse(srHtml)
                End Using

                'Always add a new page after report is done, irrespective of whether there will be a next report - this is to get the accurate page number
                document.NewPage()

                'MH added on 12 Oct 2021
                Session("ResetReportPageCounter") = True
                AddBlankPage += 1
            Next

        End If

        If Not PrintParams.IncludePhotosReport And Not save Then document.NewPage() 'Only do this if previous print report hasn't been generated as new page would've already been called

        'MH added on 12 Oct 2021
        Session("ResetReportPageCounter") = True

        pageEvent.PhotosReportPageCount = PhotosCopies 'output.PageNumber - 1 - pageEvent.GPReportPageCount

        'PATIENT COPY REPORT
        Dim PatientCopyCopies = 0
        If Not save AndAlso PrintParams.IncludePatientCopyReport Then

            'PatientCopyCopies = PrintParams.PatientFriendlyReportPrintOptions.DefaultNumberOfCopies
            If String.IsNullOrEmpty(Request.QueryString("PatientCopies")) Then
                PatientCopyCopies = PrintParams.PatientFriendlyReportPrintOptions.DefaultNumberOfCopies
            Else
                PatientCopyCopies = Request.QueryString("PatientCopies")
            End If
            LastPageNumber = LastPageNumber + 1
            For i As Integer = 0 To PatientCopyCopies - 1
                Session("ReportCopyType") = "3"
                sb = New StringBuilder()
                PatientCopyReportDiv.RenderControl(New HtmlTextWriter(New StringWriter(sb)))
                htmlText = sb.ToString()
                htmlText = htmlText.Replace("&amp;nbsp;", "&nbsp;")
                Session("PrintReportData") = Session("PrintReportData") + "<div style='min-height:1124px;'>" + ViewState("PrintReportHeader") + htmlText + "</div>" + reportFooter.Replace("{{PageNumber}}", "Page " & LastPageNumber & " of {{LastPageNumber}}")
                htmlText = htmlText.Replace("/Images/Rectangle.png", Server.MapPath("~/Images/Rectangle.png"))
                htmlText = htmlText.Replace("/Images/CheckedRectangle.png", Server.MapPath("~/Images/CheckedRectangle.png"))
                Using srHtml = New MemoryStream(Encoding.UTF8.GetBytes(htmlText))
                    p.Parse(srHtml)
                End Using

                'Always add a new page after report is done, irrespective of whether there will be a next report - this is to get the accurate page number
                document.NewPage()
                'MH added on 12 Oct 2021
                Session("ResetReportPageCounter") = True
                AddBlankPage += 1
            Next

        End If

        If Not PrintParams.IncludePatientCopyReport And Not save Then document.NewPage() 'Only do this if previous print report hasn't been generated as new page would've already been called
        pageEvent.PatientCopyReportPageCount = PatientCopyCopies 'output.PageNumber - 1 - pageEvent.GPReportPageCount - pageEvent.PhotosReportPageCount

        'Change the margins for Lab Request report as no header/footer required
        If Not save AndAlso PrintParams.IncludeLabRequestReport Then
            'MH changed on 15 Oct 2021 - Making header space for Patient demographics
            'document.SetMargins(10.0F, 10.0F, 10.0F, 40.0F)
            document.SetMargins(10.0F, 10.0F, 35.0F, 40.0F)
        End If
        HttpContext.Current.Session("RemoveFooterOfLabReport") = False
        If AddBlankPage Mod 2 <> 0 And pageEvent.PrintOptionValues.GPReportPrintOptions.PrintDoubleSided = True Then
            document.NewPage()
            Dim rectangle As New iTextSharp.text.Rectangle(document.PageSize)
            rectangle.BackgroundColor = iTextSharp.text.BaseColor.WHITE
            document.Add(rectangle)
            HttpContext.Current.Session("RemoveFooterOfLabReport") = True
        End If
        'LAB REQUEST FORM REPORT
        If Not save AndAlso PrintParams.IncludeLabRequestReport Then
            document.NewPage()

            'MH added on 12 Oct 2021
            Session("ResetReportPageCounter") = True

            Dim LabRequestCopies
            If String.IsNullOrEmpty(Request.QueryString("LabCopies")) Then
                LabRequestCopies = PrintParams.LabRequestFormPrintOptions.DefaultNumberOfCopies
            Else
                LabRequestCopies = Request.QueryString("LabCopies") 'PrintParams.LabRequestFormPrintOptions.DefaultNumberOfCopies
            End If
            LastPageNumber = LastPageNumber + 1
            For j As Integer = 0 To LabRequestCopies - 1
                Session("ReportCopyType") = "4"
                Dim i As Integer = 1
                For Each lrPage In _labRequestPages
                    'MH changed on 15 Oct 2021 - Making header space for Patient demographics
                    'document.SetMargins(10.0F, 10.0F, 10.0F, 40.0F)
                    document.SetMargins(10.0F, 10.0F, 35.0F, 40.0F)

                    diagimg4.Src = HttpContext.Current.Session("ImgBase64")
                    LabRequestHeader.Text = lrPage.ReportType.ToUpper()
                    If LabRequestHeader.Text = "CYTOLOGY" Then
                        LabRequestHeader.Style.Add("Color", "#AF8F6F")
                    ElseIf LabRequestHeader.Text = "MICROBIOLOGY" Then
                        LabRequestHeader.Style.Add("Color", "#85586F")
                    ElseIf LabRequestHeader.Text = "VIROLOGY" Then
                        LabRequestHeader.Style.Add("Color", "#738598")
                    Else
                        LabRequestHeader.Style.Add("Color", "#4888a2")
                    End If

                    Session("LabRequestFormType") = lrPage.ReportType.ToUpper()

                    DeactivateSpecimenText(lrPage.ReportType, lrPage.SpecimenKey)
                    'If PrintParams.LabRequestFormPrintOptions.RequestsPerA4Page = 2 AndAlso i Mod 2 = 0 Then
                    '   LabRequestFormFooterSection.Visible = False
                    'Else
                    '   LabRequestFormFooterSection.Visible = True
                    'End If

                    sb = New StringBuilder()
                    LabRequestDiv.RenderControl(New HtmlTextWriter(New StringWriter(sb)))
                    'htmlText = sb.ToString()
                    htmlText = sb.ToString().Replace("</br>", "<br />")
                    htmlText = htmlText.Replace("<=", "&lt;=")
                    htmlText = htmlText.Replace("/.", "/>")
                    htmlText = htmlText.Replace("&amp;nbsp;", "&nbsp;")
                    Session("PrintReportData") = Session("PrintReportData") + "<div style='min-height:1124px;'>" + htmlText + "</div>" + labreportFooter.Replace("{{PageNumber}}", "Page " & LastPageNumber & " of {{LastPageNumber}}")
                    Using srHtml = New MemoryStream(Encoding.UTF8.GetBytes(htmlText))
                        p.Parse(srHtml)
                    End Using

                    If PrintParams.LabRequestFormPrintOptions.RequestsPerA4Page = 2 Then
                        If i Mod 2 = 0 Then
                            document.NewPage()
                            'MH added on 12 Oct 2021
                            Session("ResetReportPageCounter") = True
                        End If
                    Else
                        document.NewPage()
                        'MH added on 12 Oct 2021
                        Session("ResetReportPageCounter") = True
                    End If
                    If i > 1 Then
                        AddBlankPage += 1
                    End If
                    i = i + 1
                Next
                AddBlankPage += 1
            Next

        End If

        'If Not PrintParams.PreviewOnly Then
        '    Dim jAction2 As PdfAction = If(save, New PdfAction(PdfAction.FIRSTPAGE), New PdfAction(PdfAction.PRINTDIALOG))
        '    output.SetOpenAction(jAction2)
        'End If


        'Close the PDF
        Try
            document.Close()
        Catch
        End Try


        Session("PrintReportData") = CType(Session("PrintReportData"), String).Replace("{{LastPageNumber}}", LastPageNumber.ToString())
        Session("PrintReportData") = CType(Session("PrintReportData"), String).Replace("border-left: 23px; border-color: white", "")
        Session("PrintReportData") = CType(Session("PrintReportData"), String).Replace("width: 105%;", "width:93%;")
        Session("PrintReportData") = CType(Session("PrintReportData"), String).Replace("padding-left: 20px;", "")
        Session("PrintReportData") = CType(Session("PrintReportData"), String).Replace("padding-left: 5px;", "")
        'Session("PrintReportData") = CType(Session("PrintReportData"), String).Replace("&amp;nbsp;", "&nbsp;")
        Session("PrintReportData") = headerSection + Session("PrintReportData") + "</body>"
        'padding-left: 20px ;
    End Sub
    Protected Overrides Sub RedirectToLoginPage()
        _redirectToLoginPage = True
    End Sub

    Private Sub NothingToPrint()
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "blankpdf", "alert('Nothing to print!');", True)
    End Sub

    Private Function GetSaveLocation() As String
        Return DataAdapter.GetPDFExportLocation(CInt(Session("OperatingHospitalId")))
    End Function

    Private Function GetPrintTimeText() As String
        'Return "Printed on " & DateTime.Now.ToString("dd/MM/yyyy") & " at " & DateTime.Now.ToString("HH:mm")
        Dim sCompiledOn As String = ""
        If _dtPatRD Is Nothing Then
            _dtPatRD = DataAdapter.GetPrintReport(PrintParams.ProcedureId, "RD", PrintParams.EpisodeNo, PrintParams.PatientComboId, PrintParams.ProcedureTypeId, PrintParams.ColonType)
        End If

        Dim matches = From r In _dtPatRD.AsEnumerable()
                      Where r.Field(Of String)("NodeName").ToLower = "compiledon"
                      Select r
        If matches.Count > 0 Then
            If Not IsDBNull(matches(0)("NodeSummary")) Then
                sCompiledOn = CStr(matches(0)("NodeSummary"))
            End If
        End If
        Return "Compiled on " & sCompiledOn
    End Function

    Private Function GetEndoscopistName() As String
        Dim name As String = "Endoscopist"
        If _dtPatRD Is Nothing Then
            _dtPatRD = DataAdapter.GetPrintReport(PrintParams.ProcedureId, "RD", PrintParams.EpisodeNo, PrintParams.PatientComboId, PrintParams.ProcedureTypeId, PrintParams.ColonType)
        End If

        Dim matches = From r In _dtPatRD.AsEnumerable()
                      Where r.Field(Of String)("NodeName").ToLower = "endo1"
                      Select r
        If matches.Count > 0 Then
            If Not IsDBNull(matches(0)("NodeSummary")) Then
                name = CStr(matches(0)("NodeSummary"))
            End If
        End If
        Return name
    End Function

    Private Function GetEndoscopist2Name() As String
        Dim name As String = "Endoscopist"
        If _dtPatRD Is Nothing Then
            _dtPatRD = DataAdapter.GetPrintReport(PrintParams.ProcedureId, "RD", PrintParams.EpisodeNo, PrintParams.PatientComboId, PrintParams.ProcedureTypeId, PrintParams.ColonType)
        End If

        Dim matches = From r In _dtPatRD.AsEnumerable()
                      Where r.Field(Of String)("NodeName").ToLower = "endo2"
                      Select r
        If matches.Count > 0 Then
            If Not IsDBNull(matches(0)("NodeSummary")) Then
                name = CStr(matches(0)("NodeSummary"))
            End If
        End If
        Return name
    End Function

    Private Function GetccRefConName() As String
        'Dim name As String = "CC Ref Con"
        Dim name As String = ""
        If _dtPatRD Is Nothing Then
            _dtPatRD = DataAdapter.GetPrintReport(PrintParams.ProcedureId, "RD", PrintParams.EpisodeNo, PrintParams.PatientComboId, PrintParams.ProcedureTypeId, PrintParams.ColonType)
        End If

        Dim sCCfield(3) As String
        sCCfield(2) = "ccrefcons"
        sCCfield(3) = "ccother"
        sCCfield(1) = "ccpatient"

        For i As Integer = 1 To 3
            Dim matches = From r In _dtPatRD.AsEnumerable()
                          Where r.Field(Of String)("NodeName").ToLower = sCCfield(i)
                          Select r
            If matches.Count > 0 Then
                If Not IsDBNull(matches(0)("NodeSummary")) Then
                    name += CStr(matches(0)("NodeSummary")) & IIf(i <= 3 And Trim(CStr(matches(0)("NodeSummary"))) <> "", "; ", "") & vbCrLf
                End If
            End If
        Next

        'edited by mostafiz 3891
        Dim PP_GPName As String = DataAdapter.GetPP_GPName(PrintParams.ProcedureId)
        If Not String.IsNullOrEmpty(PP_GPName) Then
            name += PP_GPName & vbCrLf
        End If

        'edited by mostafiz 3891

        Return name
    End Function

    Private Function GetPdfFileName() As String
        CheckPatientId()
        'Mahfuz changed ProcedureID to ProcedureName in file name on 28 July 2021
        Dim ProcedureName As String = ""
        Dim da_sch As New DataAccess_Sch
        ProcedureName = da_sch.GetProcedureTypeName(procedureId)

        'Dim fname As String = Session(Constants.SESSION_CASE_NOTE_NO) & "_" & Now.ToString("dd-MM-yyy") & "_" & Now.ToString("HH-mm-ss") & "_" & Session(Constants.SESSION_PROCEDURE_TYPE) & "_" & Session(Constants.SESSION_PROCEDURE_ID)
        Dim fname As String = ""
        'MH changes made on 04 Jul 2024 - TFS 4196 - Revmoing illegal characters, forward slash ( / ) from CaseNoteNo / HospitalNo 
        Dim TrimmedCaseNoteNo As String = ""

        TrimmedCaseNoteNo = Session(Constants.SESSION_CASE_NOTE_NO)
        For Each c In Path.GetInvalidFileNameChars()
            TrimmedCaseNoteNo = TrimmedCaseNoteNo.Replace(c, "").Trim()
        Next

        fname = TrimmedCaseNoteNo & "_" & Now.ToString("dd-MM-yyy") & "_" & Now.ToString("HH-mm-ss") & "_" & ProcedureName & "_" & Session(Constants.SESSION_PROCEDURE_ID)

        If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.XML_and_Main_PDF Or
            Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.XML_and_HTML Then
            fname = "GIOLJG" + patientId.ToString().PadLeft(6, "0") + "_" + Session(Constants.SESSION_PROCEDURE_TYPE).ToString() + "_" + Session(Constants.SESSION_PROCEDURE_ID).ToString().PadLeft(6, "0")
        End If

        If Not fname.EndsWith(".pdf") Then fname = fname & ".pdf"

        Return fname
    End Function

    Private Sub CheckPatientId()
        Dim patientIdFromDB As Integer
        patientIdFromDB = DataAdapter.GetPatientIdFromProcedureId(Session(Constants.SESSION_PROCEDURE_ID))

        ' If we have lost the session patientId, get it back
        'If IsNothing(Session(Constants.SESSION_PATIENT_ID)) OrElse String.IsNullOrEmpty(Session(Constants.SESSION_PATIENT_ID)) OrElse Session(Constants.SESSION_PATIENT_ID) = 0 Then
        '    Session(Constants.SESSION_PATIENT_ID) = patientIdFromDB
        'End If

        ' Somehow, it could be the DB has lost the patient ID
        If patientIdFromDB = 0 And Session(Constants.SESSION_PROCEDURE_ID) <> 0 Then
            'Update the db with the session patient id
            DataAdapter.SetPatientIdFromProcedureId(Session(Constants.SESSION_PROCEDURE_ID), patientId)
        End If

        ' Now, what do we do if they are all missing!?
        'If (IsNothing(Session(Constants.SESSION_PATIENT_ID)) OrElse String.IsNullOrEmpty(Session(Constants.SESSION_PATIENT_ID)) OrElse Session(Constants.SESSION_PATIENT_ID) = 0) And patientIdFromDB = 0 Then
        '    'We have a major problem here, we have a procedure that is being printed, but we don't have a patient for the procedure
        '    Dim ex As Exception = New Exception("Unable to find patient information")
        '    Dim errorLogRef As String
        '    errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred - Patinet missing!!", ex)

        '    Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There was a problem saving your report.")
        '    RadNotification1.Show()
        'End If

        If (IsNothing(patientId) And patientIdFromDB = 0) Then
            'We have a major problem here, we have a procedure that is being printed, but we don't have a patient for the procedure
            Dim ex As Exception = New Exception("Unable to find patient information")
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred - Patinet missing!!", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There was a problem saving your report.")
            RadNotification1.Show()
        End If
    End Sub
End Class

Public Class LabRequestPage
    Private _ReportType As String
    Public Property ReportType() As String
        Get
            Return _ReportType
        End Get
        Set(ByVal value As String)
            _ReportType = value
        End Set
    End Property

    Private _SpecimenKey As String
    Public Property SpecimenKey() As String
        Get
            Return _SpecimenKey
        End Get
        Set(ByVal value As String)
            _SpecimenKey = value
        End Set
    End Property
End Class

Public Class CustomImageTagProcessor
    Inherits iTextSharp.tool.xml.html.Image

    Public Overrides Function [End](ctx As IWorkerContext, tag As Tag, currentContent As IList(Of IElement)) As IList(Of IElement)
        Dim attributes As IDictionary(Of String, String) = tag.Attributes
        Dim src As String = ""

        If Not attributes.TryGetValue(HTML.Attribute.SRC, src) Then
            Return New List(Of IElement)(1)
        End If

        If String.IsNullOrEmpty(src) Then
            Return New List(Of IElement)(1)
        End If

        If src.StartsWith("data:image/", StringComparison.InvariantCultureIgnoreCase) Then
            ' data:[<MIME-type>][;charset=<encoding>][;base64],<data>
            Dim base64Data = src.Substring(src.IndexOf(",") + 1)
            Dim imagedata = Convert.FromBase64String(base64Data)
            Dim image = iTextSharp.text.Image.GetInstance(imagedata)

            Dim list = New List(Of IElement)()
            Dim htmlPipelineContext = GetHtmlPipelineContext(ctx)
            list.Add(GetCssAppliers().Apply(New Chunk(DirectCast(GetCssAppliers().Apply(image, tag, htmlPipelineContext), iTextSharp.text.Image), 0, 0, True), tag, htmlPipelineContext))
            Return list
        Else
            Return MyBase.[End](ctx, tag, currentContent)
        End If
    End Function
End Class

Public Class UnisoftPdfPageEvent
    Inherits PdfPageEventHelper

#Region "Declarations"
    Private cb As PdfContentByte
    Private headerTemplate As PdfTemplate
    Private footerTemplate1 As PdfTemplate
    Private footerTemplate2 As PdfTemplate
    Private footerTemplate3 As PdfTemplate
    Private footerTemplate4 As PdfTemplate
    Private sigTemplate() As PdfTemplate
    Private bf As BaseFont = Nothing
    Private _printTimeText As String
    Private _reportHeading As String
    Private _reportExportPath As String
    Private _trustType As String
    Private _reportSubHeading As String
    Private _reportName As String
    Private _logoPath As String
    Private _leftLogoPath As String
    Private _endoscopistName As String
    Private _endoscopist2Name As String
    Private _ccRefConName As String
    Private _compiledOn As String
    Private _gpReportPageCount As Integer = -1 '-1 means not set
    Private _photosReportPageCount As Integer = -1 '-1 means not set
    Private _patientCopyReportPageCount As Integer = -1 '-1 means not set

    'MH added on 12 Oct 2021
    Private _intCurrentReportPage As Integer
    Private _intMaxReportPageCounter As Integer


    Private _PatName As String
    Private _PatDob As String
    Private _PatNhsNo As String
    Private _PatCaseNoteNo As String
    Private _PatAddress As String

    Private _printoptions As PrintOptions

    Private pageNumberCells As New List(Of PdfPCell)

    Private fontBigBoldBlack As New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 16.0F, iTextSharp.text.Font.BOLD, iTextSharp.text.BaseColor.BLACK)
    Private fontBig14BoldBlack As New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 14.0F, iTextSharp.text.Font.BOLD, iTextSharp.text.BaseColor.BLACK)
    Private fontMedBoldBlack As New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 12.0F, iTextSharp.text.Font.BOLD, iTextSharp.text.BaseColor.BLACK)
    Private fontMedNormalBlack As New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 12.0F, iTextSharp.text.Font.NORMAL, iTextSharp.text.BaseColor.BLACK)
    Private fontMed10BoldBlack As New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 10.0F, iTextSharp.text.Font.BOLD, iTextSharp.text.BaseColor.BLACK)
    Private fontMed10NormalBlack As New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 10.0F, iTextSharp.text.Font.NORMAL, iTextSharp.text.BaseColor.BLACK)
    Private fontSmallNormalBlack As New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 8.0F, iTextSharp.text.Font.NORMAL, iTextSharp.text.BaseColor.BLACK)
    Private fontMed9BoldBlack As New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 9.0F, iTextSharp.text.Font.BOLD, iTextSharp.text.BaseColor.BLACK)
    Private fontMed9NormalBlack As New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 9.0F, iTextSharp.text.Font.NORMAL, iTextSharp.text.BaseColor.BLACK)
    Private fontBigBoldCyan As iTextSharp.text.Font = FontFactory.GetFont(iTextSharp.text.Font.FontFamily.HELVETICA, 16.0F, iTextSharp.text.Font.BOLD, New iTextSharp.text.BaseColor(72, 136, 162))
    Private fontMedBoldBlue As iTextSharp.text.Font = FontFactory.GetFont(iTextSharp.text.Font.FontFamily.HELVETICA, 14.0F, iTextSharp.text.Font.BOLD, New iTextSharp.text.BaseColor(0, 114, 198))
#End Region

#Region "Properties"
    Public Property PrintOptionValues() As PrintOptions
        Get
            Return _printoptions
        End Get
        Set(value As PrintOptions)
            _printoptions = value
        End Set
    End Property

    Public Property ReportExportPath() As String
        Get
            Return _reportExportPath
        End Get
        Set(value As String)
            _reportExportPath = value
        End Set
    End Property

    Public Property ReportHeading() As String
        Get
            Return _reportHeading
        End Get
        Set(value As String)
            _reportHeading = value
        End Set
    End Property

    Public Property TrustType() As String
        Get
            Return _trustType
        End Get
        Set(value As String)
            _trustType = value
        End Set
    End Property

    Public Property ReportSubHeading() As String
        Get
            Return _reportSubHeading
        End Get
        Set(value As String)
            _reportSubHeading = value
        End Set
    End Property

    Public Property ReportFooter() As String

    Public Property ReportName() As String
        Get
            Return _reportName
        End Get
        Set(value As String)
            _reportName = value
        End Set
    End Property

    Public Property LogoPath() As String
        Get
            Return _logoPath
        End Get
        Set(value As String)
            _logoPath = value
        End Set

    End Property

    Public Property LeftLogoPath() As String
        Get
            Return _leftLogoPath
        End Get
        Set(value As String)
            _leftLogoPath = value
        End Set

    End Property

    Public Property PrintTimeText() As String
        Get
            Return _printTimeText
        End Get
        Set(value As String)
            _printTimeText = value
        End Set
    End Property

    Public Property EndoscopistName() As String
        Get
            Return _endoscopistName
        End Get
        Set(value As String)
            _endoscopistName = value
        End Set
    End Property

    Public Property Endoscopist2Name() As String
        Get
            Return _endoscopist2Name
        End Get
        Set(value As String)
            _endoscopist2Name = value
        End Set
    End Property

    Public Property CCRefConName() As String
        Get
            Return _ccRefConName
        End Get
        Set(value As String)
            _ccRefConName = value
        End Set
    End Property

    Public Property CompiledOn() As String
        Get
            Return _compiledOn
        End Get
        Set(value As String)
            _compiledOn = value
        End Set
    End Property

    Public Property GPReportPageCount() As Integer
        Get
            Return _gpReportPageCount
        End Get
        Set(value As Integer)
            _gpReportPageCount = value
        End Set
    End Property
    Public Property CurrentReportPageNumber() As Integer
        Get
            Return _intCurrentReportPage
        End Get
        Set(value As Integer)
            _intCurrentReportPage = value
        End Set
    End Property
    Public Property MaxReportPageNumber() As Integer
        Get
            Return _intMaxReportPageCounter
        End Get
        Set(value As Integer)
            _intMaxReportPageCounter = value
        End Set
    End Property

    Public Property PhotosReportPageCount() As Integer
        Get
            Return _photosReportPageCount
        End Get
        Set(value As Integer)
            _photosReportPageCount = value
        End Set
    End Property

    Public Property PatientCopyReportPageCount() As Integer
        Get
            Return _patientCopyReportPageCount
        End Get
        Set(value As Integer)
            _patientCopyReportPageCount = value
        End Set
    End Property
    Public ReadOnly Property RepEnableNHSStyle As String
        Get
            Return ConfigurationManager.AppSettings("Unisoft.RepEnableNHSStyle")
        End Get
    End Property
    Public Property PatName() As String
        Get
            Return _PatName
        End Get
        Set(value As String)
            _PatName = value
        End Set
    End Property
    Public Property PatDob() As String
        Get
            Return _PatDob
        End Get
        Set(value As String)
            _PatDob = value
        End Set
    End Property
    Public Property PatNhsNo() As String
        Get
            Return _PatNhsNo
        End Get
        Set(value As String)
            _PatNhsNo = value
        End Set
    End Property
    Public Property PatCaseNoteNo() As String
        Get
            Return _PatCaseNoteNo
        End Get
        Set(value As String)
            _PatCaseNoteNo = value
        End Set
    End Property
    Public Property PatAddress() As String
        Get
            Return _PatAddress
        End Get
        Set(value As String)
            _PatAddress = value
        End Set
    End Property

#End Region

#Region "Events"
    Public Overrides Sub OnOpenDocument(writer As PdfWriter, document As Document)
        bf = BaseFont.CreateFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED)
        cb = writer.DirectContent
        headerTemplate = cb.CreateTemplate(100, 100)
        footerTemplate1 = cb.CreateTemplate(50, 75)
        footerTemplate2 = cb.CreateTemplate(50, 75)
        footerTemplate3 = cb.CreateTemplate(50, 75)
        footerTemplate4 = cb.CreateTemplate(50, 75)
    End Sub
    Public Const marginConst As Single = 20.0F

    Public Overrides Sub OnEndPage(writer As iTextSharp.text.pdf.PdfWriter, document As iTextSharp.text.Document)
        MyBase.OnEndPage(writer, document)

        'Do this only for main report, photos report and patient friendly report
        If GPReportPageCount = -1 Or PhotosReportPageCount = -1 Or PatientCopyReportPageCount = -1 Then

            WriteHeader(writer, document)

            'Draw line to separate header section from rest of page
            DrawLine(marginConst, document.PageSize.Width - marginConst, document.PageSize.Height - (headerHeight + marginConst))

            'DrawLine(marginConst, document.PageSize.Width - marginConst, document.PageSize.Height - (headerHeight + marginConst))

            'Do this only for main report and photos report
            If GPReportPageCount = -1 Or PhotosReportPageCount = -1 Then
                'Draw line for the signature of consultant just above the footer
                If _printoptions.Endo1Sig AndAlso _printoptions.Endo2Sig Then
                    DrawLine(400, 550, document.PageSize.GetBottom(140))
                    DrawLine(400, 550, document.PageSize.GetBottom(58))
                ElseIf _printoptions.Endo1Sig AndAlso Not _printoptions.Endo2Sig Then
                    DrawLine(400, 550, document.PageSize.GetBottom(140))
                ElseIf Not _printoptions.Endo1Sig AndAlso _printoptions.Endo2Sig Then
                    DrawLine(400, 550, document.PageSize.GetBottom(140))
                End If

                'Consultant name and designation

                WriteFooterConsultant(writer, document)
                WriteFooter(writer, document)
            Else
                'Patient friendly report
                'WriteFooterWithoutSignature(writer, document)
                WriteFooter(writer, document)
            End If
            'Draw line to separate footer section from rest of page
            DrawLine(marginConst, document.PageSize.Width - marginConst, document.PageSize.GetBottom(15 + 10))


            WritePageNumber(writer, document)
        Else
            If HttpContext.Current.Session("RemoveFooterOfLabReport") = False Then
                'Only for Lab request report - from 2nd page and onwards
                If HttpContext.Current.Session("ReportCopyType") = 4 Then
                    If HttpContext.Current.Session("ResetReportPageCounter") = False Then
                        WritePatientDemographicsOnHeader(writer, document)
                    End If
                End If

                WritePageNumber(writer, document) 'MH added on 13 Oct 2021

                WriteLabFooter(writer, document)
            End If
            HttpContext.Current.Session("RemoveFooterOfLabReport") = False
        End If
    End Sub
    'Public Overrides Sub OnStartPage(writer As PdfWriter, document As Document)
    '    MyBase.OnStartPage(writer, document)
    '    Dim strTextContext As String
    '    strTextContext = "Patient Name"

    '    'Only for Lab request report - from 2nd page and onwards
    '    If HttpContext.Current.Session("ReportCopyType") = 4 Then
    '        If HttpContext.Current.Session("ResetReportPageCounter") = False Then
    '            Dim pdfContByte As PdfContentByte = writer.DirectContent

    '            pdfContByte.BeginText()
    '            pdfContByte.SetFontAndSize(bf, 8)
    '            pdfContByte.SetTextMatrix(0, 0)
    '            pdfContByte.ShowText(strTextContext)
    '            pdfContByte.EndText()
    '        End If
    '    End If

    'End Sub
    Public Overrides Sub OnCloseDocument(writer As PdfWriter, document As Document)
        MyBase.OnCloseDocument(writer, document)
        '12 Oct 2021 : MH changes for Report Page number

        'GPReport pages
        If PrintOptionValues.IncludeGPReport Then
            'Consultant name and designation (on the last page only)
            'Dim i As Integer
            'WriteFooterConsultant(sigTemplate(i), document)

            'WriteFooterPageCount(footerTemplate1, GPReportPageCount)
            WriteFooterPageCount(footerTemplate1, HttpContext.Current.Session("MaxGpReportPageNumber"))
        End If

        'PhotoReport pages
        If PrintOptionValues.IncludePhotosReport Then
            'WriteFooterPageCount(footerTemplate2, PhotosReportPageCount)
            WriteFooterPageCount(footerTemplate2, HttpContext.Current.Session("MaxPhotosReportPageNumber"))
        End If

        'PatientCopyReport pages
        If PrintOptionValues.IncludePatientCopyReport Then
            'WriteFooterPageCount(footerTemplate3, PatientCopyReportPageCount)
            WriteFooterPageCount(footerTemplate3, HttpContext.Current.Session("MaxPatientCopyReportPageNumber"))
        End If

        'LabRequestFormReport pages
        If PrintOptionValues.IncludeLabRequestReport Then
            'WriteFooterPageCount(footerTemplate4, (writer.PageNumber - 1 - GPReportPageCount - PhotosReportPageCount - PatientCopyReportPageCount))
            WriteFooterPageCount(footerTemplate4, HttpContext.Current.Session("MaxLabRequestReportPageNumber"))
        End If
    End Sub
#End Region
    Public Property headerHeight As Single
#Region "Helper Methods"
    'MH added on 13 Oct 2021 : TFS 1665 Lap report patient demographics info on 2nd page and onwards
    Private Sub WritePatientDemographicsOnHeader(writer As iTextSharp.text.pdf.PdfWriter, document As iTextSharp.text.Document)
        'Dim headerTable As New PdfPTable(2)

        Dim widths As Single() = New Single() {document.PageSize.Width / (100 / 20) + 23, 23}
        'headerTable.SetWidths(widths)

        Dim strPatDemoContents As String = ""

        strPatDemoContents = " " + HttpContext.Current.Session("LabRequestFormType") + " Lab Request form continuing for " + PatName + " /NHS:" + PatNhsNo + " /dob:" + PatDob + " ..."
        Dim PatDetailsTable As New PdfPTable(1)
        Dim PatDetailsCellA1 As New PdfPCell(New Phrase(strPatDemoContents, fontMed9NormalBlack))

        PatDetailsCellA1.Border = 0
        PatDetailsTable.AddCell(PatDetailsCellA1)
        PatDetailsTable.TotalWidth = document.PageSize.Width
        PatDetailsTable.WidthPercentage = 100

        widths = New Single() {document.PageSize.Width}
        PatDetailsTable.SetWidths(widths)

        PatDetailsTable.WriteSelectedRows(0, -1, document.LeftMargin, document.Top + 10, writer.DirectContent)
        'headerHeight = headerTable.TotalHeight + PatDetailsTable.TotalHeight

    End Sub
    Private Sub WriteHeader(writer As iTextSharp.text.pdf.PdfWriter, document As iTextSharp.text.Document)
        Dim headerTable As New PdfPTable(2)
        Dim strNHSNoLabelText As String = "NHS No"

        If Not IsNothing(HttpContext.Current.Session(Constants.SESSION_HEALTH_SERVICE_NAME)) Then
            If HttpContext.Current.Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().Trim() <> "" Then
                strNHSNoLabelText = HttpContext.Current.Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString().ToUpper() + " No: "
            End If
        End If

        Dim logo As iTextSharp.text.Image = iTextSharp.text.Image.GetInstance(LogoPath)
        Dim combineSubHeading As String = ""
        If CBool(RepEnableNHSStyle) Then
            logo.ScalePercent(20.0F)
            logo.SetAbsolutePosition(document.PageSize.Width - logo.Width / (100 / 20) - 15, document.PageSize.Height - logo.Height / (100 / 20) - 15)
            document.Add(logo)
        End If

        If File.Exists(LeftLogoPath) Then
            Dim leftLogo As iTextSharp.text.Image = iTextSharp.text.Image.GetInstance(LeftLogoPath)
            Dim scalePercent = (55 / leftLogo.Height) * 100
            leftLogo.ScalePercent(scalePercent)
            leftLogo.SetAbsolutePosition(15, document.PageSize.Height - 70)
            document.Add(leftLogo)
        End If

        'If both TrustType & ReportSubHeading are present, display both on the same line 
        If TrustType <> "" And ReportSubHeading <> "" Then
            combineSubHeading = ReportSubHeading & " - " & TrustType
        ElseIf TrustType <> "" Then
            combineSubHeading = TrustType
        ElseIf ReportSubHeading <> "" Then
            combineSubHeading = ReportSubHeading
        End If

        Dim headerCellA1 As New PdfPCell(New Phrase(ReportHeading, fontBigBoldBlack))
        Dim headerCellB1 As New PdfPCell()
        'Dim headerCellA2 As New PdfPCell(New Phrase(TrustType, fontBig14BoldBlack))
        'Dim headerCellA3 As New PdfPCell(New Phrase(ReportSubHeading, fontMedNormalBlack))
        Dim headerCellA3 As New PdfPCell(New Phrase(combineSubHeading, fontMedNormalBlack))
        'Dim headerCellA4 As New PdfPCell(New Phrase(ReportName, fontBigBoldCyan))
        Dim headerCellA4 As New PdfPCell(New Phrase(ReportName, fontBigBoldBlack))

        'headerCellB1.AddElement(New Chunk(logo, 0, 0))

        headerCellA1.VerticalAlignment = Element.ALIGN_MIDDLE
        headerCellA1.Border = 0

        ' headerCellA1.BackgroundColor = new iTextSharp.text.BaseColor(System.Drawing.Color.FromArgb(235,235,235))

        If Not CBool(RepEnableNHSStyle) Then
            headerCellA1.HorizontalAlignment = Element.ALIGN_CENTER
            headerCellA1.Colspan = 2

            headerCellA3.HorizontalAlignment = Element.ALIGN_CENTER
            headerCellA3.VerticalAlignment = Element.ALIGN_MIDDLE
            headerCellA3.Border = 0
            headerCellA3.Colspan = 2
        Else
            headerCellA1.HorizontalAlignment = Element.ALIGN_RIGHT

            headerCellB1.HorizontalAlignment = Element.ALIGN_RIGHT
            headerCellB1.VerticalAlignment = Element.ALIGN_MIDDLE
            headerCellB1.Border = 0
            headerCellB1.Rowspan = 2

            headerCellA3.HorizontalAlignment = Element.ALIGN_RIGHT
            headerCellA3.VerticalAlignment = Element.ALIGN_MIDDLE
            headerCellA3.Border = 0
            headerCellA3.Colspan = 1
        End If

        'headerCellA2.HorizontalAlignment = Element.ALIGN_RIGHT
        'headerCellA2.VerticalAlignment = Element.ALIGN_MIDDLE
        'headerCellA2.Border = 0
        'headerCellA2.Colspan = 2



        headerCellA4.HorizontalAlignment = Element.ALIGN_CENTER
        headerCellA4.VerticalAlignment = Element.ALIGN_MIDDLE
        headerCellA4.Border = 0
        headerCellA4.Colspan = 2

        headerTable.AddCell(headerCellA1)
        If CBool(RepEnableNHSStyle) Then headerTable.AddCell(headerCellB1)
        'headerTable.AddCell(headerCellA2)

        headerTable.AddCell(headerCellA3)

        headerTable.AddCell(headerCellA4)

        'headerTable.TotalWidth = document.PageSize.Width - 80.0F
        'headerTable.WidthPercentage = 70
        headerTable.TotalWidth = document.PageSize.Width
        headerTable.WidthPercentage = 100
        'headerTable.HorizontalAlignment = Element.ALIGN_CENTER;

        Dim widths As Single() = New Single() {document.PageSize.Width - logo.Width / (100 / 20) + 23, logo.Width / (100 / 20) + 23}
        headerTable.SetWidths(widths)

        headerTable.WriteSelectedRows(0, -1, 0, (document.PageSize.Height - 20), writer.DirectContent)
        headerHeight = headerTable.TotalHeight

        DrawLine(marginConst, document.PageSize.Width - marginConst, document.PageSize.Height - (headerHeight + marginConst))

        '***---Patient Details header
        Dim PatDetailsTable As New PdfPTable(5)
        Dim PatDetailsCellA1 As New PdfPCell(New Phrase("Name:", fontMed9NormalBlack))
        Dim PatDetailsCellA2 As New PdfPCell(New Phrase(PatName, fontMed9BoldBlack))
        Dim PatDetailsCellA3 As New PdfPCell(New Phrase("", fontMed9NormalBlack))
        Dim PatDetailsCellA4 As New PdfPCell(New Phrase("Address:", fontMed9NormalBlack))
        Dim PatDetailsCellA5 As New PdfPCell(New Phrase(PatAddress, fontMed9BoldBlack))

        PatDetailsCellA4.Rowspan = 4
        PatDetailsCellA5.Rowspan = 4

        Dim PatDetailsCellA11 As New PdfPCell(New Phrase("Date of birth:", fontMed9NormalBlack))
        Dim PatDetailsCellA12 As New PdfPCell(New Phrase(PatDob, fontMed10BoldBlack))
        Dim PatDetailsCellA13 As New PdfPCell(New Phrase("", fontMed10NormalBlack))

        'MH Added on 01 Mar 2023
        Dim PatDetailsCellA21 As New PdfPCell(New Phrase(strNHSNoLabelText, fontMed9NormalBlack))
        Dim PatDetailsCellA22 As New PdfPCell(New Phrase(PatNhsNo, fontMed9BoldBlack))
        Dim PatDetailsCellA23 As New PdfPCell(New Phrase("", fontMed9NormalBlack))

        Dim PatDetailsCellA31 As New PdfPCell(New Phrase("Hospital no:", fontMed9NormalBlack))
        Dim PatDetailsCellA32 As New PdfPCell(New Phrase(PatCaseNoteNo, fontMed9BoldBlack))
        Dim PatDetailsCellA33 As New PdfPCell(New Phrase("", fontMed9NormalBlack))

        PatDetailsCellA1.Border = 0 : PatDetailsCellA2.Border = 0 : PatDetailsCellA3.Border = 0 : PatDetailsCellA4.Border = 0 : PatDetailsCellA5.Border = 0
        PatDetailsCellA11.Border = 0 : PatDetailsCellA12.Border = 0 : PatDetailsCellA13.Border = 0
        PatDetailsCellA21.Border = 0 : PatDetailsCellA22.Border = 0 : PatDetailsCellA23.Border = 0
        PatDetailsCellA31.Border = 0 : PatDetailsCellA32.Border = 0 : PatDetailsCellA33.Border = 0

        PatDetailsTable.AddCell(PatDetailsCellA1)
        PatDetailsTable.AddCell(PatDetailsCellA2)
        PatDetailsTable.AddCell(PatDetailsCellA3)
        PatDetailsTable.AddCell(PatDetailsCellA4)
        PatDetailsTable.AddCell(PatDetailsCellA5)

        PatDetailsTable.AddCell(PatDetailsCellA11)
        PatDetailsTable.AddCell(PatDetailsCellA12)
        PatDetailsTable.AddCell(PatDetailsCellA13)

        PatDetailsTable.AddCell(PatDetailsCellA21)
        PatDetailsTable.AddCell(PatDetailsCellA22)
        PatDetailsTable.AddCell(PatDetailsCellA23)

        PatDetailsTable.AddCell(PatDetailsCellA31)
        PatDetailsTable.AddCell(PatDetailsCellA32)
        PatDetailsTable.AddCell(PatDetailsCellA33)

        PatDetailsTable.TotalWidth = document.PageSize.Width - 50
        PatDetailsTable.WidthPercentage = 95

        widths = New Single() {50, 170, 10, 50, 170}
        PatDetailsTable.SetWidths(widths)

        'Writes rows from PdfWriter in PdfTable
        'First param is start row. -1 indicates there is no end row and all the rows to be included to write
        'Third and fourth param is x and y position to start writing

        'headerTable.WriteSelectedRows(0, -1, 0, document.PageSize.Height, writer.DirectContent)
        PatDetailsTable.WriteSelectedRows(0, -1, 35, document.PageSize.Height - (headerHeight + marginConst), writer.DirectContent)
        headerHeight = headerTable.TotalHeight + PatDetailsTable.TotalHeight

    End Sub

    Private Sub WriteFooter(writer As iTextSharp.text.pdf.PdfWriter, document As iTextSharp.text.Document)
        Dim footerTable As New PdfPTable(3) 'PdfPTable(New Single() {1.0F})
        Dim footerTableCell1 As New PdfPCell(New Phrase("Produced by Solus Endoscopy Tool (v" & HttpContext.Current.Session(Constants.SESSION_APPVERSION) & ")" & vbCrLf & PrintTimeText, fontSmallNormalBlack))
        'Dim footerTableCell2 As New PdfPCell(New Phrase(text + "[##]", baseFontSmall))
        Dim footerTableCell2 As New PdfPCell()
        pageNumberCells.Add(footerTableCell2)
        Dim footerTableCell3 As New PdfPCell(New Phrase(ReportFooter, fontSmallNormalBlack))
        'Dim footerTableCell3 As New PdfPCell(New Phrase("Signature _________________________ " & vbCrLf & EndoscopistName, fontSmallNormalBlack))

        footerTableCell1.Border = 0
        footerTableCell2.Border = 0
        footerTableCell3.Border = 0

        footerTableCell1.HorizontalAlignment = Element.ALIGN_LEFT
        footerTableCell2.HorizontalAlignment = Element.ALIGN_CENTER
        footerTableCell3.HorizontalAlignment = Element.ALIGN_RIGHT

        'footerTableCell1.VerticalAlignment = Element.ALIGN_BOTTOM
        'footerTableCell2.VerticalAlignment = Element.ALIGN_BOTTOM
        'footerTableCell3.VerticalAlignment = Element.ALIGN_BOTTOM

        'footerTable.TotalWidth = 300.0F
        footerTable.AddCell(footerTableCell1)
        footerTable.AddCell(footerTableCell2)
        footerTable.AddCell(footerTableCell3)

        footerTable.TotalWidth = document.PageSize.Width - 35.0F
        footerTable.WidthPercentage = 100

        footerTable.WriteSelectedRows(0, -1, 20, document.PageSize.GetBottom(15 + 10), writer.DirectContent)
    End Sub

    Private Sub WriteFooterWithoutSignature(writer As iTextSharp.text.pdf.PdfWriter, document As iTextSharp.text.Document)
        Dim footerTable As New PdfPTable(3) 'PdfPTable(New Single() {1.0F})
        Dim footerTableCell1 As New PdfPCell(New Phrase("Produced by Solus Endoscopy Tool (v" & HttpContext.Current.Session(Constants.SESSION_APPVERSION) & ")", fontSmallNormalBlack))
        'Dim footerTableCell2 As New PdfPCell(New Phrase(text + "[##]", baseFontSmall))
        Dim footerTableCell2 As New PdfPCell()
        pageNumberCells.Add(footerTableCell2)
        'Dim footerTableCell3 As New PdfPCell(New Phrase(PrintTimeText, fontSmallNormalBlack))
        Dim footerTableCell3 As New PdfPCell(New Phrase(ReportFooter, fontSmallNormalBlack))

        footerTableCell1.Border = 0
        footerTableCell2.Border = 0
        footerTableCell3.Border = 0

        footerTableCell1.HorizontalAlignment = Element.ALIGN_LEFT
        footerTableCell2.HorizontalAlignment = Element.ALIGN_CENTER
        footerTableCell3.HorizontalAlignment = Element.ALIGN_RIGHT

        'footerTableCell1.VerticalAlignment = Element.ALIGN_BOTTOM
        'footerTableCell2.VerticalAlignment = Element.ALIGN_BOTTOM
        'footerTableCell3.VerticalAlignment = Element.ALIGN_BOTTOM

        'footerTable.TotalWidth = 300.0F
        footerTable.AddCell(footerTableCell1)
        footerTable.AddCell(footerTableCell2)
        footerTable.AddCell(footerTableCell3)

        footerTable.TotalWidth = document.PageSize.Width - 35.0F
        footerTable.WidthPercentage = 100

        footerTable.WriteSelectedRows(0, -1, 20, document.PageSize.GetBottom(15 + 10), writer.DirectContent)
    End Sub

    Private Sub WriteLabFooter(writer As iTextSharp.text.pdf.PdfWriter, document As iTextSharp.text.Document)
        Dim footerTable As New PdfPTable(2) 'PdfPTable(New Single() {1.0F})
        Dim footerTableCell1 As New PdfPCell(New Phrase("Produced by Solus Endoscopy Tool. Call 01279 358 400 if modifications to this form/layout are required.", fontSmallNormalBlack))
        'Dim footerTableCell1 As New PdfPCell(New Phrase("Produced by Solus ERS Tool. For form/layout modifications, please call HD-Clinical on 01279 874 567.", fontSmallNormalBlack))
        'Dim footerTableCell2 As New PdfPCell(New Phrase(text + "[##]", baseFontSmall))
        'Dim footerTableCell2 As New PdfPCell()
        'pageNumberCells.Add(footerTableCell2)
        Dim footerTableCell3
        If _printoptions.Endo1Sig AndAlso _printoptions.Endo2Sig Then
            footerTableCell3 = New PdfPCell(New Phrase("Signature _________________________ " & vbCrLf & EndoscopistName & vbCrLf & vbCrLf & "Signature _________________________ " & vbCrLf & Endoscopist2Name, fontMed9NormalBlack))
        ElseIf _printoptions.Endo1Sig AndAlso Not _printoptions.Endo2Sig Then
            footerTableCell3 = New PdfPCell(New Phrase("Signature _________________________ " & vbCrLf & EndoscopistName, fontMed9NormalBlack))
        ElseIf Not _printoptions.Endo1Sig AndAlso _printoptions.Endo2Sig Then
            footerTableCell3 = New PdfPCell(New Phrase("Signature _________________________ " & vbCrLf & Endoscopist2Name, fontMed9NormalBlack))
        End If

        footerTableCell1.Border = 0
        'footerTableCell2.Border = 0
        footerTableCell3.Border = 0

        footerTableCell1.HorizontalAlignment = Element.ALIGN_LEFT
        'footerTableCell2.HorizontalAlignment = Element.ALIGN_CENTER
        footerTableCell3.HorizontalAlignment = Element.ALIGN_RIGHT

        'footerTableCell1.VerticalAlignment = Element.ALIGN_BOTTOM
        'footerTableCell2.VerticalAlignment = Element.ALIGN_BOTTOM
        'footerTableCell3.VerticalAlignment = Element.ALIGN_BOTTOM

        'footerTable.TotalWidth = 300.0F
        footerTable.AddCell(footerTableCell1)
        'footerTable.AddCell(footerTableCell2)
        footerTable.AddCell(footerTableCell3)

        footerTable.TotalWidth = document.PageSize.Width - 35.0F
        footerTable.WidthPercentage = 100

        footerTable.WriteSelectedRows(0, -1, 20, document.PageSize.GetBottom(35), writer.DirectContent)
    End Sub

    Private Sub WriteFooterPageCount(footerTemplate As PdfTemplate, pageCount As Integer)
        footerTemplate.BeginText()
        footerTemplate.SetFontAndSize(bf, 8)
        footerTemplate.SetTextMatrix(0, 0)
        footerTemplate.ShowText(CStr(pageCount))
        footerTemplate.EndText()
    End Sub

    Private Sub WritePageNumber(writer As iTextSharp.text.pdf.PdfWriter, document As iTextSharp.text.Document)
        Dim iPageNumber As Integer = GetCurrentPageNo(writer)
        Dim footerPageNumberText As String = "Page " + CStr(iPageNumber) + " of "
        cb.BeginText()
        cb.SetFontAndSize(bf, 8)
        cb.SetTextMatrix(document.PageSize.GetRight(300), document.PageSize.GetBottom(15))
        cb.ShowText(footerPageNumberText)
        cb.EndText()
        Dim len As Single = bf.GetWidthPoint(footerPageNumberText, 8)

        If GPReportPageCount = -1 Then
            'If GPReportPageCount is not set, it means it's running the GPReport pages
            cb.AddTemplate(footerTemplate1, document.PageSize.GetRight(300) + len, document.PageSize.GetBottom(15))

            'Add blank template on each page for Consultant name to be inserted on closing of the document (Sub OnCloseDocument)
            ReDim Preserve sigTemplate(iPageNumber)
            sigTemplate(iPageNumber) = cb.CreateTemplate(570, 100)
            cb.AddTemplate(sigTemplate(iPageNumber), document.PageSize.GetLeft(15), document.PageSize.GetBottom(28))
        ElseIf PhotosReportPageCount = -1 Then
            'PhotosReport pages
            cb.AddTemplate(footerTemplate2, document.PageSize.GetRight(300) + len, document.PageSize.GetBottom(15))
        ElseIf PatientCopyReportPageCount = -1 Then
            'PatientCopyReport pages
            cb.AddTemplate(footerTemplate3, document.PageSize.GetRight(300) + len, document.PageSize.GetBottom(15))
        Else
            'LabRequestReport pages
            cb.AddTemplate(footerTemplate4, document.PageSize.GetRight(300) + len, document.PageSize.GetBottom(15))
        End If
    End Sub

    Private Sub WriteFooterConsultant(writer As iTextSharp.text.pdf.PdfWriter, document As Document)

        ''Draw line for the signature of consultant just above the footer
        'footerTemplate.SetLineWidth(0.2F)
        'footerTemplate.MoveTo(5, document.PageSize.GetBottom(45))
        'footerTemplate.LineTo(200, document.PageSize.GetBottom(45))
        'footerTemplate.Stroke()

        Dim footerTable As New PdfPTable(1)
        Dim footerTableCell1
        Dim footerTableCell12
        Dim footerTableCell1_1
        Dim footerTableCell12_2
        '******************** To Do - get correct endoscopist

        Dim emailSentToGpAndConsultantFlagMessage = HttpContext.Current.Session("EmailSentToGpAndConsultantFlagMessage")

        If _printoptions.Endo1Sig AndAlso _printoptions.Endo2Sig Then
            footerTableCell1 = New PdfPCell(New Phrase(EndoscopistName, fontMed10NormalBlack))
            footerTableCell12 = New PdfPCell(New Phrase(Endoscopist2Name, fontMed10NormalBlack))
            footerTableCell1_1 = New PdfPCell(New Phrase(EndoscopistName, fontMed10NormalBlack))
            footerTableCell12_2 = New PdfPCell(New Phrase(Endoscopist2Name + vbCrLf + vbCrLf + vbCrLf + emailSentToGpAndConsultantFlagMessage, fontMed10NormalBlack))
        ElseIf _printoptions.Endo1Sig AndAlso Not _printoptions.Endo2Sig Then
            footerTableCell1 = New PdfPCell(New Phrase(EndoscopistName, fontMed10NormalBlack))
            footerTableCell12 = New PdfPCell(New Phrase("", fontMed10NormalBlack))
            footerTableCell1_1 = New PdfPCell(New Phrase(EndoscopistName + vbCrLf + vbCrLf + vbCrLf + emailSentToGpAndConsultantFlagMessage, fontMed10NormalBlack))
            footerTableCell12_2 = New PdfPCell(New Phrase("", fontMed10NormalBlack))
        ElseIf Not _printoptions.Endo1Sig AndAlso _printoptions.Endo2Sig Then
            footerTableCell1 = New PdfPCell(New Phrase("", fontMed10NormalBlack))
            footerTableCell12 = New PdfPCell(New Phrase(Endoscopist2Name, fontMed10NormalBlack))
            footerTableCell1_1 = New PdfPCell(New Phrase("", fontMed10NormalBlack))
            footerTableCell12_2 = New PdfPCell(New Phrase(Endoscopist2Name + vbCrLf + vbCrLf + vbCrLf + emailSentToGpAndConsultantFlagMessage, fontMed10NormalBlack))
        Else
            footerTableCell1 = New PdfPCell(New Phrase("", fontMed10NormalBlack))
            footerTableCell12 = New PdfPCell(New Phrase("", fontMed10NormalBlack))
            footerTableCell1_1 = New PdfPCell(New Phrase("", fontMed10NormalBlack))
            footerTableCell12_2 = New PdfPCell(New Phrase("", fontMed10NormalBlack))
        End If

        Dim footerTableCell1a As New PdfPCell(New Phrase("c.c. " & CCRefConName + vbCrLf + emailSentToGpAndConsultantFlagMessage, fontMed10NormalBlack))

        footerTableCell1.Border = 0
        footerTableCell12.Border = 0
        footerTableCell1_1.Border = 0
        footerTableCell12_2.Border = 0
        footerTableCell1a.Border = 0

        footerTableCell1.HorizontalAlignment = Element.ALIGN_LEFT
        footerTableCell12.HorizontalAlignment = Element.ALIGN_LEFT
        footerTableCell1_1.HorizontalAlignment = Element.ALIGN_LEFT
        footerTableCell12_2.HorizontalAlignment = Element.ALIGN_LEFT
        footerTableCell1a.HorizontalAlignment = Element.ALIGN_LEFT

        If Trim(CCRefConName) <> "" Then
            footerTable.AddCell(footerTableCell1)
            footerTable.AddCell(footerTableCell12)
            footerTable.AddCell(footerTableCell1a)
        Else
            footerTable.AddCell(footerTableCell1_1)
            footerTable.AddCell(footerTableCell12_2)
        End If

        footerTable.TotalWidth = document.PageSize.Width - 35.0F

        'footerTable.TotalWidth = footerTemplate.Width - 5
        footerTable.WidthPercentage = 50

        footerTable.WriteSelectedRows(0, -1, 400, document.PageSize.GetBottom(142), writer.DirectContent)
    End Sub

    Private Sub DrawLine(startX As Single, endX As Single, Y As Single)
        cb.SetLineWidth(0.2F)
        cb.MoveTo(startX, Y)
        cb.LineTo(endX, Y)
        cb.Stroke()
    End Sub

    Private Function GetCurrentPageNo(writer As iTextSharp.text.pdf.PdfWriter) As Integer
        '12 Oct 2021 : MH fixes page numbering. TFS Item 1675

        ''Write the page number text
        'Dim currentPageNo As Integer
        'If GPReportPageCount <> -1 And PhotosReportPageCount <> -1 And PatientCopyReportPageCount <> -1 Then
        '    currentPageNo = writer.PageNumber - GPReportPageCount - PhotosReportPageCount - PatientCopyReportPageCount
        'ElseIf GPReportPageCount <> -1 And PhotosReportPageCount <> -1 Then
        '    currentPageNo = writer.PageNumber - GPReportPageCount - PhotosReportPageCount
        'ElseIf GPReportPageCount <> -1 Then
        '    currentPageNo = writer.PageNumber - GPReportPageCount
        'Else
        '    currentPageNo = writer.PageNumber
        'End If

        If writer.PageNumber = 1 Then
            CurrentReportPageNumber = 1
            MaxReportPageNumber = 1
        ElseIf writer.PageNumber > 1 Then
            If HttpContext.Current.Session("ResetReportPageCounter") Then
                CurrentReportPageNumber = 1
                MaxReportPageNumber = 1
                HttpContext.Current.Session("ResetReportPageCounter") = False
            Else
                CurrentReportPageNumber = CurrentReportPageNumber + 1
                MaxReportPageNumber = CurrentReportPageNumber
            End If
        End If
        If HttpContext.Current.Session("ReportCopyType") = "1" Then
            HttpContext.Current.Session("MaxGpReportPageNumber") = MaxReportPageNumber
        ElseIf HttpContext.Current.Session("ReportCopyType") = "2" Then
            HttpContext.Current.Session("MaxPhotosReportPageNumber") = MaxReportPageNumber
        ElseIf HttpContext.Current.Session("ReportCopyType") = "3" Then
            HttpContext.Current.Session("MaxPatientCopyReportPageNumber") = MaxReportPageNumber
        ElseIf HttpContext.Current.Session("ReportCopyType") = "4" Then
            HttpContext.Current.Session("MaxLabRequestReportPageNumber") = MaxReportPageNumber
        End If

        Return CurrentReportPageNumber
    End Function
#End Region

    <WebMethod()>
    Public Shared Function CheckProcedurePhotos(iProcedureId As Integer)
        Using db As New ERS.Data.GastroDbEntities
            Return db.ERS_Photos.Any(Function(x) x.ProcedureId = iProcedureId)
        End Using
    End Function


End Class

