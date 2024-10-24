Imports Telerik.Web.UI
Public Class ProcedureMaster
    Inherits System.Web.UI.MasterPage
    Private Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        If String.IsNullOrWhiteSpace(Session("UserID")) Then
            Session.Contents.RemoveAll()
            Response.Redirect("~/Security/Logout.aspx", False)
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            PremedSummaryListView.DataBind()
            SummaryListView.DataBind()

            Pageloader()

            'resize the left side pane of master page to fit summary
            DirectCast(Me.Master.FindControl("radLeftPane"), RadPane).Width = 360
        End If
    End Sub
    Private Sub Pageloader()
        Dim procName As String = ""
        Select Case Session(Constants.SESSION_PROCEDURE_TYPE)
            Case ProcedureType.Gastroscopy
                procName = "Gastroscopy"
            Case ProcedureType.ERCP
                procName = "ERCP"
            Case ProcedureType.Colonoscopy
                procName = "Colon"
            Case ProcedureType.Proctoscopy
                procName = "Proctoscopy"
            Case ProcedureType.Sigmoidscopy
                procName = "Sigmoidoscopy"
            Case ProcedureType.EUS_OGD
                procName = "EUS (OGD)"
            Case ProcedureType.EUS_OGD
                procName = "EUS (HPB)"
            Case ProcedureType.Flexi
                procName = "Cystoscopy"
        End Select
        lblProcDate.Text = "<span style='font-size:smaller;color:#ffff99;'>Summary</span><br />" & procName & " Procedure - " & Format(Now(), "dd/MM/yyyy")
        'lblProcDate.Text = Session("ProcTable") & " Procedure - " & Format(Now(), "dd/MM/yyyy")
    End Sub
    Public Sub SetButtonStyle()
        procedurefooter.SetButtonStyle()
    End Sub
    Protected Sub SummaryListView_ItemCreated(sender As Object, e As ListViewItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!NodeSummary) Then
                e.Item.Visible = False
            ElseIf CStr(drItem!NodeSummary) = "" Then
                e.Item.Visible = False
            Else
                'Image display for NPSA alert
                Dim sImagePath = "~/Images/icons/alert.png"
                If CStr(drItem!NodeName) = "Report" AndAlso InStr(CStr(drItem!NodeSummary).ToLower, sImagePath.ToLower) > 0 Then
                    Dim urlalert As String = HttpContext.Current.Request.Url.AbsoluteUri.Replace(HttpContext.Current.Request.Url.PathAndQuery, "") + sImagePath
                    drItem!NodeSummary = Replace(drItem!NodeSummary, sImagePath, urlalert.ToLower)
                End If
            End If
        End If
    End Sub
    Protected Sub PremedSummaryListView_ItemCreated(sender As Object, e As ListViewItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim drItem As DataRow = DirectCast(DirectCast(e.Item, ListViewDataItem).DataItem, DataRowView).Row
            If IsDBNull(drItem!NodeSummary) Then
                e.Item.Visible = False
            ElseIf CStr(drItem!NodeSummary) = "" Then
                e.Item.Visible = False
            End If
        End If
    End Sub
    Protected Sub SummaryObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SummaryObjectDataSource.Selecting
        e.InputParameters("procId") = CStr(Session("ProcId"))
    End Sub
    Protected Sub PremedSummaryObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles PremedSummaryObjectDataSource.Selecting
        e.InputParameters("procId") = CStr(Session("ProcId"))
    End Sub


    Protected Sub btnRefresh_Click(sender As Object, e As EventArgs)
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.RaisePostBackEvent("reload")


        Dim dtDNA = DataAccess.ProcedureDNA(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        If dtDNA IsNot Nothing AndAlso dtDNA.Rows.Count > 0 Then
            Dim dr = dtDNA.Rows(0)
            ProcNotCarriedOutRadioButtonList.SelectedValue = dr("DNAReasonId")
            CancelReasonRadTextBox.Text = dr("DNAReasonText")
            'set DNA window controls
            ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "do_work", "disableForDNA(); setDNAControls();", True)
        End If


    End Sub


    Protected Sub procedurefooter_ShowSummary_Clicked()
        PremedSummaryListView.DataBind()
        SummaryListView.DataBind()

        ap1.RaisePostBackEvent("reload")

        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set_show_hide", "setHideShowSummary()", True)
    End Sub
End Class