Imports Telerik.Web.UI

Partial Class Products_AuditLog_AuditLog
    Inherits PageBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If (Not IsPostBack) Then
            Call InitForm()

        End If
    End Sub

    Protected Sub InitForm()
        Session("PageID") = 20
        Session("MyBGColour") = ""

        Call loadTreeView()
    End Sub

    Protected Sub loadTreeView()
        With radTreeList
            Dim addNode As New RadTreeNode("AuditLog Viewer")
            addNode.Font.Bold = True

            addNode.Nodes.Add(New RadTreeNode("Application", "1"))
            addNode.Nodes.Add(New RadTreeNode("Information", "2"))
            addNode.Nodes.Add(New RadTreeNode("Security", "3"))

            .Nodes.Add(addNode)
            .ExpandAllNodes()
        End With
    End Sub
End Class
