Imports Microsoft.VisualBasic
Imports Telerik.Web
Imports Telerik.Web.UI
Imports System.IO
Imports System.Reflection
Imports System.Drawing
Imports System.Web.Script.Serialization
Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.Blob
Imports Microsoft.WindowsAzure.Storage.File
Imports Hl7.Fhir.Model

Public MustInherit Class PageBase
    Inherits System.Web.UI.Page

    Private _logicAdapter As BusinessLogic = Nothing
    Private _dataAdapter As DataAccess = Nothing
    Private _dataAdapter_Sch As DataAccess_Sch = Nothing
    Private _sessionHelper As SessionManager = Nothing

#Region "Properties"
    Protected ReadOnly Property LogicAdapter() As BusinessLogic
        Get
            If _logicAdapter Is Nothing Then
                _logicAdapter = New BusinessLogic
            End If
            Return _logicAdapter
        End Get
    End Property

    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataAdapter Is Nothing Then
                _dataAdapter = New DataAccess
            End If
            Return _dataAdapter
        End Get
    End Property

    Protected ReadOnly Property DataAdapter_Sch() As DataAccess_Sch
        Get
            If _dataAdapter_Sch Is Nothing Then
                _dataAdapter_Sch = New DataAccess_Sch
            End If
            Return _dataAdapter_Sch
        End Get
    End Property

    Protected ReadOnly Property SessionHelper() As SessionManager
        Get
            If _sessionHelper Is Nothing Then
                _sessionHelper = New SessionManager
            End If
            Return _sessionHelper
        End Get
    End Property

    Public ReadOnly Property CacheFolderUri() As String
        Get
            If Right(Session(Constants.SESSION_PHOTO_URL), 1) = "/" Then
                Return Session(Constants.SESSION_PHOTO_URL) & "ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID) & "/Temp"
            Else
                Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID) & "/Temp"
            End If
            'Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Cache"
            'Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID) & "/Temp"
        End Get
    End Property

    Public ReadOnly Property CacheFolderPath() As String
        Get
            'Return Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Cache"
            If Right(Session(Constants.SESSION_PHOTO_UNC), 1) = "\" Then
                Return Session(Constants.SESSION_PHOTO_UNC) & "ERS\Photos\" & Session(Constants.SESSION_PROCEDURE_ID) & "\Temp"
            Else
                Return Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & Session(Constants.SESSION_PROCEDURE_ID) & "\Temp"
            End If
        End Get
    End Property

    Public ReadOnly Property TempPhotosFolderPath() As String
        Get
            If Right(Session(Constants.SESSION_PHOTO_UNC), 1) = "\" Then
                Return Session(Constants.SESSION_PHOTO_UNC) & "ERS\Temp"
            Else
                Return Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Temp"
            End If
        End Get
    End Property

    Public ReadOnly Property LogFolderPath() As String
        Get
            Return Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Log"
        End Get
    End Property

    Public ReadOnly Property PhotosFolderUri() As String
        Get
            If CBool(Session("isERSViewer")) Then
                Return Session(Constants.SESSION_PHOTO_URL)
            Else
                If Right(Session(Constants.SESSION_PHOTO_URL), 1) = "/" Then
                    Return Session(Constants.SESSION_PHOTO_URL) & "ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID)
                Else
                    Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID)
                End If

            End If
        End Get
    End Property

    Public ReadOnly Property PhotosFolderPath() As String
        Get
            If Right(Session(Constants.SESSION_PHOTO_UNC), 1) = "\" Then
                Return Session(Constants.SESSION_PHOTO_UNC) & "ERS\Photos\" & Session(Constants.SESSION_PROCEDURE_ID)
            Else
                Return Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & Session(Constants.SESSION_PROCEDURE_ID)
            End If
        End Get
    End Property


