Imports Microsoft.VisualBasic
Imports System.IO
Imports Telerik.Web
Imports Telerik.Web.UI
Imports System.Reflection

Public Class SiteDetailsBase
    Inherits PageBase

    Private _abnormalitiesDataAdapter As Abnormalities = Nothing
    Private _abnormalitiesColonDataAdapter As AbnormalitiesColon = Nothing
    Private _specimensTakenDataAdapter As SpecimensTaken = Nothing
    Private _therapeuticsDataAdapter As Therapeutics = Nothing
    Private _notesDataAdapter As Notes = Nothing

    Protected ReadOnly Property AbnormalitiesDataAdapter() As Abnormalities
        Get
            If _abnormalitiesDataAdapter Is Nothing Then
                _abnormalitiesDataAdapter = New Abnormalities
            End If
            Return _abnormalitiesDataAdapter
        End Get
    End Property

    Protected ReadOnly Property AbnormalitiesColonDataAdapter() As AbnormalitiesColon
        Get
            If _abnormalitiesColonDataAdapter Is Nothing Then
                _abnormalitiesColonDataAdapter = New AbnormalitiesColon
            End If
            Return _abnormalitiesColonDataAdapter
        End Get
    End Property

    Protected ReadOnly Property SpecimensDataAdapter() As SpecimensTaken
        Get
            If _specimensTakenDataAdapter Is Nothing Then
                _specimensTakenDataAdapter = New SpecimensTaken
            End If
            Return _specimensTakenDataAdapter
        End Get
    End Property

    Protected ReadOnly Property TherapeuticsDataAdapter() As Therapeutics
        Get
            If _therapeuticsDataAdapter Is Nothing Then
                _therapeuticsDataAdapter = New Therapeutics
            End If
            Return _therapeuticsDataAdapter
        End Get
    End Property

    Protected ReadOnly Property NotesDataAdapter() As Notes
        Get
            If _notesDataAdapter Is Nothing Then
                _notesDataAdapter = New Notes
            End If
            Return _notesDataAdapter
        End Get
    End Property
    Protected Sub Page_PreInit() Handles Me.PreInit
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "PreInit_CloseLoadingPanel", "if (window.parent.HideLoadingPanel) { window.parent.HideLoadingPanel();}", True)
    End Sub

    'Protected Sub Page_Load() Handles Me.Load
    '    ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "CloseLoadingPanel", " window.parent.HideLoadingPanel();", True)
    'End Sub

    Private Sub Page_Error(sender As Object, e As EventArgs) Handles Me.Error
        Dim errorLogRef As String
        Dim exc As Exception = Server.GetLastError

        If exc.GetBaseException() IsNot Nothing Then
            'exc = exc.InnerException
            exc = exc.GetBaseException()
        End If

        errorLogRef = LogManager.LogManagerInstance.LogError("Unhandled error occured in one of the Site Details pop up pages, and caught in the Page.Error event in the base page, SiteDetailsBase.vb.", _
                                                             exc)
        'Utilities.SetErrorNotificationStyle(DirectCast(Me.FindControl("RadNotification1"), RadNotification), exc, errorLogRef, "There is a problem saving data.")

        Server.ClearError()

        Response.Redirect("~/Products/SiteDetailsError.aspx?ErrorRef=" & errorLogRef, False)

        'ClientScript.RegisterStartupScript(Me.GetType(), "Error_CloseLoadingPanel", " alert(1);window.parent.HideLoadingPanel();", True)
        'Page.RegisterStartupScript("Error_CloseLoadingPanel", " alert(1);window.parent.HideLoadingPanel();")

        'Utilities.SetErrorNotificationStyle(DirectCast(Me.FindControl("RadNotification1"), RadNotification), 
    End Sub

    Protected Overrides Sub RedirectToLoginPage()
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "sessionexpired", "window.parent.parent.location='" + ResolveUrl("~/Security/Logout.aspx") + "'; ", True)
    End Sub
    Protected Overrides Sub PageAccessLevel()
        If Session("PKUserId") IsNot Nothing Then
            Dim iAccessLevel = DataAdapter.getAccessForEditCreate() ' added by Ferdowsi TFS 4199
            'Dim iAccessLevel As Integer = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "create_procedure")
            'Dim iAccessLevel As Integer = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), Me.GetType.Name)
            Select Case iAccessLevel
                Case 0, 1
                    HttpContext.Current.Response.Redirect("~/Products/Restricted.aspx", False)
                Case 9
            End Select

        End If
    End Sub

    Private Sub Page_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
        PageAccessLevel()
    End Sub
    Private Sub DisableControls(control As Control)

        For Each c As Control In control.Controls

            ' Get the Enabled property by reflection.
            Dim type As Type = c.GetType
            'DataAdapter.InsertControl(type.Name)
            If "RadButton,FormView,RadioButton,RadioButtonList,RadTextBox,RadDateInput,UserControls_diagram,TextBox,RadDropDownList,RadDatePicker,RadComboBox,RadNumericTextBox,CheckBox,Image,RadAsyncUpload,ListView,image,RadLinkButton,LinkButton,HtmlLink,RadWindow,RadWindowManager,".ToLower.Contains(type.Name.ToLower & ",") Then
                Dim prop As PropertyInfo = type.GetProperty("Enabled")
                If Not prop Is Nothing Then
                    prop.SetValue(c, False, Nothing)
                End If
            End If

            If type.Name = "RadGrid" AndAlso DirectCast(c, RadGrid).ID <> "PatientsGrid" Then
                Dim vGrid As RadGrid = DirectCast(c, RadGrid)
                vGrid.Enabled = False
                If vGrid.Columns(0).ColumnType = "GridTemplateColumn" Then
                    vGrid.Columns(0).Visible = False
                End If
                vGrid.ClientSettings.Selecting.AllowRowSelect = False
            End If

            If c.Controls.Count > 0 Then
                Me.DisableControls(c)
            End If
        Next
    End Sub
End Class
