Imports Microsoft.Reporting.WebForms

Public Class AuditLogReports
    Inherits System.Web.UI.Page
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        If IsNothing(Session("PKUserID")) Then
            Response.Redirect("/", False)
        End If
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'If Not (Page.IsPostBack) Then
        '    RadGridNED.Visible = False '### Initially hide it.. as it is confusingly showing a gray border while empty on form Load!
        'End If
    End Sub





    'Protected Sub Go_Click(sender As Object, e As EventArgs) Handles Go.Click
    '    NedClass.FromDate = RDPFrom.SelectedDate.ToString
    '    NedClass.ToDate = RDPTo.SelectedDate.ToString
    '    NedClass.IsProcessed = Me.IsProcessed.SelectedValue.ToString
    '    NedClass.IsRejected = IsRejected.SelectedValue.ToString
    '    NedClass.IsSchemaValid = Me.IsSchemaValid.SelectedValue.ToString
    '    NedClass.IsSent = Me.IsSent.SelectedValue.ToString
    '    NedClass.ProcedureTypeId = Me.ProcedureTypeId.SelectedValue.ToString
    '    NedClass.PatientName = PatientName.Value
    '    NedClass.CNN = CNN.Value
    '    NedClass.NHS = NHS.Value
    '    RadGridNED.DataBind()
    '    RadGridNED.Visible = True
    'End Sub

    Private Sub PreviewButton_Click(sender As Object, e As EventArgs) Handles PreviewButton.Click
        ShowReport()
    End Sub

    Sub ShowReport()
        'RV.ProcessingMode = ProcessingMode.Local

        'Dim localReport As LocalReport
        'localReport = RV.LocalReport

        'localReport.ReportPath = "Products/Reports/RV/ERS_Rep_AuditLog.rdlc"

        'Dim dt As New DataTable()

        'dt = Reports.GetPatients()

        ''Create a report data source for the sales order data
        'Dim RDS As New ReportDataSource()
        'RDS.Name = "DataSet1"
        'RDS.Value = dt

        'localReport.DataSources.Add(RDS)
    End Sub
End Class