#End Region

    Private Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        Dim dT As DataTable = DataAdapter.isUserLockedOut(Session("RoomName"), Session("UserID"))
        If Not IsNothing(dT) AndAlso dT.Rows.Count > 0 Then
            If CInt(dT.Rows(0).Item("pcState")) = 1 Then
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "lockoutscript", "alert('" & dT.Rows(0).Item("pcMessage") & "'); window.parent.location='" + ResolveUrl("~/Security/Logout.aspx") + "'; ", True)
            End If
        End If
    End Sub

    'Private Sub Page_LoadComplete(sender As Object, e As EventArgs) Handles Me.LoadComplete
    '    RegisterControls(Me, Me.GetType.Name)
    'End Sub
    Private Sub PageBase_PreInit(sender As Object, e As EventArgs) Handles Me.PreInit
        '        PageAccessLevel()
        If String.IsNullOrWhiteSpace(Session("UserID")) Then
            Session.Contents.RemoveAll()
            Response.Redirect("~/Security/SELogin.aspx", False)
        End If

        If Session("isERSViewer") Is Nothing Then
            Session.Contents.RemoveAll()
            Response.Redirect("~/Security/SELogin.aspx", False)
        End If
        DisableValidators()
        SetLastActivityTime()
    End Sub

    Protected Overridable Sub PageAccessLevel()
        'If Not IsPostBack Then
        'DataAdapter.InsertPage(Path.GetFileName(Request.PhysicalPath).Replace(".aspx", ""), Me.GetType.Name)
        If Session("PKUserId") IsNot Nothing Then


            Dim iAccessLevel As Integer = 0 'DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), Me.GetType.Name)
            If Session("PKUserId") = "-9999" Then
                iAccessLevel = 9
            ElseIf Me.GetType.Name = "DefaultPage" Or Me.GetType.Name = "security_logout_aspx" Or Me.GetType.Name = "products_options_optionserror_aspx" Then
                iAccessLevel = 9
            ElseIf Me.GetType.Name = "products_patientprocedure_aspx" Or Me.GetType.Name = "products_procedure_aspx" Then 'all page level access goes here. set iaccess level accordingly

                iAccessLevel = DataAdapter.getAccessForEditCreate() ' added by Ferdowsi TFS 4199
                'iAccessLevel = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "create_procedure")

            ElseIf Me.GetType.Name.ToLower.Contains("products_reports") Then
                iAccessLevel = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "products_reports_reports_aspx")
            ElseIf Me.GetType.Name.ToLower.Contains("products_gastro_otherdata_printprocedure_aspx") Then
                iAccessLevel = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "products_common_printreport_aspx")
            ElseIf Me.GetType.Name.ToLower.Contains("products_common_gplist_aspx") Then
                iAccessLevel = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "products_common_patientdetails_aspx")
            ElseIf Me.GetType.Name.ToLower.Contains("products_scheduler_reports") Then
                iAccessLevel = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "products_scheduler_reports_scheduler_reports_aspx")
            Else
                iAccessLevel = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), Me.GetType.Name)
            End If

            'iAccessLevel = 9 '##### ReadOnlyException for shawkat
            If Me.GetType.Name = "DefaultPage" Then
                'check if user can create procedure
                Dim patientview As patientview = FindControlRecursive(Me, "patientview")
                Dim cp As Integer = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "create_procedure")
                If cp = 0 Or cp = 1 Then
                    DisableControls(DirectCast(FindControlRecursive(Me, "NewProcedurePageView"), RadPageView), True)
                    patientview.Enabled = False
                End If
                'check if user can print
                Dim pp As Integer = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "products_common_printreport_aspx")
                If pp = 0 Then
                    DisableControls(DirectCast(FindControlRecursive(Me, "RPVPrintOptions"), RadPageView))
                    DirectCast(FindControlRecursive(Me, "PrevProcSummaryTabStrip"), RadTabStrip).Tabs.FindTabByText("Print").Visible = False
                End If

                Dim pd As Integer = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "products_pas_pasdownload_aspx")
                If pd = 0 Then DirectCast(FindControlRecursive(Me, "PASDownloadButton"), RadButton).Enabled = False

                Dim ap As Integer = DataAdapter.GetPageAccessLevel(CInt(Session("PKUserId")), "products_common_patientdetails_aspx")
                If ap = 0 Then DirectCast(FindControlRecursive(Me, "AddPatientButton"), RadButton).Enabled = False


            End If

            Dim holder As System.Web.UI.Control

            If Me.Master IsNot Nothing Then
                holder = DirectCast(Me.Master.FindControl("BodyContentPlaceHolder"), ContentPlaceHolder)
            Else
                holder = Me
            End If

            ' If Session("SkinName").ToString <> "" Then
            'ApplySkin(Me)
            'End If

            Select Case iAccessLevel
                Case 0
                    HttpContext.Current.Response.Redirect("~/Products/Restricted.aspx", False)
                    'If Not IsNothing(Request.UrlReferrer) Then
                    '    MsgBox(Request.UrlReferrer.AbsoluteUri)
                    '    HttpContext.Current.Response.Redirect(Request.UrlReferrer.ToString)
                    'Else
                    '    HttpContext.Current.Response.Redirect("~/Products/Default.aspx")
                    'End If
                Case 1
                    DisableControls(Me.Page)
                    'Dim aControl As Control = FindControlRecursive(Me.Page, "SaveButton")
                    'If IsNothing(aControl) Then aControl = FindControlRecursive(Me.Page, "cmdAccept")
                    'If Not IsNothing(aControl) AndAlso aControl.GetType.Name = "RadButton" Then
                    '    DirectCast(aControl, RadButton).Enabled = False
                    'End If
                    ' ControlAccess({"SaveButton", "CancelButton"}, holder)

                Case 9
            End Select




            '0 - No Access
            '1 - Read Only
            '9 - Full Access

        End If
        ' End If

    End Sub
    Private Sub DisableControls(control As Control, Optional disableDropDowns As Boolean = False)

        For Each c As Control In control.Controls

            ' Get the Enabled property by reflection.
            Dim type As Type = c.GetType
            'If "RadButton,FormView,RadioButton,DataList,RadioButtonList,RadTextBox,RadDateInput,UserControls_diagram,TextBox,RadDropDownList,RadDatePicker,RadComboBox,RadNumericTextBox,CheckBox,Image,RadAsyncUpload,ListView,image,RadLinkButton,LinkButton,HtmlLink,RadWindow,RadWindowManager,".ToLower.Contains(type.Name.ToLower & ",") Then
            If "RadButton,FormView,RadioButton,DataList,RadioButtonList,RadTextBox,RadDateInput,UserControls_diagram,TextBox,RadDropDownList,RadDatePicker,RadNumericTextBox,CheckBox,Image,RadAsyncUpload,ListView,image,RadLinkButton,LinkButton,HtmlLink,RadWindow,RadWindowManager,".ToLower.Contains(type.Name.ToLower & ",") Then
                Dim prop As PropertyInfo = type.GetProperty("Enabled")
                If Not prop Is Nothing Then
                    prop.SetValue(c, False, Nothing)
                End If
            End If

            If type.Name = "RadButton" AndAlso DirectCast(c, RadButton).CssClass.ToLower = "filterbtn" Then
                Dim prop As PropertyInfo = type.GetProperty("Enabled")
                If Not prop Is Nothing Then
                    prop.SetValue(c, True, Nothing)
                End If
            End If

            If type.Name = "RadTextBox" AndAlso DirectCast(c, RadTextBox).CssClass.ToLower = "filtertxt" Then
                Dim prop As PropertyInfo = type.GetProperty("Enabled")
                If Not prop Is Nothing Then
                    prop.SetValue(c, True, Nothing)
                End If
            End If

            If type.Name = "RadComboBox" Then
                If DirectCast(c, RadComboBox).CssClass.ToLower = "filterddl" Or Not disableDropDowns Then
                    If DirectCast(c, RadComboBox).Items.FindItemByValue("-55") IsNot Nothing Then
                        Dim vDropDown As RadComboBox = DirectCast(c, RadComboBox)
                        vDropDown.Items.Remove(vDropDown.Items.FindItemByValue("-55"))
                    End If
                Else
                    Dim prop As PropertyInfo = type.GetProperty("Enabled")
                    If Not prop Is Nothing Then
                        prop.SetValue(c, False, Nothing)
                    End If
                End If
            End If

            If type.Name = "RadGrid" AndAlso DirectCast(c, RadGrid).ID <> "PatientsGrid" Then
                Dim vGrid As RadGrid = DirectCast(c, RadGrid)
                If vGrid.Columns(0).ColumnType = "GridTemplateColumn" Then
                    vGrid.Columns(0).Visible = False
                End If
                vGrid.ClientSettings.Selecting.AllowRowSelect = False
            End If

            If type.Name = "GridPagerItem" Then
                Continue For 'need this as will enter the disable contol loop and disable navigation buttons
            End If

            If type.Name = "DataList" Then
                Dim vDataList As DataList = DirectCast(c, DataList)

                For Each listCtrl As Control In vDataList.Controls
                    Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
                    If item.ItemType = ListItemType.Header Or item.ItemType = ListItemType.Footer Then
                        For Each co As Control In item.Controls
                            Dim propi As PropertyInfo = co.GetType.GetProperty("Enabled")
                            If Not IsNothing(propi) Then
                                propi.SetValue(co, False, Nothing)
                            Else
                                Dim propy As PropertyInfo = co.GetType.GetProperty("Disabled")
                                If Not IsNothing(propy) Then
                                    propy.SetValue(co, True, Nothing)
                                End If
                            End If
                        Next

                    End If
                Next
                For Each itm As DataListItem In vDataList.Items
                    For Each ci As Control In itm.Controls
                        Dim propi As PropertyInfo = ci.GetType.GetProperty("Enabled")
                        If Not IsNothing(propi) Then
                            propi.SetValue(ci, False, Nothing)
                        Else
                            Dim propy As PropertyInfo = ci.GetType.GetProperty("Disabled")
                            If Not IsNothing(propy) Then
                                propy.SetValue(ci, True, Nothing)
                            End If
                        End If
                    Next
                Next
            End If


            If c.Controls.Count > 0 Then
                Me.DisableControls(c, disableDropDowns)
            End If
        Next
    End Sub

    Private Sub RegisterControls(control As Control, pageID As String)
        For Each c As Control In control.Controls
            Dim jtype As Type = c.GetType
            Dim jtext As String = ""
            Dim jpropi As PropertyInfo = jtype.GetProperty("Text")
            If Not IsNothing(jpropi) Then
                jtext = CStr(jpropi.GetValue(c))
            End If
            DataAdapter.InsertControl(c.ID, jtype.Name, jtext, pageID)

            If c.GetType.Name = "DataList" Then
                Dim vDataList As DataList = DirectCast(c, DataList)

                For Each listCtrl As Control In vDataList.Controls
                    Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
                    If item.ItemType = ListItemType.Header Or item.ItemType = ListItemType.Footer Then
                        For Each co As Control In item.Controls
                            Dim type As Type = co.GetType
                            Dim text As String = ""
                            Dim propi As PropertyInfo = type.GetProperty("Text")
                            If Not IsNothing(propi) Then
                                text = CStr(propi.GetValue(co))
                            End If
                            DataAdapter.InsertControl(co.ID, type.Name, text, pageID)
                        Next
                    End If
                Next
                For Each itm As DataListItem In vDataList.Items
                    For Each ci As Control In itm.Controls
                        Dim typey As Type = ci.GetType
                        Dim texty As String = ""
                        Dim propy As PropertyInfo = typey.GetProperty("Text")
                        If Not IsNothing(propy) Then
                            texty = CStr(propy.GetValue(ci))
                        End If
                        DataAdapter.InsertControl(ci.ID, typey.Name, texty, pageID)
                    Next
                Next
            End If


            If c.Controls.Count > 0 Then
                Me.RegisterControls(c, pageID)
            End If
        Next
    End Sub
    Sub ApplySkin(target As Control)
        'Do not apply skin for login screen
        'If InStr(target.ToString, "security_login_aspx") > 0 Then Exit Sub

        If target IsNot Nothing Then
            If target.Controls IsNot Nothing Then
                For Each child As Control In target.Controls
                    'If Not Session("SkinName") Is Nothing AndAlso Session("SkinName").ToString = "" Then
                    ' If TypeOf child Is RadTabStrip Then
                    'DirectCast(child, ISkinnableControl).Skin = "Default"
                    '  ElseIf TypeOf child Is RadGrid Then
                    'DirectCast(child, ISkinnableControl).Skin = "Office2010Blue"
                    'DirectCast(child, ISkinnableControl).Skin = "Metro"
                    ' End If
                    'Else
                    If TypeOf child Is RadTextBox Or
                                TypeOf child Is RadComboBox Or TypeOf child Is RadDateInput Or
                                TypeOf child Is RadButton Or TypeOf child Is RadDatePicker Or TypeOf child Is RadFormDecorator Then
                        'Or
                        '       TypeOf child Is RadAjaxLoadingPanel Or TypeOf child Is RadFormDecorator Then
                        ' Or TypeOf child Is RadMenu
                        'TypeOf child Is RadFormDecorator Or
                        'TypeOf child Is RadGrid Or
                        'TypeOf child Is RadTabStrip Or
                        'DirectCast(child, ISkinnableControl).Skin = Session("SkinName")
                        DirectCast(child, ISkinnableControl).Skin = "Metro"
                    End If
                    'End If
                    'If TypeOf child Is Telerik.Web.ISkinnableControl Then
                    'End If
                    'InsertCtrlName(child.ID, child.ClientID, child.UniqueID)





                    ApplySkin(child)
                Next
            End If
        End If
    End Sub


    'Public Function InsertCtrlName(ByVal Ctrl As String, ByVal CtrlName As String, ByVal CtrlClientID As String) As Integer
    '    Dim sql As New StringBuilder
    '    sql.Append("INSERT INTO zz (aa,bb,cc) ")
    '    sql.Append("VALUES (@Ctrl, @CtrlName, @CtrlClientID) ")

    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand(sql.ToString(), connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@Ctrl", IIf(Ctrl Is Nothing, "", Ctrl)))
    '        cmd.Parameters.Add(New SqlParameter("@CtrlName", IIf(CtrlName Is Nothing, "", CtrlName)))
    '        cmd.Parameters.Add(New SqlParameter("@CtrlClientID", IIf(CtrlClientID Is Nothing, "", CtrlClientID)))

    '        connection.Open()
    '        Return CInt(cmd.ExecuteScalar())
    '    End Using
    'End Function

    Sub ControlAccess(sCtrlName() As String, holder As System.Web.UI.Control)
        Dim validator As WebControl
        If holder IsNot Nothing Then
            For Each sCtrl As String In sCtrlName
                validator = holder.FindControl(sCtrl)
                If validator IsNot Nothing Then
                    validator.Visible = False
                End If
            Next
        End If
    End Sub

    Protected Overridable Sub DisableValidators()
        Dim da As New Options
        Dim dtValidators As DataTable
        Dim validator As WebControl
        Dim holder As System.Web.UI.Control

        dtValidators = da.GetSuppressedValidators(Me.GetType.BaseType.ToString())

        If Not IsNothing(Me.Master) Then
            holder = DirectCast(Me.Master.FindControl("BodyContentPlaceHolder"), ContentPlaceHolder)
        Else
            holder = Me
        End If

        If holder IsNot Nothing Then
            For Each row As DataRow In dtValidators.Rows
                'validator = FindControlRecursive(holder, CStr(row("ValidatorControlId")))
                validator = holder.FindControl(CStr(row("ValidatorControlId")))
                If validator IsNot Nothing Then
                    validator.Enabled = False
                End If
            Next
        End If
    End Sub

    Protected Overridable Sub SetLastActivityTime()
        If Session("PKUserId") IsNot Nothing Then
            Dim da As New Options
            da.UpdateLastActiveTime(CInt(Session("PKUserId")))
        End If
    End Sub


    Private Sub PageBase_LoadComplete(sender As Object, e As EventArgs) Handles Me.LoadComplete
        If (Me.GetType.Name = "products_default_aspx" Or Me.GetType.Name = "products_common_printreport_aspx") AndAlso Request.Url.OriginalString.Contains("CNN=") Then
            Exit Sub
        End If

        'If TypeOf (Me) Is Security_Login Then
        'End If
        'Dim xx As String = Me.AppRelativeVirtualPath
        If Session("UserId") IsNot Nothing AndAlso Session("UserId") <> "unisoft" Then
            PageAccessLevel()
        End If
        If Me.GetType.Name <> "security_login_aspx" And Me.GetType.Name <> "security_logout_aspx" Then
            'redirct to login page if session expires
            If Session("Authenticated") Is Nothing Then
                RedirectToLoginPage()
            End If
        End If
        'GetPageFields()

        ''Rename (override) text of controls 
        'Dim formNameList As String = "Indications,Premed"
        'Dim formNameArr() As String
        'Dim fileName As String = Replace(System.IO.Path.GetFileName(Me.AppRelativeVirtualPath), ".aspx", "")
        'formNameArr = formNameList.Split(","c)
        'If formNameArr.Contains(fileName) Then
        '    Dim daFL As New Options
        '    Dim dtFL As DataTable = daFL.GetFieldLabels(fileName)
        '    If dtFL.Rows.Count > 0 Then
        '        RenameFieldLabels(dtFL)
        '    End If
        'End If
    End Sub


    Private Sub PageBase_PreRenderComplete(sender As Object, e As EventArgs) Handles Me.PreRenderComplete
        GetPageFields()
    End Sub

    Protected Overridable Sub RedirectToLoginPage()
        'Response.Redirect(Page.ResolveUrl("~") & "/Security/Login.aspx")
        'HttpContext.Current.Response.Redirect("~/Security/Login.aspx")
        HttpContext.Current.Response.Redirect("~/Security/Logout.aspx", False)
    End Sub
    Protected Sub GetPageFields()

        Dim daOptions As New Options
        Dim AppPageName As String = Me.GetType.Name
        Page.ClientScript.RegisterStartupScript(Me.GetType(), "UniqueIDScript", $"<script>var meWho = '{Me.GetType.Name}';</script>")

        Dim ProcedureType As Integer
        If Not Integer.TryParse(Session(Constants.SESSION_PROCEDURE_TYPE), ProcedureType) Then
            ProcedureType = 0
        End If
        Dim dtFieldLabels As DataTable = daOptions.GetFieldLabels(AppPageName, IIf(AppPageName = "DefaultPage", "0", ProcedureType))

        Dim jScript As String = ""

        If dtFieldLabels.Rows.Count > 0 Then
            RenameFieldLabels(dtFieldLabels)

            'set required fields
            Dim dtRequiredFields = dtFieldLabels.AsEnumerable.Where(Function(x) x.Field(Of Boolean)("Required") = True) '.CopyToDataTable()
            If dtRequiredFields.Count > 0 Then
                jScript = SetRequiredFields(dtRequiredFields.CopyToDataTable())
            End If
        End If
        If String.IsNullOrWhiteSpace(jScript) Then jScript = "var reqFields;"
        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "PreInit_SetRequiredFields", jScript, True)
    End Sub
    Private Function SetRequiredFields(dtRF As DataTable) As String
        Dim retVal = ""

        Dim requiredControls As New List(Of Object)
        Dim ctrl As WebControl
        Dim holder As System.Web.UI.Control

        If Not IsNothing(Me.Master) Then
            holder = If(DirectCast(Me.Master.FindControl("BodyContentPlaceHolder"), ContentPlaceHolder), Me)
        Else
            holder = Me
        End If

        For Each dr In dtRF.Rows
            If holder IsNot Nothing Then
                ctrl = FindControlRecursive(holder, CStr(dr("LabelID")))
                If ctrl Is Nothing Then ctrl = holder.FindControl(CStr(dr("LabelID")))
                If ctrl IsNot Nothing Then

                    Dim values = New With {
                        .control = ctrl.ClientID,
                        .fieldName = CStr(dr("FieldName"))
                    }

                    requiredControls.Add(values)
                End If
            End If
        Next

        If requiredControls.Count = 0 Then
            Dim values = New With {
             .control = "",
             .fieldName = ""
            }

            requiredControls.Add(values)
        End If

        retVal = "var reqFields={items:" & New JavaScriptSerializer().Serialize(requiredControls) & "};"

        Return retVal
    End Function
    Private Sub RenameFieldLabels(dtFL As DataTable)
        For Each dr As DataRow In dtFL.Rows
            Dim oControl As Control
            If CStr(dr("PageID")) = "304" Then 'products_gastro_otherdata_ogd_diagnoses_aspx  -  was 36
                oControl = FindControlByValueRecursive(Me.Page, CStr(dr("LabelID")))
            Else
                oControl = FindControlRecursive(Me.Page, CStr(dr("LabelID")))
            End If
            setControlProperte(oControl, dr)
            If CStr(dr("PageID")) = "34" AndAlso CStr(dr("LabelID")) = "DrugCheckBoxes" Then 'products_common_premed_aspx  -  was 34
                FindDrugsControlRecursive(Me.Page, dr)
            End If
        Next dr
    End Sub
    Private Sub setControlProperte(oControl As Control, dr As DataRow)
        If Not IsNothing(oControl) Then
            Dim oType As Type = oControl.GetType
            If Not IsNothing(oType) Then
                'labels only
                Dim prop As PropertyInfo = oType.GetProperty("Text")
                Dim oText As String = ""
                If Not IsDBNull(dr("Override")) AndAlso Not String.IsNullOrEmpty(dr("Override")) Then
                    If oType.Name = "Label" Then
                        oText = dr("Override").ToString()
                        Dim rLabel As Label = DirectCast(oControl, Label)
                        If oText.LastIndexOf(":") <> oText.Length Then oText += ":" 'incase user doesnt put : at the end of the override phrase. for consistancy....
                        rLabel.Text = oText
                    End If
                End If

                If Not dr("Colour") Is Nothing AndAlso Not IsDBNull(dr("Colour")) AndAlso dr("Colour") <> "" Then
                    If oType.Name = "RadButton" Then
                        Dim rButton As RadButton = DirectCast(oControl, RadButton)
                        If oText <> "" Then rButton.Text = oText
                        If rButton.ForeColor.Name.ToLower = "black" Or rButton.ForeColor.Name.ToLower = "0" Then rButton.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour"))) 'check if color has been set elsewhere 1st.. mainly for footer buttons, color would've ben changed to indicate that section has been complete
                    ElseIf oType.Name = "Button" Then
                        Dim rButton As Button = DirectCast(oControl, Button)
                        If oText <> "" Then rButton.Text = oText
                        rButton.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour")))
                    ElseIf oType.Name = "RadioButtonList" Then
                        Dim rButton As RadioButtonList = DirectCast(oControl, RadioButtonList)
                        For Each itm In rButton.Items
                            itm.Text = "<span style='color:" & dr("Colour").ToString() & ";'>" & itm.Text & "</span>"
                        Next
                    ElseIf oType.Name = "RadComboBox" Then
                        Dim rButton As RadComboBox = DirectCast(oControl, RadComboBox)
                        rButton.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour")))
                        For Each itm As RadComboBoxItem In rButton.Items
                            itm.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour")))
                        Next
                    ElseIf oType.Name = "RadDropDownList" Then
                        Dim rButton As RadDropDownList = DirectCast(oControl, RadDropDownList)
                        For Each itm As DropDownListItem In rButton.Items
                            itm.Text = "<span style='color:" & dr("Colour").ToString() & ";'>" & itm.Text & "</span>"
                        Next
                    ElseIf oType.Name = "RadTextBox" Then
                        Dim rButton As RadTextBox = DirectCast(oControl, RadTextBox)
                        rButton.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour")))
                    ElseIf oType.Name = "RadNumericTextBox" Then
                        Dim rButton As RadNumericTextBox = DirectCast(oControl, RadNumericTextBox)
                        rButton.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour")))
                    ElseIf oType.Name = "RadDateInput" Then
                        Dim rButton As RadDateInput = DirectCast(oControl, RadDateInput)
                        rButton.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour")))
                    ElseIf oType.Name = "RadDatePicker" Then
                        Dim rButton As RadDatePicker = DirectCast(oControl, RadDatePicker)
                        rButton.DateInput.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour")))
                    ElseIf oType.Name = "Label" Then
                        Dim rButton As Label = DirectCast(oControl, Label)
                        rButton.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour")))
                    ElseIf oType.Name = "CheckBox" Then
                        'Dim rButton As CheckBox = DirectCast(oControl, CheckBox)
                        'rButton.Attributes.Add("Style", "color:" & CStr(dr("Colour")))
                        oText = "<span style='color:" & CStr(dr("Colour")) & ";'>" & oText & "</span>"
                        If Not prop Is Nothing Then
                            prop.SetValue(oControl, oText, Nothing)
                        End If
                    ElseIf oType.Name = "TextBox" Then
                        Dim rCtrl As TextBox = DirectCast(oControl, TextBox)
                        rCtrl.ForeColor = ColorTranslator.FromHtml(CStr(dr("Colour")))
                    Else
                        oText = "<span style='color:" & CStr(dr("Colour")) & ";'>" & oText & "</span>"
                        If Not prop Is Nothing Then
                            prop.SetValue(oControl, oText, Nothing)
                        End If
                    End If
                End If
            End If
        End If
    End Sub
    'Private Sub RenameFieldLabels(dtFL As DataTable)
    '    For Each dr In dtFL.Rows
    '        Dim oControl As Control
    '        ' oControl = TryCast(FindAControl(Me.Controls, dr("LabelID").ToString()), CheckBox)

    '        If Not dr("ControlType") Is Nothing AndAlso Not IsDBNull(dr("ControlType")) AndAlso dr("ControlType") <> "" Then
    '            Select Case dr("ControlType")
    '                Case "Button"
    '                    'Dim oControl As RadButton
    '                    oControl = TryCast(FindControlRecursive(Me.Page, dr("LabelID").ToString()), RadButton)
    '                    ExecuteRenaming("RadButton", oControl, Nothing, Nothing, dr)
    '                Case "CheckBox"
    '                    'Dim oControl As CheckBox
    '                    oControl = TryCast(FindControlRecursive(Me.Page, dr("LabelID").ToString()), CheckBox)
    '                    ExecuteRenaming("CheckBox", Nothing, oControl, Nothing, dr)
    '                Case "Radio"
    '                    oControl = TryCast(FindControlRecursive(Me.Page, dr("LabelID").ToString()), RadioButtonList)

    '                    'For Each i As ListItem In oControl.Items
    '                    '    If dr("LabelName").ToString() = i.Text Then
    '                    '        ExecuteRenaming(oControl, dr)
    '                    '    End If
    '                    '    'i.Text = "<span style='color:red;'>" & i.Text & "</span>" Then
    '                    'Next
    '            End Select
    '        End If

    '        'oControl = TryCast(FindControlRecursive(Me.Page, dr("LabelID").ToString()), RadButton)

    '    Next dr
    'End Sub

    'Private Sub ExecuteRenaming(ctrlType As String, oCtrlRadButton As RadButton, oCtrlCheckBox As CheckBox, oCtrlRadioButtonList As RadioButtonList, dr As DataRow)
    '    Dim sText As String

    '    If Not dr("Override") Is Nothing AndAlso Not IsDBNull(dr("Override")) AndAlso dr("Override") <> "" Then
    '        sText = dr("Override").ToString()
    '    Else
    '        sText = dr("LabelName").ToString()
    '    End If
    '    If Not dr("Colour") Is Nothing AndAlso Not IsDBNull(dr("Colour")) AndAlso dr("Colour") <> "" Then
    '        sText = "<span style='color:" & dr("Colour").ToString() & ";'>" & sText & "</span>"
    '    End If
    '    Select Case ctrlType
    '        Case "RadButton"
    '            If oCtrlRadButton IsNot Nothing Then oCtrlRadButton.Text = sText
    '        Case "CheckBox"
    '            If oCtrlCheckBox IsNot Nothing Then oCtrlCheckBox.Text = sText
    '    End Select
    'End Sub

    Public Shared Function FindControlRecursive(root As Control, id As String) As Control
        If root.ID = id Then
            Return root
        End If

        Return root.Controls.Cast(Of Control)().[Select](Function(c) FindControlRecursive(c, id)).FirstOrDefault(Function(c) c IsNot Nothing)
    End Function
    Public Function FindDrugsControlRecursive(root As Control, dr As DataRow) As Control
        Dim iType As Type = root.GetType
        If iType.Name = "CheckBox" Then
            Dim id As String = DirectCast(root, CheckBox).ID
            If id.StartsWith("PreMedChkBox") Then
                setControlProperte(root, dr)
            End If
        End If
        Return root.Controls.Cast(Of Control)().[Select](Function(c) FindDrugsControlRecursive(c, dr)).FirstOrDefault(Function(c) c IsNot Nothing)
    End Function
    Public Shared Function FindControlByValueRecursive(root As Control, id As String) As Control
        Dim Type As Type = root.GetType
        If root.ID = id Then
            Return root
        ElseIf Type.Name = "DataList" Then
            Dim vDataList As DataList = DirectCast(root, DataList)

            For Each listCtrl As Control In vDataList.Controls
                Dim item As DataListItem = DirectCast(listCtrl, DataListItem)
                If item.ItemType = ListItemType.Header Or item.ItemType = ListItemType.Footer Then
                    For Each c As Control In item.Controls
                        If c.GetType.Name = "HtmlInputCheckBox" Then
                            If DirectCast(c, HtmlInputCheckBox).ID = id Then
                                Return item.Controls.Item(2)
                                'Return c
                            End If
                        ElseIf c.GetType.Name = "CheckBox" Then
                            If DirectCast(c, CheckBox).ID = id Then
                                Return c
                            End If
                        ElseIf c.GetType.Name = "RadioButton" Then
                            If DirectCast(c, RadioButton).ID = id Then
                                Return c
                            End If
                        End If
                    Next

                End If
            Next

            For Each itm As DataListItem In vDataList.Items
                For Each c As Control In itm.Controls
                    If c.GetType.Name = "HtmlInputCheckBox" Then
                        If DirectCast(c, HtmlInputCheckBox).Value = id Or DirectCast(itm.Controls.Item(2), Label).Text = id Then
                            Return itm.Controls.Item(2)
                            'Return c
                        End If
                    ElseIf c.GetType.Name = "CheckBox" Then
                        If DirectCast(c, CheckBox).ID = id Then
                            Return c
                        End If
                    ElseIf c.GetType.Name = "RadioButton" Then
                        If DirectCast(c, RadioButton).ID = id Then
                            Return c
                        End If
                    End If
                Next
            Next


        End If
        Return root.Controls.Cast(Of Control)().[Select](Function(c) FindControlByValueRecursive(c, id)).FirstOrDefault(Function(c) c IsNot Nothing)
    End Function

    'This function (FindAControl) should be replaced by FindControlRecursive
    Public Function FindAControl(ByVal controls As ControlCollection, ByVal toFind As String) As Control

        If String.IsNullOrEmpty(toFind) Then
            Throw New ArgumentException("Cannot find control '" & toFind & "'")
        End If

        If controls IsNot Nothing Then
            For Each oControl As Control In controls
                If oControl IsNot Nothing Then
                    If Not String.IsNullOrEmpty(oControl.ID) AndAlso oControl.ID.Equals(toFind, StringComparison.InvariantCultureIgnoreCase) Then
                        Return oControl
                    ElseIf oControl.HasControls Then
                        Dim oFoundControl As Control

                        oFoundControl = FindAControl(oControl.Controls, toFind)
                        If oFoundControl IsNot Nothing Then
                            Return oFoundControl
                        End If
                    End If
                End If
            Next
        End If

        Return Nothing
    End Function
    Function IBool(c As Object) As Boolean
        If IsDBNull(c) Then
            Return False
        Else
            Return CBool(c)
        End If
    End Function
    Function IStr(c As Object) As String
        If IsDBNull(c) Then
            Return ""
        Else
            Return CStr(c)
        End If
    End Function
    Function IInt(c As Object) As Integer
        If IsDBNull(c) Or CStr(c) = "" Then
            Return 0
        Else
            Return CInt(c)
        End If
    End Function

    Private Sub Page_Error(sender As Object, e As EventArgs) Handles Me.Error
        Dim exc As Exception = Server.GetLastError()
        If TypeOf exc Is HttpUnhandledException Then
            Using LM As New LogManager
                Server.Transfer("~/Errors/HttpErrorPage.aspx?ReturnUrl=" + Request.Path)
                LM.LogError("Unhandled Exception!", exc)
            End Using
        End If
    End Sub

    Protected Overrides Sub OnError(e As EventArgs)
        Dim exc As Exception = Server.GetLastError()
        If TypeOf exc Is HttpUnhandledException Then
            Using LM As New LogManager
                Server.Transfer("~/Errors/HttpErrorPage.aspx?ReturnUrl=" + Request.Path)
                LM.LogError("Unhandled Exception!", exc)
            End Using
        End If
    End Sub

    Public Sub New()

    End Sub

    Protected Overrides Sub Finalize()
        MyBase.Finalize()
    End Sub

    Private Sub PageBase_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
        ApplySkin(Me)
    End Sub

    Public Sub LoadPhotos()
        Try
            Dim DataAdaptor As New DataAccess
            If Not DataAdapter.IsProcedurePrinted(Session(Constants.SESSION_PROCEDURE_ID)) Then

                If String.IsNullOrEmpty(Session(Constants.SESSION_PROCEDURE_ID)) Or Session(Constants.SESSION_PROCEDURE_ID) = 0 Then
                    RedirectToLoginPage()
                End If
                Dim portId As Int32
                Dim portName As String
                Dim sessionRoomId As String = Session("RoomId")
                portName = Session("PortName")
                portId = Session("PortId")

                'Using db As New ERS.Data.GastroDbEntities
                'Dim dbImagePort = db.ERS_ImagePort.First(Function(x) x.RoomId = CInt(sessionRoomId))
                'portName = dbImagePort.PortName
                'portId = dbImagePort.ImagePortId
                'End Using

                'Dim da As New DataAccess
                'Dim dt As DataTable = da.GetProceduresImagePort(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
                'If dt.Rows.Count = 0 Then Exit Sub

                'Dim portId = CInt(dt.Rows(0)("ImagePortId"))
                'Dim portName = dt.Rows(0)("PortName")

                If portId = 0 Then Exit Sub   'No ImagePort attached to this computer

                If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                    LoadAzurePhotos(portId, portName)
                Else
                    LoadFilePhotos(portId, portName)
                End If
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured loading photos!!", ex)
            Throw ex
        End Try
    End Sub

    Public Sub LoadAzurePhotos(portId As Int32, portName As String)
        Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureFileStorageAccount"))
        Dim blobstorageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureBlobStorageAccount"))

        Dim blobClient As CloudBlobClient
        Dim blobContainer As CloudBlobContainer

        blobClient = blobstorageAccount.CreateCloudBlobClient()
        blobContainer = blobClient.GetContainerReference("imageport")

        blobContainer.CreateIfNotExists()
        blobContainer.SetPermissions(New BlobContainerPermissions With {.PublicAccess = BlobContainerPublicAccessType.Blob})
        ' Move over any new files on the imageport folder
        Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
        Dim share As CloudFileShare = fileClient.GetShareReference("imageportshare")
        If share.Exists() Then
            Dim rootDir As CloudFileDirectory = share.GetRootDirectoryReference()
            Dim sampleDir As CloudFileDirectory = rootDir.GetDirectoryReference(Session("PortName"))
            If sampleDir.Exists() AndAlso sampleDir.ListFilesAndDirectories.Count > 0 Then
                Dim iCount = 0
                For Each c As CloudFile In sampleDir.ListFilesAndDirectories
                    iCount += 1
                    Dim stream As MemoryStream = New MemoryStream()
                    c.DownloadToStream(stream)

                    stream.Position = 0
                    Dim blobRef As CloudBlockBlob
                    Dim newFileName = "ERS_" & Session(Constants.SESSION_PROCEDURE_ID) & "_" & ConfigurationManager.AppSettings("Unisoft.HospitalID") & "_" & Session("OperatingHospitalID") & "_" & Session(Constants.SESSION_PROCEDURE_TYPE) & "_" & portId.ToString() & "_" & iCount & "_" & Now.ToString("yyMMdd_HHmmss") & c.Name.Substring(c.Name.Length - 4)
                    blobRef = blobContainer.GetBlockBlobReference(CStr(Session(Constants.SESSION_PROCEDURE_ID)) + "/Temp/" + c.Name.ToString())
                    blobRef.UploadFromStream(stream)
                    'blobRef.Metadata("CreateDate") = c.Properties.LastModified.ToString()
                    blobRef.Metadata.Add("CreateDate", c.Properties.LastModified.ToString())
                    blobRef.SetMetadata()
                    c.Delete()
                Next
            End If
        End If

    End Sub

    Private Sub LoadFilePhotos(portId As Int32, portName As String)
        Dim sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & portName
        'Dim destinationPath = CType(Me.Page, Products_Default).CacheFolderPath 'cant instantiate pagebase so must take from parent page
        Dim destinationPath = CacheFolderPath
        Dim imageCount = 0
        If Directory.Exists(sourcePath) Then
            If Not Directory.Exists(destinationPath) Then Directory.CreateDirectory(destinationPath)
            Dim searchPatterns() As String = {"*.jpg", "*.bmp", "*.jpeg", "*.gif", "*.png", "*.tiff", "*.mp4", "*.mpg"} ', "*.mov", "*.wmv", "*.flv", "*.avi", "*.mpeg"}
            Dim iCount = 0
            Dim incompleteImage As Integer = 0
            For Each searchPattern As String In searchPatterns
                Dim imgFiles = Directory.GetFiles(sourcePath, searchPattern)
                For Each img In imgFiles
                    Dim fi As New FileInfo(img)
                    If fi.Extension = searchPattern.Replace("*", "") Then
                        iCount += 1
                        Dim newFileName = "ERS_" & Session(Constants.SESSION_PROCEDURE_ID) & "_" & ConfigurationManager.AppSettings("Unisoft.HospitalID") & "_" & Session("OperatingHospitalID") & "_" & Session(Constants.SESSION_PROCEDURE_TYPE) & "_" & portId.ToString() & "_" & iCount & "_" & Now.ToString("yyMMdd_HHmmss") & fi.Extension
                        Dim newFilePath = Path.Combine(destinationPath, newFileName)
                        Dim fileSize = fi.Length
                        File.Move(img, newFilePath)
                        Dim newFI As New FileInfo(newFilePath)
                        If newFI.Length = 0 Then
                            incompleteImage += 1
                        Else
                            imageCount += 1
                            File.Delete(img)
                        End If

                        'write to log
                        WriteLog(img, newFilePath, fileSize)

                        If fi.Extension = ".bmp" Then 'check for videos as .bmp is used for capturing a frame from the video for thumbnail
                            'Currently checking for .mpg and .mp4 only

                            Dim srcVideoFile As String = ""
                            Dim srcVideoExt As String = ""
                            If File.Exists(Replace(img, ".bmp", ".mp4")) Then
                                srcVideoFile = Replace(img, ".bmp", ".mp4")
                                srcVideoExt = ".mp4"
                            ElseIf File.Exists(Replace(img, ".bmp", ".mpg")) Then
                                srcVideoFile = Replace(img, ".bmp", ".mpg")
                                srcVideoExt = ".mpg"
                            End If
                            If srcVideoFile <> "" Then
                                Dim destVideoFile As String = Replace(newFilePath, ".bmp", srcVideoExt)
                                File.Copy(srcVideoFile, destVideoFile)
                                WriteLog(Replace(fi.Name, ".bmp", srcVideoExt), Replace(newFileName, ".bmp", srcVideoExt), fileSize)
                            End If
                        End If
                    End If
                Next
            Next

            'check if any remaining jpgs remaining
            Dim di As New DirectoryInfo(sourcePath)
            If incompleteImage = 0 And di.GetFiles().Where(Function(x) x.Extension = ".jpg").Count = 0 Then
                Dim directoryName As String = sourcePath
                For Each deleteFile In Directory.GetFiles(directoryName, "*.jpg*", SearchOption.TopDirectoryOnly)
                    File.Delete(deleteFile)
                Next
            End If
        End If
        If imageCount <> 0 Then
            Try
                Dim procedureId = CInt(Session(Constants.SESSION_PROCEDURE_ID))
                Dim da As New DataAccess
                da.insertImageCount(imageCount, procedureId)
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("error autosaving mucosal visualisation", ex)
                Throw New Exception(ref)
            End Try
        End If
    End Sub

    Private Sub WriteLog(src As String, dest As String, fileSize As Long)
        Dim da As New Options
        da.WriteFileMoveLog(src, dest, fileSize)
    End Sub


End Class
