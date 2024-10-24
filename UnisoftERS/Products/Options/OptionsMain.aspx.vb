Imports Telerik.Web.UI

Partial Class Products_Options_OptionsMain
    Inherits PageBase

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            'If Me.Master.FindControl("UnisoftMenu") IsNot Nothing Then
            '    Dim UnisoftMenu As RadMenu = DirectCast(Master.FindControl("UnisoftMenu"), RadMenu)
            '    UnisoftMenu.LoadContentFile("~/App_Data/Menus/01bMenu.xml")
            'End If
            'DataAdapter.UnlockPatientProcedures(Session("PCName"), Session("UserID"))
            'LoadTreeView()           
        End If

        'Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Page)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(LeftMenuTreeView, RadSplitter1, RadAjaxLoadingPanel1)
    End Sub
    Private Sub Page_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
        If Not Page.IsPostBack Then
            BindToDataTable(LeftMenuTreeView)

            If Request.QueryString("node") IsNot Nothing Then
                SelectNode(CStr(Request.QueryString("node")))
            Else
                If CBool(Session("isERSViewer")) Then
                    SelectNode("System Configuration")
                Else
                    SelectNode("User Settings")
                End If

            End If
        End If

    End Sub
    Private Sub BindToDataTable(ByVal treeView As RadTreeView)
        treeView.DataTextField = "NodeName"
        treeView.DataValueField = "MenuUrl"
        treeView.DataFieldID = "MapID"
        treeView.DataFieldParentID = "ParentID"
        treeView.DataSource = DataAdapter.GetMenuMapItems(CInt(Session("PKUserId")), CBool(Session("isERSViewer")), CBool(Session("IsDemoVersion")), "Configure")
        treeView.DataBind()

        treeView.ExpandAllNodes()
    End Sub
    'Private Sub LoadTreeView()
    '    If CBool(Session("isERSViewer")) Then
    '        LeftMenuTreeView.LoadContentFile(Page.ResolveUrl("~/App_Data/Menus/OptionsLM_Viewer.xml"))
    '    Else
    '        LeftMenuTreeView.LoadContentFile(Page.ResolveUrl("~/App_Data/Menus/OptionsLeftMenu.xml"))
    '    End If
    '    LeftMenuTreeView.ExpandAllNodes()
    '    'Dim rootNode As New RadTreeNode("Options", "~/Products/Options/UserSettings.aspx")
    '    'rootNode.Expanded = True

    '    'rootNode.Nodes.Add(New RadTreeNode("User Settings", "~/Products/Options/UserSettings.aspx"))
    '    'rootNode.Nodes.Add(New RadTreeNode("System Settings", "~/Products/Options/SystemSettings.aspx"))
    '    'rootNode.Nodes.Add(New RadTreeNode("Export Settings", "~/Products/Options/ExportSettings.aspx"))
    '    'rootNode.Nodes.Add(New RadTreeNode("Database Settings", "~/Products/Options/DatabaseSettings.aspx"))

    '    'Dim nodeWithSubNodes As New RadTreeNode("Admin Utilities", "~/Products/Options/RegistrationDetails.aspx")
    '    'nodeWithSubNodes.Nodes.Add(New RadTreeNode("Registration Details", "~/Products/Options/RegistrationDetails.aspx"))
    '    'nodeWithSubNodes.Nodes.Add(New RadTreeNode("Password Rules", "~/Products/Options/PasswordRules.aspx"))
    '    'nodeWithSubNodes.Nodes.Add(New RadTreeNode("NHS No Validation", "~/Products/Options/NHSNoValidation.aspx"))
    '    'nodeWithSubNodes.Nodes.Add(New RadTreeNode("Required Fields Setup", "~/Products/Options/RequiredFieldsSetup.aspx"))
    '    'nodeWithSubNodes.Nodes.Add(New RadTreeNode("System Usage", "~/Products/Options/SystemUsage.aspx"))
    '    'rootNode.Nodes.Add(nodeWithSubNodes)

    '    'rootNode.Nodes.Add(New RadTreeNode("User Maintenance", "~/Products/Options/UserMaintenance.aspx"))

    '    'LeftMenuTreeView.Nodes.Add(rootNode)
    'End Sub

    Private Sub SelectNode(ByVal nodeName As String)
        Dim nodeToSelect As RadTreeNode = LeftMenuTreeView.FindNodeByText(nodeName)
        'If nodeToSelect Is Nothing Then
        '    nodeToSelect = LeftMenuTreeView.Nodes(0)
        'End If
        If Not IsNothing(nodeToSelect) Then
            If nodeToSelect.Nodes.Count > 0 Then
                nodeToSelect.Expanded = True
                nodeToSelect.Nodes(0).Selected = True
            Else
                nodeToSelect.Selected = True
            End If

            RadPane1.ContentUrl = Page.ResolveUrl(nodeToSelect.Value)
        End If

    End Sub

    'Protected Sub LeftMenuTreeView_NodeClick(sender As Object, e As RadTreeNodeEventArgs) Handles LeftMenuTreeView.NodeClick
    '    'Response.Redirect(Page.ResolveUrl("~/Products/Common/Options.aspx" & "?nodename=" & e.Node.Text & "&nodevalue=" & e.Node.Value))
    '    'Response.Redirect(Page.ResolveUrl(e.Node.Value))
    '    RadPane1.ContentUrl = Page.ResolveUrl(e.Node.Value)
    'End Sub
End Class
