Imports Telerik.Web.UI
Imports System.Globalization
Imports System.Data.SqlClient
Imports System.Web.Services
Public Class Products_Reports_Grs
    Inherits PageBase
    Public _GRSArray = "111111111111111111"
    Public IFRAME_TAG As String = "<iframe id='iFrameReportPanel' style='width:98%; height:460px; padding:1em;'" '### Single Place to control the iFrame behaviour!
    Dim Current_UserId As String

#Region "Date Variables" '## These values are used heavily in this page.. In both String and Date format. So- make it here once and re-use it later!
    Dim dateFromFilterParam As Date, _
        dateToFilterParam As Date

    Private _dateFromText As String
    Public ReadOnly Property DateFromText() As String
        Get
            Return dateFromFilterParam.ToString("yyyy/MM/dd")
        End Get
    End Property

    Private _dateToText As String
    Public ReadOnly Property DateToText() As String
        Get
            Return dateToFilterParam.ToString("yyyy/MM/dd")

        End Get
    End Property
#End Region '### Date Variable!



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
            Current_UserId = Session("PKUserID").ToString
            'SUID.Text = Current_UserId
        End If


        If Not Page.IsPostBack Then
            LoadPageInitialSettings()
        End If

        LoadOnEachTimePageIsViewed()

    End Sub

    Sub LoadPageInitialSettings()
        'Populate GRS reports treeview
        LeftMenuTreeView.Nodes.Clear()
        LeftMenuTreeView.LoadContentFile(Page.ResolveUrl("~/App_Data/Menus/ReportsMenu.xml"))
        LeftMenuTreeView.ExpandAllNodes()

        LoadConsultantListByType("all", False)


        '### OK- not reading from DB- just Direct value in the ListItemCollection
        'ComboConsultants.Items.Clear()
        'ComboConsultants.DataSource = DataAccess.ExecuteSP("usp_rep_ConsultantTypes", Nothing)
        'ComboConsultants.DataTextField = "Description"
        'ComboConsultants.DataValueField = "ListItemNo"            
        'ComboConsultants.DataBind()
        'ComboConsultants.Items.Add(New RadComboBoxItem("All", "0"))
        'ComboConsultants.FindItemByValue("0").Selected = True

    End Sub

    Sub LoadOnEachTimePageIsViewed()
        'Session("Nodo") = LeftMenuTreeView.GetXml
        '-----------------------------------------------˅
        ' This part is especific for each report
        Reporting.PageTitle = "GRS - Reports"
        Reporting.ReportName = "GRS"
        '-----------------------------------------------˄
        If RDPFrom.SelectedDate.ToString = "" Then
            Reporting.LoadDefaultsFromDB(Current_UserId)
            Try
                Me.RDPFrom.SelectedDate = Reporting.FromDate.ToString
                Me.RDPTo.SelectedDate = Reporting.ToDate.ToString

                dateFromFilterParam = Reporting.FromDate    '### These two will be re-used all over!
                dateToFilterParam = Reporting.ToDate

            Catch ex As Exception
                RDPFrom.Culture = New CultureInfo("en-GB")
                RDPTo.Culture = New CultureInfo("en-GB")
                Me.RDPFrom.SelectedDate = "01/01/1980"
                Me.RDPTo.SelectedDate = "31/12/2099"
            End Try
            cbHideSuppressed.Checked = Reporting.HideSuppressed
            ComboConsultants.SelectedIndex = Reporting.TypeOfConsultant
            ComboConsultants.Items(0).Selected = True
            'Reporting.LoadDefaultsFromDB(Current_UserId)
        End If
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

    Sub AddTab(ByVal sNodeCustomId As String, ByVal sNodeTooltip As String, ByVal sNodeText As String)

        Dim t As New RadTab
        t.Text = Left(sNodeText, 8) 'Mid(ReportName, 1, 3) + " " + Mid(ReportName, 4, 1) + "-" + Mid(ReportName, 6, 1)
        t.ToolTip = sNodeTooltip
        RadTabStripReports.Tabs.Add(t)
        Dim pv As New RadPageView
        pv.ID = "P" + sNodeCustomId
        RadMultiPageReports.PageViews.Add(pv)

        Dim lit As New Literal
        Dim Str As String = ""

        Select Case sNodeCustomId
            Case "GRSA01"
                lit.Text = CreateHeaderString(sNodeText)
                lit.Text = lit.Text + Create_iFrame("RV/GRSA01.aspx", "if")
                pv.Controls.Add(lit)
            Case "GRSA02"
                'If cb3GRA2.Checked = True Then
                '    Str = Str() + "Endoscopist1=1"
                'Else
                '    Str = Str() + "Endoscopist1=0"
                'End If
                'If cb4GRA2.Checked = True Then
                '    Str = Str() + "&Endoscopist2=1"
                'Else
                '    Str = Str() + "&Endoscopist2=0"
                'End If

                Str = If(cb3GRA2.Checked, "OGD=1", "OGD=0")
                Str = Str + IIf(cb4GRA2.Checked, "&COLSIG=1", "&COLSIG=0")

                lit.Text = CreateHeaderString(sNodeText)
                lit.Text = lit.Text + Create_iFrame("RV/GRSA02.aspx?" + Str + """", "if")
                pv.Controls.Add(lit)
            Case "GRSA04"
                Str = Str + "Summary=" + IIf(cb1GRA4.Checked, "1", "0")
                Str = Str + "&Patients=" + IIf(cb2GRA4.Checked, "1", "0")

                'lit.Text = "<h2>" + sNodeText + "</h2>" + vbCrLf
                lit.Text = CreateHeaderString(sNodeText)

                'lit.Text = lit.Text + "<div style=""padding-bottom: 10px;"" class=""ConfigureBg"">" + "<iframe src=""RV/GRSA04.aspx?" + Str + """ class=""repFrame""></iframe>" + "</div>" -- Commented by Shawkat Osman; 2016-06-13
                lit.Text = lit.Text + "<div style=""padding-bottom: 10px;"" class=""ConfigureBg"">" + Create_iFrame("RV/GRSA04.aspx?" + Str, "repFrame") + "</div>"
                pv.Controls.Add(lit)
        End Select

    End Sub

    ''' <summary>
    ''' This will Build the Text for the [iframe]
    ''' Will take the necessary parameters and build the iFrame dynamically
    ''' </summary>
    ''' <param name="SourcePageName">Report Page name, ie: RV/GRS01.aspx</param>
    ''' <param name="StyleClass">Any special class. ie: 'if'</param>
    ''' <returns>Builds the <iFrame> and returns string</returns>
    ''' <remarks></remarks>
    Private Function Create_iFrame(ByVal SourcePageName As String, ByVal StyleClass As String) As String
        Return String.Format("{0}src='{1}' class='{2}'></iframe>", IFRAME_TAG, SourcePageName, StyleClass)
    End Function

    ''' <summary>
    ''' This wil biuld a HTML:H2 Header Text.
    ''' </summary>
    ''' <param name="headerText">Text to Include in the <H2></H2> Tag</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function CreateHeaderString(headerText As String) As String
        Return "<h2>" + headerText + "</h2>" + vbCrLf
    End Function

    Sub LoadConsultantListByType(ByVal consultantType As String, Optional ByVal HideSuppressed As Boolean = False)
        'With RadListBox1
        '    .Items.Clear()
        '    .DataSource = Reporting.GetConsultants(consultantType, HideSuppressed)
        '    .DataTextField = "Consultant"
        '    .DataValueField = "UserId"
        '    .DataBind()
        'End With
    End Sub

    Private Sub AddPageView(ByVal tab As RadTab)
        'Dim pageView As RadPageView = New RadPageView
        'pageView.ID = tab.Text
        'RadMultiPageReports.PageViews.Add(pageView)
        'tab.PageViewID = pageView.ID
        'Me.RadTabStripReports.Tabs(0).Selected = True
        'Me.RadTabStripParameters.Tabs(0).Selected = True
    End Sub
    Function GetReportParameters(ByVal ReportNumber As Integer) As String
        Dim str As String = "&UserID=" + Current_UserId
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

    '    End Sub
    Protected Sub TypeOfConsultant_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ComboConsultants.SelectedIndexChanged, cbHideSuppressed.CheckedChanged
        'Reporting.CleanListBoxes(Current_UserId)
        'Reporting.SetConsultantType(Me.ComboConsultants.SelectedValue.ToString, Me.cbHideSuppressed.Checked)
        'Me.RadListBox2.Items.Clear()
        Dim selectedOperatorType As String = "", _
            selectedOperatorValue As String = ComboConsultants.SelectedValue.ToString()

        If (selectedOperatorValue.Contains("Endoscopist")) Then
            selectedOperatorType = "endoscopist"
        ElseIf (selectedOperatorValue.Contains("Nurse")) Then
            selectedOperatorType = "nurse"
        ElseIf (selectedOperatorValue.Contains("Asst")) Then
            selectedOperatorType = "assistant"
        ElseIf (selectedOperatorValue.Contains("List")) Then
            selectedOperatorType = "list"
        End If

        Me.RadListBox1.Items.Clear()
        LoadConsultantListByType(selectedOperatorType, cbHideSuppressed.Checked)
        'Me.RadListBox1.DataBind()
        'Me.RadListBox2.DataBind()

        'Me.SqlDSAllConsultants.DataBind()
        'Me.SqlDSSelectedConsultants.DataBind()
    End Sub

    Protected Sub SetUserIDFilter()

        Try
            Reporting.FromDate = RDPFrom.SelectedDate
            dateFromFilterParam = RDPFrom.SelectedDate
        Catch ex As Exception
            Reporting.FromDate = "01/01/1980"
        End Try
        Try
            Reporting.ToDate = RDPTo.SelectedDate
            dateToFilterParam = RDPTo.SelectedDate
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

        Reporting.HideSuppressed = cbHideSuppressed.Checked

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

        Reporting.UpdateReportFilterParamTable()    ''#### All the required variables are already feed in the Shared Class-'Reporting.vb'
        'sql = String.Format("Update [dbo].[ERS_ReportFilter] Set ReportDate=GetDate(), FromDate='{0}', ToDate='{1}', HideSuppressed='{2}' WHERE UserID={3}", DateFromText, DateToText, Reporting.HideSuppressed.ToString, Current_UserId)

        'sql = sql + ", TypesOfEndoscopists='" + Reporting.TypeOfConsultant.ToString + "'"



        sql = "Insert Into [dbo].[ERS_ReportConsultants] (UserID, ConsultantID, AnonimizedID) "
        sql = sql + "Select UserID=" + Current_UserId + ", ConsultantID=ReportID, AnonimizedID=ReportID From [dbo].[v_rep_Consultants] Where ReportID In (0"
        For Each Item As RadListBoxItem In RadListBox1.Items
            sql = sql + "," + Item.Value.ToString
        Next
        sql = sql + ") " '+ sql2
        DataAccess.ExecuteScalerSQL(sql, CommandType.Text)
        If Reporting.ErrorMsg <> "" Then
            'MsgBox(Reporting.ErrorMsg)
        End If
        sql = "Exec report_Anonimize " + Current_UserId + " ,0" '#### This will execute Two Cursors(!).. don't understand why! Designed by William!
        'DataAccess.ExecuteScalerSQL(sql) 'xx Shorter and sweeter; Shawkat; 2017-06-16

    End Sub

    Private Sub RadButtonFilter_Click(sender As Object, e As EventArgs) Handles RadButtonFilter.Click
        Dim ReportsArr As String() = {"GRSA01", "GRSA02", "GRSA03", "GRSA04", "GRSA05", "GRSB01", "GRSB02", "GRSB03", "GRSB04", "GRSB05", "GRSC01", "GRSC02", "GRSC03", "GRSC04", "GRSC05", "GRSC06", "GRSC07", "GRSC08"}
        Dim TabName As String = ""
        Dim taby As RadTab
        Dim pagy As RadPageView
        Dim Sql As String = ""
        Dim i As Integer = 0
        If CDate(Me.RDPFrom.SelectedDate.ToString) <= CDate(Me.RDPTo.SelectedDate.ToString) Then
            Reporting.CleanListBoxes(Current_UserId)
            Reporting.SetConsultantType(Me.ComboConsultants.SelectedValue.ToString, Me.cbHideSuppressed.Checked)
            Reporting.UserID = Current_UserId

            '#### Also store the Filter Dates- DateFrom and DateTo in the session.. so We can read the Dates directly from session rather than referring back to the Table! Shawkat Osman; 2017-06-14
            Session("ReportFilterDateFrom") = DateFromText
            Session("ReportFilterDateTo") = DateToText

            SetUserIDFilter()

            'Me.RadListBox2.Items.Clear()
            'Me.RadListBox1.Items.Clear()
            'Me.RadListBox1.DataBind()
            'Me.RadListBox2.DataBind()
            'Reporting.LoadDefaultsFromDB(Current_UserId)
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

            For Each node As RadTreeNode In LeftMenuTreeView.CheckedNodes
                If node.Level = 1 Then
                    Dim sNodeCustomId As String = node.Attributes.Item("CustomId")
                    Dim sNodeTooltip As String = node.ToolTip
                    Dim sNodeText As String = node.Text
                    AddTab(sNodeCustomId, sNodeTooltip, sNodeText)
                    'Dim rt As RadTab = RadTabStripParameters.FindTabByValue(customId)
                    'If node.Checked Then
                    '    rt.Style.Add("display", "block")
                    '    bChecked = True
                    'Else
                    '    rt.Style.Add("display", "none")
                    'End If
                End If
            Next


            'GRSArray = tbGRSArray.Text
            'For i = 1 To 18
            '    If Mid(GRSArray, i, 1) = "1" Then
            '        AddTab(i)
            '    End If
            'Next
        Else
            Return
        End If
    End Sub

    Protected Sub RadTabStrip1_TabClick1(sender As Object, e As RadTabStripEventArgs)
        'Dim TabClicked As RadTab = e.Tab

        'RadTabStrip1.FindTabByText(TabClicked.Text).Selected = True
        'MiscPageView.Selected = True
        '' LeftMenuTreeView.Enabled = False
        ' ''MsgBox(TabClicked.Text)
        'Select Case TabClicked.Text
        '    Case "GRS"
        '        GRSPageView.Selected = True
        '        '        'MainMultiPage.PageViews(0).Selected = True
        '        'LeftMenuTreeView.Enabled = True
        '        LoadTreeView("ReportsMenu")
        '        RadPageViewReports.Selected = True
        '        GRSA01PV.Selected = True
        '    Case Else
        '        MiscPageView.Selected = True
        '        MiscPageView.Visible = True
        '        MiscPageView.Enabled = True

        '        '        'Response.Redirect("JAGGRS.aspx")
        '        '        RadTabStrip1.FindTabByText("").Selected = True
        '        '        'MainMultiPage.PageViews(1).Selected = True
        '        LoadTreeView("ReportsMenuMisc")
        '        'LeftMenuTreeView.Enabled = False
        '        'Case Else
        'End Select
    End Sub

    Private Sub Page_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
        'Dim node As RadTreeNode = LeftMenuTreeView.FindNodeByText("GRS A-1")
        'If node IsNot Nothing Then
        '    ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "toggleTreeView(" + node + ");", True)
        'Else
        '    ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "toggleTreeView(null);", True)
        'End If
        '  
        'For i As Integer = 0 To RadTabStripParameters.GetAllTabs.Count - 1 Step 1
        '    Dim tab As RadTab = RadTabStripParameters.Tabs(i)
        '    tab.Style.Add("display", "none")
        'Next


        ''For Each tab As RadTab In RadTabStripParameters.GetAllTabs
        ''    tab.Style.Add("display", "none")
        ''Next

        'Dim bChecked As Boolean = False
        'For Each node As RadTreeNode In LeftMenuTreeView.CheckedNodes
        '    If node.Level = 1 Then
        '        Dim customId As String = node.Attributes.Item("CustomId")
        '        Dim rt As RadTab = RadTabStripParameters.FindTabByValue(customId)
        '        If node.Checked Then
        '            rt.Style.Add("display", "block")
        '            bChecked = True
        '        Else
        '            rt.Style.Add("display", "none")
        '        End If
        '    End If
        'Next

        ''Hide parameters tabs - first time only
        'Dim divRTSP As System.Web.UI.HtmlControls.HtmlGenericControl = Me.FindControl("RTSP")
        'If bChecked Then
        '    If divRTSP IsNot Nothing Then divRTSP.Style.Add("display", "block")
        'Else
        '    If divRTSP IsNot Nothing Then divRTSP.Style.Add("display", "none")
        '    GRSA01PV.Style.Add("display", "none")
        'End If
    End Sub

End Class
