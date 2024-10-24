Imports Telerik.Web.UI

Partial Class Products_Options_DiagnosesConfig
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            DiagnosesRadTreeView.CheckChildNodes = True
            BindToDataSet(DiagnosesRadTreeView)
            SelectFirstNode()
        End If
    End Sub
    Private Shared Sub BindToDataSet(ByVal treeView As RadTreeView)
        Dim da As New OtherData
        ' for upper GI
        Dim parentroot As New RadTreeNode("Upper GI", "1")
        parentroot.Nodes.Add(New RadTreeNode("Oesophagus", "Oesophagus"))
        parentroot.Nodes.Add(New RadTreeNode("Stomach", "Stomach"))
        parentroot.Nodes.Add(New RadTreeNode("Duodenum", "Duodenum"))
        treeView.Nodes.Add(parentroot)

        'for Colon
        Dim colonroot As New RadTreeNode("Colonoscopy", "3")
        treeView.Nodes.Add(colonroot)
        'for sig
        Dim sigroot As New RadTreeNode("Sigmoidoscopy", "4")
        treeView.Nodes.Add(sigroot)

        treeView.ExpandAllNodes()
    End Sub

    Protected Sub RadTreeView1_NodeClick(sender As Object, e As RadTreeNodeEventArgs)
        Dim sCaption As String = e.Node.Text
        DiagnosesRadGrid.MasterTableView.Caption = IIf(sCaption = "Upper GI", "Oesophagus", sCaption)
        If e.Node.Text = "Upper GI" Then
            SelectFirstNode()
            Exit Sub
        ElseIf e.Node.Nodes.Count = 0 Then
            If e.Node.Value = "3" Or e.Node.Value = "4" Then
                DiagnosesObjectDataSource.SelectParameters("ProcedureTypeID").DefaultValue = CInt(e.Node.Value)
                DiagnosesObjectDataSource.SelectParameters("Section").DefaultValue = ""
            Else
                DiagnosesObjectDataSource.SelectParameters("ProcedureTypeID").DefaultValue = CInt(e.Node.ParentNode.Value)
                DiagnosesObjectDataSource.SelectParameters("Section").DefaultValue = e.Node.Value
            End If
            DiagnosesRadGrid.DataSource = DiagnosesObjectDataSource
        Else
            DiagnosesRadGrid.DataSource = Nothing
        End If
        DiagnosesRadGrid.DataBind()
    End Sub

    Sub SelectFirstNode()
        DiagnosesRadGrid.MasterTableView.Caption = "Oesophagus"
        DiagnosesRadTreeView.Nodes(0).Nodes(0).Selected = True
        DiagnosesObjectDataSource.SelectParameters("ProcedureTypeID").DefaultValue = 1
        DiagnosesObjectDataSource.SelectParameters("Section").DefaultValue = "Oesophagus"
        DiagnosesRadGrid.DataSource = DiagnosesObjectDataSource
        DiagnosesRadGrid.DataBind()
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest

        If e.Argument = "Rebind" Then
            DiagnosesRadGrid.MasterTableView.SortExpressions.Clear()
            DiagnosesRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            DiagnosesRadGrid.MasterTableView.CurrentPageIndex = DiagnosesRadGrid.MasterTableView.PageCount - 1
            DiagnosesRadGrid.Rebind()
        End If
    End Sub
    Protected Sub DiagnosesRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles DiagnosesRadGrid.ItemCreated
        Dim itemID As Integer = 0
        Dim itemName As String = ""
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            itemID = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiagnosesMatrixID")
            If (DataBinder.Eval(e.Item.DataItem, "DisplayName") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "DisplayName").ToString())) Then
                itemName = e.Item.DataItem("DisplayName").ToString()
            End If
            EditLinkButton.Attributes("onclick") = String.Format("openAddRoleWindow('{0}');", itemID)
        End If
    End Sub

    Protected Sub DiagnosesRadGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        Dim ds As New OtherData
        If Not IsNothing(DiagnosesRadTreeView.SelectedNode) Then
            Dim eNode As RadTreeNode = DiagnosesRadTreeView.SelectedNode
            Dim t As New DataTable
            If eNode.Nodes.Count = 0 Then
                If eNode.Value = "3" Or eNode.Value = "4" Then
                    t = ds.DiagnosesSelect(eNode.Value, "")
                Else
                    t = ds.DiagnosesSelect(eNode.ParentNode.Value, eNode.Value)
                End If
                DiagnosesRadGrid.DataSource = t
            End If
        End If
    End Sub
End Class
