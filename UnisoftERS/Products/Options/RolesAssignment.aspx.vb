Imports Telerik.Web.UI

Partial Class Products_Options_RolesAssignment
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            InitForm()
            LoadTreeView()
        End If
    End Sub

    Private Sub InitForm()
        Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{RolesComboBox, ""}}, DataAdapter.GetRoles(False), "RoleName", "RoleId")
    End Sub

    Private Sub LoadTreeView()
        Dim dt = DataAdapter.GetPagesByRole(RolesComboBox.SelectedValue, GroupDropDownList.SelectedValue)

        Dim treeNodeData = (From data In dt.AsEnumerable
                            Group pageAlias = data("PageAlias"), pageId = data("PageId"), accessLevel = data("AccessLevel") By groupName = data("GroupName"), groupId = data("GroupId") Into g = Group
                            Select groupName, groupId, groupPages = g.ToList)

        Dim pageGroupId = CInt(GroupDropDownList.SelectedValue)

        If treeNodeData.Any(Function(x) {2, 3, 4, 9}.ToList.Contains(x.groupId)) Then
            PageGroupSectionsTreeView.FindNodeByValue("0").Visible = True
            PageGroupSectionsTreeView.FindNodeByValue("0").Nodes.Clear()
            For Each td In treeNodeData.Where(Function(x) {2, 3, 4, 9}.ToList.Contains(x.groupId))
                If Not IsDBNull(td.groupName ) AndAlso Not string.IsNullOrEmpty(td.groupName) AndAlso (pageGroupId = 1 OrElse td.groupId = pageGroupId) Then
                    Dim parentNode As New RadTreeNode(td.groupName, 0)
                    If td.groupId = pageGroupId Then parentNode.Expanded = True
                    For Each pn In td.groupPages
                        Dim childNode = New RadTreeNode(pn.pageAlias, pn.pageId)
                        Select Case CInt(pn.accessLevel)
                            Case 1
                                childNode.CssClass = "node-read-only"
                            Case 9
                                childNode.CssClass = "node-full-access"
                            Case Else
                                childNode.CssClass = "node-no-access"
                        End Select
                        parentNode.Nodes.Add(childNode)
                    Next
                    PageGroupSectionsTreeView.FindNodeByValue("0").Nodes.Add(parentNode)
                End If
            Next
        Else
            PageGroupSectionsTreeView.FindNodeByValue("0").Visible = False
        End If

        If treeNodeData.Any(Function(x) x.groupId = 8) Then
            PageGroupSectionsTreeView.FindNodeByValue("1").Visible = True
            PageGroupSectionsTreeView.FindNodeByValue("1").Nodes.Clear()
            For Each td In treeNodeData.Where(Function(x) x.groupId = 8)
                'Dim parentNode As New RadTreeNode(td.groupName)
                For Each pn In td.groupPages
                    Dim childNode = New RadTreeNode(pn.pageAlias, pn.pageId)
                    Select Case CInt(pn.accessLevel)
                        Case 1
                            childNode.CssClass = "node-read-only"
                        Case 9
                            childNode.CssClass = "node-full-access"
                        Case Else
                            childNode.CssClass = "node-no-access"
                    End Select
                    PageGroupSectionsTreeView.FindNodeByValue("1").Nodes.Add(childNode)
                Next
            Next
        Else
            PageGroupSectionsTreeView.FindNodeByValue("1").Visible = False
        End If
        AccessLevelCombobx.SelectedIndex=0
    End Sub

    Protected Sub GroupDropDownList_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadTreeView()
    End Sub

    Protected Sub RolesComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles RolesComboBox.SelectedIndexChanged
        LoadTreeView()
    End Sub

    ''' <summary>
    ''' Updates ALL the pages for the selected user role
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    Protected Sub ApplyClick(sender As Object, e As EventArgs)
        Dim AccessLevel As String = AccessLevelCombobx.SelectedValue
        If AccessLevel <> "" Then
            Dim RoleId As Integer = RolesComboBox.SelectedValue
            Dim roleAccessLevel As New Dictionary(Of Integer, String)
            Dim pageGroup = GroupDropDownList.SelectedValue

            For Each parentNode As RadTreeNode In PageGroupSectionsTreeView.FindNodeByValue("0").Nodes
                If parentNode.Nodes.Count > 0 Then
                    For Each childNode As RadTreeNode In parentNode.Nodes
                        Dim pageId = childNode.Value
                        roleAccessLevel.Add(pageId, AccessLevel)
                    Next
                Else
                    Dim pageId = parentNode.Value
                    roleAccessLevel.Add(pageId, AccessLevel)
                End If
            Next

            If pageGroup = 1 Or pageGroup = 8 Then
                For Each parentNode As RadTreeNode In PageGroupSectionsTreeView.FindNodeByValue("1").Nodes
                    If parentNode.Nodes.Count > 0 Then
                        For Each childNode As RadTreeNode In parentNode.Nodes
                            Dim pageId = childNode.Value
                            roleAccessLevel.Add(pageId, AccessLevel)
                        Next
                    Else
                        Dim pageId = parentNode.Value
                        roleAccessLevel.Add(pageId, AccessLevel)
                    End If
                Next
            End If

            DataAdapter.InsertPagesByRole(RoleId, roleAccessLevel, True)
            LoadTreeView()
        End If
    End Sub

    Protected Sub PageGroupSectionsTreeView_ContextMenuItemClick(sender As Object, e As RadTreeViewContextMenuEventArgs)
        Try
            If RolesComboBox.SelectedValue = "" Then Exit Sub

            Dim RoleId As Integer = RolesComboBox.SelectedValue
            Dim clickedNode As RadTreeNode = e.Node
            Dim pageId = clickedNode.Value
            Dim roleAccessLevel As New Dictionary(Of Integer, String)
            Dim accessLevel = e.MenuItem.Value

            'check if parent node.. if so update all children
            If pageId = 0 Then
                For Each n As RadTreeNode In clickedNode.Nodes
                    pageId = n.Value
                    roleAccessLevel.Add(pageId, accessLevel)
                Next
            Else
                roleAccessLevel.Add(pageId, accessLevel)
            End If

            DataAdapter.InsertPagesByRole(RoleId, roleAccessLevel)

            Dim newCssClass = ""
            Select Case accessLevel
                Case 0 'no access
                    newCssClass = "node-no-access"
                Case 1 'readonly
                    newCssClass = "node-read-only"
                Case 9 'full control
                    newCssClass = "node-full-access"
            End Select

            If clickedNode.Nodes.Count = 0 Then
                clickedNode.CssClass = newCssClass
            Else
                For Each n As RadTreeNode In clickedNode.Nodes
                    n.CssClass = newCssClass
                Next
            End If
        Catch ex As Exception

        End Try
    End Sub
End Class
