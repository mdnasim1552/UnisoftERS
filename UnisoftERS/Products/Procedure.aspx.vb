Imports System.Data.SqlClient
Imports System.IO
Imports System.Web.Optimization
Imports System.Web.Script.Serialization
Imports System.Web.Services
Imports System.Windows
Imports Hl7.Fhir.Model
Imports Telerik.Web.UI
Imports UnisoftERS.BusinessLogic

Public Class products_common_proceduresummary_aspx
    Inherits PageBase
    Public procedure_Id As Integer, ProcedureTypeId As Integer, DiagramNumber As Integer, ImageGenderId As Integer, EpisodeNo As Integer, ColonType As Integer
    Private _forPrinting As Boolean
    Dim scriptStr As String = String.Empty
    Public ReadOnly Property DiagramHeight As Integer
        Get
            Return CInt(ConfigurationManager.AppSettings("Unisoft.DiagramHeight"))
        End Get
    End Property

    Public ReadOnly Property DiagramWidth As Integer
        Get
            Return CInt(ConfigurationManager.AppSettings("Unisoft.DiagramWidth"))
        End Get
    End Property
    Public Property ForPrinting As Boolean
        Get
            Return _forPrinting
        End Get

        Set(value As Boolean)
            _forPrinting = value
        End Set
    End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ColonType = Session(Constants.SESSION_PROCEDURE_COLONTYPE)
        EpisodeNo = CInt(Session(Constants.SESSION_EPISODE_NO))
        ProcedureTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        DiagramNumber = CInt(Session(Constants.SESSION_DIAGRAM_NUMBER))
        ImageGenderId = CInt(Session(Constants.SESSION_IMAGE_GENDERID))
        procedure_Id = CInt(Session(Constants.SESSION_PROCEDURE_ID))
        If Not Page.IsPostBack Then
            Dim procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If Request.Cookies("patientId") Is Nothing Then
                MessageBox.Show("Your session expired, please start procedure again..")
                Response.Redirect("~/Products/Default.aspx", False)
            End If

            If procType = ProcedureType.Bronchoscopy Or procType = ProcedureType.EBUS Or procType = ProcedureType.Flexi Then
                divRequirementsKey.Visible = False
            End If

            Dim da As New DataAccess

            Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
                Case ProcedureType.Gastroscopy OrElse ProcedureType.Transnasal
                    If Session("NewProcedureOpen") = "1" Then

                        Dim sPreviousGastricUlcer As String = da.GetPreviousGastricUlcer(CInt(Session(Constants.SESSION_PROCEDURE_ID)), True)
                        If sPreviousGastricUlcer <> "" Then
                            MessageRadWindow.Visible = True
                            MessageRadWindow.VisibleOnPageLoad = True
                            If Len(sPreviousGastricUlcer) > 45 Then MessageRadWindow.Height = "300"
                            lblPreviousGastricUlcer.Text = "The patient had a previous GASTRIC ULCER <br>in the " & sPreviousGastricUlcer & ".  </br></br> Please add a site in that area and say whether the ulcer is healing or not."
                        End If
                    End If
                    UpperGIDiv.Attributes.Add("Style", "display:normal")
                    Dim transnasal As Boolean = da.IsTransnasalProcedure(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                    TransnasalCheckBox.Checked = transnasal
                Case ProcedureType.ERCP
                    PapillaryAnatomyButtonDiv.Attributes.Add("Style", "display:normal")

                    Dim procedure As New ERS.Data.ERS_Procedures
                    procedure = BusinessLogic.Procedures_Select(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

                    If procedure.PancreasDivisum = 1 Then PancreasDivisumCheckBox.Checked = True
                    If procedure.BiliaryManometry = 1 Then BiliaryCheckBox.Checked = True
                    If procedure.PancreaticManometry = 1 Then PancreaticCheckBox.Checked = True

                    'PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PancreasDivisumCheckBox, PancreasDivisumCheckBox, RadAjaxLoadingPanel1)
                    'PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(BiliaryCheckBox, BiliaryCheckBox, RadAjaxLoadingPanel1)
                    'PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PancreaticCheckBox, PancreaticCheckBox, RadAjaxLoadingPanel1)

                Case ProcedureType.Colonoscopy
                    ResectedColonDiv.Attributes.Add("Style", "display:normal")
                    'divScopeGuide.Visible = True
                    'tdScopeGuide.Visible = True
                Case ProcedureType.Sigmoidscopy
                    ResectedColonDiv.Attributes.Add("Style", "display:normal")
                Case ProcedureType.Proctoscopy
                    ResectedColonDiv.Attributes.Add("Style", "display:normal")
                Case ProcedureType.Bronchoscopy
                    'Flip180Button.Visible = True
                Case ProcedureType.EBUS
                    'Flip180Button.Visible = True
                Case ProcedureType.Antegrade
                Case ProcedureType.Retrograde
                    ResectedColonDiv.Attributes.Add("Style", "display:normal")
                    ResectedColonButton.Visible = False
            End Select

            ProcedureTypeLabel.Text = DataHelper.GetProcedureName("Procedure", procType)

            Session("NewProcedureOpen") = "0"
            LoadDiagram()
        End If

        Dim PatProcAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Page)

        Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
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
                'PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(PatProcAjaxMgr, lblFirstERCP, RadAjaxLoadingPanel1)
        End Select

    End Sub

    Protected Sub Page_PreRender(sender As Object, e As EventArgs)

    End Sub

    Private Sub ByDistanceAddRadButton_Click(sender As Object, e As EventArgs) Handles ByDistanceAddRadButton.Click

        If ByDistanceAtTextBox.Text = "" Or ByDistanceAtTextBox.Value <= 0 Or ByDistanceAtTextBox.Value > 9999 Then Exit Sub
        If ByDistanceToTextBox.Text = "" Or ByDistanceToTextBox.Value < 0 Or ByDistanceToTextBox.Value > 9999 Then ByDistanceToTextBox.Value = 0

        Try
            'SiteNo is set to -77 for sites By Distance (Col & Sig only)
            'DataAdapter.InsertSite(CInt(Session(Constants.SESSION_PROCEDURE_ID)),
            '            -77,
            '            ByDistanceAtTextBox.Value,
            '            ByDistanceToTextBox.Value,
            '            Nothing,
            '            Nothing,
            '            0, 0, 0)

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
            'Dim da As New DataAccess
            'Dim dtPhotos As DataTable = da.GetSitePhotos(ByDistanceList.SelectedValue, 0) ' no need to pass procedureID as we have the site ID
            'Dim tempUNC As String = HttpContext.Current.Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID) & "\Temp"
            'Dim procUNC As String = HttpContext.Current.Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID)
            'For Each dr As DataRow In dtPhotos.Rows
            '    dr("PhotoName").ToString()
            '    If File.Exists(procUNC & "\" & dr("PhotoName").ToString()) Then
            '        File.Move(procUNC & "\" & dr("PhotoName").ToString(), tempUNC & "\" & dr("PhotoName").ToString())
            '    End If
            'Next

            'DataAdapter.DeleteSite(ByDistanceList.SelectedValue)
            ByDistanceList.DataBind()
            ScriptManager.RegisterStartupScript(Page, GetType(Page), "RefreshRightPane", "RefreshSiteSummary(); SetByDistanceButtons(false);", True)
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while deleting byDistance data.", ex)

            Utilities.SetErrorNotificationStyle(ErrorNotification, errorLogRef, "There is a problem deleting sites (by distance) data.")
            ErrorNotification.Show()
        End Try
    End Sub

#Region "Discomfort score"
    <WebMethod()>
    Public Shared Sub saveDiscomfortScore(procedureId As Integer, discomfortScore As Integer)
        Try
            Dim da As New DataAccess
            da.saveDiscomfortScore(procedureId, discomfortScore)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving comfort score", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Sedation score"
    <WebMethod()>
    Public Shared Sub saveSedationScore(procedureId As Integer, sedationScoreId As Integer, childId As Integer, generalAneathetic As Decimal) 'Added by rony tfs-4075
        Try
            Dim da As New DataAccess
            da.saveSedationScore(procedureId, sedationScoreId, childId, generalAneathetic)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving sedation score", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Procedure extent"
    <WebMethod()>
    Public Shared Sub savePlannedExtent(procedureId As Integer, extentId As Integer)
        Try
            Dim da As New DataAccess
            da.saveProcedurePlannedExtent(procedureId, extentId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error saving planned extent", ex)
            Throw New Exception(ref)
        End Try
    End Sub
    <WebMethod()>
    Public Shared Sub saveWithdrawalTime(procedureId As Integer, minutes As Integer)
        Try
            Dim da As New DataAccess
            da.saveWithdrawalTime(procedureId, minutes, LowerExtent.endoscopipstId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error saving widthdrawal time", ex)
            Throw New Exception(ref)
        End Try
    End Sub

    <WebMethod()>
    Public Shared Sub saveUpperWithdrawalTime(procedureId As Integer, minutes As Integer)
        Try
            Dim da As New DataAccess
            da.saveUpperWithdrawalTime(procedureId, minutes, UpperExtent.endoscopipstId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error saving widthdrawal time", ex)
            Throw New Exception(ref)
        End Try
    End Sub

    <WebMethod()>
    Public Shared Function saveTimeToCaecum(procedureId As Integer, startDateTime As DateTime, selected As Boolean) As String
        Try
            Dim da As New DataAccess
            da.saveTimeToCaecum(procedureId, startDateTime, selected)

            'DB call to calculate withdrawal time
            Dim withdrawalTime = da.calculateWithdrawalTime(procedureId, CInt(ProcedureType.Colonoscopy))
            Return withdrawalTime
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error saving time to caecum time", ex)
            Throw New Exception(ref)
        End Try
    End Function

    <WebMethod()>
    Public Shared Sub saveLowerExtent(procedureId As Integer, extentId As Integer, additionalInfo As String, endoscopistId As Integer, confirmedById As Integer, confirmedByOther As String, caecumIdentifiedById As Integer, limitationId As Integer, difficultyId As Integer, difficultyOther As String,
                                      rectalExam As Integer, retroflexion As Integer, noRetroflexionReason As String,
                                      insertionVia As Integer, limitationOther As String, abandoned As Boolean, intubationFailed As Boolean)
        Try
            Dim da As New DataAccess
            da.saveProcedureLowerExtent(procedureId, extentId, additionalInfo, endoscopistId, confirmedById, confirmedByOther, caecumIdentifiedById, limitationId, difficultyId, difficultyOther, rectalExam, retroflexion, noRetroflexionReason,
                insertionVia, limitationOther, abandoned, intubationFailed)

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving lower extent", ex)
            Throw New Exception(ref)
        End Try
    End Sub

    <WebMethod()>
    Public Shared Sub saveUpperExtent(procedureId As Integer, extentId As Integer, additionalInfo As String, endoscopistId As Integer, jmanoeuvreId As Integer, limitedById As Integer, mucosalJunctionDistance As Integer, limitationOther As String)
        Try
            Dim da As New DataAccess
            Dim objOC As New OrderCommsBL
            da.saveProcedureUpperExtent(procedureId, extentId, additionalInfo, endoscopistId, limitedById, jmanoeuvreId, mucosalJunctionDistance, limitationOther)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving upper extent", ex)
            Throw New Exception(ref)
        End Try
    End Sub

    <WebMethod()>
    Public Shared Sub saveCaecumIdentifiedBy(identifiedById As Integer, childId As Integer, procedureId As Integer, endoscopistId As Integer, checked As Boolean)
        Try
            Dim da As New DataAccess
            da.saveProcedureCaecumIdentifiedBy(identifiedById, childId, procedureId, endoscopistId, checked)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error saving time to caecum time", ex)
            Throw New Exception(ref)
        End Try
    End Sub

    <WebMethod()>
    Public Shared Sub saveInsturments(procedureId As Integer, instrument1Id As Integer, instrument2Id As Integer, distalAttachmentId As Integer, scopeGuideUsed As Boolean?, techniqueUsed As String, techniqueIdx As String)
        Try
            Dim da As New DataAccess
            da.saveProcedureInstruments(procedureId, instrument1Id, instrument2Id, distalAttachmentId, scopeGuideUsed, techniqueUsed, techniqueIdx)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving procedure instruments", ex)
            Throw New Exception(ref)
        End Try
    End Sub
    <WebMethod()>
    Public Shared Function saveManufactuerGeneration(ByVal scopeId As Integer, ByVal scopeGenerationId As Integer)
        Try
            Dim da As New DataAccess

            Dim isSuccessful = da.updateScope(scopeId, scopeGenerationId)

            Return isSuccessful

        Catch ex As Exception
            Throw ex
        End Try
    End Function
    Private Sub PancreasDivisumCheckBox_CheckedChanged(sender As Object, e As EventArgs) Handles PancreasDivisumCheckBox.CheckedChanged
        SetManometry("PancreasDivisum", PancreasDivisumCheckBox.Checked)
        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "reloadsummary", "setRehideSummary();", True)
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

    '<WebMethod()>
    'Public Shared Function ExtentConfirmedList(isLimitationReason As Boolean) As String
    '    Try
    '        Dim da As New DataAccess
    '        Dim dbResult = da.LoadExtentConfirmedList(isLimitationReason)

    '        Dim resultsList As New List(Of Object)

    '        For Each r In dbResult.AsEnumerable

    '            Dim obj = New With {
    '                .uniqueId = CInt(r("UniqueId")),
    '                .description = r("Description").ToString
    '            }
    '            resultsList.Add(obj)
    '        Next

    '        Return New JavaScriptSerializer().Serialize(resultsList)
    '    Catch ex As Exception
    '        LogManager.LogManagerInstance.LogError("error returning extent confirmed by list", ex)
    '        Throw ex
    '    End Try
    'End Function
#End Region

#Region "Procedure Web Methods"
    <WebMethod()>
    Public Shared Function BuildTree(siteId As Integer) As String
        Try
            Return "Site ID is " + siteId.ToString()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error building procedure tree", ex)
            Throw ex
        End Try
    End Function

#End Region

#Region "Procedure timings"
    <WebMethod()>
    Public Shared Function saveProcedureTimings(procedureId As Integer, startDateTime As DateTime?, endDateTime As DateTime?, procedureTypeId As Integer) As String
        Try
            Dim da As New DataAccess
            da.saveProcedureTimings(procedureId, startDateTime, endDateTime)

            'DB call to calculate withdrawal time
            If (procedureTypeId = CInt(ProcedureType.Gastroscopy) And endDateTime > DateTime.MinValue) Or procedureTypeId = CInt(ProcedureType.Colonoscopy) Or procedureTypeId = CInt(ProcedureType.Transnasal) Then
                Dim withdrawalTime = da.calculateWithdrawalTime(procedureId, procedureTypeId)
                Return withdrawalTime
            Else
                Return 0
            End If

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error saving procedure time", ex)
            Throw ex
        End Try
    End Function

    <WebMethod()>
    Public Shared Sub saveGastricInspectionTiming(siteId As Integer, startDateTime As DateTime, endDateTime As DateTime)
        Try
            Dim da As New DataAccess
            da.saveGastricInspectionTimings(siteId, startDateTime, endDateTime)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error saving gastric inspection time", ex)
            Throw ex
        End Try
    End Sub
#End Region

#Region "Distal attachment"
    <WebMethod()>
    Public Shared Sub saveProcedureDistalAttachment(procedureId As Integer, distalAttachmentId As Integer, distalAttachmentOther As String, selected As Boolean)
        Try
            Dim da As New DataAccess
            da.saveProcedureDistalAttachment(procedureId, distalAttachmentId, distalAttachmentOther, selected)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving distal attachment", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "AI Software"
    <WebMethod()>
    Public Shared Sub saveProcedureAISoftware(procedureId As Integer, AISoftwareId As Integer, AISoftwareOther As String, AISoftwareName1 As String, AISoftwareName2 As String)
        Try
            Dim da As New DataAccess
            da.saveProcedureAISoftware(procedureId, AISoftwareId, AISoftwareOther, AISoftwareName1, AISoftwareName2)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving AI software", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Procedure drugs"
    <WebMethod()>
    Public Shared Sub saveProcedureDrugs(procedureId As Integer, drugId As Integer, dose As Decimal, units As String, selected As Boolean)
        Try
            Dim da As New DataAccess
            da.saveProcedureDrugs(procedureId, drugId, dose, units, selected)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving procedure drugs", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region
#Region "Bowel prep"
    <WebMethod()>
    Public Shared Sub saveProcedureBowelPrep(procedureId As Integer, bowelPrepId As Integer, leftScore As Integer, rightScore As Integer, transverseScore As Integer, totalScore As Integer, additionalInfo As String, quantity As Decimal, enemaId As Integer, enemaOther As String)
        Try
            Dim da As New DataAccess
            da.saveBowelPrep(procedureId, bowelPrepId, leftScore, rightScore, transverseScore, totalScore, additionalInfo, quantity, enemaId, enemaOther)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving bowel prep", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Insertion technique"
    <WebMethod()>
    Public Shared Sub saveProcedureInsertionTechnique(procedureId As Integer, techniqueId As Integer)
        Try
            Dim da As New DataAccess
            da.saveInsertionTechnique(procedureId, techniqueId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving insertion technique", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Insertion technique"
    <WebMethod()>
    Public Shared Sub saveProcedureChromendoscopy(procedureId As Integer, chromendoscopyId As Integer, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveProcedureChromendoscopy(procedureId, chromendoscopyId, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving chromendoscopy", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "OGD Mucosal outcomes"
    <WebMethod()>
    Public Shared Sub saveMucosalVisualisation(procedureId As Integer, mucosalVisualisationId As Integer)
        Try
            Dim da As New DataAccess
            da.saveProcedureMucosalVisualisation(procedureId, mucosalVisualisationId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving mucosal visualisation", ex)
            Throw New Exception(ref)
        End Try
    End Sub

    <WebMethod()>
    Public Shared Sub saveMucosalCleaning(procedureId As Integer, mucosalCleaningId As Integer, additionalInfo As String, selected As Boolean)
        Try
            Dim da As New DataAccess
            da.saveProcedureMucosalCleaning(procedureId, mucosalCleaningId, additionalInfo, selected)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving mucosal cleaning", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Insufflation"
    <WebMethod()>
    Public Shared Sub saveInsufflation(procedureId As Integer, insufflationId As Integer)
        Try
            Dim da As New DataAccess
            da.saveProcedureInsufflation(procedureId, insufflationId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving procedure insuflation", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Enteroscopy technique"
    <WebMethod()>
    Public Shared Sub saveEnteroscopyTechnique(procedureId As Integer, techniqueId As Integer, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveProcedureEnteroscopyTechnique(procedureId, techniqueId, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving enteroscopy technique", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Insertion length"
    <WebMethod()>
    Public Shared Sub saveInsertionLength(procedureId As Integer, insertionLength As Integer, tattooed As Boolean)
        Try
            Dim da As New DataAccess
            da.saveProcedureInsertionLength(procedureId, insertionLength, tattooed)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving insertion length", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Level of complexity"
    <WebMethod()>
    Public Shared Sub saveLevelOfComplexity(procedureId As Integer, procedureComplexityId As Integer)
        Try
            Dim da As New DataAccess
            da.saveProcedureLevelOfComplexity(procedureId, procedureComplexityId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving procedure complexity level", ex)
            Throw New Exception(ref)
        End Try
    End Sub

    Protected Sub btnRefreshDiagram_Click(sender As Object, e As EventArgs)
        'SchDiagram.LoadDiagram()
    End Sub

    Protected Sub RefreshDiagramButton_Click(sender As Object, e As EventArgs)
        'SchDiagram.ProcedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID)) 'CInt(node.Attributes("ProcedureId"))
        'SchDiagram.ProcedureTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        'SchDiagram.DiagramNumber = CInt(Session(Constants.SESSION_DIAGRAM_NUMBER))
        'SchDiagram.ImageGenderId = CInt(Session(Constants.SESSION_IMAGE_GENDERID))
        'SchDiagram.LoadDiagram()
        'SchDiagram.Source = "FLIP"
        LoadDiagram()
    End Sub

    Friend Sub LoadDiagram()
        Dim scriptVarStr As String = String.Empty
        Dim regJson As String = String.Empty
        Dim regEbusLymphNodesJson As String = String.Empty
        Dim sitesJson As String = String.Empty
        Dim sImageUrl As Tuple(Of String, String) = GetImageUrl(ProcedureTypeId, DiagramNumber, ImageGenderId)

        regJson = GetRegionPathsJson()
        If regJson = "[]" Then
            scriptStr = "alert('Regions are not defined in the database!');"
        Else
            scriptStr = "LoadBasics();"
            sitesJson = GetSitesDataJson()
            If sitesJson <> "" And sitesJson <> "[]" Then
                scriptStr = "LoadBasics();LoadExistingPatient();"
            End If
        End If

        If ProcedureTypeId = ProcedureType.EBUS Then
            regEbusLymphNodesJson = GetRegionPathsEbusLymphNodesJson()
        End If

        ViewState("_mRegionPathsJson") = regJson
        ViewState("_msitesDataJson") = sitesJson
        ViewState("_mRegionPathsEbusLymphNodesJson") = regEbusLymphNodesJson

        scriptVarStr = "var diagramHeight = '" & DiagramHeight & "';"
        scriptVarStr += "var diagramWidth = '" & DiagramWidth & "';"
        scriptVarStr += "var selectedProcType = '" & ProcedureTypeId & "';"
        scriptVarStr += "var procedureId = '" & procedure_Id & "';"
        scriptVarStr += "var colonType = '" & ColonType & "';"
        scriptVarStr += "var forPrinting = '" & ForPrinting & "';"
        scriptVarStr += "var resectionColonId = '" & GetResectionColon() & "';"
        scriptVarStr += "var currentSiteId;"

        'If ProcedureTypeId = ProcedureType.EBUS Then
        '    scriptVarStr += "var regionPaths = '" & RegionPathsEbusLymphNodesJson & "';"
        'Else
        scriptVarStr += "var regionPaths = '" & regJson & "';"
        'End If

        scriptVarStr += "var resectionColonRegions = '" & GetResectedColonRegionsJson() & "';"
        scriptVarStr += "var existingSites = '" & GetSitesDataJson() & "';"
        scriptVarStr += "var regionPathsEbusLymphNodes = '" & GetRegionPathsEbusLymphNodesJson() & "';"
        scriptVarStr += "var regionPathsProtocolSites = '" & GetRegionPathsProtocolSitesJson() & "';"
        scriptVarStr += "var siteRadius = " & GetSiteRadius() & ";"
        'scriptVarStr += "var imageUrl = '" & GetImageUrl(ProcedureTypeId, DiagramNumber) & "';"
        scriptVarStr += "var imageUrl = '" & sImageUrl.Item1 & "';"
        scriptStr = scriptVarStr & scriptStr
        If ForPrinting Then
            scriptStr = scriptStr & " ReturnSvgXml('" & sImageUrl.Item2 & "');"
        End If
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", scriptStr, True)
        'Page.ClientScript.RegisterStartupScript(Me.GetType(), "CallMyFunction", scriptStr, True)
    End Sub
    Private Function GetImageUrl(procedureType As Integer, diagramNumber As Integer, imageGenderId As Integer) As Tuple(Of String, String)
        Dim da As New DataAccess
        Dim dtDiagram As DataTable = da.GetDiagram(procedureType, diagramNumber, 0, 0, False, imageGenderId)
        If dtDiagram IsNot Nothing AndAlso dtDiagram.Rows.Count > 0 Then
            Return New Tuple(Of String, String)(ResolveUrl(CStr(dtDiagram.Rows(0)("DefaultImageUrl"))),
                                        ResolveUrl(CStr(dtDiagram.Rows(0)("ReportImageUrl"))))
            'Return ResolveUrl(CStr(dtDiagram.Rows(0)("DefaultImageUrl")))
        Else
            Return New Tuple(Of String, String)("", "")
            'Return "",""
        End If
    End Function
    Private Function GetRegionPathsJson() As String
        Dim dtPaths As DataTable
        Dim da As New DataAccess
        dtPaths = da.GetDiagram(ProcedureTypeId, DiagramNumber, DiagramHeight, DiagramWidth, True, ImageGenderId)
        Return DataTableToJson(dtPaths)
    End Function
    Private Function GetSitesDataJson() As String
        Dim dtSites As DataTable
        Dim da As New DataAccess
        dtSites = da.GetSites(procedure_Id, DiagramHeight, DiagramWidth, EpisodeNo, ProcedureTypeId, ColonType)
        Return DataTableToJson(dtSites)
    End Function
    Private Function GetRegionPathsEbusLymphNodesJson() As String
        Dim dtPaths As DataTable
        Dim da As New DataAccess
        dtPaths = da.GetRegionPathsEbusLymphNodes(DiagramHeight, DiagramWidth)
        Return DataTableToJson(dtPaths)
    End Function
    Private Function DataTableToJson(dt As DataTable) As String
        If dt Is Nothing Then Return Nothing
        Dim serializer As System.Web.Script.Serialization.JavaScriptSerializer = New System.Web.Script.Serialization.JavaScriptSerializer()
        Dim rows As New List(Of Dictionary(Of String, Object))
        Dim row As Dictionary(Of String, Object)

        For Each dr As DataRow In dt.Rows
            row = New Dictionary(Of String, Object)
            For Each col As DataColumn In dt.Columns
                row.Add(col.ColumnName, dr(col))
            Next
            rows.Add(row)
        Next
        Return serializer.Serialize(rows)
    End Function
    Private Function GetResectionColon() As String
        If ProcedureTypeId = ProcedureType.Colonoscopy Or ProcedureTypeId = ProcedureType.Bronchoscopy Or ProcedureTypeId = ProcedureType.Sigmoidscopy Or ProcedureTypeId = ProcedureType.Retrograde Then
            Dim da As New DataAccess
            Return da.GetResectedColonDetails(CInt(Session(Constants.SESSION_PROCEDURE_ID)), EpisodeNo, IIf(ProcedureTypeId = ProcedureType.Retrograde, True, False))
        Else
            Return "0"
        End If
    End Function
    Private Function GetResectedColonRegionsJson() As String
        If ProcedureTypeId = ProcedureType.Colonoscopy Or ProcedureTypeId = ProcedureType.Bronchoscopy Or ProcedureTypeId = ProcedureType.Sigmoidscopy Or ProcedureTypeId = ProcedureType.Retrograde Then
            Dim dtResectedColonRegions As DataTable
            Dim da As New DataAccess
            dtResectedColonRegions = da.GetResectedColonRegions()
            Return DataTableToJson(dtResectedColonRegions)
        Else
            Return "[]"
        End If
    End Function
    Private Function GetRegionPathsProtocolSitesJson() As String
        Dim dtPaths As DataTable
        Dim da As New DataAccess
        dtPaths = da.GetRegionPathsProtocolSites(procedure_Id)
        Return DataTableToJson(dtPaths)
    End Function
    Private Function GetSiteRadius() As Integer
        Dim da As New Options
        Dim dtSys As DataTable = da.GetSystemSettings()
        If dtSys.Rows.Count > 0 Then
            Return CInt(dtSys.Rows(0)("SiteRadius"))
        Else
            Return 5
        End If
    End Function
    'Private Sub Flip180Button_Click(sender As Object, e As EventArgs) Handles Flip180Button.Click
    '    If CInt(Session(Constants.SESSION_DIAGRAM_NUMBER) = 1) Then
    '        Session(Constants.SESSION_DIAGRAM_NUMBER) = 2
    '    ElseIf CInt(Session(Constants.SESSION_DIAGRAM_NUMBER) = 2) Then
    '        Session(Constants.SESSION_DIAGRAM_NUMBER) = 1
    '    End If

    '    DataAdapter.UpdateProcedureFlipDiagram(CInt(Session(Constants.SESSION_PROCEDURE_ID)))

    '    SchDiagram.LoadDiagram()
    '    SchDiagram.Source = "FLIP"
    'End Sub
#End Region

#Region "Broncho coding"
    <WebMethod()>
    Public Shared Sub SaveBronchoCoding(ByVal procedureId As Integer,
                                      ByVal codeId As Integer,
                                      ByVal checkboxStatus As Boolean,
                                      ByVal checkboxType As String)
        Try
            Dim da As New OtherData
            da.SaveBronchoCoding(procedureId, codeId, checkboxStatus, checkboxType)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving procedure coding", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Additional notes"

    <WebMethod()>
    Public Shared Sub saveAdditionalNotes(ByVal procedureId As Integer, ByVal additionalNotes As String)
        Try
            Dim da As New OtherData
            da.SaveProcedureAdditionalNotes(procedureId, additionalNotes)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving procedure additional notes", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "EBUS"

    <System.Web.Services.WebMethod()>
    Public Function SaveEbusAbnosData(ByVal siteId As Integer,
                                        ByVal normal As Boolean,
                                        ByVal size As Integer?,
                                        ByVal sizeNum As Integer?,
                                        ByVal shape As Integer?,
                                        ByVal margin As Integer?,
                                        ByVal echoGenecity As Integer?,
                                        ByVal cHS As Integer?,
                                        ByVal cNS As Integer?,
                                        ByVal vascular As Integer?,
                                        ByVal bxType As Integer?,
                                        ByVal noBxTaken As Integer?,
                                        ByVal bxNeedleType As Integer?,
                                        ByVal bxNeedleSize As Integer?,
                                        ByVal bxNeedleSizeUnits As Integer?) As Integer

        Try
            Dim rowsAffected As Integer

            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As SqlCommand = New SqlCommand("abnormalities_ebus_descriptions_save", connection)
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
                cmd.Parameters.Add(New SqlParameter("@Normal", normal))

                If size.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Size", size))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Size", 0))
                End If

                If sizeNum.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@SizeNum", sizeNum))
                Else
                    cmd.Parameters.Add(New SqlParameter("@SizeNum", 0))
                End If

                If shape.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Shape", shape))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Shape", 0))
                End If

                If margin.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Margin", margin))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Margin", 0))
                End If

                If echoGenecity.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@echoGenecity", echoGenecity))
                Else
                    cmd.Parameters.Add(New SqlParameter("@echoGenecity", 0))
                End If

                If cHS.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@CHS", cHS))
                Else
                    cmd.Parameters.Add(New SqlParameter("@CHS", 0))
                End If

                If cNS.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@CNS", cNS))
                Else
                    cmd.Parameters.Add(New SqlParameter("@CNS", 0))
                End If

                If vascular.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@Vascular", vascular))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Vascular", 0))
                End If

                If bxType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxType", bxType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxType", 0))
                End If

                If noBxTaken.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@NoBxTaken", noBxTaken))
                Else
                    cmd.Parameters.Add(New SqlParameter("@NoBxTaken", 0))
                End If

                If bxNeedleType.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleType", bxNeedleType))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleType", -1))
                End If

                If bxNeedleSize.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSize", bxNeedleSize))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSize", 0))
                End If

                If bxNeedleSizeUnits.HasValue Then
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSizeUnits", bxNeedleSizeUnits))
                Else
                    cmd.Parameters.Add(New SqlParameter("@BxNeedleSizeUnits", -1))
                End If

                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
                connection.Open()
                rowsAffected = CInt(cmd.ExecuteNonQuery())
            End Using

            Return rowsAffected

        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in Function: Procedure.SaveEbusAbnosData...", ex)
            Return False
        End Try

    End Function

