Imports System.Web.Services
Imports System.Web.Script.Services


Partial Public Class UserControls_diagram
    Inherits System.Web.UI.UserControl

#Region "Properties"
    Private Const CalledFrom As String = "Default"
    Private _procedureId As Integer
    Private _episodeNo As Integer
    Private _procedureTypeId As Integer
    Private _forPrinting As Boolean
    Private _diagramNumber As Integer
    Private _ColonType As Integer
    Private _imageGenderId As Integer

    Public Property Source() As String
        Get
            If ViewState(CalledFrom) Is Nothing Then
            End If
            Return ViewState(CalledFrom).ToString()
        End Get

        Set(value As String)
            ViewState(CalledFrom) = value
        End Set
    End Property

    Public ReadOnly Property DiagramHeight As Integer
        Get
            Return CInt(ConfigurationManager.AppSettings("Unisoft.DiagramHeight"))
        End Get
    End Property

    Public ReadOnly Property DiagramWidth As Integer
        Get
            Return CInt(ConfigurationManager.AppSettings("Unisoft.DiagramWidth"))
        End Get
    End Property

    Public ReadOnly Property RegionPathsJson As String
        Get
            If ViewState("_mRegionPathsJson") Is Nothing Then
                ViewState("_mRegionPathsJson") = GetRegionPathsJson()
            End If
            Return CStr(ViewState("_mRegionPathsJson"))
        End Get
    End Property

    Public ReadOnly Property RegionPathsEbusLymphNodesJson As String
        Get
            If ViewState("_mRegionPathsEbusLymphNodesJson") Is Nothing Then
                ViewState("_mRegionPathsEbusLymphNodesJson") = GetRegionPathsEbusLymphNodesJson()
            End If
            Return CStr(ViewState("_mRegionPathsEbusLymphNodesJson"))
        End Get
    End Property

    Public ReadOnly Property RegionPathsProtocolSitesJson As String
        Get
            If ViewState("_mRegionPathsProtocolSitesJson") Is Nothing Then
                ViewState("_mRegionPathsProtocolSitesJson") = GetRegionPathsProtocolSitesJson()
            End If
            Return CStr(ViewState("_mRegionPathsProtocolSitesJson"))
        End Get
    End Property

    Public ReadOnly Property ResectedColonRegionsJson As String
        Get
            If ViewState("_mResectedColonRegionsJson") Is Nothing Then
                ViewState("_mResectedColonRegionsJson") = GetResectedColonRegionsJson()
            End If
            Return CStr(ViewState("_mResectedColonRegionsJson"))
        End Get
    End Property

    Public ReadOnly Property SitesDataJson As String
        Get
            If ViewState("_msitesDataJson") Is Nothing Then
                ViewState("_msitesDataJson") = GetSitesDataJson()
            End If
            Return CStr(ViewState("_msitesDataJson"))
        End Get
    End Property

    Public Property ProcedureId As Integer
        Get
            Return _procedureId
        End Get

        Set(value As Integer)
            _procedureId = value
        End Set
    End Property

    Public Property EpisodeNo As Integer
        Get
            Return _episodeNo
        End Get

        Set(value As Integer)
            _episodeNo = value
        End Set
    End Property

    Public Property ProcedureTypeId As Integer
        Get
            Return _procedureTypeId
        End Get

        Set(value As Integer)
            _procedureTypeId = value
        End Set
    End Property
    Public Property ColonType As Integer
        Get
            Return _ColonType
        End Get

        Set(value As Integer)
            _ColonType = value
        End Set
    End Property

    Public Property DiagramNumber As Integer
        Get
            Return _diagramNumber
        End Get

        Set(value As Integer)
            _diagramNumber = value
        End Set
    End Property
    Public Property ImageGenderId As Integer
        Get
            Return _imageGenderId
        End Get

        Set(value As Integer)
            _imageGenderId = value
        End Set
    End Property


    Public Property ForPrinting As Boolean
        Get
            Return _forPrinting
        End Get

        Set(value As Boolean)
            _forPrinting = value
        End Set
    End Property
