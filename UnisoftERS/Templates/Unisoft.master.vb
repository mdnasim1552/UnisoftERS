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
Imports Hl7.Fhir.Model

Partial Class Unisoft
    Inherits System.Web.UI.MasterPage

    Private Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init

        If String.IsNullOrWhiteSpace(Session("UserID")) Then
            Session.Contents.RemoveAll()
            Response.Redirect("~/Security/Logout.aspx", False)
        End If
    End Sub

    Protected Sub MasterForm_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MasterForm.Load
        If Not Page.IsPostBack Then
            'SessionTimeoutNotification.ShowInterval = (Session.Timeout - 1) * 60000
            'SessionTimeoutNotification.Value = Page.ResolveClientUrl("~/Security/Logout.aspx")

            InitSystem()
            LoadXMLMenus()
            Dim hospitalName As String = DataAdapter.GetHospitalNameByRoomId(Session("RoomId"))
            If hospitalName.Length > 50 Then
                hospitalName = hospitalName.Substring(0, 50) + "..."
            End If
            'LoadRooms()
            ' loginRoomLabel.InnerHtml = "<left><div style='color:#bfdbff;font-size:xx-small;'>Logged into room</div>" & hospitalName & " - " & Session("RoomName") & " </center>"
            loginRoomLabel.InnerHtml = "<span style='color:#bfdbff;font-size:xx-small;'>Logged into room</span><br />" & Session("PageHeaderRoomTitle") & " "

            loginUserLabel.InnerHtml = "<span style='color:#bfdbff;font-size:xx-small;'>Logged in as:</span><br />" & Session("UserID") & ""
            'Call LoadMenus()

            Dim curDate As Date = Now
            divDate.InnerHtml = "<span>" & MonthName(Month(curDate), True) & " " & Right(Year(curDate), 2) & "</span>" & Day(curDate)
        End If
    End Sub

    Protected Sub InitSystem()
        'Dim uniFunction As New BasePage

        'Call uniFunction.IsAuthenticated()

        '#Call ClearSessionVariables()

        'lblUserID.Text = "UserID: <b>" & Session("UserID") & " (" & Session("FullName") & ")" & "</b>"
        'lblPageID.Text = "PageID: <b>" & Session("PageID") & "</b>&nbsp;"
        'lblCompany.Text = "&#169 1994-" & Format(Now(), "yyyy") & " <b>Unisoft Medical Systems</b>"
        'LoggedOnAtLabel.Text = "Logged on at: <b>" & Session("LoggedOn") & "</b>"
        'lblRecordCreated.Text = "<b>" & Session("PatCreated") & "</b>"
        'lblLastModified.Text = "<b>" & Session("PatLastModified") & "</b>"
        UnisoftMenu.Visible = True

        'FeedbackRadButton.Attributes.Add("onclick", "OpenPopUpWindow('Feedback');")

        'If Session("LicenseExpired") = "True" Then
        '    ahWarning.HRef = "../Products/Options/OptionsMain.aspx?node=Licence"
        '    ahWarning.Attributes.Add("style", "color:#b30000;font-weight:bold;text-shadow: 0px 0px 9px rgba(255, 255, 255, 1);text-decoration:none;cursor:pointer;")
        '    ahWarning.InnerHtml = "License Expired"
        'ElseIf CBool(Session("IsDemoVersion")) Then
        '    ahWarning.HRef = "javascript:void(0)"
        '    ahWarning.Attributes.Add("style", "color:#ffe699;font-weight:bold;text-shadow: 0px 0px 9px rgba(255, 255, 255, 1);text-decoration:none;")
        '    ahWarning.InnerHtml = "Demo Version"
        '    'ElseIf Session("isERSViewer") Then
        '    '    FeedbackRadButton.Visible = False
        'End If

        'Select Case Session("PageID")
        '    Case 1, 10, 90
        '        ReturnToMain.Style("Display") = "None"

        '    Case 5
        '        UnisoftMenu.Visible = False

        '    Case Else
        '        ReturnToMain.Style("Display") = "Block"
        '        If Session("PageID") = 3 Then
        '            cmdReturn.Text = "Demographics"
        '            'divRecordDetails.Style("Display") = "None"
        '        Else
        '            cmdReturn.Text = "Main screen"
        '            divRecordDetails.Style("Display") = "Block"
        '        End If
        'End Select

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
        'UnisoftMenu.DataTextField = "NodeName"
        'UnisoftMenu.DataValueField = "MenuUrl"
        'UnisoftMenu.DataFieldID = "MapID"
        UnisoftMenu.DataFieldParentID = "ParentID"
        UnisoftMenu.DataSource = DataAdapter.GetMenuMapItems(CInt(Session("PKUserId")), CBool(Session("isERSViewer")), CBool(Session("IsDemoVersion")), "StartMenu")
        UnisoftMenu.DataBind()

        'If Trim(Session("PageID")) <> "" Then
        '    'UnisoftMenu.LoadContentFile("~/App_Data/Menus/" & Format(CInt(Session("PageID")), "00") & "Menu.xml")
        '    UnisoftMenu.LoadContentFile("~/App_Data/Menus/01Menu.xml")
        'Else
        '    UnisoftMenu.LoadContentFile("~/App_Data/Menus/01Menu.xml")
        'End If
        'If CBool(Session("IsDemoVersion")) Then
        '    Dim reportMenu As RadMenuItem = UnisoftMenu.FindItemByText("Reports")
        '    If Not IsNothing(reportMenu) Then
        '        reportMenu.ToolTip = "Reports is disabled for a demo version"
        '        reportMenu.NavigateUrl = ""
        '    End If
        'End If
    End Sub
    Protected Sub UnisoftMenuDataBound(ByVal sender As Object, ByVal e As RadMenuEventArgs)
        Dim row As DataRowView = DirectCast(e.Item.DataItem, DataRowView)
        e.Item.Text = row("NodeName")
        'Not setting NavigateUrl for Home will enable postback onclick of Home and trigger UnisoftMenu_ItemClick
        If e.Item.Text <> "Home" Then e.Item.NavigateUrl = row("MenuUrl")

        e.Item.ImageUrl = row("MenuIcon")
        e.Item.ToolTip = row("MenuTooltip")
        If e.Item.Text = "|" Then e.Item.IsSeparator = True
        If e.Item.Text = "About ERS" Then e.Item.Attributes.Add("OnClick", "OpenPopUpWindow('About');return false;")
        If e.Item.Text = "Feedback" Then e.Item.Attributes.Add("OnClick", "window.open('mailto:support@hd-clinical.com?subject=Solus%20Endoscopy%20Feedback&body=Thank%20you%20for%20your%20feedback');return false;")
        If e.Item.Text = "Log Support Ticket" Then e.Item.Attributes.Add("OnClick", "window.open('https://hd-clinicalsupport.zendesk.com/hc/en-gb/requests/new');return false;")

        If Left(e.Item.Text, 11) = "HD Clinical" Then e.Item.Target = "_blank"
        'If Left(e.Item.Text, 18) = "Log Support Ticket" Then e.Item.Target = "_blank"
        If e.Item.Text = "Help" Then e.Item.PostBack = False
        'e.Item.Visible = IIf(CInt(row("UserAccess")) <> 0, True, False)
        'e.Item.Enabled = IIf(CInt(row("UserAccess")) <> 9, True, False)
        'e.Item.ToolTip = "Learn more about " + e.Item.Text
    End Sub
    'Protected Sub LoadMenus()
    '    Dim adapter As New SqlDataAdapter("SELECT * FROM [Menus] WHERE [PageID] =" & Session("PageID"), DataAccess.ConnectionStr)
    '    Dim links As New DataSet()
    '    adapter.Fill(links)

    '    With UnisoftMenu
    '        .DataSource = links
    '        .DataFieldID = "MenuID"
    '        .DataFieldParentID = "ParentID"
    '        .DataTextField = "Text"
    '        .DataNavigateUrlField = "URL"
    '        .DataBind()
    '    End With
    'End Sub

    Function CheckRequiredFields() As String
        Dim opt As New Options()
        Dim procedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))

        CheckRequiredFields = opt.CheckRequired(procedureId)
    End Function

    Protected Sub UnisoftMenu_ItemClick(ByVal sender As Object, ByVal e As RadMenuEventArgs) Handles UnisoftMenu.ItemClick
        If Request.Url.Segments(Request.Url.Segments.Count - 1) = "PatientProcedure.aspx" Then
            Dim sCheckRequiredFields = CheckRequiredFields()
            If sCheckRequiredFields <> String.Empty Then
                'cmdMainScreen.AutoPostBack = False
                'cmdMainScreen.OnClientClicked = "DisplayMessage"
            End If
        End If

        'If (Not IsPostBack) Then
        Select Case e.Item.Text
            Case "Home"
                RedirectPage()
            Case "About Unisoft"
                'RadWindowManager1.VisibleOnPageLoad = True
                'With radUniWindow
                '.NavigateUrl = "~/Products/Common/About.aspx"
                'End With

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

    'Protected Sub UnisoftMenu_ItemCreated(ByVal sender As Object, ByVal e As RadMenuEventArgs) Handles UnisoftMenu.ItemCreated
    '    '#Stop
    'End Sub

    'Protected Sub cmdReturn_Click(sender As Object, e As System.EventArgs) Handles cmdReturn.Click
    '    If Session("PageID") = "3" Then
    '        Response.Redirect("~/Products/Gastro/PatientDetails.aspx?CNN=" & Session(SESSION_CASE_NOTE_NO))
    '    Else
    '        Response.Redirect("~/Products/Default.aspx")
    '    End If
    'End Sub


    Protected Sub LeftMenuRadTreeView_NodeClick(sender As Object, e As RadTreeNodeEventArgs) Handles LeftMenuRadTreeView.NodeClick
        'Response.Redirect(Page.ResolveUrl("~/Products/Common/Options.aspx" & "?nodename=" & e.Node.Text & "&nodevalue=" & e.Node.Value))
        Response.Redirect(Page.ResolveUrl(e.Node.Value), False)
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

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        If e.Argument = "collapsed" Or e.Argument = "expanded" Then
            Session("PaneState") = e.Argument.ToString
        ElseIf e.Argument = "refreshDiagram" Then
            Dim contentPage As products_common_proceduresummary_aspx = TryCast(Me.Page, products_common_proceduresummary_aspx)
            If contentPage IsNot Nothing Then
                contentPage.LoadDiagram()
            End If
        End If
    End Sub
End Class