#End Region

#Region "Vocal cord paralysis"
    <WebMethod()>
    Public Shared Sub saveVocalCordParalysis(procedureId As Integer, vocalCordParalysisId As Integer, additionalInformation As String)
        Try
            Dim da As New DataAccess
            da.saveProcedureVocalCordParalysis(procedureId, vocalCordParalysisId, additionalInformation)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving procedure drugs", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region
#Region "Bronco Drugs"
    <System.Web.Services.WebMethod()>
    Public Shared Sub SaveBronchoDrugs(ByVal procedureId As Integer,
                                     ByVal effectOfSedation As Integer?,
                                     ByVal lignocaineSpray As Boolean,
                                     ByVal lignocaineSprayTotal As Nullable(Of Decimal),
                                     ByVal lignocaineGel As Boolean,
                                     ByVal lignocaineViaScope1pc As Nullable(Of Decimal),
                                     ByVal lignocaineViaScope2pc As Nullable(Of Decimal),
                                     ByVal lignocaineViaScope4pc As Nullable(Of Decimal),
                                     ByVal lignocaineNebuliser2pc As Nullable(Of Decimal),
                                     ByVal lignocaineNebuliser4pc As Nullable(Of Decimal),
                                     ByVal lignocaineTranscricoid2pc As Nullable(Of Decimal),
                                     ByVal lignocaineTranscricoid4pc As Nullable(Of Decimal),
                                     ByVal lignocaineBronchial1pc As Nullable(Of Decimal),
                                     ByVal lignocaineBronchial2pc As Nullable(Of Decimal),
                                     ByVal supplyOxygen As Boolean,
                                     ByVal supplyOxygenPercentage As Nullable(Of Decimal),
                                     ByVal nasal As Nullable(Of Decimal),
                                     ByVal spO2Base As Nullable(Of Decimal),
                                     ByVal spO2Min As Nullable(Of Decimal),
                                     ByVal lignocaineSprayPercentage As Integer?) 'Added by rony tfs-4328
        Try
            Dim da As New OtherData
            da.SaveBronchoDrugs(procedureId,
                                     effectOfSedation,
                                     lignocaineSpray,
                                     lignocaineSprayTotal,
                                     lignocaineGel,
                                     lignocaineViaScope1pc,
                                     lignocaineViaScope2pc,
                                     lignocaineViaScope4pc,
                                     lignocaineNebuliser2pc,
                                     lignocaineNebuliser4pc,
                                     lignocaineTranscricoid2pc,
                                     lignocaineTranscricoid4pc,
                                     lignocaineBronchial1pc,
                                     lignocaineBronchial2pc,
                                     supplyOxygen,
                                     supplyOxygenPercentage,
                                     nasal,
                                     spO2Base,
                                     spO2Min,
                                     lignocaineSprayPercentage)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving imaging method", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region


