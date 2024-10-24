Imports Telerik.Web.UI

Partial Class Products_AuditLog_AuditLog2
    Inherits PageBase

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Call initForm()
            Call RefreshList()
            LoadTreeView()
        End If

        Dim selectedNodeValue = CStr(Request.QueryString("nodevalue"))
        RefreshList(, True, selectedNodeValue)
    End Sub

    Protected Sub LoadTreeView()
        Dim rootNode As New RadTreeNode("Audit Log (View all)", "~/Products/AuditLog/AuditLog2.aspx?nodevalue=0")
        rootNode.Expanded = True

        rootNode.Nodes.Add(New RadTreeNode("Application", "~/Products/AuditLog/AuditLog2.aspx?nodevalue=1"))
        rootNode.Nodes.Add(New RadTreeNode("Information", "~/Products/AuditLog/AuditLog2.aspx?nodevalue=2"))
        rootNode.Nodes.Add(New RadTreeNode("System", "~/Products/AuditLog/AuditLog2.aspx?nodevalue=3"))

        LeftMenuTreeView.Nodes.Add(rootNode)
    End Sub

    Protected Sub initForm()
        'UnisoftMenu.LoadContentFile("~/App_Data/Menus/20Menu.xml")
        Dim UnisoftMenu As RadMenu = DirectCast(Master.FindControl("UnisoftMenu"), RadMenu)
        UnisoftMenu.LoadContentFile("~/App_Data/Menus/01bMenu.xml")
    End Sub

    'Protected Sub rtAuditCategory_NodeClick(sender As Object, e As RadTreeNodeEventArgs) Handles rtAuditCategory.NodeClick
    '    Call RefreshList(, True, e.Node.TabIndex)
    'End Sub

    Protected Sub RefreshList(Optional ByVal sSQL As String = "", Optional ByVal bReset As Boolean = False, Optional ByVal categoryID As Integer = 0)
        'If sSQL = "" Then
        '    sSQL = "SELECT [Event Type] AS Event_Type, [Date], [Full Username] AS Full_Username, [StationID], [Event Description] AS Event_Description FROM [AuditLog]"

        '    If categoryID <> 0 Then
        '        sSQL = sSQL & " WHERE [Category] = " & categoryID
        '    End If
        '    sSQL = sSQL & " ORDER BY [Date] DESC"
        'End If

        If bReset = True Then
            uniRadGrid.Dispose()
        End If

        'uniRadGrid.DataSource = uniAdaptor.GetDataTable(sSQL)
        uniRadGrid.DataSource = DataAdapter.GetAuditLog(categoryID)

        If bReset = True Then
            uniRadGrid.DataBind()
        End If
    End Sub

    Protected Sub uniRadGrid_PageIndexChanged(sender As Object, e As GridPageChangedEventArgs) Handles uniRadGrid.PageIndexChanged
        Call RefreshList()
    End Sub
End Class
