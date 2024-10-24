Imports System.Windows
Imports Telerik.Web.UI

Public Class PreviousDiseases
    Inherits ProcedureControls

    Private Shared procType As Integer
    Private patientId As Int32 = 0
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            If Not HttpContext.Current.Request.Cookies("patientId") Is Nothing Then
                Dim PatientCookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
                patientId = If(PatientCookie IsNot Nothing, Convert.ToInt32(PatientCookie.Value), 0)
                loadPreviousDiseaseControls()
            Else
                MessageBox.Show("Your session expired, please start procedure again..")
                Response.Redirect("~/Products/Default.aspx", False)
            End If
        End If
    End Sub



    Private Sub loadPreviousDiseaseControls()
        Try
            'databing repeater
            Dim dbResult = DataAdapter.LoadPreviousDiseases(procType)
            Dim previousDiseases = dbResult.AsEnumerable.Where(Function(x) Not x("AdditionalInfo"))
            'load patient previous diseases
            Dim patientRecord = DataAdapter.GetPatientPreviousDiseases(patientId)

            If previousDiseases.Count > 0 Then
                ' Colummn wise Checkbox sorting part
                Dim filteredDataTable = previousDiseases.CopyToDataTable()

                Dim resultDataTable As DataTable = DataHelper.GetColumnWiseSortedTable(filteredDataTable)

                rptPreviousDiseases.DataSource = resultDataTable
                rptPreviousDiseases.DataBind()
                ' Colummn wise Checkbox sorting part

                For Each itm As RepeaterItem In rptPreviousDiseases.Items
                    Dim chk As New CheckBox

                    For Each ctrl As Control In itm.Controls
                        If TypeOf ctrl Is CheckBox Then
                            chk = CType(ctrl, CheckBox)
                        End If
                    Next

                    If chk IsNot Nothing Then
                        Dim uniqueId = CInt(chk.Attributes.Item("data-uniqueid"))

                        chk.Checked = patientRecord.AsEnumerable.Any(Function(x) CInt(x("UniqueId")) = uniqueId)
                    End If
                Next
            End If

            'additional info/other text boxes
            If dbResult.AsEnumerable.Any(Function(x) x("AdditionalInfo")) Then
                rptAdditionalInfo.DataSource = dbResult.AsEnumerable.Where(Function(x) x("AdditionalInfo")).CopyToDataTable
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

                    tb.Text = (From si In patientRecord Where CInt(si("UniqueId")) = uniqueId
                               Select si("AdditionalInformation")).FirstOrDefault
                End If
            Next
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

End Class