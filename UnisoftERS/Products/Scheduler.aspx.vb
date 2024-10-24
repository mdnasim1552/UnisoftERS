Imports Telerik.Web.UI
Imports System.IO
Imports System.Data.SqlClient
Imports System.Drawing
Imports System.Web.Services
Imports System.Web.Script.Services

Partial Class Products_Scheduler
    Inherits PageBase

    Protected Sub Page_Init(sender As Object, e As System.EventArgs) Handles Me.Init

    End Sub
    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Me.Master IsNot Nothing Then
                Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                If leftPane IsNot Nothing Then leftPane.Visible = False
                If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
            End If
        End If
    End Sub

End Class