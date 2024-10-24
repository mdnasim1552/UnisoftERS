

'Imports Microsoft.VisualBasic
'Imports System
'Imports System.Collections.Generic
'Imports System.Data
'Imports System.Data.SqlClient
'Imports System.Configuration
Imports Telerik.Web.UI
'Imports System.Web
'Imports System.Web.UI
'Imports System.Web.UI.WebControls
'Imports System.Web.UI.HtmlControls
Imports System.Data.SqlClient

Partial Class Scheduler
    Inherits System.Web.UI.MasterPage

    Private Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        If String.IsNullOrWhiteSpace(Session("UserID")) Then
            Session.Contents.RemoveAll()
            Response.Redirect("~/Security/SELogin.aspx", False)
        End If
        DirectCast(Me.Master.FindControl("radRightPane"), RadPane).Scrolling = SplitterPaneScrolling.Y
        DirectCast(Me.Master.FindControl("radLeftPane"), RadPane).Collapsed = True
    End Sub

    Protected Sub MasterForm_Load(ByVal sender As Object, ByVal e As System.EventArgs) 'Handles MasterForm.Load
        If Not Page.IsPostBack Then

            InitSystem()
            LoadXMLMenus()
            'loginUserLabel.InnerHtml = "<center><div style='color:#bfdbff;font-size:x-small;'>Logged in as:</div><div style='color:#bfdbff;font-size:small;'>" & Session("UserID") & "</div></center>"

            Dim curDate As Date = Now
            DirectCast(Me.Master.FindControl("radLeftPane"), RadPane).Collapsed = True
            DirectCast(Me.Master.FindControl("radRightPane"), RadPane).Scrolling = SplitterPaneScrolling.Y
            DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar).Visible = False

        End If
    End Sub

    Protected Sub InitSystem()
        'UnisoftMenu.Visible = True

        Select Case Session("MyBGColour")
            Case "Office2007"
                MainContentDiv.Style("background-color") = "#bfdbff"

            Case "Windows7"
                MainContentDiv.Style("background-color") = "#dfe9f5"

            Case Else
                MainContentDiv.Style("background-color") = "#fff"
        End Select

    End Sub

    Protected Sub LoadXMLMenus()
        'UnisoftMenu.DataFieldParentID = "ParentID"
        'UnisoftMenu.DataSource = DataAdapter.GetMenuMapItems(CInt(Session("PKUserId")), CBool(Session("isERSViewer")), CBool(Session("IsDemoVersion")), "StartMenu")
        'UnisoftMenu.DataBind()

    End Sub
    Protected Sub UnisoftMenuDataBound(ByVal sender As Object, ByVal e As RadMenuEventArgs)
        Dim row As DataRowView = DirectCast(e.Item.DataItem, DataRowView)
        e.Item.Text = row("NodeName")

        If e.Item.Text <> "Home" Then e.Item.NavigateUrl = row("MenuUrl")

        e.Item.ImageUrl = row("MenuIcon")
        e.Item.ToolTip = row("MenuTooltip")
        If e.Item.Text = "|" Then e.Item.IsSeparator = True
        'If e.Item.Text = "About ERS" Then e.Item.Attributes.Add("OnClick", "OpenPopUpWindow('About');return false;")
        'If e.Item.Text = "Feedback" Then e.Item.Attributes.Add("OnClick", "window.open('mailto:support@hd-clinical.com?subject=Solus%20Endoscopy%20Feedback&body=Thank%20you%20for%20your%20feedback');return false;")

        If Left(e.Item.Text, 11) = "HD Clinical" Then e.Item.Target = "_blank"
        If e.Item.Text = "Help" Then e.Item.PostBack = False
    End Sub

    Protected Sub UnisoftMenu_ItemClick(ByVal sender As Object, ByVal e As RadMenuEventArgs) 'Handles UnisoftMenu.ItemClick
        'If (Not IsPostBack) Then
        Select Case e.Item.Text
            Case "Home"
                RedirectPage()
            Case "About Unisoft"

            Case "Save Record"
                If Session("PageID") = "90" Then
                    'Init notification??
                    Response.Redirect("~/Products/PatientProcedure.aspx", False)
                End If

        End Select
        'End If

    End Sub

    Protected Sub lbLogo_Click(sender As Object, e As EventArgs)
        RedirectPage()
    End Sub

    Sub RedirectPage()
        ' Destroy Patinet Cookies
        If Not Request.Cookies("patientId") Is Nothing Then
            Dim Cookie As HttpCookie = HttpContext.Current.Request.Cookies("patientId")
            Cookie.Expires = DateTime.Now.AddDays(-1)
            Response.Cookies.Add(Cookie)
        End If

        Response.Redirect("~/Products/Default.aspx", False)
    End Sub

    Protected Sub OnCallbackUpdate(ByVal sender As Object, ByVal e As RadNotificationEventArgs)

    End Sub


    Private _dataAdapter As DataAccess = Nothing
    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataAdapter Is Nothing Then
                _dataAdapter = New DataAccess
            End If
            Return _dataAdapter
        End Get
    End Property



End Class