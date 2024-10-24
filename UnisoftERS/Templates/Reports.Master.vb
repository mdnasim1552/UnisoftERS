Imports Telerik.Web.UI
Imports System.Globalization
Imports System.Web.Services

Public Class Reports1
    Inherits System.Web.UI.MasterPage

    Private Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        If String.IsNullOrWhiteSpace(Session("UserID")) Then
            Session.Contents.RemoveAll()
            Response.Redirect("~/Security/Logout.aspx", False)
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Me.Master IsNot Nothing Then
            Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
            Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

            If leftPane IsNot Nothing Then leftPane.Visible = False
            If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
        End If
        'If Not Page.IsPostBack Then
        '    If Me.Master.FindControl("UnisoftMenu") IsNot Nothing Then
        '        Dim UnisoftMenu As RadMenu = DirectCast(Master.FindControl("UnisoftMenu"), RadMenu)
        '        UnisoftMenu.LoadContentFile("~/App_Data/Menus/01bMenu.xml")
        '    End If
        '    LoadTreeView("ReportsMenuMisc")
        '    'If Request.QueryString("node") IsNot Nothing Then
        '    '    SelectNode(CStr(Request.QueryString("node")))
        '    'Else
        '    '    SelectNode("UserSettings")
        '    'End If
        '    'Dim RadAjaxLoadingPanelR As New RadAjaxLoadingPanel()
        '    'Dim myAjaxMgr As New RadAjaxManager
        '    'myAjaxMgr.AjaxSettings.AddAjaxSetting(LeftMenuTreeView, DeploySite, RadAjaxLoadingPanelR)
        'End If
    End Sub

    'Private Sub LoadTreeView(ByVal xmlFile As String)
    '    Dim str As String = ""
    '    LeftMenuTreeView.Nodes.Clear()
    '    LeftMenuTreeView.LoadContentFile(Page.ResolveUrl("~/App_Data/Menus/" + xmlFile + ".xml"))
    '    LeftMenuTreeView.ExpandAllNodes()
    '    'LeftMenuTreeView.FindNodeByText("GRS").Selected = True
    '    Dim enablecheckbox As String = ""
    '    Dim NodeName As String = ""
    '    Dim NodeValue As String = ""
    '    Dim GRSName As String = ""
    '    Dim reader As New System.Xml.XmlTextReader(Server.MapPath("~/App_Data/Menus/" + xmlFile + ".xml"))

    '    While reader.Read()
    '        'If reader.NodeType = System.Xml.XmlNodeType.Element Then
    '        enablecheckbox = reader.GetAttribute("enablecheckbox")
    '        NodeName = reader.GetAttribute("Text")
    '        NodeValue = reader.Value
    '        Dim foundNode As RadTreeNode = LeftMenuTreeView.FindNodeByText(NodeName)
    '        If foundNode IsNot Nothing Then
    '            If enablecheckbox = "true" Then
    '                foundNode.Checkable = True
    '                GRSName = reader.GetAttribute("GRS")
    '                foundNode.Attributes.Add("GRS", GRSName)
    '            Else
    '                foundNode.Checkable = False
    '                foundNode.Attributes.Add("GRS", "")
    '            End If
    '        End If
    '    End While
    'End Sub

End Class