Imports Telerik.Web.UI

Public Class FurtherProcedures
    Inherits ProcedureControls

    Public Shared procType As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            InitializeRiskDropdowns()
            PopulateComboBoxes()

            Dim da As New OtherData
            Dim dtFu As DataTable = da.GetUpperGIFollowUp(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtFu.Rows.Count > 0 Then
                PopulateData(dtFu.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateComboBoxes()

        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                    {FurtherProcedureComboBox, DataAdapter.GetFutherProcedures(CInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                    {FurtherProcedureDueTypeComboBox, "Further procedure period"}
              })

    End Sub

    Private Sub PopulateData(ByVal drFu As DataRow)

        FurtherProcedureTextBox.Text = Server.HtmlDecode(CStr(drFu("FurtherProcedureText").ToString))

    End Sub
    Private Sub InitializeRiskDropdowns()
        RiskCategoriesComboBox.Items.Add(New RadComboBoxItem("", "-1"))
        RiskCategoriesComboBox.Items.Add(New RadComboBoxItem("low risk", "1"))
        RiskCategoriesComboBox.Items.Add(New RadComboBoxItem("high risk", "2"))
    End Sub

End Class