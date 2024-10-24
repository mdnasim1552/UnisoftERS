Imports System.Windows
Imports Telerik.Web.UI

Public Class FamilyHistory
    Inherits ProcedureControls

    Private Shared procType As Integer
    Private patientId As Int32 = 0

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
            Else
                MessageBox.Show("Your session expired, please start procedure again..")
                Response.Redirect("~/Products/Default.aspx", False)
            End If

            'If procType = ProcedureType.Colonoscopy Or procType = ProcedureType.Sigmoidscopy Or procType = ProcedureType.Retrograde Then
            '    loadFamilyDiseaseHistory()
            'Else
            '    FamilyHistoryDiv.Visible = False
            'End If
            loadFamilyDiseaseHistory()
        End If
    End Sub

    Private Sub loadFamilyDiseaseHistory()
        Try
            Dim familyDiseaseHistory = DataAdapter.LoadFamilyDiseaseHistory(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))

            ' Colummn wise Checkbox sorting part
            Dim filteredDataTable = familyDiseaseHistory.AsEnumerable.Where(Function(x) Not x("AdditionalInfo")).CopyToDataTable

            Dim resultDataTable As DataTable = DataHelper.GetColumnWiseSortedTable(filteredDataTable)

            rptFamilyHistory.DataSource = resultDataTable
            rptFamilyHistory.DataBind()
            ' Colummn wise Checkbox sorting part

            'load patient previous diseases
            Dim patientRecord = DataAdapter.GetPatientFamilyHistory(patientId, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

            For Each itm As RepeaterItem In rptFamilyHistory.Items
                Dim chk As New CheckBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is CheckBox Then
                        chk = CType(ctrl, CheckBox)
                    End If
                Next

                If chk IsNot Nothing Then
                    If chk.Text.ToLower = "no risk" Then
                        chk.CssClass = chk.CssClass + " family-history-none"
                    End If

                    Dim uniqueId = CInt(chk.Attributes.Item("data-uniqueid"))

                    chk.Checked = patientRecord.AsEnumerable.Any(Function(x) CInt(x("FamilyDiseaseHistoryId")) = uniqueId)
                End If
            Next

            'additional info/other text boxes
            If familyDiseaseHistory.AsEnumerable.Any(Function(x) x("AdditionalInfo")) Then
                rptAdditionalInfo.DataSource = familyDiseaseHistory.AsEnumerable.Where(Function(x) x("AdditionalInfo")).CopyToDataTable
                rptAdditionalInfo.DataBind()
            End If

            For Each itm As RepeaterItem In rptAdditionalInfo.Items
                Dim tb As New RadTextBox

                For Each ctrl As Control In itm.Controls
                    If TypeOf ctrl Is RadTextBox Then
                        tb = CType(ctrl, RadTextBox)
                    End If
                Next

                If tb IsNot Nothing Then
                    Dim uniqueId = CInt(tb.Attributes.Item("data-uniqueid"))

                    tb.Text = (From si In patientRecord Where CInt(si("FamilyDiseaseHistoryId")) = uniqueId
                               Select si("AdditionalInformation")).FirstOrDefault
                End If
            Next

        Catch ex As Exception
            Throw ex
        End Try
    End Sub

End Class