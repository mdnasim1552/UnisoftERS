Imports Telerik.Web.UI
Public Class Products_Reports_ReportsMain
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        'If Not Page.IsPostBack Then
        '    If Me.Master.FindControl("UnisoftMenu") IsNot Nothing Then
        '        Dim UnisoftMenu As RadMenu = DirectCast(Master.FindControl("UnisoftMenu"), RadMenu)
        '        UnisoftMenu.LoadContentFile("~/App_Data/Menus/01bMenu.xml")
        '    End If

        '    LoadTreeView()

        '    If Request.QueryString("node") IsNot Nothing Then
        '        SelectNode(CStr(Request.QueryString("node")))
        '    Else
        '        SelectNode("UserSettings")
        '    End If
        'End If

        'Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Page)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(LeftMenuTreeView, RadSplitter1, RadAjaxLoadingPanel1)
    End Sub

    Private Sub LoadTreeView()
        'LeftMenuTreeView.LoadContentFile(Page.ResolveUrl("~/App_Data/Menus/ReportsLeftMenu.xml"))
        'LeftMenuTreeView.ExpandAllNodes()
        'Dim rootNode As New RadTreeNode("Options", "~/Products/Options/UserSettings.aspx")
        'rootNode.Expanded = True

        'rootNode.Nodes.Add(New RadTreeNode("User Settings", "~/Products/Options/UserSettings.aspx"))
        'rootNode.Nodes.Add(New RadTreeNode("System Settings", "~/Products/Options/SystemSettings.aspx"))
        'rootNode.Nodes.Add(New RadTreeNode("Export Settings", "~/Products/Options/ExportSettings.aspx"))
        'rootNode.Nodes.Add(New RadTreeNode("Database Settings", "~/Products/Options/DatabaseSettings.aspx"))

        'Dim nodeWithSubNodes As New RadTreeNode("Admin Utilities", "~/Products/Options/RegistrationDetails.aspx")
        'nodeWithSubNodes.Nodes.Add(New RadTreeNode("Registration Details", "~/Products/Options/RegistrationDetails.aspx"))
        'nodeWithSubNodes.Nodes.Add(New RadTreeNode("Password Rules", "~/Products/Options/PasswordRules.aspx"))
        'nodeWithSubNodes.Nodes.Add(New RadTreeNode("NHS No Validation", "~/Products/Options/NHSNoValidation.aspx"))
        'nodeWithSubNodes.Nodes.Add(New RadTreeNode("Required Fields Setup", "~/Products/Options/RequiredFieldsSetup.aspx"))
        'nodeWithSubNodes.Nodes.Add(New RadTreeNode("System Usage", "~/Products/Options/SystemUsage.aspx"))
        'rootNode.Nodes.Add(nodeWithSubNodes)

        'rootNode.Nodes.Add(New RadTreeNode("User Maintenance", "~/Products/Options/UserMaintenance.aspx"))

        'LeftMenuTreeView.Nodes.Add(rootNode)
    End Sub

    'Private Sub SelectNode(ByVal nodeName As String)
    '    Dim nodeToSelect As RadTreeNode = LeftMenuTreeView.FindNodeByAttribute("GRSBRepeat", nodeName)
    '    If nodeToSelect Is Nothing Then
    '        nodeToSelect = LeftMenuTreeView.Nodes(0)
    '    End If

    '    If nodeToSelect.Nodes.Count > 0 Then
    '        nodeToSelect.Expanded = True
    '        nodeToSelect.Nodes(0).Selected = True
    '    Else
    '        nodeToSelect.Selected = True
    '    End If

    '    RadPane1.ContentUrl = Page.ResolveUrl(nodeToSelect.Value)
    'End Sub

    'Protected Sub LeftMenuTreeView_NodeClick(sender As Object, e As RadTreeNodeEventArgs) Handles LeftMenuTreeView.NodeClick
    '    'Response.Redirect(Page.ResolveUrl("~/Products/Common/Options.aspx" & "?nodename=" & e.Node.Text & "&nodevalue=" & e.Node.Value))
    '    'Response.Redirect(Page.ResolveUrl(e.Node.Value))
    '    RadPane1.ContentUrl = Page.ResolveUrl(e.Node.Value)
    'End Sub

End Class