Imports System.IO
Imports System.Windows

Public Class preprocedure_aspx
    Inherits PageBase


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            If Request.Cookies("patientId") Is Nothing Then
                MessageBox.Show("Your session expired, please start procedure again..")
                Response.Redirect("~/Products/Default.aspx", False)
            End If

            If DataAccess.ProcedureDNA(CInt(Session(Constants.SESSION_PROCEDURE_ID))).Rows.Count > 0 Then
                ProcNotCarriedOutCheckBox.Checked = True
            End If

            Dim procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            If Session("NewProcedureOpen") = "1" Then
                If ConfigurationManager.AppSettings("IsAzure").ToLower() <> "true" Then
                    Dim portId As Int32
                    Dim portName As String
                    Dim sessionRoomId As String = Session("RoomId")

                    portName = Session("portName")
                    portId = Session("portId")

                    If Not (String.IsNullOrEmpty(portName)) Then

                        Dim sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & portName
                        If Directory.Exists(sourcePath) Then

                            Dim di As New DirectoryInfo(sourcePath)
                            If di.GetFiles().Any(Function(x) x.Extension = ".jpg") OrElse di.GetFiles().Any(Function(x) x.Extension = ".bmp") Then
                                Using lm As New AuditLogManager
                                    lm.WriteActivityLog(EVENT_TYPE.SelectRecord, "New procedure. Images exist on Imageport share: " & portName & ". Procedure: " & Session(Constants.SESSION_PROCEDURE_ID))
                                End Using
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

            If procType = ProcedureType.Bronchoscopy Or procType = ProcedureType.EBUS Or procType = ProcedureType.Flexi Then
                divRequirementsKey.Visible = False
            End If

            If Not (procType = CInt(ProcedureType.Colonoscopy) Or procType = CInt(ProcedureType.Sigmoidscopy) Or procType = CInt(ProcedureType.Retrograde)) Then
                'PreProcFamilyHistory.Visible = False
                fitValueResults.Visible = False
            End If
            If (procType = CInt(ProcedureType.Flexi) Or procType = CInt(ProcedureType.Rigid)) Then
                PreProcPreviousDiseases.Visible = False
                LUTSIPSSSymptomsDiv.Visible = True
                PreviousHistoryUrologyDiv.Visible = True
                UrineDipstickCytologyDiv.Visible = True
                SmokingDiv.Visible = True
                CystoscopyHeaderDiv.Visible = True
                populateCystoScopyType()
                StagingDiv.Visible = False
            Else
                LUTSIPSSSymptomsDiv.Visible = False
                PreviousHistoryUrologyDiv.Visible = False
                UrineDipstickCytologyDiv.Visible = False
                SmokingDiv.Visible = False
                StagingDiv.Visible = False
            End If

            If Not (procType = CInt(ProcedureType.ERCP) And Not procType = ProcedureType.EUS_HPB) Then
                PreProcImaging.Visible = False
            End If

            If (procType = CInt(ProcedureType.EBUS) Or procType = (ProcedureType.Bronchoscopy)) Then
                PreProcASAStatus.Visible = False
                'PreProcFamilyHistory.Visible = False
                PreProcPreviousDiseases.Visible = False
                PreviousHistoryDiv.Visible = False

                PreProcReferralData.Visible = True
                StagingDiv.Visible = True
            End If

            ProcedureTypeLabel.Text = DataHelper.GetProcedureName("Pre procedure", procType)
        End If
    End Sub

    Protected Sub Page_Prerender(sender As Object, e As EventArgs)

    End Sub
    Sub populateCystoScopyType()
        Dim dataAccess As New DataAccess()

        ' CystoscopyType.DataTextField = "CystoscopyTypeText"
        ' CystoscopyType.DataValueField = "CystoscopyTypeId"
        ' CystoscopyType.DataSource = dataAccess.GetCystoscopyType()
        ' CystoscopyType.DataBind()
    End Sub

    Sub reloadSummary()
        Dim SummaryListView As ListView = DirectCast(Master.FindControl("SummaryListView"), ListView)
        SummaryListView.DataBind()

        Dim PremedSummaryListView As ListView = DirectCast(Master.FindControl("PremedSummaryListView"), ListView)
        PremedSummaryListView.DataBind()
    End Sub


    Private Sub RemoveImages_Click(sender As Object, e As EventArgs) Handles RemoveImages.Click
        Dim portId As Int32
        Dim portName As String
        Dim sessionRoomId As String = Session("RoomId")

        portName = Session("PortName")
        portId = Session("portId")


        If Not (String.IsNullOrEmpty(portName)) Then

            Dim sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & portName
            If Not Directory.Exists(sourcePath) Then Exit Sub
            Using lm As New AuditLogManager
                lm.WriteActivityLog(EVENT_TYPE.Delete, "Removing images from Imageport: " & portName & " for procedure: " & Session(Constants.SESSION_PROCEDURE_ID))
            End Using
            Dim di As New DirectoryInfo(sourcePath)
            Dim fiArr As FileInfo() = di.GetFiles()
            For Each fil As FileInfo In fiArr
                If fil.Extension = ".bmp" OrElse fil.Extension = ".jpg" OrElse fil.Extension = ".mp4" Then
                    If Not Directory.Exists(TempPhotosFolderPath) Then Directory.CreateDirectory(TempPhotosFolderPath)
                    If File.Exists(TempPhotosFolderPath & "\" & portName & fil.Name) Then
                        File.Delete(TempPhotosFolderPath & "\" & portName & fil.Name)
                    End If
                    File.Move(fil.FullName, TempPhotosFolderPath & "\" & portName & fil.Name)
                Else
                    File.Delete(fil.FullName)
                End If
            Next
        End If
        ImagesExistRadWindow.Visible = False
        ImagesExistRadWindow.VisibleOnPageLoad = False
    End Sub

#Region "Previous Diseases"
    <System.Web.Services.WebMethod()>
    Public Shared Sub savePreviousDisease(procedureId As Integer, patientId As Integer, previousDiseaseId As Integer, checked As Boolean, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.savePreviousDisease(procedureId, patientId, previousDiseaseId, checked, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving previous disease", ex)
            Throw New Exception(ref, New Exception("There was an error saving previous diseases"))
        End Try
    End Sub
#End Region

#Region "Previous Surgery"
    <System.Web.Services.WebMethod()>
    Public Shared Sub savePreviousSurgery(procedureId As Integer, patientId As Integer, previousSurgeryId As String, previousSurgeryPeriod As String)
        Try
            Dim da As New DataAccess
            da.savePreviousSurgery(procedureId, patientId, previousSurgeryId, previousSurgeryPeriod)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving previous surgery", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Allergies"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveAllergy(procedureId As Integer, allergyResult As Integer, allergyDescription As String, patientId As Integer)
        Try
            Dim da As New DataAccess
            da.saveAllergy(procedureId, allergyResult, allergyDescription, patientId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving allergies", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Damaging Drugs"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveAntiCoagDrugStatus(procedureId As Integer, drugStatus As String, potentialSignificantStatus As String) 'Added by rony tfs-4171
        Try
            Dim da As New DataAccess
            da.saveAntiCoagDrugStatus(procedureId, drugStatus, potentialSignificantStatus)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving damaging drugs", ex)
            Throw New Exception(ref)
        End Try
    End Sub


    <System.Web.Services.WebMethod()>
    Public Shared Sub deleteAntiCoagDrug(procedureId As Integer)
        Try
            Dim da As New DataAccess
            da.deleteProcedureAntiCoagDrug(procedureId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error deleting anti-coag drugs", ex)
            Throw New Exception(ref)
        End Try
    End Sub
    <System.Web.Services.WebMethod()>
    Public Shared Function saveDamagingDrug(procedureId As Integer, drugId As String, antiCoag As Integer, sectionName As String, newText As String, potentialSignificantStatus As String, antiCoagOtherText As String) 'Added by rony tfs-4171
        Try
            Dim da As New DataAccess
            Dim newDrugId As Integer? = da.saveDamagingDrug(procedureId, drugId, antiCoag, sectionName, newText, potentialSignificantStatus, antiCoagOtherText)
            Return newDrugId
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving damaging drugs", ex)
            Throw New Exception(ref)
        End Try
    End Function
#End Region

#Region "Comorbidity"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveComorbidity(procedureId As Integer?, preAssessmentId As Integer?, comorbidityId As Integer, childId As Integer, checked As Boolean, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveComorbidity(procedureId, preAssessmentId, comorbidityId, childId, checked, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving comorbidity", ex)
            Throw New Exception(ref)
        End Try
    End Sub

#End Region

#Region "Indications"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveIndication(procedureId As Integer, indicationId As Integer, childId As Integer, checked As Boolean, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveIndication(procedureId, indicationId, childId, checked, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving indications", ex)
            Throw New Exception(ref)
        End Try
    End Sub
    '<System.Web.Services.WebMethod()>
    'Public Shared Sub savePreviousDiseaseUrology(procedureId As Integer, previousDiseaseId As Integer, checked As Boolean, additionalInfo As String, selectedRenalUretericSurgeryId As Int16, isDropdownChange As Boolean)
    '    Try
    '        Dim da As New DataAccess
    '        da.savePreviousDiseaseUrology(procedureId, previousDiseaseId, checked, additionalInfo, selectedRenalUretericSurgeryId, isDropdownChange)
    '    Catch ex As Exception
    '        LogManager.LogManagerInstance.LogError("error autosaving Previous Disease Urology ", ex)
    '        Throw ex
    '    End Try
    'End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub saveUrineDipstickCytology(procedureId As Integer, previousDiseaseId As Integer, checked As Boolean, additionalInfo As String, childId As Int64, dateSent As String)
        Try
            Dim da As New DataAccess
            da.saveUrineDipstickCytology(procedureId, previousDiseaseId, checked, additionalInfo, childId, dateSent)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error autosaving Previous Disease Urology ", ex)
            Throw ex
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub savePreviousDiseaseUrology(procedureId As Integer, previousDiseaseId As Integer, checked As Boolean, additionalInfo As String, childId As Int64)
        Try
            Dim da As New DataAccess
            da.savePreviousDiseaseUrology(procedureId, previousDiseaseId, checked, additionalInfo, childId)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error autosaving Previous Disease Urology ", ex)
            Throw ex
        End Try
    End Sub
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveLUTSIPSSScore(procedureId As Integer, LUTSIPSSSymptomId As Integer, IsScore As Boolean, SelectedScoreId As Integer, TotalScoreValue As Integer)
        Try
            Dim da As New DataAccess
            da.saveLUTSIPSSSymptoms(procedureId, LUTSIPSSSymptomId, IsScore, SelectedScoreId, TotalScoreValue)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error autosaving indication", ex)
            Throw ex
        End Try
    End Sub
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveSmoking(procedureId As Integer, PatientId As Integer, SmokingTypeId As Integer, SmokingStatus As String, AverageSmoking As Integer?, SmokingNoYear As Integer?, SmokedQuitYears As Integer, SmokedPerday As Integer, SmokedNoYear As Integer)
        Try
            Dim da As New DataAccess
            da.saveSmoking(procedureId, PatientId, SmokingTypeId, SmokingStatus, AverageSmoking, SmokingNoYear, SmokedQuitYears, SmokedPerday, SmokedNoYear)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error saving Smoking", ex)
            Throw ex
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub saveAlcoholing(procedureId As Integer, PatientId As Integer, AlcoholingTypeId As Integer, AlcoholingStatus As String, AverageAlcoholing As Integer?, AlcoholingNoYear As Integer?, AlcoholedQuitYears As Integer, AlcoholedPerday As Integer, AlcoholedNoYear As Integer)
        Try
            Dim da As New DataAccess
            da.saveAlcoholing(procedureId, PatientId, AlcoholingTypeId, AlcoholingStatus, AverageAlcoholing, AlcoholingNoYear, AlcoholedQuitYears, AlcoholedPerday, AlcoholedNoYear)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error saving Smoking", ex)
            Throw ex
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub saveCystoscopyHeader(procedureId As Integer, CystoscopyTypeId As String, CystoscopyProcedureType As String)
        Try
            Dim da As New DataAccess
            da.saveCystoscopyHeader(procedureId, CystoscopyTypeId, CystoscopyProcedureType)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error saving Cystoscopy Header", ex)
            Throw ex
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function getSmokingDeatail(procedureId As Integer) As String
        Try
            Dim da As New DataAccess
            Return datatableToJSON(da.GetSmokingDetails(procedureId))
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error retrieving  smoking ", ex)
            Throw ex
        End Try
    End Function
    <System.Web.Services.WebMethod()>
    Public Shared Function getAlcoholingDeatail(procedureId As Integer) As String
        Try
            Dim da As New DataAccess
            Return datatableToJSON(da.GetAlcoholingDetails(procedureId))
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error retrieving  smoking ", ex)
            Throw ex
        End Try
    End Function

    Public Shared Function datatableToJSON(dt As DataTable)
        Dim dict As Dictionary(Of String, Object) = New Dictionary(Of String, Object)()
        Dim arr As Object() = New Object(dt.Rows.Count - 1) {}
        For i As Integer = 0 To dt.Rows.Count - 1
            arr(i) = dt.Rows(i).ItemArray
        Next
        dict.Add("details", arr)



        Dim serialize As New System.Web.Script.Serialization.JavaScriptSerializer()
        Return serialize.Serialize(dict.Item("details"))

    End Function

    <System.Web.Services.WebMethod()>
    Public Shared Sub DeleteSmoking(ProcedureSmokingId As Integer)
        Try
            Dim da As New DataAccess
            da.DeleteSmoking(ProcedureSmokingId)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error removing smoking", ex)
            Throw ex
        End Try
    End Sub
    <System.Web.Services.WebMethod()>
    Public Shared Sub DeleteAlcoholing(ProcedureSmokingId As Integer)
        Try
            Dim da As New DataAccess
            da.DeleteAlcoholing(ProcedureSmokingId)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("error removing smoking", ex)
            Throw ex
        End Try
    End Sub
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveSubIndication(procedureId As Integer, subIndicationId As Integer, checked As Boolean, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveSubIndication(procedureId, subIndicationId, checked, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving sub-indications", ex)
            Throw New Exception(ref)
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub deleteSubIndications(procedureId As Integer)
        Try
            Dim da As New DataAccess
            da.deleteSubIndications(procedureId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error deleting sub=-indications", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Family disease history"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveFamilyHistory(procedureId As Integer, patientId As Integer, familyDiseaseId As Integer, checked As Boolean, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveFamilyDiseaseHistory(procedureId, patientId, familyDiseaseId, checked, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving family disease history", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Imaging"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveImagingMethod(procedureId As Integer, imagingMethodId As Integer, checked As Boolean, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveImagingMethod(procedureId, imagingMethodId, checked, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving imaging method", ex)
            Throw New Exception(ref)
        End Try
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Sub saveImagingOutcome(procedureId As Integer, imagingOutcomeId As Integer, childOutcomeId As Integer, checked As Boolean, additionalInfo As String)
        Try
            Dim da As New DataAccess
            da.saveImagingOutcome(procedureId, imagingOutcomeId, childOutcomeId, checked, additionalInfo)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving imaging outcome", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "ASA Status"
    <System.Web.Services.WebMethod()>
    Public Shared Sub savePatientASAStatus(procedureId As Integer, patientId As Integer, asaStatusId As Integer)
        Try
            Dim da As New DataAccess
            da.savePatientASAStatus(patientId, procedureId, asaStatusId)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving asa status", ex)
            Throw New Exception(ref)
        End Try
    End Sub

#End Region

#Region "Referral Data"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveReferralData(procedureId As Integer, dateBronchRequested As DateTime?, dateOfReferral As DateTime?, lcaSuspectedBySpecialist As Boolean, CTScanAvailable As Boolean, dateOfScan As DateTime?)
        Try
            Dim da As New DataAccess
            Dim offsetMinutes As Integer = CInt(HttpContext.Current.Session("TimezoneOffset"))
            If dateBronchRequested IsNot Nothing Then
                dateBronchRequested = dateBronchRequested.Value.AddMinutes(-offsetMinutes)
            End If
            If dateOfReferral IsNot Nothing Then
                dateOfReferral = dateOfReferral.Value.AddMinutes(-offsetMinutes)
            End If
            If dateOfScan IsNot Nothing Then
                dateOfScan = dateOfScan.Value.AddMinutes(-offsetMinutes)
            End If
            da.saveBronchoReferralData(procedureId, dateBronchRequested, dateOfReferral, lcaSuspectedBySpecialist, CTScanAvailable, dateOfScan)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving imaging method", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region



    <System.Web.Services.WebMethod()>
    Public Shared Function saveNewTextEntry(sectionName As String, newText As String) As Integer
        Try
            Dim da As New DataAccess
            Return da.saveNewTextEntry(sectionName, newText)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving new text entry", ex)
            Throw New Exception(ref)
        End Try
    End Function

#Region "Bronco Staging"
    <System.Web.Services.WebMethod()>
    Public Shared Function SaveBroncoStaging(procedureId As Integer,
                                             stagingInvestigations As Boolean,
                                             clinicalGrounds As Boolean,
                                             imagingOfThorax As Boolean,
                                             pleuralHistology As Boolean,
                                             mediastinalSampling As Boolean,
                                             metastases As Boolean,
                                             bronchoscopy As Boolean,
                                             stage As Boolean,
                                             stageT As Nullable(Of Integer),
                                             stageN As Nullable(Of Integer),
                                             stageM As Nullable(Of Integer),
                                             stageLocation As Nullable(Of Integer),
                                             performanceStatus As Boolean,
                                             performanceStatusType As Nullable(Of Integer))
        Try
            Dim da As New OtherData
            Return da.SaveBroncoStaging(procedureId, stagingInvestigations, clinicalGrounds, imagingOfThorax, pleuralHistology, mediastinalSampling, metastases,
                                        bronchoscopy, stage, stageT, stageN, stageM, stageLocation, performanceStatus, performanceStatusType)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving staging entry", ex)
            Throw New Exception(ref)
        End Try

    End Function
#End Region

#Region "FIT"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveProcedureFIT(FITValue As String, FITNotKnownId As Integer, procedureId As Integer, selected As Boolean)
        Try
            Dim da As New DataAccess
            da.saveProcedureFIT(FITValue, FITNotKnownId, procedureId, selected)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("error autosaving FIT entry", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

#Region "Repeat Procedure"
    <System.Web.Services.WebMethod()>
    Public Shared Sub saveRepeatProcedure(procedureId As Integer, selectedAnswer As Boolean, repeatUnknownValue As Integer, otherTextValue As String)
        Try
            Dim da As New DataAccess
            da.saveRepeatProcedure(procedureId, selectedAnswer, repeatUnknownValue, otherTextValue)
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error auto-saving repeat procedure entry", ex)
            Throw New Exception(ref)
        End Try
    End Sub
#End Region

End Class