'Imports Hl7.Fhir.ElementModel.Types
Imports Telerik.Web.UI

Public Class PlannedExtent
    Inherits ProcedureControls

    Public Shared procType As Integer
    Public Shared PlannedExtentIdValue As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            Try
                bindExtent()

            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading indications for binding", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading planned extent")
                RadNotification1.Show()
            End Try
        End If
    End Sub


    Private Sub bindExtent()
        Try
            Dim extentOptions = DataAdapter.LoadExtent(procType)
            Dim procedureExtent = DataAdapter.getProcedurePlannedExtent(Session(Constants.SESSION_PROCEDURE_ID))


            If extentOptions.Rows.Count > 0 Then
                PlannedExtentRadComboBox.DataSource = extentOptions.AsEnumerable.Where(Function(x) x("ListOrderBy") >= 0 And Not CBool(x("AdditionalInfo"))).CopyToDataTable '-1 is for failed results
            End If

            PlannedExtentRadComboBox.DataBind()

            If procedureExtent.Rows.Count > 0 Then
                Dim dr = procedureExtent.Rows(0)
                PlannedExtentRadComboBox.SelectedIndex = PlannedExtentRadComboBox.FindItemIndexByValue(dr("ExtentId"))
            Else
                'set to default options as per NED recommendation (see NED2-030)
                If procType = CInt(ProcedureType.Gastroscopy) OrElse procType = CInt(ProcedureType.Transnasal) Then
                    PlannedExtentRadComboBox.SelectedIndex = PlannedExtentRadComboBox.FindItemIndexByText("D2")
                ElseIf procType = CInt(ProcedureType.Colonoscopy) Then
                    PlannedExtentRadComboBox.SelectedIndex = PlannedExtentRadComboBox.FindItemIndexByText("Caecum")
                ElseIf procType = CInt(ProcedureType.Sigmoidscopy) Then
                    PlannedExtentRadComboBox.SelectedIndex = PlannedExtentRadComboBox.FindItemIndexByText("Descending colon")
                Else
                    PlannedExtentRadComboBox.Items.Insert(0, New RadComboBoxItem(""))
                    PlannedExtentRadComboBox.SelectedIndex = 0
                End If
            End If




        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    'Added by ronytfs-2830 start
    Protected Sub PlannedExtentRadComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim dr = CType(e.Item.DataItem, DataRowView)
            e.Item.Attributes.Add("data-planned-extent", dr("ListOrderBy").ToString)
        End If
    End Sub
    'End
End Class