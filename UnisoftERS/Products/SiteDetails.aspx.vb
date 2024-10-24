Imports System.Drawing
Imports DevExpress.ExpressApp.Web.SystemModule.CallbackHandlers
Imports DevExpress.XtraRichEdit.Model
Imports Telerik.Web.UI

Partial Class Products_SiteDetails
    Inherits SiteDetailsBase

    Private Shared NavigateDefault As String = ""

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim SiteId As Integer
            If String.IsNullOrEmpty(Request.QueryString("SiteId")) Then
                SiteId = -1
            ElseIf Request.QueryString("SiteId") = "undefined" Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "alert('Site was not committed. Please refresh the page and try again.');", True)
                SiteId = 0
            ElseIf Not Integer.TryParse(Request.QueryString("SiteId"), SiteId) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "alert('Something is wrong, unable to find the site selected. Please refresh the page and try again.');", True)
                SiteId = 0
            End If


            'Dim procType As Integer = CInt(Request.QueryString("ProcType"))
            'Dim procType As Integer = CInt(Session("ProcNo"))
            'If Not String.IsNullOrEmpty(Request.QueryString("Region")) _
            '    And Not String.IsNullOrEmpty(Request.QueryString("SiteId")) Then

            'Dim siteId As String = Request.QueryString("SiteId")

            'If SiteId <> 0 Then
            Dim reg As String = Request.QueryString("Region")
            Dim optionChosen As String = Convert.ToString(Request.QueryString("OptionChosen"))
            If optionChosen = "Specimens" Then optionChosen = "Specimens Taken"
            If optionChosen = "Barretts Epithelium" Then optionChosen = "Barrett's"
            If optionChosen = "Notes for the site" Then optionChosen = "Additional notes"
            If reg IsNot Nothing AndAlso (reg.Contains("Pylorus") And optionChosen = "Duodenal Ulcer") Then optionChosen = "Pyloric Ulcer"
            Dim insertionType As String = Convert.ToString(Request.QueryString("InsertionType"))
            Dim areaNo As String = Convert.ToString(Request.QueryString("AreaNo"))
            If areaNo = "undefined" Then areaNo = 0
            LoadTreeView(reg, CInt(SiteId), optionChosen, insertionType, CInt(areaNo))

            'End If
            'End If
        End If
        'SiteDetailsRadAjaxManager.AjaxSettings.AddAjaxSetting()
    End Sub

    'Protected Sub Page_PreLoad(sender As Object, e As System.EventArgs) Handles Me.PreLoad
    '    Call uniAdaptor.IsAuthenticated()
    'End Sub

    Protected Sub LoadTreeView(ByVal region As String, ByVal siteId As Integer, optionChosen As String, insertionType As String, areaNo As Integer)
        Dim procType As Integer = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

        'First tree option is "Procedure"
        'Dim ProcedureNode As New RadTreeNode("Procedure data", "~/Products/Common/ProcedureSummary.aspx")
        'SiteDetailsMenuRadTreeView.Nodes.Add(ProcedureNode)
        'ProcedureNode.ImageUrl = "~/images/icons/procedure.png"

        Dim rootNode As New RadTreeNode("Procedure data", "~/Products/Common/ProcedureSummary.aspx") 'RadTreeNode("Procedure outcome", "~/Products/PatientProcedure.aspx")
        'rootNode.Selected = True

        Dim photoNode As New RadTreeNode
        With photoNode
            .Text = "Media"
            .ImageUrl = "~/images/icons/camera.png"
            .Value = "~/Products/Common/AttachedMedia.aspx?ProcedureId=" & Session(Constants.SESSION_PROCEDURE_ID)
        End With

        Dim dtPhotos As DataTable = DataAdapter.GetSitePhotos(Nothing, CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        If dtPhotos.Rows.Count > 0 Then
            photoNode.Style.Add("font-weight", "bold")
            photoNode.Style.Add("color", "#005999")
        End If

        rootNode.Nodes.Add(photoNode)

        Dim dtTreeRoot As DataTable

        dtTreeRoot = DataAdapter.GetSitesByProcedure(Session(Constants.SESSION_PROCEDURE_ID))

        For Each r As DataRow In dtTreeRoot.Rows
            Dim siteNode = GetSiteNodes(r("siteNo"), r("region"), r("siteId"), optionChosen, insertionType, areaNo, siteId, r("SiteName"))

            'check if this is a redirect following an item being saved. If so, open and select that node
            If Not String.IsNullOrWhiteSpace(Request.QueryString("DefaultNav")) AndAlso Not String.IsNullOrWhiteSpace(Request.QueryString("SiteId")) Then
                If CInt(r("siteId")) = CInt(Request.QueryString("SiteId")) Then
                    rootNode.Selected = False
                    siteNode.Selected = True
                    siteNode.Expanded = True
                End If
            End If
            rootNode.Nodes.Add(siteNode)
        Next


        SiteDetailsMenuRadTreeView.ShowLineImages = False

        SiteDetailsMenuRadTreeView.Nodes.Add(rootNode)

        'Dim rootNode As New RadTreeNode("Site " & siteNo & " (" & region & ")", "~/Products/Common/SiteSummary.aspx?SiteId=" + CStr(siteId) + "&SiteName=" + siteNo)
        rootNode.Expanded = True
        rootNode.ImageUrl = "~/images/icons/procedure.png"

        If dtTreeRoot.Rows.Count = 0 Then
            rootNode.Selected = True
        Else
            If siteId = 0 Then
                rootNode.Selected = True
            End If
        End If

        ''Temp code - remove later
        'If siteId = -1 Then
        '    Exit Sub
        'End If

        ''For areas, get the main site id
        'siteId = DataAdapter.GetPrimeSiteId(siteId)
        Dim siteNo As String '= DataAdapter.GetSiteNo(siteId)
        'If Not String.IsNullOrEmpty(Request.QueryString("DefaultNav")) Then
        '    rootNode.Selected = True
        'End If
        If procType = ProcedureType.EBUS Then
            If siteId = -1 Or siteId = 0 Then
                Session("EBUSLymphNodeName") = "Lymph Node"
            Else
                Session("EBUSLymphNodeName") = DataAdapter.GetEbusLymphNodeNameBySiteId(siteId)
            End If

            siteNo = "Lymph node"
            Me.Title = Me.Title + " - Site " & siteNo & " (" & Session("EBUSLymphNodeName") & ")"
        Else
            If siteId > 0 Then
                siteNo = DataAdapter.GetSiteNo(siteId)
                Me.Title = Me.Title + " - Site " & siteNo & " (" & region & ")"
            End If
        End If

        ''added code below back in for Bronchs/EBUS
        'Me.Title = Me.Title + " - Site " & siteNo & " (" & region & ")"

        'If arrMenus.Count = 0 Then
        '    n1.Value = dvMenus(0)!NavigateUrl & "?SiteId=" & siteId & "&Area=" & dvMenus(0)!Area & "&Reg=" & region & "&InsertionType=" & insertionType & "&AreaNo=" & areaNo
        '    If CBool(dvMenus(0)!RecordExists) Then
        '        n1.Style.Add("font-weight", "bold")
        '        n1.Style.Add("color", "#005999")
        '    End If
        'Else
        '    For Each m2 As String In arrMenus
        '        Dim dvMenu As DataView = New DataView(dtMenus, "ParentMenu = '" & m1 & "' AND Menu = '" & Replace(m2, "'", "''") & "'", "", DataViewRowState.CurrentRows)
        '        If m2 = "Barretts" Then m2 = "Barrett's"
        '        Dim n2 As New RadTreeNode(m2)
        '        'n2.Value = m2
        '        'n2.NavigateUrl = dvMenu(0)!NavigateUrl
        '        'n2.Target = "contentFrame"
        '        n2.Value = dvMenu(0)!NavigateUrl.ToString() & "?SiteId=" & siteId & "&Area=" & dvMenu(0)!Area & "&Reg=" & region
        '        If CBool(dvMenu(0)!RecordExists) Then
        '            n2.Style.Add("font-weight", "bold")
        '            n1.Style.Add("font-weight", "bold") ' I OD, enabled this to bold abnormality menu 
        '            n2.Style.Add("color", "#005999")
        '            n1.Style.Add("color", "#005999")
        '            n1.Expanded = True
        '        End If
        '        If m2 = optionChosen Then
        '            n2.Selected = True
        '        End If
        '        n1.Nodes.Add(n2)
        '    Next
        'End If
        'rootNode.Nodes.Add(n1)
        'Next

        SiteDetailsMenuRadTreeView.Nodes.Add(rootNode)
    End Sub

    Private Function GetSiteNodes(siteNo As String, region As String, siteId As Integer, optionChosen As String, insertionType As String, areaNo As Integer, selectedSiteId As Integer, siteName As String) As RadTreeNode
        Dim siteTitle = If(siteNo = "-77", "Site by distance", "Site " & siteName)
        Dim rootnode As New RadTreeNode(siteTitle & " (" & region & ")", "~/Products/Common/SiteSummary.aspx?SiteId=" + CStr(siteId) + "&SiteName=" + If(siteNo = "-77", "by distance (" & region & ")", siteName))
        rootnode.ExpandMode = TreeNodeExpandMode.ServerSideCallBack
        If siteId = selectedSiteId Then
            rootnode.Expanded = True
            rootnode.Selected = True
            LoadSiteTree(siteId, rootnode, optionChosen, insertionType, areaNo, region)
        Else
            Dim n1 As New RadTreeNode("Building - ," + siteId.ToString() + "," + areaNo.ToString() + "," + region)
            rootnode.Nodes.Add(n1)
        End If
        'rootnode.ImageUrl = "~/images/icons/site.png"

        Return rootnode
    End Function

    Private Sub LoadSiteTree(siteId As Integer, Rootnode As RadTreeNode, optionChosen As String, insertionType As String, areaNo As Integer, region As String)
        Dim dtMenus As DataTable = DataAdapter.GetSiteDetailsMenus(siteId)
        Dim dvParentMenus = New DataView(dtMenus)
        Dim arrParentMenu = GetDistinctValues(dvParentMenus, "ParentMenu")
        For Each m1 As String In arrParentMenu
            Dim dvMenus As DataView = New DataView(dtMenus, "ParentMenu = '" & m1 & "'", "", DataViewRowState.CurrentRows)
            Dim arrMenus = GetDistinctValues(dvMenus, "Menu")
            Dim n1 As New RadTreeNode(m1)
            If m1 = "Abnormalities" Then
                n1.Value = "~/Products/Abnormalities.aspx"
                n1.ImageUrl = "~/images/icons/abnormalities.png"
                n1.Expanded = True
            ElseIf m1 = "Therapeutic Procedures" Then
                n1.ImageUrl = "~/images/icons/therapeutic.png"
            ElseIf m1 = "Specimens Taken" Then
                n1.ImageUrl = "~/images/icons/specimen.png"
            ElseIf m1 = "Additional notes" Then
                n1.ImageUrl = "~/images/icons/notes.png"
            ElseIf m1 = "Diagnoses" Then
                n1.ImageUrl = "~/images/icons/diagnoses.png"
            ElseIf m1 = "Media" Then
                n1.ImageUrl = "~/images/icons/camera.png"
            End If

            If m1 = optionChosen Then
                n1.Selected = True
            End If
            If arrMenus.Count = 0 Then
                n1.Value = dvMenus(0)!NavigateUrl & "?SiteId=" & siteId & "&Area=" & dvMenus(0)!Area & "&Reg=" & region.Replace("<br/>", "") & "&InsertionType=" & insertionType & "&AreaNo=" & areaNo
                If CBool(dvMenus(0)!RecordExists) Then
                    'n1.Style.Add("font-weight", "bold")
                    'n1.Style.Add("color", "#005999")
                    n1.CssClass = "selectedNode"
                End If
            Else
                For Each m2 As String In arrMenus
                    Dim dvMenu As DataView = New DataView(dtMenus, "ParentMenu = '" & m1 & "' AND Menu = '" & Replace(m2, "'", "''") & "'", "", DataViewRowState.CurrentRows)
                    If m2 = "Barretts" Then m2 = "Barrett's"
                    Dim n2 As New RadTreeNode(m2)
                    'n2.Value = m2
                    'n2.NavigateUrl = dvMenu(0)!NavigateUrl
                    'n2.Target = "contentFrame"
                    n2.Value = dvMenu(0)!NavigateUrl.ToString() & "?SiteId=" & siteId & "&Area=" & dvMenu(0)!Area & "&Reg=" & region.Replace("<br/>", "")
                    If CBool(dvMenu(0)!RecordExists) Then
                        'n2.Style.Add("font-weight", "bold")
                        'n1.Style.Add("font-weight", "bold") ' I OD, enabled this to bold abnormality menu 
                        'n2.Style.Add("color", "#005999")
                        'n1.Style.Add("color", "#005999")
                        n1.CssClass = "selectedNode"
                        n2.CssClass = "selectedNode"
                        n1.Expanded = True
                    End If
                    If m2 = optionChosen Then
                        n2.Selected = True
                    End If
                    n1.Nodes.Add(n2)
                Next
            End If
            Rootnode.Nodes.Add(n1)
        Next
    End Sub

    Private Function GetDistinctValues(dView As DataView, column As String) As String()
        Dim dtDistinct As DataTable = dView.ToTable(True, column)
        Dim arr As New List(Of String)

        For Each row As DataRow In dtDistinct.Rows
            If Not String.IsNullOrEmpty(CStr(row(column))) Then
                arr.Add(row(column))
            End If
        Next
        Return arr.ToArray
    End Function

    Private Sub SiteDetailsMenuRadTreeView_NodeExpand(sender As Object, e As RadTreeNodeEventArgs) Handles SiteDetailsMenuRadTreeView.NodeExpand
        If Left(e.Node.Nodes(0).Text, 11) = "Building - " Then
            Dim siteString = e.Node.Nodes(0).Text
            e.Node.Nodes(0).Remove()

            Dim parts As String() = siteString.Split(","c)
            Dim siteId As Integer = Integer.Parse(parts(1))
            Dim areaNumber As Integer = Integer.Parse(parts(2))
            Dim siteName As String = parts(3)
            LoadSiteTree(siteId, e.Node, 1, 1, areaNumber, siteName)
        End If
    End Sub
End Class
