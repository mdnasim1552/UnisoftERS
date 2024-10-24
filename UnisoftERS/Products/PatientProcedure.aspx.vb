Imports Telerik.Web.UI
Imports System.Data.SqlClient
Imports System.IO
Imports System.Threading
Imports System.Web.Script.Serialization
Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.File
Imports Microsoft.WindowsAzure.Storage.Blob

Partial Class Products_PatientProcedure
    Inherits PageBase

    Private conn As SqlConnection = Nothing
    Private myReader As SqlDataReader = Nothing
    Private _AbnormalitiesDataAdapter As Abnormalities = Nothing

    Protected ReadOnly Property AbnormalitiesDataAdapter() As Abnormalities
        Get
            If _AbnormalitiesDataAdapter Is Nothing Then
                _AbnormalitiesDataAdapter = New Abnormalities
            End If
            Return _AbnormalitiesDataAdapter
        End Get
    End Property

    Protected Sub Page_Init(sender As Object, e As System.EventArgs) Handles Me.Init
        If CStr(Request.QueryString("Pg")) = "1" Then

        End If

        If Not IsPostBack Then
            'DataAdapter.LockPatientProcedures(Session("PCName"), Session("UserID"), CInt(Session(Constants.SESSION_PATIENT_ID)))
            initForm()
            'DirectCast(Me.Master.FindControl("radLeftPane"), RadPane).Width = 355
            'DirectCast(Me.Master.FindControl("radLeftPane"), RadPane).MinWidth = 350

            If CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Bronchoscopy _
                    Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.EBUS _
                    Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Thoracoscopy Then
                AccessMethodSection.Visible = True
                Scope2Section.Visible = False
            Else
                AccessMethodSection.Visible = False
                Scope2Section.Visible = True
            End If
            DeleteProcRadButton.Enabled = (DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "delete_procedure") > 0)
        End If


        'If Me.Master.FindControl("SessionTimeoutNotification") IsNot Nothing Then
        '    Dim SessionTimeoutNotification As RadNotification = DirectCast(Master.FindControl("SessionTimeoutNotification"), RadNotification)
        '    SessionTimeoutNotification.ShowInterval = (Session.Timeout - 1) * 60000
        '    SessionTimeoutNotification.Value = Page.ResolveClientUrl("~/Security/Logout.aspx")
        'End If

        'If Me.Master.FindControl("SummaryPreviewDiv") IsNot Nothing Then
        '    Dim SummaryPreviewDiv As HtmlGenericControl = DirectCast(Master.FindControl("SummaryPreviewDiv"), HtmlGenericControl)
        '    SummaryPreviewDiv.Visible = False
        'End If
        'If Me.Master.FindControl("LeftPaneContentPlaceHolderDiv") IsNot Nothing Then
        '    Dim LeftPaneContentPlaceHolderDiv As HtmlGenericControl = DirectCast(Master.FindControl("LeftPaneContentPlaceHolderDiv"), HtmlGenericControl)
        '    LeftPaneContentPlaceHolderDiv.Visible = True
        'End If

        'TestPhotosImageGallery.DataSource = DataAdapter.GetSitePhotos(1003, CInt(Session(Constants.SESSION_PROCEDURE_ID)))


        'DirectCast(procedurefooter.FindControl("cmdMainScreen"), RadButton).Visible = False
        'DirectCast(procedurefooter.FindControl("tabspace"), HtmlGenericControl).Visible = False
        'End If
        'Dim diagUserControl As UserControl = CType(Page.FindControl("SchDiagram"), UserControl)
        'PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(Flip180Button, MyLabel)

        LoadVideos()
    End Sub
    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load

        Dim PatProcAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Page)
        'PatProcAjaxMgr.EnablePageHeadUpdate = False
        'PatProcAjaxMgr.ClientEvents.OnRequestStart = "onRequestStart"
        'PatProcAjaxMgr.ClientEvents.OnResponseEnd = "onResponseEnd"
        'PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PatProcAjaxMgr, alertDiv, RadAjaxLoadingPanel1)
        PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PatProcAjaxMgr, SummaryListView, RadAjaxLoadingPanel1)
        PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PatProcAjaxMgr, PhotosListView, RadAjaxLoadingPanel1)
        PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PatProcAjaxMgr, VideosListView, RadAjaxLoadingPanel1)
        PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(VideosListView, VideosLightBox, RadAjaxLoadingPanel1)
        PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PatProcAjaxMgr, procedurefooter, RadAjaxLoadingPanel1)
        'PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(testpanel2, testpanel2, RadAjaxLoadingPanel1)

        PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(cboInstrument1, cboInstrument1, RadAjaxLoadingPanel1)
        PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(cboInstrument2, cboInstrument2, RadAjaxLoadingPanel1)
        PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(DistalAttachmentRadComboBox, DistalAttachmentRadComboBox)
        PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(AccessMethodComboBox, AccessMethodComboBox, RadAjaxLoadingPanel1)
        Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
            Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy
                PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(rbScopeGuide, rbScopeGuide, RadAjaxLoadingPanel1)
            Case ProcedureType.ERCP
                PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PancreasDivisumCheckBox, PancreasDivisumCheckBox, RadAjaxLoadingPanel1)
                PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(BiliaryCheckBox, BiliaryCheckBox, RadAjaxLoadingPanel1)
                PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PancreaticCheckBox, PancreaticCheckBox, RadAjaxLoadingPanel1)

                Dim sFirstERCP As String = DataAdapter.GetFirstERCP(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                divFirstERCP.Visible = True
                If Not sFirstERCP Is Nothing AndAlso sFirstERCP <> "" Then

                    lblFirstERCP.Text = sFirstERCP
                    lblFirstERCP.BorderColor = System.Drawing.ColorTranslator.FromHtml("#e5c365")
                    lblFirstERCP.BackColor = System.Drawing.ColorTranslator.FromHtml("#fdf4bf")
                Else
                    lblFirstERCP.BorderColor = System.Drawing.Color.White
                    lblFirstERCP.BackColor = System.Drawing.Color.White
                End If
                PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PatProcAjaxMgr, lblFirstERCP, RadAjaxLoadingPanel1)
        End Select

        ErrorNotification.Title = "HD Clinical Support Helpdesk: " & ConfigurationManager.AppSettings("Unisoft.Helpdesk")
        AddHandler PatProcAjaxMgr.AjaxRequest, AddressOf PatProcAjaxMgr_AjaxRequest

        'If procedurefooter.FindControl("cmdMainScreen") IsNot Nothing AndAlso procedurefooter.FindControl("tabspace") IsNot Nothing Then
        'If FindControlRecursive(procedurefooter, "cmdMainScreen") IsNot Nothing AndAlso FindControlRecursive(procedurefooter, "tabspace") IsNot Nothing Then
        'DirectCast(procedurefooter.FindControl("cmdMainScreen"), RadButton).Text
        'DirectCast(procedurefooter.FindControl("cmdMainScreen"), RadButton).Visible = False
        'DirectCast(procedurefooter.FindControl("tabspace"), HtmlGenericControl).Visible = False

        'DirectCast(FindControlRecursive(procedurefooter, "cmdMainScreen"), RadButton).Text = "Return to home page"
    End Sub

    'Private Sub Page_LoadComplete(sender As Object, e As EventArgs) Handles Me.LoadComplete
    '    Dim OtherMenu As RadMenuItem = DirectCast(FindControlRecursive(procedurefooter, "OtherDataMenu"), RadMenu).FindItemByValue("26")
    '    If Not IsNothing(OtherMenu) Then
    '        OtherMenu.Text = "Return to home page"
    '    End If

    'End Sub
    'Protected Sub Page_PreLoad(sender As Object, e As System.EventArgs) Handles Me.PreLoad
    '    Call uniAdaptor.IsAuthenticated()
    'End Sub

    Protected Sub initForm()
        'If Session("AdvancedMode") = True Then
        '    optAdvanced.Checked = True
        'Else
        '    optStandard.Checked = True
        'End If

        'lblCoords.Value = Session("LastXYPos")

        ' UnisoftMenu.LoadContentFile("~/App_Data/Menus/03Menu.xml")


        'Session("TitleBar") = PatientName.Text
        If Not IsPostBack Then
            If Session("NewProcedureOpen") = "1" Then

                ' Now we have to check to see if there are any images on the imageport. If there are, prompt to remove them
                ' *************************************************************************
                Dim portId As Int32
                Dim portName As String
                Dim sessionRoomId As String = Session("RoomId")

                portName = Session("portName")
                portId = Session("portId")
                'Using db As New ERS.Data.GastroDbEntities
                '    Dim dbImagePort = db.ERS_ImagePort.First(Function(x) x.RoomId = CInt(sessionRoomId))
                '    portName = dbImagePort.PortName
                '    portId = dbImagePort.ImagePortId
                'End Using

                If Not (String.IsNullOrEmpty(portName)) Then

                    Dim sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & portName
                    If Directory.Exists(sourcePath) Then

                        Dim di As New DirectoryInfo(sourcePath)
                        If di.GetFiles().Any(Function(x) x.Extension = ".jpg") OrElse di.GetFiles().Any(Function(x) x.Extension = ".bmp") Then
                            ImagesExistRadWindow.Visible = True
                            ImagesExistRadWindow.VisibleOnPageLoad = True
                            lblImageExistsMessage.Text = "Images exist on the ImagePort " & portName & ". Do you want to remove them?"
                        End If
                    End If
                End If
            End If

        Else
            ImagesExistRadWindow.Visible = False
            ImagesExistRadWindow.VisibleOnPageLoad = False
        End If


        Dim procName As String = ""
        Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
            Case ProcedureType.Gastroscopy
                procName = "Gastroscopy"
                If Session("NewProcedureOpen") = "1" Then
                    Dim sPreviousGastricUlcer As String = AbnormalitiesDataAdapter.GetPreviousGastricUlcer(CInt(Session(Constants.SESSION_PROCEDURE_ID)), True)
                    If sPreviousGastricUlcer <> "" Then
                        MessageRadWindow.Visible = True
                        MessageRadWindow.VisibleOnPageLoad = True
                        If Len(sPreviousGastricUlcer) > 45 Then MessageRadWindow.Height = "300"
                        lblPreviousGastricUlcer.Text = "The patient had a previous GASTRIC ULCER <br>in the " & sPreviousGastricUlcer & ".  </br></br> Please put a site in that area and say whether the ulcer is healing or not."
                    End If
                End If
                UpperGIDiv.Attributes.Add("Style", "display:normal")
                Dim transnasal As Boolean = DataAdapter.IsTransnasalProcedure(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                CancelledProcCheckBox.Checked = transnasal
            Case ProcedureType.ERCP
                procName = "ERCP"
                PapillaryAnatomyButtonDiv.Attributes.Add("Style", "display:normal")
                'liDiagnoses.Visible = True
            Case ProcedureType.Colonoscopy
                procName = "Colon"
                ResectedColonDiv.Attributes.Add("Style", "display:normal")
                divScopeGuide.Visible = True
                tdScopeGuide.Visible = True
            Case ProcedureType.Sigmoidscopy
                procName = "Sigmoidoscopy"
                ResectedColonDiv.Attributes.Add("Style", "display:normal")
                divScopeGuide.Visible = True
                tdScopeGuide.Visible = True
            Case ProcedureType.Proctoscopy
                procName = "Proctoscopy"
            Case ProcedureType.Bronchoscopy
                procName = "Bronchoscopy"
                'Flip180Button.Visible = True
                MarkAreaButton.Visible = False
                'radContentPane.ContentUrl = "~/Products/Broncho/OtherData/Pathology.aspx"
            Case ProcedureType.EBUS
                procName = "EBUS"
                'Flip180Button.Visible = True
                MarkAreaButton.Visible = False
                'radContentPane.ContentUrl = "~/Products/Broncho/OtherData/Pathology.aspx"
            Case ProcedureType.Antegrade
                procName = "Enteroscopy - Antegrade"
                Flip180Button.Visible = False
                MarkAreaButton.Visible = True
            Case ProcedureType.Retrograde
                procName = "Enteroscopy - Retrograde"
                Flip180Button.Visible = False
                MarkAreaButton.Visible = True
            Case ProcedureType.EUS_OGD
                procName = "EUS (OGD)"
                EUSDiv.Attributes.Add("Style", "display:normal")
                Dim EUSComplete As Boolean = DataAdapter.IsEUSSuccessful(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                EUSCompleteCheckBox.Checked = EUSComplete
                Flip180Button.Visible = False
                MarkAreaButton.Visible = True
            Case ProcedureType.EUS_HPB
                procName = "EUS (HPB)"
                EUSDiv.Attributes.Add("Style", "display:normal")
                Dim EUSComplete As Boolean = DataAdapter.IsEUSSuccessful(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                EUSCompleteCheckBox.Checked = EUSComplete
                Flip180Button.Visible = False
                MarkAreaButton.Visible = True
                'liDiagnoses.Visible = True
        End Select
        lblProcDate.Text = procName & " Procedure - " & Format(CDate(Session(Constants.SESSION_PROCEDURE_DATE)), "dd/MM/yyyy")
        'Session("NewProcedureOpen") = "0"

        'Call loadPatientInfo()
        'Call loadAbnoTheraTree()
        'Call loadReportFields()

        'Call initButtonState()
        LoadInstruments()
        'LoadEndoStaff()

        Dim procedure As New ERS.Data.ERS_Procedures
        procedure = BusinessLogic.Procedures_Select(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        If procedure IsNot Nothing Then
            cboInstrument1.SelectedValue = Convert.ToInt32(procedure.Instrument1)
            cboInstrument2.SelectedValue = Convert.ToInt32(procedure.Instrument2)
            DistalAttachmentRadComboBox.SelectedValue = Convert.ToInt32(procedure.DistalAttachmentId)
            AccessMethodComboBox.SelectedValue = Convert.ToInt32(procedure.Instrument2)
            Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
                Case ProcedureType.ERCP
                    If procedure.PancreasDivisum = 1 Then PancreasDivisumCheckBox.Checked = True
                    If procedure.BiliaryManometry = 1 Then BiliaryCheckBox.Checked = True
                    If procedure.PancreaticManometry = 1 Then PancreaticCheckBox.Checked = True
                Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy
                    If procedure.ScopeGuide.HasValue Then
                        rbScopeGuide.SelectedValue = (IIf(procedure.ScopeGuide, 1, 0))
                    Else
                        rbScopeGuide.SelectedValue = 0
                    End If
            End Select
            Session("PortId") = procedure.ImagePortId
            Dim da As DataAccess = New DataAccess()
            Session("PortName") = da.ImagePortName(procedure.ImagePortId)
        End If

        'Dim dtIns As DataTable = DataAdapter.GetProcedureInstruments(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        'If dtIns.Rows.Count > 0 Then
        '    'PopulateData(dtIns.Rows(0))
        '    cboInstrument1.SelectedValue = CInt(dtIns.Rows(0)("Instrument1"))
        '    cboInstrument2.SelectedValue = CInt(dtIns.Rows(0)("Instrument2"))
        '    Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
        '        Case ProcedureType.ERCP
        '            If dtIns.Rows(0)("PancreasDivisum") = 1 Then PancreasDivisumCheckBox.Checked = True
        '            If dtIns.Rows(0)("BiliaryManometry") = 1 Then BiliaryCheckBox.Checked = True
        '            If dtIns.Rows(0)("PancreaticManometry") = 1 Then PancreaticCheckBox.Checked = True
        '        Case ProcedureType.Colonoscopy, ProcedureType.Sigmoidscopy
        '            If dtIns.Rows(0)("ScopeGuide") Then
        '                rbScopeGuide.SelectedValue = 1
        '            End If
        '    End Select
        'End If

        'If Me.Master.FindControl("cmdMainScreen") IsNot Nothing Then
        '    Dim ctrl As RadButton = DirectCast(Master.FindControl("cmdMainScreen"), RadButton)
        '    ctrl.Visible = False
        'End If
        'If Me.Master.FindControl("tabspace") IsNot Nothing Then
        '    Dim ctrl As HtmlGenericControl = DirectCast(Master.FindControl("tabspace"), HtmlGenericControl)
        '    ctrl.Visible = False
        'End If

        LoadDiagram()

        'Dim thera As New Therapeutics
        'Dim AlertText As String = thera.GetNPSAalert(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        'If AlertText IsNot Nothing AndAlso AlertText.Trim <> "" Then
        '    alertDiv.Attributes.Add("style", "display:normal;border:solid;border-color:red;margin-left:10px;width:50%;")
        '    NpsaAlertLabel.InnerText = AlertText
        'Else
        '    alertDiv.Attributes.Add("style", "display:none")
        'End If
        'buildReport()

        'If Session("BoldButtons") Is Nothing Then
        '    Session("BoldButtons") = New List(Of String)
        'Else
        '    Dim dtRec As DataTable = DataAdapter.GetRecordCountOfOtherData(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        '    Dim secs = (From dr In dtRec.AsEnumerable()
        '               Select CStr(dr("Identifier"))).ToList()
        '    Session("BoldButtons") = secs
        'End If

    End Sub

    'Protected Sub loadPatientInfo()
    '    'PatientName.Text = Session("PatSurname") & ", " & Session("PatForename") & " (" & Session("PatGender") & ")"
    '    'CNN.Text = Session(Constants.SESSION_CASE_NOTE_NO)
    '    'NHSNo.Text = Session("PatNHS")
    '    'DOB.Text = Session("PatDOB")
    '    'RecCreated.Text = Session("PatCreated")

    '    '#ListCon.Text = Session("PPListCon")
    '    '#Endo1.Text = Session("PPEndo1") & ", " & Session("PPEndo2")
    '    '#Nurses.Text = Session("PPNurse1") & ", " & Session("PPNurse2")
    'End Sub

    Protected Sub LoadDiagram()
        'Dim scriptStr As String = String.Empty
        'Dim regJson As String = String.Empty
        'Dim sitesJson As String = String.Empty

        'regJson = GetRegionPathsJson()
        'If regJson = "[]" Then
        '    scriptStr = "alert('Regions are not defined in the database!');"
        'Else
        '    scriptStr = "LoadBasics();"
        '    sitesJson = GetSitesDataJson()
        '    If sitesJson <> "" And sitesJson <> "[]" Then
        '        scriptStr = "LoadBasics();LoadExistingPatient();"
        '    End If
        'End If

        'ViewState("_mRegionPathsJson") = regJson
        'ViewState("_msitesDataJson") = sitesJson

        'Page.ClientScript.RegisterStartupScript(Me.GetType(), "CallMyFunction", scriptStr, True)

        'SchDiagram.ProcedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))
        'SchDiagram.ProcedureTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        'SchDiagram.DiagramId = CInt(Session(Constants.SESSION_DIAGRAM_ID))

    End Sub

    Protected Sub LoadInstruments()
        Dim dtScopeLst As DataTable = DataAdapter.GetScopeLst(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))

        DistalAttachmentRadComboBox.DataSource = DataAdapter.LoadDistalAttachments()
        DistalAttachmentRadComboBox.DataBind()

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{cboInstrument1, ""}}, dtScopeLst, "ScopeName", "ScopeId")
        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{cboInstrument2, ""}}, dtScopeLst, "ScopeName", "ScopeId")
        cboInstrument1.Items.Insert(0, New RadComboBoxItem(""))
        cboInstrument2.Items.Insert(0, New RadComboBoxItem(""))

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{AccessMethodComboBox, "AccessMethod Thoracic"}})

        'Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
        '        {cboInstrument1, DataAdapter.GetInstruments(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
        '        {cboInstrument2, DataAdapter.GetInstruments(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
        '        {AccessMethodComboBox, "AccessMethod Thoracic"}
        '  })


        'Dim listTextField As String = "ListItemText"
        'Dim listValueField As String = "ListItemNo"

        'Utilities.LoadDropdown(cboInstrument1, DataAdapter.GetInstruments(CInt(Session(Constants.SESSION_PROCEDURE_TYPE))), listTextField, listValueField, "")
        'Utilities.LoadDropdown(cboInstrument2, DataAdapter.GetInstruments(CInt(Session(Constants.SESSION_PROCEDURE_TYPE))), listTextField, listValueField, "")
        'Utilities.LoadDropdown(AccessMethodComboBox, DataAdapter.GetDropDownList("AccessMethod Thoracic"), listTextField, listValueField, "")
    End Sub

    'Protected Sub LoadEndoStaff()
    ''Hide Labels and show combo boxes
    'Dim radLabels As String() = {"ListCon", "Endo1", "Nurses"}
    'For Each controlName In radLabels
    '    If Me.Master.FindControl(controlName) IsNot Nothing Then
    '        Dim ctrl As Label = DirectCast(Master.FindControl(controlName), Label)
    '        ctrl.Visible = False
    '    End If
    'Next

    'Dim radComboBoxes As String() = {"cboListConsultant", "cboEndo1", "cboEndo2", "cboNurse1", "cboNurse2", "cboNurse3"}
    'For Each controlName In radComboBoxes
    '    If Me.Master.FindControl(controlName) IsNot Nothing Then
    '        Dim ctrl As RadComboBox = DirectCast(Master.FindControl(controlName), RadComboBox)
    '        ctrl.Visible = True
    '    End If
    'Next

    'Populate combo boxes
    'DirectCast(Me.Master, DATAMasterPage).LoadEndoStaff()
    'End Sub

    'Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
    Protected Sub PatProcAjaxMgr_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs)
        If e.Argument.ToLower.StartsWith("dna") Then
            Response.Redirect("Gastro/OtherData/OGD/Indications.aspx")
        Else
            If e.Argument.StartsWith("DetachPhoto") Then
                Dim photoId As Integer = CInt(e.Argument.Split("#")(1))
                Dim photoName = DataAdapter.DeletePhoto(photoId, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

                If ConfigurationManager.AppSettings("IsAzure") = "true" Then
                    Dim blobstorageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureBlobStorageAccount"))

                    Dim blobClient As CloudBlobClient
                    Dim blobContainer As CloudBlobContainer

                    blobClient = blobstorageAccount.CreateCloudBlobClient()
                    blobContainer = blobClient.GetContainerReference("imageport")

                    blobContainer.CreateIfNotExists()
                    blobContainer.SetPermissions(New BlobContainerPermissions With {.PublicAccess = BlobContainerPublicAccessType.Blob})
                    ' move photo/change blob name 
                    Dim oldPhotoName = Right(photoName, photoName.Length - InStr(photoName, "/" + CStr(Session(Constants.SESSION_PROCEDURE_ID)) + "/"))
                    Dim newPhotoName = CStr(Session(Constants.SESSION_PROCEDURE_ID)) + "/Temp/" + Right(photoName, photoName.Length - photoName.LastIndexOf("/") - 1)
                    Dim imageBlob As CloudBlockBlob = blobContainer.GetBlockBlobReference(oldPhotoName)
                    Dim newImageBlob As CloudBlockBlob = blobContainer.GetBlockBlobReference(newPhotoName)
                    newImageBlob.StartCopy(imageBlob)
                    While newImageBlob.CopyState.Status = CopyStatus.Pending
                        Threading.Thread.Sleep(100)
                    End While

                    If newImageBlob.CopyState.Status = CopyStatus.Success Then
                        imageBlob.FetchAttributes()
                        If imageBlob.Metadata.Count > 0 Then
                            newImageBlob.Metadata.Add("CreateDate", imageBlob.Metadata("CreateDate"))
                            newImageBlob.SetMetadata()
                        End If
                        imageBlob.Delete()
                    End If

                Else
                    'remove from folder
                    Dim sourcePath = Path.Combine(PhotosFolderPath, photoName)
                    Dim destPath = Path.Combine(CacheFolderPath, photoName)

                    If File.Exists(destPath) Then File.Delete(destPath) 'in case file already exists in destPath
                    Dim originalCreationTime = File.GetCreationTimeUtc(sourcePath)
                    File.Move(sourcePath, destPath)
                    File.SetCreationTimeUtc(destPath, originalCreationTime) 'need to keep the time stamp incase needed for the TTC and WT details
                End If

            End If



            SummaryListView.DataBind()
            PhotosListView.DataBind()
            'procedurefooter.DataBind()
            VideosListView.Rebind()
            LoadVideos()

            'The JS method SetPhotoContextMenu() is called from here because it needs to be called AFTER the PatProcAjaxMgr_AjaxRequest completes.
            ScriptManager.RegisterStartupScript(Page, GetType(Page), "myscript", "SetPhotoContextMenu();SetVideoContextMenu();", True)

        End If
    End Sub

    Public Function DatatableToDictionary(dt As DataTable) As Dictionary(Of String, Dictionary(Of String, Object))
        Dim cols = dt.Columns.Cast(Of DataColumn)()
        Return dt.Rows.Cast(Of DataRow)().ToDictionary(Function(r) r(ID).ToString(), Function(r) cols.ToDictionary(Function(c) c.ColumnName, Function(c) r(c.ColumnName)))
    End Function

    Protected Sub SummaryObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryObjectDataSource.Selecting
        e.InputParameters("procId") = CStr(Session(Constants.SESSION_PROCEDURE_ID))
    End Sub

    Protected Sub SummaryPremedObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryPremedObjectDataSource.Selecting
        e.InputParameters("procId") = CStr(Session(Constants.SESSION_PROCEDURE_ID))
    End Sub

    Protected Sub SummaryListView_ItemCreated(sender As Object, e As ListViewItemEventArgs) Handles SummaryListView.ItemCreated
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!NodeSummary) Then
                e.Item.Visible = False
            ElseIf CStr(drItem!NodeSummary) = "" Then
                e.Item.Visible = False
            End If
        Else
            e.Item.Visible = False
        End If
    End Sub

    Protected Sub SummaryPremedListView_ItemCreated(sender As Object, e As ListViewItemEventArgs) Handles SummaryPremedListView.ItemCreated
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!NodeSummary) Then
                e.Item.Visible = False
            ElseIf CStr(drItem!NodeSummary) = "" Then
                e.Item.Visible = False
            End If
        Else
            e.Item.Visible = False
        End If
    End Sub

    Protected Sub SitesWithPhotosObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SitesWithPhotosObjectDataSource.Selecting
        e.InputParameters("procedureId") = CStr(Session(Constants.SESSION_PROCEDURE_ID))
        e.InputParameters("includeVideos") = False
    End Sub

    Protected Function GetSitesVideos() As DataTable
        Dim dtSitesWithPhotos As DataTable = DataAdapter.GetSitesWithPhotos(CStr(Session(Constants.SESSION_PROCEDURE_ID)))
        Dim dtSiteVideos As DataTable = Nothing
        Dim bVideoPresent As Boolean = False

        For Each drSiteWithPhotos In dtSitesWithPhotos.Rows
            If Not IsDBNull(drSiteWithPhotos("SiteId")) Then
                Dim sId As Integer = CInt(drSiteWithPhotos("SiteId"))
                Dim siteDescription As String = DataAdapter.GetSiteDescription(sId)
                Dim dtSitePhotos = DataAdapter.GetSitePhotos(sId, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

                If dtSiteVideos Is Nothing Then
                    dtSiteVideos = dtSitePhotos.Clone()
                    dtSiteVideos.Columns.Add("ImageUrl")
                    dtSiteVideos.Columns.Add("ImageThumbnailUrl")
                    dtSiteVideos.Columns.Add("SiteDescription")
                    dtSiteVideos.AcceptChanges()
                End If

                For Each dr As DataRow In dtSitePhotos.Rows
                    If (Path.GetExtension(CStr(dr("PhotoName"))) = ".mp4") Then
                        Dim drNew = dtSiteVideos.NewRow()
                        drNew("PhotoId") = dr("PhotoId")
                        drNew("SiteId") = dr("SiteId")
                        drNew("ImageUrl") = PhotosFolderUri & "/" & dr("PhotoName")
                        drNew("SiteDescription") = siteDescription
                        drNew("ImageThumbnailUrl") = CStr(PhotosFolderUri & "/" & dr("PhotoName").Replace(".mp4", ".bmp"))
                        dtSiteVideos.Rows.Add(drNew)
                        bVideoPresent = True
                    End If
                Next

                'For i As Integer = dtSitePhotos.Rows.Count - 1 To 0 Step -1
                '    If Not (Path.GetExtension(CStr(dtSitePhotos.Rows(i)("ImageUrl"))) = ".mp4") Then
                '        dtSitePhotos.Rows.Remove(dtSitePhotos.Rows(i))
                '    End If
                'Next

            End If
        Next
        If Not bVideoPresent Then VideosListView.Visible = False
        Return dtSiteVideos
    End Function

    Protected Sub SummaryListView_ItemDataBound(sender As Object, e As ListViewItemEventArgs) Handles SummaryListView.ItemDataBound
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row

            If Not IsDBNull(drItem!NodeName) Then
                If CStr(drItem!NodeName) = "Report" AndAlso Not IsDBNull(drItem!NodeSummary) Then
                    Dim NodeSummaryLabel As Label = DirectCast(e.Item.FindControl("NodeSummaryLabel"), Label)
                    If NodeSummaryLabel IsNot Nothing Then
                        NodeSummaryLabel.Text = DataAdapter.GetReportSummaryWithHyperlinks(CStr(Session(Constants.SESSION_PROCEDURE_ID)), 0)
                    End If

                ElseIf (CStr(drItem!NodeName) = "Instructions for PEG care" Or CStr(drItem!NodeName) = "Post procedure patient care") _
                    AndAlso Not IsDBNull(drItem!NodeSummary) Then
                    Dim NodeSummaryLabel As Label = DirectCast(e.Item.FindControl("NodeSummaryLabel"), Label)
                    If NodeSummaryLabel IsNot Nothing Then
                        NodeSummaryLabel.Text = DataAdapter.GetInstForCareWithHyperlinks(CStr(Session(Constants.SESSION_PROCEDURE_ID)))
                    End If
                End If
            End If
        End If
    End Sub

    'Protected Sub PhotosListView_DataBound(sender As Object, e As EventArgs) Handles PhotosListView.DataBound
    '    Dim PhotosImageGallery As RadImageGallery = DirectCast(PhotosListView.Items(0).FindControl("PhotosImageGallery"), RadImageGallery)
    '    PhotosImageGallery.DataSource = DataAdapter.GetSitePhotos(1003, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
    'End Sub

    'Protected Sub PhotosListView_ItemCreated(sender As Object, e As ListViewItemEventArgs) Handles PhotosListView.ItemCreated
    '    If e.Item.DataItem IsNot Nothing Then
    '        Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
    '        Dim PhotosImageGallery As RadImageGallery = DirectCast(e.Item.FindControl("PhotosImageGallery"), RadImageGallery)

    '        If PhotosImageGallery IsNot Nothing Then
    '            PhotosImageGallery.DataSource = DataAdapter.GetSitePhotos(If(Not IsDBNull(drItem("SiteId")), CInt(drItem("SiteId")), 0), CInt(Session(Constants.SESSION_PROCEDURE_ID)))
    '            PhotosImageGallery.DataBind()
    '        End If
    '    End If
    'End Sub

    'Private WithEvents PhotosImageGallery As RadImageGallery = Nothing

    Protected Sub PhotosListView_ItemDataBound(sender As Object, e As ListViewItemEventArgs) Handles PhotosListView.ItemDataBound
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            Dim SiteNameLabel As Label = DirectCast(e.Item.FindControl("SiteNameLabel"), Label)

            If IsDBNull(drItem("SiteId")) Then
                SiteNameLabel.Text = "Attached to the report: "
            ElseIf CStr(drItem("SiteName")) = "ZZZZ" Then
                'This might happen when records deleted (manually prob) from ERS_Sites but the orphan records remain in ERS_Photos
                SiteNameLabel.Text = "Not Known (Corresponding site not found. Please contact Unisoft)"
            End If

            ''Dim PhotosImageGallery As RadImageGallery = DirectCast(e.Item.FindControl("PhotosImageGallery"), RadImageGallery)
            'PhotosImageGallery = DirectCast(e.Item.FindControl("PhotosImageGallery"), RadImageGallery)

            'If PhotosImageGallery IsNot Nothing Then
            '    'Dim gogo As New AjaxUpdatedControl()
            '    'gogo.ControlID = PhotosImageGallery.ID
            '    'RadAjaxManager1.AjaxSettings(0).UpdatedControls.Add(gogo)
            '    'PhotosImageGallery.DataSource = DataAdapter.GetSitePhotos(If(Not IsDBNull(drItem("SiteId")), CInt(drItem("SiteId")), 0), CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            '    'PhotosImageGallery.DataImageField = "PhotoBlob"
            '    'PhotosImageGallery.DataBind()
            'End If
        End If
    End Sub

    Protected Sub PhotosImageGallery_NeedDataSource(ByVal sender As Object, ByVal e As ImageGalleryNeedDataSourceEventArgs)
        Dim PhotosImageGallery As RadImageGallery = DirectCast(sender, RadImageGallery)
        Dim lvItem As ListViewDataItem = DirectCast(DirectCast(sender, RadImageGallery).NamingContainer, ListViewDataItem)
        Dim siteIdObj = PhotosListView.DataKeys(lvItem.DataItemIndex).Values("SiteId")
        Dim sId As Integer = If(Not IsDBNull(siteIdObj), CInt(siteIdObj), 0)

        Dim siteDescription As String = DataAdapter.GetSiteDescription(sId)

        'Dim drItem As DataRow = DirectCast(lvItem.DataItem, DataRowView).Row
        'PhotosImageGallery.DataSource = DataAdapter.GetSitePhotos(If(Not IsDBNull(drItem("SiteId")), CInt(drItem("SiteId")), 0), CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        Dim dtSitePhotos = DataAdapter.GetSitePhotos(sId, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

        For i As Integer = dtSitePhotos.Rows.Count - 1 To 0 Step -1
            If Path.GetExtension(CStr(dtSitePhotos.Rows(i)("PhotoName"))) = ".mp4" Then
                dtSitePhotos.Rows.Remove(dtSitePhotos.Rows(i))
            End If
        Next

        If dtSitePhotos.Rows.Count > 0 Then
            dtSitePhotos.Columns.Add("ImageUrl")
            dtSitePhotos.Columns.Add("ImageThumbnailUrl")
            dtSitePhotos.Columns.Add("SiteDescription")
            dtSitePhotos.AcceptChanges()

            For Each dr As DataRow In dtSitePhotos.Rows
                Dim photoURL As String
                If ConfigurationManager.AppSettings("IsAzure") = "true" Then
                    photoURL = dr("PhotoName")
                Else
                    If CBool(Session("IsERSViewer")) Then 'displaying the 'image not avaiable' should not apply to ERS Viewer
                        photoURL = PhotosFolderUri & "/" & dr("PhotoName")
                    Else
                        If File.Exists(PhotosFolderPath & "/" & dr("PhotoName")) Then
                            photoURL = PhotosFolderUri & "/" & dr("PhotoName")
                        Else
                            photoURL = Page.Request.Url.GetLeftPart(UriPartial.Authority) & "/" & Request.ApplicationPath & "/Images/image-not-found.jpg"
                        End If
                    End If
                End If

                dr("ImageUrl") = photoURL
                dr("ImageThumbnailUrl") = photoURL
                dr("SiteDescription") = siteDescription

                If (Path.GetExtension(CStr(dr("ImageUrl"))) = ".mp4") Then
                    dr("ImageThumbnailUrl") = CStr(dr("ImageUrl")).Replace(".mp4", ".bmp")
                End If
            Next
            PhotosImageGallery.DataSource = dtSitePhotos
            PhotosImageGallery.DataKeyNames = {"PhotoId"}
        End If
    End Sub

    Protected Sub PhotosImageGallery_OnItemDataBound(ByVal sender As Object, ByVal e As ImageGalleryItemEventArgs)
        Dim drItem As DataRow = DirectCast(e.ListViewItem.DataItem, System.Data.DataRowView).Row
        If drItem("SiteDescription") IsNot Nothing Then
            DirectCast(e.Item, ImageGalleryItem).Title = Convert.ToString(drItem("SiteDescription"))
        End If
        ' this is used in Detach Photo function
        If drItem("PhotoId") IsNot Nothing Then
            DirectCast(e.Item, ImageGalleryItem).Description = Convert.ToInt32(drItem("PhotoId"))
        End If
    End Sub

    Protected Sub VideosListView_NeedDataSource(sender As Object, e As RadListViewNeedDataSourceEventArgs)
        VideosListView.DataSource = GetSitesVideos()
    End Sub

    Private Sub LoadVideos()
        Dim dtSitesVideos As DataTable = GetSitesVideos()

        If dtSitesVideos IsNot Nothing Then
            For Each dr In dtSitesVideos.Rows
                'Dim sId As Integer = CInt(dr("SiteId"))

                'If (Path.GetExtension(CStr(dr("ImageUrl"))) = ".mp4") Then
                '    Dim igti As New ImageGalleryTemplateItem()
                '    igti.ThumbnailUrl = CStr(dr("ImageThumbnailUrl"))
                '    Dim template As New ImageGalleryContentTemplate(CStr(dr("ImageUrl")), CInt(dr("PhotoId")))
                '    igti.ContentTemplate = template
                '    VideosImageGallery.Items.Add(igti)
                'End If

                If (Path.GetExtension(CStr(dr("ImageUrl"))) = ".mp4") Then
                    Dim item As New RadLightBoxItem()
                    item.Title = CStr(dr("SiteDescription"))
                    item.Description = CStr(dr("SiteDescription"))
                    item.ItemTemplate = New LightBoxMediaTemplate(CStr(dr("ImageUrl")), CInt(dr("PhotoId")))
                    VideosLightBox.Items.Add(item)
                End If
            Next
        End If
    End Sub

    'Protected Sub PhotosRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs) Handles PhotosRepeater.ItemDataBound
    '    If e.Item.DataItem IsNot Nothing Then
    '        Dim drItem As DataRow = DirectCast(DirectCast(e.Item, RepeaterItem).DataItem, DataRowView).Row
    '        Dim SiteNameLabel As Label = DirectCast(e.Item.FindControl("SiteNameLabel"), Label)

    '        If IsDBNull(drItem("SiteId")) Then
    '            SiteNameLabel.Text = "Attached to the report: "
    '        End If

    '        Dim PhotosImageGallery As RadImageGallery = DirectCast(e.Item.FindControl("PhotosImageGallery"), RadImageGallery)

    '        If PhotosImageGallery IsNot Nothing Then
    '            'Dim gogo As New AjaxUpdatedControl()
    '            'gogo.ControlID = PhotosImageGallery.ID
    '            'RadAjaxManager1.AjaxSettings(0).UpdatedControls.Add(gogo)
    '            PhotosImageGallery.DataSource = DataAdapter.GetSitePhotos(If(Not IsDBNull(drItem("SiteId")), CInt(drItem("SiteId")), 0), CInt(Session(Constants.SESSION_PROCEDURE_ID)))
    '            'PhotosImageGallery.DataImageField = "PhotoBlob"
    '            PhotosImageGallery.DataBind()
    '        End If
    '    End If
    'End Sub

    Protected Sub DistalAttachmentRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles DistalAttachmentRadComboBox.SelectedIndexChanged
        Try
            updateDistalAttachment()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error saving distal attament- selected item= " & DistalAttachmentRadComboBox.SelectedItem.Text, ex)
        End Try
    End Sub

    Protected Sub cboInstrument1_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles cboInstrument1.SelectedIndexChanged
        UpdateInstrument()
    End Sub

    Protected Sub cboInstrument2_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles cboInstrument2.SelectedIndexChanged
        UpdateInstrument()
    End Sub

    Protected Sub AccessMethodComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles AccessMethodComboBox.SelectedIndexChanged
        UpdateInstrument()
    End Sub

    Sub updateDistalAttachment()
        If Not DistalAttachmentRadComboBox.SelectedValue = 0 And Not DistalAttachmentRadComboBox.SelectedValue = -55 Then
            DataAdapter.UpdateDistalAttachment(DistalAttachmentRadComboBox.SelectedValue, DistalAttachmentRadComboBox.SelectedItem.Text, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        End If
    End Sub

    Sub UpdateInstrument()
        Dim Instrument1, Instrument2 As Integer
        Dim Instrument2Txt As String = ""
        Dim InstrumentTxt As String = ""

        If cboInstrument1.SelectedValue = "" OrElse cboInstrument1.SelectedValue = "0" Then
            Instrument1 = 0
        Else
            Instrument1 = cboInstrument1.SelectedValue
            InstrumentTxt = cboInstrument1.SelectedItem.Text
        End If

        If CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Bronchoscopy _
                Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.EBUS _
                Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Thoracoscopy Then
            If AccessMethodComboBox.SelectedValue = "" Then
                Instrument2 = 0
            Else
                Instrument2 = AccessMethodComboBox.SelectedValue
                Instrument2Txt = AccessMethodComboBox.SelectedItem.Text
            End If
        Else
            If cboInstrument2.SelectedValue = "" OrElse cboInstrument2.SelectedValue = "0" Then
                Instrument2 = 0
            Else
                Instrument2 = cboInstrument2.SelectedValue
                Instrument2Txt = cboInstrument2.SelectedItem.Text
            End If
        End If

        If InstrumentTxt <> "" Then InstrumentTxt = InstrumentTxt & "<br />"
        InstrumentTxt = InstrumentTxt & Instrument2Txt

        DataAdapter.UpdateInstrument(Instrument1, cboInstrument1.SelectedItem.Text, Instrument2, Instrument2Txt, InstrumentTxt, CInt(Session(Constants.SESSION_PROCEDURE_ID)), CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))

        'If newProcedure.ImagePortId > 0 Then
        'get photos from image port and save to photos save location
        Try
            'Dim t As Thread
            't = New Thread(AddressOf LoadPhotos)
            't.Start()
            LoadPhotos()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while downloading photos.", ex)

            Utilities.SetErrorNotificationStyle(ErrorNotification, errorLogRef, ex.Message)
            ErrorNotification.Show()
        End Try

        'End If
    End Sub

    Private Sub rbScopeGuide_SelectedIndexChanged(sender As Object, e As EventArgs) Handles rbScopeGuide.SelectedIndexChanged
        DataAdapter.UpdateProcedureField("ScopeGuide", rbScopeGuide.SelectedValue, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
    End Sub

    Private Sub Flip180Button_Click(sender As Object, e As EventArgs) Handles Flip180Button.Click
        If CInt(Session(Constants.SESSION_DIAGRAM_NUMBER) = 1) Then
            Session(Constants.SESSION_DIAGRAM_NUMBER) = 2
        ElseIf CInt(Session(Constants.SESSION_DIAGRAM_NUMBER) = 2) Then
            Session(Constants.SESSION_DIAGRAM_NUMBER) = 1
        End If

        DataAdapter.UpdateProcedureFlipDiagram(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

        'LoadDiagram()
        SchDiagram.Source = "FLIP"
    End Sub

    Private Sub DeleteProcRadButton_Click(sender As Object, e As EventArgs) Handles DeleteProcRadButton.Click
        If Not CBool(Session("isERSViewer")) Then
            DataAdapter.DeleteProcedure(CInt(Session(Constants.SESSION_PROCEDURE_ID)), 0)
        End If
        Response.Redirect("~/Products/Default.aspx?patient=true")
    End Sub

    Private Sub RemoveImages_Click(sender As Object, e As EventArgs) Handles RemoveImages.Click
        Dim portId As Int32
        Dim portName As String
        Dim sessionRoomId As String = Session("RoomId")

        portName = Session("PortName")
        portId = Session("portId")
        'Using db As New ERS.Data.GastroDbEntities
        '    Dim dbImagePort = db.ERS_ImagePort.First(Function(x) x.RoomId = CInt(sessionRoomId))
        '    portName = dbImagePort.PortName
        '    portId = dbImagePort.ImagePortId
        'End Using

        If Not (String.IsNullOrEmpty(portName)) Then

            Dim sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & portName
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
        ImagesExistRadWindow.Visible = False
        ImagesExistRadWindow.VisibleOnPageLoad = False
    End Sub

    Private Sub CancelDeleteRadButton_Click(sender As Object, e As EventArgs) Handles CancelDeleteRadButton.Click
        'Response.Redirect("~/Products/Default.aspx?patient=true")
    End Sub

    Private Sub KeepProcRadButton_Click(sender As Object, e As EventArgs) Handles KeepProcRadButton.Click
        Response.Redirect("~/Products/Default.aspx?patient=true")
    End Sub

    Private Sub ByDistanceAddRadButton_Click(sender As Object, e As EventArgs) Handles ByDistanceAddRadButton.Click

        If ByDistanceAtTextBox.Text = "" Or ByDistanceAtTextBox.Value <= 0 Or ByDistanceAtTextBox.Value > 9999 Then Exit Sub
        If ByDistanceToTextBox.Text = "" Or ByDistanceToTextBox.Value < 0 Or ByDistanceToTextBox.Value > 9999 Then ByDistanceToTextBox.Value = 0

        Try
            'SiteNo is set to -77 for sites By Distance (Col & Sig only)
            DataAdapter.InsertSite(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
                        -77,
                        ByDistanceAtTextBox.Value,
                        ByDistanceToTextBox.Value,
                        Nothing,
                        Nothing,
                        0, 0, 0)

            ByDistanceList.DataBind()
            ByDistanceAtTextBox.Text = ""
            ByDistanceToTextBox.Text = ""
            'ByDistanceAddRadButton.Enabled = False
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving byDistance data.", ex)

            Utilities.SetErrorNotificationStyle(ErrorNotification, errorLogRef, "There is a problem saving sites (by distance) data.")
            ErrorNotification.Show()
        End Try

    End Sub

    Private Sub ByDistanceRemoveButton_Click(sender As Object, e As EventArgs) Handles ByDistanceRemoveButton.Click
        If ByDistanceList.SelectedIndex < 0 Then Exit Sub
        Try
            'release photo from site
            Dim da As New DataAccess
            Dim dtPhotos As DataTable = da.GetSitePhotos(ByDistanceList.SelectedValue, 0) ' no need to pass procedureID as we have the site ID
            Dim tempUNC As String = HttpContext.Current.Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID) & "\Temp"
            Dim procUNC As String = HttpContext.Current.Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID)
            For Each dr As DataRow In dtPhotos.Rows
                dr("PhotoName").ToString()
                If File.Exists(procUNC & "\" & dr("PhotoName").ToString()) Then
                    File.Move(procUNC & "\" & dr("PhotoName").ToString(), tempUNC & "\" & dr("PhotoName").ToString())
                End If
            Next

            DataAdapter.DeleteSite(ByDistanceList.SelectedValue)
            ByDistanceList.DataBind()
            ScriptManager.RegisterStartupScript(Page, GetType(Page), "RefreshRightPane", "RefreshSiteSummary(); SetByDistanceButtons(false);", True)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while deleting byDistance data.", ex)

            Utilities.SetErrorNotificationStyle(ErrorNotification, errorLogRef, "There is a problem deleting sites (by distance) data.")
            ErrorNotification.Show()
        End Try
    End Sub

    Private Sub PancreasDivisumCheckBox_CheckedChanged(sender As Object, e As EventArgs) Handles PancreasDivisumCheckBox.CheckedChanged
        SetManometry("PancreasDivisum", PancreasDivisumCheckBox.Checked)
    End Sub

    Private Sub BiliaryCheckBox_CheckedChanged(sender As Object, e As EventArgs) Handles BiliaryCheckBox.CheckedChanged
        SetManometry("BiliaryManometry", BiliaryCheckBox.Checked)
    End Sub

    Private Sub PancreaticCheckBox_CheckedChanged(sender As Object, e As EventArgs) Handles PancreaticCheckBox.CheckedChanged
        SetManometry("PancreaticManometry", PancreaticCheckBox.Checked)
    End Sub

    Sub SetManometry(fldName As String, bVal As Boolean)
        DataAdapter.UpdateProcedureField(fldName, bVal, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
    End Sub

    'Private Sub LoadPhotos()
    '    Try
    '        Dim dt As DataTable = DataAdapter.GetProceduresImagePort(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
    '        If dt.Rows.Count = 0 Then Exit Sub

    '        Dim portId = CInt(dt.Rows(0)("ImagePortId"))
    '        Dim portName = dt.Rows(0)("PortName")

    '        If portId = 0 Then Exit Sub   'No ImagePort attached to this computer

    '        Dim sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & portName
    '        'Dim destinationPath = CType(Me.Page, Products_Default).CacheFolderPath 'cant instantiate pagebase so must take from parent page
    '        Dim destinationPath = CacheFolderPath

    '        If Directory.Exists(sourcePath) Then
    '            If Not Directory.Exists(destinationPath) Then Directory.CreateDirectory(destinationPath)
    '            Dim searchPatterns() As String = {"*.jpg", "*.bmp", "*.jpeg", "*.gif", "*.png", "*.tiff", "*.mp4", "*.mpg"} ', "*.mov", "*.wmv", "*.flv", "*.avi", "*.mpeg"}
    '            Dim iCount = 1
    '            For Each searchPattern As String In searchPatterns
    '                Dim imgFiles = Directory.GetFiles(sourcePath, searchPattern)
    '                For Each img In imgFiles
    '                    Dim fi As New FileInfo(img)

    '                    If fi.Extension = searchPattern.Replace("*", "") Then
    '                        Dim newFileName = "ERS_" & Session(Constants.SESSION_PROCEDURE_ID) & "_" & ConfigurationManager.AppSettings("Unisoft.HospitalID") & "_" & Session("OperatingHospitalID") & "_" & Session(Constants.SESSION_PROCEDURE_TYPE) & "_" & portId.ToString() & "_" & iCount & "_" & Now.ToString("yyMMdd_HHmmss") & fi.Extension
    '                        Dim newFilePath = Path.Combine(destinationPath, newFileName)
    '                        File.Move(img, newFilePath)
    '                        'write to log
    '                        WriteLog(fi.Name, newFileName)

    '                        If fi.Extension = ".bmp" Then 'check for videos as .bmp is used for capturing a frame from the video for thumbnail
    '                            'Currently checking for .mpg and .mp4 only

    '                            Dim srcVideoFile As String = ""
    '                            Dim srcVideoExt As String = ""
    '                            If File.Exists(Replace(img, ".bmp", ".mp4")) Then
    '                                srcVideoFile = Replace(img, ".bmp", ".mp4")
    '                                srcVideoExt = ".mp4"
    '                            ElseIf File.Exists(Replace(img, ".bmp", ".mpg")) Then
    '                                srcVideoFile = Replace(img, ".bmp", ".mpg")
    '                                srcVideoExt = ".mpg"
    '                            End If
    '                            If srcVideoFile <> "" Then
    '                                Dim destVideoFile As String = Replace(newFilePath, ".bmp", srcVideoExt)
    '                                File.Move(srcVideoFile, destVideoFile)
    '                                WriteLog(Replace(fi.Name, ".bmp", srcVideoExt), Replace(newFileName, ".bmp", srcVideoExt))
    '                            End If
    '                        End If
    '                        iCount += 1
    '                    End If
    '                Next
    '            Next

    '            'Delete all remaining files (jpg_0, *.pts) which are created by ImagePort and not required
    '            Dim directoryName As String = sourcePath
    '            For Each deleteFile In Directory.GetFiles(directoryName, "*.jpg*", SearchOption.TopDirectoryOnly)
    '                File.Delete(deleteFile)
    '            Next
    '        End If
    '    Catch ex As Exception
    '         Dim errorLogRef As String
    '        errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while loading photos.", ex)

    '        Utilities.SetErrorNotificationStyle(ErrorNotification, errorLogRef, "There is a problem loading your photos.")
    '        ErrorNotification.Show()
    '    End Try
    'End Sub

    'Private Sub WriteLog(src As String, dest As String)
    '    If Not Directory.Exists(LogFolderPath) Then Directory.CreateDirectory(LogFolderPath)
    '    Using sw As New StreamWriter(LogFolderPath & "\ImgLog.txt", True)
    '        sw.WriteLine(DateTime.Now & ": " & src & " moved to " & dest)
    '    End Using
    'End Sub

    Private Class LightBoxMediaTemplate
        Implements ITemplate

        Protected player As RadMediaPlayer
        Private source As String
        Private photoId As Integer

        Public Sub New(source As String, photoId As Integer)
            Me.source = source
            Me.photoId = photoId
        End Sub

        Public Sub InstantiateIn(container As Control) Implements ITemplate.InstantiateIn
            player = New RadMediaPlayer()
            player.ID = "RadMediaPlayer" & CStr(photoId)
            'player.RenderMode = RenderMode.Lightweight
            'player.ToolBar.FullScreenButton.Style("display") = "none"
            player.Source = source
            player.Height = Unit.Pixel(336)
            player.Width = Unit.Pixel(600)
            'player.TitleBar.ShareButton.Visible = false
            player.TitleBar.Visible = False
            player.ToolBar.SubtitlesButton.Visible = False
            player.ToolBar.HDButton.Visible = False

            container.Controls.Add(player)
        End Sub

    End Class

    Protected Sub ProcedureNotCarriedOutDetailsLinkButton_Click(sender As Object, e As EventArgs)
        Try

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error getting DNA reasons", ex)
            Utilities.SetErrorNotificationStyle(ErrorNotification, ref, "Error getting procedure DNA resons")
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function IsLymphNodeBySiteId(siteId As Integer) As String
        Try
            Dim da As New DataAccess
            Dim isLymphNode As Object

            If siteId = -1 Or siteId = 0 Then
                isLymphNode = True
            Else
                isLymphNode = da.IsLymphNodeBySiteId(siteId)
            End If

            Return New JavaScriptSerializer().Serialize(isLymphNode)

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("errrrrrrrorrrrrrringggggggg!!!!!!!!!", ex)
            Throw ex
        End Try
    End Function

End Class