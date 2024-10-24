Imports Telerik.Web.UI

Public Class Other
    Inherits SiteDetailsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim da As DataAccess = New DataAccess
            Dim dt As DataTable = da.GetAbnormalitiesForProcedure(CInt(Request.QueryString("SiteId")))
            Utilities.LoadCheckBoxList(AbnormalitiesCheckboxes, dt, "Abnormality", "OtherId", True)
            PopulateSelectedAbmormalities(dt)
        End If
    End Sub

    Private Sub PopulateSelectedAbmormalities(dt As DataTable)
        For Each dr As DataRow In dt.Rows
            If dr("Selected") = 1 Then
                Dim i As Integer
                For i = 0 To AbnormalitiesCheckboxes.Items.Count - 1
                    If AbnormalitiesCheckboxes.Items(i).Value = dr("OtherId") Then
                        AbnormalitiesCheckboxes.Items(i).Selected = True
                    End If
                Next
            End If
        Next
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Dim abnormalities As String = ""
        For i = 0 To AbnormalitiesCheckboxes.Items.Count - 1
            If AbnormalitiesCheckboxes.Items(i).Selected Then
                abnormalities += AbnormalitiesCheckboxes.Items(i).Value + ","
            End If
        Next
        Dim da As DataAccess = New DataAccess
        da.SaveOtherAbnormality(CInt(Request.QueryString("SiteId")),
                                abnormalities)
        If saveAndClose Then
            ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
        End If
    End Sub
End Class