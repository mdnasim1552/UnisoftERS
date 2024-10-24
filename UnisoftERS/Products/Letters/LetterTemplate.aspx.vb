Imports System.Data.SqlClient
Imports System.IO
Imports DevExpress.Web

Imports DevExpress.Web.Office
Imports DevExpress.XtraRichEdit
Imports Telerik.Web.UI

Public Class LetterTemplate
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ASPxRichEdit1.DataSource = MergeDataModels.GetPatientData()
        ASPxRichEdit1.DataBind()


        If Not Me.IsPostBack Then

            Dim LetterTypeId = Request.QueryString("LetterTypeId")
            If Not (LetterTypeId = Nothing) Then
                'Dim da As New LetterGeneration()
                'Dim datatable = da.GetAdditionalDocumentFoId(CType(LetterTypeId, Long))

                hdnLetterTypeId.Value = LetterTypeId
                Dim dataRow = GetTemplateData(LetterTypeId)
                Dim OperationalHospitalId = CType(dataRow("OperationalHospitalId"), Long)
                PopulateHospitalDropDownList(OperationalHospitalId)
                PopulateLetterNameDropdown(OperationalHospitalId, LetterTypeId)
                PopulateCreateLetterNameDropdown(OperationalHospitalId)
                PopulateRichEdit(LetterTypeId, CType(dataRow("LetterContent"), Byte()))
                SaveButton.Enabled = True
                SaveButton.Text = "Update"
                '  DisabledDropdown()
            Else
                PopulateHospitalDropDownList()
                PopulateDropdowns(CInt(Session("OperatingHospitalID")))
                SaveButton.Enabled = False
            End If





        End If

    End Sub
    Protected Sub ASPxCallbackPanel1_Callback(ByVal sender As Object, ByVal e As CallbackEventArgsBase)
        ASPxRichEdit1.[New]()
        ASPxRichEdit1.DataSource = MergeDataModels.GetPatientData()
        ASPxRichEdit1.DataBind()
    End Sub
    Protected Sub CloseButton_Click(ByVal sender As Object, ByVal e As EventArgs)
        If ASPxRichEdit1.DocumentId <> "" Then
            DocumentManager.CloseDocument(ASPxRichEdit1.DocumentId)
        End If
        Response.Redirect("ListLetterTemplate.aspx", False)
    End Sub

    Private Sub PopulateLetterNameDropdown(OperationalHospitalId As Long, Optional LetterTypeId As Long? = 0)
        Dim da As New LetterGeneration
        LetterNameDropdown.Items.Clear()
        LetterNameDropdown.Items.Insert(0, "Select Letter Template")
        LetterNameDropdown.AppendDataBoundItems = True
        LetterNameDropdown.DataSource = da.GetLetterType(OperationalHospitalId)
        LetterNameDropdown.DataBind()
        If Not LetterTypeId = 0 Then
            LetterNameDropdown.SelectedValue = LetterTypeId
        End If
    End Sub
    Private Sub PopulateCreateLetterNameDropdown(OperationalHospitalId As Long)
        Dim da As New LetterGeneration
        CreateLetterNameDropdown.Items.Clear()
        CreateLetterNameDropdown.Items.Insert(0, "Select Letter")
        CreateLetterNameDropdown.AppendDataBoundItems = True
        CreateLetterNameDropdown.DataSource = da.GetLetterTypeWithoutTemplate(OperationalHospitalId)
        CreateLetterNameDropdown.DataBind()
    End Sub
    Private Sub PopulateHospitalDropDownList(Optional OperationalHospitalId As Long? = 0)
        Dim da As New LetterGeneration
        HospitalDropDownList.Items.Clear()
        HospitalDropDownList.AppendDataBoundItems = True
        HospitalDropDownList.DataSource = da.GetOperatingHospitals(CInt(Session("TrustId")))
        HospitalDropDownList.DataBind()
        If Not OperationalHospitalId = 0 Then
            HospitalDropDownList.SelectedValue = OperationalHospitalId
        End If
    End Sub

    Private Sub DisabledDropdown()
        HospitalDropDownList.Enabled = False
        CreateLetterNameDropdown.Enabled = False
        LetterNameDropdown.Enabled = False
    End Sub
    Protected Sub LetterNameDropdown_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)
        If Not LetterNameDropdown.SelectedIndex = 0 Then
            Dim LetterId As String = LetterNameDropdown.SelectedValue
            If LetterId = "0" Then
                LetterName.Text = ""
            Else
                LetterName.Text = LetterNameDropdown.SelectedItem.Text
            End If
            CreateLetterNameDropdown.SelectedIndex = 0
            SaveButton.Enabled = True
            SaveButton.Text = "Update"
            Dim dataRow = GetTemplateData(LetterNameDropdown.SelectedValue)
            PopulateRichEdit(LetterNameDropdown.SelectedValue, CType(dataRow("LetterContent"), Byte()))
        Else
            ASPxRichEdit1.New()
            SaveButton.Enabled = False
        End If
    End Sub
    Protected Sub PopulateRichEdit(templateId As Long, LetterContent As Byte())


        ASPxRichEdit1.Open(templateId, DocumentFormat.Rtf, Function()
                                                               Dim docBytes() As Byte = LetterContent
                                                               Return New MemoryStream(docBytes)
                                                           End Function)

    End Sub

    Private Function GetTemplateData(templateId As Long) As DataRow
        Dim da As New LetterGeneration
        Dim datatable As DataTable = da.GetTemapletDataForTemplateId(templateId)
        If datatable.Rows.Count <> 0 Then
            Return datatable.Rows(0)
        Else
            Return Nothing
        End If
    End Function


    Protected Sub CreateLetterNameDropdown_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)
        If Not CreateLetterNameDropdown.SelectedIndex = 0 Then
            Dim LetterId As String = CreateLetterNameDropdown.SelectedValue
            If LetterId = "0" Then
                LetterName.Text = ""
            Else
                LetterName.Text = CreateLetterNameDropdown.SelectedItem.Text
            End If
            LetterNameDropdown.SelectedIndex = 0
            SaveButton.Enabled = True
            SaveButton.Text = "Save"
            ASPxRichEdit1.New()
        Else
            ASPxRichEdit1.New()
            SaveButton.Enabled = False
        End If

    End Sub

    Protected Sub SaveButton_Click(ByVal sender As Object, ByVal e As EventArgs)
        If (CreateLetterNameDropdown.SelectedIndex = 0 And LetterNameDropdown.SelectedIndex = 0) Then
            ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", "ShowMessage()", True)
        Else
            ASPxRichEdit1.Save()

        End If
    End Sub

    Protected Sub RichEdit_Saving(ByVal source As Object, ByVal e As DocumentSavingEventArgs)
        ' Save document with the Ribbon Save button
        Try
            e.Handled = True
            Dim da As New LetterGeneration
            If SaveButton.Text = "Save" Then
                Dim selectedValue = CreateLetterNameDropdown.SelectedValue
                Dim selectedText = CreateLetterNameDropdown.SelectedText
                Dim templateId = da.GetTemplateIdForAppontmentStatusId(selectedValue, HospitalDropDownList.SelectedValue)
                If templateId = 0 Then
                    da.InsertTemplate(CreateLetterNameDropdown.SelectedValue, LetterName.Text, ASPxRichEdit1.SaveCopy(DocumentFormat.Rtf), HospitalDropDownList.SelectedValue)

                    PopulateLetterNameDropdown(HospitalDropDownList.SelectedValue)
                    PopulateCreateLetterNameDropdown(HospitalDropDownList.SelectedValue)
                    SaveButton.Text = "Update"
                    LetterNameDropdown.SelectedIndex = LetterNameDropdown.FindItemByText(selectedText).Index
                    LetterNameDropdown_SelectedIndexChanged(Nothing, Nothing)
                Else
                    da.UpdateTemplate(Convert.ToDecimal(templateId), ASPxRichEdit1.SaveCopy(DocumentFormat.Rtf))
                End If

            Else
                da.UpdateTemplate(Convert.ToDecimal(LetterNameDropdown.SelectedValue), ASPxRichEdit1.SaveCopy(DocumentFormat.Rtf))
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured During Letter template save.", ex)
            Utilities.SetErrorNotificationStyle(LetterPrintRadNotification, errorLogRef, "Error During Template Save.")
            LetterPrintRadNotification.Show()
        End Try
    End Sub
    Protected Sub HospitalDropDownList_SelectedIndexChanged(sender As Object, e As DropDownListEventArgs)
        PopulateDropdowns(HospitalDropDownList.SelectedValue)
        ASPxRichEdit1.New()
        SaveButton.Enabled = False
    End Sub

    Protected Sub PopulateDropdowns(selectedHospital As Integer)
        PopulateLetterNameDropdown(selectedHospital)
        PopulateCreateLetterNameDropdown(selectedHospital)
        LetterNameDropdown.SelectedIndex = 0
        CreateLetterNameDropdown.SelectedIndex = 0
    End Sub

