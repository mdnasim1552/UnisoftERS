Imports Telerik.Web.UI
Imports System.Globalization
Imports System.Data.SqlClient
Imports System.Web.Services
Public Class Products_Reports_Report
    Inherits PageBase
    Public _GRSArray = "111111111111111111"
    Public Property GRSArray
        Get
            Return _GRSArray
        End Get
        Set(value)
            _GRSArray = value
        End Set
    End Property
    Public _UserID As String = "0"
    Public Property UserID As String
        Get
            Return _UserID
        End Get
        Set(value As String)
            _UserID = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/", False)
        Else
            UserID = Session("PKUserId").ToString
            'SUID.Text = Session("PKUserId").ToString
        End If
        If Not Page.IsPostBack Then
            If Me.Master.FindControl("UnisoftMenu") IsNot Nothing Then
                Dim UnisoftMenu As RadMenu = DirectCast(Master.FindControl("UnisoftMenu"), RadMenu)
                UnisoftMenu.LoadContentFile("~/App_Data/Menus/01bMenu.xml")
            End If
            LoadTreeView("ReportsMenuMisc")
            If Request.QueryString("node") IsNot Nothing Then
                SelectNode(CStr(Request.QueryString("node")))
            Else
                SelectNode("UserSettings")
            End If
            'Dim RadAjaxLoadingPanelR As New RadAjaxLoadingPanel()
            'Dim myAjaxMgr As New RadAjaxManager
            'myAjaxMgr.AjaxSettings.AddAjaxSetting(LeftMenuTreeView, DeploySite, RadAjaxLoadingPanelR)
        End If
        'Session("Nodo") = LeftMenuTreeView.GetXml
        '-----------------------------------------------˅
        ' This part is especific for each report
        Reporting.PageTitle = "JAGGRS - Reports"
        Reporting.ReportName = "JAGGRS"
        '-----------------------------------------------˄
    End Sub
    Private Sub LoadTreeView(ByVal xmlFile As String)
        Dim str As String = ""
        LeftMenuTreeView.Nodes.Clear()
        LeftMenuTreeView.LoadContentFile(Page.ResolveUrl("~/App_Data/Menus/" + xmlFile + ".xml"))
        LeftMenuTreeView.ExpandAllNodes()
        'LeftMenuTreeView.FindNodeByText("GRS").Selected = True
        Dim enablecheckbox As String = ""
        Dim NodeName As String = ""
        Dim NodeValue As String = ""
        Dim GRSName As String = ""
        Dim reader As New System.Xml.XmlTextReader(Server.MapPath("~/App_Data/Menus/" + xmlFile + ".xml"))

        '#### We are not showing any GRS report.. so- disable the following block of code.. enable if required! Comment: Shawkat; 2017-10-25
        While reader.Read()
            'If reader.NodeType = System.Xml.XmlNodeType.Element Then
            enablecheckbox = reader.GetAttribute("enablecheckbox")
            NodeName = reader.GetAttribute("Text")
            NodeValue = reader.Value
            Dim foundNode As RadTreeNode = LeftMenuTreeView.FindNodeByText(NodeName)
            If foundNode IsNot Nothing Then
                If enablecheckbox = "true" Then
                    foundNode.Checkable = True
                    GRSName = reader.GetAttribute("GRS")
                    foundNode.Attributes.Add("GRS", GRSName)
                Else
                    foundNode.Checkable = False
                    foundNode.Attributes.Add("GRS", "")
                End If
            End If
        End While
    End Sub
    Private Sub SelectNode(ByVal nodeName As String)
        Dim nodeToSelect As RadTreeNode = LeftMenuTreeView.FindNodeByAttribute("GRSBRepeat", nodeName)
        If nodeToSelect Is Nothing Then
            nodeToSelect = LeftMenuTreeView.Nodes(0)
        End If
        If nodeToSelect.Nodes.Count > 0 Then
            nodeToSelect.Expanded = True

            nodeToSelect.Nodes(0).Selected = True
        Else
            nodeToSelect.Selected = True
        End If
        'RadPane1.ContentUrl = Page.ResolveUrl(nodeToSelect.Value)
    End Sub
End Class
