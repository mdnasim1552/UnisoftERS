Public Class CystoscopyHeader
    Inherits ProcedureControls

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            Dim procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
            populateCystoScopyType()
            Dim procedureCystoscopyHeader = DataAdapter.GetProcedureCystoscopyHeader(Session(Constants.SESSION_PROCEDURE_ID))
            Dim procedureCystoscopyHeaderDatarow = procedureCystoscopyHeader.Rows
            If procedureCystoscopyHeader.Rows.Count > 0 Then
                CystoscopyType.SelectedIndex = CystoscopyType.FindItemIndexByText(procedureCystoscopyHeader.Rows(0)("CystoscopyTypeId").ToString())
                CystoscopyProcedureType.SelectedValue = procedureCystoscopyHeader.Rows(0)("CystoscopyProcedureType").ToString()
            Else
                CystoscopyType.SelectedIndex = CystoscopyType.FindItemIndexByText("First Cystoscopy")
                CystoscopyProcedureType.SelectedIndex = 0
                Dim dataAccess As New DataAccess()
                dataAccess.saveCystoscopyHeader(Session(Constants.SESSION_PROCEDURE_ID), CystoscopyType.SelectedValue, CystoscopyProcedureType.SelectedValue)
            End If
        End If
    End Sub
    Sub populateCystoScopyType()
        Dim dataAccess As New DataAccess()
        CystoscopyType.DataTextField = "CystoscopyTypeText"
        CystoscopyType.DataValueField = "CystoscopyTypeText"
        CystoscopyType.DataSource = dataAccess.GetCystoscopyType()
        CystoscopyType.DataBind()
    End Sub
End Class