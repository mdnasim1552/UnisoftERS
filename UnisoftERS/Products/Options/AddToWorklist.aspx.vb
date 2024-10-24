Imports DevExpress.CodeParser
Imports DevExpress.Data.Helpers

Public Class AddToWorklist
    Inherits System.Web.UI.Page
    Dim dataaccess As New DataAccess
    Property oWorklistOptions As WorkListOptions
        Get
            Dim wlo As New WorkListOptions
            If Not IsNothing(Session("WLOEndoscopistId")) Then
                wlo.EndoscopistId = Session("WLOEndoscopistId")
                wlo.ProcedureTypeId = Session("WLOProcedureTypeId")
                wlo.ScheduledDate = Session("WLOScheduledDate")
                wlo.RoomId = Session("WLORoomId")
                Return wlo
            Else
                Return Nothing
            End If
        End Get
        Set(value As WorkListOptions)
            Session("WLOEndoscopistId") = value.EndoscopistId
            Session("WLOProcedureTypeId") = value.ProcedureTypeId
            Session("WLOScheduledDate") = value.ScheduledDate
            Session("WLORoomId") = value.RoomId
        End Set
    End Property

    ReadOnly Property PatientId As Integer
        Get
            Return CInt(Request.QueryString("PatientId"))

        End Get
    End Property
    Private _dataAdapter_Sch As DataAccess_Sch = Nothing
    Protected ReadOnly Property DataAdapter_Sch() As DataAccess_Sch
        Get
            If _dataAdapter_Sch Is Nothing Then
                _dataAdapter_Sch = New DataAccess_Sch
            End If
            Return _dataAdapter_Sch
        End Get
    End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim intSCIStorePatientID As Integer = 0
        Dim intSELocalDBPatientID As Integer = 0

        If Not Page.IsPostBack Then
            'ProcedureTypesDataSource.ConnectionString = DataAccess.ConnectionStr
            '
            Dim dt As DataTable = dataaccess.GetProcedureTypes()
            ProcedureTypesCheckBoxList.DataTextField = "ProcedureType"
            ProcedureTypesCheckBoxList.DataValueField = "ProcedureTypeId"
            ProcedureTypesCheckBoxList.DataSource = dt
            ProcedureTypesCheckBoxList.DataBind()
            ' Add a default selected item programmatically
            ProcedureTypesCheckBoxList.Items.Insert(0, New ListItem("Any/Unknown", "0"))
            ProcedureTypesCheckBoxList.Items(0).Selected = True


            RadComboRoomBox.DataValueField = "RoomId"
            RadComboRoomBox.DataTextField = "RoomName"

            RadComboRoomBox.DataSource = DataAdapter_Sch.GetRoomsLst(CInt(Session("OperatingHospitalId")), Nothing, Nothing, Nothing)
            RadComboRoomBox.DataBind()



            Dim maxDate As DateTime
            Dim OptionsDataAdapter As New Options
            Dim dtSys As DataTable = OptionsDataAdapter.GetSystemSettings(CInt(Session("OperatingHospitalId")))

            If dtSys.Rows.Count > 0 Then
                maxDate = Now.AddDays(CInt(dtSys.Rows(0)("MaxWorklistDays")))
            Else
                maxDate = Now.AddDays(2)
            End If
            ProcedureDateRadDatePicker.MinDate = Now.Date
            ProcedureDateRadDatePicker.MaxDate = maxDate.Date
            Dim ProcedureTypeIdList As New List(Of String)()

            If oWorklistOptions IsNot Nothing Then


                If Not String.IsNullOrEmpty(oWorklistOptions.ProcedureTypeId) Then
                    ProcedureTypeIdList = oWorklistOptions.ProcedureTypeId.Split(","c).ToList()
                End If
                EndoscopistComboBox.SelectedValue = oWorklistOptions.EndoscopistId
                ProcedureDateRadDatePicker.SelectedDate = oWorklistOptions.ScheduledDate
                ProcedureStartRadTimePicker.SelectedTime = oWorklistOptions.ScheduledDate.TimeOfDay
                For i As Integer = 0 To ProcedureTypesCheckBoxList.Items.Count - 1
                    If ProcedureTypeIdList.Contains(ProcedureTypesCheckBoxList.Items(i).Value) Then
                        ProcedureTypesCheckBoxList.Items(i).Selected = True
                    Else
                        ProcedureTypesCheckBoxList.Items(i).Selected = False
                    End If
                Next
                RadComboRoomBox.SelectedValue = oWorklistOptions.RoomId
            Else
                ProcedureDateRadDatePicker.SelectedDate = Now.AddDays(1)
                ProcedureStartRadTimePicker.SelectedTime = (New TimeSpan(9, 0, 0))
            End If


            Dim da As New DataAccess
            If Not String.IsNullOrWhiteSpace(Request.QueryString("PatientId")) Then
                If Not String.IsNullOrWhiteSpace(Request.QueryString("mode")) AndAlso Request.QueryString("mode").ToLower() = "edit" AndAlso CInt(Request.QueryString("uniqueId")) > 0 Then
                    LoadWaitlist()
                Else
                    'get patient details

                    'Mahfuz changed on 02 July 2021
                    'Place 1
                    'After clicking on "Add to work list" - the request comes here first time with SCIStorePatientID in Request.QueryString("PatientId")

                    'If SCIStore D&G Webservice enabled then above patientId will be SCIStorePatientID not SE Local DB PatientID
                    If Session(Constants.SESSION_IMPORT_PATIENT_BY_WEBSERVICE) = ImportPatientByWebserviceOptions.Webservice Then
                        Dim ScotHosWSBL As ScotHospitalWebServiceBL = New ScotHospitalWebServiceBL
                        intSCIStorePatientID = CInt(Request.QueryString("PatientId"))
                        ScotHosWSBL.ConnectWebservice()
                        'Call GetPatients method
                        intSELocalDBPatientID = ScotHosWSBL.ImportPatientsIntoDatabaseBySCIStorePatientID(intSCIStorePatientID)
                        'Logout
                        ScotHosWSBL.DisconnectService()
                    ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI) = ImportPatientByWebserviceOptions.NSSAPI Then
                        If Session("PatientSearchSource") = Constants.SESSION_IMPORT_PATIENT_BY_NSSAPI Then
                            Dim nipapiPIBL As NIPAPIBL = New NIPAPIBL()
                            Dim chiNumber As String = Request.QueryString("nhsno")
                            intSELocalDBPatientID = nipapiPIBL.ExtractAndImportPatientsIntoDatabase(chiNumber)
                        Else
                            intSELocalDBPatientID = PatientId
                        End If
                    ElseIf Session(Constants.SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI) = ImportPatientByWebserviceOptions.NHSSPINEAPI Then

                        Dim nhsSpineAPI As NHSSPINEAPIBL = New NHSSPINEAPIBL()
                        Dim nhsNumber As String = Request.QueryString("nhsno")

                        intSELocalDBPatientID = nhsSpineAPI.ExtractAndImportPatientsIntoDatabase(nhsNumber)
                    Else
                        intSELocalDBPatientID = CInt(Request.QueryString("PatientId"))
                    End If

                    Session("SELocalDBPatientID") = intSELocalDBPatientID

                    'Dim existingWorklistPatient = da.GetWorklistPatient(PatientId, Session("OperatingHospitalID"))
                    Dim existingWorklistPatient = da.GetWorklistPatient(CInt(Session("SELocalDBPatientID")), Session("OperatingHospitalID")) 'Mahfuz changed on 02 July 2021
                    Dim dataSource As DataTable = dataaccess.GetEndoscopist()

                    If existingWorklistPatient.Rows.Count > 0 Then
                        Dim dr = existingWorklistPatient.Rows(0)

                        PatientNameLabel.Text = dr("Forename").ToString() & " " & dr("Surname").ToString()
                        PatientDOBLabel.Text = CDate(dr("DateOfBirth")).ToShortDateString()
                        PatientAddressLabel.Text = dr("Address").ToString()
                        PatientCaseNoteNoLabel.Text = dr("HospitalNumber").ToString()
                        If CDate(dr("Date")) < ProcedureDateRadDatePicker.MinDate Then
                            ProcedureDateRadDatePicker.SelectedDate = ProcedureDateRadDatePicker.MinDate
                        ElseIf CDate(dr("Date")) > ProcedureDateRadDatePicker.MaxDate Then
                            ProcedureDateRadDatePicker.SelectedDate = ProcedureDateRadDatePicker.MaxDate
                        Else
                            ProcedureDateRadDatePicker.SelectedDate = CDate(dr("Date"))
                            ProcedureStartRadTimePicker.SelectedTime = CDate(dr("Date")).TimeOfDay
                        End If


                        EndoscopistComboBox.DataSource = dataSource
                        EndoscopistComboBox.DataBind()

                        If Not dr.IsNull("EndoscopistId") Then
                            Dim idExists As Boolean = dataSource.AsEnumerable().Any(Function(row) row.Field(Of Integer)("UserId") = CInt(dr("EndoscopistId")))
                            If Not idExists Then
                                EndoscopistComboBox.SelectedValue = ""
                            Else
                                EndoscopistComboBox.SelectedValue = CInt(dr("EndoscopistId"))
                            End If
                        Else
                            EndoscopistComboBox.SelectedValue = ""
                        End If


                        If Not dr.IsNull("RoomId") Then RadComboRoomBox.SelectedValue = CInt(dr("RoomId"))
                        If Not dr.IsNull("ProcedureTypeId") Then
                            'Dim columnValues As List(Of String) = existingWorklistPatient.AsEnumerable().Select(Function(row) row.Field(Of String)("ProcedureTypeId")).ToList()
                            Dim existingProcedureTypeId = (From p In existingWorklistPatient Select p.Field(Of Integer)("ProcedureTypeId")).ToList

                            For i As Integer = 0 To ProcedureTypesCheckBoxList.Items.Count - 1
                                If existingProcedureTypeId.Contains(ProcedureTypesCheckBoxList.Items(i).Value) Then
                                    ProcedureTypesCheckBoxList.Items(i).Selected = True
                                Else
                                    ProcedureTypesCheckBoxList.Items(i).Selected = False
                                End If
                            Next
                        End If

                        'show message with option to continue
                        Dim msgContent = "Patient is already booked in for a "
                        If dr.IsNull("ProcedureType") Then
                            msgContent += "procedure"
                        Else
                            Dim existingProcedureType = (From p In existingWorklistPatient Select p.Field(Of String)("ProcedureType")).Distinct().Where(Function(x) Not String.IsNullOrEmpty(x)).ToList
                            msgContent += String.Join(",", existingProcedureType) 'dr("ProcedureType")
                        End If
                        msgContent += " on " & CDate(dr("Date")).ToString("dd MMM yyyy") & " (" & dr("TimeOfDay").ToString() & ") <br />"
                        msgContent += "Would you like to load and amend this?"

                        valDiv.InnerHtml = msgContent
                        RadNotification1.Show()
                    Else
                        EndoscopistComboBox.DataSource = dataSource
                        EndoscopistComboBox.DataBind()
                        'Place 2
                        'Dim dtPatient = da.GetPatientById(PatientId) '02 July 2021 Mahfuz changed as follows
                        Dim dtPatient = da.GetPatientById(CInt(Session("SELocalDBPatientID")))

                        If dtPatient.Rows.Count > 0 Then
                            Dim dr = dtPatient.Rows(0)
                            PatientNameLabel.Text = dr("Forename1").ToString() & " " & dr("Surname").ToString()
                            PatientDOBLabel.Text = CDate(dr("DateOfBirth")).ToShortDateString()
                            PatientAddressLabel.Text = dr("Address").ToString()
                            PatientCaseNoteNoLabel.Text = dr("HospitalNumber").ToString()
                        End If
                    End If
                End If
            End If
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs)
        Dim procedureDate
        Dim endoscopist = CInt(EndoscopistComboBox.SelectedValue)
        Dim RoomID = CInt(RadComboRoomBox.SelectedValue)
        Dim da As New DataAccess

        Dim procedureTypeIds As New List(Of String)()
        For Each litem As ListItem In ProcedureTypesCheckBoxList.Items
            If litem.Selected Then
                procedureTypeIds.Add(litem.Value)
            End If
        Next
        Dim procedureTypeIdss As String = "0"
        If procedureTypeIds.Count > 0 Then
            procedureTypeIdss = String.Join(",", procedureTypeIds)
        End If

        If Not (ProcedureDateRadDatePicker.SelectedDate Is Nothing) Then
            procedureDate = ProcedureDateRadDatePicker.SelectedDate.Value
            Dim procedureTime As TimeSpan = If(ProcedureStartRadTimePicker.SelectedTime.HasValue, ProcedureStartRadTimePicker.SelectedTime.Value, New TimeSpan(9, 0, 0))
            Dim combinedDateTime As DateTime = procedureDate.Date.Add(procedureTime)
            ' Extract AM/PM designation
            Dim amPmDesignation As String = combinedDateTime.ToString("tt")
            'Place 3
            'da.AddPatientToWorklist(PatientId, procedureDate, endoscopist, procedureTypeId, Session("OperatingHospitalID"), TimeOfDayRadioButtonList.SelectedValue) 
            '02 July 2021 Mahfuz changed as below
            da.AddPatientToWorklist(CInt(Session("SELocalDBPatientID")), combinedDateTime, endoscopist, procedureTypeIdss, Session("OperatingHospitalID"), amPmDesignation, RoomID)

            oWorklistOptions = New WorkListOptions With {
                .ScheduledDate = combinedDateTime,
                .EndoscopistId = endoscopist,
                .ProcedureTypeId = procedureTypeIdss,
                .RoomId = RoomID
            }

            If Not String.IsNullOrWhiteSpace(Request.QueryString("mode")) AndAlso Request.QueryString("mode") = "edit" Then
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndUpdate", "CloseAndUpdate();", True)
            Else
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)
            End If
        End If
    End Sub

    Private Sub LoadWaitlist()
        Dim da As New DataAccess
        Dim existingWorklistPatient = da.GetWorklistRecord(CInt(Request.QueryString("uniqueId")), CInt(Session("OperatingHospitalId")))

        Dim dr = existingWorklistPatient.Rows(0)
        PatientNameLabel.Text = dr("Forename").ToString() & " " & dr("Surname").ToString()
        PatientDOBLabel.Text = CDate(dr("DateOfBirth")).ToShortDateString()
        PatientAddressLabel.Text = dr("Address").ToString()
        PatientCaseNoteNoLabel.Text = dr("HospitalNumber").ToString()

        ProcedureDateRadDatePicker.SelectedDate = CDate(dr("Date"))
        ProcedureStartRadTimePicker.SelectedTime = CDate(dr("Date")).TimeOfDay
        If Not dr.IsNull("RoomId") Then RadComboRoomBox.SelectedValue = CInt(dr("RoomId"))
        If Not dr.IsNull("EndoscopistId") Then EndoscopistComboBox.SelectedValue = CInt(dr("EndoscopistId"))
        If Not dr.IsNull("ProcedureTypeId") Then
            Dim existingProcedureTypeId = (From p In existingWorklistPatient Select p.Field(Of Integer)("ProcedureTypeId")).ToList

            For i As Integer = 0 To ProcedureTypesCheckBoxList.Items.Count - 1
                If existingProcedureTypeId.Contains(ProcedureTypesCheckBoxList.Items(i).Value) Then
                    ProcedureTypesCheckBoxList.Items(i).Selected = True
                Else
                    ProcedureTypesCheckBoxList.Items(i).Selected = False
                End If
            Next
        End If
    End Sub

    Protected Sub NoCloseButton_Click(sender As Object, e As EventArgs)
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)
    End Sub
End Class