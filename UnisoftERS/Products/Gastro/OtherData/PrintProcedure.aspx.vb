Imports Telerik.Web.UI
Imports Telerik.Web.UI.Skins

Partial Class Products_Gastro_OtherData_PrintProcedure
    Inherits PageBase

    Protected Sub Page_Init(sender As Object, e As System.EventArgs) Handles Me.Init

    End Sub

    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(PrintInitiateUserControl.FindControl("divInitiatePrint"), divPrintInitiate)
        PrintInitiateUserControl.LoadPrintInitiatePage()
        If Not IsPostBack Then
            If DataAccess.ProcedureDNA(CInt(Session(Constants.SESSION_PROCEDURE_ID))).Rows.Count > 0 Then
                ProcNotCarriedOutCheckBox.Checked = True
            End If
        End If
    End Sub
End Class
