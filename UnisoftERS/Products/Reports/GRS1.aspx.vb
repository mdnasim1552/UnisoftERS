Imports Telerik.Web.UI
Imports System.Globalization
Imports System.Data.SqlClient
Imports System.Web.Services
Public Class Products_Reports_Grs1
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
            LoadTreeView("ReportsMenu")
            If Request.QueryString("node") IsNot Nothing Then
                SelectNode(CStr(Request.QueryString("node")))
            Else
                SelectNode("UserSettings")
            End If
            Dim RadAjaxLoadingPanelR As New RadAjaxLoadingPanel()
            Dim myAjaxMgr As New RadAjaxManager
            'myAjaxMgr.AjaxSettings.AddAjaxSetting(RadTabStrip1, rside, RadAjaxLoadingPanelR)
            myAjaxMgr.AjaxSettings.AddAjaxSetting(RadTabStrip1, RadTabStrip1, RadAjaxLoadingPanelR)
            myAjaxMgr.AjaxSettings.AddAjaxSetting(RadTabStrip1, LeftMenuTreeView, RadAjaxLoadingPanelR)
            myAjaxMgr.AjaxSettings.AddAjaxSetting(LeftMenuTreeView, DeploySite, RadAjaxLoadingPanelR)
            myAjaxMgr.AjaxSettings.AddAjaxSetting(LeftMenuTreeView, DeployFrame, RadAjaxLoadingPanelR)
        End If
        Session("Nodo") = LeftMenuTreeView.GetXml
        '-----------------------------------------------˅
        ' This part is especific for each report
        Reporting.PageTitle = "GRS - Reports"
        Reporting.ReportName = "GRS"
        '-----------------------------------------------˄
        If RDPFrom.SelectedDate.ToString = "" Then
            Reporting.LoadDefaultsFromDB(Session("PKUserID").ToString)
            Try
                Me.RDPFrom.SelectedDate = Reporting.FromDate.ToString
                Me.RDPTo.SelectedDate = Reporting.ToDate.ToString
            Catch ex As Exception
                RDPFrom.Culture = New CultureInfo("en-GB")
                RDPTo.Culture = New CultureInfo("en-GB")
                Me.RDPFrom.SelectedDate = "01/01/1980"
                Me.RDPTo.SelectedDate = "31/12/2099"
            End Try
            cbHideSuppressed.Checked = Reporting.HideSuppressed
            ComboConsultants.SelectedIndex = Reporting.TypeOfConsultant
            ComboConsultants.Items(0).Selected = True
            'Reporting.LoadDefaultsFromDB(Session("PKUserID").ToString)
        End If
        'Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(RadButtonFilter, RadTabStrip1, RadAjaxLoadingPanel1)
        'Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(ComboConsultants, RadListBox1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(ComboConsultants, RadListBox2)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(cbHideSuppressed, ComboConsultants)
    End Sub
    Private Sub LoadTreeView(ByVal xmlFile As String)
        Dim str As String = ""
        LeftMenuTreeView.Nodes.Clear()
        LeftMenuTreeView.LoadContentFile(Page.ResolveUrl("~/App_Data/Menus/" + xmlFile + ".xml"))
        LeftMenuTreeView.ExpandAllNodes()
        'LeftMenuTreeView.FindNodeByText("GRS reports").Selected = True
        Dim enablecheckbox As String = ""
        Dim NodeName As String = ""
        Dim NodeValue As String = ""
        Dim GRSName As String = ""
        Dim reader As New System.Xml.XmlTextReader(Server.MapPath("~/App_Data/Menus/" + xmlFile + ".xml"))
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
            'End If
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

    Sub AddTab(ByVal RaiseEventPosition As Integer)
        Dim ReportsArr As String() = {"GRSA01", "GRSA02", "GRSA03", "GRSA04", "GRSA05", "GRSB01", "GRSB02", "GRSB03", "GRSB04", "GRSB05", "GRSC01", "GRSC02", "GRSC03", "GRSC04", "GRSC05", "GRSC06", "GRSC07", "GRSC08"}
        Dim ReportsNameArr As String() = {"GRSA01", "GRSA02", "GRSA03", "GRSA04", "GRSA05A", "GRSB01", "GRSB02", "GRSB03", "GRSB04", "GRSB05", "GRSC01", "GRSC02", "GRSC03", "GRSC04", "GRSC05", "GRSC06", "GRSA07", "GRSC08"}
        Dim ReportsTitleArr As String() = {"GRS A - Diagnostic Biopsies for Diarrhoea", "GRS A - Haemostasis after endoscopic therapy", "GRS A - Stent and PEG/PEJ placement", "GRS A - Use of reversing agent", "GRS A - Assessment of sedation/Conform", "GRS B - Analysis of colonic Polyps/Polypectomies", "GRS B - Completion of intended therapeutic ERCP", "GRS B - Decompression of obstructed ducts", "GRS B - Repeat OGD for gastric ulcers", "GRS B - Tattoing of small tumours and suspected malignant polyps", "GRS C - Adenoma/Polyp detection rate", "GRS C - Colonoscopy completion Summary", "GRS C - Colonoscopy detailed failure report", "GRS C - Analysis of colonoscopy bowel preparation (Boston)", "GRS C - Analysis of colonoscopy bowel preparation (standard)", "GRS C - Quality of bowel preparation with repeats", "GRS C - Sedation and Analgesia for all procedures", "GRS C - Successful Intubation and completion of OGD"}
        Dim ReportName As String = ""
        Dim URL As String = ""
        ReportName = ReportsArr(RaiseEventPosition - 1)
        Dim t As New RadTab
        t.Text = Mid(ReportName, 1, 3) + " " + Mid(ReportName, 4, 1) + "-" + Mid(ReportName, 6, 1)
        t.ToolTip = ReportsTitleArr(RaiseEventPosition - 1)
        RadTabStripReports.Tabs.Add(t)
        Dim pv As New RadPageView
        pv.ID = "P" + ReportName
        RadMultiPageReports.PageViews.Add(pv)
        Dim lit As New Literal
        Dim Str As String = ""
        Select Case RaiseEventPosition
            Case 1
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSA01.aspx"" class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 2
                If cb1GRA2.Checked = True Then
                    Str = Str + "Endoscopist1=1"
                Else
                    Str = Str + "Endoscopist1=0"
                End If
                If cb2GRA2.Checked = True Then
                    Str = Str + "&Endoscopist2=1"
                Else
                    Str = Str + "&Endoscopist2=0"
                End If
                If cb3GRA2.Checked = True Then
                    Str = Str + "&OGD=1"
                Else
                    Str = Str + "&OGD=0"
                End If
                If cb4GRA2.Checked = True Then
                    Str = Str + "&COLSIG=1"
                Else
                    Str = Str + "&COLSIG=0"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSA02.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 3
                Select Case ComboConsultants.SelectedValue
                    Case "AllConsultants"
                        Str = Str + "Endoscopist1=1"
                        Str = Str + "&Endoscopist2=1"
                    Case "Endoscopist1"
                        Str = Str + "Endoscopist1=1"
                        Str = Str + "&Endoscopist2=0"
                    Case "Endoscopist2"
                        Str = Str + "Endoscopist1=0"
                        Str = Str + "&Endoscopist2=1"
                    Case Else
                        Str = Str + "Endoscopist1=1"
                        Str = Str + "&Endoscopist2=1"
                End Select
                If cb6GRA3.Checked Then
                    Str = Str + "&UnitAsAWhole=1"
                Else
                    Str = Str + "&UnitAsAWhole=0"
                End If
                Select Case radio1GRA3.SelectedValue
                    Case "All"
                        Str = Str + "&FromAge=0&ToAge=200"
                    Case "Under"
                        Try
                            Str = Str + "&FromAge=0&ToAge=" + Me.ToAgeGRA3.Text.ToString
                        Catch ex As Exception
                            Str = Str + "&FromAge=0&ToAge=200"
                        End Try
                    Case "Over"
                        Try
                            Str = Str + "&FromAge=" + Me.FromAgeGRA3.Text.ToString + "&ToAge=200"
                        Catch ex As Exception
                            Str = Str + "&FromAge=0&ToAge=200"
                        End Try
                    Case "Between"
                        Try
                            Str = Str + "&FromAge=" + Me.FromAgeGRA3.Text.ToString + "&ToAge=" + Me.ToAgeGRA3.Text.ToString
                        Catch ex As Exception
                            Str = Str + "&FromAge=0&ToAge=200"
                        End Try
                    Case Else
                        Str = Str + "&FromAge=0&ToAge=200"
                End Select
                If cb1GRA3.Checked Then
                    Str = Str + "&OesophagealStent=1"
                Else
                    Str = Str + "&OesophagealStent=0"
                End If
                If cb2GRA3.Checked Then
                    Str = Str + "&DuodenalStent=1"
                Else
                    Str = Str + "&DuodenalStent=0"
                End If
                If cb3GRA3.Checked Then
                    Str = Str + "&ColonicStent=1"
                Else
                    Str = Str + "&ColonicStent=0"
                End If
                If cb4GRA3.Checked Then
                    Str = Str + "&PEG=1"
                Else
                    Str = Str + "&PEG=0"
                End If
                If cb5GRA3.Checked Then
                    Str = Str + "&PEJ=1"
                Else
                    Str = Str + "&PEJ=0"
                End If
                Select Case radio2GRA3.SelectedValue
                    Case "Count"
                        Str = Str + "&CountOfProcedures=1"
                        Str = Str + "&ListOfPatients=0"
                    Case "List"
                        Str = Str + "&CountOfProcedures=0"
                        Str = Str + "&ListOfPatients=1"
                End Select
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSA03.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 4
                If cb1GRA4.Checked = True Then
                    Str = Str + "Summary=1"
                Else
                    Str = Str + "Summary=0"
                End If
                If cb2GRA4.Checked = True Then
                    Str = Str + "&Patients=1"
                Else
                    Str = Str + "&Patients=0"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSA04.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 5
                If cb2GRA5.Checked = True Then
                    Str = ""
                    lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                    lit.Text = lit.Text + "<iframe src=""RV/GRSA05C.aspx?" + Str + """ class=""if""></iframe>"
                    pv.Controls.Add(lit)
                Else
                    If cb1GRA5.Checked = True Then
                        Str = "UnitAsAWhole=1"
                        lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                        lit.Text = lit.Text + "<iframe src=""RV/GRSA05A.aspx?" + Str + """ class=""if""></iframe>"
                        pv.Controls.Add(lit)
                    Else
                        Str = "UnitAsAWhole=0"
                        lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                        lit.Text = lit.Text + "<iframe src=""RV/GRSA05A.aspx?" + Str + """ class=""if""></iframe>"
                        pv.Controls.Add(lit)
                    End If
                End If
            Case 6
                Select Case ComboConsultants.SelectedValue
                    Case "All"
                        Str = Str + "Endoscopist1=1&Endoscopist2=1"
                    Case "Endoscopist1"
                        Str = Str + "Endoscopist1=1&Endoscopist2=0"
                    Case "Endoscopist2"
                        Str = Str + "Endoscopist1=0&Endoscopist2=1"
                    Case Else
                        Str = Str + "Endoscopist1=1&Endoscopist2=1"
                End Select
                If cb1GRB1.Checked Then
                    Str = Str + "&Sessile=1"
                Else
                    Str = Str + "&Sessile=0"
                End If
                If cb2GRB1.Checked Then
                    Str = Str + "&Pedunculated=1"
                Else
                    Str = Str + "&Pedunculated=0"
                End If
                If cb3GRB1.Checked Then
                    Str = Str + "&Pseudopolyp=1"
                Else
                    Str = Str + "&Pseudopolyp=0"
                End If
                If FromAgeGRB1.Text <> "" Then
                    Try
                        Str = Str + "&FromAge=" + FromAgeGRB1.Text
                    Catch ex As Exception
                        Str = Str + "&FromAge=0"
                    End Try
                Else
                    Str = Str + "&FromAge=0"
                End If
                If ToAgeGRB1.Text <> "" Then
                    Try
                        Str = Str + "&ToAge=" + ToAgeGRB1.Text
                    Catch ex As Exception
                        Str = Str + "&ToAge=200"
                    End Try
                Else
                    Str = Str + "&ToAge=200"
                End If
                If in1GRB1.Value <> "" Then
                    Str = Str + "&GTSessile=" + in1GRB1.Value.ToString
                Else
                    Str = Str + "&GTSessile=0"
                End If
                If in2GRB1.Value <> "" Then
                    Str = Str + "&GTPedunculated=" + in2GRB1.Value.ToString
                Else
                    Str = Str + "&GTPedunculated=0"
                End If
                If in3GRB1.Value <> "" Then
                    Str = Str + "&GTPseudopolyp=" + in3GRB1.Value.ToString
                Else
                    Str = Str + "&GTPseudopolyp=0"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSB01.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 7
                If cb1GRB2.Checked = True Then
                    Str = Str + "Endoscopist1=1"
                Else
                    Str = Str + "Endoscopist1=0"
                End If
                If cb2GRB2.Checked = True Then
                    Str = Str + "&Endoscopist2=1"
                Else
                    Str = Str + "&Endoscopist2=0"
                End If
                If FromAgeGRB2.Text <> "" Then
                    Try
                        Str = Str + "&FromAge=" + FromAgeGRB2.Text
                    Catch ex As Exception
                        Str = Str + "&FromAge=0"
                    End Try
                Else
                    Str = Str + "&FromAge=0"
                End If
                If ToAgeGRB2.Text <> "" Then
                    Try
                        Str = Str + "&ToAge=" + ToAgeGRB2.Text
                    Catch ex As Exception
                        Str = Str + "&ToAge=200"
                    End Try
                Else
                    Str = Str + "&ToAge=200"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSB02.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 8
                If cb1GRB3.Checked = True Then
                    Str = Str + "Endoscopist1=1"
                Else
                    Str = Str + "Endoscopist1=0"
                End If
                If cb2GRB3.Checked = True Then
                    Str = Str + "&Endoscopist2=1"
                Else
                    Str = Str + "&Endoscopist2=0"
                End If
                If FromAgeGRB3.Text <> "" Then
                    Try
                        Str = Str + "&FromAge=" + FromAgeGRB3.Text
                    Catch ex As Exception
                        Str = Str + "&FromAge=0"
                    End Try
                Else
                    Str = Str + "&FromAge=0"
                End If
                If ToAgeGRB3.Text <> "" Then
                    Try
                        Str = Str + "&ToAge=" + ToAgeGRB3.Text
                    Catch ex As Exception
                        Str = Str + "&ToAge=200"
                    End Try
                Else
                    Str = Str + "&ToAge=200"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSB03.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 9
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSB04.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 10
                If cb1GRB5.Checked Then
                    Str = Str + "Endoscopist1=1"
                Else
                    Str = Str + "Endoscopist1=0"
                End If
                If cb2GRB5.Checked Then
                    Str = Str + "&Endoscopist2=1"
                Else
                    Str = Str + "&Endoscopist2=0"
                End If
                If cb1Tumour.Checked Then
                    Str = Str + "&Sessile=1"
                Else
                    Str = Str + "&Sessile=0"
                End If
                If in1GB5.Value.ToString = "" Then
                    Str = Str + "&SessileN=0"
                Else
                    Str = Str + "&SessileN=" + in1GB5.Value.ToString
                End If
                If cb2Tumour.Checked Then
                    Str = Str + "&Pedunculated=1"
                Else
                    Str = Str + "&Pedunculated=0"
                End If
                If in2GB5.Value.ToString = "" Then
                    Str = Str + "&PedunculatedN=0"
                Else
                    Str = Str + "&PedunculatedN=" + in2GB5.Value.ToString
                End If
                If cb3Tumour.Checked Then
                    Str = Str + "&Submucosal=1"
                Else
                    Str = Str + "&Submucosal=0"
                End If
                If in3GB5.Value.ToString = "" Then
                    Str = Str + "&SubmucosalN=0"
                Else
                    Str = Str + "&SubmucosalN=" + in3GB5.Value.ToString
                End If
                If cb4Tumour.Checked Then
                    Str = Str + "&Villous=1"
                Else
                    Str = Str + "&Villous=0"
                End If
                If in4GB5.Value.ToString = "" Then
                    Str = Str + "&VillousN=0"
                Else
                    Str = Str + "&VillousN=" + in4GB5.Value.ToString
                End If
                If cb5Tumour.Checked Then
                    Str = Str + "&Ulcerative=1"
                Else
                    Str = Str + "&Ulcerative=0"
                End If
                If in5GB5.Value.ToString = "" Then
                    Str = Str + "&UlcerativeN=0"
                Else
                    Str = Str + "&UlcerativeN=" + in5GB5.Value.ToString
                End If
                If cb6Tumour.Checked Then
                    Str = Str + "&Stricturing=1"
                Else
                    Str = Str + "&Stricturing=0"
                End If
                If in6GB5.Value.ToString = "" Then
                    Str = Str + "&StricturingN=0"
                Else
                    Str = Str + "&StricturingN=" + in6GB5.Value.ToString
                End If
                If cb7Tumour.Checked Then
                    Str = Str + "&Polypoidal=1"
                Else
                    Str = Str + "&Polypoidal=0"
                End If
                If in7GB5.Value.ToString = "" Then
                    Str = Str + "&PolypoidalN=0"
                Else
                    Str = Str + "&PolypoidalN=" + in7GB5.Value.ToString
                End If
                If FromAgeGRB5.Text <> "" Then
                    Try
                        Str = Str + "&FromAge=" + FromAgeGRB5.Text
                    Catch ex As Exception
                        Str = Str + "&FromAge=0"
                    End Try
                Else
                    Str = Str + "&FromAge=0"
                End If
                If ToAgeGRB5.Text <> "" Then
                    Try
                        Str = Str + "&ToAge=" + ToAgeGRB5.Text
                    Catch ex As Exception
                        Str = Str + "&ToAge=200"
                    End Try
                Else
                    Str = Str + "&ToAge=200"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSB05.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 11
                If cb1GRC1.Checked Then
                    Str = Str + "Endoscopist1=1"
                Else
                    Str = Str + "Endoscopist1=0"
                End If
                If cb2GRC1.Checked Then
                    Str = Str + "&Endoscopist2=1"
                Else
                    Str = Str + "&Endoscopist2=0"
                End If
                If radio1GRC1.SelectedValue = "COL" Then
                    Str = Str + "&ProcType=COL"
                Else
                    Str = Str + "&ProcType=SIG"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSC01.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 12
                If cb1GRC2.Checked Then
                    Str = Str + "Endoscopist1=1"
                Else
                    Str = Str + "Endoscopist1=0"
                End If
                If cb2GRC2.Checked Then
                    Str = Str + "&Endoscopist2=1"
                Else
                    Str = Str + "&Endoscopist2=0"
                End If
                If cb3GRC2.Checked Then
                    Str = Str + "&Summary=1"
                Else
                    Str = Str + "&Summary=0"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSC02.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 13
                If cb1GRC3.Checked Then
                    Str = Str + "Endoscopist1=1"
                Else
                    Str = Str + "Endoscopist1=0"
                End If
                If cb1GRC3.Checked Then
                    Str = Str + "&Endoscopist2=1"
                Else
                    Str = Str + "&Endoscopist2=0"
                End If
                'radio1GRC3
                If radio1GRC3.SelectedValue = "COL" Then
                    Str = Str + "&ProcType=COL"
                Else
                    Str = Str + "&ProcType=SIG"
                End If
                If cb3GRC3.Checked Then
                    Str = Str + "&Complications=1"
                Else
                    Str = Str + "&Complications=0"
                End If
                'cb4GRC3
                If cb4GRC3.Checked Then
                    Str = Str + "&ReversalAgents=1"
                Else
                    Str = Str + "&ReversalAgents=0"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSC03.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 14
                If radio1GRC4.SelectedValue = "COL" Then
                    Str = Str + "ProcType='COL'"
                Else
                    Str = Str + "ProcType='SIG'"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSC04.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 15
                If radio1GRC5.SelectedValue = "COL" Then
                    Str = Str + "ProcType=COL"
                Else
                    Str = Str + "ProcType=SIG"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSC05.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case 17
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                'lit.Text = lit.Text + "<p><a href=""" + Reporting.SSRSURL + Reporting.ReportURL + ReportsNameArr(RaiseEventPosition - 1) + GetReportParameters(RaiseEventPosition) + """>" + Mid(ReportName, 1, 3) + " " + Mid(ReportName, 4, 1) + "-" + Mid(ReportName, 6, 1) + "</a></p>" + vbCrLf
                pv.Controls.Add(lit)
                Dim RadGrid2 As New RadGrid
                RadGrid2.ID = "RadGrid2"
                RadGrid2.Skin = "Office2007"
                RadGrid2.HeaderStyle.CssClass = "UnisoftRGHead"
                RadGrid2.ItemStyle.CssClass = "UnisoftRG"
                RadGrid2.AllowPaging = True
                RadGrid2.AllowSorting = True
                RadGrid2.AutoGenerateColumns = True
                RadGrid2.RenderMode = RenderMode.Lightweight
                RadGrid2.MasterTableView.CommandItemDisplay = GridCommandItemDisplay.Top
                RadGrid2.MasterTableView.CommandItemStyle.HorizontalAlign = HorizontalAlign.Left
                RadGrid2.MasterTableView.CommandItemSettings.ShowExportToExcelButton = False
                RadGrid2.MasterTableView.CommandItemSettings.ShowAddNewRecordButton = False
                RadGrid2.MasterTableView.CommandItemSettings.ShowRefreshButton = False
                RadGrid2.Height = "560"
                'RadGrid2.DataSource = GetGetGRSC07()
                Dim chk As String = ""
                Dim FromAge As String = ""
                Dim ToAge As String = ""
                If cb3GRC7.Checked Then
                    chk = "1"
                Else
                    chk = "0"
                End If
                Select Case radio1GRC7.SelectedValue
                    Case "All"
                        FromAge = "0"
                        ToAge = "200"
                    Case "Under"
                        FromAge = "0"
                        Try
                            ToAge = Request("ToAgeGRC7").ToString
                        Catch ex As Exception
                            ToAge = "200"
                        End Try
                    Case "Over"
                        Try
                            FromAge = Request("FromAgeGRC7").ToString
                        Catch ex As Exception
                            FromAge = "0"
                        End Try
                        ToAge = "200"
                    Case "Between"
                        Try
                            ToAge = Request("ToAgeGRC7").ToString
                        Catch ex As Exception
                            ToAge = "200"
                        End Try
                        Try
                            FromAge = Request("FromAgeGRC7").ToString
                        Catch ex As Exception
                            FromAge = "0"
                        End Try
                    Case Else
                        FromAge = "0"
                        ToAge = "200"
                End Select

                RadGrid2.DataSource = Reports.GetGRSC07(Session("PKUserID").ToString, radio2GRC7.SelectedValue.ToString, radio3GRC7.SelectedValue.ToString, chk, FromAge, ToAge)
                RadGrid2.DataBind()
                RadGrid2.ShowFooter = False
                RadGrid2.ClientSettings.Scrolling.AllowScroll = True
                pv.Controls.Add(RadGrid2)
                RadGrid2.Visible = True
                'pv.Controls.Add(lit)
            Case 18
                If cb1GRC8.Checked = True Then
                    Str = Str + "UnitAsAWhole=1"
                Else
                    Str = Str + "UnitAsAWhole=0"
                End If
                If cb2GRC8.Checked = True Then
                    Str = Str + "&ListPatients=1"
                Else
                    Str = Str + "&ListPatients=0"
                End If
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""RV/GRSC08.aspx?" + Str + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
            Case Else
                lit.Text = "<h2>" + ReportsTitleArr(RaiseEventPosition - 1) + "</h2>" + vbCrLf
                lit.Text = "<p style=""color:red;"">Debug: " + Reporting.SSRSURL + Reporting.ReportURL + ReportsNameArr(RaiseEventPosition - 1) + GetReportParameters(RaiseEventPosition) + "</p>" + vbCrLf
                lit.Text = lit.Text + "<iframe src=""" + Reporting.SSRSURL + Reporting.ReportURL + ReportsNameArr(RaiseEventPosition - 1) + GetReportParameters(RaiseEventPosition) + """ class=""if""></iframe>"
                pv.Controls.Add(lit)
        End Select
        If RadMultiPageParameters.PageViews.Count() > 0 Then
            RadMultiPageParameters.PageViews(0).Selected = True
        End If
    End Sub
    Private Sub AddPageView(ByVal tab As RadTab)
        Dim pageView As RadPageView = New RadPageView
        pageView.ID = tab.Text
        RadMultiPageReports.PageViews.Add(pageView)
        tab.PageViewID = pageView.ID
        Me.RadTabStripReports.Tabs(0).Selected = True
        Me.RadTabStripParameters.Tabs(0).Selected = True
    End Sub
    Function GetReportParameters(ByVal ReportNumber As Integer) As String
        Dim str As String = "&UserID=" + Session("PKUserID").ToString
        Select Case ReportNumber
            Case 17
                str = str + ", @ProcType='" + radio2GRC7.SelectedValue.ToString + "', @OutputAs=" + radio3GRC7.SelectedValue.ToString
                If cb3GRC7.Checked Then
                    str = str + ", @Check=1"
                Else
                    str = str + ", @Check=0"
                End If
                Select Case radio1GRC7.SelectedValue
                    Case "All"
                        str = str + ", @FromAge=0, @ToAge=200"
                    Case "Under"
                        str = str + ", @FromAge=0, @ToAge=" + Me.ToAgeGRC7.Text.ToString
                    Case "Over"
                        str = str + ", @FromAge=" + Me.FromAgeGRC7.Text.ToString + ", @ToAge=200"
                    Case "Between"
                        str = str + ", @FromAge=" + Me.FromAgeGRC7.Text.ToString + ", @ToAge=" + Me.ToAgeGRC7.Text.ToString
                End Select
            Case Else
                str = str
        End Select
        Return str
    End Function
    Protected Sub TypeOfConsultant_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ComboConsultants.SelectedIndexChanged, cbHideSuppressed.CheckedChanged
        Reporting.CleanListBoxes(Session("PKUserId").ToString)
        Reporting.SetConsultantType(Me.ComboConsultants.SelectedValue.ToString, Me.cbHideSuppressed.Checked)
        Me.RadListBox2.Items.Clear()
        Me.RadListBox1.Items.Clear()
        Me.RadListBox1.DataBind()
        Me.RadListBox2.DataBind()
        Me.SqlDSAllConsultants.DataBind()
        Me.SqlDSSelectedConsultants.DataBind()
    End Sub
    Protected Sub SetUserIDFilter(ByVal UserID As String)
        Try
            Reporting.FromDate = RDPFrom.SelectedDate
        Catch ex As Exception
            Reporting.FromDate = "01/01/2018"
        End Try
        Try
            Reporting.ToDate = RDPTo.SelectedDate
        Catch ex As Exception
            Reporting.ToDate = "31/12/2099"
        End Try
        If ComboConsultants.Items(0).Selected Then
            Reporting.TypeOfConsultant = 0
        ElseIf ComboConsultants.Items(1).Selected Then
            Reporting.TypeOfConsultant = 1
        ElseIf ComboConsultants.Items(2).Selected Then
            Reporting.TypeOfConsultant = 2
        ElseIf ComboConsultants.Items(3).Selected Then
            Reporting.TypeOfConsultant = 3
        ElseIf ComboConsultants.Items(4).Selected Then
            Reporting.TypeOfConsultant = 4
        ElseIf ComboConsultants.Items(5).Selected Then
            Reporting.TypeOfConsultant = 5
        ElseIf ComboConsultants.Items(6).Selected Then
            Reporting.TypeOfConsultant = 6
        Else
            Reporting.TypeOfConsultant = 0
        End If
        If Me.cbHideSuppressed.Checked Then
            Reporting.HideSuppressed = True
        Else
            Reporting.HideSuppressed = False
        End If
        Dim sql As String = ""
        Dim sql2 As String = ""
        Select Case Me.ComboConsultants.SelectedValue.ToString
            Case "AllConsultants"
                sql2 = " And ((IsEndoscopist1='1') Or (IsEndoscopist2='1') Or (IsListConsultant='1') Or (IsAssistantOrTrainee='1') Or (IsNurse1='1') Or (IsNurse2='1'))"
            Case "Endoscopist1"
                sql2 = " And IsEndoscopist1='1'"
            Case "Endoscopist2"
                sql2 = " And IsEndoscopist2='1'"
            Case "ListConsultant"
                sql2 = " And IsListConsultant='1'"
            Case "Assistant"
                sql2 = " And IsAssistantOrTrainee='1'"
            Case "Nurse1"
                sql2 = " And IsNurse1='1'"
            Case "Nurse2"
                sql2 = " And IsNurse2='1'"
            Case Else
        End Select
        sql = "Update [dbo].[ERS_ReportFilter] Set ReportDate=GetDate(), FromDate=Convert(Date,SubString('" + Reporting.FromDate + "',7,4)+'-'+SubString('" + Reporting.FromDate + "',4,2)+'-'+SubString('" + Reporting.FromDate + "',1,2)) , ToDate=Convert(Date,SubString('" + Reporting.ToDate + "',7,4)+'-'+SubString('" + Reporting.ToDate + "',4,2)+'-'+SubString('" + Reporting.ToDate + "',1,2)) "
        sql = sql + ", HideSuppressed='" + Reporting.HideSuppressed.ToString + "'"
        sql = sql + ", TrustId ='" + Session("TrustId") + "'"

        'sql = sql + ", TypesOfEndoscopists='" + Reporting.TypeOfConsultant.ToString + "'"
        sql = sql + " WHERE UserID = " + Session("PKUserID").ToString
        Reporting.Transaction(sql)
        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand(sql, connection)
        '    cmd.CommandType = CommandType.Text
        '    cmd.Connection.Open()
        '    cmd.ExecuteNonQuery()
        'End Using
        'sql = "Delete [dbo].[ERS_ReportConsultants] Where UserID=0 And UserId In (" + Session("PKUserID").ToString + ")"
        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand(sql, connection)
        '    cmd.CommandType = CommandType.Text
        '    cmd.Connection.Open()
        '    cmd.ExecuteNonQuery()
        '    cmd.Dispose()
        'End Using
        sql = "Insert Into [dbo].[ERS_ReportConsultants] (UserID, ConsultantID, AnonimizedID) "
        sql = sql + "Select UserID=" + Session("PKUserID").ToString + ", ConsultantID=ReportID, AnonimizedID=ReportID From [dbo].[v_rep_Consultants] Where ReportID In (0"
        For Each Item As RadListBoxItem In RadListBox2.Items
            sql = sql + "," + Item.Value.ToString
        Next
        sql = sql + ") " '+ sql2
        Reporting.Transaction(sql)
        If Reporting.ErrorMsg <> "" Then
            'MsgBox(Reporting.ErrorMsg)
        End If
        sql = "Exec report_Anonimize " + Session("PKUserID").ToString + " ,0"
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd3 As New SqlCommand(sql, connection)
            cmd3.CommandType = CommandType.Text
            cmd3.Connection.Open()
            cmd3.ExecuteNonQuery()
            cmd3.Dispose()
        End Using
        'Reporting.LoadDefaultsFromDB(Session("PKUserID").ToString)
    End Sub

    Protected Sub RadButtonFilter_Click()
        Dim ReportsArr As String() = {"GRSA01", "GRSA02", "GRSA03", "GRSA04", "GRSA05", "GRSB01", "GRSB02", "GRSB03", "GRSB04", "GRSB05", "GRSC01", "GRSC02", "GRSC03", "GRSC04", "GRSC05", "GRSC06", "GRSC07", "GRSC08"}
        Dim TabName As String = ""
        Dim taby As RadTab
        Dim pagy As RadPageView
        Dim Sql As String = ""
        Dim i As Integer = 0
        If CDate(Me.RDPFrom.SelectedDate.ToString) <= CDate(Me.RDPTo.SelectedDate.ToString) Then
            Reporting.CleanListBoxes(Session("PKUserId").ToString)
            Reporting.SetConsultantType(Me.ComboConsultants.SelectedValue.ToString, Me.cbHideSuppressed.Checked)
            Sql = "Delete ERS_ReportConsultants Where UserID=" + Session("PKUserID").ToString
            Reporting.Transaction(Sql)
            Sql = "Delete ERS_ReportFilter Where UserID=" + Session("PKUserID").ToString
            Reporting.Transaction(Sql)
            Sql = "Insert Into ERS_ReportFilter (UserId) Values (" + Session("PKUserID").ToString + ")"
            Reporting.Transaction(Sql)
            SetUserIDFilter(Session("PKUserID").ToString)
            Me.RadListBox2.Items.Clear()
            Me.RadListBox1.Items.Clear()
            Me.RadListBox1.DataBind()
            Me.RadListBox2.DataBind()
            'Reporting.LoadDefaultsFromDB(Session("PKUserID").ToString)
            Dim str As String = ""

            Reporting.Parameters = ""
            '-----------------------------------------------˅
            ' This part is especific for each report
            Reporting.Parameters = str
            '-----------------------------------------------˄
            For i = RadTabStripReports.Tabs.Count - 1 To 1 Step -1
                taby = RadTabStripReports.Tabs(i)
                RadTabStripReports.Tabs.Remove(taby)
            Next
            For i = RadMultiPageReports.PageViews.Count - 1 To 1 Step -1
                pagy = RadMultiPageReports.PageViews(i)
                RadMultiPageReports.PageViews.Remove(pagy)
            Next
            GRSArray = tbGRSArray.Text
            For i = 1 To 18
                If Mid(GRSArray, i, 1) = "1" Then
                    AddTab(i)
                End If
            Next
        Else
            Return
        End If
    End Sub

    Protected Sub RadTabStrip1_TabClick1(sender As Object, e As RadTabStripEventArgs)
        Dim TabClicked As RadTab = e.Tab

        RadTabStrip1.FindTabByText(TabClicked.Text).Selected = True
        MiscPageView.Selected = True
        ' LeftMenuTreeView.Enabled = False
        ''MsgBox(TabClicked.Text)
        Select Case TabClicked.Text
            Case "GRS"
                GRSPageView.Selected = True
                '        'MainMultiPage.PageViews(0).Selected = True
                'LeftMenuTreeView.Enabled = True
                LoadTreeView("ReportsMenu")
                RadPageViewReports.Selected = True
                GRSA01PV.Selected = True
            Case Else
                MiscPageView.Selected = True
                MiscPageView.Visible = True
                MiscPageView.Enabled = True

                '        'Response.Redirect("JAGGRS.aspx")
                '        RadTabStrip1.FindTabByText("").Selected = True
                '        'MainMultiPage.PageViews(1).Selected = True
                LoadTreeView("ReportsMenuMisc")
                'LeftMenuTreeView.Enabled = False
                'Case Else
        End Select
    End Sub

End Class