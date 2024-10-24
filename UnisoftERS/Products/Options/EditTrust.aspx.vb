Imports Telerik.Web.UI

Public Class EditTrust
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            'PopulateProcedureTypeDropdown
            Dim da As DataAccess = New DataAccess
            Dim Id As Integer = CInt(Request.QueryString("TrustId"))
            If Id = 0 Then
                'we have a new record being created

            Else
                TrustId.Value = Id
                'lets populate the abnormality from the database
                Dim dt As DataTable = da.GetTrust(Id)
                If dt.Rows.Count > 0 Then
                    TrustTextBox.Text = dt.Rows(0).Item("TrustName")
                End If
            End If
            End If
    End Sub


    Protected Sub saveButton_Click()

        Dim da As DataAccess = New DataAccess
        da.SaveTrust(TrustId.Value, TrustTextBox.Text)
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType, "SaveAndClose", "CloseAndRebind();", True)
    End Sub

End Class