#End Region

    'Protected Sub UserControls_diagram_Load(sender As Object, e As EventArgs) Handles Me.Load
    '    'LoadDiagram()
    'End Sub

    Dim scriptStr As String = String.Empty

    Friend Sub LoadDiagram()
        Dim scriptVarStr As String = String.Empty
        Dim regJson As String = String.Empty
        Dim regEbusLymphNodesJson As String = String.Empty
        Dim sitesJson As String = String.Empty
        Dim sImageUrl As Tuple(Of String, String) = GetImageUrl(ProcedureTypeId, DiagramNumber, ImageGenderId)

        regJson = GetRegionPathsJson()
        If regJson = "[]" Then
            scriptStr = "alert('Regions are not defined in the database!');"
        Else
            scriptStr = "LoadBasics();"
            sitesJson = GetSitesDataJson()
            If sitesJson <> "" And sitesJson <> "[]" Then
                scriptStr = "LoadBasics();LoadExistingPatient();"
            End If
        End If

        If ProcedureTypeId = ProcedureType.EBUS Then
            regEbusLymphNodesJson = GetRegionPathsEbusLymphNodesJson()
        End If

        ViewState("_mRegionPathsJson") = regJson
        ViewState("_msitesDataJson") = sitesJson
        ViewState("_mRegionPathsEbusLymphNodesJson") = regEbusLymphNodesJson

        scriptVarStr = "var diagramHeight = '" & DiagramHeight & "';"
        scriptVarStr += "var diagramWidth = '" & DiagramWidth & "';"
        scriptVarStr += "var selectedProcType = '" & ProcedureTypeId & "';"
        scriptVarStr += "var procedureId = '" & ProcedureId & "';"
        scriptVarStr += "var colonType = '" & ColonType & "';"
        scriptVarStr += "var forPrinting = '" & ForPrinting & "';"
        scriptVarStr += "var resectionColonId = '" & GetResectionColon() & "';"
        scriptVarStr += "var currentSiteId;"

        'If ProcedureTypeId = ProcedureType.EBUS Then
        '    scriptVarStr += "var regionPaths = '" & RegionPathsEbusLymphNodesJson & "';"
        'Else
        scriptVarStr += "var regionPaths = '" & RegionPathsJson & "';"
        'End If

        scriptVarStr += "var resectionColonRegions = '" & GetResectedColonRegionsJson() & "';"
        scriptVarStr += "var existingSites = '" & SitesDataJson & "';"
        scriptVarStr += "var regionPathsEbusLymphNodes = '" & RegionPathsEbusLymphNodesJson & "';"
        scriptVarStr += "var regionPathsProtocolSites = '" & RegionPathsProtocolSitesJson & "';"
        scriptVarStr += "var siteRadius = " & GetSiteRadius() & ";"
        'scriptVarStr += "var imageUrl = '" & GetImageUrl(ProcedureTypeId, DiagramNumber) & "';"
        scriptVarStr += "var imageUrl = '" & sImageUrl.Item1 & "';"

        scriptStr = scriptVarStr & scriptStr

        If ForPrinting Then
            scriptStr = scriptStr & " ReturnSvgXml('" & sImageUrl.Item2 & "');"
        End If

        If ViewState(CalledFrom) = "PatientProcedure" Then
            Page.ClientScript.RegisterStartupScript(Me.GetType(), "CallMyFunction", scriptStr, True)
        Else
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CallMyFunction", scriptStr, True)
        End If
    End Sub

    Private Function GetRegionPathsJson() As String
        Dim dtPaths As DataTable
        Dim da As New DataAccess
        dtPaths = da.GetDiagram(ProcedureTypeId, DiagramNumber, DiagramHeight, DiagramWidth, True, ImageGenderId)
        Return DataTableToJson(dtPaths)
    End Function

    Private Function GetRegionPathsEbusLymphNodesJson() As String
        Dim dtPaths As DataTable
        Dim da As New DataAccess
        dtPaths = da.GetRegionPathsEbusLymphNodes(DiagramHeight, DiagramWidth)
        Return DataTableToJson(dtPaths)
    End Function

    Private Function GetRegionPathsProtocolSitesJson() As String
        Dim dtPaths As DataTable
        Dim da As New DataAccess
        dtPaths = da.GetRegionPathsProtocolSites(ProcedureId)
        Return DataTableToJson(dtPaths)
    End Function

    Private Function GetResectedColonRegionsJson() As String
        If ProcedureTypeId = ProcedureType.Colonoscopy Or ProcedureTypeId = ProcedureType.Bronchoscopy Or ProcedureTypeId = ProcedureType.Sigmoidscopy Or ProcedureTypeId = ProcedureType.Retrograde Then
            Dim dtResectedColonRegions As DataTable
            Dim da As New DataAccess
            dtResectedColonRegions = da.GetResectedColonRegions()
            Return DataTableToJson(dtResectedColonRegions)
        Else
            Return "[]"
        End If
    End Function

    Private Function GetResectionColon() As String
        If ProcedureTypeId = ProcedureType.Colonoscopy Or ProcedureTypeId = ProcedureType.Bronchoscopy Or ProcedureTypeId = ProcedureType.Sigmoidscopy Or ProcedureTypeId = ProcedureType.Retrograde Then
            Dim da As New DataAccess
            Return da.GetResectedColonDetails(CInt(Session(Constants.SESSION_PROCEDURE_ID)), EpisodeNo, IIf(ProcedureTypeId = ProcedureType.Retrograde, True, False))
        Else
            Return "0"
        End If
    End Function

    Private Function GetSitesDataJson() As String
        Dim dtSites As DataTable
        Dim da As New DataAccess
        dtSites = da.GetSites(ProcedureId, DiagramHeight, DiagramWidth, EpisodeNo, ProcedureTypeId, ColonType)
        Return DataTableToJson(dtSites)
    End Function

    Private Function DataTableToJson(dt As DataTable) As String
        If dt Is Nothing Then Return Nothing
        Dim serializer As System.Web.Script.Serialization.JavaScriptSerializer = New System.Web.Script.Serialization.JavaScriptSerializer()
        Dim rows As New List(Of Dictionary(Of String, Object))
        Dim row As Dictionary(Of String, Object)

        For Each dr As DataRow In dt.Rows
            row = New Dictionary(Of String, Object)
            For Each col As DataColumn In dt.Columns
                row.Add(col.ColumnName, dr(col))
            Next
            rows.Add(row)
        Next
        Return serializer.Serialize(rows)
    End Function

    Protected Overrides Sub Render(output As HtmlTextWriter)
        ProcedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))
        ProcedureTypeId = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))
        DiagramNumber = CInt(Session(Constants.SESSION_DIAGRAM_NUMBER))
        If Not String.IsNullOrWhiteSpace(Session(Constants.SESSION_IMAGE_GENDERID).ToString) Then
            ImageGenderId = CInt(Session(Constants.SESSION_IMAGE_GENDERID))
        Else
            ImageGenderId = 0
        End If
        LoadDiagram()
    End Sub

    Private Function GetSiteRadius() As Integer
        Dim da As New Options
        Dim dtSys As DataTable = da.GetSystemSettings()
        If dtSys.Rows.Count > 0 Then
            Return CInt(dtSys.Rows(0)("SiteRadius"))
        Else
            Return 5
        End If
    End Function

    Private Function GetImageUrl(procedureType As Integer, diagramNumber As Integer, imageGenderId As Integer) As Tuple(Of String, String)
        Dim da As New DataAccess
        Dim dtDiagram As DataTable = da.GetDiagram(procedureType, diagramNumber, 0, 0, False, imageGenderId)
        If dtDiagram IsNot Nothing AndAlso dtDiagram.Rows.Count > 0 Then
            Return New Tuple(Of String, String)(ResolveUrl(CStr(dtDiagram.Rows(0)("DefaultImageUrl"))),
                                        ResolveUrl(CStr(dtDiagram.Rows(0)("ReportImageUrl"))))
            'Return ResolveUrl(CStr(dtDiagram.Rows(0)("DefaultImageUrl")))
        Else
            Return New Tuple(Of String, String)("", "")
            'Return "",""
        End If
    End Function
End Class