End Class

Public NotInheritable Class MergeDataModels
    Private Sub New()
    End Sub
    Public Shared Function GetPatientData() As List(Of PatientMergeModel)
        Dim ds = New List(Of PatientMergeModel)()
        'For i As Integer = 0 To 9
        '    ds.Add(New PatientMergeModel With {.Title = "Title_1_" & i, .FirstName = "First Name_1_" & i, .LastName = "LastName_1_" & i, .Address = "Address_1_" & i})
        'Next i
        Return ds
    End Function

End Class

Public Class PatientMergeModel

    Public Property ListOfPatientInformation() As String
        Get

        End Get
        Set(ByVal value As String)

        End Set
    End Property
    Private privatePatientTitle As String
    Public Property Title() As String
        Get
            Return privatePatientTitle
        End Get
        Set(ByVal value As String)
            privatePatientTitle = value
        End Set
    End Property
    Private privatePatientFirstName As String
    Public Property FirstName() As String
        Get
            Return privatePatientFirstName
        End Get
        Set(ByVal value As String)
            privatePatientFirstName = value
        End Set
    End Property
    Private privatePatientLastName As String
    Public Property LastName() As String
        Get
            Return privatePatientLastName
        End Get
        Set(ByVal value As String)
            privatePatientLastName = value
        End Set
    End Property
    Private privatePatientAddress1 As String
    Public Property Address1() As String
        Get
            Return privatePatientAddress1
        End Get
        Set(ByVal value As String)
            privatePatientAddress1 = value
        End Set
    End Property
    Private privatePatientAddress2 As String
    Public Property Address2() As String
        Get
            Return privatePatientAddress2
        End Get
        Set(ByVal value As String)
            privatePatientAddress2 = value
        End Set
    End Property
    Private privatePatientAddress3 As String
    Public Property Address3() As String
        Get
            Return privatePatientAddress3
        End Get
        Set(ByVal value As String)
            privatePatientAddress3 = value
        End Set
    End Property
    Private privatePatientAddress4 As String
    Public Property Address4() As String
        Get
            Return privatePatientAddress4
        End Get
        Set(ByVal value As String)
            privatePatientAddress4 = value
        End Set
    End Property
    Private privatePatientPostCode As String
    Public Property PostCode() As String
        Get
            Return privatePatientPostCode
        End Get
        Set(ByVal value As String)
            privatePatientPostCode = value
        End Set
    End Property
    Private privatePatientDateOfBirth As String
    Public Property DateOfBirth() As String
        Get
            Return privatePatientDateOfBirth
        End Get
        Set(ByVal value As String)
            privatePatientDateOfBirth = value
        End Set
    End Property

    Private privatePatientHospitalNumber As String
    Public Property HospitalNumber() As String
        Get
            Return privatePatientHospitalNumber
        End Get
        Set(ByVal value As String)
            privatePatientHospitalNumber = value
        End Set
    End Property
    Private privatePatientNHSNo As String
    Public Property NHSNo() As String
        Get
            Return privatePatientNHSNo
        End Get
        Set(ByVal value As String)
            privatePatientNHSNo = value
        End Set
    End Property
    Private privateGPName As String
    Public Property GPName() As String
        Get
            Return privateGPName
        End Get
        Set(ByVal value As String)
            privateGPName = value
        End Set
    End Property

    Public Property ListOfAppointmentInformation() As String
        Get

        End Get
        Set(ByVal value As String)

        End Set
    End Property
    Private privateAppointmentReferrer As String
    Public Property Referrer() As String
        Get
            Return privateAppointmentReferrer
        End Get
        Set(ByVal value As String)
            privateAppointmentReferrer = value
        End Set
    End Property
    Private privateConsultantName As String
    Public Property ConsultantName() As String
        Get
            Return privateConsultantName
        End Get
        Set(ByVal value As String)
            privateConsultantName = value
        End Set
    End Property
    Private privateAppointmentTemplateName As String
    Public Property TemplateName() As String
        Get
            Return privateAppointmentTemplateName
        End Get
        Set(ByVal value As String)
            privateAppointmentTemplateName = value
        End Set
    End Property
    Private privateAppointmentLetterComment As String
    Public Property LetterComment() As String
        Get
            Return privateAppointmentLetterComment
        End Get
        Set(ByVal value As String)
            privateAppointmentLetterComment = value
        End Set
    End Property
    Private privateAppointmentDueArrivalTime As String
    Public Property DueArrivalTime() As String
        Get
            Return privateAppointmentDueArrivalTime
        End Get
        Set(ByVal value As String)
            privateAppointmentDueArrivalTime = value
        End Set
    End Property

    Private privateAppointmentDueArrivalDate As String
    Public Property DueArrivalDate() As String
        Get
            Return privateAppointmentDueArrivalDate
        End Get
        Set(ByVal value As String)
            privateAppointmentDueArrivalDate = value
        End Set
    End Property

    Private privateAppointmentStartDate As String
    Public Property AppointmentStartDate() As String
        Get
            Return privateAppointmentStartDate
        End Get
        Set(ByVal value As String)
            privateAppointmentStartDate = value
        End Set
    End Property
    Private privateAppointmentStartTime As String
    Public Property AppointmentStartTime() As String
        Get
            Return privateAppointmentStartTime
        End Get
        Set(ByVal value As String)
            privateAppointmentStartTime = value
        End Set
    End Property

    Private privateAppointmentDuration As String
    Public Property AppointmentDuration() As String
        Get
            Return privateAppointmentDuration
        End Get
        Set(ByVal value As String)
            privateAppointmentDuration = value
        End Set
    End Property
    Private privateAppointmentCancelBy As String
    Public Property AppointmentCancelBy() As String
        Get
            Return privateAppointmentCancelBy
        End Get
        Set(ByVal value As String)
            privateAppointmentCancelBy = value
        End Set
    End Property
    Private privateAppointmentCancelReason As String
    Public Property CancelReason() As String
        Get
            Return privateAppointmentCancelReason
        End Get
        Set(ByVal value As String)
            privateAppointmentCancelReason = value
        End Set
    End Property
    Private privateAppointmentCancelComment As String
    Public Property CancelComment() As String
        Get
            Return privateAppointmentCancelComment
        End Get
        Set(ByVal value As String)
            privateAppointmentCancelComment = value
        End Set
    End Property
    Private privateAppointmentProcedures As String
    Public Property ProceduresName() As String
        Get
            Return privateAppointmentProcedures
        End Get
        Set(ByVal value As String)
            privateAppointmentProcedures = value
        End Set
    End Property
    Private privateAppointmentGeneralInformation As String
    Public Property GeneralInformation() As String
        Get
            Return privateAppointmentGeneralInformation
        End Get
        Set(ByVal value As String)
            privateAppointmentGeneralInformation = value
        End Set
    End Property
    Private privateAppointmenNotes As String
    Public Property Notes() As String
        Get
            Return privateAppointmenNotes
        End Get
        Set(ByVal value As String)
            privateAppointmenNotes = value
        End Set
    End Property
End Class