#Region "Management"

    <System.Web.Services.WebMethod()>   ' SaveDefault field by Ferdowsi
    Public Shared Sub saveManagement(SaveDefault As Boolean, procedureId As Integer, ManagementNone As Boolean, PulseOximetry As Boolean, IVAccess As Boolean, IVAntibiotics As Boolean, Oxygenation As Boolean, OxygenationMethod As Integer, OxygenationFlowRate As Decimal,
                                     ContinuousECG As Boolean, BP As Boolean, BPSystolic As Decimal, BPDiastolic As Decimal, ManagementOther As Boolean, ManagementOtherText As String)
        Try

            Dim UpperGIQA_Record As ERS.Data.ERS_UpperGIQA
            Using db As New ERS.Data.GastroDbEntities
                If db.ERS_UpperGIQA.Any(Function(x) x.ProcedureId = procedureId) Then
                    UpperGIQA_Record = db.ERS_UpperGIQA.Where(Function(x) x.ProcedureId = procedureId).FirstOrDefault
                Else
                    UpperGIQA_Record = New ERS.Data.ERS_UpperGIQA
                    UpperGIQA_Record.ProcedureId = procedureId
                End If

                With UpperGIQA_Record
                    .ManagementNone = ManagementNone
                    .PulseOximetry = PulseOximetry
                    .IVAccess = IVAccess
                    .IVAntibiotics = IVAntibiotics
                    .Oxygenation = Oxygenation
                    If OxygenationMethod > 0 Then .OxygenationMethod = OxygenationMethod
                    If OxygenationMethod > 0 Then .OxygenationFlowRate = OxygenationFlowRate
                    .ContinuousECG = ContinuousECG
                    .BP = BP
                    If BP Then .BPSystolic = BPSystolic
                    If BP Then .BPDiastolic = BPDiastolic
                    .ManagementOther = ManagementOther
                    .ManagementOtherText = ManagementOtherText
                End With

                If UpperGIQA_Record.Id = 0 Then
                    db.ERS_UpperGIQA.Add(UpperGIQA_Record)
                Else
                    db.ERS_UpperGIQA.Attach(UpperGIQA_Record)
                    db.Entry(UpperGIQA_Record).State = Entity.EntityState.Modified
                End If

                db.SaveChanges()
                Dim da As DataAccess = New DataAccess()
                da.Update_UpperGIQA(procedureId)
            End Using

            If (SaveDefault) Then    'added by Ferdowsi
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT) = True
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_NONE) = ManagementNone
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_PULSE_OXIMETRY) = PulseOximetry
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_IV_ACCESS) = IVAccess
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_IV_ANTIBIOTICS) = IVAntibiotics
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION) = Oxygenation
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_METHOD) = OxygenationMethod
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OXYGENATION_FLOW_RATE) = OxygenationFlowRate
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_CONTINOUS_ECG) = ContinuousECG
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_BP) = BP
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_SYSTOLIC_BP) = BPSystolic
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_DIASTOLIC_BP) = BPDiastolic
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OTHER) = ManagementOther
                HttpContext.Current.Session(Constants.SESSION_QA_MANAGEMENT_OTHER_TEXT) = ManagementOtherText
            End If    'added by Ferdowsi


        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error saving management data", ex)
            Throw New Exception(ref, New Exception(ex.Message))
        End Try
    End Sub


#End Region

End Class